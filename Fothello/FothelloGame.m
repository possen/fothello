//
//  Fothello.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/10/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import "FothelloGame.h"

#pragma mark - TrackInfo -

@interface TrackInfo : NSObject
@property (nonatomic) Piece *piece;
@property (nonatomic) NSInteger x;
@property (nonatomic) NSInteger y;
@end

@implementation TrackInfo

@end

#pragma mark - FothelloGame -

@implementation FothelloGame

+ (id)sharedInstance
{
    static dispatch_once_t onceToken;
    __strong static id _sharedObject = nil;
    
    dispatch_once(&onceToken,
    ^{
        NSString *filename = [self pathForGameState];
        
        FothelloGame *fothello = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];

        // if there is no saved game state create it for the first time.
        if (fothello == nil)
        {
            fothello = [[FothelloGame alloc] init];
        }

        _sharedObject = fothello;
    });
    
    return _sharedObject;
}


+ (NSString *)pathForGameState
{
    NSString *docsPath
    = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
       objectAtIndex:0];
    
    NSString *filename = [docsPath stringByAppendingPathComponent:@"Fothello"];
    
    return filename;
}

- (void)saveGameState
{
    FothelloGame *game = [FothelloGame sharedInstance];
    NSString *filename = [FothelloGame pathForGameState];
    
    [NSKeyedArchiver archiveRootObject:game toFile:filename];
}


- (id)init
{
    self = [super init];
    if (self)
    {
        _matches = [[NSMutableArray alloc] initWithCapacity:10];
        _players = [[NSMutableArray alloc] initWithCapacity:10];
        
        // TODO: defaut to two to get things going. Support more players later.
        Player *player1 = [self newPlayerWithName:@"Player 1" preferredPieceColor:PieceColorBlack];
        Player *player2 = [self newPlayerWithName:@"Player 2" preferredPieceColor:PieceColorWhite];
        
        Match *match = [self newMatch:@"default game" players:_players];
        self.currentMatch = match;
        
        player1.strategy = [[BoxStrategy alloc] initWithMatch:match name:@"Computer"];
        player2.strategy = [[BoxStrategy alloc] initWithMatch:match name:@"Computer"];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    
    if (self)
    {
        _players = [coder decodeObjectForKey:@"players"];
        _matches = [coder decodeObjectForKey:@"matches"];
        _currentMatch = [coder decodeObjectForKey:@"currentMatch"];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"currentMatch %@",self.currentMatch];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.players forKey:@"players"];
    [encoder encodeObject:self.matches  forKey:@"matches"];
    [encoder encodeObject:self.currentMatch forKey:@"currentMatch"];
}

- (Match *)createMatch:(NSString *)name players:(NSArray *)players
{
    Match *match = [[Match alloc] initWithName:name players:players];
    
    if ([self.matches indexOfObject:match] == NSNotFound)
    {
        [self.matches addObject:match];
        return match;
    }
    return nil; // not able to create with that name.
}

- (Match *)newMatch:(NSString *)name players:(NSArray *)players
{
    Match *match = nil;
    if (name == nil)
    {
        NSInteger count = 0;

        while (name == nil)
        {
            name = [NSString stringWithFormat:@"Unnamed Game %ld", (long)count];
            match = [self createMatch:name players:players];
            count++;
        }
    }
    else
    {
        match = [self createMatch:name players:players];
    }
    
    return match;
}

- (void)deleteMatch:(Match *)match
{
    [self.matches removeObject:match];
}

- (Player *)newPlayerWithName:(NSString *)name
          preferredPieceColor:(PieceColor)preferredPieceColor
{
    return [self newPlayerWithName:name
               preferredPieceColor:preferredPieceColor
                          strategy:nil];
}

- (Player *)newPlayerWithName:(NSString *)name
          preferredPieceColor:(PieceColor)preferredPieceColor
                     strategy:(Strategy *)strategy
{
    Player *player = [[Player alloc] initWithName:name];
    player.preferredPieceColor  = preferredPieceColor;
    [self.players addObject:player];
    player.strategy = strategy;
    return player;
}


- (void)deletePlayer:(Player *)player
{
    [self.players removeObject:player];
}

@end

#pragma mark - Player -

@implementation Player

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    
    if (self)
    {
        _name = name;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _preferredPieceColor = [aDecoder decodeIntegerForKey:@"prefereredPieceColor"];
        _color = [aDecoder decodeIntegerForKey:@"currentPieceColor"];
        _strategy = [aDecoder decodeObjectForKey:@"strategy"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeInteger:self.preferredPieceColor forKey:@"prefereredPieceColor"];
    [aCoder encodeInteger:self.color forKey:@"currentPieceColor"];
    [aCoder encodeObject:self.strategy forKey:@"strategy"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"name %@",self.name];
}

- (BOOL)takeTurn
{
    return [self.strategy takeTurn:self];
}

- (BOOL)isEqual:(id)name
{
    return [self.name isEqualToString:name];
}

- (NSUInteger)hash
{
    return self.name.hash;
}

@end

#pragma mark - Piece -

@implementation Piece

- (id)initWithCoder:(NSCoder *)coder
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
    return [NSString stringWithFormat:@"pieceColor %@",self.colorStringRepresentation];
}

- (BOOL)isClear
{
    return self.color == PieceColorNone;
}

- (void)clear
{
    self.color = PieceColorNone;
}

- (NSString *)colorStringRepresentation
{
    switch (self.color)
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
    }
}

@end


#pragma mark - Board -

@implementation Board

- (id)initWithBoardSize:(NSInteger)size
{
    return [self initWithBoardSize:size piecePlacedBlock:nil];
}

- (id)initWithBoardSize:(NSInteger)size piecePlacedBlock:(PlaceBlock)block
{
    self = [super init];
    
    if (self)
    {
        _placeBlock = block;
        
        if (size % 2 == 1)
            return nil; // must be multiple of 2
        
        _grid = [[NSMutableArray alloc] initWithCapacity:size*size];
 
        // init with empty pieces
        for (NSInteger index = 0; index < size * size; index ++)
        {
            [_grid addObject:[[Piece alloc] init]];
        }

        _size = size;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\n%@",[self print]];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        self.grid = [coder decodeObjectForKey:@"grid"];
        self.size = [coder decodeIntegerForKey:@"size"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.grid forKey:@"grid"];
    [aCoder encodeInteger:self.size forKey:@"size"];
}

- (Position)center
{
    Position pos;
    pos.x = self.size / 2 - 1; // zero based counting
    pos.y = self.size / 2 - 1;
    return pos;
}

- (void)reset
{
    for (NSInteger y = 0; y < self.size; y++)
    {
        for (NSInteger x = 0; x < self.size; x++)
        {
            [[self pieceAtPositionX:x Y:y] clear];
        }
    }
}

- (void)visitAll:(void (^)(NSInteger x, NSInteger y, Piece *piece))block
{
    for (NSInteger y = 0; y < self.size; y++)
    {
        for (NSInteger x = 0; x < self.size; x++)
        {
            Piece *piece = [self pieceAtPositionX:x Y:y];

            block(x, y, piece);
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

- (BOOL)player:(Player *)player pieceAtPositionX:(NSInteger)x Y:(NSInteger)y
{
    Piece *piece = [self pieceAtPositionX:x Y:y];

    piece.color =  player.color;
    
    if (self.placeBlock)
    {
        self.placeBlock(x, y, piece);
    }
    return YES;
}

- (void)printBanner:(NSMutableString *)boardString
{
    for (NSInteger width = 0; width < self.size + 2; width++)
    {
        [boardString appendString:@"-"];
    }
    [boardString appendString:@"\n"];
}

- (NSString *)print
{
    NSMutableString *boardString = [[NSMutableString alloc] init];
    [self printBanner:boardString];
    
    for (NSInteger y = 0; y < self.size; y++)
    {
        [boardString appendString:@"|"];
        for (NSInteger x = 0; x < self.size; x++)
        {
            Piece *piece = [self pieceAtPositionX:x Y:y];
            [boardString appendString:piece.colorStringRepresentation];
        }
        [boardString appendString:@"|"];
        [boardString appendString:@"\n"];
    }

    [self printBanner:boardString];

    return boardString;
}

@end

#pragma mark - Match -

@implementation Match

- (instancetype)initWithName:(NSString *)name players:(NSArray *)players
{
    self = [super init];
    
    if (self)
    {
        if (players.count > 2)
            return nil;
        
        _name = name;
        _players = players;
        _currentPlayer = players[0];
        [self setupPlayersColors];
        _board = [[Board alloc] initWithBoardSize:8];
        [self reset];

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        _players = [coder decodeObjectForKey:@"players"];
        _board = [coder decodeObjectForKey:@"board"];
        _name = [coder decodeObjectForKey:@"name"];
        _currentPlayer = [coder decodeObjectForKey:@"currentPlayer"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.players forKey:@"players"];
    [aCoder encodeObject:self.board forKey:@"board"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.currentPlayer forKey:@"currentPlayer"];
}


- (void)setupPlayersColors
{
    // if the player's prefered colors are the same, pick one for each.
    
    //TODO: For now twoplayer only. Future support more
    Player *player0 = self.players[0];
    Player *player1 = self.players[1];
  
    if (player0.preferredPieceColor != player1.preferredPieceColor)
    {
        player0.color = player0.preferredPieceColor;
        player1.color = player1.preferredPieceColor;
    }
    else
    {
        player0.color = PieceColorBlack;
        player1.color = PieceColorWhite;
    }
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
        case DirectionNone: // keeps warnings away, could use default
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
        case DirectionNone: // keeps warnings away, could use default
        case DirectionUp:
        case DirectionDown:
        case DirectionLast:
            break;
    }
    
    Delta delta; delta.dx = x; delta.dy = y;
    return delta;
}


- (BOOL)findTracksX:(NSInteger)x
                  Y:(NSInteger)y
          forPlayer:(Player *)player
         trackBlock:(void (^)(NSArray *pieces))trackBlock
{
    // calls block for each direction that has a successful track
    // does not call for invalid tracks. Will call back for each complete track.
    // a track does not include start position, one or more
    // pieces of different color than the player's color, terminated by a piece of
    // the same color as the player.

    BOOL found = NO;
    
    // check that piece is on board and we are placing on clear space
    Piece *piece = [self.board pieceAtPositionX:x Y:y];
    if (piece == nil || ![piece isClear])
        return NO;
    
    // try each direction, to see if there is a track
    for (Direction direction = DirectionFirst; direction < DirectionLast; direction ++)
    {
        Delta diff = [self determineDirection:direction];
        
        NSInteger offsetx = x; NSInteger offsety = y;
        
        NSMutableArray *track = [[NSMutableArray alloc] initWithCapacity:10];
        
        // keep adding pieces until we hit a piece of the same color, edge of board or
        // clear space.
        BOOL valid;
        
        do {
            offsetx += diff.dx; offsety += diff.dy;
            piece = [self.board pieceAtPositionX:offsetx Y:offsety];
            valid = piece && ![piece isClear]; // make sure it is on board and not clear.
           
            if (valid)
            {
                TrackInfo *trackInfo = [[TrackInfo alloc] init];
                trackInfo.x = offsetx;
                trackInfo.y = offsety;
                trackInfo.piece = piece;
                [track addObject:trackInfo];
            }
        } while (valid && piece.color != player.color);
  
        // found piece of same color, end track and call back.
        if (valid && piece.color == player.color && track.count > 1)
        {
            trackBlock(track);
            found = YES;
        }
    }
    
    return found;
}

- (BOOL)placePieceForPlayer:(Player *)player atX:(NSInteger)x Y:(NSInteger)y
{
    return [self findTracksX:x Y:y
                   forPlayer:player
                  trackBlock:
            ^(NSArray *trackInfo)
            {
                Piece *piece = [self.board pieceAtPositionX:x Y:y];
                piece.color = player.color;
                
                self.board.placeBlock(x, y, piece);

                for (TrackInfo *trackItem in trackInfo)
                {
                    piece = trackItem.piece;
                    NSInteger x = trackItem.x;
                    NSInteger y = trackItem.y;
                    piece.color = player.color;
                  
                    if (self.board.placeBlock)
                    {
                        self.board.placeBlock(x, y, piece);
                    }
                }
            }];
}

- (void)nextPlayer
{
    NSArray *players = self.players;

    self.currentPlayer = self.currentPlayer == players[0]
                                             ? players[1]
                                             : players[0];
    
}

- (NSInteger)calculateScore:(Player *)player
{
    NSInteger score = 0;
    for (NSInteger y = 0; y < self.board.size; y++)
    {
        for (NSInteger x = 0; x < self.board.size; x++)
        {
            Piece *piece = [self.board pieceAtPositionX:x Y:y];
            score += piece.color == player.color;
        }
    }
    return score;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"match %@",self.name];
}


- (void)boxCoord:(NSInteger)dist block:
    (void (^)(Position position, BOOL isCorner, NSInteger count, BOOL *stop))block
{
    // calculates the positions of the pieces in a box dist from center.
    
    dist = (dist - 1) * 2 + 1; // skip even rings
    
    // calculate start position
    Position position;
    position.x = dist - dist / 2;
    position.y = dist - dist / 2;

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

- (void)reset
{
    [_board reset];
    
    NSArray *players = self.players;
    Board *board = self.board;
    Position center = board.center;

    [self boxCoord:1 block:^(Position position, BOOL isCorner, NSInteger count, BOOL *stop)
     {
         NSInteger playerCount = (count + 1) % self.players.count;
         
         [board player:players[playerCount]
      pieceAtPositionX:center.x + position.x
                     Y:center.y + position.y];
         
         count++;
     }];
    
    NSLog(@"\n%@\n", [board print]);
}

- (BOOL)done
{
    return NO;
}


- (void)test
{
    NSLog(@"player %@ score %ld", self.players[0],
          (long)[self calculateScore:self.players[0]]);
    
    NSLog(@"player %@ score %ld", self.players[1],
          (long)[self calculateScore:self.players[1]]);
}


- (BOOL)isEqual:(id)name
{
    return [self.name isEqualToString:name];
}

- (NSUInteger)hash
{
    return self.name.hash;
}
@end

#pragma mark - Strategy -

@implementation Strategy

// Not done and not used yet.
- (id)initWithMatch:(Match *)match name:(NSString *)name
{
    self = [super init];
    if (self)
    {
        _match = match;
        _name = name;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        _match = [coder decodeObjectForKey:@"match"];
        _name = [coder decodeObjectForKey:@"name"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.match forKey:@"match"];
    [aCoder encodeObject:self.name forKey:@"name"];
}

- (BOOL)takeTurn:(Player *)player
{
    // subclass
    return NO;
}

@end

#pragma mark - BoxStategy -

@implementation BoxStrategy

- (BOOL)takeTurn:(Player *)player
{
    Match *match = self.match;
    Board *board = match.board;
    Position center = board.center;
    
    for (NSInteger boxSize = 0; boxSize < board.size; boxSize++)
    {
        __block BOOL placedInbox = NO;
        
        [self.match boxCoord:boxSize block:
         ^(Position position, BOOL isCorner, NSInteger count, BOOL *stop)
         {
             BOOL placed = [match placePieceForPlayer:player
                                                atX:center.x + position.x
                                                  Y:center.y + position.y];
             
             if (placed)
             {
                 NSLog(@"\n%@ player %@", [board print], player);
                 
                 placedInbox = YES;
                 *stop = YES;
             }
         }];
        
        if (placedInbox)
        {
            return YES; // whether piece could be placed.
        }
    }
    
    return NO;
}

@end





