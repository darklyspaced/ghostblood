; prints out strings
;
; params:
;   bx: CStr
println:
    begin:
        pusha ; push all register values to the stack
        mov ah, 0x0e ; set the subfunction of interrupt 0x10 to teletype output

    print_char:
        mov al, [bx] ; get the char stored at bx
        cmp al, 0 ; check if its NULL (the end of the str)
        je print_new_line ; return from function if its the end

        int 0x10 ; else: print the char
        add bx, 1 ; move the address of bx to next char
        jmp print_char ; loop

    print_new_line:
        mov al, 0x0a ; newline char
        int 0x10
        mov al, 0x0d ; carriage return
        int 0x10

    return:
        popa ; restore all register values to what they were before function call
        ret
