 //
//  ViewController.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/11/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import "MatchViewControllerIOS.h"
#import "BoardScene+BoardScene_iOS.h"
#import "FothelloGame.h"
#import "DialogViewController.h"
#import "Match.h"
#import "Player.h"

@interface MatchViewControllerIOS ()

@end

@implementation MatchViewControllerIOS

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pass.hidden = YES;
   
    CGRect bounds = CGRectMake(0, 0, self.view.frame.size.width,  self.view.frame.size.height);
    
    // Create and configure the scene.
    BoardScene *scene = [[BoardScene alloc] initWithSize:bounds.size match:self.match];
    self.boardScene = scene;
    scene.match = self.match;

    __weak MatchViewControllerIOS *weakBlockSelf = self;
    scene.updatePlayerMove = ^(BOOL canMove)
    {
        [weakBlockSelf updateMove:canMove];
    };
    
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Configure the view.
    SKView *skView = (SKView *)self.mainScene;
    
    // Present the scene.
    [skView presentScene:scene];
  
    [self reset];
}

- (void)reset
{
    [self.match restart];
}

- (void)updateMove:(BOOL)canMove
{
    self.pass.hidden = canMove;
}

- (IBAction)unwindFromCancelForm:(UIStoryboardSegue *)segue
{
}

- (IBAction)unwindFromConfirmationForm:(UIStoryboardSegue *)segue
{
    DialogViewController *dvc = segue.sourceViewController;
    
    PlayerKindSelection kind = [dvc playerKindFromSelections];
    
    UISegmentedControl *difficultyControl = dvc.difficulty;
    Difficulty difficulty = [difficultyControl selectedSegmentIndex] + 1;
    
    FothelloGame *game = [FothelloGame sharedInstance];

    Match *match = [game createMatchFromKind:kind difficulty:difficulty];
    self.boardScene.match = match;
    self.match = match;
    
    [self reset];
}

- (BOOL)allowActionToRun
{
    return YES;
}

- (IBAction)pass:(UIButton *)sender
{
    [self.match.currentPlayer takeTurnPass];
}

- (IBAction)resetGame:(UIButton *)sender
{
    [self.match restart];
}

- (IBAction)hint:(UIButton *)sender
{
    [self.match.currentPlayer hint];
}

- (IBAction)undo:(UIButton *)sender
{
    [self.match undo];
}

- (IBAction)redo:(UIButton *)sender
{
    [self.match redo];
}

@end
