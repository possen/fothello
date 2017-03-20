
    //
//  FothelloGameGameKit.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 2/22/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <GameKit/GameKit.h>
#import <CloudKit/CloudKit.h>

#import "FothelloGameGameKit.h"

@interface FothelloGameGameKit () 
@property (nonatomic) NSArray<GKGameSession *> *sessions;
@end

@implementation FothelloGameGameKit

- (Match *)createMatchFromKind:(PlayerKindSelection)kind difficulty:(Difficulty)difficulty
{
    switch (kind)
    {
        case PlayerKindSelectionHumanVGameCenter:
        {
            // watch does not create a match only allows playing of existing matches.
            CKContainer *defaultContainer = [CKContainer defaultContainer];
            NSString *containerName = [defaultContainer containerIdentifier];
            
            [GKGameSession createSessionInContainer:containerName
                                          withTitle:@"GameKit"
                                maxConnectedPlayers:2
                                  completionHandler:
             ^(GKGameSession *session, NSError *error)
             {}];
            break;
        }
        default:
            break;
    }

    return [super createMatchFromKind:kind difficulty:difficulty];
}

- (void)loadMatches
{
    CKContainer *defaultContainer = [CKContainer defaultContainer];

    [GKGameSession loadSessionsInContainer:defaultContainer.containerIdentifier
                         completionHandler:^(NSArray<GKGameSession *> *sessions, NSError *error)
     {
         NSAssert(error != nil, @"error %@", error);

         self.sessions = sessions;
     }];
}

- (void)saveMatches
{
    for (Match *match in self.matches)
    {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
        [match.session saveData:data
              completionHandler:^(NSData *conflictingData, NSError * error)
         {
             NSAssert(error != nil, @"error %@", error);
           
         }];
    }
}
@end
