//
//  FothelloTests.m
//  FothelloTests
//
//  Created by Paul Ossenbruggen on 11/11/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import <XCTest/XCTest.h>
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
    Board* myB = makeBoard(false);
    bool legal[64];
    findLegalMoves(myB, legal);
    printBoard(myB, legal);
    
    char nblack, nwhite;
    countPieces(myB, &nblack, &nwhite);
    XCTAssert(nblack == 2);
    XCTAssert(nwhite == 2);
    
    makeMove(myB, 5, 4);
    findLegalMoves(myB, legal);
    printBoard(myB, legal);
    
    countPieces(myB, &nblack, &nwhite);
    printf("# black: %d, # white: %d\n", nblack, nwhite);
    XCTAssert(nblack == 4);
    XCTAssert(nwhite == 1);
    
    bool leg54 = legalMove(myB, 5, 4);
    bool leg53 = legalMove(myB, 5, 3);
    bool leg55 = legalMove(myB, 5, 5);
    printf("leg53: %d, leg54: %d, leg55: %d\n", leg53, leg54, leg55);
    XCTAssert(leg54 == 0);
    XCTAssert(leg53 == 1);
    XCTAssert(leg55 == 1);
   
    startNew(BoardDiffcultyBeginner);
    printBoard(myB, legal);
    
    int p1, p2, p3;
    p1 = getPiece(myB, CONV_21(3, 3));
    p2 = getPiece(myB, CONV_21(2, 4));
    p3 = getPiece(myB, CONV_21(3, 4));
    printf("27: %d, 34: %d, 35: %d\n", p1, p2, p3);
    printf("COORD_21(3, 5): %d\n", CONV_21(3, 5));
    
    XCTAssert(p1 == 2);
    XCTAssert(p2 == 0);
    XCTAssert(p3 == 1);
}

@end
