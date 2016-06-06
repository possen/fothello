//
//  PlayerMove.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/27/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "PlayerMove.h"
#import "Piece.h"
#import "BoardPosition.h"

#pragma mark - PlayerMove -

@implementation PlayerMove

- (instancetype)copyWithZone:(NSZone *)zone
{
    PlayerMove *move = [[self class] allocWithZone:zone];
    move.piece = [self.piece copy];
    move.position = [self.position copy];
    return move;
}

+ (PlayerMove *)makeMoveForColor:(PieceColor)color position:(BoardPosition *)pos
{
    Piece *piece = [[Piece alloc] initWithColor:color];
    PlayerMove *move = [[PlayerMove alloc] init];
    move.piece = piece;
    move.position = pos;
    return move;
}

+ (PlayerMove *)makePassMoveForColor:(PieceColor)color
{
    Piece *piece = [[Piece alloc] initWithColor:color];
    PlayerMove *move = [[PlayerMove alloc] init];
    move.piece = piece;
    move.position.x = -1;
    move.position.y = -1;
    return move;
}

- (NSString *)description
{
    NSString  *pieceStr = self.piece.description;
    return (!self.isPass)
        ? [NSString stringWithFormat:@"%@ %c%ld ", pieceStr, 'A' + (char)self.position.x, 8 - (long)self.position.y]
        : [NSString stringWithFormat:@"%@ Pass", pieceStr];
}

- (BOOL)isPass
{
    return self.position.x == -1;
}

@end

