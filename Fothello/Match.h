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
                     players:(NSArray *)players
                  difficulty:(Difficulty)difficulty;

- (BOOL)placePieceForPlayer:(Player *)player atX:(NSInteger)x Y:(NSInteger)y;
- (void)reset;
- (void)test;
- (BOOL)done;
- (void)nextPlayer;
- (void)processOtherTurnsX:(NSInteger)humanX Y:(NSInteger)y pass:(BOOL)pass;
- (void)ready;
- (BOOL)beginTurn;
- (void)endTurn;
- (NSInteger)calculateScore:(Player *)player;
- (BOOL)findTracksX:(NSInteger)x
                  Y:(NSInteger)y
          forPlayer:(Player *)player
         trackBlock:(void (^)(NSArray *pieces))trackBlock;

@property (nonatomic) NSString *name;
@property (nonatomic) GameBoard *board;
@property (nonatomic) NSArray *players;
@property (nonatomic) Player *currentPlayer;
@property (nonatomic) Difficulty difficulty; // only used by AIStrategy
@property (nonatomic, copy) CurrentPlayerBlock currentPlayerBlock;
@property (nonatomic, copy) MatchStatusBlock matchStatusBlock;
@property (nonatomic) NSMutableArray *moves;
@end


