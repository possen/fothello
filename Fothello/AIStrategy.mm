//
//  AIStrategy.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/18/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "AIStrategy.h"
#import "FothelloGame.h"
#import "board.hpp"
#import "Match.h"
#import "Player.h"
#import "GameBoard.h"
#import "NetworkController.h"
#import "FothelloNetworkRequest.h"

#import "json.hpp"

using json = nlohmann::json;

#pragma mark - AIStrategy -

@interface AIStrategy ()
@property (nonatomic) Difficulty difficulty;
@property (nonatomic) NetworkController *network;
@end

@implementation AIStrategy
@synthesize difficulty = _difficulty;
@synthesize network = _network;

- (id)initWithMatch:(Match *)match
{
    self = [super initWithMatch:match];
    if (self)
    {
        _difficulty = match.difficulty;
        _network = [[NetworkController alloc] init];
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



- (BOOL)takeTurn:(Player *)player atX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass
{
    Board *board = makeBoard();
    int moveNum = (int)self.match.board.piecesPlayed.count;
    char playerColor = player.color == PieceColorBlack ? BLACK : WHITE;
    
    NSString *boardStr = [self.match.board toStringAscii];
    std::string boardResult = [boardStr cStringUsingEncoding:NSASCIIStringEncoding];
    bool result = setBoardFromString(board, boardResult);
    NSAssert(result == true, @"failetoconvert");
    
    json j;
    j["difficulty"] = (int)_difficulty;
    j["moveNum"] = moveNum;
    j["board"] = boardResult;
    j["color"] = (int)playerColor;
    std::string s = j.dump(4);    // {\"happy\":true,\"pi\":3.141}
    printf("%s", s.c_str());

    NSData *data = [[NSString stringWithCString:s.c_str()
                                       encoding:[NSString defaultCStringEncoding]
                     ] dataUsingEncoding:NSUTF8StringEncoding ];
    
    NSCondition *condition = [[NSCondition alloc] init];
    
    __block NSString *respString = nil;
    __block NSError *respError = nil;
    __block json r;
    
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
    
    if (respError != nil)
    {
        std::string jsonResp = getMoveFromJSON(j.dump(4));
        r = json::parse(jsonResp);
    }
    
    if (r["pass"].get<bool>() == true) {
        FothelloGame *game = [FothelloGame sharedInstance];
        [game pass];
        return NO;
    }
    NSInteger ay = r["movey"].get<int>();
    NSInteger ax = r["movex"].get<int>();
    
    printf("placed %ld %ld\n", (long)ax, (long)ay);
    
    Match *match = self.match;
    return [match placePieceForPlayer:player atX:ax Y:ay];
}

@end


