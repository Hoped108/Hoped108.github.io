---
title: "rcore-ch3"
date: 2026-05-09 17:16:26
tags:
  - note
---

# state & file structure

loader.rs: loading the application

task.rs: execute and switch program

Without relocate mechanism,current application's address bases on the absolute destination.
Each application has there own address,so we need a build.py to specify the linker script respectively.It passes `-Ttext=<base_address + step * app_id`.This makes the linker place that app's .text section at the expected load address.After the build, linker.ld remains unchanged.

Each application needs to be loader on the memory with different address.The calculate formula: 
```rust
// os/src/loader.rs

 fn get_base_i(app_id: usize) -> usize {
     APP_BASE_ADDRESS + app_id * APP_SIZE_LIMIT // config.rs contain the const value
 }
 ```

 Different from the previous operation,after finishing the program,run_next_app function would jump to the application(with index)'s entrypoint and convert the stack into user stack.(Trap context save the content of epc register ,which store program starting address)

# task switch
 switch.S would switch the process stack(__switch function)
 ```S
.altmacro
.macro SAVE_SN n
    sd s\n, (\n+2)*8(a0)
.endm
.macro LOAD_SN n
    ld s\n, (\n+2)*8(a1)
.endm
    .section .text
    .globl __switch
__switch:
    # __switch(
    #     current_task_cx_ptr: *mut TaskContext,
    #     next_task_cx_ptr: *const TaskContext
    # )
    # save kernel stack of current task
    sd sp, 8(a0)
    # save ra & s0~s11 of current execution
    sd ra, 0(a0)
    .set n, 0
    .rept 12
        SAVE_SN %n
        .set n, n + 1
    .endr
    # restore ra & s0~s11 of next execution
    ld ra, 0(a1)
    .set n, 0
    .rept 12
        LOAD_SN %n
        .set n, n + 1
    .endr
    # restore kernel stack of next task
    ld sp, 8(a1)
    ret
```
Saves current kernel context and restores next task's kernel context.It saves/restores:
ra, sp, s0-s11(callee-saved registers)
This is enough for a simple context switch,as we only need to save the callee-saved registers and the return address.(not full user register saving,which is done in trap handling code)

# trap handling
When a trap happens,hardware automatically saves user registers into `TrapContext` on the kernel stack,then jumps to the trap entry point defined in `trap.S`.After handling the trap,`trap.S` calls `__restore` to restore user registers and return to user mode.
## trap.S::__restore()
Restores the app's saved registers from `TrapContext`,swaps back to the user stack, then executes `sret` to return to user mode.

## trap.S::__alltraps()
Entry point when user code traps into kernel.It saves user registers into `TrapContext`,then calls `rust_trap_handler()` to handle the trap in Rust code.After handling, it calls `__restore()` to restore user registers and return to user mode.

## mod.rs::trap_handler()
Decide why the trap happens,then call coresponding handler:
- syscall: call `syscall_handler()`
- timer interrupt: call `timer_handler()`
- Store/Page fault -> call `fault_handler()`
- IllegalInstruction -> kill current app
```rust
/// trap handler
#[no_mangle]
pub fn trap_handler(cx: &mut TrapContext) -> &mut TrapContext {
    let scause = scause::read(); // get trap cause
    let stval = stval::read(); // get extra value
                               // trace!("into {:?}", scause.cause());
    match scause.cause() {
        Trap::Exception(Exception::UserEnvCall) => {
            // jump to next instruction anyway
            cx.sepc += 4;
            record_current_syscall(cx.x[17]);
            // get system call return value
            cx.x[10] = syscall(cx.x[17], [cx.x[10], cx.x[11], cx.x[12]]) as usize;
        }
        Trap::Exception(Exception::StoreFault) | Trap::Exception(Exception::StorePageFault) => {
            println!("[kernel] PageFault in application, bad addr = {:#x}, bad instruction = {:#x}, kernel killed it.", stval, cx.sepc);
            exit_current_and_run_next();
        }
        Trap::Exception(Exception::IllegalInstruction) => {
            println!("[kernel] IllegalInstruction in application, kernel killed it.");
            exit_current_and_run_next();
        }
        Trap::Interrupt(Interrupt::SupervisorTimer) => {
            set_next_trigger();
            suspend_current_and_run_next();
        }
        _ => {
            panic!(
                "Unsupported trap {:?}, stval = {:#x}!",
                scause.cause(),
                stval
            );
        }
    }
    cx
}
```

# Task process

RustSBI/bootloader -> entry.asm -> rust_main -> load user apps -> create tasks -> switch to 
user mode -> traps/syscalls/timer return to kernel

os/src/main.rs kernel entry after assembly boot
- clear `.bss`
- init logging and heap
- init trap entry
- load user aps
- enable timer interrupt
- run first task

## task/mod.rs:
`TASK_MANAGER`
Global task manager instance,initialized in `main.rs` after loading user apps.It is created  lazily.It:
- reads app count from `loader::get_app_num()`
- creates one `TaskControlBlock` for each app 
- initializes them with `TaskContext::goto_restore()`
- marks each app as `Ready`

`TaskManager`
Main scheduler object.
```rust
pub struct TaskManager {
    /// total number of tasks
    num_app: usize,
    /// use inner value to get mutable access
    inner: UPSafeCell<TaskManagerInner>,
}
```
- `num_app`: total number of tasks
- `inner`: use inner value to get mutable access

`TaskManagerInner`
```rust
/// Inner of Task Manager
pub struct TaskManagerInner {
    /// task list
    tasks: [TaskControlBlock; MAX_APP_NUM],
    /// id of current `Running` task
    current_task: usize,
}
```
Real mutable scheduler state.
`tasks`: all app task records.
`current_task`: index of currently running task.

`run_first_task()`
start task 0.It marks task 0 as `Running` and call `__switch` to jumps into task0's saved context.After this,kernel enters user mode through `__restore` and starts executing user code.
```rust
fn run_first_task(&self) -> ! {
    let mut inner: RefMut<'_,TaskManagerInner> = self.inner.exclusive_access();
    let task0: &mut TaskControlBlock = &mut inner.tasks[0];
    task0.task_status = TaskStatus::Running;
    let next_task_cs_ptr = &task0.task_cx as *const TaskContext;
    drop(inner);
    let mut _unused = TaskContext::zero_init();
    //before this, we should drop local variables that must be dropped manually
    unsafe {
        __switch(&mut _unused as *mut TaskContext, next_task_cs_ptr);
    }
    panic!("Unreachable in run_first_task!");
}
```

`mark_current_suspended()`
Changes current task status:
Running -> Ready
Used when the task calls `yield` syscall,which means it is willing to give up the CPU to other tasks`yield` or timer interrupt happens.
```rust
fn mark_current_suspended(&self) {
    let mut inner: RefMut<'_,TaskManagerInner> = self.inner.exclusive_access();
    inner.tasks[inner.current_task].task_status = TaskStatus::Ready;
}
```

`mark_current_exited()`
Changes current task status:
Running -> Exited
Used when the task finishes execution.
```rust
fn mark_current_exited(&self) {
    let mut inner: RefMut<'_,TaskManagerInner> = self.inner.exclusive_access();
    inner.tasks[inner.current_task].task_status = TaskStatus::Exited;
}
```

`record_current_syscall(syscall_id: usize)`
Return how many times the current task has called that syscall.

`find_next_task()`
Finds the next `Ready` task after current task.
It use simple round-robin order: cur+1,cur+2,...
```rust
fn find_next_task(&self) -> Option<usize> {
    let inner = self.inner.exclusive_access();
    let current = inner.current_task;
    (current + 1..current + self.num_app + 1)
    .map(|id| id % self.num_app)
    .find(|&id| inner.tasks[id].task_status == TaskStatus::Ready)
}
```

`run_next_task()`
Switches to the next `Ready` task.
steps:
- find next task index with `find_next_task()`
- mark next task as `Running`
- update current task index
- call `__switch` to switch to next task's context
```rust
fn run_next_task(&self) {
    if let Some(next:usize) = self.find_next_task() {
        let mut inner: RefMut<'_,TaskManagerInner> = self.inner.exclusive_access();
        let current = inner.current_task;
        inner.tasks[next].task_status = TaskStatus::Running;
        inner.current_task = next;
        //get current and next task context pointer before dropping inner
        let current_task_cs_ptr = &mut inner.tasks[current].task_cx as *mut TaskContext;
        let next_task_cs_ptr = &inner.tasks[next].task_cx as *const TaskContext;
        drop(inner);
        //before this, we should drop local variables that must be dropped manually
        unsafe {
            __switch(current_task_cs_ptr, next_task_cs_ptr);
        }  
        //go back to user mode
    } else {
        panic!("No more task to run!");// all Tasks are Exited
    }
}
```

other functions like `pub fn run_first_task()`,just a private wrapper,which called TASK_MANAGER.run_first_task() in main.rs.

## task/task.rs:
**Each task has a TaskControlBlock**
Each task has:
- TaskContext: kernel scheduling context
- TaskStatus: Ready / Running / Exited
- syscall_times: syscall counter array

```rust
/// The task control block (TCB) of a task.
#[derive(Copy, Clone)]
pub struct TaskControlBlock {
    /// The task status in it's lifecycle
    pub task_status: TaskStatus,
    /// The task context
    pub task_cx: TaskContext,
    /// Per-task syscall counters indexed by syscall id.
    pub syscall_times: [usize; MAX_SYSCALL_NUM],
}

/// The status of a task
#[derive(Copy, Clone, PartialEq)]
pub enum TaskStatus {
    /// uninitialized
    UnInit,
    /// ready to run
    Ready,
    /// running
    Running,
    /// exited
    Exited,
}
```

## task/context.rs:
Sets each task's `ra` to `__restore`.So when the scheduler switches to a task for the first time,it jumps to trap restore code,which finally executes `sret` into user mode.
```rust
//! Implementation of [`TaskContext`]

#[derive(Copy, Clone)]
#[repr(C)]
/// task context structure containing some registers
pub struct TaskContext {
    /// Ret position after task switching
    ra: usize,
    /// Stack pointer
    sp: usize,
    /// s0-11 register, callee saved
    s: [usize; 12],
}

impl TaskContext {
    /// Create a new empty task context
    pub fn zero_init() -> Self {
        Self {
            ra: 0,
            sp: 0,
            s: [0; 12],
        }
    }
    /// Create a new task context with a trap return addr and a kernel stack pointer
    pub fn goto_restore(kstack_ptr: usize) -> Self {
        extern "C" {
            fn __restore();
        }
        Self {
            ra: __restore as usize,
            sp: kstack_ptr,
            s: [0; 12],
        }
    }
}
```

# Time-sharing multitasking
When a task calls `yield` syscall or timer interrupt happens, it is willing to give up the CPU to other tasks. The kernel marks it as `Ready` and calls `run_next_task()` to switch to another `Ready` task.
But the application may never call `yield` or trigger timer interrupt,which means it will never give up the CPU.It is belonged to the `Cooperative Scheduling`,the opposite of `Preemptive Scheduling`.To implement preemptive scheduling, we need to trigger timer interrupt periodically,which is done in `timer_handler()` by calling `set_next_trigger()`.This makes the kernel switch to another task at regular intervals,even if the current task never calls `yield` or triggers timer interrupt by itself.

**For simplicity, we only implement cooperative scheduling with `Round-Robin`**
In RISC-V,there have a 64bits CSR `mtime` saves the passing clock cycle.The `mtimecmp` store the relative time,once the `mtime` exceeds the `mtimecmp`,would trigger interrupt.

src/timer.rs
```rust
use riscv::register::time;

pub fn get_timer() -> usize{
    time::read()
}

use crate::config::CLOCK_FREQ;
const TICKS_PER_SEC: usize = 100;

pub fn set_next_trigger() {
    set_timer(get_time() + CLOCK_FREQ / TICKS_PER_SEC);
}
```

We can control the `mtimecmp` to set when to trigger interrupt.
```rust
const SBI_SET_TIMER: usize = 0;

pub fn set_timer(timer: usize) {
    sbi_call(SBI_SET_TIMER, timer,0, 0);
}
```

## statistical time
```rust
/os/src/timer.rs

const MICRO_PER_SEC: usize = 1_000_000;

pub fn get_time_us() -> usize {
    time::read() / (CLOCK_FREQ / MICRO_PER_SEC)
}
```
