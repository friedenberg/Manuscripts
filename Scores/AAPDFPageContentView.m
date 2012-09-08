//
//  AAPDFContentView.m
//  Scores
//
//  Created by Sasha Friedenberg on 9/1/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AAPDFPageContentView.h"

#import "AAPDFView.h"
#import "AAPageControl.h"

#import "AAOperationQueue.h"
#import "AAPDFPageDrawingOperation.h"

#import "NSUInteger+Enumeration.h"


@interface AAPDFPageContentView ()

- (void)tapGesture:(UITapGestureRecognizer *)sender;
- (void)pdfPageDrawingOperationDidFinish:(AAPDFPageDrawingOperation *)operation;

@end


@implementation AAPDFPageContentView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        drawingQueue = [AAOperationQueue new];
		drawingQueue.maxConcurrentOperationCount = 3;
		drawingQueue.operationCountLimit = 3;
        
        pdfPageCache = [NSCache new];
        pdfPageCache.countLimit = 3;
        
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        [self addGestureRecognizer:tapGesture];
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

@synthesize pdfDocument, pageCount;
@dynamic scrollView;

- (void)setPdfDocument:(CGPDFDocumentRef)value
{
    CGPDFDocumentRef old = pdfDocument;
    pdfDocument = CGPDFDocumentRetain(value);
    CGPDFDocumentRelease(old);
    
    pageCount = CGPDFDocumentGetNumberOfPages(pdfDocument);
    self.scrollView.pageControl.pageCount = pageCount;
    
    [self reloadTiles];
}

- (CGFloat)pageWidth
{
    return self.scrollView.bounds.size.width;
}

- (CGSize)contentSize
{
    return CGSizeMake(self.pageWidth * pageCount, self.scrollView.bounds.size.height);
}

#pragma mark - tiling

- (NSEnumerator *)tileKeyEnumerator
{
    NSMutableArray *tileKeys = [NSMutableArray arrayWithCapacity:pageCount];
    
    NSUIntegerEnumerate(pageCount, ^(NSUInteger index) {
        
        [tileKeys addObject:@(index)];
    });
    
    return [tileKeys objectEnumerator];
}

- (id)newTile
{
    return [UIImageView new];
}

- (BOOL)visibilityForTileKey:(NSNumber *)key
{
    return NSLocationInRange(key.unsignedIntegerValue, self.scrollView.activePages);
}

- (CGRect)frameForTileKey:(NSNumber *)key tile:(id)tile
{
    CGRect frame = self.scrollView.bounds;
    frame.origin.x = (CGFloat)key.unsignedIntegerValue * self.pageWidth;
    return frame;
}

- (void)prepareTileForReuse:(UIImageView *)tile withKey:(NSNumber *)key
{
    tile.image = nil;
}

- (void)tileWillAppear:(UIImageView *)tile withKey:(NSNumber *)key
{
    CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdfDocument, key.unsignedIntegerValue + 1);
    
    UIImage *cachedPDFPageImage = [pdfPageCache objectForKey:key];
    
    if (cachedPDFPageImage)
    {
        tile.image = cachedPDFPageImage;
        [pdfPageCache removeObjectForKey:key];
    }
    else
    {
        AAPDFPageDrawingOperation *drawingOperation = [AAPDFPageDrawingOperation new];
        drawingOperation.canvasSize = self.scrollView.bounds.size;
        drawingOperation.pdfPage = pdfPage;
        drawingOperation.key = key;
        [drawingOperation addObserver:self forKeyPath:@"isFinished" options:0 context:kPDFDrawingOperationObservingContext];
        
        [drawingQueue addOperation:drawingOperation];
        
        [drawingOperation release];
    }
}

- (void)pdfPageDrawingOperationDidFinish:(AAPDFPageDrawingOperation *)operation
{
    UIImageView *imageView = [self tileForKey:operation.key];
    imageView.image = operation.pdfPageImage;
}

- (void)tileDidDisappear:(UIImageView *)tile withKey:(NSNumber *)key
{
    //TODO: check to see if image is low-res or high-res
    UIImage *image = tile.image;
    
    if (image)
    {
        [pdfPageCache setObject:image forKey:key];
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)sender
{
    CGFloat width = CGRectGetWidth(self.scrollView.bounds);
	CGPoint tapPoint = [sender locationInView:self];
	CGFloat xOrigin = tapPoint.x - self.scrollView.contentOffset.x;
    
	if (xOrigin <= width / 3) [self.scrollView setCurrentPage:self.scrollView.currentPage - 1 animated:YES];
	else if (xOrigin >= width * 2 / 3) [self.scrollView setCurrentPage:self.scrollView.currentPage + 1 animated:YES];
}

- (void)dealloc
{
    CGPDFDocumentRelease(pdfDocument);
    [tapGesture release];
    [drawingQueue release];
    [pdfPageCache release];
    [super dealloc];
}

@end
