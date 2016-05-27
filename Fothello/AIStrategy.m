//
//  AIStrategy.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/27/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "AIStrategy.h"
#import "FothelloGame.h"

#pragma mark - AIStrategy -

@interface AIStrategy ()
@property (nonatomic) Difficulty difficulty;
@end

@implementation AIStrategy
@synthesize difficulty = _difficulty;

- (BOOL)manual
{
    return NO;
}

- (id)initWithMatch:(Match *)match
{
    self = [super initWithMatch:match];
    if (self)
    {
        _difficulty = DifficultyEasy;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _difficulty = (Difficulty)[aDecoder decodeIntegerForKey:@"difficulty"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeInteger:self.difficulty forKey:@"difficulty"];
}


- (NSArray <BoardPiece *> *)takeTurn:(Player *)player
{
    PlayerMove *move = [self calculateMoveForPlayer:player difficulty:self.difficulty];
    Match *match = self.match;
    return [match placeMove:move forPlayer:player showMove:YES];
}


@end
