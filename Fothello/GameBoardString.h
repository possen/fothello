//
//  GameBoard+String.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/18/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameBoardInternal.h"

@interface GameBoardString : NSObject
@property (nonatomic, nonnull) GameBoardInternal * boardInternal;

- (nonnull instancetype)initWithBoard:(nonnull GameBoardInternal *)internal;

- (nonnull NSString *)convertToString:(BOOL)ascii reverse:(BOOL)reverse;
- (void)printBoardUpdates:(nonnull NSArray<NSArray<BoardPiece *> *> *)tracks;

@end
