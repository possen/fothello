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
    PieceColorYellow
} PieceColor;

typedef enum Direction : NSInteger
{
    DirectionNone,
    DirectionUp,
    DirectionUpLeft,
    DirectionLeft,
    DirectionDownLeft,
    DirectionDown,
    DirectionDownRight,
    DirectionRight,
    DirectionUpRight,
    DirectionLast
} Direction;

typedef struct Difference
{
    NSInteger x;
    NSInteger y;
} Difference;

@class Game;
@class Board;
@class Piece;
@class Player;

#pragma mark - Intefaces -

#pragma mark - Fothello -

@interface Fothello : NSObject <NSCoding>
- (Game *)newGame:(NSString *)name players:(NSArray *)players; // name can be nil for automatic name
@property (nonatomic) Game *currentGame;
@property (nonatomic) NSMutableArray *games;
@property (nonatomic) NSMutableArray *players;
@end

#pragma mark - Player -

@interface Player : NSObject <NSCoding>

@property (nonatomic) NSString *name;
@property (nonatomic) PieceColor preferredPieceColor;
@property (nonatomic) PieceColor color;
- (instancetype)initWithName:(NSString *)name;
@end

#pragma mark - Piece -

@interface Piece : NSObject <NSCoding>
@property (nonatomic) PieceColor pieceColor;

- (BOOL)isClear;
- (void)clear;
@end

#pragma mark - Board -

@interface Board : NSObject <NSCoding>
- (id)initWithBoardSize:(NSInteger)size;

- (Piece *)pieceAtPositionX:(NSInteger)x Y:(NSInteger)y;
- (void)reset;

@property (nonatomic) NSMutableArray *grid;
@property (nonatomic) NSInteger size;
@end

#pragma mark - Game -

@interface Game : NSObject <NSCoding>
- (instancetype)initWithName:(NSString *)name players:(NSArray *)players;
- (BOOL)placePieceForPlayer:(Player *)player atX:(NSInteger)x Y:(NSInteger)y;
- (void)reset;
- (void)test;

@property (nonatomic) NSString *name;
@property (nonatomic) Board *board;
@property (nonatomic) NSArray *players;
@property (nonatomic) Player *currentPlayer;

@end

#pragma mark - Strategy -

@interface Strategy : NSObject <NSCoding>

@property (nonatomic) Game *game;

- (id)initWithGame:(Game *)game;

@end



