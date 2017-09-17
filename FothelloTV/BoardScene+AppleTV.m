//
//  BoardScene.m
//  FothelloTV
//
//  Created by Paul Ossenbruggen on 1/26/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <FothelloLib/FothelloLib.h>

#import "BoardScene.h"
#import "BoardScene+AppleTV.h"

@implementation BoardScene (AppleTV)

- (void)presentWithView:(SKView *)view updatePlayerMove:(UpdatePlayerMove)updateMove
{
    [self presentCommon:updateMove];
    [view presentScene:self];
}

@end
