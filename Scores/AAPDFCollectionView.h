//
//  AAPDFCollectionView.h
//  Scores
//
//  Created by Sasha Friedenberg on 10/4/14.
//  Copyright (c) 2014 Apple, Stamford. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AAPageControl;

@interface AAPDFCollectionView : UICollectionView

@property (nonatomic, readonly) AAPageControl *pageControl;

@end
