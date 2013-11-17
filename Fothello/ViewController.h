//
//  ViewController.h
//  Fothello
//

//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *pass;
- (IBAction)pass:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *resetGame;
- (IBAction)resetGame:(UIButton *)sender;

@end
