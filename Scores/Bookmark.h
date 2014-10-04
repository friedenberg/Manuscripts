//
//  Bookmark.h
//  Scores
//
//  Created by Sasha Friedenberg on 8/28/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MarkedObject.h"

@class Page;

@interface Bookmark : MarkedObject

@property (nonatomic) int16_t indentationLevel;
@property (nonatomic, strong) Page *page;

@end
