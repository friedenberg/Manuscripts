//
//  BookmarkTableViewViewController.h
//  Scores
//
//  Created by Sasha Friedenberg on 8/1/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AAFetchedResultsTableViewController.h"
#import "AAEditableTableView.h"


@class ScoreDocument, Bookmark, BookmarkTableViewController;

@protocol BookmarkTableViewControllerDelegate <AACoreDataViewControllerDelegate>

- (NSUInteger)indexOfCurrentDisplayedPageForBookmarkTableViewController:(BookmarkTableViewController *)someController;
- (void)bookmarkTableViewController:(BookmarkTableViewController *)someController didSelectBookmark:(Bookmark *)someBookmark;
- (void)bookmarkTableViewControllerDidChangeBookmarks:(BookmarkTableViewController *)someController;

@end

@interface BookmarkTableViewController : AAFetchedResultsTableViewController
{
	ScoreDocument *document;
}

- (id)initWithNibName:(NSString *)nibNameOrNil scoreDocument:(ScoreDocument *)someDocument;

@property (nonatomic, assign) id <BookmarkTableViewControllerDelegate> delegate;
@property (nonatomic, readonly) IBOutlet AAEditableTableView *tableView;

@end
