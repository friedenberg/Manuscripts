//
//  ScoreDocument.h
//  Scores
//
//  Created by Sasha Friedenberg on 8/28/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Page;

@interface ScoreDocument : NSManagedObject

@property (nonatomic, strong) NSString * composer;
@property (nonatomic, strong) NSDate *dateLastOpened;
@property (nonatomic, strong) NSString * path;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * year;
@property (nonatomic, strong) NSData * coverImage;
@property (nonatomic, strong) NSOrderedSet *pages;
@end

@interface ScoreDocument (CoreDataGeneratedAccessors)

- (void)insertObject:(Page *)value inPagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPagesAtIndex:(NSUInteger)idx;
- (void)insertPages:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPagesAtIndex:(NSUInteger)idx withObject:(Page *)value;
- (void)replacePagesAtIndexes:(NSIndexSet *)indexes withPages:(NSArray *)values;
- (void)addPagesObject:(Page *)value;
- (void)removePagesObject:(Page *)value;
- (void)addPages:(NSOrderedSet *)values;
- (void)removePages:(NSOrderedSet *)values;

@end
