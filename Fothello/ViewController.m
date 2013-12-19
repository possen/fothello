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

@interface ViewController ()

// contentView's vertical bottom constraint, used to alter the contentView's vertical size when ads arrive
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (nonatomic) BOOL notFirstTime;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView *skView = (SKView *)self.mainScene;
    //    skView.showsFPS = YES;
    //skView.showsNodeCount = YES;
 
    self.pass.hidden = YES;
    
    // Create and configure the scene.
    BoardScene *scene = [BoardScene sceneWithSize:skView.bounds.size];
    self.boardScene = scene;
 
    __weak ViewController *weakBlockSelf = self;
    scene.updatePlayerMove = ^(BOOL canMove)
    {
        [weakBlockSelf updateMove:canMove];
    };

    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];

    ADBannerView *adView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    //    adView.frame = CGRectOffset(adView.frame, 0, 20);
    [adView sizeThatFits:[skView frame].size];
    adView.delegate = self;
    _bannerView = adView;
    [self.view addSubview:adView];

    [self.boardScene.game ready];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self layoutAnimated:NO];
}

- (void)viewDidLayoutSubviews
{
    if (self.notFirstTime)
    {
        [self layoutAnimated:[UIView areAnimationsEnabled]];
    }
    self.notFirstTime = YES;
}

- (void)layoutAnimated:(BOOL)animated
{
    CGRect contentFrame = self.view.bounds;
    
    // all we need to do is ask the banner for a size that fits into the layout area we are using
    CGSize sizeForBanner = [self.bannerView sizeThatFits:contentFrame.size];
    
    // compute the ad banner frame
    CGRect bannerFrame = self.bannerView.frame;
    if (self.bannerView.bannerLoaded)
    {
        // bring the ad into view
        contentFrame.size.height -= sizeForBanner.height;   // shrink down content frame to fit the banner above it
        contentFrame.origin.y += sizeForBanner.height;
        bannerFrame.origin.y = 0;
        bannerFrame.size.height = sizeForBanner.height;
        bannerFrame.size.width = sizeForBanner.width;
        [self.view layoutSubviews];
    }
    else
    {
        // hide the banner off screen further off the bottom
        bannerFrame.size.height = 0;
    }
    //    self.mainScene.frame = contentFrame;
    
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:
     ^{
        [self.mainScene layoutIfNeeded];
        self.bannerView.frame = bannerFrame;
    }];
}


- (void)updateMove:(BOOL)canMove
{
    self.pass.hidden = canMove;
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
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
    [self layoutAnimated:YES];
}

- (IBAction)unwindFromCancelForm:(UIStoryboardSegue *)segue
{
}

- (IBAction)unwindFromConfirmationForm:(UIStoryboardSegue *)segue
{
    DialogViewController *dvc = segue.sourceViewController;
    
    UISegmentedControl *playerTypeControl = dvc.playerType;
    PlayerType playerType = [playerTypeControl selectedSegmentIndex] + 1;
    
    UISegmentedControl *humanControl = dvc.humanPlayerColor;
    PieceColor pieceColor = [humanControl selectedSegmentIndex] + 1;

    UISegmentedControl *difficultyControl = dvc.difficulty;
    Difficulty difficulty = [difficultyControl selectedSegmentIndex] + 1;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:playerType forKey:@"playerType"];
    [prefs setInteger:pieceColor forKey:@"humanColor"];
    [prefs setInteger:difficulty forKey:@"difficulty"];
    [prefs synchronize];

    FothelloGame *game = [FothelloGame sharedInstance];

    [game.currentMatch reset]; // clear the board only. 
    [self.boardScene teardownCurrentMatch];

    [game matchWithDifficulty:difficulty
             firstPlayerColor:pieceColor
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
