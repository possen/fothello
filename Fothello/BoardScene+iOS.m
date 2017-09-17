//
//  BoardScene+iOS.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/15/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//
#import "FothelloGame.h"
#import "BoardScene.h"
#import "BoardScene+iOS.h"

@implementation BoardScene (iOS)
- (void)presentWithView:(SKView *)view updatePlayerMove:(UpdatePlayerMove)updateMove
{
    [self presentCommon:updateMove];
    [view presentScene:self];
}

@end
