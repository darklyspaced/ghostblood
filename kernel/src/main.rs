#![no_std]
#![no_main]

use core::panic::PanicInfo;

/// Overwrites the entry point for the OS
///
/// The entry point for a typical rust binary is usually `crt0`, a set of setup execution routines,
/// that performs any initialisation needed (with a function called `_start` being the entry
/// point). This then calls the Rust Runtime which sets up things like stack overflow guarding,
/// backtracing and stack unwinding.
///
/// Obviously, there is no OS, so we have to define our own entry point; `_start` being the default
/// that the linker searches for. `#[no_mangle]` ensures that the function remains being called
/// `_start` so the linker can find it. (The linker only knows about C where clashing function
/// names are not allowed so Rust mangles function names to ensure that each one has a unique name).
#[no_mangle]
pub extern "C" fn _start() -> ! {
    loop {}
}

/// Handles panics in the OS
#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}
