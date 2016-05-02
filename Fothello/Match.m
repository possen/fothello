//
//  Match.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/2/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Match.h"
#import "Player.h"
#import "FothelloGame.h"
#import "GameBoard.h"
#import "Strategy.h"

#pragma mark - Match -

@implementation Match

- (instancetype)initWithName:(NSString *)name
                     players:(NSArray<Player *> *)players
                  difficulty:(Difficulty)difficulty
{
    self = [super init];
    
    if (self)
    {
        if (players.count > 2)
            return nil;
        
        _name = name;
        _players = [players copy];
        _difficulty = difficulty;
        _currentPlayer = players[0];
        _moves = [[NSMutableArray alloc] initWithCapacity:64];
        [self setupPlayersColors];
        _board = [[GameBoard alloc] initWithBoardSize:8];
        [self reset];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        _players = [coder decodeObjectForKey:@"players"];
        _board = [coder decodeObjectForKey:@"board"];
        _name = [coder decodeObjectForKey:@"name"];
        _currentPlayer = [coder decodeObjectForKey:@"currentPlayer"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.players forKey:@"players"];
    [aCoder encodeObject:self.board forKey:@"board"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.currentPlayer forKey:@"currentPlayer"];
}


- (void)setupPlayersColors
{
    // if the player's prefered colors are the same, pick one for each.
    
    //TODO: For now twoplayer only. Future support more
    Player *player0 = self.players[0];
    Player *player1 = self.players[1];
    
    if (player0.preferredPieceColor != player1.preferredPieceColor)
    {
        player0.color = player0.preferredPieceColor;
        player1.color = player1.preferredPieceColor;
    }
    else
    {
        player0.color = PieceColorBlack;
        player1.color = PieceColorWhite;
    }
}

- (void)ready
{
    BOOL canMove = [self beginTurn];
    if (self.currentPlayerBlock)
    {
        self.currentPlayerBlock(self.currentPlayer, canMove);
    }
}

- (void)pass
{
    [self.currentPlayer.strategy pass];
    [self nextPlayer];
    [self processOtherTurns];
}

- (void)hint
{
    
}

- (void)undo
{
    
}

- (void)redo
{
    
}

- (void)reset
{
    [self endTurn];
    self.currentPlayer = self.players[0];
    for (Player *player in self.players) {
        [player.strategy resetWithDifficulty:self.difficulty];
    }
    
    GameBoard *board = self.board;
    [board reset];
    
    NSArray<Player *> *players = self.players;
    Move *center = board.center;
    
    [self boxCoord:1 block:
     ^(Move *position, BOOL isCorner, NSInteger count, BOOL *stop)
     {
         NSInteger playerCount = (count) % self.players.count;
         
         [board player:players[playerCount]
      pieceAtPositionX:center.x + position.x
                     Y:center.y + position.y];
         
         count++;
     }];
    
    NSLog(@"\n%@\n", [board toString]);

    [self beginTurn];
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
        case DirectionNone: // keeps warnings away, could use default
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
        case DirectionNone: // keeps warnings away, could use default
        case DirectionUp:
        case DirectionDown:
        case DirectionLast:
            break;
    }
    
    Delta delta; delta.dx = x; delta.dy = y;
    return delta;
}


- (BOOL)findTracksX:(NSInteger)x
                  Y:(NSInteger)y
          forPlayer:(Player *)player
         trackBlock:(void (^)(NSArray<TrackInfo *> *pieces))trackBlock
{
    // calls block for each direction that has a successful track
    // does not call for invalid tracks. Will call back for each complete track.
    // a track does not include start position, one or more
    // pieces of different color than the player's color, terminated by a piece of
    // the same color as the player.
    
    BOOL found = NO;
    
    // check that piece is on board and we are placing on clear space
    Piece *piece = [self.board pieceAtPositionX:x Y:y];
    if (piece == nil || ![piece isClear])
        return NO;
    
    // try each direction, to see if there is a track
    for (Direction direction = DirectionFirst; direction < DirectionLast; direction ++)
    {
        Delta diff = [self determineDirection:direction];
        
        NSInteger offsetx = x; NSInteger offsety = y;
        
        NSMutableArray<TrackInfo *> *track = [[NSMutableArray alloc] initWithCapacity:10];
        
        // keep adding pieces until we hit a piece of the same color, edge of board or
        // clear space.
        BOOL valid;
        
        do {
            offsetx += diff.dx; offsety += diff.dy;
            piece = [self.board pieceAtPositionX:offsetx Y:offsety];
            valid = piece && ![piece isClear]; // make sure it is on board and not clear.
            
            if (valid)
            {
                TrackInfo *trackInfo = [[TrackInfo alloc] init];
                trackInfo.x = offsetx;
                trackInfo.y = offsety;
                trackInfo.piece = piece;
                [track addObject:trackInfo];
            }
        } while (valid && piece.color != player.color);
        
        // found piece of same color, end track and call back.
        if (valid && piece.color == player.color && track.count > 1)
        {
            if (trackBlock)
                trackBlock(track);
            found = YES;
        }
    }
    
    return found;
}

- (BOOL)placePieceForPlayer:(Player *)player position:(Move *)position
{
    NSMutableArray<PlayerMove *> *pieces = [[NSMutableArray alloc] initWithCapacity:10];
    
    BOOL result = [self findTracksX:position.x Y:position.y
                          forPlayer:player
                         trackBlock:
                   ^(NSArray<Piece *> *trackInfo)
                   {
                       Piece *piece = [self.board pieceAtPositionX:position.x Y:position.y];
                       [self.board changePiece:piece withColor:player.color];
                       [pieces addObject:[PlayerMove makePiecePositionX:position.x Y:position.y piece:piece pass:position.pass]];
                       for (TrackInfo *trackItem in trackInfo)
                       {
                           piece = trackItem.piece;
                           NSInteger x = trackItem.x;
                           NSInteger y = trackItem.y;
                           [self.board changePiece:piece withColor:player.color];
                           
                           [pieces addObject:[PlayerMove makePiecePositionX:x Y:y piece:piece pass:NO]];
                       }
                   }];
    
    if (self.board.placeBlock)
    {
        self.board.placeBlock(pieces);
    }
    
    return result;
}

- (BOOL)showHintForPlayer:(Player *)player position:(Move *)position
{
    return NO;
}

- (BOOL)takeTurnAtX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass
{
    [self endTurn];

    BOOL otherPlayersMoved = NO;
    for (Player *player in self.players)
    {
        if (player != self.currentPlayer)
        {
            otherPlayersMoved |= [player otherPlayer:player movedToX:x Y:y pass:pass];
        }
    }

    BOOL moved = [self.currentPlayer takeTurnAtX:x Y:y pass:pass];
    if (!otherPlayersMoved && !moved)
    {
        return NO; // game over
    }

    // if not moved, put legal moves back.
    if (!moved)
    {
        [self beginTurn];
    }
    return moved;
}


- (BOOL)nextPlayer
{
    NSArray<Player *> *players = self.players;
    
    [self endTurn];
    BOOL prevPlayerCouldMove = self.currentPlayer.canMove;
    self.currentPlayer = (self.currentPlayer == players[0]
                          ? players[1]
                          : players[0]);
    
    NSLog(@"current player %@", self.currentPlayer);
    BOOL boardFull = [self.board boardFull];
    BOOL canMove = [self beginTurn];
    self.currentPlayer.canMove = canMove;
    
    if ((!prevPlayerCouldMove  && !canMove) || boardFull)
    {
        self.matchStatusBlock(YES);
        return NO;
    }
    
    if (self.currentPlayerBlock)
    {
        self.currentPlayerBlock(self.currentPlayer, canMove);
    }
    return YES;
}

- (BOOL)beginTurn
{
    BOOL found = [self.currentPlayer.strategy displaylegalMoves:YES forPlayer:self.currentPlayer];
    return found;
}


- (void)endTurn
{
    [self.currentPlayer.strategy displaylegalMoves:NO forPlayer:self.currentPlayer];
    
    NSLog(@"%@", self.board);
}

- (void)processOtherTurns
{
    self.turnProcessing = YES;
    __block BOOL placed = NO;
    
    double delayInSeconds = .5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,
                                            (int64_t)(delayInSeconds * NSEC_PER_SEC));
    
    dispatch_after(popTime, dispatch_get_main_queue(),
       ^(void)
       {
           dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
             ^{
                 placed = [self.currentPlayer takeTurn];
                 
                 if (! self.currentPlayer.strategy.manual && placed)
                 {
                     [self processOtherTurns];
                 }
                 
                 self.turnProcessing = NO;
             });
       });
    
    
}

- (NSInteger)calculateScore:(Player *)player
{
    return [self.board playerScore:player];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"match %@",self.name];
}


- (void)boxCoord:(NSInteger)dist block:
(void (^)(Move *position, BOOL isCorner, NSInteger count, BOOL *stop))block
{
    // calculates the positions of the pieces in a box dist from center.
    
    dist = (dist - 1) * 2 + 1; // skip even rings
    
    // calculate start position
    Move *position = [Move new];
    position.x = dist - dist / 2;
    position.y = dist - dist / 2;
    
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

- (void)addMoveAtX:(NSInteger)x Y:(NSInteger)y piece:(Piece *)piece pass:(BOOL)pass
{
    PlayerMove *move = [PlayerMove makePiecePositionX:x Y:y piece:piece pass:pass];
    
    [self.moves addObject:move];
}


- (BOOL)done
{
    return NO;
}


- (void)test
{
    NSLog(@"player %@ score %ld", self.players[0],
          (long)[self calculateScore:self.players[0]]);
    
    NSLog(@"player %@ score %ld", self.players[1],
          (long)[self calculateScore:self.players[1]]);
}


- (BOOL)isEqual:(id)name
{
    return [self.name isEqualToString:name];
}

- (NSUInteger)hash
{
    return self.name.hash;
}
@end
