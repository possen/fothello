//
//  Fothello.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/10/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import "Fothello.h"


#pragma mark - Fothello -

@implementation Fothello

- (id)init
{
    self = [super init];
    if (self)
    {
        _games = [[NSMutableArray alloc] initWithCapacity:10];
        _players = [[NSMutableArray alloc] initWithCapacity:10];
        
        // defaut to two to get things going.
        [self newPlayerWithName:@"Player 1" preferredPieceColor:PieceColorBlack];
        [self newPlayerWithName:@"Player 2" preferredPieceColor:PieceColorWhite];
        Game *game = [self newGame:@"default game" players:_players];
        self.currentGame = game;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    
    if (self)
    {
        self.players = [coder decodeObjectForKey:@"players"];
        self.games = [coder decodeObjectForKey:@"games"];
        self.currentGame = [coder decodeObjectForKey:@"currentGame"];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"currentGame %@",self.currentGame];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.players forKey:@"players"];
    [encoder encodeObject:self.games  forKey:@"games"];
    [encoder encodeObject:self.currentGame forKey:@"currentGame"];
}

- (Game *)createGame:(NSString *)name players:(NSArray *)players
{
    Game *game = [[Game alloc] initWithName:name players:players];
    
    if ([self.games indexOfObject:game] == NSNotFound)
    {
        [self.games addObject:game];
        return game;
    }
    return nil; // not able to create with that name.
}

- (Game *)newGame:(NSString *)name players:(NSArray *)players
{
    Game *game = nil;
    if (name == nil)
    {
        NSInteger count = 0;

        while (name == nil)
        {
            name = [NSString stringWithFormat:@"Unnamed Game %ld", (long)count];
            game = [self createGame:name players:players];
            count++;
        }
    }
    else
    {
        game = [self createGame:name players:players];
    }
    
    return game;
}

- (void)deleteGame:(Game *)game
{
    [self.games removeObject:game];
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
        self.name = [aDecoder decodeObjectForKey:@"name"];
        _preferredPieceColor = [aDecoder decodeIntegerForKey:@"prefereredPieceColor"];
        _color = [aDecoder decodeIntegerForKey:@"currentPieceColor"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeInteger:self.preferredPieceColor forKey:@"prefereredPieceColor"];
    [aCoder encodeInteger:self.color forKey:@"currentPieceColor"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"name %@",self.name];
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
        _pieceColor = [coder decodeIntegerForKey:@"pieceColor"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.pieceColor forKey:@"pieceColor"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"pieceColor %@",self.colorStringRepresentation];
}

- (BOOL)isClear
{
    return self.pieceColor == PieceColorNone;
}

- (void)clear
{
    self.pieceColor = PieceColorNone;
}

- (NSString *)colorStringRepresentation
{
    switch (self.pieceColor)
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
    self = [super init];
    
    if (self)
    {
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
    pos.x = self.size / 2 - 1; // zero
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

    if (piece.pieceColor == PieceColorNone)
    {
        piece.pieceColor =  player.color;
        return YES;
    }
    else
        return NO; // can't place piece there.
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

#pragma mark - Game -

@implementation Game

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

- (void)setupPlayersColors
{
    // For now twoplayer only.
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
    NSInteger x = 0;
    NSInteger y = 0;
    
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
    
    Delta Delta;
    Delta.dx = x;
    Delta.dy = y;
    return Delta;
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
                [track addObject:piece];
     
        } while (valid && piece.pieceColor != player.color);
  
        // found piece of same color, end track and call back.
        if (valid && piece.pieceColor == player.color && track.count > 1)
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
            ^(NSArray *pieces)
            {
                Piece *piece = [self.board pieceAtPositionX:x Y:y];
                piece.pieceColor = player.color;
                
                for (Piece *piece in pieces)
                {
                    piece.pieceColor = player.color;
                }
            }];
}

- (void)nextTurn
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
            score += piece.pieceColor == player.color;
        }
    }
    return score;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"game %@",self.name];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        self.players = [coder decodeObjectForKey:@"players"];
        self.board = [coder decodeObjectForKey:@"board"];
        self.name = [coder decodeObjectForKey:@"name"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.players forKey:@"players"];
    [aCoder encodeObject:self.board forKey:@"board"];
    [aCoder encodeObject:self.name forKey:@"name"];
}


- (void)boxCoord:(NSInteger)dist block:
    (void (^)(Position position, BOOL isCorner, NSInteger count))block
{
    // calculates the positions of the pieces in a box dist from center.
    
    dist = (dist - 1) * 2 + 1; // skip even rings
    
    // calculate start position
    Position position;
    position.x = dist - dist / 2;
    position.y = dist - dist / 2;

    // calculate how many pieces to place.
    // Four times dist for the number of directions
    for (NSInteger moveDist = 0; moveDist < dist * 4; moveDist ++ )
    {
        // times two so we get only UP, RIGHT, DOWN, LEFT
        Direction dir = moveDist / dist * 2 + DirectionFirst;
        Delta diff = [self determineDirection:dir];

        position.x += diff.dx;
        position.y += diff.dy;
        
        NSLog(@"moveDist:%ld dist:%ld px:%ld py:%ld", (long)moveDist,(long)dist, (long)position.x, (long)position.y );

        block(position, YES, moveDist);
    }
}

- (void)reset
{
    [_board reset];
    
    NSArray *players = self.players;
    Board *board = self.board;
    Position center = board.center;

    [self boxCoord:1 block:^(Position position, BOOL isCorner, NSInteger count)
     {
         NSInteger playerCount = (count + 1) % self.players.count;
         
         [board player:players[playerCount]
      pieceAtPositionX:center.x + position.x
                     Y:center.y + position.y];
         
         count++;
     }];
    
    NSLog(@"\n%@\n", [board print]);
}

- (void)testTurnX:(NSInteger)x Y:(NSInteger)y
{
    [self placePieceForPlayer:self.currentPlayer atX:x  Y:y ];
    NSLog(@"\n%@ player %@", [[self board] print], self.currentPlayer);
    [self nextTurn];
    usleep(100000);
}

- (void)test
{
    [self nextTurn];

    [self testTurnX:3  Y:2 ];
    [self testTurnX:4  Y:2 ];
    [self testTurnX:5  Y:2 ];
    [self testTurnX:2  Y:4 ];
    [self testTurnX:5  Y:5 ];
    [self testTurnX:3  Y:1 ];
    [self testTurnX:2  Y:0 ];
    [self testTurnX:6  Y:2 ];
    [self testTurnX:2  Y:5 ];
    [self testTurnX:3  Y:0 ];
    [self testTurnX:2  Y:3 ];
    [self testTurnX:1  Y:6 ];
    [self testTurnX:4  Y:0 ];
    [self testTurnX:1  Y:3 ];
    [self testTurnX:0  Y:2 ];
    [self testTurnX:0  Y:3 ];
    [self testTurnX:0  Y:4 ];
    [self testTurnX:1  Y:4 ];
    [self testTurnX:4  Y:1 ];
    [self testTurnX:6  Y:6 ];
    [self testTurnX:7  Y:2 ];
    [self testTurnX:6  Y:1 ];
    [self testTurnX:6  Y:0 ];
    [self testTurnX:7  Y:0 ];
    [self testTurnX:0  Y:5 ];
    [self testTurnX:5  Y:0 ];
    [self testTurnX:2  Y:7 ];
    [self testTurnX:0  Y:7 ];
    [self testTurnX:1  Y:5 ];
    [self testTurnX:1  Y:0 ];
    [self testTurnX:1  Y:0 ];
    [self testTurnX:5  Y:1 ];
    [self testTurnX:7  Y:7 ];
    [self testTurnX:0  Y:6 ];
    [self testTurnX:2  Y:2 ];
    [self testTurnX:1  Y:2 ];
    [self testTurnX:3  Y:5 ];
    [self testTurnX:0  Y:1 ];
    [self testTurnX:1  Y:7 ];
    [self testTurnX:3  Y:7 ];
    [self testTurnX:2  Y:1 ];
    [self testTurnX:1  Y:1 ];
    [self testTurnX:0  Y:0 ];
    [self testTurnX:2  Y:6 ];
    [self testTurnX:7  Y:1 ];
    [self testTurnX:3  Y:6 ];
    [self testTurnX:5  Y:3 ];
    [self testTurnX:6  Y:3 ];
    [self testTurnX:7  Y:3 ];
    [self testTurnX:7  Y:4 ];
    [self testTurnX:5  Y:4 ];
    [self testTurnX:4  Y:5 ];
    [self testTurnX:6  Y:4 ];
    [self testTurnX:5  Y:6 ];
    [self testTurnX:6  Y:5 ];
    [self testTurnX:6  Y:7 ];
    [self testTurnX:5  Y:7 ];
    [self testTurnX:4  Y:7 ];
    [self testTurnX:7  Y:6 ];
    [self testTurnX:4  Y:6 ];
    [self testTurnX:7  Y:5 ];
    
    NSLog(@"player %@ score %ld", self.players[0],
          (long)[self calculateScore:self.players[0]]);
    
    NSLog(@"player %@ score %ld", self.players[1],
          (long)[self calculateScore:self.players[1]]);

#if 0
    [self reset];

    BOOL player1 = NO;
    BOOL player2 = NO;
    
    while (!player1 || !player2)
    {
        NSInteger count = 30;
        
        while (!player1 /*&& count != 0*/)
        {
            NSInteger x = arc4random() % self.board.size;
            NSInteger y = arc4random() % self.board.size;
            
            player1 = [self placePieceForPlayer:self.currentPlayer atX:x Y:y];
            NSLog(@"\n%@ player %@", [[self board] print], self.currentPlayer);

            count --;
        }
        [self nextTurn];
        
        count = 30;
        while (!player2 /*&& count != 0*/)
        {
            NSInteger x = arc4random() % self.board.size;
            NSInteger y = arc4random() % self.board.size;
            
            [self placePieceForPlayer:self.currentPlayer atX:x Y:y];
            NSLog(@"\n%@ player %@", [[self board] print], self.currentPlayer);

            count --;
        }
        [self nextTurn];
    }
#endif
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

@implementation Strategy

// Not done and not used yet.
- (id)initWithGame:(Game *)game
{
    self = [super init];
    if (self)
    {
        _game = game;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        self.game = [coder decodeObjectForKey:@"game"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.game forKey:@"game"];
}


@end

