//
//  MatchViewControllerMac.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/16/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SpriteKit/SpriteKit.h>

@class Match;

@interface MatchViewControllerMac : NSViewController
@property (nonatomic) Match *match;
- (void)resetGame;
@end
