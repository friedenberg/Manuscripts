//
//  Bookmark.h
//  Scores
//
//  Created by Sasha Friedenberg on 8/7/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MarkedObject.h"


@interface Bookmark : MarkedObject

@property (nonatomic) int16_t indentationLevel;

@end
