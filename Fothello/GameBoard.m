//
//  GameBoard.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/2/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "FothelloGame.h"
#import "GameBoard.h"
#import "GameBoardInternal.h"
#import "GameBoardLegalMoves.h"
#import "Player.h"
#import "Piece.h"
#import "BoardPiece.h"
#import "BoardPosition.h"
#import "PlayerMove.h"
#import "NSArray+Extensions.h"
#import "NSDictionary+Extensions.h"
#import "GameBoardRepresentation.h"
#import "NSArray+Holes.h"

@interface GameBoard ()
@property (nonatomic, readonly) GameBoardInternal *boardInternal;
@end

@interface GameBoardInternal ()
@property (nonatomic, readonly, nonnull) NSDictionary<NSNumber *, NSNumber *> *piecesPlayed;
@property (nonatomic, readonly) GameBoardRepresentation *boardRepresentation;

- (void)updateBoardWithPieces:(NSArray<NSArray <BoardPiece *> *> *)tracks;
- (void)determineLegalMoves;
- (void)visitAllUnqueued:(void (^)(NSInteger x, NSInteger y, Piece *piece))block;
- (Piece *)pieceAtPositionX:(NSInteger)x Y:(NSInteger)y;
- (NSArray<NSArray<BoardPiece *> *> *)placeMovesUnqueued:(NSArray<PlayerMove *> *)moves;
- (NSArray<BoardPiece *> *)startingPieces;
- (NSArray<BoardPiece *> *)erase;
- (BOOL)isFullUnqueud;
- (NSInteger)size;
- (void)updateCompletion:(UpdateCompleteBlock)updateComplete
          updateFunction:(NSArray<NSArray<BoardPiece *> *> *(^)(void))updateFunction;

@end


@implementation GameBoard

- (instancetype)initWithBoardSize:(NSInteger)size
{
    return [self initWithBoardSize:size piecePlacedBlock:nil];
}

- (instancetype)initWithBoardSize:(NSInteger)size piecePlacedBlock:(PlaceBlock)block
{
    self = [super init];
    
    if (self)
    {
        _boardInternal = [[GameBoardInternal alloc] initWithBoard:self size:size piecePlacedBlock:block];
        _queue = dispatch_queue_create("match update queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (NSDictionary<NSNumber *, NSNumber *> *)piecesPlayed
{
    return self.boardInternal.piecesPlayed;
}

- (NSInteger)size
{
    return self.boardInternal.size;
}

//
// lets the work for the update occur in the processing queue rather than the queue
// is is being called from the caller's thread. Use this method around calls that
// are not queued already, if they update or read board data structures
//
- (void)updateBoard:(NSArray<NSArray <BoardPiece *> *> *(^)(void))updateFunction
           complete:(UpdateCompleteBlock)updateComplete
{
    GameBoardInternal *internal = self.boardInternal;
    dispatch_async(self.queue,^{
        [internal updateCompletion:updateComplete updateFunction:updateFunction];
    });
}

- (void)updateBoard:(NSArray<NSArray <BoardPiece *> *> *(^)(void))updateFunction
{
    [self updateBoard:updateFunction complete:nil];
}

- (void)visitAll:(void (^)(NSInteger x, NSInteger y, Piece *piece))block
{
    GameBoardInternal *internal = self.boardInternal;
    [self updateBoard:nil
             complete:^{
         [internal visitAllUnqueued:block];
     }];
}

- (void)reset
{
    GameBoardInternal *internal = self.boardInternal;
    [self updateBoard:^NSArray<NSArray<BoardPiece *> *> * {
        NSArray<BoardPiece *> *boardPieces = [internal erase];
        NSArray<BoardPiece *> *startingPieces = [internal startingPieces];
        return @[boardPieces, startingPieces];
    }];
}

- (void)placeMoves:(NSArray<PlayerMove *> *)moves
{
    GameBoardInternal *internal = self.boardInternal;
    [self updateBoard:^NSArray<NSArray<BoardPiece *> *> *{
        return [internal placeMovesUnqueued:moves];
    }];
}

- (void)isLegalMove:(PlayerMove *)move
          forPlayer:(Player *)player
              legal:(void (^)(BOOL))legal
{
    GameBoardInternal *internal = self.boardInternal;
    [self updateBoard:nil complete:^{
        GameBoardLegalMoves *obj = internal.legalMoves;
        
        BOOL legalMove = [obj isLegalMove:move forPlayer:player];
        // avoid calling into same queue.
        dispatch_async(dispatch_get_main_queue(), ^{
            legal(legalMove);
        });
    }];
}

- (void)showLegalMoves:(BOOL)display forPlayer:(Player *)player
{
    GameBoardInternal *internal = self.boardInternal;
    [self updateBoard:^NSArray<NSArray<BoardPiece *> *> *{
         NSArray<BoardPiece *> *pieces = [internal.legalMoves legalMovesForPlayerColor:player.color];
         
         if (!display)
         {
             pieces = [internal.legalMoves findLegals:pieces];
         }
        
         return pieces ? @[pieces] : @[];
     }];
}

- (NSArray <BoardPiece *> *)legalMovesForPlayerColor:(PieceColor)color
{
    __block NSArray <BoardPiece *> *result = nil;
    GameBoardInternal *internal = self.boardInternal;
    dispatch_sync(self.queue,^{
        result = [internal.legalMoves legalMovesForPlayerColor:color];
    });
    return result;
}

- (BOOL)canMove:(Player *)player
{
    __block BOOL result = NO;
    GameBoardInternal *internal = self.boardInternal;
    dispatch_sync(self.queue,^{
        result = [internal.legalMoves canMoveUnqueued:player];
    });
    
    return result;
}

- (BOOL)isFull
{
    __block BOOL result = NO;
    GameBoardInternal *internal = self.boardInternal;
    dispatch_sync(self.queue,^{
        result = [internal isFullUnqueud];
    });
    return result;
}

- (NSInteger)playerScore:(Player *)player
{
    __block NSInteger result = 0;
    GameBoardInternal *internal = self.boardInternal;
    dispatch_sync(self.queue,^{
        result = [internal playerScoreUnqueued:player];
    });
    return result;
}

- (NSString *)requestFormat
{
    __block NSString *result = nil;
    GameBoardRepresentation *boardString = self.boardInternal.boardRepresentation;
    dispatch_sync(self.queue, ^{
        result = [boardString toAscii];
    });
    
    return result;
}


#pragma mark - Queue Safe -

- (void)showClickedMove:(PlayerMove *)move forPieceColor:(PieceColor)color
{
    if (self.highlightBlock == nil) return;
    self.highlightBlock(move.position, color == PieceColorWhite ? PieceColorRed : PieceColorBlue);
}

- (void)showHintMove:(PlayerMove *)move forPieceColor:(PieceColor)color
{
    if (self.highlightBlock == nil) return;
    self.highlightBlock(move.position, color);
}

@end
