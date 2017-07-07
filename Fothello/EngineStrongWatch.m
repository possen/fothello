//
//  EngineStrongIOS.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 2/19/17.
//  Copyright © 2017 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import "Engine.h"
#import "EngineStrong.h"

@interface EngineStrongWatch () <WCSessionDelegate>
@property (nonatomic)WCSession *session;
@end

@implementation EngineStrongWatch

+ (instancetype)engine
{
    __block EngineStrongWatch *result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[EngineStrongWatch alloc] init];
    });
    return result;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _session = [WCSession defaultSession];
        _session.delegate = self;
        [_session activateSession];
    }
    return self;
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message
   replyHandler:(void(^)(NSDictionary<NSString *, id> *replyMessage))replyHandler
{
    Difficulty difficulty = [message[@"difficulty"] integerValue];
    NSInteger moveNumber = [message[@"moveNum"] integerValue];
    PieceColor pieceColor = [message[@"color"] integerValue];
    NSString *board = [message[@"board"] stringValue];
    
    NSDictionary *replyMessage = [self calculateMoveWithBoard:board
                                                  playerColor:pieceColor
                                                   moveNumber:moveNumber
                                                    diffculty:difficulty];
    NSLog(@"IOS %@", replyMessage);
    return replyHandler(replyMessage);
}

- (void)sesion:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *, id> *)data
{
    NSLog(@"%s", __FUNCTION__);
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

@end
