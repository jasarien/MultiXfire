//
//  MXAppDelegate.m
//  MultiXfire
//
//  Created by James Addyman on 24/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MXAppDelegate.h"
#import "NSFileManager+DirectoryLocations.h"
#import "MXHTTPServerController.h"
#import "MXDBManager.h"
#import "MXSessionsListViewController.h"
#import "MXXfireUser.h"
#import "XfireSession.h"

@implementation MXAppDelegate

@synthesize window = _window;

- (void)dealloc
{
	[_serverController release], _serverController = nil;
	[_sessionsListViewController release], _sessionsListViewController = nil;
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSString *dbPath = [[NSFileManager defaultManager] dbPath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:dbPath] == NO)
	{
		NSError *error = nil;
		if (![[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"users" ofType:@"sqlite"]
												toPath:dbPath
												 error:&error])
		{
			NSLog(@"Error copying db to App Support directory: %@", [error localizedDescription]);
		}
	}
	
	_serverController = [[MXHTTPServerController alloc] init];
	
	NSLog(@"%@", [[MXDBManager sharedInstance] allUsers]);
	
	_sessionsListViewController = [[MXSessionListViewController alloc] initWithNibName:@"MXSessionsListViewController"
																				bundle:nil];
	[[_sessionsListViewController view] setFrame:NSMakeRect(0, 0, 157, [[self.window contentView] frame].size.height)];
	[[self.window contentView] addSubview:[_sessionsListViewController view]];
	
	NSMutableArray *sessions = [NSMutableArray array];
	
	for (MXXfireUser *user in [[MXDBManager sharedInstance] allUsers])
	{
		MXSessionController *sessionController = [[[MXSessionController alloc] initWithUser:user] autorelease];
		[sessionController setDelegate:_sessionsListViewController];
		[sessions addObject:sessionController];
	}
	
	[_sessionsListViewController setSessions:sessions];
}

@end
