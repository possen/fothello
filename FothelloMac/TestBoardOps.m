//
//  TestBoardOps.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/15/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <FothelloLib/FothelloLib.h>

#import "NSArray+Extensions.h"

@interface TestBoardOps : XCTestCase
@property (nonatomic) Match *match;
@property (nonatomic) GameBoard *board;
@property (nonatomic) dispatch_queue_t queue;
@end

@implementation TestBoardOps

- (void)setUp
{
    [super setUp];
    
    self.queue = dispatch_queue_create("match update queue", DISPATCH_QUEUE_SERIAL);
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testBoardPlace
{
    GameBoard *board = [[GameBoard alloc] initWithBoardSize:8];
    XCTestExpectation *expectation =  [self expectationWithDescription:@"testBoardPlace"];

    [board updateBoard:^NSArray<NSArray<BoardPiece *> *> *
     {
         NSMutableArray<BoardPiece *> *pieces = [[NSMutableArray alloc] initWithCapacity:10];
         BoardPosition *center = board.center;
         [board boxCoord:4 block:^(BoardPosition *position, BOOL isCorner, NSInteger count, BOOL *stop)
          {
              NSInteger x = center.x + position.x;
              NSInteger y = center.y + position.y;
              Piece *piece = [board pieceAtPositionX:x Y:y];
         
              BoardPosition *pos = [[BoardPosition alloc] initWithX:x Y:y];
              [pieces addObject:[BoardPiece makeBoardPieceWithPiece:piece position:pos color:PieceColorWhite]];
          }];
         
         [expectation fulfill];
         return @[pieces];
     }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error)
     {
         XCTAssert(error == nil, @"error");
    }];
    
    [board updateBoard:^NSArray<NSArray<BoardPiece *> *> *
     {
         Piece *peice1 = [board pieceAtPositionX:0 Y:0];
         XCTAssertEqualObjects(peice1.description, @"○");
         Piece *peice2 = [board pieceAtPositionX:7 Y:7];
         XCTAssertEqualObjects(peice2.description, @"○");
         Piece *peice3 = [board pieceAtPositionX:3 Y:3];
         XCTAssertEqualObjects(peice3.description, @".");
         return nil;
     }];
}

- (void)testFindOps
{
    GameBoard *board = [[GameBoard alloc] initWithBoardSize:8];
    XCTestExpectation *expectation =  [self expectationWithDescription:@"testCanMove"];
    
    [board updateBoard:^NSArray<NSArray<BoardPiece *> *> *
    {
        NSMutableArray<BoardPiece *> *pieces = [[NSMutableArray alloc] initWithCapacity:10];
        
        Piece *piece1 = [board pieceAtPositionX:3 Y:3];
        BoardPosition *pos1 = [[BoardPosition alloc] initWithX:3 Y:3];
        [pieces addObject:[BoardPiece makeBoardPieceWithPiece:piece1 position:pos1 color:PieceColorWhite]];

        Piece *piece2 = [board pieceAtPositionX:4 Y:3];
        BoardPosition *pos2 = [[BoardPosition alloc] initWithX:4 Y:3];
        [pieces addObject:[BoardPiece makeBoardPieceWithPiece:piece2 position:pos2 color:PieceColorBlack]];
        
        [expectation fulfill];
        return @[pieces];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error)
     {
         XCTAssert(error == nil, @"error");
     }];
    
    expectation = [self expectationWithDescription:@"testPlace"];

    [board updateBoard:^NSArray<NSArray<BoardPiece *> *> *
     {
         Player *player = [[Player alloc] initWithName:@"testPlayer"];
         player.color = PieceColorWhite;
         XCTAssertTrue([board canMove:player]);
         
         NSMutableArray<BoardPiece *> *pieces = [[NSMutableArray alloc] initWithCapacity:10];
         
         Piece *piece1 = [board pieceAtPositionX:5 Y:3];
         BoardPosition *pos1 = [[BoardPosition alloc] initWithX:5 Y:3];
         [pieces addObject:[BoardPiece makeBoardPieceWithPiece:piece1 position:pos1 color:PieceColorWhite]];
         
         PlayerMove *move = [PlayerMove makeMoveForColor:PieceColorWhite position:pos1];
         NSArray<NSArray<BoardPiece *> *> *piecesLists = [board placeMove:move forPlayer:player];
         [pieces addObjectsFromArray:[piecesLists flatten]];
         
         [expectation fulfill];
         return @[pieces];
     }];
 
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error)
     {
         XCTAssert(error == nil, @"error");
     }];
  
    [board updateBoard:^NSArray<NSArray<BoardPiece *> *> *
    {
        Piece *peice1 = [board pieceAtPositionX:3 Y:3];
        XCTAssertEqualObjects(peice1.description, @"○");
        Piece *peice2 = [board pieceAtPositionX:4 Y:3];
        XCTAssertEqualObjects(peice2.description, @"○");
        Piece *peice3 = [board pieceAtPositionX:5 Y:3];
        XCTAssertEqualObjects(peice3.description, @"○");
        return nil;
    }];
}

- (void)testSetupComputerVsComputerGame
{
    FothelloGame *game = [FothelloGame sharedInstance];
    self.match = [game createMatchFromKind:PlayerKindSelectionComputerVComputer difficulty:DifficultyEasy];
    [self.match reset]; // clear the board only.
    [self.match restart];
    NSLog(@"match description %@", [self.match description]);
    
    XCTAssertEqual([self.match areAllPlayersComputers], true);
    
    __block BOOL gameFinished = NO;
    self.match.matchStatusBlock = ^(BOOL gameOver)
    {
        gameFinished = gameOver;
    };

    //__weak TestBoardOps *weakSelf = self;
    self.match.currentPlayerBlock = ^(Player *player, BOOL canMove)
    {
    };

    while (!gameFinished)
    {
        [self.match.currentPlayer takeTurn];
    }
}

- (void)testReset
{
    GameBoard *board = [[GameBoard alloc] initWithBoardSize:8];
    [board reset];
    [board reset];
    [board reset];
    [board reset];
}



@end
