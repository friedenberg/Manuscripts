//
//  ScorePDFViewController.m
//  Scores
//
//  Created by Sasha Friedenberg on 7/28/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "ScorePDFViewController.h"

#import "AAScorePDFView.h"


@interface ScorePDFViewController ()

- (void)bookmarksButton:(id)sender;

@end

@implementation ScorePDFViewController

+ (void)initialize
{
	if (self == [ScorePDFViewController class])
	{
		@autoreleasepool
		{
//			UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, 0);
//			
//			UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//			
//			UIGraphicsEndImageContext();
//			
//			id appearance = [UINavigationBar appearanceWhenContainedIn:self, nil];
//			appearance = [UINavigationBar appearance];
//			[appearance setBarStyle:UIBarStyleBlackTranslucent];
//			[appearance setTintColor:[UIColor blueColor]];
//			[appearance setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
		}
	}
}

- (id)initWithNibName:(NSString *)nibNameOrNil documentURL:(NSURL *)someURL
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nil])
	{
        documentURL = [someURL copy];
		self.title = [documentURL lastPathComponent];
    }
	
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *tableOfContentsItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(bookmarksButton:)];
    self.navigationItem.rightBarButtonItem = tableOfContentsItem;
    [tableOfContentsItem release];
    
    CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithURL((CFURLRef)documentURL);
    pdfView.pdfDocument = pdfDocument;
    CGPDFDocumentRelease(pdfDocument);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = YES;
}

- (void)bookmarksButton:(id)sender
{
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)dealloc
{
    [documentURL release];
    [super dealloc];
}

@end
