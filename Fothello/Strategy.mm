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

#import "json.hpp"

using json = nlohmann::json;

#pragma mark - Strategy -

@interface Strategy ()
@property (nonatomic) Difficulty difficulty;
@property (nonatomic) NetworkController *network;
@end

@implementation Strategy

@synthesize difficulty = _difficulty;
@synthesize network = _network;

// Not done and not used yet.
- (id)initWithMatch:(Match *)match
{
    self = [super init];
    if (self)
    {
        _match = match;
        _difficulty = match.difficulty;
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
        _difficulty = (Difficulty)[coder decodeIntForKey:@"difficulty"];
        _network = [[NetworkController alloc] init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.match forKey:@"match"];
    [aCoder encodeInt:self.difficulty forKey:@"difficulty"];

}

- (BOOL)takeTurn:(Player *)player atX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass
{
    // subclass
    return NO;
}

- (BOOL)otherPlayer:(Player *)player movedToX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass
{
    // subclass
    return YES;
}


- (void)convertBoard
{
    // subclass
}

- (BOOL)displaylegalMoves:(BOOL)display forPlayer:(Player *)player
{
    Match *match = self.match;
    GameBoard *board = match.board;
    __block BOOL foundLegal = NO;
    
    NSMutableArray<PlayerMove *>*moves = [[NSMutableArray alloc] initWithCapacity:10];
    if (display)
    {
        // Determine moves
        [board visitAll:^(NSInteger x, NSInteger y, Piece *piece)
         {
             BOOL foundMove = [match findTracksX:x Y:y
                                       forPlayer:player
                                      trackBlock:nil];
             if (foundMove)
             {
                 Piece *piece = [board pieceAtPositionX:x Y:y];
                 PieceColor color = display ? PieceColorLegal : PieceColorNone;
                 if (piece.color != color)
                 {
                     [board changePiece:piece withColor:color];
                     
                     if (self.manual)
                     {
                         [moves addObject:[PlayerMove makePiecePositionX:x Y:y piece:piece pass:NO]];
                     }
                 }
                 foundLegal = YES;
             }
         }];
    }
    else
    {
        [board visitAll:^(NSInteger x, NSInteger y, Piece *piece)
         {
             if (piece.color == PieceColorLegal)
             {
                 [board changePiece:piece withColor:PieceColorNone];
                 [moves addObject:[PlayerMove makePiecePositionX:x Y:y piece:piece pass:NO]];
             }
         }];
    }
    
    board.placeBlock(moves);
    
    return foundLegal;
}

- (void)resetWithDifficulty:(Difficulty)difficulty
{
    // subclass
}

- (void)pass
{
    // subclass
}


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

- (Move *)calculateMoveForPlayer:(Player *)player
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
    std::string s = j.dump(4);
    printf("%s", s.c_str());
    
    __block NSError *respError = nil;
    __block json r;
#define NETWORK
#ifdef NETWORK
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
    if (respError != nil)
#endif
    {
        std::string jsonResp = getMoveFromJSON(j.dump(4));
        r = json::parse(jsonResp);
    }
    
    if (r["pass"].get<bool>())
    {
        [self.match pass];
        return [Move positionWithPass];
    }
    
    NSInteger ay = r["movey"].get<int>();
    NSInteger ax = r["movex"].get<int>();
    
    Move *point = [[Move alloc] init];
    point.x = ax;
    point.y = ay;
    
    return [Move positionWithX:ax y:ay pass:NO];
}


@end

#pragma mark - HumanStategy -

@implementation HumanStrategy

- (BOOL)manual
{
    return YES;
}

- (BOOL)takeTurn:(Player *)player atX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass
{
    [super takeTurn:player atX:x Y:y pass:pass];
    
    Move *position = [Move positionWithX:x y:y pass:pass];
    
    Match *match = self.match;
    
    BOOL placed = [match placePieceForPlayer:player position:position];
    return placed;
}

- (BOOL)hintForPlayer:(Player *)player
{
    Move *position = [self calculateMoveForPlayer:player];
    
    return [self.match showHintForPlayer:player position:position];
}
@end


#pragma mark - AIStrategy -

@interface AIStrategy ()
@end

@implementation AIStrategy

- (id)initWithMatch:(Match *)match
{
    self = [super initWithMatch:match];
    if (self)
    {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeInteger:self.difficulty forKey:@"difficulty"];
}


- (BOOL)takeTurn:(Player *)player atX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass
{
    Move *position = [self calculateMoveForPlayer:player];

    Match *match = self.match;
    return [match placePieceForPlayer:player position:position];
}

@end


