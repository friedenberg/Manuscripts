//
//  AAPDFCollectionView.m
//  Scores
//
//  Created by Sasha Friedenberg on 10/4/14.
//  Copyright (c) 2014 Apple, Stamford. All rights reserved.
//

#import "AAPDFCollectionView.h"

#import "AAPDFCollectionViewLayout.h"
#import "AAPageControl.h"


@interface AAPDFCollectionView ()

- (void)pageControlPageChanged:(id)sender;

@end

@implementation AAPDFCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        self.backgroundColor = [UIColor grayColor];
        _pageControl = [AAPageControl new];
        [_pageControl addTarget:self action:@selector(pageControlPageChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_pageControl];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    CGSize contentSize = self.contentSize;
    CGPoint contentOffset = self.contentOffset;
    CGRect visibleBounds = CGRectZero;
    visibleBounds.origin = contentOffset;
    visibleBounds.size = bounds.size;
    
    [_pageControl sizeToFit];
    CGRect pageControlFrame = _pageControl.frame;
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
    
    _pageControl.frame = pageControlFrame;
    
    CGFloat contentOffsetX = MAX(0, MIN(self.contentOffset.x, self.contentSize.width));
    NSUInteger currentPage = (NSUInteger)floor(contentOffsetX / self.bounds.size.width);
    
    _pageControl.currentPage = currentPage;
}

- (void)scrollToPage:(NSUInteger)someIndex animated:(BOOL)animated
{
    if (someIndex > [self.dataSource collectionView:self numberOfItemsInSection:0] - 1) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"index of page is outside bounds" userInfo:nil];
    }
    
    [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:someIndex inSection:0]
                 atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                         animated:animated];
}

- (void)pageControlPageChanged:(id)sender
{
    NSUInteger newPage = self.pageControl.currentPage;
    
    [self scrollToPage:newPage animated:NO];
}

@end
