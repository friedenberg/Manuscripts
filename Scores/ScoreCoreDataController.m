//
//  ScoreCoreDataController.m
//  Scores
//
//  Created by Sasha Friedenberg on 8/1/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "ScoreCoreDataController.h"

#import "ScoreDocument.h"


@implementation ScoreCoreDataController

- (void)addScoreDocumentFromFileURL:(NSURL *)oldURL
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    NSString *fileName = [(NSString *)CFUUIDCreateString(NULL, uuidRef) autorelease];
    
    fileName = [fileName stringByAppendingPathExtension:@"pdf"];
    
    NSString *filePath = [DocumentsDirectory() stringByAppendingPathComponent:fileName];
    
    NSURL *documentURL = [NSURL fileURLWithPath:filePath];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] moveItemAtURL:oldURL toURL:documentURL error:&error];
    
    ScoreDocument *newDocument = [NSEntityDescription insertNewObjectForEntityForName:@"ScoreDocument" inManagedObjectContext:managedObjectContext];
    newDocument.path = filePath;
    newDocument.title = [documentURL lastPathComponent];
    
    [self saveContext];
}

@end
