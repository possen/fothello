//
//  AIStrategy.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/18/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import "AIStrategy.h"
#import "FothelloGame.h"
#import "board.hpp"
#import "minimax.hpp"

#pragma mark - AIStrategy -

@interface AIStrategy ()
@property (nonatomic) BOOL firstPlayer;
@property (nonatomic) Difficulty difficulty;
@end

@implementation AIStrategy
@synthesize firstPlayer = _firstPlayer;
@synthesize difficulty = _difficulty;

- (void)setupMini
{
    startNew(self.difficulty);
}

- (id)initWithMatch:(Match *)match firstPlayer:(BOOL)firstPlayer
{
    self = [super initWithMatch:match firstPlayer:firstPlayer];
    if (self)
    {
        _board = makeBoard(NO);
        _firstPlayer = firstPlayer;
        _difficulty = match.difficulty;
        [self setupMini];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _board = makeBoard(NO);
        
        [self setupMini];
        
        NSUInteger len =  sizeof(char) * 61 * 64;
        const uint8_t *buffer;
        buffer = [aDecoder decodeBytesForKey:@"boarda" returnedLength:&len];
        memcpy(_board->a, buffer, 61 * 64 * sizeof(char));
        buffer = [aDecoder decodeBytesForKey:@"boardmoves" returnedLength:&len];
        memcpy(_board->moves, buffer, 128 * sizeof(char));
        
        _board->n = [aDecoder decodeInt32ForKey:@"n"];
        _board->m = [aDecoder decodeInt32ForKey:@"m"];
        _board->top = [aDecoder decodeInt32ForKey:@"top"];
        _board->wt = [aDecoder decodeInt32ForKey:@"wt"];
        _difficulty = (Difficulty)[aDecoder decodeIntegerForKey:@"difficulty"];
        [self setupDifficulty:_difficulty];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeBytes:(const uint8_t *)_board->a length:sizeof(char) * 61 * 64 forKey:@"boarda"];
    [aCoder encodeBytes:(const uint8_t *)_board->moves length:sizeof(char) * 128 forKey:@"boardmoves"];
    [aCoder encodeInt32:_board->n forKey:@"n"];
    [aCoder encodeInt32:_board->m forKey:@"m"];
    [aCoder encodeInt32:_board->top forKey:@"top"];
    [aCoder encodeInt32:_board->wt forKey:@"wt"];
    [aCoder encodeInteger:self.difficulty forKey:@"difficulty"];
}

- (void)convertBoard
{
    // todo
    char *a = _board->a[0];

    FothelloGame *game = [FothelloGame sharedInstance];

    [game.currentMatch.board visitAll:^(NSInteger x, NSInteger y, Piece *piece)
    {
        a[y * 8 + x] = [piece isClear] ? EMPTY :
                        piece.color == PieceColorBlack
                         ? BLACK
                         : WHITE;
        
    }];
}

- (BOOL)takeTurn:(Player *)player atX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass
{
    [super takeTurn:player atX:x Y:y pass:pass];
    bool legalMoves[64];
    _board->wt = self.firstPlayer ? WHITE : BLACK;
    
    char humanHasLegalMove = findLegalMoves(_board, legalMoves);
    //    printBoard(_board, legalMoves);

    if (pass) // negative means pass.
        makePass(_board);
    else
        makeMove(_board, x, y);
    
    //printBoard(_board, legalMoves);

    Match *match = self.match;
    _board->wt = self.firstPlayer ? BLACK : WHITE;

    char computerHasLegalMove = findLegalMoves(_board, legalMoves);
    if (!humanHasLegalMove && !computerHasLegalMove)
        return NO; // game over
    char nextMove = getMinimaxMove(_board, legalMoves);

    char ay = nextMove / 8;
    char ax = nextMove % 8;
    
    printf("placed %d %d\n", ax, ay);

    if (legalMove(_board, ax, ay))
    {
        makeMove(_board, ax, ay);

        return [match placePieceForPlayer:player atX:ax Y:ay];
    }
    else
    {
        makePass(_board);
        
        FothelloGame *game = [FothelloGame sharedInstance];
        [game pass];
        return NO;
    }

    return YES;
}

- (void)setupDifficulty:(Difficulty)difficulty
{
    startNew(difficulty);
}

- (void)resetWithDifficulty:(Difficulty)difficulty
{
    initBoard(_board, NO);
    _difficulty = difficulty;
    [self setupDifficulty:difficulty];
}
@end

