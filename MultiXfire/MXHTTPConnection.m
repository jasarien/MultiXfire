#import "MXHTTPConnection.h"
#import "HTTPMessage.h"
#import "MXHTTPJSONResponse.h"
#import "DDNumber.h"
#import "HTTPLogging.h"
#import "JSON.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "NSFileManager+DirectoryLocations.h"
#import "MXDBManager.h"
#import "MXXfireUser.h"
#import "MXDevice.h"

static const int httpLogLevel = HTTP_LOG_LEVEL_WARN; // | HTTP_LOG_FLAG_TRACE;

NSString * const kRegisterResource = @"/register";
NSString * const kConnectResource = @"/connect";

@interface MXHTTPConnection ()

- (NSDictionary *)requestBody;
- (NSObject<HTTPResponse> *)performRegister;
- (NSObject<HTTPResponse> *)performConnect;
- (void)postNewRegistrationNotificationForUser:(MXXfireUser *)user;
- (void)postConnectNotificationForUsername:(NSString *)username;
@end

@implementation MXHTTPConnection

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
	if ([method isEqualToString:@"POST"])
	{
		if ([path isEqualToString:kRegisterResource])
		{
			return YES;
		}
		else if ([path isEqualToString:kConnectResource])
		{
			return YES;
		}
	}
	
	return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
	if([method isEqualToString:@"POST"])
		return YES;
	
	return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	if ([method isEqualToString:@"POST"] && [path isEqualToString:kRegisterResource])
	{
		return [self performRegister];
	}
	else if ([method isEqualToString:@"POST"] && [path isEqualToString:kConnectResource])
	{
		return [self performConnect];
	}
	
	return [super httpResponseForMethod:method URI:path];
}

//- (void)prepareForBodyWithSize:(UInt64)contentLength
//{
//	
//}

- (void)processBodyData:(NSData *)postDataChunk
{
	[request appendData:postDataChunk];
}

- (NSDictionary *)requestBody
{
	SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
	NSDictionary *body = [parser objectWithData:[request body]];
	return body;
}

#pragma mark - Actions

- (NSObject<HTTPResponse> *)performRegister
{
	NSDictionary *parameters = [self requestBody];
	
	NSDictionary *user = [parameters objectForKey:@"user"];
	NSString *username = [user objectForKey:@"username"];
	NSString *passwordHash = [user objectForKey:@"passwordHash"];
	
	NSDictionary *device = [user objectForKey:@"device"];
	NSString *udid = [device objectForKey:@"udid"];
	NSString *pushToken = [device objectForKey:@"pushToken"];

	if (![username length] ||
		![passwordHash length] ||
		![udid length] ||
		![pushToken length])
	{
		NSDictionary *responseDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Invalid parameters", @"error", nil];
		NSData *response = [[responseDict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
		return [[[MXHTTPJSONResponse alloc] initWithData:response statusCode:400] autorelease];
	}
	
	NSError *error = nil;
	
	FMDatabase *users = [FMDatabase databaseWithPath:[[NSFileManager defaultManager] dbPath]];
	[users open];
		
	MXXfireUser *xfireUser = [[MXDBManager sharedInstance] ensureUserExistsWithParamters:user error:&error];
	if (!user && error)
	{
		NSLog(@"Error inserting new user: %@", [error localizedDescription]);
		NSDictionary *responseDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Error creating new user: %@", [error localizedDescription]], @"error", nil];
		NSData *response = [[responseDict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
		return [[[MXHTTPJSONResponse alloc] initWithData:response statusCode:400] autorelease];
	}
	
	MXDevice *xfireDevice = [[MXDBManager sharedInstance] ensureDeviceExistsWithParamters:device error:&error];
	if (!device && error)
	{
		NSLog(@"Error inserting new device: %@", [error localizedDescription]);
		NSDictionary *responseDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Error creating new device: %@", [error localizedDescription]], @"error", nil];
		NSData *response = [[responseDict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
		return [[[MXHTTPJSONResponse alloc] initWithData:response statusCode:400] autorelease];		
	}
	
	[xfireUser addDevice:xfireDevice];
	
	[[MXDBManager sharedInstance] ensureLinkExistsBetweenUser:xfireUser device:xfireDevice error:&error];
	if (error)
	{
		NSLog(@"Error inserting userDevice link %@", [error localizedDescription]);
		NSDictionary *responseDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Error creating new user-device link: %@", [error localizedDescription]], @"error", nil];
		NSData *response = [[responseDict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
		return [[[MXHTTPJSONResponse alloc] initWithData:response statusCode:400] autorelease];
	}
	
	NSMutableArray *devices = [NSMutableArray array];
	for (MXDevice *dev in [xfireUser devices])
	{
		NSDictionary *deviceDict = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithInteger:[dev deviceID]], @"deviceID",
									[dev udid], @"udid",
									[dev pushToken], @"pushToken", nil];
		[devices addObject:deviceDict];
	}
	
	[self postNewRegistrationNotificationForUser:xfireUser];
	
	NSDictionary *responseDict = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObjectsAndKeys:
																		[NSNumber numberWithInteger:[xfireUser userID]], @"userID",
																		[xfireUser username], @"username",
																		[xfireUser passwordHash], @"passwordHash",
																		devices, @"devices", nil]
															 forKey:@"user"];
	NSData *response = [[responseDict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
	return [[[MXHTTPJSONResponse alloc] initWithData:response statusCode:200] autorelease];
}

- (void)postNewRegistrationNotificationForUser:(MXXfireUser *)user
{
	[[NSNotificationCenter defaultCenter] postNotificationName:newRegistrationNotification
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:user forKey:@"xfireUser"]];
}

- (NSObject <HTTPResponse> *)performConnect
{
	NSDictionary *parameters = [self requestBody];
	
	NSDictionary *user = [parameters objectForKey:@"user"];
	NSString *username = [user objectForKey:@"username"];
	
	[self postConnectNotificationForUsername:username];
	
	return [[[MXHTTPJSONResponse alloc] initWithData:nil statusCode:200] autorelease];
}

- (void)postConnectNotificationForUsername:(NSString *)username
{
	[[NSNotificationCenter defaultCenter] postNotificationName:connectNotification
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:username forKey:@"username"]];
}

@end
