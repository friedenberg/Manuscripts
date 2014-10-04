//
//  AAEditableTableView.m
//  Scores
//
//  Created by Sasha Friedenberg on 8/4/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AAEditableTableView.h"

#import "AAEditableTableView_PrivateCellMethods.h"
#import "AAEditableTableViewCell.h"


@implementation AAEditableTableView

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
	{
		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTap:)];
		tap.numberOfTapsRequired = 1;
		tap.numberOfTouchesRequired = 1;
        
	}
	
	return self;
}

@dynamic delegate, dataSource;

- (AAEditableTableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (AAEditableTableViewCell *)[super cellForRowAtIndexPath:indexPath];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (!editing)
    {
        [firstResponder resignFirstResponder];
    }
        
    [super setEditing:editing animated:animated];
}

- (void)cellTap:(UITapGestureRecognizer *)recognizer
{
	NSIndexPath *indexPath = [self indexPathForRowAtPoint:[recognizer locationInView:self]];
	AAEditableTableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
	[cell.textField becomeFirstResponder];
}

#pragma Cell notifications

- (void)cellDidBeginEditing:(AAEditableTableViewCell *)cell
{
    firstResponder = cell.textField;
}

- (void)cellDidChangeTextFieldValue:(AAEditableTableViewCell *)cell
{
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    [self.delegate tableView:self didChangeContentOfCellAtIndexPath:indexPath];
}

- (void)cellDidEndEditing:(AAEditableTableViewCell *)cell
{
    firstResponder = nil;
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    [self.delegate tableView:self didChangeContentOfCellAtIndexPath:indexPath];
}

@end
