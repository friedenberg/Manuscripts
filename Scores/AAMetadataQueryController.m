//
//  AAMetadataQueryResultController.m
//  Scores
//
//  Created by Sasha Friedenberg on 7/22/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AAMetadataQueryController.h"

@interface AAMetadataQueryController ()

- (void)queryDidStart:(NSNotification *)someNotification;
- (void)queryDidUpdate:(NSNotification *)someNotification;
- (void)queryDidFinish:(NSNotification *)someNotification;

@end

@implementation AAMetadataQueryController

- (id)initWithMetadataQuery:(NSMetadataQuery *)someQuery
{
    if (self = [super init])
    {
        results = [NSMutableArray new];
        self.metadataQuery = someQuery;
    }
    
    return self;
}

@synthesize metadataQuery, delegate;

- (void)setMetadataQuery:(NSMetadataQuery *)value
{
    NSMetadataQuery *oldQuery = metadataQuery;
    metadataQuery = value;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:NSMetadataQueryDidStartGatheringNotification object:oldQuery];
    [nc removeObserver:self name:NSMetadataQueryDidUpdateNotification object:oldQuery];
    [nc removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:oldQuery];
    
    [nc addObserver:self selector:@selector(queryDidStart:) name:NSMetadataQueryDidStartGatheringNotification object:metadataQuery];
    [nc addObserver:self selector:@selector(queryDidUpdate:) name:NSMetadataQueryDidUpdateNotification object:metadataQuery];
    [nc addObserver:self selector:@selector(queryDidFinish:) name:NSMetadataQueryDidFinishGatheringNotification object:metadataQuery];
}

- (void)setDelegate:(id <AAMetadataQueryControllerDelegate>)value
{
    delegate = value;
    delegateFlags.willChangeResults = [delegate respondsToSelector:@selector(controllerWillChangeContent:)];
    delegateFlags.didChangeObject = [delegate respondsToSelector:@selector(controller:didChangeObject:atIndex:forChangeType:newIndex:)];
    delegateFlags.didChangeResults = [delegate respondsToSelector:@selector(controllerDidChangeResults:)];
}

- (void)performQuery
{
    [metadataQuery startQuery];
}

- (void)queryDidStart:(NSNotification *)someNotification
{
    if (delegateFlags.willChangeResults)
        [delegate controllerWillChangeResults:self];
}

- (void)queryDidUpdate:(NSNotification *)someNotification
{
    
}

- (void)queryDidFinish:(NSNotification *)someNotification
{
    if (delegateFlags.didChangeResults)
        [delegate controllerDidChangeResults:self];
}
     
- (void)dealloc
{
    self.metadataQuery = nil;
}

@end
