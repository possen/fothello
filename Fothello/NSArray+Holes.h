//
//  NSMutableArray+NSMutableArray_Holes.h
//  WDMedia
//
//  Created by Paul Ossenbruggen on 2/15/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (NSMutableArray_Holes)

- (id)objectAtCheckedIndex:(NSUInteger)index;
- (NSArray *)filterNSNulls;

@end

@interface NSMutableArray (NSMutableArray_Holes)

- (void)setObject:(id)object atCheckedIndex:(NSUInteger)index;

@end
