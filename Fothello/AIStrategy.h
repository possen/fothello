//
//  AIStrategy.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/27/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Strategy.h"

@interface AIStrategy : Strategy
- (instancetype)initWithDifficulty:(Difficulty)difficulty engine:(id<Engine>)engine;
@end
