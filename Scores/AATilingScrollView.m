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

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])\
    {
        // Initialization code
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect contentRect = CGRectZero;
    
    for (AATiledContentView *contentView in contentViews)
    {
        [contentView sizeToFit];
        CGRect frame = contentView.frame;
        
        contentRect = CGRectUnion(contentRect, frame);
    }
    
    self.contentSize = contentRect.size;
}

@end
