//
//  AAPDFScrollView.m
//  Scores
//
//  Created by Sasha Friedenberg on 7/24/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AAScorePDFView.h"

#import "AAViewRecycler.h"

#import "AAScorePDFPageView.h"
#import "AAPDFDrawingOperation.h"

#import "AAPageIndexView.h"


@interface AAScorePDFView ()

- (void)pageChanged:(id)sender;

@end

@implementation AAScorePDFView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
		self.showsHorizontalScrollIndicator = NO;
		self.canCancelContentTouches = NO;
		
        self.pagingEnabled = YES;
        pdfPageRecycler = [[AAViewRecycler alloc] initWithDelegate:self];
        
		pdfPageDrawingQueue = [NSOperationQueue new];
		pdfPageDrawingQueue.maxConcurrentOperationCount = 3;
		
        pagePadding = 0;
        
        pageIndexView = [[AAPageIndexView alloc] initWithFrame:CGRectZero];
        pdfPageContentView = [[UIView alloc] initWithFrame:CGRectZero];
        
        [pageIndexView addTarget:self action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:pdfPageContentView];
        [self addSubview:pageIndexView];
    }
    
    return self;
}

- (id)initWithURL:(NSURL *)pdfURL
{
    if (self = [super initWithFrame:CGRectZero])
    {
		self.showsHorizontalScrollIndicator = NO;
		self.canCancelContentTouches = NO;
        self.pagingEnabled = YES;
        //self.bounces = NO;
        
        pdfDocument = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
        
		pdfPageDrawingQueue = [NSOperationQueue new];
		pdfPageDrawingQueue.maxConcurrentOperationCount = 1;
		
        pdfPageRecycler = [[AAViewRecycler alloc] initWithDelegate:self];
        
        pagePadding = 0;
        
        pageIndexView = [[AAPageIndexView alloc] initWithFrame:CGRectZero];
        pdfPageContentView = [[UIView alloc] initWithFrame:CGRectZero];
        
        [pageIndexView addTarget:self action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:pdfPageContentView];
        [self addSubview:pageIndexView];
    }
    
    return self;
}

- (void)setFrame:(CGRect)value
{
    [super setFrame:value];
    pageWidth = value.size.width;
}

@synthesize pdfDocument;

- (void)setPdfDocument:(CGPDFDocumentRef)value
{
    CGPDFDocumentRef old = pdfDocument;
    pdfDocument = CGPDFDocumentRetain(value);
    CGPDFDocumentRelease(old);
    
    numberOfPages = CGPDFDocumentGetNumberOfPages(pdfDocument);
    pageIndexView.pageCount = numberOfPages;
    
    [self setNeedsLayout];
}

- (UIView *)unusedViewForViewRecycler:(AAViewRecycler *)someViewRecycler
{
	UIView *view = [[UIImageView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    return [view autorelease];
}

- (BOOL)visibilityForKey:(id)key viewRecycler:(AAViewRecycler *)someViewRecycler
{
    NSNumber *number = key;
    NSUInteger index = [number unsignedIntegerValue];
    
	BOOL visibility = NSLocationInRange(index, visibleIndexes);
    //NSLog(@"%@, is %i visible: %i", NSStringFromRange(visibleIndexes), index, visibility);
    return visibility;
}

- (CGRect)rectForViewWithKey:(id)key viewRecycler:(AAViewRecycler *)someViewRecycler
{
    NSNumber *number = key;
    NSUInteger index = [number unsignedIntegerValue];
    
    CGRect rect = self.bounds;
    rect.origin.x = pagePadding;
    rect.origin.x += index * (pageWidth + (pagePadding * 2));
    
    return rect;
}

- (UIView *)superviewForViewWithKey:(id)key viewRecycler:(AAViewRecycler *)someViewRecycler
{
    return pdfPageContentView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    CGPoint contentOffset = self.contentOffset;
    CGRect visibleRect = CGRectZero;
    visibleRect.origin = contentOffset;
    visibleRect.size = bounds.size;
    
    CGSize contentSize = bounds.size;
    contentSize.width *= (numberOfPages + (pagePadding * 2));
    self.contentSize = contentSize;
    
    CGRect pdfPageContentRect = CGRectMake(0, 0, contentSize.width, contentSize.height);
    pdfPageContentView.frame = pdfPageContentRect;
    
    [pageIndexView sizeToFit];
    CGRect pageIndexRect = pageIndexView.frame;
    pageIndexRect.size.width = bounds.size.width - 12;
    pageIndexRect.origin.x = visibleRect.origin.x + 6;
    pageIndexRect.origin.y = bounds.size.height - pageIndexRect.size.height - 4;
    pageIndexView.frame = pageIndexRect;
    
	CGFloat layoutWidthForPage = (pageWidth + (pagePadding * 2));
	
	indexOfCurrentPage = floor((visibleRect.origin.x + (layoutWidthForPage / 2)) / layoutWidthForPage);
	
	indexOfCurrentPage = BETWEEN(0, indexOfCurrentPage, numberOfPages);
    NSUInteger previousPage = BETWEEN(0, indexOfCurrentPage == 0 ? 0 : indexOfCurrentPage - 1, numberOfPages);
	NSUInteger nextPage = BETWEEN(0, indexOfCurrentPage + 2, numberOfPages);
    
    NSRange previouslyVisibleIndexes = visibleIndexes;
    visibleIndexes = NSMakeRange(previousPage, nextPage - previousPage);
    
    NSUIntegerEnumerationBlock processPageAtIndexBlock = ^(NSUInteger index) {
        
        NSNumber *number = [NSNumber numberWithUnsignedInteger:index];
        [pdfPageRecycler processViewForKey:number];
    };
    
    NSRangeEnumerate(previouslyVisibleIndexes, processPageAtIndexBlock);
    
    processPageAtIndexBlock(indexOfCurrentPage);
    processPageAtIndexBlock(nextPage);
    processPageAtIndexBlock(previousPage);
}

static NSString *kPDFDrawingOperationObservingContext = @"kPDFDrawingOperationObservingContext";

- (void)viewRecycler:(AAViewRecycler *)someViewReuseController didLoadView:(UIView *)view withKey:(id)key
{
    NSNumber *index = key;
    UIImageView *pageView = (UIImageView *)view;
    pageView.image = nil;
	CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdfDocument, [index unsignedIntegerValue] + 1);
    
	AAPDFDrawingOperation *drawingOperation = [AAPDFDrawingOperation new];
	drawingOperation.canvasSize = self.bounds.size;
	drawingOperation.pdfPage = pdfPage;
	drawingOperation.viewRecyclingKey = key;
	[drawingOperation addObserver:self forKeyPath:@"isFinished" options:0 context:kPDFDrawingOperationObservingContext];
	[pdfPageDrawingQueue addOperation:drawingOperation];
	[drawingOperation release];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == kPDFDrawingOperationObservingContext)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			
			AAPDFDrawingOperation *drawingOperation = object;
			UIImageView *imageView = [pdfPageRecycler visibleViewForKey:drawingOperation.viewRecyclingKey];
			imageView.image = drawingOperation.pdfPageImage;
			[imageView setNeedsDisplay];
		});
		
		[object removeObserver:self forKeyPath:keyPath];
	}
	else [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated
{
    [super scrollRectToVisible:rect animated:animated];
}

- (NSUInteger)pageIndex
{
    return indexOfCurrentPage;
}

- (void)setPageIndex:(NSUInteger)newPageIndex
{
    [self setPageIndex:newPageIndex animated:NO];
}

- (void)setPageIndex:(NSUInteger)pageIndex animated:(BOOL)shouldAnimate
{
    CGRect pageRect = [self rectForViewWithKey:[NSNumber numberWithUnsignedInteger:pageIndex] viewRecycler:pdfPageRecycler];
    [self scrollRectToVisible:pageRect animated:shouldAnimate];
}

- (void)pageChanged:(id)sender
{
    CGFloat progress = pageIndexView.currentTrackingProgress;
    
    if (progress >= 0 && progress < 1)
        [self setPageIndex:floor(numberOfPages * pageIndexView.currentTrackingProgress) animated:NO];
}

- (void)dealloc
{
    [pdfPageContentView release];
    [pageIndexView release];
	[pdfPageDrawingQueue release];
    CGPDFDocumentRelease(pdfDocument);
    [super dealloc];
}

@end
