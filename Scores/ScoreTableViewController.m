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



@end

@implementation ScoreTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
		self.title = @"Scores";
    }
    
    return self;
}

- (void)modifyFetchRequest
{
    [self.fetchRequest setEntity:[NSEntityDescription entityForName:@"ScoreDocument" inManagedObjectContext:self.managedObjectContext]];
    [self.fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ScoreDocument *document = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSURL *docURL = [NSURL fileURLWithPath:[DocumentsDirectory() stringByAppendingPathComponent:document.path]];
    AAPDFCollectionViewController *pdfController = [[AAPDFCollectionViewController alloc] initWithDocumentURL:docURL];
    [self.navigationController pushViewController:pdfController animated:YES];
}


@end
