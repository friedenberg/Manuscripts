//
//  AAAppDelegate.h
//  Scores
//
//  Created by Sasha Friedenberg on 7/22/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *DocumentsDirectory();

@class ScoreCollectionViewController;

@interface AAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ScoreCollectionViewController *viewController;

@end
