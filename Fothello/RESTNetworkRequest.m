//
//  RESTReqeust.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/5/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "RESTNetworkRequest.h"

@interface RESTNetworkRequest ()
@property (nonatomic, copy) NSURL *baseUrl;
@property (nonatomic, copy) NSString *command;
@property (nonatomic, copy) NSString *query;
@property (nonatomic) NSURLSession *session;
@end

@implementation RESTNetworkRequest

- (instancetype)initWithCommand:(NSString *)command query:(NSString *)query
{
    self = [super init];
    if (self)
    {
        NSString *baseUrlStr = @"http://ec2-52-37-209-218.us-west-2.compute.amazonaws.com";
        _baseUrl = [NSURL URLWithString:baseUrlStr];
        _command = command;
        _query = query ? [NSString stringWithFormat:@"?%@", query] : nil;
        _session = [NSURLSession sharedSession];
        _session.configuration.timeoutIntervalForResource = 10;

    }
    return self;
}

- (void)sendRequestWithData:(NSData *)postData
                 completion:(void (^)(NSData *data, NSError *error))completion
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@%@", self.baseUrl, self.command, self.query];

    NSURL *url = [NSURL URLWithString:urlString relativeToURL:self.baseUrl];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    urlRequest.HTTPBody = postData;
    urlRequest.HTTPMethod = @"POST";

    NSURLSessionTask *task = [self.session dataTaskWithRequest:urlRequest
                                             completionHandler:
    ^(NSData *data, NSURLResponse *response, NSError *error) {
        completion(data, error);
    }];
    
    [task resume];
    
}
@end
