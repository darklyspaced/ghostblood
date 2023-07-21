#![no_std]
#![no_main]

use core::panic::PanicInfo;

use bootloader_api::entry_point;

entry_point!(kernel_main);

/// Entry point for the kernel that the bootloader transfers control over to
fn kernel_main(boot_info: &'static mut bootloader_api::BootInfo) -> ! {
    loop {}
}

/// Handles panics in the OS
#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}
