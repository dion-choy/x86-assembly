
org 100h

jmp start

left equ 4bh
right equ 4dh
up equ 48h
down equ 50h

start1 db "Welcome to Snake!", 0Dh, 0Ah
db "Press ESC to exit at any time", 0Dh, 0Ah 
db "Press any key to start", 0Dh, 0Ah, "$"
  
length db 3
direction db right
tail dw 100 dup (0FFFFh)
exitFlag db 0 

loss1 db "You Lost!", 0Dh, 0Ah
db "Your Score: "
loss2 db 0, 0, 0, 0Dh, 0Ah
db "Press ENTER to restart", 0Dh, 0Ah
db "Press any key to exit...", 0Dh, 0Ah, "$"

start:
mov cx, 0

mov ah, 0
mov al, 0
int 10h

lea dx, start1
mov ah, 9
int 21h

mov ah, 0
int 16h
 
mov ah, 0 
mov al, 0
int 10h

mov dx, 0 

call drawApple

snakeLoop:

call eraseSnake         ; erase tail
call drawSnake          ; draw head
 
;call delay             ; 500ms delay function(commented for slow emu speed)

call detectInput        ; get direction
call movCursor          ; mov cursor forward
call checkCollision     ; check hit itself/out of bounds
cmp exitFlag, 1         ; check if exit condition
je exit
ja quit

jmp snakeLoop           ; loop

delay proc
    push dx
    mov ah, 86h
    mov cx, 7h
    mov dx, 0A120h
    int 15h
    pop dx
    ret
delay endp

drawSnake proc 
    push ax
    push bx
    push cx
    
    mov al, '*'         ; set colour as "*"
    mov ah, 09h         ; write char + attribute
    mov bl, 1010b       ; attribute, light green colour
    mov cx, 1           ; print once
    int 10h             ; call interrupt to draw
    
    pop cx
    pop bx
    pop ax
    ret
drawSnake endp 


detectInput proc
    push ax
    mov ah, 1           ; get input from buffer
    int 16h    
                      
    cmp al, 1Bh         ; check if esc pressed
    jne noExit 
    mov exitFlag, 2
    noExit:
    
    cmp ah, 1           ; if key not pressed
    je noKeyPress       ; do not clear buffer

    cmp ah, up          ; else:
    je upInput
    cmp ah, down
    je downInput
    cmp ah, left
    je leftInput
    cmp ah, right
    je rightInput
    jmp invalidInput
    
    upInput:
    cmp direction, down
    jne validInput
    jmp invalidInput
    
    downInput:
    cmp direction, up
    jne validInput
    jmp invalidInput
    
    leftInput:
    cmp direction, right
    jne validInput
    jmp invalidInput
    
    rightInput:
    cmp direction, left
    jne validInput
    jmp invalidInput
    
    validInput:         ; if direction input, write
    mov direction, ah 
    
    invalidInput:
    
    mov ah, 0
    int 16h
    
    noKeyPress:
    
    pop ax
    ret
detectInput endp

movCursor proc
    push ax
    push bx
    
    mov ah, direction
    
    cmp ah, right       ; check direction
    je movR 
    cmp ah, left
    je movL
    cmp ah, up
    je movU
    cmp ah, down
    je movD 
    
    
    movR:               ; inc cursor in direction
    inc dl
    jmp endMov
    
    movL:
    dec dl
    jmp endMov
    
    movU: 
    dec dh
    jmp endMov
    
    movD:
    inc dh
    jmp endMov
    
    endMov:
     
    mov ah, 2
    int 10h             ; call interrupt to move cursor
    
    pop bx
    pop ax
    ret
movCursor endp

eraseSnake proc 
    push ax
    push dx
    push cx
    
    mov al, length      ; due to word storage,
    shl al, 1           ; multiply length by 2
    
    cmp bl, al          ; check if index at end of queue
    jne noLoopback      ; if reached,
    mov bl, 0           ; move index to 0
    
    noLoopback:         ; if not reached
    
    cmp tail[bx], 0FFFFh; check if new queue index
    je emptyIndex           ; if not new index,
    xchg dx, tail[bx]       ; write current coord to queue,
                            ; get coord of tail
    mov ah, 2            
    int 10h                 ; move cursor to coord
    
    push bx 
    
    mov al, ' '
    mov ah, 09h
    mov bl, 0111b
    mov cx, 1               ; call interrupt, erase tail
    int 10h
    
    pop bx
    
    jmp exitEraseSnake 
    
    emptyIndex:             ; if new index, add to queue
    mov tail[bx], dx
    
    exitEraseSnake:
    add bl, 2           ; increment index
    
    pop cx
    pop dx
    mov ah, 2
    int 10h
    
    pop ax 
    ret
eraseSnake endp

checkCollision proc
    push ax
    push dx
    
    mov ah, 8
    int 10h             ; call interrupt, check current char
    
    cmp al, "*"         ; if hit snake body, lose
    je collision
    
    cmp dh, 25          ; if row out of bound, lose
    jae collision
    
    cmp dl, 40          ; if col out of bound, lose
    jae collision
    jmp checkApple
     
    collision:          ; set exit flag HIGh
    mov exitFlag, 1
    jmp exitCheckCollision
       
    checkApple:
    cmp al, "@"         ; if apple eaten,
    jne exitCheckCollision
    inc length          ; increase length
    call drawApple      ; draw new apple
    
    exitCheckCollision:
    pop dx
    mov ah, 2
    int 10h
      
    pop ax
    ret
checkCollision endp

drawApple proc
    push ax
    push dx
    push cx
    push bx
    
    rerollCoord:        ; basic pseudorandom generator
    
    mov ah, 2Ch
    int 21h             ; interrupt to get sys time
    mov ax, 0
    
    mov bx, 25 
    mov al, dh
    div bl
    mov dh, ah          ; modulus so row is 0-25
    
    mov bx, 40
    mov al, dl
    div bl
    mov dl, ah          ; modulus so col is 0-40
      
    mov ah, 2
    int 10h             ; interrupt to move cursor
    
    mov ah, 8
    int 10h 
    cmp al, "*"         ; check not snake body
    je rerollCoord
          
           
    mov al, "@"         ; if no body, draw apple
    mov ah, 09h  
    mov bl, 1100b       ; attribute red colour
    mov cx, 1
    int 10h
    
    pop bx
    pop cx
    pop dx
    mov ah, 2
    int 10h
      
    pop ax 
    ret
drawApple endp  

restart:

mov length, 3           ; reset data
mov direction, right
mov exitFlag, 0

mov cx, 100 
lea di, tail
clearMemory:
mov [di], 0FFFFh
add di, 2
loop clearMemory 

mov ah, 0
mov al, 0
int 10h

jmp start

exit:
mov ah, 0
mov al, 0
int 10h

mov al, length
sub al, 3

mov bl, 100
div bl
   
add al, "0"             ; express in dec
mov loss2[0], al

mov al, ah
mov ah, 0
mov bl, 10
div bl

add al, "0"
add ah, "0"

mov loss2[1], al
mov loss2[2], ah

lea dx, loss1
mov ah, 9
int 21h

mov ah, 0
int 16h

cmp ax, 01C0Dh
je restart 

quit:
ret