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
@class GameBoard;
@class Piece;
@class Player;
@class Strategy;

@interface Position : NSObject 
@property (nonatomic) NSInteger x;
@property (nonatomic) NSInteger y;
@end

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






