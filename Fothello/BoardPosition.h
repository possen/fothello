//
//  BoardPosition.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/27/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BoardPosition : NSObject <NSCopying>

@property (nonatomic) NSInteger x;
@property (nonatomic) NSInteger y;

- (nonnull instancetype)initWithX:(NSInteger)x Y:(NSInteger)y;
+ (nonnull instancetype)positionWithX:(NSInteger)x y:(NSInteger)y;

@end
