# Changes from EMU8086 to TASM

### Conditional Jump

_EMU8086_

-   No Jump limit

_TASM_

-   -127/+128 bytes

### EXE Program boilerplate:

_EMU8086_

```
data segment

; define data here

ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
    mov ax, data
    mov ds, ax

    ; add your code here

mov ax, 4c00h
int 21h

ends

end start
```

_TASM_

```
data    segment

; define data here

data    ends

code    segment
   assume cs: code_seg, ds:data_seg

    start:
        mov ax, @data
        mov ds, ax

        ; add code here

code ends
   end  start
```

### COM Program boilerplate

_EMU8086_

```
org 100h

jmp start

; define data here

start:

; add your code here

ret
```

_TASM_

```
.model tiny
.code
.8086

org 100h

jmp start

; define data here

start:

; add your code here

end start

```
