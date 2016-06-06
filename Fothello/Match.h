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
@class BoardPosition;

#pragma mark - Match -

typedef void (^MatchStatusBlock)(BOOL gameOver);
typedef void (^MovesUpdateBlock)();
typedef void (^CurrentPlayerBlock)(Player * _Nonnull player, BOOL canMove);

@interface Match : NSObject <NSCoding>

- (nonnull instancetype)initWithName:(nonnull NSString *)name
                             players:(nonnull NSArray<Player *> *)players;

- (void)restart;
- (void)reset;
- (void)undo;
- (void)redo;
- (void)resetRedos;
- (void)nextPlayer;
- (void)ready;
- (void)placeMove:(nonnull PlayerMove *)move forPlayer:(nonnull Player *)player showMove:(BOOL)showMove;

@property (nonatomic, copy, nonnull) NSString *name;
@property (nonatomic, readonly, nonnull) GameBoard *board;
@property (nonatomic, readonly, nonnull) NSArray<Player *>*players;
@property (nonatomic, readonly, nonnull) Player *currentPlayer;
@property (nonatomic, copy, nullable) CurrentPlayerBlock currentPlayerBlock;
@property (nonatomic, copy, nullable) MatchStatusBlock matchStatusBlock;
@property (nonatomic, copy, nullable) MovesUpdateBlock movesUpdateBlock;
@property (nonatomic, nonnull) NSMutableArray<PlayerMove *> *moves;
@property (nonatomic) BOOL noMoves;
@property (nonatomic, readonly) BOOL turnProcessing;

@property (nonatomic, readonly, nonnull) NSMutableArray *redos;
@property (nonatomic, readonly) BOOL areAllPlayersComputers;
@end


