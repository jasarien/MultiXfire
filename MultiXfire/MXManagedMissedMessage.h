//
//  MXManagedMissedMessage.h
//  MultiXfire
//
//  Created by James Addyman on 03/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MXManagedMissedMessage : NSManagedObject

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * remoteUsername;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSDate * date;

@end
