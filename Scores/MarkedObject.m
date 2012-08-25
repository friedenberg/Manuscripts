//
//  MarkedObject.m
//  Scores
//
//  Created by Sasha Friedenberg on 8/1/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "MarkedObject.h"


@implementation MarkedObject

@dynamic pageIndex;
@dynamic title;
@dynamic lastModified;
@dynamic scoreDocument;

- (void)didChangeValueForKey:(NSString *)key
{
    [super didChangeValueForKey:key];
    
    if (![key isEqualToString:@"lastModified"])
    {
        self.lastModified = [NSDate date];
    }
}

@end
