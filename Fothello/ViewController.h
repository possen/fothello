//
//  ViewController.h
//  Fothello
//

//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <iAd/iAd.h>

@class BoardScene;

@interface ViewController : UIViewController <ADBannerViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *pass;
@property (weak, nonatomic) IBOutlet UIButton *resetGame;
@property (nonatomic) BOOL bannerIsVisible;
@property (strong, nonatomic) IBOutlet SKView *mainScene;
@property (strong, nonatomic) BoardScene *boardScene;

- (IBAction)pass:(UIButton *)sender;
- (IBAction)resetGame:(UIButton *)sender;

@end
