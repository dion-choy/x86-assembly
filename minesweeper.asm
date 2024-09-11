
org 100h

jmp drawField

mineChar equ 162    ; ASCII for mine
flagChar equ 16     ; ASCII for flag
emptyChar equ 176   ; ASCII for shaded block
display equ 0   ; main page
minefield equ 1 ; minefield (hidden) page
numOfBombs equ 99   ; <========= NUM OF MINES
numOfRevealed dw 0
pRNG db 0           ; store next num

winMessage db "You WIN!!", 0Dh, 0Ah, "$"
loseMessage db "You Lose", 0Dh, 0Ah, "$"             
lastMessage db "Press any key to close...", 0Dh, 0Ah, "$"

drawField:      ; draw minefield
mov ax, 3
int 10h

mov dh, 3
mov dl, 25     
mov bh, minefield     ; write to hidden page
mov bl, 77h
mov cx, 16
mov al, '0'
call fillWithChar

; load number of mines, setcursor to full box
mov ch, 0
mov cl, 7
mov ah, 1
int 10h

mov cx, numOfBombs
populateMines:
push cx

mov ah, 2Ch
int 21h             ; interrupt to get sys time
mov pRNG, dl

rerollCoords:

mov ah, 2Ch
int 21h             ; interrupt to get sys time
mov ax, 0

mov bh, 16
mov al, dl
add al, pRNG
div bh
mov bh, ah          ; modulus so row is 0-16
add bh, 4

mov ah, 2Ch
int 21h             ; interrupt to get sys time
mov ax, 0

mov bl, 30
mov al, dl
add al, pRNG
div bl
mov bl, ah          ; modulus so col is 0-30
add bl, 25 

mov dx, bx  
mov bh, minefield
mov ah, 2
int 10h             ; interrupt to move cursor

mov ah, 8
int 10h 
cmp al, mineChar         ; check if occupied
je rerollCoords


mov al, mineChar         ; if no mineChar, draw
mov ah, 09h  
mov bl, 0F0h        ; attribute black colour
mov cx, 1
int 10h

mov ch, 32          ; when cursor full block and black text,
mov cl, 7           ; creates blinking effect
mov ah, 1           ; these lines REMOVE effect
int 10h
call incSides       
mov ch, 0           ; restore with block cursor
mov cl, 7           ; so bombs have blinking effect
mov ah, 1
int 10h

pop cx
loop populateMines

mov bh, display
call drawBorder

mov bh, minefield
call drawBorder

mov dh, 3
mov dl, 25     
mov bh, display     ; write to display
mov bl, 70h
mov cx, 16
mov al, emptyChar
call fillWithChar

jmp allowInput

; SETUP PROCEDURES
fillWithChar proc
    fillWithCharLoop:      ; fill out field with
    push cx                ; char at AL
    
    inc dh
    mov ah, 2
    int 10h
    
    mov ah, 09h
    mov cx, 30
    int 10h
    pop cx
    loop fillWithCharLoop
    ret
fillWithChar endp


drawBorder proc     ; draw minefield
    mov dh, 3
    mov dl, 24
    mov ah, 2
    int 10h  
    
    mov ah, 0Ah     ; draw top border
    mov al, "#"
    mov cx, 32
    int 10h
    
    mov cx, 16
    drawSides:          ; draw vertical sides
    push cx
    
    inc dh
    mov dl, 24
    mov ah, 2
    int 10h
    
    mov ah, 0Ah
    mov al, "#"
    mov cx, 1
    int 10h
    
    mov dl, 55
    mov ah, 2
    int 10h
    
    mov ah, 0Ah
    mov al, "#"
    mov cx, 1
    int 10h
    
    pop cx
    loop drawSides
           
    mov dh, 20
    mov dl, 24
    mov ah, 2
    int 10h  
    
    mov ah, 0Ah     ; draw bottom border
    mov al, "#"
    mov cx, 32
    int 10h
    ret
drawBorder endp

incSides proc               ; when mine spawns
    mov cl, mineChar        ; increment all tiles around it
    
    dec dh
    dec dl
    call check          ; check if tile is mine
    je noNWBomb         ; if yes skip inc
    call incTiles
                        ; same...
    noNWBomb:           ; for...
    inc dl              ; remaining...
    call check
    je noNBomb
    call incTiles
    
    noNBomb:   
    inc dl
    call check
    je noNEBomb
    call incTiles
    
    noNEBomb:
    inc dh
    call check
    je noEBomb
    call incTiles
    
    noEBomb: 
    inc dh
    call check
    je noSEBomb
    call incTiles
    
    noSEBomb:
    dec dl
    call check
    je noSBomb
    call incTiles
    
    noSBomb:
    dec dl
    call check
    je noSWBomb
    call incTiles
    
    noSWBomb:
    dec dh
    call check
    je noWBomb
    call incTiles
    
    noWBomb: 

    ret
incSides endp

incTiles proc       ; procedure to increment tile
    push cx         ; and write colour
    inc al
    and ah, 0F0h
    
    cmp al, '1'     ; check if number
    jne above1      ; if not then skip
    or ah, 09h
    jmp colourEnd   ; jmp to end
    
    above1:         ; same...
    cmp al, '2'     ; for...
    jne above2      ; remaining...
    or ah, 02h
    jmp colourEnd
    
    above2:
    cmp al, '3'
    jne above3
    or ah, 0Ch
    jmp colourEnd
    
    above3:
    cmp al, '4'
    jne above4
    or ah, 01h
    jmp colourEnd
    
    above4:
    cmp al, '5'
    jne above5
    or ah, 06h
    jmp colourEnd
    
    above5:
    cmp al, '6'
    jne above6
    or ah, 03h
    jmp colourEnd
    
    above6:
    cmp al, '7'
    jne above7
    or ah, 00h
    jmp colourEnd
    
    above7:
    cmp al, '8'
    jne above8
    or ah, 08h
    jmp colourEnd
    
    above8:
    cmp al, '9'
    jne notNum
    or ah, 0Fh
    jmp colourEnd
    
    notNum:
    or ah, 07h
    
    colourEnd:
    mov bl, ah
    
    mov ah, 09h
    mov cx, 1
    int 10h
    pop cx
    ret
incTiles endp
; END SETUP PROCEDURES

allowInput:     ; start user input
mov ch, 6
mov cl, 7       ; set underline cursor shape
mov ah, 1
int 10h

mov ax, 0       ; set mouse input but hide cursor because
int 33h         ; MS DOS block cursor shape doesn't write 
                ; char properly

again:          ; ===========GAMEPLAY LOOP===========
mov ax, 3
int 33h         ; detect user input

push bx         ; BX contains left/right click so push to stack
mov ax, cx      ; cx, dx in subpixels
mov cl, 8       ; hence div by 8
div cl

xchg ax, dx
div cl

mov dh, al
mov bh, display
mov ah, 2       ; move text cursor to mouse to replace block
int 10h

pop bx          ; restore left/right click
cmp bl, 1       ; if left click, reveal tile
je revealTile

cmp bl, 2       ; if right click, place flag
je placeFlagChar

; Check if WIN condition => only bombs left on screen
; i.e. numOfTiles - numOfRevealed = numOfBombs
mov ax, 480     ; 480 <= number of tiles on screen
sub ax, numOfRevealed
cmp ax, numOfBombs  ; if num of remaining = num of bombs
je winExit          ; win

jmp again

; LEFT CLICK FUNCTION
revealTile:

mov cl, flagChar
mov bl, display
call check          ; check if current tile is flagChar
je leftMouseDown    ; if yes, ignore click

mov cl, emptyChar   ; check if empty tile
mov bl, display
call check
jne leftMouseDown   ; if not empty, ignore click

call copyTile       ; when click not ignored, copy tile

cmp al, mineChar    ; if copied tile = mine
je loseExit         ; lose

cmp al, '0'         ; if copied tile = '0'
jne leftMouseDown   ;   
call revealNeighbours    ; reveal neighbour tiles

leftMouseDown:
mov ax, 3
int 33h
cmp bl, 1
je leftMouseDown    ; loop until mouse click is released
jmp again           ; return to function

; RIGHT CLICK FUNCTION
placeFlagChar:

mov cl, flagChar
mov bl, display
call check          ; check if tile is flagChar
jne flagCharTile    ; if yes, toggle off

mov al, emptyChar
mov ah, 09h  
mov bl, 70h 
mov cx, 1
int 10h

jmp rightMouseDown

flagCharTile:

mov cl, emptyChar
mov bl, display
call check          ; else, check if empty char to toggle on
jne rightMouseDown

mov al, flagChar
mov ah, 09h  
mov bl, 1100b 
mov cx, 1
int 10h

rightMouseDown:

mov ax, 3
int 33h
cmp bl, 2
je rightMouseDown   ; loop until mouse released
jmp again           ; return

; GAMELOOP PROCEDURES
check proc          ; DX: row, col
    mov ah, 2       ; CL: char to check
    int 10h         ; BL: page to check
    
    mov ah, 8
    int 10h
    
    cmp al, cl      ; set relevant flags
    ret
check endp

copyTile proc           ; DX: row, col
    push cx
    mov bh, minefield
    mov ah, 2
    int 10h             ; move cursor to hidden page
    
    mov ah, 8
    int 10h             ; read text and
    mov bl, ah          ; move char to BL for next int
    
    mov bh, display
    mov ah, 2
    int 10h             ; move cursor to main page
    
    mov ah, 09h
    mov bh, display
    mov cx, 1           ; write char
    int 10h
    
    inc numOfRevealed
    pop cx      
    ret
copyTile endp

revealNeighbours proc   ; Recursive function to reveal neighbours
    dec dh          ; N -> NE -> NW -> E -> W -> S -> SE -> SW
    
    call revealTiles

    inc dl      
    
    call revealTiles
    
    sub dl, 2
    
    call revealTiles
    
    add dl, 2
    inc dh
    
    call revealTiles
    
    dec dl
    dec dl
    
    call revealTiles
    
    inc dl
    inc dh
    
    call revealTiles
    
    dec dl
    
    call revealTiles
    
    add dl, 2
    call revealTiles
    
    dec dh
    dec dl
    mov ah, 2
    int 10h
    
    ret
revealNeighbours endp

revealTiles proc
    mov cl, emptyChar
    mov bh, display
    call check          ; check if empty tile
    jne noZero          ; if not empty skip to next tile
    
    call copyTile       ; reveal tile
    
    mov cl, '0'
    mov bh, minefield
    call check          ; check if 0
    jne noZero          ; if not 0, skip recursion
    
    call revealNeighbours
    
    noZero:
    ret
revealTiles endp
; END GAMELOOP PROCEDURES

showField proc
    mov ax, 0501h   ; reveal full board
    int 10h
    
    mov dx, 0
    mov bh, minefield
    mov ah, 2
    int 10h
    ret
showField endp

winExit: 
call showField

lea dx, winMessage
jmp finalExit 

loseExit:
call showField

lea dx, loseMessage 

finalExit:
mov ah, 9
int 21h

lea dx, lastMessage
mov ah, 9
int 21h

mov ah, 0
int 16h

mov ax, 3
int 10h

ret




