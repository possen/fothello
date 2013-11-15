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
    // Override point for customization after application launch.
        
    NSString *docsPath
        = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
           objectAtIndex:0];
    
    NSString *filename = [docsPath stringByAppendingPathComponent:@"Fothello"];
    
    FothelloGame *fothello ;//= [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
    if (fothello == nil)
    {
        fothello = [[FothelloGame alloc] init];
    }
    
    Match *match = fothello.currentMatch;
    [match reset];
    
    BOOL couldMove1; BOOL couldMove2;
    
    do
    {
        couldMove1 = [match.currentPlayer takeTurn];
        [match nextPlayer];
        
        couldMove2 = [match.currentPlayer takeTurn];
        [match nextPlayer];
        
    } while (couldMove1 || couldMove2);
    
    [NSKeyedArchiver archiveRootObject:fothello toFile:filename];

    return YES;
}
							
@end
