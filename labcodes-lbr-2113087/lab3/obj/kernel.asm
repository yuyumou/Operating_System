
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	0000a517          	auipc	a0,0xa
ffffffffc020003a:	00a50513          	addi	a0,a0,10 # ffffffffc020a040 <edata>
ffffffffc020003e:	00011617          	auipc	a2,0x11
ffffffffc0200042:	55a60613          	addi	a2,a2,1370 # ffffffffc0211598 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	102040ef          	jal	ra,ffffffffc0204150 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00004597          	auipc	a1,0x4
ffffffffc0200056:	5de58593          	addi	a1,a1,1502 # ffffffffc0204630 <etext>
ffffffffc020005a:	00004517          	auipc	a0,0x4
ffffffffc020005e:	5f650513          	addi	a0,a0,1526 # ffffffffc0204650 <etext+0x20>
ffffffffc0200062:	05c000ef          	jal	ra,ffffffffc02000be <cprintf>

    print_kerninfo();
ffffffffc0200066:	100000ef          	jal	ra,ffffffffc0200166 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	36a010ef          	jal	ra,ffffffffc02013d4 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006e:	504000ef          	jal	ra,ffffffffc0200572 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200072:	238020ef          	jal	ra,ffffffffc02022aa <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200076:	35e000ef          	jal	ra,ffffffffc02003d4 <ide_init>
    swap_init();                // init swap
ffffffffc020007a:	29d020ef          	jal	ra,ffffffffc0202b16 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007e:	3ae000ef          	jal	ra,ffffffffc020042c <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc0200082:	a001                	j	ffffffffc0200082 <kern_init+0x4c>

ffffffffc0200084 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200084:	1141                	addi	sp,sp,-16
ffffffffc0200086:	e022                	sd	s0,0(sp)
ffffffffc0200088:	e406                	sd	ra,8(sp)
ffffffffc020008a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020008c:	3f6000ef          	jal	ra,ffffffffc0200482 <cons_putc>
    (*cnt) ++;
ffffffffc0200090:	401c                	lw	a5,0(s0)
}
ffffffffc0200092:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200094:	2785                	addiw	a5,a5,1
ffffffffc0200096:	c01c                	sw	a5,0(s0)
}
ffffffffc0200098:	6402                	ld	s0,0(sp)
ffffffffc020009a:	0141                	addi	sp,sp,16
ffffffffc020009c:	8082                	ret

ffffffffc020009e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	86ae                	mv	a3,a1
ffffffffc02000a2:	862a                	mv	a2,a0
ffffffffc02000a4:	006c                	addi	a1,sp,12
ffffffffc02000a6:	00000517          	auipc	a0,0x0
ffffffffc02000aa:	fde50513          	addi	a0,a0,-34 # ffffffffc0200084 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ae:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000b0:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	134040ef          	jal	ra,ffffffffc02041e6 <vprintfmt>
    return cnt;
}
ffffffffc02000b6:	60e2                	ld	ra,24(sp)
ffffffffc02000b8:	4532                	lw	a0,12(sp)
ffffffffc02000ba:	6105                	addi	sp,sp,32
ffffffffc02000bc:	8082                	ret

ffffffffc02000be <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000be:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000c0:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c4:	f42e                	sd	a1,40(sp)
ffffffffc02000c6:	f832                	sd	a2,48(sp)
ffffffffc02000c8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ca:	862a                	mv	a2,a0
ffffffffc02000cc:	004c                	addi	a1,sp,4
ffffffffc02000ce:	00000517          	auipc	a0,0x0
ffffffffc02000d2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200084 <cputch>
ffffffffc02000d6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d8:	ec06                	sd	ra,24(sp)
ffffffffc02000da:	e0ba                	sd	a4,64(sp)
ffffffffc02000dc:	e4be                	sd	a5,72(sp)
ffffffffc02000de:	e8c2                	sd	a6,80(sp)
ffffffffc02000e0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e6:	100040ef          	jal	ra,ffffffffc02041e6 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000ea:	60e2                	ld	ra,24(sp)
ffffffffc02000ec:	4512                	lw	a0,4(sp)
ffffffffc02000ee:	6125                	addi	sp,sp,96
ffffffffc02000f0:	8082                	ret

ffffffffc02000f2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f2:	3900006f          	j	ffffffffc0200482 <cons_putc>

ffffffffc02000f6 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f6:	1141                	addi	sp,sp,-16
ffffffffc02000f8:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000fa:	3be000ef          	jal	ra,ffffffffc02004b8 <cons_getc>
ffffffffc02000fe:	dd75                	beqz	a0,ffffffffc02000fa <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200100:	60a2                	ld	ra,8(sp)
ffffffffc0200102:	0141                	addi	sp,sp,16
ffffffffc0200104:	8082                	ret

ffffffffc0200106 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200106:	00011317          	auipc	t1,0x11
ffffffffc020010a:	33a30313          	addi	t1,t1,826 # ffffffffc0211440 <is_panic>
ffffffffc020010e:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200112:	715d                	addi	sp,sp,-80
ffffffffc0200114:	ec06                	sd	ra,24(sp)
ffffffffc0200116:	e822                	sd	s0,16(sp)
ffffffffc0200118:	f436                	sd	a3,40(sp)
ffffffffc020011a:	f83a                	sd	a4,48(sp)
ffffffffc020011c:	fc3e                	sd	a5,56(sp)
ffffffffc020011e:	e0c2                	sd	a6,64(sp)
ffffffffc0200120:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200122:	02031c63          	bnez	t1,ffffffffc020015a <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200126:	4785                	li	a5,1
ffffffffc0200128:	8432                	mv	s0,a2
ffffffffc020012a:	00011717          	auipc	a4,0x11
ffffffffc020012e:	30f72b23          	sw	a5,790(a4) # ffffffffc0211440 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200132:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc0200134:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200136:	85aa                	mv	a1,a0
ffffffffc0200138:	00004517          	auipc	a0,0x4
ffffffffc020013c:	52050513          	addi	a0,a0,1312 # ffffffffc0204658 <etext+0x28>
    va_start(ap, fmt);
ffffffffc0200140:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200142:	f7dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200146:	65a2                	ld	a1,8(sp)
ffffffffc0200148:	8522                	mv	a0,s0
ffffffffc020014a:	f55ff0ef          	jal	ra,ffffffffc020009e <vcprintf>
    cprintf("\n");
ffffffffc020014e:	00005517          	auipc	a0,0x5
ffffffffc0200152:	50a50513          	addi	a0,a0,1290 # ffffffffc0205658 <commands+0xee0>
ffffffffc0200156:	f69ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc020015a:	3a0000ef          	jal	ra,ffffffffc02004fa <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020015e:	4501                	li	a0,0
ffffffffc0200160:	132000ef          	jal	ra,ffffffffc0200292 <kmonitor>
ffffffffc0200164:	bfed                	j	ffffffffc020015e <__panic+0x58>

ffffffffc0200166 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200166:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200168:	00004517          	auipc	a0,0x4
ffffffffc020016c:	54050513          	addi	a0,a0,1344 # ffffffffc02046a8 <etext+0x78>
void print_kerninfo(void) {
ffffffffc0200170:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200172:	f4dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200176:	00000597          	auipc	a1,0x0
ffffffffc020017a:	ec058593          	addi	a1,a1,-320 # ffffffffc0200036 <kern_init>
ffffffffc020017e:	00004517          	auipc	a0,0x4
ffffffffc0200182:	54a50513          	addi	a0,a0,1354 # ffffffffc02046c8 <etext+0x98>
ffffffffc0200186:	f39ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020018a:	00004597          	auipc	a1,0x4
ffffffffc020018e:	4a658593          	addi	a1,a1,1190 # ffffffffc0204630 <etext>
ffffffffc0200192:	00004517          	auipc	a0,0x4
ffffffffc0200196:	55650513          	addi	a0,a0,1366 # ffffffffc02046e8 <etext+0xb8>
ffffffffc020019a:	f25ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020019e:	0000a597          	auipc	a1,0xa
ffffffffc02001a2:	ea258593          	addi	a1,a1,-350 # ffffffffc020a040 <edata>
ffffffffc02001a6:	00004517          	auipc	a0,0x4
ffffffffc02001aa:	56250513          	addi	a0,a0,1378 # ffffffffc0204708 <etext+0xd8>
ffffffffc02001ae:	f11ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc02001b2:	00011597          	auipc	a1,0x11
ffffffffc02001b6:	3e658593          	addi	a1,a1,998 # ffffffffc0211598 <end>
ffffffffc02001ba:	00004517          	auipc	a0,0x4
ffffffffc02001be:	56e50513          	addi	a0,a0,1390 # ffffffffc0204728 <etext+0xf8>
ffffffffc02001c2:	efdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001c6:	00011597          	auipc	a1,0x11
ffffffffc02001ca:	7d158593          	addi	a1,a1,2001 # ffffffffc0211997 <end+0x3ff>
ffffffffc02001ce:	00000797          	auipc	a5,0x0
ffffffffc02001d2:	e6878793          	addi	a5,a5,-408 # ffffffffc0200036 <kern_init>
ffffffffc02001d6:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001da:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001de:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001e0:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001e4:	95be                	add	a1,a1,a5
ffffffffc02001e6:	85a9                	srai	a1,a1,0xa
ffffffffc02001e8:	00004517          	auipc	a0,0x4
ffffffffc02001ec:	56050513          	addi	a0,a0,1376 # ffffffffc0204748 <etext+0x118>
}
ffffffffc02001f0:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001f2:	ecdff06f          	j	ffffffffc02000be <cprintf>

ffffffffc02001f6 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001f6:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001f8:	00004617          	auipc	a2,0x4
ffffffffc02001fc:	48060613          	addi	a2,a2,1152 # ffffffffc0204678 <etext+0x48>
ffffffffc0200200:	04e00593          	li	a1,78
ffffffffc0200204:	00004517          	auipc	a0,0x4
ffffffffc0200208:	48c50513          	addi	a0,a0,1164 # ffffffffc0204690 <etext+0x60>
void print_stackframe(void) {
ffffffffc020020c:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020020e:	ef9ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200212 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200212:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200214:	00004617          	auipc	a2,0x4
ffffffffc0200218:	63c60613          	addi	a2,a2,1596 # ffffffffc0204850 <commands+0xd8>
ffffffffc020021c:	00004597          	auipc	a1,0x4
ffffffffc0200220:	65458593          	addi	a1,a1,1620 # ffffffffc0204870 <commands+0xf8>
ffffffffc0200224:	00004517          	auipc	a0,0x4
ffffffffc0200228:	65450513          	addi	a0,a0,1620 # ffffffffc0204878 <commands+0x100>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020022c:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020022e:	e91ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200232:	00004617          	auipc	a2,0x4
ffffffffc0200236:	65660613          	addi	a2,a2,1622 # ffffffffc0204888 <commands+0x110>
ffffffffc020023a:	00004597          	auipc	a1,0x4
ffffffffc020023e:	67658593          	addi	a1,a1,1654 # ffffffffc02048b0 <commands+0x138>
ffffffffc0200242:	00004517          	auipc	a0,0x4
ffffffffc0200246:	63650513          	addi	a0,a0,1590 # ffffffffc0204878 <commands+0x100>
ffffffffc020024a:	e75ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020024e:	00004617          	auipc	a2,0x4
ffffffffc0200252:	67260613          	addi	a2,a2,1650 # ffffffffc02048c0 <commands+0x148>
ffffffffc0200256:	00004597          	auipc	a1,0x4
ffffffffc020025a:	68a58593          	addi	a1,a1,1674 # ffffffffc02048e0 <commands+0x168>
ffffffffc020025e:	00004517          	auipc	a0,0x4
ffffffffc0200262:	61a50513          	addi	a0,a0,1562 # ffffffffc0204878 <commands+0x100>
ffffffffc0200266:	e59ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    }
    return 0;
}
ffffffffc020026a:	60a2                	ld	ra,8(sp)
ffffffffc020026c:	4501                	li	a0,0
ffffffffc020026e:	0141                	addi	sp,sp,16
ffffffffc0200270:	8082                	ret

ffffffffc0200272 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200272:	1141                	addi	sp,sp,-16
ffffffffc0200274:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200276:	ef1ff0ef          	jal	ra,ffffffffc0200166 <print_kerninfo>
    return 0;
}
ffffffffc020027a:	60a2                	ld	ra,8(sp)
ffffffffc020027c:	4501                	li	a0,0
ffffffffc020027e:	0141                	addi	sp,sp,16
ffffffffc0200280:	8082                	ret

ffffffffc0200282 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200282:	1141                	addi	sp,sp,-16
ffffffffc0200284:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200286:	f71ff0ef          	jal	ra,ffffffffc02001f6 <print_stackframe>
    return 0;
}
ffffffffc020028a:	60a2                	ld	ra,8(sp)
ffffffffc020028c:	4501                	li	a0,0
ffffffffc020028e:	0141                	addi	sp,sp,16
ffffffffc0200290:	8082                	ret

ffffffffc0200292 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200292:	7115                	addi	sp,sp,-224
ffffffffc0200294:	e962                	sd	s8,144(sp)
ffffffffc0200296:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200298:	00004517          	auipc	a0,0x4
ffffffffc020029c:	52850513          	addi	a0,a0,1320 # ffffffffc02047c0 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc02002a0:	ed86                	sd	ra,216(sp)
ffffffffc02002a2:	e9a2                	sd	s0,208(sp)
ffffffffc02002a4:	e5a6                	sd	s1,200(sp)
ffffffffc02002a6:	e1ca                	sd	s2,192(sp)
ffffffffc02002a8:	fd4e                	sd	s3,184(sp)
ffffffffc02002aa:	f952                	sd	s4,176(sp)
ffffffffc02002ac:	f556                	sd	s5,168(sp)
ffffffffc02002ae:	f15a                	sd	s6,160(sp)
ffffffffc02002b0:	ed5e                	sd	s7,152(sp)
ffffffffc02002b2:	e566                	sd	s9,136(sp)
ffffffffc02002b4:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002b6:	e09ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002ba:	00004517          	auipc	a0,0x4
ffffffffc02002be:	52e50513          	addi	a0,a0,1326 # ffffffffc02047e8 <commands+0x70>
ffffffffc02002c2:	dfdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    if (tf != NULL) {
ffffffffc02002c6:	000c0563          	beqz	s8,ffffffffc02002d0 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002ca:	8562                	mv	a0,s8
ffffffffc02002cc:	492000ef          	jal	ra,ffffffffc020075e <print_trapframe>
ffffffffc02002d0:	00004c97          	auipc	s9,0x4
ffffffffc02002d4:	4a8c8c93          	addi	s9,s9,1192 # ffffffffc0204778 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc02002d8:	00006997          	auipc	s3,0x6
ffffffffc02002dc:	b8098993          	addi	s3,s3,-1152 # ffffffffc0205e58 <commands+0x16e0>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e0:	00004917          	auipc	s2,0x4
ffffffffc02002e4:	53090913          	addi	s2,s2,1328 # ffffffffc0204810 <commands+0x98>
        if (argc == MAXARGS - 1) {
ffffffffc02002e8:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002ea:	00004b17          	auipc	s6,0x4
ffffffffc02002ee:	52eb0b13          	addi	s6,s6,1326 # ffffffffc0204818 <commands+0xa0>
    if (argc == 0) {
ffffffffc02002f2:	00004a97          	auipc	s5,0x4
ffffffffc02002f6:	57ea8a93          	addi	s5,s5,1406 # ffffffffc0204870 <commands+0xf8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	4b8d                	li	s7,3
        if ((buf = readline("")) != NULL) {
ffffffffc02002fc:	854e                	mv	a0,s3
ffffffffc02002fe:	274040ef          	jal	ra,ffffffffc0204572 <readline>
ffffffffc0200302:	842a                	mv	s0,a0
ffffffffc0200304:	dd65                	beqz	a0,ffffffffc02002fc <kmonitor+0x6a>
ffffffffc0200306:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc020030a:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020030c:	c999                	beqz	a1,ffffffffc0200322 <kmonitor+0x90>
ffffffffc020030e:	854a                	mv	a0,s2
ffffffffc0200310:	623030ef          	jal	ra,ffffffffc0204132 <strchr>
ffffffffc0200314:	c925                	beqz	a0,ffffffffc0200384 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc0200316:	00144583          	lbu	a1,1(s0)
ffffffffc020031a:	00040023          	sb	zero,0(s0)
ffffffffc020031e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200320:	f5fd                	bnez	a1,ffffffffc020030e <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc0200322:	dce9                	beqz	s1,ffffffffc02002fc <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200324:	6582                	ld	a1,0(sp)
ffffffffc0200326:	00004d17          	auipc	s10,0x4
ffffffffc020032a:	452d0d13          	addi	s10,s10,1106 # ffffffffc0204778 <commands>
    if (argc == 0) {
ffffffffc020032e:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200330:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200332:	0d61                	addi	s10,s10,24
ffffffffc0200334:	5d5030ef          	jal	ra,ffffffffc0204108 <strcmp>
ffffffffc0200338:	c919                	beqz	a0,ffffffffc020034e <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020033a:	2405                	addiw	s0,s0,1
ffffffffc020033c:	09740463          	beq	s0,s7,ffffffffc02003c4 <kmonitor+0x132>
ffffffffc0200340:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200344:	6582                	ld	a1,0(sp)
ffffffffc0200346:	0d61                	addi	s10,s10,24
ffffffffc0200348:	5c1030ef          	jal	ra,ffffffffc0204108 <strcmp>
ffffffffc020034c:	f57d                	bnez	a0,ffffffffc020033a <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020034e:	00141793          	slli	a5,s0,0x1
ffffffffc0200352:	97a2                	add	a5,a5,s0
ffffffffc0200354:	078e                	slli	a5,a5,0x3
ffffffffc0200356:	97e6                	add	a5,a5,s9
ffffffffc0200358:	6b9c                	ld	a5,16(a5)
ffffffffc020035a:	8662                	mv	a2,s8
ffffffffc020035c:	002c                	addi	a1,sp,8
ffffffffc020035e:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200362:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200364:	f8055ce3          	bgez	a0,ffffffffc02002fc <kmonitor+0x6a>
}
ffffffffc0200368:	60ee                	ld	ra,216(sp)
ffffffffc020036a:	644e                	ld	s0,208(sp)
ffffffffc020036c:	64ae                	ld	s1,200(sp)
ffffffffc020036e:	690e                	ld	s2,192(sp)
ffffffffc0200370:	79ea                	ld	s3,184(sp)
ffffffffc0200372:	7a4a                	ld	s4,176(sp)
ffffffffc0200374:	7aaa                	ld	s5,168(sp)
ffffffffc0200376:	7b0a                	ld	s6,160(sp)
ffffffffc0200378:	6bea                	ld	s7,152(sp)
ffffffffc020037a:	6c4a                	ld	s8,144(sp)
ffffffffc020037c:	6caa                	ld	s9,136(sp)
ffffffffc020037e:	6d0a                	ld	s10,128(sp)
ffffffffc0200380:	612d                	addi	sp,sp,224
ffffffffc0200382:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200384:	00044783          	lbu	a5,0(s0)
ffffffffc0200388:	dfc9                	beqz	a5,ffffffffc0200322 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc020038a:	03448863          	beq	s1,s4,ffffffffc02003ba <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc020038e:	00349793          	slli	a5,s1,0x3
ffffffffc0200392:	0118                	addi	a4,sp,128
ffffffffc0200394:	97ba                	add	a5,a5,a4
ffffffffc0200396:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020039a:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020039e:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003a0:	e591                	bnez	a1,ffffffffc02003ac <kmonitor+0x11a>
ffffffffc02003a2:	b749                	j	ffffffffc0200324 <kmonitor+0x92>
            buf ++;
ffffffffc02003a4:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003a6:	00044583          	lbu	a1,0(s0)
ffffffffc02003aa:	ddad                	beqz	a1,ffffffffc0200324 <kmonitor+0x92>
ffffffffc02003ac:	854a                	mv	a0,s2
ffffffffc02003ae:	585030ef          	jal	ra,ffffffffc0204132 <strchr>
ffffffffc02003b2:	d96d                	beqz	a0,ffffffffc02003a4 <kmonitor+0x112>
ffffffffc02003b4:	00044583          	lbu	a1,0(s0)
ffffffffc02003b8:	bf91                	j	ffffffffc020030c <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003ba:	45c1                	li	a1,16
ffffffffc02003bc:	855a                	mv	a0,s6
ffffffffc02003be:	d01ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02003c2:	b7f1                	j	ffffffffc020038e <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003c4:	6582                	ld	a1,0(sp)
ffffffffc02003c6:	00004517          	auipc	a0,0x4
ffffffffc02003ca:	47250513          	addi	a0,a0,1138 # ffffffffc0204838 <commands+0xc0>
ffffffffc02003ce:	cf1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    return 0;
ffffffffc02003d2:	b72d                	j	ffffffffc02002fc <kmonitor+0x6a>

ffffffffc02003d4 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}//该函数被定义为空，即不执行任何操作。通常，这个函数可以用于初始化IDE硬盘。
ffffffffc02003d4:	8082                	ret

ffffffffc02003d6 <ide_device_valid>:
#define MAX_DISK_NSECS 56  //表示每个IDE硬盘最多有56个扇区
static char ide[MAX_DISK_NSECS * SECTSIZE]; //静态字符数组，用于模拟IDE硬盘的存储空间。
                                            //数组的大小为MAX_DISK_NSECS * SECTSIZE，表示IDE硬盘的总容量，
                                            //每个扇区的大小为SECTSIZE字节。

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02003d6:	00253513          	sltiu	a0,a0,2
ffffffffc02003da:	8082                	ret

ffffffffc02003dc <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02003dc:	03800513          	li	a0,56
ffffffffc02003e0:	8082                	ret

ffffffffc02003e2 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003e2:	0000a797          	auipc	a5,0xa
ffffffffc02003e6:	c5e78793          	addi	a5,a5,-930 # ffffffffc020a040 <edata>
ffffffffc02003ea:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02003ee:	1141                	addi	sp,sp,-16
ffffffffc02003f0:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003f2:	95be                	add	a1,a1,a5
ffffffffc02003f4:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02003f8:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003fa:	569030ef          	jal	ra,ffffffffc0204162 <memcpy>

    //用于从指定IDE设备读取扇区数据。
    //接受设备号ideno、起始扇区号secno、目标缓冲区指针dst，以及要读取的扇区数nsecs。
    //函数会将扇区数据复制到目标缓冲区，并返回一个整数值，用于表示操作是否成功。

}
ffffffffc02003fe:	60a2                	ld	ra,8(sp)
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	0141                	addi	sp,sp,16
ffffffffc0200404:	8082                	ret

ffffffffc0200406 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc0200406:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200408:	0095979b          	slliw	a5,a1,0x9
ffffffffc020040c:	0000a517          	auipc	a0,0xa
ffffffffc0200410:	c3450513          	addi	a0,a0,-972 # ffffffffc020a040 <edata>
                   size_t nsecs) {
ffffffffc0200414:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200416:	00969613          	slli	a2,a3,0x9
ffffffffc020041a:	85ba                	mv	a1,a4
ffffffffc020041c:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc020041e:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200420:	543030ef          	jal	ra,ffffffffc0204162 <memcpy>
    return 0;

    //用于向指定IDE设备写入扇区数据。
    //接受设备号ideno、起始扇区号secno、源数据缓冲区指针src,以及要写入的扇区数nsecs。
    //函数会将源数据复制到IDE硬盘的模拟存储空间中，并返回一个整数值，用于表示操作是否成功。
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
ffffffffc0200426:	4501                	li	a0,0
ffffffffc0200428:	0141                	addi	sp,sp,16
ffffffffc020042a:	8082                	ret

ffffffffc020042c <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc020042c:	67e1                	lui	a5,0x18
ffffffffc020042e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200432:	00011717          	auipc	a4,0x11
ffffffffc0200436:	00f73b23          	sd	a5,22(a4) # ffffffffc0211448 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020043e:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200440:	953e                	add	a0,a0,a5
ffffffffc0200442:	4601                	li	a2,0
ffffffffc0200444:	4881                	li	a7,0
ffffffffc0200446:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc020044a:	02000793          	li	a5,32
ffffffffc020044e:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200452:	00004517          	auipc	a0,0x4
ffffffffc0200456:	49e50513          	addi	a0,a0,1182 # ffffffffc02048f0 <commands+0x178>
    ticks = 0;
ffffffffc020045a:	00011797          	auipc	a5,0x11
ffffffffc020045e:	0007bf23          	sd	zero,30(a5) # ffffffffc0211478 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200462:	c5dff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200466 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200466:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020046a:	00011797          	auipc	a5,0x11
ffffffffc020046e:	fde78793          	addi	a5,a5,-34 # ffffffffc0211448 <timebase>
ffffffffc0200472:	639c                	ld	a5,0(a5)
ffffffffc0200474:	4581                	li	a1,0
ffffffffc0200476:	4601                	li	a2,0
ffffffffc0200478:	953e                	add	a0,a0,a5
ffffffffc020047a:	4881                	li	a7,0
ffffffffc020047c:	00000073          	ecall
ffffffffc0200480:	8082                	ret

ffffffffc0200482 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200482:	100027f3          	csrr	a5,sstatus
ffffffffc0200486:	8b89                	andi	a5,a5,2
ffffffffc0200488:	0ff57513          	andi	a0,a0,255
ffffffffc020048c:	e799                	bnez	a5,ffffffffc020049a <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020048e:	4581                	li	a1,0
ffffffffc0200490:	4601                	li	a2,0
ffffffffc0200492:	4885                	li	a7,1
ffffffffc0200494:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200498:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020049a:	1101                	addi	sp,sp,-32
ffffffffc020049c:	ec06                	sd	ra,24(sp)
ffffffffc020049e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02004a0:	05a000ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc02004a4:	6522                	ld	a0,8(sp)
ffffffffc02004a6:	4581                	li	a1,0
ffffffffc02004a8:	4601                	li	a2,0
ffffffffc02004aa:	4885                	li	a7,1
ffffffffc02004ac:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02004b0:	60e2                	ld	ra,24(sp)
ffffffffc02004b2:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02004b4:	0400006f          	j	ffffffffc02004f4 <intr_enable>

ffffffffc02004b8 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02004b8:	100027f3          	csrr	a5,sstatus
ffffffffc02004bc:	8b89                	andi	a5,a5,2
ffffffffc02004be:	eb89                	bnez	a5,ffffffffc02004d0 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02004c0:	4501                	li	a0,0
ffffffffc02004c2:	4581                	li	a1,0
ffffffffc02004c4:	4601                	li	a2,0
ffffffffc02004c6:	4889                	li	a7,2
ffffffffc02004c8:	00000073          	ecall
ffffffffc02004cc:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02004ce:	8082                	ret
int cons_getc(void) {
ffffffffc02004d0:	1101                	addi	sp,sp,-32
ffffffffc02004d2:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02004d4:	026000ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc02004d8:	4501                	li	a0,0
ffffffffc02004da:	4581                	li	a1,0
ffffffffc02004dc:	4601                	li	a2,0
ffffffffc02004de:	4889                	li	a7,2
ffffffffc02004e0:	00000073          	ecall
ffffffffc02004e4:	2501                	sext.w	a0,a0
ffffffffc02004e6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02004e8:	00c000ef          	jal	ra,ffffffffc02004f4 <intr_enable>
}
ffffffffc02004ec:	60e2                	ld	ra,24(sp)
ffffffffc02004ee:	6522                	ld	a0,8(sp)
ffffffffc02004f0:	6105                	addi	sp,sp,32
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004f4:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004f8:	8082                	ret

ffffffffc02004fa <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004fa:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004fe:	8082                	ret

ffffffffc0200500 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200500:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200504:	1141                	addi	sp,sp,-16
ffffffffc0200506:	e022                	sd	s0,0(sp)
ffffffffc0200508:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020050a:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc020050e:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200510:	11053583          	ld	a1,272(a0)
ffffffffc0200514:	05500613          	li	a2,85
ffffffffc0200518:	c399                	beqz	a5,ffffffffc020051e <pgfault_handler+0x1e>
ffffffffc020051a:	04b00613          	li	a2,75
ffffffffc020051e:	11843703          	ld	a4,280(s0)
ffffffffc0200522:	47bd                	li	a5,15
ffffffffc0200524:	05700693          	li	a3,87
ffffffffc0200528:	00f70463          	beq	a4,a5,ffffffffc0200530 <pgfault_handler+0x30>
ffffffffc020052c:	05200693          	li	a3,82
ffffffffc0200530:	00004517          	auipc	a0,0x4
ffffffffc0200534:	6b850513          	addi	a0,a0,1720 # ffffffffc0204be8 <commands+0x470>
ffffffffc0200538:	b87ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc020053c:	00011797          	auipc	a5,0x11
ffffffffc0200540:	f7478793          	addi	a5,a5,-140 # ffffffffc02114b0 <check_mm_struct>
ffffffffc0200544:	6388                	ld	a0,0(a5)
ffffffffc0200546:	c911                	beqz	a0,ffffffffc020055a <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200548:	11043603          	ld	a2,272(s0)
ffffffffc020054c:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200550:	6402                	ld	s0,0(sp)
ffffffffc0200552:	60a2                	ld	ra,8(sp)
ffffffffc0200554:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200556:	2920206f          	j	ffffffffc02027e8 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020055a:	00004617          	auipc	a2,0x4
ffffffffc020055e:	6ae60613          	addi	a2,a2,1710 # ffffffffc0204c08 <commands+0x490>
ffffffffc0200562:	07800593          	li	a1,120
ffffffffc0200566:	00004517          	auipc	a0,0x4
ffffffffc020056a:	6ba50513          	addi	a0,a0,1722 # ffffffffc0204c20 <commands+0x4a8>
ffffffffc020056e:	b99ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200572 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200572:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200576:	00000797          	auipc	a5,0x0
ffffffffc020057a:	49a78793          	addi	a5,a5,1178 # ffffffffc0200a10 <__alltraps>
ffffffffc020057e:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200582:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200586:	000407b7          	lui	a5,0x40
ffffffffc020058a:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020058e:	8082                	ret

ffffffffc0200590 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200590:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	1141                	addi	sp,sp,-16
ffffffffc0200594:	e022                	sd	s0,0(sp)
ffffffffc0200596:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200598:	00004517          	auipc	a0,0x4
ffffffffc020059c:	6a050513          	addi	a0,a0,1696 # ffffffffc0204c38 <commands+0x4c0>
void print_regs(struct pushregs *gpr) {
ffffffffc02005a0:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02005a2:	b1dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02005a6:	640c                	ld	a1,8(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	6a850513          	addi	a0,a0,1704 # ffffffffc0204c50 <commands+0x4d8>
ffffffffc02005b0:	b0fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005b4:	680c                	ld	a1,16(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	6b250513          	addi	a0,a0,1714 # ffffffffc0204c68 <commands+0x4f0>
ffffffffc02005be:	b01ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005c2:	6c0c                	ld	a1,24(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	6bc50513          	addi	a0,a0,1724 # ffffffffc0204c80 <commands+0x508>
ffffffffc02005cc:	af3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005d0:	700c                	ld	a1,32(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	6c650513          	addi	a0,a0,1734 # ffffffffc0204c98 <commands+0x520>
ffffffffc02005da:	ae5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005de:	740c                	ld	a1,40(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	6d050513          	addi	a0,a0,1744 # ffffffffc0204cb0 <commands+0x538>
ffffffffc02005e8:	ad7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005ec:	780c                	ld	a1,48(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	6da50513          	addi	a0,a0,1754 # ffffffffc0204cc8 <commands+0x550>
ffffffffc02005f6:	ac9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005fa:	7c0c                	ld	a1,56(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	6e450513          	addi	a0,a0,1764 # ffffffffc0204ce0 <commands+0x568>
ffffffffc0200604:	abbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200608:	602c                	ld	a1,64(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	6ee50513          	addi	a0,a0,1774 # ffffffffc0204cf8 <commands+0x580>
ffffffffc0200612:	aadff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200616:	642c                	ld	a1,72(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	6f850513          	addi	a0,a0,1784 # ffffffffc0204d10 <commands+0x598>
ffffffffc0200620:	a9fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200624:	682c                	ld	a1,80(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	70250513          	addi	a0,a0,1794 # ffffffffc0204d28 <commands+0x5b0>
ffffffffc020062e:	a91ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200632:	6c2c                	ld	a1,88(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	70c50513          	addi	a0,a0,1804 # ffffffffc0204d40 <commands+0x5c8>
ffffffffc020063c:	a83ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200640:	702c                	ld	a1,96(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	71650513          	addi	a0,a0,1814 # ffffffffc0204d58 <commands+0x5e0>
ffffffffc020064a:	a75ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020064e:	742c                	ld	a1,104(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	72050513          	addi	a0,a0,1824 # ffffffffc0204d70 <commands+0x5f8>
ffffffffc0200658:	a67ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020065c:	782c                	ld	a1,112(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	72a50513          	addi	a0,a0,1834 # ffffffffc0204d88 <commands+0x610>
ffffffffc0200666:	a59ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020066a:	7c2c                	ld	a1,120(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	73450513          	addi	a0,a0,1844 # ffffffffc0204da0 <commands+0x628>
ffffffffc0200674:	a4bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200678:	604c                	ld	a1,128(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	73e50513          	addi	a0,a0,1854 # ffffffffc0204db8 <commands+0x640>
ffffffffc0200682:	a3dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200686:	644c                	ld	a1,136(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	74850513          	addi	a0,a0,1864 # ffffffffc0204dd0 <commands+0x658>
ffffffffc0200690:	a2fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200694:	684c                	ld	a1,144(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	75250513          	addi	a0,a0,1874 # ffffffffc0204de8 <commands+0x670>
ffffffffc020069e:	a21ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc02006a2:	6c4c                	ld	a1,152(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	75c50513          	addi	a0,a0,1884 # ffffffffc0204e00 <commands+0x688>
ffffffffc02006ac:	a13ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006b0:	704c                	ld	a1,160(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	76650513          	addi	a0,a0,1894 # ffffffffc0204e18 <commands+0x6a0>
ffffffffc02006ba:	a05ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006be:	744c                	ld	a1,168(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	77050513          	addi	a0,a0,1904 # ffffffffc0204e30 <commands+0x6b8>
ffffffffc02006c8:	9f7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006cc:	784c                	ld	a1,176(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	77a50513          	addi	a0,a0,1914 # ffffffffc0204e48 <commands+0x6d0>
ffffffffc02006d6:	9e9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006da:	7c4c                	ld	a1,184(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	78450513          	addi	a0,a0,1924 # ffffffffc0204e60 <commands+0x6e8>
ffffffffc02006e4:	9dbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006e8:	606c                	ld	a1,192(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	78e50513          	addi	a0,a0,1934 # ffffffffc0204e78 <commands+0x700>
ffffffffc02006f2:	9cdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006f6:	646c                	ld	a1,200(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	79850513          	addi	a0,a0,1944 # ffffffffc0204e90 <commands+0x718>
ffffffffc0200700:	9bfff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200704:	686c                	ld	a1,208(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	7a250513          	addi	a0,a0,1954 # ffffffffc0204ea8 <commands+0x730>
ffffffffc020070e:	9b1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200712:	6c6c                	ld	a1,216(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	7ac50513          	addi	a0,a0,1964 # ffffffffc0204ec0 <commands+0x748>
ffffffffc020071c:	9a3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200720:	706c                	ld	a1,224(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	7b650513          	addi	a0,a0,1974 # ffffffffc0204ed8 <commands+0x760>
ffffffffc020072a:	995ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020072e:	746c                	ld	a1,232(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	7c050513          	addi	a0,a0,1984 # ffffffffc0204ef0 <commands+0x778>
ffffffffc0200738:	987ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020073c:	786c                	ld	a1,240(s0)
ffffffffc020073e:	00004517          	auipc	a0,0x4
ffffffffc0200742:	7ca50513          	addi	a0,a0,1994 # ffffffffc0204f08 <commands+0x790>
ffffffffc0200746:	979ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020074a:	7c6c                	ld	a1,248(s0)
}
ffffffffc020074c:	6402                	ld	s0,0(sp)
ffffffffc020074e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200750:	00004517          	auipc	a0,0x4
ffffffffc0200754:	7d050513          	addi	a0,a0,2000 # ffffffffc0204f20 <commands+0x7a8>
}
ffffffffc0200758:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020075a:	965ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc020075e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020075e:	1141                	addi	sp,sp,-16
ffffffffc0200760:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200762:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200764:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200766:	00004517          	auipc	a0,0x4
ffffffffc020076a:	7d250513          	addi	a0,a0,2002 # ffffffffc0204f38 <commands+0x7c0>
void print_trapframe(struct trapframe *tf) {
ffffffffc020076e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200770:	94fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200774:	8522                	mv	a0,s0
ffffffffc0200776:	e1bff0ef          	jal	ra,ffffffffc0200590 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020077a:	10043583          	ld	a1,256(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	7d250513          	addi	a0,a0,2002 # ffffffffc0204f50 <commands+0x7d8>
ffffffffc0200786:	939ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020078a:	10843583          	ld	a1,264(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	7da50513          	addi	a0,a0,2010 # ffffffffc0204f68 <commands+0x7f0>
ffffffffc0200796:	929ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020079a:	11043583          	ld	a1,272(s0)
ffffffffc020079e:	00004517          	auipc	a0,0x4
ffffffffc02007a2:	7e250513          	addi	a0,a0,2018 # ffffffffc0204f80 <commands+0x808>
ffffffffc02007a6:	919ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007aa:	11843583          	ld	a1,280(s0)
}
ffffffffc02007ae:	6402                	ld	s0,0(sp)
ffffffffc02007b0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007b2:	00004517          	auipc	a0,0x4
ffffffffc02007b6:	7e650513          	addi	a0,a0,2022 # ffffffffc0204f98 <commands+0x820>
}
ffffffffc02007ba:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007bc:	903ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc02007c0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007c0:	11853783          	ld	a5,280(a0)
ffffffffc02007c4:	577d                	li	a4,-1
ffffffffc02007c6:	8305                	srli	a4,a4,0x1
ffffffffc02007c8:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02007ca:	472d                	li	a4,11
ffffffffc02007cc:	06f76f63          	bltu	a4,a5,ffffffffc020084a <interrupt_handler+0x8a>
ffffffffc02007d0:	00004717          	auipc	a4,0x4
ffffffffc02007d4:	13c70713          	addi	a4,a4,316 # ffffffffc020490c <commands+0x194>
ffffffffc02007d8:	078a                	slli	a5,a5,0x2
ffffffffc02007da:	97ba                	add	a5,a5,a4
ffffffffc02007dc:	439c                	lw	a5,0(a5)
ffffffffc02007de:	97ba                	add	a5,a5,a4
ffffffffc02007e0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007e2:	00004517          	auipc	a0,0x4
ffffffffc02007e6:	3b650513          	addi	a0,a0,950 # ffffffffc0204b98 <commands+0x420>
ffffffffc02007ea:	8d5ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007ee:	00004517          	auipc	a0,0x4
ffffffffc02007f2:	38a50513          	addi	a0,a0,906 # ffffffffc0204b78 <commands+0x400>
ffffffffc02007f6:	8c9ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007fa:	00004517          	auipc	a0,0x4
ffffffffc02007fe:	33e50513          	addi	a0,a0,830 # ffffffffc0204b38 <commands+0x3c0>
ffffffffc0200802:	8bdff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200806:	00004517          	auipc	a0,0x4
ffffffffc020080a:	35250513          	addi	a0,a0,850 # ffffffffc0204b58 <commands+0x3e0>
ffffffffc020080e:	8b1ff06f          	j	ffffffffc02000be <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200812:	00004517          	auipc	a0,0x4
ffffffffc0200816:	3b650513          	addi	a0,a0,950 # ffffffffc0204bc8 <commands+0x450>
ffffffffc020081a:	8a5ff06f          	j	ffffffffc02000be <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc020081e:	1141                	addi	sp,sp,-16
ffffffffc0200820:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200822:	c45ff0ef          	jal	ra,ffffffffc0200466 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200826:	00011797          	auipc	a5,0x11
ffffffffc020082a:	c5278793          	addi	a5,a5,-942 # ffffffffc0211478 <ticks>
ffffffffc020082e:	639c                	ld	a5,0(a5)
ffffffffc0200830:	06400713          	li	a4,100
ffffffffc0200834:	0785                	addi	a5,a5,1
ffffffffc0200836:	02e7f733          	remu	a4,a5,a4
ffffffffc020083a:	00011697          	auipc	a3,0x11
ffffffffc020083e:	c2f6bf23          	sd	a5,-962(a3) # ffffffffc0211478 <ticks>
ffffffffc0200842:	c711                	beqz	a4,ffffffffc020084e <interrupt_handler+0x8e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200844:	60a2                	ld	ra,8(sp)
ffffffffc0200846:	0141                	addi	sp,sp,16
ffffffffc0200848:	8082                	ret
            print_trapframe(tf);
ffffffffc020084a:	f15ff06f          	j	ffffffffc020075e <print_trapframe>
}
ffffffffc020084e:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200850:	06400593          	li	a1,100
ffffffffc0200854:	00004517          	auipc	a0,0x4
ffffffffc0200858:	36450513          	addi	a0,a0,868 # ffffffffc0204bb8 <commands+0x440>
}
ffffffffc020085c:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020085e:	861ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200862 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200862:	11853783          	ld	a5,280(a0)
ffffffffc0200866:	473d                	li	a4,15
ffffffffc0200868:	16f76563          	bltu	a4,a5,ffffffffc02009d2 <exception_handler+0x170>
ffffffffc020086c:	00004717          	auipc	a4,0x4
ffffffffc0200870:	0d070713          	addi	a4,a4,208 # ffffffffc020493c <commands+0x1c4>
ffffffffc0200874:	078a                	slli	a5,a5,0x2
ffffffffc0200876:	97ba                	add	a5,a5,a4
ffffffffc0200878:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc020087a:	1101                	addi	sp,sp,-32
ffffffffc020087c:	e822                	sd	s0,16(sp)
ffffffffc020087e:	ec06                	sd	ra,24(sp)
ffffffffc0200880:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200882:	97ba                	add	a5,a5,a4
ffffffffc0200884:	842a                	mv	s0,a0
ffffffffc0200886:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200888:	00004517          	auipc	a0,0x4
ffffffffc020088c:	29850513          	addi	a0,a0,664 # ffffffffc0204b20 <commands+0x3a8>
ffffffffc0200890:	82fff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200894:	8522                	mv	a0,s0
ffffffffc0200896:	c6bff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc020089a:	84aa                	mv	s1,a0
ffffffffc020089c:	12051d63          	bnez	a0,ffffffffc02009d6 <exception_handler+0x174>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008a0:	60e2                	ld	ra,24(sp)
ffffffffc02008a2:	6442                	ld	s0,16(sp)
ffffffffc02008a4:	64a2                	ld	s1,8(sp)
ffffffffc02008a6:	6105                	addi	sp,sp,32
ffffffffc02008a8:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02008aa:	00004517          	auipc	a0,0x4
ffffffffc02008ae:	0d650513          	addi	a0,a0,214 # ffffffffc0204980 <commands+0x208>
}
ffffffffc02008b2:	6442                	ld	s0,16(sp)
ffffffffc02008b4:	60e2                	ld	ra,24(sp)
ffffffffc02008b6:	64a2                	ld	s1,8(sp)
ffffffffc02008b8:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008ba:	805ff06f          	j	ffffffffc02000be <cprintf>
ffffffffc02008be:	00004517          	auipc	a0,0x4
ffffffffc02008c2:	0e250513          	addi	a0,a0,226 # ffffffffc02049a0 <commands+0x228>
ffffffffc02008c6:	b7f5                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008c8:	00004517          	auipc	a0,0x4
ffffffffc02008cc:	0f850513          	addi	a0,a0,248 # ffffffffc02049c0 <commands+0x248>
ffffffffc02008d0:	b7cd                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008d2:	00004517          	auipc	a0,0x4
ffffffffc02008d6:	10650513          	addi	a0,a0,262 # ffffffffc02049d8 <commands+0x260>
ffffffffc02008da:	bfe1                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008dc:	00004517          	auipc	a0,0x4
ffffffffc02008e0:	10c50513          	addi	a0,a0,268 # ffffffffc02049e8 <commands+0x270>
ffffffffc02008e4:	b7f9                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008e6:	00004517          	auipc	a0,0x4
ffffffffc02008ea:	12250513          	addi	a0,a0,290 # ffffffffc0204a08 <commands+0x290>
ffffffffc02008ee:	fd0ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008f2:	8522                	mv	a0,s0
ffffffffc02008f4:	c0dff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc02008f8:	84aa                	mv	s1,a0
ffffffffc02008fa:	d15d                	beqz	a0,ffffffffc02008a0 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02008fc:	8522                	mv	a0,s0
ffffffffc02008fe:	e61ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200902:	86a6                	mv	a3,s1
ffffffffc0200904:	00004617          	auipc	a2,0x4
ffffffffc0200908:	11c60613          	addi	a2,a2,284 # ffffffffc0204a20 <commands+0x2a8>
ffffffffc020090c:	0ca00593          	li	a1,202
ffffffffc0200910:	00004517          	auipc	a0,0x4
ffffffffc0200914:	31050513          	addi	a0,a0,784 # ffffffffc0204c20 <commands+0x4a8>
ffffffffc0200918:	feeff0ef          	jal	ra,ffffffffc0200106 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc020091c:	00004517          	auipc	a0,0x4
ffffffffc0200920:	12450513          	addi	a0,a0,292 # ffffffffc0204a40 <commands+0x2c8>
ffffffffc0200924:	b779                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200926:	00004517          	auipc	a0,0x4
ffffffffc020092a:	13250513          	addi	a0,a0,306 # ffffffffc0204a58 <commands+0x2e0>
ffffffffc020092e:	f90ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200932:	8522                	mv	a0,s0
ffffffffc0200934:	bcdff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc0200938:	84aa                	mv	s1,a0
ffffffffc020093a:	d13d                	beqz	a0,ffffffffc02008a0 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020093c:	8522                	mv	a0,s0
ffffffffc020093e:	e21ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200942:	86a6                	mv	a3,s1
ffffffffc0200944:	00004617          	auipc	a2,0x4
ffffffffc0200948:	0dc60613          	addi	a2,a2,220 # ffffffffc0204a20 <commands+0x2a8>
ffffffffc020094c:	0d400593          	li	a1,212
ffffffffc0200950:	00004517          	auipc	a0,0x4
ffffffffc0200954:	2d050513          	addi	a0,a0,720 # ffffffffc0204c20 <commands+0x4a8>
ffffffffc0200958:	faeff0ef          	jal	ra,ffffffffc0200106 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc020095c:	00004517          	auipc	a0,0x4
ffffffffc0200960:	11450513          	addi	a0,a0,276 # ffffffffc0204a70 <commands+0x2f8>
ffffffffc0200964:	b7b9                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200966:	00004517          	auipc	a0,0x4
ffffffffc020096a:	12a50513          	addi	a0,a0,298 # ffffffffc0204a90 <commands+0x318>
ffffffffc020096e:	b791                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200970:	00004517          	auipc	a0,0x4
ffffffffc0200974:	14050513          	addi	a0,a0,320 # ffffffffc0204ab0 <commands+0x338>
ffffffffc0200978:	bf2d                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc020097a:	00004517          	auipc	a0,0x4
ffffffffc020097e:	15650513          	addi	a0,a0,342 # ffffffffc0204ad0 <commands+0x358>
ffffffffc0200982:	bf05                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200984:	00004517          	auipc	a0,0x4
ffffffffc0200988:	16c50513          	addi	a0,a0,364 # ffffffffc0204af0 <commands+0x378>
ffffffffc020098c:	b71d                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc020098e:	00004517          	auipc	a0,0x4
ffffffffc0200992:	17a50513          	addi	a0,a0,378 # ffffffffc0204b08 <commands+0x390>
ffffffffc0200996:	f28ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020099a:	8522                	mv	a0,s0
ffffffffc020099c:	b65ff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc02009a0:	84aa                	mv	s1,a0
ffffffffc02009a2:	ee050fe3          	beqz	a0,ffffffffc02008a0 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009a6:	8522                	mv	a0,s0
ffffffffc02009a8:	db7ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009ac:	86a6                	mv	a3,s1
ffffffffc02009ae:	00004617          	auipc	a2,0x4
ffffffffc02009b2:	07260613          	addi	a2,a2,114 # ffffffffc0204a20 <commands+0x2a8>
ffffffffc02009b6:	0ea00593          	li	a1,234
ffffffffc02009ba:	00004517          	auipc	a0,0x4
ffffffffc02009be:	26650513          	addi	a0,a0,614 # ffffffffc0204c20 <commands+0x4a8>
ffffffffc02009c2:	f44ff0ef          	jal	ra,ffffffffc0200106 <__panic>
}
ffffffffc02009c6:	6442                	ld	s0,16(sp)
ffffffffc02009c8:	60e2                	ld	ra,24(sp)
ffffffffc02009ca:	64a2                	ld	s1,8(sp)
ffffffffc02009cc:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009ce:	d91ff06f          	j	ffffffffc020075e <print_trapframe>
ffffffffc02009d2:	d8dff06f          	j	ffffffffc020075e <print_trapframe>
                print_trapframe(tf);
ffffffffc02009d6:	8522                	mv	a0,s0
ffffffffc02009d8:	d87ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009dc:	86a6                	mv	a3,s1
ffffffffc02009de:	00004617          	auipc	a2,0x4
ffffffffc02009e2:	04260613          	addi	a2,a2,66 # ffffffffc0204a20 <commands+0x2a8>
ffffffffc02009e6:	0f100593          	li	a1,241
ffffffffc02009ea:	00004517          	auipc	a0,0x4
ffffffffc02009ee:	23650513          	addi	a0,a0,566 # ffffffffc0204c20 <commands+0x4a8>
ffffffffc02009f2:	f14ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02009f6 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc02009f6:	11853783          	ld	a5,280(a0)
ffffffffc02009fa:	0007c463          	bltz	a5,ffffffffc0200a02 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02009fe:	e65ff06f          	j	ffffffffc0200862 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200a02:	dbfff06f          	j	ffffffffc02007c0 <interrupt_handler>
	...

ffffffffc0200a10 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200a10:	14011073          	csrw	sscratch,sp
ffffffffc0200a14:	712d                	addi	sp,sp,-288
ffffffffc0200a16:	e406                	sd	ra,8(sp)
ffffffffc0200a18:	ec0e                	sd	gp,24(sp)
ffffffffc0200a1a:	f012                	sd	tp,32(sp)
ffffffffc0200a1c:	f416                	sd	t0,40(sp)
ffffffffc0200a1e:	f81a                	sd	t1,48(sp)
ffffffffc0200a20:	fc1e                	sd	t2,56(sp)
ffffffffc0200a22:	e0a2                	sd	s0,64(sp)
ffffffffc0200a24:	e4a6                	sd	s1,72(sp)
ffffffffc0200a26:	e8aa                	sd	a0,80(sp)
ffffffffc0200a28:	ecae                	sd	a1,88(sp)
ffffffffc0200a2a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a2c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a2e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a30:	fcbe                	sd	a5,120(sp)
ffffffffc0200a32:	e142                	sd	a6,128(sp)
ffffffffc0200a34:	e546                	sd	a7,136(sp)
ffffffffc0200a36:	e94a                	sd	s2,144(sp)
ffffffffc0200a38:	ed4e                	sd	s3,152(sp)
ffffffffc0200a3a:	f152                	sd	s4,160(sp)
ffffffffc0200a3c:	f556                	sd	s5,168(sp)
ffffffffc0200a3e:	f95a                	sd	s6,176(sp)
ffffffffc0200a40:	fd5e                	sd	s7,184(sp)
ffffffffc0200a42:	e1e2                	sd	s8,192(sp)
ffffffffc0200a44:	e5e6                	sd	s9,200(sp)
ffffffffc0200a46:	e9ea                	sd	s10,208(sp)
ffffffffc0200a48:	edee                	sd	s11,216(sp)
ffffffffc0200a4a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a4c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a4e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a50:	fdfe                	sd	t6,248(sp)
ffffffffc0200a52:	14002473          	csrr	s0,sscratch
ffffffffc0200a56:	100024f3          	csrr	s1,sstatus
ffffffffc0200a5a:	14102973          	csrr	s2,sepc
ffffffffc0200a5e:	143029f3          	csrr	s3,stval
ffffffffc0200a62:	14202a73          	csrr	s4,scause
ffffffffc0200a66:	e822                	sd	s0,16(sp)
ffffffffc0200a68:	e226                	sd	s1,256(sp)
ffffffffc0200a6a:	e64a                	sd	s2,264(sp)
ffffffffc0200a6c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a6e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a70:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a72:	f85ff0ef          	jal	ra,ffffffffc02009f6 <trap>

ffffffffc0200a76 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a76:	6492                	ld	s1,256(sp)
ffffffffc0200a78:	6932                	ld	s2,264(sp)
ffffffffc0200a7a:	10049073          	csrw	sstatus,s1
ffffffffc0200a7e:	14191073          	csrw	sepc,s2
ffffffffc0200a82:	60a2                	ld	ra,8(sp)
ffffffffc0200a84:	61e2                	ld	gp,24(sp)
ffffffffc0200a86:	7202                	ld	tp,32(sp)
ffffffffc0200a88:	72a2                	ld	t0,40(sp)
ffffffffc0200a8a:	7342                	ld	t1,48(sp)
ffffffffc0200a8c:	73e2                	ld	t2,56(sp)
ffffffffc0200a8e:	6406                	ld	s0,64(sp)
ffffffffc0200a90:	64a6                	ld	s1,72(sp)
ffffffffc0200a92:	6546                	ld	a0,80(sp)
ffffffffc0200a94:	65e6                	ld	a1,88(sp)
ffffffffc0200a96:	7606                	ld	a2,96(sp)
ffffffffc0200a98:	76a6                	ld	a3,104(sp)
ffffffffc0200a9a:	7746                	ld	a4,112(sp)
ffffffffc0200a9c:	77e6                	ld	a5,120(sp)
ffffffffc0200a9e:	680a                	ld	a6,128(sp)
ffffffffc0200aa0:	68aa                	ld	a7,136(sp)
ffffffffc0200aa2:	694a                	ld	s2,144(sp)
ffffffffc0200aa4:	69ea                	ld	s3,152(sp)
ffffffffc0200aa6:	7a0a                	ld	s4,160(sp)
ffffffffc0200aa8:	7aaa                	ld	s5,168(sp)
ffffffffc0200aaa:	7b4a                	ld	s6,176(sp)
ffffffffc0200aac:	7bea                	ld	s7,184(sp)
ffffffffc0200aae:	6c0e                	ld	s8,192(sp)
ffffffffc0200ab0:	6cae                	ld	s9,200(sp)
ffffffffc0200ab2:	6d4e                	ld	s10,208(sp)
ffffffffc0200ab4:	6dee                	ld	s11,216(sp)
ffffffffc0200ab6:	7e0e                	ld	t3,224(sp)
ffffffffc0200ab8:	7eae                	ld	t4,232(sp)
ffffffffc0200aba:	7f4e                	ld	t5,240(sp)
ffffffffc0200abc:	7fee                	ld	t6,248(sp)
ffffffffc0200abe:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200ac0:	10200073          	sret
	...

ffffffffc0200ad0 <_lru_init>:

static int
_lru_init(void)
{
    return 0;
}
ffffffffc0200ad0:	4501                	li	a0,0
ffffffffc0200ad2:	8082                	ret

ffffffffc0200ad4 <_lru_set_unswappable>:

static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0200ad4:	4501                	li	a0,0
ffffffffc0200ad6:	8082                	ret

ffffffffc0200ad8 <_lru_tick_event>:

static int
_lru_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0200ad8:	4501                	li	a0,0
ffffffffc0200ada:	8082                	ret

ffffffffc0200adc <_lru_init_mm>:
{     
ffffffffc0200adc:	1141                	addi	sp,sp,-16
ffffffffc0200ade:	e406                	sd	ra,8(sp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200ae0:	00011797          	auipc	a5,0x11
ffffffffc0200ae4:	9a078793          	addi	a5,a5,-1632 # ffffffffc0211480 <pra_list_head>
     mm->sm_priv = &pra_list_head;
ffffffffc0200ae8:	f51c                	sd	a5,40(a0)
     cprintf(" mm->sm_priv %x in lru_init_mm\n",mm->sm_priv);
ffffffffc0200aea:	85be                	mv	a1,a5
ffffffffc0200aec:	00004517          	auipc	a0,0x4
ffffffffc0200af0:	65450513          	addi	a0,a0,1620 # ffffffffc0205140 <commands+0x9c8>
ffffffffc0200af4:	e79c                	sd	a5,8(a5)
ffffffffc0200af6:	e39c                	sd	a5,0(a5)
ffffffffc0200af8:	dc6ff0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc0200afc:	60a2                	ld	ra,8(sp)
ffffffffc0200afe:	4501                	li	a0,0
ffffffffc0200b00:	0141                	addi	sp,sp,16
ffffffffc0200b02:	8082                	ret

ffffffffc0200b04 <_lru_check_swap>:
_lru_check_swap(void) {
ffffffffc0200b04:	1101                	addi	sp,sp,-32
    cprintf("write Virt Page c in lru_check_swap\n");
ffffffffc0200b06:	00004517          	auipc	a0,0x4
ffffffffc0200b0a:	4aa50513          	addi	a0,a0,1194 # ffffffffc0204fb0 <commands+0x838>
_lru_check_swap(void) {
ffffffffc0200b0e:	ec06                	sd	ra,24(sp)
ffffffffc0200b10:	e822                	sd	s0,16(sp)
ffffffffc0200b12:	e426                	sd	s1,8(sp)
ffffffffc0200b14:	e04a                	sd	s2,0(sp)
    cprintf("write Virt Page c in lru_check_swap\n");
ffffffffc0200b16:	da8ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    lru_access(0x3000, 0x0c);
ffffffffc0200b1a:	45b1                	li	a1,12
ffffffffc0200b1c:	650d                	lui	a0,0x3
    assert(pgfault_num==4);
ffffffffc0200b1e:	00011417          	auipc	s0,0x11
ffffffffc0200b22:	94240413          	addi	s0,s0,-1726 # ffffffffc0211460 <pgfault_num>
    lru_access(0x3000, 0x0c);
ffffffffc0200b26:	08f020ef          	jal	ra,ffffffffc02033b4 <lru_access>
    assert(pgfault_num==4);
ffffffffc0200b2a:	4004                	lw	s1,0(s0)
ffffffffc0200b2c:	4791                	li	a5,4
ffffffffc0200b2e:	2481                	sext.w	s1,s1
ffffffffc0200b30:	16f49063          	bne	s1,a5,ffffffffc0200c90 <_lru_check_swap+0x18c>
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc0200b34:	00004517          	auipc	a0,0x4
ffffffffc0200b38:	4e450513          	addi	a0,a0,1252 # ffffffffc0205018 <commands+0x8a0>
ffffffffc0200b3c:	d82ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    lru_access(0x1000, 0x0a);
ffffffffc0200b40:	45a9                	li	a1,10
ffffffffc0200b42:	6505                	lui	a0,0x1
ffffffffc0200b44:	071020ef          	jal	ra,ffffffffc02033b4 <lru_access>
    assert(pgfault_num==4);
ffffffffc0200b48:	00042903          	lw	s2,0(s0)
ffffffffc0200b4c:	2901                	sext.w	s2,s2
ffffffffc0200b4e:	2c991163          	bne	s2,s1,ffffffffc0200e10 <_lru_check_swap+0x30c>
    cprintf("write Virt Page d in lru_check_swap\n");
ffffffffc0200b52:	00004517          	auipc	a0,0x4
ffffffffc0200b56:	4ee50513          	addi	a0,a0,1262 # ffffffffc0205040 <commands+0x8c8>
ffffffffc0200b5a:	d64ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    lru_access(0x4000, 0x0d);
ffffffffc0200b5e:	45b5                	li	a1,13
ffffffffc0200b60:	6511                	lui	a0,0x4
ffffffffc0200b62:	053020ef          	jal	ra,ffffffffc02033b4 <lru_access>
    assert(pgfault_num==4);
ffffffffc0200b66:	4004                	lw	s1,0(s0)
ffffffffc0200b68:	2481                	sext.w	s1,s1
ffffffffc0200b6a:	29249363          	bne	s1,s2,ffffffffc0200df0 <_lru_check_swap+0x2ec>
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc0200b6e:	00004517          	auipc	a0,0x4
ffffffffc0200b72:	4fa50513          	addi	a0,a0,1274 # ffffffffc0205068 <commands+0x8f0>
ffffffffc0200b76:	d48ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    lru_access(0x2000, 0x0b);
ffffffffc0200b7a:	45ad                	li	a1,11
ffffffffc0200b7c:	6509                	lui	a0,0x2
ffffffffc0200b7e:	037020ef          	jal	ra,ffffffffc02033b4 <lru_access>
    assert(pgfault_num==4);
ffffffffc0200b82:	401c                	lw	a5,0(s0)
ffffffffc0200b84:	2781                	sext.w	a5,a5
ffffffffc0200b86:	24979563          	bne	a5,s1,ffffffffc0200dd0 <_lru_check_swap+0x2cc>
    cprintf("write Virt Page e in lru_check_swap\n");
ffffffffc0200b8a:	00004517          	auipc	a0,0x4
ffffffffc0200b8e:	50650513          	addi	a0,a0,1286 # ffffffffc0205090 <commands+0x918>
ffffffffc0200b92:	d2cff0ef          	jal	ra,ffffffffc02000be <cprintf>
    lru_access(0x5000, 0x0e);
ffffffffc0200b96:	45b9                	li	a1,14
ffffffffc0200b98:	6515                	lui	a0,0x5
ffffffffc0200b9a:	01b020ef          	jal	ra,ffffffffc02033b4 <lru_access>
    assert(pgfault_num==5);
ffffffffc0200b9e:	401c                	lw	a5,0(s0)
ffffffffc0200ba0:	4715                	li	a4,5
ffffffffc0200ba2:	2781                	sext.w	a5,a5
ffffffffc0200ba4:	20e79663          	bne	a5,a4,ffffffffc0200db0 <_lru_check_swap+0x2ac>
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc0200ba8:	00004517          	auipc	a0,0x4
ffffffffc0200bac:	4c050513          	addi	a0,a0,1216 # ffffffffc0205068 <commands+0x8f0>
ffffffffc0200bb0:	d0eff0ef          	jal	ra,ffffffffc02000be <cprintf>
    lru_access(0x3000, 0x0c);
ffffffffc0200bb4:	45b1                	li	a1,12
ffffffffc0200bb6:	650d                	lui	a0,0x3
ffffffffc0200bb8:	7fc020ef          	jal	ra,ffffffffc02033b4 <lru_access>
    assert(pgfault_num==6);
ffffffffc0200bbc:	401c                	lw	a5,0(s0)
ffffffffc0200bbe:	4719                	li	a4,6
ffffffffc0200bc0:	2781                	sext.w	a5,a5
ffffffffc0200bc2:	1ce79763          	bne	a5,a4,ffffffffc0200d90 <_lru_check_swap+0x28c>
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc0200bc6:	00004517          	auipc	a0,0x4
ffffffffc0200bca:	45250513          	addi	a0,a0,1106 # ffffffffc0205018 <commands+0x8a0>
ffffffffc0200bce:	cf0ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    lru_access(0x1000, 0x0a);
ffffffffc0200bd2:	45a9                	li	a1,10
ffffffffc0200bd4:	6505                	lui	a0,0x1
ffffffffc0200bd6:	7de020ef          	jal	ra,ffffffffc02033b4 <lru_access>
    assert(pgfault_num==7);
ffffffffc0200bda:	4004                	lw	s1,0(s0)
ffffffffc0200bdc:	479d                	li	a5,7
ffffffffc0200bde:	2481                	sext.w	s1,s1
ffffffffc0200be0:	18f49863          	bne	s1,a5,ffffffffc0200d70 <_lru_check_swap+0x26c>
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc0200be4:	00004517          	auipc	a0,0x4
ffffffffc0200be8:	48450513          	addi	a0,a0,1156 # ffffffffc0205068 <commands+0x8f0>
ffffffffc0200bec:	cd2ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    lru_access(0x2000, 0x0b);
ffffffffc0200bf0:	45ad                	li	a1,11
ffffffffc0200bf2:	6509                	lui	a0,0x2
ffffffffc0200bf4:	7c0020ef          	jal	ra,ffffffffc02033b4 <lru_access>
    assert(pgfault_num==7);
ffffffffc0200bf8:	00042903          	lw	s2,0(s0)
ffffffffc0200bfc:	2901                	sext.w	s2,s2
ffffffffc0200bfe:	14991963          	bne	s2,s1,ffffffffc0200d50 <_lru_check_swap+0x24c>
    cprintf("write Virt Page c in lru_check_swap\n");
ffffffffc0200c02:	00004517          	auipc	a0,0x4
ffffffffc0200c06:	3ae50513          	addi	a0,a0,942 # ffffffffc0204fb0 <commands+0x838>
ffffffffc0200c0a:	cb4ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    lru_access(0x3000, 0x0c);
ffffffffc0200c0e:	45b1                	li	a1,12
ffffffffc0200c10:	650d                	lui	a0,0x3
ffffffffc0200c12:	7a2020ef          	jal	ra,ffffffffc02033b4 <lru_access>
    assert(pgfault_num==7);
ffffffffc0200c16:	401c                	lw	a5,0(s0)
ffffffffc0200c18:	2781                	sext.w	a5,a5
ffffffffc0200c1a:	11279b63          	bne	a5,s2,ffffffffc0200d30 <_lru_check_swap+0x22c>
    cprintf("write Virt Page d in lru_check_swap\n");
ffffffffc0200c1e:	00004517          	auipc	a0,0x4
ffffffffc0200c22:	42250513          	addi	a0,a0,1058 # ffffffffc0205040 <commands+0x8c8>
ffffffffc0200c26:	c98ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    lru_access(0x4000, 0x0d);
ffffffffc0200c2a:	45b5                	li	a1,13
ffffffffc0200c2c:	6511                	lui	a0,0x4
ffffffffc0200c2e:	786020ef          	jal	ra,ffffffffc02033b4 <lru_access>
    assert(pgfault_num==8);
ffffffffc0200c32:	401c                	lw	a5,0(s0)
ffffffffc0200c34:	4721                	li	a4,8
ffffffffc0200c36:	2781                	sext.w	a5,a5
ffffffffc0200c38:	0ce79c63          	bne	a5,a4,ffffffffc0200d10 <_lru_check_swap+0x20c>
    cprintf("write Virt Page e in lru_check_swap\n");
ffffffffc0200c3c:	00004517          	auipc	a0,0x4
ffffffffc0200c40:	45450513          	addi	a0,a0,1108 # ffffffffc0205090 <commands+0x918>
ffffffffc0200c44:	c7aff0ef          	jal	ra,ffffffffc02000be <cprintf>
    lru_access(0x5000, 0x0e);
ffffffffc0200c48:	45b9                	li	a1,14
ffffffffc0200c4a:	6515                	lui	a0,0x5
ffffffffc0200c4c:	768020ef          	jal	ra,ffffffffc02033b4 <lru_access>
    assert(pgfault_num==9);
ffffffffc0200c50:	401c                	lw	a5,0(s0)
ffffffffc0200c52:	4725                	li	a4,9
ffffffffc0200c54:	2781                	sext.w	a5,a5
ffffffffc0200c56:	08e79d63          	bne	a5,a4,ffffffffc0200cf0 <_lru_check_swap+0x1ec>
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc0200c5a:	00004517          	auipc	a0,0x4
ffffffffc0200c5e:	3be50513          	addi	a0,a0,958 # ffffffffc0205018 <commands+0x8a0>
ffffffffc0200c62:	c5cff0ef          	jal	ra,ffffffffc02000be <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0200c66:	6785                	lui	a5,0x1
ffffffffc0200c68:	0007c483          	lbu	s1,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0200c6c:	47a9                	li	a5,10
ffffffffc0200c6e:	06f49163          	bne	s1,a5,ffffffffc0200cd0 <_lru_check_swap+0x1cc>
    lru_access(0x1000, 0x0a);
ffffffffc0200c72:	45a9                	li	a1,10
ffffffffc0200c74:	6505                	lui	a0,0x1
ffffffffc0200c76:	73e020ef          	jal	ra,ffffffffc02033b4 <lru_access>
    assert(pgfault_num==10);
ffffffffc0200c7a:	401c                	lw	a5,0(s0)
ffffffffc0200c7c:	2781                	sext.w	a5,a5
ffffffffc0200c7e:	02979963          	bne	a5,s1,ffffffffc0200cb0 <_lru_check_swap+0x1ac>
}
ffffffffc0200c82:	60e2                	ld	ra,24(sp)
ffffffffc0200c84:	6442                	ld	s0,16(sp)
ffffffffc0200c86:	64a2                	ld	s1,8(sp)
ffffffffc0200c88:	6902                	ld	s2,0(sp)
ffffffffc0200c8a:	4501                	li	a0,0
ffffffffc0200c8c:	6105                	addi	sp,sp,32
ffffffffc0200c8e:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0200c90:	00004697          	auipc	a3,0x4
ffffffffc0200c94:	34868693          	addi	a3,a3,840 # ffffffffc0204fd8 <commands+0x860>
ffffffffc0200c98:	00004617          	auipc	a2,0x4
ffffffffc0200c9c:	35060613          	addi	a2,a2,848 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0200ca0:	06200593          	li	a1,98
ffffffffc0200ca4:	00004517          	auipc	a0,0x4
ffffffffc0200ca8:	35c50513          	addi	a0,a0,860 # ffffffffc0205000 <commands+0x888>
ffffffffc0200cac:	c5aff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==10);
ffffffffc0200cb0:	00004697          	auipc	a3,0x4
ffffffffc0200cb4:	48068693          	addi	a3,a3,1152 # ffffffffc0205130 <commands+0x9b8>
ffffffffc0200cb8:	00004617          	auipc	a2,0x4
ffffffffc0200cbc:	33060613          	addi	a2,a2,816 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0200cc0:	08400593          	li	a1,132
ffffffffc0200cc4:	00004517          	auipc	a0,0x4
ffffffffc0200cc8:	33c50513          	addi	a0,a0,828 # ffffffffc0205000 <commands+0x888>
ffffffffc0200ccc:	c3aff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0200cd0:	00004697          	auipc	a3,0x4
ffffffffc0200cd4:	43868693          	addi	a3,a3,1080 # ffffffffc0205108 <commands+0x990>
ffffffffc0200cd8:	00004617          	auipc	a2,0x4
ffffffffc0200cdc:	31060613          	addi	a2,a2,784 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0200ce0:	08200593          	li	a1,130
ffffffffc0200ce4:	00004517          	auipc	a0,0x4
ffffffffc0200ce8:	31c50513          	addi	a0,a0,796 # ffffffffc0205000 <commands+0x888>
ffffffffc0200cec:	c1aff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==9);
ffffffffc0200cf0:	00004697          	auipc	a3,0x4
ffffffffc0200cf4:	40868693          	addi	a3,a3,1032 # ffffffffc02050f8 <commands+0x980>
ffffffffc0200cf8:	00004617          	auipc	a2,0x4
ffffffffc0200cfc:	2f060613          	addi	a2,a2,752 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0200d00:	08000593          	li	a1,128
ffffffffc0200d04:	00004517          	auipc	a0,0x4
ffffffffc0200d08:	2fc50513          	addi	a0,a0,764 # ffffffffc0205000 <commands+0x888>
ffffffffc0200d0c:	bfaff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==8);
ffffffffc0200d10:	00004697          	auipc	a3,0x4
ffffffffc0200d14:	3d868693          	addi	a3,a3,984 # ffffffffc02050e8 <commands+0x970>
ffffffffc0200d18:	00004617          	auipc	a2,0x4
ffffffffc0200d1c:	2d060613          	addi	a2,a2,720 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0200d20:	07d00593          	li	a1,125
ffffffffc0200d24:	00004517          	auipc	a0,0x4
ffffffffc0200d28:	2dc50513          	addi	a0,a0,732 # ffffffffc0205000 <commands+0x888>
ffffffffc0200d2c:	bdaff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==7);
ffffffffc0200d30:	00004697          	auipc	a3,0x4
ffffffffc0200d34:	3a868693          	addi	a3,a3,936 # ffffffffc02050d8 <commands+0x960>
ffffffffc0200d38:	00004617          	auipc	a2,0x4
ffffffffc0200d3c:	2b060613          	addi	a2,a2,688 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0200d40:	07a00593          	li	a1,122
ffffffffc0200d44:	00004517          	auipc	a0,0x4
ffffffffc0200d48:	2bc50513          	addi	a0,a0,700 # ffffffffc0205000 <commands+0x888>
ffffffffc0200d4c:	bbaff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==7);
ffffffffc0200d50:	00004697          	auipc	a3,0x4
ffffffffc0200d54:	38868693          	addi	a3,a3,904 # ffffffffc02050d8 <commands+0x960>
ffffffffc0200d58:	00004617          	auipc	a2,0x4
ffffffffc0200d5c:	29060613          	addi	a2,a2,656 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0200d60:	07700593          	li	a1,119
ffffffffc0200d64:	00004517          	auipc	a0,0x4
ffffffffc0200d68:	29c50513          	addi	a0,a0,668 # ffffffffc0205000 <commands+0x888>
ffffffffc0200d6c:	b9aff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==7);
ffffffffc0200d70:	00004697          	auipc	a3,0x4
ffffffffc0200d74:	36868693          	addi	a3,a3,872 # ffffffffc02050d8 <commands+0x960>
ffffffffc0200d78:	00004617          	auipc	a2,0x4
ffffffffc0200d7c:	27060613          	addi	a2,a2,624 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0200d80:	07400593          	li	a1,116
ffffffffc0200d84:	00004517          	auipc	a0,0x4
ffffffffc0200d88:	27c50513          	addi	a0,a0,636 # ffffffffc0205000 <commands+0x888>
ffffffffc0200d8c:	b7aff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==6);
ffffffffc0200d90:	00004697          	auipc	a3,0x4
ffffffffc0200d94:	33868693          	addi	a3,a3,824 # ffffffffc02050c8 <commands+0x950>
ffffffffc0200d98:	00004617          	auipc	a2,0x4
ffffffffc0200d9c:	25060613          	addi	a2,a2,592 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0200da0:	07100593          	li	a1,113
ffffffffc0200da4:	00004517          	auipc	a0,0x4
ffffffffc0200da8:	25c50513          	addi	a0,a0,604 # ffffffffc0205000 <commands+0x888>
ffffffffc0200dac:	b5aff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc0200db0:	00004697          	auipc	a3,0x4
ffffffffc0200db4:	30868693          	addi	a3,a3,776 # ffffffffc02050b8 <commands+0x940>
ffffffffc0200db8:	00004617          	auipc	a2,0x4
ffffffffc0200dbc:	23060613          	addi	a2,a2,560 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0200dc0:	06e00593          	li	a1,110
ffffffffc0200dc4:	00004517          	auipc	a0,0x4
ffffffffc0200dc8:	23c50513          	addi	a0,a0,572 # ffffffffc0205000 <commands+0x888>
ffffffffc0200dcc:	b3aff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==4);
ffffffffc0200dd0:	00004697          	auipc	a3,0x4
ffffffffc0200dd4:	20868693          	addi	a3,a3,520 # ffffffffc0204fd8 <commands+0x860>
ffffffffc0200dd8:	00004617          	auipc	a2,0x4
ffffffffc0200ddc:	21060613          	addi	a2,a2,528 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0200de0:	06b00593          	li	a1,107
ffffffffc0200de4:	00004517          	auipc	a0,0x4
ffffffffc0200de8:	21c50513          	addi	a0,a0,540 # ffffffffc0205000 <commands+0x888>
ffffffffc0200dec:	b1aff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==4);
ffffffffc0200df0:	00004697          	auipc	a3,0x4
ffffffffc0200df4:	1e868693          	addi	a3,a3,488 # ffffffffc0204fd8 <commands+0x860>
ffffffffc0200df8:	00004617          	auipc	a2,0x4
ffffffffc0200dfc:	1f060613          	addi	a2,a2,496 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0200e00:	06800593          	li	a1,104
ffffffffc0200e04:	00004517          	auipc	a0,0x4
ffffffffc0200e08:	1fc50513          	addi	a0,a0,508 # ffffffffc0205000 <commands+0x888>
ffffffffc0200e0c:	afaff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==4);
ffffffffc0200e10:	00004697          	auipc	a3,0x4
ffffffffc0200e14:	1c868693          	addi	a3,a3,456 # ffffffffc0204fd8 <commands+0x860>
ffffffffc0200e18:	00004617          	auipc	a2,0x4
ffffffffc0200e1c:	1d060613          	addi	a2,a2,464 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0200e20:	06500593          	li	a1,101
ffffffffc0200e24:	00004517          	auipc	a0,0x4
ffffffffc0200e28:	1dc50513          	addi	a0,a0,476 # ffffffffc0205000 <commands+0x888>
ffffffffc0200e2c:	adaff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200e30 <_lru_swap_out_victim>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0200e30:	7514                	ld	a3,40(a0)
{
ffffffffc0200e32:	1141                	addi	sp,sp,-16
ffffffffc0200e34:	e406                	sd	ra,8(sp)
    assert(head != NULL);
ffffffffc0200e36:	c6b9                	beqz	a3,ffffffffc0200e84 <_lru_swap_out_victim+0x54>
    assert(in_tick==0);
ffffffffc0200e38:	e635                	bnez	a2,ffffffffc0200ea4 <_lru_swap_out_victim+0x74>
    list_entry_t *le = head->next;
ffffffffc0200e3a:	669c                	ld	a5,8(a3)
    while (le!=head) {
ffffffffc0200e3c:	04f68063          	beq	a3,a5,ffffffffc0200e7c <_lru_swap_out_victim+0x4c>
    struct list_entry_t* maxle=NULL;
ffffffffc0200e40:	4501                	li	a0,0
        if(page->visited>max) {
ffffffffc0200e42:	fe07b703          	ld	a4,-32(a5)
ffffffffc0200e46:	00e67563          	bleu	a4,a2,ffffffffc0200e50 <_lru_swap_out_victim+0x20>
            max = page->visited;
ffffffffc0200e4a:	0007061b          	sext.w	a2,a4
ffffffffc0200e4e:	853e                	mv	a0,a5
        le = le->next;
ffffffffc0200e50:	679c                	ld	a5,8(a5)
    while (le!=head) {
ffffffffc0200e52:	fef698e3          	bne	a3,a5,ffffffffc0200e42 <_lru_swap_out_victim+0x12>
    if (maxle != head) {
ffffffffc0200e56:	00d50d63          	beq	a0,a3,ffffffffc0200e70 <_lru_swap_out_victim+0x40>
ffffffffc0200e5a:	fd050693          	addi	a3,a0,-48
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
ffffffffc0200e5e:	6118                	ld	a4,0(a0)
ffffffffc0200e60:	651c                	ld	a5,8(a0)
}
ffffffffc0200e62:	60a2                	ld	ra,8(sp)
ffffffffc0200e64:	4501                	li	a0,0
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200e66:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200e68:	e398                	sd	a4,0(a5)
        *ptr_page = le2page(maxle, pra_page_link);
ffffffffc0200e6a:	e194                	sd	a3,0(a1)
}
ffffffffc0200e6c:	0141                	addi	sp,sp,16
ffffffffc0200e6e:	8082                	ret
ffffffffc0200e70:	60a2                	ld	ra,8(sp)
        *ptr_page = NULL;
ffffffffc0200e72:	0005b023          	sd	zero,0(a1)
}
ffffffffc0200e76:	4501                	li	a0,0
ffffffffc0200e78:	0141                	addi	sp,sp,16
ffffffffc0200e7a:	8082                	ret
    while (le!=head) {
ffffffffc0200e7c:	fd000693          	li	a3,-48
    struct list_entry_t* maxle=NULL;
ffffffffc0200e80:	4501                	li	a0,0
ffffffffc0200e82:	bff1                	j	ffffffffc0200e5e <_lru_swap_out_victim+0x2e>
    assert(head != NULL);
ffffffffc0200e84:	00004697          	auipc	a3,0x4
ffffffffc0200e88:	2fc68693          	addi	a3,a3,764 # ffffffffc0205180 <commands+0xa08>
ffffffffc0200e8c:	00004617          	auipc	a2,0x4
ffffffffc0200e90:	15c60613          	addi	a2,a2,348 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0200e94:	04100593          	li	a1,65
ffffffffc0200e98:	00004517          	auipc	a0,0x4
ffffffffc0200e9c:	16850513          	addi	a0,a0,360 # ffffffffc0205000 <commands+0x888>
ffffffffc0200ea0:	a66ff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(in_tick==0);
ffffffffc0200ea4:	00004697          	auipc	a3,0x4
ffffffffc0200ea8:	2ec68693          	addi	a3,a3,748 # ffffffffc0205190 <commands+0xa18>
ffffffffc0200eac:	00004617          	auipc	a2,0x4
ffffffffc0200eb0:	13c60613          	addi	a2,a2,316 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0200eb4:	04200593          	li	a1,66
ffffffffc0200eb8:	00004517          	auipc	a0,0x4
ffffffffc0200ebc:	14850513          	addi	a0,a0,328 # ffffffffc0205000 <commands+0x888>
ffffffffc0200ec0:	a46ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200ec4 <_lru_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0200ec4:	03060713          	addi	a4,a2,48
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0200ec8:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0200eca:	cb09                	beqz	a4,ffffffffc0200edc <_lru_map_swappable+0x18>
ffffffffc0200ecc:	cb81                	beqz	a5,ffffffffc0200edc <_lru_map_swappable+0x18>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200ece:	6794                	ld	a3,8(a5)
}
ffffffffc0200ed0:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc0200ed2:	e298                	sd	a4,0(a3)
ffffffffc0200ed4:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0200ed6:	fe14                	sd	a3,56(a2)
    elm->prev = prev;
ffffffffc0200ed8:	fa1c                	sd	a5,48(a2)
ffffffffc0200eda:	8082                	ret
{
ffffffffc0200edc:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0200ede:	00004697          	auipc	a3,0x4
ffffffffc0200ee2:	28268693          	addi	a3,a3,642 # ffffffffc0205160 <commands+0x9e8>
ffffffffc0200ee6:	00004617          	auipc	a2,0x4
ffffffffc0200eea:	10260613          	addi	a2,a2,258 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0200eee:	03300593          	li	a1,51
ffffffffc0200ef2:	00004517          	auipc	a0,0x4
ffffffffc0200ef6:	10e50513          	addi	a0,a0,270 # ffffffffc0205000 <commands+0x888>
{
ffffffffc0200efa:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0200efc:	a0aff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200f00 <pa2page.part.4>:

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0200f00:	1141                	addi	sp,sp,-16
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
ffffffffc0200f02:	00004617          	auipc	a2,0x4
ffffffffc0200f06:	33660613          	addi	a2,a2,822 # ffffffffc0205238 <commands+0xac0>
ffffffffc0200f0a:	06500593          	li	a1,101
ffffffffc0200f0e:	00004517          	auipc	a0,0x4
ffffffffc0200f12:	34a50513          	addi	a0,a0,842 # ffffffffc0205258 <commands+0xae0>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0200f16:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0200f18:	9eeff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200f1c <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0200f1c:	715d                	addi	sp,sp,-80
ffffffffc0200f1e:	e0a2                	sd	s0,64(sp)
ffffffffc0200f20:	fc26                	sd	s1,56(sp)
ffffffffc0200f22:	f84a                	sd	s2,48(sp)
ffffffffc0200f24:	f44e                	sd	s3,40(sp)
ffffffffc0200f26:	f052                	sd	s4,32(sp)
ffffffffc0200f28:	ec56                	sd	s5,24(sp)
ffffffffc0200f2a:	e486                	sd	ra,72(sp)
ffffffffc0200f2c:	842a                	mv	s0,a0
ffffffffc0200f2e:	00010497          	auipc	s1,0x10
ffffffffc0200f32:	56248493          	addi	s1,s1,1378 # ffffffffc0211490 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200f36:	4985                	li	s3,1
ffffffffc0200f38:	00010a17          	auipc	s4,0x10
ffffffffc0200f3c:	538a0a13          	addi	s4,s4,1336 # ffffffffc0211470 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0200f40:	0005091b          	sext.w	s2,a0
ffffffffc0200f44:	00010a97          	auipc	s5,0x10
ffffffffc0200f48:	56ca8a93          	addi	s5,s5,1388 # ffffffffc02114b0 <check_mm_struct>
ffffffffc0200f4c:	a00d                	j	ffffffffc0200f6e <alloc_pages+0x52>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0200f4e:	609c                	ld	a5,0(s1)
ffffffffc0200f50:	6f9c                	ld	a5,24(a5)
ffffffffc0200f52:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0200f54:	4601                	li	a2,0
ffffffffc0200f56:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200f58:	ed0d                	bnez	a0,ffffffffc0200f92 <alloc_pages+0x76>
ffffffffc0200f5a:	0289ec63          	bltu	s3,s0,ffffffffc0200f92 <alloc_pages+0x76>
ffffffffc0200f5e:	000a2783          	lw	a5,0(s4)
ffffffffc0200f62:	2781                	sext.w	a5,a5
ffffffffc0200f64:	c79d                	beqz	a5,ffffffffc0200f92 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200f66:	000ab503          	ld	a0,0(s5)
ffffffffc0200f6a:	173010ef          	jal	ra,ffffffffc02028dc <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f6e:	100027f3          	csrr	a5,sstatus
ffffffffc0200f72:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0200f74:	8522                	mv	a0,s0
ffffffffc0200f76:	dfe1                	beqz	a5,ffffffffc0200f4e <alloc_pages+0x32>
        intr_disable();
ffffffffc0200f78:	d82ff0ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc0200f7c:	609c                	ld	a5,0(s1)
ffffffffc0200f7e:	8522                	mv	a0,s0
ffffffffc0200f80:	6f9c                	ld	a5,24(a5)
ffffffffc0200f82:	9782                	jalr	a5
ffffffffc0200f84:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200f86:	d6eff0ef          	jal	ra,ffffffffc02004f4 <intr_enable>
ffffffffc0200f8a:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0200f8c:	4601                	li	a2,0
ffffffffc0200f8e:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200f90:	d569                	beqz	a0,ffffffffc0200f5a <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0200f92:	60a6                	ld	ra,72(sp)
ffffffffc0200f94:	6406                	ld	s0,64(sp)
ffffffffc0200f96:	74e2                	ld	s1,56(sp)
ffffffffc0200f98:	7942                	ld	s2,48(sp)
ffffffffc0200f9a:	79a2                	ld	s3,40(sp)
ffffffffc0200f9c:	7a02                	ld	s4,32(sp)
ffffffffc0200f9e:	6ae2                	ld	s5,24(sp)
ffffffffc0200fa0:	6161                	addi	sp,sp,80
ffffffffc0200fa2:	8082                	ret

ffffffffc0200fa4 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200fa4:	100027f3          	csrr	a5,sstatus
ffffffffc0200fa8:	8b89                	andi	a5,a5,2
ffffffffc0200faa:	eb89                	bnez	a5,ffffffffc0200fbc <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc0200fac:	00010797          	auipc	a5,0x10
ffffffffc0200fb0:	4e478793          	addi	a5,a5,1252 # ffffffffc0211490 <pmm_manager>
ffffffffc0200fb4:	639c                	ld	a5,0(a5)
ffffffffc0200fb6:	0207b303          	ld	t1,32(a5)
ffffffffc0200fba:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200fbc:	1101                	addi	sp,sp,-32
ffffffffc0200fbe:	ec06                	sd	ra,24(sp)
ffffffffc0200fc0:	e822                	sd	s0,16(sp)
ffffffffc0200fc2:	e426                	sd	s1,8(sp)
ffffffffc0200fc4:	842a                	mv	s0,a0
ffffffffc0200fc6:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200fc8:	d32ff0ef          	jal	ra,ffffffffc02004fa <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0200fcc:	00010797          	auipc	a5,0x10
ffffffffc0200fd0:	4c478793          	addi	a5,a5,1220 # ffffffffc0211490 <pmm_manager>
ffffffffc0200fd4:	639c                	ld	a5,0(a5)
ffffffffc0200fd6:	85a6                	mv	a1,s1
ffffffffc0200fd8:	8522                	mv	a0,s0
ffffffffc0200fda:	739c                	ld	a5,32(a5)
ffffffffc0200fdc:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0200fde:	6442                	ld	s0,16(sp)
ffffffffc0200fe0:	60e2                	ld	ra,24(sp)
ffffffffc0200fe2:	64a2                	ld	s1,8(sp)
ffffffffc0200fe4:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200fe6:	d0eff06f          	j	ffffffffc02004f4 <intr_enable>

ffffffffc0200fea <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200fea:	100027f3          	csrr	a5,sstatus
ffffffffc0200fee:	8b89                	andi	a5,a5,2
ffffffffc0200ff0:	eb89                	bnez	a5,ffffffffc0201002 <nr_free_pages+0x18>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0200ff2:	00010797          	auipc	a5,0x10
ffffffffc0200ff6:	49e78793          	addi	a5,a5,1182 # ffffffffc0211490 <pmm_manager>
ffffffffc0200ffa:	639c                	ld	a5,0(a5)
ffffffffc0200ffc:	0287b303          	ld	t1,40(a5)
ffffffffc0201000:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201002:	1141                	addi	sp,sp,-16
ffffffffc0201004:	e406                	sd	ra,8(sp)
ffffffffc0201006:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201008:	cf2ff0ef          	jal	ra,ffffffffc02004fa <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020100c:	00010797          	auipc	a5,0x10
ffffffffc0201010:	48478793          	addi	a5,a5,1156 # ffffffffc0211490 <pmm_manager>
ffffffffc0201014:	639c                	ld	a5,0(a5)
ffffffffc0201016:	779c                	ld	a5,40(a5)
ffffffffc0201018:	9782                	jalr	a5
ffffffffc020101a:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020101c:	cd8ff0ef          	jal	ra,ffffffffc02004f4 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201020:	8522                	mv	a0,s0
ffffffffc0201022:	60a2                	ld	ra,8(sp)
ffffffffc0201024:	6402                	ld	s0,0(sp)
ffffffffc0201026:	0141                	addi	sp,sp,16
ffffffffc0201028:	8082                	ret

ffffffffc020102a <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020102a:	715d                	addi	sp,sp,-80
ffffffffc020102c:	fc26                	sd	s1,56(sp)
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020102e:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201032:	1ff4f493          	andi	s1,s1,511
ffffffffc0201036:	048e                	slli	s1,s1,0x3
ffffffffc0201038:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc020103a:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020103c:	f84a                	sd	s2,48(sp)
ffffffffc020103e:	f44e                	sd	s3,40(sp)
ffffffffc0201040:	f052                	sd	s4,32(sp)
ffffffffc0201042:	e486                	sd	ra,72(sp)
ffffffffc0201044:	e0a2                	sd	s0,64(sp)
ffffffffc0201046:	ec56                	sd	s5,24(sp)
ffffffffc0201048:	e85a                	sd	s6,16(sp)
ffffffffc020104a:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc020104c:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201050:	892e                	mv	s2,a1
ffffffffc0201052:	8a32                	mv	s4,a2
ffffffffc0201054:	00010997          	auipc	s3,0x10
ffffffffc0201058:	40498993          	addi	s3,s3,1028 # ffffffffc0211458 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc020105c:	e3c9                	bnez	a5,ffffffffc02010de <get_pte+0xb4>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc020105e:	16060163          	beqz	a2,ffffffffc02011c0 <get_pte+0x196>
ffffffffc0201062:	4505                	li	a0,1
ffffffffc0201064:	eb9ff0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0201068:	842a                	mv	s0,a0
ffffffffc020106a:	14050b63          	beqz	a0,ffffffffc02011c0 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020106e:	00010b97          	auipc	s7,0x10
ffffffffc0201072:	43ab8b93          	addi	s7,s7,1082 # ffffffffc02114a8 <pages>
ffffffffc0201076:	000bb503          	ld	a0,0(s7)
ffffffffc020107a:	00004797          	auipc	a5,0x4
ffffffffc020107e:	13e78793          	addi	a5,a5,318 # ffffffffc02051b8 <commands+0xa40>
ffffffffc0201082:	0007bb03          	ld	s6,0(a5)
ffffffffc0201086:	40a40533          	sub	a0,s0,a0
ffffffffc020108a:	850d                	srai	a0,a0,0x3
ffffffffc020108c:	03650533          	mul	a0,a0,s6
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201090:	4785                	li	a5,1
        
        //get the physical address of memory which this (struct* Page *) page  manages
        uintptr_t pa = page2pa(page);

        // sets the first n bytes of the memory area pointed by s
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201092:	00010997          	auipc	s3,0x10
ffffffffc0201096:	3c698993          	addi	s3,s3,966 # ffffffffc0211458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020109a:	00080ab7          	lui	s5,0x80
ffffffffc020109e:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02010a2:	c01c                	sw	a5,0(s0)
ffffffffc02010a4:	57fd                	li	a5,-1
ffffffffc02010a6:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02010a8:	9556                	add	a0,a0,s5
ffffffffc02010aa:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02010ac:	0532                	slli	a0,a0,0xc
ffffffffc02010ae:	16e7f063          	bleu	a4,a5,ffffffffc020120e <get_pte+0x1e4>
ffffffffc02010b2:	00010797          	auipc	a5,0x10
ffffffffc02010b6:	3e678793          	addi	a5,a5,998 # ffffffffc0211498 <va_pa_offset>
ffffffffc02010ba:	639c                	ld	a5,0(a5)
ffffffffc02010bc:	6605                	lui	a2,0x1
ffffffffc02010be:	4581                	li	a1,0
ffffffffc02010c0:	953e                	add	a0,a0,a5
ffffffffc02010c2:	08e030ef          	jal	ra,ffffffffc0204150 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02010c6:	000bb683          	ld	a3,0(s7)
ffffffffc02010ca:	40d406b3          	sub	a3,s0,a3
ffffffffc02010ce:	868d                	srai	a3,a3,0x3
ffffffffc02010d0:	036686b3          	mul	a3,a3,s6
ffffffffc02010d4:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02010d6:	06aa                	slli	a3,a3,0xa
ffffffffc02010d8:	0116e693          	ori	a3,a3,17


        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02010dc:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02010de:	77fd                	lui	a5,0xfffff
ffffffffc02010e0:	068a                	slli	a3,a3,0x2
ffffffffc02010e2:	0009b703          	ld	a4,0(s3)
ffffffffc02010e6:	8efd                	and	a3,a3,a5
ffffffffc02010e8:	00c6d793          	srli	a5,a3,0xc
ffffffffc02010ec:	0ce7fc63          	bleu	a4,a5,ffffffffc02011c4 <get_pte+0x19a>
ffffffffc02010f0:	00010a97          	auipc	s5,0x10
ffffffffc02010f4:	3a8a8a93          	addi	s5,s5,936 # ffffffffc0211498 <va_pa_offset>
ffffffffc02010f8:	000ab403          	ld	s0,0(s5)
ffffffffc02010fc:	01595793          	srli	a5,s2,0x15
ffffffffc0201100:	1ff7f793          	andi	a5,a5,511
ffffffffc0201104:	96a2                	add	a3,a3,s0
ffffffffc0201106:	00379413          	slli	s0,a5,0x3
ffffffffc020110a:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc020110c:	6014                	ld	a3,0(s0)
ffffffffc020110e:	0016f793          	andi	a5,a3,1
ffffffffc0201112:	ebbd                	bnez	a5,ffffffffc0201188 <get_pte+0x15e>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201114:	0a0a0663          	beqz	s4,ffffffffc02011c0 <get_pte+0x196>
ffffffffc0201118:	4505                	li	a0,1
ffffffffc020111a:	e03ff0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc020111e:	84aa                	mv	s1,a0
ffffffffc0201120:	c145                	beqz	a0,ffffffffc02011c0 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201122:	00010b97          	auipc	s7,0x10
ffffffffc0201126:	386b8b93          	addi	s7,s7,902 # ffffffffc02114a8 <pages>
ffffffffc020112a:	000bb503          	ld	a0,0(s7)
ffffffffc020112e:	00004797          	auipc	a5,0x4
ffffffffc0201132:	08a78793          	addi	a5,a5,138 # ffffffffc02051b8 <commands+0xa40>
ffffffffc0201136:	0007bb03          	ld	s6,0(a5)
ffffffffc020113a:	40a48533          	sub	a0,s1,a0
ffffffffc020113e:	850d                	srai	a0,a0,0x3
ffffffffc0201140:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201144:	4785                	li	a5,1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201146:	00080a37          	lui	s4,0x80
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc020114a:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020114e:	c09c                	sw	a5,0(s1)
ffffffffc0201150:	57fd                	li	a5,-1
ffffffffc0201152:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201154:	9552                	add	a0,a0,s4
ffffffffc0201156:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201158:	0532                	slli	a0,a0,0xc
ffffffffc020115a:	08e7fd63          	bleu	a4,a5,ffffffffc02011f4 <get_pte+0x1ca>
ffffffffc020115e:	000ab783          	ld	a5,0(s5)
ffffffffc0201162:	6605                	lui	a2,0x1
ffffffffc0201164:	4581                	li	a1,0
ffffffffc0201166:	953e                	add	a0,a0,a5
ffffffffc0201168:	7e9020ef          	jal	ra,ffffffffc0204150 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020116c:	000bb683          	ld	a3,0(s7)
ffffffffc0201170:	40d486b3          	sub	a3,s1,a3
ffffffffc0201174:	868d                	srai	a3,a3,0x3
ffffffffc0201176:	036686b3          	mul	a3,a3,s6
ffffffffc020117a:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020117c:	06aa                	slli	a3,a3,0xa
ffffffffc020117e:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201182:	e014                	sd	a3,0(s0)
ffffffffc0201184:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201188:	068a                	slli	a3,a3,0x2
ffffffffc020118a:	757d                	lui	a0,0xfffff
ffffffffc020118c:	8ee9                	and	a3,a3,a0
ffffffffc020118e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201192:	04e7f563          	bleu	a4,a5,ffffffffc02011dc <get_pte+0x1b2>
ffffffffc0201196:	000ab503          	ld	a0,0(s5)
ffffffffc020119a:	00c95793          	srli	a5,s2,0xc
ffffffffc020119e:	1ff7f793          	andi	a5,a5,511
ffffffffc02011a2:	96aa                	add	a3,a3,a0
ffffffffc02011a4:	00379513          	slli	a0,a5,0x3
ffffffffc02011a8:	9536                	add	a0,a0,a3
}
ffffffffc02011aa:	60a6                	ld	ra,72(sp)
ffffffffc02011ac:	6406                	ld	s0,64(sp)
ffffffffc02011ae:	74e2                	ld	s1,56(sp)
ffffffffc02011b0:	7942                	ld	s2,48(sp)
ffffffffc02011b2:	79a2                	ld	s3,40(sp)
ffffffffc02011b4:	7a02                	ld	s4,32(sp)
ffffffffc02011b6:	6ae2                	ld	s5,24(sp)
ffffffffc02011b8:	6b42                	ld	s6,16(sp)
ffffffffc02011ba:	6ba2                	ld	s7,8(sp)
ffffffffc02011bc:	6161                	addi	sp,sp,80
ffffffffc02011be:	8082                	ret
            return NULL;
ffffffffc02011c0:	4501                	li	a0,0
ffffffffc02011c2:	b7e5                	j	ffffffffc02011aa <get_pte+0x180>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02011c4:	00004617          	auipc	a2,0x4
ffffffffc02011c8:	ffc60613          	addi	a2,a2,-4 # ffffffffc02051c0 <commands+0xa48>
ffffffffc02011cc:	10800593          	li	a1,264
ffffffffc02011d0:	00004517          	auipc	a0,0x4
ffffffffc02011d4:	01850513          	addi	a0,a0,24 # ffffffffc02051e8 <commands+0xa70>
ffffffffc02011d8:	f2ffe0ef          	jal	ra,ffffffffc0200106 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02011dc:	00004617          	auipc	a2,0x4
ffffffffc02011e0:	fe460613          	addi	a2,a2,-28 # ffffffffc02051c0 <commands+0xa48>
ffffffffc02011e4:	11500593          	li	a1,277
ffffffffc02011e8:	00004517          	auipc	a0,0x4
ffffffffc02011ec:	00050513          	mv	a0,a0
ffffffffc02011f0:	f17fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc02011f4:	86aa                	mv	a3,a0
ffffffffc02011f6:	00004617          	auipc	a2,0x4
ffffffffc02011fa:	fca60613          	addi	a2,a2,-54 # ffffffffc02051c0 <commands+0xa48>
ffffffffc02011fe:	11100593          	li	a1,273
ffffffffc0201202:	00004517          	auipc	a0,0x4
ffffffffc0201206:	fe650513          	addi	a0,a0,-26 # ffffffffc02051e8 <commands+0xa70>
ffffffffc020120a:	efdfe0ef          	jal	ra,ffffffffc0200106 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020120e:	86aa                	mv	a3,a0
ffffffffc0201210:	00004617          	auipc	a2,0x4
ffffffffc0201214:	fb060613          	addi	a2,a2,-80 # ffffffffc02051c0 <commands+0xa48>
ffffffffc0201218:	10300593          	li	a1,259
ffffffffc020121c:	00004517          	auipc	a0,0x4
ffffffffc0201220:	fcc50513          	addi	a0,a0,-52 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201224:	ee3fe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0201228 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201228:	1141                	addi	sp,sp,-16
ffffffffc020122a:	e022                	sd	s0,0(sp)
ffffffffc020122c:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020122e:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201230:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201232:	df9ff0ef          	jal	ra,ffffffffc020102a <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201236:	c011                	beqz	s0,ffffffffc020123a <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201238:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020123a:	c521                	beqz	a0,ffffffffc0201282 <get_page+0x5a>
ffffffffc020123c:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc020123e:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201240:	0017f713          	andi	a4,a5,1
ffffffffc0201244:	e709                	bnez	a4,ffffffffc020124e <get_page+0x26>
}
ffffffffc0201246:	60a2                	ld	ra,8(sp)
ffffffffc0201248:	6402                	ld	s0,0(sp)
ffffffffc020124a:	0141                	addi	sp,sp,16
ffffffffc020124c:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc020124e:	00010717          	auipc	a4,0x10
ffffffffc0201252:	20a70713          	addi	a4,a4,522 # ffffffffc0211458 <npage>
ffffffffc0201256:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201258:	078a                	slli	a5,a5,0x2
ffffffffc020125a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020125c:	02e7f863          	bleu	a4,a5,ffffffffc020128c <get_page+0x64>
    return &pages[PPN(pa) - nbase];
ffffffffc0201260:	fff80537          	lui	a0,0xfff80
ffffffffc0201264:	97aa                	add	a5,a5,a0
ffffffffc0201266:	00010697          	auipc	a3,0x10
ffffffffc020126a:	24268693          	addi	a3,a3,578 # ffffffffc02114a8 <pages>
ffffffffc020126e:	6288                	ld	a0,0(a3)
ffffffffc0201270:	60a2                	ld	ra,8(sp)
ffffffffc0201272:	6402                	ld	s0,0(sp)
ffffffffc0201274:	00379713          	slli	a4,a5,0x3
ffffffffc0201278:	97ba                	add	a5,a5,a4
ffffffffc020127a:	078e                	slli	a5,a5,0x3
ffffffffc020127c:	953e                	add	a0,a0,a5
ffffffffc020127e:	0141                	addi	sp,sp,16
ffffffffc0201280:	8082                	ret
ffffffffc0201282:	60a2                	ld	ra,8(sp)
ffffffffc0201284:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0201286:	4501                	li	a0,0
}
ffffffffc0201288:	0141                	addi	sp,sp,16
ffffffffc020128a:	8082                	ret
ffffffffc020128c:	c75ff0ef          	jal	ra,ffffffffc0200f00 <pa2page.part.4>

ffffffffc0201290 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201290:	1141                	addi	sp,sp,-16
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201292:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201294:	e406                	sd	ra,8(sp)
ffffffffc0201296:	e022                	sd	s0,0(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201298:	d93ff0ef          	jal	ra,ffffffffc020102a <get_pte>
    if (ptep != NULL) {
ffffffffc020129c:	c511                	beqz	a0,ffffffffc02012a8 <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc020129e:	611c                	ld	a5,0(a0)
ffffffffc02012a0:	842a                	mv	s0,a0
ffffffffc02012a2:	0017f713          	andi	a4,a5,1
ffffffffc02012a6:	e709                	bnez	a4,ffffffffc02012b0 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc02012a8:	60a2                	ld	ra,8(sp)
ffffffffc02012aa:	6402                	ld	s0,0(sp)
ffffffffc02012ac:	0141                	addi	sp,sp,16
ffffffffc02012ae:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02012b0:	00010717          	auipc	a4,0x10
ffffffffc02012b4:	1a870713          	addi	a4,a4,424 # ffffffffc0211458 <npage>
ffffffffc02012b8:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02012ba:	078a                	slli	a5,a5,0x2
ffffffffc02012bc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02012be:	04e7f063          	bleu	a4,a5,ffffffffc02012fe <page_remove+0x6e>
    return &pages[PPN(pa) - nbase];
ffffffffc02012c2:	fff80737          	lui	a4,0xfff80
ffffffffc02012c6:	97ba                	add	a5,a5,a4
ffffffffc02012c8:	00010717          	auipc	a4,0x10
ffffffffc02012cc:	1e070713          	addi	a4,a4,480 # ffffffffc02114a8 <pages>
ffffffffc02012d0:	6308                	ld	a0,0(a4)
ffffffffc02012d2:	00379713          	slli	a4,a5,0x3
ffffffffc02012d6:	97ba                	add	a5,a5,a4
ffffffffc02012d8:	078e                	slli	a5,a5,0x3
ffffffffc02012da:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02012dc:	411c                	lw	a5,0(a0)
ffffffffc02012de:	fff7871b          	addiw	a4,a5,-1
ffffffffc02012e2:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02012e4:	cb09                	beqz	a4,ffffffffc02012f6 <page_remove+0x66>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02012e6:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc02012ea:	12000073          	sfence.vma
}
ffffffffc02012ee:	60a2                	ld	ra,8(sp)
ffffffffc02012f0:	6402                	ld	s0,0(sp)
ffffffffc02012f2:	0141                	addi	sp,sp,16
ffffffffc02012f4:	8082                	ret
            free_page(page);
ffffffffc02012f6:	4585                	li	a1,1
ffffffffc02012f8:	cadff0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
ffffffffc02012fc:	b7ed                	j	ffffffffc02012e6 <page_remove+0x56>
ffffffffc02012fe:	c03ff0ef          	jal	ra,ffffffffc0200f00 <pa2page.part.4>

ffffffffc0201302 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201302:	7179                	addi	sp,sp,-48
ffffffffc0201304:	87b2                	mv	a5,a2
ffffffffc0201306:	f022                	sd	s0,32(sp)
    //pgdir是页表基址(satp)，page对应物理页面，la是虚拟地址
    
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201308:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020130a:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020130c:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020130e:	ec26                	sd	s1,24(sp)
ffffffffc0201310:	f406                	sd	ra,40(sp)
ffffffffc0201312:	e84a                	sd	s2,16(sp)
ffffffffc0201314:	e44e                	sd	s3,8(sp)
ffffffffc0201316:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201318:	d13ff0ef          	jal	ra,ffffffffc020102a <get_pte>
    //先找到对应页表项的位置，如果原先不存在，get_pte()会分配页表项的内存

    if (ptep == NULL) {
ffffffffc020131c:	c945                	beqz	a0,ffffffffc02013cc <page_insert+0xca>
    page->ref += 1;
ffffffffc020131e:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0201320:	611c                	ld	a5,0(a0)
ffffffffc0201322:	892a                	mv	s2,a0
ffffffffc0201324:	0016871b          	addiw	a4,a3,1
ffffffffc0201328:	c018                	sw	a4,0(s0)
ffffffffc020132a:	0017f713          	andi	a4,a5,1
ffffffffc020132e:	e339                	bnez	a4,ffffffffc0201374 <page_insert+0x72>
ffffffffc0201330:	00010797          	auipc	a5,0x10
ffffffffc0201334:	17878793          	addi	a5,a5,376 # ffffffffc02114a8 <pages>
ffffffffc0201338:	639c                	ld	a5,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020133a:	00004717          	auipc	a4,0x4
ffffffffc020133e:	e7e70713          	addi	a4,a4,-386 # ffffffffc02051b8 <commands+0xa40>
ffffffffc0201342:	40f407b3          	sub	a5,s0,a5
ffffffffc0201346:	6300                	ld	s0,0(a4)
ffffffffc0201348:	878d                	srai	a5,a5,0x3
ffffffffc020134a:	000806b7          	lui	a3,0x80
ffffffffc020134e:	028787b3          	mul	a5,a5,s0
ffffffffc0201352:	97b6                	add	a5,a5,a3
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201354:	07aa                	slli	a5,a5,0xa
ffffffffc0201356:	8fc5                	or	a5,a5,s1
ffffffffc0201358:	0017e793          	ori	a5,a5,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc020135c:	00f93023          	sd	a5,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201360:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0201364:	4501                	li	a0,0
}
ffffffffc0201366:	70a2                	ld	ra,40(sp)
ffffffffc0201368:	7402                	ld	s0,32(sp)
ffffffffc020136a:	64e2                	ld	s1,24(sp)
ffffffffc020136c:	6942                	ld	s2,16(sp)
ffffffffc020136e:	69a2                	ld	s3,8(sp)
ffffffffc0201370:	6145                	addi	sp,sp,48
ffffffffc0201372:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201374:	00010717          	auipc	a4,0x10
ffffffffc0201378:	0e470713          	addi	a4,a4,228 # ffffffffc0211458 <npage>
ffffffffc020137c:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc020137e:	00279513          	slli	a0,a5,0x2
ffffffffc0201382:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201384:	04e57663          	bleu	a4,a0,ffffffffc02013d0 <page_insert+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0201388:	fff807b7          	lui	a5,0xfff80
ffffffffc020138c:	953e                	add	a0,a0,a5
ffffffffc020138e:	00010997          	auipc	s3,0x10
ffffffffc0201392:	11a98993          	addi	s3,s3,282 # ffffffffc02114a8 <pages>
ffffffffc0201396:	0009b783          	ld	a5,0(s3)
ffffffffc020139a:	00351713          	slli	a4,a0,0x3
ffffffffc020139e:	953a                	add	a0,a0,a4
ffffffffc02013a0:	050e                	slli	a0,a0,0x3
ffffffffc02013a2:	953e                	add	a0,a0,a5
        if (p == page) {
ffffffffc02013a4:	00a40e63          	beq	s0,a0,ffffffffc02013c0 <page_insert+0xbe>
    page->ref -= 1;
ffffffffc02013a8:	411c                	lw	a5,0(a0)
ffffffffc02013aa:	fff7871b          	addiw	a4,a5,-1
ffffffffc02013ae:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02013b0:	cb11                	beqz	a4,ffffffffc02013c4 <page_insert+0xc2>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02013b2:	00093023          	sd	zero,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc02013b6:	12000073          	sfence.vma
ffffffffc02013ba:	0009b783          	ld	a5,0(s3)
ffffffffc02013be:	bfb5                	j	ffffffffc020133a <page_insert+0x38>
    page->ref -= 1;
ffffffffc02013c0:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc02013c2:	bfa5                	j	ffffffffc020133a <page_insert+0x38>
            free_page(page);
ffffffffc02013c4:	4585                	li	a1,1
ffffffffc02013c6:	bdfff0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
ffffffffc02013ca:	b7e5                	j	ffffffffc02013b2 <page_insert+0xb0>
        return -E_NO_MEM;
ffffffffc02013cc:	5571                	li	a0,-4
ffffffffc02013ce:	bf61                	j	ffffffffc0201366 <page_insert+0x64>
ffffffffc02013d0:	b31ff0ef          	jal	ra,ffffffffc0200f00 <pa2page.part.4>

ffffffffc02013d4 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc02013d4:	00005797          	auipc	a5,0x5
ffffffffc02013d8:	eb478793          	addi	a5,a5,-332 # ffffffffc0206288 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02013dc:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc02013de:	711d                	addi	sp,sp,-96
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02013e0:	00004517          	auipc	a0,0x4
ffffffffc02013e4:	ea050513          	addi	a0,a0,-352 # ffffffffc0205280 <commands+0xb08>
void pmm_init(void) {
ffffffffc02013e8:	ec86                	sd	ra,88(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02013ea:	00010717          	auipc	a4,0x10
ffffffffc02013ee:	0af73323          	sd	a5,166(a4) # ffffffffc0211490 <pmm_manager>
void pmm_init(void) {
ffffffffc02013f2:	e8a2                	sd	s0,80(sp)
ffffffffc02013f4:	e4a6                	sd	s1,72(sp)
ffffffffc02013f6:	e0ca                	sd	s2,64(sp)
ffffffffc02013f8:	fc4e                	sd	s3,56(sp)
ffffffffc02013fa:	f852                	sd	s4,48(sp)
ffffffffc02013fc:	f456                	sd	s5,40(sp)
ffffffffc02013fe:	f05a                	sd	s6,32(sp)
ffffffffc0201400:	ec5e                	sd	s7,24(sp)
ffffffffc0201402:	e862                	sd	s8,16(sp)
ffffffffc0201404:	e466                	sd	s9,8(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201406:	00010417          	auipc	s0,0x10
ffffffffc020140a:	08a40413          	addi	s0,s0,138 # ffffffffc0211490 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020140e:	cb1fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pmm_manager->init();
ffffffffc0201412:	601c                	ld	a5,0(s0)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201414:	49c5                	li	s3,17
ffffffffc0201416:	40100a13          	li	s4,1025
    pmm_manager->init();
ffffffffc020141a:	679c                	ld	a5,8(a5)
ffffffffc020141c:	00010497          	auipc	s1,0x10
ffffffffc0201420:	03c48493          	addi	s1,s1,60 # ffffffffc0211458 <npage>
ffffffffc0201424:	00010917          	auipc	s2,0x10
ffffffffc0201428:	08490913          	addi	s2,s2,132 # ffffffffc02114a8 <pages>
ffffffffc020142c:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020142e:	57f5                	li	a5,-3
ffffffffc0201430:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201432:	07e006b7          	lui	a3,0x7e00
ffffffffc0201436:	01b99613          	slli	a2,s3,0x1b
ffffffffc020143a:	015a1593          	slli	a1,s4,0x15
ffffffffc020143e:	00004517          	auipc	a0,0x4
ffffffffc0201442:	e5a50513          	addi	a0,a0,-422 # ffffffffc0205298 <commands+0xb20>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201446:	00010717          	auipc	a4,0x10
ffffffffc020144a:	04f73923          	sd	a5,82(a4) # ffffffffc0211498 <va_pa_offset>
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc020144e:	c71fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201452:	00004517          	auipc	a0,0x4
ffffffffc0201456:	e7650513          	addi	a0,a0,-394 # ffffffffc02052c8 <commands+0xb50>
ffffffffc020145a:	c65fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc020145e:	01b99693          	slli	a3,s3,0x1b
ffffffffc0201462:	16fd                	addi	a3,a3,-1
ffffffffc0201464:	015a1613          	slli	a2,s4,0x15
ffffffffc0201468:	07e005b7          	lui	a1,0x7e00
ffffffffc020146c:	00004517          	auipc	a0,0x4
ffffffffc0201470:	e7450513          	addi	a0,a0,-396 # ffffffffc02052e0 <commands+0xb68>
ffffffffc0201474:	c4bfe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201478:	777d                	lui	a4,0xfffff
ffffffffc020147a:	00011797          	auipc	a5,0x11
ffffffffc020147e:	11d78793          	addi	a5,a5,285 # ffffffffc0212597 <end+0xfff>
ffffffffc0201482:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201484:	00088737          	lui	a4,0x88
ffffffffc0201488:	00010697          	auipc	a3,0x10
ffffffffc020148c:	fce6b823          	sd	a4,-48(a3) # ffffffffc0211458 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201490:	00010717          	auipc	a4,0x10
ffffffffc0201494:	00f73c23          	sd	a5,24(a4) # ffffffffc02114a8 <pages>
ffffffffc0201498:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020149a:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020149c:	4585                	li	a1,1
ffffffffc020149e:	fff80637          	lui	a2,0xfff80
ffffffffc02014a2:	a019                	j	ffffffffc02014a8 <pmm_init+0xd4>
ffffffffc02014a4:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc02014a8:	97b6                	add	a5,a5,a3
ffffffffc02014aa:	07a1                	addi	a5,a5,8
ffffffffc02014ac:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02014b0:	609c                	ld	a5,0(s1)
ffffffffc02014b2:	0705                	addi	a4,a4,1
ffffffffc02014b4:	04868693          	addi	a3,a3,72
ffffffffc02014b8:	00c78533          	add	a0,a5,a2
ffffffffc02014bc:	fea764e3          	bltu	a4,a0,ffffffffc02014a4 <pmm_init+0xd0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02014c0:	00093503          	ld	a0,0(s2)
ffffffffc02014c4:	00379693          	slli	a3,a5,0x3
ffffffffc02014c8:	96be                	add	a3,a3,a5
ffffffffc02014ca:	fdc00737          	lui	a4,0xfdc00
ffffffffc02014ce:	972a                	add	a4,a4,a0
ffffffffc02014d0:	068e                	slli	a3,a3,0x3
ffffffffc02014d2:	96ba                	add	a3,a3,a4
ffffffffc02014d4:	c0200737          	lui	a4,0xc0200
ffffffffc02014d8:	58e6ea63          	bltu	a3,a4,ffffffffc0201a6c <pmm_init+0x698>
ffffffffc02014dc:	00010997          	auipc	s3,0x10
ffffffffc02014e0:	fbc98993          	addi	s3,s3,-68 # ffffffffc0211498 <va_pa_offset>
ffffffffc02014e4:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc02014e8:	45c5                	li	a1,17
ffffffffc02014ea:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02014ec:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02014ee:	44b6ef63          	bltu	a3,a1,ffffffffc020194c <pmm_init+0x578>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02014f2:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02014f4:	00010417          	auipc	s0,0x10
ffffffffc02014f8:	f5c40413          	addi	s0,s0,-164 # ffffffffc0211450 <boot_pgdir>
    pmm_manager->check();
ffffffffc02014fc:	7b9c                	ld	a5,48(a5)
ffffffffc02014fe:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201500:	00004517          	auipc	a0,0x4
ffffffffc0201504:	e3050513          	addi	a0,a0,-464 # ffffffffc0205330 <commands+0xbb8>
ffffffffc0201508:	bb7fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020150c:	00008697          	auipc	a3,0x8
ffffffffc0201510:	af468693          	addi	a3,a3,-1292 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201514:	00010797          	auipc	a5,0x10
ffffffffc0201518:	f2d7be23          	sd	a3,-196(a5) # ffffffffc0211450 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020151c:	c02007b7          	lui	a5,0xc0200
ffffffffc0201520:	0ef6ece3          	bltu	a3,a5,ffffffffc0201e18 <pmm_init+0xa44>
ffffffffc0201524:	0009b783          	ld	a5,0(s3)
ffffffffc0201528:	8e9d                	sub	a3,a3,a5
ffffffffc020152a:	00010797          	auipc	a5,0x10
ffffffffc020152e:	f6d7bb23          	sd	a3,-138(a5) # ffffffffc02114a0 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0201532:	ab9ff0ef          	jal	ra,ffffffffc0200fea <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201536:	6098                	ld	a4,0(s1)
ffffffffc0201538:	c80007b7          	lui	a5,0xc8000
ffffffffc020153c:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc020153e:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201540:	0ae7ece3          	bltu	a5,a4,ffffffffc0201df8 <pmm_init+0xa24>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201544:	6008                	ld	a0,0(s0)
ffffffffc0201546:	4c050363          	beqz	a0,ffffffffc0201a0c <pmm_init+0x638>
ffffffffc020154a:	6785                	lui	a5,0x1
ffffffffc020154c:	17fd                	addi	a5,a5,-1
ffffffffc020154e:	8fe9                	and	a5,a5,a0
ffffffffc0201550:	2781                	sext.w	a5,a5
ffffffffc0201552:	4a079d63          	bnez	a5,ffffffffc0201a0c <pmm_init+0x638>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201556:	4601                	li	a2,0
ffffffffc0201558:	4581                	li	a1,0
ffffffffc020155a:	ccfff0ef          	jal	ra,ffffffffc0201228 <get_page>
ffffffffc020155e:	4c051763          	bnez	a0,ffffffffc0201a2c <pmm_init+0x658>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201562:	4505                	li	a0,1
ffffffffc0201564:	9b9ff0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0201568:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020156a:	6008                	ld	a0,0(s0)
ffffffffc020156c:	4681                	li	a3,0
ffffffffc020156e:	4601                	li	a2,0
ffffffffc0201570:	85d6                	mv	a1,s5
ffffffffc0201572:	d91ff0ef          	jal	ra,ffffffffc0201302 <page_insert>
ffffffffc0201576:	52051763          	bnez	a0,ffffffffc0201aa4 <pmm_init+0x6d0>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020157a:	6008                	ld	a0,0(s0)
ffffffffc020157c:	4601                	li	a2,0
ffffffffc020157e:	4581                	li	a1,0
ffffffffc0201580:	aabff0ef          	jal	ra,ffffffffc020102a <get_pte>
ffffffffc0201584:	50050063          	beqz	a0,ffffffffc0201a84 <pmm_init+0x6b0>
    assert(pte2page(*ptep) == p1);
ffffffffc0201588:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020158a:	0017f713          	andi	a4,a5,1
ffffffffc020158e:	46070363          	beqz	a4,ffffffffc02019f4 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0201592:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201594:	078a                	slli	a5,a5,0x2
ffffffffc0201596:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201598:	44c7f063          	bleu	a2,a5,ffffffffc02019d8 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc020159c:	fff80737          	lui	a4,0xfff80
ffffffffc02015a0:	97ba                	add	a5,a5,a4
ffffffffc02015a2:	00379713          	slli	a4,a5,0x3
ffffffffc02015a6:	00093683          	ld	a3,0(s2)
ffffffffc02015aa:	97ba                	add	a5,a5,a4
ffffffffc02015ac:	078e                	slli	a5,a5,0x3
ffffffffc02015ae:	97b6                	add	a5,a5,a3
ffffffffc02015b0:	5efa9463          	bne	s5,a5,ffffffffc0201b98 <pmm_init+0x7c4>
    assert(page_ref(p1) == 1);
ffffffffc02015b4:	000aab83          	lw	s7,0(s5)
ffffffffc02015b8:	4785                	li	a5,1
ffffffffc02015ba:	5afb9f63          	bne	s7,a5,ffffffffc0201b78 <pmm_init+0x7a4>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02015be:	6008                	ld	a0,0(s0)
ffffffffc02015c0:	76fd                	lui	a3,0xfffff
ffffffffc02015c2:	611c                	ld	a5,0(a0)
ffffffffc02015c4:	078a                	slli	a5,a5,0x2
ffffffffc02015c6:	8ff5                	and	a5,a5,a3
ffffffffc02015c8:	00c7d713          	srli	a4,a5,0xc
ffffffffc02015cc:	58c77963          	bleu	a2,a4,ffffffffc0201b5e <pmm_init+0x78a>
ffffffffc02015d0:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02015d4:	97e2                	add	a5,a5,s8
ffffffffc02015d6:	0007bb03          	ld	s6,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc02015da:	0b0a                	slli	s6,s6,0x2
ffffffffc02015dc:	00db7b33          	and	s6,s6,a3
ffffffffc02015e0:	00cb5793          	srli	a5,s6,0xc
ffffffffc02015e4:	56c7f063          	bleu	a2,a5,ffffffffc0201b44 <pmm_init+0x770>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02015e8:	4601                	li	a2,0
ffffffffc02015ea:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02015ec:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02015ee:	a3dff0ef          	jal	ra,ffffffffc020102a <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02015f2:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02015f4:	53651863          	bne	a0,s6,ffffffffc0201b24 <pmm_init+0x750>

    p2 = alloc_page();
ffffffffc02015f8:	4505                	li	a0,1
ffffffffc02015fa:	923ff0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc02015fe:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201600:	6008                	ld	a0,0(s0)
ffffffffc0201602:	46d1                	li	a3,20
ffffffffc0201604:	6605                	lui	a2,0x1
ffffffffc0201606:	85da                	mv	a1,s6
ffffffffc0201608:	cfbff0ef          	jal	ra,ffffffffc0201302 <page_insert>
ffffffffc020160c:	4e051c63          	bnez	a0,ffffffffc0201b04 <pmm_init+0x730>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201610:	6008                	ld	a0,0(s0)
ffffffffc0201612:	4601                	li	a2,0
ffffffffc0201614:	6585                	lui	a1,0x1
ffffffffc0201616:	a15ff0ef          	jal	ra,ffffffffc020102a <get_pte>
ffffffffc020161a:	4c050563          	beqz	a0,ffffffffc0201ae4 <pmm_init+0x710>
    assert(*ptep & PTE_U);
ffffffffc020161e:	611c                	ld	a5,0(a0)
ffffffffc0201620:	0107f713          	andi	a4,a5,16
ffffffffc0201624:	4a070063          	beqz	a4,ffffffffc0201ac4 <pmm_init+0x6f0>
    assert(*ptep & PTE_W);
ffffffffc0201628:	8b91                	andi	a5,a5,4
ffffffffc020162a:	66078763          	beqz	a5,ffffffffc0201c98 <pmm_init+0x8c4>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020162e:	6008                	ld	a0,0(s0)
ffffffffc0201630:	611c                	ld	a5,0(a0)
ffffffffc0201632:	8bc1                	andi	a5,a5,16
ffffffffc0201634:	64078263          	beqz	a5,ffffffffc0201c78 <pmm_init+0x8a4>
    assert(page_ref(p2) == 1);
ffffffffc0201638:	000b2783          	lw	a5,0(s6)
ffffffffc020163c:	61779e63          	bne	a5,s7,ffffffffc0201c58 <pmm_init+0x884>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201640:	4681                	li	a3,0
ffffffffc0201642:	6605                	lui	a2,0x1
ffffffffc0201644:	85d6                	mv	a1,s5
ffffffffc0201646:	cbdff0ef          	jal	ra,ffffffffc0201302 <page_insert>
ffffffffc020164a:	5e051763          	bnez	a0,ffffffffc0201c38 <pmm_init+0x864>
    assert(page_ref(p1) == 2);
ffffffffc020164e:	000aa703          	lw	a4,0(s5)
ffffffffc0201652:	4789                	li	a5,2
ffffffffc0201654:	5cf71263          	bne	a4,a5,ffffffffc0201c18 <pmm_init+0x844>
    assert(page_ref(p2) == 0);
ffffffffc0201658:	000b2783          	lw	a5,0(s6)
ffffffffc020165c:	58079e63          	bnez	a5,ffffffffc0201bf8 <pmm_init+0x824>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201660:	6008                	ld	a0,0(s0)
ffffffffc0201662:	4601                	li	a2,0
ffffffffc0201664:	6585                	lui	a1,0x1
ffffffffc0201666:	9c5ff0ef          	jal	ra,ffffffffc020102a <get_pte>
ffffffffc020166a:	56050763          	beqz	a0,ffffffffc0201bd8 <pmm_init+0x804>
    assert(pte2page(*ptep) == p1);
ffffffffc020166e:	6114                	ld	a3,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201670:	0016f793          	andi	a5,a3,1
ffffffffc0201674:	38078063          	beqz	a5,ffffffffc02019f4 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0201678:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020167a:	00269793          	slli	a5,a3,0x2
ffffffffc020167e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201680:	34e7fc63          	bleu	a4,a5,ffffffffc02019d8 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201684:	fff80737          	lui	a4,0xfff80
ffffffffc0201688:	97ba                	add	a5,a5,a4
ffffffffc020168a:	00379713          	slli	a4,a5,0x3
ffffffffc020168e:	00093603          	ld	a2,0(s2)
ffffffffc0201692:	97ba                	add	a5,a5,a4
ffffffffc0201694:	078e                	slli	a5,a5,0x3
ffffffffc0201696:	97b2                	add	a5,a5,a2
ffffffffc0201698:	52fa9063          	bne	s5,a5,ffffffffc0201bb8 <pmm_init+0x7e4>
    assert((*ptep & PTE_U) == 0);
ffffffffc020169c:	8ac1                	andi	a3,a3,16
ffffffffc020169e:	6e069d63          	bnez	a3,ffffffffc0201d98 <pmm_init+0x9c4>

    page_remove(boot_pgdir, 0x0);
ffffffffc02016a2:	6008                	ld	a0,0(s0)
ffffffffc02016a4:	4581                	li	a1,0
ffffffffc02016a6:	bebff0ef          	jal	ra,ffffffffc0201290 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02016aa:	000aa703          	lw	a4,0(s5)
ffffffffc02016ae:	4785                	li	a5,1
ffffffffc02016b0:	6cf71463          	bne	a4,a5,ffffffffc0201d78 <pmm_init+0x9a4>
    assert(page_ref(p2) == 0);
ffffffffc02016b4:	000b2783          	lw	a5,0(s6)
ffffffffc02016b8:	6a079063          	bnez	a5,ffffffffc0201d58 <pmm_init+0x984>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02016bc:	6008                	ld	a0,0(s0)
ffffffffc02016be:	6585                	lui	a1,0x1
ffffffffc02016c0:	bd1ff0ef          	jal	ra,ffffffffc0201290 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02016c4:	000aa783          	lw	a5,0(s5)
ffffffffc02016c8:	66079863          	bnez	a5,ffffffffc0201d38 <pmm_init+0x964>
    assert(page_ref(p2) == 0);
ffffffffc02016cc:	000b2783          	lw	a5,0(s6)
ffffffffc02016d0:	70079463          	bnez	a5,ffffffffc0201dd8 <pmm_init+0xa04>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02016d4:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02016d8:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02016da:	000b3783          	ld	a5,0(s6)
ffffffffc02016de:	078a                	slli	a5,a5,0x2
ffffffffc02016e0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02016e2:	2eb7fb63          	bleu	a1,a5,ffffffffc02019d8 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc02016e6:	fff80737          	lui	a4,0xfff80
ffffffffc02016ea:	973e                	add	a4,a4,a5
ffffffffc02016ec:	00371793          	slli	a5,a4,0x3
ffffffffc02016f0:	00093603          	ld	a2,0(s2)
ffffffffc02016f4:	97ba                	add	a5,a5,a4
ffffffffc02016f6:	078e                	slli	a5,a5,0x3
ffffffffc02016f8:	00f60733          	add	a4,a2,a5
ffffffffc02016fc:	4314                	lw	a3,0(a4)
ffffffffc02016fe:	4705                	li	a4,1
ffffffffc0201700:	6ae69c63          	bne	a3,a4,ffffffffc0201db8 <pmm_init+0x9e4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201704:	00004a97          	auipc	s5,0x4
ffffffffc0201708:	ab4a8a93          	addi	s5,s5,-1356 # ffffffffc02051b8 <commands+0xa40>
ffffffffc020170c:	000ab703          	ld	a4,0(s5)
ffffffffc0201710:	4037d693          	srai	a3,a5,0x3
ffffffffc0201714:	00080bb7          	lui	s7,0x80
ffffffffc0201718:	02e686b3          	mul	a3,a3,a4
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020171c:	577d                	li	a4,-1
ffffffffc020171e:	8331                	srli	a4,a4,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201720:	96de                	add	a3,a3,s7
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201722:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201724:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201726:	2ab77b63          	bleu	a1,a4,ffffffffc02019dc <pmm_init+0x608>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc020172a:	0009b783          	ld	a5,0(s3)
ffffffffc020172e:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201730:	629c                	ld	a5,0(a3)
ffffffffc0201732:	078a                	slli	a5,a5,0x2
ffffffffc0201734:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201736:	2ab7f163          	bleu	a1,a5,ffffffffc02019d8 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc020173a:	417787b3          	sub	a5,a5,s7
ffffffffc020173e:	00379513          	slli	a0,a5,0x3
ffffffffc0201742:	97aa                	add	a5,a5,a0
ffffffffc0201744:	00379513          	slli	a0,a5,0x3
ffffffffc0201748:	9532                	add	a0,a0,a2
ffffffffc020174a:	4585                	li	a1,1
ffffffffc020174c:	859ff0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201750:	000b3503          	ld	a0,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201754:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201756:	050a                	slli	a0,a0,0x2
ffffffffc0201758:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc020175a:	26f57f63          	bleu	a5,a0,ffffffffc02019d8 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc020175e:	417507b3          	sub	a5,a0,s7
ffffffffc0201762:	00379513          	slli	a0,a5,0x3
ffffffffc0201766:	00093703          	ld	a4,0(s2)
ffffffffc020176a:	953e                	add	a0,a0,a5
ffffffffc020176c:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc020176e:	4585                	li	a1,1
ffffffffc0201770:	953a                	add	a0,a0,a4
ffffffffc0201772:	833ff0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0201776:	601c                	ld	a5,0(s0)
ffffffffc0201778:	0007b023          	sd	zero,0(a5)

    assert(nr_free_store==nr_free_pages());
ffffffffc020177c:	86fff0ef          	jal	ra,ffffffffc0200fea <nr_free_pages>
ffffffffc0201780:	2caa1663          	bne	s4,a0,ffffffffc0201a4c <pmm_init+0x678>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201784:	00004517          	auipc	a0,0x4
ffffffffc0201788:	ebc50513          	addi	a0,a0,-324 # ffffffffc0205640 <commands+0xec8>
ffffffffc020178c:	933fe0ef          	jal	ra,ffffffffc02000be <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0201790:	85bff0ef          	jal	ra,ffffffffc0200fea <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201794:	6098                	ld	a4,0(s1)
ffffffffc0201796:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc020179a:	8b2a                	mv	s6,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020179c:	00c71693          	slli	a3,a4,0xc
ffffffffc02017a0:	1cd7fd63          	bleu	a3,a5,ffffffffc020197a <pmm_init+0x5a6>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02017a4:	83b1                	srli	a5,a5,0xc
ffffffffc02017a6:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02017a8:	c0200a37          	lui	s4,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02017ac:	1ce7f963          	bleu	a4,a5,ffffffffc020197e <pmm_init+0x5aa>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02017b0:	7c7d                	lui	s8,0xfffff
ffffffffc02017b2:	6b85                	lui	s7,0x1
ffffffffc02017b4:	a029                	j	ffffffffc02017be <pmm_init+0x3ea>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02017b6:	00ca5713          	srli	a4,s4,0xc
ffffffffc02017ba:	1cf77263          	bleu	a5,a4,ffffffffc020197e <pmm_init+0x5aa>
ffffffffc02017be:	0009b583          	ld	a1,0(s3)
ffffffffc02017c2:	4601                	li	a2,0
ffffffffc02017c4:	95d2                	add	a1,a1,s4
ffffffffc02017c6:	865ff0ef          	jal	ra,ffffffffc020102a <get_pte>
ffffffffc02017ca:	1c050763          	beqz	a0,ffffffffc0201998 <pmm_init+0x5c4>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02017ce:	611c                	ld	a5,0(a0)
ffffffffc02017d0:	078a                	slli	a5,a5,0x2
ffffffffc02017d2:	0187f7b3          	and	a5,a5,s8
ffffffffc02017d6:	1f479163          	bne	a5,s4,ffffffffc02019b8 <pmm_init+0x5e4>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02017da:	609c                	ld	a5,0(s1)
ffffffffc02017dc:	9a5e                	add	s4,s4,s7
ffffffffc02017de:	6008                	ld	a0,0(s0)
ffffffffc02017e0:	00c79713          	slli	a4,a5,0xc
ffffffffc02017e4:	fcea69e3          	bltu	s4,a4,ffffffffc02017b6 <pmm_init+0x3e2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc02017e8:	611c                	ld	a5,0(a0)
ffffffffc02017ea:	6a079363          	bnez	a5,ffffffffc0201e90 <pmm_init+0xabc>

    struct Page *p;
    p = alloc_page();
ffffffffc02017ee:	4505                	li	a0,1
ffffffffc02017f0:	f2cff0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc02017f4:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02017f6:	6008                	ld	a0,0(s0)
ffffffffc02017f8:	4699                	li	a3,6
ffffffffc02017fa:	10000613          	li	a2,256
ffffffffc02017fe:	85d2                	mv	a1,s4
ffffffffc0201800:	b03ff0ef          	jal	ra,ffffffffc0201302 <page_insert>
ffffffffc0201804:	66051663          	bnez	a0,ffffffffc0201e70 <pmm_init+0xa9c>
    assert(page_ref(p) == 1);
ffffffffc0201808:	000a2703          	lw	a4,0(s4) # ffffffffc0200000 <kern_entry>
ffffffffc020180c:	4785                	li	a5,1
ffffffffc020180e:	64f71163          	bne	a4,a5,ffffffffc0201e50 <pmm_init+0xa7c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201812:	6008                	ld	a0,0(s0)
ffffffffc0201814:	6b85                	lui	s7,0x1
ffffffffc0201816:	4699                	li	a3,6
ffffffffc0201818:	100b8613          	addi	a2,s7,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc020181c:	85d2                	mv	a1,s4
ffffffffc020181e:	ae5ff0ef          	jal	ra,ffffffffc0201302 <page_insert>
ffffffffc0201822:	60051763          	bnez	a0,ffffffffc0201e30 <pmm_init+0xa5c>
    assert(page_ref(p) == 2);
ffffffffc0201826:	000a2703          	lw	a4,0(s4)
ffffffffc020182a:	4789                	li	a5,2
ffffffffc020182c:	4ef71663          	bne	a4,a5,ffffffffc0201d18 <pmm_init+0x944>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201830:	00004597          	auipc	a1,0x4
ffffffffc0201834:	f4858593          	addi	a1,a1,-184 # ffffffffc0205778 <commands+0x1000>
ffffffffc0201838:	10000513          	li	a0,256
ffffffffc020183c:	0bb020ef          	jal	ra,ffffffffc02040f6 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201840:	100b8593          	addi	a1,s7,256
ffffffffc0201844:	10000513          	li	a0,256
ffffffffc0201848:	0c1020ef          	jal	ra,ffffffffc0204108 <strcmp>
ffffffffc020184c:	4a051663          	bnez	a0,ffffffffc0201cf8 <pmm_init+0x924>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201850:	00093683          	ld	a3,0(s2)
ffffffffc0201854:	000abc83          	ld	s9,0(s5)
ffffffffc0201858:	00080c37          	lui	s8,0x80
ffffffffc020185c:	40da06b3          	sub	a3,s4,a3
ffffffffc0201860:	868d                	srai	a3,a3,0x3
ffffffffc0201862:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201866:	5afd                	li	s5,-1
ffffffffc0201868:	609c                	ld	a5,0(s1)
ffffffffc020186a:	00cada93          	srli	s5,s5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020186e:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201870:	0156f733          	and	a4,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0201874:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201876:	16f77363          	bleu	a5,a4,ffffffffc02019dc <pmm_init+0x608>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020187a:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020187e:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201882:	96be                	add	a3,a3,a5
ffffffffc0201884:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fdedb68>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201888:	02b020ef          	jal	ra,ffffffffc02040b2 <strlen>
ffffffffc020188c:	44051663          	bnez	a0,ffffffffc0201cd8 <pmm_init+0x904>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201890:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201894:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201896:	000bb783          	ld	a5,0(s7)
ffffffffc020189a:	078a                	slli	a5,a5,0x2
ffffffffc020189c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020189e:	12e7fd63          	bleu	a4,a5,ffffffffc02019d8 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc02018a2:	418787b3          	sub	a5,a5,s8
ffffffffc02018a6:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018aa:	96be                	add	a3,a3,a5
ffffffffc02018ac:	039686b3          	mul	a3,a3,s9
ffffffffc02018b0:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02018b2:	0156fab3          	and	s5,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc02018b6:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02018b8:	12eaf263          	bleu	a4,s5,ffffffffc02019dc <pmm_init+0x608>
ffffffffc02018bc:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc02018c0:	4585                	li	a1,1
ffffffffc02018c2:	8552                	mv	a0,s4
ffffffffc02018c4:	99b6                	add	s3,s3,a3
ffffffffc02018c6:	edeff0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02018ca:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc02018ce:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02018d0:	078a                	slli	a5,a5,0x2
ffffffffc02018d2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02018d4:	10e7f263          	bleu	a4,a5,ffffffffc02019d8 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc02018d8:	fff809b7          	lui	s3,0xfff80
ffffffffc02018dc:	97ce                	add	a5,a5,s3
ffffffffc02018de:	00379513          	slli	a0,a5,0x3
ffffffffc02018e2:	00093703          	ld	a4,0(s2)
ffffffffc02018e6:	97aa                	add	a5,a5,a0
ffffffffc02018e8:	00379513          	slli	a0,a5,0x3
    free_page(pde2page(pd0[0]));
ffffffffc02018ec:	953a                	add	a0,a0,a4
ffffffffc02018ee:	4585                	li	a1,1
ffffffffc02018f0:	eb4ff0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02018f4:	000bb503          	ld	a0,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc02018f8:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02018fa:	050a                	slli	a0,a0,0x2
ffffffffc02018fc:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02018fe:	0cf57d63          	bleu	a5,a0,ffffffffc02019d8 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201902:	013507b3          	add	a5,a0,s3
ffffffffc0201906:	00379513          	slli	a0,a5,0x3
ffffffffc020190a:	00093703          	ld	a4,0(s2)
ffffffffc020190e:	953e                	add	a0,a0,a5
ffffffffc0201910:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0201912:	4585                	li	a1,1
ffffffffc0201914:	953a                	add	a0,a0,a4
ffffffffc0201916:	e8eff0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc020191a:	601c                	ld	a5,0(s0)
ffffffffc020191c:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>

    assert(nr_free_store==nr_free_pages());
ffffffffc0201920:	ecaff0ef          	jal	ra,ffffffffc0200fea <nr_free_pages>
ffffffffc0201924:	38ab1a63          	bne	s6,a0,ffffffffc0201cb8 <pmm_init+0x8e4>
}
ffffffffc0201928:	6446                	ld	s0,80(sp)
ffffffffc020192a:	60e6                	ld	ra,88(sp)
ffffffffc020192c:	64a6                	ld	s1,72(sp)
ffffffffc020192e:	6906                	ld	s2,64(sp)
ffffffffc0201930:	79e2                	ld	s3,56(sp)
ffffffffc0201932:	7a42                	ld	s4,48(sp)
ffffffffc0201934:	7aa2                	ld	s5,40(sp)
ffffffffc0201936:	7b02                	ld	s6,32(sp)
ffffffffc0201938:	6be2                	ld	s7,24(sp)
ffffffffc020193a:	6c42                	ld	s8,16(sp)
ffffffffc020193c:	6ca2                	ld	s9,8(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc020193e:	00004517          	auipc	a0,0x4
ffffffffc0201942:	eb250513          	addi	a0,a0,-334 # ffffffffc02057f0 <commands+0x1078>
}
ffffffffc0201946:	6125                	addi	sp,sp,96
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0201948:	f76fe06f          	j	ffffffffc02000be <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020194c:	6705                	lui	a4,0x1
ffffffffc020194e:	177d                	addi	a4,a4,-1
ffffffffc0201950:	96ba                	add	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0201952:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201956:	08f77163          	bleu	a5,a4,ffffffffc02019d8 <pmm_init+0x604>
    pmm_manager->init_memmap(base, n);
ffffffffc020195a:	00043803          	ld	a6,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc020195e:	9732                	add	a4,a4,a2
ffffffffc0201960:	00371793          	slli	a5,a4,0x3
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201964:	767d                	lui	a2,0xfffff
ffffffffc0201966:	8ef1                	and	a3,a3,a2
ffffffffc0201968:	97ba                	add	a5,a5,a4
    pmm_manager->init_memmap(base, n);
ffffffffc020196a:	01083703          	ld	a4,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020196e:	8d95                	sub	a1,a1,a3
ffffffffc0201970:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201972:	81b1                	srli	a1,a1,0xc
ffffffffc0201974:	953e                	add	a0,a0,a5
ffffffffc0201976:	9702                	jalr	a4
ffffffffc0201978:	bead                	j	ffffffffc02014f2 <pmm_init+0x11e>
ffffffffc020197a:	6008                	ld	a0,0(s0)
ffffffffc020197c:	b5b5                	j	ffffffffc02017e8 <pmm_init+0x414>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020197e:	86d2                	mv	a3,s4
ffffffffc0201980:	00004617          	auipc	a2,0x4
ffffffffc0201984:	84060613          	addi	a2,a2,-1984 # ffffffffc02051c0 <commands+0xa48>
ffffffffc0201988:	1d700593          	li	a1,471
ffffffffc020198c:	00004517          	auipc	a0,0x4
ffffffffc0201990:	85c50513          	addi	a0,a0,-1956 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201994:	f72fe0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0201998:	00004697          	auipc	a3,0x4
ffffffffc020199c:	cc868693          	addi	a3,a3,-824 # ffffffffc0205660 <commands+0xee8>
ffffffffc02019a0:	00003617          	auipc	a2,0x3
ffffffffc02019a4:	64860613          	addi	a2,a2,1608 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02019a8:	1d700593          	li	a1,471
ffffffffc02019ac:	00004517          	auipc	a0,0x4
ffffffffc02019b0:	83c50513          	addi	a0,a0,-1988 # ffffffffc02051e8 <commands+0xa70>
ffffffffc02019b4:	f52fe0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02019b8:	00004697          	auipc	a3,0x4
ffffffffc02019bc:	ce868693          	addi	a3,a3,-792 # ffffffffc02056a0 <commands+0xf28>
ffffffffc02019c0:	00003617          	auipc	a2,0x3
ffffffffc02019c4:	62860613          	addi	a2,a2,1576 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02019c8:	1d800593          	li	a1,472
ffffffffc02019cc:	00004517          	auipc	a0,0x4
ffffffffc02019d0:	81c50513          	addi	a0,a0,-2020 # ffffffffc02051e8 <commands+0xa70>
ffffffffc02019d4:	f32fe0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc02019d8:	d28ff0ef          	jal	ra,ffffffffc0200f00 <pa2page.part.4>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02019dc:	00003617          	auipc	a2,0x3
ffffffffc02019e0:	7e460613          	addi	a2,a2,2020 # ffffffffc02051c0 <commands+0xa48>
ffffffffc02019e4:	06a00593          	li	a1,106
ffffffffc02019e8:	00004517          	auipc	a0,0x4
ffffffffc02019ec:	87050513          	addi	a0,a0,-1936 # ffffffffc0205258 <commands+0xae0>
ffffffffc02019f0:	f16fe0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02019f4:	00004617          	auipc	a2,0x4
ffffffffc02019f8:	a3c60613          	addi	a2,a2,-1476 # ffffffffc0205430 <commands+0xcb8>
ffffffffc02019fc:	07000593          	li	a1,112
ffffffffc0201a00:	00004517          	auipc	a0,0x4
ffffffffc0201a04:	85850513          	addi	a0,a0,-1960 # ffffffffc0205258 <commands+0xae0>
ffffffffc0201a08:	efefe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201a0c:	00004697          	auipc	a3,0x4
ffffffffc0201a10:	96468693          	addi	a3,a3,-1692 # ffffffffc0205370 <commands+0xbf8>
ffffffffc0201a14:	00003617          	auipc	a2,0x3
ffffffffc0201a18:	5d460613          	addi	a2,a2,1492 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201a1c:	19d00593          	li	a1,413
ffffffffc0201a20:	00003517          	auipc	a0,0x3
ffffffffc0201a24:	7c850513          	addi	a0,a0,1992 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201a28:	edefe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201a2c:	00004697          	auipc	a3,0x4
ffffffffc0201a30:	97c68693          	addi	a3,a3,-1668 # ffffffffc02053a8 <commands+0xc30>
ffffffffc0201a34:	00003617          	auipc	a2,0x3
ffffffffc0201a38:	5b460613          	addi	a2,a2,1460 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201a3c:	19e00593          	li	a1,414
ffffffffc0201a40:	00003517          	auipc	a0,0x3
ffffffffc0201a44:	7a850513          	addi	a0,a0,1960 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201a48:	ebefe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0201a4c:	00004697          	auipc	a3,0x4
ffffffffc0201a50:	bd468693          	addi	a3,a3,-1068 # ffffffffc0205620 <commands+0xea8>
ffffffffc0201a54:	00003617          	auipc	a2,0x3
ffffffffc0201a58:	59460613          	addi	a2,a2,1428 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201a5c:	1ca00593          	li	a1,458
ffffffffc0201a60:	00003517          	auipc	a0,0x3
ffffffffc0201a64:	78850513          	addi	a0,a0,1928 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201a68:	e9efe0ef          	jal	ra,ffffffffc0200106 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201a6c:	00004617          	auipc	a2,0x4
ffffffffc0201a70:	89c60613          	addi	a2,a2,-1892 # ffffffffc0205308 <commands+0xb90>
ffffffffc0201a74:	07700593          	li	a1,119
ffffffffc0201a78:	00003517          	auipc	a0,0x3
ffffffffc0201a7c:	77050513          	addi	a0,a0,1904 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201a80:	e86fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201a84:	00004697          	auipc	a3,0x4
ffffffffc0201a88:	97c68693          	addi	a3,a3,-1668 # ffffffffc0205400 <commands+0xc88>
ffffffffc0201a8c:	00003617          	auipc	a2,0x3
ffffffffc0201a90:	55c60613          	addi	a2,a2,1372 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201a94:	1a400593          	li	a1,420
ffffffffc0201a98:	00003517          	auipc	a0,0x3
ffffffffc0201a9c:	75050513          	addi	a0,a0,1872 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201aa0:	e66fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201aa4:	00004697          	auipc	a3,0x4
ffffffffc0201aa8:	92c68693          	addi	a3,a3,-1748 # ffffffffc02053d0 <commands+0xc58>
ffffffffc0201aac:	00003617          	auipc	a2,0x3
ffffffffc0201ab0:	53c60613          	addi	a2,a2,1340 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201ab4:	1a200593          	li	a1,418
ffffffffc0201ab8:	00003517          	auipc	a0,0x3
ffffffffc0201abc:	73050513          	addi	a0,a0,1840 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201ac0:	e46fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0201ac4:	00004697          	auipc	a3,0x4
ffffffffc0201ac8:	a5468693          	addi	a3,a3,-1452 # ffffffffc0205518 <commands+0xda0>
ffffffffc0201acc:	00003617          	auipc	a2,0x3
ffffffffc0201ad0:	51c60613          	addi	a2,a2,1308 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201ad4:	1af00593          	li	a1,431
ffffffffc0201ad8:	00003517          	auipc	a0,0x3
ffffffffc0201adc:	71050513          	addi	a0,a0,1808 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201ae0:	e26fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201ae4:	00004697          	auipc	a3,0x4
ffffffffc0201ae8:	a0468693          	addi	a3,a3,-1532 # ffffffffc02054e8 <commands+0xd70>
ffffffffc0201aec:	00003617          	auipc	a2,0x3
ffffffffc0201af0:	4fc60613          	addi	a2,a2,1276 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201af4:	1ae00593          	li	a1,430
ffffffffc0201af8:	00003517          	auipc	a0,0x3
ffffffffc0201afc:	6f050513          	addi	a0,a0,1776 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201b00:	e06fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201b04:	00004697          	auipc	a3,0x4
ffffffffc0201b08:	9ac68693          	addi	a3,a3,-1620 # ffffffffc02054b0 <commands+0xd38>
ffffffffc0201b0c:	00003617          	auipc	a2,0x3
ffffffffc0201b10:	4dc60613          	addi	a2,a2,1244 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201b14:	1ad00593          	li	a1,429
ffffffffc0201b18:	00003517          	auipc	a0,0x3
ffffffffc0201b1c:	6d050513          	addi	a0,a0,1744 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201b20:	de6fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201b24:	00004697          	auipc	a3,0x4
ffffffffc0201b28:	96468693          	addi	a3,a3,-1692 # ffffffffc0205488 <commands+0xd10>
ffffffffc0201b2c:	00003617          	auipc	a2,0x3
ffffffffc0201b30:	4bc60613          	addi	a2,a2,1212 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201b34:	1aa00593          	li	a1,426
ffffffffc0201b38:	00003517          	auipc	a0,0x3
ffffffffc0201b3c:	6b050513          	addi	a0,a0,1712 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201b40:	dc6fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201b44:	86da                	mv	a3,s6
ffffffffc0201b46:	00003617          	auipc	a2,0x3
ffffffffc0201b4a:	67a60613          	addi	a2,a2,1658 # ffffffffc02051c0 <commands+0xa48>
ffffffffc0201b4e:	1a900593          	li	a1,425
ffffffffc0201b52:	00003517          	auipc	a0,0x3
ffffffffc0201b56:	69650513          	addi	a0,a0,1686 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201b5a:	dacfe0ef          	jal	ra,ffffffffc0200106 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201b5e:	86be                	mv	a3,a5
ffffffffc0201b60:	00003617          	auipc	a2,0x3
ffffffffc0201b64:	66060613          	addi	a2,a2,1632 # ffffffffc02051c0 <commands+0xa48>
ffffffffc0201b68:	1a800593          	li	a1,424
ffffffffc0201b6c:	00003517          	auipc	a0,0x3
ffffffffc0201b70:	67c50513          	addi	a0,a0,1660 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201b74:	d92fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0201b78:	00004697          	auipc	a3,0x4
ffffffffc0201b7c:	8f868693          	addi	a3,a3,-1800 # ffffffffc0205470 <commands+0xcf8>
ffffffffc0201b80:	00003617          	auipc	a2,0x3
ffffffffc0201b84:	46860613          	addi	a2,a2,1128 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201b88:	1a600593          	li	a1,422
ffffffffc0201b8c:	00003517          	auipc	a0,0x3
ffffffffc0201b90:	65c50513          	addi	a0,a0,1628 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201b94:	d72fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0201b98:	00004697          	auipc	a3,0x4
ffffffffc0201b9c:	8c068693          	addi	a3,a3,-1856 # ffffffffc0205458 <commands+0xce0>
ffffffffc0201ba0:	00003617          	auipc	a2,0x3
ffffffffc0201ba4:	44860613          	addi	a2,a2,1096 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201ba8:	1a500593          	li	a1,421
ffffffffc0201bac:	00003517          	auipc	a0,0x3
ffffffffc0201bb0:	63c50513          	addi	a0,a0,1596 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201bb4:	d52fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0201bb8:	00004697          	auipc	a3,0x4
ffffffffc0201bbc:	8a068693          	addi	a3,a3,-1888 # ffffffffc0205458 <commands+0xce0>
ffffffffc0201bc0:	00003617          	auipc	a2,0x3
ffffffffc0201bc4:	42860613          	addi	a2,a2,1064 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201bc8:	1b800593          	li	a1,440
ffffffffc0201bcc:	00003517          	auipc	a0,0x3
ffffffffc0201bd0:	61c50513          	addi	a0,a0,1564 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201bd4:	d32fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201bd8:	00004697          	auipc	a3,0x4
ffffffffc0201bdc:	91068693          	addi	a3,a3,-1776 # ffffffffc02054e8 <commands+0xd70>
ffffffffc0201be0:	00003617          	auipc	a2,0x3
ffffffffc0201be4:	40860613          	addi	a2,a2,1032 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201be8:	1b700593          	li	a1,439
ffffffffc0201bec:	00003517          	auipc	a0,0x3
ffffffffc0201bf0:	5fc50513          	addi	a0,a0,1532 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201bf4:	d12fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201bf8:	00004697          	auipc	a3,0x4
ffffffffc0201bfc:	9b868693          	addi	a3,a3,-1608 # ffffffffc02055b0 <commands+0xe38>
ffffffffc0201c00:	00003617          	auipc	a2,0x3
ffffffffc0201c04:	3e860613          	addi	a2,a2,1000 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201c08:	1b600593          	li	a1,438
ffffffffc0201c0c:	00003517          	auipc	a0,0x3
ffffffffc0201c10:	5dc50513          	addi	a0,a0,1500 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201c14:	cf2fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0201c18:	00004697          	auipc	a3,0x4
ffffffffc0201c1c:	98068693          	addi	a3,a3,-1664 # ffffffffc0205598 <commands+0xe20>
ffffffffc0201c20:	00003617          	auipc	a2,0x3
ffffffffc0201c24:	3c860613          	addi	a2,a2,968 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201c28:	1b500593          	li	a1,437
ffffffffc0201c2c:	00003517          	auipc	a0,0x3
ffffffffc0201c30:	5bc50513          	addi	a0,a0,1468 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201c34:	cd2fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201c38:	00004697          	auipc	a3,0x4
ffffffffc0201c3c:	93068693          	addi	a3,a3,-1744 # ffffffffc0205568 <commands+0xdf0>
ffffffffc0201c40:	00003617          	auipc	a2,0x3
ffffffffc0201c44:	3a860613          	addi	a2,a2,936 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201c48:	1b400593          	li	a1,436
ffffffffc0201c4c:	00003517          	auipc	a0,0x3
ffffffffc0201c50:	59c50513          	addi	a0,a0,1436 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201c54:	cb2fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0201c58:	00004697          	auipc	a3,0x4
ffffffffc0201c5c:	8f868693          	addi	a3,a3,-1800 # ffffffffc0205550 <commands+0xdd8>
ffffffffc0201c60:	00003617          	auipc	a2,0x3
ffffffffc0201c64:	38860613          	addi	a2,a2,904 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201c68:	1b200593          	li	a1,434
ffffffffc0201c6c:	00003517          	auipc	a0,0x3
ffffffffc0201c70:	57c50513          	addi	a0,a0,1404 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201c74:	c92fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201c78:	00004697          	auipc	a3,0x4
ffffffffc0201c7c:	8c068693          	addi	a3,a3,-1856 # ffffffffc0205538 <commands+0xdc0>
ffffffffc0201c80:	00003617          	auipc	a2,0x3
ffffffffc0201c84:	36860613          	addi	a2,a2,872 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201c88:	1b100593          	li	a1,433
ffffffffc0201c8c:	00003517          	auipc	a0,0x3
ffffffffc0201c90:	55c50513          	addi	a0,a0,1372 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201c94:	c72fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0201c98:	00004697          	auipc	a3,0x4
ffffffffc0201c9c:	89068693          	addi	a3,a3,-1904 # ffffffffc0205528 <commands+0xdb0>
ffffffffc0201ca0:	00003617          	auipc	a2,0x3
ffffffffc0201ca4:	34860613          	addi	a2,a2,840 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201ca8:	1b000593          	li	a1,432
ffffffffc0201cac:	00003517          	auipc	a0,0x3
ffffffffc0201cb0:	53c50513          	addi	a0,a0,1340 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201cb4:	c52fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0201cb8:	00004697          	auipc	a3,0x4
ffffffffc0201cbc:	96868693          	addi	a3,a3,-1688 # ffffffffc0205620 <commands+0xea8>
ffffffffc0201cc0:	00003617          	auipc	a2,0x3
ffffffffc0201cc4:	32860613          	addi	a2,a2,808 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201cc8:	1f200593          	li	a1,498
ffffffffc0201ccc:	00003517          	auipc	a0,0x3
ffffffffc0201cd0:	51c50513          	addi	a0,a0,1308 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201cd4:	c32fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201cd8:	00004697          	auipc	a3,0x4
ffffffffc0201cdc:	af068693          	addi	a3,a3,-1296 # ffffffffc02057c8 <commands+0x1050>
ffffffffc0201ce0:	00003617          	auipc	a2,0x3
ffffffffc0201ce4:	30860613          	addi	a2,a2,776 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201ce8:	1ea00593          	li	a1,490
ffffffffc0201cec:	00003517          	auipc	a0,0x3
ffffffffc0201cf0:	4fc50513          	addi	a0,a0,1276 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201cf4:	c12fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201cf8:	00004697          	auipc	a3,0x4
ffffffffc0201cfc:	a9868693          	addi	a3,a3,-1384 # ffffffffc0205790 <commands+0x1018>
ffffffffc0201d00:	00003617          	auipc	a2,0x3
ffffffffc0201d04:	2e860613          	addi	a2,a2,744 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201d08:	1e700593          	li	a1,487
ffffffffc0201d0c:	00003517          	auipc	a0,0x3
ffffffffc0201d10:	4dc50513          	addi	a0,a0,1244 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201d14:	bf2fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0201d18:	00004697          	auipc	a3,0x4
ffffffffc0201d1c:	a4868693          	addi	a3,a3,-1464 # ffffffffc0205760 <commands+0xfe8>
ffffffffc0201d20:	00003617          	auipc	a2,0x3
ffffffffc0201d24:	2c860613          	addi	a2,a2,712 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201d28:	1e300593          	li	a1,483
ffffffffc0201d2c:	00003517          	auipc	a0,0x3
ffffffffc0201d30:	4bc50513          	addi	a0,a0,1212 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201d34:	bd2fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0201d38:	00004697          	auipc	a3,0x4
ffffffffc0201d3c:	8a868693          	addi	a3,a3,-1880 # ffffffffc02055e0 <commands+0xe68>
ffffffffc0201d40:	00003617          	auipc	a2,0x3
ffffffffc0201d44:	2a860613          	addi	a2,a2,680 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201d48:	1c000593          	li	a1,448
ffffffffc0201d4c:	00003517          	auipc	a0,0x3
ffffffffc0201d50:	49c50513          	addi	a0,a0,1180 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201d54:	bb2fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201d58:	00004697          	auipc	a3,0x4
ffffffffc0201d5c:	85868693          	addi	a3,a3,-1960 # ffffffffc02055b0 <commands+0xe38>
ffffffffc0201d60:	00003617          	auipc	a2,0x3
ffffffffc0201d64:	28860613          	addi	a2,a2,648 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201d68:	1bd00593          	li	a1,445
ffffffffc0201d6c:	00003517          	auipc	a0,0x3
ffffffffc0201d70:	47c50513          	addi	a0,a0,1148 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201d74:	b92fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0201d78:	00003697          	auipc	a3,0x3
ffffffffc0201d7c:	6f868693          	addi	a3,a3,1784 # ffffffffc0205470 <commands+0xcf8>
ffffffffc0201d80:	00003617          	auipc	a2,0x3
ffffffffc0201d84:	26860613          	addi	a2,a2,616 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201d88:	1bc00593          	li	a1,444
ffffffffc0201d8c:	00003517          	auipc	a0,0x3
ffffffffc0201d90:	45c50513          	addi	a0,a0,1116 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201d94:	b72fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201d98:	00004697          	auipc	a3,0x4
ffffffffc0201d9c:	83068693          	addi	a3,a3,-2000 # ffffffffc02055c8 <commands+0xe50>
ffffffffc0201da0:	00003617          	auipc	a2,0x3
ffffffffc0201da4:	24860613          	addi	a2,a2,584 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201da8:	1b900593          	li	a1,441
ffffffffc0201dac:	00003517          	auipc	a0,0x3
ffffffffc0201db0:	43c50513          	addi	a0,a0,1084 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201db4:	b52fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201db8:	00004697          	auipc	a3,0x4
ffffffffc0201dbc:	84068693          	addi	a3,a3,-1984 # ffffffffc02055f8 <commands+0xe80>
ffffffffc0201dc0:	00003617          	auipc	a2,0x3
ffffffffc0201dc4:	22860613          	addi	a2,a2,552 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201dc8:	1c300593          	li	a1,451
ffffffffc0201dcc:	00003517          	auipc	a0,0x3
ffffffffc0201dd0:	41c50513          	addi	a0,a0,1052 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201dd4:	b32fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201dd8:	00003697          	auipc	a3,0x3
ffffffffc0201ddc:	7d868693          	addi	a3,a3,2008 # ffffffffc02055b0 <commands+0xe38>
ffffffffc0201de0:	00003617          	auipc	a2,0x3
ffffffffc0201de4:	20860613          	addi	a2,a2,520 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201de8:	1c100593          	li	a1,449
ffffffffc0201dec:	00003517          	auipc	a0,0x3
ffffffffc0201df0:	3fc50513          	addi	a0,a0,1020 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201df4:	b12fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201df8:	00003697          	auipc	a3,0x3
ffffffffc0201dfc:	55868693          	addi	a3,a3,1368 # ffffffffc0205350 <commands+0xbd8>
ffffffffc0201e00:	00003617          	auipc	a2,0x3
ffffffffc0201e04:	1e860613          	addi	a2,a2,488 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201e08:	19c00593          	li	a1,412
ffffffffc0201e0c:	00003517          	auipc	a0,0x3
ffffffffc0201e10:	3dc50513          	addi	a0,a0,988 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201e14:	af2fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201e18:	00003617          	auipc	a2,0x3
ffffffffc0201e1c:	4f060613          	addi	a2,a2,1264 # ffffffffc0205308 <commands+0xb90>
ffffffffc0201e20:	0bd00593          	li	a1,189
ffffffffc0201e24:	00003517          	auipc	a0,0x3
ffffffffc0201e28:	3c450513          	addi	a0,a0,964 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201e2c:	adafe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201e30:	00004697          	auipc	a3,0x4
ffffffffc0201e34:	8f068693          	addi	a3,a3,-1808 # ffffffffc0205720 <commands+0xfa8>
ffffffffc0201e38:	00003617          	auipc	a2,0x3
ffffffffc0201e3c:	1b060613          	addi	a2,a2,432 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201e40:	1e200593          	li	a1,482
ffffffffc0201e44:	00003517          	auipc	a0,0x3
ffffffffc0201e48:	3a450513          	addi	a0,a0,932 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201e4c:	abafe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0201e50:	00004697          	auipc	a3,0x4
ffffffffc0201e54:	8b868693          	addi	a3,a3,-1864 # ffffffffc0205708 <commands+0xf90>
ffffffffc0201e58:	00003617          	auipc	a2,0x3
ffffffffc0201e5c:	19060613          	addi	a2,a2,400 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201e60:	1e100593          	li	a1,481
ffffffffc0201e64:	00003517          	auipc	a0,0x3
ffffffffc0201e68:	38450513          	addi	a0,a0,900 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201e6c:	a9afe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201e70:	00004697          	auipc	a3,0x4
ffffffffc0201e74:	86068693          	addi	a3,a3,-1952 # ffffffffc02056d0 <commands+0xf58>
ffffffffc0201e78:	00003617          	auipc	a2,0x3
ffffffffc0201e7c:	17060613          	addi	a2,a2,368 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201e80:	1e000593          	li	a1,480
ffffffffc0201e84:	00003517          	auipc	a0,0x3
ffffffffc0201e88:	36450513          	addi	a0,a0,868 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201e8c:	a7afe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0201e90:	00004697          	auipc	a3,0x4
ffffffffc0201e94:	82868693          	addi	a3,a3,-2008 # ffffffffc02056b8 <commands+0xf40>
ffffffffc0201e98:	00003617          	auipc	a2,0x3
ffffffffc0201e9c:	15060613          	addi	a2,a2,336 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201ea0:	1dc00593          	li	a1,476
ffffffffc0201ea4:	00003517          	auipc	a0,0x3
ffffffffc0201ea8:	34450513          	addi	a0,a0,836 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201eac:	a5afe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0201eb0 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201eb0:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0201eb4:	8082                	ret

ffffffffc0201eb6 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0201eb6:	7179                	addi	sp,sp,-48
ffffffffc0201eb8:	e84a                	sd	s2,16(sp)
ffffffffc0201eba:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0201ebc:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0201ebe:	f022                	sd	s0,32(sp)
ffffffffc0201ec0:	ec26                	sd	s1,24(sp)
ffffffffc0201ec2:	e44e                	sd	s3,8(sp)
ffffffffc0201ec4:	f406                	sd	ra,40(sp)
ffffffffc0201ec6:	84ae                	mv	s1,a1
ffffffffc0201ec8:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0201eca:	852ff0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0201ece:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0201ed0:	cd19                	beqz	a0,ffffffffc0201eee <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0201ed2:	85aa                	mv	a1,a0
ffffffffc0201ed4:	86ce                	mv	a3,s3
ffffffffc0201ed6:	8626                	mv	a2,s1
ffffffffc0201ed8:	854a                	mv	a0,s2
ffffffffc0201eda:	c28ff0ef          	jal	ra,ffffffffc0201302 <page_insert>
ffffffffc0201ede:	ed39                	bnez	a0,ffffffffc0201f3c <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0201ee0:	0000f797          	auipc	a5,0xf
ffffffffc0201ee4:	59078793          	addi	a5,a5,1424 # ffffffffc0211470 <swap_init_ok>
ffffffffc0201ee8:	439c                	lw	a5,0(a5)
ffffffffc0201eea:	2781                	sext.w	a5,a5
ffffffffc0201eec:	eb89                	bnez	a5,ffffffffc0201efe <pgdir_alloc_page+0x48>
}
ffffffffc0201eee:	8522                	mv	a0,s0
ffffffffc0201ef0:	70a2                	ld	ra,40(sp)
ffffffffc0201ef2:	7402                	ld	s0,32(sp)
ffffffffc0201ef4:	64e2                	ld	s1,24(sp)
ffffffffc0201ef6:	6942                	ld	s2,16(sp)
ffffffffc0201ef8:	69a2                	ld	s3,8(sp)
ffffffffc0201efa:	6145                	addi	sp,sp,48
ffffffffc0201efc:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0201efe:	0000f797          	auipc	a5,0xf
ffffffffc0201f02:	5b278793          	addi	a5,a5,1458 # ffffffffc02114b0 <check_mm_struct>
ffffffffc0201f06:	6388                	ld	a0,0(a5)
ffffffffc0201f08:	4681                	li	a3,0
ffffffffc0201f0a:	8622                	mv	a2,s0
ffffffffc0201f0c:	85a6                	mv	a1,s1
ffffffffc0201f0e:	1bf000ef          	jal	ra,ffffffffc02028cc <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0201f12:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0201f14:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0201f16:	4785                	li	a5,1
ffffffffc0201f18:	fcf70be3          	beq	a4,a5,ffffffffc0201eee <pgdir_alloc_page+0x38>
ffffffffc0201f1c:	00003697          	auipc	a3,0x3
ffffffffc0201f20:	34c68693          	addi	a3,a3,844 # ffffffffc0205268 <commands+0xaf0>
ffffffffc0201f24:	00003617          	auipc	a2,0x3
ffffffffc0201f28:	0c460613          	addi	a2,a2,196 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201f2c:	18400593          	li	a1,388
ffffffffc0201f30:	00003517          	auipc	a0,0x3
ffffffffc0201f34:	2b850513          	addi	a0,a0,696 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201f38:	9cefe0ef          	jal	ra,ffffffffc0200106 <__panic>
            free_page(page);
ffffffffc0201f3c:	8522                	mv	a0,s0
ffffffffc0201f3e:	4585                	li	a1,1
ffffffffc0201f40:	864ff0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
            return NULL;
ffffffffc0201f44:	4401                	li	s0,0
ffffffffc0201f46:	b765                	j	ffffffffc0201eee <pgdir_alloc_page+0x38>

ffffffffc0201f48 <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc0201f48:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201f4a:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc0201f4c:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201f4e:	fff50713          	addi	a4,a0,-1
ffffffffc0201f52:	17f9                	addi	a5,a5,-2
ffffffffc0201f54:	04e7ee63          	bltu	a5,a4,ffffffffc0201fb0 <kmalloc+0x68>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0201f58:	6785                	lui	a5,0x1
ffffffffc0201f5a:	17fd                	addi	a5,a5,-1
ffffffffc0201f5c:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc0201f5e:	8131                	srli	a0,a0,0xc
ffffffffc0201f60:	fbdfe0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
    assert(base != NULL);
ffffffffc0201f64:	c159                	beqz	a0,ffffffffc0201fea <kmalloc+0xa2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f66:	0000f797          	auipc	a5,0xf
ffffffffc0201f6a:	54278793          	addi	a5,a5,1346 # ffffffffc02114a8 <pages>
ffffffffc0201f6e:	639c                	ld	a5,0(a5)
ffffffffc0201f70:	8d1d                	sub	a0,a0,a5
ffffffffc0201f72:	00003797          	auipc	a5,0x3
ffffffffc0201f76:	24678793          	addi	a5,a5,582 # ffffffffc02051b8 <commands+0xa40>
ffffffffc0201f7a:	6394                	ld	a3,0(a5)
ffffffffc0201f7c:	850d                	srai	a0,a0,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f7e:	0000f797          	auipc	a5,0xf
ffffffffc0201f82:	4da78793          	addi	a5,a5,1242 # ffffffffc0211458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f86:	02d50533          	mul	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f8a:	6398                	ld	a4,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f8c:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f90:	57fd                	li	a5,-1
ffffffffc0201f92:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f94:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f96:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f98:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f9a:	02e7fb63          	bleu	a4,a5,ffffffffc0201fd0 <kmalloc+0x88>
ffffffffc0201f9e:	0000f797          	auipc	a5,0xf
ffffffffc0201fa2:	4fa78793          	addi	a5,a5,1274 # ffffffffc0211498 <va_pa_offset>
ffffffffc0201fa6:	639c                	ld	a5,0(a5)
    ptr = page2kva(base);
    return ptr;
}
ffffffffc0201fa8:	60a2                	ld	ra,8(sp)
ffffffffc0201faa:	953e                	add	a0,a0,a5
ffffffffc0201fac:	0141                	addi	sp,sp,16
ffffffffc0201fae:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201fb0:	00003697          	auipc	a3,0x3
ffffffffc0201fb4:	25868693          	addi	a3,a3,600 # ffffffffc0205208 <commands+0xa90>
ffffffffc0201fb8:	00003617          	auipc	a2,0x3
ffffffffc0201fbc:	03060613          	addi	a2,a2,48 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201fc0:	1fa00593          	li	a1,506
ffffffffc0201fc4:	00003517          	auipc	a0,0x3
ffffffffc0201fc8:	22450513          	addi	a0,a0,548 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0201fcc:	93afe0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0201fd0:	86aa                	mv	a3,a0
ffffffffc0201fd2:	00003617          	auipc	a2,0x3
ffffffffc0201fd6:	1ee60613          	addi	a2,a2,494 # ffffffffc02051c0 <commands+0xa48>
ffffffffc0201fda:	06a00593          	li	a1,106
ffffffffc0201fde:	00003517          	auipc	a0,0x3
ffffffffc0201fe2:	27a50513          	addi	a0,a0,634 # ffffffffc0205258 <commands+0xae0>
ffffffffc0201fe6:	920fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(base != NULL);
ffffffffc0201fea:	00003697          	auipc	a3,0x3
ffffffffc0201fee:	23e68693          	addi	a3,a3,574 # ffffffffc0205228 <commands+0xab0>
ffffffffc0201ff2:	00003617          	auipc	a2,0x3
ffffffffc0201ff6:	ff660613          	addi	a2,a2,-10 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0201ffa:	1fd00593          	li	a1,509
ffffffffc0201ffe:	00003517          	auipc	a0,0x3
ffffffffc0202002:	1ea50513          	addi	a0,a0,490 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0202006:	900fe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc020200a <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc020200a:	1141                	addi	sp,sp,-16
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020200c:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc020200e:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202010:	fff58713          	addi	a4,a1,-1
ffffffffc0202014:	17f9                	addi	a5,a5,-2
ffffffffc0202016:	04e7eb63          	bltu	a5,a4,ffffffffc020206c <kfree+0x62>
    assert(ptr != NULL);
ffffffffc020201a:	c941                	beqz	a0,ffffffffc02020aa <kfree+0xa0>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc020201c:	6785                	lui	a5,0x1
ffffffffc020201e:	17fd                	addi	a5,a5,-1
ffffffffc0202020:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202022:	c02007b7          	lui	a5,0xc0200
ffffffffc0202026:	81b1                	srli	a1,a1,0xc
ffffffffc0202028:	06f56463          	bltu	a0,a5,ffffffffc0202090 <kfree+0x86>
ffffffffc020202c:	0000f797          	auipc	a5,0xf
ffffffffc0202030:	46c78793          	addi	a5,a5,1132 # ffffffffc0211498 <va_pa_offset>
ffffffffc0202034:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0202036:	0000f717          	auipc	a4,0xf
ffffffffc020203a:	42270713          	addi	a4,a4,1058 # ffffffffc0211458 <npage>
ffffffffc020203e:	6318                	ld	a4,0(a4)
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202040:	40f507b3          	sub	a5,a0,a5
    if (PPN(pa) >= npage) {
ffffffffc0202044:	83b1                	srli	a5,a5,0xc
ffffffffc0202046:	04e7f363          	bleu	a4,a5,ffffffffc020208c <kfree+0x82>
    return &pages[PPN(pa) - nbase];
ffffffffc020204a:	fff80537          	lui	a0,0xfff80
ffffffffc020204e:	97aa                	add	a5,a5,a0
ffffffffc0202050:	0000f697          	auipc	a3,0xf
ffffffffc0202054:	45868693          	addi	a3,a3,1112 # ffffffffc02114a8 <pages>
ffffffffc0202058:	6288                	ld	a0,0(a3)
ffffffffc020205a:	00379713          	slli	a4,a5,0x3
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc020205e:	60a2                	ld	ra,8(sp)
ffffffffc0202060:	97ba                	add	a5,a5,a4
ffffffffc0202062:	078e                	slli	a5,a5,0x3
    free_pages(base, num_pages);
ffffffffc0202064:	953e                	add	a0,a0,a5
}
ffffffffc0202066:	0141                	addi	sp,sp,16
    free_pages(base, num_pages);
ffffffffc0202068:	f3dfe06f          	j	ffffffffc0200fa4 <free_pages>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020206c:	00003697          	auipc	a3,0x3
ffffffffc0202070:	19c68693          	addi	a3,a3,412 # ffffffffc0205208 <commands+0xa90>
ffffffffc0202074:	00003617          	auipc	a2,0x3
ffffffffc0202078:	f7460613          	addi	a2,a2,-140 # ffffffffc0204fe8 <commands+0x870>
ffffffffc020207c:	20300593          	li	a1,515
ffffffffc0202080:	00003517          	auipc	a0,0x3
ffffffffc0202084:	16850513          	addi	a0,a0,360 # ffffffffc02051e8 <commands+0xa70>
ffffffffc0202088:	87efe0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc020208c:	e75fe0ef          	jal	ra,ffffffffc0200f00 <pa2page.part.4>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202090:	86aa                	mv	a3,a0
ffffffffc0202092:	00003617          	auipc	a2,0x3
ffffffffc0202096:	27660613          	addi	a2,a2,630 # ffffffffc0205308 <commands+0xb90>
ffffffffc020209a:	06c00593          	li	a1,108
ffffffffc020209e:	00003517          	auipc	a0,0x3
ffffffffc02020a2:	1ba50513          	addi	a0,a0,442 # ffffffffc0205258 <commands+0xae0>
ffffffffc02020a6:	860fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(ptr != NULL);
ffffffffc02020aa:	00003697          	auipc	a3,0x3
ffffffffc02020ae:	14e68693          	addi	a3,a3,334 # ffffffffc02051f8 <commands+0xa80>
ffffffffc02020b2:	00003617          	auipc	a2,0x3
ffffffffc02020b6:	f3660613          	addi	a2,a2,-202 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02020ba:	20400593          	li	a1,516
ffffffffc02020be:	00003517          	auipc	a0,0x3
ffffffffc02020c2:	12a50513          	addi	a0,a0,298 # ffffffffc02051e8 <commands+0xa70>
ffffffffc02020c6:	840fe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02020ca <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02020ca:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02020cc:	00003697          	auipc	a3,0x3
ffffffffc02020d0:	74468693          	addi	a3,a3,1860 # ffffffffc0205810 <commands+0x1098>
ffffffffc02020d4:	00003617          	auipc	a2,0x3
ffffffffc02020d8:	f1460613          	addi	a2,a2,-236 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02020dc:	07d00593          	li	a1,125
ffffffffc02020e0:	00003517          	auipc	a0,0x3
ffffffffc02020e4:	75050513          	addi	a0,a0,1872 # ffffffffc0205830 <commands+0x10b8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02020e8:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02020ea:	81cfe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02020ee <mm_create>:
mm_create(void) {
ffffffffc02020ee:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02020f0:	03000513          	li	a0,48
mm_create(void) {
ffffffffc02020f4:	e022                	sd	s0,0(sp)
ffffffffc02020f6:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02020f8:	e51ff0ef          	jal	ra,ffffffffc0201f48 <kmalloc>
ffffffffc02020fc:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02020fe:	c115                	beqz	a0,ffffffffc0202122 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0202100:	0000f797          	auipc	a5,0xf
ffffffffc0202104:	37078793          	addi	a5,a5,880 # ffffffffc0211470 <swap_init_ok>
ffffffffc0202108:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc020210a:	e408                	sd	a0,8(s0)
ffffffffc020210c:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc020210e:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0202112:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0202116:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020211a:	2781                	sext.w	a5,a5
ffffffffc020211c:	eb81                	bnez	a5,ffffffffc020212c <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc020211e:	02053423          	sd	zero,40(a0)
}
ffffffffc0202122:	8522                	mv	a0,s0
ffffffffc0202124:	60a2                	ld	ra,8(sp)
ffffffffc0202126:	6402                	ld	s0,0(sp)
ffffffffc0202128:	0141                	addi	sp,sp,16
ffffffffc020212a:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020212c:	790000ef          	jal	ra,ffffffffc02028bc <swap_init_mm>
}
ffffffffc0202130:	8522                	mv	a0,s0
ffffffffc0202132:	60a2                	ld	ra,8(sp)
ffffffffc0202134:	6402                	ld	s0,0(sp)
ffffffffc0202136:	0141                	addi	sp,sp,16
ffffffffc0202138:	8082                	ret

ffffffffc020213a <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc020213a:	1101                	addi	sp,sp,-32
ffffffffc020213c:	e04a                	sd	s2,0(sp)
ffffffffc020213e:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202140:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0202144:	e822                	sd	s0,16(sp)
ffffffffc0202146:	e426                	sd	s1,8(sp)
ffffffffc0202148:	ec06                	sd	ra,24(sp)
ffffffffc020214a:	84ae                	mv	s1,a1
ffffffffc020214c:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020214e:	dfbff0ef          	jal	ra,ffffffffc0201f48 <kmalloc>
    if (vma != NULL) {
ffffffffc0202152:	c509                	beqz	a0,ffffffffc020215c <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0202154:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202158:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020215a:	ed00                	sd	s0,24(a0)
}
ffffffffc020215c:	60e2                	ld	ra,24(sp)
ffffffffc020215e:	6442                	ld	s0,16(sp)
ffffffffc0202160:	64a2                	ld	s1,8(sp)
ffffffffc0202162:	6902                	ld	s2,0(sp)
ffffffffc0202164:	6105                	addi	sp,sp,32
ffffffffc0202166:	8082                	ret

ffffffffc0202168 <find_vma>:
    if (mm != NULL) {
ffffffffc0202168:	c51d                	beqz	a0,ffffffffc0202196 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc020216a:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020216c:	c781                	beqz	a5,ffffffffc0202174 <find_vma+0xc>
ffffffffc020216e:	6798                	ld	a4,8(a5)
ffffffffc0202170:	02e5f663          	bleu	a4,a1,ffffffffc020219c <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0202174:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc0202176:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0202178:	00f50f63          	beq	a0,a5,ffffffffc0202196 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc020217c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202180:	fee5ebe3          	bltu	a1,a4,ffffffffc0202176 <find_vma+0xe>
ffffffffc0202184:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202188:	fee5f7e3          	bleu	a4,a1,ffffffffc0202176 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc020218c:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc020218e:	c781                	beqz	a5,ffffffffc0202196 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0202190:	e91c                	sd	a5,16(a0)
}
ffffffffc0202192:	853e                	mv	a0,a5
ffffffffc0202194:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0202196:	4781                	li	a5,0
}
ffffffffc0202198:	853e                	mv	a0,a5
ffffffffc020219a:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020219c:	6b98                	ld	a4,16(a5)
ffffffffc020219e:	fce5fbe3          	bleu	a4,a1,ffffffffc0202174 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc02021a2:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc02021a4:	b7fd                	j	ffffffffc0202192 <find_vma+0x2a>

ffffffffc02021a6 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc02021a6:	6590                	ld	a2,8(a1)
ffffffffc02021a8:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc02021ac:	1141                	addi	sp,sp,-16
ffffffffc02021ae:	e406                	sd	ra,8(sp)
ffffffffc02021b0:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02021b2:	01066863          	bltu	a2,a6,ffffffffc02021c2 <insert_vma_struct+0x1c>
ffffffffc02021b6:	a8b9                	j	ffffffffc0202214 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02021b8:	fe87b683          	ld	a3,-24(a5)
ffffffffc02021bc:	04d66763          	bltu	a2,a3,ffffffffc020220a <insert_vma_struct+0x64>
ffffffffc02021c0:	873e                	mv	a4,a5
ffffffffc02021c2:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc02021c4:	fef51ae3          	bne	a0,a5,ffffffffc02021b8 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc02021c8:	02a70463          	beq	a4,a0,ffffffffc02021f0 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02021cc:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02021d0:	fe873883          	ld	a7,-24(a4)
ffffffffc02021d4:	08d8f063          	bleu	a3,a7,ffffffffc0202254 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02021d8:	04d66e63          	bltu	a2,a3,ffffffffc0202234 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc02021dc:	00f50a63          	beq	a0,a5,ffffffffc02021f0 <insert_vma_struct+0x4a>
ffffffffc02021e0:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02021e4:	0506e863          	bltu	a3,a6,ffffffffc0202234 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc02021e8:	ff07b603          	ld	a2,-16(a5)
ffffffffc02021ec:	02c6f263          	bleu	a2,a3,ffffffffc0202210 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02021f0:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc02021f2:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02021f4:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02021f8:	e390                	sd	a2,0(a5)
ffffffffc02021fa:	e710                	sd	a2,8(a4)
}
ffffffffc02021fc:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02021fe:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0202200:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0202202:	2685                	addiw	a3,a3,1
ffffffffc0202204:	d114                	sw	a3,32(a0)
}
ffffffffc0202206:	0141                	addi	sp,sp,16
ffffffffc0202208:	8082                	ret
    if (le_prev != list) {
ffffffffc020220a:	fca711e3          	bne	a4,a0,ffffffffc02021cc <insert_vma_struct+0x26>
ffffffffc020220e:	bfd9                	j	ffffffffc02021e4 <insert_vma_struct+0x3e>
ffffffffc0202210:	ebbff0ef          	jal	ra,ffffffffc02020ca <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202214:	00003697          	auipc	a3,0x3
ffffffffc0202218:	6ac68693          	addi	a3,a3,1708 # ffffffffc02058c0 <commands+0x1148>
ffffffffc020221c:	00003617          	auipc	a2,0x3
ffffffffc0202220:	dcc60613          	addi	a2,a2,-564 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0202224:	08400593          	li	a1,132
ffffffffc0202228:	00003517          	auipc	a0,0x3
ffffffffc020222c:	60850513          	addi	a0,a0,1544 # ffffffffc0205830 <commands+0x10b8>
ffffffffc0202230:	ed7fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202234:	00003697          	auipc	a3,0x3
ffffffffc0202238:	6cc68693          	addi	a3,a3,1740 # ffffffffc0205900 <commands+0x1188>
ffffffffc020223c:	00003617          	auipc	a2,0x3
ffffffffc0202240:	dac60613          	addi	a2,a2,-596 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0202244:	07c00593          	li	a1,124
ffffffffc0202248:	00003517          	auipc	a0,0x3
ffffffffc020224c:	5e850513          	addi	a0,a0,1512 # ffffffffc0205830 <commands+0x10b8>
ffffffffc0202250:	eb7fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0202254:	00003697          	auipc	a3,0x3
ffffffffc0202258:	68c68693          	addi	a3,a3,1676 # ffffffffc02058e0 <commands+0x1168>
ffffffffc020225c:	00003617          	auipc	a2,0x3
ffffffffc0202260:	d8c60613          	addi	a2,a2,-628 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0202264:	07b00593          	li	a1,123
ffffffffc0202268:	00003517          	auipc	a0,0x3
ffffffffc020226c:	5c850513          	addi	a0,a0,1480 # ffffffffc0205830 <commands+0x10b8>
ffffffffc0202270:	e97fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202274 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0202274:	1141                	addi	sp,sp,-16
ffffffffc0202276:	e022                	sd	s0,0(sp)
ffffffffc0202278:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020227a:	6508                	ld	a0,8(a0)
ffffffffc020227c:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc020227e:	00a40e63          	beq	s0,a0,ffffffffc020229a <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0202282:	6118                	ld	a4,0(a0)
ffffffffc0202284:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0202286:	03000593          	li	a1,48
ffffffffc020228a:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc020228c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020228e:	e398                	sd	a4,0(a5)
ffffffffc0202290:	d7bff0ef          	jal	ra,ffffffffc020200a <kfree>
    return listelm->next;
ffffffffc0202294:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0202296:	fea416e3          	bne	s0,a0,ffffffffc0202282 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020229a:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc020229c:	6402                	ld	s0,0(sp)
ffffffffc020229e:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc02022a0:	03000593          	li	a1,48
}
ffffffffc02022a4:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc02022a6:	d65ff06f          	j	ffffffffc020200a <kfree>

ffffffffc02022aa <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc02022aa:	715d                	addi	sp,sp,-80
ffffffffc02022ac:	e486                	sd	ra,72(sp)
ffffffffc02022ae:	e0a2                	sd	s0,64(sp)
ffffffffc02022b0:	fc26                	sd	s1,56(sp)
ffffffffc02022b2:	f84a                	sd	s2,48(sp)
ffffffffc02022b4:	f052                	sd	s4,32(sp)
ffffffffc02022b6:	f44e                	sd	s3,40(sp)
ffffffffc02022b8:	ec56                	sd	s5,24(sp)
ffffffffc02022ba:	e85a                	sd	s6,16(sp)
ffffffffc02022bc:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02022be:	d2dfe0ef          	jal	ra,ffffffffc0200fea <nr_free_pages>
ffffffffc02022c2:	892a                	mv	s2,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02022c4:	d27fe0ef          	jal	ra,ffffffffc0200fea <nr_free_pages>
ffffffffc02022c8:	8a2a                	mv	s4,a0

    struct mm_struct *mm = mm_create();
ffffffffc02022ca:	e25ff0ef          	jal	ra,ffffffffc02020ee <mm_create>
    assert(mm != NULL);
ffffffffc02022ce:	842a                	mv	s0,a0
ffffffffc02022d0:	03200493          	li	s1,50
ffffffffc02022d4:	e919                	bnez	a0,ffffffffc02022ea <vmm_init+0x40>
ffffffffc02022d6:	aeed                	j	ffffffffc02026d0 <vmm_init+0x426>
        vma->vm_start = vm_start;
ffffffffc02022d8:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02022da:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02022dc:	00053c23          	sd	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02022e0:	14ed                	addi	s1,s1,-5
ffffffffc02022e2:	8522                	mv	a0,s0
ffffffffc02022e4:	ec3ff0ef          	jal	ra,ffffffffc02021a6 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02022e8:	c88d                	beqz	s1,ffffffffc020231a <vmm_init+0x70>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02022ea:	03000513          	li	a0,48
ffffffffc02022ee:	c5bff0ef          	jal	ra,ffffffffc0201f48 <kmalloc>
ffffffffc02022f2:	85aa                	mv	a1,a0
ffffffffc02022f4:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02022f8:	f165                	bnez	a0,ffffffffc02022d8 <vmm_init+0x2e>
        assert(vma != NULL);
ffffffffc02022fa:	00004697          	auipc	a3,0x4
ffffffffc02022fe:	84e68693          	addi	a3,a3,-1970 # ffffffffc0205b48 <commands+0x13d0>
ffffffffc0202302:	00003617          	auipc	a2,0x3
ffffffffc0202306:	ce660613          	addi	a2,a2,-794 # ffffffffc0204fe8 <commands+0x870>
ffffffffc020230a:	0ce00593          	li	a1,206
ffffffffc020230e:	00003517          	auipc	a0,0x3
ffffffffc0202312:	52250513          	addi	a0,a0,1314 # ffffffffc0205830 <commands+0x10b8>
ffffffffc0202316:	df1fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc020231a:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020231e:	1f900993          	li	s3,505
ffffffffc0202322:	a819                	j	ffffffffc0202338 <vmm_init+0x8e>
        vma->vm_start = vm_start;
ffffffffc0202324:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202326:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202328:	00053c23          	sd	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020232c:	0495                	addi	s1,s1,5
ffffffffc020232e:	8522                	mv	a0,s0
ffffffffc0202330:	e77ff0ef          	jal	ra,ffffffffc02021a6 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0202334:	03348a63          	beq	s1,s3,ffffffffc0202368 <vmm_init+0xbe>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202338:	03000513          	li	a0,48
ffffffffc020233c:	c0dff0ef          	jal	ra,ffffffffc0201f48 <kmalloc>
ffffffffc0202340:	85aa                	mv	a1,a0
ffffffffc0202342:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0202346:	fd79                	bnez	a0,ffffffffc0202324 <vmm_init+0x7a>
        assert(vma != NULL);
ffffffffc0202348:	00004697          	auipc	a3,0x4
ffffffffc020234c:	80068693          	addi	a3,a3,-2048 # ffffffffc0205b48 <commands+0x13d0>
ffffffffc0202350:	00003617          	auipc	a2,0x3
ffffffffc0202354:	c9860613          	addi	a2,a2,-872 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0202358:	0d400593          	li	a1,212
ffffffffc020235c:	00003517          	auipc	a0,0x3
ffffffffc0202360:	4d450513          	addi	a0,a0,1236 # ffffffffc0205830 <commands+0x10b8>
ffffffffc0202364:	da3fd0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0202368:	6418                	ld	a4,8(s0)
ffffffffc020236a:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc020236c:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0202370:	2ae40063          	beq	s0,a4,ffffffffc0202610 <vmm_init+0x366>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202374:	fe873603          	ld	a2,-24(a4)
ffffffffc0202378:	ffe78693          	addi	a3,a5,-2
ffffffffc020237c:	20d61a63          	bne	a2,a3,ffffffffc0202590 <vmm_init+0x2e6>
ffffffffc0202380:	ff073683          	ld	a3,-16(a4)
ffffffffc0202384:	20d79663          	bne	a5,a3,ffffffffc0202590 <vmm_init+0x2e6>
ffffffffc0202388:	0795                	addi	a5,a5,5
ffffffffc020238a:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc020238c:	feb792e3          	bne	a5,a1,ffffffffc0202370 <vmm_init+0xc6>
ffffffffc0202390:	499d                	li	s3,7
ffffffffc0202392:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0202394:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0202398:	85a6                	mv	a1,s1
ffffffffc020239a:	8522                	mv	a0,s0
ffffffffc020239c:	dcdff0ef          	jal	ra,ffffffffc0202168 <find_vma>
ffffffffc02023a0:	8b2a                	mv	s6,a0
        assert(vma1 != NULL);
ffffffffc02023a2:	2e050763          	beqz	a0,ffffffffc0202690 <vmm_init+0x3e6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc02023a6:	00148593          	addi	a1,s1,1
ffffffffc02023aa:	8522                	mv	a0,s0
ffffffffc02023ac:	dbdff0ef          	jal	ra,ffffffffc0202168 <find_vma>
ffffffffc02023b0:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc02023b2:	2a050f63          	beqz	a0,ffffffffc0202670 <vmm_init+0x3c6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc02023b6:	85ce                	mv	a1,s3
ffffffffc02023b8:	8522                	mv	a0,s0
ffffffffc02023ba:	dafff0ef          	jal	ra,ffffffffc0202168 <find_vma>
        assert(vma3 == NULL);
ffffffffc02023be:	28051963          	bnez	a0,ffffffffc0202650 <vmm_init+0x3a6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02023c2:	00348593          	addi	a1,s1,3
ffffffffc02023c6:	8522                	mv	a0,s0
ffffffffc02023c8:	da1ff0ef          	jal	ra,ffffffffc0202168 <find_vma>
        assert(vma4 == NULL);
ffffffffc02023cc:	26051263          	bnez	a0,ffffffffc0202630 <vmm_init+0x386>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02023d0:	00448593          	addi	a1,s1,4
ffffffffc02023d4:	8522                	mv	a0,s0
ffffffffc02023d6:	d93ff0ef          	jal	ra,ffffffffc0202168 <find_vma>
        assert(vma5 == NULL);
ffffffffc02023da:	2c051b63          	bnez	a0,ffffffffc02026b0 <vmm_init+0x406>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02023de:	008b3783          	ld	a5,8(s6)
ffffffffc02023e2:	1c979763          	bne	a5,s1,ffffffffc02025b0 <vmm_init+0x306>
ffffffffc02023e6:	010b3783          	ld	a5,16(s6)
ffffffffc02023ea:	1d379363          	bne	a5,s3,ffffffffc02025b0 <vmm_init+0x306>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02023ee:	008ab783          	ld	a5,8(s5)
ffffffffc02023f2:	1c979f63          	bne	a5,s1,ffffffffc02025d0 <vmm_init+0x326>
ffffffffc02023f6:	010ab783          	ld	a5,16(s5)
ffffffffc02023fa:	1d379b63          	bne	a5,s3,ffffffffc02025d0 <vmm_init+0x326>
ffffffffc02023fe:	0495                	addi	s1,s1,5
ffffffffc0202400:	0995                	addi	s3,s3,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0202402:	f9749be3          	bne	s1,s7,ffffffffc0202398 <vmm_init+0xee>
ffffffffc0202406:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0202408:	59fd                	li	s3,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc020240a:	85a6                	mv	a1,s1
ffffffffc020240c:	8522                	mv	a0,s0
ffffffffc020240e:	d5bff0ef          	jal	ra,ffffffffc0202168 <find_vma>
ffffffffc0202412:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0202416:	c90d                	beqz	a0,ffffffffc0202448 <vmm_init+0x19e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0202418:	6914                	ld	a3,16(a0)
ffffffffc020241a:	6510                	ld	a2,8(a0)
ffffffffc020241c:	00003517          	auipc	a0,0x3
ffffffffc0202420:	61450513          	addi	a0,a0,1556 # ffffffffc0205a30 <commands+0x12b8>
ffffffffc0202424:	c9bfd0ef          	jal	ra,ffffffffc02000be <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0202428:	00003697          	auipc	a3,0x3
ffffffffc020242c:	63068693          	addi	a3,a3,1584 # ffffffffc0205a58 <commands+0x12e0>
ffffffffc0202430:	00003617          	auipc	a2,0x3
ffffffffc0202434:	bb860613          	addi	a2,a2,-1096 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0202438:	0f600593          	li	a1,246
ffffffffc020243c:	00003517          	auipc	a0,0x3
ffffffffc0202440:	3f450513          	addi	a0,a0,1012 # ffffffffc0205830 <commands+0x10b8>
ffffffffc0202444:	cc3fd0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0202448:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc020244a:	fd3490e3          	bne	s1,s3,ffffffffc020240a <vmm_init+0x160>
    }

    mm_destroy(mm);
ffffffffc020244e:	8522                	mv	a0,s0
ffffffffc0202450:	e25ff0ef          	jal	ra,ffffffffc0202274 <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202454:	b97fe0ef          	jal	ra,ffffffffc0200fea <nr_free_pages>
ffffffffc0202458:	28aa1c63          	bne	s4,a0,ffffffffc02026f0 <vmm_init+0x446>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc020245c:	00003517          	auipc	a0,0x3
ffffffffc0202460:	63c50513          	addi	a0,a0,1596 # ffffffffc0205a98 <commands+0x1320>
ffffffffc0202464:	c5bfd0ef          	jal	ra,ffffffffc02000be <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0202468:	b83fe0ef          	jal	ra,ffffffffc0200fea <nr_free_pages>
ffffffffc020246c:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc020246e:	c81ff0ef          	jal	ra,ffffffffc02020ee <mm_create>
ffffffffc0202472:	0000f797          	auipc	a5,0xf
ffffffffc0202476:	02a7bf23          	sd	a0,62(a5) # ffffffffc02114b0 <check_mm_struct>
ffffffffc020247a:	842a                	mv	s0,a0

    assert(check_mm_struct != NULL);
ffffffffc020247c:	2a050a63          	beqz	a0,ffffffffc0202730 <vmm_init+0x486>
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202480:	0000f797          	auipc	a5,0xf
ffffffffc0202484:	fd078793          	addi	a5,a5,-48 # ffffffffc0211450 <boot_pgdir>
ffffffffc0202488:	6384                	ld	s1,0(a5)
    assert(pgdir[0] == 0);
ffffffffc020248a:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020248c:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc020248e:	32079d63          	bnez	a5,ffffffffc02027c8 <vmm_init+0x51e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202492:	03000513          	li	a0,48
ffffffffc0202496:	ab3ff0ef          	jal	ra,ffffffffc0201f48 <kmalloc>
ffffffffc020249a:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc020249c:	14050a63          	beqz	a0,ffffffffc02025f0 <vmm_init+0x346>
        vma->vm_end = vm_end;
ffffffffc02024a0:	002007b7          	lui	a5,0x200
ffffffffc02024a4:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc02024a8:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02024aa:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc02024ac:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc02024b0:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc02024b2:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc02024b6:	cf1ff0ef          	jal	ra,ffffffffc02021a6 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc02024ba:	10000593          	li	a1,256
ffffffffc02024be:	8522                	mv	a0,s0
ffffffffc02024c0:	ca9ff0ef          	jal	ra,ffffffffc0202168 <find_vma>
ffffffffc02024c4:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc02024c8:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02024cc:	2aaa1263          	bne	s4,a0,ffffffffc0202770 <vmm_init+0x4c6>
        *(char *)(addr + i) = i;
ffffffffc02024d0:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc02024d4:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc02024d6:	fee79de3          	bne	a5,a4,ffffffffc02024d0 <vmm_init+0x226>
        sum += i;
ffffffffc02024da:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc02024dc:	10000793          	li	a5,256
        sum += i;
ffffffffc02024e0:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02024e4:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc02024e8:	0007c683          	lbu	a3,0(a5)
ffffffffc02024ec:	0785                	addi	a5,a5,1
ffffffffc02024ee:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02024f0:	fec79ce3          	bne	a5,a2,ffffffffc02024e8 <vmm_init+0x23e>
    }
    assert(sum == 0);
ffffffffc02024f4:	2a071a63          	bnez	a4,ffffffffc02027a8 <vmm_init+0x4fe>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02024f8:	4581                	li	a1,0
ffffffffc02024fa:	8526                	mv	a0,s1
ffffffffc02024fc:	d95fe0ef          	jal	ra,ffffffffc0201290 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202500:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0202502:	0000f717          	auipc	a4,0xf
ffffffffc0202506:	f5670713          	addi	a4,a4,-170 # ffffffffc0211458 <npage>
ffffffffc020250a:	6318                	ld	a4,0(a4)
    return pa2page(PDE_ADDR(pde));
ffffffffc020250c:	078a                	slli	a5,a5,0x2
ffffffffc020250e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202510:	28e7f063          	bleu	a4,a5,ffffffffc0202790 <vmm_init+0x4e6>
    return &pages[PPN(pa) - nbase];
ffffffffc0202514:	00004717          	auipc	a4,0x4
ffffffffc0202518:	06470713          	addi	a4,a4,100 # ffffffffc0206578 <nbase>
ffffffffc020251c:	6318                	ld	a4,0(a4)
ffffffffc020251e:	0000f697          	auipc	a3,0xf
ffffffffc0202522:	f8a68693          	addi	a3,a3,-118 # ffffffffc02114a8 <pages>
ffffffffc0202526:	6288                	ld	a0,0(a3)
ffffffffc0202528:	8f99                	sub	a5,a5,a4
ffffffffc020252a:	00379713          	slli	a4,a5,0x3
ffffffffc020252e:	97ba                	add	a5,a5,a4
ffffffffc0202530:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0202532:	953e                	add	a0,a0,a5
ffffffffc0202534:	4585                	li	a1,1
ffffffffc0202536:	a6ffe0ef          	jal	ra,ffffffffc0200fa4 <free_pages>

    pgdir[0] = 0;
ffffffffc020253a:	0004b023          	sd	zero,0(s1)

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc020253e:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc0202540:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc0202544:	d31ff0ef          	jal	ra,ffffffffc0202274 <mm_destroy>

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0202548:	19fd                	addi	s3,s3,-1
    check_mm_struct = NULL;
ffffffffc020254a:	0000f797          	auipc	a5,0xf
ffffffffc020254e:	f607b323          	sd	zero,-154(a5) # ffffffffc02114b0 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202552:	a99fe0ef          	jal	ra,ffffffffc0200fea <nr_free_pages>
ffffffffc0202556:	1aa99d63          	bne	s3,a0,ffffffffc0202710 <vmm_init+0x466>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc020255a:	00003517          	auipc	a0,0x3
ffffffffc020255e:	5b650513          	addi	a0,a0,1462 # ffffffffc0205b10 <commands+0x1398>
ffffffffc0202562:	b5dfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202566:	a85fe0ef          	jal	ra,ffffffffc0200fea <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc020256a:	197d                	addi	s2,s2,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020256c:	1ea91263          	bne	s2,a0,ffffffffc0202750 <vmm_init+0x4a6>
}
ffffffffc0202570:	6406                	ld	s0,64(sp)
ffffffffc0202572:	60a6                	ld	ra,72(sp)
ffffffffc0202574:	74e2                	ld	s1,56(sp)
ffffffffc0202576:	7942                	ld	s2,48(sp)
ffffffffc0202578:	79a2                	ld	s3,40(sp)
ffffffffc020257a:	7a02                	ld	s4,32(sp)
ffffffffc020257c:	6ae2                	ld	s5,24(sp)
ffffffffc020257e:	6b42                	ld	s6,16(sp)
ffffffffc0202580:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202582:	00003517          	auipc	a0,0x3
ffffffffc0202586:	5ae50513          	addi	a0,a0,1454 # ffffffffc0205b30 <commands+0x13b8>
}
ffffffffc020258a:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc020258c:	b33fd06f          	j	ffffffffc02000be <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202590:	00003697          	auipc	a3,0x3
ffffffffc0202594:	3b868693          	addi	a3,a3,952 # ffffffffc0205948 <commands+0x11d0>
ffffffffc0202598:	00003617          	auipc	a2,0x3
ffffffffc020259c:	a5060613          	addi	a2,a2,-1456 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02025a0:	0dd00593          	li	a1,221
ffffffffc02025a4:	00003517          	auipc	a0,0x3
ffffffffc02025a8:	28c50513          	addi	a0,a0,652 # ffffffffc0205830 <commands+0x10b8>
ffffffffc02025ac:	b5bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02025b0:	00003697          	auipc	a3,0x3
ffffffffc02025b4:	42068693          	addi	a3,a3,1056 # ffffffffc02059d0 <commands+0x1258>
ffffffffc02025b8:	00003617          	auipc	a2,0x3
ffffffffc02025bc:	a3060613          	addi	a2,a2,-1488 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02025c0:	0ed00593          	li	a1,237
ffffffffc02025c4:	00003517          	auipc	a0,0x3
ffffffffc02025c8:	26c50513          	addi	a0,a0,620 # ffffffffc0205830 <commands+0x10b8>
ffffffffc02025cc:	b3bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02025d0:	00003697          	auipc	a3,0x3
ffffffffc02025d4:	43068693          	addi	a3,a3,1072 # ffffffffc0205a00 <commands+0x1288>
ffffffffc02025d8:	00003617          	auipc	a2,0x3
ffffffffc02025dc:	a1060613          	addi	a2,a2,-1520 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02025e0:	0ee00593          	li	a1,238
ffffffffc02025e4:	00003517          	auipc	a0,0x3
ffffffffc02025e8:	24c50513          	addi	a0,a0,588 # ffffffffc0205830 <commands+0x10b8>
ffffffffc02025ec:	b1bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(vma != NULL);
ffffffffc02025f0:	00003697          	auipc	a3,0x3
ffffffffc02025f4:	55868693          	addi	a3,a3,1368 # ffffffffc0205b48 <commands+0x13d0>
ffffffffc02025f8:	00003617          	auipc	a2,0x3
ffffffffc02025fc:	9f060613          	addi	a2,a2,-1552 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0202600:	11100593          	li	a1,273
ffffffffc0202604:	00003517          	auipc	a0,0x3
ffffffffc0202608:	22c50513          	addi	a0,a0,556 # ffffffffc0205830 <commands+0x10b8>
ffffffffc020260c:	afbfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0202610:	00003697          	auipc	a3,0x3
ffffffffc0202614:	32068693          	addi	a3,a3,800 # ffffffffc0205930 <commands+0x11b8>
ffffffffc0202618:	00003617          	auipc	a2,0x3
ffffffffc020261c:	9d060613          	addi	a2,a2,-1584 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0202620:	0db00593          	li	a1,219
ffffffffc0202624:	00003517          	auipc	a0,0x3
ffffffffc0202628:	20c50513          	addi	a0,a0,524 # ffffffffc0205830 <commands+0x10b8>
ffffffffc020262c:	adbfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma4 == NULL);
ffffffffc0202630:	00003697          	auipc	a3,0x3
ffffffffc0202634:	38068693          	addi	a3,a3,896 # ffffffffc02059b0 <commands+0x1238>
ffffffffc0202638:	00003617          	auipc	a2,0x3
ffffffffc020263c:	9b060613          	addi	a2,a2,-1616 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0202640:	0e900593          	li	a1,233
ffffffffc0202644:	00003517          	auipc	a0,0x3
ffffffffc0202648:	1ec50513          	addi	a0,a0,492 # ffffffffc0205830 <commands+0x10b8>
ffffffffc020264c:	abbfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma3 == NULL);
ffffffffc0202650:	00003697          	auipc	a3,0x3
ffffffffc0202654:	35068693          	addi	a3,a3,848 # ffffffffc02059a0 <commands+0x1228>
ffffffffc0202658:	00003617          	auipc	a2,0x3
ffffffffc020265c:	99060613          	addi	a2,a2,-1648 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0202660:	0e700593          	li	a1,231
ffffffffc0202664:	00003517          	auipc	a0,0x3
ffffffffc0202668:	1cc50513          	addi	a0,a0,460 # ffffffffc0205830 <commands+0x10b8>
ffffffffc020266c:	a9bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma2 != NULL);
ffffffffc0202670:	00003697          	auipc	a3,0x3
ffffffffc0202674:	32068693          	addi	a3,a3,800 # ffffffffc0205990 <commands+0x1218>
ffffffffc0202678:	00003617          	auipc	a2,0x3
ffffffffc020267c:	97060613          	addi	a2,a2,-1680 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0202680:	0e500593          	li	a1,229
ffffffffc0202684:	00003517          	auipc	a0,0x3
ffffffffc0202688:	1ac50513          	addi	a0,a0,428 # ffffffffc0205830 <commands+0x10b8>
ffffffffc020268c:	a7bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma1 != NULL);
ffffffffc0202690:	00003697          	auipc	a3,0x3
ffffffffc0202694:	2f068693          	addi	a3,a3,752 # ffffffffc0205980 <commands+0x1208>
ffffffffc0202698:	00003617          	auipc	a2,0x3
ffffffffc020269c:	95060613          	addi	a2,a2,-1712 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02026a0:	0e300593          	li	a1,227
ffffffffc02026a4:	00003517          	auipc	a0,0x3
ffffffffc02026a8:	18c50513          	addi	a0,a0,396 # ffffffffc0205830 <commands+0x10b8>
ffffffffc02026ac:	a5bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma5 == NULL);
ffffffffc02026b0:	00003697          	auipc	a3,0x3
ffffffffc02026b4:	31068693          	addi	a3,a3,784 # ffffffffc02059c0 <commands+0x1248>
ffffffffc02026b8:	00003617          	auipc	a2,0x3
ffffffffc02026bc:	93060613          	addi	a2,a2,-1744 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02026c0:	0eb00593          	li	a1,235
ffffffffc02026c4:	00003517          	auipc	a0,0x3
ffffffffc02026c8:	16c50513          	addi	a0,a0,364 # ffffffffc0205830 <commands+0x10b8>
ffffffffc02026cc:	a3bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(mm != NULL);
ffffffffc02026d0:	00003697          	auipc	a3,0x3
ffffffffc02026d4:	25068693          	addi	a3,a3,592 # ffffffffc0205920 <commands+0x11a8>
ffffffffc02026d8:	00003617          	auipc	a2,0x3
ffffffffc02026dc:	91060613          	addi	a2,a2,-1776 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02026e0:	0c700593          	li	a1,199
ffffffffc02026e4:	00003517          	auipc	a0,0x3
ffffffffc02026e8:	14c50513          	addi	a0,a0,332 # ffffffffc0205830 <commands+0x10b8>
ffffffffc02026ec:	a1bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02026f0:	00003697          	auipc	a3,0x3
ffffffffc02026f4:	38068693          	addi	a3,a3,896 # ffffffffc0205a70 <commands+0x12f8>
ffffffffc02026f8:	00003617          	auipc	a2,0x3
ffffffffc02026fc:	8f060613          	addi	a2,a2,-1808 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0202700:	0fb00593          	li	a1,251
ffffffffc0202704:	00003517          	auipc	a0,0x3
ffffffffc0202708:	12c50513          	addi	a0,a0,300 # ffffffffc0205830 <commands+0x10b8>
ffffffffc020270c:	9fbfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202710:	00003697          	auipc	a3,0x3
ffffffffc0202714:	36068693          	addi	a3,a3,864 # ffffffffc0205a70 <commands+0x12f8>
ffffffffc0202718:	00003617          	auipc	a2,0x3
ffffffffc020271c:	8d060613          	addi	a2,a2,-1840 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0202720:	12e00593          	li	a1,302
ffffffffc0202724:	00003517          	auipc	a0,0x3
ffffffffc0202728:	10c50513          	addi	a0,a0,268 # ffffffffc0205830 <commands+0x10b8>
ffffffffc020272c:	9dbfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0202730:	00003697          	auipc	a3,0x3
ffffffffc0202734:	38868693          	addi	a3,a3,904 # ffffffffc0205ab8 <commands+0x1340>
ffffffffc0202738:	00003617          	auipc	a2,0x3
ffffffffc020273c:	8b060613          	addi	a2,a2,-1872 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0202740:	10a00593          	li	a1,266
ffffffffc0202744:	00003517          	auipc	a0,0x3
ffffffffc0202748:	0ec50513          	addi	a0,a0,236 # ffffffffc0205830 <commands+0x10b8>
ffffffffc020274c:	9bbfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202750:	00003697          	auipc	a3,0x3
ffffffffc0202754:	32068693          	addi	a3,a3,800 # ffffffffc0205a70 <commands+0x12f8>
ffffffffc0202758:	00003617          	auipc	a2,0x3
ffffffffc020275c:	89060613          	addi	a2,a2,-1904 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0202760:	0bd00593          	li	a1,189
ffffffffc0202764:	00003517          	auipc	a0,0x3
ffffffffc0202768:	0cc50513          	addi	a0,a0,204 # ffffffffc0205830 <commands+0x10b8>
ffffffffc020276c:	99bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0202770:	00003697          	auipc	a3,0x3
ffffffffc0202774:	37068693          	addi	a3,a3,880 # ffffffffc0205ae0 <commands+0x1368>
ffffffffc0202778:	00003617          	auipc	a2,0x3
ffffffffc020277c:	87060613          	addi	a2,a2,-1936 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0202780:	11600593          	li	a1,278
ffffffffc0202784:	00003517          	auipc	a0,0x3
ffffffffc0202788:	0ac50513          	addi	a0,a0,172 # ffffffffc0205830 <commands+0x10b8>
ffffffffc020278c:	97bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202790:	00003617          	auipc	a2,0x3
ffffffffc0202794:	aa860613          	addi	a2,a2,-1368 # ffffffffc0205238 <commands+0xac0>
ffffffffc0202798:	06500593          	li	a1,101
ffffffffc020279c:	00003517          	auipc	a0,0x3
ffffffffc02027a0:	abc50513          	addi	a0,a0,-1348 # ffffffffc0205258 <commands+0xae0>
ffffffffc02027a4:	963fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(sum == 0);
ffffffffc02027a8:	00003697          	auipc	a3,0x3
ffffffffc02027ac:	35868693          	addi	a3,a3,856 # ffffffffc0205b00 <commands+0x1388>
ffffffffc02027b0:	00003617          	auipc	a2,0x3
ffffffffc02027b4:	83860613          	addi	a2,a2,-1992 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02027b8:	12000593          	li	a1,288
ffffffffc02027bc:	00003517          	auipc	a0,0x3
ffffffffc02027c0:	07450513          	addi	a0,a0,116 # ffffffffc0205830 <commands+0x10b8>
ffffffffc02027c4:	943fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02027c8:	00003697          	auipc	a3,0x3
ffffffffc02027cc:	30868693          	addi	a3,a3,776 # ffffffffc0205ad0 <commands+0x1358>
ffffffffc02027d0:	00003617          	auipc	a2,0x3
ffffffffc02027d4:	81860613          	addi	a2,a2,-2024 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02027d8:	10d00593          	li	a1,269
ffffffffc02027dc:	00003517          	auipc	a0,0x3
ffffffffc02027e0:	05450513          	addi	a0,a0,84 # ffffffffc0205830 <commands+0x10b8>
ffffffffc02027e4:	923fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02027e8 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02027e8:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02027ea:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02027ec:	f022                	sd	s0,32(sp)
ffffffffc02027ee:	ec26                	sd	s1,24(sp)
ffffffffc02027f0:	f406                	sd	ra,40(sp)
ffffffffc02027f2:	e84a                	sd	s2,16(sp)
ffffffffc02027f4:	8432                	mv	s0,a2
ffffffffc02027f6:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02027f8:	971ff0ef          	jal	ra,ffffffffc0202168 <find_vma>

    pgfault_num++;
ffffffffc02027fc:	0000f797          	auipc	a5,0xf
ffffffffc0202800:	c6478793          	addi	a5,a5,-924 # ffffffffc0211460 <pgfault_num>
ffffffffc0202804:	439c                	lw	a5,0(a5)
ffffffffc0202806:	2785                	addiw	a5,a5,1
ffffffffc0202808:	0000f717          	auipc	a4,0xf
ffffffffc020280c:	c4f72c23          	sw	a5,-936(a4) # ffffffffc0211460 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0202810:	c549                	beqz	a0,ffffffffc020289a <do_pgfault+0xb2>
ffffffffc0202812:	651c                	ld	a5,8(a0)
ffffffffc0202814:	08f46363          	bltu	s0,a5,ffffffffc020289a <do_pgfault+0xb2>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0202818:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc020281a:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020281c:	8b89                	andi	a5,a5,2
ffffffffc020281e:	efa9                	bnez	a5,ffffffffc0202878 <do_pgfault+0x90>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0202820:	767d                	lui	a2,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0202822:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0202824:	8c71                	and	s0,s0,a2
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0202826:	85a2                	mv	a1,s0
ffffffffc0202828:	4605                	li	a2,1
ffffffffc020282a:	801fe0ef          	jal	ra,ffffffffc020102a <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc020282e:	610c                	ld	a1,0(a0)
ffffffffc0202830:	c5b1                	beqz	a1,ffffffffc020287c <do_pgfault+0x94>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0202832:	0000f797          	auipc	a5,0xf
ffffffffc0202836:	c3e78793          	addi	a5,a5,-962 # ffffffffc0211470 <swap_init_ok>
ffffffffc020283a:	439c                	lw	a5,0(a5)
ffffffffc020283c:	2781                	sext.w	a5,a5
ffffffffc020283e:	c7bd                	beqz	a5,ffffffffc02028ac <do_pgfault+0xc4>
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            swap_in(mm, addr, &page);
ffffffffc0202840:	85a2                	mv	a1,s0
ffffffffc0202842:	0030                	addi	a2,sp,8
ffffffffc0202844:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0202846:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc0202848:	1be000ef          	jal	ra,ffffffffc0202a06 <swap_in>
            //into the memory which page managed.
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc020284c:	65a2                	ld	a1,8(sp)
ffffffffc020284e:	6c88                	ld	a0,24(s1)
ffffffffc0202850:	86ca                	mv	a3,s2
ffffffffc0202852:	8622                	mv	a2,s0
ffffffffc0202854:	aaffe0ef          	jal	ra,ffffffffc0201302 <page_insert>
            //logical addr
            //(3) make the page swappable.
            swap_map_swappable(mm, addr, page, 1);
ffffffffc0202858:	6622                	ld	a2,8(sp)
ffffffffc020285a:	4685                	li	a3,1
ffffffffc020285c:	85a2                	mv	a1,s0
ffffffffc020285e:	8526                	mv	a0,s1
ffffffffc0202860:	06c000ef          	jal	ra,ffffffffc02028cc <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0202864:	6722                	ld	a4,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0202866:	4781                	li	a5,0
            page->pra_vaddr = addr;
ffffffffc0202868:	e320                	sd	s0,64(a4)
failed:
    return ret;
}
ffffffffc020286a:	70a2                	ld	ra,40(sp)
ffffffffc020286c:	7402                	ld	s0,32(sp)
ffffffffc020286e:	64e2                	ld	s1,24(sp)
ffffffffc0202870:	6942                	ld	s2,16(sp)
ffffffffc0202872:	853e                	mv	a0,a5
ffffffffc0202874:	6145                	addi	sp,sp,48
ffffffffc0202876:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc0202878:	4959                	li	s2,22
ffffffffc020287a:	b75d                	j	ffffffffc0202820 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc020287c:	6c88                	ld	a0,24(s1)
ffffffffc020287e:	864a                	mv	a2,s2
ffffffffc0202880:	85a2                	mv	a1,s0
ffffffffc0202882:	e34ff0ef          	jal	ra,ffffffffc0201eb6 <pgdir_alloc_page>
   ret = 0;
ffffffffc0202886:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0202888:	f16d                	bnez	a0,ffffffffc020286a <do_pgfault+0x82>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc020288a:	00003517          	auipc	a0,0x3
ffffffffc020288e:	fe650513          	addi	a0,a0,-26 # ffffffffc0205870 <commands+0x10f8>
ffffffffc0202892:	82dfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202896:	57f1                	li	a5,-4
            goto failed;
ffffffffc0202898:	bfc9                	j	ffffffffc020286a <do_pgfault+0x82>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc020289a:	85a2                	mv	a1,s0
ffffffffc020289c:	00003517          	auipc	a0,0x3
ffffffffc02028a0:	fa450513          	addi	a0,a0,-92 # ffffffffc0205840 <commands+0x10c8>
ffffffffc02028a4:	81bfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = -E_INVAL;
ffffffffc02028a8:	57f5                	li	a5,-3
        goto failed;
ffffffffc02028aa:	b7c1                	j	ffffffffc020286a <do_pgfault+0x82>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc02028ac:	00003517          	auipc	a0,0x3
ffffffffc02028b0:	fec50513          	addi	a0,a0,-20 # ffffffffc0205898 <commands+0x1120>
ffffffffc02028b4:	80bfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc02028b8:	57f1                	li	a5,-4
            goto failed;
ffffffffc02028ba:	bf45                	j	ffffffffc020286a <do_pgfault+0x82>

ffffffffc02028bc <swap_init_mm>:
}

int
swap_init_mm(struct mm_struct *mm)
{
     return sm->init_mm(mm);
ffffffffc02028bc:	0000f797          	auipc	a5,0xf
ffffffffc02028c0:	bac78793          	addi	a5,a5,-1108 # ffffffffc0211468 <sm>
ffffffffc02028c4:	639c                	ld	a5,0(a5)
ffffffffc02028c6:	0107b303          	ld	t1,16(a5)
ffffffffc02028ca:	8302                	jr	t1

ffffffffc02028cc <swap_map_swappable>:
}

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc02028cc:	0000f797          	auipc	a5,0xf
ffffffffc02028d0:	b9c78793          	addi	a5,a5,-1124 # ffffffffc0211468 <sm>
ffffffffc02028d4:	639c                	ld	a5,0(a5)
ffffffffc02028d6:	0207b303          	ld	t1,32(a5)
ffffffffc02028da:	8302                	jr	t1

ffffffffc02028dc <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
ffffffffc02028dc:	7159                	addi	sp,sp,-112
ffffffffc02028de:	f486                	sd	ra,104(sp)
ffffffffc02028e0:	f0a2                	sd	s0,96(sp)
ffffffffc02028e2:	eca6                	sd	s1,88(sp)
ffffffffc02028e4:	e8ca                	sd	s2,80(sp)
ffffffffc02028e6:	e4ce                	sd	s3,72(sp)
ffffffffc02028e8:	e0d2                	sd	s4,64(sp)
ffffffffc02028ea:	fc56                	sd	s5,56(sp)
ffffffffc02028ec:	f85a                	sd	s6,48(sp)
ffffffffc02028ee:	f45e                	sd	s7,40(sp)
ffffffffc02028f0:	f062                	sd	s8,32(sp)
ffffffffc02028f2:	ec66                	sd	s9,24(sp)
     int i;
     for (i = 0; i != n; ++ i)
ffffffffc02028f4:	0e058763          	beqz	a1,ffffffffc02029e2 <swap_out+0x106>
ffffffffc02028f8:	8ab2                	mv	s5,a2
ffffffffc02028fa:	892a                	mv	s2,a0
ffffffffc02028fc:	8a2e                	mv	s4,a1
ffffffffc02028fe:	4401                	li	s0,0
ffffffffc0202900:	0000f997          	auipc	s3,0xf
ffffffffc0202904:	b6898993          	addi	s3,s3,-1176 # ffffffffc0211468 <sm>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
                  break;
          }          
          //assert(!PageReserved(page));

          cprintf("SWAP: choose victim page 0x%08x\n", page);
ffffffffc0202908:	00003b17          	auipc	s6,0x3
ffffffffc020290c:	588b0b13          	addi	s6,s6,1416 # ffffffffc0205e90 <commands+0x1718>
                    cprintf("SWAP: failed to save\n");
                    sm->map_swappable(mm, v, page, 0);
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202910:	00003b97          	auipc	s7,0x3
ffffffffc0202914:	5e8b8b93          	addi	s7,s7,1512 # ffffffffc0205ef8 <commands+0x1780>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202918:	00003c17          	auipc	s8,0x3
ffffffffc020291c:	5c8c0c13          	addi	s8,s8,1480 # ffffffffc0205ee0 <commands+0x1768>
ffffffffc0202920:	a825                	j	ffffffffc0202958 <swap_out+0x7c>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202922:	67a2                	ld	a5,8(sp)
ffffffffc0202924:	8626                	mv	a2,s1
ffffffffc0202926:	85a2                	mv	a1,s0
ffffffffc0202928:	63b4                	ld	a3,64(a5)
ffffffffc020292a:	855e                	mv	a0,s7
     for (i = 0; i != n; ++ i)
ffffffffc020292c:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc020292e:	82b1                	srli	a3,a3,0xc
ffffffffc0202930:	0685                	addi	a3,a3,1
ffffffffc0202932:	f8cfd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202936:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202938:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc020293a:	613c                	ld	a5,64(a0)
ffffffffc020293c:	83b1                	srli	a5,a5,0xc
ffffffffc020293e:	0785                	addi	a5,a5,1
ffffffffc0202940:	07a2                	slli	a5,a5,0x8
ffffffffc0202942:	00fcb023          	sd	a5,0(s9)
                    free_page(page);
ffffffffc0202946:	e5efe0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
ffffffffc020294a:	01893503          	ld	a0,24(s2)
ffffffffc020294e:	85a6                	mv	a1,s1
ffffffffc0202950:	d60ff0ef          	jal	ra,ffffffffc0201eb0 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202954:	068a0163          	beq	s4,s0,ffffffffc02029b6 <swap_out+0xda>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202958:	0009b783          	ld	a5,0(s3)
ffffffffc020295c:	8656                	mv	a2,s5
ffffffffc020295e:	002c                	addi	a1,sp,8
ffffffffc0202960:	7b9c                	ld	a5,48(a5)
ffffffffc0202962:	854a                	mv	a0,s2
ffffffffc0202964:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202966:	e535                	bnez	a0,ffffffffc02029d2 <swap_out+0xf6>
          cprintf("SWAP: choose victim page 0x%08x\n", page);
ffffffffc0202968:	65a2                	ld	a1,8(sp)
ffffffffc020296a:	855a                	mv	a0,s6
ffffffffc020296c:	f52fd0ef          	jal	ra,ffffffffc02000be <cprintf>
          v=page->pra_vaddr; 
ffffffffc0202970:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202972:	01893503          	ld	a0,24(s2)
ffffffffc0202976:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202978:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020297a:	85a6                	mv	a1,s1
ffffffffc020297c:	eaefe0ef          	jal	ra,ffffffffc020102a <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202980:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202982:	8caa                	mv	s9,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202984:	8b85                	andi	a5,a5,1
ffffffffc0202986:	c3a5                	beqz	a5,ffffffffc02029e6 <swap_out+0x10a>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202988:	65a2                	ld	a1,8(sp)
ffffffffc020298a:	61bc                	ld	a5,64(a1)
ffffffffc020298c:	83b1                	srli	a5,a5,0xc
ffffffffc020298e:	00178513          	addi	a0,a5,1
ffffffffc0202992:	0522                	slli	a0,a0,0x8
ffffffffc0202994:	678010ef          	jal	ra,ffffffffc020400c <swapfs_write>
ffffffffc0202998:	d549                	beqz	a0,ffffffffc0202922 <swap_out+0x46>
                    cprintf("SWAP: failed to save\n");
ffffffffc020299a:	8562                	mv	a0,s8
ffffffffc020299c:	f22fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02029a0:	0009b783          	ld	a5,0(s3)
ffffffffc02029a4:	6622                	ld	a2,8(sp)
ffffffffc02029a6:	4681                	li	a3,0
ffffffffc02029a8:	739c                	ld	a5,32(a5)
ffffffffc02029aa:	85a6                	mv	a1,s1
ffffffffc02029ac:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc02029ae:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02029b0:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc02029b2:	fa8a13e3          	bne	s4,s0,ffffffffc0202958 <swap_out+0x7c>
     }
     return i;
}
ffffffffc02029b6:	8522                	mv	a0,s0
ffffffffc02029b8:	70a6                	ld	ra,104(sp)
ffffffffc02029ba:	7406                	ld	s0,96(sp)
ffffffffc02029bc:	64e6                	ld	s1,88(sp)
ffffffffc02029be:	6946                	ld	s2,80(sp)
ffffffffc02029c0:	69a6                	ld	s3,72(sp)
ffffffffc02029c2:	6a06                	ld	s4,64(sp)
ffffffffc02029c4:	7ae2                	ld	s5,56(sp)
ffffffffc02029c6:	7b42                	ld	s6,48(sp)
ffffffffc02029c8:	7ba2                	ld	s7,40(sp)
ffffffffc02029ca:	7c02                	ld	s8,32(sp)
ffffffffc02029cc:	6ce2                	ld	s9,24(sp)
ffffffffc02029ce:	6165                	addi	sp,sp,112
ffffffffc02029d0:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc02029d2:	85a2                	mv	a1,s0
ffffffffc02029d4:	00003517          	auipc	a0,0x3
ffffffffc02029d8:	48c50513          	addi	a0,a0,1164 # ffffffffc0205e60 <commands+0x16e8>
ffffffffc02029dc:	ee2fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                  break;
ffffffffc02029e0:	bfd9                	j	ffffffffc02029b6 <swap_out+0xda>
     for (i = 0; i != n; ++ i)
ffffffffc02029e2:	4401                	li	s0,0
ffffffffc02029e4:	bfc9                	j	ffffffffc02029b6 <swap_out+0xda>
          assert((*ptep & PTE_V) != 0);
ffffffffc02029e6:	00003697          	auipc	a3,0x3
ffffffffc02029ea:	4d268693          	addi	a3,a3,1234 # ffffffffc0205eb8 <commands+0x1740>
ffffffffc02029ee:	00002617          	auipc	a2,0x2
ffffffffc02029f2:	5fa60613          	addi	a2,a2,1530 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02029f6:	06800593          	li	a1,104
ffffffffc02029fa:	00003517          	auipc	a0,0x3
ffffffffc02029fe:	4d650513          	addi	a0,a0,1238 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc0202a02:	f04fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202a06 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
ffffffffc0202a06:	7179                	addi	sp,sp,-48
ffffffffc0202a08:	e84a                	sd	s2,16(sp)
ffffffffc0202a0a:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0202a0c:	4505                	li	a0,1
{
ffffffffc0202a0e:	ec26                	sd	s1,24(sp)
ffffffffc0202a10:	e44e                	sd	s3,8(sp)
ffffffffc0202a12:	f406                	sd	ra,40(sp)
ffffffffc0202a14:	f022                	sd	s0,32(sp)
ffffffffc0202a16:	84ae                	mv	s1,a1
ffffffffc0202a18:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0202a1a:	d02fe0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
     assert(result!=NULL);
ffffffffc0202a1e:	c129                	beqz	a0,ffffffffc0202a60 <swap_in+0x5a>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0202a20:	842a                	mv	s0,a0
ffffffffc0202a22:	01893503          	ld	a0,24(s2)
ffffffffc0202a26:	4601                	li	a2,0
ffffffffc0202a28:	85a6                	mv	a1,s1
ffffffffc0202a2a:	e00fe0ef          	jal	ra,ffffffffc020102a <get_pte>
ffffffffc0202a2e:	892a                	mv	s2,a0
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0202a30:	6108                	ld	a0,0(a0)
ffffffffc0202a32:	85a2                	mv	a1,s0
ffffffffc0202a34:	532010ef          	jal	ra,ffffffffc0203f66 <swapfs_read>
     {
        assert(r!=0);
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0202a38:	00093583          	ld	a1,0(s2)
ffffffffc0202a3c:	8626                	mv	a2,s1
ffffffffc0202a3e:	00003517          	auipc	a0,0x3
ffffffffc0202a42:	14a50513          	addi	a0,a0,330 # ffffffffc0205b88 <commands+0x1410>
ffffffffc0202a46:	81a1                	srli	a1,a1,0x8
ffffffffc0202a48:	e76fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     *ptr_result=result;
     return 0;
}
ffffffffc0202a4c:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0202a4e:	0089b023          	sd	s0,0(s3)
}
ffffffffc0202a52:	7402                	ld	s0,32(sp)
ffffffffc0202a54:	64e2                	ld	s1,24(sp)
ffffffffc0202a56:	6942                	ld	s2,16(sp)
ffffffffc0202a58:	69a2                	ld	s3,8(sp)
ffffffffc0202a5a:	4501                	li	a0,0
ffffffffc0202a5c:	6145                	addi	sp,sp,48
ffffffffc0202a5e:	8082                	ret
     assert(result!=NULL);
ffffffffc0202a60:	00003697          	auipc	a3,0x3
ffffffffc0202a64:	11868693          	addi	a3,a3,280 # ffffffffc0205b78 <commands+0x1400>
ffffffffc0202a68:	00002617          	auipc	a2,0x2
ffffffffc0202a6c:	58060613          	addi	a2,a2,1408 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0202a70:	07e00593          	li	a1,126
ffffffffc0202a74:	00003517          	auipc	a0,0x3
ffffffffc0202a78:	45c50513          	addi	a0,a0,1116 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc0202a7c:	e8afd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202a80 <lru_update>:
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
}

void lru_update(int addr){
ffffffffc0202a80:	7179                	addi	sp,sp,-48
ffffffffc0202a82:	f022                	sd	s0,32(sp)
    struct Page* pg = get_page(check_mm_struct->pgdir, addr, NULL);
ffffffffc0202a84:	0000f417          	auipc	s0,0xf
ffffffffc0202a88:	a2c40413          	addi	s0,s0,-1492 # ffffffffc02114b0 <check_mm_struct>
ffffffffc0202a8c:	601c                	ld	a5,0(s0)
ffffffffc0202a8e:	85aa                	mv	a1,a0
ffffffffc0202a90:	4601                	li	a2,0
ffffffffc0202a92:	6f88                	ld	a0,24(a5)
void lru_update(int addr){
ffffffffc0202a94:	f406                	sd	ra,40(sp)
ffffffffc0202a96:	ec26                	sd	s1,24(sp)
ffffffffc0202a98:	e84a                	sd	s2,16(sp)
ffffffffc0202a9a:	e44e                	sd	s3,8(sp)
    struct Page* pg = get_page(check_mm_struct->pgdir, addr, NULL);
ffffffffc0202a9c:	f8cfe0ef          	jal	ra,ffffffffc0201228 <get_page>
    if(check_mm_struct!=NULL){
ffffffffc0202aa0:	601c                	ld	a5,0(s0)
ffffffffc0202aa2:	c3b9                	beqz	a5,ffffffffc0202ae8 <lru_update+0x68>
        list_entry_t *head=(list_entry_t*) check_mm_struct->sm_priv;
ffffffffc0202aa4:	7784                	ld	s1,40(a5)
        assert(head != NULL);
ffffffffc0202aa6:	c8a1                	beqz	s1,ffffffffc0202af6 <lru_update+0x76>
        list_entry_t *le = head->next;
ffffffffc0202aa8:	6480                	ld	s0,8(s1)
        // 遍历check_mm_struct的链表，visited加1,若是刚刚访问的addr，visited改为0
        while (le!=head) {
ffffffffc0202aaa:	02848f63          	beq	s1,s0,ffffffffc0202ae8 <lru_update+0x68>
ffffffffc0202aae:	892a                	mv	s2,a0
            struct Page* page = le2page(le,pra_page_link);
            if(page!=pg) page->visited++;
            else {
               page->visited =0;
               cprintf("visited ref=%d pra_vaddr=%p\n",page->ref,page->pra_vaddr);
ffffffffc0202ab0:	00003997          	auipc	s3,0x3
ffffffffc0202ab4:	0a898993          	addi	s3,s3,168 # ffffffffc0205b58 <commands+0x13e0>
ffffffffc0202ab8:	a809                	j	ffffffffc0202aca <lru_update+0x4a>
            if(page!=pg) page->visited++;
ffffffffc0202aba:	fe043783          	ld	a5,-32(s0)
ffffffffc0202abe:	0785                	addi	a5,a5,1
ffffffffc0202ac0:	fef43023          	sd	a5,-32(s0)
            }
            le = le->next;
ffffffffc0202ac4:	6400                	ld	s0,8(s0)
        while (le!=head) {
ffffffffc0202ac6:	02848163          	beq	s1,s0,ffffffffc0202ae8 <lru_update+0x68>
            struct Page* page = le2page(le,pra_page_link);
ffffffffc0202aca:	fd040793          	addi	a5,s0,-48
            if(page!=pg) page->visited++;
ffffffffc0202ace:	fef916e3          	bne	s2,a5,ffffffffc0202aba <lru_update+0x3a>
               cprintf("visited ref=%d pra_vaddr=%p\n",page->ref,page->pra_vaddr);
ffffffffc0202ad2:	6810                	ld	a2,16(s0)
ffffffffc0202ad4:	fd042583          	lw	a1,-48(s0)
               page->visited =0;
ffffffffc0202ad8:	fe043023          	sd	zero,-32(s0)
               cprintf("visited ref=%d pra_vaddr=%p\n",page->ref,page->pra_vaddr);
ffffffffc0202adc:	854e                	mv	a0,s3
ffffffffc0202ade:	de0fd0ef          	jal	ra,ffffffffc02000be <cprintf>
            le = le->next;
ffffffffc0202ae2:	6400                	ld	s0,8(s0)
        while (le!=head) {
ffffffffc0202ae4:	fe8493e3          	bne	s1,s0,ffffffffc0202aca <lru_update+0x4a>
        }
        return;
    }
    return;

}
ffffffffc0202ae8:	70a2                	ld	ra,40(sp)
ffffffffc0202aea:	7402                	ld	s0,32(sp)
ffffffffc0202aec:	64e2                	ld	s1,24(sp)
ffffffffc0202aee:	6942                	ld	s2,16(sp)
ffffffffc0202af0:	69a2                	ld	s3,8(sp)
ffffffffc0202af2:	6145                	addi	sp,sp,48
ffffffffc0202af4:	8082                	ret
        assert(head != NULL);
ffffffffc0202af6:	00002697          	auipc	a3,0x2
ffffffffc0202afa:	68a68693          	addi	a3,a3,1674 # ffffffffc0205180 <commands+0xa08>
ffffffffc0202afe:	00002617          	auipc	a2,0x2
ffffffffc0202b02:	4ea60613          	addi	a2,a2,1258 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0202b06:	13400593          	li	a1,308
ffffffffc0202b0a:	00003517          	auipc	a0,0x3
ffffffffc0202b0e:	3c650513          	addi	a0,a0,966 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc0202b12:	df4fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202b16 <swap_init>:
{
ffffffffc0202b16:	7135                	addi	sp,sp,-160
ffffffffc0202b18:	ed06                	sd	ra,152(sp)
ffffffffc0202b1a:	e922                	sd	s0,144(sp)
ffffffffc0202b1c:	e526                	sd	s1,136(sp)
ffffffffc0202b1e:	e14a                	sd	s2,128(sp)
ffffffffc0202b20:	fcce                	sd	s3,120(sp)
ffffffffc0202b22:	f8d2                	sd	s4,112(sp)
ffffffffc0202b24:	f4d6                	sd	s5,104(sp)
ffffffffc0202b26:	f0da                	sd	s6,96(sp)
ffffffffc0202b28:	ecde                	sd	s7,88(sp)
ffffffffc0202b2a:	e8e2                	sd	s8,80(sp)
ffffffffc0202b2c:	e4e6                	sd	s9,72(sp)
ffffffffc0202b2e:	e0ea                	sd	s10,64(sp)
ffffffffc0202b30:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202b32:	3fc010ef          	jal	ra,ffffffffc0203f2e <swapfs_init>
     if (!(7 <= max_swap_offset &&
ffffffffc0202b36:	0000f797          	auipc	a5,0xf
ffffffffc0202b3a:	a0a78793          	addi	a5,a5,-1526 # ffffffffc0211540 <max_swap_offset>
ffffffffc0202b3e:	6394                	ld	a3,0(a5)
ffffffffc0202b40:	010007b7          	lui	a5,0x1000
ffffffffc0202b44:	17e1                	addi	a5,a5,-8
ffffffffc0202b46:	ff968713          	addi	a4,a3,-7
ffffffffc0202b4a:	54e7e963          	bltu	a5,a4,ffffffffc020309c <swap_init+0x586>
     sm = &swap_manager_lru;//use first in first out Page Replacement Algorithm
ffffffffc0202b4e:	00007797          	auipc	a5,0x7
ffffffffc0202b52:	4b278793          	addi	a5,a5,1202 # ffffffffc020a000 <swap_manager_lru>
     int r = sm->init(); 
ffffffffc0202b56:	6798                	ld	a4,8(a5)
     sm = &swap_manager_lru;//use first in first out Page Replacement Algorithm
ffffffffc0202b58:	0000f697          	auipc	a3,0xf
ffffffffc0202b5c:	90f6b823          	sd	a5,-1776(a3) # ffffffffc0211468 <sm>
ffffffffc0202b60:	0000fc97          	auipc	s9,0xf
ffffffffc0202b64:	908c8c93          	addi	s9,s9,-1784 # ffffffffc0211468 <sm>
     int r = sm->init(); 
ffffffffc0202b68:	9702                	jalr	a4
ffffffffc0202b6a:	8b2a                	mv	s6,a0
     if (r == 0)
ffffffffc0202b6c:	c10d                	beqz	a0,ffffffffc0202b8e <swap_init+0x78>
}
ffffffffc0202b6e:	60ea                	ld	ra,152(sp)
ffffffffc0202b70:	644a                	ld	s0,144(sp)
ffffffffc0202b72:	855a                	mv	a0,s6
ffffffffc0202b74:	64aa                	ld	s1,136(sp)
ffffffffc0202b76:	690a                	ld	s2,128(sp)
ffffffffc0202b78:	79e6                	ld	s3,120(sp)
ffffffffc0202b7a:	7a46                	ld	s4,112(sp)
ffffffffc0202b7c:	7aa6                	ld	s5,104(sp)
ffffffffc0202b7e:	7b06                	ld	s6,96(sp)
ffffffffc0202b80:	6be6                	ld	s7,88(sp)
ffffffffc0202b82:	6c46                	ld	s8,80(sp)
ffffffffc0202b84:	6ca6                	ld	s9,72(sp)
ffffffffc0202b86:	6d06                	ld	s10,64(sp)
ffffffffc0202b88:	7de2                	ld	s11,56(sp)
ffffffffc0202b8a:	610d                	addi	sp,sp,160
ffffffffc0202b8c:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202b8e:	000cb783          	ld	a5,0(s9)
ffffffffc0202b92:	00003517          	auipc	a0,0x3
ffffffffc0202b96:	05650513          	addi	a0,a0,86 # ffffffffc0205be8 <commands+0x1470>
ffffffffc0202b9a:	0000f417          	auipc	s0,0xf
ffffffffc0202b9e:	9e640413          	addi	s0,s0,-1562 # ffffffffc0211580 <free_area>
ffffffffc0202ba2:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202ba4:	4785                	li	a5,1
ffffffffc0202ba6:	0000f717          	auipc	a4,0xf
ffffffffc0202baa:	8cf72523          	sw	a5,-1846(a4) # ffffffffc0211470 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202bae:	d10fd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202bb2:	641c                	ld	a5,8(s0)
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bb4:	40878863          	beq	a5,s0,ffffffffc0202fc4 <swap_init+0x4ae>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202bb8:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202bbc:	8305                	srli	a4,a4,0x1
        assert(PageProperty(p));
ffffffffc0202bbe:	8b05                	andi	a4,a4,1
ffffffffc0202bc0:	40070663          	beqz	a4,ffffffffc0202fcc <swap_init+0x4b6>
     int ret, count = 0, total = 0, i;
ffffffffc0202bc4:	4481                	li	s1,0
ffffffffc0202bc6:	4901                	li	s2,0
ffffffffc0202bc8:	a031                	j	ffffffffc0202bd4 <swap_init+0xbe>
ffffffffc0202bca:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0202bce:	8b09                	andi	a4,a4,2
ffffffffc0202bd0:	3e070e63          	beqz	a4,ffffffffc0202fcc <swap_init+0x4b6>
        count ++, total += p->property;
ffffffffc0202bd4:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202bd8:	679c                	ld	a5,8(a5)
ffffffffc0202bda:	2905                	addiw	s2,s2,1
ffffffffc0202bdc:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bde:	fe8796e3          	bne	a5,s0,ffffffffc0202bca <swap_init+0xb4>
ffffffffc0202be2:	89a6                	mv	s3,s1
     assert(total == nr_free_pages());
ffffffffc0202be4:	c06fe0ef          	jal	ra,ffffffffc0200fea <nr_free_pages>
ffffffffc0202be8:	5b351663          	bne	a0,s3,ffffffffc0203194 <swap_init+0x67e>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202bec:	8626                	mv	a2,s1
ffffffffc0202bee:	85ca                	mv	a1,s2
ffffffffc0202bf0:	00003517          	auipc	a0,0x3
ffffffffc0202bf4:	04050513          	addi	a0,a0,64 # ffffffffc0205c30 <commands+0x14b8>
ffffffffc0202bf8:	cc6fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     struct mm_struct *mm = mm_create();
ffffffffc0202bfc:	cf2ff0ef          	jal	ra,ffffffffc02020ee <mm_create>
ffffffffc0202c00:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202c02:	50050963          	beqz	a0,ffffffffc0203114 <swap_init+0x5fe>
     assert(check_mm_struct == NULL);
ffffffffc0202c06:	0000f797          	auipc	a5,0xf
ffffffffc0202c0a:	8aa78793          	addi	a5,a5,-1878 # ffffffffc02114b0 <check_mm_struct>
ffffffffc0202c0e:	639c                	ld	a5,0(a5)
ffffffffc0202c10:	52079263          	bnez	a5,ffffffffc0203134 <swap_init+0x61e>
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202c14:	0000f797          	auipc	a5,0xf
ffffffffc0202c18:	83c78793          	addi	a5,a5,-1988 # ffffffffc0211450 <boot_pgdir>
ffffffffc0202c1c:	6398                	ld	a4,0(a5)
     check_mm_struct = mm;
ffffffffc0202c1e:	0000f797          	auipc	a5,0xf
ffffffffc0202c22:	88a7b923          	sd	a0,-1902(a5) # ffffffffc02114b0 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc0202c26:	631c                	ld	a5,0(a4)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202c28:	ec3a                	sd	a4,24(sp)
ffffffffc0202c2a:	ed18                	sd	a4,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202c2c:	4a079463          	bnez	a5,ffffffffc02030d4 <swap_init+0x5be>
     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202c30:	6599                	lui	a1,0x6
ffffffffc0202c32:	460d                	li	a2,3
ffffffffc0202c34:	6505                	lui	a0,0x1
ffffffffc0202c36:	d04ff0ef          	jal	ra,ffffffffc020213a <vma_create>
ffffffffc0202c3a:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202c3c:	4a050c63          	beqz	a0,ffffffffc02030f4 <swap_init+0x5de>
     insert_vma_struct(mm, vma);
ffffffffc0202c40:	855e                	mv	a0,s7
ffffffffc0202c42:	d64ff0ef          	jal	ra,ffffffffc02021a6 <insert_vma_struct>
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202c46:	00003517          	auipc	a0,0x3
ffffffffc0202c4a:	02a50513          	addi	a0,a0,42 # ffffffffc0205c70 <commands+0x14f8>
ffffffffc0202c4e:	c70fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202c52:	018bb503          	ld	a0,24(s7)
ffffffffc0202c56:	4605                	li	a2,1
ffffffffc0202c58:	6585                	lui	a1,0x1
ffffffffc0202c5a:	bd0fe0ef          	jal	ra,ffffffffc020102a <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202c5e:	44050b63          	beqz	a0,ffffffffc02030b4 <swap_init+0x59e>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202c62:	00003517          	auipc	a0,0x3
ffffffffc0202c66:	05e50513          	addi	a0,a0,94 # ffffffffc0205cc0 <commands+0x1548>
ffffffffc0202c6a:	0000fa17          	auipc	s4,0xf
ffffffffc0202c6e:	84ea0a13          	addi	s4,s4,-1970 # ffffffffc02114b8 <check_rp>
ffffffffc0202c72:	c4cfd0ef          	jal	ra,ffffffffc02000be <cprintf>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c76:	0000fa97          	auipc	s5,0xf
ffffffffc0202c7a:	862a8a93          	addi	s5,s5,-1950 # ffffffffc02114d8 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202c7e:	89d2                	mv	s3,s4
          check_rp[i] = alloc_page();
ffffffffc0202c80:	4505                	li	a0,1
ffffffffc0202c82:	a9afe0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0202c86:	00a9b023          	sd	a0,0(s3)
          assert(check_rp[i] != NULL );
ffffffffc0202c8a:	36050163          	beqz	a0,ffffffffc0202fec <swap_init+0x4d6>
ffffffffc0202c8e:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202c90:	8b89                	andi	a5,a5,2
ffffffffc0202c92:	38079d63          	bnez	a5,ffffffffc020302c <swap_init+0x516>
ffffffffc0202c96:	09a1                	addi	s3,s3,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c98:	ff5994e3          	bne	s3,s5,ffffffffc0202c80 <swap_init+0x16a>
     list_entry_t free_list_store = free_list;
ffffffffc0202c9c:	601c                	ld	a5,0(s0)
ffffffffc0202c9e:	00843983          	ld	s3,8(s0)
     nr_free = 0;
ffffffffc0202ca2:	0000fd17          	auipc	s10,0xf
ffffffffc0202ca6:	816d0d13          	addi	s10,s10,-2026 # ffffffffc02114b8 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc0202caa:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202cac:	481c                	lw	a5,16(s0)
ffffffffc0202cae:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0202cb0:	0000f797          	auipc	a5,0xf
ffffffffc0202cb4:	8c87bc23          	sd	s0,-1832(a5) # ffffffffc0211588 <free_area+0x8>
ffffffffc0202cb8:	0000f797          	auipc	a5,0xf
ffffffffc0202cbc:	8c87b423          	sd	s0,-1848(a5) # ffffffffc0211580 <free_area>
     nr_free = 0;
ffffffffc0202cc0:	0000f797          	auipc	a5,0xf
ffffffffc0202cc4:	8c07a823          	sw	zero,-1840(a5) # ffffffffc0211590 <free_area+0x10>
        free_pages(check_rp[i],1);
ffffffffc0202cc8:	000d3503          	ld	a0,0(s10)
ffffffffc0202ccc:	4585                	li	a1,1
ffffffffc0202cce:	0d21                	addi	s10,s10,8
ffffffffc0202cd0:	ad4fe0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202cd4:	ff5d1ae3          	bne	s10,s5,ffffffffc0202cc8 <swap_init+0x1b2>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202cd8:	01042d03          	lw	s10,16(s0)
ffffffffc0202cdc:	4791                	li	a5,4
ffffffffc0202cde:	5cfd1b63          	bne	s10,a5,ffffffffc02032b4 <swap_init+0x79e>
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202ce2:	00003517          	auipc	a0,0x3
ffffffffc0202ce6:	06650513          	addi	a0,a0,102 # ffffffffc0205d48 <commands+0x15d0>
ffffffffc0202cea:	bd4fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     if(strcmp(sm->name,"lru swap manager")==0){
ffffffffc0202cee:	000cb783          	ld	a5,0(s9)
ffffffffc0202cf2:	00002597          	auipc	a1,0x2
ffffffffc0202cf6:	4ae58593          	addi	a1,a1,1198 # ffffffffc02051a0 <commands+0xa28>
     pgfault_num=0;
ffffffffc0202cfa:	0000ed97          	auipc	s11,0xe
ffffffffc0202cfe:	766d8d93          	addi	s11,s11,1894 # ffffffffc0211460 <pgfault_num>
     if(strcmp(sm->name,"lru swap manager")==0){
ffffffffc0202d02:	6388                	ld	a0,0(a5)
     pgfault_num=0;
ffffffffc0202d04:	0000e797          	auipc	a5,0xe
ffffffffc0202d08:	7407ae23          	sw	zero,1884(a5) # ffffffffc0211460 <pgfault_num>
     if(strcmp(sm->name,"lru swap manager")==0){
ffffffffc0202d0c:	3fc010ef          	jal	ra,ffffffffc0204108 <strcmp>

void lru_access(int addr, int val){
    *(unsigned char *)addr = val;
ffffffffc0202d10:	6705                	lui	a4,0x1
ffffffffc0202d12:	46a9                	li	a3,10
ffffffffc0202d14:	00d70023          	sb	a3,0(a4) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     if(strcmp(sm->name,"lru swap manager")==0){
ffffffffc0202d18:	1a050d63          	beqz	a0,ffffffffc0202ed2 <swap_init+0x3bc>
     assert(pgfault_num==1);
ffffffffc0202d1c:	000da783          	lw	a5,0(s11)
ffffffffc0202d20:	4605                	li	a2,1
ffffffffc0202d22:	2781                	sext.w	a5,a5
ffffffffc0202d24:	48c79863          	bne	a5,a2,ffffffffc02031b4 <swap_init+0x69e>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202d28:	00d70823          	sb	a3,16(a4)
     assert(pgfault_num==1);
ffffffffc0202d2c:	000da703          	lw	a4,0(s11)
ffffffffc0202d30:	2701                	sext.w	a4,a4
ffffffffc0202d32:	4af71163          	bne	a4,a5,ffffffffc02031d4 <swap_init+0x6be>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202d36:	6709                	lui	a4,0x2
ffffffffc0202d38:	46ad                	li	a3,11
ffffffffc0202d3a:	00d70023          	sb	a3,0(a4) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202d3e:	000da783          	lw	a5,0(s11)
ffffffffc0202d42:	4609                	li	a2,2
ffffffffc0202d44:	2781                	sext.w	a5,a5
ffffffffc0202d46:	4ac79763          	bne	a5,a2,ffffffffc02031f4 <swap_init+0x6de>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202d4a:	00d70823          	sb	a3,16(a4)
     assert(pgfault_num==2);
ffffffffc0202d4e:	000da703          	lw	a4,0(s11)
ffffffffc0202d52:	2701                	sext.w	a4,a4
ffffffffc0202d54:	4cf71063          	bne	a4,a5,ffffffffc0203214 <swap_init+0x6fe>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202d58:	670d                	lui	a4,0x3
ffffffffc0202d5a:	46b1                	li	a3,12
ffffffffc0202d5c:	00d70023          	sb	a3,0(a4) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202d60:	000da783          	lw	a5,0(s11)
ffffffffc0202d64:	460d                	li	a2,3
ffffffffc0202d66:	2781                	sext.w	a5,a5
ffffffffc0202d68:	4cc79663          	bne	a5,a2,ffffffffc0203234 <swap_init+0x71e>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202d6c:	00d70823          	sb	a3,16(a4)
     assert(pgfault_num==3);
ffffffffc0202d70:	000da703          	lw	a4,0(s11)
ffffffffc0202d74:	2701                	sext.w	a4,a4
ffffffffc0202d76:	4cf71f63          	bne	a4,a5,ffffffffc0203254 <swap_init+0x73e>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202d7a:	6791                	lui	a5,0x4
ffffffffc0202d7c:	4735                	li	a4,13
ffffffffc0202d7e:	00e78023          	sb	a4,0(a5) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202d82:	000da783          	lw	a5,0(s11)
ffffffffc0202d86:	2781                	sext.w	a5,a5
ffffffffc0202d88:	4fa79663          	bne	a5,s10,ffffffffc0203274 <swap_init+0x75e>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202d8c:	6791                	lui	a5,0x4
ffffffffc0202d8e:	4735                	li	a4,13
ffffffffc0202d90:	00e78823          	sb	a4,16(a5) # 4010 <BASE_ADDRESS-0xffffffffc01fbff0>
     assert(pgfault_num==4);
ffffffffc0202d94:	000da783          	lw	a5,0(s11)
ffffffffc0202d98:	4711                	li	a4,4
ffffffffc0202d9a:	2781                	sext.w	a5,a5
ffffffffc0202d9c:	4ee79c63          	bne	a5,a4,ffffffffc0203294 <swap_init+0x77e>
     assert( nr_free == 0);         
ffffffffc0202da0:	481c                	lw	a5,16(s0)
ffffffffc0202da2:	3a079963          	bnez	a5,ffffffffc0203154 <swap_init+0x63e>
ffffffffc0202da6:	0000e797          	auipc	a5,0xe
ffffffffc0202daa:	73278793          	addi	a5,a5,1842 # ffffffffc02114d8 <swap_in_seq_no>
ffffffffc0202dae:	0000e717          	auipc	a4,0xe
ffffffffc0202db2:	75270713          	addi	a4,a4,1874 # ffffffffc0211500 <swap_out_seq_no>
ffffffffc0202db6:	0000e617          	auipc	a2,0xe
ffffffffc0202dba:	74a60613          	addi	a2,a2,1866 # ffffffffc0211500 <swap_out_seq_no>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202dbe:	56fd                	li	a3,-1
ffffffffc0202dc0:	c394                	sw	a3,0(a5)
ffffffffc0202dc2:	c314                	sw	a3,0(a4)
ffffffffc0202dc4:	0791                	addi	a5,a5,4
ffffffffc0202dc6:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202dc8:	fec79ce3          	bne	a5,a2,ffffffffc0202dc0 <swap_init+0x2aa>
ffffffffc0202dcc:	0000e697          	auipc	a3,0xe
ffffffffc0202dd0:	79468693          	addi	a3,a3,1940 # ffffffffc0211560 <check_ptep>
ffffffffc0202dd4:	0000e817          	auipc	a6,0xe
ffffffffc0202dd8:	6e480813          	addi	a6,a6,1764 # ffffffffc02114b8 <check_rp>
ffffffffc0202ddc:	6705                	lui	a4,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202dde:	0000ec17          	auipc	s8,0xe
ffffffffc0202de2:	67ac0c13          	addi	s8,s8,1658 # ffffffffc0211458 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202de6:	0000ed97          	auipc	s11,0xe
ffffffffc0202dea:	6c2d8d93          	addi	s11,s11,1730 # ffffffffc02114a8 <pages>
ffffffffc0202dee:	00003d17          	auipc	s10,0x3
ffffffffc0202df2:	78ad0d13          	addi	s10,s10,1930 # ffffffffc0206578 <nbase>
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202df6:	6562                	ld	a0,24(sp)
ffffffffc0202df8:	85ba                	mv	a1,a4
         check_ptep[i]=0;
ffffffffc0202dfa:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202dfe:	4601                	li	a2,0
ffffffffc0202e00:	e842                	sd	a6,16(sp)
ffffffffc0202e02:	e43a                	sd	a4,8(sp)
         check_ptep[i]=0;
ffffffffc0202e04:	e036                	sd	a3,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202e06:	a24fe0ef          	jal	ra,ffffffffc020102a <get_pte>
ffffffffc0202e0a:	6682                	ld	a3,0(sp)
         assert(check_ptep[i] != NULL);
ffffffffc0202e0c:	6722                	ld	a4,8(sp)
ffffffffc0202e0e:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202e10:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202e12:	22050d63          	beqz	a0,ffffffffc020304c <swap_init+0x536>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202e16:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202e18:	0017f613          	andi	a2,a5,1
ffffffffc0202e1c:	24060863          	beqz	a2,ffffffffc020306c <swap_init+0x556>
    if (PPN(pa) >= npage) {
ffffffffc0202e20:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202e24:	078a                	slli	a5,a5,0x2
ffffffffc0202e26:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e28:	24c7fe63          	bleu	a2,a5,ffffffffc0203084 <swap_init+0x56e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e2c:	000d3603          	ld	a2,0(s10)
ffffffffc0202e30:	000db583          	ld	a1,0(s11)
ffffffffc0202e34:	00083503          	ld	a0,0(a6)
ffffffffc0202e38:	8f91                	sub	a5,a5,a2
ffffffffc0202e3a:	00379613          	slli	a2,a5,0x3
ffffffffc0202e3e:	97b2                	add	a5,a5,a2
ffffffffc0202e40:	078e                	slli	a5,a5,0x3
ffffffffc0202e42:	97ae                	add	a5,a5,a1
ffffffffc0202e44:	1cf51463          	bne	a0,a5,ffffffffc020300c <swap_init+0x4f6>
ffffffffc0202e48:	6785                	lui	a5,0x1
ffffffffc0202e4a:	973e                	add	a4,a4,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202e4c:	6795                	lui	a5,0x5
ffffffffc0202e4e:	06a1                	addi	a3,a3,8
ffffffffc0202e50:	0821                	addi	a6,a6,8
ffffffffc0202e52:	faf712e3          	bne	a4,a5,ffffffffc0202df6 <swap_init+0x2e0>
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202e56:	00003517          	auipc	a0,0x3
ffffffffc0202e5a:	f9a50513          	addi	a0,a0,-102 # ffffffffc0205df0 <commands+0x1678>
ffffffffc0202e5e:	a60fd0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = sm->check_swap();
ffffffffc0202e62:	000cb783          	ld	a5,0(s9)
ffffffffc0202e66:	7f9c                	ld	a5,56(a5)
ffffffffc0202e68:	9782                	jalr	a5
     assert(ret==0);
ffffffffc0202e6a:	30051563          	bnez	a0,ffffffffc0203174 <swap_init+0x65e>
         free_pages(check_rp[i],1);
ffffffffc0202e6e:	000a3503          	ld	a0,0(s4)
ffffffffc0202e72:	4585                	li	a1,1
ffffffffc0202e74:	0a21                	addi	s4,s4,8
ffffffffc0202e76:	92efe0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202e7a:	ff5a1ae3          	bne	s4,s5,ffffffffc0202e6e <swap_init+0x358>
     mm_destroy(mm);
ffffffffc0202e7e:	855e                	mv	a0,s7
ffffffffc0202e80:	bf4ff0ef          	jal	ra,ffffffffc0202274 <mm_destroy>
     nr_free = nr_free_store;
ffffffffc0202e84:	77a2                	ld	a5,40(sp)
ffffffffc0202e86:	0000e717          	auipc	a4,0xe
ffffffffc0202e8a:	70f72523          	sw	a5,1802(a4) # ffffffffc0211590 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202e8e:	7782                	ld	a5,32(sp)
ffffffffc0202e90:	0000e717          	auipc	a4,0xe
ffffffffc0202e94:	6ef73823          	sd	a5,1776(a4) # ffffffffc0211580 <free_area>
ffffffffc0202e98:	0000e797          	auipc	a5,0xe
ffffffffc0202e9c:	6f37b823          	sd	s3,1776(a5) # ffffffffc0211588 <free_area+0x8>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202ea0:	00898a63          	beq	s3,s0,ffffffffc0202eb4 <swap_init+0x39e>
         count --, total -= p->property;
ffffffffc0202ea4:	ff89a783          	lw	a5,-8(s3)
    return listelm->next;
ffffffffc0202ea8:	0089b983          	ld	s3,8(s3)
ffffffffc0202eac:	397d                	addiw	s2,s2,-1
ffffffffc0202eae:	9c9d                	subw	s1,s1,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202eb0:	fe899ae3          	bne	s3,s0,ffffffffc0202ea4 <swap_init+0x38e>
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202eb4:	8626                	mv	a2,s1
ffffffffc0202eb6:	85ca                	mv	a1,s2
ffffffffc0202eb8:	00003517          	auipc	a0,0x3
ffffffffc0202ebc:	f6850513          	addi	a0,a0,-152 # ffffffffc0205e20 <commands+0x16a8>
ffffffffc0202ec0:	9fefd0ef          	jal	ra,ffffffffc02000be <cprintf>
     cprintf("check_swap() succeeded!\n");
ffffffffc0202ec4:	00003517          	auipc	a0,0x3
ffffffffc0202ec8:	f7c50513          	addi	a0,a0,-132 # ffffffffc0205e40 <commands+0x16c8>
ffffffffc0202ecc:	9f2fd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202ed0:	b979                	j	ffffffffc0202b6e <swap_init+0x58>
    lru_update(addr);
ffffffffc0202ed2:	6505                	lui	a0,0x1
    *(unsigned char *)addr = val;
ffffffffc0202ed4:	e036                	sd	a3,0(sp)
    lru_update(addr);
ffffffffc0202ed6:	babff0ef          	jal	ra,ffffffffc0202a80 <lru_update>
          assert(pgfault_num==1);
ffffffffc0202eda:	000da783          	lw	a5,0(s11)
ffffffffc0202ede:	4605                	li	a2,1
ffffffffc0202ee0:	6705                	lui	a4,0x1
ffffffffc0202ee2:	00078c1b          	sext.w	s8,a5
ffffffffc0202ee6:	6682                	ld	a3,0(sp)
ffffffffc0202ee8:	3ecc1663          	bne	s8,a2,ffffffffc02032d4 <swap_init+0x7be>
    *(unsigned char *)addr = val;
ffffffffc0202eec:	00d70823          	sb	a3,16(a4) # 1010 <BASE_ADDRESS-0xffffffffc01feff0>
    lru_update(addr);
ffffffffc0202ef0:	01070513          	addi	a0,a4,16
ffffffffc0202ef4:	b8dff0ef          	jal	ra,ffffffffc0202a80 <lru_update>
          assert(pgfault_num==1);
ffffffffc0202ef8:	000da703          	lw	a4,0(s11)
ffffffffc0202efc:	2701                	sext.w	a4,a4
ffffffffc0202efe:	41871b63          	bne	a4,s8,ffffffffc0203314 <swap_init+0x7fe>
    *(unsigned char *)addr = val;
ffffffffc0202f02:	46ad                	li	a3,11
ffffffffc0202f04:	6709                	lui	a4,0x2
ffffffffc0202f06:	00d70023          	sb	a3,0(a4) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    lru_update(addr);
ffffffffc0202f0a:	6509                	lui	a0,0x2
    *(unsigned char *)addr = val;
ffffffffc0202f0c:	e036                	sd	a3,0(sp)
    lru_update(addr);
ffffffffc0202f0e:	b73ff0ef          	jal	ra,ffffffffc0202a80 <lru_update>
          assert(pgfault_num==2);
ffffffffc0202f12:	000da783          	lw	a5,0(s11)
ffffffffc0202f16:	4609                	li	a2,2
ffffffffc0202f18:	6709                	lui	a4,0x2
ffffffffc0202f1a:	00078c1b          	sext.w	s8,a5
ffffffffc0202f1e:	6682                	ld	a3,0(sp)
ffffffffc0202f20:	3ccc1a63          	bne	s8,a2,ffffffffc02032f4 <swap_init+0x7de>
    *(unsigned char *)addr = val;
ffffffffc0202f24:	00d70823          	sb	a3,16(a4) # 2010 <BASE_ADDRESS-0xffffffffc01fdff0>
    lru_update(addr);
ffffffffc0202f28:	01070513          	addi	a0,a4,16
ffffffffc0202f2c:	b55ff0ef          	jal	ra,ffffffffc0202a80 <lru_update>
          assert(pgfault_num==2);
ffffffffc0202f30:	000da703          	lw	a4,0(s11)
ffffffffc0202f34:	2701                	sext.w	a4,a4
ffffffffc0202f36:	45871f63          	bne	a4,s8,ffffffffc0203394 <swap_init+0x87e>
    *(unsigned char *)addr = val;
ffffffffc0202f3a:	46b1                	li	a3,12
ffffffffc0202f3c:	670d                	lui	a4,0x3
ffffffffc0202f3e:	00d70023          	sb	a3,0(a4) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    lru_update(addr);
ffffffffc0202f42:	650d                	lui	a0,0x3
    *(unsigned char *)addr = val;
ffffffffc0202f44:	e036                	sd	a3,0(sp)
    lru_update(addr);
ffffffffc0202f46:	b3bff0ef          	jal	ra,ffffffffc0202a80 <lru_update>
          assert(pgfault_num==3);
ffffffffc0202f4a:	000da783          	lw	a5,0(s11)
ffffffffc0202f4e:	460d                	li	a2,3
ffffffffc0202f50:	670d                	lui	a4,0x3
ffffffffc0202f52:	00078c1b          	sext.w	s8,a5
ffffffffc0202f56:	6682                	ld	a3,0(sp)
ffffffffc0202f58:	40cc1e63          	bne	s8,a2,ffffffffc0203374 <swap_init+0x85e>
    *(unsigned char *)addr = val;
ffffffffc0202f5c:	00d70823          	sb	a3,16(a4) # 3010 <BASE_ADDRESS-0xffffffffc01fcff0>
    lru_update(addr);
ffffffffc0202f60:	01070513          	addi	a0,a4,16
ffffffffc0202f64:	b1dff0ef          	jal	ra,ffffffffc0202a80 <lru_update>
          assert(pgfault_num==3);
ffffffffc0202f68:	000da703          	lw	a4,0(s11)
ffffffffc0202f6c:	2701                	sext.w	a4,a4
ffffffffc0202f6e:	3f871363          	bne	a4,s8,ffffffffc0203354 <swap_init+0x83e>
    *(unsigned char *)addr = val;
ffffffffc0202f72:	6791                	lui	a5,0x4
ffffffffc0202f74:	4735                	li	a4,13
ffffffffc0202f76:	00e78023          	sb	a4,0(a5) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    lru_update(addr);
ffffffffc0202f7a:	6511                	lui	a0,0x4
ffffffffc0202f7c:	b05ff0ef          	jal	ra,ffffffffc0202a80 <lru_update>
          assert(pgfault_num==4);
ffffffffc0202f80:	000da783          	lw	a5,0(s11)
ffffffffc0202f84:	2781                	sext.w	a5,a5
ffffffffc0202f86:	3ba79763          	bne	a5,s10,ffffffffc0203334 <swap_init+0x81e>
    *(unsigned char *)addr = val;
ffffffffc0202f8a:	47b5                	li	a5,13
ffffffffc0202f8c:	6511                	lui	a0,0x4
ffffffffc0202f8e:	00f50823          	sb	a5,16(a0) # 4010 <BASE_ADDRESS-0xffffffffc01fbff0>
    lru_update(addr);
ffffffffc0202f92:	0541                	addi	a0,a0,16
ffffffffc0202f94:	aedff0ef          	jal	ra,ffffffffc0202a80 <lru_update>
          assert(pgfault_num==4);
ffffffffc0202f98:	000da783          	lw	a5,0(s11)
ffffffffc0202f9c:	4711                	li	a4,4
ffffffffc0202f9e:	2781                	sext.w	a5,a5
ffffffffc0202fa0:	e0e780e3          	beq	a5,a4,ffffffffc0202da0 <swap_init+0x28a>
ffffffffc0202fa4:	00002697          	auipc	a3,0x2
ffffffffc0202fa8:	03468693          	addi	a3,a3,52 # ffffffffc0204fd8 <commands+0x860>
ffffffffc0202fac:	00002617          	auipc	a2,0x2
ffffffffc0202fb0:	03c60613          	addi	a2,a2,60 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0202fb4:	0a200593          	li	a1,162
ffffffffc0202fb8:	00003517          	auipc	a0,0x3
ffffffffc0202fbc:	f1850513          	addi	a0,a0,-232 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc0202fc0:	946fd0ef          	jal	ra,ffffffffc0200106 <__panic>
     int ret, count = 0, total = 0, i;
ffffffffc0202fc4:	4481                	li	s1,0
ffffffffc0202fc6:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202fc8:	4981                	li	s3,0
ffffffffc0202fca:	b929                	j	ffffffffc0202be4 <swap_init+0xce>
        assert(PageProperty(p));
ffffffffc0202fcc:	00003697          	auipc	a3,0x3
ffffffffc0202fd0:	c3468693          	addi	a3,a3,-972 # ffffffffc0205c00 <commands+0x1488>
ffffffffc0202fd4:	00002617          	auipc	a2,0x2
ffffffffc0202fd8:	01460613          	addi	a2,a2,20 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0202fdc:	0d000593          	li	a1,208
ffffffffc0202fe0:	00003517          	auipc	a0,0x3
ffffffffc0202fe4:	ef050513          	addi	a0,a0,-272 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc0202fe8:	91efd0ef          	jal	ra,ffffffffc0200106 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202fec:	00003697          	auipc	a3,0x3
ffffffffc0202ff0:	cfc68693          	addi	a3,a3,-772 # ffffffffc0205ce8 <commands+0x1570>
ffffffffc0202ff4:	00002617          	auipc	a2,0x2
ffffffffc0202ff8:	ff460613          	addi	a2,a2,-12 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0202ffc:	0f000593          	li	a1,240
ffffffffc0203000:	00003517          	auipc	a0,0x3
ffffffffc0203004:	ed050513          	addi	a0,a0,-304 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc0203008:	8fefd0ef          	jal	ra,ffffffffc0200106 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020300c:	00003697          	auipc	a3,0x3
ffffffffc0203010:	dbc68693          	addi	a3,a3,-580 # ffffffffc0205dc8 <commands+0x1650>
ffffffffc0203014:	00002617          	auipc	a2,0x2
ffffffffc0203018:	fd460613          	addi	a2,a2,-44 # ffffffffc0204fe8 <commands+0x870>
ffffffffc020301c:	11000593          	li	a1,272
ffffffffc0203020:	00003517          	auipc	a0,0x3
ffffffffc0203024:	eb050513          	addi	a0,a0,-336 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc0203028:	8defd0ef          	jal	ra,ffffffffc0200106 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc020302c:	00003697          	auipc	a3,0x3
ffffffffc0203030:	cd468693          	addi	a3,a3,-812 # ffffffffc0205d00 <commands+0x1588>
ffffffffc0203034:	00002617          	auipc	a2,0x2
ffffffffc0203038:	fb460613          	addi	a2,a2,-76 # ffffffffc0204fe8 <commands+0x870>
ffffffffc020303c:	0f100593          	li	a1,241
ffffffffc0203040:	00003517          	auipc	a0,0x3
ffffffffc0203044:	e9050513          	addi	a0,a0,-368 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc0203048:	8befd0ef          	jal	ra,ffffffffc0200106 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc020304c:	00003697          	auipc	a3,0x3
ffffffffc0203050:	d6468693          	addi	a3,a3,-668 # ffffffffc0205db0 <commands+0x1638>
ffffffffc0203054:	00002617          	auipc	a2,0x2
ffffffffc0203058:	f9460613          	addi	a2,a2,-108 # ffffffffc0204fe8 <commands+0x870>
ffffffffc020305c:	10f00593          	li	a1,271
ffffffffc0203060:	00003517          	auipc	a0,0x3
ffffffffc0203064:	e7050513          	addi	a0,a0,-400 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc0203068:	89efd0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020306c:	00002617          	auipc	a2,0x2
ffffffffc0203070:	3c460613          	addi	a2,a2,964 # ffffffffc0205430 <commands+0xcb8>
ffffffffc0203074:	07000593          	li	a1,112
ffffffffc0203078:	00002517          	auipc	a0,0x2
ffffffffc020307c:	1e050513          	addi	a0,a0,480 # ffffffffc0205258 <commands+0xae0>
ffffffffc0203080:	886fd0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203084:	00002617          	auipc	a2,0x2
ffffffffc0203088:	1b460613          	addi	a2,a2,436 # ffffffffc0205238 <commands+0xac0>
ffffffffc020308c:	06500593          	li	a1,101
ffffffffc0203090:	00002517          	auipc	a0,0x2
ffffffffc0203094:	1c850513          	addi	a0,a0,456 # ffffffffc0205258 <commands+0xae0>
ffffffffc0203098:	86efd0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc020309c:	00003617          	auipc	a2,0x3
ffffffffc02030a0:	b2c60613          	addi	a2,a2,-1236 # ffffffffc0205bc8 <commands+0x1450>
ffffffffc02030a4:	02800593          	li	a1,40
ffffffffc02030a8:	00003517          	auipc	a0,0x3
ffffffffc02030ac:	e2850513          	addi	a0,a0,-472 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc02030b0:	856fd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc02030b4:	00003697          	auipc	a3,0x3
ffffffffc02030b8:	bf468693          	addi	a3,a3,-1036 # ffffffffc0205ca8 <commands+0x1530>
ffffffffc02030bc:	00002617          	auipc	a2,0x2
ffffffffc02030c0:	f2c60613          	addi	a2,a2,-212 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02030c4:	0eb00593          	li	a1,235
ffffffffc02030c8:	00003517          	auipc	a0,0x3
ffffffffc02030cc:	e0850513          	addi	a0,a0,-504 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc02030d0:	836fd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgdir[0] == 0);
ffffffffc02030d4:	00003697          	auipc	a3,0x3
ffffffffc02030d8:	9fc68693          	addi	a3,a3,-1540 # ffffffffc0205ad0 <commands+0x1358>
ffffffffc02030dc:	00002617          	auipc	a2,0x2
ffffffffc02030e0:	f0c60613          	addi	a2,a2,-244 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02030e4:	0e000593          	li	a1,224
ffffffffc02030e8:	00003517          	auipc	a0,0x3
ffffffffc02030ec:	de850513          	addi	a0,a0,-536 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc02030f0:	816fd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(vma != NULL);
ffffffffc02030f4:	00003697          	auipc	a3,0x3
ffffffffc02030f8:	a5468693          	addi	a3,a3,-1452 # ffffffffc0205b48 <commands+0x13d0>
ffffffffc02030fc:	00002617          	auipc	a2,0x2
ffffffffc0203100:	eec60613          	addi	a2,a2,-276 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203104:	0e300593          	li	a1,227
ffffffffc0203108:	00003517          	auipc	a0,0x3
ffffffffc020310c:	dc850513          	addi	a0,a0,-568 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc0203110:	ff7fc0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(mm != NULL);
ffffffffc0203114:	00003697          	auipc	a3,0x3
ffffffffc0203118:	80c68693          	addi	a3,a3,-2036 # ffffffffc0205920 <commands+0x11a8>
ffffffffc020311c:	00002617          	auipc	a2,0x2
ffffffffc0203120:	ecc60613          	addi	a2,a2,-308 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203124:	0d800593          	li	a1,216
ffffffffc0203128:	00003517          	auipc	a0,0x3
ffffffffc020312c:	da850513          	addi	a0,a0,-600 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc0203130:	fd7fc0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203134:	00003697          	auipc	a3,0x3
ffffffffc0203138:	b2468693          	addi	a3,a3,-1244 # ffffffffc0205c58 <commands+0x14e0>
ffffffffc020313c:	00002617          	auipc	a2,0x2
ffffffffc0203140:	eac60613          	addi	a2,a2,-340 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203144:	0db00593          	li	a1,219
ffffffffc0203148:	00003517          	auipc	a0,0x3
ffffffffc020314c:	d8850513          	addi	a0,a0,-632 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc0203150:	fb7fc0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert( nr_free == 0);         
ffffffffc0203154:	00003697          	auipc	a3,0x3
ffffffffc0203158:	c4c68693          	addi	a3,a3,-948 # ffffffffc0205da0 <commands+0x1628>
ffffffffc020315c:	00002617          	auipc	a2,0x2
ffffffffc0203160:	e8c60613          	addi	a2,a2,-372 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203164:	10700593          	li	a1,263
ffffffffc0203168:	00003517          	auipc	a0,0x3
ffffffffc020316c:	d6850513          	addi	a0,a0,-664 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc0203170:	f97fc0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(ret==0);
ffffffffc0203174:	00003697          	auipc	a3,0x3
ffffffffc0203178:	ca468693          	addi	a3,a3,-860 # ffffffffc0205e18 <commands+0x16a0>
ffffffffc020317c:	00002617          	auipc	a2,0x2
ffffffffc0203180:	e6c60613          	addi	a2,a2,-404 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203184:	11600593          	li	a1,278
ffffffffc0203188:	00003517          	auipc	a0,0x3
ffffffffc020318c:	d4850513          	addi	a0,a0,-696 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc0203190:	f77fc0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203194:	00003697          	auipc	a3,0x3
ffffffffc0203198:	a7c68693          	addi	a3,a3,-1412 # ffffffffc0205c10 <commands+0x1498>
ffffffffc020319c:	00002617          	auipc	a2,0x2
ffffffffc02031a0:	e4c60613          	addi	a2,a2,-436 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02031a4:	0d300593          	li	a1,211
ffffffffc02031a8:	00003517          	auipc	a0,0x3
ffffffffc02031ac:	d2850513          	addi	a0,a0,-728 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc02031b0:	f57fc0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==1);
ffffffffc02031b4:	00003697          	auipc	a3,0x3
ffffffffc02031b8:	bbc68693          	addi	a3,a3,-1092 # ffffffffc0205d70 <commands+0x15f8>
ffffffffc02031bc:	00002617          	auipc	a2,0x2
ffffffffc02031c0:	e2c60613          	addi	a2,a2,-468 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02031c4:	0a600593          	li	a1,166
ffffffffc02031c8:	00003517          	auipc	a0,0x3
ffffffffc02031cc:	d0850513          	addi	a0,a0,-760 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc02031d0:	f37fc0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==1);
ffffffffc02031d4:	00003697          	auipc	a3,0x3
ffffffffc02031d8:	b9c68693          	addi	a3,a3,-1124 # ffffffffc0205d70 <commands+0x15f8>
ffffffffc02031dc:	00002617          	auipc	a2,0x2
ffffffffc02031e0:	e0c60613          	addi	a2,a2,-500 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02031e4:	0a800593          	li	a1,168
ffffffffc02031e8:	00003517          	auipc	a0,0x3
ffffffffc02031ec:	ce850513          	addi	a0,a0,-792 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc02031f0:	f17fc0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==2);
ffffffffc02031f4:	00003697          	auipc	a3,0x3
ffffffffc02031f8:	b8c68693          	addi	a3,a3,-1140 # ffffffffc0205d80 <commands+0x1608>
ffffffffc02031fc:	00002617          	auipc	a2,0x2
ffffffffc0203200:	dec60613          	addi	a2,a2,-532 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203204:	0aa00593          	li	a1,170
ffffffffc0203208:	00003517          	auipc	a0,0x3
ffffffffc020320c:	cc850513          	addi	a0,a0,-824 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc0203210:	ef7fc0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==2);
ffffffffc0203214:	00003697          	auipc	a3,0x3
ffffffffc0203218:	b6c68693          	addi	a3,a3,-1172 # ffffffffc0205d80 <commands+0x1608>
ffffffffc020321c:	00002617          	auipc	a2,0x2
ffffffffc0203220:	dcc60613          	addi	a2,a2,-564 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203224:	0ac00593          	li	a1,172
ffffffffc0203228:	00003517          	auipc	a0,0x3
ffffffffc020322c:	ca850513          	addi	a0,a0,-856 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc0203230:	ed7fc0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==3);
ffffffffc0203234:	00003697          	auipc	a3,0x3
ffffffffc0203238:	b5c68693          	addi	a3,a3,-1188 # ffffffffc0205d90 <commands+0x1618>
ffffffffc020323c:	00002617          	auipc	a2,0x2
ffffffffc0203240:	dac60613          	addi	a2,a2,-596 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203244:	0ae00593          	li	a1,174
ffffffffc0203248:	00003517          	auipc	a0,0x3
ffffffffc020324c:	c8850513          	addi	a0,a0,-888 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc0203250:	eb7fc0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==3);
ffffffffc0203254:	00003697          	auipc	a3,0x3
ffffffffc0203258:	b3c68693          	addi	a3,a3,-1220 # ffffffffc0205d90 <commands+0x1618>
ffffffffc020325c:	00002617          	auipc	a2,0x2
ffffffffc0203260:	d8c60613          	addi	a2,a2,-628 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203264:	0b000593          	li	a1,176
ffffffffc0203268:	00003517          	auipc	a0,0x3
ffffffffc020326c:	c6850513          	addi	a0,a0,-920 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc0203270:	e97fc0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==4);
ffffffffc0203274:	00002697          	auipc	a3,0x2
ffffffffc0203278:	d6468693          	addi	a3,a3,-668 # ffffffffc0204fd8 <commands+0x860>
ffffffffc020327c:	00002617          	auipc	a2,0x2
ffffffffc0203280:	d6c60613          	addi	a2,a2,-660 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203284:	0b200593          	li	a1,178
ffffffffc0203288:	00003517          	auipc	a0,0x3
ffffffffc020328c:	c4850513          	addi	a0,a0,-952 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc0203290:	e77fc0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==4);
ffffffffc0203294:	00002697          	auipc	a3,0x2
ffffffffc0203298:	d4468693          	addi	a3,a3,-700 # ffffffffc0204fd8 <commands+0x860>
ffffffffc020329c:	00002617          	auipc	a2,0x2
ffffffffc02032a0:	d4c60613          	addi	a2,a2,-692 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02032a4:	0b400593          	li	a1,180
ffffffffc02032a8:	00003517          	auipc	a0,0x3
ffffffffc02032ac:	c2850513          	addi	a0,a0,-984 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc02032b0:	e57fc0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02032b4:	00003697          	auipc	a3,0x3
ffffffffc02032b8:	a6c68693          	addi	a3,a3,-1428 # ffffffffc0205d20 <commands+0x15a8>
ffffffffc02032bc:	00002617          	auipc	a2,0x2
ffffffffc02032c0:	d2c60613          	addi	a2,a2,-724 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02032c4:	0fe00593          	li	a1,254
ffffffffc02032c8:	00003517          	auipc	a0,0x3
ffffffffc02032cc:	c0850513          	addi	a0,a0,-1016 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc02032d0:	e37fc0ef          	jal	ra,ffffffffc0200106 <__panic>
          assert(pgfault_num==1);
ffffffffc02032d4:	00003697          	auipc	a3,0x3
ffffffffc02032d8:	a9c68693          	addi	a3,a3,-1380 # ffffffffc0205d70 <commands+0x15f8>
ffffffffc02032dc:	00002617          	auipc	a2,0x2
ffffffffc02032e0:	d0c60613          	addi	a2,a2,-756 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02032e4:	09400593          	li	a1,148
ffffffffc02032e8:	00003517          	auipc	a0,0x3
ffffffffc02032ec:	be850513          	addi	a0,a0,-1048 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc02032f0:	e17fc0ef          	jal	ra,ffffffffc0200106 <__panic>
          assert(pgfault_num==2);
ffffffffc02032f4:	00003697          	auipc	a3,0x3
ffffffffc02032f8:	a8c68693          	addi	a3,a3,-1396 # ffffffffc0205d80 <commands+0x1608>
ffffffffc02032fc:	00002617          	auipc	a2,0x2
ffffffffc0203300:	cec60613          	addi	a2,a2,-788 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203304:	09800593          	li	a1,152
ffffffffc0203308:	00003517          	auipc	a0,0x3
ffffffffc020330c:	bc850513          	addi	a0,a0,-1080 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc0203310:	df7fc0ef          	jal	ra,ffffffffc0200106 <__panic>
          assert(pgfault_num==1);
ffffffffc0203314:	00003697          	auipc	a3,0x3
ffffffffc0203318:	a5c68693          	addi	a3,a3,-1444 # ffffffffc0205d70 <commands+0x15f8>
ffffffffc020331c:	00002617          	auipc	a2,0x2
ffffffffc0203320:	ccc60613          	addi	a2,a2,-820 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203324:	09600593          	li	a1,150
ffffffffc0203328:	00003517          	auipc	a0,0x3
ffffffffc020332c:	ba850513          	addi	a0,a0,-1112 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc0203330:	dd7fc0ef          	jal	ra,ffffffffc0200106 <__panic>
          assert(pgfault_num==4);
ffffffffc0203334:	00002697          	auipc	a3,0x2
ffffffffc0203338:	ca468693          	addi	a3,a3,-860 # ffffffffc0204fd8 <commands+0x860>
ffffffffc020333c:	00002617          	auipc	a2,0x2
ffffffffc0203340:	cac60613          	addi	a2,a2,-852 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203344:	0a000593          	li	a1,160
ffffffffc0203348:	00003517          	auipc	a0,0x3
ffffffffc020334c:	b8850513          	addi	a0,a0,-1144 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc0203350:	db7fc0ef          	jal	ra,ffffffffc0200106 <__panic>
          assert(pgfault_num==3);
ffffffffc0203354:	00003697          	auipc	a3,0x3
ffffffffc0203358:	a3c68693          	addi	a3,a3,-1476 # ffffffffc0205d90 <commands+0x1618>
ffffffffc020335c:	00002617          	auipc	a2,0x2
ffffffffc0203360:	c8c60613          	addi	a2,a2,-884 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203364:	09e00593          	li	a1,158
ffffffffc0203368:	00003517          	auipc	a0,0x3
ffffffffc020336c:	b6850513          	addi	a0,a0,-1176 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc0203370:	d97fc0ef          	jal	ra,ffffffffc0200106 <__panic>
          assert(pgfault_num==3);
ffffffffc0203374:	00003697          	auipc	a3,0x3
ffffffffc0203378:	a1c68693          	addi	a3,a3,-1508 # ffffffffc0205d90 <commands+0x1618>
ffffffffc020337c:	00002617          	auipc	a2,0x2
ffffffffc0203380:	c6c60613          	addi	a2,a2,-916 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203384:	09c00593          	li	a1,156
ffffffffc0203388:	00003517          	auipc	a0,0x3
ffffffffc020338c:	b4850513          	addi	a0,a0,-1208 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc0203390:	d77fc0ef          	jal	ra,ffffffffc0200106 <__panic>
          assert(pgfault_num==2);
ffffffffc0203394:	00003697          	auipc	a3,0x3
ffffffffc0203398:	9ec68693          	addi	a3,a3,-1556 # ffffffffc0205d80 <commands+0x1608>
ffffffffc020339c:	00002617          	auipc	a2,0x2
ffffffffc02033a0:	c4c60613          	addi	a2,a2,-948 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02033a4:	09a00593          	li	a1,154
ffffffffc02033a8:	00003517          	auipc	a0,0x3
ffffffffc02033ac:	b2850513          	addi	a0,a0,-1240 # ffffffffc0205ed0 <commands+0x1758>
ffffffffc02033b0:	d57fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02033b4 <lru_access>:
    *(unsigned char *)addr = val;
ffffffffc02033b4:	00b50023          	sb	a1,0(a0)
    lru_update(addr);
ffffffffc02033b8:	ec8ff06f          	j	ffffffffc0202a80 <lru_update>

ffffffffc02033bc <default_init>:
    elm->prev = elm->next = elm;
ffffffffc02033bc:	0000e797          	auipc	a5,0xe
ffffffffc02033c0:	1c478793          	addi	a5,a5,452 # ffffffffc0211580 <free_area>
ffffffffc02033c4:	e79c                	sd	a5,8(a5)
ffffffffc02033c6:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc02033c8:	0007a823          	sw	zero,16(a5)
}
ffffffffc02033cc:	8082                	ret

ffffffffc02033ce <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc02033ce:	0000e517          	auipc	a0,0xe
ffffffffc02033d2:	1c256503          	lwu	a0,450(a0) # ffffffffc0211590 <free_area+0x10>
ffffffffc02033d6:	8082                	ret

ffffffffc02033d8 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc02033d8:	715d                	addi	sp,sp,-80
ffffffffc02033da:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc02033dc:	0000e917          	auipc	s2,0xe
ffffffffc02033e0:	1a490913          	addi	s2,s2,420 # ffffffffc0211580 <free_area>
ffffffffc02033e4:	00893783          	ld	a5,8(s2)
ffffffffc02033e8:	e486                	sd	ra,72(sp)
ffffffffc02033ea:	e0a2                	sd	s0,64(sp)
ffffffffc02033ec:	fc26                	sd	s1,56(sp)
ffffffffc02033ee:	f44e                	sd	s3,40(sp)
ffffffffc02033f0:	f052                	sd	s4,32(sp)
ffffffffc02033f2:	ec56                	sd	s5,24(sp)
ffffffffc02033f4:	e85a                	sd	s6,16(sp)
ffffffffc02033f6:	e45e                	sd	s7,8(sp)
ffffffffc02033f8:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02033fa:	31278f63          	beq	a5,s2,ffffffffc0203718 <default_check+0x340>
ffffffffc02033fe:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203402:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203404:	8b05                	andi	a4,a4,1
ffffffffc0203406:	30070d63          	beqz	a4,ffffffffc0203720 <default_check+0x348>
    int count = 0, total = 0;
ffffffffc020340a:	4401                	li	s0,0
ffffffffc020340c:	4481                	li	s1,0
ffffffffc020340e:	a031                	j	ffffffffc020341a <default_check+0x42>
ffffffffc0203410:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0203414:	8b09                	andi	a4,a4,2
ffffffffc0203416:	30070563          	beqz	a4,ffffffffc0203720 <default_check+0x348>
        count ++, total += p->property;
ffffffffc020341a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020341e:	679c                	ld	a5,8(a5)
ffffffffc0203420:	2485                	addiw	s1,s1,1
ffffffffc0203422:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203424:	ff2796e3          	bne	a5,s2,ffffffffc0203410 <default_check+0x38>
ffffffffc0203428:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc020342a:	bc1fd0ef          	jal	ra,ffffffffc0200fea <nr_free_pages>
ffffffffc020342e:	75351963          	bne	a0,s3,ffffffffc0203b80 <default_check+0x7a8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203432:	4505                	li	a0,1
ffffffffc0203434:	ae9fd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0203438:	8a2a                	mv	s4,a0
ffffffffc020343a:	48050363          	beqz	a0,ffffffffc02038c0 <default_check+0x4e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020343e:	4505                	li	a0,1
ffffffffc0203440:	addfd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0203444:	89aa                	mv	s3,a0
ffffffffc0203446:	74050d63          	beqz	a0,ffffffffc0203ba0 <default_check+0x7c8>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020344a:	4505                	li	a0,1
ffffffffc020344c:	ad1fd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0203450:	8aaa                	mv	s5,a0
ffffffffc0203452:	4e050763          	beqz	a0,ffffffffc0203940 <default_check+0x568>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0203456:	2f3a0563          	beq	s4,s3,ffffffffc0203740 <default_check+0x368>
ffffffffc020345a:	2eaa0363          	beq	s4,a0,ffffffffc0203740 <default_check+0x368>
ffffffffc020345e:	2ea98163          	beq	s3,a0,ffffffffc0203740 <default_check+0x368>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0203462:	000a2783          	lw	a5,0(s4)
ffffffffc0203466:	2e079d63          	bnez	a5,ffffffffc0203760 <default_check+0x388>
ffffffffc020346a:	0009a783          	lw	a5,0(s3)
ffffffffc020346e:	2e079963          	bnez	a5,ffffffffc0203760 <default_check+0x388>
ffffffffc0203472:	411c                	lw	a5,0(a0)
ffffffffc0203474:	2e079663          	bnez	a5,ffffffffc0203760 <default_check+0x388>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203478:	0000e797          	auipc	a5,0xe
ffffffffc020347c:	03078793          	addi	a5,a5,48 # ffffffffc02114a8 <pages>
ffffffffc0203480:	639c                	ld	a5,0(a5)
ffffffffc0203482:	00002717          	auipc	a4,0x2
ffffffffc0203486:	d3670713          	addi	a4,a4,-714 # ffffffffc02051b8 <commands+0xa40>
ffffffffc020348a:	630c                	ld	a1,0(a4)
ffffffffc020348c:	40fa0733          	sub	a4,s4,a5
ffffffffc0203490:	870d                	srai	a4,a4,0x3
ffffffffc0203492:	02b70733          	mul	a4,a4,a1
ffffffffc0203496:	00003697          	auipc	a3,0x3
ffffffffc020349a:	0e268693          	addi	a3,a3,226 # ffffffffc0206578 <nbase>
ffffffffc020349e:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02034a0:	0000e697          	auipc	a3,0xe
ffffffffc02034a4:	fb868693          	addi	a3,a3,-72 # ffffffffc0211458 <npage>
ffffffffc02034a8:	6294                	ld	a3,0(a3)
ffffffffc02034aa:	06b2                	slli	a3,a3,0xc
ffffffffc02034ac:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02034ae:	0732                	slli	a4,a4,0xc
ffffffffc02034b0:	2cd77863          	bleu	a3,a4,ffffffffc0203780 <default_check+0x3a8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02034b4:	40f98733          	sub	a4,s3,a5
ffffffffc02034b8:	870d                	srai	a4,a4,0x3
ffffffffc02034ba:	02b70733          	mul	a4,a4,a1
ffffffffc02034be:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02034c0:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02034c2:	4ed77f63          	bleu	a3,a4,ffffffffc02039c0 <default_check+0x5e8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02034c6:	40f507b3          	sub	a5,a0,a5
ffffffffc02034ca:	878d                	srai	a5,a5,0x3
ffffffffc02034cc:	02b787b3          	mul	a5,a5,a1
ffffffffc02034d0:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02034d2:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02034d4:	34d7f663          	bleu	a3,a5,ffffffffc0203820 <default_check+0x448>
    assert(alloc_page() == NULL);
ffffffffc02034d8:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02034da:	00093c03          	ld	s8,0(s2)
ffffffffc02034de:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc02034e2:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc02034e6:	0000e797          	auipc	a5,0xe
ffffffffc02034ea:	0b27b123          	sd	s2,162(a5) # ffffffffc0211588 <free_area+0x8>
ffffffffc02034ee:	0000e797          	auipc	a5,0xe
ffffffffc02034f2:	0927b923          	sd	s2,146(a5) # ffffffffc0211580 <free_area>
    nr_free = 0;
ffffffffc02034f6:	0000e797          	auipc	a5,0xe
ffffffffc02034fa:	0807ad23          	sw	zero,154(a5) # ffffffffc0211590 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02034fe:	a1ffd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0203502:	2e051f63          	bnez	a0,ffffffffc0203800 <default_check+0x428>
    free_page(p0);
ffffffffc0203506:	4585                	li	a1,1
ffffffffc0203508:	8552                	mv	a0,s4
ffffffffc020350a:	a9bfd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
    free_page(p1);
ffffffffc020350e:	4585                	li	a1,1
ffffffffc0203510:	854e                	mv	a0,s3
ffffffffc0203512:	a93fd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
    free_page(p2);
ffffffffc0203516:	4585                	li	a1,1
ffffffffc0203518:	8556                	mv	a0,s5
ffffffffc020351a:	a8bfd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
    assert(nr_free == 3);
ffffffffc020351e:	01092703          	lw	a4,16(s2)
ffffffffc0203522:	478d                	li	a5,3
ffffffffc0203524:	2af71e63          	bne	a4,a5,ffffffffc02037e0 <default_check+0x408>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203528:	4505                	li	a0,1
ffffffffc020352a:	9f3fd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc020352e:	89aa                	mv	s3,a0
ffffffffc0203530:	28050863          	beqz	a0,ffffffffc02037c0 <default_check+0x3e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203534:	4505                	li	a0,1
ffffffffc0203536:	9e7fd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc020353a:	8aaa                	mv	s5,a0
ffffffffc020353c:	3e050263          	beqz	a0,ffffffffc0203920 <default_check+0x548>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203540:	4505                	li	a0,1
ffffffffc0203542:	9dbfd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0203546:	8a2a                	mv	s4,a0
ffffffffc0203548:	3a050c63          	beqz	a0,ffffffffc0203900 <default_check+0x528>
    assert(alloc_page() == NULL);
ffffffffc020354c:	4505                	li	a0,1
ffffffffc020354e:	9cffd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0203552:	38051763          	bnez	a0,ffffffffc02038e0 <default_check+0x508>
    free_page(p0);
ffffffffc0203556:	4585                	li	a1,1
ffffffffc0203558:	854e                	mv	a0,s3
ffffffffc020355a:	a4bfd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc020355e:	00893783          	ld	a5,8(s2)
ffffffffc0203562:	23278f63          	beq	a5,s2,ffffffffc02037a0 <default_check+0x3c8>
    assert((p = alloc_page()) == p0);
ffffffffc0203566:	4505                	li	a0,1
ffffffffc0203568:	9b5fd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc020356c:	32a99a63          	bne	s3,a0,ffffffffc02038a0 <default_check+0x4c8>
    assert(alloc_page() == NULL);
ffffffffc0203570:	4505                	li	a0,1
ffffffffc0203572:	9abfd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0203576:	30051563          	bnez	a0,ffffffffc0203880 <default_check+0x4a8>
    assert(nr_free == 0);
ffffffffc020357a:	01092783          	lw	a5,16(s2)
ffffffffc020357e:	2e079163          	bnez	a5,ffffffffc0203860 <default_check+0x488>
    free_page(p);
ffffffffc0203582:	854e                	mv	a0,s3
ffffffffc0203584:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0203586:	0000e797          	auipc	a5,0xe
ffffffffc020358a:	ff87bd23          	sd	s8,-6(a5) # ffffffffc0211580 <free_area>
ffffffffc020358e:	0000e797          	auipc	a5,0xe
ffffffffc0203592:	ff77bd23          	sd	s7,-6(a5) # ffffffffc0211588 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0203596:	0000e797          	auipc	a5,0xe
ffffffffc020359a:	ff67ad23          	sw	s6,-6(a5) # ffffffffc0211590 <free_area+0x10>
    free_page(p);
ffffffffc020359e:	a07fd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
    free_page(p1);
ffffffffc02035a2:	4585                	li	a1,1
ffffffffc02035a4:	8556                	mv	a0,s5
ffffffffc02035a6:	9fffd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
    free_page(p2);
ffffffffc02035aa:	4585                	li	a1,1
ffffffffc02035ac:	8552                	mv	a0,s4
ffffffffc02035ae:	9f7fd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02035b2:	4515                	li	a0,5
ffffffffc02035b4:	969fd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc02035b8:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02035ba:	28050363          	beqz	a0,ffffffffc0203840 <default_check+0x468>
ffffffffc02035be:	651c                	ld	a5,8(a0)
ffffffffc02035c0:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc02035c2:	8b85                	andi	a5,a5,1
ffffffffc02035c4:	54079e63          	bnez	a5,ffffffffc0203b20 <default_check+0x748>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02035c8:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02035ca:	00093b03          	ld	s6,0(s2)
ffffffffc02035ce:	00893a83          	ld	s5,8(s2)
ffffffffc02035d2:	0000e797          	auipc	a5,0xe
ffffffffc02035d6:	fb27b723          	sd	s2,-82(a5) # ffffffffc0211580 <free_area>
ffffffffc02035da:	0000e797          	auipc	a5,0xe
ffffffffc02035de:	fb27b723          	sd	s2,-82(a5) # ffffffffc0211588 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc02035e2:	93bfd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc02035e6:	50051d63          	bnez	a0,ffffffffc0203b00 <default_check+0x728>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02035ea:	09098a13          	addi	s4,s3,144
ffffffffc02035ee:	8552                	mv	a0,s4
ffffffffc02035f0:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02035f2:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc02035f6:	0000e797          	auipc	a5,0xe
ffffffffc02035fa:	f807ad23          	sw	zero,-102(a5) # ffffffffc0211590 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc02035fe:	9a7fd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0203602:	4511                	li	a0,4
ffffffffc0203604:	919fd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0203608:	4c051c63          	bnez	a0,ffffffffc0203ae0 <default_check+0x708>
ffffffffc020360c:	0989b783          	ld	a5,152(s3)
ffffffffc0203610:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0203612:	8b85                	andi	a5,a5,1
ffffffffc0203614:	4a078663          	beqz	a5,ffffffffc0203ac0 <default_check+0x6e8>
ffffffffc0203618:	0a89a703          	lw	a4,168(s3)
ffffffffc020361c:	478d                	li	a5,3
ffffffffc020361e:	4af71163          	bne	a4,a5,ffffffffc0203ac0 <default_check+0x6e8>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0203622:	450d                	li	a0,3
ffffffffc0203624:	8f9fd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0203628:	8c2a                	mv	s8,a0
ffffffffc020362a:	46050b63          	beqz	a0,ffffffffc0203aa0 <default_check+0x6c8>
    assert(alloc_page() == NULL);
ffffffffc020362e:	4505                	li	a0,1
ffffffffc0203630:	8edfd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0203634:	44051663          	bnez	a0,ffffffffc0203a80 <default_check+0x6a8>
    assert(p0 + 2 == p1);
ffffffffc0203638:	438a1463          	bne	s4,s8,ffffffffc0203a60 <default_check+0x688>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc020363c:	4585                	li	a1,1
ffffffffc020363e:	854e                	mv	a0,s3
ffffffffc0203640:	965fd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
    free_pages(p1, 3);
ffffffffc0203644:	458d                	li	a1,3
ffffffffc0203646:	8552                	mv	a0,s4
ffffffffc0203648:	95dfd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
ffffffffc020364c:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0203650:	04898c13          	addi	s8,s3,72
ffffffffc0203654:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0203656:	8b85                	andi	a5,a5,1
ffffffffc0203658:	3e078463          	beqz	a5,ffffffffc0203a40 <default_check+0x668>
ffffffffc020365c:	0189a703          	lw	a4,24(s3)
ffffffffc0203660:	4785                	li	a5,1
ffffffffc0203662:	3cf71f63          	bne	a4,a5,ffffffffc0203a40 <default_check+0x668>
ffffffffc0203666:	008a3783          	ld	a5,8(s4)
ffffffffc020366a:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020366c:	8b85                	andi	a5,a5,1
ffffffffc020366e:	3a078963          	beqz	a5,ffffffffc0203a20 <default_check+0x648>
ffffffffc0203672:	018a2703          	lw	a4,24(s4)
ffffffffc0203676:	478d                	li	a5,3
ffffffffc0203678:	3af71463          	bne	a4,a5,ffffffffc0203a20 <default_check+0x648>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020367c:	4505                	li	a0,1
ffffffffc020367e:	89ffd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0203682:	36a99f63          	bne	s3,a0,ffffffffc0203a00 <default_check+0x628>
    free_page(p0);
ffffffffc0203686:	4585                	li	a1,1
ffffffffc0203688:	91dfd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020368c:	4509                	li	a0,2
ffffffffc020368e:	88ffd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0203692:	34aa1763          	bne	s4,a0,ffffffffc02039e0 <default_check+0x608>

    free_pages(p0, 2);
ffffffffc0203696:	4589                	li	a1,2
ffffffffc0203698:	90dfd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
    free_page(p2);
ffffffffc020369c:	4585                	li	a1,1
ffffffffc020369e:	8562                	mv	a0,s8
ffffffffc02036a0:	905fd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02036a4:	4515                	li	a0,5
ffffffffc02036a6:	877fd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc02036aa:	89aa                	mv	s3,a0
ffffffffc02036ac:	48050a63          	beqz	a0,ffffffffc0203b40 <default_check+0x768>
    assert(alloc_page() == NULL);
ffffffffc02036b0:	4505                	li	a0,1
ffffffffc02036b2:	86bfd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc02036b6:	2e051563          	bnez	a0,ffffffffc02039a0 <default_check+0x5c8>

    assert(nr_free == 0);
ffffffffc02036ba:	01092783          	lw	a5,16(s2)
ffffffffc02036be:	2c079163          	bnez	a5,ffffffffc0203980 <default_check+0x5a8>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02036c2:	4595                	li	a1,5
ffffffffc02036c4:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02036c6:	0000e797          	auipc	a5,0xe
ffffffffc02036ca:	ed77a523          	sw	s7,-310(a5) # ffffffffc0211590 <free_area+0x10>
    free_list = free_list_store;
ffffffffc02036ce:	0000e797          	auipc	a5,0xe
ffffffffc02036d2:	eb67b923          	sd	s6,-334(a5) # ffffffffc0211580 <free_area>
ffffffffc02036d6:	0000e797          	auipc	a5,0xe
ffffffffc02036da:	eb57b923          	sd	s5,-334(a5) # ffffffffc0211588 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc02036de:	8c7fd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
    return listelm->next;
ffffffffc02036e2:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02036e6:	01278963          	beq	a5,s2,ffffffffc02036f8 <default_check+0x320>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02036ea:	ff87a703          	lw	a4,-8(a5)
ffffffffc02036ee:	679c                	ld	a5,8(a5)
ffffffffc02036f0:	34fd                	addiw	s1,s1,-1
ffffffffc02036f2:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02036f4:	ff279be3          	bne	a5,s2,ffffffffc02036ea <default_check+0x312>
    }
    assert(count == 0);
ffffffffc02036f8:	26049463          	bnez	s1,ffffffffc0203960 <default_check+0x588>
    assert(total == 0);
ffffffffc02036fc:	46041263          	bnez	s0,ffffffffc0203b60 <default_check+0x788>
}
ffffffffc0203700:	60a6                	ld	ra,72(sp)
ffffffffc0203702:	6406                	ld	s0,64(sp)
ffffffffc0203704:	74e2                	ld	s1,56(sp)
ffffffffc0203706:	7942                	ld	s2,48(sp)
ffffffffc0203708:	79a2                	ld	s3,40(sp)
ffffffffc020370a:	7a02                	ld	s4,32(sp)
ffffffffc020370c:	6ae2                	ld	s5,24(sp)
ffffffffc020370e:	6b42                	ld	s6,16(sp)
ffffffffc0203710:	6ba2                	ld	s7,8(sp)
ffffffffc0203712:	6c02                	ld	s8,0(sp)
ffffffffc0203714:	6161                	addi	sp,sp,80
ffffffffc0203716:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203718:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020371a:	4401                	li	s0,0
ffffffffc020371c:	4481                	li	s1,0
ffffffffc020371e:	b331                	j	ffffffffc020342a <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0203720:	00002697          	auipc	a3,0x2
ffffffffc0203724:	4e068693          	addi	a3,a3,1248 # ffffffffc0205c00 <commands+0x1488>
ffffffffc0203728:	00002617          	auipc	a2,0x2
ffffffffc020372c:	8c060613          	addi	a2,a2,-1856 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203730:	0f000593          	li	a1,240
ffffffffc0203734:	00003517          	auipc	a0,0x3
ffffffffc0203738:	80450513          	addi	a0,a0,-2044 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc020373c:	9cbfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0203740:	00003697          	auipc	a3,0x3
ffffffffc0203744:	87068693          	addi	a3,a3,-1936 # ffffffffc0205fb0 <commands+0x1838>
ffffffffc0203748:	00002617          	auipc	a2,0x2
ffffffffc020374c:	8a060613          	addi	a2,a2,-1888 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203750:	0bd00593          	li	a1,189
ffffffffc0203754:	00002517          	auipc	a0,0x2
ffffffffc0203758:	7e450513          	addi	a0,a0,2020 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc020375c:	9abfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0203760:	00003697          	auipc	a3,0x3
ffffffffc0203764:	87868693          	addi	a3,a3,-1928 # ffffffffc0205fd8 <commands+0x1860>
ffffffffc0203768:	00002617          	auipc	a2,0x2
ffffffffc020376c:	88060613          	addi	a2,a2,-1920 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203770:	0be00593          	li	a1,190
ffffffffc0203774:	00002517          	auipc	a0,0x2
ffffffffc0203778:	7c450513          	addi	a0,a0,1988 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc020377c:	98bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0203780:	00003697          	auipc	a3,0x3
ffffffffc0203784:	89868693          	addi	a3,a3,-1896 # ffffffffc0206018 <commands+0x18a0>
ffffffffc0203788:	00002617          	auipc	a2,0x2
ffffffffc020378c:	86060613          	addi	a2,a2,-1952 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203790:	0c000593          	li	a1,192
ffffffffc0203794:	00002517          	auipc	a0,0x2
ffffffffc0203798:	7a450513          	addi	a0,a0,1956 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc020379c:	96bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(!list_empty(&free_list));
ffffffffc02037a0:	00003697          	auipc	a3,0x3
ffffffffc02037a4:	90068693          	addi	a3,a3,-1792 # ffffffffc02060a0 <commands+0x1928>
ffffffffc02037a8:	00002617          	auipc	a2,0x2
ffffffffc02037ac:	84060613          	addi	a2,a2,-1984 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02037b0:	0d900593          	li	a1,217
ffffffffc02037b4:	00002517          	auipc	a0,0x2
ffffffffc02037b8:	78450513          	addi	a0,a0,1924 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc02037bc:	94bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02037c0:	00002697          	auipc	a3,0x2
ffffffffc02037c4:	79068693          	addi	a3,a3,1936 # ffffffffc0205f50 <commands+0x17d8>
ffffffffc02037c8:	00002617          	auipc	a2,0x2
ffffffffc02037cc:	82060613          	addi	a2,a2,-2016 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02037d0:	0d200593          	li	a1,210
ffffffffc02037d4:	00002517          	auipc	a0,0x2
ffffffffc02037d8:	76450513          	addi	a0,a0,1892 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc02037dc:	92bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free == 3);
ffffffffc02037e0:	00003697          	auipc	a3,0x3
ffffffffc02037e4:	8b068693          	addi	a3,a3,-1872 # ffffffffc0206090 <commands+0x1918>
ffffffffc02037e8:	00002617          	auipc	a2,0x2
ffffffffc02037ec:	80060613          	addi	a2,a2,-2048 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02037f0:	0d000593          	li	a1,208
ffffffffc02037f4:	00002517          	auipc	a0,0x2
ffffffffc02037f8:	74450513          	addi	a0,a0,1860 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc02037fc:	90bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203800:	00003697          	auipc	a3,0x3
ffffffffc0203804:	87868693          	addi	a3,a3,-1928 # ffffffffc0206078 <commands+0x1900>
ffffffffc0203808:	00001617          	auipc	a2,0x1
ffffffffc020380c:	7e060613          	addi	a2,a2,2016 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203810:	0cb00593          	li	a1,203
ffffffffc0203814:	00002517          	auipc	a0,0x2
ffffffffc0203818:	72450513          	addi	a0,a0,1828 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc020381c:	8ebfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0203820:	00003697          	auipc	a3,0x3
ffffffffc0203824:	83868693          	addi	a3,a3,-1992 # ffffffffc0206058 <commands+0x18e0>
ffffffffc0203828:	00001617          	auipc	a2,0x1
ffffffffc020382c:	7c060613          	addi	a2,a2,1984 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203830:	0c200593          	li	a1,194
ffffffffc0203834:	00002517          	auipc	a0,0x2
ffffffffc0203838:	70450513          	addi	a0,a0,1796 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc020383c:	8cbfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(p0 != NULL);
ffffffffc0203840:	00003697          	auipc	a3,0x3
ffffffffc0203844:	89868693          	addi	a3,a3,-1896 # ffffffffc02060d8 <commands+0x1960>
ffffffffc0203848:	00001617          	auipc	a2,0x1
ffffffffc020384c:	7a060613          	addi	a2,a2,1952 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203850:	0f800593          	li	a1,248
ffffffffc0203854:	00002517          	auipc	a0,0x2
ffffffffc0203858:	6e450513          	addi	a0,a0,1764 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc020385c:	8abfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free == 0);
ffffffffc0203860:	00002697          	auipc	a3,0x2
ffffffffc0203864:	54068693          	addi	a3,a3,1344 # ffffffffc0205da0 <commands+0x1628>
ffffffffc0203868:	00001617          	auipc	a2,0x1
ffffffffc020386c:	78060613          	addi	a2,a2,1920 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203870:	0df00593          	li	a1,223
ffffffffc0203874:	00002517          	auipc	a0,0x2
ffffffffc0203878:	6c450513          	addi	a0,a0,1732 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc020387c:	88bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203880:	00002697          	auipc	a3,0x2
ffffffffc0203884:	7f868693          	addi	a3,a3,2040 # ffffffffc0206078 <commands+0x1900>
ffffffffc0203888:	00001617          	auipc	a2,0x1
ffffffffc020388c:	76060613          	addi	a2,a2,1888 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203890:	0dd00593          	li	a1,221
ffffffffc0203894:	00002517          	auipc	a0,0x2
ffffffffc0203898:	6a450513          	addi	a0,a0,1700 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc020389c:	86bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02038a0:	00003697          	auipc	a3,0x3
ffffffffc02038a4:	81868693          	addi	a3,a3,-2024 # ffffffffc02060b8 <commands+0x1940>
ffffffffc02038a8:	00001617          	auipc	a2,0x1
ffffffffc02038ac:	74060613          	addi	a2,a2,1856 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02038b0:	0dc00593          	li	a1,220
ffffffffc02038b4:	00002517          	auipc	a0,0x2
ffffffffc02038b8:	68450513          	addi	a0,a0,1668 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc02038bc:	84bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02038c0:	00002697          	auipc	a3,0x2
ffffffffc02038c4:	69068693          	addi	a3,a3,1680 # ffffffffc0205f50 <commands+0x17d8>
ffffffffc02038c8:	00001617          	auipc	a2,0x1
ffffffffc02038cc:	72060613          	addi	a2,a2,1824 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02038d0:	0b900593          	li	a1,185
ffffffffc02038d4:	00002517          	auipc	a0,0x2
ffffffffc02038d8:	66450513          	addi	a0,a0,1636 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc02038dc:	82bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02038e0:	00002697          	auipc	a3,0x2
ffffffffc02038e4:	79868693          	addi	a3,a3,1944 # ffffffffc0206078 <commands+0x1900>
ffffffffc02038e8:	00001617          	auipc	a2,0x1
ffffffffc02038ec:	70060613          	addi	a2,a2,1792 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02038f0:	0d600593          	li	a1,214
ffffffffc02038f4:	00002517          	auipc	a0,0x2
ffffffffc02038f8:	64450513          	addi	a0,a0,1604 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc02038fc:	80bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203900:	00002697          	auipc	a3,0x2
ffffffffc0203904:	69068693          	addi	a3,a3,1680 # ffffffffc0205f90 <commands+0x1818>
ffffffffc0203908:	00001617          	auipc	a2,0x1
ffffffffc020390c:	6e060613          	addi	a2,a2,1760 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203910:	0d400593          	li	a1,212
ffffffffc0203914:	00002517          	auipc	a0,0x2
ffffffffc0203918:	62450513          	addi	a0,a0,1572 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc020391c:	feafc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203920:	00002697          	auipc	a3,0x2
ffffffffc0203924:	65068693          	addi	a3,a3,1616 # ffffffffc0205f70 <commands+0x17f8>
ffffffffc0203928:	00001617          	auipc	a2,0x1
ffffffffc020392c:	6c060613          	addi	a2,a2,1728 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203930:	0d300593          	li	a1,211
ffffffffc0203934:	00002517          	auipc	a0,0x2
ffffffffc0203938:	60450513          	addi	a0,a0,1540 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc020393c:	fcafc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203940:	00002697          	auipc	a3,0x2
ffffffffc0203944:	65068693          	addi	a3,a3,1616 # ffffffffc0205f90 <commands+0x1818>
ffffffffc0203948:	00001617          	auipc	a2,0x1
ffffffffc020394c:	6a060613          	addi	a2,a2,1696 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203950:	0bb00593          	li	a1,187
ffffffffc0203954:	00002517          	auipc	a0,0x2
ffffffffc0203958:	5e450513          	addi	a0,a0,1508 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc020395c:	faafc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(count == 0);
ffffffffc0203960:	00003697          	auipc	a3,0x3
ffffffffc0203964:	8c868693          	addi	a3,a3,-1848 # ffffffffc0206228 <commands+0x1ab0>
ffffffffc0203968:	00001617          	auipc	a2,0x1
ffffffffc020396c:	68060613          	addi	a2,a2,1664 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203970:	12500593          	li	a1,293
ffffffffc0203974:	00002517          	auipc	a0,0x2
ffffffffc0203978:	5c450513          	addi	a0,a0,1476 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc020397c:	f8afc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free == 0);
ffffffffc0203980:	00002697          	auipc	a3,0x2
ffffffffc0203984:	42068693          	addi	a3,a3,1056 # ffffffffc0205da0 <commands+0x1628>
ffffffffc0203988:	00001617          	auipc	a2,0x1
ffffffffc020398c:	66060613          	addi	a2,a2,1632 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203990:	11a00593          	li	a1,282
ffffffffc0203994:	00002517          	auipc	a0,0x2
ffffffffc0203998:	5a450513          	addi	a0,a0,1444 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc020399c:	f6afc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02039a0:	00002697          	auipc	a3,0x2
ffffffffc02039a4:	6d868693          	addi	a3,a3,1752 # ffffffffc0206078 <commands+0x1900>
ffffffffc02039a8:	00001617          	auipc	a2,0x1
ffffffffc02039ac:	64060613          	addi	a2,a2,1600 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02039b0:	11800593          	li	a1,280
ffffffffc02039b4:	00002517          	auipc	a0,0x2
ffffffffc02039b8:	58450513          	addi	a0,a0,1412 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc02039bc:	f4afc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02039c0:	00002697          	auipc	a3,0x2
ffffffffc02039c4:	67868693          	addi	a3,a3,1656 # ffffffffc0206038 <commands+0x18c0>
ffffffffc02039c8:	00001617          	auipc	a2,0x1
ffffffffc02039cc:	62060613          	addi	a2,a2,1568 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02039d0:	0c100593          	li	a1,193
ffffffffc02039d4:	00002517          	auipc	a0,0x2
ffffffffc02039d8:	56450513          	addi	a0,a0,1380 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc02039dc:	f2afc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02039e0:	00003697          	auipc	a3,0x3
ffffffffc02039e4:	80868693          	addi	a3,a3,-2040 # ffffffffc02061e8 <commands+0x1a70>
ffffffffc02039e8:	00001617          	auipc	a2,0x1
ffffffffc02039ec:	60060613          	addi	a2,a2,1536 # ffffffffc0204fe8 <commands+0x870>
ffffffffc02039f0:	11200593          	li	a1,274
ffffffffc02039f4:	00002517          	auipc	a0,0x2
ffffffffc02039f8:	54450513          	addi	a0,a0,1348 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc02039fc:	f0afc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0203a00:	00002697          	auipc	a3,0x2
ffffffffc0203a04:	7c868693          	addi	a3,a3,1992 # ffffffffc02061c8 <commands+0x1a50>
ffffffffc0203a08:	00001617          	auipc	a2,0x1
ffffffffc0203a0c:	5e060613          	addi	a2,a2,1504 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203a10:	11000593          	li	a1,272
ffffffffc0203a14:	00002517          	auipc	a0,0x2
ffffffffc0203a18:	52450513          	addi	a0,a0,1316 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc0203a1c:	eeafc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0203a20:	00002697          	auipc	a3,0x2
ffffffffc0203a24:	78068693          	addi	a3,a3,1920 # ffffffffc02061a0 <commands+0x1a28>
ffffffffc0203a28:	00001617          	auipc	a2,0x1
ffffffffc0203a2c:	5c060613          	addi	a2,a2,1472 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203a30:	10e00593          	li	a1,270
ffffffffc0203a34:	00002517          	auipc	a0,0x2
ffffffffc0203a38:	50450513          	addi	a0,a0,1284 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc0203a3c:	ecafc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0203a40:	00002697          	auipc	a3,0x2
ffffffffc0203a44:	73868693          	addi	a3,a3,1848 # ffffffffc0206178 <commands+0x1a00>
ffffffffc0203a48:	00001617          	auipc	a2,0x1
ffffffffc0203a4c:	5a060613          	addi	a2,a2,1440 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203a50:	10d00593          	li	a1,269
ffffffffc0203a54:	00002517          	auipc	a0,0x2
ffffffffc0203a58:	4e450513          	addi	a0,a0,1252 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc0203a5c:	eaafc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0203a60:	00002697          	auipc	a3,0x2
ffffffffc0203a64:	70868693          	addi	a3,a3,1800 # ffffffffc0206168 <commands+0x19f0>
ffffffffc0203a68:	00001617          	auipc	a2,0x1
ffffffffc0203a6c:	58060613          	addi	a2,a2,1408 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203a70:	10800593          	li	a1,264
ffffffffc0203a74:	00002517          	auipc	a0,0x2
ffffffffc0203a78:	4c450513          	addi	a0,a0,1220 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc0203a7c:	e8afc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203a80:	00002697          	auipc	a3,0x2
ffffffffc0203a84:	5f868693          	addi	a3,a3,1528 # ffffffffc0206078 <commands+0x1900>
ffffffffc0203a88:	00001617          	auipc	a2,0x1
ffffffffc0203a8c:	56060613          	addi	a2,a2,1376 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203a90:	10700593          	li	a1,263
ffffffffc0203a94:	00002517          	auipc	a0,0x2
ffffffffc0203a98:	4a450513          	addi	a0,a0,1188 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc0203a9c:	e6afc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0203aa0:	00002697          	auipc	a3,0x2
ffffffffc0203aa4:	6a868693          	addi	a3,a3,1704 # ffffffffc0206148 <commands+0x19d0>
ffffffffc0203aa8:	00001617          	auipc	a2,0x1
ffffffffc0203aac:	54060613          	addi	a2,a2,1344 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203ab0:	10600593          	li	a1,262
ffffffffc0203ab4:	00002517          	auipc	a0,0x2
ffffffffc0203ab8:	48450513          	addi	a0,a0,1156 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc0203abc:	e4afc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0203ac0:	00002697          	auipc	a3,0x2
ffffffffc0203ac4:	65868693          	addi	a3,a3,1624 # ffffffffc0206118 <commands+0x19a0>
ffffffffc0203ac8:	00001617          	auipc	a2,0x1
ffffffffc0203acc:	52060613          	addi	a2,a2,1312 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203ad0:	10500593          	li	a1,261
ffffffffc0203ad4:	00002517          	auipc	a0,0x2
ffffffffc0203ad8:	46450513          	addi	a0,a0,1124 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc0203adc:	e2afc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0203ae0:	00002697          	auipc	a3,0x2
ffffffffc0203ae4:	62068693          	addi	a3,a3,1568 # ffffffffc0206100 <commands+0x1988>
ffffffffc0203ae8:	00001617          	auipc	a2,0x1
ffffffffc0203aec:	50060613          	addi	a2,a2,1280 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203af0:	10400593          	li	a1,260
ffffffffc0203af4:	00002517          	auipc	a0,0x2
ffffffffc0203af8:	44450513          	addi	a0,a0,1092 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc0203afc:	e0afc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203b00:	00002697          	auipc	a3,0x2
ffffffffc0203b04:	57868693          	addi	a3,a3,1400 # ffffffffc0206078 <commands+0x1900>
ffffffffc0203b08:	00001617          	auipc	a2,0x1
ffffffffc0203b0c:	4e060613          	addi	a2,a2,1248 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203b10:	0fe00593          	li	a1,254
ffffffffc0203b14:	00002517          	auipc	a0,0x2
ffffffffc0203b18:	42450513          	addi	a0,a0,1060 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc0203b1c:	deafc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(!PageProperty(p0));
ffffffffc0203b20:	00002697          	auipc	a3,0x2
ffffffffc0203b24:	5c868693          	addi	a3,a3,1480 # ffffffffc02060e8 <commands+0x1970>
ffffffffc0203b28:	00001617          	auipc	a2,0x1
ffffffffc0203b2c:	4c060613          	addi	a2,a2,1216 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203b30:	0f900593          	li	a1,249
ffffffffc0203b34:	00002517          	auipc	a0,0x2
ffffffffc0203b38:	40450513          	addi	a0,a0,1028 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc0203b3c:	dcafc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0203b40:	00002697          	auipc	a3,0x2
ffffffffc0203b44:	6c868693          	addi	a3,a3,1736 # ffffffffc0206208 <commands+0x1a90>
ffffffffc0203b48:	00001617          	auipc	a2,0x1
ffffffffc0203b4c:	4a060613          	addi	a2,a2,1184 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203b50:	11700593          	li	a1,279
ffffffffc0203b54:	00002517          	auipc	a0,0x2
ffffffffc0203b58:	3e450513          	addi	a0,a0,996 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc0203b5c:	daafc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(total == 0);
ffffffffc0203b60:	00002697          	auipc	a3,0x2
ffffffffc0203b64:	6d868693          	addi	a3,a3,1752 # ffffffffc0206238 <commands+0x1ac0>
ffffffffc0203b68:	00001617          	auipc	a2,0x1
ffffffffc0203b6c:	48060613          	addi	a2,a2,1152 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203b70:	12600593          	li	a1,294
ffffffffc0203b74:	00002517          	auipc	a0,0x2
ffffffffc0203b78:	3c450513          	addi	a0,a0,964 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc0203b7c:	d8afc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(total == nr_free_pages());
ffffffffc0203b80:	00002697          	auipc	a3,0x2
ffffffffc0203b84:	09068693          	addi	a3,a3,144 # ffffffffc0205c10 <commands+0x1498>
ffffffffc0203b88:	00001617          	auipc	a2,0x1
ffffffffc0203b8c:	46060613          	addi	a2,a2,1120 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203b90:	0f300593          	li	a1,243
ffffffffc0203b94:	00002517          	auipc	a0,0x2
ffffffffc0203b98:	3a450513          	addi	a0,a0,932 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc0203b9c:	d6afc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203ba0:	00002697          	auipc	a3,0x2
ffffffffc0203ba4:	3d068693          	addi	a3,a3,976 # ffffffffc0205f70 <commands+0x17f8>
ffffffffc0203ba8:	00001617          	auipc	a2,0x1
ffffffffc0203bac:	44060613          	addi	a2,a2,1088 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203bb0:	0ba00593          	li	a1,186
ffffffffc0203bb4:	00002517          	auipc	a0,0x2
ffffffffc0203bb8:	38450513          	addi	a0,a0,900 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc0203bbc:	d4afc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203bc0 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0203bc0:	1141                	addi	sp,sp,-16
ffffffffc0203bc2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203bc4:	18058063          	beqz	a1,ffffffffc0203d44 <default_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc0203bc8:	00359693          	slli	a3,a1,0x3
ffffffffc0203bcc:	96ae                	add	a3,a3,a1
ffffffffc0203bce:	068e                	slli	a3,a3,0x3
ffffffffc0203bd0:	96aa                	add	a3,a3,a0
ffffffffc0203bd2:	02d50d63          	beq	a0,a3,ffffffffc0203c0c <default_free_pages+0x4c>
ffffffffc0203bd6:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203bd8:	8b85                	andi	a5,a5,1
ffffffffc0203bda:	14079563          	bnez	a5,ffffffffc0203d24 <default_free_pages+0x164>
ffffffffc0203bde:	651c                	ld	a5,8(a0)
ffffffffc0203be0:	8385                	srli	a5,a5,0x1
ffffffffc0203be2:	8b85                	andi	a5,a5,1
ffffffffc0203be4:	14079063          	bnez	a5,ffffffffc0203d24 <default_free_pages+0x164>
ffffffffc0203be8:	87aa                	mv	a5,a0
ffffffffc0203bea:	a809                	j	ffffffffc0203bfc <default_free_pages+0x3c>
ffffffffc0203bec:	6798                	ld	a4,8(a5)
ffffffffc0203bee:	8b05                	andi	a4,a4,1
ffffffffc0203bf0:	12071a63          	bnez	a4,ffffffffc0203d24 <default_free_pages+0x164>
ffffffffc0203bf4:	6798                	ld	a4,8(a5)
ffffffffc0203bf6:	8b09                	andi	a4,a4,2
ffffffffc0203bf8:	12071663          	bnez	a4,ffffffffc0203d24 <default_free_pages+0x164>
        p->flags = 0;
ffffffffc0203bfc:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0203c00:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0203c04:	04878793          	addi	a5,a5,72
ffffffffc0203c08:	fed792e3          	bne	a5,a3,ffffffffc0203bec <default_free_pages+0x2c>
    base->property = n;
ffffffffc0203c0c:	2581                	sext.w	a1,a1
ffffffffc0203c0e:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc0203c10:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203c14:	4789                	li	a5,2
ffffffffc0203c16:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0203c1a:	0000e697          	auipc	a3,0xe
ffffffffc0203c1e:	96668693          	addi	a3,a3,-1690 # ffffffffc0211580 <free_area>
ffffffffc0203c22:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0203c24:	669c                	ld	a5,8(a3)
ffffffffc0203c26:	9db9                	addw	a1,a1,a4
ffffffffc0203c28:	0000e717          	auipc	a4,0xe
ffffffffc0203c2c:	96b72423          	sw	a1,-1688(a4) # ffffffffc0211590 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0203c30:	08d78f63          	beq	a5,a3,ffffffffc0203cce <default_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc0203c34:	fe078713          	addi	a4,a5,-32
ffffffffc0203c38:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0203c3a:	4801                	li	a6,0
ffffffffc0203c3c:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0203c40:	00e56a63          	bltu	a0,a4,ffffffffc0203c54 <default_free_pages+0x94>
    return listelm->next;
ffffffffc0203c44:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203c46:	02d70563          	beq	a4,a3,ffffffffc0203c70 <default_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203c4a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0203c4c:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0203c50:	fee57ae3          	bleu	a4,a0,ffffffffc0203c44 <default_free_pages+0x84>
ffffffffc0203c54:	00080663          	beqz	a6,ffffffffc0203c60 <default_free_pages+0xa0>
ffffffffc0203c58:	0000e817          	auipc	a6,0xe
ffffffffc0203c5c:	92b83423          	sd	a1,-1752(a6) # ffffffffc0211580 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203c60:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203c62:	e390                	sd	a2,0(a5)
ffffffffc0203c64:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc0203c66:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0203c68:	f10c                	sd	a1,32(a0)
    if (le != &free_list) {
ffffffffc0203c6a:	02d59163          	bne	a1,a3,ffffffffc0203c8c <default_free_pages+0xcc>
ffffffffc0203c6e:	a091                	j	ffffffffc0203cb2 <default_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc0203c70:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203c72:	f514                	sd	a3,40(a0)
ffffffffc0203c74:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203c76:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc0203c78:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203c7a:	00d70563          	beq	a4,a3,ffffffffc0203c84 <default_free_pages+0xc4>
ffffffffc0203c7e:	4805                	li	a6,1
ffffffffc0203c80:	87ba                	mv	a5,a4
ffffffffc0203c82:	b7e9                	j	ffffffffc0203c4c <default_free_pages+0x8c>
ffffffffc0203c84:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0203c86:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0203c88:	02d78163          	beq	a5,a3,ffffffffc0203caa <default_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc0203c8c:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc0203c90:	fe058613          	addi	a2,a1,-32
        if (p + p->property == base) {
ffffffffc0203c94:	02081713          	slli	a4,a6,0x20
ffffffffc0203c98:	9301                	srli	a4,a4,0x20
ffffffffc0203c9a:	00371793          	slli	a5,a4,0x3
ffffffffc0203c9e:	97ba                	add	a5,a5,a4
ffffffffc0203ca0:	078e                	slli	a5,a5,0x3
ffffffffc0203ca2:	97b2                	add	a5,a5,a2
ffffffffc0203ca4:	02f50e63          	beq	a0,a5,ffffffffc0203ce0 <default_free_pages+0x120>
ffffffffc0203ca8:	751c                	ld	a5,40(a0)
    if (le != &free_list) {
ffffffffc0203caa:	fe078713          	addi	a4,a5,-32
ffffffffc0203cae:	00d78d63          	beq	a5,a3,ffffffffc0203cc8 <default_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc0203cb2:	4d0c                	lw	a1,24(a0)
ffffffffc0203cb4:	02059613          	slli	a2,a1,0x20
ffffffffc0203cb8:	9201                	srli	a2,a2,0x20
ffffffffc0203cba:	00361693          	slli	a3,a2,0x3
ffffffffc0203cbe:	96b2                	add	a3,a3,a2
ffffffffc0203cc0:	068e                	slli	a3,a3,0x3
ffffffffc0203cc2:	96aa                	add	a3,a3,a0
ffffffffc0203cc4:	04d70063          	beq	a4,a3,ffffffffc0203d04 <default_free_pages+0x144>
}
ffffffffc0203cc8:	60a2                	ld	ra,8(sp)
ffffffffc0203cca:	0141                	addi	sp,sp,16
ffffffffc0203ccc:	8082                	ret
ffffffffc0203cce:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0203cd0:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc0203cd4:	e398                	sd	a4,0(a5)
ffffffffc0203cd6:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0203cd8:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0203cda:	f11c                	sd	a5,32(a0)
}
ffffffffc0203cdc:	0141                	addi	sp,sp,16
ffffffffc0203cde:	8082                	ret
            p->property += base->property;
ffffffffc0203ce0:	4d1c                	lw	a5,24(a0)
ffffffffc0203ce2:	0107883b          	addw	a6,a5,a6
ffffffffc0203ce6:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203cea:	57f5                	li	a5,-3
ffffffffc0203cec:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203cf0:	02053803          	ld	a6,32(a0)
ffffffffc0203cf4:	7518                	ld	a4,40(a0)
            base = p;
ffffffffc0203cf6:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc0203cf8:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc0203cfc:	659c                	ld	a5,8(a1)
ffffffffc0203cfe:	01073023          	sd	a6,0(a4)
ffffffffc0203d02:	b765                	j	ffffffffc0203caa <default_free_pages+0xea>
            base->property += p->property;
ffffffffc0203d04:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203d08:	fe878693          	addi	a3,a5,-24
ffffffffc0203d0c:	9db9                	addw	a1,a1,a4
ffffffffc0203d0e:	cd0c                	sw	a1,24(a0)
ffffffffc0203d10:	5775                	li	a4,-3
ffffffffc0203d12:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203d16:	6398                	ld	a4,0(a5)
ffffffffc0203d18:	679c                	ld	a5,8(a5)
}
ffffffffc0203d1a:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0203d1c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203d1e:	e398                	sd	a4,0(a5)
ffffffffc0203d20:	0141                	addi	sp,sp,16
ffffffffc0203d22:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203d24:	00002697          	auipc	a3,0x2
ffffffffc0203d28:	52468693          	addi	a3,a3,1316 # ffffffffc0206248 <commands+0x1ad0>
ffffffffc0203d2c:	00001617          	auipc	a2,0x1
ffffffffc0203d30:	2bc60613          	addi	a2,a2,700 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203d34:	08300593          	li	a1,131
ffffffffc0203d38:	00002517          	auipc	a0,0x2
ffffffffc0203d3c:	20050513          	addi	a0,a0,512 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc0203d40:	bc6fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(n > 0);
ffffffffc0203d44:	00002697          	auipc	a3,0x2
ffffffffc0203d48:	52c68693          	addi	a3,a3,1324 # ffffffffc0206270 <commands+0x1af8>
ffffffffc0203d4c:	00001617          	auipc	a2,0x1
ffffffffc0203d50:	29c60613          	addi	a2,a2,668 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203d54:	08000593          	li	a1,128
ffffffffc0203d58:	00002517          	auipc	a0,0x2
ffffffffc0203d5c:	1e050513          	addi	a0,a0,480 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc0203d60:	ba6fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203d64 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0203d64:	cd51                	beqz	a0,ffffffffc0203e00 <default_alloc_pages+0x9c>
    if (n > nr_free) {
ffffffffc0203d66:	0000e597          	auipc	a1,0xe
ffffffffc0203d6a:	81a58593          	addi	a1,a1,-2022 # ffffffffc0211580 <free_area>
ffffffffc0203d6e:	0105a803          	lw	a6,16(a1)
ffffffffc0203d72:	862a                	mv	a2,a0
ffffffffc0203d74:	02081793          	slli	a5,a6,0x20
ffffffffc0203d78:	9381                	srli	a5,a5,0x20
ffffffffc0203d7a:	00a7ee63          	bltu	a5,a0,ffffffffc0203d96 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0203d7e:	87ae                	mv	a5,a1
ffffffffc0203d80:	a801                	j	ffffffffc0203d90 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0203d82:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203d86:	02071693          	slli	a3,a4,0x20
ffffffffc0203d8a:	9281                	srli	a3,a3,0x20
ffffffffc0203d8c:	00c6f763          	bleu	a2,a3,ffffffffc0203d9a <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0203d90:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203d92:	feb798e3          	bne	a5,a1,ffffffffc0203d82 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0203d96:	4501                	li	a0,0
}
ffffffffc0203d98:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc0203d9a:	fe078513          	addi	a0,a5,-32
    if (page != NULL) {
ffffffffc0203d9e:	dd6d                	beqz	a0,ffffffffc0203d98 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0203da0:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203da4:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0203da8:	00060e1b          	sext.w	t3,a2
ffffffffc0203dac:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0203db0:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0203db4:	02d67b63          	bleu	a3,a2,ffffffffc0203dea <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc0203db8:	00361693          	slli	a3,a2,0x3
ffffffffc0203dbc:	96b2                	add	a3,a3,a2
ffffffffc0203dbe:	068e                	slli	a3,a3,0x3
ffffffffc0203dc0:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0203dc2:	41c7073b          	subw	a4,a4,t3
ffffffffc0203dc6:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203dc8:	00868613          	addi	a2,a3,8
ffffffffc0203dcc:	4709                	li	a4,2
ffffffffc0203dce:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0203dd2:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0203dd6:	02068613          	addi	a2,a3,32
    prev->next = next->prev = elm;
ffffffffc0203dda:	0105a803          	lw	a6,16(a1)
ffffffffc0203dde:	e310                	sd	a2,0(a4)
ffffffffc0203de0:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0203de4:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc0203de6:	0316b023          	sd	a7,32(a3)
        nr_free -= n;
ffffffffc0203dea:	41c8083b          	subw	a6,a6,t3
ffffffffc0203dee:	0000d717          	auipc	a4,0xd
ffffffffc0203df2:	7b072123          	sw	a6,1954(a4) # ffffffffc0211590 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203df6:	5775                	li	a4,-3
ffffffffc0203df8:	17a1                	addi	a5,a5,-24
ffffffffc0203dfa:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0203dfe:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0203e00:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0203e02:	00002697          	auipc	a3,0x2
ffffffffc0203e06:	46e68693          	addi	a3,a3,1134 # ffffffffc0206270 <commands+0x1af8>
ffffffffc0203e0a:	00001617          	auipc	a2,0x1
ffffffffc0203e0e:	1de60613          	addi	a2,a2,478 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203e12:	06200593          	li	a1,98
ffffffffc0203e16:	00002517          	auipc	a0,0x2
ffffffffc0203e1a:	12250513          	addi	a0,a0,290 # ffffffffc0205f38 <commands+0x17c0>
default_alloc_pages(size_t n) {
ffffffffc0203e1e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203e20:	ae6fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203e24 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0203e24:	1141                	addi	sp,sp,-16
ffffffffc0203e26:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203e28:	c1fd                	beqz	a1,ffffffffc0203f0e <default_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc0203e2a:	00359693          	slli	a3,a1,0x3
ffffffffc0203e2e:	96ae                	add	a3,a3,a1
ffffffffc0203e30:	068e                	slli	a3,a3,0x3
ffffffffc0203e32:	96aa                	add	a3,a3,a0
ffffffffc0203e34:	02d50463          	beq	a0,a3,ffffffffc0203e5c <default_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0203e38:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0203e3a:	87aa                	mv	a5,a0
ffffffffc0203e3c:	8b05                	andi	a4,a4,1
ffffffffc0203e3e:	e709                	bnez	a4,ffffffffc0203e48 <default_init_memmap+0x24>
ffffffffc0203e40:	a07d                	j	ffffffffc0203eee <default_init_memmap+0xca>
ffffffffc0203e42:	6798                	ld	a4,8(a5)
ffffffffc0203e44:	8b05                	andi	a4,a4,1
ffffffffc0203e46:	c745                	beqz	a4,ffffffffc0203eee <default_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc0203e48:	0007ac23          	sw	zero,24(a5)
ffffffffc0203e4c:	0007b423          	sd	zero,8(a5)
ffffffffc0203e50:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0203e54:	04878793          	addi	a5,a5,72
ffffffffc0203e58:	fed795e3          	bne	a5,a3,ffffffffc0203e42 <default_init_memmap+0x1e>
    base->property = n;
ffffffffc0203e5c:	2581                	sext.w	a1,a1
ffffffffc0203e5e:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203e60:	4789                	li	a5,2
ffffffffc0203e62:	00850713          	addi	a4,a0,8
ffffffffc0203e66:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0203e6a:	0000d697          	auipc	a3,0xd
ffffffffc0203e6e:	71668693          	addi	a3,a3,1814 # ffffffffc0211580 <free_area>
ffffffffc0203e72:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0203e74:	669c                	ld	a5,8(a3)
ffffffffc0203e76:	9db9                	addw	a1,a1,a4
ffffffffc0203e78:	0000d717          	auipc	a4,0xd
ffffffffc0203e7c:	70b72c23          	sw	a1,1816(a4) # ffffffffc0211590 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0203e80:	04d78a63          	beq	a5,a3,ffffffffc0203ed4 <default_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc0203e84:	fe078713          	addi	a4,a5,-32
ffffffffc0203e88:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0203e8a:	4801                	li	a6,0
ffffffffc0203e8c:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0203e90:	00e56a63          	bltu	a0,a4,ffffffffc0203ea4 <default_init_memmap+0x80>
    return listelm->next;
ffffffffc0203e94:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203e96:	02d70563          	beq	a4,a3,ffffffffc0203ec0 <default_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203e9a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0203e9c:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0203ea0:	fee57ae3          	bleu	a4,a0,ffffffffc0203e94 <default_init_memmap+0x70>
ffffffffc0203ea4:	00080663          	beqz	a6,ffffffffc0203eb0 <default_init_memmap+0x8c>
ffffffffc0203ea8:	0000d717          	auipc	a4,0xd
ffffffffc0203eac:	6cb73c23          	sd	a1,1752(a4) # ffffffffc0211580 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203eb0:	6398                	ld	a4,0(a5)
}
ffffffffc0203eb2:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0203eb4:	e390                	sd	a2,0(a5)
ffffffffc0203eb6:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0203eb8:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0203eba:	f118                	sd	a4,32(a0)
ffffffffc0203ebc:	0141                	addi	sp,sp,16
ffffffffc0203ebe:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0203ec0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203ec2:	f514                	sd	a3,40(a0)
ffffffffc0203ec4:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203ec6:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc0203ec8:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203eca:	00d70e63          	beq	a4,a3,ffffffffc0203ee6 <default_init_memmap+0xc2>
ffffffffc0203ece:	4805                	li	a6,1
ffffffffc0203ed0:	87ba                	mv	a5,a4
ffffffffc0203ed2:	b7e9                	j	ffffffffc0203e9c <default_init_memmap+0x78>
}
ffffffffc0203ed4:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0203ed6:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc0203eda:	e398                	sd	a4,0(a5)
ffffffffc0203edc:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0203ede:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0203ee0:	f11c                	sd	a5,32(a0)
}
ffffffffc0203ee2:	0141                	addi	sp,sp,16
ffffffffc0203ee4:	8082                	ret
ffffffffc0203ee6:	60a2                	ld	ra,8(sp)
ffffffffc0203ee8:	e290                	sd	a2,0(a3)
ffffffffc0203eea:	0141                	addi	sp,sp,16
ffffffffc0203eec:	8082                	ret
        assert(PageReserved(p));
ffffffffc0203eee:	00002697          	auipc	a3,0x2
ffffffffc0203ef2:	38a68693          	addi	a3,a3,906 # ffffffffc0206278 <commands+0x1b00>
ffffffffc0203ef6:	00001617          	auipc	a2,0x1
ffffffffc0203efa:	0f260613          	addi	a2,a2,242 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203efe:	04900593          	li	a1,73
ffffffffc0203f02:	00002517          	auipc	a0,0x2
ffffffffc0203f06:	03650513          	addi	a0,a0,54 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc0203f0a:	9fcfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(n > 0);
ffffffffc0203f0e:	00002697          	auipc	a3,0x2
ffffffffc0203f12:	36268693          	addi	a3,a3,866 # ffffffffc0206270 <commands+0x1af8>
ffffffffc0203f16:	00001617          	auipc	a2,0x1
ffffffffc0203f1a:	0d260613          	addi	a2,a2,210 # ffffffffc0204fe8 <commands+0x870>
ffffffffc0203f1e:	04600593          	li	a1,70
ffffffffc0203f22:	00002517          	auipc	a0,0x2
ffffffffc0203f26:	01650513          	addi	a0,a0,22 # ffffffffc0205f38 <commands+0x17c0>
ffffffffc0203f2a:	9dcfc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203f2e <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203f2e:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203f30:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203f32:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203f34:	ca2fc0ef          	jal	ra,ffffffffc02003d6 <ide_device_valid>
ffffffffc0203f38:	cd01                	beqz	a0,ffffffffc0203f50 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203f3a:	4505                	li	a0,1
ffffffffc0203f3c:	ca0fc0ef          	jal	ra,ffffffffc02003dc <ide_device_size>

    //使用static_assert进行断言检查，确保页的大小能够整除扇区的大小。
    //检查交换分区设备是否有效，如果无效则调用panic函数触发内核崩溃。

    
}
ffffffffc0203f40:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203f42:	810d                	srli	a0,a0,0x3
ffffffffc0203f44:	0000d797          	auipc	a5,0xd
ffffffffc0203f48:	5ea7be23          	sd	a0,1532(a5) # ffffffffc0211540 <max_swap_offset>
}
ffffffffc0203f4c:	0141                	addi	sp,sp,16
ffffffffc0203f4e:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203f50:	00002617          	auipc	a2,0x2
ffffffffc0203f54:	38860613          	addi	a2,a2,904 # ffffffffc02062d8 <default_pmm_manager+0x50>
ffffffffc0203f58:	45b5                	li	a1,13
ffffffffc0203f5a:	00002517          	auipc	a0,0x2
ffffffffc0203f5e:	39e50513          	addi	a0,a0,926 # ffffffffc02062f8 <default_pmm_manager+0x70>
ffffffffc0203f62:	9a4fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203f66 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203f66:	1141                	addi	sp,sp,-16
ffffffffc0203f68:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f6a:	00855793          	srli	a5,a0,0x8
ffffffffc0203f6e:	c7b5                	beqz	a5,ffffffffc0203fda <swapfs_read+0x74>
ffffffffc0203f70:	0000d717          	auipc	a4,0xd
ffffffffc0203f74:	5d070713          	addi	a4,a4,1488 # ffffffffc0211540 <max_swap_offset>
ffffffffc0203f78:	6318                	ld	a4,0(a4)
ffffffffc0203f7a:	06e7f063          	bleu	a4,a5,ffffffffc0203fda <swapfs_read+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203f7e:	0000d717          	auipc	a4,0xd
ffffffffc0203f82:	52a70713          	addi	a4,a4,1322 # ffffffffc02114a8 <pages>
ffffffffc0203f86:	6310                	ld	a2,0(a4)
ffffffffc0203f88:	00001717          	auipc	a4,0x1
ffffffffc0203f8c:	23070713          	addi	a4,a4,560 # ffffffffc02051b8 <commands+0xa40>
ffffffffc0203f90:	00002697          	auipc	a3,0x2
ffffffffc0203f94:	5e868693          	addi	a3,a3,1512 # ffffffffc0206578 <nbase>
ffffffffc0203f98:	40c58633          	sub	a2,a1,a2
ffffffffc0203f9c:	630c                	ld	a1,0(a4)
ffffffffc0203f9e:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203fa0:	0000d717          	auipc	a4,0xd
ffffffffc0203fa4:	4b870713          	addi	a4,a4,1208 # ffffffffc0211458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203fa8:	02b60633          	mul	a2,a2,a1
ffffffffc0203fac:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203fb0:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203fb2:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203fb4:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203fb6:	57fd                	li	a5,-1
ffffffffc0203fb8:	83b1                	srli	a5,a5,0xc
ffffffffc0203fba:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203fbc:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203fbe:	02e7fa63          	bleu	a4,a5,ffffffffc0203ff2 <swapfs_read+0x8c>
ffffffffc0203fc2:	0000d797          	auipc	a5,0xd
ffffffffc0203fc6:	4d678793          	addi	a5,a5,1238 # ffffffffc0211498 <va_pa_offset>
ffffffffc0203fca:	639c                	ld	a5,0(a5)
}
ffffffffc0203fcc:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203fce:	46a1                	li	a3,8
ffffffffc0203fd0:	963e                	add	a2,a2,a5
ffffffffc0203fd2:	4505                	li	a0,1
}
ffffffffc0203fd4:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203fd6:	c0cfc06f          	j	ffffffffc02003e2 <ide_read_secs>
ffffffffc0203fda:	86aa                	mv	a3,a0
ffffffffc0203fdc:	00002617          	auipc	a2,0x2
ffffffffc0203fe0:	33460613          	addi	a2,a2,820 # ffffffffc0206310 <default_pmm_manager+0x88>
ffffffffc0203fe4:	45e5                	li	a1,25
ffffffffc0203fe6:	00002517          	auipc	a0,0x2
ffffffffc0203fea:	31250513          	addi	a0,a0,786 # ffffffffc02062f8 <default_pmm_manager+0x70>
ffffffffc0203fee:	918fc0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0203ff2:	86b2                	mv	a3,a2
ffffffffc0203ff4:	06a00593          	li	a1,106
ffffffffc0203ff8:	00001617          	auipc	a2,0x1
ffffffffc0203ffc:	1c860613          	addi	a2,a2,456 # ffffffffc02051c0 <commands+0xa48>
ffffffffc0204000:	00001517          	auipc	a0,0x1
ffffffffc0204004:	25850513          	addi	a0,a0,600 # ffffffffc0205258 <commands+0xae0>
ffffffffc0204008:	8fefc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc020400c <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc020400c:	1141                	addi	sp,sp,-16
ffffffffc020400e:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204010:	00855793          	srli	a5,a0,0x8
ffffffffc0204014:	c7b5                	beqz	a5,ffffffffc0204080 <swapfs_write+0x74>
ffffffffc0204016:	0000d717          	auipc	a4,0xd
ffffffffc020401a:	52a70713          	addi	a4,a4,1322 # ffffffffc0211540 <max_swap_offset>
ffffffffc020401e:	6318                	ld	a4,0(a4)
ffffffffc0204020:	06e7f063          	bleu	a4,a5,ffffffffc0204080 <swapfs_write+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0204024:	0000d717          	auipc	a4,0xd
ffffffffc0204028:	48470713          	addi	a4,a4,1156 # ffffffffc02114a8 <pages>
ffffffffc020402c:	6310                	ld	a2,0(a4)
ffffffffc020402e:	00001717          	auipc	a4,0x1
ffffffffc0204032:	18a70713          	addi	a4,a4,394 # ffffffffc02051b8 <commands+0xa40>
ffffffffc0204036:	00002697          	auipc	a3,0x2
ffffffffc020403a:	54268693          	addi	a3,a3,1346 # ffffffffc0206578 <nbase>
ffffffffc020403e:	40c58633          	sub	a2,a1,a2
ffffffffc0204042:	630c                	ld	a1,0(a4)
ffffffffc0204044:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0204046:	0000d717          	auipc	a4,0xd
ffffffffc020404a:	41270713          	addi	a4,a4,1042 # ffffffffc0211458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020404e:	02b60633          	mul	a2,a2,a1
ffffffffc0204052:	0037959b          	slliw	a1,a5,0x3
ffffffffc0204056:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0204058:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020405a:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020405c:	57fd                	li	a5,-1
ffffffffc020405e:	83b1                	srli	a5,a5,0xc
ffffffffc0204060:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0204062:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0204064:	02e7fa63          	bleu	a4,a5,ffffffffc0204098 <swapfs_write+0x8c>
ffffffffc0204068:	0000d797          	auipc	a5,0xd
ffffffffc020406c:	43078793          	addi	a5,a5,1072 # ffffffffc0211498 <va_pa_offset>
ffffffffc0204070:	639c                	ld	a5,0(a5)
}
ffffffffc0204072:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204074:	46a1                	li	a3,8
ffffffffc0204076:	963e                	add	a2,a2,a5
ffffffffc0204078:	4505                	li	a0,1
}
ffffffffc020407a:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020407c:	b8afc06f          	j	ffffffffc0200406 <ide_write_secs>
ffffffffc0204080:	86aa                	mv	a3,a0
ffffffffc0204082:	00002617          	auipc	a2,0x2
ffffffffc0204086:	28e60613          	addi	a2,a2,654 # ffffffffc0206310 <default_pmm_manager+0x88>
ffffffffc020408a:	45f9                	li	a1,30
ffffffffc020408c:	00002517          	auipc	a0,0x2
ffffffffc0204090:	26c50513          	addi	a0,a0,620 # ffffffffc02062f8 <default_pmm_manager+0x70>
ffffffffc0204094:	872fc0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0204098:	86b2                	mv	a3,a2
ffffffffc020409a:	06a00593          	li	a1,106
ffffffffc020409e:	00001617          	auipc	a2,0x1
ffffffffc02040a2:	12260613          	addi	a2,a2,290 # ffffffffc02051c0 <commands+0xa48>
ffffffffc02040a6:	00001517          	auipc	a0,0x1
ffffffffc02040aa:	1b250513          	addi	a0,a0,434 # ffffffffc0205258 <commands+0xae0>
ffffffffc02040ae:	858fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02040b2 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02040b2:	00054783          	lbu	a5,0(a0)
ffffffffc02040b6:	cb91                	beqz	a5,ffffffffc02040ca <strlen+0x18>
    size_t cnt = 0;
ffffffffc02040b8:	4781                	li	a5,0
        cnt ++;
ffffffffc02040ba:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc02040bc:	00f50733          	add	a4,a0,a5
ffffffffc02040c0:	00074703          	lbu	a4,0(a4)
ffffffffc02040c4:	fb7d                	bnez	a4,ffffffffc02040ba <strlen+0x8>
    }
    return cnt;
}
ffffffffc02040c6:	853e                	mv	a0,a5
ffffffffc02040c8:	8082                	ret
    size_t cnt = 0;
ffffffffc02040ca:	4781                	li	a5,0
}
ffffffffc02040cc:	853e                	mv	a0,a5
ffffffffc02040ce:	8082                	ret

ffffffffc02040d0 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc02040d0:	c185                	beqz	a1,ffffffffc02040f0 <strnlen+0x20>
ffffffffc02040d2:	00054783          	lbu	a5,0(a0)
ffffffffc02040d6:	cf89                	beqz	a5,ffffffffc02040f0 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc02040d8:	4781                	li	a5,0
ffffffffc02040da:	a021                	j	ffffffffc02040e2 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02040dc:	00074703          	lbu	a4,0(a4)
ffffffffc02040e0:	c711                	beqz	a4,ffffffffc02040ec <strnlen+0x1c>
        cnt ++;
ffffffffc02040e2:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02040e4:	00f50733          	add	a4,a0,a5
ffffffffc02040e8:	fef59ae3          	bne	a1,a5,ffffffffc02040dc <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02040ec:	853e                	mv	a0,a5
ffffffffc02040ee:	8082                	ret
    size_t cnt = 0;
ffffffffc02040f0:	4781                	li	a5,0
}
ffffffffc02040f2:	853e                	mv	a0,a5
ffffffffc02040f4:	8082                	ret

ffffffffc02040f6 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02040f6:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02040f8:	0585                	addi	a1,a1,1
ffffffffc02040fa:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02040fe:	0785                	addi	a5,a5,1
ffffffffc0204100:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204104:	fb75                	bnez	a4,ffffffffc02040f8 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204106:	8082                	ret

ffffffffc0204108 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204108:	00054783          	lbu	a5,0(a0)
ffffffffc020410c:	0005c703          	lbu	a4,0(a1)
ffffffffc0204110:	cb91                	beqz	a5,ffffffffc0204124 <strcmp+0x1c>
ffffffffc0204112:	00e79c63          	bne	a5,a4,ffffffffc020412a <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0204116:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204118:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc020411c:	0585                	addi	a1,a1,1
ffffffffc020411e:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204122:	fbe5                	bnez	a5,ffffffffc0204112 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204124:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204126:	9d19                	subw	a0,a0,a4
ffffffffc0204128:	8082                	ret
ffffffffc020412a:	0007851b          	sext.w	a0,a5
ffffffffc020412e:	9d19                	subw	a0,a0,a4
ffffffffc0204130:	8082                	ret

ffffffffc0204132 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204132:	00054783          	lbu	a5,0(a0)
ffffffffc0204136:	cb91                	beqz	a5,ffffffffc020414a <strchr+0x18>
        if (*s == c) {
ffffffffc0204138:	00b79563          	bne	a5,a1,ffffffffc0204142 <strchr+0x10>
ffffffffc020413c:	a809                	j	ffffffffc020414e <strchr+0x1c>
ffffffffc020413e:	00b78763          	beq	a5,a1,ffffffffc020414c <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0204142:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204144:	00054783          	lbu	a5,0(a0)
ffffffffc0204148:	fbfd                	bnez	a5,ffffffffc020413e <strchr+0xc>
    }
    return NULL;
ffffffffc020414a:	4501                	li	a0,0
}
ffffffffc020414c:	8082                	ret
ffffffffc020414e:	8082                	ret

ffffffffc0204150 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204150:	ca01                	beqz	a2,ffffffffc0204160 <memset+0x10>
ffffffffc0204152:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204154:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204156:	0785                	addi	a5,a5,1
ffffffffc0204158:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020415c:	fec79de3          	bne	a5,a2,ffffffffc0204156 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204160:	8082                	ret

ffffffffc0204162 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204162:	ca19                	beqz	a2,ffffffffc0204178 <memcpy+0x16>
ffffffffc0204164:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204166:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204168:	0585                	addi	a1,a1,1
ffffffffc020416a:	fff5c703          	lbu	a4,-1(a1)
ffffffffc020416e:	0785                	addi	a5,a5,1
ffffffffc0204170:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204174:	fec59ae3          	bne	a1,a2,ffffffffc0204168 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204178:	8082                	ret

ffffffffc020417a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020417a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020417e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0204180:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204184:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0204186:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020418a:	f022                	sd	s0,32(sp)
ffffffffc020418c:	ec26                	sd	s1,24(sp)
ffffffffc020418e:	e84a                	sd	s2,16(sp)
ffffffffc0204190:	f406                	sd	ra,40(sp)
ffffffffc0204192:	e44e                	sd	s3,8(sp)
ffffffffc0204194:	84aa                	mv	s1,a0
ffffffffc0204196:	892e                	mv	s2,a1
ffffffffc0204198:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020419c:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc020419e:	03067e63          	bleu	a6,a2,ffffffffc02041da <printnum+0x60>
ffffffffc02041a2:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02041a4:	00805763          	blez	s0,ffffffffc02041b2 <printnum+0x38>
ffffffffc02041a8:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02041aa:	85ca                	mv	a1,s2
ffffffffc02041ac:	854e                	mv	a0,s3
ffffffffc02041ae:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02041b0:	fc65                	bnez	s0,ffffffffc02041a8 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02041b2:	1a02                	slli	s4,s4,0x20
ffffffffc02041b4:	020a5a13          	srli	s4,s4,0x20
ffffffffc02041b8:	00002797          	auipc	a5,0x2
ffffffffc02041bc:	30878793          	addi	a5,a5,776 # ffffffffc02064c0 <error_string+0x38>
ffffffffc02041c0:	9a3e                	add	s4,s4,a5
}
ffffffffc02041c2:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02041c4:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02041c8:	70a2                	ld	ra,40(sp)
ffffffffc02041ca:	69a2                	ld	s3,8(sp)
ffffffffc02041cc:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02041ce:	85ca                	mv	a1,s2
ffffffffc02041d0:	8326                	mv	t1,s1
}
ffffffffc02041d2:	6942                	ld	s2,16(sp)
ffffffffc02041d4:	64e2                	ld	s1,24(sp)
ffffffffc02041d6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02041d8:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02041da:	03065633          	divu	a2,a2,a6
ffffffffc02041de:	8722                	mv	a4,s0
ffffffffc02041e0:	f9bff0ef          	jal	ra,ffffffffc020417a <printnum>
ffffffffc02041e4:	b7f9                	j	ffffffffc02041b2 <printnum+0x38>

ffffffffc02041e6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02041e6:	7119                	addi	sp,sp,-128
ffffffffc02041e8:	f4a6                	sd	s1,104(sp)
ffffffffc02041ea:	f0ca                	sd	s2,96(sp)
ffffffffc02041ec:	e8d2                	sd	s4,80(sp)
ffffffffc02041ee:	e4d6                	sd	s5,72(sp)
ffffffffc02041f0:	e0da                	sd	s6,64(sp)
ffffffffc02041f2:	fc5e                	sd	s7,56(sp)
ffffffffc02041f4:	f862                	sd	s8,48(sp)
ffffffffc02041f6:	f06a                	sd	s10,32(sp)
ffffffffc02041f8:	fc86                	sd	ra,120(sp)
ffffffffc02041fa:	f8a2                	sd	s0,112(sp)
ffffffffc02041fc:	ecce                	sd	s3,88(sp)
ffffffffc02041fe:	f466                	sd	s9,40(sp)
ffffffffc0204200:	ec6e                	sd	s11,24(sp)
ffffffffc0204202:	892a                	mv	s2,a0
ffffffffc0204204:	84ae                	mv	s1,a1
ffffffffc0204206:	8d32                	mv	s10,a2
ffffffffc0204208:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020420a:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020420c:	00002a17          	auipc	s4,0x2
ffffffffc0204210:	124a0a13          	addi	s4,s4,292 # ffffffffc0206330 <default_pmm_manager+0xa8>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204214:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204218:	00002c17          	auipc	s8,0x2
ffffffffc020421c:	270c0c13          	addi	s8,s8,624 # ffffffffc0206488 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204220:	000d4503          	lbu	a0,0(s10)
ffffffffc0204224:	02500793          	li	a5,37
ffffffffc0204228:	001d0413          	addi	s0,s10,1
ffffffffc020422c:	00f50e63          	beq	a0,a5,ffffffffc0204248 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0204230:	c521                	beqz	a0,ffffffffc0204278 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204232:	02500993          	li	s3,37
ffffffffc0204236:	a011                	j	ffffffffc020423a <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0204238:	c121                	beqz	a0,ffffffffc0204278 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc020423a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020423c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020423e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204240:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204244:	ff351ae3          	bne	a0,s3,ffffffffc0204238 <vprintfmt+0x52>
ffffffffc0204248:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020424c:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204250:	4981                	li	s3,0
ffffffffc0204252:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0204254:	5cfd                	li	s9,-1
ffffffffc0204256:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204258:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc020425c:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020425e:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0204262:	0ff6f693          	andi	a3,a3,255
ffffffffc0204266:	00140d13          	addi	s10,s0,1
ffffffffc020426a:	20d5e563          	bltu	a1,a3,ffffffffc0204474 <vprintfmt+0x28e>
ffffffffc020426e:	068a                	slli	a3,a3,0x2
ffffffffc0204270:	96d2                	add	a3,a3,s4
ffffffffc0204272:	4294                	lw	a3,0(a3)
ffffffffc0204274:	96d2                	add	a3,a3,s4
ffffffffc0204276:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204278:	70e6                	ld	ra,120(sp)
ffffffffc020427a:	7446                	ld	s0,112(sp)
ffffffffc020427c:	74a6                	ld	s1,104(sp)
ffffffffc020427e:	7906                	ld	s2,96(sp)
ffffffffc0204280:	69e6                	ld	s3,88(sp)
ffffffffc0204282:	6a46                	ld	s4,80(sp)
ffffffffc0204284:	6aa6                	ld	s5,72(sp)
ffffffffc0204286:	6b06                	ld	s6,64(sp)
ffffffffc0204288:	7be2                	ld	s7,56(sp)
ffffffffc020428a:	7c42                	ld	s8,48(sp)
ffffffffc020428c:	7ca2                	ld	s9,40(sp)
ffffffffc020428e:	7d02                	ld	s10,32(sp)
ffffffffc0204290:	6de2                	ld	s11,24(sp)
ffffffffc0204292:	6109                	addi	sp,sp,128
ffffffffc0204294:	8082                	ret
    if (lflag >= 2) {
ffffffffc0204296:	4705                	li	a4,1
ffffffffc0204298:	008a8593          	addi	a1,s5,8
ffffffffc020429c:	01074463          	blt	a4,a6,ffffffffc02042a4 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc02042a0:	26080363          	beqz	a6,ffffffffc0204506 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc02042a4:	000ab603          	ld	a2,0(s5)
ffffffffc02042a8:	46c1                	li	a3,16
ffffffffc02042aa:	8aae                	mv	s5,a1
ffffffffc02042ac:	a06d                	j	ffffffffc0204356 <vprintfmt+0x170>
            goto reswitch;
ffffffffc02042ae:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02042b2:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02042b4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02042b6:	b765                	j	ffffffffc020425e <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc02042b8:	000aa503          	lw	a0,0(s5)
ffffffffc02042bc:	85a6                	mv	a1,s1
ffffffffc02042be:	0aa1                	addi	s5,s5,8
ffffffffc02042c0:	9902                	jalr	s2
            break;
ffffffffc02042c2:	bfb9                	j	ffffffffc0204220 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02042c4:	4705                	li	a4,1
ffffffffc02042c6:	008a8993          	addi	s3,s5,8
ffffffffc02042ca:	01074463          	blt	a4,a6,ffffffffc02042d2 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc02042ce:	22080463          	beqz	a6,ffffffffc02044f6 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc02042d2:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02042d6:	24044463          	bltz	s0,ffffffffc020451e <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02042da:	8622                	mv	a2,s0
ffffffffc02042dc:	8ace                	mv	s5,s3
ffffffffc02042de:	46a9                	li	a3,10
ffffffffc02042e0:	a89d                	j	ffffffffc0204356 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02042e2:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02042e6:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02042e8:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02042ea:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02042ee:	8fb5                	xor	a5,a5,a3
ffffffffc02042f0:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02042f4:	1ad74363          	blt	a4,a3,ffffffffc020449a <vprintfmt+0x2b4>
ffffffffc02042f8:	00369793          	slli	a5,a3,0x3
ffffffffc02042fc:	97e2                	add	a5,a5,s8
ffffffffc02042fe:	639c                	ld	a5,0(a5)
ffffffffc0204300:	18078d63          	beqz	a5,ffffffffc020449a <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204304:	86be                	mv	a3,a5
ffffffffc0204306:	00002617          	auipc	a2,0x2
ffffffffc020430a:	26a60613          	addi	a2,a2,618 # ffffffffc0206570 <error_string+0xe8>
ffffffffc020430e:	85a6                	mv	a1,s1
ffffffffc0204310:	854a                	mv	a0,s2
ffffffffc0204312:	240000ef          	jal	ra,ffffffffc0204552 <printfmt>
ffffffffc0204316:	b729                	j	ffffffffc0204220 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0204318:	00144603          	lbu	a2,1(s0)
ffffffffc020431c:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020431e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204320:	bf3d                	j	ffffffffc020425e <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0204322:	4705                	li	a4,1
ffffffffc0204324:	008a8593          	addi	a1,s5,8
ffffffffc0204328:	01074463          	blt	a4,a6,ffffffffc0204330 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc020432c:	1e080263          	beqz	a6,ffffffffc0204510 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0204330:	000ab603          	ld	a2,0(s5)
ffffffffc0204334:	46a1                	li	a3,8
ffffffffc0204336:	8aae                	mv	s5,a1
ffffffffc0204338:	a839                	j	ffffffffc0204356 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc020433a:	03000513          	li	a0,48
ffffffffc020433e:	85a6                	mv	a1,s1
ffffffffc0204340:	e03e                	sd	a5,0(sp)
ffffffffc0204342:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204344:	85a6                	mv	a1,s1
ffffffffc0204346:	07800513          	li	a0,120
ffffffffc020434a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020434c:	0aa1                	addi	s5,s5,8
ffffffffc020434e:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0204352:	6782                	ld	a5,0(sp)
ffffffffc0204354:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204356:	876e                	mv	a4,s11
ffffffffc0204358:	85a6                	mv	a1,s1
ffffffffc020435a:	854a                	mv	a0,s2
ffffffffc020435c:	e1fff0ef          	jal	ra,ffffffffc020417a <printnum>
            break;
ffffffffc0204360:	b5c1                	j	ffffffffc0204220 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204362:	000ab603          	ld	a2,0(s5)
ffffffffc0204366:	0aa1                	addi	s5,s5,8
ffffffffc0204368:	1c060663          	beqz	a2,ffffffffc0204534 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc020436c:	00160413          	addi	s0,a2,1
ffffffffc0204370:	17b05c63          	blez	s11,ffffffffc02044e8 <vprintfmt+0x302>
ffffffffc0204374:	02d00593          	li	a1,45
ffffffffc0204378:	14b79263          	bne	a5,a1,ffffffffc02044bc <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020437c:	00064783          	lbu	a5,0(a2)
ffffffffc0204380:	0007851b          	sext.w	a0,a5
ffffffffc0204384:	c905                	beqz	a0,ffffffffc02043b4 <vprintfmt+0x1ce>
ffffffffc0204386:	000cc563          	bltz	s9,ffffffffc0204390 <vprintfmt+0x1aa>
ffffffffc020438a:	3cfd                	addiw	s9,s9,-1
ffffffffc020438c:	036c8263          	beq	s9,s6,ffffffffc02043b0 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0204390:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204392:	18098463          	beqz	s3,ffffffffc020451a <vprintfmt+0x334>
ffffffffc0204396:	3781                	addiw	a5,a5,-32
ffffffffc0204398:	18fbf163          	bleu	a5,s7,ffffffffc020451a <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc020439c:	03f00513          	li	a0,63
ffffffffc02043a0:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02043a2:	0405                	addi	s0,s0,1
ffffffffc02043a4:	fff44783          	lbu	a5,-1(s0)
ffffffffc02043a8:	3dfd                	addiw	s11,s11,-1
ffffffffc02043aa:	0007851b          	sext.w	a0,a5
ffffffffc02043ae:	fd61                	bnez	a0,ffffffffc0204386 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc02043b0:	e7b058e3          	blez	s11,ffffffffc0204220 <vprintfmt+0x3a>
ffffffffc02043b4:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02043b6:	85a6                	mv	a1,s1
ffffffffc02043b8:	02000513          	li	a0,32
ffffffffc02043bc:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02043be:	e60d81e3          	beqz	s11,ffffffffc0204220 <vprintfmt+0x3a>
ffffffffc02043c2:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02043c4:	85a6                	mv	a1,s1
ffffffffc02043c6:	02000513          	li	a0,32
ffffffffc02043ca:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02043cc:	fe0d94e3          	bnez	s11,ffffffffc02043b4 <vprintfmt+0x1ce>
ffffffffc02043d0:	bd81                	j	ffffffffc0204220 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02043d2:	4705                	li	a4,1
ffffffffc02043d4:	008a8593          	addi	a1,s5,8
ffffffffc02043d8:	01074463          	blt	a4,a6,ffffffffc02043e0 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02043dc:	12080063          	beqz	a6,ffffffffc02044fc <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02043e0:	000ab603          	ld	a2,0(s5)
ffffffffc02043e4:	46a9                	li	a3,10
ffffffffc02043e6:	8aae                	mv	s5,a1
ffffffffc02043e8:	b7bd                	j	ffffffffc0204356 <vprintfmt+0x170>
ffffffffc02043ea:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02043ee:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02043f2:	846a                	mv	s0,s10
ffffffffc02043f4:	b5ad                	j	ffffffffc020425e <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02043f6:	85a6                	mv	a1,s1
ffffffffc02043f8:	02500513          	li	a0,37
ffffffffc02043fc:	9902                	jalr	s2
            break;
ffffffffc02043fe:	b50d                	j	ffffffffc0204220 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0204400:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0204404:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204408:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020440a:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc020440c:	e40dd9e3          	bgez	s11,ffffffffc020425e <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0204410:	8de6                	mv	s11,s9
ffffffffc0204412:	5cfd                	li	s9,-1
ffffffffc0204414:	b5a9                	j	ffffffffc020425e <vprintfmt+0x78>
            goto reswitch;
ffffffffc0204416:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc020441a:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020441e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204420:	bd3d                	j	ffffffffc020425e <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0204422:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0204426:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020442a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020442c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204430:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204434:	fcd56ce3          	bltu	a0,a3,ffffffffc020440c <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0204438:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020443a:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc020443e:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204442:	0196873b          	addw	a4,a3,s9
ffffffffc0204446:	0017171b          	slliw	a4,a4,0x1
ffffffffc020444a:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc020444e:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0204452:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0204456:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020445a:	fcd57fe3          	bleu	a3,a0,ffffffffc0204438 <vprintfmt+0x252>
ffffffffc020445e:	b77d                	j	ffffffffc020440c <vprintfmt+0x226>
            if (width < 0)
ffffffffc0204460:	fffdc693          	not	a3,s11
ffffffffc0204464:	96fd                	srai	a3,a3,0x3f
ffffffffc0204466:	00ddfdb3          	and	s11,s11,a3
ffffffffc020446a:	00144603          	lbu	a2,1(s0)
ffffffffc020446e:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204470:	846a                	mv	s0,s10
ffffffffc0204472:	b3f5                	j	ffffffffc020425e <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0204474:	85a6                	mv	a1,s1
ffffffffc0204476:	02500513          	li	a0,37
ffffffffc020447a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020447c:	fff44703          	lbu	a4,-1(s0)
ffffffffc0204480:	02500793          	li	a5,37
ffffffffc0204484:	8d22                	mv	s10,s0
ffffffffc0204486:	d8f70de3          	beq	a4,a5,ffffffffc0204220 <vprintfmt+0x3a>
ffffffffc020448a:	02500713          	li	a4,37
ffffffffc020448e:	1d7d                	addi	s10,s10,-1
ffffffffc0204490:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0204494:	fee79de3          	bne	a5,a4,ffffffffc020448e <vprintfmt+0x2a8>
ffffffffc0204498:	b361                	j	ffffffffc0204220 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020449a:	00002617          	auipc	a2,0x2
ffffffffc020449e:	0c660613          	addi	a2,a2,198 # ffffffffc0206560 <error_string+0xd8>
ffffffffc02044a2:	85a6                	mv	a1,s1
ffffffffc02044a4:	854a                	mv	a0,s2
ffffffffc02044a6:	0ac000ef          	jal	ra,ffffffffc0204552 <printfmt>
ffffffffc02044aa:	bb9d                	j	ffffffffc0204220 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02044ac:	00002617          	auipc	a2,0x2
ffffffffc02044b0:	0ac60613          	addi	a2,a2,172 # ffffffffc0206558 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc02044b4:	00002417          	auipc	s0,0x2
ffffffffc02044b8:	0a540413          	addi	s0,s0,165 # ffffffffc0206559 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02044bc:	8532                	mv	a0,a2
ffffffffc02044be:	85e6                	mv	a1,s9
ffffffffc02044c0:	e032                	sd	a2,0(sp)
ffffffffc02044c2:	e43e                	sd	a5,8(sp)
ffffffffc02044c4:	c0dff0ef          	jal	ra,ffffffffc02040d0 <strnlen>
ffffffffc02044c8:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02044cc:	6602                	ld	a2,0(sp)
ffffffffc02044ce:	01b05d63          	blez	s11,ffffffffc02044e8 <vprintfmt+0x302>
ffffffffc02044d2:	67a2                	ld	a5,8(sp)
ffffffffc02044d4:	2781                	sext.w	a5,a5
ffffffffc02044d6:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02044d8:	6522                	ld	a0,8(sp)
ffffffffc02044da:	85a6                	mv	a1,s1
ffffffffc02044dc:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02044de:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02044e0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02044e2:	6602                	ld	a2,0(sp)
ffffffffc02044e4:	fe0d9ae3          	bnez	s11,ffffffffc02044d8 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02044e8:	00064783          	lbu	a5,0(a2)
ffffffffc02044ec:	0007851b          	sext.w	a0,a5
ffffffffc02044f0:	e8051be3          	bnez	a0,ffffffffc0204386 <vprintfmt+0x1a0>
ffffffffc02044f4:	b335                	j	ffffffffc0204220 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02044f6:	000aa403          	lw	s0,0(s5)
ffffffffc02044fa:	bbf1                	j	ffffffffc02042d6 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02044fc:	000ae603          	lwu	a2,0(s5)
ffffffffc0204500:	46a9                	li	a3,10
ffffffffc0204502:	8aae                	mv	s5,a1
ffffffffc0204504:	bd89                	j	ffffffffc0204356 <vprintfmt+0x170>
ffffffffc0204506:	000ae603          	lwu	a2,0(s5)
ffffffffc020450a:	46c1                	li	a3,16
ffffffffc020450c:	8aae                	mv	s5,a1
ffffffffc020450e:	b5a1                	j	ffffffffc0204356 <vprintfmt+0x170>
ffffffffc0204510:	000ae603          	lwu	a2,0(s5)
ffffffffc0204514:	46a1                	li	a3,8
ffffffffc0204516:	8aae                	mv	s5,a1
ffffffffc0204518:	bd3d                	j	ffffffffc0204356 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc020451a:	9902                	jalr	s2
ffffffffc020451c:	b559                	j	ffffffffc02043a2 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc020451e:	85a6                	mv	a1,s1
ffffffffc0204520:	02d00513          	li	a0,45
ffffffffc0204524:	e03e                	sd	a5,0(sp)
ffffffffc0204526:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204528:	8ace                	mv	s5,s3
ffffffffc020452a:	40800633          	neg	a2,s0
ffffffffc020452e:	46a9                	li	a3,10
ffffffffc0204530:	6782                	ld	a5,0(sp)
ffffffffc0204532:	b515                	j	ffffffffc0204356 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0204534:	01b05663          	blez	s11,ffffffffc0204540 <vprintfmt+0x35a>
ffffffffc0204538:	02d00693          	li	a3,45
ffffffffc020453c:	f6d798e3          	bne	a5,a3,ffffffffc02044ac <vprintfmt+0x2c6>
ffffffffc0204540:	00002417          	auipc	s0,0x2
ffffffffc0204544:	01940413          	addi	s0,s0,25 # ffffffffc0206559 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204548:	02800513          	li	a0,40
ffffffffc020454c:	02800793          	li	a5,40
ffffffffc0204550:	bd1d                	j	ffffffffc0204386 <vprintfmt+0x1a0>

ffffffffc0204552 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204552:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204554:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204558:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020455a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020455c:	ec06                	sd	ra,24(sp)
ffffffffc020455e:	f83a                	sd	a4,48(sp)
ffffffffc0204560:	fc3e                	sd	a5,56(sp)
ffffffffc0204562:	e0c2                	sd	a6,64(sp)
ffffffffc0204564:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204566:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204568:	c7fff0ef          	jal	ra,ffffffffc02041e6 <vprintfmt>
}
ffffffffc020456c:	60e2                	ld	ra,24(sp)
ffffffffc020456e:	6161                	addi	sp,sp,80
ffffffffc0204570:	8082                	ret

ffffffffc0204572 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0204572:	715d                	addi	sp,sp,-80
ffffffffc0204574:	e486                	sd	ra,72(sp)
ffffffffc0204576:	e0a2                	sd	s0,64(sp)
ffffffffc0204578:	fc26                	sd	s1,56(sp)
ffffffffc020457a:	f84a                	sd	s2,48(sp)
ffffffffc020457c:	f44e                	sd	s3,40(sp)
ffffffffc020457e:	f052                	sd	s4,32(sp)
ffffffffc0204580:	ec56                	sd	s5,24(sp)
ffffffffc0204582:	e85a                	sd	s6,16(sp)
ffffffffc0204584:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0204586:	c901                	beqz	a0,ffffffffc0204596 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0204588:	85aa                	mv	a1,a0
ffffffffc020458a:	00002517          	auipc	a0,0x2
ffffffffc020458e:	fe650513          	addi	a0,a0,-26 # ffffffffc0206570 <error_string+0xe8>
ffffffffc0204592:	b2dfb0ef          	jal	ra,ffffffffc02000be <cprintf>
readline(const char *prompt) {
ffffffffc0204596:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204598:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020459a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020459c:	4aa9                	li	s5,10
ffffffffc020459e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02045a0:	0000db97          	auipc	s7,0xd
ffffffffc02045a4:	aa0b8b93          	addi	s7,s7,-1376 # ffffffffc0211040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02045a8:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02045ac:	b4bfb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc02045b0:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02045b2:	00054b63          	bltz	a0,ffffffffc02045c8 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02045b6:	00a95b63          	ble	a0,s2,ffffffffc02045cc <readline+0x5a>
ffffffffc02045ba:	029a5463          	ble	s1,s4,ffffffffc02045e2 <readline+0x70>
        c = getchar();
ffffffffc02045be:	b39fb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc02045c2:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02045c4:	fe0559e3          	bgez	a0,ffffffffc02045b6 <readline+0x44>
            return NULL;
ffffffffc02045c8:	4501                	li	a0,0
ffffffffc02045ca:	a099                	j	ffffffffc0204610 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02045cc:	03341463          	bne	s0,s3,ffffffffc02045f4 <readline+0x82>
ffffffffc02045d0:	e8b9                	bnez	s1,ffffffffc0204626 <readline+0xb4>
        c = getchar();
ffffffffc02045d2:	b25fb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc02045d6:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02045d8:	fe0548e3          	bltz	a0,ffffffffc02045c8 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02045dc:	fea958e3          	ble	a0,s2,ffffffffc02045cc <readline+0x5a>
ffffffffc02045e0:	4481                	li	s1,0
            cputchar(c);
ffffffffc02045e2:	8522                	mv	a0,s0
ffffffffc02045e4:	b0ffb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i ++] = c;
ffffffffc02045e8:	009b87b3          	add	a5,s7,s1
ffffffffc02045ec:	00878023          	sb	s0,0(a5)
ffffffffc02045f0:	2485                	addiw	s1,s1,1
ffffffffc02045f2:	bf6d                	j	ffffffffc02045ac <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02045f4:	01540463          	beq	s0,s5,ffffffffc02045fc <readline+0x8a>
ffffffffc02045f8:	fb641ae3          	bne	s0,s6,ffffffffc02045ac <readline+0x3a>
            cputchar(c);
ffffffffc02045fc:	8522                	mv	a0,s0
ffffffffc02045fe:	af5fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i] = '\0';
ffffffffc0204602:	0000d517          	auipc	a0,0xd
ffffffffc0204606:	a3e50513          	addi	a0,a0,-1474 # ffffffffc0211040 <buf>
ffffffffc020460a:	94aa                	add	s1,s1,a0
ffffffffc020460c:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0204610:	60a6                	ld	ra,72(sp)
ffffffffc0204612:	6406                	ld	s0,64(sp)
ffffffffc0204614:	74e2                	ld	s1,56(sp)
ffffffffc0204616:	7942                	ld	s2,48(sp)
ffffffffc0204618:	79a2                	ld	s3,40(sp)
ffffffffc020461a:	7a02                	ld	s4,32(sp)
ffffffffc020461c:	6ae2                	ld	s5,24(sp)
ffffffffc020461e:	6b42                	ld	s6,16(sp)
ffffffffc0204620:	6ba2                	ld	s7,8(sp)
ffffffffc0204622:	6161                	addi	sp,sp,80
ffffffffc0204624:	8082                	ret
            cputchar(c);
ffffffffc0204626:	4521                	li	a0,8
ffffffffc0204628:	acbfb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            i --;
ffffffffc020462c:	34fd                	addiw	s1,s1,-1
ffffffffc020462e:	bfbd                	j	ffffffffc02045ac <readline+0x3a>
