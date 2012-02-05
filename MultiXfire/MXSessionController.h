//
//  MXSessionController.h
//  MultiXfire
//
//  Created by James Addyman on 04/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XfireSession.h"

@class MXXfireUser, MXSessionController;

@protocol MXSessionControllerDelegate <NSObject>

- (void)sessionController:(MXSessionController *)session didChangeStatus:(XfireSessionStatus)status;
- (void)sessionControllerWillDisconnect:(MXSessionController *)session reason:(NSString *)reason;
- (void)sessionControllerLoginFailed:(MXSessionController *)session reason:(NSString *)reason;

@end

@interface MXSessionController : NSObject

@property (nonatomic, assign) id <MXSessionControllerDelegate> delegate;

@property (nonatomic, retain) MXXfireUser *user;
@property (nonatomic, retain) XfireSession *session;

- (id)initWithUser:(MXXfireUser *)user;

@end
