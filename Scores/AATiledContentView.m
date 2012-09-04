//
//  AATiledContentView.m
//  Scores
//
//  Created by Sasha Friedenberg on 8/25/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AATiledContentView.h"
#import "AAViewRecycler.h"


NSString * const AAViewTilingVisibleKey = @"AAViewTilingVisibleKey";
NSString * const AAViewTilingNotVisibleKey = @"AAViewTilingNotVisibleKey";


@interface AATiledContentView ()

@property (nonatomic, readwrite, assign) UIScrollView *scrollView;

@end


@implementation AATiledContentView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        spareTiles = [NSMutableArray new];
        
        visibleTileKeys = [NSMutableSet new];
        
        visibleTiles = [NSMutableDictionary new];
        selectedTileKeys = [NSMutableSet new];
        
        tileStates = [NSMutableDictionary new];
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
        
        //removed
        if (wasVisible && !isVisible)
        {
            UIView *view = [visibleTiles objectForKey:key];
            [spareTiles addObject:view];
            [visibleTiles removeObjectForKey:key];
            [view removeFromSuperview];
            [self tileDidDisappear:view withKey:key];
        }
        //remained
        else if (wasVisible && isVisible)
        {
            UIView *view = [visibleTiles objectForKey:key];
            view.frame = [self frameForTileKey:key];
        }
        //added
        else if (!wasVisible && isVisible)
        {
            UIView *view = spareTiles.count ? [spareTiles objectAtIndex:0] : nil;
            
            if (view)
            {
                [spareTiles removeObjectAtIndex:0];
            }
            else
            {
                view = [self tile];
            }
            
            view.frame = [self frameForTileKey:key];
            [self tileWillAppear:view withKey:key];
            [self addSubview:view];
        }
    };
    
    [tileKeyStates enumerateKeysAndObjectsUsingBlock:^(id key, NSString *state, BOOL *stop) {
        
        BOOL wasVisible = state == AAViewTilingVisibleKey;
        BOOL isVisible = [self visibilityForTileKey:key];
        
        processView(key, wasVisible, isVisible);
        
        [tileKeyStates setObject:(isVisible ? AAViewTilingVisibleKey : AAViewTilingNotVisibleKey) forKey:key];
    }];
    
//    NSDictionary *previousStates = [tileKeyStates copy];
//    
//    NSUIntegerEnumerate(self.tileCount, ^(NSUInteger index) {
//        
//        id key = [self tileKeyAtIndex:index];
//        
//        BOOL wasVisible = [previousStates objectForKey:key] == AAViewTilingVisibleKey;
//        BOOL isVisible = [self visibilityForTileKey:key];
//        
//        [tileKeyStates setObject:isVisible ? AAViewTilingVisibleKey : AAViewTilingNotVisibleKey forKey:key];
//        
//        processView(key, wasVisible, isVisible);
//    });
//    
//    [previousStates release];
}

#pragma mark - tile population

- (NSUInteger)tileCount
{
    return 0;
}

- (id)tileKeyAtIndex:(NSUInteger)index
{
    return nil;
}

#pragma mark - tiling

- (void)reloadTiles
{
    [tileKeyStates removeAllObjects];
    
    NSUIntegerEnumerate(self.tileCount, ^(NSUInteger index) {
        
        [tileKeyStates setObject:AAViewTilingNotVisibleKey forKey:[self tileKeyAtIndex:index]];
    });
    
    [self setNeedsLayout];
}

- (id)tile
{
    UIView *tile = [UIView new];
    return [tile autorelease];
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

- (void)prepareTileForReuse:(id)tile withKey:(id)key
{
    
}

- (void)tileWillAppear:(id)tile withKey:(id)key
{
    
}

- (void)tileDidDisappear:(id)tile withKey:(id <NSCopying>)key
{
    
}

- (void)dealloc
{
    [tileKeyStates release];
    [tileStates release];
    [spareTiles release];
    [visibleTileKeys release];
    [visibleTiles release];
    [selectedTileKeys release];
    
    [super dealloc];
}

@end
