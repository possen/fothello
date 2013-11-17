//
//  MyScene.h
//  Fothello
//

//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class FothelloGame;

@interface BoardScene : SKScene

@property (nonatomic) FothelloGame *game;

@property (nonatomic,readonly) NSInteger boardDimensions;
@property (nonatomic,readonly) CGRect boardRect;
@property (nonatomic,readonly) NSInteger boardSize;

@end
