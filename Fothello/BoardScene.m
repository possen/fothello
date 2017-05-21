    //
//  MyScene.m
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


@interface BoardScene ()
@property (nonatomic) SKNode *prevHighlight;
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
        _boardDisplay = [[BoardDisplay alloc] initWithMatch:match boardScene:self];
        _playerDisplay = [[PlayerDisplay alloc] initWithMatch:match boardScene:self];
        [self setMatch:match];
    }
    return self;
}

- (void)setPiece:(NSArray<NSArray <BoardPiece *> *> *)pieceTracks
{
    NSArray<BoardPiece *> *boardPieces = [NSArray flatten:pieceTracks];
    
    for (BoardPiece *piece in boardPieces)
    {
        [self placeSpriteAtX:piece.position.x Y:piece.position.y withPiece:piece.piece];
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

// codebeat:disable(ABC, LINES_OF_CODE)
- (void)setMatch:(Match *)match
{
    _match = match;
    _boardSize = match.board.size;
    [self.boardDisplay drawBoard];
    __weak BoardScene *weakBlockSelf = self;

    // whenever a piece is placed on board calls back to here.
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
            [weakBlockSelf higlightAtX:pos.x y:pos.y color:color];
        });
    };
    
    [self syncronizeBoardStateWithModel];
    
    self.currentPlayerSprite = match.currentPlayer.userReference;
}
// codebeat:enable(ABC, LINES_OF_CODE)


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
         [self placeSpriteAtX:x Y:y withPiece:piece];
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
    CGFloat spacing = self.boardDimensions / boardSize;
    Match *match = self.match;
    
    CGFloat x = (rawx - origin.x) / spacing;
    CGFloat y = (rawy - origin.y) / spacing;
    
    if (x >= 0 && x < boardSize && y >= 0 && y < boardSize)
    {
        if (!match.turnProcessing) // don't allow move if other players are processing.
        {
            BoardPosition *boardPosition = [BoardPosition positionWithX:x y:y];
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

- (SKColor *)skColorFromPieceColor:(PieceColor)color
{
    static NSDictionary *colors = nil;
    
    colors = @{@(PieceColorNone)    : [SKColor clearColor],
               @(PieceColorWhite)   : [SKColor whiteColor],
               @(PieceColorBlack)   : [SKColor blackColor],
               @(PieceColorRed)     : [SKColor redColor],
               @(PieceColorBlue)    : [SKColor blueColor],
               @(PieceColorGreen)   : [SKColor greenColor],
               @(PieceColorYellow)  : [SKColor yellowColor],
               @(PieceColorLegal)   : [SKColor blackColor]};
    
    return colors[@(color)];
}

- (SKNode *)makePieceWithColor:(PieceColor)color size:(CGSize)size
{
    SKShapeNode *pieceSprite = [[SKShapeNode alloc] init];
    
    CGMutablePathRef myPath = CGPathCreateMutable();
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGPathAddEllipseInRect(myPath, NULL, rect);
    pieceSprite.path = myPath;
    CFRelease(myPath);
    
    pieceSprite.lineWidth = 1.0;
    pieceSprite.fillColor = [self skColorFromPieceColor:color];
    pieceSprite.strokeColor = [self skColorFromPieceColor:color];
    pieceSprite.glowWidth = 0.5;
    return pieceSprite;
}

- (void)movePieceTo:(BoardPosition *)pos
{
    CGPoint screenPos = [self calculateScreenPositionFromX:pos.x andY:pos.y sizeSmall:NO];
    SKAction *actionPos = [SKAction moveTo:screenPos duration:.5];
    SKAction *action = [SKAction sequence:@[actionPos]];
    [self.currentPlayerSprite runAction:action];
}

- (CGSize)calculateSpriteSizeWithSmallSize:(BOOL)sizeSmall
{
    CGFloat boardSize = self.boardSize;
    CGFloat spacing = self.boardDimensions / boardSize;
    CGSize spriteSize = CGSizeMake(spacing - 6.5, spacing - 6.5);

    if (sizeSmall) {
        spriteSize = CGSizeMake(spacing - spacing/1.5, spacing - spacing/1.5);
    }
    return spriteSize;
}

- (CGPoint)calculateScreenPositionFromX:(NSInteger)x andY:(NSInteger)y sizeSmall:(BOOL)sizeSmall
{
    CGRect boardRect = self.boardRect;
    CGFloat boardSize = self.boardSize;
    CGFloat spacing = self.boardDimensions / boardSize;
    CGSize spriteSize = [self calculateSpriteSizeWithSmallSize:sizeSmall];
    CGFloat originx = boardRect.origin.x; CGFloat originy = boardRect.origin.y;
    
    return CGPointMake(x * spacing + originx - spriteSize.width / 2 + spacing / 2,
                       y * spacing + originy - spriteSize.height / 2 + spacing / 2);
}

- (void)placeSpriteAtX:(NSInteger)x Y:(NSInteger)y withPiece:(Piece *)piece
{
    // remove the piece
    [piece.userReference removeFromParent];
    piece.userReference = nil;    
    
    if (piece.color == PieceColorNone) return;
    
    BOOL showLegalMoves = piece.color == PieceColorLegal;
    CGSize spriteSize = [self calculateSpriteSizeWithSmallSize:showLegalMoves];
    
    SKNode *sprite = [self makePieceWithColor:piece.color size:spriteSize];
    sprite.position = [self calculateScreenPositionFromX:x andY:y sizeSmall:showLegalMoves];
    sprite.alpha = 0.0;

    [self addChild:sprite];
    CGFloat finalAlpha = showLegalMoves ? .3 : 1.0;
    SKAction *action = [SKAction fadeAlphaTo:finalAlpha duration:.5];
    
    // All the animations should complete at about the same time but only want one
    // callback.
    [sprite runAction:action];
    piece.userReference = sprite;
}

- (void)higlightAtX:(NSInteger)x y:(NSInteger)y color:(PieceColor)color
{
    if (x < 0 || y < 0) return;
    
    CGSize spriteSize = [self calculateSpriteSizeWithSmallSize:NO];
    SKNode *sprite = [self makePieceWithColor:color size:spriteSize];
    sprite.position = [self calculateScreenPositionFromX:x andY:y sizeSmall:NO];
    sprite.alpha = 1.0;
    
    SKAction *action = [SKAction fadeAlphaTo:0 duration:.5];
    
    [self.prevHighlight removeFromParent];
    [self addChild:sprite];
    self.prevHighlight = sprite;
    
    [sprite runAction:action completion:^{
         [sprite removeFromParent];
     }];
}

@end
