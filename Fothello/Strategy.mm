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

- (NSArray <BoardPiece *> *)takeTurn:(Player *)player
{
    // subclass
    return nil;
}

- (NSArray <BoardPiece *> *)takeTurn:(Player *)player atX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass
{
    // subclass
    return nil;
}

- (NSArray <BoardPiece *> *)legalMoves:(BOOL)display forPlayer:(Player *)player
{    
    Match *match = self.match;
    GameBoard *board = match.board;
    
    NSMutableArray<BoardPiece *>*pieces = [[NSMutableArray alloc] initWithCapacity:10];
    
    if (display)
    {
        __block BOOL foundLegal = NO;
        
        // Determine moves
        [board visitAll:^(NSInteger x, NSInteger y, Piece *piece)
         {
             BoardPosition *boardPosition = [BoardPosition positionWithX:x y:y];
             PlayerMove *move = [PlayerMove makeMoveWithPiece:piece position:boardPosition];
             BOOL foundMove = [match.board findTracksForMove:move
                                                   forPlayer:player
                                                  trackBlock:nil];
             if (foundMove)
             {
                 Piece *piece = [board pieceAtPositionX:x Y:y];
                 PieceColor color = display ? PieceColorLegal : PieceColorNone;
                 if (piece.color != color)
                 {
                     [pieces addObject:[BoardPiece makeBoardPieceWithPiece:piece position:boardPosition color:color]];
                 }
                 foundLegal = YES;
             }
         }];
        return foundLegal ? [pieces copy] : nil;
    }
    else
    {
        [board visitAll:^(NSInteger x, NSInteger y, Piece *piece)
         {
             if (piece.color == PieceColorLegal)
             {
                 BoardPosition *boardPosition = [BoardPosition positionWithX:x y:y];
                 [pieces addObject:[BoardPiece makeBoardPieceWithPiece:piece position:boardPosition color:PieceColorNone]];
             }
         }];
        return [pieces copy];
    }
}


- (PlayerMove *)calculateMoveForPlayer:(Player *)player
{
    Board *board = makeBoard();
    int moveNum = (int)self.match.board.piecesPlayed.count;
    char playerColor = player.color == PieceColorBlack ? BLACK : WHITE;
    
    NSString *boardStr = [self.match.board toStringAscii];
    std::string boardResult = [boardStr cStringUsingEncoding:NSASCIIStringEncoding];
    bool result = setBoardFromString(board, boardResult);
    NSAssert(result == true, @"failetoconvert");
    if (result == false)
    {
        return nil;
    }
    json j;
    j["difficulty"] = (int)_difficulty;
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
        // error or network disabled, do processing locally.
        std::string jsonResp = getMoveFromJSON(j.dump(4));
        r = json::parse(jsonResp);
    }
    
    
    if (r["pass"].get<bool>())
    {
        [self.match pass];
        Piece *piece = [[Piece alloc] initWithColor:player.color];
        BoardPosition *boardPosition = [BoardPosition positionWithPass];
        return [PlayerMove makeMoveWithPiece:piece position:boardPosition];
    }
    
    NSInteger ay = r["movey"].get<int>();
    NSInteger ax = r["movex"].get<int>();
    
    BoardPosition *boardPosition = [BoardPosition positionWithX:ax y:ay];
    Piece *piece = [[Piece alloc] initWithColor:player.color];
    return [PlayerMove makeMoveWithPiece:piece position:boardPosition];
}

- (void)hintForPlayer:(Player *)player
{
    // subclass 
}

@end

#pragma mark - HumanStategy -

@implementation HumanStrategy

- (BOOL)manual
{
    return YES;
}

- (NSArray <BoardPiece *> *)takeTurn:(Player *)player atX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass
{
    [super takeTurn:player atX:x Y:y pass:pass];
  
    Match *match = self.match;
    
    Piece *piece = [[Piece alloc] initWithColor:player.color];
    BoardPosition *boardPosition = [BoardPosition positionWithX:x y:y];
    PlayerMove *move = [PlayerMove makeMoveWithPiece:piece position:boardPosition];
    
    return [match placeMove:move forPlayer:player];
}

- (void)hintForPlayer:(Player *)player
{
    PlayerMove *move = [self calculateMoveForPlayer:player];
    [self.match showHintMove:move forPlayer:player];
}
@end


#pragma mark - AIStrategy -

@interface AIStrategy ()
@end

@implementation AIStrategy

- (BOOL)manual
{
    return NO;
}

- (id)initWithMatch:(Match *)match
{
    self = [super initWithMatch:match];
    if (self)
    {
        self.difficulty = DifficultyEasy;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.difficulty = (Difficulty)[aDecoder decodeIntegerForKey:@"difficulty"];
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
    PlayerMove *move = [self calculateMoveForPlayer:player];

    Match *match = self.match;
    return [match placeMove:move forPlayer:player];
}


@end


