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
#import "AAPDFPageContentView.h"

#import "NSUInteger+Enumeration.h"


@interface AAPDFNoteContentView () <UIGestureRecognizerDelegate>

- (void)pressGesture:(UILongPressGestureRecognizer *)sender;

@end

@implementation AAPDFNoteContentView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        pressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressGesture:)];
        //pressGesture.delegate = self;
        [self addGestureRecognizer:pressGesture];
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (self.scrollView)
    {
        for (UIGestureRecognizer *recognizer in self.scrollView.gestureRecognizers)
        {
            [recognizer requireGestureRecognizerToFail:pressGesture];
        }
    }
}

@synthesize dataSource;
@dynamic selectedTileKey, selectedTile;

- (void)setDataSource:(id<AAPDFNoteContentViewDataSource>)value
{
    dataSource = value;
    [self reloadTiles];
}

- (CGSize)contentSize
{
    return self.scrollView.pdfContentView.contentSize;
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

@synthesize editing;

- (void)setEditing:(BOOL)value
{
    editing = value;
    
    [self setNeedsLayout];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return gestureRecognizer == pressGesture && otherGestureRecognizer.view == self.superview;
}

- (void)pressGesture:(UILongPressGestureRecognizer *)sender
{
    if (!self.dataSource) return;
    
    CGPoint touchLocation = [sender locationInView:self];
    NSUInteger thisPage = [self.scrollView pageIndexForPoint:touchLocation];
    
    switch (sender.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            self.editing = YES;
            
            NSUInteger numberOfNotesOnThisPage = [self.dataSource numberOfNotesAtPageIndex:thisPage noteContentView:self];
            
            NSUIntegerEnumerate(numberOfNotesOnThisPage, ^(NSUInteger index) {
                
                index = numberOfNotesOnThisPage - index - 1;
                NSIndexPath *noteKey = [NSIndexPath indexPathForRow:index inSection:thisPage];
                
                CGRect frame = [[self tileForKey:noteKey] frame];
                
                if (CGRectContainsPoint(frame, touchLocation) && !self.selectedTileKey)
                {
                    self.selectedTileKey = noteKey;
                }
                
            });
            
            AAPDFNoteView *selectedNoteView = self.selectedTile;
            
            if (selectedNoteView)
            {
                [selectedNoteView startDragAsExistingView];
            }
            else
            {
                self.selectedTileKey = [self.dataSource addNoteWithCenterPoint:touchLocation pageIndex:thisPage noteContentView:self];
                
                [self beginMutatingTiles];
                [self addTileKey:self.selectedTileKey];
                [self endMutatingTiles];
                
                selectedNoteView = self.selectedTile;
                [selectedNoteView startDragAsNewView];
            }
            
            [self bringSubviewToFront:selectedNoteView];
            selectedNoteView.center = touchLocation;
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            AAPDFNoteView *noteView = self.selectedTile;
            noteView.center = touchLocation;
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            AAPDFNoteView *noteView = self.selectedTile;
            [noteView endDrag];
            
            [self.dataSource noteContentView:self didMoveNoteWithIndexPathToFront:self.selectedTileKey];
            [self.dataSource setCenterPoint:touchLocation indexPath:self.selectedTileKey noteContentView:self];
            self.selectedTileKey = nil;
        }
            break;
            
        default:
            break;
    }
}

- (void)tileWillAppear:(AAPDFNoteView *)tile withKey:(NSIndexPath *)key
{
    [super tileWillAppear:tile withKey:key];
    
    tile.editing = self.editing;
}

- (void)dealloc
{
    [pressGesture release];
    [super dealloc];
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