//
//  AAMetadataQueryResultControllerDelegate.h
//  Scores
//
//  Created by Sasha Friedenberg on 7/22/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


typedef enum
{
    AAMetadataQueryResultsChangeInsert  = NSFetchedResultsChangeInsert,
    AAMetadataQueryResultsChangeDelete  = NSFetchedResultsChangeDelete,
    AAMetadataQueryResultsChangeMove    = NSFetchedResultsChangeMove,
    AAMetadataQueryResultsChangeUpdate  = NSFetchedResultsChangeUpdate
    
} AAMetadataQueryResultsChangeType;

@class AAMetadataQueryController;

@protocol AAMetadataQueryControllerDelegate <NSObject>

@optional;
- (void)controllerWillChangeResults:(AAMetadataQueryController *)controller;
- (void)controller:(AAMetadataQueryController *)controller didChangeObject:(id)anObject atIndex:(NSUInteger)index forChangeType:(AAMetadataQueryResultsChangeType)type newIndex:(NSUInteger)newIndex;
- (void)controllerDidChangeResults:(AAMetadataQueryController *)controller;

@end
