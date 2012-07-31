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


@interface AAScorePDFView : UIScrollView <AAViewRecyclerDelegate>
{
	NSOperationQueue *pdfPageDrawingQueue;
	
    NSUInteger numberOfPages;
    CGFloat pageWidth;
    CGFloat pagePadding;
    CGPDFDocumentRef pdfDocument;
    
    AAViewRecycler *pdfPageRecycler;
    NSRange visibleIndexes;
	NSUInteger indexOfCurrentPage;
}

- (id)initWithURL:(NSURL *)pdfURL;

@property (nonatomic) CGPDFDocumentRef pdfDocument;

@end
