//
//  AAPageIndexView.m
//  Scores
//
//  Created by Sasha Friedenberg on 7/30/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AAPageControl.h"

#import "AAViewRecycler.h"
#import "NSIndexSet+AAAdditions.h"


@interface AAPageControl () <AAViewRecyclerDelegate>

- (NSUInteger)convertPageIndexToDotIndex:(NSUInteger)pageIndex;
- (NSUInteger)convertDotIndexToPageIndex:(NSUInteger)dotIndex;

- (void)setPageIndexFromTrackingPoint:(CGPoint)point;

@end

@implementation AAPageControl

static CGFloat kDotDiameter = 4;
static CGFloat kInterdotSpacing = 12;

static CGFloat kStandardCapDiameter = 28;
static UIImage *backgroundImage;
static UIImage *dotImage;
static UIImage *dotImageHighlighted;

+ (void)initialize
{
    if (self == [AAPageControl class])
    {
        CGRect bounds = CGRectMake(0, 0, kStandardCapDiameter + 1, kStandardCapDiameter);
		
        {
			UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0);
			
			[[UIColor colorWithWhite:0.5 alpha:0.5] setFill];
			[[UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:kStandardCapDiameter / 2] fill];
			
			backgroundImage = [[UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsMake(0, kStandardCapDiameter / 2, 0, kStandardCapDiameter / 2)] retain];
			
			UIGraphicsEndImageContext();
		}
        
		{
			bounds.size = CGSizeMake(kDotDiameter, kDotDiameter);
			UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0);
			
			CGFloat dotRadius = kDotDiameter / 2;
			
			UIBezierPath *dotPath = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:dotRadius];
			
			[[UIColor colorWithWhite:0.4 alpha:0.5] setFill];
			[dotPath fill];
			
			UIEdgeInsets resizingInsets = UIEdgeInsetsMake(dotRadius, dotRadius, dotRadius, dotRadius);
			
			dotImage = [[UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:resizingInsets] retain];
			
			CGContextClearRect(UIGraphicsGetCurrentContext(), bounds);
			
			[[UIColor colorWithWhite:0.0 alpha:1] setFill];
			[dotPath fill];
			
			dotImageHighlighted = [[UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:resizingInsets] retain];
			
			UIGraphicsEndImageContext();
		}
    }
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
	{
        self.backgroundColor = [UIColor clearColor];
        backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        backgroundView.hidden = YES;
        backgroundView.opaque = NO;
		
		dotContentView = [[UIView alloc] initWithFrame:CGRectZero];
		dotContentView.userInteractionEnabled = NO;
		
        [self addSubview:backgroundView];
        [self addSubview:dotContentView];
        
        //progressView = [UIView new];
        progressView.backgroundColor = [UIColor redColor];
        
        [self addSubview:progressView];
		
        largeDotIndexes = [NSMutableIndexSet new];
        
        self.contentMode = UIViewContentModeRedraw;
		
		dotRecycler = [[AAViewRecycler alloc] initWithDelegate:self];
    }
	
    return self;
}

- (void)setFrame:(CGRect)frame
{
    CGRect oldFrame = self.frame;
    super.frame = frame;
    
    if (!CGRectEqualToRect(frame, oldFrame))
    {
        [dotRecycler reloadVisibleViews];
    }
}

@synthesize pageCount, currentPage, bookmarkedIndexes, sections;

- (void)setPageCount:(NSUInteger)value
{
    pageCount = value;
    [self setNeedsLayout];
}

#pragma - mark Geometry

- (CGPoint)centerForDotAtIndex:(NSUInteger)dotIndex
{
	CGRect bounds = self.bounds;
	CGFloat boundsMidY = CGRectGetMidY(bounds);
	return CGPointMake(dotIndex * kInterdotSpacing + dotContentRect.origin.x, boundsMidY);
}

#pragma - mark View Recycling

- (UIView *)unusedViewForViewRecycler:(AAViewRecycler *)someViewRecycler
{
	UIImageView *imageView = [[UIImageView alloc] initWithImage:dotImage highlightedImage:dotImageHighlighted];
	return [imageView autorelease];
}

- (BOOL)visibilityForKey:(id)key viewRecycler:(AAViewRecycler *)someViewRecycler
{
	return YES;
}

- (CGRect)rectForViewWithKey:(id)key viewRecycler:(AAViewRecycler *)someViewRecycler
{
	NSUInteger dotIndex = [key unsignedIntegerValue];
	CGPoint center = [dotContentView convertPoint:[self centerForDotAtIndex:dotIndex] fromView:self];
	CGRect dotRect = CGRectZero;
	dotRect.origin = center;
	
	BOOL isLarge = [largeDotIndexes containsIndex:dotIndex];
	
	CGFloat radius = kDotDiameter / 2;
	
	dotRect.origin.x -= radius;
	dotRect.origin.y -= radius + (isLarge ? radius : 0);
	
	dotRect.size = CGSizeMake(kDotDiameter, kDotDiameter * (isLarge ? 2 : 1));
	
	return dotRect;
}

- (UIView *)superviewForViewWithKey:(id)key viewRecycler:(AAViewRecycler *)someViewRecycler
{
	return dotContentView;
}

- (void)layoutSubviews
{
    CGRect bounds = self.bounds;
    
    backgroundView.frame = self.bounds;
    
    dotContentRect = bounds;
    dotContentRect.origin.x += kStandardCapDiameter / 2;
    dotContentRect.size.width -= kStandardCapDiameter;
    CGFloat flooredDotContentWidth = dotContentRect.size.width - fmod(dotContentRect.size.width, 12);
    dotContentRect.origin.x += (dotContentRect.size.width - flooredDotContentWidth) / 2;
    dotContentRect.size.width = flooredDotContentWidth;
	dotContentRect = CGRectStandardize(dotContentRect);
	dotContentView.frame = dotContentRect;
    
	NSUInteger previousDotCount = dotCount;
	dotCount = dotContentRect.size.width / kInterdotSpacing + 1;
    
    if (bookmarkedIndexes.count && !largeDotIndexes.count)
    {
        [bookmarkedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            
            [largeDotIndexes addIndex:[self convertPageIndexToDotIndex:idx]];
        }];
    }
	
	NSRange previous = NSMakeRange(0, previousDotCount);
	NSRange current = NSMakeRange(0, dotCount);
	NSRangeEnumerateUnion(previous, current, ^(NSUInteger index) {
		
		[dotRecycler processViewForKey:@(index)];
	});
    
    CGRect progressRect = dotContentRect;
    progressRect.size.width = 1;
    progressRect.origin.x = dotContentRect.origin.x + (dotContentRect.size.width * currentPage / pageCount) - (progressRect.size.width / 2);
    progressView.frame = progressRect;
}

- (void)viewRecycler:(AAViewRecycler *)someViewReuseController didLoadView:(UIView *)view withKey:(id)key
{
    UIImageView *dotView = view;
    dotView.highlighted = [key unsignedIntegerValue] == highlightedDotIndex;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    size.height = kStandardCapDiameter;
    return size;
}

#pragma - mark touch handling

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	backgroundView.hidden = NO;
    [self setPageIndexFromTrackingPoint:[touch locationInView:self]];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self setPageIndexFromTrackingPoint:[touch locationInView:self]];
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	backgroundView.hidden = YES;
    [self setPageIndexFromTrackingPoint:[touch locationInView:self]];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    backgroundView.hidden = YES;
}

- (void)setPageIndexFromTrackingPoint:(CGPoint)point
{
    self.currentPage = [self pageIndexForPoint:point affinityForBookmarks:YES];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (NSUInteger)pageIndexForPoint:(CGPoint)point affinityForBookmarks:(BOOL)prefersBookmarks
{
    point.x = MAX(CGRectGetMinX(dotContentRect), point.x);
    point.x = MIN(CGRectGetMaxX(dotContentRect), point.x);
    __block CGFloat convertedXOrigin = [dotContentView convertPoint:point fromView:self].x;
    CGFloat progress = convertedXOrigin / dotContentRect.size.width;
    
    __block NSUInteger dotIndex = (NSUInteger)round(progress * (CGFloat)dotCount);
    
	if (prefersBookmarks)
	{
        CGFloat upperBoundary = convertedXOrigin + kInterdotSpacing;
        CGFloat lowerBoundary = convertedXOrigin - kInterdotSpacing;
        
        [bookmarkedIndexes enumerateIndexesUsingBlock:^(NSUInteger bookmarkPageIndex, BOOL *stop)
        {
            NSUInteger bookmarkDotIndex = [self convertPageIndexToDotIndex:bookmarkPageIndex];
            CGFloat bookmarkCenterX = [self convertPoint:[self centerForDotAtIndex:bookmarkDotIndex] toView:dotContentView].x;
            
            if (lowerBoundary <= bookmarkCenterX && bookmarkCenterX <= upperBoundary)
            {
                dotIndex = bookmarkDotIndex;
                convertedXOrigin = (CGFloat)bookmarkPageIndex / (CGFloat)pageCount * dotContentView.bounds.size.width;
                *stop = YES;
            }
        }];
	}
	
	NSUInteger index = (NSUInteger)round(convertedXOrigin / dotContentRect.size.width * (CGFloat)pageCount);
    
    if (index == pageCount) index--;
    return index;
}

- (void)setCurrentPage:(NSUInteger)value
{
    NSUInteger oldValue = currentPage;
    currentPage = value;
 	
	NSUInteger oldIndex = [self convertPageIndexToDotIndex:oldValue];
	highlightedDotIndex = [self convertPageIndexToDotIndex:currentPage];
	
    [dotRecycler beginMutation];
    
    [dotRecycler reloadViewWithKey:@(oldIndex)];
    [dotRecycler reloadViewWithKey:@(highlightedDotIndex)];
    
    [dotRecycler endMutation];
    
    [self setNeedsLayout];
}

- (void)setBookmarkedIndexes:(NSIndexSet *)value
{
    NSIndexSet *old = bookmarkedIndexes;
    bookmarkedIndexes = [value retain];
    [old release];
    
    [largeDotIndexes removeAllIndexes];
    
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (NSUInteger)convertPageIndexToDotIndex:(NSUInteger)pageIndex
{
    double progress = (double)pageIndex / (double)pageCount;
    double dotProgress = progress * (double)(dotCount - 1);
    NSUInteger dotIndex = (NSUInteger)round(dotProgress);
	return dotIndex;
}

- (NSUInteger)convertDotIndexToPageIndex:(NSUInteger)dotIndex
{
    double progress = (double)dotIndex / (double)(dotCount - 1);
    double pageProgress = progress * (double)pageCount;
	NSUInteger pageIndex = (NSUInteger)round(pageProgress);
	return pageIndex;
}

- (void)setSections:(NSDictionary *)value
{
    NSDictionary *old = sections;
    sections = [value retain];
    [old release];
    [self setNeedsDisplay];
}

- (void)dealloc
{
    [progressView release];
	[dotContentView release];
    [largeDotIndexes release];
    [bookmarkedIndexes release];
    [sections release];
    [backgroundView release];
    [super dealloc];
}

@end
