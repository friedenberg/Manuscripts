//
//  BookmarkTableViewViewController.m
//  Scores
//
//  Created by Sasha Friedenberg on 8/1/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "BookmarkTableViewController.h"

#import "AAEditableTableViewCell.h"
#import "AAEditableTableView.h"

#import "ScoreDocument.h"
#import "Page.h"
#import "Bookmark.h"


@interface BookmarkTableViewController () <AAEditableTableViewDelegate>

- (void)addBookmark:(UIBarButtonItem *)barButtonItem;

- (void)swipe:(UISwipeGestureRecognizer *)sender;

@end

@implementation BookmarkTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil scoreDocument:(ScoreDocument *)someDocument
{
    if (self = [super initWithNibName:nibNameOrNil managedObjectContext:[someDocument managedObjectContext]])
	{
        self.title = @"Bookmarks";
		document = [someDocument retain];
    }
	
    return self;
}

@dynamic delegate, tableView;

- (void)modifyFetchRequest
{
	[self.fetchRequest setEntity:[NSEntityDescription entityForName:@"Bookmark" inManagedObjectContext:managedObjectContext]];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"scoreDocument == %@", document];
	fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"pageIndex" ascending:YES],
									 [NSSortDescriptor sortDescriptorWithKey:@"indentationLevel" ascending:YES]];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
	UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
	rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
	rightSwipe.numberOfTouchesRequired = 1;
	
	UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
	leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
	leftSwipe.numberOfTouchesRequired = 1;
	
	[self.tableView addGestureRecognizer:rightSwipe];
	[self.tableView addGestureRecognizer:leftSwipe];
	
	[rightSwipe release];
	[leftSwipe release];
	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBookmark:)];
	self.navigationItem.rightBarButtonItem = addButton;
	[addButton release];
    
    self.navigationItem.leftBarButtonItem = fetchedResultsController.fetchedObjects.count ? self.editButtonItem : nil;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [super controllerDidChangeContent:controller];
    
    [self.navigationItem setLeftBarButtonItem:controller.fetchedObjects.count ? self.editButtonItem : nil animated:YES];
    
    [self.delegate bookmarkTableViewControllerDidChangeBookmarks:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.editing = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (AAEditableTableViewCell *)tableView:(UITableView *)someTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    AAEditableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[[AAEditableTableViewCell alloc] initWithSuperTable:self.tableView reuseIdentifier:CellIdentifier] autorelease];
    }
    
	Bookmark *bookmark = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
    cell.textField.text = bookmark.title;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", bookmark.page.index + 1];
	cell.indentationLevel =  bookmark.indentationLevel;
    
    return cell;
}

- (void)tableView:(AAEditableTableView *)someTableView didChangeContentOfCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *textFieldString = [[[someTableView cellForRowAtIndexPath:indexPath] textField] text];
    Bookmark *bookmark = [fetchedResultsController objectAtIndexPath:indexPath];
    
    [self performBlockWhileIgnoringFetchedResultControllerChanges:^{
        
        bookmark.title = textFieldString;
    }];
}

- (void)swipe:(UISwipeGestureRecognizer *)sender
{
	if (tableView.editing && sender.state == UIGestureRecognizerStateEnded)
	{
        CGPoint swipeLocation = [sender locationInView:self.tableView];
        NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
		AAEditableTableViewCell *cell = [self.tableView cellForRowAtIndexPath:swipedIndexPath];
        
        Bookmark *bookmark = [fetchedResultsController objectAtIndexPath:swipedIndexPath];
        NSInteger indentationLevel = bookmark.indentationLevel;
        
		[self performBlock:^{
			
			bookmark.indentationLevel = indentationLevel + (sender.direction == UISwipeGestureRecognizerDirectionRight ? 1 : -1);
			[cell setIndentationLevel:bookmark.indentationLevel animated:YES];
			
		} withTableViewRowAnimationStyle:UITableViewRowAnimationFade];
	}
}

- (void)addBookmark:(UIBarButtonItem *)barButtonItem
{
	NSUInteger currentIndex = [self.delegate indexOfCurrentDisplayedPageForBookmarkTableViewController:self];
	
	[self performBlock:^{
		
		Bookmark *bookmark = [NSEntityDescription insertNewObjectForEntityForName:@"Bookmark" inManagedObjectContext:managedObjectContext];
		bookmark.page = [document.pages objectAtIndex:currentIndex];
		bookmark.title = [NSString stringWithFormat:@"Page %i", currentIndex + 1];
		
		[self saveContext];
		
		[self setEditing:YES animated:YES];
		
		double delayInSeconds = 0.35;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^{
			
			NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:bookmark];
			AAEditableTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
			[cell.textField selectAll:nil];
			[cell.textField becomeFirstResponder];
		});
		
	} withTableViewRowAnimationStyle:UITableViewRowAnimationMiddle];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Bookmark *bookmark = [fetchedResultsController objectAtIndexPath:indexPath];
        
        [self performBlock:^{
            
            [managedObjectContext deleteObject:bookmark];
            [self saveContext];
            
        } withTableViewRowAnimationStyle:UITableViewRowAnimationLeft];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Bookmark *bookmark = [fetchedResultsController objectAtIndexPath:indexPath];
	[self.delegate bookmarkTableViewController:self didSelectBookmark:bookmark];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
