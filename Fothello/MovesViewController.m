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

@interface MovesViewController ()
@property (nonatomic) IBOutlet NSTableView *tableView;
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
 
    self.adapter = [[MovesViewAdapter alloc] initWithMatch:self.match];
    self.tableView.delegate = self.adapter;
    self.tableView.dataSource = self.adapter;
    __weak typeof(self) weakSelf = self;
    
    self.match.movesUpdateBlock = ^{
        [weakSelf.tableView reloadData];
    };
}


@end
