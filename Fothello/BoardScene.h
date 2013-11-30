//
//  MyScene.h
//  Fothello
//

//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class FothelloGame;

typedef void (^UpdatePlayerMove)(BOOL canMove);

@interface BoardScene : SKScene

@property (nonatomic) FothelloGame *game;
@property (nonatomic,readonly) NSInteger boardDimensions;
@property (nonatomic,readonly) CGRect boardRect;
@property (nonatomic,readonly) NSInteger boardSize;
@property (nonatomic) SKSpriteNode *currentPlayerSprite;
@property (nonatomic) BOOL turnProcessing;
@property (nonatomic, copy) UpdatePlayerMove updatePlayerMove;

- (void)setupCurrentMatch;
- (void)teardownCurrentMatch;

@end
