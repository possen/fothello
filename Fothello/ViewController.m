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

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    //    skView.showsFPS = YES;
    //skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [BoardScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    
    ADBannerView *adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    adView.frame = CGRectOffset(adView.frame, 0, 20);
    adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
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
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height + 20);
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
        banner.frame = CGRectOffset(banner.frame, 0, -(banner.frame.size.height + 20));
        [UIView commitAnimations];
        self.bannerIsVisible = YES;
    }
}

- (IBAction)unwindFromConfirmationForm:(UIStoryboardSegue *)segue
{
    FothelloGame *game = [FothelloGame sharedInstance];
    [game reset];
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
    FothelloGame *game = [FothelloGame sharedInstance];
    [game reset];
}
@end
