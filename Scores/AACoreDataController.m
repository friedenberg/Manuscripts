//
//  AACoreDataController.m
//  Breaks
//
//  Created by Sasha Friedenberg on 4/7/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AACoreDataController.h"


NSString *DocumentsDirectory() { return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]; };

@implementation AACoreDataController

- (id)init
{
	if (self = [super init])
	{
		
	}
	
	return self;
}

- (void)applicationWillTerminate:(UIApplication *)application 
{
    [self saveContext];
}

- (void)saveContext 
{
    NSError *error = nil;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}    

- (void)deleteAllData
{
	NSArray *stores = [self.persistentStoreCoordinator persistentStores];
	
	for(NSPersistentStore *store in stores) 
	{
		[persistentStoreCoordinator removePersistentStore:store error:nil];
		[[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
	}
	
	[persistentStoreCoordinator release], persistentStoreCoordinator = nil;
}

#pragma mark -
#pragma mark Core Data stack

- (NSManagedObjectContext *)managedObjectContext 
{
    
    if (managedObjectContext) return managedObjectContext;
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	
    if (coordinator != nil) 
	{
        managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
		[managedObjectContext setMergePolicy:NSRollbackMergePolicy];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
		[managedObjectContext setRetainsRegisteredObjects:YES];
    }
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel 
{
    
    if (managedObjectModel) return managedObjectModel;
    
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"Scores" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{
    
    if (persistentStoreCoordinator) return persistentStoreCoordinator;
    
    NSURL *storeURL = [NSURL fileURLWithPath:[DocumentsDirectory() stringByAppendingPathComponent:@"Scores.sqlite"]];
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
		[[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
		
		persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
		
		if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
		{
			abort();
		}
		
    }    
    
    return persistentStoreCoordinator;
}

- (void)dealloc 
{
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];

    [super dealloc];
}

@end

