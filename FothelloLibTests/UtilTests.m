//
//  UtilTests.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 2/9/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSArray+Holes.h"

@interface UtilTests : XCTestCase

@end

@implementation UtilTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTestAccessors {
    NSMutableArray *arr = [NSMutableArray new];
    [arr setObject:@"test1" atCheckedIndex:2];
    [arr setObject:@"test2" atCheckedIndex:20];
    [arr setObject:@"test3" atCheckedIndex:9];
    
    XCTAssertEqualObjects([arr objectAtCheckedIndex:2], @"test1");
    XCTAssertEqualObjects([arr objectAtCheckedIndex:20], @"test2");
    XCTAssertEqualObjects([arr objectAtCheckedIndex:9], @"test3");
}


- (void)testNullAndFlatten
{
    NSMutableArray *arr = [NSMutableArray new];
    [arr setObject:nil atCheckedIndex:15];
    [arr setObject:@"test1" atCheckedIndex:2];
    [arr setObject:@"test2" atCheckedIndex:20];
    [arr setObject:@"test3" atCheckedIndex:9];

    XCTAssertNil([arr objectAtCheckedIndex:15]);
    XCTAssertNil([arr objectAtCheckedIndex:3]);
    NSArray *flattened = [arr filterNSNulls];
    NSArray *result = @[@"test1", @"test3", @"test2"];
    XCTAssertEqualObjects(result, flattened);

    XCTAssertNil([arr objectAtCheckedIndex:50]);
}


@end
