//
//  MovesViewController.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/8/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "MovesViewController.h"
#import "MovesViewAdapter.h"
#import "Match.h"
#import "PlayerMove.h"
#import "MatchMoves.h"
#import "GameBoard.h"


@interface MovesViewController ()
@property (weak, nonatomic) IBOutlet NSTableView *tableView;
@property (nonatomic) Match *match;
@property (nonatomic) MovesViewAdapter *adapter;
@end

@implementation MovesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    FothelloGame *game = [FothelloGame sharedInstance];
    
    NSAssert(game.matches.count != 0, @"matches empty");
    self.match = game.matches.allValues[0];
    
    self.adapter = [[MovesViewAdapter alloc] initWithMatch:self.match tableView:self.tableView];
}

- (IBAction)selectAction:(NSTextFieldCell *)sender
{
    NSInteger row = self.tableView.selectedRow;
    PlayerMove *move = self.match.matchMoves.moves[row];
    [self.match.board showClickedMove:move forPieceColor:move.color];
}

- (void)resetGame:(Match *)match
{
    self.match = match;
    self.adapter.match = match;
    
    __weak MovesViewController *weakSelf = self;
    self.match.movesUpdateBlock = ^{
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [weakSelf.tableView reloadData];
                       });
    };
}

@end
