 //
//  ViewController.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/11/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import <GameKit/GameKit.h>

#import "MatchViewControllerIOS.h"
#import "BoardScene+BoardScene_iOS.h"
#import "FothelloGame.h"
#import "DialogViewController.h"
#import "Match.h"
#import "Player.h"

@interface MatchViewControllerIOS () <GKTurnBasedMatchmakerViewControllerDelegate>
@property (nonatomic) UIViewController *authenticationController;
@property (nonatomic) GKTurnBasedMatchmakerViewController *turnedMatchMakerVC;
@end

@implementation MatchViewControllerIOS

- (void)viewDidLoad
{
    [self authenticateLocalPlayer];
    
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

- (void)authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    __weak GKLocalPlayer *weakLocalPlayer = localPlayer;
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil)
        {
            //showAuthenticationDialogWhenReasonable: is an example method name. Create your own method that displays an authentication view when appropriate for your app.
            [self showAuthenticationDialog: viewController];
        }
        else if (weakLocalPlayer.isAuthenticated)
        {
            //authenticatedPlayer: is an example method name. Create your own method that is called after the local player is authenticated.
            [self authenticatedPlayer: weakLocalPlayer];
        }
        else
        {
            [self disableGameCenter];
        }
    };
}



- (void)showAuthenticationDialog:(UIViewController *)vc
{
    [self presentViewController:vc animated:YES completion:nil];
    self.authenticationController = vc;
}

- (void)authenticatedPlayer:(GKLocalPlayer *)localPlayer
{
    
}

- (void)disableGameCenter
{
    
}

- (void)createGameKitMatch
{
    //    NSAssert(error == nil, @"error %@", error);
    
    GKMatchRequest *matchRequest = [[GKMatchRequest alloc] init];
    matchRequest.minPlayers = 2;
    matchRequest.maxPlayers = 2;
    matchRequest.defaultNumberOfPlayers = 2;
    matchRequest.inviteMessage = @"Please play Fothello with me!"; // TODO: customize
    
    matchRequest.playerAttributes
        = PieceColorBlack
        ? 0xFFFF0000
        : 0x0000FFFF;
    
    self.turnedMatchMakerVC = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:matchRequest];
    
    self.turnedMatchMakerVC.turnBasedMatchmakerDelegate = self;
    [self presentViewController:self.turnedMatchMakerVC animated:YES completion:nil];
    
    //                     Player *player2 = [self newPlayerWithName:@"White" preferredPieceColor:PieceColorWhite];
    //                     player2.name = players[1]
    //                                [self setupMatch:@[player2, player1]];
    //}];
    
}

- (void)reset
{
    [self.match reset];
    [self.match beginMatch];
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
    
    if (kind == PlayerKindSelectionHumanVGameCenter)
    {
        [self createGameKitMatch];
    }
    
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
    [self reset];
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


#pragma mark - GKTurnBasedMatchmakerViewControllerDelegate -

- (void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController
{
    [self.turnedMatchMakerVC dismissViewControllerAnimated:YES completion:nil];
}

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController
                         didFailWithError:(NSError *)error
{
    [self.turnedMatchMakerVC dismissViewControllerAnimated:YES completion:nil];
}

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController
                             didFindMatch:(GKTurnBasedMatch *)turnBasedMatch
{
    id<Engine>engine = [[FothelloGame sharedInstance] engine];
    //    Player *player1 = [self newPlayerWithName:@"Black" preferredPieceColor:PieceColorBlack];
    //   player1.name = player.displayName;
    [self.turnedMatchMakerVC dismissViewControllerAnimated:YES completion:nil];
    
}


@end
