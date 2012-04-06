#import "MXHTTPConnection.h"
#import "HTTPMessage.h"
#import "MXHTTPJSONResponse.h"
#import "DDNumber.h"
#import "HTTPLogging.h"
#import "SBJson.h"
#import "NSFileManager+DirectoryLocations.h"
#import "MXDataManager.h"
#import "MXManagedUser.h"
#import "MXManagedDevice.h"
#import "MXManagedMissedMessage.h"

static const int httpLogLevel = HTTP_LOG_LEVEL_WARN; // | HTTP_LOG_FLAG_TRACE;

NSString * const kUnregisterResource = @"/unregister";
NSString * const kUnregisterDeviceResource = @"/unregisterDevice";
NSString * const kRegisterResource = @"/register";
NSString * const kConnectResource = @"/connect";
NSString * const kHeartbeatResource = @"/heartbeat";
NSString * const kKillHeartbeatResource = @"/killHeartbeat";
NSString * const kMissedMessagesResource = @"/missedMessages";

@interface MXHTTPConnection ()

- (NSDictionary *)requestBody;
- (NSObject<HTTPResponse> *)performRegister;
- (NSObject<HTTPResponse> *)performUnregister;
- (NSObject <HTTPResponse> *)performUnregisterDevice;
- (NSObject<HTTPResponse> *)performConnect;
- (NSObject<HTTPResponse> *)receivedHeartbeat;
- (NSObject<HTTPResponse> *)receivedKillHeartbeat;
- (NSObject<HTTPResponse> *)getMissedMessages;

- (void)postNewRegistrationNotificationForUser:(MXManagedUser *)user;
- (void)postUnregistrationNotificationForUser:(MXManagedUser *)user;
- (void)postConnectNotificationForUser:(MXManagedUser *)user;

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
		if ([path isEqualToString:kUnregisterResource])
		{
			return YES;
		}
		if ([path isEqualToString:kUnregisterDeviceResource])
		{
			return YES;
		}
		else if ([path isEqualToString:kConnectResource])
		{
			return YES;
		}
		else if ([path isEqualToString:kHeartbeatResource])
		{
			return YES;
		}
		else if ([path isEqualToString:kKillHeartbeatResource])
		{
			return YES;
		}
		else if ([path isEqualToString:kMissedMessagesResource])
		{
			return YES;
		}
	}
	
	return [super supportsMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	if ([method isEqualToString:@"POST"])
	{
		if ([path isEqualToString:kRegisterResource])
		{
			return [self performRegister];
		}
		else if ([path isEqualToString:kUnregisterResource])
		{
			return [self performUnregister];
		}
		else if ([path isEqualToString:kUnregisterDeviceResource])
		{
			return [self performUnregisterDevice];
		}
		else if ([path isEqualToString:kConnectResource])
		{
			return [self performConnect];
		}
		else if ([path isEqualToString:kHeartbeatResource])
		{
			return [self receivedHeartbeat];
		}
		else if ([path isEqualToString:kKillHeartbeatResource])
		{
			return [self receivedKillHeartbeat];
		}
		else if ([path isEqualToString:kMissedMessagesResource])
		{
			return [self getMissedMessages];
		}
	}	
	return [super httpResponseForMethod:method URI:path];
}

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

- (void)postNewRegistrationNotificationForUser:(MXManagedUser *)user
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:newRegistrationNotification
															object:self
														  userInfo:[NSDictionary dictionaryWithObject:user forKey:@"user"]];
	});
}

- (void)postUnregistrationNotificationForUser:(MXManagedUser *)user
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:unregistrationNotification
															object:self
														  userInfo:[NSDictionary dictionaryWithObject:user forKey:@"user"]];
	});
}

- (void)postConnectNotificationForUser:(MXManagedUser *)user
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:connectNotification
															object:self
														  userInfo:[NSDictionary dictionaryWithObject:user forKey:@"user"]];
	});
}

- (NSObject<HTTPResponse> *)performRegister
{
	NSDictionary *parameters = [self requestBody];
	
	NSDictionary *userParams = [parameters objectForKey:@"user"];
	NSString *username = [userParams objectForKey:@"username"];
	NSString *passwordHash = [userParams objectForKey:@"passwordHash"];
	
	NSDictionary *deviceParams = [userParams objectForKey:@"device"];
	NSString *pushToken = [deviceParams objectForKey:@"pushToken"];

	if (![username length] ||
		![passwordHash length] ||
		![pushToken length])
	{
		NSDictionary *responseDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Invalid parameters", @"error", nil];
		NSData *response = [[responseDict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
		return [[[MXHTTPJSONResponse alloc] initWithData:response statusCode:400] autorelease];
	}
	
	__block NSData *response = nil;
	
	dispatch_sync(dispatch_get_main_queue(), ^{
		MXManagedUser *user = [[MXDataManager sharedInstance] registerUserWithParameters:userParams];
		
		[self postNewRegistrationNotificationForUser:user];
		
		NSMutableArray *devices = [NSMutableArray array];
		for (MXManagedDevice *dev in [user devices])
		{
			NSDictionary *deviceDict = [NSDictionary dictionaryWithObjectsAndKeys:
										[dev pushToken], @"pushToken", nil];
			[devices addObject:deviceDict];
		}
		
		NSDictionary *responseDict = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObjectsAndKeys:
																		 [user username], @"username",
																		 [user passwordHash], @"passwordHash",
																		 devices, @"devices", nil]
																 forKey:@"user"];
		response = [[[responseDict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding] retain];
	});
	
	[response autorelease];
	
	return [[[MXHTTPJSONResponse alloc] initWithData:response statusCode:200] autorelease];
}

- (NSObject <HTTPResponse> *)performUnregister
{
	NSDictionary *parameters = [self requestBody];
	
	NSDictionary *userParams = [parameters objectForKey:@"user"];
	NSString *username = [userParams objectForKey:@"username"];
	
	if (![username length])
	{
		NSDictionary *responseDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Invalid parameters", @"error", nil];
		NSData *response = [[responseDict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
		return [[[MXHTTPJSONResponse alloc] initWithData:response statusCode:400] autorelease];
	}
	
	__block MXManagedUser *user = nil;
	dispatch_sync(dispatch_get_main_queue(), ^{
		user = [[MXDataManager sharedInstance] userForUsername:username];
	});
	
	if (!user)
	{
		NSDictionary *responseDict = [NSDictionary dictionaryWithObjectsAndKeys:@"User Does Not Exist", @"error", nil];
		NSData *response = [[responseDict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
		return [[[MXHTTPJSONResponse alloc] initWithData:response statusCode:404] autorelease];
	}
	
	dispatch_sync(dispatch_get_main_queue(), ^{
		[[MXDataManager sharedInstance] unregisterUser:user];
	});
	
	return [[[MXHTTPJSONResponse alloc] initWithData:nil statusCode:200] autorelease];
}

- (NSObject <HTTPResponse> *)performUnregisterDevice
{
	NSDictionary *parameters = [self requestBody];
	
	NSDictionary *userParams = [parameters objectForKey:@"user"];
	NSString *username = [userParams objectForKey:@"username"];

	NSDictionary *deviceParams = [userParams objectForKey:@"device"];
	NSString *pushToken = [deviceParams objectForKey:@"pushToken"];
	
	if (![username length] ||
		![pushToken length])
	{
		NSDictionary *responseDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Invalid parameters", @"error", nil];
		NSData *response = [[responseDict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
		return [[[MXHTTPJSONResponse alloc] initWithData:response statusCode:400] autorelease];
	}
	
	__block MXManagedUser *user = nil;
	__block MXManagedDevice *device = nil;
	
	dispatch_sync(dispatch_get_main_queue(), ^{
		user = [[MXDataManager sharedInstance] userForUsername:username];
		device = [[MXDataManager sharedInstance] deviceForPushToken:pushToken];
	});
	
	if (!user || !device)
	{
		NSDictionary *responseDict = [NSDictionary dictionaryWithObjectsAndKeys:@"User or Device Does Not Exist", @"error", nil];
		NSData *response = [[responseDict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
		return [[[MXHTTPJSONResponse alloc] initWithData:response statusCode:404] autorelease];
	}
	
	dispatch_sync(dispatch_get_main_queue(), ^{
		[[MXDataManager sharedInstance] unregisterDevice:device forUser:user];
	});
	
	return [[[MXHTTPJSONResponse alloc] initWithData:nil statusCode:200] autorelease];
}

- (NSObject <HTTPResponse> *)performConnect
{
	NSDictionary *parameters = [self requestBody];
	
	NSDictionary *userParams = [parameters objectForKey:@"user"];
	NSString *username = [userParams objectForKey:@"username"];
	
	if (![username length])
	{
		NSDictionary *responseDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Invalid parameters", @"error", nil];
		NSData *response = [[responseDict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
		return [[[MXHTTPJSONResponse alloc] initWithData:response statusCode:400] autorelease];
	}
	
	__block MXManagedUser *user = nil;
	
	dispatch_sync(dispatch_get_main_queue(), ^{
		user = [[MXDataManager sharedInstance] userForUsername:username];
	});
	
	[self postConnectNotificationForUser:user];
	
	return [[[MXHTTPJSONResponse alloc] initWithData:nil statusCode:200] autorelease];
}

- (NSObject<HTTPResponse> *)receivedHeartbeat
{
	NSDictionary *parameters = [self requestBody];
	NSDictionary *userParams = [parameters objectForKey:@"user"];
	NSString *username = [userParams objectForKey:@"username"];
	
	if (![username length])
	{
		NSDictionary *responseDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Invalid parameters", @"error", nil];
		NSData *response = [[responseDict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
		return [[[MXHTTPJSONResponse alloc] initWithData:response statusCode:400] autorelease];
	}	
	
	__block MXManagedUser *user = nil;
	
	dispatch_sync(dispatch_get_main_queue(), ^{
		user = [[MXDataManager sharedInstance] userForUsername:username];
	});
	
	dispatch_sync(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:receivedHeartbeatNotification
															object:self
														  userInfo:[NSDictionary dictionaryWithObject:user forKey:@"user"]];
	});
	
	return [[[MXHTTPJSONResponse alloc] initWithData:nil statusCode:200] autorelease];
}

- (NSObject<HTTPResponse> *)receivedKillHeartbeat
{
	NSDictionary *parameters = [self requestBody];
	NSDictionary *userParams = [parameters objectForKey:@"user"];
	NSString *username = [userParams objectForKey:@"username"];
	
	if (![username length])
	{
		NSDictionary *responseDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Invalid parameters", @"error", nil];
		NSData *response = [[responseDict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
		return [[[MXHTTPJSONResponse alloc] initWithData:response statusCode:400] autorelease];
	}	
	
	__block MXManagedUser *user = nil;
	
	dispatch_sync(dispatch_get_main_queue(), ^{
		user = [[MXDataManager sharedInstance] userForUsername:username];
	});
	
	dispatch_sync(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:receivedKillHeartbeatNotification
															object:self
														  userInfo:[NSDictionary dictionaryWithObject:user forKey:@"user"]];
	});
	
	return [[[MXHTTPJSONResponse alloc] initWithData:nil statusCode:200] autorelease];	
}

- (NSObject<HTTPResponse> *)getMissedMessages
{
	NSDictionary *parameters = [self requestBody];
	NSDictionary *userParams = [parameters objectForKey:@"user"];
	NSString *username = [userParams objectForKey:@"username"];
	
	if (![username length])
	{
		NSDictionary *responseDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Invalid parameters", @"error", nil];
		NSData *response = [[responseDict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
		return [[[MXHTTPJSONResponse alloc] initWithData:response statusCode:400] autorelease];
	}	
	
	NSMutableArray *missedMessages = [NSMutableArray array];
	
	dispatch_sync(dispatch_get_main_queue(), ^{
		MXManagedUser *user = [[MXDataManager sharedInstance] userForUsername:username];
		NSArray *allObjects = [[user missedMessages] allObjects];
		for (MXManagedMissedMessage *mm in allObjects)
		{
			NSTimeInterval timeSince1970 = [[mm date] timeIntervalSince1970];
			NSString *date = [NSString stringWithFormat:@"%f", timeSince1970];
			
			NSDictionary *missedMessage = [NSDictionary dictionaryWithObjectsAndKeys:[[[mm remoteUsername] copy] autorelease], @"username", [[[mm message] copy] autorelease], @"message", date, @"date", nil];
			[missedMessages addObject:missedMessage];
		}
		
		[user removeMissedMessages:[user missedMessages]];
		[[MXDataManager sharedInstance] save];
	});
	
	[missedMessages sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
		return [[obj1 objectForKey:@"date"] compare:[obj2 objectForKey:@"date"]];
	}];
	
	NSDictionary *responseDict = [NSDictionary dictionaryWithObject:missedMessages forKey:@"missedMessages"];
	
	NSData *response = [[responseDict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
	return [[[MXHTTPJSONResponse alloc] initWithData:response statusCode:200] autorelease];
}

@end
