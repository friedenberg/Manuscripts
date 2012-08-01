//
//  ScoreCollectionViewController.m
//  Scores
//
//  Created by Sasha Friedenberg on 7/22/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "ScoreCollectionViewController.h"
#import "AAAppDelegate.h"

#import "ScorePDFViewController.h"


@interface ScoreCollectionViewController ()



@end

@implementation ScoreCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        documents = [NSMutableArray new];
		self.title = @"Scores";
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSArray *localDocuments = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:DocumentsDirectory() error:NULL];

    for (NSString *document in localDocuments)
    {
        //NSURL *fileURL = [NSURL fileURLWithPath:document];
        //UIManagedDocument *managedDocument = [[UIManagedDocument alloc] initWithFileURL:fileURL];
        [documents addObject:document];
        //[managedDocument release];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return documents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    
    cell.textLabel.text = [documents objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *fileURL = [NSURL fileURLWithPath:[DocumentsDirectory() stringByAppendingPathComponent:[documents objectAtIndex:indexPath.row]]];
    ScorePDFViewController *pdfController = [[ScorePDFViewController alloc] initWithNibName:@"ScorePDFViewController" documentURL:fileURL];
    [self.navigationController pushViewController:pdfController animated:YES];
    [pdfController release];
}

- (void)dealloc
{
    [documents release];
    [super dealloc];
}

@end
