//
//  MXDataManager.m
//  MultiXfire
//
//  Created by James Addyman on 30/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MXDataManager.h"
#import "NSFileManager+DirectoryLocations.h"
#import "MXManagedUser.h"
#import "MXManagedDevice.h"

@interface MXDataManager ()

- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

@end

@implementation MXDataManager

static MXDataManager *_sharedInstance;

+ (MXDataManager *)sharedInstance
{
	static dispatch_once_t predicate;
	dispatch_once(&predicate, ^{
		_sharedInstance = [[self alloc] init]; 
	});
	return _sharedInstance;
}

- (id)init
{
	if ((self = [super init]))
	{
		[self managedObjectModel];
		[self persistentStoreCoordinator];
		[self managedObjectContext];
	}
	
	return self;
}

- (void)dealloc
{
	[_managedObjectModel release];
	[_managedObjectContext release];
	[_persistentStoreCoordinator release];
	[super dealloc];
}

- (NSManagedObjectModel *)managedObjectModel
{
	if (!_managedObjectModel)
	{
		_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Users" withExtension:@"momd"]];
	}
	
	return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if (!_persistentStoreCoordinator)
	{
		NSError *error = nil;
		
		_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
		[_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
												  configuration:nil
															URL:[NSURL fileURLWithPath:[[[NSFileManager defaultManager] applicationSupportDirectory] stringByAppendingPathComponent:@"Users.storedata"]]
														options:nil
														  error:&error];
		if (error)
		{
			NSLog(@"Error adding persistent store to persistent store coordinator: %@", [error localizedDescription]);
			[_persistentStoreCoordinator release], _persistentStoreCoordinator = nil;
			return nil;
		}
	}
	
	return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
	if (!_managedObjectContext)
	{
		_managedObjectContext = [[NSManagedObjectContext alloc] init];
		[_managedObjectContext setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
	}
	
	return _managedObjectContext;
}

- (void)save
{
	NSError *error = nil;
	[[self managedObjectContext] save:&error];
	
	if (error)
	{
		NSLog(@"Error saving context: %@", [error localizedDescription]);
	}
}

#pragma mark - Users

- (NSArray *)allUsers
{
	NSError *error = nil;
	
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([MXManagedUser class])];
	NSArray *users = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
	if (error)
	{
		NSLog(@"Error getting users: %@", [error localizedDescription]);
		return nil;
	}
	
	return users;
}

- (MXManagedUser *)userForUsername:(NSString *)username
{
	NSError *error = nil;
	
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([MXManagedUser class])];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"username LIKE %@", username]];
	NSArray *users = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
	if (error)
	{
		NSLog(@"Error getting user: %@", [error localizedDescription]);
		return nil;
	}
	
	MXManagedUser *user = nil;
	if ([users count])
	{
		user = [users objectAtIndex:0];
	}
	
	return user;
}

- (MXManagedUser *)registerUserWithParameters:(NSDictionary *)parameters
{
	MXManagedUser *user = [self userForUsername:[parameters objectForKey:@"username"]];
	
	if (!user)
	{
		user = (MXManagedUser *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([MXManagedUser class])
															  inManagedObjectContext:[self managedObjectContext]];
		[self save];
	}
	
	[user setUsername:[parameters objectForKey:@"username"]];
	[user setPasswordHash:[parameters objectForKey:@"passwordHash"]];
	
	MXManagedDevice *device = [self deviceForPushToken:[[parameters objectForKey:@"device"] objectForKey:@"pushToken"]];
	if (!device)
	{
		device = (MXManagedDevice *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([MXManagedDevice class])
																  inManagedObjectContext:[self managedObjectContext]];
		[self save];
	}
	
	[device setPushToken:[[parameters objectForKey:@"device"] objectForKey:@"pushToken"]];
	
	[user addDevicesObject:device];
	
	return user;
}

- (void)unregisterUser:(MXManagedUser *)user
{
	[[NSNotificationCenter defaultCenter] postNotificationName:unregistrationNotification
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:user forKey:@"user"]];
	
	[[self managedObjectContext] deleteObject:user];
	[self save];
}

#pragma mark - Devices

- (MXManagedDevice *)deviceForPushToken:(NSString *)pushToken
{
	NSError *error = nil;
	
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([MXManagedDevice class])];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"pushToken LIKE %@", pushToken]];
	NSArray *devices = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
	if (error)
	{
		NSLog(@"Error getting device: %@", [error localizedDescription]);
		return nil;
	}
	
	MXManagedDevice *device = nil;
	if ([devices count])
	{
		device = [devices objectAtIndex:0];
	}
	
	return device;
}

- (void)unregisterDevice:(MXManagedDevice *)device forUser:(MXManagedUser *)user
{
	[user removeDevicesObject:device];
	if ([[device users] count] == 0)
	{
		[[self managedObjectContext] deleteObject:device];
	}

	[self save];
	
	if ([[user devices] count] == 0)
	{
		[self unregisterUser:user];
	}
}

@end
