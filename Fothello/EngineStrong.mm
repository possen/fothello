//
//  Engine.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 2/18/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//
// Calculates move on current device or offloads it to Webservice.
// 

#import <GameplayKit/GameplayKit.h>
#import "Engine.h"
#import "BoardPiece.h"
#import "NetworkController.h"
#import "FothelloNetworkRequest.h"
#import "FothelloGame.h"
#import "Match.h"
#import "Player.h"
#import "GameBoard.h"
#import "board.hpp"
#import "json.hpp"
#import "EngineStrong.h"

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


@implementation EngineStrong

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _network = [[NetworkController alloc] init];
        _randomSource = [[GKARC4RandomSource alloc] init];
    }
    return self;
}

- (json)calculateRemotely:(std::string)query
{
    __block json r;

    NSCondition *condition = [[NSCondition alloc] init];
    NSData *data = [[NSString stringWithCString:query.c_str()
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
             r["error"] = error.description;
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
    return r;
}

- (void)seed:(NSString *)seed
{
    self.randomSource = [[GKARC4RandomSource alloc] initWithSeed:[seed dataUsingEncoding:NSASCIIStringEncoding]];
}

- (NSDictionary *)calculateMoveForPlayer:(PieceColor)playerColor match:(Match *)match difficulty:(Difficulty)difficulty
{
    int moveNum = (int)match.board.piecesPlayed.count;
    NSString *boardStr = [match.board requestFormat];
    return [self calculateMoveWithBoard:boardStr playerColor:playerColor moveNumber:moveNum diffculty:difficulty];
}


- (NSDictionary *)calculateMoveWithBoard:(NSString *)boardStr
                             playerColor:(PieceColor)playerColor
                              moveNumber:(NSInteger)moveNumber
                               diffculty:(Difficulty)difficulty
{
    char color = playerColor == PieceColorBlack ? BLACK : WHITE;
    Board *board = makeBoard();
    std::string boardData = [boardStr cStringUsingEncoding:NSASCIIStringEncoding];

    bool result = setBoardFromString(board, boardData);
    NSAssert(result, @"failetoconvert");
    if (!result)
    {
        return nil;
    }
    json j;
    j["difficulty"] = (int)difficulty;
    j["moveNum"] = (int)moveNumber;
    j["board"] = boardData;
    j["color"] = (int)color;
    std::string s = j.dump(4);
    //    printf("%s", s.c_str());
    
    __block json r;
    __block NSError *respError = nil;
    
    bool network = false;
    if (network)
    {
        [self calculateRemotely:s];
    }
    
    // error or network disabled, do processing locally.
    if (respError != nil || !network)
    {
        NSInteger randValue = [self.randomSource nextInt];
        std::string jsonResp = getMoveFromJSON(j.dump(4), randValue);
        r = json::parse(jsonResp);
        NSLog(@"%s", jsonResp.c_str());
        
    }
    
    NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
    bool pass = r["pass"].get<bool>();
    response[@"pass"] = @(pass);
    if (!pass)
    {
        response[@"movex"] = @(r["movex"].get<int>());
        response[@"movey"] = @(r["movey"].get<int>());
    }
    return response;
}

@end
