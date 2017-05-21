//
//  GameBoardLegalMoves.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/20/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BoardPiece;
@class GameBoardInternal;

@interface GameBoardLegalMoves : NSObject

- (nonnull instancetype)initWithGameBoard:(nonnull GameBoardInternal *)gameBoard;

@property (nonatomic,nonnull) NSMutableArray<NSArray<BoardPiece *>*> *legalMovesForPlayer;

@end
