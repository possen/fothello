//
//  GestureSelection.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 7/3/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GestureSelection.h"
#import "BoardScene.h"
#import "BoardPiece.h"
#import "BoardScene.h"
#import "GameBoard.h"
#import "Player.h"
#import "Match.h"
#import "PlayerMove.h"


@interface GestureSelection ()
@property (nonatomic) BoardScene *boardScene;
@end

@implementation GestureSelection

- (instancetype)initWithMatch:(Match *)match
{
    self = [super init];
    if (self)
    {
        _match = match;
    }
    return self;
}

- (void)up
{
    self.currentPos -= 1;
    [self selectLegalMove];
}

- (void)down
{
    self.currentPos += 1;
    [self selectLegalMove];
}

- (void)tap
{
    NSArray<BoardPiece *> *legalMoves = [self selectLegalMove];
    Player *player = self.match.currentPlayer;
    
    if (legalMoves.count != 0)
    {
        NSInteger index = [self normalizeIndex:legalMoves.count value:self.currentPos];
        
        BoardPosition *pos = legalMoves[index].position;
        PlayerMove *move = [PlayerMove makeMoveForColor:player.color position:pos];
        [self.match placeMove:move forPlayer:player];
    }
    else
    {
        PlayerMove *passMove = [PlayerMove makePassMoveForColor:player.color];
        [self.match placeMove:passMove forPlayer:player];
    }
    NSLog(@"tap");
}

- (NSInteger)normalizeIndex:(NSInteger)maxIndex value:(CGFloat)value
{
    NSInteger result = value;
    if (self.currentPos > maxIndex - 1)
    {
        result = 0;
    }
    
    if (self.currentPos < 0)
    {
        result = maxIndex - 1;
    }
    
    return result;
}

- (NSArray<BoardPiece *> *)selectLegalMove
{
    NSArray<BoardPiece *> *legalMoves = [self.match.board
                                         legalMovesForPlayerColor:self.match.currentPlayer.color];
    
    NSInteger countLegalMoves = legalMoves.count;
    NSInteger index = [self normalizeIndex:countLegalMoves value:self.currentPos];
    self.currentPos =index;
    
    if (countLegalMoves != 0)
    {
        BoardPosition *pos = legalMoves[index].position;
        self.match.board.highlightBlock(pos, PieceColorYellow);
    }
    
    return legalMoves;
}

@end
