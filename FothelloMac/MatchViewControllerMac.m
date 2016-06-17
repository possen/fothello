//
//  MatchViewControllerMac.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/16/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "MatchViewControllerMac.h"
#import "NewGameViewController.h"
#import "MovesViewController.h"
#import "BoardScene.h"
#import "Match.h"
#import "FothelloGame.h"
#import "BoardPosition.h"
#import "Player.h"
#import "PlayerMove.h"

@interface MatchViewControllerMac () <DismissDelegate>
@property (nonatomic) BoardScene *boardScene;
@property (nonatomic) NSInteger pageIndex;
@property (nonatomic) IBOutlet SKView *mainView;
@property (nonatomic) IBOutlet MovesViewController *movesController;
@property (nonatomic) BOOL canMove;
@end

@implementation MatchViewControllerMac

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    FothelloGame *game = [FothelloGame sharedInstance];
    
    NSAssert(game.matches.count != 0, @"matches empty");
    self.match = game.matches.allValues[0];

    [self resetGame];
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
        self.match = [[FothelloGame sharedInstance] createMatchFromKind:playerKind
                                                             difficulty:difficulty];
        
        [self resetGame];
    }
}

- (void)resetGame
{
    SKView *skView = self.mainView;
    self.boardScene.match = self.match;
    
    // Set the scale mode to scale to fit the window
    self.boardScene.scaleMode = SKSceneScaleModeAspectFit;

    // Create and configure the scene.
    BoardScene *scene = [[BoardScene alloc] initWithSize:skView.bounds.size match:self.match];
    self.boardScene = scene;
    
    __weak typeof(self) weakSelf = self;
      
    scene.updatePlayerMove = ^(BOOL canMove)
    {
        [weakSelf updateMove:canMove];
    };
    
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    
    [self.match restart];
    [self.match ready];
    [self.movesController resetGame:self.match];
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
    [self.match.currentPlayer makePassMove];
}

- (IBAction)resetGame:(id)sender
{
    [self.match restart];
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
        return !self.match.noMoves;
    }
    return YES;
}

@end
