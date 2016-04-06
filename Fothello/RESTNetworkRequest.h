//
//  RESTReqeust.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/5/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RESTNetworkRequest : NSObject
- (instancetype)initWithCommand:(NSString *)command query:(NSString *)query;
- (void)sendRequestWithData:(NSData *)postData completion:(void (^)(NSData *data, NSError *error))completion;
@end
