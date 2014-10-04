//
//  AAPDFDrawingOperation.m
//  Scores
//
//  Created by Sasha Friedenberg on 7/30/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AAPDFPageDrawingOperation.h"

@implementation AAPDFPageDrawingOperation

- (void)setPdfPage:(CGPDFPageRef)value
{
	CGPDFPageRef old = _pdfPage;
	_pdfPage = CGPDFPageRetain(value);
	CGPDFPageRelease(old);
}

- (void)main
{
	UIGraphicsBeginImageContextWithOptions(self.canvasSize, YES, 0);
    CGContextRef context = NULL;
    
    CGRect bounds = CGRectMake(0, 0, _canvasSize.width, _canvasSize.height);
    context = UIGraphicsGetCurrentContext();
	
	[[UIColor whiteColor] set];
	CGContextFillRect(context, bounds);
	
	CGPDFBox pdfBox = kCGPDFMediaBox;
	CGRect pdfRect = CGPDFPageGetBoxRect(_pdfPage, pdfBox);
	
	BOOL scaleByWidth = (bounds.size.width / bounds.size.height) < (pdfRect.size.width / pdfRect.size.height);
	
	CGFloat scaleFactor;
	
	if (scaleByWidth)
		scaleFactor = bounds.size.width / pdfRect.size.width;
	else
		scaleFactor = bounds.size.height / pdfRect.size.height;
	
    if (scaleByWidth)
    {
        CGFloat heightPadding = CGRectGetMidY(bounds) - pdfRect.size.height * scaleFactor / 2;
        CGContextTranslateCTM(context, 0, floor(heightPadding));
    }
	else
    {
        CGFloat widthPadding = CGRectGetMidX(bounds) - pdfRect.size.width * scaleFactor / 2;
        CGContextTranslateCTM(context, floor(widthPadding), 0);
    }
    
	CGContextScaleCTM(context, scaleFactor, -scaleFactor);
	CGContextTranslateCTM(context, 1.0, -pdfRect.size.height);
	
    CGContextDrawPDFPage(context, _pdfPage);
	
	_pdfPageImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
}

- (void)dealloc
{
	CGPDFPageRelease(_pdfPage);
}

@end
