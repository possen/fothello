//
//  ViewController.h
//  Fothello
//
//  UI For a particular board.
//
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <iAd/iAd.h>

@class BoardScene;
@class Match;

@interface MatchViewController : UIViewController <ADBannerViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *pass;
@property (weak, nonatomic) IBOutlet UIButton *resetGame;
@property (nonatomic) BOOL bannerIsVisible;
@property (nonatomic) ADBannerView *bannerView;
@property (strong, nonatomic) IBOutlet SKView *mainScene;
@property (strong, nonatomic) BoardScene *boardScene;
@property (nonatomic) NSInteger pageIndex;
@property (nonatomic) Match *match;

- (IBAction)pass:(UIButton *)sender;
- (IBAction)resetGame:(UIButton *)sender;
@end
