/* board.hpp   Part of Othello

   */
   
#ifndef _BOARD_HPP_
#define _BOARD_HPP_

extern bool showLegalMoves;

const char DIRECTION[8][2] = {{1, 0}, {1, 1}, {0, 1}, {-1, 1}, {-1, 0}, {-1, -1}, {0, -1}, {1, -1}};

struct Board {
  char a[61][64];  // stack of board array
  char moves[128];  // sequence of moves include PASS until this point.
  char n;  // number of actual moves made (NOT incl. PASS).
  char m;  // number of moves incl. PASSes made so far.
  char top;  // redo possible if m < top.
  char wt;  // whose turn it is to move.
};

#define uchar unsigned char


void startNew(char searchDepth);

Board* makeBoard(char isFlipped);
void initBoard(Board *board, char isFlipped);
void printBoard(Board *b, bool *legalMoves);

char getMove(Board *board, bool *legalMoves);
void setPlayer(Board *b, bool firstPlayer);

void setPiece(Board *board, char place, char color);
char getPiece(Board *board, char place);
void flipPiece(Board *board, char place);

bool legalMove(Board *board, char x, char y);
bool findLegalMoves(Board *board, bool *legalMoves);

void makeMove(Board *board, char x, char y);
void makePass(Board *board);
bool undoMove(Board *board);
bool redoMove(Board *board);

void countPieces(char *a, char *nb, char *nw, uchar ntotal);
void countPieces(Board *b, char *nb, char *nw);

#endif
