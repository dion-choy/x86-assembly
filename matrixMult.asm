org 100h

jmp start

mat1 db 1,2,3,4,5,6,7,8,9 
mat2 db 9,8,7,6,5,4,3,2,1

start:      
lea si, mat1
mov cl, 3   ;ch->row, cl->col
mov dx, 0200h

movRow:
mov ch, 3
lea di, mat2
     
movCol:     ;loop start for movRow 

call mulAcc

inc di         
dec ch
jnz movCol  ;loop end        
          
add si, 3          
dec cl
jnz movRow
jmp end
                  
mulAcc proc
    push cx
    push si
    push di
    mov ch, 3
    
    loop3times:      
    mov al, [si]
    mul [di]
    add bl, al
    adc bh, ah
    
    inc si
    add di, 3         
    dec ch
    jnz loop3times
               
    mov di, dx
    mov [di], bl
    mov [di+1], bh
    add dx, 2
    mov bx, 0 
          
    pop di
    pop si      
    pop cx
    ret
mulAcc endp

end:
ret