//
//  ScorePDFViewController.m
//  Scores
//
//  Created by Sasha Friedenberg on 7/28/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "ScorePDFViewController.h"

#import "AAPDFView.h"
#import "AAPDFContentView.h"


@interface ScorePDFViewController ()

@end

@implementation ScorePDFViewController

- (id)initWithNibName:(NSString *)nibNameOrNil documentURL:(NSURL *)someURL
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nil])
	{
        documentURL = [someURL copy];
    }
	
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithURL((CFURLRef)documentURL);
    pdfView.pdfContentView.pdfDocument = pdfDocument;
    CGPDFDocumentRelease(pdfDocument);
    
    //pdfView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == pdfView)
    {
        CGRect navBarRect = self.navigationController.navigationBar.frame;
        
        CGFloat xOffset = scrollView.contentOffset.x;
        CGFloat contentWidth = scrollView.contentSize.width;
        CGFloat boundsWidth = scrollView.bounds.size.width;
        
        navBarRect.origin.x = 0;
        
        if (xOffset < 0)
            navBarRect.origin.x -= xOffset;
        else if (xOffset > contentWidth - boundsWidth)
            navBarRect.origin.x -= fmod(xOffset, boundsWidth);
        
        self.navigationController.navigationBar.frame = navBarRect;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [documentURL release];
    [super dealloc];
}

@end
