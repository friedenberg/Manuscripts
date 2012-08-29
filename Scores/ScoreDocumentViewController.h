//
//  ScoreDocumentViewController.h
//  Scores
//
//  Created by Sasha Friedenberg on 8/1/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "ScorePDFViewController.h"


@class ScoreDocument;

@interface ScoreDocumentViewController : ScorePDFViewController <AAScorePDFViewNoteDataSource>
{
	UIPopoverController *popoverController;
	ScoreDocument *document;
}

- (id)initWithNibName:(NSString *)nibNameOrNil scoreDocument:(ScoreDocument *)someDocument;

@end
