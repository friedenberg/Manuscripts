//
//  ScoreDocumentViewController.m
//  Scores
//
//  Created by Sasha Friedenberg on 8/1/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "ScoreDocumentViewController.h"

#import "ScoreDocument.h"
#import "Page.h"
#import "Bookmark.h"
#import "Note.h"

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
    
    pdfView.noteDataSource = self;
}

- (void)calculatePageIndexBookmarks
{
    NSMutableIndexSet *bookmarkedIndexes = [NSMutableIndexSet new];
    
    for (Page *page in document.pages)
    {
        if (page.bookmarks.count)
        {
            [bookmarkedIndexes addIndex:page.index];
        }
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
    [pdfView setPageIndex:someBookmark.page.index animated:YES];
}

- (void)bookmarkTableViewControllerDidChangeBookmarks:(BookmarkTableViewController *)someController
{
    [self calculatePageIndexBookmarks];
}

#pragma mark - note data source

- (NSUInteger)numberOfNotesAtPageIndex:(NSUInteger)pageIndex scorePDFView:(AAScorePDFView *)someScorePDFView
{
    return [[[document.pages objectAtIndex:pageIndex] notes] count];
}

- (NSString *)bodyForNoteAtIndexPath:(NSIndexPath *)noteIndexPath scorePDFView:(AAScorePDFView *)someScorePDFView
{
    return [[[[document.pages objectAtIndex:noteIndexPath.section] notes] objectAtIndex:noteIndexPath.row] body];
}

- (CGPoint)centerPointForNoteAtIndexPath:(NSIndexPath *)noteIndexPath scorePDFView:(AAScorePDFView *)someScorePDFView
{
    return [[[[document.pages objectAtIndex:noteIndexPath.section] notes] objectAtIndex:noteIndexPath.row] centerPoint];
}

- (void)setCenterPoint:(CGPoint)noteCenterPoint indexPath:(NSIndexPath *)noteIndexPath scorePDFView:(AAScorePDFView *)someScorePDFView
{
    [[[[document.pages objectAtIndex:noteIndexPath.section] notes] objectAtIndex:noteIndexPath.row] setCenterPoint:noteCenterPoint];
}

- (void)scorePDFView:(AAScorePDFView *)someScorePDFView didMoveNoteWithIndexPathToFront:(NSIndexPath *)indexPath
{
    
}

- (NSIndexPath *)addNoteWithCenterPoint:(CGPoint)newNoteCenter pageIndex:(NSUInteger)pageIndex scorePDFView:(AAScorePDFView *)someScorePDFView
{
    Note *newNote = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:document.managedObjectContext];
    newNote.centerPoint = newNoteCenter;
    Page *page = [document.pages objectAtIndex:pageIndex];
    newNote.page = page;
    //[page addNotesObject:newNote];
    
    return [NSIndexPath indexPathForRow:page.notes.count - 1 inSection:pageIndex];
}

- (void)dealloc
{
	[popoverController release];
	[document release];
	[super dealloc];
}

@end
