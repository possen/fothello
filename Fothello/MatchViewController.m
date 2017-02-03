 //
//  ViewController.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/11/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import "MatchViewController.h"
#import "BoardScene+BoardScene_iOS.h"
#import "FothelloGame.h"
#import "DialogViewController.h"
#import "Match.h"
#import "Player.h"

@interface MatchViewController ()

// contentView's vertical bottom constraint, used to alter the contentView's vertical size when ads arrive
@property (nonatomic) BOOL notFirstTime;

@end

@implementation MatchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView *skView = (SKView *)self.mainScene;
    
    self.pass.hidden = YES;
    
 //   CGRect bounds = skView.bounds;
    
    CGRect bounds = CGRectMake(0, 0, self.view.frame.size.width,  self.view.frame.size.height);
    
    // Create and configure the scene.
    BoardScene *scene = [[BoardScene alloc] initWithSize:bounds.size match:self.match];
    self.boardScene = scene;
 
    __weak MatchViewController *weakBlockSelf = self;
    scene.updatePlayerMove = ^(BOOL canMove)
    {
        [weakBlockSelf updateMove:canMove];
    };

    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];

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

    [self.boardScene teardownMatch];

    Match *match = [game createMatchFromKind:kind difficulty:difficulty];
    self.match = match;
    self.boardScene.match = match;
    
    [self.boardScene setupMatch];
    
    [self.match restart];
    [self.boardScene nextPlayer];
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
