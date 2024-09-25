
org 100h

jmp setup

termVelo equ 2
accel equ 1
distBtwnPillar equ 20
height equ 24
size equ 4
gap equ 5

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
    
    cmp firstPillar, 7
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

mov cx, 80
mov al, '='
mov ah, 0Ah
int 10h 

mov dh, 11
call drawBird
call generateGap

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

mov ah, 01h
int 16h

jz contLoop

mov ah, 00h
int 16h

cmp ah, 39h ; keycode for spacebar
jne contLoop

mov velo, -3

contLoop:

cmp velo, termVelo
jg addAccel

add velo, accel
addAccel:

call delay

jmp gameLoop

drawPillar proc
    push dx
    
    mov ch, 0
    mov dl, firstPillar
    mov cl, size
    drawMultPillar:
    push cx
    
    cmp dl, 78
    jnb skipPillar
    
    mov dh, 0
    mov cx, height
    drawVertPillar:
    push cx
    
    mov ah, 2
    int 10h   
    
    mov bl, 0Ah
    mov cx, 3
    mov al, 186
    mov ah, 09h
    int 10h
    
    add dl, 3
    mov ah, 2
    int 10h
    
    mov bl, 0Fh
    mov cx, 1
    mov al, ' '
    mov ah, 09h
    int 10h
    
    sub dl, 3
    
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
    mov cx, 3
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
    mov cx, 3
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
    mov dx, 86D2h
    int 15h
    
    pop ax
    pop bx
    pop cx
    pop dx
    ret
delay endp

exit:

ret




