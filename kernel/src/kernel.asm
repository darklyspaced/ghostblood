kernel_start:
    mov bx, 0x1000      ; make the offset where kernel was loaded into memory
    mov ds, bx
    xor bx, bx

    mov bx, KERNEL_LOAD
    call println

    hlt

%include "src/println.asm"

KERNEL_LOAD:
    db '[!] Loaded kernel into memory [!]',0
