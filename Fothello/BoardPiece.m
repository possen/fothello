//
//  BoardPiece.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/27/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "BoardPiece.h"
#import "Piece.h"
#import "BoardPosition.h"

#pragma mark - BoardPiece -

@implementation BoardPiece

- (instancetype)copyWithZone:(NSZone *)zone
{
    BoardPiece *boardPiece = [[self class] allocWithZone:zone];
    boardPiece.piece = [self.piece copy];
    boardPiece.position = [self.position copy];
    boardPiece.color = self.color;
    return boardPiece;
}

+ (BoardPiece *)makeBoardPieceWithPiece:(Piece *)piece position:(BoardPosition *)pos color:(PieceColor)color
{
    BoardPiece *boardPiece = [[BoardPiece alloc] init];
    boardPiece.piece = piece;
    boardPiece.position = pos;
    boardPiece.color = color;
    return boardPiece;
}

- (NSUInteger)hash
{
    return self.position.hash ^ self.piece.color;
}

- (BOOL)isEqual:(BoardPiece *)other
{
    return [self.position isEqual:other.position] && self.piece.color == other.piece.color;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%ld - %ld %@ -> %@", (long)self.position.x + 1,
           (long)self.position.y + 1, self.piece.description,
            [Piece stringFromColor:self.color]];
}

@end

