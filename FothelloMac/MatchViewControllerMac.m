//
//  MatchViewControllerMac.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/16/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <FothelloLib/FothelloLib.h>

#import "MatchViewControllerMac.h"
#import "NewGameViewController.h"
#import "MovesViewController.h"
#import "BoardScene+Mac.h"
#import "AppDelegate.h"
#import "GameBoard.h"
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
    game.engine = [EngineStrong engine];
    Match *match = [game setupDefaultMatch];
    self.match = match;
    SKView *skView = self.mainView;
  
    BoardScene *boardScene = [[BoardScene alloc] initWithSize:skView.bounds.size match:match];
    self.boardScene = boardScene;
    
    NSAssert(game.matches.count != 0, @"matches empty");
    self.match = game.matches.allValues[0];
    
    [boardScene presentWithView:skView updatePlayerMove:^(BOOL canMove) {
        self.canMove = canMove;
    }];
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
        self.boardScene.match = self.match;
        [self reset];
    }
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
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
}

- (void)restoreStateWithCoder:(NSCoder *)coder
{
    [super restoreStateWithCoder:coder];
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
    [self.match.matchMoves undo];
}

- (IBAction)redo:(id)sender
{
    [self.match.matchMoves redo];
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
        return self.match.matchMoves.redos.count != 0 && !computersOnly;
    }

    if (theAction == @selector(undo:))
    {
        return self.match.matchMoves.moves.count != 0 && !computersOnly;
    }

    if (theAction == @selector(hint:))
    {
        NSLog(@"hint %d", self.match.noMoves);
        return !self.match.noMoves;
    }
    
    return YES;
}

@end
