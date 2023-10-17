# Challenge 3 **硬件的可用物理内存范围的获取方法的理解**

问题为：如果 OS 无法提前知道当前硬件的可用物理内存范围，请问你有何办法让 OS 获取可用物理内存范围？

我们的ucore riscV写死了内存布局，用宏定义的方式把可用范围的开始地址和结束地址给出，由此我们可以从数值上直接知道可用的物理内存范围是怎样的。但实际情况中，无论是什么操作系统，都没办法提前知道哪些物理内存地址是可用的，哪些是不可用的。比如如果我们在8G内存的基础上在主板上新安装增加了一条8G内存条，如何获取新的可用物理内存范围呢？

对此，我们可以参考操作系统发展历程中，物理内存范围获取的方法变革：

## 80386时代
    

获取可用物理内存范围的过程需要经过CPU主动探测，每隔一定间隔向指向的地址位写入AA或55（10101010或01010101），观察读回的是否仍然是AA或55来判断某一些可能的位置是否可用。这不失为一种方法，但是十分缓慢。

  

## Linux x86的做法：

先在前面说明我们探究的结论：Linux x86下主要通过循环调用BIOS的**int 0x15中断**获取E820查询结果，即一系列的**地址范围描述符**，再通过查询结果**建立E820表**，其中包括每个内存区域的起始地址、大小和类型，供操作系统使用，进行正确的初始化内存管理。

 ### E820表
 
在系统boot的时候，kernel需要通过一些方法获得机器内存容量。有三种参数88H(只能探测最大64MB的内存)，E801H(得到内存容量)，E820H(获得memory map)，这个memory map被称为E820图。

E820内存表通常包括以下关键信息：

1. **内存地址范围**：每个条目描述了一个物理内存区域的起始地址和大小。这些区域可以包括RAM、保留区域、内存映射IO（MMIO）、ACPI数据、NVSRAM等。
    
2. **内存类型**：每个区域都有一个关联的内存类型，例如RAM、保留、ACPI数据、MMIO等。这有助于操作系统了解如何管理和分配这些内存区域。
    
3. **数量和顺序**：内存表中的条目数量和顺序取决于物理内存布局，通常按地址顺序排列。
    

如ubuntu64的内存容量获取，其打印结果为：（注释标注了大小）

```C
[    0.000000] e820: BIOS-provided physical RAM map:   
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009ebff] usable  //634kb
[    0.000000] BIOS-e820: [mem 0x000000000009ec00-0x000000000009ffff] reserved  //4kb
[    0.000000] BIOS-e820: [mem 0x00000000000dc000-0x00000000000fffff] reserved //143kb
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000bfecffff] usable  //3069MB
[    0.000000] BIOS-e820: [mem 0x00000000bfed0000-0x00000000bfefefff] ACPI data
[    0.000000] BIOS-e820: [mem 0x00000000bfeff000-0x00000000bfefffff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000bff00000-0x00000000bfffffff] usable  //1g
[    0.000000] BIOS-e820: [mem 0x00000000f0000000-0x00000000f7ffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec0ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffe0000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000043fffffff] usable
```

我们试图从ubuntu输出的表层逐层深入，探究linux是如何获取内存可用范围的。查询这段输出对应的linux源代码有如下段落：

```C
// linux/arch/x86/kernel/e820.c
void __init e820__memory_setup(void)
{
        char *who;

        /* This is a firmware interface ABI - make sure we don't break it: */
        BUILD_BUG_ON(sizeof(struct boot_e820_entry) != 20);

        who = x86_init.resources.memory_setup();

        memcpy(e820_table_kexec, e820_table, sizeof(*e820_table_kexec));
        memcpy(e820_table_firmware, e820_table, sizeof(*e820_table_firmware));

        pr_info("BIOS-provided physical RAM map:\n");
        e820__print_table(who);
}
```

who这个char类型指针的值为x86_init的函数 **.resources.memory_setup()** 的返回值，我们再去查看x86_init.c的源代码

```C
// linux/arch/x86/kernel/x86_init.c
struct x86_init_ops x86_init __initdata = {

        .resources = {
                .probe_roms                = probe_roms,
                .reserve_resources        = reserve_standard_io_resources,
                .memory_setup                = e820__memory_setup_default,
        },
        //....
}
```

发现函数指针调用的是**e820__memory_setup_default()** 这个函数。

```C
// linux/arch/x86/kernel/e820.c

/*
 * Pass the firmware (bootloader) E820 map to the kernel and process it:
 */
char *__init e820__memory_setup_default(void)
{
        char *who = "BIOS-e820";

        /*
         * Try to copy the BIOS-supplied E820-map.
         *
         * Otherwise fake a memory map; one section from 0k->640k,
         * the next section from 1mb->appropriate_mem_k
         */
        if (append_e820_table(boot_params.e820_table, boot_params.e820_entries) < 0) {
                u64 mem_size;

                /* Compare results from other methods and take the one that gives more RAM: */
                if (boot_params.alt_mem_k < boot_params.screen_info.ext_mem_k) {
                        mem_size = boot_params.screen_info.ext_mem_k;
                        who = "BIOS-88";
                } else {
                        mem_size = boot_params.alt_mem_k;
                        who = "BIOS-e801";
                }

                e820_table->nr_entries = 0;
                e820__range_add(0, LOWMEMSIZE(), E820_TYPE_RAM);
                e820__range_add(HIGH_MEMORY, mem_size << 10, E820_TYPE_RAM);
        }

        /* We just appended a lot of ranges, sanitize the table: */
        e820__update_table(e820_table);

        return who;
}
```

函数的语句含义大致如下：

- 首先，尝试从启动参数中的 `boot_params.e820_table` 和 `boot_params.e820_entries` **复制BIOS提供的E820内存映射表**。如果成功复制，它将使用这个表来初始化内存布局，并将 `who` 设置为 "BIOS-e820"。
    
- 如果无法复制BIOS提供的表，它会尝试通过其他方法估算内存布局。具体地，它会根据 `boot_params.alt_mem_k` 和 `boot_params.screen_info.ext_mem_k` 这两个变量的值来确定内存大小，并将 `who` 设置为相应的标识。
    
- 如果无法通过这两种方式确定内存布局，它将创建一个伪造内存布局，模拟内存分布。这个模拟的内存布局将包括两个区域：一个从物理地址0到640KB，另一个从物理地址1MB到一个特定值（`mem_size`）的内存，同样被标记为`E820_TYPE_RAM`，表示这部分内存也是可用的。如果使用伪造的内存映射表，则`who`变量的值将变为 "BIOS-88" 或 "BIOS-e801"，取决于哪个内存值更大。
    
- 接下来， `e820__range_add` 函数将这些模拟的内存区域添加到内存布局表 `e820_table` 中，并将这两个区域标记为RAM类型。
    
- 最后，调用 `e820__update_table` 函数来确保内存布局表的正确性。
    
    ###   从硬件获得e820表，int 0x15中断
    

从以上的分析可以看出，linux x86主要是通过主板提供的内存映射表来初始化内存布局的。最关键的就是从硬件读取e820表的结构，这个函数是**detect_memory_e820()**。

其大致逻辑含义是，把int 0x15放到一个do-while循环里，每次得到的一个内存段放到struct e820entry里，而struct e820entry的结构正是e820返回结果的结构！内核通过int 0x15中断遍历整个表，并把它保存到了boot_params.e820_map。

```C
// linux/arch/x86/boot/memory.c
static void detect_memory_e820(void)
{
        int count = 0;
        struct biosregs ireg, oreg;
        struct boot_e820_entry *desc = boot_params.e820_table;
        static struct boot_e820_entry buf; /* static so it is zeroed */

        initregs(&ireg);
        ireg.ax  = 0xe820;
        ireg.cx  = sizeof(buf);
        ireg.edx = SMAP;
        ireg.di  = (size_t)&buf;

        /*
         * Note: at least one BIOS is known which assumes that the
         * buffer pointed to by one e820 call is the same one as
         * the previous call, and only changes modified fields.  Therefore,
         * we use a temporary buffer and copy the results entry by entry.
         *
         * This routine deliberately does not try to account for
         * ACPI 3+ extended attributes.  This is because there are
         * BIOSes in the field which report zero for the valid bit for
         * all ranges, and we don't currently make any use of the
         * other attribute bits.  Revisit this if we see the extended
         * attribute bits deployed in a meaningful way in the future.
         */

        do {
                intcall(0x15, &ireg, &oreg);
                ireg.ebx = oreg.ebx; /* for next iteration... */

                /* BIOSes which terminate the chain with CF = 1 as opposed
                   to %ebx = 0 don't always report the SMAP signature on
                   the final, failing, probe. */
                if (oreg.eflags & X86_EFLAGS_CF)
                        break;

                /* Some BIOSes stop returning SMAP in the middle of
                   the search loop.  We don't know exactly how the BIOS
                   screwed up the map at that point, we might have a
                   partial map, the full map, or complete garbage, so
                   just return failure. */
                if (oreg.eax != SMAP) {
                        count = 0;
                        break;
                }

                *desc++ = buf;
                count++;
        } while (ireg.ebx && count < ARRAY_SIZE(boot_params.e820_table));

        boot_params.e820_entries = count;
}
```

这里获取到的 e820_table 里的数据是未经过整理的，linux 还会通过 setup_memory_map() 去整理这些数据，这里为避免冲淡主题，我们继续说明主要的int 0x15中断。

Int 0x15中断调用bios例程获得一个内存段的信息，根据上面的代码也可以看出，int 0x15中断需要传入一系列的寄存器并返回一系列寄存器，作为e820的调用参数。

从上面的代码中可以看出int 0x15中断的寄存器调用大致如下：

- eax：子功能编号，为0xe820（int 0x15 可以完成许多工作，主要由eax的值决定）
    
- edx：534D4150h(ascii字符”SMAP”)，签名，约定填”SMAP”
    
- ebx：每调用一次int $0x15，ebx会加1。当ebx为0表示所有内存块检测完毕。
    
- ecx：存放地址范围描述符的内存大小，至少要设置为20。[地址范围描述符共计20字节，格式是：内存块基地址(8 byte)+这块内存的大小(8 byte)+这块内存的类型(4 byte)]
    
- es:di：告诉BIOS要把地址描述符写到这个地址。
    

中断的返回值如下：

- CF标志位：若中断执行失败，则置为1。
    
- eax：值是534D4150h(“SMAP”)
    
- es:di：中断不改变该值，值与参数传入的值一致
    
- ebx：下一个中断描述符的计数值
    
- ecx：返回BIOS写到cs:di处的地址描述符的大小
    
- ah：若发生错误，表示错误码
    

再想深层探究BIOS的中断实现流程，就遇到了很大的阻碍，这是由于中断的具体代码是在计算机的BIOS固件中实现的，通常存储在计算机的ROM芯片中。因此我们无法直接查看这些代码。而对于虚拟机来说，VMware、VirtualBox等虚拟机管理程序会模拟计算机硬件，并负责处理虚拟机中的中断和访问虚拟化的BIOS，但这也是其专有实现，没有公开源码。因此我们的实验探究到此终止。

## Risc-V的做法：
    

Risc-V支持两种读取内存信息的方法，分别是读取内存内置信息和类似int 0x15的做法，int 0x15在前面2.部分已经详细叙述，这部分主要是由OpenSBI的sbi_query_memory()提供的，此处不再赘述。

第一种做法的基本想法是，为了避免每次读取并扫描的复杂，从内存角度，内存也可以将自己的可用物理内存等信息用一块只读的地方保存下来，每次操作系统读取这一部分，并做一些解析和计算，就可以得到内存布局的相关信息。（这种方式主要由硬件开发人员提供）

具体到Risc-V上，Device Tree是一个用于描述设备资源的树形数据结构。硬件开发人员按照源代码的标准编写相关描述串口、中断、主频、内存布局等的多种内存信息，由DT Compiler(Device Tree Compiler)编译成二进制程序，由openSBI传给OS，OS解析得到写入的这些信息。

但这并不是从操作系统层面给出的解决方式，而是从内存的层面给出的一种方法。

# 总结

到此，我们探究了80386上、linux x86上和Risc-V上获取硬件的可用物理内存范围的一些方法，从朴素到智能，解决这一问题的想法是多变的，这也说明一个工程问题没有唯一的标准答案，可以从多个角度和方面思考解决问题的办法。