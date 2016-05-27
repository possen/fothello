//
//  MovesViewAdapter.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/8/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "MovesViewAdapter.h"
#import "Match.h"
#import "PlayerMove.h"

@interface MovesViewAdapter ()
@end

@implementation MovesViewAdapter

- (instancetype)initWithMatch:(Match *)match
{
    self = [super init];
    
    if (self)
    {
        _match = match;
    }
    
    return self;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.match.moves.count;
}

- (NSTableCellView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *movesIdentifier = @"movesID";
    NSTableCellView *cell = [tableView makeViewWithIdentifier:movesIdentifier owner: nil];
    PlayerMove *move = self.match.moves[row];
    cell.textField.stringValue = [move description];
    return cell;
}


@end
