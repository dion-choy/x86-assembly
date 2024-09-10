# x86 Assembly

### These files have been created and debugged in EMU8086

[Documentation for EMU8086](https://yassinebridi.github.io/asm-docs/) \
Tested on x86 emulator: [DOSBox](https://www.dosbox.com/) \
&nbsp;

## Programs Made

-   [matrixMult.asm](#matrixmultasm)
-   [sqrt.asm](#sqrtasm)
-   [snakeGame.asm](#snakegameasm)
-   [ticTacToe.asm](#tictactoeasm)
-   [pong.asm](#pongasm)
-   [minesweeper.asm](#minesweeperasm)

## Brief Overview

#### matrixMult.asm

-   Simple 3x3 multiplier
-   Places output at DS:0200h

#### sqrt.asm

-   Low Precision Square Root calculator
-   Basic I/O

    -   Input value
    -   Display result

_Program_

-   Uses Newton-Raphson method to approximate the root of following function, $f(x)=  x^2 - input$

#### snakeGame.asm

-   Snake Game
-   I/O
    -   Input directions
    -   Draw snake and apples

_Program_

-   Drawng snake

    -   Stores coordinates of body in a queue (allocated 100 words)
    -   Find tail by looping pointer(BX) through queue
    -   Replaces tail with new head

-   Pseudo-random number generator

    -   Uses system time to generate coordinates for apple

#### ticTacToe.asm

-   2 Player Tic Tac Toe Game
-   I/O
    -   Register mouse clicks
    -   Draw grid, with X's and O's
-   Win condition:

    -   Either player obtains 3 in a row

_Program_

-   Loops through rows and columns to check for 3 in a row
-   Manually checks diagonals
-   Check win condition

#### pong.asm

-   2 Player Pong Game
-   I/O

    -   Input up and down keystroke directions for both paddles

-   Win condition:

    -   Player wins 10 point
    -   Opponent loses by default

_Program_

-   Basic physics

    -   Vertical and horizontal velocity components
    -   When bounce, velocity component negates
    -   Paddle height 5x ball
    -   Angle changes based on location of paddle hit

-   Collision detection

    -   Compare height of ball with height of paddles

-   Check win and lose condition

#### minesweeper.asm

-   Minesweeper Game
-   I/O

    -   Register mouse clicks
        -   Left click digs tile
        -   Right click places flag
    -   Update screen with dug flags

-   Win condition:

    -   Only mines remaining in field (Either flagged or unflagged)

-   Lose condition:

    -   Digging on a mine tile

_Program_

-   Pseudo-random number generator

    -   Uses system time to generate coordinates for mines
    -   Checks to ensure the tile is not preoccupied

-   Uses multiple pages

    -   Main page displays dug tiles
    -   Secondary page hides generated minefield

-   When tile is dug:

    -   Tile copied from secondary to main page
    -   Counter of number of dug blocks incremented
    -   Check win and lose condition
