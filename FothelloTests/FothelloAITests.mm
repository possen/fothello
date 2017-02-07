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
#import "json.hpp"

using namespace std;
using json = nlohmann::json;

@interface FothelloTestsAI : XCTestCase

@end

@implementation FothelloTestsAI

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

    XCTAssertEqual(leg54, 0);
    XCTAssertEqual(leg53, 0);
    XCTAssertEqual(leg55, 0);
   
    printBoard(myB, legal, CONV_21(0, 0));
    
    char move1 = getMove(myB, CONV_21(6, 5), 2, BoardDiffcultyExperienced);
    XCTAssertEqual(move1, -1);
    
    char move2 = getMove(myB, CONV_21(5, 5), 2, BoardDiffcultyExperienced);
    XCTAssertEqual(move2, -1);
}

- (void)testFromFirstMove
{
    Board *board = makeBoard();
    std::string boardResult =
                "----------\n"
                "|........|\n"
                "|........|\n"
                "|........|\n"
                "|...XO...|\n"
                "|...OX...|\n"
                "|........|\n"
                "|........|\n"
                "|........|\n"
                "----------\n";
    bool result = setBoardFromString(board, boardResult);
    XCTAssertEqual(result, true, @"failetoconvert");

    json j;
    j["difficulty"] = (int)BoardDiffcultyExperienced;
    j["moveNum"] = 4;
    j["board"] = boardResult;
    j["color"] = (int)BLACK;
    std::string s = j.dump(4);
    printf("%s", s.c_str());
    
    std::string jsonResp = getMoveFromJSON(j.dump(4));
    json r = json::parse(jsonResp);

    bool pass = r["pass"].get<bool>();
    NSInteger ay = r["movey"].get<int>();
    NSInteger ax = r["movex"].get<int>();
    
    XCTAssertEqual(pass, false);
    XCTAssertEqual(ax, 4);
    XCTAssertEqual(ay, 2);
    
    j["color"] = (int)WHITE;
    jsonResp = getMoveFromJSON(j.dump(4));
    r = json::parse(jsonResp);
    
    pass = r["pass"].get<bool>();
    ay = r["movey"].get<int>();
    ax = r["movex"].get<int>();

    XCTAssertEqual(pass, false);
    XCTAssertEqual(ax, 3);
    XCTAssertEqual(ay, 2);
}

- (void)testFromEndMoves
{
    Board *board = makeBoard();
    std::string boardResult =
    "----------\n"
    "|XXXXXXXX|\n"
    "|OXOOOXOO|\n"
    "|XXXOOXOX|\n"
    "|OOOXOXOO|\n"
    "|XXXOXOOO|\n"
    "|XXOXXX..|\n"
    "|XXXXXXOO|\n"
    "|XXXXXXXX|\n"
    "----------\n";
    bool result = setBoardFromString(board, boardResult);
    XCTAssertEqual(result, true, @"failetoconvert");
    
    json j;
    j["difficulty"] = (int)BoardDiffcultyExperienced;
    j["moveNum"] = 62;
    j["board"] = boardResult;
    j["color"] = (int)BLACK;
    std::string s = j.dump(4);
    printf("%s", s.c_str());
    
    std::string jsonResp = getMoveFromJSON(j.dump(4));
    json r = json::parse(jsonResp);
    
    bool pass;
    NSInteger ax;
    NSInteger ay;
    
    pass = r["pass"].get<bool>();
    ay = r["movey"].get<int>();
    ax = r["movex"].get<int>();
    
    XCTAssertEqual(pass, false);
    XCTAssertEqual(ax, 6);
    XCTAssertEqual(ay, 5);
    
    j["color"] = (int)WHITE;
    jsonResp = getMoveFromJSON(j.dump(4));
    r = json::parse(jsonResp);
    
    pass = r["pass"].get<bool>();
    ay = r["movey"].get<int>();
    ax = r["movex"].get<int>();
    
    XCTAssertEqual(pass, false);
    XCTAssertEqual(ax, 6);
    XCTAssertEqual(ay, 5);
}


- (void)testPassMove
{
    Board *board = makeBoard();
    std::string boardResult =
    "----------\n"
    "|XXXXXXXX|\n"
    "|OXOOOXOO|\n"
    "|XXXOOXOX|\n"
    "|OOOXOXOO|\n"
    "|XXXOXOOO|\n"
    "|XXXXXX..|\n"
    "|XXXXXXOO|\n"
    "|XXXXXXXX|\n"
    "----------\n";
    bool result = setBoardFromString(board, boardResult);
    XCTAssertEqual(result, true, @"failetoconvert");
    
    json j;
    j["difficulty"] = (int)BoardDiffcultyExperienced;
    j["moveNum"] = 62;
    j["board"] = boardResult;
    j["color"] = (int)BLACK;
    std::string s = j.dump(4);
    printf("%s", s.c_str());
    
    std::string jsonResp = getMoveFromJSON(j.dump(4));
    json r = json::parse(jsonResp);
    
    bool pass;
    NSInteger ax;
    NSInteger ay;
    
    pass = r["pass"].get<bool>();
    ay = r["movey"].get<int>();
    ax = r["movex"].get<int>();
    
    XCTAssertEqual(pass, false);
    XCTAssertEqual(ax, 6);
    XCTAssertEqual(ay, 5);
    
    pass = r["pass"].get<bool>();
    XCTAssertEqual(pass, false);
    
    j["color"] = (int)WHITE;
    jsonResp = getMoveFromJSON(j.dump(4));
    r = json::parse(jsonResp);
    
    pass = r["pass"].get<bool>();
    XCTAssertEqual(pass, true);
}


- (void)testFromLastMove
{
    Board *board = makeBoard();
    std::string boardResult =
                "----------\n"
                "|XXXXXXXX|\n"
                "|OXOOOXOO|\n"
                "|XXXOOXOX|\n"
                "|OOOXOXOO|\n"
                "|XXXOXOOO|\n"
                "|XXOXXXOX|\n"
                "|XXXXXXOO|\n"
                "|XXXXXXXX|\n"
                "----------\n";
    bool result = setBoardFromString(board, boardResult);
    XCTAssertEqual(result, true, @"failetoconvert");
    
    json j;
    j["difficulty"] = (int)BoardDiffcultyExperienced;
    j["moveNum"] = 62;
    j["board"] = boardResult;
    j["color"] = (int)BLACK;
    std::string s = j.dump(4);
    printf("%s", s.c_str());
    
    std::string jsonResp = getMoveFromJSON(j.dump(4));
    json r = json::parse(jsonResp);
    
    bool pass;
    
    pass = r["pass"].get<bool>();
    XCTAssertEqual(pass, true);
    
    j["color"] = (int)WHITE;
    jsonResp = getMoveFromJSON(j.dump(4));
    r = json::parse(jsonResp);
    
    pass = r["pass"].get<bool>();
    XCTAssertEqual(pass, true);
}

@end
