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

@interface AIStrategy ()
@property (nonatomic) BOOL firstPlayer;
@property (nonatomic) Difficulty difficulty;
@end

@implementation AIStrategy
@synthesize firstPlayer = _firstPlayer;
@synthesize difficulty = _difficulty;

- (void)setupMini:(BOOL)firstPlayer
{
    char isFlipped  = NO;
    
    // globals not good but miniothello uses them.
    if (firstPlayer)
    {
        player1 = COMPUTER;
        player2 = HUMAN;
    }
    else
    {
        player1 = HUMAN;
        player2 = COMPUTER;
    }
    
    searchDepth = SEARCH_BEGINNER;
    originalSearchDepth = searchDepth;
    bruteForceDepth = BRUTE_FORCE_BEGINNER;
    winLarge = DEF_WIN_LARGE;
    mpcDepth = MPC_NOVICE; // not used.
    boardFlipped = isFlipped = DEF_IS_FLIPPED;
    randomnessLevel = DEF_RANDOMNESS_LEVEL;
    showLegalMoves = false;
    useAndersson = false;
    showDots = false;
    selfPlayLimit = 127;  // big enough.
    srand((unsigned)time(NULL));
}

- (id)initWithMatch:(Match *)match firstPlayer:(BOOL)firstPlayer
{
    self = [super initWithMatch:match firstPlayer:firstPlayer];
    if (self)
    {
        _board = makeBoard(NO);
        _firstPlayer = firstPlayer;
        _difficulty = match.difficulty;
        [self setupMini:firstPlayer];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _board = makeBoard(NO);
        
        [self setupMini:self.firstPlayer];
        
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

- (BOOL)takeTurn:(Player *)player atX:(NSInteger)x Y:(NSInteger)y
{
    bool legalMoves[64];
    _board->wt = self.firstPlayer ? WHITE : BLACK;
    
    char humanHasLegalMove = findLegalMoves(_board, legalMoves);
    //    printBoard(_board, legalMoves);

    if (x == -1)
        makePass(_board);
    else
        makeMove(_board, x, y);
    
    printBoard(_board, legalMoves);

    Match *match = self.match;
    _board->wt = self.firstPlayer ? BLACK : WHITE;

    char computerHasLegalMove = findLegalMoves(_board, legalMoves);
    if (!humanHasLegalMove && !computerHasLegalMove)
        return NO; // game over
    char nextMove = getMinimaxMove(_board, legalMoves);

    char ay = nextMove / 8;
    char ax = nextMove % 8;
    
    //    printBoard(_board, legalMoves);
    printf("placed %d %d\n", ax, ay);

    if (legalMove(_board, ax, ay))
    {
        makeMove(_board, ax, ay);
        //        printBoard(_board, legalMoves);

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
    switch (difficulty)
    {
        case DifficultyEasy:
        case DifficultyNone:
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
            
        default:
            [NSException raise:@"bad index" format:@"%@", self];
            break;
    }
    
    originalSearchDepth = searchDepth;
}

- (void)resetWithDifficulty:(Difficulty)difficulty
{
    initBoard(_board, NO);
    _difficulty = difficulty;
    [self setupDifficulty:difficulty];
}
@end

