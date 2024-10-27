# Changes from EMU8086/TASM to NASM

### Procedures:

_EMU8086/TASM_

```
procName PROC

    ...

    ret
procName ENDP
```

_NASM_

```
procName:

    ...

    ret
```

### Variables:

_EMU8086/TASM_

```
mov al, variable    ; Moves value of variable
mov variable, al

lea al, variable        ; Moves address of variable
mov al, offset variable
```

_NASM_

```
mov al, [variable]    ; Moves value of variable
mov byte [variable], al    ; Moves value of variable

mov al, variable      ; Moves address of variable
```
