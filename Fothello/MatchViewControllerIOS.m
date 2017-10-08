                                           //
//  ViewController.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/11/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import "MatchViewControllerIOS.h"
#import "BoardScene+iOS.h"
#import "FothelloGame.h"
#import "DialogViewController.h"
#import "Match.h"
#import "MatchMoves.h"
#import "Player.h"
#import "EngineStrong.h"
#import "GestureSelection.h"

@interface MatchViewControllerIOS () 
@property (nonatomic) GestureSelection *gestureSelection;
@end

@implementation MatchViewControllerIOS

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pass.hidden = YES;
    
    // Create and configure the scene.
    FothelloGame *game = [FothelloGame sharedInstance];    
    Match *match = [game setupDefaultMatch];
    self.match = match;
    CGSize size = self.view.bounds.size;
    BoardScene *boardScene = [[BoardScene alloc] initWithSize:size match:self.match];
    self.boardScene = boardScene;
    
    [boardScene presentWithView:self.mainScene updatePlayerMove:^(BOOL canMove) {
        self.pass.hidden = canMove;
    }];
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
    
    [self.match reset];
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
    [self.match reset];
}

- (IBAction)hint:(UIButton *)sender
{
    [self.match.currentPlayer hint];
}

- (IBAction)undo:(UIButton *)sender
{
    [self.match.matchMoves undo];
}

- (IBAction)redo:(UIButton *)sender
{
    [self.match.matchMoves redo];
}

@end
