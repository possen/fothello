//
//  GameBoard+String.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/18/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "GameBoard.h"
#import "GameBoard+String.h"
#import "Piece.h"
#import "BoardPiece.h"
#import "NSArray+Extensions.h"
#import "NSDictionary+Extensions.h"

@implementation GameBoard (String)

- (void)printBanner:(NSMutableString *)boardString ascii:(BOOL)ascii
{
    if (!ascii) [boardString appendString:@" "];

    for (NSInteger width = 0; width < self.size + 2; width++)
    {
        [boardString appendString:@"-"];
    }
    [boardString appendString:@"\n"];
}

- (void)printRow:(NSMutableString *)boardString ascii:(BOOL)ascii reverse:(BOOL)reverse
{
    NSInteger size = self.size;
    NSInteger reverseOffset = reverse ? size - 1 : 0;
    for (NSInteger y = 0; y < size; ++y)
    {
        NSInteger ry = labs(reverseOffset - y);
        if (!ascii) [boardString appendFormat:@"%ld", (long)ry + 1];
        
        [boardString appendString:@"|"];
        
        for (NSInteger x = 0; x < self.size; x++)
        {
            Piece *piece = [self pieceAtPositionX:x Y:ry];
            [boardString appendString:ascii ? piece.colorStringRepresentationAscii
                                            : piece.colorStringRepresentation];
        }
        
        [boardString appendString:@"|\n"];
    }
}

- (void)printHeader:(NSMutableString *)boardString
{
    [boardString appendFormat:@"  "];
    for (NSInteger x = 0; x < self.size; x++)
    {
        [boardString appendFormat:@"%c", (char)x + 'A'];
    }
    [boardString appendFormat:@"\n"];
}

- (void)printPlayedPieces:(NSMutableString *)boardString
{
    NSDictionary *dict =  [self.piecesPlayed mapObjectsUsingBlock:^id(NSString *key, id obj) {
                               return @[[Piece stringFromColor:[key integerValue]], obj];
                           }];
    
    // printing the dict does not preserve dictionary key unicode characters.
    for (NSString *dictItem in dict)
    {
        [boardString appendFormat:@"%@ %@\n", dictItem, dict[dictItem]];
    }
}

- (NSString *)convertToString:(BOOL)ascii reverse:(BOOL)reverse
{
    NSMutableString *boardString = [[NSMutableString alloc] init];
    
    if (!ascii) [self printHeader:boardString];
    
    [self printBanner:boardString ascii:ascii];
    [self printRow:boardString ascii:ascii reverse:reverse];
    [self printBanner:boardString ascii:ascii];
    
    if (!ascii) [self printPlayedPieces:boardString];
    
    return [boardString copy];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\n%@",[self toString]];
}

- (NSString *)toString
{
    return [self convertToString:NO reverse:YES];
}

- (void)printBoardUpdates:(NSArray<NSArray<BoardPiece *> *> *)tracks
{
    NSLog(@"(%lu){", (unsigned long)tracks.count);
    for (NSArray<BoardPiece *> *track in tracks)
    {
        NSMutableString *string = [[NSString stringWithFormat:@"(%lu)", (unsigned long)track.count] mutableCopy];
        for (BoardPiece *boardPiece in track)
        {
            [string appendFormat:@"(%@@) ", boardPiece.description];
        }
        NSLog(@"%@", string);
    }
    NSLog(@"}");
}

@end
