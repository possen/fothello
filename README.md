fothello
========

Reversi like game.
-----------------

This is the beginnings of a Reversi like game. The idea is to get familiar with
SpriteKit and eventually GameKit. 

Capabilities
------------
* Model handles persisting games and related information.
* Model supports boards of larger than 8x8.
* Model handles the naming conflicts and preferred piece colors for a player
* Model lets you store a game for later play.
* Model has a callback mechanism to get tracks of what pieces will be flipped by a move.
* It is designed to support more than two players at once (thus the multiple colors other than black and white). 
* It reports correct or bad moves. 
* Allows different strategies for each player. 
* legal move display
* challenging play with Mini Othello for AI Strategy.

Limitations
-----------
* The game model is in one file, when getting started on a project I find it is easier to deal with just one
  file then break out later.

To Do
-----
* Undo
* Allow users to enter their names
* Add gamekit.
* UI for managing users, selecting competitors and selecting multiple manual players. 
* more than 2 players?

Classes
=======

Fothello
--------
Root object for game. Initializes objects. Manages players, games and current game.

Match
----
Associates a players to a particular match. Initiates the board, manages the game logic such as who's turn it
is and how moves are made. Could be subclassed for a different variant of the game. Has functions to determine
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
Overridable strategy object. It will called with the takeTurn method for each player. 

Nov 12, 2013
- Paul
