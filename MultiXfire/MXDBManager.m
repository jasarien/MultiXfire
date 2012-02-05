//
//  MXDBController.m
//  MultiXfire
//
//  Created by James Addyman on 28/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MXDBManager.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "NSFileManager+DirectoryLocations.h"
#import "JSON.h"
#import "MXXfireUser.h"
#import "MXDevice.h"

static MXDBManager *_sharedInstance;

@implementation MXDBManager

@synthesize delegate = _delegate;

+ (MXDBManager *)sharedInstance
{
	static dispatch_once_t predicate;
	dispatch_once(&predicate, ^{
		_sharedInstance = [[self alloc] initWithDatabaseName:@"users"]; 
	});
	return _sharedInstance;
}

- (id)initWithDatabaseName:(NSString *)databaseName
{
	if ((self = [super init]))
	{
		_database = [[FMDatabase alloc] initWithPath:[[NSFileManager defaultManager] dbPath]];
		[_database open];
	}
	
	return self;
}

- (void)dealloc
{
	[_database close];
	[_database release], _database = nil;
    [super dealloc];
}

- (MXXfireUser *)userForUserID:(NSInteger)userID
{
	NSString *dbUsername = nil;
	NSString *dbPasswordHash = nil;
	
	// get user by username
	FMResultSet *resultSet = [_database executeQuery:@"select * from user where id = ?", [NSNumber numberWithInteger:userID]];
	while ([resultSet next])
	{
		dbUsername = [resultSet stringForColumn:@"username"];
		dbPasswordHash = [resultSet stringForColumn:@"passwordHash"];
	}
	[resultSet close];
	
	MXXfireUser *user = nil;
	
	if ([dbUsername length] && [dbPasswordHash length])
	{
		user = [[[MXXfireUser alloc] initWithID:userID] autorelease];
		[user setUsername:dbUsername];
		[user setPasswordHash:dbPasswordHash];
	}
	
	return user;
}

- (MXDevice *)deviceForID:(NSInteger)deviceID
{
	NSString *dbUdid = nil;
	NSString *dbPushToken = nil;
	
	// get device by udid
	FMResultSet *resultSet = [_database executeQuery:@"select * from device where id = ?", [NSNumber numberWithInteger:deviceID]];
	while ([resultSet next])
	{
		dbUdid = [resultSet stringForColumn:@"udid"];
		dbPushToken = [resultSet stringForColumn:@"pushToken"];
	}
	[resultSet close];
	
	MXDevice *device = nil;
	
	if ([dbUdid length] && [dbPushToken length])
	{
		device = [[[MXDevice alloc] initWithID:deviceID] autorelease];
		[device setUdid:dbUdid];
		[device setPushToken:dbPushToken];
	}
	
	return device;
}

- (NSArray *)allUsers
{
	NSMutableArray *users = [NSMutableArray array];
	
	FMResultSet *resultSet = [_database executeQuery:@"select * from user"];
	while ([resultSet next])
	{
		MXXfireUser *user = [[[MXXfireUser alloc] initWithID:[resultSet intForColumn:@"id"]] autorelease];
		[user setUsername:[resultSet stringForColumn:@"username"]];
		[user setPasswordHash:[resultSet stringForColumn:@"passwordHash"]];
		
		[users addObject:user];
	}
	[resultSet close];
	
	for (MXXfireUser *user in users)
	{
		resultSet = [_database executeQuery:@"select * from userDevices where userID = ?", [NSNumber numberWithInteger:[user userID]]];
		while ([resultSet next])
		{
			NSInteger deviceID = [resultSet intForColumn:@"deviceID"];
			FMResultSet *devResultSet = [_database executeQuery:@"select * from device where id = ?", [NSNumber numberWithInteger:deviceID]];
			while ([devResultSet next])
			{
				MXDevice *device = [[[MXDevice alloc] initWithID:deviceID] autorelease];
				[device setUdid:[devResultSet stringForColumn:@"udid"]];
				[device setPushToken:[devResultSet stringForColumn:@"pushToken"]];
				[user addDevice:device];
			}
			[devResultSet close];
		}
		[resultSet close];
	}
	
	return [[users copy] autorelease];
}

- (MXXfireUser *)ensureUserExistsWithParamters:(NSDictionary *)params error:(NSError **)error
{
	NSString *username = [params objectForKey:@"username"];
	NSString *passwordHash = [params objectForKey:@"passwordHash"];
	
	NSNumber *userID = nil;
	NSString *dbUsername = nil;
	NSString *dbPasswordHash = nil;
	
	// get user by username
	FMResultSet *resultSet = [_database executeQuery:@"select * from user where username = ?", username];
	while ([resultSet next])
	{
		dbUsername = [resultSet stringForColumn:@"username"];
		dbPasswordHash = [resultSet stringForColumn:@"passwordHash"];
		userID = [NSNumber numberWithInt:[resultSet intForColumn:@"id"]];
	}
	[resultSet close];
	
	// check if user already exists in db
	if (![dbUsername length])
	{
		// if not, insert new user into db
		if (![_database executeUpdate:@"insert into user (username, passwordHash) values (? ,?)"
							error:error
			 withArgumentsInArray:[NSArray arrayWithObjects:username, passwordHash, nil]
						 orVAList:NULL])
		{
			return nil;
		}
		
		// get the userID for the newly inserted user
		resultSet = [_database executeQuery:@"select * from user where username = ?", username];
		while ([resultSet next])
		{
			userID = [NSNumber numberWithInt:[resultSet intForColumn:@"id"]];
			dbUsername = [resultSet stringForColumn:@"username"];
			dbPasswordHash = [resultSet stringForColumn:@"passwordHash"];
		}
		[resultSet close];
	}
	else
	{
		//user exists so update the info
		if ([dbPasswordHash isEqualToString:passwordHash] == NO)
		{
			if (![_database executeUpdate:@"update user set passwordHash = ? where username = ?"
								error:error
				 withArgumentsInArray:[NSArray arrayWithObjects:passwordHash, username, nil]
							 orVAList:NULL])
			{
				return nil;
			}
			
			dbPasswordHash = passwordHash;
		}
	}
	
	MXXfireUser *user = [[[MXXfireUser alloc] initWithID:[userID integerValue]] autorelease];
	[user setUsername:dbUsername];
	[user setPasswordHash:dbPasswordHash];
	
	return user;
}

- (MXDevice *)ensureDeviceExistsWithParamters:(NSDictionary *)params error:(NSError **)error
{
	NSString *udid = [params objectForKey:@"udid"];
	NSString *pushToken = [params objectForKey:@"pushToken"];
	
	NSNumber *deviceID = nil;
	NSString *dbUdid = nil;
	NSString *dbPushToken = nil;
	
	// get device by udid
	FMResultSet *resultSet = [_database executeQuery:@"select * from device where udid = ?", udid];
	while ([resultSet next])
	{
		dbUdid = [resultSet stringForColumn:@"udid"];
		dbPushToken = [resultSet stringForColumn:@"pushToken"];
		deviceID = [NSNumber numberWithInt:[resultSet intForColumn:@"id"]];
	}
	[resultSet close];
	
	//check if device already exists in db
	if (![dbUdid length])
	{
		// if not, insert it
		if (![_database executeUpdate:@"insert into device (udid, pushToken) values (?, ?)"
							error:error
			 withArgumentsInArray:[NSArray arrayWithObjects:udid, pushToken, nil]
						 orVAList:NULL])
		{
			return nil;
		}
		
		// get the id for the newly inserted device
		resultSet = [_database executeQuery:@"select * from device where udid = ?", udid];
		while ([resultSet next])
		{
			deviceID = [NSNumber numberWithInt:[resultSet intForColumn:@"id"]];
			dbUdid = [resultSet stringForColumn:@"udid"];
			dbPushToken = [resultSet stringForColumn:@"pushToken"];
		}
		[resultSet close];
	}
	else
	{
		// device exists, update info
		if ([dbPushToken isEqualToString:pushToken] == NO)
		{
			if (![_database executeUpdate:@"update device set pushToken = ? where udid = ?"
								error:error
				 withArgumentsInArray:[NSArray arrayWithObjects:pushToken, udid, nil]
							 orVAList:NULL])
			{
				return nil;
			}
			
			dbPushToken = pushToken;
		}
	}
	
	MXDevice *device = [[[MXDevice alloc] initWithID:[deviceID integerValue]] autorelease];
	[device setUdid:dbUdid];
	[device setPushToken:dbPushToken];
	
	return device;
}

- (void)ensureLinkExistsBetweenUser:(MXXfireUser *)user device:(MXDevice *)device error:(NSError **)error
{
	BOOL found = NO;
	FMResultSet *resultSet = [_database executeQuery:@"select * from userDevices where userID = ?", [NSNumber numberWithInteger:[user userID]]];
	while ([resultSet next])
	{
		if (([resultSet intForColumn:@"userID"] == [user userID]) &&
			([resultSet intForColumn:@"deviceID"] == [device deviceID]))
		{
			found = YES;
			break;
		}
	}
	
	if (!found)
	{
		if (![_database executeUpdate:@"insert into userDevices (userID, deviceID) values (? , ?)"
							error:error
			 withArgumentsInArray:[NSArray arrayWithObjects:[NSNumber numberWithInteger:[user userID]], [NSNumber numberWithInteger:[device deviceID]], nil]
						 orVAList:NULL])
		{
			return;
		}
	}
}


@end
