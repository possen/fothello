fothello
========
<a href="https://codebeat.co/projects/github-com-possen-fothello-develop"><img alt="codebeat badge" src="https://codebeat.co/badges/38055ff3-1d79-4fb6-b3bd-7f1dce4bf8d8" /></a>

Reversi like game.
-----------------
`
This is the beginnings of a Reversi like game. The idea is to get familiar with
SpriteKit and eventually GameKit. 

Capabilities
------------
* Model handles persisting games and related information.
* It is designed to support more than two players at once (thus the multiple colors other than black and white). 
* It reports correct or bad moves. 
* Allows different strategies for each player. 
* legal move display
* challenging play with Mini Othello for AI Strategy.
* hints
* Undo
* Redo
* Mac and iOS
* Move display (mac only right now)
* server 
    
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
