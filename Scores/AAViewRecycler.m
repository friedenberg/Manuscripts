//
//  UIViewReuseManager.m
//  Breaks
//
//  Created by Sasha Friedenberg on 5/22/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AAViewRecycler.h"


@implementation AAViewRecycler

- (id)initWithDelegate:(id <AAViewRecyclerDelegate>)someObject
{
	if (self = [super init])
	{
		self.delegate = someObject;
		
		visibleViews = [NSMutableDictionary new];
		
		cachedViews = [NSMutableArray new];
		
		//cachedReuseIdentifierKeys = [NSMutableDictionary new];
		selectedViews = [NSMutableSet new];
        visibleViewKeys = [NSMutableSet new];
        
        viewsToReload = [NSMutableSet new];
	}
	
	return self;
}

@synthesize delegate, editing;

- (void)setDelegate:(id <AAViewRecyclerDelegate>)value
{
	delegate = value;
	
	delegateMethodFlags.didLoadView = [delegate respondsToSelector:@selector(viewRecycler:didLoadView:withKey:)];
	delegateMethodFlags.prepareViewForRecycling = [delegate respondsToSelector:@selector(viewRecycler:prepareViewForRecycling:)];
	delegateMethodFlags.visibleKeys = [delegate respondsToSelector:@selector(visibleKeysForViewRecycler:)];
	delegateMethodFlags.didSelect = [delegate respondsToSelector:@selector(viewRecycler:selectViewWithKey:selected:)];
}

- (void)setEditing:(BOOL)value
{
	[self setEditing:value animated:NO];
}

- (void)setEditing:(BOOL)value animated:(BOOL)animated
{
	editing = value;
	for (id view in [visibleViews allValues]) [view setEditing:editing animated:animated];
	[self clearSelection];
}

- (void)processViews
{
    NSSet *newVisibleViews = [delegate visibleKeysForViewRecycler:self];
    NSSet *oldVisibleViews = [visibleViewKeys copy];
    
    for (id key in oldVisibleViews)
        [self processViewForKey:key];
    
    for (id key in newVisibleViews)
        [self processViewForKey:key];
        
    [visibleViewKeys setSet:newVisibleViews];
    [oldVisibleViews release];
}

- (void)processViewForKey:(id)key
{
	UIView *view = [self visibleViewForKey:key];
	BOOL isVisible = [self.delegate visibilityForKey:key viewRecycler:self];
	BOOL wasVisible = view != nil;
	
	if (isVisible)
	{
		if (!view)
        {
            view = [self cachedView];
			if (delegateMethodFlags.prepareViewForRecycling)
            	[delegate viewRecycler:self prepareViewForRecycling:view];
        }
        
		if (!view)
        {
            view = [self.delegate unusedViewForViewRecycler:self];
            if (delegateMethodFlags.prepareViewForRecycling)
            	[delegate viewRecycler:self prepareViewForRecycling:view];
        }
		
		if ([viewsToReload containsObject:key] || !wasVisible) [self setView:view forKey:key];
		else view.frame = [self.delegate rectForViewWithKey:key view:view viewRecycler:self];
	}
	else if (wasVisible) [self cacheView:view forKey:key];
}

- (NSArray *)visibleViews
{
	return [visibleViews allValues];
}

- (id)visibleViewForKey:(id)key
{
	return [visibleViews objectForKey:key];
}

- (id)cachedView
{
	return [cachedViews lastObject];
}

- (void)setView:(UIView *)view forKey:(id)key
{
	//if ([view conformsToProtocol:@protocol(AAViewEditing)]) view.editing = self.editing;
	//if ([view conformsToProtocol:@protocol(AAViewSelecting)]) view.selected = [selectedViews containsObject:key];
	view.frame = [self.delegate rectForViewWithKey:key view:view viewRecycler:self];
	if (delegateMethodFlags.didLoadView)
		[self.delegate viewRecycler:self didLoadView:view withKey:key];
	
	[[self.delegate superviewForViewWithKey:key viewRecycler:self] addSubview:view];
	[visibleViews setObject:view forKey:key];
	[cachedViews removeObject:view];
    
    if (!isMutating)
        [viewsToReload removeObject:key];
}

- (void)cacheView:(UIView *)view forKey:(id)key
{
	[cachedViews addObject:view];
	[visibleViews removeObjectForKey:key];
	[view removeFromSuperview];
}

- (void)cacheAllViews
{
	[cachedViews addObjectsFromArray:[visibleViews allValues]];
	[visibleViews removeAllObjects];
	[viewsToReload removeAllObjects];
}

- (void)removeAllCachedViews
{
	[cachedViews removeAllObjects];
}

- (void)removeAllViews
{
	[visibleViews removeAllObjects];
	[cachedViews removeAllObjects];
	[viewsToReload removeAllObjects];
}

#pragma - mark selection

- (BOOL)viewForKeyIsSelected:(id)key
{
	return [selectedViews containsObject:key];
}

- (void)toggleSelectionForKey:(id)key
{
	if (!key) return;
	BOOL isSelected = [selectedViews containsObject:key];
	
	if (isSelected) [selectedViews removeObject:key];
	else [selectedViews addObject:key];
	
	if (delegateMethodFlags.didSelect)
		[self.delegate viewRecycler:self selectViewWithKey:key selected:!isSelected];
}

- (void)clearSelection
{
	NSArray *deselectedViews = [selectedViews allObjects];
	[selectedViews removeAllObjects];
	
	[[visibleViews objectsForKeys:deselectedViews notFoundMarker:[NSNull null]] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		if (obj != [NSNull null])
		{
			UIView <AAViewRecycling> *view = obj;
			id key = [deselectedViews objectAtIndex:idx];
			
			if (delegateMethodFlags.didLoadView)
				[self.delegate viewRecycler:self didLoadView:view withKey:key];
		}
	}];
}

@synthesize keyForCurrentlyTouchedView;

- (id)currentlyTouchedView
{
	return [self visibleViewForKey:self.keyForCurrentlyTouchedView];
}

- (void)refreshSelectionForCurrentlyTouchedView
{
	BOOL isSelected = [selectedViews containsObject:keyForCurrentlyTouchedView];
	
	if (delegateMethodFlags.didSelect)
		[delegate viewRecycler:self selectViewWithKey:keyForCurrentlyTouchedView selected:isSelected];
}

- (void)toggleSelectionForCurrentlyTouchedView
{
	[self toggleSelectionForKey:self.keyForCurrentlyTouchedView];
}

#pragma mark - mutation

- (void)beginMutation
{
    isMutating = YES;
    [viewsToReload removeAllObjects];
}

- (void)reloadViewWithKey:(id)key
{
    [viewsToReload addObject:key];
}

- (void)endMutation
{
    NSArray *reloadingKeys = [viewsToReload allObjects];
    NSArray *reloadingViews = [visibleViews objectsForKeys:reloadingKeys notFoundMarker:[NSNull null]];
    
    [reloadingKeys enumerateObjectsUsingBlock:^(id key, NSUInteger index, BOOL *stop) {
        
        id view = [reloadingViews objectAtIndex:index];
        if (view != [NSNull null]) [self setView:view forKey:key];
    }];
    
    [viewsToReload removeAllObjects];
    isMutating = NO;
}

- (void)reloadVisibleViews
{
    [self beginMutation];
    [viewsToReload addObjectsFromArray:[visibleViews allKeys]];
    [self endMutation];
}

- (void)dealloc
{
    [viewsToReload release];
    [visibleViewKeys release];
	[visibleViews release];
	[cachedViews release];
	[selectedViews release];
	[super dealloc];
}

@end
