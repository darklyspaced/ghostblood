[org 0x7c00] ; set the offset as CPU assumes that mem offsets are from 0x0000 instead of from start of
             ; binary mem (0x7c00) while in reality they are of the latter. org tells the CPU this

jmp 0x000:start         ; perform a long jump to enforce CS:IP

start:
    xor ax, ax          ; set data segment to offset 0 as org is alr set
    mov ds, ax          ; segment registers could be any spurious value at boot
    mov es, ax

    mov [B_DRIVE], dl   ; store the bootdrive

    cli                 ; disable CPU interrupts (software interrupts are still enabled)
    mov ss, ax          ; 8088 had a bug: interrupts were not disabled while modifying ss:(e)sp; interrupts
                        ; cause %flags to be pushed onto stack and modification of ss:(e)sp != atomic...

    mov bp, 0x7c00      ; sets the stack up at 0x8000. stack grows downwards (towards lower addresses)
    mov sp, bp          ; and BIOS is above, ending at 0x7e00

    mov bx, BOOTING     ; store the mem address of BOOTING in bx
    call println

    mov dx, dl
    call print_hex

    mov dx, 0x1234
    call print_hex

    jmp $               ; jump to the current address (infinite loop)

%include "println.asm"
%include "print_hex.asm"

; ============= DATA ===============
BOOTING:
    db 'Booting Ghostblood',0

B_DRIVE: ; bootdrive
    db 0

; ========= MAKE BOOTABLE ==========
times 510 - ($-$$) db 0 ; fill with 510 zeros minus the size of the previous code
dw 0xaa55               ; tells the firmware that this is a bootsector that is bootable
                        ; by adding magic number
