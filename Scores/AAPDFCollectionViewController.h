//
//  AAPDFCollectionViewController.h
//  Scores
//
//  Created by Sasha Friedenberg on 10/4/14.
//  Copyright (c) 2014 Apple, Stamford. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AAOperationQueue;

@interface AAPDFCollectionViewController : UICollectionViewController
{
    CGPDFDocumentRef _pdfDocument;
    AAOperationQueue *_drawingOperationQueue;
    NSCache *_pdfImageCache;
}

- (instancetype)initWithDocumentURL:(NSURL *)documentURL;

@end
