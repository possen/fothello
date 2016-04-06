//
//  FothelloNetworkRequest.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/5/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "FothelloNetworkRequest.h"

@implementation FothelloNetworkRequest

- (instancetype)initWithQuery:(NSString *)query
{
    self = [super initWithCommand:@"fothellows" query:query];
    return self;
}

@end
