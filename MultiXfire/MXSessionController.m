//
//  MXSessionController.m
//  MultiXfire
//
//  Created by James Addyman on 04/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MXSessionController.h"
#import "XfireSession.h"
#import "XfireSession_Private.h"
#import "MXDataManager.h"
#import "MXManagedUser.h"
#import "MXManagedDevice.h"
#import "MXManagedMissedMessage.h"
#import "SBJson.h"

#define heartbeatInterval 130

@interface MXSessionController ()

- (void)pushMessage:(NSString *)message fromFriend:(XfireFriend *)friend;

@end

@implementation MXSessionController

@synthesize delegate = _delegate;

@synthesize user = _user;
@synthesize session = _session;

@synthesize response = _response;

- (id)initWithUser:(MXManagedUser *)user
{
	if ((self = [super init]))
	{
		_heartbeatTimer = nil;
		
		self.user = user;
		self.session = [XfireSession newSessionWithHost:XfireHostName port:XfirePortNumber];
		[self.session setPosingClientVersion:XfirePoseClientVersion];
		[self.session setDelegate:self];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handleHeartbeatNotification:)
													 name:receivedHeartbeatNotification
												   object:nil];
	}
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.user = nil;
	self.session = nil;
	self.response = nil;
	
	[super dealloc];
}

- (BOOL)isEqual:(id)object
{
	MXSessionController *otherController = (MXSessionController *)object;
	
	if ([[[otherController user] username] isEqualToString:[[self user] username]])
	{
		return YES;
	}
	
	return NO;
}

- (NSUInteger)hash
{
	return [[[self user] username] hash];
}

- (void)xfireGetSession:(XfireSession *)session userName:(NSString **)aName password:(NSString **)password
{
	*aName = [self.user username];
	*password = [self.user passwordHash];
}

- (XfireSkin *)xfireSessionSkin:(XfireSession *)session
{
	return [XfireSkin theSkin];
}

- (void)xfireSession:(XfireSession *)session didChangeStatus:(XfireSessionStatus)newStatus
{
	if ([self.delegate respondsToSelector:@selector(sessionController:didChangeStatus:)])
	{
		[self.delegate sessionController:self didChangeStatus:newStatus];
	}
}

- (void)xfireSessionLoginFailed:(XfireSession *)session reason:(NSString *)reason
{
	if ([self.delegate respondsToSelector:@selector(sessionControllerLoginFailed:reason:)])
	{
		[self.delegate sessionControllerLoginFailed:self reason:reason];
	}	
}

- (void)xfireSessionWillDisconnect:(XfireSession *)session reason:(NSString *)reason
{
	//reset Session
	self.session = [XfireSession newSessionWithHost:XfireHostName port:XfirePortNumber];
	[self.session setPosingClientVersion:XfirePoseClientVersion];
	[self.session setDelegate:self];
	
	if ([self.delegate respondsToSelector:@selector(sessionControllerWillDisconnect:reason:)])
	{
		[self.delegate sessionControllerWillDisconnect:self reason:reason];
	}
}

- (void)xfireSession:(XfireSession *)session didBeginChat:(XfireChat *)chat
{
	[chat setDelegate:self];
}

- (void)xfireSession:(XfireSession *)session chat:(XfireChat *)aChat didReceiveMessage:(NSString *)msg
{
	NSLog(@"%@ says: %@", [[aChat remoteFriend] userName], msg);
	
	NSDictionary *missedMessage = [NSDictionary dictionaryWithObjectsAndKeys:[self.user username], @"username", [[aChat remoteFriend] userName], @"remoteUsername", msg, @"message", [NSDate date], @"date", nil];
	[self.user addMissedMessage:missedMessage];
	
	[self pushMessage:msg fromFriend:[aChat remoteFriend]];
}

- (void)xfireSession:(XfireSession *)session chat:(XfireChat *)chat didReceiveTypingNotification:(BOOL)typing
{
	
}

- (void)pushMessage:(NSString *)message fromFriend:(XfireFriend *)friend
{
	NSMutableString *devicesString = [NSMutableString stringWithString:@"["];
	NSArray *devices = [[self.user devices] allObjects];
	for (MXManagedDevice *device in devices)
	{
		if ([device isEqual:[devices lastObject]])
		{
			[devicesString appendFormat:@"\"%@\"", [device pushToken]];
		}
		else
		{
			[devicesString appendFormat:@"\"%@\",", [device pushToken]];
		}
	}
	[devicesString appendString:@"]"];
	
	NSString *alert = [NSString stringWithFormat:@"%@: %@", [friend userName], message];
	
	NSURL *url = [NSURL URLWithString:@"https://go.urbanairship.com/api/push/"];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setValue:UAAuthKey forHTTPHeaderField:@"Authorization"];
	
	NSString *body = [NSString stringWithFormat:@"{\"device_tokens\":%@,\"aps\":{\"badge\":%d,\"alert\":\"%@\",\"sound\":\"Purr.aiff\"}}", devicesString, [[self.user missedMessages] count], alert];
	NSLog(@"body: %@", body);
	NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
	[request setHTTPBody:bodyData];
	[NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	self.response = (NSHTTPURLResponse *)response;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if ([self.response statusCode] != 200)
	{
		NSLog(@"Push Response Status %ld", [self.response statusCode]);
	}
	else
	{
		NSLog(@"Push request successful");
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"Error sending push request:%@", [error localizedDescription]);
}

- (void)handleHeartbeatNotification:(NSNotification *)note
{
	MXManagedUser *user = [[note userInfo] objectForKey:@"user"];
	if ([[user username] isEqualToString:[self.user username]] && [self.session status] == kXfireSessionStatusOffline)
	{
		NSLog(@"Got heartbeat, restarting timer");
		[self stopHeartbeatTimer];
		_heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:heartbeatInterval
														   target:self
														 selector:@selector(heartbeatTimerExpired:)
														 userInfo:nil
														  repeats:NO];
	}
}

- (void)stopHeartbeatTimer
{
	[_heartbeatTimer invalidate], _heartbeatTimer = nil;
}

- (void)heartbeatTimerExpired:(NSTimer *)timer
{
	NSLog(@"heartbeat expired - logging in");
	
	[self stopHeartbeatTimer];
	[self.session connect];
}

@end
