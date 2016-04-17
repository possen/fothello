//
//  MatchViewControllerMac.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/16/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "MatchViewControllerMac.h"
#import <SpriteKit/SpriteKit.h>
#import "BoardScene.h"
#import "Match.h"

@interface MatchViewControllerMac ()
@property (nonatomic) IBOutlet SKView *mainScene;
@property (strong, nonatomic) BoardScene *boardScene;
@property (nonatomic) NSInteger pageIndex;
@property (nonatomic) Match *match;

@end

@implementation MatchViewControllerMac

- (void)viewDidLoad {
    [super viewDidLoad];
    SKView *skView = (SKView *)self.mainScene;
    self.boardScene.game.currentMatch = self.match;
//    /* Set the scale mode to scale to fit the window */
    self.boardScene.scaleMode = SKSceneScaleModeAspectFit;

//    self.pass.hidden = YES;
    
    // Create and configure the scene.
    BoardScene *scene = [BoardScene sceneWithSize:skView.bounds.size];
    self.boardScene = scene;
    
    __weak MatchViewControllerMac *weakBlockSelf = self;
    scene.updatePlayerMove = ^(BOOL canMove)
    {
 //       [weakBlockSelf updateMove:canMove];
    };
    
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
//    [self addAd];
    
    [self.boardScene.game ready];

}

@end
