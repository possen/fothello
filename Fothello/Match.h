//
//  Match.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/2/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FothelloGame.h"

@class PlayerMove;
@class BoardPiece;
@class GameBoard;

#pragma mark - Match -

typedef void (^MatchStatusBlock)(BOOL gameOver);
typedef void (^MovesUpdateBlock)();
typedef void (^CurrentPlayerBlock)(Player * _Nonnull player, BOOL canMove);
typedef void (^HighlightBlock)(PlayerMove * _Nonnull  move, PieceColor color);

@interface Match : NSObject <NSCoding>

- (nonnull instancetype)initWithName:(nonnull NSString *)name
                     players:(nonnull NSArray<Player *> *)players
                  difficulty:(Difficulty)difficulty;

- (nullable NSArray <BoardPiece *> *)placeMove:(nonnull PlayerMove *)move forPlayer:(nonnull Player *)player showMove:(BOOL)showMove;
- (void)showHintMove:(nonnull PlayerMove *)move forPlayer:(nonnull Player *)player;

- (void)restart;
- (void)reset;
- (void)test;
- (void)hint;
- (void)undo;
- (void)redo;
- (BOOL)done;
- (void)nextPlayer;
- (void)takeTurnAtX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass;
- (void)takeTurn;
- (void)takeTurnPass;
- (void)ready;
- (nullable NSArray <BoardPiece *> *)beginTurn;
- (nullable NSArray <BoardPiece *> *)endTurn;
- (NSInteger)calculateScore:(nonnull Player *)player;

@property (nonatomic, copy, nonnull) NSString *name;
@property (nonatomic, readonly, nonnull) GameBoard *board;
@property (nonatomic, readonly, nonnull) NSArray<Player *>*players;
@property (nonatomic, readonly, nonnull) Player *currentPlayer;
@property (nonatomic) Difficulty difficulty; // only used by AIStrategy
@property (nonatomic, copy, nullable) CurrentPlayerBlock currentPlayerBlock;
@property (nonatomic, copy, nullable) MatchStatusBlock matchStatusBlock;
@property (nonatomic, copy, nullable) HighlightBlock highlightBlock;
@property (nonatomic, copy, nullable) MovesUpdateBlock movesUpdateBlock;
@property (nonatomic, nonnull) NSMutableArray<PlayerMove *> *moves;
@property (nonatomic) BOOL noMoves;

@property (nonatomic, readonly) BOOL turnProcessing;
@property (nonatomic, readonly, nonnull) NSMutableArray *redos;
@property (nonatomic, readonly) BOOL areAllPlayersComputers;
@end


