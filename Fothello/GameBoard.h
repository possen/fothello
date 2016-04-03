//
//  GameBoard.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/2/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - TrackInfo -

@interface TrackInfo : NSObject
@property (nonatomic) Piece *piece;
@property (nonatomic) NSInteger x;
@property (nonatomic) NSInteger y;
@end


#pragma mark - PlayerMove -

@interface PlayerMove : NSObject
@property (nonatomic) Piece *piece;
@property (nonatomic) Position *position;
@property (nonatomic) BOOL pass;
+ (PlayerMove *)makePiecePositionX:(NSInteger)x Y:(NSInteger)y piece:(Piece *)piece pass:(BOOL)pass;
@end

typedef void (^PlaceBlock)(NSArray *pieces);
typedef void (^CurrentPlayerBlock)(Player *player, BOOL canMove);
typedef void (^MatchStatusBlock)(BOOL gameOver);

#pragma mark - Piece -

@interface Piece : NSObject <NSCoding>
@property (nonatomic) PieceColor color;
@property (nonatomic) id userReference; // Store reference to UI object

- (BOOL)isClear;
- (void)clear;
@end

#pragma mark - Board -

@interface GameBoard : NSObject <NSCoding>

- (id)initWithBoardSize:(NSInteger)size;
- (id)initWithBoardSize:(NSInteger)size
       piecePlacedBlock:(PlaceBlock)block;

- (Piece *)pieceAtPositionX:(NSInteger)x Y:(NSInteger)y;
- (void)reset;
- (Position *)center;
- (void)visitAll:(void (^)(NSInteger x, NSInteger y, Piece *piece))block;
- (void)changePiece:(Piece *)piece withColor:(PieceColor)color;
- (BOOL)boardFull;
- (NSString *)toString;
- (NSString *)toStringAscii;
- (NSInteger)playerScore:(Player *)player;
- (BOOL)player:(Player *)player pieceAtPositionX:(NSInteger)x Y:(NSInteger)y;


@property (nonatomic) NSMutableArray *grid;
@property (nonatomic) NSInteger size;
@property (nonatomic, copy) PlaceBlock placeBlock;
@property (nonatomic) NSMutableDictionary *piecesPlayed;
@end
