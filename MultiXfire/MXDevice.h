//
//  MXDevice.h
//  MultiXfire
//
//  Created by James Addyman on 28/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MXDevice : NSObject {

	NSInteger _deviceID;
	
}

@property (nonatomic, copy) NSString *udid;
@property (nonatomic, copy) NSString *pushToken;

- (id)initWithID:(NSInteger)deviceID;

- (NSInteger)deviceID;

@end
