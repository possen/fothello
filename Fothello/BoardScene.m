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
        Match *currentMatch = self.game.currentMatch;

        _boardSize = currentMatch.board.size;
        
        __weak BoardScene *weakBlockSelf = self;
        
        // whenever a piece is placed on board calls back to here.
        _game.currentMatch.board.placeBlock =
            ^(NSInteger x, NSInteger y, Piece *piece)
            {
                [weakBlockSelf placeSpriteAtX:x Y:y withPiece:piece];
            };
        
        [self syncronizeBoardStateWithModel];

        _game.currentMatch.currentPlayerBlock =
            ^(Player *player)
            {
                [weakBlockSelf displayCurrentPlayer:player];
            };
        

        /* Setup your scene here */
        [self drawBoard];
        [self addPlayerSprites];
        self.currentPlayerSprite = currentMatch.currentPlayer.identifier;
        [_game ready];
    }
    return self;
}

- (void)syncronizeBoardStateWithModel
{
    Board *board = self.game.currentMatch.board;
    [board visitAll:^(NSInteger x, NSInteger y, Piece *piece)
     {
         [self placeSpriteAtX:x Y:y withPiece:piece];
     }];
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

    [self addChild:myLabel];
}

- (void)addPlayerSprites
{
    Match *match = self.game.currentMatch;
    
    for (Player *player in match.players)
    {
        SKSpriteNode *playerSprite = [[SKSpriteNode alloc] init];
        playerSprite.position = CGPointMake(CGRectGetMidX(self.frame), -100);
        playerSprite.size = CGSizeMake(40, 30);

        NSString *filename = [self pieceColorToFileName:player.color];
        SKSpriteNode *pieceSprite = [[SKSpriteNode alloc] initWithImageNamed:filename];
        pieceSprite.size = CGSizeMake(30, 30);
        [playerSprite addChild:pieceSprite];
        
        SKLabelNode *playerLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        playerLabel.text = player.name;
        playerLabel.fontSize = 14;
        playerLabel.position = CGPointMake(0, -40);
        [playerSprite addChild:playerLabel];
        
        [self addChild:playerSprite];
        player.identifier = playerSprite;
    }
}

- (void)displayCurrentPlayer:(Player *)player
{
    SKAction *action = [SKAction moveToY:-100 duration:.5];
         
    [self.currentPlayerSprite runAction:action];
    self.currentPlayerSprite = player.identifier;
  
    action = [SKAction moveToY:60 duration:.5];

    [self.currentPlayerSprite runAction:action];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // ignore clicks if turn still processing. 
    if (self.turnProcessing)
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
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                {
                    [self.game processOtherTurns];
                    self.turnProcessing = NO;
                });
            }
        }
    }
}

- (NSString *)pieceColorToFileName:(PieceColor)color
{
    switch (color)
    {
        case PieceColorBlack:
            return @"violet-sphere";
        case PieceColorWhite:
            return @"green-sphere";
        case PieceColorLegal:
            return @"GrayDot";
        default:
            break;
    }
    return nil;
}


- (void)placeSpriteAtX:(NSInteger)x Y:(NSInteger)y withPiece:(Piece *)piece
{
    CGRect boardRect = self.boardRect;
    NSInteger boardSize = self.boardSize;
    NSInteger spacing = self.boardDimensions / boardSize;
    
    [piece.identifier removeFromParent];
    piece.identifier = nil;
    
    if (piece.color != PieceColorNone)
    {
        NSString *filename = [self pieceColorToFileName:piece.color];
        CGSize spriteSize = CGSizeMake(spacing - 5, spacing - 5);
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:filename];
        sprite.alpha = 0.0;
     
        sprite.position
            = CGPointMake(x * spacing + boardRect.origin.x + spriteSize.width / 2 + 3,
                          y * spacing + boardRect.origin.y + spriteSize.height / 2 + 2);

        CGFloat finalAlpha = 1.0;
        if (piece.color == PieceColorLegal)
        {
            spriteSize = CGSizeMake(spacing - 10, spacing - 10);
            finalAlpha = .3;
        }

        sprite.size = spriteSize;
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
