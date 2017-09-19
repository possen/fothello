//
//  EngineWatch.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 2/18/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import "Engine.h"
#import "Match.h"
#import "Player.h"
#import "GameBoard.h"

@interface EngineWeakWatch () <WCSessionDelegate>
@property (nonatomic)WCSession *session;
@end

@implementation EngineWeakWatch

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        if ([WCSession isSupported])
        {
            _session = [WCSession defaultSession];
            _session.delegate = self;
            [_session activateSession];
        }
        else
        {
            return nil; 
        }
    }
    return self;
}

- (void)session:(WCSession *)session
activationDidCompleteWithState:(WCSessionActivationState)activationState
          error:(NSError *)error
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)sessionDidBecomeInactive:(WCSession *)session
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)sessionDidDeactivate:(WCSession *)WCSession
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)seed:(NSString *)seed
{
    // don't genereate randome numbers here.
}

- (NSDictionary<NSString *, id> *)calculateMoveForPlayer:(PieceColor)playerColor
                                                   match:(Match *)match
                                              difficulty:(Difficulty)difficulty
{
    int moveNum = (int)match.board.piecesPlayed.count;
    
    NSMutableDictionary *applicationData = [[NSMutableDictionary alloc] initWithCapacity:5];
    applicationData[@"playerColor"] = [NSString stringWithFormat:@"%d", playerColor];
    applicationData[@"board"] = [match.board requestFormat];
    applicationData[@"moveNum"] = [@(moveNum) stringValue];
    applicationData[@"difficulty"] = @(difficulty);

    NSCondition *condition = [[NSCondition alloc] init];
    __block NSDictionary<NSString *,id> *response = nil;
    
    [self.session sendMessage:applicationData
                 replyHandler:^(NSDictionary<NSString *,id> *replyMessage)
    {
        response = replyMessage;
        [condition signal];
        [condition unlock];
    }
                 errorHandler:^(NSError *error)
    {
        [response mutableCopy][@"error"]  = error;
        [condition signal];
        [condition unlock];
    }];
    
    [condition lock];
    [condition wait];
    NSLog(@"watch %@", response);
    return response;
}

@end
