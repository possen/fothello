//
//  NSDictionary_Extensions_h.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 2/8/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (NSDictionary_Extensions_h)
- (NSDictionary *)mapObjectsUsingBlock:(NSArray<id> * (^)(id key, id obj))block;
@end
