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
    
    CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithURL((__bridge CFURLRef)documentURL);
    pdfView.pdfDocument = pdfDocument;
    CGPDFDocumentRelease(pdfDocument);
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
