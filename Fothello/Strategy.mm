//
//  AIStrategy.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/18/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "FothelloGame.h"
#import "board.hpp"
#import "Match.h"
#import "Player.h"
#import "GameBoard.h"
#import "NetworkController.h"
#import "FothelloNetworkRequest.h"
#import "Strategy.h"
#import "PlayerMove.h"
#import "BoardPosition.h"
#import "Piece.h"

#import "json.hpp"

using json = nlohmann::json;

// This shows the json format of the data to send to the calc engine.
std::string testString(
                       "\"{"
                       "\"board\":"
                       "\"----------\\n"
                       "|........|\\n"
                       "|........|\\n"
                       "|........|\\n"
                       "|..XXX...|\\n"
                       "|...XO...|\\n"
                       "|........|\\n"
                       "|........|\\n"
                       "|........|\\n"
                       "----------\\n\","
                       "\"color\": 2,"
                       "\"difficulty\": 1,"
                       "\"moveNum\": 2"
                       "}");

#pragma mark - Strategy -

@interface Strategy ()
@property (nonatomic) NetworkController *network;
@end

@implementation Strategy

@synthesize network = _network;

// Not done and not used yet.
- (id)init
{
    self = [super init];
    if (self)
    {
        _network = [[NetworkController alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        _match = [coder decodeObjectForKey:@"match"];
        _network = [[NetworkController alloc] init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.match forKey:@"match"];
}

- (void)takeTurn:(Player *)player
{
    // subclass
}

- (void)takeTurn:(Player *)player atPosition:(BoardPosition *)position
{
    // subclass
}

- (void)beginTurn:(Player *)player
{
    // subclass
}

- (void)endTurn:(Player *)player
{
    // subclass
}

- (PlayerMove *)calculateMoveForPlayer:(Player *)player difficulty:(Difficulty)difficulty
{
    Board *board = makeBoard();
    int moveNum = (int)self.match.board.piecesPlayed.count;
    char playerColor = player.color == PieceColorBlack ? BLACK : WHITE;
    
    NSString *boardStr = [self.match.board requestFormat];
    std::string boardResult = [boardStr cStringUsingEncoding:NSASCIIStringEncoding];
    bool result = setBoardFromString(board, boardResult);
    NSAssert(result, @"failetoconvert");
    if (!result)
    {
        return nil;
    }
    json j;
    j["difficulty"] = (int)difficulty;
    j["moveNum"] = moveNum;
    j["board"] = boardResult;
    j["color"] = (int)playerColor;
    std::string s = j.dump(4);
//    printf("%s", s.c_str());
   
    __block json r;
    __block NSError *respError = nil;

    bool network = false;
    if (network)
    {
        NSCondition *condition = [[NSCondition alloc] init];
        NSData *data = [[NSString stringWithCString:s.c_str()
                                           encoding:[NSString defaultCStringEncoding]
                         ] dataUsingEncoding:NSUTF8StringEncoding ];
        
        __block NSString *respString = nil;
        FothelloNetworkRequest *request = [[FothelloNetworkRequest alloc] initWithQuery:nil];
        [self.network sendRequest:request sendData:data completion:
         ^(NSData *receiveData, NSError *error)
         {
             if (error != nil)
             {
                 NSLog(@"Error %@", error);
                 respError = error;
             }
             else
             {
                 respString = [[NSString alloc] initWithData:receiveData encoding:NSUTF8StringEncoding];
                 r = json::parse([respString cStringUsingEncoding:NSASCIIStringEncoding]);
             }
             [condition signal];
             [condition unlock];
         }];
        [condition lock];
        [condition wait];
        
        NSLog(@"Netrequest Complete");
    }

    if (respError != nil || !network)
    {
        FothelloGame *game = [FothelloGame sharedInstance];
        NSInteger randValue = [game.randomSource nextInt];
        // error or network disabled, do processing locally.
        std::string jsonResp = getMoveFromJSON(j.dump(4), randValue);
        r = json::parse(jsonResp);
    }
    
    if (r["pass"].get<bool>())
    {
        return [PlayerMove makePassMoveForColor:player.color];
    }
    
    NSInteger ay = r["movey"].get<int>();
    NSInteger ax = r["movex"].get<int>();
    
    BoardPosition *boardPosition = [BoardPosition positionWithX:ax y:ay];
    return [PlayerMove makeMoveForColor:player.color position:boardPosition];
}

- (void)hintForPlayer:(Player *)player
{
    // subclass
}

- (void)makeMoveForPlayer:(Player *)player
{
    // subclass
}

- (void)makeMove:(PlayerMove *)move forPlayer:(Player *)player
{
    // uses highlight block.
    [self.match.board showClickedMove:move forPlayer:player];
}

@end




