//
//  GameBoardLegalMoves.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/20/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FothelloGame.h"

@class BoardPiece;
@class GameBoardInternal;
@class PlayerMove;

@interface GameBoardLegalMoves : NSObject

- (nonnull instancetype)initWithGameBoard:(nonnull GameBoardInternal *)gameBoard;
- (nonnull NSArray<BoardPiece *> *)findLegals:(nonnull NSArray<BoardPiece *> *)pieces;
- (nonnull NSArray <BoardPiece *> *)legalMove:(nonnull PlayerMove *)move forPlayer:(nonnull Player *)player;
- (BOOL)isLegalMove:(nonnull PlayerMove *)move forPlayer:(nonnull Player *)player;
- (nonnull NSArray <BoardPiece *> *)legalMovesForPlayerColor:(PieceColor)color;

@property (nonatomic,nonnull) NSMutableArray<NSArray<BoardPiece *>*> *legalMovesForPlayer;

@end
