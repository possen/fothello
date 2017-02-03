//
//  Player.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/2/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FothelloGame.h"

@class Strategy;
@class BoardPiece;
@class PlayerMove;
@class BoardPosition;
@class GameBoard;

typedef enum PlayerType : NSInteger
{
    PlayerTypeNone = 0,
    PlayerTypeHuman,
    PlayerTypeComputer
} PlayerType;

#pragma mark - Player -

@interface Player : NSObject <NSCoding>

@property (nonatomic, copy, nonnull) NSString *name;
@property (nonatomic) PieceColor preferredPieceColor;
@property (nonatomic) PieceColor color;
@property (nonatomic, nullable) Strategy *strategy;
@property (nonatomic) NSInteger score;
@property (nonatomic, nullable) id userReference;
@property (nonatomic, readonly) BOOL turnProcessing;

- (nonnull instancetype)initWithName:(nonnull NSString *)name;

- (void)takeTurn; // AI players
- (void)takeTurnAtPosition:(nonnull BoardPosition *)positon;
- (void)takeTurnPass;

- (nullable NSArray<NSArray<BoardPiece *> *> *)beginTurn;
- (nullable NSArray<NSArray<BoardPiece *> *> *)endTurn;
- (void)hint;
@end

