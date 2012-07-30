//
//  ScorePDFViewController.h
//  Scores
//
//  Created by Sasha Friedenberg on 7/28/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AAScorePDFView;

@interface ScorePDFViewController : UIViewController
{
    IBOutlet AAScorePDFView *pdfView;
    NSURL *documentURL;
}

- (id)initWithNibName:(NSString *)nibNameOrNil documentURL:(NSURL *)someURL;

@end
