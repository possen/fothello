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
@property (nonatomic, nonnull) Match *match;

- (nonnull instancetype)initWithMatch:(nonnull Match *)match tableView:(nonnull NSTableView *)tableView;

@end
