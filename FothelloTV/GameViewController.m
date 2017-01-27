//
//  GameViewController.m
//  FothelloTV
//
//  Created by Paul Ossenbruggen on 1/26/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import "GameViewController.h"
#import "GameBoard.h"

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
//    // including entities and graphs.
//    GKScene *scene = [GKScene sceneWithFileNamed:@"GameScene"];
//    
//    // Get the SKScene from the loaded GKScene
//    GameScene *sceneNode = (GameScene *)scene.rootNode;
//    
//    // Copy gameplay related content over to the scene
//    sceneNode.entities = [scene.entities mutableCopy];
//    sceneNode.graphs = [scene.graphs mutableCopy];
//    
//    // Set the scale mode to scale to fit the window
//    sceneNode.scaleMode = SKSceneScaleModeAspectFill;
//    
//    SKView *skView = (SKView *)self.view;
//    
//    // Present the scene
//    [skView presentScene:sceneNode];
//    
//    skView.showsFPS = YES;
//    skView.showsNodeCount = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
