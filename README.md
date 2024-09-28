# x86 Assembly

### These files have been created and debugged in EMU8086

[Documentation for EMU8086](https://yassinebridi.github.io/asm-docs/) \
Tested on x86 emulator: [DOSBox](https://www.dosbox.com/)

[Webpage Demo](https://dion-choy.github.io/x86-assembly/) (using js dos API)
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

    -   Input value
    -   Display result

    **_Program_**

-   Uses Newton-Raphson method to approximate the root of following function, $f(x)=  x^2 - input$

#### snakeGame.asm

-   Snake Game

    -   Input up, down, left, right keys to change direction

-   Lose condition:

    -   Hit wall
    -   Hit self

    **_Program_**

-   Drawng snake

    -   Stores coordinates of body in a queue (allocated 100 words)
    -   Find tail by looping pointer(BX) through queue
    -   Replaces tail with new head

-   Pseudo-random number generator

    -   Uses system time to generate coordinates for apple

#### ticTacToe.asm

-   2 Player Tic Tac Toe Game

    -   Current player clicks on grid to place symbol

-   Win condition:

    -   Either player obtains 3 in a row

    **_Program_**

-   Loops through rows and columns to check for 3 in a row
-   Manually checks diagonals

#### pong.asm

-   2 Player Pong Game

    -   Left paddle controlled by 'w' and 's' key
    -   Right paddle controlled by up and down key

-   Win condition:

    -   Player wins 10 point
    -   Opponent loses by default

    **_Program_**

-   Basic physics

    -   Vertical and horizontal velocity components
    -   When bounce, velocity component negates
    -   Paddle height 5x ball
    -   Angle changes based on location of paddle hit

-   Collision detection

    -   Compare height of ball with height of paddles

#### minesweeper.asm

-   Minesweeper Game

    -   Left click digs tile
    -   Right click places flag

-   Chord clicking

    -   If a numbered tile with the same number of flags surrounding is clicked, all neighbouring tiles except flagged tiles will be revealed

-   Win condition:

    -   Only mines remaining in field (Either flagged or unflagged)

-   Lose condition:

    -   Digging on a mine tile

    **_Program_**

-   Pseudo-random number generator

    -   Uses system time to generate coordinates for mines
    -   Checks to ensure the tile is not preoccupied

-   Uses multiple pages

    -   Main page displays dug tiles
    -   Secondary page hides generated minefield

-   When tile is dug:

    -   Tile copied from secondary to main page
    -   Counter of number of dug blocks incremented

-   Recursive flood fill algorithm reveals neighbouring tiles if '0'

    -   Checks from top row to bottom row
    -   If any neighbouring tile is '0', call procedure again

#### flappyBird.asm

-   Flappy Bird

    -   Spacebar to flap wings

-   Lose condition:

    -   Bird hits floor
    -   Bird hits pillar

    **_Program_**

-   Pseudo-random number generator

    -   Uses system time to generate height of gap

-   Simple gravity

    -   Gravity of 1 char/frame
    -   Terminal velocity of 2 char/frame

-   Flapping wing:
    -   Change velocity to upwards 3 char/frame
    -   Gravity makes a smoother arc
