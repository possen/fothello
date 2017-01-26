//
//  InterfaceController.h
//  FothelloWatch Extension
//
//  Created by Paul Ossenbruggen on 6/14/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@class Match;

@interface InterfaceController : WKInterfaceController <WKCrownDelegate>
@property (nonatomic) Match *match;
@end
