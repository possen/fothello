//
//  AIStrategy.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/18/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "FothelloGame.h"
#import "Player.h"
#import "GameBoard.h"
#import "Strategy.h"
#import "PlayerMove.h"
#import "BoardPosition.h"
#import "Piece.h"
#import "Engine.h"
#import "Match.h"

#pragma mark - Strategy -

@interface Strategy ()
@end

@implementation Strategy

- (id)initWithEngine:(id<Engine>)engine
{
    self = [super init];
    if (self)
    {
        _engine = engine;
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

- (void)setEngine:(id<Engine>)engine
{
    _engine = engine;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.match forKey:@"match"];
}

- (void)takeTurn:(Player *)player
{
    // subclass
}

- (void)takeTurn:(Player *)player atPosition:(BoardPosition *)position
{
    // subclass
}

- (void)beginTurn:(Player *)player
{
    // subclass
}

- (void)endTurn:(Player *)player
{
    // subclass
}

- (PlayerMove *)calculateMoveForPlayer:(Player *)player difficulty:(Difficulty)difficulty
{
    NSAssert(self.engine != nil, @"No engine!");
    NSAssert(self.match != nil, @"No match!");

    NSDictionary *response = [self.engine calculateMoveForPlayer:player
                                                           match:self.match
                                                      difficulty:difficulty];
    if ([response[@"pass"] boolValue])
    {
        PlayerMove *makeMoveForColor = [PlayerMove makePassMoveForColor:player.color];
        return makeMoveForColor;
    }
    BoardPosition *boardPosition = [BoardPosition positionWithX:[response[@"movex"] integerValue]
                                                              y:[response[@"movey"] integerValue]];
    return [PlayerMove makeMoveForColor:player.color position:boardPosition];
}

- (void)hintForPlayer:(Player *)player
{
    // subclass
}

- (void)makeMoveForPlayer:(Player *)player
{
    // subclass
}

- (void)makeMove:(PlayerMove *)move forPlayer:(Player *)player
{
    // uses highlight block.
    [self.match.board showClickedMove:move forPlayer:player];
}

@end




