//
//  Note.h
//  Scores
//
//  Created by Sasha Friedenberg on 8/25/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MarkedObject.h"


@interface Note : MarkedObject

@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString *identifier;

@end
