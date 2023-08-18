#![no_std]
#![no_main]

use bootloader_api::entry_point;
use core::{fmt::Write, panic::PanicInfo};

use kernel::log::Log;

entry_point!(kernel_main);

/// Entry point for the kernel that the bootloader transfers control over to
fn kernel_main(boot_info: &'static mut bootloader_api::BootInfo) -> ! {
    let framebuffer = boot_info.framebuffer.as_mut().unwrap();
    let info = framebuffer.info().clone();

    {
        let mut logger = Log::new(framebuffer.buffer_mut(), info);
        logger.clear();

        writeln!(logger, "Successfully booted Ghostblood!").unwrap();
    }
    loop {}
}

/// Handles panics in the OS
#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}
