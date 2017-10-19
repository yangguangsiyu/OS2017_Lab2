
obj/kern/kernel：     文件格式 elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 d0 11 00       	mov    $0x11d000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 d0 11 f0       	mov    $0xf011d000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5c 00 00 00       	call   f010009a <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 20 9f 23 f0 00 	cmpl   $0x0,0xf0239f20
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 20 9f 23 f0    	mov    %esi,0xf0239f20

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 a1 54 00 00       	call   f0105502 <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 a0 5b 10 f0       	push   $0xf0105ba0
f010006d:	e8 46 2c 00 00       	call   f0102cb8 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 16 2c 00 00       	call   f0102c92 <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 3c 5f 10 f0 	movl   $0xf0105f3c,(%esp)
f0100083:	e8 30 2c 00 00       	call   f0102cb8 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 84 08 00 00       	call   f0100919 <monitor>
f0100095:	83 c4 10             	add    $0x10,%esp
f0100098:	eb f1                	jmp    f010008b <_panic+0x4b>

f010009a <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010009a:	55                   	push   %ebp
f010009b:	89 e5                	mov    %esp,%ebp
f010009d:	53                   	push   %ebx
f010009e:	83 ec 08             	sub    $0x8,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a1:	b8 08 b0 27 f0       	mov    $0xf027b008,%eax
f01000a6:	2d 8c 87 23 f0       	sub    $0xf023878c,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 8c 87 23 f0       	push   $0xf023878c
f01000b3:	e8 28 4e 00 00       	call   f0104ee0 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 5c 05 00 00       	call   f0100619 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 0c 5c 10 f0       	push   $0xf0105c0c
f01000ca:	e8 e9 2b 00 00       	call   f0102cb8 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 07 0f 00 00       	call   f0100fdb <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 dc 23 00 00       	call   f01024b5 <env_init>
	trap_init();
f01000d9:	e8 54 2c 00 00       	call   f0102d32 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 15 51 00 00       	call   f01051f8 <mp_init>
	lapic_init();
f01000e3:	e8 35 54 00 00       	call   f010551d <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 f2 2a 00 00       	call   f0102bdf <pic_init>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000ed:	83 c4 10             	add    $0x10,%esp
f01000f0:	83 3d 28 9f 23 f0 07 	cmpl   $0x7,0xf0239f28
f01000f7:	77 16                	ja     f010010f <i386_init+0x75>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01000f9:	68 00 70 00 00       	push   $0x7000
f01000fe:	68 c4 5b 10 f0       	push   $0xf0105bc4
f0100103:	6a 64                	push   $0x64
f0100105:	68 27 5c 10 f0       	push   $0xf0105c27
f010010a:	e8 31 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010010f:	83 ec 04             	sub    $0x4,%esp
f0100112:	b8 5e 51 10 f0       	mov    $0xf010515e,%eax
f0100117:	2d e4 50 10 f0       	sub    $0xf01050e4,%eax
f010011c:	50                   	push   %eax
f010011d:	68 e4 50 10 f0       	push   $0xf01050e4
f0100122:	68 00 70 00 f0       	push   $0xf0007000
f0100127:	e8 01 4e 00 00       	call   f0104f2d <memmove>
f010012c:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010012f:	bb 20 a0 23 f0       	mov    $0xf023a020,%ebx
f0100134:	eb 4d                	jmp    f0100183 <i386_init+0xe9>
		if (c == cpus + cpunum())  // We've started already.
f0100136:	e8 c7 53 00 00       	call   f0105502 <cpunum>
f010013b:	6b c0 74             	imul   $0x74,%eax,%eax
f010013e:	05 20 a0 23 f0       	add    $0xf023a020,%eax
f0100143:	39 c3                	cmp    %eax,%ebx
f0100145:	74 39                	je     f0100180 <i386_init+0xe6>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100147:	89 d8                	mov    %ebx,%eax
f0100149:	2d 20 a0 23 f0       	sub    $0xf023a020,%eax
f010014e:	c1 f8 02             	sar    $0x2,%eax
f0100151:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100157:	c1 e0 0f             	shl    $0xf,%eax
f010015a:	05 00 30 24 f0       	add    $0xf0243000,%eax
f010015f:	a3 24 9f 23 f0       	mov    %eax,0xf0239f24
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100164:	83 ec 08             	sub    $0x8,%esp
f0100167:	68 00 70 00 00       	push   $0x7000
f010016c:	0f b6 03             	movzbl (%ebx),%eax
f010016f:	50                   	push   %eax
f0100170:	e8 f6 54 00 00       	call   f010566b <lapic_startap>
f0100175:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100178:	8b 43 04             	mov    0x4(%ebx),%eax
f010017b:	83 f8 01             	cmp    $0x1,%eax
f010017e:	75 f8                	jne    f0100178 <i386_init+0xde>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100180:	83 c3 74             	add    $0x74,%ebx
f0100183:	6b 05 c4 a3 23 f0 74 	imul   $0x74,0xf023a3c4,%eax
f010018a:	05 20 a0 23 f0       	add    $0xf023a020,%eax
f010018f:	39 c3                	cmp    %eax,%ebx
f0100191:	72 a3                	jb     f0100136 <i386_init+0x9c>
    

    /*
     ** This is also for lab4 Part 1
    */
    ENV_CREATE(user_faultdie, ENV_TYPE_USER);
f0100193:	83 ec 08             	sub    $0x8,%esp
f0100196:	6a 00                	push   $0x0
f0100198:	68 4c 24 1b f0       	push   $0xf01b244c
f010019d:	e8 3f 25 00 00       	call   f01026e1 <env_create>

#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f01001a2:	e8 3f 3d 00 00       	call   f0103ee6 <sched_yield>

f01001a7 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001a7:	55                   	push   %ebp
f01001a8:	89 e5                	mov    %esp,%ebp
f01001aa:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001ad:	a1 2c 9f 23 f0       	mov    0xf0239f2c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001b2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001b7:	77 12                	ja     f01001cb <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001b9:	50                   	push   %eax
f01001ba:	68 e8 5b 10 f0       	push   $0xf0105be8
f01001bf:	6a 7b                	push   $0x7b
f01001c1:	68 27 5c 10 f0       	push   $0xf0105c27
f01001c6:	e8 75 fe ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01001cb:	05 00 00 00 10       	add    $0x10000000,%eax
f01001d0:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001d3:	e8 2a 53 00 00       	call   f0105502 <cpunum>
f01001d8:	83 ec 08             	sub    $0x8,%esp
f01001db:	50                   	push   %eax
f01001dc:	68 33 5c 10 f0       	push   $0xf0105c33
f01001e1:	e8 d2 2a 00 00       	call   f0102cb8 <cprintf>

	lapic_init();
f01001e6:	e8 32 53 00 00       	call   f010551d <lapic_init>
	env_init_percpu();
f01001eb:	e8 95 22 00 00       	call   f0102485 <env_init_percpu>
	trap_init_percpu();
f01001f0:	e8 d7 2a 00 00       	call   f0102ccc <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001f5:	e8 08 53 00 00       	call   f0105502 <cpunum>
f01001fa:	6b d0 74             	imul   $0x74,%eax,%edx
f01001fd:	81 c2 20 a0 23 f0    	add    $0xf023a020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100203:	b8 01 00 00 00       	mov    $0x1,%eax
f0100208:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
	// only one CPU can enter the scheduler at a time!
	//
	// Lab2 Your code here:


    sched_yield();
f010020c:	e8 d5 3c 00 00       	call   f0103ee6 <sched_yield>

f0100211 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100211:	55                   	push   %ebp
f0100212:	89 e5                	mov    %esp,%ebp
f0100214:	53                   	push   %ebx
f0100215:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100218:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010021b:	ff 75 0c             	pushl  0xc(%ebp)
f010021e:	ff 75 08             	pushl  0x8(%ebp)
f0100221:	68 49 5c 10 f0       	push   $0xf0105c49
f0100226:	e8 8d 2a 00 00       	call   f0102cb8 <cprintf>
	vcprintf(fmt, ap);
f010022b:	83 c4 08             	add    $0x8,%esp
f010022e:	53                   	push   %ebx
f010022f:	ff 75 10             	pushl  0x10(%ebp)
f0100232:	e8 5b 2a 00 00       	call   f0102c92 <vcprintf>
	cprintf("\n");
f0100237:	c7 04 24 3c 5f 10 f0 	movl   $0xf0105f3c,(%esp)
f010023e:	e8 75 2a 00 00       	call   f0102cb8 <cprintf>
	va_end(ap);
}
f0100243:	83 c4 10             	add    $0x10,%esp
f0100246:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100249:	c9                   	leave  
f010024a:	c3                   	ret    

f010024b <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010024b:	55                   	push   %ebp
f010024c:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010024e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100253:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100254:	a8 01                	test   $0x1,%al
f0100256:	74 0b                	je     f0100263 <serial_proc_data+0x18>
f0100258:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010025d:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010025e:	0f b6 c0             	movzbl %al,%eax
f0100261:	eb 05                	jmp    f0100268 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100263:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100268:	5d                   	pop    %ebp
f0100269:	c3                   	ret    

f010026a <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010026a:	55                   	push   %ebp
f010026b:	89 e5                	mov    %esp,%ebp
f010026d:	53                   	push   %ebx
f010026e:	83 ec 04             	sub    $0x4,%esp
f0100271:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100273:	eb 2b                	jmp    f01002a0 <cons_intr+0x36>
		if (c == 0)
f0100275:	85 c0                	test   %eax,%eax
f0100277:	74 27                	je     f01002a0 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f0100279:	8b 0d 24 92 23 f0    	mov    0xf0239224,%ecx
f010027f:	8d 51 01             	lea    0x1(%ecx),%edx
f0100282:	89 15 24 92 23 f0    	mov    %edx,0xf0239224
f0100288:	88 81 20 90 23 f0    	mov    %al,-0xfdc6fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010028e:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100294:	75 0a                	jne    f01002a0 <cons_intr+0x36>
			cons.wpos = 0;
f0100296:	c7 05 24 92 23 f0 00 	movl   $0x0,0xf0239224
f010029d:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002a0:	ff d3                	call   *%ebx
f01002a2:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002a5:	75 ce                	jne    f0100275 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002a7:	83 c4 04             	add    $0x4,%esp
f01002aa:	5b                   	pop    %ebx
f01002ab:	5d                   	pop    %ebp
f01002ac:	c3                   	ret    

f01002ad <kbd_proc_data>:
f01002ad:	ba 64 00 00 00       	mov    $0x64,%edx
f01002b2:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01002b3:	a8 01                	test   $0x1,%al
f01002b5:	0f 84 f0 00 00 00    	je     f01003ab <kbd_proc_data+0xfe>
f01002bb:	ba 60 00 00 00       	mov    $0x60,%edx
f01002c0:	ec                   	in     (%dx),%al
f01002c1:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002c3:	3c e0                	cmp    $0xe0,%al
f01002c5:	75 0d                	jne    f01002d4 <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01002c7:	83 0d 00 90 23 f0 40 	orl    $0x40,0xf0239000
		return 0;
f01002ce:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002d3:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01002d4:	55                   	push   %ebp
f01002d5:	89 e5                	mov    %esp,%ebp
f01002d7:	53                   	push   %ebx
f01002d8:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01002db:	84 c0                	test   %al,%al
f01002dd:	79 36                	jns    f0100315 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01002df:	8b 0d 00 90 23 f0    	mov    0xf0239000,%ecx
f01002e5:	89 cb                	mov    %ecx,%ebx
f01002e7:	83 e3 40             	and    $0x40,%ebx
f01002ea:	83 e0 7f             	and    $0x7f,%eax
f01002ed:	85 db                	test   %ebx,%ebx
f01002ef:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002f2:	0f b6 d2             	movzbl %dl,%edx
f01002f5:	0f b6 82 c0 5d 10 f0 	movzbl -0xfefa240(%edx),%eax
f01002fc:	83 c8 40             	or     $0x40,%eax
f01002ff:	0f b6 c0             	movzbl %al,%eax
f0100302:	f7 d0                	not    %eax
f0100304:	21 c8                	and    %ecx,%eax
f0100306:	a3 00 90 23 f0       	mov    %eax,0xf0239000
		return 0;
f010030b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100310:	e9 9e 00 00 00       	jmp    f01003b3 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f0100315:	8b 0d 00 90 23 f0    	mov    0xf0239000,%ecx
f010031b:	f6 c1 40             	test   $0x40,%cl
f010031e:	74 0e                	je     f010032e <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100320:	83 c8 80             	or     $0xffffff80,%eax
f0100323:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100325:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100328:	89 0d 00 90 23 f0    	mov    %ecx,0xf0239000
	}

	shift |= shiftcode[data];
f010032e:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100331:	0f b6 82 c0 5d 10 f0 	movzbl -0xfefa240(%edx),%eax
f0100338:	0b 05 00 90 23 f0    	or     0xf0239000,%eax
f010033e:	0f b6 8a c0 5c 10 f0 	movzbl -0xfefa340(%edx),%ecx
f0100345:	31 c8                	xor    %ecx,%eax
f0100347:	a3 00 90 23 f0       	mov    %eax,0xf0239000

	c = charcode[shift & (CTL | SHIFT)][data];
f010034c:	89 c1                	mov    %eax,%ecx
f010034e:	83 e1 03             	and    $0x3,%ecx
f0100351:	8b 0c 8d a0 5c 10 f0 	mov    -0xfefa360(,%ecx,4),%ecx
f0100358:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010035c:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010035f:	a8 08                	test   $0x8,%al
f0100361:	74 1b                	je     f010037e <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f0100363:	89 da                	mov    %ebx,%edx
f0100365:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100368:	83 f9 19             	cmp    $0x19,%ecx
f010036b:	77 05                	ja     f0100372 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f010036d:	83 eb 20             	sub    $0x20,%ebx
f0100370:	eb 0c                	jmp    f010037e <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f0100372:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100375:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100378:	83 fa 19             	cmp    $0x19,%edx
f010037b:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010037e:	f7 d0                	not    %eax
f0100380:	a8 06                	test   $0x6,%al
f0100382:	75 2d                	jne    f01003b1 <kbd_proc_data+0x104>
f0100384:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010038a:	75 25                	jne    f01003b1 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f010038c:	83 ec 0c             	sub    $0xc,%esp
f010038f:	68 63 5c 10 f0       	push   $0xf0105c63
f0100394:	e8 1f 29 00 00       	call   f0102cb8 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100399:	ba 92 00 00 00       	mov    $0x92,%edx
f010039e:	b8 03 00 00 00       	mov    $0x3,%eax
f01003a3:	ee                   	out    %al,(%dx)
f01003a4:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003a7:	89 d8                	mov    %ebx,%eax
f01003a9:	eb 08                	jmp    f01003b3 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01003ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003b0:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003b1:	89 d8                	mov    %ebx,%eax
}
f01003b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003b6:	c9                   	leave  
f01003b7:	c3                   	ret    

f01003b8 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003b8:	55                   	push   %ebp
f01003b9:	89 e5                	mov    %esp,%ebp
f01003bb:	57                   	push   %edi
f01003bc:	56                   	push   %esi
f01003bd:	53                   	push   %ebx
f01003be:	83 ec 1c             	sub    $0x1c,%esp
f01003c1:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003c3:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003c8:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003cd:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003d2:	eb 09                	jmp    f01003dd <cons_putc+0x25>
f01003d4:	89 ca                	mov    %ecx,%edx
f01003d6:	ec                   	in     (%dx),%al
f01003d7:	ec                   	in     (%dx),%al
f01003d8:	ec                   	in     (%dx),%al
f01003d9:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01003da:	83 c3 01             	add    $0x1,%ebx
f01003dd:	89 f2                	mov    %esi,%edx
f01003df:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003e0:	a8 20                	test   $0x20,%al
f01003e2:	75 08                	jne    f01003ec <cons_putc+0x34>
f01003e4:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01003ea:	7e e8                	jle    f01003d4 <cons_putc+0x1c>
f01003ec:	89 f8                	mov    %edi,%eax
f01003ee:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003f1:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003f6:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003f7:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003fc:	be 79 03 00 00       	mov    $0x379,%esi
f0100401:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100406:	eb 09                	jmp    f0100411 <cons_putc+0x59>
f0100408:	89 ca                	mov    %ecx,%edx
f010040a:	ec                   	in     (%dx),%al
f010040b:	ec                   	in     (%dx),%al
f010040c:	ec                   	in     (%dx),%al
f010040d:	ec                   	in     (%dx),%al
f010040e:	83 c3 01             	add    $0x1,%ebx
f0100411:	89 f2                	mov    %esi,%edx
f0100413:	ec                   	in     (%dx),%al
f0100414:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010041a:	7f 04                	jg     f0100420 <cons_putc+0x68>
f010041c:	84 c0                	test   %al,%al
f010041e:	79 e8                	jns    f0100408 <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100420:	ba 78 03 00 00       	mov    $0x378,%edx
f0100425:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100429:	ee                   	out    %al,(%dx)
f010042a:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010042f:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100434:	ee                   	out    %al,(%dx)
f0100435:	b8 08 00 00 00       	mov    $0x8,%eax
f010043a:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010043b:	89 fa                	mov    %edi,%edx
f010043d:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100443:	89 f8                	mov    %edi,%eax
f0100445:	80 cc 07             	or     $0x7,%ah
f0100448:	85 d2                	test   %edx,%edx
f010044a:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010044d:	89 f8                	mov    %edi,%eax
f010044f:	0f b6 c0             	movzbl %al,%eax
f0100452:	83 f8 09             	cmp    $0x9,%eax
f0100455:	74 74                	je     f01004cb <cons_putc+0x113>
f0100457:	83 f8 09             	cmp    $0x9,%eax
f010045a:	7f 0a                	jg     f0100466 <cons_putc+0xae>
f010045c:	83 f8 08             	cmp    $0x8,%eax
f010045f:	74 14                	je     f0100475 <cons_putc+0xbd>
f0100461:	e9 99 00 00 00       	jmp    f01004ff <cons_putc+0x147>
f0100466:	83 f8 0a             	cmp    $0xa,%eax
f0100469:	74 3a                	je     f01004a5 <cons_putc+0xed>
f010046b:	83 f8 0d             	cmp    $0xd,%eax
f010046e:	74 3d                	je     f01004ad <cons_putc+0xf5>
f0100470:	e9 8a 00 00 00       	jmp    f01004ff <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f0100475:	0f b7 05 28 92 23 f0 	movzwl 0xf0239228,%eax
f010047c:	66 85 c0             	test   %ax,%ax
f010047f:	0f 84 e6 00 00 00    	je     f010056b <cons_putc+0x1b3>
			crt_pos--;
f0100485:	83 e8 01             	sub    $0x1,%eax
f0100488:	66 a3 28 92 23 f0    	mov    %ax,0xf0239228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010048e:	0f b7 c0             	movzwl %ax,%eax
f0100491:	66 81 e7 00 ff       	and    $0xff00,%di
f0100496:	83 cf 20             	or     $0x20,%edi
f0100499:	8b 15 2c 92 23 f0    	mov    0xf023922c,%edx
f010049f:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004a3:	eb 78                	jmp    f010051d <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004a5:	66 83 05 28 92 23 f0 	addw   $0x50,0xf0239228
f01004ac:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004ad:	0f b7 05 28 92 23 f0 	movzwl 0xf0239228,%eax
f01004b4:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004ba:	c1 e8 16             	shr    $0x16,%eax
f01004bd:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004c0:	c1 e0 04             	shl    $0x4,%eax
f01004c3:	66 a3 28 92 23 f0    	mov    %ax,0xf0239228
f01004c9:	eb 52                	jmp    f010051d <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01004cb:	b8 20 00 00 00       	mov    $0x20,%eax
f01004d0:	e8 e3 fe ff ff       	call   f01003b8 <cons_putc>
		cons_putc(' ');
f01004d5:	b8 20 00 00 00       	mov    $0x20,%eax
f01004da:	e8 d9 fe ff ff       	call   f01003b8 <cons_putc>
		cons_putc(' ');
f01004df:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e4:	e8 cf fe ff ff       	call   f01003b8 <cons_putc>
		cons_putc(' ');
f01004e9:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ee:	e8 c5 fe ff ff       	call   f01003b8 <cons_putc>
		cons_putc(' ');
f01004f3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f8:	e8 bb fe ff ff       	call   f01003b8 <cons_putc>
f01004fd:	eb 1e                	jmp    f010051d <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01004ff:	0f b7 05 28 92 23 f0 	movzwl 0xf0239228,%eax
f0100506:	8d 50 01             	lea    0x1(%eax),%edx
f0100509:	66 89 15 28 92 23 f0 	mov    %dx,0xf0239228
f0100510:	0f b7 c0             	movzwl %ax,%eax
f0100513:	8b 15 2c 92 23 f0    	mov    0xf023922c,%edx
f0100519:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010051d:	66 81 3d 28 92 23 f0 	cmpw   $0x7cf,0xf0239228
f0100524:	cf 07 
f0100526:	76 43                	jbe    f010056b <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100528:	a1 2c 92 23 f0       	mov    0xf023922c,%eax
f010052d:	83 ec 04             	sub    $0x4,%esp
f0100530:	68 00 0f 00 00       	push   $0xf00
f0100535:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010053b:	52                   	push   %edx
f010053c:	50                   	push   %eax
f010053d:	e8 eb 49 00 00       	call   f0104f2d <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100542:	8b 15 2c 92 23 f0    	mov    0xf023922c,%edx
f0100548:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010054e:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100554:	83 c4 10             	add    $0x10,%esp
f0100557:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010055c:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010055f:	39 d0                	cmp    %edx,%eax
f0100561:	75 f4                	jne    f0100557 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100563:	66 83 2d 28 92 23 f0 	subw   $0x50,0xf0239228
f010056a:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010056b:	8b 0d 30 92 23 f0    	mov    0xf0239230,%ecx
f0100571:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100576:	89 ca                	mov    %ecx,%edx
f0100578:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100579:	0f b7 1d 28 92 23 f0 	movzwl 0xf0239228,%ebx
f0100580:	8d 71 01             	lea    0x1(%ecx),%esi
f0100583:	89 d8                	mov    %ebx,%eax
f0100585:	66 c1 e8 08          	shr    $0x8,%ax
f0100589:	89 f2                	mov    %esi,%edx
f010058b:	ee                   	out    %al,(%dx)
f010058c:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100591:	89 ca                	mov    %ecx,%edx
f0100593:	ee                   	out    %al,(%dx)
f0100594:	89 d8                	mov    %ebx,%eax
f0100596:	89 f2                	mov    %esi,%edx
f0100598:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100599:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010059c:	5b                   	pop    %ebx
f010059d:	5e                   	pop    %esi
f010059e:	5f                   	pop    %edi
f010059f:	5d                   	pop    %ebp
f01005a0:	c3                   	ret    

f01005a1 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005a1:	80 3d 34 92 23 f0 00 	cmpb   $0x0,0xf0239234
f01005a8:	74 11                	je     f01005bb <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005aa:	55                   	push   %ebp
f01005ab:	89 e5                	mov    %esp,%ebp
f01005ad:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005b0:	b8 4b 02 10 f0       	mov    $0xf010024b,%eax
f01005b5:	e8 b0 fc ff ff       	call   f010026a <cons_intr>
}
f01005ba:	c9                   	leave  
f01005bb:	f3 c3                	repz ret 

f01005bd <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005bd:	55                   	push   %ebp
f01005be:	89 e5                	mov    %esp,%ebp
f01005c0:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005c3:	b8 ad 02 10 f0       	mov    $0xf01002ad,%eax
f01005c8:	e8 9d fc ff ff       	call   f010026a <cons_intr>
}
f01005cd:	c9                   	leave  
f01005ce:	c3                   	ret    

f01005cf <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005cf:	55                   	push   %ebp
f01005d0:	89 e5                	mov    %esp,%ebp
f01005d2:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01005d5:	e8 c7 ff ff ff       	call   f01005a1 <serial_intr>
	kbd_intr();
f01005da:	e8 de ff ff ff       	call   f01005bd <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01005df:	a1 20 92 23 f0       	mov    0xf0239220,%eax
f01005e4:	3b 05 24 92 23 f0    	cmp    0xf0239224,%eax
f01005ea:	74 26                	je     f0100612 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01005ec:	8d 50 01             	lea    0x1(%eax),%edx
f01005ef:	89 15 20 92 23 f0    	mov    %edx,0xf0239220
f01005f5:	0f b6 88 20 90 23 f0 	movzbl -0xfdc6fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01005fc:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01005fe:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100604:	75 11                	jne    f0100617 <cons_getc+0x48>
			cons.rpos = 0;
f0100606:	c7 05 20 92 23 f0 00 	movl   $0x0,0xf0239220
f010060d:	00 00 00 
f0100610:	eb 05                	jmp    f0100617 <cons_getc+0x48>
		return c;
	}
	return 0;
f0100612:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100617:	c9                   	leave  
f0100618:	c3                   	ret    

f0100619 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100619:	55                   	push   %ebp
f010061a:	89 e5                	mov    %esp,%ebp
f010061c:	57                   	push   %edi
f010061d:	56                   	push   %esi
f010061e:	53                   	push   %ebx
f010061f:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100622:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100629:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100630:	5a a5 
	if (*cp != 0xA55A) {
f0100632:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100639:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010063d:	74 11                	je     f0100650 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010063f:	c7 05 30 92 23 f0 b4 	movl   $0x3b4,0xf0239230
f0100646:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100649:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010064e:	eb 16                	jmp    f0100666 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100650:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100657:	c7 05 30 92 23 f0 d4 	movl   $0x3d4,0xf0239230
f010065e:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100661:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100666:	8b 3d 30 92 23 f0    	mov    0xf0239230,%edi
f010066c:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100671:	89 fa                	mov    %edi,%edx
f0100673:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100674:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100677:	89 da                	mov    %ebx,%edx
f0100679:	ec                   	in     (%dx),%al
f010067a:	0f b6 c8             	movzbl %al,%ecx
f010067d:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100680:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100685:	89 fa                	mov    %edi,%edx
f0100687:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100688:	89 da                	mov    %ebx,%edx
f010068a:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010068b:	89 35 2c 92 23 f0    	mov    %esi,0xf023922c
	crt_pos = pos;
f0100691:	0f b6 c0             	movzbl %al,%eax
f0100694:	09 c8                	or     %ecx,%eax
f0100696:	66 a3 28 92 23 f0    	mov    %ax,0xf0239228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f010069c:	e8 1c ff ff ff       	call   f01005bd <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01006a1:	83 ec 0c             	sub    $0xc,%esp
f01006a4:	0f b7 05 88 f3 11 f0 	movzwl 0xf011f388,%eax
f01006ab:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006b0:	50                   	push   %eax
f01006b1:	e8 b1 24 00 00       	call   f0102b67 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006b6:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006bb:	b8 00 00 00 00       	mov    $0x0,%eax
f01006c0:	89 f2                	mov    %esi,%edx
f01006c2:	ee                   	out    %al,(%dx)
f01006c3:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006c8:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006cd:	ee                   	out    %al,(%dx)
f01006ce:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01006d3:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006d8:	89 da                	mov    %ebx,%edx
f01006da:	ee                   	out    %al,(%dx)
f01006db:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01006e0:	b8 00 00 00 00       	mov    $0x0,%eax
f01006e5:	ee                   	out    %al,(%dx)
f01006e6:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006eb:	b8 03 00 00 00       	mov    $0x3,%eax
f01006f0:	ee                   	out    %al,(%dx)
f01006f1:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01006fb:	ee                   	out    %al,(%dx)
f01006fc:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100701:	b8 01 00 00 00       	mov    $0x1,%eax
f0100706:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100707:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010070c:	ec                   	in     (%dx),%al
f010070d:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010070f:	83 c4 10             	add    $0x10,%esp
f0100712:	3c ff                	cmp    $0xff,%al
f0100714:	0f 95 05 34 92 23 f0 	setne  0xf0239234
f010071b:	89 f2                	mov    %esi,%edx
f010071d:	ec                   	in     (%dx),%al
f010071e:	89 da                	mov    %ebx,%edx
f0100720:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100721:	80 f9 ff             	cmp    $0xff,%cl
f0100724:	75 10                	jne    f0100736 <cons_init+0x11d>
		cprintf("Serial port does not exist!\n");
f0100726:	83 ec 0c             	sub    $0xc,%esp
f0100729:	68 6f 5c 10 f0       	push   $0xf0105c6f
f010072e:	e8 85 25 00 00       	call   f0102cb8 <cprintf>
f0100733:	83 c4 10             	add    $0x10,%esp
}
f0100736:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100739:	5b                   	pop    %ebx
f010073a:	5e                   	pop    %esi
f010073b:	5f                   	pop    %edi
f010073c:	5d                   	pop    %ebp
f010073d:	c3                   	ret    

f010073e <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010073e:	55                   	push   %ebp
f010073f:	89 e5                	mov    %esp,%ebp
f0100741:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100744:	8b 45 08             	mov    0x8(%ebp),%eax
f0100747:	e8 6c fc ff ff       	call   f01003b8 <cons_putc>
}
f010074c:	c9                   	leave  
f010074d:	c3                   	ret    

f010074e <getchar>:

int
getchar(void)
{
f010074e:	55                   	push   %ebp
f010074f:	89 e5                	mov    %esp,%ebp
f0100751:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100754:	e8 76 fe ff ff       	call   f01005cf <cons_getc>
f0100759:	85 c0                	test   %eax,%eax
f010075b:	74 f7                	je     f0100754 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010075d:	c9                   	leave  
f010075e:	c3                   	ret    

f010075f <iscons>:

int
iscons(int fdnum)
{
f010075f:	55                   	push   %ebp
f0100760:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100762:	b8 01 00 00 00       	mov    $0x1,%eax
f0100767:	5d                   	pop    %ebp
f0100768:	c3                   	ret    

f0100769 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100769:	55                   	push   %ebp
f010076a:	89 e5                	mov    %esp,%ebp
f010076c:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010076f:	68 c0 5e 10 f0       	push   $0xf0105ec0
f0100774:	68 de 5e 10 f0       	push   $0xf0105ede
f0100779:	68 e3 5e 10 f0       	push   $0xf0105ee3
f010077e:	e8 35 25 00 00       	call   f0102cb8 <cprintf>
f0100783:	83 c4 0c             	add    $0xc,%esp
f0100786:	68 84 5f 10 f0       	push   $0xf0105f84
f010078b:	68 ec 5e 10 f0       	push   $0xf0105eec
f0100790:	68 e3 5e 10 f0       	push   $0xf0105ee3
f0100795:	e8 1e 25 00 00       	call   f0102cb8 <cprintf>
	return 0;
}
f010079a:	b8 00 00 00 00       	mov    $0x0,%eax
f010079f:	c9                   	leave  
f01007a0:	c3                   	ret    

f01007a1 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007a1:	55                   	push   %ebp
f01007a2:	89 e5                	mov    %esp,%ebp
f01007a4:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007a7:	68 f5 5e 10 f0       	push   $0xf0105ef5
f01007ac:	e8 07 25 00 00       	call   f0102cb8 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007b1:	83 c4 08             	add    $0x8,%esp
f01007b4:	68 0c 00 10 00       	push   $0x10000c
f01007b9:	68 ac 5f 10 f0       	push   $0xf0105fac
f01007be:	e8 f5 24 00 00       	call   f0102cb8 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007c3:	83 c4 0c             	add    $0xc,%esp
f01007c6:	68 0c 00 10 00       	push   $0x10000c
f01007cb:	68 0c 00 10 f0       	push   $0xf010000c
f01007d0:	68 d4 5f 10 f0       	push   $0xf0105fd4
f01007d5:	e8 de 24 00 00       	call   f0102cb8 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007da:	83 c4 0c             	add    $0xc,%esp
f01007dd:	68 81 5b 10 00       	push   $0x105b81
f01007e2:	68 81 5b 10 f0       	push   $0xf0105b81
f01007e7:	68 f8 5f 10 f0       	push   $0xf0105ff8
f01007ec:	e8 c7 24 00 00       	call   f0102cb8 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007f1:	83 c4 0c             	add    $0xc,%esp
f01007f4:	68 8c 87 23 00       	push   $0x23878c
f01007f9:	68 8c 87 23 f0       	push   $0xf023878c
f01007fe:	68 1c 60 10 f0       	push   $0xf010601c
f0100803:	e8 b0 24 00 00       	call   f0102cb8 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100808:	83 c4 0c             	add    $0xc,%esp
f010080b:	68 08 b0 27 00       	push   $0x27b008
f0100810:	68 08 b0 27 f0       	push   $0xf027b008
f0100815:	68 40 60 10 f0       	push   $0xf0106040
f010081a:	e8 99 24 00 00       	call   f0102cb8 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010081f:	b8 07 b4 27 f0       	mov    $0xf027b407,%eax
f0100824:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100829:	83 c4 08             	add    $0x8,%esp
f010082c:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100831:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100837:	85 c0                	test   %eax,%eax
f0100839:	0f 48 c2             	cmovs  %edx,%eax
f010083c:	c1 f8 0a             	sar    $0xa,%eax
f010083f:	50                   	push   %eax
f0100840:	68 64 60 10 f0       	push   $0xf0106064
f0100845:	e8 6e 24 00 00       	call   f0102cb8 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010084a:	b8 00 00 00 00       	mov    $0x0,%eax
f010084f:	c9                   	leave  
f0100850:	c3                   	ret    

f0100851 <read_eip>:

unsigned int read_eip()
{
f0100851:	55                   	push   %ebp
f0100852:	89 e5                	mov    %esp,%ebp
    unsigned int callerpc;
    __asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f0100854:	8b 45 04             	mov    0x4(%ebp),%eax
    return callerpc;
}
f0100857:	5d                   	pop    %ebp
f0100858:	c3                   	ret    

f0100859 <mon_backtrace>:
}


int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100859:	55                   	push   %ebp
f010085a:	89 e5                	mov    %esp,%ebp
f010085c:	57                   	push   %edi
f010085d:	56                   	push   %esi
f010085e:	53                   	push   %ebx
f010085f:	83 ec 14             	sub    $0x14,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100862:	89 ee                	mov    %ebp,%esi
}

unsigned int read_eip()
{
    unsigned int callerpc;
    __asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f0100864:	8b 5d 04             	mov    0x4(%ebp),%ebx
{
	// Your code here.
    unsigned int *p  = (unsigned int*) read_ebp();
    unsigned int eip = read_eip();

    cprintf("current eip=%08x", eip);
f0100867:	53                   	push   %ebx
f0100868:	68 0e 5f 10 f0       	push   $0xf0105f0e
f010086d:	e8 46 24 00 00       	call   f0102cb8 <cprintf>
    debuginfo_eip((uintptr_t) eip, &info);
f0100872:	83 c4 08             	add    $0x8,%esp
f0100875:	68 38 92 23 f0       	push   $0xf0239238
f010087a:	53                   	push   %ebx
f010087b:	e8 79 3c 00 00       	call   f01044f9 <debuginfo_eip>
    cprintf("\n");
f0100880:	c7 04 24 3c 5f 10 f0 	movl   $0xf0105f3c,(%esp)
f0100887:	e8 2c 24 00 00       	call   f0102cb8 <cprintf>
f010088c:	83 c4 10             	add    $0x10,%esp
static inline unsigned int*
dump_stack(unsigned int* p)
{
    unsigned int i = 0;

    cprintf("ebp %08x eip %08x args", p, J_ARG_N(p, 1));
f010088f:	83 ec 04             	sub    $0x4,%esp
f0100892:	ff 76 04             	pushl  0x4(%esi)
f0100895:	56                   	push   %esi
f0100896:	68 1f 5f 10 f0       	push   $0xf0105f1f
f010089b:	e8 18 24 00 00       	call   f0102cb8 <cprintf>
f01008a0:	8d 5e 08             	lea    0x8(%esi),%ebx
f01008a3:	8d 7e 1c             	lea    0x1c(%esi),%edi
f01008a6:	83 c4 10             	add    $0x10,%esp
    
    for (i = 2; i < 7;i++)
    {
        cprintf(" %08x \n", J_ARG_N(p, i));
f01008a9:	83 ec 08             	sub    $0x8,%esp
f01008ac:	ff 33                	pushl  (%ebx)
f01008ae:	68 36 5f 10 f0       	push   $0xf0105f36
f01008b3:	e8 00 24 00 00       	call   f0102cb8 <cprintf>
f01008b8:	83 c3 04             	add    $0x4,%ebx
{
    unsigned int i = 0;

    cprintf("ebp %08x eip %08x args", p, J_ARG_N(p, 1));
    
    for (i = 2; i < 7;i++)
f01008bb:	83 c4 10             	add    $0x10,%esp
f01008be:	39 fb                	cmp    %edi,%ebx
f01008c0:	75 e7                	jne    f01008a9 <mon_backtrace+0x50>
    {
        cprintf(" %08x \n", J_ARG_N(p, i));
    }
    
    return (unsigned int*)J_NEXT_EBP(p);
f01008c2:	8b 36                	mov    (%esi),%esi
    debuginfo_eip((uintptr_t) eip, &info);
    cprintf("\n");
    do
    {
        p = dump_stack(p);
    }while(p);
f01008c4:	85 f6                	test   %esi,%esi
f01008c6:	75 c7                	jne    f010088f <mon_backtrace+0x36>

    cprintf("\n");
f01008c8:	83 ec 0c             	sub    $0xc,%esp
f01008cb:	68 3c 5f 10 f0       	push   $0xf0105f3c
f01008d0:	e8 e3 23 00 00       	call   f0102cb8 <cprintf>
f01008d5:	89 eb                	mov    %ebp,%ebx
    p = (unsigned int*)read_ebp();
f01008d7:	83 c4 10             	add    $0x10,%esp

static inline unsigned int*
dump_backstrace_symbols(unsigned int *p)
{

    cprintf("%s %d\n",info.eip_fn_name, info.eip_line);
f01008da:	83 ec 04             	sub    $0x4,%esp
f01008dd:	ff 35 3c 92 23 f0    	pushl  0xf023923c
f01008e3:	ff 35 40 92 23 f0    	pushl  0xf0239240
f01008e9:	68 3e 5f 10 f0       	push   $0xf0105f3e
f01008ee:	e8 c5 23 00 00       	call   f0102cb8 <cprintf>

    debuginfo_eip((uintptr_t)*(p+1), &info);
f01008f3:	83 c4 08             	add    $0x8,%esp
f01008f6:	68 38 92 23 f0       	push   $0xf0239238
f01008fb:	ff 73 04             	pushl  0x4(%ebx)
f01008fe:	e8 f6 3b 00 00       	call   f01044f9 <debuginfo_eip>

    return (unsigned int*)J_NEXT_EBP(p);
f0100903:	8b 1b                	mov    (%ebx),%ebx
    cprintf("\n");
    p = (unsigned int*)read_ebp();
    do
    {
        p = dump_backstrace_symbols(p);
    }while(p);
f0100905:	83 c4 10             	add    $0x10,%esp
f0100908:	85 db                	test   %ebx,%ebx
f010090a:	75 ce                	jne    f01008da <mon_backtrace+0x81>

	return 0;
}
f010090c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100911:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100914:	5b                   	pop    %ebx
f0100915:	5e                   	pop    %esi
f0100916:	5f                   	pop    %edi
f0100917:	5d                   	pop    %ebp
f0100918:	c3                   	ret    

f0100919 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100919:	55                   	push   %ebp
f010091a:	89 e5                	mov    %esp,%ebp
f010091c:	57                   	push   %edi
f010091d:	56                   	push   %esi
f010091e:	53                   	push   %ebx
f010091f:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	//cprintf("Welcome to %Cc the JOS kernel monitor!\n", COLOR_GRN, 'H');
	cprintf("Welcome to the JOS kernel monitor!\n");
f0100922:	68 90 60 10 f0       	push   $0xf0106090
f0100927:	e8 8c 23 00 00       	call   f0102cb8 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010092c:	c7 04 24 b4 60 10 f0 	movl   $0xf01060b4,(%esp)
f0100933:	e8 80 23 00 00       	call   f0102cb8 <cprintf>

	if (tf != NULL)
f0100938:	83 c4 10             	add    $0x10,%esp
f010093b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010093f:	74 0e                	je     f010094f <monitor+0x36>
		print_trapframe(tf);
f0100941:	83 ec 0c             	sub    $0xc,%esp
f0100944:	ff 75 08             	pushl  0x8(%ebp)
f0100947:	e8 03 25 00 00       	call   f0102e4f <print_trapframe>
f010094c:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f010094f:	83 ec 0c             	sub    $0xc,%esp
f0100952:	68 45 5f 10 f0       	push   $0xf0105f45
f0100957:	e8 2d 43 00 00       	call   f0104c89 <readline>
f010095c:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010095e:	83 c4 10             	add    $0x10,%esp
f0100961:	85 c0                	test   %eax,%eax
f0100963:	74 ea                	je     f010094f <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100965:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010096c:	be 00 00 00 00       	mov    $0x0,%esi
f0100971:	eb 0a                	jmp    f010097d <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100973:	c6 03 00             	movb   $0x0,(%ebx)
f0100976:	89 f7                	mov    %esi,%edi
f0100978:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010097b:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010097d:	0f b6 03             	movzbl (%ebx),%eax
f0100980:	84 c0                	test   %al,%al
f0100982:	74 63                	je     f01009e7 <monitor+0xce>
f0100984:	83 ec 08             	sub    $0x8,%esp
f0100987:	0f be c0             	movsbl %al,%eax
f010098a:	50                   	push   %eax
f010098b:	68 49 5f 10 f0       	push   $0xf0105f49
f0100990:	e8 0e 45 00 00       	call   f0104ea3 <strchr>
f0100995:	83 c4 10             	add    $0x10,%esp
f0100998:	85 c0                	test   %eax,%eax
f010099a:	75 d7                	jne    f0100973 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f010099c:	80 3b 00             	cmpb   $0x0,(%ebx)
f010099f:	74 46                	je     f01009e7 <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01009a1:	83 fe 0f             	cmp    $0xf,%esi
f01009a4:	75 14                	jne    f01009ba <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009a6:	83 ec 08             	sub    $0x8,%esp
f01009a9:	6a 10                	push   $0x10
f01009ab:	68 4e 5f 10 f0       	push   $0xf0105f4e
f01009b0:	e8 03 23 00 00       	call   f0102cb8 <cprintf>
f01009b5:	83 c4 10             	add    $0x10,%esp
f01009b8:	eb 95                	jmp    f010094f <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f01009ba:	8d 7e 01             	lea    0x1(%esi),%edi
f01009bd:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01009c1:	eb 03                	jmp    f01009c6 <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01009c3:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01009c6:	0f b6 03             	movzbl (%ebx),%eax
f01009c9:	84 c0                	test   %al,%al
f01009cb:	74 ae                	je     f010097b <monitor+0x62>
f01009cd:	83 ec 08             	sub    $0x8,%esp
f01009d0:	0f be c0             	movsbl %al,%eax
f01009d3:	50                   	push   %eax
f01009d4:	68 49 5f 10 f0       	push   $0xf0105f49
f01009d9:	e8 c5 44 00 00       	call   f0104ea3 <strchr>
f01009de:	83 c4 10             	add    $0x10,%esp
f01009e1:	85 c0                	test   %eax,%eax
f01009e3:	74 de                	je     f01009c3 <monitor+0xaa>
f01009e5:	eb 94                	jmp    f010097b <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f01009e7:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009ee:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01009ef:	85 f6                	test   %esi,%esi
f01009f1:	0f 84 58 ff ff ff    	je     f010094f <monitor+0x36>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01009f7:	83 ec 08             	sub    $0x8,%esp
f01009fa:	68 de 5e 10 f0       	push   $0xf0105ede
f01009ff:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a02:	e8 3e 44 00 00       	call   f0104e45 <strcmp>
f0100a07:	83 c4 10             	add    $0x10,%esp
f0100a0a:	85 c0                	test   %eax,%eax
f0100a0c:	74 1e                	je     f0100a2c <monitor+0x113>
f0100a0e:	83 ec 08             	sub    $0x8,%esp
f0100a11:	68 ec 5e 10 f0       	push   $0xf0105eec
f0100a16:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a19:	e8 27 44 00 00       	call   f0104e45 <strcmp>
f0100a1e:	83 c4 10             	add    $0x10,%esp
f0100a21:	85 c0                	test   %eax,%eax
f0100a23:	75 2f                	jne    f0100a54 <monitor+0x13b>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100a25:	b8 01 00 00 00       	mov    $0x1,%eax
f0100a2a:	eb 05                	jmp    f0100a31 <monitor+0x118>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a2c:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f0100a31:	83 ec 04             	sub    $0x4,%esp
f0100a34:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100a37:	01 d0                	add    %edx,%eax
f0100a39:	ff 75 08             	pushl  0x8(%ebp)
f0100a3c:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100a3f:	51                   	push   %ecx
f0100a40:	56                   	push   %esi
f0100a41:	ff 14 85 e4 60 10 f0 	call   *-0xfef9f1c(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a48:	83 c4 10             	add    $0x10,%esp
f0100a4b:	85 c0                	test   %eax,%eax
f0100a4d:	78 1d                	js     f0100a6c <monitor+0x153>
f0100a4f:	e9 fb fe ff ff       	jmp    f010094f <monitor+0x36>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a54:	83 ec 08             	sub    $0x8,%esp
f0100a57:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a5a:	68 6b 5f 10 f0       	push   $0xf0105f6b
f0100a5f:	e8 54 22 00 00       	call   f0102cb8 <cprintf>
f0100a64:	83 c4 10             	add    $0x10,%esp
f0100a67:	e9 e3 fe ff ff       	jmp    f010094f <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a6f:	5b                   	pop    %ebx
f0100a70:	5e                   	pop    %esi
f0100a71:	5f                   	pop    %edi
f0100a72:	5d                   	pop    %ebp
f0100a73:	c3                   	ret    

f0100a74 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a74:	55                   	push   %ebp
f0100a75:	89 e5                	mov    %esp,%ebp
f0100a77:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a79:	83 3d 50 92 23 f0 00 	cmpl   $0x0,0xf0239250
f0100a80:	75 0f                	jne    f0100a91 <boot_alloc+0x1d>
		extern char end[];
		nextfree = (char *)ROUNDUP((char *) end, PGSIZE);
f0100a82:	b8 07 c0 27 f0       	mov    $0xf027c007,%eax
f0100a87:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a8c:	a3 50 92 23 f0       	mov    %eax,0xf0239250
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

    result = nextfree;
f0100a91:	a1 50 92 23 f0       	mov    0xf0239250,%eax
    nextfree += ROUNDUP(n, PGSIZE);
f0100a96:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0100a9c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100aa2:	01 c2                	add    %eax,%edx
f0100aa4:	89 15 50 92 23 f0    	mov    %edx,0xf0239250

	return result;
}
f0100aaa:	5d                   	pop    %ebp
f0100aab:	c3                   	ret    

f0100aac <page2kva>:
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100aac:	2b 05 30 9f 23 f0    	sub    0xf0239f30,%eax
f0100ab2:	c1 f8 03             	sar    $0x3,%eax
f0100ab5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ab8:	89 c2                	mov    %eax,%edx
f0100aba:	c1 ea 0c             	shr    $0xc,%edx
f0100abd:	39 15 28 9f 23 f0    	cmp    %edx,0xf0239f28
f0100ac3:	77 18                	ja     f0100add <page2kva+0x31>
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f0100ac5:	55                   	push   %ebp
f0100ac6:	89 e5                	mov    %esp,%ebp
f0100ac8:	83 ec 08             	sub    $0x8,%esp

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100acb:	50                   	push   %eax
f0100acc:	68 c4 5b 10 f0       	push   $0xf0105bc4
f0100ad1:	6a 58                	push   $0x58
f0100ad3:	68 e9 66 10 f0       	push   $0xf01066e9
f0100ad8:	e8 63 f5 ff ff       	call   f0100040 <_panic>
}

static inline void*
page2kva(struct PageInfo *pp)
{
	return KADDR(page2pa(pp));
f0100add:	2d 00 00 00 10       	sub    $0x10000000,%eax
}
f0100ae2:	c3                   	ret    

f0100ae3 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100ae3:	89 d1                	mov    %edx,%ecx
f0100ae5:	c1 e9 16             	shr    $0x16,%ecx
f0100ae8:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100aeb:	a8 01                	test   $0x1,%al
f0100aed:	74 52                	je     f0100b41 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100aef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100af4:	89 c1                	mov    %eax,%ecx
f0100af6:	c1 e9 0c             	shr    $0xc,%ecx
f0100af9:	3b 0d 28 9f 23 f0    	cmp    0xf0239f28,%ecx
f0100aff:	72 1b                	jb     f0100b1c <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b01:	55                   	push   %ebp
f0100b02:	89 e5                	mov    %esp,%ebp
f0100b04:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b07:	50                   	push   %eax
f0100b08:	68 c4 5b 10 f0       	push   $0xf0105bc4
f0100b0d:	68 fd 03 00 00       	push   $0x3fd
f0100b12:	68 f7 66 10 f0       	push   $0xf01066f7
f0100b17:	e8 24 f5 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100b1c:	c1 ea 0c             	shr    $0xc,%edx
f0100b1f:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b25:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b2c:	89 c2                	mov    %eax,%edx
f0100b2e:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b31:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b36:	85 d2                	test   %edx,%edx
f0100b38:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b3d:	0f 44 c2             	cmove  %edx,%eax
f0100b40:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100b41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100b46:	c3                   	ret    

f0100b47 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100b47:	55                   	push   %ebp
f0100b48:	89 e5                	mov    %esp,%ebp
f0100b4a:	57                   	push   %edi
f0100b4b:	56                   	push   %esi
f0100b4c:	53                   	push   %ebx
f0100b4d:	83 ec 0c             	sub    $0xc,%esp
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
    uint32_t pa;
    page_free_list = NULL;
f0100b50:	c7 05 58 92 23 f0 00 	movl   $0x0,0xf0239258
f0100b57:	00 00 00 

    for(i = 0; i<npages; i++)
f0100b5a:	be 00 00 00 00       	mov    $0x0,%esi
f0100b5f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100b64:	e9 0f 01 00 00       	jmp    f0100c78 <page_init+0x131>
    {
		
        if(i == 0)
f0100b69:	85 db                	test   %ebx,%ebx
f0100b6b:	75 16                	jne    f0100b83 <page_init+0x3c>
        {
            pages[0].pp_ref = 1;
f0100b6d:	a1 30 9f 23 f0       	mov    0xf0239f30,%eax
f0100b72:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
            pages[0].pp_link = NULL;
f0100b78:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
            continue;
f0100b7e:	e9 ef 00 00 00       	jmp    f0100c72 <page_init+0x12b>
        }
        else if(i == MPENTRY_PADDR/PGSIZE)
f0100b83:	83 fb 07             	cmp    $0x7,%ebx
f0100b86:	75 1f                	jne    f0100ba7 <page_init+0x60>
        {
            // for lab 4
            pages[i].pp_ref = 1;
f0100b88:	a1 30 9f 23 f0       	mov    0xf0239f30,%eax
f0100b8d:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
            pages[i].pp_link = NULL;
f0100b93:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b9a:	89 f7                	mov    %esi,%edi
f0100b9c:	c1 ff 03             	sar    $0x3,%edi
f0100b9f:	c1 e7 0c             	shl    $0xc,%edi
f0100ba2:	e9 97 00 00 00       	jmp    f0100c3e <page_init+0xf7>
        }
        else if(i < npages_basemem)
f0100ba7:	3b 1d 5c 92 23 f0    	cmp    0xf023925c,%ebx
f0100bad:	73 25                	jae    f0100bd4 <page_init+0x8d>
        {
            // used for base memory
            pages[i].pp_ref = 0;
f0100baf:	89 f0                	mov    %esi,%eax
f0100bb1:	03 05 30 9f 23 f0    	add    0xf0239f30,%eax
f0100bb7:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
            pages[i].pp_link = page_free_list;
f0100bbd:	8b 15 58 92 23 f0    	mov    0xf0239258,%edx
f0100bc3:	89 10                	mov    %edx,(%eax)
            page_free_list = &pages[i];
f0100bc5:	89 f0                	mov    %esi,%eax
f0100bc7:	03 05 30 9f 23 f0    	add    0xf0239f30,%eax
f0100bcd:	a3 58 92 23 f0       	mov    %eax,0xf0239258
f0100bd2:	eb 56                	jmp    f0100c2a <page_init+0xe3>
        }
        else if(i <= (EXTPHYSMEM/PGSIZE) || i < (((uint32_t)boot_alloc(0) - KERNBASE) >> PGSHIFT))
f0100bd4:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
f0100bda:	76 16                	jbe    f0100bf2 <page_init+0xab>
f0100bdc:	b8 00 00 00 00       	mov    $0x0,%eax
f0100be1:	e8 8e fe ff ff       	call   f0100a74 <boot_alloc>
f0100be6:	05 00 00 00 10       	add    $0x10000000,%eax
f0100beb:	c1 e8 0c             	shr    $0xc,%eax
f0100bee:	39 c3                	cmp    %eax,%ebx
f0100bf0:	73 15                	jae    f0100c07 <page_init+0xc0>
        {
            //used for IO memory
            pages[i].pp_ref++;
f0100bf2:	89 f0                	mov    %esi,%eax
f0100bf4:	03 05 30 9f 23 f0    	add    0xf0239f30,%eax
f0100bfa:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
            pages[i].pp_link = NULL;
f0100bff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100c05:	eb 23                	jmp    f0100c2a <page_init+0xe3>
        }
        else
        {
            pages[i].pp_ref = 0;
f0100c07:	89 f0                	mov    %esi,%eax
f0100c09:	03 05 30 9f 23 f0    	add    0xf0239f30,%eax
f0100c0f:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
            pages[i].pp_link = page_free_list;
f0100c15:	8b 15 58 92 23 f0    	mov    0xf0239258,%edx
f0100c1b:	89 10                	mov    %edx,(%eax)
            page_free_list = &pages[i];
f0100c1d:	89 f0                	mov    %esi,%eax
f0100c1f:	03 05 30 9f 23 f0    	add    0xf0239f30,%eax
f0100c25:	a3 58 92 23 f0       	mov    %eax,0xf0239258
f0100c2a:	89 f7                	mov    %esi,%edi
f0100c2c:	c1 ff 03             	sar    $0x3,%edi
f0100c2f:	c1 e7 0c             	shl    $0xc,%edi
        }

        pa = page2pa(&pages[i]);

        if((pa == 0 || (pa < IOPHYSMEM && pa <= ((uint32_t)boot_alloc(0) - KERNBASE) >> PGSHIFT)) && (pages[i].pp_ref == 0))
f0100c32:	85 ff                	test   %edi,%edi
f0100c34:	74 1e                	je     f0100c54 <page_init+0x10d>
f0100c36:	81 ff ff ff 09 00    	cmp    $0x9ffff,%edi
f0100c3c:	77 34                	ja     f0100c72 <page_init+0x12b>
f0100c3e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c43:	e8 2c fe ff ff       	call   f0100a74 <boot_alloc>
f0100c48:	05 00 00 00 10       	add    $0x10000000,%eax
f0100c4d:	c1 e8 0c             	shr    $0xc,%eax
f0100c50:	39 f8                	cmp    %edi,%eax
f0100c52:	72 1e                	jb     f0100c72 <page_init+0x12b>
f0100c54:	a1 30 9f 23 f0       	mov    0xf0239f30,%eax
f0100c59:	66 83 7c 30 04 00    	cmpw   $0x0,0x4(%eax,%esi,1)
f0100c5f:	75 11                	jne    f0100c72 <page_init+0x12b>
        {
            cprintf("page error : i %d\n",i);
f0100c61:	83 ec 08             	sub    $0x8,%esp
f0100c64:	53                   	push   %ebx
f0100c65:	68 03 67 10 f0       	push   $0xf0106703
f0100c6a:	e8 49 20 00 00       	call   f0102cb8 <cprintf>
f0100c6f:	83 c4 10             	add    $0x10,%esp
	// free pages!
	size_t i;
    uint32_t pa;
    page_free_list = NULL;

    for(i = 0; i<npages; i++)
f0100c72:	83 c3 01             	add    $0x1,%ebx
f0100c75:	83 c6 08             	add    $0x8,%esi
f0100c78:	3b 1d 28 9f 23 f0    	cmp    0xf0239f28,%ebx
f0100c7e:	0f 82 e5 fe ff ff    	jb     f0100b69 <page_init+0x22>
        {
            cprintf("page error : i %d\n",i);
        }

    }
}
f0100c84:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c87:	5b                   	pop    %ebx
f0100c88:	5e                   	pop    %esi
f0100c89:	5f                   	pop    %edi
f0100c8a:	5d                   	pop    %ebp
f0100c8b:	c3                   	ret    

f0100c8c <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100c8c:	55                   	push   %ebp
f0100c8d:	89 e5                	mov    %esp,%ebp
f0100c8f:	53                   	push   %ebx
f0100c90:	83 ec 04             	sub    $0x4,%esp
    struct PageInfo* pp = NULL;
    if (!page_free_list)
f0100c93:	8b 1d 58 92 23 f0    	mov    0xf0239258,%ebx
f0100c99:	85 db                	test   %ebx,%ebx
f0100c9b:	74 52                	je     f0100cef <page_alloc+0x63>
        return NULL;
    }

    pp = page_free_list;

    page_free_list = page_free_list->pp_link;
f0100c9d:	8b 03                	mov    (%ebx),%eax
f0100c9f:	a3 58 92 23 f0       	mov    %eax,0xf0239258

    if(alloc_flags & ALLOC_ZERO)
f0100ca4:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100ca8:	74 45                	je     f0100cef <page_alloc+0x63>
f0100caa:	89 d8                	mov    %ebx,%eax
f0100cac:	2b 05 30 9f 23 f0    	sub    0xf0239f30,%eax
f0100cb2:	c1 f8 03             	sar    $0x3,%eax
f0100cb5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100cb8:	89 c2                	mov    %eax,%edx
f0100cba:	c1 ea 0c             	shr    $0xc,%edx
f0100cbd:	3b 15 28 9f 23 f0    	cmp    0xf0239f28,%edx
f0100cc3:	72 12                	jb     f0100cd7 <page_alloc+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cc5:	50                   	push   %eax
f0100cc6:	68 c4 5b 10 f0       	push   $0xf0105bc4
f0100ccb:	6a 58                	push   $0x58
f0100ccd:	68 e9 66 10 f0       	push   $0xf01066e9
f0100cd2:	e8 69 f3 ff ff       	call   f0100040 <_panic>
    {
        memset(page2kva(pp), 0, PGSIZE);
f0100cd7:	83 ec 04             	sub    $0x4,%esp
f0100cda:	68 00 10 00 00       	push   $0x1000
f0100cdf:	6a 00                	push   $0x0
f0100ce1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ce6:	50                   	push   %eax
f0100ce7:	e8 f4 41 00 00       	call   f0104ee0 <memset>
f0100cec:	83 c4 10             	add    $0x10,%esp
    }

	return pp;
}
f0100cef:	89 d8                	mov    %ebx,%eax
f0100cf1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100cf4:	c9                   	leave  
f0100cf5:	c3                   	ret    

f0100cf6 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100cf6:	55                   	push   %ebp
f0100cf7:	89 e5                	mov    %esp,%ebp
f0100cf9:	83 ec 08             	sub    $0x8,%esp
f0100cfc:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.

    assert(pp->pp_ref == 0 || pp->pp_link == NULL);
f0100cff:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100d04:	74 1e                	je     f0100d24 <page_free+0x2e>
f0100d06:	83 38 00             	cmpl   $0x0,(%eax)
f0100d09:	74 19                	je     f0100d24 <page_free+0x2e>
f0100d0b:	68 f4 60 10 f0       	push   $0xf01060f4
f0100d10:	68 16 67 10 f0       	push   $0xf0106716
f0100d15:	68 b2 01 00 00       	push   $0x1b2
f0100d1a:	68 f7 66 10 f0       	push   $0xf01066f7
f0100d1f:	e8 1c f3 ff ff       	call   f0100040 <_panic>

    pp->pp_link = page_free_list;
f0100d24:	8b 15 58 92 23 f0    	mov    0xf0239258,%edx
f0100d2a:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f0100d2c:	a3 58 92 23 f0       	mov    %eax,0xf0239258
}
f0100d31:	c9                   	leave  
f0100d32:	c3                   	ret    

f0100d33 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100d33:	55                   	push   %ebp
f0100d34:	89 e5                	mov    %esp,%ebp
f0100d36:	83 ec 08             	sub    $0x8,%esp
f0100d39:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100d3c:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100d40:	83 e8 01             	sub    $0x1,%eax
f0100d43:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100d47:	66 85 c0             	test   %ax,%ax
f0100d4a:	75 0c                	jne    f0100d58 <page_decref+0x25>
		page_free(pp);
f0100d4c:	83 ec 0c             	sub    $0xc,%esp
f0100d4f:	52                   	push   %edx
f0100d50:	e8 a1 ff ff ff       	call   f0100cf6 <page_free>
f0100d55:	83 c4 10             	add    $0x10,%esp
}
f0100d58:	c9                   	leave  
f0100d59:	c3                   	ret    

f0100d5a <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100d5a:	55                   	push   %ebp
f0100d5b:	89 e5                	mov    %esp,%ebp
f0100d5d:	57                   	push   %edi
f0100d5e:	56                   	push   %esi
f0100d5f:	53                   	push   %ebx
f0100d60:	83 ec 0c             	sub    $0xc,%esp
f0100d63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    pde_t *pde = NULL;
    pte_t *pgtable = NULL;

    struct PageInfo *pp = NULL;

    pde = &pgdir[PDX(va)];
f0100d66:	89 de                	mov    %ebx,%esi
f0100d68:	c1 ee 16             	shr    $0x16,%esi
f0100d6b:	c1 e6 02             	shl    $0x2,%esi
f0100d6e:	03 75 08             	add    0x8(%ebp),%esi

    if(*pde & PTE_P)
f0100d71:	8b 06                	mov    (%esi),%eax
f0100d73:	a8 01                	test   $0x1,%al
f0100d75:	74 2f                	je     f0100da6 <pgdir_walk+0x4c>
    {
        pgtable = (KADDR(PTE_ADDR(*pde)));
f0100d77:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d7c:	89 c2                	mov    %eax,%edx
f0100d7e:	c1 ea 0c             	shr    $0xc,%edx
f0100d81:	39 15 28 9f 23 f0    	cmp    %edx,0xf0239f28
f0100d87:	77 15                	ja     f0100d9e <pgdir_walk+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d89:	50                   	push   %eax
f0100d8a:	68 c4 5b 10 f0       	push   $0xf0105bc4
f0100d8f:	68 e7 01 00 00       	push   $0x1e7
f0100d94:	68 f7 66 10 f0       	push   $0xf01066f7
f0100d99:	e8 a2 f2 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100d9e:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f0100da4:	eb 77                	jmp    f0100e1d <pgdir_walk+0xc3>
    }
    else
    {
        if(!create ||
f0100da6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100daa:	74 7f                	je     f0100e2b <pgdir_walk+0xd1>
f0100dac:	83 ec 0c             	sub    $0xc,%esp
f0100daf:	6a 01                	push   $0x1
f0100db1:	e8 d6 fe ff ff       	call   f0100c8c <page_alloc>
f0100db6:	83 c4 10             	add    $0x10,%esp
f0100db9:	85 c0                	test   %eax,%eax
f0100dbb:	74 75                	je     f0100e32 <pgdir_walk+0xd8>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100dbd:	89 c1                	mov    %eax,%ecx
f0100dbf:	2b 0d 30 9f 23 f0    	sub    0xf0239f30,%ecx
f0100dc5:	c1 f9 03             	sar    $0x3,%ecx
f0100dc8:	c1 e1 0c             	shl    $0xc,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100dcb:	89 ca                	mov    %ecx,%edx
f0100dcd:	c1 ea 0c             	shr    $0xc,%edx
f0100dd0:	3b 15 28 9f 23 f0    	cmp    0xf0239f28,%edx
f0100dd6:	72 12                	jb     f0100dea <pgdir_walk+0x90>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100dd8:	51                   	push   %ecx
f0100dd9:	68 c4 5b 10 f0       	push   $0xf0105bc4
f0100dde:	6a 58                	push   $0x58
f0100de0:	68 e9 66 10 f0       	push   $0xf01066e9
f0100de5:	e8 56 f2 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100dea:	8d b9 00 00 00 f0    	lea    -0x10000000(%ecx),%edi
f0100df0:	89 fa                	mov    %edi,%edx
            !(pp = page_alloc(ALLOC_ZERO)) ||
f0100df2:	85 ff                	test   %edi,%edi
f0100df4:	74 43                	je     f0100e39 <pgdir_walk+0xdf>
            !(pgtable = (pte_t *)page2kva(pp)))
        {
            return NULL;
        }

        pp->pp_ref++;
f0100df6:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100dfb:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0100e01:	77 15                	ja     f0100e18 <pgdir_walk+0xbe>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e03:	57                   	push   %edi
f0100e04:	68 e8 5b 10 f0       	push   $0xf0105be8
f0100e09:	68 f3 01 00 00       	push   $0x1f3
f0100e0e:	68 f7 66 10 f0       	push   $0xf01066f7
f0100e13:	e8 28 f2 ff ff       	call   f0100040 <_panic>
        *pde = PADDR(pgtable) | PTE_P | PTE_W | PTE_U;
f0100e18:	83 c9 07             	or     $0x7,%ecx
f0100e1b:	89 0e                	mov    %ecx,(%esi)
    }

	return &pgtable[PTX(va)];
f0100e1d:	c1 eb 0a             	shr    $0xa,%ebx
f0100e20:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0100e26:	8d 04 1a             	lea    (%edx,%ebx,1),%eax
f0100e29:	eb 13                	jmp    f0100e3e <pgdir_walk+0xe4>
    {
        if(!create ||
            !(pp = page_alloc(ALLOC_ZERO)) ||
            !(pgtable = (pte_t *)page2kva(pp)))
        {
            return NULL;
f0100e2b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e30:	eb 0c                	jmp    f0100e3e <pgdir_walk+0xe4>
f0100e32:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e37:	eb 05                	jmp    f0100e3e <pgdir_walk+0xe4>
f0100e39:	b8 00 00 00 00       	mov    $0x0,%eax
        pp->pp_ref++;
        *pde = PADDR(pgtable) | PTE_P | PTE_W | PTE_U;
    }

	return &pgtable[PTX(va)];
}
f0100e3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e41:	5b                   	pop    %ebx
f0100e42:	5e                   	pop    %esi
f0100e43:	5f                   	pop    %edi
f0100e44:	5d                   	pop    %ebp
f0100e45:	c3                   	ret    

f0100e46 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100e46:	55                   	push   %ebp
f0100e47:	89 e5                	mov    %esp,%ebp
f0100e49:	83 ec 0c             	sub    $0xc,%esp
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);
f0100e4c:	6a 00                	push   $0x0
f0100e4e:	ff 75 0c             	pushl  0xc(%ebp)
f0100e51:	ff 75 08             	pushl  0x8(%ebp)
f0100e54:	e8 01 ff ff ff       	call   f0100d5a <pgdir_walk>

    if(!pte)
f0100e59:	83 c4 10             	add    $0x10,%esp
f0100e5c:	85 c0                	test   %eax,%eax
f0100e5e:	74 31                	je     f0100e91 <page_lookup+0x4b>
    {
        return NULL;
    }

    *pte_store = pte;
f0100e60:	8b 55 10             	mov    0x10(%ebp),%edx
f0100e63:	89 02                	mov    %eax,(%edx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e65:	8b 00                	mov    (%eax),%eax
f0100e67:	c1 e8 0c             	shr    $0xc,%eax
f0100e6a:	3b 05 28 9f 23 f0    	cmp    0xf0239f28,%eax
f0100e70:	72 14                	jb     f0100e86 <page_lookup+0x40>
		panic("pa2page called with invalid pa");
f0100e72:	83 ec 04             	sub    $0x4,%esp
f0100e75:	68 1c 61 10 f0       	push   $0xf010611c
f0100e7a:	6a 51                	push   $0x51
f0100e7c:	68 e9 66 10 f0       	push   $0xf01066e9
f0100e81:	e8 ba f1 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0100e86:	8b 15 30 9f 23 f0    	mov    0xf0239f30,%edx
f0100e8c:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	return pa2page(PTE_ADDR(*pte));
f0100e8f:	eb 05                	jmp    f0100e96 <page_lookup+0x50>
	// Fill this function in
    pte_t * pte = pgdir_walk(pgdir, va, 0);

    if(!pte)
    {
        return NULL;
f0100e91:	b8 00 00 00 00       	mov    $0x0,%eax
    }

    *pte_store = pte;

	return pa2page(PTE_ADDR(*pte));
}
f0100e96:	c9                   	leave  
f0100e97:	c3                   	ret    

f0100e98 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100e98:	55                   	push   %ebp
f0100e99:	89 e5                	mov    %esp,%ebp
f0100e9b:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0100e9e:	e8 5f 46 00 00       	call   f0105502 <cpunum>
f0100ea3:	6b c0 74             	imul   $0x74,%eax,%eax
f0100ea6:	83 b8 28 a0 23 f0 00 	cmpl   $0x0,-0xfdc5fd8(%eax)
f0100ead:	74 16                	je     f0100ec5 <tlb_invalidate+0x2d>
f0100eaf:	e8 4e 46 00 00       	call   f0105502 <cpunum>
f0100eb4:	6b c0 74             	imul   $0x74,%eax,%eax
f0100eb7:	8b 80 28 a0 23 f0    	mov    -0xfdc5fd8(%eax),%eax
f0100ebd:	8b 55 08             	mov    0x8(%ebp),%edx
f0100ec0:	39 50 60             	cmp    %edx,0x60(%eax)
f0100ec3:	75 06                	jne    f0100ecb <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100ec5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100ec8:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0100ecb:	c9                   	leave  
f0100ecc:	c3                   	ret    

f0100ecd <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100ecd:	55                   	push   %ebp
f0100ece:	89 e5                	mov    %esp,%ebp
f0100ed0:	56                   	push   %esi
f0100ed1:	53                   	push   %ebx
f0100ed2:	83 ec 14             	sub    $0x14,%esp
f0100ed5:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0100ed8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
    pte_t *pte = pgdir_walk(pgdir, va, 0);
f0100edb:	6a 00                	push   $0x0
f0100edd:	56                   	push   %esi
f0100ede:	53                   	push   %ebx
f0100edf:	e8 76 fe ff ff       	call   f0100d5a <pgdir_walk>
f0100ee4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    pte_t ** pte_store = &pte;

    struct PageInfo *pp = page_lookup(pgdir, va, pte_store);
f0100ee7:	83 c4 0c             	add    $0xc,%esp
f0100eea:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100eed:	50                   	push   %eax
f0100eee:	56                   	push   %esi
f0100eef:	53                   	push   %ebx
f0100ef0:	e8 51 ff ff ff       	call   f0100e46 <page_lookup>

    if(!pp)
f0100ef5:	83 c4 10             	add    $0x10,%esp
f0100ef8:	85 c0                	test   %eax,%eax
f0100efa:	74 1f                	je     f0100f1b <page_remove+0x4e>
    {
        return ;
    }

    page_decref(pp);
f0100efc:	83 ec 0c             	sub    $0xc,%esp
f0100eff:	50                   	push   %eax
f0100f00:	e8 2e fe ff ff       	call   f0100d33 <page_decref>
    **pte_store = 0;
f0100f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100f08:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tlb_invalidate(pgdir, va);
f0100f0e:	83 c4 08             	add    $0x8,%esp
f0100f11:	56                   	push   %esi
f0100f12:	53                   	push   %ebx
f0100f13:	e8 80 ff ff ff       	call   f0100e98 <tlb_invalidate>
f0100f18:	83 c4 10             	add    $0x10,%esp
}
f0100f1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100f1e:	5b                   	pop    %ebx
f0100f1f:	5e                   	pop    %esi
f0100f20:	5d                   	pop    %ebp
f0100f21:	c3                   	ret    

f0100f22 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100f22:	55                   	push   %ebp
f0100f23:	89 e5                	mov    %esp,%ebp
f0100f25:	57                   	push   %edi
f0100f26:	56                   	push   %esi
f0100f27:	53                   	push   %ebx
f0100f28:	83 ec 10             	sub    $0x10,%esp
f0100f2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100f2e:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
    pte_t *pte = pgdir_walk(pgdir, va, 0);
f0100f31:	6a 00                	push   $0x0
f0100f33:	57                   	push   %edi
f0100f34:	ff 75 08             	pushl  0x8(%ebp)
f0100f37:	e8 1e fe ff ff       	call   f0100d5a <pgdir_walk>
    physaddr_t ppa = page2pa(pp);

    if(pte)
f0100f3c:	83 c4 10             	add    $0x10,%esp
f0100f3f:	85 c0                	test   %eax,%eax
f0100f41:	74 27                	je     f0100f6a <page_insert+0x48>
f0100f43:	89 c6                	mov    %eax,%esi
    {
        if(*pte & PTE_P)
f0100f45:	f6 00 01             	testb  $0x1,(%eax)
f0100f48:	74 0f                	je     f0100f59 <page_insert+0x37>
        {
            page_remove(pgdir, va);
f0100f4a:	83 ec 08             	sub    $0x8,%esp
f0100f4d:	57                   	push   %edi
f0100f4e:	ff 75 08             	pushl  0x8(%ebp)
f0100f51:	e8 77 ff ff ff       	call   f0100ecd <page_remove>
f0100f56:	83 c4 10             	add    $0x10,%esp
        }

        if(page_free_list == pp)
f0100f59:	3b 1d 58 92 23 f0    	cmp    0xf0239258,%ebx
f0100f5f:	75 20                	jne    f0100f81 <page_insert+0x5f>
        {
            page_free_list = page_free_list->pp_link;
f0100f61:	8b 03                	mov    (%ebx),%eax
f0100f63:	a3 58 92 23 f0       	mov    %eax,0xf0239258
f0100f68:	eb 17                	jmp    f0100f81 <page_insert+0x5f>
        }
    }
    else
    {
        pte = pgdir_walk(pgdir, va, 1);
f0100f6a:	83 ec 04             	sub    $0x4,%esp
f0100f6d:	6a 01                	push   $0x1
f0100f6f:	57                   	push   %edi
f0100f70:	ff 75 08             	pushl  0x8(%ebp)
f0100f73:	e8 e2 fd ff ff       	call   f0100d5a <pgdir_walk>
f0100f78:	89 c6                	mov    %eax,%esi
        if(!pte)
f0100f7a:	83 c4 10             	add    $0x10,%esp
f0100f7d:	85 c0                	test   %eax,%eax
f0100f7f:	74 33                	je     f0100fb4 <page_insert+0x92>
            return -E_NO_MEM;
        }

    }

    *pte = page2pa(pp) | PTE_P | perm;
f0100f81:	89 d8                	mov    %ebx,%eax
f0100f83:	2b 05 30 9f 23 f0    	sub    0xf0239f30,%eax
f0100f89:	c1 f8 03             	sar    $0x3,%eax
f0100f8c:	c1 e0 0c             	shl    $0xc,%eax
f0100f8f:	8b 55 14             	mov    0x14(%ebp),%edx
f0100f92:	83 ca 01             	or     $0x1,%edx
f0100f95:	09 d0                	or     %edx,%eax
f0100f97:	89 06                	mov    %eax,(%esi)

    pp->pp_ref++;
f0100f99:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
    tlb_invalidate(pgdir, va);
f0100f9e:	83 ec 08             	sub    $0x8,%esp
f0100fa1:	57                   	push   %edi
f0100fa2:	ff 75 08             	pushl  0x8(%ebp)
f0100fa5:	e8 ee fe ff ff       	call   f0100e98 <tlb_invalidate>
	return 0;
f0100faa:	83 c4 10             	add    $0x10,%esp
f0100fad:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fb2:	eb 05                	jmp    f0100fb9 <page_insert+0x97>
    else
    {
        pte = pgdir_walk(pgdir, va, 1);
        if(!pte)
        {
            return -E_NO_MEM;
f0100fb4:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
    *pte = page2pa(pp) | PTE_P | perm;

    pp->pp_ref++;
    tlb_invalidate(pgdir, va);
	return 0;
}
f0100fb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fbc:	5b                   	pop    %ebx
f0100fbd:	5e                   	pop    %esi
f0100fbe:	5f                   	pop    %edi
f0100fbf:	5d                   	pop    %ebp
f0100fc0:	c3                   	ret    

f0100fc1 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0100fc1:	55                   	push   %ebp
f0100fc2:	89 e5                	mov    %esp,%ebp
f0100fc4:	83 ec 0c             	sub    $0xc,%esp
	// Hint: The staff solution uses boot_map_region.
	//
	// Lab2 code here:


	panic("mmio_map_region not implemented");
f0100fc7:	68 3c 61 10 f0       	push   $0xf010613c
f0100fcc:	68 c9 02 00 00       	push   $0x2c9
f0100fd1:	68 f7 66 10 f0       	push   $0xf01066f7
f0100fd6:	e8 65 f0 ff ff       	call   f0100040 <_panic>

f0100fdb <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100fdb:	55                   	push   %ebp
f0100fdc:	89 e5                	mov    %esp,%ebp
f0100fde:	57                   	push   %edi
f0100fdf:	56                   	push   %esi
f0100fe0:	53                   	push   %ebx
f0100fe1:	83 ec 48             	sub    $0x48,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100fe4:	6a 15                	push   $0x15
f0100fe6:	e8 4e 1b 00 00       	call   f0102b39 <mc146818_read>
f0100feb:	89 c3                	mov    %eax,%ebx
f0100fed:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0100ff4:	e8 40 1b 00 00       	call   f0102b39 <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0100ff9:	c1 e0 08             	shl    $0x8,%eax
f0100ffc:	09 d8                	or     %ebx,%eax
f0100ffe:	c1 e0 0a             	shl    $0xa,%eax
f0101001:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101007:	85 c0                	test   %eax,%eax
f0101009:	0f 48 c2             	cmovs  %edx,%eax
f010100c:	c1 f8 0c             	sar    $0xc,%eax
f010100f:	a3 5c 92 23 f0       	mov    %eax,0xf023925c
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101014:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f010101b:	e8 19 1b 00 00       	call   f0102b39 <mc146818_read>
f0101020:	89 c3                	mov    %eax,%ebx
f0101022:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101029:	e8 0b 1b 00 00       	call   f0102b39 <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010102e:	c1 e0 08             	shl    $0x8,%eax
f0101031:	09 d8                	or     %ebx,%eax
f0101033:	c1 e0 0a             	shl    $0xa,%eax
f0101036:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010103c:	83 c4 10             	add    $0x10,%esp
f010103f:	85 c0                	test   %eax,%eax
f0101041:	0f 48 c2             	cmovs  %edx,%eax
f0101044:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101047:	85 c0                	test   %eax,%eax
f0101049:	74 0e                	je     f0101059 <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f010104b:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101051:	89 15 28 9f 23 f0    	mov    %edx,0xf0239f28
f0101057:	eb 0c                	jmp    f0101065 <mem_init+0x8a>
	else
		npages = npages_basemem;
f0101059:	8b 15 5c 92 23 f0    	mov    0xf023925c,%edx
f010105f:	89 15 28 9f 23 f0    	mov    %edx,0xf0239f28

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101065:	c1 e0 0c             	shl    $0xc,%eax
f0101068:	c1 e8 0a             	shr    $0xa,%eax
f010106b:	50                   	push   %eax
f010106c:	a1 5c 92 23 f0       	mov    0xf023925c,%eax
f0101071:	c1 e0 0c             	shl    $0xc,%eax
f0101074:	c1 e8 0a             	shr    $0xa,%eax
f0101077:	50                   	push   %eax
f0101078:	a1 28 9f 23 f0       	mov    0xf0239f28,%eax
f010107d:	c1 e0 0c             	shl    $0xc,%eax
f0101080:	c1 e8 0a             	shr    $0xa,%eax
f0101083:	50                   	push   %eax
f0101084:	68 5c 61 10 f0       	push   $0xf010615c
f0101089:	e8 2a 1c 00 00       	call   f0102cb8 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010108e:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101093:	e8 dc f9 ff ff       	call   f0100a74 <boot_alloc>
f0101098:	a3 2c 9f 23 f0       	mov    %eax,0xf0239f2c
	memset(kern_pgdir, 0, PGSIZE);
f010109d:	83 c4 0c             	add    $0xc,%esp
f01010a0:	68 00 10 00 00       	push   $0x1000
f01010a5:	6a 00                	push   $0x0
f01010a7:	50                   	push   %eax
f01010a8:	e8 33 3e 00 00       	call   f0104ee0 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01010ad:	a1 2c 9f 23 f0       	mov    0xf0239f2c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01010b2:	83 c4 10             	add    $0x10,%esp
f01010b5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01010ba:	77 15                	ja     f01010d1 <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01010bc:	50                   	push   %eax
f01010bd:	68 e8 5b 10 f0       	push   $0xf0105be8
f01010c2:	68 90 00 00 00       	push   $0x90
f01010c7:	68 f7 66 10 f0       	push   $0xf01066f7
f01010cc:	e8 6f ef ff ff       	call   f0100040 <_panic>
f01010d1:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01010d7:	83 ca 05             	or     $0x5,%edx
f01010da:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

    pages = (struct PageInfo*)boot_alloc(ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE));
f01010e0:	a1 28 9f 23 f0       	mov    0xf0239f28,%eax
f01010e5:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01010ec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01010f1:	e8 7e f9 ff ff       	call   f0100a74 <boot_alloc>
f01010f6:	a3 30 9f 23 f0       	mov    %eax,0xf0239f30

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

    envs = (struct Env*)boot_alloc(ROUNDUP(NENV * sizeof(struct Env), PGSIZE));
f01010fb:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101100:	e8 6f f9 ff ff       	call   f0100a74 <boot_alloc>
f0101105:	a3 60 92 23 f0       	mov    %eax,0xf0239260
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010110a:	e8 38 fa ff ff       	call   f0100b47 <page_init>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f010110f:	a1 58 92 23 f0       	mov    0xf0239258,%eax
f0101114:	85 c0                	test   %eax,%eax
f0101116:	75 17                	jne    f010112f <mem_init+0x154>
		panic("'page_free_list' is a null pointer!");
f0101118:	83 ec 04             	sub    $0x4,%esp
f010111b:	68 98 61 10 f0       	push   $0xf0106198
f0101120:	68 32 03 00 00       	push   $0x332
f0101125:	68 f7 66 10 f0       	push   $0xf01066f7
f010112a:	e8 11 ef ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f010112f:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0101132:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101135:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0101138:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f010113b:	89 c2                	mov    %eax,%edx
f010113d:	2b 15 30 9f 23 f0    	sub    0xf0239f30,%edx
f0101143:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0101149:	0f 95 c2             	setne  %dl
f010114c:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f010114f:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0101153:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0101155:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101159:	8b 00                	mov    (%eax),%eax
f010115b:	85 c0                	test   %eax,%eax
f010115d:	75 dc                	jne    f010113b <mem_init+0x160>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f010115f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101162:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101168:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010116b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010116e:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101170:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0101173:	89 1d 58 92 23 f0    	mov    %ebx,0xf0239258
f0101179:	eb 54                	jmp    f01011cf <mem_init+0x1f4>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010117b:	89 d8                	mov    %ebx,%eax
f010117d:	2b 05 30 9f 23 f0    	sub    0xf0239f30,%eax
f0101183:	c1 f8 03             	sar    $0x3,%eax
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
f0101186:	89 c2                	mov    %eax,%edx
f0101188:	c1 e2 0c             	shl    $0xc,%edx
f010118b:	a9 00 fc 0f 00       	test   $0xffc00,%eax
f0101190:	75 3b                	jne    f01011cd <mem_init+0x1f2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101192:	89 d0                	mov    %edx,%eax
f0101194:	c1 e8 0c             	shr    $0xc,%eax
f0101197:	3b 05 28 9f 23 f0    	cmp    0xf0239f28,%eax
f010119d:	72 12                	jb     f01011b1 <mem_init+0x1d6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010119f:	52                   	push   %edx
f01011a0:	68 c4 5b 10 f0       	push   $0xf0105bc4
f01011a5:	6a 58                	push   $0x58
f01011a7:	68 e9 66 10 f0       	push   $0xf01066e9
f01011ac:	e8 8f ee ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f01011b1:	83 ec 04             	sub    $0x4,%esp
f01011b4:	68 80 00 00 00       	push   $0x80
f01011b9:	68 97 00 00 00       	push   $0x97
f01011be:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01011c4:	52                   	push   %edx
f01011c5:	e8 16 3d 00 00       	call   f0104ee0 <memset>
f01011ca:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01011cd:	8b 1b                	mov    (%ebx),%ebx
f01011cf:	85 db                	test   %ebx,%ebx
f01011d1:	75 a8                	jne    f010117b <mem_init+0x1a0>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f01011d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01011d8:	e8 97 f8 ff ff       	call   f0100a74 <boot_alloc>
f01011dd:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01011e0:	a1 58 92 23 f0       	mov    0xf0239258,%eax
f01011e5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01011e8:	8b 0d 30 9f 23 f0    	mov    0xf0239f30,%ecx
		assert(pp < pages + npages);
f01011ee:	8b 35 28 9f 23 f0    	mov    0xf0239f28,%esi
f01011f4:	89 75 c8             	mov    %esi,-0x38(%ebp)
f01011f7:	8d 1c f1             	lea    (%ecx,%esi,8),%ebx
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01011fa:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01011fd:	89 c2                	mov    %eax,%edx
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f01011ff:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f0101206:	be 00 00 00 00       	mov    $0x0,%esi
f010120b:	e9 52 01 00 00       	jmp    f0101362 <mem_init+0x387>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101210:	39 d1                	cmp    %edx,%ecx
f0101212:	76 19                	jbe    f010122d <mem_init+0x252>
f0101214:	68 2b 67 10 f0       	push   $0xf010672b
f0101219:	68 16 67 10 f0       	push   $0xf0106716
f010121e:	68 4c 03 00 00       	push   $0x34c
f0101223:	68 f7 66 10 f0       	push   $0xf01066f7
f0101228:	e8 13 ee ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f010122d:	39 da                	cmp    %ebx,%edx
f010122f:	72 19                	jb     f010124a <mem_init+0x26f>
f0101231:	68 37 67 10 f0       	push   $0xf0106737
f0101236:	68 16 67 10 f0       	push   $0xf0106716
f010123b:	68 4d 03 00 00       	push   $0x34d
f0101240:	68 f7 66 10 f0       	push   $0xf01066f7
f0101245:	e8 f6 ed ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010124a:	89 d0                	mov    %edx,%eax
f010124c:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f010124f:	a8 07                	test   $0x7,%al
f0101251:	74 19                	je     f010126c <mem_init+0x291>
f0101253:	68 bc 61 10 f0       	push   $0xf01061bc
f0101258:	68 16 67 10 f0       	push   $0xf0106716
f010125d:	68 4e 03 00 00       	push   $0x34e
f0101262:	68 f7 66 10 f0       	push   $0xf01066f7
f0101267:	e8 d4 ed ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010126c:	c1 f8 03             	sar    $0x3,%eax
f010126f:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101272:	85 c0                	test   %eax,%eax
f0101274:	75 19                	jne    f010128f <mem_init+0x2b4>
f0101276:	68 4b 67 10 f0       	push   $0xf010674b
f010127b:	68 16 67 10 f0       	push   $0xf0106716
f0101280:	68 51 03 00 00       	push   $0x351
f0101285:	68 f7 66 10 f0       	push   $0xf01066f7
f010128a:	e8 b1 ed ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f010128f:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101294:	75 19                	jne    f01012af <mem_init+0x2d4>
f0101296:	68 5c 67 10 f0       	push   $0xf010675c
f010129b:	68 16 67 10 f0       	push   $0xf0106716
f01012a0:	68 52 03 00 00       	push   $0x352
f01012a5:	68 f7 66 10 f0       	push   $0xf01066f7
f01012aa:	e8 91 ed ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01012af:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01012b4:	75 19                	jne    f01012cf <mem_init+0x2f4>
f01012b6:	68 f0 61 10 f0       	push   $0xf01061f0
f01012bb:	68 16 67 10 f0       	push   $0xf0106716
f01012c0:	68 53 03 00 00       	push   $0x353
f01012c5:	68 f7 66 10 f0       	push   $0xf01066f7
f01012ca:	e8 71 ed ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f01012cf:	3d 00 00 10 00       	cmp    $0x100000,%eax
f01012d4:	75 19                	jne    f01012ef <mem_init+0x314>
f01012d6:	68 75 67 10 f0       	push   $0xf0106775
f01012db:	68 16 67 10 f0       	push   $0xf0106716
f01012e0:	68 54 03 00 00       	push   $0x354
f01012e5:	68 f7 66 10 f0       	push   $0xf01066f7
f01012ea:	e8 51 ed ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01012ef:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f01012f4:	0f 86 62 0f 00 00    	jbe    f010225c <mem_init+0x1281>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012fa:	89 c7                	mov    %eax,%edi
f01012fc:	c1 ef 0c             	shr    $0xc,%edi
f01012ff:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0101302:	77 12                	ja     f0101316 <mem_init+0x33b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101304:	50                   	push   %eax
f0101305:	68 c4 5b 10 f0       	push   $0xf0105bc4
f010130a:	6a 58                	push   $0x58
f010130c:	68 e9 66 10 f0       	push   $0xf01066e9
f0101311:	e8 2a ed ff ff       	call   f0100040 <_panic>
f0101316:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f010131c:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f010131f:	0f 86 47 0f 00 00    	jbe    f010226c <mem_init+0x1291>
f0101325:	68 14 62 10 f0       	push   $0xf0106214
f010132a:	68 16 67 10 f0       	push   $0xf0106716
f010132f:	68 55 03 00 00       	push   $0x355
f0101334:	68 f7 66 10 f0       	push   $0xf01066f7
f0101339:	e8 02 ed ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f010133e:	68 8f 67 10 f0       	push   $0xf010678f
f0101343:	68 16 67 10 f0       	push   $0xf0106716
f0101348:	68 57 03 00 00       	push   $0x357
f010134d:	68 f7 66 10 f0       	push   $0xf01066f7
f0101352:	e8 e9 ec ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0101357:	83 c6 01             	add    $0x1,%esi
f010135a:	eb 04                	jmp    f0101360 <mem_init+0x385>
		else
			++nfree_extmem;
f010135c:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101360:	8b 12                	mov    (%edx),%edx
f0101362:	85 d2                	test   %edx,%edx
f0101364:	0f 85 a6 fe ff ff    	jne    f0101210 <mem_init+0x235>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f010136a:	85 f6                	test   %esi,%esi
f010136c:	7f 19                	jg     f0101387 <mem_init+0x3ac>
f010136e:	68 ac 67 10 f0       	push   $0xf01067ac
f0101373:	68 16 67 10 f0       	push   $0xf0106716
f0101378:	68 5f 03 00 00       	push   $0x35f
f010137d:	68 f7 66 10 f0       	push   $0xf01066f7
f0101382:	e8 b9 ec ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0101387:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f010138b:	7f 19                	jg     f01013a6 <mem_init+0x3cb>
f010138d:	68 be 67 10 f0       	push   $0xf01067be
f0101392:	68 16 67 10 f0       	push   $0xf0106716
f0101397:	68 60 03 00 00       	push   $0x360
f010139c:	68 f7 66 10 f0       	push   $0xf01066f7
f01013a1:	e8 9a ec ff ff       	call   f0100040 <_panic>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01013a6:	bb 00 00 00 00       	mov    $0x0,%ebx
f01013ab:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01013ae:	85 c9                	test   %ecx,%ecx
f01013b0:	75 1e                	jne    f01013d0 <mem_init+0x3f5>
		panic("'pages' is a null pointer!");
f01013b2:	83 ec 04             	sub    $0x4,%esp
f01013b5:	68 cf 67 10 f0       	push   $0xf01067cf
f01013ba:	68 71 03 00 00       	push   $0x371
f01013bf:	68 f7 66 10 f0       	push   $0xf01066f7
f01013c4:	e8 77 ec ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
		++nfree;
f01013c9:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013cc:	8b 00                	mov    (%eax),%eax
f01013ce:	eb 00                	jmp    f01013d0 <mem_init+0x3f5>
f01013d0:	85 c0                	test   %eax,%eax
f01013d2:	75 f5                	jne    f01013c9 <mem_init+0x3ee>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01013d4:	83 ec 0c             	sub    $0xc,%esp
f01013d7:	6a 00                	push   $0x0
f01013d9:	e8 ae f8 ff ff       	call   f0100c8c <page_alloc>
f01013de:	89 c7                	mov    %eax,%edi
f01013e0:	83 c4 10             	add    $0x10,%esp
f01013e3:	85 c0                	test   %eax,%eax
f01013e5:	75 19                	jne    f0101400 <mem_init+0x425>
f01013e7:	68 ea 67 10 f0       	push   $0xf01067ea
f01013ec:	68 16 67 10 f0       	push   $0xf0106716
f01013f1:	68 79 03 00 00       	push   $0x379
f01013f6:	68 f7 66 10 f0       	push   $0xf01066f7
f01013fb:	e8 40 ec ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101400:	83 ec 0c             	sub    $0xc,%esp
f0101403:	6a 00                	push   $0x0
f0101405:	e8 82 f8 ff ff       	call   f0100c8c <page_alloc>
f010140a:	89 c6                	mov    %eax,%esi
f010140c:	83 c4 10             	add    $0x10,%esp
f010140f:	85 c0                	test   %eax,%eax
f0101411:	75 19                	jne    f010142c <mem_init+0x451>
f0101413:	68 00 68 10 f0       	push   $0xf0106800
f0101418:	68 16 67 10 f0       	push   $0xf0106716
f010141d:	68 7a 03 00 00       	push   $0x37a
f0101422:	68 f7 66 10 f0       	push   $0xf01066f7
f0101427:	e8 14 ec ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010142c:	83 ec 0c             	sub    $0xc,%esp
f010142f:	6a 00                	push   $0x0
f0101431:	e8 56 f8 ff ff       	call   f0100c8c <page_alloc>
f0101436:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101439:	83 c4 10             	add    $0x10,%esp
f010143c:	85 c0                	test   %eax,%eax
f010143e:	75 19                	jne    f0101459 <mem_init+0x47e>
f0101440:	68 16 68 10 f0       	push   $0xf0106816
f0101445:	68 16 67 10 f0       	push   $0xf0106716
f010144a:	68 7b 03 00 00       	push   $0x37b
f010144f:	68 f7 66 10 f0       	push   $0xf01066f7
f0101454:	e8 e7 eb ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101459:	39 f7                	cmp    %esi,%edi
f010145b:	75 19                	jne    f0101476 <mem_init+0x49b>
f010145d:	68 2c 68 10 f0       	push   $0xf010682c
f0101462:	68 16 67 10 f0       	push   $0xf0106716
f0101467:	68 7e 03 00 00       	push   $0x37e
f010146c:	68 f7 66 10 f0       	push   $0xf01066f7
f0101471:	e8 ca eb ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101476:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101479:	39 c6                	cmp    %eax,%esi
f010147b:	74 04                	je     f0101481 <mem_init+0x4a6>
f010147d:	39 c7                	cmp    %eax,%edi
f010147f:	75 19                	jne    f010149a <mem_init+0x4bf>
f0101481:	68 5c 62 10 f0       	push   $0xf010625c
f0101486:	68 16 67 10 f0       	push   $0xf0106716
f010148b:	68 7f 03 00 00       	push   $0x37f
f0101490:	68 f7 66 10 f0       	push   $0xf01066f7
f0101495:	e8 a6 eb ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010149a:	8b 0d 30 9f 23 f0    	mov    0xf0239f30,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01014a0:	8b 15 28 9f 23 f0    	mov    0xf0239f28,%edx
f01014a6:	c1 e2 0c             	shl    $0xc,%edx
f01014a9:	89 f8                	mov    %edi,%eax
f01014ab:	29 c8                	sub    %ecx,%eax
f01014ad:	c1 f8 03             	sar    $0x3,%eax
f01014b0:	c1 e0 0c             	shl    $0xc,%eax
f01014b3:	39 d0                	cmp    %edx,%eax
f01014b5:	72 19                	jb     f01014d0 <mem_init+0x4f5>
f01014b7:	68 3e 68 10 f0       	push   $0xf010683e
f01014bc:	68 16 67 10 f0       	push   $0xf0106716
f01014c1:	68 80 03 00 00       	push   $0x380
f01014c6:	68 f7 66 10 f0       	push   $0xf01066f7
f01014cb:	e8 70 eb ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01014d0:	89 f0                	mov    %esi,%eax
f01014d2:	29 c8                	sub    %ecx,%eax
f01014d4:	c1 f8 03             	sar    $0x3,%eax
f01014d7:	c1 e0 0c             	shl    $0xc,%eax
f01014da:	39 c2                	cmp    %eax,%edx
f01014dc:	77 19                	ja     f01014f7 <mem_init+0x51c>
f01014de:	68 5b 68 10 f0       	push   $0xf010685b
f01014e3:	68 16 67 10 f0       	push   $0xf0106716
f01014e8:	68 81 03 00 00       	push   $0x381
f01014ed:	68 f7 66 10 f0       	push   $0xf01066f7
f01014f2:	e8 49 eb ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01014f7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014fa:	29 c8                	sub    %ecx,%eax
f01014fc:	c1 f8 03             	sar    $0x3,%eax
f01014ff:	c1 e0 0c             	shl    $0xc,%eax
f0101502:	39 c2                	cmp    %eax,%edx
f0101504:	77 19                	ja     f010151f <mem_init+0x544>
f0101506:	68 78 68 10 f0       	push   $0xf0106878
f010150b:	68 16 67 10 f0       	push   $0xf0106716
f0101510:	68 82 03 00 00       	push   $0x382
f0101515:	68 f7 66 10 f0       	push   $0xf01066f7
f010151a:	e8 21 eb ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010151f:	a1 58 92 23 f0       	mov    0xf0239258,%eax
f0101524:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101527:	c7 05 58 92 23 f0 00 	movl   $0x0,0xf0239258
f010152e:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101531:	83 ec 0c             	sub    $0xc,%esp
f0101534:	6a 00                	push   $0x0
f0101536:	e8 51 f7 ff ff       	call   f0100c8c <page_alloc>
f010153b:	83 c4 10             	add    $0x10,%esp
f010153e:	85 c0                	test   %eax,%eax
f0101540:	74 19                	je     f010155b <mem_init+0x580>
f0101542:	68 95 68 10 f0       	push   $0xf0106895
f0101547:	68 16 67 10 f0       	push   $0xf0106716
f010154c:	68 89 03 00 00       	push   $0x389
f0101551:	68 f7 66 10 f0       	push   $0xf01066f7
f0101556:	e8 e5 ea ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f010155b:	83 ec 0c             	sub    $0xc,%esp
f010155e:	57                   	push   %edi
f010155f:	e8 92 f7 ff ff       	call   f0100cf6 <page_free>
	page_free(pp1);
f0101564:	89 34 24             	mov    %esi,(%esp)
f0101567:	e8 8a f7 ff ff       	call   f0100cf6 <page_free>
	page_free(pp2);
f010156c:	83 c4 04             	add    $0x4,%esp
f010156f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101572:	e8 7f f7 ff ff       	call   f0100cf6 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101577:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010157e:	e8 09 f7 ff ff       	call   f0100c8c <page_alloc>
f0101583:	89 c6                	mov    %eax,%esi
f0101585:	83 c4 10             	add    $0x10,%esp
f0101588:	85 c0                	test   %eax,%eax
f010158a:	75 19                	jne    f01015a5 <mem_init+0x5ca>
f010158c:	68 ea 67 10 f0       	push   $0xf01067ea
f0101591:	68 16 67 10 f0       	push   $0xf0106716
f0101596:	68 90 03 00 00       	push   $0x390
f010159b:	68 f7 66 10 f0       	push   $0xf01066f7
f01015a0:	e8 9b ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01015a5:	83 ec 0c             	sub    $0xc,%esp
f01015a8:	6a 00                	push   $0x0
f01015aa:	e8 dd f6 ff ff       	call   f0100c8c <page_alloc>
f01015af:	89 c7                	mov    %eax,%edi
f01015b1:	83 c4 10             	add    $0x10,%esp
f01015b4:	85 c0                	test   %eax,%eax
f01015b6:	75 19                	jne    f01015d1 <mem_init+0x5f6>
f01015b8:	68 00 68 10 f0       	push   $0xf0106800
f01015bd:	68 16 67 10 f0       	push   $0xf0106716
f01015c2:	68 91 03 00 00       	push   $0x391
f01015c7:	68 f7 66 10 f0       	push   $0xf01066f7
f01015cc:	e8 6f ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01015d1:	83 ec 0c             	sub    $0xc,%esp
f01015d4:	6a 00                	push   $0x0
f01015d6:	e8 b1 f6 ff ff       	call   f0100c8c <page_alloc>
f01015db:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015de:	83 c4 10             	add    $0x10,%esp
f01015e1:	85 c0                	test   %eax,%eax
f01015e3:	75 19                	jne    f01015fe <mem_init+0x623>
f01015e5:	68 16 68 10 f0       	push   $0xf0106816
f01015ea:	68 16 67 10 f0       	push   $0xf0106716
f01015ef:	68 92 03 00 00       	push   $0x392
f01015f4:	68 f7 66 10 f0       	push   $0xf01066f7
f01015f9:	e8 42 ea ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01015fe:	39 fe                	cmp    %edi,%esi
f0101600:	75 19                	jne    f010161b <mem_init+0x640>
f0101602:	68 2c 68 10 f0       	push   $0xf010682c
f0101607:	68 16 67 10 f0       	push   $0xf0106716
f010160c:	68 94 03 00 00       	push   $0x394
f0101611:	68 f7 66 10 f0       	push   $0xf01066f7
f0101616:	e8 25 ea ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010161b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010161e:	39 c7                	cmp    %eax,%edi
f0101620:	74 04                	je     f0101626 <mem_init+0x64b>
f0101622:	39 c6                	cmp    %eax,%esi
f0101624:	75 19                	jne    f010163f <mem_init+0x664>
f0101626:	68 5c 62 10 f0       	push   $0xf010625c
f010162b:	68 16 67 10 f0       	push   $0xf0106716
f0101630:	68 95 03 00 00       	push   $0x395
f0101635:	68 f7 66 10 f0       	push   $0xf01066f7
f010163a:	e8 01 ea ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010163f:	83 ec 0c             	sub    $0xc,%esp
f0101642:	6a 00                	push   $0x0
f0101644:	e8 43 f6 ff ff       	call   f0100c8c <page_alloc>
f0101649:	83 c4 10             	add    $0x10,%esp
f010164c:	85 c0                	test   %eax,%eax
f010164e:	74 19                	je     f0101669 <mem_init+0x68e>
f0101650:	68 95 68 10 f0       	push   $0xf0106895
f0101655:	68 16 67 10 f0       	push   $0xf0106716
f010165a:	68 96 03 00 00       	push   $0x396
f010165f:	68 f7 66 10 f0       	push   $0xf01066f7
f0101664:	e8 d7 e9 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101669:	89 f0                	mov    %esi,%eax
f010166b:	e8 3c f4 ff ff       	call   f0100aac <page2kva>
f0101670:	83 ec 04             	sub    $0x4,%esp
f0101673:	68 00 10 00 00       	push   $0x1000
f0101678:	6a 01                	push   $0x1
f010167a:	50                   	push   %eax
f010167b:	e8 60 38 00 00       	call   f0104ee0 <memset>
	page_free(pp0);
f0101680:	89 34 24             	mov    %esi,(%esp)
f0101683:	e8 6e f6 ff ff       	call   f0100cf6 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101688:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010168f:	e8 f8 f5 ff ff       	call   f0100c8c <page_alloc>
f0101694:	83 c4 10             	add    $0x10,%esp
f0101697:	85 c0                	test   %eax,%eax
f0101699:	75 19                	jne    f01016b4 <mem_init+0x6d9>
f010169b:	68 a4 68 10 f0       	push   $0xf01068a4
f01016a0:	68 16 67 10 f0       	push   $0xf0106716
f01016a5:	68 9b 03 00 00       	push   $0x39b
f01016aa:	68 f7 66 10 f0       	push   $0xf01066f7
f01016af:	e8 8c e9 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01016b4:	39 c6                	cmp    %eax,%esi
f01016b6:	74 19                	je     f01016d1 <mem_init+0x6f6>
f01016b8:	68 c2 68 10 f0       	push   $0xf01068c2
f01016bd:	68 16 67 10 f0       	push   $0xf0106716
f01016c2:	68 9c 03 00 00       	push   $0x39c
f01016c7:	68 f7 66 10 f0       	push   $0xf01066f7
f01016cc:	e8 6f e9 ff ff       	call   f0100040 <_panic>
	c = page2kva(pp);
f01016d1:	89 f0                	mov    %esi,%eax
f01016d3:	e8 d4 f3 ff ff       	call   f0100aac <page2kva>
f01016d8:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01016de:	80 38 00             	cmpb   $0x0,(%eax)
f01016e1:	74 19                	je     f01016fc <mem_init+0x721>
f01016e3:	68 d2 68 10 f0       	push   $0xf01068d2
f01016e8:	68 16 67 10 f0       	push   $0xf0106716
f01016ed:	68 9f 03 00 00       	push   $0x39f
f01016f2:	68 f7 66 10 f0       	push   $0xf01066f7
f01016f7:	e8 44 e9 ff ff       	call   f0100040 <_panic>
f01016fc:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01016ff:	39 d0                	cmp    %edx,%eax
f0101701:	75 db                	jne    f01016de <mem_init+0x703>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101703:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101706:	a3 58 92 23 f0       	mov    %eax,0xf0239258

	// free the pages we took
	page_free(pp0);
f010170b:	83 ec 0c             	sub    $0xc,%esp
f010170e:	56                   	push   %esi
f010170f:	e8 e2 f5 ff ff       	call   f0100cf6 <page_free>
	page_free(pp1);
f0101714:	89 3c 24             	mov    %edi,(%esp)
f0101717:	e8 da f5 ff ff       	call   f0100cf6 <page_free>
	page_free(pp2);
f010171c:	83 c4 04             	add    $0x4,%esp
f010171f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101722:	e8 cf f5 ff ff       	call   f0100cf6 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101727:	a1 58 92 23 f0       	mov    0xf0239258,%eax
f010172c:	83 c4 10             	add    $0x10,%esp
f010172f:	eb 05                	jmp    f0101736 <mem_init+0x75b>
		--nfree;
f0101731:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101734:	8b 00                	mov    (%eax),%eax
f0101736:	85 c0                	test   %eax,%eax
f0101738:	75 f7                	jne    f0101731 <mem_init+0x756>
		--nfree;
	assert(nfree == 0);
f010173a:	85 db                	test   %ebx,%ebx
f010173c:	74 19                	je     f0101757 <mem_init+0x77c>
f010173e:	68 dc 68 10 f0       	push   $0xf01068dc
f0101743:	68 16 67 10 f0       	push   $0xf0106716
f0101748:	68 ac 03 00 00       	push   $0x3ac
f010174d:	68 f7 66 10 f0       	push   $0xf01066f7
f0101752:	e8 e9 e8 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101757:	83 ec 0c             	sub    $0xc,%esp
f010175a:	68 7c 62 10 f0       	push   $0xf010627c
f010175f:	e8 54 15 00 00       	call   f0102cb8 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101764:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010176b:	e8 1c f5 ff ff       	call   f0100c8c <page_alloc>
f0101770:	89 c3                	mov    %eax,%ebx
f0101772:	83 c4 10             	add    $0x10,%esp
f0101775:	85 c0                	test   %eax,%eax
f0101777:	75 19                	jne    f0101792 <mem_init+0x7b7>
f0101779:	68 ea 67 10 f0       	push   $0xf01067ea
f010177e:	68 16 67 10 f0       	push   $0xf0106716
f0101783:	68 12 04 00 00       	push   $0x412
f0101788:	68 f7 66 10 f0       	push   $0xf01066f7
f010178d:	e8 ae e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101792:	83 ec 0c             	sub    $0xc,%esp
f0101795:	6a 00                	push   $0x0
f0101797:	e8 f0 f4 ff ff       	call   f0100c8c <page_alloc>
f010179c:	89 c6                	mov    %eax,%esi
f010179e:	83 c4 10             	add    $0x10,%esp
f01017a1:	85 c0                	test   %eax,%eax
f01017a3:	75 19                	jne    f01017be <mem_init+0x7e3>
f01017a5:	68 00 68 10 f0       	push   $0xf0106800
f01017aa:	68 16 67 10 f0       	push   $0xf0106716
f01017af:	68 13 04 00 00       	push   $0x413
f01017b4:	68 f7 66 10 f0       	push   $0xf01066f7
f01017b9:	e8 82 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01017be:	83 ec 0c             	sub    $0xc,%esp
f01017c1:	6a 00                	push   $0x0
f01017c3:	e8 c4 f4 ff ff       	call   f0100c8c <page_alloc>
f01017c8:	89 c7                	mov    %eax,%edi
f01017ca:	83 c4 10             	add    $0x10,%esp
f01017cd:	85 c0                	test   %eax,%eax
f01017cf:	75 19                	jne    f01017ea <mem_init+0x80f>
f01017d1:	68 16 68 10 f0       	push   $0xf0106816
f01017d6:	68 16 67 10 f0       	push   $0xf0106716
f01017db:	68 14 04 00 00       	push   $0x414
f01017e0:	68 f7 66 10 f0       	push   $0xf01066f7
f01017e5:	e8 56 e8 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01017ea:	39 f3                	cmp    %esi,%ebx
f01017ec:	75 19                	jne    f0101807 <mem_init+0x82c>
f01017ee:	68 2c 68 10 f0       	push   $0xf010682c
f01017f3:	68 16 67 10 f0       	push   $0xf0106716
f01017f8:	68 17 04 00 00       	push   $0x417
f01017fd:	68 f7 66 10 f0       	push   $0xf01066f7
f0101802:	e8 39 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101807:	39 c6                	cmp    %eax,%esi
f0101809:	74 04                	je     f010180f <mem_init+0x834>
f010180b:	39 c3                	cmp    %eax,%ebx
f010180d:	75 19                	jne    f0101828 <mem_init+0x84d>
f010180f:	68 5c 62 10 f0       	push   $0xf010625c
f0101814:	68 16 67 10 f0       	push   $0xf0106716
f0101819:	68 18 04 00 00       	push   $0x418
f010181e:	68 f7 66 10 f0       	push   $0xf01066f7
f0101823:	e8 18 e8 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101828:	a1 58 92 23 f0       	mov    0xf0239258,%eax
f010182d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	page_free_list = 0;
f0101830:	c7 05 58 92 23 f0 00 	movl   $0x0,0xf0239258
f0101837:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010183a:	83 ec 0c             	sub    $0xc,%esp
f010183d:	6a 00                	push   $0x0
f010183f:	e8 48 f4 ff ff       	call   f0100c8c <page_alloc>
f0101844:	83 c4 10             	add    $0x10,%esp
f0101847:	85 c0                	test   %eax,%eax
f0101849:	74 19                	je     f0101864 <mem_init+0x889>
f010184b:	68 95 68 10 f0       	push   $0xf0106895
f0101850:	68 16 67 10 f0       	push   $0xf0106716
f0101855:	68 1f 04 00 00       	push   $0x41f
f010185a:	68 f7 66 10 f0       	push   $0xf01066f7
f010185f:	e8 dc e7 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101864:	83 ec 04             	sub    $0x4,%esp
f0101867:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010186a:	50                   	push   %eax
f010186b:	6a 00                	push   $0x0
f010186d:	ff 35 2c 9f 23 f0    	pushl  0xf0239f2c
f0101873:	e8 ce f5 ff ff       	call   f0100e46 <page_lookup>
f0101878:	83 c4 10             	add    $0x10,%esp
f010187b:	85 c0                	test   %eax,%eax
f010187d:	74 19                	je     f0101898 <mem_init+0x8bd>
f010187f:	68 9c 62 10 f0       	push   $0xf010629c
f0101884:	68 16 67 10 f0       	push   $0xf0106716
f0101889:	68 22 04 00 00       	push   $0x422
f010188e:	68 f7 66 10 f0       	push   $0xf01066f7
f0101893:	e8 a8 e7 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101898:	6a 02                	push   $0x2
f010189a:	6a 00                	push   $0x0
f010189c:	56                   	push   %esi
f010189d:	ff 35 2c 9f 23 f0    	pushl  0xf0239f2c
f01018a3:	e8 7a f6 ff ff       	call   f0100f22 <page_insert>
f01018a8:	83 c4 10             	add    $0x10,%esp
f01018ab:	85 c0                	test   %eax,%eax
f01018ad:	78 19                	js     f01018c8 <mem_init+0x8ed>
f01018af:	68 d4 62 10 f0       	push   $0xf01062d4
f01018b4:	68 16 67 10 f0       	push   $0xf0106716
f01018b9:	68 25 04 00 00       	push   $0x425
f01018be:	68 f7 66 10 f0       	push   $0xf01066f7
f01018c3:	e8 78 e7 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01018c8:	83 ec 0c             	sub    $0xc,%esp
f01018cb:	53                   	push   %ebx
f01018cc:	e8 25 f4 ff ff       	call   f0100cf6 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01018d1:	6a 02                	push   $0x2
f01018d3:	6a 00                	push   $0x0
f01018d5:	56                   	push   %esi
f01018d6:	ff 35 2c 9f 23 f0    	pushl  0xf0239f2c
f01018dc:	e8 41 f6 ff ff       	call   f0100f22 <page_insert>
f01018e1:	83 c4 20             	add    $0x20,%esp
f01018e4:	85 c0                	test   %eax,%eax
f01018e6:	74 19                	je     f0101901 <mem_init+0x926>
f01018e8:	68 04 63 10 f0       	push   $0xf0106304
f01018ed:	68 16 67 10 f0       	push   $0xf0106716
f01018f2:	68 29 04 00 00       	push   $0x429
f01018f7:	68 f7 66 10 f0       	push   $0xf01066f7
f01018fc:	e8 3f e7 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101901:	a1 2c 9f 23 f0       	mov    0xf0239f2c,%eax
f0101906:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101909:	8b 0d 30 9f 23 f0    	mov    0xf0239f30,%ecx
f010190f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0101912:	8b 00                	mov    (%eax),%eax
f0101914:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101917:	89 c2                	mov    %eax,%edx
f0101919:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010191f:	89 d8                	mov    %ebx,%eax
f0101921:	29 c8                	sub    %ecx,%eax
f0101923:	c1 f8 03             	sar    $0x3,%eax
f0101926:	c1 e0 0c             	shl    $0xc,%eax
f0101929:	39 c2                	cmp    %eax,%edx
f010192b:	74 19                	je     f0101946 <mem_init+0x96b>
f010192d:	68 34 63 10 f0       	push   $0xf0106334
f0101932:	68 16 67 10 f0       	push   $0xf0106716
f0101937:	68 2a 04 00 00       	push   $0x42a
f010193c:	68 f7 66 10 f0       	push   $0xf01066f7
f0101941:	e8 fa e6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101946:	ba 00 00 00 00       	mov    $0x0,%edx
f010194b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010194e:	e8 90 f1 ff ff       	call   f0100ae3 <check_va2pa>
f0101953:	89 f2                	mov    %esi,%edx
f0101955:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101958:	c1 fa 03             	sar    $0x3,%edx
f010195b:	c1 e2 0c             	shl    $0xc,%edx
f010195e:	39 d0                	cmp    %edx,%eax
f0101960:	74 19                	je     f010197b <mem_init+0x9a0>
f0101962:	68 5c 63 10 f0       	push   $0xf010635c
f0101967:	68 16 67 10 f0       	push   $0xf0106716
f010196c:	68 2b 04 00 00       	push   $0x42b
f0101971:	68 f7 66 10 f0       	push   $0xf01066f7
f0101976:	e8 c5 e6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010197b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101980:	74 19                	je     f010199b <mem_init+0x9c0>
f0101982:	68 e7 68 10 f0       	push   $0xf01068e7
f0101987:	68 16 67 10 f0       	push   $0xf0106716
f010198c:	68 2c 04 00 00       	push   $0x42c
f0101991:	68 f7 66 10 f0       	push   $0xf01066f7
f0101996:	e8 a5 e6 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f010199b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01019a0:	74 19                	je     f01019bb <mem_init+0x9e0>
f01019a2:	68 f8 68 10 f0       	push   $0xf01068f8
f01019a7:	68 16 67 10 f0       	push   $0xf0106716
f01019ac:	68 2d 04 00 00       	push   $0x42d
f01019b1:	68 f7 66 10 f0       	push   $0xf01066f7
f01019b6:	e8 85 e6 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01019bb:	6a 02                	push   $0x2
f01019bd:	68 00 10 00 00       	push   $0x1000
f01019c2:	57                   	push   %edi
f01019c3:	ff 75 d0             	pushl  -0x30(%ebp)
f01019c6:	e8 57 f5 ff ff       	call   f0100f22 <page_insert>
f01019cb:	83 c4 10             	add    $0x10,%esp
f01019ce:	85 c0                	test   %eax,%eax
f01019d0:	74 19                	je     f01019eb <mem_init+0xa10>
f01019d2:	68 8c 63 10 f0       	push   $0xf010638c
f01019d7:	68 16 67 10 f0       	push   $0xf0106716
f01019dc:	68 30 04 00 00       	push   $0x430
f01019e1:	68 f7 66 10 f0       	push   $0xf01066f7
f01019e6:	e8 55 e6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019eb:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019f0:	a1 2c 9f 23 f0       	mov    0xf0239f2c,%eax
f01019f5:	e8 e9 f0 ff ff       	call   f0100ae3 <check_va2pa>
f01019fa:	89 fa                	mov    %edi,%edx
f01019fc:	2b 15 30 9f 23 f0    	sub    0xf0239f30,%edx
f0101a02:	c1 fa 03             	sar    $0x3,%edx
f0101a05:	c1 e2 0c             	shl    $0xc,%edx
f0101a08:	39 d0                	cmp    %edx,%eax
f0101a0a:	74 19                	je     f0101a25 <mem_init+0xa4a>
f0101a0c:	68 c8 63 10 f0       	push   $0xf01063c8
f0101a11:	68 16 67 10 f0       	push   $0xf0106716
f0101a16:	68 31 04 00 00       	push   $0x431
f0101a1b:	68 f7 66 10 f0       	push   $0xf01066f7
f0101a20:	e8 1b e6 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101a25:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101a2a:	74 19                	je     f0101a45 <mem_init+0xa6a>
f0101a2c:	68 09 69 10 f0       	push   $0xf0106909
f0101a31:	68 16 67 10 f0       	push   $0xf0106716
f0101a36:	68 32 04 00 00       	push   $0x432
f0101a3b:	68 f7 66 10 f0       	push   $0xf01066f7
f0101a40:	e8 fb e5 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101a45:	83 ec 0c             	sub    $0xc,%esp
f0101a48:	6a 00                	push   $0x0
f0101a4a:	e8 3d f2 ff ff       	call   f0100c8c <page_alloc>
f0101a4f:	83 c4 10             	add    $0x10,%esp
f0101a52:	85 c0                	test   %eax,%eax
f0101a54:	74 19                	je     f0101a6f <mem_init+0xa94>
f0101a56:	68 95 68 10 f0       	push   $0xf0106895
f0101a5b:	68 16 67 10 f0       	push   $0xf0106716
f0101a60:	68 35 04 00 00       	push   $0x435
f0101a65:	68 f7 66 10 f0       	push   $0xf01066f7
f0101a6a:	e8 d1 e5 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a6f:	6a 02                	push   $0x2
f0101a71:	68 00 10 00 00       	push   $0x1000
f0101a76:	57                   	push   %edi
f0101a77:	ff 35 2c 9f 23 f0    	pushl  0xf0239f2c
f0101a7d:	e8 a0 f4 ff ff       	call   f0100f22 <page_insert>
f0101a82:	83 c4 10             	add    $0x10,%esp
f0101a85:	85 c0                	test   %eax,%eax
f0101a87:	74 19                	je     f0101aa2 <mem_init+0xac7>
f0101a89:	68 8c 63 10 f0       	push   $0xf010638c
f0101a8e:	68 16 67 10 f0       	push   $0xf0106716
f0101a93:	68 38 04 00 00       	push   $0x438
f0101a98:	68 f7 66 10 f0       	push   $0xf01066f7
f0101a9d:	e8 9e e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101aa2:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101aa7:	a1 2c 9f 23 f0       	mov    0xf0239f2c,%eax
f0101aac:	e8 32 f0 ff ff       	call   f0100ae3 <check_va2pa>
f0101ab1:	89 fa                	mov    %edi,%edx
f0101ab3:	2b 15 30 9f 23 f0    	sub    0xf0239f30,%edx
f0101ab9:	c1 fa 03             	sar    $0x3,%edx
f0101abc:	c1 e2 0c             	shl    $0xc,%edx
f0101abf:	39 d0                	cmp    %edx,%eax
f0101ac1:	74 19                	je     f0101adc <mem_init+0xb01>
f0101ac3:	68 c8 63 10 f0       	push   $0xf01063c8
f0101ac8:	68 16 67 10 f0       	push   $0xf0106716
f0101acd:	68 39 04 00 00       	push   $0x439
f0101ad2:	68 f7 66 10 f0       	push   $0xf01066f7
f0101ad7:	e8 64 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101adc:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101ae1:	74 19                	je     f0101afc <mem_init+0xb21>
f0101ae3:	68 09 69 10 f0       	push   $0xf0106909
f0101ae8:	68 16 67 10 f0       	push   $0xf0106716
f0101aed:	68 3a 04 00 00       	push   $0x43a
f0101af2:	68 f7 66 10 f0       	push   $0xf01066f7
f0101af7:	e8 44 e5 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101afc:	83 ec 0c             	sub    $0xc,%esp
f0101aff:	6a 00                	push   $0x0
f0101b01:	e8 86 f1 ff ff       	call   f0100c8c <page_alloc>
f0101b06:	83 c4 10             	add    $0x10,%esp
f0101b09:	85 c0                	test   %eax,%eax
f0101b0b:	74 19                	je     f0101b26 <mem_init+0xb4b>
f0101b0d:	68 95 68 10 f0       	push   $0xf0106895
f0101b12:	68 16 67 10 f0       	push   $0xf0106716
f0101b17:	68 3e 04 00 00       	push   $0x43e
f0101b1c:	68 f7 66 10 f0       	push   $0xf01066f7
f0101b21:	e8 1a e5 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101b26:	8b 15 2c 9f 23 f0    	mov    0xf0239f2c,%edx
f0101b2c:	8b 02                	mov    (%edx),%eax
f0101b2e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b33:	89 c1                	mov    %eax,%ecx
f0101b35:	c1 e9 0c             	shr    $0xc,%ecx
f0101b38:	3b 0d 28 9f 23 f0    	cmp    0xf0239f28,%ecx
f0101b3e:	72 15                	jb     f0101b55 <mem_init+0xb7a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b40:	50                   	push   %eax
f0101b41:	68 c4 5b 10 f0       	push   $0xf0105bc4
f0101b46:	68 41 04 00 00       	push   $0x441
f0101b4b:	68 f7 66 10 f0       	push   $0xf01066f7
f0101b50:	e8 eb e4 ff ff       	call   f0100040 <_panic>
f0101b55:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101b5a:	89 45 e0             	mov    %eax,-0x20(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101b5d:	83 ec 04             	sub    $0x4,%esp
f0101b60:	6a 00                	push   $0x0
f0101b62:	68 00 10 00 00       	push   $0x1000
f0101b67:	52                   	push   %edx
f0101b68:	e8 ed f1 ff ff       	call   f0100d5a <pgdir_walk>
f0101b6d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101b70:	8d 51 04             	lea    0x4(%ecx),%edx
f0101b73:	83 c4 10             	add    $0x10,%esp
f0101b76:	39 d0                	cmp    %edx,%eax
f0101b78:	74 19                	je     f0101b93 <mem_init+0xbb8>
f0101b7a:	68 f8 63 10 f0       	push   $0xf01063f8
f0101b7f:	68 16 67 10 f0       	push   $0xf0106716
f0101b84:	68 42 04 00 00       	push   $0x442
f0101b89:	68 f7 66 10 f0       	push   $0xf01066f7
f0101b8e:	e8 ad e4 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101b93:	6a 06                	push   $0x6
f0101b95:	68 00 10 00 00       	push   $0x1000
f0101b9a:	57                   	push   %edi
f0101b9b:	ff 35 2c 9f 23 f0    	pushl  0xf0239f2c
f0101ba1:	e8 7c f3 ff ff       	call   f0100f22 <page_insert>
f0101ba6:	83 c4 10             	add    $0x10,%esp
f0101ba9:	85 c0                	test   %eax,%eax
f0101bab:	74 19                	je     f0101bc6 <mem_init+0xbeb>
f0101bad:	68 38 64 10 f0       	push   $0xf0106438
f0101bb2:	68 16 67 10 f0       	push   $0xf0106716
f0101bb7:	68 45 04 00 00       	push   $0x445
f0101bbc:	68 f7 66 10 f0       	push   $0xf01066f7
f0101bc1:	e8 7a e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bc6:	a1 2c 9f 23 f0       	mov    0xf0239f2c,%eax
f0101bcb:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101bce:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bd3:	e8 0b ef ff ff       	call   f0100ae3 <check_va2pa>
f0101bd8:	89 fa                	mov    %edi,%edx
f0101bda:	2b 15 30 9f 23 f0    	sub    0xf0239f30,%edx
f0101be0:	c1 fa 03             	sar    $0x3,%edx
f0101be3:	c1 e2 0c             	shl    $0xc,%edx
f0101be6:	39 d0                	cmp    %edx,%eax
f0101be8:	74 19                	je     f0101c03 <mem_init+0xc28>
f0101bea:	68 c8 63 10 f0       	push   $0xf01063c8
f0101bef:	68 16 67 10 f0       	push   $0xf0106716
f0101bf4:	68 46 04 00 00       	push   $0x446
f0101bf9:	68 f7 66 10 f0       	push   $0xf01066f7
f0101bfe:	e8 3d e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101c03:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101c08:	74 19                	je     f0101c23 <mem_init+0xc48>
f0101c0a:	68 09 69 10 f0       	push   $0xf0106909
f0101c0f:	68 16 67 10 f0       	push   $0xf0106716
f0101c14:	68 47 04 00 00       	push   $0x447
f0101c19:	68 f7 66 10 f0       	push   $0xf01066f7
f0101c1e:	e8 1d e4 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101c23:	83 ec 04             	sub    $0x4,%esp
f0101c26:	6a 00                	push   $0x0
f0101c28:	68 00 10 00 00       	push   $0x1000
f0101c2d:	ff 75 d0             	pushl  -0x30(%ebp)
f0101c30:	e8 25 f1 ff ff       	call   f0100d5a <pgdir_walk>
f0101c35:	83 c4 10             	add    $0x10,%esp
f0101c38:	f6 00 04             	testb  $0x4,(%eax)
f0101c3b:	75 19                	jne    f0101c56 <mem_init+0xc7b>
f0101c3d:	68 78 64 10 f0       	push   $0xf0106478
f0101c42:	68 16 67 10 f0       	push   $0xf0106716
f0101c47:	68 48 04 00 00       	push   $0x448
f0101c4c:	68 f7 66 10 f0       	push   $0xf01066f7
f0101c51:	e8 ea e3 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101c56:	a1 2c 9f 23 f0       	mov    0xf0239f2c,%eax
f0101c5b:	f6 00 04             	testb  $0x4,(%eax)
f0101c5e:	75 19                	jne    f0101c79 <mem_init+0xc9e>
f0101c60:	68 1a 69 10 f0       	push   $0xf010691a
f0101c65:	68 16 67 10 f0       	push   $0xf0106716
f0101c6a:	68 49 04 00 00       	push   $0x449
f0101c6f:	68 f7 66 10 f0       	push   $0xf01066f7
f0101c74:	e8 c7 e3 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c79:	6a 02                	push   $0x2
f0101c7b:	68 00 10 00 00       	push   $0x1000
f0101c80:	57                   	push   %edi
f0101c81:	50                   	push   %eax
f0101c82:	e8 9b f2 ff ff       	call   f0100f22 <page_insert>
f0101c87:	83 c4 10             	add    $0x10,%esp
f0101c8a:	85 c0                	test   %eax,%eax
f0101c8c:	74 19                	je     f0101ca7 <mem_init+0xccc>
f0101c8e:	68 8c 63 10 f0       	push   $0xf010638c
f0101c93:	68 16 67 10 f0       	push   $0xf0106716
f0101c98:	68 4c 04 00 00       	push   $0x44c
f0101c9d:	68 f7 66 10 f0       	push   $0xf01066f7
f0101ca2:	e8 99 e3 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101ca7:	83 ec 04             	sub    $0x4,%esp
f0101caa:	6a 00                	push   $0x0
f0101cac:	68 00 10 00 00       	push   $0x1000
f0101cb1:	ff 35 2c 9f 23 f0    	pushl  0xf0239f2c
f0101cb7:	e8 9e f0 ff ff       	call   f0100d5a <pgdir_walk>
f0101cbc:	83 c4 10             	add    $0x10,%esp
f0101cbf:	f6 00 02             	testb  $0x2,(%eax)
f0101cc2:	75 19                	jne    f0101cdd <mem_init+0xd02>
f0101cc4:	68 ac 64 10 f0       	push   $0xf01064ac
f0101cc9:	68 16 67 10 f0       	push   $0xf0106716
f0101cce:	68 4d 04 00 00       	push   $0x44d
f0101cd3:	68 f7 66 10 f0       	push   $0xf01066f7
f0101cd8:	e8 63 e3 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101cdd:	83 ec 04             	sub    $0x4,%esp
f0101ce0:	6a 00                	push   $0x0
f0101ce2:	68 00 10 00 00       	push   $0x1000
f0101ce7:	ff 35 2c 9f 23 f0    	pushl  0xf0239f2c
f0101ced:	e8 68 f0 ff ff       	call   f0100d5a <pgdir_walk>
f0101cf2:	83 c4 10             	add    $0x10,%esp
f0101cf5:	f6 00 04             	testb  $0x4,(%eax)
f0101cf8:	74 19                	je     f0101d13 <mem_init+0xd38>
f0101cfa:	68 e0 64 10 f0       	push   $0xf01064e0
f0101cff:	68 16 67 10 f0       	push   $0xf0106716
f0101d04:	68 4e 04 00 00       	push   $0x44e
f0101d09:	68 f7 66 10 f0       	push   $0xf01066f7
f0101d0e:	e8 2d e3 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101d13:	6a 02                	push   $0x2
f0101d15:	68 00 00 40 00       	push   $0x400000
f0101d1a:	53                   	push   %ebx
f0101d1b:	ff 35 2c 9f 23 f0    	pushl  0xf0239f2c
f0101d21:	e8 fc f1 ff ff       	call   f0100f22 <page_insert>
f0101d26:	83 c4 10             	add    $0x10,%esp
f0101d29:	85 c0                	test   %eax,%eax
f0101d2b:	78 19                	js     f0101d46 <mem_init+0xd6b>
f0101d2d:	68 18 65 10 f0       	push   $0xf0106518
f0101d32:	68 16 67 10 f0       	push   $0xf0106716
f0101d37:	68 51 04 00 00       	push   $0x451
f0101d3c:	68 f7 66 10 f0       	push   $0xf01066f7
f0101d41:	e8 fa e2 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101d46:	6a 02                	push   $0x2
f0101d48:	68 00 10 00 00       	push   $0x1000
f0101d4d:	56                   	push   %esi
f0101d4e:	ff 35 2c 9f 23 f0    	pushl  0xf0239f2c
f0101d54:	e8 c9 f1 ff ff       	call   f0100f22 <page_insert>
f0101d59:	83 c4 10             	add    $0x10,%esp
f0101d5c:	85 c0                	test   %eax,%eax
f0101d5e:	74 19                	je     f0101d79 <mem_init+0xd9e>
f0101d60:	68 50 65 10 f0       	push   $0xf0106550
f0101d65:	68 16 67 10 f0       	push   $0xf0106716
f0101d6a:	68 54 04 00 00       	push   $0x454
f0101d6f:	68 f7 66 10 f0       	push   $0xf01066f7
f0101d74:	e8 c7 e2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101d79:	83 ec 04             	sub    $0x4,%esp
f0101d7c:	6a 00                	push   $0x0
f0101d7e:	68 00 10 00 00       	push   $0x1000
f0101d83:	ff 35 2c 9f 23 f0    	pushl  0xf0239f2c
f0101d89:	e8 cc ef ff ff       	call   f0100d5a <pgdir_walk>
f0101d8e:	83 c4 10             	add    $0x10,%esp
f0101d91:	f6 00 04             	testb  $0x4,(%eax)
f0101d94:	74 19                	je     f0101daf <mem_init+0xdd4>
f0101d96:	68 e0 64 10 f0       	push   $0xf01064e0
f0101d9b:	68 16 67 10 f0       	push   $0xf0106716
f0101da0:	68 55 04 00 00       	push   $0x455
f0101da5:	68 f7 66 10 f0       	push   $0xf01066f7
f0101daa:	e8 91 e2 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101daf:	a1 2c 9f 23 f0       	mov    0xf0239f2c,%eax
f0101db4:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101db7:	ba 00 00 00 00       	mov    $0x0,%edx
f0101dbc:	e8 22 ed ff ff       	call   f0100ae3 <check_va2pa>
f0101dc1:	89 c1                	mov    %eax,%ecx
f0101dc3:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101dc6:	89 f0                	mov    %esi,%eax
f0101dc8:	2b 05 30 9f 23 f0    	sub    0xf0239f30,%eax
f0101dce:	c1 f8 03             	sar    $0x3,%eax
f0101dd1:	c1 e0 0c             	shl    $0xc,%eax
f0101dd4:	39 c1                	cmp    %eax,%ecx
f0101dd6:	74 19                	je     f0101df1 <mem_init+0xe16>
f0101dd8:	68 8c 65 10 f0       	push   $0xf010658c
f0101ddd:	68 16 67 10 f0       	push   $0xf0106716
f0101de2:	68 58 04 00 00       	push   $0x458
f0101de7:	68 f7 66 10 f0       	push   $0xf01066f7
f0101dec:	e8 4f e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101df1:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101df6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101df9:	e8 e5 ec ff ff       	call   f0100ae3 <check_va2pa>
f0101dfe:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101e01:	74 19                	je     f0101e1c <mem_init+0xe41>
f0101e03:	68 b8 65 10 f0       	push   $0xf01065b8
f0101e08:	68 16 67 10 f0       	push   $0xf0106716
f0101e0d:	68 59 04 00 00       	push   $0x459
f0101e12:	68 f7 66 10 f0       	push   $0xf01066f7
f0101e17:	e8 24 e2 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101e1c:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0101e21:	74 19                	je     f0101e3c <mem_init+0xe61>
f0101e23:	68 30 69 10 f0       	push   $0xf0106930
f0101e28:	68 16 67 10 f0       	push   $0xf0106716
f0101e2d:	68 5b 04 00 00       	push   $0x45b
f0101e32:	68 f7 66 10 f0       	push   $0xf01066f7
f0101e37:	e8 04 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101e3c:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101e41:	74 19                	je     f0101e5c <mem_init+0xe81>
f0101e43:	68 41 69 10 f0       	push   $0xf0106941
f0101e48:	68 16 67 10 f0       	push   $0xf0106716
f0101e4d:	68 5c 04 00 00       	push   $0x45c
f0101e52:	68 f7 66 10 f0       	push   $0xf01066f7
f0101e57:	e8 e4 e1 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101e5c:	83 ec 0c             	sub    $0xc,%esp
f0101e5f:	6a 00                	push   $0x0
f0101e61:	e8 26 ee ff ff       	call   f0100c8c <page_alloc>
f0101e66:	83 c4 10             	add    $0x10,%esp
f0101e69:	39 c7                	cmp    %eax,%edi
f0101e6b:	75 04                	jne    f0101e71 <mem_init+0xe96>
f0101e6d:	85 c0                	test   %eax,%eax
f0101e6f:	75 19                	jne    f0101e8a <mem_init+0xeaf>
f0101e71:	68 e8 65 10 f0       	push   $0xf01065e8
f0101e76:	68 16 67 10 f0       	push   $0xf0106716
f0101e7b:	68 5f 04 00 00       	push   $0x45f
f0101e80:	68 f7 66 10 f0       	push   $0xf01066f7
f0101e85:	e8 b6 e1 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101e8a:	83 ec 08             	sub    $0x8,%esp
f0101e8d:	6a 00                	push   $0x0
f0101e8f:	ff 35 2c 9f 23 f0    	pushl  0xf0239f2c
f0101e95:	e8 33 f0 ff ff       	call   f0100ecd <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e9a:	a1 2c 9f 23 f0       	mov    0xf0239f2c,%eax
f0101e9f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101ea2:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ea7:	e8 37 ec ff ff       	call   f0100ae3 <check_va2pa>
f0101eac:	83 c4 10             	add    $0x10,%esp
f0101eaf:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101eb2:	74 19                	je     f0101ecd <mem_init+0xef2>
f0101eb4:	68 0c 66 10 f0       	push   $0xf010660c
f0101eb9:	68 16 67 10 f0       	push   $0xf0106716
f0101ebe:	68 63 04 00 00       	push   $0x463
f0101ec3:	68 f7 66 10 f0       	push   $0xf01066f7
f0101ec8:	e8 73 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101ecd:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ed2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101ed5:	e8 09 ec ff ff       	call   f0100ae3 <check_va2pa>
f0101eda:	89 f2                	mov    %esi,%edx
f0101edc:	2b 15 30 9f 23 f0    	sub    0xf0239f30,%edx
f0101ee2:	c1 fa 03             	sar    $0x3,%edx
f0101ee5:	c1 e2 0c             	shl    $0xc,%edx
f0101ee8:	39 d0                	cmp    %edx,%eax
f0101eea:	74 19                	je     f0101f05 <mem_init+0xf2a>
f0101eec:	68 b8 65 10 f0       	push   $0xf01065b8
f0101ef1:	68 16 67 10 f0       	push   $0xf0106716
f0101ef6:	68 64 04 00 00       	push   $0x464
f0101efb:	68 f7 66 10 f0       	push   $0xf01066f7
f0101f00:	e8 3b e1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101f05:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f0a:	74 19                	je     f0101f25 <mem_init+0xf4a>
f0101f0c:	68 e7 68 10 f0       	push   $0xf01068e7
f0101f11:	68 16 67 10 f0       	push   $0xf0106716
f0101f16:	68 65 04 00 00       	push   $0x465
f0101f1b:	68 f7 66 10 f0       	push   $0xf01066f7
f0101f20:	e8 1b e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101f25:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101f2a:	74 19                	je     f0101f45 <mem_init+0xf6a>
f0101f2c:	68 41 69 10 f0       	push   $0xf0106941
f0101f31:	68 16 67 10 f0       	push   $0xf0106716
f0101f36:	68 66 04 00 00       	push   $0x466
f0101f3b:	68 f7 66 10 f0       	push   $0xf01066f7
f0101f40:	e8 fb e0 ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101f45:	6a 00                	push   $0x0
f0101f47:	68 00 10 00 00       	push   $0x1000
f0101f4c:	56                   	push   %esi
f0101f4d:	ff 75 d0             	pushl  -0x30(%ebp)
f0101f50:	e8 cd ef ff ff       	call   f0100f22 <page_insert>
f0101f55:	83 c4 10             	add    $0x10,%esp
f0101f58:	85 c0                	test   %eax,%eax
f0101f5a:	74 19                	je     f0101f75 <mem_init+0xf9a>
f0101f5c:	68 30 66 10 f0       	push   $0xf0106630
f0101f61:	68 16 67 10 f0       	push   $0xf0106716
f0101f66:	68 69 04 00 00       	push   $0x469
f0101f6b:	68 f7 66 10 f0       	push   $0xf01066f7
f0101f70:	e8 cb e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0101f75:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f7a:	75 19                	jne    f0101f95 <mem_init+0xfba>
f0101f7c:	68 52 69 10 f0       	push   $0xf0106952
f0101f81:	68 16 67 10 f0       	push   $0xf0106716
f0101f86:	68 6a 04 00 00       	push   $0x46a
f0101f8b:	68 f7 66 10 f0       	push   $0xf01066f7
f0101f90:	e8 ab e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0101f95:	83 3e 00             	cmpl   $0x0,(%esi)
f0101f98:	74 19                	je     f0101fb3 <mem_init+0xfd8>
f0101f9a:	68 5e 69 10 f0       	push   $0xf010695e
f0101f9f:	68 16 67 10 f0       	push   $0xf0106716
f0101fa4:	68 6b 04 00 00       	push   $0x46b
f0101fa9:	68 f7 66 10 f0       	push   $0xf01066f7
f0101fae:	e8 8d e0 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101fb3:	83 ec 08             	sub    $0x8,%esp
f0101fb6:	68 00 10 00 00       	push   $0x1000
f0101fbb:	ff 35 2c 9f 23 f0    	pushl  0xf0239f2c
f0101fc1:	e8 07 ef ff ff       	call   f0100ecd <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101fc6:	a1 2c 9f 23 f0       	mov    0xf0239f2c,%eax
f0101fcb:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101fce:	ba 00 00 00 00       	mov    $0x0,%edx
f0101fd3:	e8 0b eb ff ff       	call   f0100ae3 <check_va2pa>
f0101fd8:	83 c4 10             	add    $0x10,%esp
f0101fdb:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fde:	74 19                	je     f0101ff9 <mem_init+0x101e>
f0101fe0:	68 0c 66 10 f0       	push   $0xf010660c
f0101fe5:	68 16 67 10 f0       	push   $0xf0106716
f0101fea:	68 6f 04 00 00       	push   $0x46f
f0101fef:	68 f7 66 10 f0       	push   $0xf01066f7
f0101ff4:	e8 47 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101ff9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ffe:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102001:	e8 dd ea ff ff       	call   f0100ae3 <check_va2pa>
f0102006:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102009:	74 19                	je     f0102024 <mem_init+0x1049>
f010200b:	68 68 66 10 f0       	push   $0xf0106668
f0102010:	68 16 67 10 f0       	push   $0xf0106716
f0102015:	68 70 04 00 00       	push   $0x470
f010201a:	68 f7 66 10 f0       	push   $0xf01066f7
f010201f:	e8 1c e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102024:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102029:	74 19                	je     f0102044 <mem_init+0x1069>
f010202b:	68 73 69 10 f0       	push   $0xf0106973
f0102030:	68 16 67 10 f0       	push   $0xf0106716
f0102035:	68 71 04 00 00       	push   $0x471
f010203a:	68 f7 66 10 f0       	push   $0xf01066f7
f010203f:	e8 fc df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102044:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102049:	74 19                	je     f0102064 <mem_init+0x1089>
f010204b:	68 41 69 10 f0       	push   $0xf0106941
f0102050:	68 16 67 10 f0       	push   $0xf0106716
f0102055:	68 72 04 00 00       	push   $0x472
f010205a:	68 f7 66 10 f0       	push   $0xf01066f7
f010205f:	e8 dc df ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102064:	83 ec 0c             	sub    $0xc,%esp
f0102067:	6a 00                	push   $0x0
f0102069:	e8 1e ec ff ff       	call   f0100c8c <page_alloc>
f010206e:	83 c4 10             	add    $0x10,%esp
f0102071:	39 c6                	cmp    %eax,%esi
f0102073:	75 04                	jne    f0102079 <mem_init+0x109e>
f0102075:	85 c0                	test   %eax,%eax
f0102077:	75 19                	jne    f0102092 <mem_init+0x10b7>
f0102079:	68 90 66 10 f0       	push   $0xf0106690
f010207e:	68 16 67 10 f0       	push   $0xf0106716
f0102083:	68 75 04 00 00       	push   $0x475
f0102088:	68 f7 66 10 f0       	push   $0xf01066f7
f010208d:	e8 ae df ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102092:	83 ec 0c             	sub    $0xc,%esp
f0102095:	6a 00                	push   $0x0
f0102097:	e8 f0 eb ff ff       	call   f0100c8c <page_alloc>
f010209c:	83 c4 10             	add    $0x10,%esp
f010209f:	85 c0                	test   %eax,%eax
f01020a1:	74 19                	je     f01020bc <mem_init+0x10e1>
f01020a3:	68 95 68 10 f0       	push   $0xf0106895
f01020a8:	68 16 67 10 f0       	push   $0xf0106716
f01020ad:	68 78 04 00 00       	push   $0x478
f01020b2:	68 f7 66 10 f0       	push   $0xf01066f7
f01020b7:	e8 84 df ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01020bc:	8b 0d 2c 9f 23 f0    	mov    0xf0239f2c,%ecx
f01020c2:	8b 11                	mov    (%ecx),%edx
f01020c4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01020ca:	89 d8                	mov    %ebx,%eax
f01020cc:	2b 05 30 9f 23 f0    	sub    0xf0239f30,%eax
f01020d2:	c1 f8 03             	sar    $0x3,%eax
f01020d5:	c1 e0 0c             	shl    $0xc,%eax
f01020d8:	39 c2                	cmp    %eax,%edx
f01020da:	74 19                	je     f01020f5 <mem_init+0x111a>
f01020dc:	68 34 63 10 f0       	push   $0xf0106334
f01020e1:	68 16 67 10 f0       	push   $0xf0106716
f01020e6:	68 7b 04 00 00       	push   $0x47b
f01020eb:	68 f7 66 10 f0       	push   $0xf01066f7
f01020f0:	e8 4b df ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01020f5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01020fb:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102100:	74 19                	je     f010211b <mem_init+0x1140>
f0102102:	68 f8 68 10 f0       	push   $0xf01068f8
f0102107:	68 16 67 10 f0       	push   $0xf0106716
f010210c:	68 7d 04 00 00       	push   $0x47d
f0102111:	68 f7 66 10 f0       	push   $0xf01066f7
f0102116:	e8 25 df ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010211b:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102121:	83 ec 0c             	sub    $0xc,%esp
f0102124:	53                   	push   %ebx
f0102125:	e8 cc eb ff ff       	call   f0100cf6 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010212a:	83 c4 0c             	add    $0xc,%esp
f010212d:	6a 01                	push   $0x1
f010212f:	68 00 10 40 00       	push   $0x401000
f0102134:	ff 35 2c 9f 23 f0    	pushl  0xf0239f2c
f010213a:	e8 1b ec ff ff       	call   f0100d5a <pgdir_walk>
f010213f:	89 c1                	mov    %eax,%ecx
f0102141:	89 45 e0             	mov    %eax,-0x20(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102144:	a1 2c 9f 23 f0       	mov    0xf0239f2c,%eax
f0102149:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010214c:	8b 40 04             	mov    0x4(%eax),%eax
f010214f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102154:	89 c2                	mov    %eax,%edx
f0102156:	c1 ea 0c             	shr    $0xc,%edx
f0102159:	83 c4 10             	add    $0x10,%esp
f010215c:	3b 15 28 9f 23 f0    	cmp    0xf0239f28,%edx
f0102162:	72 15                	jb     f0102179 <mem_init+0x119e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102164:	50                   	push   %eax
f0102165:	68 c4 5b 10 f0       	push   $0xf0105bc4
f010216a:	68 84 04 00 00       	push   $0x484
f010216f:	68 f7 66 10 f0       	push   $0xf01066f7
f0102174:	e8 c7 de ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102179:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f010217e:	39 c1                	cmp    %eax,%ecx
f0102180:	74 19                	je     f010219b <mem_init+0x11c0>
f0102182:	68 84 69 10 f0       	push   $0xf0106984
f0102187:	68 16 67 10 f0       	push   $0xf0106716
f010218c:	68 85 04 00 00       	push   $0x485
f0102191:	68 f7 66 10 f0       	push   $0xf01066f7
f0102196:	e8 a5 de ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010219b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010219e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f01021a5:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01021ab:	89 d8                	mov    %ebx,%eax
f01021ad:	e8 fa e8 ff ff       	call   f0100aac <page2kva>
f01021b2:	83 ec 04             	sub    $0x4,%esp
f01021b5:	68 00 10 00 00       	push   $0x1000
f01021ba:	68 ff 00 00 00       	push   $0xff
f01021bf:	50                   	push   %eax
f01021c0:	e8 1b 2d 00 00       	call   f0104ee0 <memset>
	page_free(pp0);
f01021c5:	89 1c 24             	mov    %ebx,(%esp)
f01021c8:	e8 29 eb ff ff       	call   f0100cf6 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01021cd:	83 c4 0c             	add    $0xc,%esp
f01021d0:	6a 01                	push   $0x1
f01021d2:	6a 00                	push   $0x0
f01021d4:	ff 35 2c 9f 23 f0    	pushl  0xf0239f2c
f01021da:	e8 7b eb ff ff       	call   f0100d5a <pgdir_walk>
	ptep = (pte_t *) page2kva(pp0);
f01021df:	89 d8                	mov    %ebx,%eax
f01021e1:	e8 c6 e8 ff ff       	call   f0100aac <page2kva>
f01021e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01021e9:	83 c4 10             	add    $0x10,%esp
	for(i=0; i<NPTENTRIES; i++)
f01021ec:	ba 00 00 00 00       	mov    $0x0,%edx
		assert((ptep[i] & PTE_P) == 0);
f01021f1:	f6 04 90 01          	testb  $0x1,(%eax,%edx,4)
f01021f5:	74 19                	je     f0102210 <mem_init+0x1235>
f01021f7:	68 9c 69 10 f0       	push   $0xf010699c
f01021fc:	68 16 67 10 f0       	push   $0xf0106716
f0102201:	68 8f 04 00 00       	push   $0x48f
f0102206:	68 f7 66 10 f0       	push   $0xf01066f7
f010220b:	e8 30 de ff ff       	call   f0100040 <_panic>
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102210:	83 c2 01             	add    $0x1,%edx
f0102213:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0102219:	75 d6                	jne    f01021f1 <mem_init+0x1216>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f010221b:	a1 2c 9f 23 f0       	mov    0xf0239f2c,%eax
f0102220:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102226:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// give free list back
	page_free_list = fl;
f010222c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010222f:	a3 58 92 23 f0       	mov    %eax,0xf0239258

	// free the pages we took
	page_free(pp0);
f0102234:	83 ec 0c             	sub    $0xc,%esp
f0102237:	53                   	push   %ebx
f0102238:	e8 b9 ea ff ff       	call   f0100cf6 <page_free>
	page_free(pp1);
f010223d:	89 34 24             	mov    %esi,(%esp)
f0102240:	e8 b1 ea ff ff       	call   f0100cf6 <page_free>
	page_free(pp2);
f0102245:	89 3c 24             	mov    %edi,(%esp)
f0102248:	e8 a9 ea ff ff       	call   f0100cf6 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010224d:	83 c4 08             	add    $0x8,%esp
f0102250:	68 01 10 00 00       	push   $0x1001
f0102255:	6a 00                	push   $0x0
f0102257:	e8 65 ed ff ff       	call   f0100fc1 <mmio_map_region>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f010225c:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0102261:	0f 85 f0 f0 ff ff    	jne    f0101357 <mem_init+0x37c>
f0102267:	e9 d2 f0 ff ff       	jmp    f010133e <mem_init+0x363>
f010226c:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0102271:	0f 85 e5 f0 ff ff    	jne    f010135c <mem_init+0x381>
f0102277:	e9 c2 f0 ff ff       	jmp    f010133e <mem_init+0x363>

f010227c <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f010227c:	55                   	push   %ebp
f010227d:	89 e5                	mov    %esp,%ebp
f010227f:	57                   	push   %edi
f0102280:	56                   	push   %esi
f0102281:	53                   	push   %ebx
f0102282:	83 ec 0c             	sub    $0xc,%esp
f0102285:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.

    uintptr_t end_va = ROUNDUP((uint32_t)va + len, PGSIZE);
f0102288:	8b 45 10             	mov    0x10(%ebp),%eax
f010228b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010228e:	8d b4 06 ff 0f 00 00 	lea    0xfff(%esi,%eax,1),%esi
f0102295:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pte_t *pte = NULL;
    perm |= PTE_P;
f010229b:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010229e:	83 cb 01             	or     $0x1,%ebx

    for (user_mem_check_addr = (uintptr_t)va; 
f01022a1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01022a4:	a3 54 92 23 f0       	mov    %eax,0xf0239254
f01022a9:	eb 37                	jmp    f01022e2 <user_mem_check+0x66>
                user_mem_check_addr < end_va;
                user_mem_check_addr += PGSIZE )
    {

        pte = pgdir_walk(env->env_pgdir, (void *)user_mem_check_addr, 0);
f01022ab:	83 ec 04             	sub    $0x4,%esp
f01022ae:	6a 00                	push   $0x0
f01022b0:	50                   	push   %eax
f01022b1:	ff 77 60             	pushl  0x60(%edi)
f01022b4:	e8 a1 ea ff ff       	call   f0100d5a <pgdir_walk>

        if(!pte)
f01022b9:	83 c4 10             	add    $0x10,%esp
f01022bc:	85 c0                	test   %eax,%eax
f01022be:	74 32                	je     f01022f2 <user_mem_check+0x76>
        {
            goto err;
        }

        if(user_mem_check_addr > ULIM)
f01022c0:	8b 15 54 92 23 f0    	mov    0xf0239254,%edx
f01022c6:	81 fa 00 00 80 ef    	cmp    $0xef800000,%edx
f01022cc:	77 24                	ja     f01022f2 <user_mem_check+0x76>
        {
            goto err;
        }
        if((*pte & perm) != perm)
f01022ce:	89 d9                	mov    %ebx,%ecx
f01022d0:	23 08                	and    (%eax),%ecx
f01022d2:	39 cb                	cmp    %ecx,%ebx
f01022d4:	75 1c                	jne    f01022f2 <user_mem_check+0x76>
    pte_t *pte = NULL;
    perm |= PTE_P;

    for (user_mem_check_addr = (uintptr_t)va; 
                user_mem_check_addr < end_va;
                user_mem_check_addr += PGSIZE )
f01022d6:	81 c2 00 10 00 00    	add    $0x1000,%edx
f01022dc:	89 15 54 92 23 f0    	mov    %edx,0xf0239254
    uintptr_t end_va = ROUNDUP((uint32_t)va + len, PGSIZE);
    pte_t *pte = NULL;
    perm |= PTE_P;

    for (user_mem_check_addr = (uintptr_t)va; 
                user_mem_check_addr < end_va;
f01022e2:	a1 54 92 23 f0       	mov    0xf0239254,%eax

    uintptr_t end_va = ROUNDUP((uint32_t)va + len, PGSIZE);
    pte_t *pte = NULL;
    perm |= PTE_P;

    for (user_mem_check_addr = (uintptr_t)va; 
f01022e7:	39 c6                	cmp    %eax,%esi
f01022e9:	77 c0                	ja     f01022ab <user_mem_check+0x2f>
            goto err;
        }
                
    }

	return 0;
f01022eb:	ba 00 00 00 00       	mov    $0x0,%edx
f01022f0:	eb 17                	jmp    f0102309 <user_mem_check+0x8d>
    else
    {
        user_mem_check_addr = *pte;
    }
    
    return -E_FAULT;
f01022f2:	ba fa ff ff ff       	mov    $0xfffffffa,%edx

	return 0;
err:

    
    if (user_mem_check_addr == (uintptr_t) va)
f01022f7:	8b 3d 54 92 23 f0    	mov    0xf0239254,%edi
f01022fd:	39 7d 0c             	cmp    %edi,0xc(%ebp)
f0102300:	74 07                	je     f0102309 <user_mem_check+0x8d>
    {
        user_mem_check_addr = (uintptr_t) va;
    }
    else
    {
        user_mem_check_addr = *pte;
f0102302:	8b 00                	mov    (%eax),%eax
f0102304:	a3 54 92 23 f0       	mov    %eax,0xf0239254
    }
    
    return -E_FAULT;
}
f0102309:	89 d0                	mov    %edx,%eax
f010230b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010230e:	5b                   	pop    %ebx
f010230f:	5e                   	pop    %esi
f0102310:	5f                   	pop    %edi
f0102311:	5d                   	pop    %ebp
f0102312:	c3                   	ret    

f0102313 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102313:	55                   	push   %ebp
f0102314:	89 e5                	mov    %esp,%ebp
f0102316:	53                   	push   %ebx
f0102317:	83 ec 04             	sub    $0x4,%esp
f010231a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f010231d:	8b 45 14             	mov    0x14(%ebp),%eax
f0102320:	83 c8 04             	or     $0x4,%eax
f0102323:	50                   	push   %eax
f0102324:	ff 75 10             	pushl  0x10(%ebp)
f0102327:	ff 75 0c             	pushl  0xc(%ebp)
f010232a:	53                   	push   %ebx
f010232b:	e8 4c ff ff ff       	call   f010227c <user_mem_check>
f0102330:	83 c4 10             	add    $0x10,%esp
f0102333:	85 c0                	test   %eax,%eax
f0102335:	79 21                	jns    f0102358 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102337:	83 ec 04             	sub    $0x4,%esp
f010233a:	ff 35 54 92 23 f0    	pushl  0xf0239254
f0102340:	ff 73 48             	pushl  0x48(%ebx)
f0102343:	68 b4 66 10 f0       	push   $0xf01066b4
f0102348:	e8 6b 09 00 00       	call   f0102cb8 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f010234d:	89 1c 24             	mov    %ebx,(%esp)
f0102350:	e8 b8 06 00 00       	call   f0102a0d <env_destroy>
f0102355:	83 c4 10             	add    $0x10,%esp
	}
}
f0102358:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010235b:	c9                   	leave  
f010235c:	c3                   	ret    

f010235d <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f010235d:	55                   	push   %ebp
f010235e:	89 e5                	mov    %esp,%ebp
f0102360:	57                   	push   %edi
f0102361:	56                   	push   %esi
f0102362:	53                   	push   %ebx
f0102363:	83 ec 0c             	sub    $0xc,%esp
f0102366:	89 c7                	mov    %eax,%edi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

    va = ROUNDDOWN(va, PGSIZE);
f0102368:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010236e:	89 d6                	mov    %edx,%esi
    len = ROUNDUP(len, PGSIZE);
f0102370:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
f0102376:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

    struct PageInfo *pp;
    int ret = 0;

    for(; len > 0; len -= PGSIZE, va += PGSIZE)
f010237c:	eb 5e                	jmp    f01023dc <region_alloc+0x7f>
    {
        pp = page_alloc(0);
f010237e:	83 ec 0c             	sub    $0xc,%esp
f0102381:	6a 00                	push   $0x0
f0102383:	e8 04 e9 ff ff       	call   f0100c8c <page_alloc>

        if(!pp)
f0102388:	83 c4 10             	add    $0x10,%esp
f010238b:	85 c0                	test   %eax,%eax
f010238d:	75 17                	jne    f01023a6 <region_alloc+0x49>
        {
            panic("region_alloc failed\n");
f010238f:	83 ec 04             	sub    $0x4,%esp
f0102392:	68 b3 69 10 f0       	push   $0xf01069b3
f0102397:	68 3e 01 00 00       	push   $0x13e
f010239c:	68 c8 69 10 f0       	push   $0xf01069c8
f01023a1:	e8 9a dc ff ff       	call   f0100040 <_panic>
        }

        ret = page_insert(e->env_pgdir, pp, va, PTE_U | PTE_W | PTE_P);
f01023a6:	6a 07                	push   $0x7
f01023a8:	56                   	push   %esi
f01023a9:	50                   	push   %eax
f01023aa:	ff 77 60             	pushl  0x60(%edi)
f01023ad:	e8 70 eb ff ff       	call   f0100f22 <page_insert>

        if(ret)
f01023b2:	83 c4 10             	add    $0x10,%esp
f01023b5:	85 c0                	test   %eax,%eax
f01023b7:	74 17                	je     f01023d0 <region_alloc+0x73>
        {
            panic("region_alloc failed\n");
f01023b9:	83 ec 04             	sub    $0x4,%esp
f01023bc:	68 b3 69 10 f0       	push   $0xf01069b3
f01023c1:	68 45 01 00 00       	push   $0x145
f01023c6:	68 c8 69 10 f0       	push   $0xf01069c8
f01023cb:	e8 70 dc ff ff       	call   f0100040 <_panic>
    len = ROUNDUP(len, PGSIZE);

    struct PageInfo *pp;
    int ret = 0;

    for(; len > 0; len -= PGSIZE, va += PGSIZE)
f01023d0:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
f01023d6:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01023dc:	85 db                	test   %ebx,%ebx
f01023de:	75 9e                	jne    f010237e <region_alloc+0x21>
        if(ret)
        {
            panic("region_alloc failed\n");
        }
    }
}
f01023e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01023e3:	5b                   	pop    %ebx
f01023e4:	5e                   	pop    %esi
f01023e5:	5f                   	pop    %edi
f01023e6:	5d                   	pop    %ebp
f01023e7:	c3                   	ret    

f01023e8 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01023e8:	55                   	push   %ebp
f01023e9:	89 e5                	mov    %esp,%ebp
f01023eb:	56                   	push   %esi
f01023ec:	53                   	push   %ebx
f01023ed:	8b 45 08             	mov    0x8(%ebp),%eax
f01023f0:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01023f3:	85 c0                	test   %eax,%eax
f01023f5:	75 1a                	jne    f0102411 <envid2env+0x29>
		*env_store = curenv;
f01023f7:	e8 06 31 00 00       	call   f0105502 <cpunum>
f01023fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01023ff:	8b 80 28 a0 23 f0    	mov    -0xfdc5fd8(%eax),%eax
f0102405:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102408:	89 01                	mov    %eax,(%ecx)
		return 0;
f010240a:	b8 00 00 00 00       	mov    $0x0,%eax
f010240f:	eb 70                	jmp    f0102481 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102411:	89 c3                	mov    %eax,%ebx
f0102413:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102419:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f010241c:	03 1d 60 92 23 f0    	add    0xf0239260,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102422:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102426:	74 05                	je     f010242d <envid2env+0x45>
f0102428:	3b 43 48             	cmp    0x48(%ebx),%eax
f010242b:	74 10                	je     f010243d <envid2env+0x55>
		*env_store = 0;
f010242d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102430:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102436:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010243b:	eb 44                	jmp    f0102481 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010243d:	84 d2                	test   %dl,%dl
f010243f:	74 36                	je     f0102477 <envid2env+0x8f>
f0102441:	e8 bc 30 00 00       	call   f0105502 <cpunum>
f0102446:	6b c0 74             	imul   $0x74,%eax,%eax
f0102449:	3b 98 28 a0 23 f0    	cmp    -0xfdc5fd8(%eax),%ebx
f010244f:	74 26                	je     f0102477 <envid2env+0x8f>
f0102451:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102454:	e8 a9 30 00 00       	call   f0105502 <cpunum>
f0102459:	6b c0 74             	imul   $0x74,%eax,%eax
f010245c:	8b 80 28 a0 23 f0    	mov    -0xfdc5fd8(%eax),%eax
f0102462:	3b 70 48             	cmp    0x48(%eax),%esi
f0102465:	74 10                	je     f0102477 <envid2env+0x8f>
		*env_store = 0;
f0102467:	8b 45 0c             	mov    0xc(%ebp),%eax
f010246a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102470:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102475:	eb 0a                	jmp    f0102481 <envid2env+0x99>
	}

	*env_store = e;
f0102477:	8b 45 0c             	mov    0xc(%ebp),%eax
f010247a:	89 18                	mov    %ebx,(%eax)
	return 0;
f010247c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102481:	5b                   	pop    %ebx
f0102482:	5e                   	pop    %esi
f0102483:	5d                   	pop    %ebp
f0102484:	c3                   	ret    

f0102485 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102485:	55                   	push   %ebp
f0102486:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102488:	b8 00 f3 11 f0       	mov    $0xf011f300,%eax
f010248d:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102490:	b8 23 00 00 00       	mov    $0x23,%eax
f0102495:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102497:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102499:	b8 10 00 00 00       	mov    $0x10,%eax
f010249e:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01024a0:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01024a2:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01024a4:	ea ab 24 10 f0 08 00 	ljmp   $0x8,$0xf01024ab
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01024ab:	b8 00 00 00 00       	mov    $0x0,%eax
f01024b0:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01024b3:	5d                   	pop    %ebp
f01024b4:	c3                   	ret    

f01024b5 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01024b5:	55                   	push   %ebp
f01024b6:	89 e5                	mov    %esp,%ebp
f01024b8:	56                   	push   %esi
f01024b9:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.

    int temp = 0;
    env_free_list = NULL;
f01024ba:	c7 05 64 92 23 f0 00 	movl   $0x0,0xf0239264
f01024c1:	00 00 00 
    cprintf("NENV -1 : %u\n", NENV -1);
f01024c4:	83 ec 08             	sub    $0x8,%esp
f01024c7:	68 ff 03 00 00       	push   $0x3ff
f01024cc:	68 d3 69 10 f0       	push   $0xf01069d3
f01024d1:	e8 e2 07 00 00       	call   f0102cb8 <cprintf>

    for (temp = NENV -1; temp >= 0; temp--)
    {
        envs[temp].env_id = 0;
f01024d6:	8b 35 60 92 23 f0    	mov    0xf0239260,%esi
f01024dc:	8b 15 64 92 23 f0    	mov    0xf0239264,%edx
f01024e2:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f01024e8:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f01024eb:	83 c4 10             	add    $0x10,%esp
f01024ee:	89 c1                	mov    %eax,%ecx
f01024f0:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
        envs[temp].env_parent_id = 0;
f01024f7:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
        envs[temp].env_type = ENV_TYPE_USER;
f01024fe:	c7 40 50 00 00 00 00 	movl   $0x0,0x50(%eax)
        envs[temp].env_status = ENV_FREE;
f0102505:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
        envs[temp].env_runs = 0;
f010250c:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
        envs[temp].env_pgdir = NULL;
f0102513:	c7 40 60 00 00 00 00 	movl   $0x0,0x60(%eax)
        envs[temp].env_link = env_free_list;
f010251a:	89 50 44             	mov    %edx,0x44(%eax)
f010251d:	83 e8 7c             	sub    $0x7c,%eax
        env_free_list = &envs[temp];
f0102520:	89 ca                	mov    %ecx,%edx

    int temp = 0;
    env_free_list = NULL;
    cprintf("NENV -1 : %u\n", NENV -1);

    for (temp = NENV -1; temp >= 0; temp--)
f0102522:	39 d8                	cmp    %ebx,%eax
f0102524:	75 c8                	jne    f01024ee <env_init+0x39>
f0102526:	89 35 64 92 23 f0    	mov    %esi,0xf0239264
        envs[temp].env_pgdir = NULL;
        envs[temp].env_link = env_free_list;
        env_free_list = &envs[temp];
    }

    cprintf("env_free_list : 0x%08x, & envs[temp]: 0x%08x\n", env_free_list, &envs[temp]);
f010252c:	83 ec 04             	sub    $0x4,%esp
f010252f:	a1 60 92 23 f0       	mov    0xf0239260,%eax
f0102534:	83 e8 7c             	sub    $0x7c,%eax
f0102537:	50                   	push   %eax
f0102538:	56                   	push   %esi
f0102539:	68 28 6a 10 f0       	push   $0xf0106a28
f010253e:	e8 75 07 00 00       	call   f0102cb8 <cprintf>

	// Per-CPU part of the initialization
	env_init_percpu();
f0102543:	e8 3d ff ff ff       	call   f0102485 <env_init_percpu>
}
f0102548:	83 c4 10             	add    $0x10,%esp
f010254b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010254e:	5b                   	pop    %ebx
f010254f:	5e                   	pop    %esi
f0102550:	5d                   	pop    %ebp
f0102551:	c3                   	ret    

f0102552 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102552:	55                   	push   %ebp
f0102553:	89 e5                	mov    %esp,%ebp
f0102555:	57                   	push   %edi
f0102556:	56                   	push   %esi
f0102557:	53                   	push   %ebx
f0102558:	83 ec 0c             	sub    $0xc,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010255b:	8b 1d 64 92 23 f0    	mov    0xf0239264,%ebx
f0102561:	85 db                	test   %ebx,%ebx
f0102563:	0f 84 64 01 00 00    	je     f01026cd <env_alloc+0x17b>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102569:	83 ec 0c             	sub    $0xc,%esp
f010256c:	6a 01                	push   $0x1
f010256e:	e8 19 e7 ff ff       	call   f0100c8c <page_alloc>
f0102573:	83 c4 10             	add    $0x10,%esp
f0102576:	85 c0                	test   %eax,%eax
f0102578:	0f 84 56 01 00 00    	je     f01026d4 <env_alloc+0x182>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
    (p->pp_ref)++;
f010257e:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102583:	2b 05 30 9f 23 f0    	sub    0xf0239f30,%eax
f0102589:	89 c6                	mov    %eax,%esi
f010258b:	c1 fe 03             	sar    $0x3,%esi
f010258e:	c1 e6 0c             	shl    $0xc,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102591:	89 f0                	mov    %esi,%eax
f0102593:	c1 e8 0c             	shr    $0xc,%eax
f0102596:	3b 05 28 9f 23 f0    	cmp    0xf0239f28,%eax
f010259c:	72 12                	jb     f01025b0 <env_alloc+0x5e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010259e:	56                   	push   %esi
f010259f:	68 c4 5b 10 f0       	push   $0xf0105bc4
f01025a4:	6a 58                	push   $0x58
f01025a6:	68 e9 66 10 f0       	push   $0xf01066e9
f01025ab:	e8 90 da ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01025b0:	8d be 00 00 00 f0    	lea    -0x10000000(%esi),%edi
    pde_t* page_dir = page2kva(p);
    memcpy(page_dir, kern_pgdir, PGSIZE);
f01025b6:	83 ec 04             	sub    $0x4,%esp
f01025b9:	68 00 10 00 00       	push   $0x1000
f01025be:	ff 35 2c 9f 23 f0    	pushl  0xf0239f2c
f01025c4:	57                   	push   %edi
f01025c5:	e8 cb 29 00 00       	call   f0104f95 <memcpy>
    e->env_pgdir = page_dir;
f01025ca:	89 7b 60             	mov    %edi,0x60(%ebx)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025cd:	83 c4 10             	add    $0x10,%esp
f01025d0:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f01025d6:	77 15                	ja     f01025ed <env_alloc+0x9b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025d8:	57                   	push   %edi
f01025d9:	68 e8 5b 10 f0       	push   $0xf0105be8
f01025de:	68 d2 00 00 00       	push   $0xd2
f01025e3:	68 c8 69 10 f0       	push   $0xf01069c8
f01025e8:	e8 53 da ff ff       	call   f0100040 <_panic>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01025ed:	83 ce 05             	or     $0x5,%esi
f01025f0:	89 b7 f4 0e 00 00    	mov    %esi,0xef4(%edi)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01025f6:	8b 43 48             	mov    0x48(%ebx),%eax
f01025f9:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01025fe:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102603:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102608:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010260b:	89 da                	mov    %ebx,%edx
f010260d:	2b 15 60 92 23 f0    	sub    0xf0239260,%edx
f0102613:	c1 fa 02             	sar    $0x2,%edx
f0102616:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f010261c:	09 d0                	or     %edx,%eax
f010261e:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102621:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102624:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102627:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010262e:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102635:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010263c:	83 ec 04             	sub    $0x4,%esp
f010263f:	6a 44                	push   $0x44
f0102641:	6a 00                	push   $0x0
f0102643:	53                   	push   %ebx
f0102644:	e8 97 28 00 00       	call   f0104ee0 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102649:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010264f:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102655:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010265b:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102662:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
    e->env_tf.tf_eflags |= FL_IF;
f0102668:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f010266f:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0102676:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f010267a:	8b 43 44             	mov    0x44(%ebx),%eax
f010267d:	a3 64 92 23 f0       	mov    %eax,0xf0239264
	*newenv_store = e;
f0102682:	8b 45 08             	mov    0x8(%ebp),%eax
f0102685:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102687:	8b 5b 48             	mov    0x48(%ebx),%ebx
f010268a:	e8 73 2e 00 00       	call   f0105502 <cpunum>
f010268f:	6b c0 74             	imul   $0x74,%eax,%eax
f0102692:	83 c4 10             	add    $0x10,%esp
f0102695:	ba 00 00 00 00       	mov    $0x0,%edx
f010269a:	83 b8 28 a0 23 f0 00 	cmpl   $0x0,-0xfdc5fd8(%eax)
f01026a1:	74 11                	je     f01026b4 <env_alloc+0x162>
f01026a3:	e8 5a 2e 00 00       	call   f0105502 <cpunum>
f01026a8:	6b c0 74             	imul   $0x74,%eax,%eax
f01026ab:	8b 80 28 a0 23 f0    	mov    -0xfdc5fd8(%eax),%eax
f01026b1:	8b 50 48             	mov    0x48(%eax),%edx
f01026b4:	83 ec 04             	sub    $0x4,%esp
f01026b7:	53                   	push   %ebx
f01026b8:	52                   	push   %edx
f01026b9:	68 e1 69 10 f0       	push   $0xf01069e1
f01026be:	e8 f5 05 00 00       	call   f0102cb8 <cprintf>
	return 0;
f01026c3:	83 c4 10             	add    $0x10,%esp
f01026c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01026cb:	eb 0c                	jmp    f01026d9 <env_alloc+0x187>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01026cd:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01026d2:	eb 05                	jmp    f01026d9 <env_alloc+0x187>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01026d4:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01026d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01026dc:	5b                   	pop    %ebx
f01026dd:	5e                   	pop    %esi
f01026de:	5f                   	pop    %edi
f01026df:	5d                   	pop    %ebp
f01026e0:	c3                   	ret    

f01026e1 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01026e1:	55                   	push   %ebp
f01026e2:	89 e5                	mov    %esp,%ebp
f01026e4:	57                   	push   %edi
f01026e5:	56                   	push   %esi
f01026e6:	53                   	push   %ebx
f01026e7:	83 ec 34             	sub    $0x34,%esp
f01026ea:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
    int ret = 0;
    struct Env *e = NULL;
f01026ed:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    ret = env_alloc(&e, 0);
f01026f4:	6a 00                	push   $0x0
f01026f6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01026f9:	50                   	push   %eax
f01026fa:	e8 53 fe ff ff       	call   f0102552 <env_alloc>

    if(ret < 0)
f01026ff:	83 c4 10             	add    $0x10,%esp
f0102702:	85 c0                	test   %eax,%eax
f0102704:	79 15                	jns    f010271b <env_create+0x3a>
    {
        panic("env_create: %e\n", ret);
f0102706:	50                   	push   %eax
f0102707:	68 f6 69 10 f0       	push   $0xf01069f6
f010270c:	68 be 01 00 00       	push   $0x1be
f0102711:	68 c8 69 10 f0       	push   $0xf01069c8
f0102716:	e8 25 d9 ff ff       	call   f0100040 <_panic>
    }

    load_icode(e, binary);
f010271b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010271e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// LAB 3: Your code here.

    struct Elf* elfhdr = (struct Elf *)binary;
    struct Proghdr *ph, *eph;
    
    if(elfhdr->e_magic != ELF_MAGIC)
f0102721:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102727:	74 17                	je     f0102740 <env_create+0x5f>
    {
        panic("elf header's magic is not correct\n");
f0102729:	83 ec 04             	sub    $0x4,%esp
f010272c:	68 58 6a 10 f0       	push   $0xf0106a58
f0102731:	68 86 01 00 00       	push   $0x186
f0102736:	68 c8 69 10 f0       	push   $0xf01069c8
f010273b:	e8 00 d9 ff ff       	call   f0100040 <_panic>
    }

    ph = (struct Proghdr *)((uint8_t *)elfhdr + elfhdr->e_phoff);
f0102740:	89 fb                	mov    %edi,%ebx
f0102742:	03 5f 1c             	add    0x1c(%edi),%ebx

    eph = ph + elfhdr->e_phnum;
f0102745:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0102749:	c1 e6 05             	shl    $0x5,%esi
f010274c:	01 de                	add    %ebx,%esi

    lcr3(PADDR(e->env_pgdir));
f010274e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102751:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102754:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102759:	77 15                	ja     f0102770 <env_create+0x8f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010275b:	50                   	push   %eax
f010275c:	68 e8 5b 10 f0       	push   $0xf0105be8
f0102761:	68 8d 01 00 00       	push   $0x18d
f0102766:	68 c8 69 10 f0       	push   $0xf01069c8
f010276b:	e8 d0 d8 ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102770:	05 00 00 00 10       	add    $0x10000000,%eax
f0102775:	0f 22 d8             	mov    %eax,%cr3
f0102778:	eb 60                	jmp    f01027da <env_create+0xf9>

    for(;ph < eph; ph++)
    {
        if(ph->p_type != ELF_PROG_LOAD)
f010277a:	83 3b 01             	cmpl   $0x1,(%ebx)
f010277d:	75 58                	jne    f01027d7 <env_create+0xf6>
        {
            continue;
        }

        if(ph->p_filesz > ph->p_memsz)
f010277f:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0102782:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0102785:	76 17                	jbe    f010279e <env_create+0xbd>
        {
            panic("file size is great than memory size\n");
f0102787:	83 ec 04             	sub    $0x4,%esp
f010278a:	68 7c 6a 10 f0       	push   $0xf0106a7c
f010278f:	68 98 01 00 00       	push   $0x198
f0102794:	68 c8 69 10 f0       	push   $0xf01069c8
f0102799:	e8 a2 d8 ff ff       	call   f0100040 <_panic>
        }

        region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f010279e:	8b 53 08             	mov    0x8(%ebx),%edx
f01027a1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01027a4:	e8 b4 fb ff ff       	call   f010235d <region_alloc>
        memmove((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f01027a9:	83 ec 04             	sub    $0x4,%esp
f01027ac:	ff 73 10             	pushl  0x10(%ebx)
f01027af:	89 f8                	mov    %edi,%eax
f01027b1:	03 43 04             	add    0x4(%ebx),%eax
f01027b4:	50                   	push   %eax
f01027b5:	ff 73 08             	pushl  0x8(%ebx)
f01027b8:	e8 70 27 00 00       	call   f0104f2d <memmove>

        memset((void *)ph->p_va + ph->p_filesz, 0, (ph->p_memsz - ph->p_filesz));
f01027bd:	8b 43 10             	mov    0x10(%ebx),%eax
f01027c0:	83 c4 0c             	add    $0xc,%esp
f01027c3:	8b 53 14             	mov    0x14(%ebx),%edx
f01027c6:	29 c2                	sub    %eax,%edx
f01027c8:	52                   	push   %edx
f01027c9:	6a 00                	push   $0x0
f01027cb:	03 43 08             	add    0x8(%ebx),%eax
f01027ce:	50                   	push   %eax
f01027cf:	e8 0c 27 00 00       	call   f0104ee0 <memset>
f01027d4:	83 c4 10             	add    $0x10,%esp

    eph = ph + elfhdr->e_phnum;

    lcr3(PADDR(e->env_pgdir));

    for(;ph < eph; ph++)
f01027d7:	83 c3 20             	add    $0x20,%ebx
f01027da:	39 de                	cmp    %ebx,%esi
f01027dc:	77 9c                	ja     f010277a <env_create+0x99>
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.

    lcr3(PADDR(kern_pgdir));
f01027de:	a1 2c 9f 23 f0       	mov    0xf0239f2c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027e3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01027e8:	77 15                	ja     f01027ff <env_create+0x11e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027ea:	50                   	push   %eax
f01027eb:	68 e8 5b 10 f0       	push   $0xf0105be8
f01027f0:	68 a6 01 00 00       	push   $0x1a6
f01027f5:	68 c8 69 10 f0       	push   $0xf01069c8
f01027fa:	e8 41 d8 ff ff       	call   f0100040 <_panic>
f01027ff:	05 00 00 00 10       	add    $0x10000000,%eax
f0102804:	0f 22 d8             	mov    %eax,%cr3

    e->env_tf.tf_eip = elfhdr->e_entry;
f0102807:	8b 47 18             	mov    0x18(%edi),%eax
f010280a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010280d:	89 47 30             	mov    %eax,0x30(%edi)

    region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0102810:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0102815:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010281a:	89 f8                	mov    %edi,%eax
f010281c:	e8 3c fb ff ff       	call   f010235d <region_alloc>
    {
        panic("env_create: %e\n", ret);
    }

    load_icode(e, binary);
    e->env_type = type;
f0102821:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102824:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102827:	89 50 50             	mov    %edx,0x50(%eax)
}
f010282a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010282d:	5b                   	pop    %ebx
f010282e:	5e                   	pop    %esi
f010282f:	5f                   	pop    %edi
f0102830:	5d                   	pop    %ebp
f0102831:	c3                   	ret    

f0102832 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0102832:	55                   	push   %ebp
f0102833:	89 e5                	mov    %esp,%ebp
f0102835:	57                   	push   %edi
f0102836:	56                   	push   %esi
f0102837:	53                   	push   %ebx
f0102838:	83 ec 1c             	sub    $0x1c,%esp
f010283b:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010283e:	e8 bf 2c 00 00       	call   f0105502 <cpunum>
f0102843:	6b c0 74             	imul   $0x74,%eax,%eax
f0102846:	39 b8 28 a0 23 f0    	cmp    %edi,-0xfdc5fd8(%eax)
f010284c:	75 29                	jne    f0102877 <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f010284e:	a1 2c 9f 23 f0       	mov    0xf0239f2c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102853:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102858:	77 15                	ja     f010286f <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010285a:	50                   	push   %eax
f010285b:	68 e8 5b 10 f0       	push   $0xf0105be8
f0102860:	68 d3 01 00 00       	push   $0x1d3
f0102865:	68 c8 69 10 f0       	push   $0xf01069c8
f010286a:	e8 d1 d7 ff ff       	call   f0100040 <_panic>
f010286f:	05 00 00 00 10       	add    $0x10000000,%eax
f0102874:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102877:	8b 5f 48             	mov    0x48(%edi),%ebx
f010287a:	e8 83 2c 00 00       	call   f0105502 <cpunum>
f010287f:	6b c0 74             	imul   $0x74,%eax,%eax
f0102882:	ba 00 00 00 00       	mov    $0x0,%edx
f0102887:	83 b8 28 a0 23 f0 00 	cmpl   $0x0,-0xfdc5fd8(%eax)
f010288e:	74 11                	je     f01028a1 <env_free+0x6f>
f0102890:	e8 6d 2c 00 00       	call   f0105502 <cpunum>
f0102895:	6b c0 74             	imul   $0x74,%eax,%eax
f0102898:	8b 80 28 a0 23 f0    	mov    -0xfdc5fd8(%eax),%eax
f010289e:	8b 50 48             	mov    0x48(%eax),%edx
f01028a1:	83 ec 04             	sub    $0x4,%esp
f01028a4:	53                   	push   %ebx
f01028a5:	52                   	push   %edx
f01028a6:	68 06 6a 10 f0       	push   $0xf0106a06
f01028ab:	e8 08 04 00 00       	call   f0102cb8 <cprintf>
f01028b0:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01028b3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01028ba:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01028bd:	89 d0                	mov    %edx,%eax
f01028bf:	c1 e0 02             	shl    $0x2,%eax
f01028c2:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01028c5:	8b 47 60             	mov    0x60(%edi),%eax
f01028c8:	8b 34 90             	mov    (%eax,%edx,4),%esi
f01028cb:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01028d1:	0f 84 a8 00 00 00    	je     f010297f <env_free+0x14d>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01028d7:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01028dd:	89 f0                	mov    %esi,%eax
f01028df:	c1 e8 0c             	shr    $0xc,%eax
f01028e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01028e5:	39 05 28 9f 23 f0    	cmp    %eax,0xf0239f28
f01028eb:	77 15                	ja     f0102902 <env_free+0xd0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01028ed:	56                   	push   %esi
f01028ee:	68 c4 5b 10 f0       	push   $0xf0105bc4
f01028f3:	68 e2 01 00 00       	push   $0x1e2
f01028f8:	68 c8 69 10 f0       	push   $0xf01069c8
f01028fd:	e8 3e d7 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102902:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102905:	c1 e0 16             	shl    $0x16,%eax
f0102908:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010290b:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0102910:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0102917:	01 
f0102918:	74 17                	je     f0102931 <env_free+0xff>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010291a:	83 ec 08             	sub    $0x8,%esp
f010291d:	89 d8                	mov    %ebx,%eax
f010291f:	c1 e0 0c             	shl    $0xc,%eax
f0102922:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102925:	50                   	push   %eax
f0102926:	ff 77 60             	pushl  0x60(%edi)
f0102929:	e8 9f e5 ff ff       	call   f0100ecd <page_remove>
f010292e:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102931:	83 c3 01             	add    $0x1,%ebx
f0102934:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010293a:	75 d4                	jne    f0102910 <env_free+0xde>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010293c:	8b 47 60             	mov    0x60(%edi),%eax
f010293f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102942:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102949:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010294c:	3b 05 28 9f 23 f0    	cmp    0xf0239f28,%eax
f0102952:	72 14                	jb     f0102968 <env_free+0x136>
		panic("pa2page called with invalid pa");
f0102954:	83 ec 04             	sub    $0x4,%esp
f0102957:	68 1c 61 10 f0       	push   $0xf010611c
f010295c:	6a 51                	push   $0x51
f010295e:	68 e9 66 10 f0       	push   $0xf01066e9
f0102963:	e8 d8 d6 ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f0102968:	83 ec 0c             	sub    $0xc,%esp
f010296b:	a1 30 9f 23 f0       	mov    0xf0239f30,%eax
f0102970:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102973:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0102976:	50                   	push   %eax
f0102977:	e8 b7 e3 ff ff       	call   f0100d33 <page_decref>
f010297c:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010297f:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0102983:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102986:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f010298b:	0f 85 29 ff ff ff    	jne    f01028ba <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0102991:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102994:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102999:	77 15                	ja     f01029b0 <env_free+0x17e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010299b:	50                   	push   %eax
f010299c:	68 e8 5b 10 f0       	push   $0xf0105be8
f01029a1:	68 f0 01 00 00       	push   $0x1f0
f01029a6:	68 c8 69 10 f0       	push   $0xf01069c8
f01029ab:	e8 90 d6 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f01029b0:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01029b7:	05 00 00 00 10       	add    $0x10000000,%eax
f01029bc:	c1 e8 0c             	shr    $0xc,%eax
f01029bf:	3b 05 28 9f 23 f0    	cmp    0xf0239f28,%eax
f01029c5:	72 14                	jb     f01029db <env_free+0x1a9>
		panic("pa2page called with invalid pa");
f01029c7:	83 ec 04             	sub    $0x4,%esp
f01029ca:	68 1c 61 10 f0       	push   $0xf010611c
f01029cf:	6a 51                	push   $0x51
f01029d1:	68 e9 66 10 f0       	push   $0xf01066e9
f01029d6:	e8 65 d6 ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f01029db:	83 ec 0c             	sub    $0xc,%esp
f01029de:	8b 15 30 9f 23 f0    	mov    0xf0239f30,%edx
f01029e4:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01029e7:	50                   	push   %eax
f01029e8:	e8 46 e3 ff ff       	call   f0100d33 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01029ed:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01029f4:	a1 64 92 23 f0       	mov    0xf0239264,%eax
f01029f9:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01029fc:	89 3d 64 92 23 f0    	mov    %edi,0xf0239264
}
f0102a02:	83 c4 10             	add    $0x10,%esp
f0102a05:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102a08:	5b                   	pop    %ebx
f0102a09:	5e                   	pop    %esi
f0102a0a:	5f                   	pop    %edi
f0102a0b:	5d                   	pop    %ebp
f0102a0c:	c3                   	ret    

f0102a0d <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0102a0d:	55                   	push   %ebp
f0102a0e:	89 e5                	mov    %esp,%ebp
f0102a10:	53                   	push   %ebx
f0102a11:	83 ec 04             	sub    $0x4,%esp
f0102a14:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0102a17:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0102a1b:	75 19                	jne    f0102a36 <env_destroy+0x29>
f0102a1d:	e8 e0 2a 00 00       	call   f0105502 <cpunum>
f0102a22:	6b c0 74             	imul   $0x74,%eax,%eax
f0102a25:	3b 98 28 a0 23 f0    	cmp    -0xfdc5fd8(%eax),%ebx
f0102a2b:	74 09                	je     f0102a36 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0102a2d:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0102a34:	eb 33                	jmp    f0102a69 <env_destroy+0x5c>
	}

	env_free(e);
f0102a36:	83 ec 0c             	sub    $0xc,%esp
f0102a39:	53                   	push   %ebx
f0102a3a:	e8 f3 fd ff ff       	call   f0102832 <env_free>

	if (curenv == e) {
f0102a3f:	e8 be 2a 00 00       	call   f0105502 <cpunum>
f0102a44:	6b c0 74             	imul   $0x74,%eax,%eax
f0102a47:	83 c4 10             	add    $0x10,%esp
f0102a4a:	3b 98 28 a0 23 f0    	cmp    -0xfdc5fd8(%eax),%ebx
f0102a50:	75 17                	jne    f0102a69 <env_destroy+0x5c>
		curenv = NULL;
f0102a52:	e8 ab 2a 00 00       	call   f0105502 <cpunum>
f0102a57:	6b c0 74             	imul   $0x74,%eax,%eax
f0102a5a:	c7 80 28 a0 23 f0 00 	movl   $0x0,-0xfdc5fd8(%eax)
f0102a61:	00 00 00 
		sched_yield();
f0102a64:	e8 7d 14 00 00       	call   f0103ee6 <sched_yield>
	}
}
f0102a69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102a6c:	c9                   	leave  
f0102a6d:	c3                   	ret    

f0102a6e <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102a6e:	55                   	push   %ebp
f0102a6f:	89 e5                	mov    %esp,%ebp
f0102a71:	53                   	push   %ebx
f0102a72:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0102a75:	e8 88 2a 00 00       	call   f0105502 <cpunum>
f0102a7a:	6b c0 74             	imul   $0x74,%eax,%eax
f0102a7d:	8b 98 28 a0 23 f0    	mov    -0xfdc5fd8(%eax),%ebx
f0102a83:	e8 7a 2a 00 00       	call   f0105502 <cpunum>
f0102a88:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0102a8b:	8b 65 08             	mov    0x8(%ebp),%esp
f0102a8e:	61                   	popa   
f0102a8f:	07                   	pop    %es
f0102a90:	1f                   	pop    %ds
f0102a91:	83 c4 08             	add    $0x8,%esp
f0102a94:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102a95:	83 ec 04             	sub    $0x4,%esp
f0102a98:	68 1c 6a 10 f0       	push   $0xf0106a1c
f0102a9d:	68 26 02 00 00       	push   $0x226
f0102aa2:	68 c8 69 10 f0       	push   $0xf01069c8
f0102aa7:	e8 94 d5 ff ff       	call   f0100040 <_panic>

f0102aac <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0102aac:	55                   	push   %ebp
f0102aad:	89 e5                	mov    %esp,%ebp
f0102aaf:	53                   	push   %ebx
f0102ab0:	83 ec 04             	sub    $0x4,%esp
f0102ab3:	8b 5d 08             	mov    0x8(%ebp),%ebx

	// LAB 3: Your code here.

	//panic("env_run not yet implemented");

    if(curenv && curenv->env_status == ENV_RUNNING)
f0102ab6:	e8 47 2a 00 00       	call   f0105502 <cpunum>
f0102abb:	6b c0 74             	imul   $0x74,%eax,%eax
f0102abe:	83 b8 28 a0 23 f0 00 	cmpl   $0x0,-0xfdc5fd8(%eax)
f0102ac5:	74 29                	je     f0102af0 <env_run+0x44>
f0102ac7:	e8 36 2a 00 00       	call   f0105502 <cpunum>
f0102acc:	6b c0 74             	imul   $0x74,%eax,%eax
f0102acf:	8b 80 28 a0 23 f0    	mov    -0xfdc5fd8(%eax),%eax
f0102ad5:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0102ad9:	75 15                	jne    f0102af0 <env_run+0x44>
    {
        curenv->env_status = ENV_RUNNABLE;
f0102adb:	e8 22 2a 00 00       	call   f0105502 <cpunum>
f0102ae0:	6b c0 74             	imul   $0x74,%eax,%eax
f0102ae3:	8b 80 28 a0 23 f0    	mov    -0xfdc5fd8(%eax),%eax
f0102ae9:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
    }

    curenv = e;
f0102af0:	e8 0d 2a 00 00       	call   f0105502 <cpunum>
f0102af5:	6b c0 74             	imul   $0x74,%eax,%eax
f0102af8:	89 98 28 a0 23 f0    	mov    %ebx,-0xfdc5fd8(%eax)
    e->env_status = ENV_RUNNING;
f0102afe:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
    e->env_runs++;
f0102b05:	83 43 58 01          	addl   $0x1,0x58(%ebx)

    lcr3(PADDR(e->env_pgdir));
f0102b09:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b0c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b11:	77 15                	ja     f0102b28 <env_run+0x7c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b13:	50                   	push   %eax
f0102b14:	68 e8 5b 10 f0       	push   $0xf0105be8
f0102b19:	68 50 02 00 00       	push   $0x250
f0102b1e:	68 c8 69 10 f0       	push   $0xf01069c8
f0102b23:	e8 18 d5 ff ff       	call   f0100040 <_panic>
f0102b28:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b2d:	0f 22 d8             	mov    %eax,%cr3

// LAB 2: Your code here.
    env_pop_tf(&(e->env_tf));
f0102b30:	83 ec 0c             	sub    $0xc,%esp
f0102b33:	53                   	push   %ebx
f0102b34:	e8 35 ff ff ff       	call   f0102a6e <env_pop_tf>

f0102b39 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102b39:	55                   	push   %ebp
f0102b3a:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102b3c:	ba 70 00 00 00       	mov    $0x70,%edx
f0102b41:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b44:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102b45:	ba 71 00 00 00       	mov    $0x71,%edx
f0102b4a:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102b4b:	0f b6 c0             	movzbl %al,%eax
}
f0102b4e:	5d                   	pop    %ebp
f0102b4f:	c3                   	ret    

f0102b50 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102b50:	55                   	push   %ebp
f0102b51:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102b53:	ba 70 00 00 00       	mov    $0x70,%edx
f0102b58:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b5b:	ee                   	out    %al,(%dx)
f0102b5c:	ba 71 00 00 00       	mov    $0x71,%edx
f0102b61:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102b64:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102b65:	5d                   	pop    %ebp
f0102b66:	c3                   	ret    

f0102b67 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0102b67:	55                   	push   %ebp
f0102b68:	89 e5                	mov    %esp,%ebp
f0102b6a:	56                   	push   %esi
f0102b6b:	53                   	push   %ebx
f0102b6c:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0102b6f:	66 a3 88 f3 11 f0    	mov    %ax,0xf011f388
	if (!didinit)
f0102b75:	80 3d 68 92 23 f0 00 	cmpb   $0x0,0xf0239268
f0102b7c:	74 5a                	je     f0102bd8 <irq_setmask_8259A+0x71>
f0102b7e:	89 c6                	mov    %eax,%esi
f0102b80:	ba 21 00 00 00       	mov    $0x21,%edx
f0102b85:	ee                   	out    %al,(%dx)
f0102b86:	66 c1 e8 08          	shr    $0x8,%ax
f0102b8a:	ba a1 00 00 00       	mov    $0xa1,%edx
f0102b8f:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0102b90:	83 ec 0c             	sub    $0xc,%esp
f0102b93:	68 a1 6a 10 f0       	push   $0xf0106aa1
f0102b98:	e8 1b 01 00 00       	call   f0102cb8 <cprintf>
f0102b9d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0102ba0:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0102ba5:	0f b7 f6             	movzwl %si,%esi
f0102ba8:	f7 d6                	not    %esi
f0102baa:	0f a3 de             	bt     %ebx,%esi
f0102bad:	73 11                	jae    f0102bc0 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0102baf:	83 ec 08             	sub    $0x8,%esp
f0102bb2:	53                   	push   %ebx
f0102bb3:	68 4f 70 10 f0       	push   $0xf010704f
f0102bb8:	e8 fb 00 00 00       	call   f0102cb8 <cprintf>
f0102bbd:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0102bc0:	83 c3 01             	add    $0x1,%ebx
f0102bc3:	83 fb 10             	cmp    $0x10,%ebx
f0102bc6:	75 e2                	jne    f0102baa <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0102bc8:	83 ec 0c             	sub    $0xc,%esp
f0102bcb:	68 3c 5f 10 f0       	push   $0xf0105f3c
f0102bd0:	e8 e3 00 00 00       	call   f0102cb8 <cprintf>
f0102bd5:	83 c4 10             	add    $0x10,%esp
}
f0102bd8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0102bdb:	5b                   	pop    %ebx
f0102bdc:	5e                   	pop    %esi
f0102bdd:	5d                   	pop    %ebp
f0102bde:	c3                   	ret    

f0102bdf <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0102bdf:	c6 05 68 92 23 f0 01 	movb   $0x1,0xf0239268
f0102be6:	ba 21 00 00 00       	mov    $0x21,%edx
f0102beb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102bf0:	ee                   	out    %al,(%dx)
f0102bf1:	ba a1 00 00 00       	mov    $0xa1,%edx
f0102bf6:	ee                   	out    %al,(%dx)
f0102bf7:	ba 20 00 00 00       	mov    $0x20,%edx
f0102bfc:	b8 11 00 00 00       	mov    $0x11,%eax
f0102c01:	ee                   	out    %al,(%dx)
f0102c02:	ba 21 00 00 00       	mov    $0x21,%edx
f0102c07:	b8 20 00 00 00       	mov    $0x20,%eax
f0102c0c:	ee                   	out    %al,(%dx)
f0102c0d:	b8 04 00 00 00       	mov    $0x4,%eax
f0102c12:	ee                   	out    %al,(%dx)
f0102c13:	b8 03 00 00 00       	mov    $0x3,%eax
f0102c18:	ee                   	out    %al,(%dx)
f0102c19:	ba a0 00 00 00       	mov    $0xa0,%edx
f0102c1e:	b8 11 00 00 00       	mov    $0x11,%eax
f0102c23:	ee                   	out    %al,(%dx)
f0102c24:	ba a1 00 00 00       	mov    $0xa1,%edx
f0102c29:	b8 28 00 00 00       	mov    $0x28,%eax
f0102c2e:	ee                   	out    %al,(%dx)
f0102c2f:	b8 02 00 00 00       	mov    $0x2,%eax
f0102c34:	ee                   	out    %al,(%dx)
f0102c35:	b8 01 00 00 00       	mov    $0x1,%eax
f0102c3a:	ee                   	out    %al,(%dx)
f0102c3b:	ba 20 00 00 00       	mov    $0x20,%edx
f0102c40:	b8 68 00 00 00       	mov    $0x68,%eax
f0102c45:	ee                   	out    %al,(%dx)
f0102c46:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102c4b:	ee                   	out    %al,(%dx)
f0102c4c:	ba a0 00 00 00       	mov    $0xa0,%edx
f0102c51:	b8 68 00 00 00       	mov    $0x68,%eax
f0102c56:	ee                   	out    %al,(%dx)
f0102c57:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102c5c:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0102c5d:	0f b7 05 88 f3 11 f0 	movzwl 0xf011f388,%eax
f0102c64:	66 83 f8 ff          	cmp    $0xffff,%ax
f0102c68:	74 13                	je     f0102c7d <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0102c6a:	55                   	push   %ebp
f0102c6b:	89 e5                	mov    %esp,%ebp
f0102c6d:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0102c70:	0f b7 c0             	movzwl %ax,%eax
f0102c73:	50                   	push   %eax
f0102c74:	e8 ee fe ff ff       	call   f0102b67 <irq_setmask_8259A>
f0102c79:	83 c4 10             	add    $0x10,%esp
}
f0102c7c:	c9                   	leave  
f0102c7d:	f3 c3                	repz ret 

f0102c7f <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102c7f:	55                   	push   %ebp
f0102c80:	89 e5                	mov    %esp,%ebp
f0102c82:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102c85:	ff 75 08             	pushl  0x8(%ebp)
f0102c88:	e8 b1 da ff ff       	call   f010073e <cputchar>
	*cnt++;
}
f0102c8d:	83 c4 10             	add    $0x10,%esp
f0102c90:	c9                   	leave  
f0102c91:	c3                   	ret    

f0102c92 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102c92:	55                   	push   %ebp
f0102c93:	89 e5                	mov    %esp,%ebp
f0102c95:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102c98:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102c9f:	ff 75 0c             	pushl  0xc(%ebp)
f0102ca2:	ff 75 08             	pushl  0x8(%ebp)
f0102ca5:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102ca8:	50                   	push   %eax
f0102ca9:	68 7f 2c 10 f0       	push   $0xf0102c7f
f0102cae:	e8 aa 1b 00 00       	call   f010485d <vprintfmt>
	return cnt;
}
f0102cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102cb6:	c9                   	leave  
f0102cb7:	c3                   	ret    

f0102cb8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102cb8:	55                   	push   %ebp
f0102cb9:	89 e5                	mov    %esp,%ebp
f0102cbb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102cbe:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102cc1:	50                   	push   %eax
f0102cc2:	ff 75 08             	pushl  0x8(%ebp)
f0102cc5:	e8 c8 ff ff ff       	call   f0102c92 <vcprintf>
	va_end(ap);

	return cnt;
}
f0102cca:	c9                   	leave  
f0102ccb:	c3                   	ret    

f0102ccc <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0102ccc:	55                   	push   %ebp
f0102ccd:	89 e5                	mov    %esp,%ebp


	// Setup a TSS so that we get the right stack
	// when we trap to the kernel. 
	 
	ts.ts_esp0 = KSTACKTOP;
f0102ccf:	b8 a0 9a 23 f0       	mov    $0xf0239aa0,%eax
f0102cd4:	c7 05 a4 9a 23 f0 00 	movl   $0xf0000000,0xf0239aa4
f0102cdb:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0102cde:	66 c7 05 a8 9a 23 f0 	movw   $0x10,0xf0239aa8
f0102ce5:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f0102ce7:	66 c7 05 06 9b 23 f0 	movw   $0x68,0xf0239b06
f0102cee:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0102cf0:	66 c7 05 48 f3 11 f0 	movw   $0x67,0xf011f348
f0102cf7:	67 00 
f0102cf9:	66 a3 4a f3 11 f0    	mov    %ax,0xf011f34a
f0102cff:	89 c2                	mov    %eax,%edx
f0102d01:	c1 ea 10             	shr    $0x10,%edx
f0102d04:	88 15 4c f3 11 f0    	mov    %dl,0xf011f34c
f0102d0a:	c6 05 4e f3 11 f0 40 	movb   $0x40,0xf011f34e
f0102d11:	c1 e8 18             	shr    $0x18,%eax
f0102d14:	a2 4f f3 11 f0       	mov    %al,0xf011f34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0102d19:	c6 05 4d f3 11 f0 89 	movb   $0x89,0xf011f34d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0102d20:	b8 28 00 00 00       	mov    $0x28,%eax
f0102d25:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0102d28:	b8 8c f3 11 f0       	mov    $0xf011f38c,%eax
f0102d2d:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0102d30:	5d                   	pop    %ebp
f0102d31:	c3                   	ret    

f0102d32 <trap_init>:

	// LAB 3: Your code here.

    extern uint32_t idt_entries[];
    int i = 0;
    for (i = 0; i < 256; i++)
f0102d32:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d37:	eb 40                	jmp    f0102d79 <trap_init+0x47>
    {
        switch(i)
f0102d39:	83 f8 03             	cmp    $0x3,%eax
f0102d3c:	74 05                	je     f0102d43 <trap_init+0x11>
f0102d3e:	83 f8 30             	cmp    $0x30,%eax
f0102d41:	75 36                	jne    f0102d79 <trap_init+0x47>
        {
            case T_BRKPT:
            case T_SYSCALL:
                    SETGATE(idt[i], 0, GD_KT, idt_entries[i], 3);
f0102d43:	8b 14 85 92 f3 11 f0 	mov    -0xfee0c6e(,%eax,4),%edx
f0102d4a:	66 89 14 c5 80 92 23 	mov    %dx,-0xfdc6d80(,%eax,8)
f0102d51:	f0 
f0102d52:	66 c7 04 c5 82 92 23 	movw   $0x8,-0xfdc6d7e(,%eax,8)
f0102d59:	f0 08 00 
f0102d5c:	c6 04 c5 84 92 23 f0 	movb   $0x0,-0xfdc6d7c(,%eax,8)
f0102d63:	00 
f0102d64:	c6 04 c5 85 92 23 f0 	movb   $0xee,-0xfdc6d7b(,%eax,8)
f0102d6b:	ee 
f0102d6c:	c1 ea 10             	shr    $0x10,%edx
f0102d6f:	66 89 14 c5 86 92 23 	mov    %dx,-0xfdc6d7a(,%eax,8)
f0102d76:	f0 
                    break;
f0102d77:	eb 34                	jmp    f0102dad <trap_init+0x7b>

            default:
                    SETGATE(idt[i], 0, GD_KT, idt_entries[i], 0);
f0102d79:	8b 14 85 92 f3 11 f0 	mov    -0xfee0c6e(,%eax,4),%edx
f0102d80:	66 89 14 c5 80 92 23 	mov    %dx,-0xfdc6d80(,%eax,8)
f0102d87:	f0 
f0102d88:	66 c7 04 c5 82 92 23 	movw   $0x8,-0xfdc6d7e(,%eax,8)
f0102d8f:	f0 08 00 
f0102d92:	c6 04 c5 84 92 23 f0 	movb   $0x0,-0xfdc6d7c(,%eax,8)
f0102d99:	00 
f0102d9a:	c6 04 c5 85 92 23 f0 	movb   $0x8e,-0xfdc6d7b(,%eax,8)
f0102da1:	8e 
f0102da2:	c1 ea 10             	shr    $0x10,%edx
f0102da5:	66 89 14 c5 86 92 23 	mov    %dx,-0xfdc6d7a(,%eax,8)
f0102dac:	f0 

	// LAB 3: Your code here.

    extern uint32_t idt_entries[];
    int i = 0;
    for (i = 0; i < 256; i++)
f0102dad:	83 c0 01             	add    $0x1,%eax
f0102db0:	3d ff 00 00 00       	cmp    $0xff,%eax
f0102db5:	7e 82                	jle    f0102d39 <trap_init+0x7>
}


void
trap_init(void)
{
f0102db7:	55                   	push   %ebp
f0102db8:	89 e5                	mov    %esp,%ebp
                    break;
        }
    }

	// Per-CPU setup 
	trap_init_percpu();
f0102dba:	e8 0d ff ff ff       	call   f0102ccc <trap_init_percpu>
}
f0102dbf:	5d                   	pop    %ebp
f0102dc0:	c3                   	ret    

f0102dc1 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0102dc1:	55                   	push   %ebp
f0102dc2:	89 e5                	mov    %esp,%ebp
f0102dc4:	53                   	push   %ebx
f0102dc5:	83 ec 0c             	sub    $0xc,%esp
f0102dc8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0102dcb:	ff 33                	pushl  (%ebx)
f0102dcd:	68 b5 6a 10 f0       	push   $0xf0106ab5
f0102dd2:	e8 e1 fe ff ff       	call   f0102cb8 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0102dd7:	83 c4 08             	add    $0x8,%esp
f0102dda:	ff 73 04             	pushl  0x4(%ebx)
f0102ddd:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0102de2:	e8 d1 fe ff ff       	call   f0102cb8 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0102de7:	83 c4 08             	add    $0x8,%esp
f0102dea:	ff 73 08             	pushl  0x8(%ebx)
f0102ded:	68 d3 6a 10 f0       	push   $0xf0106ad3
f0102df2:	e8 c1 fe ff ff       	call   f0102cb8 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0102df7:	83 c4 08             	add    $0x8,%esp
f0102dfa:	ff 73 0c             	pushl  0xc(%ebx)
f0102dfd:	68 e2 6a 10 f0       	push   $0xf0106ae2
f0102e02:	e8 b1 fe ff ff       	call   f0102cb8 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0102e07:	83 c4 08             	add    $0x8,%esp
f0102e0a:	ff 73 10             	pushl  0x10(%ebx)
f0102e0d:	68 f1 6a 10 f0       	push   $0xf0106af1
f0102e12:	e8 a1 fe ff ff       	call   f0102cb8 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0102e17:	83 c4 08             	add    $0x8,%esp
f0102e1a:	ff 73 14             	pushl  0x14(%ebx)
f0102e1d:	68 00 6b 10 f0       	push   $0xf0106b00
f0102e22:	e8 91 fe ff ff       	call   f0102cb8 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0102e27:	83 c4 08             	add    $0x8,%esp
f0102e2a:	ff 73 18             	pushl  0x18(%ebx)
f0102e2d:	68 0f 6b 10 f0       	push   $0xf0106b0f
f0102e32:	e8 81 fe ff ff       	call   f0102cb8 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0102e37:	83 c4 08             	add    $0x8,%esp
f0102e3a:	ff 73 1c             	pushl  0x1c(%ebx)
f0102e3d:	68 1e 6b 10 f0       	push   $0xf0106b1e
f0102e42:	e8 71 fe ff ff       	call   f0102cb8 <cprintf>
}
f0102e47:	83 c4 10             	add    $0x10,%esp
f0102e4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102e4d:	c9                   	leave  
f0102e4e:	c3                   	ret    

f0102e4f <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0102e4f:	55                   	push   %ebp
f0102e50:	89 e5                	mov    %esp,%ebp
f0102e52:	56                   	push   %esi
f0102e53:	53                   	push   %ebx
f0102e54:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0102e57:	e8 a6 26 00 00       	call   f0105502 <cpunum>
f0102e5c:	83 ec 04             	sub    $0x4,%esp
f0102e5f:	50                   	push   %eax
f0102e60:	53                   	push   %ebx
f0102e61:	68 82 6b 10 f0       	push   $0xf0106b82
f0102e66:	e8 4d fe ff ff       	call   f0102cb8 <cprintf>
	print_regs(&tf->tf_regs);
f0102e6b:	89 1c 24             	mov    %ebx,(%esp)
f0102e6e:	e8 4e ff ff ff       	call   f0102dc1 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0102e73:	83 c4 08             	add    $0x8,%esp
f0102e76:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0102e7a:	50                   	push   %eax
f0102e7b:	68 a0 6b 10 f0       	push   $0xf0106ba0
f0102e80:	e8 33 fe ff ff       	call   f0102cb8 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0102e85:	83 c4 08             	add    $0x8,%esp
f0102e88:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0102e8c:	50                   	push   %eax
f0102e8d:	68 b3 6b 10 f0       	push   $0xf0106bb3
f0102e92:	e8 21 fe ff ff       	call   f0102cb8 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0102e97:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0102e9a:	83 c4 10             	add    $0x10,%esp
f0102e9d:	83 f8 13             	cmp    $0x13,%eax
f0102ea0:	77 09                	ja     f0102eab <print_trapframe+0x5c>
		return excnames[trapno];
f0102ea2:	8b 14 85 40 6e 10 f0 	mov    -0xfef91c0(,%eax,4),%edx
f0102ea9:	eb 1f                	jmp    f0102eca <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0102eab:	83 f8 30             	cmp    $0x30,%eax
f0102eae:	74 15                	je     f0102ec5 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0102eb0:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0102eb3:	83 fa 10             	cmp    $0x10,%edx
f0102eb6:	b9 4c 6b 10 f0       	mov    $0xf0106b4c,%ecx
f0102ebb:	ba 39 6b 10 f0       	mov    $0xf0106b39,%edx
f0102ec0:	0f 43 d1             	cmovae %ecx,%edx
f0102ec3:	eb 05                	jmp    f0102eca <print_trapframe+0x7b>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0102ec5:	ba 2d 6b 10 f0       	mov    $0xf0106b2d,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0102eca:	83 ec 04             	sub    $0x4,%esp
f0102ecd:	52                   	push   %edx
f0102ece:	50                   	push   %eax
f0102ecf:	68 c6 6b 10 f0       	push   $0xf0106bc6
f0102ed4:	e8 df fd ff ff       	call   f0102cb8 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0102ed9:	83 c4 10             	add    $0x10,%esp
f0102edc:	3b 1d 80 9a 23 f0    	cmp    0xf0239a80,%ebx
f0102ee2:	75 1a                	jne    f0102efe <print_trapframe+0xaf>
f0102ee4:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0102ee8:	75 14                	jne    f0102efe <print_trapframe+0xaf>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0102eea:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0102eed:	83 ec 08             	sub    $0x8,%esp
f0102ef0:	50                   	push   %eax
f0102ef1:	68 d8 6b 10 f0       	push   $0xf0106bd8
f0102ef6:	e8 bd fd ff ff       	call   f0102cb8 <cprintf>
f0102efb:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0102efe:	83 ec 08             	sub    $0x8,%esp
f0102f01:	ff 73 2c             	pushl  0x2c(%ebx)
f0102f04:	68 e7 6b 10 f0       	push   $0xf0106be7
f0102f09:	e8 aa fd ff ff       	call   f0102cb8 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0102f0e:	83 c4 10             	add    $0x10,%esp
f0102f11:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0102f15:	75 49                	jne    f0102f60 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0102f17:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0102f1a:	89 c2                	mov    %eax,%edx
f0102f1c:	83 e2 01             	and    $0x1,%edx
f0102f1f:	ba 66 6b 10 f0       	mov    $0xf0106b66,%edx
f0102f24:	b9 5b 6b 10 f0       	mov    $0xf0106b5b,%ecx
f0102f29:	0f 44 ca             	cmove  %edx,%ecx
f0102f2c:	89 c2                	mov    %eax,%edx
f0102f2e:	83 e2 02             	and    $0x2,%edx
f0102f31:	ba 78 6b 10 f0       	mov    $0xf0106b78,%edx
f0102f36:	be 72 6b 10 f0       	mov    $0xf0106b72,%esi
f0102f3b:	0f 45 d6             	cmovne %esi,%edx
f0102f3e:	83 e0 04             	and    $0x4,%eax
f0102f41:	be c7 6c 10 f0       	mov    $0xf0106cc7,%esi
f0102f46:	b8 7d 6b 10 f0       	mov    $0xf0106b7d,%eax
f0102f4b:	0f 44 c6             	cmove  %esi,%eax
f0102f4e:	51                   	push   %ecx
f0102f4f:	52                   	push   %edx
f0102f50:	50                   	push   %eax
f0102f51:	68 f5 6b 10 f0       	push   $0xf0106bf5
f0102f56:	e8 5d fd ff ff       	call   f0102cb8 <cprintf>
f0102f5b:	83 c4 10             	add    $0x10,%esp
f0102f5e:	eb 10                	jmp    f0102f70 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0102f60:	83 ec 0c             	sub    $0xc,%esp
f0102f63:	68 3c 5f 10 f0       	push   $0xf0105f3c
f0102f68:	e8 4b fd ff ff       	call   f0102cb8 <cprintf>
f0102f6d:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0102f70:	83 ec 08             	sub    $0x8,%esp
f0102f73:	ff 73 30             	pushl  0x30(%ebx)
f0102f76:	68 04 6c 10 f0       	push   $0xf0106c04
f0102f7b:	e8 38 fd ff ff       	call   f0102cb8 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0102f80:	83 c4 08             	add    $0x8,%esp
f0102f83:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0102f87:	50                   	push   %eax
f0102f88:	68 13 6c 10 f0       	push   $0xf0106c13
f0102f8d:	e8 26 fd ff ff       	call   f0102cb8 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0102f92:	83 c4 08             	add    $0x8,%esp
f0102f95:	ff 73 38             	pushl  0x38(%ebx)
f0102f98:	68 26 6c 10 f0       	push   $0xf0106c26
f0102f9d:	e8 16 fd ff ff       	call   f0102cb8 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0102fa2:	83 c4 10             	add    $0x10,%esp
f0102fa5:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0102fa9:	74 25                	je     f0102fd0 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0102fab:	83 ec 08             	sub    $0x8,%esp
f0102fae:	ff 73 3c             	pushl  0x3c(%ebx)
f0102fb1:	68 35 6c 10 f0       	push   $0xf0106c35
f0102fb6:	e8 fd fc ff ff       	call   f0102cb8 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0102fbb:	83 c4 08             	add    $0x8,%esp
f0102fbe:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0102fc2:	50                   	push   %eax
f0102fc3:	68 44 6c 10 f0       	push   $0xf0106c44
f0102fc8:	e8 eb fc ff ff       	call   f0102cb8 <cprintf>
f0102fcd:	83 c4 10             	add    $0x10,%esp
	}
}
f0102fd0:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0102fd3:	5b                   	pop    %ebx
f0102fd4:	5e                   	pop    %esi
f0102fd5:	5d                   	pop    %ebp
f0102fd6:	c3                   	ret    

f0102fd7 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0102fd7:	55                   	push   %ebp
f0102fd8:	89 e5                	mov    %esp,%ebp
f0102fda:	57                   	push   %edi
f0102fdb:	56                   	push   %esi
f0102fdc:	53                   	push   %ebx
f0102fdd:	83 ec 0c             	sub    $0xc,%esp
f0102fe0:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0102fe3:	0f 20 d6             	mov    %cr2,%esi

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.

    if(tf->tf_cs == GD_KT)
f0102fe6:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f0102feb:	75 17                	jne    f0103004 <page_fault_handler+0x2d>
    {
        panic("Page fault in kernel");
f0102fed:	83 ec 04             	sub    $0x4,%esp
f0102ff0:	68 57 6c 10 f0       	push   $0xf0106c57
f0102ff5:	68 42 01 00 00       	push   $0x142
f0102ffa:	68 6c 6c 10 f0       	push   $0xf0106c6c
f0102fff:	e8 3c d0 ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

    if (!curenv->env_pgfault_upcall)
f0103004:	e8 f9 24 00 00       	call   f0105502 <cpunum>
f0103009:	6b c0 74             	imul   $0x74,%eax,%eax
f010300c:	8b 80 28 a0 23 f0    	mov    -0xfdc5fd8(%eax),%eax
f0103012:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103016:	0f 84 a6 00 00 00    	je     f01030c2 <page_fault_handler+0xeb>
    {
        goto destroy;
    }

    //check that exception stack is allocated
    user_mem_assert(curenv, (void *)(UXSTACKTOP - 4), 4, 0);
f010301c:	e8 e1 24 00 00       	call   f0105502 <cpunum>
f0103021:	6a 00                	push   $0x0
f0103023:	6a 04                	push   $0x4
f0103025:	68 fc ff bf ee       	push   $0xeebffffc
f010302a:	6b c0 74             	imul   $0x74,%eax,%eax
f010302d:	ff b0 28 a0 23 f0    	pushl  -0xfdc5fd8(%eax)
f0103033:	e8 db f2 ff ff       	call   f0102313 <user_mem_assert>

    uintptr_t exstack;
    struct UTrapframe *utf;

    // Figure out top where trapframe should end, leaving 1 word scratch space
    if (tf->tf_esp >= UXSTACKTOP - PGSIZE && tf->tf_esp <= UXSTACKTOP - 1)
f0103038:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010303b:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
f0103041:	83 c4 10             	add    $0x10,%esp
    {
        exstack = (tf->tf_esp - sizeof(struct UTrapframe) - 4);
f0103044:	83 e8 38             	sub    $0x38,%eax
f0103047:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f010304d:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f0103052:	0f 46 d0             	cmovbe %eax,%edx
    }

    // set up UTrapframe on exception stack
    utf = (struct UTrapframe *)(exstack);

    utf->utf_fault_va = fault_va;
f0103055:	89 32                	mov    %esi,(%edx)
    utf->utf_err    = tf->tf_err;
f0103057:	8b 43 2c             	mov    0x2c(%ebx),%eax
f010305a:	89 42 04             	mov    %eax,0x4(%edx)
    utf->utf_regs   = tf->tf_regs;
f010305d:	8d 7a 08             	lea    0x8(%edx),%edi
f0103060:	b9 08 00 00 00       	mov    $0x8,%ecx
f0103065:	89 de                	mov    %ebx,%esi
f0103067:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
    utf->utf_eip    = tf->tf_eip;
f0103069:	8b 43 30             	mov    0x30(%ebx),%eax
f010306c:	89 42 28             	mov    %eax,0x28(%edx)
    utf->utf_eflags = tf->tf_eflags;
f010306f:	8b 43 38             	mov    0x38(%ebx),%eax
f0103072:	89 d7                	mov    %edx,%edi
f0103074:	89 42 2c             	mov    %eax,0x2c(%edx)
    utf->utf_esp    = tf->tf_esp;
f0103077:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010307a:	89 42 30             	mov    %eax,0x30(%edx)

    user_mem_assert(curenv, (void *)exstack, sizeof(struct UTrapframe), PTE_P | PTE_W | PTE_U);
f010307d:	e8 80 24 00 00       	call   f0105502 <cpunum>
f0103082:	6a 07                	push   $0x7
f0103084:	6a 34                	push   $0x34
f0103086:	57                   	push   %edi
f0103087:	6b c0 74             	imul   $0x74,%eax,%eax
f010308a:	ff b0 28 a0 23 f0    	pushl  -0xfdc5fd8(%eax)
f0103090:	e8 7e f2 ff ff       	call   f0102313 <user_mem_assert>
    // fix trapframe to return to user handler
    tf->tf_esp = (uintptr_t) utf;
f0103095:	89 7b 3c             	mov    %edi,0x3c(%ebx)
    tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;
f0103098:	e8 65 24 00 00       	call   f0105502 <cpunum>
f010309d:	6b c0 74             	imul   $0x74,%eax,%eax
f01030a0:	8b 80 28 a0 23 f0    	mov    -0xfdc5fd8(%eax),%eax
f01030a6:	8b 40 64             	mov    0x64(%eax),%eax
f01030a9:	89 43 30             	mov    %eax,0x30(%ebx)

    env_run(curenv);
f01030ac:	e8 51 24 00 00       	call   f0105502 <cpunum>
f01030b1:	83 c4 04             	add    $0x4,%esp
f01030b4:	6b c0 74             	imul   $0x74,%eax,%eax
f01030b7:	ff b0 28 a0 23 f0    	pushl  -0xfdc5fd8(%eax)
f01030bd:	e8 ea f9 ff ff       	call   f0102aac <env_run>

    panic("Unreachable code!\n");

destroy:
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01030c2:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01030c5:	e8 38 24 00 00       	call   f0105502 <cpunum>

    panic("Unreachable code!\n");

destroy:
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01030ca:	57                   	push   %edi
f01030cb:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f01030cc:	6b c0 74             	imul   $0x74,%eax,%eax

    panic("Unreachable code!\n");

destroy:
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01030cf:	8b 80 28 a0 23 f0    	mov    -0xfdc5fd8(%eax),%eax
f01030d5:	ff 70 48             	pushl  0x48(%eax)
f01030d8:	68 14 6e 10 f0       	push   $0xf0106e14
f01030dd:	e8 d6 fb ff ff       	call   f0102cb8 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01030e2:	89 1c 24             	mov    %ebx,(%esp)
f01030e5:	e8 65 fd ff ff       	call   f0102e4f <print_trapframe>
	env_destroy(curenv);
f01030ea:	e8 13 24 00 00       	call   f0105502 <cpunum>
f01030ef:	83 c4 04             	add    $0x4,%esp
f01030f2:	6b c0 74             	imul   $0x74,%eax,%eax
f01030f5:	ff b0 28 a0 23 f0    	pushl  -0xfdc5fd8(%eax)
f01030fb:	e8 0d f9 ff ff       	call   f0102a0d <env_destroy>
}
f0103100:	83 c4 10             	add    $0x10,%esp
f0103103:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103106:	5b                   	pop    %ebx
f0103107:	5e                   	pop    %esi
f0103108:	5f                   	pop    %edi
f0103109:	5d                   	pop    %ebp
f010310a:	c3                   	ret    

f010310b <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f010310b:	55                   	push   %ebp
f010310c:	89 e5                	mov    %esp,%ebp
f010310e:	57                   	push   %edi
f010310f:	56                   	push   %esi
f0103110:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103113:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0103114:	83 3d 20 9f 23 f0 00 	cmpl   $0x0,0xf0239f20
f010311b:	74 01                	je     f010311e <trap+0x13>
		asm volatile("hlt");
f010311d:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010311e:	e8 df 23 00 00       	call   f0105502 <cpunum>
f0103123:	6b d0 74             	imul   $0x74,%eax,%edx
f0103126:	81 c2 20 a0 23 f0    	add    $0xf023a020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010312c:	b8 01 00 00 00       	mov    $0x1,%eax
f0103131:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0103135:	83 f8 02             	cmp    $0x2,%eax
f0103138:	75 10                	jne    f010314a <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010313a:	83 ec 0c             	sub    $0xc,%esp
f010313d:	68 a0 f7 11 f0       	push   $0xf011f7a0
f0103142:	e8 29 26 00 00       	call   f0105770 <spin_lock>
f0103147:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f010314a:	9c                   	pushf  
f010314b:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010314c:	f6 c4 02             	test   $0x2,%ah
f010314f:	74 19                	je     f010316a <trap+0x5f>
f0103151:	68 78 6c 10 f0       	push   $0xf0106c78
f0103156:	68 16 67 10 f0       	push   $0xf0106716
f010315b:	68 0a 01 00 00       	push   $0x10a
f0103160:	68 6c 6c 10 f0       	push   $0xf0106c6c
f0103165:	e8 d6 ce ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f010316a:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010316e:	83 e0 03             	and    $0x3,%eax
f0103171:	66 83 f8 03          	cmp    $0x3,%ax
f0103175:	0f 85 90 00 00 00    	jne    f010320b <trap+0x100>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 2: Your code here.

		assert(curenv);
f010317b:	e8 82 23 00 00       	call   f0105502 <cpunum>
f0103180:	6b c0 74             	imul   $0x74,%eax,%eax
f0103183:	83 b8 28 a0 23 f0 00 	cmpl   $0x0,-0xfdc5fd8(%eax)
f010318a:	75 19                	jne    f01031a5 <trap+0x9a>
f010318c:	68 91 6c 10 f0       	push   $0xf0106c91
f0103191:	68 16 67 10 f0       	push   $0xf0106716
f0103196:	68 12 01 00 00       	push   $0x112
f010319b:	68 6c 6c 10 f0       	push   $0xf0106c6c
f01031a0:	e8 9b ce ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01031a5:	e8 58 23 00 00       	call   f0105502 <cpunum>
f01031aa:	6b c0 74             	imul   $0x74,%eax,%eax
f01031ad:	8b 80 28 a0 23 f0    	mov    -0xfdc5fd8(%eax),%eax
f01031b3:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01031b7:	75 2d                	jne    f01031e6 <trap+0xdb>
			env_free(curenv);
f01031b9:	e8 44 23 00 00       	call   f0105502 <cpunum>
f01031be:	83 ec 0c             	sub    $0xc,%esp
f01031c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01031c4:	ff b0 28 a0 23 f0    	pushl  -0xfdc5fd8(%eax)
f01031ca:	e8 63 f6 ff ff       	call   f0102832 <env_free>
			curenv = NULL;
f01031cf:	e8 2e 23 00 00       	call   f0105502 <cpunum>
f01031d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01031d7:	c7 80 28 a0 23 f0 00 	movl   $0x0,-0xfdc5fd8(%eax)
f01031de:	00 00 00 
			sched_yield();
f01031e1:	e8 00 0d 00 00       	call   f0103ee6 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01031e6:	e8 17 23 00 00       	call   f0105502 <cpunum>
f01031eb:	6b c0 74             	imul   $0x74,%eax,%eax
f01031ee:	8b 80 28 a0 23 f0    	mov    -0xfdc5fd8(%eax),%eax
f01031f4:	b9 11 00 00 00       	mov    $0x11,%ecx
f01031f9:	89 c7                	mov    %eax,%edi
f01031fb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01031fd:	e8 00 23 00 00       	call   f0105502 <cpunum>
f0103202:	6b c0 74             	imul   $0x74,%eax,%eax
f0103205:	8b b0 28 a0 23 f0    	mov    -0xfdc5fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f010320b:	89 35 80 9a 23 f0    	mov    %esi,0xf0239a80
	// Handle processor exceptions.
	// LAB 3: Your code here.
	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0103211:	8b 46 28             	mov    0x28(%esi),%eax
f0103214:	83 f8 27             	cmp    $0x27,%eax
f0103217:	75 1d                	jne    f0103236 <trap+0x12b>
		cprintf("Spurious interrupt on irq 7\n");
f0103219:	83 ec 0c             	sub    $0xc,%esp
f010321c:	68 98 6c 10 f0       	push   $0xf0106c98
f0103221:	e8 92 fa ff ff       	call   f0102cb8 <cprintf>
		print_trapframe(tf);
f0103226:	89 34 24             	mov    %esi,(%esp)
f0103229:	e8 21 fc ff ff       	call   f0102e4f <print_trapframe>
f010322e:	83 c4 10             	add    $0x10,%esp
f0103231:	e9 a3 00 00 00       	jmp    f01032d9 <trap+0x1ce>

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

    switch(tf->tf_trapno)
f0103236:	83 f8 0e             	cmp    $0xe,%eax
f0103239:	74 0c                	je     f0103247 <trap+0x13c>
f010323b:	83 f8 30             	cmp    $0x30,%eax
f010323e:	74 26                	je     f0103266 <trap+0x15b>
f0103240:	83 f8 03             	cmp    $0x3,%eax
f0103243:	75 42                	jne    f0103287 <trap+0x17c>
f0103245:	eb 11                	jmp    f0103258 <trap+0x14d>
    {
        case T_PGFLT:
                page_fault_handler(tf);
f0103247:	83 ec 0c             	sub    $0xc,%esp
f010324a:	56                   	push   %esi
f010324b:	e8 87 fd ff ff       	call   f0102fd7 <page_fault_handler>
f0103250:	83 c4 10             	add    $0x10,%esp
f0103253:	e9 81 00 00 00       	jmp    f01032d9 <trap+0x1ce>
                return;
        case T_BRKPT:
                monitor(tf);
f0103258:	83 ec 0c             	sub    $0xc,%esp
f010325b:	56                   	push   %esi
f010325c:	e8 b8 d6 ff ff       	call   f0100919 <monitor>
f0103261:	83 c4 10             	add    $0x10,%esp
f0103264:	eb 73                	jmp    f01032d9 <trap+0x1ce>
                return;

        case T_SYSCALL:
                tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, 
f0103266:	83 ec 08             	sub    $0x8,%esp
f0103269:	ff 76 04             	pushl  0x4(%esi)
f010326c:	ff 36                	pushl  (%esi)
f010326e:	ff 76 10             	pushl  0x10(%esi)
f0103271:	ff 76 18             	pushl  0x18(%esi)
f0103274:	ff 76 14             	pushl  0x14(%esi)
f0103277:	ff 76 1c             	pushl  0x1c(%esi)
f010327a:	e8 d5 0c 00 00       	call   f0103f54 <syscall>
f010327f:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103282:	83 c4 20             	add    $0x20,%esp
f0103285:	eb 52                	jmp    f01032d9 <trap+0x1ce>
                            tf->tf_regs.reg_esi);
                return ;
                
    }

    if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER)
f0103287:	83 f8 20             	cmp    $0x20,%eax
f010328a:	75 0a                	jne    f0103296 <trap+0x18b>
    {
        //time_tick();
        lapic_eoi();
f010328c:	e8 bc 23 00 00       	call   f010564d <lapic_eoi>
        sched_yield();
f0103291:	e8 50 0c 00 00       	call   f0103ee6 <sched_yield>
        return;
    }

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0103296:	83 ec 0c             	sub    $0xc,%esp
f0103299:	56                   	push   %esi
f010329a:	e8 b0 fb ff ff       	call   f0102e4f <print_trapframe>
	if (tf->tf_cs == GD_KT)
f010329f:	83 c4 10             	add    $0x10,%esp
f01032a2:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01032a7:	75 17                	jne    f01032c0 <trap+0x1b5>
		panic("unhandled trap in kernel");
f01032a9:	83 ec 04             	sub    $0x4,%esp
f01032ac:	68 b5 6c 10 f0       	push   $0xf0106cb5
f01032b1:	68 f0 00 00 00       	push   $0xf0
f01032b6:	68 6c 6c 10 f0       	push   $0xf0106c6c
f01032bb:	e8 80 cd ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f01032c0:	e8 3d 22 00 00       	call   f0105502 <cpunum>
f01032c5:	83 ec 0c             	sub    $0xc,%esp
f01032c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01032cb:	ff b0 28 a0 23 f0    	pushl  -0xfdc5fd8(%eax)
f01032d1:	e8 37 f7 ff ff       	call   f0102a0d <env_destroy>
f01032d6:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01032d9:	e8 24 22 00 00       	call   f0105502 <cpunum>
f01032de:	6b c0 74             	imul   $0x74,%eax,%eax
f01032e1:	83 b8 28 a0 23 f0 00 	cmpl   $0x0,-0xfdc5fd8(%eax)
f01032e8:	74 2a                	je     f0103314 <trap+0x209>
f01032ea:	e8 13 22 00 00       	call   f0105502 <cpunum>
f01032ef:	6b c0 74             	imul   $0x74,%eax,%eax
f01032f2:	8b 80 28 a0 23 f0    	mov    -0xfdc5fd8(%eax),%eax
f01032f8:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01032fc:	75 16                	jne    f0103314 <trap+0x209>
		env_run(curenv);
f01032fe:	e8 ff 21 00 00       	call   f0105502 <cpunum>
f0103303:	83 ec 0c             	sub    $0xc,%esp
f0103306:	6b c0 74             	imul   $0x74,%eax,%eax
f0103309:	ff b0 28 a0 23 f0    	pushl  -0xfdc5fd8(%eax)
f010330f:	e8 98 f7 ff ff       	call   f0102aac <env_run>
	else
		sched_yield();
f0103314:	e8 cd 0b 00 00       	call   f0103ee6 <sched_yield>
f0103319:	90                   	nop

f010331a <divide_error>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

	TRAPHANDLER_NOEC(divide_error, T_DIVIDE)				# divide error
f010331a:	6a 00                	push   $0x0
f010331c:	6a 00                	push   $0x0
f010331e:	e9 ce 0a 00 00       	jmp    f0103df1 <_alltraps>
f0103323:	90                   	nop

f0103324 <debug>:
	TRAPHANDLER_NOEC(debug, T_DEBUG)						# debug exception
f0103324:	6a 00                	push   $0x0
f0103326:	6a 01                	push   $0x1
f0103328:	e9 c4 0a 00 00       	jmp    f0103df1 <_alltraps>
f010332d:	90                   	nop

f010332e <nmi>:
	TRAPHANDLER_NOEC(nmi, T_NMI)							# non-maskable interrupt
f010332e:	6a 00                	push   $0x0
f0103330:	6a 02                	push   $0x2
f0103332:	e9 ba 0a 00 00       	jmp    f0103df1 <_alltraps>
f0103337:	90                   	nop

f0103338 <breakpoint>:
    TRAPHANDLER_NOEC(breakpoint, T_BRKPT)					# breakpoint
f0103338:	6a 00                	push   $0x0
f010333a:	6a 03                	push   $0x3
f010333c:	e9 b0 0a 00 00       	jmp    f0103df1 <_alltraps>
f0103341:	90                   	nop

f0103342 <overflow>:
	TRAPHANDLER_NOEC(overflow, T_OFLOW)						# overflow
f0103342:	6a 00                	push   $0x0
f0103344:	6a 04                	push   $0x4
f0103346:	e9 a6 0a 00 00       	jmp    f0103df1 <_alltraps>
f010334b:	90                   	nop

f010334c <bounds>:
	TRAPHANDLER_NOEC(bounds, T_BOUND)						# bounds check
f010334c:	6a 00                	push   $0x0
f010334e:	6a 05                	push   $0x5
f0103350:	e9 9c 0a 00 00       	jmp    f0103df1 <_alltraps>
f0103355:	90                   	nop

f0103356 <invalid_op>:
	TRAPHANDLER_NOEC(invalid_op, T_ILLOP)					# illegal opcode
f0103356:	6a 00                	push   $0x0
f0103358:	6a 06                	push   $0x6
f010335a:	e9 92 0a 00 00       	jmp    f0103df1 <_alltraps>
f010335f:	90                   	nop

f0103360 <device_not_available>:
	TRAPHANDLER_NOEC(device_not_available, T_DEVICE)		# device not available
f0103360:	6a 00                	push   $0x0
f0103362:	6a 07                	push   $0x7
f0103364:	e9 88 0a 00 00       	jmp    f0103df1 <_alltraps>
f0103369:	90                   	nop

f010336a <double_fault>:
	TRAPHANDLER(double_fault, T_DBLFLT)						# double fault
f010336a:	6a 08                	push   $0x8
f010336c:	e9 80 0a 00 00       	jmp    f0103df1 <_alltraps>
f0103371:	90                   	nop

f0103372 <coprocessor_segment_overrun>:
	TRAPHANDLER_NOEC(coprocessor_segment_overrun, T_COPROC)	# reserved (not generated by recent processors)
f0103372:	6a 00                	push   $0x0
f0103374:	6a 09                	push   $0x9
f0103376:	e9 76 0a 00 00       	jmp    f0103df1 <_alltraps>
f010337b:	90                   	nop

f010337c <invalid_TSS>:
	TRAPHANDLER(invalid_TSS, T_TSS)							# invalid task switch segment
f010337c:	6a 0a                	push   $0xa
f010337e:	e9 6e 0a 00 00       	jmp    f0103df1 <_alltraps>
f0103383:	90                   	nop

f0103384 <segment_not_present>:
	TRAPHANDLER(segment_not_present, T_SEGNP)				# segment not present
f0103384:	6a 0b                	push   $0xb
f0103386:	e9 66 0a 00 00       	jmp    f0103df1 <_alltraps>
f010338b:	90                   	nop

f010338c <stack_segment>:
	TRAPHANDLER(stack_segment, T_STACK)						# stack exception
f010338c:	6a 0c                	push   $0xc
f010338e:	e9 5e 0a 00 00       	jmp    f0103df1 <_alltraps>
f0103393:	90                   	nop

f0103394 <general_protection>:
	TRAPHANDLER(general_protection, T_GPFLT)				# general protection fault
f0103394:	6a 0d                	push   $0xd
f0103396:	e9 56 0a 00 00       	jmp    f0103df1 <_alltraps>
f010339b:	90                   	nop

f010339c <page_fault>:
	TRAPHANDLER(page_fault, T_PGFLT)						# page fault
f010339c:	6a 0e                	push   $0xe
f010339e:	e9 4e 0a 00 00       	jmp    f0103df1 <_alltraps>
f01033a3:	90                   	nop

f01033a4 <reserved>:
	TRAPHANDLER_NOEC(reserved, T_RES)						# reserved
f01033a4:	6a 00                	push   $0x0
f01033a6:	6a 0f                	push   $0xf
f01033a8:	e9 44 0a 00 00       	jmp    f0103df1 <_alltraps>
f01033ad:	90                   	nop

f01033ae <float_point_error>:
	TRAPHANDLER_NOEC(float_point_error, T_FPERR)			# floating point error
f01033ae:	6a 00                	push   $0x0
f01033b0:	6a 10                	push   $0x10
f01033b2:	e9 3a 0a 00 00       	jmp    f0103df1 <_alltraps>
f01033b7:	90                   	nop

f01033b8 <alignment_check>:
	TRAPHANDLER(alignment_check, T_ALIGN)					# alignment check
f01033b8:	6a 11                	push   $0x11
f01033ba:	e9 32 0a 00 00       	jmp    f0103df1 <_alltraps>
f01033bf:	90                   	nop

f01033c0 <machine_check>:
	TRAPHANDLER_NOEC(machine_check, T_MCHK)					# machine check
f01033c0:	6a 00                	push   $0x0
f01033c2:	6a 12                	push   $0x12
f01033c4:	e9 28 0a 00 00       	jmp    f0103df1 <_alltraps>
f01033c9:	90                   	nop

f01033ca <SIMD_float_point_error>:
	TRAPHANDLER_NOEC(SIMD_float_point_error, T_SIMDERR)		# SIMD floating point error
f01033ca:	6a 00                	push   $0x0
f01033cc:	6a 13                	push   $0x13
f01033ce:	e9 1e 0a 00 00       	jmp    f0103df1 <_alltraps>
f01033d3:	90                   	nop

f01033d4 <trap_handler_placeholder20>:
	TRAPHANDLER_NOEC(trap_handler_placeholder20,20)
f01033d4:	6a 00                	push   $0x0
f01033d6:	6a 14                	push   $0x14
f01033d8:	e9 14 0a 00 00       	jmp    f0103df1 <_alltraps>
f01033dd:	90                   	nop

f01033de <trap_handler_placeholder21>:
	TRAPHANDLER_NOEC(trap_handler_placeholder21,21)
f01033de:	6a 00                	push   $0x0
f01033e0:	6a 15                	push   $0x15
f01033e2:	e9 0a 0a 00 00       	jmp    f0103df1 <_alltraps>
f01033e7:	90                   	nop

f01033e8 <trap_handler_placeholder22>:
	TRAPHANDLER_NOEC(trap_handler_placeholder22,22)
f01033e8:	6a 00                	push   $0x0
f01033ea:	6a 16                	push   $0x16
f01033ec:	e9 00 0a 00 00       	jmp    f0103df1 <_alltraps>
f01033f1:	90                   	nop

f01033f2 <trap_handler_placeholder23>:
	TRAPHANDLER_NOEC(trap_handler_placeholder23,23)
f01033f2:	6a 00                	push   $0x0
f01033f4:	6a 17                	push   $0x17
f01033f6:	e9 f6 09 00 00       	jmp    f0103df1 <_alltraps>
f01033fb:	90                   	nop

f01033fc <trap_handler_placeholder24>:
	TRAPHANDLER_NOEC(trap_handler_placeholder24,24)
f01033fc:	6a 00                	push   $0x0
f01033fe:	6a 18                	push   $0x18
f0103400:	e9 ec 09 00 00       	jmp    f0103df1 <_alltraps>
f0103405:	90                   	nop

f0103406 <trap_handler_placeholder25>:
	TRAPHANDLER_NOEC(trap_handler_placeholder25,25)
f0103406:	6a 00                	push   $0x0
f0103408:	6a 19                	push   $0x19
f010340a:	e9 e2 09 00 00       	jmp    f0103df1 <_alltraps>
f010340f:	90                   	nop

f0103410 <trap_handler_placeholder26>:
	TRAPHANDLER_NOEC(trap_handler_placeholder26,26)
f0103410:	6a 00                	push   $0x0
f0103412:	6a 1a                	push   $0x1a
f0103414:	e9 d8 09 00 00       	jmp    f0103df1 <_alltraps>
f0103419:	90                   	nop

f010341a <trap_handler_placeholder27>:
	TRAPHANDLER_NOEC(trap_handler_placeholder27,27)
f010341a:	6a 00                	push   $0x0
f010341c:	6a 1b                	push   $0x1b
f010341e:	e9 ce 09 00 00       	jmp    f0103df1 <_alltraps>
f0103423:	90                   	nop

f0103424 <trap_handler_placeholder28>:
	TRAPHANDLER_NOEC(trap_handler_placeholder28,28)
f0103424:	6a 00                	push   $0x0
f0103426:	6a 1c                	push   $0x1c
f0103428:	e9 c4 09 00 00       	jmp    f0103df1 <_alltraps>
f010342d:	90                   	nop

f010342e <trap_handler_placeholder29>:
	TRAPHANDLER_NOEC(trap_handler_placeholder29,29)
f010342e:	6a 00                	push   $0x0
f0103430:	6a 1d                	push   $0x1d
f0103432:	e9 ba 09 00 00       	jmp    f0103df1 <_alltraps>
f0103437:	90                   	nop

f0103438 <trap_handler_placeholder30>:
	TRAPHANDLER_NOEC(trap_handler_placeholder30,30)
f0103438:	6a 00                	push   $0x0
f010343a:	6a 1e                	push   $0x1e
f010343c:	e9 b0 09 00 00       	jmp    f0103df1 <_alltraps>
f0103441:	90                   	nop

f0103442 <trap_handler_placeholder31>:
	TRAPHANDLER_NOEC(trap_handler_placeholder31,31)
f0103442:	6a 00                	push   $0x0
f0103444:	6a 1f                	push   $0x1f
f0103446:	e9 a6 09 00 00       	jmp    f0103df1 <_alltraps>
f010344b:	90                   	nop

f010344c <trap_handler_placeholder32>:
	TRAPHANDLER_NOEC(trap_handler_placeholder32,32)
f010344c:	6a 00                	push   $0x0
f010344e:	6a 20                	push   $0x20
f0103450:	e9 9c 09 00 00       	jmp    f0103df1 <_alltraps>
f0103455:	90                   	nop

f0103456 <trap_handler_placeholder33>:
	TRAPHANDLER_NOEC(trap_handler_placeholder33,33)
f0103456:	6a 00                	push   $0x0
f0103458:	6a 21                	push   $0x21
f010345a:	e9 92 09 00 00       	jmp    f0103df1 <_alltraps>
f010345f:	90                   	nop

f0103460 <trap_handler_placeholder34>:
	TRAPHANDLER_NOEC(trap_handler_placeholder34,34)
f0103460:	6a 00                	push   $0x0
f0103462:	6a 22                	push   $0x22
f0103464:	e9 88 09 00 00       	jmp    f0103df1 <_alltraps>
f0103469:	90                   	nop

f010346a <trap_handler_placeholder35>:
	TRAPHANDLER_NOEC(trap_handler_placeholder35,35)
f010346a:	6a 00                	push   $0x0
f010346c:	6a 23                	push   $0x23
f010346e:	e9 7e 09 00 00       	jmp    f0103df1 <_alltraps>
f0103473:	90                   	nop

f0103474 <trap_handler_placeholder36>:
	TRAPHANDLER_NOEC(trap_handler_placeholder36,36)
f0103474:	6a 00                	push   $0x0
f0103476:	6a 24                	push   $0x24
f0103478:	e9 74 09 00 00       	jmp    f0103df1 <_alltraps>
f010347d:	90                   	nop

f010347e <trap_handler_placeholder37>:
	TRAPHANDLER_NOEC(trap_handler_placeholder37,37)
f010347e:	6a 00                	push   $0x0
f0103480:	6a 25                	push   $0x25
f0103482:	e9 6a 09 00 00       	jmp    f0103df1 <_alltraps>
f0103487:	90                   	nop

f0103488 <trap_handler_placeholder38>:
	TRAPHANDLER_NOEC(trap_handler_placeholder38,38)
f0103488:	6a 00                	push   $0x0
f010348a:	6a 26                	push   $0x26
f010348c:	e9 60 09 00 00       	jmp    f0103df1 <_alltraps>
f0103491:	90                   	nop

f0103492 <trap_handler_placeholder39>:
	TRAPHANDLER_NOEC(trap_handler_placeholder39,39)
f0103492:	6a 00                	push   $0x0
f0103494:	6a 27                	push   $0x27
f0103496:	e9 56 09 00 00       	jmp    f0103df1 <_alltraps>
f010349b:	90                   	nop

f010349c <trap_handler_placeholder40>:
	TRAPHANDLER_NOEC(trap_handler_placeholder40,40)
f010349c:	6a 00                	push   $0x0
f010349e:	6a 28                	push   $0x28
f01034a0:	e9 4c 09 00 00       	jmp    f0103df1 <_alltraps>
f01034a5:	90                   	nop

f01034a6 <trap_handler_placeholder41>:
	TRAPHANDLER_NOEC(trap_handler_placeholder41,41)
f01034a6:	6a 00                	push   $0x0
f01034a8:	6a 29                	push   $0x29
f01034aa:	e9 42 09 00 00       	jmp    f0103df1 <_alltraps>
f01034af:	90                   	nop

f01034b0 <trap_handler_placeholder42>:
	TRAPHANDLER_NOEC(trap_handler_placeholder42,42)
f01034b0:	6a 00                	push   $0x0
f01034b2:	6a 2a                	push   $0x2a
f01034b4:	e9 38 09 00 00       	jmp    f0103df1 <_alltraps>
f01034b9:	90                   	nop

f01034ba <trap_handler_placeholder43>:
	TRAPHANDLER_NOEC(trap_handler_placeholder43,43)
f01034ba:	6a 00                	push   $0x0
f01034bc:	6a 2b                	push   $0x2b
f01034be:	e9 2e 09 00 00       	jmp    f0103df1 <_alltraps>
f01034c3:	90                   	nop

f01034c4 <trap_handler_placeholder44>:
	TRAPHANDLER_NOEC(trap_handler_placeholder44,44)
f01034c4:	6a 00                	push   $0x0
f01034c6:	6a 2c                	push   $0x2c
f01034c8:	e9 24 09 00 00       	jmp    f0103df1 <_alltraps>
f01034cd:	90                   	nop

f01034ce <trap_handler_placeholder45>:
	TRAPHANDLER_NOEC(trap_handler_placeholder45,45)
f01034ce:	6a 00                	push   $0x0
f01034d0:	6a 2d                	push   $0x2d
f01034d2:	e9 1a 09 00 00       	jmp    f0103df1 <_alltraps>
f01034d7:	90                   	nop

f01034d8 <trap_handler_placeholder46>:
	TRAPHANDLER_NOEC(trap_handler_placeholder46,46)
f01034d8:	6a 00                	push   $0x0
f01034da:	6a 2e                	push   $0x2e
f01034dc:	e9 10 09 00 00       	jmp    f0103df1 <_alltraps>
f01034e1:	90                   	nop

f01034e2 <trap_handler_placeholder47>:
	TRAPHANDLER_NOEC(trap_handler_placeholder47,47)
f01034e2:	6a 00                	push   $0x0
f01034e4:	6a 2f                	push   $0x2f
f01034e6:	e9 06 09 00 00       	jmp    f0103df1 <_alltraps>
f01034eb:	90                   	nop

f01034ec <system_call>:
	TRAPHANDLER_NOEC(system_call, T_SYSCALL)				# system call
f01034ec:	6a 00                	push   $0x0
f01034ee:	6a 30                	push   $0x30
f01034f0:	e9 fc 08 00 00       	jmp    f0103df1 <_alltraps>
f01034f5:	90                   	nop

f01034f6 <trap_handler_placeholder49>:
	TRAPHANDLER_NOEC(trap_handler_placeholder49,49)
f01034f6:	6a 00                	push   $0x0
f01034f8:	6a 31                	push   $0x31
f01034fa:	e9 f2 08 00 00       	jmp    f0103df1 <_alltraps>
f01034ff:	90                   	nop

f0103500 <trap_handler_placeholder50>:
	TRAPHANDLER_NOEC(trap_handler_placeholder50,50)
f0103500:	6a 00                	push   $0x0
f0103502:	6a 32                	push   $0x32
f0103504:	e9 e8 08 00 00       	jmp    f0103df1 <_alltraps>
f0103509:	90                   	nop

f010350a <trap_handler_placeholder51>:
	TRAPHANDLER_NOEC(trap_handler_placeholder51,51)
f010350a:	6a 00                	push   $0x0
f010350c:	6a 33                	push   $0x33
f010350e:	e9 de 08 00 00       	jmp    f0103df1 <_alltraps>
f0103513:	90                   	nop

f0103514 <trap_handler_placeholder52>:
	TRAPHANDLER_NOEC(trap_handler_placeholder52,52)
f0103514:	6a 00                	push   $0x0
f0103516:	6a 34                	push   $0x34
f0103518:	e9 d4 08 00 00       	jmp    f0103df1 <_alltraps>
f010351d:	90                   	nop

f010351e <trap_handler_placeholder53>:
	TRAPHANDLER_NOEC(trap_handler_placeholder53,53)
f010351e:	6a 00                	push   $0x0
f0103520:	6a 35                	push   $0x35
f0103522:	e9 ca 08 00 00       	jmp    f0103df1 <_alltraps>
f0103527:	90                   	nop

f0103528 <trap_handler_placeholder54>:
	TRAPHANDLER_NOEC(trap_handler_placeholder54,54)
f0103528:	6a 00                	push   $0x0
f010352a:	6a 36                	push   $0x36
f010352c:	e9 c0 08 00 00       	jmp    f0103df1 <_alltraps>
f0103531:	90                   	nop

f0103532 <trap_handler_placeholder55>:
	TRAPHANDLER_NOEC(trap_handler_placeholder55,55)
f0103532:	6a 00                	push   $0x0
f0103534:	6a 37                	push   $0x37
f0103536:	e9 b6 08 00 00       	jmp    f0103df1 <_alltraps>
f010353b:	90                   	nop

f010353c <trap_handler_placeholder56>:
	TRAPHANDLER_NOEC(trap_handler_placeholder56,56)
f010353c:	6a 00                	push   $0x0
f010353e:	6a 38                	push   $0x38
f0103540:	e9 ac 08 00 00       	jmp    f0103df1 <_alltraps>
f0103545:	90                   	nop

f0103546 <trap_handler_placeholder57>:
	TRAPHANDLER_NOEC(trap_handler_placeholder57,57)
f0103546:	6a 00                	push   $0x0
f0103548:	6a 39                	push   $0x39
f010354a:	e9 a2 08 00 00       	jmp    f0103df1 <_alltraps>
f010354f:	90                   	nop

f0103550 <trap_handler_placeholder58>:
	TRAPHANDLER_NOEC(trap_handler_placeholder58,58)
f0103550:	6a 00                	push   $0x0
f0103552:	6a 3a                	push   $0x3a
f0103554:	e9 98 08 00 00       	jmp    f0103df1 <_alltraps>
f0103559:	90                   	nop

f010355a <trap_handler_placeholder59>:
	TRAPHANDLER_NOEC(trap_handler_placeholder59,59)
f010355a:	6a 00                	push   $0x0
f010355c:	6a 3b                	push   $0x3b
f010355e:	e9 8e 08 00 00       	jmp    f0103df1 <_alltraps>
f0103563:	90                   	nop

f0103564 <trap_handler_placeholder60>:
	TRAPHANDLER_NOEC(trap_handler_placeholder60,60)
f0103564:	6a 00                	push   $0x0
f0103566:	6a 3c                	push   $0x3c
f0103568:	e9 84 08 00 00       	jmp    f0103df1 <_alltraps>
f010356d:	90                   	nop

f010356e <trap_handler_placeholder61>:
	TRAPHANDLER_NOEC(trap_handler_placeholder61,61)
f010356e:	6a 00                	push   $0x0
f0103570:	6a 3d                	push   $0x3d
f0103572:	e9 7a 08 00 00       	jmp    f0103df1 <_alltraps>
f0103577:	90                   	nop

f0103578 <trap_handler_placeholder62>:
	TRAPHANDLER_NOEC(trap_handler_placeholder62,62)
f0103578:	6a 00                	push   $0x0
f010357a:	6a 3e                	push   $0x3e
f010357c:	e9 70 08 00 00       	jmp    f0103df1 <_alltraps>
f0103581:	90                   	nop

f0103582 <trap_handler_placeholder63>:
	TRAPHANDLER_NOEC(trap_handler_placeholder63,63)
f0103582:	6a 00                	push   $0x0
f0103584:	6a 3f                	push   $0x3f
f0103586:	e9 66 08 00 00       	jmp    f0103df1 <_alltraps>
f010358b:	90                   	nop

f010358c <trap_handler_placeholder64>:
	TRAPHANDLER_NOEC(trap_handler_placeholder64,64)
f010358c:	6a 00                	push   $0x0
f010358e:	6a 40                	push   $0x40
f0103590:	e9 5c 08 00 00       	jmp    f0103df1 <_alltraps>
f0103595:	90                   	nop

f0103596 <trap_handler_placeholder65>:
	TRAPHANDLER_NOEC(trap_handler_placeholder65,65)
f0103596:	6a 00                	push   $0x0
f0103598:	6a 41                	push   $0x41
f010359a:	e9 52 08 00 00       	jmp    f0103df1 <_alltraps>
f010359f:	90                   	nop

f01035a0 <trap_handler_placeholder66>:
	TRAPHANDLER_NOEC(trap_handler_placeholder66,66)
f01035a0:	6a 00                	push   $0x0
f01035a2:	6a 42                	push   $0x42
f01035a4:	e9 48 08 00 00       	jmp    f0103df1 <_alltraps>
f01035a9:	90                   	nop

f01035aa <trap_handler_placeholder67>:
	TRAPHANDLER_NOEC(trap_handler_placeholder67,67)
f01035aa:	6a 00                	push   $0x0
f01035ac:	6a 43                	push   $0x43
f01035ae:	e9 3e 08 00 00       	jmp    f0103df1 <_alltraps>
f01035b3:	90                   	nop

f01035b4 <trap_handler_placeholder68>:
	TRAPHANDLER_NOEC(trap_handler_placeholder68,68)
f01035b4:	6a 00                	push   $0x0
f01035b6:	6a 44                	push   $0x44
f01035b8:	e9 34 08 00 00       	jmp    f0103df1 <_alltraps>
f01035bd:	90                   	nop

f01035be <trap_handler_placeholder69>:
	TRAPHANDLER_NOEC(trap_handler_placeholder69,69)
f01035be:	6a 00                	push   $0x0
f01035c0:	6a 45                	push   $0x45
f01035c2:	e9 2a 08 00 00       	jmp    f0103df1 <_alltraps>
f01035c7:	90                   	nop

f01035c8 <trap_handler_placeholder70>:
	TRAPHANDLER_NOEC(trap_handler_placeholder70,70)
f01035c8:	6a 00                	push   $0x0
f01035ca:	6a 46                	push   $0x46
f01035cc:	e9 20 08 00 00       	jmp    f0103df1 <_alltraps>
f01035d1:	90                   	nop

f01035d2 <trap_handler_placeholder71>:
	TRAPHANDLER_NOEC(trap_handler_placeholder71,71)
f01035d2:	6a 00                	push   $0x0
f01035d4:	6a 47                	push   $0x47
f01035d6:	e9 16 08 00 00       	jmp    f0103df1 <_alltraps>
f01035db:	90                   	nop

f01035dc <trap_handler_placeholder72>:
	TRAPHANDLER_NOEC(trap_handler_placeholder72,72)
f01035dc:	6a 00                	push   $0x0
f01035de:	6a 48                	push   $0x48
f01035e0:	e9 0c 08 00 00       	jmp    f0103df1 <_alltraps>
f01035e5:	90                   	nop

f01035e6 <trap_handler_placeholder73>:
	TRAPHANDLER_NOEC(trap_handler_placeholder73,73)
f01035e6:	6a 00                	push   $0x0
f01035e8:	6a 49                	push   $0x49
f01035ea:	e9 02 08 00 00       	jmp    f0103df1 <_alltraps>
f01035ef:	90                   	nop

f01035f0 <trap_handler_placeholder74>:
	TRAPHANDLER_NOEC(trap_handler_placeholder74,74)
f01035f0:	6a 00                	push   $0x0
f01035f2:	6a 4a                	push   $0x4a
f01035f4:	e9 f8 07 00 00       	jmp    f0103df1 <_alltraps>
f01035f9:	90                   	nop

f01035fa <trap_handler_placeholder75>:
	TRAPHANDLER_NOEC(trap_handler_placeholder75,75)
f01035fa:	6a 00                	push   $0x0
f01035fc:	6a 4b                	push   $0x4b
f01035fe:	e9 ee 07 00 00       	jmp    f0103df1 <_alltraps>
f0103603:	90                   	nop

f0103604 <trap_handler_placeholder76>:
	TRAPHANDLER_NOEC(trap_handler_placeholder76,76)
f0103604:	6a 00                	push   $0x0
f0103606:	6a 4c                	push   $0x4c
f0103608:	e9 e4 07 00 00       	jmp    f0103df1 <_alltraps>
f010360d:	90                   	nop

f010360e <trap_handler_placeholder77>:
	TRAPHANDLER_NOEC(trap_handler_placeholder77,77)
f010360e:	6a 00                	push   $0x0
f0103610:	6a 4d                	push   $0x4d
f0103612:	e9 da 07 00 00       	jmp    f0103df1 <_alltraps>
f0103617:	90                   	nop

f0103618 <trap_handler_placeholder78>:
	TRAPHANDLER_NOEC(trap_handler_placeholder78,78)
f0103618:	6a 00                	push   $0x0
f010361a:	6a 4e                	push   $0x4e
f010361c:	e9 d0 07 00 00       	jmp    f0103df1 <_alltraps>
f0103621:	90                   	nop

f0103622 <trap_handler_placeholder79>:
	TRAPHANDLER_NOEC(trap_handler_placeholder79,79)
f0103622:	6a 00                	push   $0x0
f0103624:	6a 4f                	push   $0x4f
f0103626:	e9 c6 07 00 00       	jmp    f0103df1 <_alltraps>
f010362b:	90                   	nop

f010362c <trap_handler_placeholder80>:
	TRAPHANDLER_NOEC(trap_handler_placeholder80,80)
f010362c:	6a 00                	push   $0x0
f010362e:	6a 50                	push   $0x50
f0103630:	e9 bc 07 00 00       	jmp    f0103df1 <_alltraps>
f0103635:	90                   	nop

f0103636 <trap_handler_placeholder81>:
	TRAPHANDLER_NOEC(trap_handler_placeholder81,81)
f0103636:	6a 00                	push   $0x0
f0103638:	6a 51                	push   $0x51
f010363a:	e9 b2 07 00 00       	jmp    f0103df1 <_alltraps>
f010363f:	90                   	nop

f0103640 <trap_handler_placeholder82>:
	TRAPHANDLER_NOEC(trap_handler_placeholder82,82)
f0103640:	6a 00                	push   $0x0
f0103642:	6a 52                	push   $0x52
f0103644:	e9 a8 07 00 00       	jmp    f0103df1 <_alltraps>
f0103649:	90                   	nop

f010364a <trap_handler_placeholder83>:
	TRAPHANDLER_NOEC(trap_handler_placeholder83,83)
f010364a:	6a 00                	push   $0x0
f010364c:	6a 53                	push   $0x53
f010364e:	e9 9e 07 00 00       	jmp    f0103df1 <_alltraps>
f0103653:	90                   	nop

f0103654 <trap_handler_placeholder84>:
	TRAPHANDLER_NOEC(trap_handler_placeholder84,84)
f0103654:	6a 00                	push   $0x0
f0103656:	6a 54                	push   $0x54
f0103658:	e9 94 07 00 00       	jmp    f0103df1 <_alltraps>
f010365d:	90                   	nop

f010365e <trap_handler_placeholder85>:
	TRAPHANDLER_NOEC(trap_handler_placeholder85,85)
f010365e:	6a 00                	push   $0x0
f0103660:	6a 55                	push   $0x55
f0103662:	e9 8a 07 00 00       	jmp    f0103df1 <_alltraps>
f0103667:	90                   	nop

f0103668 <trap_handler_placeholder86>:
	TRAPHANDLER_NOEC(trap_handler_placeholder86,86)
f0103668:	6a 00                	push   $0x0
f010366a:	6a 56                	push   $0x56
f010366c:	e9 80 07 00 00       	jmp    f0103df1 <_alltraps>
f0103671:	90                   	nop

f0103672 <trap_handler_placeholder87>:
	TRAPHANDLER_NOEC(trap_handler_placeholder87,87)
f0103672:	6a 00                	push   $0x0
f0103674:	6a 57                	push   $0x57
f0103676:	e9 76 07 00 00       	jmp    f0103df1 <_alltraps>
f010367b:	90                   	nop

f010367c <trap_handler_placeholder88>:
	TRAPHANDLER_NOEC(trap_handler_placeholder88,88)
f010367c:	6a 00                	push   $0x0
f010367e:	6a 58                	push   $0x58
f0103680:	e9 6c 07 00 00       	jmp    f0103df1 <_alltraps>
f0103685:	90                   	nop

f0103686 <trap_handler_placeholder89>:
	TRAPHANDLER_NOEC(trap_handler_placeholder89,89)
f0103686:	6a 00                	push   $0x0
f0103688:	6a 59                	push   $0x59
f010368a:	e9 62 07 00 00       	jmp    f0103df1 <_alltraps>
f010368f:	90                   	nop

f0103690 <trap_handler_placeholder90>:
	TRAPHANDLER_NOEC(trap_handler_placeholder90,90)
f0103690:	6a 00                	push   $0x0
f0103692:	6a 5a                	push   $0x5a
f0103694:	e9 58 07 00 00       	jmp    f0103df1 <_alltraps>
f0103699:	90                   	nop

f010369a <trap_handler_placeholder91>:
	TRAPHANDLER_NOEC(trap_handler_placeholder91,91)
f010369a:	6a 00                	push   $0x0
f010369c:	6a 5b                	push   $0x5b
f010369e:	e9 4e 07 00 00       	jmp    f0103df1 <_alltraps>
f01036a3:	90                   	nop

f01036a4 <trap_handler_placeholder92>:
	TRAPHANDLER_NOEC(trap_handler_placeholder92,92)
f01036a4:	6a 00                	push   $0x0
f01036a6:	6a 5c                	push   $0x5c
f01036a8:	e9 44 07 00 00       	jmp    f0103df1 <_alltraps>
f01036ad:	90                   	nop

f01036ae <trap_handler_placeholder93>:
	TRAPHANDLER_NOEC(trap_handler_placeholder93,93)
f01036ae:	6a 00                	push   $0x0
f01036b0:	6a 5d                	push   $0x5d
f01036b2:	e9 3a 07 00 00       	jmp    f0103df1 <_alltraps>
f01036b7:	90                   	nop

f01036b8 <trap_handler_placeholder94>:
	TRAPHANDLER_NOEC(trap_handler_placeholder94,94)
f01036b8:	6a 00                	push   $0x0
f01036ba:	6a 5e                	push   $0x5e
f01036bc:	e9 30 07 00 00       	jmp    f0103df1 <_alltraps>
f01036c1:	90                   	nop

f01036c2 <trap_handler_placeholder95>:
	TRAPHANDLER_NOEC(trap_handler_placeholder95,95)
f01036c2:	6a 00                	push   $0x0
f01036c4:	6a 5f                	push   $0x5f
f01036c6:	e9 26 07 00 00       	jmp    f0103df1 <_alltraps>
f01036cb:	90                   	nop

f01036cc <trap_handler_placeholder96>:
	TRAPHANDLER_NOEC(trap_handler_placeholder96,96)
f01036cc:	6a 00                	push   $0x0
f01036ce:	6a 60                	push   $0x60
f01036d0:	e9 1c 07 00 00       	jmp    f0103df1 <_alltraps>
f01036d5:	90                   	nop

f01036d6 <trap_handler_placeholder97>:
	TRAPHANDLER_NOEC(trap_handler_placeholder97,97)
f01036d6:	6a 00                	push   $0x0
f01036d8:	6a 61                	push   $0x61
f01036da:	e9 12 07 00 00       	jmp    f0103df1 <_alltraps>
f01036df:	90                   	nop

f01036e0 <trap_handler_placeholder98>:
	TRAPHANDLER_NOEC(trap_handler_placeholder98,98)
f01036e0:	6a 00                	push   $0x0
f01036e2:	6a 62                	push   $0x62
f01036e4:	e9 08 07 00 00       	jmp    f0103df1 <_alltraps>
f01036e9:	90                   	nop

f01036ea <trap_handler_placeholder99>:
	TRAPHANDLER_NOEC(trap_handler_placeholder99,99)
f01036ea:	6a 00                	push   $0x0
f01036ec:	6a 63                	push   $0x63
f01036ee:	e9 fe 06 00 00       	jmp    f0103df1 <_alltraps>
f01036f3:	90                   	nop

f01036f4 <trap_handler_placeholder100>:
	TRAPHANDLER_NOEC(trap_handler_placeholder100,100)
f01036f4:	6a 00                	push   $0x0
f01036f6:	6a 64                	push   $0x64
f01036f8:	e9 f4 06 00 00       	jmp    f0103df1 <_alltraps>
f01036fd:	90                   	nop

f01036fe <trap_handler_placeholder101>:
	TRAPHANDLER_NOEC(trap_handler_placeholder101,101)
f01036fe:	6a 00                	push   $0x0
f0103700:	6a 65                	push   $0x65
f0103702:	e9 ea 06 00 00       	jmp    f0103df1 <_alltraps>
f0103707:	90                   	nop

f0103708 <trap_handler_placeholder102>:
	TRAPHANDLER_NOEC(trap_handler_placeholder102,102)
f0103708:	6a 00                	push   $0x0
f010370a:	6a 66                	push   $0x66
f010370c:	e9 e0 06 00 00       	jmp    f0103df1 <_alltraps>
f0103711:	90                   	nop

f0103712 <trap_handler_placeholder103>:
	TRAPHANDLER_NOEC(trap_handler_placeholder103,103)
f0103712:	6a 00                	push   $0x0
f0103714:	6a 67                	push   $0x67
f0103716:	e9 d6 06 00 00       	jmp    f0103df1 <_alltraps>
f010371b:	90                   	nop

f010371c <trap_handler_placeholder104>:
	TRAPHANDLER_NOEC(trap_handler_placeholder104,104)
f010371c:	6a 00                	push   $0x0
f010371e:	6a 68                	push   $0x68
f0103720:	e9 cc 06 00 00       	jmp    f0103df1 <_alltraps>
f0103725:	90                   	nop

f0103726 <trap_handler_placeholder105>:
	TRAPHANDLER_NOEC(trap_handler_placeholder105,105)
f0103726:	6a 00                	push   $0x0
f0103728:	6a 69                	push   $0x69
f010372a:	e9 c2 06 00 00       	jmp    f0103df1 <_alltraps>
f010372f:	90                   	nop

f0103730 <trap_handler_placeholder106>:
	TRAPHANDLER_NOEC(trap_handler_placeholder106,106)
f0103730:	6a 00                	push   $0x0
f0103732:	6a 6a                	push   $0x6a
f0103734:	e9 b8 06 00 00       	jmp    f0103df1 <_alltraps>
f0103739:	90                   	nop

f010373a <trap_handler_placeholder107>:
	TRAPHANDLER_NOEC(trap_handler_placeholder107,107)
f010373a:	6a 00                	push   $0x0
f010373c:	6a 6b                	push   $0x6b
f010373e:	e9 ae 06 00 00       	jmp    f0103df1 <_alltraps>
f0103743:	90                   	nop

f0103744 <trap_handler_placeholder108>:
	TRAPHANDLER_NOEC(trap_handler_placeholder108,108)
f0103744:	6a 00                	push   $0x0
f0103746:	6a 6c                	push   $0x6c
f0103748:	e9 a4 06 00 00       	jmp    f0103df1 <_alltraps>
f010374d:	90                   	nop

f010374e <trap_handler_placeholder109>:
	TRAPHANDLER_NOEC(trap_handler_placeholder109,109)
f010374e:	6a 00                	push   $0x0
f0103750:	6a 6d                	push   $0x6d
f0103752:	e9 9a 06 00 00       	jmp    f0103df1 <_alltraps>
f0103757:	90                   	nop

f0103758 <trap_handler_placeholder110>:
	TRAPHANDLER_NOEC(trap_handler_placeholder110,110)
f0103758:	6a 00                	push   $0x0
f010375a:	6a 6e                	push   $0x6e
f010375c:	e9 90 06 00 00       	jmp    f0103df1 <_alltraps>
f0103761:	90                   	nop

f0103762 <trap_handler_placeholder111>:
	TRAPHANDLER_NOEC(trap_handler_placeholder111,111)
f0103762:	6a 00                	push   $0x0
f0103764:	6a 6f                	push   $0x6f
f0103766:	e9 86 06 00 00       	jmp    f0103df1 <_alltraps>
f010376b:	90                   	nop

f010376c <trap_handler_placeholder112>:
	TRAPHANDLER_NOEC(trap_handler_placeholder112,112)
f010376c:	6a 00                	push   $0x0
f010376e:	6a 70                	push   $0x70
f0103770:	e9 7c 06 00 00       	jmp    f0103df1 <_alltraps>
f0103775:	90                   	nop

f0103776 <trap_handler_placeholder113>:
	TRAPHANDLER_NOEC(trap_handler_placeholder113,113)
f0103776:	6a 00                	push   $0x0
f0103778:	6a 71                	push   $0x71
f010377a:	e9 72 06 00 00       	jmp    f0103df1 <_alltraps>
f010377f:	90                   	nop

f0103780 <trap_handler_placeholder114>:
	TRAPHANDLER_NOEC(trap_handler_placeholder114,114)
f0103780:	6a 00                	push   $0x0
f0103782:	6a 72                	push   $0x72
f0103784:	e9 68 06 00 00       	jmp    f0103df1 <_alltraps>
f0103789:	90                   	nop

f010378a <trap_handler_placeholder115>:
	TRAPHANDLER_NOEC(trap_handler_placeholder115,115)
f010378a:	6a 00                	push   $0x0
f010378c:	6a 73                	push   $0x73
f010378e:	e9 5e 06 00 00       	jmp    f0103df1 <_alltraps>
f0103793:	90                   	nop

f0103794 <trap_handler_placeholder116>:
	TRAPHANDLER_NOEC(trap_handler_placeholder116,116)
f0103794:	6a 00                	push   $0x0
f0103796:	6a 74                	push   $0x74
f0103798:	e9 54 06 00 00       	jmp    f0103df1 <_alltraps>
f010379d:	90                   	nop

f010379e <trap_handler_placeholder117>:
	TRAPHANDLER_NOEC(trap_handler_placeholder117,117)
f010379e:	6a 00                	push   $0x0
f01037a0:	6a 75                	push   $0x75
f01037a2:	e9 4a 06 00 00       	jmp    f0103df1 <_alltraps>
f01037a7:	90                   	nop

f01037a8 <trap_handler_placeholder118>:
	TRAPHANDLER_NOEC(trap_handler_placeholder118,118)
f01037a8:	6a 00                	push   $0x0
f01037aa:	6a 76                	push   $0x76
f01037ac:	e9 40 06 00 00       	jmp    f0103df1 <_alltraps>
f01037b1:	90                   	nop

f01037b2 <trap_handler_placeholder119>:
	TRAPHANDLER_NOEC(trap_handler_placeholder119,119)
f01037b2:	6a 00                	push   $0x0
f01037b4:	6a 77                	push   $0x77
f01037b6:	e9 36 06 00 00       	jmp    f0103df1 <_alltraps>
f01037bb:	90                   	nop

f01037bc <trap_handler_placeholder120>:
	TRAPHANDLER_NOEC(trap_handler_placeholder120,120)
f01037bc:	6a 00                	push   $0x0
f01037be:	6a 78                	push   $0x78
f01037c0:	e9 2c 06 00 00       	jmp    f0103df1 <_alltraps>
f01037c5:	90                   	nop

f01037c6 <trap_handler_placeholder121>:
	TRAPHANDLER_NOEC(trap_handler_placeholder121,121)
f01037c6:	6a 00                	push   $0x0
f01037c8:	6a 79                	push   $0x79
f01037ca:	e9 22 06 00 00       	jmp    f0103df1 <_alltraps>
f01037cf:	90                   	nop

f01037d0 <trap_handler_placeholder122>:
	TRAPHANDLER_NOEC(trap_handler_placeholder122,122)
f01037d0:	6a 00                	push   $0x0
f01037d2:	6a 7a                	push   $0x7a
f01037d4:	e9 18 06 00 00       	jmp    f0103df1 <_alltraps>
f01037d9:	90                   	nop

f01037da <trap_handler_placeholder123>:
	TRAPHANDLER_NOEC(trap_handler_placeholder123,123)
f01037da:	6a 00                	push   $0x0
f01037dc:	6a 7b                	push   $0x7b
f01037de:	e9 0e 06 00 00       	jmp    f0103df1 <_alltraps>
f01037e3:	90                   	nop

f01037e4 <trap_handler_placeholder124>:
	TRAPHANDLER_NOEC(trap_handler_placeholder124,124)
f01037e4:	6a 00                	push   $0x0
f01037e6:	6a 7c                	push   $0x7c
f01037e8:	e9 04 06 00 00       	jmp    f0103df1 <_alltraps>
f01037ed:	90                   	nop

f01037ee <trap_handler_placeholder125>:
	TRAPHANDLER_NOEC(trap_handler_placeholder125,125)
f01037ee:	6a 00                	push   $0x0
f01037f0:	6a 7d                	push   $0x7d
f01037f2:	e9 fa 05 00 00       	jmp    f0103df1 <_alltraps>
f01037f7:	90                   	nop

f01037f8 <trap_handler_placeholder126>:
	TRAPHANDLER_NOEC(trap_handler_placeholder126,126)
f01037f8:	6a 00                	push   $0x0
f01037fa:	6a 7e                	push   $0x7e
f01037fc:	e9 f0 05 00 00       	jmp    f0103df1 <_alltraps>
f0103801:	90                   	nop

f0103802 <trap_handler_placeholder127>:
	TRAPHANDLER_NOEC(trap_handler_placeholder127,127)
f0103802:	6a 00                	push   $0x0
f0103804:	6a 7f                	push   $0x7f
f0103806:	e9 e6 05 00 00       	jmp    f0103df1 <_alltraps>
f010380b:	90                   	nop

f010380c <trap_handler_placeholder128>:
	TRAPHANDLER_NOEC(trap_handler_placeholder128,128)
f010380c:	6a 00                	push   $0x0
f010380e:	68 80 00 00 00       	push   $0x80
f0103813:	e9 d9 05 00 00       	jmp    f0103df1 <_alltraps>

f0103818 <trap_handler_placeholder129>:
	TRAPHANDLER_NOEC(trap_handler_placeholder129,129)
f0103818:	6a 00                	push   $0x0
f010381a:	68 81 00 00 00       	push   $0x81
f010381f:	e9 cd 05 00 00       	jmp    f0103df1 <_alltraps>

f0103824 <trap_handler_placeholder130>:
	TRAPHANDLER_NOEC(trap_handler_placeholder130,130)
f0103824:	6a 00                	push   $0x0
f0103826:	68 82 00 00 00       	push   $0x82
f010382b:	e9 c1 05 00 00       	jmp    f0103df1 <_alltraps>

f0103830 <trap_handler_placeholder131>:
	TRAPHANDLER_NOEC(trap_handler_placeholder131,131)
f0103830:	6a 00                	push   $0x0
f0103832:	68 83 00 00 00       	push   $0x83
f0103837:	e9 b5 05 00 00       	jmp    f0103df1 <_alltraps>

f010383c <trap_handler_placeholder132>:
	TRAPHANDLER_NOEC(trap_handler_placeholder132,132)
f010383c:	6a 00                	push   $0x0
f010383e:	68 84 00 00 00       	push   $0x84
f0103843:	e9 a9 05 00 00       	jmp    f0103df1 <_alltraps>

f0103848 <trap_handler_placeholder133>:
	TRAPHANDLER_NOEC(trap_handler_placeholder133,133)
f0103848:	6a 00                	push   $0x0
f010384a:	68 85 00 00 00       	push   $0x85
f010384f:	e9 9d 05 00 00       	jmp    f0103df1 <_alltraps>

f0103854 <trap_handler_placeholder134>:
	TRAPHANDLER_NOEC(trap_handler_placeholder134,134)
f0103854:	6a 00                	push   $0x0
f0103856:	68 86 00 00 00       	push   $0x86
f010385b:	e9 91 05 00 00       	jmp    f0103df1 <_alltraps>

f0103860 <trap_handler_placeholder135>:
	TRAPHANDLER_NOEC(trap_handler_placeholder135,135)
f0103860:	6a 00                	push   $0x0
f0103862:	68 87 00 00 00       	push   $0x87
f0103867:	e9 85 05 00 00       	jmp    f0103df1 <_alltraps>

f010386c <trap_handler_placeholder136>:
	TRAPHANDLER_NOEC(trap_handler_placeholder136,136)
f010386c:	6a 00                	push   $0x0
f010386e:	68 88 00 00 00       	push   $0x88
f0103873:	e9 79 05 00 00       	jmp    f0103df1 <_alltraps>

f0103878 <trap_handler_placeholder137>:
	TRAPHANDLER_NOEC(trap_handler_placeholder137,137)
f0103878:	6a 00                	push   $0x0
f010387a:	68 89 00 00 00       	push   $0x89
f010387f:	e9 6d 05 00 00       	jmp    f0103df1 <_alltraps>

f0103884 <trap_handler_placeholder138>:
	TRAPHANDLER_NOEC(trap_handler_placeholder138,138)
f0103884:	6a 00                	push   $0x0
f0103886:	68 8a 00 00 00       	push   $0x8a
f010388b:	e9 61 05 00 00       	jmp    f0103df1 <_alltraps>

f0103890 <trap_handler_placeholder139>:
	TRAPHANDLER_NOEC(trap_handler_placeholder139,139)
f0103890:	6a 00                	push   $0x0
f0103892:	68 8b 00 00 00       	push   $0x8b
f0103897:	e9 55 05 00 00       	jmp    f0103df1 <_alltraps>

f010389c <trap_handler_placeholder140>:
	TRAPHANDLER_NOEC(trap_handler_placeholder140,140)
f010389c:	6a 00                	push   $0x0
f010389e:	68 8c 00 00 00       	push   $0x8c
f01038a3:	e9 49 05 00 00       	jmp    f0103df1 <_alltraps>

f01038a8 <trap_handler_placeholder141>:
	TRAPHANDLER_NOEC(trap_handler_placeholder141,141)
f01038a8:	6a 00                	push   $0x0
f01038aa:	68 8d 00 00 00       	push   $0x8d
f01038af:	e9 3d 05 00 00       	jmp    f0103df1 <_alltraps>

f01038b4 <trap_handler_placeholder142>:
	TRAPHANDLER_NOEC(trap_handler_placeholder142,142)
f01038b4:	6a 00                	push   $0x0
f01038b6:	68 8e 00 00 00       	push   $0x8e
f01038bb:	e9 31 05 00 00       	jmp    f0103df1 <_alltraps>

f01038c0 <trap_handler_placeholder143>:
	TRAPHANDLER_NOEC(trap_handler_placeholder143,143)
f01038c0:	6a 00                	push   $0x0
f01038c2:	68 8f 00 00 00       	push   $0x8f
f01038c7:	e9 25 05 00 00       	jmp    f0103df1 <_alltraps>

f01038cc <trap_handler_placeholder144>:
	TRAPHANDLER_NOEC(trap_handler_placeholder144,144)
f01038cc:	6a 00                	push   $0x0
f01038ce:	68 90 00 00 00       	push   $0x90
f01038d3:	e9 19 05 00 00       	jmp    f0103df1 <_alltraps>

f01038d8 <trap_handler_placeholder145>:
	TRAPHANDLER_NOEC(trap_handler_placeholder145,145)
f01038d8:	6a 00                	push   $0x0
f01038da:	68 91 00 00 00       	push   $0x91
f01038df:	e9 0d 05 00 00       	jmp    f0103df1 <_alltraps>

f01038e4 <trap_handler_placeholder146>:
	TRAPHANDLER_NOEC(trap_handler_placeholder146,146)
f01038e4:	6a 00                	push   $0x0
f01038e6:	68 92 00 00 00       	push   $0x92
f01038eb:	e9 01 05 00 00       	jmp    f0103df1 <_alltraps>

f01038f0 <trap_handler_placeholder147>:
	TRAPHANDLER_NOEC(trap_handler_placeholder147,147)
f01038f0:	6a 00                	push   $0x0
f01038f2:	68 93 00 00 00       	push   $0x93
f01038f7:	e9 f5 04 00 00       	jmp    f0103df1 <_alltraps>

f01038fc <trap_handler_placeholder148>:
	TRAPHANDLER_NOEC(trap_handler_placeholder148,148)
f01038fc:	6a 00                	push   $0x0
f01038fe:	68 94 00 00 00       	push   $0x94
f0103903:	e9 e9 04 00 00       	jmp    f0103df1 <_alltraps>

f0103908 <trap_handler_placeholder149>:
	TRAPHANDLER_NOEC(trap_handler_placeholder149,149)
f0103908:	6a 00                	push   $0x0
f010390a:	68 95 00 00 00       	push   $0x95
f010390f:	e9 dd 04 00 00       	jmp    f0103df1 <_alltraps>

f0103914 <trap_handler_placeholder150>:
	TRAPHANDLER_NOEC(trap_handler_placeholder150,150)
f0103914:	6a 00                	push   $0x0
f0103916:	68 96 00 00 00       	push   $0x96
f010391b:	e9 d1 04 00 00       	jmp    f0103df1 <_alltraps>

f0103920 <trap_handler_placeholder151>:
	TRAPHANDLER_NOEC(trap_handler_placeholder151,151)
f0103920:	6a 00                	push   $0x0
f0103922:	68 97 00 00 00       	push   $0x97
f0103927:	e9 c5 04 00 00       	jmp    f0103df1 <_alltraps>

f010392c <trap_handler_placeholder152>:
	TRAPHANDLER_NOEC(trap_handler_placeholder152,152)
f010392c:	6a 00                	push   $0x0
f010392e:	68 98 00 00 00       	push   $0x98
f0103933:	e9 b9 04 00 00       	jmp    f0103df1 <_alltraps>

f0103938 <trap_handler_placeholder153>:
	TRAPHANDLER_NOEC(trap_handler_placeholder153,153)
f0103938:	6a 00                	push   $0x0
f010393a:	68 99 00 00 00       	push   $0x99
f010393f:	e9 ad 04 00 00       	jmp    f0103df1 <_alltraps>

f0103944 <trap_handler_placeholder154>:
	TRAPHANDLER_NOEC(trap_handler_placeholder154,154)
f0103944:	6a 00                	push   $0x0
f0103946:	68 9a 00 00 00       	push   $0x9a
f010394b:	e9 a1 04 00 00       	jmp    f0103df1 <_alltraps>

f0103950 <trap_handler_placeholder155>:
	TRAPHANDLER_NOEC(trap_handler_placeholder155,155)
f0103950:	6a 00                	push   $0x0
f0103952:	68 9b 00 00 00       	push   $0x9b
f0103957:	e9 95 04 00 00       	jmp    f0103df1 <_alltraps>

f010395c <trap_handler_placeholder156>:
	TRAPHANDLER_NOEC(trap_handler_placeholder156,156)
f010395c:	6a 00                	push   $0x0
f010395e:	68 9c 00 00 00       	push   $0x9c
f0103963:	e9 89 04 00 00       	jmp    f0103df1 <_alltraps>

f0103968 <trap_handler_placeholder157>:
	TRAPHANDLER_NOEC(trap_handler_placeholder157,157)
f0103968:	6a 00                	push   $0x0
f010396a:	68 9d 00 00 00       	push   $0x9d
f010396f:	e9 7d 04 00 00       	jmp    f0103df1 <_alltraps>

f0103974 <trap_handler_placeholder158>:
	TRAPHANDLER_NOEC(trap_handler_placeholder158,158)
f0103974:	6a 00                	push   $0x0
f0103976:	68 9e 00 00 00       	push   $0x9e
f010397b:	e9 71 04 00 00       	jmp    f0103df1 <_alltraps>

f0103980 <trap_handler_placeholder159>:
	TRAPHANDLER_NOEC(trap_handler_placeholder159,159)
f0103980:	6a 00                	push   $0x0
f0103982:	68 9f 00 00 00       	push   $0x9f
f0103987:	e9 65 04 00 00       	jmp    f0103df1 <_alltraps>

f010398c <trap_handler_placeholder160>:
	TRAPHANDLER_NOEC(trap_handler_placeholder160,160)
f010398c:	6a 00                	push   $0x0
f010398e:	68 a0 00 00 00       	push   $0xa0
f0103993:	e9 59 04 00 00       	jmp    f0103df1 <_alltraps>

f0103998 <trap_handler_placeholder161>:
	TRAPHANDLER_NOEC(trap_handler_placeholder161,161)
f0103998:	6a 00                	push   $0x0
f010399a:	68 a1 00 00 00       	push   $0xa1
f010399f:	e9 4d 04 00 00       	jmp    f0103df1 <_alltraps>

f01039a4 <trap_handler_placeholder162>:
	TRAPHANDLER_NOEC(trap_handler_placeholder162,162)
f01039a4:	6a 00                	push   $0x0
f01039a6:	68 a2 00 00 00       	push   $0xa2
f01039ab:	e9 41 04 00 00       	jmp    f0103df1 <_alltraps>

f01039b0 <trap_handler_placeholder163>:
	TRAPHANDLER_NOEC(trap_handler_placeholder163,163)
f01039b0:	6a 00                	push   $0x0
f01039b2:	68 a3 00 00 00       	push   $0xa3
f01039b7:	e9 35 04 00 00       	jmp    f0103df1 <_alltraps>

f01039bc <trap_handler_placeholder164>:
	TRAPHANDLER_NOEC(trap_handler_placeholder164,164)
f01039bc:	6a 00                	push   $0x0
f01039be:	68 a4 00 00 00       	push   $0xa4
f01039c3:	e9 29 04 00 00       	jmp    f0103df1 <_alltraps>

f01039c8 <trap_handler_placeholder165>:
	TRAPHANDLER_NOEC(trap_handler_placeholder165,165)
f01039c8:	6a 00                	push   $0x0
f01039ca:	68 a5 00 00 00       	push   $0xa5
f01039cf:	e9 1d 04 00 00       	jmp    f0103df1 <_alltraps>

f01039d4 <trap_handler_placeholder166>:
	TRAPHANDLER_NOEC(trap_handler_placeholder166,166)
f01039d4:	6a 00                	push   $0x0
f01039d6:	68 a6 00 00 00       	push   $0xa6
f01039db:	e9 11 04 00 00       	jmp    f0103df1 <_alltraps>

f01039e0 <trap_handler_placeholder167>:
	TRAPHANDLER_NOEC(trap_handler_placeholder167,167)
f01039e0:	6a 00                	push   $0x0
f01039e2:	68 a7 00 00 00       	push   $0xa7
f01039e7:	e9 05 04 00 00       	jmp    f0103df1 <_alltraps>

f01039ec <trap_handler_placeholder168>:
	TRAPHANDLER_NOEC(trap_handler_placeholder168,168)
f01039ec:	6a 00                	push   $0x0
f01039ee:	68 a8 00 00 00       	push   $0xa8
f01039f3:	e9 f9 03 00 00       	jmp    f0103df1 <_alltraps>

f01039f8 <trap_handler_placeholder169>:
	TRAPHANDLER_NOEC(trap_handler_placeholder169,169)
f01039f8:	6a 00                	push   $0x0
f01039fa:	68 a9 00 00 00       	push   $0xa9
f01039ff:	e9 ed 03 00 00       	jmp    f0103df1 <_alltraps>

f0103a04 <trap_handler_placeholder170>:
	TRAPHANDLER_NOEC(trap_handler_placeholder170,170)
f0103a04:	6a 00                	push   $0x0
f0103a06:	68 aa 00 00 00       	push   $0xaa
f0103a0b:	e9 e1 03 00 00       	jmp    f0103df1 <_alltraps>

f0103a10 <trap_handler_placeholder171>:
	TRAPHANDLER_NOEC(trap_handler_placeholder171,171)
f0103a10:	6a 00                	push   $0x0
f0103a12:	68 ab 00 00 00       	push   $0xab
f0103a17:	e9 d5 03 00 00       	jmp    f0103df1 <_alltraps>

f0103a1c <trap_handler_placeholder172>:
	TRAPHANDLER_NOEC(trap_handler_placeholder172,172)
f0103a1c:	6a 00                	push   $0x0
f0103a1e:	68 ac 00 00 00       	push   $0xac
f0103a23:	e9 c9 03 00 00       	jmp    f0103df1 <_alltraps>

f0103a28 <trap_handler_placeholder173>:
	TRAPHANDLER_NOEC(trap_handler_placeholder173,173)
f0103a28:	6a 00                	push   $0x0
f0103a2a:	68 ad 00 00 00       	push   $0xad
f0103a2f:	e9 bd 03 00 00       	jmp    f0103df1 <_alltraps>

f0103a34 <trap_handler_placeholder174>:
	TRAPHANDLER_NOEC(trap_handler_placeholder174,174)
f0103a34:	6a 00                	push   $0x0
f0103a36:	68 ae 00 00 00       	push   $0xae
f0103a3b:	e9 b1 03 00 00       	jmp    f0103df1 <_alltraps>

f0103a40 <trap_handler_placeholder175>:
	TRAPHANDLER_NOEC(trap_handler_placeholder175,175)
f0103a40:	6a 00                	push   $0x0
f0103a42:	68 af 00 00 00       	push   $0xaf
f0103a47:	e9 a5 03 00 00       	jmp    f0103df1 <_alltraps>

f0103a4c <trap_handler_placeholder176>:
	TRAPHANDLER_NOEC(trap_handler_placeholder176,176)
f0103a4c:	6a 00                	push   $0x0
f0103a4e:	68 b0 00 00 00       	push   $0xb0
f0103a53:	e9 99 03 00 00       	jmp    f0103df1 <_alltraps>

f0103a58 <trap_handler_placeholder177>:
	TRAPHANDLER_NOEC(trap_handler_placeholder177,177)
f0103a58:	6a 00                	push   $0x0
f0103a5a:	68 b1 00 00 00       	push   $0xb1
f0103a5f:	e9 8d 03 00 00       	jmp    f0103df1 <_alltraps>

f0103a64 <trap_handler_placeholder178>:
	TRAPHANDLER_NOEC(trap_handler_placeholder178,178)
f0103a64:	6a 00                	push   $0x0
f0103a66:	68 b2 00 00 00       	push   $0xb2
f0103a6b:	e9 81 03 00 00       	jmp    f0103df1 <_alltraps>

f0103a70 <trap_handler_placeholder179>:
	TRAPHANDLER_NOEC(trap_handler_placeholder179,179)
f0103a70:	6a 00                	push   $0x0
f0103a72:	68 b3 00 00 00       	push   $0xb3
f0103a77:	e9 75 03 00 00       	jmp    f0103df1 <_alltraps>

f0103a7c <trap_handler_placeholder180>:
	TRAPHANDLER_NOEC(trap_handler_placeholder180,180)
f0103a7c:	6a 00                	push   $0x0
f0103a7e:	68 b4 00 00 00       	push   $0xb4
f0103a83:	e9 69 03 00 00       	jmp    f0103df1 <_alltraps>

f0103a88 <trap_handler_placeholder181>:
	TRAPHANDLER_NOEC(trap_handler_placeholder181,181)
f0103a88:	6a 00                	push   $0x0
f0103a8a:	68 b5 00 00 00       	push   $0xb5
f0103a8f:	e9 5d 03 00 00       	jmp    f0103df1 <_alltraps>

f0103a94 <trap_handler_placeholder182>:
	TRAPHANDLER_NOEC(trap_handler_placeholder182,182)
f0103a94:	6a 00                	push   $0x0
f0103a96:	68 b6 00 00 00       	push   $0xb6
f0103a9b:	e9 51 03 00 00       	jmp    f0103df1 <_alltraps>

f0103aa0 <trap_handler_placeholder183>:
	TRAPHANDLER_NOEC(trap_handler_placeholder183,183)
f0103aa0:	6a 00                	push   $0x0
f0103aa2:	68 b7 00 00 00       	push   $0xb7
f0103aa7:	e9 45 03 00 00       	jmp    f0103df1 <_alltraps>

f0103aac <trap_handler_placeholder184>:
	TRAPHANDLER_NOEC(trap_handler_placeholder184,184)
f0103aac:	6a 00                	push   $0x0
f0103aae:	68 b8 00 00 00       	push   $0xb8
f0103ab3:	e9 39 03 00 00       	jmp    f0103df1 <_alltraps>

f0103ab8 <trap_handler_placeholder185>:
	TRAPHANDLER_NOEC(trap_handler_placeholder185,185)
f0103ab8:	6a 00                	push   $0x0
f0103aba:	68 b9 00 00 00       	push   $0xb9
f0103abf:	e9 2d 03 00 00       	jmp    f0103df1 <_alltraps>

f0103ac4 <trap_handler_placeholder186>:
	TRAPHANDLER_NOEC(trap_handler_placeholder186,186)
f0103ac4:	6a 00                	push   $0x0
f0103ac6:	68 ba 00 00 00       	push   $0xba
f0103acb:	e9 21 03 00 00       	jmp    f0103df1 <_alltraps>

f0103ad0 <trap_handler_placeholder187>:
	TRAPHANDLER_NOEC(trap_handler_placeholder187,187)
f0103ad0:	6a 00                	push   $0x0
f0103ad2:	68 bb 00 00 00       	push   $0xbb
f0103ad7:	e9 15 03 00 00       	jmp    f0103df1 <_alltraps>

f0103adc <trap_handler_placeholder188>:
	TRAPHANDLER_NOEC(trap_handler_placeholder188,188)
f0103adc:	6a 00                	push   $0x0
f0103ade:	68 bc 00 00 00       	push   $0xbc
f0103ae3:	e9 09 03 00 00       	jmp    f0103df1 <_alltraps>

f0103ae8 <trap_handler_placeholder189>:
	TRAPHANDLER_NOEC(trap_handler_placeholder189,189)
f0103ae8:	6a 00                	push   $0x0
f0103aea:	68 bd 00 00 00       	push   $0xbd
f0103aef:	e9 fd 02 00 00       	jmp    f0103df1 <_alltraps>

f0103af4 <trap_handler_placeholder190>:
	TRAPHANDLER_NOEC(trap_handler_placeholder190,190)
f0103af4:	6a 00                	push   $0x0
f0103af6:	68 be 00 00 00       	push   $0xbe
f0103afb:	e9 f1 02 00 00       	jmp    f0103df1 <_alltraps>

f0103b00 <trap_handler_placeholder191>:
	TRAPHANDLER_NOEC(trap_handler_placeholder191,191)
f0103b00:	6a 00                	push   $0x0
f0103b02:	68 bf 00 00 00       	push   $0xbf
f0103b07:	e9 e5 02 00 00       	jmp    f0103df1 <_alltraps>

f0103b0c <trap_handler_placeholder192>:
	TRAPHANDLER_NOEC(trap_handler_placeholder192,192)
f0103b0c:	6a 00                	push   $0x0
f0103b0e:	68 c0 00 00 00       	push   $0xc0
f0103b13:	e9 d9 02 00 00       	jmp    f0103df1 <_alltraps>

f0103b18 <trap_handler_placeholder193>:
	TRAPHANDLER_NOEC(trap_handler_placeholder193,193)
f0103b18:	6a 00                	push   $0x0
f0103b1a:	68 c1 00 00 00       	push   $0xc1
f0103b1f:	e9 cd 02 00 00       	jmp    f0103df1 <_alltraps>

f0103b24 <trap_handler_placeholder194>:
	TRAPHANDLER_NOEC(trap_handler_placeholder194,194)
f0103b24:	6a 00                	push   $0x0
f0103b26:	68 c2 00 00 00       	push   $0xc2
f0103b2b:	e9 c1 02 00 00       	jmp    f0103df1 <_alltraps>

f0103b30 <trap_handler_placeholder195>:
	TRAPHANDLER_NOEC(trap_handler_placeholder195,195)
f0103b30:	6a 00                	push   $0x0
f0103b32:	68 c3 00 00 00       	push   $0xc3
f0103b37:	e9 b5 02 00 00       	jmp    f0103df1 <_alltraps>

f0103b3c <trap_handler_placeholder196>:
	TRAPHANDLER_NOEC(trap_handler_placeholder196,196)
f0103b3c:	6a 00                	push   $0x0
f0103b3e:	68 c4 00 00 00       	push   $0xc4
f0103b43:	e9 a9 02 00 00       	jmp    f0103df1 <_alltraps>

f0103b48 <trap_handler_placeholder197>:
	TRAPHANDLER_NOEC(trap_handler_placeholder197,197)
f0103b48:	6a 00                	push   $0x0
f0103b4a:	68 c5 00 00 00       	push   $0xc5
f0103b4f:	e9 9d 02 00 00       	jmp    f0103df1 <_alltraps>

f0103b54 <trap_handler_placeholder198>:
	TRAPHANDLER_NOEC(trap_handler_placeholder198,198)
f0103b54:	6a 00                	push   $0x0
f0103b56:	68 c6 00 00 00       	push   $0xc6
f0103b5b:	e9 91 02 00 00       	jmp    f0103df1 <_alltraps>

f0103b60 <trap_handler_placeholder199>:
	TRAPHANDLER_NOEC(trap_handler_placeholder199,199)
f0103b60:	6a 00                	push   $0x0
f0103b62:	68 c7 00 00 00       	push   $0xc7
f0103b67:	e9 85 02 00 00       	jmp    f0103df1 <_alltraps>

f0103b6c <trap_handler_placeholder200>:
	TRAPHANDLER_NOEC(trap_handler_placeholder200,200)
f0103b6c:	6a 00                	push   $0x0
f0103b6e:	68 c8 00 00 00       	push   $0xc8
f0103b73:	e9 79 02 00 00       	jmp    f0103df1 <_alltraps>

f0103b78 <trap_handler_placeholder201>:
	TRAPHANDLER_NOEC(trap_handler_placeholder201,201)
f0103b78:	6a 00                	push   $0x0
f0103b7a:	68 c9 00 00 00       	push   $0xc9
f0103b7f:	e9 6d 02 00 00       	jmp    f0103df1 <_alltraps>

f0103b84 <trap_handler_placeholder202>:
	TRAPHANDLER_NOEC(trap_handler_placeholder202,202)
f0103b84:	6a 00                	push   $0x0
f0103b86:	68 ca 00 00 00       	push   $0xca
f0103b8b:	e9 61 02 00 00       	jmp    f0103df1 <_alltraps>

f0103b90 <trap_handler_placeholder203>:
	TRAPHANDLER_NOEC(trap_handler_placeholder203,203)
f0103b90:	6a 00                	push   $0x0
f0103b92:	68 cb 00 00 00       	push   $0xcb
f0103b97:	e9 55 02 00 00       	jmp    f0103df1 <_alltraps>

f0103b9c <trap_handler_placeholder204>:
	TRAPHANDLER_NOEC(trap_handler_placeholder204,204)
f0103b9c:	6a 00                	push   $0x0
f0103b9e:	68 cc 00 00 00       	push   $0xcc
f0103ba3:	e9 49 02 00 00       	jmp    f0103df1 <_alltraps>

f0103ba8 <trap_handler_placeholder205>:
	TRAPHANDLER_NOEC(trap_handler_placeholder205,205)
f0103ba8:	6a 00                	push   $0x0
f0103baa:	68 cd 00 00 00       	push   $0xcd
f0103baf:	e9 3d 02 00 00       	jmp    f0103df1 <_alltraps>

f0103bb4 <trap_handler_placeholder206>:
	TRAPHANDLER_NOEC(trap_handler_placeholder206,206)
f0103bb4:	6a 00                	push   $0x0
f0103bb6:	68 ce 00 00 00       	push   $0xce
f0103bbb:	e9 31 02 00 00       	jmp    f0103df1 <_alltraps>

f0103bc0 <trap_handler_placeholder207>:
	TRAPHANDLER_NOEC(trap_handler_placeholder207,207)
f0103bc0:	6a 00                	push   $0x0
f0103bc2:	68 cf 00 00 00       	push   $0xcf
f0103bc7:	e9 25 02 00 00       	jmp    f0103df1 <_alltraps>

f0103bcc <trap_handler_placeholder208>:
	TRAPHANDLER_NOEC(trap_handler_placeholder208,208)
f0103bcc:	6a 00                	push   $0x0
f0103bce:	68 d0 00 00 00       	push   $0xd0
f0103bd3:	e9 19 02 00 00       	jmp    f0103df1 <_alltraps>

f0103bd8 <trap_handler_placeholder209>:
	TRAPHANDLER_NOEC(trap_handler_placeholder209,209)
f0103bd8:	6a 00                	push   $0x0
f0103bda:	68 d1 00 00 00       	push   $0xd1
f0103bdf:	e9 0d 02 00 00       	jmp    f0103df1 <_alltraps>

f0103be4 <trap_handler_placeholder210>:
	TRAPHANDLER_NOEC(trap_handler_placeholder210,210)
f0103be4:	6a 00                	push   $0x0
f0103be6:	68 d2 00 00 00       	push   $0xd2
f0103beb:	e9 01 02 00 00       	jmp    f0103df1 <_alltraps>

f0103bf0 <trap_handler_placeholder211>:
	TRAPHANDLER_NOEC(trap_handler_placeholder211,211)
f0103bf0:	6a 00                	push   $0x0
f0103bf2:	68 d3 00 00 00       	push   $0xd3
f0103bf7:	e9 f5 01 00 00       	jmp    f0103df1 <_alltraps>

f0103bfc <trap_handler_placeholder212>:
	TRAPHANDLER_NOEC(trap_handler_placeholder212,212)
f0103bfc:	6a 00                	push   $0x0
f0103bfe:	68 d4 00 00 00       	push   $0xd4
f0103c03:	e9 e9 01 00 00       	jmp    f0103df1 <_alltraps>

f0103c08 <trap_handler_placeholder213>:
	TRAPHANDLER_NOEC(trap_handler_placeholder213,213)
f0103c08:	6a 00                	push   $0x0
f0103c0a:	68 d5 00 00 00       	push   $0xd5
f0103c0f:	e9 dd 01 00 00       	jmp    f0103df1 <_alltraps>

f0103c14 <trap_handler_placeholder214>:
	TRAPHANDLER_NOEC(trap_handler_placeholder214,214)
f0103c14:	6a 00                	push   $0x0
f0103c16:	68 d6 00 00 00       	push   $0xd6
f0103c1b:	e9 d1 01 00 00       	jmp    f0103df1 <_alltraps>

f0103c20 <trap_handler_placeholder215>:
	TRAPHANDLER_NOEC(trap_handler_placeholder215,215)
f0103c20:	6a 00                	push   $0x0
f0103c22:	68 d7 00 00 00       	push   $0xd7
f0103c27:	e9 c5 01 00 00       	jmp    f0103df1 <_alltraps>

f0103c2c <trap_handler_placeholder216>:
	TRAPHANDLER_NOEC(trap_handler_placeholder216,216)
f0103c2c:	6a 00                	push   $0x0
f0103c2e:	68 d8 00 00 00       	push   $0xd8
f0103c33:	e9 b9 01 00 00       	jmp    f0103df1 <_alltraps>

f0103c38 <trap_handler_placeholder217>:
	TRAPHANDLER_NOEC(trap_handler_placeholder217,217)
f0103c38:	6a 00                	push   $0x0
f0103c3a:	68 d9 00 00 00       	push   $0xd9
f0103c3f:	e9 ad 01 00 00       	jmp    f0103df1 <_alltraps>

f0103c44 <trap_handler_placeholder218>:
	TRAPHANDLER_NOEC(trap_handler_placeholder218,218)
f0103c44:	6a 00                	push   $0x0
f0103c46:	68 da 00 00 00       	push   $0xda
f0103c4b:	e9 a1 01 00 00       	jmp    f0103df1 <_alltraps>

f0103c50 <trap_handler_placeholder219>:
	TRAPHANDLER_NOEC(trap_handler_placeholder219,219)
f0103c50:	6a 00                	push   $0x0
f0103c52:	68 db 00 00 00       	push   $0xdb
f0103c57:	e9 95 01 00 00       	jmp    f0103df1 <_alltraps>

f0103c5c <trap_handler_placeholder220>:
	TRAPHANDLER_NOEC(trap_handler_placeholder220,220)
f0103c5c:	6a 00                	push   $0x0
f0103c5e:	68 dc 00 00 00       	push   $0xdc
f0103c63:	e9 89 01 00 00       	jmp    f0103df1 <_alltraps>

f0103c68 <trap_handler_placeholder221>:
	TRAPHANDLER_NOEC(trap_handler_placeholder221,221)
f0103c68:	6a 00                	push   $0x0
f0103c6a:	68 dd 00 00 00       	push   $0xdd
f0103c6f:	e9 7d 01 00 00       	jmp    f0103df1 <_alltraps>

f0103c74 <trap_handler_placeholder222>:
	TRAPHANDLER_NOEC(trap_handler_placeholder222,222)
f0103c74:	6a 00                	push   $0x0
f0103c76:	68 de 00 00 00       	push   $0xde
f0103c7b:	e9 71 01 00 00       	jmp    f0103df1 <_alltraps>

f0103c80 <trap_handler_placeholder223>:
	TRAPHANDLER_NOEC(trap_handler_placeholder223,223)
f0103c80:	6a 00                	push   $0x0
f0103c82:	68 df 00 00 00       	push   $0xdf
f0103c87:	e9 65 01 00 00       	jmp    f0103df1 <_alltraps>

f0103c8c <trap_handler_placeholder224>:
	TRAPHANDLER_NOEC(trap_handler_placeholder224,224)
f0103c8c:	6a 00                	push   $0x0
f0103c8e:	68 e0 00 00 00       	push   $0xe0
f0103c93:	e9 59 01 00 00       	jmp    f0103df1 <_alltraps>

f0103c98 <trap_handler_placeholder225>:
	TRAPHANDLER_NOEC(trap_handler_placeholder225,225)
f0103c98:	6a 00                	push   $0x0
f0103c9a:	68 e1 00 00 00       	push   $0xe1
f0103c9f:	e9 4d 01 00 00       	jmp    f0103df1 <_alltraps>

f0103ca4 <trap_handler_placeholder226>:
	TRAPHANDLER_NOEC(trap_handler_placeholder226,226)
f0103ca4:	6a 00                	push   $0x0
f0103ca6:	68 e2 00 00 00       	push   $0xe2
f0103cab:	e9 41 01 00 00       	jmp    f0103df1 <_alltraps>

f0103cb0 <trap_handler_placeholder227>:
	TRAPHANDLER_NOEC(trap_handler_placeholder227,227)
f0103cb0:	6a 00                	push   $0x0
f0103cb2:	68 e3 00 00 00       	push   $0xe3
f0103cb7:	e9 35 01 00 00       	jmp    f0103df1 <_alltraps>

f0103cbc <trap_handler_placeholder228>:
	TRAPHANDLER_NOEC(trap_handler_placeholder228,228)
f0103cbc:	6a 00                	push   $0x0
f0103cbe:	68 e4 00 00 00       	push   $0xe4
f0103cc3:	e9 29 01 00 00       	jmp    f0103df1 <_alltraps>

f0103cc8 <trap_handler_placeholder229>:
	TRAPHANDLER_NOEC(trap_handler_placeholder229,229)
f0103cc8:	6a 00                	push   $0x0
f0103cca:	68 e5 00 00 00       	push   $0xe5
f0103ccf:	e9 1d 01 00 00       	jmp    f0103df1 <_alltraps>

f0103cd4 <trap_handler_placeholder230>:
	TRAPHANDLER_NOEC(trap_handler_placeholder230,230)
f0103cd4:	6a 00                	push   $0x0
f0103cd6:	68 e6 00 00 00       	push   $0xe6
f0103cdb:	e9 11 01 00 00       	jmp    f0103df1 <_alltraps>

f0103ce0 <trap_handler_placeholder231>:
	TRAPHANDLER_NOEC(trap_handler_placeholder231,231)
f0103ce0:	6a 00                	push   $0x0
f0103ce2:	68 e7 00 00 00       	push   $0xe7
f0103ce7:	e9 05 01 00 00       	jmp    f0103df1 <_alltraps>

f0103cec <trap_handler_placeholder232>:
	TRAPHANDLER_NOEC(trap_handler_placeholder232,232)
f0103cec:	6a 00                	push   $0x0
f0103cee:	68 e8 00 00 00       	push   $0xe8
f0103cf3:	e9 f9 00 00 00       	jmp    f0103df1 <_alltraps>

f0103cf8 <trap_handler_placeholder233>:
	TRAPHANDLER_NOEC(trap_handler_placeholder233,233)
f0103cf8:	6a 00                	push   $0x0
f0103cfa:	68 e9 00 00 00       	push   $0xe9
f0103cff:	e9 ed 00 00 00       	jmp    f0103df1 <_alltraps>

f0103d04 <trap_handler_placeholder234>:
	TRAPHANDLER_NOEC(trap_handler_placeholder234,234)
f0103d04:	6a 00                	push   $0x0
f0103d06:	68 ea 00 00 00       	push   $0xea
f0103d0b:	e9 e1 00 00 00       	jmp    f0103df1 <_alltraps>

f0103d10 <trap_handler_placeholder235>:
	TRAPHANDLER_NOEC(trap_handler_placeholder235,235)
f0103d10:	6a 00                	push   $0x0
f0103d12:	68 eb 00 00 00       	push   $0xeb
f0103d17:	e9 d5 00 00 00       	jmp    f0103df1 <_alltraps>

f0103d1c <trap_handler_placeholder236>:
	TRAPHANDLER_NOEC(trap_handler_placeholder236,236)
f0103d1c:	6a 00                	push   $0x0
f0103d1e:	68 ec 00 00 00       	push   $0xec
f0103d23:	e9 c9 00 00 00       	jmp    f0103df1 <_alltraps>

f0103d28 <trap_handler_placeholder237>:
	TRAPHANDLER_NOEC(trap_handler_placeholder237,237)
f0103d28:	6a 00                	push   $0x0
f0103d2a:	68 ed 00 00 00       	push   $0xed
f0103d2f:	e9 bd 00 00 00       	jmp    f0103df1 <_alltraps>

f0103d34 <trap_handler_placeholder238>:
	TRAPHANDLER_NOEC(trap_handler_placeholder238,238)
f0103d34:	6a 00                	push   $0x0
f0103d36:	68 ee 00 00 00       	push   $0xee
f0103d3b:	e9 b1 00 00 00       	jmp    f0103df1 <_alltraps>

f0103d40 <trap_handler_placeholder239>:
	TRAPHANDLER_NOEC(trap_handler_placeholder239,239)
f0103d40:	6a 00                	push   $0x0
f0103d42:	68 ef 00 00 00       	push   $0xef
f0103d47:	e9 a5 00 00 00       	jmp    f0103df1 <_alltraps>

f0103d4c <trap_handler_placeholder240>:
	TRAPHANDLER_NOEC(trap_handler_placeholder240,240)
f0103d4c:	6a 00                	push   $0x0
f0103d4e:	68 f0 00 00 00       	push   $0xf0
f0103d53:	e9 99 00 00 00       	jmp    f0103df1 <_alltraps>

f0103d58 <trap_handler_placeholder241>:
	TRAPHANDLER_NOEC(trap_handler_placeholder241,241)
f0103d58:	6a 00                	push   $0x0
f0103d5a:	68 f1 00 00 00       	push   $0xf1
f0103d5f:	e9 8d 00 00 00       	jmp    f0103df1 <_alltraps>

f0103d64 <trap_handler_placeholder242>:
	TRAPHANDLER_NOEC(trap_handler_placeholder242,242)
f0103d64:	6a 00                	push   $0x0
f0103d66:	68 f2 00 00 00       	push   $0xf2
f0103d6b:	e9 81 00 00 00       	jmp    f0103df1 <_alltraps>

f0103d70 <trap_handler_placeholder243>:
	TRAPHANDLER_NOEC(trap_handler_placeholder243,243)
f0103d70:	6a 00                	push   $0x0
f0103d72:	68 f3 00 00 00       	push   $0xf3
f0103d77:	eb 78                	jmp    f0103df1 <_alltraps>
f0103d79:	90                   	nop

f0103d7a <trap_handler_placeholder244>:
	TRAPHANDLER_NOEC(trap_handler_placeholder244,244)
f0103d7a:	6a 00                	push   $0x0
f0103d7c:	68 f4 00 00 00       	push   $0xf4
f0103d81:	eb 6e                	jmp    f0103df1 <_alltraps>
f0103d83:	90                   	nop

f0103d84 <trap_handler_placeholder245>:
	TRAPHANDLER_NOEC(trap_handler_placeholder245,245)
f0103d84:	6a 00                	push   $0x0
f0103d86:	68 f5 00 00 00       	push   $0xf5
f0103d8b:	eb 64                	jmp    f0103df1 <_alltraps>
f0103d8d:	90                   	nop

f0103d8e <trap_handler_placeholder246>:
	TRAPHANDLER_NOEC(trap_handler_placeholder246,246)
f0103d8e:	6a 00                	push   $0x0
f0103d90:	68 f6 00 00 00       	push   $0xf6
f0103d95:	eb 5a                	jmp    f0103df1 <_alltraps>
f0103d97:	90                   	nop

f0103d98 <trap_handler_placeholder247>:
	TRAPHANDLER_NOEC(trap_handler_placeholder247,247)
f0103d98:	6a 00                	push   $0x0
f0103d9a:	68 f7 00 00 00       	push   $0xf7
f0103d9f:	eb 50                	jmp    f0103df1 <_alltraps>
f0103da1:	90                   	nop

f0103da2 <trap_handler_placeholder248>:
	TRAPHANDLER_NOEC(trap_handler_placeholder248,248)
f0103da2:	6a 00                	push   $0x0
f0103da4:	68 f8 00 00 00       	push   $0xf8
f0103da9:	eb 46                	jmp    f0103df1 <_alltraps>
f0103dab:	90                   	nop

f0103dac <trap_handler_placeholder249>:
	TRAPHANDLER_NOEC(trap_handler_placeholder249,249)
f0103dac:	6a 00                	push   $0x0
f0103dae:	68 f9 00 00 00       	push   $0xf9
f0103db3:	eb 3c                	jmp    f0103df1 <_alltraps>
f0103db5:	90                   	nop

f0103db6 <trap_handler_placeholder250>:
	TRAPHANDLER_NOEC(trap_handler_placeholder250,250)
f0103db6:	6a 00                	push   $0x0
f0103db8:	68 fa 00 00 00       	push   $0xfa
f0103dbd:	eb 32                	jmp    f0103df1 <_alltraps>
f0103dbf:	90                   	nop

f0103dc0 <trap_handler_placeholder251>:
	TRAPHANDLER_NOEC(trap_handler_placeholder251,251)
f0103dc0:	6a 00                	push   $0x0
f0103dc2:	68 fb 00 00 00       	push   $0xfb
f0103dc7:	eb 28                	jmp    f0103df1 <_alltraps>
f0103dc9:	90                   	nop

f0103dca <trap_handler_placeholder252>:
	TRAPHANDLER_NOEC(trap_handler_placeholder252,252)
f0103dca:	6a 00                	push   $0x0
f0103dcc:	68 fc 00 00 00       	push   $0xfc
f0103dd1:	eb 1e                	jmp    f0103df1 <_alltraps>
f0103dd3:	90                   	nop

f0103dd4 <trap_handler_placeholder253>:
	TRAPHANDLER_NOEC(trap_handler_placeholder253,253)
f0103dd4:	6a 00                	push   $0x0
f0103dd6:	68 fd 00 00 00       	push   $0xfd
f0103ddb:	eb 14                	jmp    f0103df1 <_alltraps>
f0103ddd:	90                   	nop

f0103dde <trap_handler_placeholder254>:
	TRAPHANDLER_NOEC(trap_handler_placeholder254,254)
f0103dde:	6a 00                	push   $0x0
f0103de0:	68 fe 00 00 00       	push   $0xfe
f0103de5:	eb 0a                	jmp    f0103df1 <_alltraps>
f0103de7:	90                   	nop

f0103de8 <trap_handler_placeholder255>:
	TRAPHANDLER_NOEC(trap_handler_placeholder255,255)
f0103de8:	6a 00                	push   $0x0
f0103dea:	68 ff 00 00 00       	push   $0xff
f0103def:	eb 00                	jmp    f0103df1 <_alltraps>

f0103df1 <_alltraps>:
.text
.globl _alltraps
_alltraps:
  # Push values (in reverse) to make the stack look like a struct Trapframe
  # Everything below tf_trapno is already on stack
  pushl %ds
f0103df1:	1e                   	push   %ds
  pushl %es
f0103df2:	06                   	push   %es
  pushal
f0103df3:	60                   	pusha  
  # Looking back from stack top, we get exactly a struct Trapframe
  
  # load GD_KD into %ds and %es
  movl $GD_KD, %eax
f0103df4:	b8 10 00 00 00       	mov    $0x10,%eax
  movw %ax,%ds
f0103df9:	8e d8                	mov    %eax,%ds
  movw %ax,%es
f0103dfb:	8e c0                	mov    %eax,%es

  # pushl %esp to pass a pointer to the Trapframe as an argument to trap()
  pushl %esp
f0103dfd:	54                   	push   %esp
  /* Nuke frame pointer, like we do in entry.S when bootstrapping kernel.
     Otherwise backtrace would walk off the stack. */  
  # avoid page fault in kernel
  movl $0, %ebp
f0103dfe:	bd 00 00 00 00       	mov    $0x0,%ebp
  call trap
f0103e03:	e8 03 f3 ff ff       	call   f010310b <trap>

  # Clean up the stack setup for previous trap() call and prepare for iret
  addl $4, %esp       # skip the argument we passed on stack to trap()
f0103e08:	83 c4 04             	add    $0x4,%esp
  popal
f0103e0b:	61                   	popa   
  popl %es
f0103e0c:	07                   	pop    %es
  popl %ds
f0103e0d:	1f                   	pop    %ds
  addl $8, %esp       # skip trapno and errcode
f0103e0e:	83 c4 08             	add    $0x8,%esp
  iret
f0103e11:	cf                   	iret   

f0103e12 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0103e12:	55                   	push   %ebp
f0103e13:	89 e5                	mov    %esp,%ebp
f0103e15:	83 ec 08             	sub    $0x8,%esp
f0103e18:	a1 60 92 23 f0       	mov    0xf0239260,%eax
f0103e1d:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0103e20:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0103e25:	8b 02                	mov    (%edx),%eax
f0103e27:	83 e8 01             	sub    $0x1,%eax
f0103e2a:	83 f8 02             	cmp    $0x2,%eax
f0103e2d:	76 10                	jbe    f0103e3f <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0103e2f:	83 c1 01             	add    $0x1,%ecx
f0103e32:	83 c2 7c             	add    $0x7c,%edx
f0103e35:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0103e3b:	75 e8                	jne    f0103e25 <sched_halt+0x13>
f0103e3d:	eb 08                	jmp    f0103e47 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0103e3f:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0103e45:	75 1f                	jne    f0103e66 <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f0103e47:	83 ec 0c             	sub    $0xc,%esp
f0103e4a:	68 90 6e 10 f0       	push   $0xf0106e90
f0103e4f:	e8 64 ee ff ff       	call   f0102cb8 <cprintf>
f0103e54:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0103e57:	83 ec 0c             	sub    $0xc,%esp
f0103e5a:	6a 00                	push   $0x0
f0103e5c:	e8 b8 ca ff ff       	call   f0100919 <monitor>
f0103e61:	83 c4 10             	add    $0x10,%esp
f0103e64:	eb f1                	jmp    f0103e57 <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0103e66:	e8 97 16 00 00       	call   f0105502 <cpunum>
f0103e6b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e6e:	c7 80 28 a0 23 f0 00 	movl   $0x0,-0xfdc5fd8(%eax)
f0103e75:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0103e78:	a1 2c 9f 23 f0       	mov    0xf0239f2c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103e7d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103e82:	77 12                	ja     f0103e96 <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103e84:	50                   	push   %eax
f0103e85:	68 e8 5b 10 f0       	push   $0xf0105be8
f0103e8a:	6a 51                	push   $0x51
f0103e8c:	68 b9 6e 10 f0       	push   $0xf0106eb9
f0103e91:	e8 aa c1 ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103e96:	05 00 00 00 10       	add    $0x10000000,%eax
f0103e9b:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0103e9e:	e8 5f 16 00 00       	call   f0105502 <cpunum>
f0103ea3:	6b d0 74             	imul   $0x74,%eax,%edx
f0103ea6:	81 c2 20 a0 23 f0    	add    $0xf023a020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0103eac:	b8 02 00 00 00       	mov    $0x2,%eax
f0103eb1:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103eb5:	83 ec 0c             	sub    $0xc,%esp
f0103eb8:	68 a0 f7 11 f0       	push   $0xf011f7a0
f0103ebd:	e8 4b 19 00 00       	call   f010580d <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103ec2:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0103ec4:	e8 39 16 00 00       	call   f0105502 <cpunum>
f0103ec9:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0103ecc:	8b 80 30 a0 23 f0    	mov    -0xfdc5fd0(%eax),%eax
f0103ed2:	bd 00 00 00 00       	mov    $0x0,%ebp
f0103ed7:	89 c4                	mov    %eax,%esp
f0103ed9:	6a 00                	push   $0x0
f0103edb:	6a 00                	push   $0x0
f0103edd:	fb                   	sti    
f0103ede:	f4                   	hlt    
f0103edf:	eb fd                	jmp    f0103ede <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0103ee1:	83 c4 10             	add    $0x10,%esp
f0103ee4:	c9                   	leave  
f0103ee5:	c3                   	ret    

f0103ee6 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0103ee6:	55                   	push   %ebp
f0103ee7:	89 e5                	mov    %esp,%ebp
f0103ee9:	56                   	push   %esi
f0103eea:	53                   	push   %ebx
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.

    idle = thiscpu->cpu_env;
f0103eeb:	e8 12 16 00 00       	call   f0105502 <cpunum>
f0103ef0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ef3:	8b b0 28 a0 23 f0    	mov    -0xfdc5fd8(%eax),%esi
    uint32_t start = (idle != NULL) ? ENVX( idle->env_id) : 0;
f0103ef9:	85 f6                	test   %esi,%esi
f0103efb:	74 0b                	je     f0103f08 <sched_yield+0x22>
f0103efd:	8b 4e 48             	mov    0x48(%esi),%ecx
f0103f00:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f0103f06:	eb 05                	jmp    f0103f0d <sched_yield+0x27>
f0103f08:	b9 00 00 00 00       	mov    $0x0,%ecx
    uint32_t i = start;
    bool first = true;

    for (; i != start || first; i = (i+1) % NENV, first = false)
    {
        if(envs[i].env_status == ENV_RUNNABLE)
f0103f0d:	8b 1d 60 92 23 f0    	mov    0xf0239260,%ebx

	// LAB 4: Your code here.

    idle = thiscpu->cpu_env;
    uint32_t start = (idle != NULL) ? ENVX( idle->env_id) : 0;
    uint32_t i = start;
f0103f13:	89 c8                	mov    %ecx,%eax
    bool first = true;

    for (; i != start || first; i = (i+1) % NENV, first = false)
    {
        if(envs[i].env_status == ENV_RUNNABLE)
f0103f15:	6b d0 7c             	imul   $0x7c,%eax,%edx
f0103f18:	01 da                	add    %ebx,%edx
f0103f1a:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f0103f1e:	75 09                	jne    f0103f29 <sched_yield+0x43>
        {
            env_run(&envs[i]);
f0103f20:	83 ec 0c             	sub    $0xc,%esp
f0103f23:	52                   	push   %edx
f0103f24:	e8 83 eb ff ff       	call   f0102aac <env_run>
    idle = thiscpu->cpu_env;
    uint32_t start = (idle != NULL) ? ENVX( idle->env_id) : 0;
    uint32_t i = start;
    bool first = true;

    for (; i != start || first; i = (i+1) % NENV, first = false)
f0103f29:	83 c0 01             	add    $0x1,%eax
f0103f2c:	25 ff 03 00 00       	and    $0x3ff,%eax
f0103f31:	39 c1                	cmp    %eax,%ecx
f0103f33:	75 e0                	jne    f0103f15 <sched_yield+0x2f>
            env_run(&envs[i]);
            return ;
        }
    }

    if (idle && idle->env_status == ENV_RUNNING)
f0103f35:	85 f6                	test   %esi,%esi
f0103f37:	74 0f                	je     f0103f48 <sched_yield+0x62>
f0103f39:	83 7e 54 03          	cmpl   $0x3,0x54(%esi)
f0103f3d:	75 09                	jne    f0103f48 <sched_yield+0x62>
    {
        env_run(idle);
f0103f3f:	83 ec 0c             	sub    $0xc,%esp
f0103f42:	56                   	push   %esi
f0103f43:	e8 64 eb ff ff       	call   f0102aac <env_run>
        return ;
    }

	// sched_halt never returns
	sched_halt();
f0103f48:	e8 c5 fe ff ff       	call   f0103e12 <sched_halt>
}
f0103f4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103f50:	5b                   	pop    %ebx
f0103f51:	5e                   	pop    %esi
f0103f52:	5d                   	pop    %ebp
f0103f53:	c3                   	ret    

f0103f54 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103f54:	55                   	push   %ebp
f0103f55:	89 e5                	mov    %esp,%ebp
f0103f57:	57                   	push   %edi
f0103f58:	56                   	push   %esi
f0103f59:	53                   	push   %ebx
f0103f5a:	83 ec 1c             	sub    $0x1c,%esp
f0103f5d:	8b 45 08             	mov    0x8(%ebp),%eax

	//panic("syscall not implemented");

    int32_t r = 0;

	switch (syscallno) 
f0103f60:	83 f8 0c             	cmp    $0xc,%eax
f0103f63:	0f 87 6b 04 00 00    	ja     f01043d4 <syscall+0x480>
f0103f69:	ff 24 85 f4 6f 10 f0 	jmp    *-0xfef900c(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
    user_mem_assert(curenv, (void *)s, len, PTE_U);
f0103f70:	e8 8d 15 00 00       	call   f0105502 <cpunum>
f0103f75:	6a 04                	push   $0x4
f0103f77:	ff 75 10             	pushl  0x10(%ebp)
f0103f7a:	ff 75 0c             	pushl  0xc(%ebp)
f0103f7d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f80:	ff b0 28 a0 23 f0    	pushl  -0xfdc5fd8(%eax)
f0103f86:	e8 88 e3 ff ff       	call   f0102313 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0103f8b:	83 c4 0c             	add    $0xc,%esp
f0103f8e:	ff 75 0c             	pushl  0xc(%ebp)
f0103f91:	ff 75 10             	pushl  0x10(%ebp)
f0103f94:	68 c6 6e 10 f0       	push   $0xf0106ec6
f0103f99:	e8 1a ed ff ff       	call   f0102cb8 <cprintf>
f0103f9e:	83 c4 10             	add    $0x10,%esp
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");

    int32_t r = 0;
f0103fa1:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103fa6:	e9 4e 04 00 00       	jmp    f01043f9 <syscall+0x4a5>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0103fab:	e8 1f c6 ff ff       	call   f01005cf <cons_getc>
f0103fb0:	89 c3                	mov    %eax,%ebx
	switch (syscallno) 
    {
        case SYS_cputs:
            sys_cputs((const char*) a1, (size_t)a2); break;
        case SYS_cgetc: 
            r = sys_cgetc(); break;
f0103fb2:	e9 42 04 00 00       	jmp    f01043f9 <syscall+0x4a5>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0103fb7:	e8 46 15 00 00       	call   f0105502 <cpunum>
f0103fbc:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fbf:	8b 80 28 a0 23 f0    	mov    -0xfdc5fd8(%eax),%eax
f0103fc5:	8b 58 48             	mov    0x48(%eax),%ebx
        case SYS_cputs:
            sys_cputs((const char*) a1, (size_t)a2); break;
        case SYS_cgetc: 
            r = sys_cgetc(); break;
        case SYS_getenvid:
            r = sys_getenvid(); break;
f0103fc8:	e9 2c 04 00 00       	jmp    f01043f9 <syscall+0x4a5>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0103fcd:	83 ec 04             	sub    $0x4,%esp
f0103fd0:	6a 01                	push   $0x1
f0103fd2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103fd5:	50                   	push   %eax
f0103fd6:	ff 75 0c             	pushl  0xc(%ebp)
f0103fd9:	e8 0a e4 ff ff       	call   f01023e8 <envid2env>
f0103fde:	83 c4 10             	add    $0x10,%esp
		return r;
f0103fe1:	89 c3                	mov    %eax,%ebx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0103fe3:	85 c0                	test   %eax,%eax
f0103fe5:	0f 88 0e 04 00 00    	js     f01043f9 <syscall+0x4a5>
		return r;
	if (e == curenv)
f0103feb:	e8 12 15 00 00       	call   f0105502 <cpunum>
f0103ff0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103ff3:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ff6:	39 90 28 a0 23 f0    	cmp    %edx,-0xfdc5fd8(%eax)
f0103ffc:	75 23                	jne    f0104021 <syscall+0xcd>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103ffe:	e8 ff 14 00 00       	call   f0105502 <cpunum>
f0104003:	83 ec 08             	sub    $0x8,%esp
f0104006:	6b c0 74             	imul   $0x74,%eax,%eax
f0104009:	8b 80 28 a0 23 f0    	mov    -0xfdc5fd8(%eax),%eax
f010400f:	ff 70 48             	pushl  0x48(%eax)
f0104012:	68 cb 6e 10 f0       	push   $0xf0106ecb
f0104017:	e8 9c ec ff ff       	call   f0102cb8 <cprintf>
f010401c:	83 c4 10             	add    $0x10,%esp
f010401f:	eb 25                	jmp    f0104046 <syscall+0xf2>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104021:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104024:	e8 d9 14 00 00       	call   f0105502 <cpunum>
f0104029:	83 ec 04             	sub    $0x4,%esp
f010402c:	53                   	push   %ebx
f010402d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104030:	8b 80 28 a0 23 f0    	mov    -0xfdc5fd8(%eax),%eax
f0104036:	ff 70 48             	pushl  0x48(%eax)
f0104039:	68 e6 6e 10 f0       	push   $0xf0106ee6
f010403e:	e8 75 ec ff ff       	call   f0102cb8 <cprintf>
f0104043:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104046:	83 ec 0c             	sub    $0xc,%esp
f0104049:	ff 75 e4             	pushl  -0x1c(%ebp)
f010404c:	e8 bc e9 ff ff       	call   f0102a0d <env_destroy>
f0104051:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104054:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104059:	e9 9b 03 00 00       	jmp    f01043f9 <syscall+0x4a5>
	// LAB 4: Your code here.

    struct Env *e;
    struct PageInfo *pp;

    if(envid2env(envid, &e, 1) < 0)
f010405e:	83 ec 04             	sub    $0x4,%esp
f0104061:	6a 01                	push   $0x1
f0104063:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104066:	50                   	push   %eax
f0104067:	ff 75 0c             	pushl  0xc(%ebp)
f010406a:	e8 79 e3 ff ff       	call   f01023e8 <envid2env>
f010406f:	83 c4 10             	add    $0x10,%esp
f0104072:	85 c0                	test   %eax,%eax
f0104074:	78 6e                	js     f01040e4 <syscall+0x190>
    {
        return -E_BAD_ENV;
    }

    if((uintptr_t) va >= UTOP || (uintptr_t) va % PGSIZE)
f0104076:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010407d:	77 6f                	ja     f01040ee <syscall+0x19a>
f010407f:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104086:	75 70                	jne    f01040f8 <syscall+0x1a4>
    {
        return -E_INVAL;
    }

    if((perm & PTE_U) == 0 || (perm & PTE_P) == 0)
f0104088:	8b 45 14             	mov    0x14(%ebp),%eax
f010408b:	83 e0 05             	and    $0x5,%eax
f010408e:	83 f8 05             	cmp    $0x5,%eax
f0104091:	75 6f                	jne    f0104102 <syscall+0x1ae>
    {
        return -E_INVAL;
    }

    if((perm & ~(PTE_U | PTE_P | PTE_W | PTE_AVAIL)) != 0)
f0104093:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104096:	81 e3 f8 f1 ff ff    	and    $0xfffff1f8,%ebx
f010409c:	75 6e                	jne    f010410c <syscall+0x1b8>
    {
        return -E_NO_MEM;
    }

    if ((pp = page_alloc(ALLOC_ZERO)) == NULL)
f010409e:	83 ec 0c             	sub    $0xc,%esp
f01040a1:	6a 01                	push   $0x1
f01040a3:	e8 e4 cb ff ff       	call   f0100c8c <page_alloc>
f01040a8:	89 c6                	mov    %eax,%esi
f01040aa:	83 c4 10             	add    $0x10,%esp
f01040ad:	85 c0                	test   %eax,%eax
f01040af:	74 65                	je     f0104116 <syscall+0x1c2>
    {
        return -E_NO_MEM;
    }

    if(page_insert(e->env_pgdir, pp, va, perm) < 0)
f01040b1:	ff 75 14             	pushl  0x14(%ebp)
f01040b4:	ff 75 10             	pushl  0x10(%ebp)
f01040b7:	50                   	push   %eax
f01040b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01040bb:	ff 70 60             	pushl  0x60(%eax)
f01040be:	e8 5f ce ff ff       	call   f0100f22 <page_insert>
f01040c3:	83 c4 10             	add    $0x10,%esp
f01040c6:	85 c0                	test   %eax,%eax
f01040c8:	0f 89 2b 03 00 00    	jns    f01043f9 <syscall+0x4a5>
    {
        page_free(pp);
f01040ce:	83 ec 0c             	sub    $0xc,%esp
f01040d1:	56                   	push   %esi
f01040d2:	e8 1f cc ff ff       	call   f0100cf6 <page_free>
f01040d7:	83 c4 10             	add    $0x10,%esp
        return -E_NO_MEM;
f01040da:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f01040df:	e9 15 03 00 00       	jmp    f01043f9 <syscall+0x4a5>
    struct Env *e;
    struct PageInfo *pp;

    if(envid2env(envid, &e, 1) < 0)
    {
        return -E_BAD_ENV;
f01040e4:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01040e9:	e9 0b 03 00 00       	jmp    f01043f9 <syscall+0x4a5>
    }

    if((uintptr_t) va >= UTOP || (uintptr_t) va % PGSIZE)
    {
        return -E_INVAL;
f01040ee:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01040f3:	e9 01 03 00 00       	jmp    f01043f9 <syscall+0x4a5>
f01040f8:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01040fd:	e9 f7 02 00 00       	jmp    f01043f9 <syscall+0x4a5>
    }

    if((perm & PTE_U) == 0 || (perm & PTE_P) == 0)
    {
        return -E_INVAL;
f0104102:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104107:	e9 ed 02 00 00       	jmp    f01043f9 <syscall+0x4a5>
    }

    if((perm & ~(PTE_U | PTE_P | PTE_W | PTE_AVAIL)) != 0)
    {
        return -E_NO_MEM;
f010410c:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104111:	e9 e3 02 00 00       	jmp    f01043f9 <syscall+0x4a5>
    }

    if ((pp = page_alloc(ALLOC_ZERO)) == NULL)
    {
        return -E_NO_MEM;
f0104116:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
            r = sys_env_destroy((envid_t) a1); break;
        /*
         ** Added sys_exofork() for lab 4 by Jason Leaster
         */
        case SYS_page_alloc:
             return sys_page_alloc(a1, (void *)a2, a3);
f010411b:	e9 d9 02 00 00       	jmp    f01043f9 <syscall+0x4a5>
    struct Env *srcenv;
    struct Env *dstenv;
    pte_t *pte;
    struct PageInfo *pp;

    if(envid2env(srcenvid, &srcenv, 1) < 0||
f0104120:	83 ec 04             	sub    $0x4,%esp
f0104123:	6a 01                	push   $0x1
f0104125:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104128:	50                   	push   %eax
f0104129:	ff 75 0c             	pushl  0xc(%ebp)
f010412c:	e8 b7 e2 ff ff       	call   f01023e8 <envid2env>
f0104131:	83 c4 10             	add    $0x10,%esp
f0104134:	85 c0                	test   %eax,%eax
f0104136:	0f 88 05 01 00 00    	js     f0104241 <syscall+0x2ed>
        envid2env(dstenvid,&dstenv, 1) < 0)
f010413c:	83 ec 04             	sub    $0x4,%esp
f010413f:	6a 01                	push   $0x1
f0104141:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104144:	50                   	push   %eax
f0104145:	ff 75 14             	pushl  0x14(%ebp)
f0104148:	e8 9b e2 ff ff       	call   f01023e8 <envid2env>
    struct Env *srcenv;
    struct Env *dstenv;
    pte_t *pte;
    struct PageInfo *pp;

    if(envid2env(srcenvid, &srcenv, 1) < 0||
f010414d:	83 c4 10             	add    $0x10,%esp
f0104150:	85 c0                	test   %eax,%eax
f0104152:	0f 88 f3 00 00 00    	js     f010424b <syscall+0x2f7>
        envid2env(dstenvid,&dstenv, 1) < 0)
    {
        return -E_BAD_ENV;
    }

    if((uintptr_t)srcva >= UTOP || (uintptr_t)srcva % PGSIZE ||
f0104158:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010415f:	77 1b                	ja     f010417c <syscall+0x228>
f0104161:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104168:	75 12                	jne    f010417c <syscall+0x228>
f010416a:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104171:	77 09                	ja     f010417c <syscall+0x228>
       (uintptr_t)dstva >= UTOP || (uintptr_t)dstva % PGSIZE)
f0104173:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f010417a:	74 1a                	je     f0104196 <syscall+0x242>
    {
        cprintf("sys_page_map: invalid boundary or page-aligned\n");
f010417c:	83 ec 0c             	sub    $0xc,%esp
f010417f:	68 a0 6f 10 f0       	push   $0xf0106fa0
f0104184:	e8 2f eb ff ff       	call   f0102cb8 <cprintf>
f0104189:	83 c4 10             	add    $0x10,%esp
        return -E_INVAL;
f010418c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104191:	e9 63 02 00 00       	jmp    f01043f9 <syscall+0x4a5>
    }

    if((perm & PTE_U) == 0 ||(perm & PTE_P) == 0 ||(perm & ~PTE_SYSCALL) != 0)
f0104196:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104199:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f010419e:	83 f8 05             	cmp    $0x5,%eax
f01041a1:	74 1a                	je     f01041bd <syscall+0x269>
    {
        cprintf("sys_page_map: invalid perm\n");
f01041a3:	83 ec 0c             	sub    $0xc,%esp
f01041a6:	68 fe 6e 10 f0       	push   $0xf0106efe
f01041ab:	e8 08 eb ff ff       	call   f0102cb8 <cprintf>
f01041b0:	83 c4 10             	add    $0x10,%esp
        return -E_INVAL;
f01041b3:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01041b8:	e9 3c 02 00 00       	jmp    f01043f9 <syscall+0x4a5>
    }

    if((pp = page_lookup(srcenv->env_pgdir, srcva, &pte)) == NULL)
f01041bd:	83 ec 04             	sub    $0x4,%esp
f01041c0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01041c3:	50                   	push   %eax
f01041c4:	ff 75 10             	pushl  0x10(%ebp)
f01041c7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01041ca:	ff 70 60             	pushl  0x60(%eax)
f01041cd:	e8 74 cc ff ff       	call   f0100e46 <page_lookup>
f01041d2:	83 c4 10             	add    $0x10,%esp
f01041d5:	85 c0                	test   %eax,%eax
f01041d7:	75 1a                	jne    f01041f3 <syscall+0x29f>
    {
        cprintf("page not found\n");
f01041d9:	83 ec 0c             	sub    $0xc,%esp
f01041dc:	68 1a 6f 10 f0       	push   $0xf0106f1a
f01041e1:	e8 d2 ea ff ff       	call   f0102cb8 <cprintf>
f01041e6:	83 c4 10             	add    $0x10,%esp
        return -E_INVAL;
f01041e9:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01041ee:	e9 06 02 00 00       	jmp    f01043f9 <syscall+0x4a5>
    }


    if((perm & PTE_W) && ((*pte & PTE_W)) == 0)
f01041f3:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01041f7:	74 22                	je     f010421b <syscall+0x2c7>
f01041f9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01041fc:	f6 02 02             	testb  $0x2,(%edx)
f01041ff:	75 1a                	jne    f010421b <syscall+0x2c7>
    {
        cprintf("sys_page_map: invalid PTE_W\n");
f0104201:	83 ec 0c             	sub    $0xc,%esp
f0104204:	68 2a 6f 10 f0       	push   $0xf0106f2a
f0104209:	e8 aa ea ff ff       	call   f0102cb8 <cprintf>
f010420e:	83 c4 10             	add    $0x10,%esp
        return -E_INVAL;
f0104211:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104216:	e9 de 01 00 00       	jmp    f01043f9 <syscall+0x4a5>
    }

    if (page_insert(dstenv->env_pgdir, pp, dstva, perm))
f010421b:	ff 75 1c             	pushl  0x1c(%ebp)
f010421e:	ff 75 18             	pushl  0x18(%ebp)
f0104221:	50                   	push   %eax
f0104222:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104225:	ff 70 60             	pushl  0x60(%eax)
f0104228:	e8 f5 cc ff ff       	call   f0100f22 <page_insert>
f010422d:	89 c3                	mov    %eax,%ebx
f010422f:	83 c4 10             	add    $0x10,%esp
    {
        return -E_NO_MEM;
f0104232:	85 c0                	test   %eax,%eax
f0104234:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104239:	0f 45 d8             	cmovne %eax,%ebx
f010423c:	e9 b8 01 00 00       	jmp    f01043f9 <syscall+0x4a5>
    struct PageInfo *pp;

    if(envid2env(srcenvid, &srcenv, 1) < 0||
        envid2env(dstenvid,&dstenv, 1) < 0)
    {
        return -E_BAD_ENV;
f0104241:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104246:	e9 ae 01 00 00       	jmp    f01043f9 <syscall+0x4a5>
f010424b:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104250:	e9 a4 01 00 00       	jmp    f01043f9 <syscall+0x4a5>
{
	// Hint: This function is a wrapper around page_remove().
	// LAB 4: Your code here.

    struct Env *e;
    if(envid2env(envid, &e, 1) < 0)
f0104255:	83 ec 04             	sub    $0x4,%esp
f0104258:	6a 01                	push   $0x1
f010425a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010425d:	50                   	push   %eax
f010425e:	ff 75 0c             	pushl  0xc(%ebp)
f0104261:	e8 82 e1 ff ff       	call   f01023e8 <envid2env>
f0104266:	83 c4 10             	add    $0x10,%esp
f0104269:	85 c0                	test   %eax,%eax
f010426b:	78 30                	js     f010429d <syscall+0x349>
    {
        return -E_BAD_ENV;
    }

    if((uintptr_t)va >= UTOP || (uintptr_t) va % PGSIZE)
f010426d:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104274:	77 31                	ja     f01042a7 <syscall+0x353>
f0104276:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010427d:	75 32                	jne    f01042b1 <syscall+0x35d>
    {
        return -E_INVAL;
    }

    page_remove(e->env_pgdir, va);
f010427f:	83 ec 08             	sub    $0x8,%esp
f0104282:	ff 75 10             	pushl  0x10(%ebp)
f0104285:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104288:	ff 70 60             	pushl  0x60(%eax)
f010428b:	e8 3d cc ff ff       	call   f0100ecd <page_remove>
f0104290:	83 c4 10             	add    $0x10,%esp

    return 0;
f0104293:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104298:	e9 5c 01 00 00       	jmp    f01043f9 <syscall+0x4a5>
	// LAB 4: Your code here.

    struct Env *e;
    if(envid2env(envid, &e, 1) < 0)
    {
        return -E_BAD_ENV;
f010429d:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01042a2:	e9 52 01 00 00       	jmp    f01043f9 <syscall+0x4a5>
    }

    if((uintptr_t)va >= UTOP || (uintptr_t) va % PGSIZE)
    {
        return -E_INVAL;
f01042a7:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01042ac:	e9 48 01 00 00       	jmp    f01043f9 <syscall+0x4a5>
f01042b1:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
        case SYS_page_alloc:
             return sys_page_alloc(a1, (void *)a2, a3);
        case SYS_page_map:
             return sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
        case SYS_page_unmap:
             return sys_page_unmap(a1, (void *)a2);
f01042b6:	e9 3e 01 00 00       	jmp    f01043f9 <syscall+0x4a5>
	// LAB 4: Your code here.

    struct Env *e;
    int err;

    if((err = env_alloc(&e, curenv->env_id)) < 0)
f01042bb:	e8 42 12 00 00       	call   f0105502 <cpunum>
f01042c0:	83 ec 08             	sub    $0x8,%esp
f01042c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01042c6:	8b 80 28 a0 23 f0    	mov    -0xfdc5fd8(%eax),%eax
f01042cc:	ff 70 48             	pushl  0x48(%eax)
f01042cf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01042d2:	50                   	push   %eax
f01042d3:	e8 7a e2 ff ff       	call   f0102552 <env_alloc>
f01042d8:	83 c4 10             	add    $0x10,%esp
    {
        return err;
f01042db:	89 c3                	mov    %eax,%ebx
	// LAB 4: Your code here.

    struct Env *e;
    int err;

    if((err = env_alloc(&e, curenv->env_id)) < 0)
f01042dd:	85 c0                	test   %eax,%eax
f01042df:	0f 88 14 01 00 00    	js     f01043f9 <syscall+0x4a5>
    {
        return err;
    }

    e->env_status = ENV_NOT_RUNNABLE;
f01042e5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01042e8:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
    e->env_tf = curenv->env_tf;
f01042ef:	e8 0e 12 00 00       	call   f0105502 <cpunum>
f01042f4:	6b c0 74             	imul   $0x74,%eax,%eax
f01042f7:	8b b0 28 a0 23 f0    	mov    -0xfdc5fd8(%eax),%esi
f01042fd:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104302:	89 df                	mov    %ebx,%edi
f0104304:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
    e->env_tf.tf_regs.reg_eax = 0;
f0104306:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104309:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

    return e->env_id;
f0104310:	8b 58 48             	mov    0x48(%eax),%ebx
f0104313:	e9 e1 00 00 00       	jmp    f01043f9 <syscall+0x4a5>
	// envid's status.

	// LAB 4: Your code here.
    struct Env *e;

    if(envid2env(envid, &e, 1) < 0)
f0104318:	83 ec 04             	sub    $0x4,%esp
f010431b:	6a 01                	push   $0x1
f010431d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104320:	50                   	push   %eax
f0104321:	ff 75 0c             	pushl  0xc(%ebp)
f0104324:	e8 bf e0 ff ff       	call   f01023e8 <envid2env>
f0104329:	83 c4 10             	add    $0x10,%esp
f010432c:	85 c0                	test   %eax,%eax
f010432e:	78 20                	js     f0104350 <syscall+0x3fc>
    {
        return -E_BAD_ENV;
    }

    if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f0104330:	8b 45 10             	mov    0x10(%ebp),%eax
f0104333:	83 e8 02             	sub    $0x2,%eax
f0104336:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f010433b:	75 1d                	jne    f010435a <syscall+0x406>
    {
        return -E_INVAL;
    }

    e->env_status = status;
f010433d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104340:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104343:	89 78 54             	mov    %edi,0x54(%eax)
    return 0;
f0104346:	bb 00 00 00 00       	mov    $0x0,%ebx
f010434b:	e9 a9 00 00 00       	jmp    f01043f9 <syscall+0x4a5>
	// LAB 4: Your code here.
    struct Env *e;

    if(envid2env(envid, &e, 1) < 0)
    {
        return -E_BAD_ENV;
f0104350:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104355:	e9 9f 00 00 00       	jmp    f01043f9 <syscall+0x4a5>
    }

    if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
    {
        return -E_INVAL;
f010435a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
        case SYS_page_unmap:
             return sys_page_unmap(a1, (void *)a2);
        case SYS_exofork:
             return sys_exofork();
        case SYS_env_set_status:
             return sys_env_set_status(a1, a2);
f010435f:	e9 95 00 00 00       	jmp    f01043f9 <syscall+0x4a5>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
    struct Env *e;

    if(envid2env(envid, &e, 1) < 0)
f0104364:	83 ec 04             	sub    $0x4,%esp
f0104367:	6a 01                	push   $0x1
f0104369:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010436c:	50                   	push   %eax
f010436d:	ff 75 0c             	pushl  0xc(%ebp)
f0104370:	e8 73 e0 ff ff       	call   f01023e8 <envid2env>
f0104375:	83 c4 10             	add    $0x10,%esp
f0104378:	85 c0                	test   %eax,%eax
f010437a:	78 1e                	js     f010439a <syscall+0x446>
    {
        return -E_BAD_ENV;
    }

    e->env_pgfault_upcall = func;
f010437c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010437f:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104382:	89 48 64             	mov    %ecx,0x64(%eax)
    user_mem_assert(e, func, 4, 0);
f0104385:	6a 00                	push   $0x0
f0104387:	6a 04                	push   $0x4
f0104389:	51                   	push   %ecx
f010438a:	50                   	push   %eax
f010438b:	e8 83 df ff ff       	call   f0102313 <user_mem_assert>
f0104390:	83 c4 10             	add    $0x10,%esp

    return 0;
f0104393:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104398:	eb 5f                	jmp    f01043f9 <syscall+0x4a5>
	// LAB 4: Your code here.
    struct Env *e;

    if(envid2env(envid, &e, 1) < 0)
    {
        return -E_BAD_ENV;
f010439a:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
        case SYS_exofork:
             return sys_exofork();
        case SYS_env_set_status:
             return sys_env_set_status(a1, a2);
        case SYS_env_set_pgfault_upcall:
             return sys_env_set_pgfault_upcall(a1, (void *)a2);
f010439f:	eb 58                	jmp    f01043f9 <syscall+0x4a5>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f01043a1:	e8 40 fb ff ff       	call   f0103ee6 <sched_yield>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 2: Your code here.


	panic("sys_ipc_try_send not implemented");
f01043a6:	83 ec 04             	sub    $0x4,%esp
f01043a9:	68 d0 6f 10 f0       	push   $0xf0106fd0
f01043ae:	68 80 01 00 00       	push   $0x180
f01043b3:	68 47 6f 10 f0       	push   $0xf0106f47
f01043b8:	e8 83 bc ff ff       	call   f0100040 <_panic>
static int
sys_ipc_recv(void *dstva)
{
	// LAB 2: Your code here.
    
	panic("sys_ipc_recv not implemented");
f01043bd:	83 ec 04             	sub    $0x4,%esp
f01043c0:	68 56 6f 10 f0       	push   $0xf0106f56
f01043c5:	68 93 01 00 00       	push   $0x193
f01043ca:	68 47 6f 10 f0       	push   $0xf0106f47
f01043cf:	e8 6c bc ff ff       	call   f0100040 <_panic>
        case SYS_ipc_recv:
             return sys_ipc_recv((void *)a1);

        default:

            cprintf("Error syscall(%u)\n", syscallno);
f01043d4:	83 ec 08             	sub    $0x8,%esp
f01043d7:	50                   	push   %eax
f01043d8:	68 73 6f 10 f0       	push   $0xf0106f73
f01043dd:	e8 d6 e8 ff ff       	call   f0102cb8 <cprintf>
            panic("syscall not impelmented\n");
f01043e2:	83 c4 0c             	add    $0xc,%esp
f01043e5:	68 86 6f 10 f0       	push   $0xf0106f86
f01043ea:	68 c6 01 00 00       	push   $0x1c6
f01043ef:	68 47 6f 10 f0       	push   $0xf0106f47
f01043f4:	e8 47 bc ff ff       	call   f0100040 <_panic>

            return -E_NO_SYS;
	}

    return r;
}
f01043f9:	89 d8                	mov    %ebx,%eax
f01043fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01043fe:	5b                   	pop    %ebx
f01043ff:	5e                   	pop    %esi
f0104400:	5f                   	pop    %edi
f0104401:	5d                   	pop    %ebp
f0104402:	c3                   	ret    

f0104403 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104403:	55                   	push   %ebp
f0104404:	89 e5                	mov    %esp,%ebp
f0104406:	57                   	push   %edi
f0104407:	56                   	push   %esi
f0104408:	53                   	push   %ebx
f0104409:	83 ec 14             	sub    $0x14,%esp
f010440c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010440f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104412:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104415:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104418:	8b 1a                	mov    (%edx),%ebx
f010441a:	8b 01                	mov    (%ecx),%eax
f010441c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010441f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104426:	eb 7f                	jmp    f01044a7 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104428:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010442b:	01 d8                	add    %ebx,%eax
f010442d:	89 c6                	mov    %eax,%esi
f010442f:	c1 ee 1f             	shr    $0x1f,%esi
f0104432:	01 c6                	add    %eax,%esi
f0104434:	d1 fe                	sar    %esi
f0104436:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104439:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010443c:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f010443f:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104441:	eb 03                	jmp    f0104446 <stab_binsearch+0x43>
			m--;
f0104443:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104446:	39 c3                	cmp    %eax,%ebx
f0104448:	7f 0d                	jg     f0104457 <stab_binsearch+0x54>
f010444a:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010444e:	83 ea 0c             	sub    $0xc,%edx
f0104451:	39 f9                	cmp    %edi,%ecx
f0104453:	75 ee                	jne    f0104443 <stab_binsearch+0x40>
f0104455:	eb 05                	jmp    f010445c <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104457:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f010445a:	eb 4b                	jmp    f01044a7 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010445c:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010445f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104462:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104466:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104469:	76 11                	jbe    f010447c <stab_binsearch+0x79>
			*region_left = m;
f010446b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010446e:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104470:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104473:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010447a:	eb 2b                	jmp    f01044a7 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010447c:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010447f:	73 14                	jae    f0104495 <stab_binsearch+0x92>
			*region_right = m - 1;
f0104481:	83 e8 01             	sub    $0x1,%eax
f0104484:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104487:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010448a:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010448c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104493:	eb 12                	jmp    f01044a7 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104495:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104498:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f010449a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010449e:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01044a0:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01044a7:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01044aa:	0f 8e 78 ff ff ff    	jle    f0104428 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01044b0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01044b4:	75 0f                	jne    f01044c5 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f01044b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01044b9:	8b 00                	mov    (%eax),%eax
f01044bb:	83 e8 01             	sub    $0x1,%eax
f01044be:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01044c1:	89 06                	mov    %eax,(%esi)
f01044c3:	eb 2c                	jmp    f01044f1 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01044c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01044c8:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01044ca:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01044cd:	8b 0e                	mov    (%esi),%ecx
f01044cf:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01044d2:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01044d5:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01044d8:	eb 03                	jmp    f01044dd <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01044da:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01044dd:	39 c8                	cmp    %ecx,%eax
f01044df:	7e 0b                	jle    f01044ec <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f01044e1:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01044e5:	83 ea 0c             	sub    $0xc,%edx
f01044e8:	39 df                	cmp    %ebx,%edi
f01044ea:	75 ee                	jne    f01044da <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01044ec:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01044ef:	89 06                	mov    %eax,(%esi)
	}
}
f01044f1:	83 c4 14             	add    $0x14,%esp
f01044f4:	5b                   	pop    %ebx
f01044f5:	5e                   	pop    %esi
f01044f6:	5f                   	pop    %edi
f01044f7:	5d                   	pop    %ebp
f01044f8:	c3                   	ret    

f01044f9 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01044f9:	55                   	push   %ebp
f01044fa:	89 e5                	mov    %esp,%ebp
f01044fc:	57                   	push   %edi
f01044fd:	56                   	push   %esi
f01044fe:	53                   	push   %ebx
f01044ff:	83 ec 3c             	sub    $0x3c,%esp
f0104502:	8b 75 08             	mov    0x8(%ebp),%esi
f0104505:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104508:	c7 03 28 70 10 f0    	movl   $0xf0107028,(%ebx)
	info->eip_line = 0;
f010450e:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104515:	c7 43 08 28 70 10 f0 	movl   $0xf0107028,0x8(%ebx)
	info->eip_fn_namelen = 9;
f010451c:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104523:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104526:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010452d:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104533:	77 21                	ja     f0104556 <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104535:	a1 00 00 20 00       	mov    0x200000,%eax
f010453a:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stab_end = usd->stab_end;
f010453d:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104542:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f0104548:	89 7d b8             	mov    %edi,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f010454b:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f0104551:	89 7d c0             	mov    %edi,-0x40(%ebp)
f0104554:	eb 1a                	jmp    f0104570 <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104556:	c7 45 c0 b2 49 11 f0 	movl   $0xf01149b2,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f010455d:	c7 45 b8 e9 13 11 f0 	movl   $0xf01113e9,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104564:	b8 e8 13 11 f0       	mov    $0xf01113e8,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104569:	c7 45 bc 18 75 10 f0 	movl   $0xf0107518,-0x44(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104570:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104573:	39 7d b8             	cmp    %edi,-0x48(%ebp)
f0104576:	0f 83 95 01 00 00    	jae    f0104711 <debuginfo_eip+0x218>
f010457c:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0104580:	0f 85 92 01 00 00    	jne    f0104718 <debuginfo_eip+0x21f>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104586:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010458d:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104590:	29 f8                	sub    %edi,%eax
f0104592:	c1 f8 02             	sar    $0x2,%eax
f0104595:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010459b:	83 e8 01             	sub    $0x1,%eax
f010459e:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01045a1:	56                   	push   %esi
f01045a2:	6a 64                	push   $0x64
f01045a4:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01045a7:	89 c1                	mov    %eax,%ecx
f01045a9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01045ac:	89 f8                	mov    %edi,%eax
f01045ae:	e8 50 fe ff ff       	call   f0104403 <stab_binsearch>
	if (lfile == 0)
f01045b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01045b6:	83 c4 08             	add    $0x8,%esp
f01045b9:	85 c0                	test   %eax,%eax
f01045bb:	0f 84 5e 01 00 00    	je     f010471f <debuginfo_eip+0x226>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01045c1:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01045c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01045c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01045ca:	56                   	push   %esi
f01045cb:	6a 24                	push   $0x24
f01045cd:	8d 45 d8             	lea    -0x28(%ebp),%eax
f01045d0:	89 c1                	mov    %eax,%ecx
f01045d2:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01045d5:	89 f8                	mov    %edi,%eax
f01045d7:	e8 27 fe ff ff       	call   f0104403 <stab_binsearch>

	if (lfun <= rfun) {
f01045dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01045df:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01045e2:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f01045e5:	83 c4 08             	add    $0x8,%esp
f01045e8:	39 d0                	cmp    %edx,%eax
f01045ea:	7f 2b                	jg     f0104617 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01045ec:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01045ef:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f01045f2:	8b 11                	mov    (%ecx),%edx
f01045f4:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01045f7:	2b 7d b8             	sub    -0x48(%ebp),%edi
f01045fa:	39 fa                	cmp    %edi,%edx
f01045fc:	73 06                	jae    f0104604 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01045fe:	03 55 b8             	add    -0x48(%ebp),%edx
f0104601:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104604:	8b 51 08             	mov    0x8(%ecx),%edx
f0104607:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f010460a:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f010460c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010460f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104612:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104615:	eb 0f                	jmp    f0104626 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104617:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010461a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010461d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104620:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104623:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104626:	83 ec 08             	sub    $0x8,%esp
f0104629:	6a 3a                	push   $0x3a
f010462b:	ff 73 08             	pushl  0x8(%ebx)
f010462e:	e8 91 08 00 00       	call   f0104ec4 <strfind>
f0104633:	2b 43 08             	sub    0x8(%ebx),%eax
f0104636:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104639:	83 c4 08             	add    $0x8,%esp
f010463c:	56                   	push   %esi
f010463d:	6a 44                	push   $0x44
f010463f:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104642:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104645:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0104648:	89 f0                	mov    %esi,%eax
f010464a:	e8 b4 fd ff ff       	call   f0104403 <stab_binsearch>
    if(rline >= lline)
f010464f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104652:	83 c4 10             	add    $0x10,%esp
f0104655:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0104658:	0f 8c c8 00 00 00    	jl     f0104726 <debuginfo_eip+0x22d>
    {
        info->eip_line = stabs[lline].n_desc;
f010465e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104661:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0104664:	0f b7 4a 06          	movzwl 0x6(%edx),%ecx
f0104668:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010466b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010466e:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104672:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104675:	eb 0a                	jmp    f0104681 <debuginfo_eip+0x188>
f0104677:	83 e8 01             	sub    $0x1,%eax
f010467a:	83 ea 0c             	sub    $0xc,%edx
f010467d:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104681:	39 c7                	cmp    %eax,%edi
f0104683:	7e 05                	jle    f010468a <debuginfo_eip+0x191>
f0104685:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104688:	eb 47                	jmp    f01046d1 <debuginfo_eip+0x1d8>
	       && stabs[lline].n_type != N_SOL
f010468a:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010468e:	80 f9 84             	cmp    $0x84,%cl
f0104691:	75 0e                	jne    f01046a1 <debuginfo_eip+0x1a8>
f0104693:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104696:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f010469a:	74 1c                	je     f01046b8 <debuginfo_eip+0x1bf>
f010469c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010469f:	eb 17                	jmp    f01046b8 <debuginfo_eip+0x1bf>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01046a1:	80 f9 64             	cmp    $0x64,%cl
f01046a4:	75 d1                	jne    f0104677 <debuginfo_eip+0x17e>
f01046a6:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f01046aa:	74 cb                	je     f0104677 <debuginfo_eip+0x17e>
f01046ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01046af:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01046b3:	74 03                	je     f01046b8 <debuginfo_eip+0x1bf>
f01046b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01046b8:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01046bb:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01046be:	8b 14 87             	mov    (%edi,%eax,4),%edx
f01046c1:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01046c4:	8b 75 b8             	mov    -0x48(%ebp),%esi
f01046c7:	29 f0                	sub    %esi,%eax
f01046c9:	39 c2                	cmp    %eax,%edx
f01046cb:	73 04                	jae    f01046d1 <debuginfo_eip+0x1d8>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01046cd:	01 f2                	add    %esi,%edx
f01046cf:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01046d1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01046d4:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01046d7:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01046dc:	39 f2                	cmp    %esi,%edx
f01046de:	7d 52                	jge    f0104732 <debuginfo_eip+0x239>
		for (lline = lfun + 1;
f01046e0:	83 c2 01             	add    $0x1,%edx
f01046e3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01046e6:	89 d0                	mov    %edx,%eax
f01046e8:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01046eb:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01046ee:	8d 14 97             	lea    (%edi,%edx,4),%edx
f01046f1:	eb 04                	jmp    f01046f7 <debuginfo_eip+0x1fe>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01046f3:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01046f7:	39 c6                	cmp    %eax,%esi
f01046f9:	7e 32                	jle    f010472d <debuginfo_eip+0x234>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01046fb:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01046ff:	83 c0 01             	add    $0x1,%eax
f0104702:	83 c2 0c             	add    $0xc,%edx
f0104705:	80 f9 a0             	cmp    $0xa0,%cl
f0104708:	74 e9                	je     f01046f3 <debuginfo_eip+0x1fa>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010470a:	b8 00 00 00 00       	mov    $0x0,%eax
f010470f:	eb 21                	jmp    f0104732 <debuginfo_eip+0x239>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104711:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104716:	eb 1a                	jmp    f0104732 <debuginfo_eip+0x239>
f0104718:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010471d:	eb 13                	jmp    f0104732 <debuginfo_eip+0x239>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f010471f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104724:	eb 0c                	jmp    f0104732 <debuginfo_eip+0x239>
    {
        info->eip_line = stabs[lline].n_desc;
    }
    else
    {
        return -1;
f0104726:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010472b:	eb 05                	jmp    f0104732 <debuginfo_eip+0x239>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010472d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104732:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104735:	5b                   	pop    %ebx
f0104736:	5e                   	pop    %esi
f0104737:	5f                   	pop    %edi
f0104738:	5d                   	pop    %ebp
f0104739:	c3                   	ret    

f010473a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010473a:	55                   	push   %ebp
f010473b:	89 e5                	mov    %esp,%ebp
f010473d:	57                   	push   %edi
f010473e:	56                   	push   %esi
f010473f:	53                   	push   %ebx
f0104740:	83 ec 1c             	sub    $0x1c,%esp
f0104743:	89 c7                	mov    %eax,%edi
f0104745:	89 d6                	mov    %edx,%esi
f0104747:	8b 45 08             	mov    0x8(%ebp),%eax
f010474a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010474d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104750:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104753:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104756:	bb 00 00 00 00       	mov    $0x0,%ebx
f010475b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010475e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104761:	39 d3                	cmp    %edx,%ebx
f0104763:	72 05                	jb     f010476a <printnum+0x30>
f0104765:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104768:	77 45                	ja     f01047af <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010476a:	83 ec 0c             	sub    $0xc,%esp
f010476d:	ff 75 18             	pushl  0x18(%ebp)
f0104770:	8b 45 14             	mov    0x14(%ebp),%eax
f0104773:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104776:	53                   	push   %ebx
f0104777:	ff 75 10             	pushl  0x10(%ebp)
f010477a:	83 ec 08             	sub    $0x8,%esp
f010477d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104780:	ff 75 e0             	pushl  -0x20(%ebp)
f0104783:	ff 75 dc             	pushl  -0x24(%ebp)
f0104786:	ff 75 d8             	pushl  -0x28(%ebp)
f0104789:	e8 72 11 00 00       	call   f0105900 <__udivdi3>
f010478e:	83 c4 18             	add    $0x18,%esp
f0104791:	52                   	push   %edx
f0104792:	50                   	push   %eax
f0104793:	89 f2                	mov    %esi,%edx
f0104795:	89 f8                	mov    %edi,%eax
f0104797:	e8 9e ff ff ff       	call   f010473a <printnum>
f010479c:	83 c4 20             	add    $0x20,%esp
f010479f:	eb 18                	jmp    f01047b9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01047a1:	83 ec 08             	sub    $0x8,%esp
f01047a4:	56                   	push   %esi
f01047a5:	ff 75 18             	pushl  0x18(%ebp)
f01047a8:	ff d7                	call   *%edi
f01047aa:	83 c4 10             	add    $0x10,%esp
f01047ad:	eb 03                	jmp    f01047b2 <printnum+0x78>
f01047af:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01047b2:	83 eb 01             	sub    $0x1,%ebx
f01047b5:	85 db                	test   %ebx,%ebx
f01047b7:	7f e8                	jg     f01047a1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01047b9:	83 ec 08             	sub    $0x8,%esp
f01047bc:	56                   	push   %esi
f01047bd:	83 ec 04             	sub    $0x4,%esp
f01047c0:	ff 75 e4             	pushl  -0x1c(%ebp)
f01047c3:	ff 75 e0             	pushl  -0x20(%ebp)
f01047c6:	ff 75 dc             	pushl  -0x24(%ebp)
f01047c9:	ff 75 d8             	pushl  -0x28(%ebp)
f01047cc:	e8 5f 12 00 00       	call   f0105a30 <__umoddi3>
f01047d1:	83 c4 14             	add    $0x14,%esp
f01047d4:	0f be 80 32 70 10 f0 	movsbl -0xfef8fce(%eax),%eax
f01047db:	50                   	push   %eax
f01047dc:	ff d7                	call   *%edi
}
f01047de:	83 c4 10             	add    $0x10,%esp
f01047e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01047e4:	5b                   	pop    %ebx
f01047e5:	5e                   	pop    %esi
f01047e6:	5f                   	pop    %edi
f01047e7:	5d                   	pop    %ebp
f01047e8:	c3                   	ret    

f01047e9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01047e9:	55                   	push   %ebp
f01047ea:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01047ec:	83 fa 01             	cmp    $0x1,%edx
f01047ef:	7e 0e                	jle    f01047ff <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01047f1:	8b 10                	mov    (%eax),%edx
f01047f3:	8d 4a 08             	lea    0x8(%edx),%ecx
f01047f6:	89 08                	mov    %ecx,(%eax)
f01047f8:	8b 02                	mov    (%edx),%eax
f01047fa:	8b 52 04             	mov    0x4(%edx),%edx
f01047fd:	eb 22                	jmp    f0104821 <getuint+0x38>
	else if (lflag)
f01047ff:	85 d2                	test   %edx,%edx
f0104801:	74 10                	je     f0104813 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104803:	8b 10                	mov    (%eax),%edx
f0104805:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104808:	89 08                	mov    %ecx,(%eax)
f010480a:	8b 02                	mov    (%edx),%eax
f010480c:	ba 00 00 00 00       	mov    $0x0,%edx
f0104811:	eb 0e                	jmp    f0104821 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104813:	8b 10                	mov    (%eax),%edx
f0104815:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104818:	89 08                	mov    %ecx,(%eax)
f010481a:	8b 02                	mov    (%edx),%eax
f010481c:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104821:	5d                   	pop    %ebp
f0104822:	c3                   	ret    

f0104823 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104823:	55                   	push   %ebp
f0104824:	89 e5                	mov    %esp,%ebp
f0104826:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104829:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010482d:	8b 10                	mov    (%eax),%edx
f010482f:	3b 50 04             	cmp    0x4(%eax),%edx
f0104832:	73 0a                	jae    f010483e <sprintputch+0x1b>
		*b->buf++ = ch;
f0104834:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104837:	89 08                	mov    %ecx,(%eax)
f0104839:	8b 45 08             	mov    0x8(%ebp),%eax
f010483c:	88 02                	mov    %al,(%edx)
}
f010483e:	5d                   	pop    %ebp
f010483f:	c3                   	ret    

f0104840 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104840:	55                   	push   %ebp
f0104841:	89 e5                	mov    %esp,%ebp
f0104843:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104846:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104849:	50                   	push   %eax
f010484a:	ff 75 10             	pushl  0x10(%ebp)
f010484d:	ff 75 0c             	pushl  0xc(%ebp)
f0104850:	ff 75 08             	pushl  0x8(%ebp)
f0104853:	e8 05 00 00 00       	call   f010485d <vprintfmt>
	va_end(ap);
}
f0104858:	83 c4 10             	add    $0x10,%esp
f010485b:	c9                   	leave  
f010485c:	c3                   	ret    

f010485d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010485d:	55                   	push   %ebp
f010485e:	89 e5                	mov    %esp,%ebp
f0104860:	57                   	push   %edi
f0104861:	56                   	push   %esi
f0104862:	53                   	push   %ebx
f0104863:	83 ec 2c             	sub    $0x2c,%esp
f0104866:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
f0104869:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104870:	eb 17                	jmp    f0104889 <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104872:	85 c0                	test   %eax,%eax
f0104874:	0f 84 9f 03 00 00    	je     f0104c19 <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
f010487a:	83 ec 08             	sub    $0x8,%esp
f010487d:	ff 75 0c             	pushl  0xc(%ebp)
f0104880:	50                   	push   %eax
f0104881:	ff 55 08             	call   *0x8(%ebp)
f0104884:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104887:	89 f3                	mov    %esi,%ebx
f0104889:	8d 73 01             	lea    0x1(%ebx),%esi
f010488c:	0f b6 03             	movzbl (%ebx),%eax
f010488f:	83 f8 25             	cmp    $0x25,%eax
f0104892:	75 de                	jne    f0104872 <vprintfmt+0x15>
f0104894:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f0104898:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010489f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f01048a4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f01048ab:	ba 00 00 00 00       	mov    $0x0,%edx
f01048b0:	eb 06                	jmp    f01048b8 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01048b2:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f01048b4:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01048b8:	8d 5e 01             	lea    0x1(%esi),%ebx
f01048bb:	0f b6 06             	movzbl (%esi),%eax
f01048be:	0f b6 c8             	movzbl %al,%ecx
f01048c1:	83 e8 23             	sub    $0x23,%eax
f01048c4:	3c 55                	cmp    $0x55,%al
f01048c6:	0f 87 2d 03 00 00    	ja     f0104bf9 <vprintfmt+0x39c>
f01048cc:	0f b6 c0             	movzbl %al,%eax
f01048cf:	ff 24 85 00 71 10 f0 	jmp    *-0xfef8f00(,%eax,4)
f01048d6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01048d8:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f01048dc:	eb da                	jmp    f01048b8 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01048de:	89 de                	mov    %ebx,%esi
f01048e0:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01048e5:	8d 04 bf             	lea    (%edi,%edi,4),%eax
f01048e8:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
f01048ec:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
f01048ef:	8d 41 d0             	lea    -0x30(%ecx),%eax
f01048f2:	83 f8 09             	cmp    $0x9,%eax
f01048f5:	77 33                	ja     f010492a <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01048f7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01048fa:	eb e9                	jmp    f01048e5 <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01048fc:	8b 45 14             	mov    0x14(%ebp),%eax
f01048ff:	8d 48 04             	lea    0x4(%eax),%ecx
f0104902:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104905:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104907:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104909:	eb 1f                	jmp    f010492a <vprintfmt+0xcd>
f010490b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010490e:	85 c0                	test   %eax,%eax
f0104910:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104915:	0f 49 c8             	cmovns %eax,%ecx
f0104918:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010491b:	89 de                	mov    %ebx,%esi
f010491d:	eb 99                	jmp    f01048b8 <vprintfmt+0x5b>
f010491f:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104921:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
f0104928:	eb 8e                	jmp    f01048b8 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
f010492a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010492e:	79 88                	jns    f01048b8 <vprintfmt+0x5b>
				width = precision, precision = -1;
f0104930:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0104933:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0104938:	e9 7b ff ff ff       	jmp    f01048b8 <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010493d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104940:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104942:	e9 71 ff ff ff       	jmp    f01048b8 <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
f0104947:	8b 45 14             	mov    0x14(%ebp),%eax
f010494a:	8d 50 04             	lea    0x4(%eax),%edx
f010494d:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
f0104950:	83 ec 08             	sub    $0x8,%esp
f0104953:	ff 75 0c             	pushl  0xc(%ebp)
f0104956:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0104959:	03 08                	add    (%eax),%ecx
f010495b:	51                   	push   %ecx
f010495c:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
f010495f:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
f0104962:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
f0104969:	e9 1b ff ff ff       	jmp    f0104889 <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
f010496e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104971:	8d 48 04             	lea    0x4(%eax),%ecx
f0104974:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104977:	8b 00                	mov    (%eax),%eax
f0104979:	83 f8 02             	cmp    $0x2,%eax
f010497c:	74 1a                	je     f0104998 <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010497e:	89 de                	mov    %ebx,%esi
f0104980:	83 f8 04             	cmp    $0x4,%eax
f0104983:	b8 00 00 00 00       	mov    $0x0,%eax
f0104988:	b9 00 04 00 00       	mov    $0x400,%ecx
f010498d:	0f 44 c1             	cmove  %ecx,%eax
f0104990:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104993:	e9 20 ff ff ff       	jmp    f01048b8 <vprintfmt+0x5b>
f0104998:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
f010499a:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
f01049a1:	e9 12 ff ff ff       	jmp    f01048b8 <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
f01049a6:	8b 45 14             	mov    0x14(%ebp),%eax
f01049a9:	8d 50 04             	lea    0x4(%eax),%edx
f01049ac:	89 55 14             	mov    %edx,0x14(%ebp)
f01049af:	8b 00                	mov    (%eax),%eax
f01049b1:	99                   	cltd   
f01049b2:	31 d0                	xor    %edx,%eax
f01049b4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01049b6:	83 f8 09             	cmp    $0x9,%eax
f01049b9:	7f 0b                	jg     f01049c6 <vprintfmt+0x169>
f01049bb:	8b 14 85 60 72 10 f0 	mov    -0xfef8da0(,%eax,4),%edx
f01049c2:	85 d2                	test   %edx,%edx
f01049c4:	75 19                	jne    f01049df <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
f01049c6:	50                   	push   %eax
f01049c7:	68 4a 70 10 f0       	push   $0xf010704a
f01049cc:	ff 75 0c             	pushl  0xc(%ebp)
f01049cf:	ff 75 08             	pushl  0x8(%ebp)
f01049d2:	e8 69 fe ff ff       	call   f0104840 <printfmt>
f01049d7:	83 c4 10             	add    $0x10,%esp
f01049da:	e9 aa fe ff ff       	jmp    f0104889 <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
f01049df:	52                   	push   %edx
f01049e0:	68 28 67 10 f0       	push   $0xf0106728
f01049e5:	ff 75 0c             	pushl  0xc(%ebp)
f01049e8:	ff 75 08             	pushl  0x8(%ebp)
f01049eb:	e8 50 fe ff ff       	call   f0104840 <printfmt>
f01049f0:	83 c4 10             	add    $0x10,%esp
f01049f3:	e9 91 fe ff ff       	jmp    f0104889 <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01049f8:	8b 45 14             	mov    0x14(%ebp),%eax
f01049fb:	8d 50 04             	lea    0x4(%eax),%edx
f01049fe:	89 55 14             	mov    %edx,0x14(%ebp)
f0104a01:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0104a03:	85 f6                	test   %esi,%esi
f0104a05:	b8 43 70 10 f0       	mov    $0xf0107043,%eax
f0104a0a:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f0104a0d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104a11:	0f 8e 93 00 00 00    	jle    f0104aaa <vprintfmt+0x24d>
f0104a17:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f0104a1b:	0f 84 91 00 00 00    	je     f0104ab2 <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104a21:	83 ec 08             	sub    $0x8,%esp
f0104a24:	57                   	push   %edi
f0104a25:	56                   	push   %esi
f0104a26:	e8 4f 03 00 00       	call   f0104d7a <strnlen>
f0104a2b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104a2e:	29 c1                	sub    %eax,%ecx
f0104a30:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104a33:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0104a36:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
f0104a3a:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0104a3d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104a40:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104a43:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104a46:	89 cb                	mov    %ecx,%ebx
f0104a48:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104a4a:	eb 0e                	jmp    f0104a5a <vprintfmt+0x1fd>
					putch(padc, putdat);
f0104a4c:	83 ec 08             	sub    $0x8,%esp
f0104a4f:	56                   	push   %esi
f0104a50:	57                   	push   %edi
f0104a51:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104a54:	83 eb 01             	sub    $0x1,%ebx
f0104a57:	83 c4 10             	add    $0x10,%esp
f0104a5a:	85 db                	test   %ebx,%ebx
f0104a5c:	7f ee                	jg     f0104a4c <vprintfmt+0x1ef>
f0104a5e:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0104a61:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104a64:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104a67:	85 c9                	test   %ecx,%ecx
f0104a69:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a6e:	0f 49 c1             	cmovns %ecx,%eax
f0104a71:	29 c1                	sub    %eax,%ecx
f0104a73:	89 cb                	mov    %ecx,%ebx
f0104a75:	eb 41                	jmp    f0104ab8 <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104a77:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104a7b:	74 1b                	je     f0104a98 <vprintfmt+0x23b>
f0104a7d:	0f be c0             	movsbl %al,%eax
f0104a80:	83 e8 20             	sub    $0x20,%eax
f0104a83:	83 f8 5e             	cmp    $0x5e,%eax
f0104a86:	76 10                	jbe    f0104a98 <vprintfmt+0x23b>
					putch('?', putdat);
f0104a88:	83 ec 08             	sub    $0x8,%esp
f0104a8b:	ff 75 0c             	pushl  0xc(%ebp)
f0104a8e:	6a 3f                	push   $0x3f
f0104a90:	ff 55 08             	call   *0x8(%ebp)
f0104a93:	83 c4 10             	add    $0x10,%esp
f0104a96:	eb 0d                	jmp    f0104aa5 <vprintfmt+0x248>
				else
					putch(ch, putdat);
f0104a98:	83 ec 08             	sub    $0x8,%esp
f0104a9b:	ff 75 0c             	pushl  0xc(%ebp)
f0104a9e:	52                   	push   %edx
f0104a9f:	ff 55 08             	call   *0x8(%ebp)
f0104aa2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104aa5:	83 eb 01             	sub    $0x1,%ebx
f0104aa8:	eb 0e                	jmp    f0104ab8 <vprintfmt+0x25b>
f0104aaa:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104aad:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104ab0:	eb 06                	jmp    f0104ab8 <vprintfmt+0x25b>
f0104ab2:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104ab5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104ab8:	83 c6 01             	add    $0x1,%esi
f0104abb:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
f0104abf:	0f be d0             	movsbl %al,%edx
f0104ac2:	85 d2                	test   %edx,%edx
f0104ac4:	74 25                	je     f0104aeb <vprintfmt+0x28e>
f0104ac6:	85 ff                	test   %edi,%edi
f0104ac8:	78 ad                	js     f0104a77 <vprintfmt+0x21a>
f0104aca:	83 ef 01             	sub    $0x1,%edi
f0104acd:	79 a8                	jns    f0104a77 <vprintfmt+0x21a>
f0104acf:	89 d8                	mov    %ebx,%eax
f0104ad1:	8b 75 08             	mov    0x8(%ebp),%esi
f0104ad4:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104ad7:	89 c3                	mov    %eax,%ebx
f0104ad9:	eb 16                	jmp    f0104af1 <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104adb:	83 ec 08             	sub    $0x8,%esp
f0104ade:	57                   	push   %edi
f0104adf:	6a 20                	push   $0x20
f0104ae1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104ae3:	83 eb 01             	sub    $0x1,%ebx
f0104ae6:	83 c4 10             	add    $0x10,%esp
f0104ae9:	eb 06                	jmp    f0104af1 <vprintfmt+0x294>
f0104aeb:	8b 75 08             	mov    0x8(%ebp),%esi
f0104aee:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104af1:	85 db                	test   %ebx,%ebx
f0104af3:	7f e6                	jg     f0104adb <vprintfmt+0x27e>
f0104af5:	89 75 08             	mov    %esi,0x8(%ebp)
f0104af8:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0104afb:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0104afe:	e9 86 fd ff ff       	jmp    f0104889 <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104b03:	83 fa 01             	cmp    $0x1,%edx
f0104b06:	7e 10                	jle    f0104b18 <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
f0104b08:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b0b:	8d 50 08             	lea    0x8(%eax),%edx
f0104b0e:	89 55 14             	mov    %edx,0x14(%ebp)
f0104b11:	8b 30                	mov    (%eax),%esi
f0104b13:	8b 78 04             	mov    0x4(%eax),%edi
f0104b16:	eb 26                	jmp    f0104b3e <vprintfmt+0x2e1>
	else if (lflag)
f0104b18:	85 d2                	test   %edx,%edx
f0104b1a:	74 12                	je     f0104b2e <vprintfmt+0x2d1>
		return va_arg(*ap, long);
f0104b1c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b1f:	8d 50 04             	lea    0x4(%eax),%edx
f0104b22:	89 55 14             	mov    %edx,0x14(%ebp)
f0104b25:	8b 30                	mov    (%eax),%esi
f0104b27:	89 f7                	mov    %esi,%edi
f0104b29:	c1 ff 1f             	sar    $0x1f,%edi
f0104b2c:	eb 10                	jmp    f0104b3e <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
f0104b2e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b31:	8d 50 04             	lea    0x4(%eax),%edx
f0104b34:	89 55 14             	mov    %edx,0x14(%ebp)
f0104b37:	8b 30                	mov    (%eax),%esi
f0104b39:	89 f7                	mov    %esi,%edi
f0104b3b:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104b3e:	89 f0                	mov    %esi,%eax
f0104b40:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104b42:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0104b47:	85 ff                	test   %edi,%edi
f0104b49:	79 7b                	jns    f0104bc6 <vprintfmt+0x369>
				putch('-', putdat);
f0104b4b:	83 ec 08             	sub    $0x8,%esp
f0104b4e:	ff 75 0c             	pushl  0xc(%ebp)
f0104b51:	6a 2d                	push   $0x2d
f0104b53:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0104b56:	89 f0                	mov    %esi,%eax
f0104b58:	89 fa                	mov    %edi,%edx
f0104b5a:	f7 d8                	neg    %eax
f0104b5c:	83 d2 00             	adc    $0x0,%edx
f0104b5f:	f7 da                	neg    %edx
f0104b61:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0104b64:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0104b69:	eb 5b                	jmp    f0104bc6 <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0104b6b:	8d 45 14             	lea    0x14(%ebp),%eax
f0104b6e:	e8 76 fc ff ff       	call   f01047e9 <getuint>
			base = 10;
f0104b73:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0104b78:	eb 4c                	jmp    f0104bc6 <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
f0104b7a:	8d 45 14             	lea    0x14(%ebp),%eax
f0104b7d:	e8 67 fc ff ff       	call   f01047e9 <getuint>
            base = 8;
f0104b82:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0104b87:	eb 3d                	jmp    f0104bc6 <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
f0104b89:	83 ec 08             	sub    $0x8,%esp
f0104b8c:	ff 75 0c             	pushl  0xc(%ebp)
f0104b8f:	6a 30                	push   $0x30
f0104b91:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0104b94:	83 c4 08             	add    $0x8,%esp
f0104b97:	ff 75 0c             	pushl  0xc(%ebp)
f0104b9a:	6a 78                	push   $0x78
f0104b9c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104b9f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ba2:	8d 50 04             	lea    0x4(%eax),%edx
f0104ba5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104ba8:	8b 00                	mov    (%eax),%eax
f0104baa:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0104baf:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0104bb2:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0104bb7:	eb 0d                	jmp    f0104bc6 <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104bb9:	8d 45 14             	lea    0x14(%ebp),%eax
f0104bbc:	e8 28 fc ff ff       	call   f01047e9 <getuint>
			base = 16;
f0104bc1:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104bc6:	83 ec 0c             	sub    $0xc,%esp
f0104bc9:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
f0104bcd:	56                   	push   %esi
f0104bce:	ff 75 e0             	pushl  -0x20(%ebp)
f0104bd1:	51                   	push   %ecx
f0104bd2:	52                   	push   %edx
f0104bd3:	50                   	push   %eax
f0104bd4:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104bd7:	8b 45 08             	mov    0x8(%ebp),%eax
f0104bda:	e8 5b fb ff ff       	call   f010473a <printnum>
			break;
f0104bdf:	83 c4 20             	add    $0x20,%esp
f0104be2:	e9 a2 fc ff ff       	jmp    f0104889 <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104be7:	83 ec 08             	sub    $0x8,%esp
f0104bea:	ff 75 0c             	pushl  0xc(%ebp)
f0104bed:	51                   	push   %ecx
f0104bee:	ff 55 08             	call   *0x8(%ebp)
			break;
f0104bf1:	83 c4 10             	add    $0x10,%esp
f0104bf4:	e9 90 fc ff ff       	jmp    f0104889 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104bf9:	83 ec 08             	sub    $0x8,%esp
f0104bfc:	ff 75 0c             	pushl  0xc(%ebp)
f0104bff:	6a 25                	push   $0x25
f0104c01:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104c04:	83 c4 10             	add    $0x10,%esp
f0104c07:	89 f3                	mov    %esi,%ebx
f0104c09:	eb 03                	jmp    f0104c0e <vprintfmt+0x3b1>
f0104c0b:	83 eb 01             	sub    $0x1,%ebx
f0104c0e:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0104c12:	75 f7                	jne    f0104c0b <vprintfmt+0x3ae>
f0104c14:	e9 70 fc ff ff       	jmp    f0104889 <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
f0104c19:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104c1c:	5b                   	pop    %ebx
f0104c1d:	5e                   	pop    %esi
f0104c1e:	5f                   	pop    %edi
f0104c1f:	5d                   	pop    %ebp
f0104c20:	c3                   	ret    

f0104c21 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104c21:	55                   	push   %ebp
f0104c22:	89 e5                	mov    %esp,%ebp
f0104c24:	83 ec 18             	sub    $0x18,%esp
f0104c27:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c2a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104c2d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104c30:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104c34:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104c37:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104c3e:	85 c0                	test   %eax,%eax
f0104c40:	74 26                	je     f0104c68 <vsnprintf+0x47>
f0104c42:	85 d2                	test   %edx,%edx
f0104c44:	7e 22                	jle    f0104c68 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104c46:	ff 75 14             	pushl  0x14(%ebp)
f0104c49:	ff 75 10             	pushl  0x10(%ebp)
f0104c4c:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104c4f:	50                   	push   %eax
f0104c50:	68 23 48 10 f0       	push   $0xf0104823
f0104c55:	e8 03 fc ff ff       	call   f010485d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104c5a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104c5d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104c63:	83 c4 10             	add    $0x10,%esp
f0104c66:	eb 05                	jmp    f0104c6d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0104c68:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0104c6d:	c9                   	leave  
f0104c6e:	c3                   	ret    

f0104c6f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104c6f:	55                   	push   %ebp
f0104c70:	89 e5                	mov    %esp,%ebp
f0104c72:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104c75:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104c78:	50                   	push   %eax
f0104c79:	ff 75 10             	pushl  0x10(%ebp)
f0104c7c:	ff 75 0c             	pushl  0xc(%ebp)
f0104c7f:	ff 75 08             	pushl  0x8(%ebp)
f0104c82:	e8 9a ff ff ff       	call   f0104c21 <vsnprintf>
	va_end(ap);

	return rc;
}
f0104c87:	c9                   	leave  
f0104c88:	c3                   	ret    

f0104c89 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104c89:	55                   	push   %ebp
f0104c8a:	89 e5                	mov    %esp,%ebp
f0104c8c:	57                   	push   %edi
f0104c8d:	56                   	push   %esi
f0104c8e:	53                   	push   %ebx
f0104c8f:	83 ec 0c             	sub    $0xc,%esp
f0104c92:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104c95:	85 c0                	test   %eax,%eax
f0104c97:	74 11                	je     f0104caa <readline+0x21>
		cprintf("%s", prompt);
f0104c99:	83 ec 08             	sub    $0x8,%esp
f0104c9c:	50                   	push   %eax
f0104c9d:	68 28 67 10 f0       	push   $0xf0106728
f0104ca2:	e8 11 e0 ff ff       	call   f0102cb8 <cprintf>
f0104ca7:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104caa:	83 ec 0c             	sub    $0xc,%esp
f0104cad:	6a 00                	push   $0x0
f0104caf:	e8 ab ba ff ff       	call   f010075f <iscons>
f0104cb4:	89 c7                	mov    %eax,%edi
f0104cb6:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0104cb9:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104cbe:	e8 8b ba ff ff       	call   f010074e <getchar>
f0104cc3:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104cc5:	85 c0                	test   %eax,%eax
f0104cc7:	79 18                	jns    f0104ce1 <readline+0x58>
			cprintf("read error: %e\n", c);
f0104cc9:	83 ec 08             	sub    $0x8,%esp
f0104ccc:	50                   	push   %eax
f0104ccd:	68 88 72 10 f0       	push   $0xf0107288
f0104cd2:	e8 e1 df ff ff       	call   f0102cb8 <cprintf>
			return NULL;
f0104cd7:	83 c4 10             	add    $0x10,%esp
f0104cda:	b8 00 00 00 00       	mov    $0x0,%eax
f0104cdf:	eb 79                	jmp    f0104d5a <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104ce1:	83 f8 08             	cmp    $0x8,%eax
f0104ce4:	0f 94 c2             	sete   %dl
f0104ce7:	83 f8 7f             	cmp    $0x7f,%eax
f0104cea:	0f 94 c0             	sete   %al
f0104ced:	08 c2                	or     %al,%dl
f0104cef:	74 1a                	je     f0104d0b <readline+0x82>
f0104cf1:	85 f6                	test   %esi,%esi
f0104cf3:	7e 16                	jle    f0104d0b <readline+0x82>
			if (echoing)
f0104cf5:	85 ff                	test   %edi,%edi
f0104cf7:	74 0d                	je     f0104d06 <readline+0x7d>
				cputchar('\b');
f0104cf9:	83 ec 0c             	sub    $0xc,%esp
f0104cfc:	6a 08                	push   $0x8
f0104cfe:	e8 3b ba ff ff       	call   f010073e <cputchar>
f0104d03:	83 c4 10             	add    $0x10,%esp
			i--;
f0104d06:	83 ee 01             	sub    $0x1,%esi
f0104d09:	eb b3                	jmp    f0104cbe <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104d0b:	83 fb 1f             	cmp    $0x1f,%ebx
f0104d0e:	7e 23                	jle    f0104d33 <readline+0xaa>
f0104d10:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104d16:	7f 1b                	jg     f0104d33 <readline+0xaa>
			if (echoing)
f0104d18:	85 ff                	test   %edi,%edi
f0104d1a:	74 0c                	je     f0104d28 <readline+0x9f>
				cputchar(c);
f0104d1c:	83 ec 0c             	sub    $0xc,%esp
f0104d1f:	53                   	push   %ebx
f0104d20:	e8 19 ba ff ff       	call   f010073e <cputchar>
f0104d25:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0104d28:	88 9e 20 9b 23 f0    	mov    %bl,-0xfdc64e0(%esi)
f0104d2e:	8d 76 01             	lea    0x1(%esi),%esi
f0104d31:	eb 8b                	jmp    f0104cbe <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0104d33:	83 fb 0a             	cmp    $0xa,%ebx
f0104d36:	74 05                	je     f0104d3d <readline+0xb4>
f0104d38:	83 fb 0d             	cmp    $0xd,%ebx
f0104d3b:	75 81                	jne    f0104cbe <readline+0x35>
			if (echoing)
f0104d3d:	85 ff                	test   %edi,%edi
f0104d3f:	74 0d                	je     f0104d4e <readline+0xc5>
				cputchar('\n');
f0104d41:	83 ec 0c             	sub    $0xc,%esp
f0104d44:	6a 0a                	push   $0xa
f0104d46:	e8 f3 b9 ff ff       	call   f010073e <cputchar>
f0104d4b:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0104d4e:	c6 86 20 9b 23 f0 00 	movb   $0x0,-0xfdc64e0(%esi)
			return buf;
f0104d55:	b8 20 9b 23 f0       	mov    $0xf0239b20,%eax
		}
	}
}
f0104d5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104d5d:	5b                   	pop    %ebx
f0104d5e:	5e                   	pop    %esi
f0104d5f:	5f                   	pop    %edi
f0104d60:	5d                   	pop    %ebp
f0104d61:	c3                   	ret    

f0104d62 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104d62:	55                   	push   %ebp
f0104d63:	89 e5                	mov    %esp,%ebp
f0104d65:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104d68:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d6d:	eb 03                	jmp    f0104d72 <strlen+0x10>
		n++;
f0104d6f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104d72:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104d76:	75 f7                	jne    f0104d6f <strlen+0xd>
		n++;
	return n;
}
f0104d78:	5d                   	pop    %ebp
f0104d79:	c3                   	ret    

f0104d7a <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104d7a:	55                   	push   %ebp
f0104d7b:	89 e5                	mov    %esp,%ebp
f0104d7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104d80:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104d83:	ba 00 00 00 00       	mov    $0x0,%edx
f0104d88:	eb 03                	jmp    f0104d8d <strnlen+0x13>
		n++;
f0104d8a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104d8d:	39 c2                	cmp    %eax,%edx
f0104d8f:	74 08                	je     f0104d99 <strnlen+0x1f>
f0104d91:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0104d95:	75 f3                	jne    f0104d8a <strnlen+0x10>
f0104d97:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0104d99:	5d                   	pop    %ebp
f0104d9a:	c3                   	ret    

f0104d9b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104d9b:	55                   	push   %ebp
f0104d9c:	89 e5                	mov    %esp,%ebp
f0104d9e:	53                   	push   %ebx
f0104d9f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104da2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104da5:	89 c2                	mov    %eax,%edx
f0104da7:	83 c2 01             	add    $0x1,%edx
f0104daa:	83 c1 01             	add    $0x1,%ecx
f0104dad:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0104db1:	88 5a ff             	mov    %bl,-0x1(%edx)
f0104db4:	84 db                	test   %bl,%bl
f0104db6:	75 ef                	jne    f0104da7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104db8:	5b                   	pop    %ebx
f0104db9:	5d                   	pop    %ebp
f0104dba:	c3                   	ret    

f0104dbb <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104dbb:	55                   	push   %ebp
f0104dbc:	89 e5                	mov    %esp,%ebp
f0104dbe:	53                   	push   %ebx
f0104dbf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104dc2:	53                   	push   %ebx
f0104dc3:	e8 9a ff ff ff       	call   f0104d62 <strlen>
f0104dc8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0104dcb:	ff 75 0c             	pushl  0xc(%ebp)
f0104dce:	01 d8                	add    %ebx,%eax
f0104dd0:	50                   	push   %eax
f0104dd1:	e8 c5 ff ff ff       	call   f0104d9b <strcpy>
	return dst;
}
f0104dd6:	89 d8                	mov    %ebx,%eax
f0104dd8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104ddb:	c9                   	leave  
f0104ddc:	c3                   	ret    

f0104ddd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104ddd:	55                   	push   %ebp
f0104dde:	89 e5                	mov    %esp,%ebp
f0104de0:	56                   	push   %esi
f0104de1:	53                   	push   %ebx
f0104de2:	8b 75 08             	mov    0x8(%ebp),%esi
f0104de5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104de8:	89 f3                	mov    %esi,%ebx
f0104dea:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104ded:	89 f2                	mov    %esi,%edx
f0104def:	eb 0f                	jmp    f0104e00 <strncpy+0x23>
		*dst++ = *src;
f0104df1:	83 c2 01             	add    $0x1,%edx
f0104df4:	0f b6 01             	movzbl (%ecx),%eax
f0104df7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104dfa:	80 39 01             	cmpb   $0x1,(%ecx)
f0104dfd:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104e00:	39 da                	cmp    %ebx,%edx
f0104e02:	75 ed                	jne    f0104df1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104e04:	89 f0                	mov    %esi,%eax
f0104e06:	5b                   	pop    %ebx
f0104e07:	5e                   	pop    %esi
f0104e08:	5d                   	pop    %ebp
f0104e09:	c3                   	ret    

f0104e0a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104e0a:	55                   	push   %ebp
f0104e0b:	89 e5                	mov    %esp,%ebp
f0104e0d:	56                   	push   %esi
f0104e0e:	53                   	push   %ebx
f0104e0f:	8b 75 08             	mov    0x8(%ebp),%esi
f0104e12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104e15:	8b 55 10             	mov    0x10(%ebp),%edx
f0104e18:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104e1a:	85 d2                	test   %edx,%edx
f0104e1c:	74 21                	je     f0104e3f <strlcpy+0x35>
f0104e1e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0104e22:	89 f2                	mov    %esi,%edx
f0104e24:	eb 09                	jmp    f0104e2f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104e26:	83 c2 01             	add    $0x1,%edx
f0104e29:	83 c1 01             	add    $0x1,%ecx
f0104e2c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104e2f:	39 c2                	cmp    %eax,%edx
f0104e31:	74 09                	je     f0104e3c <strlcpy+0x32>
f0104e33:	0f b6 19             	movzbl (%ecx),%ebx
f0104e36:	84 db                	test   %bl,%bl
f0104e38:	75 ec                	jne    f0104e26 <strlcpy+0x1c>
f0104e3a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0104e3c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104e3f:	29 f0                	sub    %esi,%eax
}
f0104e41:	5b                   	pop    %ebx
f0104e42:	5e                   	pop    %esi
f0104e43:	5d                   	pop    %ebp
f0104e44:	c3                   	ret    

f0104e45 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104e45:	55                   	push   %ebp
f0104e46:	89 e5                	mov    %esp,%ebp
f0104e48:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104e4b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104e4e:	eb 06                	jmp    f0104e56 <strcmp+0x11>
		p++, q++;
f0104e50:	83 c1 01             	add    $0x1,%ecx
f0104e53:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0104e56:	0f b6 01             	movzbl (%ecx),%eax
f0104e59:	84 c0                	test   %al,%al
f0104e5b:	74 04                	je     f0104e61 <strcmp+0x1c>
f0104e5d:	3a 02                	cmp    (%edx),%al
f0104e5f:	74 ef                	je     f0104e50 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104e61:	0f b6 c0             	movzbl %al,%eax
f0104e64:	0f b6 12             	movzbl (%edx),%edx
f0104e67:	29 d0                	sub    %edx,%eax
}
f0104e69:	5d                   	pop    %ebp
f0104e6a:	c3                   	ret    

f0104e6b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104e6b:	55                   	push   %ebp
f0104e6c:	89 e5                	mov    %esp,%ebp
f0104e6e:	53                   	push   %ebx
f0104e6f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e72:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104e75:	89 c3                	mov    %eax,%ebx
f0104e77:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104e7a:	eb 06                	jmp    f0104e82 <strncmp+0x17>
		n--, p++, q++;
f0104e7c:	83 c0 01             	add    $0x1,%eax
f0104e7f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104e82:	39 d8                	cmp    %ebx,%eax
f0104e84:	74 15                	je     f0104e9b <strncmp+0x30>
f0104e86:	0f b6 08             	movzbl (%eax),%ecx
f0104e89:	84 c9                	test   %cl,%cl
f0104e8b:	74 04                	je     f0104e91 <strncmp+0x26>
f0104e8d:	3a 0a                	cmp    (%edx),%cl
f0104e8f:	74 eb                	je     f0104e7c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104e91:	0f b6 00             	movzbl (%eax),%eax
f0104e94:	0f b6 12             	movzbl (%edx),%edx
f0104e97:	29 d0                	sub    %edx,%eax
f0104e99:	eb 05                	jmp    f0104ea0 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104e9b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104ea0:	5b                   	pop    %ebx
f0104ea1:	5d                   	pop    %ebp
f0104ea2:	c3                   	ret    

f0104ea3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104ea3:	55                   	push   %ebp
f0104ea4:	89 e5                	mov    %esp,%ebp
f0104ea6:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ea9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104ead:	eb 07                	jmp    f0104eb6 <strchr+0x13>
		if (*s == c)
f0104eaf:	38 ca                	cmp    %cl,%dl
f0104eb1:	74 0f                	je     f0104ec2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104eb3:	83 c0 01             	add    $0x1,%eax
f0104eb6:	0f b6 10             	movzbl (%eax),%edx
f0104eb9:	84 d2                	test   %dl,%dl
f0104ebb:	75 f2                	jne    f0104eaf <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0104ebd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104ec2:	5d                   	pop    %ebp
f0104ec3:	c3                   	ret    

f0104ec4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104ec4:	55                   	push   %ebp
f0104ec5:	89 e5                	mov    %esp,%ebp
f0104ec7:	8b 45 08             	mov    0x8(%ebp),%eax
f0104eca:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104ece:	eb 03                	jmp    f0104ed3 <strfind+0xf>
f0104ed0:	83 c0 01             	add    $0x1,%eax
f0104ed3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0104ed6:	38 ca                	cmp    %cl,%dl
f0104ed8:	74 04                	je     f0104ede <strfind+0x1a>
f0104eda:	84 d2                	test   %dl,%dl
f0104edc:	75 f2                	jne    f0104ed0 <strfind+0xc>
			break;
	return (char *) s;
}
f0104ede:	5d                   	pop    %ebp
f0104edf:	c3                   	ret    

f0104ee0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104ee0:	55                   	push   %ebp
f0104ee1:	89 e5                	mov    %esp,%ebp
f0104ee3:	57                   	push   %edi
f0104ee4:	56                   	push   %esi
f0104ee5:	53                   	push   %ebx
f0104ee6:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104ee9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104eec:	85 c9                	test   %ecx,%ecx
f0104eee:	74 36                	je     f0104f26 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104ef0:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104ef6:	75 28                	jne    f0104f20 <memset+0x40>
f0104ef8:	f6 c1 03             	test   $0x3,%cl
f0104efb:	75 23                	jne    f0104f20 <memset+0x40>
		c &= 0xFF;
f0104efd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104f01:	89 d3                	mov    %edx,%ebx
f0104f03:	c1 e3 08             	shl    $0x8,%ebx
f0104f06:	89 d6                	mov    %edx,%esi
f0104f08:	c1 e6 18             	shl    $0x18,%esi
f0104f0b:	89 d0                	mov    %edx,%eax
f0104f0d:	c1 e0 10             	shl    $0x10,%eax
f0104f10:	09 f0                	or     %esi,%eax
f0104f12:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0104f14:	89 d8                	mov    %ebx,%eax
f0104f16:	09 d0                	or     %edx,%eax
f0104f18:	c1 e9 02             	shr    $0x2,%ecx
f0104f1b:	fc                   	cld    
f0104f1c:	f3 ab                	rep stos %eax,%es:(%edi)
f0104f1e:	eb 06                	jmp    f0104f26 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104f20:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f23:	fc                   	cld    
f0104f24:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104f26:	89 f8                	mov    %edi,%eax
f0104f28:	5b                   	pop    %ebx
f0104f29:	5e                   	pop    %esi
f0104f2a:	5f                   	pop    %edi
f0104f2b:	5d                   	pop    %ebp
f0104f2c:	c3                   	ret    

f0104f2d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104f2d:	55                   	push   %ebp
f0104f2e:	89 e5                	mov    %esp,%ebp
f0104f30:	57                   	push   %edi
f0104f31:	56                   	push   %esi
f0104f32:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f35:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104f38:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104f3b:	39 c6                	cmp    %eax,%esi
f0104f3d:	73 35                	jae    f0104f74 <memmove+0x47>
f0104f3f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104f42:	39 d0                	cmp    %edx,%eax
f0104f44:	73 2e                	jae    f0104f74 <memmove+0x47>
		s += n;
		d += n;
f0104f46:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104f49:	89 d6                	mov    %edx,%esi
f0104f4b:	09 fe                	or     %edi,%esi
f0104f4d:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104f53:	75 13                	jne    f0104f68 <memmove+0x3b>
f0104f55:	f6 c1 03             	test   $0x3,%cl
f0104f58:	75 0e                	jne    f0104f68 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0104f5a:	83 ef 04             	sub    $0x4,%edi
f0104f5d:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104f60:	c1 e9 02             	shr    $0x2,%ecx
f0104f63:	fd                   	std    
f0104f64:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104f66:	eb 09                	jmp    f0104f71 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104f68:	83 ef 01             	sub    $0x1,%edi
f0104f6b:	8d 72 ff             	lea    -0x1(%edx),%esi
f0104f6e:	fd                   	std    
f0104f6f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104f71:	fc                   	cld    
f0104f72:	eb 1d                	jmp    f0104f91 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104f74:	89 f2                	mov    %esi,%edx
f0104f76:	09 c2                	or     %eax,%edx
f0104f78:	f6 c2 03             	test   $0x3,%dl
f0104f7b:	75 0f                	jne    f0104f8c <memmove+0x5f>
f0104f7d:	f6 c1 03             	test   $0x3,%cl
f0104f80:	75 0a                	jne    f0104f8c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0104f82:	c1 e9 02             	shr    $0x2,%ecx
f0104f85:	89 c7                	mov    %eax,%edi
f0104f87:	fc                   	cld    
f0104f88:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104f8a:	eb 05                	jmp    f0104f91 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104f8c:	89 c7                	mov    %eax,%edi
f0104f8e:	fc                   	cld    
f0104f8f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104f91:	5e                   	pop    %esi
f0104f92:	5f                   	pop    %edi
f0104f93:	5d                   	pop    %ebp
f0104f94:	c3                   	ret    

f0104f95 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104f95:	55                   	push   %ebp
f0104f96:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0104f98:	ff 75 10             	pushl  0x10(%ebp)
f0104f9b:	ff 75 0c             	pushl  0xc(%ebp)
f0104f9e:	ff 75 08             	pushl  0x8(%ebp)
f0104fa1:	e8 87 ff ff ff       	call   f0104f2d <memmove>
}
f0104fa6:	c9                   	leave  
f0104fa7:	c3                   	ret    

f0104fa8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104fa8:	55                   	push   %ebp
f0104fa9:	89 e5                	mov    %esp,%ebp
f0104fab:	56                   	push   %esi
f0104fac:	53                   	push   %ebx
f0104fad:	8b 45 08             	mov    0x8(%ebp),%eax
f0104fb0:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104fb3:	89 c6                	mov    %eax,%esi
f0104fb5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104fb8:	eb 1a                	jmp    f0104fd4 <memcmp+0x2c>
		if (*s1 != *s2)
f0104fba:	0f b6 08             	movzbl (%eax),%ecx
f0104fbd:	0f b6 1a             	movzbl (%edx),%ebx
f0104fc0:	38 d9                	cmp    %bl,%cl
f0104fc2:	74 0a                	je     f0104fce <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0104fc4:	0f b6 c1             	movzbl %cl,%eax
f0104fc7:	0f b6 db             	movzbl %bl,%ebx
f0104fca:	29 d8                	sub    %ebx,%eax
f0104fcc:	eb 0f                	jmp    f0104fdd <memcmp+0x35>
		s1++, s2++;
f0104fce:	83 c0 01             	add    $0x1,%eax
f0104fd1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104fd4:	39 f0                	cmp    %esi,%eax
f0104fd6:	75 e2                	jne    f0104fba <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104fd8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104fdd:	5b                   	pop    %ebx
f0104fde:	5e                   	pop    %esi
f0104fdf:	5d                   	pop    %ebp
f0104fe0:	c3                   	ret    

f0104fe1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104fe1:	55                   	push   %ebp
f0104fe2:	89 e5                	mov    %esp,%ebp
f0104fe4:	53                   	push   %ebx
f0104fe5:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0104fe8:	89 c1                	mov    %eax,%ecx
f0104fea:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0104fed:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104ff1:	eb 0a                	jmp    f0104ffd <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104ff3:	0f b6 10             	movzbl (%eax),%edx
f0104ff6:	39 da                	cmp    %ebx,%edx
f0104ff8:	74 07                	je     f0105001 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104ffa:	83 c0 01             	add    $0x1,%eax
f0104ffd:	39 c8                	cmp    %ecx,%eax
f0104fff:	72 f2                	jb     f0104ff3 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105001:	5b                   	pop    %ebx
f0105002:	5d                   	pop    %ebp
f0105003:	c3                   	ret    

f0105004 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105004:	55                   	push   %ebp
f0105005:	89 e5                	mov    %esp,%ebp
f0105007:	57                   	push   %edi
f0105008:	56                   	push   %esi
f0105009:	53                   	push   %ebx
f010500a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010500d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105010:	eb 03                	jmp    f0105015 <strtol+0x11>
		s++;
f0105012:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105015:	0f b6 01             	movzbl (%ecx),%eax
f0105018:	3c 20                	cmp    $0x20,%al
f010501a:	74 f6                	je     f0105012 <strtol+0xe>
f010501c:	3c 09                	cmp    $0x9,%al
f010501e:	74 f2                	je     f0105012 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105020:	3c 2b                	cmp    $0x2b,%al
f0105022:	75 0a                	jne    f010502e <strtol+0x2a>
		s++;
f0105024:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105027:	bf 00 00 00 00       	mov    $0x0,%edi
f010502c:	eb 11                	jmp    f010503f <strtol+0x3b>
f010502e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105033:	3c 2d                	cmp    $0x2d,%al
f0105035:	75 08                	jne    f010503f <strtol+0x3b>
		s++, neg = 1;
f0105037:	83 c1 01             	add    $0x1,%ecx
f010503a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010503f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105045:	75 15                	jne    f010505c <strtol+0x58>
f0105047:	80 39 30             	cmpb   $0x30,(%ecx)
f010504a:	75 10                	jne    f010505c <strtol+0x58>
f010504c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105050:	75 7c                	jne    f01050ce <strtol+0xca>
		s += 2, base = 16;
f0105052:	83 c1 02             	add    $0x2,%ecx
f0105055:	bb 10 00 00 00       	mov    $0x10,%ebx
f010505a:	eb 16                	jmp    f0105072 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f010505c:	85 db                	test   %ebx,%ebx
f010505e:	75 12                	jne    f0105072 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105060:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105065:	80 39 30             	cmpb   $0x30,(%ecx)
f0105068:	75 08                	jne    f0105072 <strtol+0x6e>
		s++, base = 8;
f010506a:	83 c1 01             	add    $0x1,%ecx
f010506d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105072:	b8 00 00 00 00       	mov    $0x0,%eax
f0105077:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010507a:	0f b6 11             	movzbl (%ecx),%edx
f010507d:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105080:	89 f3                	mov    %esi,%ebx
f0105082:	80 fb 09             	cmp    $0x9,%bl
f0105085:	77 08                	ja     f010508f <strtol+0x8b>
			dig = *s - '0';
f0105087:	0f be d2             	movsbl %dl,%edx
f010508a:	83 ea 30             	sub    $0x30,%edx
f010508d:	eb 22                	jmp    f01050b1 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f010508f:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105092:	89 f3                	mov    %esi,%ebx
f0105094:	80 fb 19             	cmp    $0x19,%bl
f0105097:	77 08                	ja     f01050a1 <strtol+0x9d>
			dig = *s - 'a' + 10;
f0105099:	0f be d2             	movsbl %dl,%edx
f010509c:	83 ea 57             	sub    $0x57,%edx
f010509f:	eb 10                	jmp    f01050b1 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01050a1:	8d 72 bf             	lea    -0x41(%edx),%esi
f01050a4:	89 f3                	mov    %esi,%ebx
f01050a6:	80 fb 19             	cmp    $0x19,%bl
f01050a9:	77 16                	ja     f01050c1 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01050ab:	0f be d2             	movsbl %dl,%edx
f01050ae:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01050b1:	3b 55 10             	cmp    0x10(%ebp),%edx
f01050b4:	7d 0b                	jge    f01050c1 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01050b6:	83 c1 01             	add    $0x1,%ecx
f01050b9:	0f af 45 10          	imul   0x10(%ebp),%eax
f01050bd:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01050bf:	eb b9                	jmp    f010507a <strtol+0x76>

	if (endptr)
f01050c1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01050c5:	74 0d                	je     f01050d4 <strtol+0xd0>
		*endptr = (char *) s;
f01050c7:	8b 75 0c             	mov    0xc(%ebp),%esi
f01050ca:	89 0e                	mov    %ecx,(%esi)
f01050cc:	eb 06                	jmp    f01050d4 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01050ce:	85 db                	test   %ebx,%ebx
f01050d0:	74 98                	je     f010506a <strtol+0x66>
f01050d2:	eb 9e                	jmp    f0105072 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01050d4:	89 c2                	mov    %eax,%edx
f01050d6:	f7 da                	neg    %edx
f01050d8:	85 ff                	test   %edi,%edi
f01050da:	0f 45 c2             	cmovne %edx,%eax
}
f01050dd:	5b                   	pop    %ebx
f01050de:	5e                   	pop    %esi
f01050df:	5f                   	pop    %edi
f01050e0:	5d                   	pop    %ebp
f01050e1:	c3                   	ret    
f01050e2:	66 90                	xchg   %ax,%ax

f01050e4 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01050e4:	fa                   	cli    

	xorw    %ax, %ax
f01050e5:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01050e7:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01050e9:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01050eb:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01050ed:	0f 01 16             	lgdtl  (%esi)
f01050f0:	74 70                	je     f0105162 <mpsearch1+0x3>
	movl    %cr0, %eax
f01050f2:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01050f5:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01050f9:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01050fc:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105102:	08 00                	or     %al,(%eax)

f0105104 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105104:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105108:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010510a:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010510c:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010510e:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105112:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105114:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105116:	b8 00 d0 11 00       	mov    $0x11d000,%eax
	movl    %eax, %cr3
f010511b:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010511e:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105121:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105126:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105129:	8b 25 24 9f 23 f0    	mov    0xf0239f24,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f010512f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105134:	b8 a7 01 10 f0       	mov    $0xf01001a7,%eax
	call    *%eax
f0105139:	ff d0                	call   *%eax

f010513b <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010513b:	eb fe                	jmp    f010513b <spin>
f010513d:	8d 76 00             	lea    0x0(%esi),%esi

f0105140 <gdt>:
	...
f0105148:	ff                   	(bad)  
f0105149:	ff 00                	incl   (%eax)
f010514b:	00 00                	add    %al,(%eax)
f010514d:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105154:	00                   	.byte 0x0
f0105155:	92                   	xchg   %eax,%edx
f0105156:	cf                   	iret   
	...

f0105158 <gdtdesc>:
f0105158:	17                   	pop    %ss
f0105159:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f010515e <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f010515e:	90                   	nop

f010515f <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f010515f:	55                   	push   %ebp
f0105160:	89 e5                	mov    %esp,%ebp
f0105162:	57                   	push   %edi
f0105163:	56                   	push   %esi
f0105164:	53                   	push   %ebx
f0105165:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105168:	8b 0d 28 9f 23 f0    	mov    0xf0239f28,%ecx
f010516e:	89 c3                	mov    %eax,%ebx
f0105170:	c1 eb 0c             	shr    $0xc,%ebx
f0105173:	39 cb                	cmp    %ecx,%ebx
f0105175:	72 12                	jb     f0105189 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105177:	50                   	push   %eax
f0105178:	68 c4 5b 10 f0       	push   $0xf0105bc4
f010517d:	6a 57                	push   $0x57
f010517f:	68 25 74 10 f0       	push   $0xf0107425
f0105184:	e8 b7 ae ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105189:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010518f:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105191:	89 c2                	mov    %eax,%edx
f0105193:	c1 ea 0c             	shr    $0xc,%edx
f0105196:	39 ca                	cmp    %ecx,%edx
f0105198:	72 12                	jb     f01051ac <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010519a:	50                   	push   %eax
f010519b:	68 c4 5b 10 f0       	push   $0xf0105bc4
f01051a0:	6a 57                	push   $0x57
f01051a2:	68 25 74 10 f0       	push   $0xf0107425
f01051a7:	e8 94 ae ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01051ac:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f01051b2:	eb 2f                	jmp    f01051e3 <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01051b4:	83 ec 04             	sub    $0x4,%esp
f01051b7:	6a 04                	push   $0x4
f01051b9:	68 35 74 10 f0       	push   $0xf0107435
f01051be:	53                   	push   %ebx
f01051bf:	e8 e4 fd ff ff       	call   f0104fa8 <memcmp>
f01051c4:	83 c4 10             	add    $0x10,%esp
f01051c7:	85 c0                	test   %eax,%eax
f01051c9:	75 15                	jne    f01051e0 <mpsearch1+0x81>
f01051cb:	89 da                	mov    %ebx,%edx
f01051cd:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f01051d0:	0f b6 0a             	movzbl (%edx),%ecx
f01051d3:	01 c8                	add    %ecx,%eax
f01051d5:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01051d8:	39 d7                	cmp    %edx,%edi
f01051da:	75 f4                	jne    f01051d0 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01051dc:	84 c0                	test   %al,%al
f01051de:	74 0e                	je     f01051ee <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01051e0:	83 c3 10             	add    $0x10,%ebx
f01051e3:	39 f3                	cmp    %esi,%ebx
f01051e5:	72 cd                	jb     f01051b4 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01051e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01051ec:	eb 02                	jmp    f01051f0 <mpsearch1+0x91>
f01051ee:	89 d8                	mov    %ebx,%eax
}
f01051f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01051f3:	5b                   	pop    %ebx
f01051f4:	5e                   	pop    %esi
f01051f5:	5f                   	pop    %edi
f01051f6:	5d                   	pop    %ebp
f01051f7:	c3                   	ret    

f01051f8 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01051f8:	55                   	push   %ebp
f01051f9:	89 e5                	mov    %esp,%ebp
f01051fb:	57                   	push   %edi
f01051fc:	56                   	push   %esi
f01051fd:	53                   	push   %ebx
f01051fe:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105201:	c7 05 c0 a3 23 f0 20 	movl   $0xf023a020,0xf023a3c0
f0105208:	a0 23 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010520b:	83 3d 28 9f 23 f0 00 	cmpl   $0x0,0xf0239f28
f0105212:	75 16                	jne    f010522a <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105214:	68 00 04 00 00       	push   $0x400
f0105219:	68 c4 5b 10 f0       	push   $0xf0105bc4
f010521e:	6a 6f                	push   $0x6f
f0105220:	68 25 74 10 f0       	push   $0xf0107425
f0105225:	e8 16 ae ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010522a:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105231:	85 c0                	test   %eax,%eax
f0105233:	74 16                	je     f010524b <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105235:	c1 e0 04             	shl    $0x4,%eax
f0105238:	ba 00 04 00 00       	mov    $0x400,%edx
f010523d:	e8 1d ff ff ff       	call   f010515f <mpsearch1>
f0105242:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105245:	85 c0                	test   %eax,%eax
f0105247:	75 3c                	jne    f0105285 <mp_init+0x8d>
f0105249:	eb 20                	jmp    f010526b <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f010524b:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105252:	c1 e0 0a             	shl    $0xa,%eax
f0105255:	2d 00 04 00 00       	sub    $0x400,%eax
f010525a:	ba 00 04 00 00       	mov    $0x400,%edx
f010525f:	e8 fb fe ff ff       	call   f010515f <mpsearch1>
f0105264:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105267:	85 c0                	test   %eax,%eax
f0105269:	75 1a                	jne    f0105285 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f010526b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105270:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105275:	e8 e5 fe ff ff       	call   f010515f <mpsearch1>
f010527a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f010527d:	85 c0                	test   %eax,%eax
f010527f:	0f 84 5d 02 00 00    	je     f01054e2 <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105285:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105288:	8b 70 04             	mov    0x4(%eax),%esi
f010528b:	85 f6                	test   %esi,%esi
f010528d:	74 06                	je     f0105295 <mp_init+0x9d>
f010528f:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105293:	74 15                	je     f01052aa <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105295:	83 ec 0c             	sub    $0xc,%esp
f0105298:	68 98 72 10 f0       	push   $0xf0107298
f010529d:	e8 16 da ff ff       	call   f0102cb8 <cprintf>
f01052a2:	83 c4 10             	add    $0x10,%esp
f01052a5:	e9 38 02 00 00       	jmp    f01054e2 <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01052aa:	89 f0                	mov    %esi,%eax
f01052ac:	c1 e8 0c             	shr    $0xc,%eax
f01052af:	3b 05 28 9f 23 f0    	cmp    0xf0239f28,%eax
f01052b5:	72 15                	jb     f01052cc <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01052b7:	56                   	push   %esi
f01052b8:	68 c4 5b 10 f0       	push   $0xf0105bc4
f01052bd:	68 90 00 00 00       	push   $0x90
f01052c2:	68 25 74 10 f0       	push   $0xf0107425
f01052c7:	e8 74 ad ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01052cc:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f01052d2:	83 ec 04             	sub    $0x4,%esp
f01052d5:	6a 04                	push   $0x4
f01052d7:	68 3a 74 10 f0       	push   $0xf010743a
f01052dc:	53                   	push   %ebx
f01052dd:	e8 c6 fc ff ff       	call   f0104fa8 <memcmp>
f01052e2:	83 c4 10             	add    $0x10,%esp
f01052e5:	85 c0                	test   %eax,%eax
f01052e7:	74 15                	je     f01052fe <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01052e9:	83 ec 0c             	sub    $0xc,%esp
f01052ec:	68 c8 72 10 f0       	push   $0xf01072c8
f01052f1:	e8 c2 d9 ff ff       	call   f0102cb8 <cprintf>
f01052f6:	83 c4 10             	add    $0x10,%esp
f01052f9:	e9 e4 01 00 00       	jmp    f01054e2 <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01052fe:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105302:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105306:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105309:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f010530e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105313:	eb 0d                	jmp    f0105322 <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105315:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f010531c:	f0 
f010531d:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f010531f:	83 c0 01             	add    $0x1,%eax
f0105322:	39 c7                	cmp    %eax,%edi
f0105324:	75 ef                	jne    f0105315 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105326:	84 d2                	test   %dl,%dl
f0105328:	74 15                	je     f010533f <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f010532a:	83 ec 0c             	sub    $0xc,%esp
f010532d:	68 fc 72 10 f0       	push   $0xf01072fc
f0105332:	e8 81 d9 ff ff       	call   f0102cb8 <cprintf>
f0105337:	83 c4 10             	add    $0x10,%esp
f010533a:	e9 a3 01 00 00       	jmp    f01054e2 <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f010533f:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105343:	3c 01                	cmp    $0x1,%al
f0105345:	74 1d                	je     f0105364 <mp_init+0x16c>
f0105347:	3c 04                	cmp    $0x4,%al
f0105349:	74 19                	je     f0105364 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f010534b:	83 ec 08             	sub    $0x8,%esp
f010534e:	0f b6 c0             	movzbl %al,%eax
f0105351:	50                   	push   %eax
f0105352:	68 20 73 10 f0       	push   $0xf0107320
f0105357:	e8 5c d9 ff ff       	call   f0102cb8 <cprintf>
f010535c:	83 c4 10             	add    $0x10,%esp
f010535f:	e9 7e 01 00 00       	jmp    f01054e2 <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105364:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105368:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f010536c:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105371:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105376:	01 ce                	add    %ecx,%esi
f0105378:	eb 0d                	jmp    f0105387 <mp_init+0x18f>
f010537a:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105381:	f0 
f0105382:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105384:	83 c0 01             	add    $0x1,%eax
f0105387:	39 c7                	cmp    %eax,%edi
f0105389:	75 ef                	jne    f010537a <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010538b:	89 d0                	mov    %edx,%eax
f010538d:	02 43 2a             	add    0x2a(%ebx),%al
f0105390:	74 15                	je     f01053a7 <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105392:	83 ec 0c             	sub    $0xc,%esp
f0105395:	68 40 73 10 f0       	push   $0xf0107340
f010539a:	e8 19 d9 ff ff       	call   f0102cb8 <cprintf>
f010539f:	83 c4 10             	add    $0x10,%esp
f01053a2:	e9 3b 01 00 00       	jmp    f01054e2 <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01053a7:	85 db                	test   %ebx,%ebx
f01053a9:	0f 84 33 01 00 00    	je     f01054e2 <mp_init+0x2ea>
		return;
	ismp = 1;
f01053af:	c7 05 00 a0 23 f0 01 	movl   $0x1,0xf023a000
f01053b6:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01053b9:	8b 43 24             	mov    0x24(%ebx),%eax
f01053bc:	a3 00 b0 27 f0       	mov    %eax,0xf027b000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01053c1:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f01053c4:	be 00 00 00 00       	mov    $0x0,%esi
f01053c9:	e9 85 00 00 00       	jmp    f0105453 <mp_init+0x25b>
		switch (*p) {
f01053ce:	0f b6 07             	movzbl (%edi),%eax
f01053d1:	84 c0                	test   %al,%al
f01053d3:	74 06                	je     f01053db <mp_init+0x1e3>
f01053d5:	3c 04                	cmp    $0x4,%al
f01053d7:	77 55                	ja     f010542e <mp_init+0x236>
f01053d9:	eb 4e                	jmp    f0105429 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01053db:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f01053df:	74 11                	je     f01053f2 <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f01053e1:	6b 05 c4 a3 23 f0 74 	imul   $0x74,0xf023a3c4,%eax
f01053e8:	05 20 a0 23 f0       	add    $0xf023a020,%eax
f01053ed:	a3 c0 a3 23 f0       	mov    %eax,0xf023a3c0
			if (ncpu < NCPU) {
f01053f2:	a1 c4 a3 23 f0       	mov    0xf023a3c4,%eax
f01053f7:	83 f8 07             	cmp    $0x7,%eax
f01053fa:	7f 13                	jg     f010540f <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f01053fc:	6b d0 74             	imul   $0x74,%eax,%edx
f01053ff:	88 82 20 a0 23 f0    	mov    %al,-0xfdc5fe0(%edx)
				ncpu++;
f0105405:	83 c0 01             	add    $0x1,%eax
f0105408:	a3 c4 a3 23 f0       	mov    %eax,0xf023a3c4
f010540d:	eb 15                	jmp    f0105424 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010540f:	83 ec 08             	sub    $0x8,%esp
f0105412:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105416:	50                   	push   %eax
f0105417:	68 70 73 10 f0       	push   $0xf0107370
f010541c:	e8 97 d8 ff ff       	call   f0102cb8 <cprintf>
f0105421:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105424:	83 c7 14             	add    $0x14,%edi
			continue;
f0105427:	eb 27                	jmp    f0105450 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105429:	83 c7 08             	add    $0x8,%edi
			continue;
f010542c:	eb 22                	jmp    f0105450 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010542e:	83 ec 08             	sub    $0x8,%esp
f0105431:	0f b6 c0             	movzbl %al,%eax
f0105434:	50                   	push   %eax
f0105435:	68 98 73 10 f0       	push   $0xf0107398
f010543a:	e8 79 d8 ff ff       	call   f0102cb8 <cprintf>
			ismp = 0;
f010543f:	c7 05 00 a0 23 f0 00 	movl   $0x0,0xf023a000
f0105446:	00 00 00 
			i = conf->entry;
f0105449:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f010544d:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105450:	83 c6 01             	add    $0x1,%esi
f0105453:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105457:	39 c6                	cmp    %eax,%esi
f0105459:	0f 82 6f ff ff ff    	jb     f01053ce <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010545f:	a1 c0 a3 23 f0       	mov    0xf023a3c0,%eax
f0105464:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010546b:	83 3d 00 a0 23 f0 00 	cmpl   $0x0,0xf023a000
f0105472:	75 26                	jne    f010549a <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105474:	c7 05 c4 a3 23 f0 01 	movl   $0x1,0xf023a3c4
f010547b:	00 00 00 
		lapicaddr = 0;
f010547e:	c7 05 00 b0 27 f0 00 	movl   $0x0,0xf027b000
f0105485:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105488:	83 ec 0c             	sub    $0xc,%esp
f010548b:	68 b8 73 10 f0       	push   $0xf01073b8
f0105490:	e8 23 d8 ff ff       	call   f0102cb8 <cprintf>
		return;
f0105495:	83 c4 10             	add    $0x10,%esp
f0105498:	eb 48                	jmp    f01054e2 <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010549a:	83 ec 04             	sub    $0x4,%esp
f010549d:	ff 35 c4 a3 23 f0    	pushl  0xf023a3c4
f01054a3:	0f b6 00             	movzbl (%eax),%eax
f01054a6:	50                   	push   %eax
f01054a7:	68 3f 74 10 f0       	push   $0xf010743f
f01054ac:	e8 07 d8 ff ff       	call   f0102cb8 <cprintf>

	if (mp->imcrp) {
f01054b1:	83 c4 10             	add    $0x10,%esp
f01054b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01054b7:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01054bb:	74 25                	je     f01054e2 <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01054bd:	83 ec 0c             	sub    $0xc,%esp
f01054c0:	68 e4 73 10 f0       	push   $0xf01073e4
f01054c5:	e8 ee d7 ff ff       	call   f0102cb8 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01054ca:	ba 22 00 00 00       	mov    $0x22,%edx
f01054cf:	b8 70 00 00 00       	mov    $0x70,%eax
f01054d4:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01054d5:	ba 23 00 00 00       	mov    $0x23,%edx
f01054da:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01054db:	83 c8 01             	or     $0x1,%eax
f01054de:	ee                   	out    %al,(%dx)
f01054df:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f01054e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01054e5:	5b                   	pop    %ebx
f01054e6:	5e                   	pop    %esi
f01054e7:	5f                   	pop    %edi
f01054e8:	5d                   	pop    %ebp
f01054e9:	c3                   	ret    

f01054ea <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f01054ea:	55                   	push   %ebp
f01054eb:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01054ed:	8b 0d 04 b0 27 f0    	mov    0xf027b004,%ecx
f01054f3:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01054f6:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01054f8:	a1 04 b0 27 f0       	mov    0xf027b004,%eax
f01054fd:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105500:	5d                   	pop    %ebp
f0105501:	c3                   	ret    

f0105502 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105502:	55                   	push   %ebp
f0105503:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105505:	a1 04 b0 27 f0       	mov    0xf027b004,%eax
f010550a:	85 c0                	test   %eax,%eax
f010550c:	74 08                	je     f0105516 <cpunum+0x14>
		return lapic[ID] >> 24;
f010550e:	8b 40 20             	mov    0x20(%eax),%eax
f0105511:	c1 e8 18             	shr    $0x18,%eax
f0105514:	eb 05                	jmp    f010551b <cpunum+0x19>
	return 0;
f0105516:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010551b:	5d                   	pop    %ebp
f010551c:	c3                   	ret    

f010551d <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f010551d:	a1 00 b0 27 f0       	mov    0xf027b000,%eax
f0105522:	85 c0                	test   %eax,%eax
f0105524:	0f 84 21 01 00 00    	je     f010564b <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f010552a:	55                   	push   %ebp
f010552b:	89 e5                	mov    %esp,%ebp
f010552d:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105530:	68 00 10 00 00       	push   $0x1000
f0105535:	50                   	push   %eax
f0105536:	e8 86 ba ff ff       	call   f0100fc1 <mmio_map_region>
f010553b:	a3 04 b0 27 f0       	mov    %eax,0xf027b004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105540:	ba 27 01 00 00       	mov    $0x127,%edx
f0105545:	b8 3c 00 00 00       	mov    $0x3c,%eax
f010554a:	e8 9b ff ff ff       	call   f01054ea <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f010554f:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105554:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105559:	e8 8c ff ff ff       	call   f01054ea <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f010555e:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105563:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105568:	e8 7d ff ff ff       	call   f01054ea <lapicw>
	lapicw(TICR, 10000000); 
f010556d:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105572:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105577:	e8 6e ff ff ff       	call   f01054ea <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f010557c:	e8 81 ff ff ff       	call   f0105502 <cpunum>
f0105581:	6b c0 74             	imul   $0x74,%eax,%eax
f0105584:	05 20 a0 23 f0       	add    $0xf023a020,%eax
f0105589:	83 c4 10             	add    $0x10,%esp
f010558c:	39 05 c0 a3 23 f0    	cmp    %eax,0xf023a3c0
f0105592:	74 0f                	je     f01055a3 <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105594:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105599:	b8 d4 00 00 00       	mov    $0xd4,%eax
f010559e:	e8 47 ff ff ff       	call   f01054ea <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01055a3:	ba 00 00 01 00       	mov    $0x10000,%edx
f01055a8:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01055ad:	e8 38 ff ff ff       	call   f01054ea <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01055b2:	a1 04 b0 27 f0       	mov    0xf027b004,%eax
f01055b7:	8b 40 30             	mov    0x30(%eax),%eax
f01055ba:	c1 e8 10             	shr    $0x10,%eax
f01055bd:	3c 03                	cmp    $0x3,%al
f01055bf:	76 0f                	jbe    f01055d0 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f01055c1:	ba 00 00 01 00       	mov    $0x10000,%edx
f01055c6:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01055cb:	e8 1a ff ff ff       	call   f01054ea <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01055d0:	ba 33 00 00 00       	mov    $0x33,%edx
f01055d5:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01055da:	e8 0b ff ff ff       	call   f01054ea <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f01055df:	ba 00 00 00 00       	mov    $0x0,%edx
f01055e4:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01055e9:	e8 fc fe ff ff       	call   f01054ea <lapicw>
	lapicw(ESR, 0);
f01055ee:	ba 00 00 00 00       	mov    $0x0,%edx
f01055f3:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01055f8:	e8 ed fe ff ff       	call   f01054ea <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01055fd:	ba 00 00 00 00       	mov    $0x0,%edx
f0105602:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105607:	e8 de fe ff ff       	call   f01054ea <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f010560c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105611:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105616:	e8 cf fe ff ff       	call   f01054ea <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010561b:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105620:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105625:	e8 c0 fe ff ff       	call   f01054ea <lapicw>
	while(lapic[ICRLO] & DELIVS)
f010562a:	8b 15 04 b0 27 f0    	mov    0xf027b004,%edx
f0105630:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105636:	f6 c4 10             	test   $0x10,%ah
f0105639:	75 f5                	jne    f0105630 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f010563b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105640:	b8 20 00 00 00       	mov    $0x20,%eax
f0105645:	e8 a0 fe ff ff       	call   f01054ea <lapicw>
}
f010564a:	c9                   	leave  
f010564b:	f3 c3                	repz ret 

f010564d <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f010564d:	83 3d 04 b0 27 f0 00 	cmpl   $0x0,0xf027b004
f0105654:	74 13                	je     f0105669 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105656:	55                   	push   %ebp
f0105657:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105659:	ba 00 00 00 00       	mov    $0x0,%edx
f010565e:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105663:	e8 82 fe ff ff       	call   f01054ea <lapicw>
}
f0105668:	5d                   	pop    %ebp
f0105669:	f3 c3                	repz ret 

f010566b <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f010566b:	55                   	push   %ebp
f010566c:	89 e5                	mov    %esp,%ebp
f010566e:	56                   	push   %esi
f010566f:	53                   	push   %ebx
f0105670:	8b 75 08             	mov    0x8(%ebp),%esi
f0105673:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105676:	ba 70 00 00 00       	mov    $0x70,%edx
f010567b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105680:	ee                   	out    %al,(%dx)
f0105681:	ba 71 00 00 00       	mov    $0x71,%edx
f0105686:	b8 0a 00 00 00       	mov    $0xa,%eax
f010568b:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010568c:	83 3d 28 9f 23 f0 00 	cmpl   $0x0,0xf0239f28
f0105693:	75 19                	jne    f01056ae <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105695:	68 67 04 00 00       	push   $0x467
f010569a:	68 c4 5b 10 f0       	push   $0xf0105bc4
f010569f:	68 99 00 00 00       	push   $0x99
f01056a4:	68 5c 74 10 f0       	push   $0xf010745c
f01056a9:	e8 92 a9 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01056ae:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01056b5:	00 00 
	wrv[1] = addr >> 4;
f01056b7:	89 d8                	mov    %ebx,%eax
f01056b9:	c1 e8 04             	shr    $0x4,%eax
f01056bc:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01056c2:	c1 e6 18             	shl    $0x18,%esi
f01056c5:	89 f2                	mov    %esi,%edx
f01056c7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01056cc:	e8 19 fe ff ff       	call   f01054ea <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01056d1:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01056d6:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01056db:	e8 0a fe ff ff       	call   f01054ea <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01056e0:	ba 00 85 00 00       	mov    $0x8500,%edx
f01056e5:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01056ea:	e8 fb fd ff ff       	call   f01054ea <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01056ef:	c1 eb 0c             	shr    $0xc,%ebx
f01056f2:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01056f5:	89 f2                	mov    %esi,%edx
f01056f7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01056fc:	e8 e9 fd ff ff       	call   f01054ea <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105701:	89 da                	mov    %ebx,%edx
f0105703:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105708:	e8 dd fd ff ff       	call   f01054ea <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010570d:	89 f2                	mov    %esi,%edx
f010570f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105714:	e8 d1 fd ff ff       	call   f01054ea <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105719:	89 da                	mov    %ebx,%edx
f010571b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105720:	e8 c5 fd ff ff       	call   f01054ea <lapicw>
		microdelay(200);
	}
}
f0105725:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105728:	5b                   	pop    %ebx
f0105729:	5e                   	pop    %esi
f010572a:	5d                   	pop    %ebp
f010572b:	c3                   	ret    

f010572c <lapic_ipi>:

void
lapic_ipi(int vector)
{
f010572c:	55                   	push   %ebp
f010572d:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f010572f:	8b 55 08             	mov    0x8(%ebp),%edx
f0105732:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105738:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010573d:	e8 a8 fd ff ff       	call   f01054ea <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105742:	8b 15 04 b0 27 f0    	mov    0xf027b004,%edx
f0105748:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010574e:	f6 c4 10             	test   $0x10,%ah
f0105751:	75 f5                	jne    f0105748 <lapic_ipi+0x1c>
		;
}
f0105753:	5d                   	pop    %ebp
f0105754:	c3                   	ret    

f0105755 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105755:	55                   	push   %ebp
f0105756:	89 e5                	mov    %esp,%ebp
f0105758:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f010575b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105761:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105764:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105767:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f010576e:	5d                   	pop    %ebp
f010576f:	c3                   	ret    

f0105770 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105770:	55                   	push   %ebp
f0105771:	89 e5                	mov    %esp,%ebp
f0105773:	56                   	push   %esi
f0105774:	53                   	push   %ebx
f0105775:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105778:	83 3b 00             	cmpl   $0x0,(%ebx)
f010577b:	74 14                	je     f0105791 <spin_lock+0x21>
f010577d:	8b 73 08             	mov    0x8(%ebx),%esi
f0105780:	e8 7d fd ff ff       	call   f0105502 <cpunum>
f0105785:	6b c0 74             	imul   $0x74,%eax,%eax
f0105788:	05 20 a0 23 f0       	add    $0xf023a020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f010578d:	39 c6                	cmp    %eax,%esi
f010578f:	74 07                	je     f0105798 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105791:	ba 01 00 00 00       	mov    $0x1,%edx
f0105796:	eb 20                	jmp    f01057b8 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105798:	8b 5b 04             	mov    0x4(%ebx),%ebx
f010579b:	e8 62 fd ff ff       	call   f0105502 <cpunum>
f01057a0:	83 ec 0c             	sub    $0xc,%esp
f01057a3:	53                   	push   %ebx
f01057a4:	50                   	push   %eax
f01057a5:	68 6c 74 10 f0       	push   $0xf010746c
f01057aa:	6a 41                	push   $0x41
f01057ac:	68 d0 74 10 f0       	push   $0xf01074d0
f01057b1:	e8 8a a8 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01057b6:	f3 90                	pause  
f01057b8:	89 d0                	mov    %edx,%eax
f01057ba:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f01057bd:	85 c0                	test   %eax,%eax
f01057bf:	75 f5                	jne    f01057b6 <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01057c1:	e8 3c fd ff ff       	call   f0105502 <cpunum>
f01057c6:	6b c0 74             	imul   $0x74,%eax,%eax
f01057c9:	05 20 a0 23 f0       	add    $0xf023a020,%eax
f01057ce:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f01057d1:	83 c3 0c             	add    $0xc,%ebx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01057d4:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01057d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01057db:	eb 0b                	jmp    f01057e8 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f01057dd:	8b 4a 04             	mov    0x4(%edx),%ecx
f01057e0:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01057e3:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01057e5:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01057e8:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01057ee:	76 11                	jbe    f0105801 <spin_lock+0x91>
f01057f0:	83 f8 09             	cmp    $0x9,%eax
f01057f3:	7e e8                	jle    f01057dd <spin_lock+0x6d>
f01057f5:	eb 0a                	jmp    f0105801 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f01057f7:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01057fe:	83 c0 01             	add    $0x1,%eax
f0105801:	83 f8 09             	cmp    $0x9,%eax
f0105804:	7e f1                	jle    f01057f7 <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105806:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105809:	5b                   	pop    %ebx
f010580a:	5e                   	pop    %esi
f010580b:	5d                   	pop    %ebp
f010580c:	c3                   	ret    

f010580d <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f010580d:	55                   	push   %ebp
f010580e:	89 e5                	mov    %esp,%ebp
f0105810:	57                   	push   %edi
f0105811:	56                   	push   %esi
f0105812:	53                   	push   %ebx
f0105813:	83 ec 4c             	sub    $0x4c,%esp
f0105816:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105819:	83 3e 00             	cmpl   $0x0,(%esi)
f010581c:	74 18                	je     f0105836 <spin_unlock+0x29>
f010581e:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105821:	e8 dc fc ff ff       	call   f0105502 <cpunum>
f0105826:	6b c0 74             	imul   $0x74,%eax,%eax
f0105829:	05 20 a0 23 f0       	add    $0xf023a020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f010582e:	39 c3                	cmp    %eax,%ebx
f0105830:	0f 84 a5 00 00 00    	je     f01058db <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105836:	83 ec 04             	sub    $0x4,%esp
f0105839:	6a 28                	push   $0x28
f010583b:	8d 46 0c             	lea    0xc(%esi),%eax
f010583e:	50                   	push   %eax
f010583f:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105842:	53                   	push   %ebx
f0105843:	e8 e5 f6 ff ff       	call   f0104f2d <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105848:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f010584b:	0f b6 38             	movzbl (%eax),%edi
f010584e:	8b 76 04             	mov    0x4(%esi),%esi
f0105851:	e8 ac fc ff ff       	call   f0105502 <cpunum>
f0105856:	57                   	push   %edi
f0105857:	56                   	push   %esi
f0105858:	50                   	push   %eax
f0105859:	68 98 74 10 f0       	push   $0xf0107498
f010585e:	e8 55 d4 ff ff       	call   f0102cb8 <cprintf>
f0105863:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105866:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105869:	eb 54                	jmp    f01058bf <spin_unlock+0xb2>
f010586b:	83 ec 08             	sub    $0x8,%esp
f010586e:	57                   	push   %edi
f010586f:	50                   	push   %eax
f0105870:	e8 84 ec ff ff       	call   f01044f9 <debuginfo_eip>
f0105875:	83 c4 10             	add    $0x10,%esp
f0105878:	85 c0                	test   %eax,%eax
f010587a:	78 27                	js     f01058a3 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f010587c:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f010587e:	83 ec 04             	sub    $0x4,%esp
f0105881:	89 c2                	mov    %eax,%edx
f0105883:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105886:	52                   	push   %edx
f0105887:	ff 75 b0             	pushl  -0x50(%ebp)
f010588a:	ff 75 b4             	pushl  -0x4c(%ebp)
f010588d:	ff 75 ac             	pushl  -0x54(%ebp)
f0105890:	ff 75 a8             	pushl  -0x58(%ebp)
f0105893:	50                   	push   %eax
f0105894:	68 e0 74 10 f0       	push   $0xf01074e0
f0105899:	e8 1a d4 ff ff       	call   f0102cb8 <cprintf>
f010589e:	83 c4 20             	add    $0x20,%esp
f01058a1:	eb 12                	jmp    f01058b5 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f01058a3:	83 ec 08             	sub    $0x8,%esp
f01058a6:	ff 36                	pushl  (%esi)
f01058a8:	68 f7 74 10 f0       	push   $0xf01074f7
f01058ad:	e8 06 d4 ff ff       	call   f0102cb8 <cprintf>
f01058b2:	83 c4 10             	add    $0x10,%esp
f01058b5:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01058b8:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01058bb:	39 c3                	cmp    %eax,%ebx
f01058bd:	74 08                	je     f01058c7 <spin_unlock+0xba>
f01058bf:	89 de                	mov    %ebx,%esi
f01058c1:	8b 03                	mov    (%ebx),%eax
f01058c3:	85 c0                	test   %eax,%eax
f01058c5:	75 a4                	jne    f010586b <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01058c7:	83 ec 04             	sub    $0x4,%esp
f01058ca:	68 ff 74 10 f0       	push   $0xf01074ff
f01058cf:	6a 67                	push   $0x67
f01058d1:	68 d0 74 10 f0       	push   $0xf01074d0
f01058d6:	e8 65 a7 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f01058db:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01058e2:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01058e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01058ee:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f01058f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01058f4:	5b                   	pop    %ebx
f01058f5:	5e                   	pop    %esi
f01058f6:	5f                   	pop    %edi
f01058f7:	5d                   	pop    %ebp
f01058f8:	c3                   	ret    
f01058f9:	66 90                	xchg   %ax,%ax
f01058fb:	66 90                	xchg   %ax,%ax
f01058fd:	66 90                	xchg   %ax,%ax
f01058ff:	90                   	nop

f0105900 <__udivdi3>:
f0105900:	55                   	push   %ebp
f0105901:	57                   	push   %edi
f0105902:	56                   	push   %esi
f0105903:	53                   	push   %ebx
f0105904:	83 ec 1c             	sub    $0x1c,%esp
f0105907:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010590b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010590f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0105913:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105917:	85 f6                	test   %esi,%esi
f0105919:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010591d:	89 ca                	mov    %ecx,%edx
f010591f:	89 f8                	mov    %edi,%eax
f0105921:	75 3d                	jne    f0105960 <__udivdi3+0x60>
f0105923:	39 cf                	cmp    %ecx,%edi
f0105925:	0f 87 c5 00 00 00    	ja     f01059f0 <__udivdi3+0xf0>
f010592b:	85 ff                	test   %edi,%edi
f010592d:	89 fd                	mov    %edi,%ebp
f010592f:	75 0b                	jne    f010593c <__udivdi3+0x3c>
f0105931:	b8 01 00 00 00       	mov    $0x1,%eax
f0105936:	31 d2                	xor    %edx,%edx
f0105938:	f7 f7                	div    %edi
f010593a:	89 c5                	mov    %eax,%ebp
f010593c:	89 c8                	mov    %ecx,%eax
f010593e:	31 d2                	xor    %edx,%edx
f0105940:	f7 f5                	div    %ebp
f0105942:	89 c1                	mov    %eax,%ecx
f0105944:	89 d8                	mov    %ebx,%eax
f0105946:	89 cf                	mov    %ecx,%edi
f0105948:	f7 f5                	div    %ebp
f010594a:	89 c3                	mov    %eax,%ebx
f010594c:	89 d8                	mov    %ebx,%eax
f010594e:	89 fa                	mov    %edi,%edx
f0105950:	83 c4 1c             	add    $0x1c,%esp
f0105953:	5b                   	pop    %ebx
f0105954:	5e                   	pop    %esi
f0105955:	5f                   	pop    %edi
f0105956:	5d                   	pop    %ebp
f0105957:	c3                   	ret    
f0105958:	90                   	nop
f0105959:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105960:	39 ce                	cmp    %ecx,%esi
f0105962:	77 74                	ja     f01059d8 <__udivdi3+0xd8>
f0105964:	0f bd fe             	bsr    %esi,%edi
f0105967:	83 f7 1f             	xor    $0x1f,%edi
f010596a:	0f 84 98 00 00 00    	je     f0105a08 <__udivdi3+0x108>
f0105970:	bb 20 00 00 00       	mov    $0x20,%ebx
f0105975:	89 f9                	mov    %edi,%ecx
f0105977:	89 c5                	mov    %eax,%ebp
f0105979:	29 fb                	sub    %edi,%ebx
f010597b:	d3 e6                	shl    %cl,%esi
f010597d:	89 d9                	mov    %ebx,%ecx
f010597f:	d3 ed                	shr    %cl,%ebp
f0105981:	89 f9                	mov    %edi,%ecx
f0105983:	d3 e0                	shl    %cl,%eax
f0105985:	09 ee                	or     %ebp,%esi
f0105987:	89 d9                	mov    %ebx,%ecx
f0105989:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010598d:	89 d5                	mov    %edx,%ebp
f010598f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105993:	d3 ed                	shr    %cl,%ebp
f0105995:	89 f9                	mov    %edi,%ecx
f0105997:	d3 e2                	shl    %cl,%edx
f0105999:	89 d9                	mov    %ebx,%ecx
f010599b:	d3 e8                	shr    %cl,%eax
f010599d:	09 c2                	or     %eax,%edx
f010599f:	89 d0                	mov    %edx,%eax
f01059a1:	89 ea                	mov    %ebp,%edx
f01059a3:	f7 f6                	div    %esi
f01059a5:	89 d5                	mov    %edx,%ebp
f01059a7:	89 c3                	mov    %eax,%ebx
f01059a9:	f7 64 24 0c          	mull   0xc(%esp)
f01059ad:	39 d5                	cmp    %edx,%ebp
f01059af:	72 10                	jb     f01059c1 <__udivdi3+0xc1>
f01059b1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01059b5:	89 f9                	mov    %edi,%ecx
f01059b7:	d3 e6                	shl    %cl,%esi
f01059b9:	39 c6                	cmp    %eax,%esi
f01059bb:	73 07                	jae    f01059c4 <__udivdi3+0xc4>
f01059bd:	39 d5                	cmp    %edx,%ebp
f01059bf:	75 03                	jne    f01059c4 <__udivdi3+0xc4>
f01059c1:	83 eb 01             	sub    $0x1,%ebx
f01059c4:	31 ff                	xor    %edi,%edi
f01059c6:	89 d8                	mov    %ebx,%eax
f01059c8:	89 fa                	mov    %edi,%edx
f01059ca:	83 c4 1c             	add    $0x1c,%esp
f01059cd:	5b                   	pop    %ebx
f01059ce:	5e                   	pop    %esi
f01059cf:	5f                   	pop    %edi
f01059d0:	5d                   	pop    %ebp
f01059d1:	c3                   	ret    
f01059d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01059d8:	31 ff                	xor    %edi,%edi
f01059da:	31 db                	xor    %ebx,%ebx
f01059dc:	89 d8                	mov    %ebx,%eax
f01059de:	89 fa                	mov    %edi,%edx
f01059e0:	83 c4 1c             	add    $0x1c,%esp
f01059e3:	5b                   	pop    %ebx
f01059e4:	5e                   	pop    %esi
f01059e5:	5f                   	pop    %edi
f01059e6:	5d                   	pop    %ebp
f01059e7:	c3                   	ret    
f01059e8:	90                   	nop
f01059e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01059f0:	89 d8                	mov    %ebx,%eax
f01059f2:	f7 f7                	div    %edi
f01059f4:	31 ff                	xor    %edi,%edi
f01059f6:	89 c3                	mov    %eax,%ebx
f01059f8:	89 d8                	mov    %ebx,%eax
f01059fa:	89 fa                	mov    %edi,%edx
f01059fc:	83 c4 1c             	add    $0x1c,%esp
f01059ff:	5b                   	pop    %ebx
f0105a00:	5e                   	pop    %esi
f0105a01:	5f                   	pop    %edi
f0105a02:	5d                   	pop    %ebp
f0105a03:	c3                   	ret    
f0105a04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105a08:	39 ce                	cmp    %ecx,%esi
f0105a0a:	72 0c                	jb     f0105a18 <__udivdi3+0x118>
f0105a0c:	31 db                	xor    %ebx,%ebx
f0105a0e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0105a12:	0f 87 34 ff ff ff    	ja     f010594c <__udivdi3+0x4c>
f0105a18:	bb 01 00 00 00       	mov    $0x1,%ebx
f0105a1d:	e9 2a ff ff ff       	jmp    f010594c <__udivdi3+0x4c>
f0105a22:	66 90                	xchg   %ax,%ax
f0105a24:	66 90                	xchg   %ax,%ax
f0105a26:	66 90                	xchg   %ax,%ax
f0105a28:	66 90                	xchg   %ax,%ax
f0105a2a:	66 90                	xchg   %ax,%ax
f0105a2c:	66 90                	xchg   %ax,%ax
f0105a2e:	66 90                	xchg   %ax,%ax

f0105a30 <__umoddi3>:
f0105a30:	55                   	push   %ebp
f0105a31:	57                   	push   %edi
f0105a32:	56                   	push   %esi
f0105a33:	53                   	push   %ebx
f0105a34:	83 ec 1c             	sub    $0x1c,%esp
f0105a37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0105a3b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0105a3f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105a43:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105a47:	85 d2                	test   %edx,%edx
f0105a49:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105a4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105a51:	89 f3                	mov    %esi,%ebx
f0105a53:	89 3c 24             	mov    %edi,(%esp)
f0105a56:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105a5a:	75 1c                	jne    f0105a78 <__umoddi3+0x48>
f0105a5c:	39 f7                	cmp    %esi,%edi
f0105a5e:	76 50                	jbe    f0105ab0 <__umoddi3+0x80>
f0105a60:	89 c8                	mov    %ecx,%eax
f0105a62:	89 f2                	mov    %esi,%edx
f0105a64:	f7 f7                	div    %edi
f0105a66:	89 d0                	mov    %edx,%eax
f0105a68:	31 d2                	xor    %edx,%edx
f0105a6a:	83 c4 1c             	add    $0x1c,%esp
f0105a6d:	5b                   	pop    %ebx
f0105a6e:	5e                   	pop    %esi
f0105a6f:	5f                   	pop    %edi
f0105a70:	5d                   	pop    %ebp
f0105a71:	c3                   	ret    
f0105a72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105a78:	39 f2                	cmp    %esi,%edx
f0105a7a:	89 d0                	mov    %edx,%eax
f0105a7c:	77 52                	ja     f0105ad0 <__umoddi3+0xa0>
f0105a7e:	0f bd ea             	bsr    %edx,%ebp
f0105a81:	83 f5 1f             	xor    $0x1f,%ebp
f0105a84:	75 5a                	jne    f0105ae0 <__umoddi3+0xb0>
f0105a86:	3b 54 24 04          	cmp    0x4(%esp),%edx
f0105a8a:	0f 82 e0 00 00 00    	jb     f0105b70 <__umoddi3+0x140>
f0105a90:	39 0c 24             	cmp    %ecx,(%esp)
f0105a93:	0f 86 d7 00 00 00    	jbe    f0105b70 <__umoddi3+0x140>
f0105a99:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105a9d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0105aa1:	83 c4 1c             	add    $0x1c,%esp
f0105aa4:	5b                   	pop    %ebx
f0105aa5:	5e                   	pop    %esi
f0105aa6:	5f                   	pop    %edi
f0105aa7:	5d                   	pop    %ebp
f0105aa8:	c3                   	ret    
f0105aa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105ab0:	85 ff                	test   %edi,%edi
f0105ab2:	89 fd                	mov    %edi,%ebp
f0105ab4:	75 0b                	jne    f0105ac1 <__umoddi3+0x91>
f0105ab6:	b8 01 00 00 00       	mov    $0x1,%eax
f0105abb:	31 d2                	xor    %edx,%edx
f0105abd:	f7 f7                	div    %edi
f0105abf:	89 c5                	mov    %eax,%ebp
f0105ac1:	89 f0                	mov    %esi,%eax
f0105ac3:	31 d2                	xor    %edx,%edx
f0105ac5:	f7 f5                	div    %ebp
f0105ac7:	89 c8                	mov    %ecx,%eax
f0105ac9:	f7 f5                	div    %ebp
f0105acb:	89 d0                	mov    %edx,%eax
f0105acd:	eb 99                	jmp    f0105a68 <__umoddi3+0x38>
f0105acf:	90                   	nop
f0105ad0:	89 c8                	mov    %ecx,%eax
f0105ad2:	89 f2                	mov    %esi,%edx
f0105ad4:	83 c4 1c             	add    $0x1c,%esp
f0105ad7:	5b                   	pop    %ebx
f0105ad8:	5e                   	pop    %esi
f0105ad9:	5f                   	pop    %edi
f0105ada:	5d                   	pop    %ebp
f0105adb:	c3                   	ret    
f0105adc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105ae0:	8b 34 24             	mov    (%esp),%esi
f0105ae3:	bf 20 00 00 00       	mov    $0x20,%edi
f0105ae8:	89 e9                	mov    %ebp,%ecx
f0105aea:	29 ef                	sub    %ebp,%edi
f0105aec:	d3 e0                	shl    %cl,%eax
f0105aee:	89 f9                	mov    %edi,%ecx
f0105af0:	89 f2                	mov    %esi,%edx
f0105af2:	d3 ea                	shr    %cl,%edx
f0105af4:	89 e9                	mov    %ebp,%ecx
f0105af6:	09 c2                	or     %eax,%edx
f0105af8:	89 d8                	mov    %ebx,%eax
f0105afa:	89 14 24             	mov    %edx,(%esp)
f0105afd:	89 f2                	mov    %esi,%edx
f0105aff:	d3 e2                	shl    %cl,%edx
f0105b01:	89 f9                	mov    %edi,%ecx
f0105b03:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105b07:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105b0b:	d3 e8                	shr    %cl,%eax
f0105b0d:	89 e9                	mov    %ebp,%ecx
f0105b0f:	89 c6                	mov    %eax,%esi
f0105b11:	d3 e3                	shl    %cl,%ebx
f0105b13:	89 f9                	mov    %edi,%ecx
f0105b15:	89 d0                	mov    %edx,%eax
f0105b17:	d3 e8                	shr    %cl,%eax
f0105b19:	89 e9                	mov    %ebp,%ecx
f0105b1b:	09 d8                	or     %ebx,%eax
f0105b1d:	89 d3                	mov    %edx,%ebx
f0105b1f:	89 f2                	mov    %esi,%edx
f0105b21:	f7 34 24             	divl   (%esp)
f0105b24:	89 d6                	mov    %edx,%esi
f0105b26:	d3 e3                	shl    %cl,%ebx
f0105b28:	f7 64 24 04          	mull   0x4(%esp)
f0105b2c:	39 d6                	cmp    %edx,%esi
f0105b2e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105b32:	89 d1                	mov    %edx,%ecx
f0105b34:	89 c3                	mov    %eax,%ebx
f0105b36:	72 08                	jb     f0105b40 <__umoddi3+0x110>
f0105b38:	75 11                	jne    f0105b4b <__umoddi3+0x11b>
f0105b3a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0105b3e:	73 0b                	jae    f0105b4b <__umoddi3+0x11b>
f0105b40:	2b 44 24 04          	sub    0x4(%esp),%eax
f0105b44:	1b 14 24             	sbb    (%esp),%edx
f0105b47:	89 d1                	mov    %edx,%ecx
f0105b49:	89 c3                	mov    %eax,%ebx
f0105b4b:	8b 54 24 08          	mov    0x8(%esp),%edx
f0105b4f:	29 da                	sub    %ebx,%edx
f0105b51:	19 ce                	sbb    %ecx,%esi
f0105b53:	89 f9                	mov    %edi,%ecx
f0105b55:	89 f0                	mov    %esi,%eax
f0105b57:	d3 e0                	shl    %cl,%eax
f0105b59:	89 e9                	mov    %ebp,%ecx
f0105b5b:	d3 ea                	shr    %cl,%edx
f0105b5d:	89 e9                	mov    %ebp,%ecx
f0105b5f:	d3 ee                	shr    %cl,%esi
f0105b61:	09 d0                	or     %edx,%eax
f0105b63:	89 f2                	mov    %esi,%edx
f0105b65:	83 c4 1c             	add    $0x1c,%esp
f0105b68:	5b                   	pop    %ebx
f0105b69:	5e                   	pop    %esi
f0105b6a:	5f                   	pop    %edi
f0105b6b:	5d                   	pop    %ebp
f0105b6c:	c3                   	ret    
f0105b6d:	8d 76 00             	lea    0x0(%esi),%esi
f0105b70:	29 f9                	sub    %edi,%ecx
f0105b72:	19 d6                	sbb    %edx,%esi
f0105b74:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105b78:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105b7c:	e9 18 ff ff ff       	jmp    f0105a99 <__umoddi3+0x69>
