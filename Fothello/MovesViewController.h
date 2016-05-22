//
//  MovesViewController.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/8/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Match;

@interface MovesViewController : NSViewController
- (void)resetGame:(Match *)match;
@end
