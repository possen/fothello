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

@class Match;
@class Board;
@class Piece;
@class Player;
@class Strategy;

typedef void (^PlaceBlock)(NSInteger x, NSInteger y, Piece *piece);

#pragma mark - Classes -

#pragma mark - Fothello -

@interface FothelloGame : NSObject <NSCoding>

+ (id)sharedInstance;
- (Match *)newMatch:(NSString *)name players:(NSArray *)players; // name can be nil for automatic name
- (void)saveGameState;

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

- (instancetype)initWithName:(NSString *)name;
- (BOOL)takeTurnAtX:(NSInteger)x Y:(NSInteger)y;
@end

#pragma mark - Piece -

@interface Piece : NSObject <NSCoding>
@property (nonatomic) PieceColor color;
@property (nonatomic) id identifier; // Store reference to UI object

- (BOOL)isClear;
- (void)clear;
@end

#pragma mark - Board -

@interface Board : NSObject <NSCoding>

- (id)initWithBoardSize:(NSInteger)size;
- (id)initWithBoardSize:(NSInteger)size
       piecePlacedBlock:(void (^)(NSInteger x, NSInteger y, Piece *piece))block;

- (Piece *)pieceAtPositionX:(NSInteger)x Y:(NSInteger)y;
- (void)reset;
- (Position)center;
- (void)visitAll:(void (^)(NSInteger x, NSInteger y, Piece *piece))block;


@property (nonatomic) NSMutableArray *grid;
@property (nonatomic) NSInteger size;
@property (nonatomic, copy) PlaceBlock placeBlock;
@end

#pragma mark - Match -

@interface Match : NSObject <NSCoding>
- (instancetype)initWithName:(NSString *)name players:(NSArray *)players;
- (BOOL)placePieceForPlayer:(Player *)player atX:(NSInteger)x Y:(NSInteger)y;
- (void)reset;
- (void)test;
- (BOOL)done;
- (void)nextPlayer;

@property (nonatomic) NSString *name;
@property (nonatomic) Board *board;
@property (nonatomic) NSArray *players;
@property (nonatomic) Player *currentPlayer;

@end

#pragma mark - Strategy -

@interface Strategy : NSObject <NSCoding>

@property (nonatomic) Match *match;
@property (nonatomic) NSString *name;
@property (nonatomic) BOOL manual;

- (id)initWithMatch:(Match *)match name:(NSString *)name;
- (BOOL)takeTurn:(Player *)player atX:(NSInteger)x Y:(NSInteger)y;

@end

#pragma mark - BoxStrategy -

@interface BoxStrategy : Strategy <NSCoding>
@end

#pragma mark - HumanStrategy -

@interface HumanStrategy : Strategy <NSCoding>
@end





