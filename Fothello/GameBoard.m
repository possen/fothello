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
#import "GameBoardString.h"
#import "NSArray+Holes.h"

@interface GameBoard ()
@property (nonatomic) GameBoardInternal *boardInternal;
@end

@interface GameBoardInternal ()
@property (nonatomic, readwrite, nonnull) NSDictionary<NSNumber *, NSNumber *> *piecesPlayed;
@property (nonatomic, readonly, nonnull) NSMutableArray<NSArray<BoardPiece *>*> *legalMovesForPlayer;
@property (nonatomic) GameBoardString *boardString;


- (void)updateBoardWithPieces:(NSArray<NSArray <BoardPiece *> *> *)tracks;
- (void)determineLegalMoves;
- (void)visitAllUnqueued:(void (^)(NSInteger x, NSInteger y, Piece *piece))block;
- (Piece *)pieceAtPositionX:(NSInteger)x Y:(NSInteger)y;
- (NSArray<NSArray<BoardPiece *> *> *)placeMovesUnqueued:(NSArray<PlayerMove *> *)moves;
- (NSArray<BoardPiece *> *)startingPieces;
- (NSArray<BoardPiece *> *)erase;
- (BOOL)isFullUnqueud;
- (BOOL)canMoveUnqueued:(nonnull Player *)player;
- (NSInteger)size;

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
        _boardInternal = [[GameBoardInternal alloc] initWithBoard:self size:size];
        _queue = dispatch_queue_create("match update queue", DISPATCH_QUEUE_SERIAL);
        _placeBlock = block;
    }
    return self;
}

- (NSDictionary<NSNumber *, NSNumber *> *)piecesPlayed {
    return self.boardInternal.piecesPlayed;
}

- (NSInteger)size {
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
    dispatch_async(self.queue,^{
       if (updateFunction != nil)
       {
           GameBoardInternal *internal = self.boardInternal;
           NSArray<NSArray <BoardPiece *> *> *pieces = updateFunction();
           [internal updateBoardWithPieces:pieces];
           [internal determineLegalMoves];
           if (self.placeBlock != nil) self.placeBlock(pieces);

//           NSLog(@"%@", self.legalMovesForPlayer);
       }
       
       if (self.updateCompleteBlock != nil) self.updateCompleteBlock();
       if (updateComplete != nil) updateComplete();
   });
}

- (void)updateBoard:(NSArray<NSArray <BoardPiece *> *> *(^)(void))updateFunction
{
    [self updateBoard:updateFunction complete:nil];
}

- (void)visitAll:(void (^)(NSInteger x, NSInteger y, Piece *piece))block
{
    [self updateBoard:nil
             complete:^{
         GameBoardInternal *internal = self.boardInternal;
         [internal visitAllUnqueued:block];
     }];
}

- (void)reset
{
    [self updateBoard:^NSArray<NSArray<BoardPiece *> *> * {
        GameBoardInternal *internal = self.boardInternal;
        NSArray<BoardPiece *> *boardPieces = [internal erase];
        NSArray<BoardPiece *> *startingPieces = [internal startingPieces];
        return @[boardPieces, startingPieces];
    }];
}

- (void)placeMoves:(NSArray<PlayerMove *> *)moves
{
    [self updateBoard:^NSArray<NSArray<BoardPiece *> *> *{
        GameBoardInternal *internal = self.boardInternal;
        return [internal placeMovesUnqueued:moves];
     }];
}

- (void)isLegalMove:(PlayerMove *)move
          forPlayer:(Player *)player
              legal:(void (^)(BOOL))legal
{
    [self updateBoard:nil complete:^{
        GameBoardInternal *internal = self.boardInternal;
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
    [self updateBoard:^NSArray<NSArray<BoardPiece *> *> *{
        GameBoardInternal *internal = self.boardInternal;

         NSArray<BoardPiece *> *pieces = [internal.legalMovesForPlayer objectAtCheckedIndex:player.color];
         
         if (!display) {
             pieces = [internal.legalMoves findLegals:pieces];
         }
        
         return pieces ? @[pieces] : @[];
     }];
}

- (NSArray <BoardPiece *> *)legalMovesForPlayerColor:(PieceColor)color {
    __block NSArray <BoardPiece *> *result = nil;
    dispatch_sync(self.queue,^{
        GameBoardInternal *internal = self.boardInternal;
        result = [internal.legalMoves legalMovesForPlayerColor:color];
    });
    return result;
}


- (BOOL)canMove:(Player *)player
{
    __block BOOL result = NO;
    dispatch_sync(self.queue,^{
        GameBoardInternal *internal = self.boardInternal;
        result = [internal canMoveUnqueued:player];
    });
    
    return result;
}

- (BOOL)isFull
{
    __block BOOL result = NO;
    dispatch_sync(self.queue,^{
        GameBoardInternal *internal = self.boardInternal;
        result = [internal isFullUnqueud];
    });
    return result;
}

- (NSInteger)playerScore:(Player *)player
{
    __block NSInteger result = 0;
    dispatch_sync(self.queue,^{
        GameBoardInternal *internal = self.boardInternal;
        result = [internal playerScoreUnqueued:player];
    });
    return result;
}


- (NSString *)requestFormat
{
    __block NSString *result = nil;
    
    dispatch_sync(self.queue, ^{
        GameBoardString *internal = self.boardInternal.boardString;
        result = [internal convertToString:YES reverse:NO];
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
