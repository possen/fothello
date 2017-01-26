//
//  NSArray+Extensions.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/29/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "NSArray+Extensions.h"

@implementation NSArray (Extensions)

+ (NSArray *)flatten:(NSArray<NSArray<id> *> *)arrayOfArrays;
{
    return[arrayOfArrays valueForKeyPath: @"@unionOfArrays.self"];
}

@end
