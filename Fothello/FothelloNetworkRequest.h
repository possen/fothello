//
//  FothelloNetworkRequest.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/5/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "RESTNetworkRequest.h"

@interface FothelloNetworkRequest : RESTNetworkRequest
- (instancetype)initWithQuery:(NSString *)query;

@end
