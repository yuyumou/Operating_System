
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
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
ffffffffc0200028:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fda50513          	addi	a0,a0,-38 # ffffffffc0206010 <edata>
ffffffffc020003e:	00006617          	auipc	a2,0x6
ffffffffc0200042:	44a60613          	addi	a2,a2,1098 # ffffffffc0206488 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	668010ef          	jal	ra,ffffffffc02016b6 <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00001517          	auipc	a0,0x1
ffffffffc020005a:	67250513          	addi	a0,a0,1650 # ffffffffc02016c8 <etext>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	0dc000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	725000ef          	jal	ra,ffffffffc0200f8e <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	3fc000ef          	jal	ra,ffffffffc020046a <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	39a000ef          	jal	ra,ffffffffc020040c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3e8000ef          	jal	ra,ffffffffc020045e <intr_enable>



    /* do nothing */
    while (1)
        ;
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200084:	3ce000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200088:	401c                	lw	a5,0(s0)
}
ffffffffc020008a:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
}
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200096:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	86ae                	mv	a3,a1
ffffffffc020009a:	862a                	mv	a2,a0
ffffffffc020009c:	006c                	addi	a1,sp,12
ffffffffc020009e:	00000517          	auipc	a0,0x0
ffffffffc02000a2:	fde50513          	addi	a0,a0,-34 # ffffffffc020007c <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000aa:	0fe010ef          	jal	ra,ffffffffc02011a8 <vprintfmt>
    return cnt;
}
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000bc:	f42e                	sd	a1,40(sp)
ffffffffc02000be:	f832                	sd	a2,48(sp)
ffffffffc02000c0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fb650513          	addi	a0,a0,-74 # ffffffffc020007c <cputch>
ffffffffc02000ce:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
ffffffffc02000d2:	e0ba                	sd	a4,64(sp)
ffffffffc02000d4:	e4be                	sd	a5,72(sp)
ffffffffc02000d6:	e8c2                	sd	a6,80(sp)
ffffffffc02000d8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000da:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000dc:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000de:	0ca010ef          	jal	ra,ffffffffc02011a8 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e2:	60e2                	ld	ra,24(sp)
ffffffffc02000e4:	4512                	lw	a0,4(sp)
ffffffffc02000e6:	6125                	addi	sp,sp,96
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ea:	3680006f          	j	ffffffffc0200452 <cons_putc>

ffffffffc02000ee <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ee:	1101                	addi	sp,sp,-32
ffffffffc02000f0:	e822                	sd	s0,16(sp)
ffffffffc02000f2:	ec06                	sd	ra,24(sp)
ffffffffc02000f4:	e426                	sd	s1,8(sp)
ffffffffc02000f6:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f8:	00054503          	lbu	a0,0(a0)
ffffffffc02000fc:	c51d                	beqz	a0,ffffffffc020012a <cputs+0x3c>
ffffffffc02000fe:	0405                	addi	s0,s0,1
ffffffffc0200100:	4485                	li	s1,1
ffffffffc0200102:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200104:	34e000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200112:	f96d                	bnez	a0,ffffffffc0200104 <cputs+0x16>
ffffffffc0200114:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200118:	4529                	li	a0,10
ffffffffc020011a:	338000ef          	jal	ra,ffffffffc0200452 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011e:	8522                	mv	a0,s0
ffffffffc0200120:	60e2                	ld	ra,24(sp)
ffffffffc0200122:	6442                	ld	s0,16(sp)
ffffffffc0200124:	64a2                	ld	s1,8(sp)
ffffffffc0200126:	6105                	addi	sp,sp,32
ffffffffc0200128:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020012a:	4405                	li	s0,1
ffffffffc020012c:	b7f5                	j	ffffffffc0200118 <cputs+0x2a>

ffffffffc020012e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012e:	1141                	addi	sp,sp,-16
ffffffffc0200130:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200132:	328000ef          	jal	ra,ffffffffc020045a <cons_getc>
ffffffffc0200136:	dd75                	beqz	a0,ffffffffc0200132 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200138:	60a2                	ld	ra,8(sp)
ffffffffc020013a:	0141                	addi	sp,sp,16
ffffffffc020013c:	8082                	ret

ffffffffc020013e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200140:	00001517          	auipc	a0,0x1
ffffffffc0200144:	5d850513          	addi	a0,a0,1496 # ffffffffc0201718 <etext+0x50>
void print_kerninfo(void) {
ffffffffc0200148:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee858593          	addi	a1,a1,-280 # ffffffffc0200036 <kern_init>
ffffffffc0200156:	00001517          	auipc	a0,0x1
ffffffffc020015a:	5e250513          	addi	a0,a0,1506 # ffffffffc0201738 <etext+0x70>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200162:	00001597          	auipc	a1,0x1
ffffffffc0200166:	56658593          	addi	a1,a1,1382 # ffffffffc02016c8 <etext>
ffffffffc020016a:	00001517          	auipc	a0,0x1
ffffffffc020016e:	5ee50513          	addi	a0,a0,1518 # ffffffffc0201758 <etext+0x90>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200176:	00006597          	auipc	a1,0x6
ffffffffc020017a:	e9a58593          	addi	a1,a1,-358 # ffffffffc0206010 <edata>
ffffffffc020017e:	00001517          	auipc	a0,0x1
ffffffffc0200182:	5fa50513          	addi	a0,a0,1530 # ffffffffc0201778 <etext+0xb0>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018a:	00006597          	auipc	a1,0x6
ffffffffc020018e:	2fe58593          	addi	a1,a1,766 # ffffffffc0206488 <end>
ffffffffc0200192:	00001517          	auipc	a0,0x1
ffffffffc0200196:	60650513          	addi	a0,a0,1542 # ffffffffc0201798 <etext+0xd0>
ffffffffc020019a:	f1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019e:	00006597          	auipc	a1,0x6
ffffffffc02001a2:	6e958593          	addi	a1,a1,1769 # ffffffffc0206887 <end+0x3ff>
ffffffffc02001a6:	00000797          	auipc	a5,0x0
ffffffffc02001aa:	e9078793          	addi	a5,a5,-368 # ffffffffc0200036 <kern_init>
ffffffffc02001ae:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b2:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b6:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b8:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001bc:	95be                	add	a1,a1,a5
ffffffffc02001be:	85a9                	srai	a1,a1,0xa
ffffffffc02001c0:	00001517          	auipc	a0,0x1
ffffffffc02001c4:	5f850513          	addi	a0,a0,1528 # ffffffffc02017b8 <etext+0xf0>
}
ffffffffc02001c8:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ca:	eedff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02001ce <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001ce:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001d0:	00001617          	auipc	a2,0x1
ffffffffc02001d4:	51860613          	addi	a2,a2,1304 # ffffffffc02016e8 <etext+0x20>
ffffffffc02001d8:	04e00593          	li	a1,78
ffffffffc02001dc:	00001517          	auipc	a0,0x1
ffffffffc02001e0:	52450513          	addi	a0,a0,1316 # ffffffffc0201700 <etext+0x38>
void print_stackframe(void) {
ffffffffc02001e4:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e6:	1c6000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001ea <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ea:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ec:	00001617          	auipc	a2,0x1
ffffffffc02001f0:	6dc60613          	addi	a2,a2,1756 # ffffffffc02018c8 <commands+0xe0>
ffffffffc02001f4:	00001597          	auipc	a1,0x1
ffffffffc02001f8:	6f458593          	addi	a1,a1,1780 # ffffffffc02018e8 <commands+0x100>
ffffffffc02001fc:	00001517          	auipc	a0,0x1
ffffffffc0200200:	6f450513          	addi	a0,a0,1780 # ffffffffc02018f0 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200204:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200206:	eb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020020a:	00001617          	auipc	a2,0x1
ffffffffc020020e:	6f660613          	addi	a2,a2,1782 # ffffffffc0201900 <commands+0x118>
ffffffffc0200212:	00001597          	auipc	a1,0x1
ffffffffc0200216:	71658593          	addi	a1,a1,1814 # ffffffffc0201928 <commands+0x140>
ffffffffc020021a:	00001517          	auipc	a0,0x1
ffffffffc020021e:	6d650513          	addi	a0,a0,1750 # ffffffffc02018f0 <commands+0x108>
ffffffffc0200222:	e95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200226:	00001617          	auipc	a2,0x1
ffffffffc020022a:	71260613          	addi	a2,a2,1810 # ffffffffc0201938 <commands+0x150>
ffffffffc020022e:	00001597          	auipc	a1,0x1
ffffffffc0200232:	72a58593          	addi	a1,a1,1834 # ffffffffc0201958 <commands+0x170>
ffffffffc0200236:	00001517          	auipc	a0,0x1
ffffffffc020023a:	6ba50513          	addi	a0,a0,1722 # ffffffffc02018f0 <commands+0x108>
ffffffffc020023e:	e79ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    }
    return 0;
}
ffffffffc0200242:	60a2                	ld	ra,8(sp)
ffffffffc0200244:	4501                	li	a0,0
ffffffffc0200246:	0141                	addi	sp,sp,16
ffffffffc0200248:	8082                	ret

ffffffffc020024a <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020024a:	1141                	addi	sp,sp,-16
ffffffffc020024c:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020024e:	ef1ff0ef          	jal	ra,ffffffffc020013e <print_kerninfo>
    return 0;
}
ffffffffc0200252:	60a2                	ld	ra,8(sp)
ffffffffc0200254:	4501                	li	a0,0
ffffffffc0200256:	0141                	addi	sp,sp,16
ffffffffc0200258:	8082                	ret

ffffffffc020025a <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025a:	1141                	addi	sp,sp,-16
ffffffffc020025c:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020025e:	f71ff0ef          	jal	ra,ffffffffc02001ce <print_stackframe>
    return 0;
}
ffffffffc0200262:	60a2                	ld	ra,8(sp)
ffffffffc0200264:	4501                	li	a0,0
ffffffffc0200266:	0141                	addi	sp,sp,16
ffffffffc0200268:	8082                	ret

ffffffffc020026a <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020026a:	7115                	addi	sp,sp,-224
ffffffffc020026c:	e962                	sd	s8,144(sp)
ffffffffc020026e:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200270:	00001517          	auipc	a0,0x1
ffffffffc0200274:	5c050513          	addi	a0,a0,1472 # ffffffffc0201830 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200278:	ed86                	sd	ra,216(sp)
ffffffffc020027a:	e9a2                	sd	s0,208(sp)
ffffffffc020027c:	e5a6                	sd	s1,200(sp)
ffffffffc020027e:	e1ca                	sd	s2,192(sp)
ffffffffc0200280:	fd4e                	sd	s3,184(sp)
ffffffffc0200282:	f952                	sd	s4,176(sp)
ffffffffc0200284:	f556                	sd	s5,168(sp)
ffffffffc0200286:	f15a                	sd	s6,160(sp)
ffffffffc0200288:	ed5e                	sd	s7,152(sp)
ffffffffc020028a:	e566                	sd	s9,136(sp)
ffffffffc020028c:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020028e:	e29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200292:	00001517          	auipc	a0,0x1
ffffffffc0200296:	5c650513          	addi	a0,a0,1478 # ffffffffc0201858 <commands+0x70>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029e:	000c0563          	beqz	s8,ffffffffc02002a8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a2:	8562                	mv	a0,s8
ffffffffc02002a4:	3a6000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002a8:	00001c97          	auipc	s9,0x1
ffffffffc02002ac:	540c8c93          	addi	s9,s9,1344 # ffffffffc02017e8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b0:	00001997          	auipc	s3,0x1
ffffffffc02002b4:	5d098993          	addi	s3,s3,1488 # ffffffffc0201880 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00001917          	auipc	s2,0x1
ffffffffc02002bc:	5d090913          	addi	s2,s2,1488 # ffffffffc0201888 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c2:	00001b17          	auipc	s6,0x1
ffffffffc02002c6:	5ceb0b13          	addi	s6,s6,1486 # ffffffffc0201890 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002ca:	00001a97          	auipc	s5,0x1
ffffffffc02002ce:	61ea8a93          	addi	s5,s5,1566 # ffffffffc02018e8 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d4:	854e                	mv	a0,s3
ffffffffc02002d6:	25e010ef          	jal	ra,ffffffffc0201534 <readline>
ffffffffc02002da:	842a                	mv	s0,a0
ffffffffc02002dc:	dd65                	beqz	a0,ffffffffc02002d4 <kmonitor+0x6a>
ffffffffc02002de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e4:	c999                	beqz	a1,ffffffffc02002fa <kmonitor+0x90>
ffffffffc02002e6:	854a                	mv	a0,s2
ffffffffc02002e8:	3b0010ef          	jal	ra,ffffffffc0201698 <strchr>
ffffffffc02002ec:	c925                	beqz	a0,ffffffffc020035c <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002ee:	00144583          	lbu	a1,1(s0)
ffffffffc02002f2:	00040023          	sb	zero,0(s0)
ffffffffc02002f6:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002f8:	f5fd                	bnez	a1,ffffffffc02002e6 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02002fa:	dce9                	beqz	s1,ffffffffc02002d4 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002fc:	6582                	ld	a1,0(sp)
ffffffffc02002fe:	00001d17          	auipc	s10,0x1
ffffffffc0200302:	4ead0d13          	addi	s10,s10,1258 # ffffffffc02017e8 <commands>
    if (argc == 0) {
ffffffffc0200306:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200308:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	362010ef          	jal	ra,ffffffffc020166e <strcmp>
ffffffffc0200310:	c919                	beqz	a0,ffffffffc0200326 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	09740463          	beq	s0,s7,ffffffffc020039c <kmonitor+0x132>
ffffffffc0200318:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020031c:	6582                	ld	a1,0(sp)
ffffffffc020031e:	0d61                	addi	s10,s10,24
ffffffffc0200320:	34e010ef          	jal	ra,ffffffffc020166e <strcmp>
ffffffffc0200324:	f57d                	bnez	a0,ffffffffc0200312 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200326:	00141793          	slli	a5,s0,0x1
ffffffffc020032a:	97a2                	add	a5,a5,s0
ffffffffc020032c:	078e                	slli	a5,a5,0x3
ffffffffc020032e:	97e6                	add	a5,a5,s9
ffffffffc0200330:	6b9c                	ld	a5,16(a5)
ffffffffc0200332:	8662                	mv	a2,s8
ffffffffc0200334:	002c                	addi	a1,sp,8
ffffffffc0200336:	fff4851b          	addiw	a0,s1,-1
ffffffffc020033a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020033c:	f8055ce3          	bgez	a0,ffffffffc02002d4 <kmonitor+0x6a>
}
ffffffffc0200340:	60ee                	ld	ra,216(sp)
ffffffffc0200342:	644e                	ld	s0,208(sp)
ffffffffc0200344:	64ae                	ld	s1,200(sp)
ffffffffc0200346:	690e                	ld	s2,192(sp)
ffffffffc0200348:	79ea                	ld	s3,184(sp)
ffffffffc020034a:	7a4a                	ld	s4,176(sp)
ffffffffc020034c:	7aaa                	ld	s5,168(sp)
ffffffffc020034e:	7b0a                	ld	s6,160(sp)
ffffffffc0200350:	6bea                	ld	s7,152(sp)
ffffffffc0200352:	6c4a                	ld	s8,144(sp)
ffffffffc0200354:	6caa                	ld	s9,136(sp)
ffffffffc0200356:	6d0a                	ld	s10,128(sp)
ffffffffc0200358:	612d                	addi	sp,sp,224
ffffffffc020035a:	8082                	ret
        if (*buf == '\0') {
ffffffffc020035c:	00044783          	lbu	a5,0(s0)
ffffffffc0200360:	dfc9                	beqz	a5,ffffffffc02002fa <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc0200362:	03448863          	beq	s1,s4,ffffffffc0200392 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc0200366:	00349793          	slli	a5,s1,0x3
ffffffffc020036a:	0118                	addi	a4,sp,128
ffffffffc020036c:	97ba                	add	a5,a5,a4
ffffffffc020036e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200372:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200376:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200378:	e591                	bnez	a1,ffffffffc0200384 <kmonitor+0x11a>
ffffffffc020037a:	b749                	j	ffffffffc02002fc <kmonitor+0x92>
            buf ++;
ffffffffc020037c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020037e:	00044583          	lbu	a1,0(s0)
ffffffffc0200382:	ddad                	beqz	a1,ffffffffc02002fc <kmonitor+0x92>
ffffffffc0200384:	854a                	mv	a0,s2
ffffffffc0200386:	312010ef          	jal	ra,ffffffffc0201698 <strchr>
ffffffffc020038a:	d96d                	beqz	a0,ffffffffc020037c <kmonitor+0x112>
ffffffffc020038c:	00044583          	lbu	a1,0(s0)
ffffffffc0200390:	bf91                	j	ffffffffc02002e4 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020039a:	b7f1                	j	ffffffffc0200366 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	51250513          	addi	a0,a0,1298 # ffffffffc02018b0 <commands+0xc8>
ffffffffc02003a6:	d11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return 0;
ffffffffc02003aa:	b72d                	j	ffffffffc02002d4 <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	06430313          	addi	t1,t1,100 # ffffffffc0206410 <is_panic>
ffffffffc02003b4:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	02031c63          	bnez	t1,ffffffffc0200400 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	8432                	mv	s0,a2
ffffffffc02003d0:	00006717          	auipc	a4,0x6
ffffffffc02003d4:	04f72023          	sw	a5,64(a4) # ffffffffc0206410 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d8:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003da:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003dc:	85aa                	mv	a1,a0
ffffffffc02003de:	00001517          	auipc	a0,0x1
ffffffffc02003e2:	58a50513          	addi	a0,a0,1418 # ffffffffc0201968 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02003e6:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e8:	ccfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003ec:	65a2                	ld	a1,8(sp)
ffffffffc02003ee:	8522                	mv	a0,s0
ffffffffc02003f0:	ca7ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc02003f4:	00001517          	auipc	a0,0x1
ffffffffc02003f8:	3ec50513          	addi	a0,a0,1004 # ffffffffc02017e0 <etext+0x118>
ffffffffc02003fc:	cbbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200400:	064000ef          	jal	ra,ffffffffc0200464 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200404:	4501                	li	a0,0
ffffffffc0200406:	e65ff0ef          	jal	ra,ffffffffc020026a <kmonitor>
ffffffffc020040a:	bfed                	j	ffffffffc0200404 <__panic+0x58>

ffffffffc020040c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020040c:	1141                	addi	sp,sp,-16
ffffffffc020040e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200410:	02000793          	li	a5,32
ffffffffc0200414:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200418:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020041c:	67e1                	lui	a5,0x18
ffffffffc020041e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200422:	953e                	add	a0,a0,a5
ffffffffc0200424:	1ea010ef          	jal	ra,ffffffffc020160e <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00001517          	auipc	a0,0x1
ffffffffc0200436:	55650513          	addi	a0,a0,1366 # ffffffffc0201988 <commands+0x1a0>
}
ffffffffc020043a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc020043c:	c7bff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc0200440 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200440:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200444:	67e1                	lui	a5,0x18
ffffffffc0200446:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020044a:	953e                	add	a0,a0,a5
ffffffffc020044c:	1c20106f          	j	ffffffffc020160e <sbi_set_timer>

ffffffffc0200450 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200450:	8082                	ret

ffffffffc0200452 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200452:	0ff57513          	andi	a0,a0,255
ffffffffc0200456:	19c0106f          	j	ffffffffc02015f2 <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	1d00106f          	j	ffffffffc020162a <sbi_console_getchar>

ffffffffc020045e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200464:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200468:	8082                	ret

ffffffffc020046a <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020046a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020046e:	00000797          	auipc	a5,0x0
ffffffffc0200472:	30678793          	addi	a5,a5,774 # ffffffffc0200774 <__alltraps>
ffffffffc0200476:	10579073          	csrw	stvec,a5
}
ffffffffc020047a:	8082                	ret

ffffffffc020047c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020047e:	1141                	addi	sp,sp,-16
ffffffffc0200480:	e022                	sd	s0,0(sp)
ffffffffc0200482:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200484:	00001517          	auipc	a0,0x1
ffffffffc0200488:	61c50513          	addi	a0,a0,1564 # ffffffffc0201aa0 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00001517          	auipc	a0,0x1
ffffffffc0200498:	62450513          	addi	a0,a0,1572 # ffffffffc0201ab8 <commands+0x2d0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00001517          	auipc	a0,0x1
ffffffffc02004a6:	62e50513          	addi	a0,a0,1582 # ffffffffc0201ad0 <commands+0x2e8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00001517          	auipc	a0,0x1
ffffffffc02004b4:	63850513          	addi	a0,a0,1592 # ffffffffc0201ae8 <commands+0x300>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00001517          	auipc	a0,0x1
ffffffffc02004c2:	64250513          	addi	a0,a0,1602 # ffffffffc0201b00 <commands+0x318>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00001517          	auipc	a0,0x1
ffffffffc02004d0:	64c50513          	addi	a0,a0,1612 # ffffffffc0201b18 <commands+0x330>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00001517          	auipc	a0,0x1
ffffffffc02004de:	65650513          	addi	a0,a0,1622 # ffffffffc0201b30 <commands+0x348>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00001517          	auipc	a0,0x1
ffffffffc02004ec:	66050513          	addi	a0,a0,1632 # ffffffffc0201b48 <commands+0x360>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00001517          	auipc	a0,0x1
ffffffffc02004fa:	66a50513          	addi	a0,a0,1642 # ffffffffc0201b60 <commands+0x378>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00001517          	auipc	a0,0x1
ffffffffc0200508:	67450513          	addi	a0,a0,1652 # ffffffffc0201b78 <commands+0x390>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00001517          	auipc	a0,0x1
ffffffffc0200516:	67e50513          	addi	a0,a0,1662 # ffffffffc0201b90 <commands+0x3a8>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00001517          	auipc	a0,0x1
ffffffffc0200524:	68850513          	addi	a0,a0,1672 # ffffffffc0201ba8 <commands+0x3c0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00001517          	auipc	a0,0x1
ffffffffc0200532:	69250513          	addi	a0,a0,1682 # ffffffffc0201bc0 <commands+0x3d8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00001517          	auipc	a0,0x1
ffffffffc0200540:	69c50513          	addi	a0,a0,1692 # ffffffffc0201bd8 <commands+0x3f0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00001517          	auipc	a0,0x1
ffffffffc020054e:	6a650513          	addi	a0,a0,1702 # ffffffffc0201bf0 <commands+0x408>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00001517          	auipc	a0,0x1
ffffffffc020055c:	6b050513          	addi	a0,a0,1712 # ffffffffc0201c08 <commands+0x420>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00001517          	auipc	a0,0x1
ffffffffc020056a:	6ba50513          	addi	a0,a0,1722 # ffffffffc0201c20 <commands+0x438>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00001517          	auipc	a0,0x1
ffffffffc0200578:	6c450513          	addi	a0,a0,1732 # ffffffffc0201c38 <commands+0x450>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00001517          	auipc	a0,0x1
ffffffffc0200586:	6ce50513          	addi	a0,a0,1742 # ffffffffc0201c50 <commands+0x468>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00001517          	auipc	a0,0x1
ffffffffc0200594:	6d850513          	addi	a0,a0,1752 # ffffffffc0201c68 <commands+0x480>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00001517          	auipc	a0,0x1
ffffffffc02005a2:	6e250513          	addi	a0,a0,1762 # ffffffffc0201c80 <commands+0x498>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00001517          	auipc	a0,0x1
ffffffffc02005b0:	6ec50513          	addi	a0,a0,1772 # ffffffffc0201c98 <commands+0x4b0>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00001517          	auipc	a0,0x1
ffffffffc02005be:	6f650513          	addi	a0,a0,1782 # ffffffffc0201cb0 <commands+0x4c8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00001517          	auipc	a0,0x1
ffffffffc02005cc:	70050513          	addi	a0,a0,1792 # ffffffffc0201cc8 <commands+0x4e0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00001517          	auipc	a0,0x1
ffffffffc02005da:	70a50513          	addi	a0,a0,1802 # ffffffffc0201ce0 <commands+0x4f8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00001517          	auipc	a0,0x1
ffffffffc02005e8:	71450513          	addi	a0,a0,1812 # ffffffffc0201cf8 <commands+0x510>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00001517          	auipc	a0,0x1
ffffffffc02005f6:	71e50513          	addi	a0,a0,1822 # ffffffffc0201d10 <commands+0x528>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00001517          	auipc	a0,0x1
ffffffffc0200604:	72850513          	addi	a0,a0,1832 # ffffffffc0201d28 <commands+0x540>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00001517          	auipc	a0,0x1
ffffffffc0200612:	73250513          	addi	a0,a0,1842 # ffffffffc0201d40 <commands+0x558>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00001517          	auipc	a0,0x1
ffffffffc0200620:	73c50513          	addi	a0,a0,1852 # ffffffffc0201d58 <commands+0x570>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00001517          	auipc	a0,0x1
ffffffffc020062e:	74650513          	addi	a0,a0,1862 # ffffffffc0201d70 <commands+0x588>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00001517          	auipc	a0,0x1
ffffffffc0200640:	74c50513          	addi	a0,a0,1868 # ffffffffc0201d88 <commands+0x5a0>
}
ffffffffc0200644:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200646:	a71ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020064a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020064a:	1141                	addi	sp,sp,-16
ffffffffc020064c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020064e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200650:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200652:	00001517          	auipc	a0,0x1
ffffffffc0200656:	74e50513          	addi	a0,a0,1870 # ffffffffc0201da0 <commands+0x5b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065c:	a5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200660:	8522                	mv	a0,s0
ffffffffc0200662:	e1bff0ef          	jal	ra,ffffffffc020047c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200666:	10043583          	ld	a1,256(s0)
ffffffffc020066a:	00001517          	auipc	a0,0x1
ffffffffc020066e:	74e50513          	addi	a0,a0,1870 # ffffffffc0201db8 <commands+0x5d0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00001517          	auipc	a0,0x1
ffffffffc020067e:	75650513          	addi	a0,a0,1878 # ffffffffc0201dd0 <commands+0x5e8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00001517          	auipc	a0,0x1
ffffffffc020068e:	75e50513          	addi	a0,a0,1886 # ffffffffc0201de8 <commands+0x600>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00001517          	auipc	a0,0x1
ffffffffc02006a2:	76250513          	addi	a0,a0,1890 # ffffffffc0201e00 <commands+0x618>
}
ffffffffc02006a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a8:	a0fff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02006ac <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006ac:	11853783          	ld	a5,280(a0)
ffffffffc02006b0:	577d                	li	a4,-1
ffffffffc02006b2:	8305                	srli	a4,a4,0x1
ffffffffc02006b4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02006b6:	472d                	li	a4,11
ffffffffc02006b8:	08f76563          	bltu	a4,a5,ffffffffc0200742 <interrupt_handler+0x96>
ffffffffc02006bc:	00001717          	auipc	a4,0x1
ffffffffc02006c0:	2e870713          	addi	a4,a4,744 # ffffffffc02019a4 <commands+0x1bc>
ffffffffc02006c4:	078a                	slli	a5,a5,0x2
ffffffffc02006c6:	97ba                	add	a5,a5,a4
ffffffffc02006c8:	439c                	lw	a5,0(a5)
ffffffffc02006ca:	97ba                	add	a5,a5,a4
ffffffffc02006cc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006ce:	00001517          	auipc	a0,0x1
ffffffffc02006d2:	36a50513          	addi	a0,a0,874 # ffffffffc0201a38 <commands+0x250>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	33e50513          	addi	a0,a0,830 # ffffffffc0201a18 <commands+0x230>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	2f250513          	addi	a0,a0,754 # ffffffffc02019d8 <commands+0x1f0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	36650513          	addi	a0,a0,870 # ffffffffc0201a58 <commands+0x270>
ffffffffc02006fa:	9bdff06f          	j	ffffffffc02000b6 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006fe:	1141                	addi	sp,sp,-16
ffffffffc0200700:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200702:	d3fff0ef          	jal	ra,ffffffffc0200440 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200706:	00006797          	auipc	a5,0x6
ffffffffc020070a:	d2a78793          	addi	a5,a5,-726 # ffffffffc0206430 <ticks>
ffffffffc020070e:	639c                	ld	a5,0(a5)
ffffffffc0200710:	06400713          	li	a4,100
ffffffffc0200714:	0785                	addi	a5,a5,1
ffffffffc0200716:	02e7f733          	remu	a4,a5,a4
ffffffffc020071a:	00006697          	auipc	a3,0x6
ffffffffc020071e:	d0f6bb23          	sd	a5,-746(a3) # ffffffffc0206430 <ticks>
ffffffffc0200722:	c315                	beqz	a4,ffffffffc0200746 <interrupt_handler+0x9a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200724:	60a2                	ld	ra,8(sp)
ffffffffc0200726:	0141                	addi	sp,sp,16
ffffffffc0200728:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020072a:	00001517          	auipc	a0,0x1
ffffffffc020072e:	35650513          	addi	a0,a0,854 # ffffffffc0201a80 <commands+0x298>
ffffffffc0200732:	985ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	2c250513          	addi	a0,a0,706 # ffffffffc02019f8 <commands+0x210>
ffffffffc020073e:	979ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00001517          	auipc	a0,0x1
ffffffffc0200750:	32450513          	addi	a0,a0,804 # ffffffffc0201a70 <commands+0x288>
}
ffffffffc0200754:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200756:	961ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020075a <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc020075a:	11853783          	ld	a5,280(a0)
ffffffffc020075e:	0007c863          	bltz	a5,ffffffffc020076e <trap+0x14>
    switch (tf->cause) {
ffffffffc0200762:	472d                	li	a4,11
ffffffffc0200764:	00f76363          	bltu	a4,a5,ffffffffc020076a <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200768:	8082                	ret
            print_trapframe(tf);
ffffffffc020076a:	ee1ff06f          	j	ffffffffc020064a <print_trapframe>
        interrupt_handler(tf);
ffffffffc020076e:	f3fff06f          	j	ffffffffc02006ac <interrupt_handler>
	...

ffffffffc0200774 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200774:	14011073          	csrw	sscratch,sp
ffffffffc0200778:	712d                	addi	sp,sp,-288
ffffffffc020077a:	e002                	sd	zero,0(sp)
ffffffffc020077c:	e406                	sd	ra,8(sp)
ffffffffc020077e:	ec0e                	sd	gp,24(sp)
ffffffffc0200780:	f012                	sd	tp,32(sp)
ffffffffc0200782:	f416                	sd	t0,40(sp)
ffffffffc0200784:	f81a                	sd	t1,48(sp)
ffffffffc0200786:	fc1e                	sd	t2,56(sp)
ffffffffc0200788:	e0a2                	sd	s0,64(sp)
ffffffffc020078a:	e4a6                	sd	s1,72(sp)
ffffffffc020078c:	e8aa                	sd	a0,80(sp)
ffffffffc020078e:	ecae                	sd	a1,88(sp)
ffffffffc0200790:	f0b2                	sd	a2,96(sp)
ffffffffc0200792:	f4b6                	sd	a3,104(sp)
ffffffffc0200794:	f8ba                	sd	a4,112(sp)
ffffffffc0200796:	fcbe                	sd	a5,120(sp)
ffffffffc0200798:	e142                	sd	a6,128(sp)
ffffffffc020079a:	e546                	sd	a7,136(sp)
ffffffffc020079c:	e94a                	sd	s2,144(sp)
ffffffffc020079e:	ed4e                	sd	s3,152(sp)
ffffffffc02007a0:	f152                	sd	s4,160(sp)
ffffffffc02007a2:	f556                	sd	s5,168(sp)
ffffffffc02007a4:	f95a                	sd	s6,176(sp)
ffffffffc02007a6:	fd5e                	sd	s7,184(sp)
ffffffffc02007a8:	e1e2                	sd	s8,192(sp)
ffffffffc02007aa:	e5e6                	sd	s9,200(sp)
ffffffffc02007ac:	e9ea                	sd	s10,208(sp)
ffffffffc02007ae:	edee                	sd	s11,216(sp)
ffffffffc02007b0:	f1f2                	sd	t3,224(sp)
ffffffffc02007b2:	f5f6                	sd	t4,232(sp)
ffffffffc02007b4:	f9fa                	sd	t5,240(sp)
ffffffffc02007b6:	fdfe                	sd	t6,248(sp)
ffffffffc02007b8:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007bc:	100024f3          	csrr	s1,sstatus
ffffffffc02007c0:	14102973          	csrr	s2,sepc
ffffffffc02007c4:	143029f3          	csrr	s3,stval
ffffffffc02007c8:	14202a73          	csrr	s4,scause
ffffffffc02007cc:	e822                	sd	s0,16(sp)
ffffffffc02007ce:	e226                	sd	s1,256(sp)
ffffffffc02007d0:	e64a                	sd	s2,264(sp)
ffffffffc02007d2:	ea4e                	sd	s3,272(sp)
ffffffffc02007d4:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007d6:	850a                	mv	a0,sp
    jal trap
ffffffffc02007d8:	f83ff0ef          	jal	ra,ffffffffc020075a <trap>

ffffffffc02007dc <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007dc:	6492                	ld	s1,256(sp)
ffffffffc02007de:	6932                	ld	s2,264(sp)
ffffffffc02007e0:	10049073          	csrw	sstatus,s1
ffffffffc02007e4:	14191073          	csrw	sepc,s2
ffffffffc02007e8:	60a2                	ld	ra,8(sp)
ffffffffc02007ea:	61e2                	ld	gp,24(sp)
ffffffffc02007ec:	7202                	ld	tp,32(sp)
ffffffffc02007ee:	72a2                	ld	t0,40(sp)
ffffffffc02007f0:	7342                	ld	t1,48(sp)
ffffffffc02007f2:	73e2                	ld	t2,56(sp)
ffffffffc02007f4:	6406                	ld	s0,64(sp)
ffffffffc02007f6:	64a6                	ld	s1,72(sp)
ffffffffc02007f8:	6546                	ld	a0,80(sp)
ffffffffc02007fa:	65e6                	ld	a1,88(sp)
ffffffffc02007fc:	7606                	ld	a2,96(sp)
ffffffffc02007fe:	76a6                	ld	a3,104(sp)
ffffffffc0200800:	7746                	ld	a4,112(sp)
ffffffffc0200802:	77e6                	ld	a5,120(sp)
ffffffffc0200804:	680a                	ld	a6,128(sp)
ffffffffc0200806:	68aa                	ld	a7,136(sp)
ffffffffc0200808:	694a                	ld	s2,144(sp)
ffffffffc020080a:	69ea                	ld	s3,152(sp)
ffffffffc020080c:	7a0a                	ld	s4,160(sp)
ffffffffc020080e:	7aaa                	ld	s5,168(sp)
ffffffffc0200810:	7b4a                	ld	s6,176(sp)
ffffffffc0200812:	7bea                	ld	s7,184(sp)
ffffffffc0200814:	6c0e                	ld	s8,192(sp)
ffffffffc0200816:	6cae                	ld	s9,200(sp)
ffffffffc0200818:	6d4e                	ld	s10,208(sp)
ffffffffc020081a:	6dee                	ld	s11,216(sp)
ffffffffc020081c:	7e0e                	ld	t3,224(sp)
ffffffffc020081e:	7eae                	ld	t4,232(sp)
ffffffffc0200820:	7f4e                	ld	t5,240(sp)
ffffffffc0200822:	7fee                	ld	t6,248(sp)
ffffffffc0200824:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200826:	10200073          	sret

ffffffffc020082a <buddy_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020082a:	00006797          	auipc	a5,0x6
ffffffffc020082e:	c0e78793          	addi	a5,a5,-1010 # ffffffffc0206438 <free_area>
ffffffffc0200832:	e79c                	sd	a5,8(a5)
ffffffffc0200834:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void buddy_init(void)
{
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200836:	0007a823          	sw	zero,16(a5)
}
ffffffffc020083a:	8082                	ret

ffffffffc020083c <buddy_nr_free_pages>:
}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}
ffffffffc020083c:	00006517          	auipc	a0,0x6
ffffffffc0200840:	c0c56503          	lwu	a0,-1012(a0) # ffffffffc0206448 <free_area+0x10>
ffffffffc0200844:	8082                	ret

ffffffffc0200846 <buddy_free_pages>:
    assert(n > 0);
ffffffffc0200846:	10058463          	beqz	a1,ffffffffc020094e <buddy_free_pages+0x108>
    if (!IS_POWER_OF_2(n))
ffffffffc020084a:	fff58793          	addi	a5,a1,-1
ffffffffc020084e:	8fed                	and	a5,a5,a1
ffffffffc0200850:	882e                	mv	a6,a1
ffffffffc0200852:	c395                	beqz	a5,ffffffffc0200876 <buddy_free_pages+0x30>
    while (tmp >>= 1)
ffffffffc0200854:	4015d81b          	sraiw	a6,a1,0x1
ffffffffc0200858:	0e080963          	beqz	a6,ffffffffc020094a <buddy_free_pages+0x104>
    int n = 0, tmp = size;
ffffffffc020085c:	4781                	li	a5,0
ffffffffc020085e:	a011                	j	ffffffffc0200862 <buddy_free_pages+0x1c>
        n++;
ffffffffc0200860:	87ba                	mv	a5,a4
    while (tmp >>= 1)
ffffffffc0200862:	40185813          	srai	a6,a6,0x1
        n++;
ffffffffc0200866:	0017871b          	addiw	a4,a5,1
    while (tmp >>= 1)
ffffffffc020086a:	fe081be3          	bnez	a6,ffffffffc0200860 <buddy_free_pages+0x1a>
ffffffffc020086e:	2789                	addiw	a5,a5,2
ffffffffc0200870:	4805                	li	a6,1
ffffffffc0200872:	00f8183b          	sllw	a6,a6,a5
    int offset = (base - buddy_manager.mem_tree);
ffffffffc0200876:	00006897          	auipc	a7,0x6
ffffffffc020087a:	bda88893          	addi	a7,a7,-1062 # ffffffffc0206450 <buddy_manager>
ffffffffc020087e:	0088b583          	ld	a1,8(a7)
ffffffffc0200882:	00001797          	auipc	a5,0x1
ffffffffc0200886:	6fe78793          	addi	a5,a5,1790 # ffffffffc0201f80 <commands+0x798>
ffffffffc020088a:	639c                	ld	a5,0(a5)
ffffffffc020088c:	40b505b3          	sub	a1,a0,a1
ffffffffc0200890:	858d                	srai	a1,a1,0x3
ffffffffc0200892:	02f585b3          	mul	a1,a1,a5
    index = buddy_manager.total_size + offset - 1;
ffffffffc0200896:	0108a783          	lw	a5,16(a7)
    node_size = 1;
ffffffffc020089a:	4685                	li	a3,1
        if (index == 0)
ffffffffc020089c:	4605                	li	a2,1
    index = buddy_manager.total_size + offset - 1;
ffffffffc020089e:	37fd                	addiw	a5,a5,-1
ffffffffc02008a0:	9fad                	addw	a5,a5,a1
    while (node_size != n)
ffffffffc02008a2:	a811                	j	ffffffffc02008b6 <buddy_free_pages+0x70>
        index = PARENT(index);
ffffffffc02008a4:	37fd                	addiw	a5,a5,-1
ffffffffc02008a6:	0007871b          	sext.w	a4,a5
        node_size *= 2;
ffffffffc02008aa:	0016969b          	slliw	a3,a3,0x1
        index = PARENT(index);
ffffffffc02008ae:	0017d79b          	srliw	a5,a5,0x1
        if (index == 0)
ffffffffc02008b2:	08e67b63          	bleu	a4,a2,ffffffffc0200948 <buddy_free_pages+0x102>
    while (node_size != n)
ffffffffc02008b6:	02069713          	slli	a4,a3,0x20
ffffffffc02008ba:	9301                	srli	a4,a4,0x20
ffffffffc02008bc:	ff0714e3          	bne	a4,a6,ffffffffc02008a4 <buddy_free_pages+0x5e>
    buddy_manager.size[index] = node_size;
ffffffffc02008c0:	0008b303          	ld	t1,0(a7)
ffffffffc02008c4:	02079713          	slli	a4,a5,0x20
ffffffffc02008c8:	8379                	srli	a4,a4,0x1e
ffffffffc02008ca:	971a                	add	a4,a4,t1
ffffffffc02008cc:	c314                	sw	a3,0(a4)
    while (index)
ffffffffc02008ce:	cba1                	beqz	a5,ffffffffc020091e <buddy_free_pages+0xd8>
        index = PARENT(index);
ffffffffc02008d0:	37fd                	addiw	a5,a5,-1
ffffffffc02008d2:	0017d51b          	srliw	a0,a5,0x1
        left_longest = buddy_manager.size[LEFT_LEAF(index)];
ffffffffc02008d6:	ffe7f713          	andi	a4,a5,-2
        right_longest = buddy_manager.size[RIGHT_LEAF(index)];
ffffffffc02008da:	0015061b          	addiw	a2,a0,1
        left_longest = buddy_manager.size[LEFT_LEAF(index)];
ffffffffc02008de:	2705                	addiw	a4,a4,1
        right_longest = buddy_manager.size[RIGHT_LEAF(index)];
ffffffffc02008e0:	0016161b          	slliw	a2,a2,0x1
        left_longest = buddy_manager.size[LEFT_LEAF(index)];
ffffffffc02008e4:	1702                	slli	a4,a4,0x20
        right_longest = buddy_manager.size[RIGHT_LEAF(index)];
ffffffffc02008e6:	1602                	slli	a2,a2,0x20
        left_longest = buddy_manager.size[LEFT_LEAF(index)];
ffffffffc02008e8:	9301                	srli	a4,a4,0x20
        right_longest = buddy_manager.size[RIGHT_LEAF(index)];
ffffffffc02008ea:	9201                	srli	a2,a2,0x20
        left_longest = buddy_manager.size[LEFT_LEAF(index)];
ffffffffc02008ec:	070a                	slli	a4,a4,0x2
        right_longest = buddy_manager.size[RIGHT_LEAF(index)];
ffffffffc02008ee:	060a                	slli	a2,a2,0x2
        left_longest = buddy_manager.size[LEFT_LEAF(index)];
ffffffffc02008f0:	971a                	add	a4,a4,t1
        right_longest = buddy_manager.size[RIGHT_LEAF(index)];
ffffffffc02008f2:	961a                	add	a2,a2,t1
        left_longest = buddy_manager.size[LEFT_LEAF(index)];
ffffffffc02008f4:	00072883          	lw	a7,0(a4)
        right_longest = buddy_manager.size[RIGHT_LEAF(index)];
ffffffffc02008f8:	4210                	lw	a2,0(a2)
ffffffffc02008fa:	02051713          	slli	a4,a0,0x20
ffffffffc02008fe:	8379                	srli	a4,a4,0x1e
        node_size *= 2;
ffffffffc0200900:	0016969b          	slliw	a3,a3,0x1
        if (left_longest + right_longest == node_size){  //合并
ffffffffc0200904:	00c88ebb          	addw	t4,a7,a2
        index = PARENT(index);
ffffffffc0200908:	0005079b          	sext.w	a5,a0
        if (left_longest + right_longest == node_size){  //合并
ffffffffc020090c:	971a                	add	a4,a4,t1
ffffffffc020090e:	02de8b63          	beq	t4,a3,ffffffffc0200944 <buddy_free_pages+0xfe>
            buddy_manager.size[index] = MAX(left_longest, right_longest);
ffffffffc0200912:	8546                	mv	a0,a7
ffffffffc0200914:	00c8f363          	bleu	a2,a7,ffffffffc020091a <buddy_free_pages+0xd4>
ffffffffc0200918:	8532                	mv	a0,a2
ffffffffc020091a:	c308                	sw	a0,0(a4)
    while (index)
ffffffffc020091c:	fbd5                	bnez	a5,ffffffffc02008d0 <buddy_free_pages+0x8a>
    nr_free+=n;
ffffffffc020091e:	00006797          	auipc	a5,0x6
ffffffffc0200922:	b1a78793          	addi	a5,a5,-1254 # ffffffffc0206438 <free_area>
ffffffffc0200926:	4b9c                	lw	a5,16(a5)
    cprintf("free done at %u with %u pages!\n",offset,n);
ffffffffc0200928:	8642                	mv	a2,a6
ffffffffc020092a:	2581                	sext.w	a1,a1
    nr_free+=n;
ffffffffc020092c:	0107883b          	addw	a6,a5,a6
    cprintf("free done at %u with %u pages!\n",offset,n);
ffffffffc0200930:	00001517          	auipc	a0,0x1
ffffffffc0200934:	69050513          	addi	a0,a0,1680 # ffffffffc0201fc0 <commands+0x7d8>
    nr_free+=n;
ffffffffc0200938:	00006797          	auipc	a5,0x6
ffffffffc020093c:	b107a823          	sw	a6,-1264(a5) # ffffffffc0206448 <free_area+0x10>
    cprintf("free done at %u with %u pages!\n",offset,n);
ffffffffc0200940:	f76ff06f          	j	ffffffffc02000b6 <cprintf>
            buddy_manager.size[index] = node_size;
ffffffffc0200944:	c314                	sw	a3,0(a4)
ffffffffc0200946:	b761                	j	ffffffffc02008ce <buddy_free_pages+0x88>
ffffffffc0200948:	8082                	ret
    while (tmp >>= 1)
ffffffffc020094a:	4809                	li	a6,2
    return (1 << n);
ffffffffc020094c:	b72d                	j	ffffffffc0200876 <buddy_free_pages+0x30>
{
ffffffffc020094e:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200950:	00001697          	auipc	a3,0x1
ffffffffc0200954:	63868693          	addi	a3,a3,1592 # ffffffffc0201f88 <commands+0x7a0>
ffffffffc0200958:	00001617          	auipc	a2,0x1
ffffffffc020095c:	63860613          	addi	a2,a2,1592 # ffffffffc0201f90 <commands+0x7a8>
ffffffffc0200960:	0a500593          	li	a1,165
ffffffffc0200964:	00001517          	auipc	a0,0x1
ffffffffc0200968:	64450513          	addi	a0,a0,1604 # ffffffffc0201fa8 <commands+0x7c0>
{
ffffffffc020096c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020096e:	a3fff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200972 <buddy_alloc_pages>:
{
ffffffffc0200972:	1141                	addi	sp,sp,-16
ffffffffc0200974:	e406                	sd	ra,8(sp)
ffffffffc0200976:	e022                	sd	s0,0(sp)
    assert(n > 0);
ffffffffc0200978:	16050c63          	beqz	a0,ffffffffc0200af0 <buddy_alloc_pages+0x17e>
    if (!IS_POWER_OF_2(n))
ffffffffc020097c:	fff50793          	addi	a5,a0,-1
ffffffffc0200980:	8fe9                	and	a5,a5,a0
ffffffffc0200982:	12079563          	bnez	a5,ffffffffc0200aac <buddy_alloc_pages+0x13a>
    if (n > nr_free)
ffffffffc0200986:	00006797          	auipc	a5,0x6
ffffffffc020098a:	ac27e783          	lwu	a5,-1342(a5) # ffffffffc0206448 <free_area+0x10>
ffffffffc020098e:	14a7e363          	bltu	a5,a0,ffffffffc0200ad4 <buddy_alloc_pages+0x162>
    if (buddy_manager.size[index] < n)
ffffffffc0200992:	00006317          	auipc	t1,0x6
ffffffffc0200996:	abe30313          	addi	t1,t1,-1346 # ffffffffc0206450 <buddy_manager>
ffffffffc020099a:	00033603          	ld	a2,0(t1)
ffffffffc020099e:	00066783          	lwu	a5,0(a2)
ffffffffc02009a2:	12a7e963          	bltu	a5,a0,ffffffffc0200ad4 <buddy_alloc_pages+0x162>
    for (node_size = buddy_manager.total_size; node_size != n; node_size /= 2)
ffffffffc02009a6:	01032583          	lw	a1,16(t1)
ffffffffc02009aa:	02059793          	slli	a5,a1,0x20
ffffffffc02009ae:	9381                	srli	a5,a5,0x20
ffffffffc02009b0:	12f50863          	beq	a0,a5,ffffffffc0200ae0 <buddy_alloc_pages+0x16e>
    unsigned index = 0;
ffffffffc02009b4:	4781                	li	a5,0
        if (buddy_manager.size[LEFT_LEAF(index)] >= n)
ffffffffc02009b6:	0017969b          	slliw	a3,a5,0x1
ffffffffc02009ba:	0016879b          	addiw	a5,a3,1
ffffffffc02009be:	02079713          	slli	a4,a5,0x20
ffffffffc02009c2:	8379                	srli	a4,a4,0x1e
ffffffffc02009c4:	9732                	add	a4,a4,a2
ffffffffc02009c6:	00076703          	lwu	a4,0(a4)
ffffffffc02009ca:	00a77463          	bleu	a0,a4,ffffffffc02009d2 <buddy_alloc_pages+0x60>
            index = RIGHT_LEAF(index);
ffffffffc02009ce:	0026879b          	addiw	a5,a3,2
    for (node_size = buddy_manager.total_size; node_size != n; node_size /= 2)
ffffffffc02009d2:	0015d59b          	srliw	a1,a1,0x1
ffffffffc02009d6:	02059713          	slli	a4,a1,0x20
ffffffffc02009da:	9301                	srli	a4,a4,0x20
ffffffffc02009dc:	fca71de3          	bne	a4,a0,ffffffffc02009b6 <buddy_alloc_pages+0x44>
    offset = (index + 1) * node_size - buddy_manager.total_size;
ffffffffc02009e0:	0017871b          	addiw	a4,a5,1
ffffffffc02009e4:	02b705bb          	mulw	a1,a4,a1
    buddy_manager.size[index] = 0;
ffffffffc02009e8:	02079713          	slli	a4,a5,0x20
ffffffffc02009ec:	8379                	srli	a4,a4,0x1e
ffffffffc02009ee:	9732                	add	a4,a4,a2
ffffffffc02009f0:	00072023          	sw	zero,0(a4)
    offset = (index + 1) * node_size - buddy_manager.total_size;
ffffffffc02009f4:	01032703          	lw	a4,16(t1)
ffffffffc02009f8:	9d99                	subw	a1,a1,a4
    while (index)
ffffffffc02009fa:	c7a9                	beqz	a5,ffffffffc0200a44 <buddy_alloc_pages+0xd2>
        index = PARENT(index);
ffffffffc02009fc:	37fd                	addiw	a5,a5,-1
ffffffffc02009fe:	0017d81b          	srliw	a6,a5,0x1
        buddy_manager.size[index] = MAX(buddy_manager.size[LEFT_LEAF(index)], buddy_manager.size[RIGHT_LEAF(index)]);
ffffffffc0200a02:	ffe7f713          	andi	a4,a5,-2
ffffffffc0200a06:	0018069b          	addiw	a3,a6,1
ffffffffc0200a0a:	0016969b          	slliw	a3,a3,0x1
ffffffffc0200a0e:	2705                	addiw	a4,a4,1
ffffffffc0200a10:	1682                	slli	a3,a3,0x20
ffffffffc0200a12:	1702                	slli	a4,a4,0x20
ffffffffc0200a14:	9281                	srli	a3,a3,0x20
ffffffffc0200a16:	9301                	srli	a4,a4,0x20
ffffffffc0200a18:	068a                	slli	a3,a3,0x2
ffffffffc0200a1a:	070a                	slli	a4,a4,0x2
ffffffffc0200a1c:	9732                	add	a4,a4,a2
ffffffffc0200a1e:	96b2                	add	a3,a3,a2
ffffffffc0200a20:	00072883          	lw	a7,0(a4)
ffffffffc0200a24:	4294                	lw	a3,0(a3)
ffffffffc0200a26:	02081713          	slli	a4,a6,0x20
ffffffffc0200a2a:	8379                	srli	a4,a4,0x1e
ffffffffc0200a2c:	00068e9b          	sext.w	t4,a3
ffffffffc0200a30:	00088e1b          	sext.w	t3,a7
        index = PARENT(index);
ffffffffc0200a34:	0008079b          	sext.w	a5,a6
        buddy_manager.size[index] = MAX(buddy_manager.size[LEFT_LEAF(index)], buddy_manager.size[RIGHT_LEAF(index)]);
ffffffffc0200a38:	9732                	add	a4,a4,a2
ffffffffc0200a3a:	01cef363          	bleu	t3,t4,ffffffffc0200a40 <buddy_alloc_pages+0xce>
ffffffffc0200a3e:	86c6                	mv	a3,a7
ffffffffc0200a40:	c314                	sw	a3,0(a4)
    while (index)
ffffffffc0200a42:	ffcd                	bnez	a5,ffffffffc02009fc <buddy_alloc_pages+0x8a>
    struct Page *base = buddy_manager.mem_tree + offset;
ffffffffc0200a44:	02059713          	slli	a4,a1,0x20
ffffffffc0200a48:	9301                	srli	a4,a4,0x20
ffffffffc0200a4a:	00271793          	slli	a5,a4,0x2
ffffffffc0200a4e:	00833403          	ld	s0,8(t1)
ffffffffc0200a52:	97ba                	add	a5,a5,a4
    for (page = base; page != base + n; page++)
ffffffffc0200a54:	00251713          	slli	a4,a0,0x2
    struct Page *base = buddy_manager.mem_tree + offset;
ffffffffc0200a58:	078e                	slli	a5,a5,0x3
    for (page = base; page != base + n; page++)
ffffffffc0200a5a:	972a                	add	a4,a4,a0
    struct Page *base = buddy_manager.mem_tree + offset;
ffffffffc0200a5c:	943e                	add	s0,s0,a5
    for (page = base; page != base + n; page++)
ffffffffc0200a5e:	070e                	slli	a4,a4,0x3
ffffffffc0200a60:	9722                	add	a4,a4,s0
ffffffffc0200a62:	87a2                	mv	a5,s0
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200a64:	56f5                	li	a3,-3
ffffffffc0200a66:	00e40a63          	beq	s0,a4,ffffffffc0200a7a <buddy_alloc_pages+0x108>
ffffffffc0200a6a:	00878613          	addi	a2,a5,8
ffffffffc0200a6e:	60d6302f          	amoand.d	zero,a3,(a2)
ffffffffc0200a72:	02878793          	addi	a5,a5,40
ffffffffc0200a76:	fee79ae3          	bne	a5,a4,ffffffffc0200a6a <buddy_alloc_pages+0xf8>
    nr_free -= n;
ffffffffc0200a7a:	00006797          	auipc	a5,0x6
ffffffffc0200a7e:	9be78793          	addi	a5,a5,-1602 # ffffffffc0206438 <free_area>
ffffffffc0200a82:	4b9c                	lw	a5,16(a5)
ffffffffc0200a84:	0005071b          	sext.w	a4,a0
    cprintf("alloc done at %u with %u pages\n",offset,n);
ffffffffc0200a88:	862a                	mv	a2,a0
    nr_free -= n;
ffffffffc0200a8a:	9f99                	subw	a5,a5,a4
ffffffffc0200a8c:	00006697          	auipc	a3,0x6
ffffffffc0200a90:	9af6ae23          	sw	a5,-1604(a3) # ffffffffc0206448 <free_area+0x10>
    base->property = n;  //用n来保存分配的页数，n为2的幂
ffffffffc0200a94:	c818                	sw	a4,16(s0)
    cprintf("alloc done at %u with %u pages\n",offset,n);
ffffffffc0200a96:	00001517          	auipc	a0,0x1
ffffffffc0200a9a:	38250513          	addi	a0,a0,898 # ffffffffc0201e18 <commands+0x630>
ffffffffc0200a9e:	e18ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
}
ffffffffc0200aa2:	8522                	mv	a0,s0
ffffffffc0200aa4:	60a2                	ld	ra,8(sp)
ffffffffc0200aa6:	6402                	ld	s0,0(sp)
ffffffffc0200aa8:	0141                	addi	sp,sp,16
ffffffffc0200aaa:	8082                	ret
    while (tmp >>= 1)
ffffffffc0200aac:	4015551b          	sraiw	a0,a0,0x1
ffffffffc0200ab0:	cd15                	beqz	a0,ffffffffc0200aec <buddy_alloc_pages+0x17a>
    int n = 0, tmp = size;
ffffffffc0200ab2:	4781                	li	a5,0
ffffffffc0200ab4:	a011                	j	ffffffffc0200ab8 <buddy_alloc_pages+0x146>
        n++;
ffffffffc0200ab6:	87ba                	mv	a5,a4
    while (tmp >>= 1)
ffffffffc0200ab8:	8505                	srai	a0,a0,0x1
        n++;
ffffffffc0200aba:	0017871b          	addiw	a4,a5,1
    while (tmp >>= 1)
ffffffffc0200abe:	fd65                	bnez	a0,ffffffffc0200ab6 <buddy_alloc_pages+0x144>
ffffffffc0200ac0:	2789                	addiw	a5,a5,2
ffffffffc0200ac2:	4505                	li	a0,1
ffffffffc0200ac4:	00f5153b          	sllw	a0,a0,a5
    if (n > nr_free)
ffffffffc0200ac8:	00006797          	auipc	a5,0x6
ffffffffc0200acc:	9807e783          	lwu	a5,-1664(a5) # ffffffffc0206448 <free_area+0x10>
ffffffffc0200ad0:	eca7f1e3          	bleu	a0,a5,ffffffffc0200992 <buddy_alloc_pages+0x20>
        return NULL;
ffffffffc0200ad4:	4401                	li	s0,0
}
ffffffffc0200ad6:	8522                	mv	a0,s0
ffffffffc0200ad8:	60a2                	ld	ra,8(sp)
ffffffffc0200ada:	6402                	ld	s0,0(sp)
ffffffffc0200adc:	0141                	addi	sp,sp,16
ffffffffc0200ade:	8082                	ret
    buddy_manager.size[index] = 0;
ffffffffc0200ae0:	00062023          	sw	zero,0(a2)
    offset = (index + 1) * node_size - buddy_manager.total_size;
ffffffffc0200ae4:	01032783          	lw	a5,16(t1)
ffffffffc0200ae8:	9d9d                	subw	a1,a1,a5
    while (index)
ffffffffc0200aea:	bfa9                	j	ffffffffc0200a44 <buddy_alloc_pages+0xd2>
    while (tmp >>= 1)
ffffffffc0200aec:	4509                	li	a0,2
    return (1 << n);
ffffffffc0200aee:	bd61                	j	ffffffffc0200986 <buddy_alloc_pages+0x14>
    assert(n > 0);
ffffffffc0200af0:	00001697          	auipc	a3,0x1
ffffffffc0200af4:	49868693          	addi	a3,a3,1176 # ffffffffc0201f88 <commands+0x7a0>
ffffffffc0200af8:	00001617          	auipc	a2,0x1
ffffffffc0200afc:	49860613          	addi	a2,a2,1176 # ffffffffc0201f90 <commands+0x7a8>
ffffffffc0200b00:	06c00593          	li	a1,108
ffffffffc0200b04:	00001517          	auipc	a0,0x1
ffffffffc0200b08:	4a450513          	addi	a0,a0,1188 # ffffffffc0201fa8 <commands+0x7c0>
ffffffffc0200b0c:	8a1ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200b10 <buddy_init_memmap>:
{
ffffffffc0200b10:	1141                	addi	sp,sp,-16
ffffffffc0200b12:	e406                	sd	ra,8(sp)
ffffffffc0200b14:	e022                	sd	s0,0(sp)
    assert(n > 0);
ffffffffc0200b16:	c5e5                	beqz	a1,ffffffffc0200bfe <buddy_init_memmap+0xee>
    int n = 0, tmp = size;
ffffffffc0200b18:	0005841b          	sext.w	s0,a1
    while (tmp >>= 1)
ffffffffc0200b1c:	40145793          	srai	a5,s0,0x1
ffffffffc0200b20:	cfcd                	beqz	a5,ffffffffc0200bda <buddy_init_memmap+0xca>
    int n = 0, tmp = size;
ffffffffc0200b22:	4701                	li	a4,0
ffffffffc0200b24:	a011                	j	ffffffffc0200b28 <buddy_init_memmap+0x18>
        n++;
ffffffffc0200b26:	8736                	mv	a4,a3
    while (tmp >>= 1)
ffffffffc0200b28:	8785                	srai	a5,a5,0x1
        n++;
ffffffffc0200b2a:	0017069b          	addiw	a3,a4,1
    while (tmp >>= 1)
ffffffffc0200b2e:	ffe5                	bnez	a5,ffffffffc0200b26 <buddy_init_memmap+0x16>
ffffffffc0200b30:	2709                	addiw	a4,a4,2
ffffffffc0200b32:	4605                	li	a2,1
ffffffffc0200b34:	00e6163b          	sllw	a2,a2,a4
    for (; p != base + n; p++)
ffffffffc0200b38:	00259793          	slli	a5,a1,0x2
ffffffffc0200b3c:	97ae                	add	a5,a5,a1
ffffffffc0200b3e:	078e                	slli	a5,a5,0x3
ffffffffc0200b40:	00f506b3          	add	a3,a0,a5
ffffffffc0200b44:	02d50463          	beq	a0,a3,ffffffffc0200b6c <buddy_init_memmap+0x5c>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b48:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0200b4a:	87aa                	mv	a5,a0
ffffffffc0200b4c:	8b05                	andi	a4,a4,1
ffffffffc0200b4e:	e709                	bnez	a4,ffffffffc0200b58 <buddy_init_memmap+0x48>
ffffffffc0200b50:	a079                	j	ffffffffc0200bde <buddy_init_memmap+0xce>
ffffffffc0200b52:	6798                	ld	a4,8(a5)
ffffffffc0200b54:	8b05                	andi	a4,a4,1
ffffffffc0200b56:	c741                	beqz	a4,ffffffffc0200bde <buddy_init_memmap+0xce>
        p->flags = p->property = 0;
ffffffffc0200b58:	0007a823          	sw	zero,16(a5)
ffffffffc0200b5c:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200b60:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc0200b64:	02878793          	addi	a5,a5,40
ffffffffc0200b68:	fed795e3          	bne	a5,a3,ffffffffc0200b52 <buddy_init_memmap+0x42>
    buddy_manager.total_size = round_up_n;
ffffffffc0200b6c:	0006071b          	sext.w	a4,a2
    base->property = n; // 从base开始有n个可用页
ffffffffc0200b70:	c900                	sw	s0,16(a0)
    unsigned node_size = 2 * round_up_n;
ffffffffc0200b72:	0017179b          	slliw	a5,a4,0x1
    buddy_manager.mem_tree = base;
ffffffffc0200b76:	00006897          	auipc	a7,0x6
ffffffffc0200b7a:	8ea8b123          	sd	a0,-1822(a7) # ffffffffc0206458 <buddy_manager+0x8>
    for (int i = 0; i <2 * round_up_n - 1; ++i)
ffffffffc0200b7e:	00161813          	slli	a6,a2,0x1
    buddy_manager.total_size = round_up_n;
ffffffffc0200b82:	00006517          	auipc	a0,0x6
ffffffffc0200b86:	8ce52f23          	sw	a4,-1826(a0) # ffffffffc0206460 <buddy_manager+0x10>
    buddy_manager.size = (unsigned *)p;
ffffffffc0200b8a:	00006517          	auipc	a0,0x6
ffffffffc0200b8e:	8cd53323          	sd	a3,-1850(a0) # ffffffffc0206450 <buddy_manager>
    unsigned node_size = 2 * round_up_n;
ffffffffc0200b92:	0007851b          	sext.w	a0,a5
    for (int i = 0; i <2 * round_up_n - 1; ++i)
ffffffffc0200b96:	387d                	addiw	a6,a6,-1
ffffffffc0200b98:	87b6                	mv	a5,a3
ffffffffc0200b9a:	4701                	li	a4,0
        if (IS_POWER_OF_2(i + 1))
ffffffffc0200b9c:	0017069b          	addiw	a3,a4,1
ffffffffc0200ba0:	8f75                	and	a4,a4,a3
ffffffffc0200ba2:	e319                	bnez	a4,ffffffffc0200ba8 <buddy_init_memmap+0x98>
            node_size /= 2;
ffffffffc0200ba4:	0015551b          	srliw	a0,a0,0x1
        buddy_manager.size[i] = node_size;
ffffffffc0200ba8:	c388                	sw	a0,0(a5)
ffffffffc0200baa:	8736                	mv	a4,a3
ffffffffc0200bac:	0791                	addi	a5,a5,4
    for (int i = 0; i <2 * round_up_n - 1; ++i)
ffffffffc0200bae:	ff0697e3          	bne	a3,a6,ffffffffc0200b9c <buddy_init_memmap+0x8c>
    cprintf("initialized %u pages with a %u size tree\n",n,round_up_n);
ffffffffc0200bb2:	00001517          	auipc	a0,0x1
ffffffffc0200bb6:	43e50513          	addi	a0,a0,1086 # ffffffffc0201ff0 <commands+0x808>
ffffffffc0200bba:	cfcff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    nr_free += n;
ffffffffc0200bbe:	00006797          	auipc	a5,0x6
ffffffffc0200bc2:	87a78793          	addi	a5,a5,-1926 # ffffffffc0206438 <free_area>
ffffffffc0200bc6:	4b9c                	lw	a5,16(a5)
}
ffffffffc0200bc8:	60a2                	ld	ra,8(sp)
    nr_free += n;
ffffffffc0200bca:	9c3d                	addw	s0,s0,a5
ffffffffc0200bcc:	00006797          	auipc	a5,0x6
ffffffffc0200bd0:	8687ae23          	sw	s0,-1924(a5) # ffffffffc0206448 <free_area+0x10>
}
ffffffffc0200bd4:	6402                	ld	s0,0(sp)
ffffffffc0200bd6:	0141                	addi	sp,sp,16
ffffffffc0200bd8:	8082                	ret
    while (tmp >>= 1)
ffffffffc0200bda:	4609                	li	a2,2
ffffffffc0200bdc:	bfb1                	j	ffffffffc0200b38 <buddy_init_memmap+0x28>
        assert(PageReserved(p));
ffffffffc0200bde:	00001697          	auipc	a3,0x1
ffffffffc0200be2:	40268693          	addi	a3,a3,1026 # ffffffffc0201fe0 <commands+0x7f8>
ffffffffc0200be6:	00001617          	auipc	a2,0x1
ffffffffc0200bea:	3aa60613          	addi	a2,a2,938 # ffffffffc0201f90 <commands+0x7a8>
ffffffffc0200bee:	04300593          	li	a1,67
ffffffffc0200bf2:	00001517          	auipc	a0,0x1
ffffffffc0200bf6:	3b650513          	addi	a0,a0,950 # ffffffffc0201fa8 <commands+0x7c0>
ffffffffc0200bfa:	fb2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200bfe:	00001697          	auipc	a3,0x1
ffffffffc0200c02:	38a68693          	addi	a3,a3,906 # ffffffffc0201f88 <commands+0x7a0>
ffffffffc0200c06:	00001617          	auipc	a2,0x1
ffffffffc0200c0a:	38a60613          	addi	a2,a2,906 # ffffffffc0201f90 <commands+0x7a8>
ffffffffc0200c0e:	03d00593          	li	a1,61
ffffffffc0200c12:	00001517          	auipc	a0,0x1
ffffffffc0200c16:	39650513          	addi	a0,a0,918 # ffffffffc0201fa8 <commands+0x7c0>
ffffffffc0200c1a:	f92ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200c1e <buddy_check>:
basic_check(void) {

}

static void
buddy_check(void) {
ffffffffc0200c1e:	7139                	addi	sp,sp,-64
    cprintf("buddy check!\n");
ffffffffc0200c20:	00001517          	auipc	a0,0x1
ffffffffc0200c24:	21850513          	addi	a0,a0,536 # ffffffffc0201e38 <commands+0x650>
buddy_check(void) {
ffffffffc0200c28:	fc06                	sd	ra,56(sp)
ffffffffc0200c2a:	f822                	sd	s0,48(sp)
ffffffffc0200c2c:	f426                	sd	s1,40(sp)
ffffffffc0200c2e:	f04a                	sd	s2,32(sp)
ffffffffc0200c30:	ec4e                	sd	s3,24(sp)
ffffffffc0200c32:	e852                	sd	s4,16(sp)
ffffffffc0200c34:	e456                	sd	s5,8(sp)
ffffffffc0200c36:	e05a                	sd	s6,0(sp)
    cprintf("buddy check!\n");
ffffffffc0200c38:	c7eff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    
    struct Page *p0, *A, *B, *C, *D;
    p0 = A = B = C = D = NULL;

    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c3c:	4505                	li	a0,1
ffffffffc0200c3e:	2c6000ef          	jal	ra,ffffffffc0200f04 <alloc_pages>
ffffffffc0200c42:	1e050163          	beqz	a0,ffffffffc0200e24 <buddy_check+0x206>
ffffffffc0200c46:	84aa                	mv	s1,a0
    assert((A = alloc_page()) != NULL);
ffffffffc0200c48:	4505                	li	a0,1
ffffffffc0200c4a:	2ba000ef          	jal	ra,ffffffffc0200f04 <alloc_pages>
ffffffffc0200c4e:	842a                	mv	s0,a0
ffffffffc0200c50:	24050a63          	beqz	a0,ffffffffc0200ea4 <buddy_check+0x286>
    assert((B = alloc_page()) != NULL);
ffffffffc0200c54:	4505                	li	a0,1
ffffffffc0200c56:	2ae000ef          	jal	ra,ffffffffc0200f04 <alloc_pages>
ffffffffc0200c5a:	892a                	mv	s2,a0
ffffffffc0200c5c:	22050463          	beqz	a0,ffffffffc0200e84 <buddy_check+0x266>


    assert(p0 != A && p0 != B && A != B);
ffffffffc0200c60:	14848263          	beq	s1,s0,ffffffffc0200da4 <buddy_check+0x186>
ffffffffc0200c64:	14a48063          	beq	s1,a0,ffffffffc0200da4 <buddy_check+0x186>
ffffffffc0200c68:	12a40e63          	beq	s0,a0,ffffffffc0200da4 <buddy_check+0x186>
    assert(page_ref(p0) == 0 && page_ref(A) == 0 && page_ref(B) == 0);
ffffffffc0200c6c:	409c                	lw	a5,0(s1)
ffffffffc0200c6e:	14079b63          	bnez	a5,ffffffffc0200dc4 <buddy_check+0x1a6>
ffffffffc0200c72:	401c                	lw	a5,0(s0)
ffffffffc0200c74:	14079863          	bnez	a5,ffffffffc0200dc4 <buddy_check+0x1a6>
ffffffffc0200c78:	411c                	lw	a5,0(a0)
ffffffffc0200c7a:	14079563          	bnez	a5,ffffffffc0200dc4 <buddy_check+0x1a6>
    assert(A==p0+1 && B == A+1);
ffffffffc0200c7e:	02848793          	addi	a5,s1,40
ffffffffc0200c82:	16f41163          	bne	s0,a5,ffffffffc0200de4 <buddy_check+0x1c6>
ffffffffc0200c86:	02840793          	addi	a5,s0,40
ffffffffc0200c8a:	14f51d63          	bne	a0,a5,ffffffffc0200de4 <buddy_check+0x1c6>

    free_page(p0);    
ffffffffc0200c8e:	8526                	mv	a0,s1
ffffffffc0200c90:	4585                	li	a1,1
ffffffffc0200c92:	2b6000ef          	jal	ra,ffffffffc0200f48 <free_pages>
    free_page(A);
ffffffffc0200c96:	8522                	mv	a0,s0
ffffffffc0200c98:	4585                	li	a1,1
ffffffffc0200c9a:	2ae000ef          	jal	ra,ffffffffc0200f48 <free_pages>
    free_page(B);
ffffffffc0200c9e:	4585                	li	a1,1
ffffffffc0200ca0:	854a                	mv	a0,s2
ffffffffc0200ca2:	2a6000ef          	jal	ra,ffffffffc0200f48 <free_pages>
    
    A = alloc_pages(512);
ffffffffc0200ca6:	20000513          	li	a0,512
ffffffffc0200caa:	25a000ef          	jal	ra,ffffffffc0200f04 <alloc_pages>
ffffffffc0200cae:	892a                	mv	s2,a0
    B = alloc_pages(512);
ffffffffc0200cb0:	20000513          	li	a0,512
ffffffffc0200cb4:	250000ef          	jal	ra,ffffffffc0200f04 <alloc_pages>
ffffffffc0200cb8:	842a                	mv	s0,a0
    free_pages(A, 256);
ffffffffc0200cba:	10000593          	li	a1,256
ffffffffc0200cbe:	854a                	mv	a0,s2
ffffffffc0200cc0:	288000ef          	jal	ra,ffffffffc0200f48 <free_pages>
    free_pages(B, 512);
ffffffffc0200cc4:	20000593          	li	a1,512
ffffffffc0200cc8:	8522                	mv	a0,s0
    free_pages(A + 256, 256);
ffffffffc0200cca:	648d                	lui	s1,0x3
    free_pages(B, 512);
ffffffffc0200ccc:	27c000ef          	jal	ra,ffffffffc0200f48 <free_pages>
    free_pages(A + 256, 256);
ffffffffc0200cd0:	80048493          	addi	s1,s1,-2048 # 2800 <BASE_ADDRESS-0xffffffffc01fd800>
ffffffffc0200cd4:	00990533          	add	a0,s2,s1
ffffffffc0200cd8:	10000593          	li	a1,256
ffffffffc0200cdc:	26c000ef          	jal	ra,ffffffffc0200f48 <free_pages>

    
    p0 = alloc_pages(8192);
ffffffffc0200ce0:	6509                	lui	a0,0x2
ffffffffc0200ce2:	222000ef          	jal	ra,ffffffffc0200f04 <alloc_pages>

    assert(p0 == A);
ffffffffc0200ce6:	1ea91f63          	bne	s2,a0,ffffffffc0200ee4 <buddy_check+0x2c6>

    A = alloc_pages(128);
ffffffffc0200cea:	08000513          	li	a0,128
ffffffffc0200cee:	216000ef          	jal	ra,ffffffffc0200f04 <alloc_pages>
ffffffffc0200cf2:	8aaa                	mv	s5,a0
    B = alloc_pages(64);
    // 检查是否相邻

    assert(A + 128 == B);
ffffffffc0200cf4:	6405                	lui	s0,0x1
    B = alloc_pages(64);
ffffffffc0200cf6:	04000513          	li	a0,64
ffffffffc0200cfa:	20a000ef          	jal	ra,ffffffffc0200f04 <alloc_pages>
    assert(A + 128 == B);
ffffffffc0200cfe:	40040993          	addi	s3,s0,1024 # 1400 <BASE_ADDRESS-0xffffffffc01fec00>
ffffffffc0200d02:	013a87b3          	add	a5,s5,s3
    B = alloc_pages(64);
ffffffffc0200d06:	8a2a                	mv	s4,a0
    assert(A + 128 == B);
ffffffffc0200d08:	1af51e63          	bne	a0,a5,ffffffffc0200ec4 <buddy_check+0x2a6>

    
    C = alloc_pages(128);
ffffffffc0200d0c:	08000513          	li	a0,128
ffffffffc0200d10:	1f4000ef          	jal	ra,ffffffffc0200f04 <alloc_pages>


    //检查C有没有和A重叠
    assert(A + 256 == C);
ffffffffc0200d14:	94d6                	add	s1,s1,s5
    C = alloc_pages(128);
ffffffffc0200d16:	8b2a                	mv	s6,a0
    assert(A + 256 == C);
ffffffffc0200d18:	14951663          	bne	a0,s1,ffffffffc0200e64 <buddy_check+0x246>
    
    //释放A
    free_pages(A, 128);
ffffffffc0200d1c:	08000593          	li	a1,128
ffffffffc0200d20:	8556                	mv	a0,s5
ffffffffc0200d22:	226000ef          	jal	ra,ffffffffc0200f48 <free_pages>
    D = alloc_pages(64);
ffffffffc0200d26:	04000513          	li	a0,64
ffffffffc0200d2a:	1da000ef          	jal	ra,ffffffffc0200f04 <alloc_pages>
ffffffffc0200d2e:	84aa                	mv	s1,a0
    cprintf("D %p\n", D);
ffffffffc0200d30:	85aa                	mv	a1,a0

    
    
    // 检查D是否能够使用A刚刚释放的内存
    assert(D + 128 == B);
ffffffffc0200d32:	99a6                	add	s3,s3,s1
    cprintf("D %p\n", D);
ffffffffc0200d34:	00001517          	auipc	a0,0x1
ffffffffc0200d38:	21450513          	addi	a0,a0,532 # ffffffffc0201f48 <commands+0x760>
ffffffffc0200d3c:	b7aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    assert(D + 128 == B);
ffffffffc0200d40:	113a1263          	bne	s4,s3,ffffffffc0200e44 <buddy_check+0x226>
    free_pages(C, 128);
ffffffffc0200d44:	08000593          	li	a1,128
ffffffffc0200d48:	855a                	mv	a0,s6
ffffffffc0200d4a:	1fe000ef          	jal	ra,ffffffffc0200f48 <free_pages>
    C = alloc_pages(64);
ffffffffc0200d4e:	04000513          	li	a0,64
ffffffffc0200d52:	1b2000ef          	jal	ra,ffffffffc0200f04 <alloc_pages>
    // 检查C是否在B、D之间
    assert(C == D + 64 && C == B - 64);
ffffffffc0200d56:	a0040413          	addi	s0,s0,-1536
ffffffffc0200d5a:	008487b3          	add	a5,s1,s0
    C = alloc_pages(64);
ffffffffc0200d5e:	89aa                	mv	s3,a0
    assert(C == D + 64 && C == B - 64);
ffffffffc0200d60:	0af51263          	bne	a0,a5,ffffffffc0200e04 <buddy_check+0x1e6>
ffffffffc0200d64:	408a0433          	sub	s0,s4,s0
ffffffffc0200d68:	08851e63          	bne	a0,s0,ffffffffc0200e04 <buddy_check+0x1e6>
    free_pages(B, 64);
ffffffffc0200d6c:	8552                	mv	a0,s4
ffffffffc0200d6e:	04000593          	li	a1,64
ffffffffc0200d72:	1d6000ef          	jal	ra,ffffffffc0200f48 <free_pages>
    free_pages(D, 64);
ffffffffc0200d76:	8526                	mv	a0,s1
ffffffffc0200d78:	04000593          	li	a1,64
ffffffffc0200d7c:	1cc000ef          	jal	ra,ffffffffc0200f48 <free_pages>
    free_pages(C, 64);
ffffffffc0200d80:	854e                	mv	a0,s3
ffffffffc0200d82:	04000593          	li	a1,64
ffffffffc0200d86:	1c2000ef          	jal	ra,ffffffffc0200f48 <free_pages>
    // 全部释放
    free_pages(p0, 8192);
    
}
ffffffffc0200d8a:	7442                	ld	s0,48(sp)
ffffffffc0200d8c:	70e2                	ld	ra,56(sp)
ffffffffc0200d8e:	74a2                	ld	s1,40(sp)
ffffffffc0200d90:	69e2                	ld	s3,24(sp)
ffffffffc0200d92:	6a42                	ld	s4,16(sp)
ffffffffc0200d94:	6aa2                	ld	s5,8(sp)
ffffffffc0200d96:	6b02                	ld	s6,0(sp)
    free_pages(p0, 8192);
ffffffffc0200d98:	854a                	mv	a0,s2
}
ffffffffc0200d9a:	7902                	ld	s2,32(sp)
    free_pages(p0, 8192);
ffffffffc0200d9c:	6589                	lui	a1,0x2
}
ffffffffc0200d9e:	6121                	addi	sp,sp,64
    free_pages(p0, 8192);
ffffffffc0200da0:	1a80006f          	j	ffffffffc0200f48 <free_pages>
    assert(p0 != A && p0 != B && A != B);
ffffffffc0200da4:	00001697          	auipc	a3,0x1
ffffffffc0200da8:	10468693          	addi	a3,a3,260 # ffffffffc0201ea8 <commands+0x6c0>
ffffffffc0200dac:	00001617          	auipc	a2,0x1
ffffffffc0200db0:	1e460613          	addi	a2,a2,484 # ffffffffc0201f90 <commands+0x7a8>
ffffffffc0200db4:	0f200593          	li	a1,242
ffffffffc0200db8:	00001517          	auipc	a0,0x1
ffffffffc0200dbc:	1f050513          	addi	a0,a0,496 # ffffffffc0201fa8 <commands+0x7c0>
ffffffffc0200dc0:	decff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(A) == 0 && page_ref(B) == 0);
ffffffffc0200dc4:	00001697          	auipc	a3,0x1
ffffffffc0200dc8:	10468693          	addi	a3,a3,260 # ffffffffc0201ec8 <commands+0x6e0>
ffffffffc0200dcc:	00001617          	auipc	a2,0x1
ffffffffc0200dd0:	1c460613          	addi	a2,a2,452 # ffffffffc0201f90 <commands+0x7a8>
ffffffffc0200dd4:	0f300593          	li	a1,243
ffffffffc0200dd8:	00001517          	auipc	a0,0x1
ffffffffc0200ddc:	1d050513          	addi	a0,a0,464 # ffffffffc0201fa8 <commands+0x7c0>
ffffffffc0200de0:	dccff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(A==p0+1 && B == A+1);
ffffffffc0200de4:	00001697          	auipc	a3,0x1
ffffffffc0200de8:	12468693          	addi	a3,a3,292 # ffffffffc0201f08 <commands+0x720>
ffffffffc0200dec:	00001617          	auipc	a2,0x1
ffffffffc0200df0:	1a460613          	addi	a2,a2,420 # ffffffffc0201f90 <commands+0x7a8>
ffffffffc0200df4:	0f400593          	li	a1,244
ffffffffc0200df8:	00001517          	auipc	a0,0x1
ffffffffc0200dfc:	1b050513          	addi	a0,a0,432 # ffffffffc0201fa8 <commands+0x7c0>
ffffffffc0200e00:	dacff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(C == D + 64 && C == B - 64);
ffffffffc0200e04:	00001697          	auipc	a3,0x1
ffffffffc0200e08:	15c68693          	addi	a3,a3,348 # ffffffffc0201f60 <commands+0x778>
ffffffffc0200e0c:	00001617          	auipc	a2,0x1
ffffffffc0200e10:	18460613          	addi	a2,a2,388 # ffffffffc0201f90 <commands+0x7a8>
ffffffffc0200e14:	11e00593          	li	a1,286
ffffffffc0200e18:	00001517          	auipc	a0,0x1
ffffffffc0200e1c:	19050513          	addi	a0,a0,400 # ffffffffc0201fa8 <commands+0x7c0>
ffffffffc0200e20:	d8cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e24:	00001697          	auipc	a3,0x1
ffffffffc0200e28:	02468693          	addi	a3,a3,36 # ffffffffc0201e48 <commands+0x660>
ffffffffc0200e2c:	00001617          	auipc	a2,0x1
ffffffffc0200e30:	16460613          	addi	a2,a2,356 # ffffffffc0201f90 <commands+0x7a8>
ffffffffc0200e34:	0ed00593          	li	a1,237
ffffffffc0200e38:	00001517          	auipc	a0,0x1
ffffffffc0200e3c:	17050513          	addi	a0,a0,368 # ffffffffc0201fa8 <commands+0x7c0>
ffffffffc0200e40:	d6cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(D + 128 == B);
ffffffffc0200e44:	00001697          	auipc	a3,0x1
ffffffffc0200e48:	10c68693          	addi	a3,a3,268 # ffffffffc0201f50 <commands+0x768>
ffffffffc0200e4c:	00001617          	auipc	a2,0x1
ffffffffc0200e50:	14460613          	addi	a2,a2,324 # ffffffffc0201f90 <commands+0x7a8>
ffffffffc0200e54:	11a00593          	li	a1,282
ffffffffc0200e58:	00001517          	auipc	a0,0x1
ffffffffc0200e5c:	15050513          	addi	a0,a0,336 # ffffffffc0201fa8 <commands+0x7c0>
ffffffffc0200e60:	d4cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(A + 256 == C);
ffffffffc0200e64:	00001697          	auipc	a3,0x1
ffffffffc0200e68:	0d468693          	addi	a3,a3,212 # ffffffffc0201f38 <commands+0x750>
ffffffffc0200e6c:	00001617          	auipc	a2,0x1
ffffffffc0200e70:	12460613          	addi	a2,a2,292 # ffffffffc0201f90 <commands+0x7a8>
ffffffffc0200e74:	11000593          	li	a1,272
ffffffffc0200e78:	00001517          	auipc	a0,0x1
ffffffffc0200e7c:	13050513          	addi	a0,a0,304 # ffffffffc0201fa8 <commands+0x7c0>
ffffffffc0200e80:	d2cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((B = alloc_page()) != NULL);
ffffffffc0200e84:	00001697          	auipc	a3,0x1
ffffffffc0200e88:	00468693          	addi	a3,a3,4 # ffffffffc0201e88 <commands+0x6a0>
ffffffffc0200e8c:	00001617          	auipc	a2,0x1
ffffffffc0200e90:	10460613          	addi	a2,a2,260 # ffffffffc0201f90 <commands+0x7a8>
ffffffffc0200e94:	0ef00593          	li	a1,239
ffffffffc0200e98:	00001517          	auipc	a0,0x1
ffffffffc0200e9c:	11050513          	addi	a0,a0,272 # ffffffffc0201fa8 <commands+0x7c0>
ffffffffc0200ea0:	d0cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((A = alloc_page()) != NULL);
ffffffffc0200ea4:	00001697          	auipc	a3,0x1
ffffffffc0200ea8:	fc468693          	addi	a3,a3,-60 # ffffffffc0201e68 <commands+0x680>
ffffffffc0200eac:	00001617          	auipc	a2,0x1
ffffffffc0200eb0:	0e460613          	addi	a2,a2,228 # ffffffffc0201f90 <commands+0x7a8>
ffffffffc0200eb4:	0ee00593          	li	a1,238
ffffffffc0200eb8:	00001517          	auipc	a0,0x1
ffffffffc0200ebc:	0f050513          	addi	a0,a0,240 # ffffffffc0201fa8 <commands+0x7c0>
ffffffffc0200ec0:	cecff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(A + 128 == B);
ffffffffc0200ec4:	00001697          	auipc	a3,0x1
ffffffffc0200ec8:	06468693          	addi	a3,a3,100 # ffffffffc0201f28 <commands+0x740>
ffffffffc0200ecc:	00001617          	auipc	a2,0x1
ffffffffc0200ed0:	0c460613          	addi	a2,a2,196 # ffffffffc0201f90 <commands+0x7a8>
ffffffffc0200ed4:	10900593          	li	a1,265
ffffffffc0200ed8:	00001517          	auipc	a0,0x1
ffffffffc0200edc:	0d050513          	addi	a0,a0,208 # ffffffffc0201fa8 <commands+0x7c0>
ffffffffc0200ee0:	cccff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 == A);
ffffffffc0200ee4:	00001697          	auipc	a3,0x1
ffffffffc0200ee8:	03c68693          	addi	a3,a3,60 # ffffffffc0201f20 <commands+0x738>
ffffffffc0200eec:	00001617          	auipc	a2,0x1
ffffffffc0200ef0:	0a460613          	addi	a2,a2,164 # ffffffffc0201f90 <commands+0x7a8>
ffffffffc0200ef4:	10300593          	li	a1,259
ffffffffc0200ef8:	00001517          	auipc	a0,0x1
ffffffffc0200efc:	0b050513          	addi	a0,a0,176 # ffffffffc0201fa8 <commands+0x7c0>
ffffffffc0200f00:	cacff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200f04 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f04:	100027f3          	csrr	a5,sstatus
ffffffffc0200f08:	8b89                	andi	a5,a5,2
ffffffffc0200f0a:	eb89                	bnez	a5,ffffffffc0200f1c <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200f0c:	00005797          	auipc	a5,0x5
ffffffffc0200f10:	56478793          	addi	a5,a5,1380 # ffffffffc0206470 <pmm_manager>
ffffffffc0200f14:	639c                	ld	a5,0(a5)
ffffffffc0200f16:	0187b303          	ld	t1,24(a5)
ffffffffc0200f1a:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc0200f1c:	1141                	addi	sp,sp,-16
ffffffffc0200f1e:	e406                	sd	ra,8(sp)
ffffffffc0200f20:	e022                	sd	s0,0(sp)
ffffffffc0200f22:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0200f24:	d40ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200f28:	00005797          	auipc	a5,0x5
ffffffffc0200f2c:	54878793          	addi	a5,a5,1352 # ffffffffc0206470 <pmm_manager>
ffffffffc0200f30:	639c                	ld	a5,0(a5)
ffffffffc0200f32:	8522                	mv	a0,s0
ffffffffc0200f34:	6f9c                	ld	a5,24(a5)
ffffffffc0200f36:	9782                	jalr	a5
ffffffffc0200f38:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200f3a:	d24ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200f3e:	8522                	mv	a0,s0
ffffffffc0200f40:	60a2                	ld	ra,8(sp)
ffffffffc0200f42:	6402                	ld	s0,0(sp)
ffffffffc0200f44:	0141                	addi	sp,sp,16
ffffffffc0200f46:	8082                	ret

ffffffffc0200f48 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f48:	100027f3          	csrr	a5,sstatus
ffffffffc0200f4c:	8b89                	andi	a5,a5,2
ffffffffc0200f4e:	eb89                	bnez	a5,ffffffffc0200f60 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200f50:	00005797          	auipc	a5,0x5
ffffffffc0200f54:	52078793          	addi	a5,a5,1312 # ffffffffc0206470 <pmm_manager>
ffffffffc0200f58:	639c                	ld	a5,0(a5)
ffffffffc0200f5a:	0207b303          	ld	t1,32(a5)
ffffffffc0200f5e:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200f60:	1101                	addi	sp,sp,-32
ffffffffc0200f62:	ec06                	sd	ra,24(sp)
ffffffffc0200f64:	e822                	sd	s0,16(sp)
ffffffffc0200f66:	e426                	sd	s1,8(sp)
ffffffffc0200f68:	842a                	mv	s0,a0
ffffffffc0200f6a:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200f6c:	cf8ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200f70:	00005797          	auipc	a5,0x5
ffffffffc0200f74:	50078793          	addi	a5,a5,1280 # ffffffffc0206470 <pmm_manager>
ffffffffc0200f78:	639c                	ld	a5,0(a5)
ffffffffc0200f7a:	85a6                	mv	a1,s1
ffffffffc0200f7c:	8522                	mv	a0,s0
ffffffffc0200f7e:	739c                	ld	a5,32(a5)
ffffffffc0200f80:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200f82:	6442                	ld	s0,16(sp)
ffffffffc0200f84:	60e2                	ld	ra,24(sp)
ffffffffc0200f86:	64a2                	ld	s1,8(sp)
ffffffffc0200f88:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200f8a:	cd4ff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc0200f8e <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200f8e:	00001797          	auipc	a5,0x1
ffffffffc0200f92:	09278793          	addi	a5,a5,146 # ffffffffc0202020 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200f96:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200f98:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200f9a:	00001517          	auipc	a0,0x1
ffffffffc0200f9e:	0d650513          	addi	a0,a0,214 # ffffffffc0202070 <buddy_pmm_manager+0x50>
void pmm_init(void) {
ffffffffc0200fa2:	ec06                	sd	ra,24(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200fa4:	00005717          	auipc	a4,0x5
ffffffffc0200fa8:	4cf73623          	sd	a5,1228(a4) # ffffffffc0206470 <pmm_manager>
void pmm_init(void) {
ffffffffc0200fac:	e822                	sd	s0,16(sp)
ffffffffc0200fae:	e426                	sd	s1,8(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200fb0:	00005417          	auipc	s0,0x5
ffffffffc0200fb4:	4c040413          	addi	s0,s0,1216 # ffffffffc0206470 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fb8:	8feff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc0200fbc:	601c                	ld	a5,0(s0)
ffffffffc0200fbe:	679c                	ld	a5,8(a5)
ffffffffc0200fc0:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200fc2:	57f5                	li	a5,-3
ffffffffc0200fc4:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200fc6:	00001517          	auipc	a0,0x1
ffffffffc0200fca:	0c250513          	addi	a0,a0,194 # ffffffffc0202088 <buddy_pmm_manager+0x68>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200fce:	00005717          	auipc	a4,0x5
ffffffffc0200fd2:	4af73523          	sd	a5,1194(a4) # ffffffffc0206478 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0200fd6:	8e0ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200fda:	46c5                	li	a3,17
ffffffffc0200fdc:	06ee                	slli	a3,a3,0x1b
ffffffffc0200fde:	40100613          	li	a2,1025
ffffffffc0200fe2:	16fd                	addi	a3,a3,-1
ffffffffc0200fe4:	0656                	slli	a2,a2,0x15
ffffffffc0200fe6:	07e005b7          	lui	a1,0x7e00
ffffffffc0200fea:	00001517          	auipc	a0,0x1
ffffffffc0200fee:	0b650513          	addi	a0,a0,182 # ffffffffc02020a0 <buddy_pmm_manager+0x80>
ffffffffc0200ff2:	8c4ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200ff6:	777d                	lui	a4,0xfffff
ffffffffc0200ff8:	00006797          	auipc	a5,0x6
ffffffffc0200ffc:	48f78793          	addi	a5,a5,1167 # ffffffffc0207487 <end+0xfff>
ffffffffc0201000:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201002:	00088737          	lui	a4,0x88
ffffffffc0201006:	00005697          	auipc	a3,0x5
ffffffffc020100a:	40e6b923          	sd	a4,1042(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020100e:	4601                	li	a2,0
ffffffffc0201010:	00005717          	auipc	a4,0x5
ffffffffc0201014:	46f73823          	sd	a5,1136(a4) # ffffffffc0206480 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201018:	4681                	li	a3,0
ffffffffc020101a:	00005897          	auipc	a7,0x5
ffffffffc020101e:	3fe88893          	addi	a7,a7,1022 # ffffffffc0206418 <npage>
ffffffffc0201022:	00005597          	auipc	a1,0x5
ffffffffc0201026:	45e58593          	addi	a1,a1,1118 # ffffffffc0206480 <pages>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020102a:	4805                	li	a6,1
ffffffffc020102c:	fff80537          	lui	a0,0xfff80
ffffffffc0201030:	a011                	j	ffffffffc0201034 <pmm_init+0xa6>
ffffffffc0201032:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc0201034:	97b2                	add	a5,a5,a2
ffffffffc0201036:	07a1                	addi	a5,a5,8
ffffffffc0201038:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020103c:	0008b703          	ld	a4,0(a7)
ffffffffc0201040:	0685                	addi	a3,a3,1
ffffffffc0201042:	02860613          	addi	a2,a2,40
ffffffffc0201046:	00a707b3          	add	a5,a4,a0
ffffffffc020104a:	fef6e4e3          	bltu	a3,a5,ffffffffc0201032 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020104e:	6190                	ld	a2,0(a1)
ffffffffc0201050:	00271793          	slli	a5,a4,0x2
ffffffffc0201054:	97ba                	add	a5,a5,a4
ffffffffc0201056:	fec006b7          	lui	a3,0xfec00
ffffffffc020105a:	078e                	slli	a5,a5,0x3
ffffffffc020105c:	96b2                	add	a3,a3,a2
ffffffffc020105e:	96be                	add	a3,a3,a5
ffffffffc0201060:	c02007b7          	lui	a5,0xc0200
ffffffffc0201064:	08f6e863          	bltu	a3,a5,ffffffffc02010f4 <pmm_init+0x166>
ffffffffc0201068:	00005497          	auipc	s1,0x5
ffffffffc020106c:	41048493          	addi	s1,s1,1040 # ffffffffc0206478 <va_pa_offset>
ffffffffc0201070:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc0201072:	45c5                	li	a1,17
ffffffffc0201074:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201076:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc0201078:	04b6e963          	bltu	a3,a1,ffffffffc02010ca <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020107c:	601c                	ld	a5,0(s0)
ffffffffc020107e:	7b9c                	ld	a5,48(a5)
ffffffffc0201080:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201082:	00001517          	auipc	a0,0x1
ffffffffc0201086:	0b650513          	addi	a0,a0,182 # ffffffffc0202138 <buddy_pmm_manager+0x118>
ffffffffc020108a:	82cff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc020108e:	00004697          	auipc	a3,0x4
ffffffffc0201092:	f7268693          	addi	a3,a3,-142 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0201096:	00005797          	auipc	a5,0x5
ffffffffc020109a:	38d7b523          	sd	a3,906(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc020109e:	c02007b7          	lui	a5,0xc0200
ffffffffc02010a2:	06f6e563          	bltu	a3,a5,ffffffffc020110c <pmm_init+0x17e>
ffffffffc02010a6:	609c                	ld	a5,0(s1)
}
ffffffffc02010a8:	6442                	ld	s0,16(sp)
ffffffffc02010aa:	60e2                	ld	ra,24(sp)
ffffffffc02010ac:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02010ae:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc02010b0:	8e9d                	sub	a3,a3,a5
ffffffffc02010b2:	00005797          	auipc	a5,0x5
ffffffffc02010b6:	3ad7bb23          	sd	a3,950(a5) # ffffffffc0206468 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02010ba:	00001517          	auipc	a0,0x1
ffffffffc02010be:	09e50513          	addi	a0,a0,158 # ffffffffc0202158 <buddy_pmm_manager+0x138>
ffffffffc02010c2:	8636                	mv	a2,a3
}
ffffffffc02010c4:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02010c6:	ff1fe06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02010ca:	6785                	lui	a5,0x1
ffffffffc02010cc:	17fd                	addi	a5,a5,-1
ffffffffc02010ce:	96be                	add	a3,a3,a5
ffffffffc02010d0:	77fd                	lui	a5,0xfffff
ffffffffc02010d2:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02010d4:	00c6d793          	srli	a5,a3,0xc
ffffffffc02010d8:	04e7f663          	bleu	a4,a5,ffffffffc0201124 <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc02010dc:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02010de:	97aa                	add	a5,a5,a0
ffffffffc02010e0:	00279513          	slli	a0,a5,0x2
ffffffffc02010e4:	953e                	add	a0,a0,a5
ffffffffc02010e6:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02010e8:	8d95                	sub	a1,a1,a3
ffffffffc02010ea:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02010ec:	81b1                	srli	a1,a1,0xc
ffffffffc02010ee:	9532                	add	a0,a0,a2
ffffffffc02010f0:	9782                	jalr	a5
ffffffffc02010f2:	b769                	j	ffffffffc020107c <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02010f4:	00001617          	auipc	a2,0x1
ffffffffc02010f8:	fdc60613          	addi	a2,a2,-36 # ffffffffc02020d0 <buddy_pmm_manager+0xb0>
ffffffffc02010fc:	06f00593          	li	a1,111
ffffffffc0201100:	00001517          	auipc	a0,0x1
ffffffffc0201104:	ff850513          	addi	a0,a0,-8 # ffffffffc02020f8 <buddy_pmm_manager+0xd8>
ffffffffc0201108:	aa4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020110c:	00001617          	auipc	a2,0x1
ffffffffc0201110:	fc460613          	addi	a2,a2,-60 # ffffffffc02020d0 <buddy_pmm_manager+0xb0>
ffffffffc0201114:	08a00593          	li	a1,138
ffffffffc0201118:	00001517          	auipc	a0,0x1
ffffffffc020111c:	fe050513          	addi	a0,a0,-32 # ffffffffc02020f8 <buddy_pmm_manager+0xd8>
ffffffffc0201120:	a8cff0ef          	jal	ra,ffffffffc02003ac <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201124:	00001617          	auipc	a2,0x1
ffffffffc0201128:	fe460613          	addi	a2,a2,-28 # ffffffffc0202108 <buddy_pmm_manager+0xe8>
ffffffffc020112c:	06b00593          	li	a1,107
ffffffffc0201130:	00001517          	auipc	a0,0x1
ffffffffc0201134:	ff850513          	addi	a0,a0,-8 # ffffffffc0202128 <buddy_pmm_manager+0x108>
ffffffffc0201138:	a74ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020113c <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020113c:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201140:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201142:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201146:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201148:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020114c:	f022                	sd	s0,32(sp)
ffffffffc020114e:	ec26                	sd	s1,24(sp)
ffffffffc0201150:	e84a                	sd	s2,16(sp)
ffffffffc0201152:	f406                	sd	ra,40(sp)
ffffffffc0201154:	e44e                	sd	s3,8(sp)
ffffffffc0201156:	84aa                	mv	s1,a0
ffffffffc0201158:	892e                	mv	s2,a1
ffffffffc020115a:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020115e:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0201160:	03067e63          	bleu	a6,a2,ffffffffc020119c <printnum+0x60>
ffffffffc0201164:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201166:	00805763          	blez	s0,ffffffffc0201174 <printnum+0x38>
ffffffffc020116a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020116c:	85ca                	mv	a1,s2
ffffffffc020116e:	854e                	mv	a0,s3
ffffffffc0201170:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201172:	fc65                	bnez	s0,ffffffffc020116a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201174:	1a02                	slli	s4,s4,0x20
ffffffffc0201176:	020a5a13          	srli	s4,s4,0x20
ffffffffc020117a:	00001797          	auipc	a5,0x1
ffffffffc020117e:	1ae78793          	addi	a5,a5,430 # ffffffffc0202328 <error_string+0x38>
ffffffffc0201182:	9a3e                	add	s4,s4,a5
}
ffffffffc0201184:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201186:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020118a:	70a2                	ld	ra,40(sp)
ffffffffc020118c:	69a2                	ld	s3,8(sp)
ffffffffc020118e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201190:	85ca                	mv	a1,s2
ffffffffc0201192:	8326                	mv	t1,s1
}
ffffffffc0201194:	6942                	ld	s2,16(sp)
ffffffffc0201196:	64e2                	ld	s1,24(sp)
ffffffffc0201198:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020119a:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020119c:	03065633          	divu	a2,a2,a6
ffffffffc02011a0:	8722                	mv	a4,s0
ffffffffc02011a2:	f9bff0ef          	jal	ra,ffffffffc020113c <printnum>
ffffffffc02011a6:	b7f9                	j	ffffffffc0201174 <printnum+0x38>

ffffffffc02011a8 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02011a8:	7119                	addi	sp,sp,-128
ffffffffc02011aa:	f4a6                	sd	s1,104(sp)
ffffffffc02011ac:	f0ca                	sd	s2,96(sp)
ffffffffc02011ae:	e8d2                	sd	s4,80(sp)
ffffffffc02011b0:	e4d6                	sd	s5,72(sp)
ffffffffc02011b2:	e0da                	sd	s6,64(sp)
ffffffffc02011b4:	fc5e                	sd	s7,56(sp)
ffffffffc02011b6:	f862                	sd	s8,48(sp)
ffffffffc02011b8:	f06a                	sd	s10,32(sp)
ffffffffc02011ba:	fc86                	sd	ra,120(sp)
ffffffffc02011bc:	f8a2                	sd	s0,112(sp)
ffffffffc02011be:	ecce                	sd	s3,88(sp)
ffffffffc02011c0:	f466                	sd	s9,40(sp)
ffffffffc02011c2:	ec6e                	sd	s11,24(sp)
ffffffffc02011c4:	892a                	mv	s2,a0
ffffffffc02011c6:	84ae                	mv	s1,a1
ffffffffc02011c8:	8d32                	mv	s10,a2
ffffffffc02011ca:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02011cc:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011ce:	00001a17          	auipc	s4,0x1
ffffffffc02011d2:	fcaa0a13          	addi	s4,s4,-54 # ffffffffc0202198 <buddy_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02011d6:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02011da:	00001c17          	auipc	s8,0x1
ffffffffc02011de:	116c0c13          	addi	s8,s8,278 # ffffffffc02022f0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011e2:	000d4503          	lbu	a0,0(s10)
ffffffffc02011e6:	02500793          	li	a5,37
ffffffffc02011ea:	001d0413          	addi	s0,s10,1
ffffffffc02011ee:	00f50e63          	beq	a0,a5,ffffffffc020120a <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02011f2:	c521                	beqz	a0,ffffffffc020123a <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011f4:	02500993          	li	s3,37
ffffffffc02011f8:	a011                	j	ffffffffc02011fc <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc02011fa:	c121                	beqz	a0,ffffffffc020123a <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc02011fc:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011fe:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201200:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201202:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201206:	ff351ae3          	bne	a0,s3,ffffffffc02011fa <vprintfmt+0x52>
ffffffffc020120a:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020120e:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201212:	4981                	li	s3,0
ffffffffc0201214:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0201216:	5cfd                	li	s9,-1
ffffffffc0201218:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020121a:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc020121e:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201220:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0201224:	0ff6f693          	andi	a3,a3,255
ffffffffc0201228:	00140d13          	addi	s10,s0,1
ffffffffc020122c:	20d5e563          	bltu	a1,a3,ffffffffc0201436 <vprintfmt+0x28e>
ffffffffc0201230:	068a                	slli	a3,a3,0x2
ffffffffc0201232:	96d2                	add	a3,a3,s4
ffffffffc0201234:	4294                	lw	a3,0(a3)
ffffffffc0201236:	96d2                	add	a3,a3,s4
ffffffffc0201238:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020123a:	70e6                	ld	ra,120(sp)
ffffffffc020123c:	7446                	ld	s0,112(sp)
ffffffffc020123e:	74a6                	ld	s1,104(sp)
ffffffffc0201240:	7906                	ld	s2,96(sp)
ffffffffc0201242:	69e6                	ld	s3,88(sp)
ffffffffc0201244:	6a46                	ld	s4,80(sp)
ffffffffc0201246:	6aa6                	ld	s5,72(sp)
ffffffffc0201248:	6b06                	ld	s6,64(sp)
ffffffffc020124a:	7be2                	ld	s7,56(sp)
ffffffffc020124c:	7c42                	ld	s8,48(sp)
ffffffffc020124e:	7ca2                	ld	s9,40(sp)
ffffffffc0201250:	7d02                	ld	s10,32(sp)
ffffffffc0201252:	6de2                	ld	s11,24(sp)
ffffffffc0201254:	6109                	addi	sp,sp,128
ffffffffc0201256:	8082                	ret
    if (lflag >= 2) {
ffffffffc0201258:	4705                	li	a4,1
ffffffffc020125a:	008a8593          	addi	a1,s5,8
ffffffffc020125e:	01074463          	blt	a4,a6,ffffffffc0201266 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0201262:	26080363          	beqz	a6,ffffffffc02014c8 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0201266:	000ab603          	ld	a2,0(s5)
ffffffffc020126a:	46c1                	li	a3,16
ffffffffc020126c:	8aae                	mv	s5,a1
ffffffffc020126e:	a06d                	j	ffffffffc0201318 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0201270:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201274:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201276:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201278:	b765                	j	ffffffffc0201220 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc020127a:	000aa503          	lw	a0,0(s5)
ffffffffc020127e:	85a6                	mv	a1,s1
ffffffffc0201280:	0aa1                	addi	s5,s5,8
ffffffffc0201282:	9902                	jalr	s2
            break;
ffffffffc0201284:	bfb9                	j	ffffffffc02011e2 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201286:	4705                	li	a4,1
ffffffffc0201288:	008a8993          	addi	s3,s5,8
ffffffffc020128c:	01074463          	blt	a4,a6,ffffffffc0201294 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0201290:	22080463          	beqz	a6,ffffffffc02014b8 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0201294:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0201298:	24044463          	bltz	s0,ffffffffc02014e0 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc020129c:	8622                	mv	a2,s0
ffffffffc020129e:	8ace                	mv	s5,s3
ffffffffc02012a0:	46a9                	li	a3,10
ffffffffc02012a2:	a89d                	j	ffffffffc0201318 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02012a4:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02012a8:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02012aa:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02012ac:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02012b0:	8fb5                	xor	a5,a5,a3
ffffffffc02012b2:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02012b6:	1ad74363          	blt	a4,a3,ffffffffc020145c <vprintfmt+0x2b4>
ffffffffc02012ba:	00369793          	slli	a5,a3,0x3
ffffffffc02012be:	97e2                	add	a5,a5,s8
ffffffffc02012c0:	639c                	ld	a5,0(a5)
ffffffffc02012c2:	18078d63          	beqz	a5,ffffffffc020145c <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc02012c6:	86be                	mv	a3,a5
ffffffffc02012c8:	00001617          	auipc	a2,0x1
ffffffffc02012cc:	11060613          	addi	a2,a2,272 # ffffffffc02023d8 <error_string+0xe8>
ffffffffc02012d0:	85a6                	mv	a1,s1
ffffffffc02012d2:	854a                	mv	a0,s2
ffffffffc02012d4:	240000ef          	jal	ra,ffffffffc0201514 <printfmt>
ffffffffc02012d8:	b729                	j	ffffffffc02011e2 <vprintfmt+0x3a>
            lflag ++;
ffffffffc02012da:	00144603          	lbu	a2,1(s0)
ffffffffc02012de:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012e0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02012e2:	bf3d                	j	ffffffffc0201220 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc02012e4:	4705                	li	a4,1
ffffffffc02012e6:	008a8593          	addi	a1,s5,8
ffffffffc02012ea:	01074463          	blt	a4,a6,ffffffffc02012f2 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc02012ee:	1e080263          	beqz	a6,ffffffffc02014d2 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc02012f2:	000ab603          	ld	a2,0(s5)
ffffffffc02012f6:	46a1                	li	a3,8
ffffffffc02012f8:	8aae                	mv	s5,a1
ffffffffc02012fa:	a839                	j	ffffffffc0201318 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc02012fc:	03000513          	li	a0,48
ffffffffc0201300:	85a6                	mv	a1,s1
ffffffffc0201302:	e03e                	sd	a5,0(sp)
ffffffffc0201304:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201306:	85a6                	mv	a1,s1
ffffffffc0201308:	07800513          	li	a0,120
ffffffffc020130c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020130e:	0aa1                	addi	s5,s5,8
ffffffffc0201310:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0201314:	6782                	ld	a5,0(sp)
ffffffffc0201316:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201318:	876e                	mv	a4,s11
ffffffffc020131a:	85a6                	mv	a1,s1
ffffffffc020131c:	854a                	mv	a0,s2
ffffffffc020131e:	e1fff0ef          	jal	ra,ffffffffc020113c <printnum>
            break;
ffffffffc0201322:	b5c1                	j	ffffffffc02011e2 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201324:	000ab603          	ld	a2,0(s5)
ffffffffc0201328:	0aa1                	addi	s5,s5,8
ffffffffc020132a:	1c060663          	beqz	a2,ffffffffc02014f6 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc020132e:	00160413          	addi	s0,a2,1
ffffffffc0201332:	17b05c63          	blez	s11,ffffffffc02014aa <vprintfmt+0x302>
ffffffffc0201336:	02d00593          	li	a1,45
ffffffffc020133a:	14b79263          	bne	a5,a1,ffffffffc020147e <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020133e:	00064783          	lbu	a5,0(a2)
ffffffffc0201342:	0007851b          	sext.w	a0,a5
ffffffffc0201346:	c905                	beqz	a0,ffffffffc0201376 <vprintfmt+0x1ce>
ffffffffc0201348:	000cc563          	bltz	s9,ffffffffc0201352 <vprintfmt+0x1aa>
ffffffffc020134c:	3cfd                	addiw	s9,s9,-1
ffffffffc020134e:	036c8263          	beq	s9,s6,ffffffffc0201372 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0201352:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201354:	18098463          	beqz	s3,ffffffffc02014dc <vprintfmt+0x334>
ffffffffc0201358:	3781                	addiw	a5,a5,-32
ffffffffc020135a:	18fbf163          	bleu	a5,s7,ffffffffc02014dc <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc020135e:	03f00513          	li	a0,63
ffffffffc0201362:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201364:	0405                	addi	s0,s0,1
ffffffffc0201366:	fff44783          	lbu	a5,-1(s0)
ffffffffc020136a:	3dfd                	addiw	s11,s11,-1
ffffffffc020136c:	0007851b          	sext.w	a0,a5
ffffffffc0201370:	fd61                	bnez	a0,ffffffffc0201348 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0201372:	e7b058e3          	blez	s11,ffffffffc02011e2 <vprintfmt+0x3a>
ffffffffc0201376:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201378:	85a6                	mv	a1,s1
ffffffffc020137a:	02000513          	li	a0,32
ffffffffc020137e:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201380:	e60d81e3          	beqz	s11,ffffffffc02011e2 <vprintfmt+0x3a>
ffffffffc0201384:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201386:	85a6                	mv	a1,s1
ffffffffc0201388:	02000513          	li	a0,32
ffffffffc020138c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020138e:	fe0d94e3          	bnez	s11,ffffffffc0201376 <vprintfmt+0x1ce>
ffffffffc0201392:	bd81                	j	ffffffffc02011e2 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201394:	4705                	li	a4,1
ffffffffc0201396:	008a8593          	addi	a1,s5,8
ffffffffc020139a:	01074463          	blt	a4,a6,ffffffffc02013a2 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc020139e:	12080063          	beqz	a6,ffffffffc02014be <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02013a2:	000ab603          	ld	a2,0(s5)
ffffffffc02013a6:	46a9                	li	a3,10
ffffffffc02013a8:	8aae                	mv	s5,a1
ffffffffc02013aa:	b7bd                	j	ffffffffc0201318 <vprintfmt+0x170>
ffffffffc02013ac:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02013b0:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013b4:	846a                	mv	s0,s10
ffffffffc02013b6:	b5ad                	j	ffffffffc0201220 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02013b8:	85a6                	mv	a1,s1
ffffffffc02013ba:	02500513          	li	a0,37
ffffffffc02013be:	9902                	jalr	s2
            break;
ffffffffc02013c0:	b50d                	j	ffffffffc02011e2 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02013c2:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02013c6:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02013ca:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013cc:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02013ce:	e40dd9e3          	bgez	s11,ffffffffc0201220 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02013d2:	8de6                	mv	s11,s9
ffffffffc02013d4:	5cfd                	li	s9,-1
ffffffffc02013d6:	b5a9                	j	ffffffffc0201220 <vprintfmt+0x78>
            goto reswitch;
ffffffffc02013d8:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc02013dc:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013e0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02013e2:	bd3d                	j	ffffffffc0201220 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc02013e4:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc02013e8:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013ec:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02013ee:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02013f2:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02013f6:	fcd56ce3          	bltu	a0,a3,ffffffffc02013ce <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc02013fa:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02013fc:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0201400:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201404:	0196873b          	addw	a4,a3,s9
ffffffffc0201408:	0017171b          	slliw	a4,a4,0x1
ffffffffc020140c:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0201410:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0201414:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201418:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020141c:	fcd57fe3          	bleu	a3,a0,ffffffffc02013fa <vprintfmt+0x252>
ffffffffc0201420:	b77d                	j	ffffffffc02013ce <vprintfmt+0x226>
            if (width < 0)
ffffffffc0201422:	fffdc693          	not	a3,s11
ffffffffc0201426:	96fd                	srai	a3,a3,0x3f
ffffffffc0201428:	00ddfdb3          	and	s11,s11,a3
ffffffffc020142c:	00144603          	lbu	a2,1(s0)
ffffffffc0201430:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201432:	846a                	mv	s0,s10
ffffffffc0201434:	b3f5                	j	ffffffffc0201220 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0201436:	85a6                	mv	a1,s1
ffffffffc0201438:	02500513          	li	a0,37
ffffffffc020143c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020143e:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201442:	02500793          	li	a5,37
ffffffffc0201446:	8d22                	mv	s10,s0
ffffffffc0201448:	d8f70de3          	beq	a4,a5,ffffffffc02011e2 <vprintfmt+0x3a>
ffffffffc020144c:	02500713          	li	a4,37
ffffffffc0201450:	1d7d                	addi	s10,s10,-1
ffffffffc0201452:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0201456:	fee79de3          	bne	a5,a4,ffffffffc0201450 <vprintfmt+0x2a8>
ffffffffc020145a:	b361                	j	ffffffffc02011e2 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020145c:	00001617          	auipc	a2,0x1
ffffffffc0201460:	f6c60613          	addi	a2,a2,-148 # ffffffffc02023c8 <error_string+0xd8>
ffffffffc0201464:	85a6                	mv	a1,s1
ffffffffc0201466:	854a                	mv	a0,s2
ffffffffc0201468:	0ac000ef          	jal	ra,ffffffffc0201514 <printfmt>
ffffffffc020146c:	bb9d                	j	ffffffffc02011e2 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020146e:	00001617          	auipc	a2,0x1
ffffffffc0201472:	f5260613          	addi	a2,a2,-174 # ffffffffc02023c0 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0201476:	00001417          	auipc	s0,0x1
ffffffffc020147a:	f4b40413          	addi	s0,s0,-181 # ffffffffc02023c1 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020147e:	8532                	mv	a0,a2
ffffffffc0201480:	85e6                	mv	a1,s9
ffffffffc0201482:	e032                	sd	a2,0(sp)
ffffffffc0201484:	e43e                	sd	a5,8(sp)
ffffffffc0201486:	1c2000ef          	jal	ra,ffffffffc0201648 <strnlen>
ffffffffc020148a:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020148e:	6602                	ld	a2,0(sp)
ffffffffc0201490:	01b05d63          	blez	s11,ffffffffc02014aa <vprintfmt+0x302>
ffffffffc0201494:	67a2                	ld	a5,8(sp)
ffffffffc0201496:	2781                	sext.w	a5,a5
ffffffffc0201498:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc020149a:	6522                	ld	a0,8(sp)
ffffffffc020149c:	85a6                	mv	a1,s1
ffffffffc020149e:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02014a0:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02014a2:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02014a4:	6602                	ld	a2,0(sp)
ffffffffc02014a6:	fe0d9ae3          	bnez	s11,ffffffffc020149a <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02014aa:	00064783          	lbu	a5,0(a2)
ffffffffc02014ae:	0007851b          	sext.w	a0,a5
ffffffffc02014b2:	e8051be3          	bnez	a0,ffffffffc0201348 <vprintfmt+0x1a0>
ffffffffc02014b6:	b335                	j	ffffffffc02011e2 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02014b8:	000aa403          	lw	s0,0(s5)
ffffffffc02014bc:	bbf1                	j	ffffffffc0201298 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02014be:	000ae603          	lwu	a2,0(s5)
ffffffffc02014c2:	46a9                	li	a3,10
ffffffffc02014c4:	8aae                	mv	s5,a1
ffffffffc02014c6:	bd89                	j	ffffffffc0201318 <vprintfmt+0x170>
ffffffffc02014c8:	000ae603          	lwu	a2,0(s5)
ffffffffc02014cc:	46c1                	li	a3,16
ffffffffc02014ce:	8aae                	mv	s5,a1
ffffffffc02014d0:	b5a1                	j	ffffffffc0201318 <vprintfmt+0x170>
ffffffffc02014d2:	000ae603          	lwu	a2,0(s5)
ffffffffc02014d6:	46a1                	li	a3,8
ffffffffc02014d8:	8aae                	mv	s5,a1
ffffffffc02014da:	bd3d                	j	ffffffffc0201318 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc02014dc:	9902                	jalr	s2
ffffffffc02014de:	b559                	j	ffffffffc0201364 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc02014e0:	85a6                	mv	a1,s1
ffffffffc02014e2:	02d00513          	li	a0,45
ffffffffc02014e6:	e03e                	sd	a5,0(sp)
ffffffffc02014e8:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02014ea:	8ace                	mv	s5,s3
ffffffffc02014ec:	40800633          	neg	a2,s0
ffffffffc02014f0:	46a9                	li	a3,10
ffffffffc02014f2:	6782                	ld	a5,0(sp)
ffffffffc02014f4:	b515                	j	ffffffffc0201318 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc02014f6:	01b05663          	blez	s11,ffffffffc0201502 <vprintfmt+0x35a>
ffffffffc02014fa:	02d00693          	li	a3,45
ffffffffc02014fe:	f6d798e3          	bne	a5,a3,ffffffffc020146e <vprintfmt+0x2c6>
ffffffffc0201502:	00001417          	auipc	s0,0x1
ffffffffc0201506:	ebf40413          	addi	s0,s0,-321 # ffffffffc02023c1 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020150a:	02800513          	li	a0,40
ffffffffc020150e:	02800793          	li	a5,40
ffffffffc0201512:	bd1d                	j	ffffffffc0201348 <vprintfmt+0x1a0>

ffffffffc0201514 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201514:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201516:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020151a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020151c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020151e:	ec06                	sd	ra,24(sp)
ffffffffc0201520:	f83a                	sd	a4,48(sp)
ffffffffc0201522:	fc3e                	sd	a5,56(sp)
ffffffffc0201524:	e0c2                	sd	a6,64(sp)
ffffffffc0201526:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201528:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020152a:	c7fff0ef          	jal	ra,ffffffffc02011a8 <vprintfmt>
}
ffffffffc020152e:	60e2                	ld	ra,24(sp)
ffffffffc0201530:	6161                	addi	sp,sp,80
ffffffffc0201532:	8082                	ret

ffffffffc0201534 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201534:	715d                	addi	sp,sp,-80
ffffffffc0201536:	e486                	sd	ra,72(sp)
ffffffffc0201538:	e0a2                	sd	s0,64(sp)
ffffffffc020153a:	fc26                	sd	s1,56(sp)
ffffffffc020153c:	f84a                	sd	s2,48(sp)
ffffffffc020153e:	f44e                	sd	s3,40(sp)
ffffffffc0201540:	f052                	sd	s4,32(sp)
ffffffffc0201542:	ec56                	sd	s5,24(sp)
ffffffffc0201544:	e85a                	sd	s6,16(sp)
ffffffffc0201546:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201548:	c901                	beqz	a0,ffffffffc0201558 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc020154a:	85aa                	mv	a1,a0
ffffffffc020154c:	00001517          	auipc	a0,0x1
ffffffffc0201550:	e8c50513          	addi	a0,a0,-372 # ffffffffc02023d8 <error_string+0xe8>
ffffffffc0201554:	b63fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc0201558:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020155a:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020155c:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020155e:	4aa9                	li	s5,10
ffffffffc0201560:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201562:	00005b97          	auipc	s7,0x5
ffffffffc0201566:	aaeb8b93          	addi	s7,s7,-1362 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020156a:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020156e:	bc1fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201572:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201574:	00054b63          	bltz	a0,ffffffffc020158a <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201578:	00a95b63          	ble	a0,s2,ffffffffc020158e <readline+0x5a>
ffffffffc020157c:	029a5463          	ble	s1,s4,ffffffffc02015a4 <readline+0x70>
        c = getchar();
ffffffffc0201580:	baffe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201584:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201586:	fe0559e3          	bgez	a0,ffffffffc0201578 <readline+0x44>
            return NULL;
ffffffffc020158a:	4501                	li	a0,0
ffffffffc020158c:	a099                	j	ffffffffc02015d2 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc020158e:	03341463          	bne	s0,s3,ffffffffc02015b6 <readline+0x82>
ffffffffc0201592:	e8b9                	bnez	s1,ffffffffc02015e8 <readline+0xb4>
        c = getchar();
ffffffffc0201594:	b9bfe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201598:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020159a:	fe0548e3          	bltz	a0,ffffffffc020158a <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020159e:	fea958e3          	ble	a0,s2,ffffffffc020158e <readline+0x5a>
ffffffffc02015a2:	4481                	li	s1,0
            cputchar(c);
ffffffffc02015a4:	8522                	mv	a0,s0
ffffffffc02015a6:	b45fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc02015aa:	009b87b3          	add	a5,s7,s1
ffffffffc02015ae:	00878023          	sb	s0,0(a5)
ffffffffc02015b2:	2485                	addiw	s1,s1,1
ffffffffc02015b4:	bf6d                	j	ffffffffc020156e <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02015b6:	01540463          	beq	s0,s5,ffffffffc02015be <readline+0x8a>
ffffffffc02015ba:	fb641ae3          	bne	s0,s6,ffffffffc020156e <readline+0x3a>
            cputchar(c);
ffffffffc02015be:	8522                	mv	a0,s0
ffffffffc02015c0:	b2bfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc02015c4:	00005517          	auipc	a0,0x5
ffffffffc02015c8:	a4c50513          	addi	a0,a0,-1460 # ffffffffc0206010 <edata>
ffffffffc02015cc:	94aa                	add	s1,s1,a0
ffffffffc02015ce:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02015d2:	60a6                	ld	ra,72(sp)
ffffffffc02015d4:	6406                	ld	s0,64(sp)
ffffffffc02015d6:	74e2                	ld	s1,56(sp)
ffffffffc02015d8:	7942                	ld	s2,48(sp)
ffffffffc02015da:	79a2                	ld	s3,40(sp)
ffffffffc02015dc:	7a02                	ld	s4,32(sp)
ffffffffc02015de:	6ae2                	ld	s5,24(sp)
ffffffffc02015e0:	6b42                	ld	s6,16(sp)
ffffffffc02015e2:	6ba2                	ld	s7,8(sp)
ffffffffc02015e4:	6161                	addi	sp,sp,80
ffffffffc02015e6:	8082                	ret
            cputchar(c);
ffffffffc02015e8:	4521                	li	a0,8
ffffffffc02015ea:	b01fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc02015ee:	34fd                	addiw	s1,s1,-1
ffffffffc02015f0:	bfbd                	j	ffffffffc020156e <readline+0x3a>

ffffffffc02015f2 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc02015f2:	00005797          	auipc	a5,0x5
ffffffffc02015f6:	a1678793          	addi	a5,a5,-1514 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc02015fa:	6398                	ld	a4,0(a5)
ffffffffc02015fc:	4781                	li	a5,0
ffffffffc02015fe:	88ba                	mv	a7,a4
ffffffffc0201600:	852a                	mv	a0,a0
ffffffffc0201602:	85be                	mv	a1,a5
ffffffffc0201604:	863e                	mv	a2,a5
ffffffffc0201606:	00000073          	ecall
ffffffffc020160a:	87aa                	mv	a5,a0
}
ffffffffc020160c:	8082                	ret

ffffffffc020160e <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc020160e:	00005797          	auipc	a5,0x5
ffffffffc0201612:	e1a78793          	addi	a5,a5,-486 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201616:	6398                	ld	a4,0(a5)
ffffffffc0201618:	4781                	li	a5,0
ffffffffc020161a:	88ba                	mv	a7,a4
ffffffffc020161c:	852a                	mv	a0,a0
ffffffffc020161e:	85be                	mv	a1,a5
ffffffffc0201620:	863e                	mv	a2,a5
ffffffffc0201622:	00000073          	ecall
ffffffffc0201626:	87aa                	mv	a5,a0
}
ffffffffc0201628:	8082                	ret

ffffffffc020162a <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc020162a:	00005797          	auipc	a5,0x5
ffffffffc020162e:	9d678793          	addi	a5,a5,-1578 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201632:	639c                	ld	a5,0(a5)
ffffffffc0201634:	4501                	li	a0,0
ffffffffc0201636:	88be                	mv	a7,a5
ffffffffc0201638:	852a                	mv	a0,a0
ffffffffc020163a:	85aa                	mv	a1,a0
ffffffffc020163c:	862a                	mv	a2,a0
ffffffffc020163e:	00000073          	ecall
ffffffffc0201642:	852a                	mv	a0,a0
ffffffffc0201644:	2501                	sext.w	a0,a0
ffffffffc0201646:	8082                	ret

ffffffffc0201648 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201648:	c185                	beqz	a1,ffffffffc0201668 <strnlen+0x20>
ffffffffc020164a:	00054783          	lbu	a5,0(a0)
ffffffffc020164e:	cf89                	beqz	a5,ffffffffc0201668 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201650:	4781                	li	a5,0
ffffffffc0201652:	a021                	j	ffffffffc020165a <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201654:	00074703          	lbu	a4,0(a4)
ffffffffc0201658:	c711                	beqz	a4,ffffffffc0201664 <strnlen+0x1c>
        cnt ++;
ffffffffc020165a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020165c:	00f50733          	add	a4,a0,a5
ffffffffc0201660:	fef59ae3          	bne	a1,a5,ffffffffc0201654 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201664:	853e                	mv	a0,a5
ffffffffc0201666:	8082                	ret
    size_t cnt = 0;
ffffffffc0201668:	4781                	li	a5,0
}
ffffffffc020166a:	853e                	mv	a0,a5
ffffffffc020166c:	8082                	ret

ffffffffc020166e <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020166e:	00054783          	lbu	a5,0(a0)
ffffffffc0201672:	0005c703          	lbu	a4,0(a1)
ffffffffc0201676:	cb91                	beqz	a5,ffffffffc020168a <strcmp+0x1c>
ffffffffc0201678:	00e79c63          	bne	a5,a4,ffffffffc0201690 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc020167c:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020167e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201682:	0585                	addi	a1,a1,1
ffffffffc0201684:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201688:	fbe5                	bnez	a5,ffffffffc0201678 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020168a:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020168c:	9d19                	subw	a0,a0,a4
ffffffffc020168e:	8082                	ret
ffffffffc0201690:	0007851b          	sext.w	a0,a5
ffffffffc0201694:	9d19                	subw	a0,a0,a4
ffffffffc0201696:	8082                	ret

ffffffffc0201698 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201698:	00054783          	lbu	a5,0(a0)
ffffffffc020169c:	cb91                	beqz	a5,ffffffffc02016b0 <strchr+0x18>
        if (*s == c) {
ffffffffc020169e:	00b79563          	bne	a5,a1,ffffffffc02016a8 <strchr+0x10>
ffffffffc02016a2:	a809                	j	ffffffffc02016b4 <strchr+0x1c>
ffffffffc02016a4:	00b78763          	beq	a5,a1,ffffffffc02016b2 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02016a8:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02016aa:	00054783          	lbu	a5,0(a0)
ffffffffc02016ae:	fbfd                	bnez	a5,ffffffffc02016a4 <strchr+0xc>
    }
    return NULL;
ffffffffc02016b0:	4501                	li	a0,0
}
ffffffffc02016b2:	8082                	ret
ffffffffc02016b4:	8082                	ret

ffffffffc02016b6 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02016b6:	ca01                	beqz	a2,ffffffffc02016c6 <memset+0x10>
ffffffffc02016b8:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02016ba:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02016bc:	0785                	addi	a5,a5,1
ffffffffc02016be:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02016c2:	fec79de3          	bne	a5,a2,ffffffffc02016bc <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02016c6:	8082                	ret
