/*******************************************************************
	FILE:		XfireFriend.m
	
	COPYRIGHT:
		Copyright 2007-2008, the MacFire.org team.
		Use of this software is governed by the license terms
		indicated in the License.txt file (a BSD license).
	
	DESCRIPTION:
		Container represents information about a contact on the Xfire
		network.
	
	HISTORY:
		2008 04 12  Moved display string stuff out elsewhere.
		2008 04 06  Changed copyright to BSD license.
		2008 03 01  Added first and last name support.
		2008 02 10  Added support for game IP and port.
		2008 01 12  Added copyright notice.
		2007 11 20  Created.
*******************************************************************/

#import "XfireFriend.h"
#import "XfireSession_Private.h"
#import "NSString+ValidationAdditions.h"

@implementation XfireFriend

- (id)init
{
	self = [super init];
	if( self )
	{
		_userID = 0;
		_username = nil;
		_nickname = nil;
		_clanNicknames = [[NSMutableDictionary alloc] init];
		_clanIDs = [[NSMutableArray alloc] init];
		_firstName = nil;
		_lastName = nil;
		_avatarURL = nil;
		_isOnline = NO;
		_sessionID = nil;
		_statusString = nil;
		_publicIP = 0;
		_publicPort = 0;
		_gameID = 0;
		_gameIPAddress = 0;
		_gamePort = 0;
		_isClanMember = NO;
		_isDirectFriend = NO;
		_isFriendOfFriend = NO;
		_commonFriendIDs = nil;
	}
	return self;
}

- (void)dealloc
{
	[_username release];
	[_nickname release];
	[_clanNicknames release];
	[_clanIDs release];
	[_sessionID release];
	[_statusString release];
	[_commonFriendIDs release];
	[_avatarURL release];
	
	_username = nil;
	_nickname = nil;
	_clanNicknames = nil;
	_clanIDs = nil;
	_sessionID = nil;
	_statusString = nil;
	_commonFriendIDs = nil;
	_avatarURL = nil;
	
	[super dealloc];
}

- (void)setUserID:(NSUInteger)newID
{
	_userID = newID;
}
- (NSUInteger)userID
{
	return _userID;
}

- (void)setUserName:(NSString *)aName
{
	NSString *tmp = [aName copy];
	[_username release];
	_username = tmp;
}
- (NSString *)userName
{
	return _username;
}

- (void)setNickName:(NSString *)aName
{
	NSString *tmp = [aName copy];
	[_nickname release];
	_nickname = tmp;
}
- (NSString *)nickName
{
	return _nickname;
}

- (void)setClanNickname:(NSString *)aName forKey:(NSString *)key
{
	[_clanNicknames setObject:aName forKey:key];
}

- (NSString *)clanNicknameForKey:(NSString *)key
{
	return [_clanNicknames objectForKey:key];
}

- (NSString *)displayName
{
	NSDictionary *userOptions = [_session userOptions];
	BOOL displayNicknames = [[userOptions objectForKey:kXfireShowNicknamesOption] boolValue];
	
	if (displayNicknames)
	{
		if ([_nickname hasText])
		{
			return _nickname;
		}
	}
	return _username;
}

- (void)setFirstName:(NSString *)aName
{
	NSString *tmp = [aName copy];
	[_firstName release];
	_firstName = tmp;
}
- (NSString *)firstName
{
	return _firstName;
}

- (void)setLastName:(NSString *)aName
{
	NSString *tmp = [aName copy];
	[_lastName release];
	_lastName = tmp;
}
- (NSString *)lastName
{
	return _lastName;
}

- (void)setAvatarURL:(NSURL *)aURL
{
	if (_avatarURL)
	{
		[_avatarURL release];
		_avatarURL = nil;
	}
	
	_avatarURL = [aURL retain];
}

- (NSURL *)avatarURL
{
	return _avatarURL;
}


- (void)setIsOnline:(BOOL)status
{
	_isOnline = status;
}
- (BOOL)isOnline
{
	return _isOnline;
}

- (void)setIsClanMember:(BOOL)clanMember
{
	_isClanMember = clanMember;
}

- (BOOL)isClanMember
{
	return _isClanMember;
}

- (void)addClanID:(NSUInteger)clanID
{
	[_clanIDs addObject:[NSNumber numberWithUnsignedInteger:clanID]];
}

- (NSArray *)clanIDs
{
	return [[_clanIDs copy] autorelease];
}

- (void)setIsDirectFriend:(BOOL)isDirectFriend
{
	_isDirectFriend = isDirectFriend;
}

- (BOOL)isDirectFriend
{
	return _isDirectFriend;
}

- (void)setIsFriendOfFriend:(BOOL)isFoF
{
	_isFriendOfFriend = isFoF;
}
- (BOOL)isFriendOfFriend
{
	return _isFriendOfFriend;
}

- (void)setSessionID:(NSData *)anID
{
	NSData *tmp = [anID copy];
	[_sessionID release];
	_sessionID = tmp;
}
- (NSData *)sessionID
{
	return _sessionID;
}

- (void)setPublicIP:(NSUInteger)anIP
{
	_publicIP = anIP;
}
- (NSUInteger)publicIP
{
	return _publicIP;
}

- (void)setPublicPort:(unsigned short)aPort
{
	_publicPort = aPort;
}
- (unsigned short)publicPort
{
	return _publicPort;
}

- (void)setStatusString:(NSString *)aString
{
	NSString *tmp = [aString copy];
	[_statusString release];
	_statusString = tmp;
}
- (NSString *)statusString
{
	if( _statusString )
		return _statusString;
	return @"";
}

- (void)setGameID:(NSUInteger)anID
{
	_gameID = anID;
}
- (NSInteger)gameID
{
	return _gameID;
}

- (void)setGameIPAddress:(NSUInteger)anIP
{
	_gameIPAddress = anIP;
}
- (NSUInteger)gameIPAddress
{
	return _gameIPAddress;
}

- (void)setGamePort:(unsigned short)port
{
	_gamePort = port;
}
- (unsigned short)gamePort
{
	return _gamePort;
}

- (void)setSession:(XfireSession *)aSession
{
	_session = aSession;
}

- (XfireSession *)session
{
	return _session;
}

// For Friend of Friend only
- (void)addCommonFriendID:(NSNumber*)anID
{
	if( _commonFriendIDs == nil )
		_commonFriendIDs = [[NSMutableArray alloc] init];
	[_commonFriendIDs addObject:anID];
}

// array of XfireFriend
- (NSArray *)commonFriends
{
	NSUInteger i, cnt;
	NSMutableArray *arr = [NSMutableArray array];
	NSNumber *frID;
	XfireFriend *fr;
	
	cnt = [_commonFriendIDs count];
	for( i = 0; i < cnt; i++ )
	{
		frID = [_commonFriendIDs objectAtIndex:i];
		fr = [[self session] friendForUserID:[frID unsignedIntValue]];
		if( fr )
		{
			[arr addObject:fr];
		}
	}
	
	return arr;
}

- (NSString *)description
{
	NSMutableString *str = [NSMutableString string];
	
	[str appendFormat:@"XfireFriend (%@):\n", _nickname];
	[str appendFormat:@"  user ID     = %u (0x%08x)\n", _userID, _userID];
	[str appendFormat:@"  user name   = %@\n", _username];
	[str appendFormat:@"  nick name   = %@\n", _nickname];
	[str appendFormat:@"  clan nicknames = %@ \n", _clanNicknames];
	[str appendFormat:@"  status      = %@\n", _statusString];
	[str appendFormat:@"  game ID     = %d\n", _gameID];
	[str appendFormat:@"  session ID  = %@\n", _sessionID];
	[str appendFormat:@"  is online   = %@\n", (_isOnline?@"Yes":@"No")];
	[str appendFormat:@"  is clan member = %@\n", (_isClanMember?@"Yes":@"No")];
	[str appendFormat:@"  clan IDs	  = %@\n", _clanIDs];
	[str appendFormat:@"  public IP   = %d (0x%08x)\n",_publicIP, _publicIP];
	[str appendFormat:@"  public port = %d\n", _publicPort];
	[str appendFormat:@"  avatar url  = %@\n", _avatarURL];
	
	
	return str;
}

- (NSComparisonResult)compareFriendsByUserName:(XfireFriend *)aFriend
{
	return [[self userName] caseInsensitiveCompare:[aFriend userName]];
}

- (NSComparisonResult)compareFriendsByDisplayName:(XfireFriend *)aFriend
{
	return [[self userName] caseInsensitiveCompare:[aFriend displayName]];
}

- (BOOL)isEqual:(id)object
{
	return [[self userName] isEqualToString:[object userName]];
}

- (NSUInteger)hash
{
	return [[self userName] hash];
}

@end
