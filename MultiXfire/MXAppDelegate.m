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
#import "MXSessionsListViewController.h"
#import "MXDataManager.h"
#import "MXManagedUser.h"
#import "MXManagedDevice.h"
#import "XfireSession.h"
#import "NSData+Base64Additions.h"

@interface MXAppDelegate ()

- (void)registerDevicesWithUA:(NSSet *)devices;

@end

@implementation MXAppDelegate

@synthesize window = _window;
@synthesize sessionsListViewController = _sessionsListViewController;

- (void)dealloc
{
	[_uaResponseData release], _uaResponseData = nil;
	[_serverController release], _serverController = nil;
	[_sessionsListViewController release], _sessionsListViewController = nil;
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	_serverController = [[MXHTTPServerController alloc] init];
	
//	_sessionsListViewController = [[MXSessionListViewController alloc] initWithNibName:@"MXSessionsListViewController"
//																				bundle:nil];
//	[[_sessionsListViewController view] setFrame:NSMakeRect(0, 0, 157, [[self.window contentView] frame].size.height)];
//	[[self.window contentView] addSubview:[_sessionsListViewController view]];
	
	NSMutableArray *sessions = [NSMutableArray array];
	
	for (MXManagedUser *user in [[MXDataManager sharedInstance] allUsers])
	{
		MXSessionController *sessionController = [[[MXSessionController alloc] initWithUser:user] autorelease];
		[sessionController setDelegate:_sessionsListViewController];
		[sessions addObject:sessionController];
		
		[self registerDevicesWithUA:[user devices]];
	}
	
	[_sessionsListViewController setSessions:sessions];
}

- (void)handleNewRegistrationNotification:(NSNotification *)note
{
	MXManagedUser *user = [[note userInfo] objectForKey:@"user"];
	[self registerDevicesWithUA:[user devices]];
}

- (void)registerDevicesWithUA:(NSSet *)devices
{
	for (MXManagedDevice *device in [devices allObjects])
	{
		[_uaResponseData release];
		_uaResponseData = [[NSMutableData alloc] init];
		
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://go.urbanairship.com/api/device_tokens/%@", [device pushToken]]];
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
		[request setHTTPMethod:@"PUT"];
		[request setValue:UAAuthKey forHTTPHeaderField:@"Authorization"];
		[NSURLConnection connectionWithRequest:request delegate:self];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[_uaResponseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *jsonResponse = [[[NSString alloc] initWithData:_uaResponseData encoding:NSUTF8StringEncoding] autorelease];
	[_uaResponseData release], _uaResponseData = nil;
	if ([jsonResponse length])
	{
		NSLog(@"UA Response: %@", jsonResponse);
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSString *jsonResponse = [[[NSString alloc] initWithData:_uaResponseData encoding:NSUTF8StringEncoding] autorelease];
	[_uaResponseData release], _uaResponseData = nil;
	if ([jsonResponse length])
	{
		NSLog(@"Failed, UA Response: %@", jsonResponse);
	}
}

@end
