//
//  AAEditableTableView.h
//  Scores
//
//  Created by Sasha Friedenberg on 8/4/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AAEditableTableView, AAEditableTableViewCell;

@protocol AAEditableTableViewDataSource <UITableViewDataSource>

- (AAEditableTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol AAEditableTableViewDelegate <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView willDisplayCell:(AAEditableTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(AAEditableTableView *)someTableView didChangeContentOfCellAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface AAEditableTableView : UITableView
{
    UIResponder *firstResponder;
}

@property (nonatomic, weak) id <AAEditableTableViewDelegate> delegate;
@property (nonatomic, weak) id <AAEditableTableViewDataSource> dataSource;

- (AAEditableTableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
