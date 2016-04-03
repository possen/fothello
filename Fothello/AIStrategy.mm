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
#import "Match.h"
#import "Player.h"
#import "GameBoard.h"



#pragma mark - AIStrategy -

@interface AIStrategy ()
@property (nonatomic) Difficulty difficulty;
@end

@implementation AIStrategy
@synthesize difficulty = _difficulty;

- (id)initWithMatch:(Match *)match
{
    self = [super initWithMatch:match];
    if (self)
    {
        _difficulty = match.difficulty;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _difficulty = (Difficulty)[aDecoder decodeIntegerForKey:@"difficulty"];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeInteger:self.difficulty forKey:@"difficulty"];
}

- (BOOL)takeTurn:(Player *)player atX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass
{
    Board *board = makeBoard();

    NSString *boardStr = [self.match.board toStringAscii];
    bool result = setBoardFromString(board, [boardStr cStringUsingEncoding:NSASCIIStringEncoding]);
    NSAssert(result == true, @"failetoconvert");

    char playerColor = player.color == PieceColorBlack ? BLACK : WHITE;
    
    char nextMove = getMove(board, playerColor, self.match.board.piecesPlayed.count, (BoardDiffculty)_difficulty);
    if (nextMove == -1) {
        FothelloGame *game = [FothelloGame sharedInstance];
        [game pass];
        return NO;
    }
    char ay = nextMove / 8;
    char ax = nextMove % 8;
    
    printf("placed %d %d\n", ax, ay);

    Match *match = self.match;
    return [match placePieceForPlayer:player atX:ax Y:ay];
}

@end

