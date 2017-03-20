//
//  MatchViewControllerMac.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/16/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <FothelloLib/FothelloLib.h>
#import <GameKit/GameKit.h>

#import "MatchViewControllerMac.h"
#import "NewGameViewController.h"
#import "MovesViewController.h"
#import "BoardScene.h"
#import "AppDelegate.h"

@interface MatchViewControllerMac () <DismissDelegate, GKTurnBasedMatchmakerViewControllerDelegate>
@property (nonatomic) BoardScene *boardScene;
@property (nonatomic) NSInteger pageIndex;
@property (nonatomic) IBOutlet SKView *mainView;
@property (nonatomic) IBOutlet MovesViewController *movesController;
@property (nonatomic) BOOL canMove;
@property (nonatomic) NSViewController *authenticationController;

@end

@implementation MatchViewControllerMac

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)viewDidLoad
{
    [self authenticateLocalPlayer];
    
    [super viewDidLoad];

    FothelloGame *game = [FothelloGame sharedInstance];
    [game setupDefaultMatch:game.engine];
    
    NSAssert(game.matches.count != 0, @"matches empty");
    self.match = game.matches.allValues[0];

    SKView *skView = self.mainView;
  
    // Create and configure the scene.
    BoardScene *scene = [[BoardScene alloc] initWithSize:skView.bounds.size
                                                   match:self.match];
    
    //    BoardScene *scene = (BoardScene *)[SKScene nodeWithFileNamed:@"BoardScene"];
    self.boardScene = scene;
  
    __weak typeof(self) weakSelf = self;
    scene.updatePlayerMove = ^(BOOL canMove)
    {
        [weakSelf updateMove:canMove];
    };
    
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Set the scale mode to scale to fit the window
    self.boardScene.scaleMode = SKSceneScaleModeAspectFit;
    
    // Present the scene.
    [skView presentScene:scene];
    
    // do this after setting up scene otherwise we get an error sometimes modifiying an array while iterating.
    scene.match = self.match;

    [self reset];
}

- (void)authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    __weak GKLocalPlayer *weakLocalPlayer = localPlayer;
    
    localPlayer.authenticateHandler = ^(NSViewController *viewController, NSError *error){
        if (viewController != nil)
        {
            //showAuthenticationDialogWhenReasonable: is an example method name. Create your own method that displays an authentication view when appropriate for your app.
            [self showAuthenticationDialog:viewController];
        }
        else if (weakLocalPlayer.isAuthenticated)
        {
            //        [self authenticatedPlayer: localPlayer];
        }
        else
        {
            [self disableGameCenter];
        }
    };
}

- (void)showAuthenticationDialog:(NSViewController *)vc
{
    [self presentViewControllerAsSheet:vc];
    self.authenticationController = vc;
}

- (void)authenticatedPlayer:(GKLocalPlayer *)localPlayer
{
    
}

- (void)disableGameCenter
{
    
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"NewDocument"])
    {
        NewGameViewController *newGameVC = segue.destinationController;
        newGameVC.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"Moves"])
    {
        self.movesController = segue.destinationController;
        [self.movesController resetGame:self.match];
    }
}

- (void)dismissed:(BOOL)cancel playerKind:(PlayerKindSelection)playerKind difficulty:(Difficulty)difficulty
{
    if (!cancel)
    {
        if (playerKind == PlayerKindSelectionHumanVGameCenter)
        {
            [self createGameKitMatch];
        }
        else
        {
            self.match = [[FothelloGame sharedInstance] createMatchFromKind:playerKind
                                                                 difficulty:difficulty];
            self.boardScene.match = self.match;
            [self reset];
        }
    }
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
    
    GKTurnBasedMatchmakerViewController *vc
        = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:matchRequest];
    
    vc.turnBasedMatchmakerDelegate = self;
    GKDialogController *controller = [[GKDialogController alloc] init];
    [controller presentViewController:vc];
    
    //                     Player *player2 = [self newPlayerWithName:@"White" preferredPieceColor:PieceColorWhite];
    //                     player2.name = players[1]
    //                                [self setupMatch:@[player2, player1]];
    //}];

}



- (void)setMatch:(Match *)match
{
    [self.match reset]; // erase board
    _match = match;
    [self.match reset]; // setup board
}

- (void)reset
{
    [self.movesController resetGame:self.match];
    [self.match reset];
    [self.match beginMatch];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
}

- (void)restoreStateWithCoder:(NSCoder *)coder
{
    [super restoreStateWithCoder:coder];
}

- (void)updateMove:(BOOL)canMove
{
    self.canMove = canMove;
}

- (IBAction)newDocument:(id)sender
{
    [self performSegueWithIdentifier:@"NewDocument" sender:self];
}

- (IBAction)pass:(id)sender
{
    [self.match.currentPlayer takeTurnPass];
}

- (IBAction)resetGame:(id)sender
{
    [self reset];
}

- (IBAction)hint:(id)sender
{
    [self.match.currentPlayer hint];
}

- (IBAction)undo:(id)sender
{
    [self.match undo];
}

- (IBAction)redo:(id)sender
{
    [self.match redo];
}

- (BOOL)validateUserInterfaceItem:(NSMenuItem *)menuItem
{
    SEL theAction = [menuItem action];

    if (theAction == @selector(pass:))
    {
        return !self.canMove;
    }
    
    BOOL computersOnly = [self.match areAllPlayersComputers];
    
    if (theAction == @selector(redo:))
    {
        return self.match.redos.count != 0 && !computersOnly;
    }

    if (theAction == @selector(undo:))
    {
        return self.match.moves.count != 0 && !computersOnly;
    }

    if (theAction == @selector(hint:))
    {
        NSLog(@"hint %d", self.match.noMoves);
        return !self.match.noMoves;
    }
    
    return YES;
}

#pragma mark - GKTurnBasedMatchmakerViewControllerDelegate -

- (void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController
{
    [self.authenticationController dismissController:nil];
}

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController
                         didFailWithError:(NSError *)error
{
    [self.authenticationController dismissController:nil];
}

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController
                             didFindMatch:(GKTurnBasedMatch *)turnBasedMatch
{
    id<Engine>engine = [[FothelloGame sharedInstance] engine];
    //    Player *player1 = [self newPlayerWithName:@"Black" preferredPieceColor:PieceColorBlack];
    //   player1.name = player.displayName;
    [self.authenticationController dismissController:nil];
    
}

@end
