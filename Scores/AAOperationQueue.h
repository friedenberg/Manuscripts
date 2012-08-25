//
//  AAOperationQueue.h
//  Scores
//
//  Created by Sasha Friedenberg on 8/7/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AAOperationQueue : NSOperationQueue
{
	NSUInteger operationCountLimit;
}

@property (nonatomic) NSUInteger operationCountLimit; //if an operation is added that exceed this limit, operations are cancelled from the top of the cue

@end
