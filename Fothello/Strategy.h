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
@class Move;

#pragma mark - Strategy -

@interface Strategy : NSObject <NSCoding>

@property (nonatomic) Match *match;
@property (nonatomic, readonly) BOOL manual;

- (id)initWithMatch:(Match *)match;
- (BOOL)takeTurn:(Player *)player atX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass;
- (BOOL)otherPlayer:(Player *)player movedToX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass;
- (BOOL)displaylegalMoves:(BOOL)display forPlayer:(Player *)player;
- (void)resetWithDifficulty:(Difficulty)difficulty;
- (void)pass;
- (void)convertBoard;
- (Move *)calculateMoveForPlayer:(Player *)player;
- (void)hintForPlayer:(Player *)player;

@end


#pragma mark - HumanStrategy -

@interface HumanStrategy : Strategy <NSCoding>
@end

@interface AIStrategy : Strategy
@end
