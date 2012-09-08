//
//  AAPDFView.h
//  Scores
//
//  Created by Sasha Friedenberg on 9/1/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AATilingScrollView.h"


@class AAPDFPageContentView, AAPDFNoteContentView, AAPageControl;

@interface AAPDFView : AATilingScrollView
{
    AAPageControl *pageControl;
    AAPDFPageContentView *pdfContentView;
    AAPDFNoteContentView *noteContentView;
    
    NSUInteger currentPage;
    NSRange activePages;
}

@property (nonatomic, readonly) AAPDFPageContentView *pdfContentView;
@property (nonatomic, readonly) AAPDFNoteContentView *noteContentView;
@property (nonatomic, readonly) AAPageControl *pageControl;

@property (nonatomic) NSUInteger currentPage;
- (void)setCurrentPage:(NSUInteger)value animated:(BOOL)shouldAnimate;
@property (nonatomic, readonly) NSRange activePages;

//geometry
- (NSUInteger)pageIndexForPoint:(CGPoint)point;

@end
