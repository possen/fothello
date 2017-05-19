//
//  GameOverDisplay.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/29/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameOverDisplay.h"
#import "Match.h"
#import "GameBoard.h"
#import "BoardScene.h"
#import "Piece.h"

@interface GameOverDisplay ()
@property (nonatomic) Match *match;
@property (nonatomic) BoardScene *boardScene;
@end

@implementation GameOverDisplay

-(instancetype)initWithMatch:(Match *)match boardScene:(BoardScene *)boardScene
{
    self = [super init];
    if (self)
    {
        _match = match;
        _boardScene = boardScene;
    }
    return self;
}

- (void)displayScore
{
    BoardScene *boardScene = self.boardScene;
    Match *match = self.match;
    Player *player1 = match.players[0]; Player *player2 = match.players[1];
    NSInteger score1 = [match.board playerScore:player1];
    NSInteger score2 = [match.board playerScore:player2];
    
    Player *winner = score1 > score2 ? player1 : player2;
    
    SKLabelNode *winLabel = [SKLabelNode labelNodeWithFontNamed:kMainFont];
    
    winLabel.text = score1 == score2
        ? @"Tie"
        : [NSString stringWithFormat:NSLocalizedString(@"%@ Wins", @"user name"), winner.name];
    
    CGRect frame = self.boardScene.frame;
    winLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    winLabel.fontSize = 32;
    winLabel.fontColor = [SKColor colorWithRed:0xff green:0 blue:0 alpha:.7];
    winLabel.position = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    
    boardScene.gameOverNode = winLabel;
    [boardScene addChild:winLabel];
    SKAction *action = [SKAction fadeInWithDuration:.5];
    SKAction *action2 = [SKAction fadeOutWithDuration:.5];

    SKAction *runAction = [SKAction runBlock:^{
           [boardScene.boardUI runAction:[SKAction fadeAlphaTo:1 duration:.5]];
           [self fadePiecesTo:1];
       }];
    
    [winLabel runAction:[SKAction sequence:@[[SKAction repeatAction:
                                              [SKAction sequence:@[action, action2]] count:5],
                                             runAction]]];
}

- (void)fadePiecesTo:(NSInteger)value
{
    [self.match.board visitAll:^(NSInteger x, NSInteger y, Piece *piece)
     {
         SKNode *node = piece.userReference;
         [node runAction:[SKAction fadeAlphaTo:value duration:.5]];
     }];
}

- (void)animatePlayer:(Player *)player movePos:(NSInteger)pos
{
    BoardScene *boardScene = self.boardScene;
    SKNode *playerNode = player.userReference;

    SKNode *node1 = player.userReference;
    SKNode *playerName = [playerNode childNodeWithName:@"playerName"];
    [playerName runAction:[SKAction fadeAlphaTo:0 duration:1]];
    
    // assuming both player displays are same height
    NSInteger ypos = boardScene.boardRect.origin.y + boardScene.boardRect.size.height
        + playerNode.frame.size.height;
   
    [node1 runAction:
     [SKAction group:
      @[[SKAction moveToX:pos - playerNode.frame.size.width/2 duration:1],
        [SKAction moveToY:ypos duration:1]]] ];
}

- (void)present
{
    [self displayScore];

    BoardScene *boardScene = self.boardScene;
    Match *match = self.match;
    Player *player1 = match.players[0];
    Player *player2 = match.players[1];

    [boardScene.boardUI runAction:[SKAction fadeAlphaTo:.4 duration:.5]];
    CGFloat width = boardScene.frame.size.width;
    
    [self fadePiecesTo:.4];
    [self animatePlayer:player1 movePos:width / 4];
    [self animatePlayer:player2 movePos:width / 4 * 3];
}

- (void)dismiss
{
    BoardScene *boardScene = self.boardScene;

    [boardScene.gameOverNode removeFromParent];
    boardScene.gameOverNode = nil;
    Match *match = self.match;
    
    for (Player *player in match.players)
    {
        SKSpriteNode *node = player.userReference;
        node.position = CGPointMake(CGRectGetMidX(boardScene.frame) - node.size.width / 2, -100);
        SKNode *playerName = [node childNodeWithName:@"playerName"];
        [playerName runAction:[SKAction fadeAlphaTo:1 duration:1]];
    }
    boardScene.gameOverNode = nil;
}

@end
