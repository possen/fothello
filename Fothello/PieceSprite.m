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
@property (nonatomic) CGFloat spacing;
@property (nonatomic) SKSpriteNode *currentPlayerSprite;
@property (nonatomic) CGRect boardRect;
@property (nonatomic) CGPoint centersOffset;
@end

#if TARGET_OS_OSX
CGFloat fudge =  0;
#else
CGFloat fudge =  2.5;
#endif

@implementation PieceSprite

- (instancetype)initWithBoardScene:(BoardScene *)boardScene
{
    self = [super init];
    
    if (self)
    {
        _boardScene = boardScene;
        _spacing = boardScene.spacing;
        _boardRect = boardScene.boardRect;
        CGFloat offset = _spacing / 2;
        _centersOffset = CGPointMake(_boardRect.origin.x + offset + fudge, _boardRect.origin.y + offset + fudge);
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
    CGRect rect = CGRectMake(-(size.width / 2.0), -(size.height / 2.0), size.width, size.height);
    CGPathAddEllipseInRect(myPath, NULL, rect);
    pieceSprite.path = myPath;
    CFRelease(myPath);
    
    pieceSprite.lineWidth = 1.0;
    pieceSprite.fillColor = [self skColorFromPieceColor:color];
    pieceSprite.strokeColor = [self skColorFromPieceColor:color];
    return pieceSprite;
}
    
- (void)movePieceTo:(BoardPosition *)pos
{
    CGPoint screenPos = [self calculateScreenPositionFromPos:pos sizeSmall:NO];
    SKAction *actionPos = [SKAction moveTo:screenPos duration:.5];
    SKAction *action = [SKAction sequence:@[actionPos]];
    [self.currentPlayerSprite runAction:action];
}

- (CGSize)calculateSpriteSizeWithSmallSize:(BOOL)sizeSmall
{
    CGFloat size = sizeSmall ? _spacing * 0.4 : _spacing * 0.9;
    CGSize spriteSize = CGSizeMake(size, size);
    return spriteSize;
}

- (CGPoint)calculateScreenPositionFromPos:(BoardPosition *)pos sizeSmall:(BOOL)sizeSmall
{
    return CGPointMake(pos.x * _spacing + _centersOffset.x, pos.y * _spacing + _centersOffset.y);
}

- (CGPoint)calculateScreenPositionFromX:(NSInteger)x andY:(NSInteger)y sizeSmall:(BOOL)sizeSmall
{
    return CGPointMake(x * _spacing + _centersOffset.x, y * _spacing + _centersOffset.y);
}
    
- (void)placeSpriteAtX:(NSInteger)x Y:(NSInteger)y withPiece:(Piece *)piece
{
    // remove the piece
    [piece.userReference removeFromParent];
    piece.userReference = nil;
    
    if (piece.color == PieceColorNone) return;
    
    BOOL showLegalMoves = piece.color == PieceColorLegal;
    CGSize spriteSize = [self calculateSpriteSizeWithSmallSize:showLegalMoves];
    
    SKNode *sprite = [self makePieceWithColor:piece.color size:spriteSize];
    sprite.position = [self calculateScreenPositionFromX:x andY:y sizeSmall:showLegalMoves];
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
    
    [self.prevHighlight removeFromParent];
    
    CGSize spriteSize = [self calculateSpriteSizeWithSmallSize:NO];
    SKNode *sprite = [self makePieceWithColor:color size:spriteSize];
    sprite.position = [self calculateScreenPositionFromX:x andY:y sizeSmall:NO];
    sprite.alpha = 1.0;
    
    SKAction *fadeOut = [SKAction fadeOutWithDuration: .5];
    SKAction *fadeIn = [SKAction fadeOutWithDuration: .5];
    SKAction *pulse = [SKAction sequence:@[fadeOut, fadeIn]];
    SKAction *pulseForever = [SKAction repeatActionForever:pulse];
    [sprite runAction:pulseForever];
    [self.boardScene addChild:sprite];
    self.prevHighlight = sprite;
}

@end
