//
//  MarkedObject.h
//  Scores
//
//  Created by Sasha Friedenberg on 8/1/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MarkedObject : NSManagedObject

@property (nonatomic) int16_t pageIndex;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSManagedObject *scoreDocument;

@end
