//
//  AIStrategy.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/27/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "AIStrategy.h"
#import "FothelloGame.h"
#import "Player.h"
#import "GameBoard.h"

@interface Strategy (Protected)
- (nullable PlayerMove *)calculateMoveForPlayer:(nonnull Player *)player difficulty:(Difficulty)difficulty;
@end

#pragma mark - AIStrategy -

@interface AIStrategy ()
@property (nonatomic) Difficulty difficulty;
@property (nonatomic, readwrite) BOOL turnProcessing;
@end

@implementation AIStrategy

@synthesize difficulty = _difficulty;

- (BOOL)automatic
{
    return YES;
}

- (id)initWithDifficulty:(Difficulty)difficulty
{
    self = [super init];
    if (self)
    {
        _difficulty = difficulty;
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

- (void)makeMoveForPlayer:(Player *)player
{
    self.turnProcessing = YES;
    dispatch_async(self.match.board.queue, ^
    {
        PlayerMove *move = [self calculateMoveForPlayer:player difficulty:self.difficulty];
        [super makeMove:move forPlayer:player];
        [self.match placeMove:move forPlayer:player];
        self.turnProcessing = NO;
    });
}

@end
