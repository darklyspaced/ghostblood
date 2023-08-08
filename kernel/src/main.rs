#![no_std]
#![no_main]

use bootloader_api::entry_point;
use core::panic::PanicInfo;

entry_point!(kernel_main);

/// Entry point for the kernel that the bootloader transfers control over to
fn kernel_main(boot_info: &'static mut bootloader_api::BootInfo) -> ! {
    let message = b"Hello, World!";
    if let Some(framebuffer) = boot_info.framebuffer.as_mut() {
        framebuffer.buffer_mut().into_iter().skip_while(predicate)
    }
    loop {}
}

/// Handles panics in the OS
#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}
