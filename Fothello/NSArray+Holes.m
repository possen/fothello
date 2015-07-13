//
//  NSMutableArray+NSMutableArray_Holes.m
//  WDMedia
//
//  Created by Paul Ossenbruggen on 2/15/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//
// an array extension that allows unfilled in areas. 

#import "NSArray+Holes.h"

@implementation NSArray (NSMutableArray_Holes)

- (id)objectAtCheckedIndex:(NSUInteger)index
{
    if (index >= self.count)
    {
        return nil;
    }
    else
    {
        id result =  [self objectAtIndex:index];
        return result == [NSNull null] ? nil : result;
    }
}

- (NSArray *)filterNSNulls
// this function will affect the position of the items
{
    NSIndexSet *set = [self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
                       {
                           return obj != [NSNull null];
                       }];
    
    return [self objectsAtIndexes:set];
}


@end

@implementation NSMutableArray (NSMutableArray_Holes)

- (void)setObject:(id)object atCheckedIndex:(NSUInteger)index
{
    NSNull *null = [NSNull null];
 
    if (!object)
    {
        object = null;
    }
    
    NSUInteger count = self.count;
    
    if (index < count)
    {
        [self replaceObjectAtIndex:index withObject:object];
    }
    else
    {
        if (index > count)
        {
            NSUInteger delta = index - count;
            
            for (NSUInteger i=0; i < delta; i++)
            {
                [self addObject:null];
            }
        }
        
        [self addObject:object];
    }
}


@end
