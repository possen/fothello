//
//  ViewController.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/11/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import "ViewController.h"
#import "BoardScene.h"
#import "FothelloGame.h"
#import <iAd/iAd.h>
#import "DialogViewController.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView *skView = (SKView *)self.view;
    //    skView.showsFPS = YES;
    //skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    BoardScene *scene = [BoardScene sceneWithSize:skView.bounds.size];
    self.boardScene = scene;
    
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    
    ADBannerView *adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    //    adView.frame = CGRectOffset(adView.frame, 0, 20);
    [adView sizeThatFits:[skView frame].size];
    adView.delegate = self;
    [self.view addSubview:adView];
}


- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    NSLog(@"Banner view is beginning an ad action");
    BOOL shouldExecuteAction = [self allowActionToRun]; // your application implements this method
    if (!willLeave && shouldExecuteAction)
    {
        // insert code here to suspend any services that might conflict with the advertisement
    }
    return shouldExecuteAction;
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (self.bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        // Assumes the banner view is placed at the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
        [UIView commitAnimations];
        self.bannerIsVisible = NO;
    }
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!self.bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        // Assumes the banner view is just off the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, -(banner.frame.size.height));
        [UIView commitAnimations];
        self.bannerIsVisible = YES;
    }
}

- (IBAction)unwindFromCancelForm:(UIStoryboardSegue *)segue
{
}

- (IBAction)unwindFromConfirmationForm:(UIStoryboardSegue *)segue
{
    DialogViewController *dvc = segue.sourceViewController;
    
    UISegmentedControl *playerTypeControl = dvc.playerType;
    PlayerType playerType = [playerTypeControl selectedSegmentIndex];
    
    UISegmentedControl *humanControl = dvc.humanPlayerColor;
    PieceColor pieceColor = [humanControl selectedSegmentIndex];

    UISegmentedControl *difficultyControl = dvc.difficulty;
    Difficulty difficulty = [difficultyControl selectedSegmentIndex];

    FothelloGame *game = [FothelloGame sharedInstance];

    [game.currentMatch reset]; // clear the board only. 
    [self.boardScene teardownCurrentMatch];

    [game matchWithDifficulty:difficulty
             firstPlayerColor:pieceColor + PieceColorBlack
                 opponentType:playerType];
    
    [self.boardScene setupCurrentMatch];
    
    [game reset];

    // segment control is zero based add start piece color to map it correctly.
    if (pieceColor + PieceColorBlack ==  PieceColorWhite)
    {
        if (playerType == PlayerTypeComputer)
            [game.currentMatch processOtherTurnsX:-1 Y:-1];
        else
            [game.currentMatch nextPlayer];
    }
}

- (BOOL)allowActionToRun
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}



- (IBAction)pass:(UIButton *)sender
{
    FothelloGame *game = [FothelloGame sharedInstance];
    [game pass];
}

- (IBAction)resetGame:(UIButton *)sender {
    //   FothelloGame *game = [FothelloGame sharedInstance];
    //    [game reset];
}
@end
