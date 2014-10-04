//
//  AAPageIndexView.h
//  Scores
//
//  Created by Sasha Friedenberg on 7/30/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AAViewRecycler;

@interface AAPageControl : UIControl
{
	AAViewRecycler *dotRecycler;
	
    BOOL isScrubbing;
    
    UIView *progressView;
	UIView *dotContentView;
	
    CGRect dotContentRect;
    NSUInteger dotCount;
    NSMutableIndexSet *largeDotIndexes;
    NSUInteger highlightedDotIndex;
    
    NSInteger currentPageIndexAtStartOfScrubbing;
	
    NSDictionary *sections;
    NSIndexSet *bookmarkedIndexes;
	UIView *backgroundView;
}

@property (nonatomic) NSUInteger pageCount;
@property (nonatomic) NSUInteger currentPage;
@property (nonatomic, strong) NSIndexSet *bookmarkedIndexes;
@property (nonatomic, strong) NSDictionary *sections; //@{@[sectionStartIndex] : @"sectionTitle"}

@property (nonatomic, readonly) BOOL isScrubbing;

- (CGPoint)centerForDotAtIndex:(NSUInteger)dotIndex;

- (NSUInteger)pageIndexForPoint:(CGPoint)point prefersBookmarks:(BOOL)prefersBookmarks;

@end
