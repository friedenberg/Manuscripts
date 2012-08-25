//
//  UIView+UIViewAnimationAdditions.m
//  Scores
//
//  Created by Sasha Friedenberg on 8/5/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "UIView+UIViewAnimationAdditions.h"

@implementation UIView (UIViewAnimationAdditions)

- (void)layoutSubviewsAnimated:(BOOL)shouldAnimate
{
    [UIView animateWithDuration:(shouldAnimate ? 0.35 : 0) animations:^{
        
        [self layoutSubviews];
    }];
}

@end
