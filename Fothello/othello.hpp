/*********
  othello.hpp
  */

#ifndef _OTHELLO_HPP_
#define _OTHELLO_HPP_

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "game.hpp"

#define SEARCH_NOVICE             4
#define SEARCH_BEGINNER           6
#define SEARCH_AMATEUR            8
#define SEARCH_EXPERIENCED        10

#define BRUTE_FORCE_NOVICE        12
#define BRUTE_FORCE_BEGINNER      14
#define BRUTE_FORCE_AMATEUR       16
#define BRUTE_FORCE_EXPERIENCED   19

// MPC not yet implemented
#define MPC_NOVICE        0
#define MPC_BEGINNER      0
#define MPC_AMATEUR       0
#define MPC_EXPERIENCED   0

// Default values
#define DEF_WIN_LARGE         1
#define DEF_IS_FLIPPED        0
#define DEF_RANDOMNESS_LEVEL  2

#define PROGRAM_NAME "Mini-Othello"
#define VERSION "0.01-alpha-1"

const char *PROGRAM_INFO = "%s (2003)   v%s\
  \nYunpeng Li & Dobo Radichkov (for F03-CSCI311 A.I. Term Project)\n";

const char *OPTIONS_HELP = "\nUsage: %s [options]\n\
  \nPlayer Options: \n\
    --man <side>      Human plays which side  (default black)\n\
    -b    <side> = black       Human plays black                             \n\
    -w             white       Human plays white                             \n\
    -a             both        Human plays both sides, i.e. no computer      \n\
    -n             neither     Human plays neither side, i.e. two computers  \n\
  \nComputer A.I. Options (higher = stronger, slower): \n\
    -D, --depth      <depth>   Mid-game search depth (default %d)\n\
    -E, --end-game   <depth>   End game brute force depth (default %d)\n\
    -C, --mpc-depth  <depth>   M.P.C. cutoff depth (not yet implemented)\n\
    -W, --win-max    <0/1>     Computer tries to maximze a win or minimize\n\
                               a loss (default %d)\n\
  \nOther Options: \n\
    -S, --strong-end           Use Andersson's fast end of game solver, it is \n\
                               automatically turned on when -E value > 16\n\
    -r, --randomness  <0-9>    Randomness level for computer player (default %d)\n\
    -f, --flip-board           Start with the game board mirrored\n\
    -s, --self-play   <n>      Self-play for n moves, then hand over to human\n\
    -p, --show-progress        Show computer's thinking progress\n\
    -t, --show-time            Show the time taken for each computer move\n\
    -i, --no-hints             Don't show legal moves as '+' on the board\n\
        --quiet                Don't print out the informational message\n\
    -?, --help                 Display this message\n\
    -h, --more-help            Display control commands\n\
  \nShort-cut switches: \n\
    -L0, --novice      ==   -D %d  -E %d\n\
    -L1, --beginner    ==   -D %d  -E %d    (default)\n\
    -L2, --amateur     ==   -D %d  -E %d    (-L2+ for adding \"-E 18 -S\")\n\
    -L3, --exprienced  ==   -D %d  -E %d  -S  (very slow!)\n\
  \nExamples: \n\
    %s --novice\n\
    %s --depth 10 --end-game 18 -w -W 0\n";

const char *SETTINGS = "\nGame started with the following settings:\n\
  Black:                              %s\n\
  White:                              %s\n\
  Mid game search depth:              %d\n\
  End game search depth:              %d\n\
  Multi-prob cutoff depth:            N/A\n\
  Maximize winning score:             %s\n\
  Randomness level:                   %d\n\
  Use fast end of game solver:        %s\n";

const char *HELP_MESSAGE = 
"Symbols: 'X' = Black, 'O' = White, '.' = Empty,  '+' = Legal move\
  \nTo move, enter a letter followed by a number.\
  \nExamples: d5, G6, c 8, a-1\
  \nSpecial Command (during a game):\n\
  undo        --  Undo the last move.\n\
  redo        --  Redo the move that was undone.\n\
  undo <n>    --  Undo the last n moves.\n\
  redo <n>    --  Redo n moves.\n\
  undo all    --  Undo all moves.\n\
  redo all    --  Redo all moves.\n\
  lm          --  Turn off/on display of legalmoves as '+'.\n\
  swapsides   --  Swap the players' colors.\n\
  skip        --  Make the play the current move for the human player.\n\
  handover    --  Let computer play the rest of game for the human player.\n\
  help        --  Display this message.\n";
  
    
void printHead();
void printUsage(char *arg0);
void printThanks();
void printSettings(char player1, char player2);

#endif
