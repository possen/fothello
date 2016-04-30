//
//  DialogViewController.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/23/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import "DialogViewController.h"
#import "FothelloGame.h"
#import "Match.h"

@interface DialogViewController ()
@property (weak, nonatomic) IBOutlet UILabel *difficultyLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *youPlayerType;
@property (weak, nonatomic) IBOutlet UISegmentedControl *opponentPlayerType;
@end

@implementation DialogViewController

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];

    [coder encodeInteger:[self.youPlayerType selectedSegmentIndex] + 1 forKey:@"playerType"];
    [coder encodeInteger:[self.opponentPlayerType selectedSegmentIndex] + 1 forKey:@"opponentPlayerType"];
    [coder encodeInteger:[self.difficulty selectedSegmentIndex] + 1 forKey:@"difficulty"];
    NSLog(@"saving state");
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    [self.youPlayerType setSelectedSegmentIndex:[coder decodeIntegerForKey:@"playerType"] - 1 ];
    [self.opponentPlayerType setSelectedSegmentIndex:[coder decodeIntegerForKey:@"opponentPlayerType"] - 1];
    [self.difficulty setSelectedSegmentIndex:[coder decodeIntegerForKey:@"difficulty"] - 1];
    [self updateControls];
    NSLog(@"restoring state");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    PlayerKindSelection playerKind = [prefs integerForKey:@"playerKind"];
    Difficulty difficulty = [prefs integerForKey:@"difficulty"];

    [self playerKindToSelections:playerKind];
    [self.difficulty setSelectedSegmentIndex:difficulty - 1];
    [self updateControls];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:[self playerKindFromSelections] forKey:@"playerKind"];
    [prefs setInteger:self.difficulty.selectedSegmentIndex + 1 forKey:@"difficulty"];
    [prefs synchronize];
}

- (PlayerKindSelection)playerKindFromSelections
{
    NSInteger youKind = self.youPlayerType.selectedSegmentIndex;
    NSInteger opponentKind = self.opponentPlayerType.selectedSegmentIndex;
    return youKind | opponentKind << 1;
}

- (void)playerKindToSelections:(PlayerKindSelection)kind
{
    NSInteger youSelection = kind & 1;
    NSInteger opponentSelection = (kind & 6) >> 1;
    
    self.youPlayerType.selectedSegmentIndex = youSelection;
    self.opponentPlayerType.selectedSegmentIndex = opponentSelection;
}

- (void)updateControls
{
    PlayerKindSelection kind = [self playerKindFromSelections];
    BOOL notComputerMatch = (kind == PlayerKindSelectionHumanVHuman
                          || kind == PlayerKindSelectionHumanVGameCenter);
    
    self.difficulty.hidden = notComputerMatch;
    self.difficultyLabel.hidden = notComputerMatch;
}

- (IBAction)againstAction:(UISegmentedControl *)sender
{
    [self updateControls];
}

- (IBAction)youAction:(UISegmentedControl *)sender
{
    [self updateControls];
}

- (IBAction)difficultyAction:(UISegmentedControl *)sender
{
    [self updateControls];
}

@end
