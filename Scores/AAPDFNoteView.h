//
//  AAPDFNoteView.h
//  Scores
//
//  Created by Sasha Friedenberg on 9/5/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface AAPDFNoteView : UIView
{
    UILabel *textLabel;
    BOOL editing;
    BOOL dragging;
}

@property (weak, nonatomic, readonly) UILabel *textLabel;

@property (nonatomic, getter = isEditing) BOOL editing;

@property (nonatomic, getter = isDragging) BOOL dragging;

- (void)startDragAsNewView;
- (void)startDragAsExistingView;
- (void)endDrag;

@end
