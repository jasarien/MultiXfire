//
//  MXXfireUser.h
//  MultiXfire
//
//  Created by James Addyman on 28/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MXDevice;

@interface MXXfireUser : NSObject {
	
	NSInteger _userID;
	
	NSMutableArray *_devices;
	
}

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *passwordHash;

- (id)initWithID:(NSInteger)userID;

- (NSInteger)userID;

- (void)addDevice:(MXDevice *)device;
- (void)removeDevice:(MXDevice *)device;
- (NSArray *)devices;

@end
