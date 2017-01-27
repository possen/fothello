//
//  FothelloTests.m
//  FothelloTests
//
//  Created by Paul Ossenbruggen on 11/11/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <FothelloLib/FothelloLib.h>
#import "Board.hpp"

@interface FothelloTests : XCTestCase

@end

@implementation FothelloTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBasicBoard
{
    printf("sizeof(Board): %lu\n", sizeof(Board));
    Board* myB = makeBoard();
    bool legal[64];
    findLegalMoves(myB, legal, BLACK);
    printBoard(myB, legal, CONV_21(0, 0));
    
    char nblack, nwhite;
    countPieces(myB, &nblack, &nwhite, 0);
    XCTAssert(nblack == 0);
    XCTAssert(nwhite == 0);
    
    findLegalMoves(myB, legal, WHITE);
    printBoard(myB, legal, CONV_21(0, 0));
    
    countPieces(myB, &nblack, &nwhite, 0);
    printf("# black: %d, # white: %d\n", nblack, nwhite);
    XCTAssert(nblack == 0);
    XCTAssert(nwhite == 0);
    
    bool leg54 = legalMove(myB, 5, 4, BLACK);
    bool leg53 = legalMove(myB, 5, 3, BLACK);
    bool leg55 = legalMove(myB, 5, 5, BLACK);
    printf("leg53: %d, leg54: %d, leg55: %d\n", leg53, leg54, leg55);
    XCTAssert(leg54 == 0);
    XCTAssert(leg53 == 0);
    XCTAssert(leg55 == 0);
   
    printBoard(myB, legal, CONV_21(0, 0));
    
}

@end
