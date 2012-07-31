//
//  UIViewReuseManager.h
//  Breaks
//
//  Created by Sasha Friedenberg on 5/22/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AAViewRecyclerDelegate.h"

#define BETWEEN(lower, value, upper) MAX(lower, MIN(upper, value))

typedef void (^NSUIntegerEnumerationBlock)(NSUInteger index);

extern void NSUIntegerEnumerate(NSUInteger count, NSUIntegerEnumerationBlock enumerationBlock);

extern NSRange NSRangeFromValues(NSUInteger a, NSUInteger b);
extern void NSRangeEnumerate(NSRange range, NSUIntegerEnumerationBlock enumerationBlock);
extern void NSRangeEnumerateUnion(NSRange range1, NSRange range2, NSUIntegerEnumerationBlock enumerationBlock);


@interface AAViewRecycler : NSObject <AAViewEditing>
{
	id <AAViewRecyclerDelegate> delegate;
	
	NSUInteger *visibleViewIndexes;
	NSMutableDictionary *visibleViews;
	NSMutableArray *cachedViews;
	
	//NSMutableDictionary *cachedReuseIdentifierKeys;
	
	//selection
	id keyForCurrentlyTouchedView;
	NSMutableSet *selectedViews;
	
	//mutation
	NSMutableSet *viewsToReload;
}

- (id)initWithDelegate:(id <AAViewRecyclerDelegate>)someObject;

@property (nonatomic, assign) id <AAViewRecyclerDelegate> delegate;
@property (nonatomic, readonly) NSArray *visibleViews;

//recycling
- (void)processViewForKey:(id)key;

- (id)visibleViewForKey:(id)key;
- (id)cachedView;

- (void)setView:(UIView *)view forKey:(id)key;
- (void)cacheView:(UIView *)view forKey:(id)key;

- (void)cacheAllViews;
- (void)removeAllCachedViews;
- (void)removeAllViews;

//selection
- (BOOL)viewForKeyIsSelected:(id)key;
- (void)toggleSelectionForKey:(id)key;
- (void)clearSelection;
- (void)toggleSelectionForCurrentlyTouchedView;
- (void)refreshSelectionForCurrentlyTouchedView;
@property (nonatomic, retain) id keyForCurrentlyTouchedView;
- (id)currentlyTouchedView;

//mutation
- (void)addKeyToReload:(id)key;

@end
