//
//  Piece.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/27/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "Piece.h"
#import "FothelloGame.h"

#pragma mark - Piece -

@implementation Piece

- (instancetype)copyWithZone:(NSZone *)zone
{
    Piece *piece = [[self class] allocWithZone:zone];
    piece.color = self.color;
    piece.userReference = self.userReference;
    return piece;
}

- (instancetype)initWithColor:(PieceColor)color
{
    self = [super init];
    if (self)
    {
        _color = color;
    }
    return self;
}

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
    return [NSString stringWithFormat:@"%@", self.colorStringRepresentation];
}

- (BOOL)isClear
{
    return self.color == PieceColorNone || self.color == PieceColorLegal;
}

- (void)clear
{
    self.color = PieceColorNone;
}

+ (NSString *)stringFromColor:(PieceColor)color
{
    switch (color)
    {
        case PieceColorNone:
            return @"\u00B7";
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
            return @"\u25EE";
    }
}

- (nonnull NSString *)colorStringRepresentation
{
    return [Piece stringFromColor:self.color];
}

- (nonnull NSString *)colorStringRepresentationAscii
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
