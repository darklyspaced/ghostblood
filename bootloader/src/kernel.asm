mov eax, 1
add eax, 1

mov dx, KERNEL
call println

%include "println.asm"

KERNEL:
    db '[X] Loading kernel into memory [X]',0
