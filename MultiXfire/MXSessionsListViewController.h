//
//  MXUserListViewController.h
//  MultiXfire
//
//  Created by James Addyman on 28/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MXSessionController.h"

@interface MXSessionListViewController : NSViewController <NSTabViewDelegate, NSTableViewDataSource, MXSessionControllerDelegate>

@property (nonatomic, assign) IBOutlet NSTableView *tableView;
@property (nonatomic, retain) NSMutableArray *sessions;

@end
