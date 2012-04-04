//
//  MXManagedDevice.h
//  MultiXfire
//
//  Created by James Addyman on 30/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MXManagedUser;

@interface MXManagedDevice : NSManagedObject

@property (nonatomic, retain) NSString * pushToken;
@property (nonatomic, retain) NSSet *users;
@end

@interface MXManagedDevice (CoreDataGeneratedAccessors)

- (void)addUsersObject:(MXManagedUser *)value;
- (void)removeUsersObject:(MXManagedUser *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

@end
