//
//  GameBoardInternal.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/20/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Player.h"
#import "GameBoard.h"

@class Piece;
@class BoardPosition;
@class GameBoardLegalMoves;
@class GameBoardTracks;

@interface GameBoardInternal : NSObject <NSCoding>

@property (nonnull, nonatomic, readonly) GameBoardLegalMoves *legalMoves;
@property (nonnull, nonatomic, readonly) GameBoardTracks *tracker;

- (nonnull instancetype)initWithBoard:(nonnull GameBoard *)board size:(NSInteger)size piecePlacedBlock:(nonnull PlaceBlock)block;
- (nonnull BoardPosition *)center;
- (nullable Piece *)pieceAtPositionX:(NSInteger)x Y:(NSInteger)y;
- (nullable Piece *)pieceAtPosition:(nonnull BoardPosition *)pos;
- (NSInteger)playerScoreUnqueued:(nonnull Player *)player;
- (void)visitAllUnqueued:(nonnull void (^)(NSInteger x, NSInteger y, Piece *_Nonnull piece))block;

@end
