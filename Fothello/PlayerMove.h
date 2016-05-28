//
//  PlayerMove.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/27/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BoardPiece.h"

@class PlayerMove;
@class BoardPosition;
@class Piece;

// specifically a move that can be replayed.
@interface PlayerMove : BoardPiece <NSCopying>

+ (nonnull PlayerMove *)makeMoveForColor:(PieceColor)piece position:(nonnull BoardPosition *)position;
+ (nonnull PlayerMove *)makePassMoveForColor:(PieceColor)piece;

@property (nonatomic, readonly) BOOL isPass;

@end
