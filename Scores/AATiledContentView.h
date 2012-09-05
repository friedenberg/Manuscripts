//
//  AATiledContentView.h
//  Scores
//
//  Created by Sasha Friedenberg on 8/25/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


extern NSString * const AAViewTilingOnscreenKey;
extern NSString * const AAViewTilingOffscreenKey;

@interface AATiledContentView : UIView
{
@private;
    UIScrollView *scrollView;
    CGRect previouslyVisibleRect;
    CGRect visibleRect;
    
    NSMutableSet *tileKeys;
    
    NSMutableArray *spareTiles;
    
    NSMutableDictionary *tileKeyStates;
    NSMutableDictionary *visibleTiles;
}

@property (nonatomic, readonly, assign) UIScrollView *scrollView;
@property (nonatomic, readonly) CGSize contentSize;
@property (nonatomic) CGRect visibleRect;

@property (nonatomic, readonly) NSEnumerator *tileKeyEnumerator;

//tile mutation
- (void)beginMutatingTiles;
- (void)endMutatingTiles;

- (void)reloadTiles;

//tiling
- (id)newTile;
- (id)tileForKey:(id)key;

- (BOOL)visibilityForTileKey:(id)key;
- (CGRect)frameForTileKey:(id)key;
- (void)prepareTileForReuse:(id)tile;

- (void)tileWillAppear:(id)tile withKey:(id)key;
- (void)tileDidDisappear:(id)tile withKey:(id)key;

@end
