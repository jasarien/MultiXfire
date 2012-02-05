//
//  MXDBController.h
//  MultiXfire
//
//  Created by James Addyman on 28/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase, MXXfireUser, MXDevice, MXDBManager;

@protocol MXDBManagerDelegate <NSObject>

- (void)dbManager:(MXDBManager *)dbManager addedNewUser:(MXXfireUser *)user;

@end

@interface MXDBManager : NSObject {
	
	FMDatabase *_database;
	
	id <MXDBManagerDelegate> _delegate;
	
}

@property (nonatomic, assign) id <MXDBManagerDelegate> delegate;

+ (MXDBManager *)sharedInstance;

- (id)initWithDatabaseName:(NSString *)databaseName;

- (MXXfireUser *)ensureUserExistsWithParamters:(NSDictionary *)params error:(NSError **)error;
- (MXDevice *)ensureDeviceExistsWithParamters:(NSDictionary *)params error:(NSError **)error;
- (void)ensureLinkExistsBetweenUser:(MXXfireUser *)user device:(MXDevice *)device error:(NSError **)error;

- (MXXfireUser *)userForUserID:(NSInteger)userID;
- (MXDevice *)deviceForID:(NSInteger)deviceID;
- (NSArray *)allUsers;

@end
