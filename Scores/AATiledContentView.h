//
//  AATiledContentView.h
//  Scores
//
//  Created by Sasha Friedenberg on 8/25/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AATiledContentView : UIView
{
    CGRect visibleRect;
}

@property (nonatomic) CGRect visibleRect;

- (UIView *)newTile;
- (BOOL)visibilityForTileWithKey:(id)key;
- (CGRect)rectForTileWithKey:(id)key;
- (void)didLoadTileWithKey:(id)key;

@end
