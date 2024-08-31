# x86 Assembly
### These files have been created and debugged in EMU8086
<a href="https://yassinebridi.github.io/asm-docs/">Documentation for EMU8086</a>
<br>
<br>
## Programs Made
- matrixMult.asm
    - Simple 3x3 multiplier
- sqrt.asm
    - Low Precision Square Root calculator
    - Uses Newton-Raphson method to approximate the root of f(x) = x<sup>2</sup> - [inputValue]
    - Basic I/O with emu8086 screen
        - Input value
        - Display result
- snakeGame.asm
    - Simple Snake Game
    - I/O with emu8086 screen
        - Input directions
        - Draw snake and apples
    - Collision detection
        - Uses list as queue by looping a pointer through
- ticTacToe.asm
    - Simple 2 Player Tic Tac Toe Game
    - I/O with emu8086 screen
        - Input mouse clicks
        - Draw grid, with X's and O's
- pong.asm
    - Simple 2 Player Pong Game
    - Basic physics
        - Vertical and horizontal velocity components 
        - When bounce, velocity component negates
        - Paddle height 5x ball
        - Angle changes based on location of paddle hit 
    - Collision detection
        - Compare height of ball with height of paddles
    - I/O with emu8086 screen
        - Input up and down directions for both paddles