//
//  GameBoard.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/2/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "FothelloGame.h"
#import "GameBoard.h"
#import "Player.h"
#import "Piece.h"
#import "BoardPiece.h"
#import "BoardPosition.h"
#import "PlayerMove.h"
#import "NSArray+Extensions.h"
#import "NSDictionary+Extensions.h"
#import "GameBoard+String.h"
#import "NSArray+Holes.h"

typedef enum Direction : NSInteger
{
    DirectionNone = 0,
    DirectionFirst = 1,
    DirectionUp = 1,
    DirectionUpLeft,
    DirectionLeft,
    DirectionDownLeft,
    DirectionDown,
    DirectionDownRight,
    DirectionRight,
    DirectionUpRight,
    DirectionLast
} Direction;

typedef struct Delta
{
    NSInteger dx;
    NSInteger dy;
} Delta;

#pragma mark - GameBoard -

@interface GameBoard ()
@property (nonatomic, readwrite, nonnull) NSDictionary<NSNumber *, NSNumber *> *piecesPlayed;
@property (nonatomic) NSMutableArray<Piece *> *grid;
@property (nonatomic) NSMutableArray<NSArray<BoardPiece *>*> *legalMovesForPlayer;
@end

@implementation GameBoard

- (instancetype)initWithBoardSize:(NSInteger)size
{
    return [self initWithBoardSize:size piecePlacedBlock:nil ];
}

- (instancetype)initWithBoardSize:(NSInteger)size piecePlacedBlock:(PlaceBlock)block
{
    self = [super init];
    
    if (self)
    {
        _queue = dispatch_queue_create("match update queue", DISPATCH_QUEUE_SERIAL);

        _placeBlock = block;
        
        if (size % 2 == 1) return nil; // must be multiple of 2
        
        _grid = [[NSMutableArray alloc] initWithCapacity:size*size];
        _piecesPlayed = [NSDictionary new];
        
        // init with empty pieces
        for (NSInteger index = 0; index < size * size; index ++)
        {
            [_grid addObject:[[Piece alloc] init]];
        }
        
        _size = size;
        _legalMovesForPlayer = [@[@[], @[]] mutableCopy];
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

#pragma - Queued - 


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

//
// lets the work for the update occur in the processing queue rather than the queue
// is is being called from the caller's thread. Use this method around calls that
// are not queued already, if they update or read board data structures
//
- (void)updateBoard:(NSArray<NSArray <BoardPiece *> *> *(^)())updateFunction
           complete:(UpdateCompleteBlock)updateComplete
{
    dispatch_async(self.queue,^{
       if (updateFunction != nil)
       {
           NSArray<NSArray <BoardPiece *> *> *pieces = updateFunction();
           [self updateBoardWithPieces:pieces];
           [self determineLegalMoves];
//           NSLog(@"%@", self.legalMovesForPlayer);
       }
       
       if (self.updateCompleteBlock != nil) self.updateCompleteBlock();
       if (updateComplete != nil) updateComplete();
   });
}

- (void)updateBoard:(NSArray<NSArray <BoardPiece *> *> *(^)())updateFunction
{
    [self updateBoard:updateFunction complete:nil];
}

- (void)visitAll:(void (^)(NSInteger x, NSInteger y, Piece *piece))block
{
    [self updateBoard:nil
             complete:^{
         [self visitAllUnqueued:block];
     }];
}

- (NSArray<BoardPiece *> *)startingPieces
{
    // place initial pieces.
    BoardPosition *center = self.center;
    
    NSMutableArray<BoardPiece *> *setupBoard = [NSMutableArray new];
    
    [self boxCoord:1 block:
     ^(BoardPosition *position, BOOL isCorner, NSInteger count, BOOL *stop) {
         NSInteger playerCount = (count + 1) % 2;
         NSInteger x = center.x + position.x; NSInteger y = center.y + position.y;
         BoardPosition *pos = [[BoardPosition alloc] initWithX:x Y:y];
         Piece *piece = [self pieceAtPositionX:x Y:y];
         
         [setupBoard addObject:[BoardPiece makeBoardPieceWithPiece:piece position:pos color:playerCount + 1]];
     }];
    
    return [setupBoard copy];
}

- (void)reset
{
    [self updateBoard:^NSArray<NSArray<BoardPiece *> *> * {
        NSArray<BoardPiece *> *boardPieces = [self erase];
        NSArray<BoardPiece *> *startingPieces = [self startingPieces];
        return @[boardPieces, startingPieces];
    }];
}


- (void)placeMoves:(NSArray<PlayerMove *> *)moves
{
    [self updateBoard:^NSArray<NSArray<BoardPiece *> *> *{
         NSArray<NSArray<BoardPiece *> *> *pieces = @[];
        
         for (PlayerMove *move in moves)
         {
             if (move.isPass) return nil;
             BoardPosition *position = move.position;
             Piece *currentBoardPiece = [self pieceAtPositionX:position.x Y:position.y];
             
             NSArray<NSArray<BoardPiece *> *> *moveBoardPiece = @[@[[BoardPiece makeBoardPieceWithPiece:currentBoardPiece
                                                                                               position:position
                                                                                                  color:move.color]]];
             
             NSArray<NSArray<BoardPiece *> *> *movePieces = [moveBoardPiece arrayByAddingObjectsFromArray:
                                                         [self findTracksForBoardPiece:move color:move.color]];
             
             pieces = [pieces arrayByAddingObjectsFromArray:movePieces];
         }
         return pieces;
     }];
}

- (void)isLegalMove:(PlayerMove *)move
          forPlayer:(Player *)player
              legal:(void (^)(BOOL))legal
{
    [self updateBoard:nil complete:^{
        NSArray <BoardPiece *> *legalMoves = [self.legalMovesForPlayer objectAtCheckedIndex:player.color];
        
        BOOL legalMove = legalMoves != nil
                && [legalMoves indexOfObjectPassingTest:^
            BOOL (BoardPiece *boardPiece, NSUInteger idx, BOOL *stop) {
                return boardPiece.position.x == move.position.x
                && boardPiece.position.y == move.position.y;
            }] != NSNotFound;
        
        // avoid calling into same queue.
        dispatch_async(dispatch_get_main_queue(), ^{
            legal(legalMove);
        });
    }];
}

- (NSArray<BoardPiece *> *)findLegals:(NSArray<BoardPiece *> *)pieces
{
    NSIndexSet *legals = [pieces indexesOfObjectsPassingTest:
                          ^BOOL(BoardPiece *piece, NSUInteger idx, BOOL * stop) {
                              Piece *currentPiece = [self pieceAtPositionX:piece.position.x Y:piece.position.y];
                              BOOL result = currentPiece.color == PieceColorLegal;
                              return result;
                          }];
    
    pieces = [pieces objectsAtIndexes:legals];
    [pieces enumerateObjectsUsingBlock:^(BoardPiece *piece, NSUInteger idx, BOOL *stop) {
         piece.color = PieceColorNone;
     }];
    return pieces;
}

- (void)showLegalMoves:(BOOL)display forPlayer:(Player *)player
{
    [self updateBoard:^NSArray<NSArray<BoardPiece *> *> *{
         NSArray<BoardPiece *> *pieces = [self.legalMovesForPlayer objectAtCheckedIndex:player.color];
         
         if (!display) {
             pieces = [self findLegals:pieces];
         }
         return pieces ? @[pieces] : @[];
     }];
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

- (void)showClickedMove:(PlayerMove *)move forPlayer:(Player *)player
{
    if (self.highlightBlock == nil) return;
    self.highlightBlock(move.position, player.color == PieceColorWhite ? PieceColorRed : PieceColorBlue);
}

- (void)showHintMove:(PlayerMove *)move forPlayer:(Player *)player
{
    if (self.highlightBlock == nil) return;
    self.highlightBlock(move.position, player.color);
}

- (NSInteger)calculateIndexX:(NSInteger)x Y:(NSInteger)y
{
    return x * self.size + y;
}


#pragma mark - Non Queued -

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

- (void)updateBoardWithPieces:(NSArray<NSArray <BoardPiece *> *> *)tracks
{
    if (tracks == nil) return;
    
    [self printBoardUpdates:tracks];
    
    NSArray<BoardPiece *> *boardPieces = [NSArray flatten:tracks];
    for (BoardPiece *boardPiece in boardPieces)
    {
        [self changePiece:boardPiece.piece withColor:boardPiece.color];
    }
    
    if (self.placeBlock != nil) self.placeBlock(tracks);
    
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

- (BOOL)isFull
{
    __block BOOL result = NO;
    dispatch_sync(self.queue,^{
        result = [self isFullUnqueud];
    });
    return result;
}

- (NSInteger)playerScoreUnqueued:(Player *)player
{
    NSNumber *key = @(player.color);
    return [self.piecesPlayed[key] integerValue];
}

- (NSInteger)playerScore:(Player *)player
{
    __block NSInteger result = 0;
    dispatch_sync(self.queue,^{
        result = [self playerScoreUnqueued:player];
    });
    return result;
}

- (BOOL)canMoveUnqueued:(Player *)player
{
    NSArray <BoardPiece *> *moves = [self.legalMovesForPlayer objectAtCheckedIndex:player.color];
    
    __block NSString *boardMoves = @"";
    [moves mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
        boardMoves = [boardMoves stringByAppendingString:boardMoves];
        return @[];
    }];
    NSLog(@"boardMoves %@", boardMoves);

    return moves.count != 0;
}

- (BOOL)canMove:(Player *)player
{
    __block BOOL result = NO;
    dispatch_sync(self.queue,^{
        result = [self canMoveUnqueued:player];
    });
    
    return result;
}

- (NSArray <BoardPiece *> *)legalMovesForPlayerColor:(PieceColor)color
{
    NSMutableArray<BoardPiece *>*pieces = [[NSMutableArray alloc] initWithCapacity:10];
    
    // Determine moves
    [self visitAllUnqueued:^(NSInteger x, NSInteger y, Piece *findPiece) {
         BoardPosition *boardPosition = [BoardPosition positionWithX:x y:y];
         BoardPiece *findBoardPiece = [BoardPiece makeBoardPieceWithPiece:findPiece position:boardPosition color:color];
         
         BOOL foundTrack = [self findTracksForBoardPiece:findBoardPiece color:color] != nil;
         if (foundTrack)
         {
             Piece *piece = [self pieceAtPositionX:x Y:y];
             [pieces addObject:[BoardPiece makeBoardPieceWithPiece:piece position:boardPosition color:PieceColorLegal]];
         }
     }];
    
    return [pieces copy];
}

- (void)visitAllUnqueued:(void (^)(NSInteger x, NSInteger y, Piece *piece))block
{
    NSInteger size = self.size;
    
    [self.grid enumerateObjectsUsingBlock:^(Piece * piece, NSUInteger index, BOOL * stop) {
         block(index % size, index / size, piece);
     }];
}

- (Piece *)pieceAtPositionX:(NSInteger)x Y:(NSInteger)y
{
    if (x >= self.size || y >= self.size || x < 0 || y < 0) return nil;
    
    return [self.grid objectAtIndex:[self calculateIndexX:x Y:y]];
}

- (NSArray *)followTrackForDirection:(Direction)direction
                               piece:(BoardPiece *)boardPiece
                               color:(PieceColor)pieceColor
{
    Delta diff = [self determineDirection:direction];
    
    NSMutableArray<BoardPiece *> *track = [[NSMutableArray alloc] initWithCapacity:10];
    
    NSInteger offsetx = boardPiece.position.x; NSInteger offsety = boardPiece.position.y;
    
    // keep adding pieces until we hit a piece of the same color, edge of board or
    // clear space.
    BOOL valid; Piece *piece;

    do {
        offsetx += diff.dx; offsety += diff.dy;
        piece = [self pieceAtPositionX:offsetx Y:offsety];
        valid = piece && ![piece isClear]; // make sure it is on board and not clear.
        
        if (valid)
        {
            BoardPosition *offset = [BoardPosition positionWithX:offsetx y:offsety];
            [track addObject:[BoardPiece makeBoardPieceWithPiece:piece position:offset color:pieceColor]];
        }
    } while (valid && piece.color != pieceColor);
    
    BOOL result = valid && piece.color == pieceColor && track.count > 1;
    return result ? track : nil;
}

- (NSArray<NSArray <BoardPiece *> *> *)findTracksForBoardPiece:(BoardPiece *)boardPiece
                                                         color:(PieceColor)pieceColor
{
    // calls block for each direction that has a successful track
    // a track does not include start position, one or more
    // pieces of different color than the player's color, terminated by a piece of
    // the same color as the player.
    
    // check that piece is on board and we are placing on clear space
    Piece *piece = [self pieceAtPositionX:boardPiece.position.x Y:boardPiece.position.y];
    
    if (piece == nil || ![piece isClear]) return nil;
    
    NSMutableArray<NSMutableArray <BoardPiece *> *> *tracks = [[NSMutableArray alloc] initWithCapacity:10];

    BOOL found = NO;

    // try each direction, to see if there is a track
    for (Direction direction = DirectionFirst; direction < DirectionLast; direction ++)
    {
        NSArray *track = [self followTrackForDirection:direction piece:boardPiece color:pieceColor];
        
        // found piece of same color, end track call back.
        if (track != nil)
        {
            found = YES;
            [tracks addObject:[track copy]];
        }
    }
    
    return found ? [tracks copy] : nil;
}

- (Delta)determineDirection:(Direction)direction
{
    NSInteger x = 0; NSInteger y = 0;
    
    switch (direction)
    {
        case DirectionUp: case DirectionUpLeft: case DirectionUpRight: y = -1; break;
        case DirectionDown: case DirectionDownRight: case DirectionDownLeft: y = 1; break;
        case DirectionNone: case DirectionLeft: case DirectionRight: case DirectionLast: break;
    }
    
    switch (direction)
    {
        case DirectionRight: case DirectionDownRight: case DirectionUpRight: x = 1; break;
        case DirectionLeft: case DirectionDownLeft: case DirectionUpLeft: x = -1; break;
        case DirectionNone: case DirectionUp: case DirectionDown: case DirectionLast: break;
    }
    
    Delta delta; delta.dx = x; delta.dy = y;
    return delta;
}

- (void)boxCoord:(NSInteger)dist
           block:(void (^)(BoardPosition *position, BOOL isCorner, NSInteger count, BOOL *stop))block
{
    // calculates the positions of the pieces in a box dist from center.
    
    dist = (dist - 1) * 2 + 1; // skip even rings
    
    // calculate start position
    BoardPosition *position = [BoardPosition positionWithX:dist - dist / 2 y:dist - dist / 2];
    
    // calculate how many pieces to place.
    // Four times dist for the number of directions
    for (NSInteger moveDist = 0; moveDist < dist * 4; moveDist ++)
    {
        // times two so we get only UP, RIGHT, DOWN, LEFT
        Direction dir = moveDist / dist * 2 + DirectionFirst;
        Delta diff = [self determineDirection:dir];
        
        position.x += diff.dx; position.y += diff.dy;
        
        BOOL stop = NO;
        block(position, ABS(position.x) == ABS(position.y), moveDist, &stop);
        if (stop) break;
    }
}

- (NSString *)requestFormat
{
    __block NSString *result = nil;
    
    dispatch_sync(self.queue, ^{
                      result = [self convertToString:YES reverse:NO];
                  });
    
    return result;
}

@end
