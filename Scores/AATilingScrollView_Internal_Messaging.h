//
//  AATilingScrollView_Internal_Messaging.h
//  Scores
//
//  Created by Sasha Friedenberg on 9/6/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "AATilingScrollView.h"
#import "AATiledContentView.h"


@interface AATilingScrollView ()

- (void)contentViewDidChangeContentSize:(AATiledContentView *)someContentView;

@end


@interface AATiledContentView ()

@end