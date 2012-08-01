//
//  AACoreDataController.h
//  Breaks
//
//  Created by Sasha Friedenberg on 4/7/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <CoreData/CoreData.h>


extern NSString *DocumentsDirectory();

@interface AACoreDataController : NSObject
{
    NSManagedObjectContext *managedObjectContext;
    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;

@end