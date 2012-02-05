//
//  MXHTTPJSONResponse.m
//  MultiXfire
//
//  Created by James Addyman on 24/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MXHTTPJSONResponse.h"

@implementation MXHTTPJSONResponse

@synthesize statusCode = _statusCode;

- (id)initWithData:(NSData *)_data statusCode:(NSInteger)statusCode
{
	if ((self = [super initWithData:_data]))
	{
		_statusCode = statusCode;
	}
	
	return self;
}

- (NSInteger)status
{
	return self.statusCode;
}

- (NSDictionary *)httpHeaders
{
	return [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type", nil];
}

@end
