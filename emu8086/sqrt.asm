
org 100h   

jmp getInput

input db 3 DUP(?)
outDec db 0, 0, ".$"
outFrac db 0, 0, 0, 0, "$"

num db 0
frac db 0
y dw 0
x dw 1  
grad db 0
intcpt dw 0 

msg1 db "Enter 3 digit num to sqrt, 0<num<255, eg. 001: $" 
msg2 db 0Dh, 0Ah, "Answer: $"   

 
;--------Input-------

getInput:
lea di, input

lea dx, msg1 
mov ah, 9
int 21h  

wait_for_key:
; check for keystroke in
; keyboard buffer:
mov ah, 1
int 16h ;BIOS interrupt for keyboard
jz wait_for_key
; get keystroke from keyboard:
; (remove from the buffer)
mov ah, 0
int 16h
; print the key:
mov ah, 0eh
int 10h 
; press 'ent' to exit:
cmp al, 13
jz startCalc  

sub al, 48 ;change to int by ascii offset
mov [di], al
inc di

jmp wait_for_key
    
;--------Calculation------- 
    
startCalc:
mov cx, 7 
lea di, input ;get num from input   

mov al, [di]
mov ah, 100 
mul ah
mov bl, al

mov al, [di+1] 
mov ah, 10
mul ah
add bl, al
  
add bl, [di+2]
mov num, bl
mov bx, 0   
           
     
sqrt: 

call findGrad
call findy  
call findyInt
call findxInt

loop sqrt
jmp getOutput

findGrad proc            ;gradient of tangent line
    push ax
    push bx 
    
    mov ax, x
    mov bl, 2
    mul bl
    mov grad, al      
       
    pop bx
    pop ax
    ret
findGrad endp

findy proc    ;find square num 
    push ax
    push bx  
    
    mov ax, x
    mov bl, num
    mul al
    sub ax, bx
    mov y, ax 
              
    pop bx
    pop ax
    ret
findy endp

findyInt proc    ;find intercept of tangent 
    push ax         ;y=mx+c  
    push bx
    
    mov al, grad    ;mx -> ax  
    mov bx, x
    mul bl
    
    mov bx, y
    sub bx, ax
    mov intcpt, bx   
     
    pop bx
    pop ax
    ret
findyInt endp
       
findxInt proc 
    push ax
    push bx
    
    mov ax, intcpt
    neg ax
    
    mov bl, grad 
    div bl
    mov x, ax
    
    
    pop bx   
    pop ax
    ret
findxInt endp
               
;------Output------
        
getOutput:

mov ax, x    ; get decimal
mov ah, 0

mov cl, 10
div cl        ; convert to dec

add ax, 3030h       ; convert to ascii char
mov outDec, al
mov outDec[1], ah 
    
; get fraction output
mov ax, x       
mov al, ah
mov ah, 0    

mov cx, 100     ; multiply to perform operation
mul cx       
div grad         ; calc fraction   
      
mov cx, 0
cmp ax, 100
jb tohundreth 

cmp ax, 1000
jb tothousandth  

mov cx, 1000       ; get tenth place
div cx  
add al, 30h    
mov outFrac[bx], al 

inc bx

mov ax, dx         ; get hundredth place 
mov dx, 0   
 
tothousandth:

mov cx, 100       ; get tenth place
div cx  
add al, 30h    
mov outFrac[bx], al 

inc bx

mov ax, dx         ; get hundredth place 
mov dx, 0    

tohundreth:

mov cx, 10  
div cx      
add al, 30h 
mov outFrac[bx], al   
add dl, 30h 
mov outFrac[bx+1], dl
  
  

print: 

lea dx, msg2 
mov ah, 9
int 21h  

mov al, num
mov ah, 0


lea dx, outDec 
mov ah, 9
int 21h  

lea dx, outFrac
mov ah, 9
int 21h  

ret




