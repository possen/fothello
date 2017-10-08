//
//  InterfaceController.m
//  FothelloWatch Extension
//
//  Created by Paul Ossenbruggen on 6/14/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <FothelloLib/FothelloLib.h>

#import "InterfaceController.h"
#import "GameBoard.h"
#import "Match.h"
#import "GestureSelection.h"
#import "BoardScene+Watch.h"

@interface InterfaceController() 

@property (strong, nonatomic) IBOutlet WKInterfaceSKScene *skInterface;
@property (nonatomic) BoardScene *boardScene;
@property (nonatomic) GestureSelection *gestureSelecton;
@end

@implementation InterfaceController

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];
    
    self.crownSequencer.delegate = self;
    [self.crownSequencer focus];
    
    FothelloGame *game = [FothelloGame sharedInstance];
    EngineWeakWatch *engine = [[EngineWeakWatch alloc] init];
    game.engine = engine;
    
    Match *match = [game setupDefaultMatch];
    self.match = match;
    CGSize size = self.skInterface.scene.size;
    CGSize newSize = CGSizeMake(size.width * 2, size.height * 2);
    BoardScene *boardScene = [[BoardScene alloc] initWithSize:newSize match:match];
    self.boardScene = boardScene;
    
    [boardScene presentWithWKInterface:self.skInterface updatePlayerMove:^(BOOL canMove) {
        //    self.pass.hidden = canMove;
    }];
}

- (void)setMatch:(Match *)match
{
    [self.match reset]; // erase board
    _match = match;
    [self.match reset]; // setup board
}

- (void)willActivate
{
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate
{
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)crownDidRotate:(WKCrownSequencer *)crownSequencer rotationalDelta:(double)rotationalDelta
{
    self.gestureSelecton.currentPos += rotationalDelta;
    [self.gestureSelecton selectLegalMove];
}

- (IBAction)upAction:(id)sender
{
    [self.gestureSelecton up];
}

- (IBAction)downAction:(id)sender
{
    [self.gestureSelecton down];
}

- (IBAction)tapAction:(id)sender
{
    [self.gestureSelecton tap];
}

@end



