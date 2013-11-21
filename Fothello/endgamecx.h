/* endgamecx.h
  */

#ifndef _ENDGAME_H_
#define _ENDGAME_H_

#define END_WHITE 0  // origially named WHITE
#define END_EMPTY 1  // origially named EMPTY
#define END_BLACK 2  // origially named BLACK
#define DUMMY 3
#ifndef uchar
#define uchar unsigned char
#endif

void PrepareToSolve(uchar *board);
int EndSolve (uchar *board, double alpha, double beta, int color, int empties, 
              int discdiff, int prevmove);

#endif

