//
//  AATiledContentView.m
//  Scores
//
//  Created by Sasha Friedenberg on 8/25/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AATiledContentView.h"


@interface AATiledContentView ()

@property (nonatomic, readwrite, assign) UIScrollView *scrollView;

@end

@implementation AATiledContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSSet *oldVisibleTileKeys = [[visibleTileKeys copy] autorelease];
    NSSet *newVisibleTileKeys = [self visibleTileKeysForRect:self.visibleRect];
    NSMutableSet *removedTileKeys = [NSMutableSet setWithSet:oldVisibleTileKeys];
    NSMutableSet *addedTileKeys = [NSMutableSet setWithSet:newVisibleTileKeys];
    
    for (id key in oldVisibleTileKeys)
    {
        [removedTileKeys removeObject:[newVisibleTileKeys member:key]];
    }
    
    for (id key in newVisibleTileKeys)
    {
        [addedTileKeys removeObject:[oldVisibleTileKeys member:key]];
    }
    
    //tiling
    
    for (id key in removedTileKeys)
    {
        UIView *view = [visibleTiles objectForKey:key];
        [spareTiles addObject:view];
        [visibleTiles removeObjectForKey:key];
        [view removeFromSuperview];
        [self tileDidDisappear:view withKey:key];
    }
    
    [visibleTileKeys setSet:newVisibleTileKeys];
    
    for (id key in visibleTileKeys)
    {
        UIView *view = [visibleTiles objectForKey:key];
        view.frame = [self frameForTileKey:key];
    }
    
    for (id key in addedTileKeys)
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
}

#pragma mark - tiling

- (NSSet *)visibleTileKeysForRect:(CGRect)rect
{
    return [NSSet set];
}

- (id)tile
{
    UIView *tile = [UIView new];
    return [tile autorelease];
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

@end
