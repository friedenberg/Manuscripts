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


@class AAPageControl;

@interface AAScorePDFView : UIScrollView <AAViewRecyclerDelegate>
{
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
}

@property (nonatomic) CGPDFDocumentRef pdfDocument;
@property (nonatomic) BOOL shouldRenderNewPages;

@property (nonatomic) NSUInteger pageIndex;
- (void)setPageIndex:(NSUInteger)pageIndex animated:(BOOL)shouldAnimate;

@property (nonatomic, readonly) AAPageControl *pageControl;

- (void)beginRotation;
- (void)endRotation;

@end
