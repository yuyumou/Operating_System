
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
ffffffffc0200042:	43260613          	addi	a2,a2,1074 # ffffffffc0206470 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	2a3010ef          	jal	ra,ffffffffc0201af0 <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	ab250513          	addi	a0,a0,-1358 # ffffffffc0201b08 <etext+0x6>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	0dc000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	35e010ef          	jal	ra,ffffffffc02013c8 <pmm_init>

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
ffffffffc02000aa:	538010ef          	jal	ra,ffffffffc02015e2 <vprintfmt>
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
ffffffffc02000de:	504010ef          	jal	ra,ffffffffc02015e2 <vprintfmt>
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
ffffffffc0200140:	00002517          	auipc	a0,0x2
ffffffffc0200144:	a1850513          	addi	a0,a0,-1512 # ffffffffc0201b58 <etext+0x56>
void print_kerninfo(void) {
ffffffffc0200148:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee858593          	addi	a1,a1,-280 # ffffffffc0200036 <kern_init>
ffffffffc0200156:	00002517          	auipc	a0,0x2
ffffffffc020015a:	a2250513          	addi	a0,a0,-1502 # ffffffffc0201b78 <etext+0x76>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200162:	00002597          	auipc	a1,0x2
ffffffffc0200166:	9a058593          	addi	a1,a1,-1632 # ffffffffc0201b02 <etext>
ffffffffc020016a:	00002517          	auipc	a0,0x2
ffffffffc020016e:	a2e50513          	addi	a0,a0,-1490 # ffffffffc0201b98 <etext+0x96>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200176:	00006597          	auipc	a1,0x6
ffffffffc020017a:	e9a58593          	addi	a1,a1,-358 # ffffffffc0206010 <edata>
ffffffffc020017e:	00002517          	auipc	a0,0x2
ffffffffc0200182:	a3a50513          	addi	a0,a0,-1478 # ffffffffc0201bb8 <etext+0xb6>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018a:	00006597          	auipc	a1,0x6
ffffffffc020018e:	2e658593          	addi	a1,a1,742 # ffffffffc0206470 <end>
ffffffffc0200192:	00002517          	auipc	a0,0x2
ffffffffc0200196:	a4650513          	addi	a0,a0,-1466 # ffffffffc0201bd8 <etext+0xd6>
ffffffffc020019a:	f1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019e:	00006597          	auipc	a1,0x6
ffffffffc02001a2:	6d158593          	addi	a1,a1,1745 # ffffffffc020686f <end+0x3ff>
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
ffffffffc02001c0:	00002517          	auipc	a0,0x2
ffffffffc02001c4:	a3850513          	addi	a0,a0,-1480 # ffffffffc0201bf8 <etext+0xf6>
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
ffffffffc02001d0:	00002617          	auipc	a2,0x2
ffffffffc02001d4:	95860613          	addi	a2,a2,-1704 # ffffffffc0201b28 <etext+0x26>
ffffffffc02001d8:	04e00593          	li	a1,78
ffffffffc02001dc:	00002517          	auipc	a0,0x2
ffffffffc02001e0:	96450513          	addi	a0,a0,-1692 # ffffffffc0201b40 <etext+0x3e>
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
ffffffffc02001ec:	00002617          	auipc	a2,0x2
ffffffffc02001f0:	b1c60613          	addi	a2,a2,-1252 # ffffffffc0201d08 <commands+0xe0>
ffffffffc02001f4:	00002597          	auipc	a1,0x2
ffffffffc02001f8:	b3458593          	addi	a1,a1,-1228 # ffffffffc0201d28 <commands+0x100>
ffffffffc02001fc:	00002517          	auipc	a0,0x2
ffffffffc0200200:	b3450513          	addi	a0,a0,-1228 # ffffffffc0201d30 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200204:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200206:	eb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020020a:	00002617          	auipc	a2,0x2
ffffffffc020020e:	b3660613          	addi	a2,a2,-1226 # ffffffffc0201d40 <commands+0x118>
ffffffffc0200212:	00002597          	auipc	a1,0x2
ffffffffc0200216:	b5658593          	addi	a1,a1,-1194 # ffffffffc0201d68 <commands+0x140>
ffffffffc020021a:	00002517          	auipc	a0,0x2
ffffffffc020021e:	b1650513          	addi	a0,a0,-1258 # ffffffffc0201d30 <commands+0x108>
ffffffffc0200222:	e95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200226:	00002617          	auipc	a2,0x2
ffffffffc020022a:	b5260613          	addi	a2,a2,-1198 # ffffffffc0201d78 <commands+0x150>
ffffffffc020022e:	00002597          	auipc	a1,0x2
ffffffffc0200232:	b6a58593          	addi	a1,a1,-1174 # ffffffffc0201d98 <commands+0x170>
ffffffffc0200236:	00002517          	auipc	a0,0x2
ffffffffc020023a:	afa50513          	addi	a0,a0,-1286 # ffffffffc0201d30 <commands+0x108>
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
ffffffffc0200270:	00002517          	auipc	a0,0x2
ffffffffc0200274:	a0050513          	addi	a0,a0,-1536 # ffffffffc0201c70 <commands+0x48>
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
ffffffffc0200292:	00002517          	auipc	a0,0x2
ffffffffc0200296:	a0650513          	addi	a0,a0,-1530 # ffffffffc0201c98 <commands+0x70>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029e:	000c0563          	beqz	s8,ffffffffc02002a8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a2:	8562                	mv	a0,s8
ffffffffc02002a4:	3a6000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002a8:	00002c97          	auipc	s9,0x2
ffffffffc02002ac:	980c8c93          	addi	s9,s9,-1664 # ffffffffc0201c28 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b0:	00002997          	auipc	s3,0x2
ffffffffc02002b4:	a1098993          	addi	s3,s3,-1520 # ffffffffc0201cc0 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00002917          	auipc	s2,0x2
ffffffffc02002bc:	a1090913          	addi	s2,s2,-1520 # ffffffffc0201cc8 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c2:	00002b17          	auipc	s6,0x2
ffffffffc02002c6:	a0eb0b13          	addi	s6,s6,-1522 # ffffffffc0201cd0 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002ca:	00002a97          	auipc	s5,0x2
ffffffffc02002ce:	a5ea8a93          	addi	s5,s5,-1442 # ffffffffc0201d28 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d4:	854e                	mv	a0,s3
ffffffffc02002d6:	698010ef          	jal	ra,ffffffffc020196e <readline>
ffffffffc02002da:	842a                	mv	s0,a0
ffffffffc02002dc:	dd65                	beqz	a0,ffffffffc02002d4 <kmonitor+0x6a>
ffffffffc02002de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e4:	c999                	beqz	a1,ffffffffc02002fa <kmonitor+0x90>
ffffffffc02002e6:	854a                	mv	a0,s2
ffffffffc02002e8:	7ea010ef          	jal	ra,ffffffffc0201ad2 <strchr>
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
ffffffffc02002fe:	00002d17          	auipc	s10,0x2
ffffffffc0200302:	92ad0d13          	addi	s10,s10,-1750 # ffffffffc0201c28 <commands>
    if (argc == 0) {
ffffffffc0200306:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200308:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	79c010ef          	jal	ra,ffffffffc0201aa8 <strcmp>
ffffffffc0200310:	c919                	beqz	a0,ffffffffc0200326 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	09740463          	beq	s0,s7,ffffffffc020039c <kmonitor+0x132>
ffffffffc0200318:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020031c:	6582                	ld	a1,0(sp)
ffffffffc020031e:	0d61                	addi	s10,s10,24
ffffffffc0200320:	788010ef          	jal	ra,ffffffffc0201aa8 <strcmp>
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
ffffffffc0200386:	74c010ef          	jal	ra,ffffffffc0201ad2 <strchr>
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
ffffffffc020039e:	00002517          	auipc	a0,0x2
ffffffffc02003a2:	95250513          	addi	a0,a0,-1710 # ffffffffc0201cf0 <commands+0xc8>
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
ffffffffc02003de:	00002517          	auipc	a0,0x2
ffffffffc02003e2:	9ca50513          	addi	a0,a0,-1590 # ffffffffc0201da8 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02003e6:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e8:	ccfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003ec:	65a2                	ld	a1,8(sp)
ffffffffc02003ee:	8522                	mv	a0,s0
ffffffffc02003f0:	ca7ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc02003f4:	00002517          	auipc	a0,0x2
ffffffffc02003f8:	82c50513          	addi	a0,a0,-2004 # ffffffffc0201c20 <etext+0x11e>
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
ffffffffc0200424:	624010ef          	jal	ra,ffffffffc0201a48 <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00002517          	auipc	a0,0x2
ffffffffc0200436:	99650513          	addi	a0,a0,-1642 # ffffffffc0201dc8 <commands+0x1a0>
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
ffffffffc020044c:	5fc0106f          	j	ffffffffc0201a48 <sbi_set_timer>

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
ffffffffc0200456:	5d60106f          	j	ffffffffc0201a2c <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	60a0106f          	j	ffffffffc0201a64 <sbi_console_getchar>

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
ffffffffc0200484:	00002517          	auipc	a0,0x2
ffffffffc0200488:	a5c50513          	addi	a0,a0,-1444 # ffffffffc0201ee0 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00002517          	auipc	a0,0x2
ffffffffc0200498:	a6450513          	addi	a0,a0,-1436 # ffffffffc0201ef8 <commands+0x2d0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00002517          	auipc	a0,0x2
ffffffffc02004a6:	a6e50513          	addi	a0,a0,-1426 # ffffffffc0201f10 <commands+0x2e8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00002517          	auipc	a0,0x2
ffffffffc02004b4:	a7850513          	addi	a0,a0,-1416 # ffffffffc0201f28 <commands+0x300>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00002517          	auipc	a0,0x2
ffffffffc02004c2:	a8250513          	addi	a0,a0,-1406 # ffffffffc0201f40 <commands+0x318>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00002517          	auipc	a0,0x2
ffffffffc02004d0:	a8c50513          	addi	a0,a0,-1396 # ffffffffc0201f58 <commands+0x330>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00002517          	auipc	a0,0x2
ffffffffc02004de:	a9650513          	addi	a0,a0,-1386 # ffffffffc0201f70 <commands+0x348>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00002517          	auipc	a0,0x2
ffffffffc02004ec:	aa050513          	addi	a0,a0,-1376 # ffffffffc0201f88 <commands+0x360>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00002517          	auipc	a0,0x2
ffffffffc02004fa:	aaa50513          	addi	a0,a0,-1366 # ffffffffc0201fa0 <commands+0x378>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00002517          	auipc	a0,0x2
ffffffffc0200508:	ab450513          	addi	a0,a0,-1356 # ffffffffc0201fb8 <commands+0x390>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00002517          	auipc	a0,0x2
ffffffffc0200516:	abe50513          	addi	a0,a0,-1346 # ffffffffc0201fd0 <commands+0x3a8>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00002517          	auipc	a0,0x2
ffffffffc0200524:	ac850513          	addi	a0,a0,-1336 # ffffffffc0201fe8 <commands+0x3c0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00002517          	auipc	a0,0x2
ffffffffc0200532:	ad250513          	addi	a0,a0,-1326 # ffffffffc0202000 <commands+0x3d8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	adc50513          	addi	a0,a0,-1316 # ffffffffc0202018 <commands+0x3f0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00002517          	auipc	a0,0x2
ffffffffc020054e:	ae650513          	addi	a0,a0,-1306 # ffffffffc0202030 <commands+0x408>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00002517          	auipc	a0,0x2
ffffffffc020055c:	af050513          	addi	a0,a0,-1296 # ffffffffc0202048 <commands+0x420>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	afa50513          	addi	a0,a0,-1286 # ffffffffc0202060 <commands+0x438>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00002517          	auipc	a0,0x2
ffffffffc0200578:	b0450513          	addi	a0,a0,-1276 # ffffffffc0202078 <commands+0x450>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00002517          	auipc	a0,0x2
ffffffffc0200586:	b0e50513          	addi	a0,a0,-1266 # ffffffffc0202090 <commands+0x468>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00002517          	auipc	a0,0x2
ffffffffc0200594:	b1850513          	addi	a0,a0,-1256 # ffffffffc02020a8 <commands+0x480>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00002517          	auipc	a0,0x2
ffffffffc02005a2:	b2250513          	addi	a0,a0,-1246 # ffffffffc02020c0 <commands+0x498>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	b2c50513          	addi	a0,a0,-1236 # ffffffffc02020d8 <commands+0x4b0>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00002517          	auipc	a0,0x2
ffffffffc02005be:	b3650513          	addi	a0,a0,-1226 # ffffffffc02020f0 <commands+0x4c8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00002517          	auipc	a0,0x2
ffffffffc02005cc:	b4050513          	addi	a0,a0,-1216 # ffffffffc0202108 <commands+0x4e0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	b4a50513          	addi	a0,a0,-1206 # ffffffffc0202120 <commands+0x4f8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	b5450513          	addi	a0,a0,-1196 # ffffffffc0202138 <commands+0x510>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	b5e50513          	addi	a0,a0,-1186 # ffffffffc0202150 <commands+0x528>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	b6850513          	addi	a0,a0,-1176 # ffffffffc0202168 <commands+0x540>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	b7250513          	addi	a0,a0,-1166 # ffffffffc0202180 <commands+0x558>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	b7c50513          	addi	a0,a0,-1156 # ffffffffc0202198 <commands+0x570>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	b8650513          	addi	a0,a0,-1146 # ffffffffc02021b0 <commands+0x588>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	b8c50513          	addi	a0,a0,-1140 # ffffffffc02021c8 <commands+0x5a0>
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
ffffffffc0200652:	00002517          	auipc	a0,0x2
ffffffffc0200656:	b8e50513          	addi	a0,a0,-1138 # ffffffffc02021e0 <commands+0x5b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065c:	a5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200660:	8522                	mv	a0,s0
ffffffffc0200662:	e1bff0ef          	jal	ra,ffffffffc020047c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200666:	10043583          	ld	a1,256(s0)
ffffffffc020066a:	00002517          	auipc	a0,0x2
ffffffffc020066e:	b8e50513          	addi	a0,a0,-1138 # ffffffffc02021f8 <commands+0x5d0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	b9650513          	addi	a0,a0,-1130 # ffffffffc0202210 <commands+0x5e8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	b9e50513          	addi	a0,a0,-1122 # ffffffffc0202228 <commands+0x600>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	ba250513          	addi	a0,a0,-1118 # ffffffffc0202240 <commands+0x618>
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
ffffffffc02006c0:	72870713          	addi	a4,a4,1832 # ffffffffc0201de4 <commands+0x1bc>
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
ffffffffc02006d2:	7aa50513          	addi	a0,a0,1962 # ffffffffc0201e78 <commands+0x250>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	77e50513          	addi	a0,a0,1918 # ffffffffc0201e58 <commands+0x230>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	73250513          	addi	a0,a0,1842 # ffffffffc0201e18 <commands+0x1f0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	7a650513          	addi	a0,a0,1958 # ffffffffc0201e98 <commands+0x270>
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
ffffffffc020072e:	79650513          	addi	a0,a0,1942 # ffffffffc0201ec0 <commands+0x298>
ffffffffc0200732:	985ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	70250513          	addi	a0,a0,1794 # ffffffffc0201e38 <commands+0x210>
ffffffffc020073e:	979ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00001517          	auipc	a0,0x1
ffffffffc0200750:	76450513          	addi	a0,a0,1892 # ffffffffc0201eb0 <commands+0x288>
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

ffffffffc020082a <best_fit_init>:
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

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200836:	0007a823          	sw	zero,16(a5)
}
ffffffffc020083a:	8082                	ret

ffffffffc020083c <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc020083c:	00006517          	auipc	a0,0x6
ffffffffc0200840:	c0c56503          	lwu	a0,-1012(a0) # ffffffffc0206448 <free_area+0x10>
ffffffffc0200844:	8082                	ret

ffffffffc0200846 <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc0200846:	c545                	beqz	a0,ffffffffc02008ee <best_fit_alloc_pages+0xa8>
    if (n > nr_free) {
ffffffffc0200848:	00006597          	auipc	a1,0x6
ffffffffc020084c:	bf058593          	addi	a1,a1,-1040 # ffffffffc0206438 <free_area>
ffffffffc0200850:	0105a883          	lw	a7,16(a1)
ffffffffc0200854:	862a                	mv	a2,a0
ffffffffc0200856:	02089793          	slli	a5,a7,0x20
ffffffffc020085a:	9381                	srli	a5,a5,0x20
ffffffffc020085c:	08a7e763          	bltu	a5,a0,ffffffffc02008ea <best_fit_alloc_pages+0xa4>
    unsigned int min_size = nr_free + 1;
ffffffffc0200860:	0018881b          	addiw	a6,a7,1
    list_entry_t *le = &free_list;
ffffffffc0200864:	87ae                	mv	a5,a1
    struct Page *page = NULL;
ffffffffc0200866:	4501                	li	a0,0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200868:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020086a:	02b78163          	beq	a5,a1,ffffffffc020088c <best_fit_alloc_pages+0x46>
        if ((p->property >= n) && (p->property < min_size)) {
ffffffffc020086e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200872:	02071693          	slli	a3,a4,0x20
ffffffffc0200876:	9281                	srli	a3,a3,0x20
ffffffffc0200878:	fec6e8e3          	bltu	a3,a2,ffffffffc0200868 <best_fit_alloc_pages+0x22>
ffffffffc020087c:	ff0776e3          	bleu	a6,a4,ffffffffc0200868 <best_fit_alloc_pages+0x22>
        struct Page *p = le2page(le, page_link);
ffffffffc0200880:	fe878513          	addi	a0,a5,-24
ffffffffc0200884:	679c                	ld	a5,8(a5)
ffffffffc0200886:	883a                	mv	a6,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200888:	feb793e3          	bne	a5,a1,ffffffffc020086e <best_fit_alloc_pages+0x28>
    if (page != NULL) {
ffffffffc020088c:	c125                	beqz	a0,ffffffffc02008ec <best_fit_alloc_pages+0xa6>
    __list_del(listelm->prev, listelm->next);
ffffffffc020088e:	7118                	ld	a4,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200890:	6d14                	ld	a3,24(a0)
        if (page->property > n) {
ffffffffc0200892:	490c                	lw	a1,16(a0)
ffffffffc0200894:	0006081b          	sext.w	a6,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200898:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc020089a:	e314                	sd	a3,0(a4)
ffffffffc020089c:	02059713          	slli	a4,a1,0x20
ffffffffc02008a0:	9301                	srli	a4,a4,0x20
ffffffffc02008a2:	02e67863          	bleu	a4,a2,ffffffffc02008d2 <best_fit_alloc_pages+0x8c>
            struct Page *p = page + n;
ffffffffc02008a6:	00261713          	slli	a4,a2,0x2
ffffffffc02008aa:	9732                	add	a4,a4,a2
ffffffffc02008ac:	070e                	slli	a4,a4,0x3
ffffffffc02008ae:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc02008b0:	410585bb          	subw	a1,a1,a6
ffffffffc02008b4:	cb0c                	sw	a1,16(a4)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02008b6:	4609                	li	a2,2
ffffffffc02008b8:	00870593          	addi	a1,a4,8
ffffffffc02008bc:	40c5b02f          	amoor.d	zero,a2,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02008c0:	6690                	ld	a2,8(a3)
            list_add(prev, &(p->page_link));
ffffffffc02008c2:	01870593          	addi	a1,a4,24
    prev->next = next->prev = elm;
ffffffffc02008c6:	0107a883          	lw	a7,16(a5)
ffffffffc02008ca:	e20c                	sd	a1,0(a2)
ffffffffc02008cc:	e68c                	sd	a1,8(a3)
    elm->next = next;
ffffffffc02008ce:	f310                	sd	a2,32(a4)
    elm->prev = prev;
ffffffffc02008d0:	ef14                	sd	a3,24(a4)
        nr_free -= n;
ffffffffc02008d2:	410888bb          	subw	a7,a7,a6
ffffffffc02008d6:	00006797          	auipc	a5,0x6
ffffffffc02008da:	b717a923          	sw	a7,-1166(a5) # ffffffffc0206448 <free_area+0x10>
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02008de:	57f5                	li	a5,-3
ffffffffc02008e0:	00850713          	addi	a4,a0,8
ffffffffc02008e4:	60f7302f          	amoand.d	zero,a5,(a4)
ffffffffc02008e8:	8082                	ret
        return NULL;
ffffffffc02008ea:	4501                	li	a0,0
}
ffffffffc02008ec:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc02008ee:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02008f0:	00002697          	auipc	a3,0x2
ffffffffc02008f4:	96868693          	addi	a3,a3,-1688 # ffffffffc0202258 <commands+0x630>
ffffffffc02008f8:	00002617          	auipc	a2,0x2
ffffffffc02008fc:	96860613          	addi	a2,a2,-1688 # ffffffffc0202260 <commands+0x638>
ffffffffc0200900:	06d00593          	li	a1,109
ffffffffc0200904:	00002517          	auipc	a0,0x2
ffffffffc0200908:	97450513          	addi	a0,a0,-1676 # ffffffffc0202278 <commands+0x650>
best_fit_alloc_pages(size_t n) {
ffffffffc020090c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020090e:	a9fff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200912 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200912:	715d                	addi	sp,sp,-80
ffffffffc0200914:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc0200916:	00006917          	auipc	s2,0x6
ffffffffc020091a:	b2290913          	addi	s2,s2,-1246 # ffffffffc0206438 <free_area>
ffffffffc020091e:	00893783          	ld	a5,8(s2)
ffffffffc0200922:	e486                	sd	ra,72(sp)
ffffffffc0200924:	e0a2                	sd	s0,64(sp)
ffffffffc0200926:	fc26                	sd	s1,56(sp)
ffffffffc0200928:	f44e                	sd	s3,40(sp)
ffffffffc020092a:	f052                	sd	s4,32(sp)
ffffffffc020092c:	ec56                	sd	s5,24(sp)
ffffffffc020092e:	e85a                	sd	s6,16(sp)
ffffffffc0200930:	e45e                	sd	s7,8(sp)
ffffffffc0200932:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200934:	2d278363          	beq	a5,s2,ffffffffc0200bfa <best_fit_check+0x2e8>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200938:	ff07b703          	ld	a4,-16(a5)
ffffffffc020093c:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020093e:	8b05                	andi	a4,a4,1
ffffffffc0200940:	2c070163          	beqz	a4,ffffffffc0200c02 <best_fit_check+0x2f0>
    int count = 0, total = 0;
ffffffffc0200944:	4401                	li	s0,0
ffffffffc0200946:	4481                	li	s1,0
ffffffffc0200948:	a031                	j	ffffffffc0200954 <best_fit_check+0x42>
ffffffffc020094a:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc020094e:	8b09                	andi	a4,a4,2
ffffffffc0200950:	2a070963          	beqz	a4,ffffffffc0200c02 <best_fit_check+0x2f0>
        count ++, total += p->property;
ffffffffc0200954:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200958:	679c                	ld	a5,8(a5)
ffffffffc020095a:	2485                	addiw	s1,s1,1
ffffffffc020095c:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020095e:	ff2796e3          	bne	a5,s2,ffffffffc020094a <best_fit_check+0x38>
ffffffffc0200962:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200964:	225000ef          	jal	ra,ffffffffc0201388 <nr_free_pages>
ffffffffc0200968:	37351d63          	bne	a0,s3,ffffffffc0200ce2 <best_fit_check+0x3d0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020096c:	4505                	li	a0,1
ffffffffc020096e:	191000ef          	jal	ra,ffffffffc02012fe <alloc_pages>
ffffffffc0200972:	8a2a                	mv	s4,a0
ffffffffc0200974:	3a050763          	beqz	a0,ffffffffc0200d22 <best_fit_check+0x410>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200978:	4505                	li	a0,1
ffffffffc020097a:	185000ef          	jal	ra,ffffffffc02012fe <alloc_pages>
ffffffffc020097e:	89aa                	mv	s3,a0
ffffffffc0200980:	38050163          	beqz	a0,ffffffffc0200d02 <best_fit_check+0x3f0>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200984:	4505                	li	a0,1
ffffffffc0200986:	179000ef          	jal	ra,ffffffffc02012fe <alloc_pages>
ffffffffc020098a:	8aaa                	mv	s5,a0
ffffffffc020098c:	30050b63          	beqz	a0,ffffffffc0200ca2 <best_fit_check+0x390>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200990:	293a0963          	beq	s4,s3,ffffffffc0200c22 <best_fit_check+0x310>
ffffffffc0200994:	28aa0763          	beq	s4,a0,ffffffffc0200c22 <best_fit_check+0x310>
ffffffffc0200998:	28a98563          	beq	s3,a0,ffffffffc0200c22 <best_fit_check+0x310>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020099c:	000a2783          	lw	a5,0(s4)
ffffffffc02009a0:	2a079163          	bnez	a5,ffffffffc0200c42 <best_fit_check+0x330>
ffffffffc02009a4:	0009a783          	lw	a5,0(s3)
ffffffffc02009a8:	28079d63          	bnez	a5,ffffffffc0200c42 <best_fit_check+0x330>
ffffffffc02009ac:	411c                	lw	a5,0(a0)
ffffffffc02009ae:	28079a63          	bnez	a5,ffffffffc0200c42 <best_fit_check+0x330>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009b2:	00006797          	auipc	a5,0x6
ffffffffc02009b6:	ab678793          	addi	a5,a5,-1354 # ffffffffc0206468 <pages>
ffffffffc02009ba:	639c                	ld	a5,0(a5)
ffffffffc02009bc:	00002717          	auipc	a4,0x2
ffffffffc02009c0:	8d470713          	addi	a4,a4,-1836 # ffffffffc0202290 <commands+0x668>
ffffffffc02009c4:	630c                	ld	a1,0(a4)
ffffffffc02009c6:	40fa0733          	sub	a4,s4,a5
ffffffffc02009ca:	870d                	srai	a4,a4,0x3
ffffffffc02009cc:	02b70733          	mul	a4,a4,a1
ffffffffc02009d0:	00002697          	auipc	a3,0x2
ffffffffc02009d4:	f8068693          	addi	a3,a3,-128 # ffffffffc0202950 <nbase>
ffffffffc02009d8:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02009da:	00006697          	auipc	a3,0x6
ffffffffc02009de:	a3e68693          	addi	a3,a3,-1474 # ffffffffc0206418 <npage>
ffffffffc02009e2:	6294                	ld	a3,0(a3)
ffffffffc02009e4:	06b2                	slli	a3,a3,0xc
ffffffffc02009e6:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc02009e8:	0732                	slli	a4,a4,0xc
ffffffffc02009ea:	26d77c63          	bleu	a3,a4,ffffffffc0200c62 <best_fit_check+0x350>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009ee:	40f98733          	sub	a4,s3,a5
ffffffffc02009f2:	870d                	srai	a4,a4,0x3
ffffffffc02009f4:	02b70733          	mul	a4,a4,a1
ffffffffc02009f8:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02009fa:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02009fc:	42d77363          	bleu	a3,a4,ffffffffc0200e22 <best_fit_check+0x510>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200a00:	40f507b3          	sub	a5,a0,a5
ffffffffc0200a04:	878d                	srai	a5,a5,0x3
ffffffffc0200a06:	02b787b3          	mul	a5,a5,a1
ffffffffc0200a0a:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200a0c:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200a0e:	3ed7fa63          	bleu	a3,a5,ffffffffc0200e02 <best_fit_check+0x4f0>
    assert(alloc_page() == NULL);
ffffffffc0200a12:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200a14:	00093c03          	ld	s8,0(s2)
ffffffffc0200a18:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200a1c:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200a20:	00006797          	auipc	a5,0x6
ffffffffc0200a24:	a327b023          	sd	s2,-1504(a5) # ffffffffc0206440 <free_area+0x8>
ffffffffc0200a28:	00006797          	auipc	a5,0x6
ffffffffc0200a2c:	a127b823          	sd	s2,-1520(a5) # ffffffffc0206438 <free_area>
    nr_free = 0;
ffffffffc0200a30:	00006797          	auipc	a5,0x6
ffffffffc0200a34:	a007ac23          	sw	zero,-1512(a5) # ffffffffc0206448 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200a38:	0c7000ef          	jal	ra,ffffffffc02012fe <alloc_pages>
ffffffffc0200a3c:	3a051363          	bnez	a0,ffffffffc0200de2 <best_fit_check+0x4d0>
    free_page(p0);
ffffffffc0200a40:	4585                	li	a1,1
ffffffffc0200a42:	8552                	mv	a0,s4
ffffffffc0200a44:	0ff000ef          	jal	ra,ffffffffc0201342 <free_pages>
    free_page(p1);
ffffffffc0200a48:	4585                	li	a1,1
ffffffffc0200a4a:	854e                	mv	a0,s3
ffffffffc0200a4c:	0f7000ef          	jal	ra,ffffffffc0201342 <free_pages>
    free_page(p2);
ffffffffc0200a50:	4585                	li	a1,1
ffffffffc0200a52:	8556                	mv	a0,s5
ffffffffc0200a54:	0ef000ef          	jal	ra,ffffffffc0201342 <free_pages>
    assert(nr_free == 3);
ffffffffc0200a58:	01092703          	lw	a4,16(s2)
ffffffffc0200a5c:	478d                	li	a5,3
ffffffffc0200a5e:	36f71263          	bne	a4,a5,ffffffffc0200dc2 <best_fit_check+0x4b0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200a62:	4505                	li	a0,1
ffffffffc0200a64:	09b000ef          	jal	ra,ffffffffc02012fe <alloc_pages>
ffffffffc0200a68:	89aa                	mv	s3,a0
ffffffffc0200a6a:	32050c63          	beqz	a0,ffffffffc0200da2 <best_fit_check+0x490>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200a6e:	4505                	li	a0,1
ffffffffc0200a70:	08f000ef          	jal	ra,ffffffffc02012fe <alloc_pages>
ffffffffc0200a74:	8aaa                	mv	s5,a0
ffffffffc0200a76:	30050663          	beqz	a0,ffffffffc0200d82 <best_fit_check+0x470>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200a7a:	4505                	li	a0,1
ffffffffc0200a7c:	083000ef          	jal	ra,ffffffffc02012fe <alloc_pages>
ffffffffc0200a80:	8a2a                	mv	s4,a0
ffffffffc0200a82:	2e050063          	beqz	a0,ffffffffc0200d62 <best_fit_check+0x450>
    assert(alloc_page() == NULL);
ffffffffc0200a86:	4505                	li	a0,1
ffffffffc0200a88:	077000ef          	jal	ra,ffffffffc02012fe <alloc_pages>
ffffffffc0200a8c:	2a051b63          	bnez	a0,ffffffffc0200d42 <best_fit_check+0x430>
    free_page(p0);
ffffffffc0200a90:	4585                	li	a1,1
ffffffffc0200a92:	854e                	mv	a0,s3
ffffffffc0200a94:	0af000ef          	jal	ra,ffffffffc0201342 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200a98:	00893783          	ld	a5,8(s2)
ffffffffc0200a9c:	1f278363          	beq	a5,s2,ffffffffc0200c82 <best_fit_check+0x370>
    assert((p = alloc_page()) == p0);
ffffffffc0200aa0:	4505                	li	a0,1
ffffffffc0200aa2:	05d000ef          	jal	ra,ffffffffc02012fe <alloc_pages>
ffffffffc0200aa6:	54a99e63          	bne	s3,a0,ffffffffc0201002 <best_fit_check+0x6f0>
    assert(alloc_page() == NULL);
ffffffffc0200aaa:	4505                	li	a0,1
ffffffffc0200aac:	053000ef          	jal	ra,ffffffffc02012fe <alloc_pages>
ffffffffc0200ab0:	52051963          	bnez	a0,ffffffffc0200fe2 <best_fit_check+0x6d0>
    assert(nr_free == 0);
ffffffffc0200ab4:	01092783          	lw	a5,16(s2)
ffffffffc0200ab8:	50079563          	bnez	a5,ffffffffc0200fc2 <best_fit_check+0x6b0>
    free_page(p);
ffffffffc0200abc:	854e                	mv	a0,s3
ffffffffc0200abe:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200ac0:	00006797          	auipc	a5,0x6
ffffffffc0200ac4:	9787bc23          	sd	s8,-1672(a5) # ffffffffc0206438 <free_area>
ffffffffc0200ac8:	00006797          	auipc	a5,0x6
ffffffffc0200acc:	9777bc23          	sd	s7,-1672(a5) # ffffffffc0206440 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200ad0:	00006797          	auipc	a5,0x6
ffffffffc0200ad4:	9767ac23          	sw	s6,-1672(a5) # ffffffffc0206448 <free_area+0x10>
    free_page(p);
ffffffffc0200ad8:	06b000ef          	jal	ra,ffffffffc0201342 <free_pages>
    free_page(p1);
ffffffffc0200adc:	4585                	li	a1,1
ffffffffc0200ade:	8556                	mv	a0,s5
ffffffffc0200ae0:	063000ef          	jal	ra,ffffffffc0201342 <free_pages>
    free_page(p2);
ffffffffc0200ae4:	4585                	li	a1,1
ffffffffc0200ae6:	8552                	mv	a0,s4
ffffffffc0200ae8:	05b000ef          	jal	ra,ffffffffc0201342 <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200aec:	4515                	li	a0,5
ffffffffc0200aee:	011000ef          	jal	ra,ffffffffc02012fe <alloc_pages>
ffffffffc0200af2:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200af4:	4a050763          	beqz	a0,ffffffffc0200fa2 <best_fit_check+0x690>
ffffffffc0200af8:	651c                	ld	a5,8(a0)
ffffffffc0200afa:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200afc:	8b85                	andi	a5,a5,1
ffffffffc0200afe:	48079263          	bnez	a5,ffffffffc0200f82 <best_fit_check+0x670>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200b02:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200b04:	00093b03          	ld	s6,0(s2)
ffffffffc0200b08:	00893a83          	ld	s5,8(s2)
ffffffffc0200b0c:	00006797          	auipc	a5,0x6
ffffffffc0200b10:	9327b623          	sd	s2,-1748(a5) # ffffffffc0206438 <free_area>
ffffffffc0200b14:	00006797          	auipc	a5,0x6
ffffffffc0200b18:	9327b623          	sd	s2,-1748(a5) # ffffffffc0206440 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200b1c:	7e2000ef          	jal	ra,ffffffffc02012fe <alloc_pages>
ffffffffc0200b20:	44051163          	bnez	a0,ffffffffc0200f62 <best_fit_check+0x650>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200b24:	4589                	li	a1,2
ffffffffc0200b26:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200b2a:	01092b83          	lw	s7,16(s2)
    free_pages(p0 + 4, 1);
ffffffffc0200b2e:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200b32:	00006797          	auipc	a5,0x6
ffffffffc0200b36:	9007ab23          	sw	zero,-1770(a5) # ffffffffc0206448 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200b3a:	009000ef          	jal	ra,ffffffffc0201342 <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200b3e:	8562                	mv	a0,s8
ffffffffc0200b40:	4585                	li	a1,1
ffffffffc0200b42:	001000ef          	jal	ra,ffffffffc0201342 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200b46:	4511                	li	a0,4
ffffffffc0200b48:	7b6000ef          	jal	ra,ffffffffc02012fe <alloc_pages>
ffffffffc0200b4c:	3e051b63          	bnez	a0,ffffffffc0200f42 <best_fit_check+0x630>
ffffffffc0200b50:	0309b783          	ld	a5,48(s3)
ffffffffc0200b54:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200b56:	8b85                	andi	a5,a5,1
ffffffffc0200b58:	3c078563          	beqz	a5,ffffffffc0200f22 <best_fit_check+0x610>
ffffffffc0200b5c:	0389a703          	lw	a4,56(s3)
ffffffffc0200b60:	4789                	li	a5,2
ffffffffc0200b62:	3cf71063          	bne	a4,a5,ffffffffc0200f22 <best_fit_check+0x610>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200b66:	4505                	li	a0,1
ffffffffc0200b68:	796000ef          	jal	ra,ffffffffc02012fe <alloc_pages>
ffffffffc0200b6c:	8a2a                	mv	s4,a0
ffffffffc0200b6e:	38050a63          	beqz	a0,ffffffffc0200f02 <best_fit_check+0x5f0>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200b72:	4509                	li	a0,2
ffffffffc0200b74:	78a000ef          	jal	ra,ffffffffc02012fe <alloc_pages>
ffffffffc0200b78:	36050563          	beqz	a0,ffffffffc0200ee2 <best_fit_check+0x5d0>
    assert(p0 + 4 == p1);
ffffffffc0200b7c:	354c1363          	bne	s8,s4,ffffffffc0200ec2 <best_fit_check+0x5b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200b80:	854e                	mv	a0,s3
ffffffffc0200b82:	4595                	li	a1,5
ffffffffc0200b84:	7be000ef          	jal	ra,ffffffffc0201342 <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200b88:	4515                	li	a0,5
ffffffffc0200b8a:	774000ef          	jal	ra,ffffffffc02012fe <alloc_pages>
ffffffffc0200b8e:	89aa                	mv	s3,a0
ffffffffc0200b90:	30050963          	beqz	a0,ffffffffc0200ea2 <best_fit_check+0x590>
    assert(alloc_page() == NULL);
ffffffffc0200b94:	4505                	li	a0,1
ffffffffc0200b96:	768000ef          	jal	ra,ffffffffc02012fe <alloc_pages>
ffffffffc0200b9a:	2e051463          	bnez	a0,ffffffffc0200e82 <best_fit_check+0x570>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200b9e:	01092783          	lw	a5,16(s2)
ffffffffc0200ba2:	2c079063          	bnez	a5,ffffffffc0200e62 <best_fit_check+0x550>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200ba6:	4595                	li	a1,5
ffffffffc0200ba8:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200baa:	00006797          	auipc	a5,0x6
ffffffffc0200bae:	8977af23          	sw	s7,-1890(a5) # ffffffffc0206448 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200bb2:	00006797          	auipc	a5,0x6
ffffffffc0200bb6:	8967b323          	sd	s6,-1914(a5) # ffffffffc0206438 <free_area>
ffffffffc0200bba:	00006797          	auipc	a5,0x6
ffffffffc0200bbe:	8957b323          	sd	s5,-1914(a5) # ffffffffc0206440 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200bc2:	780000ef          	jal	ra,ffffffffc0201342 <free_pages>
    return listelm->next;
ffffffffc0200bc6:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bca:	01278963          	beq	a5,s2,ffffffffc0200bdc <best_fit_check+0x2ca>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200bce:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200bd2:	679c                	ld	a5,8(a5)
ffffffffc0200bd4:	34fd                	addiw	s1,s1,-1
ffffffffc0200bd6:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bd8:	ff279be3          	bne	a5,s2,ffffffffc0200bce <best_fit_check+0x2bc>
    }
    assert(count == 0);
ffffffffc0200bdc:	26049363          	bnez	s1,ffffffffc0200e42 <best_fit_check+0x530>
    assert(total == 0);
ffffffffc0200be0:	e06d                	bnez	s0,ffffffffc0200cc2 <best_fit_check+0x3b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200be2:	60a6                	ld	ra,72(sp)
ffffffffc0200be4:	6406                	ld	s0,64(sp)
ffffffffc0200be6:	74e2                	ld	s1,56(sp)
ffffffffc0200be8:	7942                	ld	s2,48(sp)
ffffffffc0200bea:	79a2                	ld	s3,40(sp)
ffffffffc0200bec:	7a02                	ld	s4,32(sp)
ffffffffc0200bee:	6ae2                	ld	s5,24(sp)
ffffffffc0200bf0:	6b42                	ld	s6,16(sp)
ffffffffc0200bf2:	6ba2                	ld	s7,8(sp)
ffffffffc0200bf4:	6c02                	ld	s8,0(sp)
ffffffffc0200bf6:	6161                	addi	sp,sp,80
ffffffffc0200bf8:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bfa:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200bfc:	4401                	li	s0,0
ffffffffc0200bfe:	4481                	li	s1,0
ffffffffc0200c00:	b395                	j	ffffffffc0200964 <best_fit_check+0x52>
        assert(PageProperty(p));
ffffffffc0200c02:	00001697          	auipc	a3,0x1
ffffffffc0200c06:	69668693          	addi	a3,a3,1686 # ffffffffc0202298 <commands+0x670>
ffffffffc0200c0a:	00001617          	auipc	a2,0x1
ffffffffc0200c0e:	65660613          	addi	a2,a2,1622 # ffffffffc0202260 <commands+0x638>
ffffffffc0200c12:	10f00593          	li	a1,271
ffffffffc0200c16:	00001517          	auipc	a0,0x1
ffffffffc0200c1a:	66250513          	addi	a0,a0,1634 # ffffffffc0202278 <commands+0x650>
ffffffffc0200c1e:	f8eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c22:	00001697          	auipc	a3,0x1
ffffffffc0200c26:	70668693          	addi	a3,a3,1798 # ffffffffc0202328 <commands+0x700>
ffffffffc0200c2a:	00001617          	auipc	a2,0x1
ffffffffc0200c2e:	63660613          	addi	a2,a2,1590 # ffffffffc0202260 <commands+0x638>
ffffffffc0200c32:	0db00593          	li	a1,219
ffffffffc0200c36:	00001517          	auipc	a0,0x1
ffffffffc0200c3a:	64250513          	addi	a0,a0,1602 # ffffffffc0202278 <commands+0x650>
ffffffffc0200c3e:	f6eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c42:	00001697          	auipc	a3,0x1
ffffffffc0200c46:	70e68693          	addi	a3,a3,1806 # ffffffffc0202350 <commands+0x728>
ffffffffc0200c4a:	00001617          	auipc	a2,0x1
ffffffffc0200c4e:	61660613          	addi	a2,a2,1558 # ffffffffc0202260 <commands+0x638>
ffffffffc0200c52:	0dc00593          	li	a1,220
ffffffffc0200c56:	00001517          	auipc	a0,0x1
ffffffffc0200c5a:	62250513          	addi	a0,a0,1570 # ffffffffc0202278 <commands+0x650>
ffffffffc0200c5e:	f4eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c62:	00001697          	auipc	a3,0x1
ffffffffc0200c66:	72e68693          	addi	a3,a3,1838 # ffffffffc0202390 <commands+0x768>
ffffffffc0200c6a:	00001617          	auipc	a2,0x1
ffffffffc0200c6e:	5f660613          	addi	a2,a2,1526 # ffffffffc0202260 <commands+0x638>
ffffffffc0200c72:	0de00593          	li	a1,222
ffffffffc0200c76:	00001517          	auipc	a0,0x1
ffffffffc0200c7a:	60250513          	addi	a0,a0,1538 # ffffffffc0202278 <commands+0x650>
ffffffffc0200c7e:	f2eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200c82:	00001697          	auipc	a3,0x1
ffffffffc0200c86:	79668693          	addi	a3,a3,1942 # ffffffffc0202418 <commands+0x7f0>
ffffffffc0200c8a:	00001617          	auipc	a2,0x1
ffffffffc0200c8e:	5d660613          	addi	a2,a2,1494 # ffffffffc0202260 <commands+0x638>
ffffffffc0200c92:	0f700593          	li	a1,247
ffffffffc0200c96:	00001517          	auipc	a0,0x1
ffffffffc0200c9a:	5e250513          	addi	a0,a0,1506 # ffffffffc0202278 <commands+0x650>
ffffffffc0200c9e:	f0eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ca2:	00001697          	auipc	a3,0x1
ffffffffc0200ca6:	66668693          	addi	a3,a3,1638 # ffffffffc0202308 <commands+0x6e0>
ffffffffc0200caa:	00001617          	auipc	a2,0x1
ffffffffc0200cae:	5b660613          	addi	a2,a2,1462 # ffffffffc0202260 <commands+0x638>
ffffffffc0200cb2:	0d900593          	li	a1,217
ffffffffc0200cb6:	00001517          	auipc	a0,0x1
ffffffffc0200cba:	5c250513          	addi	a0,a0,1474 # ffffffffc0202278 <commands+0x650>
ffffffffc0200cbe:	eeeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == 0);
ffffffffc0200cc2:	00002697          	auipc	a3,0x2
ffffffffc0200cc6:	88668693          	addi	a3,a3,-1914 # ffffffffc0202548 <commands+0x920>
ffffffffc0200cca:	00001617          	auipc	a2,0x1
ffffffffc0200cce:	59660613          	addi	a2,a2,1430 # ffffffffc0202260 <commands+0x638>
ffffffffc0200cd2:	15100593          	li	a1,337
ffffffffc0200cd6:	00001517          	auipc	a0,0x1
ffffffffc0200cda:	5a250513          	addi	a0,a0,1442 # ffffffffc0202278 <commands+0x650>
ffffffffc0200cde:	eceff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == nr_free_pages());
ffffffffc0200ce2:	00001697          	auipc	a3,0x1
ffffffffc0200ce6:	5c668693          	addi	a3,a3,1478 # ffffffffc02022a8 <commands+0x680>
ffffffffc0200cea:	00001617          	auipc	a2,0x1
ffffffffc0200cee:	57660613          	addi	a2,a2,1398 # ffffffffc0202260 <commands+0x638>
ffffffffc0200cf2:	11200593          	li	a1,274
ffffffffc0200cf6:	00001517          	auipc	a0,0x1
ffffffffc0200cfa:	58250513          	addi	a0,a0,1410 # ffffffffc0202278 <commands+0x650>
ffffffffc0200cfe:	eaeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d02:	00001697          	auipc	a3,0x1
ffffffffc0200d06:	5e668693          	addi	a3,a3,1510 # ffffffffc02022e8 <commands+0x6c0>
ffffffffc0200d0a:	00001617          	auipc	a2,0x1
ffffffffc0200d0e:	55660613          	addi	a2,a2,1366 # ffffffffc0202260 <commands+0x638>
ffffffffc0200d12:	0d800593          	li	a1,216
ffffffffc0200d16:	00001517          	auipc	a0,0x1
ffffffffc0200d1a:	56250513          	addi	a0,a0,1378 # ffffffffc0202278 <commands+0x650>
ffffffffc0200d1e:	e8eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d22:	00001697          	auipc	a3,0x1
ffffffffc0200d26:	5a668693          	addi	a3,a3,1446 # ffffffffc02022c8 <commands+0x6a0>
ffffffffc0200d2a:	00001617          	auipc	a2,0x1
ffffffffc0200d2e:	53660613          	addi	a2,a2,1334 # ffffffffc0202260 <commands+0x638>
ffffffffc0200d32:	0d700593          	li	a1,215
ffffffffc0200d36:	00001517          	auipc	a0,0x1
ffffffffc0200d3a:	54250513          	addi	a0,a0,1346 # ffffffffc0202278 <commands+0x650>
ffffffffc0200d3e:	e6eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d42:	00001697          	auipc	a3,0x1
ffffffffc0200d46:	6ae68693          	addi	a3,a3,1710 # ffffffffc02023f0 <commands+0x7c8>
ffffffffc0200d4a:	00001617          	auipc	a2,0x1
ffffffffc0200d4e:	51660613          	addi	a2,a2,1302 # ffffffffc0202260 <commands+0x638>
ffffffffc0200d52:	0f400593          	li	a1,244
ffffffffc0200d56:	00001517          	auipc	a0,0x1
ffffffffc0200d5a:	52250513          	addi	a0,a0,1314 # ffffffffc0202278 <commands+0x650>
ffffffffc0200d5e:	e4eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d62:	00001697          	auipc	a3,0x1
ffffffffc0200d66:	5a668693          	addi	a3,a3,1446 # ffffffffc0202308 <commands+0x6e0>
ffffffffc0200d6a:	00001617          	auipc	a2,0x1
ffffffffc0200d6e:	4f660613          	addi	a2,a2,1270 # ffffffffc0202260 <commands+0x638>
ffffffffc0200d72:	0f200593          	li	a1,242
ffffffffc0200d76:	00001517          	auipc	a0,0x1
ffffffffc0200d7a:	50250513          	addi	a0,a0,1282 # ffffffffc0202278 <commands+0x650>
ffffffffc0200d7e:	e2eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d82:	00001697          	auipc	a3,0x1
ffffffffc0200d86:	56668693          	addi	a3,a3,1382 # ffffffffc02022e8 <commands+0x6c0>
ffffffffc0200d8a:	00001617          	auipc	a2,0x1
ffffffffc0200d8e:	4d660613          	addi	a2,a2,1238 # ffffffffc0202260 <commands+0x638>
ffffffffc0200d92:	0f100593          	li	a1,241
ffffffffc0200d96:	00001517          	auipc	a0,0x1
ffffffffc0200d9a:	4e250513          	addi	a0,a0,1250 # ffffffffc0202278 <commands+0x650>
ffffffffc0200d9e:	e0eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200da2:	00001697          	auipc	a3,0x1
ffffffffc0200da6:	52668693          	addi	a3,a3,1318 # ffffffffc02022c8 <commands+0x6a0>
ffffffffc0200daa:	00001617          	auipc	a2,0x1
ffffffffc0200dae:	4b660613          	addi	a2,a2,1206 # ffffffffc0202260 <commands+0x638>
ffffffffc0200db2:	0f000593          	li	a1,240
ffffffffc0200db6:	00001517          	auipc	a0,0x1
ffffffffc0200dba:	4c250513          	addi	a0,a0,1218 # ffffffffc0202278 <commands+0x650>
ffffffffc0200dbe:	deeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 3);
ffffffffc0200dc2:	00001697          	auipc	a3,0x1
ffffffffc0200dc6:	64668693          	addi	a3,a3,1606 # ffffffffc0202408 <commands+0x7e0>
ffffffffc0200dca:	00001617          	auipc	a2,0x1
ffffffffc0200dce:	49660613          	addi	a2,a2,1174 # ffffffffc0202260 <commands+0x638>
ffffffffc0200dd2:	0ee00593          	li	a1,238
ffffffffc0200dd6:	00001517          	auipc	a0,0x1
ffffffffc0200dda:	4a250513          	addi	a0,a0,1186 # ffffffffc0202278 <commands+0x650>
ffffffffc0200dde:	dceff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200de2:	00001697          	auipc	a3,0x1
ffffffffc0200de6:	60e68693          	addi	a3,a3,1550 # ffffffffc02023f0 <commands+0x7c8>
ffffffffc0200dea:	00001617          	auipc	a2,0x1
ffffffffc0200dee:	47660613          	addi	a2,a2,1142 # ffffffffc0202260 <commands+0x638>
ffffffffc0200df2:	0e900593          	li	a1,233
ffffffffc0200df6:	00001517          	auipc	a0,0x1
ffffffffc0200dfa:	48250513          	addi	a0,a0,1154 # ffffffffc0202278 <commands+0x650>
ffffffffc0200dfe:	daeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200e02:	00001697          	auipc	a3,0x1
ffffffffc0200e06:	5ce68693          	addi	a3,a3,1486 # ffffffffc02023d0 <commands+0x7a8>
ffffffffc0200e0a:	00001617          	auipc	a2,0x1
ffffffffc0200e0e:	45660613          	addi	a2,a2,1110 # ffffffffc0202260 <commands+0x638>
ffffffffc0200e12:	0e000593          	li	a1,224
ffffffffc0200e16:	00001517          	auipc	a0,0x1
ffffffffc0200e1a:	46250513          	addi	a0,a0,1122 # ffffffffc0202278 <commands+0x650>
ffffffffc0200e1e:	d8eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200e22:	00001697          	auipc	a3,0x1
ffffffffc0200e26:	58e68693          	addi	a3,a3,1422 # ffffffffc02023b0 <commands+0x788>
ffffffffc0200e2a:	00001617          	auipc	a2,0x1
ffffffffc0200e2e:	43660613          	addi	a2,a2,1078 # ffffffffc0202260 <commands+0x638>
ffffffffc0200e32:	0df00593          	li	a1,223
ffffffffc0200e36:	00001517          	auipc	a0,0x1
ffffffffc0200e3a:	44250513          	addi	a0,a0,1090 # ffffffffc0202278 <commands+0x650>
ffffffffc0200e3e:	d6eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(count == 0);
ffffffffc0200e42:	00001697          	auipc	a3,0x1
ffffffffc0200e46:	6f668693          	addi	a3,a3,1782 # ffffffffc0202538 <commands+0x910>
ffffffffc0200e4a:	00001617          	auipc	a2,0x1
ffffffffc0200e4e:	41660613          	addi	a2,a2,1046 # ffffffffc0202260 <commands+0x638>
ffffffffc0200e52:	15000593          	li	a1,336
ffffffffc0200e56:	00001517          	auipc	a0,0x1
ffffffffc0200e5a:	42250513          	addi	a0,a0,1058 # ffffffffc0202278 <commands+0x650>
ffffffffc0200e5e:	d4eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200e62:	00001697          	auipc	a3,0x1
ffffffffc0200e66:	5ee68693          	addi	a3,a3,1518 # ffffffffc0202450 <commands+0x828>
ffffffffc0200e6a:	00001617          	auipc	a2,0x1
ffffffffc0200e6e:	3f660613          	addi	a2,a2,1014 # ffffffffc0202260 <commands+0x638>
ffffffffc0200e72:	14500593          	li	a1,325
ffffffffc0200e76:	00001517          	auipc	a0,0x1
ffffffffc0200e7a:	40250513          	addi	a0,a0,1026 # ffffffffc0202278 <commands+0x650>
ffffffffc0200e7e:	d2eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e82:	00001697          	auipc	a3,0x1
ffffffffc0200e86:	56e68693          	addi	a3,a3,1390 # ffffffffc02023f0 <commands+0x7c8>
ffffffffc0200e8a:	00001617          	auipc	a2,0x1
ffffffffc0200e8e:	3d660613          	addi	a2,a2,982 # ffffffffc0202260 <commands+0x638>
ffffffffc0200e92:	13f00593          	li	a1,319
ffffffffc0200e96:	00001517          	auipc	a0,0x1
ffffffffc0200e9a:	3e250513          	addi	a0,a0,994 # ffffffffc0202278 <commands+0x650>
ffffffffc0200e9e:	d0eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200ea2:	00001697          	auipc	a3,0x1
ffffffffc0200ea6:	67668693          	addi	a3,a3,1654 # ffffffffc0202518 <commands+0x8f0>
ffffffffc0200eaa:	00001617          	auipc	a2,0x1
ffffffffc0200eae:	3b660613          	addi	a2,a2,950 # ffffffffc0202260 <commands+0x638>
ffffffffc0200eb2:	13e00593          	li	a1,318
ffffffffc0200eb6:	00001517          	auipc	a0,0x1
ffffffffc0200eba:	3c250513          	addi	a0,a0,962 # ffffffffc0202278 <commands+0x650>
ffffffffc0200ebe:	ceeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200ec2:	00001697          	auipc	a3,0x1
ffffffffc0200ec6:	64668693          	addi	a3,a3,1606 # ffffffffc0202508 <commands+0x8e0>
ffffffffc0200eca:	00001617          	auipc	a2,0x1
ffffffffc0200ece:	39660613          	addi	a2,a2,918 # ffffffffc0202260 <commands+0x638>
ffffffffc0200ed2:	13600593          	li	a1,310
ffffffffc0200ed6:	00001517          	auipc	a0,0x1
ffffffffc0200eda:	3a250513          	addi	a0,a0,930 # ffffffffc0202278 <commands+0x650>
ffffffffc0200ede:	cceff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200ee2:	00001697          	auipc	a3,0x1
ffffffffc0200ee6:	60e68693          	addi	a3,a3,1550 # ffffffffc02024f0 <commands+0x8c8>
ffffffffc0200eea:	00001617          	auipc	a2,0x1
ffffffffc0200eee:	37660613          	addi	a2,a2,886 # ffffffffc0202260 <commands+0x638>
ffffffffc0200ef2:	13500593          	li	a1,309
ffffffffc0200ef6:	00001517          	auipc	a0,0x1
ffffffffc0200efa:	38250513          	addi	a0,a0,898 # ffffffffc0202278 <commands+0x650>
ffffffffc0200efe:	caeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200f02:	00001697          	auipc	a3,0x1
ffffffffc0200f06:	5ce68693          	addi	a3,a3,1486 # ffffffffc02024d0 <commands+0x8a8>
ffffffffc0200f0a:	00001617          	auipc	a2,0x1
ffffffffc0200f0e:	35660613          	addi	a2,a2,854 # ffffffffc0202260 <commands+0x638>
ffffffffc0200f12:	13400593          	li	a1,308
ffffffffc0200f16:	00001517          	auipc	a0,0x1
ffffffffc0200f1a:	36250513          	addi	a0,a0,866 # ffffffffc0202278 <commands+0x650>
ffffffffc0200f1e:	c8eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200f22:	00001697          	auipc	a3,0x1
ffffffffc0200f26:	57e68693          	addi	a3,a3,1406 # ffffffffc02024a0 <commands+0x878>
ffffffffc0200f2a:	00001617          	auipc	a2,0x1
ffffffffc0200f2e:	33660613          	addi	a2,a2,822 # ffffffffc0202260 <commands+0x638>
ffffffffc0200f32:	13200593          	li	a1,306
ffffffffc0200f36:	00001517          	auipc	a0,0x1
ffffffffc0200f3a:	34250513          	addi	a0,a0,834 # ffffffffc0202278 <commands+0x650>
ffffffffc0200f3e:	c6eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200f42:	00001697          	auipc	a3,0x1
ffffffffc0200f46:	54668693          	addi	a3,a3,1350 # ffffffffc0202488 <commands+0x860>
ffffffffc0200f4a:	00001617          	auipc	a2,0x1
ffffffffc0200f4e:	31660613          	addi	a2,a2,790 # ffffffffc0202260 <commands+0x638>
ffffffffc0200f52:	13100593          	li	a1,305
ffffffffc0200f56:	00001517          	auipc	a0,0x1
ffffffffc0200f5a:	32250513          	addi	a0,a0,802 # ffffffffc0202278 <commands+0x650>
ffffffffc0200f5e:	c4eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f62:	00001697          	auipc	a3,0x1
ffffffffc0200f66:	48e68693          	addi	a3,a3,1166 # ffffffffc02023f0 <commands+0x7c8>
ffffffffc0200f6a:	00001617          	auipc	a2,0x1
ffffffffc0200f6e:	2f660613          	addi	a2,a2,758 # ffffffffc0202260 <commands+0x638>
ffffffffc0200f72:	12500593          	li	a1,293
ffffffffc0200f76:	00001517          	auipc	a0,0x1
ffffffffc0200f7a:	30250513          	addi	a0,a0,770 # ffffffffc0202278 <commands+0x650>
ffffffffc0200f7e:	c2eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageProperty(p0));
ffffffffc0200f82:	00001697          	auipc	a3,0x1
ffffffffc0200f86:	4ee68693          	addi	a3,a3,1262 # ffffffffc0202470 <commands+0x848>
ffffffffc0200f8a:	00001617          	auipc	a2,0x1
ffffffffc0200f8e:	2d660613          	addi	a2,a2,726 # ffffffffc0202260 <commands+0x638>
ffffffffc0200f92:	11c00593          	li	a1,284
ffffffffc0200f96:	00001517          	auipc	a0,0x1
ffffffffc0200f9a:	2e250513          	addi	a0,a0,738 # ffffffffc0202278 <commands+0x650>
ffffffffc0200f9e:	c0eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);
ffffffffc0200fa2:	00001697          	auipc	a3,0x1
ffffffffc0200fa6:	4be68693          	addi	a3,a3,1214 # ffffffffc0202460 <commands+0x838>
ffffffffc0200faa:	00001617          	auipc	a2,0x1
ffffffffc0200fae:	2b660613          	addi	a2,a2,694 # ffffffffc0202260 <commands+0x638>
ffffffffc0200fb2:	11b00593          	li	a1,283
ffffffffc0200fb6:	00001517          	auipc	a0,0x1
ffffffffc0200fba:	2c250513          	addi	a0,a0,706 # ffffffffc0202278 <commands+0x650>
ffffffffc0200fbe:	beeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200fc2:	00001697          	auipc	a3,0x1
ffffffffc0200fc6:	48e68693          	addi	a3,a3,1166 # ffffffffc0202450 <commands+0x828>
ffffffffc0200fca:	00001617          	auipc	a2,0x1
ffffffffc0200fce:	29660613          	addi	a2,a2,662 # ffffffffc0202260 <commands+0x638>
ffffffffc0200fd2:	0fd00593          	li	a1,253
ffffffffc0200fd6:	00001517          	auipc	a0,0x1
ffffffffc0200fda:	2a250513          	addi	a0,a0,674 # ffffffffc0202278 <commands+0x650>
ffffffffc0200fde:	bceff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fe2:	00001697          	auipc	a3,0x1
ffffffffc0200fe6:	40e68693          	addi	a3,a3,1038 # ffffffffc02023f0 <commands+0x7c8>
ffffffffc0200fea:	00001617          	auipc	a2,0x1
ffffffffc0200fee:	27660613          	addi	a2,a2,630 # ffffffffc0202260 <commands+0x638>
ffffffffc0200ff2:	0fb00593          	li	a1,251
ffffffffc0200ff6:	00001517          	auipc	a0,0x1
ffffffffc0200ffa:	28250513          	addi	a0,a0,642 # ffffffffc0202278 <commands+0x650>
ffffffffc0200ffe:	baeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201002:	00001697          	auipc	a3,0x1
ffffffffc0201006:	42e68693          	addi	a3,a3,1070 # ffffffffc0202430 <commands+0x808>
ffffffffc020100a:	00001617          	auipc	a2,0x1
ffffffffc020100e:	25660613          	addi	a2,a2,598 # ffffffffc0202260 <commands+0x638>
ffffffffc0201012:	0fa00593          	li	a1,250
ffffffffc0201016:	00001517          	auipc	a0,0x1
ffffffffc020101a:	26250513          	addi	a0,a0,610 # ffffffffc0202278 <commands+0x650>
ffffffffc020101e:	b8eff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201022 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0201022:	1141                	addi	sp,sp,-16
ffffffffc0201024:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201026:	18058063          	beqz	a1,ffffffffc02011a6 <best_fit_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc020102a:	00259693          	slli	a3,a1,0x2
ffffffffc020102e:	96ae                	add	a3,a3,a1
ffffffffc0201030:	068e                	slli	a3,a3,0x3
ffffffffc0201032:	96aa                	add	a3,a3,a0
ffffffffc0201034:	02d50d63          	beq	a0,a3,ffffffffc020106e <best_fit_free_pages+0x4c>
ffffffffc0201038:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020103a:	8b85                	andi	a5,a5,1
ffffffffc020103c:	14079563          	bnez	a5,ffffffffc0201186 <best_fit_free_pages+0x164>
ffffffffc0201040:	651c                	ld	a5,8(a0)
ffffffffc0201042:	8385                	srli	a5,a5,0x1
ffffffffc0201044:	8b85                	andi	a5,a5,1
ffffffffc0201046:	14079063          	bnez	a5,ffffffffc0201186 <best_fit_free_pages+0x164>
ffffffffc020104a:	87aa                	mv	a5,a0
ffffffffc020104c:	a809                	j	ffffffffc020105e <best_fit_free_pages+0x3c>
ffffffffc020104e:	6798                	ld	a4,8(a5)
ffffffffc0201050:	8b05                	andi	a4,a4,1
ffffffffc0201052:	12071a63          	bnez	a4,ffffffffc0201186 <best_fit_free_pages+0x164>
ffffffffc0201056:	6798                	ld	a4,8(a5)
ffffffffc0201058:	8b09                	andi	a4,a4,2
ffffffffc020105a:	12071663          	bnez	a4,ffffffffc0201186 <best_fit_free_pages+0x164>
        p->flags = 0;
ffffffffc020105e:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201062:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201066:	02878793          	addi	a5,a5,40
ffffffffc020106a:	fed792e3          	bne	a5,a3,ffffffffc020104e <best_fit_free_pages+0x2c>
    base->property = n;
ffffffffc020106e:	2581                	sext.w	a1,a1
ffffffffc0201070:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201072:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201076:	4789                	li	a5,2
ffffffffc0201078:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020107c:	00005697          	auipc	a3,0x5
ffffffffc0201080:	3bc68693          	addi	a3,a3,956 # ffffffffc0206438 <free_area>
ffffffffc0201084:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201086:	669c                	ld	a5,8(a3)
ffffffffc0201088:	9db9                	addw	a1,a1,a4
ffffffffc020108a:	00005717          	auipc	a4,0x5
ffffffffc020108e:	3ab72f23          	sw	a1,958(a4) # ffffffffc0206448 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201092:	08d78f63          	beq	a5,a3,ffffffffc0201130 <best_fit_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc0201096:	fe878713          	addi	a4,a5,-24
ffffffffc020109a:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020109c:	4801                	li	a6,0
ffffffffc020109e:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02010a2:	00e56a63          	bltu	a0,a4,ffffffffc02010b6 <best_fit_free_pages+0x94>
    return listelm->next;
ffffffffc02010a6:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02010a8:	02d70563          	beq	a4,a3,ffffffffc02010d2 <best_fit_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02010ac:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02010ae:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02010b2:	fee57ae3          	bleu	a4,a0,ffffffffc02010a6 <best_fit_free_pages+0x84>
ffffffffc02010b6:	00080663          	beqz	a6,ffffffffc02010c2 <best_fit_free_pages+0xa0>
ffffffffc02010ba:	00005817          	auipc	a6,0x5
ffffffffc02010be:	36b83f23          	sd	a1,894(a6) # ffffffffc0206438 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02010c2:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc02010c4:	e390                	sd	a2,0(a5)
ffffffffc02010c6:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02010c8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02010ca:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc02010cc:	02d59163          	bne	a1,a3,ffffffffc02010ee <best_fit_free_pages+0xcc>
ffffffffc02010d0:	a091                	j	ffffffffc0201114 <best_fit_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc02010d2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02010d4:	f114                	sd	a3,32(a0)
ffffffffc02010d6:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02010d8:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02010da:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02010dc:	00d70563          	beq	a4,a3,ffffffffc02010e6 <best_fit_free_pages+0xc4>
ffffffffc02010e0:	4805                	li	a6,1
ffffffffc02010e2:	87ba                	mv	a5,a4
ffffffffc02010e4:	b7e9                	j	ffffffffc02010ae <best_fit_free_pages+0x8c>
ffffffffc02010e6:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02010e8:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02010ea:	02d78163          	beq	a5,a3,ffffffffc020110c <best_fit_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc02010ee:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc02010f2:	fe858613          	addi	a2,a1,-24
        if (p + p->property == base) {
ffffffffc02010f6:	02081713          	slli	a4,a6,0x20
ffffffffc02010fa:	9301                	srli	a4,a4,0x20
ffffffffc02010fc:	00271793          	slli	a5,a4,0x2
ffffffffc0201100:	97ba                	add	a5,a5,a4
ffffffffc0201102:	078e                	slli	a5,a5,0x3
ffffffffc0201104:	97b2                	add	a5,a5,a2
ffffffffc0201106:	02f50e63          	beq	a0,a5,ffffffffc0201142 <best_fit_free_pages+0x120>
ffffffffc020110a:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc020110c:	fe878713          	addi	a4,a5,-24
ffffffffc0201110:	00d78d63          	beq	a5,a3,ffffffffc020112a <best_fit_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc0201114:	490c                	lw	a1,16(a0)
ffffffffc0201116:	02059613          	slli	a2,a1,0x20
ffffffffc020111a:	9201                	srli	a2,a2,0x20
ffffffffc020111c:	00261693          	slli	a3,a2,0x2
ffffffffc0201120:	96b2                	add	a3,a3,a2
ffffffffc0201122:	068e                	slli	a3,a3,0x3
ffffffffc0201124:	96aa                	add	a3,a3,a0
ffffffffc0201126:	04d70063          	beq	a4,a3,ffffffffc0201166 <best_fit_free_pages+0x144>
}
ffffffffc020112a:	60a2                	ld	ra,8(sp)
ffffffffc020112c:	0141                	addi	sp,sp,16
ffffffffc020112e:	8082                	ret
ffffffffc0201130:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201132:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201136:	e398                	sd	a4,0(a5)
ffffffffc0201138:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020113a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020113c:	ed1c                	sd	a5,24(a0)
}
ffffffffc020113e:	0141                	addi	sp,sp,16
ffffffffc0201140:	8082                	ret
            p->property += base->property;
ffffffffc0201142:	491c                	lw	a5,16(a0)
ffffffffc0201144:	0107883b          	addw	a6,a5,a6
ffffffffc0201148:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020114c:	57f5                	li	a5,-3
ffffffffc020114e:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201152:	01853803          	ld	a6,24(a0)
ffffffffc0201156:	7118                	ld	a4,32(a0)
            base = p;
ffffffffc0201158:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc020115a:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc020115e:	659c                	ld	a5,8(a1)
ffffffffc0201160:	01073023          	sd	a6,0(a4)
ffffffffc0201164:	b765                	j	ffffffffc020110c <best_fit_free_pages+0xea>
            base->property += p->property;
ffffffffc0201166:	ff87a703          	lw	a4,-8(a5)
ffffffffc020116a:	ff078693          	addi	a3,a5,-16
ffffffffc020116e:	9db9                	addw	a1,a1,a4
ffffffffc0201170:	c90c                	sw	a1,16(a0)
ffffffffc0201172:	5775                	li	a4,-3
ffffffffc0201174:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201178:	6398                	ld	a4,0(a5)
ffffffffc020117a:	679c                	ld	a5,8(a5)
}
ffffffffc020117c:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020117e:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201180:	e398                	sd	a4,0(a5)
ffffffffc0201182:	0141                	addi	sp,sp,16
ffffffffc0201184:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201186:	00001697          	auipc	a3,0x1
ffffffffc020118a:	3d268693          	addi	a3,a3,978 # ffffffffc0202558 <commands+0x930>
ffffffffc020118e:	00001617          	auipc	a2,0x1
ffffffffc0201192:	0d260613          	addi	a2,a2,210 # ffffffffc0202260 <commands+0x638>
ffffffffc0201196:	09600593          	li	a1,150
ffffffffc020119a:	00001517          	auipc	a0,0x1
ffffffffc020119e:	0de50513          	addi	a0,a0,222 # ffffffffc0202278 <commands+0x650>
ffffffffc02011a2:	a0aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc02011a6:	00001697          	auipc	a3,0x1
ffffffffc02011aa:	0b268693          	addi	a3,a3,178 # ffffffffc0202258 <commands+0x630>
ffffffffc02011ae:	00001617          	auipc	a2,0x1
ffffffffc02011b2:	0b260613          	addi	a2,a2,178 # ffffffffc0202260 <commands+0x638>
ffffffffc02011b6:	09300593          	li	a1,147
ffffffffc02011ba:	00001517          	auipc	a0,0x1
ffffffffc02011be:	0be50513          	addi	a0,a0,190 # ffffffffc0202278 <commands+0x650>
ffffffffc02011c2:	9eaff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02011c6 <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc02011c6:	1141                	addi	sp,sp,-16
ffffffffc02011c8:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02011ca:	10058a63          	beqz	a1,ffffffffc02012de <best_fit_init_memmap+0x118>
    for (; p != base + n; p ++) {
ffffffffc02011ce:	00259693          	slli	a3,a1,0x2
ffffffffc02011d2:	96ae                	add	a3,a3,a1
ffffffffc02011d4:	068e                	slli	a3,a3,0x3
ffffffffc02011d6:	96aa                	add	a3,a3,a0
ffffffffc02011d8:	02d50a63          	beq	a0,a3,ffffffffc020120c <best_fit_init_memmap+0x46>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02011dc:	651c                	ld	a5,8(a0)
        assert(PageReserved(p));
ffffffffc02011de:	8b85                	andi	a5,a5,1
ffffffffc02011e0:	cff9                	beqz	a5,ffffffffc02012be <best_fit_init_memmap+0xf8>
ffffffffc02011e2:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02011e4:	87aa                	mv	a5,a0
ffffffffc02011e6:	8b05                	andi	a4,a4,1
ffffffffc02011e8:	eb01                	bnez	a4,ffffffffc02011f8 <best_fit_init_memmap+0x32>
ffffffffc02011ea:	a855                	j	ffffffffc020129e <best_fit_init_memmap+0xd8>
ffffffffc02011ec:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02011ee:	8b05                	andi	a4,a4,1
ffffffffc02011f0:	c779                	beqz	a4,ffffffffc02012be <best_fit_init_memmap+0xf8>
ffffffffc02011f2:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02011f4:	8b05                	andi	a4,a4,1
ffffffffc02011f6:	c745                	beqz	a4,ffffffffc020129e <best_fit_init_memmap+0xd8>
        p->flags = p->property = 0;
ffffffffc02011f8:	0007a823          	sw	zero,16(a5)
ffffffffc02011fc:	0007b423          	sd	zero,8(a5)
ffffffffc0201200:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201204:	02878793          	addi	a5,a5,40
ffffffffc0201208:	fed792e3          	bne	a5,a3,ffffffffc02011ec <best_fit_init_memmap+0x26>
    base->property = n;
ffffffffc020120c:	2581                	sext.w	a1,a1
ffffffffc020120e:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201210:	4789                	li	a5,2
ffffffffc0201212:	00850713          	addi	a4,a0,8
ffffffffc0201216:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020121a:	00005697          	auipc	a3,0x5
ffffffffc020121e:	21e68693          	addi	a3,a3,542 # ffffffffc0206438 <free_area>
ffffffffc0201222:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201224:	669c                	ld	a5,8(a3)
ffffffffc0201226:	9db9                	addw	a1,a1,a4
ffffffffc0201228:	00005717          	auipc	a4,0x5
ffffffffc020122c:	22b72023          	sw	a1,544(a4) # ffffffffc0206448 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201230:	04d78a63          	beq	a5,a3,ffffffffc0201284 <best_fit_init_memmap+0xbe>
            struct Page* page = le2page(le, page_link);
ffffffffc0201234:	fe878713          	addi	a4,a5,-24
ffffffffc0201238:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020123a:	4801                	li	a6,0
ffffffffc020123c:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201240:	00e56a63          	bltu	a0,a4,ffffffffc0201254 <best_fit_init_memmap+0x8e>
    return listelm->next;
ffffffffc0201244:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list) {
ffffffffc0201246:	02d70563          	beq	a4,a3,ffffffffc0201270 <best_fit_init_memmap+0xaa>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020124a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020124c:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201250:	fee57ae3          	bleu	a4,a0,ffffffffc0201244 <best_fit_init_memmap+0x7e>
ffffffffc0201254:	00080663          	beqz	a6,ffffffffc0201260 <best_fit_init_memmap+0x9a>
ffffffffc0201258:	00005717          	auipc	a4,0x5
ffffffffc020125c:	1eb73023          	sd	a1,480(a4) # ffffffffc0206438 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201260:	6398                	ld	a4,0(a5)
}
ffffffffc0201262:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201264:	e390                	sd	a2,0(a5)
ffffffffc0201266:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201268:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020126a:	ed18                	sd	a4,24(a0)
ffffffffc020126c:	0141                	addi	sp,sp,16
ffffffffc020126e:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201270:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201272:	f114                	sd	a3,32(a0)
ffffffffc0201274:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201276:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201278:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020127a:	00d70e63          	beq	a4,a3,ffffffffc0201296 <best_fit_init_memmap+0xd0>
ffffffffc020127e:	4805                	li	a6,1
ffffffffc0201280:	87ba                	mv	a5,a4
ffffffffc0201282:	b7e9                	j	ffffffffc020124c <best_fit_init_memmap+0x86>
}
ffffffffc0201284:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201286:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020128a:	e398                	sd	a4,0(a5)
ffffffffc020128c:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020128e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201290:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201292:	0141                	addi	sp,sp,16
ffffffffc0201294:	8082                	ret
ffffffffc0201296:	60a2                	ld	ra,8(sp)
ffffffffc0201298:	e290                	sd	a2,0(a3)
ffffffffc020129a:	0141                	addi	sp,sp,16
ffffffffc020129c:	8082                	ret
        assert(PageReserved(p));
ffffffffc020129e:	00001697          	auipc	a3,0x1
ffffffffc02012a2:	2e268693          	addi	a3,a3,738 # ffffffffc0202580 <commands+0x958>
ffffffffc02012a6:	00001617          	auipc	a2,0x1
ffffffffc02012aa:	fba60613          	addi	a2,a2,-70 # ffffffffc0202260 <commands+0x638>
ffffffffc02012ae:	04e00593          	li	a1,78
ffffffffc02012b2:	00001517          	auipc	a0,0x1
ffffffffc02012b6:	fc650513          	addi	a0,a0,-58 # ffffffffc0202278 <commands+0x650>
ffffffffc02012ba:	8f2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
        assert(PageReserved(p));
ffffffffc02012be:	00001697          	auipc	a3,0x1
ffffffffc02012c2:	2c268693          	addi	a3,a3,706 # ffffffffc0202580 <commands+0x958>
ffffffffc02012c6:	00001617          	auipc	a2,0x1
ffffffffc02012ca:	f9a60613          	addi	a2,a2,-102 # ffffffffc0202260 <commands+0x638>
ffffffffc02012ce:	04a00593          	li	a1,74
ffffffffc02012d2:	00001517          	auipc	a0,0x1
ffffffffc02012d6:	fa650513          	addi	a0,a0,-90 # ffffffffc0202278 <commands+0x650>
ffffffffc02012da:	8d2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc02012de:	00001697          	auipc	a3,0x1
ffffffffc02012e2:	f7a68693          	addi	a3,a3,-134 # ffffffffc0202258 <commands+0x630>
ffffffffc02012e6:	00001617          	auipc	a2,0x1
ffffffffc02012ea:	f7a60613          	addi	a2,a2,-134 # ffffffffc0202260 <commands+0x638>
ffffffffc02012ee:	04700593          	li	a1,71
ffffffffc02012f2:	00001517          	auipc	a0,0x1
ffffffffc02012f6:	f8650513          	addi	a0,a0,-122 # ffffffffc0202278 <commands+0x650>
ffffffffc02012fa:	8b2ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02012fe <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012fe:	100027f3          	csrr	a5,sstatus
ffffffffc0201302:	8b89                	andi	a5,a5,2
ffffffffc0201304:	eb89                	bnez	a5,ffffffffc0201316 <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201306:	00005797          	auipc	a5,0x5
ffffffffc020130a:	15278793          	addi	a5,a5,338 # ffffffffc0206458 <pmm_manager>
ffffffffc020130e:	639c                	ld	a5,0(a5)
ffffffffc0201310:	0187b303          	ld	t1,24(a5)
ffffffffc0201314:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc0201316:	1141                	addi	sp,sp,-16
ffffffffc0201318:	e406                	sd	ra,8(sp)
ffffffffc020131a:	e022                	sd	s0,0(sp)
ffffffffc020131c:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020131e:	946ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201322:	00005797          	auipc	a5,0x5
ffffffffc0201326:	13678793          	addi	a5,a5,310 # ffffffffc0206458 <pmm_manager>
ffffffffc020132a:	639c                	ld	a5,0(a5)
ffffffffc020132c:	8522                	mv	a0,s0
ffffffffc020132e:	6f9c                	ld	a5,24(a5)
ffffffffc0201330:	9782                	jalr	a5
ffffffffc0201332:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0201334:	92aff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201338:	8522                	mv	a0,s0
ffffffffc020133a:	60a2                	ld	ra,8(sp)
ffffffffc020133c:	6402                	ld	s0,0(sp)
ffffffffc020133e:	0141                	addi	sp,sp,16
ffffffffc0201340:	8082                	ret

ffffffffc0201342 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201342:	100027f3          	csrr	a5,sstatus
ffffffffc0201346:	8b89                	andi	a5,a5,2
ffffffffc0201348:	eb89                	bnez	a5,ffffffffc020135a <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc020134a:	00005797          	auipc	a5,0x5
ffffffffc020134e:	10e78793          	addi	a5,a5,270 # ffffffffc0206458 <pmm_manager>
ffffffffc0201352:	639c                	ld	a5,0(a5)
ffffffffc0201354:	0207b303          	ld	t1,32(a5)
ffffffffc0201358:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc020135a:	1101                	addi	sp,sp,-32
ffffffffc020135c:	ec06                	sd	ra,24(sp)
ffffffffc020135e:	e822                	sd	s0,16(sp)
ffffffffc0201360:	e426                	sd	s1,8(sp)
ffffffffc0201362:	842a                	mv	s0,a0
ffffffffc0201364:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201366:	8feff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020136a:	00005797          	auipc	a5,0x5
ffffffffc020136e:	0ee78793          	addi	a5,a5,238 # ffffffffc0206458 <pmm_manager>
ffffffffc0201372:	639c                	ld	a5,0(a5)
ffffffffc0201374:	85a6                	mv	a1,s1
ffffffffc0201376:	8522                	mv	a0,s0
ffffffffc0201378:	739c                	ld	a5,32(a5)
ffffffffc020137a:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020137c:	6442                	ld	s0,16(sp)
ffffffffc020137e:	60e2                	ld	ra,24(sp)
ffffffffc0201380:	64a2                	ld	s1,8(sp)
ffffffffc0201382:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201384:	8daff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc0201388 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201388:	100027f3          	csrr	a5,sstatus
ffffffffc020138c:	8b89                	andi	a5,a5,2
ffffffffc020138e:	eb89                	bnez	a5,ffffffffc02013a0 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201390:	00005797          	auipc	a5,0x5
ffffffffc0201394:	0c878793          	addi	a5,a5,200 # ffffffffc0206458 <pmm_manager>
ffffffffc0201398:	639c                	ld	a5,0(a5)
ffffffffc020139a:	0287b303          	ld	t1,40(a5)
ffffffffc020139e:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc02013a0:	1141                	addi	sp,sp,-16
ffffffffc02013a2:	e406                	sd	ra,8(sp)
ffffffffc02013a4:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02013a6:	8beff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02013aa:	00005797          	auipc	a5,0x5
ffffffffc02013ae:	0ae78793          	addi	a5,a5,174 # ffffffffc0206458 <pmm_manager>
ffffffffc02013b2:	639c                	ld	a5,0(a5)
ffffffffc02013b4:	779c                	ld	a5,40(a5)
ffffffffc02013b6:	9782                	jalr	a5
ffffffffc02013b8:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02013ba:	8a4ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02013be:	8522                	mv	a0,s0
ffffffffc02013c0:	60a2                	ld	ra,8(sp)
ffffffffc02013c2:	6402                	ld	s0,0(sp)
ffffffffc02013c4:	0141                	addi	sp,sp,16
ffffffffc02013c6:	8082                	ret

ffffffffc02013c8 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02013c8:	00001797          	auipc	a5,0x1
ffffffffc02013cc:	1c878793          	addi	a5,a5,456 # ffffffffc0202590 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02013d0:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02013d2:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02013d4:	00001517          	auipc	a0,0x1
ffffffffc02013d8:	20c50513          	addi	a0,a0,524 # ffffffffc02025e0 <best_fit_pmm_manager+0x50>
void pmm_init(void) {
ffffffffc02013dc:	ec06                	sd	ra,24(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02013de:	00005717          	auipc	a4,0x5
ffffffffc02013e2:	06f73d23          	sd	a5,122(a4) # ffffffffc0206458 <pmm_manager>
void pmm_init(void) {
ffffffffc02013e6:	e822                	sd	s0,16(sp)
ffffffffc02013e8:	e426                	sd	s1,8(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02013ea:	00005417          	auipc	s0,0x5
ffffffffc02013ee:	06e40413          	addi	s0,s0,110 # ffffffffc0206458 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02013f2:	cc5fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc02013f6:	601c                	ld	a5,0(s0)
ffffffffc02013f8:	679c                	ld	a5,8(a5)
ffffffffc02013fa:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02013fc:	57f5                	li	a5,-3
ffffffffc02013fe:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201400:	00001517          	auipc	a0,0x1
ffffffffc0201404:	1f850513          	addi	a0,a0,504 # ffffffffc02025f8 <best_fit_pmm_manager+0x68>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201408:	00005717          	auipc	a4,0x5
ffffffffc020140c:	04f73c23          	sd	a5,88(a4) # ffffffffc0206460 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0201410:	ca7fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0201414:	46c5                	li	a3,17
ffffffffc0201416:	06ee                	slli	a3,a3,0x1b
ffffffffc0201418:	40100613          	li	a2,1025
ffffffffc020141c:	16fd                	addi	a3,a3,-1
ffffffffc020141e:	0656                	slli	a2,a2,0x15
ffffffffc0201420:	07e005b7          	lui	a1,0x7e00
ffffffffc0201424:	00001517          	auipc	a0,0x1
ffffffffc0201428:	1ec50513          	addi	a0,a0,492 # ffffffffc0202610 <best_fit_pmm_manager+0x80>
ffffffffc020142c:	c8bfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201430:	777d                	lui	a4,0xfffff
ffffffffc0201432:	00006797          	auipc	a5,0x6
ffffffffc0201436:	03d78793          	addi	a5,a5,61 # ffffffffc020746f <end+0xfff>
ffffffffc020143a:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc020143c:	00088737          	lui	a4,0x88
ffffffffc0201440:	00005697          	auipc	a3,0x5
ffffffffc0201444:	fce6bc23          	sd	a4,-40(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201448:	4601                	li	a2,0
ffffffffc020144a:	00005717          	auipc	a4,0x5
ffffffffc020144e:	00f73f23          	sd	a5,30(a4) # ffffffffc0206468 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201452:	4681                	li	a3,0
ffffffffc0201454:	00005897          	auipc	a7,0x5
ffffffffc0201458:	fc488893          	addi	a7,a7,-60 # ffffffffc0206418 <npage>
ffffffffc020145c:	00005597          	auipc	a1,0x5
ffffffffc0201460:	00c58593          	addi	a1,a1,12 # ffffffffc0206468 <pages>
ffffffffc0201464:	4805                	li	a6,1
ffffffffc0201466:	fff80537          	lui	a0,0xfff80
ffffffffc020146a:	a011                	j	ffffffffc020146e <pmm_init+0xa6>
ffffffffc020146c:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc020146e:	97b2                	add	a5,a5,a2
ffffffffc0201470:	07a1                	addi	a5,a5,8
ffffffffc0201472:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201476:	0008b703          	ld	a4,0(a7)
ffffffffc020147a:	0685                	addi	a3,a3,1
ffffffffc020147c:	02860613          	addi	a2,a2,40
ffffffffc0201480:	00a707b3          	add	a5,a4,a0
ffffffffc0201484:	fef6e4e3          	bltu	a3,a5,ffffffffc020146c <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201488:	6190                	ld	a2,0(a1)
ffffffffc020148a:	00271793          	slli	a5,a4,0x2
ffffffffc020148e:	97ba                	add	a5,a5,a4
ffffffffc0201490:	fec006b7          	lui	a3,0xfec00
ffffffffc0201494:	078e                	slli	a5,a5,0x3
ffffffffc0201496:	96b2                	add	a3,a3,a2
ffffffffc0201498:	96be                	add	a3,a3,a5
ffffffffc020149a:	c02007b7          	lui	a5,0xc0200
ffffffffc020149e:	08f6e863          	bltu	a3,a5,ffffffffc020152e <pmm_init+0x166>
ffffffffc02014a2:	00005497          	auipc	s1,0x5
ffffffffc02014a6:	fbe48493          	addi	s1,s1,-66 # ffffffffc0206460 <va_pa_offset>
ffffffffc02014aa:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc02014ac:	45c5                	li	a1,17
ffffffffc02014ae:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02014b0:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc02014b2:	04b6e963          	bltu	a3,a1,ffffffffc0201504 <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02014b6:	601c                	ld	a5,0(s0)
ffffffffc02014b8:	7b9c                	ld	a5,48(a5)
ffffffffc02014ba:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02014bc:	00001517          	auipc	a0,0x1
ffffffffc02014c0:	1ec50513          	addi	a0,a0,492 # ffffffffc02026a8 <best_fit_pmm_manager+0x118>
ffffffffc02014c4:	bf3fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02014c8:	00004697          	auipc	a3,0x4
ffffffffc02014cc:	b3868693          	addi	a3,a3,-1224 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02014d0:	00005797          	auipc	a5,0x5
ffffffffc02014d4:	f4d7b823          	sd	a3,-176(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02014d8:	c02007b7          	lui	a5,0xc0200
ffffffffc02014dc:	06f6e563          	bltu	a3,a5,ffffffffc0201546 <pmm_init+0x17e>
ffffffffc02014e0:	609c                	ld	a5,0(s1)
}
ffffffffc02014e2:	6442                	ld	s0,16(sp)
ffffffffc02014e4:	60e2                	ld	ra,24(sp)
ffffffffc02014e6:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02014e8:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc02014ea:	8e9d                	sub	a3,a3,a5
ffffffffc02014ec:	00005797          	auipc	a5,0x5
ffffffffc02014f0:	f6d7b223          	sd	a3,-156(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02014f4:	00001517          	auipc	a0,0x1
ffffffffc02014f8:	1d450513          	addi	a0,a0,468 # ffffffffc02026c8 <best_fit_pmm_manager+0x138>
ffffffffc02014fc:	8636                	mv	a2,a3
}
ffffffffc02014fe:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201500:	bb7fe06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201504:	6785                	lui	a5,0x1
ffffffffc0201506:	17fd                	addi	a5,a5,-1
ffffffffc0201508:	96be                	add	a3,a3,a5
ffffffffc020150a:	77fd                	lui	a5,0xfffff
ffffffffc020150c:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc020150e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201512:	04e7f663          	bleu	a4,a5,ffffffffc020155e <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc0201516:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201518:	97aa                	add	a5,a5,a0
ffffffffc020151a:	00279513          	slli	a0,a5,0x2
ffffffffc020151e:	953e                	add	a0,a0,a5
ffffffffc0201520:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201522:	8d95                	sub	a1,a1,a3
ffffffffc0201524:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201526:	81b1                	srli	a1,a1,0xc
ffffffffc0201528:	9532                	add	a0,a0,a2
ffffffffc020152a:	9782                	jalr	a5
ffffffffc020152c:	b769                	j	ffffffffc02014b6 <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020152e:	00001617          	auipc	a2,0x1
ffffffffc0201532:	11260613          	addi	a2,a2,274 # ffffffffc0202640 <best_fit_pmm_manager+0xb0>
ffffffffc0201536:	06f00593          	li	a1,111
ffffffffc020153a:	00001517          	auipc	a0,0x1
ffffffffc020153e:	12e50513          	addi	a0,a0,302 # ffffffffc0202668 <best_fit_pmm_manager+0xd8>
ffffffffc0201542:	e6bfe0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201546:	00001617          	auipc	a2,0x1
ffffffffc020154a:	0fa60613          	addi	a2,a2,250 # ffffffffc0202640 <best_fit_pmm_manager+0xb0>
ffffffffc020154e:	08a00593          	li	a1,138
ffffffffc0201552:	00001517          	auipc	a0,0x1
ffffffffc0201556:	11650513          	addi	a0,a0,278 # ffffffffc0202668 <best_fit_pmm_manager+0xd8>
ffffffffc020155a:	e53fe0ef          	jal	ra,ffffffffc02003ac <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020155e:	00001617          	auipc	a2,0x1
ffffffffc0201562:	11a60613          	addi	a2,a2,282 # ffffffffc0202678 <best_fit_pmm_manager+0xe8>
ffffffffc0201566:	06b00593          	li	a1,107
ffffffffc020156a:	00001517          	auipc	a0,0x1
ffffffffc020156e:	12e50513          	addi	a0,a0,302 # ffffffffc0202698 <best_fit_pmm_manager+0x108>
ffffffffc0201572:	e3bfe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201576 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201576:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020157a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020157c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201580:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201582:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201586:	f022                	sd	s0,32(sp)
ffffffffc0201588:	ec26                	sd	s1,24(sp)
ffffffffc020158a:	e84a                	sd	s2,16(sp)
ffffffffc020158c:	f406                	sd	ra,40(sp)
ffffffffc020158e:	e44e                	sd	s3,8(sp)
ffffffffc0201590:	84aa                	mv	s1,a0
ffffffffc0201592:	892e                	mv	s2,a1
ffffffffc0201594:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201598:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc020159a:	03067e63          	bleu	a6,a2,ffffffffc02015d6 <printnum+0x60>
ffffffffc020159e:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02015a0:	00805763          	blez	s0,ffffffffc02015ae <printnum+0x38>
ffffffffc02015a4:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02015a6:	85ca                	mv	a1,s2
ffffffffc02015a8:	854e                	mv	a0,s3
ffffffffc02015aa:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02015ac:	fc65                	bnez	s0,ffffffffc02015a4 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015ae:	1a02                	slli	s4,s4,0x20
ffffffffc02015b0:	020a5a13          	srli	s4,s4,0x20
ffffffffc02015b4:	00001797          	auipc	a5,0x1
ffffffffc02015b8:	2e478793          	addi	a5,a5,740 # ffffffffc0202898 <error_string+0x38>
ffffffffc02015bc:	9a3e                	add	s4,s4,a5
}
ffffffffc02015be:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015c0:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02015c4:	70a2                	ld	ra,40(sp)
ffffffffc02015c6:	69a2                	ld	s3,8(sp)
ffffffffc02015c8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015ca:	85ca                	mv	a1,s2
ffffffffc02015cc:	8326                	mv	t1,s1
}
ffffffffc02015ce:	6942                	ld	s2,16(sp)
ffffffffc02015d0:	64e2                	ld	s1,24(sp)
ffffffffc02015d2:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015d4:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02015d6:	03065633          	divu	a2,a2,a6
ffffffffc02015da:	8722                	mv	a4,s0
ffffffffc02015dc:	f9bff0ef          	jal	ra,ffffffffc0201576 <printnum>
ffffffffc02015e0:	b7f9                	j	ffffffffc02015ae <printnum+0x38>

ffffffffc02015e2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02015e2:	7119                	addi	sp,sp,-128
ffffffffc02015e4:	f4a6                	sd	s1,104(sp)
ffffffffc02015e6:	f0ca                	sd	s2,96(sp)
ffffffffc02015e8:	e8d2                	sd	s4,80(sp)
ffffffffc02015ea:	e4d6                	sd	s5,72(sp)
ffffffffc02015ec:	e0da                	sd	s6,64(sp)
ffffffffc02015ee:	fc5e                	sd	s7,56(sp)
ffffffffc02015f0:	f862                	sd	s8,48(sp)
ffffffffc02015f2:	f06a                	sd	s10,32(sp)
ffffffffc02015f4:	fc86                	sd	ra,120(sp)
ffffffffc02015f6:	f8a2                	sd	s0,112(sp)
ffffffffc02015f8:	ecce                	sd	s3,88(sp)
ffffffffc02015fa:	f466                	sd	s9,40(sp)
ffffffffc02015fc:	ec6e                	sd	s11,24(sp)
ffffffffc02015fe:	892a                	mv	s2,a0
ffffffffc0201600:	84ae                	mv	s1,a1
ffffffffc0201602:	8d32                	mv	s10,a2
ffffffffc0201604:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201606:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201608:	00001a17          	auipc	s4,0x1
ffffffffc020160c:	100a0a13          	addi	s4,s4,256 # ffffffffc0202708 <best_fit_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201610:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201614:	00001c17          	auipc	s8,0x1
ffffffffc0201618:	24cc0c13          	addi	s8,s8,588 # ffffffffc0202860 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020161c:	000d4503          	lbu	a0,0(s10)
ffffffffc0201620:	02500793          	li	a5,37
ffffffffc0201624:	001d0413          	addi	s0,s10,1
ffffffffc0201628:	00f50e63          	beq	a0,a5,ffffffffc0201644 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc020162c:	c521                	beqz	a0,ffffffffc0201674 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020162e:	02500993          	li	s3,37
ffffffffc0201632:	a011                	j	ffffffffc0201636 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0201634:	c121                	beqz	a0,ffffffffc0201674 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0201636:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201638:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020163a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020163c:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201640:	ff351ae3          	bne	a0,s3,ffffffffc0201634 <vprintfmt+0x52>
ffffffffc0201644:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201648:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020164c:	4981                	li	s3,0
ffffffffc020164e:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0201650:	5cfd                	li	s9,-1
ffffffffc0201652:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201654:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0201658:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020165a:	fdd6069b          	addiw	a3,a2,-35
ffffffffc020165e:	0ff6f693          	andi	a3,a3,255
ffffffffc0201662:	00140d13          	addi	s10,s0,1
ffffffffc0201666:	20d5e563          	bltu	a1,a3,ffffffffc0201870 <vprintfmt+0x28e>
ffffffffc020166a:	068a                	slli	a3,a3,0x2
ffffffffc020166c:	96d2                	add	a3,a3,s4
ffffffffc020166e:	4294                	lw	a3,0(a3)
ffffffffc0201670:	96d2                	add	a3,a3,s4
ffffffffc0201672:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201674:	70e6                	ld	ra,120(sp)
ffffffffc0201676:	7446                	ld	s0,112(sp)
ffffffffc0201678:	74a6                	ld	s1,104(sp)
ffffffffc020167a:	7906                	ld	s2,96(sp)
ffffffffc020167c:	69e6                	ld	s3,88(sp)
ffffffffc020167e:	6a46                	ld	s4,80(sp)
ffffffffc0201680:	6aa6                	ld	s5,72(sp)
ffffffffc0201682:	6b06                	ld	s6,64(sp)
ffffffffc0201684:	7be2                	ld	s7,56(sp)
ffffffffc0201686:	7c42                	ld	s8,48(sp)
ffffffffc0201688:	7ca2                	ld	s9,40(sp)
ffffffffc020168a:	7d02                	ld	s10,32(sp)
ffffffffc020168c:	6de2                	ld	s11,24(sp)
ffffffffc020168e:	6109                	addi	sp,sp,128
ffffffffc0201690:	8082                	ret
    if (lflag >= 2) {
ffffffffc0201692:	4705                	li	a4,1
ffffffffc0201694:	008a8593          	addi	a1,s5,8
ffffffffc0201698:	01074463          	blt	a4,a6,ffffffffc02016a0 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc020169c:	26080363          	beqz	a6,ffffffffc0201902 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc02016a0:	000ab603          	ld	a2,0(s5)
ffffffffc02016a4:	46c1                	li	a3,16
ffffffffc02016a6:	8aae                	mv	s5,a1
ffffffffc02016a8:	a06d                	j	ffffffffc0201752 <vprintfmt+0x170>
            goto reswitch;
ffffffffc02016aa:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02016ae:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016b0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02016b2:	b765                	j	ffffffffc020165a <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc02016b4:	000aa503          	lw	a0,0(s5)
ffffffffc02016b8:	85a6                	mv	a1,s1
ffffffffc02016ba:	0aa1                	addi	s5,s5,8
ffffffffc02016bc:	9902                	jalr	s2
            break;
ffffffffc02016be:	bfb9                	j	ffffffffc020161c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02016c0:	4705                	li	a4,1
ffffffffc02016c2:	008a8993          	addi	s3,s5,8
ffffffffc02016c6:	01074463          	blt	a4,a6,ffffffffc02016ce <vprintfmt+0xec>
    else if (lflag) {
ffffffffc02016ca:	22080463          	beqz	a6,ffffffffc02018f2 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc02016ce:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02016d2:	24044463          	bltz	s0,ffffffffc020191a <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02016d6:	8622                	mv	a2,s0
ffffffffc02016d8:	8ace                	mv	s5,s3
ffffffffc02016da:	46a9                	li	a3,10
ffffffffc02016dc:	a89d                	j	ffffffffc0201752 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02016de:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02016e2:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02016e4:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02016e6:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02016ea:	8fb5                	xor	a5,a5,a3
ffffffffc02016ec:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02016f0:	1ad74363          	blt	a4,a3,ffffffffc0201896 <vprintfmt+0x2b4>
ffffffffc02016f4:	00369793          	slli	a5,a3,0x3
ffffffffc02016f8:	97e2                	add	a5,a5,s8
ffffffffc02016fa:	639c                	ld	a5,0(a5)
ffffffffc02016fc:	18078d63          	beqz	a5,ffffffffc0201896 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201700:	86be                	mv	a3,a5
ffffffffc0201702:	00001617          	auipc	a2,0x1
ffffffffc0201706:	24660613          	addi	a2,a2,582 # ffffffffc0202948 <error_string+0xe8>
ffffffffc020170a:	85a6                	mv	a1,s1
ffffffffc020170c:	854a                	mv	a0,s2
ffffffffc020170e:	240000ef          	jal	ra,ffffffffc020194e <printfmt>
ffffffffc0201712:	b729                	j	ffffffffc020161c <vprintfmt+0x3a>
            lflag ++;
ffffffffc0201714:	00144603          	lbu	a2,1(s0)
ffffffffc0201718:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020171a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020171c:	bf3d                	j	ffffffffc020165a <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc020171e:	4705                	li	a4,1
ffffffffc0201720:	008a8593          	addi	a1,s5,8
ffffffffc0201724:	01074463          	blt	a4,a6,ffffffffc020172c <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0201728:	1e080263          	beqz	a6,ffffffffc020190c <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc020172c:	000ab603          	ld	a2,0(s5)
ffffffffc0201730:	46a1                	li	a3,8
ffffffffc0201732:	8aae                	mv	s5,a1
ffffffffc0201734:	a839                	j	ffffffffc0201752 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0201736:	03000513          	li	a0,48
ffffffffc020173a:	85a6                	mv	a1,s1
ffffffffc020173c:	e03e                	sd	a5,0(sp)
ffffffffc020173e:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201740:	85a6                	mv	a1,s1
ffffffffc0201742:	07800513          	li	a0,120
ffffffffc0201746:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201748:	0aa1                	addi	s5,s5,8
ffffffffc020174a:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc020174e:	6782                	ld	a5,0(sp)
ffffffffc0201750:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201752:	876e                	mv	a4,s11
ffffffffc0201754:	85a6                	mv	a1,s1
ffffffffc0201756:	854a                	mv	a0,s2
ffffffffc0201758:	e1fff0ef          	jal	ra,ffffffffc0201576 <printnum>
            break;
ffffffffc020175c:	b5c1                	j	ffffffffc020161c <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020175e:	000ab603          	ld	a2,0(s5)
ffffffffc0201762:	0aa1                	addi	s5,s5,8
ffffffffc0201764:	1c060663          	beqz	a2,ffffffffc0201930 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0201768:	00160413          	addi	s0,a2,1
ffffffffc020176c:	17b05c63          	blez	s11,ffffffffc02018e4 <vprintfmt+0x302>
ffffffffc0201770:	02d00593          	li	a1,45
ffffffffc0201774:	14b79263          	bne	a5,a1,ffffffffc02018b8 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201778:	00064783          	lbu	a5,0(a2)
ffffffffc020177c:	0007851b          	sext.w	a0,a5
ffffffffc0201780:	c905                	beqz	a0,ffffffffc02017b0 <vprintfmt+0x1ce>
ffffffffc0201782:	000cc563          	bltz	s9,ffffffffc020178c <vprintfmt+0x1aa>
ffffffffc0201786:	3cfd                	addiw	s9,s9,-1
ffffffffc0201788:	036c8263          	beq	s9,s6,ffffffffc02017ac <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc020178c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020178e:	18098463          	beqz	s3,ffffffffc0201916 <vprintfmt+0x334>
ffffffffc0201792:	3781                	addiw	a5,a5,-32
ffffffffc0201794:	18fbf163          	bleu	a5,s7,ffffffffc0201916 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0201798:	03f00513          	li	a0,63
ffffffffc020179c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020179e:	0405                	addi	s0,s0,1
ffffffffc02017a0:	fff44783          	lbu	a5,-1(s0)
ffffffffc02017a4:	3dfd                	addiw	s11,s11,-1
ffffffffc02017a6:	0007851b          	sext.w	a0,a5
ffffffffc02017aa:	fd61                	bnez	a0,ffffffffc0201782 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc02017ac:	e7b058e3          	blez	s11,ffffffffc020161c <vprintfmt+0x3a>
ffffffffc02017b0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02017b2:	85a6                	mv	a1,s1
ffffffffc02017b4:	02000513          	li	a0,32
ffffffffc02017b8:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02017ba:	e60d81e3          	beqz	s11,ffffffffc020161c <vprintfmt+0x3a>
ffffffffc02017be:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02017c0:	85a6                	mv	a1,s1
ffffffffc02017c2:	02000513          	li	a0,32
ffffffffc02017c6:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02017c8:	fe0d94e3          	bnez	s11,ffffffffc02017b0 <vprintfmt+0x1ce>
ffffffffc02017cc:	bd81                	j	ffffffffc020161c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02017ce:	4705                	li	a4,1
ffffffffc02017d0:	008a8593          	addi	a1,s5,8
ffffffffc02017d4:	01074463          	blt	a4,a6,ffffffffc02017dc <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02017d8:	12080063          	beqz	a6,ffffffffc02018f8 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02017dc:	000ab603          	ld	a2,0(s5)
ffffffffc02017e0:	46a9                	li	a3,10
ffffffffc02017e2:	8aae                	mv	s5,a1
ffffffffc02017e4:	b7bd                	j	ffffffffc0201752 <vprintfmt+0x170>
ffffffffc02017e6:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02017ea:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017ee:	846a                	mv	s0,s10
ffffffffc02017f0:	b5ad                	j	ffffffffc020165a <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02017f2:	85a6                	mv	a1,s1
ffffffffc02017f4:	02500513          	li	a0,37
ffffffffc02017f8:	9902                	jalr	s2
            break;
ffffffffc02017fa:	b50d                	j	ffffffffc020161c <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02017fc:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0201800:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201804:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201806:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0201808:	e40dd9e3          	bgez	s11,ffffffffc020165a <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc020180c:	8de6                	mv	s11,s9
ffffffffc020180e:	5cfd                	li	s9,-1
ffffffffc0201810:	b5a9                	j	ffffffffc020165a <vprintfmt+0x78>
            goto reswitch;
ffffffffc0201812:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0201816:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020181a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020181c:	bd3d                	j	ffffffffc020165a <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc020181e:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0201822:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201826:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201828:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020182c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201830:	fcd56ce3          	bltu	a0,a3,ffffffffc0201808 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0201834:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201836:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc020183a:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020183e:	0196873b          	addw	a4,a3,s9
ffffffffc0201842:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201846:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc020184a:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc020184e:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201852:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201856:	fcd57fe3          	bleu	a3,a0,ffffffffc0201834 <vprintfmt+0x252>
ffffffffc020185a:	b77d                	j	ffffffffc0201808 <vprintfmt+0x226>
            if (width < 0)
ffffffffc020185c:	fffdc693          	not	a3,s11
ffffffffc0201860:	96fd                	srai	a3,a3,0x3f
ffffffffc0201862:	00ddfdb3          	and	s11,s11,a3
ffffffffc0201866:	00144603          	lbu	a2,1(s0)
ffffffffc020186a:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020186c:	846a                	mv	s0,s10
ffffffffc020186e:	b3f5                	j	ffffffffc020165a <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0201870:	85a6                	mv	a1,s1
ffffffffc0201872:	02500513          	li	a0,37
ffffffffc0201876:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201878:	fff44703          	lbu	a4,-1(s0)
ffffffffc020187c:	02500793          	li	a5,37
ffffffffc0201880:	8d22                	mv	s10,s0
ffffffffc0201882:	d8f70de3          	beq	a4,a5,ffffffffc020161c <vprintfmt+0x3a>
ffffffffc0201886:	02500713          	li	a4,37
ffffffffc020188a:	1d7d                	addi	s10,s10,-1
ffffffffc020188c:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0201890:	fee79de3          	bne	a5,a4,ffffffffc020188a <vprintfmt+0x2a8>
ffffffffc0201894:	b361                	j	ffffffffc020161c <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201896:	00001617          	auipc	a2,0x1
ffffffffc020189a:	0a260613          	addi	a2,a2,162 # ffffffffc0202938 <error_string+0xd8>
ffffffffc020189e:	85a6                	mv	a1,s1
ffffffffc02018a0:	854a                	mv	a0,s2
ffffffffc02018a2:	0ac000ef          	jal	ra,ffffffffc020194e <printfmt>
ffffffffc02018a6:	bb9d                	j	ffffffffc020161c <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02018a8:	00001617          	auipc	a2,0x1
ffffffffc02018ac:	08860613          	addi	a2,a2,136 # ffffffffc0202930 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc02018b0:	00001417          	auipc	s0,0x1
ffffffffc02018b4:	08140413          	addi	s0,s0,129 # ffffffffc0202931 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02018b8:	8532                	mv	a0,a2
ffffffffc02018ba:	85e6                	mv	a1,s9
ffffffffc02018bc:	e032                	sd	a2,0(sp)
ffffffffc02018be:	e43e                	sd	a5,8(sp)
ffffffffc02018c0:	1c2000ef          	jal	ra,ffffffffc0201a82 <strnlen>
ffffffffc02018c4:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02018c8:	6602                	ld	a2,0(sp)
ffffffffc02018ca:	01b05d63          	blez	s11,ffffffffc02018e4 <vprintfmt+0x302>
ffffffffc02018ce:	67a2                	ld	a5,8(sp)
ffffffffc02018d0:	2781                	sext.w	a5,a5
ffffffffc02018d2:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02018d4:	6522                	ld	a0,8(sp)
ffffffffc02018d6:	85a6                	mv	a1,s1
ffffffffc02018d8:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02018da:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02018dc:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02018de:	6602                	ld	a2,0(sp)
ffffffffc02018e0:	fe0d9ae3          	bnez	s11,ffffffffc02018d4 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018e4:	00064783          	lbu	a5,0(a2)
ffffffffc02018e8:	0007851b          	sext.w	a0,a5
ffffffffc02018ec:	e8051be3          	bnez	a0,ffffffffc0201782 <vprintfmt+0x1a0>
ffffffffc02018f0:	b335                	j	ffffffffc020161c <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02018f2:	000aa403          	lw	s0,0(s5)
ffffffffc02018f6:	bbf1                	j	ffffffffc02016d2 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02018f8:	000ae603          	lwu	a2,0(s5)
ffffffffc02018fc:	46a9                	li	a3,10
ffffffffc02018fe:	8aae                	mv	s5,a1
ffffffffc0201900:	bd89                	j	ffffffffc0201752 <vprintfmt+0x170>
ffffffffc0201902:	000ae603          	lwu	a2,0(s5)
ffffffffc0201906:	46c1                	li	a3,16
ffffffffc0201908:	8aae                	mv	s5,a1
ffffffffc020190a:	b5a1                	j	ffffffffc0201752 <vprintfmt+0x170>
ffffffffc020190c:	000ae603          	lwu	a2,0(s5)
ffffffffc0201910:	46a1                	li	a3,8
ffffffffc0201912:	8aae                	mv	s5,a1
ffffffffc0201914:	bd3d                	j	ffffffffc0201752 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0201916:	9902                	jalr	s2
ffffffffc0201918:	b559                	j	ffffffffc020179e <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc020191a:	85a6                	mv	a1,s1
ffffffffc020191c:	02d00513          	li	a0,45
ffffffffc0201920:	e03e                	sd	a5,0(sp)
ffffffffc0201922:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201924:	8ace                	mv	s5,s3
ffffffffc0201926:	40800633          	neg	a2,s0
ffffffffc020192a:	46a9                	li	a3,10
ffffffffc020192c:	6782                	ld	a5,0(sp)
ffffffffc020192e:	b515                	j	ffffffffc0201752 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0201930:	01b05663          	blez	s11,ffffffffc020193c <vprintfmt+0x35a>
ffffffffc0201934:	02d00693          	li	a3,45
ffffffffc0201938:	f6d798e3          	bne	a5,a3,ffffffffc02018a8 <vprintfmt+0x2c6>
ffffffffc020193c:	00001417          	auipc	s0,0x1
ffffffffc0201940:	ff540413          	addi	s0,s0,-11 # ffffffffc0202931 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201944:	02800513          	li	a0,40
ffffffffc0201948:	02800793          	li	a5,40
ffffffffc020194c:	bd1d                	j	ffffffffc0201782 <vprintfmt+0x1a0>

ffffffffc020194e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020194e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201950:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201954:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201956:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201958:	ec06                	sd	ra,24(sp)
ffffffffc020195a:	f83a                	sd	a4,48(sp)
ffffffffc020195c:	fc3e                	sd	a5,56(sp)
ffffffffc020195e:	e0c2                	sd	a6,64(sp)
ffffffffc0201960:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201962:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201964:	c7fff0ef          	jal	ra,ffffffffc02015e2 <vprintfmt>
}
ffffffffc0201968:	60e2                	ld	ra,24(sp)
ffffffffc020196a:	6161                	addi	sp,sp,80
ffffffffc020196c:	8082                	ret

ffffffffc020196e <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020196e:	715d                	addi	sp,sp,-80
ffffffffc0201970:	e486                	sd	ra,72(sp)
ffffffffc0201972:	e0a2                	sd	s0,64(sp)
ffffffffc0201974:	fc26                	sd	s1,56(sp)
ffffffffc0201976:	f84a                	sd	s2,48(sp)
ffffffffc0201978:	f44e                	sd	s3,40(sp)
ffffffffc020197a:	f052                	sd	s4,32(sp)
ffffffffc020197c:	ec56                	sd	s5,24(sp)
ffffffffc020197e:	e85a                	sd	s6,16(sp)
ffffffffc0201980:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201982:	c901                	beqz	a0,ffffffffc0201992 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201984:	85aa                	mv	a1,a0
ffffffffc0201986:	00001517          	auipc	a0,0x1
ffffffffc020198a:	fc250513          	addi	a0,a0,-62 # ffffffffc0202948 <error_string+0xe8>
ffffffffc020198e:	f28fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc0201992:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201994:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201996:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201998:	4aa9                	li	s5,10
ffffffffc020199a:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020199c:	00004b97          	auipc	s7,0x4
ffffffffc02019a0:	674b8b93          	addi	s7,s7,1652 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02019a4:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02019a8:	f86fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02019ac:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02019ae:	00054b63          	bltz	a0,ffffffffc02019c4 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02019b2:	00a95b63          	ble	a0,s2,ffffffffc02019c8 <readline+0x5a>
ffffffffc02019b6:	029a5463          	ble	s1,s4,ffffffffc02019de <readline+0x70>
        c = getchar();
ffffffffc02019ba:	f74fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02019be:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02019c0:	fe0559e3          	bgez	a0,ffffffffc02019b2 <readline+0x44>
            return NULL;
ffffffffc02019c4:	4501                	li	a0,0
ffffffffc02019c6:	a099                	j	ffffffffc0201a0c <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02019c8:	03341463          	bne	s0,s3,ffffffffc02019f0 <readline+0x82>
ffffffffc02019cc:	e8b9                	bnez	s1,ffffffffc0201a22 <readline+0xb4>
        c = getchar();
ffffffffc02019ce:	f60fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02019d2:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02019d4:	fe0548e3          	bltz	a0,ffffffffc02019c4 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02019d8:	fea958e3          	ble	a0,s2,ffffffffc02019c8 <readline+0x5a>
ffffffffc02019dc:	4481                	li	s1,0
            cputchar(c);
ffffffffc02019de:	8522                	mv	a0,s0
ffffffffc02019e0:	f0afe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc02019e4:	009b87b3          	add	a5,s7,s1
ffffffffc02019e8:	00878023          	sb	s0,0(a5)
ffffffffc02019ec:	2485                	addiw	s1,s1,1
ffffffffc02019ee:	bf6d                	j	ffffffffc02019a8 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02019f0:	01540463          	beq	s0,s5,ffffffffc02019f8 <readline+0x8a>
ffffffffc02019f4:	fb641ae3          	bne	s0,s6,ffffffffc02019a8 <readline+0x3a>
            cputchar(c);
ffffffffc02019f8:	8522                	mv	a0,s0
ffffffffc02019fa:	ef0fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc02019fe:	00004517          	auipc	a0,0x4
ffffffffc0201a02:	61250513          	addi	a0,a0,1554 # ffffffffc0206010 <edata>
ffffffffc0201a06:	94aa                	add	s1,s1,a0
ffffffffc0201a08:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201a0c:	60a6                	ld	ra,72(sp)
ffffffffc0201a0e:	6406                	ld	s0,64(sp)
ffffffffc0201a10:	74e2                	ld	s1,56(sp)
ffffffffc0201a12:	7942                	ld	s2,48(sp)
ffffffffc0201a14:	79a2                	ld	s3,40(sp)
ffffffffc0201a16:	7a02                	ld	s4,32(sp)
ffffffffc0201a18:	6ae2                	ld	s5,24(sp)
ffffffffc0201a1a:	6b42                	ld	s6,16(sp)
ffffffffc0201a1c:	6ba2                	ld	s7,8(sp)
ffffffffc0201a1e:	6161                	addi	sp,sp,80
ffffffffc0201a20:	8082                	ret
            cputchar(c);
ffffffffc0201a22:	4521                	li	a0,8
ffffffffc0201a24:	ec6fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc0201a28:	34fd                	addiw	s1,s1,-1
ffffffffc0201a2a:	bfbd                	j	ffffffffc02019a8 <readline+0x3a>

ffffffffc0201a2c <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201a2c:	00004797          	auipc	a5,0x4
ffffffffc0201a30:	5dc78793          	addi	a5,a5,1500 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201a34:	6398                	ld	a4,0(a5)
ffffffffc0201a36:	4781                	li	a5,0
ffffffffc0201a38:	88ba                	mv	a7,a4
ffffffffc0201a3a:	852a                	mv	a0,a0
ffffffffc0201a3c:	85be                	mv	a1,a5
ffffffffc0201a3e:	863e                	mv	a2,a5
ffffffffc0201a40:	00000073          	ecall
ffffffffc0201a44:	87aa                	mv	a5,a0
}
ffffffffc0201a46:	8082                	ret

ffffffffc0201a48 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201a48:	00005797          	auipc	a5,0x5
ffffffffc0201a4c:	9e078793          	addi	a5,a5,-1568 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201a50:	6398                	ld	a4,0(a5)
ffffffffc0201a52:	4781                	li	a5,0
ffffffffc0201a54:	88ba                	mv	a7,a4
ffffffffc0201a56:	852a                	mv	a0,a0
ffffffffc0201a58:	85be                	mv	a1,a5
ffffffffc0201a5a:	863e                	mv	a2,a5
ffffffffc0201a5c:	00000073          	ecall
ffffffffc0201a60:	87aa                	mv	a5,a0
}
ffffffffc0201a62:	8082                	ret

ffffffffc0201a64 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201a64:	00004797          	auipc	a5,0x4
ffffffffc0201a68:	59c78793          	addi	a5,a5,1436 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201a6c:	639c                	ld	a5,0(a5)
ffffffffc0201a6e:	4501                	li	a0,0
ffffffffc0201a70:	88be                	mv	a7,a5
ffffffffc0201a72:	852a                	mv	a0,a0
ffffffffc0201a74:	85aa                	mv	a1,a0
ffffffffc0201a76:	862a                	mv	a2,a0
ffffffffc0201a78:	00000073          	ecall
ffffffffc0201a7c:	852a                	mv	a0,a0
ffffffffc0201a7e:	2501                	sext.w	a0,a0
ffffffffc0201a80:	8082                	ret

ffffffffc0201a82 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a82:	c185                	beqz	a1,ffffffffc0201aa2 <strnlen+0x20>
ffffffffc0201a84:	00054783          	lbu	a5,0(a0)
ffffffffc0201a88:	cf89                	beqz	a5,ffffffffc0201aa2 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201a8a:	4781                	li	a5,0
ffffffffc0201a8c:	a021                	j	ffffffffc0201a94 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a8e:	00074703          	lbu	a4,0(a4)
ffffffffc0201a92:	c711                	beqz	a4,ffffffffc0201a9e <strnlen+0x1c>
        cnt ++;
ffffffffc0201a94:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a96:	00f50733          	add	a4,a0,a5
ffffffffc0201a9a:	fef59ae3          	bne	a1,a5,ffffffffc0201a8e <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201a9e:	853e                	mv	a0,a5
ffffffffc0201aa0:	8082                	ret
    size_t cnt = 0;
ffffffffc0201aa2:	4781                	li	a5,0
}
ffffffffc0201aa4:	853e                	mv	a0,a5
ffffffffc0201aa6:	8082                	ret

ffffffffc0201aa8 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201aa8:	00054783          	lbu	a5,0(a0)
ffffffffc0201aac:	0005c703          	lbu	a4,0(a1)
ffffffffc0201ab0:	cb91                	beqz	a5,ffffffffc0201ac4 <strcmp+0x1c>
ffffffffc0201ab2:	00e79c63          	bne	a5,a4,ffffffffc0201aca <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201ab6:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201ab8:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201abc:	0585                	addi	a1,a1,1
ffffffffc0201abe:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201ac2:	fbe5                	bnez	a5,ffffffffc0201ab2 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201ac4:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201ac6:	9d19                	subw	a0,a0,a4
ffffffffc0201ac8:	8082                	ret
ffffffffc0201aca:	0007851b          	sext.w	a0,a5
ffffffffc0201ace:	9d19                	subw	a0,a0,a4
ffffffffc0201ad0:	8082                	ret

ffffffffc0201ad2 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201ad2:	00054783          	lbu	a5,0(a0)
ffffffffc0201ad6:	cb91                	beqz	a5,ffffffffc0201aea <strchr+0x18>
        if (*s == c) {
ffffffffc0201ad8:	00b79563          	bne	a5,a1,ffffffffc0201ae2 <strchr+0x10>
ffffffffc0201adc:	a809                	j	ffffffffc0201aee <strchr+0x1c>
ffffffffc0201ade:	00b78763          	beq	a5,a1,ffffffffc0201aec <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0201ae2:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201ae4:	00054783          	lbu	a5,0(a0)
ffffffffc0201ae8:	fbfd                	bnez	a5,ffffffffc0201ade <strchr+0xc>
    }
    return NULL;
ffffffffc0201aea:	4501                	li	a0,0
}
ffffffffc0201aec:	8082                	ret
ffffffffc0201aee:	8082                	ret

ffffffffc0201af0 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201af0:	ca01                	beqz	a2,ffffffffc0201b00 <memset+0x10>
ffffffffc0201af2:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201af4:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201af6:	0785                	addi	a5,a5,1
ffffffffc0201af8:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201afc:	fec79de3          	bne	a5,a2,ffffffffc0201af6 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201b00:	8082                	ret
