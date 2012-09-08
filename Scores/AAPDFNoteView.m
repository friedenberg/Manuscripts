//
//  AAPDFNoteView.m
//  Scores
//
//  Created by Sasha Friedenberg on 9/5/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AAPDFNoteView.h"

@implementation AAPDFNoteView


- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor yellowColor];
        textLabel = [UILabel new];
        textLabel.backgroundColor = [UIColor yellowColor];
        //[self addSubview:textLabel];
        
        CALayer *layer = self.layer;
        layer.shadowColor = [UIColor blackColor].CGColor;
        layer.shadowOpacity = 1.0;
        layer.shadowRadius = 5;
        layer.shadowOffset = CGSizeMake(0, 3);
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    textLabel.frame = CGRectInset(bounds, 10, 10);
}

@synthesize dragging, editing;

static CGFloat kDraggingOpacity = 0.7;
static CGFloat kDraggingScale = 1.2;

- (void)setDragging:(BOOL)value
{
    if (dragging != value)
    {
        dragging = value;
        
        CALayer *layer = self.layer;
        
        if (dragging)
        {
            layer.transform = CATransform3DMakeScale(kDraggingScale, kDraggingScale, 1);
            layer.opacity = kDraggingOpacity;
        }
        else
        {
            layer.transform = CATransform3DMakeScale(1, 1, 1);
            layer.opacity = 1;
        }
    }
}

- (void)setEditing:(BOOL)value
{
    [self willChangeValueForKey:@"editing"];
    editing = value;
    [self didChangeValueForKey:@"editing"];
    
    if (editing)
    {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        
        CGFloat wobbleAngle = 0.06f;
        
        NSValue *valLeft = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(wobbleAngle, 0.0f, 0.0f, 1.0f)];
        NSValue *valRight = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(-wobbleAngle, 0.0f, 0.0f, 1.0f)];
        animation.values = [NSArray arrayWithObjects:valLeft, valRight, nil];
        
        animation.autoreverses = YES;
        animation.duration = 0.125;
        animation.repeatCount = HUGE_VALF;
        
        [self.layer addAnimation:animation forKey:@"wiggle"];
    }
    else
    {
        [self.layer removeAnimationForKey:@"wiggle"];
    }
}

- (void)startDragAsNewView
{
    static NSTimeInterval kStartDragNewAnimationDuration = 0.35;
    
    self.dragging = YES;
    
    CAKeyframeAnimation *alphaAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 1)],
    [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.4, 1.4, 1)],
    [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1)],
    [NSValue valueWithCATransform3D:CATransform3DMakeScale(kDraggingScale, kDraggingScale, 1)]];
    
    popAnimation.keyTimes = @[@0.0, @0.5, @0.9, @1.0];
    
    alphaAnimation.values = @[@1, @(kDraggingOpacity)];
    alphaAnimation.keyTimes = @[@0, @1];
    
    alphaAnimation.fillMode = kCAFillModeForwards;
    alphaAnimation.removedOnCompletion = YES;
    alphaAnimation.duration = kStartDragNewAnimationDuration;
    
    popAnimation.fillMode = kCAFillModeForwards;
    popAnimation.removedOnCompletion = YES;
    popAnimation.duration = kStartDragNewAnimationDuration;
    
    //popAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CAAnimationGroup *animations = [CAAnimationGroup animation];
    animations.animations = @[alphaAnimation, popAnimation];
    animations.duration = kStartDragNewAnimationDuration;
    
    [self.layer addAnimation:animations forKey:@"beginDrag"];
}

- (void)startDragAsExistingView
{
    static NSTimeInterval kStartDragExistingAnimationDuration = 0.2;
    
    self.dragging = YES;
    
    CAKeyframeAnimation *alphaAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)],
    [NSValue valueWithCATransform3D:CATransform3DMakeScale(kDraggingScale, kDraggingScale, 1)]];
    
    popAnimation.keyTimes = @[@0.0, @1.0];
    
    alphaAnimation.values = @[@1, @(kDraggingOpacity)];
    alphaAnimation.keyTimes = @[@0, @1];
    
    alphaAnimation.fillMode = kCAFillModeForwards;
    alphaAnimation.removedOnCompletion = YES;
    alphaAnimation.duration = kStartDragExistingAnimationDuration;
    
    popAnimation.fillMode = kCAFillModeForwards;
    popAnimation.removedOnCompletion = YES;
    popAnimation.duration = kStartDragExistingAnimationDuration;
    
    //popAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CAAnimationGroup *animations = [CAAnimationGroup animation];
    animations.animations = @[alphaAnimation, popAnimation];
    animations.duration = kStartDragExistingAnimationDuration;
    
    [self.layer addAnimation:animations forKey:@"beginDrag"];
}

- (void)endDrag
{
    static NSTimeInterval kEndDragAnimationDuration = 0.2;
    
    self.dragging = NO;
    
    CAKeyframeAnimation *fadeIn = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    CAKeyframeAnimation *shrink = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    shrink.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(kDraggingScale, kDraggingScale, 1)],
    [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)]];
    
    shrink.keyTimes = @[@0.0, @1.0];
    
    shrink.fillMode = kCAFillModeForwards;
    shrink.removedOnCompletion = YES;
    shrink.duration = kEndDragAnimationDuration;
    
    //shrink.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CAAnimationGroup *animations = [CAAnimationGroup animation];
    animations.animations = @[fadeIn, shrink];
    animations.duration = kEndDragAnimationDuration;
    
    [self.layer addAnimation:animations forKey:@"endDrag"];
}

- (void)dealloc
{
    [textLabel release];
    [super dealloc];
}



@end
