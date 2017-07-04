//
//  InterfaceController.m
//  FothelloWatch Extension
//
//  Created by Paul Ossenbruggen on 6/14/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <FothelloLib/FothelloLib.h>

#import "InterfaceController.h"
#import "BoardScene.h"
#import "GameBoard.h"
#import "Match.h"
#import "GestureSelection.h"

@interface InterfaceController() 

@property (strong, nonatomic) IBOutlet WKInterfaceSKScene *skInterface;
@property (nonatomic) BoardScene *boardScene;
@property (nonatomic) GestureSelection *gestureSelecton;
@end


@implementation InterfaceController 

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];

//    SKView *skView = (SKView *)self.mainScene;
    //    skView.showsFPS = YES;
    //skView.showsNodeCount = YES;
    
    // Load the SKScene from 'BoardScene.sks'
//    BoardScene *scene = [BoardScene nodeWithFileNamed:@"BoardScene"];
    CGSize size = CGSizeMake(310, 310);
//    self.pass.hidden = YES;
    
    self.crownSequencer.delegate = self;
    [self.crownSequencer focus];

    FothelloGame *game = [FothelloGame sharedInstance];
    
    self.match = [game createMatchFromKind:PlayerKindSelectionHumanVComputer difficulty:DifficultyEasy];
    
    game.engine = [EngineWatch engine];    
    [game setupDefaultMatch:game.engine];
    
    // Create and configure the scene.
    BoardScene *scene = [[BoardScene alloc] initWithSize:size match:self.match];
    self.boardScene = scene;
    
    __weak InterfaceController *weakBlockSelf = self;
    scene.updatePlayerMove = ^(BOOL canMove)
    {
        [weakBlockSelf updateMove:canMove];
    };
    
    // Set the scale mode to scale to fit the window
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene
    [self.skInterface presentScene:scene];
    
    scene.match = self.match;
   
    // Use a value that will maintain consistent frame rate
    self.skInterface.preferredFramesPerSecond = 30;
    
    self.gestureSelecton = [[GestureSelection alloc] init];
    
    [self reset];
}

- (void)updateMove:(BOOL)canMove
{
    //x`    self.pass.hidden = canMove;
}

- (void)reset
{
    [self.match reset];
    [self.match beginMatch];
}

- (void)setMatch:(Match *)match
{
    [self.match reset]; // erase board
    _match = match;
    [self.match reset]; // setup board
}

- (void)willActivate
{
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate
{
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)crownDidRotate:(WKCrownSequencer *)crownSequencer rotationalDelta:(double)rotationalDelta
{
    self.gestureSelecton.currentPos += rotationalDelta;
    [self.gestureSelecton selectLegalMove];
}


- (IBAction)upAction:(id)sender
{
    [self.gestureSelecton up];
}

- (IBAction)downAction:(id)sender
{
    [self.gestureSelecton down];
}

- (IBAction)tapAction:(id)sender
{
    [self.gestureSelecton tap];
}

@end



