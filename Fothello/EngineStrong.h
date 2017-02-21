//
//  EngineStrong.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 2/20/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#ifndef EngineStrong_h
#define EngineStrong_h

@class NetworkController;

@interface EngineStrong ()
@property (nullable, nonatomic) NetworkController *network;

- (nonnull NSDictionary<NSString *, id> *)calculateMoveWithBoard:(nonnull NSString *)boardStr
                                                     playerColor:(PieceColor)playerColor
                                                      moveNumber:(NSInteger)moveNumber
                                                       diffculty:(Difficulty)difficulty;

- (void)seed:(nonnull NSString *)seed;

@end


#endif /* EngineStrong_h */
