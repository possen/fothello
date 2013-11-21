/* 
   board.cpp  --  this file is a part of Othello
   containing data & fucntions related to the board. 
    
   This is the board for the game engine. AI functions should not use its 
   method, but instead access the board array directly.
*/


#include "board.hpp"


/* calls malloc to allocate memory for board and initialize to start-of-game 
  configurations, a pointer to the board is returned. */
Board* makeBoard(char isFlipped) {
  Board *b = (Board*)malloc(sizeof(Board)); // free if no longer used!
  initBoard(b, isFlipped);
  return b;
}

/* initialize a given board to start-of-game configuration. */
void initBoard(Board *board, char isFlipped) {
  char *a = board->a[0];
  for(int i=0; i<64; i++)
    a[i] = EMPTY;
  if(isFlipped) {
    a[27] = BLACK;
    a[28] = WHITE;
    a[35] = WHITE;
    a[36] = BLACK;
  }
  else {
    a[27] = WHITE;
    a[28] = BLACK;
    a[35] = BLACK;
    a[36] = WHITE;
  }
  board->n = 0;
  board->m = 0;
  board->top = 0;
  board->wt = BLACK;
  board->moves[0] = PASS; // "zeroth" move actually doesn't exist
}

/* -- Access methods: avoid using (access board directly) whenver speed matters -- */
/* set a grid to a certain color */
void setPiece(Board *board, char place, char color) {
  board->a[board->n][place] = color;
}

/* get color */
char getPiece(Board *board, char place) {
  return board->a[board->n][place];
}

void flipPiece(Board *board, char place) {
  char &p = board->a[board->n][place];
  p = OTHER(p);
}
/*-----------------------------*/

///* initialize the board array for the next move (if the move is not PASS) 
//   This increment the stack pointers and copies the board array to the top level */
//static void initNextMove(Board *b) {
//  b->n = b->n + 1;
//  b->m = b->m + 1;
//  b->top = b->m;
//}

/* test if a point is on board */

/* Test if a move is legal of not */
bool legalMove(Board *b, char x, char y) {
  char n = b->n;
  char *a = b->a[n];
  char place = CONV_21(x, y);
  if(x < 0 || x > 7 || y < 0 || y > 7)
    return false;
  if(a[place] != EMPTY)
    return false;
  /* test left for possible flips */
  char wt = b->wt;
  bool result = false;
  for(char dir=0; dir<8; dir++) {
    char dx = DIRECTION[dir][0];
    char dy = DIRECTION[dir][1];
    char tx = x+2*dx;
    char ty = y+2*dy;
    /* need to be at least 2 grids away from the edge and a oppenent piece 
      adjacent in the direction */
    if(!ON_BOARD(tx, ty) || a[CONV_21(x+dx, y+dy)] != OTHER(wt))
      continue;
    while(ON_BOARD(tx, ty) && a[CONV_21(tx, ty)] == OTHER(wt)) {
      tx += dx;
      ty += dy;
    }
    if(ON_BOARD(tx, ty) && a[CONV_21(tx, ty)] == wt) {
      result = true;
      break;
    }
  }
  return result;
}

/* get all legal moves */
bool findLegalMoves(Board *b, bool *lm) {
  bool result = false;
  for(int y=0; y<8; y++) {
    for(int x=0; x<8; x++) {
      lm[CONV_21(x, y)] = legalMove(b, x, y);
      if(lm[CONV_21(x, y)])
        result = true;
    }
  }
  return result;
}

/* make a move, (x, y) must be a legal move */
void makeMove(Board *b, char x, char y) {
  char n = b->n;
  char wt = b->wt;
  char *a = b->a[n];
  char *a1 = b->a[n+1];
  char place = CONV_21(x, y);
  for(int i=0; i<64; i++)
    a1[i] = a[i];
  for(char dir=0; dir<8; dir++) {
    char dx = DIRECTION[dir][0];
    char dy = DIRECTION[dir][1];
    char tx = x+2*dx;
    char ty = y+2*dy;
    /* need to be at least 2 grids away from the edge and a oppenent piece 
      adjacent in the direction to make flips in this direction. */
    if(!ON_BOARD(tx, ty) || a[CONV_21(x+dx, y+dy)] != OTHER(wt))
      continue;
    while(ON_BOARD(tx, ty) && a[CONV_21(tx, ty)] == OTHER(wt)) {
      tx += dx;
      ty += dy;
    }
    /* go back and flip the pieces if it should happen */
    if(ON_BOARD(tx, ty) && a[CONV_21(tx, ty)] == wt) {
      tx -= dx;
      ty -= dy;
      while(a[CONV_21(tx, ty)] == OTHER(wt)) {
        a1[CONV_21(tx, ty)] = wt;
        tx -= dx;
        ty -= dy;
      }
    }
  }
  /* update the board to the next step */
  a1[place] = wt;
  b->wt = OTHER(wt);
  b->n += 1;  // actual move pointer
  b->m += 1;  // total move pointer
  b->top = b->m;  // whenever a move is made, no 'redo' possible
  b->moves[b->m] = place;  // record this move
}

/* undo a move -- return true if it can be done, false otherwise */
bool undoMove(Board *b) {
  char m = b->m;
  if(m == 0)
    return false;
  if(b->moves[m] == PASS) {
    b->m -= 1;
    b->wt = OTHER(b->wt);
  }
  else {
    b->m -= 1;
    b->n -= 1;
    b->wt = OTHER(b->wt);
  }
  return true;
}

/* redo a move -- return true if redo is possible, false otherwise */
bool redoMove(Board *b) {
  char m = b->m;
  char top = b->top;
  if(m == top)
    return false;
  if(b->moves[m+1] == PASS) {
    b->m += 1;
    b->wt = OTHER(b->wt);
  }
  else {
    b->m += 1;
    b->n += 1;
    b->wt = OTHER(b->wt);
  }
  return true;
}

/* make a pass */
void makePass(Board *b) {
  b->m += 1;
  b->wt = OTHER(b->wt);
  b->top = b->m;
  b->moves[b->m] = PASS;
}

/* count pieces (without conditional statements) 
  -- Operate on array, can be used for evaluation fucntion -- 
  1st arg is the board array, 2nd and 3th are pointers to black # and white #.
  4th arg is the total number of pieces.
  This base on assumption that BLACK==1, WHITE==2 and EMPTY==0. Some changes
  will be necessary if those there constants are redefined! */
void countPieces(char *a, char *nb, char *nw, uchar ntotal) {
  uchar sum = 0;
  for(int i=0; i<64; i+=4) {
    sum += a[i];
    sum += a[i+1];
    sum += a[i+2];
    sum += a[i+3];
  }
  *nb = WHITE*ntotal - sum;
  *nw = sum - BLACK*ntotal;
}

/* count piece function that takes a board instead of an array. Used by
  game engine. */
void countPieces(Board *b, char *nb, char *nw) {
  countPieces(b->a[b->n], nb, nw, b->n + 4); // has 4 pieces when game starts.
}

/* print out the board */
void printBoard(Board *b, bool *legalMoves) {
  char *a = b->a[b->n];
  char lastMove = b->moves[b->m];
  char place;
  const char *s;
  char nb, nw;
  countPieces(b, &nb, &nw);
  printf("\n     A B C D E F G H\n");
  for(char y=8-1; y>=0; y--) {
    if(lastMove == 8*y)
      printf("  %d (", y+1);
    else
      printf("  %d  ", y+1);
    for(char x=0; x<8; x++) {
      place = CONV_21(x, y);
      if(a[place] == BLACK)
        s = "X";
      else if(a[place] == WHITE)
        s = "O";
      else if(legalMoves[place] && showLegalMoves)
        s = "+";
      else
        s = ".";
      if(place+1 == lastMove && x != 7)
        printf("%s(", s);
      else if(place == lastMove)
        printf("%s)", s);
      else
        printf("%s ", s);
    }
    // printf(" %d", y+1);
    if(y == 0)
      printf("\tBlack: %d", nb);
    if(y == 1)
      printf("\tWhite: %d", nw);
    printf("\n");
  }
  // printf("   A B C D E F G H\n");
  printf("\n");
}


//********************************************//
/*
// Debug/test
int main (int argc, char ** argv) {
  printf("sizeof(Board): %d\n", sizeof(Board));
  Board* myB = makeBoard();
  bool legal[64];
  findLegalMoves(myB, legal);
  printBoard(myB, legal);
  makeMove(myB, 5, 4);
  findLegalMoves(myB, legal);
  printBoard(myB, legal);
  char nblack, nwhite;
  countPieces(myB, &nblack, &nwhite);
  printf("# black: %d, # white: %d\n", nblack, nwhite);
  //bool leg54 = legalMove(myB, 5, 4);
//  bool leg53 = legalMove(myB, 5, 3);
//  bool leg55 = legalMove(myB, 5, 5);
//  printf("leg53: %d, leg54: %d, leg55: %d\n", leg53, leg54, leg55);
  // makeStartGameBoard(myB);
  // printBoard(myB);
  //int p1, p2, p3;
//  p1 = getColor(myB, 3, 3);
//  p2 = getColor(myB, 2, 4);
//  p3 = getColor(myB, 3, 4);
//  printf("27: %d, 34: %d, 35: %d\n", p1, p2, p3);
//  
//  printf("COORD_21(3, 5): %d\n", COORD_21(3, 5));
//  flipBoard(myB, 1 << COORD_21(3, 3), 0);
//  printBoard(myB);
}
//*/

