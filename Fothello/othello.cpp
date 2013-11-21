/*********************************************************************
 *  Mini-Othello 2003     for CSCI 311 A.I. (Fall '03) Term Project
 *  Yunpeng Li & Dobo Radichkov       (version: 0.01alpha)
 *
 *  othello.cpp -- the command-line interface of Othello.
 *  It read from command line the game options.
 *  
 **********************************************************************
 */

#include "othello.hpp"

char searchDepth;
char originalSearchDepth;
char bruteForceDepth;
char mpcDepth;
bool winLarge;
char randomnessLevel;
bool useAndersson;
bool boardFlipped;
bool showLegalMoves;
// Non essential vars.
bool showDots;
bool showTime;
char selfPlayLimit;
char player1, player2;

double totalTimeUsed; // used mainly for testing.

int main(int argc, char **argv) {
  bool invalid = false;
  char isFlipped;
  // default: if no argument given.
  player1 = HUMAN;
  player2 = COMPUTER;
  searchDepth = SEARCH_BEGINNER;
  bruteForceDepth = BRUTE_FORCE_BEGINNER;
  winLarge = DEF_WIN_LARGE;
  boardFlipped = isFlipped = DEF_IS_FLIPPED;
  randomnessLevel = DEF_RANDOMNESS_LEVEL;
  showLegalMoves = true;
  useAndersson = false;
  showDots = false;
  bool showInfo = true;
  selfPlayLimit = 127;  // big enough.
  srand(time(NULL));
  
  // read from arguments
  if(argc > 1) {
    if(strcmp(argv[1], "--help") == 0 || strcmp(argv[1], "-?") == 0) {
      printUsage(argv[0]);
      return 0;
    }
    if(strcmp(argv[1], "--more-help") == 0 || strcmp(argv[1], "-h") == 0) {
      printf("\n");
      printf(HELP_MESSAGE);
      return 0;
    }
  }
  for(int i=1; i<argc; i++) {
    char *arg = argv[i];
    if(!(strlen(arg) > 1 && arg[0] == '-')) { // check "-x" format
      if(invalid)
        continue;
    }
    /* for the "--man" option */
    if(strcmp(arg, "--man") == 0) {
      if((i = argc-1)) { // missing argument
        printf("*** Argument needed after \"--man\" !\n");
        invalid = true;
        break;
      }
      char *toPlay = argv[i+1];
      if(strcmp(toPlay, "black") == 0) {
        player1 = HUMAN;
        player2 = COMPUTER;
      }
      else if(strcmp(toPlay, "white") == 0) {
        player1 = COMPUTER;
        player2 = HUMAN;
      }
      else if(strcmp(toPlay, "both") == 0) {
        player1 = HUMAN;
        player2 = HUMAN;
      }
      else if(strcmp(toPlay, "neither") == 0) {
        player1 = COMPUTER;
        player2 = COMPUTER;
      }
      else { // bad argument
        printf("*** Invalid argument \"%s\" after \"--man\" !\n", toPlay);
        invalid = true;
        i++;  // skip argv[i+1] next time.
      }
    }
    /* for the quick switches for selecting side */
    else if(strcmp(arg, "-b") == 0) {
      player1 = HUMAN;
      player2 = COMPUTER;
    }
    else if(strcmp(arg, "-w") == 0) {
      player1 = COMPUTER;
      player2 = HUMAN;
    }
    else if(strcmp(arg, "-a") == 0) {
      player1 = HUMAN;
      player2 = HUMAN;
    }
    else if(strcmp(arg, "-n") == 0) {
      player1 = COMPUTER;
      player2 = COMPUTER;
    }
    /* For computer A.I. options */
    else if(strcmp(arg, "-D") == 0 || strcmp(arg, "--depth") == 0) {
      if(i == argc-1) { // missing argument
        printf("*** Argument needed after %s !\n", arg);
        invalid = true;
        break;
      }
      char depth = atoi(argv[i+1]);
      if(depth)
        searchDepth = depth;
      else {
        printf("*** Invalid argument \"%s\" after %s !\n", argv[i+1], arg);
        invalid = true;
      }
      i++;
    }
    else if(strcmp(arg, "-E") == 0 || strcmp(arg, "--end-game") == 0) {
      if(i == argc-1) { // missing argument
        printf("*** Argument needed after %s !\n", arg);
        invalid = true;
        break;
      }
      char depth = atoi(argv[i+1]);
      if(depth) {
        bruteForceDepth = depth;
      }
      else {
        printf("*** Invalid argument \"%s\" after %s !\n", argv[i+1], arg);
        invalid = true;
      }
      i++;
    }
    else if(strcmp(arg, "-C") == 0 || strcmp(arg, "--mpc-depth") == 0) {
      if(i == argc-1) { // missing argument
        printf("*** Argument needed after %s !\n", arg);
        invalid = true;
        break;
      }
      char depth = atoi(argv[i+1]);
      if(depth) {
        mpcDepth = depth;
        printf("Warning: Multi-Prob Cutoff is not yet implemented!\n");
      }
      else {
        printf("*** Invalid argument \"%s\" after %s !\n", argv[i+1], arg);
        invalid = true;
      }
      i++;
    }
    else if(strcmp(arg, "-W") == 0 || strcmp(arg, "--win-max") == 0) {
      if(i == argc-1) { // missing argument
        printf("*** Argument needed after %s !\n", arg);
        invalid = true;
        break;
      }
      char *arg2 = argv[i+1];
      if(strlen(arg2) == 1 && arg2[0] >= '0' && arg2[0] <= '1') {
        winLarge = arg2[0] - '0';
      }
      else {
        printf("*** Invalid argument \"%s\" after %s !\n", argv[i+1], arg);
        invalid = true;
      }
      i++;
    }
    /* Other options */
    else if(strcmp(arg, "-f") == 0 || strcmp(arg, "--flip-board") == 0) {
      boardFlipped = isFlipped = 1;
    }
    else if(strcmp(arg, "-r") == 0 || strcmp(arg, "--randomness") == 0) {
      if(i == argc-1) { // missing argument
        printf("*** Argument needed after %s !\n", arg);
        return 0;
      }
      char *arg2 = argv[i+1];
      if(strlen(arg2) == 1 && arg2[0] >= '0' && arg2[0] <= '9') {
        randomnessLevel = arg2[0] - '0';
      }
      else {
        printf("*** Invalid argument \"%s\" after %s !\n", argv[i+1], arg);
        invalid = true;
      }
      i++;
    }
    else if(strcmp(arg, "-S") == 0 || strcmp(arg, "--strong-end") == 0) {
      useAndersson = true;
    }
    else if(strcmp(arg, "-p") == 0 || strcmp(arg, "--show-progress") == 0) {
      showDots = true;
    }
    else if(strcmp(arg, "-t") == 0 || strcmp(arg, "--show-time") == 0) {
      showTime = true;
    }
    else if(strcmp(arg, "--quiet") == 0) {
      showInfo = false;
    }
    else if(strcmp(arg, "-i") == 0 || strcmp(arg, "--no-hints") == 0) {
      showLegalMoves = false;
    }
    else if(strcmp(arg, "-s") == 0 || strcmp(arg, "--self-play") == 0) {
      if(i == argc-1) { // missing argument
        printf("*** Argument needed after %s !\n", arg);
        return 0;
      }
      char *arg2 = argv[i+1];
      char temp = atoi(arg2);
      if(temp > 0) {
        player1 = COMPUTER;
        player2 = COMPUTER;
        selfPlayLimit = temp;
      }
      else {
        printf("*** Invalid argument \"%s\" after %s !\n", argv[i+1], arg);
        invalid = true;
      }
      i++;
    }
    /* For the short-cut switches */
    else if(strcmp(arg, "-L0") == 0 || strcmp(arg, "--novice") == 0) {
      searchDepth = SEARCH_NOVICE;
      bruteForceDepth = BRUTE_FORCE_NOVICE;
      mpcDepth = MPC_NOVICE;
    }
    else if(strcmp(arg, "-L1") == 0 || strcmp(arg, "--beginner") == 0) {
      searchDepth = SEARCH_BEGINNER;
      bruteForceDepth = BRUTE_FORCE_BEGINNER;
      mpcDepth = MPC_BEGINNER;
    }
    else if(strcmp(arg, "-L2") == 0 || strcmp(arg, "--amateur") == 0) {
      searchDepth = SEARCH_AMATEUR;
      bruteForceDepth = BRUTE_FORCE_AMATEUR;
      mpcDepth = MPC_AMATEUR;
    }
    else if(strcmp(arg, "-L3") == 0 || strcmp(arg, "--experienced") == 0) {
      searchDepth = SEARCH_EXPERIENCED;
      bruteForceDepth = BRUTE_FORCE_EXPERIENCED;
      mpcDepth = MPC_EXPERIENCED;
    }
    else if(strcmp(arg, "-L2+") == 0) { // brute force 2 levels more.
      searchDepth = SEARCH_AMATEUR;
      bruteForceDepth = 18;
      mpcDepth = MPC_AMATEUR;
    }
    /* Otherwise it is an invalid switch */
    else {
      printf("*** Invalid option switch %s !\n", arg);
      invalid = true;
    }
  }
  if(invalid) {
    printf("Type \"%s --help\" for options.\n", argv[0]);
    return 0;
  }
  /* Game can start */
  if(bruteForceDepth > 16) {
    // turn on fast endgame solver, since mine may get a bit too slow for this depth.
    useAndersson = true;
  }
  originalSearchDepth = searchDepth; // the searchDepth var. will change during the game.
  // print out the info head
  if(showInfo) {
    printf("\n");
    printHead();
    printSettings(player1, player2);
  }
  Board *gb = makeBoard(isFlipped);
  playGame(gb);
  if(player1 == HUMAN || player2 == HUMAN)
    printThanks();
  else
    printf("Total time used: %.0f seconds\n", totalTimeUsed);
  
  return 0;
}

/* print out the some messege */
void printHead() {
  printf(PROGRAM_INFO, PROGRAM_NAME, VERSION);
}

void printUsage(char *arg0) {
  printf(PROGRAM_INFO, PROGRAM_NAME, VERSION);
  printf(OPTIONS_HELP, arg0, SEARCH_BEGINNER, BRUTE_FORCE_BEGINNER, 
        DEF_WIN_LARGE, DEF_RANDOMNESS_LEVEL,
        SEARCH_NOVICE, BRUTE_FORCE_NOVICE, 
        SEARCH_BEGINNER, BRUTE_FORCE_BEGINNER, 
        SEARCH_AMATEUR, BRUTE_FORCE_AMATEUR,
        SEARCH_EXPERIENCED, BRUTE_FORCE_EXPERIENCED, 
        arg0, arg0);
}

void printThanks() {
  printf("Thank you for playing %s !\n", PROGRAM_NAME);
}

void printSettings(char player1, char player2) {
  const char *p1, *p2, *maxwin, *fastend;
  p1 = player1 == HUMAN? "HUMAN" : "COMPUTER";
  p2 = player2 == HUMAN? "HUMAN" : "COMPUTER";
  maxwin = winLarge? "Yes" : "No";
  fastend = useAndersson? "Yes" : "No";
  printf(SETTINGS, p1, p2, searchDepth, bruteForceDepth, maxwin, randomnessLevel, 
        fastend);
}

