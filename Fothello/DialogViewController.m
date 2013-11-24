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
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.playerType setSelectedSegmentIndex:PlayerTypeComputer];
    [self setupPlayerType:PlayerTypeComputer];
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
