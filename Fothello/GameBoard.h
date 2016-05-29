//
//  GameBoard.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/2/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//
//  Manages the game pieces in a 8x8 grid.
//  Finds legal moves and determines what pieces should be flipped for a move.
//  Keeps track of what pieces were played.


#import <Foundation/Foundation.h>

#import "Player.h"

@class Piece;
@class BoardPosition;
@class PlayerMove;

typedef void (^PlaceBlock)(NSArray<NSArray<BoardPiece *> *> * _Nullable pieces);
typedef void (^HighlightBlock)(PlayerMove * _Nonnull  move, PieceColor color);

#pragma mark - GameBoard -

@interface GameBoard : NSObject <NSCoding>

- (nonnull id)initWithBoardSize:(NSInteger)size;
- (nonnull id)initWithBoardSize:(NSInteger)size piecePlacedBlock:(nullable PlaceBlock)block;
- (nullable Piece *)pieceAtPositionX:(NSInteger)x Y:(NSInteger)y;
- (void)visitAll:(nonnull void (^)(NSInteger x, NSInteger y, Piece * _Nullable piece))block;
- (BOOL)isFull;
- (void)reset;
- (nonnull NSString *)requestFormat;
- (NSInteger)playerScore:(nonnull Player *)player;

- (void)placeMove:(nonnull PlayerMove *)move forPlayer:(nonnull Player *)player showMove:(BOOL)showMove;
- (void)showHintMove:(nonnull PlayerMove *)move forPlayer:(nonnull Player *)player;

- (nullable NSArray<NSArray <BoardPiece *> *> *)findTracksForBoardPiece:(nonnull BoardPiece *)piece
                                                                 player:(nonnull Player *)player;

- (nullable NSArray <BoardPiece *> *)legalMovesForPlayer:(nonnull Player *)player;

- (void)showLegalMoves:(BOOL)display forPlayer:(nonnull Player *)player;

- (void)boxCoord:(NSInteger)dist
           block:(nonnull void (^)(BoardPosition * _Nonnull position, BOOL isCorner, NSInteger count, BOOL * _Nullable stop))block;

- (BOOL)canMove:(nonnull Player *)player;
- (nonnull NSArray<BoardPiece *>*)updateWithTrack:(nonnull NSArray<Piece *>*)trackInfo position:(nonnull BoardPosition *)position player:(nonnull Player *)player;

@property (nonatomic) NSInteger size;
@property (nonatomic, copy, nullable)  PlaceBlock placeBlock;
@property (nonatomic, nonnull) NSMutableDictionary<NSNumber *, NSNumber *> *piecesPlayed;
@property (nonatomic, copy, nullable) HighlightBlock highlightBlock;
@end
