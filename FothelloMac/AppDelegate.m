//
//  AppDelegate.m
//  FothelloMac
//
//  Created by Paul Ossenbruggen on 4/20/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "AppDelegate.h"
#import <FothelloLib/FothelloLib.h>

@interface AppDelegate () <NSMenuDelegate>
@property (weak) IBOutlet NSMenuItem *hideMenuItem;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    FothelloGame *game = [FothelloGame sharedInstance];
    NSMenu *menu = [[NSApplication sharedApplication] mainMenu];

    // UI tests dont work if we don't do this, menu is not updating. x
    game.gameOverBlock = ^
    {
        self.hideMenuItem.enabled = NO;

        // this should do the trick but it seems it needs the enabled above.
        [menu update];
    };
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
