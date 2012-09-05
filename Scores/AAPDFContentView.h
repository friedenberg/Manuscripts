//
//  AAPDFContentView.h
//  Scores
//
//  Created by Sasha Friedenberg on 9/1/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AATiledContentView.h"
#import "AAPDFView.h"


@class AAOperationQueue;

@interface AAPDFContentView : AATiledContentView
{
    AAOperationQueue *drawingQueue;
	NSCache *pdfPageCache;
    
	BOOL isRotating;
    
    NSUInteger pageCount;
    CGPDFDocumentRef pdfDocument;
    
    UITapGestureRecognizer *tapGesture;
}

@property (nonatomic, readonly, assign) AAPDFView *scrollView;

@property (nonatomic) CGPDFDocumentRef pdfDocument;
@property (nonatomic, readonly) NSUInteger pageCount;

@property (nonatomic) BOOL shouldRenderNewPages;

@end
