//
//  BoardPosition.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 5/27/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "BoardPosition.h"

@implementation BoardPosition

- (instancetype)copyWithZone:(NSZone *)zone
{
    BoardPosition *position = [[self class] allocWithZone:zone];
    position.x = self.x;
    position.y = self.y;
    return position;
}

+ (instancetype)positionWithX:(NSInteger)x y:(NSInteger)y
{
    BoardPosition *position = [[BoardPosition alloc] initWithX:x Y:y];
    return position;
}

- (instancetype)initWithX:(NSInteger)x Y:(NSInteger)y
{
    self = [super init];
    if (self)
    {
        _x = x;
        _y = y;
    }
    return self;
}

- (NSUInteger)hash
{
    return self.x ^ self.y;
}

- (BOOL)isEqual:(BoardPosition *)object
{
    return self.x == object.x && self.y == object.y;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%c%ld", (char)self.x +'A', (long)self.y+1];
}
@end

