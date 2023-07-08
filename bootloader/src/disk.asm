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
    ;   read across cylinders within one interrupt
    read_kernel_setup:
        pusha

        ; setup where to read to
        mov bx, 0x1000
        mov es, bx
        xor bx, bx

        mov ah, 0x02 ; set subfunction of int 0x13 to read
        mov ch, 0    ; track 0
        mov dh, 0    ; what head to read
        mov al, 1    ; how many sectors to read
        mov cl, 2    ; sector to read -- after boot sector

    read_sector:
        int 0x13

        jnc read_kernel_end

        failure:
            mov bx, FAIL
            call println

            mov dh, ah
            call print_byte

    read_kernel_end:
        popa
        jmp 0x1000:0x0000
        ret

FAIL:
    db '[!] Failed to read from disk with error code:',0
