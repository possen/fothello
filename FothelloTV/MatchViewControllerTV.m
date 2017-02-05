//
//  GameViewController.m
//  FothelloTV
//
//  Created by Paul Ossenbruggen on 1/26/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import "MatchViewControllerTV.h"
#import "BoardScene.h"

@interface MatchViewController ()
@property (nonatomic) BoardScene *boardScene;
@end

@implementation MatchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load 'BoardScene.sks' as a GKScene. This provides gameplay related content
    // including entities and graphs.
    //   GKScene *scene = [GKScene sceneWithFileNamed:@"BoardScene"];
    CGSize size = CGSizeMake(310, 310);

    FothelloGame *game = [FothelloGame sharedInstance];
    self.match = [game createMatchFromKind:PlayerKindSelectionHumanVComputer difficulty:DifficultyEasy];
    
    // Create and configure the scene.
    BoardScene *scene = [[BoardScene alloc] initWithSize:size match:self.match];
    scene.match = self.match;
    self.boardScene = scene;

    __weak MatchViewController *weakSelf = self;
    scene.updatePlayerMove = ^(BOOL canMove)
    {
        [weakSelf updateMove:canMove];
    };

    // Get the SKScene from the loaded GKScene
//    BoardScene *sceneNode = (BoardScene *)scene.rootNode;
    
    // Set the scale mode to scale to fit the window
    scene.scaleMode = SKSceneScaleModeAspectFit;
    
    SKView *skView = (SKView *)self.view;
    
    // Present the scene
    [skView presentScene:scene];
    
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
}

- (void)updateMove:(BOOL)canMove
{
    //    self.pass.hidden = canMove;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
