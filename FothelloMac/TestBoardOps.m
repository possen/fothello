//
//  TestBoardOps.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/15/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <FothelloLib/FothelloLib.h>

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
         XCTAssertEqualObjects(peice3.description, @"·");
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
    Player *player = [[Player alloc] initWithName:@"testPlayer"];
    player.color = PieceColorWhite;

    [board updateBoard:^NSArray<NSArray<BoardPiece *> *> *
     {         
         NSMutableArray<BoardPiece *> *pieces = [[NSMutableArray alloc] initWithCapacity:10];
         
         Piece *piece1 = [board pieceAtPositionX:5 Y:3];
         BoardPosition *pos1 = [[BoardPosition alloc] initWithX:5 Y:3];
         [pieces addObject:[BoardPiece makeBoardPieceWithPiece:piece1 position:pos1 color:PieceColorWhite]];
         
         PlayerMove *move = [PlayerMove makeMoveForColor:PieceColorWhite position:pos1];
         [board placeMove:move forPlayer:player];
         
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
        XCTAssertEqualObjects(peice2.description, @"●");
        Piece *peice3 = [board pieceAtPositionX:5 Y:3];
        XCTAssertEqualObjects(peice3.description, @"○");
        
        NSInteger score = [board playerScoreUnqueued:player];
        XCTAssertEqual(score, 2);
        return nil;
    }];
}

- (void)playCvCGame
{
    FothelloGame *game = [FothelloGame sharedInstance];
    self.match = [game createMatchFromKind:PlayerKindSelectionComputerVComputer difficulty:DifficultyEasy];
    [self.match reset]; 
    [self.match beginMatch];
    NSLog(@"match description %@", [self.match description]);
    
    XCTAssertEqual([self.match areAllPlayersComputers], true);
    
    XCTestExpectation *expectation =  [self expectationWithDescription:@"testFinishGame"];
    
    __block BOOL gameFinished = NO;
    self.match.matchStatusBlock = ^(BOOL gameOver)
    {
        gameFinished = gameOver;
        [expectation fulfill];
    };
    
    __weak TestBoardOps *weakSelf = self;
    self.match.currentPlayerBlock = ^(Player *player, BOOL canMove)
    {
        if (!gameFinished)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.match nextPlayer];
                [weakSelf.match.currentPlayer takeTurn];
            });
        }
    };
    
    [self.match.currentPlayer takeTurn];
    
    [self waitForExpectationsWithTimeout:60.0 handler:^(NSError *error)
     {
         XCTAssert(error == nil, @"error");
     }];
}

- (void)testSetupComputerVsComputerGame1
{
    srand(1);
    [self playCvCGame];
}

- (void)testSetupComputerVsComputerGame2
{
    srand(2);
    [self playCvCGame];
}

- (void)testSetupComputerVsComputerGame3
{
    srand(3);
    [self playCvCGame];
}

- (void)testSetupComputerVsComputerGame4
{
    srand(4);
    [self playCvCGame];
}

- (void)testSetupComputerVsComputerGame5
{
    srand(5);
    [self playCvCGame];
}

- (void)doReset:(GameBoard *)board
{
    XCTestExpectation *expectation1 =  [self expectationWithDescription:@"testErase1"];
    board.placeBlock = ^(NSArray<NSArray <BoardPiece *> *> *pieceTracks)
    {
        [expectation1 fulfill];
    };
    [board reset];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testReset
{
    Player *player1 = [[Player alloc] init];
    player1.color = PieceColorWhite;
    Player *player2 = [[Player alloc] init];
    player2.color = PieceColorBlack;
    
    GameBoard *board = [[GameBoard alloc] initWithBoardSize:8];

    [self doReset:board];
    XCTAssertEqual(2, [board playerScore:player1]);
    XCTAssertEqual(2, [board playerScore:player2]);

    [self doReset:board];
    XCTAssertEqual(2, [board playerScore:player1]);
    XCTAssertEqual(2, [board playerScore:player2]);

    XCTestExpectation *expectationPlace =  [self expectationWithDescription:@"expectationPlace"];
    
    board.placeBlock = ^(NSArray<NSArray <BoardPiece *> *> *pieceTracks)
    {
        [expectationPlace fulfill];
    };

    [board updateBoard:^NSArray<NSArray<BoardPiece *> *> *
     {
         NSMutableArray<BoardPiece *> *pieces = [[NSMutableArray alloc] initWithCapacity:10];
         
         Piece *piece1 = [board pieceAtPositionX:6 Y:4];
         BoardPosition *pos1 = [[BoardPosition alloc] initWithX:3 Y:3];
         [pieces addObject:[BoardPiece makeBoardPieceWithPiece:piece1 position:pos1 color:PieceColorWhite]];
         
         Piece *piece2 = [board pieceAtPositionX:7 Y:2];
         BoardPosition *pos2 = [[BoardPosition alloc] initWithX:4 Y:3];
         [pieces addObject:[BoardPiece makeBoardPieceWithPiece:piece2 position:pos2 color:PieceColorBlack]];
  
         return @[pieces];
     }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * error) {
    }];
    
    XCTAssertEqual(3, [board playerScore:player1]);
    XCTAssertEqual(3, [board playerScore:player2]);

    [self doReset:board];
    XCTAssertEqual(2, [board playerScore:player1]);
    XCTAssertEqual(2, [board playerScore:player2]);

    [self doReset:board];
    XCTAssertEqual(2, [board playerScore:player1]);
    XCTAssertEqual(2, [board playerScore:player2]);
}

- (void)testBoardFull
{
    Player *player1 = [[Player alloc] init];
    player1.color = PieceColorWhite;
    Player *player2 = [[Player alloc] init];
    player2.color = PieceColorBlack;

    GameBoard *board = [[GameBoard alloc] initWithBoardSize:8];
    [self doReset:board];
    
    {
        BOOL full = [board isFull];
        XCTAssertFalse(full);
        BOOL canMove1 = [board canMove:player1];
        XCTAssertTrue(canMove1);
        BOOL canMove2 = [board canMove:player2];
        XCTAssertTrue(canMove2);
    }
    
    XCTestExpectation *expectation =  [self expectationWithDescription:@"boardFull"];
  
    board.placeBlock = ^(NSArray<NSArray <BoardPiece *> *> *pieceTracks)
    {
        [expectation fulfill];
    };

    [board updateBoard:^NSArray<NSArray<BoardPiece *> *> *
    {
        NSMutableArray<BoardPiece *> *pieces = [[NSMutableArray alloc] initWithCapacity:10];
        
        [board visitAllUnqueued:^(NSInteger x, NSInteger y, Piece *piece)
         {
             BoardPosition *pos = [[BoardPosition alloc] initWithX:x Y:y];
             [pieces addObject:
              [BoardPiece makeBoardPieceWithPiece:piece
                                         position:pos
                                            color:PieceColorBlack]];
         }];
        return @[pieces];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];

    {
        BOOL full = [board isFull];
        XCTAssertTrue(full);
        BOOL canMove1 = [board canMove:player1];
        XCTAssertFalse(canMove1);
        BOOL canMove2 = [board canMove:player2];
        XCTAssertFalse(canMove2);
    }
}

- (void)testShowLegalMoves
{
    Player *player1 = [[Player alloc] init];
    player1.color = PieceColorWhite;
    Player *player2 = [[Player alloc] init];
    player2.color = PieceColorBlack;
    
    GameBoard *board = [[GameBoard alloc] initWithBoardSize:8];
    [self doReset:board];
    
    {
        BOOL full = [board isFull];
        XCTAssertFalse(full);
        BOOL canMove1 = [board canMove:player1];
        XCTAssertTrue(canMove1);
        BOOL canMove2 = [board canMove:player2];
        XCTAssertTrue(canMove2);
    }
    
    {
        XCTestExpectation *expectation =  [self expectationWithDescription:@"boardFull"];
        
        board.placeBlock = ^(NSArray<NSArray <BoardPiece *> *> *pieceTracks)
        {
            [expectation fulfill];
        };
        
        [board updateBoard:^NSArray<NSArray<BoardPiece *> *> *
         {
             NSMutableArray<BoardPiece *> *pieces = [[NSMutableArray alloc] initWithCapacity:10];
             
             Piece *piece1 = [board pieceAtPositionX:5 Y:3];
             BoardPosition *pos1 = [[BoardPosition alloc] initWithX:5 Y:3];
             [pieces addObject:[BoardPiece makeBoardPieceWithPiece:piece1 position:pos1 color:PieceColorWhite]];
             
             Piece *piece2 = [board pieceAtPositionX:4 Y:2];
             BoardPosition *pos2 = [[BoardPosition alloc] initWithX:4 Y:2];
             [pieces addObject:[BoardPiece makeBoardPieceWithPiece:piece2 position:pos2 color:PieceColorBlack]];
             
             return @[pieces];
         }];
        
        [self waitForExpectationsWithTimeout:30.0 handler:^(NSError * error) {
        }];
        
        XCTAssertEqualObjects(board.piecesPlayed[@0], @-6);
        XCTAssertEqualObjects(board.piecesPlayed[@1], @3);
        XCTAssertEqualObjects(board.piecesPlayed[@2], @3);
    }
    
    {
        XCTestExpectation *expectation =  [self expectationWithDescription:@"ShowLegalYes"];
        
        board.placeBlock = ^(NSArray<NSArray <BoardPiece *> *> *pieceTracks)
        {
            [expectation fulfill];
        };
        
        [board showLegalMoves:YES forPlayer:player1];
        
        [self waitForExpectationsWithTimeout:30.0 handler:^(NSError * error) {
        }];
        
        XCTAssertEqualObjects(board.piecesPlayed[@0], @-13);
        XCTAssertEqualObjects(board.piecesPlayed[@7], @7);
        XCTAssertEqualObjects(board.piecesPlayed[@2], @3);
        XCTAssertEqualObjects(board.piecesPlayed[@1], @3);
    }
    
    {
        XCTestExpectation *expectation =  [self expectationWithDescription:@"ShowLegalNo"];
        
        board.placeBlock = ^(NSArray<NSArray <BoardPiece *> *> *pieceTracks)
        {
            [expectation fulfill];
        };
        
        [board showLegalMoves:NO forPlayer:player1];
        
        [self waitForExpectationsWithTimeout:30.0 handler:^(NSError * error) {
        }];
        
        XCTAssertEqualObjects(board.piecesPlayed[@0], @-6);
        XCTAssertEqualObjects(board.piecesPlayed[@7], @0);
        XCTAssertEqualObjects(board.piecesPlayed[@2], @3);
        XCTAssertEqualObjects(board.piecesPlayed[@1], @3);
    }
    
    {
        XCTestExpectation *expectation =  [self expectationWithDescription:@"ShowLegalYes"];
        
        board.placeBlock = ^(NSArray<NSArray <BoardPiece *> *> *pieceTracks)
        {
            [expectation fulfill];
        };
        
        [board showLegalMoves:YES forPlayer:player2];
        
        [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * error) {
        }];
        
        XCTAssertEqualObjects(board.piecesPlayed[@0], @-11);
        XCTAssertEqualObjects(board.piecesPlayed[@7], @5);
        XCTAssertEqualObjects(board.piecesPlayed[@2], @3);
        XCTAssertEqualObjects(board.piecesPlayed[@1], @3);
    }
    
    {
        XCTestExpectation *expectation =  [self expectationWithDescription:@"ShowLegalNo"];
        
        board.placeBlock = ^(NSArray<NSArray <BoardPiece *> *> *pieceTracks)
        {
            [expectation fulfill];
        };
        
        [board showLegalMoves:NO forPlayer:player2];
        
        [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * error) {
        }];
        XCTAssertEqualObjects(board.piecesPlayed[@0], @-6);
        XCTAssertEqualObjects(board.piecesPlayed[@7], @0);
        XCTAssertEqualObjects(board.piecesPlayed[@2], @3);
        XCTAssertEqualObjects(board.piecesPlayed[@1], @3);
    }
}

- (void)testMatch
{
    FothelloGame *game = [FothelloGame sharedInstance];
    self.match = [game createMatchFromKind:PlayerKindSelectionHumanVComputer difficulty:DifficultyEasy];
    
    GameBoard *board = self.match.board;

    // Create and configure the scene.

    {
        XCTestExpectation *expectation =  [self expectationWithDescription:@"placeMove"];
        
        board.placeBlock = ^(NSArray<NSArray <BoardPiece *> *> *pieceTracks)
        {
            [expectation fulfill];
        };
        
        [self.match.currentPlayer takeTurn]; //ai white
        
        [self waitForExpectationsWithTimeout:30.0 handler:nil];
    }

    board.placeBlock = ^(NSArray<NSArray <BoardPiece *> *> *pieceTracks)
    {
        // clear out previous block.
    };

    [self.match nextPlayer];
    
    {
        XCTestExpectation *expectation =  [self expectationWithDescription:@"hint"];
        
        board.highlightBlock = ^(BoardPosition *move, PieceColor color)
        {
            [expectation fulfill];
        };
        
        [self.match.currentPlayer hint]; //human black
        
        [self waitForExpectationsWithTimeout:30.0 handler:nil];
        
        board.highlightBlock = ^(BoardPosition *move, PieceColor color)
        {
        };
    }

    {
        XCTestExpectation *expectation =  [self expectationWithDescription:@"beginTurn"];
        
        board.placeBlock = ^(NSArray<NSArray <BoardPiece *> *> *pieceTracks)
        {
            [expectation fulfill];
        };
        
        [self.match beginTurn];
      
        [self waitForExpectationsWithTimeout:30.0 handler:nil];
    }

    {
        XCTestExpectation *expectation =  [self expectationWithDescription:@"endTurn"];
        
        board.placeBlock = ^(NSArray<NSArray <BoardPiece *> *> *pieceTracks)
        {
            [expectation fulfill];
        };
        
        [self.match endTurn];
        
        [self waitForExpectationsWithTimeout:30.0 handler:nil];
    }
   
    {
        XCTestExpectation *expectation =  [self expectationWithDescription:@"placeMove"];
        
        board.placeBlock = ^(NSArray<NSArray <BoardPiece *> *> *pieceTracks)
        {
            [expectation fulfill];
        };
        
        BoardPosition *pos = [BoardPosition positionWithX:2 y:2];
        [self.match.currentPlayer takeTurnAtPosition:pos];
        
        [self waitForExpectationsWithTimeout:30.0 handler:nil];
    }

    board.placeBlock = ^(NSArray<NSArray <BoardPiece *> *> *pieceTracks)
    {
        // clear out previous block.
    };
    
    [self.match nextPlayer];
    
    {
        XCTestExpectation *expectation =  [self expectationWithDescription:@"takeTurn"];
        
        board.highlightBlock = ^(BoardPosition *move, PieceColor color)
        {
            [expectation fulfill];
        };
        
        [self.match.currentPlayer takeTurn]; // White AI
        
        [self waitForExpectationsWithTimeout:30.0 handler:nil];
    }

    {
        XCTestExpectation *expectation =  [self expectationWithDescription:@"takeTurnPass"];
        
        board.highlightBlock = ^(BoardPosition *move, PieceColor color)
        {
            [expectation fulfill];
        };
        
        [self.match.currentPlayer takeTurnPass];
        
        [self waitForExpectationsWithTimeout:30.0 handler:nil];
    }
}

@end
