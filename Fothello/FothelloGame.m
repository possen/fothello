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
        _matches = [[NSMutableDictionary alloc] initWithCapacity:10];
        _players = [[NSMutableArray alloc] initWithCapacity:10];
        
        // create default players.
        [self newPlayerWithName:@"Player 1" preferredPieceColor:PieceColorBlack];
        [self newPlayerWithName:@"Player 2" preferredPieceColor:PieceColorWhite];
  
        [self matchWithDifficulty:DifficultyEasy
                 firstPlayerColor:PieceColorBlack
                     opponentType:PlayerTypeComputer];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    
    if (self)
    {
        _players = [coder decodeObjectForKey:@"players"];
        _matches = [coder decodeObjectForKey:@"matches"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.players forKey:@"players"];
    [encoder encodeObject:self.matches  forKey:@"matches"];
}

- (Match *)createMatch:(NSString *)name
               players:(NSArray<Player *> *)players
            difficulty:(Difficulty)difficulty
{
    Match *match = [[Match alloc] initWithName:name players:players difficulty:difficulty];
    
    if ([self.matches objectForKey:name] == nil)
    {
        self.matches[name] = match;
        return match;
    }
    return nil; // not able to create with that name.
}

- (Match *)matchWithDifficulty:(Difficulty)difficulty
              firstPlayerColor:(PieceColor)pieceColor
                  opponentType:(PlayerType)opposingPlayerType
{
    Player *player1 = self.players[0];
    Player *player2 = self.players[1];
    
    NSArray<Player *> *players = @[player1, player2];
    Match *match = [self matchWithName:nil players:players difficulty:difficulty];

    if (opposingPlayerType == PlayerTypeComputer)
    {
        if (pieceColor == PieceColorBlack)
        {
            player1.strategy = [[HumanStrategy alloc] initWithMatch:match];
            player2.strategy = [[AIStrategy alloc] initWithMatch:match];
        }
        else
        {
            // need to make computer do first move.
            player1.strategy = [[AIStrategy alloc] initWithMatch:match];
            player2.strategy = [[HumanStrategy alloc] initWithMatch:match];
        }
    }
    else
    {
        player1.strategy = [[HumanStrategy alloc] initWithMatch:match];
        player2.strategy = [[HumanStrategy alloc] initWithMatch:match];
    }
    
    return match;
}

- (Match *)matchWithName:(NSString *)name
                 players:(NSArray<Player *> *)players
              difficulty:(Difficulty)difficulty
{
    Match *match = nil;
    if (name == nil)
    {
        long count = self.matches.count;
        name = [NSString stringWithFormat:@"Unnamed Game %ld", (long)count];
        match = [self createMatch:name players:players difficulty:difficulty];
    }
    else
    {
        match = [self createMatch:name players:players difficulty:difficulty];
    }
    
    return match;
}

- (void)deleteMatch:(NSString *)name
{
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

@end






