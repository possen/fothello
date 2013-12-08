//
//  MyScene.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/11/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import "BoardScene.h"
#import "FothelloGame.h"

@implementation BoardScene

- (id)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    
    if (self)
    {
        _boardDimensions = MIN(size.width, size.height) - 40;
        _boardRect = CGRectMake(20, size.height / 2 - _boardDimensions / 2,
                                    _boardDimensions, _boardDimensions);
        
        _game = [FothelloGame sharedInstance];

        [self setupCurrentMatch];
        
        /* Setup your scene here */
        [self drawBoard];
        [self addPlayerSprites];
        [_game ready];
    }
    return self;
}

- (void)setupCurrentMatch
{
    Match *currentMatch = self.game.currentMatch;
    
    _boardSize = currentMatch.board.size;
    
    __weak BoardScene *weakBlockSelf = self;
    
    // whenever a piece is placed on board calls back to here.
    currentMatch.board.placeBlock =
    ^(NSInteger x, NSInteger y, Piece *piece)
    {
        [weakBlockSelf placeSpriteAtX:x Y:y withPiece:piece];
    };
    
    [self syncronizeBoardStateWithModel];
    
    currentMatch.currentPlayerBlock =
    ^(Player *player, BOOL canMove)
    {
        [weakBlockSelf displayCurrentPlayer:player];
        if (weakBlockSelf.updatePlayerMove)
            weakBlockSelf.updatePlayerMove(canMove);
    };
    
    currentMatch.matchStatusBlock = ^(BOOL gameOver)
    {
        if (gameOver)
            [weakBlockSelf displayGameOver];
    };
    
    self.currentPlayerSprite = currentMatch.currentPlayer.identifier;
}

- (void)teardownCurrentMatch
{    
    Match *currentMatch = self.game.currentMatch;
    currentMatch.board.placeBlock = nil;
    currentMatch.currentPlayerBlock = nil;
    self.currentPlayerSprite = nil;;
    [self removeGameOver];
}

- (void)syncronizeBoardStateWithModel
{
    FBoard *board = self.game.currentMatch.board;
    [board visitAll:^(NSInteger x, NSInteger y, Piece *piece)
     {
         [self placeSpriteAtX:x Y:y withPiece:piece];
     }];
}

- (void)displayGameOver
{
    Match *match = self.game.currentMatch;
    Player *player1 = match.players[0];
    Player *player2 = match.players[1];
    NSInteger score1 = [match calculateScore:player1];
    NSInteger score2 = [match calculateScore:player2];

    Player *winner = score1 > score2 ? player1 : player2;
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    myLabel.text = [NSString stringWithFormat:@"%@ Wins", winner.name];
    myLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    myLabel.fontSize = 32;
    myLabel.fontColor = [SKColor colorWithRed:0xff green:0 blue:0 alpha:.7];
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    SKAction *action = [SKAction fadeInWithDuration:.5];
    SKAction *action2 = [SKAction fadeOutWithDuration:.5];
    
    [myLabel runAction:[SKAction repeatAction:
                        [SKAction sequence:@[action, action2]] count:5]];
    [self addChild:myLabel];
    
    self.gameOverNode = myLabel;

    SKNode *playerNode1 =  player1.identifier;
    
    // assuming both player displays are same height
    NSInteger ypos = self.boardRect.origin.y + self.boardRect.size.height
                    + playerNode1.frame.size.height;
    
    SKNode *node1 = player1.identifier;
    SKNode *playerName1 = [playerNode1 childNodeWithName:@"playerName"];
    [playerName1 runAction:[SKAction fadeAlphaTo:0 duration:1]];
    [node1 runAction:
     [SKAction group:
        @[[SKAction moveToX:self.frame.size.width / 4 - playerNode1.frame.size.width/2 duration:1],
          [SKAction moveToY:ypos duration:1]]] ];

    SKNode *node2 = player2.identifier;
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
    Match *match = self.game.currentMatch;
    
    for (Player *player in match.players)
    {
        SKSpriteNode *node = player.identifier;
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
    [boardUI setStrokeColor:[UIColor whiteColor]];
    
    [self addChild:boardUI];
    
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

- (SKNode *)makePieceWithColor:(PieceColor)color size:(CGSize)size
{
    SKShapeNode *pieceSprite = [[SKShapeNode alloc] init];
    
    CGMutablePathRef myPath = CGPathCreateMutable();
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGPathAddEllipseInRect(myPath, NULL, rect);
    pieceSprite.path = myPath;
    
    pieceSprite.lineWidth = 1.0;
    pieceSprite.fillColor = color == PieceColorWhite ? [SKColor whiteColor] : [SKColor blackColor];
    pieceSprite.strokeColor = [SKColor lightGrayColor];
    pieceSprite.glowWidth = 0.5;
    return pieceSprite;
}

- (void)addPlayerSprites
{
    Match *match = self.game.currentMatch;
    
    for (Player *player in match.players)
    {
        SKSpriteNode *playerSprite = [[SKSpriteNode alloc] init];
        CGSize size = CGSizeMake(30, 30);
        playerSprite.size = size;
        playerSprite.position = CGPointMake(CGRectGetMidX(self.frame) - playerSprite.size.width / 2, -100);

        SKNode *pieceSprite = [self makePieceWithColor:player.color size:size];
        [playerSprite addChild:pieceSprite];
        
        SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        scoreLabel.name = @"score";
        scoreLabel.text = [NSString stringWithFormat:@"%d", [match calculateScore:player]];
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
        player.identifier = playerSprite;
    }
}

- (void)displayCurrentPlayer:(Player *)player
{
    Match *match = self.game.currentMatch;
    SKAction *action = [SKAction moveToY:-100 duration:.5];
         
    [self.currentPlayerSprite runAction:action];
    self.currentPlayerSprite = player.identifier;
    
    SKLabelNode *scoreLabel = (SKLabelNode *)[self.currentPlayerSprite childNodeWithName:@"score"];
    scoreLabel.text = [NSString stringWithFormat:@"%d", [match calculateScore:player]];
  
    action = [SKAction moveToY:60 duration:.5];
    [self.currentPlayerSprite runAction:action];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // ignore clicks if turn still processing. 
    if (self.turnProcessing && self.gameOverNode)
        return;
    
    /* Called when a touch begins */
    CGRect boardRect = self.boardRect;
    NSInteger boardSize = self.boardSize;
    NSInteger spacing = self.boardDimensions / self.boardSize;
    
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:self];
        
        NSInteger x = (location.x - boardRect.origin.x) / spacing;
        NSInteger y = (location.y - boardRect.origin.y) / spacing;
        
        if (x < boardSize && y < boardSize && !self.turnProcessing)
        {
            BOOL placed = [self.game takeTurnAtX:x Y:y];
            
            if (placed)
            {
                self.turnProcessing = YES;

                double delayInSeconds = .5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,
                                            (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(),
                               ^(void)
                {
                    [self.game processOtherTurnsX:x Y:y]; // x & y represent human player move
                    self.turnProcessing = NO;
                });
            }
        }
    }
}



- (void)placeSpriteAtX:(NSInteger)x Y:(NSInteger)y withPiece:(Piece *)piece
{
    CGRect boardRect = self.boardRect;
    NSInteger boardSize = self.boardSize;
    NSInteger spacing = self.boardDimensions / boardSize;
    
    //   NSLog(@"piece %d x:%d y:%d %@", piece.color, x, y, piece.identifier);

    [piece.identifier removeFromParent];
    piece.identifier = nil;    
    
    if (piece.color != PieceColorNone)
    {
        CGFloat finalAlpha = 1.0;

        CGSize spriteSize = CGSizeMake(spacing - 6.5, spacing - 6.5);
        if (piece.color == PieceColorLegal)
        {
            spriteSize = CGSizeMake(spacing - spacing/1.5, spacing - spacing/1.5);
            finalAlpha = .3;
        }
        SKNode *sprite = [self makePieceWithColor:piece.color size:spriteSize];
        sprite.alpha = 0.0;
     
        sprite.position
            = CGPointMake(x * spacing + boardRect.origin.x - spriteSize.width / 2 + spacing / 2,
                          y * spacing + boardRect.origin.y - spriteSize.height / 2 + spacing / 2);


        [self addChild:sprite];
        SKAction *action = [SKAction fadeAlphaTo:finalAlpha duration:.5];
        
        // All the animations should complete at about the same time but only want one
        // callback.
        [sprite runAction:action];
        piece.identifier = sprite;
    }
}


- (void)update:(CFTimeInterval)currentTime
{
    /* Called before each frame is rendered */
}

@end
