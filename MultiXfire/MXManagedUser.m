//
//  MXManagedUser.m
//  MultiXfire
//
//  Created by James Addyman on 30/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MXManagedUser.h"
#import "MXManagedDevice.h"
#import "MXManagedMissedMessage.h"


@implementation MXManagedUser

@dynamic username;
@dynamic passwordHash;
@dynamic devices;
@dynamic missedMessages;

- (void)prepareForDeletion
{
	[super prepareForDeletion];
	
	for (MXManagedDevice *device in [self devices])
	{
		if ([[device users] count] <= 1)
		{
			[[self managedObjectContext] deleteObject:device];
		}
	}
}

- (void)addMissedMessage:(NSDictionary *)missedMessageDict
{
	MXManagedMissedMessage *missedMessage = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([MXManagedMissedMessage class])
																		  inManagedObjectContext:[self managedObjectContext]];
	[missedMessage setUsername:[missedMessageDict objectForKey:@"username"]];
	[missedMessage setRemoteUsername:[missedMessageDict objectForKey:@"remoteUsername"]];
	[missedMessage setMessage:[missedMessageDict objectForKey:@"message"]];
	[missedMessage setDate:[missedMessageDict objectForKey:@"date"]];
	
	[self addMissedMessagesObject:missedMessage]; 
	
	[self.managedObjectContext save:nil];
}

@end
