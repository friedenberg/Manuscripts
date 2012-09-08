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

#import "AAPDFContentView.h"

@interface AAPDFPageContentView : AAPDFContentView
{
    AAOperationQueue *drawingQueue;
	NSCache *pdfPageCache;
    
    NSUInteger pageCount;
    CGPDFDocumentRef pdfDocument;
    
    UITapGestureRecognizer *tapGesture;
}

@property (nonatomic) CGPDFDocumentRef pdfDocument;
@property (nonatomic, readonly) NSUInteger pageCount;

@property (nonatomic) BOOL shouldRenderNewPages;

@end
