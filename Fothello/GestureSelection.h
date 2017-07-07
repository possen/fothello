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
@property (nonatomic, nonnull) Match *match;
@property (nonatomic) double currentPos;

- (nonnull instancetype)initWithMatch:(nonnull Match *)match;

- (nonnull NSArray<BoardPiece *> *)selectLegalMove;
- (void)up;
- (void)down;
- (void)tap;

@end
