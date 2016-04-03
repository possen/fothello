/* 
   board.cpp  --  this file is a part of Othello
   containing data & fucntions related to the board. 
    
   This is the board for the game engine. AI functions should not use its 
   method, but instead access the board array directly.
*/

#include <iostream>
#include <string>
#include <sstream>
#include <vector>

#include "json.hpp"
#include "board.hpp"
#include "minimax.hpp"

using namespace std;
using json = nlohmann::json;


char getMove(Board *board, char color, long moveNum, BoardDiffculty difficulty) {
    bool legalMoves[64];
    char computerHasLegalMove = findLegalMoves(board, legalMoves, color);
    if (!computerHasLegalMove)
    {
        return -1;
    }
    char nextMove = getMove(board, legalMoves, color, moveNum, (BoardDiffculty)difficulty);
    return nextMove;
}

char getMove(Board *board, bool *legalMoves, char forPlayer, char moveNum, BoardDiffculty difficulty) {
    return getMinimaxMove(board, legalMoves, forPlayer, moveNum, difficulty);
}

/* calls malloc to allocate memory for board and initialize to start-of-game 
  configurations, a pointer to the board is returned. */
Board* makeBoard() {
    Board *b = (Board*)malloc(sizeof(Board)); // free if no longer used!
    char *a = b->a;
    for(int i=0; i<64; i++) {
        a[i] = EMPTY;
    }
  return b;
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
bool legalMove(Board *b, char x, char y, char forPlayer) {
  char *a = b->a;
  char place = CONV_21(x, y);
  if(x < 0 || x > 7 || y < 0 || y > 7)
    return false;
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
    if(!ON_BOARD(tx, ty) || a[CONV_21(x+dx, y+dy)] != OTHER(forPlayer))
      continue;
    while(ON_BOARD(tx, ty) && a[CONV_21(tx, ty)] == OTHER(forPlayer)) {
      tx += dx;
      ty += dy;
    }
    if(ON_BOARD(tx, ty) && a[CONV_21(tx, ty)] == forPlayer) {
      result = true;
      break;
    }
  }
  return result;
}

/* get all legal moves */
bool findLegalMoves(Board *b, bool *lm, char forPlayer) {
  bool result = false;
  for(int y=0; y<8; y++) {
    for(int x=0; x<8; x++) {
      lm[CONV_21(x, y)] = legalMove(b, x, y, forPlayer);
      if(lm[CONV_21(x, y)])
        result = true;
    }
  }
  return result;
}

/* count pieces (without conditional statements) 
  -- Operate on array, can be used for evaluation fucntion -- 
  1st arg is the board array, 2nd and 3th are pointers to black # and white #.
  4th arg is the total number of pieces.
  This base on assumption that BLACK==1, WHITE==2 and EMPTY==0. Some changes
  will be necessary if those there constants are redefined! */
void countPieces(Board *b, char *nb, char *nw, uchar ntotal) {
    char *a = b->a;
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


/* print out the board */
void printBoard(Board *b, bool *legalMoves, char lastMove) {
  char *a = b->a;
    
  char place;
  const char *s;
  char nb, nw;
  countPieces(b, &nb, &nw, 0);
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
      else if(legalMoves[place] )
        s = "+";
      else
        s = ".";
      if(place+1 == lastMove && x != 7)
        printf("%s(", s);
      else if(place == lastMove)
        printf("%s)", s);
      else
        printf("%s ", s);

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



vector<string> split(const string &s, char delim) {
    vector<string> elems;
    stringstream ss(s);
    string item;
    while (getline(ss, item, delim)) {
        elems.push_back(item);
    }
    return elems;
}

bool setBoardFromString(Board *board, const std::string &boardStr) {
    char *a = board->a;
    vector<string> splitStr = split(boardStr, '\n');

    // drop first and last
    vector<string> rows(splitStr.begin() + 1, splitStr.end() - 1);
    if (rows.size() < 8 || rows.size() > 8)
        return false;
    int i = 0;
    for (string &row : rows) {
        string columns(row.begin() + 1, row.end() - 1);
        if (columns.size() < 8 || columns.size() > 8)
            return false;
        
        for (char &c : columns) {
            printf("%c", c);
            a[i++] = (c == 'O')
                ? WHITE
                : (c == 'X')
                    ? BLACK
                    : EMPTY;
        
        }
        printf("\n");
    }
    return true;
}

string testString("{ \"happy\": true, \"pi\": 3.141 }");
                  

bool setBoardFromJSON(Board *board, const std::string &boardStr) {
    auto json = json::parse(boardStr);
    bool result = false;
    
    return result;
}





