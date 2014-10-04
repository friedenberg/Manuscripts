//
//  AAPDFCollectionViewController.m
//  Scores
//
//  Created by Sasha Friedenberg on 10/4/14.
//  Copyright (c) 2014 Apple, Stamford. All rights reserved.
//

#import "AAPDFCollectionViewController.h"

#import "AAPDFCollectionViewLayout.h"
#import "AAPDFViewCell.h"

#import "AAOperationQueue.h"
#import "AAPDFPageDrawingOperation.h"


@interface AAPDFCollectionViewController ()

@end

@implementation AAPDFCollectionViewController

- (instancetype)initWithDocumentURL:(NSURL *)documentURL
{
    if (self = [super initWithCollectionViewLayout:[AAPDFCollectionViewLayout new]]) {
        _pdfDocument = CGPDFDocumentCreateWithURL((CFURLRef)documentURL);
        AAPDFCollectionViewLayout *layout = (AAPDFCollectionViewLayout *)self.collectionView.collectionViewLayout;
        layout.pageCount = CGPDFDocumentGetNumberOfPages(_pdfDocument);
        _drawingOperationQueue = [AAOperationQueue new];
        _drawingOperationQueue.operationCountLimit = 3;
    }
    
    return self;
}

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.collectionView registerClass:[AAPDFViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    self.collectionView.pagingEnabled = YES;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSAssert(section == 0, @"section count must be 0");
    return CGPDFDocumentGetNumberOfPages(_pdfDocument);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(indexPath.section == 0, @"section count must be 0");
    AAPDFViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    AAPDFPageDrawingOperation *op = [AAPDFPageDrawingOperation new];
    op.canvasSize = self.collectionView.bounds.size;
    op.pdfPage = CGPDFDocumentGetPage(_pdfDocument, indexPath.item + 1);
    [op start];
    cell.imageView.image = op.pdfPageImage;
    
    return cell;
}

@end
