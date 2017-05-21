//
//  PlayerDisplay.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/29/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#import "PlayerDisplay.h"
#import "Match.h"
#import "GameBoard.h"
#import "BoardScene.h"
#import "Piece.h"
#import "Strategy.h"
#import "PieceSprite.h"

@interface PlayerDisplay ()
@property (nonatomic) Match *match;
@property (nonatomic) BoardScene *boardScene;
@end

@implementation PlayerDisplay

- (instancetype)initWithMatch:(Match *)match boardScene:(BoardScene *)boardScene;
{
    self = [super init];
    if (self)
    {
        _match = match;
        _boardScene = boardScene;
    }
    return self;
}

- (void)addPlayerSprites
{
    BoardScene *boardScene = self.boardScene;

    Match *match = self.match;
    
    for (Player *player in match.players)
    {
        SKSpriteNode *playerSprite = [[SKSpriteNode alloc] init];
        CGSize size = CGSizeMake(30, 30);
        playerSprite.size = size;
        playerSprite.position = CGPointMake(CGRectGetMidX(boardScene.frame) - playerSprite.size.width / 2, -100);
        
        SKNode *pieceSprite = [boardScene.pieceSprite makePieceWithColor:player.color size:size];
        pieceSprite.name = @"piece";
        [playerSprite addChild:pieceSprite];
        
        SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:kMainFont];
        scoreLabel.name = @"score";
        scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)[match.board playerScore:player]];
        scoreLabel.fontSize = 14;
        scoreLabel.position = CGPointMake(15, -20);
        [playerSprite addChild:scoreLabel];
        
        SKLabelNode *playerLabel = [SKLabelNode labelNodeWithFontNamed:kMainFont];
        playerLabel.name = @"playerName";
        playerLabel.text = player.name;
        playerLabel.fontSize = 14;
        playerLabel.position = CGPointMake(15, -40);
        [playerSprite addChild:playerLabel];
        
        [boardScene addChild:playerSprite];
        player.userReference = playerSprite;
    }
}

- (void)displayPlayer:(Player *)player
{
    BoardScene *boardScene = self.boardScene;

    SKAction *fadeIn = [SKAction fadeAlphaTo:1 duration:1];
    SKAction *fadeOut = [SKAction fadeAlphaTo:0 duration:0];
    Match *match = self.match;
    boardScene.currentPlayerSprite = player.userReference;
    
    SKLabelNode *scoreLabel = (SKLabelNode *)[boardScene.currentPlayerSprite childNodeWithName:@"score"];
    scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)[match.board playerScore:player]];
    CGFloat homePos = boardScene.boardDimensions / 2;
    
    SKAction *action = [SKAction moveTo:CGPointMake(homePos, 100) duration:0];
    [boardScene.currentPlayerSprite runAction:[SKAction sequence:@[action]]];
    
    SKNode *piece = [boardScene.currentPlayerSprite childNodeWithName:@"piece"];
    
    if (player.strategy.automatic)
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

@end
