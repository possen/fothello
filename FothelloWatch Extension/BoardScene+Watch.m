//
//  BoardScene+Watch.m
//  FothelloWatch Extension
//
//  Created by Paul Ossenbruggen on 9/17/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import "BoardScene+Watch.h"

@implementation BoardScene (Watch)
- (void)presentWithUpdatePlayerMove:(UpdatePlayerMove)updateMove
{
    [self presentCommon:updateMove];
}
@end
