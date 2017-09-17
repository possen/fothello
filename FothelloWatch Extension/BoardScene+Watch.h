//
//  BoardScene+Watch.h
//  FothelloWatch Extension
//
//  Created by Paul Ossenbruggen on 9/17/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import "BoardScene.h"

@interface BoardScene (Watch)
- (void)presentWithUpdatePlayerMove:(nonnull UpdatePlayerMove)updateMove;
@end
