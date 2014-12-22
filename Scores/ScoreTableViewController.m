//
//  ScoreCollectionViewController.m
//  Scores
//
//  Created by Sasha Friedenberg on 7/22/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "ScoreTableViewController.h"
#import "ScoreAppDelegate.h"

#import "AAPDFCollectionViewController.h"

#import "ScoreDocument.h"


@interface ScoreTableViewController ()

@property (nonatomic) NSIndexPath *indexPathForCurrentlyEditingRow;
- (void)longPress:(UILongPressGestureRecognizer *)gesture;

@end

@implementation ScoreTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
		self.title = @"Manuscripts";
    }
    
    return self;
}

- (void)modifyFetchRequest
{
    [self.fetchRequest setEntity:[NSEntityDescription entityForName:@"ScoreDocument" inManagedObjectContext:self.managedObjectContext]];
    [self.fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.tableView addGestureRecognizer:gesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)someTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [someTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell.textLabel.text = [[self.fetchedResultsController objectAtIndexPath:indexPath] title];
    
    return cell;
}

- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
    CGPoint p = [gesture locationInView:self.tableView];
    
    self.indexPathForCurrentlyEditingRow = [self.tableView indexPathForRowAtPoint:p];
    
    if (!self.indexPathForCurrentlyEditingRow) {
        NSLog(@"long press on table view but not on a row");
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        ScoreDocument *doc = [self.fetchedResultsController objectAtIndexPath:self.indexPathForCurrentlyEditingRow];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Edit Title" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Done", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [[alert textFieldAtIndex:0] setText:doc.title];
        [alert show];
        [[alert textFieldAtIndex:0]  selectAll:nil];
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    ScoreDocument *doc = [self.fetchedResultsController objectAtIndexPath:self.indexPathForCurrentlyEditingRow];
    doc.title = [[alertView textFieldAtIndex:0] text];
    [self saveContext];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ScoreDocument *document = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSURL *docURL = [NSURL fileURLWithPath:[DocumentsDirectory() stringByAppendingPathComponent:document.path]];
    AAPDFCollectionViewController *pdfController = [[AAPDFCollectionViewController alloc] initWithDocumentURL:docURL];
    [self.navigationController pushViewController:pdfController animated:YES];
}

@end
