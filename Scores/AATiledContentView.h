//
//  AATiledContentView.h
//  Scores
//
//  Created by Sasha Friedenberg on 8/25/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


extern NSString * const AAViewTilingStateOnscreen;
extern NSString * const AAViewTilingStateOffscreen;


@class AATilingScrollView;

@interface AATiledContentView : UIView
{
@private;
    UIScrollView *scrollView;
    AATilingScrollView *tilingScrollView;
    CGRect visibleFrame;
    
    NSMutableArray *spareTiles;
    
    NSMutableDictionary *tileKeyStates;
    NSMutableDictionary *visibleTiles;
    
    NSMutableDictionary *mutatedTileKeys;
}

@property (nonatomic, readonly, assign) UIScrollView *scrollView;
@property (nonatomic, readonly) AATilingScrollView *tilingScrollView;
@property (nonatomic, readonly) CGSize contentSize;
@property (nonatomic) CGRect visibleFrame;

@property (nonatomic, readonly) NSEnumerator *tileKeyEnumerator;

//tile mutation
- (void)beginMutatingTiles;
- (void)addTileKey:(id)key;
- (void)reloadTileKey:(id)key;
- (void)removeTileKey:(id)key;
- (void)endMutatingTiles;

- (void)reloadTiles;

//tiling
- (id)newTile;
- (id)tileForKey:(id)key;

- (BOOL)visibilityForTileKey:(id)key;
- (CGRect)frameForTileKey:(id)key tile:(id)tile;
- (void)prepareTileForReuse:(id)tile;

- (void)tileWillAppear:(id)tile withKey:(id)key;
//- (void)transitionTile:(id)tile withKey:(id)key toState:(id)newState fromState:(id)oldState;
- (void)tileDidDisappear:(id)tile withKey:(id)key;

//selection
@property (nonatomic, retain) id selectedTileKey;
@property (nonatomic, readonly) id selectedTile;

@end
