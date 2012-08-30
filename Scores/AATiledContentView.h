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
    UIScrollView *scrollView;
    CGRect previouslyVisibleRect;
    CGRect visibleRect;
    
    NSMutableArray *spareTiles;
    
    NSMutableSet *visibleTileKeys;
    NSMutableDictionary *visibleTiles;
    NSMutableSet *selectedTileKeys;
}

@property (nonatomic, readonly, assign) UIScrollView *scrollView;
@property (nonatomic) CGRect visibleRect;

//tiling

- (NSSet *)visibleTileKeysForRect:(CGRect)rect;

- (id)tile;
- (BOOL)visibilityForTileKey:(id <NSCopying>)key;
- (CGRect)frameForTileKey:(id <NSCopying>)key;
- (void)prepareTileForReuse:(id)tile withKey:(id <NSCopying>)key;

- (void)tileWillAppear:(id)tile withKey:(id <NSCopying>)key;
- (void)tileDidDisappear:(id)tile withKey:(id <NSCopying>)key;

@end
