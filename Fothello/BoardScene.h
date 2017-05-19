//
//  MyScene.h
//  Fothello
//

//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "FothelloGame.h"

static NSString *kMainFont = @"AvenirNext-Medium";

@class Match;

typedef void (^UpdatePlayerMove)(BOOL canMove);

@interface BoardScene : SKScene

@property (nonatomic) Match *match;
@property (nonatomic,readonly) NSInteger boardDimensions;
@property (nonatomic,readonly) CGRect boardRect;
@property (nonatomic,readonly) NSInteger boardSize;
@property (nonatomic) SKSpriteNode *currentPlayerSprite;
@property (nonatomic, copy) UpdatePlayerMove updatePlayerMove;
@property (nonatomic) SKNode *gameOverNode;
@property (nonatomic) SKShapeNode *boardUI;

- (instancetype)initWithSize:(CGSize)size match:(Match *)match;
- (void)locationX:(NSInteger)rawx Y:(NSInteger)rawy;
- (SKNode *)makePieceWithColor:(PieceColor)color size:(CGSize)size;

@end
