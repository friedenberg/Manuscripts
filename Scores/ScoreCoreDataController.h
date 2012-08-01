//
//  ScoreCoreDataController.h
//  Scores
//
//  Created by Sasha Friedenberg on 8/1/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AACoreDataController.h"

@interface ScoreCoreDataController : AACoreDataController

- (void)addScoreDocumentFromFileURL:(NSURL *)documentURL;

@end
