---
title: "rcore-users"
date: 2026-05-09 17:55:00
tags:
  - rCore
  - OS
  - user
---

# rCore User Directory

The `user/` directory is the user application side of this rCore repo.

```text
user/  user-mode programs and user-side library
os/    kernel-mode code: trap, syscall implementation, scheduler, loader
```

The kernel does not run Rust source files directly. The user programs in `user/src/bin/*.rs` are compiled into binaries, then embedded into the kernel image and loaded by the kernel.

## File Roles

```text
user/src/bin/*.rs
  Real user applications and tests.
  Many files are chapter tests, such as ch2*, ch3*, ..., ch9*.

user/src/lib.rs
  Tiny user runtime and user-friendly API.
  Provides _start(), heap init, clear_bss(), exit(), yield_(), get_time(), etc.

user/src/console.rs
  User-side println!/print! support.
  It buffers text and finally calls write().

user/src/syscall.rs
  Raw syscall client.
  It puts syscall id and arguments into RISC-V registers, then executes ecall.

user/src/linker.ld
  User program linker layout.
  The entry point is _start.

user/build.py
  For ch3, builds every selected app at a different fixed address.
```

## User Program Start Chain

A user app does not start from its own `main` directly. It starts from `_start` in `user/src/lib.rs`.

```text
kernel jumps to user app entry
  -> user/src/lib.rs::_start(argc, argv)
  -> clear_bss()
  -> init user heap
  -> call app main()
  -> exit(main_return_value)
  -> sys_exit()
  -> ecall
  -> kernel syscall handler
```

Important code shape:

```rust
#[no_mangle]
#[link_section = ".text.entry"]
pub extern "C" fn _start(argc: usize, argv: usize) -> ! {
    clear_bss();
    HEAP.lock().init(...);
    exit(main(argc, v.as_slice()));
}
```

Each app in `user/src/bin/*.rs` provides its own `main`.

```rust
#[no_mangle]
fn main() -> i32 {
    println!("hello");
    0
}
```

## Why User Has Its Own lib

User programs cannot directly call kernel Rust functions in `os/`.

Wrong mental model:

```text
user app -> directly call os::sys_yield()
```

Real model:

```text
user app
  -> user_lib::yield_()
  -> user/src/syscall.rs::sys_yield()
  -> ecall
  -> kernel trap handler
  -> os/src/syscall/process.rs::sys_yield()
```

So there are two syscall sides:

```text
user/src/syscall.rs
  syscall client: prepare registers and execute ecall

os/src/syscall/*.rs
  syscall server: actually implement kernel behavior
```

## println Chain

When a user app calls `println!`, it still enters the kernel through syscall.

```text
println!("hello")
  -> user/src/console.rs::print()
  -> user/src/lib.rs::write()
  -> user/src/syscall.rs::sys_write()
  -> syscall(SYSCALL_WRITE, ...)
  -> ecall
  -> kernel trap handler
  -> kernel sys_write()
  -> console output
```

So `console.rs` is not the real hardware console driver. It is only the user-side printing wrapper.

## yield Chain

```text
yield_()
  -> user/src/lib.rs::yield_()
  -> user/src/syscall.rs::sys_yield()
  -> syscall(SYSCALL_YIELD, [0, 0, 0])
  -> ecall
  -> kernel trap handler
  -> kernel sys_yield()
  -> suspend_current_and_run_next()
```

## Raw syscall Registers

The user syscall wrapper uses RISC-V registers:

```rust
core::arch::asm!(
    "ecall",
    inlateout("x10") args[0] => ret,
    in("x11") args[1],
    in("x12") args[2],
    in("x17") id,
);
```

Meaning:

```text
x10 / a0 = arg0 and return value
x11 / a1 = arg1
x12 / a2 = arg2
x17 / a7 = syscall id
ecall    = enter kernel
```

## make run Locates User Apps

`make run` is usually executed from `os/`.

```text
cd os
make run
```

The important chain is:

```text
os/Makefile::run
  -> os/Makefile::build
  -> os/Makefile::kernel
  -> make -C ../user build TEST=$(TEST) CHAPTER=$(CHAPTER) BASE=$(BASE)
```

So the OS build enters the `user/` directory and asks it to build selected apps.

In `user/Makefile`, app selection is based on chapter:

```text
BASE=1, CHAPTER=3
  -> user/src/bin/ch3b_*.rs

BASE=0, CHAPTER=3
  -> user/src/bin/ch3_*.rs

BASE=2, CHAPTER=3
  -> user/src/bin/ch3*.rs
```

Then:

```text
user/src/bin/*.rs
  -> cargo builds ELF files
  -> rust-objcopy creates .bin files
  -> user/build/bin/*.bin
```

## Embedding Apps Into Kernel

After user apps are built, `os/build.rs` reads:

```text
../user/build/bin/
```

It generates:

```text
os/src/link_app.S
```

The generated assembly embeds app binaries using `.incbin`:

```asm
_num_app:
    .quad 3
    .quad app_0_start
    .quad app_1_start
    .quad app_2_start
    .quad app_2_end

app_0_start:
    .incbin "../user/build/bin/ch3b_yield0.bin"
app_0_end:
```

Then `os/src/main.rs` includes that generated file:

```rust
core::arch::global_asm!(include_str!("link_app.S"));
```

At boot:

```text
rust_main()
  -> loader::load_apps()
  -> read _num_app and app start/end symbols
  -> copy each embedded app to memory
```

For ch3, apps are copied to fixed addresses:

```text
app 0 -> 0x80400000
app 1 -> 0x80420000
app 2 -> 0x80440000
```

## Whole User-Side Picture

```text
user/src/bin/ch3b_yield0.rs
  -> uses user_lib
  -> starts at user_lib::_start
  -> calls app main()
  -> println!/yield_/get_time()
  -> user lib wrapper
  -> user syscall wrapper
  -> ecall
  -> kernel
```

Build and load picture:

```text
make run
  -> build selected user apps
  -> create user/build/bin/*.bin
  -> os/build.rs generates link_app.S
  -> kernel embeds .bin files
  -> loader::load_apps copies them to app memory
  -> task manager creates tasks
  -> __switch + __restore + sret enters user app
```

Short summary:

```text
user/src/bin = applications/tests
user/lib.rs = tiny runtime and friendly API
user/console.rs = print wrapper
user/syscall.rs = ecall wrapper
os/syscall = real syscall implementation
make run = build user apps first, then embed them into kernel
```
