//
//  InterfaceController.m
//  FothelloWatch Extension
//
//  Created by Paul Ossenbruggen on 6/14/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "InterfaceController.h"
#import "GameScene.h"
#import "BoardScene.h"
#import "FothelloGame.h"

@interface InterfaceController()

@property (strong, nonatomic) IBOutlet WKInterfaceSKScene *skInterface;
@property (nonatomic) BoardScene *boardScene;
@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];

//    SKView *skView = (SKView *)self.mainScene;
    //    skView.showsFPS = YES;
    //skView.showsNodeCount = YES;
    
    // Load the SKScene from 'GameScene.sks'
//    BoardScene *scene = [BoardScene nodeWithFileNamed:@"GameScene"];
    CGSize size = CGSizeMake(300, 300);
//    self.pass.hidden = YES;
    
    FothelloGame *game = [FothelloGame sharedInstance];
    Match *match = [game createMatchFromKind:PlayerKindSelectionHumanVComputer difficulty:DifficultyEasy];
 
    // Create and configure the scene.
    BoardScene *scene = [[BoardScene alloc] initWithSize:size match:match];
    scene.match = match;
    self.boardScene = scene;
    
    
//    __weak InterfaceController *weakBlockSelf = self;
//    scene.updatePlayerMove = ^(BOOL canMove)
//    {
//        [weakBlockSelf updateMove:canMove];
//    };
    
    // Set the scale mode to scale to fit the window
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene
    [self.skInterface presentScene:scene];
    
    // Use a value that will maintain consistent frame rate
    self.skInterface.preferredFramesPerSecond = 30;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



