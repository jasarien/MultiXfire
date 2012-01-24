//
//  MXHTTPServerController.m
//  MultiXfire
//
//  Created by James Addyman on 24/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MXHTTPServerController.h"
#import "HTTPServer.h"
#import "MXHTTPConnection.h"

@implementation MXHTTPServerController

- (id)init
{
	if ((self = [super init]))
	{
		_httpServer = [[HTTPServer alloc] init];
		
		[_httpServer setConnectionClass:[MXHTTPConnection class]];
		[_httpServer setType:@"_http._tcp."];
		[_httpServer setPort:8080];
		[_httpServer setDocumentRoot:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"]];
		
		NSError *error = nil;
		if (![_httpServer start:&error])
		{
			NSLog(@"Error starting server %@", [error localizedDescription]);
		}
	}
	
	return self;
}

- (void)dealloc
{
	[_httpServer release], _httpServer = nil;
	[super dealloc];
}

@end
