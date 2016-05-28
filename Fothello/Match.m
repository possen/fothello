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
#import "PlayerMove.h"
#import "Piece.h"
#import "BoardPosition.h"

#pragma mark - Match -

@interface Match ()
@property (nonatomic, readwrite) Player *currentPlayer;
@property (nonatomic, readwrite) BOOL turnProcessing;
@property (nonatomic, readwrite) NSMutableArray *redos;
@end

@implementation Match

- (instancetype)initWithName:(NSString *)name
                     players:(NSArray<Player *> *)players
{
    self = [super init];
    
    if (self)
    {
        if (players.count > 2)
            return nil;
        
        _name = name;
        _players = [players copy];
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

- (void)replayMoves
{
    [self reset];
 
    NSArray<PlayerMove *> *moves = [self.moves copy];
    
    [self.moves removeAllObjects]; // replaying them, so need to clear this out to avoid readd check.
    
    [moves enumerateObjectsWithOptions:0 usingBlock:^(PlayerMove *move, NSUInteger idx, BOOL *stop)
     {
          NSLog(@"replay move %@", move);
          Player *player = self.players[idx % 2];
          [self.board placeMove:move forPlayer:player showMove:NO];
     }];
}

- (void)undo
{
    // remove the last move
    [self removeMove];
    
    // if the next player is a computer then remove that one too.
    if ([self isAnyPlayerAComputer])
    {
        [self removeMove];
    }

    [self replayMoves];
    [self beginTurn];
}

- (void)redo
{
    if (self.redos.count == 0)
    {
        return;
    }

    for (Player *player in self.players)
    {
        PlayerMove *move = [self.redos lastObject];
        [self.redos removeLastObject];
        
        NSLog(@"redo %@", move);
        
        [self placeMove:move forPlayer:player showMove:YES];
    }
    
    [self beginTurn];
}

- (void)placeMove:(PlayerMove *)move forPlayer:(Player *)player showMove:(BOOL)showMove
{
    [self.board placeMove:move forPlayer:player showMove:showMove];
    [self addMove:move];
    [self nextPlayer];
    [self takeTurn];
    
    if (player.strategy.manual) // it was a AI player if non null
    {
        self.turnProcessing = NO; // enable UI.
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
    
    [self beginTurn];
    [self ready];
}

- (void)reset
{
    [self endTurn];
    
    GameBoard *board = self.board;
    
    if (self.matchStatusBlock)
    {
        self.matchStatusBlock(NO);
    }
    self.noMoves = NO;
    
    [board reset];
}

- (void)showHintMove:(PlayerMove *)move forPlayer:(Player *)player
{
    [self.board showHintMove:move forPlayer:player];
}

- (void)takeTurnAtX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass
{
    [self resetRedos];
    [self endTurn];
    
    if ([self.board legalMoves:YES forPlayer:self.currentPlayer])
    {
        [self.currentPlayer takeTurnAtX:x Y:y pass:pass];
    }
    else
    {
        [self beginTurn]; // reset not a valid move.
    }
}

- (void)takeTurn
{
    self.turnProcessing = YES;
    
    if (self.noMoves)
        return;
    
    double delayInSeconds = .5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,
                                            (int64_t)(delayInSeconds * NSEC_PER_SEC));
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
        [self.currentPlayer takeTurn];
    });
}

- (void)takeTurnPass
{
    PlayerMove *move = [PlayerMove makePassMoveForColor:self.currentPlayer.color];
    [self addMove:move];
    [self resetRedos];
    [self nextPlayer];
    [self takeTurn];
}

- (void)nextPlayer
{
    NSArray<Player *> *players = self.players;
    
    BOOL prevPlayerCouldMove = [self.board canMove:self.currentPlayer];
    [self endTurn];

    self.currentPlayer = (self.currentPlayer == players[0]
                          ? players[1]
                          : players[0]);
    
    [self beginTurn];
         
     BOOL currentPlayerCanMove = [self.board canMove:self.currentPlayer];
     BOOL isFull = [self.board isFull];
     
     if ((!prevPlayerCouldMove  && !currentPlayerCanMove) || isFull)
     {
         self.matchStatusBlock(YES);
         self.noMoves = YES;
     }

     if (self.currentPlayerBlock)
     {
         self.currentPlayerBlock(self.currentPlayer, currentPlayerCanMove);
     }
}

- (void)beginTurn
{
    // don't display legal moves for AI players.
    if (!self.currentPlayer.strategy.manual)
    {
        return;
    }

    [self.board legalMoves:YES forPlayer:self.currentPlayer];
}

- (void)endTurn
{
    if (!self.currentPlayer.strategy.manual)
    {
        return;
    }
    
    [self.board legalMoves:NO forPlayer:self.currentPlayer];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"match %@", self.name];
}

- (void)resetRedos
{
    [self.redos removeAllObjects];
}

- (PlayerMove *)addMove:(PlayerMove *)move
{
    // need to allow multiple pass objects.
    if (!move.position.isPass  && [self.moves containsObject:move] )
    {
        return nil; // dont add twice
    }
    
    [self.moves addObject:[move copy]];
    
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
          (long)[self.board playerScore:self.players[0]]);
    
    NSLog(@"player %@ score %ld", self.players[1],
          (long)[self.board playerScore:self.players[1]]);
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

