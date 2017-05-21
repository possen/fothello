//
//  GameBoardLegalMoves.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/20/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import "GameBoardLegalMoves.h"
#import "FothelloGame.h"
#import "GameBoardInternal.h"
#import "Player.h"
#import "PlayerMove.h"
#import "BoardPiece.h"
#import "BoardPosition.h"
#import "NSArray+Holes.h"
#import "Piece.h"

@interface GameBoardLegalMoves ()
@property (nonatomic) GameBoardInternal *internal;
@end

@interface GameBoardInternal ()
- (NSArray<NSArray <BoardPiece *> *> *)findTracksForBoardPiece:(BoardPiece *)boardPiece
                                                         color:(PieceColor)pieceColor;

@end

@implementation GameBoardLegalMoves

- (instancetype)initWithGameBoard:(GameBoardInternal *)gameBoard
{
    self = [super init];
    if (self) {
        _internal = gameBoard;
        _legalMovesForPlayer = [@[@[], @[]] mutableCopy];
    }
    return self;
}

- (void)determineLegalMoves
{
    // Make copy to update, so it can be read outside queue.
    NSMutableArray<NSArray<BoardPiece *>*> *legalPieces = [self.legalMovesForPlayer mutableCopy];
    for (PieceColor color = PieceColorBlack; color <= PieceColorWhite; color ++)
    {
        NSArray <BoardPiece *> *legalMoves = [self legalMovesForPlayerColor:color];
        [legalPieces setObject:legalMoves atCheckedIndex:color];
    }
    
    self.legalMovesForPlayer = legalPieces;
}

- (BOOL)isLegalMove:(PlayerMove *)move forPlayer:(Player *)player
{
    NSArray <BoardPiece *> *legalMoves = [self.legalMovesForPlayer objectAtCheckedIndex:player.color];
    
    BOOL legalMove = legalMoves != nil
    && [legalMoves indexOfObjectPassingTest:^
        BOOL (BoardPiece *boardPiece, NSUInteger idx, BOOL *stop) {
            return boardPiece.position.x == move.position.x
            && boardPiece.position.y == move.position.y;
        }] != NSNotFound;
    
    return legalMove;
}

- (NSArray <BoardPiece *> *)legalMovesForPlayerColor:(PieceColor)color
{
    NSMutableArray<BoardPiece *>*pieces = [[NSMutableArray alloc] initWithCapacity:10];
    GameBoardInternal *internal = self.internal;
    
    // Determine moves
    [internal visitAllUnqueued:^(NSInteger x, NSInteger y, Piece *findPiece) {
        BoardPosition *boardPosition = [BoardPosition positionWithX:x y:y];
        BoardPiece *findBoardPiece = [BoardPiece makeBoardPieceWithPiece:findPiece position:boardPosition color:color];
        
        BOOL foundTrack = [internal findTracksForBoardPiece:findBoardPiece color:color] != nil;
        if (foundTrack)
        {
            Piece *piece = [internal pieceAtPositionX:x Y:y];
            [pieces addObject:[BoardPiece makeBoardPieceWithPiece:piece position:boardPosition color:PieceColorLegal]];
        }
    }];
    
    return [pieces copy];
}

- (NSArray<BoardPiece *> *)findLegals:(NSArray<BoardPiece *> *)pieces
{
    GameBoardInternal *internal = self.internal;

    NSIndexSet *legals = [pieces indexesOfObjectsPassingTest:
                          ^BOOL(BoardPiece *piece, NSUInteger idx, BOOL * stop) {
                              Piece *currentPiece = [internal pieceAtPositionX:piece.position.x Y:piece.position.y];
                              BOOL result = currentPiece.color == PieceColorLegal;
                              return result;
                          }];
    
    pieces = [pieces objectsAtIndexes:legals];
    [pieces enumerateObjectsUsingBlock:^(BoardPiece *piece, NSUInteger idx, BOOL *stop) {
        piece.color = PieceColorNone;
    }];
    return pieces;
}


@end
