//
//  BoardScene.m
//  FothelloTV
//
//  Created by Paul Ossenbruggen on 1/26/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <FothelloLib/FothelloLib.h>

#import "BoardScene.h"
#import "BoardScene+BoardScene_AppleTV.h"

@implementation BoardScene (BoardScene_AppleTV)

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    [self locationX:location.x Y:location.y];
}

@end
