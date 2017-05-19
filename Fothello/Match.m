//
//  Match.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/2/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Match.h"
#import "MatchMoves.h"
#import "Player.h"
#import "FothelloGame.h"
#import "GameBoard.h"
#import "Strategy.h"
#import "PlayerMove.h"
#import "Piece.h"
#import "BoardPosition.h"
#import "NSArray+Extensions.h"

#pragma mark - Match -

@interface Match ()
@property (nonatomic, readwrite) Player *currentPlayer;
@end

@implementation Match

- (instancetype)initWithName:(NSString *)name
                     players:(NSArray<Player *> *)players
{
    self = [super init];
    
    if (self)
    {
        if (players.count > 2) return nil;
        
        _name = name;
        _players = [players copy];
        _currentPlayer = players[0];
        [self setupPlayersColors];
        _board = [[GameBoard alloc] initWithBoardSize:8];
        _matchMoves = [[MatchMoves alloc] initWithMatch:self];
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

    player0.color = PieceColorBlack;
    player1.color = PieceColorWhite;

    if (player0.preferredPieceColor != player1.preferredPieceColor)
    {
        player0.color = player0.preferredPieceColor;
        player1.color = player1.preferredPieceColor;
    }
}


- (BOOL)turnProcessing
{
    return [self.players indexOfObjectPassingTest:^BOOL (Player * obj, NSUInteger idx, BOOL * stop)
    {
        return obj.turnProcessing;
    }] != NSNotFound;
}

- (void)beginMatch
{
    self.currentPlayer = self.players[0];

    [self.matchMoves resetMoves];
    
    if (self.movesUpdateBlock) self.movesUpdateBlock();
    
    [self beginTurn];
    
    // kick off two automatic first player.
    if (self.currentPlayer.strategy.automatic)
    {
        [self.currentPlayer takeTurn];
    }
}

- (void)endMatch
{
}

- (void)reset
{
    [self endTurn];
    
    if (self.matchStatusBlock) self.matchStatusBlock(NO);
    
    self.noMoves = NO;
    
    [self.board reset];
}

- (void)nextPlayerWithTime:(float)time
{
    [self nextPlayer];
    
    if (self.currentPlayer.strategy.automatic)
    {
        // schedule time for AI Player to start turn
        dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC);
        dispatch_after(when, dispatch_get_main_queue(), ^{
            [self.currentPlayer takeTurn];
        });
    } 
}

- (void)callMatchStatusBlock:(BOOL)result
{
    if (self.matchStatusBlock) self.matchStatusBlock(result);
}

- (void)nextPlayer
{
    NSArray<Player *> *players = self.players;
    GameBoard *board = self.board;
    Player *player1 = players[0]; Player *player2 = players[1];
    
    // this enters work queue first so will complete before the second canMove call.
    BOOL prevPlayerCouldMove = [board canMove:self.currentPlayer];
    
    self.currentPlayer = (self.currentPlayer == player1 ? player2 : player1);
    
    NSLog(@"Current Player %@ %@ %@", self.currentPlayer, self.currentPlayer.strategy, board );
    
    BOOL currentPlayerCanMove = [board canMove:self.currentPlayer];
    BOOL isFull = [board isFull];

    if (!currentPlayerCanMove) [self callMatchStatusBlock:NO];

    if ( (!prevPlayerCouldMove && !currentPlayerCanMove) || isFull)
    {
        if (!self.noMoves)
        {
            [self callMatchStatusBlock:YES];
            self.noMoves = YES;
        }
    }
}

- (void)beginTurn
{
    [self.currentPlayer beginTurn];
}

- (void)endTurn
{
    [self.currentPlayer endTurn];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"match %@", self.name];
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
        if (player.strategy.automatic)
        {
            *stop = YES;
            return YES;
        }
        return NO;
    }].count != 0;
}

- (BOOL)areAllPlayersComputers
{
    return [self.players indexesOfObjectsPassingTest:^BOOL(Player *player, NSUInteger idx, BOOL *stop) {
        if (player.strategy.automatic)
        {
            return YES;
        }
        return NO;
    }].count == self.players.count;
}

- (void)placeMove:(PlayerMove *)move forPlayer:(Player *)player
{
    NSLog(@"place move %@", move);
    [self.board placeMoves:@[move]];
    
    if (self.currentPlayerBlock)
    {
        BOOL canMove = [self.board canMoveUnqueued:self.currentPlayer];
        NSLog(@"canMove %d", canMove);
        self.currentPlayerBlock(player, canMove, move.isPass);
    }
    
    [self.matchMoves addMove:move];
}


@end

