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
#import "MatchMoves.h"
#import "GameBoard.h"

@interface MovesViewAdapter ()
@property (nonatomic) NSTableView *tableView;
@end

@implementation MovesViewAdapter

- (instancetype)initWithMatch:(Match *)match tableView:(NSTableView *)tableView
{
    self = [super init];
    
    if (self)
    {
        _match = match;
        _tableView = tableView;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return self;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.match.matchMoves.moves.count;
}

- (NSTableCellView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *movesIdentifier = @"movesID";
    NSTableCellView *cell = [tableView makeViewWithIdentifier:movesIdentifier owner: nil];
    PlayerMove *move = self.match.matchMoves.moves[row];
    cell.textField.stringValue = [move description];
    return cell;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSInteger row = self.tableView.selectedRow;
    PlayerMove *move = self.match.matchMoves.moves[row];
    [self.match.board showClickedMove:move forPieceColor:move.color];
    [self.tableView scrollRowToVisible:row];
}

@end
