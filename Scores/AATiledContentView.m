//
//  AATiledContentView.m
//  Scores
//
//  Created by Sasha Friedenberg on 8/25/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AATiledContentView.h"
#import "AAViewRecycler.h"


NSString * const AAViewTilingOnscreenKey = @"AAViewTilingOnscreenKey";
NSString * const AAViewTilingOffscreenKey = @"AAViewTilingOffscreenKey";


@interface AATiledContentView ()

@property (nonatomic, readwrite, assign) UIScrollView *scrollView;

@end


@implementation AATiledContentView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        spareTiles = [NSMutableArray new];
        
        visibleTiles = [NSMutableDictionary new];
        tileKeyStates = [NSMutableDictionary new];
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if ([newSuperview isKindOfClass:[UIScrollView class]])
    {
        self.scrollView = (id)newSuperview;
    }
    else
    {
        self.scrollView = nil;
    }
}

@synthesize scrollView;

static NSString * const kContentOffsetObservingContext = @"kContentOffsetObservingContext";

- (void)setScrollView:(UIScrollView *)value
{
    UIScrollView *oldScrollView = scrollView;
    scrollView = value;
    
    [oldScrollView removeObserver:self forKeyPath:@"contentOffset"];
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionInitial context:kContentOffsetObservingContext];
    
    [self reloadTiles];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kContentOffsetObservingContext)
    {
        CGRect newVisibleRect = CGRectZero;
        newVisibleRect.size = scrollView.bounds.size;
        newVisibleRect.origin = scrollView.contentOffset;
        
        CGFloat scale = (CGFloat)1 / scrollView.zoomScale;
        
        if (scale <= 1)
        {
            newVisibleRect.origin.x *= scale;
            newVisibleRect.origin.y *= scale;
            newVisibleRect.size.width *= scale;
            newVisibleRect.size.height *= scale;
        }
        
        self.visibleRect = CGRectIntersection(newVisibleRect, self.frame);
    }
    else [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@synthesize visibleRect;

- (void)setVisibleRect:(CGRect)newVisibleRect
{
    [self willChangeValueForKey:@"visibleRect"];
    visibleRect = newVisibleRect;
    [self didChangeValueForKey:@"visibleRect"];
    
    [self setNeedsLayout];
}

- (CGSize)contentSize
{
    return CGSizeZero;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return self.contentSize;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    void (^processView)(id key, BOOL wasVisible, BOOL isVisible) = ^(id key, BOOL wasVisible, BOOL isVisible) {
        
        //offscreen
        if (wasVisible && !isVisible)
        {
            UIView *view = [visibleTiles objectForKey:key];
            [spareTiles addObject:view];
            [view removeFromSuperview];
            [self tileDidDisappear:view withKey:key];
            [visibleTiles removeObjectForKey:key];
        }
        //remained
        else if (wasVisible && isVisible)
        {
            UIView *view = [visibleTiles objectForKey:key];
            view.frame = [self frameForTileKey:key];
        }
        //onscreen
        else if (!wasVisible && isVisible)
        {
            UIView *view = spareTiles.count ? [[spareTiles objectAtIndex:0] retain] : nil;
            
            if (view)
            {
                [spareTiles removeObjectAtIndex:0];
                [self prepareTileForReuse:view];
            }
            else
            {
                view = [self newTile];
            }
            
            view.frame = [self frameForTileKey:key];
            [self tileWillAppear:view withKey:key];
            [visibleTiles setObject:view forKey:key];
            [self addSubview:view];
            
            [view release];
        }
    };
    
    [tileKeyStates enumerateKeysAndObjectsUsingBlock:^(id key, NSString *state, BOOL *stop) {
        
        BOOL wasVisible = state == AAViewTilingOnscreenKey;
        BOOL isVisible = [self visibilityForTileKey:key];
        
        processView(key, wasVisible, isVisible);
        
        [tileKeyStates setObject:(isVisible ? AAViewTilingOnscreenKey : AAViewTilingOffscreenKey) forKey:key];
    }];
}

#pragma mark - tile population

- (NSEnumerator *)tileKeyEnumerator
{
    return nil;
}

- (void)beginMutatingTiles
{
    
}

- (void)endMutatingTiles
{
    
    [self setNeedsLayout];
}

- (void)addTileAtIndex:(NSUInteger)index
{
    
}

- (void)reloadTileAtIndex:(NSUInteger)index
{
    
}

- (void)moveTileAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    
}

- (void)removeTileAtIndex:(NSUInteger)index
{
    
}

#pragma mark - tiling

- (void)reloadTiles
{
    [visibleTiles enumerateKeysAndObjectsUsingBlock:^(id key, UIView *tile, BOOL *stop) {
        
        [spareTiles addObject:tile];
        [visibleTiles removeObjectForKey:key];
        [tile removeFromSuperview];
    }];
    
    [self willChangeValueForKey:@"contentSize"];
    
    [tileKeyStates removeAllObjects];
    
    for (id key in self.tileKeyEnumerator)
    {
        [tileKeyStates setObject:AAViewTilingOffscreenKey forKey:key];
    }
    
    [self didChangeValueForKey:@"contentSize"];
    
    [self setNeedsLayout];
}

- (id)newTile
{
    return [UIView new];
}

- (id)tileForKey:(id)key
{
    return [visibleTiles objectForKey:key];
}

- (BOOL)visibilityForTileKey:(id)key
{
    return NO;
}

- (CGRect)frameForTileKey:(id)key
{
    return CGRectZero;
}

- (void)prepareTileForReuse:(id)tile
{
    
}

- (void)tileWillAppear:(id)tile withKey:(id)key
{
    
}

- (void)tileDidDisappear:(id)tile withKey:(id)key
{
    
}

- (void)dealloc
{
    [tileKeyStates release];
    [spareTiles release];
    [visibleTiles release];
    
    [super dealloc];
}

@end
