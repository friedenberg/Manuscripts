//
//  NSIndexSet+AAAdditions.m
//  Scores
//
//  Created by Sasha Friedenberg on 8/10/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "NSIndexSet+AAAdditions.h"

@implementation NSIndexSet (AAAdditions)

- (NSUInteger)indexNearestToIndex:(NSUInteger)index
{
	NSUInteger lowerIndex = [self indexLessThanOrEqualToIndex:index];
	if (lowerIndex == index)
		return lowerIndex;
	
	NSUInteger upperIndex = [self indexGreaterThanOrEqualToIndex:index];
	if (upperIndex == index)
		return upperIndex;
	
	NSUInteger lowerDifference = index - lowerIndex;
	NSUInteger upperDifference = upperIndex - index;
	
	if (lowerDifference >= upperDifference)
		return lowerIndex;
	else
		return upperIndex;
}

@end
