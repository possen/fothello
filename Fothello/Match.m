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

@interface Match ()
@end

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
        _redos = [[NSMutableArray alloc] initWithCapacity:64];
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
    Piece *piece = [[Piece alloc] initWithColor:self.currentPlayer.color];    
    PlayerMove *move = [PlayerMove makePassMoveWithPiece:piece];
    [self addMove:move];
    [self nextPlayer];
    [self processOtherTurns];
}

- (void)replayMoves
{
    [self reset];
    
    for (PlayerMove *move in [self.moves copy])
    {
        [self takeTurnAtX:move.position.x Y:move.position.y pass:move.position.isPass];
    }
}

- (void)undo
{
    [self removeMove];
    
    if ([self isAnyPlayerAComputer])
    {
        [self removeMove];
    }

    [self reset];
    [self replayMoves];
}

- (void)redo
{
    if (self.redos.count == 0)
    {
        return;
    }
    
    for (Player *player in self.players)
    {
        if (!player.strategy.manual)
        {
            PlayerMove *move = [self.redos lastObject];
            [self.redos removeLastObject];
            [self takeTurnAtX:move.position.x Y:move.position.y pass:move.position.isPass];
        }
    }
}

- (void)hint
{
    [self.currentPlayer.strategy hintForPlayer:self.currentPlayer];
}

- (void)fullReset
{
    self.currentPlayer = self.players[0];

    [self.redos removeAllObjects];
    [self.moves removeAllObjects];
    [self reset];
    [self ready];
}

- (void)reset
{
    [self endTurn];
    
    GameBoard *board = self.board;
    [board reset];
    
    NSArray<Player *> *players = self.players;
    BoardPosition *center = board.center;
    
    [self boxCoord:1 block:
     ^(BoardPosition *position, BOOL isCorner, NSInteger count, BOOL *stop)
     {
         NSInteger playerCount = (count) % self.players.count;
         
         [board player:players[playerCount]
      pieceAtPositionX:center.x + position.x
                     Y:center.y + position.y];
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


- (BOOL)findTracksForMove:(PlayerMove *)move
                forPlayer:(Player *)player
               trackBlock:(void (^)(NSArray<BoardPiece *> *pieces))trackBlock
{
    // calls block for each direction that has a successful track
    // does not call for invalid tracks. Will call back for each complete track.
    // a track does not include start position, one or more
    // pieces of different color than the player's color, terminated by a piece of
    // the same color as the player.
    
    BOOL found = NO;
    
    // check that piece is on board and we are placing on clear space
    Piece *piece = [self.board pieceAtPositionX:move.position.x Y:move.position.y];
    if (piece == nil || ![piece isClear])
    {
        return NO;
    }
   
    // try each direction, to see if there is a track
    for (Direction direction = DirectionFirst; direction < DirectionLast; direction ++)
    {
        Delta diff = [self determineDirection:direction];
        
        NSInteger offsetx = move.position.x; NSInteger offsety = move.position.y;
        Piece *piece;
        
        NSMutableArray<BoardPiece *> *track = [[NSMutableArray alloc] initWithCapacity:10];
        
        // keep adding pieces until we hit a piece of the same color, edge of board or
        // clear space.
        BOOL valid;
        
        do {
            offsetx += diff.dx; offsety += diff.dy;
            piece = [self.board pieceAtPositionX:offsetx Y:offsety];
            valid = piece && ![piece isClear]; // make sure it is on board and not clear.
            
            if (valid)
            {
                BoardPosition *offset = [BoardPosition positionWithX:offsetx y:offsety];
                BoardPiece *trackInfo = [BoardPiece makeBoardPieceWithPiece:piece position:offset];
                [track addObject:trackInfo];
            }
        } while (valid && piece.color != player.color);
        
        // found piece of same color, end track and call back.
        if (valid && piece.color == player.color && track.count > 1)
        {
            if (trackBlock)
            {
                trackBlock(track);
            }
            found = YES;
        }
    }
    
    return found;
}

- (BOOL)placeMove:(PlayerMove *)move forPlayer:(Player *)player
{
    NSMutableArray<BoardPiece *> *pieces = [[NSMutableArray alloc] initWithCapacity:10];
    BoardPosition *position = move.position;

    // briefly highlight position
    self.highlightBlock(position.x, move.position.y, player.color == PieceColorWhite ? PieceColorRed : PieceColorBlue);

    
    BOOL result = [self findTracksForMove:move
                          forPlayer:player
                         trackBlock:
                   ^(NSArray<Piece *> *trackInfo)
                   {
                       Piece *piece = [self.board pieceAtPositionX:position.x Y:position.y];
                       [self.board changePiece:piece withColor:player.color];
                       
                       // add the piece to the list of moves.
                       [self addMove:move];
                       
                       [pieces addObject:move];
                       
                       for (BoardPiece *trackItem in trackInfo)
                       {
                           piece = trackItem.piece;
                           NSInteger x = trackItem.position.x;
                           NSInteger y = trackItem.position.y;
                           [self.board changePiece:piece withColor:player.color];
                           BoardPosition *position = [BoardPosition positionWithX:x y:y];
                           [pieces addObject:[BoardPiece makeBoardPieceWithPiece:piece position:position]];
                       }
                   }];
    
    if (self.board.placeBlock)
    {
        self.board.placeBlock(pieces);
    }
    
    return result;
}

- (void)showHintMove:(PlayerMove *)move forPlayer:(Player *)player
{
    self.highlightBlock(move.position.x, move.position.y, player.color);
}

- (BOOL)takeTurnAtX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass
{
    [self endTurn];


    BOOL moved = [self.currentPlayer takeTurnAtX:x Y:y pass:pass];
    if (!moved)
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
    return [self.currentPlayer.strategy displaylegalMoves:YES forPlayer:self.currentPlayer];
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

- (void)resetRedos
{
    [self.redos removeAllObjects];
}

- (PlayerMove *)addMove:(PlayerMove *)move
{
    [self.moves addObject:move];
    [self resetRedos];
    return move;
}

- (PlayerMove *)removeMove
{
    PlayerMove *move = [self.moves lastObject];
    [self.redos addObject:move];
    [self.moves removeLastObject];
    return move;
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

- (BOOL)isAnyPlayerAComputer
{
    return [self.players indexesOfObjectsPassingTest:^BOOL(Player *player, NSUInteger idx, BOOL *stop)
    {
        if (!player.strategy.manual)
        {
            *stop = YES;
            return YES;
        }
        return NO;
    }].count != 0;
}

- (BOOL)areAllPlayersComputers
{
    return [self.players indexesOfObjectsPassingTest:^BOOL(Player *player, NSUInteger idx, BOOL *stop)
            {
                if (!player.strategy.manual)
                {
                    return YES;
                }
                return NO;
            }].count == self.players.count;
}

@end

#pragma mark - PlayerMove -

@implementation PlayerMove

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
    return [NSString stringWithFormat:@"%ld %ld %@", (long)self.position.x, (long)self.position.y, self.piece];
}
@end

