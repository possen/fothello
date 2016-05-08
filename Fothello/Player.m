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
        _canMove = YES;
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
        _canMove = [aDecoder decodeBoolForKey:@"canMove"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeInteger:self.preferredPieceColor forKey:@"prefereredPieceColor"];
    [aCoder encodeInteger:self.color forKey:@"currentPieceColor"];
    [aCoder encodeObject:self.strategy forKey:@"strategy"];
    [aCoder encodeBool:self.canMove forKey:@"canMove"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"name %@",self.name];
}

- (BOOL)takeTurn // automatic players
{
    BOOL moved = [self.strategy takeTurn:self atX:-1 Y:-1 pass:NO];
    
    if (moved)
    {
        moved = [self.strategy.match nextPlayer];
    }
    return moved;
}

- (BOOL)takeTurnAtX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass
{
    BOOL moved = [self.strategy takeTurn:self atX:x Y:y pass:pass];
    
    if (moved)
    {
        [self.strategy.match nextPlayer];
    }
    return moved;
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
