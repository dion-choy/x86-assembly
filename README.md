# x86 Assembly

### These files have been created and debugged in EMU8086

[Documentation for EMU8086](https://yassinebridi.github.io/asm-docs/) \
&nbsp;

## Programs Made

-   [matrixMult.asm](#matrixmultasm)
-   [sqrt.asm](#sqrtasm)
-   [snakeGame.asm](#snakegameasm)
-   [ticTacToe.asm](#tictactoeasm)
-   [pong.asm](#pongasm)

## Brief Overview

#### matrixMult.asm

-   Simple 3x3 multiplier
-   Places output at DS:0200h

#### sqrt.asm

-   Low Precision Square Root calculator
-   Uses Newton-Raphson method to approximate the root of following function, $f(x)=  x^2 - input$
-   Basic I/O with emu8086 screen
    -   Input value
    -   Display result

#### snakeGame.asm

-   Simple Snake Game
-   I/O with emu8086 screen
    -   Input directions
    -   Draw snake and apples
-   Collision detection
    -   Uses list as queue by looping a pointer through
-   Pseudo-random number generator
    -   Uses system time to generate coordinates for apple

#### ticTacToe.asm

-   Simple 2 Player Tic Tac Toe Game
-   I/O with emu8086 screen
    -   Input mouse clicks
    -   Draw grid, with X's and O's

#### pong.asm

-   Simple 2 Player Pong Game
-   Basic physics
    -   Vertical and horizontal velocity components
    -   When bounce, velocity component negates
    -   Paddle height 5x ball
    -   Angle changes based on location of paddle hit
-   Collision detection
    -   Compare height of ball with height of paddles
-   I/O with emu8086 screen
    -   Input up and down directions for both paddles
