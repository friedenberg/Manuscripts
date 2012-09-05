//
//  AAPDFView.m
//  Scores
//
//  Created by Sasha Friedenberg on 9/1/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AAPDFView.h"

#import "AAPDFContentView.h"
#import "AAPageControl.h"


@interface AAPDFView ()

- (void)pageControlPageChanged:(id)sender;

@end

@implementation AAPDFView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        pdfContentView = [AAPDFContentView new];
        [self addContentView:pdfContentView];
        
        pageControl = [AAPageControl new];
        [pageControl addTarget:self action:@selector(pageControlPageChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:pageControl];
    }
    
    return self;
}

@synthesize pdfContentView, pageControl, currentPage, activePages;

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    CGSize contentSize = self.contentSize;
    CGPoint contentOffset = self.contentOffset;
    CGRect visibleBounds = self.visibleBounds;
    
    currentPage = floor((visibleBounds.origin.x + (visibleBounds.size.width / 2)) / visibleBounds.size.width);
    NSUInteger activePageCount = (currentPage > 0) + (currentPage < pdfContentView.pageCount - 1) + 1;
    activePages = NSMakeRange(currentPage > 0 ? currentPage - 1 : 0, activePageCount);
    
    [pageControl sizeToFit];
    CGRect pageControlFrame = pageControl.frame;
    pageControlFrame.size.width = bounds.size.width - 12;
    pageControlFrame.origin.x = visibleBounds.origin.x + 6;
    pageControlFrame.origin.y = bounds.size.height - pageControlFrame.size.height - 4;
    
    if (contentOffset.x < 0)
    {
        pageControlFrame.origin.x -= contentOffset.x;
    }
    else if (contentOffset.x > contentSize.width - bounds.size.width)
    {
        pageControlFrame.origin.x -= fmod(contentOffset.x, bounds.size.width);
    }
    
    pageControl.frame = pageControlFrame;
    
    pageControl.currentPage = currentPage;
}

- (void)setCurrentPage:(NSUInteger)value
{
    [self setCurrentPage:value animated:NO];
}

- (void)setCurrentPage:(NSUInteger)value animated:(BOOL)shouldAnimate
{
    if (value == currentPage) return;
    
    currentPage = value;
    CGRect pageRect = [pdfContentView frameForTileKey:@(currentPage)];
    [self scrollRectToVisible:pageRect animated:shouldAnimate];
}

- (void)pageControlPageChanged:(id)sender
{
    self.currentPage = pageControl.currentPage;
}

- (void)dealloc
{
    [pageControl release];
    [pdfContentView release];
    [super dealloc];
}

@end
