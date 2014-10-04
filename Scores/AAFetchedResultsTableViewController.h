//
//  AAFetchedResultsTableViewController.h
//  Dispatch
//
//  Created by Sasha Friedenberg on 1/25/11.
//  Copyright 2011 Anodized Apps, LLC. All rights reserved.
//

#import "AAFetchedResultsViewController.h"


@interface AAFetchedResultsTableViewController : AAFetchedResultsViewController <UITableViewDataSource, UITableViewDelegate>
{
    BOOL shouldIgnoreFetchedResultControllerEvents;
    
	UITableViewRowAnimation currentStyle;
}

@property (strong, nonatomic, readonly) IBOutlet UITableView *tableView;

- (void)performBlockWhileIgnoringFetchedResultControllerChanges:(dispatch_block_t)block;
- (void)performBlock:(dispatch_block_t)block withTableViewRowAnimationStyle:(UITableViewRowAnimation)style;

- (NSIndexPath *)fetchedResultsControllerIndexPathFromIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)tableViewIndexPathFromIndexPath:(NSIndexPath *)indexPath;

@end