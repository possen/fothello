/****
  Minimax.hpp
  
  */
  
#ifndef _MINIMAX_HPP_
#define _MINIMAX_HPP_

#include <time.h>
#include "board.hpp"
#include "endgamecx.h"

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

void startNew(char searchDepth);
char getMinimaxMove(Board *board, bool *legalMoves);

#endif
