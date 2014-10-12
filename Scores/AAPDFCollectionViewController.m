//
//  AAPDFCollectionViewController.m
//  Scores
//
//  Created by Sasha Friedenberg on 10/4/14.
//  Copyright (c) 2014 Apple, Stamford. All rights reserved.
//

#import "AAPDFCollectionViewController.h"

#import "AAPDFCollectionViewLayout.h"
#import "AAPDFCollectionView.h"
#import "AAPDFViewCell.h"
#import "AAPageControl.h"

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
        _pdfImageCache = [NSCache new];
        _pdfImageCache.countLimit = 5;
    }
    
    return self;
}

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];

    UICollectionViewLayout *layout = self.collectionView.collectionViewLayout;
    AAPDFCollectionView *collectionView = [[AAPDFCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.pageControl.pageCount = CGPDFDocumentGetNumberOfPages(_pdfDocument) - 1;
    self.collectionView = collectionView;
    
    [self.collectionView registerClass:[AAPDFViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self scrollViewDidScroll:self.collectionView];
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
    
    UIImage *image = [_pdfImageCache objectForKey:indexPath];
    cell.imageView.image = image;
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat contentOffsetX = MAX(0, MIN(scrollView.contentOffset.x, scrollView.contentSize.width));
    NSUInteger currentPage = (NSUInteger)floor(contentOffsetX / scrollView.bounds.size.width);
    
    NSUInteger pageCount = CGPDFDocumentGetNumberOfPages(_pdfDocument);
    
    if (currentPage == 0) {
        currentPage = 1;
    } else if (currentPage == pageCount - 1) {
        currentPage = pageCount - 2;
    }
    
    void (^createOp)(NSUInteger pageIndex) = ^(NSUInteger pageIndex) {
        NSArray *opKeys = [_drawingOperationQueue.operations valueForKey:@"key"];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:pageIndex inSection:0];
        
        if (![opKeys containsObject:indexPath] && ![_pdfImageCache objectForKey:indexPath]) {
            __block AAPDFPageDrawingOperation *op = [AAPDFPageDrawingOperation new];
            op.key = indexPath;
            op.canvasSize = scrollView.bounds.size;
            op.pdfPage = CGPDFDocumentGetPage(_pdfDocument, pageIndex + 1);
            
            op.completionBlock = ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = op.pdfPageImage;
                    if (image) {
                        [_pdfImageCache setObject:image forKey:indexPath];
                        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                    }
                    
                    op = nil;
                });
            };
            
            [_drawingOperationQueue addOperation:op];
        }
    };
    
    createOp(currentPage - 1);
    createOp(currentPage);
    createOp(currentPage + 1);
}

@end
