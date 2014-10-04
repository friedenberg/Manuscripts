//
//  AAPDFContentView.h
//  
//
//  Created by Sasha Friedenberg on 9/5/12.
//
//

#import "AATiledContentView.h"
#import "AAPDFView.h"


@interface AAPDFContentView : AATiledContentView

@property (nonatomic, readonly, weak) AAPDFView *scrollView;

@end
