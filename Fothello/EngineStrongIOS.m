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

@interface EngineStrongIOS () <WCSessionDelegate>
@property (nonatomic)WCSession *session;
@end

@implementation EngineStrongIOS

+ (instancetype)engine
{
    __block EngineStrongIOS *result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[EngineStrongIOS alloc] init];
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

- (void)sesion:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *, id> *)applicationContext
{
    NSAssert(false, @"implement");
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
