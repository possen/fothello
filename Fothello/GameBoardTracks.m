//
//  GameBoardTracks.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/20/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import "GameBoardTracks.h"
#import "FothelloGame.h"
#import "GameBoardInternal.h"
#import "Player.h"
#import "PlayerMove.h"
#import "BoardPiece.h"
#import "BoardPosition.h"
#import "NSArray+Holes.h"
#import "Piece.h"

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

@interface GameBoardTracks ()
@property (nonatomic) GameBoardInternal *internal;
@end

@implementation GameBoardTracks

- (instancetype)initWithGameBoard:(GameBoardInternal *)gameBoard
{
    self = [super init];
    if (self) {
        _internal = gameBoard;
    }
    return self;
}

// codebeat:disable[ABC]
- (NSArray *)followTrackForDirection:(Direction)direction
                               piece:(BoardPiece *)boardPiece
                               color:(PieceColor)pieceColor
{
    GameBoardInternal *internal = self.internal;
    Delta diff = [self determineDirection:direction];
    
    NSMutableArray<BoardPiece *> *track = [[NSMutableArray alloc] initWithCapacity:10];
    BoardPosition *position = boardPiece.position;
    NSInteger offsetx = position.x; NSInteger offsety = position.y;
    
    // keep adding pieces until we hit a piece of the same color, edge of board or
    // clear space.
    BOOL valid; Piece *piece; PieceColor currentPieceColor;
    
    do {
        offsetx += diff.dx; offsety += diff.dy;
        piece = [internal pieceAtPositionX:offsetx Y:offsety];
        currentPieceColor = piece.color;
        valid = piece && ![piece isClear]; // make sure it is on board and not clear.
        
        if (valid)
        {
            BoardPosition *offset = [BoardPosition positionWithX:offsetx y:offsety];
            [track addObject:[BoardPiece makeBoardPieceWithPiece:piece position:offset color:pieceColor]];
        }
    } while (valid && currentPieceColor != pieceColor);
    
    BOOL result = valid && currentPieceColor == pieceColor && track.count > 1;
    return result ? track : nil;
}
// codebeat:enable[ABC]

- (NSArray<NSArray <BoardPiece *> *> *)findTracksForBoardPiece:(BoardPiece *)boardPiece
                                                         color:(PieceColor)pieceColor
{
    GameBoardInternal *internal = self.internal;

    // calls block for each direction that has a successful track
    // a track does not include start position, one or more
    // pieces of different color than the player's color, terminated by a piece of
    // the same color as the player.
    
    // check that piece is on board and we are placing on clear space
    Piece *piece = [internal pieceAtPositionX:boardPiece.position.x Y:boardPiece.position.y];
    
    if (piece == nil || ![piece isClear]) return nil;
    
    NSMutableArray<NSArray <BoardPiece *> *> *tracks = [[NSMutableArray alloc] initWithCapacity:10];
    
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

@end
