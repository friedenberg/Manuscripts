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
	
    UIView *progressView;
	UIView *dotContentView;
	
    CGRect dotContentRect;
    NSUInteger dotCount;
    NSMutableIndexSet *largeDotIndexes;
    NSUInteger highlightedDotIndex;
	
    NSDictionary *sections;
    NSIndexSet *bookmarkedIndexes;
	UIView *backgroundView;
}

@property (nonatomic) NSUInteger pageCount;
@property (nonatomic) NSUInteger currentPage;
@property (nonatomic, retain) NSIndexSet *bookmarkedIndexes;
@property (nonatomic, retain) NSDictionary *sections; //@{@[sectionStartIndex] : @"sectionTitle"}

- (CGPoint)centerForDotAtIndex:(NSUInteger)dotIndex;

- (NSUInteger)pageIndexForPoint:(CGPoint)point affinityForBookmarks:(BOOL)prefersBookmarks;

@end
