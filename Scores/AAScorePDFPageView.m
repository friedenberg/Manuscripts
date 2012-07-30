//
//  AAScorePDFPageView.m
//  Scores
//
//  Created by Sasha Friedenberg on 7/24/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AAScorePDFPageView.h"

@implementation AAScorePDFPageView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        //self.clearsContextBeforeDrawing = YES;
        //self.backgroundColor = [UIColor whiteColor];
    }
                
    return self;
}

@synthesize editing, selected;

- (void)setEditing:(BOOL)value animated:(BOOL)animated
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    
}

@synthesize pdfPage;

- (void)setPdfPage:(CGPDFPageRef)value
{
    CGPDFPageRef old = pdfPage;
    pdfPage = CGPDFPageRetain(value);
    CGPDFPageRelease(old);
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
	CGRect bounds = self.bounds;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, bounds);
    
    //CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    //CGContextFillRect(context, self.bounds);
    [[UIColor clearColor] set];
    CGContextFillRect(context, bounds);
	
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
	
	[[UIColor redColor] set];
	CGContextFillRect(context, CGRectInset(pdfRect, -1, -1));
	
    CGContextDrawPDFPage(context, pdfPage);
    //CGContextRestoreGState(context);
}

@end
