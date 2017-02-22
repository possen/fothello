//
//  Document.m
//  FothelloMac
//
//  Created by Paul Ossenbruggen on 4/20/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "Document.h"
#import "Match.h"

@implementation Document

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
    }
    return self;
}

- (nullable instancetype)initWithType:(NSString *)typeName error:(NSError **)outError
{
    self = [super initWithType:typeName error:outError];
    
    if (self)
    {
//        NSArray *players = @[];
//        _match = [[Match alloc] initWithName:@"untitled" players:players difficulty:DifficultyEasy];
    }
    return self;
}


+ (BOOL)autosavesInPlace
{
    return YES;
}

- (void)makeWindowControllers
{
    NSWindowController *windowController =
        [[NSStoryboard storyboardWithName:@"Main" bundle:nil]
         instantiateControllerWithIdentifier:@"Document Window Controller"];
    
    // Override to return the Storyboard file name of the document.
    [self addWindowController:windowController];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.match forKey:@"root"];
    [archiver finishEncoding];

    return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    // Customize the unarchiver.
    self.match = [unarchiver decodeObjectForKey:@"root"];
    [unarchiver finishDecoding];

    return YES;
}

@end
