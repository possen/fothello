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

- (void)replayMoves
{
    [self reset];
 
    NSArray<PlayerMove *> *moves = [self.moves copy];
    
    [self.moves removeAllObjects]; // replaying them, so need to clear this out to avoid readd check.
    
    [moves enumerateObjectsWithOptions:0 usingBlock:^(PlayerMove *move, NSUInteger idx, BOOL *stop)
     {
         NSLog(@"replay move %@", move);
         Player *player = self.players[idx % 2];
         [self.board updateBoard:^NSArray<NSArray<BoardPiece *> *> *
          {
              NSArray<NSArray<BoardPiece *> *> *pieces = [self.board placeMove:move forPlayer:player];
              return pieces;
          }];
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
        
        [self placeMove:move forPlayer:player];
    }
}

- (BOOL)isLegalMove:(nonnull PlayerMove *)move forPlayer:(nonnull Player *)player
{
    if ([move isPass])
    {
        return YES;
    }
    
    NSArray <BoardPiece *> *legalMoves = [self.board legalMovesForPlayer:player];
    
    BOOL legalMove = legalMoves != nil
            && [legalMoves indexOfObjectPassingTest:^
        BOOL (BoardPiece *boardPiece, NSUInteger idx, BOOL *stop)
        {
            return boardPiece.position.x == move.position.x
            && boardPiece.position.y == move.position.y;
        }] != NSNotFound;
    
    return legalMove;
}

- (void)placeMove:(PlayerMove *)move forPlayer:(Player *)player
{
    [self.board updateBoard:^NSArray<NSArray<BoardPiece *> *> *
     {
         NSArray<NSArray<BoardPiece *> *> *pieces = [self.board placeMove:move forPlayer:player];
         return pieces;
     }];

    [self addMove:move];

    if (self.currentPlayerBlock)
    {
        BOOL currentPlayerCanMove = [self.board canMove:self.currentPlayer];
        self.currentPlayerBlock(self.currentPlayer, currentPlayerCanMove);
    }
}

- (BOOL)turnProcessing
{
    return [self.players indexOfObjectPassingTest:^BOOL (Player * obj, NSUInteger idx, BOOL * stop)
    {
        return obj.turnProcessing;
    }] == NSNotFound;
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
}

- (void)reset
{
    [self.currentPlayer endTurn];
    
    GameBoard *board = self.board;
    
    if (self.matchStatusBlock)
    {
        self.matchStatusBlock(NO);
    }
    self.noMoves = NO;
    
    [board reset];
}

- (void)nextPlayer
{
    NSArray<Player *> *players = self.players;
    
    BOOL prevPlayerCouldMove = [self.board canMove:self.currentPlayer];
    
    self.currentPlayer = (self.currentPlayer == players[0]
                          ? players[1]
                          : players[0]);
    
    NSLog(@"Current Player %@ %@", self.currentPlayer, self.currentPlayer.strategy );
    
    BOOL currentPlayerCanMove = [self.board canMove:self.currentPlayer];
    BOOL isFull = [self.board isFull];
    NSLog(@"Board  %@ ", self.board );
   
    if ((!prevPlayerCouldMove  && !currentPlayerCanMove) || isFull)
    {
        self.matchStatusBlock(YES);
        self.noMoves = YES;
    }    
}

- (void)beginTurn
{
    [self.board updateBoard:^NSArray<NSArray<BoardPiece *> *> *
    {
         return [self.currentPlayer beginTurn];
     }];
}

- (void)endTurn
{
    [self.board updateBoard:^NSArray<NSArray<BoardPiece *> *> *
    {
        return [self.currentPlayer endTurn];
    }];
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
    if (!move.isPass  && [self.moves containsObject:move] )
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

