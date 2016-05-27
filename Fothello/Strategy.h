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
@class BoardPosition;

#pragma mark - Strategy -

@interface Strategy : NSObject <NSCoding>

@property (nonatomic, nonnull) Match *match;
@property (nonatomic, readonly) BOOL manual;

- (nonnull id)initWithMatch:(nonnull Match *)match;
- (nullable NSArray <BoardPiece *> *)takeTurn:(nonnull Player *)player;
- (nullable NSArray <BoardPiece *> *)takeTurn:(nonnull Player *)player atX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass;
- (nullable NSArray <BoardPiece *> *)legalMoves:(BOOL)display forPlayer:(nonnull Player *)player;
- (nullable PlayerMove *)calculateMoveForPlayer:(nonnull Player *)player difficulty:(Difficulty)difficulty;
- (void)hintForPlayer:(nonnull Player *)player;

@end


