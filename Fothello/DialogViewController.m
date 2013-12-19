//
//  DialogViewController.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/23/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import "DialogViewController.h"
#import "FothelloGame.h"

@interface DialogViewController ()

@end

@implementation DialogViewController

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];

    [coder encodeInteger:[self.playerType selectedSegmentIndex] + 1 forKey:@"playerType"];
    [coder encodeInteger:[self.humanPlayerColor selectedSegmentIndex] + 1 forKey:@"humanColor"];
    [coder encodeInteger:[self.difficulty selectedSegmentIndex] + 1 forKey:@"difficulty"];
    NSLog(@"saving state");
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    [self.playerType setSelectedSegmentIndex:[coder decodeIntegerForKey:@"playerType"] - 1 ];
    [self.humanPlayerColor setSelectedSegmentIndex:[coder decodeIntegerForKey:@"humanColor"] - 1];
    [self.difficulty setSelectedSegmentIndex:[coder decodeIntegerForKey:@"difficulty"] - 1];
    [self setupPlayerType:[self.playerType selectedSegmentIndex] - 1];
    NSLog(@"restoring state");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    PlayerType playerType = [prefs integerForKey:@"playerType"];
    PieceColor humanColor = [prefs integerForKey:@"humanColor"];
    Difficulty difficulty = [prefs integerForKey:@"difficulty"];

    if (playerType == PlayerTypeNone)
    {
        // defaults
        playerType = PlayerTypeComputer;
        humanColor = PieceColorBlack;
        difficulty = DifficultyEasy;
    }
    
    [self.playerType setSelectedSegmentIndex:playerType - 1];
    [self setupPlayerType:playerType];
    [self.humanPlayerColor setSelectedSegmentIndex:humanColor - 1];
    [self.difficulty setSelectedSegmentIndex:difficulty - 1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupPlayerType:(PlayerType)playerType
{
    switch (playerType)
    {
        case PlayerTypeHuman:
            self.difficulty.hidden = YES;
            self.difficultyLabel.hidden = YES;
            break;
            
        case PlayerTypeComputer:
            self.difficulty.hidden = NO;
            self.difficultyLabel.hidden = NO;
            break;
            
        default:
            [NSException raise:@"bad selector" format:@"%@", self];
            break;
    }
}

- (IBAction)againstAction:(UISegmentedControl *)sender
{
    [self setupPlayerType:[sender selectedSegmentIndex] + 1];
}

- (IBAction)humanPlayerColorAction:(UISegmentedControl *)sender
{
}

- (IBAction)difficultyAction:(UISegmentedControl *)sender
{
}

@end
