/****
  Minimax.hpp
  
  */
  
#ifndef _MINIMAX_HPP_
#define _MINIMAX_HPP_

#include <time.h>
#include "board.hpp"

#define EMPTY 0
#define BLACK 1
#define WHITE 2
#define OTHER(x) (3-(x))  // OTHER(BLACK) = WHITE, vice versa.

#define PASS -1
#define ILLEGAL -2

#define CONV_21(x, y) (((y) << 3)+(x))
#define ON_BOARD(x, y) ((x) >= 0 && (x) < 8 && (y) >= 0 && (y) < 8)

#ifndef uint
#define uint usigned int
#endif

// Default values
#define DEF_WIN_LARGE         1
#define DEF_IS_FLIPPED        0
#define DEF_RANDOMNESS_LEVEL  2

#define PROGRAM_NAME "Mini-Othello"
#define VERSION "0.01-alpha-1"

#define HARD_WIRED_FIRST_MOVE 37  // F-5 position
#define HARD_WIRED_FIRST_MOVE_BOARD_FLIPPED 34  // C-5
#define ESTIMATED_CORNER_WORTH 10.0  // Wild guess, don't trust!
#define DENOMINATOR_EXTRA_PREV_MIN_DOF 0.2  // for avoiding divide by 0

#define DEBUG_MINIMAX 0
#define COUNT_PRUNING 0

char getMinimaxMove(Board *board, bool *legalMoves, char forPlayer, char moveNum, BoardDiffculty difficulty);

#endif
