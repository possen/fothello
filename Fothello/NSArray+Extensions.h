//
//  NSArray+NSArray_Extensions.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/29/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Extensions)
+ (NSArray *)flatten:(NSArray<NSArray<id> *> *)arrayOfArrays;
@end
