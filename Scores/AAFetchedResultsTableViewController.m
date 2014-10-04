//
//  AAFetchedResultsTableViewController.m
//  Dispatch
//
//  Created by Sasha Friedenberg on 1/25/11.
//  Copyright 2011 Anodized Apps, LLC. All rights reserved.
//

#import "AAFetchedResultsTableViewController.h"


@interface AAFetchedResultsTableViewController ()

@property (nonatomic, readwrite) IBOutlet UITableView *tableView;

@end

@implementation AAFetchedResultsTableViewController

@synthesize tableView;

- (void)loadView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.view = self.tableView;
}

- (void)viewWillAppear:(BOOL)animated 
{
	currentStyle = -1;
    [super viewWillAppear:animated];
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.tableView flashScrollIndicators];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	
	UITableView *aTableView = self.tableView;
	
	[aTableView setEditing:editing animated:animated];
}

#pragma mark -
#pragma mark Table view data source

- (NSIndexPath *)fetchedResultsControllerIndexPathFromIndexPath:(NSIndexPath *)indexPath
{
	return indexPath;
}

- (NSIndexPath *)tableViewIndexPathFromIndexPath:(NSIndexPath *)indexPath
{
	return indexPath;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [[fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section 
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	abort();
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (void)tableView:(UITableView *)aTableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath 
{
	assert(aTableView == self.tableView);
    
    [self performBlockWhileIgnoringFetchedResultControllerChanges:^{
        
        [self.managedObjectContext processPendingChanges];
    }];
}

- (void)performBlock:(dispatch_block_t)block withTableViewRowAnimationStyle:(UITableViewRowAnimation)style
{
	currentStyle = style;
	block();
	currentStyle = -1;
}

- (void)performBlockWhileIgnoringFetchedResultControllerChanges:(dispatch_block_t)block
{
    shouldIgnoreFetchedResultControllerEvents = YES;
    block();
    [managedObjectContext processPendingChanges];
    shouldIgnoreFetchedResultControllerEvents = NO;
}

#pragma mark -
#pragma mark Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	if (shouldIgnoreFetchedResultControllerEvents) return;
    
	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller 
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex 
	 forChangeType:(NSFetchedResultsChangeType)type
{
    if (shouldIgnoreFetchedResultControllerEvents) @throw [NSException exceptionWithName:NSGenericException reason:@"section was added or removed while ignoring fetched result controller events" userInfo:nil];
    
	switch (type) 
	{
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller 
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath 
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
	if (shouldIgnoreFetchedResultControllerEvents)
	{
		
		
		return;
	}
	
	UITableView *someTableView = self.tableView;
	NSIndexPath *newIP = [self tableViewIndexPathFromIndexPath:newIndexPath];
	NSIndexPath *oldIP = [self tableViewIndexPathFromIndexPath:indexPath];
	
	switch (type) 
	{	
		case NSFetchedResultsChangeInsert:
			[someTableView insertRowsAtIndexPaths:@[newIP] withRowAnimation:currentStyle ?: UITableViewRowAnimationTop];
			break;
			
		case NSFetchedResultsChangeDelete:
			[someTableView deleteRowsAtIndexPaths:@[oldIP] withRowAnimation:currentStyle ?: UITableViewRowAnimationLeft];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[someTableView reloadRowsAtIndexPaths:@[oldIP] withRowAnimation:currentStyle ?: UITableViewRowAnimationNone];
			break;
			
		case NSFetchedResultsChangeMove:
			[someTableView moveRowAtIndexPath:oldIP toIndexPath:newIP];
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller 
{
	if (shouldIgnoreFetchedResultControllerEvents) return;
    
	[self.tableView endUpdates];
}

@end

