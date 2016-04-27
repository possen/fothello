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

#pragma mark - Fothello -

@interface FothelloGame : NSObject <NSCoding>

+ (id)sharedInstance;

@property (nonatomic) NSMutableDictionary <NSString *, Match *> *matches;
@property (nonatomic) NSMutableArray <Player *> *players;
@end






