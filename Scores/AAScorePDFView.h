//
//  AAPDFScrollView.h
//  Scores
//
//  Created by Sasha Friedenberg on 7/24/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AAViewRecycler.h"
#import "AAOperationQueue.h"


@class AAScorePDFView;

@protocol AAScorePDFViewNoteDataSource <NSObject>

- (NSUInteger)numberOfNotesAtPageIndex:(NSUInteger)pageIndex scorePDFView:(AAScorePDFView *)someScorePDFView;
- (NSString *)bodyForNoteAtIndexPath:(NSIndexPath *)noteIndexPath scorePDFView:(AAScorePDFView *)someScorePDFView;

- (CGPoint)centerPointForNoteAtIndexPath:(NSIndexPath *)noteIndexPath scorePDFView:(AAScorePDFView *)someScorePDFView;
- (void)setCenterPoint:(CGPoint)noteCenterPoint indexPath:(NSIndexPath *)noteIndexPath scorePDFView:(AAScorePDFView *)someScorePDFView;

- (void)scorePDFView:(AAScorePDFView *)someScorePDFView didMoveNoteWithIndexPathToFront:(NSIndexPath *)indexPath;

- (NSIndexPath *)addNoteWithCenterPoint:(CGPoint)newNoteCenter pageIndex:(NSUInteger)pageIndex scorePDFView:(AAScorePDFView *)someScorePDFView; //return the new note's index path, please

@end

@class AAPageControl, AAScorePDFNoteView;

@interface AAScorePDFView : UIScrollView <AAViewRecyclerDelegate>
{
    id <AAScorePDFViewNoteDataSource> noteDataSource;
    
	AAOperationQueue *drawingQueue;
	
    BOOL shouldShowTwoPages;
	BOOL isRotating;
    
    NSMutableSet *visibleViewKeys;
    
    NSUInteger numberOfPages;
    CGFloat pageWidth;
    CGFloat pagePadding;
    CGPDFDocumentRef pdfDocument;
    
    AAViewRecycler *pageRecycler;
    AAViewRecycler *noteRecycler;
    NSRange visibleIndexes;
	NSUInteger indexOfCurrentPage;
    
    AAPageControl *pageControl;
    UIView *pdfPageContentView;
    UIView *noteContentView;
    
    UITapGestureRecognizer *tapRecognizer;
    UILongPressGestureRecognizer *pressRecognizer;
    
    AAScorePDFNoteView *currentNoteView;
}

@property (nonatomic) CGPDFDocumentRef pdfDocument;
@property (nonatomic, assign) id <AAScorePDFViewNoteDataSource> noteDataSource;

@property (nonatomic) BOOL shouldRenderNewPages;

@property (nonatomic) NSUInteger pageIndex;
- (void)setPageIndex:(NSUInteger)pageIndex animated:(BOOL)shouldAnimate;

@property (nonatomic, readonly) AAPageControl *pageControl;

- (NSUInteger)pageIndexForPoint:(CGPoint)point;

- (void)beginRotation;
- (void)endRotation;

@end
