/*******
  minimax.cpp
  This is the AI minimax search for Othello.
  
  Note: Andersson's end-of-game solver is very good at solving end of game 
   -- about 2 steps more than my simple minimax. 
  */

#import <stdio.h>
#import <stdlib.h>

#include "minimax.hpp"
#include "endgamecx.h"

#define SEARCH_NOVICE             4
#define SEARCH_BEGINNER           6
#define SEARCH_AMATEUR            8
#define SEARCH_EXPERIENCED        10

#define BRUTE_FORCE_NOVICE        12
#define BRUTE_FORCE_BEGINNER      14
#define BRUTE_FORCE_AMATEUR       16
#define BRUTE_FORCE_EXPERIENCED   19

// Default values
#define DEF_WIN_LARGE         1
#define DEF_IS_FLIPPED        0
#define DEF_RANDOMNESS_LEVEL  2

#define MAX_INT 2147483647
#define MIN_INT -2147483648
#define LARGE_FLOAT 1.0e35
#define SMALL_FLOAT -1.0e35
#define HUGE_FLOAT 2.0e38
#define TINY_FLOAT -2.0e38

#define PROGRAM_NAME "Mini-Othello"
#define VERSION "0.01-alpha-1"


static char mmBoard[61][64];
static char base;
static unsigned int countPruning;
static unsigned int countSearching, countEval;
static unsigned int temp0, temp1;
static float extra;

static char searchDepth;
static char originalSearchDepth;
static char bruteForceDepth;
static char useAndersson;
static char randomnessLevel;
static char winLarge;

float getMin(char lastx, char lasty, char color, char depth, char passes,
             char prevmaxDOF, char prevminDOF, //DOF found in previous getMax and getMin;
             char selfPieces, char oppPieces, float alpha, float beta);
float getMax(char lastx, char lasty, char color, char depth, char passes,
             char prevmaxDOF, char prevminDOF,
             char selfPieces, char oppPieces, float alpha, float beta);

void copyBoardArray(char *to, char *from);
bool legalMove(char *a, char color, char x, char y);
char findLegalMoves(char *a, char color, unsigned int *mask0, unsigned int *mask1);
char tryMove(char *a, char color, char x, char y);

float evaluateEndGame(char selfPieces, char oppPieces);
float evaluateBoard(char *a, char forWhom, char whoseTurn, char prevmaxDOF,
                    char prevminDOF, char selfPieces, char oppPieces);

void printBoardArray(char *a);
int strongEndGameSolve(char depth, char color, char selfPieces, char oppPieces,
                       char prevNotPass, float alpha, float beta);

char lookup[] = {1, 1, 1,
               SEARCH_BEGINNER, BRUTE_FORCE_BEGINNER, 0,
               SEARCH_NOVICE, BRUTE_FORCE_NOVICE, 0,
               SEARCH_AMATEUR, BRUTE_FORCE_AMATEUR, 0,
               SEARCH_EXPERIENCED, BRUTE_FORCE_EXPERIENCED, 1};

void startNewMinimax(char diffculty) {
    searchDepth = lookup[diffculty * 3];
    bruteForceDepth = lookup[diffculty * 3 + 1];
    useAndersson = lookup[diffculty * 3 + 2];
    
    originalSearchDepth = searchDepth;
    bruteForceDepth = diffculty;
    winLarge = DEF_WIN_LARGE;
    randomnessLevel = DEF_RANDOMNESS_LEVEL;
    srand((unsigned)time(NULL));
}

/* Return a move using minimax search. -- Called only once per move made */
char getMinimaxMove(Board *board, bool *legalMoves) {
  /* Initialization */
  countPruning = countSearching = countEval = 0;
  base = board->n;
  char bestMove = PASS;
  float bestValue = 2* SMALL_FLOAT; // avoid return a PASS while there is still legal moves
  float currValue;
  char depth = 0;
    //  char passes = 0;
  char color = board->wt;
  float alpha = SMALL_FLOAT;
  float beta = LARGE_FLOAT;
  /* If end of game is within the brute force depth, search all the way to the end. */
  if(base + 4 + bruteForceDepth >= 64) {
    searchDepth = bruteForceDepth;
  }
  else
    searchDepth = originalSearchDepth;
  // Add a certain randomness to corner value 
  extra = DENOMINATOR_EXTRA_PREV_MIN_DOF;
  if(randomnessLevel) {
    float temprand = ((float)(rand() % 4001)) / 4001 - 0.5;  // +- 0.5
    extra = DENOMINATOR_EXTRA_PREV_MIN_DOF * (1 + 0.02 * temprand * randomnessLevel);
  }
  // initialize the arrays to the board configuration.
  char *a = board->a[base];
  char *b = mmBoard[depth];
  char *b1 = mmBoard[depth+1];
  copyBoardArray(b, a);
  if(base == 0) {  // don't want to search for the first move.
      return HARD_WIRED_FIRST_MOVE_BOARD_FLIPPED;
  }
  char place;
  unsigned int mask0, mask1;
  char nLegalMoves = findLegalMoves(b, color, &mask0, &mask1);
  char selfPieces, oppPieces, nFlips;
  if(color == BLACK)
    countPieces(b, &selfPieces, &oppPieces, base+depth+4);
  else
    countPieces(b, &oppPieces, &selfPieces, base+depth+4);
  for(char y=0; y<8; y++) {
    for(char x=0; x<8; x++) {
      place = CONV_21(x, y);
      if(!legalMoves[place])
        continue;
      copyBoardArray(b1, b);
      nFlips = tryMove(b1, color, x, y);
      if(base + depth + 4 == 63)  // just filled the board.
        currValue = evaluateEndGame(selfPieces+nFlips+1, oppPieces-nFlips);
      else if(useAndersson && (base + 4 + bruteForceDepth >= 64)) {
        if(winLarge)
          currValue = strongEndGameSolve(depth+1, OTHER(color), selfPieces+nFlips+1, 
                                        oppPieces-nFlips, 1, -64, 64);
        else
          currValue = strongEndGameSolve(depth+1, OTHER(color), selfPieces+nFlips+1, 
                                        oppPieces-nFlips, 1, -64, 1);
      }
      else {
        currValue = getMin(x, y, OTHER(color), depth+1, 0, nLegalMoves, nLegalMoves, 
                          selfPieces+nFlips+1, oppPieces-nFlips, alpha, beta);
        if(DEBUG_MINIMAX) {
          printf("getMin returned: %e, (depth: %d)\n", currValue, depth+1);
        }
      }
      if(currValue > bestValue) {
        bestMove = place;
        bestValue = currValue;
      }
      if(bestValue > alpha)
        alpha = bestValue;
    }
  }
  if(COUNT_PRUNING)
    printf("Nodes searched: %d, evaluated: %d, pruned: %d\n", countSearching, countEval, countPruning);
  return bestMove;
}

/***************************************************************
                    The minimax core      
 *****************************************************************
 */

/**************************************************
  Function: getMin(...)
  ---- The MIN part of Minimax ---- 
  getMin always plays for "opponent"
*/
/* NOTE: passes = 1 if there has been odd number of passes on the search path, 
  zero otherwise (same in getMax) */
  
float getMin(char lastx, char lasty, char color, char depth, char passes, 
             char prevmaxDOF, char prevminDOF, //DOF found in previous getMax and getMin;
             char selfPieces, char oppPieces,
             float alpha, float beta) {
  if(DEBUG_MINIMAX) {
    printf("In getMin, at depth %d -- alpha: %e, beta: %e\n", depth, alpha, beta);
  }
  if(COUNT_PRUNING)
    countSearching++;
  if(selfPieces == 0) // got anihilated!
    return SMALL_FLOAT;
  else if(oppPieces == 0)
    return LARGE_FLOAT;
  // Initialization started.
  char *a = mmBoard[depth];
  char *a1 = mmBoard[depth+1]; // a1 is the board config. after (depth+1)th search move.
  uchar uPieces = base + depth + 4;
  char nFlips;
  char x, y, place;
  /* If there is only one move left, simply player it (if possible) and count scores */
  if(uPieces == 63) {
    int i = 0;
    while(a[i] != EMPTY)
      i++;
    y = i / 8;
    x = i - 8*y;
    copyBoardArray(a1, a);
    nFlips = tryMove(a1, color, x, y);
    if(nFlips) { // i.e. move can be played
      return evaluateEndGame(selfPieces-nFlips, oppPieces+nFlips+1);
    }
    else {
      nFlips = tryMove(a1, OTHER(color), x, y);
      if(nFlips) // i.e. move can be played by the other player
        return evaluateEndGame(selfPieces+nFlips+1, oppPieces-nFlips);
      else  // no one can play this move
        return evaluateEndGame(selfPieces, oppPieces);
    }
  }
  /* test if cut-off depth reached */
  if(depth == searchDepth + passes) // always evaluate when it is self's turn to move
    return evaluateBoard(a, OTHER(color), color, prevmaxDOF, prevminDOF, 
                        selfPieces, oppPieces);
  char nLegalMoves;
  unsigned int mask0, mask1;
  nLegalMoves = findLegalMoves(a, color, &mask0, &mask1);
  /* test if there is any legal move posssible */
  if(!nLegalMoves) {
    if(lastx == -1) // last step is also pass, this branch ends here.
      return evaluateEndGame(selfPieces, oppPieces);
    else // make a pass (set lastx to -1), depth NOT incremented.
      return getMax(-1, -1, OTHER(color), depth, 1-passes, prevmaxDOF, 0, 
                    selfPieces, oppPieces, alpha, beta);
  }
  /* Now there are legal moves to make */
  float minValue = LARGE_FLOAT;
  float currValue;
  /* first test the move adjacent to last oppenent move (if any) */
  if(lastx != -1) {
    for(char i=0; i<8; i++) {
      x = lastx + DIRECTION[i][0];
      y = lasty + DIRECTION[i][1];
      if(ON_BOARD(x, y)) {
        place = CONV_21(x, y);
        if(place < 32) {
          if(mask0 & (1 << place)) { // it is a legal move
            copyBoardArray(a1, a);
            nFlips = tryMove(a1, color, x, y);
            currValue = getMax(x, y, OTHER(color), depth+1, passes, 
                                prevmaxDOF, nLegalMoves, selfPieces-nFlips, 
                                oppPieces+nFlips+1, alpha, beta);
            mask0 = mask0 & ~(1 << place);  // make off this bit.
            if(currValue < minValue)
              minValue = currValue;
            if(minValue < beta)
              beta = minValue;
            if(alpha >= beta) { // prun brunch as soon as alpha and beta crosses.
              if(COUNT_PRUNING)
                countPruning++;
              return beta;
            }
          }
        }
        else { // place >= 32
          if(mask1 & (1 << (place - 32))) { // it is a legal move
            copyBoardArray(a1, a);
            nFlips = tryMove(a1, color, x, y);
            currValue = getMax(x, y, OTHER(color), depth+1, passes, 
                                prevmaxDOF, nLegalMoves,  selfPieces-nFlips, 
                                oppPieces+nFlips+1, alpha, beta);
            mask1 = mask1 & ~(1 << (place - 32));  // make off this bit.
            if(currValue < minValue)
              minValue = currValue;
            if(minValue < beta)
              beta = minValue;
            if(alpha >= beta) {
              if(COUNT_PRUNING)
                countPruning++;
              return beta;
            }
          }
        }
      }
    }
  }
  /* Now try the rest moves */
  for(y=0; y<4; y++)
    for(x=0; x<8; x++) {
      place = CONV_21(x, y);
      if(mask0 & (1 << place)) { // move is legal
        copyBoardArray(a1, a);
        nFlips = tryMove(a1, color, x, y);
        currValue = getMax(x, y, OTHER(color), depth+1, passes, prevmaxDOF, nLegalMoves, 
                           selfPieces-nFlips, oppPieces+nFlips+1, alpha, beta);
        if(currValue < minValue)
          minValue = currValue;
        if(minValue < beta)
          beta = minValue;
        if(alpha >= beta) { // prun brunch as soon as alpha and beta crosses.
          if(COUNT_PRUNING)
            countPruning++;
          return beta;
        }
      }
    }
  for(y=4; y<8; y++)
    for(x=0; x<8; x++) {
      place = CONV_21(x, y);
      if(mask1 & (1 << (place - 32))) { // move is legal
        copyBoardArray(a1, a);
        nFlips = tryMove(a1, color, x, y);
        currValue = getMax(x, y, OTHER(color), depth+1, passes, prevmaxDOF, nLegalMoves, 
                           selfPieces-nFlips, oppPieces+nFlips+1, alpha, beta);
        if(currValue < minValue)
          minValue = currValue;
        if(minValue < beta)
          beta = minValue;
        if(alpha >= beta) { // prun brunch as soon as alpha and beta crosses.
          if(COUNT_PRUNING)
            countPruning++;
          return beta;
        }
      }
    }
  return minValue;
}

/***********************************************
 
  Function: getMax(...)
  ---- The MAX par of Minimax ---- 
  getMax always plays for "self"
*/
float getMax(char lastx, char lasty, char color, char depth, char passes, 
             char prevmaxDOF, char prevminDOF, 
             char selfPieces, char oppPieces,
             float alpha, float beta) {
  if(DEBUG_MINIMAX) {
    printf("In getMax, at depth %d -- alpha: %e, beta: %e\n", depth, alpha, beta);
    // printf("DEBUG_MINIMAX: %d", DEBUG_MINIMAX);
  }
  if(COUNT_PRUNING)
    countSearching++;
  if(selfPieces == 0) // got anihilated!
    return SMALL_FLOAT;
  else if(oppPieces == 0)
    return LARGE_FLOAT;
  // Initialization started.
  char *a = mmBoard[depth];
  char *a1 = mmBoard[depth+1]; // a1 is the board config. after (depth+1)th search move.
  uchar uPieces = base + depth + 4;
  char nFlips;
  char x, y, place;
  /* If there is only one move left, simply player it (if possible) and count scores */
  if(uPieces == 63) {
    int i = 0;
    while(a[i] != EMPTY)
      i++;
    y = i / 8;
    x = i - 8*y;
    copyBoardArray(a1, a);
    nFlips = tryMove(a1, color, x, y);
    if(nFlips) { // i.e. move can be played
      return evaluateEndGame(selfPieces+nFlips+1, oppPieces-nFlips);
    }
    else {
      nFlips = tryMove(a1, OTHER(color), x, y);
      if(nFlips) // i.e. move can be played by the other player
        return evaluateEndGame(selfPieces-nFlips, oppPieces+nFlips+1);
      else  // no one can play this move
        return evaluateEndGame(selfPieces, oppPieces);
    }
  }
  /* test if cut-off depth reached */
  if(depth == searchDepth + passes) // always evaluate when it is self's turn to move
    return evaluateBoard(a, color, color, prevmaxDOF, prevminDOF, 
                        selfPieces, oppPieces);
  char nLegalMoves;
  unsigned int mask0, mask1;
  nLegalMoves = findLegalMoves(a, color, &mask0, &mask1);
  /* test if there is any legal move posssible */
  if(!nLegalMoves) {
    if(lastx == -1) // last step is also pass, this branch ends here.
      return evaluateEndGame(selfPieces, oppPieces);
    else // make a pass (set lastx to -1), depth NOT incremented.
      return getMin(-1, -1, OTHER(color), depth, 1-passes, 0, prevminDOF, 
                    selfPieces, oppPieces, alpha, beta);
  }
  /* Now there are legal moves to make */
  float maxValue = SMALL_FLOAT;
  float currValue;
  /* first test the move adjacent to last oppenent move (if any) */
  if(lastx != -1) {
    for(char i=0; i<8; i++) {
      x = lastx + DIRECTION[i][0];
      y = lasty + DIRECTION[i][1];
      if(ON_BOARD(x, y)) {
        place = CONV_21(x, y);
        if(place < 32) {
          if(mask0 & (1 << place)) { // it is a legal move
            copyBoardArray(a1, a);
            nFlips = tryMove(a1, color, x, y);
            currValue = getMin(x, y, OTHER(color), depth+1, passes, 
                                nLegalMoves, prevminDOF, selfPieces+nFlips+1, 
                                oppPieces-nFlips, alpha, beta);
            mask0 = mask0 & ~(1 << place);  // make off this bit.
            if(currValue > maxValue)
              maxValue = currValue;
            if(maxValue > alpha)
              alpha = maxValue;
            if(alpha >= beta) { // prun brunch as soon as alpha and beta crosses.
              if(COUNT_PRUNING)
                countPruning++;
              return alpha;
            }
          }
        }
        else { // place >= 32
          if(mask1 & (1 << (place - 32))) { // it is a legal move
            copyBoardArray(a1, a);
            nFlips = tryMove(a1, color, x, y);
            currValue = getMin(x, y, OTHER(color), depth+1, passes, 
                                nLegalMoves, prevminDOF,  selfPieces+nFlips+1, 
                                oppPieces-nFlips, alpha, beta);
            mask1 = mask1 & ~(1 << (place - 32));  // make off this bit.
            if(currValue > maxValue)
              maxValue = currValue;
            if(maxValue > alpha)
              alpha = maxValue;
            if(alpha >= beta) {
              if(COUNT_PRUNING)
                countPruning++;
              return alpha;
            }
          }
        }
      }
    }
  }
  /* Now try the rest moves */
  for(y=0; y<4; y++)
    for(x=0; x<8; x++) {
      place = CONV_21(x, y);
      if(mask0 & (1 << place)) { // move is legal
        copyBoardArray(a1, a);
        nFlips = tryMove(a1, color, x, y);
        currValue = getMin(x, y, OTHER(color), depth+1, passes, nLegalMoves, prevminDOF, 
                           selfPieces+nFlips+1, oppPieces-nFlips, alpha, beta);
        if(currValue > maxValue)
          maxValue = currValue;
        if(maxValue > alpha)
          alpha = maxValue;
        if(alpha >= beta) { // prun brunch as soon as alpha and beta crosses.
          if(COUNT_PRUNING)
            countPruning++;
          return alpha;
        }
      }
    }
  for(y=4; y<8; y++)
    for(x=0; x<8; x++) {
      place = CONV_21(x, y);
      if(mask1 & (1 << (place - 32))) { // move is legal
        copyBoardArray(a1, a);
        nFlips = tryMove(a1, color, x, y);
        currValue = getMin(x, y, OTHER(color), depth+1, passes, nLegalMoves, prevminDOF, 
                           selfPieces+nFlips+1, oppPieces-nFlips, alpha, beta);
        if(currValue > maxValue)
          maxValue = currValue;
        if(maxValue > alpha)
          alpha = maxValue;
        if(alpha >= beta) { // prun brunch as soon as alpha and beta crosses.
          if(COUNT_PRUNING)
            countPruning++;
          return alpha;
        }
      }
    }
  return maxValue;
}

/************************ End of Minimax core ***********************/


/* copy a board array */
void copyBoardArray(char *to, char *from) {
  for(int i=0; i<60; i+=6) { // some loop unrolling
    to[i] = from[i];
    to[i+1] = from[i+1];
    to[i+2] = from[i+2];
    to[i+3] = from[i+3];
    to[i+4] = from[i+4];
    to[i+5] = from[i+5];
  }
  to[60] = from[60];
  to[61] = from[61];
  to[62] = from[62];
  to[63] = from[63];
}

/* test if a move is legal one a board array for the given color */
/* NOTE: this code is sloooooow! Write seperate code for each of the eight
  possible directions is one way to improve its speed */
bool legalMove(char *a, char color, char x, char y) {
  char place = CONV_21(x, y);
  if(a[place] != EMPTY)
    return false;
  /* test left for possible flips */
  bool result = false;
  for(char dir=0; dir<8; dir++) {
    char dx = DIRECTION[dir][0];
    char dy = DIRECTION[dir][1];
    char tx = x+2*dx;
    char ty = y+2*dy;
    /* need to be at least 2 grids away from the edge and a oppenent piece 
      adjacent in the direction */
    if(!ON_BOARD(tx, ty) || a[CONV_21(x+dx, y+dy)] != OTHER(color))
      continue;
    while(ON_BOARD(tx, ty) && a[CONV_21(tx, ty)] == OTHER(color)) {
      tx += dx;
      ty += dy;
    }
    if(ON_BOARD(tx, ty) && a[CONV_21(tx, ty)] == color) {
      result = true;
      break;
    }
  }
  return result;
}

/* find all the legal moves, stored as bitmask of two ints. Returns the number 
  of legalMoves found */
char findLegalMoves(char *a, char color, unsigned int *mask0, unsigned int *mask1) {
  char count = 0;
  unsigned int isLegal;
  *mask0 = 0;
  *mask1 = 0;
  for(char y=0; y<4; y++)
    for(char x=0; x<8; x++) {
      isLegal = legalMove(a, color, x, y);
      if(isLegal) {
        *mask0 = *mask0 | 1 << CONV_21(x, y);
        count++;
      }
    }
  for(char y=4; y<8; y++)
    for(char x=0; x<8; x++) {
      isLegal = legalMove(a, color, x, y);
      if(isLegal) {
        *mask1 = *mask1 | 1 << CONV_21(x, y);
        count++;
      }
    }
  return count;
}

/* try a move on the minimax's board. Return the number of pieces flipped. 
  (also slow) */
char tryMove(char *a, char color, char x, char y) {
  char flipCount = 0;
  char dx, dy, tx, ty;
  for(char dir=0; dir<8; dir++) {
    dx = DIRECTION[dir][0];
    dy = DIRECTION[dir][1];
    tx = x+2*dx;
    ty = y+2*dy;
    /* need to be at least 2 grids away from the edge and a oppenent piece 
      adjacent in the direction to make flips in this direction. */
    if(!ON_BOARD(tx, ty) || a[CONV_21(x+dx, y+dy)] != OTHER(color))
      continue;
    while(ON_BOARD(tx, ty) && a[CONV_21(tx, ty)] == OTHER(color)) {
      tx += dx;
      ty += dy;
    }
    /* go back and flip the pieces if it should happen */
    if(ON_BOARD(tx, ty) && a[CONV_21(tx, ty)] == color) {
      tx -= dx;
      ty -= dy;
      while(a[CONV_21(tx, ty)] == OTHER(color)) {
        a[CONV_21(tx, ty)] = color;
        flipCount++;
        tx -= dx;
        ty -= dy;
      }
    }
  }
  /* the new piece is added if it caused any flips */
  if(flipCount)
    a[CONV_21(x, y)] = color;
  return flipCount;
}

/* Premitive evaluation functions -- not good at all, just to make game going */
/* Evaluate an end-of-game situation (just count) */
float evaluateEndGame(char selfPieces, char oppPieces) {
  if(COUNT_PRUNING)
    countEval++;
  char diff = selfPieces - oppPieces;
  if(winLarge) // try to win by as many (or lose as few) as posssible
    return 1.0e10 * (float)diff;
  else { // Only three states: win, lose or draw.
    if(diff > 0) // as long as win, doesn't care score
      return LARGE_FLOAT;
    else if(diff < 0) // if losing, still want to struggle a bit
      return 1.0e10 * (float)diff;
    else
      return 0.0;
  }
}

/* Evaluate an board situation (game still in progress) */
float evaluateBoard(char *a, char forWhom, char whoseTurn, char prevmaxDOF, 
                    char prevminDOF, char selfPieces, char oppPieces) {
  if(DEBUG_MINIMAX) {
    printBoardArray(a);
    printf("Depth: %d, eval. value: %e\n", selfPieces+oppPieces-base-4, 
            (float)(selfPieces-oppPieces));
    return selfPieces - oppPieces;
  }
  if(COUNT_PRUNING)
    countEval++;
  
  char nLegalMoves = findLegalMoves(a, whoseTurn, &temp0, &temp1); // slow step.
  if(forWhom == whoseTurn)
    prevmaxDOF = nLegalMoves;
  else
    prevminDOF = nLegalMoves;
  // */   
  // disc count unimportant during midd
  float result = (0.01 * (selfPieces - oppPieces)) + 
                (prevmaxDOF / (prevminDOF + extra));
  /* A little simple account for corners */
  char sign;
  if(forWhom == BLACK)
    sign = 1; 
  else
    sign = -1;
  // BLACK = 1, WHITE = 2, EMPTY = 0
  // Approach 1 -- About the same speed as Approch 2
  char mean = EMPTY+1;
  result += (((a[0]+1) % 3 - mean) * sign) * ESTIMATED_CORNER_WORTH;
  result += (((a[7]+1) % 3 - mean) * sign) * ESTIMATED_CORNER_WORTH;
  result += (((a[56]+1) % 3 - mean) * sign) * ESTIMATED_CORNER_WORTH;
  result += (((a[63]+1) % 3 - mean) * sign) * ESTIMATED_CORNER_WORTH;
  return result;
}

/* Print out the board array -- for debugging purpose */
void printBoardArray(char *a) {
  char place;
  printf("\n   0 1 2 3 4 5 6 7\n");
  for(char y=0; y<8; y++) {
    printf("%d  ", y);
    for(char x=0; x<8; x++) {
      place = CONV_21(x, y);
      if(a[place] == BLACK)
        printf("X ");
      else if(a[place] == WHITE)
        printf("O ");
      else
        printf(". ");
    }
    printf("\n");
  }
  printf("\n");
}

/* Uses Andersson's complicated end of game solver 
  Here 'color' is the opponent color as viewed by Minimax, but is 'self' 
  as viewed by EndSolve. */
int strongEndGameSolve(char depth, char color, char selfPieces, char oppPieces, 
                       char prevNotPass, float alpha, float beta) {
  int result;
  int nEmpties = 64 - selfPieces - oppPieces;
  int difference = oppPieces - selfPieces;
  int ecolor = color == BLACK? END_BLACK : END_WHITE;
  uchar eboard[91]; // board specified by the end of game solver
  for(int i=0; i<91; i++)
    eboard[i] = DUMMY;
  char *a = mmBoard[depth];
  for(int y=0; y<8; y++)
    for(int x=0; x<8; x++) {
      if(a[CONV_21(x, y)] == BLACK)
        eboard[10+x+9*y] = END_BLACK;
      else if(a[CONV_21(x, y)] == WHITE)
        eboard[10+x+9*y] = END_WHITE;
      else
        eboard[10+x+9*y] = END_EMPTY;
    }
  PrepareToSolve(eboard);
  result = EndSolve(eboard, alpha, beta, ecolor, nEmpties, difference, prevNotPass);
  return 0 - result; // since result is as viewed by opponent.
}

