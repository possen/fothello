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

+ (PlayerMove *)makeMoveWithPiece:(Piece *)piece position:(BoardPosition *)pos
{
    PlayerMove *move = [[PlayerMove alloc] init];
    move.piece = piece;
    move.position = pos;
    return move;
}

+ (PlayerMove *)makePassMoveWithPiece:(Piece *)piece
{
    PlayerMove *move = [[PlayerMove alloc] init];
    move.piece = piece;
    move.position = [BoardPosition positionWithPass];
    return move;
}

- (NSString *)description
{
    NSString  *pieceStr = self.piece.description;
    return (!self.isPass)
    ? [NSString stringWithFormat:@"%@ %ld - %ld ", pieceStr, (long)self.position.x + 1, (long)self.position.y + 1]
    : [NSString stringWithFormat:@"%@ Pass", pieceStr];
}

- (BOOL)isPass
{
    return self.position.x == -1;
}

@end

