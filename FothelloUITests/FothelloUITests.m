
//  FothelloUITests.m
//  FothelloUITests
//
//  Created by Paul Ossenbruggen on 2/9/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FothelloGame.h"
#import "Match.h"

@interface FothelloUITests : XCTestCase

@end

@implementation FothelloUITests

- (void)setUp
{
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}


- (void)testComputerVSComputer
{
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCUIElementQuery *menuBarsQuery = app.menuBars;

    [self expectationForPredicate:
     [NSPredicate predicateWithFormat:@"isEnabled == false"]
                 evaluatedWithObject:app.menuItems[@"Hint"]
                          handler:nil ];

    [menuBarsQuery.menuBarItems[@"File"] click];
    [menuBarsQuery.menuItems[@"New Game..."] click];
  
    XCUIElement *fothelloWindow = app.windows[@"Fothello"];
    XCUIElementQuery *sheetsQuery = fothelloWindow.sheets;
    [[sheetsQuery childrenMatchingType:XCUIElementTypePopUpButton].element click];
    [sheetsQuery.menuItems[@"CvC"] click];
    [sheetsQuery.buttons[@"Start"] click];
    [menuBarsQuery.menuBarItems[@"Game"] click];
    
    [self waitForExpectationsWithTimeout:960 handler:nil];
//    XCUIElement *item = app.menuItems[@"Hint"];
//    XCTAssertFalse(item.isEnabled);
}

@end
