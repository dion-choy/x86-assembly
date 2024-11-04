
org 100h

jmp start

left equ 4bh
right equ 4dh
up equ 48h
down equ 50h

focal dw 50

; angle lookup for CORDIC algorithm
angleLookup db 45, 26, 14, 7, 3, 2, 1

exitFlag db 0
color db 1110b

; vvvv variables for line drawing
startXPos dw 0
startYPos dw 0

endXPos dw 0
endYPos dw 0

cursorXPos dw 0
cursorYPos dw 0

yIncDec dw 0
xIncDec dw 0
; ^^^^ variables for line drawing

xTrans dw 0
yTrans dw 0
zTrans dw 0

xAngle dw 0
yAngle dw 0
zAngle dw 0

objLen dw 3
objects dw object1, object2, object3

object1 dw 8    ; number of points
    dw 1110b    ; color
    
    dw -80, -20, 40
    dw -80, -20, 80
    dw -80, 20, 80
    dw -80, 20, 40
    dw -40, 20, 40
    dw -40, 20, 80
    dw -40, -20, 80
    dw -40, -20, 40
    
    dw 12   ; number of connections
    
    dw 1, 2
    dw 1, 4
    dw 1, 8
    dw 6, 3
    dw 6, 5
    dw 6, 7
    dw 3, 2
    dw 3, 4
    dw 7, 2
    dw 7, 8
    dw 5, 4
    dw 5, 8
obj1Init dw 30*3 DUP(0)
    
object2 dw 8    ; number of points
    dw 1110b    ; color
    
    dw 50, -10, 0
    dw 50, -10, 20
    dw 50, 10, 20
    dw 50, 10, 0
    dw 30, 10, 0
    dw 30, 10, 20
    dw 30, -10, 20
    dw 30, -10, 0

    dw 12   ; number of connections
    
    dw 1, 2
    dw 1, 4
    dw 1, 8
    dw 6, 3
    dw 6, 5
    dw 6, 7
    dw 3, 2
    dw 3, 4
    dw 7, 2
    dw 7, 8
    dw 5, 4
    dw 5, 8
obj2Init dw 30*3 DUP(0)
    
object3 dw 6
    dw 1111h
    dw -5, 0, 0       ; Origin point
    dw 5, 0, 0
    dw 0, -5, 0
    dw 0, 5, 0
    dw 0, 0, -5
    dw 0, 0, 5
    
    dw 3
    
    dw 1, 2
    dw 3, 4
    dw 5, 6
obj3Init dw 30*3 DUP(0)    

start:
    
mov ax, @data
mov es, ax
mov ds, ax

mov ah, 0
mov al, 13h
int 10h

lea di, objects
mov cx, objLen
storeObj:

mov si, [di]
call storeInitialPoints
add di, 2

loop storeObj

drawScreen:

lea di, objects
mov cx, objLen
drawObj:
push cx

mov si, [di]
mov cx, [si][2]
mov color, cl
call drawGeometry
add di, 2

pop cx
loop drawObj

call pushBuffer

getInput:
call detectInput
jc drawScreen

cmp exitFlag, 1
je exit

jmp getInput

objEdgePtToAddr proc    ; di: address of connection point
    mov bx, [di]        ; si: address of 1st obj point
    shl bx, 1   ; Multiply bx by 3
    add bx, [di]
    sub bx, 3   ; sub by 3 for 1-based indexing of points
    shl bx, 1   ; Multiply by 2(bytes)
    add bx, si
    
    ret                 ; bx: address of point to project
objEdgePtToAddr endp

drawGeometry proc   ; load address of object into si
    push di
    
    mov di, [si]    ; multiply length of object by 6
    shl di, 1       ; since (x,y,z) => 3(words)*2(bytes)
    add di, [si]
    shl di, 1
    
    add si, 4
    add di, si
    mov cx, [di]
    add di, 2
    
    drawEdges:
    
    call objEdgePtToAddr
    call calcProj
    mov startXPos, ax
    mov startYPos, bx
    
    add di, 2
    
    call objEdgePtToAddr
    call calcProj
    mov endXPos, ax
    mov endYPos, bx
    
    add di, 2
    
    call drawLine
    
    loop drawEdges
    
    pop di
    ret
drawGeometry endp

applyTrans proc
    
    call checkAngle     ; Change angle to -180 < x <= 180
    
    lea si, objects
    mov cx, objLen
    applyTransform:
    push cx
    
    mov di, [si]
    call writeInitial   ; Write initalPoints to position
                        ; for rotation
    call rotateX        ; Apply rotation
    call rotateY
    call rotateZ
    
    call changePoints   ; Calculate translation
                        ; and store in initalPoints    
    pop cx
    add si, 2
    loop applyTransform
    
    ret
applyTrans endp

detectInput proc
    
    mov bx, 0
    mov cx, 0
    mov dx, 0
    
    clc
    
    mov ah, 1           ; get input from buffer
    int 16h    
                        ; if key not pressed
    jz noInput          ; do not clear buffer
    
    cmp al, 1Bh         ; check if esc pressed
    jne noExit 
    mov exitFlag, 1
    noExit:
    
    cmp al, 'r'
    jne noReset
    mov xTrans, 0
    mov yTrans, 0
    mov zTrans, 0
    mov xAngle, 0
    mov yAngle, 0
    mov zAngle, 0
    jmp endOfDetect
    noReset:
    
    cmp al, 'q'
    jne noDecZAngle
    add zAngle, 5
    jmp endOfDetect
    noDecZAngle:
    
    cmp al, 'e'
    jne noIncZAngle
    sub zAngle, 5
    jmp endOfDetect
    noIncZAngle:
    
    cmp al, 'w'
    jne noDecXAngle
    add xAngle, 5
    jmp endOfDetect
    noDecXAngle:
    
    cmp al, 's'
    jne noIncXAngle
    sub xAngle, 5
    jmp endOfDetect
    noIncXAngle:
    
    cmp al, 'a'
    jne noDecYAngle
    sub yAngle, 5
    jmp endOfDetect
    noDecYAngle:
    
    cmp al, 'd'
    jne noIncYAngle
    add yAngle, 5
    jmp endOfDetect
    noIncYAngle:
    
    cmp al, 'i'
    je zoomIn
    cmp al, 'o'
    je zoomOut
    cmp ah, up
    je upInput
    cmp ah, down
    je downInput
    cmp ah, left
    je leftInput
    cmp ah, right
    je rightInput
    jmp invalidInput
    
    zoomIn:
    dec zTrans
    jmp endOfDetect
    
    zoomOut:
    inc zTrans
    jmp endOfDetect
    
    upInput:
    inc yTrans
    jmp endOfDetect
    
    downInput:
    dec yTrans
    jmp endOfDetect
    
    leftInput:
    dec xTrans
    jmp endOfDetect
    
    rightInput:
    inc xTrans
    jmp endOfDetect
    
    endOfDetect:
    
    call applyTrans
    
    stc
    
    invalidInput:
    
    mov ah, 0
    int 16h
    
    noInput:
    
    ret
detectInput endp

writeInitial proc   ; di is input of object to copy points
    push si
    push di
    
    mov cx, [di]    ; multiply length of object by 3
    shl cx, 1       ; since (x,y,z) => 3 words
    add cx, [di]
    
    push cx
    shl cx, 1
    mov si, cx
    pop cx
    
    add di, 4
    
    add si, di
    mov ax, [si]
    shl ax, 2   ; multiply ax by 4
    add si, ax
    add si, 2
    
    rep movsw
    
    pop di
    pop si
    ret
writeInitial endp

checkAngle proc     ; Change change to range -180 <= x <= 180
    cmp xAngle, 180
    jl xBelow180
    sub xAngle, 360
    xBelow180:
    
    cmp xAngle, -180
    jg xAbove180
    add xAngle, 360
    xAbove180:
    
    cmp yAngle, 180
    jl yBelow180
    sub yAngle, 360
    yBelow180:
    
    cmp yAngle, -180
    jg yAbove180
    add yAngle, 360
    yAbove180:
    
    cmp zAngle, 180
    jl zBelow180
    sub zAngle, 360
    zBelow180:
    
    cmp zAngle, -180
    jg zAbove180
    add zAngle, 360
    zAbove180:
    
    ret
checkAngle endp

; vvvvv ===== Axis Rotation Code ===== vvvvv
rotateX proc    ; dx is angle to rotate
    push di     ; di is address of obj to rotate
    push si
    
    mov dx, xAngle
    
    call getRotateBitMask
        
    mov cx, [di]
    add di, 4

    rotateAroundX:
    
    mov ax, [di][4]
    mov bx, [di][2]
    
    call applyRotate
    
    mov [di][4], ax
    mov [di][2], bx
    
    add di, 6
    
    loop rotateAroundX
    
    pop si
    pop di
    ret
rotateX endp

rotateY proc        ; dx is angle to rotate
    push di
    push si
    
    mov dx, yAngle
    
    call getRotateBitMask
        
    mov cx, [di]
    add di, 4

    rotateAroundY:
    
    mov ax, [di][4]
    mov bx, [di]
    
    call applyRotate
    
    mov [di][4], ax
    mov [di], bx
    
    add di, 6
    
    loop rotateAroundY
    
    pop si
    pop di
    ret
rotateY endp

rotateZ proc        ; dx is angle to rotate
    push di
    push si
    
    mov dx, zAngle
    
    call getRotateBitMask
        
    mov cx, [di]
    add di, 4

    rotateAroundZ:
    
    mov ax, [di]
    mov bx, [di][2]
    
    call applyRotate
    
    mov [di], ax
    mov [di][2], bx
    
    add di, 6
    
    loop rotateAroundZ
    
    pop si
    pop di
    ret
rotateZ endp

getRotateBitMask proc   ; dx: angle to rotate (deg)
    push cx         ; CORDIC algorithm
    push dx
    push di
    
    cmp dx, 0
    jg noAngleChange
    
    neg dx
    
    noAngleChange:
    
    cmp dx, 90
    jbe smallerThan90
    
    sub dx, 180
    neg dx
    
    smallerThan90:
    
    mov di, 1
    mov ax, 0   ; bitmask of add/sub angle
    mov bx, 0   ; if bit high then sub, else add
    mov cx, 0
    
    add bx, 45
    
    findBitmask:
    
    cmp bx, dx
    jl addAngle
    mov cl, angleLookup[di]
    shl cl, 1
    sub bx, cx
    or al, 80h
    addAngle:
    add bl, angleLookup[di]
    adc bh, 0
    shr al, 1
    
    inc di
    cmp di, 7
    jnz findBitmask
    
    mov si, ax
    
    pop di
    pop dx
    pop cx
    ret
getRotateBitMask endp

applyRotate proc    ; ax: first coord, bx: second coord
    push di
    push si
    push cx
    push dx
    
    cmp dx, 0
    jge noYFlip
    
    neg dx
    neg bx
    
    noYFlip:
    
    cmp dx, 90
    jbe noXFlip
    
    neg ax
    
    noXFlip:
    
    cmp dx, 0
    je noRevertXFlip
          
    mov cl, 0
    
    translateVector:    ; ax: xn, bx:yn
    mov dx, ax
    sar dx, cl      ; dx: xn*(-2)^n
    
    test si, 1
    jz posAngle1    ; check if angle is +/-
    neg dx
    
    posAngle1:
    
    push dx         ; push to stack
    
    mov dx, bx
    sar dx, cl      ; dx: yn*(-2)^n

    test si, 1
    jz posAngle2    ; check if angle is +/-
    neg dx
    
    posAngle2:
    
    sub ax, dx      ; ax: x(n+1) i.e. xn-yn*(-2)^n
    
    pop dx
    
    add bx, dx      ; bx: y(n+1) i.e. yn+xn*(-2)^n
    
    shr si, 1
    inc cl
    cmp cl, 7
    jne translateVector
    
    mov cx, 61   ; multiply ax by 6/10
    imul cx
    
    mov cx, 100
    idiv cx
    
    cmp dx, 100
    jl noCarryAx
    
    inc ax
    
    noCarryAx:
    
    xchg ax, bx ; swap ax and bx
    
    mov cx, 61  ; multiply ax by 6/10
    imul cx
    
    mov cx, 100
    idiv cx
    
    cmp dx, 100
    jl noCarryBx
    
    inc ax
    
    noCarryBx:
    
    xchg ax, bx
    
    pop dx
    push dx
    
    cmp dx, 0
    jge noRevertYFlip
    
    neg bx
    neg dx
    
    noRevertYFlip:
    
    cmp dx, 90
    jbe noRevertXFlip
    
    neg bx
    
    noRevertXFlip:
    
    pop dx
    pop cx
    pop si
    pop di
    ret
applyRotate endp
; ^^^^^ ===== Axis Rotation Code ===== ^^^^^

; vvvvv ===== Translation Code ===== vvvvv
changePoints proc   ; ax: change in x, bx: change in y
    push di         ; dx: change in z, di: object to translate
    
    mov cx, [di]
    add di, 4
    
    changePointLoop:
    push cx
    
    mov cx, xTrans
    add [di], cx
    add di, 2
        
    mov cx, yTrans
    add [di], cx
    add di, 2
        
    mov cx, zTrans
    add [di], cx
    add di, 2
    
    pop cx
    loop changePointLoop
    
    pop di
    ret
changePoints endp
; ^^^^^ ===== Translation Code ===== ^^^^^

; vvvvv ===== Point projection code ===== vvvvv
calcProj proc       ; Move address of point into BX
    push cx     ; Xproj = x*focal/(z+focal)
    push dx     ; Yproj = y*focal/(z+focal)
    
    mov ax, [bx][0]     ; x-coord of point
    mov dx, [bx][1*2]     ; y-coord of point
    mov cx, [bx][2*2]     ; z-coord of point
    
    add cx, focal
    jns inFrontOfCam
    
    mov cx, 4
    
    inFrontOfCam:
    
    cmp cx, 0
    jg noDivideError
    
    mov cx, 1
    
    noDivideError:
    
    push dx
    
    mov bx, focal
    imul bx
    idiv cx
    
    pop dx
    push ax
    
    mov ax, focal
    imul dx
    idiv cx
    
    mov bx, ax
    pop ax
    
    pop cx
    pop dx
    ret         ; return x-coord at AX
calcProj endp   ; return y-coord at BX
; ^^^^^ ===== Point projection code ===== ^^^^^

; vvvvv ===== Line drawing code ===== vvvvv
drawLine proc       ; Bresenham's line algorithm 
    push ax
    push bx
    push cx
    push dx
    
    mov xIncDec, 1
    mov yIncDec, 1
    
    push ax
    
    mov ax, startXPos
    mov cursorXPos, ax
    
    mov ax, startYPos
    mov cursorYPos, ax
    
    pop ax

    mov cx, endXPos     ; cx: deltaX
    sub cx, startXPos
    
    cmp cx, 0
    jge doNotInvertX
    
    sub xIncDec, 2
    neg cx
    
    doNotInvertX:
    
    
    mov ax, endYPos     ; ax: deltaY
    sub ax, startYPos   
    
    cmp ax, 0
    jge doNotInvertY
    
    sub yIncDec, 2
    neg ax
    
    doNotInvertY:
    
    neg ax
    
    mov bx, ax          ; bx: error
    add bx, cx
    
    
    drawNextPx:
    
    call drawPx
    
    
    mov dx, endXPos
    cmp cursorXPos, dx
    jne lineNotFinished
    
    mov dx, endYPos
    cmp cursorYPos, dx
    jne lineNotFinished
    
    jmp endLine
    
    lineNotFinished:
    
    mov dx, bx
    shl dx, 1
    
    cmp dx, ax
    jl noXChange
    
    add bx, ax
    push dx
    mov dx, xIncDec
    add cursorXPos, dx
    pop dx
    noXChange:
    
    cmp dx, cx
    jg noYChange
    
    add bx, cx
    push dx
    mov dx, yIncDec
    add cursorYPos, dx
    pop dx
    noYChange:
    
    jmp drawNextPx
    
    endLine:
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
drawLine endp

drawPx proc
    push ax
    push cx
    push dx
    
    mov cx, cursorXPos
    add cx, 160
    
    mov dx, cursorYPos
    neg dx
    add dx, 100
    
    cmp cx, 320
    jae skipPx
    
    cmp dx, 200
    jae skipPx
    
    mov al, color
    call writeToBuffer
    
    skipPx:
    
    pop dx
    pop cx
    pop ax   
    ret
drawPx endp
; ^^^^^ ===== Line drawing code ===== ^^^^^

; vvvvv ===== Single buffer code ===== vvvvv
pushBuffer proc
    push di
    push si
    push ds
    push es
    push cx
    
    cld
    
    ; Push buffer
    mov ax, 09000h
    mov ds, ax
    
    mov ax, 0A000h
    mov es, ax
    
    mov si, 0
    mov di, 0
    
    mov cx, 07D00h
    rep movsw
    
    ; Clear buffer
    mov ax, 09000h
    mov es, ax
    
    mov ax, 0
    
    mov di, 0
    
    mov cx, 07D00h
    rep stosw
    
    pop cx
    pop es
    pop ds
    pop si
    pop di
    ret
pushBuffer endp

writeToBuffer proc
    push bx
    push dx
    push es
    push ax
    
    mov ax, 09000h
    mov es, ax
    
    mov bx, dx  ; multiply dx by 320, put in bx
    shl bx, 2
    add bx, dx
    shl bx, 6
    
    add bx, cx
    
    pop ax
    mov es:bx, al
    
    pop es
    pop dx
    pop bx
    ret
writeToBuffer endp
; ^^^^^ ===== Single buffer code ===== ^^^^^

storeInitialPoints proc     ; si: address of object as input
    push di
    push cx
    
    mov cx, [si]    ; multiply length of object by 3
    shl cx, 1       ; since (x,y,z) => 3 words
    add cx, [si]
    
    push cx
    shl cx, 1
    mov di, cx
    pop cx
    
    add si, 4
    
    add di, si
    mov ax, [di]
    shl ax, 2   ; multiply ax by 4
    add di, ax
    add di, 2
    
    rep movsw
    
    pop cx
    pop di
    ret
storeInitialPoints endp

exit:

ret