//
//  GameViewController.m
//  FothelloTV
//
//  Created by Paul Ossenbruggen on 1/26/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import "MatchViewControllerTV.h"
#import "BoardScene+AppleTV.h"
#import "GestureSelection.h"

@interface MatchViewControllerTV ()
@property (nonatomic) BoardScene *boardScene;
@property (nonatomic) GestureSelection *gestureSelection;
@end

@implementation MatchViewControllerTV

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    FothelloGame *game = [FothelloGame sharedInstance];
    game.engine = [EngineStrong engine];
    
    Match *match = [game setupDefaultMatch];
    self.match = match;
    
    CGSize size = self.view.frame.size;

    // Create and configure the scene.
    BoardScene *scene = [[BoardScene alloc] initWithSize:size match:match];
    self.boardScene = scene;
    
    SKView *skView = (SKView *)self.view;
    [scene presentWithView:skView updatePlayerMove:^(BOOL canMove) {
        //    self.pass.hidden = canMove;
    }];
}

- (void)setMatch:(Match *)match
{
    [self.match reset]; // erase board
    _match = match;
    [self.match reset]; // setup board
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction)upAction:(id)sender
{
    [self.gestureSelection up];
}

- (IBAction)downAction:(id)sender
{
    [self.gestureSelection down];
}

- (IBAction)tapAction:(id)sender
{
    [self.gestureSelection tap];
}


@end
