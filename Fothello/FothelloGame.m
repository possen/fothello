//
//  Fothello.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/10/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import "FothelloGame.h"
#import "Strategy.h"
#import "Match.h"
#import "Player.h"
#import "AIStrategy.h"
#import "BoardScene.h"
#import "HumanStrategy.h"

#pragma mark - FothelloGame -

@implementation FothelloGame

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    __strong static id _sharedObject = nil;
    
    dispatch_once(&onceToken,
    ^{
        NSString *filename = [self pathForGameState];
        
        FothelloGame *fothello = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];

        // if there is no saved game state create it for the first time.
        if (fothello == nil)
        {
            fothello = [[FothelloGame alloc] init];
        }

        _sharedObject = fothello;
    }); 
    
    return _sharedObject;
}


+ (NSString *)pathForGameState
{
    NSString *docsPath
    = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
       objectAtIndex:0];
    
    NSString *filename = [docsPath stringByAppendingPathComponent:@"Fothello"];
    
    return filename;
}

- (void)saveGameState
{
    FothelloGame *game = [FothelloGame sharedInstance];
    NSString *filename = [FothelloGame pathForGameState];
    
    [NSKeyedArchiver archiveRootObject:game toFile:filename];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        srand((unsigned)time(NULL));
        _matchOrder = [[NSMutableArray alloc] initWithCapacity:10];
        _matches = [[NSMutableDictionary alloc] initWithCapacity:10];
        _players = [[NSMutableArray alloc] initWithCapacity:10];
                
        // create default players.
        [self newPlayerWithName:@"White" preferredPieceColor:PieceColorWhite];
        [self newPlayerWithName:@"Black" preferredPieceColor:PieceColorBlack];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    
    if (self)
    {
        _matchOrder = [coder decodeObjectForKey:@"matchOrder"];
        _players = [coder decodeObjectForKey:@"players"];
        _matches = [coder decodeObjectForKey:@"matches"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.matchOrder forKey:@"matchOrder"];
    [encoder encodeObject:self.players forKey:@"players"];
    [encoder encodeObject:self.matches forKey:@"matches"];
}

- (Match *)setupDefaultMatch
{
    Match *match = [self createMatchFromKind:PlayerKindSelectionHumanVComputer difficulty:DifficultyEasy];
    return match;
}

- (Match *)createMatch:(NSString *)name
               players:(NSArray<Player *> *)players
{
    Match *match = [[Match alloc] initWithName:name players:players];
    
    if ([self.matches objectForKey:name] == nil)
    {
        [self.matchOrder addObject:name];
        self.matches[name] = match;
        return match;
    }
    return nil; // not able to create with that name.
}

- (Match *)matchWithName:(NSString *)name
                 players:(NSArray<Player *> *)players
{
    Match *match = nil;
    if (name == nil)
    {
        long count = self.matches.count;
        name = [NSString stringWithFormat:@"Unnamed Game %ld", (long)count];
        match = [self createMatch:name players:players];
    }
    else
    {
        match = [self createMatch:name players:players];
    }
    
    return match;
}

- (void)deleteMatch:(NSString *)name
{
    [self.matchOrder removeObject:name];
    [self.matches removeObjectForKey:name];
}

- (Player *)newPlayerWithName:(NSString *)name
          preferredPieceColor:(PieceColor)preferredPieceColor
{
    return [self newPlayerWithName:name
               preferredPieceColor:preferredPieceColor
                          strategy:nil];
}

- (Player *)newPlayerWithName:(NSString *)name
          preferredPieceColor:(PieceColor)preferredPieceColor
                     strategy:(Strategy *)strategy
{
    Player *player = [[Player alloc] initWithName:name];
    player.preferredPieceColor = preferredPieceColor;
    if ([self.players containsObject:player])
    {
        [self.players removeObject:player];
    }
    [self.players addObject:player];
    player.strategy = strategy;
    return player;
}

- (void)deletePlayer:(Player *)player
{
    [self.players removeObject:player];
}

- (void)setEngine:(id <Engine>) engine match:(Match *)match
{
    _engine = engine;
    
    for (Player *player in self.players)
    {
        Strategy *strategy = player.strategy;
        player.strategy.engine = engine;
        strategy.match = match;
    }
}

// don't think it should penalize for using a switch.
// codebeat:disable[ABC, LOC]
- (Match *)pickStrategyKind:(PlayerKindSelection)kind
                 difficulty:(Difficulty)difficulty
                    players:(NSArray<Player *> *)players
{
    Strategy *strategy1; Strategy *strategy2;
    id<Engine>engine = [[FothelloGame sharedInstance] engine];
    
    // black goes first.
    switch (kind)
    {
        case PlayerKindSelectionHumanVHuman:
            strategy1 = [[HumanStrategy alloc] initWithEngine:engine];
            strategy2 = [[HumanStrategy alloc] initWithEngine:engine];
            break;
        case PlayerKindSelectionHumanVComputer:
            strategy1 = [[HumanStrategy alloc] initWithEngine:engine];
            strategy2 = [[AIStrategy alloc] initWithDifficulty:difficulty engine:engine];
            break;
        case PlayerKindSelectionComputerVHuman:
            strategy1 = [[AIStrategy alloc] initWithDifficulty:difficulty engine:engine];
            strategy2 = [[HumanStrategy alloc] initWithEngine:engine];
            break;
        case PlayerKindSelectionComputerVComputer:
            strategy1 = [[AIStrategy alloc] initWithDifficulty:difficulty engine:engine];
            strategy2 = [[AIStrategy alloc] initWithDifficulty:difficulty engine:engine];
            break;
        case PlayerKindSelectionHumanVGameCenter:
            NSAssert(false, @"not implemented");
            break;
        default:
            NSAssert(false, @"cant find kind");
    }
    
    players[0].strategy = strategy1; players[1].strategy = strategy2;
    return [[Match alloc] initWithName:@"game" players:players];
}
// codebeat:enable[ABC, LOC]

- (Match *)createMatchFromKind:(PlayerKindSelection)kind difficulty:(Difficulty)difficulty
{
    Player *player1 = [self newPlayerWithName:@"Black" preferredPieceColor:PieceColorBlack];
    Player *player2 = [self newPlayerWithName:@"White" preferredPieceColor:PieceColorWhite];
    Match *match = [self pickStrategyKind:kind difficulty:difficulty players:@[player1, player2]];
    
    [self setEngine:self.engine match:match];
    [match reset];
    return match;
}

@end
