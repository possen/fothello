//
//  Fothello.m
//  Fothello
//
//  Created by Paul Ossenbruggen on 11/10/13.
//  Copyright (c) 2013 Paul Ossenbruggen. All rights reserved.
//

#import "FothelloGame.h"
#import "AIStrategy.h"

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

- (void)pass
{
    Match *match = self.currentMatch;
    [match.currentPlayer.strategy pass];
    [match nextPlayer];
    [match processOtherTurnsX:-1 Y:-1];
}

- (void)reset
{
    Match *match = self.currentMatch;
    [match endTurn];
    match.currentPlayer = match.players[0];
    for (Player *player in match.players)
        [player.strategy resetWithDifficulty:match.difficulty];
    [match reset];
    [match beginTurn];
}


- (id)init
{
    self = [super init];
    if (self)
    {
        _matches = [[NSMutableArray alloc] initWithCapacity:10];
        _players = [[NSMutableArray alloc] initWithCapacity:10];
        
        // create default players.
        [self newPlayerWithName:@"Player 1" preferredPieceColor:PieceColorBlack];
        [self newPlayerWithName:@"Player 2" preferredPieceColor:PieceColorWhite];
  
        [self matchWithDifficulty:DifficultyEasy
                 firstPlayerColor:PieceColorBlack
                     opponentType:PlayerTypeComputer];
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

- (void)ready
{
    Match *match = self.currentMatch;
    [match ready];
}

- (BOOL)takeTurnAtX:(NSInteger)x Y:(NSInteger)y
{
    Match *match = self.currentMatch;
    [match endTurn];
    
    BOOL moved = [match.currentPlayer takeTurnAtX:x Y:y];

    // if not moved, put legal moves back.
    if (!moved)
        [match beginTurn];

    return moved;
}

- (void)processOtherTurnsX:(NSInteger)x Y:(NSInteger)y
{
    Match *match = self.currentMatch;
    [match processOtherTurnsX:x Y:y];
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

- (Match *)createMatch:(NSString *)name
               players:(NSArray *)players
            difficulty:(Difficulty)difficulty
{
    Match *match = [[Match alloc] initWithName:name players:players difficulty:difficulty];
    
    if ([self.matches indexOfObject:match] == NSNotFound)
    {
        [self.matches addObject:match];
        return match;
    }
    return nil; // not able to create with that name.
}

- (void)matchWithDifficulty:(Difficulty)difficulty
           firstPlayerColor:(PieceColor)pieceColor
               opponentType:(PlayerType)opposingPlayerType
{
    Player *player1 = self.players[0];
    Player *player2 = self.players[1];
    
    NSArray *players = @[player1, player2];
    Match *match = [self matchWithName:nil players:players difficulty:difficulty];

    self.currentMatch = match;

    if (opposingPlayerType == PlayerTypeComputer)
    {
        if (pieceColor == PieceColorBlack)
        {
            player1.strategy = [[HumanStrategy alloc] initWithMatch:match firstPlayer:YES];
            player2.strategy = [[AIStrategy alloc] initWithMatch:match firstPlayer:NO];
        }
        else
        {
            // need to make computer do first move.
            player1.strategy = [[AIStrategy alloc] initWithMatch:match firstPlayer:YES];
            player2.strategy = [[HumanStrategy alloc] initWithMatch:match firstPlayer:NO];
        }
    }
    else
    {
        player1.strategy = [[HumanStrategy alloc] initWithMatch:match firstPlayer:YES];
        player2.strategy = [[HumanStrategy alloc] initWithMatch:match firstPlayer:NO];
    }
    
}

- (Match *)matchWithName:(NSString *)name
                 players:(NSArray *)players
              difficulty:(Difficulty)difficulty
{
    Match *match = nil;
    if (name == nil)
    {
        long count = self.matches.count;
        name = [NSString stringWithFormat:@"Unnamed Game %ld", (long)count];
        match = [self createMatch:name players:players difficulty:difficulty];
    }
    else
    {
        match = [self createMatch:name players:players difficulty:difficulty];
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
        _canMove = YES;
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
        _canMove = [aDecoder decodeBoolForKey:@"canMove"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeInteger:self.preferredPieceColor forKey:@"prefereredPieceColor"];
    [aCoder encodeInteger:self.color forKey:@"currentPieceColor"];
    [aCoder encodeObject:self.strategy forKey:@"strategy"];
    [aCoder encodeBool:self.canMove forKey:@"canMove"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"name %@",self.name];
}

- (BOOL)takeTurnAtX:(NSInteger)x Y:(NSInteger)y
{
    BOOL moved =  [self.strategy takeTurn:self atX:x Y:y];
    
    if (moved)
        [self.strategy.match nextPlayer];

    return moved;
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
    return self.color == PieceColorNone || self.color == PieceColorLegal;
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
        case PieceColorLegal:
            return @"•";
    }
}

@end


#pragma mark - Board -

@implementation FBoard

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
    [self visitAll:^(NSInteger x, NSInteger y, Piece *piece)
     {
        [piece clear];
        if (self.placeBlock)
        {
             self.placeBlock(x, y, piece);
        }
     }];
}

- (void)visitAll:(void (^)(NSInteger x, NSInteger y, Piece *piece))block
{
    NSInteger size = self.size;
    
    for (NSInteger y = 0; y < size; y++)
    {
        for (NSInteger x = 0; x < size; x++)
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
    
    NSInteger size = self.size;
    for (NSInteger y = size -1; y >= 0; --y)
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

- (instancetype)initWithName:(NSString *)name
                     players:(NSArray *)players
                  difficulty:(Difficulty)difficulty
{
    self = [super init];
    
    if (self)
    {
        if (players.count > 2)
            return nil;
        
        _name = name;
        _players = [players copy];
        _difficulty = difficulty;
        _currentPlayer = players[0];
        [self setupPlayersColors];
        _board = [[FBoard alloc] initWithBoardSize:8];
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

- (void)ready
{
    if (self.currentPlayerBlock)
        self.currentPlayerBlock(self.currentPlayer, YES);
    [self beginTurn];
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
            if (trackBlock)
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

    [self endTurn];
    BOOL prevPlayerCouldMove = self.currentPlayer.canMove;
    self.currentPlayer = self.currentPlayer == players[0]
                                             ? players[1]
                                             : players[0];
 
    NSLog(@"current player %@", self.currentPlayer);
    
    BOOL canMove = [self beginTurn];
    self.currentPlayer.canMove = canMove;
    
    if (!prevPlayerCouldMove  && !canMove)
        self.matchStatusBlock(YES);
    
    if (self.currentPlayerBlock)
        self.currentPlayerBlock(self.currentPlayer, canMove);
}

- (BOOL)beginTurn
{
    //    NSLog(@"begin(");
   return [self.currentPlayer.strategy findLegalMoves:self.currentPlayer display:YES];
    //NSLog(@")begin %@", self.board);
}

- (void)endTurn
{
    //NSLog(@"end(");
    [self.currentPlayer.strategy findLegalMoves:self.currentPlayer display:NO];
    //NSLog(@")end %@", self.board);
}


- (void)processOtherTurnsX:(NSInteger)humanx Y:(NSInteger)humany
{
    while (! self.currentPlayer.strategy.manual)
    {
        BOOL placed = [self.currentPlayer takeTurnAtX:humanx Y:humany];
        if (!placed)
            break;
    }
}

- (NSInteger)calculateScore:(Player *)player
{
    // Probably need a less brute force calculation of score. 
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
    FBoard *board = self.board;

    [board reset];
    
    NSArray *players = self.players;
    Position center = board.center;

    [self boxCoord:1 block:^(Position position, BOOL isCorner, NSInteger count, BOOL *stop)
     {
         NSInteger playerCount = (count) % self.players.count;
         
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
- (id)initWithMatch:(Match *)match firstPlayer:(BOOL)firstPlayer
{
    self = [super init];
    if (self)
    {
        _match = match;
        _firstPlayer = firstPlayer;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        _match = [coder decodeObjectForKey:@"match"];
        _firstPlayer = [coder decodeBoolForKey:@"firstPlayer"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.match forKey:@"match"];
    [aCoder encodeBool:self.firstPlayer forKey:@"firstPlayer"];
}

- (BOOL)takeTurn:(Player *)player atX:(NSInteger)x Y:(NSInteger)y
{
    // subclass
    return NO;
}

- (BOOL)findLegalMoves:(Player *)player display:(BOOL)display
{
    Match *match = self.match;
    FBoard *board = match.board;
    __block BOOL foundLegal = NO;
    
    // Determine moves
    [board visitAll:^(NSInteger x, NSInteger y, Piece *piece)
     {
         BOOL foundMove = [match findTracksX:x Y:y
                                   forPlayer:player
                                  trackBlock:nil];
         if (foundMove)
         {
             Piece *piece = [board pieceAtPositionX:x Y:y];
             PieceColor color = display ? PieceColorLegal : PieceColorNone;
             if (piece.color != color)
             {
                 piece.color = color;
                 if (self.manual)
                     board.placeBlock(x, y, piece);
             }
             foundLegal = YES;
         }
     }];
    return foundLegal;
}

- (void)resetWithDifficulty:(Difficulty)difficulty
{
    // subclass
}

- (void)pass
{
    // subclass
}

@end

#pragma mark - BoxStategy -

@implementation BoxStrategy

- (BOOL)takeTurn:(Player *)player atX:(NSInteger)x Y:(NSInteger)y
{
    Match *match = self.match;
    FBoard *board = match.board;
    Position center = board.center;
    
    for (NSInteger boxSize = 0; boxSize < board.size; boxSize++)
    {
        __block BOOL placedInbox = NO;
        
        [match boxCoord:boxSize block:
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

#pragma mark - HumanStategy -

@implementation HumanStrategy

- (BOOL)manual
{
    return YES;
}

- (BOOL)takeTurn:(Player *)player atX:(NSInteger)x Y:(NSInteger)y
{
    Match *match = self.match;

    BOOL placed = [match placePieceForPlayer:player atX:x Y:y];
    return placed;
}


@end






