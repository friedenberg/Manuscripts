//
//  AAPDFNoteContentView.h
//  Scores
//
//  Created by Sasha Friedenberg on 9/4/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AAPDFContentView.h"


@class AAPDFNoteContentView, AAPDFNoteView;

@protocol AAPDFNoteContentViewDataSource <NSObject>

- (NSUInteger)numberOfNotesAtPageIndex:(NSUInteger)pageIndex noteContentView:(AAPDFNoteContentView *)someNoteContentView;
- (NSString *)bodyForNoteAtIndexPath:(NSIndexPath *)noteIndexPath noteContentView:(AAPDFNoteContentView *)someNoteContentView;

- (CGPoint)centerPointForNoteAtIndexPath:(NSIndexPath *)noteIndexPath noteContentView:(AAPDFNoteContentView *)someNoteContentView;
- (void)setCenterPoint:(CGPoint)noteCenterPoint indexPath:(NSIndexPath *)noteIndexPath noteContentView:(AAPDFNoteContentView *)someNoteContentView;

- (void)noteContentView:(AAPDFNoteContentView *)someNoteContentView didMoveNoteWithIndexPathToFront:(NSIndexPath *)indexPath;

- (NSIndexPath *)addNoteWithCenterPoint:(CGPoint)newNoteCenter pageIndex:(NSUInteger)pageIndex noteContentView:(AAPDFNoteContentView *)someNoteContentView; //return the new note's index path, please

@end


@interface AAPDFNoteContentView : AAPDFContentView
{
    id <AAPDFNoteContentViewDataSource> __weak dataSource;
    UILongPressGestureRecognizer *pressGesture;
    
    BOOL editing;
}

@property (nonatomic, weak) id <AAPDFNoteContentViewDataSource> dataSource;

@property (nonatomic, getter = isEditing) BOOL editing;

@property (nonatomic, strong) NSIndexPath *selectedTileKey;
@property (weak, nonatomic, readonly) AAPDFNoteView *selectedTile;

@end

@interface NSIndexPath (AAPDFNoteContentViewAdditions)

+ (NSIndexPath *)indexPathForIndex:(NSUInteger)index inPage:(NSUInteger)page;

@property (nonatomic, readonly) NSUInteger index;
@property (nonatomic, readonly) NSUInteger page;

@end