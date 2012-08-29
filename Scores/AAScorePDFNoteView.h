//
//  AAScorePDFNoteView.h
//  Scores
//
//  Created by Sasha Friedenberg on 8/25/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface AAScorePDFNoteView : UIView
{
    UILabel *textLabel;
    BOOL dragging;
}

@property (nonatomic, readonly) UILabel *textLabel;

@property (nonatomic, getter = isDragging) BOOL dragging;

- (void)startDragAsNewView;
- (void)startDragAsExistingView;
- (void)endDrag;

@end
