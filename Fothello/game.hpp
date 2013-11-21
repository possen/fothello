/***
  game.hpp
  
  */

#ifndef _GAME_HPP_
#define _GAME_HPP_

#include <string.h>
#include <time.h>
#include "board.hpp"
#include "minimax.hpp"

#define HUMAN 1
#define COMPUTER 2

extern double totalTimeUsed;
extern bool showDots;
extern bool showTime;

void playGame(Board *board);

#endif

