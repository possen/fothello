//
//  AppDelegate.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/11/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import "AppDelegate.h"
#import "FothelloGame.h"
#import "DialogViewController.h"
#import <VungleSDK/VungleSDK.h>

#define VungleAPIKey @"5894de4c3fcbdb6757000433"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    VungleSDK *vungle = [VungleSDK sharedSDK];
    [vungle startWithAppId:VungleAPIKey];

    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;    
}


- (void)application:(UIApplication *)application willEncodeRestorableStateWithCoder:(NSCoder *)coder
{
    FothelloGame *game = [FothelloGame sharedInstance];
    [game saveGameState];
}

- (void)application:(UIApplication *)application didDecodeRestorableStateWithCoder:(NSCoder *)coder
{
    [FothelloGame sharedInstance];
}

@end
