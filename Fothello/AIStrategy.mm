//
//  AIStrategy.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/18/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "AIStrategy.h"
#import "FothelloGame.h"
#import "board.hpp"

#pragma mark - AIStrategy -

@interface AIStrategy ()
{
    struct Board *_board;
}

@property (nonatomic) Difficulty difficulty;
@end

@implementation AIStrategy
@synthesize difficulty = _difficulty;

- (id)initWithMatch:(Match *)match
{
    self = [super initWithMatch:match];
    if (self)
    {
        _board = makeBoard();
        _difficulty = match.difficulty;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _board = makeBoard();
        
        NSUInteger len =  sizeof(char) * 64;
        const uint8_t *buffer;
        buffer = [aDecoder decodeBytesForKey:@"boarda" returnedLength:&len];
        memcpy(_board->a, buffer, 64 * sizeof(char));
        
        _difficulty = (Difficulty)[aDecoder decodeIntegerForKey:@"difficulty"];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeBytes:(const uint8_t *)_board->a length:sizeof(char) * 61 * 64 forKey:@"boarda"];
    [aCoder encodeInteger:self.difficulty forKey:@"difficulty"];
}

- (BOOL)takeTurn:(Player *)player atX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass
{
    NSString *boardStr = [self.match.board toStringAscii];
    bool result = setBoardFromString(_board, [boardStr cStringUsingEncoding:NSASCIIStringEncoding]);
    NSAssert(result == true, @"failetoconvert");

    char playerColor = player.color == PieceColorBlack ? BLACK : WHITE;
    
    bool legalMoves[64];
    char computerHasLegalMove = findLegalMoves(_board, legalMoves, playerColor);
    if (!computerHasLegalMove)
    {
        FothelloGame *game = [FothelloGame sharedInstance];
        [game pass];
        return NO;
    }
    char nextMove = getMove(_board, legalMoves, playerColor, 1, (BoardDiffculty)_difficulty); // todo: boardnum

    char ay = nextMove / 8;
    char ax = nextMove % 8;
    
    printf("placed %d %d\n", ax, ay);

    Match *match = self.match;
    return [match placePieceForPlayer:player atX:ax Y:ay];
}


- (void)resetWithDifficulty:(Difficulty)difficulty
{
    _board = makeBoard();
    _difficulty = difficulty;
}
@end

