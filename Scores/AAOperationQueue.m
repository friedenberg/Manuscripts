//
//  AAOperationQueue.m
//  Scores
//
//  Created by Sasha Friedenberg on 8/7/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AAOperationQueue.h"

@implementation AAOperationQueue

@synthesize operationCountLimit;

- (void)addOperation:(NSOperation *)operation
{
	[super addOperation:operation];
	
	NSArray *operations = [self operations];
	NSInteger invalidOperationCount = operations.count - operationCountLimit;
	
	if (invalidOperationCount > 0)
	{
		NSArray *invalidOperations = [operations subarrayWithRange:NSMakeRange(0, invalidOperationCount)];
		[invalidOperations makeObjectsPerformSelector:@selector(cancel)];
	}
}

@end
