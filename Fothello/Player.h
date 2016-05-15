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

typedef enum PlayerType : NSInteger
{
    PlayerTypeNone = 0,
    PlayerTypeHuman,
    PlayerTypeComputer
} PlayerType;

#pragma mark - Player -

@interface Player : NSObject <NSCoding>

@property (nonatomic, copy) NSString *name;
@property (nonatomic) PieceColor preferredPieceColor;
@property (nonatomic) PieceColor color;
@property (nonatomic) Strategy *strategy;
@property (nonatomic) NSInteger score;
@property (nonatomic) id userReference;
@property (nonatomic, readonly) BOOL canMove;

- (instancetype)initWithName:(NSString *)name;
- (NSArray <BoardPiece *> *)takeTurn; // automated players don't pass position here.
- (NSArray <BoardPiece *> *)takeTurnAtX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass;

@end

