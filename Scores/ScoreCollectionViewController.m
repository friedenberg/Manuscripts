//
//  ScoreCollectionViewController.m
//  Scores
//
//  Created by Sasha Friedenberg on 7/22/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "ScoreCollectionViewController.h"
#import "ScoreAppDelegate.h"

#import "ScorePDFViewController.h"


@interface ScoreCollectionViewController ()



@end

@implementation ScoreCollectionViewController

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
	return YES;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)someTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    
    cell.textLabel.text = [[self.fetchedResultsController objectAtIndexPath:indexPath] title];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *fileURL = [NSURL fileURLWithPath:[[self.fetchedResultsController objectAtIndexPath:indexPath] path]];
    ScorePDFViewController *pdfController = [[ScorePDFViewController alloc] initWithNibName:@"ScorePDFViewController" documentURL:fileURL];
    [self.navigationController pushViewController:pdfController animated:YES];
    [pdfController release];
}

- (void)dealloc
{
    [super dealloc];
}

@end
