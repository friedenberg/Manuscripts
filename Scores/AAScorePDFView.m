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


@interface AAScorePDFView () <UIGestureRecognizerDelegate>

- (void)tap:(UITapGestureRecognizer *)sender;
- (void)press:(UILongPressGestureRecognizer *)sender;
- (void)pageChanged:(id)sender;

@end

@implementation AAScorePDFView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
		self.showsHorizontalScrollIndicator = NO;
		//self.canCancelContentTouches = NO;
        //self.delaysContentTouches = NO;
		
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
        [self addSubview:noteContentView];
        [self addSubview:pageControl];
		
        visibleViewKeys = [NSMutableSet new];
        
		tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(press:)];
        pressRecognizer.delegate = self;
        
        [pressRecognizer requireGestureRecognizerToFail:tapRecognizer];
        
        for (UIGestureRecognizer *recognizer in self.gestureRecognizers)
        {
            [recognizer requireGestureRecognizerToFail:pressRecognizer];
        }
        
        [self addGestureRecognizer:tapRecognizer];
        [noteContentView addGestureRecognizer:pressRecognizer];
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

#pragma mark - properties

@synthesize pdfDocument, noteDataSource, pageControl;

- (void)setPdfDocument:(CGPDFDocumentRef)value
{
    CGPDFDocumentRef old = pdfDocument;
    pdfDocument = CGPDFDocumentRetain(value);
    CGPDFDocumentRelease(old);
    
    numberOfPages = CGPDFDocumentGetNumberOfPages(pdfDocument);
    pageControl.pageCount = numberOfPages;
    
    [self setNeedsLayout];
}

- (void)setNoteDataSource:(id<AAScorePDFViewNoteDataSource>)value
{
    noteDataSource = value;
    [self setNeedsLayout];
}

#pragma mark - geometry

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
        NSIndexPath *indexPath = key;
        return NSLocationInRange(indexPath.section, visibleIndexes);
    }
    else return NO;
}

- (CGRect)rectForViewWithKey:(id)key view:(UIView *)view viewRecycler:(AAViewRecycler *)someViewRecycler
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
        CGSize size = [view sizeThatFits:view.frame.size];
        size.width = MAX(size.width, 100);
        size.height = MAX(size.height, 100);
        
        CGPoint centerPoint = [self.noteDataSource centerPointForNoteAtIndexPath:key scorePDFView:self];
        
        rect.size = size;
        rect.origin = CGPointMake(floor(centerPoint.x - size.width / 2), floor(centerPoint.y - size.height / 2));
    }
    
    return rect;
}

- (NSUInteger)pageIndexForPoint:(CGPoint)point
{
    return floor(point.x / pageWidth);
}

#pragma mark - view recycling

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
	
    NSUIntegerEnumerationBlock processPageAtIndexBlock = ^(NSUInteger pageIndex) {
        
        NSNumber *number = [NSNumber numberWithUnsignedInteger:pageIndex];
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
    if (someViewReuseController == pageRecycler)
    {
        NSNumber *index = key;
        NSUInteger pageIndex = [index unsignedIntegerValue];
        CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdfDocument, [index unsignedIntegerValue] + 1);
        
        AAPDFDrawingOperation *drawingOperation = [AAPDFDrawingOperation new];
        drawingOperation.canvasSize = [self rectForViewWithKey:key view:view viewRecycler:pageRecycler].size;
        drawingOperation.pdfPage = pdfPage;
        drawingOperation.viewRecyclingKey = key;
        [drawingOperation addObserver:self forKeyPath:@"isFinished" options:0 context:kPDFDrawingOperationObservingContext];
        [drawingQueue addOperation:drawingOperation];
        [drawingOperation release];
        
        NSUInteger numberOfNotesOnThisPage = [self.noteDataSource numberOfNotesAtPageIndex:pageIndex scorePDFView:self];
        
        NSUIntegerEnumerate(numberOfNotesOnThisPage, ^(NSUInteger noteIndex) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:noteIndex inSection:pageIndex];
            [noteRecycler processViewForKey:indexPath];
        });
    }
    else
    {
        NSIndexPath *indexPath = key;
        AAScorePDFNoteView *noteView = view;
        
        noteView.textLabel.text = [self.noteDataSource bodyForNoteAtIndexPath:indexPath scorePDFView:self];
    }
}

- (void)viewRecycler:(AAViewRecycler *)someViewReuseController prepareViewForRecycling:(UIView *)view
{
    if (someViewReuseController == pageRecycler)
    {
        UIImageView *pageView = (UIImageView *)view;
        pageView.image = nil;
    }
    else if (someViewReuseController == noteRecycler)
    {
        
    }
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
    NSNumber *key = @(pageIndex);
    CGRect pageRect = [self rectForViewWithKey:key view:[pageRecycler visibleViewForKey:key] viewRecycler:pageRecycler];
    [self scrollRectToVisible:pageRect animated:shouldAnimate];
}

- (void)pageChanged:(id)sender
{
    self.pageIndex = pageControl.currentPage;
}

#pragma mark - user interaction

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    if (view == pageControl)
        return YES;
    
    return NO;
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

- (void)press:(UILongPressGestureRecognizer *)sender
{
    CGPoint touchLocation = [sender locationInView:noteContentView];
    NSUInteger thisPage = [self pageIndexForPoint:touchLocation];
    
    switch (sender.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            NSUInteger numberOfNotesOnThisPage = [self.noteDataSource numberOfNotesAtPageIndex:thisPage scorePDFView:self];
            
            NSUIntegerEnumerate(numberOfNotesOnThisPage, ^(NSUInteger index) {
                
                index = numberOfNotesOnThisPage - index - 1;
                NSIndexPath *noteKey = [NSIndexPath indexPathForRow:index inSection:thisPage];
                
                CGRect frame = [[noteRecycler visibleViewForKey:noteKey] frame];
                
                if (CGRectContainsPoint(frame, touchLocation) && !noteRecycler.keyForCurrentlyTouchedView)
                {
                    noteRecycler.keyForCurrentlyTouchedView = noteKey;
                }
                
            });
            
            if (noteRecycler.keyForCurrentlyTouchedView)
            {
                [noteRecycler.currentlyTouchedView startDragAsExistingView];
            }
            else
            {
                noteRecycler.keyForCurrentlyTouchedView = [self.noteDataSource addNoteWithCenterPoint:touchLocation pageIndex:indexOfCurrentPage scorePDFView:self];
                [noteRecycler processViewForKey:noteRecycler.keyForCurrentlyTouchedView];
                [noteRecycler.currentlyTouchedView startDragAsNewView];
            }
            
            [noteContentView bringSubviewToFront:noteRecycler.currentlyTouchedView];
            [noteRecycler.currentlyTouchedView setCenter:touchLocation];
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            AAScorePDFNoteView *noteView = noteRecycler.currentlyTouchedView;
            noteView.center = touchLocation;
        }
            break;
        
        case UIGestureRecognizerStateEnded:
        {
            AAScorePDFNoteView *noteView = noteRecycler.currentlyTouchedView;
            [noteView endDrag];
            
            [self.noteDataSource scorePDFView:self didMoveNoteWithIndexPathToFront:noteRecycler.keyForCurrentlyTouchedView];
            [self.noteDataSource setCenterPoint:touchLocation indexPath:noteRecycler.keyForCurrentlyTouchedView scorePDFView:self];
            noteRecycler.keyForCurrentlyTouchedView = nil;
        }
            break;
            
        default:
            break;
    }
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
    [tapRecognizer release];
    [pressRecognizer release];
    
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
