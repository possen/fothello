//
//  MyScene.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/11/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import "MyScene.h"


@implementation MyScene

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        _boardDimensions = 280;
        _boardDim = 8;
        _boardRect = CGRectMake(20, 100, _boardDimensions, _boardDimensions);
        
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:.0 green:.70 blue:0.3 alpha:1.0];
        
        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        
        myLabel.text = @"Fothello";
        myLabel.fontSize = 30;
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame), 20);
        
        CGRect boardRect = self.boardRect;
        NSInteger boardDimensions = self.boardDimensions;
        SKShapeNode *boardUI = [SKShapeNode node];
        
        CGMutablePathRef pathToDraw = CGPathCreateMutable();
        CGPathMoveToPoint(pathToDraw, NULL, boardRect.origin.x, boardRect.origin.y);
        CGPathAddRect(pathToDraw, NULL, CGRectMake(boardRect.origin.x,
                                                   boardRect.origin.y,
                                                   boardRect.size.width,
                                                   boardRect.size.height));
        
        NSInteger spacing = boardDimensions / self.boardDim;
        for (NSInteger lines = 0; lines < boardDimensions; lines += spacing)
        {
            CGPathMoveToPoint(pathToDraw, NULL, boardRect.origin.x, boardRect.origin.y + lines);
            CGPathAddLineToPoint(pathToDraw, NULL, boardRect.origin.x + boardRect.size.width, boardRect.origin.y + lines);
            CGPathMoveToPoint(pathToDraw, NULL, boardRect.origin.x + lines, boardRect.origin.y);
            CGPathAddLineToPoint(pathToDraw, NULL, boardRect.origin.x + lines, boardRect.origin.y + boardRect.size.width);

            //   CGPathAddRect(pathToDraw, NULL, CGRectMake(20, 100, lines, 280));
            //CGPathAddRect(pathToDraw, NULL, CGRectMake(20, 100, 280, lines));
        }
        
        boardUI.path = pathToDraw;
        [boardUI setStrokeColor:[UIColor whiteColor]];
        [self addChild:boardUI];

        [self addChild:myLabel];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    /* Called when a touch begins */
    CGRect boardRect = self.boardRect;
    NSInteger boardDim = self.boardDim;
    NSInteger spacing = self.boardDimensions / boardDim;
    CGSize spriteSize = CGSizeMake(30, 30);
    

    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:self];
        
        NSInteger x = (location.x - boardRect.origin.x) / spacing;
        NSInteger y = (location.y - boardRect.origin.y) / spacing;
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"red-sphere"];
        
        sprite.position = CGPointMake(x * spacing + boardRect.origin.x + spriteSize.width / 2,
                                      y * spacing + boardRect.origin.y + spriteSize.height / 2);
        
        sprite.size = spriteSize;
                
        [self addChild:sprite];
    }
}

-(void)update:(CFTimeInterval)currentTime
{
    /* Called before each frame is rendered */
}

@end
