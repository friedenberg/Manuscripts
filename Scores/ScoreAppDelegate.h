//
//  AAAppDelegate.h
//  Scores
//
//  Created by Sasha Friedenberg on 7/22/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScoreCoreDataController.h"


@class ScoreTableViewController;

@interface ScoreAppDelegate : UIResponder <UIApplicationDelegate>
{
    ScoreCoreDataController *coreDataController;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ScoreTableViewController *viewController;

@end
