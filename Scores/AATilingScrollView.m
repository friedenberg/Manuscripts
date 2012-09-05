//
//  AATilingScrollView.m
//  Scores
//
//  Created by Sasha Friedenberg on 8/25/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AATilingScrollView.h"

#import "AATiledContentView.h"

@implementation AATilingScrollView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        contentViews = [NSMutableArray new];
    }
    
    return self;
}

static NSString * const kContentViewContentSizeObservingContext = @"kContentViewContentSizeObservingContext";

- (void)addContentView:(AATiledContentView *)someContentView
{
    [self addSubview:someContentView];
    [contentViews addObject:someContentView];
    [someContentView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionInitial context:kContentViewContentSizeObservingContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kContentViewContentSizeObservingContext)
    {
        [self setNeedsLayout];
    }
    else [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@synthesize visibleBounds;

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    [self willChangeValueForKey:@"visibleBounds"];
    
    visibleBounds = bounds;
    visibleBounds.origin = self.contentOffset;
    
    CGFloat scale = (CGFloat)1 / self.zoomScale;
    
    if (scale < 1)
    {
        visibleBounds.origin.x *= scale;
        visibleBounds.origin.y *= scale;
        visibleBounds.size.width *= scale;
        visibleBounds.size.height *= scale;
    }
    
    [self didChangeValueForKey:@"visibleBounds"];
    
    CGRect contentRect = CGRectZero;
    
    for (AATiledContentView *contentView in contentViews)
    {
        [contentView sizeToFit];
        CGRect frame = contentView.frame;
        
        contentRect = CGRectUnion(contentRect, frame);
    }
    
    self.contentSize = contentRect.size;
}

- (void)dealloc
{
    [contentViews release];
    [super dealloc];
}

@end
