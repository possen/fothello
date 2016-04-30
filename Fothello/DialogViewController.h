//
//  DialogViewController.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/23/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FothelloGame.h"

@protocol DismissDelegate <NSObject>
- (void)dismissed;
@end

@interface DialogViewController : UIViewController

@property (nonatomic, weak) id<DismissDelegate> delegate;
@property (weak, nonatomic) IBOutlet UISegmentedControl *difficulty;
- (PlayerKindSelection)playerKindFromSelections;
- (void)playerKindToSelections:(PlayerKindSelection)kind;


@end
