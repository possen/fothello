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
@property (weak, nonatomic) IBOutlet NSPopUpButton *difficultyButton;
@property (weak, nonatomic) IBOutlet NSTextField *difficultyLabel;
@property (weak, nonatomic) IBOutlet NSPopUpButton *playerKinds;
@property (weak, nonatomic) IBOutlet NSButton *cancelButton;
@property (weak, nonatomic) IBOutlet NSButton *okButton;
@end

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
    BOOL notComputerMatch = (item.tag ==  PlayerKindSelectionHumanVHuman || item.tag == PlayerKindSelectionHumanVGameCenter);
    
    self.difficultyLabel.hidden = notComputerMatch;
    self.difficultyButton.hidden = notComputerMatch;
}

- (IBAction)dismissController:(id)sender
{
    [super dismissController:sender];    

    [self.delegate dismissed:sender == self.cancelButton
                  playerKind:self.playerKinds.selectedTag
                  difficulty:self.difficultyButton.selectedTag];
}
@end
