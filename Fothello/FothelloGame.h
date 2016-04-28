//
//  Fothello.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/10/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>


@class Match;
@class Player;
@class Strategy;

typedef NS_ENUM(NSInteger, PieceColor)
{
    PieceColorNone,
    PieceColorBlack,
    PieceColorWhite,
    PieceColorRed,     // for 3 or more players
    PieceColorBlue,
    PieceColorGreen,
    PieceColorYellow,
    PieceColorLegal    // show legal moves
};

#pragma mark - Fothello -

@interface FothelloGame : NSObject <NSCoding>

+ (id)sharedInstance;

@property (nonatomic) NSMutableDictionary <NSString *, Match *> *matches;
@property (nonatomic) NSMutableArray <Player *> *players;

- (Player *)newPlayerWithName:(NSString *)name
          preferredPieceColor:(PieceColor)preferredPieceColor;

@end






