//
//  AAEditableTableView_PrivateCellMethods.h
//  Scores
//
//  Created by Sasha Friedenberg on 8/9/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AAEditableTableView.h"


@interface AAEditableTableView ()

- (void)cellDidBeginEditing:(AAEditableTableViewCell *)cell;
- (void)cellDidChangeTextFieldValue:(AAEditableTableViewCell *)cell;
- (void)cellDidEndEditing:(AAEditableTableViewCell *)cell;

@end
