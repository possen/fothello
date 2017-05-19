//
//  MatchMoves.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/19/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PlayerMove;
@class Match;

@interface MatchMoves : NSObject
@property (nonatomic, nonnull) NSMutableArray<PlayerMove *> *moves;
@property (nonatomic, readonly, nonnull) NSMutableArray<PlayerMove *> *redos;

- (nonnull PlayerMove *)addMove:(nonnull PlayerMove *)move;

- (void)undo;
- (void)redo;
- (void)resetRedos;
- (void)resetMoves;

- (nonnull instancetype)initWithMatch:(nonnull Match *)match;

@end
