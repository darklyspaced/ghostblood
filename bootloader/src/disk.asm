get_disk_params:
    disk_setup:
        mov di, 0x0000 ; guard against some BIOS bugs when di != 0x0000
        pusha

    ; inaccurate for (emulated) floppy disks
    read_disk_params:
        mov ah, 0x08
        int 0x13

        sub dh, 0x01 ; num of heads is one greater than it actually is
        call print_byte ; %dh has the number of heads

        and cl, 0x3f
        mov dh, cl ; %cl has the number of sectors per track
        call print_byte

    disk_end:
        popa
        ret

read_kernel:
    ; params:
    ;   dl: drive number
    ;   ch: number of sectors to read
    ;
    ;   has to loop and read one sector at a time because some BIOSes can't
    ;   read across cylinders with one interrupt
    read_kernel_setup:
        pusha

        ; setup where to read to
        mov bx, 0x09c0
        mov es, bx
        xor bx, bx

        mov ah, 0x02 ; set subfunction of int 0x13 to read
        mov ch, 0    ; track 0
        mov dh, 0    ; what head to read
        mov al, 1    ; how many sectors to read
        mov cl, 2    ; sector to read -- after boot sector

    read_sector:
        int 0x13

        jc failure
        jnc success

        success:
            mov bx, SUCCESS
            call println

            mov dh, al
            call print_byte

            mov dh, ah
            call print_byte

            jmp again

        failure:
            mov bx, FAIL
            call println

            mov dh, ah
            call print_byte

        again:
            cmp cl, ch
            jl read_loop ; if we still have more to read

            jmp read_kernel_end ; if we have read all requested

    read_loop:
        add cl, 1
        jmp read_sector

    read_kernel_end:
        popa
        jmp 0x09c0:0
        ret

FAIL:
    db 'FAILED BITCH',0

SUCCESS:
    db 'You did it!',0

READ:
    db 'attempted to read',0

