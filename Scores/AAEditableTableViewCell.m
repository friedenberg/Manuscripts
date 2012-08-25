//
//  AAEditableTableViewCell.m
//  Scores
//
//  Created by Sasha Friedenberg on 8/4/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AAEditableTableViewCell.h"

#import "AAEditableTableView.h"
#import "AAEditableTableView_PrivateCellMethods.h"

#import "UIView+UIViewAnimationAdditions.h"


@interface AAEditableTableViewCell () <UITextFieldDelegate>

- (void)textFieldDidChangeValue:(UITextField *)someTextField;

@end

@implementation AAEditableTableViewCell

- (id)initWithSuperTable:(AAEditableTableView *)someTableView reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier])
    {
        superTable = someTableView;
        
        self.textLabel.hidden = YES;
        textField = [[UITextField alloc] initWithFrame:CGRectZero];
        textField.delegate = self;
        textField.enabled = NO;
        textField.font = [UIFont boldSystemFontOfSize:17];
        textField.returnKeyType = UIReturnKeyDone;
        textField.enablesReturnKeyAutomatically = YES;
        [textField addTarget:self action:@selector(textFieldDidChangeValue:) forControlEvents:UIControlEventEditingChanged];
        
        [self.contentView addSubview:textField];
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    abort();
}

@synthesize textField;

static CGFloat kPadding = 10;

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    [textField sizeToFit];
    CGRect textFieldRect = textField.frame;
    textFieldRect.origin.y = floor(CGRectGetMidY(bounds) - textFieldRect.size.height / 2);
    textFieldRect.origin.x = kPadding;
    textFieldRect.origin.x += self.indentationWidth * self.indentationLevel;
    textFieldRect.size.width = floor(bounds.size.width - (kPadding + textFieldRect.origin.x + (bounds.size.width - self.detailTextLabel.frame.origin.x)));
    textField.frame = textFieldRect;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    textField.enabled = editing;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    textField.textColor = highlighted ? [UIColor whiteColor] : [UIColor darkTextColor];
}

- (void)setIndentationLevel:(NSInteger)value animated:(BOOL)shouldAnimate
{
    self.indentationLevel = value;
    [self layoutSubviewsAnimated:shouldAnimate];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [superTable cellDidBeginEditing:self];
    
    return YES;
}

- (void)textFieldDidChangeValue:(UITextField *)someTextField
{
    [superTable cellDidChangeTextFieldValue:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)someTextField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [superTable cellDidEndEditing:self];
    
    return YES;
}

- (void)dealloc
{
    [textField release];
    [super dealloc];
}

@end
