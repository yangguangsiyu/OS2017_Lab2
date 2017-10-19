
obj/user/faultallocbad：     文件格式 elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 60 10 80 00       	push   $0x801060
  800045:	e8 9c 01 00 00       	call   8001e6 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 27 0b 00 00       	call   800b85 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 80 10 80 00       	push   $0x801080
  80006f:	6a 0f                	push   $0xf
  800071:	68 6a 10 80 00       	push   $0x80106a
  800076:	e8 92 00 00 00       	call   80010d <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 ac 10 80 00       	push   $0x8010ac
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 a6 06 00 00       	call   80072f <snprintf>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 93 0c 00 00       	call   800d34 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 19 0a 00 00       	call   800ac9 <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000c0:	e8 82 0a 00 00       	call   800b47 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 a5 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800101:	6a 00                	push   $0x0
  800103:	e8 fe 09 00 00       	call   800b06 <sys_env_destroy>
}
  800108:	83 c4 10             	add    $0x10,%esp
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800112:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800115:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80011b:	e8 27 0a 00 00       	call   800b47 <sys_getenvid>
  800120:	83 ec 0c             	sub    $0xc,%esp
  800123:	ff 75 0c             	pushl  0xc(%ebp)
  800126:	ff 75 08             	pushl  0x8(%ebp)
  800129:	56                   	push   %esi
  80012a:	50                   	push   %eax
  80012b:	68 d8 10 80 00       	push   $0x8010d8
  800130:	e8 b1 00 00 00       	call   8001e6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800135:	83 c4 18             	add    $0x18,%esp
  800138:	53                   	push   %ebx
  800139:	ff 75 10             	pushl  0x10(%ebp)
  80013c:	e8 54 00 00 00       	call   800195 <vcprintf>
	cprintf("\n");
  800141:	c7 04 24 68 10 80 00 	movl   $0x801068,(%esp)
  800148:	e8 99 00 00 00       	call   8001e6 <cprintf>
  80014d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800150:	cc                   	int3   
  800151:	eb fd                	jmp    800150 <_panic+0x43>

00800153 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	53                   	push   %ebx
  800157:	83 ec 04             	sub    $0x4,%esp
  80015a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80015d:	8b 13                	mov    (%ebx),%edx
  80015f:	8d 42 01             	lea    0x1(%edx),%eax
  800162:	89 03                	mov    %eax,(%ebx)
  800164:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800167:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80016b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800170:	75 1a                	jne    80018c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800172:	83 ec 08             	sub    $0x8,%esp
  800175:	68 ff 00 00 00       	push   $0xff
  80017a:	8d 43 08             	lea    0x8(%ebx),%eax
  80017d:	50                   	push   %eax
  80017e:	e8 46 09 00 00       	call   800ac9 <sys_cputs>
		b->idx = 0;
  800183:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800189:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80018c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800190:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800193:	c9                   	leave  
  800194:	c3                   	ret    

00800195 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80019e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001a5:	00 00 00 
	b.cnt = 0;
  8001a8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001af:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b2:	ff 75 0c             	pushl  0xc(%ebp)
  8001b5:	ff 75 08             	pushl  0x8(%ebp)
  8001b8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001be:	50                   	push   %eax
  8001bf:	68 53 01 80 00       	push   $0x800153
  8001c4:	e8 54 01 00 00       	call   80031d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001c9:	83 c4 08             	add    $0x8,%esp
  8001cc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001d2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001d8:	50                   	push   %eax
  8001d9:	e8 eb 08 00 00       	call   800ac9 <sys_cputs>

	return b.cnt;
}
  8001de:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    

008001e6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ec:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ef:	50                   	push   %eax
  8001f0:	ff 75 08             	pushl  0x8(%ebp)
  8001f3:	e8 9d ff ff ff       	call   800195 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001f8:	c9                   	leave  
  8001f9:	c3                   	ret    

008001fa <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001fa:	55                   	push   %ebp
  8001fb:	89 e5                	mov    %esp,%ebp
  8001fd:	57                   	push   %edi
  8001fe:	56                   	push   %esi
  8001ff:	53                   	push   %ebx
  800200:	83 ec 1c             	sub    $0x1c,%esp
  800203:	89 c7                	mov    %eax,%edi
  800205:	89 d6                	mov    %edx,%esi
  800207:	8b 45 08             	mov    0x8(%ebp),%eax
  80020a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80020d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800210:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800213:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800216:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80021e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800221:	39 d3                	cmp    %edx,%ebx
  800223:	72 05                	jb     80022a <printnum+0x30>
  800225:	39 45 10             	cmp    %eax,0x10(%ebp)
  800228:	77 45                	ja     80026f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80022a:	83 ec 0c             	sub    $0xc,%esp
  80022d:	ff 75 18             	pushl  0x18(%ebp)
  800230:	8b 45 14             	mov    0x14(%ebp),%eax
  800233:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800236:	53                   	push   %ebx
  800237:	ff 75 10             	pushl  0x10(%ebp)
  80023a:	83 ec 08             	sub    $0x8,%esp
  80023d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800240:	ff 75 e0             	pushl  -0x20(%ebp)
  800243:	ff 75 dc             	pushl  -0x24(%ebp)
  800246:	ff 75 d8             	pushl  -0x28(%ebp)
  800249:	e8 72 0b 00 00       	call   800dc0 <__udivdi3>
  80024e:	83 c4 18             	add    $0x18,%esp
  800251:	52                   	push   %edx
  800252:	50                   	push   %eax
  800253:	89 f2                	mov    %esi,%edx
  800255:	89 f8                	mov    %edi,%eax
  800257:	e8 9e ff ff ff       	call   8001fa <printnum>
  80025c:	83 c4 20             	add    $0x20,%esp
  80025f:	eb 18                	jmp    800279 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800261:	83 ec 08             	sub    $0x8,%esp
  800264:	56                   	push   %esi
  800265:	ff 75 18             	pushl  0x18(%ebp)
  800268:	ff d7                	call   *%edi
  80026a:	83 c4 10             	add    $0x10,%esp
  80026d:	eb 03                	jmp    800272 <printnum+0x78>
  80026f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800272:	83 eb 01             	sub    $0x1,%ebx
  800275:	85 db                	test   %ebx,%ebx
  800277:	7f e8                	jg     800261 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800279:	83 ec 08             	sub    $0x8,%esp
  80027c:	56                   	push   %esi
  80027d:	83 ec 04             	sub    $0x4,%esp
  800280:	ff 75 e4             	pushl  -0x1c(%ebp)
  800283:	ff 75 e0             	pushl  -0x20(%ebp)
  800286:	ff 75 dc             	pushl  -0x24(%ebp)
  800289:	ff 75 d8             	pushl  -0x28(%ebp)
  80028c:	e8 5f 0c 00 00       	call   800ef0 <__umoddi3>
  800291:	83 c4 14             	add    $0x14,%esp
  800294:	0f be 80 fb 10 80 00 	movsbl 0x8010fb(%eax),%eax
  80029b:	50                   	push   %eax
  80029c:	ff d7                	call   *%edi
}
  80029e:	83 c4 10             	add    $0x10,%esp
  8002a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a4:	5b                   	pop    %ebx
  8002a5:	5e                   	pop    %esi
  8002a6:	5f                   	pop    %edi
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ac:	83 fa 01             	cmp    $0x1,%edx
  8002af:	7e 0e                	jle    8002bf <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b1:	8b 10                	mov    (%eax),%edx
  8002b3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b6:	89 08                	mov    %ecx,(%eax)
  8002b8:	8b 02                	mov    (%edx),%eax
  8002ba:	8b 52 04             	mov    0x4(%edx),%edx
  8002bd:	eb 22                	jmp    8002e1 <getuint+0x38>
	else if (lflag)
  8002bf:	85 d2                	test   %edx,%edx
  8002c1:	74 10                	je     8002d3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c3:	8b 10                	mov    (%eax),%edx
  8002c5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c8:	89 08                	mov    %ecx,(%eax)
  8002ca:	8b 02                	mov    (%edx),%eax
  8002cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d1:	eb 0e                	jmp    8002e1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d3:	8b 10                	mov    (%eax),%edx
  8002d5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d8:	89 08                	mov    %ecx,(%eax)
  8002da:	8b 02                	mov    (%edx),%eax
  8002dc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ed:	8b 10                	mov    (%eax),%edx
  8002ef:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f2:	73 0a                	jae    8002fe <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002f7:	89 08                	mov    %ecx,(%eax)
  8002f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fc:	88 02                	mov    %al,(%edx)
}
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    

00800300 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800306:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800309:	50                   	push   %eax
  80030a:	ff 75 10             	pushl  0x10(%ebp)
  80030d:	ff 75 0c             	pushl  0xc(%ebp)
  800310:	ff 75 08             	pushl  0x8(%ebp)
  800313:	e8 05 00 00 00       	call   80031d <vprintfmt>
	va_end(ap);
}
  800318:	83 c4 10             	add    $0x10,%esp
  80031b:	c9                   	leave  
  80031c:	c3                   	ret    

0080031d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	57                   	push   %edi
  800321:	56                   	push   %esi
  800322:	53                   	push   %ebx
  800323:	83 ec 2c             	sub    $0x2c,%esp
  800326:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
  800329:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800330:	eb 17                	jmp    800349 <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800332:	85 c0                	test   %eax,%eax
  800334:	0f 84 9f 03 00 00    	je     8006d9 <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
  80033a:	83 ec 08             	sub    $0x8,%esp
  80033d:	ff 75 0c             	pushl  0xc(%ebp)
  800340:	50                   	push   %eax
  800341:	ff 55 08             	call   *0x8(%ebp)
  800344:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800347:	89 f3                	mov    %esi,%ebx
  800349:	8d 73 01             	lea    0x1(%ebx),%esi
  80034c:	0f b6 03             	movzbl (%ebx),%eax
  80034f:	83 f8 25             	cmp    $0x25,%eax
  800352:	75 de                	jne    800332 <vprintfmt+0x15>
  800354:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800358:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80035f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800364:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80036b:	ba 00 00 00 00       	mov    $0x0,%edx
  800370:	eb 06                	jmp    800378 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800372:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800374:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800378:	8d 5e 01             	lea    0x1(%esi),%ebx
  80037b:	0f b6 06             	movzbl (%esi),%eax
  80037e:	0f b6 c8             	movzbl %al,%ecx
  800381:	83 e8 23             	sub    $0x23,%eax
  800384:	3c 55                	cmp    $0x55,%al
  800386:	0f 87 2d 03 00 00    	ja     8006b9 <vprintfmt+0x39c>
  80038c:	0f b6 c0             	movzbl %al,%eax
  80038f:	ff 24 85 c0 11 80 00 	jmp    *0x8011c0(,%eax,4)
  800396:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800398:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80039c:	eb da                	jmp    800378 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	89 de                	mov    %ebx,%esi
  8003a0:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a5:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  8003a8:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  8003ac:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  8003af:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8003b2:	83 f8 09             	cmp    $0x9,%eax
  8003b5:	77 33                	ja     8003ea <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ba:	eb e9                	jmp    8003a5 <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bf:	8d 48 04             	lea    0x4(%eax),%ecx
  8003c2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003c5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c9:	eb 1f                	jmp    8003ea <vprintfmt+0xcd>
  8003cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ce:	85 c0                	test   %eax,%eax
  8003d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d5:	0f 49 c8             	cmovns %eax,%ecx
  8003d8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	89 de                	mov    %ebx,%esi
  8003dd:	eb 99                	jmp    800378 <vprintfmt+0x5b>
  8003df:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003e1:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  8003e8:	eb 8e                	jmp    800378 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8003ea:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ee:	79 88                	jns    800378 <vprintfmt+0x5b>
				width = precision, precision = -1;
  8003f0:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8003f3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003f8:	e9 7b ff ff ff       	jmp    800378 <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003fd:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800402:	e9 71 ff ff ff       	jmp    800378 <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
  800407:	8b 45 14             	mov    0x14(%ebp),%eax
  80040a:	8d 50 04             	lea    0x4(%eax),%edx
  80040d:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  800410:	83 ec 08             	sub    $0x8,%esp
  800413:	ff 75 0c             	pushl  0xc(%ebp)
  800416:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800419:	03 08                	add    (%eax),%ecx
  80041b:	51                   	push   %ecx
  80041c:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
  80041f:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
  800422:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
  800429:	e9 1b ff ff ff       	jmp    800349 <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8d 48 04             	lea    0x4(%eax),%ecx
  800434:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800437:	8b 00                	mov    (%eax),%eax
  800439:	83 f8 02             	cmp    $0x2,%eax
  80043c:	74 1a                	je     800458 <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043e:	89 de                	mov    %ebx,%esi
  800440:	83 f8 04             	cmp    $0x4,%eax
  800443:	b8 00 00 00 00       	mov    $0x0,%eax
  800448:	b9 00 04 00 00       	mov    $0x400,%ecx
  80044d:	0f 44 c1             	cmove  %ecx,%eax
  800450:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800453:	e9 20 ff ff ff       	jmp    800378 <vprintfmt+0x5b>
  800458:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
  80045a:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
  800461:	e9 12 ff ff ff       	jmp    800378 <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800466:	8b 45 14             	mov    0x14(%ebp),%eax
  800469:	8d 50 04             	lea    0x4(%eax),%edx
  80046c:	89 55 14             	mov    %edx,0x14(%ebp)
  80046f:	8b 00                	mov    (%eax),%eax
  800471:	99                   	cltd   
  800472:	31 d0                	xor    %edx,%eax
  800474:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800476:	83 f8 09             	cmp    $0x9,%eax
  800479:	7f 0b                	jg     800486 <vprintfmt+0x169>
  80047b:	8b 14 85 20 13 80 00 	mov    0x801320(,%eax,4),%edx
  800482:	85 d2                	test   %edx,%edx
  800484:	75 19                	jne    80049f <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800486:	50                   	push   %eax
  800487:	68 13 11 80 00       	push   $0x801113
  80048c:	ff 75 0c             	pushl  0xc(%ebp)
  80048f:	ff 75 08             	pushl  0x8(%ebp)
  800492:	e8 69 fe ff ff       	call   800300 <printfmt>
  800497:	83 c4 10             	add    $0x10,%esp
  80049a:	e9 aa fe ff ff       	jmp    800349 <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  80049f:	52                   	push   %edx
  8004a0:	68 1c 11 80 00       	push   $0x80111c
  8004a5:	ff 75 0c             	pushl  0xc(%ebp)
  8004a8:	ff 75 08             	pushl  0x8(%ebp)
  8004ab:	e8 50 fe ff ff       	call   800300 <printfmt>
  8004b0:	83 c4 10             	add    $0x10,%esp
  8004b3:	e9 91 fe ff ff       	jmp    800349 <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bb:	8d 50 04             	lea    0x4(%eax),%edx
  8004be:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004c3:	85 f6                	test   %esi,%esi
  8004c5:	b8 0c 11 80 00       	mov    $0x80110c,%eax
  8004ca:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8004cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d1:	0f 8e 93 00 00 00    	jle    80056a <vprintfmt+0x24d>
  8004d7:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004db:	0f 84 91 00 00 00    	je     800572 <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e1:	83 ec 08             	sub    $0x8,%esp
  8004e4:	57                   	push   %edi
  8004e5:	56                   	push   %esi
  8004e6:	e8 76 02 00 00       	call   800761 <strnlen>
  8004eb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ee:	29 c1                	sub    %eax,%ecx
  8004f0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004f3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004f6:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8004fa:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004fd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800500:	8b 75 0c             	mov    0xc(%ebp),%esi
  800503:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800506:	89 cb                	mov    %ecx,%ebx
  800508:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050a:	eb 0e                	jmp    80051a <vprintfmt+0x1fd>
					putch(padc, putdat);
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	56                   	push   %esi
  800510:	57                   	push   %edi
  800511:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800514:	83 eb 01             	sub    $0x1,%ebx
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 db                	test   %ebx,%ebx
  80051c:	7f ee                	jg     80050c <vprintfmt+0x1ef>
  80051e:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800521:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800524:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800527:	85 c9                	test   %ecx,%ecx
  800529:	b8 00 00 00 00       	mov    $0x0,%eax
  80052e:	0f 49 c1             	cmovns %ecx,%eax
  800531:	29 c1                	sub    %eax,%ecx
  800533:	89 cb                	mov    %ecx,%ebx
  800535:	eb 41                	jmp    800578 <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800537:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80053b:	74 1b                	je     800558 <vprintfmt+0x23b>
  80053d:	0f be c0             	movsbl %al,%eax
  800540:	83 e8 20             	sub    $0x20,%eax
  800543:	83 f8 5e             	cmp    $0x5e,%eax
  800546:	76 10                	jbe    800558 <vprintfmt+0x23b>
					putch('?', putdat);
  800548:	83 ec 08             	sub    $0x8,%esp
  80054b:	ff 75 0c             	pushl  0xc(%ebp)
  80054e:	6a 3f                	push   $0x3f
  800550:	ff 55 08             	call   *0x8(%ebp)
  800553:	83 c4 10             	add    $0x10,%esp
  800556:	eb 0d                	jmp    800565 <vprintfmt+0x248>
				else
					putch(ch, putdat);
  800558:	83 ec 08             	sub    $0x8,%esp
  80055b:	ff 75 0c             	pushl  0xc(%ebp)
  80055e:	52                   	push   %edx
  80055f:	ff 55 08             	call   *0x8(%ebp)
  800562:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800565:	83 eb 01             	sub    $0x1,%ebx
  800568:	eb 0e                	jmp    800578 <vprintfmt+0x25b>
  80056a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80056d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800570:	eb 06                	jmp    800578 <vprintfmt+0x25b>
  800572:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800575:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800578:	83 c6 01             	add    $0x1,%esi
  80057b:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80057f:	0f be d0             	movsbl %al,%edx
  800582:	85 d2                	test   %edx,%edx
  800584:	74 25                	je     8005ab <vprintfmt+0x28e>
  800586:	85 ff                	test   %edi,%edi
  800588:	78 ad                	js     800537 <vprintfmt+0x21a>
  80058a:	83 ef 01             	sub    $0x1,%edi
  80058d:	79 a8                	jns    800537 <vprintfmt+0x21a>
  80058f:	89 d8                	mov    %ebx,%eax
  800591:	8b 75 08             	mov    0x8(%ebp),%esi
  800594:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800597:	89 c3                	mov    %eax,%ebx
  800599:	eb 16                	jmp    8005b1 <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059b:	83 ec 08             	sub    $0x8,%esp
  80059e:	57                   	push   %edi
  80059f:	6a 20                	push   $0x20
  8005a1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a3:	83 eb 01             	sub    $0x1,%ebx
  8005a6:	83 c4 10             	add    $0x10,%esp
  8005a9:	eb 06                	jmp    8005b1 <vprintfmt+0x294>
  8005ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ae:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005b1:	85 db                	test   %ebx,%ebx
  8005b3:	7f e6                	jg     80059b <vprintfmt+0x27e>
  8005b5:	89 75 08             	mov    %esi,0x8(%ebp)
  8005b8:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005be:	e9 86 fd ff ff       	jmp    800349 <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c3:	83 fa 01             	cmp    $0x1,%edx
  8005c6:	7e 10                	jle    8005d8 <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8d 50 08             	lea    0x8(%eax),%edx
  8005ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d1:	8b 30                	mov    (%eax),%esi
  8005d3:	8b 78 04             	mov    0x4(%eax),%edi
  8005d6:	eb 26                	jmp    8005fe <vprintfmt+0x2e1>
	else if (lflag)
  8005d8:	85 d2                	test   %edx,%edx
  8005da:	74 12                	je     8005ee <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 50 04             	lea    0x4(%eax),%edx
  8005e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e5:	8b 30                	mov    (%eax),%esi
  8005e7:	89 f7                	mov    %esi,%edi
  8005e9:	c1 ff 1f             	sar    $0x1f,%edi
  8005ec:	eb 10                	jmp    8005fe <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8d 50 04             	lea    0x4(%eax),%edx
  8005f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f7:	8b 30                	mov    (%eax),%esi
  8005f9:	89 f7                	mov    %esi,%edi
  8005fb:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005fe:	89 f0                	mov    %esi,%eax
  800600:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800602:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800607:	85 ff                	test   %edi,%edi
  800609:	79 7b                	jns    800686 <vprintfmt+0x369>
				putch('-', putdat);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	ff 75 0c             	pushl  0xc(%ebp)
  800611:	6a 2d                	push   $0x2d
  800613:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800616:	89 f0                	mov    %esi,%eax
  800618:	89 fa                	mov    %edi,%edx
  80061a:	f7 d8                	neg    %eax
  80061c:	83 d2 00             	adc    $0x0,%edx
  80061f:	f7 da                	neg    %edx
  800621:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800624:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800629:	eb 5b                	jmp    800686 <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80062b:	8d 45 14             	lea    0x14(%ebp),%eax
  80062e:	e8 76 fc ff ff       	call   8002a9 <getuint>
			base = 10;
  800633:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800638:	eb 4c                	jmp    800686 <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
  80063a:	8d 45 14             	lea    0x14(%ebp),%eax
  80063d:	e8 67 fc ff ff       	call   8002a9 <getuint>
            base = 8;
  800642:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800647:	eb 3d                	jmp    800686 <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	ff 75 0c             	pushl  0xc(%ebp)
  80064f:	6a 30                	push   $0x30
  800651:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800654:	83 c4 08             	add    $0x8,%esp
  800657:	ff 75 0c             	pushl  0xc(%ebp)
  80065a:	6a 78                	push   $0x78
  80065c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8d 50 04             	lea    0x4(%eax),%edx
  800665:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800668:	8b 00                	mov    (%eax),%eax
  80066a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80066f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800672:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800677:	eb 0d                	jmp    800686 <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800679:	8d 45 14             	lea    0x14(%ebp),%eax
  80067c:	e8 28 fc ff ff       	call   8002a9 <getuint>
			base = 16;
  800681:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800686:	83 ec 0c             	sub    $0xc,%esp
  800689:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  80068d:	56                   	push   %esi
  80068e:	ff 75 e0             	pushl  -0x20(%ebp)
  800691:	51                   	push   %ecx
  800692:	52                   	push   %edx
  800693:	50                   	push   %eax
  800694:	8b 55 0c             	mov    0xc(%ebp),%edx
  800697:	8b 45 08             	mov    0x8(%ebp),%eax
  80069a:	e8 5b fb ff ff       	call   8001fa <printnum>
			break;
  80069f:	83 c4 20             	add    $0x20,%esp
  8006a2:	e9 a2 fc ff ff       	jmp    800349 <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	ff 75 0c             	pushl  0xc(%ebp)
  8006ad:	51                   	push   %ecx
  8006ae:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006b1:	83 c4 10             	add    $0x10,%esp
  8006b4:	e9 90 fc ff ff       	jmp    800349 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b9:	83 ec 08             	sub    $0x8,%esp
  8006bc:	ff 75 0c             	pushl  0xc(%ebp)
  8006bf:	6a 25                	push   $0x25
  8006c1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c4:	83 c4 10             	add    $0x10,%esp
  8006c7:	89 f3                	mov    %esi,%ebx
  8006c9:	eb 03                	jmp    8006ce <vprintfmt+0x3b1>
  8006cb:	83 eb 01             	sub    $0x1,%ebx
  8006ce:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006d2:	75 f7                	jne    8006cb <vprintfmt+0x3ae>
  8006d4:	e9 70 fc ff ff       	jmp    800349 <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  8006d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006dc:	5b                   	pop    %ebx
  8006dd:	5e                   	pop    %esi
  8006de:	5f                   	pop    %edi
  8006df:	5d                   	pop    %ebp
  8006e0:	c3                   	ret    

008006e1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e1:	55                   	push   %ebp
  8006e2:	89 e5                	mov    %esp,%ebp
  8006e4:	83 ec 18             	sub    $0x18,%esp
  8006e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006fe:	85 c0                	test   %eax,%eax
  800700:	74 26                	je     800728 <vsnprintf+0x47>
  800702:	85 d2                	test   %edx,%edx
  800704:	7e 22                	jle    800728 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800706:	ff 75 14             	pushl  0x14(%ebp)
  800709:	ff 75 10             	pushl  0x10(%ebp)
  80070c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80070f:	50                   	push   %eax
  800710:	68 e3 02 80 00       	push   $0x8002e3
  800715:	e8 03 fc ff ff       	call   80031d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80071a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80071d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800720:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800723:	83 c4 10             	add    $0x10,%esp
  800726:	eb 05                	jmp    80072d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800728:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80072d:	c9                   	leave  
  80072e:	c3                   	ret    

0080072f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800735:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800738:	50                   	push   %eax
  800739:	ff 75 10             	pushl  0x10(%ebp)
  80073c:	ff 75 0c             	pushl  0xc(%ebp)
  80073f:	ff 75 08             	pushl  0x8(%ebp)
  800742:	e8 9a ff ff ff       	call   8006e1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800747:	c9                   	leave  
  800748:	c3                   	ret    

00800749 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800749:	55                   	push   %ebp
  80074a:	89 e5                	mov    %esp,%ebp
  80074c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80074f:	b8 00 00 00 00       	mov    $0x0,%eax
  800754:	eb 03                	jmp    800759 <strlen+0x10>
		n++;
  800756:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800759:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80075d:	75 f7                	jne    800756 <strlen+0xd>
		n++;
	return n;
}
  80075f:	5d                   	pop    %ebp
  800760:	c3                   	ret    

00800761 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800767:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076a:	ba 00 00 00 00       	mov    $0x0,%edx
  80076f:	eb 03                	jmp    800774 <strnlen+0x13>
		n++;
  800771:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800774:	39 c2                	cmp    %eax,%edx
  800776:	74 08                	je     800780 <strnlen+0x1f>
  800778:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80077c:	75 f3                	jne    800771 <strnlen+0x10>
  80077e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800780:	5d                   	pop    %ebp
  800781:	c3                   	ret    

00800782 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	53                   	push   %ebx
  800786:	8b 45 08             	mov    0x8(%ebp),%eax
  800789:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80078c:	89 c2                	mov    %eax,%edx
  80078e:	83 c2 01             	add    $0x1,%edx
  800791:	83 c1 01             	add    $0x1,%ecx
  800794:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800798:	88 5a ff             	mov    %bl,-0x1(%edx)
  80079b:	84 db                	test   %bl,%bl
  80079d:	75 ef                	jne    80078e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80079f:	5b                   	pop    %ebx
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	53                   	push   %ebx
  8007a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a9:	53                   	push   %ebx
  8007aa:	e8 9a ff ff ff       	call   800749 <strlen>
  8007af:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007b2:	ff 75 0c             	pushl  0xc(%ebp)
  8007b5:	01 d8                	add    %ebx,%eax
  8007b7:	50                   	push   %eax
  8007b8:	e8 c5 ff ff ff       	call   800782 <strcpy>
	return dst;
}
  8007bd:	89 d8                	mov    %ebx,%eax
  8007bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c2:	c9                   	leave  
  8007c3:	c3                   	ret    

008007c4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	56                   	push   %esi
  8007c8:	53                   	push   %ebx
  8007c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007cf:	89 f3                	mov    %esi,%ebx
  8007d1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d4:	89 f2                	mov    %esi,%edx
  8007d6:	eb 0f                	jmp    8007e7 <strncpy+0x23>
		*dst++ = *src;
  8007d8:	83 c2 01             	add    $0x1,%edx
  8007db:	0f b6 01             	movzbl (%ecx),%eax
  8007de:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e1:	80 39 01             	cmpb   $0x1,(%ecx)
  8007e4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e7:	39 da                	cmp    %ebx,%edx
  8007e9:	75 ed                	jne    8007d8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007eb:	89 f0                	mov    %esi,%eax
  8007ed:	5b                   	pop    %ebx
  8007ee:	5e                   	pop    %esi
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	56                   	push   %esi
  8007f5:	53                   	push   %ebx
  8007f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fc:	8b 55 10             	mov    0x10(%ebp),%edx
  8007ff:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800801:	85 d2                	test   %edx,%edx
  800803:	74 21                	je     800826 <strlcpy+0x35>
  800805:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800809:	89 f2                	mov    %esi,%edx
  80080b:	eb 09                	jmp    800816 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80080d:	83 c2 01             	add    $0x1,%edx
  800810:	83 c1 01             	add    $0x1,%ecx
  800813:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800816:	39 c2                	cmp    %eax,%edx
  800818:	74 09                	je     800823 <strlcpy+0x32>
  80081a:	0f b6 19             	movzbl (%ecx),%ebx
  80081d:	84 db                	test   %bl,%bl
  80081f:	75 ec                	jne    80080d <strlcpy+0x1c>
  800821:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800823:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800826:	29 f0                	sub    %esi,%eax
}
  800828:	5b                   	pop    %ebx
  800829:	5e                   	pop    %esi
  80082a:	5d                   	pop    %ebp
  80082b:	c3                   	ret    

0080082c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800832:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800835:	eb 06                	jmp    80083d <strcmp+0x11>
		p++, q++;
  800837:	83 c1 01             	add    $0x1,%ecx
  80083a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80083d:	0f b6 01             	movzbl (%ecx),%eax
  800840:	84 c0                	test   %al,%al
  800842:	74 04                	je     800848 <strcmp+0x1c>
  800844:	3a 02                	cmp    (%edx),%al
  800846:	74 ef                	je     800837 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800848:	0f b6 c0             	movzbl %al,%eax
  80084b:	0f b6 12             	movzbl (%edx),%edx
  80084e:	29 d0                	sub    %edx,%eax
}
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	53                   	push   %ebx
  800856:	8b 45 08             	mov    0x8(%ebp),%eax
  800859:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085c:	89 c3                	mov    %eax,%ebx
  80085e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800861:	eb 06                	jmp    800869 <strncmp+0x17>
		n--, p++, q++;
  800863:	83 c0 01             	add    $0x1,%eax
  800866:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800869:	39 d8                	cmp    %ebx,%eax
  80086b:	74 15                	je     800882 <strncmp+0x30>
  80086d:	0f b6 08             	movzbl (%eax),%ecx
  800870:	84 c9                	test   %cl,%cl
  800872:	74 04                	je     800878 <strncmp+0x26>
  800874:	3a 0a                	cmp    (%edx),%cl
  800876:	74 eb                	je     800863 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800878:	0f b6 00             	movzbl (%eax),%eax
  80087b:	0f b6 12             	movzbl (%edx),%edx
  80087e:	29 d0                	sub    %edx,%eax
  800880:	eb 05                	jmp    800887 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800882:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800887:	5b                   	pop    %ebx
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800894:	eb 07                	jmp    80089d <strchr+0x13>
		if (*s == c)
  800896:	38 ca                	cmp    %cl,%dl
  800898:	74 0f                	je     8008a9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80089a:	83 c0 01             	add    $0x1,%eax
  80089d:	0f b6 10             	movzbl (%eax),%edx
  8008a0:	84 d2                	test   %dl,%dl
  8008a2:	75 f2                	jne    800896 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b5:	eb 03                	jmp    8008ba <strfind+0xf>
  8008b7:	83 c0 01             	add    $0x1,%eax
  8008ba:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008bd:	38 ca                	cmp    %cl,%dl
  8008bf:	74 04                	je     8008c5 <strfind+0x1a>
  8008c1:	84 d2                	test   %dl,%dl
  8008c3:	75 f2                	jne    8008b7 <strfind+0xc>
			break;
	return (char *) s;
}
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	57                   	push   %edi
  8008cb:	56                   	push   %esi
  8008cc:	53                   	push   %ebx
  8008cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d3:	85 c9                	test   %ecx,%ecx
  8008d5:	74 36                	je     80090d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008dd:	75 28                	jne    800907 <memset+0x40>
  8008df:	f6 c1 03             	test   $0x3,%cl
  8008e2:	75 23                	jne    800907 <memset+0x40>
		c &= 0xFF;
  8008e4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e8:	89 d3                	mov    %edx,%ebx
  8008ea:	c1 e3 08             	shl    $0x8,%ebx
  8008ed:	89 d6                	mov    %edx,%esi
  8008ef:	c1 e6 18             	shl    $0x18,%esi
  8008f2:	89 d0                	mov    %edx,%eax
  8008f4:	c1 e0 10             	shl    $0x10,%eax
  8008f7:	09 f0                	or     %esi,%eax
  8008f9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008fb:	89 d8                	mov    %ebx,%eax
  8008fd:	09 d0                	or     %edx,%eax
  8008ff:	c1 e9 02             	shr    $0x2,%ecx
  800902:	fc                   	cld    
  800903:	f3 ab                	rep stos %eax,%es:(%edi)
  800905:	eb 06                	jmp    80090d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800907:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090a:	fc                   	cld    
  80090b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80090d:	89 f8                	mov    %edi,%eax
  80090f:	5b                   	pop    %ebx
  800910:	5e                   	pop    %esi
  800911:	5f                   	pop    %edi
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	57                   	push   %edi
  800918:	56                   	push   %esi
  800919:	8b 45 08             	mov    0x8(%ebp),%eax
  80091c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800922:	39 c6                	cmp    %eax,%esi
  800924:	73 35                	jae    80095b <memmove+0x47>
  800926:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800929:	39 d0                	cmp    %edx,%eax
  80092b:	73 2e                	jae    80095b <memmove+0x47>
		s += n;
		d += n;
  80092d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800930:	89 d6                	mov    %edx,%esi
  800932:	09 fe                	or     %edi,%esi
  800934:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80093a:	75 13                	jne    80094f <memmove+0x3b>
  80093c:	f6 c1 03             	test   $0x3,%cl
  80093f:	75 0e                	jne    80094f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800941:	83 ef 04             	sub    $0x4,%edi
  800944:	8d 72 fc             	lea    -0x4(%edx),%esi
  800947:	c1 e9 02             	shr    $0x2,%ecx
  80094a:	fd                   	std    
  80094b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094d:	eb 09                	jmp    800958 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80094f:	83 ef 01             	sub    $0x1,%edi
  800952:	8d 72 ff             	lea    -0x1(%edx),%esi
  800955:	fd                   	std    
  800956:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800958:	fc                   	cld    
  800959:	eb 1d                	jmp    800978 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095b:	89 f2                	mov    %esi,%edx
  80095d:	09 c2                	or     %eax,%edx
  80095f:	f6 c2 03             	test   $0x3,%dl
  800962:	75 0f                	jne    800973 <memmove+0x5f>
  800964:	f6 c1 03             	test   $0x3,%cl
  800967:	75 0a                	jne    800973 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800969:	c1 e9 02             	shr    $0x2,%ecx
  80096c:	89 c7                	mov    %eax,%edi
  80096e:	fc                   	cld    
  80096f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800971:	eb 05                	jmp    800978 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800973:	89 c7                	mov    %eax,%edi
  800975:	fc                   	cld    
  800976:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800978:	5e                   	pop    %esi
  800979:	5f                   	pop    %edi
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80097f:	ff 75 10             	pushl  0x10(%ebp)
  800982:	ff 75 0c             	pushl  0xc(%ebp)
  800985:	ff 75 08             	pushl  0x8(%ebp)
  800988:	e8 87 ff ff ff       	call   800914 <memmove>
}
  80098d:	c9                   	leave  
  80098e:	c3                   	ret    

0080098f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	56                   	push   %esi
  800993:	53                   	push   %ebx
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099a:	89 c6                	mov    %eax,%esi
  80099c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099f:	eb 1a                	jmp    8009bb <memcmp+0x2c>
		if (*s1 != *s2)
  8009a1:	0f b6 08             	movzbl (%eax),%ecx
  8009a4:	0f b6 1a             	movzbl (%edx),%ebx
  8009a7:	38 d9                	cmp    %bl,%cl
  8009a9:	74 0a                	je     8009b5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009ab:	0f b6 c1             	movzbl %cl,%eax
  8009ae:	0f b6 db             	movzbl %bl,%ebx
  8009b1:	29 d8                	sub    %ebx,%eax
  8009b3:	eb 0f                	jmp    8009c4 <memcmp+0x35>
		s1++, s2++;
  8009b5:	83 c0 01             	add    $0x1,%eax
  8009b8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009bb:	39 f0                	cmp    %esi,%eax
  8009bd:	75 e2                	jne    8009a1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c4:	5b                   	pop    %ebx
  8009c5:	5e                   	pop    %esi
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	53                   	push   %ebx
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009cf:	89 c1                	mov    %eax,%ecx
  8009d1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d8:	eb 0a                	jmp    8009e4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009da:	0f b6 10             	movzbl (%eax),%edx
  8009dd:	39 da                	cmp    %ebx,%edx
  8009df:	74 07                	je     8009e8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e1:	83 c0 01             	add    $0x1,%eax
  8009e4:	39 c8                	cmp    %ecx,%eax
  8009e6:	72 f2                	jb     8009da <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e8:	5b                   	pop    %ebx
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	57                   	push   %edi
  8009ef:	56                   	push   %esi
  8009f0:	53                   	push   %ebx
  8009f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f7:	eb 03                	jmp    8009fc <strtol+0x11>
		s++;
  8009f9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fc:	0f b6 01             	movzbl (%ecx),%eax
  8009ff:	3c 20                	cmp    $0x20,%al
  800a01:	74 f6                	je     8009f9 <strtol+0xe>
  800a03:	3c 09                	cmp    $0x9,%al
  800a05:	74 f2                	je     8009f9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a07:	3c 2b                	cmp    $0x2b,%al
  800a09:	75 0a                	jne    800a15 <strtol+0x2a>
		s++;
  800a0b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a0e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a13:	eb 11                	jmp    800a26 <strtol+0x3b>
  800a15:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a1a:	3c 2d                	cmp    $0x2d,%al
  800a1c:	75 08                	jne    800a26 <strtol+0x3b>
		s++, neg = 1;
  800a1e:	83 c1 01             	add    $0x1,%ecx
  800a21:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a26:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a2c:	75 15                	jne    800a43 <strtol+0x58>
  800a2e:	80 39 30             	cmpb   $0x30,(%ecx)
  800a31:	75 10                	jne    800a43 <strtol+0x58>
  800a33:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a37:	75 7c                	jne    800ab5 <strtol+0xca>
		s += 2, base = 16;
  800a39:	83 c1 02             	add    $0x2,%ecx
  800a3c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a41:	eb 16                	jmp    800a59 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a43:	85 db                	test   %ebx,%ebx
  800a45:	75 12                	jne    800a59 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a47:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a4f:	75 08                	jne    800a59 <strtol+0x6e>
		s++, base = 8;
  800a51:	83 c1 01             	add    $0x1,%ecx
  800a54:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a59:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a61:	0f b6 11             	movzbl (%ecx),%edx
  800a64:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a67:	89 f3                	mov    %esi,%ebx
  800a69:	80 fb 09             	cmp    $0x9,%bl
  800a6c:	77 08                	ja     800a76 <strtol+0x8b>
			dig = *s - '0';
  800a6e:	0f be d2             	movsbl %dl,%edx
  800a71:	83 ea 30             	sub    $0x30,%edx
  800a74:	eb 22                	jmp    800a98 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a76:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a79:	89 f3                	mov    %esi,%ebx
  800a7b:	80 fb 19             	cmp    $0x19,%bl
  800a7e:	77 08                	ja     800a88 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a80:	0f be d2             	movsbl %dl,%edx
  800a83:	83 ea 57             	sub    $0x57,%edx
  800a86:	eb 10                	jmp    800a98 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a88:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a8b:	89 f3                	mov    %esi,%ebx
  800a8d:	80 fb 19             	cmp    $0x19,%bl
  800a90:	77 16                	ja     800aa8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a92:	0f be d2             	movsbl %dl,%edx
  800a95:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a98:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a9b:	7d 0b                	jge    800aa8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a9d:	83 c1 01             	add    $0x1,%ecx
  800aa0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aa6:	eb b9                	jmp    800a61 <strtol+0x76>

	if (endptr)
  800aa8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aac:	74 0d                	je     800abb <strtol+0xd0>
		*endptr = (char *) s;
  800aae:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab1:	89 0e                	mov    %ecx,(%esi)
  800ab3:	eb 06                	jmp    800abb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab5:	85 db                	test   %ebx,%ebx
  800ab7:	74 98                	je     800a51 <strtol+0x66>
  800ab9:	eb 9e                	jmp    800a59 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800abb:	89 c2                	mov    %eax,%edx
  800abd:	f7 da                	neg    %edx
  800abf:	85 ff                	test   %edi,%edi
  800ac1:	0f 45 c2             	cmovne %edx,%eax
}
  800ac4:	5b                   	pop    %ebx
  800ac5:	5e                   	pop    %esi
  800ac6:	5f                   	pop    %edi
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	57                   	push   %edi
  800acd:	56                   	push   %esi
  800ace:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad7:	8b 55 08             	mov    0x8(%ebp),%edx
  800ada:	89 c3                	mov    %eax,%ebx
  800adc:	89 c7                	mov    %eax,%edi
  800ade:	89 c6                	mov    %eax,%esi
  800ae0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ae2:	5b                   	pop    %ebx
  800ae3:	5e                   	pop    %esi
  800ae4:	5f                   	pop    %edi
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	57                   	push   %edi
  800aeb:	56                   	push   %esi
  800aec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aed:	ba 00 00 00 00       	mov    $0x0,%edx
  800af2:	b8 01 00 00 00       	mov    $0x1,%eax
  800af7:	89 d1                	mov    %edx,%ecx
  800af9:	89 d3                	mov    %edx,%ebx
  800afb:	89 d7                	mov    %edx,%edi
  800afd:	89 d6                	mov    %edx,%esi
  800aff:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b01:	5b                   	pop    %ebx
  800b02:	5e                   	pop    %esi
  800b03:	5f                   	pop    %edi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
  800b0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b14:	b8 03 00 00 00       	mov    $0x3,%eax
  800b19:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1c:	89 cb                	mov    %ecx,%ebx
  800b1e:	89 cf                	mov    %ecx,%edi
  800b20:	89 ce                	mov    %ecx,%esi
  800b22:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b24:	85 c0                	test   %eax,%eax
  800b26:	7e 17                	jle    800b3f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b28:	83 ec 0c             	sub    $0xc,%esp
  800b2b:	50                   	push   %eax
  800b2c:	6a 03                	push   $0x3
  800b2e:	68 48 13 80 00       	push   $0x801348
  800b33:	6a 23                	push   $0x23
  800b35:	68 65 13 80 00       	push   $0x801365
  800b3a:	e8 ce f5 ff ff       	call   80010d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5f                   	pop    %edi
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	57                   	push   %edi
  800b4b:	56                   	push   %esi
  800b4c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b52:	b8 02 00 00 00       	mov    $0x2,%eax
  800b57:	89 d1                	mov    %edx,%ecx
  800b59:	89 d3                	mov    %edx,%ebx
  800b5b:	89 d7                	mov    %edx,%edi
  800b5d:	89 d6                	mov    %edx,%esi
  800b5f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b61:	5b                   	pop    %ebx
  800b62:	5e                   	pop    %esi
  800b63:	5f                   	pop    %edi
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <sys_yield>:

void
sys_yield(void)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b71:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b76:	89 d1                	mov    %edx,%ecx
  800b78:	89 d3                	mov    %edx,%ebx
  800b7a:	89 d7                	mov    %edx,%edi
  800b7c:	89 d6                	mov    %edx,%esi
  800b7e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
  800b8b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8e:	be 00 00 00 00       	mov    $0x0,%esi
  800b93:	b8 04 00 00 00       	mov    $0x4,%eax
  800b98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba1:	89 f7                	mov    %esi,%edi
  800ba3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba5:	85 c0                	test   %eax,%eax
  800ba7:	7e 17                	jle    800bc0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba9:	83 ec 0c             	sub    $0xc,%esp
  800bac:	50                   	push   %eax
  800bad:	6a 04                	push   $0x4
  800baf:	68 48 13 80 00       	push   $0x801348
  800bb4:	6a 23                	push   $0x23
  800bb6:	68 65 13 80 00       	push   $0x801365
  800bbb:	e8 4d f5 ff ff       	call   80010d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc3:	5b                   	pop    %ebx
  800bc4:	5e                   	pop    %esi
  800bc5:	5f                   	pop    %edi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	57                   	push   %edi
  800bcc:	56                   	push   %esi
  800bcd:	53                   	push   %ebx
  800bce:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd1:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bdf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800be2:	8b 75 18             	mov    0x18(%ebp),%esi
  800be5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be7:	85 c0                	test   %eax,%eax
  800be9:	7e 17                	jle    800c02 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800beb:	83 ec 0c             	sub    $0xc,%esp
  800bee:	50                   	push   %eax
  800bef:	6a 05                	push   $0x5
  800bf1:	68 48 13 80 00       	push   $0x801348
  800bf6:	6a 23                	push   $0x23
  800bf8:	68 65 13 80 00       	push   $0x801365
  800bfd:	e8 0b f5 ff ff       	call   80010d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	57                   	push   %edi
  800c0e:	56                   	push   %esi
  800c0f:	53                   	push   %ebx
  800c10:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c18:	b8 06 00 00 00       	mov    $0x6,%eax
  800c1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c20:	8b 55 08             	mov    0x8(%ebp),%edx
  800c23:	89 df                	mov    %ebx,%edi
  800c25:	89 de                	mov    %ebx,%esi
  800c27:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c29:	85 c0                	test   %eax,%eax
  800c2b:	7e 17                	jle    800c44 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2d:	83 ec 0c             	sub    $0xc,%esp
  800c30:	50                   	push   %eax
  800c31:	6a 06                	push   $0x6
  800c33:	68 48 13 80 00       	push   $0x801348
  800c38:	6a 23                	push   $0x23
  800c3a:	68 65 13 80 00       	push   $0x801365
  800c3f:	e8 c9 f4 ff ff       	call   80010d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c47:	5b                   	pop    %ebx
  800c48:	5e                   	pop    %esi
  800c49:	5f                   	pop    %edi
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	57                   	push   %edi
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
  800c52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5a:	b8 08 00 00 00       	mov    $0x8,%eax
  800c5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c62:	8b 55 08             	mov    0x8(%ebp),%edx
  800c65:	89 df                	mov    %ebx,%edi
  800c67:	89 de                	mov    %ebx,%esi
  800c69:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6b:	85 c0                	test   %eax,%eax
  800c6d:	7e 17                	jle    800c86 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6f:	83 ec 0c             	sub    $0xc,%esp
  800c72:	50                   	push   %eax
  800c73:	6a 08                	push   $0x8
  800c75:	68 48 13 80 00       	push   $0x801348
  800c7a:	6a 23                	push   $0x23
  800c7c:	68 65 13 80 00       	push   $0x801365
  800c81:	e8 87 f4 ff ff       	call   80010d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c89:	5b                   	pop    %ebx
  800c8a:	5e                   	pop    %esi
  800c8b:	5f                   	pop    %edi
  800c8c:	5d                   	pop    %ebp
  800c8d:	c3                   	ret    

00800c8e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
  800c94:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9c:	b8 09 00 00 00       	mov    $0x9,%eax
  800ca1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca7:	89 df                	mov    %ebx,%edi
  800ca9:	89 de                	mov    %ebx,%esi
  800cab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cad:	85 c0                	test   %eax,%eax
  800caf:	7e 17                	jle    800cc8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb1:	83 ec 0c             	sub    $0xc,%esp
  800cb4:	50                   	push   %eax
  800cb5:	6a 09                	push   $0x9
  800cb7:	68 48 13 80 00       	push   $0x801348
  800cbc:	6a 23                	push   $0x23
  800cbe:	68 65 13 80 00       	push   $0x801365
  800cc3:	e8 45 f4 ff ff       	call   80010d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccb:	5b                   	pop    %ebx
  800ccc:	5e                   	pop    %esi
  800ccd:	5f                   	pop    %edi
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	57                   	push   %edi
  800cd4:	56                   	push   %esi
  800cd5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd6:	be 00 00 00 00       	mov    $0x0,%esi
  800cdb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ce0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cec:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cee:	5b                   	pop    %ebx
  800cef:	5e                   	pop    %esi
  800cf0:	5f                   	pop    %edi
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    

00800cf3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	57                   	push   %edi
  800cf7:	56                   	push   %esi
  800cf8:	53                   	push   %ebx
  800cf9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d01:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
  800d09:	89 cb                	mov    %ecx,%ebx
  800d0b:	89 cf                	mov    %ecx,%edi
  800d0d:	89 ce                	mov    %ecx,%esi
  800d0f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d11:	85 c0                	test   %eax,%eax
  800d13:	7e 17                	jle    800d2c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d15:	83 ec 0c             	sub    $0xc,%esp
  800d18:	50                   	push   %eax
  800d19:	6a 0c                	push   $0xc
  800d1b:	68 48 13 80 00       	push   $0x801348
  800d20:	6a 23                	push   $0x23
  800d22:	68 65 13 80 00       	push   $0x801365
  800d27:	e8 e1 f3 ff ff       	call   80010d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2f:	5b                   	pop    %ebx
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d3a:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d41:	75 4c                	jne    800d8f <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.

        void *va = (void *)(UXSTACKTOP - PGSIZE);
        if (sys_page_alloc(thisenv->env_id, va, PTE_P | PTE_U | PTE_W))
  800d43:	a1 04 20 80 00       	mov    0x802004,%eax
  800d48:	8b 40 48             	mov    0x48(%eax),%eax
  800d4b:	83 ec 04             	sub    $0x4,%esp
  800d4e:	6a 07                	push   $0x7
  800d50:	68 00 f0 bf ee       	push   $0xeebff000
  800d55:	50                   	push   %eax
  800d56:	e8 2a fe ff ff       	call   800b85 <sys_page_alloc>
  800d5b:	83 c4 10             	add    $0x10,%esp
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	74 14                	je     800d76 <set_pgfault_handler+0x42>
        {
            panic("Unable to allocate memory for pgfault expected\n");
  800d62:	83 ec 04             	sub    $0x4,%esp
  800d65:	68 74 13 80 00       	push   $0x801374
  800d6a:	6a 24                	push   $0x24
  800d6c:	68 a4 13 80 00       	push   $0x8013a4
  800d71:	e8 97 f3 ff ff       	call   80010d <_panic>
        }

        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800d76:	a1 04 20 80 00       	mov    0x802004,%eax
  800d7b:	8b 40 48             	mov    0x48(%eax),%eax
  800d7e:	83 ec 08             	sub    $0x8,%esp
  800d81:	68 99 0d 80 00       	push   $0x800d99
  800d86:	50                   	push   %eax
  800d87:	e8 02 ff ff ff       	call   800c8e <sys_env_set_pgfault_upcall>
  800d8c:	83 c4 10             	add    $0x10,%esp

		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d92:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d97:	c9                   	leave  
  800d98:	c3                   	ret    

00800d99 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d99:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d9a:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800d9f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800da1:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
    movl %esp, %ebx
  800da4:	89 e3                	mov    %esp,%ebx
    // 40 is the size between utf_fault_va ~ utf_regs
    movl 40(%esp), %eax
  800da6:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 48(%esp), %esp
  800daa:	8b 64 24 30          	mov    0x30(%esp),%esp
    pushl %eax
  800dae:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    movl %ebx, %esp
  800daf:	89 dc                	mov    %ebx,%esp
    subl $4, 48(%esp)
  800db1:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    popl %eax
  800db6:	58                   	pop    %eax
    popl %eax
  800db7:	58                   	pop    %eax
    popal
  800db8:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  800db9:	83 c4 04             	add    $0x4,%esp
    popfl
  800dbc:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp
  800dbd:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  800dbe:	c3                   	ret    
  800dbf:	90                   	nop

00800dc0 <__udivdi3>:
  800dc0:	55                   	push   %ebp
  800dc1:	57                   	push   %edi
  800dc2:	56                   	push   %esi
  800dc3:	53                   	push   %ebx
  800dc4:	83 ec 1c             	sub    $0x1c,%esp
  800dc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800dcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800dcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800dd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800dd7:	85 f6                	test   %esi,%esi
  800dd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ddd:	89 ca                	mov    %ecx,%edx
  800ddf:	89 f8                	mov    %edi,%eax
  800de1:	75 3d                	jne    800e20 <__udivdi3+0x60>
  800de3:	39 cf                	cmp    %ecx,%edi
  800de5:	0f 87 c5 00 00 00    	ja     800eb0 <__udivdi3+0xf0>
  800deb:	85 ff                	test   %edi,%edi
  800ded:	89 fd                	mov    %edi,%ebp
  800def:	75 0b                	jne    800dfc <__udivdi3+0x3c>
  800df1:	b8 01 00 00 00       	mov    $0x1,%eax
  800df6:	31 d2                	xor    %edx,%edx
  800df8:	f7 f7                	div    %edi
  800dfa:	89 c5                	mov    %eax,%ebp
  800dfc:	89 c8                	mov    %ecx,%eax
  800dfe:	31 d2                	xor    %edx,%edx
  800e00:	f7 f5                	div    %ebp
  800e02:	89 c1                	mov    %eax,%ecx
  800e04:	89 d8                	mov    %ebx,%eax
  800e06:	89 cf                	mov    %ecx,%edi
  800e08:	f7 f5                	div    %ebp
  800e0a:	89 c3                	mov    %eax,%ebx
  800e0c:	89 d8                	mov    %ebx,%eax
  800e0e:	89 fa                	mov    %edi,%edx
  800e10:	83 c4 1c             	add    $0x1c,%esp
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    
  800e18:	90                   	nop
  800e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e20:	39 ce                	cmp    %ecx,%esi
  800e22:	77 74                	ja     800e98 <__udivdi3+0xd8>
  800e24:	0f bd fe             	bsr    %esi,%edi
  800e27:	83 f7 1f             	xor    $0x1f,%edi
  800e2a:	0f 84 98 00 00 00    	je     800ec8 <__udivdi3+0x108>
  800e30:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e35:	89 f9                	mov    %edi,%ecx
  800e37:	89 c5                	mov    %eax,%ebp
  800e39:	29 fb                	sub    %edi,%ebx
  800e3b:	d3 e6                	shl    %cl,%esi
  800e3d:	89 d9                	mov    %ebx,%ecx
  800e3f:	d3 ed                	shr    %cl,%ebp
  800e41:	89 f9                	mov    %edi,%ecx
  800e43:	d3 e0                	shl    %cl,%eax
  800e45:	09 ee                	or     %ebp,%esi
  800e47:	89 d9                	mov    %ebx,%ecx
  800e49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e4d:	89 d5                	mov    %edx,%ebp
  800e4f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e53:	d3 ed                	shr    %cl,%ebp
  800e55:	89 f9                	mov    %edi,%ecx
  800e57:	d3 e2                	shl    %cl,%edx
  800e59:	89 d9                	mov    %ebx,%ecx
  800e5b:	d3 e8                	shr    %cl,%eax
  800e5d:	09 c2                	or     %eax,%edx
  800e5f:	89 d0                	mov    %edx,%eax
  800e61:	89 ea                	mov    %ebp,%edx
  800e63:	f7 f6                	div    %esi
  800e65:	89 d5                	mov    %edx,%ebp
  800e67:	89 c3                	mov    %eax,%ebx
  800e69:	f7 64 24 0c          	mull   0xc(%esp)
  800e6d:	39 d5                	cmp    %edx,%ebp
  800e6f:	72 10                	jb     800e81 <__udivdi3+0xc1>
  800e71:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e75:	89 f9                	mov    %edi,%ecx
  800e77:	d3 e6                	shl    %cl,%esi
  800e79:	39 c6                	cmp    %eax,%esi
  800e7b:	73 07                	jae    800e84 <__udivdi3+0xc4>
  800e7d:	39 d5                	cmp    %edx,%ebp
  800e7f:	75 03                	jne    800e84 <__udivdi3+0xc4>
  800e81:	83 eb 01             	sub    $0x1,%ebx
  800e84:	31 ff                	xor    %edi,%edi
  800e86:	89 d8                	mov    %ebx,%eax
  800e88:	89 fa                	mov    %edi,%edx
  800e8a:	83 c4 1c             	add    $0x1c,%esp
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    
  800e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e98:	31 ff                	xor    %edi,%edi
  800e9a:	31 db                	xor    %ebx,%ebx
  800e9c:	89 d8                	mov    %ebx,%eax
  800e9e:	89 fa                	mov    %edi,%edx
  800ea0:	83 c4 1c             	add    $0x1c,%esp
  800ea3:	5b                   	pop    %ebx
  800ea4:	5e                   	pop    %esi
  800ea5:	5f                   	pop    %edi
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    
  800ea8:	90                   	nop
  800ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	89 d8                	mov    %ebx,%eax
  800eb2:	f7 f7                	div    %edi
  800eb4:	31 ff                	xor    %edi,%edi
  800eb6:	89 c3                	mov    %eax,%ebx
  800eb8:	89 d8                	mov    %ebx,%eax
  800eba:	89 fa                	mov    %edi,%edx
  800ebc:	83 c4 1c             	add    $0x1c,%esp
  800ebf:	5b                   	pop    %ebx
  800ec0:	5e                   	pop    %esi
  800ec1:	5f                   	pop    %edi
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    
  800ec4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ec8:	39 ce                	cmp    %ecx,%esi
  800eca:	72 0c                	jb     800ed8 <__udivdi3+0x118>
  800ecc:	31 db                	xor    %ebx,%ebx
  800ece:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800ed2:	0f 87 34 ff ff ff    	ja     800e0c <__udivdi3+0x4c>
  800ed8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800edd:	e9 2a ff ff ff       	jmp    800e0c <__udivdi3+0x4c>
  800ee2:	66 90                	xchg   %ax,%ax
  800ee4:	66 90                	xchg   %ax,%ax
  800ee6:	66 90                	xchg   %ax,%ax
  800ee8:	66 90                	xchg   %ax,%ax
  800eea:	66 90                	xchg   %ax,%ax
  800eec:	66 90                	xchg   %ax,%ax
  800eee:	66 90                	xchg   %ax,%ax

00800ef0 <__umoddi3>:
  800ef0:	55                   	push   %ebp
  800ef1:	57                   	push   %edi
  800ef2:	56                   	push   %esi
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 1c             	sub    $0x1c,%esp
  800ef7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800efb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800eff:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f07:	85 d2                	test   %edx,%edx
  800f09:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f11:	89 f3                	mov    %esi,%ebx
  800f13:	89 3c 24             	mov    %edi,(%esp)
  800f16:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f1a:	75 1c                	jne    800f38 <__umoddi3+0x48>
  800f1c:	39 f7                	cmp    %esi,%edi
  800f1e:	76 50                	jbe    800f70 <__umoddi3+0x80>
  800f20:	89 c8                	mov    %ecx,%eax
  800f22:	89 f2                	mov    %esi,%edx
  800f24:	f7 f7                	div    %edi
  800f26:	89 d0                	mov    %edx,%eax
  800f28:	31 d2                	xor    %edx,%edx
  800f2a:	83 c4 1c             	add    $0x1c,%esp
  800f2d:	5b                   	pop    %ebx
  800f2e:	5e                   	pop    %esi
  800f2f:	5f                   	pop    %edi
  800f30:	5d                   	pop    %ebp
  800f31:	c3                   	ret    
  800f32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f38:	39 f2                	cmp    %esi,%edx
  800f3a:	89 d0                	mov    %edx,%eax
  800f3c:	77 52                	ja     800f90 <__umoddi3+0xa0>
  800f3e:	0f bd ea             	bsr    %edx,%ebp
  800f41:	83 f5 1f             	xor    $0x1f,%ebp
  800f44:	75 5a                	jne    800fa0 <__umoddi3+0xb0>
  800f46:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f4a:	0f 82 e0 00 00 00    	jb     801030 <__umoddi3+0x140>
  800f50:	39 0c 24             	cmp    %ecx,(%esp)
  800f53:	0f 86 d7 00 00 00    	jbe    801030 <__umoddi3+0x140>
  800f59:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f5d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f61:	83 c4 1c             	add    $0x1c,%esp
  800f64:	5b                   	pop    %ebx
  800f65:	5e                   	pop    %esi
  800f66:	5f                   	pop    %edi
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    
  800f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f70:	85 ff                	test   %edi,%edi
  800f72:	89 fd                	mov    %edi,%ebp
  800f74:	75 0b                	jne    800f81 <__umoddi3+0x91>
  800f76:	b8 01 00 00 00       	mov    $0x1,%eax
  800f7b:	31 d2                	xor    %edx,%edx
  800f7d:	f7 f7                	div    %edi
  800f7f:	89 c5                	mov    %eax,%ebp
  800f81:	89 f0                	mov    %esi,%eax
  800f83:	31 d2                	xor    %edx,%edx
  800f85:	f7 f5                	div    %ebp
  800f87:	89 c8                	mov    %ecx,%eax
  800f89:	f7 f5                	div    %ebp
  800f8b:	89 d0                	mov    %edx,%eax
  800f8d:	eb 99                	jmp    800f28 <__umoddi3+0x38>
  800f8f:	90                   	nop
  800f90:	89 c8                	mov    %ecx,%eax
  800f92:	89 f2                	mov    %esi,%edx
  800f94:	83 c4 1c             	add    $0x1c,%esp
  800f97:	5b                   	pop    %ebx
  800f98:	5e                   	pop    %esi
  800f99:	5f                   	pop    %edi
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    
  800f9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fa0:	8b 34 24             	mov    (%esp),%esi
  800fa3:	bf 20 00 00 00       	mov    $0x20,%edi
  800fa8:	89 e9                	mov    %ebp,%ecx
  800faa:	29 ef                	sub    %ebp,%edi
  800fac:	d3 e0                	shl    %cl,%eax
  800fae:	89 f9                	mov    %edi,%ecx
  800fb0:	89 f2                	mov    %esi,%edx
  800fb2:	d3 ea                	shr    %cl,%edx
  800fb4:	89 e9                	mov    %ebp,%ecx
  800fb6:	09 c2                	or     %eax,%edx
  800fb8:	89 d8                	mov    %ebx,%eax
  800fba:	89 14 24             	mov    %edx,(%esp)
  800fbd:	89 f2                	mov    %esi,%edx
  800fbf:	d3 e2                	shl    %cl,%edx
  800fc1:	89 f9                	mov    %edi,%ecx
  800fc3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fc7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800fcb:	d3 e8                	shr    %cl,%eax
  800fcd:	89 e9                	mov    %ebp,%ecx
  800fcf:	89 c6                	mov    %eax,%esi
  800fd1:	d3 e3                	shl    %cl,%ebx
  800fd3:	89 f9                	mov    %edi,%ecx
  800fd5:	89 d0                	mov    %edx,%eax
  800fd7:	d3 e8                	shr    %cl,%eax
  800fd9:	89 e9                	mov    %ebp,%ecx
  800fdb:	09 d8                	or     %ebx,%eax
  800fdd:	89 d3                	mov    %edx,%ebx
  800fdf:	89 f2                	mov    %esi,%edx
  800fe1:	f7 34 24             	divl   (%esp)
  800fe4:	89 d6                	mov    %edx,%esi
  800fe6:	d3 e3                	shl    %cl,%ebx
  800fe8:	f7 64 24 04          	mull   0x4(%esp)
  800fec:	39 d6                	cmp    %edx,%esi
  800fee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ff2:	89 d1                	mov    %edx,%ecx
  800ff4:	89 c3                	mov    %eax,%ebx
  800ff6:	72 08                	jb     801000 <__umoddi3+0x110>
  800ff8:	75 11                	jne    80100b <__umoddi3+0x11b>
  800ffa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800ffe:	73 0b                	jae    80100b <__umoddi3+0x11b>
  801000:	2b 44 24 04          	sub    0x4(%esp),%eax
  801004:	1b 14 24             	sbb    (%esp),%edx
  801007:	89 d1                	mov    %edx,%ecx
  801009:	89 c3                	mov    %eax,%ebx
  80100b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80100f:	29 da                	sub    %ebx,%edx
  801011:	19 ce                	sbb    %ecx,%esi
  801013:	89 f9                	mov    %edi,%ecx
  801015:	89 f0                	mov    %esi,%eax
  801017:	d3 e0                	shl    %cl,%eax
  801019:	89 e9                	mov    %ebp,%ecx
  80101b:	d3 ea                	shr    %cl,%edx
  80101d:	89 e9                	mov    %ebp,%ecx
  80101f:	d3 ee                	shr    %cl,%esi
  801021:	09 d0                	or     %edx,%eax
  801023:	89 f2                	mov    %esi,%edx
  801025:	83 c4 1c             	add    $0x1c,%esp
  801028:	5b                   	pop    %ebx
  801029:	5e                   	pop    %esi
  80102a:	5f                   	pop    %edi
  80102b:	5d                   	pop    %ebp
  80102c:	c3                   	ret    
  80102d:	8d 76 00             	lea    0x0(%esi),%esi
  801030:	29 f9                	sub    %edi,%ecx
  801032:	19 d6                	sbb    %edx,%esi
  801034:	89 74 24 04          	mov    %esi,0x4(%esp)
  801038:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80103c:	e9 18 ff ff ff       	jmp    800f59 <__umoddi3+0x69>
