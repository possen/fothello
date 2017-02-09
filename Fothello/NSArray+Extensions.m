//
//  NSArray+Extensions.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/29/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "NSArray+Extensions.h"

@implementation NSArray (Extensions)

+ (NSArray *)flatten:(NSArray<NSArray<id> *> *)arrayOfArrays
{
    return [arrayOfArrays valueForKeyPath: @"@unionOfArrays.self"];
}

- (NSArray *)flatten
{
    return [self valueForKeyPath: @"@unionOfArrays.self"];
}

- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject:block(obj, idx)];
    }];
    return result;
}

@end
