//
//  AAPDFNoteContentView.h
//  Scores
//
//  Created by Sasha Friedenberg on 9/4/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AAPDFContentView.h"


@class AAPDFNoteContentView;

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
    id <AAPDFNoteContentViewDataSource> dataSource;
    UILongPressGestureRecognizer *pressGesture;
}

@property (nonatomic, assign) id <AAPDFNoteContentViewDataSource> dataSource;

@end

@interface NSIndexPath (AAPDFNoteContentViewAdditions)

+ (NSIndexPath *)indexPathForIndex:(NSUInteger)index inPage:(NSUInteger)page;

@property (nonatomic, readonly) NSUInteger index;
@property (nonatomic, readonly) NSUInteger page;

@end