//
//  GameBoard+String.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/18/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameBoard.h"

@interface GameBoard (String)

- (nonnull NSString *)convertToString:(BOOL)ascii reverse:(BOOL)reverse;

@end
