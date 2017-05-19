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
    CGFloat originx = boardRect.origin.x; CGFloat originy = boardRect.origin.y;
    
    [boardScene addChild:[self makeDotAtPosition:CGPointMake(originx + (spacing * 2), originy + (spacing * 2))]];
    [boardScene addChild:[self makeDotAtPosition:CGPointMake(originx + (spacing * 2), originy + (spacing * 6))]];
    [boardScene addChild:[self makeDotAtPosition:CGPointMake(originx + (spacing * 6), originy + (spacing * 2))]];
    [boardScene addChild:[self makeDotAtPosition:CGPointMake(originx + (spacing * 6), originy + (spacing * 6))]];
}

- (void)drawBoardGrid
{
    BoardScene *boardScene = self.boardScene;
    CGRect boardRect = boardScene.boardRect;
    CGFloat boardDimensions = boardScene.boardDimensions;
    SKShapeNode *boardUI = [SKShapeNode node];
    
    CGFloat spacing = boardDimensions / _boardSize;
    CGFloat originx = boardRect.origin.x; CGFloat originy = boardRect.origin.y;
    CGFloat width = boardRect.size.width; CGFloat height = boardRect.size.height;

    CGMutablePathRef pathToDraw = CGPathCreateMutable();
    CGPathMoveToPoint(pathToDraw, NULL, boardRect.origin.x, boardRect.origin.y);
    CGPathAddRect(pathToDraw, NULL, CGRectMake(originx, originy, width, height));
    
    for (CGFloat lines = 0; lines < boardDimensions; lines += spacing)
    {
        CGPathMoveToPoint(pathToDraw, NULL, originx, originy + lines);
        CGPathAddLineToPoint(pathToDraw, NULL, originx + boardRect.size.width, originy + lines);
        CGPathMoveToPoint(pathToDraw, NULL, originx + lines, originy);
        CGPathAddLineToPoint(pathToDraw, NULL, originx + lines, originy + boardRect.size.width);
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
    myLabel.fontSize = 30;      myLabel.position = CGPointMake(CGRectGetMidX(boardScene.frame),boardRect.origin.y + boardRect.size.height + 20);
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
