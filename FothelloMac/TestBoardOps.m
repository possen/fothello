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
#import "MatchViewControllerMac.h"
#import "MatchWindowController.h"
#import "Match.h"

@interface TestBoardOps : XCTestCase
@property (nonatomic) Match *match;
@property (nonatomic) GameBoard *board;
@end

@implementation TestBoardOps

- (void)setUp
{
    [super setUp];
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    
    MatchViewControllerMac *vc = [storyboard instantiateControllerWithIdentifier:@"MatchViewController"];
    self.match = vc.match;
    self.board = self.match.board;
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testBoardPlace
{
    GameBoard *board = self.board;

    [board updateBoardWithFunction:^NSArray<BoardPiece *> *
     {
         NSMutableArray<BoardPiece *> *pieces = [[NSMutableArray alloc] initWithCapacity:10];
         BoardPosition *center = board.center;
         
         [board boxCoord:4 block:
          ^(BoardPosition *position, BOOL isCorner, NSInteger count, BOOL *stop)
          {
              NSInteger x = center.x + position.x; NSInteger y = center.y + position.y;
              
              Piece *piece = [board pieceAtPositionX:x Y:y];
              piece.color = PieceColorWhite;
              BoardPosition *pos = [[BoardPosition alloc] initWithX:x Y:y];
              [pieces addObject:[BoardPiece makeBoardPieceWithPiece:piece position:pos]];
          }];
         return [pieces copy];
     }];
}


@end
