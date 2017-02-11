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

typedef NS_ENUM(NSInteger, Difficulty)
{
    DifficultyNone = 0,
    DifficultyEasy,
    DifficultyModerate,
    DifficultyHard,
    DifficultyHardest
};

typedef NS_ENUM(NSInteger, PlayerKindSelection)
{
    PlayerKindSelectionHumanVHuman,
    PlayerKindSelectionHumanVComputer,
    PlayerKindSelectionComputerVHuman,
    PlayerKindSelectionComputerVComputer,
    PlayerKindSelectionHumanVGameCenter
};

typedef NS_ENUM(NSInteger, PieceColor)
{
    PieceColorNone,
    PieceColorBlack,
    PieceColorWhite,
    PieceColorRed,     
    PieceColorBlue,
    PieceColorGreen,
    PieceColorYellow,
    PieceColorLegal    // show legal moves
};

#pragma mark - Fothello -

typedef void (^GameOverBlock)();

@interface FothelloGame : NSObject <NSCoding>

+ (nonnull id)sharedInstance;

@property (nonnull, nonatomic) NSMutableArray <NSString *> *matchOrder;
@property (nonnull, nonatomic) NSMutableDictionary <NSString *, Match *> *matches;
@property (nonnull, nonatomic) NSMutableArray <Player *> *players;
@property (nonatomic, copy, nullable) GameOverBlock gameOverBlock; // only for testing.

- (nonnull Player *)newPlayerWithName:(nonnull NSString *)name
          preferredPieceColor:(PieceColor)preferredPieceColor;

- (nonnull Match *)createMatchFromKind:(PlayerKindSelection)kind difficulty:(Difficulty)difficulty;

@end






