//
//  AATiledContentView.h
//  Scores
//
//  Created by Sasha Friedenberg on 8/25/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


extern NSString * const AAViewTilingVisibleKey;
extern NSString * const AAViewTilingNotVisibleKey;

@interface AATiledContentView : UIView
{
    UIScrollView *scrollView;
    CGRect previouslyVisibleRect;
    CGRect visibleRect;
    
    NSMutableDictionary *tileStates;
    
    NSMutableArray *spareTiles;
    
    NSMutableDictionary *tileKeyStates;
    
    NSMutableSet *visibleTileKeys;
    NSMutableDictionary *visibleTiles;
    NSMutableSet *selectedTileKeys;
}

@property (nonatomic, readonly, assign) UIScrollView *scrollView;
@property (nonatomic, readonly) CGSize contentSize;
@property (nonatomic) CGRect visibleRect;

//tile population
@property (nonatomic, readonly) NSUInteger tileCount;
- (id)tileKeyAtIndex:(NSUInteger)index;

//tile mutation
- (void)reloadTiles;

//tiling
- (id)tile;
- (id)tileForKey:(id)key;

- (BOOL)visibilityForTileKey:(id <NSCopying>)key;
- (CGRect)frameForTileKey:(id <NSCopying>)key;
- (void)prepareTileForReuse:(id)tile withKey:(id <NSCopying>)key;

- (void)tileWillAppear:(id)tile withKey:(id <NSCopying>)key;
- (void)tileDidDisappear:(id)tile withKey:(id <NSCopying>)key;

@end
