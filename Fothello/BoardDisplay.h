//
//  BoardDisplay.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/29/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Match.h"
#import "GameBoard.h"
#import "BoardScene.h"

@interface BoardDisplay : NSObject

- (instancetype)initWithMatch:(Match *)match
                   boardScene:(BoardScene *)boardScene
              boardDimensions:(CGFloat)boardDimensions;

- (void)drawBoard;
@end
