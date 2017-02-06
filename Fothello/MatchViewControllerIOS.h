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

@class BoardScene;
@class Match;

@interface MatchViewControllerIOS : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *pass;
@property (weak, nonatomic) IBOutlet UIButton *resetGame;
@property (nonatomic) BOOL bannerIsVisible;
@property (strong, nonatomic) IBOutlet SKView *mainScene;
@property (strong, nonatomic) BoardScene *boardScene;
@property (nonatomic) NSInteger pageIndex;
@property (nonatomic) Match *match;

- (IBAction)pass:(UIButton *)sender;
- (IBAction)resetGame:(UIButton *)sender;
@end
