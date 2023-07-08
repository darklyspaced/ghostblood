ENTRY(_start) /* define the entry point for the kernel */

PHDRS {
    headers PT_PHDR FILEHDR PHDRS AT(0x500);
    code PT_LOAD;
}

SECTIONS {
    . = 0x100000;
    _kernel_start = .;

    .text : { *(.text) } :code

    .bss : { *(.bss) }
    .data : { *(.data) }

    /* removes the eh_frame because we don't need it */
    /DISCARD/ : { *(.eh_frame) }

    /* the kernel is exactly 1MiB (2048 sectors) */
    . = _kernel_start + 0x100000 - 2;
    .marker :
    {
        SHORT(0xface) /* add some thing recognisable to where the end of the kernel should be */
    }
}
