
org 100h

jmp setup

screenHeight equ 25
screenWidth equ 80

termVelo equ 2
accel equ 1
distBtwnPillar equ 20
height equ 24
size equ 4
gap equ 5
pillarWidth equ 4

startMsg db "Welcome to Flappy Bird!", 0Dh, 0Ah
db "Press ESC to exit at any time", 0Dh, 0Ah 
db "Press any key to start", 0Dh, 0Ah, "$"
endMsg db "Score: $"
loseFlag db 0
velo db 1
pillars db size DUP(0)
firstPillar db 80
pRNG db 0
score db 0

drawBird proc
    mov dl, 10
    mov ah, 2
    int 10h
    
    mov bl, 0Eh
    mov cx, 1
    mov al, '('
    mov ah, 09h
    int 10h
    
    inc dl
    mov ah, 2
    int 10h
    
    mov bl, 0Eh
    mov cx, 1
    mov al, ')'
    mov ah, 09h
    int 10h
    
    inc dl
    mov ah, 2
    int 10h
    
    mov bl, 0Ch
    mov cx, 1
    mov al, 169
    mov ah, 09h
    int 10h
    ret
drawBird endp

eraseBird proc
    sub dl, 2
    mov ah, 2
    int 10h
    
    mov cx, 3
    mov al, ' '
    mov ah, 0Ah
    int 10h
    
    ret
eraseBird endp

checkColl proc
    cmp dh, height
    jl noFloorHit
    mov loseFlag, 1
    mov dh, height
    
    noFloorHit:
    
    cmp dh, -2
    jg notCeiling
    
    mov dh, -2
    
    cmp firstPillar, 13
    jne notCeiling
    
    mov loseFlag, 1
    
    notCeiling:
    mov ah, 08h
    int 10h
    
    cmp al, 186
    jne notLeftTouch
    mov loseFlag, 1
    
    notLeftTouch:
    add dl, 2
    mov ah, 2
    int 10h
    
    mov ah, 08h
    int 10h
    
    cmp al, 186
    jne notPipe
    mov loseFlag, 1
    
    notPipe:
    
    cmp firstPillar, 10-pillarWidth
    jne notIncScore
    inc score
    
    notIncScore:
    
    ret
checkColl endp    

generateGap proc
    push dx 
    
    mov cx, size
    
    gapLoop:
    push cx
    
    mov ah, 2Ch
    int 21h             ; interrupt to get sys time
    
    mov bx, height-2-gap
    
    mov ah, 0
    mov al, dl
    add al, pRNG
    mov pRNG, al
    mov ah, 0
    div bl
    
    pop cx
    
    call delay
    
    mov bx, cx
    dec bx
    mov pillars[bx], ah
    
    loop gapLoop
    
    pop dx
    ret
generateGap endp

setup:
mov ax, 3
int 10h

mov ch, 32
mov ah, 1
int 10h

mov dh, height
mov dl, 0
mov ah, 2
int 10h

mov cx, screenWidth
mov al, '='
mov ah, 0Ah
int 10h 

mov dh, 11
call drawBird
call generateGap

push dx
mov dx, 0
mov ah, 2
int 10h

lea dx, startMsg
mov ah, 9
int 21h

mov ah, 00h
int 16h

mov dx, 0
mov ah, 2
int 10h

mov ah, 0Ah
mov al, ' '
mov cx, 240
mov bx, 0
int 10h

pop dx
mov ah, 2
int 10h

gameLoop:
call drawPillar
call eraseBird

add dh, velo
mov ah, 2
int 10h

call checkColl
call drawBird

cmp loseFlag, 1
je exit

call delay

mov ah, 01h
int 16h

jz contLoop

mov ah, 00h
int 16h

cmp ah, 39h     ; keycode for spacebar
jne contLoop

mov velo, -3

contLoop:

cmp velo, termVelo
jg addAccel

add velo, accel
addAccel:

jmp gameLoop

drawPillar proc
    push dx
    
    mov ch, 0
    mov dl, firstPillar
    mov cl, size
    drawMultPillar:
    push cx
    
    cmp dl, screenWidth-pillarWidth-1
    jnb skipPillar
    
    mov dh, 0
    mov cx, height
    drawVertPillar:
    push cx
    
    mov ah, 2
    int 10h   
    
    mov bl, 0Ah
    mov cx, pillarWidth
    mov al, 186
    mov ah, 09h
    int 10h
    
    add dl, pillarWidth
    mov ah, 2
    int 10h
    
    mov bl, 0Fh
    mov cx, 1
    mov al, ' '
    mov ah, 09h
    int 10h
    
    sub dl, pillarWidth
    
    inc dh
    
    pop cx
    loop drawVertPillar
    
    
    pop cx
    
    mov bx, cx
    
    mov dh, pillars[bx][-1]
    inc dh
   
    push cx
    
    mov cx, gap
    drawGap:
    push cx
    
    mov ah, 2
    int 10h
    
    mov bl, 0Fh
    mov cx, pillarWidth
    mov al, ' '
    mov ah, 09h
    int 10h
    
    inc dh
    pop cx
    loop drawGap
    
    skipPillar:
       
    add dl, distBtwnPillar
    pop cx
    loop drawMultPillar
    
    cmp firstPillar, 0
    jne notAtLeft
    
    mov dx, 0
    mov cx, height
    erasePillar:
    push cx
    
    mov ah, 2
    int 10h
    
    mov bl, 0Fh
    mov cx, pillarWidth
    mov al, ' '
    mov ah, 09h
    int 10h
    
    inc dh
    
    pop cx
    loop erasePillar
    
    add firstPillar, distBtwnPillar
    
    mov cx, size-1
    shiftQueue:
    
    mov bx, cx
    mov al, pillars[bx][-1]
    
    mov pillars[bx], al
    
    loop shiftQueue
    
    mov ah, 2Ch
    int 21h             ; interrupt to get sys time
    
    mov bx, height-gap-2
    
    mov ah, 0
    mov al, dl
    add al, pRNG
    mov pRNG, al
    mov ah, 0
    div bl
    
    mov pillars, ah
    
    notAtLeft:
    
    dec firstPillar
    pop dx
    ret
drawPillar endp

delay proc
    push dx
    push cx
    push bx
    push ax
    
    mov ah, 86h
    mov cx, 03h
    mov dx, 8000h
    int 15h
    
    pop ax
    pop bx
    pop cx
    pop dx
    ret
delay endp

printScore proc
    mov cx, 1
            
    mov ah, 0
    mov al, score
    cmp al, 0
    je printZero
    
    mov cx, 0
    
    getRadix:
    mov ah, 0
    
    inc cx
    mov bl, 10
    div bl
    
    cmp ax, 0
    ja getRadix
    
    dec cx
 
    printChar:
    mov al, score
    mov bl, 10
    
    push cx
    getDigit:
    mov ah, 0
    div bl
    loop getDigit
    pop cx
              
    printZero:
    push cx
    mov al, ah
    
    add al, '0'
    mov bl, 0Fh
    mov cx, 1
    mov ah, 09h
    int 10h
    
    inc dl
    mov ah, 2
    int 10h
    
    pop cx
    loop printChar
    
    ret
printScore endp

exit:

mov al, 2
mov bh, 0Fh
mov cx, 0
mov dh, screenHeight-1
mov dl, screenWidth-1

mov ah, 6
int 10h

mov bh, 0
mov dh, screenHeight-2
mov dl, 0

mov ah, 2
int 10h

push dx
lea dx, endMsg
mov ah, 9
int 21h
pop dx

add dl, 7
mov ah, 2
int 10h

call printScore

mov bh, 0
mov dh, screenHeight-1
mov dl, 0

mov ah, 2
int 10h

ret




