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
    NSMutableArray *contentViews;
}

- (void)addContentView:(AATiledContentView *)someContentView;

@end
