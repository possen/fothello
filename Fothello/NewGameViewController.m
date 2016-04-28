//
//  NewGameViewController.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/26/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "NewGameViewController.h"
#import "Match.h"
#import "Strategy.h"
#import "Player.h"
#import "FothelloGame.h"
#import "MatchViewControllerMac.h"

@interface NewGameViewController ()
@property (weak) IBOutlet NSPopUpButton *difficultyButton;
@property (weak) IBOutlet NSTextField *difficultyLabel;
@property (weak) IBOutlet NSPopUpButton *playerKinds;
@end

typedef NS_ENUM(NSInteger, PlayerKindSelection)
{
    PlayerKindSelectionHumanVHuman,
    PlayerKindSelectionHumanVComputer,
    PlayerKindSelectionComputerVHuman,
    PlayerKindSelectionComputerVComputer,
    PlayerKindSelectionHumanVGameCenter
};

@implementation NewGameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateMenu:self.playerKinds.selectedItem];
}

- (IBAction)playerKindAction:(NSPopUpButton *)sender
{
    NSMenuItem *item = sender.selectedItem;
    [self updateMenu:item];
}

- (void)updateMenu:(NSMenuItem *)item
{
    BOOL computerMatch = (item.tag ==  PlayerKindSelectionHumanVHuman || item.tag == PlayerKindSelectionHumanVGameCenter);
    
    self.difficultyLabel.hidden = computerMatch;
    self.difficultyButton.hidden = computerMatch;
}
- (IBAction)dismissController:(id)sender
{
    [super dismissController:sender];

    FothelloGame *game = [FothelloGame sharedInstance];

    Player *player1;
    Player *player2;
    
    Class player1StrategyClass;
    Class player2StrategyClass;
    
    switch (self.playerKinds.selectedItem.tag)
    {
        case PlayerKindSelectionHumanVHuman:
            player1 = [game newPlayerWithName:@"Human 1" preferredPieceColor:PieceColorWhite];
            player2 = [game newPlayerWithName:@"Human 2" preferredPieceColor:PieceColorBlack];
            player1StrategyClass = [HumanStrategy class];
            player2StrategyClass = [HumanStrategy class];
            break;
        case PlayerKindSelectionHumanVComputer:
            player1 = [game newPlayerWithName:@"Human" preferredPieceColor:PieceColorWhite];
            player2 = [game newPlayerWithName:@"Computer" preferredPieceColor:PieceColorBlack];
            player1StrategyClass = [HumanStrategy class];
            player2StrategyClass = [AIStrategy class];
            break;
        case PlayerKindSelectionComputerVHuman:
            player1 = [game newPlayerWithName:@"Computer" preferredPieceColor:PieceColorWhite];
            player2 = [game newPlayerWithName:@"Human" preferredPieceColor:PieceColorBlack];
            player1StrategyClass = [AIStrategy class];
            player2StrategyClass = [HumanStrategy class];
            break;
        case PlayerKindSelectionComputerVComputer:
            player1 = [game newPlayerWithName:@"Computer 1" preferredPieceColor:PieceColorWhite];
            player2 = [game newPlayerWithName:@"Computer 2" preferredPieceColor:PieceColorBlack];
            player1StrategyClass = [AIStrategy class];
            player2StrategyClass = [AIStrategy class];
            break;
        case PlayerKindSelectionHumanVGameCenter:
            break;
        default:
            NSAssert(false, @"cant find kind");
    }
    
    Match *match = [[Match alloc] initWithName:@"game" players:@[player1, player2] difficulty:self.difficultyButton.selectedItem.tag];
    player1.strategy = [[player1StrategyClass alloc] initWithMatch:match];
    player2.strategy = [[player2StrategyClass alloc] initWithMatch:match];
    MatchViewControllerMac *parent = (MatchViewControllerMac *)self.presentingViewController;
    parent.match = match;
    [parent resetGame];
    [self.delegate dismissed];
}
@end
