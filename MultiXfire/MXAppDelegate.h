//
//  MXAppDelegate.h
//  MultiXfire
//
//  Created by James Addyman on 24/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MXHTTPServerController, MXSessionListViewController;

@interface MXAppDelegate : NSObject <NSApplicationDelegate> {
	
	MXHTTPServerController *_serverController;
	
	NSMutableData *_uaResponseData;
	
}

@property (nonatomic, assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) IBOutlet MXSessionListViewController *sessionsListViewController;

@end
