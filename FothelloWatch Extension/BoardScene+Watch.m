//
//  BoardScene+Watch.m
//  FothelloWatch Extension
//
//  Created by Paul Ossenbruggen on 9/17/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <SpriteKit/SpriteKit.h>
#import "BoardScene+Watch.h"

@implementation BoardScene (Watch)

- (void)presentWithWKInterface:(WKInterfaceSKScene *)interface updatePlayerMove:(UpdatePlayerMove)updateMove
{
    [self presentCommon:updateMove];
    [interface presentScene:self];
}

@end
