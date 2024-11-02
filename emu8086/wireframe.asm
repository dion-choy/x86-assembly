
org 100h

jmp start

left equ 4bh
right equ 4dh
up equ 48h
down equ 50h

focal dw 50

angleLookup db 45, 26, 14, 7, 3, 2, 1

exitFlag db 0
color db 1110b

startXPos dw 0
startYPos dw 0

endXPos dw 0
endYPos dw 0

cursorXPos dw 0
cursorYPos dw 0

yIncDec dw 0
xIncDec dw 0

xAngle dw 0
yAngle dw 0
zAngle dw 0

pointsLen equ 16

point1 dw -80, -20, 40
point2 dw -80, -20, 80
point3 dw -80, 20, 80
point4 dw -80, 20, 40
point5 dw -40, 20, 40
point6 dw -40, 20, 80
point7 dw -40, -20, 80
point8 dw -40, -20, 40

point11 dw 50, -10, 0
point12 dw 50, -10, 20
point13 dw 50, 10, 20
point14 dw 50, 10, 0
point15 dw 30, 10, 0
point16 dw 30, 10, 20
point17 dw 30, -10, 20
point18 dw 30, -10, 0

connLen equ 24
connections dw point1, point2
    dw point1, point4
    dw point1, point8
    dw point6, point3
    dw point6, point5
    dw point6, point7
    dw point3, point2
    dw point3, point4
    dw point7, point2
    dw point7, point8
    dw point5, point4
    dw point5, point8
    
    dw point11, point12
    dw point11, point14
    dw point11, point18
    dw point16, point13
    dw point16, point15
    dw point16, point17
    dw point13, point12
    dw point13, point14
    dw point17, point12
    dw point17, point18
    dw point15, point14
    dw point15, point18

;pointsLen equ 1
;point1 dw 0,0,0
;
;connLen equ 1
;connections dw point1, point1
;
pointTranslate dw pointsLen*3 DUP(0)

start:

mov ah, 0
mov al, 13h
int 10h

call initBuffer
call initTranslateCache

drawScreen:

call drawGeometry
call pushBuffer

getInput:
call detectInput
jc drawScreen

cmp exitFlag, 1
je exit

jmp getInput

drawGeometry proc
    
    mov di, 0
    mov cx, connLen
    drawEdges:
    
    mov bx, connections[di]
    call calcProj
    mov startXPos, ax
    mov startYPos, bx
    
    add di, 2
    
    mov bx, connections[di]
    call calcProj
    mov endXPos, ax
    mov endYPos, bx
    
    add di, 2
    
    call drawLine
    
    loop drawEdges

    ret
drawGeometry endp

detectInput proc
    push ax
    push bx
    push cx
    push dx
    
    mov bx, 0
    mov cx, 0
    mov dx, 0
    
    mov ah, 1           ; get input from buffer
    int 16h    
                        ; if key not pressed
    jz noInput          ; do not clear buffer
    
    cmp al, 1Bh         ; check if esc pressed
    jne noExit 
    mov exitFlag, 1
    noExit:
    
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
    dec dx
    jmp endOfDetect
    
    zoomOut:
    inc dx
    jmp endOfDetect
    
    upInput:
    inc bx
    jmp endOfDetect
    
    downInput:
    dec bx
    jmp endOfDetect
    
    leftInput:
    dec cx
    jmp endOfDetect
    
    rightInput:
    inc cx
    jmp endOfDetect
    
    endOfDetect:
    mov ax, cx
    call changePoints       ; Calculate translation
                            ; and store in pointTranslate
    call writeTranslation   ; Write pointTranslate to position
                            ; for rotation
    call checkAngle    ; Change angle to -180 < x <= 180
    call rotateX       ; Apply rotation
    call rotateY
    call rotateZ
    
    stc
    
    invalidInput:
    
    mov ah, 0
    int 16h
    
    noInput:
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
detectInput endp

writeTranslation proc
    push si
    push di
    push ds
    push es
    
    mov ax, @data
    mov es, ax
    mov ds, ax
    
    lea di, point1
    lea si, pointTranslate
    
    mov cx, pointsLen   ; multiple pointsLen by 3
    shl cx, 1
    add cx, pointsLen
    
    rep movsw
    
    pop es
    pop ds
    pop di
    pop si
    ret
writeTranslation endp

checkAngle proc
    
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
rotateX proc        ; dx is angle to rotate
    push di
    push si
    
    mov dx, xAngle
    
    call getRotateBitMask
        
    mov cx, pointsLen
    mov di, 0

    rotateAroundX:
    
    mov ax, point1[di][4]
    mov bx, point1[di][2]
    
    call applyRotate
    
    mov point1[di][4], ax
    mov point1[di][2], bx
    
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
        
    mov cx, pointsLen
    mov di, 0

    rotateAroundY:
    
    mov ax, point1[di][4]
    mov bx, point1[di]
    
    call applyRotate
    
    mov point1[di][4], ax
    mov point1[di], bx
    
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
        
    mov cx, pointsLen
    mov di, 0

    rotateAroundZ:
    
    mov ax, point1[di]
    mov bx, point1[di][2]
    
    call applyRotate
    
    mov point1[di], ax
    mov point1[di][2], bx
    
    add di, 6
    
    loop rotateAroundZ
    
    pop si
    pop di
    ret
rotateZ endp

getRotateBitMask proc   ; dx: angle to rotate (deg)
    push ax         ; CORDIC algorithm
    push bx
    push cx
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
    pop bx
    pop ax
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
    
    xchg ax, bx ; swap ax and bx
    
    mov cx, 61  ; multiply ax by 6/10
    imul cx
    
    mov cx, 100
    idiv cx
    
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
    push di         ; dx: change in z
    
    mov cx, pointsLen
    mov di, 0
    
    changePointLoop:
    
    add pointTranslate[di], ax
    add di, 2
    
    add pointTranslate[di], bx
    add di, 2
    
    add pointTranslate[di], dx
    add di, 2
    
    loop changePointLoop
    
    pop di
    ret
changePoints endp
; ^^^^^ ===== X, Y, Z Translation Code ===== ^^^^^

; vvvvv ===== Point projection code ===== vvvvv
calcProj proc       ; Move address of point into BX
    ; Xproj = x*focal/(z+focal)
    ; Yproj = y*focal/(z+focal)
    push cx
    push dx
    
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
    
    mov ax, 09000h
    mov ds, ax
    
    mov ax, 0A000h
    mov es, ax
    
    mov si, 0
    mov di, 0
    
    mov cx, 07D00h
    rep movsw
    
    mov ax, 08000h
    mov ds, ax
    
    mov ax, 09000h
    mov es, ax
    
    mov si, 0
    mov di, 0
    
    mov cx, 07D00h
    rep movsw
    
    pop cx
    pop es
    pop ds
    pop si
    pop di
    ret
pushBuffer endp

writeToBuffer proc
    push ax
    push bx
    push dx
    
    mov ax, 09000h
    mov es, ax
    
    mov bx, dx  ; multiply dx by 320, put in bx
    shl bx, 2
    add bx, dx
    shl bx, 6
    
    add bx, cx
    
    mov al, color
    mov es:bx, al
    
    pop dx
    pop bx
    pop ax
    ret
writeToBuffer endp

initBuffer proc
    push di
    push si
    push ds
    push es
    push cx
    
    cld
    
    mov ax, 09000h
    mov es, ax
    
    mov ax, 0
    
    mov di, 0
    
    mov cx, 07D00h
    rep stosw
    
    call pushBuffer
    call pushBuffer
    
    pop cx
    pop es
    pop ds
    pop si
    pop di
    ret
initBuffer endp
; ^^^^^ ===== Single buffer code ===== ^^^^^

initTranslateCache proc
    push si
    push di
    push ds
    push es
    
    mov ax, @data
    mov es, ax
    mov ds, ax
    
    lea si, point1
    lea di, pointTranslate
    
    mov cx, pointsLen   ; multiple pointsLen by 3
    shl cx, 1
    add cx, pointsLen
    
    rep movsw
    
    pop es
    pop ds
    pop di
    pop si
    ret
initTranslateCache endp

exit:

ret