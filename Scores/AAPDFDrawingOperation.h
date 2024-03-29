//
//  AAPDFDrawingOperation.h
//  Scores
//
//  Created by Sasha Friedenberg on 7/30/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AAPDFDrawingOperation : NSOperation
{
	CGSize canvasSize;
	CGPDFPageRef pdfPage;
	
	UIImage *pdfPageImage;
}

@property (nonatomic, copy) id viewRecyclingKey;
@property (nonatomic) CGSize canvasSize;
@property (nonatomic) CGPDFPageRef pdfPage;

@property (nonatomic, readonly) UIImage *pdfPageImage;

@end
