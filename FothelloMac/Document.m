//
//  Document.m
//  FothelloMac
//
//  Created by Paul Ossenbruggen on 4/20/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "Document.h"
#import "Match.h"
#import "FothelloGame.h"

@interface Document ()
@property (nonatomic) Match *match;
@end

@implementation Document

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        FothelloGame *game = [FothelloGame sharedInstance];
        if (game.matches.count == 0)
        {
            [[FothelloGame sharedInstance] matchWithDifficulty:DifficultyEasy firstPlayerColor:PieceColorBlack opponentType:PlayerTypeComputer];
        }
        
        NSAssert(game.matches.count != 0, @"matches empty");
        _match = game.matches[0];
    }
    
    return self;
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (void)makeWindowControllers
{
    // Override to return the Storyboard file name of the document.
    [self addWindowController:[[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Document Window Controller"]];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    [NSException raise:@"UnimplementedMethod" format:@"%@ is unimplemented", NSStringFromSelector(_cmd)];
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    [NSException raise:@"UnimplementedMethod" format:@"%@ is unimplemented", NSStringFromSelector(_cmd)];
    return YES;
}

@end
