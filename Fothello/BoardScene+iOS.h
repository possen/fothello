//
//  BoardScene+iOS.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/15/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "BoardScene.h"

@interface BoardScene (iOS)
- (void)presentWithView:(nonnull SKView *)view updatePlayerMove:(nonnull UpdatePlayerMove)updateMove;
@end
