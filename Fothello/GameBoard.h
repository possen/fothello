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

typedef void (^PlaceBlock)(NSArray<BoardPiece *> * _Nullable pieces);

#pragma mark - GameBoard -

@interface GameBoard : NSObject <NSCoding>

- (nonnull id)initWithBoardSize:(NSInteger)size queue:(nonnull dispatch_queue_t)queue;
- (nonnull id)initWithBoardSize:(NSInteger)size
                  queue:(nonnull dispatch_queue_t)queue
       piecePlacedBlock:(nullable PlaceBlock)block;

- (nullable Piece *)pieceAtPositionX:(NSInteger)x Y:(NSInteger)y;
- (nonnull NSArray<BoardPiece *> *)erase;
- (nonnull BoardPosition *)center;
- (void)visitAll:(nonnull void (^)(NSInteger x, NSInteger y, Piece * _Nullable piece))block;
- (BOOL)boardFull;
- (nonnull NSString *)toString;
- (nonnull NSString *)toStringAscii;
- (NSInteger)playerScore:(nonnull Player *)player;
- (void)updateBoardWithFunction:(nonnull NSArray<BoardPiece *> * _Nonnull (^)())updateFunction;
- (BOOL)findTracksForMove:(nonnull BoardPiece *)move
                forPlayer:(nonnull Player *)player
               trackBlock:(nullable void (^)(NSArray<BoardPiece *> * _Nonnull positions))trackBlock;
- (void)boxCoord:(NSInteger)dist
           block:(nonnull void (^)(BoardPosition * _Nonnull position, BOOL isCorner, NSInteger count, BOOL * _Nullable stop))block;
- (nonnull NSArray<BoardPiece *>*)updateWithTrack:(nonnull NSArray<Piece *>*)trackInfo position:(nonnull BoardPosition *)position player:(nonnull Player *)player;

@property (nonatomic) NSInteger size;
@property (nonatomic, copy, nullable)  PlaceBlock placeBlock;
@property (nonatomic, nonnull) NSMutableDictionary<NSNumber *, NSNumber *> *piecesPlayed;
@end
