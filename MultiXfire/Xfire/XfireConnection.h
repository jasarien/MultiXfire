/*******************************************************************
	FILE:		XfireConnection.h
	
	COPYRIGHT:
		Copyright 2007-2008, the MacFire.org team.
		Use of this software is governed by the license terms
		indicated in the License.txt file (a BSD license).
	
	DESCRIPTION:
		Abstract base class with common support for a threaded
		connection to some kind of IP socket.
	
	HISTORY:
		2008 04 06  Changed copyright to BSD license.
		2008 02 10  Eliminated secondary reader thread.
		2008 01 11  Rewrote using new threading and notification model.
		            Should be less likely to have problems later.
		2007 10 26  Created.
*******************************************************************/

#import <Foundation/Foundation.h>

@class JSAsyncSocket;
@class XfireSession;
@class XfirePacket;
@class XfirePacketLogger;

typedef enum
{
	kXfireConnectionDisconnected = 0,
	kXfireConnectionStarting,
	kXfireConnectionConnected,
	kXfireConnectionStopping
} XfireConnectionStatus;

@interface XfireConnection : NSObject
{
	// Unchanging once created
	NSString				*_host;
	unsigned short			_port;
	XfireSession			*_session; // not retained
	
	JSAsyncSocket				*_socket;
	XfireConnectionStatus	_status;
	XfirePacketLogger		*_packetLogger;
}

// The login connection is the initial connection to the Xfire server
// NOTE: This does not autorelease the result.
// TODO: Later: Connections to other things (peers, HTTP servers, etc.)
+ (id)newLoginConnectionToHost:(NSString *)host port:(unsigned short)portNumber;


// Get/set -- don't change this after set!
- (void)setSession:(XfireSession *)session;
- (XfireSession *)session;

// Send keepalive, if applicable
- (void)keepAlive;

// Connect/disconnect
- (void)connect;
- (void)disconnect;

// Connection status
- (XfireConnectionStatus)status;

// Sending data
- (void)sendPacket:(XfirePacket *)pkt;

// Receiving data is handled by internal receiver, which determines
// what to do with it.

@end
