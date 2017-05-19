//
//  PlayerDisplay.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/29/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameOverDisplay.h"
#import "Match.h"
#import "GameBoard.h"
#import "BoardScene.h"
#import "Piece.h"

@interface PlayerDisplay : NSObject
- (instancetype)initWithMatch:(Match *)match boardScene:(BoardScene *)boardScene;
- (void)displayPlayer:(Player *)player;
@end
