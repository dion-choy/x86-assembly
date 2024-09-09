
org 100h

jmp drawField

bomb equ 162
flag equ 16
screen1 equ 0
screen2 equ 1
numOfBombs equ 99
numOfRevealed dw 0

drawField:      ; draw minefield
mov ax, 3
int 10h

mov ch, 0
mov cl, 7
mov ah, 1
int 10h

mov dh, 3
mov dl, 25     
mov bh, screen2     ; <=======change back to page 1 to hide
mov cx, 16
drawZeros:      ; draw vertical sides
push cx

inc dh
mov ah, 2
int 10h

mov ah, 0Ah
mov al, '0'
mov cx, 30
int 10h

pop cx
loop drawZeros

; load number of mines
mov cx, numOfBombs
populateMines:
push cx

rerollCoords:

mov ah, 2Ch
int 21h             ; interrupt to get sys time
mov ax, 0

mov bh, 16
mov al, dl
div bh
mov bh, ah          ; modulus so row is 0-16
add bh, 4

call delay

mov ah, 2Ch
int 21h             ; interrupt to get sys time
mov ax, 0

mov bl, 30
mov al, dl
div bl
mov bl, ah          ; modulus so col is 0-30
add bl, 25 

mov dx, bx  
mov bh, screen2     ; <=======change back to page 1 to hide
mov ah, 2
int 10h             ; interrupt to move cursor

mov ah, 8
int 10h 
cmp al, bomb         ; check if occupied
je rerollCoords


mov al, bomb         ; if no mine, draw
mov ah, 09h  
mov bl, 0F0h       ; attribute black colour
mov cx, 1
int 10h
call incSides

pop cx
loop populateMines

mov bh, screen1
call drawBorder

mov bh, screen2
call drawBorder
jmp allowInput


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

delay proc
    push dx
    mov ah, 86h
    mov cx, 0h
    mov dx, 053h
    int 15h
    pop dx
    ret
delay endp

incSides proc
    mov cl, bomb
    
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
    mov ah, 0Ah
    mov cx, 1
    int 10h
    pop cx
    ret
incTiles endp

allowInput:     ; start user input
mov ax, 0
int 33h

again:
mov ax, 3
int 33h

push bx
mov ax, cx      ; cx, dx in subpixels
mov cl, 8       ; hence div by 8
div cl

xchg ax, dx 
div cl

mov dh, al
mov bh, screen1
mov ah, 2
int 10h

pop bx
cmp bl, 1
je revealTile

cmp bl, 2
je placeFlag

; Check if WIN condition
; i.e. numOfTiles - numOfRevealed = numOfBombs
mov ax, 480
sub ax, numOfRevealed
cmp ax, numOfBombs
je winExit

;call debugger

jmp again


;debugger proc
;    push ax
;    push bx
;    push cx
;    push dx
;    
;    mov dx, 0
;    mov bh, screen1
;    mov ah, 2
;    int 10h
;    
;    mov al, numOfRevealed     ; empty box
;    mov ah, 09h  
;    mov bl, 0Fh 
;    mov cx, 1
;    int 10h
;    
;    pop dx
;    pop cx
;    pop bx
;    pop ax
;    ret
;debugger endp

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
    mov bh, screen2
    mov ah, 2
    int 10h
    
    mov ah, 8
    int 10h
    mov bl, ah
    
    mov bh, screen1
    mov ah, 2
    int 10h
    
    mov ah, 09h
    mov bh, screen1
    mov cx, 1
    int 10h
    
    inc numOfRevealed
    pop cx      
    ret
copyTile endp

; LEFT CLICK FUNCTION
revealTile:

mov cl, flag
mov bl, screen1
call check
je leftMouseDown

mov cl, ' '
mov bl, screen1
call check
jne leftMouseDown

call copyTile

cmp al, bomb
je loseExit

cmp al, '0'
jne leftMouseDown
call delay
call revealZeros
call delay

leftMouseDown:
mov ax, 3
int 33h
cmp bl, 1
je leftMouseDown
jmp again

; RIGHT CLICK FUNCTION
placeFlag:

mov cl, flag
mov bl, screen1
call check
jne flagTile

mov al, ' '     ; empty box
mov ah, 09h  
mov bl, 0Fh 
mov cx, 1
int 10h

jmp rightMouseDown

flagTile:

mov cl, ' '
mov bl, screen1
call check
jne rightMouseDown

mov al, flag    ; flag
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

revealZeros proc
    dec dh
    
    mov cl, ' '
    mov bh, screen1
    call check
    jne noNZero
    
    call copyTile
    
    mov cl, '0'
    mov bh, screen2
    call check
    jne noNZero
    
    call revealZeros
    
    noNZero:        
    inc dl
    inc dh
    
    mov cl, ' '
    mov bh, screen1
    call check
    jne noEZero
    
    call copyTile
    
    mov cl, '0'     
    mov bh, screen2
    call check
    jne noEZero
    
    call revealZeros
    
    noEZero: 
    dec dl
    dec dl
    
    mov cl, ' '
    mov bh, screen1
    call check
    jne noWZero
    
    call copyTile
    
    mov cl, '0'
    mov bh, screen2
    call check
    jne noWZero
    
    call revealZeros
    
    noWZero:
    inc dl
    inc dh
    
    mov cl, ' '
    mov bh, screen1
    call check
    jne noSZero
    
    call copyTile
    
    mov cl, '0'
    mov bh, screen2
    call check
    jne noSZero
    
    call revealZeros
    
    noSZero:
    dec dh
    mov ah, 2
    int 10h
    
    ret
revealZeros endp

winExit:
loseExit:
mov ax, 0501h   ; <=========to check if written
int 10h

ret




