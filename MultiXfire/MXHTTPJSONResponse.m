//
//  MXHTTPJSONResponse.m
//  MultiXfire
//
//  Created by James Addyman on 24/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MXHTTPJSONResponse.h"

@implementation MXHTTPJSONResponse

- (NSInteger)status
{
	return 200;
}

- (NSDictionary *)httpHeaders
{
	return [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type", nil];
}

@end
