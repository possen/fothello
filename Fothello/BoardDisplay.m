//
//  BoardDisplay.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/29/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import "BoardDisplay.h"

@interface BoardDisplay ()
@property (nonatomic) Match *match;
@property (nonatomic) BoardScene *boardScene;
@property (nonatomic) CGFloat spacing;
@property (nonatomic) CGFloat boardSize;
@property (nonatomic) CGFloat boardDimensions;
@end

@implementation BoardDisplay

- (instancetype)initWithMatch:(Match *)match boardScene:(BoardScene *)boardScene
{
    self = [super init];
    if (self)
    {
        _match = match;
        _boardScene = boardScene;
        _boardSize = match.board.size;
        _spacing = _boardDimensions / _boardSize;
    }
    return self;
}

- (SKNode *)makeDotAtPosition:(CGPoint)position
{
    SKShapeNode *dotSprite = [[SKShapeNode alloc] init];
    CGFloat size = 5;
    CGMutablePathRef myPath = CGPathCreateMutable();
    CGRect rect = CGRectMake(0, 0, size, size);
    CGPathAddEllipseInRect(myPath, NULL, rect);
    dotSprite.path = myPath;
    CFRelease(myPath);
    
    dotSprite.lineWidth = 1.0;
    dotSprite.fillColor = [SKColor whiteColor];
    dotSprite.strokeColor = [SKColor blackColor];
    dotSprite.position = CGPointMake(position.x - (size / 2) - .5, position.y - (size / 2) -.5);
    return dotSprite;
}

- (void)drawDots
{
    BoardScene *boardScene = self.boardScene;
    CGFloat spacing = self.spacing;
    CGRect boardRect = boardScene.boardRect;
    
    SKNode *dot1 = [self makeDotAtPosition:CGPointMake(boardRect.origin.x + (spacing * 2), boardRect.origin.y + (spacing * 2))];
    [boardScene addChild:dot1];
    
    SKNode *dot2 = [self makeDotAtPosition:CGPointMake(boardRect.origin.x + (spacing * 2), boardRect.origin.y + (spacing * 6))];
    [boardScene addChild:dot2];
    
    SKNode *dot3 = [self makeDotAtPosition:CGPointMake(boardRect.origin.x + (spacing * 6), boardRect.origin.y + (spacing * 2))];
    [boardScene addChild:dot3];
    
    SKNode *dot4 = [self makeDotAtPosition:CGPointMake(boardRect.origin.x + (spacing * 6), boardRect.origin.y + (spacing * 6))];
    [boardScene addChild:dot4];
}

- (void)drawBoardGrid
{
    BoardScene *boardScene = self.boardScene;
    CGRect boardRect = boardScene.boardRect;
    CGFloat boardDimensions = boardScene.boardDimensions;
    SKShapeNode *boardUI = [SKShapeNode node];
    CGFloat spacing = boardDimensions / _boardSize;
    
    CGMutablePathRef pathToDraw = CGPathCreateMutable();
    CGPathMoveToPoint(pathToDraw, NULL, boardRect.origin.x, boardRect.origin.y);
    CGPathAddRect(pathToDraw, NULL, CGRectMake(boardRect.origin.x,
                                               boardRect.origin.y,
                                               boardRect.size.width,
                                               boardRect.size.height));
    
    for (CGFloat lines = 0; lines < boardDimensions; lines += spacing)
    {
        CGPathMoveToPoint(pathToDraw, NULL,
                          boardRect.origin.x,
                          boardRect.origin.y + lines);
        
        CGPathAddLineToPoint(pathToDraw, NULL,
                             boardRect.origin.x + boardRect.size.width,
                             boardRect.origin.y + lines);
        
        CGPathMoveToPoint(pathToDraw, NULL,
                          boardRect.origin.x + lines,
                          boardRect.origin.y);
        
        CGPathAddLineToPoint(pathToDraw, NULL,
                             boardRect.origin.x + lines,
                             boardRect.origin.y + boardRect.size.width);
    }
    
    boardUI.path = pathToDraw;
    [boardUI setStrokeColor:[SKColor blackColor]];
    
    [boardScene addChild:boardUI];
    CFRelease(pathToDraw);
    
    boardScene.boardUI = boardUI;
}

- (void)drawGameTitle
{
    BoardScene *boardScene = self.boardScene;
    CGRect boardRect = boardScene.boardRect;
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:kMainFont];
    
    myLabel.text = @"Fothello";
    myLabel.fontSize = 30;
    myLabel.position = CGPointMake(CGRectGetMidX(boardScene.frame),
                                   boardRect.origin.y
                                   + boardRect.size.height + 20 );
    [boardScene addChild:myLabel];
    
    SKAction *action = [SKAction fadeAlphaTo:0 duration:2];
    [myLabel runAction:action];
}

- (void)drawBoard
{
    BoardScene *boardScene = self.boardScene;
    boardScene.backgroundColor = [SKColor colorWithRed:.0 green:.70 blue:0.3 alpha:1.0];
    [self drawGameTitle];
    [self drawBoardGrid];
    [self drawDots];
}


@end
