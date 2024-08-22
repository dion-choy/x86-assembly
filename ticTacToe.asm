
org 100h
 
jmp enter

player db 1                     ; 0: "O", 1: "X"
grid db 0,0,0, 0,0,0, 0,0,0     ; 3x3 matrix, 1: "O", 2: "X"    
row db 0                        ; 0 indexing
col db 0                        ; 0 indexing
win1 db "Player '"
win2 db 0, "' wins!$"
tie1 db "Tie!$"

enter: 

mov ah, 0
int 10h
     
mov ax, 1
int 33h  

drawGrid:
mov dl, 0
mov dh, 8

mov ah, 2
int 10h 

mov al, '#'         
mov ah, 09h         
mov bl, 0111b       
mov cx, 40           
int 10h
        
mov dl, 0
mov dh, 17

mov ah, 2
int 10h 

mov al, '#'         
mov ah, 09h         
mov bl, 0111b       
mov cx, 40           
int 10h 
          
mov dl, 13
mov dh, 0 
mov cx, 40

mov dl, 13
mov dh, 0 
mov cx, 25 
call drawCol

mov dl, 27
mov dh, 0 
mov cx, 25 
call drawCol 
  
again:
mov ax, 3
int 33h 

cmp bl, 1 
je btnClick
jmp again
          
btnClick:
call findGrid   
mov ax, 0
call checkFilled
cmp ax, 1
je again 

cmp player, 0
je playerO
jmp playerX

checkWin:
mov ax, 0 

call rowWin             
cmp ax, 1
je exit:

call colWin 
cmp ax, 1
je exit:

call diagWin
cmp ax, 1
je exit:

call checkTie
cmp ax, 2
je tieExit:

jmp again 

rowWin proc
    push bx
    
    mov bx, 0
     
    rowWinLoop: 
    
    mov al, grid[bx]
    cmp al, 0
    je restartRowWinLoop
    
    cmp al, grid[bx+1]
    jne restartRowWinLoop                
    
    
    cmp al, grid[bx+2]
    jne restartRowWinLoop
    
    mov ax, 1
    jmp exitRowWin
                     
    restartRowWinLoop:
    mov ax, 0
    add bx, 3 
    cmp bx, 9
    jne rowWinLoop
    
    exitRowWin:
    pop bx    
    ret
rowWin endp

colWin proc
    push bx
    
    mov bx, 0
     
    colWinLoop: 
    
    mov al, grid[bx]
    cmp al, 0
    je restartColWinLoop
    
    cmp al, grid[bx+3]
    jne restartColWinLoop                
    
    
    cmp al, grid[bx+6]
    jne restartColWinLoop
    
    mov ax, 1
    jmp exitColWin
                     
    restartColWinLoop:
    mov ax, 0
    add bx, 1 
    cmp bx, 3
    jne colWinLoop
    
    exitColWin:
    pop bx  
    
    ret
colWin endp  

diagWin proc 
    push bx
    
    mov bx, 4
    
    mov al, grid[bx]
    cmp al, 0
    je noDiagWin
    
    mov bx, 0 
    cmp al, grid[bx] 
    jne checkOtherDiag 
    
    mov bx, 8
    cmp al, grid[bx] 
    jne checkOtherDiag
    mov ax, 1
    jmp exitDiagWin 
    
    checkOtherDiag:
    mov bx, 2
    cmp al, grid[bx] 
    jne noDiagWin 
    
    mov bx, 6
    cmp al, grid[bx] 
    jne noDiagWin
    
    mov ax, 1
    jmp exitDiagWin 
     
    noDiagWin:
    mov ax, 0        
    
    exitDiagWin:
    pop bx
         
    ret
diagWin endp    
 
checkTie proc
    push bx
    mov bx, 9
    
    checkTieLoop:    
    dec bx 
    cmp grid[bx], 0
    je noTie
    
    cmp bx, 0
    jne checkTieLoop
    mov ax, 2
    
    noTie:
    pop bx
    ret
checkTie endp    


playerO:
call loadIndex
mov grid[bx], 1
     
call drawO

mov player, 1
jmp checkWin
         
playerX:      
call loadIndex
mov grid[bx], 2

call drawX

mov player, 0
jmp checkWin 


drawO proc
    call moveToCorner
             
    add dh, 1
    add dl, 3
    
    mov ah, 2
    int 10h
    
    mov ah, 0Ah 
    mov al, "O"
    mov cx, 3
    int 10h 
    
    add dh, 1
    add dl, 3
    
    mov ah, 2
    int 10h
    
    mov ah, 0Ah 
    mov al, "O"
    mov cx, 1
    int 10h
    
    add dh, 1
    add dl, 1
    
    mov ah, 2
    int 10h
    
    mov ah, 0Ah 
    mov al, "O"
    mov cx, 1
    int 10h 
    
    
    add dh, 1
    
    mov ah, 2
    int 10h
    
    mov ah, 0Ah 
    mov al, "O"
    mov cx, 1
    int 10h
            
    add dh, 1
    sub dl, 1
    
    mov ah, 2
    int 10h
    
    mov ah, 0Ah 
    mov al, "O"
    mov cx, 1
    int 10h 
    
    sub dl, 3
    add dh, 1
    
    mov ah, 2
    int 10h
    
    mov ah, 0Ah 
    mov al, "O"
    mov cx, 3
    int 10h
    
    sub dh, 1
    sub dl, 1
    
    mov ah, 2
    int 10h
    
    mov ah, 0Ah 
    mov al, "O"
    mov cx, 1
    int 10h 
    
    sub dh, 1
    sub dl, 1
    
    mov ah, 2
    int 10h
    
    mov ah, 0Ah 
    mov al, "O"
    mov cx, 1
    int 10h 
    
    sub dh, 1
    
    mov ah, 2
    int 10h
    
    mov ah, 0Ah 
    mov al, "O"
    mov cx, 1
    int 10h 
    
    sub dh, 1
    add dl, 1
    
    mov ah, 2
    int 10h
    
    mov ah, 0Ah 
    mov al, "O"
    mov cx, 1
    int 10h
    
    ret
drawO endp

drawX proc
    call moveToCorner
    
    mov cx, 6
    drawXLoop1:
    push cx
    
    inc dh
    inc dl
    
    mov ah, 2
    int 10h
    
    mov ah, 0Ah 
    mov al, "X"
    mov cx, 2
    int 10h
     
    pop cx         
    loop drawXLoop1 
    
    sub dl, 6
    inc dh
    
    mov cx, 6
    drawXLoop2:
    push cx
    
    dec dh
    inc dl
    
    mov ah, 2
    int 10h
    
    mov ah, 0Ah 
    mov al, "X"
    mov cx, 2
    int 10h
     
    pop cx         
    loop drawXLoop2
    
    ret
drawX endp 

moveToCorner proc
    mov al, row
    mov bl, 9
    mul bl
    
    mov dh, al 
    
    mov al, col
    mov bl, 14
    mul bl
    add al, 2          
    
    mov dl, al 
    
    mov ah, 2
    int 10h         ; move cursor to corner of grid
    
    ret
moveToCorner endp    


checkFilled proc
    call loadIndex
    cmp grid[bx], 0
    je unfilledGrid
    
    mov ax, 1
    
    unfilledGrid:
    
    ret
checkFilled endp 

loadIndex proc  
    push ax
    
    mov ch, row
    mov cl, col
               
    mov al, 3
    mul ch
    
    mov bx, ax
    add bl, cl
    
    pop ax
    ret
loadIndex endp

findGrid proc 
    push ax
    
    ; find col
    mov ax, cx
    mov cl, 8
    div cl
    
    cmp al, 13
    ja notCol1    
    mov col, 0       
    jmp findColEnd 
    
    notCol1:
    cmp al, 27
    ja col3    
    mov col, 1       
    jmp findColEnd
    
    col3: 
    mov col, 2
      
    findColEnd:
    
    ; find row
    mov ax, dx
    mov cl, 8
    div cl
    
    cmp al, 8
    ja notRow1    
    mov row, 0      
    jmp findRowEnd
    
    notRow1:
    cmp al, 17
    ja row3    
    mov row, 1
    jmp findRowEnd
    
    row3: 
    mov row, 2
    
    
    findRowEnd:
    pop ax   
    ret
findGrid endp         
         
drawCol proc   
    
    drawColLoop:  
    push cx
    mov ah, 2
    int 10h 
    
    mov ah, 0Ah 
    mov al, "#"
    mov cx, 1
    int 10h
    
    pop cx        
    inc dh
    loop drawColLoop
    
    ret
drawCol endp

exit:

mov ah, 0
int 10h

lea dx, win1
cmp player, 0
jne Owin 
mov win2, "X"
jmp dispMessage

Owin:
mov win2, "O"
jmp dispMessage

tieExit:
mov ah, 0
int 10h 
lea dx, tie1

dispMessage:
mov ah, 9
int 21h 

ret