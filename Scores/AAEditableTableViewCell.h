//
//  AAEditableTableViewCell.h
//  Scores
//
//  Created by Sasha Friedenberg on 8/4/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AAEditableTableView;

@interface AAEditableTableViewCell : UITableViewCell
{
    AAEditableTableView *superTable;
    
    UITextField *textField;
}

- (id)initWithSuperTable:(AAEditableTableView *)someTableView reuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, readonly) UITextField *textField;

- (void)setIndentationLevel:(NSInteger)value animated:(BOOL)shouldAnimate;

@end
