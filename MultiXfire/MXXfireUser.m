//
//  MXXfireUser.m
//  MultiXfire
//
//  Created by James Addyman on 28/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MXXfireUser.h"
#import "MXDevice.h"

@implementation MXXfireUser

@synthesize username = _username;
@synthesize passwordHash = _passwordHash;

- (id)initWithID:(NSInteger)userID
{
	if ((self = [super init]))
	{
		_userID = userID;
		_devices = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
	self.username = nil;
	self.passwordHash = nil;
	[_devices release], _devices = nil;
	
	[super dealloc];
}

- (NSInteger)userID
{
	return _userID;
}

- (void)addDevice:(MXDevice *)device
{
	if (![_devices containsObject:device])
	{
		[_devices addObject:device];
	}
}

- (void)removeDevice:(MXDevice *)device
{
	[_devices removeObject:device];
}

- (NSArray *)devices
{
	return [[_devices copy] autorelease];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p> {Username: %@, PasswordHash: %@, Devices: %@}", NSStringFromClass([self class]), self, self.username, self.passwordHash, [self devices], nil];
}

@end
