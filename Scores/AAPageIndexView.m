//
//  AAPageIndexView.m
//  Scores
//
//  Created by Sasha Friedenberg on 7/30/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AAPageIndexView.h"

@implementation AAPageIndexView

static CGFloat kStandardCapDiameter = 28;
static UIImage *backgroundImage;

+ (void)initialize
{
    if (self == [AAPageIndexView class])
    {
        CGRect bounds = CGRectMake(0, 0, kStandardCapDiameter + 1, kStandardCapDiameter);
        UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0);
        
        [[UIColor colorWithWhite:0.5 alpha:0.5] setFill];
        [[UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:kStandardCapDiameter / 2] fill];
        
        backgroundImage = [[UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsMake(0, kStandardCapDiameter / 2, 0, kStandardCapDiameter / 2)] retain];
        
        UIGraphicsEndImageContext();
    }
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
	{
        currentTrackingProgress = -1;
        self.backgroundColor = [UIColor clearColor];
        backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        backgroundView.hidden = YES;
        backgroundView.opaque = NO;
        [self addSubview:backgroundView];
    }
	
    return self;
}

@synthesize pageCount, currentPage, currentTrackingProgress;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    backgroundView.hidden = NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    backgroundView.hidden = YES;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    backgroundView.hidden = YES;
}

- (void)layoutSubviews
{
    backgroundView.frame = self.bounds;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    size.height = kStandardCapDiameter;
    return size;
}

static CGFloat kDotDiameter = 4;
static CGFloat kInterdotSpacing = 8;

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect bounds = self.bounds;
    
    CGRect contentBounds = bounds;
    contentBounds.origin.x += kStandardCapDiameter / 2;
    contentBounds.size.width -= kStandardCapDiameter;
	
	NSUInteger pointCount = (NSUInteger)floor(contentBounds.size.width / (kDotDiameter + kInterdotSpacing));
    CGFloat dotIndexWidth = pointCount * (kDotDiameter + kInterdotSpacing);
    CGFloat dotIndexLeftPadding = (contentBounds.size.width - dotIndexWidth) / 2;
    
    CGFloat dotY = floor(CGRectGetMidY(contentBounds) - kDotDiameter / 2);
    
    [[UIColor colorWithWhite:0.6 alpha:1] setFill];
	
    for (int i = 0; i < pointCount; i++)
    {
        CGRect dotRect = contentBounds;
        dotRect.origin.x += floor((i * (kDotDiameter + kInterdotSpacing)) + dotIndexLeftPadding);
        dotRect.origin.y = dotY;
        dotRect.size.width = kDotDiameter;
        dotRect.size.height = kDotDiameter;
        
        CGContextFillEllipseInRect(context, dotRect);
    }
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGFloat xOrigin = [touch locationInView:self].x;
    currentTrackingProgress = xOrigin / self.bounds.size.width;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGFloat xOrigin = [touch locationInView:self].x;
    currentTrackingProgress = xOrigin / self.bounds.size.width;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGFloat xOrigin = [touch locationInView:self].x;
    currentTrackingProgress = xOrigin / self.bounds.size.width;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    currentTrackingProgress = -1;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    currentTrackingProgress = -1;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)dealloc
{
    [backgroundView release];
    [super dealloc];
}

@end
