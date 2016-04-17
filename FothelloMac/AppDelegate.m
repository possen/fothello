//
//  AppDelegate.m
//  FothelloMac
//
//  Created by Paul Ossenbruggen on 4/15/16.
//  Copyright (c) 2016 Paul Ossenbruggen. All rights reserved.
//

#import "AppDelegate.h"
#import "BoardScene.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end
