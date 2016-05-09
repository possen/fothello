//
//  MovesViewAdapter.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/8/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Match;

@interface MovesViewAdapter : NSObject  <NSTableViewDelegate, NSTableViewDataSource>
@property (nonatomic) Match *match;

- (instancetype)initWithMatch:(Match *)match;

@end
