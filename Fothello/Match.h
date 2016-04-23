//
//  Match.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/2/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FothelloGame.h"
#import "GameBoard.h"

#pragma mark - Match -

@interface Match : NSObject <NSCoding>

- (instancetype)initWithName:(NSString *)name
                     players:(NSArray<Player *> *)players
                  difficulty:(Difficulty)difficulty;

- (BOOL)placePieceForPlayer:(Player *)player position:(Move *)position;
- (BOOL)showHintForPlayer:(Player *)player position:(Move *)position;

- (void)reset;
- (void)test;
- (void)pass;
- (void)hint;
- (void)undo;
- (void)redo;
- (BOOL)done;
- (void)nextPlayer;
- (BOOL)takeTurnAtX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass;
- (void)processOtherTurnsX:(NSInteger)humanX Y:(NSInteger)y pass:(BOOL)pass;
- (void)ready;
- (BOOL)beginTurn;
- (void)endTurn;
- (NSInteger)calculateScore:(Player *)player;
- (BOOL)findTracksX:(NSInteger)x
                  Y:(NSInteger)y
          forPlayer:(Player *)player
         trackBlock:(void (^)(NSArray<TrackInfo *> *pieces))trackBlock;

@property (nonatomic) NSString *name;
@property (nonatomic) GameBoard *board;
@property (nonatomic) NSArray<Player *>*players;
@property (nonatomic) Player *currentPlayer;
@property (nonatomic) Difficulty difficulty; // only used by AIStrategy
@property (nonatomic, copy) CurrentPlayerBlock currentPlayerBlock;
@property (nonatomic, copy) MatchStatusBlock matchStatusBlock;
@property (nonatomic) NSMutableArray<PlayerMove *> *moves;
@end


