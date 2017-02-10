//
//  UtilTests.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 2/9/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSArray+Holes.h"
#import "NSArray+Extensions.h"

@interface UtilTests : XCTestCase

@end

@implementation UtilTests

- (void)testTestAccessors
{
    NSMutableArray *arr = [NSMutableArray new];
    [arr setObject:@"test1" atCheckedIndex:2];
    [arr setObject:@"test2" atCheckedIndex:20];
    [arr setObject:@"test3" atCheckedIndex:9];
    
    XCTAssertEqualObjects([arr objectAtCheckedIndex:2], @"test1");
    XCTAssertEqualObjects([arr objectAtCheckedIndex:20], @"test2");
    XCTAssertEqualObjects([arr objectAtCheckedIndex:9], @"test3");
}


- (void)testNullAndFilteredNils
{
    NSMutableArray *arr = [NSMutableArray new];
    [arr setObject:nil atCheckedIndex:15];
    [arr setObject:@"test1" atCheckedIndex:2];
    [arr setObject:@"test2" atCheckedIndex:20];
    [arr setObject:@"test3" atCheckedIndex:9];

    XCTAssertNil([arr objectAtCheckedIndex:15]);
    XCTAssertNil([arr objectAtCheckedIndex:3]);
    NSArray *filtered = [arr filterNSNulls];
    NSArray *result = @[@"test1", @"test3", @"test2"];
    XCTAssertEqualObjects(result, filtered);

    XCTAssertNil([arr objectAtCheckedIndex:50]);
}

- (void)testFlattened
{
    NSArray *arr = @[@[@"test1", @"test2"], @[@"test3", @"test4"], @[@"test5"]];
    NSArray *flattened = [arr flatten];
    NSArray *result = @[@"test1", @"test2", @"test3", @"test4", @"test5"];
    XCTAssertEqualObjects(result, flattened);
    
    XCTAssertNil([arr objectAtCheckedIndex:50]);
}

- (void)testMap
{
    NSArray *arr = @[@1, @2, @3, @4, @5, @8];
    NSArray *result = [arr mapObjectsUsingBlock:
        ^id(id obj, NSUInteger idx)
        {
            return [NSString stringWithFormat:@"Mississippi %@", obj];
        }];
    NSArray *mapped =     @[@"Mississippi 1",
                            @"Mississippi 2",
                            @"Mississippi 3",
                            @"Mississippi 4",
                            @"Mississippi 5",
                            @"Mississippi 8"];

    XCTAssertEqualObjects(result, mapped );
}

@end
