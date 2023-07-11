#![no_main]
#![no_std]

use core::arch::asm;
use core::panic::PanicInfo;

use log::info;
use uefi::prelude::*;

#[entry]
fn main(image: Handle, system_table: SystemTable<Boot>) -> Status {
    Status::SUCCESS
}

fn load_kernel(image: Handle, system_table: SystemTable<Boot>) {
    let file_system = get_image_file_system();
}
/// Panic handler for the bootloader.
///
/// In case of any panics, the bootloader will just pause the CPU and disable any further hardware
/// interrupts, logging out the reason for any panics.
#[panic_handler]
fn panic(info: &PanicInfo) -> ! {
    info!("{}", info);
    unsafe {
        loop {
            asm!("cli; hlt")
        }
    }
}
