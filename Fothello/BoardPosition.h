//
//  BoardPosition.h
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/27/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BoardPosition : NSObject <NSCopying>

// thses are in zero offset coordinates
@property (nonatomic) NSInteger x;
@property (nonatomic) NSInteger y;

- (nonnull instancetype)initWithX:(NSInteger)x Y:(NSInteger)y;
+ (nonnull instancetype)positionWithX:(NSInteger)x Y:(NSInteger)y;
- (nonnull instancetype)addPosition:(nonnull BoardPosition *)pos;
@end
