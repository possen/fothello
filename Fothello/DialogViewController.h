//
//  DialogViewController.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/23/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DialogViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *playerType;
@property (weak, nonatomic) IBOutlet UISegmentedControl *humanPlayerColor;
@property (weak, nonatomic) IBOutlet UISegmentedControl *difficulty;
@property (weak, nonatomic) IBOutlet UILabel *difficultyLabel;

- (IBAction)againstAction:(UISegmentedControl *)sender;
- (IBAction)humanPlayerColorAction:(UISegmentedControl *)sender;
- (IBAction)difficultyAction:(UISegmentedControl *)sender;

@end
