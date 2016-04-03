//
//  Fothello.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/10/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum PieceColor : NSInteger
{
    PieceColorNone,
    PieceColorBlack,
    PieceColorWhite,
    PieceColorRed,     // for 3 or more players
    PieceColorBlue,
    PieceColorGreen,
    PieceColorYellow,
    PieceColorLegal    // show legal moves
} PieceColor;

typedef enum Direction : NSInteger
{
    DirectionNone = 0,
    DirectionUp = 1,     DirectionFirst = 1,
    DirectionUpLeft,
    DirectionLeft,
    DirectionDownLeft,
    DirectionDown,
    DirectionDownRight,
    DirectionRight,
    DirectionUpRight,
    DirectionLast
} Direction;

typedef struct Delta
{
    NSInteger dx;
    NSInteger dy;
} Delta;

typedef struct Position
{
    NSInteger x;
    NSInteger y;
} Position;

typedef enum PlayerType : NSInteger
{
    PlayerTypeNone = 0,
    PlayerTypeHuman,
    PlayerTypeComputer
} PlayerType;

typedef enum Difficulty : NSInteger
{
    DifficultyNone = 0,
    DifficultyEasy,
    DifficultyModerate,
    DifficultyHard,
    DifficultyHardest
} Difficulty;


@class Match;
@class FBoard;
@class Piece;
@class Player;
@class Strategy;

#pragma mark - PiecePosition - 

@interface PiecePosition : NSObject
@property (nonatomic) Piece *piece;
@property (nonatomic) Position position;
@end

typedef void (^PlaceBlock)(NSArray *pieces);
typedef void (^CurrentPlayerBlock)(Player *player, BOOL canMove);
typedef void (^MatchStatusBlock)(BOOL gameOver);

#pragma mark - Fothello -

@interface FothelloGame : NSObject <NSCoding>

+ (id)sharedInstance;

- (Match *)matchWithName:(NSString *)name       // name can be nil for automatic name
                 players:(NSArray *)players
              difficulty:(Difficulty)difficulty;

- (void)saveGameState;
- (void)ready;
- (void)pass;
- (void)reset;

- (void)matchWithDifficulty:(Difficulty)difficulty
          firstPlayerColor:(PieceColor)pieceColor
              opponentType:(PlayerType)playerType;

- (BOOL)takeTurnAtX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass;

- (void)processOtherTurnsX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass;

@property (nonatomic) Match *currentMatch;
@property (nonatomic) NSMutableArray *matches;
@property (nonatomic) NSMutableArray *players;
@end

#pragma mark - Player -

@interface Player : NSObject <NSCoding>

@property (nonatomic) NSString *name;
@property (nonatomic) PieceColor preferredPieceColor;
@property (nonatomic) PieceColor color;
@property (nonatomic) Strategy *strategy;
@property (nonatomic) NSInteger score;
@property (nonatomic) id userReference;
@property (nonatomic) BOOL canMove;

- (instancetype)initWithName:(NSString *)name;
- (BOOL)takeTurnAtX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass;
- (BOOL)otherPlayer:(Player *)player movedToX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass;

@end

#pragma mark - Piece -

@interface Piece : NSObject <NSCoding>
@property (nonatomic) PieceColor color;
@property (nonatomic) id userReference; // Store reference to UI object

- (BOOL)isClear;
- (void)clear;
@end

#pragma mark - Board -

@interface FBoard : NSObject <NSCoding>

- (id)initWithBoardSize:(NSInteger)size;
- (id)initWithBoardSize:(NSInteger)size
       piecePlacedBlock:(PlaceBlock)block;

- (Piece *)pieceAtPositionX:(NSInteger)x Y:(NSInteger)y;
- (void)reset;
- (Position)center;
- (void)visitAll:(void (^)(NSInteger x, NSInteger y, Piece *piece))block;
- (void)changePiece:(Piece *)piece withColor:(PieceColor)color;
- (BOOL)boardFull;
- (NSString *)toString;
- (NSString *)toStringAscii;

@property (nonatomic) NSMutableArray *grid;
@property (nonatomic) NSInteger size;
@property (nonatomic, copy) PlaceBlock placeBlock;
@property (nonatomic) NSMutableDictionary *piecesPlayed;
@end

#pragma mark - Match -

@interface Match : NSObject <NSCoding>

- (instancetype)initWithName:(NSString *)name
                     players:(NSArray *)players
                  difficulty:(Difficulty)difficulty;

- (BOOL)placePieceForPlayer:(Player *)player atX:(NSInteger)x Y:(NSInteger)y;
- (void)reset;
- (void)test;
- (BOOL)done;
- (void)nextPlayer;
- (void)processOtherTurnsX:(NSInteger)humanX Y:(NSInteger)y pass:(BOOL)pass;
- (void)ready;
- (BOOL)beginTurn;
- (void)endTurn;
- (NSInteger)calculateScore:(Player *)player;

@property (nonatomic) NSString *name;
@property (nonatomic) FBoard *board;
@property (nonatomic) NSArray *players;
@property (nonatomic) Player *currentPlayer;
@property (nonatomic) Difficulty difficulty; // only used by AIStrategy
@property (nonatomic, copy) CurrentPlayerBlock currentPlayerBlock;
@property (nonatomic, copy) MatchStatusBlock matchStatusBlock;
@end

#pragma mark - Strategy -

@interface Strategy : NSObject <NSCoding>

@property (nonatomic) Match *match;
@property (nonatomic, readonly) BOOL manual;

- (id)initWithMatch:(Match *)match ;
- (BOOL)takeTurn:(Player *)player atX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass;
- (BOOL)otherPlayer:(Player *)player movedToX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass;
- (BOOL)displaylegalMoves:(BOOL)display forPlayer:(Player *)player;
- (void)resetWithDifficulty:(Difficulty)difficulty;
- (void)pass;
- (void)convertBoard;

@end

#pragma mark - BoxStrategy -

@interface BoxStrategy : Strategy <NSCoding>
@end

#pragma mark - HumanStrategy -

@interface HumanStrategy : Strategy <NSCoding>
@end







