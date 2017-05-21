//
//  GameBoardTracks.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/20/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FothelloGame.h"

@class GameBoardInternal;
@class BoardPiece;
@class BoardPosition;

@interface GameBoardTracks : NSObject

- (nonnull instancetype)initWithGameBoard:(nonnull GameBoardInternal *)gameBoard;
- (nonnull NSArray<NSArray <BoardPiece *> *> *)findTracksForBoardPiece:(nonnull BoardPiece *)boardPiece
                                                         color:(PieceColor)pieceColor;

// Non queued versions, must be wrapped in updateBoard).
- (void)boxCoord:(NSInteger)dist
           block:(nonnull void (^)(BoardPosition * _Nonnull position, BOOL isCorner, NSInteger count, BOOL * _Nullable stop))block;

@end
