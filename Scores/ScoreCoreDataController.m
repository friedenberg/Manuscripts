//
//  ScoreCoreDataController.m
//  Scores
//
//  Created by Sasha Friedenberg on 8/1/12.
//  Copyright (c) 2012 Apple, Stamford. All rights reserved.
//

#import "ScoreCoreDataController.h"

#import "NSUInteger+Enumeration.h"
#import "ScoreDocument.h"
#import "Page.h"


@implementation ScoreCoreDataController

- (void)addScoreDocumentFromFileURL:(NSURL *)oldURL
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    NSString *fileName = (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL, uuidRef));
    CFRelease(uuidRef);
    
    fileName = [fileName stringByAppendingPathExtension:@"pdf"];
    
    NSString *filePath = [DocumentsDirectory() stringByAppendingPathComponent:fileName];
    
    NSURL *documentURL = [NSURL fileURLWithPath:filePath];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] moveItemAtURL:oldURL toURL:documentURL error:&error];
    
    ScoreDocument *newDocument = [NSEntityDescription insertNewObjectForEntityForName:@"ScoreDocument" inManagedObjectContext:managedObjectContext];
    newDocument.path = filePath.lastPathComponent;
    newDocument.title = [[oldURL lastPathComponent] stringByDeletingPathExtension];
    
    CGPDFDocumentRef doc = CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:filePath]);
    
    NSUIntegerEnumerate(CGPDFDocumentGetNumberOfPages(doc), ^(NSUInteger index) {
        
        Page *page = [NSEntityDescription insertNewObjectForEntityForName:@"Page" inManagedObjectContext:managedObjectContext];
        page.index = index;
        page.scoreDocument = newDocument;
    });
    
    CGPDFDocumentRelease(doc);
    
    [self saveContext];
}

@end
