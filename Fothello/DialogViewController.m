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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    [self.playerType setSelectedSegmentIndex:PlayerTypeComputer];
    [self setupPlayerType:PlayerTypeComputer];

    return self;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];

    [coder encodeInteger:[self.playerType selectedSegmentIndex] forKey:@"playerType"];
    [coder encodeInteger:[self.humanPlayerColor selectedSegmentIndex] forKey:@"humanColor"];
    [coder encodeInteger:[self.difficulty selectedSegmentIndex] forKey:@"difficulty"];
    NSLog(@"saving state");
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    [self.playerType setSelectedSegmentIndex:[coder decodeIntegerForKey:@"playerType"]];
    [self.humanPlayerColor setSelectedSegmentIndex:[coder decodeIntegerForKey:@"humanColor"]];
    [self.difficulty setSelectedSegmentIndex:[coder decodeIntegerForKey:@"difficulty"]];
    [self setupPlayerType:[self.playerType selectedSegmentIndex]];
    NSLog(@"restoring state");

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger playerType = [prefs integerForKey:@"playerType"];
    NSInteger humanColor = [prefs integerForKey:@"humanColor"];
    NSInteger difficulty = [prefs integerForKey:@"difficulty"];

    [self.playerType setSelectedSegmentIndex:playerType];
    [self setupPlayerType:playerType];
    [self.humanPlayerColor setSelectedSegmentIndex:humanColor];
    [self.difficulty setSelectedSegmentIndex:difficulty];
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
    }
}

- (IBAction)againstAction:(UISegmentedControl *)sender
{
    [self setupPlayerType:[sender selectedSegmentIndex]];
}

- (IBAction)humanPlayerColorAction:(UISegmentedControl *)sender
{
}

- (IBAction)difficultyAction:(UISegmentedControl *)sender
{
}

@end
