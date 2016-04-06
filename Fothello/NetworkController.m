//
//  NetworkController.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/5/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "NetworkController.h"

@implementation NetworkController

- (void)sendRequest:(RESTNetworkRequest *)request
            sendData:(NSData *)data
         completion:(void (^)(NSData *receiveData, NSError *error))block
{
    [request sendRequestWithData:data completion:block];
}

@end
