---
title: "viewing file"
date: 2026-05-07 17:52:18
tags:
  - note
---

# viewing file
`cat`: print the whole file into terminal(concatenate the file and print on the standard output)
e.g.
```bash
cat file1 > file2
cat file1 file2 > combined
cat file1 file2 #print the two file,may be add more arguments
```

`tail` & `head`: output the last(head) part of the file 
e.g.
```bash
tail file1 #default 10 lines
tail -n 5 file #specify the lines
tail -c 5 file #specify the bytes
tail -f file.log # following a growing file live
```

`less`:
Not to read the file entirely and provide interactively reading or search.
```bash
Space      next page
  b          previous page
  j          down one line
  k          up one line
  /word      search forward
  n          next match
  N          previous match
  g          top of file
  G          bottom of file
  q          quit
```

# Searching
`grep` search text in a file
```bash
grep "Rust" file # search the lines with "Rust"
grep -n "Rust" file # with line number
grep -i "Rust" file # ignore the lower and upper case
grep -v "Rust" file # exclude matched lines

grep -R "Cargo" . # search "Cargo" recursively in current directory  could replace by the rg
```

`find`
Meaning: find files/directories by name, type, size, time, etc.
```bash
find . -name "*.log"
find . -type f
find . -type d
find . -size +100M
find . \( -name "Cargo.toml" -o -name "Makefile" -o -name "package.json" \) | sort
```

```text
.          start from current directory
-name      match filename
-type f    file
-type d    directory
-size      match file size
```

# pipe and redirection
`|`
Meaning: send output of one command into another command.
```bash
grep "ERROR" app.log | wc -l # find ERROR lines → count them
```

`>`
redirect output to a file,overwrite the old one or new
`>>`
redirect output to a file,append

# Text processing
`wc`
Meaning: word/line/byte count. 
```bash
wc file.txt #   88  207 2434 ass.cpp
wc -l file.txt    # line count
wc -w file.txt    # word count
wc -c file.txt    # byte count
```

`sort`
sort lines
```bash
sort -n file # numeric sort,compare according to string numeric values
sort -r file # reverse sort
```

`uniq`
remove the repeated adjacent lines(usually need to sort first)
```bash
sort file | uniq
sort file | uniq -c # count duplicate,print before the line
```

`cut`
data1.csv like:
```text
name,age,city
Tom,18,London
Jack,20,Paris
```

```bash
 cut -d ',' -f 1 data1.csv # -d ','    delimiter is comma
                            # -f 1      get first field
# name
# Tom
# Jack
```

`awk`
process text by columns and rules(for table-like text)
```bash
ps aux | awk 'print {$2, $11}' #print PID and command name
```

`sed`
stream editor,usually used for replacement.
```bash
sed 's/old/new/g' file.txt
```

`xargs`
turn input lines into command arguments
```bash
find . -name "*.rs" -print0 | xargs -0 grep "unsafe" # find Rust files → search unsafe inside them
```

# process and network
`ps`
show running processes. It is a snapshot, not live.

Common command:
```bash
ps aux
```

Example output:
```text
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.1 167284 11720 ?        Ss   10:00   0:01 /sbin/init
ope         2356  0.2  1.4 945000 82000 pts/0    Sl+  10:20   0:04 code
ope         2488  0.0  0.0  10580  4200 pts/1    R+   10:25   0:00 ps aux
```

Column meaning:
```text
USER       user who owns the process
PID        process id, used by kill
%CPU       CPU usage percentage
%MEM       memory usage percentage
VSZ        virtual memory size in KB
RSS        real physical memory used in KB
TTY        terminal connected to the process, ? means no terminal
STAT       process state
START      when the process started
TIME       total CPU time used
COMMAND    command that started the process
```

Common `STAT` values:
```text
R    running
S    sleeping
D    uninterruptible sleep, often waiting for disk or I/O
T    stopped
Z    zombie process
+    foreground process in a terminal
s    session leader
l    multi-threaded process
```

Useful pipelines:
```bash
ps aux | grep "ssh"
ps aux | sort -nr -k 3 | head
ps aux | sort -nr -k 4 | head
```

Meaning:
```text
sort -nr -k 3    sort by CPU usage, high to low
sort -nr -k 4    sort by memory usage, high to low
```

`top`
live process monitor
```bash
top
```

Example upper area:
```text
top - 10:30:01 up 2:15,  1 user,  load average: 0.08, 0.05, 0.01
Tasks: 154 total,   1 running, 153 sleeping,   0 stopped,   0 zombie
%Cpu(s):  2.0 us,  1.0 sy,  0.0 ni, 96.5 id,  0.5 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem :   7800.0 total,   3200.0 free,   2500.0 used,   2100.0 buff/cache
MiB Swap:   2048.0 total,   2048.0 free,      0.0 used.   5000.0 avail Mem
```

Upper area meaning:
```text
up                  how long the system has been running
users               logged-in users
load average        average runnable/waiting work in last 1, 5, 15 minutes
Tasks total         number of processes
running             processes currently running
sleeping            processes waiting for work or I/O
stopped             paused processes
zombie              ended processes still waiting for parent cleanup
us                  CPU time used by user programs
sy                  CPU time used by kernel/system
ni                  CPU time used by processes with changed nice value
id                  CPU idle time
wa                  CPU waiting for I/O
hi                  CPU handling hardware interrupts
si                  CPU handling software interrupts
st                  CPU stolen by virtual machine host
Mem total           total RAM
Mem free            unused RAM
Mem used            used RAM
buff/cache          memory used for buffers and cache
Swap total/free     swap space size and free space
avail Mem           memory available for new programs
```

Example process table:
```text
    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
   2356 ope       20   0  945000  82000  43000 S   2.0   1.0   0:04.12 code
   2488 ope       20   0   10580   4200   3300 R   0.3   0.0   0:00.01 top
```

Process table meaning:
```text
PID        process id
USER       user who owns the process
PR         priority
NI         nice value, lower usually means higher priority
VIRT       virtual memory used
RES        physical RAM used
SHR        shared memory
S          process state, like R running or S sleeping
%CPU       CPU usage
%MEM       memory usage
TIME+      total CPU time used
COMMAND    command name
```

```text
q    quit
k    kill process
P    sort by CPU
M    sort by memory
N    sort by PID
```

`ss`
show socket / ports
```bash
ss -tulnp
```

```text
-t    TCP
-u    UDP
-l    listening
-n    show numbers, not names
-p    show process
```

`lsof`
list open file(normal files,socket,devices)
```bash
lsof -i :8080
```
