//
//  AIStrategy.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/18/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import "FothelloGame.h"

struct Board;
@interface AIStrategy : Strategy
{
    struct Board *_board;
}

@property (nonatomic) BOOL firstPlayer;
@end
