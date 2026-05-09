---
title: "PageTable"
date: 2026-05-06 11:15:37
tags:
  - note
---

# page table

Divide the physical memory into fixed-size page,could deal with the problems in using segmentation(Fragmentation and hard to alloc).

Each physical page frame store the data,and the virtual address mapping to the corresponding pa.
Actually, the program(process) just sees the virtual page in logical.

And page table builds the mapping work,and store in certain page frame.

Page table contains the page table entries, which specifies the mapping relationship and other flags,like PTE_V,PTE_R and so on.There have a PTE_V means that the specified PA is valid or allocated.The VA is split into VPN parts and offset. Each VPN part indexes one level of the page table. Non-leaf PTEs give the PPN of the next page table, and the final leaf PTE gives the PPN of the physical page. Then the MMU combines that PPN with the unchanged offset to get the PA.

Building a single level page table means each process has a huge memory for page table, which is a waste for those unused memory(single level page table is a linear array).So we can use multiple page table,which is a tree structure.High level page table just like a directory for low level,and the unallocated or unused one would not assign.

Tips: left shift the num may equal to multiply powers of two
      right shift the num equal to divide powers of two 
 
# va to pa(translate)
MMU,Memory Management Unit,a piece of hardware inside or near the CPU,would take the translation and checking permission  tasks
Take the SV39 as example:

first: define the const var

```rust
pub const PAGE_SIZE: usize = 4096;
pub const PT_ENTRIES: usize = 512;

//PTE flags
pub const PTE_V: u64 = 1 << 0;
pub const PTE_R: u64 = 1 << 1;
pub const PTE_W: u64 = 1 << 2;
pub const PTE_X: u64 = 1 << 3;

const PPN_SHIFT: u32 = 10;
```

second: set the struct
```rust
pub struct PageTableNode {
    pub entries: [u64; PT_ENTRIES],
}

// omit the impl like new , default

pub struct Sv39PageTable {
    nodes: HashMap<u64, PageTableNode>,
    pub root_ppn: u64,
    next_ppn: u64,
}

#[derive(Debug, PartialEq)]
pub enum TranslateResult {
    Ok(u64),
    PageFault,
}
```

third: build translate function
Tips:
```
 PTE = [ PPN ][ flags ]
        ^^^^^   ^^^^^^^
                low 10 bits
```
So need right shift PPN_SHIFT

```rust
pub fn translate(&self, va: u64) -> TranslateResult{
    let mut ppn = self.root_ppn;

    for level in (0..=2).rev() {
        let idx = (va >> 12) & 0x1ff;
        
        let node = match self.nodes.get(&ppn) {
            Some(node) => node,
            None => return TranslateResult::PageFault;
        }

        let pte = node.entries[idx];

        if pte & PTE_V == 0 { //check the PTE_V
            return Translate::PageFault;
        }

        // left shift 12, because the page_size = 4096(12 powers of two)
        if pte & (PTE_R | PTE_W | PTE_X) {
            let pte_ppn = pte >> PPN_SHIFT // get page number
            let offset = va & (1 << (12 + level * 9) - 1);
            let pa = (pte_ppn << 12) | offset;

            return TranslateResult::Ok(pa);
        }

        if level == 0 {
            return TranslateResult::Ok(pa);
        }

        ppn = pte >> PPN_SHIFT;
    }
    TranslateResult::PageFault
}
```

# Summarize
VA
→ extract VPN[level]
→ find PTE
→ check V
→ if R/W/X != 0: leaf, build PA
→ else: go to next-level page table
→ if invalid: page fault

# TLB
Actually,it is slow to check the page table each memory access.(It need to translate the va into pa).So we need a hardware support like cache.Then TLB was born.(Translation-Lookaside Buffer)It just a mapping from vpn to ppn with some flags.

## TLB entries:
```text
 ┌───────┬──────┬──────┬───────┬───────┐
 │ valid │ asid │ vpn  │  ppn  │ flags │
 └───────┴──────┴──────┴───────┴───────┘
 ```

 Tips:
This valid bits is different from the PTE_V,it means this TLB entry is valid or not;PTE_V means this page were not allocated by the program or process.The normally running program shouldn't access this address,otherwise,the program would trap into the os,and os kill this program.
This valid bits normally used in context switch,which guarantee the other program would not use the previous address mapping.
By the way,the protection about the context switch also contain the asid bits,which figure the certain process(address space identifier).Different from the PID(32 bits),asid just 8 bits while you can regard it as PID.

## Translation
va & asid
-> va => vpn with asid to find the TLB
```rust
    pub fn lookup(&mut self, vpn: u64, asid: u16) -> Option<u64> {
        // TODO: 遍历 self.entries，查找 valid && vpn 匹配 && asid 匹配的条目
        // 命中：self.stats.hits += 1，返回 Some(entry.ppn)
        // 未命中：self.stats.misses += 1，返回 None
        for entry in &self.entries {
            if entry.valid && entry.vpn == vpn && entry.asid == asid{
                self.stats.hits += 1;
                return Some(entry.ppn);
            }
        }
        self.stats.misses += 1;
        None
    }
```
-> not found in the TLB then walk the page table
-> insert the new mapping rule int the TLB
-> not found in the page table => return the page fault
```rust
    pub fn translate(&mut self, vpn: u64) -> Option<u64> {
        // TODO: 实现 TLB + 页表的二级查找
        if let Some(ppn) = self.tlb.lookup(vpn,self.current_asid) {
            return Some(ppn);
        }
        for (asid,ppn_) in &self.page_table {
            if *asid == self.current_asid && ppn_.vpn == vpn {
                self.tlb.insert(vpn,ppn_.ppn,*asid,ppn_.flags);
                return Some(ppn_.ppn);
            }
        }
        None
    }
```

## Flush
The new mapping rule comes into the TLB,while the old one need to be flushed.Setting the durational time for the mapping is the key to clear the useless one in the LRU(least-recently-used),while the another idea is random replacement.
