//
//  AAAppDelegate.m
//  Scores
//
//  Created by Sasha Friedenberg on 7/22/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "ScoreAppDelegate.h"

#import "ScoreCollectionViewController.h"

#import "ScorePDFViewController.h"


@implementation ScoreAppDelegate

@synthesize window, viewController;

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [coreDataController addScoreDocumentFromFileURL:url];
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    //navigationBar.barStyle = UIBarStyleBlackTranslucent;
    navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor darkTextColor], UITextAttributeTextShadowColor : [UIColor lightTextColor]};
    [navigationBar setBackgroundImage:[UIImage imageNamed:@"clearImage"] forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *barButtonItem = [UIBarButtonItem appearance];
    barButtonItem.tintColor = [UIColor grayColor];
    barButtonItem.tintColor = [UIColor grayColor];
    
    coreDataController = [ScoreCoreDataController new];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor whiteColor];
    self.viewController = [[[ScoreCollectionViewController alloc] initWithNibName:@"ScoreCollectionViewController" managedObjectContext:coreDataController.managedObjectContext] autorelease];
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:self.viewController] autorelease];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)dealloc
{
    [coreDataController release];
    [window release];
    [viewController release];
    [super dealloc];
}

@end