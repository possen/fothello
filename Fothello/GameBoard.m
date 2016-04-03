//
//  GameBoard.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/2/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "FothelloGame.h"
#import "GameBoard.h"
#import "Player.h"

@implementation TrackInfo
@end

#pragma mark - PiecePosition -

@implementation PiecePosition
+ (PiecePosition *)makePiecePositionX:(NSInteger)x Y:(NSInteger)y piece:(Piece *)piece
{
    Position pos;
    pos.x = x;
    pos.y = y;
    PiecePosition *piecePosition = [[PiecePosition alloc] init];
    piecePosition.position = pos;
    piecePosition.piece = piece;
    return piecePosition;
}
@end


#pragma mark - Piece -

@implementation Piece

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    
    if (self)
    {
        _color = [coder decodeIntegerForKey:@"pieceColor"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.color forKey:@"pieceColor"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"pieceColor %@",self.colorStringRepresentation];
}

- (BOOL)isClear
{
    return self.color == PieceColorNone || self.color == PieceColorLegal;
}

- (void)clear
{
    self.color = PieceColorNone;
}

- (NSString *)colorStringRepresentation
{
    switch (self.color)
    {
        case PieceColorNone:
            return @".";
        case PieceColorWhite:
            return @"\u25CB";
        case PieceColorBlack:
            return @"\u25CF";
        case PieceColorRed:
            return @"R";
        case PieceColorGreen:
            return @"G";
        case PieceColorYellow:
            return @"Y";
        case PieceColorBlue:
            return @"B";
        case PieceColorLegal:
            return @"•";
    }
}

- (NSString *)colorStringRepresentationAscii
{
    switch (self.color)
    {
        case PieceColorNone:
            return @".";
        case PieceColorWhite:
            return @"O";
        case PieceColorBlack:
            return @"X";
        case PieceColorRed:
            return @"R";
        case PieceColorGreen:
            return @"G";
        case PieceColorYellow:
            return @"Y";
        case PieceColorBlue:
            return @"B";
        case PieceColorLegal:
            return @".";
    }
}


@end


#pragma mark - Board -

@implementation FBoard

- (instancetype)initWithBoardSize:(NSInteger)size
{
    return [self initWithBoardSize:size piecePlacedBlock:nil];
}

- (instancetype)initWithBoardSize:(NSInteger)size piecePlacedBlock:(PlaceBlock)block
{
    self = [super init];
    
    if (self)
    {
        _placeBlock = block;
        
        if (size % 2 == 1)
            return nil; // must be multiple of 2
        
        _grid = [[NSMutableArray alloc] initWithCapacity:size*size];
        _piecesPlayed = [[NSMutableDictionary alloc] init];
        
        // init with empty pieces
        for (NSInteger index = 0; index < size * size; index ++)
        {
            [_grid addObject:[[Piece alloc] init]];
        }
        
        _size = size;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\n%@",[self toString]];
}

- (void)updateColor:(Piece *)piece incdec:(NSInteger)incDec
{
    if ([piece isClear])
        return;
    
    NSNumber *key = @(piece.color);
    NSNumber *count = self.piecesPlayed[key];
    
    NSInteger newCount = [count integerValue] + incDec;
    self.piecesPlayed[key] = @(newCount);
}

- (void)changePiece:(Piece *)piece withColor:(PieceColor)color
{
    [self updateColor:piece incdec:-1];
    piece.color = color;
    [self updateColor:piece incdec:1];
}

- (BOOL)boardFull
{
    NSInteger total = 0;
    for (NSNumber *key in self.piecesPlayed)
    {
        NSInteger score = [self.piecesPlayed[key] integerValue];
        if (score == 0)
            return YES; // all white or all black.
        
        total += score;
    }
    
    return (total >= self.size * self.size);
}

- (NSInteger)playerScore:(Player *)player
{
    NSNumber *key = @(player.color);
    return [self.piecesPlayed[key] integerValue];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        self.grid = [coder decodeObjectForKey:@"grid"];
        self.size = [coder decodeIntegerForKey:@"size"];
        self.piecesPlayed = [coder decodeObjectForKey:@"piecesPlayed"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.grid forKey:@"grid"];
    [aCoder encodeInteger:self.size forKey:@"size"];
    [aCoder encodeObject:self.piecesPlayed forKey:@"piecesPlayed"];
}

- (Position)center
{
    Position pos;
    pos.x = self.size / 2 - 1; // zero based counting
    pos.y = self.size / 2 - 1;
    return pos;
}

- (void)reset
{
    NSMutableArray *pieces = [[NSMutableArray alloc] initWithCapacity:10];
    
    [self visitAll:^(NSInteger x, NSInteger y, Piece *piece)
     {
         [piece clear];
         if (self.placeBlock)
         {
             [pieces addObject:[PiecePosition makePiecePositionX:x Y:y piece:piece]];
         }
     }];
    
    if (self.placeBlock)
        self.placeBlock(pieces);
    
    [self.piecesPlayed removeAllObjects];
}

- (void)visitAll:(void (^)(NSInteger x, NSInteger y, Piece *piece))block
{
    NSInteger size = self.size;
    
    for (NSInteger y = 0; y < size; y++)
    {
        for (NSInteger x = 0; x < size; x++)
        {
            Piece *piece = [self pieceAtPositionX:x Y:y];
            
            block(x, y, piece);
        }
    }
}

- (NSInteger)calculateIndexX:(NSInteger)x Y:(NSInteger)y
{
    return x * self.size + y;
}

- (Piece *)pieceAtPositionX:(NSInteger)x Y:(NSInteger)y
{
    if (x >= self.size || y >= self.size || x < 0 || y < 0)
        return nil;
    
    return [self.grid objectAtIndex:[self calculateIndexX:x Y:y]];
}

- (BOOL)player:(Player *)player pieceAtPositionX:(NSInteger)x Y:(NSInteger)y
{
    Piece *piece = [self pieceAtPositionX:x Y:y];
    
    [self changePiece:piece withColor:player.color];
    
    NSMutableArray *pieces = [[NSMutableArray alloc] initWithCapacity:10];
    [pieces addObject:[PiecePosition makePiecePositionX:x Y:y piece:piece]];
    
    if (self.placeBlock)
    {
        self.placeBlock(pieces);
    }
    return YES;
}

- (void)printBanner:(NSMutableString *)boardString
{
    for (NSInteger width = 0; width < self.size + 2; width++)
    {
        [boardString appendString:@"-"];
    }
    [boardString appendString:@"\n"];
}

- (NSString *)convertToString:(BOOL)ascii
{
    NSMutableString *boardString = [[NSMutableString alloc] init];
    [self printBanner:boardString];
    
    NSInteger size = self.size;
    for (NSInteger y = size -1; y >= 0; --y)
    {
        [boardString appendString:@"|"];
        for (NSInteger x = 0; x < self.size; x++)
        {
            Piece *piece = [self pieceAtPositionX:x Y:y];
            if (ascii)
                [boardString appendString:piece.colorStringRepresentationAscii];
            else
                [boardString appendString:piece.colorStringRepresentation];
            
        }
        [boardString appendString:@"|"];
        [boardString appendString:@"\n"];
    }
    
    [self printBanner:boardString];
    return boardString;
}

- (NSString *)toString
{
    return [self convertToString:NO];
}

- (NSString *)toStringAscii
{
    return [self convertToString:YES];
}

@end


