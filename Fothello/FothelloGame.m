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
#import "HumanStrategy.h"

#pragma mark - FothelloGame -

@implementation FothelloGame

+ (id)sharedInstance
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
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL exists = [fileManager fileExistsAtPath:filename];
    if (!exists)
    {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:filename withIntermediateDirectories:NO attributes:nil error:&error];
        if (error != nil)
        {
            NSLog(@"error %@", error);
        }
    }
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
        [self newPlayerWithName:@"Player 1" preferredPieceColor:PieceColorWhite];
        [self newPlayerWithName:@"Player 2" preferredPieceColor:PieceColorBlack];
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

- (void)setupDefaultMatch:(id<Engine>)engine
{
    Match *match = [self matchWithName:nil players:self.players];
    match.players[0].strategy = [[HumanStrategy alloc] initWithEngine:engine];
    match.players[1].strategy = [[AIStrategy alloc] initWithDifficulty:DifficultyEasy engine:engine];
    match.players[0].strategy.match = match;
    match.players[1].strategy.match = match;
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
    player.preferredPieceColor  = preferredPieceColor;
    [self.players addObject:player];
    player.strategy = strategy;
    return player;
}


- (void)deletePlayer:(Player *)player
{
    [self.players removeObject:player];
}

- (void)setEngine:(id <Engine>) engine
{
    _engine = engine;
    for (Player *player in self.players)
    {
        player.strategy.engine = engine;
    }
}

- (Match *)createMatchFromKind:(PlayerKindSelection)kind difficulty:(Difficulty)difficulty
{
    id<Engine>engine = [[FothelloGame sharedInstance] engine];
    Player *player1 = [self newPlayerWithName:@"Black" preferredPieceColor:PieceColorBlack];
    Player *player2 = [self newPlayerWithName:@"White" preferredPieceColor:PieceColorWhite];

    // black goes first.
    switch (kind)
    {
        case PlayerKindSelectionHumanVHuman:
            player1.strategy = [[HumanStrategy alloc] initWithEngine:engine];
            player2.strategy = [[HumanStrategy alloc] initWithEngine:engine];
            break;
        case PlayerKindSelectionHumanVComputer:
            player1.strategy = [[HumanStrategy alloc] initWithEngine:engine];
            player2.strategy = [[AIStrategy alloc] initWithDifficulty:difficulty engine:engine];
            break;
        case PlayerKindSelectionComputerVHuman:
            player1.strategy = [[AIStrategy alloc] initWithDifficulty:difficulty engine:engine];
            player2.strategy = [[HumanStrategy alloc] initWithEngine:engine];
            break;
        case PlayerKindSelectionComputerVComputer:
            player1.strategy = [[AIStrategy alloc] initWithDifficulty:difficulty engine:engine];
            player2.strategy = [[AIStrategy alloc] initWithDifficulty:difficulty engine:engine];
            break;
        case PlayerKindSelectionHumanVGameCenter:
            NSAssert(false, @"not implemented");
            break;
        default:
            NSAssert(false, @"cant find kind");
    }
    
    if (player1 == nil || player2 == nil)
    {
        return nil;
    }
    
    Match *match = [[Match alloc] initWithName:@"game" players:@[player2, player1]];
    for (Player *player in self.players)
    {
        player.strategy.engine = self.engine;
        player.strategy.match = match;
    }
    [match reset];
    return match;
}

@end
