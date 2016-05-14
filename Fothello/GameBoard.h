//
//  GameBoard.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/2/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Player.h"

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

@class Piece;

#pragma mark - Move -

@interface BoardPosition : NSObject
@property (nonatomic) NSInteger x;
@property (nonatomic) NSInteger y;
@property (nonatomic, readonly, getter=isPass) BOOL pass;

- (instancetype)initWithPass;
- (instancetype)initWithX:(NSInteger)x Y:(NSInteger)y;

+ (instancetype)positionWithPass;
+ (instancetype)positionWithX:(NSInteger)x y:(NSInteger)y;
+ (instancetype)positionWithX:(NSInteger)x y:(NSInteger)y pass:(BOOL)pass;

@end

#pragma mark - BoardPiece -

// used more generically for any color and position on the board.
@interface BoardPiece : NSObject
@property (nonatomic) Piece *piece;
@property (nonatomic) BoardPosition *position;
+ (BoardPiece *)makeBoardPieceWithPiece:(Piece *)piece position:(BoardPosition *)position;
@end

typedef void (^PlaceBlock)(NSArray<BoardPiece *> *pieces);

#pragma mark - Piece -

@interface Piece : NSObject <NSCoding>
@property (nonatomic) PieceColor color;
@property (nonatomic) id userReference; // Store reference to UI object

- (instancetype)initWithColor:(PieceColor)color;

- (BOOL)isClear;
- (void)clear;
@end

#pragma mark - Board -

@interface GameBoard : NSObject <NSCoding>

- (id)initWithBoardSize:(NSInteger)size queue:(dispatch_queue_t)queue;
- (id)initWithBoardSize:(NSInteger)size
                  queue:(dispatch_queue_t)queue
       piecePlacedBlock:(PlaceBlock)block;

- (Piece *)pieceAtPositionX:(NSInteger)x Y:(NSInteger)y;
- (void)reset;
- (BoardPosition *)center;
- (void)visitAll:(void (^)(NSInteger x, NSInteger y, Piece *piece))block;
- (void)changePiece:(Piece *)piece withColor:(PieceColor)color;
- (BOOL)boardFull;
- (NSString *)toString;
- (NSString *)toStringAscii;
- (NSInteger)playerScore:(Player *)player;
- (BOOL)player:(Player *)player pieceAtPositionX:(NSInteger)x Y:(NSInteger)y;
- (void)updateBoardWithMoves:(NSArray <BoardPiece *> *)moves;
- (void)updateBoardWithFunction:(NSArray<BoardPiece *> *(^)())updateFunction;

@property (nonatomic) NSMutableArray<Piece *> *grid;
@property (nonatomic) NSInteger size;
@property (nonatomic, copy) PlaceBlock placeBlock;
@property (nonatomic) NSMutableDictionary<NSNumber *, NSNumber *> *piecesPlayed;
@end
