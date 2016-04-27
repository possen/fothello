//
//  NewGameViewController.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/26/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "NewGameViewController.h"

@interface NewGameViewController ()

@end

@implementation NewGameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)dismissController:(id)sender
{
    [super dismissController:sender];
    NSLog(@"sender %@", sender);
}
@end
