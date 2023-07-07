; prints out a word equivalent of hex
;
; params:
;   dx: hexadecimal
print_word:
    setup:
        pusha ; store copy of all registers on stack
        mov cx, 0 ; set the index to 0

    ; converts hex to ASCII
    convert:
        mov ax, 0x000f ; make ax a mask
        and ax, dx ; apply the mask, storing value in ax (0x1234 -> 0x0004)
        shr dx, 4 ; 0x1234 -> 0x123 (sizeof(0xf) == 4 bits)

        add al, 0x30 ; 0x30 is the base for numbers ('0')
        cmp al, 0x39 ; compare hex to ASCII 9
        jle replace ; if char is a number, replace it in WORD_OUT

        add al, 0x27 ; 0x30 + 0x31 == 0x61, base for lower case letters ('a')

    replace:
        mov bx, WORD_OUT + 5 ; set bx to an address that points to last char of WORD_OUT
        sub bx, cx ; move backwards based on the letter of hex that we are converting

        mov [bx], al ; overwrite char with produced ASCII

        cmp cx, 3
        je display ; if: all four chars have been processed, print it out!

        add cx, 1 ; else: increment index
        jmp convert ; loop

    display:
        mov bx, WORD_OUT
        call println

    end:
        popa ; retrieve copy of all registers -- restore to what they were before func call
        ret

; prints out a byte equivalent of hex
;
; params:
;   dh: hexadecimal byte
print_byte:
    print_byte_setup:
        pusha ; store copy of all registers on stack
        mov cx, 0 ; set the index to 0

    ; converts hex to ASCII
    print_byte_convert:
        mov al, 0x0f ; make ax a mask
        and al, dh ; apply the mask, storing value in ax (0x12 -> 0x02)
        shr dh, 4 ; 0x12 -> 0x1 (sizeof(0xf) == 4 bits)

        add al, 0x30 ; 0x30 is the base for numbers ('0')
        cmp al, 0x39 ; compare hex to ASCII 9
        jle print_byte_replace ; if char is a number, replace it in WORD_OUT

        add al, 0x27 ; 0x30 + 0x31 == 0x61, base for lower case letters ('a')

    print_byte_replace:
        mov bx, BYTE_OUT + 3 ; set bx to an address that points to last char of BYTE_OUT
        sub bx, cx ; move backwards based on the letter of hex that we are converting

        mov [bx], al ; overwrite char with produced ASCII

        cmp cx, 1
        je print_byte_display ; if: both chars have been processed, print it out!

        add cx, 1 ; else: increment index
        jmp print_byte_convert ; loop

    print_byte_display:
        mov bx, BYTE_OUT
        call println

    print_byte_end:
        popa ; retrieve copy of all registers -- restore to what they were before func call
        ret

; ============DATA=============
WORD_OUT:
    db '0x0000',0

BYTE_OUT:
    db '0x00',0
