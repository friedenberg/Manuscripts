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


@implementation AAScorePDFView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.pagingEnabled = YES;
        pdfPageRecycler = [[AAViewRecycler alloc] initWithDelegate:self];
        
        pagePadding = 0;
    }
    
    return self;
}

- (id)initWithURL:(NSURL *)pdfURL
{
    if (self = [super initWithFrame:CGRectZero])
    {
        self.pagingEnabled = YES;
        pdfDocument = CGPDFDocumentCreateWithURL((__bridge CFURLRef)pdfURL);
        
        pdfPageRecycler = [[AAViewRecycler alloc] initWithDelegate:self];
        
        pagePadding = 0;
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
    
    [self setNeedsLayout];
}

- (UIView <AAViewRecycling> *)unusedViewForViewRecycler:(AAViewRecycler *)someViewRecycler
{
    return [[[AAScorePDFPageView alloc] initWithFrame:CGRectZero] autorelease];
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
    return self;
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
    
	CGFloat layoutWidthForPage = (pageWidth + (pagePadding * 2));
	
	indexOfCurrentPage = floor((visibleRect.origin.x + (layoutWidthForPage / 2)) / layoutWidthForPage);
	
	indexOfCurrentPage = BETWEEN(0, indexOfCurrentPage, numberOfPages);
    NSUInteger firstIndex = BETWEEN(0, indexOfCurrentPage == 0 ? 0 : indexOfCurrentPage - 1, numberOfPages);
	NSUInteger lastIndex = BETWEEN(0, indexOfCurrentPage + 2, numberOfPages);
    
    NSRange previouslyVisibleIndexes = visibleIndexes;
    visibleIndexes = NSMakeRange(firstIndex, lastIndex - firstIndex);
    
    NSRangeEnumerateUnion(previouslyVisibleIndexes, visibleIndexes, ^(NSUInteger index) {
        
        NSNumber *number = [NSNumber numberWithUnsignedInteger:index];
        [pdfPageRecycler processViewForKey:number];
    });
}

- (void)viewRecycler:(AAViewRecycler *)someViewReuseController didLoadView:(UIView <AAViewRecycling> *)view withKey:(id)key
{
    NSNumber *index = key;
    AAScorePDFPageView *pageView = view;
    pageView.pdfPage = CGPDFDocumentGetPage(pdfDocument, [index unsignedIntegerValue] + 1);
}

- (void)dealloc
{
    CGPDFDocumentRelease(pdfDocument);
    [super dealloc];
}

@end
