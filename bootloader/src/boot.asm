[org 0x7c00] ; set the offset as CPU assumes that mem offsets are from 0x0000 instead of from start of binary mem (0x7c00)
             ; while in reality they are of the latter. org tells the CPU this
global _start

_start:
    mov bp, 0x9000 ; sets the stack up at 0x9000 as stack grows downwards (towards lower addresses)
    mov sp, bp     ; and BIOS is below (at 0x7e00) so it needs to be sufficiently above

    mov bx, BOOTING ; store the mem address of boot_msg in dx
    call print_str

    jmp $ ; jump to the current address (infinite loop)

print_str:
    pusha ; push all register values to the stack
    mov ah, 0x0e ; set the subfunction of interrupt 0x10 to teletype output

    print_char:
        mov al, [bx] ; get the char stored at bx
        cmp al, 0 ; check if its NULL (the end of the str)
        je end ; return from function if its the end

        int 0x10 ; else: print the char
        add bx, 1 ; move the address of bx to next char
        jmp print_char ; loop

    end:
        popa ; restore all register values to what they were before function call
        ret

BOOTING:
    db 'Booting Ghostblood',0

; Fill with 510 zeros minus the size of the previous code
times 510 - ($-$$) db 0
; tells the firmware that this is a bootsector that is bootable
dw 0xaa55
