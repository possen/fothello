//
//  GameOverDisplay.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/29/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Match;
@class BoardScene;

@interface GameOverDisplay : NSObject
- (instancetype)initWithMatch:(Match *)match boardScene:(BoardScene *)boardScene;
- (void)dismiss;
@end
