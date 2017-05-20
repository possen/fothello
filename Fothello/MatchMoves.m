//
//  MatchMoves.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/19/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import "MatchMoves.h"
#import "Player.h"
#import "Match.h"
#import "GameBoard.h"
#import "PlayerMove.h"

@interface MatchMoves ()
@property (nonatomic, readwrite) NSMutableArray *redos;
@property (nonatomic) Match *match;
@end

@implementation MatchMoves

- (instancetype)initWithMatch:(Match *)match
{
    self = [super init];
    if (self) {
        
        _moves = [[NSMutableArray alloc] initWithCapacity:64];
        _redos = [[NSMutableArray alloc] initWithCapacity:64];
        _match = match;
    }
    return self;
}

- (void)replayMoves
{
    [self.match reset];
    
    NSArray<PlayerMove *> *moves = [self.moves copy];
    
    NSLog(@"replay moves");
    for (PlayerMove *obj in moves)
    {
        NSLog(@"move %@", obj.description);
    }
    [self.match.board placeMoves:moves];
    [self.match beginTurn];
}


- (void)undo
{
    // remove the last move
    [self removeMove];
    
    // if the next player is a computer then remove that one too.
    if ([self.match isAnyPlayerAComputer])
    {
        [self removeMove];
    }
    
    [self replayMoves];
}

- (void)redo
{
    if (self.redos.count == 0) return;
    
    for (Player *player in self.match.players)
    {
        PlayerMove *move = [self.redos lastObject];
        [self.redos removeLastObject];
        
        NSLog(@"redo %@", move);
        
        [self.match placeMove:move forPlayer:player];
    }
}

- (void)resetMoves
{
    [self resetRedos];
    [self.moves removeAllObjects];
}

- (void)resetRedos
{
    [self.redos removeAllObjects];
}

- (PlayerMove *)addMove:(PlayerMove *)move
{
    // need to allow multiple pass objects.
    if (!move.isPass  && [self.moves containsObject:move] ) return nil; // dont add twice
    
    [self.moves addObject:[move copy]];
    
    if (self.match.movesUpdateBlock) self.match.movesUpdateBlock();
    
    return move;
}

- (PlayerMove *)removeMove
{
    PlayerMove *move = [self.moves lastObject];
    [self.redos addObject:move];
    [self.moves removeLastObject];
    
    if (self.match.movesUpdateBlock) self.match.movesUpdateBlock();
    
    return move;
}

@end
