//
//  Strategy.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/2/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "Strategy.h"
#import "Match.h"
#import "GameBoard.h"

#pragma mark - Strategy -

@implementation Strategy

// Not done and not used yet.
- (id)initWithMatch:(Match *)match
{
    self = [super init];
    if (self)
    {
        _match = match;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        _match = [coder decodeObjectForKey:@"match"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.match forKey:@"match"];
}

- (BOOL)takeTurn:(Player *)player atX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass
{
    // subclass
    return NO;
}

- (BOOL)otherPlayer:(Player *)player movedToX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass
{
    // subclass
    return YES;
}


- (void)convertBoard
{
    // subclass
}

- (BOOL)displaylegalMoves:(BOOL)display forPlayer:(Player *)player
{
    Match *match = self.match;
    GameBoard *board = match.board;
    __block BOOL foundLegal = NO;
    
    NSMutableArray *pieces = [[NSMutableArray alloc] initWithCapacity:10];
    if (display)
    {
        // Determine moves
        [board visitAll:^(NSInteger x, NSInteger y, Piece *piece)
         {
             BOOL foundMove = [match findTracksX:x Y:y
                                       forPlayer:player
                                      trackBlock:nil];
             if (foundMove)
             {
                 Piece *piece = [board pieceAtPositionX:x Y:y];
                 PieceColor color = display ? PieceColorLegal : PieceColorNone;
                 if (piece.color != color)
                 {
                     [board changePiece:piece withColor:color];
                     
                     if (self.manual)
                     {
                         [pieces addObject:[PlayerMove makePiecePositionX:x Y:y piece:piece pass:NO]];
                     }
                 }
                 foundLegal = YES;
             }
         }];
    }
    else
    {
        [board visitAll:^(NSInteger x, NSInteger y, Piece *piece)
         {
             if (piece.color == PieceColorLegal)
             {
                 [board changePiece:piece withColor:PieceColorNone];
                 [pieces addObject:[PlayerMove makePiecePositionX:x Y:y piece:piece pass:NO]];
             }
         }];
    }
    
    board.placeBlock(pieces);
    
    return foundLegal;
}

- (void)resetWithDifficulty:(Difficulty)difficulty
{
    // subclass
}

- (void)pass
{
    // subclass
}

@end

#pragma mark - HumanStategy -

@implementation HumanStrategy

- (BOOL)manual
{
    return YES;
}

- (BOOL)takeTurn:(Player *)player atX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass
{
    [super takeTurn:player atX:x Y:y pass:pass];
    
    Match *match = self.match;
    
    BOOL placed = [match placePieceForPlayer:player atX:x Y:y];
    return placed;
}


@end
