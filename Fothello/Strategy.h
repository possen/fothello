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

@property (nonatomic) Match *match;
@property (nonatomic, readonly) BOOL manual;

- (id)initWithMatch:(Match *)match;
- (NSArray <BoardPiece *> *)takeTurn:(Player *)player;
- (NSArray <BoardPiece *> *)takeTurn:(Player *)player atX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass;
- (NSArray <BoardPiece *> *)legalMoves:(BOOL)display forPlayer:(Player *)player;
- (PlayerMove *)calculateMoveForPlayer:(Player *)player;
- (void)hintForPlayer:(Player *)player;

@end


#pragma mark - HumanStrategy -

@interface HumanStrategy : Strategy <NSCoding>
@end

@interface AIStrategy : Strategy
@end
