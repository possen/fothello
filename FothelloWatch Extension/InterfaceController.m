//
//  InterfaceController.m
//  FothelloWatch Extension
//
//  Created by Paul Ossenbruggen on 6/14/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <FothelloLib/FothelloLib.h>

#import "InterfaceController.h"
#import "BoardScene.h"
#import "GameBoard.h"
#import "Match.h"

@interface InterfaceController() 

@property (strong, nonatomic) IBOutlet WKInterfaceSKScene *skInterface;
@property (nonatomic) BoardScene *boardScene;
@property (nonatomic) double currentPos;

@end


@implementation InterfaceController 

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];

//    SKView *skView = (SKView *)self.mainScene;
    //    skView.showsFPS = YES;
    //skView.showsNodeCount = YES;
    
    // Load the SKScene from 'BoardScene.sks'
//    BoardScene *scene = [BoardScene nodeWithFileNamed:@"BoardScene"];
    CGSize size = CGSizeMake(310, 310);
//    self.pass.hidden = YES;
    
    self.crownSequencer.delegate = self;
    [self.crownSequencer focus];

    FothelloGame *game = [FothelloGame sharedInstance];
    self.match = [game createMatchFromKind:PlayerKindSelectionHumanVComputer difficulty:DifficultyEasy];
    
    // Create and configure the scene.
    BoardScene *scene = [[BoardScene alloc] initWithSize:size match:self.match];
    self.boardScene = scene;
    
    __weak InterfaceController *weakBlockSelf = self;
    scene.updatePlayerMove = ^(BOOL canMove)
    {
        [weakBlockSelf updateMove:canMove];
    };
    
    // Set the scale mode to scale to fit the window
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene
    [self.skInterface presentScene:scene];
    
    scene.match = self.match;
   
    // Use a value that will maintain consistent frame rate
    self.skInterface.preferredFramesPerSecond = 30;
    
    [self reset];
}

- (void)updateMove:(BOOL)canMove
{
    // self.pass.hidden = canMove;
}

- (void)reset
{
    [self.match reset];
    [self.match beginMatch];
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

- (NSInteger)normaizeIndex:(NSInteger)maxIndex value:(CGFloat)value
{
    NSInteger result = value;
    if (self.currentPos > maxIndex - 1)
    {
        result = 0;
    }
    
    if (self.currentPos < 0)
    {
        result = maxIndex - 1;
    }
    return result;
}

- (void)crownDidRotate:(WKCrownSequencer *)crownSequencer rotationalDelta:(double)rotationalDelta
{
    self.currentPos += rotationalDelta;
    NSArray<BoardPiece *> *legalMoves = [self.match.board
                                         legalMovesForPlayerColor:self.match.currentPlayer.color];
   
    NSInteger countLegalMoves = legalMoves.count;
    NSInteger index = [self normaizeIndex:countLegalMoves value:self.currentPos];
    
    if (countLegalMoves != 0)
    {
        BoardPosition *pos = legalMoves[index].position;
        self.match.board.highlightBlock(pos, PieceColorYellow);
    }
}

- (IBAction)tapAction:(id)sender
{
    NSArray<BoardPiece *> *legalMoves = [self.match.board
                                         legalMovesForPlayerColor:self.match.currentPlayer.color];

    Player *player = self.match.currentPlayer;
    NSInteger countLegalMoves = legalMoves.count;
    NSInteger index = [self normaizeIndex:countLegalMoves value:self.currentPos];
 
    if (countLegalMoves != 0)
    {
        BoardPosition *pos = legalMoves[index].position;
        PlayerMove *move = [PlayerMove makeMoveForColor:player.color position:pos];
        [self.match placeMove:move forPlayer:player];
    }
    else
    {
        PlayerMove *passMove = [PlayerMove makePassMoveForColor:player.color];
        [self.match placeMove:passMove forPlayer:player];
    }
    NSLog(@"tap");
}

@end



