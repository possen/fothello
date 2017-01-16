//
//  TestBoardOps.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/15/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BoardScene.h"
#import "GameBoard.h"
#import "Match.h"
#import "Piece.h"
#import "BoardPosition.h"
#import "BoardPiece.h"

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

    [board updateBoardWithFunction:^NSArray<NSArray<BoardPiece *> *> *
     {
         NSMutableArray<BoardPiece *> *pieces = [[NSMutableArray alloc] initWithCapacity:10];
         BoardPosition *center = board.center;
         
         [board boxCoord:4 block:^(BoardPosition *position, BOOL isCorner, NSInteger count, BOOL *stop)
          {
              NSInteger x = center.x + position.x; NSInteger y = center.y + position.y;
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
         
         
//         NSString *boardString = board.description;
//         NSString *start = [boardString substringToIndex:18];
//         NSString *end = [boardString substringFromIndex:89];
         
//         XCTAssert([start isEqualToString:@"\n----------\n|○○○○○"], @"boards");
//         XCTAssert([end isEqualToString:@"|○○○○○○○○|\n----------\n{\n    2 = 28;\n}"], @"boards");
    }];
}

- (void)testFindOps {
    
}

@end
