//
//  Strategy.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/2/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "FothelloGame.h"

@class Match;
@class Player;

#pragma mark - Strategy -

@interface Strategy : NSObject <NSCoding>

@property (nonatomic) Match *match;
@property (nonatomic, readonly) BOOL manual;

- (id)initWithMatch:(Match *)match ;
- (BOOL)takeTurn:(Player *)player atX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass;
- (BOOL)otherPlayer:(Player *)player movedToX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass;
- (BOOL)displaylegalMoves:(BOOL)display forPlayer:(Player *)player;
- (void)resetWithDifficulty:(Difficulty)difficulty;
- (void)pass;
- (void)convertBoard;

@end


#pragma mark - HumanStrategy -

@interface HumanStrategy : Strategy <NSCoding>
@end

