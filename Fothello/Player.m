//
//  Player.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/2/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "Player.h"
#import "Strategy.h"
#import "Match.h"

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

- (BOOL)canMove
{
    NSArray <BoardPiece *> *moves = [self.strategy legalMoves:YES forPlayer:self];
    return moves != nil;
}

- (NSArray <BoardPiece *> *)takeTurn // automatic players
{
    NSArray <BoardPiece *> * pieces = [self.strategy takeTurn:self];
    return pieces;
}

- (NSArray <BoardPiece *> *)takeTurnAtX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass
{
    NSArray <BoardPiece *> * pieces = [self.strategy takeTurn:self atX:x Y:y pass:pass];
    return pieces;
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
