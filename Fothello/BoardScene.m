//
//  MyScene.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/11/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import "FothelloGame.h"
#import "GameBoard.h"
#import "Player.h"
#import "Match.h"
#import "BoardScene.h"
#import "Strategy.h"

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
        [self setupMatch];
        
        /* Setup your scene here */
        [self drawBoard];
        [self addPlayerSprites];
    }
    return self;
}

- (void)setupMatch
{
    Match *match = self.match;
    _boardSize = match.board.size;
    
    __weak BoardScene *weakBlockSelf = self;

    // whenever a piece is placed on board calls back to here.
    match.board.placeBlock =
        ^(NSArray *piecePositions)
        {
            if (piecePositions.count == 0)
            {
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(),
            ^{
                for (BoardPiece *piecePosition in piecePositions)
                {
                    NSLog(@"piece %d x:%ld y:%ld", (int)piecePosition.piece.color, (long)piecePosition.position.x, (long)piecePosition.position.y);

                    [weakBlockSelf placeSpriteAtX:piecePosition.position.x
                                                Y:piecePosition.position.y
                                        withPiece:piecePosition.piece];
                }
            });
        };
    
    match.currentPlayerBlock =
        ^(Player *player, BOOL canMove)
        {
            dispatch_async(dispatch_get_main_queue(),
            ^{
                [weakBlockSelf displayCurrentPlayer:player];
                if (weakBlockSelf.updatePlayerMove)
                {
                    weakBlockSelf.updatePlayerMove(canMove || self.gameOverNode);
                }
            });
        };

    match.matchStatusBlock = ^(BOOL gameOver)
        {
            dispatch_async(dispatch_get_main_queue(),
            ^{
                if (gameOver)
                {
                    [weakBlockSelf displayGameOver];
                }
             });
        };
    
    match.highlightBlock = ^(NSInteger x, NSInteger y, PieceColor color)
    {
        [self higlightAtX:x y:y color:color];
    };
    
    [self syncronizeBoardStateWithModel];
    
    self.currentPlayerSprite = match.currentPlayer.userReference;    
}

- (void)startVsComputerGameIfSelected
{    
    if ([self.match isAnyPlayerAComputer])
    {
        [self.match processOtherTurns];
    }
}

- (void)teardownMatch
{    
    Match *match = self.match;
    match.board.placeBlock = nil;
    match.currentPlayerBlock = nil;
    self.currentPlayerSprite = nil;;
    [self removeGameOver];
}

- (void)syncronizeBoardStateWithModel
{
    GameBoard *board = self.match.board;
    [board visitAll:^(NSInteger x, NSInteger y, Piece *piece)
     {
         [self placeSpriteAtX:x Y:y withPiece:piece];
     }];
}

- (void)locationX:(NSInteger)rawx Y:(NSInteger)rawy
{
    // ignore clicks if turn still processing.
    if (self.match.turnProcessing || self.gameOverNode)
    {
        return;
    }
    
    /* Called when a touch begins */
    CGRect boardRect = self.boardRect;
    NSInteger boardSize = self.boardSize;
    NSInteger spacing = self.boardDimensions / self.boardSize;
    
    CGFloat x = (rawx - boardRect.origin.x) / spacing;
    CGFloat y = (rawy - boardRect.origin.y) / spacing;
    
    if (x >= 0 && x < boardSize && y >= 0 && y < boardSize &&
        !self.turnProcessing)
    {
        BOOL placed = [self.match takeTurnAtX:x Y:y pass:NO];
        
        if (placed)
        {
            [self.match processOtherTurns];
        }
    }
}

- (void)displayGameOver
{
    if (self.gameOverNode)
    {
        return;
    }
    
    Match *match = self.match;
    Player *player1 = match.players[0];
    Player *player2 = match.players[1];
    NSInteger score1 = [match calculateScore:player1];
    NSInteger score2 = [match calculateScore:player2];

    Player *winner = score1 > score2 ? player1 : player2;
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    myLabel.text = score1 == score2
                 ? @"Tie"
                 : [NSString stringWithFormat:NSLocalizedString(@"%@ Wins", @"user name"), winner.name];
    
    myLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    myLabel.fontSize = 32;
    myLabel.fontColor = [SKColor colorWithRed:0xff green:0 blue:0 alpha:.7];
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    SKAction *action = [SKAction fadeInWithDuration:.5];
    SKAction *action2 = [SKAction fadeOutWithDuration:.5];
    SKAction *runAction = [SKAction runBlock:
    ^{
        [self.boardUI runAction:[SKAction fadeAlphaTo:1 duration:.5]];
        
        [self.match.board visitAll:^(NSInteger x, NSInteger y, Piece *piece)
         {
             SKNode *node = piece.userReference;
             [node runAction:[SKAction fadeAlphaTo:1 duration:.5]];
         }];
    }];
    
    [myLabel runAction:[SKAction sequence:@[[SKAction repeatAction:
                        [SKAction sequence:@[action, action2]] count:5],
                                            runAction]]];
    [self addChild:myLabel];
    
    self.gameOverNode = myLabel;
    
    [self.boardUI runAction:[SKAction fadeAlphaTo:.4 duration:.5]];
    
    [self.match.board visitAll:^(NSInteger x, NSInteger y, Piece *piece)
    {
        SKNode *node = piece.userReference;
        [node runAction:[SKAction fadeAlphaTo:.4 duration:.5]];
    }];

    SKNode *playerNode1 =  player1.userReference;
    
    // assuming both player displays are same height
    NSInteger ypos = self.boardRect.origin.y + self.boardRect.size.height
                    + playerNode1.frame.size.height;
    
    SKNode *node1 = player1.userReference;
    SKNode *playerName1 = [playerNode1 childNodeWithName:@"playerName"];
    [playerName1 runAction:[SKAction fadeAlphaTo:0 duration:1]];
    
    [node1 runAction:
     [SKAction group:
        @[[SKAction moveToX:self.frame.size.width / 4 - playerNode1.frame.size.width/2 duration:1],
          [SKAction moveToY:ypos duration:1]]] ];

    SKNode *node2 = player2.userReference;
    SKNode *playerName2 = [node2 childNodeWithName:@"playerName"];
    [playerName2 runAction:[SKAction fadeAlphaTo:0 duration:1]];

    [node2 runAction:
     [SKAction group:
      @[[SKAction moveToX:self.frame.size.width / 4 * 3 - playerNode1.frame.size.width /2 duration:1],
        [SKAction moveToY:ypos duration:1]]] ];
}

- (void)removeGameOver
{
    [self.gameOverNode removeFromParent];
    self.gameOverNode = nil;
    Match *match = self.match;
    
    for (Player *player in match.players)
    {
        SKSpriteNode *node = player.userReference;
        node.position = CGPointMake(CGRectGetMidX(self.frame) - node.size.width / 2, -100);
        SKNode *playerName = [node childNodeWithName:@"playerName"];
        [playerName runAction:[SKAction fadeAlphaTo:1 duration:1]];
    }
    
    [self displayCurrentPlayer:match.players[0]];
}

- (void)drawBoard
{
    self.backgroundColor = [SKColor colorWithRed:.0 green:.70 blue:0.3 alpha:1.0];
    
    CGRect boardRect = self.boardRect;
    NSInteger boardDimensions = self.boardDimensions;
    SKShapeNode *boardUI = [SKShapeNode node];
    
    CGMutablePathRef pathToDraw = CGPathCreateMutable();
    CGPathMoveToPoint(pathToDraw, NULL, boardRect.origin.x, boardRect.origin.y);
    CGPathAddRect(pathToDraw, NULL, CGRectMake(boardRect.origin.x,
                                               boardRect.origin.y,
                                               boardRect.size.width,
                                               boardRect.size.height));
    
    NSInteger spacing = boardDimensions / _boardSize;
    for (NSInteger lines = 0; lines < boardDimensions; lines += spacing)
    {
        CGPathMoveToPoint(pathToDraw, NULL,
                          boardRect.origin.x,
                          boardRect.origin.y + lines);
        
        CGPathAddLineToPoint(pathToDraw, NULL,
                             boardRect.origin.x + boardRect.size.width,
                             boardRect.origin.y + lines);
        
        CGPathMoveToPoint(pathToDraw, NULL,
                          boardRect.origin.x + lines,
                          boardRect.origin.y);
        
        CGPathAddLineToPoint(pathToDraw, NULL,
                             boardRect.origin.x + lines,
                             boardRect.origin.y + boardRect.size.width);
    }
    
    boardUI.path = pathToDraw;
    [boardUI setStrokeColor:[SKColor whiteColor]];
    CFRelease(pathToDraw);
    [self addChild:boardUI];
    self.boardUI = boardUI;
    
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    myLabel.text = @"Fothello";
    myLabel.fontSize = 30;
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                   boardRect.origin.y
                                   + boardRect.size.height + 20 );

    SKAction *action = [SKAction fadeAlphaTo:0 duration:2];
    [myLabel runAction:action];

    [self addChild:myLabel];
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
    pieceSprite.strokeColor = [SKColor lightGrayColor];
    pieceSprite.glowWidth = 0.5;
    return pieceSprite;
}

- (void)addPlayerSprites
{
    Match *match = self.match;
    
    for (Player *player in match.players)
    {
        SKSpriteNode *playerSprite = [[SKSpriteNode alloc] init];
        CGSize size = CGSizeMake(30, 30);
        playerSprite.size = size;
        playerSprite.position = CGPointMake(CGRectGetMidX(self.frame) - playerSprite.size.width / 2, -100);

        SKNode *pieceSprite = [self makePieceWithColor:player.color size:size];
        pieceSprite.name = @"piece";
        [playerSprite addChild:pieceSprite];
        
        SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        scoreLabel.name = @"score";
        scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)[match calculateScore:player]];
        scoreLabel.fontSize = 14;
        scoreLabel.position = CGPointMake(15, -20);
        [playerSprite addChild:scoreLabel];

        SKLabelNode *playerLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        playerLabel.name = @"playerName";
        playerLabel.text = player.name;
        playerLabel.fontSize = 14;
        playerLabel.position = CGPointMake(15, -40);
        [playerSprite addChild:playerLabel];
        
        [self addChild:playerSprite];
        player.userReference = playerSprite;
    }
}

- (void)movePieceTo:(BoardPosition *)pos
{
    CGPoint screenPos = [self calculateScreenPositionFromX:pos.x andY:pos.y sizeSmall:NO];
    SKAction *actionPos = [SKAction moveTo:screenPos duration:.5];
    SKAction *action = [SKAction sequence:@[actionPos]];
    [self.currentPlayerSprite runAction:action];
}

- (void)displayCurrentPlayer:(Player *)player
{
    SKAction *fadeIn = [SKAction fadeAlphaTo:1 duration:1];
    SKAction *fadeOut = [SKAction fadeAlphaTo:0 duration:0];
    Match *match = self.match;
    self.currentPlayerSprite = player.userReference;
    
    SKLabelNode *scoreLabel = (SKLabelNode *)[self.currentPlayerSprite childNodeWithName:@"score"];
    scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)[match calculateScore:player]];
    NSInteger homePos = self.boardDimensions / 2;
 
     SKAction *action = [SKAction moveTo:CGPointMake(homePos, 100) duration:0];
    [self.currentPlayerSprite runAction:[SKAction sequence:@[action]]];
    
    SKNode *piece = [self.currentPlayerSprite childNodeWithName:@"piece"];
    
    if (!player.strategy.manual)
    {
        [piece runAction:
             [SKAction repeatActionForever:
             [SKAction sequence:@[fadeIn, fadeOut]]]];
    }
    else
    {
        [piece removeAllActions];
        [piece runAction:
         [SKAction fadeAlphaTo:1 duration:0]];
    }
}

- (CGSize)calculateSpriteSizeWithSmallSize:(BOOL)sizeSmall
{
    NSInteger boardSize = self.boardSize;
    NSInteger spacing = self.boardDimensions / boardSize;
    CGSize spriteSize = CGSizeMake(spacing - 6.5, spacing - 6.5);
    if (sizeSmall)
    {
        spriteSize = CGSizeMake(spacing - spacing/1.5, spacing - spacing/1.5);
    }
    return spriteSize;
}

- (CGPoint)calculateScreenPositionFromX:(NSInteger)x andY:(NSInteger)y sizeSmall:(BOOL)sizeSmall
{
    CGRect boardRect = self.boardRect;
    NSInteger boardSize = self.boardSize;
    NSInteger spacing = self.boardDimensions / boardSize;
    CGSize spriteSize = [self calculateSpriteSizeWithSmallSize:sizeSmall];
    
    return CGPointMake(x * spacing + boardRect.origin.x - spriteSize.width / 2 + spacing / 2,
                  y * spacing + boardRect.origin.y - spriteSize.height / 2 + spacing / 2);

}

- (void)placeSpriteAtX:(NSInteger)x Y:(NSInteger)y withPiece:(Piece *)piece
{
    [piece.userReference removeFromParent];
    piece.userReference = nil;    
    
    if (piece.color != PieceColorNone)
    {
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
}

- (void)higlightAtX:(NSInteger)x y:(NSInteger)y color:(PieceColor)color
{
    if (x < 0 || y < 0)
    {
        return;
    }
    
    CGSize spriteSize = [self calculateSpriteSizeWithSmallSize:NO];
    SKNode *sprite = [self makePieceWithColor:color size:spriteSize];
    sprite.position = [self calculateScreenPositionFromX:x andY:y sizeSmall:NO];
    sprite.alpha = 1.0;
    
    SKAction *action = [SKAction fadeAlphaTo:0 duration:.5];
 
    [self addChild:sprite];
    
    [sprite runAction:action completion:
     ^{
        [sprite removeFromParent];
    }];
}

@end
