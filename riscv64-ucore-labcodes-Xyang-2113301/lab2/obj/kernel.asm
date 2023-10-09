
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
ffffffffc0200042:	44260613          	addi	a2,a2,1090 # ffffffffc0206480 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	5a6010ef          	jal	ra,ffffffffc02015f4 <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00001517          	auipc	a0,0x1
ffffffffc020005a:	5b250513          	addi	a0,a0,1458 # ffffffffc0201608 <etext+0x2>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	0dc000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	663000ef          	jal	ra,ffffffffc0200ecc <pmm_init>

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
ffffffffc02000aa:	03c010ef          	jal	ra,ffffffffc02010e6 <vprintfmt>
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
ffffffffc02000de:	008010ef          	jal	ra,ffffffffc02010e6 <vprintfmt>
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
ffffffffc0200144:	51850513          	addi	a0,a0,1304 # ffffffffc0201658 <etext+0x52>
void print_kerninfo(void) {
ffffffffc0200148:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee858593          	addi	a1,a1,-280 # ffffffffc0200036 <kern_init>
ffffffffc0200156:	00001517          	auipc	a0,0x1
ffffffffc020015a:	52250513          	addi	a0,a0,1314 # ffffffffc0201678 <etext+0x72>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200162:	00001597          	auipc	a1,0x1
ffffffffc0200166:	4a458593          	addi	a1,a1,1188 # ffffffffc0201606 <etext>
ffffffffc020016a:	00001517          	auipc	a0,0x1
ffffffffc020016e:	52e50513          	addi	a0,a0,1326 # ffffffffc0201698 <etext+0x92>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200176:	00006597          	auipc	a1,0x6
ffffffffc020017a:	e9a58593          	addi	a1,a1,-358 # ffffffffc0206010 <edata>
ffffffffc020017e:	00001517          	auipc	a0,0x1
ffffffffc0200182:	53a50513          	addi	a0,a0,1338 # ffffffffc02016b8 <etext+0xb2>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018a:	00006597          	auipc	a1,0x6
ffffffffc020018e:	2f658593          	addi	a1,a1,758 # ffffffffc0206480 <end>
ffffffffc0200192:	00001517          	auipc	a0,0x1
ffffffffc0200196:	54650513          	addi	a0,a0,1350 # ffffffffc02016d8 <etext+0xd2>
ffffffffc020019a:	f1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019e:	00006597          	auipc	a1,0x6
ffffffffc02001a2:	6e158593          	addi	a1,a1,1761 # ffffffffc020687f <end+0x3ff>
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
ffffffffc02001c4:	53850513          	addi	a0,a0,1336 # ffffffffc02016f8 <etext+0xf2>
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
ffffffffc02001d4:	45860613          	addi	a2,a2,1112 # ffffffffc0201628 <etext+0x22>
ffffffffc02001d8:	04e00593          	li	a1,78
ffffffffc02001dc:	00001517          	auipc	a0,0x1
ffffffffc02001e0:	46450513          	addi	a0,a0,1124 # ffffffffc0201640 <etext+0x3a>
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
ffffffffc02001f0:	61c60613          	addi	a2,a2,1564 # ffffffffc0201808 <commands+0xe0>
ffffffffc02001f4:	00001597          	auipc	a1,0x1
ffffffffc02001f8:	63458593          	addi	a1,a1,1588 # ffffffffc0201828 <commands+0x100>
ffffffffc02001fc:	00001517          	auipc	a0,0x1
ffffffffc0200200:	63450513          	addi	a0,a0,1588 # ffffffffc0201830 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200204:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200206:	eb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020020a:	00001617          	auipc	a2,0x1
ffffffffc020020e:	63660613          	addi	a2,a2,1590 # ffffffffc0201840 <commands+0x118>
ffffffffc0200212:	00001597          	auipc	a1,0x1
ffffffffc0200216:	65658593          	addi	a1,a1,1622 # ffffffffc0201868 <commands+0x140>
ffffffffc020021a:	00001517          	auipc	a0,0x1
ffffffffc020021e:	61650513          	addi	a0,a0,1558 # ffffffffc0201830 <commands+0x108>
ffffffffc0200222:	e95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200226:	00001617          	auipc	a2,0x1
ffffffffc020022a:	65260613          	addi	a2,a2,1618 # ffffffffc0201878 <commands+0x150>
ffffffffc020022e:	00001597          	auipc	a1,0x1
ffffffffc0200232:	66a58593          	addi	a1,a1,1642 # ffffffffc0201898 <commands+0x170>
ffffffffc0200236:	00001517          	auipc	a0,0x1
ffffffffc020023a:	5fa50513          	addi	a0,a0,1530 # ffffffffc0201830 <commands+0x108>
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
ffffffffc0200274:	50050513          	addi	a0,a0,1280 # ffffffffc0201770 <commands+0x48>
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
ffffffffc0200296:	50650513          	addi	a0,a0,1286 # ffffffffc0201798 <commands+0x70>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029e:	000c0563          	beqz	s8,ffffffffc02002a8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a2:	8562                	mv	a0,s8
ffffffffc02002a4:	3a6000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002a8:	00001c97          	auipc	s9,0x1
ffffffffc02002ac:	480c8c93          	addi	s9,s9,1152 # ffffffffc0201728 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b0:	00001997          	auipc	s3,0x1
ffffffffc02002b4:	51098993          	addi	s3,s3,1296 # ffffffffc02017c0 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00001917          	auipc	s2,0x1
ffffffffc02002bc:	51090913          	addi	s2,s2,1296 # ffffffffc02017c8 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c2:	00001b17          	auipc	s6,0x1
ffffffffc02002c6:	50eb0b13          	addi	s6,s6,1294 # ffffffffc02017d0 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002ca:	00001a97          	auipc	s5,0x1
ffffffffc02002ce:	55ea8a93          	addi	s5,s5,1374 # ffffffffc0201828 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d4:	854e                	mv	a0,s3
ffffffffc02002d6:	19c010ef          	jal	ra,ffffffffc0201472 <readline>
ffffffffc02002da:	842a                	mv	s0,a0
ffffffffc02002dc:	dd65                	beqz	a0,ffffffffc02002d4 <kmonitor+0x6a>
ffffffffc02002de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e4:	c999                	beqz	a1,ffffffffc02002fa <kmonitor+0x90>
ffffffffc02002e6:	854a                	mv	a0,s2
ffffffffc02002e8:	2ee010ef          	jal	ra,ffffffffc02015d6 <strchr>
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
ffffffffc0200302:	42ad0d13          	addi	s10,s10,1066 # ffffffffc0201728 <commands>
    if (argc == 0) {
ffffffffc0200306:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200308:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	2a0010ef          	jal	ra,ffffffffc02015ac <strcmp>
ffffffffc0200310:	c919                	beqz	a0,ffffffffc0200326 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	09740463          	beq	s0,s7,ffffffffc020039c <kmonitor+0x132>
ffffffffc0200318:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020031c:	6582                	ld	a1,0(sp)
ffffffffc020031e:	0d61                	addi	s10,s10,24
ffffffffc0200320:	28c010ef          	jal	ra,ffffffffc02015ac <strcmp>
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
ffffffffc0200386:	250010ef          	jal	ra,ffffffffc02015d6 <strchr>
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
ffffffffc02003a2:	45250513          	addi	a0,a0,1106 # ffffffffc02017f0 <commands+0xc8>
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
ffffffffc02003e2:	4ca50513          	addi	a0,a0,1226 # ffffffffc02018a8 <commands+0x180>
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
ffffffffc02003f8:	32c50513          	addi	a0,a0,812 # ffffffffc0201720 <etext+0x11a>
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
ffffffffc0200424:	128010ef          	jal	ra,ffffffffc020154c <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00001517          	auipc	a0,0x1
ffffffffc0200436:	49650513          	addi	a0,a0,1174 # ffffffffc02018c8 <commands+0x1a0>
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
ffffffffc020044c:	1000106f          	j	ffffffffc020154c <sbi_set_timer>

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
ffffffffc0200456:	0da0106f          	j	ffffffffc0201530 <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	10e0106f          	j	ffffffffc0201568 <sbi_console_getchar>

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
ffffffffc0200488:	55c50513          	addi	a0,a0,1372 # ffffffffc02019e0 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00001517          	auipc	a0,0x1
ffffffffc0200498:	56450513          	addi	a0,a0,1380 # ffffffffc02019f8 <commands+0x2d0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00001517          	auipc	a0,0x1
ffffffffc02004a6:	56e50513          	addi	a0,a0,1390 # ffffffffc0201a10 <commands+0x2e8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00001517          	auipc	a0,0x1
ffffffffc02004b4:	57850513          	addi	a0,a0,1400 # ffffffffc0201a28 <commands+0x300>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00001517          	auipc	a0,0x1
ffffffffc02004c2:	58250513          	addi	a0,a0,1410 # ffffffffc0201a40 <commands+0x318>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00001517          	auipc	a0,0x1
ffffffffc02004d0:	58c50513          	addi	a0,a0,1420 # ffffffffc0201a58 <commands+0x330>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00001517          	auipc	a0,0x1
ffffffffc02004de:	59650513          	addi	a0,a0,1430 # ffffffffc0201a70 <commands+0x348>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00001517          	auipc	a0,0x1
ffffffffc02004ec:	5a050513          	addi	a0,a0,1440 # ffffffffc0201a88 <commands+0x360>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00001517          	auipc	a0,0x1
ffffffffc02004fa:	5aa50513          	addi	a0,a0,1450 # ffffffffc0201aa0 <commands+0x378>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00001517          	auipc	a0,0x1
ffffffffc0200508:	5b450513          	addi	a0,a0,1460 # ffffffffc0201ab8 <commands+0x390>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00001517          	auipc	a0,0x1
ffffffffc0200516:	5be50513          	addi	a0,a0,1470 # ffffffffc0201ad0 <commands+0x3a8>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00001517          	auipc	a0,0x1
ffffffffc0200524:	5c850513          	addi	a0,a0,1480 # ffffffffc0201ae8 <commands+0x3c0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00001517          	auipc	a0,0x1
ffffffffc0200532:	5d250513          	addi	a0,a0,1490 # ffffffffc0201b00 <commands+0x3d8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00001517          	auipc	a0,0x1
ffffffffc0200540:	5dc50513          	addi	a0,a0,1500 # ffffffffc0201b18 <commands+0x3f0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00001517          	auipc	a0,0x1
ffffffffc020054e:	5e650513          	addi	a0,a0,1510 # ffffffffc0201b30 <commands+0x408>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00001517          	auipc	a0,0x1
ffffffffc020055c:	5f050513          	addi	a0,a0,1520 # ffffffffc0201b48 <commands+0x420>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00001517          	auipc	a0,0x1
ffffffffc020056a:	5fa50513          	addi	a0,a0,1530 # ffffffffc0201b60 <commands+0x438>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00001517          	auipc	a0,0x1
ffffffffc0200578:	60450513          	addi	a0,a0,1540 # ffffffffc0201b78 <commands+0x450>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00001517          	auipc	a0,0x1
ffffffffc0200586:	60e50513          	addi	a0,a0,1550 # ffffffffc0201b90 <commands+0x468>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00001517          	auipc	a0,0x1
ffffffffc0200594:	61850513          	addi	a0,a0,1560 # ffffffffc0201ba8 <commands+0x480>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00001517          	auipc	a0,0x1
ffffffffc02005a2:	62250513          	addi	a0,a0,1570 # ffffffffc0201bc0 <commands+0x498>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00001517          	auipc	a0,0x1
ffffffffc02005b0:	62c50513          	addi	a0,a0,1580 # ffffffffc0201bd8 <commands+0x4b0>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00001517          	auipc	a0,0x1
ffffffffc02005be:	63650513          	addi	a0,a0,1590 # ffffffffc0201bf0 <commands+0x4c8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00001517          	auipc	a0,0x1
ffffffffc02005cc:	64050513          	addi	a0,a0,1600 # ffffffffc0201c08 <commands+0x4e0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00001517          	auipc	a0,0x1
ffffffffc02005da:	64a50513          	addi	a0,a0,1610 # ffffffffc0201c20 <commands+0x4f8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00001517          	auipc	a0,0x1
ffffffffc02005e8:	65450513          	addi	a0,a0,1620 # ffffffffc0201c38 <commands+0x510>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00001517          	auipc	a0,0x1
ffffffffc02005f6:	65e50513          	addi	a0,a0,1630 # ffffffffc0201c50 <commands+0x528>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00001517          	auipc	a0,0x1
ffffffffc0200604:	66850513          	addi	a0,a0,1640 # ffffffffc0201c68 <commands+0x540>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00001517          	auipc	a0,0x1
ffffffffc0200612:	67250513          	addi	a0,a0,1650 # ffffffffc0201c80 <commands+0x558>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00001517          	auipc	a0,0x1
ffffffffc0200620:	67c50513          	addi	a0,a0,1660 # ffffffffc0201c98 <commands+0x570>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00001517          	auipc	a0,0x1
ffffffffc020062e:	68650513          	addi	a0,a0,1670 # ffffffffc0201cb0 <commands+0x588>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00001517          	auipc	a0,0x1
ffffffffc0200640:	68c50513          	addi	a0,a0,1676 # ffffffffc0201cc8 <commands+0x5a0>
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
ffffffffc0200656:	68e50513          	addi	a0,a0,1678 # ffffffffc0201ce0 <commands+0x5b8>
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
ffffffffc020066e:	68e50513          	addi	a0,a0,1678 # ffffffffc0201cf8 <commands+0x5d0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00001517          	auipc	a0,0x1
ffffffffc020067e:	69650513          	addi	a0,a0,1686 # ffffffffc0201d10 <commands+0x5e8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00001517          	auipc	a0,0x1
ffffffffc020068e:	69e50513          	addi	a0,a0,1694 # ffffffffc0201d28 <commands+0x600>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00001517          	auipc	a0,0x1
ffffffffc02006a2:	6a250513          	addi	a0,a0,1698 # ffffffffc0201d40 <commands+0x618>
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
ffffffffc02006c0:	22870713          	addi	a4,a4,552 # ffffffffc02018e4 <commands+0x1bc>
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
ffffffffc02006d2:	2aa50513          	addi	a0,a0,682 # ffffffffc0201978 <commands+0x250>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	27e50513          	addi	a0,a0,638 # ffffffffc0201958 <commands+0x230>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	23250513          	addi	a0,a0,562 # ffffffffc0201918 <commands+0x1f0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	2a650513          	addi	a0,a0,678 # ffffffffc0201998 <commands+0x270>
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
ffffffffc020072e:	29650513          	addi	a0,a0,662 # ffffffffc02019c0 <commands+0x298>
ffffffffc0200732:	985ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	20250513          	addi	a0,a0,514 # ffffffffc0201938 <commands+0x210>
ffffffffc020073e:	979ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00001517          	auipc	a0,0x1
ffffffffc0200750:	26450513          	addi	a0,a0,612 # ffffffffc02019b0 <commands+0x288>
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
ffffffffc0200846:	12058a63          	beqz	a1,ffffffffc020097a <buddy_free_pages+0x134>
    if (!IS_POWER_OF_2(n))
ffffffffc020084a:	fff58793          	addi	a5,a1,-1
ffffffffc020084e:	8fed                	and	a5,a5,a1
ffffffffc0200850:	882e                	mv	a6,a1
ffffffffc0200852:	c395                	beqz	a5,ffffffffc0200876 <buddy_free_pages+0x30>
    while (tmp >>= 1)
ffffffffc0200854:	4015d81b          	sraiw	a6,a1,0x1
ffffffffc0200858:	0e080a63          	beqz	a6,ffffffffc020094c <buddy_free_pages+0x106>
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
ffffffffc0200876:	00006797          	auipc	a5,0x6
ffffffffc020087a:	bda78793          	addi	a5,a5,-1062 # ffffffffc0206450 <buddy_manager>
ffffffffc020087e:	678c                	ld	a1,8(a5)
ffffffffc0200880:	00001717          	auipc	a4,0x1
ffffffffc0200884:	5e870713          	addi	a4,a4,1512 # ffffffffc0201e68 <commands+0x740>
ffffffffc0200888:	6318                	ld	a4,0(a4)
ffffffffc020088a:	40b505b3          	sub	a1,a0,a1
ffffffffc020088e:	858d                	srai	a1,a1,0x3
ffffffffc0200890:	02e585b3          	mul	a1,a1,a4
    index = buddy_manager.size[0] + offset - 1;
ffffffffc0200894:	0007b883          	ld	a7,0(a5)
    for (; node_size != n; index = PARENT(index))
ffffffffc0200898:	4705                	li	a4,1
    index = buddy_manager.size[0] + offset - 1;
ffffffffc020089a:	0008a783          	lw	a5,0(a7)
ffffffffc020089e:	37fd                	addiw	a5,a5,-1
ffffffffc02008a0:	9fad                	addw	a5,a5,a1
    for (; node_size != n; index = PARENT(index))
ffffffffc02008a2:	0ae80363          	beq	a6,a4,ffffffffc0200948 <buddy_free_pages+0x102>
        if (index == 0)
ffffffffc02008a6:	c3c5                	beqz	a5,ffffffffc0200946 <buddy_free_pages+0x100>
        node_size *= 2;
ffffffffc02008a8:	4689                	li	a3,2
ffffffffc02008aa:	a021                	j	ffffffffc02008b2 <buddy_free_pages+0x6c>
ffffffffc02008ac:	0016969b          	slliw	a3,a3,0x1
        if (index == 0)
ffffffffc02008b0:	cbd9                	beqz	a5,ffffffffc0200946 <buddy_free_pages+0x100>
    for (; node_size != n; index = PARENT(index))
ffffffffc02008b2:	02069713          	slli	a4,a3,0x20
ffffffffc02008b6:	37fd                	addiw	a5,a5,-1
ffffffffc02008b8:	9301                	srli	a4,a4,0x20
ffffffffc02008ba:	0017d79b          	srliw	a5,a5,0x1
ffffffffc02008be:	ff0717e3          	bne	a4,a6,ffffffffc02008ac <buddy_free_pages+0x66>
    buddy_manager.size[index] = node_size;
ffffffffc02008c2:	02079713          	slli	a4,a5,0x20
ffffffffc02008c6:	8379                	srli	a4,a4,0x1e
ffffffffc02008c8:	9746                	add	a4,a4,a7
ffffffffc02008ca:	c314                	sw	a3,0(a4)
    while (index)
ffffffffc02008cc:	cba1                	beqz	a5,ffffffffc020091c <buddy_free_pages+0xd6>
        index = PARENT(index);
ffffffffc02008ce:	37fd                	addiw	a5,a5,-1
ffffffffc02008d0:	0017d51b          	srliw	a0,a5,0x1
        left_longest = buddy_manager.size[LEFT_LEAF(index)];
ffffffffc02008d4:	ffe7f713          	andi	a4,a5,-2
        right_longest = buddy_manager.size[RIGHT_LEAF(index)];
ffffffffc02008d8:	0015061b          	addiw	a2,a0,1
        left_longest = buddy_manager.size[LEFT_LEAF(index)];
ffffffffc02008dc:	2705                	addiw	a4,a4,1
        right_longest = buddy_manager.size[RIGHT_LEAF(index)];
ffffffffc02008de:	0016161b          	slliw	a2,a2,0x1
        left_longest = buddy_manager.size[LEFT_LEAF(index)];
ffffffffc02008e2:	1702                	slli	a4,a4,0x20
        right_longest = buddy_manager.size[RIGHT_LEAF(index)];
ffffffffc02008e4:	1602                	slli	a2,a2,0x20
        left_longest = buddy_manager.size[LEFT_LEAF(index)];
ffffffffc02008e6:	9301                	srli	a4,a4,0x20
        right_longest = buddy_manager.size[RIGHT_LEAF(index)];
ffffffffc02008e8:	9201                	srli	a2,a2,0x20
        left_longest = buddy_manager.size[LEFT_LEAF(index)];
ffffffffc02008ea:	070a                	slli	a4,a4,0x2
        right_longest = buddy_manager.size[RIGHT_LEAF(index)];
ffffffffc02008ec:	060a                	slli	a2,a2,0x2
        left_longest = buddy_manager.size[LEFT_LEAF(index)];
ffffffffc02008ee:	9746                	add	a4,a4,a7
        right_longest = buddy_manager.size[RIGHT_LEAF(index)];
ffffffffc02008f0:	9646                	add	a2,a2,a7
        left_longest = buddy_manager.size[LEFT_LEAF(index)];
ffffffffc02008f2:	00072303          	lw	t1,0(a4)
        right_longest = buddy_manager.size[RIGHT_LEAF(index)];
ffffffffc02008f6:	4210                	lw	a2,0(a2)
ffffffffc02008f8:	02051713          	slli	a4,a0,0x20
ffffffffc02008fc:	8379                	srli	a4,a4,0x1e
        node_size *= 2;
ffffffffc02008fe:	0016969b          	slliw	a3,a3,0x1
        if (left_longest + right_longest == node_size)  //合并
ffffffffc0200902:	00c30ebb          	addw	t4,t1,a2
        index = PARENT(index);
ffffffffc0200906:	0005079b          	sext.w	a5,a0
        if (left_longest + right_longest == node_size)  //合并
ffffffffc020090a:	9746                	add	a4,a4,a7
ffffffffc020090c:	02de8b63          	beq	t4,a3,ffffffffc0200942 <buddy_free_pages+0xfc>
            buddy_manager.size[index] = MAX(left_longest, right_longest);
ffffffffc0200910:	851a                	mv	a0,t1
ffffffffc0200912:	00c37363          	bleu	a2,t1,ffffffffc0200918 <buddy_free_pages+0xd2>
ffffffffc0200916:	8532                	mv	a0,a2
ffffffffc0200918:	c308                	sw	a0,0(a4)
    while (index)
ffffffffc020091a:	fbd5                	bnez	a5,ffffffffc02008ce <buddy_free_pages+0x88>
    nr_free+=n;
ffffffffc020091c:	00006797          	auipc	a5,0x6
ffffffffc0200920:	b1c78793          	addi	a5,a5,-1252 # ffffffffc0206438 <free_area>
ffffffffc0200924:	4b9c                	lw	a5,16(a5)
    cprintf("free done at %u with %u pages!\n",offset,n);
ffffffffc0200926:	8642                	mv	a2,a6
ffffffffc0200928:	2581                	sext.w	a1,a1
    nr_free+=n;
ffffffffc020092a:	0107883b          	addw	a6,a5,a6
    cprintf("free done at %u with %u pages!\n",offset,n);
ffffffffc020092e:	00001517          	auipc	a0,0x1
ffffffffc0200932:	57a50513          	addi	a0,a0,1402 # ffffffffc0201ea8 <commands+0x780>
    nr_free+=n;
ffffffffc0200936:	00006797          	auipc	a5,0x6
ffffffffc020093a:	b107a923          	sw	a6,-1262(a5) # ffffffffc0206448 <free_area+0x10>
    cprintf("free done at %u with %u pages!\n",offset,n);
ffffffffc020093e:	f78ff06f          	j	ffffffffc02000b6 <cprintf>
            buddy_manager.size[index] = node_size;
ffffffffc0200942:	c314                	sw	a3,0(a4)
ffffffffc0200944:	b761                	j	ffffffffc02008cc <buddy_free_pages+0x86>
ffffffffc0200946:	8082                	ret
    node_size = 1;
ffffffffc0200948:	4685                	li	a3,1
ffffffffc020094a:	bfa5                	j	ffffffffc02008c2 <buddy_free_pages+0x7c>
    int offset = (base - buddy_manager.mem_tree);
ffffffffc020094c:	00006797          	auipc	a5,0x6
ffffffffc0200950:	b0478793          	addi	a5,a5,-1276 # ffffffffc0206450 <buddy_manager>
ffffffffc0200954:	678c                	ld	a1,8(a5)
ffffffffc0200956:	00001717          	auipc	a4,0x1
ffffffffc020095a:	51270713          	addi	a4,a4,1298 # ffffffffc0201e68 <commands+0x740>
ffffffffc020095e:	6318                	ld	a4,0(a4)
ffffffffc0200960:	40b505b3          	sub	a1,a0,a1
ffffffffc0200964:	858d                	srai	a1,a1,0x3
ffffffffc0200966:	02e585b3          	mul	a1,a1,a4
    index = buddy_manager.size[0] + offset - 1;
ffffffffc020096a:	0007b883          	ld	a7,0(a5)
ffffffffc020096e:	4809                	li	a6,2
ffffffffc0200970:	0008a783          	lw	a5,0(a7)
ffffffffc0200974:	37fd                	addiw	a5,a5,-1
ffffffffc0200976:	9fad                	addw	a5,a5,a1
    for (; node_size != n; index = PARENT(index))
ffffffffc0200978:	b73d                	j	ffffffffc02008a6 <buddy_free_pages+0x60>
{
ffffffffc020097a:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020097c:	00001697          	auipc	a3,0x1
ffffffffc0200980:	4f468693          	addi	a3,a3,1268 # ffffffffc0201e70 <commands+0x748>
ffffffffc0200984:	00001617          	auipc	a2,0x1
ffffffffc0200988:	4f460613          	addi	a2,a2,1268 # ffffffffc0201e78 <commands+0x750>
ffffffffc020098c:	0a500593          	li	a1,165
ffffffffc0200990:	00001517          	auipc	a0,0x1
ffffffffc0200994:	50050513          	addi	a0,a0,1280 # ffffffffc0201e90 <commands+0x768>
{
ffffffffc0200998:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020099a:	a13ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020099e <buddy_alloc_pages>:
{
ffffffffc020099e:	1141                	addi	sp,sp,-16
ffffffffc02009a0:	e406                	sd	ra,8(sp)
ffffffffc02009a2:	e022                	sd	s0,0(sp)
    assert(n > 0);
ffffffffc02009a4:	16050f63          	beqz	a0,ffffffffc0200b22 <buddy_alloc_pages+0x184>
    if (n > nr_free)
ffffffffc02009a8:	00006797          	auipc	a5,0x6
ffffffffc02009ac:	aa07e783          	lwu	a5,-1376(a5) # ffffffffc0206448 <free_area+0x10>
ffffffffc02009b0:	14a7ee63          	bltu	a5,a0,ffffffffc0200b0c <buddy_alloc_pages+0x16e>
    if (!IS_POWER_OF_2(n))
ffffffffc02009b4:	fff50793          	addi	a5,a0,-1
ffffffffc02009b8:	8fe9                	and	a5,a5,a0
ffffffffc02009ba:	10079f63          	bnez	a5,ffffffffc0200ad8 <buddy_alloc_pages+0x13a>
    if (buddy_manager.size[index] < n)
ffffffffc02009be:	00006317          	auipc	t1,0x6
ffffffffc02009c2:	a9230313          	addi	t1,t1,-1390 # ffffffffc0206450 <buddy_manager>
ffffffffc02009c6:	00033603          	ld	a2,0(t1)
ffffffffc02009ca:	420c                	lw	a1,0(a2)
ffffffffc02009cc:	02059793          	slli	a5,a1,0x20
ffffffffc02009d0:	9381                	srli	a5,a5,0x20
ffffffffc02009d2:	12a7ed63          	bltu	a5,a0,ffffffffc0200b0c <buddy_alloc_pages+0x16e>
    for (node_size = buddy_manager.size[0]; node_size != n; node_size /= 2)
ffffffffc02009d6:	14a78163          	beq	a5,a0,ffffffffc0200b18 <buddy_alloc_pages+0x17a>
    unsigned index = 0;
ffffffffc02009da:	4781                	li	a5,0
        if (buddy_manager.size[LEFT_LEAF(index)] >= n)
ffffffffc02009dc:	0017969b          	slliw	a3,a5,0x1
ffffffffc02009e0:	0016879b          	addiw	a5,a3,1
ffffffffc02009e4:	02079713          	slli	a4,a5,0x20
ffffffffc02009e8:	8379                	srli	a4,a4,0x1e
ffffffffc02009ea:	9732                	add	a4,a4,a2
ffffffffc02009ec:	00076703          	lwu	a4,0(a4)
ffffffffc02009f0:	00a77463          	bleu	a0,a4,ffffffffc02009f8 <buddy_alloc_pages+0x5a>
            index = RIGHT_LEAF(index);
ffffffffc02009f4:	0026879b          	addiw	a5,a3,2
    for (node_size = buddy_manager.size[0]; node_size != n; node_size /= 2)
ffffffffc02009f8:	0015d59b          	srliw	a1,a1,0x1
ffffffffc02009fc:	02059713          	slli	a4,a1,0x20
ffffffffc0200a00:	9301                	srli	a4,a4,0x20
ffffffffc0200a02:	fca71de3          	bne	a4,a0,ffffffffc02009dc <buddy_alloc_pages+0x3e>
    offset = (index + 1) * node_size - buddy_manager.size[0];
ffffffffc0200a06:	00178f1b          	addiw	t5,a5,1
ffffffffc0200a0a:	02bf05bb          	mulw	a1,t5,a1
    buddy_manager.size[index] = 0;
ffffffffc0200a0e:	02079713          	slli	a4,a5,0x20
ffffffffc0200a12:	8379                	srli	a4,a4,0x1e
ffffffffc0200a14:	9732                	add	a4,a4,a2
ffffffffc0200a16:	00072023          	sw	zero,0(a4)
    offset = (index + 1) * node_size - buddy_manager.size[0];
ffffffffc0200a1a:	00062f03          	lw	t5,0(a2)
ffffffffc0200a1e:	41e58f3b          	subw	t5,a1,t5
ffffffffc0200a22:	000f059b          	sext.w	a1,t5
    while (index)
ffffffffc0200a26:	c7a9                	beqz	a5,ffffffffc0200a70 <buddy_alloc_pages+0xd2>
        index = PARENT(index);
ffffffffc0200a28:	37fd                	addiw	a5,a5,-1
ffffffffc0200a2a:	0017d81b          	srliw	a6,a5,0x1
        buddy_manager.size[index] = MAX(buddy_manager.size[LEFT_LEAF(index)], buddy_manager.size[RIGHT_LEAF(index)]);
ffffffffc0200a2e:	ffe7f713          	andi	a4,a5,-2
ffffffffc0200a32:	0018069b          	addiw	a3,a6,1
ffffffffc0200a36:	0016969b          	slliw	a3,a3,0x1
ffffffffc0200a3a:	2705                	addiw	a4,a4,1
ffffffffc0200a3c:	1682                	slli	a3,a3,0x20
ffffffffc0200a3e:	1702                	slli	a4,a4,0x20
ffffffffc0200a40:	9281                	srli	a3,a3,0x20
ffffffffc0200a42:	9301                	srli	a4,a4,0x20
ffffffffc0200a44:	068a                	slli	a3,a3,0x2
ffffffffc0200a46:	070a                	slli	a4,a4,0x2
ffffffffc0200a48:	9732                	add	a4,a4,a2
ffffffffc0200a4a:	96b2                	add	a3,a3,a2
ffffffffc0200a4c:	00072883          	lw	a7,0(a4)
ffffffffc0200a50:	4294                	lw	a3,0(a3)
ffffffffc0200a52:	02081713          	slli	a4,a6,0x20
ffffffffc0200a56:	8379                	srli	a4,a4,0x1e
ffffffffc0200a58:	00068e9b          	sext.w	t4,a3
ffffffffc0200a5c:	00088e1b          	sext.w	t3,a7
        index = PARENT(index);
ffffffffc0200a60:	0008079b          	sext.w	a5,a6
        buddy_manager.size[index] = MAX(buddy_manager.size[LEFT_LEAF(index)], buddy_manager.size[RIGHT_LEAF(index)]);
ffffffffc0200a64:	9732                	add	a4,a4,a2
ffffffffc0200a66:	01cef363          	bleu	t3,t4,ffffffffc0200a6c <buddy_alloc_pages+0xce>
ffffffffc0200a6a:	86c6                	mv	a3,a7
ffffffffc0200a6c:	c314                	sw	a3,0(a4)
    while (index)
ffffffffc0200a6e:	ffcd                	bnez	a5,ffffffffc0200a28 <buddy_alloc_pages+0x8a>
ffffffffc0200a70:	020f1793          	slli	a5,t5,0x20
ffffffffc0200a74:	9381                	srli	a5,a5,0x20
    struct Page *base = buddy_manager.mem_tree + offset;
ffffffffc0200a76:	00279713          	slli	a4,a5,0x2
ffffffffc0200a7a:	00833403          	ld	s0,8(t1)
ffffffffc0200a7e:	97ba                	add	a5,a5,a4
    for (page = base; page != base + n; page++)
ffffffffc0200a80:	00251713          	slli	a4,a0,0x2
    struct Page *base = buddy_manager.mem_tree + offset;
ffffffffc0200a84:	078e                	slli	a5,a5,0x3
    for (page = base; page != base + n; page++)
ffffffffc0200a86:	972a                	add	a4,a4,a0
    struct Page *base = buddy_manager.mem_tree + offset;
ffffffffc0200a88:	943e                	add	s0,s0,a5
    for (page = base; page != base + n; page++)
ffffffffc0200a8a:	070e                	slli	a4,a4,0x3
ffffffffc0200a8c:	9722                	add	a4,a4,s0
ffffffffc0200a8e:	87a2                	mv	a5,s0
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200a90:	56f5                	li	a3,-3
ffffffffc0200a92:	00e40a63          	beq	s0,a4,ffffffffc0200aa6 <buddy_alloc_pages+0x108>
ffffffffc0200a96:	00878613          	addi	a2,a5,8
ffffffffc0200a9a:	60d6302f          	amoand.d	zero,a3,(a2)
ffffffffc0200a9e:	02878793          	addi	a5,a5,40
ffffffffc0200aa2:	fee79ae3          	bne	a5,a4,ffffffffc0200a96 <buddy_alloc_pages+0xf8>
    nr_free -= n;
ffffffffc0200aa6:	00006797          	auipc	a5,0x6
ffffffffc0200aaa:	99278793          	addi	a5,a5,-1646 # ffffffffc0206438 <free_area>
ffffffffc0200aae:	4b9c                	lw	a5,16(a5)
ffffffffc0200ab0:	0005071b          	sext.w	a4,a0
    cprintf("alloc done at %u with %u pages\n",offset,n);
ffffffffc0200ab4:	862a                	mv	a2,a0
    nr_free -= n;
ffffffffc0200ab6:	9f99                	subw	a5,a5,a4
ffffffffc0200ab8:	00006697          	auipc	a3,0x6
ffffffffc0200abc:	98f6a823          	sw	a5,-1648(a3) # ffffffffc0206448 <free_area+0x10>
    base->property = n;  //用n来保存分配的页数，n为2的幂
ffffffffc0200ac0:	c818                	sw	a4,16(s0)
    cprintf("alloc done at %u with %u pages\n",offset,n);
ffffffffc0200ac2:	00001517          	auipc	a0,0x1
ffffffffc0200ac6:	29650513          	addi	a0,a0,662 # ffffffffc0201d58 <commands+0x630>
ffffffffc0200aca:	decff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
}
ffffffffc0200ace:	8522                	mv	a0,s0
ffffffffc0200ad0:	60a2                	ld	ra,8(sp)
ffffffffc0200ad2:	6402                	ld	s0,0(sp)
ffffffffc0200ad4:	0141                	addi	sp,sp,16
ffffffffc0200ad6:	8082                	ret
    while (tmp >>= 1)
ffffffffc0200ad8:	4015551b          	sraiw	a0,a0,0x1
ffffffffc0200adc:	c129                	beqz	a0,ffffffffc0200b1e <buddy_alloc_pages+0x180>
    int n = 0, tmp = size;
ffffffffc0200ade:	4781                	li	a5,0
ffffffffc0200ae0:	a011                	j	ffffffffc0200ae4 <buddy_alloc_pages+0x146>
        n++;
ffffffffc0200ae2:	87ba                	mv	a5,a4
    while (tmp >>= 1)
ffffffffc0200ae4:	8505                	srai	a0,a0,0x1
        n++;
ffffffffc0200ae6:	0017871b          	addiw	a4,a5,1
    while (tmp >>= 1)
ffffffffc0200aea:	fd65                	bnez	a0,ffffffffc0200ae2 <buddy_alloc_pages+0x144>
    if (buddy_manager.size[index] < n)
ffffffffc0200aec:	00006317          	auipc	t1,0x6
ffffffffc0200af0:	96430313          	addi	t1,t1,-1692 # ffffffffc0206450 <buddy_manager>
ffffffffc0200af4:	00033603          	ld	a2,0(t1)
ffffffffc0200af8:	2789                	addiw	a5,a5,2
ffffffffc0200afa:	4505                	li	a0,1
ffffffffc0200afc:	420c                	lw	a1,0(a2)
ffffffffc0200afe:	00f5153b          	sllw	a0,a0,a5
ffffffffc0200b02:	02059793          	slli	a5,a1,0x20
ffffffffc0200b06:	9381                	srli	a5,a5,0x20
ffffffffc0200b08:	eca7f7e3          	bleu	a0,a5,ffffffffc02009d6 <buddy_alloc_pages+0x38>
        return NULL;
ffffffffc0200b0c:	4401                	li	s0,0
}
ffffffffc0200b0e:	8522                	mv	a0,s0
ffffffffc0200b10:	60a2                	ld	ra,8(sp)
ffffffffc0200b12:	6402                	ld	s0,0(sp)
ffffffffc0200b14:	0141                	addi	sp,sp,16
ffffffffc0200b16:	8082                	ret
    buddy_manager.size[index] = 0;
ffffffffc0200b18:	00062023          	sw	zero,0(a2)
    while (index)
ffffffffc0200b1c:	bfa9                	j	ffffffffc0200a76 <buddy_alloc_pages+0xd8>
    while (tmp >>= 1)
ffffffffc0200b1e:	4509                	li	a0,2
    return (1 << n);
ffffffffc0200b20:	bd79                	j	ffffffffc02009be <buddy_alloc_pages+0x20>
    assert(n > 0);
ffffffffc0200b22:	00001697          	auipc	a3,0x1
ffffffffc0200b26:	34e68693          	addi	a3,a3,846 # ffffffffc0201e70 <commands+0x748>
ffffffffc0200b2a:	00001617          	auipc	a2,0x1
ffffffffc0200b2e:	34e60613          	addi	a2,a2,846 # ffffffffc0201e78 <commands+0x750>
ffffffffc0200b32:	06f00593          	li	a1,111
ffffffffc0200b36:	00001517          	auipc	a0,0x1
ffffffffc0200b3a:	35a50513          	addi	a0,a0,858 # ffffffffc0201e90 <commands+0x768>
ffffffffc0200b3e:	86fff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200b42 <buddy_init_memmap>:
{
ffffffffc0200b42:	7179                	addi	sp,sp,-48
ffffffffc0200b44:	ec26                	sd	s1,24(sp)
ffffffffc0200b46:	e84a                	sd	s2,16(sp)
ffffffffc0200b48:	84aa                	mv	s1,a0
ffffffffc0200b4a:	892e                	mv	s2,a1
    cprintf("initializing %u pages\n",n);
ffffffffc0200b4c:	00001517          	auipc	a0,0x1
ffffffffc0200b50:	37c50513          	addi	a0,a0,892 # ffffffffc0201ec8 <commands+0x7a0>
{
ffffffffc0200b54:	f406                	sd	ra,40(sp)
ffffffffc0200b56:	f022                	sd	s0,32(sp)
ffffffffc0200b58:	e44e                	sd	s3,8(sp)
ffffffffc0200b5a:	e052                	sd	s4,0(sp)
    cprintf("initializing %u pages\n",n);
ffffffffc0200b5c:	d5aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    assert(n > 0);
ffffffffc0200b60:	10090d63          	beqz	s2,ffffffffc0200c7a <buddy_init_memmap+0x138>
    int n = 0, tmp = size;
ffffffffc0200b64:	0009041b          	sext.w	s0,s2
    while (tmp >>= 1)
ffffffffc0200b68:	40145793          	srai	a5,s0,0x1
ffffffffc0200b6c:	c7ed                	beqz	a5,ffffffffc0200c56 <buddy_init_memmap+0x114>
    int n = 0, tmp = size;
ffffffffc0200b6e:	4701                	li	a4,0
ffffffffc0200b70:	a011                	j	ffffffffc0200b74 <buddy_init_memmap+0x32>
        n++;
ffffffffc0200b72:	8732                	mv	a4,a2
    while (tmp >>= 1)
ffffffffc0200b74:	8785                	srai	a5,a5,0x1
        n++;
ffffffffc0200b76:	0017061b          	addiw	a2,a4,1
    while (tmp >>= 1)
ffffffffc0200b7a:	ffe5                	bnez	a5,ffffffffc0200b72 <buddy_init_memmap+0x30>
ffffffffc0200b7c:	2709                	addiw	a4,a4,2
ffffffffc0200b7e:	4985                	li	s3,1
ffffffffc0200b80:	00e999bb          	sllw	s3,s3,a4
    for (; p != base + n; p++)
ffffffffc0200b84:	00291693          	slli	a3,s2,0x2
ffffffffc0200b88:	96ca                	add	a3,a3,s2
ffffffffc0200b8a:	068e                	slli	a3,a3,0x3
ffffffffc0200b8c:	96a6                	add	a3,a3,s1
ffffffffc0200b8e:	02d48463          	beq	s1,a3,ffffffffc0200bb6 <buddy_init_memmap+0x74>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b92:	6498                	ld	a4,8(s1)
        assert(PageReserved(p));
ffffffffc0200b94:	87a6                	mv	a5,s1
ffffffffc0200b96:	8b05                	andi	a4,a4,1
ffffffffc0200b98:	e709                	bnez	a4,ffffffffc0200ba2 <buddy_init_memmap+0x60>
ffffffffc0200b9a:	a0c1                	j	ffffffffc0200c5a <buddy_init_memmap+0x118>
ffffffffc0200b9c:	6798                	ld	a4,8(a5)
ffffffffc0200b9e:	8b05                	andi	a4,a4,1
ffffffffc0200ba0:	cf4d                	beqz	a4,ffffffffc0200c5a <buddy_init_memmap+0x118>
        p->flags = p->property = 0;
ffffffffc0200ba2:	0007a823          	sw	zero,16(a5)
ffffffffc0200ba6:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200baa:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc0200bae:	02878793          	addi	a5,a5,40
ffffffffc0200bb2:	fed795e3          	bne	a5,a3,ffffffffc0200b9c <buddy_init_memmap+0x5a>
    cprintf("initial done!\n");
ffffffffc0200bb6:	00001517          	auipc	a0,0x1
ffffffffc0200bba:	32a50513          	addi	a0,a0,810 # ffffffffc0201ee0 <commands+0x7b8>
    buddy_manager.mem_tree = base;
ffffffffc0200bbe:	00006797          	auipc	a5,0x6
ffffffffc0200bc2:	8897bd23          	sd	s1,-1894(a5) # ffffffffc0206458 <buddy_manager+0x8>
    buddy_manager.size = (unsigned *)p;
ffffffffc0200bc6:	00006797          	auipc	a5,0x6
ffffffffc0200bca:	88d7b523          	sd	a3,-1910(a5) # ffffffffc0206450 <buddy_manager>
    buddy_manager.mem_tree = base;
ffffffffc0200bce:	00006a17          	auipc	s4,0x6
ffffffffc0200bd2:	882a0a13          	addi	s4,s4,-1918 # ffffffffc0206450 <buddy_manager>
    cprintf("initial done!\n");
ffffffffc0200bd6:	ce0ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    buddy_manager.size[0] = round_up_n;
ffffffffc0200bda:	000a3783          	ld	a5,0(s4)
    base->property = n; // 从base开始有n个可用页
ffffffffc0200bde:	c880                	sw	s0,16(s1)
    buddy_manager.size[0] = round_up_n;
ffffffffc0200be0:	0009891b          	sext.w	s2,s3
ffffffffc0200be4:	0127a023          	sw	s2,0(a5)
    cprintf("total node:%d\n",round_up_n);
ffffffffc0200be8:	85ce                	mv	a1,s3
ffffffffc0200bea:	00001517          	auipc	a0,0x1
ffffffffc0200bee:	30650513          	addi	a0,a0,774 # ffffffffc0201ef0 <commands+0x7c8>
ffffffffc0200bf2:	cc4ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("initializing tree\n");
ffffffffc0200bf6:	00001517          	auipc	a0,0x1
ffffffffc0200bfa:	30a50513          	addi	a0,a0,778 # ffffffffc0201f00 <commands+0x7d8>
    unsigned node_size = 2 * round_up_n;
ffffffffc0200bfe:	0019149b          	slliw	s1,s2,0x1
    cprintf("initializing tree\n");
ffffffffc0200c02:	cb4ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    for (int i = 0; i < round_up_n; ++i)
ffffffffc0200c06:	02098063          	beqz	s3,ffffffffc0200c26 <buddy_init_memmap+0xe4>
ffffffffc0200c0a:	000a3703          	ld	a4,0(s4)
ffffffffc0200c0e:	4781                	li	a5,0
        if (IS_POWER_OF_2(i + 1))
ffffffffc0200c10:	0017869b          	addiw	a3,a5,1
ffffffffc0200c14:	8ff5                	and	a5,a5,a3
ffffffffc0200c16:	e399                	bnez	a5,ffffffffc0200c1c <buddy_init_memmap+0xda>
            node_size /= 2;
ffffffffc0200c18:	0014d49b          	srliw	s1,s1,0x1
        buddy_manager.size[i] = node_size;
ffffffffc0200c1c:	c304                	sw	s1,0(a4)
ffffffffc0200c1e:	87b6                	mv	a5,a3
ffffffffc0200c20:	0711                	addi	a4,a4,4
    for (int i = 0; i < round_up_n; ++i)
ffffffffc0200c22:	ff2697e3          	bne	a3,s2,ffffffffc0200c10 <buddy_init_memmap+0xce>
    cprintf("tree done\n");
ffffffffc0200c26:	00001517          	auipc	a0,0x1
ffffffffc0200c2a:	30250513          	addi	a0,a0,770 # ffffffffc0201f28 <commands+0x800>
ffffffffc0200c2e:	c88ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    nr_free += n;
ffffffffc0200c32:	00006797          	auipc	a5,0x6
ffffffffc0200c36:	80678793          	addi	a5,a5,-2042 # ffffffffc0206438 <free_area>
ffffffffc0200c3a:	4b9c                	lw	a5,16(a5)
}
ffffffffc0200c3c:	70a2                	ld	ra,40(sp)
ffffffffc0200c3e:	64e2                	ld	s1,24(sp)
    nr_free += n;
ffffffffc0200c40:	9c3d                	addw	s0,s0,a5
ffffffffc0200c42:	00006797          	auipc	a5,0x6
ffffffffc0200c46:	8087a323          	sw	s0,-2042(a5) # ffffffffc0206448 <free_area+0x10>
}
ffffffffc0200c4a:	7402                	ld	s0,32(sp)
ffffffffc0200c4c:	6942                	ld	s2,16(sp)
ffffffffc0200c4e:	69a2                	ld	s3,8(sp)
ffffffffc0200c50:	6a02                	ld	s4,0(sp)
ffffffffc0200c52:	6145                	addi	sp,sp,48
ffffffffc0200c54:	8082                	ret
    while (tmp >>= 1)
ffffffffc0200c56:	4989                	li	s3,2
ffffffffc0200c58:	b735                	j	ffffffffc0200b84 <buddy_init_memmap+0x42>
        assert(PageReserved(p));
ffffffffc0200c5a:	00001697          	auipc	a3,0x1
ffffffffc0200c5e:	2be68693          	addi	a3,a3,702 # ffffffffc0201f18 <commands+0x7f0>
ffffffffc0200c62:	00001617          	auipc	a2,0x1
ffffffffc0200c66:	21660613          	addi	a2,a2,534 # ffffffffc0201e78 <commands+0x750>
ffffffffc0200c6a:	04300593          	li	a1,67
ffffffffc0200c6e:	00001517          	auipc	a0,0x1
ffffffffc0200c72:	22250513          	addi	a0,a0,546 # ffffffffc0201e90 <commands+0x768>
ffffffffc0200c76:	f36ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200c7a:	00001697          	auipc	a3,0x1
ffffffffc0200c7e:	1f668693          	addi	a3,a3,502 # ffffffffc0201e70 <commands+0x748>
ffffffffc0200c82:	00001617          	auipc	a2,0x1
ffffffffc0200c86:	1f660613          	addi	a2,a2,502 # ffffffffc0201e78 <commands+0x750>
ffffffffc0200c8a:	03d00593          	li	a1,61
ffffffffc0200c8e:	00001517          	auipc	a0,0x1
ffffffffc0200c92:	20250513          	addi	a0,a0,514 # ffffffffc0201e90 <commands+0x768>
ffffffffc0200c96:	f16ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200c9a <buddy_check>:
basic_check(void) {

}

static void
buddy_check(void) {
ffffffffc0200c9a:	1101                	addi	sp,sp,-32
    cprintf("buddy check!\n");
ffffffffc0200c9c:	00001517          	auipc	a0,0x1
ffffffffc0200ca0:	0dc50513          	addi	a0,a0,220 # ffffffffc0201d78 <commands+0x650>
buddy_check(void) {
ffffffffc0200ca4:	ec06                	sd	ra,24(sp)
ffffffffc0200ca6:	e822                	sd	s0,16(sp)
ffffffffc0200ca8:	e426                	sd	s1,8(sp)
ffffffffc0200caa:	e04a                	sd	s2,0(sp)
    cprintf("buddy check!\n");
ffffffffc0200cac:	c0aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    
    struct Page *p0, *A, *B, *C, *D;
    p0 = A = B = C = D = NULL;

    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cb0:	4505                	li	a0,1
ffffffffc0200cb2:	190000ef          	jal	ra,ffffffffc0200e42 <alloc_pages>
ffffffffc0200cb6:	cd41                	beqz	a0,ffffffffc0200d4e <buddy_check+0xb4>
ffffffffc0200cb8:	842a                	mv	s0,a0
    assert((A = alloc_page()) != NULL);
ffffffffc0200cba:	4505                	li	a0,1
ffffffffc0200cbc:	186000ef          	jal	ra,ffffffffc0200e42 <alloc_pages>
ffffffffc0200cc0:	84aa                	mv	s1,a0
ffffffffc0200cc2:	c531                	beqz	a0,ffffffffc0200d0e <buddy_check+0x74>
    assert((B = alloc_page()) != NULL);
ffffffffc0200cc4:	4505                	li	a0,1
ffffffffc0200cc6:	17c000ef          	jal	ra,ffffffffc0200e42 <alloc_pages>
ffffffffc0200cca:	892a                	mv	s2,a0
ffffffffc0200ccc:	c169                	beqz	a0,ffffffffc0200d8e <buddy_check+0xf4>

    assert(p0 != A && p0 != B && A != B);
ffffffffc0200cce:	06940063          	beq	s0,s1,ffffffffc0200d2e <buddy_check+0x94>
ffffffffc0200cd2:	04a40e63          	beq	s0,a0,ffffffffc0200d2e <buddy_check+0x94>
ffffffffc0200cd6:	04a48c63          	beq	s1,a0,ffffffffc0200d2e <buddy_check+0x94>
    assert(page_ref(p0) == 0 && page_ref(A) == 0 && page_ref(B) == 0);
ffffffffc0200cda:	401c                	lw	a5,0(s0)
ffffffffc0200cdc:	ebc9                	bnez	a5,ffffffffc0200d6e <buddy_check+0xd4>
ffffffffc0200cde:	409c                	lw	a5,0(s1)
ffffffffc0200ce0:	e7d9                	bnez	a5,ffffffffc0200d6e <buddy_check+0xd4>
ffffffffc0200ce2:	411c                	lw	a5,0(a0)
ffffffffc0200ce4:	e7c9                	bnez	a5,ffffffffc0200d6e <buddy_check+0xd4>
    assert(A==p0+1 && B == A+1);
ffffffffc0200ce6:	02840793          	addi	a5,s0,40
ffffffffc0200cea:	0cf48263          	beq	s1,a5,ffffffffc0200dae <buddy_check+0x114>
ffffffffc0200cee:	00001697          	auipc	a3,0x1
ffffffffc0200cf2:	15a68693          	addi	a3,a3,346 # ffffffffc0201e48 <commands+0x720>
ffffffffc0200cf6:	00001617          	auipc	a2,0x1
ffffffffc0200cfa:	18260613          	addi	a2,a2,386 # ffffffffc0201e78 <commands+0x750>
ffffffffc0200cfe:	0eb00593          	li	a1,235
ffffffffc0200d02:	00001517          	auipc	a0,0x1
ffffffffc0200d06:	18e50513          	addi	a0,a0,398 # ffffffffc0201e90 <commands+0x768>
ffffffffc0200d0a:	ea2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((A = alloc_page()) != NULL);
ffffffffc0200d0e:	00001697          	auipc	a3,0x1
ffffffffc0200d12:	09a68693          	addi	a3,a3,154 # ffffffffc0201da8 <commands+0x680>
ffffffffc0200d16:	00001617          	auipc	a2,0x1
ffffffffc0200d1a:	16260613          	addi	a2,a2,354 # ffffffffc0201e78 <commands+0x750>
ffffffffc0200d1e:	0e600593          	li	a1,230
ffffffffc0200d22:	00001517          	auipc	a0,0x1
ffffffffc0200d26:	16e50513          	addi	a0,a0,366 # ffffffffc0201e90 <commands+0x768>
ffffffffc0200d2a:	e82ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != A && p0 != B && A != B);
ffffffffc0200d2e:	00001697          	auipc	a3,0x1
ffffffffc0200d32:	0ba68693          	addi	a3,a3,186 # ffffffffc0201de8 <commands+0x6c0>
ffffffffc0200d36:	00001617          	auipc	a2,0x1
ffffffffc0200d3a:	14260613          	addi	a2,a2,322 # ffffffffc0201e78 <commands+0x750>
ffffffffc0200d3e:	0e900593          	li	a1,233
ffffffffc0200d42:	00001517          	auipc	a0,0x1
ffffffffc0200d46:	14e50513          	addi	a0,a0,334 # ffffffffc0201e90 <commands+0x768>
ffffffffc0200d4a:	e62ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d4e:	00001697          	auipc	a3,0x1
ffffffffc0200d52:	03a68693          	addi	a3,a3,58 # ffffffffc0201d88 <commands+0x660>
ffffffffc0200d56:	00001617          	auipc	a2,0x1
ffffffffc0200d5a:	12260613          	addi	a2,a2,290 # ffffffffc0201e78 <commands+0x750>
ffffffffc0200d5e:	0e500593          	li	a1,229
ffffffffc0200d62:	00001517          	auipc	a0,0x1
ffffffffc0200d66:	12e50513          	addi	a0,a0,302 # ffffffffc0201e90 <commands+0x768>
ffffffffc0200d6a:	e42ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(A) == 0 && page_ref(B) == 0);
ffffffffc0200d6e:	00001697          	auipc	a3,0x1
ffffffffc0200d72:	09a68693          	addi	a3,a3,154 # ffffffffc0201e08 <commands+0x6e0>
ffffffffc0200d76:	00001617          	auipc	a2,0x1
ffffffffc0200d7a:	10260613          	addi	a2,a2,258 # ffffffffc0201e78 <commands+0x750>
ffffffffc0200d7e:	0ea00593          	li	a1,234
ffffffffc0200d82:	00001517          	auipc	a0,0x1
ffffffffc0200d86:	10e50513          	addi	a0,a0,270 # ffffffffc0201e90 <commands+0x768>
ffffffffc0200d8a:	e22ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((B = alloc_page()) != NULL);
ffffffffc0200d8e:	00001697          	auipc	a3,0x1
ffffffffc0200d92:	03a68693          	addi	a3,a3,58 # ffffffffc0201dc8 <commands+0x6a0>
ffffffffc0200d96:	00001617          	auipc	a2,0x1
ffffffffc0200d9a:	0e260613          	addi	a2,a2,226 # ffffffffc0201e78 <commands+0x750>
ffffffffc0200d9e:	0e700593          	li	a1,231
ffffffffc0200da2:	00001517          	auipc	a0,0x1
ffffffffc0200da6:	0ee50513          	addi	a0,a0,238 # ffffffffc0201e90 <commands+0x768>
ffffffffc0200daa:	e02ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(A==p0+1 && B == A+1);
ffffffffc0200dae:	02848793          	addi	a5,s1,40
ffffffffc0200db2:	f2f51ee3          	bne	a0,a5,ffffffffc0200cee <buddy_check+0x54>

    free_page(p0);    
ffffffffc0200db6:	8522                	mv	a0,s0
ffffffffc0200db8:	4585                	li	a1,1
ffffffffc0200dba:	0cc000ef          	jal	ra,ffffffffc0200e86 <free_pages>
    free_page(A);
ffffffffc0200dbe:	8526                	mv	a0,s1
ffffffffc0200dc0:	4585                	li	a1,1
ffffffffc0200dc2:	0c4000ef          	jal	ra,ffffffffc0200e86 <free_pages>
    free_page(B);
ffffffffc0200dc6:	4585                	li	a1,1
ffffffffc0200dc8:	854a                	mv	a0,s2
ffffffffc0200dca:	0bc000ef          	jal	ra,ffffffffc0200e86 <free_pages>
    
    A = alloc_pages(512);
ffffffffc0200dce:	20000513          	li	a0,512
ffffffffc0200dd2:	070000ef          	jal	ra,ffffffffc0200e42 <alloc_pages>
ffffffffc0200dd6:	842a                	mv	s0,a0
    B = alloc_pages(512);
ffffffffc0200dd8:	20000513          	li	a0,512
ffffffffc0200ddc:	066000ef          	jal	ra,ffffffffc0200e42 <alloc_pages>
ffffffffc0200de0:	84aa                	mv	s1,a0
    free_pages(A, 256);
ffffffffc0200de2:	10000593          	li	a1,256
ffffffffc0200de6:	8522                	mv	a0,s0
ffffffffc0200de8:	09e000ef          	jal	ra,ffffffffc0200e86 <free_pages>
    free_pages(B, 512);
ffffffffc0200dec:	20000593          	li	a1,512
ffffffffc0200df0:	8526                	mv	a0,s1
ffffffffc0200df2:	094000ef          	jal	ra,ffffffffc0200e86 <free_pages>
    free_pages(A + 256, 256);
ffffffffc0200df6:	650d                	lui	a0,0x3
ffffffffc0200df8:	80050513          	addi	a0,a0,-2048 # 2800 <BASE_ADDRESS-0xffffffffc01fd800>
ffffffffc0200dfc:	9522                	add	a0,a0,s0
ffffffffc0200dfe:	10000593          	li	a1,256
ffffffffc0200e02:	084000ef          	jal	ra,ffffffffc0200e86 <free_pages>

    
    p0 = alloc_pages(8192);
ffffffffc0200e06:	6509                	lui	a0,0x2
ffffffffc0200e08:	03a000ef          	jal	ra,ffffffffc0200e42 <alloc_pages>

    assert(p0 == A);
ffffffffc0200e0c:	02a40263          	beq	s0,a0,ffffffffc0200e30 <buddy_check+0x196>
ffffffffc0200e10:	00001697          	auipc	a3,0x1
ffffffffc0200e14:	05068693          	addi	a3,a3,80 # ffffffffc0201e60 <commands+0x738>
ffffffffc0200e18:	00001617          	auipc	a2,0x1
ffffffffc0200e1c:	06060613          	addi	a2,a2,96 # ffffffffc0201e78 <commands+0x750>
ffffffffc0200e20:	0fa00593          	li	a1,250
ffffffffc0200e24:	00001517          	auipc	a0,0x1
ffffffffc0200e28:	06c50513          	addi	a0,a0,108 # ffffffffc0201e90 <commands+0x768>
ffffffffc0200e2c:	d80ff0ef          	jal	ra,ffffffffc02003ac <__panic>

    A = alloc_pages(128);
ffffffffc0200e30:	08000513          	li	a0,128
ffffffffc0200e34:	00e000ef          	jal	ra,ffffffffc0200e42 <alloc_pages>
    B = alloc_pages(128);
ffffffffc0200e38:	08000513          	li	a0,128
ffffffffc0200e3c:	006000ef          	jal	ra,ffffffffc0200e42 <alloc_pages>
    // 检查是否相邻

    while (1)
    {
        /* code */
    }
ffffffffc0200e40:	a001                	j	ffffffffc0200e40 <buddy_check+0x1a6>

ffffffffc0200e42 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200e42:	100027f3          	csrr	a5,sstatus
ffffffffc0200e46:	8b89                	andi	a5,a5,2
ffffffffc0200e48:	eb89                	bnez	a5,ffffffffc0200e5a <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200e4a:	00005797          	auipc	a5,0x5
ffffffffc0200e4e:	61e78793          	addi	a5,a5,1566 # ffffffffc0206468 <pmm_manager>
ffffffffc0200e52:	639c                	ld	a5,0(a5)
ffffffffc0200e54:	0187b303          	ld	t1,24(a5)
ffffffffc0200e58:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc0200e5a:	1141                	addi	sp,sp,-16
ffffffffc0200e5c:	e406                	sd	ra,8(sp)
ffffffffc0200e5e:	e022                	sd	s0,0(sp)
ffffffffc0200e60:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0200e62:	e02ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200e66:	00005797          	auipc	a5,0x5
ffffffffc0200e6a:	60278793          	addi	a5,a5,1538 # ffffffffc0206468 <pmm_manager>
ffffffffc0200e6e:	639c                	ld	a5,0(a5)
ffffffffc0200e70:	8522                	mv	a0,s0
ffffffffc0200e72:	6f9c                	ld	a5,24(a5)
ffffffffc0200e74:	9782                	jalr	a5
ffffffffc0200e76:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200e78:	de6ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200e7c:	8522                	mv	a0,s0
ffffffffc0200e7e:	60a2                	ld	ra,8(sp)
ffffffffc0200e80:	6402                	ld	s0,0(sp)
ffffffffc0200e82:	0141                	addi	sp,sp,16
ffffffffc0200e84:	8082                	ret

ffffffffc0200e86 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200e86:	100027f3          	csrr	a5,sstatus
ffffffffc0200e8a:	8b89                	andi	a5,a5,2
ffffffffc0200e8c:	eb89                	bnez	a5,ffffffffc0200e9e <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200e8e:	00005797          	auipc	a5,0x5
ffffffffc0200e92:	5da78793          	addi	a5,a5,1498 # ffffffffc0206468 <pmm_manager>
ffffffffc0200e96:	639c                	ld	a5,0(a5)
ffffffffc0200e98:	0207b303          	ld	t1,32(a5)
ffffffffc0200e9c:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200e9e:	1101                	addi	sp,sp,-32
ffffffffc0200ea0:	ec06                	sd	ra,24(sp)
ffffffffc0200ea2:	e822                	sd	s0,16(sp)
ffffffffc0200ea4:	e426                	sd	s1,8(sp)
ffffffffc0200ea6:	842a                	mv	s0,a0
ffffffffc0200ea8:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200eaa:	dbaff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200eae:	00005797          	auipc	a5,0x5
ffffffffc0200eb2:	5ba78793          	addi	a5,a5,1466 # ffffffffc0206468 <pmm_manager>
ffffffffc0200eb6:	639c                	ld	a5,0(a5)
ffffffffc0200eb8:	85a6                	mv	a1,s1
ffffffffc0200eba:	8522                	mv	a0,s0
ffffffffc0200ebc:	739c                	ld	a5,32(a5)
ffffffffc0200ebe:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200ec0:	6442                	ld	s0,16(sp)
ffffffffc0200ec2:	60e2                	ld	ra,24(sp)
ffffffffc0200ec4:	64a2                	ld	s1,8(sp)
ffffffffc0200ec6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200ec8:	d96ff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc0200ecc <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200ecc:	00001797          	auipc	a5,0x1
ffffffffc0200ed0:	06c78793          	addi	a5,a5,108 # ffffffffc0201f38 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200ed4:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200ed6:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200ed8:	00001517          	auipc	a0,0x1
ffffffffc0200edc:	0b050513          	addi	a0,a0,176 # ffffffffc0201f88 <buddy_pmm_manager+0x50>
void pmm_init(void) {
ffffffffc0200ee0:	ec06                	sd	ra,24(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200ee2:	00005717          	auipc	a4,0x5
ffffffffc0200ee6:	58f73323          	sd	a5,1414(a4) # ffffffffc0206468 <pmm_manager>
void pmm_init(void) {
ffffffffc0200eea:	e822                	sd	s0,16(sp)
ffffffffc0200eec:	e426                	sd	s1,8(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200eee:	00005417          	auipc	s0,0x5
ffffffffc0200ef2:	57a40413          	addi	s0,s0,1402 # ffffffffc0206468 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200ef6:	9c0ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc0200efa:	601c                	ld	a5,0(s0)
ffffffffc0200efc:	679c                	ld	a5,8(a5)
ffffffffc0200efe:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200f00:	57f5                	li	a5,-3
ffffffffc0200f02:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200f04:	00001517          	auipc	a0,0x1
ffffffffc0200f08:	09c50513          	addi	a0,a0,156 # ffffffffc0201fa0 <buddy_pmm_manager+0x68>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200f0c:	00005717          	auipc	a4,0x5
ffffffffc0200f10:	56f73223          	sd	a5,1380(a4) # ffffffffc0206470 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0200f14:	9a2ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200f18:	46c5                	li	a3,17
ffffffffc0200f1a:	06ee                	slli	a3,a3,0x1b
ffffffffc0200f1c:	40100613          	li	a2,1025
ffffffffc0200f20:	16fd                	addi	a3,a3,-1
ffffffffc0200f22:	0656                	slli	a2,a2,0x15
ffffffffc0200f24:	07e005b7          	lui	a1,0x7e00
ffffffffc0200f28:	00001517          	auipc	a0,0x1
ffffffffc0200f2c:	09050513          	addi	a0,a0,144 # ffffffffc0201fb8 <buddy_pmm_manager+0x80>
ffffffffc0200f30:	986ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200f34:	777d                	lui	a4,0xfffff
ffffffffc0200f36:	00006797          	auipc	a5,0x6
ffffffffc0200f3a:	54978793          	addi	a5,a5,1353 # ffffffffc020747f <end+0xfff>
ffffffffc0200f3e:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200f40:	00088737          	lui	a4,0x88
ffffffffc0200f44:	00005697          	auipc	a3,0x5
ffffffffc0200f48:	4ce6ba23          	sd	a4,1236(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200f4c:	4601                	li	a2,0
ffffffffc0200f4e:	00005717          	auipc	a4,0x5
ffffffffc0200f52:	52f73523          	sd	a5,1322(a4) # ffffffffc0206478 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200f56:	4681                	li	a3,0
ffffffffc0200f58:	00005897          	auipc	a7,0x5
ffffffffc0200f5c:	4c088893          	addi	a7,a7,1216 # ffffffffc0206418 <npage>
ffffffffc0200f60:	00005597          	auipc	a1,0x5
ffffffffc0200f64:	51858593          	addi	a1,a1,1304 # ffffffffc0206478 <pages>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200f68:	4805                	li	a6,1
ffffffffc0200f6a:	fff80537          	lui	a0,0xfff80
ffffffffc0200f6e:	a011                	j	ffffffffc0200f72 <pmm_init+0xa6>
ffffffffc0200f70:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc0200f72:	97b2                	add	a5,a5,a2
ffffffffc0200f74:	07a1                	addi	a5,a5,8
ffffffffc0200f76:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200f7a:	0008b703          	ld	a4,0(a7)
ffffffffc0200f7e:	0685                	addi	a3,a3,1
ffffffffc0200f80:	02860613          	addi	a2,a2,40
ffffffffc0200f84:	00a707b3          	add	a5,a4,a0
ffffffffc0200f88:	fef6e4e3          	bltu	a3,a5,ffffffffc0200f70 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200f8c:	6190                	ld	a2,0(a1)
ffffffffc0200f8e:	00271793          	slli	a5,a4,0x2
ffffffffc0200f92:	97ba                	add	a5,a5,a4
ffffffffc0200f94:	fec006b7          	lui	a3,0xfec00
ffffffffc0200f98:	078e                	slli	a5,a5,0x3
ffffffffc0200f9a:	96b2                	add	a3,a3,a2
ffffffffc0200f9c:	96be                	add	a3,a3,a5
ffffffffc0200f9e:	c02007b7          	lui	a5,0xc0200
ffffffffc0200fa2:	08f6e863          	bltu	a3,a5,ffffffffc0201032 <pmm_init+0x166>
ffffffffc0200fa6:	00005497          	auipc	s1,0x5
ffffffffc0200faa:	4ca48493          	addi	s1,s1,1226 # ffffffffc0206470 <va_pa_offset>
ffffffffc0200fae:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc0200fb0:	45c5                	li	a1,17
ffffffffc0200fb2:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200fb4:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc0200fb6:	04b6e963          	bltu	a3,a1,ffffffffc0201008 <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200fba:	601c                	ld	a5,0(s0)
ffffffffc0200fbc:	7b9c                	ld	a5,48(a5)
ffffffffc0200fbe:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200fc0:	00001517          	auipc	a0,0x1
ffffffffc0200fc4:	09050513          	addi	a0,a0,144 # ffffffffc0202050 <buddy_pmm_manager+0x118>
ffffffffc0200fc8:	8eeff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200fcc:	00004697          	auipc	a3,0x4
ffffffffc0200fd0:	03468693          	addi	a3,a3,52 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200fd4:	00005797          	auipc	a5,0x5
ffffffffc0200fd8:	44d7b623          	sd	a3,1100(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200fdc:	c02007b7          	lui	a5,0xc0200
ffffffffc0200fe0:	06f6e563          	bltu	a3,a5,ffffffffc020104a <pmm_init+0x17e>
ffffffffc0200fe4:	609c                	ld	a5,0(s1)
}
ffffffffc0200fe6:	6442                	ld	s0,16(sp)
ffffffffc0200fe8:	60e2                	ld	ra,24(sp)
ffffffffc0200fea:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200fec:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc0200fee:	8e9d                	sub	a3,a3,a5
ffffffffc0200ff0:	00005797          	auipc	a5,0x5
ffffffffc0200ff4:	46d7b823          	sd	a3,1136(a5) # ffffffffc0206460 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200ff8:	00001517          	auipc	a0,0x1
ffffffffc0200ffc:	07850513          	addi	a0,a0,120 # ffffffffc0202070 <buddy_pmm_manager+0x138>
ffffffffc0201000:	8636                	mv	a2,a3
}
ffffffffc0201002:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201004:	8b2ff06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201008:	6785                	lui	a5,0x1
ffffffffc020100a:	17fd                	addi	a5,a5,-1
ffffffffc020100c:	96be                	add	a3,a3,a5
ffffffffc020100e:	77fd                	lui	a5,0xfffff
ffffffffc0201010:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0201012:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201016:	04e7f663          	bleu	a4,a5,ffffffffc0201062 <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc020101a:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc020101c:	97aa                	add	a5,a5,a0
ffffffffc020101e:	00279513          	slli	a0,a5,0x2
ffffffffc0201022:	953e                	add	a0,a0,a5
ffffffffc0201024:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201026:	8d95                	sub	a1,a1,a3
ffffffffc0201028:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc020102a:	81b1                	srli	a1,a1,0xc
ffffffffc020102c:	9532                	add	a0,a0,a2
ffffffffc020102e:	9782                	jalr	a5
ffffffffc0201030:	b769                	j	ffffffffc0200fba <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201032:	00001617          	auipc	a2,0x1
ffffffffc0201036:	fb660613          	addi	a2,a2,-74 # ffffffffc0201fe8 <buddy_pmm_manager+0xb0>
ffffffffc020103a:	06f00593          	li	a1,111
ffffffffc020103e:	00001517          	auipc	a0,0x1
ffffffffc0201042:	fd250513          	addi	a0,a0,-46 # ffffffffc0202010 <buddy_pmm_manager+0xd8>
ffffffffc0201046:	b66ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020104a:	00001617          	auipc	a2,0x1
ffffffffc020104e:	f9e60613          	addi	a2,a2,-98 # ffffffffc0201fe8 <buddy_pmm_manager+0xb0>
ffffffffc0201052:	08a00593          	li	a1,138
ffffffffc0201056:	00001517          	auipc	a0,0x1
ffffffffc020105a:	fba50513          	addi	a0,a0,-70 # ffffffffc0202010 <buddy_pmm_manager+0xd8>
ffffffffc020105e:	b4eff0ef          	jal	ra,ffffffffc02003ac <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201062:	00001617          	auipc	a2,0x1
ffffffffc0201066:	fbe60613          	addi	a2,a2,-66 # ffffffffc0202020 <buddy_pmm_manager+0xe8>
ffffffffc020106a:	06b00593          	li	a1,107
ffffffffc020106e:	00001517          	auipc	a0,0x1
ffffffffc0201072:	fd250513          	addi	a0,a0,-46 # ffffffffc0202040 <buddy_pmm_manager+0x108>
ffffffffc0201076:	b36ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020107a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020107a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020107e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201080:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201084:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201086:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020108a:	f022                	sd	s0,32(sp)
ffffffffc020108c:	ec26                	sd	s1,24(sp)
ffffffffc020108e:	e84a                	sd	s2,16(sp)
ffffffffc0201090:	f406                	sd	ra,40(sp)
ffffffffc0201092:	e44e                	sd	s3,8(sp)
ffffffffc0201094:	84aa                	mv	s1,a0
ffffffffc0201096:	892e                	mv	s2,a1
ffffffffc0201098:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020109c:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc020109e:	03067e63          	bleu	a6,a2,ffffffffc02010da <printnum+0x60>
ffffffffc02010a2:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02010a4:	00805763          	blez	s0,ffffffffc02010b2 <printnum+0x38>
ffffffffc02010a8:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02010aa:	85ca                	mv	a1,s2
ffffffffc02010ac:	854e                	mv	a0,s3
ffffffffc02010ae:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02010b0:	fc65                	bnez	s0,ffffffffc02010a8 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02010b2:	1a02                	slli	s4,s4,0x20
ffffffffc02010b4:	020a5a13          	srli	s4,s4,0x20
ffffffffc02010b8:	00001797          	auipc	a5,0x1
ffffffffc02010bc:	18878793          	addi	a5,a5,392 # ffffffffc0202240 <error_string+0x38>
ffffffffc02010c0:	9a3e                	add	s4,s4,a5
}
ffffffffc02010c2:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02010c4:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02010c8:	70a2                	ld	ra,40(sp)
ffffffffc02010ca:	69a2                	ld	s3,8(sp)
ffffffffc02010cc:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02010ce:	85ca                	mv	a1,s2
ffffffffc02010d0:	8326                	mv	t1,s1
}
ffffffffc02010d2:	6942                	ld	s2,16(sp)
ffffffffc02010d4:	64e2                	ld	s1,24(sp)
ffffffffc02010d6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02010d8:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02010da:	03065633          	divu	a2,a2,a6
ffffffffc02010de:	8722                	mv	a4,s0
ffffffffc02010e0:	f9bff0ef          	jal	ra,ffffffffc020107a <printnum>
ffffffffc02010e4:	b7f9                	j	ffffffffc02010b2 <printnum+0x38>

ffffffffc02010e6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02010e6:	7119                	addi	sp,sp,-128
ffffffffc02010e8:	f4a6                	sd	s1,104(sp)
ffffffffc02010ea:	f0ca                	sd	s2,96(sp)
ffffffffc02010ec:	e8d2                	sd	s4,80(sp)
ffffffffc02010ee:	e4d6                	sd	s5,72(sp)
ffffffffc02010f0:	e0da                	sd	s6,64(sp)
ffffffffc02010f2:	fc5e                	sd	s7,56(sp)
ffffffffc02010f4:	f862                	sd	s8,48(sp)
ffffffffc02010f6:	f06a                	sd	s10,32(sp)
ffffffffc02010f8:	fc86                	sd	ra,120(sp)
ffffffffc02010fa:	f8a2                	sd	s0,112(sp)
ffffffffc02010fc:	ecce                	sd	s3,88(sp)
ffffffffc02010fe:	f466                	sd	s9,40(sp)
ffffffffc0201100:	ec6e                	sd	s11,24(sp)
ffffffffc0201102:	892a                	mv	s2,a0
ffffffffc0201104:	84ae                	mv	s1,a1
ffffffffc0201106:	8d32                	mv	s10,a2
ffffffffc0201108:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020110a:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020110c:	00001a17          	auipc	s4,0x1
ffffffffc0201110:	fa4a0a13          	addi	s4,s4,-92 # ffffffffc02020b0 <buddy_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201114:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201118:	00001c17          	auipc	s8,0x1
ffffffffc020111c:	0f0c0c13          	addi	s8,s8,240 # ffffffffc0202208 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201120:	000d4503          	lbu	a0,0(s10)
ffffffffc0201124:	02500793          	li	a5,37
ffffffffc0201128:	001d0413          	addi	s0,s10,1
ffffffffc020112c:	00f50e63          	beq	a0,a5,ffffffffc0201148 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0201130:	c521                	beqz	a0,ffffffffc0201178 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201132:	02500993          	li	s3,37
ffffffffc0201136:	a011                	j	ffffffffc020113a <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0201138:	c121                	beqz	a0,ffffffffc0201178 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc020113a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020113c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020113e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201140:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201144:	ff351ae3          	bne	a0,s3,ffffffffc0201138 <vprintfmt+0x52>
ffffffffc0201148:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020114c:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201150:	4981                	li	s3,0
ffffffffc0201152:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0201154:	5cfd                	li	s9,-1
ffffffffc0201156:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201158:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc020115c:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020115e:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0201162:	0ff6f693          	andi	a3,a3,255
ffffffffc0201166:	00140d13          	addi	s10,s0,1
ffffffffc020116a:	20d5e563          	bltu	a1,a3,ffffffffc0201374 <vprintfmt+0x28e>
ffffffffc020116e:	068a                	slli	a3,a3,0x2
ffffffffc0201170:	96d2                	add	a3,a3,s4
ffffffffc0201172:	4294                	lw	a3,0(a3)
ffffffffc0201174:	96d2                	add	a3,a3,s4
ffffffffc0201176:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201178:	70e6                	ld	ra,120(sp)
ffffffffc020117a:	7446                	ld	s0,112(sp)
ffffffffc020117c:	74a6                	ld	s1,104(sp)
ffffffffc020117e:	7906                	ld	s2,96(sp)
ffffffffc0201180:	69e6                	ld	s3,88(sp)
ffffffffc0201182:	6a46                	ld	s4,80(sp)
ffffffffc0201184:	6aa6                	ld	s5,72(sp)
ffffffffc0201186:	6b06                	ld	s6,64(sp)
ffffffffc0201188:	7be2                	ld	s7,56(sp)
ffffffffc020118a:	7c42                	ld	s8,48(sp)
ffffffffc020118c:	7ca2                	ld	s9,40(sp)
ffffffffc020118e:	7d02                	ld	s10,32(sp)
ffffffffc0201190:	6de2                	ld	s11,24(sp)
ffffffffc0201192:	6109                	addi	sp,sp,128
ffffffffc0201194:	8082                	ret
    if (lflag >= 2) {
ffffffffc0201196:	4705                	li	a4,1
ffffffffc0201198:	008a8593          	addi	a1,s5,8
ffffffffc020119c:	01074463          	blt	a4,a6,ffffffffc02011a4 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc02011a0:	26080363          	beqz	a6,ffffffffc0201406 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc02011a4:	000ab603          	ld	a2,0(s5)
ffffffffc02011a8:	46c1                	li	a3,16
ffffffffc02011aa:	8aae                	mv	s5,a1
ffffffffc02011ac:	a06d                	j	ffffffffc0201256 <vprintfmt+0x170>
            goto reswitch;
ffffffffc02011ae:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02011b2:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011b4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02011b6:	b765                	j	ffffffffc020115e <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc02011b8:	000aa503          	lw	a0,0(s5)
ffffffffc02011bc:	85a6                	mv	a1,s1
ffffffffc02011be:	0aa1                	addi	s5,s5,8
ffffffffc02011c0:	9902                	jalr	s2
            break;
ffffffffc02011c2:	bfb9                	j	ffffffffc0201120 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02011c4:	4705                	li	a4,1
ffffffffc02011c6:	008a8993          	addi	s3,s5,8
ffffffffc02011ca:	01074463          	blt	a4,a6,ffffffffc02011d2 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc02011ce:	22080463          	beqz	a6,ffffffffc02013f6 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc02011d2:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02011d6:	24044463          	bltz	s0,ffffffffc020141e <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02011da:	8622                	mv	a2,s0
ffffffffc02011dc:	8ace                	mv	s5,s3
ffffffffc02011de:	46a9                	li	a3,10
ffffffffc02011e0:	a89d                	j	ffffffffc0201256 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02011e2:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02011e6:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02011e8:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02011ea:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02011ee:	8fb5                	xor	a5,a5,a3
ffffffffc02011f0:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02011f4:	1ad74363          	blt	a4,a3,ffffffffc020139a <vprintfmt+0x2b4>
ffffffffc02011f8:	00369793          	slli	a5,a3,0x3
ffffffffc02011fc:	97e2                	add	a5,a5,s8
ffffffffc02011fe:	639c                	ld	a5,0(a5)
ffffffffc0201200:	18078d63          	beqz	a5,ffffffffc020139a <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201204:	86be                	mv	a3,a5
ffffffffc0201206:	00001617          	auipc	a2,0x1
ffffffffc020120a:	0ea60613          	addi	a2,a2,234 # ffffffffc02022f0 <error_string+0xe8>
ffffffffc020120e:	85a6                	mv	a1,s1
ffffffffc0201210:	854a                	mv	a0,s2
ffffffffc0201212:	240000ef          	jal	ra,ffffffffc0201452 <printfmt>
ffffffffc0201216:	b729                	j	ffffffffc0201120 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0201218:	00144603          	lbu	a2,1(s0)
ffffffffc020121c:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020121e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201220:	bf3d                	j	ffffffffc020115e <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0201222:	4705                	li	a4,1
ffffffffc0201224:	008a8593          	addi	a1,s5,8
ffffffffc0201228:	01074463          	blt	a4,a6,ffffffffc0201230 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc020122c:	1e080263          	beqz	a6,ffffffffc0201410 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0201230:	000ab603          	ld	a2,0(s5)
ffffffffc0201234:	46a1                	li	a3,8
ffffffffc0201236:	8aae                	mv	s5,a1
ffffffffc0201238:	a839                	j	ffffffffc0201256 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc020123a:	03000513          	li	a0,48
ffffffffc020123e:	85a6                	mv	a1,s1
ffffffffc0201240:	e03e                	sd	a5,0(sp)
ffffffffc0201242:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201244:	85a6                	mv	a1,s1
ffffffffc0201246:	07800513          	li	a0,120
ffffffffc020124a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020124c:	0aa1                	addi	s5,s5,8
ffffffffc020124e:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0201252:	6782                	ld	a5,0(sp)
ffffffffc0201254:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201256:	876e                	mv	a4,s11
ffffffffc0201258:	85a6                	mv	a1,s1
ffffffffc020125a:	854a                	mv	a0,s2
ffffffffc020125c:	e1fff0ef          	jal	ra,ffffffffc020107a <printnum>
            break;
ffffffffc0201260:	b5c1                	j	ffffffffc0201120 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201262:	000ab603          	ld	a2,0(s5)
ffffffffc0201266:	0aa1                	addi	s5,s5,8
ffffffffc0201268:	1c060663          	beqz	a2,ffffffffc0201434 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc020126c:	00160413          	addi	s0,a2,1
ffffffffc0201270:	17b05c63          	blez	s11,ffffffffc02013e8 <vprintfmt+0x302>
ffffffffc0201274:	02d00593          	li	a1,45
ffffffffc0201278:	14b79263          	bne	a5,a1,ffffffffc02013bc <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020127c:	00064783          	lbu	a5,0(a2)
ffffffffc0201280:	0007851b          	sext.w	a0,a5
ffffffffc0201284:	c905                	beqz	a0,ffffffffc02012b4 <vprintfmt+0x1ce>
ffffffffc0201286:	000cc563          	bltz	s9,ffffffffc0201290 <vprintfmt+0x1aa>
ffffffffc020128a:	3cfd                	addiw	s9,s9,-1
ffffffffc020128c:	036c8263          	beq	s9,s6,ffffffffc02012b0 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0201290:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201292:	18098463          	beqz	s3,ffffffffc020141a <vprintfmt+0x334>
ffffffffc0201296:	3781                	addiw	a5,a5,-32
ffffffffc0201298:	18fbf163          	bleu	a5,s7,ffffffffc020141a <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc020129c:	03f00513          	li	a0,63
ffffffffc02012a0:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02012a2:	0405                	addi	s0,s0,1
ffffffffc02012a4:	fff44783          	lbu	a5,-1(s0)
ffffffffc02012a8:	3dfd                	addiw	s11,s11,-1
ffffffffc02012aa:	0007851b          	sext.w	a0,a5
ffffffffc02012ae:	fd61                	bnez	a0,ffffffffc0201286 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc02012b0:	e7b058e3          	blez	s11,ffffffffc0201120 <vprintfmt+0x3a>
ffffffffc02012b4:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02012b6:	85a6                	mv	a1,s1
ffffffffc02012b8:	02000513          	li	a0,32
ffffffffc02012bc:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02012be:	e60d81e3          	beqz	s11,ffffffffc0201120 <vprintfmt+0x3a>
ffffffffc02012c2:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02012c4:	85a6                	mv	a1,s1
ffffffffc02012c6:	02000513          	li	a0,32
ffffffffc02012ca:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02012cc:	fe0d94e3          	bnez	s11,ffffffffc02012b4 <vprintfmt+0x1ce>
ffffffffc02012d0:	bd81                	j	ffffffffc0201120 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02012d2:	4705                	li	a4,1
ffffffffc02012d4:	008a8593          	addi	a1,s5,8
ffffffffc02012d8:	01074463          	blt	a4,a6,ffffffffc02012e0 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02012dc:	12080063          	beqz	a6,ffffffffc02013fc <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02012e0:	000ab603          	ld	a2,0(s5)
ffffffffc02012e4:	46a9                	li	a3,10
ffffffffc02012e6:	8aae                	mv	s5,a1
ffffffffc02012e8:	b7bd                	j	ffffffffc0201256 <vprintfmt+0x170>
ffffffffc02012ea:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02012ee:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012f2:	846a                	mv	s0,s10
ffffffffc02012f4:	b5ad                	j	ffffffffc020115e <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02012f6:	85a6                	mv	a1,s1
ffffffffc02012f8:	02500513          	li	a0,37
ffffffffc02012fc:	9902                	jalr	s2
            break;
ffffffffc02012fe:	b50d                	j	ffffffffc0201120 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0201300:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0201304:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201308:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020130a:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc020130c:	e40dd9e3          	bgez	s11,ffffffffc020115e <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0201310:	8de6                	mv	s11,s9
ffffffffc0201312:	5cfd                	li	s9,-1
ffffffffc0201314:	b5a9                	j	ffffffffc020115e <vprintfmt+0x78>
            goto reswitch;
ffffffffc0201316:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc020131a:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020131e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201320:	bd3d                	j	ffffffffc020115e <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0201322:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0201326:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020132a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020132c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201330:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201334:	fcd56ce3          	bltu	a0,a3,ffffffffc020130c <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0201338:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020133a:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc020133e:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201342:	0196873b          	addw	a4,a3,s9
ffffffffc0201346:	0017171b          	slliw	a4,a4,0x1
ffffffffc020134a:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc020134e:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0201352:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201356:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020135a:	fcd57fe3          	bleu	a3,a0,ffffffffc0201338 <vprintfmt+0x252>
ffffffffc020135e:	b77d                	j	ffffffffc020130c <vprintfmt+0x226>
            if (width < 0)
ffffffffc0201360:	fffdc693          	not	a3,s11
ffffffffc0201364:	96fd                	srai	a3,a3,0x3f
ffffffffc0201366:	00ddfdb3          	and	s11,s11,a3
ffffffffc020136a:	00144603          	lbu	a2,1(s0)
ffffffffc020136e:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201370:	846a                	mv	s0,s10
ffffffffc0201372:	b3f5                	j	ffffffffc020115e <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0201374:	85a6                	mv	a1,s1
ffffffffc0201376:	02500513          	li	a0,37
ffffffffc020137a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020137c:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201380:	02500793          	li	a5,37
ffffffffc0201384:	8d22                	mv	s10,s0
ffffffffc0201386:	d8f70de3          	beq	a4,a5,ffffffffc0201120 <vprintfmt+0x3a>
ffffffffc020138a:	02500713          	li	a4,37
ffffffffc020138e:	1d7d                	addi	s10,s10,-1
ffffffffc0201390:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0201394:	fee79de3          	bne	a5,a4,ffffffffc020138e <vprintfmt+0x2a8>
ffffffffc0201398:	b361                	j	ffffffffc0201120 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020139a:	00001617          	auipc	a2,0x1
ffffffffc020139e:	f4660613          	addi	a2,a2,-186 # ffffffffc02022e0 <error_string+0xd8>
ffffffffc02013a2:	85a6                	mv	a1,s1
ffffffffc02013a4:	854a                	mv	a0,s2
ffffffffc02013a6:	0ac000ef          	jal	ra,ffffffffc0201452 <printfmt>
ffffffffc02013aa:	bb9d                	j	ffffffffc0201120 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02013ac:	00001617          	auipc	a2,0x1
ffffffffc02013b0:	f2c60613          	addi	a2,a2,-212 # ffffffffc02022d8 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc02013b4:	00001417          	auipc	s0,0x1
ffffffffc02013b8:	f2540413          	addi	s0,s0,-219 # ffffffffc02022d9 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02013bc:	8532                	mv	a0,a2
ffffffffc02013be:	85e6                	mv	a1,s9
ffffffffc02013c0:	e032                	sd	a2,0(sp)
ffffffffc02013c2:	e43e                	sd	a5,8(sp)
ffffffffc02013c4:	1c2000ef          	jal	ra,ffffffffc0201586 <strnlen>
ffffffffc02013c8:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02013cc:	6602                	ld	a2,0(sp)
ffffffffc02013ce:	01b05d63          	blez	s11,ffffffffc02013e8 <vprintfmt+0x302>
ffffffffc02013d2:	67a2                	ld	a5,8(sp)
ffffffffc02013d4:	2781                	sext.w	a5,a5
ffffffffc02013d6:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02013d8:	6522                	ld	a0,8(sp)
ffffffffc02013da:	85a6                	mv	a1,s1
ffffffffc02013dc:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02013de:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02013e0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02013e2:	6602                	ld	a2,0(sp)
ffffffffc02013e4:	fe0d9ae3          	bnez	s11,ffffffffc02013d8 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02013e8:	00064783          	lbu	a5,0(a2)
ffffffffc02013ec:	0007851b          	sext.w	a0,a5
ffffffffc02013f0:	e8051be3          	bnez	a0,ffffffffc0201286 <vprintfmt+0x1a0>
ffffffffc02013f4:	b335                	j	ffffffffc0201120 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02013f6:	000aa403          	lw	s0,0(s5)
ffffffffc02013fa:	bbf1                	j	ffffffffc02011d6 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02013fc:	000ae603          	lwu	a2,0(s5)
ffffffffc0201400:	46a9                	li	a3,10
ffffffffc0201402:	8aae                	mv	s5,a1
ffffffffc0201404:	bd89                	j	ffffffffc0201256 <vprintfmt+0x170>
ffffffffc0201406:	000ae603          	lwu	a2,0(s5)
ffffffffc020140a:	46c1                	li	a3,16
ffffffffc020140c:	8aae                	mv	s5,a1
ffffffffc020140e:	b5a1                	j	ffffffffc0201256 <vprintfmt+0x170>
ffffffffc0201410:	000ae603          	lwu	a2,0(s5)
ffffffffc0201414:	46a1                	li	a3,8
ffffffffc0201416:	8aae                	mv	s5,a1
ffffffffc0201418:	bd3d                	j	ffffffffc0201256 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc020141a:	9902                	jalr	s2
ffffffffc020141c:	b559                	j	ffffffffc02012a2 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc020141e:	85a6                	mv	a1,s1
ffffffffc0201420:	02d00513          	li	a0,45
ffffffffc0201424:	e03e                	sd	a5,0(sp)
ffffffffc0201426:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201428:	8ace                	mv	s5,s3
ffffffffc020142a:	40800633          	neg	a2,s0
ffffffffc020142e:	46a9                	li	a3,10
ffffffffc0201430:	6782                	ld	a5,0(sp)
ffffffffc0201432:	b515                	j	ffffffffc0201256 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0201434:	01b05663          	blez	s11,ffffffffc0201440 <vprintfmt+0x35a>
ffffffffc0201438:	02d00693          	li	a3,45
ffffffffc020143c:	f6d798e3          	bne	a5,a3,ffffffffc02013ac <vprintfmt+0x2c6>
ffffffffc0201440:	00001417          	auipc	s0,0x1
ffffffffc0201444:	e9940413          	addi	s0,s0,-359 # ffffffffc02022d9 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201448:	02800513          	li	a0,40
ffffffffc020144c:	02800793          	li	a5,40
ffffffffc0201450:	bd1d                	j	ffffffffc0201286 <vprintfmt+0x1a0>

ffffffffc0201452 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201452:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201454:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201458:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020145a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020145c:	ec06                	sd	ra,24(sp)
ffffffffc020145e:	f83a                	sd	a4,48(sp)
ffffffffc0201460:	fc3e                	sd	a5,56(sp)
ffffffffc0201462:	e0c2                	sd	a6,64(sp)
ffffffffc0201464:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201466:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201468:	c7fff0ef          	jal	ra,ffffffffc02010e6 <vprintfmt>
}
ffffffffc020146c:	60e2                	ld	ra,24(sp)
ffffffffc020146e:	6161                	addi	sp,sp,80
ffffffffc0201470:	8082                	ret

ffffffffc0201472 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201472:	715d                	addi	sp,sp,-80
ffffffffc0201474:	e486                	sd	ra,72(sp)
ffffffffc0201476:	e0a2                	sd	s0,64(sp)
ffffffffc0201478:	fc26                	sd	s1,56(sp)
ffffffffc020147a:	f84a                	sd	s2,48(sp)
ffffffffc020147c:	f44e                	sd	s3,40(sp)
ffffffffc020147e:	f052                	sd	s4,32(sp)
ffffffffc0201480:	ec56                	sd	s5,24(sp)
ffffffffc0201482:	e85a                	sd	s6,16(sp)
ffffffffc0201484:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201486:	c901                	beqz	a0,ffffffffc0201496 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201488:	85aa                	mv	a1,a0
ffffffffc020148a:	00001517          	auipc	a0,0x1
ffffffffc020148e:	e6650513          	addi	a0,a0,-410 # ffffffffc02022f0 <error_string+0xe8>
ffffffffc0201492:	c25fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc0201496:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201498:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020149a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020149c:	4aa9                	li	s5,10
ffffffffc020149e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02014a0:	00005b97          	auipc	s7,0x5
ffffffffc02014a4:	b70b8b93          	addi	s7,s7,-1168 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02014a8:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02014ac:	c83fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02014b0:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02014b2:	00054b63          	bltz	a0,ffffffffc02014c8 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02014b6:	00a95b63          	ble	a0,s2,ffffffffc02014cc <readline+0x5a>
ffffffffc02014ba:	029a5463          	ble	s1,s4,ffffffffc02014e2 <readline+0x70>
        c = getchar();
ffffffffc02014be:	c71fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02014c2:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02014c4:	fe0559e3          	bgez	a0,ffffffffc02014b6 <readline+0x44>
            return NULL;
ffffffffc02014c8:	4501                	li	a0,0
ffffffffc02014ca:	a099                	j	ffffffffc0201510 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02014cc:	03341463          	bne	s0,s3,ffffffffc02014f4 <readline+0x82>
ffffffffc02014d0:	e8b9                	bnez	s1,ffffffffc0201526 <readline+0xb4>
        c = getchar();
ffffffffc02014d2:	c5dfe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02014d6:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02014d8:	fe0548e3          	bltz	a0,ffffffffc02014c8 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02014dc:	fea958e3          	ble	a0,s2,ffffffffc02014cc <readline+0x5a>
ffffffffc02014e0:	4481                	li	s1,0
            cputchar(c);
ffffffffc02014e2:	8522                	mv	a0,s0
ffffffffc02014e4:	c07fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc02014e8:	009b87b3          	add	a5,s7,s1
ffffffffc02014ec:	00878023          	sb	s0,0(a5)
ffffffffc02014f0:	2485                	addiw	s1,s1,1
ffffffffc02014f2:	bf6d                	j	ffffffffc02014ac <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02014f4:	01540463          	beq	s0,s5,ffffffffc02014fc <readline+0x8a>
ffffffffc02014f8:	fb641ae3          	bne	s0,s6,ffffffffc02014ac <readline+0x3a>
            cputchar(c);
ffffffffc02014fc:	8522                	mv	a0,s0
ffffffffc02014fe:	bedfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc0201502:	00005517          	auipc	a0,0x5
ffffffffc0201506:	b0e50513          	addi	a0,a0,-1266 # ffffffffc0206010 <edata>
ffffffffc020150a:	94aa                	add	s1,s1,a0
ffffffffc020150c:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201510:	60a6                	ld	ra,72(sp)
ffffffffc0201512:	6406                	ld	s0,64(sp)
ffffffffc0201514:	74e2                	ld	s1,56(sp)
ffffffffc0201516:	7942                	ld	s2,48(sp)
ffffffffc0201518:	79a2                	ld	s3,40(sp)
ffffffffc020151a:	7a02                	ld	s4,32(sp)
ffffffffc020151c:	6ae2                	ld	s5,24(sp)
ffffffffc020151e:	6b42                	ld	s6,16(sp)
ffffffffc0201520:	6ba2                	ld	s7,8(sp)
ffffffffc0201522:	6161                	addi	sp,sp,80
ffffffffc0201524:	8082                	ret
            cputchar(c);
ffffffffc0201526:	4521                	li	a0,8
ffffffffc0201528:	bc3fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc020152c:	34fd                	addiw	s1,s1,-1
ffffffffc020152e:	bfbd                	j	ffffffffc02014ac <readline+0x3a>

ffffffffc0201530 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201530:	00005797          	auipc	a5,0x5
ffffffffc0201534:	ad878793          	addi	a5,a5,-1320 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201538:	6398                	ld	a4,0(a5)
ffffffffc020153a:	4781                	li	a5,0
ffffffffc020153c:	88ba                	mv	a7,a4
ffffffffc020153e:	852a                	mv	a0,a0
ffffffffc0201540:	85be                	mv	a1,a5
ffffffffc0201542:	863e                	mv	a2,a5
ffffffffc0201544:	00000073          	ecall
ffffffffc0201548:	87aa                	mv	a5,a0
}
ffffffffc020154a:	8082                	ret

ffffffffc020154c <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc020154c:	00005797          	auipc	a5,0x5
ffffffffc0201550:	edc78793          	addi	a5,a5,-292 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201554:	6398                	ld	a4,0(a5)
ffffffffc0201556:	4781                	li	a5,0
ffffffffc0201558:	88ba                	mv	a7,a4
ffffffffc020155a:	852a                	mv	a0,a0
ffffffffc020155c:	85be                	mv	a1,a5
ffffffffc020155e:	863e                	mv	a2,a5
ffffffffc0201560:	00000073          	ecall
ffffffffc0201564:	87aa                	mv	a5,a0
}
ffffffffc0201566:	8082                	ret

ffffffffc0201568 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201568:	00005797          	auipc	a5,0x5
ffffffffc020156c:	a9878793          	addi	a5,a5,-1384 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201570:	639c                	ld	a5,0(a5)
ffffffffc0201572:	4501                	li	a0,0
ffffffffc0201574:	88be                	mv	a7,a5
ffffffffc0201576:	852a                	mv	a0,a0
ffffffffc0201578:	85aa                	mv	a1,a0
ffffffffc020157a:	862a                	mv	a2,a0
ffffffffc020157c:	00000073          	ecall
ffffffffc0201580:	852a                	mv	a0,a0
ffffffffc0201582:	2501                	sext.w	a0,a0
ffffffffc0201584:	8082                	ret

ffffffffc0201586 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201586:	c185                	beqz	a1,ffffffffc02015a6 <strnlen+0x20>
ffffffffc0201588:	00054783          	lbu	a5,0(a0)
ffffffffc020158c:	cf89                	beqz	a5,ffffffffc02015a6 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc020158e:	4781                	li	a5,0
ffffffffc0201590:	a021                	j	ffffffffc0201598 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201592:	00074703          	lbu	a4,0(a4)
ffffffffc0201596:	c711                	beqz	a4,ffffffffc02015a2 <strnlen+0x1c>
        cnt ++;
ffffffffc0201598:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020159a:	00f50733          	add	a4,a0,a5
ffffffffc020159e:	fef59ae3          	bne	a1,a5,ffffffffc0201592 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02015a2:	853e                	mv	a0,a5
ffffffffc02015a4:	8082                	ret
    size_t cnt = 0;
ffffffffc02015a6:	4781                	li	a5,0
}
ffffffffc02015a8:	853e                	mv	a0,a5
ffffffffc02015aa:	8082                	ret

ffffffffc02015ac <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02015ac:	00054783          	lbu	a5,0(a0)
ffffffffc02015b0:	0005c703          	lbu	a4,0(a1)
ffffffffc02015b4:	cb91                	beqz	a5,ffffffffc02015c8 <strcmp+0x1c>
ffffffffc02015b6:	00e79c63          	bne	a5,a4,ffffffffc02015ce <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02015ba:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02015bc:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02015c0:	0585                	addi	a1,a1,1
ffffffffc02015c2:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02015c6:	fbe5                	bnez	a5,ffffffffc02015b6 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02015c8:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02015ca:	9d19                	subw	a0,a0,a4
ffffffffc02015cc:	8082                	ret
ffffffffc02015ce:	0007851b          	sext.w	a0,a5
ffffffffc02015d2:	9d19                	subw	a0,a0,a4
ffffffffc02015d4:	8082                	ret

ffffffffc02015d6 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02015d6:	00054783          	lbu	a5,0(a0)
ffffffffc02015da:	cb91                	beqz	a5,ffffffffc02015ee <strchr+0x18>
        if (*s == c) {
ffffffffc02015dc:	00b79563          	bne	a5,a1,ffffffffc02015e6 <strchr+0x10>
ffffffffc02015e0:	a809                	j	ffffffffc02015f2 <strchr+0x1c>
ffffffffc02015e2:	00b78763          	beq	a5,a1,ffffffffc02015f0 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02015e6:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02015e8:	00054783          	lbu	a5,0(a0)
ffffffffc02015ec:	fbfd                	bnez	a5,ffffffffc02015e2 <strchr+0xc>
    }
    return NULL;
ffffffffc02015ee:	4501                	li	a0,0
}
ffffffffc02015f0:	8082                	ret
ffffffffc02015f2:	8082                	ret

ffffffffc02015f4 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02015f4:	ca01                	beqz	a2,ffffffffc0201604 <memset+0x10>
ffffffffc02015f6:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02015f8:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02015fa:	0785                	addi	a5,a5,1
ffffffffc02015fc:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201600:	fec79de3          	bne	a5,a2,ffffffffc02015fa <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201604:	8082                	ret
