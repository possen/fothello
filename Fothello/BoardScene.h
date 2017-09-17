//
//  MyScene.h
//  Fothello
//

//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "FothelloGame.h"

static NSString *_Nonnull kMainFont = @"AvenirNext-Medium";

@class Match;
@class PieceSprite;

typedef void (^UpdatePlayerMove)(BOOL canMove);

@interface BoardScene : SKScene

@property (nonatomic, nonnull) Match *match;
@property (nonatomic, readonly) NSInteger boardDimensions;
@property (nonatomic, readonly) CGRect boardRect;
@property (nonatomic, readonly) NSInteger boardSize;
@property (nonatomic, nonnull, copy) UpdatePlayerMove updatePlayerMove;
@property (nonatomic, nullable) SKNode *gameOverNode;
@property (nonatomic, nonnull) SKShapeNode *boardUI;
@property (nonatomic, nonnull) PieceSprite *pieceSprite;
@property (nonatomic) CGFloat spacing;
@property (nonatomic, nullable) SKSpriteNode *currentPlayerSprite;
    
- (nonnull instancetype)initWithSize:(CGSize)size match:(nonnull Match *)match;
- (void)locationX:(NSInteger)rawx Y:(NSInteger)rawy;
- (void)presentCommon:(nonnull UpdatePlayerMove)updateMove;

@end
