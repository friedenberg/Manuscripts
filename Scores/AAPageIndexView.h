//
//  AAPageIndexView.h
//  Scores
//
//  Created by Sasha Friedenberg on 7/30/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AAPageIndexView : UIControl
{
    CGFloat currentTrackingProgress;
	UIView *backgroundView;
}

@property (nonatomic) NSUInteger pageCount;
@property (nonatomic) NSUInteger currentPage;
@property (nonatomic, readonly) CGFloat currentTrackingProgress;

@end
