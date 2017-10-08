    //
//  BoardScene.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/11/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import <FothelloLib/FothelloLib.h>
#import "BoardScene.h"
#import "NSArray+Extensions.h"
#import "GameOverDisplay.h"
#import "BoardDisplay.h"
#import "PlayerDisplay.h"
#import "PieceSprite.h"
#import "GameBoard.h"
#import "GameBoardInternal.h"

@interface BoardScene ()
@property (nonatomic) GameOverDisplay *gameOverDisplay;
@property (nonatomic) BoardDisplay *boardDisplay;
@property (nonatomic) PlayerDisplay *playerDisplay;
@end

@implementation BoardScene

- (instancetype)initWithSize:(CGSize)size match:(Match *)match
{
    self = [super initWithSize:size];
    
    if (self)
    {
        _match = match;
        _boardDimensions = MIN(size.width, size.height) - 40;
        _boardRect = CGRectMake(20, size.height / 2 - _boardDimensions / 2,
                                    _boardDimensions, _boardDimensions);
        _boardDisplay = [[BoardDisplay alloc] initWithMatch:match boardScene:self boardDimensions:_boardDimensions];
        _playerDisplay = [[PlayerDisplay alloc] initWithMatch:match boardScene:self];
        _boardSize = match.board.size;
        _spacing = _boardDimensions / _boardSize;
        _pieceSprite = [[PieceSprite alloc] initWithBoardScene:self];
        [self setMatch:match];
    }
    return self;
}

- (void)presentCommon:(UpdatePlayerMove)updateMove
{
    self.scaleMode = SKSceneScaleModeAspectFill;
    self.updatePlayerMove = updateMove;
    [self.match reset];
}

- (void)setPiece:(NSArray<NSArray <BoardPiece *> *> *)pieceTracks
{
    NSArray<BoardPiece *> *boardPieces = [NSArray flatten:pieceTracks];
    
    for (BoardPiece *piece in boardPieces)
    {
        [self.pieceSprite placeSpriteAtX:piece.position.x Y:piece.position.y withPiece:piece.piece];
    }
}

- (void)currentPlayerChange:(Player *)player canMove:(BOOL)canMove pass:(BOOL)pass
{
    [self.playerDisplay displayPlayer:player];
    if (self.updatePlayerMove) self.updatePlayerMove(canMove || self.gameOverNode);
    [self playerTurnComplete];
}

- (void)statusUpdate:(BOOL)gameOver
{
    if (gameOver)
    {
        FothelloGame *game = [FothelloGame sharedInstance];
        if (game.gameOverBlock) game.gameOverBlock();
        [self displayGameOver];
    }
    else
    {
        self.updatePlayerMove(NO);
        if (self.gameOverNode)
        {
            [self.gameOverDisplay dismiss];
            [self.playerDisplay displayPlayer:self.match.players[0]];
        }
    }
}

// codebeat:disable[ABC, LOC]
- (void)setMatch:(Match *)match
{
    _match = match;
    _boardSize = match.board.size;
    [self.boardDisplay drawBoard];
    __weak BoardScene *weakBlockSelf = self;

    match.board.placeBlock = ^(NSArray<NSArray <BoardPiece *> *> *pieceTracks) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakBlockSelf setPiece:pieceTracks];
        });
    };
    
    match.currentPlayerBlock = ^(Player *player, BOOL canMove, BOOL pass) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakBlockSelf currentPlayerChange:player canMove:canMove pass:pass];
       });
    };

    match.matchStatusBlock = ^(BOOL gameOver) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakBlockSelf statusUpdate:gameOver];
        });
    };
    
    match.board.highlightBlock = ^(BoardPosition *pos, PieceColor color) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakBlockSelf.pieceSprite higlightAtX:pos.x y:pos.y color:color];
        });
    };
    
    [self syncronizeBoardStateWithModel];
    self.currentPlayerSprite = match.currentPlayer.userReference;
}
// codebeat:enable[ABC, LOC]

- (void)teardownMatch
{
    Match *match = self.match;
    match.board.placeBlock = nil;
    match.currentPlayerBlock = nil;
    self.currentPlayerSprite = nil;;
    [self.gameOverDisplay dismiss];
}

- (void)syncronizeBoardStateWithModel
{
    GameBoard *board = self.match.board;
    [board visitAll:^(NSInteger x, NSInteger y, Piece *piece) {
         [self.pieceSprite placeSpriteAtX:x Y:y withPiece:piece];
    }];
}

- (void)locationX:(NSInteger)rawx Y:(NSInteger)rawy
{
    // ignore clicks if turn game over.
    if (self.gameOverNode) return;
    
    /* Called when a touch begins */
    CGRect boardRect = self.boardRect;
    CGPoint origin = boardRect.origin;
    CGFloat boardSize = self.boardSize;
    CGFloat spacing = self.spacing;
    Match *match = self.match;
    
    CGFloat x = (rawx - origin.x) / spacing; CGFloat y = (rawy - origin.y) / spacing;
    
    if (x >= 0 && x < boardSize && y >= 0 && y < boardSize)
    {
        if (!match.turnProcessing) // don't allow move if other players are processing.
        {
            BoardPosition *boardPosition = [BoardPosition positionWithX:x Y:y];
            [match.currentPlayer takeTurnAtPosition:boardPosition];
        }
    }
}

- (void)nextPlayer
{
    [self.match endTurn];
    [self.match nextPlayerWithTime:.5];
    [self.match beginTurn];
}

- (void)playerTurnComplete
{
    if (self.gameOverNode) return;
    [self nextPlayer];
}

- (void)displayGameOver
{
    if (self.gameOverNode) return;
    self.gameOverDisplay = [[GameOverDisplay alloc] initWithMatch:self.match boardScene:self];
}

@end
