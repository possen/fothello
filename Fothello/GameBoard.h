//
//  GameBoard.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/2/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//
//  Manages the game pieces in a 8x8 grid.
//  Finds legal moves and determines what pieces should be flipped for a move.
//  Keeps track of what pieces were played. All accesses to board must be done
//  the queue to ensure data integrity.
//


#import <Foundation/Foundation.h>

#import "Player.h"

@class Piece;
@class BoardPosition;
@class PlayerMove;

typedef void (^PlaceBlock)(NSArray<NSArray<BoardPiece *> *> * _Nullable pieces);
typedef void (^HighlightBlock)(BoardPosition * _Nonnull  move, PieceColor color);
typedef void (^UpdateCompleteBlock)(void);

@interface GameBoard : NSObject 
- (nonnull id)initWithBoardSize:(NSInteger)size;
- (nonnull id)initWithBoardSize:(NSInteger)size piecePlacedBlock:(nullable PlaceBlock)block;
- (void)visitAll:(nonnull void (^)(NSInteger x, NSInteger y, Piece * _Nullable piece))block;
- (void)reset;
- (nonnull NSString *)requestFormat;

- (void)placeMoves:(nonnull NSArray<PlayerMove *> *)moves;
- (nonnull NSArray <BoardPiece *> *)legalMovesForPlayerColor:(PieceColor)color;
- (void)isLegalMove:(nonnull PlayerMove *)move forPlayer:(nonnull Player *)player legal:(void (^ _Nonnull)(BOOL))legal;
- (void)showLegalMoves:(BOOL)display forPlayer:(nonnull Player *)player;

// non queued safe
- (void)showHintMove:(nonnull PlayerMove *)move forPieceColor:(PieceColor)color;
- (void)showClickedMove:(nonnull PlayerMove *)move forPieceColor:(PieceColor)color;
- (BOOL)isFull;
- (BOOL)canMove:(nonnull Player *)player;
- (NSInteger)playerScore:(nonnull Player *)player;

// updates or reads board on queue, if nothing to update return @[];
- (void)updateBoard:(nullable NSArray<NSArray <BoardPiece *> *> * _Nonnull(^)(void))updateFunction;

@property (nonatomic, copy, nullable) HighlightBlock highlightBlock;
@property (nonatomic, copy, nullable) UpdateCompleteBlock updateCompleteBlock;
@property (nonatomic, nonnull) dispatch_queue_t queue;
@property (nonatomic, readwrite, nonnull) NSDictionary<NSNumber *, NSNumber *> *piecesPlayed;
@property (nonatomic, readonly) NSInteger size;
@property (nonatomic, copy, nullable) PlaceBlock placeBlock;

@end
