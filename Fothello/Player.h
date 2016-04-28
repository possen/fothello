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

#pragma mark - Player -

@interface Player : NSObject <NSCoding>

@property (nonatomic, copy) NSString *name;
@property (nonatomic) PieceColor preferredPieceColor;
@property (nonatomic) PieceColor color;
@property (nonatomic) Strategy *strategy;
@property (nonatomic) NSInteger score;
@property (nonatomic) id userReference;
@property (nonatomic) BOOL canMove;

- (instancetype)initWithName:(NSString *)name;
- (BOOL)takeTurnAtX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass;
- (BOOL)otherPlayer:(Player *)player movedToX:(NSInteger)x Y:(NSInteger)y pass:(BOOL)pass;

@end

