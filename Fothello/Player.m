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

- (BOOL)beginTurn
{
   return [self.strategy beginTurn:self];
}

- (void)endTurn
{
    [self.strategy endTurn:self];
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

- (void)makeMoveAtPosition:(BoardPosition *)position
{
    PlayerMove *move = [PlayerMove makeMoveForColor:self.color position:position];
    [self.strategy makeMove:move forPlayer:self];
}

- (void)makePassMove
{
    PlayerMove *move = [PlayerMove makePassMoveForColor:self.color];
    [self.strategy makeMove:move forPlayer:self];
}

- (void)makeMove // AI players
{
    [self.strategy makeMove:self];
}



@end
