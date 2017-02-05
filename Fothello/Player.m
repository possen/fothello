//
//  Player.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/2/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "Player.h"
#import "Strategy.h"
#import "PlayerMove.h"

#pragma mark - Player -

@interface Player ()
@end

@implementation Player

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    
    if (self)
    {
        _name = name;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _preferredPieceColor = [aDecoder decodeIntegerForKey:@"prefereredPieceColor"];
        _color = [aDecoder decodeIntegerForKey:@"currentPieceColor"];
        _strategy = [aDecoder decodeObjectForKey:@"strategy"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeInteger:self.preferredPieceColor forKey:@"prefereredPieceColor"];
    [aCoder encodeInteger:self.color forKey:@"currentPieceColor"];
    [aCoder encodeObject:self.strategy forKey:@"strategy"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"name %@",self.name];
}

- (void)beginTurn
{
   return [self.strategy beginTurn:self];
}

- (void)endTurn
{
    return [self.strategy endTurn:self];
}

- (BOOL)isEqual:(id)name
{
    return [self.name isEqualToString:name];
}

- (NSUInteger)hash
{
    return self.name.hash;
}

- (void)hint
{
    [self.strategy hintForPlayer:self];
}

- (void)takeTurnAtPosition:(BoardPosition *)position
{
    PlayerMove *move = [PlayerMove makeMoveForColor:self.color position:position];
    [self.strategy makeMove:move forPlayer:self];
}

- (void)takeTurn // AI players
{ 
    return [self.strategy makeMoveForPlayer:self];
}

- (void)takeTurnPass
{
    PlayerMove *move = [PlayerMove makePassMoveForColor:self.color];
    [self.strategy makeMove:move forPlayer:self];
}


@end
