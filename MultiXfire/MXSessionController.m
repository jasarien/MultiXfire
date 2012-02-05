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
#import "MXXfireUser.h"

@implementation MXSessionController

@synthesize delegate = _delegate;

@synthesize user = _user;
@synthesize session = _session;

- (id)initWithUser:(MXXfireUser *)user
{
	if ((self = [super init]))
	{
		self.user = user;
		self.session = [XfireSession newSessionWithHost:XfireHostName port:XfirePortNumber];
		[self.session setPosingClientVersion:XfirePoseClientVersion];
		[self.session setDelegate:self];
	}
	
	return self;
}

- (void)dealloc
{
	self.user = nil;
	self.session = nil;
	
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
	if ([self.delegate respondsToSelector:@selector(sessionControllerWillDisconnect:reason:)])
	{
		[self.delegate sessionControllerWillDisconnect:self reason:reason];
	}
}

@end
