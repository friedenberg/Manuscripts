//
//  AATiledContentView.m
//  Scores
//
//  Created by Sasha Friedenberg on 8/25/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AATiledContentView.h"
#import "AATilingScrollView.h"
#import "AATilingScrollView_Internal_Messaging.h"


NSString * const AAViewTilingStateOnscreen = @"AAViewTilingStateOnscreen";
NSString * const AAViewTilingStateOffscreen = @"AAViewTilingStateOffscreen";


@interface AATiledContentView ()

@property (nonatomic, readwrite, assign) UIScrollView *scrollView;

- (void)hideTile:(id)tile withKey:(id)key;
- (void)showTileWithKey:(id)key;

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
    
    if (![oldScrollView isKindOfClass:[AATilingScrollView class]])
    {
        [oldScrollView removeObserver:self forKeyPath:@"contentOffset"];
    }
    
    if ([scrollView isKindOfClass:[AATilingScrollView class]])
    {
        tilingScrollView = (id)scrollView;
    }
    else
    {
        tilingScrollView = nil;
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionInitial context:kContentOffsetObservingContext];
    }
    
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
        
        self.visibleFrame = CGRectIntersection(newVisibleRect, self.frame);
    }
    else [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@synthesize visibleFrame;

- (void)setVisibleFrame:(CGRect)newVisibleRect
{
    [self willChangeValueForKey:@"visibleFrame"];
    visibleFrame = newVisibleRect;
    [self didChangeValueForKey:@"visibleFrame"];
    
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
            UIView *tile = [visibleTiles objectForKey:key];
            [self hideTile:tile withKey:key];
        }
        //remained
        else if (wasVisible && isVisible)
        {
            UIView *tile = [visibleTiles objectForKey:key];
            tile.frame = [self frameForTileKey:key tile:tile];
        }
        //onscreen
        else if (!wasVisible && isVisible)
        {
            [self showTileWithKey:key];
        }
    };
    
    [tileKeyStates enumerateKeysAndObjectsUsingBlock:^(id key, NSString *state, BOOL *stop) {
        
        BOOL wasVisible = state == AAViewTilingStateOnscreen;
        BOOL isVisible = [self visibilityForTileKey:key];
        
        processView(key, wasVisible, isVisible);
        
        [tileKeyStates setObject:(isVisible ? AAViewTilingStateOnscreen : AAViewTilingStateOffscreen) forKey:key];
    }];
}

- (void)hideTile:(id)tile withKey:(id)key
{
    [spareTiles addObject:tile];
    [tile removeFromSuperview];
    [self tileDidDisappear:tile withKey:key];
    [visibleTiles removeObjectForKey:key];
}

- (void)showTileWithKey:(id)key
{
    UIView *tile = spareTiles.count ? [[spareTiles objectAtIndex:0] retain] : nil;
    
    if (tile)
    {
        [spareTiles removeObjectAtIndex:0];
        [self prepareTileForReuse:tile];
    }
    else
    {
        tile = [self newTile];
    }
    
    tile.frame = [self frameForTileKey:key tile:tile];
    [self tileWillAppear:tile withKey:key];
    [visibleTiles setObject:tile forKey:key];
    [self addSubview:tile];
    
    [tile release];
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
        
        [self hideTile:tile withKey:key];
    }];
    
    [self willChangeValueForKey:@"contentSize"];
    
    [tileKeyStates removeAllObjects];
    
    for (id key in self.tileKeyEnumerator)
    {
        [tileKeyStates setObject:AAViewTilingStateOffscreen forKey:key];
    }
    
    [self didChangeValueForKey:@"contentSize"];
    
    if (self.tilingScrollView)
    {
        [self.tilingScrollView contentViewDidChangeContentSize:self];
    }
    
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

- (CGRect)frameForTileKey:(id)key tile:(id)tile
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
