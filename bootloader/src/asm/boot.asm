[org 0x7c00] ; set the offset as CPU assumes that mem offsets are from 0x0000 instead of from start of
             ; binary mem (0x7c00) while in reality they are of the latter. org tells the CPU this
global _start

_start:
    mov bp, 0x9000  ; sets the stack up at 0x9000. stack grows downwards (towards lower addresses)
    mov sp, bp      ; and BIOS is below (at 0x7e00) so it needs to be sufficiently above to not overwrite

    mov bx, BOOTING ; store the mem address of BOOTING in bx
    call println

    mov dx, 0x1234
    call print_hex

    jmp $           ; jump to the current address (infinite loop)

 %include "println.asm"
 %include "print_hex.asm"

; ============= DATA ===============
BOOTING:
    db 'Booting Ghostblood',0

; ========= MAKE BOOTABLE ==========
times 510 - ($-$$) db 0 ; fill with 510 zeros minus the size of the previous code 
dw 0xaa55               ; tells the firmware that this is a bootsector that is bootable by adding magic number
