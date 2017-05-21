//
//  GameBoard+String.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/18/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "GameBoardInternal.h"
#import "GameBoardString.h"
#import "Piece.h"
#import "BoardPiece.h"
#import "NSArray+Extensions.h"
#import "NSDictionary+Extensions.h"

@interface GameBoardInternal ()
@property (nonatomic) NSInteger size;
@property (nonatomic, readonly, nonnull) NSDictionary<NSNumber *, NSNumber *> *piecesPlayed;
@end

@implementation GameBoardString

- (instancetype)initWithBoard:(GameBoardInternal *)internal
{
    self = [super init];
    if (self)
    {
        _boardInternal = internal;
    }
    return self;
}

- (void)printBanner:(NSMutableString *)boardString ascii:(BOOL)ascii
{
    if (!ascii) [boardString appendString:@" "];

    for (NSInteger width = 0; width < self.boardInternal.size + 2; width++)
    {
        [boardString appendString:@"-"];
    }
    [boardString appendString:@"\n"];
}

- (void)printRow:(NSMutableString *)boardString ascii:(BOOL)ascii reverse:(BOOL)reverse
{
    GameBoardInternal *internal = self.boardInternal;
    
    NSInteger size = internal.size;
    NSInteger reverseOffset = reverse ? size - 1 : 0;
    for (NSInteger y = 0; y < size; ++y)
    {
        NSInteger ry = labs(reverseOffset - y);
        if (!ascii) [boardString appendFormat:@"%ld", (long)ry + 1];
        
        [boardString appendString:@"|"];
        
        for (NSInteger x = 0; x < size; x++)
        {
            Piece *piece = [internal pieceAtPositionX:x Y:ry];
            [boardString appendString:ascii ? piece.colorStringRepresentationAscii
                                            : piece.colorStringRepresentation];
        }
        
        [boardString appendString:@"|\n"];
    }
}

- (void)printHeader:(NSMutableString *)boardString
{
    GameBoardInternal *internal = self.boardInternal;

    [boardString appendFormat:@"  "];
    for (NSInteger x = 0; x < internal.size; x++)
    {
        [boardString appendFormat:@"%c", (char)x + 'A'];
    }
    [boardString appendFormat:@"\n"];
}

- (void)printPlayedPieces:(NSMutableString *)boardString
{
    GameBoardInternal *internal = self.boardInternal;
 
    NSDictionary *dict =  [internal.piecesPlayed mapObjectsUsingBlock:^id(NSString *key, id obj) {
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
