/*******************************************************************
	FILE:		NSData_XfireAdditions.h
	
	COPYRIGHT:
		Copyright 2007-2008, the MacFire.org team.
		Use of this software is governed by the license terms
		indicated in the License.txt file (a BSD license).
	
	DESCRIPTION:
		Adds items to NSData that are useful for implementing the
		Xfire protocol.
	
	HISTORY:
		2008 04 06  Changed copyright to BSD license.
		2008 01 12  Added copyright notice.
		2007 10 14  Created.
*******************************************************************/

#import <Foundation/Foundation.h>

@interface NSData (XfireAdditions)

+ (NSData *)newUUID;

- (NSData*)sha1Hash;
- (NSString*)stringRepresentation;

- (unsigned char)byteAtIndex:(NSUInteger)index;

- (NSString *)enhancedDescription;

// tests for all zeros
- (BOOL)isClear;

@end
