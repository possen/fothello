//
//  GameScene.m
//  FothelloWatch Extension
//
//  Created by Paul Ossenbruggen on 6/14/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene
{
    SKShapeNode *_spinnyNode;
}

- (void)sceneDidLoad
{
    // Setup your scene here
    
    // Get label node from scene and store it for use later
    SKLabelNode *label = (SKLabelNode *)[self childNodeWithName:@"//helloLabel"];
    
    label.alpha = 0.0;
    [label runAction:[SKAction fadeInWithDuration:2.0]];
    
    CGFloat w = (self.size.width + self.size.height) * 0.3;
    
    _spinnyNode = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(w, w) cornerRadius:w * 0.3];
    _spinnyNode.lineWidth = 8.0;
    
    [_spinnyNode runAction:[SKAction sequence:@[
                                                [SKAction waitForDuration:0.5],
                                                [SKAction fadeOutWithDuration:0.5],
                                                [SKAction removeFromParent],
                                                ]]];
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:2.0],
                                                                       [SKAction runBlock:^{
        SKShapeNode *n = [_spinnyNode copy];
        n.position = CGPointMake(0.0, 0.0);
        
        n.strokeColor = [SKColor greenColor];
        [n runAction:[SKAction repeatActionForever:[SKAction rotateByAngle:M_PI_2 duration:1]]];
        
        [self addChild:n];
    }]]]]];
}

-(void)update:(CFTimeInterval)currentTime
{
    // Called before each frame is rendered
}

@end
