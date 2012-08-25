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
#import "AAScorePDFNoteView.h"
#import "AAPDFDrawingOperation.h"

#import "AAPageControl.h"


@interface AAScorePDFView ()

- (void)tap:(UITapGestureRecognizer *)sender;
- (void)pageChanged:(id)sender;

@end

@implementation AAScorePDFView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
		self.showsHorizontalScrollIndicator = NO;
		self.canCancelContentTouches = NO;
        self.delaysContentTouches = NO;
		
        self.pagingEnabled = YES;
        noteRecycler = [[AAViewRecycler alloc] initWithDelegate:self];
        pageRecycler = [[AAViewRecycler alloc] initWithDelegate:self];
        
		drawingQueue = [AAOperationQueue new];
		drawingQueue.maxConcurrentOperationCount = 3;
		drawingQueue.operationCountLimit = 3;
		
        pagePadding = 0;
        
        pageControl = [[AAPageControl alloc] initWithFrame:CGRectZero];
        pdfPageContentView = [[UIView alloc] initWithFrame:CGRectZero];
        noteContentView = [[UIView alloc] initWithFrame:CGRectZero];
        
        [pageControl addTarget:self action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:pdfPageContentView];
        [self addSubview:pageControl];
        [self addSubview:noteContentView];
		
        visibleViewKeys = [NSMutableSet new];
        
		UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
		tapGesture.numberOfTapsRequired = 1;
		tapGesture.numberOfTouchesRequired = 1;
		[self addGestureRecognizer:tapGesture];
		[tapGesture release];
    }
    
    return self;
}

- (void)setFrame:(CGRect)value
{
	CGRect oldFrame = self.frame;
	
	isRotating = CGSizeEqualToSize(oldFrame.size, CGSizeMake(value.size.height, value.size.width));
	
	//shouldShowTwoPages = value.size.width > value.size.height;
	pageWidth = value.size.width;
	/*if (shouldShowTwoPages)
	{
		pageWidth /= 2;
		drawingQueue.operationCountLimit = 6;
	}
	else drawingQueue.operationCountLimit = 3;*/
	
    super.frame = value;
}

@synthesize pdfDocument, pageControl;

- (void)setPdfDocument:(CGPDFDocumentRef)value
{
    CGPDFDocumentRef old = pdfDocument;
    pdfDocument = CGPDFDocumentRetain(value);
    CGPDFDocumentRelease(old);
    
    numberOfPages = CGPDFDocumentGetNumberOfPages(pdfDocument);
    pageControl.pageCount = numberOfPages;
    
    [self setNeedsLayout];
}

- (UIView *)unusedViewForViewRecycler:(AAViewRecycler *)someViewRecycler
{
    UIView *view = nil;
    
    if (someViewRecycler == pageRecycler)
    {
        view = [[UIImageView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        view.contentMode = UIViewContentModeScaleAspectFit;
        [view autorelease];
    }
    else if (someViewRecycler == noteRecycler)
    {
        view = [[AAScorePDFNoteView alloc] initWithFrame:CGRectZero];
        [view autorelease];
    }
    
    return view;
}

- (BOOL)visibilityForKey:(id)key viewRecycler:(AAViewRecycler *)someViewRecycler
{
    if (someViewRecycler == pageRecycler)
    {
        NSNumber *number = key;
        NSUInteger index = [number unsignedIntegerValue];
        
        BOOL visibility = NSLocationInRange(index, visibleIndexes);
        return visibility;
    }
    else if (someViewRecycler == noteRecycler)
    {
        return NO;
    }
    else return NO;
}

- (CGRect)rectForViewWithKey:(id)key viewRecycler:(AAViewRecycler *)someViewRecycler
{
    CGRect rect = CGRectZero;
    
    if (someViewRecycler == pageRecycler)
    {
        NSNumber *number = key;
        NSUInteger index = [number unsignedIntegerValue];
        
        rect = self.bounds;
        
        rect.size.width = pageWidth;
        rect.origin.x = pagePadding;
        rect.origin.x += index * (pageWidth + (pagePadding * 2));
    }
    else if (someViewRecycler == noteRecycler)
    {
        
    }
    
    return rect;
}

- (UIView *)superviewForViewWithKey:(id)key viewRecycler:(AAViewRecycler *)someViewRecycler
{
    if (someViewRecycler == pageRecycler)
    {
        return pdfPageContentView;
    }
    else if (someViewRecycler == noteRecycler)
    {
        return noteContentView;
    }
    else return nil;
}

- (NSSet *)visibleKeysForViewRecycler:(AAViewRecycler *)someViewRecycler
{
    return visibleViewKeys;
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
	contentSize.width = pageWidth;
    contentSize.width *= (numberOfPages + (pagePadding * 2));
    self.contentSize = contentSize;
    
    CGRect contentRect = CGRectMake(0, 0, contentSize.width, contentSize.height);
    pdfPageContentView.frame = contentRect;
    noteContentView.frame = contentRect;
    
    [pageControl sizeToFit];
    CGRect pageIndexRect = pageControl.frame;
    pageIndexRect.size.width = bounds.size.width - 12;
    pageIndexRect.origin.x = visibleRect.origin.x + 6;
    pageIndexRect.origin.y = bounds.size.height - pageIndexRect.size.height - 4;
    
    if (contentOffset.x < 0)
        pageIndexRect.origin.x -= contentOffset.x;
    else if (contentOffset.x > contentSize.width - bounds.size.width)
        pageIndexRect.origin.x -= fmod(contentOffset.x, bounds.size.width);
    
    pageControl.frame = pageIndexRect;
    
	CGFloat layoutWidthForPage = (pageWidth + (pagePadding * 2));
	
	indexOfCurrentPage = floor((visibleRect.origin.x + (layoutWidthForPage / 2)) / layoutWidthForPage);
	
	indexOfCurrentPage = BETWEEN(0, indexOfCurrentPage, numberOfPages);
	NSUInteger pageLayoutFactor = shouldShowTwoPages ? 2 : 1;
    NSUInteger previousPage = MAX(0, (NSInteger)indexOfCurrentPage - 1 * (NSInteger)pageLayoutFactor);
	NSUInteger nextPage = MIN(numberOfPages, indexOfCurrentPage + 2 * pageLayoutFactor);
    
    NSRange previouslyVisibleIndexes = visibleIndexes;
    visibleIndexes = NSMakeRange(previousPage, nextPage - previousPage);
    
	if (isRotating && NO)
	{
		NSRangeEnumerate(visibleIndexes, ^(NSUInteger index) {
			
			[pageRecycler reloadViewWithKey:@(index)];
		});
		
		isRotating = NO;
	}
	
    NSUIntegerEnumerationBlock processPageAtIndexBlock = ^(NSUInteger index) {
        
        NSNumber *number = [NSNumber numberWithUnsignedInteger:index];
        [pageRecycler processViewForKey:number];
    };
    
    NSRangeEnumerate(previouslyVisibleIndexes, processPageAtIndexBlock);
    
    [drawingQueue setSuspended:YES];
    
    NSRangeEnumerate(visibleIndexes, processPageAtIndexBlock);
    
    [drawingQueue setSuspended:NO];
    
    pageControl.currentPage = indexOfCurrentPage;
}

static NSString *kPDFDrawingOperationObservingContext = @"kPDFDrawingOperationObservingContext";

- (void)viewRecycler:(AAViewRecycler *)someViewReuseController didLoadView:(UIView *)view withKey:(id)key
{
    NSNumber *index = key;
	CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdfDocument, [index unsignedIntegerValue] + 1);
    
	AAPDFDrawingOperation *drawingOperation = [AAPDFDrawingOperation new];
	drawingOperation.canvasSize = [self rectForViewWithKey:key viewRecycler:pageRecycler].size;
	drawingOperation.pdfPage = pdfPage;
	drawingOperation.viewRecyclingKey = key;
	[drawingOperation addObserver:self forKeyPath:@"isFinished" options:0 context:kPDFDrawingOperationObservingContext];
	[drawingQueue addOperation:drawingOperation];
	[drawingOperation release];
}

- (void)viewRecycler:(AAViewRecycler *)someViewReuseController prepareViewForRecycling:(UIView *)view
{
    UIImageView *pageView = (UIImageView *)view;
    pageView.image = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == kPDFDrawingOperationObservingContext)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			
			AAPDFDrawingOperation *drawingOperation = object;
			UIImageView *imageView = [pageRecycler visibleViewForKey:drawingOperation.viewRecyclingKey];
			imageView.image = drawingOperation.pdfPageImage;
		});
		
		[object removeObserver:self forKeyPath:keyPath];
	}
	else [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (BOOL)shouldRenderNewPages
{
    return ![drawingQueue isSuspended];
}

- (void)setShouldRenderNewPages:(BOOL)value
{
    [drawingQueue setSuspended:!value];
}

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated
{
    [super scrollRectToVisible:rect animated:animated];
}

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    if (view == pageControl)
        return YES;
    
    return NO;
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
    CGRect pageRect = [self rectForViewWithKey:@(pageIndex) viewRecycler:pageRecycler];
    [self scrollRectToVisible:pageRect animated:shouldAnimate];
}

- (void)pageChanged:(id)sender
{
    self.pageIndex = pageControl.currentPage;
}

- (void)tap:(UITapGestureRecognizer *)sender
{
	CGFloat width = CGRectGetWidth(self.bounds);
	CGPoint tapPoint = [sender locationInView:self];
	CGFloat xOrigin = tapPoint.x - self.contentOffset.x;
	
    if (CGRectContainsPoint(pageControl.frame, tapPoint)) return;
    
	if (xOrigin <= width / 3) [self setPageIndex:indexOfCurrentPage - 1 animated:YES];
	else if (xOrigin >= width * 2 / 3) [self setPageIndex:indexOfCurrentPage + 1 animated:YES];
}

- (void)beginRotation
{
    [pageRecycler reloadVisibleViews];
    //[pageRecycler reloadViewWithKey:@(indexOfCurrentPage)];
}

- (void)endRotation
{
    
}

- (void)dealloc
{
    [noteRecycler release];
    [noteContentView release];
    [visibleViewKeys release];
    [pdfPageContentView release];
    [pageControl release];
	[drawingQueue release];
    CGPDFDocumentRelease(pdfDocument);
    [super dealloc];
}

@end
