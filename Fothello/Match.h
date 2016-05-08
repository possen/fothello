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


typedef enum PlayerType : NSInteger
{
    PlayerTypeNone = 0,
    PlayerTypeHuman,
    PlayerTypeComputer
} PlayerType;

// specifically a move that can be replayed.
@interface PlayerMove : BoardPiece
+ (PlayerMove *)makeMoveWithPiece:(Piece *)piece position:(BoardPosition *)position;
+ (PlayerMove *)makePassMoveWithPiece:(Piece *)piece;
@end


@interface Match : NSObject <NSCoding>

- (instancetype)initWithName:(NSString *)name
                     players:(NSArray<Player *> *)players
                  difficulty:(Difficulty)difficulty;

- (BOOL)placeMove:(PlayerMove *)move forPlayer:(Player *)player;
- (void)showHintMove:(PlayerMove *)move forPlayer:(Player *)player;

- (void)reset;
- (void)test;
- (void)pass;
- (void)hint;
- (void)undo;
- (void)redo;
- (BOOL)done;
- (BOOL)nextPlayer;
- (BOOL)takeTurnAtX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass; 
- (void)processOtherTurns;
- (void)ready;
- (BOOL)beginTurn;
- (void)endTurn;
- (NSInteger)calculateScore:(Player *)player;
- (BOOL)findTracksForMove:(PlayerMove *)move
                forPlayer:(Player *)player
               trackBlock:(void (^)(NSArray<BoardPiece *> *positions))trackBlock;

@property (nonatomic, copy) NSString *name;
@property (nonatomic) GameBoard *board;
@property (nonatomic) NSArray<Player *>*players;
@property (nonatomic) Player *currentPlayer;
@property (nonatomic) Difficulty difficulty; // only used by AIStrategy
@property (nonatomic, copy) CurrentPlayerBlock currentPlayerBlock;
@property (nonatomic, copy) MatchStatusBlock matchStatusBlock;
@property (nonatomic, copy) HighlightBlock highlightBlock;
@property (nonatomic) NSMutableArray<PlayerMove *> *moves;
@property (nonatomic) BOOL turnProcessing;
@end


