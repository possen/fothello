//
//  BoardScene+Mac.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/15/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//
#import "FothelloGame.h"
#import "BoardScene.h"
#import "BoardScene+Mac.h"

@implementation BoardScene (Mac)

- (void)presentWithView:(SKView *)view updatePlayerMove:(UpdatePlayerMove)updateMove
{
    [self presentCommon:updateMove];
    [view presentScene:self];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    CGPoint positionInScene = [theEvent locationInNode:self];
    [self locationX:positionInScene.x Y:positionInScene.y];
}

@end
