//
//  GameBoard.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 4/2/16.
//  Copyright © 2016 Paul Ossenbruggen. All rights reserved.
//

#import "FothelloGame.h"
#import "GameBoard.h"
#import "Player.h"


#pragma mark - Move -

@implementation BoardPosition

- (instancetype)copyWithZone:(NSZone *)zone
{
    BoardPosition *position = [[self class] allocWithZone:zone];
    position.x = self.x;
    position.y = self.y;
    return position;
}

+ (instancetype)positionWithPass
{
    return [[BoardPosition alloc] initWithPass];
}

+ (instancetype)positionWithX:(NSInteger)x y:(NSInteger)y
{
    BoardPosition *position = [[BoardPosition alloc] initWithX:x Y:y];
    return position;
}

+ (instancetype)positionWithX:(NSInteger)x y:(NSInteger)y pass:(BOOL)pass
{
    BoardPosition *position = pass ? [[BoardPosition alloc] initWithPass] : [[BoardPosition alloc] initWithX:x Y:y];
    return position;
}

- (BOOL)pass
{
    return self.x < 0 || self.y < 0;
}

- (instancetype)initWithPass
{
    self = [super init];
    if (self)
    {
        _x = -1;
        _y = -1;
    }
    return self;
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
@end

#pragma mark - BoardPiece -

@implementation BoardPiece

- (instancetype)copyWithZone:(NSZone *)zone
{
    BoardPiece *boardPiece = [[self class] allocWithZone:zone];
    boardPiece.piece = [self.piece copy];
    boardPiece.position = [self.position copy];
    boardPiece.color = self.color;
    return boardPiece;
}

+ (BoardPiece *)makeBoardPieceWithPiece:(Piece *)piece position:(BoardPosition *)pos color:(PieceColor)color
{
    BoardPiece *boardPiece = [[BoardPiece alloc] init];
    boardPiece.piece = piece;
    boardPiece.position = pos;
    boardPiece.color = color;
    return boardPiece;
}

- (NSUInteger)hash
{
    return self.position.hash ^ self.piece.color;
}

- (BOOL)isEqual:(BoardPiece *)other
{
    return [self.position isEqual:other.position]
        && self.piece.color == other.piece.color;
}

- (NSString *)description
{
    return (self.position.x != -1)
    ? [NSString stringWithFormat:@"%ld - %ld %@ -> %@", (long)self.position.x + 1,
                                                  (long)self.position.y + 1, self.piece.description,
                                                  [Piece stringFromColor:self.color]]
    : [NSString stringWithFormat:@"Pass %@", self.piece.description];
}

@end

#pragma mark - Piece -

@interface Piece ()
@property (nonatomic, readwrite) PieceColor color;
@end

@implementation Piece

- (instancetype)copyWithZone:(NSZone *)zone
{
    Piece *piece = [[self class] allocWithZone:zone];
    piece.color = self.color;
    piece.userReference = self.userReference;
    return piece;
}

- (instancetype)initWithColor:(PieceColor)color
{
    self = [super init];
    if (self)
    {
        _color = color;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    
    if (self)
    {
        _color = [coder decodeIntegerForKey:@"pieceColor"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.color forKey:@"pieceColor"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", self.colorStringRepresentation];
}

- (BOOL)isClear
{
    return self.color == PieceColorNone || self.color == PieceColorLegal;
}

- (void)clear
{
    self.color = PieceColorNone;
}

+ (NSString *)stringFromColor:(PieceColor)color
{
    switch (color)
    {
        case PieceColorNone:
            return @".";
        case PieceColorWhite:
            return @"\u25CB";
        case PieceColorBlack:
            return @"\u25CF";
        case PieceColorRed:
            return @"R";
        case PieceColorGreen:
            return @"G";
        case PieceColorYellow:
            return @"Y";
        case PieceColorBlue:
            return @"B";
        case PieceColorLegal:
            return @"•";
    }
}

- (nonnull NSString *)colorStringRepresentation
{
    return [Piece stringFromColor:self.color];
}

- (nonnull NSString *)colorStringRepresentationAscii
{
    switch (self.color)
    {
        case PieceColorNone:
            return @".";
        case PieceColorWhite:
            return @"O";
        case PieceColorBlack:
            return @"X";
        case PieceColorRed:
            return @"R";
        case PieceColorGreen:
            return @"G";
        case PieceColorYellow:
            return @"Y";
        case PieceColorBlue:
            return @"B";
        case PieceColorLegal:
            return @".";
    }
}

@end


#pragma mark - GameBoard -

@interface GameBoard ()
@property (nonatomic) dispatch_queue_t queue;
@end

@implementation GameBoard

- (instancetype)initWithBoardSize:(NSInteger)size queue:(dispatch_queue_t)queue
{
    return [self initWithBoardSize:size queue:queue piecePlacedBlock:nil ];
}

- (instancetype)initWithBoardSize:(NSInteger)size queue:(dispatch_queue_t)queue piecePlacedBlock:(PlaceBlock)block
{
    self = [super init];
    
    if (self)
    {
        _placeBlock = block;
        
        if (size % 2 == 1)
            return nil; // must be multiple of 2
        
        _grid = [[NSMutableArray alloc] initWithCapacity:size*size];
        _piecesPlayed = [[NSMutableDictionary alloc] init];
        
        // init with empty pieces
        for (NSInteger index = 0; index < size * size; index ++)
        {
            [_grid addObject:[[Piece alloc] init]];
        }
        
        _size = size;
        _queue = queue;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    
    if (self)
    {
        self.grid = [coder decodeObjectForKey:@"grid"];
        self.size = [coder decodeIntegerForKey:@"size"];
        self.piecesPlayed = [coder decodeObjectForKey:@"piecesPlayed"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.grid forKey:@"grid"];
    [aCoder encodeInteger:self.size forKey:@"size"];
    [aCoder encodeObject:self.piecesPlayed forKey:@"piecesPlayed"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\n%@",[self toString]];
}

- (void)updateColorCount:(Piece *)piece incdec:(NSInteger)incDec
{
    if ([piece isClear]) {
        return;
    }
    
    NSNumber *key = @(piece.color);
    NSNumber *count = self.piecesPlayed[key];
    
    NSInteger newCount = [count integerValue] + incDec;
    self.piecesPlayed[key] = @(newCount);
}

- (void)changePieces:(NSArray <BoardPiece *> *)boardPieces
{
    for (BoardPiece *boardPiece in boardPieces)
    {
        [self changePiece:boardPiece.piece withColor:boardPiece.color];
    }
}

- (void)changePiece:(Piece *)piece withColor:(PieceColor)color
{
    if (piece.color != color)
    {
        [self updateColorCount:piece incdec:-1]; // take away one for current piece color
        piece.color = color;                     // now change the piece color
        [self updateColorCount:piece incdec:1];  // add one for that color.
    }
}

- (BOOL)boardFull
{
    NSInteger total = 0;
    
    for (NSNumber *key in self.piecesPlayed)
    {
        NSInteger score = [self.piecesPlayed[key] integerValue];
        if (score == 0)
        {
            return YES; // all white or all black.
        }
        
        total += score;
    }
    
    return (total >= self.size * self.size);
}

- (NSInteger)playerScore:(Player *)player
{
    NSNumber *key = @(player.color);
    return [self.piecesPlayed[key] integerValue];
}


- (BoardPosition *)center
{
    BoardPosition *pos = [BoardPosition new];
    pos.x = self.size / 2 - 1; // zero based counting
    pos.y = self.size / 2 - 1;
    return pos;
}

- (NSArray<BoardPiece *> *)erase
{
    NSMutableArray<BoardPiece *> *pieces = [[NSMutableArray alloc] initWithCapacity:10];
    
    [self visitAll:^(NSInteger x, NSInteger y, Piece *piece)
     {
         [piece clear]; // must use this to bypass isClear check
         
         BoardPosition *pos = [[BoardPosition alloc] initWithX:x Y:y];
         [pieces addObject:[BoardPiece makeBoardPieceWithPiece:piece position:pos color:PieceColorNone]];
     }];
    
    [self.piecesPlayed removeAllObjects];
    return [pieces copy];
}

- (void)visitAll:(void (^)(NSInteger x, NSInteger y, Piece *piece))block
{
    NSInteger size = self.size;
  
    [self.grid enumerateObjectsUsingBlock:^(Piece * piece, NSUInteger index, BOOL * stop)
     {
         block(index % size, index / size, piece);
    }];
}

// lets the work for the update occur in the processing queue rather than the queue
// is is being called from.
- (void)updateBoardWithFunction:(NSArray<BoardPiece *> *(^)())updateFunction
{
    dispatch_async(self.queue,^
    {
       NSArray<BoardPiece *> *pieces = updateFunction();
       [self updateBoardWithPieces:pieces];
    });
}

- (void)updateBoardWithPieces:(NSArray <BoardPiece *> *)boardPieces
{
    if (boardPieces != nil)
    {
        [self changePieces:boardPieces];

        if (self.placeBlock != nil)
        {
            self.placeBlock(boardPieces);
        }
    }
}

- (NSInteger)calculateIndexX:(NSInteger)x Y:(NSInteger)y
{
    return x * self.size + y;
}

- (Piece *)pieceAtPositionX:(NSInteger)x Y:(NSInteger)y
{
    if (x >= self.size || y >= self.size || x < 0 || y < 0)
        return nil;
    
    return [self.grid objectAtIndex:[self calculateIndexX:x Y:y]];
}

- (void)printBanner:(NSMutableString *)boardString
{
    for (NSInteger width = 0; width < self.size + 2; width++)
    {
        [boardString appendString:@"-"];
    }
    [boardString appendString:@"\n"];
}

- (NSString *)convertToString:(BOOL)ascii reverse:(BOOL)reverse
{
    NSMutableString *boardString = [[NSMutableString alloc] init];
    [self printBanner:boardString];
    
    NSInteger size = self.size;
    NSInteger reverseOffset = reverse  ? size - 1: 0;
    for (NSInteger y = 0; y < size; ++y)
    {
        [boardString appendString:@"|"];
        for (NSInteger x = 0; x < self.size; x++)
        {
            Piece *piece = [self pieceAtPositionX:x Y:labs(reverseOffset - y)];
            if (piece == nil) {
                continue;
            }
            [boardString appendString:ascii
                ? piece.colorStringRepresentationAscii
                : piece.colorStringRepresentation];
        }
        [boardString appendString:@"|"];
        [boardString appendString:@"\n"];
    }
    
    [self printBanner:boardString];
    if (!ascii)
    {
        [boardString appendFormat:@"%@", self.piecesPlayed];
    }
    return [boardString copy];
}

- (NSString *)toString
{
    return [self convertToString:NO reverse:YES];
}

- (NSString *)toStringAscii
{
    return [self convertToString:YES reverse:NO];
}

- (BOOL)findTracksForMove:(BoardPiece *)move
                forPlayer:(Player *)player
               trackBlock:(void (^)(NSArray<BoardPiece *> *pieces))trackBlock
{
    // calls block for each direction that has a successful track
    // does not call for invalid tracks. Will call back for each complete track.
    // a track does not include start position, one or more
    // pieces of different color than the player's color, terminated by a piece of
    // the same color as the player.
    
    BOOL found = NO;
    
    // check that piece is on board and we are placing on clear space
    Piece *piece = [self pieceAtPositionX:move.position.x Y:move.position.y];
    if (piece == nil || ![piece isClear])
    {
        return NO;
    }
    
    // try each direction, to see if there is a track
    for (Direction direction = DirectionFirst; direction < DirectionLast; direction ++)
    {
        Delta diff = [self determineDirection:direction];
        
        NSInteger offsetx = move.position.x;
        NSInteger offsety = move.position.y;
        Piece *piece;
        
        NSMutableArray<BoardPiece *> *track = [[NSMutableArray alloc] initWithCapacity:10];
        
        // keep adding pieces until we hit a piece of the same color, edge of board or
        // clear space.
        BOOL valid;
        
        do {
            offsetx += diff.dx; offsety += diff.dy;
            piece = [self pieceAtPositionX:offsetx Y:offsety];
            valid = piece && ![piece isClear]; // make sure it is on board and not clear.
            
            if (valid)
            {
                BoardPosition *offset = [BoardPosition positionWithX:offsetx y:offsety];
                BoardPiece *trackInfo = [BoardPiece makeBoardPieceWithPiece:piece position:offset color:player.color];
                [track addObject:trackInfo];
            }
        } while (valid && piece.color != player.color);
        
        // found piece of same color, end track and call back.
        if (valid && piece.color == player.color && track.count > 1)
        {
            if (trackBlock)
            {
                trackBlock([track copy]);
            }
            found = YES;
        }
    }
    
    return found;
}


- (NSArray<BoardPiece *>*)updateWithTrack:(NSArray<Piece *>*)trackInfo position:(BoardPosition *)position player:(Player *)player
{
    NSMutableArray<BoardPiece *> *pieces = [NSMutableArray new];
    
    for (BoardPiece *trackItem in trackInfo)
    {
        Piece *piece = trackItem.piece;
        NSInteger x = trackItem.position.x;
        NSInteger y = trackItem.position.y;
        BoardPosition *position = [BoardPosition positionWithX:x y:y];
        [pieces addObject:[BoardPiece makeBoardPieceWithPiece:piece position:position color:player.color]];
    }
    return [pieces copy];
}

- (Delta)determineDirection:(Direction)direction
{
    NSInteger x = 0; NSInteger y = 0;
    
    switch (direction)
    {
        case DirectionUp:
        case DirectionUpLeft:
        case DirectionUpRight:
            y = -1;
            break;
        case DirectionDown:
        case DirectionDownRight:
        case DirectionDownLeft:
            y = 1;
            break;
        case DirectionNone:
        case DirectionLeft:
        case DirectionRight:
        case DirectionLast:
            break;
    }
    
    switch (direction)
    {
        case DirectionRight:
        case DirectionDownRight:
        case DirectionUpRight:
            x = 1;
            break;
        case DirectionLeft:
        case DirectionDownLeft:
        case DirectionUpLeft:
            x = -1;
            break;
        case DirectionNone: 
        case DirectionUp:
        case DirectionDown:
        case DirectionLast:
            break;
    }
    
    Delta delta; delta.dx = x; delta.dy = y;
    return delta;
}

- (void)boxCoord:(NSInteger)dist
           block:(void (^)(BoardPosition *position, BOOL isCorner, NSInteger count, BOOL *stop))block
{
    // calculates the positions of the pieces in a box dist from center.
    
    dist = (dist - 1) * 2 + 1; // skip even rings
    
    // calculate start position
    BoardPosition *position = [BoardPosition positionWithX:dist - dist / 2
                                                         y:dist - dist / 2];
    
    // calculate how many pieces to place.
    // Four times dist for the number of directions
    for (NSInteger moveDist = 0; moveDist < dist * 4; moveDist ++)
    {
        // times two so we get only UP, RIGHT, DOWN, LEFT
        Direction dir = moveDist / dist * 2 + DirectionFirst;
        Delta diff = [self determineDirection:dir];
        
        position.x += diff.dx;
        position.y += diff.dy;
        
        BOOL stop = NO;
        block(position, ABS(position.x) == ABS(position.y), moveDist, &stop);
        if (stop)
            break;
    }
}

@end


