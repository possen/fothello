//
//  BoardScene+BoardScene_Mac.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/15/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//
#import "FothelloGame.h"
#import "BoardScene.h"
#import "BoardScene+BoardScene_Mac.h"

@implementation BoardScene (BoardScene_Mac)

- (void)mouseDown:(NSEvent *)theEvent
{
    CGPoint positionInScene = [theEvent locationInNode:self];
    [self locationX:positionInScene.x Y:positionInScene.y];
}

- (void)mouseUp:(NSEvent *)theEvent
{
//    CGPoint positionInScene = [theEvent locationInNode:self];
//    [self screenInteractionEndedAtLocation:positionInScene];
}

- (void)mouseExited:(NSEvent *)theEvent
{
//    CGPoint positionInScene = [theEvent locationInNode:self];
//    [self screenInteractionEndedAtLocation:positionInScene];
}

@end
