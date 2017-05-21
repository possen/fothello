//
//  PieceSprite.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/20/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "PieceSprite.h"
#import "BoardPosition.h"
#import "BoardPiece.h"
#import "BoardScene.h"
#import "Piece.h"

@interface PieceSprite ()
@property (nonatomic) BoardScene *boardScene;
@property (nonatomic) SKNode *prevHighlight;
@end

@implementation PieceSprite

- (instancetype)initWithBoardScene:(BoardScene *)boardScene
{
    self = [super init];
    if (self)
    {
        _boardScene = boardScene;
    }
    return self;
}

- (SKColor *)skColorFromPieceColor:(PieceColor)color
{
    static NSDictionary *colors = nil;
    
    colors = @{@(PieceColorNone)    : [SKColor clearColor],
               @(PieceColorWhite)   : [SKColor whiteColor],
               @(PieceColorBlack)   : [SKColor blackColor],
               @(PieceColorRed)     : [SKColor redColor],
               @(PieceColorBlue)    : [SKColor blueColor],
               @(PieceColorGreen)   : [SKColor greenColor],
               @(PieceColorYellow)  : [SKColor yellowColor],
               @(PieceColorLegal)   : [SKColor blackColor]};
    
    return colors[@(color)];
}

- (SKNode *)makePieceWithColor:(PieceColor)color size:(CGSize)size
{
    SKShapeNode *pieceSprite = [[SKShapeNode alloc] init];
    
    CGMutablePathRef myPath = CGPathCreateMutable();
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGPathAddEllipseInRect(myPath, NULL, rect);
    pieceSprite.path = myPath;
    CFRelease(myPath);
    
    pieceSprite.lineWidth = 1.0;
    pieceSprite.fillColor = [self skColorFromPieceColor:color];
    pieceSprite.strokeColor = [self skColorFromPieceColor:color];
    pieceSprite.glowWidth = 0.5;
    return pieceSprite;
}

- (void)placeSpriteAtX:(NSInteger)x Y:(NSInteger)y withPiece:(Piece *)piece
{
    // remove the piece
    [piece.userReference removeFromParent];
    piece.userReference = nil;
    
    if (piece.color == PieceColorNone) return;
    
    BOOL showLegalMoves = piece.color == PieceColorLegal;
    CGSize spriteSize = [self.boardScene calculateSpriteSizeWithSmallSize:showLegalMoves];
    
    SKNode *sprite = [self makePieceWithColor:piece.color size:spriteSize];
    sprite.position = [self.boardScene calculateScreenPositionFromX:x andY:y sizeSmall:showLegalMoves];
    sprite.alpha = 0.0;
    
    [self.boardScene addChild:sprite];
    CGFloat finalAlpha = showLegalMoves ? .3 : 1.0;
    SKAction *action = [SKAction fadeAlphaTo:finalAlpha duration:.5];
    
    // All the animations should complete at about the same time but only want one
    // callback.
    [sprite runAction:action];
    piece.userReference = sprite;
}

- (void)higlightAtX:(NSInteger)x y:(NSInteger)y color:(PieceColor)color
{
    if (x < 0 || y < 0) return;
    
    CGSize spriteSize = [self.boardScene calculateSpriteSizeWithSmallSize:NO];
    SKNode *sprite = [self makePieceWithColor:color size:spriteSize];
    sprite.position = [self.boardScene calculateScreenPositionFromX:x andY:y sizeSmall:NO];
    sprite.alpha = 1.0;
    
    SKAction *action = [SKAction fadeAlphaTo:0 duration:.5];
    
    [self.prevHighlight removeFromParent];
    [self.boardScene addChild:sprite];
    self.prevHighlight = sprite;
    
    [sprite runAction:action completion:^{
        [sprite removeFromParent];
    }];
}

@end
