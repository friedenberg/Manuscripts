//
//  AAPDFContentView.h
//  Scores
//
//  Created by Sasha Friedenberg on 9/1/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AATiledContentView.h"


@class AAOperationQueue;

@interface AAPDFContentView : AATiledContentView
{
    AAOperationQueue *drawingQueue;
	
	BOOL isRotating;
    
    NSUInteger pageCount;
    CGFloat pageWidth;
    CGPDFDocumentRef pdfDocument;
    
    NSRange currentPages;
	NSUInteger currentPage;
}

@property (nonatomic) CGPDFDocumentRef pdfDocument;
@property (nonatomic) BOOL shouldRenderNewPages;

@end
