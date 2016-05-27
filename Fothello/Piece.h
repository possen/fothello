//
//  Piece.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/27/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FothelloGame.h"

#pragma mark - Piece -

@interface Piece : NSObject <NSCoding, NSCopying>
@property (nonatomic, readwrite) PieceColor color;
@property (nonatomic, nullable) id userReference; // Store reference to UI object

- (nonnull instancetype)initWithColor:(PieceColor)color;
+ (nonnull NSString *)stringFromColor:(PieceColor)color;

- (BOOL)isClear;
- (void)clear;
- (nonnull NSString *)colorStringRepresentation;
- (nonnull NSString *)colorStringRepresentationAscii;

@end

