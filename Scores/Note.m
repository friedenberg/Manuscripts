//
//  Note.m
//  Scores
//
//  Created by Sasha Friedenberg on 8/28/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "Note.h"
#import "Page.h"


@implementation Note

@dynamic body;
@dynamic centerPointString;
@dynamic identifier;
@dynamic page;

- (CGPoint)centerPoint
{
    [self willAccessValueForKey:@"centerPoint"];
    CGPoint point = CGPointFromString(self.centerPointString);
    [self didAccessValueForKey:@"centerPoint"];
    return point;
}

- (void)setCenterPoint:(CGPoint)value
{
    [self willChangeValueForKey:@"centerPoint"];
    self.centerPointString = NSStringFromCGPoint(value);
    [self didChangeValueForKey:@"centerPoint"];
}

@end
