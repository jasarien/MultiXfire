//
//  Constants.h
//  MultiXfire
//
//  Created by James Addyman on 04/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef MultiXfire_Constants_h
#define MultiXfire_Constants_h

#define MXErrorDomain @"MXErrorDomain"

#define MXErrorCodeUserNotInDatabase 0
#define MXErrorCodeDeleteUserFromDBFailed 1

#define newRegistrationNotification @"newRegistrationNotification"
#define unregistrationNotification @"unregistrationNotification"
#define connectNotification @"connectNotification"
#define receivedHeartbeatNotification @"receivedHeartbeatNotification"
#define receivedKillHeartbeatNotification @"receivedKillHeartbeatNotification"

#ifdef DEBUG
	#define UAAuthKey @"Basic TWhMbGZ4WUxRWXktNDRfSktoNEJFZzpORDByWnZiTlR4RzFVM21SMU9rdEZ3"
#else
	#define UAAuthKey @"Basic Z0Q2T0liUnFUbk9XLVU2Rm5BRjh4QTpGalZDYWVXVFNOQzMtaTV2MFp1TS1R"
#endif

//MD5 ("com.jamsoftonline.multixfire") = 404bb4d207c54b32062f07b9b2ae6272
//MD5 ("m0n1t0r-spr4y-d3sk") = 65b1b8462642f90bb42d77299681acd1

#define MXConnectionUsername @"404bb4d207c54b32062f07b9b2ae6272"
#define MXConnectionPassword @"65b1b8462642f90bb42d77299681acd1"

#endif
