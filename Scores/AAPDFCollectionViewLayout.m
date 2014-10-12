//
//  AAPDFCollectionViewLayoutOneUp.m
//  Scores
//
//  Created by Sasha Friedenberg on 10/4/14.
//  Copyright (c) 2014 Apple, Stamford. All rights reserved.
//

#import "AAPDFCollectionViewLayout.h"

@implementation AAPDFCollectionViewLayout

- (void)setPageCount:(NSUInteger)pageCount
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(pageCount))];
    _pageCount = pageCount;
    [self didChangeValueForKey:NSStringFromSelector(@selector(pageCount))];
    [self invalidateLayout];
}

- (void)prepareLayout
{
    _collectionViewBounds = self.collectionView.bounds;
    _contentSize.height = _collectionViewBounds.size.height;
    _contentSize.width = _collectionViewBounds.size.width * _pageCount;
}

- (CGSize)collectionViewContentSize
{
    return _contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    CGFloat minX = CGRectGetMinX(rect);
    CGFloat maxX = CGRectGetMaxX(rect);
    CGFloat start = minX / _collectionViewBounds.size.width;
    CGFloat end = maxX / _collectionViewBounds.size.width;
    NSUInteger startingPage = (NSUInteger)start;
    NSUInteger endingPage = MIN((NSUInteger)end, _pageCount - 1);
    
    NSMutableArray *pages = [NSMutableArray new];
    
    for (int i = startingPage; i <= endingPage; i++) {
        [pages addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]]];
    }
    
    return pages.copy;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(indexPath.section == 0, @"section index must be 0");
    
    NSInteger row = indexPath.item;
    CGRect frame = _collectionViewBounds;
    frame.origin.x = row * _collectionViewBounds.size.width;
    
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = frame;
    
    return attributes;
}

@end
