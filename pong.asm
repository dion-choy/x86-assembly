
org 100h

jmp start

leftPos db 0Ah          ; position of top of left paddle 
rightWins db 0          ; number of wins for right 

rightPos db 0Ah         ; position of top of right paddle 
leftWins db 0           ; number of wins for left

ballPos dw 0C27h        ; position of ball
oldBallPos dw 0         ; old pos of ball (to remove)
ballVeloRow db 00h      ; horizontal velocity of ball
ballVeloCol db 00h      ; veritcal velocity of ball

resetFlag db 0

rightUp equ 48h         ; BIOS scan for up key
rightDown equ 50h       ; BIOS scan for down key

leftUp equ 11h          ; BIOS scan for w key
leftDown equ 1Fh        ; BIOS scan for s key


startMessage db "Welcome to Pong!", 0Dh, 0Ah 
db "Press UP and DOWN to move right paddle", 0Dh, 0Ah  
db "Press W and S to move left paddle", 0Dh, 0Ah, 0Dh, 0Ah 
db "Press ESC to exit at any time", 0Dh, 0Ah 
db "Press any key to start", 0Dh, 0Ah, "$"

end1 db "Right wins1", 0Dh, 0Ah, "$"
end2 db "Left wins1", 0Dh, 0Ah, "$"             
end3 db "Press any key to close...", 0Dh, 0Ah, "$"

start:   
lea dx, startMessage
mov ah, 9
int 21h   

mov ah, 0
int 16h
   
mov ah, 0
mov al, 3
int 10h

startGame:
mov al, " "

mov dl, 0               ; pass position of left paddle
mov dh, leftPos
call drawInitial        ; draw initial left paddle

mov dl, 4Fh             ; pass position of right paddle
mov dh, rightPos
call drawInitial        ; draw initial left paddle
jmp resetBall:

again:
call drawBall           ; draw ball

mov cx, 2
detectInputs:
push cx
mov ah, 1
int 16h
jz noInput              ; check for input

push ax
mov ah, 0
int 16h                 ; remove from key buffer
pop ax  

cmp al, 1Bh         ; check if esc pressed
je escape

cmp ah, leftUp          ; detecting inputs
je leftUpInput          ;
cmp ah, leftDown        ;
je leftDownInput        ;
                        ;
                        ;
cmp ah, rightUp         ;
je rightUpInput         ;
cmp ah, rightDown       ;
je rightDownInput       ; detecting inputs
detectInputsRet:
pop cx
loop detectInputs
jmp inputFinished

noInput:                ; if no input, move ball
pop cx                  ; remove stack

inputFinished:
call moveBall           

call delay     ; delay 500ms (commented due to slow emu)

cmp resetFlag, 1
je resetBall
 
jmp again


delay proc
    push dx
    mov ah, 86h
    mov cx, 1h
    mov dx, 86D2h
    int 15h
    pop dx
    ret
delay endp

resetBall:
mov ballVeloRow, 3      ; reset velocity
mov ballVeloCol, 0      
mov ballPos, 0C27h      ; reset position

push ax
mov dx, 0001h
mov ah, 2
int 10h
mov al, leftWins
mov resetFlag, 1        ; if game end and flag = 1, left wins
cmp al, 10              ; if score==10 end game
je end

add al, "0"             ; print left score
mov cx, 1
mov ah, 0Ah
int 10h

mov dx, 004Eh
mov ah, 2
int 10h
mov al, rightWins
mov resetFlag, 2        ; if game end and flag = 2, right wins
cmp al, 10              ; if score==10 end game
je end

add al, "0"             ; print right score
mov ah, 0Ah
int 10h 
pop ax

mov resetFlag, 0
jmp again
          
leftUpInput:
cmp leftPos, 0          ; check if out of bounds
je noInput
dec leftPos             ; move left paddle up
jmp leftInput

leftDownInput:
cmp leftPos, 14h        ; check if out of bounds
je noInput
inc leftPos             ; move left paddle down
jmp leftInput

leftInput:
mov dl, 0
mov dh, leftPos
call drawPaddle         ; if paddle moved, draw left paddle

jmp detectInputsRet

rightUpInput:
cmp rightPos, 0         ; check if out of bounds
je noInput
dec rightPos            ; move right paddle up
jmp rightInput

rightDownInput:
cmp rightPos, 14h       ; check if out of bounds
je noInput
inc rightPos            ; move right paddle up
jmp rightInput

rightInput:
mov dl, 4Fh
mov dh, rightPos
call drawPaddle         ; if paddle moved, draw right paddle

jmp detectInputsRet

moveBall proc
    mov dx, ballPos
    mov oldBallPos, dx
    add dh, ballVeloCol
    
    cmp dh, 18h
    jna notAtTopBottom
    call topBottomColl      ; check for collision
    
    notAtTopBottom:
    add dl, ballVeloRow
    
    cmp dl, 4Fh
    jae atSides  
       
    cmp dl, 0
    je atSides
    jmp notAtSide
    
    atSides:
    call leftRightColl      ; check for collision
    
    notAtSide:
       
    mov ballPos, dx
    
    ret
moveBall endp

leftRightColl proc          ; Side collision detection
    neg ballVeloRow
    
    push bx
    push cx
    mov bh, 0
    sub bh, dl
    
    mov bl, dl
    sub bl, 4Fh
    cmp bh, bl              ; determine which side was hit
    jb closerToLeft
                        ; if closer to right
    mov dl, 4Eh         ; load col of paddle
    lea bx, rightPos    ; load pointer
    jmp closerDetermined
    
    closerToLeft:       ; if closer to left
    
    mov dl, 1           ; load col of paddle
    lea bx, leftPos     ; load pointer
    
    closerDetermined:
    cmp [bx], dh              ; determine if paddle hit
    ja noHit
    
    mov cl, [bx]        ; if within top and bottom, hit
    add cl, 4
    cmp cl, dh
    jb noHit
    
    sub cl, 2           ; when hit, flip horizontal velo
    push dx
    sub dh, cl
    add ballVeloCol, dh ; change vertical velo from location hit
    pop dx
    
    jmp hit
    
    noHit:              ; winFlag for opp on next byte
    inc [bx]1           ; can inc next byte for convenience
    inc resetFlag
    
    hit:
    
    pop cx
    pop bx
    ret
leftRightColl endp

topBottomColl proc          ; Top & bottom collision detection
    neg ballVeloCol         ; flip veritcal velocity
    add dh, ballVeloCol
    ret
topBottomColl endp

drawInitial proc
    push bx
    push cx
    push dx
    
    mov cx, 5               ; draw paddle of height 5
    mov bl, 0FFh
    drawInitialPaddle:
    push cx
    mov ah, 2
    int 10h
    
    mov cx, 1
    mov ah, 9
    int 10h
    inc dh
    pop cx
    loop drawInitialPaddle
    
    pop dx
    pop cx
    pop bx
    ret
drawInitial endp 

drawPaddle proc         ; draw paddle moving up/down
    push bx             ; erase old tips
    push cx
    push dx
    
    mov cx, 5
    mov ah, 2
    int 10h
    
    mov al, 0h          ; No character
    mov bl, 0FFh        ; White color
    mov cx, 1
    mov ah, 9
    int 10h
       
    add dh, 4
    mov ah, 2
    int 10h
    mov ah, 9
    int 10h
    
    mov bl, 0
     
    inc dh
    mov ah, 2
    int 10h
    mov ah, 9
    int 10h
    
    sub dh, 6
    mov ah, 2
    int 10h  
    mov ah, 9
    int 10h
      
    
    pop dx
    pop cx
    pop bx
    ret
drawPaddle endp

drawBall proc           ; draw new ball pos, erase old
    push bx
    push cx
    push dx
    
    mov dx, ballPos
    mov ah, 2
    
    int 10h
    
    mov bl, 0EEh
    mov cx, 1
    mov ah, 9
    int 10h
    
    mov dx, oldBallPos
    mov ah, 2
    int 10h
    
    mov bl, 0
    mov ah, 9
    int 10h
    
    pop dx
    pop cx
    pop bx
    ret
drawBall endp


end:        ; normal ending

mov ah, 0   
mov al, 3
int 10h

mov dx, 1
mov ah, 2
int 10h

cmp resetFlag, 1
je leftWinMessage

lea dx, end1
mov ah, 9
int 21h
jmp finalMessage  

leftWinMessage:
lea dx, end2
mov ah, 9
int 21h

finalMessage:
mov dx, 101h
mov ah, 2
int 10h

lea dx, end3
mov ah, 9
int 21h

mov ah, 0
int 16h

escape:     ; return if escape pressed
pop ax      ; pop so stack clear for ret
ret