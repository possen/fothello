//
//  MyScene.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/11/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import "BoardScene.h"
#import "FothelloGame.h"

@implementation BoardScene

- (void)syncronizeBoardStateWithModel
{
    Board *board = self.game.currentMatch.board;
    [board visitAll:^(NSInteger x, NSInteger y, Piece *piece)
     {
         [self placeSpriteAtX:x Y:y withPiece:piece];
     }];
}

- (id)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    
    if (self)
    {
        _boardDimensions = 280;
        _boardRect = CGRectMake(20, 100, _boardDimensions, _boardDimensions);
        _game = [FothelloGame sharedInstance];
        _boardSize = self.game.currentMatch.board.size;
        
        __weak BoardScene *weakBlockSelf = self;
        
        _game.currentMatch.board.placeBlock =
            ^(NSInteger x, NSInteger y, Piece *piece)
            {
                [weakBlockSelf placeSpriteAtX:x Y:y withPiece:piece];
            };
        
        [self syncronizeBoardStateWithModel];
        
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:.0 green:.70 blue:0.3 alpha:1.0];
        
        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        
        myLabel.text = @"Fothello";
        myLabel.fontSize = 30;
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame), 20);
        
        CGRect boardRect = self.boardRect;
        NSInteger boardDimensions = self.boardDimensions;
        SKShapeNode *boardUI = [SKShapeNode node];
        
        CGMutablePathRef pathToDraw = CGPathCreateMutable();
        CGPathMoveToPoint(pathToDraw, NULL, boardRect.origin.x, boardRect.origin.y);
        CGPathAddRect(pathToDraw, NULL, CGRectMake(boardRect.origin.x,
                                                   boardRect.origin.y,
                                                   boardRect.size.width,
                                                   boardRect.size.height));
        
        NSInteger spacing = boardDimensions / _boardSize;
        for (NSInteger lines = 0; lines < boardDimensions; lines += spacing)
        {
            CGPathMoveToPoint(pathToDraw, NULL,
                              boardRect.origin.x,
                              boardRect.origin.y + lines);
            
            CGPathAddLineToPoint(pathToDraw, NULL,
                                 boardRect.origin.x + boardRect.size.width,
                                 boardRect.origin.y + lines);
            
            CGPathMoveToPoint(pathToDraw, NULL,
                              boardRect.origin.x + lines,
                              boardRect.origin.y);
            
            CGPathAddLineToPoint(pathToDraw, NULL,
                                 boardRect.origin.x + lines,
                                 boardRect.origin.y + boardRect.size.width);
        }
        
        boardUI.path = pathToDraw;
        [boardUI setStrokeColor:[UIColor whiteColor]];
        [self addChild:boardUI];
        [self addChild:myLabel];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    /* Called when a touch begins */
    CGRect boardRect = self.boardRect;
    NSInteger boardSize = self.boardSize;
    NSInteger spacing = self.boardDimensions / self.boardSize;
    
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:self];
        
        NSInteger x = (location.x - boardRect.origin.x) / spacing;
        NSInteger y = (location.y - boardRect.origin.y) / spacing;
        
        if (x < boardSize && y < boardSize)
        {
            Match *match = self.game.currentMatch;
            BOOL couldMove1; BOOL couldMove2;

            couldMove1 = [match.currentPlayer takeTurn];
            [match nextPlayer];
        }
    }
}

- (NSString *)pieceColorToFileName:(PieceColor)color
{
    switch (color)
    {
        case PieceColorBlack:
            return @"violet-sphere";
        case PieceColorWhite:
            return @"green-sphere";
        default:
            break;
    }
    return nil;
}

- (void)placeSpriteAtX:(NSInteger)x Y:(NSInteger)y withPiece:(Piece *)piece
{
    CGRect boardRect = self.boardRect;
    NSInteger boardSize = self.boardSize;
    NSInteger spacing = self.boardDimensions / boardSize;
    
    [piece.identifier removeFromParent];
    piece.identifier = nil;
    
    if (piece.color != PieceColorNone)
    {
        NSString *filename = [self pieceColorToFileName:piece.color];
        CGSize spriteSize = CGSizeMake(30, 30);
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:filename];

        sprite.position
            = CGPointMake(x * spacing + boardRect.origin.x + spriteSize.width / 2 + 3,
                          y * spacing + boardRect.origin.y + spriteSize.height / 2 + 2);

        sprite.size = spriteSize;
        [self addChild:sprite];
        piece.identifier = sprite;
    }
    else
    {
        
    }
}


- (void)update:(CFTimeInterval)currentTime
{
    /* Called before each frame is rendered */
}

@end
