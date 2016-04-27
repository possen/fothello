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
#import "FothelloGame.h"

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
    
    FothelloGame *game = [FothelloGame sharedInstance];
    
    NSAssert(game.matches.count != 0, @"matches empty");
    self.match = game.matches.allValues[0];

    SKView *skView = self.mainView;
    self.boardScene.match = self.match;
//    /* Set the scale mode to scale to fit the window */
    self.boardScene.scaleMode = SKSceneScaleModeAspectFit;

//    self.pass.hidden = YES;
    
    // Create and configure the scene.
    BoardScene *scene = [[BoardScene alloc] initWithSize:skView.bounds.size match:self.match];
    self.boardScene = scene;
    
    __weak MatchViewControllerMac *weakBlockSelf = self;
    scene.updatePlayerMove = ^(BOOL canMove)
    {
        [weakBlockSelf updateMove:canMove];
    };
    
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    
    [self.match ready];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    
}

- (void)restoreStateWithCoder:(NSCoder *)coder
{
    
}

- (void)updateMove:(BOOL)canMove
{
    self.canMove = canMove;
}

- (IBAction)newDocument:(id)sender
{
    [self performSegueWithIdentifier:@"NewDocument" sender:self];
}

- (IBAction)pass:(id )sender
{
    [self.match pass];
}

- (IBAction)resetGame:(id)sender
{
    [self.match reset];
}

- (IBAction)hint:(id)sender
{
    [self.match pass];
}

- (IBAction)undo:(id)sender
{
    [self.match undo];
}

- (IBAction)redo:(id)sender
{
    [self.match redo];
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
