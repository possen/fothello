//
//  Document.h
//  FothelloMac
//
//  Created by Paul Ossenbruggen on 4/20/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Match;

@interface Document : NSDocument
@property (nonatomic) Match *match;
@end

