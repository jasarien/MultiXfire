//
//  MXUserListViewController.m
//  MultiXfire
//
//  Created by James Addyman on 28/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MXSessionsListViewController.h"
#import "MXManagedUser.h"

@interface MXSessionListViewController ()

- (void)viewDidLoad;

- (void)handleNewRegistrationNotification:(NSNotification *)note;

@end

@implementation MXSessionListViewController

@synthesize tableView = _tableView;
@synthesize sessions = _sessions;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		
    }
    
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.tableView = nil;
	self.sessions = nil;
	
    [super dealloc];
}

- (void)awakeFromNib
{
	[self viewDidLoad];
}

- (void)viewDidLoad
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleNewRegistrationNotification:)
												 name:newRegistrationNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleUnregistrationNotification:)
												 name:unregistrationNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleConnectNotification:)
												 name:connectNotification
											   object:nil];
}

- (void)setSessions:(NSMutableArray *)sessions
{
	[_sessions release];
	_sessions = [sessions retain];
	
	[self.tableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [self.sessions count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	MXSessionController *sessionController = [self.sessions objectAtIndex:rowIndex];
	
	if ([[aTableColumn identifier] isEqualToString:@"userColumn"])
	{
		return [[sessionController user] username];
	}
	else
	{
		NSImage *image = nil;
		
		switch ([[sessionController session] status])
		{
			case kXfireSessionStatusOnline:
				image = [NSImage imageNamed:@"green.png"];
				break;
			case kXfireSessionStatusOffline:
				image = [NSImage imageNamed:@"red.png"];
				break;
			default:
				image = [NSImage imageNamed:@"yellow.png"];
				break;
		}
		
		return image;
	}
	
	return nil;
}

- (void)sessionController:(MXSessionController *)session didChangeStatus:(XfireSessionStatus)status
{
	[[self tableView] reloadData];
	NSLog(@"%@ did change status: %d", [[session user] username], status);
}

- (void)sessionControllerWillDisconnect:(MXSessionController *)session reason:(NSString *)reason
{
	[[self tableView] reloadData];
	NSLog(@"%@ will disconnect: %@", [[session user] username], reason);
	
	if ([reason isEqualToString:kXfireUnknownNetworkErrorReason])
	{
		//reconnect
		[[session session] connect];
	}
}

- (void)sessionControllerLoginFailed:(MXSessionController *)session reason:(NSString *)reason
{
	[[self tableView] reloadData];
	NSLog(@"%@ login failed: %@", [[session user] username], reason);
}

- (void)handleNewRegistrationNotification:(NSNotification *)note
{
	MXManagedUser *user = [[note userInfo] objectForKey:@"user"];
	MXSessionController *session = [[[MXSessionController alloc] initWithUser:user] autorelease];
	[session setDelegate:self];
	if (![self.sessions containsObject:session])
	{
		[self.sessions addObject:session];
		[self.tableView reloadData];
	}
}

- (void)handleUnregistrationNotification:(NSNotification *)note
{
	MXManagedUser *user = [[note userInfo] objectForKey:@"user"];
	
	MXSessionController *unregSession = nil;
	
	for (MXSessionController *session in self.sessions)
	{
		if ([[[session user] username] isEqualToString:[user username]])
		{
			unregSession = session;
			break;
		}
	}
	
	[[unregSession session] disconnect];
	[self.sessions removeObject:unregSession];
	[self.tableView reloadData];
}

- (void)handleConnectNotification:(NSNotification *)note
{
	MXManagedUser *user = [[note userInfo] objectForKey:@"user"];
	[self.sessions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		MXSessionController *sessionController = (MXSessionController *)obj;
		if ([[[sessionController user] username] isEqualToString:[user username]])
		{
			dispatch_async(dispatch_get_main_queue(), ^{
				if ([[sessionController session] status] == kXfireSessionStatusOffline)
				{
					[sessionController stopHeartbeatTimer];
					[[sessionController session] connect];
				}
			});
			*stop = YES;
		}
	}];
}

@end
