//
//  BoardScene+BoardScene_iOS.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/15/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//
#import "FothelloGame.h"
#import "BoardScene.h"
#import "BoardScene+BoardScene_iOS.h"

@implementation BoardScene (BoardScene_iOS)

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    [self locationX:location.x Y:location.y];
}

@end
