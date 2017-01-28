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

@interface InterfaceController() 

@property (strong, nonatomic) IBOutlet WKInterfaceSKScene *skInterface;
@property (nonatomic) BoardScene *boardScene;
@property (nonatomic) double currentPos;
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
    
    // Create and configure the scene.
    BoardScene *scene = [[BoardScene alloc] initWithSize:size match:self.match];
    scene.match = self.match;
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
    self.currentPos += rotationalDelta * 8;
    NSInteger x = (NSInteger)self.currentPos % 8;
    NSInteger y = (NSInteger)self.currentPos / 8;
    
    BoardPosition *pos = [BoardPosition positionWithX:x y:y];
    self.match.board.highlightBlock(pos, PieceColorYellow);
    NSLog(@"rotate %f", rotationalDelta);
}

- (IBAction)tapAction:(id)sender
{
    NSInteger x = (NSInteger)self.currentPos % 8;
    NSInteger y = (NSInteger)self.currentPos / 8;
    
    BoardPosition *pos = [BoardPosition positionWithX:x y:y];
    PlayerMove *move = [PlayerMove makeMoveForColor:self.match.currentPlayer.preferredPieceColor position:pos];
    [self.match.board placeMove:move forPlayer:self.match.currentPlayer];
    NSLog(@"tap");

}



@end



