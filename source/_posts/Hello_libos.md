---
title: "qemu start process"
date: 2026-05-07 11:11:08
tags:
  - note
---

# qemu start process
Before the qemu start,the rustc would compile the os file into ELF(configure by Cargo.toml) with linker.ld,which tells the linker to arrange the layout of the kernel file.Just like
```text
  .text [0x80200000, 0x80202000)
  .rodata [0x80202000, 0x80203000)
  .data [0x80203000, 0x80204000)
  .bss [0x80214000, 0x80215000)
```
Then qemu start a virtual RISC-V machine with CPU,memory,serial port, clock, interrupt controller, virt test equipment, and use the RustSBI.
RustSBI is a firmware precede to kernel file,which finishing 
  - initialize the hardware env,
  - setting privilege env,
  - prepare the device tree information,
  - provide SBI invoking interface,
  - jump to the kernel entrypoint

Tips:
RISC-V has different privilege:
  - M-mode: machine mode,highest privilege,RustSBI run there,
  - S-mode: supervisor mode,os kernel file run there,
  - U-mode: user mode, user program run there,

The RustSBI jump to the kernel file and give the CPU to the base address(entrypoint in ELF file) `0x80200000`.
Then the PC = `0x80200000` would execute the first kernel instruction.The address must match the `linker.ld`'s BASE_ADDRESS = 0x80200000

## entry.asm
entry.asm would set the stack and the env Rust function need.

## How does the println! output to the terminal?
Without GPU driver and Linux stdout,the output chain is:
  println!
    ↓
  console.rs
    ↓
  sbi.rs::console_putchar()
    ↓
  ecall
    ↓
  RustSBI
    ↓
  QEMU serial port
    ↓
  terminal
  


## .bss
`.bss` is a program memory section used to store global/static variables that are zero-initialized or not explicitly initialized.

```text
.text   -> code / instructions
.rodata -> read-only constants, string literals
.data   -> initialized global/static variables
.bss    -> uninitialized or zero-initialized global/static variables
heap    -> dynamic allocation, malloc/new/Box
stack   -> local function variables, call frames
```

compile process
```text
Preprocessing: handle #include, #define
Compilation: source code -> assembly
Assembly: assembly -> machine code/object file
Linking: object files + libraries -> executable
Loading: executable -> memory, then run
```

## ELF
ELF is a common binary file format used in Linux/Unix-like systems(Executable Linkable Format)

may be like:
```text
ELF is the standard Linux binary package.

It tells the OS:
- what code to load
- where to load it
- what memory permissions to use
- where the program entry point is

It tells the linker/debugger:
- what symbols exist
- what sections exist
- what relocations are needed
```
`.bin` just a raw bytes file without structure.But ELF file has structure and could tell the loader the:
```text
Load this part at this memory address.
Give this part read + execute permission.
Give this part read + write permission.
Start execution at this entry point.
Reserve zero-filled memory for .bss.
```

## other marco
trace!, error!, info! and so on.This marco comes from:
Cargo.toml 
[dependencies]
log = "0.4"
Third-party crate

## `os/src/main.rs` detailed notes

This section explains the current `main.rs` in chapter 1. The most important
point is that this file is not a normal Rust application entry. It is part of a
bare-metal kernel. There is no Linux process, no normal `main()` function, and
no standard library runtime before this code runs.

The rough execution chain is:

```text
QEMU
  -> OpenSBI
  -> 0x80200000
  -> entry.asm::_start
  -> rust_main() in main.rs
```

The source file is:

```rust
//! The main module and entrypoint
//!
//! The operating system and app also starts in this module. Kernel code starts
//! executing from `entry.asm`, after which [`rust_main()`] is called to
//! initialize various pieces of functionality [`clear_bss()`]. (See its source code for
//! details.)
//!
//! We then call [`println!`] to display `Hello, world!`.

#![deny(missing_docs)]
#![deny(warnings)]
#![no_std]
#![no_main]
#![feature(panic_info_message)]

use core::arch::global_asm;
use log::*;

#[macro_use]
mod console;
mod lang_items;
mod logging;
mod sbi;

#[path = "boards/qemu.rs"]
mod board;

global_asm!(include_str!("entry.asm"));

/// clear BSS segment
pub fn clear_bss() {
    extern "C" {
        fn sbss();
        fn ebss();
    }
    (sbss as usize..ebss as usize).for_each(|a| unsafe { (a as *mut u8).write_volatile(0) });
}

/// the rust entry-point of os
#[no_mangle]
pub fn rust_main() -> ! {
    extern "C" {
        fn stext(); // begin addr of text segment
        fn etext(); // end addr of text segment
        fn srodata(); // start addr of Read-Only data segment
        fn erodata(); // end addr of Read-Only data ssegment
        fn sdata(); // start addr of data segment
        fn edata(); // end addr of data segment
        fn sbss(); // start addr of BSS segment
        fn ebss(); // end addr of BSS segment
        fn boot_stack_lower_bound(); // stack lower bound
        fn boot_stack_top(); // stack top
    }
    clear_bss();
    logging::init();
    println!("[kernel] Hello, world!");
    trace!(
        "[kernel] .text [{:#x}, {:#x})",
        stext as usize,
        etext as usize
    );
    debug!(
        "[kernel] .rodata [{:#x}, {:#x})",
        srodata as usize, erodata as usize
    );
    info!(
        "[kernel] .data [{:#x}, {:#x})",
        sdata as usize, edata as usize
    );
    warn!(
        "[kernel] boot_stack top=bottom={:#x}, lower_bound={:#x}",
        boot_stack_top as usize, boot_stack_lower_bound as usize
    );
    error!("[kernel] .bss [{:#x}, {:#x})", sbss as usize, ebss as usize);

    use crate::board::QEMUExit;
    crate::board::QEMU_EXIT_HANDLE.exit_success();
}
```

### 1. The top comments: `//!`

```rust
//! The main module and entrypoint
```

`//!` is an inner documentation comment. It documents the module or crate that
contains it.

This is different from:

```rust
/// documents the item below it
fn foo() {}
```

So:

```rust
//! ...
```

means:

```text
This is documentation for the current module/crate.
```

In this file, the comments explain that kernel execution starts in
`entry.asm`, and then `entry.asm` calls `rust_main()`.

### 2. Crate-level attributes

These lines are crate attributes:

```rust
#![deny(missing_docs)]
#![deny(warnings)]
#![no_std]
#![no_main]
#![feature(panic_info_message)]
```

They apply to the whole crate, not just one function.

#### `#![deny(missing_docs)]`

This asks the compiler to treat missing documentation as an error.

For example, if a public function has no documentation comment, the compiler may
reject it.

That is why `clear_bss()` and `rust_main()` have comments:

```rust
/// clear BSS segment
pub fn clear_bss() { ... }

/// the rust entry-point of os
pub fn rust_main() -> ! { ... }
```

#### `#![deny(warnings)]`

This turns all warnings into hard errors.

In a teaching kernel, this is useful because warnings often mean something is
not understood or not cleaned up. But it also means small things, such as an
unused import or typo in docs, can stop compilation.

#### `#![no_std]`

This is one of the most important lines.

Normal Rust programs use `std`:

```rust
use std::println;
use std::vec::Vec;
```

But `std` depends on an operating system. It expects things like:

```text
files
threads
heap allocation
system calls
stdout
process exit
```

At kernel boot time, none of these exist yet. The kernel is the software that
will eventually provide them.

So this kernel uses:

```rust
#![no_std]
```

That means it can use `core`, but not `std`.

`core` contains the parts of Rust that do not require an operating system, such
as:

```text
basic types
Option / Result
formatting traits
raw pointer operations
inline assembly support
```

#### `#![no_main]`

Normal Rust programs start from:

```rust
fn main() {
    ...
}
```

But that assumes an operating system has loaded the program and the Rust runtime
has prepared the environment.

This kernel does not have that. OpenSBI jumps directly to a raw instruction
address. Therefore the kernel provides its own entry flow:

```text
entry.asm::_start
  -> rust_main()
```

So this crate says:

```rust
#![no_main]
```

Meaning:

```text
Do not expect the normal Rust main function.
I will provide my own entry point.
```

#### `#![feature(panic_info_message)]`

This enables an unstable Rust feature. The kernel is using a nightly Rust
feature related to panic information.

In a normal Rust program, panic handling is provided by `std`. In this kernel,
panic handling is usually implemented manually in `lang_items.rs`.

### 3. Imports

```rust
use core::arch::global_asm;
use log::*;
```

#### `use core::arch::global_asm;`

`global_asm` allows Rust code to include global assembly code.

This is needed because the first instructions of the kernel are written in
assembly:

```asm
_start:
    la sp, boot_stack_top
    call rust_main
```

Rust functions need a valid stack. Before the stack is set, calling ordinary
Rust code is not safe. That is why the earliest boot code is in `entry.asm`.

#### `use log::*;`

This imports items from the `log` crate.

The macros:

```rust
trace!
debug!
info!
warn!
error!
```

come from:

```toml
[dependencies]
log = "0.4"
```

They do not come from `core`.

The `log` crate only provides the logging interface and macros. The real output
backend is implemented in `logging.rs`.

The chain is:

```text
trace!("...")
  -> log crate macro
  -> SimpleLogger::log() in logging.rs
  -> println!
  -> console.rs
  -> sbi.rs
  -> ecall
  -> OpenSBI
  -> QEMU terminal
```

### 4. Module declarations

```rust
#[macro_use]
mod console;
mod lang_items;
mod logging;
mod sbi;
```

These tell Rust to compile other source files as modules of this crate.

They correspond to:

```text
mod console;     -> os/src/console.rs
mod lang_items;  -> os/src/lang_items.rs
mod logging;     -> os/src/logging.rs
mod sbi;         -> os/src/sbi.rs
```

#### `#[macro_use] mod console;`

`console.rs` defines macros such as:

```rust
print!
println!
```

The attribute:

```rust
#[macro_use]
```

brings those macros into scope, so `main.rs` can directly write:

```rust
println!("[kernel] Hello, world!");
```

This is not the standard library `println!`. In this kernel, `println!` is a
custom macro defined in `console.rs`.

That custom `println!` eventually uses SBI calls to output characters.

### 5. Board-specific module path

```rust
#[path = "boards/qemu.rs"]
mod board;
```

Normally, this:

```rust
mod board;
```

would look for:

```text
os/src/board.rs
```

or:

```text
os/src/board/mod.rs
```

But this code says:

```rust
#[path = "boards/qemu.rs"]
mod board;
```

So Rust loads the module from:

```text
os/src/boards/qemu.rs
```

This file contains QEMU-specific code, such as the mechanism used to exit QEMU
successfully.

The reason for this pattern is that later the same kernel may support different
boards. Then each board can have its own file.

### 6. Including `entry.asm`

```rust
global_asm!(include_str!("entry.asm"));
```

This line includes the text content of `entry.asm` into the Rust crate as global
assembly.

Break it down:

```rust
include_str!("entry.asm")
```

means:

```text
Read the file entry.asm at compile time and include it as a string.
```

Then:

```rust
global_asm!(...)
```

passes that assembly string to the compiler.

The assembly file contains:

```asm
.section .text.entry
.globl _start
_start:
    la sp, boot_stack_top
    call rust_main

.section .bss.stack
.globl boot_stack_lower_bound
boot_stack_lower_bound:
    .space 4096 * 16
.globl boot_stack_top
boot_stack_top:
```

This defines:

```text
_start                  kernel's first code label
boot_stack_lower_bound  bottom address of boot stack
boot_stack_top          top address of boot stack
```

`linker.ld` makes sure `.text.entry` is placed at the beginning of the kernel
image. Therefore `_start` becomes the first code that runs after OpenSBI jumps
to the kernel.

### 7. `clear_bss()`

```rust
pub fn clear_bss() {
    extern "C" {
        fn sbss();
        fn ebss();
    }
    (sbss as usize..ebss as usize).for_each(|a| unsafe { (a as *mut u8).write_volatile(0) });
}
```

This function clears the `.bss` memory section.

#### What is `.bss`?

`.bss` stores global/static variables that should start as zero.

For example:

```rust
static mut COUNTER: usize = 0;
```

or large uninitialized static buffers may be placed in `.bss`.

In a normal user program, the operating system loader clears `.bss` before
running the program. In this kernel, there is no operating system loader doing
that for us. So the kernel must clear `.bss` manually.

#### `extern "C"` symbols

```rust
extern "C" {
    fn sbss();
    fn ebss();
}
```

These are not normal functions that should be called.

They are linker symbols defined by `linker.ld`.

Conceptually, think of them like:

```text
sbss = start address of .bss
ebss = end address of .bss
```

Rust does not have a special syntax here for "external linker address symbol",
so this tutorial declares them as external C functions and then takes their
addresses:

```rust
sbss as usize
ebss as usize
```

The code does not call:

```rust
sbss();
```

It only uses:

```rust
sbss as usize
```

That means:

```text
Get the address value of the symbol sbss.
```

#### The range syntax

```rust
sbss as usize..ebss as usize
```

This creates a Rust range:

```text
[sbss, ebss)
```

It includes the start address and excludes the end address.

For example, if:

```text
sbss = 0x80214000
ebss = 0x80215000
```

then the range is:

```text
0x80214000, 0x80214001, ..., 0x80214fff
```

#### `for_each`

```rust
.for_each(|a| ...)
```

This iterates over every address in the range. Each address is named `a`.

It is similar to:

```rust
for a in sbss as usize..ebss as usize {
    ...
}
```

#### The closure syntax `|a|`

```rust
|a| unsafe { ... }
```

This is a closure. It means:

```text
For each address a, run this block.
```

#### Why `unsafe`?

```rust
unsafe { (a as *mut u8).write_volatile(0) }
```

Rust normally cannot prove that an arbitrary integer address is valid memory.
Writing to a raw pointer may corrupt memory if the address is wrong.

Therefore raw pointer writes require `unsafe`.

Here it is considered valid because `sbss` and `ebss` come from `linker.ld`, and
the linker script defines the real `.bss` region.

#### `a as *mut u8`

```rust
a as *mut u8
```

This converts the integer address `a` into a raw mutable pointer to one byte.

`u8` means one byte, so the loop clears memory byte by byte.

#### `write_volatile(0)`

```rust
.write_volatile(0)
```

This writes the byte value `0` to that address.

`volatile` tells the compiler:

```text
Do not remove or reorder this memory operation as if it were useless.
This write must really happen.
```

For memory-mapped hardware and low-level memory initialization, volatile writes
are commonly used.

So the whole function means:

```text
Take the memory range [sbss, ebss).
Treat every address as one writable byte.
Write zero to each byte.
```

### 8. `rust_main()`

```rust
#[no_mangle]
pub fn rust_main() -> ! {
    ...
}
```

This is the Rust-side kernel entry function.

It is called from assembly:

```asm
call rust_main
```

#### `#[no_mangle]`

Rust normally changes function symbol names during compilation. This is called
name mangling.

For example, Rust might turn a function name into something containing module
paths and hash values.

But assembly expects the function to be named exactly:

```text
rust_main
```

So we write:

```rust
#[no_mangle]
```

This tells the compiler:

```text
Keep the generated symbol name exactly as rust_main.
```

Without this, `entry.asm` may not be able to find the function when it says:

```asm
call rust_main
```

#### `pub fn rust_main()`

```rust
pub
```

means public.

Here it also helps make the function visible as a symbol for the assembly/linker
side.

#### Return type `-> !`

```rust
pub fn rust_main() -> !
```

The `!` type is the never type.

It means:

```text
This function never returns.
```

That makes sense for a kernel entry function. There is no caller waiting in a
normal operating system process.

In this chapter, `rust_main()` eventually calls:

```rust
QEMU_EXIT_HANDLE.exit_success()
```

That function also never returns. It tells QEMU to exit. If that fails, it loops
forever.

### 9. Linker symbols inside `rust_main()`

```rust
extern "C" {
    fn stext();
    fn etext();
    fn srodata();
    fn erodata();
    fn sdata();
    fn edata();
    fn sbss();
    fn ebss();
    fn boot_stack_lower_bound();
    fn boot_stack_top();
}
```

Again, these are not ordinary functions to call. They are address symbols.

Most of them come from `linker.ld`:

```text
stext   start of .text
etext   end of .text
srodata start of .rodata
erodata end of .rodata
sdata   start of .data
edata   end of .data
sbss    start of .bss
ebss    end of .bss
```

The stack symbols come from `entry.asm`:

```text
boot_stack_lower_bound
boot_stack_top
```

They are used for printing memory layout information.

For example:

```rust
stext as usize
```

means:

```text
Convert the address of the linker symbol stext into a usize integer.
```

This lets the kernel print addresses such as:

```text
.text [0x80200000, 0x80202000)
```

### 10. Runtime steps in `rust_main()`

```rust
clear_bss();
```

This must happen early. It makes sure zero-initialized global/static memory is
actually zero before the kernel uses it.

```rust
logging::init();
```

This registers the logger defined in `logging.rs`.

Before this line, macros like `info!` and `error!` have no useful output backend.
After this line, the `log` crate knows where to send log records.

```rust
println!("[kernel] Hello, world!");
```

This uses the custom `println!` macro from `console.rs`.

The output path is:

```text
println!
  -> console::print()
  -> sbi::console_putchar()
  -> ecall
  -> OpenSBI
  -> QEMU terminal
```

### 11. Logging macros

```rust
trace!(...)
debug!(...)
info!(...)
warn!(...)
error!(...)
```

These macros come from the `log` crate, not from `core`.

The current logger chooses a color and prints:

```text
[TRACE] message
[DEBUG] message
[ INFO] message
[ WARN] message
[ERROR] message
```

The visible log level depends on the compile-time environment variable:

```rust
option_env!("LOG")
```

In `logging.rs`, the code checks:

```rust
Some("ERROR") => LevelFilter::Error,
Some("WARN") => LevelFilter::Warn,
Some("INFO") => LevelFilter::Info,
Some("DEBUG") => LevelFilter::Debug,
Some("TRACE") => LevelFilter::Trace,
_ => LevelFilter::Off,
```

So:

```bash
make run LOG=TRACE
```

allows all logs from `ERROR` up to `TRACE` to be printed.

The important detail is that:

```rust
error!("[kernel] .bss ...")
```

does not mean the kernel has crashed. It only means the code intentionally used
the `error!` log level to print the `.bss` address range.

### 12. Formatting syntax

Example:

```rust
trace!(
    "[kernel] .text [{:#x}, {:#x})",
    stext as usize,
    etext as usize
);
```

This is Rust format syntax.

```text
{}     normal display
{:?}   debug display
{:#x}  hexadecimal with 0x prefix
```

So if:

```text
stext = 0x80200000
etext = 0x80202000
```

then:

```rust
"[{:#x}, {:#x})"
```

prints:

```text
[0x80200000, 0x80202000)
```

The interval notation:

```text
[start, end)
```

means:

```text
start is included
end is excluded
```

### 13. Why are addresses printed?

The logs print these memory regions:

```text
.text
.rodata
.data
boot_stack
.bss
```

This helps verify that `linker.ld` is doing what we expect.

Typical output:

```text
[kernel] Hello, world!
[TRACE] [kernel] .text [0x80200000, 0x80202000)
[DEBUG] [kernel] .rodata [0x80202000, 0x80203000)
[ INFO] [kernel] .data [0x80203000, 0x80204000)
[ WARN] [kernel] boot_stack top=bottom=0x80214000, lower_bound=0x80204000
[ERROR] [kernel] .bss [0x80214000, 0x80215000)
```

The boot stack occupies:

```text
[0x80204000, 0x80214000)
```

That is:

```text
0x10000 bytes = 64 KiB
```

The normal `.bss` starts after the boot stack:

```text
sbss = 0x80214000
```

This prevents `clear_bss()` from clearing the stack currently being used by the
kernel.

### 14. Exiting QEMU

```rust
use crate::board::QEMUExit;
crate::board::QEMU_EXIT_HANDLE.exit_success();
```

This imports the `QEMUExit` trait and calls the QEMU-specific exit function.

`crate` means:

```text
the current Rust crate
```

So:

```rust
crate::board::QEMU_EXIT_HANDLE
```

means:

```text
Find QEMU_EXIT_HANDLE inside the board module of this crate.
```

In `boards/qemu.rs`, the code writes a special value to a special QEMU device
address. QEMU recognizes that write and exits with success.

This is mainly useful for automated tests.

### 15. Summary of the file

`main.rs` connects the early assembly boot code with the Rust kernel logic.

Its responsibilities are:

```text
1. Configure this crate as a no_std, no_main bare-metal kernel.
2. Import the assembly entry code from entry.asm.
3. Declare Rust modules such as console, logging, sbi, and board.
4. Clear the .bss memory region using linker-provided symbols.
5. Initialize logging.
6. Print kernel memory layout information.
7. Exit QEMU successfully for the tutorial test environment.
```

The central idea is:

```text
linker.ld defines important memory symbols.
entry.asm sets up the first stack and calls rust_main.
main.rs uses those symbols to initialize memory and print the kernel layout.
console.rs and sbi.rs allow main.rs to print through OpenSBI.
boards/qemu.rs allows the kernel to end the QEMU run cleanly.
```
