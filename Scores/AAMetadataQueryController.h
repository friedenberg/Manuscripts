//
//  AAMetadataQueryResultController.h
//  Scores
//
//  Created by Sasha Friedenberg on 7/22/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AAMetadataQueryControllerDelegate.h"


@interface AAMetadataQueryController : NSObject
{
    NSMetadataQuery *metadataQuery;
    id <AAMetadataQueryControllerDelegate> __weak delegate;
    NSMutableArray *results;
    
    struct
    {
        unsigned int willChangeResults:1;
        unsigned int didChangeObject:1;
        unsigned int didChangeResults:1;
        
    } delegateFlags;
}

//initialization
- (id)initWithMetadataQuery:(NSMetadataQuery *)someQuery;
- (void)performQuery;

//configuration
@property (nonatomic, strong) NSMetadataQuery *metadataQuery;
@property (nonatomic, weak) id <AAMetadataQueryControllerDelegate> delegate;


@end
