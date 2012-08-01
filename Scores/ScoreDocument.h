//
//  ScoreDocument.h
//  Scores
//
//  Created by Sasha Friedenberg on 8/1/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MarkedObject;

@interface ScoreDocument : NSManagedObject

@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * title;
@property (nonatomic) NSTimeInterval dateLastOpened;
@property (nonatomic, retain) NSString * year;
@property (nonatomic, retain) NSString * composer;
@property (nonatomic, retain) NSSet *markedObjects;
@end

@interface ScoreDocument (CoreDataGeneratedAccessors)

- (void)addMarkedObjectsObject:(MarkedObject *)value;
- (void)removeMarkedObjectsObject:(MarkedObject *)value;
- (void)addMarkedObjects:(NSSet *)values;
- (void)removeMarkedObjects:(NSSet *)values;

@end
