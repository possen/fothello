//
//  AIStrategy.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/27/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "AIStrategy.h"
#import "FothelloGame.h"

@interface Strategy (Protected)
- (nullable PlayerMove *)calculateMoveForPlayer:(nonnull Player *)player difficulty:(Difficulty)difficulty;
@end

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

- (void)makeMove:(Player *)player
{    
    double delayInSeconds = .5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,
                                            (int64_t)(delayInSeconds * NSEC_PER_SEC));
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
   {
       
       PlayerMove *move = [self calculateMoveForPlayer:player difficulty:self.difficulty];
       [super makeMove:move forPlayer: player];
       [self.match placeMove:move forPlayer:player];
   });

}


@end
