/* board.hpp   Part of Othello

   */
   
#ifndef _BOARD_HPP_
#define _BOARD_HPP_

#import <string>

#define EMPTY 0
#define BLACK 1
#define WHITE 2

enum BoardDiffculty {
    BoardDiffcultyBeginner = 1,
    BoardDiffcultyNovice,
    BoardDiffcultyAmateure,
    BoardDiffcultyExperienced
};
#define CONV_21(x, y) (((y) << 3)+(x))

const char DIRECTION[8][2] = {{1, 0}, {1, 1}, {0, 1}, {-1, 1}, {-1, 0}, {-1, -1}, {0, -1}, {1, -1}};

struct Board {
  char a[64];
};

#define uchar unsigned char

Board* makeBoard();
void printBoard(Board *b, bool *legalMoves, char lastMove);

const std::string getMoveFromJSON(const std::string &boardStr, long randomValue);

char getMove(Board *board, char color, long moveNum, BoardDiffculty difficulty, long randValue);

char getMove(Board *board, bool *legalMoves, char forPlayer, char moveNum, BoardDiffculty difficulty, long randValue);

bool legalMove(Board *board, char x, char y, char forPlayer);
bool findLegalMoves(Board *board, bool *legalMoves, char forPlayer);

bool setBoardFromString(Board *board, const std::string &boardStr);
bool setBoardFromJSON(Board *board, const std::string &boardStr);

void countPieces(Board *board, char *nb, char *nw, uchar ntotal);

// inputs:  player
//          board
//          difficulty
// outputs: position

#endif
