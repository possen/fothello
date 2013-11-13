fothello
========

Reversi like game.

This is the very beginnings of a Reversi/Othello like game for iOS. Eventually it will use SpriteKit to display
board but right now it just does the piece placement and handles the game board to flip the appropriate pieces.
You can see that in the debug window the pieces are placed and the pieces are flipped for one game. 

* It handles persisting games and related information. 
* It supports boards of larger than 8x8. 
* It handles the naming conflicts and preferred piece colors for a player
* It lets you store a game for later play.
* It has a callback mechanism to get tracks of what pieces will be flipped by a move.
* It is designed to support more than two players at once (thus the multiple colors other than black and white). 
* It reports correct or bad moves. 

Limitations
* right now the Strategy classes are just placeholders
* The main game are in one file, when getting started on a project I find it is easier to deal with just one
  file then break out later.

example output from debugger log. UI Not working yet. 
----------
|.●●●●●●●|
|...●●●●.|
|○●●●●●○○|
|○○●○●...|
|○●○○○...|
|○○○○.○..|
|●●....○.|
|●.○....○|
----------

As I said this is just the beginnings of the app and it constitues about 4-6 hours of work right now. 


Classes
=======

Fothello
--------
Root object for game. Initializes objects. Manages players, games and current game.

Game
----
Associates a players to a particular game. Initiates the board, manages the game logic such as who's turn it
is and how moves are made. Could be subclassed for a differnt variant of the game. Has functions to determine
tracks of what pieces would be flipped. It also knows how to calculate the current score. 

Player
------
Manages a preferred player color but if two players have same color will set a differnt one when the game
begins.

Piece
-----
Piece object manages a color. Every square of the board is associated with a piece even if there is no piece 
placed. 

Board
-----
Handles the grid of pieces, intended to handle the mechanics of updating the board positions. No game logic
goes here. 

Strategy
--------
Overridable strategy object. Currently not working but will have a ManualStrategy which lets players play and
Computer player strategy which could have different stratgeies for playing in the various subclasses.

Nov 12, 2013
- Paul
