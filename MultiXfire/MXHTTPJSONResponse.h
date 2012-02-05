//
//  MXHTTPJSONResponse.h
//  MultiXfire
//
//  Created by James Addyman on 24/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HTTPDataResponse.h"

@interface MXHTTPJSONResponse : HTTPDataResponse

@property (nonatomic, assign) NSInteger statusCode;

- (id)initWithData:(NSData *)_data statusCode:(NSInteger)statusCode;

@end
