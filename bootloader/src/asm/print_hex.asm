; prints out hexadecimal values as they are
;
; params:
;   dx: hexadecimal
print_hex:
    setup:
        pusha ; store copy of all registers on stack
        mov ah, 0x0e ; set the subfunction of interrupt 0x10 to teletype output
        mov cx, 0 ; set the index to 0

    ; converts hex to ASCII
    convert:
        mov ax, 0x000f ; make ax a mask
        and ax, dx ; apply the mask, storing value in ax (0x1234 -> 0x0004)
        shr dx, 4 ; 0x1234 -> 0x123 (sizeof(0xf) == 4 bits)

        add al, 0x30 ; 0x30 is the base for numbers ('0')
        cmp al, 0x39 ; compare hex to ASCII 9
        jle replace ; if char is a number, replace it in HEX_OUT

        add al, 0x31 ; 0x30 + 0x31 == 0x61, base for lower case letters ('a')

    replace:
        mov bx, HEX_OUT + 5 ; set bx to an address that points to last char of HEX_OUT
        sub bx, cx ; move backwards based on the letter of hex that we are converting

        mov [bx], al ; overwrite char with produced ASCII

        cmp cx, 3
        je display ; if: all four chars have been processed, print it out!

        add cx, 1 ; else: increment index
        jmp convert ; loop

    display:
        mov bx, HEX_OUT
        call println

    end:
        popa ; retrieve copy of all registers -- restore to what they were before func call
        ret

; ============DATA=============
HEX_OUT:
    db '0x0000',0
