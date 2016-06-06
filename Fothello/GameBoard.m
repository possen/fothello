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

typedef enum Direction : NSInteger
{
    DirectionNone = 0,
    DirectionUp = 1,     DirectionFirst = 1,
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
@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic) NSMutableArray<Piece *> *grid;
@property (nonatomic) NSArray<BoardPiece *>*legalMoves;
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
        
        if (size % 2 == 1)
            return nil; // must be multiple of 2
        
        _grid = [[NSMutableArray alloc] initWithCapacity:size*size];
        _piecesPlayed = [NSDictionary new];
        
        // init with empty pieces
        for (NSInteger index = 0; index < size * size; index ++)
        {
            [_grid addObject:[[Piece alloc] init]];
        }
        
        _size = size;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    
    if (self)
    {
        self.grid = [coder decodeObjectForKey:@"grid"];
        self.size = [coder decodeIntegerForKey:@"size"];
        self.piecesPlayed = [coder decodeObjectForKey:@"piecesPlayed"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.grid forKey:@"grid"];
    [aCoder encodeInteger:self.size forKey:@"size"];
    [aCoder encodeObject:self.piecesPlayed forKey:@"piecesPlayed"];
}


- (void)updateColorCount:(Piece *)piece incdec:(NSInteger)incDec
{
    if ([piece isClear])
    {
        return;
    }
    
    NSMutableDictionary *piecesPlayed = [self.piecesPlayed mutableCopy];
    NSNumber *key = @(piece.color);
    NSNumber *count = piecesPlayed[key];
    NSInteger newCount = [count integerValue] + incDec;
    piecesPlayed[key] = @(newCount);

    self.piecesPlayed = [piecesPlayed copy];
}

- (NSArray<BoardPiece *> *)findChangedPieces:(NSArray <BoardPiece *> *)boardPieces
{
    NSIndexSet *indcies = [boardPieces indexesOfObjectsPassingTest:
                           ^BOOL(BoardPiece * boardPiece, NSUInteger idx, BOOL * stop)
    {
        return (boardPiece.color != boardPiece.piece.color);
    }];
    
    return [boardPieces objectsAtIndexes:indcies]; // filter out things that did not change.
}

- (void)changePiece:(Piece *)piece withColor:(PieceColor)color
{
    [self updateColorCount:piece incdec:-1]; // take away one for current piece color
    piece.color = color;                     // now change the piece color
    [self updateColorCount:piece incdec:1];  // add one for that color.
}

- (void)printBoardUpdates:(NSArray<NSArray<BoardPiece *> *> *)tracks
{
    NSLog(@"(%ld){", tracks.count);
    for (NSArray<BoardPiece *> *track in tracks)
    {
        NSMutableString *string = [[NSString stringWithFormat:@"(%ld)", track.count] mutableCopy];
        for (BoardPiece *boardPiece in track)
        {
            [string appendString:@"("];
            [string appendString:boardPiece.description];
            [string appendString:@") "];
        }
        NSLog(@"%@", string);
    }
    NSLog(@"}");
}

// lets the work for the update occur in the processing queue rather than the queue
// is is being called from.
- (void)updateBoardWithFunction:(NSArray<NSArray <BoardPiece *> *> *(^)())updateFunction
{
    dispatch_async(self.queue,^
       {
           NSArray<NSArray <BoardPiece *> *> *pieces = updateFunction();
           [self updateBoardWithPieces:pieces];
       });
}

- (void)updateBoardWithPieces:(NSArray<NSArray <BoardPiece *> *> *)tracks
{
    if (tracks == nil)
    {
        return;
    }
    
//        NSArray<BoardPiece *> *filtered = [self findChangedPieces:boardPieces];
    
    if (self.placeBlock != nil)
    {
        self.placeBlock(tracks);
    }
    
    [self printBoardUpdates:tracks];
    
    NSArray<BoardPiece *> *boardPieces = [NSArray flatten:tracks];
    for (BoardPiece *boardPiece in boardPieces)
    {
        [self changePiece:boardPiece.piece withColor:boardPiece.color];
    }
    
    NSLog(@"\n%@", self);
}

- (void)reset
{
    [self updateBoardWithFunction:^NSArray<NSArray<BoardPiece *> *> *
    {
        NSArray<BoardPiece *> *boardPieces = [self erase];
    
        // place initial pieces.
        BoardPosition *center = self.center;
        
        NSMutableArray<BoardPiece *> *setupBoard = [NSMutableArray new];
        [self boxCoord:1 block:
         ^(BoardPosition *position, BOOL isCorner, NSInteger count, BOOL *stop)
         {
             NSInteger playerCount = (count + 1) % 2;
             NSInteger x = center.x + position.x; NSInteger y = center.y + position.y;
             BoardPosition *pos = [[BoardPosition alloc] initWithX:x Y:y];
             Piece *piece = [self pieceAtPositionX:x Y:y];
             [setupBoard addObject:[BoardPiece makeBoardPieceWithPiece:piece position:pos color:playerCount + 1]];
         }];
        
        return @[boardPieces, [setupBoard copy]];
    }];

}

- (void)showHintMove:(PlayerMove *)move forPlayer:(Player *)player
{
    [self updateBoardWithFunction:^NSArray<BoardPiece *> *
     {
         self.highlightBlock(move, player.color);
         return nil;
     }];
}

- (BOOL)isFull
{
    NSInteger total = 0;
    
    for (NSNumber *key in self.piecesPlayed)
    {
        NSInteger score = [self.piecesPlayed[key] integerValue];

        if (score == 0)
        {
            return YES; // all white or all black.
        }
        
        total += score;
    }
    
    return (total >= self.size * self.size);
}

- (NSInteger)playerScore:(Player *)player
{
    NSNumber *key = @(player.color);
    return [self.piecesPlayed[key] integerValue];
}

- (BoardPosition *)center
{
    BoardPosition *pos = [BoardPosition new];
    pos.x = self.size / 2 - 1; // zero based counting
    pos.y = self.size / 2 - 1;
    return pos;
}

- (void)placeMove:(PlayerMove *)move forPlayer:(Player *)player showMove:(BOOL)showMove
{
    [self updateBoardWithFunction:^NSArray<NSArray <BoardPiece *> *> *{
        
        // briefly highlight position or show pass.
        if (showMove)
        {
            self.highlightBlock(move, player.color == PieceColorWhite ? PieceColorRed : PieceColorBlue);
        }
        
        if (move.isPass)
        {
            return nil;
        }
        
        Piece *movePiece = [self pieceAtPositionX:move.position.x Y:move.position.y];
        NSArray<NSArray<BoardPiece *> *> *moveBoardPiece = @[@[[BoardPiece makeBoardPieceWithPiece:movePiece position:move.position color:player.color]]];
        NSArray<NSArray<BoardPiece *> *> *pieces = [moveBoardPiece arrayByAddingObjectsFromArray:[self findTracksForBoardPiece:move player:player]];

        return pieces;
    }];
}

- (BOOL)canMove:(Player *)player
{
    NSArray <BoardPiece *> *moves = [self legalMovesForPlayer:player];
    return moves != nil;
}

- (void)showLegalMoves:(BOOL)display forPlayer:(Player *)player
{
    [self updateBoardWithFunction:^NSArray<NSArray<BoardPiece *> *> *
     {
         if (display)
         {
             NSArray<BoardPiece *> *pieces = [self legalMovesForPlayer:player];
             self.legalMoves = pieces;
             return pieces ? @[pieces] : nil;
         }
         else
         {
             NSArray<BoardPiece *> *pieces = self.legalMoves;
             for (BoardPiece *piece in pieces)
             {
                 piece.color = PieceColorNone;
             }
             self.legalMoves = nil;
             return pieces ? @[pieces] : nil;
         }
     }];
}

- (NSArray <BoardPiece *> *)legalMovesForPlayer:(Player *)player
{
    NSMutableArray<BoardPiece *>*pieces = [[NSMutableArray alloc] initWithCapacity:10];
    
    // Determine moves
    [self visitAll:^(NSInteger x, NSInteger y, Piece *findPiece)
     {
         BoardPosition *boardPosition = [BoardPosition positionWithX:x y:y];
         BoardPiece *findBoardPiece = [BoardPiece makeBoardPieceWithPiece:findPiece position:boardPosition color:player.color];

         BOOL foundTrack = [self findTracksForBoardPiece:findBoardPiece player:player] != nil;
         if (foundTrack)
         {
             Piece *piece = [self pieceAtPositionX:x Y:y];
             [pieces addObject:[BoardPiece makeBoardPieceWithPiece:piece position:boardPosition color:PieceColorLegal]];
         }
     }];
    
    return pieces.count > 0 ? [pieces copy] : nil;
}

- (NSArray<BoardPiece *> *)erase
{
    NSMutableArray<BoardPiece *> *pieces = [[NSMutableArray alloc] initWithCapacity:10];
    
    [self visitAll:^(NSInteger x, NSInteger y, Piece *piece)
     {
         [piece clear]; // must use this to bypass isClear check
         
         BoardPosition *pos = [[BoardPosition alloc] initWithX:x Y:y];
         [pieces addObject:[BoardPiece makeBoardPieceWithPiece:piece position:pos color:PieceColorNone]];
     }];
    
    self.piecesPlayed = [NSDictionary new];
    return [pieces copy];
}

- (void)visitAll:(void (^)(NSInteger x, NSInteger y, Piece *piece))block
{
    NSInteger size = self.size;
  
    [self.grid enumerateObjectsUsingBlock:^(Piece * piece, NSUInteger index, BOOL * stop)
     {
         block(index % size, index / size, piece);
    }];
}

- (NSInteger)calculateIndexX:(NSInteger)x Y:(NSInteger)y
{
    return x * self.size + y;
}

- (Piece *)pieceAtPositionX:(NSInteger)x Y:(NSInteger)y
{
    if (x >= self.size || y >= self.size || x < 0 || y < 0)
        return nil;
    
    return [self.grid objectAtIndex:[self calculateIndexX:x Y:y]];
}

- (void)printBanner:(NSMutableString *)boardString
{
    for (NSInteger width = 0; width < self.size + 2; width++)
    {
        [boardString appendString:@"-"];
    }
    [boardString appendString:@"\n"];
}

- (NSString *)convertToString:(BOOL)ascii reverse:(BOOL)reverse
{
    NSMutableString *boardString = [[NSMutableString alloc] init];
    [self printBanner:boardString];
    
    NSInteger size = self.size;
    NSInteger reverseOffset = reverse  ? size - 1: 0;
    for (NSInteger y = 0; y < size; ++y)
    {
        [boardString appendString:@"|"];
        for (NSInteger x = 0; x < self.size; x++)
        {
            Piece *piece = [self pieceAtPositionX:x Y:labs(reverseOffset - y)];
            if (piece == nil)
            {
                continue;
            }
            [boardString appendString:ascii
                ? piece.colorStringRepresentationAscii
                : piece.colorStringRepresentation];
        }
        [boardString appendString:@"|"];
        [boardString appendString:@"\n"];
    }
    
    [self printBanner:boardString];
    if (!ascii)
    {
        [boardString appendFormat:@"%@", self.piecesPlayed];
    }
    return [boardString copy];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\n%@",[self toString]];
}

- (NSString *)toString
{
    return [self convertToString:NO reverse:YES];
}

- (NSString *)requestFormat
{
    return [self convertToString:YES reverse:NO];
}

- (NSArray<NSArray <BoardPiece *> *> *)findTracksForBoardPiece:(BoardPiece *)boardPiece
                                                        player:(Player *)player
{
    // calls block for each direction that has a successful track
    // a track does not include start position, one or more
    // pieces of different color than the player's color, terminated by a piece of
    // the same color as the player.
    
    BOOL found = NO;
    
    // check that piece is on board and we are placing on clear space
    Piece *piece = [self pieceAtPositionX:boardPiece.position.x Y:boardPiece.position.y];
    if (piece == nil || ![piece isClear])
    {
        return nil;
    }
    
    NSMutableArray<NSMutableArray <BoardPiece *> *> *tracks = [[NSMutableArray alloc] initWithCapacity:10];

    // try each direction, to see if there is a track
    for (Direction direction = DirectionFirst; direction < DirectionLast; direction ++)
    {
        Delta diff = [self determineDirection:direction];
        NSMutableArray<BoardPiece *> *track = [[NSMutableArray alloc] initWithCapacity:10];

        NSInteger offsetx = boardPiece.position.x;
        NSInteger offsety = boardPiece.position.y;
        Piece *piece;
        
        // keep adding pieces until we hit a piece of the same color, edge of board or
        // clear space.
        BOOL valid;
        
        do {
            offsetx += diff.dx; offsety += diff.dy;
            piece = [self pieceAtPositionX:offsetx Y:offsety];
            valid = piece && ![piece isClear]; // make sure it is on board and not clear.
            
            if (valid)
            {
                BoardPosition *offset = [BoardPosition positionWithX:offsetx y:offsety];
                BoardPiece *trackInfo = [BoardPiece makeBoardPieceWithPiece:piece position:offset color:player.color];
                [track addObject:trackInfo];
            }
        } while (valid && piece.color != player.color);
        
        // found piece of same color, end track and call back.
        if (valid && piece.color == player.color && track.count > 1)
        {
            found = YES;
        }
        
        if (track.count > 0)
        {
            [tracks addObject:[track copy]];
        }
    }
    
    return found ? [tracks copy] : nil;
}


- (NSArray<BoardPiece *>*)updateWithTrack:(NSArray<Piece *>*)trackInfo position:(BoardPosition *)position player:(Player *)player
{
    NSMutableArray<BoardPiece *> *pieces = [NSMutableArray new];
    
    for (BoardPiece *trackItem in trackInfo)
    {
        Piece *piece = trackItem.piece;
        NSInteger x = trackItem.position.x;
        NSInteger y = trackItem.position.y;
        BoardPosition *position = [BoardPosition positionWithX:x y:y];
        [pieces addObject:[BoardPiece makeBoardPieceWithPiece:piece position:position color:player.color]];
    }
    return [pieces copy];
}

- (Delta)determineDirection:(Direction)direction
{
    NSInteger x = 0; NSInteger y = 0;
    
    switch (direction)
    {
        case DirectionUp:
        case DirectionUpLeft:
        case DirectionUpRight:
            y = -1;
            break;
        case DirectionDown:
        case DirectionDownRight:
        case DirectionDownLeft:
            y = 1;
            break;
        case DirectionNone:
        case DirectionLeft:
        case DirectionRight:
        case DirectionLast:
            break;
    }
    
    switch (direction)
    {
        case DirectionRight:
        case DirectionDownRight:
        case DirectionUpRight:
            x = 1;
            break;
        case DirectionLeft:
        case DirectionDownLeft:
        case DirectionUpLeft:
            x = -1;
            break;
        case DirectionNone: 
        case DirectionUp:
        case DirectionDown:
        case DirectionLast:
            break;
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
    BoardPosition *position = [BoardPosition positionWithX:dist - dist / 2
                                                         y:dist - dist / 2];
    
    // calculate how many pieces to place.
    // Four times dist for the number of directions
    for (NSInteger moveDist = 0; moveDist < dist * 4; moveDist ++)
    {
        // times two so we get only UP, RIGHT, DOWN, LEFT
        Direction dir = moveDist / dist * 2 + DirectionFirst;
        Delta diff = [self determineDirection:dir];
        
        position.x += diff.dx;
        position.y += diff.dy;
        
        BOOL stop = NO;
        block(position, ABS(position.x) == ABS(position.y), moveDist, &stop);
        if (stop)
            break;
    }
}

@end


