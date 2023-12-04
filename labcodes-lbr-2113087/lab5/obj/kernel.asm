
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
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
ffffffffc0200028:	c020b137          	lui	sp,0xc020b

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

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	000a1517          	auipc	a0,0xa1
ffffffffc020003a:	01a50513          	addi	a0,a0,26 # ffffffffc02a1050 <edata>
ffffffffc020003e:	000ac617          	auipc	a2,0xac
ffffffffc0200042:	5a260613          	addi	a2,a2,1442 # ffffffffc02ac5e0 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	174060ef          	jal	ra,ffffffffc02061c2 <memset>
    cons_init();                // init the console
ffffffffc0200052:	58e000ef          	jal	ra,ffffffffc02005e0 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00006597          	auipc	a1,0x6
ffffffffc020005a:	5aa58593          	addi	a1,a1,1450 # ffffffffc0206600 <etext+0x4>
ffffffffc020005e:	00006517          	auipc	a0,0x6
ffffffffc0200062:	5c250513          	addi	a0,a0,1474 # ffffffffc0206620 <etext+0x24>
ffffffffc0200066:	06a000ef          	jal	ra,ffffffffc02000d0 <cprintf>

    print_kerninfo();
ffffffffc020006a:	25a000ef          	jal	ra,ffffffffc02002c4 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	5e6010ef          	jal	ra,ffffffffc0201654 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	5e2000ef          	jal	ra,ffffffffc0200654 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5ec000ef          	jal	ra,ffffffffc0200662 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	2bf020ef          	jal	ra,ffffffffc0202b38 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	54f050ef          	jal	ra,ffffffffc0205dcc <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	4b0000ef          	jal	ra,ffffffffc0200532 <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	604030ef          	jal	ra,ffffffffc020368a <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	500000ef          	jal	ra,ffffffffc020058a <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	5c8000ef          	jal	ra,ffffffffc0200656 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc0200092:	687050ef          	jal	ra,ffffffffc0205f18 <cpu_idle>

ffffffffc0200096 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200096:	1141                	addi	sp,sp,-16
ffffffffc0200098:	e022                	sd	s0,0(sp)
ffffffffc020009a:	e406                	sd	ra,8(sp)
ffffffffc020009c:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020009e:	544000ef          	jal	ra,ffffffffc02005e2 <cons_putc>
    (*cnt) ++;
ffffffffc02000a2:	401c                	lw	a5,0(s0)
}
ffffffffc02000a4:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc02000a6:	2785                	addiw	a5,a5,1
ffffffffc02000a8:	c01c                	sw	a5,0(s0)
}
ffffffffc02000aa:	6402                	ld	s0,0(sp)
ffffffffc02000ac:	0141                	addi	sp,sp,16
ffffffffc02000ae:	8082                	ret

ffffffffc02000b0 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000b0:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	86ae                	mv	a3,a1
ffffffffc02000b4:	862a                	mv	a2,a0
ffffffffc02000b6:	006c                	addi	a1,sp,12
ffffffffc02000b8:	00000517          	auipc	a0,0x0
ffffffffc02000bc:	fde50513          	addi	a0,a0,-34 # ffffffffc0200096 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000c0:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000c2:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c4:	194060ef          	jal	ra,ffffffffc0206258 <vprintfmt>
    return cnt;
}
ffffffffc02000c8:	60e2                	ld	ra,24(sp)
ffffffffc02000ca:	4532                	lw	a0,12(sp)
ffffffffc02000cc:	6105                	addi	sp,sp,32
ffffffffc02000ce:	8082                	ret

ffffffffc02000d0 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000d2:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000d6:	f42e                	sd	a1,40(sp)
ffffffffc02000d8:	f832                	sd	a2,48(sp)
ffffffffc02000da:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	862a                	mv	a2,a0
ffffffffc02000de:	004c                	addi	a1,sp,4
ffffffffc02000e0:	00000517          	auipc	a0,0x0
ffffffffc02000e4:	fb650513          	addi	a0,a0,-74 # ffffffffc0200096 <cputch>
ffffffffc02000e8:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000ea:	ec06                	sd	ra,24(sp)
ffffffffc02000ec:	e0ba                	sd	a4,64(sp)
ffffffffc02000ee:	e4be                	sd	a5,72(sp)
ffffffffc02000f0:	e8c2                	sd	a6,80(sp)
ffffffffc02000f2:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000f4:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000f6:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000f8:	160060ef          	jal	ra,ffffffffc0206258 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000fc:	60e2                	ld	ra,24(sp)
ffffffffc02000fe:	4512                	lw	a0,4(sp)
ffffffffc0200100:	6125                	addi	sp,sp,96
ffffffffc0200102:	8082                	ret

ffffffffc0200104 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc0200104:	4de0006f          	j	ffffffffc02005e2 <cons_putc>

ffffffffc0200108 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200108:	1101                	addi	sp,sp,-32
ffffffffc020010a:	e822                	sd	s0,16(sp)
ffffffffc020010c:	ec06                	sd	ra,24(sp)
ffffffffc020010e:	e426                	sd	s1,8(sp)
ffffffffc0200110:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc0200112:	00054503          	lbu	a0,0(a0)
ffffffffc0200116:	c51d                	beqz	a0,ffffffffc0200144 <cputs+0x3c>
ffffffffc0200118:	0405                	addi	s0,s0,1
ffffffffc020011a:	4485                	li	s1,1
ffffffffc020011c:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc020011e:	4c4000ef          	jal	ra,ffffffffc02005e2 <cons_putc>
    (*cnt) ++;
ffffffffc0200122:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	0405                	addi	s0,s0,1
ffffffffc0200128:	fff44503          	lbu	a0,-1(s0)
ffffffffc020012c:	f96d                	bnez	a0,ffffffffc020011e <cputs+0x16>
ffffffffc020012e:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200132:	4529                	li	a0,10
ffffffffc0200134:	4ae000ef          	jal	ra,ffffffffc02005e2 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200138:	8522                	mv	a0,s0
ffffffffc020013a:	60e2                	ld	ra,24(sp)
ffffffffc020013c:	6442                	ld	s0,16(sp)
ffffffffc020013e:	64a2                	ld	s1,8(sp)
ffffffffc0200140:	6105                	addi	sp,sp,32
ffffffffc0200142:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200144:	4405                	li	s0,1
ffffffffc0200146:	b7f5                	j	ffffffffc0200132 <cputs+0x2a>

ffffffffc0200148 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200148:	1141                	addi	sp,sp,-16
ffffffffc020014a:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020014c:	4cc000ef          	jal	ra,ffffffffc0200618 <cons_getc>
ffffffffc0200150:	dd75                	beqz	a0,ffffffffc020014c <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200152:	60a2                	ld	ra,8(sp)
ffffffffc0200154:	0141                	addi	sp,sp,16
ffffffffc0200156:	8082                	ret

ffffffffc0200158 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200158:	715d                	addi	sp,sp,-80
ffffffffc020015a:	e486                	sd	ra,72(sp)
ffffffffc020015c:	e0a2                	sd	s0,64(sp)
ffffffffc020015e:	fc26                	sd	s1,56(sp)
ffffffffc0200160:	f84a                	sd	s2,48(sp)
ffffffffc0200162:	f44e                	sd	s3,40(sp)
ffffffffc0200164:	f052                	sd	s4,32(sp)
ffffffffc0200166:	ec56                	sd	s5,24(sp)
ffffffffc0200168:	e85a                	sd	s6,16(sp)
ffffffffc020016a:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc020016c:	c901                	beqz	a0,ffffffffc020017c <readline+0x24>
        cprintf("%s", prompt);
ffffffffc020016e:	85aa                	mv	a1,a0
ffffffffc0200170:	00006517          	auipc	a0,0x6
ffffffffc0200174:	4b850513          	addi	a0,a0,1208 # ffffffffc0206628 <etext+0x2c>
ffffffffc0200178:	f59ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
readline(const char *prompt) {
ffffffffc020017c:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020017e:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0200180:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0200182:	4aa9                	li	s5,10
ffffffffc0200184:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200186:	000a1b97          	auipc	s7,0xa1
ffffffffc020018a:	ecab8b93          	addi	s7,s7,-310 # ffffffffc02a1050 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020018e:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0200192:	fb7ff0ef          	jal	ra,ffffffffc0200148 <getchar>
ffffffffc0200196:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0200198:	00054b63          	bltz	a0,ffffffffc02001ae <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020019c:	00a95b63          	ble	a0,s2,ffffffffc02001b2 <readline+0x5a>
ffffffffc02001a0:	029a5463          	ble	s1,s4,ffffffffc02001c8 <readline+0x70>
        c = getchar();
ffffffffc02001a4:	fa5ff0ef          	jal	ra,ffffffffc0200148 <getchar>
ffffffffc02001a8:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02001aa:	fe0559e3          	bgez	a0,ffffffffc020019c <readline+0x44>
            return NULL;
ffffffffc02001ae:	4501                	li	a0,0
ffffffffc02001b0:	a099                	j	ffffffffc02001f6 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02001b2:	03341463          	bne	s0,s3,ffffffffc02001da <readline+0x82>
ffffffffc02001b6:	e8b9                	bnez	s1,ffffffffc020020c <readline+0xb4>
        c = getchar();
ffffffffc02001b8:	f91ff0ef          	jal	ra,ffffffffc0200148 <getchar>
ffffffffc02001bc:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02001be:	fe0548e3          	bltz	a0,ffffffffc02001ae <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001c2:	fea958e3          	ble	a0,s2,ffffffffc02001b2 <readline+0x5a>
ffffffffc02001c6:	4481                	li	s1,0
            cputchar(c);
ffffffffc02001c8:	8522                	mv	a0,s0
ffffffffc02001ca:	f3bff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i ++] = c;
ffffffffc02001ce:	009b87b3          	add	a5,s7,s1
ffffffffc02001d2:	00878023          	sb	s0,0(a5)
ffffffffc02001d6:	2485                	addiw	s1,s1,1
ffffffffc02001d8:	bf6d                	j	ffffffffc0200192 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02001da:	01540463          	beq	s0,s5,ffffffffc02001e2 <readline+0x8a>
ffffffffc02001de:	fb641ae3          	bne	s0,s6,ffffffffc0200192 <readline+0x3a>
            cputchar(c);
ffffffffc02001e2:	8522                	mv	a0,s0
ffffffffc02001e4:	f21ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i] = '\0';
ffffffffc02001e8:	000a1517          	auipc	a0,0xa1
ffffffffc02001ec:	e6850513          	addi	a0,a0,-408 # ffffffffc02a1050 <edata>
ffffffffc02001f0:	94aa                	add	s1,s1,a0
ffffffffc02001f2:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001f6:	60a6                	ld	ra,72(sp)
ffffffffc02001f8:	6406                	ld	s0,64(sp)
ffffffffc02001fa:	74e2                	ld	s1,56(sp)
ffffffffc02001fc:	7942                	ld	s2,48(sp)
ffffffffc02001fe:	79a2                	ld	s3,40(sp)
ffffffffc0200200:	7a02                	ld	s4,32(sp)
ffffffffc0200202:	6ae2                	ld	s5,24(sp)
ffffffffc0200204:	6b42                	ld	s6,16(sp)
ffffffffc0200206:	6ba2                	ld	s7,8(sp)
ffffffffc0200208:	6161                	addi	sp,sp,80
ffffffffc020020a:	8082                	ret
            cputchar(c);
ffffffffc020020c:	4521                	li	a0,8
ffffffffc020020e:	ef7ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            i --;
ffffffffc0200212:	34fd                	addiw	s1,s1,-1
ffffffffc0200214:	bfbd                	j	ffffffffc0200192 <readline+0x3a>

ffffffffc0200216 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200216:	000ac317          	auipc	t1,0xac
ffffffffc020021a:	23a30313          	addi	t1,t1,570 # ffffffffc02ac450 <is_panic>
ffffffffc020021e:	00033303          	ld	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200222:	715d                	addi	sp,sp,-80
ffffffffc0200224:	ec06                	sd	ra,24(sp)
ffffffffc0200226:	e822                	sd	s0,16(sp)
ffffffffc0200228:	f436                	sd	a3,40(sp)
ffffffffc020022a:	f83a                	sd	a4,48(sp)
ffffffffc020022c:	fc3e                	sd	a5,56(sp)
ffffffffc020022e:	e0c2                	sd	a6,64(sp)
ffffffffc0200230:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200232:	02031c63          	bnez	t1,ffffffffc020026a <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200236:	4785                	li	a5,1
ffffffffc0200238:	8432                	mv	s0,a2
ffffffffc020023a:	000ac717          	auipc	a4,0xac
ffffffffc020023e:	20f73b23          	sd	a5,534(a4) # ffffffffc02ac450 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200242:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc0200244:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200246:	85aa                	mv	a1,a0
ffffffffc0200248:	00006517          	auipc	a0,0x6
ffffffffc020024c:	3e850513          	addi	a0,a0,1000 # ffffffffc0206630 <etext+0x34>
    va_start(ap, fmt);
ffffffffc0200250:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200252:	e7fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200256:	65a2                	ld	a1,8(sp)
ffffffffc0200258:	8522                	mv	a0,s0
ffffffffc020025a:	e57ff0ef          	jal	ra,ffffffffc02000b0 <vcprintf>
    cprintf("\n");
ffffffffc020025e:	00007517          	auipc	a0,0x7
ffffffffc0200262:	1b250513          	addi	a0,a0,434 # ffffffffc0207410 <commands+0xca0>
ffffffffc0200266:	e6bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc020026a:	4501                	li	a0,0
ffffffffc020026c:	4581                	li	a1,0
ffffffffc020026e:	4601                	li	a2,0
ffffffffc0200270:	48a1                	li	a7,8
ffffffffc0200272:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc0200276:	3e6000ef          	jal	ra,ffffffffc020065c <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020027a:	4501                	li	a0,0
ffffffffc020027c:	174000ef          	jal	ra,ffffffffc02003f0 <kmonitor>
ffffffffc0200280:	bfed                	j	ffffffffc020027a <__panic+0x64>

ffffffffc0200282 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200282:	715d                	addi	sp,sp,-80
ffffffffc0200284:	e822                	sd	s0,16(sp)
ffffffffc0200286:	fc3e                	sd	a5,56(sp)
ffffffffc0200288:	8432                	mv	s0,a2
    va_list ap;
    va_start(ap, fmt);
ffffffffc020028a:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020028c:	862e                	mv	a2,a1
ffffffffc020028e:	85aa                	mv	a1,a0
ffffffffc0200290:	00006517          	auipc	a0,0x6
ffffffffc0200294:	3c050513          	addi	a0,a0,960 # ffffffffc0206650 <etext+0x54>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200298:	ec06                	sd	ra,24(sp)
ffffffffc020029a:	f436                	sd	a3,40(sp)
ffffffffc020029c:	f83a                	sd	a4,48(sp)
ffffffffc020029e:	e0c2                	sd	a6,64(sp)
ffffffffc02002a0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02002a2:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02002a4:	e2dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02002a8:	65a2                	ld	a1,8(sp)
ffffffffc02002aa:	8522                	mv	a0,s0
ffffffffc02002ac:	e05ff0ef          	jal	ra,ffffffffc02000b0 <vcprintf>
    cprintf("\n");
ffffffffc02002b0:	00007517          	auipc	a0,0x7
ffffffffc02002b4:	16050513          	addi	a0,a0,352 # ffffffffc0207410 <commands+0xca0>
ffffffffc02002b8:	e19ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    va_end(ap);
}
ffffffffc02002bc:	60e2                	ld	ra,24(sp)
ffffffffc02002be:	6442                	ld	s0,16(sp)
ffffffffc02002c0:	6161                	addi	sp,sp,80
ffffffffc02002c2:	8082                	ret

ffffffffc02002c4 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02002c4:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02002c6:	00006517          	auipc	a0,0x6
ffffffffc02002ca:	3da50513          	addi	a0,a0,986 # ffffffffc02066a0 <etext+0xa4>
void print_kerninfo(void) {
ffffffffc02002ce:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002d0:	e01ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002d4:	00000597          	auipc	a1,0x0
ffffffffc02002d8:	d6258593          	addi	a1,a1,-670 # ffffffffc0200036 <kern_init>
ffffffffc02002dc:	00006517          	auipc	a0,0x6
ffffffffc02002e0:	3e450513          	addi	a0,a0,996 # ffffffffc02066c0 <etext+0xc4>
ffffffffc02002e4:	dedff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002e8:	00006597          	auipc	a1,0x6
ffffffffc02002ec:	31458593          	addi	a1,a1,788 # ffffffffc02065fc <etext>
ffffffffc02002f0:	00006517          	auipc	a0,0x6
ffffffffc02002f4:	3f050513          	addi	a0,a0,1008 # ffffffffc02066e0 <etext+0xe4>
ffffffffc02002f8:	dd9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc02002fc:	000a1597          	auipc	a1,0xa1
ffffffffc0200300:	d5458593          	addi	a1,a1,-684 # ffffffffc02a1050 <edata>
ffffffffc0200304:	00006517          	auipc	a0,0x6
ffffffffc0200308:	3fc50513          	addi	a0,a0,1020 # ffffffffc0206700 <etext+0x104>
ffffffffc020030c:	dc5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200310:	000ac597          	auipc	a1,0xac
ffffffffc0200314:	2d058593          	addi	a1,a1,720 # ffffffffc02ac5e0 <end>
ffffffffc0200318:	00006517          	auipc	a0,0x6
ffffffffc020031c:	40850513          	addi	a0,a0,1032 # ffffffffc0206720 <etext+0x124>
ffffffffc0200320:	db1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200324:	000ac597          	auipc	a1,0xac
ffffffffc0200328:	6bb58593          	addi	a1,a1,1723 # ffffffffc02ac9df <end+0x3ff>
ffffffffc020032c:	00000797          	auipc	a5,0x0
ffffffffc0200330:	d0a78793          	addi	a5,a5,-758 # ffffffffc0200036 <kern_init>
ffffffffc0200334:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200338:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020033c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020033e:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200342:	95be                	add	a1,a1,a5
ffffffffc0200344:	85a9                	srai	a1,a1,0xa
ffffffffc0200346:	00006517          	auipc	a0,0x6
ffffffffc020034a:	3fa50513          	addi	a0,a0,1018 # ffffffffc0206740 <etext+0x144>
}
ffffffffc020034e:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200350:	d81ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0200354 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200354:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200356:	00006617          	auipc	a2,0x6
ffffffffc020035a:	31a60613          	addi	a2,a2,794 # ffffffffc0206670 <etext+0x74>
ffffffffc020035e:	04d00593          	li	a1,77
ffffffffc0200362:	00006517          	auipc	a0,0x6
ffffffffc0200366:	32650513          	addi	a0,a0,806 # ffffffffc0206688 <etext+0x8c>
void print_stackframe(void) {
ffffffffc020036a:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020036c:	eabff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0200370 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200370:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200372:	00006617          	auipc	a2,0x6
ffffffffc0200376:	4de60613          	addi	a2,a2,1246 # ffffffffc0206850 <commands+0xe0>
ffffffffc020037a:	00006597          	auipc	a1,0x6
ffffffffc020037e:	4f658593          	addi	a1,a1,1270 # ffffffffc0206870 <commands+0x100>
ffffffffc0200382:	00006517          	auipc	a0,0x6
ffffffffc0200386:	4f650513          	addi	a0,a0,1270 # ffffffffc0206878 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020038a:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020038c:	d45ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0200390:	00006617          	auipc	a2,0x6
ffffffffc0200394:	4f860613          	addi	a2,a2,1272 # ffffffffc0206888 <commands+0x118>
ffffffffc0200398:	00006597          	auipc	a1,0x6
ffffffffc020039c:	51858593          	addi	a1,a1,1304 # ffffffffc02068b0 <commands+0x140>
ffffffffc02003a0:	00006517          	auipc	a0,0x6
ffffffffc02003a4:	4d850513          	addi	a0,a0,1240 # ffffffffc0206878 <commands+0x108>
ffffffffc02003a8:	d29ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc02003ac:	00006617          	auipc	a2,0x6
ffffffffc02003b0:	51460613          	addi	a2,a2,1300 # ffffffffc02068c0 <commands+0x150>
ffffffffc02003b4:	00006597          	auipc	a1,0x6
ffffffffc02003b8:	52c58593          	addi	a1,a1,1324 # ffffffffc02068e0 <commands+0x170>
ffffffffc02003bc:	00006517          	auipc	a0,0x6
ffffffffc02003c0:	4bc50513          	addi	a0,a0,1212 # ffffffffc0206878 <commands+0x108>
ffffffffc02003c4:	d0dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    }
    return 0;
}
ffffffffc02003c8:	60a2                	ld	ra,8(sp)
ffffffffc02003ca:	4501                	li	a0,0
ffffffffc02003cc:	0141                	addi	sp,sp,16
ffffffffc02003ce:	8082                	ret

ffffffffc02003d0 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003d0:	1141                	addi	sp,sp,-16
ffffffffc02003d2:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02003d4:	ef1ff0ef          	jal	ra,ffffffffc02002c4 <print_kerninfo>
    return 0;
}
ffffffffc02003d8:	60a2                	ld	ra,8(sp)
ffffffffc02003da:	4501                	li	a0,0
ffffffffc02003dc:	0141                	addi	sp,sp,16
ffffffffc02003de:	8082                	ret

ffffffffc02003e0 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003e0:	1141                	addi	sp,sp,-16
ffffffffc02003e2:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02003e4:	f71ff0ef          	jal	ra,ffffffffc0200354 <print_stackframe>
    return 0;
}
ffffffffc02003e8:	60a2                	ld	ra,8(sp)
ffffffffc02003ea:	4501                	li	a0,0
ffffffffc02003ec:	0141                	addi	sp,sp,16
ffffffffc02003ee:	8082                	ret

ffffffffc02003f0 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02003f0:	7115                	addi	sp,sp,-224
ffffffffc02003f2:	e962                	sd	s8,144(sp)
ffffffffc02003f4:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02003f6:	00006517          	auipc	a0,0x6
ffffffffc02003fa:	3c250513          	addi	a0,a0,962 # ffffffffc02067b8 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc02003fe:	ed86                	sd	ra,216(sp)
ffffffffc0200400:	e9a2                	sd	s0,208(sp)
ffffffffc0200402:	e5a6                	sd	s1,200(sp)
ffffffffc0200404:	e1ca                	sd	s2,192(sp)
ffffffffc0200406:	fd4e                	sd	s3,184(sp)
ffffffffc0200408:	f952                	sd	s4,176(sp)
ffffffffc020040a:	f556                	sd	s5,168(sp)
ffffffffc020040c:	f15a                	sd	s6,160(sp)
ffffffffc020040e:	ed5e                	sd	s7,152(sp)
ffffffffc0200410:	e566                	sd	s9,136(sp)
ffffffffc0200412:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200414:	cbdff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200418:	00006517          	auipc	a0,0x6
ffffffffc020041c:	3c850513          	addi	a0,a0,968 # ffffffffc02067e0 <commands+0x70>
ffffffffc0200420:	cb1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    if (tf != NULL) {
ffffffffc0200424:	000c0563          	beqz	s8,ffffffffc020042e <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200428:	8562                	mv	a0,s8
ffffffffc020042a:	420000ef          	jal	ra,ffffffffc020084a <print_trapframe>
ffffffffc020042e:	00006c97          	auipc	s9,0x6
ffffffffc0200432:	342c8c93          	addi	s9,s9,834 # ffffffffc0206770 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200436:	00006997          	auipc	s3,0x6
ffffffffc020043a:	3d298993          	addi	s3,s3,978 # ffffffffc0206808 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020043e:	00006917          	auipc	s2,0x6
ffffffffc0200442:	3d290913          	addi	s2,s2,978 # ffffffffc0206810 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200446:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200448:	00006b17          	auipc	s6,0x6
ffffffffc020044c:	3d0b0b13          	addi	s6,s6,976 # ffffffffc0206818 <commands+0xa8>
    if (argc == 0) {
ffffffffc0200450:	00006a97          	auipc	s5,0x6
ffffffffc0200454:	420a8a93          	addi	s5,s5,1056 # ffffffffc0206870 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200458:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020045a:	854e                	mv	a0,s3
ffffffffc020045c:	cfdff0ef          	jal	ra,ffffffffc0200158 <readline>
ffffffffc0200460:	842a                	mv	s0,a0
ffffffffc0200462:	dd65                	beqz	a0,ffffffffc020045a <kmonitor+0x6a>
ffffffffc0200464:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200468:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020046a:	c999                	beqz	a1,ffffffffc0200480 <kmonitor+0x90>
ffffffffc020046c:	854a                	mv	a0,s2
ffffffffc020046e:	537050ef          	jal	ra,ffffffffc02061a4 <strchr>
ffffffffc0200472:	c925                	beqz	a0,ffffffffc02004e2 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc0200474:	00144583          	lbu	a1,1(s0)
ffffffffc0200478:	00040023          	sb	zero,0(s0)
ffffffffc020047c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020047e:	f5fd                	bnez	a1,ffffffffc020046c <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc0200480:	dce9                	beqz	s1,ffffffffc020045a <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200482:	6582                	ld	a1,0(sp)
ffffffffc0200484:	00006d17          	auipc	s10,0x6
ffffffffc0200488:	2ecd0d13          	addi	s10,s10,748 # ffffffffc0206770 <commands>
    if (argc == 0) {
ffffffffc020048c:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020048e:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200490:	0d61                	addi	s10,s10,24
ffffffffc0200492:	4e9050ef          	jal	ra,ffffffffc020617a <strcmp>
ffffffffc0200496:	c919                	beqz	a0,ffffffffc02004ac <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200498:	2405                	addiw	s0,s0,1
ffffffffc020049a:	09740463          	beq	s0,s7,ffffffffc0200522 <kmonitor+0x132>
ffffffffc020049e:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02004a2:	6582                	ld	a1,0(sp)
ffffffffc02004a4:	0d61                	addi	s10,s10,24
ffffffffc02004a6:	4d5050ef          	jal	ra,ffffffffc020617a <strcmp>
ffffffffc02004aa:	f57d                	bnez	a0,ffffffffc0200498 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02004ac:	00141793          	slli	a5,s0,0x1
ffffffffc02004b0:	97a2                	add	a5,a5,s0
ffffffffc02004b2:	078e                	slli	a5,a5,0x3
ffffffffc02004b4:	97e6                	add	a5,a5,s9
ffffffffc02004b6:	6b9c                	ld	a5,16(a5)
ffffffffc02004b8:	8662                	mv	a2,s8
ffffffffc02004ba:	002c                	addi	a1,sp,8
ffffffffc02004bc:	fff4851b          	addiw	a0,s1,-1
ffffffffc02004c0:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02004c2:	f8055ce3          	bgez	a0,ffffffffc020045a <kmonitor+0x6a>
}
ffffffffc02004c6:	60ee                	ld	ra,216(sp)
ffffffffc02004c8:	644e                	ld	s0,208(sp)
ffffffffc02004ca:	64ae                	ld	s1,200(sp)
ffffffffc02004cc:	690e                	ld	s2,192(sp)
ffffffffc02004ce:	79ea                	ld	s3,184(sp)
ffffffffc02004d0:	7a4a                	ld	s4,176(sp)
ffffffffc02004d2:	7aaa                	ld	s5,168(sp)
ffffffffc02004d4:	7b0a                	ld	s6,160(sp)
ffffffffc02004d6:	6bea                	ld	s7,152(sp)
ffffffffc02004d8:	6c4a                	ld	s8,144(sp)
ffffffffc02004da:	6caa                	ld	s9,136(sp)
ffffffffc02004dc:	6d0a                	ld	s10,128(sp)
ffffffffc02004de:	612d                	addi	sp,sp,224
ffffffffc02004e0:	8082                	ret
        if (*buf == '\0') {
ffffffffc02004e2:	00044783          	lbu	a5,0(s0)
ffffffffc02004e6:	dfc9                	beqz	a5,ffffffffc0200480 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc02004e8:	03448863          	beq	s1,s4,ffffffffc0200518 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc02004ec:	00349793          	slli	a5,s1,0x3
ffffffffc02004f0:	0118                	addi	a4,sp,128
ffffffffc02004f2:	97ba                	add	a5,a5,a4
ffffffffc02004f4:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004f8:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02004fc:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004fe:	e591                	bnez	a1,ffffffffc020050a <kmonitor+0x11a>
ffffffffc0200500:	b749                	j	ffffffffc0200482 <kmonitor+0x92>
            buf ++;
ffffffffc0200502:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200504:	00044583          	lbu	a1,0(s0)
ffffffffc0200508:	ddad                	beqz	a1,ffffffffc0200482 <kmonitor+0x92>
ffffffffc020050a:	854a                	mv	a0,s2
ffffffffc020050c:	499050ef          	jal	ra,ffffffffc02061a4 <strchr>
ffffffffc0200510:	d96d                	beqz	a0,ffffffffc0200502 <kmonitor+0x112>
ffffffffc0200512:	00044583          	lbu	a1,0(s0)
ffffffffc0200516:	bf91                	j	ffffffffc020046a <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200518:	45c1                	li	a1,16
ffffffffc020051a:	855a                	mv	a0,s6
ffffffffc020051c:	bb5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0200520:	b7f1                	j	ffffffffc02004ec <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200522:	6582                	ld	a1,0(sp)
ffffffffc0200524:	00006517          	auipc	a0,0x6
ffffffffc0200528:	31450513          	addi	a0,a0,788 # ffffffffc0206838 <commands+0xc8>
ffffffffc020052c:	ba5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
ffffffffc0200530:	b72d                	j	ffffffffc020045a <kmonitor+0x6a>

ffffffffc0200532 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200532:	8082                	ret

ffffffffc0200534 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200534:	00253513          	sltiu	a0,a0,2
ffffffffc0200538:	8082                	ret

ffffffffc020053a <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020053a:	03800513          	li	a0,56
ffffffffc020053e:	8082                	ret

ffffffffc0200540 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200540:	000a1797          	auipc	a5,0xa1
ffffffffc0200544:	f1078793          	addi	a5,a5,-240 # ffffffffc02a1450 <ide>
ffffffffc0200548:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc020054c:	1141                	addi	sp,sp,-16
ffffffffc020054e:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200550:	95be                	add	a1,a1,a5
ffffffffc0200552:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc0200556:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200558:	47d050ef          	jal	ra,ffffffffc02061d4 <memcpy>
    return 0;
}
ffffffffc020055c:	60a2                	ld	ra,8(sp)
ffffffffc020055e:	4501                	li	a0,0
ffffffffc0200560:	0141                	addi	sp,sp,16
ffffffffc0200562:	8082                	ret

ffffffffc0200564 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc0200564:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200566:	0095979b          	slliw	a5,a1,0x9
ffffffffc020056a:	000a1517          	auipc	a0,0xa1
ffffffffc020056e:	ee650513          	addi	a0,a0,-282 # ffffffffc02a1450 <ide>
                   size_t nsecs) {
ffffffffc0200572:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200574:	00969613          	slli	a2,a3,0x9
ffffffffc0200578:	85ba                	mv	a1,a4
ffffffffc020057a:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc020057c:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020057e:	457050ef          	jal	ra,ffffffffc02061d4 <memcpy>
    return 0;
}
ffffffffc0200582:	60a2                	ld	ra,8(sp)
ffffffffc0200584:	4501                	li	a0,0
ffffffffc0200586:	0141                	addi	sp,sp,16
ffffffffc0200588:	8082                	ret

ffffffffc020058a <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc020058a:	67e1                	lui	a5,0x18
ffffffffc020058c:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xdc20>
ffffffffc0200590:	000ac717          	auipc	a4,0xac
ffffffffc0200594:	ecf73423          	sd	a5,-312(a4) # ffffffffc02ac458 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200598:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020059c:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020059e:	953e                	add	a0,a0,a5
ffffffffc02005a0:	4601                	li	a2,0
ffffffffc02005a2:	4881                	li	a7,0
ffffffffc02005a4:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02005a8:	02000793          	li	a5,32
ffffffffc02005ac:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02005b0:	00006517          	auipc	a0,0x6
ffffffffc02005b4:	34050513          	addi	a0,a0,832 # ffffffffc02068f0 <commands+0x180>
    ticks = 0;
ffffffffc02005b8:	000ac797          	auipc	a5,0xac
ffffffffc02005bc:	ee07bc23          	sd	zero,-264(a5) # ffffffffc02ac4b0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02005c0:	b11ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc02005c4 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02005c4:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02005c8:	000ac797          	auipc	a5,0xac
ffffffffc02005cc:	e9078793          	addi	a5,a5,-368 # ffffffffc02ac458 <timebase>
ffffffffc02005d0:	639c                	ld	a5,0(a5)
ffffffffc02005d2:	4581                	li	a1,0
ffffffffc02005d4:	4601                	li	a2,0
ffffffffc02005d6:	953e                	add	a0,a0,a5
ffffffffc02005d8:	4881                	li	a7,0
ffffffffc02005da:	00000073          	ecall
ffffffffc02005de:	8082                	ret

ffffffffc02005e0 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02005e0:	8082                	ret

ffffffffc02005e2 <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005e2:	100027f3          	csrr	a5,sstatus
ffffffffc02005e6:	8b89                	andi	a5,a5,2
ffffffffc02005e8:	0ff57513          	andi	a0,a0,255
ffffffffc02005ec:	e799                	bnez	a5,ffffffffc02005fa <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc02005ee:	4581                	li	a1,0
ffffffffc02005f0:	4601                	li	a2,0
ffffffffc02005f2:	4885                	li	a7,1
ffffffffc02005f4:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02005f8:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005fa:	1101                	addi	sp,sp,-32
ffffffffc02005fc:	ec06                	sd	ra,24(sp)
ffffffffc02005fe:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200600:	05c000ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc0200604:	6522                	ld	a0,8(sp)
ffffffffc0200606:	4581                	li	a1,0
ffffffffc0200608:	4601                	li	a2,0
ffffffffc020060a:	4885                	li	a7,1
ffffffffc020060c:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200610:	60e2                	ld	ra,24(sp)
ffffffffc0200612:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200614:	0420006f          	j	ffffffffc0200656 <intr_enable>

ffffffffc0200618 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200618:	100027f3          	csrr	a5,sstatus
ffffffffc020061c:	8b89                	andi	a5,a5,2
ffffffffc020061e:	eb89                	bnez	a5,ffffffffc0200630 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200620:	4501                	li	a0,0
ffffffffc0200622:	4581                	li	a1,0
ffffffffc0200624:	4601                	li	a2,0
ffffffffc0200626:	4889                	li	a7,2
ffffffffc0200628:	00000073          	ecall
ffffffffc020062c:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020062e:	8082                	ret
int cons_getc(void) {
ffffffffc0200630:	1101                	addi	sp,sp,-32
ffffffffc0200632:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200634:	028000ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc0200638:	4501                	li	a0,0
ffffffffc020063a:	4581                	li	a1,0
ffffffffc020063c:	4601                	li	a2,0
ffffffffc020063e:	4889                	li	a7,2
ffffffffc0200640:	00000073          	ecall
ffffffffc0200644:	2501                	sext.w	a0,a0
ffffffffc0200646:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200648:	00e000ef          	jal	ra,ffffffffc0200656 <intr_enable>
}
ffffffffc020064c:	60e2                	ld	ra,24(sp)
ffffffffc020064e:	6522                	ld	a0,8(sp)
ffffffffc0200650:	6105                	addi	sp,sp,32
ffffffffc0200652:	8082                	ret

ffffffffc0200654 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200654:	8082                	ret

ffffffffc0200656 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200656:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020065a:	8082                	ret

ffffffffc020065c <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020065c:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200660:	8082                	ret

ffffffffc0200662 <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200662:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200666:	00000797          	auipc	a5,0x0
ffffffffc020066a:	67a78793          	addi	a5,a5,1658 # ffffffffc0200ce0 <__alltraps>
ffffffffc020066e:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200672:	000407b7          	lui	a5,0x40
ffffffffc0200676:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020067a:	8082                	ret

ffffffffc020067c <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc020067e:	1141                	addi	sp,sp,-16
ffffffffc0200680:	e022                	sd	s0,0(sp)
ffffffffc0200682:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200684:	00006517          	auipc	a0,0x6
ffffffffc0200688:	5b450513          	addi	a0,a0,1460 # ffffffffc0206c38 <commands+0x4c8>
void print_regs(struct pushregs* gpr) {
ffffffffc020068c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020068e:	a43ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200692:	640c                	ld	a1,8(s0)
ffffffffc0200694:	00006517          	auipc	a0,0x6
ffffffffc0200698:	5bc50513          	addi	a0,a0,1468 # ffffffffc0206c50 <commands+0x4e0>
ffffffffc020069c:	a35ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02006a0:	680c                	ld	a1,16(s0)
ffffffffc02006a2:	00006517          	auipc	a0,0x6
ffffffffc02006a6:	5c650513          	addi	a0,a0,1478 # ffffffffc0206c68 <commands+0x4f8>
ffffffffc02006aa:	a27ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02006ae:	6c0c                	ld	a1,24(s0)
ffffffffc02006b0:	00006517          	auipc	a0,0x6
ffffffffc02006b4:	5d050513          	addi	a0,a0,1488 # ffffffffc0206c80 <commands+0x510>
ffffffffc02006b8:	a19ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006bc:	700c                	ld	a1,32(s0)
ffffffffc02006be:	00006517          	auipc	a0,0x6
ffffffffc02006c2:	5da50513          	addi	a0,a0,1498 # ffffffffc0206c98 <commands+0x528>
ffffffffc02006c6:	a0bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006ca:	740c                	ld	a1,40(s0)
ffffffffc02006cc:	00006517          	auipc	a0,0x6
ffffffffc02006d0:	5e450513          	addi	a0,a0,1508 # ffffffffc0206cb0 <commands+0x540>
ffffffffc02006d4:	9fdff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006d8:	780c                	ld	a1,48(s0)
ffffffffc02006da:	00006517          	auipc	a0,0x6
ffffffffc02006de:	5ee50513          	addi	a0,a0,1518 # ffffffffc0206cc8 <commands+0x558>
ffffffffc02006e2:	9efff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006e6:	7c0c                	ld	a1,56(s0)
ffffffffc02006e8:	00006517          	auipc	a0,0x6
ffffffffc02006ec:	5f850513          	addi	a0,a0,1528 # ffffffffc0206ce0 <commands+0x570>
ffffffffc02006f0:	9e1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006f4:	602c                	ld	a1,64(s0)
ffffffffc02006f6:	00006517          	auipc	a0,0x6
ffffffffc02006fa:	60250513          	addi	a0,a0,1538 # ffffffffc0206cf8 <commands+0x588>
ffffffffc02006fe:	9d3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200702:	642c                	ld	a1,72(s0)
ffffffffc0200704:	00006517          	auipc	a0,0x6
ffffffffc0200708:	60c50513          	addi	a0,a0,1548 # ffffffffc0206d10 <commands+0x5a0>
ffffffffc020070c:	9c5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200710:	682c                	ld	a1,80(s0)
ffffffffc0200712:	00006517          	auipc	a0,0x6
ffffffffc0200716:	61650513          	addi	a0,a0,1558 # ffffffffc0206d28 <commands+0x5b8>
ffffffffc020071a:	9b7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020071e:	6c2c                	ld	a1,88(s0)
ffffffffc0200720:	00006517          	auipc	a0,0x6
ffffffffc0200724:	62050513          	addi	a0,a0,1568 # ffffffffc0206d40 <commands+0x5d0>
ffffffffc0200728:	9a9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020072c:	702c                	ld	a1,96(s0)
ffffffffc020072e:	00006517          	auipc	a0,0x6
ffffffffc0200732:	62a50513          	addi	a0,a0,1578 # ffffffffc0206d58 <commands+0x5e8>
ffffffffc0200736:	99bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020073a:	742c                	ld	a1,104(s0)
ffffffffc020073c:	00006517          	auipc	a0,0x6
ffffffffc0200740:	63450513          	addi	a0,a0,1588 # ffffffffc0206d70 <commands+0x600>
ffffffffc0200744:	98dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200748:	782c                	ld	a1,112(s0)
ffffffffc020074a:	00006517          	auipc	a0,0x6
ffffffffc020074e:	63e50513          	addi	a0,a0,1598 # ffffffffc0206d88 <commands+0x618>
ffffffffc0200752:	97fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200756:	7c2c                	ld	a1,120(s0)
ffffffffc0200758:	00006517          	auipc	a0,0x6
ffffffffc020075c:	64850513          	addi	a0,a0,1608 # ffffffffc0206da0 <commands+0x630>
ffffffffc0200760:	971ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200764:	604c                	ld	a1,128(s0)
ffffffffc0200766:	00006517          	auipc	a0,0x6
ffffffffc020076a:	65250513          	addi	a0,a0,1618 # ffffffffc0206db8 <commands+0x648>
ffffffffc020076e:	963ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200772:	644c                	ld	a1,136(s0)
ffffffffc0200774:	00006517          	auipc	a0,0x6
ffffffffc0200778:	65c50513          	addi	a0,a0,1628 # ffffffffc0206dd0 <commands+0x660>
ffffffffc020077c:	955ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200780:	684c                	ld	a1,144(s0)
ffffffffc0200782:	00006517          	auipc	a0,0x6
ffffffffc0200786:	66650513          	addi	a0,a0,1638 # ffffffffc0206de8 <commands+0x678>
ffffffffc020078a:	947ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020078e:	6c4c                	ld	a1,152(s0)
ffffffffc0200790:	00006517          	auipc	a0,0x6
ffffffffc0200794:	67050513          	addi	a0,a0,1648 # ffffffffc0206e00 <commands+0x690>
ffffffffc0200798:	939ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020079c:	704c                	ld	a1,160(s0)
ffffffffc020079e:	00006517          	auipc	a0,0x6
ffffffffc02007a2:	67a50513          	addi	a0,a0,1658 # ffffffffc0206e18 <commands+0x6a8>
ffffffffc02007a6:	92bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02007aa:	744c                	ld	a1,168(s0)
ffffffffc02007ac:	00006517          	auipc	a0,0x6
ffffffffc02007b0:	68450513          	addi	a0,a0,1668 # ffffffffc0206e30 <commands+0x6c0>
ffffffffc02007b4:	91dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007b8:	784c                	ld	a1,176(s0)
ffffffffc02007ba:	00006517          	auipc	a0,0x6
ffffffffc02007be:	68e50513          	addi	a0,a0,1678 # ffffffffc0206e48 <commands+0x6d8>
ffffffffc02007c2:	90fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007c6:	7c4c                	ld	a1,184(s0)
ffffffffc02007c8:	00006517          	auipc	a0,0x6
ffffffffc02007cc:	69850513          	addi	a0,a0,1688 # ffffffffc0206e60 <commands+0x6f0>
ffffffffc02007d0:	901ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007d4:	606c                	ld	a1,192(s0)
ffffffffc02007d6:	00006517          	auipc	a0,0x6
ffffffffc02007da:	6a250513          	addi	a0,a0,1698 # ffffffffc0206e78 <commands+0x708>
ffffffffc02007de:	8f3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007e2:	646c                	ld	a1,200(s0)
ffffffffc02007e4:	00006517          	auipc	a0,0x6
ffffffffc02007e8:	6ac50513          	addi	a0,a0,1708 # ffffffffc0206e90 <commands+0x720>
ffffffffc02007ec:	8e5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007f0:	686c                	ld	a1,208(s0)
ffffffffc02007f2:	00006517          	auipc	a0,0x6
ffffffffc02007f6:	6b650513          	addi	a0,a0,1718 # ffffffffc0206ea8 <commands+0x738>
ffffffffc02007fa:	8d7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200800:	00006517          	auipc	a0,0x6
ffffffffc0200804:	6c050513          	addi	a0,a0,1728 # ffffffffc0206ec0 <commands+0x750>
ffffffffc0200808:	8c9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020080c:	706c                	ld	a1,224(s0)
ffffffffc020080e:	00006517          	auipc	a0,0x6
ffffffffc0200812:	6ca50513          	addi	a0,a0,1738 # ffffffffc0206ed8 <commands+0x768>
ffffffffc0200816:	8bbff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020081a:	746c                	ld	a1,232(s0)
ffffffffc020081c:	00006517          	auipc	a0,0x6
ffffffffc0200820:	6d450513          	addi	a0,a0,1748 # ffffffffc0206ef0 <commands+0x780>
ffffffffc0200824:	8adff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200828:	786c                	ld	a1,240(s0)
ffffffffc020082a:	00006517          	auipc	a0,0x6
ffffffffc020082e:	6de50513          	addi	a0,a0,1758 # ffffffffc0206f08 <commands+0x798>
ffffffffc0200832:	89fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200836:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200838:	6402                	ld	s0,0(sp)
ffffffffc020083a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020083c:	00006517          	auipc	a0,0x6
ffffffffc0200840:	6e450513          	addi	a0,a0,1764 # ffffffffc0206f20 <commands+0x7b0>
}
ffffffffc0200844:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200846:	88bff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc020084a <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc020084a:	1141                	addi	sp,sp,-16
ffffffffc020084c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020084e:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200850:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200852:	00006517          	auipc	a0,0x6
ffffffffc0200856:	6e650513          	addi	a0,a0,1766 # ffffffffc0206f38 <commands+0x7c8>
print_trapframe(struct trapframe *tf) {
ffffffffc020085a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020085c:	875ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200860:	8522                	mv	a0,s0
ffffffffc0200862:	e1bff0ef          	jal	ra,ffffffffc020067c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200866:	10043583          	ld	a1,256(s0)
ffffffffc020086a:	00006517          	auipc	a0,0x6
ffffffffc020086e:	6e650513          	addi	a0,a0,1766 # ffffffffc0206f50 <commands+0x7e0>
ffffffffc0200872:	85fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200876:	10843583          	ld	a1,264(s0)
ffffffffc020087a:	00006517          	auipc	a0,0x6
ffffffffc020087e:	6ee50513          	addi	a0,a0,1774 # ffffffffc0206f68 <commands+0x7f8>
ffffffffc0200882:	84fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200886:	11043583          	ld	a1,272(s0)
ffffffffc020088a:	00006517          	auipc	a0,0x6
ffffffffc020088e:	6f650513          	addi	a0,a0,1782 # ffffffffc0206f80 <commands+0x810>
ffffffffc0200892:	83fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200896:	11843583          	ld	a1,280(s0)
}
ffffffffc020089a:	6402                	ld	s0,0(sp)
ffffffffc020089c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020089e:	00006517          	auipc	a0,0x6
ffffffffc02008a2:	6f250513          	addi	a0,a0,1778 # ffffffffc0206f90 <commands+0x820>
}
ffffffffc02008a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02008a8:	829ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc02008ac <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc02008ac:	1101                	addi	sp,sp,-32
ffffffffc02008ae:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008b0:	000ac497          	auipc	s1,0xac
ffffffffc02008b4:	c3848493          	addi	s1,s1,-968 # ffffffffc02ac4e8 <check_mm_struct>
ffffffffc02008b8:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008ba:	e822                	sd	s0,16(sp)
ffffffffc02008bc:	ec06                	sd	ra,24(sp)
ffffffffc02008be:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008c0:	cbbd                	beqz	a5,ffffffffc0200936 <pgfault_handler+0x8a>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008c2:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008c6:	11053583          	ld	a1,272(a0)
ffffffffc02008ca:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ce:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008d2:	cba1                	beqz	a5,ffffffffc0200922 <pgfault_handler+0x76>
ffffffffc02008d4:	11843703          	ld	a4,280(s0)
ffffffffc02008d8:	47bd                	li	a5,15
ffffffffc02008da:	05700693          	li	a3,87
ffffffffc02008de:	00f70463          	beq	a4,a5,ffffffffc02008e6 <pgfault_handler+0x3a>
ffffffffc02008e2:	05200693          	li	a3,82
ffffffffc02008e6:	00006517          	auipc	a0,0x6
ffffffffc02008ea:	2d250513          	addi	a0,a0,722 # ffffffffc0206bb8 <commands+0x448>
ffffffffc02008ee:	fe2ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008f2:	6088                	ld	a0,0(s1)
ffffffffc02008f4:	c129                	beqz	a0,ffffffffc0200936 <pgfault_handler+0x8a>
        assert(current == idleproc);
ffffffffc02008f6:	000ac797          	auipc	a5,0xac
ffffffffc02008fa:	b9a78793          	addi	a5,a5,-1126 # ffffffffc02ac490 <current>
ffffffffc02008fe:	6398                	ld	a4,0(a5)
ffffffffc0200900:	000ac797          	auipc	a5,0xac
ffffffffc0200904:	b9878793          	addi	a5,a5,-1128 # ffffffffc02ac498 <idleproc>
ffffffffc0200908:	639c                	ld	a5,0(a5)
ffffffffc020090a:	04f71763          	bne	a4,a5,ffffffffc0200958 <pgfault_handler+0xac>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020090e:	11043603          	ld	a2,272(s0)
ffffffffc0200912:	11843583          	ld	a1,280(s0)
}
ffffffffc0200916:	6442                	ld	s0,16(sp)
ffffffffc0200918:	60e2                	ld	ra,24(sp)
ffffffffc020091a:	64a2                	ld	s1,8(sp)
ffffffffc020091c:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020091e:	7600206f          	j	ffffffffc020307e <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200922:	11843703          	ld	a4,280(s0)
ffffffffc0200926:	47bd                	li	a5,15
ffffffffc0200928:	05500613          	li	a2,85
ffffffffc020092c:	05700693          	li	a3,87
ffffffffc0200930:	faf719e3          	bne	a4,a5,ffffffffc02008e2 <pgfault_handler+0x36>
ffffffffc0200934:	bf4d                	j	ffffffffc02008e6 <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc0200936:	000ac797          	auipc	a5,0xac
ffffffffc020093a:	b5a78793          	addi	a5,a5,-1190 # ffffffffc02ac490 <current>
ffffffffc020093e:	639c                	ld	a5,0(a5)
ffffffffc0200940:	cf85                	beqz	a5,ffffffffc0200978 <pgfault_handler+0xcc>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200942:	11043603          	ld	a2,272(s0)
ffffffffc0200946:	11843583          	ld	a1,280(s0)
}
ffffffffc020094a:	6442                	ld	s0,16(sp)
ffffffffc020094c:	60e2                	ld	ra,24(sp)
ffffffffc020094e:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200950:	7788                	ld	a0,40(a5)
}
ffffffffc0200952:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200954:	72a0206f          	j	ffffffffc020307e <do_pgfault>
        assert(current == idleproc);
ffffffffc0200958:	00006697          	auipc	a3,0x6
ffffffffc020095c:	28068693          	addi	a3,a3,640 # ffffffffc0206bd8 <commands+0x468>
ffffffffc0200960:	00006617          	auipc	a2,0x6
ffffffffc0200964:	29060613          	addi	a2,a2,656 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0200968:	06b00593          	li	a1,107
ffffffffc020096c:	00006517          	auipc	a0,0x6
ffffffffc0200970:	29c50513          	addi	a0,a0,668 # ffffffffc0206c08 <commands+0x498>
ffffffffc0200974:	8a3ff0ef          	jal	ra,ffffffffc0200216 <__panic>
            print_trapframe(tf);
ffffffffc0200978:	8522                	mv	a0,s0
ffffffffc020097a:	ed1ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020097e:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200982:	11043583          	ld	a1,272(s0)
ffffffffc0200986:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020098a:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020098e:	e399                	bnez	a5,ffffffffc0200994 <pgfault_handler+0xe8>
ffffffffc0200990:	05500613          	li	a2,85
ffffffffc0200994:	11843703          	ld	a4,280(s0)
ffffffffc0200998:	47bd                	li	a5,15
ffffffffc020099a:	02f70663          	beq	a4,a5,ffffffffc02009c6 <pgfault_handler+0x11a>
ffffffffc020099e:	05200693          	li	a3,82
ffffffffc02009a2:	00006517          	auipc	a0,0x6
ffffffffc02009a6:	21650513          	addi	a0,a0,534 # ffffffffc0206bb8 <commands+0x448>
ffffffffc02009aa:	f26ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            panic("unhandled page fault.\n");
ffffffffc02009ae:	00006617          	auipc	a2,0x6
ffffffffc02009b2:	27260613          	addi	a2,a2,626 # ffffffffc0206c20 <commands+0x4b0>
ffffffffc02009b6:	07200593          	li	a1,114
ffffffffc02009ba:	00006517          	auipc	a0,0x6
ffffffffc02009be:	24e50513          	addi	a0,a0,590 # ffffffffc0206c08 <commands+0x498>
ffffffffc02009c2:	855ff0ef          	jal	ra,ffffffffc0200216 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009c6:	05700693          	li	a3,87
ffffffffc02009ca:	bfe1                	j	ffffffffc02009a2 <pgfault_handler+0xf6>

ffffffffc02009cc <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009cc:	11853783          	ld	a5,280(a0)
ffffffffc02009d0:	577d                	li	a4,-1
ffffffffc02009d2:	8305                	srli	a4,a4,0x1
ffffffffc02009d4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02009d6:	472d                	li	a4,11
ffffffffc02009d8:	08f76763          	bltu	a4,a5,ffffffffc0200a66 <interrupt_handler+0x9a>
ffffffffc02009dc:	00006717          	auipc	a4,0x6
ffffffffc02009e0:	f3070713          	addi	a4,a4,-208 # ffffffffc020690c <commands+0x19c>
ffffffffc02009e4:	078a                	slli	a5,a5,0x2
ffffffffc02009e6:	97ba                	add	a5,a5,a4
ffffffffc02009e8:	439c                	lw	a5,0(a5)
ffffffffc02009ea:	97ba                	add	a5,a5,a4
ffffffffc02009ec:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009ee:	00006517          	auipc	a0,0x6
ffffffffc02009f2:	18a50513          	addi	a0,a0,394 # ffffffffc0206b78 <commands+0x408>
ffffffffc02009f6:	edaff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009fa:	00006517          	auipc	a0,0x6
ffffffffc02009fe:	15e50513          	addi	a0,a0,350 # ffffffffc0206b58 <commands+0x3e8>
ffffffffc0200a02:	eceff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc0200a06:	00006517          	auipc	a0,0x6
ffffffffc0200a0a:	11250513          	addi	a0,a0,274 # ffffffffc0206b18 <commands+0x3a8>
ffffffffc0200a0e:	ec2ff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200a12:	00006517          	auipc	a0,0x6
ffffffffc0200a16:	12650513          	addi	a0,a0,294 # ffffffffc0206b38 <commands+0x3c8>
ffffffffc0200a1a:	eb6ff06f          	j	ffffffffc02000d0 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a1e:	00006517          	auipc	a0,0x6
ffffffffc0200a22:	17a50513          	addi	a0,a0,378 # ffffffffc0206b98 <commands+0x428>
ffffffffc0200a26:	eaaff06f          	j	ffffffffc02000d0 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a2a:	1141                	addi	sp,sp,-16
ffffffffc0200a2c:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200a2e:	b97ff0ef          	jal	ra,ffffffffc02005c4 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a32:	000ac797          	auipc	a5,0xac
ffffffffc0200a36:	a7e78793          	addi	a5,a5,-1410 # ffffffffc02ac4b0 <ticks>
ffffffffc0200a3a:	639c                	ld	a5,0(a5)
ffffffffc0200a3c:	06400713          	li	a4,100
ffffffffc0200a40:	0785                	addi	a5,a5,1
ffffffffc0200a42:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a46:	000ac697          	auipc	a3,0xac
ffffffffc0200a4a:	a6f6b523          	sd	a5,-1430(a3) # ffffffffc02ac4b0 <ticks>
ffffffffc0200a4e:	eb09                	bnez	a4,ffffffffc0200a60 <interrupt_handler+0x94>
ffffffffc0200a50:	000ac797          	auipc	a5,0xac
ffffffffc0200a54:	a4078793          	addi	a5,a5,-1472 # ffffffffc02ac490 <current>
ffffffffc0200a58:	639c                	ld	a5,0(a5)
ffffffffc0200a5a:	c399                	beqz	a5,ffffffffc0200a60 <interrupt_handler+0x94>
                current->need_resched = 1;
ffffffffc0200a5c:	4705                	li	a4,1
ffffffffc0200a5e:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a60:	60a2                	ld	ra,8(sp)
ffffffffc0200a62:	0141                	addi	sp,sp,16
ffffffffc0200a64:	8082                	ret
            print_trapframe(tf);
ffffffffc0200a66:	de5ff06f          	j	ffffffffc020084a <print_trapframe>

ffffffffc0200a6a <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a6a:	11853783          	ld	a5,280(a0)
ffffffffc0200a6e:	473d                	li	a4,15
ffffffffc0200a70:	1af76e63          	bltu	a4,a5,ffffffffc0200c2c <exception_handler+0x1c2>
ffffffffc0200a74:	00006717          	auipc	a4,0x6
ffffffffc0200a78:	ec870713          	addi	a4,a4,-312 # ffffffffc020693c <commands+0x1cc>
ffffffffc0200a7c:	078a                	slli	a5,a5,0x2
ffffffffc0200a7e:	97ba                	add	a5,a5,a4
ffffffffc0200a80:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a82:	1101                	addi	sp,sp,-32
ffffffffc0200a84:	e822                	sd	s0,16(sp)
ffffffffc0200a86:	ec06                	sd	ra,24(sp)
ffffffffc0200a88:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200a8a:	97ba                	add	a5,a5,a4
ffffffffc0200a8c:	842a                	mv	s0,a0
ffffffffc0200a8e:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a90:	00006517          	auipc	a0,0x6
ffffffffc0200a94:	fe050513          	addi	a0,a0,-32 # ffffffffc0206a70 <commands+0x300>
ffffffffc0200a98:	e38ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            tf->epc += 4;
ffffffffc0200a9c:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200aa0:	60e2                	ld	ra,24(sp)
ffffffffc0200aa2:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200aa4:	0791                	addi	a5,a5,4
ffffffffc0200aa6:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200aaa:	6442                	ld	s0,16(sp)
ffffffffc0200aac:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200aae:	5f60506f          	j	ffffffffc02060a4 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200ab2:	00006517          	auipc	a0,0x6
ffffffffc0200ab6:	fde50513          	addi	a0,a0,-34 # ffffffffc0206a90 <commands+0x320>
}
ffffffffc0200aba:	6442                	ld	s0,16(sp)
ffffffffc0200abc:	60e2                	ld	ra,24(sp)
ffffffffc0200abe:	64a2                	ld	s1,8(sp)
ffffffffc0200ac0:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200ac2:	e0eff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200ac6:	00006517          	auipc	a0,0x6
ffffffffc0200aca:	fea50513          	addi	a0,a0,-22 # ffffffffc0206ab0 <commands+0x340>
ffffffffc0200ace:	b7f5                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200ad0:	00006517          	auipc	a0,0x6
ffffffffc0200ad4:	00050513          	mv	a0,a0
ffffffffc0200ad8:	b7cd                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ada:	00006517          	auipc	a0,0x6
ffffffffc0200ade:	00e50513          	addi	a0,a0,14 # ffffffffc0206ae8 <commands+0x378>
ffffffffc0200ae2:	deeff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ae6:	8522                	mv	a0,s0
ffffffffc0200ae8:	dc5ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200aec:	84aa                	mv	s1,a0
ffffffffc0200aee:	14051163          	bnez	a0,ffffffffc0200c30 <exception_handler+0x1c6>
}
ffffffffc0200af2:	60e2                	ld	ra,24(sp)
ffffffffc0200af4:	6442                	ld	s0,16(sp)
ffffffffc0200af6:	64a2                	ld	s1,8(sp)
ffffffffc0200af8:	6105                	addi	sp,sp,32
ffffffffc0200afa:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200afc:	00006517          	auipc	a0,0x6
ffffffffc0200b00:	00450513          	addi	a0,a0,4 # ffffffffc0206b00 <commands+0x390>
ffffffffc0200b04:	dccff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b08:	8522                	mv	a0,s0
ffffffffc0200b0a:	da3ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200b0e:	84aa                	mv	s1,a0
ffffffffc0200b10:	d16d                	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b12:	8522                	mv	a0,s0
ffffffffc0200b14:	d37ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b18:	86a6                	mv	a3,s1
ffffffffc0200b1a:	00006617          	auipc	a2,0x6
ffffffffc0200b1e:	f0660613          	addi	a2,a2,-250 # ffffffffc0206a20 <commands+0x2b0>
ffffffffc0200b22:	0f800593          	li	a1,248
ffffffffc0200b26:	00006517          	auipc	a0,0x6
ffffffffc0200b2a:	0e250513          	addi	a0,a0,226 # ffffffffc0206c08 <commands+0x498>
ffffffffc0200b2e:	ee8ff0ef          	jal	ra,ffffffffc0200216 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b32:	00006517          	auipc	a0,0x6
ffffffffc0200b36:	e4e50513          	addi	a0,a0,-434 # ffffffffc0206980 <commands+0x210>
ffffffffc0200b3a:	b741                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b3c:	00006517          	auipc	a0,0x6
ffffffffc0200b40:	e6450513          	addi	a0,a0,-412 # ffffffffc02069a0 <commands+0x230>
ffffffffc0200b44:	bf9d                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b46:	00006517          	auipc	a0,0x6
ffffffffc0200b4a:	e7a50513          	addi	a0,a0,-390 # ffffffffc02069c0 <commands+0x250>
ffffffffc0200b4e:	b7b5                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b50:	00006517          	auipc	a0,0x6
ffffffffc0200b54:	e8850513          	addi	a0,a0,-376 # ffffffffc02069d8 <commands+0x268>
ffffffffc0200b58:	d78ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b5c:	6458                	ld	a4,136(s0)
ffffffffc0200b5e:	47a9                	li	a5,10
ffffffffc0200b60:	f8f719e3          	bne	a4,a5,ffffffffc0200af2 <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b64:	10843783          	ld	a5,264(s0)
ffffffffc0200b68:	0791                	addi	a5,a5,4
ffffffffc0200b6a:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b6e:	536050ef          	jal	ra,ffffffffc02060a4 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b72:	000ac797          	auipc	a5,0xac
ffffffffc0200b76:	91e78793          	addi	a5,a5,-1762 # ffffffffc02ac490 <current>
ffffffffc0200b7a:	639c                	ld	a5,0(a5)
ffffffffc0200b7c:	8522                	mv	a0,s0
}
ffffffffc0200b7e:	6442                	ld	s0,16(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b80:	6b9c                	ld	a5,16(a5)
}
ffffffffc0200b82:	60e2                	ld	ra,24(sp)
ffffffffc0200b84:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b86:	6589                	lui	a1,0x2
ffffffffc0200b88:	95be                	add	a1,a1,a5
}
ffffffffc0200b8a:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b8c:	2220006f          	j	ffffffffc0200dae <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b90:	00006517          	auipc	a0,0x6
ffffffffc0200b94:	e5850513          	addi	a0,a0,-424 # ffffffffc02069e8 <commands+0x278>
ffffffffc0200b98:	b70d                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b9a:	00006517          	auipc	a0,0x6
ffffffffc0200b9e:	e6e50513          	addi	a0,a0,-402 # ffffffffc0206a08 <commands+0x298>
ffffffffc0200ba2:	d2eff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ba6:	8522                	mv	a0,s0
ffffffffc0200ba8:	d05ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200bac:	84aa                	mv	s1,a0
ffffffffc0200bae:	d131                	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bb0:	8522                	mv	a0,s0
ffffffffc0200bb2:	c99ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bb6:	86a6                	mv	a3,s1
ffffffffc0200bb8:	00006617          	auipc	a2,0x6
ffffffffc0200bbc:	e6860613          	addi	a2,a2,-408 # ffffffffc0206a20 <commands+0x2b0>
ffffffffc0200bc0:	0cd00593          	li	a1,205
ffffffffc0200bc4:	00006517          	auipc	a0,0x6
ffffffffc0200bc8:	04450513          	addi	a0,a0,68 # ffffffffc0206c08 <commands+0x498>
ffffffffc0200bcc:	e4aff0ef          	jal	ra,ffffffffc0200216 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200bd0:	00006517          	auipc	a0,0x6
ffffffffc0200bd4:	e8850513          	addi	a0,a0,-376 # ffffffffc0206a58 <commands+0x2e8>
ffffffffc0200bd8:	cf8ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bdc:	8522                	mv	a0,s0
ffffffffc0200bde:	ccfff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200be2:	84aa                	mv	s1,a0
ffffffffc0200be4:	f00507e3          	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200be8:	8522                	mv	a0,s0
ffffffffc0200bea:	c61ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bee:	86a6                	mv	a3,s1
ffffffffc0200bf0:	00006617          	auipc	a2,0x6
ffffffffc0200bf4:	e3060613          	addi	a2,a2,-464 # ffffffffc0206a20 <commands+0x2b0>
ffffffffc0200bf8:	0d700593          	li	a1,215
ffffffffc0200bfc:	00006517          	auipc	a0,0x6
ffffffffc0200c00:	00c50513          	addi	a0,a0,12 # ffffffffc0206c08 <commands+0x498>
ffffffffc0200c04:	e12ff0ef          	jal	ra,ffffffffc0200216 <__panic>
}
ffffffffc0200c08:	6442                	ld	s0,16(sp)
ffffffffc0200c0a:	60e2                	ld	ra,24(sp)
ffffffffc0200c0c:	64a2                	ld	s1,8(sp)
ffffffffc0200c0e:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200c10:	c3bff06f          	j	ffffffffc020084a <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200c14:	00006617          	auipc	a2,0x6
ffffffffc0200c18:	e2c60613          	addi	a2,a2,-468 # ffffffffc0206a40 <commands+0x2d0>
ffffffffc0200c1c:	0d100593          	li	a1,209
ffffffffc0200c20:	00006517          	auipc	a0,0x6
ffffffffc0200c24:	fe850513          	addi	a0,a0,-24 # ffffffffc0206c08 <commands+0x498>
ffffffffc0200c28:	deeff0ef          	jal	ra,ffffffffc0200216 <__panic>
            print_trapframe(tf);
ffffffffc0200c2c:	c1fff06f          	j	ffffffffc020084a <print_trapframe>
                print_trapframe(tf);
ffffffffc0200c30:	8522                	mv	a0,s0
ffffffffc0200c32:	c19ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c36:	86a6                	mv	a3,s1
ffffffffc0200c38:	00006617          	auipc	a2,0x6
ffffffffc0200c3c:	de860613          	addi	a2,a2,-536 # ffffffffc0206a20 <commands+0x2b0>
ffffffffc0200c40:	0f100593          	li	a1,241
ffffffffc0200c44:	00006517          	auipc	a0,0x6
ffffffffc0200c48:	fc450513          	addi	a0,a0,-60 # ffffffffc0206c08 <commands+0x498>
ffffffffc0200c4c:	dcaff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0200c50 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c50:	1101                	addi	sp,sp,-32
ffffffffc0200c52:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c54:	000ac417          	auipc	s0,0xac
ffffffffc0200c58:	83c40413          	addi	s0,s0,-1988 # ffffffffc02ac490 <current>
ffffffffc0200c5c:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c5e:	ec06                	sd	ra,24(sp)
ffffffffc0200c60:	e426                	sd	s1,8(sp)
ffffffffc0200c62:	e04a                	sd	s2,0(sp)
ffffffffc0200c64:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c68:	cf1d                	beqz	a4,ffffffffc0200ca6 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c6a:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c6e:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c72:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c74:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c78:	0206c463          	bltz	a3,ffffffffc0200ca0 <trap+0x50>
        exception_handler(tf);
ffffffffc0200c7c:	defff0ef          	jal	ra,ffffffffc0200a6a <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c80:	601c                	ld	a5,0(s0)
ffffffffc0200c82:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c86:	e499                	bnez	s1,ffffffffc0200c94 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c88:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c8c:	8b05                	andi	a4,a4,1
ffffffffc0200c8e:	e339                	bnez	a4,ffffffffc0200cd4 <trap+0x84>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c90:	6f9c                	ld	a5,24(a5)
ffffffffc0200c92:	eb95                	bnez	a5,ffffffffc0200cc6 <trap+0x76>
                schedule();
            }
        }
    }
}
ffffffffc0200c94:	60e2                	ld	ra,24(sp)
ffffffffc0200c96:	6442                	ld	s0,16(sp)
ffffffffc0200c98:	64a2                	ld	s1,8(sp)
ffffffffc0200c9a:	6902                	ld	s2,0(sp)
ffffffffc0200c9c:	6105                	addi	sp,sp,32
ffffffffc0200c9e:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200ca0:	d2dff0ef          	jal	ra,ffffffffc02009cc <interrupt_handler>
ffffffffc0200ca4:	bff1                	j	ffffffffc0200c80 <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200ca6:	0006c963          	bltz	a3,ffffffffc0200cb8 <trap+0x68>
}
ffffffffc0200caa:	6442                	ld	s0,16(sp)
ffffffffc0200cac:	60e2                	ld	ra,24(sp)
ffffffffc0200cae:	64a2                	ld	s1,8(sp)
ffffffffc0200cb0:	6902                	ld	s2,0(sp)
ffffffffc0200cb2:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200cb4:	db7ff06f          	j	ffffffffc0200a6a <exception_handler>
}
ffffffffc0200cb8:	6442                	ld	s0,16(sp)
ffffffffc0200cba:	60e2                	ld	ra,24(sp)
ffffffffc0200cbc:	64a2                	ld	s1,8(sp)
ffffffffc0200cbe:	6902                	ld	s2,0(sp)
ffffffffc0200cc0:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200cc2:	d0bff06f          	j	ffffffffc02009cc <interrupt_handler>
}
ffffffffc0200cc6:	6442                	ld	s0,16(sp)
ffffffffc0200cc8:	60e2                	ld	ra,24(sp)
ffffffffc0200cca:	64a2                	ld	s1,8(sp)
ffffffffc0200ccc:	6902                	ld	s2,0(sp)
ffffffffc0200cce:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200cd0:	2de0506f          	j	ffffffffc0205fae <schedule>
                do_exit(-E_KILLED);
ffffffffc0200cd4:	555d                	li	a0,-9
ffffffffc0200cd6:	740040ef          	jal	ra,ffffffffc0205416 <do_exit>
ffffffffc0200cda:	601c                	ld	a5,0(s0)
ffffffffc0200cdc:	bf55                	j	ffffffffc0200c90 <trap+0x40>
	...

ffffffffc0200ce0 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ce0:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200ce4:	00011463          	bnez	sp,ffffffffc0200cec <__alltraps+0xc>
ffffffffc0200ce8:	14002173          	csrr	sp,sscratch
ffffffffc0200cec:	712d                	addi	sp,sp,-288
ffffffffc0200cee:	e002                	sd	zero,0(sp)
ffffffffc0200cf0:	e406                	sd	ra,8(sp)
ffffffffc0200cf2:	ec0e                	sd	gp,24(sp)
ffffffffc0200cf4:	f012                	sd	tp,32(sp)
ffffffffc0200cf6:	f416                	sd	t0,40(sp)
ffffffffc0200cf8:	f81a                	sd	t1,48(sp)
ffffffffc0200cfa:	fc1e                	sd	t2,56(sp)
ffffffffc0200cfc:	e0a2                	sd	s0,64(sp)
ffffffffc0200cfe:	e4a6                	sd	s1,72(sp)
ffffffffc0200d00:	e8aa                	sd	a0,80(sp)
ffffffffc0200d02:	ecae                	sd	a1,88(sp)
ffffffffc0200d04:	f0b2                	sd	a2,96(sp)
ffffffffc0200d06:	f4b6                	sd	a3,104(sp)
ffffffffc0200d08:	f8ba                	sd	a4,112(sp)
ffffffffc0200d0a:	fcbe                	sd	a5,120(sp)
ffffffffc0200d0c:	e142                	sd	a6,128(sp)
ffffffffc0200d0e:	e546                	sd	a7,136(sp)
ffffffffc0200d10:	e94a                	sd	s2,144(sp)
ffffffffc0200d12:	ed4e                	sd	s3,152(sp)
ffffffffc0200d14:	f152                	sd	s4,160(sp)
ffffffffc0200d16:	f556                	sd	s5,168(sp)
ffffffffc0200d18:	f95a                	sd	s6,176(sp)
ffffffffc0200d1a:	fd5e                	sd	s7,184(sp)
ffffffffc0200d1c:	e1e2                	sd	s8,192(sp)
ffffffffc0200d1e:	e5e6                	sd	s9,200(sp)
ffffffffc0200d20:	e9ea                	sd	s10,208(sp)
ffffffffc0200d22:	edee                	sd	s11,216(sp)
ffffffffc0200d24:	f1f2                	sd	t3,224(sp)
ffffffffc0200d26:	f5f6                	sd	t4,232(sp)
ffffffffc0200d28:	f9fa                	sd	t5,240(sp)
ffffffffc0200d2a:	fdfe                	sd	t6,248(sp)
ffffffffc0200d2c:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200d30:	100024f3          	csrr	s1,sstatus
ffffffffc0200d34:	14102973          	csrr	s2,sepc
ffffffffc0200d38:	143029f3          	csrr	s3,stval
ffffffffc0200d3c:	14202a73          	csrr	s4,scause
ffffffffc0200d40:	e822                	sd	s0,16(sp)
ffffffffc0200d42:	e226                	sd	s1,256(sp)
ffffffffc0200d44:	e64a                	sd	s2,264(sp)
ffffffffc0200d46:	ea4e                	sd	s3,272(sp)
ffffffffc0200d48:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d4a:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d4c:	f05ff0ef          	jal	ra,ffffffffc0200c50 <trap>

ffffffffc0200d50 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d50:	6492                	ld	s1,256(sp)
ffffffffc0200d52:	6932                	ld	s2,264(sp)
ffffffffc0200d54:	1004f413          	andi	s0,s1,256
ffffffffc0200d58:	e401                	bnez	s0,ffffffffc0200d60 <__trapret+0x10>
ffffffffc0200d5a:	1200                	addi	s0,sp,288
ffffffffc0200d5c:	14041073          	csrw	sscratch,s0
ffffffffc0200d60:	10049073          	csrw	sstatus,s1
ffffffffc0200d64:	14191073          	csrw	sepc,s2
ffffffffc0200d68:	60a2                	ld	ra,8(sp)
ffffffffc0200d6a:	61e2                	ld	gp,24(sp)
ffffffffc0200d6c:	7202                	ld	tp,32(sp)
ffffffffc0200d6e:	72a2                	ld	t0,40(sp)
ffffffffc0200d70:	7342                	ld	t1,48(sp)
ffffffffc0200d72:	73e2                	ld	t2,56(sp)
ffffffffc0200d74:	6406                	ld	s0,64(sp)
ffffffffc0200d76:	64a6                	ld	s1,72(sp)
ffffffffc0200d78:	6546                	ld	a0,80(sp)
ffffffffc0200d7a:	65e6                	ld	a1,88(sp)
ffffffffc0200d7c:	7606                	ld	a2,96(sp)
ffffffffc0200d7e:	76a6                	ld	a3,104(sp)
ffffffffc0200d80:	7746                	ld	a4,112(sp)
ffffffffc0200d82:	77e6                	ld	a5,120(sp)
ffffffffc0200d84:	680a                	ld	a6,128(sp)
ffffffffc0200d86:	68aa                	ld	a7,136(sp)
ffffffffc0200d88:	694a                	ld	s2,144(sp)
ffffffffc0200d8a:	69ea                	ld	s3,152(sp)
ffffffffc0200d8c:	7a0a                	ld	s4,160(sp)
ffffffffc0200d8e:	7aaa                	ld	s5,168(sp)
ffffffffc0200d90:	7b4a                	ld	s6,176(sp)
ffffffffc0200d92:	7bea                	ld	s7,184(sp)
ffffffffc0200d94:	6c0e                	ld	s8,192(sp)
ffffffffc0200d96:	6cae                	ld	s9,200(sp)
ffffffffc0200d98:	6d4e                	ld	s10,208(sp)
ffffffffc0200d9a:	6dee                	ld	s11,216(sp)
ffffffffc0200d9c:	7e0e                	ld	t3,224(sp)
ffffffffc0200d9e:	7eae                	ld	t4,232(sp)
ffffffffc0200da0:	7f4e                	ld	t5,240(sp)
ffffffffc0200da2:	7fee                	ld	t6,248(sp)
ffffffffc0200da4:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200da6:	10200073          	sret

ffffffffc0200daa <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200daa:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200dac:	b755                	j	ffffffffc0200d50 <__trapret>

ffffffffc0200dae <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200dae:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7698>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200db2:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200db6:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200dba:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200dbe:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200dc2:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200dc6:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200dca:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200dce:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200dd2:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200dd4:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200dd6:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200dd8:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200dda:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200ddc:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200dde:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200de0:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200de2:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200de4:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200de6:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200de8:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200dea:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200dec:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dee:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200df0:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200df2:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200df4:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200df6:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200df8:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200dfa:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dfc:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dfe:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200e00:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200e02:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200e04:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200e06:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200e08:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200e0a:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200e0c:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200e0e:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200e10:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200e12:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200e14:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200e16:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200e18:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200e1a:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200e1c:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200e1e:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200e20:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200e22:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200e24:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200e26:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200e28:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200e2a:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200e2c:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200e2e:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200e30:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200e32:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e34:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e36:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e38:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e3a:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e3c:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e3e:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e40:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e42:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e44:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e46:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e48:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e4a:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e4c:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e4e:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e50:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e52:	812e                	mv	sp,a1
ffffffffc0200e54:	bdf5                	j	ffffffffc0200d50 <__trapret>

ffffffffc0200e56 <pa2page.part.4>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
ffffffffc0200e56:	1141                	addi	sp,sp,-16
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
ffffffffc0200e58:	00006617          	auipc	a2,0x6
ffffffffc0200e5c:	1a860613          	addi	a2,a2,424 # ffffffffc0207000 <commands+0x890>
ffffffffc0200e60:	06200593          	li	a1,98
ffffffffc0200e64:	00006517          	auipc	a0,0x6
ffffffffc0200e68:	1bc50513          	addi	a0,a0,444 # ffffffffc0207020 <commands+0x8b0>
pa2page(uintptr_t pa) {
ffffffffc0200e6c:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0200e6e:	ba8ff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0200e72 <alloc_pages>:
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n)
{
ffffffffc0200e72:	715d                	addi	sp,sp,-80
ffffffffc0200e74:	e0a2                	sd	s0,64(sp)
ffffffffc0200e76:	fc26                	sd	s1,56(sp)
ffffffffc0200e78:	f84a                	sd	s2,48(sp)
ffffffffc0200e7a:	f44e                	sd	s3,40(sp)
ffffffffc0200e7c:	f052                	sd	s4,32(sp)
ffffffffc0200e7e:	ec56                	sd	s5,24(sp)
ffffffffc0200e80:	e486                	sd	ra,72(sp)
ffffffffc0200e82:	842a                	mv	s0,a0
ffffffffc0200e84:	000ab497          	auipc	s1,0xab
ffffffffc0200e88:	63448493          	addi	s1,s1,1588 # ffffffffc02ac4b8 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0)
ffffffffc0200e8c:	4985                	li	s3,1
ffffffffc0200e8e:	000aba17          	auipc	s4,0xab
ffffffffc0200e92:	5faa0a13          	addi	s4,s4,1530 # ffffffffc02ac488 <swap_init_ok>
            break;

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0200e96:	0005091b          	sext.w	s2,a0
ffffffffc0200e9a:	000aba97          	auipc	s5,0xab
ffffffffc0200e9e:	64ea8a93          	addi	s5,s5,1614 # ffffffffc02ac4e8 <check_mm_struct>
ffffffffc0200ea2:	a00d                	j	ffffffffc0200ec4 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0200ea4:	609c                	ld	a5,0(s1)
ffffffffc0200ea6:	6f9c                	ld	a5,24(a5)
ffffffffc0200ea8:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0200eaa:	4601                	li	a2,0
ffffffffc0200eac:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0)
ffffffffc0200eae:	ed0d                	bnez	a0,ffffffffc0200ee8 <alloc_pages+0x76>
ffffffffc0200eb0:	0289ec63          	bltu	s3,s0,ffffffffc0200ee8 <alloc_pages+0x76>
ffffffffc0200eb4:	000a2783          	lw	a5,0(s4)
ffffffffc0200eb8:	2781                	sext.w	a5,a5
ffffffffc0200eba:	c79d                	beqz	a5,ffffffffc0200ee8 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200ebc:	000ab503          	ld	a0,0(s5)
ffffffffc0200ec0:	76b020ef          	jal	ra,ffffffffc0203e2a <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200ec4:	100027f3          	csrr	a5,sstatus
ffffffffc0200ec8:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0200eca:	8522                	mv	a0,s0
ffffffffc0200ecc:	dfe1                	beqz	a5,ffffffffc0200ea4 <alloc_pages+0x32>
        intr_disable();
ffffffffc0200ece:	f8eff0ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc0200ed2:	609c                	ld	a5,0(s1)
ffffffffc0200ed4:	8522                	mv	a0,s0
ffffffffc0200ed6:	6f9c                	ld	a5,24(a5)
ffffffffc0200ed8:	9782                	jalr	a5
ffffffffc0200eda:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200edc:	f7aff0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc0200ee0:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0200ee2:	4601                	li	a2,0
ffffffffc0200ee4:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0)
ffffffffc0200ee6:	d569                	beqz	a0,ffffffffc0200eb0 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0200ee8:	60a6                	ld	ra,72(sp)
ffffffffc0200eea:	6406                	ld	s0,64(sp)
ffffffffc0200eec:	74e2                	ld	s1,56(sp)
ffffffffc0200eee:	7942                	ld	s2,48(sp)
ffffffffc0200ef0:	79a2                	ld	s3,40(sp)
ffffffffc0200ef2:	7a02                	ld	s4,32(sp)
ffffffffc0200ef4:	6ae2                	ld	s5,24(sp)
ffffffffc0200ef6:	6161                	addi	sp,sp,80
ffffffffc0200ef8:	8082                	ret

ffffffffc0200efa <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200efa:	100027f3          	csrr	a5,sstatus
ffffffffc0200efe:	8b89                	andi	a5,a5,2
ffffffffc0200f00:	eb89                	bnez	a5,ffffffffc0200f12 <free_pages+0x18>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200f02:	000ab797          	auipc	a5,0xab
ffffffffc0200f06:	5b678793          	addi	a5,a5,1462 # ffffffffc02ac4b8 <pmm_manager>
ffffffffc0200f0a:	639c                	ld	a5,0(a5)
ffffffffc0200f0c:	0207b303          	ld	t1,32(a5)
ffffffffc0200f10:	8302                	jr	t1
{
ffffffffc0200f12:	1101                	addi	sp,sp,-32
ffffffffc0200f14:	ec06                	sd	ra,24(sp)
ffffffffc0200f16:	e822                	sd	s0,16(sp)
ffffffffc0200f18:	e426                	sd	s1,8(sp)
ffffffffc0200f1a:	842a                	mv	s0,a0
ffffffffc0200f1c:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200f1e:	f3eff0ef          	jal	ra,ffffffffc020065c <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200f22:	000ab797          	auipc	a5,0xab
ffffffffc0200f26:	59678793          	addi	a5,a5,1430 # ffffffffc02ac4b8 <pmm_manager>
ffffffffc0200f2a:	639c                	ld	a5,0(a5)
ffffffffc0200f2c:	85a6                	mv	a1,s1
ffffffffc0200f2e:	8522                	mv	a0,s0
ffffffffc0200f30:	739c                	ld	a5,32(a5)
ffffffffc0200f32:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200f34:	6442                	ld	s0,16(sp)
ffffffffc0200f36:	60e2                	ld	ra,24(sp)
ffffffffc0200f38:	64a2                	ld	s1,8(sp)
ffffffffc0200f3a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200f3c:	f1aff06f          	j	ffffffffc0200656 <intr_enable>

ffffffffc0200f40 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f40:	100027f3          	csrr	a5,sstatus
ffffffffc0200f44:	8b89                	andi	a5,a5,2
ffffffffc0200f46:	eb89                	bnez	a5,ffffffffc0200f58 <nr_free_pages+0x18>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f48:	000ab797          	auipc	a5,0xab
ffffffffc0200f4c:	57078793          	addi	a5,a5,1392 # ffffffffc02ac4b8 <pmm_manager>
ffffffffc0200f50:	639c                	ld	a5,0(a5)
ffffffffc0200f52:	0287b303          	ld	t1,40(a5)
ffffffffc0200f56:	8302                	jr	t1
{
ffffffffc0200f58:	1141                	addi	sp,sp,-16
ffffffffc0200f5a:	e406                	sd	ra,8(sp)
ffffffffc0200f5c:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200f5e:	efeff0ef          	jal	ra,ffffffffc020065c <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f62:	000ab797          	auipc	a5,0xab
ffffffffc0200f66:	55678793          	addi	a5,a5,1366 # ffffffffc02ac4b8 <pmm_manager>
ffffffffc0200f6a:	639c                	ld	a5,0(a5)
ffffffffc0200f6c:	779c                	ld	a5,40(a5)
ffffffffc0200f6e:	9782                	jalr	a5
ffffffffc0200f70:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200f72:	ee4ff0ef          	jal	ra,ffffffffc0200656 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200f76:	8522                	mv	a0,s0
ffffffffc0200f78:	60a2                	ld	ra,8(sp)
ffffffffc0200f7a:	6402                	ld	s0,0(sp)
ffffffffc0200f7c:	0141                	addi	sp,sp,16
ffffffffc0200f7e:	8082                	ret

ffffffffc0200f80 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
ffffffffc0200f80:	7139                	addi	sp,sp,-64
ffffffffc0200f82:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200f84:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0200f88:	1ff4f493          	andi	s1,s1,511
ffffffffc0200f8c:	048e                	slli	s1,s1,0x3
ffffffffc0200f8e:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V))
ffffffffc0200f90:	6094                	ld	a3,0(s1)
{
ffffffffc0200f92:	f04a                	sd	s2,32(sp)
ffffffffc0200f94:	ec4e                	sd	s3,24(sp)
ffffffffc0200f96:	e852                	sd	s4,16(sp)
ffffffffc0200f98:	fc06                	sd	ra,56(sp)
ffffffffc0200f9a:	f822                	sd	s0,48(sp)
ffffffffc0200f9c:	e456                	sd	s5,8(sp)
ffffffffc0200f9e:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc0200fa0:	0016f793          	andi	a5,a3,1
{
ffffffffc0200fa4:	892e                	mv	s2,a1
ffffffffc0200fa6:	8a32                	mv	s4,a2
ffffffffc0200fa8:	000ab997          	auipc	s3,0xab
ffffffffc0200fac:	4c098993          	addi	s3,s3,1216 # ffffffffc02ac468 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc0200fb0:	e7bd                	bnez	a5,ffffffffc020101e <get_pte+0x9e>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0200fb2:	12060c63          	beqz	a2,ffffffffc02010ea <get_pte+0x16a>
ffffffffc0200fb6:	4505                	li	a0,1
ffffffffc0200fb8:	ebbff0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc0200fbc:	842a                	mv	s0,a0
ffffffffc0200fbe:	12050663          	beqz	a0,ffffffffc02010ea <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0200fc2:	000abb17          	auipc	s6,0xab
ffffffffc0200fc6:	50eb0b13          	addi	s6,s6,1294 # ffffffffc02ac4d0 <pages>
ffffffffc0200fca:	000b3503          	ld	a0,0(s6)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0200fce:	4785                	li	a5,1
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200fd0:	000ab997          	auipc	s3,0xab
ffffffffc0200fd4:	49898993          	addi	s3,s3,1176 # ffffffffc02ac468 <npage>
    return page - pages + nbase;
ffffffffc0200fd8:	40a40533          	sub	a0,s0,a0
ffffffffc0200fdc:	00080ab7          	lui	s5,0x80
ffffffffc0200fe0:	8519                	srai	a0,a0,0x6
ffffffffc0200fe2:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0200fe6:	c01c                	sw	a5,0(s0)
ffffffffc0200fe8:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0200fea:	9556                	add	a0,a0,s5
ffffffffc0200fec:	83b1                	srli	a5,a5,0xc
ffffffffc0200fee:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ff0:	0532                	slli	a0,a0,0xc
ffffffffc0200ff2:	14e7f363          	bleu	a4,a5,ffffffffc0201138 <get_pte+0x1b8>
ffffffffc0200ff6:	000ab797          	auipc	a5,0xab
ffffffffc0200ffa:	4ca78793          	addi	a5,a5,1226 # ffffffffc02ac4c0 <va_pa_offset>
ffffffffc0200ffe:	639c                	ld	a5,0(a5)
ffffffffc0201000:	6605                	lui	a2,0x1
ffffffffc0201002:	4581                	li	a1,0
ffffffffc0201004:	953e                	add	a0,a0,a5
ffffffffc0201006:	1bc050ef          	jal	ra,ffffffffc02061c2 <memset>
    return page - pages + nbase;
ffffffffc020100a:	000b3683          	ld	a3,0(s6)
ffffffffc020100e:	40d406b3          	sub	a3,s0,a3
ffffffffc0201012:	8699                	srai	a3,a3,0x6
ffffffffc0201014:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201016:	06aa                	slli	a3,a3,0xa
ffffffffc0201018:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020101c:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020101e:	77fd                	lui	a5,0xfffff
ffffffffc0201020:	068a                	slli	a3,a3,0x2
ffffffffc0201022:	0009b703          	ld	a4,0(s3)
ffffffffc0201026:	8efd                	and	a3,a3,a5
ffffffffc0201028:	00c6d793          	srli	a5,a3,0xc
ffffffffc020102c:	0ce7f163          	bleu	a4,a5,ffffffffc02010ee <get_pte+0x16e>
ffffffffc0201030:	000aba97          	auipc	s5,0xab
ffffffffc0201034:	490a8a93          	addi	s5,s5,1168 # ffffffffc02ac4c0 <va_pa_offset>
ffffffffc0201038:	000ab403          	ld	s0,0(s5)
ffffffffc020103c:	01595793          	srli	a5,s2,0x15
ffffffffc0201040:	1ff7f793          	andi	a5,a5,511
ffffffffc0201044:	96a2                	add	a3,a3,s0
ffffffffc0201046:	00379413          	slli	s0,a5,0x3
ffffffffc020104a:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V))
ffffffffc020104c:	6014                	ld	a3,0(s0)
ffffffffc020104e:	0016f793          	andi	a5,a3,1
ffffffffc0201052:	e3ad                	bnez	a5,ffffffffc02010b4 <get_pte+0x134>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201054:	080a0b63          	beqz	s4,ffffffffc02010ea <get_pte+0x16a>
ffffffffc0201058:	4505                	li	a0,1
ffffffffc020105a:	e19ff0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc020105e:	84aa                	mv	s1,a0
ffffffffc0201060:	c549                	beqz	a0,ffffffffc02010ea <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201062:	000abb17          	auipc	s6,0xab
ffffffffc0201066:	46eb0b13          	addi	s6,s6,1134 # ffffffffc02ac4d0 <pages>
ffffffffc020106a:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc020106e:	4785                	li	a5,1
    return page - pages + nbase;
ffffffffc0201070:	00080a37          	lui	s4,0x80
ffffffffc0201074:	40a48533          	sub	a0,s1,a0
ffffffffc0201078:	8519                	srai	a0,a0,0x6
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020107a:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc020107e:	c09c                	sw	a5,0(s1)
ffffffffc0201080:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0201082:	9552                	add	a0,a0,s4
ffffffffc0201084:	83b1                	srli	a5,a5,0xc
ffffffffc0201086:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201088:	0532                	slli	a0,a0,0xc
ffffffffc020108a:	08e7fa63          	bleu	a4,a5,ffffffffc020111e <get_pte+0x19e>
ffffffffc020108e:	000ab783          	ld	a5,0(s5)
ffffffffc0201092:	6605                	lui	a2,0x1
ffffffffc0201094:	4581                	li	a1,0
ffffffffc0201096:	953e                	add	a0,a0,a5
ffffffffc0201098:	12a050ef          	jal	ra,ffffffffc02061c2 <memset>
    return page - pages + nbase;
ffffffffc020109c:	000b3683          	ld	a3,0(s6)
ffffffffc02010a0:	40d486b3          	sub	a3,s1,a3
ffffffffc02010a4:	8699                	srai	a3,a3,0x6
ffffffffc02010a6:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02010a8:	06aa                	slli	a3,a3,0xa
ffffffffc02010aa:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02010ae:	e014                	sd	a3,0(s0)
ffffffffc02010b0:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02010b4:	068a                	slli	a3,a3,0x2
ffffffffc02010b6:	757d                	lui	a0,0xfffff
ffffffffc02010b8:	8ee9                	and	a3,a3,a0
ffffffffc02010ba:	00c6d793          	srli	a5,a3,0xc
ffffffffc02010be:	04e7f463          	bleu	a4,a5,ffffffffc0201106 <get_pte+0x186>
ffffffffc02010c2:	000ab503          	ld	a0,0(s5)
ffffffffc02010c6:	00c95793          	srli	a5,s2,0xc
ffffffffc02010ca:	1ff7f793          	andi	a5,a5,511
ffffffffc02010ce:	96aa                	add	a3,a3,a0
ffffffffc02010d0:	00379513          	slli	a0,a5,0x3
ffffffffc02010d4:	9536                	add	a0,a0,a3
}
ffffffffc02010d6:	70e2                	ld	ra,56(sp)
ffffffffc02010d8:	7442                	ld	s0,48(sp)
ffffffffc02010da:	74a2                	ld	s1,40(sp)
ffffffffc02010dc:	7902                	ld	s2,32(sp)
ffffffffc02010de:	69e2                	ld	s3,24(sp)
ffffffffc02010e0:	6a42                	ld	s4,16(sp)
ffffffffc02010e2:	6aa2                	ld	s5,8(sp)
ffffffffc02010e4:	6b02                	ld	s6,0(sp)
ffffffffc02010e6:	6121                	addi	sp,sp,64
ffffffffc02010e8:	8082                	ret
            return NULL;
ffffffffc02010ea:	4501                	li	a0,0
ffffffffc02010ec:	b7ed                	j	ffffffffc02010d6 <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02010ee:	00006617          	auipc	a2,0x6
ffffffffc02010f2:	eda60613          	addi	a2,a2,-294 # ffffffffc0206fc8 <commands+0x858>
ffffffffc02010f6:	0f500593          	li	a1,245
ffffffffc02010fa:	00006517          	auipc	a0,0x6
ffffffffc02010fe:	ef650513          	addi	a0,a0,-266 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201102:	914ff0ef          	jal	ra,ffffffffc0200216 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201106:	00006617          	auipc	a2,0x6
ffffffffc020110a:	ec260613          	addi	a2,a2,-318 # ffffffffc0206fc8 <commands+0x858>
ffffffffc020110e:	10200593          	li	a1,258
ffffffffc0201112:	00006517          	auipc	a0,0x6
ffffffffc0201116:	ede50513          	addi	a0,a0,-290 # ffffffffc0206ff0 <commands+0x880>
ffffffffc020111a:	8fcff0ef          	jal	ra,ffffffffc0200216 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020111e:	86aa                	mv	a3,a0
ffffffffc0201120:	00006617          	auipc	a2,0x6
ffffffffc0201124:	ea860613          	addi	a2,a2,-344 # ffffffffc0206fc8 <commands+0x858>
ffffffffc0201128:	0ff00593          	li	a1,255
ffffffffc020112c:	00006517          	auipc	a0,0x6
ffffffffc0201130:	ec450513          	addi	a0,a0,-316 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201134:	8e2ff0ef          	jal	ra,ffffffffc0200216 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201138:	86aa                	mv	a3,a0
ffffffffc020113a:	00006617          	auipc	a2,0x6
ffffffffc020113e:	e8e60613          	addi	a2,a2,-370 # ffffffffc0206fc8 <commands+0x858>
ffffffffc0201142:	0f100593          	li	a1,241
ffffffffc0201146:	00006517          	auipc	a0,0x6
ffffffffc020114a:	eaa50513          	addi	a0,a0,-342 # ffffffffc0206ff0 <commands+0x880>
ffffffffc020114e:	8c8ff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0201152 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc0201152:	1141                	addi	sp,sp,-16
ffffffffc0201154:	e022                	sd	s0,0(sp)
ffffffffc0201156:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201158:	4601                	li	a2,0
{
ffffffffc020115a:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020115c:	e25ff0ef          	jal	ra,ffffffffc0200f80 <get_pte>
    if (ptep_store != NULL)
ffffffffc0201160:	c011                	beqz	s0,ffffffffc0201164 <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc0201162:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0201164:	c129                	beqz	a0,ffffffffc02011a6 <get_page+0x54>
ffffffffc0201166:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201168:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc020116a:	0017f713          	andi	a4,a5,1
ffffffffc020116e:	e709                	bnez	a4,ffffffffc0201178 <get_page+0x26>
}
ffffffffc0201170:	60a2                	ld	ra,8(sp)
ffffffffc0201172:	6402                	ld	s0,0(sp)
ffffffffc0201174:	0141                	addi	sp,sp,16
ffffffffc0201176:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201178:	000ab717          	auipc	a4,0xab
ffffffffc020117c:	2f070713          	addi	a4,a4,752 # ffffffffc02ac468 <npage>
ffffffffc0201180:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201182:	078a                	slli	a5,a5,0x2
ffffffffc0201184:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201186:	02e7f563          	bleu	a4,a5,ffffffffc02011b0 <get_page+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc020118a:	000ab717          	auipc	a4,0xab
ffffffffc020118e:	34670713          	addi	a4,a4,838 # ffffffffc02ac4d0 <pages>
ffffffffc0201192:	6308                	ld	a0,0(a4)
ffffffffc0201194:	60a2                	ld	ra,8(sp)
ffffffffc0201196:	6402                	ld	s0,0(sp)
ffffffffc0201198:	fff80737          	lui	a4,0xfff80
ffffffffc020119c:	97ba                	add	a5,a5,a4
ffffffffc020119e:	079a                	slli	a5,a5,0x6
ffffffffc02011a0:	953e                	add	a0,a0,a5
ffffffffc02011a2:	0141                	addi	sp,sp,16
ffffffffc02011a4:	8082                	ret
ffffffffc02011a6:	60a2                	ld	ra,8(sp)
ffffffffc02011a8:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc02011aa:	4501                	li	a0,0
}
ffffffffc02011ac:	0141                	addi	sp,sp,16
ffffffffc02011ae:	8082                	ret
ffffffffc02011b0:	ca7ff0ef          	jal	ra,ffffffffc0200e56 <pa2page.part.4>

ffffffffc02011b4 <unmap_range>:
        tlb_invalidate(pgdir, la); //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
ffffffffc02011b4:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02011b6:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc02011ba:	ec86                	sd	ra,88(sp)
ffffffffc02011bc:	e8a2                	sd	s0,80(sp)
ffffffffc02011be:	e4a6                	sd	s1,72(sp)
ffffffffc02011c0:	e0ca                	sd	s2,64(sp)
ffffffffc02011c2:	fc4e                	sd	s3,56(sp)
ffffffffc02011c4:	f852                	sd	s4,48(sp)
ffffffffc02011c6:	f456                	sd	s5,40(sp)
ffffffffc02011c8:	f05a                	sd	s6,32(sp)
ffffffffc02011ca:	ec5e                	sd	s7,24(sp)
ffffffffc02011cc:	e862                	sd	s8,16(sp)
ffffffffc02011ce:	e466                	sd	s9,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02011d0:	03479713          	slli	a4,a5,0x34
ffffffffc02011d4:	eb71                	bnez	a4,ffffffffc02012a8 <unmap_range+0xf4>
    assert(USER_ACCESS(start, end));
ffffffffc02011d6:	002007b7          	lui	a5,0x200
ffffffffc02011da:	842e                	mv	s0,a1
ffffffffc02011dc:	0af5e663          	bltu	a1,a5,ffffffffc0201288 <unmap_range+0xd4>
ffffffffc02011e0:	8932                	mv	s2,a2
ffffffffc02011e2:	0ac5f363          	bleu	a2,a1,ffffffffc0201288 <unmap_range+0xd4>
ffffffffc02011e6:	4785                	li	a5,1
ffffffffc02011e8:	07fe                	slli	a5,a5,0x1f
ffffffffc02011ea:	08c7ef63          	bltu	a5,a2,ffffffffc0201288 <unmap_range+0xd4>
ffffffffc02011ee:	89aa                	mv	s3,a0
        }
        if (*ptep != 0)
        {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02011f0:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02011f2:	000abc97          	auipc	s9,0xab
ffffffffc02011f6:	276c8c93          	addi	s9,s9,630 # ffffffffc02ac468 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02011fa:	000abc17          	auipc	s8,0xab
ffffffffc02011fe:	2d6c0c13          	addi	s8,s8,726 # ffffffffc02ac4d0 <pages>
ffffffffc0201202:	fff80bb7          	lui	s7,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0201206:	00200b37          	lui	s6,0x200
ffffffffc020120a:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc020120e:	4601                	li	a2,0
ffffffffc0201210:	85a2                	mv	a1,s0
ffffffffc0201212:	854e                	mv	a0,s3
ffffffffc0201214:	d6dff0ef          	jal	ra,ffffffffc0200f80 <get_pte>
ffffffffc0201218:	84aa                	mv	s1,a0
        if (ptep == NULL)
ffffffffc020121a:	cd21                	beqz	a0,ffffffffc0201272 <unmap_range+0xbe>
        if (*ptep != 0)
ffffffffc020121c:	611c                	ld	a5,0(a0)
ffffffffc020121e:	e38d                	bnez	a5,ffffffffc0201240 <unmap_range+0x8c>
        start += PGSIZE;
ffffffffc0201220:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0201222:	ff2466e3          	bltu	s0,s2,ffffffffc020120e <unmap_range+0x5a>
}
ffffffffc0201226:	60e6                	ld	ra,88(sp)
ffffffffc0201228:	6446                	ld	s0,80(sp)
ffffffffc020122a:	64a6                	ld	s1,72(sp)
ffffffffc020122c:	6906                	ld	s2,64(sp)
ffffffffc020122e:	79e2                	ld	s3,56(sp)
ffffffffc0201230:	7a42                	ld	s4,48(sp)
ffffffffc0201232:	7aa2                	ld	s5,40(sp)
ffffffffc0201234:	7b02                	ld	s6,32(sp)
ffffffffc0201236:	6be2                	ld	s7,24(sp)
ffffffffc0201238:	6c42                	ld	s8,16(sp)
ffffffffc020123a:	6ca2                	ld	s9,8(sp)
ffffffffc020123c:	6125                	addi	sp,sp,96
ffffffffc020123e:	8082                	ret
    if (*ptep & PTE_V)
ffffffffc0201240:	0017f713          	andi	a4,a5,1
ffffffffc0201244:	df71                	beqz	a4,ffffffffc0201220 <unmap_range+0x6c>
    if (PPN(pa) >= npage) {
ffffffffc0201246:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020124a:	078a                	slli	a5,a5,0x2
ffffffffc020124c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020124e:	06e7fd63          	bleu	a4,a5,ffffffffc02012c8 <unmap_range+0x114>
    return &pages[PPN(pa) - nbase];
ffffffffc0201252:	000c3503          	ld	a0,0(s8)
ffffffffc0201256:	97de                	add	a5,a5,s7
ffffffffc0201258:	079a                	slli	a5,a5,0x6
ffffffffc020125a:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020125c:	411c                	lw	a5,0(a0)
ffffffffc020125e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201262:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201264:	cf11                	beqz	a4,ffffffffc0201280 <unmap_range+0xcc>
        *ptep = 0;                 //(5) clear second page table entry
ffffffffc0201266:	0004b023          	sd	zero,0(s1)

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020126a:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc020126e:	9452                	add	s0,s0,s4
ffffffffc0201270:	bf4d                	j	ffffffffc0201222 <unmap_range+0x6e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0201272:	945a                	add	s0,s0,s6
ffffffffc0201274:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0201278:	d45d                	beqz	s0,ffffffffc0201226 <unmap_range+0x72>
ffffffffc020127a:	f9246ae3          	bltu	s0,s2,ffffffffc020120e <unmap_range+0x5a>
ffffffffc020127e:	b765                	j	ffffffffc0201226 <unmap_range+0x72>
            free_page(page);
ffffffffc0201280:	4585                	li	a1,1
ffffffffc0201282:	c79ff0ef          	jal	ra,ffffffffc0200efa <free_pages>
ffffffffc0201286:	b7c5                	j	ffffffffc0201266 <unmap_range+0xb2>
    assert(USER_ACCESS(start, end));
ffffffffc0201288:	00006697          	auipc	a3,0x6
ffffffffc020128c:	37068693          	addi	a3,a3,880 # ffffffffc02075f8 <commands+0xe88>
ffffffffc0201290:	00006617          	auipc	a2,0x6
ffffffffc0201294:	96060613          	addi	a2,a2,-1696 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201298:	12b00593          	li	a1,299
ffffffffc020129c:	00006517          	auipc	a0,0x6
ffffffffc02012a0:	d5450513          	addi	a0,a0,-684 # ffffffffc0206ff0 <commands+0x880>
ffffffffc02012a4:	f73fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02012a8:	00006697          	auipc	a3,0x6
ffffffffc02012ac:	32068693          	addi	a3,a3,800 # ffffffffc02075c8 <commands+0xe58>
ffffffffc02012b0:	00006617          	auipc	a2,0x6
ffffffffc02012b4:	94060613          	addi	a2,a2,-1728 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02012b8:	12a00593          	li	a1,298
ffffffffc02012bc:	00006517          	auipc	a0,0x6
ffffffffc02012c0:	d3450513          	addi	a0,a0,-716 # ffffffffc0206ff0 <commands+0x880>
ffffffffc02012c4:	f53fe0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc02012c8:	b8fff0ef          	jal	ra,ffffffffc0200e56 <pa2page.part.4>

ffffffffc02012cc <exit_range>:
{
ffffffffc02012cc:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02012ce:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc02012d2:	fc86                	sd	ra,120(sp)
ffffffffc02012d4:	f8a2                	sd	s0,112(sp)
ffffffffc02012d6:	f4a6                	sd	s1,104(sp)
ffffffffc02012d8:	f0ca                	sd	s2,96(sp)
ffffffffc02012da:	ecce                	sd	s3,88(sp)
ffffffffc02012dc:	e8d2                	sd	s4,80(sp)
ffffffffc02012de:	e4d6                	sd	s5,72(sp)
ffffffffc02012e0:	e0da                	sd	s6,64(sp)
ffffffffc02012e2:	fc5e                	sd	s7,56(sp)
ffffffffc02012e4:	f862                	sd	s8,48(sp)
ffffffffc02012e6:	f466                	sd	s9,40(sp)
ffffffffc02012e8:	f06a                	sd	s10,32(sp)
ffffffffc02012ea:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02012ec:	03479713          	slli	a4,a5,0x34
ffffffffc02012f0:	1c071163          	bnez	a4,ffffffffc02014b2 <exit_range+0x1e6>
    assert(USER_ACCESS(start, end));
ffffffffc02012f4:	002007b7          	lui	a5,0x200
ffffffffc02012f8:	20f5e563          	bltu	a1,a5,ffffffffc0201502 <exit_range+0x236>
ffffffffc02012fc:	8b32                	mv	s6,a2
ffffffffc02012fe:	20c5f263          	bleu	a2,a1,ffffffffc0201502 <exit_range+0x236>
ffffffffc0201302:	4785                	li	a5,1
ffffffffc0201304:	07fe                	slli	a5,a5,0x1f
ffffffffc0201306:	1ec7ee63          	bltu	a5,a2,ffffffffc0201502 <exit_range+0x236>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc020130a:	c00009b7          	lui	s3,0xc0000
ffffffffc020130e:	400007b7          	lui	a5,0x40000
ffffffffc0201312:	0135f9b3          	and	s3,a1,s3
ffffffffc0201316:	99be                	add	s3,s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0201318:	c0000337          	lui	t1,0xc0000
ffffffffc020131c:	00698933          	add	s2,s3,t1
ffffffffc0201320:	01e95913          	srli	s2,s2,0x1e
ffffffffc0201324:	1ff97913          	andi	s2,s2,511
ffffffffc0201328:	8e2a                	mv	t3,a0
ffffffffc020132a:	090e                	slli	s2,s2,0x3
ffffffffc020132c:	9972                	add	s2,s2,t3
ffffffffc020132e:	00093b83          	ld	s7,0(s2)
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0201332:	ffe004b7          	lui	s1,0xffe00
    return KADDR(page2pa(page));
ffffffffc0201336:	5dfd                	li	s11,-1
        if (pde1 & PTE_V)
ffffffffc0201338:	001bf793          	andi	a5,s7,1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc020133c:	8ced                	and	s1,s1,a1
    if (PPN(pa) >= npage) {
ffffffffc020133e:	000abd17          	auipc	s10,0xab
ffffffffc0201342:	12ad0d13          	addi	s10,s10,298 # ffffffffc02ac468 <npage>
    return KADDR(page2pa(page));
ffffffffc0201346:	00cddd93          	srli	s11,s11,0xc
ffffffffc020134a:	000ab717          	auipc	a4,0xab
ffffffffc020134e:	17670713          	addi	a4,a4,374 # ffffffffc02ac4c0 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc0201352:	000abe97          	auipc	t4,0xab
ffffffffc0201356:	17ee8e93          	addi	t4,t4,382 # ffffffffc02ac4d0 <pages>
        if (pde1 & PTE_V)
ffffffffc020135a:	e79d                	bnez	a5,ffffffffc0201388 <exit_range+0xbc>
    } while (d1start != 0 && d1start < end);
ffffffffc020135c:	12098963          	beqz	s3,ffffffffc020148e <exit_range+0x1c2>
ffffffffc0201360:	400007b7          	lui	a5,0x40000
ffffffffc0201364:	84ce                	mv	s1,s3
ffffffffc0201366:	97ce                	add	a5,a5,s3
ffffffffc0201368:	1369f363          	bleu	s6,s3,ffffffffc020148e <exit_range+0x1c2>
ffffffffc020136c:	89be                	mv	s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc020136e:	00698933          	add	s2,s3,t1
ffffffffc0201372:	01e95913          	srli	s2,s2,0x1e
ffffffffc0201376:	1ff97913          	andi	s2,s2,511
ffffffffc020137a:	090e                	slli	s2,s2,0x3
ffffffffc020137c:	9972                	add	s2,s2,t3
ffffffffc020137e:	00093b83          	ld	s7,0(s2)
        if (pde1 & PTE_V)
ffffffffc0201382:	001bf793          	andi	a5,s7,1
ffffffffc0201386:	dbf9                	beqz	a5,ffffffffc020135c <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0201388:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc020138c:	0b8a                	slli	s7,s7,0x2
ffffffffc020138e:	00cbdb93          	srli	s7,s7,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201392:	14fbfc63          	bleu	a5,s7,ffffffffc02014ea <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201396:	fff80ab7          	lui	s5,0xfff80
ffffffffc020139a:	9ade                	add	s5,s5,s7
    return page - pages + nbase;
ffffffffc020139c:	000806b7          	lui	a3,0x80
ffffffffc02013a0:	96d6                	add	a3,a3,s5
ffffffffc02013a2:	006a9593          	slli	a1,s5,0x6
    return KADDR(page2pa(page));
ffffffffc02013a6:	01b6f633          	and	a2,a3,s11
    return page - pages + nbase;
ffffffffc02013aa:	e42e                	sd	a1,8(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc02013ac:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02013ae:	12f67263          	bleu	a5,a2,ffffffffc02014d2 <exit_range+0x206>
ffffffffc02013b2:	00073a03          	ld	s4,0(a4)
            free_pd0 = 1;
ffffffffc02013b6:	4c85                	li	s9,1
    return &pages[PPN(pa) - nbase];
ffffffffc02013b8:	fff808b7          	lui	a7,0xfff80
    return KADDR(page2pa(page));
ffffffffc02013bc:	9a36                	add	s4,s4,a3
    return page - pages + nbase;
ffffffffc02013be:	00080837          	lui	a6,0x80
ffffffffc02013c2:	6a85                	lui	s5,0x1
                d0start += PTSIZE;
ffffffffc02013c4:	00200c37          	lui	s8,0x200
ffffffffc02013c8:	a801                	j	ffffffffc02013d8 <exit_range+0x10c>
                    free_pd0 = 0;
ffffffffc02013ca:	4c81                	li	s9,0
                d0start += PTSIZE;
ffffffffc02013cc:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc02013ce:	c0d9                	beqz	s1,ffffffffc0201454 <exit_range+0x188>
ffffffffc02013d0:	0934f263          	bleu	s3,s1,ffffffffc0201454 <exit_range+0x188>
ffffffffc02013d4:	0d64fc63          	bleu	s6,s1,ffffffffc02014ac <exit_range+0x1e0>
                pde0 = pd0[PDX0(d0start)];
ffffffffc02013d8:	0154d413          	srli	s0,s1,0x15
ffffffffc02013dc:	1ff47413          	andi	s0,s0,511
ffffffffc02013e0:	040e                	slli	s0,s0,0x3
ffffffffc02013e2:	9452                	add	s0,s0,s4
ffffffffc02013e4:	601c                	ld	a5,0(s0)
                if (pde0 & PTE_V)
ffffffffc02013e6:	0017f693          	andi	a3,a5,1
ffffffffc02013ea:	d2e5                	beqz	a3,ffffffffc02013ca <exit_range+0xfe>
    if (PPN(pa) >= npage) {
ffffffffc02013ec:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02013f0:	00279513          	slli	a0,a5,0x2
ffffffffc02013f4:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02013f6:	0eb57a63          	bleu	a1,a0,ffffffffc02014ea <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc02013fa:	9546                	add	a0,a0,a7
    return page - pages + nbase;
ffffffffc02013fc:	010506b3          	add	a3,a0,a6
    return KADDR(page2pa(page));
ffffffffc0201400:	01b6f7b3          	and	a5,a3,s11
    return page - pages + nbase;
ffffffffc0201404:	051a                	slli	a0,a0,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0201406:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201408:	0cb7f563          	bleu	a1,a5,ffffffffc02014d2 <exit_range+0x206>
ffffffffc020140c:	631c                	ld	a5,0(a4)
ffffffffc020140e:	96be                	add	a3,a3,a5
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc0201410:	015685b3          	add	a1,a3,s5
                        if (pt[i] & PTE_V)
ffffffffc0201414:	629c                	ld	a5,0(a3)
ffffffffc0201416:	8b85                	andi	a5,a5,1
ffffffffc0201418:	fbd5                	bnez	a5,ffffffffc02013cc <exit_range+0x100>
ffffffffc020141a:	06a1                	addi	a3,a3,8
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc020141c:	fed59ce3          	bne	a1,a3,ffffffffc0201414 <exit_range+0x148>
    return &pages[PPN(pa) - nbase];
ffffffffc0201420:	000eb783          	ld	a5,0(t4)
                        free_page(pde2page(pde0));
ffffffffc0201424:	4585                	li	a1,1
ffffffffc0201426:	e072                	sd	t3,0(sp)
ffffffffc0201428:	953e                	add	a0,a0,a5
ffffffffc020142a:	ad1ff0ef          	jal	ra,ffffffffc0200efa <free_pages>
                d0start += PTSIZE;
ffffffffc020142e:	94e2                	add	s1,s1,s8
                        pd0[PDX0(d0start)] = 0;
ffffffffc0201430:	00043023          	sd	zero,0(s0)
ffffffffc0201434:	000abe97          	auipc	t4,0xab
ffffffffc0201438:	09ce8e93          	addi	t4,t4,156 # ffffffffc02ac4d0 <pages>
ffffffffc020143c:	6e02                	ld	t3,0(sp)
ffffffffc020143e:	c0000337          	lui	t1,0xc0000
ffffffffc0201442:	fff808b7          	lui	a7,0xfff80
ffffffffc0201446:	00080837          	lui	a6,0x80
ffffffffc020144a:	000ab717          	auipc	a4,0xab
ffffffffc020144e:	07670713          	addi	a4,a4,118 # ffffffffc02ac4c0 <va_pa_offset>
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0201452:	fcbd                	bnez	s1,ffffffffc02013d0 <exit_range+0x104>
            if (free_pd0)
ffffffffc0201454:	f00c84e3          	beqz	s9,ffffffffc020135c <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0201458:	000d3783          	ld	a5,0(s10)
ffffffffc020145c:	e072                	sd	t3,0(sp)
ffffffffc020145e:	08fbf663          	bleu	a5,s7,ffffffffc02014ea <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201462:	000eb503          	ld	a0,0(t4)
                free_page(pde2page(pde1));
ffffffffc0201466:	67a2                	ld	a5,8(sp)
ffffffffc0201468:	4585                	li	a1,1
ffffffffc020146a:	953e                	add	a0,a0,a5
ffffffffc020146c:	a8fff0ef          	jal	ra,ffffffffc0200efa <free_pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0201470:	00093023          	sd	zero,0(s2)
ffffffffc0201474:	000ab717          	auipc	a4,0xab
ffffffffc0201478:	04c70713          	addi	a4,a4,76 # ffffffffc02ac4c0 <va_pa_offset>
ffffffffc020147c:	c0000337          	lui	t1,0xc0000
ffffffffc0201480:	6e02                	ld	t3,0(sp)
ffffffffc0201482:	000abe97          	auipc	t4,0xab
ffffffffc0201486:	04ee8e93          	addi	t4,t4,78 # ffffffffc02ac4d0 <pages>
    } while (d1start != 0 && d1start < end);
ffffffffc020148a:	ec099be3          	bnez	s3,ffffffffc0201360 <exit_range+0x94>
}
ffffffffc020148e:	70e6                	ld	ra,120(sp)
ffffffffc0201490:	7446                	ld	s0,112(sp)
ffffffffc0201492:	74a6                	ld	s1,104(sp)
ffffffffc0201494:	7906                	ld	s2,96(sp)
ffffffffc0201496:	69e6                	ld	s3,88(sp)
ffffffffc0201498:	6a46                	ld	s4,80(sp)
ffffffffc020149a:	6aa6                	ld	s5,72(sp)
ffffffffc020149c:	6b06                	ld	s6,64(sp)
ffffffffc020149e:	7be2                	ld	s7,56(sp)
ffffffffc02014a0:	7c42                	ld	s8,48(sp)
ffffffffc02014a2:	7ca2                	ld	s9,40(sp)
ffffffffc02014a4:	7d02                	ld	s10,32(sp)
ffffffffc02014a6:	6de2                	ld	s11,24(sp)
ffffffffc02014a8:	6109                	addi	sp,sp,128
ffffffffc02014aa:	8082                	ret
            if (free_pd0)
ffffffffc02014ac:	ea0c8ae3          	beqz	s9,ffffffffc0201360 <exit_range+0x94>
ffffffffc02014b0:	b765                	j	ffffffffc0201458 <exit_range+0x18c>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02014b2:	00006697          	auipc	a3,0x6
ffffffffc02014b6:	11668693          	addi	a3,a3,278 # ffffffffc02075c8 <commands+0xe58>
ffffffffc02014ba:	00005617          	auipc	a2,0x5
ffffffffc02014be:	73660613          	addi	a2,a2,1846 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02014c2:	13f00593          	li	a1,319
ffffffffc02014c6:	00006517          	auipc	a0,0x6
ffffffffc02014ca:	b2a50513          	addi	a0,a0,-1238 # ffffffffc0206ff0 <commands+0x880>
ffffffffc02014ce:	d49fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc02014d2:	00006617          	auipc	a2,0x6
ffffffffc02014d6:	af660613          	addi	a2,a2,-1290 # ffffffffc0206fc8 <commands+0x858>
ffffffffc02014da:	06900593          	li	a1,105
ffffffffc02014de:	00006517          	auipc	a0,0x6
ffffffffc02014e2:	b4250513          	addi	a0,a0,-1214 # ffffffffc0207020 <commands+0x8b0>
ffffffffc02014e6:	d31fe0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02014ea:	00006617          	auipc	a2,0x6
ffffffffc02014ee:	b1660613          	addi	a2,a2,-1258 # ffffffffc0207000 <commands+0x890>
ffffffffc02014f2:	06200593          	li	a1,98
ffffffffc02014f6:	00006517          	auipc	a0,0x6
ffffffffc02014fa:	b2a50513          	addi	a0,a0,-1238 # ffffffffc0207020 <commands+0x8b0>
ffffffffc02014fe:	d19fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0201502:	00006697          	auipc	a3,0x6
ffffffffc0201506:	0f668693          	addi	a3,a3,246 # ffffffffc02075f8 <commands+0xe88>
ffffffffc020150a:	00005617          	auipc	a2,0x5
ffffffffc020150e:	6e660613          	addi	a2,a2,1766 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201512:	14000593          	li	a1,320
ffffffffc0201516:	00006517          	auipc	a0,0x6
ffffffffc020151a:	ada50513          	addi	a0,a0,-1318 # ffffffffc0206ff0 <commands+0x880>
ffffffffc020151e:	cf9fe0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0201522 <page_remove>:
{
ffffffffc0201522:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201524:	4601                	li	a2,0
{
ffffffffc0201526:	e426                	sd	s1,8(sp)
ffffffffc0201528:	ec06                	sd	ra,24(sp)
ffffffffc020152a:	e822                	sd	s0,16(sp)
ffffffffc020152c:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020152e:	a53ff0ef          	jal	ra,ffffffffc0200f80 <get_pte>
    if (ptep != NULL)
ffffffffc0201532:	c511                	beqz	a0,ffffffffc020153e <page_remove+0x1c>
    if (*ptep & PTE_V)
ffffffffc0201534:	611c                	ld	a5,0(a0)
ffffffffc0201536:	842a                	mv	s0,a0
ffffffffc0201538:	0017f713          	andi	a4,a5,1
ffffffffc020153c:	e711                	bnez	a4,ffffffffc0201548 <page_remove+0x26>
}
ffffffffc020153e:	60e2                	ld	ra,24(sp)
ffffffffc0201540:	6442                	ld	s0,16(sp)
ffffffffc0201542:	64a2                	ld	s1,8(sp)
ffffffffc0201544:	6105                	addi	sp,sp,32
ffffffffc0201546:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201548:	000ab717          	auipc	a4,0xab
ffffffffc020154c:	f2070713          	addi	a4,a4,-224 # ffffffffc02ac468 <npage>
ffffffffc0201550:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201552:	078a                	slli	a5,a5,0x2
ffffffffc0201554:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201556:	02e7fe63          	bleu	a4,a5,ffffffffc0201592 <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc020155a:	000ab717          	auipc	a4,0xab
ffffffffc020155e:	f7670713          	addi	a4,a4,-138 # ffffffffc02ac4d0 <pages>
ffffffffc0201562:	6308                	ld	a0,0(a4)
ffffffffc0201564:	fff80737          	lui	a4,0xfff80
ffffffffc0201568:	97ba                	add	a5,a5,a4
ffffffffc020156a:	079a                	slli	a5,a5,0x6
ffffffffc020156c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020156e:	411c                	lw	a5,0(a0)
ffffffffc0201570:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201574:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201576:	cb11                	beqz	a4,ffffffffc020158a <page_remove+0x68>
        *ptep = 0;                 //(5) clear second page table entry
ffffffffc0201578:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020157c:	12048073          	sfence.vma	s1
}
ffffffffc0201580:	60e2                	ld	ra,24(sp)
ffffffffc0201582:	6442                	ld	s0,16(sp)
ffffffffc0201584:	64a2                	ld	s1,8(sp)
ffffffffc0201586:	6105                	addi	sp,sp,32
ffffffffc0201588:	8082                	ret
            free_page(page);
ffffffffc020158a:	4585                	li	a1,1
ffffffffc020158c:	96fff0ef          	jal	ra,ffffffffc0200efa <free_pages>
ffffffffc0201590:	b7e5                	j	ffffffffc0201578 <page_remove+0x56>
ffffffffc0201592:	8c5ff0ef          	jal	ra,ffffffffc0200e56 <pa2page.part.4>

ffffffffc0201596 <page_insert>:
{
ffffffffc0201596:	7179                	addi	sp,sp,-48
ffffffffc0201598:	e44e                	sd	s3,8(sp)
ffffffffc020159a:	89b2                	mv	s3,a2
ffffffffc020159c:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020159e:	4605                	li	a2,1
{
ffffffffc02015a0:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02015a2:	85ce                	mv	a1,s3
{
ffffffffc02015a4:	ec26                	sd	s1,24(sp)
ffffffffc02015a6:	f406                	sd	ra,40(sp)
ffffffffc02015a8:	e84a                	sd	s2,16(sp)
ffffffffc02015aa:	e052                	sd	s4,0(sp)
ffffffffc02015ac:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02015ae:	9d3ff0ef          	jal	ra,ffffffffc0200f80 <get_pte>
    if (ptep == NULL)
ffffffffc02015b2:	cd49                	beqz	a0,ffffffffc020164c <page_insert+0xb6>
    page->ref += 1;
ffffffffc02015b4:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V)
ffffffffc02015b6:	611c                	ld	a5,0(a0)
ffffffffc02015b8:	892a                	mv	s2,a0
ffffffffc02015ba:	0016871b          	addiw	a4,a3,1
ffffffffc02015be:	c018                	sw	a4,0(s0)
ffffffffc02015c0:	0017f713          	andi	a4,a5,1
ffffffffc02015c4:	ef05                	bnez	a4,ffffffffc02015fc <page_insert+0x66>
ffffffffc02015c6:	000ab797          	auipc	a5,0xab
ffffffffc02015ca:	f0a78793          	addi	a5,a5,-246 # ffffffffc02ac4d0 <pages>
ffffffffc02015ce:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc02015d0:	8c19                	sub	s0,s0,a4
ffffffffc02015d2:	000806b7          	lui	a3,0x80
ffffffffc02015d6:	8419                	srai	s0,s0,0x6
ffffffffc02015d8:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02015da:	042a                	slli	s0,s0,0xa
ffffffffc02015dc:	8c45                	or	s0,s0,s1
ffffffffc02015de:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02015e2:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02015e6:	12098073          	sfence.vma	s3
    return 0;
ffffffffc02015ea:	4501                	li	a0,0
}
ffffffffc02015ec:	70a2                	ld	ra,40(sp)
ffffffffc02015ee:	7402                	ld	s0,32(sp)
ffffffffc02015f0:	64e2                	ld	s1,24(sp)
ffffffffc02015f2:	6942                	ld	s2,16(sp)
ffffffffc02015f4:	69a2                	ld	s3,8(sp)
ffffffffc02015f6:	6a02                	ld	s4,0(sp)
ffffffffc02015f8:	6145                	addi	sp,sp,48
ffffffffc02015fa:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02015fc:	000ab717          	auipc	a4,0xab
ffffffffc0201600:	e6c70713          	addi	a4,a4,-404 # ffffffffc02ac468 <npage>
ffffffffc0201604:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201606:	078a                	slli	a5,a5,0x2
ffffffffc0201608:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020160a:	04e7f363          	bleu	a4,a5,ffffffffc0201650 <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc020160e:	000aba17          	auipc	s4,0xab
ffffffffc0201612:	ec2a0a13          	addi	s4,s4,-318 # ffffffffc02ac4d0 <pages>
ffffffffc0201616:	000a3703          	ld	a4,0(s4)
ffffffffc020161a:	fff80537          	lui	a0,0xfff80
ffffffffc020161e:	953e                	add	a0,a0,a5
ffffffffc0201620:	051a                	slli	a0,a0,0x6
ffffffffc0201622:	953a                	add	a0,a0,a4
        if (p == page)
ffffffffc0201624:	00a40a63          	beq	s0,a0,ffffffffc0201638 <page_insert+0xa2>
    page->ref -= 1;
ffffffffc0201628:	411c                	lw	a5,0(a0)
ffffffffc020162a:	fff7869b          	addiw	a3,a5,-1
ffffffffc020162e:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc0201630:	c691                	beqz	a3,ffffffffc020163c <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201632:	12098073          	sfence.vma	s3
ffffffffc0201636:	bf69                	j	ffffffffc02015d0 <page_insert+0x3a>
ffffffffc0201638:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc020163a:	bf59                	j	ffffffffc02015d0 <page_insert+0x3a>
            free_page(page);
ffffffffc020163c:	4585                	li	a1,1
ffffffffc020163e:	8bdff0ef          	jal	ra,ffffffffc0200efa <free_pages>
ffffffffc0201642:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201646:	12098073          	sfence.vma	s3
ffffffffc020164a:	b759                	j	ffffffffc02015d0 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc020164c:	5571                	li	a0,-4
ffffffffc020164e:	bf79                	j	ffffffffc02015ec <page_insert+0x56>
ffffffffc0201650:	807ff0ef          	jal	ra,ffffffffc0200e56 <pa2page.part.4>

ffffffffc0201654 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201654:	00007797          	auipc	a5,0x7
ffffffffc0201658:	cb478793          	addi	a5,a5,-844 # ffffffffc0208308 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020165c:	638c                	ld	a1,0(a5)
{
ffffffffc020165e:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201660:	00006517          	auipc	a0,0x6
ffffffffc0201664:	9e850513          	addi	a0,a0,-1560 # ffffffffc0207048 <commands+0x8d8>
{
ffffffffc0201668:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020166a:	000ab717          	auipc	a4,0xab
ffffffffc020166e:	e4f73723          	sd	a5,-434(a4) # ffffffffc02ac4b8 <pmm_manager>
{
ffffffffc0201672:	e0a2                	sd	s0,64(sp)
ffffffffc0201674:	fc26                	sd	s1,56(sp)
ffffffffc0201676:	f84a                	sd	s2,48(sp)
ffffffffc0201678:	f44e                	sd	s3,40(sp)
ffffffffc020167a:	f052                	sd	s4,32(sp)
ffffffffc020167c:	ec56                	sd	s5,24(sp)
ffffffffc020167e:	e85a                	sd	s6,16(sp)
ffffffffc0201680:	e45e                	sd	s7,8(sp)
ffffffffc0201682:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201684:	000ab417          	auipc	s0,0xab
ffffffffc0201688:	e3440413          	addi	s0,s0,-460 # ffffffffc02ac4b8 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020168c:	a45fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pmm_manager->init();
ffffffffc0201690:	601c                	ld	a5,0(s0)
ffffffffc0201692:	000ab497          	auipc	s1,0xab
ffffffffc0201696:	dd648493          	addi	s1,s1,-554 # ffffffffc02ac468 <npage>
ffffffffc020169a:	000ab917          	auipc	s2,0xab
ffffffffc020169e:	e3690913          	addi	s2,s2,-458 # ffffffffc02ac4d0 <pages>
ffffffffc02016a2:	679c                	ld	a5,8(a5)
ffffffffc02016a4:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02016a6:	57f5                	li	a5,-3
ffffffffc02016a8:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02016aa:	00006517          	auipc	a0,0x6
ffffffffc02016ae:	9b650513          	addi	a0,a0,-1610 # ffffffffc0207060 <commands+0x8f0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02016b2:	000ab717          	auipc	a4,0xab
ffffffffc02016b6:	e0f73723          	sd	a5,-498(a4) # ffffffffc02ac4c0 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc02016ba:	a17fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02016be:	46c5                	li	a3,17
ffffffffc02016c0:	06ee                	slli	a3,a3,0x1b
ffffffffc02016c2:	40100613          	li	a2,1025
ffffffffc02016c6:	16fd                	addi	a3,a3,-1
ffffffffc02016c8:	0656                	slli	a2,a2,0x15
ffffffffc02016ca:	07e005b7          	lui	a1,0x7e00
ffffffffc02016ce:	00006517          	auipc	a0,0x6
ffffffffc02016d2:	9aa50513          	addi	a0,a0,-1622 # ffffffffc0207078 <commands+0x908>
ffffffffc02016d6:	9fbfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02016da:	777d                	lui	a4,0xfffff
ffffffffc02016dc:	000ac797          	auipc	a5,0xac
ffffffffc02016e0:	f0378793          	addi	a5,a5,-253 # ffffffffc02ad5df <end+0xfff>
ffffffffc02016e4:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02016e6:	00088737          	lui	a4,0x88
ffffffffc02016ea:	000ab697          	auipc	a3,0xab
ffffffffc02016ee:	d6e6bf23          	sd	a4,-642(a3) # ffffffffc02ac468 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02016f2:	000ab717          	auipc	a4,0xab
ffffffffc02016f6:	dcf73f23          	sd	a5,-546(a4) # ffffffffc02ac4d0 <pages>
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02016fa:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02016fc:	4685                	li	a3,1
ffffffffc02016fe:	fff80837          	lui	a6,0xfff80
ffffffffc0201702:	a019                	j	ffffffffc0201708 <pmm_init+0xb4>
ffffffffc0201704:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0201708:	00671613          	slli	a2,a4,0x6
ffffffffc020170c:	97b2                	add	a5,a5,a2
ffffffffc020170e:	07a1                	addi	a5,a5,8
ffffffffc0201710:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0201714:	6090                	ld	a2,0(s1)
ffffffffc0201716:	0705                	addi	a4,a4,1
ffffffffc0201718:	010607b3          	add	a5,a2,a6
ffffffffc020171c:	fef764e3          	bltu	a4,a5,ffffffffc0201704 <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201720:	00093503          	ld	a0,0(s2)
ffffffffc0201724:	fe0007b7          	lui	a5,0xfe000
ffffffffc0201728:	00661693          	slli	a3,a2,0x6
ffffffffc020172c:	97aa                	add	a5,a5,a0
ffffffffc020172e:	96be                	add	a3,a3,a5
ffffffffc0201730:	c02007b7          	lui	a5,0xc0200
ffffffffc0201734:	7af6ed63          	bltu	a3,a5,ffffffffc0201eee <pmm_init+0x89a>
ffffffffc0201738:	000ab997          	auipc	s3,0xab
ffffffffc020173c:	d8898993          	addi	s3,s3,-632 # ffffffffc02ac4c0 <va_pa_offset>
ffffffffc0201740:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end)
ffffffffc0201744:	47c5                	li	a5,17
ffffffffc0201746:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201748:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc020174a:	02f6f763          	bleu	a5,a3,ffffffffc0201778 <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020174e:	6585                	lui	a1,0x1
ffffffffc0201750:	15fd                	addi	a1,a1,-1
ffffffffc0201752:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc0201754:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201758:	48c77a63          	bleu	a2,a4,ffffffffc0201bec <pmm_init+0x598>
    pmm_manager->init_memmap(base, n);
ffffffffc020175c:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020175e:	75fd                	lui	a1,0xfffff
ffffffffc0201760:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc0201762:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc0201764:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201766:	40d786b3          	sub	a3,a5,a3
ffffffffc020176a:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc020176c:	00c6d593          	srli	a1,a3,0xc
ffffffffc0201770:	953a                	add	a0,a0,a4
ffffffffc0201772:	9602                	jalr	a2
ffffffffc0201774:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0201778:	00006517          	auipc	a0,0x6
ffffffffc020177c:	95050513          	addi	a0,a0,-1712 # ffffffffc02070c8 <commands+0x958>
ffffffffc0201780:	951fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc0201784:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t *)boot_page_table_sv39;
ffffffffc0201786:	000ab417          	auipc	s0,0xab
ffffffffc020178a:	cda40413          	addi	s0,s0,-806 # ffffffffc02ac460 <boot_pgdir>
    pmm_manager->check();
ffffffffc020178e:	7b9c                	ld	a5,48(a5)
ffffffffc0201790:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201792:	00006517          	auipc	a0,0x6
ffffffffc0201796:	94e50513          	addi	a0,a0,-1714 # ffffffffc02070e0 <commands+0x970>
ffffffffc020179a:	937fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    boot_pgdir = (pte_t *)boot_page_table_sv39;
ffffffffc020179e:	0000a697          	auipc	a3,0xa
ffffffffc02017a2:	86268693          	addi	a3,a3,-1950 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc02017a6:	000ab797          	auipc	a5,0xab
ffffffffc02017aa:	cad7bd23          	sd	a3,-838(a5) # ffffffffc02ac460 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02017ae:	c02007b7          	lui	a5,0xc0200
ffffffffc02017b2:	10f6eae3          	bltu	a3,a5,ffffffffc02020c6 <pmm_init+0xa72>
ffffffffc02017b6:	0009b783          	ld	a5,0(s3)
ffffffffc02017ba:	8e9d                	sub	a3,a3,a5
ffffffffc02017bc:	000ab797          	auipc	a5,0xab
ffffffffc02017c0:	d0d7b623          	sd	a3,-756(a5) # ffffffffc02ac4c8 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();
ffffffffc02017c4:	f7cff0ef          	jal	ra,ffffffffc0200f40 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02017c8:	6098                	ld	a4,0(s1)
ffffffffc02017ca:	c80007b7          	lui	a5,0xc8000
ffffffffc02017ce:	83b1                	srli	a5,a5,0xc
    nr_free_store = nr_free_pages();
ffffffffc02017d0:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02017d2:	0ce7eae3          	bltu	a5,a4,ffffffffc02020a6 <pmm_init+0xa52>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02017d6:	6008                	ld	a0,0(s0)
ffffffffc02017d8:	44050463          	beqz	a0,ffffffffc0201c20 <pmm_init+0x5cc>
ffffffffc02017dc:	6785                	lui	a5,0x1
ffffffffc02017de:	17fd                	addi	a5,a5,-1
ffffffffc02017e0:	8fe9                	and	a5,a5,a0
ffffffffc02017e2:	2781                	sext.w	a5,a5
ffffffffc02017e4:	42079e63          	bnez	a5,ffffffffc0201c20 <pmm_init+0x5cc>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02017e8:	4601                	li	a2,0
ffffffffc02017ea:	4581                	li	a1,0
ffffffffc02017ec:	967ff0ef          	jal	ra,ffffffffc0201152 <get_page>
ffffffffc02017f0:	78051b63          	bnez	a0,ffffffffc0201f86 <pmm_init+0x932>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02017f4:	4505                	li	a0,1
ffffffffc02017f6:	e7cff0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc02017fa:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02017fc:	6008                	ld	a0,0(s0)
ffffffffc02017fe:	4681                	li	a3,0
ffffffffc0201800:	4601                	li	a2,0
ffffffffc0201802:	85d6                	mv	a1,s5
ffffffffc0201804:	d93ff0ef          	jal	ra,ffffffffc0201596 <page_insert>
ffffffffc0201808:	7a051f63          	bnez	a0,ffffffffc0201fc6 <pmm_init+0x972>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020180c:	6008                	ld	a0,0(s0)
ffffffffc020180e:	4601                	li	a2,0
ffffffffc0201810:	4581                	li	a1,0
ffffffffc0201812:	f6eff0ef          	jal	ra,ffffffffc0200f80 <get_pte>
ffffffffc0201816:	78050863          	beqz	a0,ffffffffc0201fa6 <pmm_init+0x952>
    assert(pte2page(*ptep) == p1);
ffffffffc020181a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020181c:	0017f713          	andi	a4,a5,1
ffffffffc0201820:	3e070463          	beqz	a4,ffffffffc0201c08 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc0201824:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201826:	078a                	slli	a5,a5,0x2
ffffffffc0201828:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020182a:	3ce7f163          	bleu	a4,a5,ffffffffc0201bec <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020182e:	00093683          	ld	a3,0(s2)
ffffffffc0201832:	fff80637          	lui	a2,0xfff80
ffffffffc0201836:	97b2                	add	a5,a5,a2
ffffffffc0201838:	079a                	slli	a5,a5,0x6
ffffffffc020183a:	97b6                	add	a5,a5,a3
ffffffffc020183c:	72fa9563          	bne	s5,a5,ffffffffc0201f66 <pmm_init+0x912>
    assert(page_ref(p1) == 1);
ffffffffc0201840:	000aab83          	lw	s7,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8578>
ffffffffc0201844:	4785                	li	a5,1
ffffffffc0201846:	70fb9063          	bne	s7,a5,ffffffffc0201f46 <pmm_init+0x8f2>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020184a:	6008                	ld	a0,0(s0)
ffffffffc020184c:	76fd                	lui	a3,0xfffff
ffffffffc020184e:	611c                	ld	a5,0(a0)
ffffffffc0201850:	078a                	slli	a5,a5,0x2
ffffffffc0201852:	8ff5                	and	a5,a5,a3
ffffffffc0201854:	00c7d613          	srli	a2,a5,0xc
ffffffffc0201858:	66e67e63          	bleu	a4,a2,ffffffffc0201ed4 <pmm_init+0x880>
ffffffffc020185c:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201860:	97e2                	add	a5,a5,s8
ffffffffc0201862:	0007bb03          	ld	s6,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8578>
ffffffffc0201866:	0b0a                	slli	s6,s6,0x2
ffffffffc0201868:	00db7b33          	and	s6,s6,a3
ffffffffc020186c:	00cb5793          	srli	a5,s6,0xc
ffffffffc0201870:	56e7f863          	bleu	a4,a5,ffffffffc0201de0 <pmm_init+0x78c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201874:	4601                	li	a2,0
ffffffffc0201876:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201878:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020187a:	f06ff0ef          	jal	ra,ffffffffc0200f80 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020187e:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201880:	55651063          	bne	a0,s6,ffffffffc0201dc0 <pmm_init+0x76c>

    p2 = alloc_page();
ffffffffc0201884:	4505                	li	a0,1
ffffffffc0201886:	decff0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc020188a:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020188c:	6008                	ld	a0,0(s0)
ffffffffc020188e:	46d1                	li	a3,20
ffffffffc0201890:	6605                	lui	a2,0x1
ffffffffc0201892:	85da                	mv	a1,s6
ffffffffc0201894:	d03ff0ef          	jal	ra,ffffffffc0201596 <page_insert>
ffffffffc0201898:	50051463          	bnez	a0,ffffffffc0201da0 <pmm_init+0x74c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020189c:	6008                	ld	a0,0(s0)
ffffffffc020189e:	4601                	li	a2,0
ffffffffc02018a0:	6585                	lui	a1,0x1
ffffffffc02018a2:	edeff0ef          	jal	ra,ffffffffc0200f80 <get_pte>
ffffffffc02018a6:	4c050d63          	beqz	a0,ffffffffc0201d80 <pmm_init+0x72c>
    assert(*ptep & PTE_U);
ffffffffc02018aa:	611c                	ld	a5,0(a0)
ffffffffc02018ac:	0107f713          	andi	a4,a5,16
ffffffffc02018b0:	4a070863          	beqz	a4,ffffffffc0201d60 <pmm_init+0x70c>
    assert(*ptep & PTE_W);
ffffffffc02018b4:	8b91                	andi	a5,a5,4
ffffffffc02018b6:	48078563          	beqz	a5,ffffffffc0201d40 <pmm_init+0x6ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02018ba:	6008                	ld	a0,0(s0)
ffffffffc02018bc:	611c                	ld	a5,0(a0)
ffffffffc02018be:	8bc1                	andi	a5,a5,16
ffffffffc02018c0:	46078063          	beqz	a5,ffffffffc0201d20 <pmm_init+0x6cc>
    assert(page_ref(p2) == 1);
ffffffffc02018c4:	000b2783          	lw	a5,0(s6) # 200000 <_binary_obj___user_exit_out_size+0x1f5580>
ffffffffc02018c8:	43779c63          	bne	a5,s7,ffffffffc0201d00 <pmm_init+0x6ac>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02018cc:	4681                	li	a3,0
ffffffffc02018ce:	6605                	lui	a2,0x1
ffffffffc02018d0:	85d6                	mv	a1,s5
ffffffffc02018d2:	cc5ff0ef          	jal	ra,ffffffffc0201596 <page_insert>
ffffffffc02018d6:	40051563          	bnez	a0,ffffffffc0201ce0 <pmm_init+0x68c>
    assert(page_ref(p1) == 2);
ffffffffc02018da:	000aa703          	lw	a4,0(s5)
ffffffffc02018de:	4789                	li	a5,2
ffffffffc02018e0:	3ef71063          	bne	a4,a5,ffffffffc0201cc0 <pmm_init+0x66c>
    assert(page_ref(p2) == 0);
ffffffffc02018e4:	000b2783          	lw	a5,0(s6)
ffffffffc02018e8:	3a079c63          	bnez	a5,ffffffffc0201ca0 <pmm_init+0x64c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02018ec:	6008                	ld	a0,0(s0)
ffffffffc02018ee:	4601                	li	a2,0
ffffffffc02018f0:	6585                	lui	a1,0x1
ffffffffc02018f2:	e8eff0ef          	jal	ra,ffffffffc0200f80 <get_pte>
ffffffffc02018f6:	38050563          	beqz	a0,ffffffffc0201c80 <pmm_init+0x62c>
    assert(pte2page(*ptep) == p1);
ffffffffc02018fa:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02018fc:	00177793          	andi	a5,a4,1
ffffffffc0201900:	30078463          	beqz	a5,ffffffffc0201c08 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc0201904:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201906:	00271793          	slli	a5,a4,0x2
ffffffffc020190a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020190c:	2ed7f063          	bleu	a3,a5,ffffffffc0201bec <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0201910:	00093683          	ld	a3,0(s2)
ffffffffc0201914:	fff80637          	lui	a2,0xfff80
ffffffffc0201918:	97b2                	add	a5,a5,a2
ffffffffc020191a:	079a                	slli	a5,a5,0x6
ffffffffc020191c:	97b6                	add	a5,a5,a3
ffffffffc020191e:	32fa9163          	bne	s5,a5,ffffffffc0201c40 <pmm_init+0x5ec>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201922:	8b41                	andi	a4,a4,16
ffffffffc0201924:	70071163          	bnez	a4,ffffffffc0202026 <pmm_init+0x9d2>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201928:	6008                	ld	a0,0(s0)
ffffffffc020192a:	4581                	li	a1,0
ffffffffc020192c:	bf7ff0ef          	jal	ra,ffffffffc0201522 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201930:	000aa703          	lw	a4,0(s5)
ffffffffc0201934:	4785                	li	a5,1
ffffffffc0201936:	6cf71863          	bne	a4,a5,ffffffffc0202006 <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc020193a:	000b2783          	lw	a5,0(s6)
ffffffffc020193e:	6a079463          	bnez	a5,ffffffffc0201fe6 <pmm_init+0x992>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201942:	6008                	ld	a0,0(s0)
ffffffffc0201944:	6585                	lui	a1,0x1
ffffffffc0201946:	bddff0ef          	jal	ra,ffffffffc0201522 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc020194a:	000aa783          	lw	a5,0(s5)
ffffffffc020194e:	50079363          	bnez	a5,ffffffffc0201e54 <pmm_init+0x800>
    assert(page_ref(p2) == 0);
ffffffffc0201952:	000b2783          	lw	a5,0(s6)
ffffffffc0201956:	4c079f63          	bnez	a5,ffffffffc0201e34 <pmm_init+0x7e0>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020195a:	00043a83          	ld	s5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020195e:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201960:	000ab783          	ld	a5,0(s5)
ffffffffc0201964:	078a                	slli	a5,a5,0x2
ffffffffc0201966:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201968:	28c7f263          	bleu	a2,a5,ffffffffc0201bec <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020196c:	fff80737          	lui	a4,0xfff80
ffffffffc0201970:	00093503          	ld	a0,0(s2)
ffffffffc0201974:	97ba                	add	a5,a5,a4
ffffffffc0201976:	079a                	slli	a5,a5,0x6
ffffffffc0201978:	00f50733          	add	a4,a0,a5
ffffffffc020197c:	4314                	lw	a3,0(a4)
ffffffffc020197e:	4705                	li	a4,1
ffffffffc0201980:	48e69a63          	bne	a3,a4,ffffffffc0201e14 <pmm_init+0x7c0>
    return page - pages + nbase;
ffffffffc0201984:	8799                	srai	a5,a5,0x6
ffffffffc0201986:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc020198a:	577d                	li	a4,-1
    return page - pages + nbase;
ffffffffc020198c:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc020198e:	8331                	srli	a4,a4,0xc
ffffffffc0201990:	8f7d                	and	a4,a4,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0201992:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0201994:	46c77363          	bleu	a2,a4,ffffffffc0201dfa <pmm_init+0x7a6>

    pde_t *pd1 = boot_pgdir, *pd0 = page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201998:	0009b683          	ld	a3,0(s3)
ffffffffc020199c:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc020199e:	639c                	ld	a5,0(a5)
ffffffffc02019a0:	078a                	slli	a5,a5,0x2
ffffffffc02019a2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02019a4:	24c7f463          	bleu	a2,a5,ffffffffc0201bec <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02019a8:	416787b3          	sub	a5,a5,s6
ffffffffc02019ac:	079a                	slli	a5,a5,0x6
ffffffffc02019ae:	953e                	add	a0,a0,a5
ffffffffc02019b0:	4585                	li	a1,1
ffffffffc02019b2:	d48ff0ef          	jal	ra,ffffffffc0200efa <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02019b6:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc02019ba:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02019bc:	078a                	slli	a5,a5,0x2
ffffffffc02019be:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02019c0:	22e7f663          	bleu	a4,a5,ffffffffc0201bec <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02019c4:	00093503          	ld	a0,0(s2)
ffffffffc02019c8:	416787b3          	sub	a5,a5,s6
ffffffffc02019cc:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02019ce:	953e                	add	a0,a0,a5
ffffffffc02019d0:	4585                	li	a1,1
ffffffffc02019d2:	d28ff0ef          	jal	ra,ffffffffc0200efa <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02019d6:	601c                	ld	a5,0(s0)
ffffffffc02019d8:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc02019dc:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc02019e0:	d60ff0ef          	jal	ra,ffffffffc0200f40 <nr_free_pages>
ffffffffc02019e4:	68aa1163          	bne	s4,a0,ffffffffc0202066 <pmm_init+0xa12>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02019e8:	00006517          	auipc	a0,0x6
ffffffffc02019ec:	a1050513          	addi	a0,a0,-1520 # ffffffffc02073f8 <commands+0xc88>
ffffffffc02019f0:	ee0fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
{
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();
ffffffffc02019f4:	d4cff0ef          	jal	ra,ffffffffc0200f40 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc02019f8:	6098                	ld	a4,0(s1)
ffffffffc02019fa:	c02007b7          	lui	a5,0xc0200
    nr_free_store = nr_free_pages();
ffffffffc02019fe:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0201a00:	00c71693          	slli	a3,a4,0xc
ffffffffc0201a04:	18d7f563          	bleu	a3,a5,ffffffffc0201b8e <pmm_init+0x53a>
    {
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201a08:	83b1                	srli	a5,a5,0xc
ffffffffc0201a0a:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0201a0c:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201a10:	1ae7f163          	bleu	a4,a5,ffffffffc0201bb2 <pmm_init+0x55e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201a14:	7bfd                	lui	s7,0xfffff
ffffffffc0201a16:	6b05                	lui	s6,0x1
ffffffffc0201a18:	a029                	j	ffffffffc0201a22 <pmm_init+0x3ce>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201a1a:	00cad713          	srli	a4,s5,0xc
ffffffffc0201a1e:	18f77a63          	bleu	a5,a4,ffffffffc0201bb2 <pmm_init+0x55e>
ffffffffc0201a22:	0009b583          	ld	a1,0(s3)
ffffffffc0201a26:	4601                	li	a2,0
ffffffffc0201a28:	95d6                	add	a1,a1,s5
ffffffffc0201a2a:	d56ff0ef          	jal	ra,ffffffffc0200f80 <get_pte>
ffffffffc0201a2e:	16050263          	beqz	a0,ffffffffc0201b92 <pmm_init+0x53e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201a32:	611c                	ld	a5,0(a0)
ffffffffc0201a34:	078a                	slli	a5,a5,0x2
ffffffffc0201a36:	0177f7b3          	and	a5,a5,s7
ffffffffc0201a3a:	19579963          	bne	a5,s5,ffffffffc0201bcc <pmm_init+0x578>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0201a3e:	609c                	ld	a5,0(s1)
ffffffffc0201a40:	9ada                	add	s5,s5,s6
ffffffffc0201a42:	6008                	ld	a0,0(s0)
ffffffffc0201a44:	00c79713          	slli	a4,a5,0xc
ffffffffc0201a48:	fceae9e3          	bltu	s5,a4,ffffffffc0201a1a <pmm_init+0x3c6>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc0201a4c:	611c                	ld	a5,0(a0)
ffffffffc0201a4e:	62079c63          	bnez	a5,ffffffffc0202086 <pmm_init+0xa32>

    struct Page *p;
    p = alloc_page();
ffffffffc0201a52:	4505                	li	a0,1
ffffffffc0201a54:	c1eff0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc0201a58:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201a5a:	6008                	ld	a0,0(s0)
ffffffffc0201a5c:	4699                	li	a3,6
ffffffffc0201a5e:	10000613          	li	a2,256
ffffffffc0201a62:	85d6                	mv	a1,s5
ffffffffc0201a64:	b33ff0ef          	jal	ra,ffffffffc0201596 <page_insert>
ffffffffc0201a68:	1e051c63          	bnez	a0,ffffffffc0201c60 <pmm_init+0x60c>
    assert(page_ref(p) == 1);
ffffffffc0201a6c:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0201a70:	4785                	li	a5,1
ffffffffc0201a72:	44f71163          	bne	a4,a5,ffffffffc0201eb4 <pmm_init+0x860>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201a76:	6008                	ld	a0,0(s0)
ffffffffc0201a78:	6b05                	lui	s6,0x1
ffffffffc0201a7a:	4699                	li	a3,6
ffffffffc0201a7c:	100b0613          	addi	a2,s6,256 # 1100 <_binary_obj___user_faultread_out_size-0x8478>
ffffffffc0201a80:	85d6                	mv	a1,s5
ffffffffc0201a82:	b15ff0ef          	jal	ra,ffffffffc0201596 <page_insert>
ffffffffc0201a86:	40051763          	bnez	a0,ffffffffc0201e94 <pmm_init+0x840>
    assert(page_ref(p) == 2);
ffffffffc0201a8a:	000aa703          	lw	a4,0(s5)
ffffffffc0201a8e:	4789                	li	a5,2
ffffffffc0201a90:	3ef71263          	bne	a4,a5,ffffffffc0201e74 <pmm_init+0x820>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201a94:	00006597          	auipc	a1,0x6
ffffffffc0201a98:	a9c58593          	addi	a1,a1,-1380 # ffffffffc0207530 <commands+0xdc0>
ffffffffc0201a9c:	10000513          	li	a0,256
ffffffffc0201aa0:	6c8040ef          	jal	ra,ffffffffc0206168 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201aa4:	100b0593          	addi	a1,s6,256
ffffffffc0201aa8:	10000513          	li	a0,256
ffffffffc0201aac:	6ce040ef          	jal	ra,ffffffffc020617a <strcmp>
ffffffffc0201ab0:	44051b63          	bnez	a0,ffffffffc0201f06 <pmm_init+0x8b2>
    return page - pages + nbase;
ffffffffc0201ab4:	00093683          	ld	a3,0(s2)
ffffffffc0201ab8:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0201abc:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0201abe:	40da86b3          	sub	a3,s5,a3
ffffffffc0201ac2:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201ac4:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0201ac6:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0201ac8:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0201acc:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ad0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201ad2:	10f77f63          	bleu	a5,a4,ffffffffc0201bf0 <pmm_init+0x59c>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201ad6:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201ada:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201ade:	96be                	add	a3,a3,a5
ffffffffc0201ae0:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fd52b20>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201ae4:	640040ef          	jal	ra,ffffffffc0206124 <strlen>
ffffffffc0201ae8:	54051f63          	bnez	a0,ffffffffc0202046 <pmm_init+0x9f2>

    pde_t *pd1 = boot_pgdir, *pd0 = page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201aec:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201af0:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201af2:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fd52a20>
ffffffffc0201af6:	068a                	slli	a3,a3,0x2
ffffffffc0201af8:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201afa:	0ef6f963          	bleu	a5,a3,ffffffffc0201bec <pmm_init+0x598>
    return KADDR(page2pa(page));
ffffffffc0201afe:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0201b02:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201b04:	0efb7663          	bleu	a5,s6,ffffffffc0201bf0 <pmm_init+0x59c>
ffffffffc0201b08:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0201b0c:	4585                	li	a1,1
ffffffffc0201b0e:	8556                	mv	a0,s5
ffffffffc0201b10:	99b6                	add	s3,s3,a3
ffffffffc0201b12:	be8ff0ef          	jal	ra,ffffffffc0200efa <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201b16:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0201b1a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201b1c:	078a                	slli	a5,a5,0x2
ffffffffc0201b1e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201b20:	0ce7f663          	bleu	a4,a5,ffffffffc0201bec <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b24:	00093503          	ld	a0,0(s2)
ffffffffc0201b28:	fff809b7          	lui	s3,0xfff80
ffffffffc0201b2c:	97ce                	add	a5,a5,s3
ffffffffc0201b2e:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0201b30:	953e                	add	a0,a0,a5
ffffffffc0201b32:	4585                	li	a1,1
ffffffffc0201b34:	bc6ff0ef          	jal	ra,ffffffffc0200efa <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201b38:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0201b3c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201b3e:	078a                	slli	a5,a5,0x2
ffffffffc0201b40:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201b42:	0ae7f563          	bleu	a4,a5,ffffffffc0201bec <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b46:	00093503          	ld	a0,0(s2)
ffffffffc0201b4a:	97ce                	add	a5,a5,s3
ffffffffc0201b4c:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0201b4e:	953e                	add	a0,a0,a5
ffffffffc0201b50:	4585                	li	a1,1
ffffffffc0201b52:	ba8ff0ef          	jal	ra,ffffffffc0200efa <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0201b56:	601c                	ld	a5,0(s0)
ffffffffc0201b58:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0201b5c:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0201b60:	be0ff0ef          	jal	ra,ffffffffc0200f40 <nr_free_pages>
ffffffffc0201b64:	3caa1163          	bne	s4,a0,ffffffffc0201f26 <pmm_init+0x8d2>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0201b68:	00006517          	auipc	a0,0x6
ffffffffc0201b6c:	a4050513          	addi	a0,a0,-1472 # ffffffffc02075a8 <commands+0xe38>
ffffffffc0201b70:	d60fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0201b74:	6406                	ld	s0,64(sp)
ffffffffc0201b76:	60a6                	ld	ra,72(sp)
ffffffffc0201b78:	74e2                	ld	s1,56(sp)
ffffffffc0201b7a:	7942                	ld	s2,48(sp)
ffffffffc0201b7c:	79a2                	ld	s3,40(sp)
ffffffffc0201b7e:	7a02                	ld	s4,32(sp)
ffffffffc0201b80:	6ae2                	ld	s5,24(sp)
ffffffffc0201b82:	6b42                	ld	s6,16(sp)
ffffffffc0201b84:	6ba2                	ld	s7,8(sp)
ffffffffc0201b86:	6c02                	ld	s8,0(sp)
ffffffffc0201b88:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0201b8a:	0fd0106f          	j	ffffffffc0203486 <kmalloc_init>
ffffffffc0201b8e:	6008                	ld	a0,0(s0)
ffffffffc0201b90:	bd75                	j	ffffffffc0201a4c <pmm_init+0x3f8>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201b92:	00006697          	auipc	a3,0x6
ffffffffc0201b96:	88668693          	addi	a3,a3,-1914 # ffffffffc0207418 <commands+0xca8>
ffffffffc0201b9a:	00005617          	auipc	a2,0x5
ffffffffc0201b9e:	05660613          	addi	a2,a2,86 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201ba2:	26800593          	li	a1,616
ffffffffc0201ba6:	00005517          	auipc	a0,0x5
ffffffffc0201baa:	44a50513          	addi	a0,a0,1098 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201bae:	e68fe0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0201bb2:	86d6                	mv	a3,s5
ffffffffc0201bb4:	00005617          	auipc	a2,0x5
ffffffffc0201bb8:	41460613          	addi	a2,a2,1044 # ffffffffc0206fc8 <commands+0x858>
ffffffffc0201bbc:	26800593          	li	a1,616
ffffffffc0201bc0:	00005517          	auipc	a0,0x5
ffffffffc0201bc4:	43050513          	addi	a0,a0,1072 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201bc8:	e4efe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201bcc:	00006697          	auipc	a3,0x6
ffffffffc0201bd0:	88c68693          	addi	a3,a3,-1908 # ffffffffc0207458 <commands+0xce8>
ffffffffc0201bd4:	00005617          	auipc	a2,0x5
ffffffffc0201bd8:	01c60613          	addi	a2,a2,28 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201bdc:	26900593          	li	a1,617
ffffffffc0201be0:	00005517          	auipc	a0,0x5
ffffffffc0201be4:	41050513          	addi	a0,a0,1040 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201be8:	e2efe0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0201bec:	a6aff0ef          	jal	ra,ffffffffc0200e56 <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0201bf0:	00005617          	auipc	a2,0x5
ffffffffc0201bf4:	3d860613          	addi	a2,a2,984 # ffffffffc0206fc8 <commands+0x858>
ffffffffc0201bf8:	06900593          	li	a1,105
ffffffffc0201bfc:	00005517          	auipc	a0,0x5
ffffffffc0201c00:	42450513          	addi	a0,a0,1060 # ffffffffc0207020 <commands+0x8b0>
ffffffffc0201c04:	e12fe0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0201c08:	00005617          	auipc	a2,0x5
ffffffffc0201c0c:	5d860613          	addi	a2,a2,1496 # ffffffffc02071e0 <commands+0xa70>
ffffffffc0201c10:	07400593          	li	a1,116
ffffffffc0201c14:	00005517          	auipc	a0,0x5
ffffffffc0201c18:	40c50513          	addi	a0,a0,1036 # ffffffffc0207020 <commands+0x8b0>
ffffffffc0201c1c:	dfafe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201c20:	00005697          	auipc	a3,0x5
ffffffffc0201c24:	50068693          	addi	a3,a3,1280 # ffffffffc0207120 <commands+0x9b0>
ffffffffc0201c28:	00005617          	auipc	a2,0x5
ffffffffc0201c2c:	fc860613          	addi	a2,a2,-56 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201c30:	22a00593          	li	a1,554
ffffffffc0201c34:	00005517          	auipc	a0,0x5
ffffffffc0201c38:	3bc50513          	addi	a0,a0,956 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201c3c:	ddafe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0201c40:	00005697          	auipc	a3,0x5
ffffffffc0201c44:	5c868693          	addi	a3,a3,1480 # ffffffffc0207208 <commands+0xa98>
ffffffffc0201c48:	00005617          	auipc	a2,0x5
ffffffffc0201c4c:	fa860613          	addi	a2,a2,-88 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201c50:	24600593          	li	a1,582
ffffffffc0201c54:	00005517          	auipc	a0,0x5
ffffffffc0201c58:	39c50513          	addi	a0,a0,924 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201c5c:	dbafe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201c60:	00006697          	auipc	a3,0x6
ffffffffc0201c64:	82868693          	addi	a3,a3,-2008 # ffffffffc0207488 <commands+0xd18>
ffffffffc0201c68:	00005617          	auipc	a2,0x5
ffffffffc0201c6c:	f8860613          	addi	a2,a2,-120 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201c70:	27000593          	li	a1,624
ffffffffc0201c74:	00005517          	auipc	a0,0x5
ffffffffc0201c78:	37c50513          	addi	a0,a0,892 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201c7c:	d9afe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201c80:	00005697          	auipc	a3,0x5
ffffffffc0201c84:	61868693          	addi	a3,a3,1560 # ffffffffc0207298 <commands+0xb28>
ffffffffc0201c88:	00005617          	auipc	a2,0x5
ffffffffc0201c8c:	f6860613          	addi	a2,a2,-152 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201c90:	24500593          	li	a1,581
ffffffffc0201c94:	00005517          	auipc	a0,0x5
ffffffffc0201c98:	35c50513          	addi	a0,a0,860 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201c9c:	d7afe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201ca0:	00005697          	auipc	a3,0x5
ffffffffc0201ca4:	6c068693          	addi	a3,a3,1728 # ffffffffc0207360 <commands+0xbf0>
ffffffffc0201ca8:	00005617          	auipc	a2,0x5
ffffffffc0201cac:	f4860613          	addi	a2,a2,-184 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201cb0:	24400593          	li	a1,580
ffffffffc0201cb4:	00005517          	auipc	a0,0x5
ffffffffc0201cb8:	33c50513          	addi	a0,a0,828 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201cbc:	d5afe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0201cc0:	00005697          	auipc	a3,0x5
ffffffffc0201cc4:	68868693          	addi	a3,a3,1672 # ffffffffc0207348 <commands+0xbd8>
ffffffffc0201cc8:	00005617          	auipc	a2,0x5
ffffffffc0201ccc:	f2860613          	addi	a2,a2,-216 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201cd0:	24300593          	li	a1,579
ffffffffc0201cd4:	00005517          	auipc	a0,0x5
ffffffffc0201cd8:	31c50513          	addi	a0,a0,796 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201cdc:	d3afe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201ce0:	00005697          	auipc	a3,0x5
ffffffffc0201ce4:	63868693          	addi	a3,a3,1592 # ffffffffc0207318 <commands+0xba8>
ffffffffc0201ce8:	00005617          	auipc	a2,0x5
ffffffffc0201cec:	f0860613          	addi	a2,a2,-248 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201cf0:	24200593          	li	a1,578
ffffffffc0201cf4:	00005517          	auipc	a0,0x5
ffffffffc0201cf8:	2fc50513          	addi	a0,a0,764 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201cfc:	d1afe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0201d00:	00005697          	auipc	a3,0x5
ffffffffc0201d04:	60068693          	addi	a3,a3,1536 # ffffffffc0207300 <commands+0xb90>
ffffffffc0201d08:	00005617          	auipc	a2,0x5
ffffffffc0201d0c:	ee860613          	addi	a2,a2,-280 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201d10:	24000593          	li	a1,576
ffffffffc0201d14:	00005517          	auipc	a0,0x5
ffffffffc0201d18:	2dc50513          	addi	a0,a0,732 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201d1c:	cfafe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201d20:	00005697          	auipc	a3,0x5
ffffffffc0201d24:	5c868693          	addi	a3,a3,1480 # ffffffffc02072e8 <commands+0xb78>
ffffffffc0201d28:	00005617          	auipc	a2,0x5
ffffffffc0201d2c:	ec860613          	addi	a2,a2,-312 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201d30:	23f00593          	li	a1,575
ffffffffc0201d34:	00005517          	auipc	a0,0x5
ffffffffc0201d38:	2bc50513          	addi	a0,a0,700 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201d3c:	cdafe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0201d40:	00005697          	auipc	a3,0x5
ffffffffc0201d44:	59868693          	addi	a3,a3,1432 # ffffffffc02072d8 <commands+0xb68>
ffffffffc0201d48:	00005617          	auipc	a2,0x5
ffffffffc0201d4c:	ea860613          	addi	a2,a2,-344 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201d50:	23e00593          	li	a1,574
ffffffffc0201d54:	00005517          	auipc	a0,0x5
ffffffffc0201d58:	29c50513          	addi	a0,a0,668 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201d5c:	cbafe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0201d60:	00005697          	auipc	a3,0x5
ffffffffc0201d64:	56868693          	addi	a3,a3,1384 # ffffffffc02072c8 <commands+0xb58>
ffffffffc0201d68:	00005617          	auipc	a2,0x5
ffffffffc0201d6c:	e8860613          	addi	a2,a2,-376 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201d70:	23d00593          	li	a1,573
ffffffffc0201d74:	00005517          	auipc	a0,0x5
ffffffffc0201d78:	27c50513          	addi	a0,a0,636 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201d7c:	c9afe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d80:	00005697          	auipc	a3,0x5
ffffffffc0201d84:	51868693          	addi	a3,a3,1304 # ffffffffc0207298 <commands+0xb28>
ffffffffc0201d88:	00005617          	auipc	a2,0x5
ffffffffc0201d8c:	e6860613          	addi	a2,a2,-408 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201d90:	23c00593          	li	a1,572
ffffffffc0201d94:	00005517          	auipc	a0,0x5
ffffffffc0201d98:	25c50513          	addi	a0,a0,604 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201d9c:	c7afe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201da0:	00005697          	auipc	a3,0x5
ffffffffc0201da4:	4c068693          	addi	a3,a3,1216 # ffffffffc0207260 <commands+0xaf0>
ffffffffc0201da8:	00005617          	auipc	a2,0x5
ffffffffc0201dac:	e4860613          	addi	a2,a2,-440 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201db0:	23b00593          	li	a1,571
ffffffffc0201db4:	00005517          	auipc	a0,0x5
ffffffffc0201db8:	23c50513          	addi	a0,a0,572 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201dbc:	c5afe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201dc0:	00005697          	auipc	a3,0x5
ffffffffc0201dc4:	47868693          	addi	a3,a3,1144 # ffffffffc0207238 <commands+0xac8>
ffffffffc0201dc8:	00005617          	auipc	a2,0x5
ffffffffc0201dcc:	e2860613          	addi	a2,a2,-472 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201dd0:	23800593          	li	a1,568
ffffffffc0201dd4:	00005517          	auipc	a0,0x5
ffffffffc0201dd8:	21c50513          	addi	a0,a0,540 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201ddc:	c3afe0ef          	jal	ra,ffffffffc0200216 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201de0:	86da                	mv	a3,s6
ffffffffc0201de2:	00005617          	auipc	a2,0x5
ffffffffc0201de6:	1e660613          	addi	a2,a2,486 # ffffffffc0206fc8 <commands+0x858>
ffffffffc0201dea:	23700593          	li	a1,567
ffffffffc0201dee:	00005517          	auipc	a0,0x5
ffffffffc0201df2:	20250513          	addi	a0,a0,514 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201df6:	c20fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201dfa:	86be                	mv	a3,a5
ffffffffc0201dfc:	00005617          	auipc	a2,0x5
ffffffffc0201e00:	1cc60613          	addi	a2,a2,460 # ffffffffc0206fc8 <commands+0x858>
ffffffffc0201e04:	06900593          	li	a1,105
ffffffffc0201e08:	00005517          	auipc	a0,0x5
ffffffffc0201e0c:	21850513          	addi	a0,a0,536 # ffffffffc0207020 <commands+0x8b0>
ffffffffc0201e10:	c06fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201e14:	00005697          	auipc	a3,0x5
ffffffffc0201e18:	59468693          	addi	a3,a3,1428 # ffffffffc02073a8 <commands+0xc38>
ffffffffc0201e1c:	00005617          	auipc	a2,0x5
ffffffffc0201e20:	dd460613          	addi	a2,a2,-556 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201e24:	25100593          	li	a1,593
ffffffffc0201e28:	00005517          	auipc	a0,0x5
ffffffffc0201e2c:	1c850513          	addi	a0,a0,456 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201e30:	be6fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201e34:	00005697          	auipc	a3,0x5
ffffffffc0201e38:	52c68693          	addi	a3,a3,1324 # ffffffffc0207360 <commands+0xbf0>
ffffffffc0201e3c:	00005617          	auipc	a2,0x5
ffffffffc0201e40:	db460613          	addi	a2,a2,-588 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201e44:	24f00593          	li	a1,591
ffffffffc0201e48:	00005517          	auipc	a0,0x5
ffffffffc0201e4c:	1a850513          	addi	a0,a0,424 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201e50:	bc6fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0201e54:	00005697          	auipc	a3,0x5
ffffffffc0201e58:	53c68693          	addi	a3,a3,1340 # ffffffffc0207390 <commands+0xc20>
ffffffffc0201e5c:	00005617          	auipc	a2,0x5
ffffffffc0201e60:	d9460613          	addi	a2,a2,-620 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201e64:	24e00593          	li	a1,590
ffffffffc0201e68:	00005517          	auipc	a0,0x5
ffffffffc0201e6c:	18850513          	addi	a0,a0,392 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201e70:	ba6fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0201e74:	00005697          	auipc	a3,0x5
ffffffffc0201e78:	6a468693          	addi	a3,a3,1700 # ffffffffc0207518 <commands+0xda8>
ffffffffc0201e7c:	00005617          	auipc	a2,0x5
ffffffffc0201e80:	d7460613          	addi	a2,a2,-652 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201e84:	27300593          	li	a1,627
ffffffffc0201e88:	00005517          	auipc	a0,0x5
ffffffffc0201e8c:	16850513          	addi	a0,a0,360 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201e90:	b86fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201e94:	00005697          	auipc	a3,0x5
ffffffffc0201e98:	64468693          	addi	a3,a3,1604 # ffffffffc02074d8 <commands+0xd68>
ffffffffc0201e9c:	00005617          	auipc	a2,0x5
ffffffffc0201ea0:	d5460613          	addi	a2,a2,-684 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201ea4:	27200593          	li	a1,626
ffffffffc0201ea8:	00005517          	auipc	a0,0x5
ffffffffc0201eac:	14850513          	addi	a0,a0,328 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201eb0:	b66fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0201eb4:	00005697          	auipc	a3,0x5
ffffffffc0201eb8:	60c68693          	addi	a3,a3,1548 # ffffffffc02074c0 <commands+0xd50>
ffffffffc0201ebc:	00005617          	auipc	a2,0x5
ffffffffc0201ec0:	d3460613          	addi	a2,a2,-716 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201ec4:	27100593          	li	a1,625
ffffffffc0201ec8:	00005517          	auipc	a0,0x5
ffffffffc0201ecc:	12850513          	addi	a0,a0,296 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201ed0:	b46fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201ed4:	86be                	mv	a3,a5
ffffffffc0201ed6:	00005617          	auipc	a2,0x5
ffffffffc0201eda:	0f260613          	addi	a2,a2,242 # ffffffffc0206fc8 <commands+0x858>
ffffffffc0201ede:	23600593          	li	a1,566
ffffffffc0201ee2:	00005517          	auipc	a0,0x5
ffffffffc0201ee6:	10e50513          	addi	a0,a0,270 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201eea:	b2cfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201eee:	00005617          	auipc	a2,0x5
ffffffffc0201ef2:	1b260613          	addi	a2,a2,434 # ffffffffc02070a0 <commands+0x930>
ffffffffc0201ef6:	08900593          	li	a1,137
ffffffffc0201efa:	00005517          	auipc	a0,0x5
ffffffffc0201efe:	0f650513          	addi	a0,a0,246 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201f02:	b14fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201f06:	00005697          	auipc	a3,0x5
ffffffffc0201f0a:	64268693          	addi	a3,a3,1602 # ffffffffc0207548 <commands+0xdd8>
ffffffffc0201f0e:	00005617          	auipc	a2,0x5
ffffffffc0201f12:	ce260613          	addi	a2,a2,-798 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201f16:	27700593          	li	a1,631
ffffffffc0201f1a:	00005517          	auipc	a0,0x5
ffffffffc0201f1e:	0d650513          	addi	a0,a0,214 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201f22:	af4fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0201f26:	00005697          	auipc	a3,0x5
ffffffffc0201f2a:	4aa68693          	addi	a3,a3,1194 # ffffffffc02073d0 <commands+0xc60>
ffffffffc0201f2e:	00005617          	auipc	a2,0x5
ffffffffc0201f32:	cc260613          	addi	a2,a2,-830 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201f36:	28300593          	li	a1,643
ffffffffc0201f3a:	00005517          	auipc	a0,0x5
ffffffffc0201f3e:	0b650513          	addi	a0,a0,182 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201f42:	ad4fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0201f46:	00005697          	auipc	a3,0x5
ffffffffc0201f4a:	2da68693          	addi	a3,a3,730 # ffffffffc0207220 <commands+0xab0>
ffffffffc0201f4e:	00005617          	auipc	a2,0x5
ffffffffc0201f52:	ca260613          	addi	a2,a2,-862 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201f56:	23400593          	li	a1,564
ffffffffc0201f5a:	00005517          	auipc	a0,0x5
ffffffffc0201f5e:	09650513          	addi	a0,a0,150 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201f62:	ab4fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0201f66:	00005697          	auipc	a3,0x5
ffffffffc0201f6a:	2a268693          	addi	a3,a3,674 # ffffffffc0207208 <commands+0xa98>
ffffffffc0201f6e:	00005617          	auipc	a2,0x5
ffffffffc0201f72:	c8260613          	addi	a2,a2,-894 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201f76:	23300593          	li	a1,563
ffffffffc0201f7a:	00005517          	auipc	a0,0x5
ffffffffc0201f7e:	07650513          	addi	a0,a0,118 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201f82:	a94fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201f86:	00005697          	auipc	a3,0x5
ffffffffc0201f8a:	1d268693          	addi	a3,a3,466 # ffffffffc0207158 <commands+0x9e8>
ffffffffc0201f8e:	00005617          	auipc	a2,0x5
ffffffffc0201f92:	c6260613          	addi	a2,a2,-926 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201f96:	22b00593          	li	a1,555
ffffffffc0201f9a:	00005517          	auipc	a0,0x5
ffffffffc0201f9e:	05650513          	addi	a0,a0,86 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201fa2:	a74fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201fa6:	00005697          	auipc	a3,0x5
ffffffffc0201faa:	20a68693          	addi	a3,a3,522 # ffffffffc02071b0 <commands+0xa40>
ffffffffc0201fae:	00005617          	auipc	a2,0x5
ffffffffc0201fb2:	c4260613          	addi	a2,a2,-958 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201fb6:	23200593          	li	a1,562
ffffffffc0201fba:	00005517          	auipc	a0,0x5
ffffffffc0201fbe:	03650513          	addi	a0,a0,54 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201fc2:	a54fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201fc6:	00005697          	auipc	a3,0x5
ffffffffc0201fca:	1ba68693          	addi	a3,a3,442 # ffffffffc0207180 <commands+0xa10>
ffffffffc0201fce:	00005617          	auipc	a2,0x5
ffffffffc0201fd2:	c2260613          	addi	a2,a2,-990 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201fd6:	22f00593          	li	a1,559
ffffffffc0201fda:	00005517          	auipc	a0,0x5
ffffffffc0201fde:	01650513          	addi	a0,a0,22 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0201fe2:	a34fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201fe6:	00005697          	auipc	a3,0x5
ffffffffc0201fea:	37a68693          	addi	a3,a3,890 # ffffffffc0207360 <commands+0xbf0>
ffffffffc0201fee:	00005617          	auipc	a2,0x5
ffffffffc0201ff2:	c0260613          	addi	a2,a2,-1022 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0201ff6:	24b00593          	li	a1,587
ffffffffc0201ffa:	00005517          	auipc	a0,0x5
ffffffffc0201ffe:	ff650513          	addi	a0,a0,-10 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0202002:	a14fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202006:	00005697          	auipc	a3,0x5
ffffffffc020200a:	21a68693          	addi	a3,a3,538 # ffffffffc0207220 <commands+0xab0>
ffffffffc020200e:	00005617          	auipc	a2,0x5
ffffffffc0202012:	be260613          	addi	a2,a2,-1054 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202016:	24a00593          	li	a1,586
ffffffffc020201a:	00005517          	auipc	a0,0x5
ffffffffc020201e:	fd650513          	addi	a0,a0,-42 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0202022:	9f4fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202026:	00005697          	auipc	a3,0x5
ffffffffc020202a:	35268693          	addi	a3,a3,850 # ffffffffc0207378 <commands+0xc08>
ffffffffc020202e:	00005617          	auipc	a2,0x5
ffffffffc0202032:	bc260613          	addi	a2,a2,-1086 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202036:	24700593          	li	a1,583
ffffffffc020203a:	00005517          	auipc	a0,0x5
ffffffffc020203e:	fb650513          	addi	a0,a0,-74 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0202042:	9d4fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202046:	00005697          	auipc	a3,0x5
ffffffffc020204a:	53a68693          	addi	a3,a3,1338 # ffffffffc0207580 <commands+0xe10>
ffffffffc020204e:	00005617          	auipc	a2,0x5
ffffffffc0202052:	ba260613          	addi	a2,a2,-1118 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202056:	27a00593          	li	a1,634
ffffffffc020205a:	00005517          	auipc	a0,0x5
ffffffffc020205e:	f9650513          	addi	a0,a0,-106 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0202062:	9b4fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0202066:	00005697          	auipc	a3,0x5
ffffffffc020206a:	36a68693          	addi	a3,a3,874 # ffffffffc02073d0 <commands+0xc60>
ffffffffc020206e:	00005617          	auipc	a2,0x5
ffffffffc0202072:	b8260613          	addi	a2,a2,-1150 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202076:	25900593          	li	a1,601
ffffffffc020207a:	00005517          	auipc	a0,0x5
ffffffffc020207e:	f7650513          	addi	a0,a0,-138 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0202082:	994fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202086:	00005697          	auipc	a3,0x5
ffffffffc020208a:	3ea68693          	addi	a3,a3,1002 # ffffffffc0207470 <commands+0xd00>
ffffffffc020208e:	00005617          	auipc	a2,0x5
ffffffffc0202092:	b6260613          	addi	a2,a2,-1182 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202096:	26c00593          	li	a1,620
ffffffffc020209a:	00005517          	auipc	a0,0x5
ffffffffc020209e:	f5650513          	addi	a0,a0,-170 # ffffffffc0206ff0 <commands+0x880>
ffffffffc02020a2:	974fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02020a6:	00005697          	auipc	a3,0x5
ffffffffc02020aa:	05a68693          	addi	a3,a3,90 # ffffffffc0207100 <commands+0x990>
ffffffffc02020ae:	00005617          	auipc	a2,0x5
ffffffffc02020b2:	b4260613          	addi	a2,a2,-1214 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02020b6:	22900593          	li	a1,553
ffffffffc02020ba:	00005517          	auipc	a0,0x5
ffffffffc02020be:	f3650513          	addi	a0,a0,-202 # ffffffffc0206ff0 <commands+0x880>
ffffffffc02020c2:	954fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02020c6:	00005617          	auipc	a2,0x5
ffffffffc02020ca:	fda60613          	addi	a2,a2,-38 # ffffffffc02070a0 <commands+0x930>
ffffffffc02020ce:	0d100593          	li	a1,209
ffffffffc02020d2:	00005517          	auipc	a0,0x5
ffffffffc02020d6:	f1e50513          	addi	a0,a0,-226 # ffffffffc0206ff0 <commands+0x880>
ffffffffc02020da:	93cfe0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02020de <copy_range>:
{
ffffffffc02020de:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02020e0:	00d667b3          	or	a5,a2,a3
{
ffffffffc02020e4:	f486                	sd	ra,104(sp)
ffffffffc02020e6:	f0a2                	sd	s0,96(sp)
ffffffffc02020e8:	eca6                	sd	s1,88(sp)
ffffffffc02020ea:	e8ca                	sd	s2,80(sp)
ffffffffc02020ec:	e4ce                	sd	s3,72(sp)
ffffffffc02020ee:	e0d2                	sd	s4,64(sp)
ffffffffc02020f0:	fc56                	sd	s5,56(sp)
ffffffffc02020f2:	f85a                	sd	s6,48(sp)
ffffffffc02020f4:	f45e                	sd	s7,40(sp)
ffffffffc02020f6:	f062                	sd	s8,32(sp)
ffffffffc02020f8:	ec66                	sd	s9,24(sp)
ffffffffc02020fa:	e86a                	sd	s10,16(sp)
ffffffffc02020fc:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02020fe:	03479713          	slli	a4,a5,0x34
ffffffffc0202102:	1c071a63          	bnez	a4,ffffffffc02022d6 <copy_range+0x1f8>
    assert(USER_ACCESS(start, end));
ffffffffc0202106:	002007b7          	lui	a5,0x200
ffffffffc020210a:	8432                	mv	s0,a2
ffffffffc020210c:	18f66563          	bltu	a2,a5,ffffffffc0202296 <copy_range+0x1b8>
ffffffffc0202110:	84b6                	mv	s1,a3
ffffffffc0202112:	18d67263          	bleu	a3,a2,ffffffffc0202296 <copy_range+0x1b8>
ffffffffc0202116:	4785                	li	a5,1
ffffffffc0202118:	07fe                	slli	a5,a5,0x1f
ffffffffc020211a:	16d7ee63          	bltu	a5,a3,ffffffffc0202296 <copy_range+0x1b8>
ffffffffc020211e:	5a7d                	li	s4,-1
ffffffffc0202120:	8aaa                	mv	s5,a0
ffffffffc0202122:	892e                	mv	s2,a1
        start += PGSIZE;
ffffffffc0202124:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202126:	000aab97          	auipc	s7,0xaa
ffffffffc020212a:	342b8b93          	addi	s7,s7,834 # ffffffffc02ac468 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020212e:	000aab17          	auipc	s6,0xaa
ffffffffc0202132:	3a2b0b13          	addi	s6,s6,930 # ffffffffc02ac4d0 <pages>
    return page - pages + nbase;
ffffffffc0202136:	00080c37          	lui	s8,0x80
    return KADDR(page2pa(page));
ffffffffc020213a:	00ca5a13          	srli	s4,s4,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc020213e:	4601                	li	a2,0
ffffffffc0202140:	85a2                	mv	a1,s0
ffffffffc0202142:	854a                	mv	a0,s2
ffffffffc0202144:	e3dfe0ef          	jal	ra,ffffffffc0200f80 <get_pte>
ffffffffc0202148:	8caa                	mv	s9,a0
        if (ptep == NULL)
ffffffffc020214a:	c569                	beqz	a0,ffffffffc0202214 <copy_range+0x136>
        if (*ptep & PTE_V)
ffffffffc020214c:	611c                	ld	a5,0(a0)
ffffffffc020214e:	8b85                	andi	a5,a5,1
ffffffffc0202150:	e785                	bnez	a5,ffffffffc0202178 <copy_range+0x9a>
        start += PGSIZE;
ffffffffc0202152:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc0202154:	fe9465e3          	bltu	s0,s1,ffffffffc020213e <copy_range+0x60>
    return 0;
ffffffffc0202158:	4501                	li	a0,0
}
ffffffffc020215a:	70a6                	ld	ra,104(sp)
ffffffffc020215c:	7406                	ld	s0,96(sp)
ffffffffc020215e:	64e6                	ld	s1,88(sp)
ffffffffc0202160:	6946                	ld	s2,80(sp)
ffffffffc0202162:	69a6                	ld	s3,72(sp)
ffffffffc0202164:	6a06                	ld	s4,64(sp)
ffffffffc0202166:	7ae2                	ld	s5,56(sp)
ffffffffc0202168:	7b42                	ld	s6,48(sp)
ffffffffc020216a:	7ba2                	ld	s7,40(sp)
ffffffffc020216c:	7c02                	ld	s8,32(sp)
ffffffffc020216e:	6ce2                	ld	s9,24(sp)
ffffffffc0202170:	6d42                	ld	s10,16(sp)
ffffffffc0202172:	6da2                	ld	s11,8(sp)
ffffffffc0202174:	6165                	addi	sp,sp,112
ffffffffc0202176:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL)
ffffffffc0202178:	4605                	li	a2,1
ffffffffc020217a:	85a2                	mv	a1,s0
ffffffffc020217c:	8556                	mv	a0,s5
ffffffffc020217e:	e03fe0ef          	jal	ra,ffffffffc0200f80 <get_pte>
ffffffffc0202182:	c15d                	beqz	a0,ffffffffc0202228 <copy_range+0x14a>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0202184:	000cb783          	ld	a5,0(s9)
    if (!(pte & PTE_V)) {
ffffffffc0202188:	0017f713          	andi	a4,a5,1
ffffffffc020218c:	01f7fc93          	andi	s9,a5,31
ffffffffc0202190:	0e070763          	beqz	a4,ffffffffc020227e <copy_range+0x1a0>
    if (PPN(pa) >= npage) {
ffffffffc0202194:	000bb683          	ld	a3,0(s7)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202198:	078a                	slli	a5,a5,0x2
ffffffffc020219a:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020219e:	0cd77463          	bleu	a3,a4,ffffffffc0202266 <copy_range+0x188>
    return &pages[PPN(pa) - nbase];
ffffffffc02021a2:	000b3783          	ld	a5,0(s6)
ffffffffc02021a6:	fff806b7          	lui	a3,0xfff80
ffffffffc02021aa:	9736                	add	a4,a4,a3
ffffffffc02021ac:	071a                	slli	a4,a4,0x6
            struct Page *npage = alloc_page();
ffffffffc02021ae:	4505                	li	a0,1
ffffffffc02021b0:	00e78d33          	add	s10,a5,a4
ffffffffc02021b4:	cbffe0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc02021b8:	8daa                	mv	s11,a0
            assert(page != NULL);
ffffffffc02021ba:	080d0663          	beqz	s10,ffffffffc0202246 <copy_range+0x168>
            assert(npage != NULL);
ffffffffc02021be:	0e050c63          	beqz	a0,ffffffffc02022b6 <copy_range+0x1d8>
    return page - pages + nbase;
ffffffffc02021c2:	000b3703          	ld	a4,0(s6)
    return KADDR(page2pa(page));
ffffffffc02021c6:	000bb603          	ld	a2,0(s7)
    return page - pages + nbase;
ffffffffc02021ca:	40ed06b3          	sub	a3,s10,a4
ffffffffc02021ce:	8699                	srai	a3,a3,0x6
ffffffffc02021d0:	96e2                	add	a3,a3,s8
    return KADDR(page2pa(page));
ffffffffc02021d2:	0146f7b3          	and	a5,a3,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc02021d6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02021d8:	04c7fb63          	bleu	a2,a5,ffffffffc020222e <copy_range+0x150>
    return page - pages + nbase;
ffffffffc02021dc:	40e507b3          	sub	a5,a0,a4
    return KADDR(page2pa(page));
ffffffffc02021e0:	000aa717          	auipc	a4,0xaa
ffffffffc02021e4:	2e070713          	addi	a4,a4,736 # ffffffffc02ac4c0 <va_pa_offset>
ffffffffc02021e8:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc02021ea:	8799                	srai	a5,a5,0x6
ffffffffc02021ec:	97e2                	add	a5,a5,s8
    return KADDR(page2pa(page));
ffffffffc02021ee:	0147f733          	and	a4,a5,s4
ffffffffc02021f2:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02021f6:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02021f8:	02c77a63          	bleu	a2,a4,ffffffffc020222c <copy_range+0x14e>
            memcpy(kva_dst, kva_src, PGSIZE);
ffffffffc02021fc:	6605                	lui	a2,0x1
ffffffffc02021fe:	953e                	add	a0,a0,a5
ffffffffc0202200:	7d5030ef          	jal	ra,ffffffffc02061d4 <memcpy>
            page_insert(to, npage, start, perm);
ffffffffc0202204:	8622                	mv	a2,s0
ffffffffc0202206:	86e6                	mv	a3,s9
ffffffffc0202208:	85ee                	mv	a1,s11
ffffffffc020220a:	8556                	mv	a0,s5
ffffffffc020220c:	b8aff0ef          	jal	ra,ffffffffc0201596 <page_insert>
        start += PGSIZE;
ffffffffc0202210:	944e                	add	s0,s0,s3
ffffffffc0202212:	b789                	j	ffffffffc0202154 <copy_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202214:	002007b7          	lui	a5,0x200
ffffffffc0202218:	943e                	add	s0,s0,a5
ffffffffc020221a:	ffe007b7          	lui	a5,0xffe00
ffffffffc020221e:	8c7d                	and	s0,s0,a5
    } while (start != 0 && start < end);
ffffffffc0202220:	dc05                	beqz	s0,ffffffffc0202158 <copy_range+0x7a>
ffffffffc0202222:	f0946ee3          	bltu	s0,s1,ffffffffc020213e <copy_range+0x60>
ffffffffc0202226:	bf0d                	j	ffffffffc0202158 <copy_range+0x7a>
                return -E_NO_MEM;
ffffffffc0202228:	5571                	li	a0,-4
ffffffffc020222a:	bf05                	j	ffffffffc020215a <copy_range+0x7c>
ffffffffc020222c:	86be                	mv	a3,a5
ffffffffc020222e:	00005617          	auipc	a2,0x5
ffffffffc0202232:	d9a60613          	addi	a2,a2,-614 # ffffffffc0206fc8 <commands+0x858>
ffffffffc0202236:	06900593          	li	a1,105
ffffffffc020223a:	00005517          	auipc	a0,0x5
ffffffffc020223e:	de650513          	addi	a0,a0,-538 # ffffffffc0207020 <commands+0x8b0>
ffffffffc0202242:	fd5fd0ef          	jal	ra,ffffffffc0200216 <__panic>
            assert(page != NULL);
ffffffffc0202246:	00005697          	auipc	a3,0x5
ffffffffc020224a:	d6268693          	addi	a3,a3,-670 # ffffffffc0206fa8 <commands+0x838>
ffffffffc020224e:	00005617          	auipc	a2,0x5
ffffffffc0202252:	9a260613          	addi	a2,a2,-1630 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202256:	19e00593          	li	a1,414
ffffffffc020225a:	00005517          	auipc	a0,0x5
ffffffffc020225e:	d9650513          	addi	a0,a0,-618 # ffffffffc0206ff0 <commands+0x880>
ffffffffc0202262:	fb5fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202266:	00005617          	auipc	a2,0x5
ffffffffc020226a:	d9a60613          	addi	a2,a2,-614 # ffffffffc0207000 <commands+0x890>
ffffffffc020226e:	06200593          	li	a1,98
ffffffffc0202272:	00005517          	auipc	a0,0x5
ffffffffc0202276:	dae50513          	addi	a0,a0,-594 # ffffffffc0207020 <commands+0x8b0>
ffffffffc020227a:	f9dfd0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020227e:	00005617          	auipc	a2,0x5
ffffffffc0202282:	f6260613          	addi	a2,a2,-158 # ffffffffc02071e0 <commands+0xa70>
ffffffffc0202286:	07400593          	li	a1,116
ffffffffc020228a:	00005517          	auipc	a0,0x5
ffffffffc020228e:	d9650513          	addi	a0,a0,-618 # ffffffffc0207020 <commands+0x8b0>
ffffffffc0202292:	f85fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0202296:	00005697          	auipc	a3,0x5
ffffffffc020229a:	36268693          	addi	a3,a3,866 # ffffffffc02075f8 <commands+0xe88>
ffffffffc020229e:	00005617          	auipc	a2,0x5
ffffffffc02022a2:	95260613          	addi	a2,a2,-1710 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02022a6:	18600593          	li	a1,390
ffffffffc02022aa:	00005517          	auipc	a0,0x5
ffffffffc02022ae:	d4650513          	addi	a0,a0,-698 # ffffffffc0206ff0 <commands+0x880>
ffffffffc02022b2:	f65fd0ef          	jal	ra,ffffffffc0200216 <__panic>
            assert(npage != NULL);
ffffffffc02022b6:	00005697          	auipc	a3,0x5
ffffffffc02022ba:	d0268693          	addi	a3,a3,-766 # ffffffffc0206fb8 <commands+0x848>
ffffffffc02022be:	00005617          	auipc	a2,0x5
ffffffffc02022c2:	93260613          	addi	a2,a2,-1742 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02022c6:	19f00593          	li	a1,415
ffffffffc02022ca:	00005517          	auipc	a0,0x5
ffffffffc02022ce:	d2650513          	addi	a0,a0,-730 # ffffffffc0206ff0 <commands+0x880>
ffffffffc02022d2:	f45fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022d6:	00005697          	auipc	a3,0x5
ffffffffc02022da:	2f268693          	addi	a3,a3,754 # ffffffffc02075c8 <commands+0xe58>
ffffffffc02022de:	00005617          	auipc	a2,0x5
ffffffffc02022e2:	91260613          	addi	a2,a2,-1774 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02022e6:	18500593          	li	a1,389
ffffffffc02022ea:	00005517          	auipc	a0,0x5
ffffffffc02022ee:	d0650513          	addi	a0,a0,-762 # ffffffffc0206ff0 <commands+0x880>
ffffffffc02022f2:	f25fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02022f6 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02022f6:	12058073          	sfence.vma	a1
}
ffffffffc02022fa:	8082                	ret

ffffffffc02022fc <pgdir_alloc_page>:
{
ffffffffc02022fc:	7179                	addi	sp,sp,-48
ffffffffc02022fe:	e84a                	sd	s2,16(sp)
ffffffffc0202300:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0202302:	4505                	li	a0,1
{
ffffffffc0202304:	f022                	sd	s0,32(sp)
ffffffffc0202306:	ec26                	sd	s1,24(sp)
ffffffffc0202308:	e44e                	sd	s3,8(sp)
ffffffffc020230a:	f406                	sd	ra,40(sp)
ffffffffc020230c:	84ae                	mv	s1,a1
ffffffffc020230e:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0202310:	b63fe0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc0202314:	842a                	mv	s0,a0
    if (page != NULL)
ffffffffc0202316:	cd1d                	beqz	a0,ffffffffc0202354 <pgdir_alloc_page+0x58>
        if (page_insert(pgdir, page, la, perm) != 0)
ffffffffc0202318:	85aa                	mv	a1,a0
ffffffffc020231a:	86ce                	mv	a3,s3
ffffffffc020231c:	8626                	mv	a2,s1
ffffffffc020231e:	854a                	mv	a0,s2
ffffffffc0202320:	a76ff0ef          	jal	ra,ffffffffc0201596 <page_insert>
ffffffffc0202324:	e121                	bnez	a0,ffffffffc0202364 <pgdir_alloc_page+0x68>
        if (swap_init_ok)
ffffffffc0202326:	000aa797          	auipc	a5,0xaa
ffffffffc020232a:	16278793          	addi	a5,a5,354 # ffffffffc02ac488 <swap_init_ok>
ffffffffc020232e:	439c                	lw	a5,0(a5)
ffffffffc0202330:	2781                	sext.w	a5,a5
ffffffffc0202332:	c38d                	beqz	a5,ffffffffc0202354 <pgdir_alloc_page+0x58>
            if (check_mm_struct != NULL)
ffffffffc0202334:	000aa797          	auipc	a5,0xaa
ffffffffc0202338:	1b478793          	addi	a5,a5,436 # ffffffffc02ac4e8 <check_mm_struct>
ffffffffc020233c:	6388                	ld	a0,0(a5)
ffffffffc020233e:	c919                	beqz	a0,ffffffffc0202354 <pgdir_alloc_page+0x58>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202340:	4681                	li	a3,0
ffffffffc0202342:	8622                	mv	a2,s0
ffffffffc0202344:	85a6                	mv	a1,s1
ffffffffc0202346:	2d5010ef          	jal	ra,ffffffffc0203e1a <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc020234a:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc020234c:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc020234e:	4785                	li	a5,1
ffffffffc0202350:	02f71063          	bne	a4,a5,ffffffffc0202370 <pgdir_alloc_page+0x74>
}
ffffffffc0202354:	8522                	mv	a0,s0
ffffffffc0202356:	70a2                	ld	ra,40(sp)
ffffffffc0202358:	7402                	ld	s0,32(sp)
ffffffffc020235a:	64e2                	ld	s1,24(sp)
ffffffffc020235c:	6942                	ld	s2,16(sp)
ffffffffc020235e:	69a2                	ld	s3,8(sp)
ffffffffc0202360:	6145                	addi	sp,sp,48
ffffffffc0202362:	8082                	ret
            free_page(page);
ffffffffc0202364:	8522                	mv	a0,s0
ffffffffc0202366:	4585                	li	a1,1
ffffffffc0202368:	b93fe0ef          	jal	ra,ffffffffc0200efa <free_pages>
            return NULL;
ffffffffc020236c:	4401                	li	s0,0
ffffffffc020236e:	b7dd                	j	ffffffffc0202354 <pgdir_alloc_page+0x58>
                assert(page_ref(page) == 1);
ffffffffc0202370:	00005697          	auipc	a3,0x5
ffffffffc0202374:	cc068693          	addi	a3,a3,-832 # ffffffffc0207030 <commands+0x8c0>
ffffffffc0202378:	00005617          	auipc	a2,0x5
ffffffffc020237c:	87860613          	addi	a2,a2,-1928 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202380:	20600593          	li	a1,518
ffffffffc0202384:	00005517          	auipc	a0,0x5
ffffffffc0202388:	c6c50513          	addi	a0,a0,-916 # ffffffffc0206ff0 <commands+0x880>
ffffffffc020238c:	e8bfd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202390 <_fifo_init_mm>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0202390:	000aa797          	auipc	a5,0xaa
ffffffffc0202394:	14878793          	addi	a5,a5,328 # ffffffffc02ac4d8 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0202398:	f51c                	sd	a5,40(a0)
ffffffffc020239a:	e79c                	sd	a5,8(a5)
ffffffffc020239c:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc020239e:	4501                	li	a0,0
ffffffffc02023a0:	8082                	ret

ffffffffc02023a2 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc02023a2:	4501                	li	a0,0
ffffffffc02023a4:	8082                	ret

ffffffffc02023a6 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02023a6:	4501                	li	a0,0
ffffffffc02023a8:	8082                	ret

ffffffffc02023aa <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc02023aa:	4501                	li	a0,0
ffffffffc02023ac:	8082                	ret

ffffffffc02023ae <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc02023ae:	711d                	addi	sp,sp,-96
ffffffffc02023b0:	fc4e                	sd	s3,56(sp)
ffffffffc02023b2:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02023b4:	00005517          	auipc	a0,0x5
ffffffffc02023b8:	25c50513          	addi	a0,a0,604 # ffffffffc0207610 <commands+0xea0>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02023bc:	698d                	lui	s3,0x3
ffffffffc02023be:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc02023c0:	e8a2                	sd	s0,80(sp)
ffffffffc02023c2:	e4a6                	sd	s1,72(sp)
ffffffffc02023c4:	ec86                	sd	ra,88(sp)
ffffffffc02023c6:	e0ca                	sd	s2,64(sp)
ffffffffc02023c8:	f456                	sd	s5,40(sp)
ffffffffc02023ca:	f05a                	sd	s6,32(sp)
ffffffffc02023cc:	ec5e                	sd	s7,24(sp)
ffffffffc02023ce:	e862                	sd	s8,16(sp)
ffffffffc02023d0:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc02023d2:	000aa417          	auipc	s0,0xaa
ffffffffc02023d6:	09e40413          	addi	s0,s0,158 # ffffffffc02ac470 <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02023da:	cf7fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02023de:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6578>
    assert(pgfault_num==4);
ffffffffc02023e2:	4004                	lw	s1,0(s0)
ffffffffc02023e4:	4791                	li	a5,4
ffffffffc02023e6:	2481                	sext.w	s1,s1
ffffffffc02023e8:	14f49963          	bne	s1,a5,ffffffffc020253a <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02023ec:	00005517          	auipc	a0,0x5
ffffffffc02023f0:	27450513          	addi	a0,a0,628 # ffffffffc0207660 <commands+0xef0>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02023f4:	6a85                	lui	s5,0x1
ffffffffc02023f6:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02023f8:	cd9fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02023fc:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8578>
    assert(pgfault_num==4);
ffffffffc0202400:	00042903          	lw	s2,0(s0)
ffffffffc0202404:	2901                	sext.w	s2,s2
ffffffffc0202406:	2a991a63          	bne	s2,s1,ffffffffc02026ba <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020240a:	00005517          	auipc	a0,0x5
ffffffffc020240e:	27e50513          	addi	a0,a0,638 # ffffffffc0207688 <commands+0xf18>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202412:	6b91                	lui	s7,0x4
ffffffffc0202414:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0202416:	cbbfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020241a:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5578>
    assert(pgfault_num==4);
ffffffffc020241e:	4004                	lw	s1,0(s0)
ffffffffc0202420:	2481                	sext.w	s1,s1
ffffffffc0202422:	27249c63          	bne	s1,s2,ffffffffc020269a <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0202426:	00005517          	auipc	a0,0x5
ffffffffc020242a:	28a50513          	addi	a0,a0,650 # ffffffffc02076b0 <commands+0xf40>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020242e:	6909                	lui	s2,0x2
ffffffffc0202430:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0202432:	c9ffd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202436:	01990023          	sb	s9,0(s2) # 2000 <_binary_obj___user_faultread_out_size-0x7578>
    assert(pgfault_num==4);
ffffffffc020243a:	401c                	lw	a5,0(s0)
ffffffffc020243c:	2781                	sext.w	a5,a5
ffffffffc020243e:	22979e63          	bne	a5,s1,ffffffffc020267a <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0202442:	00005517          	auipc	a0,0x5
ffffffffc0202446:	29650513          	addi	a0,a0,662 # ffffffffc02076d8 <commands+0xf68>
ffffffffc020244a:	c87fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020244e:	6795                	lui	a5,0x5
ffffffffc0202450:	4739                	li	a4,14
ffffffffc0202452:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4578>
    assert(pgfault_num==5);
ffffffffc0202456:	4004                	lw	s1,0(s0)
ffffffffc0202458:	4795                	li	a5,5
ffffffffc020245a:	2481                	sext.w	s1,s1
ffffffffc020245c:	1ef49f63          	bne	s1,a5,ffffffffc020265a <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0202460:	00005517          	auipc	a0,0x5
ffffffffc0202464:	25050513          	addi	a0,a0,592 # ffffffffc02076b0 <commands+0xf40>
ffffffffc0202468:	c69fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020246c:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0202470:	401c                	lw	a5,0(s0)
ffffffffc0202472:	2781                	sext.w	a5,a5
ffffffffc0202474:	1c979363          	bne	a5,s1,ffffffffc020263a <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0202478:	00005517          	auipc	a0,0x5
ffffffffc020247c:	1e850513          	addi	a0,a0,488 # ffffffffc0207660 <commands+0xef0>
ffffffffc0202480:	c51fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202484:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0202488:	401c                	lw	a5,0(s0)
ffffffffc020248a:	4719                	li	a4,6
ffffffffc020248c:	2781                	sext.w	a5,a5
ffffffffc020248e:	18e79663          	bne	a5,a4,ffffffffc020261a <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0202492:	00005517          	auipc	a0,0x5
ffffffffc0202496:	21e50513          	addi	a0,a0,542 # ffffffffc02076b0 <commands+0xf40>
ffffffffc020249a:	c37fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020249e:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc02024a2:	401c                	lw	a5,0(s0)
ffffffffc02024a4:	471d                	li	a4,7
ffffffffc02024a6:	2781                	sext.w	a5,a5
ffffffffc02024a8:	14e79963          	bne	a5,a4,ffffffffc02025fa <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02024ac:	00005517          	auipc	a0,0x5
ffffffffc02024b0:	16450513          	addi	a0,a0,356 # ffffffffc0207610 <commands+0xea0>
ffffffffc02024b4:	c1dfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02024b8:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc02024bc:	401c                	lw	a5,0(s0)
ffffffffc02024be:	4721                	li	a4,8
ffffffffc02024c0:	2781                	sext.w	a5,a5
ffffffffc02024c2:	10e79c63          	bne	a5,a4,ffffffffc02025da <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02024c6:	00005517          	auipc	a0,0x5
ffffffffc02024ca:	1c250513          	addi	a0,a0,450 # ffffffffc0207688 <commands+0xf18>
ffffffffc02024ce:	c03fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02024d2:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc02024d6:	401c                	lw	a5,0(s0)
ffffffffc02024d8:	4725                	li	a4,9
ffffffffc02024da:	2781                	sext.w	a5,a5
ffffffffc02024dc:	0ce79f63          	bne	a5,a4,ffffffffc02025ba <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02024e0:	00005517          	auipc	a0,0x5
ffffffffc02024e4:	1f850513          	addi	a0,a0,504 # ffffffffc02076d8 <commands+0xf68>
ffffffffc02024e8:	be9fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02024ec:	6795                	lui	a5,0x5
ffffffffc02024ee:	4739                	li	a4,14
ffffffffc02024f0:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4578>
    assert(pgfault_num==10);
ffffffffc02024f4:	4004                	lw	s1,0(s0)
ffffffffc02024f6:	47a9                	li	a5,10
ffffffffc02024f8:	2481                	sext.w	s1,s1
ffffffffc02024fa:	0af49063          	bne	s1,a5,ffffffffc020259a <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02024fe:	00005517          	auipc	a0,0x5
ffffffffc0202502:	16250513          	addi	a0,a0,354 # ffffffffc0207660 <commands+0xef0>
ffffffffc0202506:	bcbfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020250a:	6785                	lui	a5,0x1
ffffffffc020250c:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8578>
ffffffffc0202510:	06979563          	bne	a5,s1,ffffffffc020257a <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0202514:	401c                	lw	a5,0(s0)
ffffffffc0202516:	472d                	li	a4,11
ffffffffc0202518:	2781                	sext.w	a5,a5
ffffffffc020251a:	04e79063          	bne	a5,a4,ffffffffc020255a <_fifo_check_swap+0x1ac>
}
ffffffffc020251e:	60e6                	ld	ra,88(sp)
ffffffffc0202520:	6446                	ld	s0,80(sp)
ffffffffc0202522:	64a6                	ld	s1,72(sp)
ffffffffc0202524:	6906                	ld	s2,64(sp)
ffffffffc0202526:	79e2                	ld	s3,56(sp)
ffffffffc0202528:	7a42                	ld	s4,48(sp)
ffffffffc020252a:	7aa2                	ld	s5,40(sp)
ffffffffc020252c:	7b02                	ld	s6,32(sp)
ffffffffc020252e:	6be2                	ld	s7,24(sp)
ffffffffc0202530:	6c42                	ld	s8,16(sp)
ffffffffc0202532:	6ca2                	ld	s9,8(sp)
ffffffffc0202534:	4501                	li	a0,0
ffffffffc0202536:	6125                	addi	sp,sp,96
ffffffffc0202538:	8082                	ret
    assert(pgfault_num==4);
ffffffffc020253a:	00005697          	auipc	a3,0x5
ffffffffc020253e:	0fe68693          	addi	a3,a3,254 # ffffffffc0207638 <commands+0xec8>
ffffffffc0202542:	00004617          	auipc	a2,0x4
ffffffffc0202546:	6ae60613          	addi	a2,a2,1710 # ffffffffc0206bf0 <commands+0x480>
ffffffffc020254a:	05100593          	li	a1,81
ffffffffc020254e:	00005517          	auipc	a0,0x5
ffffffffc0202552:	0fa50513          	addi	a0,a0,250 # ffffffffc0207648 <commands+0xed8>
ffffffffc0202556:	cc1fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==11);
ffffffffc020255a:	00005697          	auipc	a3,0x5
ffffffffc020255e:	22e68693          	addi	a3,a3,558 # ffffffffc0207788 <commands+0x1018>
ffffffffc0202562:	00004617          	auipc	a2,0x4
ffffffffc0202566:	68e60613          	addi	a2,a2,1678 # ffffffffc0206bf0 <commands+0x480>
ffffffffc020256a:	07300593          	li	a1,115
ffffffffc020256e:	00005517          	auipc	a0,0x5
ffffffffc0202572:	0da50513          	addi	a0,a0,218 # ffffffffc0207648 <commands+0xed8>
ffffffffc0202576:	ca1fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020257a:	00005697          	auipc	a3,0x5
ffffffffc020257e:	1e668693          	addi	a3,a3,486 # ffffffffc0207760 <commands+0xff0>
ffffffffc0202582:	00004617          	auipc	a2,0x4
ffffffffc0202586:	66e60613          	addi	a2,a2,1646 # ffffffffc0206bf0 <commands+0x480>
ffffffffc020258a:	07100593          	li	a1,113
ffffffffc020258e:	00005517          	auipc	a0,0x5
ffffffffc0202592:	0ba50513          	addi	a0,a0,186 # ffffffffc0207648 <commands+0xed8>
ffffffffc0202596:	c81fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==10);
ffffffffc020259a:	00005697          	auipc	a3,0x5
ffffffffc020259e:	1b668693          	addi	a3,a3,438 # ffffffffc0207750 <commands+0xfe0>
ffffffffc02025a2:	00004617          	auipc	a2,0x4
ffffffffc02025a6:	64e60613          	addi	a2,a2,1614 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02025aa:	06f00593          	li	a1,111
ffffffffc02025ae:	00005517          	auipc	a0,0x5
ffffffffc02025b2:	09a50513          	addi	a0,a0,154 # ffffffffc0207648 <commands+0xed8>
ffffffffc02025b6:	c61fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==9);
ffffffffc02025ba:	00005697          	auipc	a3,0x5
ffffffffc02025be:	18668693          	addi	a3,a3,390 # ffffffffc0207740 <commands+0xfd0>
ffffffffc02025c2:	00004617          	auipc	a2,0x4
ffffffffc02025c6:	62e60613          	addi	a2,a2,1582 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02025ca:	06c00593          	li	a1,108
ffffffffc02025ce:	00005517          	auipc	a0,0x5
ffffffffc02025d2:	07a50513          	addi	a0,a0,122 # ffffffffc0207648 <commands+0xed8>
ffffffffc02025d6:	c41fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==8);
ffffffffc02025da:	00005697          	auipc	a3,0x5
ffffffffc02025de:	15668693          	addi	a3,a3,342 # ffffffffc0207730 <commands+0xfc0>
ffffffffc02025e2:	00004617          	auipc	a2,0x4
ffffffffc02025e6:	60e60613          	addi	a2,a2,1550 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02025ea:	06900593          	li	a1,105
ffffffffc02025ee:	00005517          	auipc	a0,0x5
ffffffffc02025f2:	05a50513          	addi	a0,a0,90 # ffffffffc0207648 <commands+0xed8>
ffffffffc02025f6:	c21fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==7);
ffffffffc02025fa:	00005697          	auipc	a3,0x5
ffffffffc02025fe:	12668693          	addi	a3,a3,294 # ffffffffc0207720 <commands+0xfb0>
ffffffffc0202602:	00004617          	auipc	a2,0x4
ffffffffc0202606:	5ee60613          	addi	a2,a2,1518 # ffffffffc0206bf0 <commands+0x480>
ffffffffc020260a:	06600593          	li	a1,102
ffffffffc020260e:	00005517          	auipc	a0,0x5
ffffffffc0202612:	03a50513          	addi	a0,a0,58 # ffffffffc0207648 <commands+0xed8>
ffffffffc0202616:	c01fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==6);
ffffffffc020261a:	00005697          	auipc	a3,0x5
ffffffffc020261e:	0f668693          	addi	a3,a3,246 # ffffffffc0207710 <commands+0xfa0>
ffffffffc0202622:	00004617          	auipc	a2,0x4
ffffffffc0202626:	5ce60613          	addi	a2,a2,1486 # ffffffffc0206bf0 <commands+0x480>
ffffffffc020262a:	06300593          	li	a1,99
ffffffffc020262e:	00005517          	auipc	a0,0x5
ffffffffc0202632:	01a50513          	addi	a0,a0,26 # ffffffffc0207648 <commands+0xed8>
ffffffffc0202636:	be1fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==5);
ffffffffc020263a:	00005697          	auipc	a3,0x5
ffffffffc020263e:	0c668693          	addi	a3,a3,198 # ffffffffc0207700 <commands+0xf90>
ffffffffc0202642:	00004617          	auipc	a2,0x4
ffffffffc0202646:	5ae60613          	addi	a2,a2,1454 # ffffffffc0206bf0 <commands+0x480>
ffffffffc020264a:	06000593          	li	a1,96
ffffffffc020264e:	00005517          	auipc	a0,0x5
ffffffffc0202652:	ffa50513          	addi	a0,a0,-6 # ffffffffc0207648 <commands+0xed8>
ffffffffc0202656:	bc1fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==5);
ffffffffc020265a:	00005697          	auipc	a3,0x5
ffffffffc020265e:	0a668693          	addi	a3,a3,166 # ffffffffc0207700 <commands+0xf90>
ffffffffc0202662:	00004617          	auipc	a2,0x4
ffffffffc0202666:	58e60613          	addi	a2,a2,1422 # ffffffffc0206bf0 <commands+0x480>
ffffffffc020266a:	05d00593          	li	a1,93
ffffffffc020266e:	00005517          	auipc	a0,0x5
ffffffffc0202672:	fda50513          	addi	a0,a0,-38 # ffffffffc0207648 <commands+0xed8>
ffffffffc0202676:	ba1fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==4);
ffffffffc020267a:	00005697          	auipc	a3,0x5
ffffffffc020267e:	fbe68693          	addi	a3,a3,-66 # ffffffffc0207638 <commands+0xec8>
ffffffffc0202682:	00004617          	auipc	a2,0x4
ffffffffc0202686:	56e60613          	addi	a2,a2,1390 # ffffffffc0206bf0 <commands+0x480>
ffffffffc020268a:	05a00593          	li	a1,90
ffffffffc020268e:	00005517          	auipc	a0,0x5
ffffffffc0202692:	fba50513          	addi	a0,a0,-70 # ffffffffc0207648 <commands+0xed8>
ffffffffc0202696:	b81fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==4);
ffffffffc020269a:	00005697          	auipc	a3,0x5
ffffffffc020269e:	f9e68693          	addi	a3,a3,-98 # ffffffffc0207638 <commands+0xec8>
ffffffffc02026a2:	00004617          	auipc	a2,0x4
ffffffffc02026a6:	54e60613          	addi	a2,a2,1358 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02026aa:	05700593          	li	a1,87
ffffffffc02026ae:	00005517          	auipc	a0,0x5
ffffffffc02026b2:	f9a50513          	addi	a0,a0,-102 # ffffffffc0207648 <commands+0xed8>
ffffffffc02026b6:	b61fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==4);
ffffffffc02026ba:	00005697          	auipc	a3,0x5
ffffffffc02026be:	f7e68693          	addi	a3,a3,-130 # ffffffffc0207638 <commands+0xec8>
ffffffffc02026c2:	00004617          	auipc	a2,0x4
ffffffffc02026c6:	52e60613          	addi	a2,a2,1326 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02026ca:	05400593          	li	a1,84
ffffffffc02026ce:	00005517          	auipc	a0,0x5
ffffffffc02026d2:	f7a50513          	addi	a0,a0,-134 # ffffffffc0207648 <commands+0xed8>
ffffffffc02026d6:	b41fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02026da <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02026da:	751c                	ld	a5,40(a0)
{
ffffffffc02026dc:	1141                	addi	sp,sp,-16
ffffffffc02026de:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc02026e0:	cf91                	beqz	a5,ffffffffc02026fc <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc02026e2:	ee0d                	bnez	a2,ffffffffc020271c <_fifo_swap_out_victim+0x42>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc02026e4:	679c                	ld	a5,8(a5)
}
ffffffffc02026e6:	60a2                	ld	ra,8(sp)
ffffffffc02026e8:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc02026ea:	6394                	ld	a3,0(a5)
ffffffffc02026ec:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc02026ee:	fd878793          	addi	a5,a5,-40
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02026f2:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02026f4:	e314                	sd	a3,0(a4)
ffffffffc02026f6:	e19c                	sd	a5,0(a1)
}
ffffffffc02026f8:	0141                	addi	sp,sp,16
ffffffffc02026fa:	8082                	ret
         assert(head != NULL);
ffffffffc02026fc:	00005697          	auipc	a3,0x5
ffffffffc0202700:	0bc68693          	addi	a3,a3,188 # ffffffffc02077b8 <commands+0x1048>
ffffffffc0202704:	00004617          	auipc	a2,0x4
ffffffffc0202708:	4ec60613          	addi	a2,a2,1260 # ffffffffc0206bf0 <commands+0x480>
ffffffffc020270c:	04100593          	li	a1,65
ffffffffc0202710:	00005517          	auipc	a0,0x5
ffffffffc0202714:	f3850513          	addi	a0,a0,-200 # ffffffffc0207648 <commands+0xed8>
ffffffffc0202718:	afffd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(in_tick==0);
ffffffffc020271c:	00005697          	auipc	a3,0x5
ffffffffc0202720:	0ac68693          	addi	a3,a3,172 # ffffffffc02077c8 <commands+0x1058>
ffffffffc0202724:	00004617          	auipc	a2,0x4
ffffffffc0202728:	4cc60613          	addi	a2,a2,1228 # ffffffffc0206bf0 <commands+0x480>
ffffffffc020272c:	04200593          	li	a1,66
ffffffffc0202730:	00005517          	auipc	a0,0x5
ffffffffc0202734:	f1850513          	addi	a0,a0,-232 # ffffffffc0207648 <commands+0xed8>
ffffffffc0202738:	adffd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020273c <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc020273c:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0202740:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0202742:	cb09                	beqz	a4,ffffffffc0202754 <_fifo_map_swappable+0x18>
ffffffffc0202744:	cb81                	beqz	a5,ffffffffc0202754 <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202746:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0202748:	e398                	sd	a4,0(a5)
}
ffffffffc020274a:	4501                	li	a0,0
ffffffffc020274c:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc020274e:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0202750:	f614                	sd	a3,40(a2)
ffffffffc0202752:	8082                	ret
{
ffffffffc0202754:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0202756:	00005697          	auipc	a3,0x5
ffffffffc020275a:	04268693          	addi	a3,a3,66 # ffffffffc0207798 <commands+0x1028>
ffffffffc020275e:	00004617          	auipc	a2,0x4
ffffffffc0202762:	49260613          	addi	a2,a2,1170 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202766:	03200593          	li	a1,50
ffffffffc020276a:	00005517          	auipc	a0,0x5
ffffffffc020276e:	ede50513          	addi	a0,a0,-290 # ffffffffc0207648 <commands+0xed8>
{
ffffffffc0202772:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0202774:	aa3fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202778 <check_vma_overlap.isra.0.part.1>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0202778:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc020277a:	00005697          	auipc	a3,0x5
ffffffffc020277e:	07668693          	addi	a3,a3,118 # ffffffffc02077f0 <commands+0x1080>
ffffffffc0202782:	00004617          	auipc	a2,0x4
ffffffffc0202786:	46e60613          	addi	a2,a2,1134 # ffffffffc0206bf0 <commands+0x480>
ffffffffc020278a:	07900593          	li	a1,121
ffffffffc020278e:	00005517          	auipc	a0,0x5
ffffffffc0202792:	08250513          	addi	a0,a0,130 # ffffffffc0207810 <commands+0x10a0>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0202796:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0202798:	a7ffd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020279c <mm_create>:
{
ffffffffc020279c:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020279e:	04000513          	li	a0,64
{
ffffffffc02027a2:	e022                	sd	s0,0(sp)
ffffffffc02027a4:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02027a6:	505000ef          	jal	ra,ffffffffc02034aa <kmalloc>
ffffffffc02027aa:	842a                	mv	s0,a0
    if (mm != NULL)
ffffffffc02027ac:	c515                	beqz	a0,ffffffffc02027d8 <mm_create+0x3c>
        if (swap_init_ok)
ffffffffc02027ae:	000aa797          	auipc	a5,0xaa
ffffffffc02027b2:	cda78793          	addi	a5,a5,-806 # ffffffffc02ac488 <swap_init_ok>
ffffffffc02027b6:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc02027b8:	e408                	sd	a0,8(s0)
ffffffffc02027ba:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02027bc:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02027c0:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02027c4:	02052023          	sw	zero,32(a0)
        if (swap_init_ok)
ffffffffc02027c8:	2781                	sext.w	a5,a5
ffffffffc02027ca:	ef81                	bnez	a5,ffffffffc02027e2 <mm_create+0x46>
            mm->sm_priv = NULL;
ffffffffc02027cc:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc02027d0:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc02027d4:	02043c23          	sd	zero,56(s0)
}
ffffffffc02027d8:	8522                	mv	a0,s0
ffffffffc02027da:	60a2                	ld	ra,8(sp)
ffffffffc02027dc:	6402                	ld	s0,0(sp)
ffffffffc02027de:	0141                	addi	sp,sp,16
ffffffffc02027e0:	8082                	ret
            swap_init_mm(mm);
ffffffffc02027e2:	628010ef          	jal	ra,ffffffffc0203e0a <swap_init_mm>
ffffffffc02027e6:	b7ed                	j	ffffffffc02027d0 <mm_create+0x34>

ffffffffc02027e8 <vma_create>:
{
ffffffffc02027e8:	1101                	addi	sp,sp,-32
ffffffffc02027ea:	e04a                	sd	s2,0(sp)
ffffffffc02027ec:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02027ee:	03000513          	li	a0,48
{
ffffffffc02027f2:	e822                	sd	s0,16(sp)
ffffffffc02027f4:	e426                	sd	s1,8(sp)
ffffffffc02027f6:	ec06                	sd	ra,24(sp)
ffffffffc02027f8:	84ae                	mv	s1,a1
ffffffffc02027fa:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02027fc:	4af000ef          	jal	ra,ffffffffc02034aa <kmalloc>
    if (vma != NULL)
ffffffffc0202800:	c509                	beqz	a0,ffffffffc020280a <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0202802:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202806:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202808:	cd00                	sw	s0,24(a0)
}
ffffffffc020280a:	60e2                	ld	ra,24(sp)
ffffffffc020280c:	6442                	ld	s0,16(sp)
ffffffffc020280e:	64a2                	ld	s1,8(sp)
ffffffffc0202810:	6902                	ld	s2,0(sp)
ffffffffc0202812:	6105                	addi	sp,sp,32
ffffffffc0202814:	8082                	ret

ffffffffc0202816 <find_vma>:
    if (mm != NULL)
ffffffffc0202816:	c51d                	beqz	a0,ffffffffc0202844 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0202818:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc020281a:	c781                	beqz	a5,ffffffffc0202822 <find_vma+0xc>
ffffffffc020281c:	6798                	ld	a4,8(a5)
ffffffffc020281e:	02e5f663          	bleu	a4,a1,ffffffffc020284a <find_vma+0x34>
            list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0202822:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc0202824:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc0202826:	00f50f63          	beq	a0,a5,ffffffffc0202844 <find_vma+0x2e>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc020282a:	fe87b703          	ld	a4,-24(a5)
ffffffffc020282e:	fee5ebe3          	bltu	a1,a4,ffffffffc0202824 <find_vma+0xe>
ffffffffc0202832:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202836:	fee5f7e3          	bleu	a4,a1,ffffffffc0202824 <find_vma+0xe>
                vma = le2vma(le, list_link);
ffffffffc020283a:	1781                	addi	a5,a5,-32
        if (vma != NULL)
ffffffffc020283c:	c781                	beqz	a5,ffffffffc0202844 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc020283e:	e91c                	sd	a5,16(a0)
}
ffffffffc0202840:	853e                	mv	a0,a5
ffffffffc0202842:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0202844:	4781                	li	a5,0
}
ffffffffc0202846:	853e                	mv	a0,a5
ffffffffc0202848:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc020284a:	6b98                	ld	a4,16(a5)
ffffffffc020284c:	fce5fbe3          	bleu	a4,a1,ffffffffc0202822 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0202850:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0202852:	b7fd                	j	ffffffffc0202840 <find_vma+0x2a>

ffffffffc0202854 <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202854:	6590                	ld	a2,8(a1)
ffffffffc0202856:	0105b803          	ld	a6,16(a1)
{
ffffffffc020285a:	1141                	addi	sp,sp,-16
ffffffffc020285c:	e406                	sd	ra,8(sp)
ffffffffc020285e:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202860:	01066863          	bltu	a2,a6,ffffffffc0202870 <insert_vma_struct+0x1c>
ffffffffc0202864:	a8b9                	j	ffffffffc02028c2 <insert_vma_struct+0x6e>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc0202866:	fe87b683          	ld	a3,-24(a5)
ffffffffc020286a:	04d66763          	bltu	a2,a3,ffffffffc02028b8 <insert_vma_struct+0x64>
ffffffffc020286e:	873e                	mv	a4,a5
ffffffffc0202870:	671c                	ld	a5,8(a4)
    while ((le = list_next(le)) != list)
ffffffffc0202872:	fef51ae3          	bne	a0,a5,ffffffffc0202866 <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc0202876:	02a70463          	beq	a4,a0,ffffffffc020289e <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc020287a:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc020287e:	fe873883          	ld	a7,-24(a4)
ffffffffc0202882:	08d8f063          	bleu	a3,a7,ffffffffc0202902 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202886:	04d66e63          	bltu	a2,a3,ffffffffc02028e2 <insert_vma_struct+0x8e>
    }
    if (le_next != list)
ffffffffc020288a:	00f50a63          	beq	a0,a5,ffffffffc020289e <insert_vma_struct+0x4a>
ffffffffc020288e:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202892:	0506e863          	bltu	a3,a6,ffffffffc02028e2 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0202896:	ff07b603          	ld	a2,-16(a5)
ffffffffc020289a:	02c6f263          	bleu	a2,a3,ffffffffc02028be <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc020289e:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc02028a0:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02028a2:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02028a6:	e390                	sd	a2,0(a5)
ffffffffc02028a8:	e710                	sd	a2,8(a4)
}
ffffffffc02028aa:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02028ac:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02028ae:	f198                	sd	a4,32(a1)
    mm->map_count++;
ffffffffc02028b0:	2685                	addiw	a3,a3,1
ffffffffc02028b2:	d114                	sw	a3,32(a0)
}
ffffffffc02028b4:	0141                	addi	sp,sp,16
ffffffffc02028b6:	8082                	ret
    if (le_prev != list)
ffffffffc02028b8:	fca711e3          	bne	a4,a0,ffffffffc020287a <insert_vma_struct+0x26>
ffffffffc02028bc:	bfd9                	j	ffffffffc0202892 <insert_vma_struct+0x3e>
ffffffffc02028be:	ebbff0ef          	jal	ra,ffffffffc0202778 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02028c2:	00005697          	auipc	a3,0x5
ffffffffc02028c6:	03e68693          	addi	a3,a3,62 # ffffffffc0207900 <commands+0x1190>
ffffffffc02028ca:	00004617          	auipc	a2,0x4
ffffffffc02028ce:	32660613          	addi	a2,a2,806 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02028d2:	07f00593          	li	a1,127
ffffffffc02028d6:	00005517          	auipc	a0,0x5
ffffffffc02028da:	f3a50513          	addi	a0,a0,-198 # ffffffffc0207810 <commands+0x10a0>
ffffffffc02028de:	939fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02028e2:	00005697          	auipc	a3,0x5
ffffffffc02028e6:	05e68693          	addi	a3,a3,94 # ffffffffc0207940 <commands+0x11d0>
ffffffffc02028ea:	00004617          	auipc	a2,0x4
ffffffffc02028ee:	30660613          	addi	a2,a2,774 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02028f2:	07800593          	li	a1,120
ffffffffc02028f6:	00005517          	auipc	a0,0x5
ffffffffc02028fa:	f1a50513          	addi	a0,a0,-230 # ffffffffc0207810 <commands+0x10a0>
ffffffffc02028fe:	919fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0202902:	00005697          	auipc	a3,0x5
ffffffffc0202906:	01e68693          	addi	a3,a3,30 # ffffffffc0207920 <commands+0x11b0>
ffffffffc020290a:	00004617          	auipc	a2,0x4
ffffffffc020290e:	2e660613          	addi	a2,a2,742 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202912:	07700593          	li	a1,119
ffffffffc0202916:	00005517          	auipc	a0,0x5
ffffffffc020291a:	efa50513          	addi	a0,a0,-262 # ffffffffc0207810 <commands+0x10a0>
ffffffffc020291e:	8f9fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202922 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0);
ffffffffc0202922:	591c                	lw	a5,48(a0)
{
ffffffffc0202924:	1141                	addi	sp,sp,-16
ffffffffc0202926:	e406                	sd	ra,8(sp)
ffffffffc0202928:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc020292a:	e78d                	bnez	a5,ffffffffc0202954 <mm_destroy+0x32>
ffffffffc020292c:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020292e:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc0202930:	00a40c63          	beq	s0,a0,ffffffffc0202948 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0202934:	6118                	ld	a4,0(a0)
ffffffffc0202936:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc0202938:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc020293a:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020293c:	e398                	sd	a4,0(a5)
ffffffffc020293e:	429000ef          	jal	ra,ffffffffc0203566 <kfree>
    return listelm->next;
ffffffffc0202942:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc0202944:	fea418e3          	bne	s0,a0,ffffffffc0202934 <mm_destroy+0x12>
    }
    kfree(mm); // kfree mm
ffffffffc0202948:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc020294a:	6402                	ld	s0,0(sp)
ffffffffc020294c:	60a2                	ld	ra,8(sp)
ffffffffc020294e:	0141                	addi	sp,sp,16
    kfree(mm); // kfree mm
ffffffffc0202950:	4170006f          	j	ffffffffc0203566 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0202954:	00005697          	auipc	a3,0x5
ffffffffc0202958:	00c68693          	addi	a3,a3,12 # ffffffffc0207960 <commands+0x11f0>
ffffffffc020295c:	00004617          	auipc	a2,0x4
ffffffffc0202960:	29460613          	addi	a2,a2,660 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202964:	0a300593          	li	a1,163
ffffffffc0202968:	00005517          	auipc	a0,0x5
ffffffffc020296c:	ea850513          	addi	a0,a0,-344 # ffffffffc0207810 <commands+0x10a0>
ffffffffc0202970:	8a7fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202974 <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0202974:	6785                	lui	a5,0x1
{
ffffffffc0202976:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0202978:	17fd                	addi	a5,a5,-1
ffffffffc020297a:	787d                	lui	a6,0xfffff
{
ffffffffc020297c:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020297e:	00f60433          	add	s0,a2,a5
{
ffffffffc0202982:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0202984:	942e                	add	s0,s0,a1
{
ffffffffc0202986:	fc06                	sd	ra,56(sp)
ffffffffc0202988:	f04a                	sd	s2,32(sp)
ffffffffc020298a:	ec4e                	sd	s3,24(sp)
ffffffffc020298c:	e852                	sd	s4,16(sp)
ffffffffc020298e:	e456                	sd	s5,8(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0202990:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end))
ffffffffc0202994:	002007b7          	lui	a5,0x200
ffffffffc0202998:	01047433          	and	s0,s0,a6
ffffffffc020299c:	06f4e363          	bltu	s1,a5,ffffffffc0202a02 <mm_map+0x8e>
ffffffffc02029a0:	0684f163          	bleu	s0,s1,ffffffffc0202a02 <mm_map+0x8e>
ffffffffc02029a4:	4785                	li	a5,1
ffffffffc02029a6:	07fe                	slli	a5,a5,0x1f
ffffffffc02029a8:	0487ed63          	bltu	a5,s0,ffffffffc0202a02 <mm_map+0x8e>
ffffffffc02029ac:	89aa                	mv	s3,a0
ffffffffc02029ae:	8a3a                	mv	s4,a4
ffffffffc02029b0:	8ab6                	mv	s5,a3
    {
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02029b2:	c931                	beqz	a0,ffffffffc0202a06 <mm_map+0x92>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
ffffffffc02029b4:	85a6                	mv	a1,s1
ffffffffc02029b6:	e61ff0ef          	jal	ra,ffffffffc0202816 <find_vma>
ffffffffc02029ba:	c501                	beqz	a0,ffffffffc02029c2 <mm_map+0x4e>
ffffffffc02029bc:	651c                	ld	a5,8(a0)
ffffffffc02029be:	0487e263          	bltu	a5,s0,ffffffffc0202a02 <mm_map+0x8e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02029c2:	03000513          	li	a0,48
ffffffffc02029c6:	2e5000ef          	jal	ra,ffffffffc02034aa <kmalloc>
ffffffffc02029ca:	892a                	mv	s2,a0
    {
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc02029cc:	5571                	li	a0,-4
    if (vma != NULL)
ffffffffc02029ce:	02090163          	beqz	s2,ffffffffc02029f0 <mm_map+0x7c>

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc02029d2:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc02029d4:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc02029d8:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc02029dc:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc02029e0:	85ca                	mv	a1,s2
ffffffffc02029e2:	e73ff0ef          	jal	ra,ffffffffc0202854 <insert_vma_struct>
    if (vma_store != NULL)
    {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc02029e6:	4501                	li	a0,0
    if (vma_store != NULL)
ffffffffc02029e8:	000a0463          	beqz	s4,ffffffffc02029f0 <mm_map+0x7c>
        *vma_store = vma;
ffffffffc02029ec:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc02029f0:	70e2                	ld	ra,56(sp)
ffffffffc02029f2:	7442                	ld	s0,48(sp)
ffffffffc02029f4:	74a2                	ld	s1,40(sp)
ffffffffc02029f6:	7902                	ld	s2,32(sp)
ffffffffc02029f8:	69e2                	ld	s3,24(sp)
ffffffffc02029fa:	6a42                	ld	s4,16(sp)
ffffffffc02029fc:	6aa2                	ld	s5,8(sp)
ffffffffc02029fe:	6121                	addi	sp,sp,64
ffffffffc0202a00:	8082                	ret
        return -E_INVAL;
ffffffffc0202a02:	5575                	li	a0,-3
ffffffffc0202a04:	b7f5                	j	ffffffffc02029f0 <mm_map+0x7c>
    assert(mm != NULL);
ffffffffc0202a06:	00005697          	auipc	a3,0x5
ffffffffc0202a0a:	f7268693          	addi	a3,a3,-142 # ffffffffc0207978 <commands+0x1208>
ffffffffc0202a0e:	00004617          	auipc	a2,0x4
ffffffffc0202a12:	1e260613          	addi	a2,a2,482 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202a16:	0b800593          	li	a1,184
ffffffffc0202a1a:	00005517          	auipc	a0,0x5
ffffffffc0202a1e:	df650513          	addi	a0,a0,-522 # ffffffffc0207810 <commands+0x10a0>
ffffffffc0202a22:	ff4fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202a26 <dup_mmap>:

int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc0202a26:	7139                	addi	sp,sp,-64
ffffffffc0202a28:	fc06                	sd	ra,56(sp)
ffffffffc0202a2a:	f822                	sd	s0,48(sp)
ffffffffc0202a2c:	f426                	sd	s1,40(sp)
ffffffffc0202a2e:	f04a                	sd	s2,32(sp)
ffffffffc0202a30:	ec4e                	sd	s3,24(sp)
ffffffffc0202a32:	e852                	sd	s4,16(sp)
ffffffffc0202a34:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0202a36:	c535                	beqz	a0,ffffffffc0202aa2 <dup_mmap+0x7c>
ffffffffc0202a38:	892a                	mv	s2,a0
ffffffffc0202a3a:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0202a3c:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0202a3e:	e59d                	bnez	a1,ffffffffc0202a6c <dup_mmap+0x46>
ffffffffc0202a40:	a08d                	j	ffffffffc0202aa2 <dup_mmap+0x7c>
        if (nvma == NULL)
        {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0202a42:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc0202a44:	0157b423          	sd	s5,8(a5) # 200008 <_binary_obj___user_exit_out_size+0x1f5588>
        insert_vma_struct(to, nvma);
ffffffffc0202a48:	854a                	mv	a0,s2
        vma->vm_end = vm_end;
ffffffffc0202a4a:	0147b823          	sd	s4,16(a5)
        vma->vm_flags = vm_flags;
ffffffffc0202a4e:	0137ac23          	sw	s3,24(a5)
        insert_vma_struct(to, nvma);
ffffffffc0202a52:	e03ff0ef          	jal	ra,ffffffffc0202854 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
ffffffffc0202a56:	ff043683          	ld	a3,-16(s0)
ffffffffc0202a5a:	fe843603          	ld	a2,-24(s0)
ffffffffc0202a5e:	6c8c                	ld	a1,24(s1)
ffffffffc0202a60:	01893503          	ld	a0,24(s2)
ffffffffc0202a64:	4701                	li	a4,0
ffffffffc0202a66:	e78ff0ef          	jal	ra,ffffffffc02020de <copy_range>
ffffffffc0202a6a:	e105                	bnez	a0,ffffffffc0202a8a <dup_mmap+0x64>
    return listelm->prev;
ffffffffc0202a6c:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list)
ffffffffc0202a6e:	02848863          	beq	s1,s0,ffffffffc0202a9e <dup_mmap+0x78>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202a72:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0202a76:	fe843a83          	ld	s5,-24(s0)
ffffffffc0202a7a:	ff043a03          	ld	s4,-16(s0)
ffffffffc0202a7e:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202a82:	229000ef          	jal	ra,ffffffffc02034aa <kmalloc>
ffffffffc0202a86:	87aa                	mv	a5,a0
    if (vma != NULL)
ffffffffc0202a88:	fd4d                	bnez	a0,ffffffffc0202a42 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc0202a8a:	5571                	li	a0,-4
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0202a8c:	70e2                	ld	ra,56(sp)
ffffffffc0202a8e:	7442                	ld	s0,48(sp)
ffffffffc0202a90:	74a2                	ld	s1,40(sp)
ffffffffc0202a92:	7902                	ld	s2,32(sp)
ffffffffc0202a94:	69e2                	ld	s3,24(sp)
ffffffffc0202a96:	6a42                	ld	s4,16(sp)
ffffffffc0202a98:	6aa2                	ld	s5,8(sp)
ffffffffc0202a9a:	6121                	addi	sp,sp,64
ffffffffc0202a9c:	8082                	ret
    return 0;
ffffffffc0202a9e:	4501                	li	a0,0
ffffffffc0202aa0:	b7f5                	j	ffffffffc0202a8c <dup_mmap+0x66>
    assert(to != NULL && from != NULL);
ffffffffc0202aa2:	00005697          	auipc	a3,0x5
ffffffffc0202aa6:	e1e68693          	addi	a3,a3,-482 # ffffffffc02078c0 <commands+0x1150>
ffffffffc0202aaa:	00004617          	auipc	a2,0x4
ffffffffc0202aae:	14660613          	addi	a2,a2,326 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202ab2:	0d400593          	li	a1,212
ffffffffc0202ab6:	00005517          	auipc	a0,0x5
ffffffffc0202aba:	d5a50513          	addi	a0,a0,-678 # ffffffffc0207810 <commands+0x10a0>
ffffffffc0202abe:	f58fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202ac2 <exit_mmap>:

void exit_mmap(struct mm_struct *mm)
{
ffffffffc0202ac2:	1101                	addi	sp,sp,-32
ffffffffc0202ac4:	ec06                	sd	ra,24(sp)
ffffffffc0202ac6:	e822                	sd	s0,16(sp)
ffffffffc0202ac8:	e426                	sd	s1,8(sp)
ffffffffc0202aca:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0202acc:	c531                	beqz	a0,ffffffffc0202b18 <exit_mmap+0x56>
ffffffffc0202ace:	591c                	lw	a5,48(a0)
ffffffffc0202ad0:	84aa                	mv	s1,a0
ffffffffc0202ad2:	e3b9                	bnez	a5,ffffffffc0202b18 <exit_mmap+0x56>
    return listelm->next;
ffffffffc0202ad4:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0202ad6:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list)
ffffffffc0202ada:	02850663          	beq	a0,s0,ffffffffc0202b06 <exit_mmap+0x44>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0202ade:	ff043603          	ld	a2,-16(s0)
ffffffffc0202ae2:	fe843583          	ld	a1,-24(s0)
ffffffffc0202ae6:	854a                	mv	a0,s2
ffffffffc0202ae8:	eccfe0ef          	jal	ra,ffffffffc02011b4 <unmap_range>
ffffffffc0202aec:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0202aee:	fe8498e3          	bne	s1,s0,ffffffffc0202ade <exit_mmap+0x1c>
ffffffffc0202af2:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list)
ffffffffc0202af4:	00848c63          	beq	s1,s0,ffffffffc0202b0c <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0202af8:	ff043603          	ld	a2,-16(s0)
ffffffffc0202afc:	fe843583          	ld	a1,-24(s0)
ffffffffc0202b00:	854a                	mv	a0,s2
ffffffffc0202b02:	fcafe0ef          	jal	ra,ffffffffc02012cc <exit_range>
ffffffffc0202b06:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0202b08:	fe8498e3          	bne	s1,s0,ffffffffc0202af8 <exit_mmap+0x36>
    }
}
ffffffffc0202b0c:	60e2                	ld	ra,24(sp)
ffffffffc0202b0e:	6442                	ld	s0,16(sp)
ffffffffc0202b10:	64a2                	ld	s1,8(sp)
ffffffffc0202b12:	6902                	ld	s2,0(sp)
ffffffffc0202b14:	6105                	addi	sp,sp,32
ffffffffc0202b16:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0202b18:	00005697          	auipc	a3,0x5
ffffffffc0202b1c:	dc868693          	addi	a3,a3,-568 # ffffffffc02078e0 <commands+0x1170>
ffffffffc0202b20:	00004617          	auipc	a2,0x4
ffffffffc0202b24:	0d060613          	addi	a2,a2,208 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202b28:	0ed00593          	li	a1,237
ffffffffc0202b2c:	00005517          	auipc	a0,0x5
ffffffffc0202b30:	ce450513          	addi	a0,a0,-796 # ffffffffc0207810 <commands+0x10a0>
ffffffffc0202b34:	ee2fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202b38 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0202b38:	7139                	addi	sp,sp,-64
ffffffffc0202b3a:	f822                	sd	s0,48(sp)
ffffffffc0202b3c:	f426                	sd	s1,40(sp)
ffffffffc0202b3e:	fc06                	sd	ra,56(sp)
ffffffffc0202b40:	f04a                	sd	s2,32(sp)
ffffffffc0202b42:	ec4e                	sd	s3,24(sp)
ffffffffc0202b44:	e852                	sd	s4,16(sp)
ffffffffc0202b46:	e456                	sd	s5,8(sp)
static void
check_vma_struct(void)
{
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc0202b48:	c55ff0ef          	jal	ra,ffffffffc020279c <mm_create>
    assert(mm != NULL);
ffffffffc0202b4c:	842a                	mv	s0,a0
ffffffffc0202b4e:	03200493          	li	s1,50
ffffffffc0202b52:	e919                	bnez	a0,ffffffffc0202b68 <vmm_init+0x30>
ffffffffc0202b54:	a989                	j	ffffffffc0202fa6 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0202b56:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202b58:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202b5a:	00052c23          	sw	zero,24(a0)
    int i;
    for (i = step1; i >= 1; i--)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0202b5e:	14ed                	addi	s1,s1,-5
ffffffffc0202b60:	8522                	mv	a0,s0
ffffffffc0202b62:	cf3ff0ef          	jal	ra,ffffffffc0202854 <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc0202b66:	c88d                	beqz	s1,ffffffffc0202b98 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202b68:	03000513          	li	a0,48
ffffffffc0202b6c:	13f000ef          	jal	ra,ffffffffc02034aa <kmalloc>
ffffffffc0202b70:	85aa                	mv	a1,a0
ffffffffc0202b72:	00248793          	addi	a5,s1,2
    if (vma != NULL)
ffffffffc0202b76:	f165                	bnez	a0,ffffffffc0202b56 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0202b78:	00005697          	auipc	a3,0x5
ffffffffc0202b7c:	02868693          	addi	a3,a3,40 # ffffffffc0207ba0 <commands+0x1430>
ffffffffc0202b80:	00004617          	auipc	a2,0x4
ffffffffc0202b84:	07060613          	addi	a2,a2,112 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202b88:	13100593          	li	a1,305
ffffffffc0202b8c:	00005517          	auipc	a0,0x5
ffffffffc0202b90:	c8450513          	addi	a0,a0,-892 # ffffffffc0207810 <commands+0x10a0>
ffffffffc0202b94:	e82fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    for (i = step1; i >= 1; i--)
ffffffffc0202b98:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc0202b9c:	1f900913          	li	s2,505
ffffffffc0202ba0:	a819                	j	ffffffffc0202bb6 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0202ba2:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202ba4:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202ba6:	00052c23          	sw	zero,24(a0)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0202baa:	0495                	addi	s1,s1,5
ffffffffc0202bac:	8522                	mv	a0,s0
ffffffffc0202bae:	ca7ff0ef          	jal	ra,ffffffffc0202854 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0202bb2:	03248a63          	beq	s1,s2,ffffffffc0202be6 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202bb6:	03000513          	li	a0,48
ffffffffc0202bba:	0f1000ef          	jal	ra,ffffffffc02034aa <kmalloc>
ffffffffc0202bbe:	85aa                	mv	a1,a0
ffffffffc0202bc0:	00248793          	addi	a5,s1,2
    if (vma != NULL)
ffffffffc0202bc4:	fd79                	bnez	a0,ffffffffc0202ba2 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0202bc6:	00005697          	auipc	a3,0x5
ffffffffc0202bca:	fda68693          	addi	a3,a3,-38 # ffffffffc0207ba0 <commands+0x1430>
ffffffffc0202bce:	00004617          	auipc	a2,0x4
ffffffffc0202bd2:	02260613          	addi	a2,a2,34 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202bd6:	13800593          	li	a1,312
ffffffffc0202bda:	00005517          	auipc	a0,0x5
ffffffffc0202bde:	c3650513          	addi	a0,a0,-970 # ffffffffc0207810 <commands+0x10a0>
ffffffffc0202be2:	e34fd0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0202be6:	6418                	ld	a4,8(s0)
ffffffffc0202be8:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0202bea:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0202bee:	2ee40063          	beq	s0,a4,ffffffffc0202ece <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202bf2:	fe873603          	ld	a2,-24(a4)
ffffffffc0202bf6:	ffe78693          	addi	a3,a5,-2
ffffffffc0202bfa:	24d61a63          	bne	a2,a3,ffffffffc0202e4e <vmm_init+0x316>
ffffffffc0202bfe:	ff073683          	ld	a3,-16(a4)
ffffffffc0202c02:	24f69663          	bne	a3,a5,ffffffffc0202e4e <vmm_init+0x316>
ffffffffc0202c06:	0795                	addi	a5,a5,5
ffffffffc0202c08:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i++)
ffffffffc0202c0a:	feb792e3          	bne	a5,a1,ffffffffc0202bee <vmm_init+0xb6>
ffffffffc0202c0e:	491d                	li	s2,7
ffffffffc0202c10:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0202c12:	1f900a93          	li	s5,505
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0202c16:	85a6                	mv	a1,s1
ffffffffc0202c18:	8522                	mv	a0,s0
ffffffffc0202c1a:	bfdff0ef          	jal	ra,ffffffffc0202816 <find_vma>
ffffffffc0202c1e:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0202c20:	30050763          	beqz	a0,ffffffffc0202f2e <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc0202c24:	00148593          	addi	a1,s1,1
ffffffffc0202c28:	8522                	mv	a0,s0
ffffffffc0202c2a:	bedff0ef          	jal	ra,ffffffffc0202816 <find_vma>
ffffffffc0202c2e:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0202c30:	2c050f63          	beqz	a0,ffffffffc0202f0e <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc0202c34:	85ca                	mv	a1,s2
ffffffffc0202c36:	8522                	mv	a0,s0
ffffffffc0202c38:	bdfff0ef          	jal	ra,ffffffffc0202816 <find_vma>
        assert(vma3 == NULL);
ffffffffc0202c3c:	2a051963          	bnez	a0,ffffffffc0202eee <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc0202c40:	00348593          	addi	a1,s1,3
ffffffffc0202c44:	8522                	mv	a0,s0
ffffffffc0202c46:	bd1ff0ef          	jal	ra,ffffffffc0202816 <find_vma>
        assert(vma4 == NULL);
ffffffffc0202c4a:	32051263          	bnez	a0,ffffffffc0202f6e <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0202c4e:	00448593          	addi	a1,s1,4
ffffffffc0202c52:	8522                	mv	a0,s0
ffffffffc0202c54:	bc3ff0ef          	jal	ra,ffffffffc0202816 <find_vma>
        assert(vma5 == NULL);
ffffffffc0202c58:	2e051b63          	bnez	a0,ffffffffc0202f4e <vmm_init+0x416>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0202c5c:	008a3783          	ld	a5,8(s4)
ffffffffc0202c60:	20979763          	bne	a5,s1,ffffffffc0202e6e <vmm_init+0x336>
ffffffffc0202c64:	010a3783          	ld	a5,16(s4)
ffffffffc0202c68:	21279363          	bne	a5,s2,ffffffffc0202e6e <vmm_init+0x336>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0202c6c:	0089b783          	ld	a5,8(s3)
ffffffffc0202c70:	20979f63          	bne	a5,s1,ffffffffc0202e8e <vmm_init+0x356>
ffffffffc0202c74:	0109b783          	ld	a5,16(s3)
ffffffffc0202c78:	21279b63          	bne	a5,s2,ffffffffc0202e8e <vmm_init+0x356>
ffffffffc0202c7c:	0495                	addi	s1,s1,5
ffffffffc0202c7e:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0202c80:	f9549be3          	bne	s1,s5,ffffffffc0202c16 <vmm_init+0xde>
ffffffffc0202c84:	4491                	li	s1,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc0202c86:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc0202c88:	85a6                	mv	a1,s1
ffffffffc0202c8a:	8522                	mv	a0,s0
ffffffffc0202c8c:	b8bff0ef          	jal	ra,ffffffffc0202816 <find_vma>
ffffffffc0202c90:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL)
ffffffffc0202c94:	c90d                	beqz	a0,ffffffffc0202cc6 <vmm_init+0x18e>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc0202c96:	6914                	ld	a3,16(a0)
ffffffffc0202c98:	6510                	ld	a2,8(a0)
ffffffffc0202c9a:	00005517          	auipc	a0,0x5
ffffffffc0202c9e:	dee50513          	addi	a0,a0,-530 # ffffffffc0207a88 <commands+0x1318>
ffffffffc0202ca2:	c2efd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0202ca6:	00005697          	auipc	a3,0x5
ffffffffc0202caa:	e0a68693          	addi	a3,a3,-502 # ffffffffc0207ab0 <commands+0x1340>
ffffffffc0202cae:	00004617          	auipc	a2,0x4
ffffffffc0202cb2:	f4260613          	addi	a2,a2,-190 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202cb6:	15e00593          	li	a1,350
ffffffffc0202cba:	00005517          	auipc	a0,0x5
ffffffffc0202cbe:	b5650513          	addi	a0,a0,-1194 # ffffffffc0207810 <commands+0x10a0>
ffffffffc0202cc2:	d54fd0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0202cc6:	14fd                	addi	s1,s1,-1
    for (i = 4; i >= 0; i--)
ffffffffc0202cc8:	fd2490e3          	bne	s1,s2,ffffffffc0202c88 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0202ccc:	8522                	mv	a0,s0
ffffffffc0202cce:	c55ff0ef          	jal	ra,ffffffffc0202922 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0202cd2:	00005517          	auipc	a0,0x5
ffffffffc0202cd6:	df650513          	addi	a0,a0,-522 # ffffffffc0207ac8 <commands+0x1358>
ffffffffc0202cda:	bf6fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void)
{
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0202cde:	a62fe0ef          	jal	ra,ffffffffc0200f40 <nr_free_pages>
ffffffffc0202ce2:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc0202ce4:	ab9ff0ef          	jal	ra,ffffffffc020279c <mm_create>
ffffffffc0202ce8:	000aa797          	auipc	a5,0xaa
ffffffffc0202cec:	80a7b023          	sd	a0,-2048(a5) # ffffffffc02ac4e8 <check_mm_struct>
ffffffffc0202cf0:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc0202cf2:	36050663          	beqz	a0,ffffffffc020305e <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202cf6:	000a9797          	auipc	a5,0xa9
ffffffffc0202cfa:	76a78793          	addi	a5,a5,1898 # ffffffffc02ac460 <boot_pgdir>
ffffffffc0202cfe:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0202d02:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202d06:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0202d0a:	2c079e63          	bnez	a5,ffffffffc0202fe6 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202d0e:	03000513          	li	a0,48
ffffffffc0202d12:	798000ef          	jal	ra,ffffffffc02034aa <kmalloc>
ffffffffc0202d16:	842a                	mv	s0,a0
    if (vma != NULL)
ffffffffc0202d18:	18050b63          	beqz	a0,ffffffffc0202eae <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc0202d1c:	002007b7          	lui	a5,0x200
ffffffffc0202d20:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc0202d22:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0202d24:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0202d26:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0202d28:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0202d2a:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc0202d2e:	b27ff0ef          	jal	ra,ffffffffc0202854 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0202d32:	10000593          	li	a1,256
ffffffffc0202d36:	8526                	mv	a0,s1
ffffffffc0202d38:	adfff0ef          	jal	ra,ffffffffc0202816 <find_vma>
ffffffffc0202d3c:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i++)
ffffffffc0202d40:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0202d44:	2ca41163          	bne	s0,a0,ffffffffc0203006 <vmm_init+0x4ce>
    {
        *(char *)(addr + i) = i;
ffffffffc0202d48:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f5580>
        sum += i;
ffffffffc0202d4c:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i++)
ffffffffc0202d4e:	fee79de3          	bne	a5,a4,ffffffffc0202d48 <vmm_init+0x210>
        sum += i;
ffffffffc0202d52:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i++)
ffffffffc0202d54:	10000793          	li	a5,256
        sum += i;
ffffffffc0202d58:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x8222>
    }
    for (i = 0; i < 100; i++)
ffffffffc0202d5c:	16400613          	li	a2,356
    {
        sum -= *(char *)(addr + i);
ffffffffc0202d60:	0007c683          	lbu	a3,0(a5)
ffffffffc0202d64:	0785                	addi	a5,a5,1
ffffffffc0202d66:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i++)
ffffffffc0202d68:	fec79ce3          	bne	a5,a2,ffffffffc0202d60 <vmm_init+0x228>
    }

    assert(sum == 0);
ffffffffc0202d6c:	2c071963          	bnez	a4,ffffffffc020303e <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d70:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202d74:	000a9a97          	auipc	s5,0xa9
ffffffffc0202d78:	6f4a8a93          	addi	s5,s5,1780 # ffffffffc02ac468 <npage>
ffffffffc0202d7c:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d80:	078a                	slli	a5,a5,0x2
ffffffffc0202d82:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202d84:	20e7f563          	bleu	a4,a5,ffffffffc0202f8e <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d88:	00006697          	auipc	a3,0x6
ffffffffc0202d8c:	f4868693          	addi	a3,a3,-184 # ffffffffc0208cd0 <nbase>
ffffffffc0202d90:	0006ba03          	ld	s4,0(a3)
ffffffffc0202d94:	414786b3          	sub	a3,a5,s4
ffffffffc0202d98:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0202d9a:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202d9c:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0202d9e:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0202da0:	83b1                	srli	a5,a5,0xc
ffffffffc0202da2:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202da4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202da6:	28e7f063          	bleu	a4,a5,ffffffffc0203026 <vmm_init+0x4ee>
ffffffffc0202daa:	000a9797          	auipc	a5,0xa9
ffffffffc0202dae:	71678793          	addi	a5,a5,1814 # ffffffffc02ac4c0 <va_pa_offset>
ffffffffc0202db2:	6380                	ld	s0,0(a5)

    pde_t *pd1 = pgdir, *pd0 = page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0202db4:	4581                	li	a1,0
ffffffffc0202db6:	854a                	mv	a0,s2
ffffffffc0202db8:	9436                	add	s0,s0,a3
ffffffffc0202dba:	f68fe0ef          	jal	ra,ffffffffc0201522 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202dbe:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202dc0:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202dc4:	078a                	slli	a5,a5,0x2
ffffffffc0202dc6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202dc8:	1ce7f363          	bleu	a4,a5,ffffffffc0202f8e <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0202dcc:	000a9417          	auipc	s0,0xa9
ffffffffc0202dd0:	70440413          	addi	s0,s0,1796 # ffffffffc02ac4d0 <pages>
ffffffffc0202dd4:	6008                	ld	a0,0(s0)
ffffffffc0202dd6:	414787b3          	sub	a5,a5,s4
ffffffffc0202dda:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0202ddc:	953e                	add	a0,a0,a5
ffffffffc0202dde:	4585                	li	a1,1
ffffffffc0202de0:	91afe0ef          	jal	ra,ffffffffc0200efa <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202de4:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202de8:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202dec:	078a                	slli	a5,a5,0x2
ffffffffc0202dee:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202df0:	18e7ff63          	bleu	a4,a5,ffffffffc0202f8e <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0202df4:	6008                	ld	a0,0(s0)
ffffffffc0202df6:	414787b3          	sub	a5,a5,s4
ffffffffc0202dfa:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202dfc:	4585                	li	a1,1
ffffffffc0202dfe:	953e                	add	a0,a0,a5
ffffffffc0202e00:	8fafe0ef          	jal	ra,ffffffffc0200efa <free_pages>
    pgdir[0] = 0;
ffffffffc0202e04:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0202e08:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0202e0c:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc0202e10:	8526                	mv	a0,s1
ffffffffc0202e12:	b11ff0ef          	jal	ra,ffffffffc0202922 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0202e16:	000a9797          	auipc	a5,0xa9
ffffffffc0202e1a:	6c07b923          	sd	zero,1746(a5) # ffffffffc02ac4e8 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202e1e:	922fe0ef          	jal	ra,ffffffffc0200f40 <nr_free_pages>
ffffffffc0202e22:	1aa99263          	bne	s3,a0,ffffffffc0202fc6 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0202e26:	00005517          	auipc	a0,0x5
ffffffffc0202e2a:	d4250513          	addi	a0,a0,-702 # ffffffffc0207b68 <commands+0x13f8>
ffffffffc0202e2e:	aa2fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0202e32:	7442                	ld	s0,48(sp)
ffffffffc0202e34:	70e2                	ld	ra,56(sp)
ffffffffc0202e36:	74a2                	ld	s1,40(sp)
ffffffffc0202e38:	7902                	ld	s2,32(sp)
ffffffffc0202e3a:	69e2                	ld	s3,24(sp)
ffffffffc0202e3c:	6a42                	ld	s4,16(sp)
ffffffffc0202e3e:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202e40:	00005517          	auipc	a0,0x5
ffffffffc0202e44:	d4850513          	addi	a0,a0,-696 # ffffffffc0207b88 <commands+0x1418>
}
ffffffffc0202e48:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202e4a:	a86fd06f          	j	ffffffffc02000d0 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202e4e:	00005697          	auipc	a3,0x5
ffffffffc0202e52:	b5268693          	addi	a3,a3,-1198 # ffffffffc02079a0 <commands+0x1230>
ffffffffc0202e56:	00004617          	auipc	a2,0x4
ffffffffc0202e5a:	d9a60613          	addi	a2,a2,-614 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202e5e:	14200593          	li	a1,322
ffffffffc0202e62:	00005517          	auipc	a0,0x5
ffffffffc0202e66:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0207810 <commands+0x10a0>
ffffffffc0202e6a:	bacfd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0202e6e:	00005697          	auipc	a3,0x5
ffffffffc0202e72:	bba68693          	addi	a3,a3,-1094 # ffffffffc0207a28 <commands+0x12b8>
ffffffffc0202e76:	00004617          	auipc	a2,0x4
ffffffffc0202e7a:	d7a60613          	addi	a2,a2,-646 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202e7e:	15300593          	li	a1,339
ffffffffc0202e82:	00005517          	auipc	a0,0x5
ffffffffc0202e86:	98e50513          	addi	a0,a0,-1650 # ffffffffc0207810 <commands+0x10a0>
ffffffffc0202e8a:	b8cfd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0202e8e:	00005697          	auipc	a3,0x5
ffffffffc0202e92:	bca68693          	addi	a3,a3,-1078 # ffffffffc0207a58 <commands+0x12e8>
ffffffffc0202e96:	00004617          	auipc	a2,0x4
ffffffffc0202e9a:	d5a60613          	addi	a2,a2,-678 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202e9e:	15400593          	li	a1,340
ffffffffc0202ea2:	00005517          	auipc	a0,0x5
ffffffffc0202ea6:	96e50513          	addi	a0,a0,-1682 # ffffffffc0207810 <commands+0x10a0>
ffffffffc0202eaa:	b6cfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(vma != NULL);
ffffffffc0202eae:	00005697          	auipc	a3,0x5
ffffffffc0202eb2:	cf268693          	addi	a3,a3,-782 # ffffffffc0207ba0 <commands+0x1430>
ffffffffc0202eb6:	00004617          	auipc	a2,0x4
ffffffffc0202eba:	d3a60613          	addi	a2,a2,-710 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202ebe:	17600593          	li	a1,374
ffffffffc0202ec2:	00005517          	auipc	a0,0x5
ffffffffc0202ec6:	94e50513          	addi	a0,a0,-1714 # ffffffffc0207810 <commands+0x10a0>
ffffffffc0202eca:	b4cfd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0202ece:	00005697          	auipc	a3,0x5
ffffffffc0202ed2:	aba68693          	addi	a3,a3,-1350 # ffffffffc0207988 <commands+0x1218>
ffffffffc0202ed6:	00004617          	auipc	a2,0x4
ffffffffc0202eda:	d1a60613          	addi	a2,a2,-742 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202ede:	14000593          	li	a1,320
ffffffffc0202ee2:	00005517          	auipc	a0,0x5
ffffffffc0202ee6:	92e50513          	addi	a0,a0,-1746 # ffffffffc0207810 <commands+0x10a0>
ffffffffc0202eea:	b2cfd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma3 == NULL);
ffffffffc0202eee:	00005697          	auipc	a3,0x5
ffffffffc0202ef2:	b0a68693          	addi	a3,a3,-1270 # ffffffffc02079f8 <commands+0x1288>
ffffffffc0202ef6:	00004617          	auipc	a2,0x4
ffffffffc0202efa:	cfa60613          	addi	a2,a2,-774 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202efe:	14d00593          	li	a1,333
ffffffffc0202f02:	00005517          	auipc	a0,0x5
ffffffffc0202f06:	90e50513          	addi	a0,a0,-1778 # ffffffffc0207810 <commands+0x10a0>
ffffffffc0202f0a:	b0cfd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma2 != NULL);
ffffffffc0202f0e:	00005697          	auipc	a3,0x5
ffffffffc0202f12:	ada68693          	addi	a3,a3,-1318 # ffffffffc02079e8 <commands+0x1278>
ffffffffc0202f16:	00004617          	auipc	a2,0x4
ffffffffc0202f1a:	cda60613          	addi	a2,a2,-806 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202f1e:	14b00593          	li	a1,331
ffffffffc0202f22:	00005517          	auipc	a0,0x5
ffffffffc0202f26:	8ee50513          	addi	a0,a0,-1810 # ffffffffc0207810 <commands+0x10a0>
ffffffffc0202f2a:	aecfd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma1 != NULL);
ffffffffc0202f2e:	00005697          	auipc	a3,0x5
ffffffffc0202f32:	aaa68693          	addi	a3,a3,-1366 # ffffffffc02079d8 <commands+0x1268>
ffffffffc0202f36:	00004617          	auipc	a2,0x4
ffffffffc0202f3a:	cba60613          	addi	a2,a2,-838 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202f3e:	14900593          	li	a1,329
ffffffffc0202f42:	00005517          	auipc	a0,0x5
ffffffffc0202f46:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0207810 <commands+0x10a0>
ffffffffc0202f4a:	accfd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma5 == NULL);
ffffffffc0202f4e:	00005697          	auipc	a3,0x5
ffffffffc0202f52:	aca68693          	addi	a3,a3,-1334 # ffffffffc0207a18 <commands+0x12a8>
ffffffffc0202f56:	00004617          	auipc	a2,0x4
ffffffffc0202f5a:	c9a60613          	addi	a2,a2,-870 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202f5e:	15100593          	li	a1,337
ffffffffc0202f62:	00005517          	auipc	a0,0x5
ffffffffc0202f66:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0207810 <commands+0x10a0>
ffffffffc0202f6a:	aacfd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma4 == NULL);
ffffffffc0202f6e:	00005697          	auipc	a3,0x5
ffffffffc0202f72:	a9a68693          	addi	a3,a3,-1382 # ffffffffc0207a08 <commands+0x1298>
ffffffffc0202f76:	00004617          	auipc	a2,0x4
ffffffffc0202f7a:	c7a60613          	addi	a2,a2,-902 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202f7e:	14f00593          	li	a1,335
ffffffffc0202f82:	00005517          	auipc	a0,0x5
ffffffffc0202f86:	88e50513          	addi	a0,a0,-1906 # ffffffffc0207810 <commands+0x10a0>
ffffffffc0202f8a:	a8cfd0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202f8e:	00004617          	auipc	a2,0x4
ffffffffc0202f92:	07260613          	addi	a2,a2,114 # ffffffffc0207000 <commands+0x890>
ffffffffc0202f96:	06200593          	li	a1,98
ffffffffc0202f9a:	00004517          	auipc	a0,0x4
ffffffffc0202f9e:	08650513          	addi	a0,a0,134 # ffffffffc0207020 <commands+0x8b0>
ffffffffc0202fa2:	a74fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(mm != NULL);
ffffffffc0202fa6:	00005697          	auipc	a3,0x5
ffffffffc0202faa:	9d268693          	addi	a3,a3,-1582 # ffffffffc0207978 <commands+0x1208>
ffffffffc0202fae:	00004617          	auipc	a2,0x4
ffffffffc0202fb2:	c4260613          	addi	a2,a2,-958 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202fb6:	12900593          	li	a1,297
ffffffffc0202fba:	00005517          	auipc	a0,0x5
ffffffffc0202fbe:	85650513          	addi	a0,a0,-1962 # ffffffffc0207810 <commands+0x10a0>
ffffffffc0202fc2:	a54fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202fc6:	00005697          	auipc	a3,0x5
ffffffffc0202fca:	b7a68693          	addi	a3,a3,-1158 # ffffffffc0207b40 <commands+0x13d0>
ffffffffc0202fce:	00004617          	auipc	a2,0x4
ffffffffc0202fd2:	c2260613          	addi	a2,a2,-990 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202fd6:	19600593          	li	a1,406
ffffffffc0202fda:	00005517          	auipc	a0,0x5
ffffffffc0202fde:	83650513          	addi	a0,a0,-1994 # ffffffffc0207810 <commands+0x10a0>
ffffffffc0202fe2:	a34fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0202fe6:	00005697          	auipc	a3,0x5
ffffffffc0202fea:	b1a68693          	addi	a3,a3,-1254 # ffffffffc0207b00 <commands+0x1390>
ffffffffc0202fee:	00004617          	auipc	a2,0x4
ffffffffc0202ff2:	c0260613          	addi	a2,a2,-1022 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0202ff6:	17300593          	li	a1,371
ffffffffc0202ffa:	00005517          	auipc	a0,0x5
ffffffffc0202ffe:	81650513          	addi	a0,a0,-2026 # ffffffffc0207810 <commands+0x10a0>
ffffffffc0203002:	a14fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203006:	00005697          	auipc	a3,0x5
ffffffffc020300a:	b0a68693          	addi	a3,a3,-1270 # ffffffffc0207b10 <commands+0x13a0>
ffffffffc020300e:	00004617          	auipc	a2,0x4
ffffffffc0203012:	be260613          	addi	a2,a2,-1054 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203016:	17b00593          	li	a1,379
ffffffffc020301a:	00004517          	auipc	a0,0x4
ffffffffc020301e:	7f650513          	addi	a0,a0,2038 # ffffffffc0207810 <commands+0x10a0>
ffffffffc0203022:	9f4fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203026:	00004617          	auipc	a2,0x4
ffffffffc020302a:	fa260613          	addi	a2,a2,-94 # ffffffffc0206fc8 <commands+0x858>
ffffffffc020302e:	06900593          	li	a1,105
ffffffffc0203032:	00004517          	auipc	a0,0x4
ffffffffc0203036:	fee50513          	addi	a0,a0,-18 # ffffffffc0207020 <commands+0x8b0>
ffffffffc020303a:	9dcfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(sum == 0);
ffffffffc020303e:	00005697          	auipc	a3,0x5
ffffffffc0203042:	af268693          	addi	a3,a3,-1294 # ffffffffc0207b30 <commands+0x13c0>
ffffffffc0203046:	00004617          	auipc	a2,0x4
ffffffffc020304a:	baa60613          	addi	a2,a2,-1110 # ffffffffc0206bf0 <commands+0x480>
ffffffffc020304e:	18900593          	li	a1,393
ffffffffc0203052:	00004517          	auipc	a0,0x4
ffffffffc0203056:	7be50513          	addi	a0,a0,1982 # ffffffffc0207810 <commands+0x10a0>
ffffffffc020305a:	9bcfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc020305e:	00005697          	auipc	a3,0x5
ffffffffc0203062:	a8a68693          	addi	a3,a3,-1398 # ffffffffc0207ae8 <commands+0x1378>
ffffffffc0203066:	00004617          	auipc	a2,0x4
ffffffffc020306a:	b8a60613          	addi	a2,a2,-1142 # ffffffffc0206bf0 <commands+0x480>
ffffffffc020306e:	16f00593          	li	a1,367
ffffffffc0203072:	00004517          	auipc	a0,0x4
ffffffffc0203076:	79e50513          	addi	a0,a0,1950 # ffffffffc0207810 <commands+0x10a0>
ffffffffc020307a:	99cfd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020307e <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr)
{
ffffffffc020307e:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    // try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203080:	85b2                	mv	a1,a2
{
ffffffffc0203082:	f022                	sd	s0,32(sp)
ffffffffc0203084:	ec26                	sd	s1,24(sp)
ffffffffc0203086:	f406                	sd	ra,40(sp)
ffffffffc0203088:	e84a                	sd	s2,16(sp)
ffffffffc020308a:	8432                	mv	s0,a2
ffffffffc020308c:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020308e:	f88ff0ef          	jal	ra,ffffffffc0202816 <find_vma>

    pgfault_num++;
ffffffffc0203092:	000a9797          	auipc	a5,0xa9
ffffffffc0203096:	3de78793          	addi	a5,a5,990 # ffffffffc02ac470 <pgfault_num>
ffffffffc020309a:	439c                	lw	a5,0(a5)
ffffffffc020309c:	2785                	addiw	a5,a5,1
ffffffffc020309e:	000a9717          	auipc	a4,0xa9
ffffffffc02030a2:	3cf72923          	sw	a5,978(a4) # ffffffffc02ac470 <pgfault_num>
    // If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr)
ffffffffc02030a6:	c551                	beqz	a0,ffffffffc0203132 <do_pgfault+0xb4>
ffffffffc02030a8:	651c                	ld	a5,8(a0)
ffffffffc02030aa:	08f46463          	bltu	s0,a5,ffffffffc0203132 <do_pgfault+0xb4>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE)
ffffffffc02030ae:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02030b0:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE)
ffffffffc02030b2:	8b89                	andi	a5,a5,2
ffffffffc02030b4:	efb1                	bnez	a5,ffffffffc0203110 <do_pgfault+0x92>
    {
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02030b6:	767d                	lui	a2,0xfffff

    pte_t *ptep = NULL;

    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL)
ffffffffc02030b8:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02030ba:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL)
ffffffffc02030bc:	85a2                	mv	a1,s0
ffffffffc02030be:	4605                	li	a2,1
ffffffffc02030c0:	ec1fd0ef          	jal	ra,ffffffffc0200f80 <get_pte>
ffffffffc02030c4:	c941                	beqz	a0,ffffffffc0203154 <do_pgfault+0xd6>
    {
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }

    if (*ptep == 0)
ffffffffc02030c6:	610c                	ld	a1,0(a0)
ffffffffc02030c8:	c5b1                	beqz	a1,ffffffffc0203114 <do_pgfault+0x96>
         *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
         *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
         *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
         *    swap_map_swappable ： 设置页面可交换
         */
        if (swap_init_ok)
ffffffffc02030ca:	000a9797          	auipc	a5,0xa9
ffffffffc02030ce:	3be78793          	addi	a5,a5,958 # ffffffffc02ac488 <swap_init_ok>
ffffffffc02030d2:	439c                	lw	a5,0(a5)
ffffffffc02030d4:	2781                	sext.w	a5,a5
ffffffffc02030d6:	c7bd                	beqz	a5,ffffffffc0203144 <do_pgfault+0xc6>
            //(2) According to the mm,
            // addr AND page, setup the
            // map of phy addr <--->
            // logical addr
            //(3) make the page swappable.
            swap_in(mm, addr, &page);
ffffffffc02030d8:	85a2                	mv	a1,s0
ffffffffc02030da:	0030                	addi	a2,sp,8
ffffffffc02030dc:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc02030de:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc02030e0:	65f000ef          	jal	ra,ffffffffc0203f3e <swap_in>
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc02030e4:	65a2                	ld	a1,8(sp)
ffffffffc02030e6:	6c88                	ld	a0,24(s1)
ffffffffc02030e8:	86ca                	mv	a3,s2
ffffffffc02030ea:	8622                	mv	a2,s0
ffffffffc02030ec:	caafe0ef          	jal	ra,ffffffffc0201596 <page_insert>
            swap_map_swappable(mm, addr, page, 1);
ffffffffc02030f0:	6622                	ld	a2,8(sp)
ffffffffc02030f2:	4685                	li	a3,1
ffffffffc02030f4:	85a2                	mv	a1,s0
ffffffffc02030f6:	8526                	mv	a0,s1
ffffffffc02030f8:	523000ef          	jal	ra,ffffffffc0203e1a <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc02030fc:	6722                	ld	a4,8(sp)
        {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
    }
    ret = 0;
ffffffffc02030fe:	4781                	li	a5,0
            page->pra_vaddr = addr;
ffffffffc0203100:	ff00                	sd	s0,56(a4)
failed:
    return ret;
}
ffffffffc0203102:	70a2                	ld	ra,40(sp)
ffffffffc0203104:	7402                	ld	s0,32(sp)
ffffffffc0203106:	64e2                	ld	s1,24(sp)
ffffffffc0203108:	6942                	ld	s2,16(sp)
ffffffffc020310a:	853e                	mv	a0,a5
ffffffffc020310c:	6145                	addi	sp,sp,48
ffffffffc020310e:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0203110:	495d                	li	s2,23
ffffffffc0203112:	b755                	j	ffffffffc02030b6 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL)
ffffffffc0203114:	6c88                	ld	a0,24(s1)
ffffffffc0203116:	864a                	mv	a2,s2
ffffffffc0203118:	85a2                	mv	a1,s0
ffffffffc020311a:	9e2ff0ef          	jal	ra,ffffffffc02022fc <pgdir_alloc_page>
    ret = 0;
ffffffffc020311e:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL)
ffffffffc0203120:	f16d                	bnez	a0,ffffffffc0203102 <do_pgfault+0x84>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203122:	00004517          	auipc	a0,0x4
ffffffffc0203126:	74e50513          	addi	a0,a0,1870 # ffffffffc0207870 <commands+0x1100>
ffffffffc020312a:	fa7fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc020312e:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203130:	bfc9                	j	ffffffffc0203102 <do_pgfault+0x84>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203132:	85a2                	mv	a1,s0
ffffffffc0203134:	00004517          	auipc	a0,0x4
ffffffffc0203138:	6ec50513          	addi	a0,a0,1772 # ffffffffc0207820 <commands+0x10b0>
ffffffffc020313c:	f95fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = -E_INVAL;
ffffffffc0203140:	57f5                	li	a5,-3
        goto failed;
ffffffffc0203142:	b7c1                	j	ffffffffc0203102 <do_pgfault+0x84>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203144:	00004517          	auipc	a0,0x4
ffffffffc0203148:	75450513          	addi	a0,a0,1876 # ffffffffc0207898 <commands+0x1128>
ffffffffc020314c:	f85fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203150:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203152:	bf45                	j	ffffffffc0203102 <do_pgfault+0x84>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0203154:	00004517          	auipc	a0,0x4
ffffffffc0203158:	6fc50513          	addi	a0,a0,1788 # ffffffffc0207850 <commands+0x10e0>
ffffffffc020315c:	f75fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203160:	57f1                	li	a5,-4
        goto failed;
ffffffffc0203162:	b745                	j	ffffffffc0203102 <do_pgfault+0x84>

ffffffffc0203164 <user_mem_check>:

bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
ffffffffc0203164:	7179                	addi	sp,sp,-48
ffffffffc0203166:	f022                	sd	s0,32(sp)
ffffffffc0203168:	f406                	sd	ra,40(sp)
ffffffffc020316a:	ec26                	sd	s1,24(sp)
ffffffffc020316c:	e84a                	sd	s2,16(sp)
ffffffffc020316e:	e44e                	sd	s3,8(sp)
ffffffffc0203170:	e052                	sd	s4,0(sp)
ffffffffc0203172:	842e                	mv	s0,a1
    if (mm != NULL)
ffffffffc0203174:	c135                	beqz	a0,ffffffffc02031d8 <user_mem_check+0x74>
    {
        if (!USER_ACCESS(addr, addr + len))
ffffffffc0203176:	002007b7          	lui	a5,0x200
ffffffffc020317a:	04f5e663          	bltu	a1,a5,ffffffffc02031c6 <user_mem_check+0x62>
ffffffffc020317e:	00c584b3          	add	s1,a1,a2
ffffffffc0203182:	0495f263          	bleu	s1,a1,ffffffffc02031c6 <user_mem_check+0x62>
ffffffffc0203186:	4785                	li	a5,1
ffffffffc0203188:	07fe                	slli	a5,a5,0x1f
ffffffffc020318a:	0297ee63          	bltu	a5,s1,ffffffffc02031c6 <user_mem_check+0x62>
ffffffffc020318e:	892a                	mv	s2,a0
ffffffffc0203190:	89b6                	mv	s3,a3
            {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203192:	6a05                	lui	s4,0x1
ffffffffc0203194:	a821                	j	ffffffffc02031ac <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203196:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE)
ffffffffc020319a:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc020319c:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc020319e:	c685                	beqz	a3,ffffffffc02031c6 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc02031a0:	c399                	beqz	a5,ffffffffc02031a6 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE)
ffffffffc02031a2:	02e46263          	bltu	s0,a4,ffffffffc02031c6 <user_mem_check+0x62>
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc02031a6:	6900                	ld	s0,16(a0)
        while (start < end)
ffffffffc02031a8:	04947663          	bleu	s1,s0,ffffffffc02031f4 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
ffffffffc02031ac:	85a2                	mv	a1,s0
ffffffffc02031ae:	854a                	mv	a0,s2
ffffffffc02031b0:	e66ff0ef          	jal	ra,ffffffffc0202816 <find_vma>
ffffffffc02031b4:	c909                	beqz	a0,ffffffffc02031c6 <user_mem_check+0x62>
ffffffffc02031b6:	6518                	ld	a4,8(a0)
ffffffffc02031b8:	00e46763          	bltu	s0,a4,ffffffffc02031c6 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc02031bc:	4d1c                	lw	a5,24(a0)
ffffffffc02031be:	fc099ce3          	bnez	s3,ffffffffc0203196 <user_mem_check+0x32>
ffffffffc02031c2:	8b85                	andi	a5,a5,1
ffffffffc02031c4:	f3ed                	bnez	a5,ffffffffc02031a6 <user_mem_check+0x42>
            return 0;
ffffffffc02031c6:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc02031c8:	70a2                	ld	ra,40(sp)
ffffffffc02031ca:	7402                	ld	s0,32(sp)
ffffffffc02031cc:	64e2                	ld	s1,24(sp)
ffffffffc02031ce:	6942                	ld	s2,16(sp)
ffffffffc02031d0:	69a2                	ld	s3,8(sp)
ffffffffc02031d2:	6a02                	ld	s4,0(sp)
ffffffffc02031d4:	6145                	addi	sp,sp,48
ffffffffc02031d6:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc02031d8:	c02007b7          	lui	a5,0xc0200
ffffffffc02031dc:	4501                	li	a0,0
ffffffffc02031de:	fef5e5e3          	bltu	a1,a5,ffffffffc02031c8 <user_mem_check+0x64>
ffffffffc02031e2:	962e                	add	a2,a2,a1
ffffffffc02031e4:	fec5f2e3          	bleu	a2,a1,ffffffffc02031c8 <user_mem_check+0x64>
ffffffffc02031e8:	c8000537          	lui	a0,0xc8000
ffffffffc02031ec:	0505                	addi	a0,a0,1
ffffffffc02031ee:	00a63533          	sltu	a0,a2,a0
ffffffffc02031f2:	bfd9                	j	ffffffffc02031c8 <user_mem_check+0x64>
        return 1;
ffffffffc02031f4:	4505                	li	a0,1
ffffffffc02031f6:	bfc9                	j	ffffffffc02031c8 <user_mem_check+0x64>

ffffffffc02031f8 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02031f8:	c125                	beqz	a0,ffffffffc0203258 <slob_free+0x60>
		return;

	if (size)
ffffffffc02031fa:	e1a5                	bnez	a1,ffffffffc020325a <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02031fc:	100027f3          	csrr	a5,sstatus
ffffffffc0203200:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203202:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203204:	e3bd                	bnez	a5,ffffffffc020326a <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0203206:	0009e797          	auipc	a5,0x9e
ffffffffc020320a:	e3a78793          	addi	a5,a5,-454 # ffffffffc02a1040 <slobfree>
ffffffffc020320e:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0203210:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0203212:	00a7fa63          	bleu	a0,a5,ffffffffc0203226 <slob_free+0x2e>
ffffffffc0203216:	00e56c63          	bltu	a0,a4,ffffffffc020322e <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020321a:	00e7fa63          	bleu	a4,a5,ffffffffc020322e <slob_free+0x36>
    return 0;
ffffffffc020321e:	87ba                	mv	a5,a4
ffffffffc0203220:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0203222:	fea7eae3          	bltu	a5,a0,ffffffffc0203216 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0203226:	fee7ece3          	bltu	a5,a4,ffffffffc020321e <slob_free+0x26>
ffffffffc020322a:	fee57ae3          	bleu	a4,a0,ffffffffc020321e <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc020322e:	4110                	lw	a2,0(a0)
ffffffffc0203230:	00461693          	slli	a3,a2,0x4
ffffffffc0203234:	96aa                	add	a3,a3,a0
ffffffffc0203236:	08d70b63          	beq	a4,a3,ffffffffc02032cc <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc020323a:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc020323c:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc020323e:	00469713          	slli	a4,a3,0x4
ffffffffc0203242:	973e                	add	a4,a4,a5
ffffffffc0203244:	08e50f63          	beq	a0,a4,ffffffffc02032e2 <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0203248:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc020324a:	0009e717          	auipc	a4,0x9e
ffffffffc020324e:	def73b23          	sd	a5,-522(a4) # ffffffffc02a1040 <slobfree>
    if (flag) {
ffffffffc0203252:	c199                	beqz	a1,ffffffffc0203258 <slob_free+0x60>
        intr_enable();
ffffffffc0203254:	c02fd06f          	j	ffffffffc0200656 <intr_enable>
ffffffffc0203258:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc020325a:	05bd                	addi	a1,a1,15
ffffffffc020325c:	8191                	srli	a1,a1,0x4
ffffffffc020325e:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203260:	100027f3          	csrr	a5,sstatus
ffffffffc0203264:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203266:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203268:	dfd9                	beqz	a5,ffffffffc0203206 <slob_free+0xe>
{
ffffffffc020326a:	1101                	addi	sp,sp,-32
ffffffffc020326c:	e42a                	sd	a0,8(sp)
ffffffffc020326e:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0203270:	becfd0ef          	jal	ra,ffffffffc020065c <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0203274:	0009e797          	auipc	a5,0x9e
ffffffffc0203278:	dcc78793          	addi	a5,a5,-564 # ffffffffc02a1040 <slobfree>
ffffffffc020327c:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc020327e:	6522                	ld	a0,8(sp)
ffffffffc0203280:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0203282:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0203284:	00a7fa63          	bleu	a0,a5,ffffffffc0203298 <slob_free+0xa0>
ffffffffc0203288:	00e56c63          	bltu	a0,a4,ffffffffc02032a0 <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020328c:	00e7fa63          	bleu	a4,a5,ffffffffc02032a0 <slob_free+0xa8>
    return 0;
ffffffffc0203290:	87ba                	mv	a5,a4
ffffffffc0203292:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0203294:	fea7eae3          	bltu	a5,a0,ffffffffc0203288 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0203298:	fee7ece3          	bltu	a5,a4,ffffffffc0203290 <slob_free+0x98>
ffffffffc020329c:	fee57ae3          	bleu	a4,a0,ffffffffc0203290 <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc02032a0:	4110                	lw	a2,0(a0)
ffffffffc02032a2:	00461693          	slli	a3,a2,0x4
ffffffffc02032a6:	96aa                	add	a3,a3,a0
ffffffffc02032a8:	04d70763          	beq	a4,a3,ffffffffc02032f6 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc02032ac:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02032ae:	4394                	lw	a3,0(a5)
ffffffffc02032b0:	00469713          	slli	a4,a3,0x4
ffffffffc02032b4:	973e                	add	a4,a4,a5
ffffffffc02032b6:	04e50663          	beq	a0,a4,ffffffffc0203302 <slob_free+0x10a>
		cur->next = b;
ffffffffc02032ba:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc02032bc:	0009e717          	auipc	a4,0x9e
ffffffffc02032c0:	d8f73223          	sd	a5,-636(a4) # ffffffffc02a1040 <slobfree>
    if (flag) {
ffffffffc02032c4:	e58d                	bnez	a1,ffffffffc02032ee <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc02032c6:	60e2                	ld	ra,24(sp)
ffffffffc02032c8:	6105                	addi	sp,sp,32
ffffffffc02032ca:	8082                	ret
		b->units += cur->next->units;
ffffffffc02032cc:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc02032ce:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc02032d0:	9e35                	addw	a2,a2,a3
ffffffffc02032d2:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc02032d4:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc02032d6:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02032d8:	00469713          	slli	a4,a3,0x4
ffffffffc02032dc:	973e                	add	a4,a4,a5
ffffffffc02032de:	f6e515e3          	bne	a0,a4,ffffffffc0203248 <slob_free+0x50>
		cur->units += b->units;
ffffffffc02032e2:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc02032e4:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc02032e6:	9eb9                	addw	a3,a3,a4
ffffffffc02032e8:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc02032ea:	e790                	sd	a2,8(a5)
ffffffffc02032ec:	bfb9                	j	ffffffffc020324a <slob_free+0x52>
}
ffffffffc02032ee:	60e2                	ld	ra,24(sp)
ffffffffc02032f0:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02032f2:	b64fd06f          	j	ffffffffc0200656 <intr_enable>
		b->units += cur->next->units;
ffffffffc02032f6:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc02032f8:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc02032fa:	9e35                	addw	a2,a2,a3
ffffffffc02032fc:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc02032fe:	e518                	sd	a4,8(a0)
ffffffffc0203300:	b77d                	j	ffffffffc02032ae <slob_free+0xb6>
		cur->units += b->units;
ffffffffc0203302:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0203304:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0203306:	9eb9                	addw	a3,a3,a4
ffffffffc0203308:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc020330a:	e790                	sd	a2,8(a5)
ffffffffc020330c:	bf45                	j	ffffffffc02032bc <slob_free+0xc4>

ffffffffc020330e <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc020330e:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0203310:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0203312:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0203316:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0203318:	b5bfd0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
  if(!page)
ffffffffc020331c:	c139                	beqz	a0,ffffffffc0203362 <__slob_get_free_pages.isra.0+0x54>
    return page - pages + nbase;
ffffffffc020331e:	000a9797          	auipc	a5,0xa9
ffffffffc0203322:	1b278793          	addi	a5,a5,434 # ffffffffc02ac4d0 <pages>
ffffffffc0203326:	6394                	ld	a3,0(a5)
ffffffffc0203328:	00006797          	auipc	a5,0x6
ffffffffc020332c:	9a878793          	addi	a5,a5,-1624 # ffffffffc0208cd0 <nbase>
    return KADDR(page2pa(page));
ffffffffc0203330:	000a9717          	auipc	a4,0xa9
ffffffffc0203334:	13870713          	addi	a4,a4,312 # ffffffffc02ac468 <npage>
    return page - pages + nbase;
ffffffffc0203338:	40d506b3          	sub	a3,a0,a3
ffffffffc020333c:	6388                	ld	a0,0(a5)
ffffffffc020333e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0203340:	57fd                	li	a5,-1
ffffffffc0203342:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0203344:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0203346:	83b1                	srli	a5,a5,0xc
ffffffffc0203348:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020334a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020334c:	00e7ff63          	bleu	a4,a5,ffffffffc020336a <__slob_get_free_pages.isra.0+0x5c>
ffffffffc0203350:	000a9797          	auipc	a5,0xa9
ffffffffc0203354:	17078793          	addi	a5,a5,368 # ffffffffc02ac4c0 <va_pa_offset>
ffffffffc0203358:	6388                	ld	a0,0(a5)
}
ffffffffc020335a:	60a2                	ld	ra,8(sp)
ffffffffc020335c:	9536                	add	a0,a0,a3
ffffffffc020335e:	0141                	addi	sp,sp,16
ffffffffc0203360:	8082                	ret
ffffffffc0203362:	60a2                	ld	ra,8(sp)
    return NULL;
ffffffffc0203364:	4501                	li	a0,0
}
ffffffffc0203366:	0141                	addi	sp,sp,16
ffffffffc0203368:	8082                	ret
ffffffffc020336a:	00004617          	auipc	a2,0x4
ffffffffc020336e:	c5e60613          	addi	a2,a2,-930 # ffffffffc0206fc8 <commands+0x858>
ffffffffc0203372:	06900593          	li	a1,105
ffffffffc0203376:	00004517          	auipc	a0,0x4
ffffffffc020337a:	caa50513          	addi	a0,a0,-854 # ffffffffc0207020 <commands+0x8b0>
ffffffffc020337e:	e99fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0203382 <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0203382:	7179                	addi	sp,sp,-48
ffffffffc0203384:	f406                	sd	ra,40(sp)
ffffffffc0203386:	f022                	sd	s0,32(sp)
ffffffffc0203388:	ec26                	sd	s1,24(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc020338a:	01050713          	addi	a4,a0,16
ffffffffc020338e:	6785                	lui	a5,0x1
ffffffffc0203390:	0cf77b63          	bleu	a5,a4,ffffffffc0203466 <slob_alloc.isra.1.constprop.3+0xe4>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0203394:	00f50413          	addi	s0,a0,15
ffffffffc0203398:	8011                	srli	s0,s0,0x4
ffffffffc020339a:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020339c:	10002673          	csrr	a2,sstatus
ffffffffc02033a0:	8a09                	andi	a2,a2,2
ffffffffc02033a2:	ea5d                	bnez	a2,ffffffffc0203458 <slob_alloc.isra.1.constprop.3+0xd6>
	prev = slobfree;
ffffffffc02033a4:	0009e497          	auipc	s1,0x9e
ffffffffc02033a8:	c9c48493          	addi	s1,s1,-868 # ffffffffc02a1040 <slobfree>
ffffffffc02033ac:	6094                	ld	a3,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02033ae:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02033b0:	4398                	lw	a4,0(a5)
ffffffffc02033b2:	0a875763          	ble	s0,a4,ffffffffc0203460 <slob_alloc.isra.1.constprop.3+0xde>
		if (cur == slobfree) {
ffffffffc02033b6:	00f68a63          	beq	a3,a5,ffffffffc02033ca <slob_alloc.isra.1.constprop.3+0x48>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02033ba:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02033bc:	4118                	lw	a4,0(a0)
ffffffffc02033be:	02875763          	ble	s0,a4,ffffffffc02033ec <slob_alloc.isra.1.constprop.3+0x6a>
ffffffffc02033c2:	6094                	ld	a3,0(s1)
ffffffffc02033c4:	87aa                	mv	a5,a0
		if (cur == slobfree) {
ffffffffc02033c6:	fef69ae3          	bne	a3,a5,ffffffffc02033ba <slob_alloc.isra.1.constprop.3+0x38>
    if (flag) {
ffffffffc02033ca:	ea39                	bnez	a2,ffffffffc0203420 <slob_alloc.isra.1.constprop.3+0x9e>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc02033cc:	4501                	li	a0,0
ffffffffc02033ce:	f41ff0ef          	jal	ra,ffffffffc020330e <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc02033d2:	cd29                	beqz	a0,ffffffffc020342c <slob_alloc.isra.1.constprop.3+0xaa>
			slob_free(cur, PAGE_SIZE);
ffffffffc02033d4:	6585                	lui	a1,0x1
ffffffffc02033d6:	e23ff0ef          	jal	ra,ffffffffc02031f8 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02033da:	10002673          	csrr	a2,sstatus
ffffffffc02033de:	8a09                	andi	a2,a2,2
ffffffffc02033e0:	ea1d                	bnez	a2,ffffffffc0203416 <slob_alloc.isra.1.constprop.3+0x94>
			cur = slobfree;
ffffffffc02033e2:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02033e4:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02033e6:	4118                	lw	a4,0(a0)
ffffffffc02033e8:	fc874de3          	blt	a4,s0,ffffffffc02033c2 <slob_alloc.isra.1.constprop.3+0x40>
			if (cur->units == units) /* exact fit? */
ffffffffc02033ec:	04e40663          	beq	s0,a4,ffffffffc0203438 <slob_alloc.isra.1.constprop.3+0xb6>
				prev->next = cur + units;
ffffffffc02033f0:	00441693          	slli	a3,s0,0x4
ffffffffc02033f4:	96aa                	add	a3,a3,a0
ffffffffc02033f6:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc02033f8:	650c                	ld	a1,8(a0)
				prev->next->units = cur->units - units;
ffffffffc02033fa:	9f01                	subw	a4,a4,s0
ffffffffc02033fc:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc02033fe:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0203400:	c100                	sw	s0,0(a0)
			slobfree = prev;
ffffffffc0203402:	0009e717          	auipc	a4,0x9e
ffffffffc0203406:	c2f73f23          	sd	a5,-962(a4) # ffffffffc02a1040 <slobfree>
    if (flag) {
ffffffffc020340a:	ee15                	bnez	a2,ffffffffc0203446 <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc020340c:	70a2                	ld	ra,40(sp)
ffffffffc020340e:	7402                	ld	s0,32(sp)
ffffffffc0203410:	64e2                	ld	s1,24(sp)
ffffffffc0203412:	6145                	addi	sp,sp,48
ffffffffc0203414:	8082                	ret
        intr_disable();
ffffffffc0203416:	a46fd0ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc020341a:	4605                	li	a2,1
			cur = slobfree;
ffffffffc020341c:	609c                	ld	a5,0(s1)
ffffffffc020341e:	b7d9                	j	ffffffffc02033e4 <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc0203420:	a36fd0ef          	jal	ra,ffffffffc0200656 <intr_enable>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0203424:	4501                	li	a0,0
ffffffffc0203426:	ee9ff0ef          	jal	ra,ffffffffc020330e <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc020342a:	f54d                	bnez	a0,ffffffffc02033d4 <slob_alloc.isra.1.constprop.3+0x52>
}
ffffffffc020342c:	70a2                	ld	ra,40(sp)
ffffffffc020342e:	7402                	ld	s0,32(sp)
ffffffffc0203430:	64e2                	ld	s1,24(sp)
				return 0;
ffffffffc0203432:	4501                	li	a0,0
}
ffffffffc0203434:	6145                	addi	sp,sp,48
ffffffffc0203436:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0203438:	6518                	ld	a4,8(a0)
ffffffffc020343a:	e798                	sd	a4,8(a5)
			slobfree = prev;
ffffffffc020343c:	0009e717          	auipc	a4,0x9e
ffffffffc0203440:	c0f73223          	sd	a5,-1020(a4) # ffffffffc02a1040 <slobfree>
    if (flag) {
ffffffffc0203444:	d661                	beqz	a2,ffffffffc020340c <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc0203446:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0203448:	a0efd0ef          	jal	ra,ffffffffc0200656 <intr_enable>
}
ffffffffc020344c:	70a2                	ld	ra,40(sp)
ffffffffc020344e:	7402                	ld	s0,32(sp)
ffffffffc0203450:	6522                	ld	a0,8(sp)
ffffffffc0203452:	64e2                	ld	s1,24(sp)
ffffffffc0203454:	6145                	addi	sp,sp,48
ffffffffc0203456:	8082                	ret
        intr_disable();
ffffffffc0203458:	a04fd0ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc020345c:	4605                	li	a2,1
ffffffffc020345e:	b799                	j	ffffffffc02033a4 <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0203460:	853e                	mv	a0,a5
ffffffffc0203462:	87b6                	mv	a5,a3
ffffffffc0203464:	b761                	j	ffffffffc02033ec <slob_alloc.isra.1.constprop.3+0x6a>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0203466:	00004697          	auipc	a3,0x4
ffffffffc020346a:	76a68693          	addi	a3,a3,1898 # ffffffffc0207bd0 <commands+0x1460>
ffffffffc020346e:	00003617          	auipc	a2,0x3
ffffffffc0203472:	78260613          	addi	a2,a2,1922 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203476:	06400593          	li	a1,100
ffffffffc020347a:	00004517          	auipc	a0,0x4
ffffffffc020347e:	77650513          	addi	a0,a0,1910 # ffffffffc0207bf0 <commands+0x1480>
ffffffffc0203482:	d95fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0203486 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0203486:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0203488:	00004517          	auipc	a0,0x4
ffffffffc020348c:	78050513          	addi	a0,a0,1920 # ffffffffc0207c08 <commands+0x1498>
kmalloc_init(void) {
ffffffffc0203490:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0203492:	c3ffc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0203496:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0203498:	00004517          	auipc	a0,0x4
ffffffffc020349c:	71850513          	addi	a0,a0,1816 # ffffffffc0207bb0 <commands+0x1440>
}
ffffffffc02034a0:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02034a2:	c2ffc06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc02034a6 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc02034a6:	4501                	li	a0,0
ffffffffc02034a8:	8082                	ret

ffffffffc02034aa <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc02034aa:	1101                	addi	sp,sp,-32
ffffffffc02034ac:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02034ae:	6905                	lui	s2,0x1
{
ffffffffc02034b0:	e822                	sd	s0,16(sp)
ffffffffc02034b2:	ec06                	sd	ra,24(sp)
ffffffffc02034b4:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02034b6:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8589>
{
ffffffffc02034ba:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02034bc:	04a7fc63          	bleu	a0,a5,ffffffffc0203514 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc02034c0:	4561                	li	a0,24
ffffffffc02034c2:	ec1ff0ef          	jal	ra,ffffffffc0203382 <slob_alloc.isra.1.constprop.3>
ffffffffc02034c6:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc02034c8:	cd21                	beqz	a0,ffffffffc0203520 <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc02034ca:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc02034ce:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc02034d0:	00f95763          	ble	a5,s2,ffffffffc02034de <kmalloc+0x34>
ffffffffc02034d4:	6705                	lui	a4,0x1
ffffffffc02034d6:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc02034d8:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc02034da:	fef74ee3          	blt	a4,a5,ffffffffc02034d6 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc02034de:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc02034e0:	e2fff0ef          	jal	ra,ffffffffc020330e <__slob_get_free_pages.isra.0>
ffffffffc02034e4:	e488                	sd	a0,8(s1)
ffffffffc02034e6:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc02034e8:	c935                	beqz	a0,ffffffffc020355c <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02034ea:	100027f3          	csrr	a5,sstatus
ffffffffc02034ee:	8b89                	andi	a5,a5,2
ffffffffc02034f0:	e3a1                	bnez	a5,ffffffffc0203530 <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc02034f2:	000a9797          	auipc	a5,0xa9
ffffffffc02034f6:	f8678793          	addi	a5,a5,-122 # ffffffffc02ac478 <bigblocks>
ffffffffc02034fa:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc02034fc:	000a9717          	auipc	a4,0xa9
ffffffffc0203500:	f6973e23          	sd	s1,-132(a4) # ffffffffc02ac478 <bigblocks>
		bb->next = bigblocks;
ffffffffc0203504:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0203506:	8522                	mv	a0,s0
ffffffffc0203508:	60e2                	ld	ra,24(sp)
ffffffffc020350a:	6442                	ld	s0,16(sp)
ffffffffc020350c:	64a2                	ld	s1,8(sp)
ffffffffc020350e:	6902                	ld	s2,0(sp)
ffffffffc0203510:	6105                	addi	sp,sp,32
ffffffffc0203512:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0203514:	0541                	addi	a0,a0,16
ffffffffc0203516:	e6dff0ef          	jal	ra,ffffffffc0203382 <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc020351a:	01050413          	addi	s0,a0,16
ffffffffc020351e:	f565                	bnez	a0,ffffffffc0203506 <kmalloc+0x5c>
ffffffffc0203520:	4401                	li	s0,0
}
ffffffffc0203522:	8522                	mv	a0,s0
ffffffffc0203524:	60e2                	ld	ra,24(sp)
ffffffffc0203526:	6442                	ld	s0,16(sp)
ffffffffc0203528:	64a2                	ld	s1,8(sp)
ffffffffc020352a:	6902                	ld	s2,0(sp)
ffffffffc020352c:	6105                	addi	sp,sp,32
ffffffffc020352e:	8082                	ret
        intr_disable();
ffffffffc0203530:	92cfd0ef          	jal	ra,ffffffffc020065c <intr_disable>
		bb->next = bigblocks;
ffffffffc0203534:	000a9797          	auipc	a5,0xa9
ffffffffc0203538:	f4478793          	addi	a5,a5,-188 # ffffffffc02ac478 <bigblocks>
ffffffffc020353c:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc020353e:	000a9717          	auipc	a4,0xa9
ffffffffc0203542:	f2973d23          	sd	s1,-198(a4) # ffffffffc02ac478 <bigblocks>
		bb->next = bigblocks;
ffffffffc0203546:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0203548:	90efd0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc020354c:	6480                	ld	s0,8(s1)
}
ffffffffc020354e:	60e2                	ld	ra,24(sp)
ffffffffc0203550:	64a2                	ld	s1,8(sp)
ffffffffc0203552:	8522                	mv	a0,s0
ffffffffc0203554:	6442                	ld	s0,16(sp)
ffffffffc0203556:	6902                	ld	s2,0(sp)
ffffffffc0203558:	6105                	addi	sp,sp,32
ffffffffc020355a:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc020355c:	45e1                	li	a1,24
ffffffffc020355e:	8526                	mv	a0,s1
ffffffffc0203560:	c99ff0ef          	jal	ra,ffffffffc02031f8 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0203564:	b74d                	j	ffffffffc0203506 <kmalloc+0x5c>

ffffffffc0203566 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0203566:	c175                	beqz	a0,ffffffffc020364a <kfree+0xe4>
{
ffffffffc0203568:	1101                	addi	sp,sp,-32
ffffffffc020356a:	e426                	sd	s1,8(sp)
ffffffffc020356c:	ec06                	sd	ra,24(sp)
ffffffffc020356e:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0203570:	03451793          	slli	a5,a0,0x34
ffffffffc0203574:	84aa                	mv	s1,a0
ffffffffc0203576:	eb8d                	bnez	a5,ffffffffc02035a8 <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203578:	100027f3          	csrr	a5,sstatus
ffffffffc020357c:	8b89                	andi	a5,a5,2
ffffffffc020357e:	efc9                	bnez	a5,ffffffffc0203618 <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0203580:	000a9797          	auipc	a5,0xa9
ffffffffc0203584:	ef878793          	addi	a5,a5,-264 # ffffffffc02ac478 <bigblocks>
ffffffffc0203588:	6394                	ld	a3,0(a5)
ffffffffc020358a:	ce99                	beqz	a3,ffffffffc02035a8 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc020358c:	669c                	ld	a5,8(a3)
ffffffffc020358e:	6a80                	ld	s0,16(a3)
ffffffffc0203590:	0af50e63          	beq	a0,a5,ffffffffc020364c <kfree+0xe6>
    return 0;
ffffffffc0203594:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0203596:	c801                	beqz	s0,ffffffffc02035a6 <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0203598:	6418                	ld	a4,8(s0)
ffffffffc020359a:	681c                	ld	a5,16(s0)
ffffffffc020359c:	00970f63          	beq	a4,s1,ffffffffc02035ba <kfree+0x54>
ffffffffc02035a0:	86a2                	mv	a3,s0
ffffffffc02035a2:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02035a4:	f875                	bnez	s0,ffffffffc0203598 <kfree+0x32>
    if (flag) {
ffffffffc02035a6:	e659                	bnez	a2,ffffffffc0203634 <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc02035a8:	6442                	ld	s0,16(sp)
ffffffffc02035aa:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc02035ac:	ff048513          	addi	a0,s1,-16
}
ffffffffc02035b0:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc02035b2:	4581                	li	a1,0
}
ffffffffc02035b4:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc02035b6:	c43ff06f          	j	ffffffffc02031f8 <slob_free>
				*last = bb->next;
ffffffffc02035ba:	ea9c                	sd	a5,16(a3)
ffffffffc02035bc:	e641                	bnez	a2,ffffffffc0203644 <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc02035be:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc02035c2:	4018                	lw	a4,0(s0)
ffffffffc02035c4:	08f4ea63          	bltu	s1,a5,ffffffffc0203658 <kfree+0xf2>
ffffffffc02035c8:	000a9797          	auipc	a5,0xa9
ffffffffc02035cc:	ef878793          	addi	a5,a5,-264 # ffffffffc02ac4c0 <va_pa_offset>
ffffffffc02035d0:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02035d2:	000a9797          	auipc	a5,0xa9
ffffffffc02035d6:	e9678793          	addi	a5,a5,-362 # ffffffffc02ac468 <npage>
ffffffffc02035da:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc02035dc:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc02035de:	80b1                	srli	s1,s1,0xc
ffffffffc02035e0:	08f4f963          	bleu	a5,s1,ffffffffc0203672 <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc02035e4:	00005797          	auipc	a5,0x5
ffffffffc02035e8:	6ec78793          	addi	a5,a5,1772 # ffffffffc0208cd0 <nbase>
ffffffffc02035ec:	639c                	ld	a5,0(a5)
ffffffffc02035ee:	000a9697          	auipc	a3,0xa9
ffffffffc02035f2:	ee268693          	addi	a3,a3,-286 # ffffffffc02ac4d0 <pages>
ffffffffc02035f6:	6288                	ld	a0,0(a3)
ffffffffc02035f8:	8c9d                	sub	s1,s1,a5
ffffffffc02035fa:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc02035fc:	4585                	li	a1,1
ffffffffc02035fe:	9526                	add	a0,a0,s1
ffffffffc0203600:	00e595bb          	sllw	a1,a1,a4
ffffffffc0203604:	8f7fd0ef          	jal	ra,ffffffffc0200efa <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0203608:	8522                	mv	a0,s0
}
ffffffffc020360a:	6442                	ld	s0,16(sp)
ffffffffc020360c:	60e2                	ld	ra,24(sp)
ffffffffc020360e:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0203610:	45e1                	li	a1,24
}
ffffffffc0203612:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0203614:	be5ff06f          	j	ffffffffc02031f8 <slob_free>
        intr_disable();
ffffffffc0203618:	844fd0ef          	jal	ra,ffffffffc020065c <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc020361c:	000a9797          	auipc	a5,0xa9
ffffffffc0203620:	e5c78793          	addi	a5,a5,-420 # ffffffffc02ac478 <bigblocks>
ffffffffc0203624:	6394                	ld	a3,0(a5)
ffffffffc0203626:	c699                	beqz	a3,ffffffffc0203634 <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0203628:	669c                	ld	a5,8(a3)
ffffffffc020362a:	6a80                	ld	s0,16(a3)
ffffffffc020362c:	00f48763          	beq	s1,a5,ffffffffc020363a <kfree+0xd4>
        return 1;
ffffffffc0203630:	4605                	li	a2,1
ffffffffc0203632:	b795                	j	ffffffffc0203596 <kfree+0x30>
        intr_enable();
ffffffffc0203634:	822fd0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc0203638:	bf85                	j	ffffffffc02035a8 <kfree+0x42>
				*last = bb->next;
ffffffffc020363a:	000a9797          	auipc	a5,0xa9
ffffffffc020363e:	e287bf23          	sd	s0,-450(a5) # ffffffffc02ac478 <bigblocks>
ffffffffc0203642:	8436                	mv	s0,a3
ffffffffc0203644:	812fd0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc0203648:	bf9d                	j	ffffffffc02035be <kfree+0x58>
ffffffffc020364a:	8082                	ret
ffffffffc020364c:	000a9797          	auipc	a5,0xa9
ffffffffc0203650:	e287b623          	sd	s0,-468(a5) # ffffffffc02ac478 <bigblocks>
ffffffffc0203654:	8436                	mv	s0,a3
ffffffffc0203656:	b7a5                	j	ffffffffc02035be <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0203658:	86a6                	mv	a3,s1
ffffffffc020365a:	00004617          	auipc	a2,0x4
ffffffffc020365e:	a4660613          	addi	a2,a2,-1466 # ffffffffc02070a0 <commands+0x930>
ffffffffc0203662:	06e00593          	li	a1,110
ffffffffc0203666:	00004517          	auipc	a0,0x4
ffffffffc020366a:	9ba50513          	addi	a0,a0,-1606 # ffffffffc0207020 <commands+0x8b0>
ffffffffc020366e:	ba9fc0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203672:	00004617          	auipc	a2,0x4
ffffffffc0203676:	98e60613          	addi	a2,a2,-1650 # ffffffffc0207000 <commands+0x890>
ffffffffc020367a:	06200593          	li	a1,98
ffffffffc020367e:	00004517          	auipc	a0,0x4
ffffffffc0203682:	9a250513          	addi	a0,a0,-1630 # ffffffffc0207020 <commands+0x8b0>
ffffffffc0203686:	b91fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020368a <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020368a:	7135                	addi	sp,sp,-160
ffffffffc020368c:	ed06                	sd	ra,152(sp)
ffffffffc020368e:	e922                	sd	s0,144(sp)
ffffffffc0203690:	e526                	sd	s1,136(sp)
ffffffffc0203692:	e14a                	sd	s2,128(sp)
ffffffffc0203694:	fcce                	sd	s3,120(sp)
ffffffffc0203696:	f8d2                	sd	s4,112(sp)
ffffffffc0203698:	f4d6                	sd	s5,104(sp)
ffffffffc020369a:	f0da                	sd	s6,96(sp)
ffffffffc020369c:	ecde                	sd	s7,88(sp)
ffffffffc020369e:	e8e2                	sd	s8,80(sp)
ffffffffc02036a0:	e4e6                	sd	s9,72(sp)
ffffffffc02036a2:	e0ea                	sd	s10,64(sp)
ffffffffc02036a4:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc02036a6:	460010ef          	jal	ra,ffffffffc0204b06 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02036aa:	000a9797          	auipc	a5,0xa9
ffffffffc02036ae:	ece78793          	addi	a5,a5,-306 # ffffffffc02ac578 <max_swap_offset>
ffffffffc02036b2:	6394                	ld	a3,0(a5)
ffffffffc02036b4:	010007b7          	lui	a5,0x1000
ffffffffc02036b8:	17e1                	addi	a5,a5,-8
ffffffffc02036ba:	ff968713          	addi	a4,a3,-7
ffffffffc02036be:	4ae7ee63          	bltu	a5,a4,ffffffffc0203b7a <swap_init+0x4f0>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc02036c2:	0009e797          	auipc	a5,0x9e
ffffffffc02036c6:	92e78793          	addi	a5,a5,-1746 # ffffffffc02a0ff0 <swap_manager_fifo>
     int r = sm->init();
ffffffffc02036ca:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc02036cc:	000a9697          	auipc	a3,0xa9
ffffffffc02036d0:	daf6ba23          	sd	a5,-588(a3) # ffffffffc02ac480 <sm>
     int r = sm->init();
ffffffffc02036d4:	9702                	jalr	a4
ffffffffc02036d6:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc02036d8:	c10d                	beqz	a0,ffffffffc02036fa <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02036da:	60ea                	ld	ra,152(sp)
ffffffffc02036dc:	644a                	ld	s0,144(sp)
ffffffffc02036de:	8556                	mv	a0,s5
ffffffffc02036e0:	64aa                	ld	s1,136(sp)
ffffffffc02036e2:	690a                	ld	s2,128(sp)
ffffffffc02036e4:	79e6                	ld	s3,120(sp)
ffffffffc02036e6:	7a46                	ld	s4,112(sp)
ffffffffc02036e8:	7aa6                	ld	s5,104(sp)
ffffffffc02036ea:	7b06                	ld	s6,96(sp)
ffffffffc02036ec:	6be6                	ld	s7,88(sp)
ffffffffc02036ee:	6c46                	ld	s8,80(sp)
ffffffffc02036f0:	6ca6                	ld	s9,72(sp)
ffffffffc02036f2:	6d06                	ld	s10,64(sp)
ffffffffc02036f4:	7de2                	ld	s11,56(sp)
ffffffffc02036f6:	610d                	addi	sp,sp,160
ffffffffc02036f8:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02036fa:	000a9797          	auipc	a5,0xa9
ffffffffc02036fe:	d8678793          	addi	a5,a5,-634 # ffffffffc02ac480 <sm>
ffffffffc0203702:	639c                	ld	a5,0(a5)
ffffffffc0203704:	00004517          	auipc	a0,0x4
ffffffffc0203708:	59c50513          	addi	a0,a0,1436 # ffffffffc0207ca0 <commands+0x1530>
ffffffffc020370c:	000a9417          	auipc	s0,0xa9
ffffffffc0203710:	eac40413          	addi	s0,s0,-340 # ffffffffc02ac5b8 <free_area>
ffffffffc0203714:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0203716:	4785                	li	a5,1
ffffffffc0203718:	000a9717          	auipc	a4,0xa9
ffffffffc020371c:	d6f72823          	sw	a5,-656(a4) # ffffffffc02ac488 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203720:	9b1fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0203724:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203726:	36878e63          	beq	a5,s0,ffffffffc0203aa2 <swap_init+0x418>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020372a:	ff07b703          	ld	a4,-16(a5)
ffffffffc020372e:	8305                	srli	a4,a4,0x1
ffffffffc0203730:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203732:	36070c63          	beqz	a4,ffffffffc0203aaa <swap_init+0x420>
     int ret, count = 0, total = 0, i;
ffffffffc0203736:	4481                	li	s1,0
ffffffffc0203738:	4901                	li	s2,0
ffffffffc020373a:	a031                	j	ffffffffc0203746 <swap_init+0xbc>
ffffffffc020373c:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0203740:	8b09                	andi	a4,a4,2
ffffffffc0203742:	36070463          	beqz	a4,ffffffffc0203aaa <swap_init+0x420>
        count ++, total += p->property;
ffffffffc0203746:	ff87a703          	lw	a4,-8(a5)
ffffffffc020374a:	679c                	ld	a5,8(a5)
ffffffffc020374c:	2905                	addiw	s2,s2,1
ffffffffc020374e:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203750:	fe8796e3          	bne	a5,s0,ffffffffc020373c <swap_init+0xb2>
ffffffffc0203754:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0203756:	feafd0ef          	jal	ra,ffffffffc0200f40 <nr_free_pages>
ffffffffc020375a:	69351863          	bne	a0,s3,ffffffffc0203dea <swap_init+0x760>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc020375e:	8626                	mv	a2,s1
ffffffffc0203760:	85ca                	mv	a1,s2
ffffffffc0203762:	00004517          	auipc	a0,0x4
ffffffffc0203766:	58650513          	addi	a0,a0,1414 # ffffffffc0207ce8 <commands+0x1578>
ffffffffc020376a:	967fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc020376e:	82eff0ef          	jal	ra,ffffffffc020279c <mm_create>
ffffffffc0203772:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0203774:	60050b63          	beqz	a0,ffffffffc0203d8a <swap_init+0x700>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0203778:	000a9797          	auipc	a5,0xa9
ffffffffc020377c:	d7078793          	addi	a5,a5,-656 # ffffffffc02ac4e8 <check_mm_struct>
ffffffffc0203780:	639c                	ld	a5,0(a5)
ffffffffc0203782:	62079463          	bnez	a5,ffffffffc0203daa <swap_init+0x720>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203786:	000a9797          	auipc	a5,0xa9
ffffffffc020378a:	cda78793          	addi	a5,a5,-806 # ffffffffc02ac460 <boot_pgdir>
ffffffffc020378e:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0203792:	000a9797          	auipc	a5,0xa9
ffffffffc0203796:	d4a7bb23          	sd	a0,-682(a5) # ffffffffc02ac4e8 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc020379a:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020379e:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02037a2:	4e079863          	bnez	a5,ffffffffc0203c92 <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02037a6:	6599                	lui	a1,0x6
ffffffffc02037a8:	460d                	li	a2,3
ffffffffc02037aa:	6505                	lui	a0,0x1
ffffffffc02037ac:	83cff0ef          	jal	ra,ffffffffc02027e8 <vma_create>
ffffffffc02037b0:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02037b2:	50050063          	beqz	a0,ffffffffc0203cb2 <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc02037b6:	855e                	mv	a0,s7
ffffffffc02037b8:	89cff0ef          	jal	ra,ffffffffc0202854 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02037bc:	00004517          	auipc	a0,0x4
ffffffffc02037c0:	56c50513          	addi	a0,a0,1388 # ffffffffc0207d28 <commands+0x15b8>
ffffffffc02037c4:	90dfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02037c8:	018bb503          	ld	a0,24(s7)
ffffffffc02037cc:	4605                	li	a2,1
ffffffffc02037ce:	6585                	lui	a1,0x1
ffffffffc02037d0:	fb0fd0ef          	jal	ra,ffffffffc0200f80 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02037d4:	4e050f63          	beqz	a0,ffffffffc0203cd2 <swap_init+0x648>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02037d8:	00004517          	auipc	a0,0x4
ffffffffc02037dc:	5a050513          	addi	a0,a0,1440 # ffffffffc0207d78 <commands+0x1608>
ffffffffc02037e0:	000a9997          	auipc	s3,0xa9
ffffffffc02037e4:	d1098993          	addi	s3,s3,-752 # ffffffffc02ac4f0 <check_rp>
ffffffffc02037e8:	8e9fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02037ec:	000a9a17          	auipc	s4,0xa9
ffffffffc02037f0:	d24a0a13          	addi	s4,s4,-732 # ffffffffc02ac510 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02037f4:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc02037f6:	4505                	li	a0,1
ffffffffc02037f8:	e7afd0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc02037fc:	00ac3023          	sd	a0,0(s8) # 80000 <_binary_obj___user_exit_out_size+0x75580>
          assert(check_rp[i] != NULL );
ffffffffc0203800:	32050d63          	beqz	a0,ffffffffc0203b3a <swap_init+0x4b0>
ffffffffc0203804:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0203806:	8b89                	andi	a5,a5,2
ffffffffc0203808:	30079963          	bnez	a5,ffffffffc0203b1a <swap_init+0x490>
ffffffffc020380c:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020380e:	ff4c14e3          	bne	s8,s4,ffffffffc02037f6 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0203812:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0203814:	000a9c17          	auipc	s8,0xa9
ffffffffc0203818:	cdcc0c13          	addi	s8,s8,-804 # ffffffffc02ac4f0 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc020381c:	ec3e                	sd	a5,24(sp)
ffffffffc020381e:	641c                	ld	a5,8(s0)
ffffffffc0203820:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0203822:	481c                	lw	a5,16(s0)
ffffffffc0203824:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0203826:	000a9797          	auipc	a5,0xa9
ffffffffc020382a:	d887bd23          	sd	s0,-614(a5) # ffffffffc02ac5c0 <free_area+0x8>
ffffffffc020382e:	000a9797          	auipc	a5,0xa9
ffffffffc0203832:	d887b523          	sd	s0,-630(a5) # ffffffffc02ac5b8 <free_area>
     nr_free = 0;
ffffffffc0203836:	000a9797          	auipc	a5,0xa9
ffffffffc020383a:	d807a923          	sw	zero,-622(a5) # ffffffffc02ac5c8 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc020383e:	000c3503          	ld	a0,0(s8)
ffffffffc0203842:	4585                	li	a1,1
ffffffffc0203844:	0c21                	addi	s8,s8,8
ffffffffc0203846:	eb4fd0ef          	jal	ra,ffffffffc0200efa <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020384a:	ff4c1ae3          	bne	s8,s4,ffffffffc020383e <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc020384e:	01042c03          	lw	s8,16(s0)
ffffffffc0203852:	4791                	li	a5,4
ffffffffc0203854:	50fc1b63          	bne	s8,a5,ffffffffc0203d6a <swap_init+0x6e0>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0203858:	00004517          	auipc	a0,0x4
ffffffffc020385c:	5a850513          	addi	a0,a0,1448 # ffffffffc0207e00 <commands+0x1690>
ffffffffc0203860:	871fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203864:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0203866:	000a9797          	auipc	a5,0xa9
ffffffffc020386a:	c007a523          	sw	zero,-1014(a5) # ffffffffc02ac470 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020386e:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0203870:	000a9797          	auipc	a5,0xa9
ffffffffc0203874:	c0078793          	addi	a5,a5,-1024 # ffffffffc02ac470 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203878:	00c68023          	sb	a2,0(a3) # 1000 <_binary_obj___user_faultread_out_size-0x8578>
     assert(pgfault_num==1);
ffffffffc020387c:	4398                	lw	a4,0(a5)
ffffffffc020387e:	4585                	li	a1,1
ffffffffc0203880:	2701                	sext.w	a4,a4
ffffffffc0203882:	38b71863          	bne	a4,a1,ffffffffc0203c12 <swap_init+0x588>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0203886:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc020388a:	4394                	lw	a3,0(a5)
ffffffffc020388c:	2681                	sext.w	a3,a3
ffffffffc020388e:	3ae69263          	bne	a3,a4,ffffffffc0203c32 <swap_init+0x5a8>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203892:	6689                	lui	a3,0x2
ffffffffc0203894:	462d                	li	a2,11
ffffffffc0203896:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7578>
     assert(pgfault_num==2);
ffffffffc020389a:	4398                	lw	a4,0(a5)
ffffffffc020389c:	4589                	li	a1,2
ffffffffc020389e:	2701                	sext.w	a4,a4
ffffffffc02038a0:	2eb71963          	bne	a4,a1,ffffffffc0203b92 <swap_init+0x508>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc02038a4:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc02038a8:	4394                	lw	a3,0(a5)
ffffffffc02038aa:	2681                	sext.w	a3,a3
ffffffffc02038ac:	30e69363          	bne	a3,a4,ffffffffc0203bb2 <swap_init+0x528>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc02038b0:	668d                	lui	a3,0x3
ffffffffc02038b2:	4631                	li	a2,12
ffffffffc02038b4:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6578>
     assert(pgfault_num==3);
ffffffffc02038b8:	4398                	lw	a4,0(a5)
ffffffffc02038ba:	458d                	li	a1,3
ffffffffc02038bc:	2701                	sext.w	a4,a4
ffffffffc02038be:	30b71a63          	bne	a4,a1,ffffffffc0203bd2 <swap_init+0x548>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02038c2:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02038c6:	4394                	lw	a3,0(a5)
ffffffffc02038c8:	2681                	sext.w	a3,a3
ffffffffc02038ca:	32e69463          	bne	a3,a4,ffffffffc0203bf2 <swap_init+0x568>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02038ce:	6691                	lui	a3,0x4
ffffffffc02038d0:	4635                	li	a2,13
ffffffffc02038d2:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5578>
     assert(pgfault_num==4);
ffffffffc02038d6:	4398                	lw	a4,0(a5)
ffffffffc02038d8:	2701                	sext.w	a4,a4
ffffffffc02038da:	37871c63          	bne	a4,s8,ffffffffc0203c52 <swap_init+0x5c8>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02038de:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc02038e2:	439c                	lw	a5,0(a5)
ffffffffc02038e4:	2781                	sext.w	a5,a5
ffffffffc02038e6:	38e79663          	bne	a5,a4,ffffffffc0203c72 <swap_init+0x5e8>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02038ea:	481c                	lw	a5,16(s0)
ffffffffc02038ec:	40079363          	bnez	a5,ffffffffc0203cf2 <swap_init+0x668>
ffffffffc02038f0:	000a9797          	auipc	a5,0xa9
ffffffffc02038f4:	c2078793          	addi	a5,a5,-992 # ffffffffc02ac510 <swap_in_seq_no>
ffffffffc02038f8:	000a9717          	auipc	a4,0xa9
ffffffffc02038fc:	c4070713          	addi	a4,a4,-960 # ffffffffc02ac538 <swap_out_seq_no>
ffffffffc0203900:	000a9617          	auipc	a2,0xa9
ffffffffc0203904:	c3860613          	addi	a2,a2,-968 # ffffffffc02ac538 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0203908:	56fd                	li	a3,-1
ffffffffc020390a:	c394                	sw	a3,0(a5)
ffffffffc020390c:	c314                	sw	a3,0(a4)
ffffffffc020390e:	0791                	addi	a5,a5,4
ffffffffc0203910:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0203912:	fef61ce3          	bne	a2,a5,ffffffffc020390a <swap_init+0x280>
ffffffffc0203916:	000a9697          	auipc	a3,0xa9
ffffffffc020391a:	c8268693          	addi	a3,a3,-894 # ffffffffc02ac598 <check_ptep>
ffffffffc020391e:	000a9817          	auipc	a6,0xa9
ffffffffc0203922:	bd280813          	addi	a6,a6,-1070 # ffffffffc02ac4f0 <check_rp>
ffffffffc0203926:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc0203928:	000a9c97          	auipc	s9,0xa9
ffffffffc020392c:	b40c8c93          	addi	s9,s9,-1216 # ffffffffc02ac468 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203930:	00005d97          	auipc	s11,0x5
ffffffffc0203934:	3a0d8d93          	addi	s11,s11,928 # ffffffffc0208cd0 <nbase>
ffffffffc0203938:	000a9c17          	auipc	s8,0xa9
ffffffffc020393c:	b98c0c13          	addi	s8,s8,-1128 # ffffffffc02ac4d0 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0203940:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203944:	4601                	li	a2,0
ffffffffc0203946:	85ea                	mv	a1,s10
ffffffffc0203948:	855a                	mv	a0,s6
ffffffffc020394a:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc020394c:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020394e:	e32fd0ef          	jal	ra,ffffffffc0200f80 <get_pte>
ffffffffc0203952:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0203954:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203956:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0203958:	20050163          	beqz	a0,ffffffffc0203b5a <swap_init+0x4d0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020395c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020395e:	0017f613          	andi	a2,a5,1
ffffffffc0203962:	1a060063          	beqz	a2,ffffffffc0203b02 <swap_init+0x478>
    if (PPN(pa) >= npage) {
ffffffffc0203966:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020396a:	078a                	slli	a5,a5,0x2
ffffffffc020396c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020396e:	14c7fe63          	bleu	a2,a5,ffffffffc0203aca <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203972:	000db703          	ld	a4,0(s11)
ffffffffc0203976:	000c3603          	ld	a2,0(s8)
ffffffffc020397a:	00083583          	ld	a1,0(a6)
ffffffffc020397e:	8f99                	sub	a5,a5,a4
ffffffffc0203980:	079a                	slli	a5,a5,0x6
ffffffffc0203982:	e43a                	sd	a4,8(sp)
ffffffffc0203984:	97b2                	add	a5,a5,a2
ffffffffc0203986:	14f59e63          	bne	a1,a5,ffffffffc0203ae2 <swap_init+0x458>
ffffffffc020398a:	6785                	lui	a5,0x1
ffffffffc020398c:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020398e:	6795                	lui	a5,0x5
ffffffffc0203990:	06a1                	addi	a3,a3,8
ffffffffc0203992:	0821                	addi	a6,a6,8
ffffffffc0203994:	fafd16e3          	bne	s10,a5,ffffffffc0203940 <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0203998:	00004517          	auipc	a0,0x4
ffffffffc020399c:	51050513          	addi	a0,a0,1296 # ffffffffc0207ea8 <commands+0x1738>
ffffffffc02039a0:	f30fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = sm->check_swap();
ffffffffc02039a4:	000a9797          	auipc	a5,0xa9
ffffffffc02039a8:	adc78793          	addi	a5,a5,-1316 # ffffffffc02ac480 <sm>
ffffffffc02039ac:	639c                	ld	a5,0(a5)
ffffffffc02039ae:	7f9c                	ld	a5,56(a5)
ffffffffc02039b0:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc02039b2:	40051c63          	bnez	a0,ffffffffc0203dca <swap_init+0x740>

     nr_free = nr_free_store;
ffffffffc02039b6:	77a2                	ld	a5,40(sp)
ffffffffc02039b8:	000a9717          	auipc	a4,0xa9
ffffffffc02039bc:	c0f72823          	sw	a5,-1008(a4) # ffffffffc02ac5c8 <free_area+0x10>
     free_list = free_list_store;
ffffffffc02039c0:	67e2                	ld	a5,24(sp)
ffffffffc02039c2:	000a9717          	auipc	a4,0xa9
ffffffffc02039c6:	bef73b23          	sd	a5,-1034(a4) # ffffffffc02ac5b8 <free_area>
ffffffffc02039ca:	7782                	ld	a5,32(sp)
ffffffffc02039cc:	000a9717          	auipc	a4,0xa9
ffffffffc02039d0:	bef73a23          	sd	a5,-1036(a4) # ffffffffc02ac5c0 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc02039d4:	0009b503          	ld	a0,0(s3)
ffffffffc02039d8:	4585                	li	a1,1
ffffffffc02039da:	09a1                	addi	s3,s3,8
ffffffffc02039dc:	d1efd0ef          	jal	ra,ffffffffc0200efa <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02039e0:	ff499ae3          	bne	s3,s4,ffffffffc02039d4 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc02039e4:	000bbc23          	sd	zero,24(s7)
     mm_destroy(mm);
ffffffffc02039e8:	855e                	mv	a0,s7
ffffffffc02039ea:	f39fe0ef          	jal	ra,ffffffffc0202922 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02039ee:	000a9797          	auipc	a5,0xa9
ffffffffc02039f2:	a7278793          	addi	a5,a5,-1422 # ffffffffc02ac460 <boot_pgdir>
ffffffffc02039f6:	639c                	ld	a5,0(a5)
     check_mm_struct = NULL;
ffffffffc02039f8:	000a9697          	auipc	a3,0xa9
ffffffffc02039fc:	ae06b823          	sd	zero,-1296(a3) # ffffffffc02ac4e8 <check_mm_struct>
    if (PPN(pa) >= npage) {
ffffffffc0203a00:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203a04:	6394                	ld	a3,0(a5)
ffffffffc0203a06:	068a                	slli	a3,a3,0x2
ffffffffc0203a08:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203a0a:	0ce6f063          	bleu	a4,a3,ffffffffc0203aca <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203a0e:	67a2                	ld	a5,8(sp)
ffffffffc0203a10:	000c3503          	ld	a0,0(s8)
ffffffffc0203a14:	8e9d                	sub	a3,a3,a5
ffffffffc0203a16:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0203a18:	8699                	srai	a3,a3,0x6
ffffffffc0203a1a:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0203a1c:	57fd                	li	a5,-1
ffffffffc0203a1e:	83b1                	srli	a5,a5,0xc
ffffffffc0203a20:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203a22:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203a24:	2ee7f763          	bleu	a4,a5,ffffffffc0203d12 <swap_init+0x688>
     free_page(pde2page(pd0[0]));
ffffffffc0203a28:	000a9797          	auipc	a5,0xa9
ffffffffc0203a2c:	a9878793          	addi	a5,a5,-1384 # ffffffffc02ac4c0 <va_pa_offset>
ffffffffc0203a30:	639c                	ld	a5,0(a5)
ffffffffc0203a32:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203a34:	629c                	ld	a5,0(a3)
ffffffffc0203a36:	078a                	slli	a5,a5,0x2
ffffffffc0203a38:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203a3a:	08e7f863          	bleu	a4,a5,ffffffffc0203aca <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203a3e:	69a2                	ld	s3,8(sp)
ffffffffc0203a40:	4585                	li	a1,1
ffffffffc0203a42:	413787b3          	sub	a5,a5,s3
ffffffffc0203a46:	079a                	slli	a5,a5,0x6
ffffffffc0203a48:	953e                	add	a0,a0,a5
ffffffffc0203a4a:	cb0fd0ef          	jal	ra,ffffffffc0200efa <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203a4e:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0203a52:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203a56:	078a                	slli	a5,a5,0x2
ffffffffc0203a58:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203a5a:	06e7f863          	bleu	a4,a5,ffffffffc0203aca <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203a5e:	000c3503          	ld	a0,0(s8)
ffffffffc0203a62:	413787b3          	sub	a5,a5,s3
ffffffffc0203a66:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0203a68:	4585                	li	a1,1
ffffffffc0203a6a:	953e                	add	a0,a0,a5
ffffffffc0203a6c:	c8efd0ef          	jal	ra,ffffffffc0200efa <free_pages>
     pgdir[0] = 0;
ffffffffc0203a70:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0203a74:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0203a78:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203a7a:	00878963          	beq	a5,s0,ffffffffc0203a8c <swap_init+0x402>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0203a7e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203a82:	679c                	ld	a5,8(a5)
ffffffffc0203a84:	397d                	addiw	s2,s2,-1
ffffffffc0203a86:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203a88:	fe879be3          	bne	a5,s0,ffffffffc0203a7e <swap_init+0x3f4>
     }
     assert(count==0);
ffffffffc0203a8c:	28091f63          	bnez	s2,ffffffffc0203d2a <swap_init+0x6a0>
     assert(total==0);
ffffffffc0203a90:	2a049d63          	bnez	s1,ffffffffc0203d4a <swap_init+0x6c0>

     cprintf("check_swap() succeeded!\n");
ffffffffc0203a94:	00004517          	auipc	a0,0x4
ffffffffc0203a98:	46450513          	addi	a0,a0,1124 # ffffffffc0207ef8 <commands+0x1788>
ffffffffc0203a9c:	e34fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0203aa0:	b92d                	j	ffffffffc02036da <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0203aa2:	4481                	li	s1,0
ffffffffc0203aa4:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203aa6:	4981                	li	s3,0
ffffffffc0203aa8:	b17d                	j	ffffffffc0203756 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0203aaa:	00004697          	auipc	a3,0x4
ffffffffc0203aae:	20e68693          	addi	a3,a3,526 # ffffffffc0207cb8 <commands+0x1548>
ffffffffc0203ab2:	00003617          	auipc	a2,0x3
ffffffffc0203ab6:	13e60613          	addi	a2,a2,318 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203aba:	0bc00593          	li	a1,188
ffffffffc0203abe:	00004517          	auipc	a0,0x4
ffffffffc0203ac2:	1d250513          	addi	a0,a0,466 # ffffffffc0207c90 <commands+0x1520>
ffffffffc0203ac6:	f50fc0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203aca:	00003617          	auipc	a2,0x3
ffffffffc0203ace:	53660613          	addi	a2,a2,1334 # ffffffffc0207000 <commands+0x890>
ffffffffc0203ad2:	06200593          	li	a1,98
ffffffffc0203ad6:	00003517          	auipc	a0,0x3
ffffffffc0203ada:	54a50513          	addi	a0,a0,1354 # ffffffffc0207020 <commands+0x8b0>
ffffffffc0203ade:	f38fc0ef          	jal	ra,ffffffffc0200216 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203ae2:	00004697          	auipc	a3,0x4
ffffffffc0203ae6:	39e68693          	addi	a3,a3,926 # ffffffffc0207e80 <commands+0x1710>
ffffffffc0203aea:	00003617          	auipc	a2,0x3
ffffffffc0203aee:	10660613          	addi	a2,a2,262 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203af2:	0fc00593          	li	a1,252
ffffffffc0203af6:	00004517          	auipc	a0,0x4
ffffffffc0203afa:	19a50513          	addi	a0,a0,410 # ffffffffc0207c90 <commands+0x1520>
ffffffffc0203afe:	f18fc0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203b02:	00003617          	auipc	a2,0x3
ffffffffc0203b06:	6de60613          	addi	a2,a2,1758 # ffffffffc02071e0 <commands+0xa70>
ffffffffc0203b0a:	07400593          	li	a1,116
ffffffffc0203b0e:	00003517          	auipc	a0,0x3
ffffffffc0203b12:	51250513          	addi	a0,a0,1298 # ffffffffc0207020 <commands+0x8b0>
ffffffffc0203b16:	f00fc0ef          	jal	ra,ffffffffc0200216 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0203b1a:	00004697          	auipc	a3,0x4
ffffffffc0203b1e:	29e68693          	addi	a3,a3,670 # ffffffffc0207db8 <commands+0x1648>
ffffffffc0203b22:	00003617          	auipc	a2,0x3
ffffffffc0203b26:	0ce60613          	addi	a2,a2,206 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203b2a:	0dd00593          	li	a1,221
ffffffffc0203b2e:	00004517          	auipc	a0,0x4
ffffffffc0203b32:	16250513          	addi	a0,a0,354 # ffffffffc0207c90 <commands+0x1520>
ffffffffc0203b36:	ee0fc0ef          	jal	ra,ffffffffc0200216 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0203b3a:	00004697          	auipc	a3,0x4
ffffffffc0203b3e:	26668693          	addi	a3,a3,614 # ffffffffc0207da0 <commands+0x1630>
ffffffffc0203b42:	00003617          	auipc	a2,0x3
ffffffffc0203b46:	0ae60613          	addi	a2,a2,174 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203b4a:	0dc00593          	li	a1,220
ffffffffc0203b4e:	00004517          	auipc	a0,0x4
ffffffffc0203b52:	14250513          	addi	a0,a0,322 # ffffffffc0207c90 <commands+0x1520>
ffffffffc0203b56:	ec0fc0ef          	jal	ra,ffffffffc0200216 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0203b5a:	00004697          	auipc	a3,0x4
ffffffffc0203b5e:	30e68693          	addi	a3,a3,782 # ffffffffc0207e68 <commands+0x16f8>
ffffffffc0203b62:	00003617          	auipc	a2,0x3
ffffffffc0203b66:	08e60613          	addi	a2,a2,142 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203b6a:	0fb00593          	li	a1,251
ffffffffc0203b6e:	00004517          	auipc	a0,0x4
ffffffffc0203b72:	12250513          	addi	a0,a0,290 # ffffffffc0207c90 <commands+0x1520>
ffffffffc0203b76:	ea0fc0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0203b7a:	00004617          	auipc	a2,0x4
ffffffffc0203b7e:	0f660613          	addi	a2,a2,246 # ffffffffc0207c70 <commands+0x1500>
ffffffffc0203b82:	02800593          	li	a1,40
ffffffffc0203b86:	00004517          	auipc	a0,0x4
ffffffffc0203b8a:	10a50513          	addi	a0,a0,266 # ffffffffc0207c90 <commands+0x1520>
ffffffffc0203b8e:	e88fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==2);
ffffffffc0203b92:	00004697          	auipc	a3,0x4
ffffffffc0203b96:	2a668693          	addi	a3,a3,678 # ffffffffc0207e38 <commands+0x16c8>
ffffffffc0203b9a:	00003617          	auipc	a2,0x3
ffffffffc0203b9e:	05660613          	addi	a2,a2,86 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203ba2:	09700593          	li	a1,151
ffffffffc0203ba6:	00004517          	auipc	a0,0x4
ffffffffc0203baa:	0ea50513          	addi	a0,a0,234 # ffffffffc0207c90 <commands+0x1520>
ffffffffc0203bae:	e68fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==2);
ffffffffc0203bb2:	00004697          	auipc	a3,0x4
ffffffffc0203bb6:	28668693          	addi	a3,a3,646 # ffffffffc0207e38 <commands+0x16c8>
ffffffffc0203bba:	00003617          	auipc	a2,0x3
ffffffffc0203bbe:	03660613          	addi	a2,a2,54 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203bc2:	09900593          	li	a1,153
ffffffffc0203bc6:	00004517          	auipc	a0,0x4
ffffffffc0203bca:	0ca50513          	addi	a0,a0,202 # ffffffffc0207c90 <commands+0x1520>
ffffffffc0203bce:	e48fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==3);
ffffffffc0203bd2:	00004697          	auipc	a3,0x4
ffffffffc0203bd6:	27668693          	addi	a3,a3,630 # ffffffffc0207e48 <commands+0x16d8>
ffffffffc0203bda:	00003617          	auipc	a2,0x3
ffffffffc0203bde:	01660613          	addi	a2,a2,22 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203be2:	09b00593          	li	a1,155
ffffffffc0203be6:	00004517          	auipc	a0,0x4
ffffffffc0203bea:	0aa50513          	addi	a0,a0,170 # ffffffffc0207c90 <commands+0x1520>
ffffffffc0203bee:	e28fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==3);
ffffffffc0203bf2:	00004697          	auipc	a3,0x4
ffffffffc0203bf6:	25668693          	addi	a3,a3,598 # ffffffffc0207e48 <commands+0x16d8>
ffffffffc0203bfa:	00003617          	auipc	a2,0x3
ffffffffc0203bfe:	ff660613          	addi	a2,a2,-10 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203c02:	09d00593          	li	a1,157
ffffffffc0203c06:	00004517          	auipc	a0,0x4
ffffffffc0203c0a:	08a50513          	addi	a0,a0,138 # ffffffffc0207c90 <commands+0x1520>
ffffffffc0203c0e:	e08fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==1);
ffffffffc0203c12:	00004697          	auipc	a3,0x4
ffffffffc0203c16:	21668693          	addi	a3,a3,534 # ffffffffc0207e28 <commands+0x16b8>
ffffffffc0203c1a:	00003617          	auipc	a2,0x3
ffffffffc0203c1e:	fd660613          	addi	a2,a2,-42 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203c22:	09300593          	li	a1,147
ffffffffc0203c26:	00004517          	auipc	a0,0x4
ffffffffc0203c2a:	06a50513          	addi	a0,a0,106 # ffffffffc0207c90 <commands+0x1520>
ffffffffc0203c2e:	de8fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==1);
ffffffffc0203c32:	00004697          	auipc	a3,0x4
ffffffffc0203c36:	1f668693          	addi	a3,a3,502 # ffffffffc0207e28 <commands+0x16b8>
ffffffffc0203c3a:	00003617          	auipc	a2,0x3
ffffffffc0203c3e:	fb660613          	addi	a2,a2,-74 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203c42:	09500593          	li	a1,149
ffffffffc0203c46:	00004517          	auipc	a0,0x4
ffffffffc0203c4a:	04a50513          	addi	a0,a0,74 # ffffffffc0207c90 <commands+0x1520>
ffffffffc0203c4e:	dc8fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==4);
ffffffffc0203c52:	00004697          	auipc	a3,0x4
ffffffffc0203c56:	9e668693          	addi	a3,a3,-1562 # ffffffffc0207638 <commands+0xec8>
ffffffffc0203c5a:	00003617          	auipc	a2,0x3
ffffffffc0203c5e:	f9660613          	addi	a2,a2,-106 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203c62:	09f00593          	li	a1,159
ffffffffc0203c66:	00004517          	auipc	a0,0x4
ffffffffc0203c6a:	02a50513          	addi	a0,a0,42 # ffffffffc0207c90 <commands+0x1520>
ffffffffc0203c6e:	da8fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==4);
ffffffffc0203c72:	00004697          	auipc	a3,0x4
ffffffffc0203c76:	9c668693          	addi	a3,a3,-1594 # ffffffffc0207638 <commands+0xec8>
ffffffffc0203c7a:	00003617          	auipc	a2,0x3
ffffffffc0203c7e:	f7660613          	addi	a2,a2,-138 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203c82:	0a100593          	li	a1,161
ffffffffc0203c86:	00004517          	auipc	a0,0x4
ffffffffc0203c8a:	00a50513          	addi	a0,a0,10 # ffffffffc0207c90 <commands+0x1520>
ffffffffc0203c8e:	d88fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203c92:	00004697          	auipc	a3,0x4
ffffffffc0203c96:	e6e68693          	addi	a3,a3,-402 # ffffffffc0207b00 <commands+0x1390>
ffffffffc0203c9a:	00003617          	auipc	a2,0x3
ffffffffc0203c9e:	f5660613          	addi	a2,a2,-170 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203ca2:	0cc00593          	li	a1,204
ffffffffc0203ca6:	00004517          	auipc	a0,0x4
ffffffffc0203caa:	fea50513          	addi	a0,a0,-22 # ffffffffc0207c90 <commands+0x1520>
ffffffffc0203cae:	d68fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(vma != NULL);
ffffffffc0203cb2:	00004697          	auipc	a3,0x4
ffffffffc0203cb6:	eee68693          	addi	a3,a3,-274 # ffffffffc0207ba0 <commands+0x1430>
ffffffffc0203cba:	00003617          	auipc	a2,0x3
ffffffffc0203cbe:	f3660613          	addi	a2,a2,-202 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203cc2:	0cf00593          	li	a1,207
ffffffffc0203cc6:	00004517          	auipc	a0,0x4
ffffffffc0203cca:	fca50513          	addi	a0,a0,-54 # ffffffffc0207c90 <commands+0x1520>
ffffffffc0203cce:	d48fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203cd2:	00004697          	auipc	a3,0x4
ffffffffc0203cd6:	08e68693          	addi	a3,a3,142 # ffffffffc0207d60 <commands+0x15f0>
ffffffffc0203cda:	00003617          	auipc	a2,0x3
ffffffffc0203cde:	f1660613          	addi	a2,a2,-234 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203ce2:	0d700593          	li	a1,215
ffffffffc0203ce6:	00004517          	auipc	a0,0x4
ffffffffc0203cea:	faa50513          	addi	a0,a0,-86 # ffffffffc0207c90 <commands+0x1520>
ffffffffc0203cee:	d28fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert( nr_free == 0);         
ffffffffc0203cf2:	00004697          	auipc	a3,0x4
ffffffffc0203cf6:	16668693          	addi	a3,a3,358 # ffffffffc0207e58 <commands+0x16e8>
ffffffffc0203cfa:	00003617          	auipc	a2,0x3
ffffffffc0203cfe:	ef660613          	addi	a2,a2,-266 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203d02:	0f300593          	li	a1,243
ffffffffc0203d06:	00004517          	auipc	a0,0x4
ffffffffc0203d0a:	f8a50513          	addi	a0,a0,-118 # ffffffffc0207c90 <commands+0x1520>
ffffffffc0203d0e:	d08fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203d12:	00003617          	auipc	a2,0x3
ffffffffc0203d16:	2b660613          	addi	a2,a2,694 # ffffffffc0206fc8 <commands+0x858>
ffffffffc0203d1a:	06900593          	li	a1,105
ffffffffc0203d1e:	00003517          	auipc	a0,0x3
ffffffffc0203d22:	30250513          	addi	a0,a0,770 # ffffffffc0207020 <commands+0x8b0>
ffffffffc0203d26:	cf0fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(count==0);
ffffffffc0203d2a:	00004697          	auipc	a3,0x4
ffffffffc0203d2e:	1ae68693          	addi	a3,a3,430 # ffffffffc0207ed8 <commands+0x1768>
ffffffffc0203d32:	00003617          	auipc	a2,0x3
ffffffffc0203d36:	ebe60613          	addi	a2,a2,-322 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203d3a:	11d00593          	li	a1,285
ffffffffc0203d3e:	00004517          	auipc	a0,0x4
ffffffffc0203d42:	f5250513          	addi	a0,a0,-174 # ffffffffc0207c90 <commands+0x1520>
ffffffffc0203d46:	cd0fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(total==0);
ffffffffc0203d4a:	00004697          	auipc	a3,0x4
ffffffffc0203d4e:	19e68693          	addi	a3,a3,414 # ffffffffc0207ee8 <commands+0x1778>
ffffffffc0203d52:	00003617          	auipc	a2,0x3
ffffffffc0203d56:	e9e60613          	addi	a2,a2,-354 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203d5a:	11e00593          	li	a1,286
ffffffffc0203d5e:	00004517          	auipc	a0,0x4
ffffffffc0203d62:	f3250513          	addi	a0,a0,-206 # ffffffffc0207c90 <commands+0x1520>
ffffffffc0203d66:	cb0fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203d6a:	00004697          	auipc	a3,0x4
ffffffffc0203d6e:	06e68693          	addi	a3,a3,110 # ffffffffc0207dd8 <commands+0x1668>
ffffffffc0203d72:	00003617          	auipc	a2,0x3
ffffffffc0203d76:	e7e60613          	addi	a2,a2,-386 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203d7a:	0ea00593          	li	a1,234
ffffffffc0203d7e:	00004517          	auipc	a0,0x4
ffffffffc0203d82:	f1250513          	addi	a0,a0,-238 # ffffffffc0207c90 <commands+0x1520>
ffffffffc0203d86:	c90fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(mm != NULL);
ffffffffc0203d8a:	00004697          	auipc	a3,0x4
ffffffffc0203d8e:	bee68693          	addi	a3,a3,-1042 # ffffffffc0207978 <commands+0x1208>
ffffffffc0203d92:	00003617          	auipc	a2,0x3
ffffffffc0203d96:	e5e60613          	addi	a2,a2,-418 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203d9a:	0c400593          	li	a1,196
ffffffffc0203d9e:	00004517          	auipc	a0,0x4
ffffffffc0203da2:	ef250513          	addi	a0,a0,-270 # ffffffffc0207c90 <commands+0x1520>
ffffffffc0203da6:	c70fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203daa:	00004697          	auipc	a3,0x4
ffffffffc0203dae:	f6668693          	addi	a3,a3,-154 # ffffffffc0207d10 <commands+0x15a0>
ffffffffc0203db2:	00003617          	auipc	a2,0x3
ffffffffc0203db6:	e3e60613          	addi	a2,a2,-450 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203dba:	0c700593          	li	a1,199
ffffffffc0203dbe:	00004517          	auipc	a0,0x4
ffffffffc0203dc2:	ed250513          	addi	a0,a0,-302 # ffffffffc0207c90 <commands+0x1520>
ffffffffc0203dc6:	c50fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(ret==0);
ffffffffc0203dca:	00004697          	auipc	a3,0x4
ffffffffc0203dce:	10668693          	addi	a3,a3,262 # ffffffffc0207ed0 <commands+0x1760>
ffffffffc0203dd2:	00003617          	auipc	a2,0x3
ffffffffc0203dd6:	e1e60613          	addi	a2,a2,-482 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203dda:	10200593          	li	a1,258
ffffffffc0203dde:	00004517          	auipc	a0,0x4
ffffffffc0203de2:	eb250513          	addi	a0,a0,-334 # ffffffffc0207c90 <commands+0x1520>
ffffffffc0203de6:	c30fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203dea:	00004697          	auipc	a3,0x4
ffffffffc0203dee:	ede68693          	addi	a3,a3,-290 # ffffffffc0207cc8 <commands+0x1558>
ffffffffc0203df2:	00003617          	auipc	a2,0x3
ffffffffc0203df6:	dfe60613          	addi	a2,a2,-514 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203dfa:	0bf00593          	li	a1,191
ffffffffc0203dfe:	00004517          	auipc	a0,0x4
ffffffffc0203e02:	e9250513          	addi	a0,a0,-366 # ffffffffc0207c90 <commands+0x1520>
ffffffffc0203e06:	c10fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0203e0a <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203e0a:	000a8797          	auipc	a5,0xa8
ffffffffc0203e0e:	67678793          	addi	a5,a5,1654 # ffffffffc02ac480 <sm>
ffffffffc0203e12:	639c                	ld	a5,0(a5)
ffffffffc0203e14:	0107b303          	ld	t1,16(a5)
ffffffffc0203e18:	8302                	jr	t1

ffffffffc0203e1a <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203e1a:	000a8797          	auipc	a5,0xa8
ffffffffc0203e1e:	66678793          	addi	a5,a5,1638 # ffffffffc02ac480 <sm>
ffffffffc0203e22:	639c                	ld	a5,0(a5)
ffffffffc0203e24:	0207b303          	ld	t1,32(a5)
ffffffffc0203e28:	8302                	jr	t1

ffffffffc0203e2a <swap_out>:
{
ffffffffc0203e2a:	711d                	addi	sp,sp,-96
ffffffffc0203e2c:	ec86                	sd	ra,88(sp)
ffffffffc0203e2e:	e8a2                	sd	s0,80(sp)
ffffffffc0203e30:	e4a6                	sd	s1,72(sp)
ffffffffc0203e32:	e0ca                	sd	s2,64(sp)
ffffffffc0203e34:	fc4e                	sd	s3,56(sp)
ffffffffc0203e36:	f852                	sd	s4,48(sp)
ffffffffc0203e38:	f456                	sd	s5,40(sp)
ffffffffc0203e3a:	f05a                	sd	s6,32(sp)
ffffffffc0203e3c:	ec5e                	sd	s7,24(sp)
ffffffffc0203e3e:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203e40:	cde9                	beqz	a1,ffffffffc0203f1a <swap_out+0xf0>
ffffffffc0203e42:	8ab2                	mv	s5,a2
ffffffffc0203e44:	892a                	mv	s2,a0
ffffffffc0203e46:	8a2e                	mv	s4,a1
ffffffffc0203e48:	4401                	li	s0,0
ffffffffc0203e4a:	000a8997          	auipc	s3,0xa8
ffffffffc0203e4e:	63698993          	addi	s3,s3,1590 # ffffffffc02ac480 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203e52:	00004b17          	auipc	s6,0x4
ffffffffc0203e56:	126b0b13          	addi	s6,s6,294 # ffffffffc0207f78 <commands+0x1808>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203e5a:	00004b97          	auipc	s7,0x4
ffffffffc0203e5e:	106b8b93          	addi	s7,s7,262 # ffffffffc0207f60 <commands+0x17f0>
ffffffffc0203e62:	a825                	j	ffffffffc0203e9a <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203e64:	67a2                	ld	a5,8(sp)
ffffffffc0203e66:	8626                	mv	a2,s1
ffffffffc0203e68:	85a2                	mv	a1,s0
ffffffffc0203e6a:	7f94                	ld	a3,56(a5)
ffffffffc0203e6c:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203e6e:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203e70:	82b1                	srli	a3,a3,0xc
ffffffffc0203e72:	0685                	addi	a3,a3,1
ffffffffc0203e74:	a5cfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203e78:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203e7a:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203e7c:	7d1c                	ld	a5,56(a0)
ffffffffc0203e7e:	83b1                	srli	a5,a5,0xc
ffffffffc0203e80:	0785                	addi	a5,a5,1
ffffffffc0203e82:	07a2                	slli	a5,a5,0x8
ffffffffc0203e84:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203e88:	872fd0ef          	jal	ra,ffffffffc0200efa <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203e8c:	01893503          	ld	a0,24(s2)
ffffffffc0203e90:	85a6                	mv	a1,s1
ffffffffc0203e92:	c64fe0ef          	jal	ra,ffffffffc02022f6 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203e96:	048a0d63          	beq	s4,s0,ffffffffc0203ef0 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203e9a:	0009b783          	ld	a5,0(s3)
ffffffffc0203e9e:	8656                	mv	a2,s5
ffffffffc0203ea0:	002c                	addi	a1,sp,8
ffffffffc0203ea2:	7b9c                	ld	a5,48(a5)
ffffffffc0203ea4:	854a                	mv	a0,s2
ffffffffc0203ea6:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203ea8:	e12d                	bnez	a0,ffffffffc0203f0a <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203eaa:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203eac:	01893503          	ld	a0,24(s2)
ffffffffc0203eb0:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203eb2:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203eb4:	85a6                	mv	a1,s1
ffffffffc0203eb6:	8cafd0ef          	jal	ra,ffffffffc0200f80 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203eba:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203ebc:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203ebe:	8b85                	andi	a5,a5,1
ffffffffc0203ec0:	cfb9                	beqz	a5,ffffffffc0203f1e <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203ec2:	65a2                	ld	a1,8(sp)
ffffffffc0203ec4:	7d9c                	ld	a5,56(a1)
ffffffffc0203ec6:	83b1                	srli	a5,a5,0xc
ffffffffc0203ec8:	00178513          	addi	a0,a5,1
ffffffffc0203ecc:	0522                	slli	a0,a0,0x8
ffffffffc0203ece:	509000ef          	jal	ra,ffffffffc0204bd6 <swapfs_write>
ffffffffc0203ed2:	d949                	beqz	a0,ffffffffc0203e64 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203ed4:	855e                	mv	a0,s7
ffffffffc0203ed6:	9fafc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203eda:	0009b783          	ld	a5,0(s3)
ffffffffc0203ede:	6622                	ld	a2,8(sp)
ffffffffc0203ee0:	4681                	li	a3,0
ffffffffc0203ee2:	739c                	ld	a5,32(a5)
ffffffffc0203ee4:	85a6                	mv	a1,s1
ffffffffc0203ee6:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203ee8:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203eea:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203eec:	fa8a17e3          	bne	s4,s0,ffffffffc0203e9a <swap_out+0x70>
}
ffffffffc0203ef0:	8522                	mv	a0,s0
ffffffffc0203ef2:	60e6                	ld	ra,88(sp)
ffffffffc0203ef4:	6446                	ld	s0,80(sp)
ffffffffc0203ef6:	64a6                	ld	s1,72(sp)
ffffffffc0203ef8:	6906                	ld	s2,64(sp)
ffffffffc0203efa:	79e2                	ld	s3,56(sp)
ffffffffc0203efc:	7a42                	ld	s4,48(sp)
ffffffffc0203efe:	7aa2                	ld	s5,40(sp)
ffffffffc0203f00:	7b02                	ld	s6,32(sp)
ffffffffc0203f02:	6be2                	ld	s7,24(sp)
ffffffffc0203f04:	6c42                	ld	s8,16(sp)
ffffffffc0203f06:	6125                	addi	sp,sp,96
ffffffffc0203f08:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203f0a:	85a2                	mv	a1,s0
ffffffffc0203f0c:	00004517          	auipc	a0,0x4
ffffffffc0203f10:	00c50513          	addi	a0,a0,12 # ffffffffc0207f18 <commands+0x17a8>
ffffffffc0203f14:	9bcfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                  break;
ffffffffc0203f18:	bfe1                	j	ffffffffc0203ef0 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203f1a:	4401                	li	s0,0
ffffffffc0203f1c:	bfd1                	j	ffffffffc0203ef0 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203f1e:	00004697          	auipc	a3,0x4
ffffffffc0203f22:	02a68693          	addi	a3,a3,42 # ffffffffc0207f48 <commands+0x17d8>
ffffffffc0203f26:	00003617          	auipc	a2,0x3
ffffffffc0203f2a:	cca60613          	addi	a2,a2,-822 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203f2e:	06800593          	li	a1,104
ffffffffc0203f32:	00004517          	auipc	a0,0x4
ffffffffc0203f36:	d5e50513          	addi	a0,a0,-674 # ffffffffc0207c90 <commands+0x1520>
ffffffffc0203f3a:	adcfc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0203f3e <swap_in>:
{
ffffffffc0203f3e:	7179                	addi	sp,sp,-48
ffffffffc0203f40:	e84a                	sd	s2,16(sp)
ffffffffc0203f42:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203f44:	4505                	li	a0,1
{
ffffffffc0203f46:	ec26                	sd	s1,24(sp)
ffffffffc0203f48:	e44e                	sd	s3,8(sp)
ffffffffc0203f4a:	f406                	sd	ra,40(sp)
ffffffffc0203f4c:	f022                	sd	s0,32(sp)
ffffffffc0203f4e:	84ae                	mv	s1,a1
ffffffffc0203f50:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203f52:	f21fc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
     assert(result!=NULL);
ffffffffc0203f56:	c129                	beqz	a0,ffffffffc0203f98 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203f58:	842a                	mv	s0,a0
ffffffffc0203f5a:	01893503          	ld	a0,24(s2)
ffffffffc0203f5e:	4601                	li	a2,0
ffffffffc0203f60:	85a6                	mv	a1,s1
ffffffffc0203f62:	81efd0ef          	jal	ra,ffffffffc0200f80 <get_pte>
ffffffffc0203f66:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203f68:	6108                	ld	a0,0(a0)
ffffffffc0203f6a:	85a2                	mv	a1,s0
ffffffffc0203f6c:	3d3000ef          	jal	ra,ffffffffc0204b3e <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203f70:	00093583          	ld	a1,0(s2)
ffffffffc0203f74:	8626                	mv	a2,s1
ffffffffc0203f76:	00004517          	auipc	a0,0x4
ffffffffc0203f7a:	cba50513          	addi	a0,a0,-838 # ffffffffc0207c30 <commands+0x14c0>
ffffffffc0203f7e:	81a1                	srli	a1,a1,0x8
ffffffffc0203f80:	950fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0203f84:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203f86:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203f8a:	7402                	ld	s0,32(sp)
ffffffffc0203f8c:	64e2                	ld	s1,24(sp)
ffffffffc0203f8e:	6942                	ld	s2,16(sp)
ffffffffc0203f90:	69a2                	ld	s3,8(sp)
ffffffffc0203f92:	4501                	li	a0,0
ffffffffc0203f94:	6145                	addi	sp,sp,48
ffffffffc0203f96:	8082                	ret
     assert(result!=NULL);
ffffffffc0203f98:	00004697          	auipc	a3,0x4
ffffffffc0203f9c:	c8868693          	addi	a3,a3,-888 # ffffffffc0207c20 <commands+0x14b0>
ffffffffc0203fa0:	00003617          	auipc	a2,0x3
ffffffffc0203fa4:	c5060613          	addi	a2,a2,-944 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0203fa8:	07e00593          	li	a1,126
ffffffffc0203fac:	00004517          	auipc	a0,0x4
ffffffffc0203fb0:	ce450513          	addi	a0,a0,-796 # ffffffffc0207c90 <commands+0x1520>
ffffffffc0203fb4:	a62fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0203fb8 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0203fb8:	000a8797          	auipc	a5,0xa8
ffffffffc0203fbc:	60078793          	addi	a5,a5,1536 # ffffffffc02ac5b8 <free_area>
ffffffffc0203fc0:	e79c                	sd	a5,8(a5)
ffffffffc0203fc2:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0203fc4:	0007a823          	sw	zero,16(a5)
}
ffffffffc0203fc8:	8082                	ret

ffffffffc0203fca <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0203fca:	000a8517          	auipc	a0,0xa8
ffffffffc0203fce:	5fe56503          	lwu	a0,1534(a0) # ffffffffc02ac5c8 <free_area+0x10>
ffffffffc0203fd2:	8082                	ret

ffffffffc0203fd4 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0203fd4:	715d                	addi	sp,sp,-80
ffffffffc0203fd6:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc0203fd8:	000a8917          	auipc	s2,0xa8
ffffffffc0203fdc:	5e090913          	addi	s2,s2,1504 # ffffffffc02ac5b8 <free_area>
ffffffffc0203fe0:	00893783          	ld	a5,8(s2)
ffffffffc0203fe4:	e486                	sd	ra,72(sp)
ffffffffc0203fe6:	e0a2                	sd	s0,64(sp)
ffffffffc0203fe8:	fc26                	sd	s1,56(sp)
ffffffffc0203fea:	f44e                	sd	s3,40(sp)
ffffffffc0203fec:	f052                	sd	s4,32(sp)
ffffffffc0203fee:	ec56                	sd	s5,24(sp)
ffffffffc0203ff0:	e85a                	sd	s6,16(sp)
ffffffffc0203ff2:	e45e                	sd	s7,8(sp)
ffffffffc0203ff4:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203ff6:	31278463          	beq	a5,s2,ffffffffc02042fe <default_check+0x32a>
ffffffffc0203ffa:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203ffe:	8305                	srli	a4,a4,0x1
ffffffffc0204000:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0204002:	30070263          	beqz	a4,ffffffffc0204306 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0204006:	4401                	li	s0,0
ffffffffc0204008:	4481                	li	s1,0
ffffffffc020400a:	a031                	j	ffffffffc0204016 <default_check+0x42>
ffffffffc020400c:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0204010:	8b09                	andi	a4,a4,2
ffffffffc0204012:	2e070a63          	beqz	a4,ffffffffc0204306 <default_check+0x332>
        count ++, total += p->property;
ffffffffc0204016:	ff87a703          	lw	a4,-8(a5)
ffffffffc020401a:	679c                	ld	a5,8(a5)
ffffffffc020401c:	2485                	addiw	s1,s1,1
ffffffffc020401e:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0204020:	ff2796e3          	bne	a5,s2,ffffffffc020400c <default_check+0x38>
ffffffffc0204024:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0204026:	f1bfc0ef          	jal	ra,ffffffffc0200f40 <nr_free_pages>
ffffffffc020402a:	73351e63          	bne	a0,s3,ffffffffc0204766 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020402e:	4505                	li	a0,1
ffffffffc0204030:	e43fc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc0204034:	8a2a                	mv	s4,a0
ffffffffc0204036:	46050863          	beqz	a0,ffffffffc02044a6 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020403a:	4505                	li	a0,1
ffffffffc020403c:	e37fc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc0204040:	89aa                	mv	s3,a0
ffffffffc0204042:	74050263          	beqz	a0,ffffffffc0204786 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0204046:	4505                	li	a0,1
ffffffffc0204048:	e2bfc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc020404c:	8aaa                	mv	s5,a0
ffffffffc020404e:	4c050c63          	beqz	a0,ffffffffc0204526 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0204052:	2d3a0a63          	beq	s4,s3,ffffffffc0204326 <default_check+0x352>
ffffffffc0204056:	2caa0863          	beq	s4,a0,ffffffffc0204326 <default_check+0x352>
ffffffffc020405a:	2ca98663          	beq	s3,a0,ffffffffc0204326 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020405e:	000a2783          	lw	a5,0(s4)
ffffffffc0204062:	2e079263          	bnez	a5,ffffffffc0204346 <default_check+0x372>
ffffffffc0204066:	0009a783          	lw	a5,0(s3)
ffffffffc020406a:	2c079e63          	bnez	a5,ffffffffc0204346 <default_check+0x372>
ffffffffc020406e:	411c                	lw	a5,0(a0)
ffffffffc0204070:	2c079b63          	bnez	a5,ffffffffc0204346 <default_check+0x372>
    return page - pages + nbase;
ffffffffc0204074:	000a8797          	auipc	a5,0xa8
ffffffffc0204078:	45c78793          	addi	a5,a5,1116 # ffffffffc02ac4d0 <pages>
ffffffffc020407c:	639c                	ld	a5,0(a5)
ffffffffc020407e:	00005717          	auipc	a4,0x5
ffffffffc0204082:	c5270713          	addi	a4,a4,-942 # ffffffffc0208cd0 <nbase>
ffffffffc0204086:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0204088:	000a8717          	auipc	a4,0xa8
ffffffffc020408c:	3e070713          	addi	a4,a4,992 # ffffffffc02ac468 <npage>
ffffffffc0204090:	6314                	ld	a3,0(a4)
ffffffffc0204092:	40fa0733          	sub	a4,s4,a5
ffffffffc0204096:	8719                	srai	a4,a4,0x6
ffffffffc0204098:	9732                	add	a4,a4,a2
ffffffffc020409a:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020409c:	0732                	slli	a4,a4,0xc
ffffffffc020409e:	2cd77463          	bleu	a3,a4,ffffffffc0204366 <default_check+0x392>
    return page - pages + nbase;
ffffffffc02040a2:	40f98733          	sub	a4,s3,a5
ffffffffc02040a6:	8719                	srai	a4,a4,0x6
ffffffffc02040a8:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02040aa:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02040ac:	4ed77d63          	bleu	a3,a4,ffffffffc02045a6 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc02040b0:	40f507b3          	sub	a5,a0,a5
ffffffffc02040b4:	8799                	srai	a5,a5,0x6
ffffffffc02040b6:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02040b8:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02040ba:	34d7f663          	bleu	a3,a5,ffffffffc0204406 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc02040be:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02040c0:	00093c03          	ld	s8,0(s2)
ffffffffc02040c4:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc02040c8:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc02040cc:	000a8797          	auipc	a5,0xa8
ffffffffc02040d0:	4f27ba23          	sd	s2,1268(a5) # ffffffffc02ac5c0 <free_area+0x8>
ffffffffc02040d4:	000a8797          	auipc	a5,0xa8
ffffffffc02040d8:	4f27b223          	sd	s2,1252(a5) # ffffffffc02ac5b8 <free_area>
    nr_free = 0;
ffffffffc02040dc:	000a8797          	auipc	a5,0xa8
ffffffffc02040e0:	4e07a623          	sw	zero,1260(a5) # ffffffffc02ac5c8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02040e4:	d8ffc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc02040e8:	2e051f63          	bnez	a0,ffffffffc02043e6 <default_check+0x412>
    free_page(p0);
ffffffffc02040ec:	4585                	li	a1,1
ffffffffc02040ee:	8552                	mv	a0,s4
ffffffffc02040f0:	e0bfc0ef          	jal	ra,ffffffffc0200efa <free_pages>
    free_page(p1);
ffffffffc02040f4:	4585                	li	a1,1
ffffffffc02040f6:	854e                	mv	a0,s3
ffffffffc02040f8:	e03fc0ef          	jal	ra,ffffffffc0200efa <free_pages>
    free_page(p2);
ffffffffc02040fc:	4585                	li	a1,1
ffffffffc02040fe:	8556                	mv	a0,s5
ffffffffc0204100:	dfbfc0ef          	jal	ra,ffffffffc0200efa <free_pages>
    assert(nr_free == 3);
ffffffffc0204104:	01092703          	lw	a4,16(s2)
ffffffffc0204108:	478d                	li	a5,3
ffffffffc020410a:	2af71e63          	bne	a4,a5,ffffffffc02043c6 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020410e:	4505                	li	a0,1
ffffffffc0204110:	d63fc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc0204114:	89aa                	mv	s3,a0
ffffffffc0204116:	28050863          	beqz	a0,ffffffffc02043a6 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020411a:	4505                	li	a0,1
ffffffffc020411c:	d57fc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc0204120:	8aaa                	mv	s5,a0
ffffffffc0204122:	3e050263          	beqz	a0,ffffffffc0204506 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0204126:	4505                	li	a0,1
ffffffffc0204128:	d4bfc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc020412c:	8a2a                	mv	s4,a0
ffffffffc020412e:	3a050c63          	beqz	a0,ffffffffc02044e6 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0204132:	4505                	li	a0,1
ffffffffc0204134:	d3ffc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc0204138:	38051763          	bnez	a0,ffffffffc02044c6 <default_check+0x4f2>
    free_page(p0);
ffffffffc020413c:	4585                	li	a1,1
ffffffffc020413e:	854e                	mv	a0,s3
ffffffffc0204140:	dbbfc0ef          	jal	ra,ffffffffc0200efa <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0204144:	00893783          	ld	a5,8(s2)
ffffffffc0204148:	23278f63          	beq	a5,s2,ffffffffc0204386 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc020414c:	4505                	li	a0,1
ffffffffc020414e:	d25fc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc0204152:	32a99a63          	bne	s3,a0,ffffffffc0204486 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0204156:	4505                	li	a0,1
ffffffffc0204158:	d1bfc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc020415c:	30051563          	bnez	a0,ffffffffc0204466 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0204160:	01092783          	lw	a5,16(s2)
ffffffffc0204164:	2e079163          	bnez	a5,ffffffffc0204446 <default_check+0x472>
    free_page(p);
ffffffffc0204168:	854e                	mv	a0,s3
ffffffffc020416a:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc020416c:	000a8797          	auipc	a5,0xa8
ffffffffc0204170:	4587b623          	sd	s8,1100(a5) # ffffffffc02ac5b8 <free_area>
ffffffffc0204174:	000a8797          	auipc	a5,0xa8
ffffffffc0204178:	4577b623          	sd	s7,1100(a5) # ffffffffc02ac5c0 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc020417c:	000a8797          	auipc	a5,0xa8
ffffffffc0204180:	4567a623          	sw	s6,1100(a5) # ffffffffc02ac5c8 <free_area+0x10>
    free_page(p);
ffffffffc0204184:	d77fc0ef          	jal	ra,ffffffffc0200efa <free_pages>
    free_page(p1);
ffffffffc0204188:	4585                	li	a1,1
ffffffffc020418a:	8556                	mv	a0,s5
ffffffffc020418c:	d6ffc0ef          	jal	ra,ffffffffc0200efa <free_pages>
    free_page(p2);
ffffffffc0204190:	4585                	li	a1,1
ffffffffc0204192:	8552                	mv	a0,s4
ffffffffc0204194:	d67fc0ef          	jal	ra,ffffffffc0200efa <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0204198:	4515                	li	a0,5
ffffffffc020419a:	cd9fc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc020419e:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02041a0:	28050363          	beqz	a0,ffffffffc0204426 <default_check+0x452>
ffffffffc02041a4:	651c                	ld	a5,8(a0)
ffffffffc02041a6:	8385                	srli	a5,a5,0x1
ffffffffc02041a8:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc02041aa:	54079e63          	bnez	a5,ffffffffc0204706 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02041ae:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02041b0:	00093b03          	ld	s6,0(s2)
ffffffffc02041b4:	00893a83          	ld	s5,8(s2)
ffffffffc02041b8:	000a8797          	auipc	a5,0xa8
ffffffffc02041bc:	4127b023          	sd	s2,1024(a5) # ffffffffc02ac5b8 <free_area>
ffffffffc02041c0:	000a8797          	auipc	a5,0xa8
ffffffffc02041c4:	4127b023          	sd	s2,1024(a5) # ffffffffc02ac5c0 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc02041c8:	cabfc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc02041cc:	50051d63          	bnez	a0,ffffffffc02046e6 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02041d0:	08098a13          	addi	s4,s3,128
ffffffffc02041d4:	8552                	mv	a0,s4
ffffffffc02041d6:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02041d8:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc02041dc:	000a8797          	auipc	a5,0xa8
ffffffffc02041e0:	3e07a623          	sw	zero,1004(a5) # ffffffffc02ac5c8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc02041e4:	d17fc0ef          	jal	ra,ffffffffc0200efa <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02041e8:	4511                	li	a0,4
ffffffffc02041ea:	c89fc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc02041ee:	4c051c63          	bnez	a0,ffffffffc02046c6 <default_check+0x6f2>
ffffffffc02041f2:	0889b783          	ld	a5,136(s3)
ffffffffc02041f6:	8385                	srli	a5,a5,0x1
ffffffffc02041f8:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02041fa:	4a078663          	beqz	a5,ffffffffc02046a6 <default_check+0x6d2>
ffffffffc02041fe:	0909a703          	lw	a4,144(s3)
ffffffffc0204202:	478d                	li	a5,3
ffffffffc0204204:	4af71163          	bne	a4,a5,ffffffffc02046a6 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0204208:	450d                	li	a0,3
ffffffffc020420a:	c69fc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc020420e:	8c2a                	mv	s8,a0
ffffffffc0204210:	46050b63          	beqz	a0,ffffffffc0204686 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc0204214:	4505                	li	a0,1
ffffffffc0204216:	c5dfc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc020421a:	44051663          	bnez	a0,ffffffffc0204666 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc020421e:	438a1463          	bne	s4,s8,ffffffffc0204646 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0204222:	4585                	li	a1,1
ffffffffc0204224:	854e                	mv	a0,s3
ffffffffc0204226:	cd5fc0ef          	jal	ra,ffffffffc0200efa <free_pages>
    free_pages(p1, 3);
ffffffffc020422a:	458d                	li	a1,3
ffffffffc020422c:	8552                	mv	a0,s4
ffffffffc020422e:	ccdfc0ef          	jal	ra,ffffffffc0200efa <free_pages>
ffffffffc0204232:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0204236:	04098c13          	addi	s8,s3,64
ffffffffc020423a:	8385                	srli	a5,a5,0x1
ffffffffc020423c:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020423e:	3e078463          	beqz	a5,ffffffffc0204626 <default_check+0x652>
ffffffffc0204242:	0109a703          	lw	a4,16(s3)
ffffffffc0204246:	4785                	li	a5,1
ffffffffc0204248:	3cf71f63          	bne	a4,a5,ffffffffc0204626 <default_check+0x652>
ffffffffc020424c:	008a3783          	ld	a5,8(s4)
ffffffffc0204250:	8385                	srli	a5,a5,0x1
ffffffffc0204252:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0204254:	3a078963          	beqz	a5,ffffffffc0204606 <default_check+0x632>
ffffffffc0204258:	010a2703          	lw	a4,16(s4)
ffffffffc020425c:	478d                	li	a5,3
ffffffffc020425e:	3af71463          	bne	a4,a5,ffffffffc0204606 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0204262:	4505                	li	a0,1
ffffffffc0204264:	c0ffc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc0204268:	36a99f63          	bne	s3,a0,ffffffffc02045e6 <default_check+0x612>
    free_page(p0);
ffffffffc020426c:	4585                	li	a1,1
ffffffffc020426e:	c8dfc0ef          	jal	ra,ffffffffc0200efa <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0204272:	4509                	li	a0,2
ffffffffc0204274:	bfffc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc0204278:	34aa1763          	bne	s4,a0,ffffffffc02045c6 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc020427c:	4589                	li	a1,2
ffffffffc020427e:	c7dfc0ef          	jal	ra,ffffffffc0200efa <free_pages>
    free_page(p2);
ffffffffc0204282:	4585                	li	a1,1
ffffffffc0204284:	8562                	mv	a0,s8
ffffffffc0204286:	c75fc0ef          	jal	ra,ffffffffc0200efa <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020428a:	4515                	li	a0,5
ffffffffc020428c:	be7fc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc0204290:	89aa                	mv	s3,a0
ffffffffc0204292:	48050a63          	beqz	a0,ffffffffc0204726 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc0204296:	4505                	li	a0,1
ffffffffc0204298:	bdbfc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc020429c:	2e051563          	bnez	a0,ffffffffc0204586 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc02042a0:	01092783          	lw	a5,16(s2)
ffffffffc02042a4:	2c079163          	bnez	a5,ffffffffc0204566 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02042a8:	4595                	li	a1,5
ffffffffc02042aa:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02042ac:	000a8797          	auipc	a5,0xa8
ffffffffc02042b0:	3177ae23          	sw	s7,796(a5) # ffffffffc02ac5c8 <free_area+0x10>
    free_list = free_list_store;
ffffffffc02042b4:	000a8797          	auipc	a5,0xa8
ffffffffc02042b8:	3167b223          	sd	s6,772(a5) # ffffffffc02ac5b8 <free_area>
ffffffffc02042bc:	000a8797          	auipc	a5,0xa8
ffffffffc02042c0:	3157b223          	sd	s5,772(a5) # ffffffffc02ac5c0 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc02042c4:	c37fc0ef          	jal	ra,ffffffffc0200efa <free_pages>
    return listelm->next;
ffffffffc02042c8:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02042cc:	01278963          	beq	a5,s2,ffffffffc02042de <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02042d0:	ff87a703          	lw	a4,-8(a5)
ffffffffc02042d4:	679c                	ld	a5,8(a5)
ffffffffc02042d6:	34fd                	addiw	s1,s1,-1
ffffffffc02042d8:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02042da:	ff279be3          	bne	a5,s2,ffffffffc02042d0 <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc02042de:	26049463          	bnez	s1,ffffffffc0204546 <default_check+0x572>
    assert(total == 0);
ffffffffc02042e2:	46041263          	bnez	s0,ffffffffc0204746 <default_check+0x772>
}
ffffffffc02042e6:	60a6                	ld	ra,72(sp)
ffffffffc02042e8:	6406                	ld	s0,64(sp)
ffffffffc02042ea:	74e2                	ld	s1,56(sp)
ffffffffc02042ec:	7942                	ld	s2,48(sp)
ffffffffc02042ee:	79a2                	ld	s3,40(sp)
ffffffffc02042f0:	7a02                	ld	s4,32(sp)
ffffffffc02042f2:	6ae2                	ld	s5,24(sp)
ffffffffc02042f4:	6b42                	ld	s6,16(sp)
ffffffffc02042f6:	6ba2                	ld	s7,8(sp)
ffffffffc02042f8:	6c02                	ld	s8,0(sp)
ffffffffc02042fa:	6161                	addi	sp,sp,80
ffffffffc02042fc:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc02042fe:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0204300:	4401                	li	s0,0
ffffffffc0204302:	4481                	li	s1,0
ffffffffc0204304:	b30d                	j	ffffffffc0204026 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0204306:	00004697          	auipc	a3,0x4
ffffffffc020430a:	9b268693          	addi	a3,a3,-1614 # ffffffffc0207cb8 <commands+0x1548>
ffffffffc020430e:	00003617          	auipc	a2,0x3
ffffffffc0204312:	8e260613          	addi	a2,a2,-1822 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204316:	0f000593          	li	a1,240
ffffffffc020431a:	00004517          	auipc	a0,0x4
ffffffffc020431e:	c9e50513          	addi	a0,a0,-866 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204322:	ef5fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0204326:	00004697          	auipc	a3,0x4
ffffffffc020432a:	d0a68693          	addi	a3,a3,-758 # ffffffffc0208030 <commands+0x18c0>
ffffffffc020432e:	00003617          	auipc	a2,0x3
ffffffffc0204332:	8c260613          	addi	a2,a2,-1854 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204336:	0bd00593          	li	a1,189
ffffffffc020433a:	00004517          	auipc	a0,0x4
ffffffffc020433e:	c7e50513          	addi	a0,a0,-898 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204342:	ed5fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0204346:	00004697          	auipc	a3,0x4
ffffffffc020434a:	d1268693          	addi	a3,a3,-750 # ffffffffc0208058 <commands+0x18e8>
ffffffffc020434e:	00003617          	auipc	a2,0x3
ffffffffc0204352:	8a260613          	addi	a2,a2,-1886 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204356:	0be00593          	li	a1,190
ffffffffc020435a:	00004517          	auipc	a0,0x4
ffffffffc020435e:	c5e50513          	addi	a0,a0,-930 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204362:	eb5fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0204366:	00004697          	auipc	a3,0x4
ffffffffc020436a:	d3268693          	addi	a3,a3,-718 # ffffffffc0208098 <commands+0x1928>
ffffffffc020436e:	00003617          	auipc	a2,0x3
ffffffffc0204372:	88260613          	addi	a2,a2,-1918 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204376:	0c000593          	li	a1,192
ffffffffc020437a:	00004517          	auipc	a0,0x4
ffffffffc020437e:	c3e50513          	addi	a0,a0,-962 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204382:	e95fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0204386:	00004697          	auipc	a3,0x4
ffffffffc020438a:	d9a68693          	addi	a3,a3,-614 # ffffffffc0208120 <commands+0x19b0>
ffffffffc020438e:	00003617          	auipc	a2,0x3
ffffffffc0204392:	86260613          	addi	a2,a2,-1950 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204396:	0d900593          	li	a1,217
ffffffffc020439a:	00004517          	auipc	a0,0x4
ffffffffc020439e:	c1e50513          	addi	a0,a0,-994 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc02043a2:	e75fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02043a6:	00004697          	auipc	a3,0x4
ffffffffc02043aa:	c2a68693          	addi	a3,a3,-982 # ffffffffc0207fd0 <commands+0x1860>
ffffffffc02043ae:	00003617          	auipc	a2,0x3
ffffffffc02043b2:	84260613          	addi	a2,a2,-1982 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02043b6:	0d200593          	li	a1,210
ffffffffc02043ba:	00004517          	auipc	a0,0x4
ffffffffc02043be:	bfe50513          	addi	a0,a0,-1026 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc02043c2:	e55fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free == 3);
ffffffffc02043c6:	00004697          	auipc	a3,0x4
ffffffffc02043ca:	d4a68693          	addi	a3,a3,-694 # ffffffffc0208110 <commands+0x19a0>
ffffffffc02043ce:	00003617          	auipc	a2,0x3
ffffffffc02043d2:	82260613          	addi	a2,a2,-2014 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02043d6:	0d000593          	li	a1,208
ffffffffc02043da:	00004517          	auipc	a0,0x4
ffffffffc02043de:	bde50513          	addi	a0,a0,-1058 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc02043e2:	e35fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02043e6:	00004697          	auipc	a3,0x4
ffffffffc02043ea:	d1268693          	addi	a3,a3,-750 # ffffffffc02080f8 <commands+0x1988>
ffffffffc02043ee:	00003617          	auipc	a2,0x3
ffffffffc02043f2:	80260613          	addi	a2,a2,-2046 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02043f6:	0cb00593          	li	a1,203
ffffffffc02043fa:	00004517          	auipc	a0,0x4
ffffffffc02043fe:	bbe50513          	addi	a0,a0,-1090 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204402:	e15fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0204406:	00004697          	auipc	a3,0x4
ffffffffc020440a:	cd268693          	addi	a3,a3,-814 # ffffffffc02080d8 <commands+0x1968>
ffffffffc020440e:	00002617          	auipc	a2,0x2
ffffffffc0204412:	7e260613          	addi	a2,a2,2018 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204416:	0c200593          	li	a1,194
ffffffffc020441a:	00004517          	auipc	a0,0x4
ffffffffc020441e:	b9e50513          	addi	a0,a0,-1122 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204422:	df5fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(p0 != NULL);
ffffffffc0204426:	00004697          	auipc	a3,0x4
ffffffffc020442a:	d3268693          	addi	a3,a3,-718 # ffffffffc0208158 <commands+0x19e8>
ffffffffc020442e:	00002617          	auipc	a2,0x2
ffffffffc0204432:	7c260613          	addi	a2,a2,1986 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204436:	0f800593          	li	a1,248
ffffffffc020443a:	00004517          	auipc	a0,0x4
ffffffffc020443e:	b7e50513          	addi	a0,a0,-1154 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204442:	dd5fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free == 0);
ffffffffc0204446:	00004697          	auipc	a3,0x4
ffffffffc020444a:	a1268693          	addi	a3,a3,-1518 # ffffffffc0207e58 <commands+0x16e8>
ffffffffc020444e:	00002617          	auipc	a2,0x2
ffffffffc0204452:	7a260613          	addi	a2,a2,1954 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204456:	0df00593          	li	a1,223
ffffffffc020445a:	00004517          	auipc	a0,0x4
ffffffffc020445e:	b5e50513          	addi	a0,a0,-1186 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204462:	db5fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0204466:	00004697          	auipc	a3,0x4
ffffffffc020446a:	c9268693          	addi	a3,a3,-878 # ffffffffc02080f8 <commands+0x1988>
ffffffffc020446e:	00002617          	auipc	a2,0x2
ffffffffc0204472:	78260613          	addi	a2,a2,1922 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204476:	0dd00593          	li	a1,221
ffffffffc020447a:	00004517          	auipc	a0,0x4
ffffffffc020447e:	b3e50513          	addi	a0,a0,-1218 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204482:	d95fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0204486:	00004697          	auipc	a3,0x4
ffffffffc020448a:	cb268693          	addi	a3,a3,-846 # ffffffffc0208138 <commands+0x19c8>
ffffffffc020448e:	00002617          	auipc	a2,0x2
ffffffffc0204492:	76260613          	addi	a2,a2,1890 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204496:	0dc00593          	li	a1,220
ffffffffc020449a:	00004517          	auipc	a0,0x4
ffffffffc020449e:	b1e50513          	addi	a0,a0,-1250 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc02044a2:	d75fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02044a6:	00004697          	auipc	a3,0x4
ffffffffc02044aa:	b2a68693          	addi	a3,a3,-1238 # ffffffffc0207fd0 <commands+0x1860>
ffffffffc02044ae:	00002617          	auipc	a2,0x2
ffffffffc02044b2:	74260613          	addi	a2,a2,1858 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02044b6:	0b900593          	li	a1,185
ffffffffc02044ba:	00004517          	auipc	a0,0x4
ffffffffc02044be:	afe50513          	addi	a0,a0,-1282 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc02044c2:	d55fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02044c6:	00004697          	auipc	a3,0x4
ffffffffc02044ca:	c3268693          	addi	a3,a3,-974 # ffffffffc02080f8 <commands+0x1988>
ffffffffc02044ce:	00002617          	auipc	a2,0x2
ffffffffc02044d2:	72260613          	addi	a2,a2,1826 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02044d6:	0d600593          	li	a1,214
ffffffffc02044da:	00004517          	auipc	a0,0x4
ffffffffc02044de:	ade50513          	addi	a0,a0,-1314 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc02044e2:	d35fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02044e6:	00004697          	auipc	a3,0x4
ffffffffc02044ea:	b2a68693          	addi	a3,a3,-1238 # ffffffffc0208010 <commands+0x18a0>
ffffffffc02044ee:	00002617          	auipc	a2,0x2
ffffffffc02044f2:	70260613          	addi	a2,a2,1794 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02044f6:	0d400593          	li	a1,212
ffffffffc02044fa:	00004517          	auipc	a0,0x4
ffffffffc02044fe:	abe50513          	addi	a0,a0,-1346 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204502:	d15fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0204506:	00004697          	auipc	a3,0x4
ffffffffc020450a:	aea68693          	addi	a3,a3,-1302 # ffffffffc0207ff0 <commands+0x1880>
ffffffffc020450e:	00002617          	auipc	a2,0x2
ffffffffc0204512:	6e260613          	addi	a2,a2,1762 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204516:	0d300593          	li	a1,211
ffffffffc020451a:	00004517          	auipc	a0,0x4
ffffffffc020451e:	a9e50513          	addi	a0,a0,-1378 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204522:	cf5fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0204526:	00004697          	auipc	a3,0x4
ffffffffc020452a:	aea68693          	addi	a3,a3,-1302 # ffffffffc0208010 <commands+0x18a0>
ffffffffc020452e:	00002617          	auipc	a2,0x2
ffffffffc0204532:	6c260613          	addi	a2,a2,1730 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204536:	0bb00593          	li	a1,187
ffffffffc020453a:	00004517          	auipc	a0,0x4
ffffffffc020453e:	a7e50513          	addi	a0,a0,-1410 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204542:	cd5fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(count == 0);
ffffffffc0204546:	00004697          	auipc	a3,0x4
ffffffffc020454a:	d6268693          	addi	a3,a3,-670 # ffffffffc02082a8 <commands+0x1b38>
ffffffffc020454e:	00002617          	auipc	a2,0x2
ffffffffc0204552:	6a260613          	addi	a2,a2,1698 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204556:	12500593          	li	a1,293
ffffffffc020455a:	00004517          	auipc	a0,0x4
ffffffffc020455e:	a5e50513          	addi	a0,a0,-1442 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204562:	cb5fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free == 0);
ffffffffc0204566:	00004697          	auipc	a3,0x4
ffffffffc020456a:	8f268693          	addi	a3,a3,-1806 # ffffffffc0207e58 <commands+0x16e8>
ffffffffc020456e:	00002617          	auipc	a2,0x2
ffffffffc0204572:	68260613          	addi	a2,a2,1666 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204576:	11a00593          	li	a1,282
ffffffffc020457a:	00004517          	auipc	a0,0x4
ffffffffc020457e:	a3e50513          	addi	a0,a0,-1474 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204582:	c95fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0204586:	00004697          	auipc	a3,0x4
ffffffffc020458a:	b7268693          	addi	a3,a3,-1166 # ffffffffc02080f8 <commands+0x1988>
ffffffffc020458e:	00002617          	auipc	a2,0x2
ffffffffc0204592:	66260613          	addi	a2,a2,1634 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204596:	11800593          	li	a1,280
ffffffffc020459a:	00004517          	auipc	a0,0x4
ffffffffc020459e:	a1e50513          	addi	a0,a0,-1506 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc02045a2:	c75fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02045a6:	00004697          	auipc	a3,0x4
ffffffffc02045aa:	b1268693          	addi	a3,a3,-1262 # ffffffffc02080b8 <commands+0x1948>
ffffffffc02045ae:	00002617          	auipc	a2,0x2
ffffffffc02045b2:	64260613          	addi	a2,a2,1602 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02045b6:	0c100593          	li	a1,193
ffffffffc02045ba:	00004517          	auipc	a0,0x4
ffffffffc02045be:	9fe50513          	addi	a0,a0,-1538 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc02045c2:	c55fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02045c6:	00004697          	auipc	a3,0x4
ffffffffc02045ca:	ca268693          	addi	a3,a3,-862 # ffffffffc0208268 <commands+0x1af8>
ffffffffc02045ce:	00002617          	auipc	a2,0x2
ffffffffc02045d2:	62260613          	addi	a2,a2,1570 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02045d6:	11200593          	li	a1,274
ffffffffc02045da:	00004517          	auipc	a0,0x4
ffffffffc02045de:	9de50513          	addi	a0,a0,-1570 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc02045e2:	c35fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02045e6:	00004697          	auipc	a3,0x4
ffffffffc02045ea:	c6268693          	addi	a3,a3,-926 # ffffffffc0208248 <commands+0x1ad8>
ffffffffc02045ee:	00002617          	auipc	a2,0x2
ffffffffc02045f2:	60260613          	addi	a2,a2,1538 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02045f6:	11000593          	li	a1,272
ffffffffc02045fa:	00004517          	auipc	a0,0x4
ffffffffc02045fe:	9be50513          	addi	a0,a0,-1602 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204602:	c15fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0204606:	00004697          	auipc	a3,0x4
ffffffffc020460a:	c1a68693          	addi	a3,a3,-998 # ffffffffc0208220 <commands+0x1ab0>
ffffffffc020460e:	00002617          	auipc	a2,0x2
ffffffffc0204612:	5e260613          	addi	a2,a2,1506 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204616:	10e00593          	li	a1,270
ffffffffc020461a:	00004517          	auipc	a0,0x4
ffffffffc020461e:	99e50513          	addi	a0,a0,-1634 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204622:	bf5fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0204626:	00004697          	auipc	a3,0x4
ffffffffc020462a:	bd268693          	addi	a3,a3,-1070 # ffffffffc02081f8 <commands+0x1a88>
ffffffffc020462e:	00002617          	auipc	a2,0x2
ffffffffc0204632:	5c260613          	addi	a2,a2,1474 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204636:	10d00593          	li	a1,269
ffffffffc020463a:	00004517          	auipc	a0,0x4
ffffffffc020463e:	97e50513          	addi	a0,a0,-1666 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204642:	bd5fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0204646:	00004697          	auipc	a3,0x4
ffffffffc020464a:	ba268693          	addi	a3,a3,-1118 # ffffffffc02081e8 <commands+0x1a78>
ffffffffc020464e:	00002617          	auipc	a2,0x2
ffffffffc0204652:	5a260613          	addi	a2,a2,1442 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204656:	10800593          	li	a1,264
ffffffffc020465a:	00004517          	auipc	a0,0x4
ffffffffc020465e:	95e50513          	addi	a0,a0,-1698 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204662:	bb5fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0204666:	00004697          	auipc	a3,0x4
ffffffffc020466a:	a9268693          	addi	a3,a3,-1390 # ffffffffc02080f8 <commands+0x1988>
ffffffffc020466e:	00002617          	auipc	a2,0x2
ffffffffc0204672:	58260613          	addi	a2,a2,1410 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204676:	10700593          	li	a1,263
ffffffffc020467a:	00004517          	auipc	a0,0x4
ffffffffc020467e:	93e50513          	addi	a0,a0,-1730 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204682:	b95fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0204686:	00004697          	auipc	a3,0x4
ffffffffc020468a:	b4268693          	addi	a3,a3,-1214 # ffffffffc02081c8 <commands+0x1a58>
ffffffffc020468e:	00002617          	auipc	a2,0x2
ffffffffc0204692:	56260613          	addi	a2,a2,1378 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204696:	10600593          	li	a1,262
ffffffffc020469a:	00004517          	auipc	a0,0x4
ffffffffc020469e:	91e50513          	addi	a0,a0,-1762 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc02046a2:	b75fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02046a6:	00004697          	auipc	a3,0x4
ffffffffc02046aa:	af268693          	addi	a3,a3,-1294 # ffffffffc0208198 <commands+0x1a28>
ffffffffc02046ae:	00002617          	auipc	a2,0x2
ffffffffc02046b2:	54260613          	addi	a2,a2,1346 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02046b6:	10500593          	li	a1,261
ffffffffc02046ba:	00004517          	auipc	a0,0x4
ffffffffc02046be:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc02046c2:	b55fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02046c6:	00004697          	auipc	a3,0x4
ffffffffc02046ca:	aba68693          	addi	a3,a3,-1350 # ffffffffc0208180 <commands+0x1a10>
ffffffffc02046ce:	00002617          	auipc	a2,0x2
ffffffffc02046d2:	52260613          	addi	a2,a2,1314 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02046d6:	10400593          	li	a1,260
ffffffffc02046da:	00004517          	auipc	a0,0x4
ffffffffc02046de:	8de50513          	addi	a0,a0,-1826 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc02046e2:	b35fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02046e6:	00004697          	auipc	a3,0x4
ffffffffc02046ea:	a1268693          	addi	a3,a3,-1518 # ffffffffc02080f8 <commands+0x1988>
ffffffffc02046ee:	00002617          	auipc	a2,0x2
ffffffffc02046f2:	50260613          	addi	a2,a2,1282 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02046f6:	0fe00593          	li	a1,254
ffffffffc02046fa:	00004517          	auipc	a0,0x4
ffffffffc02046fe:	8be50513          	addi	a0,a0,-1858 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204702:	b15fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(!PageProperty(p0));
ffffffffc0204706:	00004697          	auipc	a3,0x4
ffffffffc020470a:	a6268693          	addi	a3,a3,-1438 # ffffffffc0208168 <commands+0x19f8>
ffffffffc020470e:	00002617          	auipc	a2,0x2
ffffffffc0204712:	4e260613          	addi	a2,a2,1250 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204716:	0f900593          	li	a1,249
ffffffffc020471a:	00004517          	auipc	a0,0x4
ffffffffc020471e:	89e50513          	addi	a0,a0,-1890 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204722:	af5fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0204726:	00004697          	auipc	a3,0x4
ffffffffc020472a:	b6268693          	addi	a3,a3,-1182 # ffffffffc0208288 <commands+0x1b18>
ffffffffc020472e:	00002617          	auipc	a2,0x2
ffffffffc0204732:	4c260613          	addi	a2,a2,1218 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204736:	11700593          	li	a1,279
ffffffffc020473a:	00004517          	auipc	a0,0x4
ffffffffc020473e:	87e50513          	addi	a0,a0,-1922 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204742:	ad5fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(total == 0);
ffffffffc0204746:	00004697          	auipc	a3,0x4
ffffffffc020474a:	b7268693          	addi	a3,a3,-1166 # ffffffffc02082b8 <commands+0x1b48>
ffffffffc020474e:	00002617          	auipc	a2,0x2
ffffffffc0204752:	4a260613          	addi	a2,a2,1186 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204756:	12600593          	li	a1,294
ffffffffc020475a:	00004517          	auipc	a0,0x4
ffffffffc020475e:	85e50513          	addi	a0,a0,-1954 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204762:	ab5fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(total == nr_free_pages());
ffffffffc0204766:	00003697          	auipc	a3,0x3
ffffffffc020476a:	56268693          	addi	a3,a3,1378 # ffffffffc0207cc8 <commands+0x1558>
ffffffffc020476e:	00002617          	auipc	a2,0x2
ffffffffc0204772:	48260613          	addi	a2,a2,1154 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204776:	0f300593          	li	a1,243
ffffffffc020477a:	00004517          	auipc	a0,0x4
ffffffffc020477e:	83e50513          	addi	a0,a0,-1986 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204782:	a95fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0204786:	00004697          	auipc	a3,0x4
ffffffffc020478a:	86a68693          	addi	a3,a3,-1942 # ffffffffc0207ff0 <commands+0x1880>
ffffffffc020478e:	00002617          	auipc	a2,0x2
ffffffffc0204792:	46260613          	addi	a2,a2,1122 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204796:	0ba00593          	li	a1,186
ffffffffc020479a:	00004517          	auipc	a0,0x4
ffffffffc020479e:	81e50513          	addi	a0,a0,-2018 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc02047a2:	a75fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02047a6 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02047a6:	1141                	addi	sp,sp,-16
ffffffffc02047a8:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02047aa:	16058e63          	beqz	a1,ffffffffc0204926 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc02047ae:	00659693          	slli	a3,a1,0x6
ffffffffc02047b2:	96aa                	add	a3,a3,a0
ffffffffc02047b4:	02d50d63          	beq	a0,a3,ffffffffc02047ee <default_free_pages+0x48>
ffffffffc02047b8:	651c                	ld	a5,8(a0)
ffffffffc02047ba:	8b85                	andi	a5,a5,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02047bc:	14079563          	bnez	a5,ffffffffc0204906 <default_free_pages+0x160>
ffffffffc02047c0:	651c                	ld	a5,8(a0)
ffffffffc02047c2:	8385                	srli	a5,a5,0x1
ffffffffc02047c4:	8b85                	andi	a5,a5,1
ffffffffc02047c6:	14079063          	bnez	a5,ffffffffc0204906 <default_free_pages+0x160>
ffffffffc02047ca:	87aa                	mv	a5,a0
ffffffffc02047cc:	a809                	j	ffffffffc02047de <default_free_pages+0x38>
ffffffffc02047ce:	6798                	ld	a4,8(a5)
ffffffffc02047d0:	8b05                	andi	a4,a4,1
ffffffffc02047d2:	12071a63          	bnez	a4,ffffffffc0204906 <default_free_pages+0x160>
ffffffffc02047d6:	6798                	ld	a4,8(a5)
ffffffffc02047d8:	8b09                	andi	a4,a4,2
ffffffffc02047da:	12071663          	bnez	a4,ffffffffc0204906 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc02047de:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc02047e2:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02047e6:	04078793          	addi	a5,a5,64
ffffffffc02047ea:	fed792e3          	bne	a5,a3,ffffffffc02047ce <default_free_pages+0x28>
    base->property = n;
ffffffffc02047ee:	2581                	sext.w	a1,a1
ffffffffc02047f0:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02047f2:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02047f6:	4789                	li	a5,2
ffffffffc02047f8:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02047fc:	000a8697          	auipc	a3,0xa8
ffffffffc0204800:	dbc68693          	addi	a3,a3,-580 # ffffffffc02ac5b8 <free_area>
ffffffffc0204804:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0204806:	669c                	ld	a5,8(a3)
ffffffffc0204808:	9db9                	addw	a1,a1,a4
ffffffffc020480a:	000a8717          	auipc	a4,0xa8
ffffffffc020480e:	dab72f23          	sw	a1,-578(a4) # ffffffffc02ac5c8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0204812:	0cd78163          	beq	a5,a3,ffffffffc02048d4 <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc0204816:	fe878713          	addi	a4,a5,-24
ffffffffc020481a:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020481c:	4801                	li	a6,0
ffffffffc020481e:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0204822:	00e56a63          	bltu	a0,a4,ffffffffc0204836 <default_free_pages+0x90>
    return listelm->next;
ffffffffc0204826:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0204828:	04d70f63          	beq	a4,a3,ffffffffc0204886 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020482c:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020482e:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0204832:	fee57ae3          	bleu	a4,a0,ffffffffc0204826 <default_free_pages+0x80>
ffffffffc0204836:	00080663          	beqz	a6,ffffffffc0204842 <default_free_pages+0x9c>
ffffffffc020483a:	000a8817          	auipc	a6,0xa8
ffffffffc020483e:	d6b83f23          	sd	a1,-642(a6) # ffffffffc02ac5b8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204842:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc0204844:	e390                	sd	a2,0(a5)
ffffffffc0204846:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc0204848:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020484a:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc020484c:	06d58a63          	beq	a1,a3,ffffffffc02048c0 <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc0204850:	ff85a603          	lw	a2,-8(a1) # ff8 <_binary_obj___user_faultread_out_size-0x8580>
        p = le2page(le, page_link);
ffffffffc0204854:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0204858:	02061793          	slli	a5,a2,0x20
ffffffffc020485c:	83e9                	srli	a5,a5,0x1a
ffffffffc020485e:	97ba                	add	a5,a5,a4
ffffffffc0204860:	04f51b63          	bne	a0,a5,ffffffffc02048b6 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc0204864:	491c                	lw	a5,16(a0)
ffffffffc0204866:	9e3d                	addw	a2,a2,a5
ffffffffc0204868:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020486c:	57f5                	li	a5,-3
ffffffffc020486e:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0204872:	01853803          	ld	a6,24(a0)
ffffffffc0204876:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc0204878:	853a                	mv	a0,a4
    prev->next = next;
ffffffffc020487a:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc020487e:	659c                	ld	a5,8(a1)
ffffffffc0204880:	01063023          	sd	a6,0(a2)
ffffffffc0204884:	a815                	j	ffffffffc02048b8 <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc0204886:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0204888:	f114                	sd	a3,32(a0)
ffffffffc020488a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020488c:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020488e:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0204890:	00d70563          	beq	a4,a3,ffffffffc020489a <default_free_pages+0xf4>
ffffffffc0204894:	4805                	li	a6,1
ffffffffc0204896:	87ba                	mv	a5,a4
ffffffffc0204898:	bf59                	j	ffffffffc020482e <default_free_pages+0x88>
ffffffffc020489a:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020489c:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc020489e:	00d78d63          	beq	a5,a3,ffffffffc02048b8 <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc02048a2:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc02048a6:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc02048aa:	02061793          	slli	a5,a2,0x20
ffffffffc02048ae:	83e9                	srli	a5,a5,0x1a
ffffffffc02048b0:	97ba                	add	a5,a5,a4
ffffffffc02048b2:	faf509e3          	beq	a0,a5,ffffffffc0204864 <default_free_pages+0xbe>
ffffffffc02048b6:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc02048b8:	fe878713          	addi	a4,a5,-24
ffffffffc02048bc:	00d78963          	beq	a5,a3,ffffffffc02048ce <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc02048c0:	4910                	lw	a2,16(a0)
ffffffffc02048c2:	02061693          	slli	a3,a2,0x20
ffffffffc02048c6:	82e9                	srli	a3,a3,0x1a
ffffffffc02048c8:	96aa                	add	a3,a3,a0
ffffffffc02048ca:	00d70e63          	beq	a4,a3,ffffffffc02048e6 <default_free_pages+0x140>
}
ffffffffc02048ce:	60a2                	ld	ra,8(sp)
ffffffffc02048d0:	0141                	addi	sp,sp,16
ffffffffc02048d2:	8082                	ret
ffffffffc02048d4:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02048d6:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02048da:	e398                	sd	a4,0(a5)
ffffffffc02048dc:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02048de:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02048e0:	ed1c                	sd	a5,24(a0)
}
ffffffffc02048e2:	0141                	addi	sp,sp,16
ffffffffc02048e4:	8082                	ret
            base->property += p->property;
ffffffffc02048e6:	ff87a703          	lw	a4,-8(a5)
ffffffffc02048ea:	ff078693          	addi	a3,a5,-16
ffffffffc02048ee:	9e39                	addw	a2,a2,a4
ffffffffc02048f0:	c910                	sw	a2,16(a0)
ffffffffc02048f2:	5775                	li	a4,-3
ffffffffc02048f4:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02048f8:	6398                	ld	a4,0(a5)
ffffffffc02048fa:	679c                	ld	a5,8(a5)
}
ffffffffc02048fc:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02048fe:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0204900:	e398                	sd	a4,0(a5)
ffffffffc0204902:	0141                	addi	sp,sp,16
ffffffffc0204904:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0204906:	00004697          	auipc	a3,0x4
ffffffffc020490a:	9c268693          	addi	a3,a3,-1598 # ffffffffc02082c8 <commands+0x1b58>
ffffffffc020490e:	00002617          	auipc	a2,0x2
ffffffffc0204912:	2e260613          	addi	a2,a2,738 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204916:	08300593          	li	a1,131
ffffffffc020491a:	00003517          	auipc	a0,0x3
ffffffffc020491e:	69e50513          	addi	a0,a0,1694 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204922:	8f5fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(n > 0);
ffffffffc0204926:	00004697          	auipc	a3,0x4
ffffffffc020492a:	9ca68693          	addi	a3,a3,-1590 # ffffffffc02082f0 <commands+0x1b80>
ffffffffc020492e:	00002617          	auipc	a2,0x2
ffffffffc0204932:	2c260613          	addi	a2,a2,706 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204936:	08000593          	li	a1,128
ffffffffc020493a:	00003517          	auipc	a0,0x3
ffffffffc020493e:	67e50513          	addi	a0,a0,1662 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204942:	8d5fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204946 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0204946:	c959                	beqz	a0,ffffffffc02049dc <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc0204948:	000a8597          	auipc	a1,0xa8
ffffffffc020494c:	c7058593          	addi	a1,a1,-912 # ffffffffc02ac5b8 <free_area>
ffffffffc0204950:	0105a803          	lw	a6,16(a1)
ffffffffc0204954:	862a                	mv	a2,a0
ffffffffc0204956:	02081793          	slli	a5,a6,0x20
ffffffffc020495a:	9381                	srli	a5,a5,0x20
ffffffffc020495c:	00a7ee63          	bltu	a5,a0,ffffffffc0204978 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0204960:	87ae                	mv	a5,a1
ffffffffc0204962:	a801                	j	ffffffffc0204972 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0204964:	ff87a703          	lw	a4,-8(a5)
ffffffffc0204968:	02071693          	slli	a3,a4,0x20
ffffffffc020496c:	9281                	srli	a3,a3,0x20
ffffffffc020496e:	00c6f763          	bleu	a2,a3,ffffffffc020497c <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0204972:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0204974:	feb798e3          	bne	a5,a1,ffffffffc0204964 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0204978:	4501                	li	a0,0
}
ffffffffc020497a:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc020497c:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc0204980:	dd6d                	beqz	a0,ffffffffc020497a <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0204982:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0204986:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc020498a:	00060e1b          	sext.w	t3,a2
ffffffffc020498e:	0068b423          	sd	t1,8(a7) # fffffffffff80008 <end+0x3fcd3a28>
    next->prev = prev;
ffffffffc0204992:	01133023          	sd	a7,0(t1) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff5580>
        if (page->property > n) {
ffffffffc0204996:	02d67863          	bleu	a3,a2,ffffffffc02049c6 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc020499a:	061a                	slli	a2,a2,0x6
ffffffffc020499c:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc020499e:	41c7073b          	subw	a4,a4,t3
ffffffffc02049a2:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02049a4:	00860693          	addi	a3,a2,8
ffffffffc02049a8:	4709                	li	a4,2
ffffffffc02049aa:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc02049ae:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02049b2:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc02049b6:	0105a803          	lw	a6,16(a1)
ffffffffc02049ba:	e314                	sd	a3,0(a4)
ffffffffc02049bc:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc02049c0:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc02049c2:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc02049c6:	41c8083b          	subw	a6,a6,t3
ffffffffc02049ca:	000a8717          	auipc	a4,0xa8
ffffffffc02049ce:	bf072f23          	sw	a6,-1026(a4) # ffffffffc02ac5c8 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02049d2:	5775                	li	a4,-3
ffffffffc02049d4:	17c1                	addi	a5,a5,-16
ffffffffc02049d6:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc02049da:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02049dc:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02049de:	00004697          	auipc	a3,0x4
ffffffffc02049e2:	91268693          	addi	a3,a3,-1774 # ffffffffc02082f0 <commands+0x1b80>
ffffffffc02049e6:	00002617          	auipc	a2,0x2
ffffffffc02049ea:	20a60613          	addi	a2,a2,522 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02049ee:	06200593          	li	a1,98
ffffffffc02049f2:	00003517          	auipc	a0,0x3
ffffffffc02049f6:	5c650513          	addi	a0,a0,1478 # ffffffffc0207fb8 <commands+0x1848>
default_alloc_pages(size_t n) {
ffffffffc02049fa:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02049fc:	81bfb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204a00 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0204a00:	1141                	addi	sp,sp,-16
ffffffffc0204a02:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0204a04:	c1ed                	beqz	a1,ffffffffc0204ae6 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc0204a06:	00659693          	slli	a3,a1,0x6
ffffffffc0204a0a:	96aa                	add	a3,a3,a0
ffffffffc0204a0c:	02d50463          	beq	a0,a3,ffffffffc0204a34 <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0204a10:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0204a12:	87aa                	mv	a5,a0
ffffffffc0204a14:	8b05                	andi	a4,a4,1
ffffffffc0204a16:	e709                	bnez	a4,ffffffffc0204a20 <default_init_memmap+0x20>
ffffffffc0204a18:	a07d                	j	ffffffffc0204ac6 <default_init_memmap+0xc6>
ffffffffc0204a1a:	6798                	ld	a4,8(a5)
ffffffffc0204a1c:	8b05                	andi	a4,a4,1
ffffffffc0204a1e:	c745                	beqz	a4,ffffffffc0204ac6 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc0204a20:	0007a823          	sw	zero,16(a5)
ffffffffc0204a24:	0007b423          	sd	zero,8(a5)
ffffffffc0204a28:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0204a2c:	04078793          	addi	a5,a5,64
ffffffffc0204a30:	fed795e3          	bne	a5,a3,ffffffffc0204a1a <default_init_memmap+0x1a>
    base->property = n;
ffffffffc0204a34:	2581                	sext.w	a1,a1
ffffffffc0204a36:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204a38:	4789                	li	a5,2
ffffffffc0204a3a:	00850713          	addi	a4,a0,8
ffffffffc0204a3e:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0204a42:	000a8697          	auipc	a3,0xa8
ffffffffc0204a46:	b7668693          	addi	a3,a3,-1162 # ffffffffc02ac5b8 <free_area>
ffffffffc0204a4a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0204a4c:	669c                	ld	a5,8(a3)
ffffffffc0204a4e:	9db9                	addw	a1,a1,a4
ffffffffc0204a50:	000a8717          	auipc	a4,0xa8
ffffffffc0204a54:	b6b72c23          	sw	a1,-1160(a4) # ffffffffc02ac5c8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0204a58:	04d78a63          	beq	a5,a3,ffffffffc0204aac <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc0204a5c:	fe878713          	addi	a4,a5,-24
ffffffffc0204a60:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0204a62:	4801                	li	a6,0
ffffffffc0204a64:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0204a68:	00e56a63          	bltu	a0,a4,ffffffffc0204a7c <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc0204a6c:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0204a6e:	02d70563          	beq	a4,a3,ffffffffc0204a98 <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0204a72:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0204a74:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0204a78:	fee57ae3          	bleu	a4,a0,ffffffffc0204a6c <default_init_memmap+0x6c>
ffffffffc0204a7c:	00080663          	beqz	a6,ffffffffc0204a88 <default_init_memmap+0x88>
ffffffffc0204a80:	000a8717          	auipc	a4,0xa8
ffffffffc0204a84:	b2b73c23          	sd	a1,-1224(a4) # ffffffffc02ac5b8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204a88:	6398                	ld	a4,0(a5)
}
ffffffffc0204a8a:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0204a8c:	e390                	sd	a2,0(a5)
ffffffffc0204a8e:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0204a90:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204a92:	ed18                	sd	a4,24(a0)
ffffffffc0204a94:	0141                	addi	sp,sp,16
ffffffffc0204a96:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0204a98:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0204a9a:	f114                	sd	a3,32(a0)
ffffffffc0204a9c:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0204a9e:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0204aa0:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0204aa2:	00d70e63          	beq	a4,a3,ffffffffc0204abe <default_init_memmap+0xbe>
ffffffffc0204aa6:	4805                	li	a6,1
ffffffffc0204aa8:	87ba                	mv	a5,a4
ffffffffc0204aaa:	b7e9                	j	ffffffffc0204a74 <default_init_memmap+0x74>
}
ffffffffc0204aac:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0204aae:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0204ab2:	e398                	sd	a4,0(a5)
ffffffffc0204ab4:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0204ab6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204ab8:	ed1c                	sd	a5,24(a0)
}
ffffffffc0204aba:	0141                	addi	sp,sp,16
ffffffffc0204abc:	8082                	ret
ffffffffc0204abe:	60a2                	ld	ra,8(sp)
ffffffffc0204ac0:	e290                	sd	a2,0(a3)
ffffffffc0204ac2:	0141                	addi	sp,sp,16
ffffffffc0204ac4:	8082                	ret
        assert(PageReserved(p));
ffffffffc0204ac6:	00004697          	auipc	a3,0x4
ffffffffc0204aca:	83268693          	addi	a3,a3,-1998 # ffffffffc02082f8 <commands+0x1b88>
ffffffffc0204ace:	00002617          	auipc	a2,0x2
ffffffffc0204ad2:	12260613          	addi	a2,a2,290 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204ad6:	04900593          	li	a1,73
ffffffffc0204ada:	00003517          	auipc	a0,0x3
ffffffffc0204ade:	4de50513          	addi	a0,a0,1246 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204ae2:	f34fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(n > 0);
ffffffffc0204ae6:	00004697          	auipc	a3,0x4
ffffffffc0204aea:	80a68693          	addi	a3,a3,-2038 # ffffffffc02082f0 <commands+0x1b80>
ffffffffc0204aee:	00002617          	auipc	a2,0x2
ffffffffc0204af2:	10260613          	addi	a2,a2,258 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0204af6:	04600593          	li	a1,70
ffffffffc0204afa:	00003517          	auipc	a0,0x3
ffffffffc0204afe:	4be50513          	addi	a0,a0,1214 # ffffffffc0207fb8 <commands+0x1848>
ffffffffc0204b02:	f14fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204b06 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204b06:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b08:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204b0a:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b0c:	a29fb0ef          	jal	ra,ffffffffc0200534 <ide_device_valid>
ffffffffc0204b10:	cd01                	beqz	a0,ffffffffc0204b28 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b12:	4505                	li	a0,1
ffffffffc0204b14:	a27fb0ef          	jal	ra,ffffffffc020053a <ide_device_size>
}
ffffffffc0204b18:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b1a:	810d                	srli	a0,a0,0x3
ffffffffc0204b1c:	000a8797          	auipc	a5,0xa8
ffffffffc0204b20:	a4a7be23          	sd	a0,-1444(a5) # ffffffffc02ac578 <max_swap_offset>
}
ffffffffc0204b24:	0141                	addi	sp,sp,16
ffffffffc0204b26:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204b28:	00004617          	auipc	a2,0x4
ffffffffc0204b2c:	83060613          	addi	a2,a2,-2000 # ffffffffc0208358 <default_pmm_manager+0x50>
ffffffffc0204b30:	45b5                	li	a1,13
ffffffffc0204b32:	00004517          	auipc	a0,0x4
ffffffffc0204b36:	84650513          	addi	a0,a0,-1978 # ffffffffc0208378 <default_pmm_manager+0x70>
ffffffffc0204b3a:	edcfb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204b3e <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204b3e:	1141                	addi	sp,sp,-16
ffffffffc0204b40:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b42:	00855793          	srli	a5,a0,0x8
ffffffffc0204b46:	cfb9                	beqz	a5,ffffffffc0204ba4 <swapfs_read+0x66>
ffffffffc0204b48:	000a8717          	auipc	a4,0xa8
ffffffffc0204b4c:	a3070713          	addi	a4,a4,-1488 # ffffffffc02ac578 <max_swap_offset>
ffffffffc0204b50:	6318                	ld	a4,0(a4)
ffffffffc0204b52:	04e7f963          	bleu	a4,a5,ffffffffc0204ba4 <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc0204b56:	000a8717          	auipc	a4,0xa8
ffffffffc0204b5a:	97a70713          	addi	a4,a4,-1670 # ffffffffc02ac4d0 <pages>
ffffffffc0204b5e:	6310                	ld	a2,0(a4)
ffffffffc0204b60:	00004717          	auipc	a4,0x4
ffffffffc0204b64:	17070713          	addi	a4,a4,368 # ffffffffc0208cd0 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204b68:	000a8697          	auipc	a3,0xa8
ffffffffc0204b6c:	90068693          	addi	a3,a3,-1792 # ffffffffc02ac468 <npage>
    return page - pages + nbase;
ffffffffc0204b70:	40c58633          	sub	a2,a1,a2
ffffffffc0204b74:	630c                	ld	a1,0(a4)
ffffffffc0204b76:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204b78:	577d                	li	a4,-1
ffffffffc0204b7a:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204b7c:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204b7e:	8331                	srli	a4,a4,0xc
ffffffffc0204b80:	8f71                	and	a4,a4,a2
ffffffffc0204b82:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b86:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204b88:	02d77a63          	bleu	a3,a4,ffffffffc0204bbc <swapfs_read+0x7e>
ffffffffc0204b8c:	000a8797          	auipc	a5,0xa8
ffffffffc0204b90:	93478793          	addi	a5,a5,-1740 # ffffffffc02ac4c0 <va_pa_offset>
ffffffffc0204b94:	639c                	ld	a5,0(a5)
}
ffffffffc0204b96:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b98:	46a1                	li	a3,8
ffffffffc0204b9a:	963e                	add	a2,a2,a5
ffffffffc0204b9c:	4505                	li	a0,1
}
ffffffffc0204b9e:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204ba0:	9a1fb06f          	j	ffffffffc0200540 <ide_read_secs>
ffffffffc0204ba4:	86aa                	mv	a3,a0
ffffffffc0204ba6:	00003617          	auipc	a2,0x3
ffffffffc0204baa:	7ea60613          	addi	a2,a2,2026 # ffffffffc0208390 <default_pmm_manager+0x88>
ffffffffc0204bae:	45d1                	li	a1,20
ffffffffc0204bb0:	00003517          	auipc	a0,0x3
ffffffffc0204bb4:	7c850513          	addi	a0,a0,1992 # ffffffffc0208378 <default_pmm_manager+0x70>
ffffffffc0204bb8:	e5efb0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0204bbc:	86b2                	mv	a3,a2
ffffffffc0204bbe:	06900593          	li	a1,105
ffffffffc0204bc2:	00002617          	auipc	a2,0x2
ffffffffc0204bc6:	40660613          	addi	a2,a2,1030 # ffffffffc0206fc8 <commands+0x858>
ffffffffc0204bca:	00002517          	auipc	a0,0x2
ffffffffc0204bce:	45650513          	addi	a0,a0,1110 # ffffffffc0207020 <commands+0x8b0>
ffffffffc0204bd2:	e44fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204bd6 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204bd6:	1141                	addi	sp,sp,-16
ffffffffc0204bd8:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bda:	00855793          	srli	a5,a0,0x8
ffffffffc0204bde:	cfb9                	beqz	a5,ffffffffc0204c3c <swapfs_write+0x66>
ffffffffc0204be0:	000a8717          	auipc	a4,0xa8
ffffffffc0204be4:	99870713          	addi	a4,a4,-1640 # ffffffffc02ac578 <max_swap_offset>
ffffffffc0204be8:	6318                	ld	a4,0(a4)
ffffffffc0204bea:	04e7f963          	bleu	a4,a5,ffffffffc0204c3c <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204bee:	000a8717          	auipc	a4,0xa8
ffffffffc0204bf2:	8e270713          	addi	a4,a4,-1822 # ffffffffc02ac4d0 <pages>
ffffffffc0204bf6:	6310                	ld	a2,0(a4)
ffffffffc0204bf8:	00004717          	auipc	a4,0x4
ffffffffc0204bfc:	0d870713          	addi	a4,a4,216 # ffffffffc0208cd0 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204c00:	000a8697          	auipc	a3,0xa8
ffffffffc0204c04:	86868693          	addi	a3,a3,-1944 # ffffffffc02ac468 <npage>
    return page - pages + nbase;
ffffffffc0204c08:	40c58633          	sub	a2,a1,a2
ffffffffc0204c0c:	630c                	ld	a1,0(a4)
ffffffffc0204c0e:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204c10:	577d                	li	a4,-1
ffffffffc0204c12:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204c14:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204c16:	8331                	srli	a4,a4,0xc
ffffffffc0204c18:	8f71                	and	a4,a4,a2
ffffffffc0204c1a:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c1e:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204c20:	02d77a63          	bleu	a3,a4,ffffffffc0204c54 <swapfs_write+0x7e>
ffffffffc0204c24:	000a8797          	auipc	a5,0xa8
ffffffffc0204c28:	89c78793          	addi	a5,a5,-1892 # ffffffffc02ac4c0 <va_pa_offset>
ffffffffc0204c2c:	639c                	ld	a5,0(a5)
}
ffffffffc0204c2e:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c30:	46a1                	li	a3,8
ffffffffc0204c32:	963e                	add	a2,a2,a5
ffffffffc0204c34:	4505                	li	a0,1
}
ffffffffc0204c36:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c38:	92dfb06f          	j	ffffffffc0200564 <ide_write_secs>
ffffffffc0204c3c:	86aa                	mv	a3,a0
ffffffffc0204c3e:	00003617          	auipc	a2,0x3
ffffffffc0204c42:	75260613          	addi	a2,a2,1874 # ffffffffc0208390 <default_pmm_manager+0x88>
ffffffffc0204c46:	45e5                	li	a1,25
ffffffffc0204c48:	00003517          	auipc	a0,0x3
ffffffffc0204c4c:	73050513          	addi	a0,a0,1840 # ffffffffc0208378 <default_pmm_manager+0x70>
ffffffffc0204c50:	dc6fb0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0204c54:	86b2                	mv	a3,a2
ffffffffc0204c56:	06900593          	li	a1,105
ffffffffc0204c5a:	00002617          	auipc	a2,0x2
ffffffffc0204c5e:	36e60613          	addi	a2,a2,878 # ffffffffc0206fc8 <commands+0x858>
ffffffffc0204c62:	00002517          	auipc	a0,0x2
ffffffffc0204c66:	3be50513          	addi	a0,a0,958 # ffffffffc0207020 <commands+0x8b0>
ffffffffc0204c6a:	dacfb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204c6e <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204c6e:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204c72:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204c76:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204c78:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204c7a:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204c7e:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204c82:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204c86:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204c8a:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204c8e:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204c92:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204c96:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204c9a:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204c9e:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204ca2:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204ca6:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204caa:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204cac:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204cae:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204cb2:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204cb6:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204cba:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204cbe:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204cc2:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204cc6:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204cca:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204cce:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204cd2:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204cd6:	8082                	ret

ffffffffc0204cd8 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204cd8:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204cda:	9402                	jalr	s0

	jal do_exit
ffffffffc0204cdc:	73a000ef          	jal	ra,ffffffffc0205416 <do_exit>

ffffffffc0204ce0 <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
ffffffffc0204ce0:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204ce2:	10800513          	li	a0,264
{
ffffffffc0204ce6:	e022                	sd	s0,0(sp)
ffffffffc0204ce8:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204cea:	fc0fe0ef          	jal	ra,ffffffffc02034aa <kmalloc>
ffffffffc0204cee:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc0204cf0:	cd29                	beqz	a0,ffffffffc0204d4a <alloc_proc+0x6a>
        /*
         * below fields(add in LAB5) in proc_struct need to be initialized
         *       uint32_t l;                        // waiting state
         *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
         */
        proc->state = PROC_UNINIT;
ffffffffc0204cf2:	57fd                	li	a5,-1
ffffffffc0204cf4:	1782                	slli	a5,a5,0x20
ffffffffc0204cf6:	e11c                	sd	a5,0(a0)
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204cf8:	07000613          	li	a2,112
ffffffffc0204cfc:	4581                	li	a1,0
        proc->runs = 0;
ffffffffc0204cfe:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc0204d02:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0204d06:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0204d0a:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0204d0e:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204d12:	03050513          	addi	a0,a0,48
ffffffffc0204d16:	4ac010ef          	jal	ra,ffffffffc02061c2 <memset>
        proc->tf = NULL;
        proc->cr3 = boot_cr3;
ffffffffc0204d1a:	000a7797          	auipc	a5,0xa7
ffffffffc0204d1e:	7ae78793          	addi	a5,a5,1966 # ffffffffc02ac4c8 <boot_cr3>
ffffffffc0204d22:	639c                	ld	a5,0(a5)
        proc->tf = NULL;
ffffffffc0204d24:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;
ffffffffc0204d28:	0a042823          	sw	zero,176(s0)
        proc->cr3 = boot_cr3;
ffffffffc0204d2c:	f45c                	sd	a5,168(s0)
        memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc0204d2e:	463d                	li	a2,15
ffffffffc0204d30:	4581                	li	a1,0
ffffffffc0204d32:	0b440513          	addi	a0,s0,180
ffffffffc0204d36:	48c010ef          	jal	ra,ffffffffc02061c2 <memset>
        proc->wait_state = 0;
ffffffffc0204d3a:	0e042623          	sw	zero,236(s0)
        proc->cptr = proc->optr = proc->yptr = NULL;
ffffffffc0204d3e:	0e043c23          	sd	zero,248(s0)
ffffffffc0204d42:	10043023          	sd	zero,256(s0)
ffffffffc0204d46:	0e043823          	sd	zero,240(s0)
    }
    return proc;
}
ffffffffc0204d4a:	8522                	mv	a0,s0
ffffffffc0204d4c:	60a2                	ld	ra,8(sp)
ffffffffc0204d4e:	6402                	ld	s0,0(sp)
ffffffffc0204d50:	0141                	addi	sp,sp,16
ffffffffc0204d52:	8082                	ret

ffffffffc0204d54 <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc0204d54:	000a7797          	auipc	a5,0xa7
ffffffffc0204d58:	73c78793          	addi	a5,a5,1852 # ffffffffc02ac490 <current>
ffffffffc0204d5c:	639c                	ld	a5,0(a5)
ffffffffc0204d5e:	73c8                	ld	a0,160(a5)
ffffffffc0204d60:	84afc06f          	j	ffffffffc0200daa <forkrets>

ffffffffc0204d64 <user_main>:
// user_main - kernel thread used to exec a user program
static int
user_main(void *arg)
{
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d64:	000a7797          	auipc	a5,0xa7
ffffffffc0204d68:	72c78793          	addi	a5,a5,1836 # ffffffffc02ac490 <current>
ffffffffc0204d6c:	639c                	ld	a5,0(a5)
{
ffffffffc0204d6e:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d70:	00004617          	auipc	a2,0x4
ffffffffc0204d74:	a3060613          	addi	a2,a2,-1488 # ffffffffc02087a0 <default_pmm_manager+0x498>
ffffffffc0204d78:	43cc                	lw	a1,4(a5)
ffffffffc0204d7a:	00004517          	auipc	a0,0x4
ffffffffc0204d7e:	a3650513          	addi	a0,a0,-1482 # ffffffffc02087b0 <default_pmm_manager+0x4a8>
{
ffffffffc0204d82:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d84:	b4cfb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0204d88:	00004797          	auipc	a5,0x4
ffffffffc0204d8c:	a1878793          	addi	a5,a5,-1512 # ffffffffc02087a0 <default_pmm_manager+0x498>
ffffffffc0204d90:	3fe05717          	auipc	a4,0x3fe05
ffffffffc0204d94:	55070713          	addi	a4,a4,1360 # a2e0 <_binary_obj___user_forktest_out_size>
ffffffffc0204d98:	e43a                	sd	a4,8(sp)
    int64_t ret = 0, len = strlen(name);
ffffffffc0204d9a:	853e                	mv	a0,a5
ffffffffc0204d9c:	00092717          	auipc	a4,0x92
ffffffffc0204da0:	f7470713          	addi	a4,a4,-140 # ffffffffc0296d10 <_binary_obj___user_forktest_out_start>
ffffffffc0204da4:	f03a                	sd	a4,32(sp)
ffffffffc0204da6:	f43e                	sd	a5,40(sp)
ffffffffc0204da8:	e802                	sd	zero,16(sp)
ffffffffc0204daa:	37a010ef          	jal	ra,ffffffffc0206124 <strlen>
ffffffffc0204dae:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204db0:	4511                	li	a0,4
ffffffffc0204db2:	55a2                	lw	a1,40(sp)
ffffffffc0204db4:	4662                	lw	a2,24(sp)
ffffffffc0204db6:	5682                	lw	a3,32(sp)
ffffffffc0204db8:	4722                	lw	a4,8(sp)
ffffffffc0204dba:	48a9                	li	a7,10
ffffffffc0204dbc:	9002                	ebreak
ffffffffc0204dbe:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204dc0:	65c2                	ld	a1,16(sp)
ffffffffc0204dc2:	00004517          	auipc	a0,0x4
ffffffffc0204dc6:	a1650513          	addi	a0,a0,-1514 # ffffffffc02087d8 <default_pmm_manager+0x4d0>
ffffffffc0204dca:	b06fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204dce:	00004617          	auipc	a2,0x4
ffffffffc0204dd2:	a1a60613          	addi	a2,a2,-1510 # ffffffffc02087e8 <default_pmm_manager+0x4e0>
ffffffffc0204dd6:	3ad00593          	li	a1,941
ffffffffc0204dda:	00004517          	auipc	a0,0x4
ffffffffc0204dde:	a2e50513          	addi	a0,a0,-1490 # ffffffffc0208808 <default_pmm_manager+0x500>
ffffffffc0204de2:	c34fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204de6 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204de6:	6d14                	ld	a3,24(a0)
{
ffffffffc0204de8:	1141                	addi	sp,sp,-16
ffffffffc0204dea:	e406                	sd	ra,8(sp)
ffffffffc0204dec:	c02007b7          	lui	a5,0xc0200
ffffffffc0204df0:	04f6e263          	bltu	a3,a5,ffffffffc0204e34 <put_pgdir+0x4e>
ffffffffc0204df4:	000a7797          	auipc	a5,0xa7
ffffffffc0204df8:	6cc78793          	addi	a5,a5,1740 # ffffffffc02ac4c0 <va_pa_offset>
ffffffffc0204dfc:	6388                	ld	a0,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0204dfe:	000a7797          	auipc	a5,0xa7
ffffffffc0204e02:	66a78793          	addi	a5,a5,1642 # ffffffffc02ac468 <npage>
ffffffffc0204e06:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0204e08:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204e0a:	82b1                	srli	a3,a3,0xc
ffffffffc0204e0c:	04f6f063          	bleu	a5,a3,ffffffffc0204e4c <put_pgdir+0x66>
    return &pages[PPN(pa) - nbase];
ffffffffc0204e10:	00004797          	auipc	a5,0x4
ffffffffc0204e14:	ec078793          	addi	a5,a5,-320 # ffffffffc0208cd0 <nbase>
ffffffffc0204e18:	639c                	ld	a5,0(a5)
ffffffffc0204e1a:	000a7717          	auipc	a4,0xa7
ffffffffc0204e1e:	6b670713          	addi	a4,a4,1718 # ffffffffc02ac4d0 <pages>
ffffffffc0204e22:	6308                	ld	a0,0(a4)
}
ffffffffc0204e24:	60a2                	ld	ra,8(sp)
ffffffffc0204e26:	8e9d                	sub	a3,a3,a5
ffffffffc0204e28:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204e2a:	4585                	li	a1,1
ffffffffc0204e2c:	9536                	add	a0,a0,a3
}
ffffffffc0204e2e:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204e30:	8cafc06f          	j	ffffffffc0200efa <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204e34:	00002617          	auipc	a2,0x2
ffffffffc0204e38:	26c60613          	addi	a2,a2,620 # ffffffffc02070a0 <commands+0x930>
ffffffffc0204e3c:	06e00593          	li	a1,110
ffffffffc0204e40:	00002517          	auipc	a0,0x2
ffffffffc0204e44:	1e050513          	addi	a0,a0,480 # ffffffffc0207020 <commands+0x8b0>
ffffffffc0204e48:	bcefb0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204e4c:	00002617          	auipc	a2,0x2
ffffffffc0204e50:	1b460613          	addi	a2,a2,436 # ffffffffc0207000 <commands+0x890>
ffffffffc0204e54:	06200593          	li	a1,98
ffffffffc0204e58:	00002517          	auipc	a0,0x2
ffffffffc0204e5c:	1c850513          	addi	a0,a0,456 # ffffffffc0207020 <commands+0x8b0>
ffffffffc0204e60:	bb6fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204e64 <setup_pgdir>:
{
ffffffffc0204e64:	1101                	addi	sp,sp,-32
ffffffffc0204e66:	e426                	sd	s1,8(sp)
ffffffffc0204e68:	84aa                	mv	s1,a0
    if ((page = alloc_page()) == NULL)
ffffffffc0204e6a:	4505                	li	a0,1
{
ffffffffc0204e6c:	ec06                	sd	ra,24(sp)
ffffffffc0204e6e:	e822                	sd	s0,16(sp)
    if ((page = alloc_page()) == NULL)
ffffffffc0204e70:	802fc0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
ffffffffc0204e74:	c125                	beqz	a0,ffffffffc0204ed4 <setup_pgdir+0x70>
    return page - pages + nbase;
ffffffffc0204e76:	000a7797          	auipc	a5,0xa7
ffffffffc0204e7a:	65a78793          	addi	a5,a5,1626 # ffffffffc02ac4d0 <pages>
ffffffffc0204e7e:	6394                	ld	a3,0(a5)
ffffffffc0204e80:	00004797          	auipc	a5,0x4
ffffffffc0204e84:	e5078793          	addi	a5,a5,-432 # ffffffffc0208cd0 <nbase>
ffffffffc0204e88:	6380                	ld	s0,0(a5)
ffffffffc0204e8a:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204e8e:	000a7717          	auipc	a4,0xa7
ffffffffc0204e92:	5da70713          	addi	a4,a4,1498 # ffffffffc02ac468 <npage>
    return page - pages + nbase;
ffffffffc0204e96:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204e98:	57fd                	li	a5,-1
ffffffffc0204e9a:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0204e9c:	96a2                	add	a3,a3,s0
    return KADDR(page2pa(page));
ffffffffc0204e9e:	83b1                	srli	a5,a5,0xc
ffffffffc0204ea0:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ea2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204ea4:	02e7fa63          	bleu	a4,a5,ffffffffc0204ed8 <setup_pgdir+0x74>
ffffffffc0204ea8:	000a7797          	auipc	a5,0xa7
ffffffffc0204eac:	61878793          	addi	a5,a5,1560 # ffffffffc02ac4c0 <va_pa_offset>
ffffffffc0204eb0:	6380                	ld	s0,0(a5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0204eb2:	000a7797          	auipc	a5,0xa7
ffffffffc0204eb6:	5ae78793          	addi	a5,a5,1454 # ffffffffc02ac460 <boot_pgdir>
ffffffffc0204eba:	638c                	ld	a1,0(a5)
ffffffffc0204ebc:	9436                	add	s0,s0,a3
ffffffffc0204ebe:	6605                	lui	a2,0x1
ffffffffc0204ec0:	8522                	mv	a0,s0
ffffffffc0204ec2:	312010ef          	jal	ra,ffffffffc02061d4 <memcpy>
    return 0;
ffffffffc0204ec6:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc0204ec8:	ec80                	sd	s0,24(s1)
}
ffffffffc0204eca:	60e2                	ld	ra,24(sp)
ffffffffc0204ecc:	6442                	ld	s0,16(sp)
ffffffffc0204ece:	64a2                	ld	s1,8(sp)
ffffffffc0204ed0:	6105                	addi	sp,sp,32
ffffffffc0204ed2:	8082                	ret
        return -E_NO_MEM;
ffffffffc0204ed4:	5571                	li	a0,-4
ffffffffc0204ed6:	bfd5                	j	ffffffffc0204eca <setup_pgdir+0x66>
ffffffffc0204ed8:	00002617          	auipc	a2,0x2
ffffffffc0204edc:	0f060613          	addi	a2,a2,240 # ffffffffc0206fc8 <commands+0x858>
ffffffffc0204ee0:	06900593          	li	a1,105
ffffffffc0204ee4:	00002517          	auipc	a0,0x2
ffffffffc0204ee8:	13c50513          	addi	a0,a0,316 # ffffffffc0207020 <commands+0x8b0>
ffffffffc0204eec:	b2afb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204ef0 <set_proc_name>:
{
ffffffffc0204ef0:	1101                	addi	sp,sp,-32
ffffffffc0204ef2:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ef4:	0b450413          	addi	s0,a0,180
{
ffffffffc0204ef8:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204efa:	4641                	li	a2,16
{
ffffffffc0204efc:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204efe:	8522                	mv	a0,s0
ffffffffc0204f00:	4581                	li	a1,0
{
ffffffffc0204f02:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204f04:	2be010ef          	jal	ra,ffffffffc02061c2 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204f08:	8522                	mv	a0,s0
}
ffffffffc0204f0a:	6442                	ld	s0,16(sp)
ffffffffc0204f0c:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204f0e:	85a6                	mv	a1,s1
}
ffffffffc0204f10:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204f12:	463d                	li	a2,15
}
ffffffffc0204f14:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204f16:	2be0106f          	j	ffffffffc02061d4 <memcpy>

ffffffffc0204f1a <proc_run>:
{
ffffffffc0204f1a:	1101                	addi	sp,sp,-32
    if (proc != current)
ffffffffc0204f1c:	000a7797          	auipc	a5,0xa7
ffffffffc0204f20:	57478793          	addi	a5,a5,1396 # ffffffffc02ac490 <current>
{
ffffffffc0204f24:	e426                	sd	s1,8(sp)
    if (proc != current)
ffffffffc0204f26:	6384                	ld	s1,0(a5)
{
ffffffffc0204f28:	ec06                	sd	ra,24(sp)
ffffffffc0204f2a:	e822                	sd	s0,16(sp)
ffffffffc0204f2c:	e04a                	sd	s2,0(sp)
    if (proc != current)
ffffffffc0204f2e:	02a48b63          	beq	s1,a0,ffffffffc0204f64 <proc_run+0x4a>
ffffffffc0204f32:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f34:	100027f3          	csrr	a5,sstatus
ffffffffc0204f38:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204f3a:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f3c:	e3a9                	bnez	a5,ffffffffc0204f7e <proc_run+0x64>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204f3e:	745c                	ld	a5,168(s0)
            current = proc;
ffffffffc0204f40:	000a7717          	auipc	a4,0xa7
ffffffffc0204f44:	54873823          	sd	s0,1360(a4) # ffffffffc02ac490 <current>
ffffffffc0204f48:	577d                	li	a4,-1
ffffffffc0204f4a:	177e                	slli	a4,a4,0x3f
ffffffffc0204f4c:	83b1                	srli	a5,a5,0xc
ffffffffc0204f4e:	8fd9                	or	a5,a5,a4
ffffffffc0204f50:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc0204f54:	03040593          	addi	a1,s0,48
ffffffffc0204f58:	03048513          	addi	a0,s1,48
ffffffffc0204f5c:	d13ff0ef          	jal	ra,ffffffffc0204c6e <switch_to>
    if (flag) {
ffffffffc0204f60:	00091863          	bnez	s2,ffffffffc0204f70 <proc_run+0x56>
}
ffffffffc0204f64:	60e2                	ld	ra,24(sp)
ffffffffc0204f66:	6442                	ld	s0,16(sp)
ffffffffc0204f68:	64a2                	ld	s1,8(sp)
ffffffffc0204f6a:	6902                	ld	s2,0(sp)
ffffffffc0204f6c:	6105                	addi	sp,sp,32
ffffffffc0204f6e:	8082                	ret
ffffffffc0204f70:	6442                	ld	s0,16(sp)
ffffffffc0204f72:	60e2                	ld	ra,24(sp)
ffffffffc0204f74:	64a2                	ld	s1,8(sp)
ffffffffc0204f76:	6902                	ld	s2,0(sp)
ffffffffc0204f78:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204f7a:	edcfb06f          	j	ffffffffc0200656 <intr_enable>
        intr_disable();
ffffffffc0204f7e:	edefb0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc0204f82:	4905                	li	s2,1
ffffffffc0204f84:	bf6d                	j	ffffffffc0204f3e <proc_run+0x24>

ffffffffc0204f86 <find_proc>:
    if (0 < pid && pid < MAX_PID)
ffffffffc0204f86:	0005071b          	sext.w	a4,a0
ffffffffc0204f8a:	6789                	lui	a5,0x2
ffffffffc0204f8c:	fff7069b          	addiw	a3,a4,-1
ffffffffc0204f90:	17f9                	addi	a5,a5,-2
ffffffffc0204f92:	04d7e063          	bltu	a5,a3,ffffffffc0204fd2 <find_proc+0x4c>
{
ffffffffc0204f96:	1141                	addi	sp,sp,-16
ffffffffc0204f98:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204f9a:	45a9                	li	a1,10
ffffffffc0204f9c:	842a                	mv	s0,a0
ffffffffc0204f9e:	853a                	mv	a0,a4
{
ffffffffc0204fa0:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204fa2:	642010ef          	jal	ra,ffffffffc02065e4 <hash32>
ffffffffc0204fa6:	02051693          	slli	a3,a0,0x20
ffffffffc0204faa:	82f1                	srli	a3,a3,0x1c
ffffffffc0204fac:	000a3517          	auipc	a0,0xa3
ffffffffc0204fb0:	4a450513          	addi	a0,a0,1188 # ffffffffc02a8450 <hash_list>
ffffffffc0204fb4:	96aa                	add	a3,a3,a0
ffffffffc0204fb6:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc0204fb8:	a029                	j	ffffffffc0204fc2 <find_proc+0x3c>
            if (proc->pid == pid)
ffffffffc0204fba:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x764c>
ffffffffc0204fbe:	00870c63          	beq	a4,s0,ffffffffc0204fd6 <find_proc+0x50>
    return listelm->next;
ffffffffc0204fc2:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204fc4:	fef69be3          	bne	a3,a5,ffffffffc0204fba <find_proc+0x34>
}
ffffffffc0204fc8:	60a2                	ld	ra,8(sp)
ffffffffc0204fca:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0204fcc:	4501                	li	a0,0
}
ffffffffc0204fce:	0141                	addi	sp,sp,16
ffffffffc0204fd0:	8082                	ret
    return NULL;
ffffffffc0204fd2:	4501                	li	a0,0
}
ffffffffc0204fd4:	8082                	ret
ffffffffc0204fd6:	60a2                	ld	ra,8(sp)
ffffffffc0204fd8:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204fda:	f2878513          	addi	a0,a5,-216
}
ffffffffc0204fde:	0141                	addi	sp,sp,16
ffffffffc0204fe0:	8082                	ret

ffffffffc0204fe2 <do_fork>:
{
ffffffffc0204fe2:	715d                	addi	sp,sp,-80
ffffffffc0204fe4:	f84a                	sd	s2,48(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc0204fe6:	000a7917          	auipc	s2,0xa7
ffffffffc0204fea:	4c290913          	addi	s2,s2,1218 # ffffffffc02ac4a8 <nr_process>
ffffffffc0204fee:	00092703          	lw	a4,0(s2)
{
ffffffffc0204ff2:	e486                	sd	ra,72(sp)
ffffffffc0204ff4:	e0a2                	sd	s0,64(sp)
ffffffffc0204ff6:	fc26                	sd	s1,56(sp)
ffffffffc0204ff8:	f44e                	sd	s3,40(sp)
ffffffffc0204ffa:	f052                	sd	s4,32(sp)
ffffffffc0204ffc:	ec56                	sd	s5,24(sp)
ffffffffc0204ffe:	e85a                	sd	s6,16(sp)
ffffffffc0205000:	e45e                	sd	s7,8(sp)
ffffffffc0205002:	e062                	sd	s8,0(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc0205004:	6785                	lui	a5,0x1
ffffffffc0205006:	32f75163          	ble	a5,a4,ffffffffc0205328 <do_fork+0x346>
ffffffffc020500a:	8aaa                	mv	s5,a0
ffffffffc020500c:	89ae                	mv	s3,a1
ffffffffc020500e:	84b2                	mv	s1,a2
    if ((proc = alloc_proc()) == NULL)
ffffffffc0205010:	cd1ff0ef          	jal	ra,ffffffffc0204ce0 <alloc_proc>
ffffffffc0205014:	842a                	mv	s0,a0
ffffffffc0205016:	30050463          	beqz	a0,ffffffffc020531e <do_fork+0x33c>
    proc->parent = current;
ffffffffc020501a:	000a7a17          	auipc	s4,0xa7
ffffffffc020501e:	476a0a13          	addi	s4,s4,1142 # ffffffffc02ac490 <current>
ffffffffc0205022:	000a3783          	ld	a5,0(s4)
    assert(current->wait_state == 0);
ffffffffc0205026:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x848c>
    proc->parent = current;
ffffffffc020502a:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc020502c:	30071063          	bnez	a4,ffffffffc020532c <do_fork+0x34a>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0205030:	4509                	li	a0,2
ffffffffc0205032:	e41fb0ef          	jal	ra,ffffffffc0200e72 <alloc_pages>
    if (page != NULL)
ffffffffc0205036:	2a050063          	beqz	a0,ffffffffc02052d6 <do_fork+0x2f4>
    return page - pages + nbase;
ffffffffc020503a:	000a7797          	auipc	a5,0xa7
ffffffffc020503e:	49678793          	addi	a5,a5,1174 # ffffffffc02ac4d0 <pages>
ffffffffc0205042:	6394                	ld	a3,0(a5)
ffffffffc0205044:	00004797          	auipc	a5,0x4
ffffffffc0205048:	c8c78793          	addi	a5,a5,-884 # ffffffffc0208cd0 <nbase>
    return KADDR(page2pa(page));
ffffffffc020504c:	000a7717          	auipc	a4,0xa7
ffffffffc0205050:	41c70713          	addi	a4,a4,1052 # ffffffffc02ac468 <npage>
    return page - pages + nbase;
ffffffffc0205054:	40d506b3          	sub	a3,a0,a3
ffffffffc0205058:	6388                	ld	a0,0(a5)
ffffffffc020505a:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020505c:	57fd                	li	a5,-1
ffffffffc020505e:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0205060:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0205062:	83b1                	srli	a5,a5,0xc
ffffffffc0205064:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0205066:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205068:	2ee7f263          	bleu	a4,a5,ffffffffc020534c <do_fork+0x36a>
ffffffffc020506c:	000a7b17          	auipc	s6,0xa7
ffffffffc0205070:	454b0b13          	addi	s6,s6,1108 # ffffffffc02ac4c0 <va_pa_offset>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0205074:	000a3703          	ld	a4,0(s4)
ffffffffc0205078:	000b3783          	ld	a5,0(s6)
ffffffffc020507c:	02873a03          	ld	s4,40(a4)
ffffffffc0205080:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0205082:	e814                	sd	a3,16(s0)
    if (oldmm == NULL)
ffffffffc0205084:	020a0863          	beqz	s4,ffffffffc02050b4 <do_fork+0xd2>
    if (clone_flags & CLONE_VM)
ffffffffc0205088:	100afa93          	andi	s5,s5,256
ffffffffc020508c:	1e0a8163          	beqz	s5,ffffffffc020526e <do_fork+0x28c>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0205090:	030a2703          	lw	a4,48(s4)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205094:	018a3783          	ld	a5,24(s4)
ffffffffc0205098:	c02006b7          	lui	a3,0xc0200
ffffffffc020509c:	2705                	addiw	a4,a4,1
ffffffffc020509e:	02ea2823          	sw	a4,48(s4)
    proc->mm = mm;
ffffffffc02050a2:	03443423          	sd	s4,40(s0)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02050a6:	2ad7ef63          	bltu	a5,a3,ffffffffc0205364 <do_fork+0x382>
ffffffffc02050aa:	000b3703          	ld	a4,0(s6)
ffffffffc02050ae:	6814                	ld	a3,16(s0)
ffffffffc02050b0:	8f99                	sub	a5,a5,a4
ffffffffc02050b2:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02050b4:	6789                	lui	a5,0x2
ffffffffc02050b6:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7698>
ffffffffc02050ba:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc02050bc:	8626                	mv	a2,s1
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02050be:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc02050c0:	87b6                	mv	a5,a3
ffffffffc02050c2:	12048893          	addi	a7,s1,288
ffffffffc02050c6:	00063803          	ld	a6,0(a2)
ffffffffc02050ca:	6608                	ld	a0,8(a2)
ffffffffc02050cc:	6a0c                	ld	a1,16(a2)
ffffffffc02050ce:	6e18                	ld	a4,24(a2)
ffffffffc02050d0:	0107b023          	sd	a6,0(a5)
ffffffffc02050d4:	e788                	sd	a0,8(a5)
ffffffffc02050d6:	eb8c                	sd	a1,16(a5)
ffffffffc02050d8:	ef98                	sd	a4,24(a5)
ffffffffc02050da:	02060613          	addi	a2,a2,32
ffffffffc02050de:	02078793          	addi	a5,a5,32
ffffffffc02050e2:	ff1612e3          	bne	a2,a7,ffffffffc02050c6 <do_fork+0xe4>
    proc->tf->gpr.a0 = 0;
ffffffffc02050e6:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02050ea:	12098b63          	beqz	s3,ffffffffc0205220 <do_fork+0x23e>
ffffffffc02050ee:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02050f2:	00000797          	auipc	a5,0x0
ffffffffc02050f6:	c6278793          	addi	a5,a5,-926 # ffffffffc0204d54 <forkret>
ffffffffc02050fa:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02050fc:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050fe:	100027f3          	csrr	a5,sstatus
ffffffffc0205102:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205104:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205106:	12079c63          	bnez	a5,ffffffffc020523e <do_fork+0x25c>
    if (++last_pid >= MAX_PID)
ffffffffc020510a:	0009c797          	auipc	a5,0x9c
ffffffffc020510e:	f3e78793          	addi	a5,a5,-194 # ffffffffc02a1048 <last_pid.1691>
ffffffffc0205112:	439c                	lw	a5,0(a5)
ffffffffc0205114:	6709                	lui	a4,0x2
ffffffffc0205116:	0017851b          	addiw	a0,a5,1
ffffffffc020511a:	0009c697          	auipc	a3,0x9c
ffffffffc020511e:	f2a6a723          	sw	a0,-210(a3) # ffffffffc02a1048 <last_pid.1691>
ffffffffc0205122:	12e55f63          	ble	a4,a0,ffffffffc0205260 <do_fork+0x27e>
    if (last_pid >= next_safe)
ffffffffc0205126:	0009c797          	auipc	a5,0x9c
ffffffffc020512a:	f2678793          	addi	a5,a5,-218 # ffffffffc02a104c <next_safe.1690>
ffffffffc020512e:	439c                	lw	a5,0(a5)
ffffffffc0205130:	000a7497          	auipc	s1,0xa7
ffffffffc0205134:	4a048493          	addi	s1,s1,1184 # ffffffffc02ac5d0 <proc_list>
ffffffffc0205138:	06f54063          	blt	a0,a5,ffffffffc0205198 <do_fork+0x1b6>
        next_safe = MAX_PID;
ffffffffc020513c:	6789                	lui	a5,0x2
ffffffffc020513e:	0009c717          	auipc	a4,0x9c
ffffffffc0205142:	f0f72723          	sw	a5,-242(a4) # ffffffffc02a104c <next_safe.1690>
ffffffffc0205146:	4581                	li	a1,0
ffffffffc0205148:	87aa                	mv	a5,a0
ffffffffc020514a:	000a7497          	auipc	s1,0xa7
ffffffffc020514e:	48648493          	addi	s1,s1,1158 # ffffffffc02ac5d0 <proc_list>
    repeat:
ffffffffc0205152:	6889                	lui	a7,0x2
ffffffffc0205154:	882e                	mv	a6,a1
ffffffffc0205156:	6609                	lui	a2,0x2
        le = list;
ffffffffc0205158:	000a7697          	auipc	a3,0xa7
ffffffffc020515c:	47868693          	addi	a3,a3,1144 # ffffffffc02ac5d0 <proc_list>
ffffffffc0205160:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list)
ffffffffc0205162:	00968f63          	beq	a3,s1,ffffffffc0205180 <do_fork+0x19e>
            if (proc->pid == last_pid)
ffffffffc0205166:	f3c6a703          	lw	a4,-196(a3)
ffffffffc020516a:	0af70663          	beq	a4,a5,ffffffffc0205216 <do_fork+0x234>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc020516e:	fee7d9e3          	ble	a4,a5,ffffffffc0205160 <do_fork+0x17e>
ffffffffc0205172:	fec757e3          	ble	a2,a4,ffffffffc0205160 <do_fork+0x17e>
ffffffffc0205176:	6694                	ld	a3,8(a3)
ffffffffc0205178:	863a                	mv	a2,a4
ffffffffc020517a:	4805                	li	a6,1
        while ((le = list_next(le)) != list)
ffffffffc020517c:	fe9695e3          	bne	a3,s1,ffffffffc0205166 <do_fork+0x184>
ffffffffc0205180:	c591                	beqz	a1,ffffffffc020518c <do_fork+0x1aa>
ffffffffc0205182:	0009c717          	auipc	a4,0x9c
ffffffffc0205186:	ecf72323          	sw	a5,-314(a4) # ffffffffc02a1048 <last_pid.1691>
ffffffffc020518a:	853e                	mv	a0,a5
ffffffffc020518c:	00080663          	beqz	a6,ffffffffc0205198 <do_fork+0x1b6>
ffffffffc0205190:	0009c797          	auipc	a5,0x9c
ffffffffc0205194:	eac7ae23          	sw	a2,-324(a5) # ffffffffc02a104c <next_safe.1690>
        proc->pid = get_pid();
ffffffffc0205198:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020519a:	45a9                	li	a1,10
ffffffffc020519c:	2501                	sext.w	a0,a0
ffffffffc020519e:	446010ef          	jal	ra,ffffffffc02065e4 <hash32>
ffffffffc02051a2:	1502                	slli	a0,a0,0x20
ffffffffc02051a4:	000a3797          	auipc	a5,0xa3
ffffffffc02051a8:	2ac78793          	addi	a5,a5,684 # ffffffffc02a8450 <hash_list>
ffffffffc02051ac:	8171                	srli	a0,a0,0x1c
ffffffffc02051ae:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02051b0:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc02051b2:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02051b4:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc02051b8:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02051ba:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc02051bc:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc02051be:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc02051c0:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc02051c4:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc02051c6:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc02051c8:	e21c                	sd	a5,0(a2)
ffffffffc02051ca:	000a7597          	auipc	a1,0xa7
ffffffffc02051ce:	40f5b723          	sd	a5,1038(a1) # ffffffffc02ac5d8 <proc_list+0x8>
    elm->next = next;
ffffffffc02051d2:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc02051d4:	e464                	sd	s1,200(s0)
    proc->yptr = NULL;
ffffffffc02051d6:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc02051da:	10e43023          	sd	a4,256(s0)
ffffffffc02051de:	c311                	beqz	a4,ffffffffc02051e2 <do_fork+0x200>
        proc->optr->yptr = proc;
ffffffffc02051e0:	ff60                	sd	s0,248(a4)
    nr_process++;
ffffffffc02051e2:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc;
ffffffffc02051e6:	fae0                	sd	s0,240(a3)
    nr_process++;
ffffffffc02051e8:	2785                	addiw	a5,a5,1
ffffffffc02051ea:	000a7717          	auipc	a4,0xa7
ffffffffc02051ee:	2af72f23          	sw	a5,702(a4) # ffffffffc02ac4a8 <nr_process>
    if (flag) {
ffffffffc02051f2:	0c099a63          	bnez	s3,ffffffffc02052c6 <do_fork+0x2e4>
    wakeup_proc(proc);
ffffffffc02051f6:	8522                	mv	a0,s0
ffffffffc02051f8:	53b000ef          	jal	ra,ffffffffc0205f32 <wakeup_proc>
    ret = proc->pid;
ffffffffc02051fc:	4048                	lw	a0,4(s0)
}
ffffffffc02051fe:	60a6                	ld	ra,72(sp)
ffffffffc0205200:	6406                	ld	s0,64(sp)
ffffffffc0205202:	74e2                	ld	s1,56(sp)
ffffffffc0205204:	7942                	ld	s2,48(sp)
ffffffffc0205206:	79a2                	ld	s3,40(sp)
ffffffffc0205208:	7a02                	ld	s4,32(sp)
ffffffffc020520a:	6ae2                	ld	s5,24(sp)
ffffffffc020520c:	6b42                	ld	s6,16(sp)
ffffffffc020520e:	6ba2                	ld	s7,8(sp)
ffffffffc0205210:	6c02                	ld	s8,0(sp)
ffffffffc0205212:	6161                	addi	sp,sp,80
ffffffffc0205214:	8082                	ret
                if (++last_pid >= next_safe)
ffffffffc0205216:	2785                	addiw	a5,a5,1
ffffffffc0205218:	0ac7da63          	ble	a2,a5,ffffffffc02052cc <do_fork+0x2ea>
ffffffffc020521c:	4585                	li	a1,1
ffffffffc020521e:	b789                	j	ffffffffc0205160 <do_fork+0x17e>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205220:	89b6                	mv	s3,a3
ffffffffc0205222:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205226:	00000797          	auipc	a5,0x0
ffffffffc020522a:	b2e78793          	addi	a5,a5,-1234 # ffffffffc0204d54 <forkret>
ffffffffc020522e:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205230:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205232:	100027f3          	csrr	a5,sstatus
ffffffffc0205236:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205238:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020523a:	ec0788e3          	beqz	a5,ffffffffc020510a <do_fork+0x128>
        intr_disable();
ffffffffc020523e:	c1efb0ef          	jal	ra,ffffffffc020065c <intr_disable>
    if (++last_pid >= MAX_PID)
ffffffffc0205242:	0009c797          	auipc	a5,0x9c
ffffffffc0205246:	e0678793          	addi	a5,a5,-506 # ffffffffc02a1048 <last_pid.1691>
ffffffffc020524a:	439c                	lw	a5,0(a5)
ffffffffc020524c:	6709                	lui	a4,0x2
        return 1;
ffffffffc020524e:	4985                	li	s3,1
ffffffffc0205250:	0017851b          	addiw	a0,a5,1
ffffffffc0205254:	0009c697          	auipc	a3,0x9c
ffffffffc0205258:	dea6aa23          	sw	a0,-524(a3) # ffffffffc02a1048 <last_pid.1691>
ffffffffc020525c:	ece545e3          	blt	a0,a4,ffffffffc0205126 <do_fork+0x144>
        last_pid = 1;
ffffffffc0205260:	4785                	li	a5,1
ffffffffc0205262:	0009c717          	auipc	a4,0x9c
ffffffffc0205266:	def72323          	sw	a5,-538(a4) # ffffffffc02a1048 <last_pid.1691>
ffffffffc020526a:	4505                	li	a0,1
ffffffffc020526c:	bdc1                	j	ffffffffc020513c <do_fork+0x15a>
    if ((mm = mm_create()) == NULL)
ffffffffc020526e:	d2efd0ef          	jal	ra,ffffffffc020279c <mm_create>
ffffffffc0205272:	8c2a                	mv	s8,a0
ffffffffc0205274:	c539                	beqz	a0,ffffffffc02052c2 <do_fork+0x2e0>
    if (setup_pgdir(mm) != 0)
ffffffffc0205276:	befff0ef          	jal	ra,ffffffffc0204e64 <setup_pgdir>
ffffffffc020527a:	e129                	bnez	a0,ffffffffc02052bc <do_fork+0x2da>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc020527c:	038a0a93          	addi	s5,s4,56
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0205280:	4785                	li	a5,1
ffffffffc0205282:	40fab7af          	amoor.d	a5,a5,(s5)
ffffffffc0205286:	8b85                	andi	a5,a5,1
ffffffffc0205288:	4b85                	li	s7,1
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc020528a:	c799                	beqz	a5,ffffffffc0205298 <do_fork+0x2b6>
        schedule();
ffffffffc020528c:	523000ef          	jal	ra,ffffffffc0205fae <schedule>
ffffffffc0205290:	417ab7af          	amoor.d	a5,s7,(s5)
ffffffffc0205294:	8b85                	andi	a5,a5,1
    while (!try_lock(lock)) {
ffffffffc0205296:	fbfd                	bnez	a5,ffffffffc020528c <do_fork+0x2aa>
        ret = dup_mmap(mm, oldmm);
ffffffffc0205298:	85d2                	mv	a1,s4
ffffffffc020529a:	8562                	mv	a0,s8
ffffffffc020529c:	f8afd0ef          	jal	ra,ffffffffc0202a26 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02052a0:	57f9                	li	a5,-2
ffffffffc02052a2:	60fab7af          	amoand.d	a5,a5,(s5)
ffffffffc02052a6:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc02052a8:	cbf9                	beqz	a5,ffffffffc020537e <do_fork+0x39c>
    if (ret != 0)
ffffffffc02052aa:	8a62                	mv	s4,s8
ffffffffc02052ac:	de0502e3          	beqz	a0,ffffffffc0205090 <do_fork+0xae>
    exit_mmap(mm);
ffffffffc02052b0:	8562                	mv	a0,s8
ffffffffc02052b2:	811fd0ef          	jal	ra,ffffffffc0202ac2 <exit_mmap>
    put_pgdir(mm);
ffffffffc02052b6:	8562                	mv	a0,s8
ffffffffc02052b8:	b2fff0ef          	jal	ra,ffffffffc0204de6 <put_pgdir>
    mm_destroy(mm);
ffffffffc02052bc:	8562                	mv	a0,s8
ffffffffc02052be:	e64fd0ef          	jal	ra,ffffffffc0202922 <mm_destroy>
ffffffffc02052c2:	6814                	ld	a3,16(s0)
ffffffffc02052c4:	bbc5                	j	ffffffffc02050b4 <do_fork+0xd2>
        intr_enable();
ffffffffc02052c6:	b90fb0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc02052ca:	b735                	j	ffffffffc02051f6 <do_fork+0x214>
                    if (last_pid >= MAX_PID)
ffffffffc02052cc:	0117c363          	blt	a5,a7,ffffffffc02052d2 <do_fork+0x2f0>
                        last_pid = 1;
ffffffffc02052d0:	4785                	li	a5,1
                    goto repeat;
ffffffffc02052d2:	4585                	li	a1,1
ffffffffc02052d4:	b541                	j	ffffffffc0205154 <do_fork+0x172>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02052d6:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc02052d8:	c02007b7          	lui	a5,0xc0200
ffffffffc02052dc:	0cf6e963          	bltu	a3,a5,ffffffffc02053ae <do_fork+0x3cc>
ffffffffc02052e0:	000a7797          	auipc	a5,0xa7
ffffffffc02052e4:	1e078793          	addi	a5,a5,480 # ffffffffc02ac4c0 <va_pa_offset>
ffffffffc02052e8:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02052ea:	000a7717          	auipc	a4,0xa7
ffffffffc02052ee:	17e70713          	addi	a4,a4,382 # ffffffffc02ac468 <npage>
ffffffffc02052f2:	6318                	ld	a4,0(a4)
    return pa2page(PADDR(kva));
ffffffffc02052f4:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02052f8:	83b1                	srli	a5,a5,0xc
ffffffffc02052fa:	08e7fe63          	bleu	a4,a5,ffffffffc0205396 <do_fork+0x3b4>
    return &pages[PPN(pa) - nbase];
ffffffffc02052fe:	00004717          	auipc	a4,0x4
ffffffffc0205302:	9d270713          	addi	a4,a4,-1582 # ffffffffc0208cd0 <nbase>
ffffffffc0205306:	6318                	ld	a4,0(a4)
ffffffffc0205308:	000a7697          	auipc	a3,0xa7
ffffffffc020530c:	1c868693          	addi	a3,a3,456 # ffffffffc02ac4d0 <pages>
ffffffffc0205310:	6288                	ld	a0,0(a3)
ffffffffc0205312:	8f99                	sub	a5,a5,a4
ffffffffc0205314:	079a                	slli	a5,a5,0x6
ffffffffc0205316:	4589                	li	a1,2
ffffffffc0205318:	953e                	add	a0,a0,a5
ffffffffc020531a:	be1fb0ef          	jal	ra,ffffffffc0200efa <free_pages>
    kfree(proc);
ffffffffc020531e:	8522                	mv	a0,s0
ffffffffc0205320:	a46fe0ef          	jal	ra,ffffffffc0203566 <kfree>
    goto fork_out;
ffffffffc0205324:	5571                	li	a0,-4
    return ret;
ffffffffc0205326:	bde1                	j	ffffffffc02051fe <do_fork+0x21c>
    int ret = -E_NO_FREE_PROC;
ffffffffc0205328:	556d                	li	a0,-5
ffffffffc020532a:	bdd1                	j	ffffffffc02051fe <do_fork+0x21c>
    assert(current->wait_state == 0);
ffffffffc020532c:	00003697          	auipc	a3,0x3
ffffffffc0205330:	24c68693          	addi	a3,a3,588 # ffffffffc0208578 <default_pmm_manager+0x270>
ffffffffc0205334:	00002617          	auipc	a2,0x2
ffffffffc0205338:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0206bf0 <commands+0x480>
ffffffffc020533c:	1da00593          	li	a1,474
ffffffffc0205340:	00003517          	auipc	a0,0x3
ffffffffc0205344:	4c850513          	addi	a0,a0,1224 # ffffffffc0208808 <default_pmm_manager+0x500>
ffffffffc0205348:	ecffa0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc020534c:	00002617          	auipc	a2,0x2
ffffffffc0205350:	c7c60613          	addi	a2,a2,-900 # ffffffffc0206fc8 <commands+0x858>
ffffffffc0205354:	06900593          	li	a1,105
ffffffffc0205358:	00002517          	auipc	a0,0x2
ffffffffc020535c:	cc850513          	addi	a0,a0,-824 # ffffffffc0207020 <commands+0x8b0>
ffffffffc0205360:	eb7fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205364:	86be                	mv	a3,a5
ffffffffc0205366:	00002617          	auipc	a2,0x2
ffffffffc020536a:	d3a60613          	addi	a2,a2,-710 # ffffffffc02070a0 <commands+0x930>
ffffffffc020536e:	18900593          	li	a1,393
ffffffffc0205372:	00003517          	auipc	a0,0x3
ffffffffc0205376:	49650513          	addi	a0,a0,1174 # ffffffffc0208808 <default_pmm_manager+0x500>
ffffffffc020537a:	e9dfa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("Unlock failed.\n");
ffffffffc020537e:	00003617          	auipc	a2,0x3
ffffffffc0205382:	21a60613          	addi	a2,a2,538 # ffffffffc0208598 <default_pmm_manager+0x290>
ffffffffc0205386:	03100593          	li	a1,49
ffffffffc020538a:	00003517          	auipc	a0,0x3
ffffffffc020538e:	21e50513          	addi	a0,a0,542 # ffffffffc02085a8 <default_pmm_manager+0x2a0>
ffffffffc0205392:	e85fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205396:	00002617          	auipc	a2,0x2
ffffffffc020539a:	c6a60613          	addi	a2,a2,-918 # ffffffffc0207000 <commands+0x890>
ffffffffc020539e:	06200593          	li	a1,98
ffffffffc02053a2:	00002517          	auipc	a0,0x2
ffffffffc02053a6:	c7e50513          	addi	a0,a0,-898 # ffffffffc0207020 <commands+0x8b0>
ffffffffc02053aa:	e6dfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02053ae:	00002617          	auipc	a2,0x2
ffffffffc02053b2:	cf260613          	addi	a2,a2,-782 # ffffffffc02070a0 <commands+0x930>
ffffffffc02053b6:	06e00593          	li	a1,110
ffffffffc02053ba:	00002517          	auipc	a0,0x2
ffffffffc02053be:	c6650513          	addi	a0,a0,-922 # ffffffffc0207020 <commands+0x8b0>
ffffffffc02053c2:	e55fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02053c6 <kernel_thread>:
{
ffffffffc02053c6:	7129                	addi	sp,sp,-320
ffffffffc02053c8:	fa22                	sd	s0,304(sp)
ffffffffc02053ca:	f626                	sd	s1,296(sp)
ffffffffc02053cc:	f24a                	sd	s2,288(sp)
ffffffffc02053ce:	84ae                	mv	s1,a1
ffffffffc02053d0:	892a                	mv	s2,a0
ffffffffc02053d2:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02053d4:	4581                	li	a1,0
ffffffffc02053d6:	12000613          	li	a2,288
ffffffffc02053da:	850a                	mv	a0,sp
{
ffffffffc02053dc:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02053de:	5e5000ef          	jal	ra,ffffffffc02061c2 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02053e2:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02053e4:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02053e6:	100027f3          	csrr	a5,sstatus
ffffffffc02053ea:	edd7f793          	andi	a5,a5,-291
ffffffffc02053ee:	1207e793          	ori	a5,a5,288
ffffffffc02053f2:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053f4:	860a                	mv	a2,sp
ffffffffc02053f6:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02053fa:	00000797          	auipc	a5,0x0
ffffffffc02053fe:	8de78793          	addi	a5,a5,-1826 # ffffffffc0204cd8 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205402:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205404:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205406:	bddff0ef          	jal	ra,ffffffffc0204fe2 <do_fork>
}
ffffffffc020540a:	70f2                	ld	ra,312(sp)
ffffffffc020540c:	7452                	ld	s0,304(sp)
ffffffffc020540e:	74b2                	ld	s1,296(sp)
ffffffffc0205410:	7912                	ld	s2,288(sp)
ffffffffc0205412:	6131                	addi	sp,sp,320
ffffffffc0205414:	8082                	ret

ffffffffc0205416 <do_exit>:
{
ffffffffc0205416:	7179                	addi	sp,sp,-48
ffffffffc0205418:	e84a                	sd	s2,16(sp)
    if (current == idleproc)
ffffffffc020541a:	000a7717          	auipc	a4,0xa7
ffffffffc020541e:	07e70713          	addi	a4,a4,126 # ffffffffc02ac498 <idleproc>
ffffffffc0205422:	000a7917          	auipc	s2,0xa7
ffffffffc0205426:	06e90913          	addi	s2,s2,110 # ffffffffc02ac490 <current>
ffffffffc020542a:	00093783          	ld	a5,0(s2)
ffffffffc020542e:	6318                	ld	a4,0(a4)
{
ffffffffc0205430:	f406                	sd	ra,40(sp)
ffffffffc0205432:	f022                	sd	s0,32(sp)
ffffffffc0205434:	ec26                	sd	s1,24(sp)
ffffffffc0205436:	e44e                	sd	s3,8(sp)
ffffffffc0205438:	e052                	sd	s4,0(sp)
    if (current == idleproc)
ffffffffc020543a:	0ce78c63          	beq	a5,a4,ffffffffc0205512 <do_exit+0xfc>
    if (current == initproc)
ffffffffc020543e:	000a7417          	auipc	s0,0xa7
ffffffffc0205442:	06240413          	addi	s0,s0,98 # ffffffffc02ac4a0 <initproc>
ffffffffc0205446:	6018                	ld	a4,0(s0)
ffffffffc0205448:	0ee78b63          	beq	a5,a4,ffffffffc020553e <do_exit+0x128>
    struct mm_struct *mm = current->mm;
ffffffffc020544c:	7784                	ld	s1,40(a5)
ffffffffc020544e:	89aa                	mv	s3,a0
    if (mm != NULL)
ffffffffc0205450:	c48d                	beqz	s1,ffffffffc020547a <do_exit+0x64>
        lcr3(boot_cr3);
ffffffffc0205452:	000a7797          	auipc	a5,0xa7
ffffffffc0205456:	07678793          	addi	a5,a5,118 # ffffffffc02ac4c8 <boot_cr3>
ffffffffc020545a:	639c                	ld	a5,0(a5)
ffffffffc020545c:	577d                	li	a4,-1
ffffffffc020545e:	177e                	slli	a4,a4,0x3f
ffffffffc0205460:	83b1                	srli	a5,a5,0xc
ffffffffc0205462:	8fd9                	or	a5,a5,a4
ffffffffc0205464:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc0205468:	589c                	lw	a5,48(s1)
ffffffffc020546a:	fff7871b          	addiw	a4,a5,-1
ffffffffc020546e:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0)
ffffffffc0205470:	cf4d                	beqz	a4,ffffffffc020552a <do_exit+0x114>
        current->mm = NULL;
ffffffffc0205472:	00093783          	ld	a5,0(s2)
ffffffffc0205476:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc020547a:	00093783          	ld	a5,0(s2)
ffffffffc020547e:	470d                	li	a4,3
ffffffffc0205480:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0205482:	0f37a423          	sw	s3,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205486:	100027f3          	csrr	a5,sstatus
ffffffffc020548a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020548c:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020548e:	e7e1                	bnez	a5,ffffffffc0205556 <do_exit+0x140>
        proc = current->parent;
ffffffffc0205490:	00093703          	ld	a4,0(s2)
        if (proc->wait_state == WT_CHILD)
ffffffffc0205494:	800007b7          	lui	a5,0x80000
ffffffffc0205498:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc020549a:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD)
ffffffffc020549c:	0ec52703          	lw	a4,236(a0)
ffffffffc02054a0:	0af70f63          	beq	a4,a5,ffffffffc020555e <do_exit+0x148>
ffffffffc02054a4:	00093683          	ld	a3,0(s2)
                if (initproc->wait_state == WT_CHILD)
ffffffffc02054a8:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE)
ffffffffc02054ac:	448d                	li	s1,3
                if (initproc->wait_state == WT_CHILD)
ffffffffc02054ae:	0985                	addi	s3,s3,1
        while (current->cptr != NULL)
ffffffffc02054b0:	7afc                	ld	a5,240(a3)
ffffffffc02054b2:	cb95                	beqz	a5,ffffffffc02054e6 <do_exit+0xd0>
            current->cptr = proc->optr;
ffffffffc02054b4:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff5680>
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc02054b8:	6008                	ld	a0,0(s0)
            current->cptr = proc->optr;
ffffffffc02054ba:	faf8                	sd	a4,240(a3)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc02054bc:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc02054be:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc02054c2:	10e7b023          	sd	a4,256(a5)
ffffffffc02054c6:	c311                	beqz	a4,ffffffffc02054ca <do_exit+0xb4>
                initproc->cptr->yptr = proc;
ffffffffc02054c8:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc02054ca:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02054cc:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02054ce:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE)
ffffffffc02054d0:	fe9710e3          	bne	a4,s1,ffffffffc02054b0 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD)
ffffffffc02054d4:	0ec52783          	lw	a5,236(a0)
ffffffffc02054d8:	fd379ce3          	bne	a5,s3,ffffffffc02054b0 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc02054dc:	257000ef          	jal	ra,ffffffffc0205f32 <wakeup_proc>
ffffffffc02054e0:	00093683          	ld	a3,0(s2)
ffffffffc02054e4:	b7f1                	j	ffffffffc02054b0 <do_exit+0x9a>
    if (flag) {
ffffffffc02054e6:	020a1363          	bnez	s4,ffffffffc020550c <do_exit+0xf6>
    schedule();
ffffffffc02054ea:	2c5000ef          	jal	ra,ffffffffc0205fae <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc02054ee:	00093783          	ld	a5,0(s2)
ffffffffc02054f2:	00003617          	auipc	a2,0x3
ffffffffc02054f6:	06660613          	addi	a2,a2,102 # ffffffffc0208558 <default_pmm_manager+0x250>
ffffffffc02054fa:	23500593          	li	a1,565
ffffffffc02054fe:	43d4                	lw	a3,4(a5)
ffffffffc0205500:	00003517          	auipc	a0,0x3
ffffffffc0205504:	30850513          	addi	a0,a0,776 # ffffffffc0208808 <default_pmm_manager+0x500>
ffffffffc0205508:	d0ffa0ef          	jal	ra,ffffffffc0200216 <__panic>
        intr_enable();
ffffffffc020550c:	94afb0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc0205510:	bfe9                	j	ffffffffc02054ea <do_exit+0xd4>
        panic("idleproc exit.\n");
ffffffffc0205512:	00003617          	auipc	a2,0x3
ffffffffc0205516:	02660613          	addi	a2,a2,38 # ffffffffc0208538 <default_pmm_manager+0x230>
ffffffffc020551a:	20100593          	li	a1,513
ffffffffc020551e:	00003517          	auipc	a0,0x3
ffffffffc0205522:	2ea50513          	addi	a0,a0,746 # ffffffffc0208808 <default_pmm_manager+0x500>
ffffffffc0205526:	cf1fa0ef          	jal	ra,ffffffffc0200216 <__panic>
            exit_mmap(mm);
ffffffffc020552a:	8526                	mv	a0,s1
ffffffffc020552c:	d96fd0ef          	jal	ra,ffffffffc0202ac2 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205530:	8526                	mv	a0,s1
ffffffffc0205532:	8b5ff0ef          	jal	ra,ffffffffc0204de6 <put_pgdir>
            mm_destroy(mm);
ffffffffc0205536:	8526                	mv	a0,s1
ffffffffc0205538:	beafd0ef          	jal	ra,ffffffffc0202922 <mm_destroy>
ffffffffc020553c:	bf1d                	j	ffffffffc0205472 <do_exit+0x5c>
        panic("initproc exit.\n");
ffffffffc020553e:	00003617          	auipc	a2,0x3
ffffffffc0205542:	00a60613          	addi	a2,a2,10 # ffffffffc0208548 <default_pmm_manager+0x240>
ffffffffc0205546:	20500593          	li	a1,517
ffffffffc020554a:	00003517          	auipc	a0,0x3
ffffffffc020554e:	2be50513          	addi	a0,a0,702 # ffffffffc0208808 <default_pmm_manager+0x500>
ffffffffc0205552:	cc5fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        intr_disable();
ffffffffc0205556:	906fb0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc020555a:	4a05                	li	s4,1
ffffffffc020555c:	bf15                	j	ffffffffc0205490 <do_exit+0x7a>
            wakeup_proc(proc);
ffffffffc020555e:	1d5000ef          	jal	ra,ffffffffc0205f32 <wakeup_proc>
ffffffffc0205562:	b789                	j	ffffffffc02054a4 <do_exit+0x8e>

ffffffffc0205564 <do_wait.part.1>:
int do_wait(int pid, int *code_store)
ffffffffc0205564:	7139                	addi	sp,sp,-64
ffffffffc0205566:	e852                	sd	s4,16(sp)
        current->wait_state = WT_CHILD;
ffffffffc0205568:	80000a37          	lui	s4,0x80000
int do_wait(int pid, int *code_store)
ffffffffc020556c:	f426                	sd	s1,40(sp)
ffffffffc020556e:	f04a                	sd	s2,32(sp)
ffffffffc0205570:	ec4e                	sd	s3,24(sp)
ffffffffc0205572:	e456                	sd	s5,8(sp)
ffffffffc0205574:	e05a                	sd	s6,0(sp)
ffffffffc0205576:	fc06                	sd	ra,56(sp)
ffffffffc0205578:	f822                	sd	s0,48(sp)
ffffffffc020557a:	89aa                	mv	s3,a0
ffffffffc020557c:	8b2e                	mv	s6,a1
        proc = current->cptr;
ffffffffc020557e:	000a7917          	auipc	s2,0xa7
ffffffffc0205582:	f1290913          	addi	s2,s2,-238 # ffffffffc02ac490 <current>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0205586:	448d                	li	s1,3
        current->state = PROC_SLEEPING;
ffffffffc0205588:	4a85                	li	s5,1
        current->wait_state = WT_CHILD;
ffffffffc020558a:	2a05                	addiw	s4,s4,1
    if (pid != 0)
ffffffffc020558c:	02098f63          	beqz	s3,ffffffffc02055ca <do_wait.part.1+0x66>
        proc = find_proc(pid);
ffffffffc0205590:	854e                	mv	a0,s3
ffffffffc0205592:	9f5ff0ef          	jal	ra,ffffffffc0204f86 <find_proc>
ffffffffc0205596:	842a                	mv	s0,a0
        if (proc != NULL && proc->parent == current)
ffffffffc0205598:	12050063          	beqz	a0,ffffffffc02056b8 <do_wait.part.1+0x154>
ffffffffc020559c:	00093703          	ld	a4,0(s2)
ffffffffc02055a0:	711c                	ld	a5,32(a0)
ffffffffc02055a2:	10e79b63          	bne	a5,a4,ffffffffc02056b8 <do_wait.part.1+0x154>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02055a6:	411c                	lw	a5,0(a0)
ffffffffc02055a8:	02978c63          	beq	a5,s1,ffffffffc02055e0 <do_wait.part.1+0x7c>
        current->state = PROC_SLEEPING;
ffffffffc02055ac:	01572023          	sw	s5,0(a4)
        current->wait_state = WT_CHILD;
ffffffffc02055b0:	0f472623          	sw	s4,236(a4)
        schedule();
ffffffffc02055b4:	1fb000ef          	jal	ra,ffffffffc0205fae <schedule>
        if (current->flags & PF_EXITING)
ffffffffc02055b8:	00093783          	ld	a5,0(s2)
ffffffffc02055bc:	0b07a783          	lw	a5,176(a5)
ffffffffc02055c0:	8b85                	andi	a5,a5,1
ffffffffc02055c2:	d7e9                	beqz	a5,ffffffffc020558c <do_wait.part.1+0x28>
            do_exit(-E_KILLED);
ffffffffc02055c4:	555d                	li	a0,-9
ffffffffc02055c6:	e51ff0ef          	jal	ra,ffffffffc0205416 <do_exit>
        proc = current->cptr;
ffffffffc02055ca:	00093703          	ld	a4,0(s2)
ffffffffc02055ce:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr)
ffffffffc02055d0:	e409                	bnez	s0,ffffffffc02055da <do_wait.part.1+0x76>
ffffffffc02055d2:	a0dd                	j	ffffffffc02056b8 <do_wait.part.1+0x154>
ffffffffc02055d4:	10043403          	ld	s0,256(s0)
ffffffffc02055d8:	d871                	beqz	s0,ffffffffc02055ac <do_wait.part.1+0x48>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02055da:	401c                	lw	a5,0(s0)
ffffffffc02055dc:	fe979ce3          	bne	a5,s1,ffffffffc02055d4 <do_wait.part.1+0x70>
    if (proc == idleproc || proc == initproc)
ffffffffc02055e0:	000a7797          	auipc	a5,0xa7
ffffffffc02055e4:	eb878793          	addi	a5,a5,-328 # ffffffffc02ac498 <idleproc>
ffffffffc02055e8:	639c                	ld	a5,0(a5)
ffffffffc02055ea:	0c878d63          	beq	a5,s0,ffffffffc02056c4 <do_wait.part.1+0x160>
ffffffffc02055ee:	000a7797          	auipc	a5,0xa7
ffffffffc02055f2:	eb278793          	addi	a5,a5,-334 # ffffffffc02ac4a0 <initproc>
ffffffffc02055f6:	639c                	ld	a5,0(a5)
ffffffffc02055f8:	0cf40663          	beq	s0,a5,ffffffffc02056c4 <do_wait.part.1+0x160>
    if (code_store != NULL)
ffffffffc02055fc:	000b0663          	beqz	s6,ffffffffc0205608 <do_wait.part.1+0xa4>
        *code_store = proc->exit_code;
ffffffffc0205600:	0e842783          	lw	a5,232(s0)
ffffffffc0205604:	00fb2023          	sw	a5,0(s6)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205608:	100027f3          	csrr	a5,sstatus
ffffffffc020560c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020560e:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205610:	e7d5                	bnez	a5,ffffffffc02056bc <do_wait.part.1+0x158>
    __list_del(listelm->prev, listelm->next);
ffffffffc0205612:	6c70                	ld	a2,216(s0)
ffffffffc0205614:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL)
ffffffffc0205616:	10043703          	ld	a4,256(s0)
ffffffffc020561a:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc020561c:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc020561e:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0205620:	6470                	ld	a2,200(s0)
ffffffffc0205622:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc0205624:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205626:	e290                	sd	a2,0(a3)
ffffffffc0205628:	c319                	beqz	a4,ffffffffc020562e <do_wait.part.1+0xca>
        proc->optr->yptr = proc->yptr;
ffffffffc020562a:	ff7c                	sd	a5,248(a4)
ffffffffc020562c:	7c7c                	ld	a5,248(s0)
    if (proc->yptr != NULL)
ffffffffc020562e:	c3d1                	beqz	a5,ffffffffc02056b2 <do_wait.part.1+0x14e>
        proc->yptr->optr = proc->optr;
ffffffffc0205630:	10e7b023          	sd	a4,256(a5)
    nr_process--;
ffffffffc0205634:	000a7797          	auipc	a5,0xa7
ffffffffc0205638:	e7478793          	addi	a5,a5,-396 # ffffffffc02ac4a8 <nr_process>
ffffffffc020563c:	439c                	lw	a5,0(a5)
ffffffffc020563e:	37fd                	addiw	a5,a5,-1
ffffffffc0205640:	000a7717          	auipc	a4,0xa7
ffffffffc0205644:	e6f72423          	sw	a5,-408(a4) # ffffffffc02ac4a8 <nr_process>
    if (flag) {
ffffffffc0205648:	e1b5                	bnez	a1,ffffffffc02056ac <do_wait.part.1+0x148>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020564a:	6814                	ld	a3,16(s0)
ffffffffc020564c:	c02007b7          	lui	a5,0xc0200
ffffffffc0205650:	0af6e263          	bltu	a3,a5,ffffffffc02056f4 <do_wait.part.1+0x190>
ffffffffc0205654:	000a7797          	auipc	a5,0xa7
ffffffffc0205658:	e6c78793          	addi	a5,a5,-404 # ffffffffc02ac4c0 <va_pa_offset>
ffffffffc020565c:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc020565e:	000a7797          	auipc	a5,0xa7
ffffffffc0205662:	e0a78793          	addi	a5,a5,-502 # ffffffffc02ac468 <npage>
ffffffffc0205666:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0205668:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc020566a:	82b1                	srli	a3,a3,0xc
ffffffffc020566c:	06f6f863          	bleu	a5,a3,ffffffffc02056dc <do_wait.part.1+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc0205670:	00003797          	auipc	a5,0x3
ffffffffc0205674:	66078793          	addi	a5,a5,1632 # ffffffffc0208cd0 <nbase>
ffffffffc0205678:	639c                	ld	a5,0(a5)
ffffffffc020567a:	000a7717          	auipc	a4,0xa7
ffffffffc020567e:	e5670713          	addi	a4,a4,-426 # ffffffffc02ac4d0 <pages>
ffffffffc0205682:	6308                	ld	a0,0(a4)
ffffffffc0205684:	8e9d                	sub	a3,a3,a5
ffffffffc0205686:	069a                	slli	a3,a3,0x6
ffffffffc0205688:	9536                	add	a0,a0,a3
ffffffffc020568a:	4589                	li	a1,2
ffffffffc020568c:	86ffb0ef          	jal	ra,ffffffffc0200efa <free_pages>
    kfree(proc);
ffffffffc0205690:	8522                	mv	a0,s0
ffffffffc0205692:	ed5fd0ef          	jal	ra,ffffffffc0203566 <kfree>
    return 0;
ffffffffc0205696:	4501                	li	a0,0
}
ffffffffc0205698:	70e2                	ld	ra,56(sp)
ffffffffc020569a:	7442                	ld	s0,48(sp)
ffffffffc020569c:	74a2                	ld	s1,40(sp)
ffffffffc020569e:	7902                	ld	s2,32(sp)
ffffffffc02056a0:	69e2                	ld	s3,24(sp)
ffffffffc02056a2:	6a42                	ld	s4,16(sp)
ffffffffc02056a4:	6aa2                	ld	s5,8(sp)
ffffffffc02056a6:	6b02                	ld	s6,0(sp)
ffffffffc02056a8:	6121                	addi	sp,sp,64
ffffffffc02056aa:	8082                	ret
        intr_enable();
ffffffffc02056ac:	fabfa0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc02056b0:	bf69                	j	ffffffffc020564a <do_wait.part.1+0xe6>
        proc->parent->cptr = proc->optr;
ffffffffc02056b2:	701c                	ld	a5,32(s0)
ffffffffc02056b4:	fbf8                	sd	a4,240(a5)
ffffffffc02056b6:	bfbd                	j	ffffffffc0205634 <do_wait.part.1+0xd0>
    return -E_BAD_PROC;
ffffffffc02056b8:	5579                	li	a0,-2
ffffffffc02056ba:	bff9                	j	ffffffffc0205698 <do_wait.part.1+0x134>
        intr_disable();
ffffffffc02056bc:	fa1fa0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc02056c0:	4585                	li	a1,1
ffffffffc02056c2:	bf81                	j	ffffffffc0205612 <do_wait.part.1+0xae>
        panic("wait idleproc or initproc.\n");
ffffffffc02056c4:	00003617          	auipc	a2,0x3
ffffffffc02056c8:	efc60613          	addi	a2,a2,-260 # ffffffffc02085c0 <default_pmm_manager+0x2b8>
ffffffffc02056cc:	35500593          	li	a1,853
ffffffffc02056d0:	00003517          	auipc	a0,0x3
ffffffffc02056d4:	13850513          	addi	a0,a0,312 # ffffffffc0208808 <default_pmm_manager+0x500>
ffffffffc02056d8:	b3ffa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02056dc:	00002617          	auipc	a2,0x2
ffffffffc02056e0:	92460613          	addi	a2,a2,-1756 # ffffffffc0207000 <commands+0x890>
ffffffffc02056e4:	06200593          	li	a1,98
ffffffffc02056e8:	00002517          	auipc	a0,0x2
ffffffffc02056ec:	93850513          	addi	a0,a0,-1736 # ffffffffc0207020 <commands+0x8b0>
ffffffffc02056f0:	b27fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02056f4:	00002617          	auipc	a2,0x2
ffffffffc02056f8:	9ac60613          	addi	a2,a2,-1620 # ffffffffc02070a0 <commands+0x930>
ffffffffc02056fc:	06e00593          	li	a1,110
ffffffffc0205700:	00002517          	auipc	a0,0x2
ffffffffc0205704:	92050513          	addi	a0,a0,-1760 # ffffffffc0207020 <commands+0x8b0>
ffffffffc0205708:	b0ffa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020570c <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
ffffffffc020570c:	1141                	addi	sp,sp,-16
ffffffffc020570e:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0205710:	831fb0ef          	jal	ra,ffffffffc0200f40 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0205714:	d93fd0ef          	jal	ra,ffffffffc02034a6 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0205718:	4601                	li	a2,0
ffffffffc020571a:	4581                	li	a1,0
ffffffffc020571c:	fffff517          	auipc	a0,0xfffff
ffffffffc0205720:	64850513          	addi	a0,a0,1608 # ffffffffc0204d64 <user_main>
ffffffffc0205724:	ca3ff0ef          	jal	ra,ffffffffc02053c6 <kernel_thread>
    if (pid <= 0)
ffffffffc0205728:	00a04563          	bgtz	a0,ffffffffc0205732 <init_main+0x26>
ffffffffc020572c:	a841                	j	ffffffffc02057bc <init_main+0xb0>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0)
    {
        schedule();
ffffffffc020572e:	081000ef          	jal	ra,ffffffffc0205fae <schedule>
    if (code_store != NULL)
ffffffffc0205732:	4581                	li	a1,0
ffffffffc0205734:	4501                	li	a0,0
ffffffffc0205736:	e2fff0ef          	jal	ra,ffffffffc0205564 <do_wait.part.1>
    while (do_wait(0, NULL) == 0)
ffffffffc020573a:	d975                	beqz	a0,ffffffffc020572e <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc020573c:	00003517          	auipc	a0,0x3
ffffffffc0205740:	ec450513          	addi	a0,a0,-316 # ffffffffc0208600 <default_pmm_manager+0x2f8>
ffffffffc0205744:	98dfa0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205748:	000a7797          	auipc	a5,0xa7
ffffffffc020574c:	d5878793          	addi	a5,a5,-680 # ffffffffc02ac4a0 <initproc>
ffffffffc0205750:	639c                	ld	a5,0(a5)
ffffffffc0205752:	7bf8                	ld	a4,240(a5)
ffffffffc0205754:	e721                	bnez	a4,ffffffffc020579c <init_main+0x90>
ffffffffc0205756:	7ff8                	ld	a4,248(a5)
ffffffffc0205758:	e331                	bnez	a4,ffffffffc020579c <init_main+0x90>
ffffffffc020575a:	1007b703          	ld	a4,256(a5)
ffffffffc020575e:	ef1d                	bnez	a4,ffffffffc020579c <init_main+0x90>
    assert(nr_process == 2);
ffffffffc0205760:	000a7717          	auipc	a4,0xa7
ffffffffc0205764:	d4870713          	addi	a4,a4,-696 # ffffffffc02ac4a8 <nr_process>
ffffffffc0205768:	4314                	lw	a3,0(a4)
ffffffffc020576a:	4709                	li	a4,2
ffffffffc020576c:	0ae69463          	bne	a3,a4,ffffffffc0205814 <init_main+0x108>
    return listelm->next;
ffffffffc0205770:	000a7697          	auipc	a3,0xa7
ffffffffc0205774:	e6068693          	addi	a3,a3,-416 # ffffffffc02ac5d0 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205778:	6698                	ld	a4,8(a3)
ffffffffc020577a:	0c878793          	addi	a5,a5,200
ffffffffc020577e:	06f71b63          	bne	a4,a5,ffffffffc02057f4 <init_main+0xe8>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205782:	629c                	ld	a5,0(a3)
ffffffffc0205784:	04f71863          	bne	a4,a5,ffffffffc02057d4 <init_main+0xc8>

    cprintf("init check memory pass.\n");
ffffffffc0205788:	00003517          	auipc	a0,0x3
ffffffffc020578c:	f6050513          	addi	a0,a0,-160 # ffffffffc02086e8 <default_pmm_manager+0x3e0>
ffffffffc0205790:	941fa0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
}
ffffffffc0205794:	60a2                	ld	ra,8(sp)
ffffffffc0205796:	4501                	li	a0,0
ffffffffc0205798:	0141                	addi	sp,sp,16
ffffffffc020579a:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020579c:	00003697          	auipc	a3,0x3
ffffffffc02057a0:	e8c68693          	addi	a3,a3,-372 # ffffffffc0208628 <default_pmm_manager+0x320>
ffffffffc02057a4:	00001617          	auipc	a2,0x1
ffffffffc02057a8:	44c60613          	addi	a2,a2,1100 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02057ac:	3c300593          	li	a1,963
ffffffffc02057b0:	00003517          	auipc	a0,0x3
ffffffffc02057b4:	05850513          	addi	a0,a0,88 # ffffffffc0208808 <default_pmm_manager+0x500>
ffffffffc02057b8:	a5ffa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("create user_main failed.\n");
ffffffffc02057bc:	00003617          	auipc	a2,0x3
ffffffffc02057c0:	e2460613          	addi	a2,a2,-476 # ffffffffc02085e0 <default_pmm_manager+0x2d8>
ffffffffc02057c4:	3ba00593          	li	a1,954
ffffffffc02057c8:	00003517          	auipc	a0,0x3
ffffffffc02057cc:	04050513          	addi	a0,a0,64 # ffffffffc0208808 <default_pmm_manager+0x500>
ffffffffc02057d0:	a47fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02057d4:	00003697          	auipc	a3,0x3
ffffffffc02057d8:	ee468693          	addi	a3,a3,-284 # ffffffffc02086b8 <default_pmm_manager+0x3b0>
ffffffffc02057dc:	00001617          	auipc	a2,0x1
ffffffffc02057e0:	41460613          	addi	a2,a2,1044 # ffffffffc0206bf0 <commands+0x480>
ffffffffc02057e4:	3c600593          	li	a1,966
ffffffffc02057e8:	00003517          	auipc	a0,0x3
ffffffffc02057ec:	02050513          	addi	a0,a0,32 # ffffffffc0208808 <default_pmm_manager+0x500>
ffffffffc02057f0:	a27fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02057f4:	00003697          	auipc	a3,0x3
ffffffffc02057f8:	e9468693          	addi	a3,a3,-364 # ffffffffc0208688 <default_pmm_manager+0x380>
ffffffffc02057fc:	00001617          	auipc	a2,0x1
ffffffffc0205800:	3f460613          	addi	a2,a2,1012 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0205804:	3c500593          	li	a1,965
ffffffffc0205808:	00003517          	auipc	a0,0x3
ffffffffc020580c:	00050513          	mv	a0,a0
ffffffffc0205810:	a07fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_process == 2);
ffffffffc0205814:	00003697          	auipc	a3,0x3
ffffffffc0205818:	e6468693          	addi	a3,a3,-412 # ffffffffc0208678 <default_pmm_manager+0x370>
ffffffffc020581c:	00001617          	auipc	a2,0x1
ffffffffc0205820:	3d460613          	addi	a2,a2,980 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0205824:	3c400593          	li	a1,964
ffffffffc0205828:	00003517          	auipc	a0,0x3
ffffffffc020582c:	fe050513          	addi	a0,a0,-32 # ffffffffc0208808 <default_pmm_manager+0x500>
ffffffffc0205830:	9e7fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205834 <do_execve>:
{
ffffffffc0205834:	7135                	addi	sp,sp,-160
ffffffffc0205836:	f8d2                	sd	s4,112(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205838:	000a7a17          	auipc	s4,0xa7
ffffffffc020583c:	c58a0a13          	addi	s4,s4,-936 # ffffffffc02ac490 <current>
ffffffffc0205840:	000a3783          	ld	a5,0(s4)
{
ffffffffc0205844:	e14a                	sd	s2,128(sp)
ffffffffc0205846:	e922                	sd	s0,144(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205848:	0287b903          	ld	s2,40(a5)
{
ffffffffc020584c:	fcce                	sd	s3,120(sp)
ffffffffc020584e:	f0da                	sd	s6,96(sp)
ffffffffc0205850:	89aa                	mv	s3,a0
ffffffffc0205852:	842e                	mv	s0,a1
ffffffffc0205854:	8b32                	mv	s6,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0205856:	4681                	li	a3,0
ffffffffc0205858:	862e                	mv	a2,a1
ffffffffc020585a:	85aa                	mv	a1,a0
ffffffffc020585c:	854a                	mv	a0,s2
{
ffffffffc020585e:	ed06                	sd	ra,152(sp)
ffffffffc0205860:	e526                	sd	s1,136(sp)
ffffffffc0205862:	f4d6                	sd	s5,104(sp)
ffffffffc0205864:	ecde                	sd	s7,88(sp)
ffffffffc0205866:	e8e2                	sd	s8,80(sp)
ffffffffc0205868:	e4e6                	sd	s9,72(sp)
ffffffffc020586a:	e0ea                	sd	s10,64(sp)
ffffffffc020586c:	fc6e                	sd	s11,56(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc020586e:	8f7fd0ef          	jal	ra,ffffffffc0203164 <user_mem_check>
ffffffffc0205872:	40050463          	beqz	a0,ffffffffc0205c7a <do_execve+0x446>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0205876:	4641                	li	a2,16
ffffffffc0205878:	4581                	li	a1,0
ffffffffc020587a:	1008                	addi	a0,sp,32
ffffffffc020587c:	147000ef          	jal	ra,ffffffffc02061c2 <memset>
    memcpy(local_name, name, len);
ffffffffc0205880:	47bd                	li	a5,15
ffffffffc0205882:	8622                	mv	a2,s0
ffffffffc0205884:	0687ee63          	bltu	a5,s0,ffffffffc0205900 <do_execve+0xcc>
ffffffffc0205888:	85ce                	mv	a1,s3
ffffffffc020588a:	1008                	addi	a0,sp,32
ffffffffc020588c:	149000ef          	jal	ra,ffffffffc02061d4 <memcpy>
    if (mm != NULL)
ffffffffc0205890:	06090f63          	beqz	s2,ffffffffc020590e <do_execve+0xda>
        cputs("mm != NULL");
ffffffffc0205894:	00002517          	auipc	a0,0x2
ffffffffc0205898:	0e450513          	addi	a0,a0,228 # ffffffffc0207978 <commands+0x1208>
ffffffffc020589c:	86dfa0ef          	jal	ra,ffffffffc0200108 <cputs>
        lcr3(boot_cr3);
ffffffffc02058a0:	000a7797          	auipc	a5,0xa7
ffffffffc02058a4:	c2878793          	addi	a5,a5,-984 # ffffffffc02ac4c8 <boot_cr3>
ffffffffc02058a8:	639c                	ld	a5,0(a5)
ffffffffc02058aa:	577d                	li	a4,-1
ffffffffc02058ac:	177e                	slli	a4,a4,0x3f
ffffffffc02058ae:	83b1                	srli	a5,a5,0xc
ffffffffc02058b0:	8fd9                	or	a5,a5,a4
ffffffffc02058b2:	18079073          	csrw	satp,a5
ffffffffc02058b6:	03092783          	lw	a5,48(s2)
ffffffffc02058ba:	fff7871b          	addiw	a4,a5,-1
ffffffffc02058be:	02e92823          	sw	a4,48(s2)
        if (mm_count_dec(mm) == 0)
ffffffffc02058c2:	28070b63          	beqz	a4,ffffffffc0205b58 <do_execve+0x324>
        current->mm = NULL;
ffffffffc02058c6:	000a3783          	ld	a5,0(s4)
ffffffffc02058ca:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL)
ffffffffc02058ce:	ecffc0ef          	jal	ra,ffffffffc020279c <mm_create>
ffffffffc02058d2:	892a                	mv	s2,a0
ffffffffc02058d4:	c135                	beqz	a0,ffffffffc0205938 <do_execve+0x104>
    if (setup_pgdir(mm) != 0)
ffffffffc02058d6:	d8eff0ef          	jal	ra,ffffffffc0204e64 <setup_pgdir>
ffffffffc02058da:	e931                	bnez	a0,ffffffffc020592e <do_execve+0xfa>
    if (elf->e_magic != ELF_MAGIC)
ffffffffc02058dc:	000b2703          	lw	a4,0(s6)
ffffffffc02058e0:	464c47b7          	lui	a5,0x464c4
ffffffffc02058e4:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9aff>
ffffffffc02058e8:	04f70a63          	beq	a4,a5,ffffffffc020593c <do_execve+0x108>
    put_pgdir(mm);
ffffffffc02058ec:	854a                	mv	a0,s2
ffffffffc02058ee:	cf8ff0ef          	jal	ra,ffffffffc0204de6 <put_pgdir>
    mm_destroy(mm);
ffffffffc02058f2:	854a                	mv	a0,s2
ffffffffc02058f4:	82efd0ef          	jal	ra,ffffffffc0202922 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc02058f8:	59e1                	li	s3,-8
    do_exit(ret);
ffffffffc02058fa:	854e                	mv	a0,s3
ffffffffc02058fc:	b1bff0ef          	jal	ra,ffffffffc0205416 <do_exit>
    memcpy(local_name, name, len);
ffffffffc0205900:	463d                	li	a2,15
ffffffffc0205902:	85ce                	mv	a1,s3
ffffffffc0205904:	1008                	addi	a0,sp,32
ffffffffc0205906:	0cf000ef          	jal	ra,ffffffffc02061d4 <memcpy>
    if (mm != NULL)
ffffffffc020590a:	f80915e3          	bnez	s2,ffffffffc0205894 <do_execve+0x60>
    if (current->mm != NULL)
ffffffffc020590e:	000a3783          	ld	a5,0(s4)
ffffffffc0205912:	779c                	ld	a5,40(a5)
ffffffffc0205914:	dfcd                	beqz	a5,ffffffffc02058ce <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0205916:	00003617          	auipc	a2,0x3
ffffffffc020591a:	a9a60613          	addi	a2,a2,-1382 # ffffffffc02083b0 <default_pmm_manager+0xa8>
ffffffffc020591e:	24100593          	li	a1,577
ffffffffc0205922:	00003517          	auipc	a0,0x3
ffffffffc0205926:	ee650513          	addi	a0,a0,-282 # ffffffffc0208808 <default_pmm_manager+0x500>
ffffffffc020592a:	8edfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    mm_destroy(mm);
ffffffffc020592e:	854a                	mv	a0,s2
ffffffffc0205930:	ff3fc0ef          	jal	ra,ffffffffc0202922 <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc0205934:	59f1                	li	s3,-4
ffffffffc0205936:	b7d1                	j	ffffffffc02058fa <do_execve+0xc6>
ffffffffc0205938:	59f1                	li	s3,-4
ffffffffc020593a:	b7c1                	j	ffffffffc02058fa <do_execve+0xc6>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020593c:	038b5703          	lhu	a4,56(s6)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205940:	020b3403          	ld	s0,32(s6)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205944:	00371793          	slli	a5,a4,0x3
ffffffffc0205948:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc020594a:	945a                	add	s0,s0,s6
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020594c:	078e                	slli	a5,a5,0x3
ffffffffc020594e:	97a2                	add	a5,a5,s0
ffffffffc0205950:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph++)
ffffffffc0205952:	02f47b63          	bleu	a5,s0,ffffffffc0205988 <do_execve+0x154>
    return KADDR(page2pa(page));
ffffffffc0205956:	5bfd                	li	s7,-1
ffffffffc0205958:	00cbd793          	srli	a5,s7,0xc
    return page - pages + nbase;
ffffffffc020595c:	000a7d97          	auipc	s11,0xa7
ffffffffc0205960:	b74d8d93          	addi	s11,s11,-1164 # ffffffffc02ac4d0 <pages>
ffffffffc0205964:	00003d17          	auipc	s10,0x3
ffffffffc0205968:	36cd0d13          	addi	s10,s10,876 # ffffffffc0208cd0 <nbase>
    return KADDR(page2pa(page));
ffffffffc020596c:	e43e                	sd	a5,8(sp)
ffffffffc020596e:	000a7c97          	auipc	s9,0xa7
ffffffffc0205972:	afac8c93          	addi	s9,s9,-1286 # ffffffffc02ac468 <npage>
        if (ph->p_type != ELF_PT_LOAD)
ffffffffc0205976:	4018                	lw	a4,0(s0)
ffffffffc0205978:	4785                	li	a5,1
ffffffffc020597a:	0ef70d63          	beq	a4,a5,ffffffffc0205a74 <do_execve+0x240>
    for (; ph < ph_end; ph++)
ffffffffc020597e:	67e2                	ld	a5,24(sp)
ffffffffc0205980:	03840413          	addi	s0,s0,56
ffffffffc0205984:	fef469e3          	bltu	s0,a5,ffffffffc0205976 <do_execve+0x142>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
ffffffffc0205988:	4701                	li	a4,0
ffffffffc020598a:	46ad                	li	a3,11
ffffffffc020598c:	00100637          	lui	a2,0x100
ffffffffc0205990:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0205994:	854a                	mv	a0,s2
ffffffffc0205996:	fdffc0ef          	jal	ra,ffffffffc0202974 <mm_map>
ffffffffc020599a:	89aa                	mv	s3,a0
ffffffffc020599c:	1a051463          	bnez	a0,ffffffffc0205b44 <do_execve+0x310>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc02059a0:	01893503          	ld	a0,24(s2)
ffffffffc02059a4:	467d                	li	a2,31
ffffffffc02059a6:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc02059aa:	953fc0ef          	jal	ra,ffffffffc02022fc <pgdir_alloc_page>
ffffffffc02059ae:	36050263          	beqz	a0,ffffffffc0205d12 <do_execve+0x4de>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc02059b2:	01893503          	ld	a0,24(s2)
ffffffffc02059b6:	467d                	li	a2,31
ffffffffc02059b8:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc02059bc:	941fc0ef          	jal	ra,ffffffffc02022fc <pgdir_alloc_page>
ffffffffc02059c0:	32050963          	beqz	a0,ffffffffc0205cf2 <do_execve+0x4be>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc02059c4:	01893503          	ld	a0,24(s2)
ffffffffc02059c8:	467d                	li	a2,31
ffffffffc02059ca:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc02059ce:	92ffc0ef          	jal	ra,ffffffffc02022fc <pgdir_alloc_page>
ffffffffc02059d2:	30050063          	beqz	a0,ffffffffc0205cd2 <do_execve+0x49e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc02059d6:	01893503          	ld	a0,24(s2)
ffffffffc02059da:	467d                	li	a2,31
ffffffffc02059dc:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc02059e0:	91dfc0ef          	jal	ra,ffffffffc02022fc <pgdir_alloc_page>
ffffffffc02059e4:	2c050763          	beqz	a0,ffffffffc0205cb2 <do_execve+0x47e>
    mm->mm_count += 1;
ffffffffc02059e8:	03092783          	lw	a5,48(s2)
    current->mm = mm;
ffffffffc02059ec:	000a3603          	ld	a2,0(s4)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02059f0:	01893683          	ld	a3,24(s2)
ffffffffc02059f4:	2785                	addiw	a5,a5,1
ffffffffc02059f6:	02f92823          	sw	a5,48(s2)
    current->mm = mm;
ffffffffc02059fa:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_exit_out_size+0xf55a8>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02059fe:	c02007b7          	lui	a5,0xc0200
ffffffffc0205a02:	28f6ec63          	bltu	a3,a5,ffffffffc0205c9a <do_execve+0x466>
ffffffffc0205a06:	000a7797          	auipc	a5,0xa7
ffffffffc0205a0a:	aba78793          	addi	a5,a5,-1350 # ffffffffc02ac4c0 <va_pa_offset>
ffffffffc0205a0e:	639c                	ld	a5,0(a5)
ffffffffc0205a10:	577d                	li	a4,-1
ffffffffc0205a12:	177e                	slli	a4,a4,0x3f
ffffffffc0205a14:	8e9d                	sub	a3,a3,a5
ffffffffc0205a16:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205a1a:	f654                	sd	a3,168(a2)
ffffffffc0205a1c:	8fd9                	or	a5,a5,a4
ffffffffc0205a1e:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205a22:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205a24:	4581                	li	a1,0
ffffffffc0205a26:	12000613          	li	a2,288
ffffffffc0205a2a:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0205a2c:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205a30:	792000ef          	jal	ra,ffffffffc02061c2 <memset>
    tf->epc = elf->e_entry;
ffffffffc0205a34:	018b3703          	ld	a4,24(s6)
    tf->gpr.sp = USTACKTOP;
ffffffffc0205a38:	4785                	li	a5,1
    set_proc_name(current, local_name);
ffffffffc0205a3a:	000a3503          	ld	a0,0(s4)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc0205a3e:	edf4f493          	andi	s1,s1,-289
    tf->gpr.sp = USTACKTOP;
ffffffffc0205a42:	07fe                	slli	a5,a5,0x1f
ffffffffc0205a44:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc0205a46:	10e43423          	sd	a4,264(s0)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc0205a4a:	10943023          	sd	s1,256(s0)
    set_proc_name(current, local_name);
ffffffffc0205a4e:	100c                	addi	a1,sp,32
ffffffffc0205a50:	ca0ff0ef          	jal	ra,ffffffffc0204ef0 <set_proc_name>
}
ffffffffc0205a54:	60ea                	ld	ra,152(sp)
ffffffffc0205a56:	644a                	ld	s0,144(sp)
ffffffffc0205a58:	854e                	mv	a0,s3
ffffffffc0205a5a:	64aa                	ld	s1,136(sp)
ffffffffc0205a5c:	690a                	ld	s2,128(sp)
ffffffffc0205a5e:	79e6                	ld	s3,120(sp)
ffffffffc0205a60:	7a46                	ld	s4,112(sp)
ffffffffc0205a62:	7aa6                	ld	s5,104(sp)
ffffffffc0205a64:	7b06                	ld	s6,96(sp)
ffffffffc0205a66:	6be6                	ld	s7,88(sp)
ffffffffc0205a68:	6c46                	ld	s8,80(sp)
ffffffffc0205a6a:	6ca6                	ld	s9,72(sp)
ffffffffc0205a6c:	6d06                	ld	s10,64(sp)
ffffffffc0205a6e:	7de2                	ld	s11,56(sp)
ffffffffc0205a70:	610d                	addi	sp,sp,160
ffffffffc0205a72:	8082                	ret
        if (ph->p_filesz > ph->p_memsz)
ffffffffc0205a74:	7410                	ld	a2,40(s0)
ffffffffc0205a76:	701c                	ld	a5,32(s0)
ffffffffc0205a78:	20f66363          	bltu	a2,a5,ffffffffc0205c7e <do_execve+0x44a>
        if (ph->p_flags & ELF_PF_X)
ffffffffc0205a7c:	405c                	lw	a5,4(s0)
            vm_flags |= VM_EXEC;
ffffffffc0205a7e:	0017f693          	andi	a3,a5,1
        if (ph->p_flags & ELF_PF_W)
ffffffffc0205a82:	0027f713          	andi	a4,a5,2
            vm_flags |= VM_EXEC;
ffffffffc0205a86:	068a                	slli	a3,a3,0x2
        if (ph->p_flags & ELF_PF_W)
ffffffffc0205a88:	0e071263          	bnez	a4,ffffffffc0205b6c <do_execve+0x338>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205a8c:	4745                	li	a4,17
        if (ph->p_flags & ELF_PF_R)
ffffffffc0205a8e:	8b91                	andi	a5,a5,4
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205a90:	e03a                	sd	a4,0(sp)
        if (ph->p_flags & ELF_PF_R)
ffffffffc0205a92:	c789                	beqz	a5,ffffffffc0205a9c <do_execve+0x268>
            perm |= PTE_R;
ffffffffc0205a94:	47cd                	li	a5,19
            vm_flags |= VM_READ;
ffffffffc0205a96:	0016e693          	ori	a3,a3,1
            perm |= PTE_R;
ffffffffc0205a9a:	e03e                	sd	a5,0(sp)
        if (vm_flags & VM_WRITE)
ffffffffc0205a9c:	0026f793          	andi	a5,a3,2
ffffffffc0205aa0:	efe1                	bnez	a5,ffffffffc0205b78 <do_execve+0x344>
        if (vm_flags & VM_EXEC)
ffffffffc0205aa2:	0046f793          	andi	a5,a3,4
ffffffffc0205aa6:	c789                	beqz	a5,ffffffffc0205ab0 <do_execve+0x27c>
            perm |= PTE_X;
ffffffffc0205aa8:	6782                	ld	a5,0(sp)
ffffffffc0205aaa:	0087e793          	ori	a5,a5,8
ffffffffc0205aae:	e03e                	sd	a5,0(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
ffffffffc0205ab0:	680c                	ld	a1,16(s0)
ffffffffc0205ab2:	4701                	li	a4,0
ffffffffc0205ab4:	854a                	mv	a0,s2
ffffffffc0205ab6:	ebffc0ef          	jal	ra,ffffffffc0202974 <mm_map>
ffffffffc0205aba:	89aa                	mv	s3,a0
ffffffffc0205abc:	e541                	bnez	a0,ffffffffc0205b44 <do_execve+0x310>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205abe:	01043b83          	ld	s7,16(s0)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205ac2:	02043983          	ld	s3,32(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205ac6:	00843a83          	ld	s5,8(s0)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205aca:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205acc:	99de                	add	s3,s3,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205ace:	9ada                	add	s5,s5,s6
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205ad0:	00fbfc33          	and	s8,s7,a5
        while (start < end)
ffffffffc0205ad4:	053bef63          	bltu	s7,s3,ffffffffc0205b32 <do_execve+0x2fe>
ffffffffc0205ad8:	aa79                	j	ffffffffc0205c76 <do_execve+0x442>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205ada:	6785                	lui	a5,0x1
ffffffffc0205adc:	418b8533          	sub	a0,s7,s8
ffffffffc0205ae0:	9c3e                	add	s8,s8,a5
ffffffffc0205ae2:	417c0833          	sub	a6,s8,s7
            if (end < la)
ffffffffc0205ae6:	0189f463          	bleu	s8,s3,ffffffffc0205aee <do_execve+0x2ba>
                size -= la - end;
ffffffffc0205aea:	41798833          	sub	a6,s3,s7
    return page - pages + nbase;
ffffffffc0205aee:	000db683          	ld	a3,0(s11)
ffffffffc0205af2:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205af6:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205af8:	40d486b3          	sub	a3,s1,a3
ffffffffc0205afc:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205afe:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205b02:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205b04:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205b08:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205b0a:	16c5fc63          	bleu	a2,a1,ffffffffc0205c82 <do_execve+0x44e>
ffffffffc0205b0e:	000a7797          	auipc	a5,0xa7
ffffffffc0205b12:	9b278793          	addi	a5,a5,-1614 # ffffffffc02ac4c0 <va_pa_offset>
ffffffffc0205b16:	0007b883          	ld	a7,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205b1a:	85d6                	mv	a1,s5
ffffffffc0205b1c:	8642                	mv	a2,a6
ffffffffc0205b1e:	96c6                	add	a3,a3,a7
ffffffffc0205b20:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205b22:	9bc2                	add	s7,s7,a6
ffffffffc0205b24:	e842                	sd	a6,16(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205b26:	6ae000ef          	jal	ra,ffffffffc02061d4 <memcpy>
            start += size, from += size;
ffffffffc0205b2a:	6842                	ld	a6,16(sp)
ffffffffc0205b2c:	9ac2                	add	s5,s5,a6
        while (start < end)
ffffffffc0205b2e:	053bf863          	bleu	s3,s7,ffffffffc0205b7e <do_execve+0x34a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0205b32:	01893503          	ld	a0,24(s2)
ffffffffc0205b36:	6602                	ld	a2,0(sp)
ffffffffc0205b38:	85e2                	mv	a1,s8
ffffffffc0205b3a:	fc2fc0ef          	jal	ra,ffffffffc02022fc <pgdir_alloc_page>
ffffffffc0205b3e:	84aa                	mv	s1,a0
ffffffffc0205b40:	fd49                	bnez	a0,ffffffffc0205ada <do_execve+0x2a6>
        ret = -E_NO_MEM;
ffffffffc0205b42:	59f1                	li	s3,-4
    exit_mmap(mm);
ffffffffc0205b44:	854a                	mv	a0,s2
ffffffffc0205b46:	f7dfc0ef          	jal	ra,ffffffffc0202ac2 <exit_mmap>
    put_pgdir(mm);
ffffffffc0205b4a:	854a                	mv	a0,s2
ffffffffc0205b4c:	a9aff0ef          	jal	ra,ffffffffc0204de6 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205b50:	854a                	mv	a0,s2
ffffffffc0205b52:	dd1fc0ef          	jal	ra,ffffffffc0202922 <mm_destroy>
    return ret;
ffffffffc0205b56:	b355                	j	ffffffffc02058fa <do_execve+0xc6>
            exit_mmap(mm);
ffffffffc0205b58:	854a                	mv	a0,s2
ffffffffc0205b5a:	f69fc0ef          	jal	ra,ffffffffc0202ac2 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205b5e:	854a                	mv	a0,s2
ffffffffc0205b60:	a86ff0ef          	jal	ra,ffffffffc0204de6 <put_pgdir>
            mm_destroy(mm);
ffffffffc0205b64:	854a                	mv	a0,s2
ffffffffc0205b66:	dbdfc0ef          	jal	ra,ffffffffc0202922 <mm_destroy>
ffffffffc0205b6a:	bbb1                	j	ffffffffc02058c6 <do_execve+0x92>
            vm_flags |= VM_WRITE;
ffffffffc0205b6c:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0205b70:	8b91                	andi	a5,a5,4
            vm_flags |= VM_WRITE;
ffffffffc0205b72:	2681                	sext.w	a3,a3
        if (ph->p_flags & ELF_PF_R)
ffffffffc0205b74:	f20790e3          	bnez	a5,ffffffffc0205a94 <do_execve+0x260>
            perm |= (PTE_W | PTE_R);
ffffffffc0205b78:	47dd                	li	a5,23
ffffffffc0205b7a:	e03e                	sd	a5,0(sp)
ffffffffc0205b7c:	b71d                	j	ffffffffc0205aa2 <do_execve+0x26e>
ffffffffc0205b7e:	01043983          	ld	s3,16(s0)
        end = ph->p_va + ph->p_memsz;
ffffffffc0205b82:	7414                	ld	a3,40(s0)
ffffffffc0205b84:	99b6                	add	s3,s3,a3
        if (start < la)
ffffffffc0205b86:	098bf163          	bleu	s8,s7,ffffffffc0205c08 <do_execve+0x3d4>
            if (start == end)
ffffffffc0205b8a:	df798ae3          	beq	s3,s7,ffffffffc020597e <do_execve+0x14a>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205b8e:	6505                	lui	a0,0x1
ffffffffc0205b90:	955e                	add	a0,a0,s7
ffffffffc0205b92:	41850533          	sub	a0,a0,s8
                size -= la - end;
ffffffffc0205b96:	41798ab3          	sub	s5,s3,s7
            if (end < la)
ffffffffc0205b9a:	0d89fb63          	bleu	s8,s3,ffffffffc0205c70 <do_execve+0x43c>
    return page - pages + nbase;
ffffffffc0205b9e:	000db683          	ld	a3,0(s11)
ffffffffc0205ba2:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205ba6:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205ba8:	40d486b3          	sub	a3,s1,a3
ffffffffc0205bac:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205bae:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205bb2:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205bb4:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205bb8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205bba:	0cc5f463          	bleu	a2,a1,ffffffffc0205c82 <do_execve+0x44e>
ffffffffc0205bbe:	000a7617          	auipc	a2,0xa7
ffffffffc0205bc2:	90260613          	addi	a2,a2,-1790 # ffffffffc02ac4c0 <va_pa_offset>
ffffffffc0205bc6:	00063803          	ld	a6,0(a2)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205bca:	4581                	li	a1,0
ffffffffc0205bcc:	8656                	mv	a2,s5
ffffffffc0205bce:	96c2                	add	a3,a3,a6
ffffffffc0205bd0:	9536                	add	a0,a0,a3
ffffffffc0205bd2:	5f0000ef          	jal	ra,ffffffffc02061c2 <memset>
            start += size;
ffffffffc0205bd6:	017a8733          	add	a4,s5,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205bda:	0389f463          	bleu	s8,s3,ffffffffc0205c02 <do_execve+0x3ce>
ffffffffc0205bde:	dae980e3          	beq	s3,a4,ffffffffc020597e <do_execve+0x14a>
ffffffffc0205be2:	00002697          	auipc	a3,0x2
ffffffffc0205be6:	7f668693          	addi	a3,a3,2038 # ffffffffc02083d8 <default_pmm_manager+0xd0>
ffffffffc0205bea:	00001617          	auipc	a2,0x1
ffffffffc0205bee:	00660613          	addi	a2,a2,6 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0205bf2:	2aa00593          	li	a1,682
ffffffffc0205bf6:	00003517          	auipc	a0,0x3
ffffffffc0205bfa:	c1250513          	addi	a0,a0,-1006 # ffffffffc0208808 <default_pmm_manager+0x500>
ffffffffc0205bfe:	e18fa0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0205c02:	ff8710e3          	bne	a4,s8,ffffffffc0205be2 <do_execve+0x3ae>
ffffffffc0205c06:	8be2                	mv	s7,s8
ffffffffc0205c08:	000a7a97          	auipc	s5,0xa7
ffffffffc0205c0c:	8b8a8a93          	addi	s5,s5,-1864 # ffffffffc02ac4c0 <va_pa_offset>
        while (start < end)
ffffffffc0205c10:	053be763          	bltu	s7,s3,ffffffffc0205c5e <do_execve+0x42a>
ffffffffc0205c14:	b3ad                	j	ffffffffc020597e <do_execve+0x14a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205c16:	6785                	lui	a5,0x1
ffffffffc0205c18:	418b8533          	sub	a0,s7,s8
ffffffffc0205c1c:	9c3e                	add	s8,s8,a5
ffffffffc0205c1e:	417c0633          	sub	a2,s8,s7
            if (end < la)
ffffffffc0205c22:	0189f463          	bleu	s8,s3,ffffffffc0205c2a <do_execve+0x3f6>
                size -= la - end;
ffffffffc0205c26:	41798633          	sub	a2,s3,s7
    return page - pages + nbase;
ffffffffc0205c2a:	000db683          	ld	a3,0(s11)
ffffffffc0205c2e:	000d3803          	ld	a6,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205c32:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205c34:	40d486b3          	sub	a3,s1,a3
ffffffffc0205c38:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205c3a:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205c3e:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0205c40:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205c44:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205c46:	02b87e63          	bleu	a1,a6,ffffffffc0205c82 <do_execve+0x44e>
ffffffffc0205c4a:	000ab803          	ld	a6,0(s5)
            start += size;
ffffffffc0205c4e:	9bb2                	add	s7,s7,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0205c50:	4581                	li	a1,0
ffffffffc0205c52:	96c2                	add	a3,a3,a6
ffffffffc0205c54:	9536                	add	a0,a0,a3
ffffffffc0205c56:	56c000ef          	jal	ra,ffffffffc02061c2 <memset>
        while (start < end)
ffffffffc0205c5a:	d33bf2e3          	bleu	s3,s7,ffffffffc020597e <do_execve+0x14a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0205c5e:	01893503          	ld	a0,24(s2)
ffffffffc0205c62:	6602                	ld	a2,0(sp)
ffffffffc0205c64:	85e2                	mv	a1,s8
ffffffffc0205c66:	e96fc0ef          	jal	ra,ffffffffc02022fc <pgdir_alloc_page>
ffffffffc0205c6a:	84aa                	mv	s1,a0
ffffffffc0205c6c:	f54d                	bnez	a0,ffffffffc0205c16 <do_execve+0x3e2>
ffffffffc0205c6e:	bdd1                	j	ffffffffc0205b42 <do_execve+0x30e>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205c70:	417c0ab3          	sub	s5,s8,s7
ffffffffc0205c74:	b72d                	j	ffffffffc0205b9e <do_execve+0x36a>
        while (start < end)
ffffffffc0205c76:	89de                	mv	s3,s7
ffffffffc0205c78:	b729                	j	ffffffffc0205b82 <do_execve+0x34e>
        return -E_INVAL;
ffffffffc0205c7a:	59f5                	li	s3,-3
ffffffffc0205c7c:	bbe1                	j	ffffffffc0205a54 <do_execve+0x220>
            ret = -E_INVAL_ELF;
ffffffffc0205c7e:	59e1                	li	s3,-8
ffffffffc0205c80:	b5d1                	j	ffffffffc0205b44 <do_execve+0x310>
ffffffffc0205c82:	00001617          	auipc	a2,0x1
ffffffffc0205c86:	34660613          	addi	a2,a2,838 # ffffffffc0206fc8 <commands+0x858>
ffffffffc0205c8a:	06900593          	li	a1,105
ffffffffc0205c8e:	00001517          	auipc	a0,0x1
ffffffffc0205c92:	39250513          	addi	a0,a0,914 # ffffffffc0207020 <commands+0x8b0>
ffffffffc0205c96:	d80fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205c9a:	00001617          	auipc	a2,0x1
ffffffffc0205c9e:	40660613          	addi	a2,a2,1030 # ffffffffc02070a0 <commands+0x930>
ffffffffc0205ca2:	2c900593          	li	a1,713
ffffffffc0205ca6:	00003517          	auipc	a0,0x3
ffffffffc0205caa:	b6250513          	addi	a0,a0,-1182 # ffffffffc0208808 <default_pmm_manager+0x500>
ffffffffc0205cae:	d68fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0205cb2:	00003697          	auipc	a3,0x3
ffffffffc0205cb6:	83e68693          	addi	a3,a3,-1986 # ffffffffc02084f0 <default_pmm_manager+0x1e8>
ffffffffc0205cba:	00001617          	auipc	a2,0x1
ffffffffc0205cbe:	f3660613          	addi	a2,a2,-202 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0205cc2:	2c400593          	li	a1,708
ffffffffc0205cc6:	00003517          	auipc	a0,0x3
ffffffffc0205cca:	b4250513          	addi	a0,a0,-1214 # ffffffffc0208808 <default_pmm_manager+0x500>
ffffffffc0205cce:	d48fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0205cd2:	00002697          	auipc	a3,0x2
ffffffffc0205cd6:	7d668693          	addi	a3,a3,2006 # ffffffffc02084a8 <default_pmm_manager+0x1a0>
ffffffffc0205cda:	00001617          	auipc	a2,0x1
ffffffffc0205cde:	f1660613          	addi	a2,a2,-234 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0205ce2:	2c300593          	li	a1,707
ffffffffc0205ce6:	00003517          	auipc	a0,0x3
ffffffffc0205cea:	b2250513          	addi	a0,a0,-1246 # ffffffffc0208808 <default_pmm_manager+0x500>
ffffffffc0205cee:	d28fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0205cf2:	00002697          	auipc	a3,0x2
ffffffffc0205cf6:	76e68693          	addi	a3,a3,1902 # ffffffffc0208460 <default_pmm_manager+0x158>
ffffffffc0205cfa:	00001617          	auipc	a2,0x1
ffffffffc0205cfe:	ef660613          	addi	a2,a2,-266 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0205d02:	2c200593          	li	a1,706
ffffffffc0205d06:	00003517          	auipc	a0,0x3
ffffffffc0205d0a:	b0250513          	addi	a0,a0,-1278 # ffffffffc0208808 <default_pmm_manager+0x500>
ffffffffc0205d0e:	d08fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0205d12:	00002697          	auipc	a3,0x2
ffffffffc0205d16:	70668693          	addi	a3,a3,1798 # ffffffffc0208418 <default_pmm_manager+0x110>
ffffffffc0205d1a:	00001617          	auipc	a2,0x1
ffffffffc0205d1e:	ed660613          	addi	a2,a2,-298 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0205d22:	2c100593          	li	a1,705
ffffffffc0205d26:	00003517          	auipc	a0,0x3
ffffffffc0205d2a:	ae250513          	addi	a0,a0,-1310 # ffffffffc0208808 <default_pmm_manager+0x500>
ffffffffc0205d2e:	ce8fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205d32 <do_yield>:
    current->need_resched = 1;
ffffffffc0205d32:	000a6797          	auipc	a5,0xa6
ffffffffc0205d36:	75e78793          	addi	a5,a5,1886 # ffffffffc02ac490 <current>
ffffffffc0205d3a:	639c                	ld	a5,0(a5)
ffffffffc0205d3c:	4705                	li	a4,1
}
ffffffffc0205d3e:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0205d40:	ef98                	sd	a4,24(a5)
}
ffffffffc0205d42:	8082                	ret

ffffffffc0205d44 <do_wait>:
{
ffffffffc0205d44:	1101                	addi	sp,sp,-32
ffffffffc0205d46:	e822                	sd	s0,16(sp)
ffffffffc0205d48:	e426                	sd	s1,8(sp)
ffffffffc0205d4a:	ec06                	sd	ra,24(sp)
ffffffffc0205d4c:	842e                	mv	s0,a1
ffffffffc0205d4e:	84aa                	mv	s1,a0
    if (code_store != NULL)
ffffffffc0205d50:	cd81                	beqz	a1,ffffffffc0205d68 <do_wait+0x24>
    struct mm_struct *mm = current->mm;
ffffffffc0205d52:	000a6797          	auipc	a5,0xa6
ffffffffc0205d56:	73e78793          	addi	a5,a5,1854 # ffffffffc02ac490 <current>
ffffffffc0205d5a:	639c                	ld	a5,0(a5)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc0205d5c:	4685                	li	a3,1
ffffffffc0205d5e:	4611                	li	a2,4
ffffffffc0205d60:	7788                	ld	a0,40(a5)
ffffffffc0205d62:	c02fd0ef          	jal	ra,ffffffffc0203164 <user_mem_check>
ffffffffc0205d66:	c909                	beqz	a0,ffffffffc0205d78 <do_wait+0x34>
ffffffffc0205d68:	85a2                	mv	a1,s0
}
ffffffffc0205d6a:	6442                	ld	s0,16(sp)
ffffffffc0205d6c:	60e2                	ld	ra,24(sp)
ffffffffc0205d6e:	8526                	mv	a0,s1
ffffffffc0205d70:	64a2                	ld	s1,8(sp)
ffffffffc0205d72:	6105                	addi	sp,sp,32
ffffffffc0205d74:	ff0ff06f          	j	ffffffffc0205564 <do_wait.part.1>
ffffffffc0205d78:	60e2                	ld	ra,24(sp)
ffffffffc0205d7a:	6442                	ld	s0,16(sp)
ffffffffc0205d7c:	64a2                	ld	s1,8(sp)
ffffffffc0205d7e:	5575                	li	a0,-3
ffffffffc0205d80:	6105                	addi	sp,sp,32
ffffffffc0205d82:	8082                	ret

ffffffffc0205d84 <do_kill>:
{
ffffffffc0205d84:	1141                	addi	sp,sp,-16
ffffffffc0205d86:	e406                	sd	ra,8(sp)
ffffffffc0205d88:	e022                	sd	s0,0(sp)
    if ((proc = find_proc(pid)) != NULL)
ffffffffc0205d8a:	9fcff0ef          	jal	ra,ffffffffc0204f86 <find_proc>
ffffffffc0205d8e:	cd0d                	beqz	a0,ffffffffc0205dc8 <do_kill+0x44>
        if (!(proc->flags & PF_EXITING))
ffffffffc0205d90:	0b052703          	lw	a4,176(a0)
ffffffffc0205d94:	00177693          	andi	a3,a4,1
ffffffffc0205d98:	e695                	bnez	a3,ffffffffc0205dc4 <do_kill+0x40>
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0205d9a:	0ec52683          	lw	a3,236(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205d9e:	00176713          	ori	a4,a4,1
ffffffffc0205da2:	0ae52823          	sw	a4,176(a0)
            return 0;
ffffffffc0205da6:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0205da8:	0006c763          	bltz	a3,ffffffffc0205db6 <do_kill+0x32>
}
ffffffffc0205dac:	8522                	mv	a0,s0
ffffffffc0205dae:	60a2                	ld	ra,8(sp)
ffffffffc0205db0:	6402                	ld	s0,0(sp)
ffffffffc0205db2:	0141                	addi	sp,sp,16
ffffffffc0205db4:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205db6:	17c000ef          	jal	ra,ffffffffc0205f32 <wakeup_proc>
}
ffffffffc0205dba:	8522                	mv	a0,s0
ffffffffc0205dbc:	60a2                	ld	ra,8(sp)
ffffffffc0205dbe:	6402                	ld	s0,0(sp)
ffffffffc0205dc0:	0141                	addi	sp,sp,16
ffffffffc0205dc2:	8082                	ret
        return -E_KILLED;
ffffffffc0205dc4:	545d                	li	s0,-9
ffffffffc0205dc6:	b7dd                	j	ffffffffc0205dac <do_kill+0x28>
    return -E_INVAL;
ffffffffc0205dc8:	5475                	li	s0,-3
ffffffffc0205dca:	b7cd                	j	ffffffffc0205dac <do_kill+0x28>

ffffffffc0205dcc <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0205dcc:	000a7797          	auipc	a5,0xa7
ffffffffc0205dd0:	80478793          	addi	a5,a5,-2044 # ffffffffc02ac5d0 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
ffffffffc0205dd4:	1101                	addi	sp,sp,-32
ffffffffc0205dd6:	000a7717          	auipc	a4,0xa7
ffffffffc0205dda:	80f73123          	sd	a5,-2046(a4) # ffffffffc02ac5d8 <proc_list+0x8>
ffffffffc0205dde:	000a6717          	auipc	a4,0xa6
ffffffffc0205de2:	7ef73923          	sd	a5,2034(a4) # ffffffffc02ac5d0 <proc_list>
ffffffffc0205de6:	ec06                	sd	ra,24(sp)
ffffffffc0205de8:	e822                	sd	s0,16(sp)
ffffffffc0205dea:	e426                	sd	s1,8(sp)
ffffffffc0205dec:	000a2797          	auipc	a5,0xa2
ffffffffc0205df0:	66478793          	addi	a5,a5,1636 # ffffffffc02a8450 <hash_list>
ffffffffc0205df4:	000a6717          	auipc	a4,0xa6
ffffffffc0205df8:	65c70713          	addi	a4,a4,1628 # ffffffffc02ac450 <is_panic>
ffffffffc0205dfc:	e79c                	sd	a5,8(a5)
ffffffffc0205dfe:	e39c                	sd	a5,0(a5)
ffffffffc0205e00:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc0205e02:	fee79de3          	bne	a5,a4,ffffffffc0205dfc <proc_init+0x30>
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
ffffffffc0205e06:	edbfe0ef          	jal	ra,ffffffffc0204ce0 <alloc_proc>
ffffffffc0205e0a:	000a6717          	auipc	a4,0xa6
ffffffffc0205e0e:	68a73723          	sd	a0,1678(a4) # ffffffffc02ac498 <idleproc>
ffffffffc0205e12:	000a6497          	auipc	s1,0xa6
ffffffffc0205e16:	68648493          	addi	s1,s1,1670 # ffffffffc02ac498 <idleproc>
ffffffffc0205e1a:	c559                	beqz	a0,ffffffffc0205ea8 <proc_init+0xdc>
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205e1c:	4709                	li	a4,2
ffffffffc0205e1e:	e118                	sd	a4,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc0205e20:	4405                	li	s0,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205e22:	00003717          	auipc	a4,0x3
ffffffffc0205e26:	1de70713          	addi	a4,a4,478 # ffffffffc0209000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc0205e2a:	00003597          	auipc	a1,0x3
ffffffffc0205e2e:	8f658593          	addi	a1,a1,-1802 # ffffffffc0208720 <default_pmm_manager+0x418>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205e32:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205e34:	ed00                	sd	s0,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc0205e36:	8baff0ef          	jal	ra,ffffffffc0204ef0 <set_proc_name>
    nr_process++;
ffffffffc0205e3a:	000a6797          	auipc	a5,0xa6
ffffffffc0205e3e:	66e78793          	addi	a5,a5,1646 # ffffffffc02ac4a8 <nr_process>
ffffffffc0205e42:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc0205e44:	6098                	ld	a4,0(s1)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e46:	4601                	li	a2,0
    nr_process++;
ffffffffc0205e48:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e4a:	4581                	li	a1,0
ffffffffc0205e4c:	00000517          	auipc	a0,0x0
ffffffffc0205e50:	8c050513          	addi	a0,a0,-1856 # ffffffffc020570c <init_main>
    nr_process++;
ffffffffc0205e54:	000a6697          	auipc	a3,0xa6
ffffffffc0205e58:	64f6aa23          	sw	a5,1620(a3) # ffffffffc02ac4a8 <nr_process>
    current = idleproc;
ffffffffc0205e5c:	000a6797          	auipc	a5,0xa6
ffffffffc0205e60:	62e7ba23          	sd	a4,1588(a5) # ffffffffc02ac490 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e64:	d62ff0ef          	jal	ra,ffffffffc02053c6 <kernel_thread>
    if (pid <= 0)
ffffffffc0205e68:	08a05c63          	blez	a0,ffffffffc0205f00 <proc_init+0x134>
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205e6c:	91aff0ef          	jal	ra,ffffffffc0204f86 <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0205e70:	00003597          	auipc	a1,0x3
ffffffffc0205e74:	8d858593          	addi	a1,a1,-1832 # ffffffffc0208748 <default_pmm_manager+0x440>
    initproc = find_proc(pid);
ffffffffc0205e78:	000a6797          	auipc	a5,0xa6
ffffffffc0205e7c:	62a7b423          	sd	a0,1576(a5) # ffffffffc02ac4a0 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0205e80:	870ff0ef          	jal	ra,ffffffffc0204ef0 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205e84:	609c                	ld	a5,0(s1)
ffffffffc0205e86:	cfa9                	beqz	a5,ffffffffc0205ee0 <proc_init+0x114>
ffffffffc0205e88:	43dc                	lw	a5,4(a5)
ffffffffc0205e8a:	ebb9                	bnez	a5,ffffffffc0205ee0 <proc_init+0x114>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205e8c:	000a6797          	auipc	a5,0xa6
ffffffffc0205e90:	61478793          	addi	a5,a5,1556 # ffffffffc02ac4a0 <initproc>
ffffffffc0205e94:	639c                	ld	a5,0(a5)
ffffffffc0205e96:	c78d                	beqz	a5,ffffffffc0205ec0 <proc_init+0xf4>
ffffffffc0205e98:	43dc                	lw	a5,4(a5)
ffffffffc0205e9a:	02879363          	bne	a5,s0,ffffffffc0205ec0 <proc_init+0xf4>
}
ffffffffc0205e9e:	60e2                	ld	ra,24(sp)
ffffffffc0205ea0:	6442                	ld	s0,16(sp)
ffffffffc0205ea2:	64a2                	ld	s1,8(sp)
ffffffffc0205ea4:	6105                	addi	sp,sp,32
ffffffffc0205ea6:	8082                	ret
        panic("cannot alloc idleproc.\n");
ffffffffc0205ea8:	00003617          	auipc	a2,0x3
ffffffffc0205eac:	86060613          	addi	a2,a2,-1952 # ffffffffc0208708 <default_pmm_manager+0x400>
ffffffffc0205eb0:	3da00593          	li	a1,986
ffffffffc0205eb4:	00003517          	auipc	a0,0x3
ffffffffc0205eb8:	95450513          	addi	a0,a0,-1708 # ffffffffc0208808 <default_pmm_manager+0x500>
ffffffffc0205ebc:	b5afa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205ec0:	00003697          	auipc	a3,0x3
ffffffffc0205ec4:	8b868693          	addi	a3,a3,-1864 # ffffffffc0208778 <default_pmm_manager+0x470>
ffffffffc0205ec8:	00001617          	auipc	a2,0x1
ffffffffc0205ecc:	d2860613          	addi	a2,a2,-728 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0205ed0:	3f000593          	li	a1,1008
ffffffffc0205ed4:	00003517          	auipc	a0,0x3
ffffffffc0205ed8:	93450513          	addi	a0,a0,-1740 # ffffffffc0208808 <default_pmm_manager+0x500>
ffffffffc0205edc:	b3afa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205ee0:	00003697          	auipc	a3,0x3
ffffffffc0205ee4:	87068693          	addi	a3,a3,-1936 # ffffffffc0208750 <default_pmm_manager+0x448>
ffffffffc0205ee8:	00001617          	auipc	a2,0x1
ffffffffc0205eec:	d0860613          	addi	a2,a2,-760 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0205ef0:	3ef00593          	li	a1,1007
ffffffffc0205ef4:	00003517          	auipc	a0,0x3
ffffffffc0205ef8:	91450513          	addi	a0,a0,-1772 # ffffffffc0208808 <default_pmm_manager+0x500>
ffffffffc0205efc:	b1afa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("create init_main failed.\n");
ffffffffc0205f00:	00003617          	auipc	a2,0x3
ffffffffc0205f04:	82860613          	addi	a2,a2,-2008 # ffffffffc0208728 <default_pmm_manager+0x420>
ffffffffc0205f08:	3e900593          	li	a1,1001
ffffffffc0205f0c:	00003517          	auipc	a0,0x3
ffffffffc0205f10:	8fc50513          	addi	a0,a0,-1796 # ffffffffc0208808 <default_pmm_manager+0x500>
ffffffffc0205f14:	b02fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205f18 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
ffffffffc0205f18:	1141                	addi	sp,sp,-16
ffffffffc0205f1a:	e022                	sd	s0,0(sp)
ffffffffc0205f1c:	e406                	sd	ra,8(sp)
ffffffffc0205f1e:	000a6417          	auipc	s0,0xa6
ffffffffc0205f22:	57240413          	addi	s0,s0,1394 # ffffffffc02ac490 <current>
    while (1)
    {
        if (current->need_resched)
ffffffffc0205f26:	6018                	ld	a4,0(s0)
ffffffffc0205f28:	6f1c                	ld	a5,24(a4)
ffffffffc0205f2a:	dffd                	beqz	a5,ffffffffc0205f28 <cpu_idle+0x10>
        {
            schedule();
ffffffffc0205f2c:	082000ef          	jal	ra,ffffffffc0205fae <schedule>
ffffffffc0205f30:	bfdd                	j	ffffffffc0205f26 <cpu_idle+0xe>

ffffffffc0205f32 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f32:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205f34:	1101                	addi	sp,sp,-32
ffffffffc0205f36:	ec06                	sd	ra,24(sp)
ffffffffc0205f38:	e822                	sd	s0,16(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f3a:	478d                	li	a5,3
ffffffffc0205f3c:	04f70a63          	beq	a4,a5,ffffffffc0205f90 <wakeup_proc+0x5e>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f40:	100027f3          	csrr	a5,sstatus
ffffffffc0205f44:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205f46:	4401                	li	s0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f48:	ef8d                	bnez	a5,ffffffffc0205f82 <wakeup_proc+0x50>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205f4a:	4789                	li	a5,2
ffffffffc0205f4c:	00f70f63          	beq	a4,a5,ffffffffc0205f6a <wakeup_proc+0x38>
            proc->state = PROC_RUNNABLE;
ffffffffc0205f50:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc0205f52:	0e052623          	sw	zero,236(a0)
    if (flag) {
ffffffffc0205f56:	e409                	bnez	s0,ffffffffc0205f60 <wakeup_proc+0x2e>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205f58:	60e2                	ld	ra,24(sp)
ffffffffc0205f5a:	6442                	ld	s0,16(sp)
ffffffffc0205f5c:	6105                	addi	sp,sp,32
ffffffffc0205f5e:	8082                	ret
ffffffffc0205f60:	6442                	ld	s0,16(sp)
ffffffffc0205f62:	60e2                	ld	ra,24(sp)
ffffffffc0205f64:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205f66:	ef0fa06f          	j	ffffffffc0200656 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205f6a:	00003617          	auipc	a2,0x3
ffffffffc0205f6e:	8ee60613          	addi	a2,a2,-1810 # ffffffffc0208858 <default_pmm_manager+0x550>
ffffffffc0205f72:	45c9                	li	a1,18
ffffffffc0205f74:	00003517          	auipc	a0,0x3
ffffffffc0205f78:	8cc50513          	addi	a0,a0,-1844 # ffffffffc0208840 <default_pmm_manager+0x538>
ffffffffc0205f7c:	b06fa0ef          	jal	ra,ffffffffc0200282 <__warn>
ffffffffc0205f80:	bfd9                	j	ffffffffc0205f56 <wakeup_proc+0x24>
ffffffffc0205f82:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0205f84:	ed8fa0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc0205f88:	6522                	ld	a0,8(sp)
ffffffffc0205f8a:	4405                	li	s0,1
ffffffffc0205f8c:	4118                	lw	a4,0(a0)
ffffffffc0205f8e:	bf75                	j	ffffffffc0205f4a <wakeup_proc+0x18>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f90:	00003697          	auipc	a3,0x3
ffffffffc0205f94:	89068693          	addi	a3,a3,-1904 # ffffffffc0208820 <default_pmm_manager+0x518>
ffffffffc0205f98:	00001617          	auipc	a2,0x1
ffffffffc0205f9c:	c5860613          	addi	a2,a2,-936 # ffffffffc0206bf0 <commands+0x480>
ffffffffc0205fa0:	45a5                	li	a1,9
ffffffffc0205fa2:	00003517          	auipc	a0,0x3
ffffffffc0205fa6:	89e50513          	addi	a0,a0,-1890 # ffffffffc0208840 <default_pmm_manager+0x538>
ffffffffc0205faa:	a6cfa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205fae <schedule>:

void
schedule(void) {
ffffffffc0205fae:	1141                	addi	sp,sp,-16
ffffffffc0205fb0:	e406                	sd	ra,8(sp)
ffffffffc0205fb2:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205fb4:	100027f3          	csrr	a5,sstatus
ffffffffc0205fb8:	8b89                	andi	a5,a5,2
ffffffffc0205fba:	4401                	li	s0,0
ffffffffc0205fbc:	e3d1                	bnez	a5,ffffffffc0206040 <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205fbe:	000a6797          	auipc	a5,0xa6
ffffffffc0205fc2:	4d278793          	addi	a5,a5,1234 # ffffffffc02ac490 <current>
ffffffffc0205fc6:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205fca:	000a6797          	auipc	a5,0xa6
ffffffffc0205fce:	4ce78793          	addi	a5,a5,1230 # ffffffffc02ac498 <idleproc>
ffffffffc0205fd2:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc0205fd4:	0008bc23          	sd	zero,24(a7) # 2018 <_binary_obj___user_faultread_out_size-0x7560>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205fd8:	04a88e63          	beq	a7,a0,ffffffffc0206034 <schedule+0x86>
ffffffffc0205fdc:	0c888693          	addi	a3,a7,200
ffffffffc0205fe0:	000a6617          	auipc	a2,0xa6
ffffffffc0205fe4:	5f060613          	addi	a2,a2,1520 # ffffffffc02ac5d0 <proc_list>
        le = last;
ffffffffc0205fe8:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0205fea:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205fec:	4809                	li	a6,2
    return listelm->next;
ffffffffc0205fee:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0205ff0:	00c78863          	beq	a5,a2,ffffffffc0206000 <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205ff4:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0205ff8:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205ffc:	01070463          	beq	a4,a6,ffffffffc0206004 <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc0206000:	fef697e3          	bne	a3,a5,ffffffffc0205fee <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206004:	c589                	beqz	a1,ffffffffc020600e <schedule+0x60>
ffffffffc0206006:	4198                	lw	a4,0(a1)
ffffffffc0206008:	4789                	li	a5,2
ffffffffc020600a:	00f70e63          	beq	a4,a5,ffffffffc0206026 <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc020600e:	451c                	lw	a5,8(a0)
ffffffffc0206010:	2785                	addiw	a5,a5,1
ffffffffc0206012:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0206014:	00a88463          	beq	a7,a0,ffffffffc020601c <schedule+0x6e>
            proc_run(next);
ffffffffc0206018:	f03fe0ef          	jal	ra,ffffffffc0204f1a <proc_run>
    if (flag) {
ffffffffc020601c:	e419                	bnez	s0,ffffffffc020602a <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020601e:	60a2                	ld	ra,8(sp)
ffffffffc0206020:	6402                	ld	s0,0(sp)
ffffffffc0206022:	0141                	addi	sp,sp,16
ffffffffc0206024:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206026:	852e                	mv	a0,a1
ffffffffc0206028:	b7dd                	j	ffffffffc020600e <schedule+0x60>
}
ffffffffc020602a:	6402                	ld	s0,0(sp)
ffffffffc020602c:	60a2                	ld	ra,8(sp)
ffffffffc020602e:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0206030:	e26fa06f          	j	ffffffffc0200656 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206034:	000a6617          	auipc	a2,0xa6
ffffffffc0206038:	59c60613          	addi	a2,a2,1436 # ffffffffc02ac5d0 <proc_list>
ffffffffc020603c:	86b2                	mv	a3,a2
ffffffffc020603e:	b76d                	j	ffffffffc0205fe8 <schedule+0x3a>
        intr_disable();
ffffffffc0206040:	e1cfa0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc0206044:	4405                	li	s0,1
ffffffffc0206046:	bfa5                	j	ffffffffc0205fbe <schedule+0x10>

ffffffffc0206048 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0206048:	000a6797          	auipc	a5,0xa6
ffffffffc020604c:	44878793          	addi	a5,a5,1096 # ffffffffc02ac490 <current>
ffffffffc0206050:	639c                	ld	a5,0(a5)
}
ffffffffc0206052:	43c8                	lw	a0,4(a5)
ffffffffc0206054:	8082                	ret

ffffffffc0206056 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0206056:	4501                	li	a0,0
ffffffffc0206058:	8082                	ret

ffffffffc020605a <sys_putc>:
    cputchar(c);
ffffffffc020605a:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc020605c:	1141                	addi	sp,sp,-16
ffffffffc020605e:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0206060:	8a4fa0ef          	jal	ra,ffffffffc0200104 <cputchar>
}
ffffffffc0206064:	60a2                	ld	ra,8(sp)
ffffffffc0206066:	4501                	li	a0,0
ffffffffc0206068:	0141                	addi	sp,sp,16
ffffffffc020606a:	8082                	ret

ffffffffc020606c <sys_kill>:
    return do_kill(pid);
ffffffffc020606c:	4108                	lw	a0,0(a0)
ffffffffc020606e:	d17ff06f          	j	ffffffffc0205d84 <do_kill>

ffffffffc0206072 <sys_yield>:
    return do_yield();
ffffffffc0206072:	cc1ff06f          	j	ffffffffc0205d32 <do_yield>

ffffffffc0206076 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0206076:	6d14                	ld	a3,24(a0)
ffffffffc0206078:	6910                	ld	a2,16(a0)
ffffffffc020607a:	650c                	ld	a1,8(a0)
ffffffffc020607c:	6108                	ld	a0,0(a0)
ffffffffc020607e:	fb6ff06f          	j	ffffffffc0205834 <do_execve>

ffffffffc0206082 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0206082:	650c                	ld	a1,8(a0)
ffffffffc0206084:	4108                	lw	a0,0(a0)
ffffffffc0206086:	cbfff06f          	j	ffffffffc0205d44 <do_wait>

ffffffffc020608a <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc020608a:	000a6797          	auipc	a5,0xa6
ffffffffc020608e:	40678793          	addi	a5,a5,1030 # ffffffffc02ac490 <current>
ffffffffc0206092:	639c                	ld	a5,0(a5)
    return do_fork(0, stack, tf);
ffffffffc0206094:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc0206096:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0206098:	6a0c                	ld	a1,16(a2)
ffffffffc020609a:	f49fe06f          	j	ffffffffc0204fe2 <do_fork>

ffffffffc020609e <sys_exit>:
    return do_exit(error_code);
ffffffffc020609e:	4108                	lw	a0,0(a0)
ffffffffc02060a0:	b76ff06f          	j	ffffffffc0205416 <do_exit>

ffffffffc02060a4 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc02060a4:	715d                	addi	sp,sp,-80
ffffffffc02060a6:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc02060a8:	000a6497          	auipc	s1,0xa6
ffffffffc02060ac:	3e848493          	addi	s1,s1,1000 # ffffffffc02ac490 <current>
ffffffffc02060b0:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc02060b2:	e0a2                	sd	s0,64(sp)
ffffffffc02060b4:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc02060b6:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc02060b8:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02060ba:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc02060bc:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02060c0:	0327ee63          	bltu	a5,s2,ffffffffc02060fc <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc02060c4:	00391713          	slli	a4,s2,0x3
ffffffffc02060c8:	00002797          	auipc	a5,0x2
ffffffffc02060cc:	7f878793          	addi	a5,a5,2040 # ffffffffc02088c0 <syscalls>
ffffffffc02060d0:	97ba                	add	a5,a5,a4
ffffffffc02060d2:	639c                	ld	a5,0(a5)
ffffffffc02060d4:	c785                	beqz	a5,ffffffffc02060fc <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc02060d6:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc02060d8:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc02060da:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc02060dc:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc02060de:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc02060e0:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc02060e2:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc02060e4:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc02060e6:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc02060e8:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02060ea:	0028                	addi	a0,sp,8
ffffffffc02060ec:	9782                	jalr	a5
ffffffffc02060ee:	e828                	sd	a0,80(s0)
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc02060f0:	60a6                	ld	ra,72(sp)
ffffffffc02060f2:	6406                	ld	s0,64(sp)
ffffffffc02060f4:	74e2                	ld	s1,56(sp)
ffffffffc02060f6:	7942                	ld	s2,48(sp)
ffffffffc02060f8:	6161                	addi	sp,sp,80
ffffffffc02060fa:	8082                	ret
    print_trapframe(tf);
ffffffffc02060fc:	8522                	mv	a0,s0
ffffffffc02060fe:	f4cfa0ef          	jal	ra,ffffffffc020084a <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0206102:	609c                	ld	a5,0(s1)
ffffffffc0206104:	86ca                	mv	a3,s2
ffffffffc0206106:	00002617          	auipc	a2,0x2
ffffffffc020610a:	77260613          	addi	a2,a2,1906 # ffffffffc0208878 <default_pmm_manager+0x570>
ffffffffc020610e:	43d8                	lw	a4,4(a5)
ffffffffc0206110:	06300593          	li	a1,99
ffffffffc0206114:	0b478793          	addi	a5,a5,180
ffffffffc0206118:	00002517          	auipc	a0,0x2
ffffffffc020611c:	79050513          	addi	a0,a0,1936 # ffffffffc02088a8 <default_pmm_manager+0x5a0>
ffffffffc0206120:	8f6fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0206124 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0206124:	00054783          	lbu	a5,0(a0)
ffffffffc0206128:	cb91                	beqz	a5,ffffffffc020613c <strlen+0x18>
    size_t cnt = 0;
ffffffffc020612a:	4781                	li	a5,0
        cnt ++;
ffffffffc020612c:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc020612e:	00f50733          	add	a4,a0,a5
ffffffffc0206132:	00074703          	lbu	a4,0(a4)
ffffffffc0206136:	fb7d                	bnez	a4,ffffffffc020612c <strlen+0x8>
    }
    return cnt;
}
ffffffffc0206138:	853e                	mv	a0,a5
ffffffffc020613a:	8082                	ret
    size_t cnt = 0;
ffffffffc020613c:	4781                	li	a5,0
}
ffffffffc020613e:	853e                	mv	a0,a5
ffffffffc0206140:	8082                	ret

ffffffffc0206142 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206142:	c185                	beqz	a1,ffffffffc0206162 <strnlen+0x20>
ffffffffc0206144:	00054783          	lbu	a5,0(a0)
ffffffffc0206148:	cf89                	beqz	a5,ffffffffc0206162 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc020614a:	4781                	li	a5,0
ffffffffc020614c:	a021                	j	ffffffffc0206154 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc020614e:	00074703          	lbu	a4,0(a4)
ffffffffc0206152:	c711                	beqz	a4,ffffffffc020615e <strnlen+0x1c>
        cnt ++;
ffffffffc0206154:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206156:	00f50733          	add	a4,a0,a5
ffffffffc020615a:	fef59ae3          	bne	a1,a5,ffffffffc020614e <strnlen+0xc>
    }
    return cnt;
}
ffffffffc020615e:	853e                	mv	a0,a5
ffffffffc0206160:	8082                	ret
    size_t cnt = 0;
ffffffffc0206162:	4781                	li	a5,0
}
ffffffffc0206164:	853e                	mv	a0,a5
ffffffffc0206166:	8082                	ret

ffffffffc0206168 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0206168:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc020616a:	0585                	addi	a1,a1,1
ffffffffc020616c:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0206170:	0785                	addi	a5,a5,1
ffffffffc0206172:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0206176:	fb75                	bnez	a4,ffffffffc020616a <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0206178:	8082                	ret

ffffffffc020617a <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020617a:	00054783          	lbu	a5,0(a0)
ffffffffc020617e:	0005c703          	lbu	a4,0(a1)
ffffffffc0206182:	cb91                	beqz	a5,ffffffffc0206196 <strcmp+0x1c>
ffffffffc0206184:	00e79c63          	bne	a5,a4,ffffffffc020619c <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0206188:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020618a:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc020618e:	0585                	addi	a1,a1,1
ffffffffc0206190:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206194:	fbe5                	bnez	a5,ffffffffc0206184 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206196:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0206198:	9d19                	subw	a0,a0,a4
ffffffffc020619a:	8082                	ret
ffffffffc020619c:	0007851b          	sext.w	a0,a5
ffffffffc02061a0:	9d19                	subw	a0,a0,a4
ffffffffc02061a2:	8082                	ret

ffffffffc02061a4 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02061a4:	00054783          	lbu	a5,0(a0)
ffffffffc02061a8:	cb91                	beqz	a5,ffffffffc02061bc <strchr+0x18>
        if (*s == c) {
ffffffffc02061aa:	00b79563          	bne	a5,a1,ffffffffc02061b4 <strchr+0x10>
ffffffffc02061ae:	a809                	j	ffffffffc02061c0 <strchr+0x1c>
ffffffffc02061b0:	00b78763          	beq	a5,a1,ffffffffc02061be <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02061b4:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02061b6:	00054783          	lbu	a5,0(a0)
ffffffffc02061ba:	fbfd                	bnez	a5,ffffffffc02061b0 <strchr+0xc>
    }
    return NULL;
ffffffffc02061bc:	4501                	li	a0,0
}
ffffffffc02061be:	8082                	ret
ffffffffc02061c0:	8082                	ret

ffffffffc02061c2 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02061c2:	ca01                	beqz	a2,ffffffffc02061d2 <memset+0x10>
ffffffffc02061c4:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02061c6:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02061c8:	0785                	addi	a5,a5,1
ffffffffc02061ca:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02061ce:	fec79de3          	bne	a5,a2,ffffffffc02061c8 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02061d2:	8082                	ret

ffffffffc02061d4 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02061d4:	ca19                	beqz	a2,ffffffffc02061ea <memcpy+0x16>
ffffffffc02061d6:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02061d8:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02061da:	0585                	addi	a1,a1,1
ffffffffc02061dc:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02061e0:	0785                	addi	a5,a5,1
ffffffffc02061e2:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02061e6:	fec59ae3          	bne	a1,a2,ffffffffc02061da <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02061ea:	8082                	ret

ffffffffc02061ec <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02061ec:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02061f0:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02061f2:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02061f6:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02061f8:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02061fc:	f022                	sd	s0,32(sp)
ffffffffc02061fe:	ec26                	sd	s1,24(sp)
ffffffffc0206200:	e84a                	sd	s2,16(sp)
ffffffffc0206202:	f406                	sd	ra,40(sp)
ffffffffc0206204:	e44e                	sd	s3,8(sp)
ffffffffc0206206:	84aa                	mv	s1,a0
ffffffffc0206208:	892e                	mv	s2,a1
ffffffffc020620a:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020620e:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0206210:	03067e63          	bleu	a6,a2,ffffffffc020624c <printnum+0x60>
ffffffffc0206214:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0206216:	00805763          	blez	s0,ffffffffc0206224 <printnum+0x38>
ffffffffc020621a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020621c:	85ca                	mv	a1,s2
ffffffffc020621e:	854e                	mv	a0,s3
ffffffffc0206220:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0206222:	fc65                	bnez	s0,ffffffffc020621a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206224:	1a02                	slli	s4,s4,0x20
ffffffffc0206226:	020a5a13          	srli	s4,s4,0x20
ffffffffc020622a:	00003797          	auipc	a5,0x3
ffffffffc020622e:	9b678793          	addi	a5,a5,-1610 # ffffffffc0208be0 <error_string+0xc8>
ffffffffc0206232:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0206234:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206236:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020623a:	70a2                	ld	ra,40(sp)
ffffffffc020623c:	69a2                	ld	s3,8(sp)
ffffffffc020623e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206240:	85ca                	mv	a1,s2
ffffffffc0206242:	8326                	mv	t1,s1
}
ffffffffc0206244:	6942                	ld	s2,16(sp)
ffffffffc0206246:	64e2                	ld	s1,24(sp)
ffffffffc0206248:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020624a:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020624c:	03065633          	divu	a2,a2,a6
ffffffffc0206250:	8722                	mv	a4,s0
ffffffffc0206252:	f9bff0ef          	jal	ra,ffffffffc02061ec <printnum>
ffffffffc0206256:	b7f9                	j	ffffffffc0206224 <printnum+0x38>

ffffffffc0206258 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0206258:	7119                	addi	sp,sp,-128
ffffffffc020625a:	f4a6                	sd	s1,104(sp)
ffffffffc020625c:	f0ca                	sd	s2,96(sp)
ffffffffc020625e:	e8d2                	sd	s4,80(sp)
ffffffffc0206260:	e4d6                	sd	s5,72(sp)
ffffffffc0206262:	e0da                	sd	s6,64(sp)
ffffffffc0206264:	fc5e                	sd	s7,56(sp)
ffffffffc0206266:	f862                	sd	s8,48(sp)
ffffffffc0206268:	f06a                	sd	s10,32(sp)
ffffffffc020626a:	fc86                	sd	ra,120(sp)
ffffffffc020626c:	f8a2                	sd	s0,112(sp)
ffffffffc020626e:	ecce                	sd	s3,88(sp)
ffffffffc0206270:	f466                	sd	s9,40(sp)
ffffffffc0206272:	ec6e                	sd	s11,24(sp)
ffffffffc0206274:	892a                	mv	s2,a0
ffffffffc0206276:	84ae                	mv	s1,a1
ffffffffc0206278:	8d32                	mv	s10,a2
ffffffffc020627a:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020627c:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020627e:	00002a17          	auipc	s4,0x2
ffffffffc0206282:	742a0a13          	addi	s4,s4,1858 # ffffffffc02089c0 <syscalls+0x100>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206286:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020628a:	00003c17          	auipc	s8,0x3
ffffffffc020628e:	88ec0c13          	addi	s8,s8,-1906 # ffffffffc0208b18 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206292:	000d4503          	lbu	a0,0(s10)
ffffffffc0206296:	02500793          	li	a5,37
ffffffffc020629a:	001d0413          	addi	s0,s10,1
ffffffffc020629e:	00f50e63          	beq	a0,a5,ffffffffc02062ba <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02062a2:	c521                	beqz	a0,ffffffffc02062ea <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062a4:	02500993          	li	s3,37
ffffffffc02062a8:	a011                	j	ffffffffc02062ac <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc02062aa:	c121                	beqz	a0,ffffffffc02062ea <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc02062ac:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062ae:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02062b0:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062b2:	fff44503          	lbu	a0,-1(s0)
ffffffffc02062b6:	ff351ae3          	bne	a0,s3,ffffffffc02062aa <vprintfmt+0x52>
ffffffffc02062ba:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02062be:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02062c2:	4981                	li	s3,0
ffffffffc02062c4:	4801                	li	a6,0
        width = precision = -1;
ffffffffc02062c6:	5cfd                	li	s9,-1
ffffffffc02062c8:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062ca:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc02062ce:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062d0:	fdd6069b          	addiw	a3,a2,-35
ffffffffc02062d4:	0ff6f693          	andi	a3,a3,255
ffffffffc02062d8:	00140d13          	addi	s10,s0,1
ffffffffc02062dc:	20d5e563          	bltu	a1,a3,ffffffffc02064e6 <vprintfmt+0x28e>
ffffffffc02062e0:	068a                	slli	a3,a3,0x2
ffffffffc02062e2:	96d2                	add	a3,a3,s4
ffffffffc02062e4:	4294                	lw	a3,0(a3)
ffffffffc02062e6:	96d2                	add	a3,a3,s4
ffffffffc02062e8:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02062ea:	70e6                	ld	ra,120(sp)
ffffffffc02062ec:	7446                	ld	s0,112(sp)
ffffffffc02062ee:	74a6                	ld	s1,104(sp)
ffffffffc02062f0:	7906                	ld	s2,96(sp)
ffffffffc02062f2:	69e6                	ld	s3,88(sp)
ffffffffc02062f4:	6a46                	ld	s4,80(sp)
ffffffffc02062f6:	6aa6                	ld	s5,72(sp)
ffffffffc02062f8:	6b06                	ld	s6,64(sp)
ffffffffc02062fa:	7be2                	ld	s7,56(sp)
ffffffffc02062fc:	7c42                	ld	s8,48(sp)
ffffffffc02062fe:	7ca2                	ld	s9,40(sp)
ffffffffc0206300:	7d02                	ld	s10,32(sp)
ffffffffc0206302:	6de2                	ld	s11,24(sp)
ffffffffc0206304:	6109                	addi	sp,sp,128
ffffffffc0206306:	8082                	ret
    if (lflag >= 2) {
ffffffffc0206308:	4705                	li	a4,1
ffffffffc020630a:	008a8593          	addi	a1,s5,8
ffffffffc020630e:	01074463          	blt	a4,a6,ffffffffc0206316 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0206312:	26080363          	beqz	a6,ffffffffc0206578 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0206316:	000ab603          	ld	a2,0(s5)
ffffffffc020631a:	46c1                	li	a3,16
ffffffffc020631c:	8aae                	mv	s5,a1
ffffffffc020631e:	a06d                	j	ffffffffc02063c8 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0206320:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0206324:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206326:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206328:	b765                	j	ffffffffc02062d0 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc020632a:	000aa503          	lw	a0,0(s5)
ffffffffc020632e:	85a6                	mv	a1,s1
ffffffffc0206330:	0aa1                	addi	s5,s5,8
ffffffffc0206332:	9902                	jalr	s2
            break;
ffffffffc0206334:	bfb9                	j	ffffffffc0206292 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206336:	4705                	li	a4,1
ffffffffc0206338:	008a8993          	addi	s3,s5,8
ffffffffc020633c:	01074463          	blt	a4,a6,ffffffffc0206344 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0206340:	22080463          	beqz	a6,ffffffffc0206568 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0206344:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0206348:	24044463          	bltz	s0,ffffffffc0206590 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc020634c:	8622                	mv	a2,s0
ffffffffc020634e:	8ace                	mv	s5,s3
ffffffffc0206350:	46a9                	li	a3,10
ffffffffc0206352:	a89d                	j	ffffffffc02063c8 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0206354:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206358:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc020635a:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc020635c:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0206360:	8fb5                	xor	a5,a5,a3
ffffffffc0206362:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206366:	1ad74363          	blt	a4,a3,ffffffffc020650c <vprintfmt+0x2b4>
ffffffffc020636a:	00369793          	slli	a5,a3,0x3
ffffffffc020636e:	97e2                	add	a5,a5,s8
ffffffffc0206370:	639c                	ld	a5,0(a5)
ffffffffc0206372:	18078d63          	beqz	a5,ffffffffc020650c <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0206376:	86be                	mv	a3,a5
ffffffffc0206378:	00000617          	auipc	a2,0x0
ffffffffc020637c:	2b060613          	addi	a2,a2,688 # ffffffffc0206628 <etext+0x2c>
ffffffffc0206380:	85a6                	mv	a1,s1
ffffffffc0206382:	854a                	mv	a0,s2
ffffffffc0206384:	240000ef          	jal	ra,ffffffffc02065c4 <printfmt>
ffffffffc0206388:	b729                	j	ffffffffc0206292 <vprintfmt+0x3a>
            lflag ++;
ffffffffc020638a:	00144603          	lbu	a2,1(s0)
ffffffffc020638e:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206390:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206392:	bf3d                	j	ffffffffc02062d0 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0206394:	4705                	li	a4,1
ffffffffc0206396:	008a8593          	addi	a1,s5,8
ffffffffc020639a:	01074463          	blt	a4,a6,ffffffffc02063a2 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc020639e:	1e080263          	beqz	a6,ffffffffc0206582 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc02063a2:	000ab603          	ld	a2,0(s5)
ffffffffc02063a6:	46a1                	li	a3,8
ffffffffc02063a8:	8aae                	mv	s5,a1
ffffffffc02063aa:	a839                	j	ffffffffc02063c8 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc02063ac:	03000513          	li	a0,48
ffffffffc02063b0:	85a6                	mv	a1,s1
ffffffffc02063b2:	e03e                	sd	a5,0(sp)
ffffffffc02063b4:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02063b6:	85a6                	mv	a1,s1
ffffffffc02063b8:	07800513          	li	a0,120
ffffffffc02063bc:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02063be:	0aa1                	addi	s5,s5,8
ffffffffc02063c0:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc02063c4:	6782                	ld	a5,0(sp)
ffffffffc02063c6:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02063c8:	876e                	mv	a4,s11
ffffffffc02063ca:	85a6                	mv	a1,s1
ffffffffc02063cc:	854a                	mv	a0,s2
ffffffffc02063ce:	e1fff0ef          	jal	ra,ffffffffc02061ec <printnum>
            break;
ffffffffc02063d2:	b5c1                	j	ffffffffc0206292 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02063d4:	000ab603          	ld	a2,0(s5)
ffffffffc02063d8:	0aa1                	addi	s5,s5,8
ffffffffc02063da:	1c060663          	beqz	a2,ffffffffc02065a6 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc02063de:	00160413          	addi	s0,a2,1
ffffffffc02063e2:	17b05c63          	blez	s11,ffffffffc020655a <vprintfmt+0x302>
ffffffffc02063e6:	02d00593          	li	a1,45
ffffffffc02063ea:	14b79263          	bne	a5,a1,ffffffffc020652e <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02063ee:	00064783          	lbu	a5,0(a2)
ffffffffc02063f2:	0007851b          	sext.w	a0,a5
ffffffffc02063f6:	c905                	beqz	a0,ffffffffc0206426 <vprintfmt+0x1ce>
ffffffffc02063f8:	000cc563          	bltz	s9,ffffffffc0206402 <vprintfmt+0x1aa>
ffffffffc02063fc:	3cfd                	addiw	s9,s9,-1
ffffffffc02063fe:	036c8263          	beq	s9,s6,ffffffffc0206422 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0206402:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206404:	18098463          	beqz	s3,ffffffffc020658c <vprintfmt+0x334>
ffffffffc0206408:	3781                	addiw	a5,a5,-32
ffffffffc020640a:	18fbf163          	bleu	a5,s7,ffffffffc020658c <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc020640e:	03f00513          	li	a0,63
ffffffffc0206412:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206414:	0405                	addi	s0,s0,1
ffffffffc0206416:	fff44783          	lbu	a5,-1(s0)
ffffffffc020641a:	3dfd                	addiw	s11,s11,-1
ffffffffc020641c:	0007851b          	sext.w	a0,a5
ffffffffc0206420:	fd61                	bnez	a0,ffffffffc02063f8 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0206422:	e7b058e3          	blez	s11,ffffffffc0206292 <vprintfmt+0x3a>
ffffffffc0206426:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0206428:	85a6                	mv	a1,s1
ffffffffc020642a:	02000513          	li	a0,32
ffffffffc020642e:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206430:	e60d81e3          	beqz	s11,ffffffffc0206292 <vprintfmt+0x3a>
ffffffffc0206434:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0206436:	85a6                	mv	a1,s1
ffffffffc0206438:	02000513          	li	a0,32
ffffffffc020643c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020643e:	fe0d94e3          	bnez	s11,ffffffffc0206426 <vprintfmt+0x1ce>
ffffffffc0206442:	bd81                	j	ffffffffc0206292 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206444:	4705                	li	a4,1
ffffffffc0206446:	008a8593          	addi	a1,s5,8
ffffffffc020644a:	01074463          	blt	a4,a6,ffffffffc0206452 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc020644e:	12080063          	beqz	a6,ffffffffc020656e <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0206452:	000ab603          	ld	a2,0(s5)
ffffffffc0206456:	46a9                	li	a3,10
ffffffffc0206458:	8aae                	mv	s5,a1
ffffffffc020645a:	b7bd                	j	ffffffffc02063c8 <vprintfmt+0x170>
ffffffffc020645c:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0206460:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206464:	846a                	mv	s0,s10
ffffffffc0206466:	b5ad                	j	ffffffffc02062d0 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0206468:	85a6                	mv	a1,s1
ffffffffc020646a:	02500513          	li	a0,37
ffffffffc020646e:	9902                	jalr	s2
            break;
ffffffffc0206470:	b50d                	j	ffffffffc0206292 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0206472:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0206476:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020647a:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020647c:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc020647e:	e40dd9e3          	bgez	s11,ffffffffc02062d0 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0206482:	8de6                	mv	s11,s9
ffffffffc0206484:	5cfd                	li	s9,-1
ffffffffc0206486:	b5a9                	j	ffffffffc02062d0 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0206488:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc020648c:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206490:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206492:	bd3d                	j	ffffffffc02062d0 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0206494:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0206498:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020649c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020649e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02064a2:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02064a6:	fcd56ce3          	bltu	a0,a3,ffffffffc020647e <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc02064aa:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02064ac:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc02064b0:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02064b4:	0196873b          	addw	a4,a3,s9
ffffffffc02064b8:	0017171b          	slliw	a4,a4,0x1
ffffffffc02064bc:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc02064c0:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc02064c4:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02064c8:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02064cc:	fcd57fe3          	bleu	a3,a0,ffffffffc02064aa <vprintfmt+0x252>
ffffffffc02064d0:	b77d                	j	ffffffffc020647e <vprintfmt+0x226>
            if (width < 0)
ffffffffc02064d2:	fffdc693          	not	a3,s11
ffffffffc02064d6:	96fd                	srai	a3,a3,0x3f
ffffffffc02064d8:	00ddfdb3          	and	s11,s11,a3
ffffffffc02064dc:	00144603          	lbu	a2,1(s0)
ffffffffc02064e0:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064e2:	846a                	mv	s0,s10
ffffffffc02064e4:	b3f5                	j	ffffffffc02062d0 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc02064e6:	85a6                	mv	a1,s1
ffffffffc02064e8:	02500513          	li	a0,37
ffffffffc02064ec:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02064ee:	fff44703          	lbu	a4,-1(s0)
ffffffffc02064f2:	02500793          	li	a5,37
ffffffffc02064f6:	8d22                	mv	s10,s0
ffffffffc02064f8:	d8f70de3          	beq	a4,a5,ffffffffc0206292 <vprintfmt+0x3a>
ffffffffc02064fc:	02500713          	li	a4,37
ffffffffc0206500:	1d7d                	addi	s10,s10,-1
ffffffffc0206502:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0206506:	fee79de3          	bne	a5,a4,ffffffffc0206500 <vprintfmt+0x2a8>
ffffffffc020650a:	b361                	j	ffffffffc0206292 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020650c:	00002617          	auipc	a2,0x2
ffffffffc0206510:	7b460613          	addi	a2,a2,1972 # ffffffffc0208cc0 <error_string+0x1a8>
ffffffffc0206514:	85a6                	mv	a1,s1
ffffffffc0206516:	854a                	mv	a0,s2
ffffffffc0206518:	0ac000ef          	jal	ra,ffffffffc02065c4 <printfmt>
ffffffffc020651c:	bb9d                	j	ffffffffc0206292 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020651e:	00002617          	auipc	a2,0x2
ffffffffc0206522:	79a60613          	addi	a2,a2,1946 # ffffffffc0208cb8 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
ffffffffc0206526:	00002417          	auipc	s0,0x2
ffffffffc020652a:	79340413          	addi	s0,s0,1939 # ffffffffc0208cb9 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020652e:	8532                	mv	a0,a2
ffffffffc0206530:	85e6                	mv	a1,s9
ffffffffc0206532:	e032                	sd	a2,0(sp)
ffffffffc0206534:	e43e                	sd	a5,8(sp)
ffffffffc0206536:	c0dff0ef          	jal	ra,ffffffffc0206142 <strnlen>
ffffffffc020653a:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020653e:	6602                	ld	a2,0(sp)
ffffffffc0206540:	01b05d63          	blez	s11,ffffffffc020655a <vprintfmt+0x302>
ffffffffc0206544:	67a2                	ld	a5,8(sp)
ffffffffc0206546:	2781                	sext.w	a5,a5
ffffffffc0206548:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc020654a:	6522                	ld	a0,8(sp)
ffffffffc020654c:	85a6                	mv	a1,s1
ffffffffc020654e:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206550:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0206552:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206554:	6602                	ld	a2,0(sp)
ffffffffc0206556:	fe0d9ae3          	bnez	s11,ffffffffc020654a <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020655a:	00064783          	lbu	a5,0(a2)
ffffffffc020655e:	0007851b          	sext.w	a0,a5
ffffffffc0206562:	e8051be3          	bnez	a0,ffffffffc02063f8 <vprintfmt+0x1a0>
ffffffffc0206566:	b335                	j	ffffffffc0206292 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0206568:	000aa403          	lw	s0,0(s5)
ffffffffc020656c:	bbf1                	j	ffffffffc0206348 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc020656e:	000ae603          	lwu	a2,0(s5)
ffffffffc0206572:	46a9                	li	a3,10
ffffffffc0206574:	8aae                	mv	s5,a1
ffffffffc0206576:	bd89                	j	ffffffffc02063c8 <vprintfmt+0x170>
ffffffffc0206578:	000ae603          	lwu	a2,0(s5)
ffffffffc020657c:	46c1                	li	a3,16
ffffffffc020657e:	8aae                	mv	s5,a1
ffffffffc0206580:	b5a1                	j	ffffffffc02063c8 <vprintfmt+0x170>
ffffffffc0206582:	000ae603          	lwu	a2,0(s5)
ffffffffc0206586:	46a1                	li	a3,8
ffffffffc0206588:	8aae                	mv	s5,a1
ffffffffc020658a:	bd3d                	j	ffffffffc02063c8 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc020658c:	9902                	jalr	s2
ffffffffc020658e:	b559                	j	ffffffffc0206414 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0206590:	85a6                	mv	a1,s1
ffffffffc0206592:	02d00513          	li	a0,45
ffffffffc0206596:	e03e                	sd	a5,0(sp)
ffffffffc0206598:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020659a:	8ace                	mv	s5,s3
ffffffffc020659c:	40800633          	neg	a2,s0
ffffffffc02065a0:	46a9                	li	a3,10
ffffffffc02065a2:	6782                	ld	a5,0(sp)
ffffffffc02065a4:	b515                	j	ffffffffc02063c8 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc02065a6:	01b05663          	blez	s11,ffffffffc02065b2 <vprintfmt+0x35a>
ffffffffc02065aa:	02d00693          	li	a3,45
ffffffffc02065ae:	f6d798e3          	bne	a5,a3,ffffffffc020651e <vprintfmt+0x2c6>
ffffffffc02065b2:	00002417          	auipc	s0,0x2
ffffffffc02065b6:	70740413          	addi	s0,s0,1799 # ffffffffc0208cb9 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02065ba:	02800513          	li	a0,40
ffffffffc02065be:	02800793          	li	a5,40
ffffffffc02065c2:	bd1d                	j	ffffffffc02063f8 <vprintfmt+0x1a0>

ffffffffc02065c4 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02065c4:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02065c6:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02065ca:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02065cc:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02065ce:	ec06                	sd	ra,24(sp)
ffffffffc02065d0:	f83a                	sd	a4,48(sp)
ffffffffc02065d2:	fc3e                	sd	a5,56(sp)
ffffffffc02065d4:	e0c2                	sd	a6,64(sp)
ffffffffc02065d6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02065d8:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02065da:	c7fff0ef          	jal	ra,ffffffffc0206258 <vprintfmt>
}
ffffffffc02065de:	60e2                	ld	ra,24(sp)
ffffffffc02065e0:	6161                	addi	sp,sp,80
ffffffffc02065e2:	8082                	ret

ffffffffc02065e4 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02065e4:	9e3707b7          	lui	a5,0x9e370
ffffffffc02065e8:	2785                	addiw	a5,a5,1
ffffffffc02065ea:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc02065ee:	02000793          	li	a5,32
ffffffffc02065f2:	40b785bb          	subw	a1,a5,a1
}
ffffffffc02065f6:	00b5553b          	srlw	a0,a0,a1
ffffffffc02065fa:	8082                	ret
