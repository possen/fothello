//
//  Strategy.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/18/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//
//  Main purpose is to pick a move whether from UI or from AI
//  Secondarily will 
//

#import <Foundation/Foundation.h>

#import "Match.h"
#import "Strategy.h"

@class Player;
@class PlayerMove;
@class BoardPosition;
@class GameBoard;

#pragma mark - Strategy -

@interface Strategy : NSObject <NSCoding>

@property (nonatomic, nonnull) Match *match;
@property (nonatomic, readonly) BOOL manual;

- (void)makeMoveForPlayer:(nonnull Player *)player;
- (void)makeMove:(nonnull PlayerMove *)move forPlayer:(nonnull Player *)player;
- (void)hintForPlayer:(nonnull Player *)player;
- (nullable NSArray<NSArray<BoardPiece *> *> *)beginTurn:(nonnull Player *)player;
- (nullable NSArray<NSArray<BoardPiece *> *> *)endTurn:(nonnull Player *)player;

@end
