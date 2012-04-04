//
//  MXManagedUser.h
//  MultiXfire
//
//  Created by James Addyman on 30/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MXManagedDevice, MXManagedMissedMessage;

@interface MXManagedUser : NSManagedObject

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * passwordHash;
@property (nonatomic, retain) NSSet *devices;
@property (nonatomic, retain) NSSet *missedMessages;

@end

@interface MXManagedUser (CoreDataGeneratedAccessors)

- (void)addDevicesObject:(MXManagedDevice *)value;
- (void)removeDevicesObject:(MXManagedDevice *)value;
- (void)addDevices:(NSSet *)values;
- (void)removeDevices:(NSSet *)values;

- (void)addMissedMessagesObject:(MXManagedMissedMessage *)value;
- (void)removeMissedMessagesObject:(MXManagedMissedMessage *)value;
- (void)addMissedMessages:(NSSet *)values;
- (void)removeMissedMessages:(NSSet *)values;

- (void)addMissedMessage:(NSDictionary *)missedMessage;

@end
