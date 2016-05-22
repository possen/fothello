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

@class PlayerMove;

#pragma mark - Match -

typedef void (^MatchStatusBlock)(BOOL gameOver);
typedef void (^MovesUpdateBlock)();
typedef void (^CurrentPlayerBlock)(Player *player, BOOL canMove);
typedef void (^HighlightBlock)(PlayerMove *move, PieceColor color);

// specifically a move that can be replayed.
@interface PlayerMove : BoardPiece
+ (PlayerMove *)makeMoveWithPiece:(Piece *)piece position:(BoardPosition *)position;
+ (PlayerMove *)makePassMoveWithPiece:(Piece *)piece;

@property (nonatomic, readonly) BOOL isPass;
@end


@interface Match : NSObject <NSCoding>

- (instancetype)initWithName:(NSString *)name
                     players:(NSArray<Player *> *)players
                  difficulty:(Difficulty)difficulty;

- (NSArray <BoardPiece *> *)placeMove:(PlayerMove *)move forPlayer:(Player *)player;
- (void)showHintMove:(PlayerMove *)move forPlayer:(Player *)player;

- (void)restart;
- (void)reset;
- (void)test;
- (void)pass;
- (void)hint;
- (void)undo;
- (void)redo;
- (BOOL)done;
- (void)nextPlayer;
- (void)takeTurnAtX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass;
- (void)takeTurn;
- (void)ready;
- (NSArray <BoardPiece *> *)beginTurn;
- (NSArray <BoardPiece *> *)endTurn;
- (NSInteger)calculateScore:(Player *)player;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, readonly) GameBoard *board;
@property (nonatomic, readonly) NSArray<Player *>*players;
@property (nonatomic, readonly) Player *currentPlayer;
@property (nonatomic) Difficulty difficulty; // only used by AIStrategy
@property (nonatomic, copy) CurrentPlayerBlock currentPlayerBlock;
@property (nonatomic, copy) MatchStatusBlock matchStatusBlock;
@property (nonatomic, copy) HighlightBlock highlightBlock;
@property (nonatomic, copy) MovesUpdateBlock movesUpdateBlock;
@property (nonatomic) NSMutableArray<PlayerMove *> *moves;

@property (nonatomic, readonly) BOOL turnProcessing;
@property (nonatomic, readonly) NSMutableArray *redos;
@property (nonatomic, readonly) BOOL areAllPlayersComputers;
@end


