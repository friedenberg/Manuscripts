//
//  AATilingScrollView.m
//  Scores
//
//  Created by Sasha Friedenberg on 8/25/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AATilingScrollView.h"

@implementation AATilingScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)addContentView:(AATiledContentView *)someContentView
{
    //[self addSubview:someContentView];
    [contentViews addObject:someContentView];
}

@end
