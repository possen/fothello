//
//  BoardPiece.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/27/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FothelloGame.h"

#pragma mark - BoardPiece -

@class Piece;
@class BoardPosition;

// used more generically for any color and position on the board.
@interface BoardPiece : NSObject <NSCopying>

@property (nonatomic) Piece *piece;
@property (nonatomic) BoardPosition *position;
@property (nonatomic) PieceColor color;

+ (BoardPiece *)makeBoardPieceWithPiece:(Piece *)piece position:(BoardPosition *)position color:(PieceColor)color;

@end
