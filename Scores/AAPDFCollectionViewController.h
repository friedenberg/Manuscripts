//
//  AAPDFCollectionViewController.h
//  Scores
//
//  Created by Sasha Friedenberg on 10/4/14.
//  Copyright (c) 2014 Apple, Stamford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AAPDFCollectionView.h"


@class AAOperationQueue;

@interface AAPDFCollectionViewController : UICollectionViewController
{
    CGPDFDocumentRef _pdfDocument;
    AAOperationQueue *_drawingOperationQueue;
    NSCache *_pdfImageCache;
    NSInteger _scrollToIndex;
}

@property (nonatomic, retain) AAPDFCollectionView *collectionView;

- (instancetype)initWithDocumentURL:(NSURL *)documentURL;

@end
