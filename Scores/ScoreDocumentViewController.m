//
//  ScoreDocumentViewController.m
//  Scores
//
//  Created by Sasha Friedenberg on 8/1/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "ScoreDocumentViewController.h"

#import "ScoreDocument.h"
#import "Bookmark.h"

#import "BookmarkTableViewController.h"

#import "AAScorePDFView.h"
#import "AAPageControl.h"


@interface ScoreDocumentViewController () <BookmarkTableViewControllerDelegate, UIPopoverControllerDelegate>

- (void)calculatePageIndexBookmarks;
- (void)bookmarksButton:(id)sender;

@end

@implementation ScoreDocumentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil scoreDocument:(ScoreDocument *)someDocument
{
    if (self = [super initWithNibName:nibNameOrNil documentURL:[NSURL fileURLWithPath:someDocument.path]])
	{
        document = [someDocument retain];
        self.title = someDocument.title;
    }
	
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UIBarButtonItem *tableOfContentsItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(bookmarksButton:)];
    self.navigationItem.rightBarButtonItem = tableOfContentsItem;
    [tableOfContentsItem release];
    
    [self calculatePageIndexBookmarks];
}

- (void)calculatePageIndexBookmarks
{
    NSMutableIndexSet *bookmarkedIndexes = [NSMutableIndexSet new];
    
    for (NSNumber *pageIndexNumber in [document.markedObjects valueForKey:@"pageIndex"])
    {
        [bookmarkedIndexes addIndex:[pageIndexNumber unsignedIntegerValue]];
    }
    
    pdfView.pageControl.bookmarkedIndexes = [[bookmarkedIndexes copy] autorelease];
    
    [bookmarkedIndexes release];
}

- (void)bookmarksButton:(id)sender
{
    if (popoverController.isPopoverVisible)
    {
        [popoverController dismissPopoverAnimated:YES];
        return;
    }
    
	BookmarkTableViewController *bookmarksVC = [[BookmarkTableViewController alloc] initWithNibName:@"BookmarkTableViewController" scoreDocument:document];
	bookmarksVC.delegate = self;
	UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:bookmarksVC];
    
	if (!popoverController)
	{
		popoverController = [[UIPopoverController alloc] initWithContentViewController:navigationVC];
		popoverController.delegate = self;
	}
	
	[popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];

	[navigationVC release];
	[bookmarksVC release];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [popoverController dismissPopoverAnimated:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
	[popoverController release];
	popoverController = nil;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	
}

- (void)coreDataViewControllerDidSaveContext:(AACoreDataViewController *)someController
{
	
}

- (NSUInteger)indexOfCurrentDisplayedPageForBookmarkTableViewController:(BookmarkTableViewController *)someController
{
	return pdfView.pageIndex;
}

- (void)bookmarkTableViewController:(BookmarkTableViewController *)someController didSelectBookmark:(Bookmark *)someBookmark
{
    [pdfView setPageIndex:someBookmark.pageIndex animated:YES];
}

- (void)bookmarkTableViewControllerDidChangeBookmarks:(BookmarkTableViewController *)someController
{
    [self calculatePageIndexBookmarks];
}

- (void)dealloc
{
	[popoverController release];
	[document release];
	[super dealloc];
}

@end
