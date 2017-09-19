//
//  GameBoardInternal.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/20/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import "GameBoardInternal.h"
#import "FothelloGame.h"
#import "GameBoard.h"
#import "Player.h"
#import "Piece.h"
#import "BoardPiece.h"
#import "BoardPosition.h"
#import "PlayerMove.h"
#import "NSArray+Extensions.h"
#import "NSDictionary+Extensions.h"
#import "GameBoardString.h"
#import "NSArray+Holes.h"
#import "GameBoardLegalMoves.h"
#import "GameBoardTracks.h"


@interface GameBoardInternal ()
@property (nonatomic) GameBoard *board;
@property (nonatomic) GameBoardString *boardString;
@property (nonatomic, readwrite, nonnull) NSDictionary<NSNumber *, NSNumber *> *piecesPlayed;
@property (nonatomic) NSMutableArray<Piece *> *grid;
@property (nonatomic) NSInteger size;
@end

@implementation GameBoardInternal

- (instancetype)initWithBoard:(GameBoard *)board size:(NSInteger)size piecePlacedBlock:(PlaceBlock)block
{
    self = [super init];
    if (self)
    {
        _boardString = [[GameBoardString alloc] initWithBoard:self];
        _legalMoves = [[GameBoardLegalMoves alloc] initWithGameBoard:self];
        _tracker = [[GameBoardTracks alloc] initWithGameBoard:self];
        _board = board;
        _size = size;
        
        if (size % 2 == 1) return nil; // must be multiple of 2
        NSInteger piecesCount = size * size;
        _grid = [[NSMutableArray alloc] initWithCapacity:piecesCount];
        _piecesPlayed = [NSDictionary new];
        
        // init with empty pieces
        for (NSInteger index = 0; index < piecesCount; index ++)
        {
            [_grid addObject:[[Piece alloc] init]];
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    
    if (self)
    {
        _grid = [coder decodeObjectForKey:@"grid"];
        _size = [coder decodeIntegerForKey:@"size"];
        _piecesPlayed = [coder decodeObjectForKey:@"piecesPlayed"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.grid forKey:@"grid"];
    [aCoder encodeInteger:self.size forKey:@"size"];
    [aCoder encodeObject:self.piecesPlayed forKey:@"piecesPlayed"];
}

#pragma mark - Queue Safe -

//
// These don't update or read data board data structures so are safe
// if called from non queued code or queued code.
//

- (BoardPosition *)center
{
    BoardPosition *pos = [BoardPosition new];
    pos.x = self.size / 2 - 1; // zero based counting
    pos.y = self.size / 2 - 1;
    return pos;
}

- (NSInteger)calculateIndexX:(NSInteger)x Y:(NSInteger)y
{
    return y * self.size + x;
}

//
// must be called within updateQueue, otherwise unexpected results will occur.
//

- (void)setPieceCount:(Piece *)piece value:(NSInteger)newCount
{
    NSMutableDictionary *piecesPlayed = [self.piecesPlayed mutableCopy];
    NSNumber *key = @(piece.color);
    piecesPlayed[key] = @(newCount);
    self.piecesPlayed = [piecesPlayed copy];
}

- (void)updateColorCount:(Piece *)piece incdec:(NSInteger)incDec
{
    NSMutableDictionary *piecesPlayed = [self.piecesPlayed mutableCopy];
    NSNumber *key = @(piece.color);
    NSNumber *count = piecesPlayed[key];
    [self setPieceCount:piece value:[count integerValue] + incDec];
}

- (void)updateBoardWithPieces:(NSArray<NSArray <BoardPiece *> *> *)pieces
{
    if (pieces == nil) return;
    
    [self.boardString printBoardUpdates:pieces];
    
    NSArray<BoardPiece *> *boardPieces = [NSArray flatten:pieces];
    for (BoardPiece *boardPiece in boardPieces)
    {
        [self changePiece:boardPiece.piece withColor:boardPiece.color];
    }
        
    NSLog(@"\n%@", self);
}

- (void)changePiece:(Piece *)piece withColor:(PieceColor)color
{
    [self updateColorCount:piece incdec:-1]; // take away one for current piece color
    piece.color = color;                     // now change the piece color
    [self updateColorCount:piece incdec:1];  // add one for that color.
}

- (BOOL)isFullUnqueud
{
    NSInteger total = [self.piecesPlayed[@0] integerValue];
    return labs(total) >= self.size * self.size;
}

- (NSInteger)playerScoreUnqueued:(Player *)player
{
    NSNumber *key = @(player.color);
    return [self.piecesPlayed[key] integerValue];
}

- (Piece *)pieceAtPosition:(BoardPosition *)pos
{
    return [self pieceAtPositionX:pos.x Y:pos.y];
}

- (Piece *)pieceAtPositionX:(NSInteger)x Y:(NSInteger)y
{
    if (x >= self.size || y >= self.size || x < 0 || y < 0) return nil;
    return [self.grid objectAtIndex:[self calculateIndexX:x Y:y]];
}

- (NSArray<BoardPiece *> *)erase
{
    NSMutableArray<BoardPiece *> *pieces = [[NSMutableArray alloc] initWithCapacity:10];
    
    [self visitAllUnqueued:^(NSInteger x, NSInteger y, Piece *piece) {
        BoardPosition *pos = [[BoardPosition alloc] initWithX:x Y:y];
        [pieces addObject: [BoardPiece makeBoardPieceWithPiece:piece position:pos color:PieceColorNone]];
    }];
    
    return [pieces copy];
}

- (NSArray<BoardPiece *> *)startingPieces
{
    // place initial pieces.
    BoardPosition *center = self.center;
    
    NSMutableArray<BoardPiece *> *setupBoard = [NSMutableArray new];
    
    [self.tracker boxCoord:1 block:
     ^(BoardPosition *position, BOOL isCorner, NSInteger count, BOOL *stop) {
         NSInteger playerCount = (count + 1) % 2;
         BoardPosition *pos = [center addPosition:position];
         Piece *piece = [self pieceAtPosition:pos];
         [setupBoard addObject:[BoardPiece makeBoardPieceWithPiece:piece position:pos color:playerCount + 1]];
     }];
    
    return [setupBoard copy];
}

- (void)visitAllUnqueued:(void (^)(NSInteger x, NSInteger y, Piece *piece))block
{
    NSInteger size = self.size;
    
    [self.grid enumerateObjectsUsingBlock:^(Piece * piece, NSUInteger index, BOOL * stop) {
        block(index % size, index / size, piece);
    }];
}

- (NSArray<NSArray<BoardPiece *> *> *)placeMovesUnqueued:(NSArray<PlayerMove *> *)moves
{
    NSArray<NSArray<BoardPiece *> *> *pieces = @[];
    
    for (PlayerMove *move in moves)
    {
        if (move.isPass) return nil;
        Piece *currentBoardPiece = [self pieceAtPosition:move.position];
        
        NSArray<NSArray<BoardPiece *> *> *moveBoardPiece = @[@[[BoardPiece makeBoardPieceWithPiece:currentBoardPiece
                                                                                          position:move.position
                                                                                             color:move.color]]];
        
        NSArray<NSArray<BoardPiece *> *> *movePieces = [moveBoardPiece arrayByAddingObjectsFromArray:
                                                        [self.tracker findTracksForBoardPiece:move color:move.color]];
        
        pieces = [pieces arrayByAddingObjectsFromArray:movePieces];
    }
    return pieces;
}

- (void)updateCompletion:(UpdateCompleteBlock)updateComplete
          updateFunction:(NSArray<NSArray<BoardPiece *> *> *(^)(void))updateFunction
{
    if (updateFunction != nil)
    {
        NSArray<NSArray <BoardPiece *> *> *pieces = updateFunction();
        [self updateBoardWithPieces:pieces];
        [self.legalMoves determineLegalMoves];
        if (self.board.placeBlock != nil) self.board.placeBlock(pieces);
    }
    
    if (updateComplete != nil) updateComplete();
}

@end
