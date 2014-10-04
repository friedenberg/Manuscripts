//
//  Note.h
//  Scores
//
//  Created by Sasha Friedenberg on 8/28/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MarkedObject.h"

@class Page;

@interface Note : MarkedObject

@property (nonatomic, strong) NSString * body;
@property (nonatomic, strong) NSString * centerPointString;
@property (nonatomic, strong) NSString * identifier;
@property (nonatomic, strong) Page *page;

@property (nonatomic) CGPoint centerPoint;

@end
