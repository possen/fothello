//
//  MatchViewControllerMac.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/16/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "MatchViewControllerMac.h"
#import "BoardScene.h"
#import "Match.h"

@interface MatchViewControllerMac ()
@property (strong, nonatomic) BoardScene *boardScene;
@property (nonatomic) NSInteger pageIndex;
@property (nonatomic) Match *match;
@property (nonatomic) IBOutlet SKView *mainView;
@property (nonatomic) BOOL canMove;
@end

@implementation MatchViewControllerMac

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    SKView *skView = self.mainView;
    self.boardScene.game.currentMatch = self.match;
//    /* Set the scale mode to scale to fit the window */
    self.boardScene.scaleMode = SKSceneScaleModeAspectFit;

//    self.pass.hidden = YES;
    
    // Create and configure the scene.
    BoardScene *scene = [BoardScene sceneWithSize:skView.bounds.size];
    self.boardScene = scene;
    
    __weak MatchViewControllerMac *weakBlockSelf = self;
    scene.updatePlayerMove = ^(BOOL canMove)
    {
        [weakBlockSelf updateMove:canMove];
    };
    
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    
    [self.boardScene.game ready];

}

- (void)updateMove:(BOOL)canMove
{
    self.canMove = canMove;
}


- (IBAction)newGame :(id)sender
{
    
}

- (IBAction)pass:(id )sender
{
    FothelloGame *game = [FothelloGame sharedInstance];
    [game pass];
}

- (IBAction)resetGame:(id)sender
{
    FothelloGame *game = [FothelloGame sharedInstance];
    [game reset];
}

- (IBAction)hint:(id)sender
{
    FothelloGame *game = [FothelloGame sharedInstance];
    [game pass];
}

- (IBAction)undo:(id)sender
{
}

- (IBAction)redo:(id)sender
{
}

- (BOOL)validateUserInterfaceItem:(NSMenuItem *)menuItem
{
    SEL theAction = [menuItem action];

    if (theAction == @selector(pass:))
    {
        return !self.canMove;
    }

    return TRUE;
}

@end
