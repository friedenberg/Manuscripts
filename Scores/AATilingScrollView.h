//
//  AATilingScrollView.h
//  Scores
//
//  Created by Sasha Friedenberg on 8/25/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AATiledContentView;

@interface AATilingScrollView : UIScrollView
{
@private;
    CGRect visibleBounds;
    NSMutableArray *contentViews;
}

@property (nonatomic, readonly) CGRect visibleBounds;

- (void)addContentView:(AATiledContentView *)someContentView;

@end
