//
//  AAPDFView.h
//  Scores
//
//  Created by Sasha Friedenberg on 9/1/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AATilingScrollView.h"


@class AAPDFContentView, AAPageControl;

@interface AAPDFView : AATilingScrollView
{
    AAPageControl *pageControl;
    AAPDFContentView *pdfContentView;
    
    NSUInteger currentPage;
    NSRange activePages;
}

@property (nonatomic, readonly) AAPDFContentView *pdfContentView;
@property (nonatomic, readonly) AAPageControl *pageControl;

@property (nonatomic) NSUInteger currentPage;
- (void)setCurrentPage:(NSUInteger)value animated:(BOOL)shouldAnimate;
@property (nonatomic, readonly) NSRange activePages;

@end
