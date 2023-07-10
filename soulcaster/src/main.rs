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
    /// compile the OS and its dependencies
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

/// Builds all the packages required by Ghostblood.
///
/// Required as per-package-target is buggy with target triple `x86_64-unknown-uefi` and native
/// `cargo build` **cannot** be used as it throws false positives on errors due to it incorrectly
/// attempting to compile for bare-metal, ignoring the `forced-target` key.
fn build(_root: &PathBuf) -> Result<()> {
    let sh = Shell::new()?;
    cmd!(sh, "cargo build --quiet --package bootloader")
        .quiet()
        .run()?;
    Ok(())
}
