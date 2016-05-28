//
//  HumanStrategy.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/27/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "FothelloGame.h"
#import "HumanStrategy.h"
#import "Piece.h"
#import "Match.h"
#import "Player.h"
#import "PlayerMove.h"
#import "BoardPosition.h"


@interface Strategy (Protected)
- (nullable PlayerMove *)calculateMoveForPlayer:(nonnull Player *)player difficulty:(Difficulty)difficulty;
@end


#pragma mark - HumanStategy -

@implementation HumanStrategy

- (BOOL)manual
{
    return YES;
}

- (void)takeTurn:(Player *)player atX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass
{
    [super takeTurn:player atX:x Y:y pass:pass];
        
    BoardPosition *boardPosition = [BoardPosition positionWithX:x y:y];
    PlayerMove *move = [PlayerMove makeMoveForColor:player.color position:boardPosition];
    [self.match placeMove:move forPlayer:player showMove:NO];
}

- (void)hintForPlayer:(Player *)player
{
    PlayerMove *move = [self calculateMoveForPlayer:player difficulty:DifficultyEasy];
    [self.match showHintMove:move forPlayer:player];
}
@end
