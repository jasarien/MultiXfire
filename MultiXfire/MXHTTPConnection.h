#import <Cocoa/Cocoa.h>
#import "HTTPConnection.h"

extern NSString * const kRegisterResource;
extern NSString * const kUnregisterResource;
extern NSString * const kUnregisterDeviceResource;
extern NSString * const kConnectResource;
extern NSString * const kHeartbeatResource;
extern NSString * const kMissedMessagesResource;

@interface MXHTTPConnection : HTTPConnection

@end