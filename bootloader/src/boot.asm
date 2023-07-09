[org 0x7c00] ; set the offset as CPU assumes that mem offsets are from 0x0000 instead of from start of
             ; binary mem (0x7c00) while in reality they are of the latter. org tells the CPU this
global _start

jmp 0x000:_start         ; perform a long jump to enforce CS:IP

_start:
    xor ax, ax          ; set data segment to offset 0 as org is alr set
    mov ds, ax          ; segment registers could be any spurious value at boot
    mov es, ax
    mov fs, ax
    mov gs, ax

    cld                 ; clear the direction flag: go forward in memory

    mov dl, [B_DRIVE]   ; store boot drive for later use

    mov ah, 0x00
    mov al, 0x03
    int 0x10            ; clear the screen

    mov bx, BOOTING     ; store the mem address of BOOTING in bx
    call println

    cli                 ; disable CPU interrupts (software interrupts are still enabled)
    mov ss, ax          ; 8088 had a bug: interrupts were not disabled while modifying ss:(e)sp; interrupts
                        ; cause %flags to be pushed onto stack and modification of ss:(e)sp != atomic...

    mov sp, 0x7c00      ; sets the stack up at 0x7c00. stack grows downwards (towards lower addresses)
    mov bp, sp          ; and BIOS is above, ending at 0x7e00

    mov [B_DRIVE], dl   ; store the bootdrive

    mov ch, 1
    call read_kernel

    hlt                 ; halts the CPU

%include "println.asm"
%include "print_hex.asm"
%include "disk.asm"

; ============= DATA ===============
BOOTING:
    db '[!] Booting Ghostblood [!]',0

B_DRIVE: ; bootdrive
    db 0

; ========= MAKE BOOTABLE ==========
times 510 - ($-$$) db 0 ; fill with 510 zeros minus the size of the previous code
dw 0xaa55               ; tells the firmware that this is a bootsector that is bootable
                        ; by adding magic number
