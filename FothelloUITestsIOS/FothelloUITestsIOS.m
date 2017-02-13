//
//  FothelloUITestsIOS.m
//  FothelloUITestsIOS
//
//  Created by Paul Ossenbruggen on 2/12/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface FothelloUITestsIOS : XCTestCase

@end

@implementation FothelloUITestsIOS

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

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testComputerVsComputer
{
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCUIElement *element = [[[[app childrenMatchingType:XCUIElementTypeWindow] elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element;
    [app.buttons[@"New Game"] tap];
    [[[element childrenMatchingType:XCUIElementTypeSegmentedControl] elementBoundByIndex:0].buttons[@"Computer"] tap];
    [[app.segmentedControls containingType:XCUIElementTypeButton identifier:@"Game Canter"].buttons[@"Computer"] tap];
    [app.buttons[@"Easy"] tap];
    [app.buttons[@"Play"] tap];
}

@end
