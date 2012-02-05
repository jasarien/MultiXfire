//
//  MXDevice.m
//  MultiXfire
//
//  Created by James Addyman on 28/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MXDevice.h"

@implementation MXDevice

@synthesize udid = _udid;
@synthesize pushToken = _pushToken;

- (id)initWithID:(NSInteger)deviceID
{
	if ((self = [super init]))
	{
		_deviceID = deviceID;
	}
	
	return self;
}

- (void)dealloc
{
	self.udid = nil;
	self.pushToken = nil;
	
	[super dealloc];
}

- (NSInteger)deviceID
{
	return _deviceID;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p> {UDID: %@, PushToken: %@}", NSStringFromClass([self class]), self, self.udid, self.pushToken, nil];
}

@end
