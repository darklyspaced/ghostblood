#![no_main]
#![no_std]

use log::info;
use uefi::prelude::*;

#[entry]
fn main(image: Handle, system_table: SystemTable<Boot>) -> Status {
    Status::SUCCESS
}
