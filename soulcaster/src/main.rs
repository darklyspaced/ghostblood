use clap::{Parser, ValueEnum};
use color_eyre::eyre::Result;
use xshell::{cmd, Shell};

use std::path::{Path, PathBuf};

#[derive(Parser)]
#[command(author = "Rohan J. <srohanjd@gmail.com>", version = "0.1.0", about = "Build system for Ghostblood", long_about = None)]
struct Soulcaster {
    /// What command should be run
    #[arg(value_enum)]
    command: Command,
}

#[derive(Copy, Clone, PartialEq, Eq, PartialOrd, Ord, ValueEnum)]
enum Command {
    /// compile and run the OS in qemu
    Run,
    /// compile the OS into a .img file
    Build,
}

fn main() -> Result<()> {
    color_eyre::install()?;
    let sh = Shell::new()?;
    let cli = Soulcaster::parse();

    let workspace = cmd!(sh, "cargo locate-project")
        .args(["--workspace", "--message-format=plain"])
        .output()?
        .stdout;
    let root = Path::new(std::str::from_utf8(&workspace)?.trim())
        .parent()
        .unwrap()
        .to_path_buf();

    match cli.command {
        Command::Run => {
            build(&root)?;
            cmd!(sh, "qemu-system-x86_64")
                .args(["-machine", "q35", "-fda", {
                    root.clone().join("build/disk.img").to_str().unwrap()
                }])
                .quiet()
                .run()?;
        }
        Command::Build => build(&root)?,
    }
    Ok(())
}

fn build(root: &PathBuf) -> Result<()> {
    let sh = Shell::new()?;
    let build_dir = root.clone().join("build/");
    let disk_img = build_dir.clone().join("disk.img");

    let boot_src = root.clone().join("bootloader/src/");
    let boot_asm = boot_src.clone().join("boot.asm");
    let mut bin = build_dir.clone().join("boot.o");

    cmd!(sh, "nasm -i {boot_src} -f bin {boot_asm} -o {bin}")
        .quiet()
        .run()?;

    let kernel_src = root.clone().join("kernel/src/");
    let kernel_asm = kernel_src.clone().join("kernel.asm");
    bin.set_file_name("kernel.o");
    cmd!(sh, "nasm -i {kernel_src} -f bin {kernel_asm} -o {bin}")
        .quiet()
        .run()?;

    cmd!(sh, "dd if=/dev/zero of={disk_img} bs=512 count=2880")
        .quiet()
        .run()?;

    bin.set_file_name("boot.o");
    cmd!(sh, "dd if={bin} of={disk_img} bs=512 count=1 seek=0")
        .quiet()
        .run()?;

    bin.set_file_name("kernel.o");
    cmd!(sh, "dd if={bin} of={disk_img} bs=512 count=1 seek=1")
        .quiet()
        .run()?;

    Ok(())
}
