
org 100h

jmp drawField

mineChar equ 162
flagChar equ 16
emptyChar equ 176
display equ 0   ; main page
minefield equ 1 ; minefield page
numOfBombs equ 50   ; <===== num of mines
numOfRevealed dw 0
pRNG db 0

winMessage db "You WIN!!", 0Dh, 0Ah, "$"
loseMessage db "You Lose", 0Dh, 0Ah, "$"             
lastMessage db "Press any key to close...", 0Dh, 0Ah, "$"

drawField:      ; draw minefield
mov ax, 3
int 10h

mov dh, 3
mov dl, 25     
mov bh, minefield     ; <=======change back to page 1 to hide
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
mov bh, minefield     ; <=======change back to page 1 to hide
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
mov bh, display     ; <=======change back to page 1 to hide
mov bl, 70h
mov cx, 16
mov al, emptyChar
call fillWithChar

jmp allowInput

; SETUP PROCEDURES
fillWithChar proc
    fillWithCharLoop:      ; draw vertical sides
    push cx
    
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
    
    mov ah, 0Ah
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
    
    mov ah, 0Ah
    mov al, "#"
    mov cx, 32
    int 10h
    ret
drawBorder endp

incSides proc
    mov cl, mineChar
    
    dec dh
    dec dl
    call check
    je noNWBomb
    call incTiles
    
    noNWBomb:
    inc dl
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

incTiles proc
    push cx
    inc al
    and ah, 0F0h
    
    cmp al, '1'
    jne above1
    or ah, 09h
    jmp colourEnd
    
    above1:
    cmp al, '2'
    jne above2
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
mov cl, 7
mov ah, 1
int 10h

mov ax, 0
int 33h

again:          ; GAMEPLAY LOOP
mov ax, 3
int 33h

push bx
mov ax, cx      ; cx, dx in subpixels
mov cl, 8       ; hence div by 8
div cl

xchg ax, dx 
div cl

mov dh, al
mov bh, display
mov ah, 2
int 10h

pop bx
cmp bl, 1
je revealTile

cmp bl, 2
je placeFlagChar

; Check if WIN condition
; i.e. numOfTiles - numOfRevealed = numOfBombs
mov ax, 480
sub ax, numOfRevealed
cmp ax, numOfBombs
je winExit

jmp again

; LEFT CLICK FUNCTION
revealTile:

mov cl, flagChar
mov bl, display
call check
je leftMouseDown

mov cl, emptyChar
mov bl, display
call check
jne leftMouseDown

call copyTile

cmp al, mineChar
je loseExit

cmp al, '0'
jne leftMouseDown
call revealZeros

leftMouseDown:
mov ax, 3
int 33h
cmp bl, 1
je leftMouseDown
jmp again

; RIGHT CLICK FUNCTION
placeFlagChar:

mov cl, flagChar
mov bl, display
call check
jne flagCharTile

mov al, emptyChar       ; empty box
mov ah, 09h  
mov bl, 70h 
mov cx, 1
int 10h

jmp rightMouseDown

flagCharTile:

mov cl, emptyChar
mov bl, display
call check
jne rightMouseDown

mov al, flagChar    ; flagChar
mov ah, 09h  
mov bl, 1100b 
mov cx, 1
int 10h

rightMouseDown:

mov ax, 3
int 33h
cmp bl, 2
je rightMouseDown
jmp again

; GAMELOOP PROCEDURES
check proc
    mov ah, 2
    int 10h
    
    mov ah, 8
    int 10h
    
    cmp al, cl
    ret
check endp

copyTile proc
    push cx
    mov bh, minefield
    mov ah, 2
    int 10h
    
    mov ah, 8
    int 10h
    mov bl, ah
    
    notZero:
    
    mov bh, display
    mov ah, 2
    int 10h
    
    mov ah, 09h
    mov bh, display
    mov cx, 1
    int 10h
    
    inc numOfRevealed
    pop cx      
    ret
copyTile endp

revealZeros proc
    dec dh
    
    mov cl, emptyChar
    mov bh, display
    call check
    jne noNZero
    
    call copyTile
    
    mov cl, '0'
    mov bh, minefield
    call check
    jne noNZero
    
    call revealZeros
    
    noNZero:
    inc dl
    mov cl, emptyChar
    mov bh, display
    call check
    jne noNEZero
    
    call copyTile
    
    mov cl, '0'
    mov bh, minefield
    call check
    jne noNEZero
    
    call revealZeros
    
    noNEZero:
    sub dl, 2
    
    mov cl, emptyChar
    mov bh, display
    call check
    jne noNWZero
    
    call copyTile
    
    mov cl, '0'
    mov bh, minefield
    call check
    jne noNWZero
    
    call revealZeros
    
    noNWZero:
    add dl, 2
    inc dh
    
    mov cl, emptyChar
    mov bh, display
    call check
    jne noEZero
    
    call copyTile
    
    mov cl, '0'     
    mov bh, minefield
    call check
    jne noEZero
    
    call revealZeros
    
    noEZero: 
    dec dl
    dec dl
    
    mov cl, emptyChar
    mov bh, display
    call check
    jne noWZero
    
    call copyTile
    
    mov cl, '0'
    mov bh, minefield
    call check
    jne noWZero
    
    call revealZeros
    
    noWZero:
    inc dl
    inc dh
    
    mov cl, emptyChar
    mov bh, display
    call check
    jne noSZero
    
    call copyTile
    
    mov cl, '0'
    mov bh, minefield
    call check
    jne noSZero
    
    call revealZeros
    
    noSZero:
    inc dl
    
    mov cl, emptyChar
    mov bh, display
    call check
    jne noSWZero
    
    call copyTile
    
    mov cl, '0'
    mov bh, minefield
    call check
    jne noSWZero
    
    call revealZeros
    
    noSWZero:
    sub dl, 2
    
    mov cl, emptyChar
    mov bh, display
    call check
    jne noSEZero
    
    call copyTile
    
    mov cl, '0'
    mov bh, minefield
    call check
    jne noSEZero
    
    call revealZeros
    
    noSEZero:
    dec dh
    inc dl
    mov ah, 2
    int 10h
    
    ret
revealZeros endp
; END GAMELOOP PROCEDURES

showField proc
    mov ax, 0501h   ; <=========to check if written
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




