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


@interface AAViewRecycler : NSObject <AAViewEditing>
{
	id <AAViewRecyclerDelegate> __weak delegate;
	
	NSMutableDictionary *visibleViews;
	NSMutableArray *cachedViews;
	
    NSMutableSet *visibleViewKeys;
    
	//NSMutableDictionary *cachedReuseIdentifierKeys;
	
	//selection
	id keyForCurrentlyTouchedView;
	NSMutableSet *selectedViews;
	
	//mutation
    BOOL isMutating;
	NSMutableSet *viewsToReload;
	
	struct
	{
		unsigned int didLoadView:1;
		unsigned int prepareViewForRecycling:1;
		unsigned int visibleKeys:1;
		unsigned int didSelect:1;
		
	} delegateMethodFlags;
}

- (id)initWithDelegate:(id <AAViewRecyclerDelegate>)someObject;

@property (nonatomic, weak) id <AAViewRecyclerDelegate> delegate;
@property (weak, nonatomic, readonly) NSArray *visibleViews;

//recycling
- (void)processViews;
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
@property (nonatomic, strong) id keyForCurrentlyTouchedView;
- (id)currentlyTouchedView;

//mutation
- (void)beginMutation;
- (void)reloadViewWithKey:(id)key;
- (void)endMutation;

- (void)reloadVisibleViews;

@end
