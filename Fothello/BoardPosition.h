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
@property (nonatomic, readonly, getter=isPass) BOOL pass;

- (nonnull instancetype)initWithPass;
- (nonnull instancetype)initWithX:(NSInteger)x Y:(NSInteger)y;

+ (nonnull instancetype)positionWithPass;
+ (nonnull instancetype)positionWithX:(NSInteger)x y:(NSInteger)y;
+ (nonnull instancetype)positionWithX:(NSInteger)x y:(NSInteger)y pass:(BOOL)pass;

@end
