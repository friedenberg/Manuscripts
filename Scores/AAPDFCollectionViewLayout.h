//
//  AAPDFCollectionViewLayoutOneUp.h
//  Scores
//
//  Created by Sasha Friedenberg on 10/4/14.
//  Copyright (c) 2014 Apple, Stamford. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AAPDFCollectionViewLayout : UICollectionViewLayout
{
    CGRect _collectionViewBounds;
    CGSize _contentSize;
}

@property (nonatomic, assign) NSUInteger pageCount;

@end
