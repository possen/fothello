//
//  AppDelegate.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/11/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import "AppDelegate.h"
#import "FothelloGame.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    FothelloGame *game = [FothelloGame sharedInstance];
    [game saveGameState];
}

@end
