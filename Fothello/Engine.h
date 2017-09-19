//
//  Engine.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 2/18/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FothelloGame.h"

@class Match;
@class GKARC4RandomSource;

@protocol Engine <NSObject>

- (nullable instancetype)init;
- (nonnull NSDictionary<NSString *, id> *)calculateMoveForPlayer:(PieceColor)playerColor match:(nonnull Match *)match difficulty:(Difficulty)difficulty;

@end

@interface EngineWeakWatch : NSObject <Engine>
@end

@interface EngineStrong : NSObject <Engine>
@property (nonatomic, nonnull) GKARC4RandomSource *randomSource;
@end

@interface EngineStrongWatch : EngineStrong
@end
