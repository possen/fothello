//
//  NetworkController.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/5/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RESTNetworkRequest.h"

@interface NetworkController : NSObject
- (void)sendRequest:(RESTNetworkRequest *)request
               sendData:(NSData *)data
         completion:(void (^)(NSData *receiveData, NSError *error))block;

@end
