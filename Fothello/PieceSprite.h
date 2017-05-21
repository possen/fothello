//
//  PieceSprite.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/20/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <SceneKit/SceneKit.h>
#import "FothelloGame.h"

@class BoardScene;
@class Piece;

@interface PieceSprite : NSObject

- (instancetype)initWithBoardScene:(BoardScene *)boardScene;
- (SKNode *)makePieceWithColor:(PieceColor)color size:(CGSize)size;
- (void)placeSpriteAtX:(NSInteger)x Y:(NSInteger)y withPiece:(Piece *)piece;
- (void)higlightAtX:(NSInteger)x y:(NSInteger)y color:(PieceColor)color;

@end
