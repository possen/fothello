//
//  TestBoardOps.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/15/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <FothelloLib/FothelloLib.h>
#import <GameplayKit/GameplayKit.h>
#import "EngineStrong.h"
#import "GameBoardInternal.h"
#import "GameBoardTracks.h"
#import "GameBoardRepresentation.h"
#import "GameBoardLegalMoves.h"

@interface GameBoard ()
@property (nonatomic) GameBoardInternal *boardInternal;
@end

@interface GameBoardInternal ()
@property (nonatomic, nonnull) GameBoardRepresentation *boardRepresentation;
@end

@interface TestBoardOps : XCTestCase
@property (nonatomic) Match *match;
@property (nonatomic) EngineStrong *engineStrong;
@property (nonatomic) FothelloGame *game;
@end

@implementation TestBoardOps

- (void)setUp
{
    [super setUp];
    
    FothelloGame *game = [FothelloGame sharedInstance];
    EngineStrong *engineStrong = [[EngineStrong alloc] init];
    game.engine = engineStrong;
    Match *match = [game setupDefaultMatch];
    self.engineStrong = engineStrong;
    self.match = match;
    self.game.matches = [@[match] mutableCopy];
    self.game = game;
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testBoardPlace
{
    GameBoard *board = [[GameBoard alloc] initWithBoardSize:8];
    GameBoardInternal *internal  = board.boardInternal;
    XCTestExpectation *expectation =  [self expectationWithDescription:@"testBoardPlace"];

    [board updateBoard:^NSArray<NSArray<BoardPiece *> *> *
     {
         NSMutableArray<BoardPiece *> *pieces = [[NSMutableArray alloc] initWithCapacity:10];
         BoardPosition *center = internal.center;
         [internal.tracker boxCoord:4 block:^(BoardPosition *position, BOOL isCorner, NSInteger count, BOOL *stop)
          {
              NSInteger x = center.x + position.x; NSInteger y = center.y + position.y;
              Piece *piece = [internal pieceAtPositionX:x Y:y];
         
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
         Piece *peice1 = [internal pieceAtPositionX:0 Y:0];
         XCTAssertEqualObjects(peice1.description, @"○");
         Piece *peice2 = [internal pieceAtPositionX:7 Y:7];
         XCTAssertEqualObjects(peice2.description, @"○");
         Piece *peice3 = [internal pieceAtPositionX:3 Y:3];
         XCTAssertEqualObjects(peice3.description, @"·");
         return nil;
     }];
}

- (void)testFindOps
{
    GameBoard *board = [[GameBoard alloc] initWithBoardSize:8];
    XCTestExpectation *expectation =  [self expectationWithDescription:@"testCanMove"];
    GameBoardInternal *internal  = board.boardInternal;

    [board updateBoard:^NSArray<NSArray<BoardPiece *> *> *
    {
        NSMutableArray<BoardPiece *> *pieces = [[NSMutableArray alloc] initWithCapacity:10];
        
        Piece *piece1 = [internal pieceAtPositionX:3 Y:3];
        BoardPosition *pos1 = [[BoardPosition alloc] initWithX:3 Y:3];
        [pieces addObject:[BoardPiece makeBoardPieceWithPiece:piece1 position:pos1 color:PieceColorWhite]];

        Piece *piece2 = [internal pieceAtPositionX:4 Y:3];
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
         
         Piece *piece1 = [internal pieceAtPositionX:5 Y:3];
         BoardPosition *pos1 = [[BoardPosition alloc] initWithX:5 Y:3];
         [pieces addObject:[BoardPiece makeBoardPieceWithPiece:piece1 position:pos1 color:PieceColorWhite]];
         
         PlayerMove *move = [PlayerMove makeMoveForColor:PieceColorWhite position:pos1];
         [board placeMoves:@[move]];
         
         [expectation fulfill];
         return @[pieces];
     }];
 
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error)
     {
         XCTAssert(error == nil, @"error");
     }];
  
    [board updateBoard:^NSArray<NSArray<BoardPiece *> *> *
    {
        Piece *peice1 = [internal pieceAtPositionX:3 Y:3];
        XCTAssertEqualObjects(peice1.description, @"○");
        Piece *peice2 = [internal pieceAtPositionX:4 Y:3];
        XCTAssertEqualObjects(peice2.description, @"●");
        Piece *peice3 = [internal pieceAtPositionX:5 Y:3];
        XCTAssertEqualObjects(peice3.description, @"○");
        
        NSInteger score = [internal playerScoreUnqueued:player];
        XCTAssertEqual(score, 2);
        return nil;
    }];
}

- (void)playCvCGame:(NSString *)seed
{
    [self.engineStrong seed:seed];

    self.match = [self.game createMatchFromKind:PlayerKindSelectionComputerVComputer
                                     difficulty:DifficultyEasy];

    [self.match reset];
    [self.match beginMatch];
    NSLog(@"match description %@", [self.match description]);
    
    XCTAssertEqual([self.match areAllPlayersComputers], true);
    
    XCTestExpectation *expectation =  [self expectationWithDescription:@"testFinishGame"];
    
    __block BOOL gameFinished = NO;
    self.match.matchStatusBlock = ^(BOOL gameOver)
    {
        gameFinished = gameOver;
        if (gameFinished)
        {
            [expectation fulfill];
        }
    };
    
    __weak TestBoardOps *weakSelf = self;
    weakSelf.match.currentPlayerBlock = ^(Player *player, BOOL canMove, BOOL pass)
    {
        if (!gameFinished)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
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
    
    self.match.currentPlayerBlock = nil;
}

- (void)testSetupComputerVsComputerGame1
{
    [self playCvCGame:@"1"];
}

- (void)testSetupComputerVsComputerGame2
{
    [self playCvCGame:@"2"];
}

- (void)testSetupComputerVsComputerGame3
{
    [self playCvCGame:@"3"];
}

- (void)testSetupComputerVsComputerGame4
{
    [self playCvCGame:@"4"];
}

- (void)testSetupComputerVsComputerGame5
{
    [self playCvCGame:@"5"];
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
    Player *player1 = [[Player alloc] initWithName:@"Player 1"];
    player1.color = PieceColorWhite;
    Player *player2 = [[Player alloc] initWithName:@"Player 2"];
    player2.color = PieceColorBlack;
    
    GameBoard *board = [[GameBoard alloc] initWithBoardSize:8];
    GameBoardInternal *internal  = board.boardInternal;

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
         
         Piece *piece1 = [internal pieceAtPositionX:6 Y:4];
         BoardPosition *pos1 = [[BoardPosition alloc] initWithX:3 Y:3];
         [pieces addObject:[BoardPiece makeBoardPieceWithPiece:piece1 position:pos1 color:PieceColorWhite]];
         
         Piece *piece2 = [internal pieceAtPositionX:7 Y:2];
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
    Player *player1 = [[Player alloc] initWithName:@"Player 1"];
    player1.color = PieceColorWhite;
    Player *player2 = [[Player alloc] initWithName:@"Player 2"];
    player2.color = PieceColorBlack;

    GameBoard *board = [[GameBoard alloc] initWithBoardSize:8];
    GameBoardInternal *internal  = board.boardInternal;

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
        
        [internal visitAllUnqueued:^(NSInteger x, NSInteger y, Piece *piece)
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
    Player *player1 = [[Player alloc] initWithName:@"Player 1"];
    player1.color = PieceColorWhite;
    Player *player2 = [[Player alloc] initWithName:@"Player 2"];
    player2.color = PieceColorBlack;
    
    GameBoard *board = [[GameBoard alloc] initWithBoardSize:8];
    GameBoardInternal *internal  = board.boardInternal;

    [self doReset:board];
    
    {
        BOOL full = [board isFull];
        XCTAssertFalse(full);
        BOOL canMove1 = [board canMove:player1];
        XCTAssertTrue(canMove1);
        BOOL canMove2 = [board canMove:player2];
        XCTAssertTrue(canMove2);
        [board isLegalMove:[PlayerMove makeMoveForColor:PieceColorWhite position:[BoardPosition positionWithX:2 Y:2]] forPlayer:player1 legal:^(BOOL legal) {
            XCTAssertTrue(legal);
        }];
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
             
             Piece *piece1 = [internal pieceAtPositionX:5 Y:3];
             BoardPosition *pos1 = [[BoardPosition alloc] initWithX:5 Y:3];
             [pieces addObject:[BoardPiece makeBoardPieceWithPiece:piece1 position:pos1 color:PieceColorWhite]];
             
             Piece *piece2 = [internal pieceAtPositionX:4 Y:2];
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

- (void)makeMoveAI
{
    __weak TestBoardOps *weakSelf = self;
    
    XCTestExpectation *expectation =  [self expectationWithDescription:@"placeMove"];
    
    weakSelf.match.currentPlayerBlock = ^(Player *player, BOOL canMove, BOOL pass)
    {
        XCTAssertEqualObjects(player.name, self.match.currentPlayer.name);
        [expectation fulfill];
    };
    
    XCTAssertEqualObjects(@"White", self.match.currentPlayer.name);
    [self.match.currentPlayer takeTurn]; //ai white
    
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
    
    weakSelf.match.currentPlayerBlock = ^(Player *player, BOOL canMove, BOOL pass)
    {
    };
}

- (void)makeMoveHuman:(BoardPosition *)position
{
    __weak TestBoardOps *weakSelf = self;
    
    XCTestExpectation *expectation =  [self expectationWithDescription:@"placeMove"];
    
    weakSelf.match.currentPlayerBlock = ^(Player *player, BOOL canMove, BOOL pass)
    {
        XCTAssertEqualObjects(player.name, self.match.currentPlayer.name);
        [expectation fulfill];
    };
    
    [self.match.currentPlayer takeTurnAtPosition:position];
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
    
    weakSelf.match.currentPlayerBlock = ^(Player *player, BOOL canMove, BOOL pass)
    {
    };
}


- (void)testMatch
{
    [self.engineStrong seed:@"match"];
    self.match = [self.game createMatchFromKind:PlayerKindSelectionHumanVComputer difficulty:DifficultyEasy];
    
    GameBoard *board = self.match.board;
    __weak TestBoardOps *weakSelf = self;

    [self makeMoveAI];
    [self.match nextPlayer];
    XCTAssertEqualObjects(@"Black", self.match.currentPlayer.name);
   
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

    XCTAssertEqualObjects(@"Black", self.match.currentPlayer.name);

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
    
    board.placeBlock = ^(NSArray<NSArray <BoardPiece *> *> *pieceTracks)
    {
        // clear out block
    };
    
    [self makeMoveHuman:[BoardPosition positionWithX:1 Y:4]];

    [self.match nextPlayer];
    XCTAssertEqualObjects(@"White", self.match.currentPlayer.name);

    [self makeMoveAI];
    
    [self.match nextPlayer];
    XCTAssertEqualObjects(@"Black", self.match.currentPlayer.name);

    {
        XCTestExpectation *expectation =  [self expectationWithDescription:@"takeTurnPass"];
        
        weakSelf.match.currentPlayerBlock = ^(Player *player, BOOL canMove, BOOL pass)
        {
            XCTAssertTrue(pass);
            [expectation fulfill];
        };
        
        [self.match.currentPlayer takeTurnPass];
        
        [self waitForExpectationsWithTimeout:30.0 handler:nil];
    }
    
    [self.match nextPlayer];
    XCTAssertEqualObjects(@"White", self.match.currentPlayer.name);

    {
        XCTestExpectation *expectation =  [self expectationWithDescription:@"takeTurn"];
        
        weakSelf.match.currentPlayerBlock = ^(Player *player, BOOL canMove, BOOL pass)
        {
            XCTAssertFalse(pass);
            [expectation fulfill];
        };
        
        [self.match.currentPlayer takeTurn]; // White AI
        
        [self waitForExpectationsWithTimeout:30.0 handler:nil];
    }
}

- (void)undoMoves
{
    __weak TestBoardOps *weakSelf = self;

    __block XCTestExpectation *expectation =  [self expectationWithDescription:@"undo"];
    weakSelf.match.matchStatusBlock = ^(BOOL gameOver)
    {
        XCTAssertFalse(gameOver);
    };
    
    GameBoard *board = self.match.board;
    board.updateCompleteBlock = ^()
    {
        [expectation fulfill];
        expectation = nil; // may get called multiple times.
    };
    
    [self.match.matchMoves undo];
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
    
    board.updateCompleteBlock = ^()
    {
    };
    weakSelf.match.matchStatusBlock = nil;
}


- (void)redoMoves
{
    XCTestExpectation *expectation =  [self expectationWithDescription:@"undo"];
    
    GameBoard *board = self.match.board;
    board.updateCompleteBlock = ^()
    {
        [expectation fulfill];
    };
    
    [self.match.matchMoves redo];
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
    
    board.updateCompleteBlock = ^()
    {
    };
}

- (void)testUndoRedo
{
    [self.engineStrong seed:@"undoredo"];
    self.match = [self.game createMatchFromKind:PlayerKindSelectionHumanVComputer difficulty:DifficultyEasy];

    [self makeMoveAI];
    [self.match nextPlayer];
    XCTAssertEqualObjects(@"Black", self.match.currentPlayer.name);
    [self makeMoveHuman:[BoardPosition positionWithX:1 Y:4]];
    [self.match nextPlayer];
    XCTAssertEqualObjects(@"White", self.match.currentPlayer.name);
    [self makeMoveAI];
    [self.match nextPlayer];
    XCTAssertEqualObjects(@"Black", self.match.currentPlayer.name);
    [self makeMoveHuman:[BoardPosition positionWithX:2 Y:6]];
    [self.match nextPlayer];
    XCTAssertEqualObjects(@"White", self.match.currentPlayer.name);
    [self makeMoveAI];    
    [self undoMoves];
    [self redoMoves];
}

@end
