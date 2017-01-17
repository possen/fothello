//
//  AIStrategy.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/18/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "Match.h"
#import "Strategy.h"

@class Player;
@class PlayerMove;
@class BoardPosition;

#pragma mark - Strategy -

@interface Strategy : NSObject <NSCoding>

@property (nonatomic, nonnull) Match *match;
@property (nonatomic, readonly) BOOL manual;

- (nullable NSArray<NSArray<BoardPiece *> *> *)makeMove:(nonnull Player *)player;
- (nullable NSArray<NSArray<BoardPiece *> *> *)makeMove:(nonnull PlayerMove *)move forPlayer:(nonnull Player *)player;
- (nullable NSArray<NSArray<BoardPiece *> *> *)hintForPlayer:(nonnull Player *)player;
- (BOOL)beginTurn:(nonnull Player *)player;
- (void)endTurn:(nonnull Player *)player;

@end
