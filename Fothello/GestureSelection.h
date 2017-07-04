//
//  GestureSelection.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 7/3/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Match.h"

@interface GestureSelection : NSObject
@property (nonatomic) Match *match;
@property (nonatomic) double currentPos;

#ifdef TARGET_OS_WATCH
- (instancetype)init;
#else
- (instancetype)initWithView:(UIView *)view;
#endif

- (NSArray<BoardPiece *> *)selectLegalMove;
- (void)up;
- (void)down;
- (void)tap;

@end
