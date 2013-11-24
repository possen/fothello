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

#define SEARCH_NOVICE             4
#define SEARCH_BEGINNER           6
#define SEARCH_AMATEUR            8
#define SEARCH_EXPERIENCED        10

#define BRUTE_FORCE_NOVICE        12
#define BRUTE_FORCE_BEGINNER      14
#define BRUTE_FORCE_AMATEUR       16
#define BRUTE_FORCE_EXPERIENCED   19

// MPC not yet implemented
#define MPC_NOVICE        0
#define MPC_BEGINNER      0
#define MPC_AMATEUR       0
#define MPC_EXPERIENCED   0

// Default values
#define DEF_WIN_LARGE         1
#define DEF_IS_FLIPPED        0
#define DEF_RANDOMNESS_LEVEL  2

#define PROGRAM_NAME "Mini-Othello"
#define VERSION "0.01-alpha-1"

char searchDepth;
char originalSearchDepth;
char bruteForceDepth;
char mpcDepth;
bool winLarge;
char randomnessLevel;
bool useAndersson;
bool boardFlipped;
bool showLegalMoves;
// Non essential vars.
bool showDots;
bool showTime;
char selfPlayLimit;
char player1, player2;
#define HUMAN 1
#define COMPUTER 2

#pragma mark - AIStrategy -

@implementation AIStrategy

- (id)initWithMatch:(Match *)match name:(NSString *)name
{
    self = [super initWithMatch:match name:name];
    if (self)
    {
        char isFlipped  = NO;

        // globals not good but miniothello uses them.
        player1 = HUMAN;
        player2 = COMPUTER;
        searchDepth = SEARCH_BEGINNER;
        originalSearchDepth = searchDepth;
        bruteForceDepth = BRUTE_FORCE_BEGINNER;
        winLarge = DEF_WIN_LARGE;
        mpcDepth = MPC_NOVICE; // not used.
        boardFlipped = isFlipped = DEF_IS_FLIPPED;
        randomnessLevel = DEF_RANDOMNESS_LEVEL;
        showLegalMoves = true;
        useAndersson = false;
        showDots = false;
        selfPlayLimit = 127;  // big enough.
        srand(time(NULL));
        _board = makeBoard(NO);
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _board = makeBoard(NO);
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
}

- (void)convertBoard
{
    // todo
    char *a = _board->a[0];

    [self.match.board visitAll:^(NSInteger x, NSInteger y, Piece *piece)
    {
        a[y * 8 + x] = [piece isClear] ? EMPTY :
                        piece.color == PieceColorBlack
                         ? BLACK
                         : WHITE;
        
    }];
}

- (BOOL)takeTurn:(Player *)player atX:(NSInteger)x Y:(NSInteger)y
{
    bool legalMoves[64];
    _board->wt = BLACK;
    
    char humanHasLegalMove = findLegalMoves(_board, legalMoves);
    printBoard(_board, legalMoves);

    if (x == -1)
        makePass(_board);
    else
        makeMove(_board, x, y);
    
    printBoard(_board, legalMoves);

    Match *match = self.match;
    //   FBoard *board = match.board;
    
    //    [self convertBoard];
    _board->wt = WHITE;

    char computerHasLegalMove = findLegalMoves(_board, legalMoves);
    if (!humanHasLegalMove && !computerHasLegalMove)
        return NO; // game over
    char nextMove = getMinimaxMove(_board, legalMoves);

    char ay = nextMove / 8;
    char ax = nextMove % 8;
    
    printBoard(_board, legalMoves);
    printf("placed %d %d\n", ax, ay);

    if (legalMove(_board, ax, ay))
    {
        makeMove(_board, ax, ay);
        printBoard(_board, legalMoves);

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

- (void)resetWithDifficulty:(Difficulty)difficulty
{
    initBoard(_board, NO);
    switch (difficulty)
    {
        case DifficultyEasy:
            searchDepth = SEARCH_NOVICE;
            bruteForceDepth = BRUTE_FORCE_NOVICE;
            break;
            
        case DifficultyModerate:
            searchDepth = SEARCH_BEGINNER;
            bruteForceDepth = BRUTE_FORCE_BEGINNER;
            break;
            
        case DifficultyHard:
            searchDepth = SEARCH_AMATEUR;
            bruteForceDepth = BRUTE_FORCE_AMATEUR;
            break;
            
        case DifficultyHardest:
            searchDepth = SEARCH_EXPERIENCED;
            bruteForceDepth = BRUTE_FORCE_EXPERIENCED;
            useAndersson = YES;
            break;            
    }
    
    originalSearchDepth = searchDepth;
}
@end

