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
    
    [super makeMove:move forPlayer:player];
    
    [self.match resetRedos];
    
    BOOL legal = [self.match isLegalMove:move forPlayer:player];
    
    if (legal)
    {
        [self.match placeMove:move forPlayer:player];
    }
}

- (void)hintForPlayer:(Player *)player
{
    PlayerMove *move = [self calculateMoveForPlayer:player difficulty:DifficultyEasy];
    [self.match.board showHintMove:move forPlayer:player];
}

- (NSArray<NSArray<BoardPiece *> *> *)beginTurn:(Player *)player
{
    return [self.match.board showLegalMoves:YES forPlayer:player];
}

- (NSArray<NSArray<BoardPiece *> *> *)endTurn:(Player *)player
{
    return [self.match.board showLegalMoves:NO forPlayer:player];
}

@end
