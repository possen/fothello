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
@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic, readwrite) Player *currentPlayer;
@property (nonatomic, readwrite) BOOL turnProcessing;
@property (nonatomic, readwrite) NSMutableArray *redos;
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
        _queue = dispatch_queue_create("match update queue", DISPATCH_QUEUE_SERIAL);
        _board = [[GameBoard alloc] initWithBoardSize:8 queue:_queue];
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
    if ([self isAnyPlayerAComputer])
    {
        [self takeTurn];
    }
}

- (void)pass
{
    Piece *piece = [[Piece alloc] initWithColor:self.currentPlayer.color];    
    PlayerMove *move = [PlayerMove makePassMoveWithPiece:piece];
    [self addMove:move];
    [self nextPlayer];
    [self takeTurn];
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

- (void)restart
{
    self.currentPlayer = self.players[0];

    [self.redos removeAllObjects];
    [self.moves removeAllObjects];
    
    if (self.movesUpdateBlock)
    {
        self.movesUpdateBlock();
    }
    
    [self reset];
    [self ready];
}

- (void)reset
{
    [self endTurn];
    
    GameBoard *board = self.board;
    
    if (self.matchStatusBlock) {
        self.matchStatusBlock(NO);
    }

    [board updateBoardWithFunction:^NSArray<BoardPiece *> *
     {
         return [board erase];
     }];
    
    // place initial pieces.
    [board updateBoardWithFunction:^NSArray<BoardPiece *> *
    {
        NSMutableArray<BoardPiece *> *pieces = [[NSMutableArray alloc] initWithCapacity:10];
        NSArray<Player *> *players = self.players;
        BoardPosition *center = board.center;
        
        [board boxCoord:1 block:
         ^(BoardPosition *position, BOOL isCorner, NSInteger count, BOOL *stop)
         {
             NSInteger playerCount = count % self.players.count;
             Player *player = players[playerCount];
             NSInteger x = center.x + position.x; NSInteger y = center.y + position.y;             
             Piece *piece = [board pieceAtPositionX:x Y:y];
             BoardPosition *pos = [[BoardPosition alloc] initWithX:x Y:y];
             [pieces addObject:[BoardPiece makeBoardPieceWithPiece:piece position:pos color:player.color]];
         }];
        
        return [pieces copy];
    }];
    
    [board updateBoardWithFunction:^NSArray<BoardPiece *> *
    {
        return [self beginTurn];
    }];
}

- (NSArray <BoardPiece *> *)placeMove:(PlayerMove *)move forPlayer:(Player *)player
{
    NSMutableArray<BoardPiece *> *pieces = [[NSMutableArray alloc] initWithCapacity:10];
    BoardPosition *position = move.position;

    // briefly highlight position
    self.highlightBlock(move, player.color == PieceColorWhite ? PieceColorRed : PieceColorBlue);

    BOOL result = [self.board findTracksForMove:move
                                      forPlayer:player
                                     trackBlock:
    ^(NSArray<Piece *> *trackInfo)
    {
        // add the piece to the list of moves.
        if ([self addMove:move] == nil)
        {
            return;
        }
        
        NSLog(@"move %@", move);
        Piece *movePiece = [self.board pieceAtPositionX:move.position.x Y:move.position.y];
        BoardPiece *moveBoardPiece = [BoardPiece makeBoardPieceWithPiece:movePiece position:move.position color:player.color];
        [pieces addObject:moveBoardPiece];
        NSArray <BoardPiece *> *morePieces = [self.board updateWithTrack:trackInfo position:position player:player];
        [pieces addObjectsFromArray:morePieces];
    }];
    
    return result ? [pieces copy] : nil;
}

- (void)showHintMove:(PlayerMove *)move forPlayer:(Player *)player
{
    [self.board updateBoardWithFunction:^NSArray<BoardPiece *> *
     {
         self.highlightBlock(move, player.color);
         return nil;
     }];
}

- (void)takeTurnAtX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass
{
    [self.board updateBoardWithFunction:^NSArray<BoardPiece *> *
    {
        return [self endTurn];
    }];
    
    NSArray <BoardPiece *> * pieces = [self.currentPlayer takeTurnAtX:x Y:y pass:pass];
    
    if (pieces.count == 0 && !pass) // invalid move, restart turn.
    {
        [self.board updateBoardWithFunction:^NSArray<BoardPiece *> *
         {
             return [self beginTurn];
         }];
    }
    else
    {
        [self.board updateBoardWithFunction:^NSArray<BoardPiece *> *
        {
            return pieces;
        }];
        
        [self nextPlayer];
        [self takeTurn];
    }
}

- (void)takeTurn
{
    self.turnProcessing = YES;
    
    double delayInSeconds = .5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,
                                            (int64_t)(delayInSeconds * NSEC_PER_SEC));
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
       [self.board updateBoardWithFunction:^NSArray<BoardPiece *> *
        {
            NSArray <BoardPiece *> *pieces = [self.currentPlayer takeTurn];
        
            if (pieces != nil) // it was a AI player if non null
            {
                [self nextPlayer];
                [self takeTurn];                
            }
            else
            {
                self.turnProcessing = NO; // enable UI.
            }
         
            return pieces;
        }];
    });
}

- (void)nextPlayer
{
    NSArray<Player *> *players = self.players;
    BOOL prevPlayerCouldMove = self.currentPlayer.canMove;
    self.currentPlayer = (self.currentPlayer == players[0]
                          ? players[1]
                          : players[0]);
    
    [self.board updateBoardWithFunction:^NSArray<BoardPiece *> *
    {
       return [self endTurn];
    }];

    [self.board updateBoardWithFunction:^NSArray<BoardPiece *> *
     {
         NSLog(@"current player %@", self.currentPlayer);
         
         NSArray <BoardPiece *> * pieces = [self beginTurn];
         
         BOOL currentPlayerCanMove = self.currentPlayer.canMove;
         BOOL boardFull = [self.board boardFull];
         
         if ((!prevPlayerCouldMove  && !currentPlayerCanMove) || boardFull)
         {
             self.matchStatusBlock(YES);
         }

         if (self.currentPlayerBlock)
         {
             self.currentPlayerBlock(self.currentPlayer, currentPlayerCanMove);
         }
         return pieces;
    }];    
}

- (NSArray <BoardPiece *> *)beginTurn
{
    // don't display legal moves for AI players.
    if (!self.currentPlayer.strategy.manual)
    {
        return nil;
    }

    return [self.currentPlayer.strategy legalMoves:YES forPlayer:self.currentPlayer];
}

- (NSArray <BoardPiece *> *)endTurn
{
    if (!self.currentPlayer.strategy.manual)
    {
        return nil;
    }
    
    NSArray <BoardPiece *> *pieces = [self.currentPlayer.strategy legalMoves:NO forPlayer:self.currentPlayer];
    
    NSLog(@"%@", self.board);
    return pieces;
}

- (NSInteger)calculateScore:(Player *)player
{
    return [self.board playerScore:player];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"match %@",self.name];
}

- (void)resetRedos
{
    [self.redos removeAllObjects];
}

- (PlayerMove *)addMove:(PlayerMove *)move
{
    if ([self.moves containsObject:move])
    {
        return nil; // dont add twice
    }
    
    [self.moves addObject:[move copy]];
    [self resetRedos];
    
    if (self.movesUpdateBlock)
    {
        self.movesUpdateBlock();
    }
    
    return move;
}

- (PlayerMove *)removeMove
{
    PlayerMove *move = [self.moves lastObject];
    [self.redos addObject:move];
    [self.moves removeLastObject];
    
    if (self.movesUpdateBlock)
    {
        self.movesUpdateBlock();
    }
    
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

- (instancetype)copyWithZone:(NSZone *)zone
{
    PlayerMove *move = [[self class] allocWithZone:zone];
    move.piece = [self.piece copy];
    move.position = [self.position copy];
    return move;
}

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
    NSString  *pieceStr = self.piece.description;
    return (!self.isPass)
            ? [NSString stringWithFormat:@"%@ %ld - %ld ", pieceStr, (long)self.position.x + 1, (long)self.position.y + 1]
            : [NSString stringWithFormat:@"%@ Pass", pieceStr];
}

- (BOOL)isPass
{
    return self.position.x == -1;
}

@end

