//
//  NSFileManager+DirectoryLocations.h
//  MultiXfire
//
//  Created by James Addyman on 28/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (DirectoryLocations)

- (NSString *)findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory
						   inDomain:(NSSearchPathDomainMask)domainMask
				appendPathComponent:(NSString *)appendComponent
							  error:(NSError **)errorOut;

- (NSString *)applicationSupportDirectory;

- (NSString *)dbPath;

@end
