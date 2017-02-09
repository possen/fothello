//
//  NSDictionary+NSDictionary_Extensions_h.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 2/8/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import "NSDictionary+Extensions.h"

@implementation NSDictionary (NSDictionary_Extensions_h)

- (NSDictionary *)mapObjectsUsingBlock:(NSArray<id> *(^)(id key, id obj))block
{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:[self count]];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *  stop)
    {
        NSArray *change = block(key, obj);
        [result setObject:change[1] forKey:change[0]];
    }];
    
    return result;
}

@end
