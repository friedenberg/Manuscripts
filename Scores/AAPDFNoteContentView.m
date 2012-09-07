//
//  AAPDFNoteContentView.m
//  Scores
//
//  Created by Sasha Friedenberg on 9/4/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AAPDFNoteContentView.h"

#import "AAPDFNoteView.h"
#import "AAPDFView.h"
#import "AAPDFContentView.h"


@interface AAPDFNoteContentView ()

- (void)pressGesture:(UILongPressGestureRecognizer *)sender;

@end

@implementation AAPDFNoteContentView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        // Initialization code
    }
    
    return self;
}

@synthesize dataSource;

- (void)setDataSource:(id<AAPDFNoteContentViewDataSource>)value
{
    dataSource = value;
    [self reloadTiles];
}

#pragma mark - tiling

- (id)newTile
{
    return [AAPDFNoteView new];
}

- (BOOL)visibilityForTileKey:(NSIndexPath *)key
{
    return NSLocationInRange(key.page, self.scrollView.activePages);
}

- (CGRect)frameForTileKey:(id)key tile:(AAPDFNoteView *)tile
{
    CGSize size = [tile sizeThatFits:tile.frame.size];
    size.width = MAX(size.width, 100);
    size.height = MAX(size.height, 100);
    
    CGPoint centerPoint = [self.dataSource centerPointForNoteAtIndexPath:key noteContentView:self];
    
    CGRect rect;
    rect.size = size;
    rect.origin = CGPointMake(floor(centerPoint.x - size.width / 2), floor(centerPoint.y - size.height / 2));
    
    return rect;
}

#pragma mark - event handling

- (void)pressGesture:(UILongPressGestureRecognizer *)sender
{
    
}

@end

@implementation NSIndexPath (AAPDFNoteContentViewAdditions)

+ (NSIndexPath *)indexPathForIndex:(NSUInteger)index inPage:(NSUInteger)page
{
    NSUInteger indices[] = {page, index};
    return [NSIndexPath indexPathWithIndexes:indices length:2];
}

- (NSUInteger)index
{
    return [self indexAtPosition:1];
}

- (NSUInteger)page
{
    return [self indexAtPosition:0];
}

@end