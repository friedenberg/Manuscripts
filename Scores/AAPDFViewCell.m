//
//  AAPDFViewCell.m
//  Scores
//
//  Created by Sasha Friedenberg on 10/4/14.
//  Copyright (c) 2014 Apple, Stamford. All rights reserved.
//

#import "AAPDFViewCell.h"

@implementation AAPDFViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] initWithFrame:frame];
        
        [self.contentView addSubview:_imageView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    self.imageView.frame = bounds;
}

@end
