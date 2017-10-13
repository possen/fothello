//
//  GameBoard+String.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/18/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameBoardInternal.h"

@interface GameBoardRepresentation : NSObject
@property (nonatomic, nonnull, readonly) GameBoardInternal *boardInternal;

- (nonnull instancetype)initWithBoard:(nonnull GameBoardInternal *)internal;
- (nonnull NSString *)toAscii;
- (nonnull NSString *)toUnicode;
- (void)printBoardUpdates:(nonnull NSArray<NSArray<BoardPiece *> *> *)tracks;

@end
