//
//  MXAppDelegate.m
//  MultiXfire
//
//  Created by James Addyman on 24/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MXAppDelegate.h"
#import "MXHTTPServerController.h"

@implementation MXAppDelegate

@synthesize window = _window;

- (void)dealloc
{
	[_serverController release], _serverController = nil;
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	_serverController = [[MXHTTPServerController alloc] init];
}



@end
