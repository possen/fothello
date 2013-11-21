/*** 
  game.cpp -- the game engine for Othello 

  */

#include "game.hpp"

static bool gameOver(Board *b);
static char parseHumanMove(char *buf);
#if 0
static char getRandomMove(Board *board, bool *legalMoves);
#endif

extern char player1, player2;
extern bool showLegalMoves;
extern char selfPlayLimit;
static bool temp[64];

/* the main loop of the game. player1 is black, player2 is white */
void playGame(Board *board) {
  /* declare some variables */
  char currentPlayer;
  char countBlack, countWhite;  // # of black and white pieces
  bool legalMoves[64];
  bool hasLegalMove;
  char buf[1024], bufCopied[1024];
  char nextMove;
  char x, y;
  const char *color;
  int nUR;  // how many moves to undo/redo
  int countUR;  // how many moves can be actually undo/redo
  char *token, *token2;
  bool hasSpecialCommand;
  bool firstInput;
  bool skip = false;
  /* Timing -- none essential variables */
  time_t tm1, tm2, steptm1, steptm2;
  double steptime;
  time(&tm1);
  srand(time(NULL));
  // seed the random generator
  /* main loop */
  while(!gameOver(board)) {
    hasLegalMove = findLegalMoves(board, legalMoves);
    currentPlayer = board->wt == BLACK? player1 : player2;
    color = board->wt == BLACK? "Black" : "White";
    
    // Hand game control over to human after the specified # of self-played moves.
    if(player1 == COMPUTER && player2 == COMPUTER && board->m == selfPlayLimit) {
      currentPlayer = player1 = player2 = HUMAN;
      selfPlayLimit = 120;
    }
    
    if(currentPlayer == HUMAN && !skip) {
      nextMove = ILLEGAL; // initialize for the while loop
      hasSpecialCommand = false;
      firstInput = true;
      while(!hasSpecialCommand &&
            (nextMove == ILLEGAL || (hasLegalMove && nextMove == PASS) || 
            (nextMove != PASS && !legalMoves[nextMove]))) {
        if(!firstInput)
          printf("*** INVALID MOVE! *** Please re-enter.\n");
        printBoard(board, legalMoves);
        if(!hasLegalMove)
          printf("YOU HAVE NO MOVE TO MAKE. PRESS [ENTER] TO PASS. (%s, # %d) ", 
                color, board->m + 1);
        else
          printf("Your move (%s, # %d): ", color, board->m + 1);
        gets(buf);  // read input for stdin
        strcpy(bufCopied, buf);
        token = strtok(bufCopied, " ");
        token2 = strtok(NULL, " ");
        /* first make should the the input is not empty string */
        if(!strlen(buf)) {
          if(hasLegalMove) {
            firstInput = true;
            continue;
          }
          else { // interpret it as a pass
            nextMove = PASS;
            break;
          }
        }
        /* check for special command */
        if(strcmp(buf, "?") == 0 || strcmp(buf, "help") == 0) {
          printf("\n");
            //   printf(HELP_MESSAGE);
       	  hasSpecialCommand = true;
        }
        if(strcmp(buf, "quit") == 0 || strcmp(buf, "exit") == 0) {
          return;
        }
        if(strcmp(token, "lm") == 0 || strcmp(token, "legalmoves") == 0) {
          showLegalMoves = !showLegalMoves;
          printf("Legal moves display is turned %s.\n", showLegalMoves? "ON" : "OFF");
          hasSpecialCommand = true;
        }
        else if(strcmp(buf, "swapsides") == 0) {
          char temp = player1;
          player1 = player2;
          player2 = temp;
          const char *sb, *sw;
          sb = player1 == COMPUTER? "COMPUTER" : "HUMAN";
          sw = player2 == COMPUTER? "COMPUTER" : "HUMAN";
          printf("### Sides swaped -- Black: %s, White: %s ###\n", sb, sw);
          hasSpecialCommand = true;
        }
        else if(strcmp(buf, "skip") == 0) {
          skip = true;
          hasSpecialCommand = true;
        }
        else if(strcmp(buf, "handover") == 0) {
          if(board->wt == BLACK) {
            player1 = COMPUTER;
            printf("### Black is now played by COMPUTER. ###");
          }
          else {
            player2 = COMPUTER;
            printf("### White is now played by COMPUTER. ###");
          }
          hasSpecialCommand = true;
        }
        else if(strcmp(buf, "undo") == 0 && token2 == NULL) {
          if(undoMove(board))
            printf("1 move undone.\n");
          else
            printf("No move to be undone!\n");
          hasSpecialCommand = true;
        }
        else if(strcmp(buf, "redo") == 0 && token2 == NULL) {
          if(redoMove(board))
            printf("1 move redone.\n");
          else
            printf("No move to be redone!\n");
          hasSpecialCommand = true;
        }
        else if(strcmp(token, "undo") == 0 || strcmp(token, "redo") == 0) {
          // printf("token2: %s", token2);  // degug
          nUR = token2 == NULL? 0 : atoi(token2);
          countUR = 0;
          if(strcmp(token, "undo") == 0) {
            if(strcmp(token2, "all") == 0) {
              while(undoMove(board))
                countUR++;
            }
            else {
              for(int i=0; i<nUR; i++)
                if(undoMove(board))
                  countUR++;
            }
            printf("%d moves undone.\n", countUR);
            hasSpecialCommand = true;
          }
          else if(strcmp(token, "redo") == 0) {
            if(strcmp(token2, "all") == 0) {
              while(redoMove(board))
                countUR++;
            }
            else {
              for(int i=0; i<nUR; i++)
                if(redoMove(board))
                  countUR++;
            }
            printf("%d moves redone.\n", countUR);
            hasSpecialCommand = true;
          }
        }
        else { /* parse the next move */
          nextMove = parseHumanMove(buf);
        }
        firstInput = false;
      }
      if(!hasSpecialCommand) {
        if(nextMove == PASS)
          makePass(board);
        else
          makeMove(board, nextMove % 8, nextMove / 8);
      }
    }
    else {  // the computer player.
      skip = false;
      printBoard(board, legalMoves);
      printf("Computer is thinking");
      if(!showDots)
        printf("...\n");
      if(hasLegalMove) {
        steptm1 = clock();
        nextMove = getMinimaxMove(board, legalMoves);
        steptm2 = clock();
        steptime = (double)(steptm2 - steptm1) / CLOCKS_PER_SEC;
        y = nextMove / 8;
        x = nextMove - 8*y;
        if(showDots)
          printf("\n");
        if(legalMove(board, x, y)) {
          makeMove(board, x, y);
          printf("Computer (%s, # %d) played at %c%c.", color, 
                board->m, x+'a', y+'1');
          if(showTime)
            printf("\t(%.3f seconds)", steptime);
          printf("\n");
        }
        else {
          printf("Computer (%s, # %d) returned ILLEGAL MOVE: %c%c !! Please debug!\n",
                  color, board->m, x+'a', y+'1');
          exit(1);
        }
      }
      else {
        makePass(board);
        if(showDots)
          printf("\n");
        printf("Computer passed. (%s, # %d)\n", color, board->m);
      }
    }
  }
  /* game is over */
  findLegalMoves(board, legalMoves);
  printBoard(board, legalMoves);
  countPieces(board, &countBlack, &countWhite);
  if(countBlack > countWhite) { // use the winner-gets-empties convention.
    printf("Black wins by %d to %d.\n", 64 - countWhite, countWhite);
  }
  else if(countBlack < countWhite) {
    printf("White wins by %d to %d.\n", 64 - countBlack, countBlack);
  }
  else {
    printf("Game is drawn at %d to %d.\n", countBlack, countWhite);
  }
  time(&tm2);
    //  totalTimeUsed = difftime(tm2, tm1);
}

/* Test if the game is over */
static bool gameOver(Board *b) {
  if(findLegalMoves(b, temp)) {
    return false;
  }
  makePass(b);
  if(findLegalMoves(b, temp)) {
    undoMove(b);
    return false;
  }
  undoMove(b);
  return true;
}

/* Parse the move from a string */
static char parseHumanMove(char *buf) {
  char p;
  char x, y;
  if(strcmp(buf, "pass") == 0)
    return PASS;
  if(strlen(buf) < 2)
    return ILLEGAL;
  if(buf[0] >= 'a' && buf[0] <= 'h')
    x = buf[0] - 'a';
  else if(buf[0] >= 'A' && buf[0] <= 'H')
    x = buf[0] - 'A';
  else
    return ILLEGAL;
  p = 1;
  while(buf[p] == ' ' || buf[p] == '-')
    p++;
  if(buf[p] >= '1' && buf[p] <= '8')
    y = buf[p] - '1';
  else
    return ILLEGAL;
  return CONV_21(x, y);
}

#if 0
/* Generate a random move */
static char getRandomMove(Board *board, bool *legalMoves) {
  char start = (char)(rand() % 64);
  for(char i=start; i<64; i++)
    if(legalMoves[i])
      return i;
  for(char i=0; i<start; i++)
    if(legalMoves[i])
      return i;
  return PASS;
}
#endif

// temporary
/*
char searchDepth;
char bruteForceDepth;
bool winLarge;
//*/

/******  Main: test/debug ***************/
/*
int main(int argc, char **argv) {
  searchDepth = 8;
  char oldSD = searchDepth;
  bruteForceDepth = 16;
  winLarge = 1;
  char isFlipped = 0;
  char player1 = HUMAN;
  char player2 = COMPUTER;
  if(argc >= 3) {
    player1 = strcmp(argv[1], "c")? HUMAN : COMPUTER;
    player2 = strcmp(argv[2], "c")? HUMAN : COMPUTER;
  }  
  if(argc >= 4) 
    searchDepth = atoi(argv[3]);
  if(argc >= 5)
    bruteForceDepth = atoi(argv[4]);
  if(argc >= 6)
    winLarge = atoi(argv[5]);
  if(argc >= 7)
    isFlipped = atoi(argv[6]);

  time_t t1, t2;
  time(&t1);
  
  Board *gb = makeBoard(isFlipped);
  playGame(gb, player1, player2);
  
  time(&t2);
  double timePassed = difftime(t2, t1); 
  printf("Total time: %f seconds. (depth: %d, brute-force: %d, winLarge: %d)\n",
         timePassed, oldSD, bruteForceDepth, winLarge);
  
  //makeMove(gb, 5, 4);
//  bool legalMoves[64];
//  findLegalMoves(gb, legalMoves);
//  printBoard(gb, legalMoves);
//  char compMove = getMinimaxMove(gb, legalMoves);
//  printf("compMove: %d\n", compMove);
//  makeMove(gb, compMove % 8, compMove / 8);
//  findLegalMoves(gb, legalMoves);
//  printBoard(gb, legalMoves);
  
  //// playGame(gb, HUMAN, COMPUTER);
//  printBoard(gb, legalMoves);
//  unsigned int mask0, mask1;
//  int nLegalMoves = findLegalMoves(gb->a[0], gb->wt, &mask0, &mask1);
//  printf("nLegalMoves: %d\n", nLegalMoves);
//  char index = 0;
//  while(index < 64 && !legalMoves[index])
//    index++;
//  copyBoardArray(gb->a[1], gb->a[0]);
//  bool *temp = (bool*)calloc(64, sizeof(bool));
//  tryMove(gb->a[0], BLACK, index % 8, index / 8);
//  printBoard(gb, temp);
//  tryMove(gb->a[0], WHITE, 2, 4);
//  printBoard(gb, temp);
//  tryMove(gb->a[0], BLACK, 3, 5);
//  printBoard(gb, temp);
//  tryMove(gb->a[0], WHITE, 4, 2);
//  printBoard(gb, temp);
  return 0;
}
// */

  /*
  bool correct = true;
  for(int i=0; i<32; i++) {
    if((legalMoves[i] && !(mask0 & (1 << i))) ||
       (!legalMoves[i] && (mask0 & (1 << i)))) {
      correct = false;
      printf("Incorrect at bit %d\n", i);
    }
  }
  for(int i=32; i<64; i++) {
    if((legalMoves[i] && !(mask1 & (1 << (i-32)))) || 
       (!legalMoves[i] && (mask1 & (1 << (i-32))))) {
      correct = false;
      printf("Incorrect at bit %d\n", i);
    }
  }
  printf("Test result: %d\n", correct);
  bool wrongMoves[64];
  for(int i=0; i<32; i++)
    wrongMoves[i] = mask0 & (1 << i);
  for(int i=32; i<64; i++)
    wrongMoves[i] = mask1 & (1 << (i-32));
  printf("Wrong moves: \n");
  printBoard(gb, wrongMoves);
  // */


