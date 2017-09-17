//
//  BoardScene+tvos.h
//  FothelloTV
//
//  Created by Paul Ossenbruggen on 1/26/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "BoardScene.h"

@interface BoardScene (TVOS)
- (void)presentWithView:(nonnull SKView *)view updatePlayerMove:(nonnull UpdatePlayerMove)updateMove;
@end
