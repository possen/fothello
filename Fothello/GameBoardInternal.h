//
//  GameBoardInternal.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/20/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Player.h"

@class Piece;
@class BoardPosition;

@interface GameBoardInternal : NSObject <NSCoding>

- (nonnull instancetype)initWithBoard:(nonnull GameBoard *)board size:(NSInteger)size;

- (nonnull BoardPosition *)center;
- (nullable Piece *)pieceAtPositionX:(NSInteger)x Y:(NSInteger)y;
- (NSInteger)playerScoreUnqueued:(nonnull Player *)player;
- (void)visitAllUnqueued:(nonnull void (^)(NSInteger x, NSInteger y, Piece *_Nonnull piece))block;

@end
