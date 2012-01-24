#import "MXHTTPConnection.h"
#import "HTTPMessage.h"
#import "MXHTTPJSONResponse.h"
#import "DDNumber.h"
#import "HTTPLogging.h"
#import "JSON.h"

static const int httpLogLevel = HTTP_LOG_LEVEL_WARN; // | HTTP_LOG_FLAG_TRACE;

NSString * const kRegisterResource = @"/register";

@interface MXHTTPConnection ()

- (NSDictionary *)requestBodyParamters;
- (NSObject<HTTPResponse> *)performRegister;

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
	
	return [super httpResponseForMethod:method URI:path];
}

- (void)prepareForBodyWithSize:(UInt64)contentLength
{

}

- (void)processBodyData:(NSData *)postDataChunk
{
	BOOL result = [request appendData:postDataChunk];
	if (!result)
	{
	}
}

- (NSDictionary *)requestBodyParamters
{
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	NSString *postStr = nil;
	
	NSData *postData = [request body];
	if (postData)
	{
		postStr = [[[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding] autorelease];
	}
	
	NSArray *keyValuePairs = [postStr componentsSeparatedByString:@"&"];
	for (NSString *keyValuePair in keyValuePairs)
	{
		NSArray *components = [keyValuePair componentsSeparatedByString:@"="];
		if ([components count] != 2)
			continue;
		
		NSString *key = [components objectAtIndex:0];
		NSString *value = [components objectAtIndex:1];
		[parameters setObject:value forKey:key];
	}
	
	return [[parameters copy] autorelease];
}

#pragma mark - Actions

- (NSObject<HTTPResponse> *)performRegister
{
	NSDictionary *parameters = [self requestBodyParamters];
	
//	NSString *username = [parameters objectForKey:@"username"];
//	NSString *password = [parameters objectForKey:@"password"];
	
	NSData *response = [[parameters JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
	
	return [[[MXHTTPJSONResponse alloc] initWithData:response] autorelease];
}

@end
