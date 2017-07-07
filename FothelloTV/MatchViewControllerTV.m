//
//  GameViewController.m
//  FothelloTV
//
//  Created by Paul Ossenbruggen on 1/26/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import "MatchViewControllerTV.h"
#import "BoardScene.h"
#import "GestureSelection.h"

@interface MatchViewControllerTV ()
@property (nonatomic) BoardScene *boardScene;
@property (nonatomic) GestureSelection *gestureSelection;
@end

@implementation MatchViewControllerTV

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load 'BoardScene.sks' as a GKScene. This provides gameplay related content
    // including entities and graphs.
    //   GKScene *scene = [GKScene sceneWithFileNamed:@"BoardScene"];
    
    // Get the SKScene from the loaded GKScene
    //    BoardScene *sceneNode = (BoardScene *)scene.rootNode;
    CGSize size = CGSizeMake(310, 310);
    
    FothelloGame *game = [FothelloGame sharedInstance];
    game.engine = [EngineStrong engine];

    self.match = [game createMatchFromKind:PlayerKindSelectionHumanVComputer difficulty:DifficultyEasy];
    
    // Create and configure the scene.
    BoardScene *scene = [[BoardScene alloc] initWithSize:size match:self.match];
    self.boardScene = scene;
    
    __weak MatchViewControllerTV *weakSelf = self;
    scene.updatePlayerMove = ^(BOOL canMove)
    {
        [weakSelf updateMove:canMove];
    };
  
    // Set the scale mode to scale to fit the window
    scene.scaleMode = SKSceneScaleModeAspectFit;
    
    SKView *skView = (SKView *)self.view;
    
    // Present the scene
    [skView presentScene:scene];
    scene.match = self.match;
   
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    self.gestureSelection = [[GestureSelection alloc] initWithMatch:self.match];
    
    [self reset];
}


- (void)setMatch:(Match *)match
{
    [self.match reset]; // erase board
    _match = match;
    [self.match reset]; // setup board
}

- (void)reset
{
    [self.match reset];
    [self.match beginMatch];
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

- (IBAction)upAction:(id)sender
{
    [self.gestureSelection up];
}

- (IBAction)downAction:(id)sender
{
    [self.gestureSelection down];
}

- (IBAction)tapAction:(id)sender
{
    [self.gestureSelection tap];
}


@end
