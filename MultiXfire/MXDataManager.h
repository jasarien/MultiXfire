//
//  MXDataManager.h
//  MultiXfire
//
//  Created by James Addyman on 30/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MXManagedUser, MXManagedDevice;

@interface MXDataManager : NSObject {
	
	NSManagedObjectModel *_managedObjectModel;
	NSManagedObjectContext *_managedObjectContext;
	NSPersistentStoreCoordinator *_persistentStoreCoordinator;
	
}

+ (MXDataManager *)sharedInstance;

- (void)save;

- (NSArray *)allUsers;
- (MXManagedUser *)userForUsername:(NSString *)username;
- (MXManagedUser *)registerUserWithParameters:(NSDictionary *)parameters;
- (void)unregisterUser:(MXManagedUser *)user;

- (MXManagedDevice *)deviceForPushToken:(NSString *)pushToken;
- (void)unregisterDevice:(MXManagedDevice *)device forUser:(MXManagedUser *)user;

@end
