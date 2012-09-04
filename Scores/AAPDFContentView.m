//
//  AAPDFContentView.m
//  Scores
//
//  Created by Sasha Friedenberg on 9/1/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AAPDFContentView.h"

#import "AAOperationQueue.h"
#import "AAPDFPageDrawingOperation.h"


@interface AAPDFContentView ()

- (void)pdfPageDrawingOperationDidFinish:(AAPDFPageDrawingOperation *)operation;

@end


@implementation AAPDFContentView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        drawingQueue = [AAOperationQueue new];
		drawingQueue.maxConcurrentOperationCount = 3;
		drawingQueue.operationCountLimit = 3;
    }
    
    return self;
}

static NSString *kPDFDrawingOperationObservingContext = @"kPDFDrawingOperationObservingContext";

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == kPDFDrawingOperationObservingContext)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			
            [self pdfPageDrawingOperationDidFinish:object];
		});
		
		[object removeObserver:self forKeyPath:keyPath];
	}
	else [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@synthesize pdfDocument;

- (void)setPdfDocument:(CGPDFDocumentRef)value
{
    CGPDFDocumentRef old = pdfDocument;
    pdfDocument = CGPDFDocumentRetain(value);
    CGPDFDocumentRelease(old);
    
    pageCount = CGPDFDocumentGetNumberOfPages(pdfDocument);
    
    [self setNeedsLayout];
}

- (CGSize)contentSize
{
    return CGSizeMake(pageWidth * pageCount, self.scrollView.bounds.size.height);
}

- (void)layoutSubviews
{
    pageWidth = self.scrollView.bounds.size.width;
        
    currentPage = floor(self.visibleRect.origin.x / pageWidth);
    NSUInteger currentPageCount = (currentPage > 0) + (currentPage < pageCount - 1) + 1;
    currentPages = NSMakeRange(currentPage > 0 ? currentPage - 1 : 0, currentPageCount);
    
    [super layoutSubviews];
}

#pragma mark - tile population

- (NSUInteger)tileCount
{
    return pageCount;
}

- (id)tileKeyAtIndex:(NSUInteger)index
{
    return @(index);
}

#pragma mark - tiling

- (id)tile
{
    UIImageView *pageView = [UIImageView new];
    return [pageView autorelease];
}

- (BOOL)visibilityForTileKey:(NSNumber *)key
{
    return NSLocationInRange(key.unsignedIntegerValue, currentPages);
}

- (CGRect)frameForTileKey:(NSNumber *)key
{
    CGRect frame = self.scrollView.bounds;
    frame.origin.x = (CGFloat)key.unsignedIntegerValue * pageWidth;
    return frame;
}

- (void)prepareTileForReuse:(UIImageView *)tile withKey:(NSNumber *)key
{
    tile.image = nil;
}

- (void)tileWillAppear:(UIImageView *)tile withKey:(NSNumber *)key
{
    CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdfDocument, key.unsignedIntegerValue + 1);
    
    AAPDFPageDrawingOperation *drawingOperation = [AAPDFPageDrawingOperation new];
    drawingOperation.canvasSize = self.scrollView.bounds.size;
    drawingOperation.pdfPage = pdfPage;
    drawingOperation.key = key;
    [drawingOperation addObserver:self forKeyPath:@"isFinished" options:0 context:kPDFDrawingOperationObservingContext];
    
    [drawingQueue addOperation:drawingOperation];
    
    [drawingOperation release];
}

- (void)pdfPageDrawingOperationDidFinish:(AAPDFPageDrawingOperation *)operation
{
    UIImageView *imageView = [self tileForKey:operation.key];
    imageView.image = operation.pdfPageImage;
}

- (void)tileDidDisappear:(UIImageView *)tile withKey:(NSNumber *)key
{
    
}

- (void)dealloc
{
    CGPDFDocumentRelease(pdfDocument);
    [drawingQueue release];
    [super dealloc];
}

@end
