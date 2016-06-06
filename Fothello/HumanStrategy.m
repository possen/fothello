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
#import "GameBoard.h"


@interface Strategy (Protected)
- (nullable PlayerMove *)calculateMoveForPlayer:(nonnull Player *)player difficulty:(Difficulty)difficulty;
@end


#pragma mark - HumanStategy -

@implementation HumanStrategy

- (BOOL)manual
{
    return YES;
}

- (void)makeMove:(PlayerMove *)move forPlayer:(Player *)player
{
    // ignore clicks if turn still processing.
    if (self.match.turnProcessing)
    {
        return;
    }
    
    [self.match resetRedos];
        
    [self.match placeMove:move forPlayer:player showMove:NO];
}

- (void)hintForPlayer:(Player *)player
{
    PlayerMove *move = [self calculateMoveForPlayer:player difficulty:DifficultyEasy];
    [self.match.board showHintMove:move forPlayer:player];
}

- (BOOL)beginTurn:(Player *)player
{
    [self.match.board showLegalMoves:YES forPlayer:player];
    return NO;
}

- (void)endTurn:(Player *)player
{
    [self.match.board showLegalMoves:NO forPlayer:player];
}

@end
