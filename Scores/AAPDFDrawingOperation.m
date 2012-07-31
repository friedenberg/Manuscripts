//
//  AAPDFDrawingOperation.m
//  Scores
//
//  Created by Sasha Friedenberg on 7/30/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AAPDFDrawingOperation.h"

@implementation AAPDFDrawingOperation

@synthesize pdfPage, pdfPageImage, canvasSize, viewRecyclingKey;

- (void)setPdfPage:(CGPDFPageRef)value
{
	CGPDFPageRef old = pdfPage;
	pdfPage = CGPDFPageRetain(value);
	CGPDFPageRelease(old);
}

- (void)main
{
	UIGraphicsBeginImageContextWithOptions(self.canvasSize, YES, 0);
	
	CGRect bounds = CGRectMake(0, 0, canvasSize.width, canvasSize.height);
    CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGPDFBox pdfBox = kCGPDFBleedBox;
	CGRect pdfRect = CGPDFPageGetBoxRect(pdfPage, pdfBox);
	
	BOOL scaleByWidth = (bounds.size.width / bounds.size.height) < (pdfRect.size.width / pdfRect.size.height);
	
	CGFloat scaleFactor;
	
	if (scaleByWidth)
		scaleFactor = bounds.size.width / pdfRect.size.width;
	else
		scaleFactor = bounds.size.height / pdfRect.size.height;
	
	CGContextScaleCTM(context, scaleFactor, -scaleFactor);
	
	if (scaleByWidth)
		CGContextTranslateCTM(context, 0, (bounds.size.height - pdfRect.size.height) / 4);
	else
		CGContextTranslateCTM(context, (bounds.size.width - pdfRect.size.width) / 4, 0);
	
	CGContextTranslateCTM(context, 1.0, -pdfRect.size.height);
	
	[[UIColor whiteColor] set];
	CGContextFillRect(context, CGRectInset(pdfRect, -1, -1));
	
    CGContextDrawPDFPage(context, pdfPage);
	
	pdfPageImage = [UIGraphicsGetImageFromCurrentImageContext() retain];
	
	UIGraphicsEndImageContext();
}

- (void)dealloc
{
	CGPDFPageRelease(pdfPage);
	[pdfPageImage release];
	[super dealloc];
}

@end
