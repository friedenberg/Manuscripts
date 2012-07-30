//
//  AAScorePDFPageView.h
//  Scores
//
//  Created by Sasha Friedenberg on 7/24/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "AAViewRecyclerDelegate.h"


@interface AAScorePDFPageView : UIView <AAViewRecycling>
{
    CGPDFPageRef pdfPage;
}

@property (nonatomic, assign) CGPDFPageRef pdfPage;

@end
