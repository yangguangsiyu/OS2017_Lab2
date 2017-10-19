
obj/user/dumbfork：     文件格式 elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 c2 01 00 00       	call   8001f3 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	56                   	push   %esi
  800045:	e8 79 0c 00 00       	call   800cc3 <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800051:	50                   	push   %eax
  800052:	68 20 11 80 00       	push   $0x801120
  800057:	6a 21                	push   $0x21
  800059:	68 33 11 80 00       	push   $0x801133
  80005e:	e8 e8 01 00 00       	call   80024b <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	6a 07                	push   $0x7
  800068:	68 00 00 40 00       	push   $0x400000
  80006d:	6a 00                	push   $0x0
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 90 0c 00 00       	call   800d06 <sys_page_map>
  800076:	83 c4 20             	add    $0x20,%esp
  800079:	85 c0                	test   %eax,%eax
  80007b:	79 12                	jns    80008f <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007d:	50                   	push   %eax
  80007e:	68 43 11 80 00       	push   $0x801143
  800083:	6a 23                	push   $0x23
  800085:	68 33 11 80 00       	push   $0x801133
  80008a:	e8 bc 01 00 00       	call   80024b <_panic>
	memmove(UTEMP, addr, PGSIZE);
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	68 00 10 00 00       	push   $0x1000
  800097:	53                   	push   %ebx
  800098:	68 00 00 40 00       	push   $0x400000
  80009d:	e8 b0 09 00 00       	call   800a52 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 00 00 40 00       	push   $0x400000
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 97 0c 00 00       	call   800d48 <sys_page_unmap>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 54 11 80 00       	push   $0x801154
  8000be:	6a 26                	push   $0x26
  8000c0:	68 33 11 80 00       	push   $0x801133
  8000c5:	e8 81 01 00 00       	call   80024b <_panic>
}
  8000ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8000d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8000de:	cd 30                	int    $0x30
  8000e0:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000e2:	85 c0                	test   %eax,%eax
  8000e4:	79 12                	jns    8000f8 <dumbfork+0x27>
		panic("sys_exofork: %e", envid);
  8000e6:	50                   	push   %eax
  8000e7:	68 67 11 80 00       	push   $0x801167
  8000ec:	6a 38                	push   $0x38
  8000ee:	68 33 11 80 00       	push   $0x801133
  8000f3:	e8 53 01 00 00       	call   80024b <_panic>
  8000f8:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 1e                	jne    80011c <dumbfork+0x4b>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8000fe:	e8 82 0b 00 00       	call   800c85 <sys_getenvid>
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
  800108:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800110:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800115:	b8 00 00 00 00       	mov    $0x0,%eax
  80011a:	eb 60                	jmp    80017c <dumbfork+0xab>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80011c:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800123:	eb 14                	jmp    800139 <dumbfork+0x68>
		duppage(envid, addr);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	52                   	push   %edx
  800129:	56                   	push   %esi
  80012a:	e8 04 ff ff ff       	call   800033 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80012f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80013c:	81 fa 08 20 80 00    	cmp    $0x802008,%edx
  800142:	72 e1                	jb     800125 <dumbfork+0x54>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800144:	83 ec 08             	sub    $0x8,%esp
  800147:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80014a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80014f:	50                   	push   %eax
  800150:	53                   	push   %ebx
  800151:	e8 dd fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	6a 02                	push   $0x2
  80015b:	53                   	push   %ebx
  80015c:	e8 29 0c 00 00       	call   800d8a <sys_env_set_status>
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	85 c0                	test   %eax,%eax
  800166:	79 12                	jns    80017a <dumbfork+0xa9>
		panic("sys_env_set_status: %e", r);
  800168:	50                   	push   %eax
  800169:	68 77 11 80 00       	push   $0x801177
  80016e:	6a 4d                	push   $0x4d
  800170:	68 33 11 80 00       	push   $0x801133
  800175:	e8 d1 00 00 00       	call   80024b <_panic>

	return envid;
  80017a:	89 d8                	mov    %ebx,%eax
}
  80017c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    

00800183 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	56                   	push   %esi
  800187:	53                   	push   %ebx
  800188:	83 ec 18             	sub    $0x18,%esp
	envid_t who;
	int i;

	// fork a child process
    cprintf("address of i : %x\n", &i);
  80018b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80018e:	50                   	push   %eax
  80018f:	68 8e 11 80 00       	push   $0x80118e
  800194:	e8 8b 01 00 00       	call   800324 <cprintf>
	who = dumbfork();
  800199:	e8 33 ff ff ff       	call   8000d1 <dumbfork>
  80019e:	89 c6                	mov    %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  8001a7:	83 c4 10             	add    $0x10,%esp
  8001aa:	85 c0                	test   %eax,%eax
  8001ac:	bb a8 11 80 00       	mov    $0x8011a8,%ebx
  8001b1:	b8 a1 11 80 00       	mov    $0x8011a1,%eax
  8001b6:	0f 45 d8             	cmovne %eax,%ebx
  8001b9:	eb 1b                	jmp    8001d6 <umain+0x53>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001bb:	83 ec 04             	sub    $0x4,%esp
  8001be:	53                   	push   %ebx
  8001bf:	50                   	push   %eax
  8001c0:	68 ae 11 80 00       	push   $0x8011ae
  8001c5:	e8 5a 01 00 00       	call   800324 <cprintf>
		sys_yield();
  8001ca:	e8 d5 0a 00 00       	call   800ca4 <sys_yield>
	// fork a child process
    cprintf("address of i : %x\n", &i);
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001cf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  8001d3:	83 c4 10             	add    $0x10,%esp
  8001d6:	85 f6                	test   %esi,%esi
  8001d8:	74 0a                	je     8001e4 <umain+0x61>
  8001da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001dd:	83 f8 09             	cmp    $0x9,%eax
  8001e0:	7e d9                	jle    8001bb <umain+0x38>
  8001e2:	eb 08                	jmp    8001ec <umain+0x69>
  8001e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001e7:	83 f8 13             	cmp    $0x13,%eax
  8001ea:	7e cf                	jle    8001bb <umain+0x38>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  8001ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ef:	5b                   	pop    %ebx
  8001f0:	5e                   	pop    %esi
  8001f1:	5d                   	pop    %ebp
  8001f2:	c3                   	ret    

008001f3 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001f3:	55                   	push   %ebp
  8001f4:	89 e5                	mov    %esp,%ebp
  8001f6:	56                   	push   %esi
  8001f7:	53                   	push   %ebx
  8001f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001fb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8001fe:	e8 82 0a 00 00       	call   800c85 <sys_getenvid>
  800203:	25 ff 03 00 00       	and    $0x3ff,%eax
  800208:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80020b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800210:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800215:	85 db                	test   %ebx,%ebx
  800217:	7e 07                	jle    800220 <libmain+0x2d>
		binaryname = argv[0];
  800219:	8b 06                	mov    (%esi),%eax
  80021b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800220:	83 ec 08             	sub    $0x8,%esp
  800223:	56                   	push   %esi
  800224:	53                   	push   %ebx
  800225:	e8 59 ff ff ff       	call   800183 <umain>

	// exit gracefully
	exit();
  80022a:	e8 0a 00 00 00       	call   800239 <exit>
}
  80022f:	83 c4 10             	add    $0x10,%esp
  800232:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800235:	5b                   	pop    %ebx
  800236:	5e                   	pop    %esi
  800237:	5d                   	pop    %ebp
  800238:	c3                   	ret    

00800239 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80023f:	6a 00                	push   $0x0
  800241:	e8 fe 09 00 00       	call   800c44 <sys_env_destroy>
}
  800246:	83 c4 10             	add    $0x10,%esp
  800249:	c9                   	leave  
  80024a:	c3                   	ret    

0080024b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	56                   	push   %esi
  80024f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800250:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800253:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800259:	e8 27 0a 00 00       	call   800c85 <sys_getenvid>
  80025e:	83 ec 0c             	sub    $0xc,%esp
  800261:	ff 75 0c             	pushl  0xc(%ebp)
  800264:	ff 75 08             	pushl  0x8(%ebp)
  800267:	56                   	push   %esi
  800268:	50                   	push   %eax
  800269:	68 cc 11 80 00       	push   $0x8011cc
  80026e:	e8 b1 00 00 00       	call   800324 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800273:	83 c4 18             	add    $0x18,%esp
  800276:	53                   	push   %ebx
  800277:	ff 75 10             	pushl  0x10(%ebp)
  80027a:	e8 54 00 00 00       	call   8002d3 <vcprintf>
	cprintf("\n");
  80027f:	c7 04 24 be 11 80 00 	movl   $0x8011be,(%esp)
  800286:	e8 99 00 00 00       	call   800324 <cprintf>
  80028b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80028e:	cc                   	int3   
  80028f:	eb fd                	jmp    80028e <_panic+0x43>

00800291 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	53                   	push   %ebx
  800295:	83 ec 04             	sub    $0x4,%esp
  800298:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80029b:	8b 13                	mov    (%ebx),%edx
  80029d:	8d 42 01             	lea    0x1(%edx),%eax
  8002a0:	89 03                	mov    %eax,(%ebx)
  8002a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002a9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002ae:	75 1a                	jne    8002ca <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002b0:	83 ec 08             	sub    $0x8,%esp
  8002b3:	68 ff 00 00 00       	push   $0xff
  8002b8:	8d 43 08             	lea    0x8(%ebx),%eax
  8002bb:	50                   	push   %eax
  8002bc:	e8 46 09 00 00       	call   800c07 <sys_cputs>
		b->idx = 0;
  8002c1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002c7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002ca:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002d1:	c9                   	leave  
  8002d2:	c3                   	ret    

008002d3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002d3:	55                   	push   %ebp
  8002d4:	89 e5                	mov    %esp,%ebp
  8002d6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002dc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002e3:	00 00 00 
	b.cnt = 0;
  8002e6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ed:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002f0:	ff 75 0c             	pushl  0xc(%ebp)
  8002f3:	ff 75 08             	pushl  0x8(%ebp)
  8002f6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002fc:	50                   	push   %eax
  8002fd:	68 91 02 80 00       	push   $0x800291
  800302:	e8 54 01 00 00       	call   80045b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800307:	83 c4 08             	add    $0x8,%esp
  80030a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800310:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800316:	50                   	push   %eax
  800317:	e8 eb 08 00 00       	call   800c07 <sys_cputs>

	return b.cnt;
}
  80031c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80032a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80032d:	50                   	push   %eax
  80032e:	ff 75 08             	pushl  0x8(%ebp)
  800331:	e8 9d ff ff ff       	call   8002d3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800336:	c9                   	leave  
  800337:	c3                   	ret    

00800338 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
  80033b:	57                   	push   %edi
  80033c:	56                   	push   %esi
  80033d:	53                   	push   %ebx
  80033e:	83 ec 1c             	sub    $0x1c,%esp
  800341:	89 c7                	mov    %eax,%edi
  800343:	89 d6                	mov    %edx,%esi
  800345:	8b 45 08             	mov    0x8(%ebp),%eax
  800348:	8b 55 0c             	mov    0xc(%ebp),%edx
  80034b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80034e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800351:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800354:	bb 00 00 00 00       	mov    $0x0,%ebx
  800359:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80035c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80035f:	39 d3                	cmp    %edx,%ebx
  800361:	72 05                	jb     800368 <printnum+0x30>
  800363:	39 45 10             	cmp    %eax,0x10(%ebp)
  800366:	77 45                	ja     8003ad <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800368:	83 ec 0c             	sub    $0xc,%esp
  80036b:	ff 75 18             	pushl  0x18(%ebp)
  80036e:	8b 45 14             	mov    0x14(%ebp),%eax
  800371:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800374:	53                   	push   %ebx
  800375:	ff 75 10             	pushl  0x10(%ebp)
  800378:	83 ec 08             	sub    $0x8,%esp
  80037b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80037e:	ff 75 e0             	pushl  -0x20(%ebp)
  800381:	ff 75 dc             	pushl  -0x24(%ebp)
  800384:	ff 75 d8             	pushl  -0x28(%ebp)
  800387:	e8 f4 0a 00 00       	call   800e80 <__udivdi3>
  80038c:	83 c4 18             	add    $0x18,%esp
  80038f:	52                   	push   %edx
  800390:	50                   	push   %eax
  800391:	89 f2                	mov    %esi,%edx
  800393:	89 f8                	mov    %edi,%eax
  800395:	e8 9e ff ff ff       	call   800338 <printnum>
  80039a:	83 c4 20             	add    $0x20,%esp
  80039d:	eb 18                	jmp    8003b7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80039f:	83 ec 08             	sub    $0x8,%esp
  8003a2:	56                   	push   %esi
  8003a3:	ff 75 18             	pushl  0x18(%ebp)
  8003a6:	ff d7                	call   *%edi
  8003a8:	83 c4 10             	add    $0x10,%esp
  8003ab:	eb 03                	jmp    8003b0 <printnum+0x78>
  8003ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003b0:	83 eb 01             	sub    $0x1,%ebx
  8003b3:	85 db                	test   %ebx,%ebx
  8003b5:	7f e8                	jg     80039f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b7:	83 ec 08             	sub    $0x8,%esp
  8003ba:	56                   	push   %esi
  8003bb:	83 ec 04             	sub    $0x4,%esp
  8003be:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8003c4:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c7:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ca:	e8 e1 0b 00 00       	call   800fb0 <__umoddi3>
  8003cf:	83 c4 14             	add    $0x14,%esp
  8003d2:	0f be 80 f0 11 80 00 	movsbl 0x8011f0(%eax),%eax
  8003d9:	50                   	push   %eax
  8003da:	ff d7                	call   *%edi
}
  8003dc:	83 c4 10             	add    $0x10,%esp
  8003df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003e2:	5b                   	pop    %ebx
  8003e3:	5e                   	pop    %esi
  8003e4:	5f                   	pop    %edi
  8003e5:	5d                   	pop    %ebp
  8003e6:	c3                   	ret    

008003e7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003e7:	55                   	push   %ebp
  8003e8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003ea:	83 fa 01             	cmp    $0x1,%edx
  8003ed:	7e 0e                	jle    8003fd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003ef:	8b 10                	mov    (%eax),%edx
  8003f1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003f4:	89 08                	mov    %ecx,(%eax)
  8003f6:	8b 02                	mov    (%edx),%eax
  8003f8:	8b 52 04             	mov    0x4(%edx),%edx
  8003fb:	eb 22                	jmp    80041f <getuint+0x38>
	else if (lflag)
  8003fd:	85 d2                	test   %edx,%edx
  8003ff:	74 10                	je     800411 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800401:	8b 10                	mov    (%eax),%edx
  800403:	8d 4a 04             	lea    0x4(%edx),%ecx
  800406:	89 08                	mov    %ecx,(%eax)
  800408:	8b 02                	mov    (%edx),%eax
  80040a:	ba 00 00 00 00       	mov    $0x0,%edx
  80040f:	eb 0e                	jmp    80041f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800411:	8b 10                	mov    (%eax),%edx
  800413:	8d 4a 04             	lea    0x4(%edx),%ecx
  800416:	89 08                	mov    %ecx,(%eax)
  800418:	8b 02                	mov    (%edx),%eax
  80041a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80041f:	5d                   	pop    %ebp
  800420:	c3                   	ret    

00800421 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800421:	55                   	push   %ebp
  800422:	89 e5                	mov    %esp,%ebp
  800424:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800427:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80042b:	8b 10                	mov    (%eax),%edx
  80042d:	3b 50 04             	cmp    0x4(%eax),%edx
  800430:	73 0a                	jae    80043c <sprintputch+0x1b>
		*b->buf++ = ch;
  800432:	8d 4a 01             	lea    0x1(%edx),%ecx
  800435:	89 08                	mov    %ecx,(%eax)
  800437:	8b 45 08             	mov    0x8(%ebp),%eax
  80043a:	88 02                	mov    %al,(%edx)
}
  80043c:	5d                   	pop    %ebp
  80043d:	c3                   	ret    

0080043e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800444:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800447:	50                   	push   %eax
  800448:	ff 75 10             	pushl  0x10(%ebp)
  80044b:	ff 75 0c             	pushl  0xc(%ebp)
  80044e:	ff 75 08             	pushl  0x8(%ebp)
  800451:	e8 05 00 00 00       	call   80045b <vprintfmt>
	va_end(ap);
}
  800456:	83 c4 10             	add    $0x10,%esp
  800459:	c9                   	leave  
  80045a:	c3                   	ret    

0080045b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80045b:	55                   	push   %ebp
  80045c:	89 e5                	mov    %esp,%ebp
  80045e:	57                   	push   %edi
  80045f:	56                   	push   %esi
  800460:	53                   	push   %ebx
  800461:	83 ec 2c             	sub    $0x2c,%esp
  800464:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
  800467:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80046e:	eb 17                	jmp    800487 <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800470:	85 c0                	test   %eax,%eax
  800472:	0f 84 9f 03 00 00    	je     800817 <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	ff 75 0c             	pushl  0xc(%ebp)
  80047e:	50                   	push   %eax
  80047f:	ff 55 08             	call   *0x8(%ebp)
  800482:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800485:	89 f3                	mov    %esi,%ebx
  800487:	8d 73 01             	lea    0x1(%ebx),%esi
  80048a:	0f b6 03             	movzbl (%ebx),%eax
  80048d:	83 f8 25             	cmp    $0x25,%eax
  800490:	75 de                	jne    800470 <vprintfmt+0x15>
  800492:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800496:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80049d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004a2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ae:	eb 06                	jmp    8004b6 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b0:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004b2:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b6:	8d 5e 01             	lea    0x1(%esi),%ebx
  8004b9:	0f b6 06             	movzbl (%esi),%eax
  8004bc:	0f b6 c8             	movzbl %al,%ecx
  8004bf:	83 e8 23             	sub    $0x23,%eax
  8004c2:	3c 55                	cmp    $0x55,%al
  8004c4:	0f 87 2d 03 00 00    	ja     8007f7 <vprintfmt+0x39c>
  8004ca:	0f b6 c0             	movzbl %al,%eax
  8004cd:	ff 24 85 c0 12 80 00 	jmp    *0x8012c0(,%eax,4)
  8004d4:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004d6:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8004da:	eb da                	jmp    8004b6 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dc:	89 de                	mov    %ebx,%esi
  8004de:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004e3:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  8004e6:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  8004ea:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  8004ed:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8004f0:	83 f8 09             	cmp    $0x9,%eax
  8004f3:	77 33                	ja     800528 <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f5:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f8:	eb e9                	jmp    8004e3 <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fd:	8d 48 04             	lea    0x4(%eax),%ecx
  800500:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800503:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800505:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800507:	eb 1f                	jmp    800528 <vprintfmt+0xcd>
  800509:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80050c:	85 c0                	test   %eax,%eax
  80050e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800513:	0f 49 c8             	cmovns %eax,%ecx
  800516:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800519:	89 de                	mov    %ebx,%esi
  80051b:	eb 99                	jmp    8004b6 <vprintfmt+0x5b>
  80051d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80051f:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  800526:	eb 8e                	jmp    8004b6 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  800528:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052c:	79 88                	jns    8004b6 <vprintfmt+0x5b>
				width = precision, precision = -1;
  80052e:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800531:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800536:	e9 7b ff ff ff       	jmp    8004b6 <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80053b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053e:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800540:	e9 71 ff ff ff       	jmp    8004b6 <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8d 50 04             	lea    0x4(%eax),%edx
  80054b:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  80054e:	83 ec 08             	sub    $0x8,%esp
  800551:	ff 75 0c             	pushl  0xc(%ebp)
  800554:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800557:	03 08                	add    (%eax),%ecx
  800559:	51                   	push   %ecx
  80055a:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
  80055d:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
  800560:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
  800567:	e9 1b ff ff ff       	jmp    800487 <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
  80056c:	8b 45 14             	mov    0x14(%ebp),%eax
  80056f:	8d 48 04             	lea    0x4(%eax),%ecx
  800572:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800575:	8b 00                	mov    (%eax),%eax
  800577:	83 f8 02             	cmp    $0x2,%eax
  80057a:	74 1a                	je     800596 <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057c:	89 de                	mov    %ebx,%esi
  80057e:	83 f8 04             	cmp    $0x4,%eax
  800581:	b8 00 00 00 00       	mov    $0x0,%eax
  800586:	b9 00 04 00 00       	mov    $0x400,%ecx
  80058b:	0f 44 c1             	cmove  %ecx,%eax
  80058e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800591:	e9 20 ff ff ff       	jmp    8004b6 <vprintfmt+0x5b>
  800596:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
  800598:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
  80059f:	e9 12 ff ff ff       	jmp    8004b6 <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8d 50 04             	lea    0x4(%eax),%edx
  8005aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ad:	8b 00                	mov    (%eax),%eax
  8005af:	99                   	cltd   
  8005b0:	31 d0                	xor    %edx,%eax
  8005b2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005b4:	83 f8 09             	cmp    $0x9,%eax
  8005b7:	7f 0b                	jg     8005c4 <vprintfmt+0x169>
  8005b9:	8b 14 85 20 14 80 00 	mov    0x801420(,%eax,4),%edx
  8005c0:	85 d2                	test   %edx,%edx
  8005c2:	75 19                	jne    8005dd <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  8005c4:	50                   	push   %eax
  8005c5:	68 08 12 80 00       	push   $0x801208
  8005ca:	ff 75 0c             	pushl  0xc(%ebp)
  8005cd:	ff 75 08             	pushl  0x8(%ebp)
  8005d0:	e8 69 fe ff ff       	call   80043e <printfmt>
  8005d5:	83 c4 10             	add    $0x10,%esp
  8005d8:	e9 aa fe ff ff       	jmp    800487 <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  8005dd:	52                   	push   %edx
  8005de:	68 11 12 80 00       	push   $0x801211
  8005e3:	ff 75 0c             	pushl  0xc(%ebp)
  8005e6:	ff 75 08             	pushl  0x8(%ebp)
  8005e9:	e8 50 fe ff ff       	call   80043e <printfmt>
  8005ee:	83 c4 10             	add    $0x10,%esp
  8005f1:	e9 91 fe ff ff       	jmp    800487 <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f9:	8d 50 04             	lea    0x4(%eax),%edx
  8005fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ff:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800601:	85 f6                	test   %esi,%esi
  800603:	b8 01 12 80 00       	mov    $0x801201,%eax
  800608:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80060b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80060f:	0f 8e 93 00 00 00    	jle    8006a8 <vprintfmt+0x24d>
  800615:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800619:	0f 84 91 00 00 00    	je     8006b0 <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
  80061f:	83 ec 08             	sub    $0x8,%esp
  800622:	57                   	push   %edi
  800623:	56                   	push   %esi
  800624:	e8 76 02 00 00       	call   80089f <strnlen>
  800629:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80062c:	29 c1                	sub    %eax,%ecx
  80062e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800631:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800634:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  800638:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80063b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80063e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800641:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800644:	89 cb                	mov    %ecx,%ebx
  800646:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800648:	eb 0e                	jmp    800658 <vprintfmt+0x1fd>
					putch(padc, putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	56                   	push   %esi
  80064e:	57                   	push   %edi
  80064f:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800652:	83 eb 01             	sub    $0x1,%ebx
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	85 db                	test   %ebx,%ebx
  80065a:	7f ee                	jg     80064a <vprintfmt+0x1ef>
  80065c:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80065f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800662:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800665:	85 c9                	test   %ecx,%ecx
  800667:	b8 00 00 00 00       	mov    $0x0,%eax
  80066c:	0f 49 c1             	cmovns %ecx,%eax
  80066f:	29 c1                	sub    %eax,%ecx
  800671:	89 cb                	mov    %ecx,%ebx
  800673:	eb 41                	jmp    8006b6 <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800675:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800679:	74 1b                	je     800696 <vprintfmt+0x23b>
  80067b:	0f be c0             	movsbl %al,%eax
  80067e:	83 e8 20             	sub    $0x20,%eax
  800681:	83 f8 5e             	cmp    $0x5e,%eax
  800684:	76 10                	jbe    800696 <vprintfmt+0x23b>
					putch('?', putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	ff 75 0c             	pushl  0xc(%ebp)
  80068c:	6a 3f                	push   $0x3f
  80068e:	ff 55 08             	call   *0x8(%ebp)
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	eb 0d                	jmp    8006a3 <vprintfmt+0x248>
				else
					putch(ch, putdat);
  800696:	83 ec 08             	sub    $0x8,%esp
  800699:	ff 75 0c             	pushl  0xc(%ebp)
  80069c:	52                   	push   %edx
  80069d:	ff 55 08             	call   *0x8(%ebp)
  8006a0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006a3:	83 eb 01             	sub    $0x1,%ebx
  8006a6:	eb 0e                	jmp    8006b6 <vprintfmt+0x25b>
  8006a8:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006ab:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006ae:	eb 06                	jmp    8006b6 <vprintfmt+0x25b>
  8006b0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006b3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006b6:	83 c6 01             	add    $0x1,%esi
  8006b9:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8006bd:	0f be d0             	movsbl %al,%edx
  8006c0:	85 d2                	test   %edx,%edx
  8006c2:	74 25                	je     8006e9 <vprintfmt+0x28e>
  8006c4:	85 ff                	test   %edi,%edi
  8006c6:	78 ad                	js     800675 <vprintfmt+0x21a>
  8006c8:	83 ef 01             	sub    $0x1,%edi
  8006cb:	79 a8                	jns    800675 <vprintfmt+0x21a>
  8006cd:	89 d8                	mov    %ebx,%eax
  8006cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006d5:	89 c3                	mov    %eax,%ebx
  8006d7:	eb 16                	jmp    8006ef <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006d9:	83 ec 08             	sub    $0x8,%esp
  8006dc:	57                   	push   %edi
  8006dd:	6a 20                	push   $0x20
  8006df:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006e1:	83 eb 01             	sub    $0x1,%ebx
  8006e4:	83 c4 10             	add    $0x10,%esp
  8006e7:	eb 06                	jmp    8006ef <vprintfmt+0x294>
  8006e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ec:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006ef:	85 db                	test   %ebx,%ebx
  8006f1:	7f e6                	jg     8006d9 <vprintfmt+0x27e>
  8006f3:	89 75 08             	mov    %esi,0x8(%ebp)
  8006f6:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8006f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006fc:	e9 86 fd ff ff       	jmp    800487 <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800701:	83 fa 01             	cmp    $0x1,%edx
  800704:	7e 10                	jle    800716 <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8d 50 08             	lea    0x8(%eax),%edx
  80070c:	89 55 14             	mov    %edx,0x14(%ebp)
  80070f:	8b 30                	mov    (%eax),%esi
  800711:	8b 78 04             	mov    0x4(%eax),%edi
  800714:	eb 26                	jmp    80073c <vprintfmt+0x2e1>
	else if (lflag)
  800716:	85 d2                	test   %edx,%edx
  800718:	74 12                	je     80072c <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8d 50 04             	lea    0x4(%eax),%edx
  800720:	89 55 14             	mov    %edx,0x14(%ebp)
  800723:	8b 30                	mov    (%eax),%esi
  800725:	89 f7                	mov    %esi,%edi
  800727:	c1 ff 1f             	sar    $0x1f,%edi
  80072a:	eb 10                	jmp    80073c <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8d 50 04             	lea    0x4(%eax),%edx
  800732:	89 55 14             	mov    %edx,0x14(%ebp)
  800735:	8b 30                	mov    (%eax),%esi
  800737:	89 f7                	mov    %esi,%edi
  800739:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80073c:	89 f0                	mov    %esi,%eax
  80073e:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800740:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800745:	85 ff                	test   %edi,%edi
  800747:	79 7b                	jns    8007c4 <vprintfmt+0x369>
				putch('-', putdat);
  800749:	83 ec 08             	sub    $0x8,%esp
  80074c:	ff 75 0c             	pushl  0xc(%ebp)
  80074f:	6a 2d                	push   $0x2d
  800751:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800754:	89 f0                	mov    %esi,%eax
  800756:	89 fa                	mov    %edi,%edx
  800758:	f7 d8                	neg    %eax
  80075a:	83 d2 00             	adc    $0x0,%edx
  80075d:	f7 da                	neg    %edx
  80075f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800762:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800767:	eb 5b                	jmp    8007c4 <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800769:	8d 45 14             	lea    0x14(%ebp),%eax
  80076c:	e8 76 fc ff ff       	call   8003e7 <getuint>
			base = 10;
  800771:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800776:	eb 4c                	jmp    8007c4 <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
  800778:	8d 45 14             	lea    0x14(%ebp),%eax
  80077b:	e8 67 fc ff ff       	call   8003e7 <getuint>
            base = 8;
  800780:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800785:	eb 3d                	jmp    8007c4 <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
  800787:	83 ec 08             	sub    $0x8,%esp
  80078a:	ff 75 0c             	pushl  0xc(%ebp)
  80078d:	6a 30                	push   $0x30
  80078f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800792:	83 c4 08             	add    $0x8,%esp
  800795:	ff 75 0c             	pushl  0xc(%ebp)
  800798:	6a 78                	push   $0x78
  80079a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80079d:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a0:	8d 50 04             	lea    0x4(%eax),%edx
  8007a3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007a6:	8b 00                	mov    (%eax),%eax
  8007a8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007ad:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007b0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007b5:	eb 0d                	jmp    8007c4 <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007b7:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ba:	e8 28 fc ff ff       	call   8003e7 <getuint>
			base = 16;
  8007bf:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007c4:	83 ec 0c             	sub    $0xc,%esp
  8007c7:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  8007cb:	56                   	push   %esi
  8007cc:	ff 75 e0             	pushl  -0x20(%ebp)
  8007cf:	51                   	push   %ecx
  8007d0:	52                   	push   %edx
  8007d1:	50                   	push   %eax
  8007d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d8:	e8 5b fb ff ff       	call   800338 <printnum>
			break;
  8007dd:	83 c4 20             	add    $0x20,%esp
  8007e0:	e9 a2 fc ff ff       	jmp    800487 <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007e5:	83 ec 08             	sub    $0x8,%esp
  8007e8:	ff 75 0c             	pushl  0xc(%ebp)
  8007eb:	51                   	push   %ecx
  8007ec:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007ef:	83 c4 10             	add    $0x10,%esp
  8007f2:	e9 90 fc ff ff       	jmp    800487 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007f7:	83 ec 08             	sub    $0x8,%esp
  8007fa:	ff 75 0c             	pushl  0xc(%ebp)
  8007fd:	6a 25                	push   $0x25
  8007ff:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800802:	83 c4 10             	add    $0x10,%esp
  800805:	89 f3                	mov    %esi,%ebx
  800807:	eb 03                	jmp    80080c <vprintfmt+0x3b1>
  800809:	83 eb 01             	sub    $0x1,%ebx
  80080c:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800810:	75 f7                	jne    800809 <vprintfmt+0x3ae>
  800812:	e9 70 fc ff ff       	jmp    800487 <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  800817:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80081a:	5b                   	pop    %ebx
  80081b:	5e                   	pop    %esi
  80081c:	5f                   	pop    %edi
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	83 ec 18             	sub    $0x18,%esp
  800825:	8b 45 08             	mov    0x8(%ebp),%eax
  800828:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80082b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80082e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800832:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800835:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80083c:	85 c0                	test   %eax,%eax
  80083e:	74 26                	je     800866 <vsnprintf+0x47>
  800840:	85 d2                	test   %edx,%edx
  800842:	7e 22                	jle    800866 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800844:	ff 75 14             	pushl  0x14(%ebp)
  800847:	ff 75 10             	pushl  0x10(%ebp)
  80084a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80084d:	50                   	push   %eax
  80084e:	68 21 04 80 00       	push   $0x800421
  800853:	e8 03 fc ff ff       	call   80045b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800858:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80085b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80085e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800861:	83 c4 10             	add    $0x10,%esp
  800864:	eb 05                	jmp    80086b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800866:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80086b:	c9                   	leave  
  80086c:	c3                   	ret    

0080086d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800873:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800876:	50                   	push   %eax
  800877:	ff 75 10             	pushl  0x10(%ebp)
  80087a:	ff 75 0c             	pushl  0xc(%ebp)
  80087d:	ff 75 08             	pushl  0x8(%ebp)
  800880:	e8 9a ff ff ff       	call   80081f <vsnprintf>
	va_end(ap);

	return rc;
}
  800885:	c9                   	leave  
  800886:	c3                   	ret    

00800887 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80088d:	b8 00 00 00 00       	mov    $0x0,%eax
  800892:	eb 03                	jmp    800897 <strlen+0x10>
		n++;
  800894:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800897:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80089b:	75 f7                	jne    800894 <strlen+0xd>
		n++;
	return n;
}
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ad:	eb 03                	jmp    8008b2 <strnlen+0x13>
		n++;
  8008af:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b2:	39 c2                	cmp    %eax,%edx
  8008b4:	74 08                	je     8008be <strnlen+0x1f>
  8008b6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008ba:	75 f3                	jne    8008af <strnlen+0x10>
  8008bc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	53                   	push   %ebx
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ca:	89 c2                	mov    %eax,%edx
  8008cc:	83 c2 01             	add    $0x1,%edx
  8008cf:	83 c1 01             	add    $0x1,%ecx
  8008d2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008d6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008d9:	84 db                	test   %bl,%bl
  8008db:	75 ef                	jne    8008cc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008dd:	5b                   	pop    %ebx
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	53                   	push   %ebx
  8008e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e7:	53                   	push   %ebx
  8008e8:	e8 9a ff ff ff       	call   800887 <strlen>
  8008ed:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008f0:	ff 75 0c             	pushl  0xc(%ebp)
  8008f3:	01 d8                	add    %ebx,%eax
  8008f5:	50                   	push   %eax
  8008f6:	e8 c5 ff ff ff       	call   8008c0 <strcpy>
	return dst;
}
  8008fb:	89 d8                	mov    %ebx,%eax
  8008fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800900:	c9                   	leave  
  800901:	c3                   	ret    

00800902 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	56                   	push   %esi
  800906:	53                   	push   %ebx
  800907:	8b 75 08             	mov    0x8(%ebp),%esi
  80090a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090d:	89 f3                	mov    %esi,%ebx
  80090f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800912:	89 f2                	mov    %esi,%edx
  800914:	eb 0f                	jmp    800925 <strncpy+0x23>
		*dst++ = *src;
  800916:	83 c2 01             	add    $0x1,%edx
  800919:	0f b6 01             	movzbl (%ecx),%eax
  80091c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80091f:	80 39 01             	cmpb   $0x1,(%ecx)
  800922:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800925:	39 da                	cmp    %ebx,%edx
  800927:	75 ed                	jne    800916 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800929:	89 f0                	mov    %esi,%eax
  80092b:	5b                   	pop    %ebx
  80092c:	5e                   	pop    %esi
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	56                   	push   %esi
  800933:	53                   	push   %ebx
  800934:	8b 75 08             	mov    0x8(%ebp),%esi
  800937:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093a:	8b 55 10             	mov    0x10(%ebp),%edx
  80093d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80093f:	85 d2                	test   %edx,%edx
  800941:	74 21                	je     800964 <strlcpy+0x35>
  800943:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800947:	89 f2                	mov    %esi,%edx
  800949:	eb 09                	jmp    800954 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80094b:	83 c2 01             	add    $0x1,%edx
  80094e:	83 c1 01             	add    $0x1,%ecx
  800951:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800954:	39 c2                	cmp    %eax,%edx
  800956:	74 09                	je     800961 <strlcpy+0x32>
  800958:	0f b6 19             	movzbl (%ecx),%ebx
  80095b:	84 db                	test   %bl,%bl
  80095d:	75 ec                	jne    80094b <strlcpy+0x1c>
  80095f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800961:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800964:	29 f0                	sub    %esi,%eax
}
  800966:	5b                   	pop    %ebx
  800967:	5e                   	pop    %esi
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800970:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800973:	eb 06                	jmp    80097b <strcmp+0x11>
		p++, q++;
  800975:	83 c1 01             	add    $0x1,%ecx
  800978:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80097b:	0f b6 01             	movzbl (%ecx),%eax
  80097e:	84 c0                	test   %al,%al
  800980:	74 04                	je     800986 <strcmp+0x1c>
  800982:	3a 02                	cmp    (%edx),%al
  800984:	74 ef                	je     800975 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800986:	0f b6 c0             	movzbl %al,%eax
  800989:	0f b6 12             	movzbl (%edx),%edx
  80098c:	29 d0                	sub    %edx,%eax
}
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	53                   	push   %ebx
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099a:	89 c3                	mov    %eax,%ebx
  80099c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80099f:	eb 06                	jmp    8009a7 <strncmp+0x17>
		n--, p++, q++;
  8009a1:	83 c0 01             	add    $0x1,%eax
  8009a4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009a7:	39 d8                	cmp    %ebx,%eax
  8009a9:	74 15                	je     8009c0 <strncmp+0x30>
  8009ab:	0f b6 08             	movzbl (%eax),%ecx
  8009ae:	84 c9                	test   %cl,%cl
  8009b0:	74 04                	je     8009b6 <strncmp+0x26>
  8009b2:	3a 0a                	cmp    (%edx),%cl
  8009b4:	74 eb                	je     8009a1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b6:	0f b6 00             	movzbl (%eax),%eax
  8009b9:	0f b6 12             	movzbl (%edx),%edx
  8009bc:	29 d0                	sub    %edx,%eax
  8009be:	eb 05                	jmp    8009c5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009c0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009c5:	5b                   	pop    %ebx
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d2:	eb 07                	jmp    8009db <strchr+0x13>
		if (*s == c)
  8009d4:	38 ca                	cmp    %cl,%dl
  8009d6:	74 0f                	je     8009e7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009d8:	83 c0 01             	add    $0x1,%eax
  8009db:	0f b6 10             	movzbl (%eax),%edx
  8009de:	84 d2                	test   %dl,%dl
  8009e0:	75 f2                	jne    8009d4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f3:	eb 03                	jmp    8009f8 <strfind+0xf>
  8009f5:	83 c0 01             	add    $0x1,%eax
  8009f8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009fb:	38 ca                	cmp    %cl,%dl
  8009fd:	74 04                	je     800a03 <strfind+0x1a>
  8009ff:	84 d2                	test   %dl,%dl
  800a01:	75 f2                	jne    8009f5 <strfind+0xc>
			break;
	return (char *) s;
}
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	57                   	push   %edi
  800a09:	56                   	push   %esi
  800a0a:	53                   	push   %ebx
  800a0b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a11:	85 c9                	test   %ecx,%ecx
  800a13:	74 36                	je     800a4b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a15:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1b:	75 28                	jne    800a45 <memset+0x40>
  800a1d:	f6 c1 03             	test   $0x3,%cl
  800a20:	75 23                	jne    800a45 <memset+0x40>
		c &= 0xFF;
  800a22:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a26:	89 d3                	mov    %edx,%ebx
  800a28:	c1 e3 08             	shl    $0x8,%ebx
  800a2b:	89 d6                	mov    %edx,%esi
  800a2d:	c1 e6 18             	shl    $0x18,%esi
  800a30:	89 d0                	mov    %edx,%eax
  800a32:	c1 e0 10             	shl    $0x10,%eax
  800a35:	09 f0                	or     %esi,%eax
  800a37:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a39:	89 d8                	mov    %ebx,%eax
  800a3b:	09 d0                	or     %edx,%eax
  800a3d:	c1 e9 02             	shr    $0x2,%ecx
  800a40:	fc                   	cld    
  800a41:	f3 ab                	rep stos %eax,%es:(%edi)
  800a43:	eb 06                	jmp    800a4b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a45:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a48:	fc                   	cld    
  800a49:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a4b:	89 f8                	mov    %edi,%eax
  800a4d:	5b                   	pop    %ebx
  800a4e:	5e                   	pop    %esi
  800a4f:	5f                   	pop    %edi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	57                   	push   %edi
  800a56:	56                   	push   %esi
  800a57:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a60:	39 c6                	cmp    %eax,%esi
  800a62:	73 35                	jae    800a99 <memmove+0x47>
  800a64:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a67:	39 d0                	cmp    %edx,%eax
  800a69:	73 2e                	jae    800a99 <memmove+0x47>
		s += n;
		d += n;
  800a6b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6e:	89 d6                	mov    %edx,%esi
  800a70:	09 fe                	or     %edi,%esi
  800a72:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a78:	75 13                	jne    800a8d <memmove+0x3b>
  800a7a:	f6 c1 03             	test   $0x3,%cl
  800a7d:	75 0e                	jne    800a8d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a7f:	83 ef 04             	sub    $0x4,%edi
  800a82:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a85:	c1 e9 02             	shr    $0x2,%ecx
  800a88:	fd                   	std    
  800a89:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a8b:	eb 09                	jmp    800a96 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a8d:	83 ef 01             	sub    $0x1,%edi
  800a90:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a93:	fd                   	std    
  800a94:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a96:	fc                   	cld    
  800a97:	eb 1d                	jmp    800ab6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a99:	89 f2                	mov    %esi,%edx
  800a9b:	09 c2                	or     %eax,%edx
  800a9d:	f6 c2 03             	test   $0x3,%dl
  800aa0:	75 0f                	jne    800ab1 <memmove+0x5f>
  800aa2:	f6 c1 03             	test   $0x3,%cl
  800aa5:	75 0a                	jne    800ab1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800aa7:	c1 e9 02             	shr    $0x2,%ecx
  800aaa:	89 c7                	mov    %eax,%edi
  800aac:	fc                   	cld    
  800aad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aaf:	eb 05                	jmp    800ab6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ab1:	89 c7                	mov    %eax,%edi
  800ab3:	fc                   	cld    
  800ab4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ab6:	5e                   	pop    %esi
  800ab7:	5f                   	pop    %edi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800abd:	ff 75 10             	pushl  0x10(%ebp)
  800ac0:	ff 75 0c             	pushl  0xc(%ebp)
  800ac3:	ff 75 08             	pushl  0x8(%ebp)
  800ac6:	e8 87 ff ff ff       	call   800a52 <memmove>
}
  800acb:	c9                   	leave  
  800acc:	c3                   	ret    

00800acd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
  800ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad8:	89 c6                	mov    %eax,%esi
  800ada:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800add:	eb 1a                	jmp    800af9 <memcmp+0x2c>
		if (*s1 != *s2)
  800adf:	0f b6 08             	movzbl (%eax),%ecx
  800ae2:	0f b6 1a             	movzbl (%edx),%ebx
  800ae5:	38 d9                	cmp    %bl,%cl
  800ae7:	74 0a                	je     800af3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ae9:	0f b6 c1             	movzbl %cl,%eax
  800aec:	0f b6 db             	movzbl %bl,%ebx
  800aef:	29 d8                	sub    %ebx,%eax
  800af1:	eb 0f                	jmp    800b02 <memcmp+0x35>
		s1++, s2++;
  800af3:	83 c0 01             	add    $0x1,%eax
  800af6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af9:	39 f0                	cmp    %esi,%eax
  800afb:	75 e2                	jne    800adf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800afd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	53                   	push   %ebx
  800b0a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b0d:	89 c1                	mov    %eax,%ecx
  800b0f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b12:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b16:	eb 0a                	jmp    800b22 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b18:	0f b6 10             	movzbl (%eax),%edx
  800b1b:	39 da                	cmp    %ebx,%edx
  800b1d:	74 07                	je     800b26 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b1f:	83 c0 01             	add    $0x1,%eax
  800b22:	39 c8                	cmp    %ecx,%eax
  800b24:	72 f2                	jb     800b18 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b26:	5b                   	pop    %ebx
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	57                   	push   %edi
  800b2d:	56                   	push   %esi
  800b2e:	53                   	push   %ebx
  800b2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b32:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b35:	eb 03                	jmp    800b3a <strtol+0x11>
		s++;
  800b37:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b3a:	0f b6 01             	movzbl (%ecx),%eax
  800b3d:	3c 20                	cmp    $0x20,%al
  800b3f:	74 f6                	je     800b37 <strtol+0xe>
  800b41:	3c 09                	cmp    $0x9,%al
  800b43:	74 f2                	je     800b37 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b45:	3c 2b                	cmp    $0x2b,%al
  800b47:	75 0a                	jne    800b53 <strtol+0x2a>
		s++;
  800b49:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b4c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b51:	eb 11                	jmp    800b64 <strtol+0x3b>
  800b53:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b58:	3c 2d                	cmp    $0x2d,%al
  800b5a:	75 08                	jne    800b64 <strtol+0x3b>
		s++, neg = 1;
  800b5c:	83 c1 01             	add    $0x1,%ecx
  800b5f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b64:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b6a:	75 15                	jne    800b81 <strtol+0x58>
  800b6c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b6f:	75 10                	jne    800b81 <strtol+0x58>
  800b71:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b75:	75 7c                	jne    800bf3 <strtol+0xca>
		s += 2, base = 16;
  800b77:	83 c1 02             	add    $0x2,%ecx
  800b7a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b7f:	eb 16                	jmp    800b97 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b81:	85 db                	test   %ebx,%ebx
  800b83:	75 12                	jne    800b97 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b85:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b8a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b8d:	75 08                	jne    800b97 <strtol+0x6e>
		s++, base = 8;
  800b8f:	83 c1 01             	add    $0x1,%ecx
  800b92:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b97:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b9f:	0f b6 11             	movzbl (%ecx),%edx
  800ba2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ba5:	89 f3                	mov    %esi,%ebx
  800ba7:	80 fb 09             	cmp    $0x9,%bl
  800baa:	77 08                	ja     800bb4 <strtol+0x8b>
			dig = *s - '0';
  800bac:	0f be d2             	movsbl %dl,%edx
  800baf:	83 ea 30             	sub    $0x30,%edx
  800bb2:	eb 22                	jmp    800bd6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bb4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bb7:	89 f3                	mov    %esi,%ebx
  800bb9:	80 fb 19             	cmp    $0x19,%bl
  800bbc:	77 08                	ja     800bc6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bbe:	0f be d2             	movsbl %dl,%edx
  800bc1:	83 ea 57             	sub    $0x57,%edx
  800bc4:	eb 10                	jmp    800bd6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bc6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bc9:	89 f3                	mov    %esi,%ebx
  800bcb:	80 fb 19             	cmp    $0x19,%bl
  800bce:	77 16                	ja     800be6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bd0:	0f be d2             	movsbl %dl,%edx
  800bd3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bd6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bd9:	7d 0b                	jge    800be6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bdb:	83 c1 01             	add    $0x1,%ecx
  800bde:	0f af 45 10          	imul   0x10(%ebp),%eax
  800be2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800be4:	eb b9                	jmp    800b9f <strtol+0x76>

	if (endptr)
  800be6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bea:	74 0d                	je     800bf9 <strtol+0xd0>
		*endptr = (char *) s;
  800bec:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bef:	89 0e                	mov    %ecx,(%esi)
  800bf1:	eb 06                	jmp    800bf9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bf3:	85 db                	test   %ebx,%ebx
  800bf5:	74 98                	je     800b8f <strtol+0x66>
  800bf7:	eb 9e                	jmp    800b97 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bf9:	89 c2                	mov    %eax,%edx
  800bfb:	f7 da                	neg    %edx
  800bfd:	85 ff                	test   %edi,%edi
  800bff:	0f 45 c2             	cmovne %edx,%eax
}
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c15:	8b 55 08             	mov    0x8(%ebp),%edx
  800c18:	89 c3                	mov    %eax,%ebx
  800c1a:	89 c7                	mov    %eax,%edi
  800c1c:	89 c6                	mov    %eax,%esi
  800c1e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c30:	b8 01 00 00 00       	mov    $0x1,%eax
  800c35:	89 d1                	mov    %edx,%ecx
  800c37:	89 d3                	mov    %edx,%ebx
  800c39:	89 d7                	mov    %edx,%edi
  800c3b:	89 d6                	mov    %edx,%esi
  800c3d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
  800c4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c52:	b8 03 00 00 00       	mov    $0x3,%eax
  800c57:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5a:	89 cb                	mov    %ecx,%ebx
  800c5c:	89 cf                	mov    %ecx,%edi
  800c5e:	89 ce                	mov    %ecx,%esi
  800c60:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c62:	85 c0                	test   %eax,%eax
  800c64:	7e 17                	jle    800c7d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c66:	83 ec 0c             	sub    $0xc,%esp
  800c69:	50                   	push   %eax
  800c6a:	6a 03                	push   $0x3
  800c6c:	68 48 14 80 00       	push   $0x801448
  800c71:	6a 23                	push   $0x23
  800c73:	68 65 14 80 00       	push   $0x801465
  800c78:	e8 ce f5 ff ff       	call   80024b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c90:	b8 02 00 00 00       	mov    $0x2,%eax
  800c95:	89 d1                	mov    %edx,%ecx
  800c97:	89 d3                	mov    %edx,%ebx
  800c99:	89 d7                	mov    %edx,%edi
  800c9b:	89 d6                	mov    %edx,%esi
  800c9d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <sys_yield>:

void
sys_yield(void)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caa:	ba 00 00 00 00       	mov    $0x0,%edx
  800caf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cb4:	89 d1                	mov    %edx,%ecx
  800cb6:	89 d3                	mov    %edx,%ebx
  800cb8:	89 d7                	mov    %edx,%edi
  800cba:	89 d6                	mov    %edx,%esi
  800cbc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccc:	be 00 00 00 00       	mov    $0x0,%esi
  800cd1:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdf:	89 f7                	mov    %esi,%edi
  800ce1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 17                	jle    800cfe <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	83 ec 0c             	sub    $0xc,%esp
  800cea:	50                   	push   %eax
  800ceb:	6a 04                	push   $0x4
  800ced:	68 48 14 80 00       	push   $0x801448
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 65 14 80 00       	push   $0x801465
  800cf9:	e8 4d f5 ff ff       	call   80024b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0f:	b8 05 00 00 00       	mov    $0x5,%eax
  800d14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d20:	8b 75 18             	mov    0x18(%ebp),%esi
  800d23:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d25:	85 c0                	test   %eax,%eax
  800d27:	7e 17                	jle    800d40 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d29:	83 ec 0c             	sub    $0xc,%esp
  800d2c:	50                   	push   %eax
  800d2d:	6a 05                	push   $0x5
  800d2f:	68 48 14 80 00       	push   $0x801448
  800d34:	6a 23                	push   $0x23
  800d36:	68 65 14 80 00       	push   $0x801465
  800d3b:	e8 0b f5 ff ff       	call   80024b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	57                   	push   %edi
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
  800d4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d56:	b8 06 00 00 00       	mov    $0x6,%eax
  800d5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d61:	89 df                	mov    %ebx,%edi
  800d63:	89 de                	mov    %ebx,%esi
  800d65:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d67:	85 c0                	test   %eax,%eax
  800d69:	7e 17                	jle    800d82 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6b:	83 ec 0c             	sub    $0xc,%esp
  800d6e:	50                   	push   %eax
  800d6f:	6a 06                	push   $0x6
  800d71:	68 48 14 80 00       	push   $0x801448
  800d76:	6a 23                	push   $0x23
  800d78:	68 65 14 80 00       	push   $0x801465
  800d7d:	e8 c9 f4 ff ff       	call   80024b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
  800d90:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d98:	b8 08 00 00 00       	mov    $0x8,%eax
  800d9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da0:	8b 55 08             	mov    0x8(%ebp),%edx
  800da3:	89 df                	mov    %ebx,%edi
  800da5:	89 de                	mov    %ebx,%esi
  800da7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da9:	85 c0                	test   %eax,%eax
  800dab:	7e 17                	jle    800dc4 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dad:	83 ec 0c             	sub    $0xc,%esp
  800db0:	50                   	push   %eax
  800db1:	6a 08                	push   $0x8
  800db3:	68 48 14 80 00       	push   $0x801448
  800db8:	6a 23                	push   $0x23
  800dba:	68 65 14 80 00       	push   $0x801465
  800dbf:	e8 87 f4 ff ff       	call   80024b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc7:	5b                   	pop    %ebx
  800dc8:	5e                   	pop    %esi
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	57                   	push   %edi
  800dd0:	56                   	push   %esi
  800dd1:	53                   	push   %ebx
  800dd2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dda:	b8 09 00 00 00       	mov    $0x9,%eax
  800ddf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de2:	8b 55 08             	mov    0x8(%ebp),%edx
  800de5:	89 df                	mov    %ebx,%edi
  800de7:	89 de                	mov    %ebx,%esi
  800de9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800deb:	85 c0                	test   %eax,%eax
  800ded:	7e 17                	jle    800e06 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800def:	83 ec 0c             	sub    $0xc,%esp
  800df2:	50                   	push   %eax
  800df3:	6a 09                	push   $0x9
  800df5:	68 48 14 80 00       	push   $0x801448
  800dfa:	6a 23                	push   $0x23
  800dfc:	68 65 14 80 00       	push   $0x801465
  800e01:	e8 45 f4 ff ff       	call   80024b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e09:	5b                   	pop    %ebx
  800e0a:	5e                   	pop    %esi
  800e0b:	5f                   	pop    %edi
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    

00800e0e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e14:	be 00 00 00 00       	mov    $0x0,%esi
  800e19:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e21:	8b 55 08             	mov    0x8(%ebp),%edx
  800e24:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e27:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e2a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e2c:	5b                   	pop    %ebx
  800e2d:	5e                   	pop    %esi
  800e2e:	5f                   	pop    %edi
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    

00800e31 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	57                   	push   %edi
  800e35:	56                   	push   %esi
  800e36:	53                   	push   %ebx
  800e37:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e3f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e44:	8b 55 08             	mov    0x8(%ebp),%edx
  800e47:	89 cb                	mov    %ecx,%ebx
  800e49:	89 cf                	mov    %ecx,%edi
  800e4b:	89 ce                	mov    %ecx,%esi
  800e4d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	7e 17                	jle    800e6a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e53:	83 ec 0c             	sub    $0xc,%esp
  800e56:	50                   	push   %eax
  800e57:	6a 0c                	push   $0xc
  800e59:	68 48 14 80 00       	push   $0x801448
  800e5e:	6a 23                	push   $0x23
  800e60:	68 65 14 80 00       	push   $0x801465
  800e65:	e8 e1 f3 ff ff       	call   80024b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6d:	5b                   	pop    %ebx
  800e6e:	5e                   	pop    %esi
  800e6f:	5f                   	pop    %edi
  800e70:	5d                   	pop    %ebp
  800e71:	c3                   	ret    
  800e72:	66 90                	xchg   %ax,%ax
  800e74:	66 90                	xchg   %ax,%ax
  800e76:	66 90                	xchg   %ax,%ax
  800e78:	66 90                	xchg   %ax,%ax
  800e7a:	66 90                	xchg   %ax,%ax
  800e7c:	66 90                	xchg   %ax,%ax
  800e7e:	66 90                	xchg   %ax,%ax

00800e80 <__udivdi3>:
  800e80:	55                   	push   %ebp
  800e81:	57                   	push   %edi
  800e82:	56                   	push   %esi
  800e83:	53                   	push   %ebx
  800e84:	83 ec 1c             	sub    $0x1c,%esp
  800e87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800e8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800e8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800e93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e97:	85 f6                	test   %esi,%esi
  800e99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e9d:	89 ca                	mov    %ecx,%edx
  800e9f:	89 f8                	mov    %edi,%eax
  800ea1:	75 3d                	jne    800ee0 <__udivdi3+0x60>
  800ea3:	39 cf                	cmp    %ecx,%edi
  800ea5:	0f 87 c5 00 00 00    	ja     800f70 <__udivdi3+0xf0>
  800eab:	85 ff                	test   %edi,%edi
  800ead:	89 fd                	mov    %edi,%ebp
  800eaf:	75 0b                	jne    800ebc <__udivdi3+0x3c>
  800eb1:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb6:	31 d2                	xor    %edx,%edx
  800eb8:	f7 f7                	div    %edi
  800eba:	89 c5                	mov    %eax,%ebp
  800ebc:	89 c8                	mov    %ecx,%eax
  800ebe:	31 d2                	xor    %edx,%edx
  800ec0:	f7 f5                	div    %ebp
  800ec2:	89 c1                	mov    %eax,%ecx
  800ec4:	89 d8                	mov    %ebx,%eax
  800ec6:	89 cf                	mov    %ecx,%edi
  800ec8:	f7 f5                	div    %ebp
  800eca:	89 c3                	mov    %eax,%ebx
  800ecc:	89 d8                	mov    %ebx,%eax
  800ece:	89 fa                	mov    %edi,%edx
  800ed0:	83 c4 1c             	add    $0x1c,%esp
  800ed3:	5b                   	pop    %ebx
  800ed4:	5e                   	pop    %esi
  800ed5:	5f                   	pop    %edi
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    
  800ed8:	90                   	nop
  800ed9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ee0:	39 ce                	cmp    %ecx,%esi
  800ee2:	77 74                	ja     800f58 <__udivdi3+0xd8>
  800ee4:	0f bd fe             	bsr    %esi,%edi
  800ee7:	83 f7 1f             	xor    $0x1f,%edi
  800eea:	0f 84 98 00 00 00    	je     800f88 <__udivdi3+0x108>
  800ef0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800ef5:	89 f9                	mov    %edi,%ecx
  800ef7:	89 c5                	mov    %eax,%ebp
  800ef9:	29 fb                	sub    %edi,%ebx
  800efb:	d3 e6                	shl    %cl,%esi
  800efd:	89 d9                	mov    %ebx,%ecx
  800eff:	d3 ed                	shr    %cl,%ebp
  800f01:	89 f9                	mov    %edi,%ecx
  800f03:	d3 e0                	shl    %cl,%eax
  800f05:	09 ee                	or     %ebp,%esi
  800f07:	89 d9                	mov    %ebx,%ecx
  800f09:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f0d:	89 d5                	mov    %edx,%ebp
  800f0f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f13:	d3 ed                	shr    %cl,%ebp
  800f15:	89 f9                	mov    %edi,%ecx
  800f17:	d3 e2                	shl    %cl,%edx
  800f19:	89 d9                	mov    %ebx,%ecx
  800f1b:	d3 e8                	shr    %cl,%eax
  800f1d:	09 c2                	or     %eax,%edx
  800f1f:	89 d0                	mov    %edx,%eax
  800f21:	89 ea                	mov    %ebp,%edx
  800f23:	f7 f6                	div    %esi
  800f25:	89 d5                	mov    %edx,%ebp
  800f27:	89 c3                	mov    %eax,%ebx
  800f29:	f7 64 24 0c          	mull   0xc(%esp)
  800f2d:	39 d5                	cmp    %edx,%ebp
  800f2f:	72 10                	jb     800f41 <__udivdi3+0xc1>
  800f31:	8b 74 24 08          	mov    0x8(%esp),%esi
  800f35:	89 f9                	mov    %edi,%ecx
  800f37:	d3 e6                	shl    %cl,%esi
  800f39:	39 c6                	cmp    %eax,%esi
  800f3b:	73 07                	jae    800f44 <__udivdi3+0xc4>
  800f3d:	39 d5                	cmp    %edx,%ebp
  800f3f:	75 03                	jne    800f44 <__udivdi3+0xc4>
  800f41:	83 eb 01             	sub    $0x1,%ebx
  800f44:	31 ff                	xor    %edi,%edi
  800f46:	89 d8                	mov    %ebx,%eax
  800f48:	89 fa                	mov    %edi,%edx
  800f4a:	83 c4 1c             	add    $0x1c,%esp
  800f4d:	5b                   	pop    %ebx
  800f4e:	5e                   	pop    %esi
  800f4f:	5f                   	pop    %edi
  800f50:	5d                   	pop    %ebp
  800f51:	c3                   	ret    
  800f52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f58:	31 ff                	xor    %edi,%edi
  800f5a:	31 db                	xor    %ebx,%ebx
  800f5c:	89 d8                	mov    %ebx,%eax
  800f5e:	89 fa                	mov    %edi,%edx
  800f60:	83 c4 1c             	add    $0x1c,%esp
  800f63:	5b                   	pop    %ebx
  800f64:	5e                   	pop    %esi
  800f65:	5f                   	pop    %edi
  800f66:	5d                   	pop    %ebp
  800f67:	c3                   	ret    
  800f68:	90                   	nop
  800f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f70:	89 d8                	mov    %ebx,%eax
  800f72:	f7 f7                	div    %edi
  800f74:	31 ff                	xor    %edi,%edi
  800f76:	89 c3                	mov    %eax,%ebx
  800f78:	89 d8                	mov    %ebx,%eax
  800f7a:	89 fa                	mov    %edi,%edx
  800f7c:	83 c4 1c             	add    $0x1c,%esp
  800f7f:	5b                   	pop    %ebx
  800f80:	5e                   	pop    %esi
  800f81:	5f                   	pop    %edi
  800f82:	5d                   	pop    %ebp
  800f83:	c3                   	ret    
  800f84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f88:	39 ce                	cmp    %ecx,%esi
  800f8a:	72 0c                	jb     800f98 <__udivdi3+0x118>
  800f8c:	31 db                	xor    %ebx,%ebx
  800f8e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800f92:	0f 87 34 ff ff ff    	ja     800ecc <__udivdi3+0x4c>
  800f98:	bb 01 00 00 00       	mov    $0x1,%ebx
  800f9d:	e9 2a ff ff ff       	jmp    800ecc <__udivdi3+0x4c>
  800fa2:	66 90                	xchg   %ax,%ax
  800fa4:	66 90                	xchg   %ax,%ax
  800fa6:	66 90                	xchg   %ax,%ax
  800fa8:	66 90                	xchg   %ax,%ax
  800faa:	66 90                	xchg   %ax,%ax
  800fac:	66 90                	xchg   %ax,%ax
  800fae:	66 90                	xchg   %ax,%ax

00800fb0 <__umoddi3>:
  800fb0:	55                   	push   %ebp
  800fb1:	57                   	push   %edi
  800fb2:	56                   	push   %esi
  800fb3:	53                   	push   %ebx
  800fb4:	83 ec 1c             	sub    $0x1c,%esp
  800fb7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800fbb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800fbf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800fc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800fc7:	85 d2                	test   %edx,%edx
  800fc9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800fcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fd1:	89 f3                	mov    %esi,%ebx
  800fd3:	89 3c 24             	mov    %edi,(%esp)
  800fd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fda:	75 1c                	jne    800ff8 <__umoddi3+0x48>
  800fdc:	39 f7                	cmp    %esi,%edi
  800fde:	76 50                	jbe    801030 <__umoddi3+0x80>
  800fe0:	89 c8                	mov    %ecx,%eax
  800fe2:	89 f2                	mov    %esi,%edx
  800fe4:	f7 f7                	div    %edi
  800fe6:	89 d0                	mov    %edx,%eax
  800fe8:	31 d2                	xor    %edx,%edx
  800fea:	83 c4 1c             	add    $0x1c,%esp
  800fed:	5b                   	pop    %ebx
  800fee:	5e                   	pop    %esi
  800fef:	5f                   	pop    %edi
  800ff0:	5d                   	pop    %ebp
  800ff1:	c3                   	ret    
  800ff2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ff8:	39 f2                	cmp    %esi,%edx
  800ffa:	89 d0                	mov    %edx,%eax
  800ffc:	77 52                	ja     801050 <__umoddi3+0xa0>
  800ffe:	0f bd ea             	bsr    %edx,%ebp
  801001:	83 f5 1f             	xor    $0x1f,%ebp
  801004:	75 5a                	jne    801060 <__umoddi3+0xb0>
  801006:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80100a:	0f 82 e0 00 00 00    	jb     8010f0 <__umoddi3+0x140>
  801010:	39 0c 24             	cmp    %ecx,(%esp)
  801013:	0f 86 d7 00 00 00    	jbe    8010f0 <__umoddi3+0x140>
  801019:	8b 44 24 08          	mov    0x8(%esp),%eax
  80101d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801021:	83 c4 1c             	add    $0x1c,%esp
  801024:	5b                   	pop    %ebx
  801025:	5e                   	pop    %esi
  801026:	5f                   	pop    %edi
  801027:	5d                   	pop    %ebp
  801028:	c3                   	ret    
  801029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801030:	85 ff                	test   %edi,%edi
  801032:	89 fd                	mov    %edi,%ebp
  801034:	75 0b                	jne    801041 <__umoddi3+0x91>
  801036:	b8 01 00 00 00       	mov    $0x1,%eax
  80103b:	31 d2                	xor    %edx,%edx
  80103d:	f7 f7                	div    %edi
  80103f:	89 c5                	mov    %eax,%ebp
  801041:	89 f0                	mov    %esi,%eax
  801043:	31 d2                	xor    %edx,%edx
  801045:	f7 f5                	div    %ebp
  801047:	89 c8                	mov    %ecx,%eax
  801049:	f7 f5                	div    %ebp
  80104b:	89 d0                	mov    %edx,%eax
  80104d:	eb 99                	jmp    800fe8 <__umoddi3+0x38>
  80104f:	90                   	nop
  801050:	89 c8                	mov    %ecx,%eax
  801052:	89 f2                	mov    %esi,%edx
  801054:	83 c4 1c             	add    $0x1c,%esp
  801057:	5b                   	pop    %ebx
  801058:	5e                   	pop    %esi
  801059:	5f                   	pop    %edi
  80105a:	5d                   	pop    %ebp
  80105b:	c3                   	ret    
  80105c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801060:	8b 34 24             	mov    (%esp),%esi
  801063:	bf 20 00 00 00       	mov    $0x20,%edi
  801068:	89 e9                	mov    %ebp,%ecx
  80106a:	29 ef                	sub    %ebp,%edi
  80106c:	d3 e0                	shl    %cl,%eax
  80106e:	89 f9                	mov    %edi,%ecx
  801070:	89 f2                	mov    %esi,%edx
  801072:	d3 ea                	shr    %cl,%edx
  801074:	89 e9                	mov    %ebp,%ecx
  801076:	09 c2                	or     %eax,%edx
  801078:	89 d8                	mov    %ebx,%eax
  80107a:	89 14 24             	mov    %edx,(%esp)
  80107d:	89 f2                	mov    %esi,%edx
  80107f:	d3 e2                	shl    %cl,%edx
  801081:	89 f9                	mov    %edi,%ecx
  801083:	89 54 24 04          	mov    %edx,0x4(%esp)
  801087:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80108b:	d3 e8                	shr    %cl,%eax
  80108d:	89 e9                	mov    %ebp,%ecx
  80108f:	89 c6                	mov    %eax,%esi
  801091:	d3 e3                	shl    %cl,%ebx
  801093:	89 f9                	mov    %edi,%ecx
  801095:	89 d0                	mov    %edx,%eax
  801097:	d3 e8                	shr    %cl,%eax
  801099:	89 e9                	mov    %ebp,%ecx
  80109b:	09 d8                	or     %ebx,%eax
  80109d:	89 d3                	mov    %edx,%ebx
  80109f:	89 f2                	mov    %esi,%edx
  8010a1:	f7 34 24             	divl   (%esp)
  8010a4:	89 d6                	mov    %edx,%esi
  8010a6:	d3 e3                	shl    %cl,%ebx
  8010a8:	f7 64 24 04          	mull   0x4(%esp)
  8010ac:	39 d6                	cmp    %edx,%esi
  8010ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010b2:	89 d1                	mov    %edx,%ecx
  8010b4:	89 c3                	mov    %eax,%ebx
  8010b6:	72 08                	jb     8010c0 <__umoddi3+0x110>
  8010b8:	75 11                	jne    8010cb <__umoddi3+0x11b>
  8010ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8010be:	73 0b                	jae    8010cb <__umoddi3+0x11b>
  8010c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8010c4:	1b 14 24             	sbb    (%esp),%edx
  8010c7:	89 d1                	mov    %edx,%ecx
  8010c9:	89 c3                	mov    %eax,%ebx
  8010cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8010cf:	29 da                	sub    %ebx,%edx
  8010d1:	19 ce                	sbb    %ecx,%esi
  8010d3:	89 f9                	mov    %edi,%ecx
  8010d5:	89 f0                	mov    %esi,%eax
  8010d7:	d3 e0                	shl    %cl,%eax
  8010d9:	89 e9                	mov    %ebp,%ecx
  8010db:	d3 ea                	shr    %cl,%edx
  8010dd:	89 e9                	mov    %ebp,%ecx
  8010df:	d3 ee                	shr    %cl,%esi
  8010e1:	09 d0                	or     %edx,%eax
  8010e3:	89 f2                	mov    %esi,%edx
  8010e5:	83 c4 1c             	add    $0x1c,%esp
  8010e8:	5b                   	pop    %ebx
  8010e9:	5e                   	pop    %esi
  8010ea:	5f                   	pop    %edi
  8010eb:	5d                   	pop    %ebp
  8010ec:	c3                   	ret    
  8010ed:	8d 76 00             	lea    0x0(%esi),%esi
  8010f0:	29 f9                	sub    %edi,%ecx
  8010f2:	19 d6                	sbb    %edx,%esi
  8010f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010fc:	e9 18 ff ff ff       	jmp    801019 <__umoddi3+0x69>
