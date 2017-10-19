
obj/user/faultalloc：     文件格式 elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
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
  800040:	68 80 10 80 00       	push   $0x801080
  800045:	e8 b1 01 00 00       	call   8001fb <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 3c 0b 00 00       	call   800b9a <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 a0 10 80 00       	push   $0x8010a0
  80006f:	6a 0e                	push   $0xe
  800071:	68 8a 10 80 00       	push   $0x80108a
  800076:	e8 a7 00 00 00       	call   800122 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 cc 10 80 00       	push   $0x8010cc
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 bb 06 00 00       	call   800744 <snprintf>
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
  80009c:	e8 a8 0c 00 00       	call   800d49 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 9c 10 80 00       	push   $0x80109c
  8000ae:	e8 48 01 00 00       	call   8001fb <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 9c 10 80 00       	push   $0x80109c
  8000c0:	e8 36 01 00 00       	call   8001fb <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000d5:	e8 82 0a 00 00       	call   800b5c <sys_getenvid>
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e7:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ec:	85 db                	test   %ebx,%ebx
  8000ee:	7e 07                	jle    8000f7 <libmain+0x2d>
		binaryname = argv[0];
  8000f0:	8b 06                	mov    (%esi),%eax
  8000f2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 90 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800101:	e8 0a 00 00 00       	call   800110 <exit>
}
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800116:	6a 00                	push   $0x0
  800118:	e8 fe 09 00 00       	call   800b1b <sys_env_destroy>
}
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	56                   	push   %esi
  800126:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800127:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80012a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800130:	e8 27 0a 00 00       	call   800b5c <sys_getenvid>
  800135:	83 ec 0c             	sub    $0xc,%esp
  800138:	ff 75 0c             	pushl  0xc(%ebp)
  80013b:	ff 75 08             	pushl  0x8(%ebp)
  80013e:	56                   	push   %esi
  80013f:	50                   	push   %eax
  800140:	68 f8 10 80 00       	push   $0x8010f8
  800145:	e8 b1 00 00 00       	call   8001fb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80014a:	83 c4 18             	add    $0x18,%esp
  80014d:	53                   	push   %ebx
  80014e:	ff 75 10             	pushl  0x10(%ebp)
  800151:	e8 54 00 00 00       	call   8001aa <vcprintf>
	cprintf("\n");
  800156:	c7 04 24 9e 10 80 00 	movl   $0x80109e,(%esp)
  80015d:	e8 99 00 00 00       	call   8001fb <cprintf>
  800162:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800165:	cc                   	int3   
  800166:	eb fd                	jmp    800165 <_panic+0x43>

00800168 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	53                   	push   %ebx
  80016c:	83 ec 04             	sub    $0x4,%esp
  80016f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800172:	8b 13                	mov    (%ebx),%edx
  800174:	8d 42 01             	lea    0x1(%edx),%eax
  800177:	89 03                	mov    %eax,(%ebx)
  800179:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80017c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800180:	3d ff 00 00 00       	cmp    $0xff,%eax
  800185:	75 1a                	jne    8001a1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800187:	83 ec 08             	sub    $0x8,%esp
  80018a:	68 ff 00 00 00       	push   $0xff
  80018f:	8d 43 08             	lea    0x8(%ebx),%eax
  800192:	50                   	push   %eax
  800193:	e8 46 09 00 00       	call   800ade <sys_cputs>
		b->idx = 0;
  800198:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a8:	c9                   	leave  
  8001a9:	c3                   	ret    

008001aa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001aa:	55                   	push   %ebp
  8001ab:	89 e5                	mov    %esp,%ebp
  8001ad:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ba:	00 00 00 
	b.cnt = 0;
  8001bd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c7:	ff 75 0c             	pushl  0xc(%ebp)
  8001ca:	ff 75 08             	pushl  0x8(%ebp)
  8001cd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d3:	50                   	push   %eax
  8001d4:	68 68 01 80 00       	push   $0x800168
  8001d9:	e8 54 01 00 00       	call   800332 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001de:	83 c4 08             	add    $0x8,%esp
  8001e1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ed:	50                   	push   %eax
  8001ee:	e8 eb 08 00 00       	call   800ade <sys_cputs>

	return b.cnt;
}
  8001f3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f9:	c9                   	leave  
  8001fa:	c3                   	ret    

008001fb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001fb:	55                   	push   %ebp
  8001fc:	89 e5                	mov    %esp,%ebp
  8001fe:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800201:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800204:	50                   	push   %eax
  800205:	ff 75 08             	pushl  0x8(%ebp)
  800208:	e8 9d ff ff ff       	call   8001aa <vcprintf>
	va_end(ap);

	return cnt;
}
  80020d:	c9                   	leave  
  80020e:	c3                   	ret    

0080020f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	57                   	push   %edi
  800213:	56                   	push   %esi
  800214:	53                   	push   %ebx
  800215:	83 ec 1c             	sub    $0x1c,%esp
  800218:	89 c7                	mov    %eax,%edi
  80021a:	89 d6                	mov    %edx,%esi
  80021c:	8b 45 08             	mov    0x8(%ebp),%eax
  80021f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800222:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800225:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800228:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80022b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800230:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800233:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800236:	39 d3                	cmp    %edx,%ebx
  800238:	72 05                	jb     80023f <printnum+0x30>
  80023a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80023d:	77 45                	ja     800284 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	ff 75 18             	pushl  0x18(%ebp)
  800245:	8b 45 14             	mov    0x14(%ebp),%eax
  800248:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80024b:	53                   	push   %ebx
  80024c:	ff 75 10             	pushl  0x10(%ebp)
  80024f:	83 ec 08             	sub    $0x8,%esp
  800252:	ff 75 e4             	pushl  -0x1c(%ebp)
  800255:	ff 75 e0             	pushl  -0x20(%ebp)
  800258:	ff 75 dc             	pushl  -0x24(%ebp)
  80025b:	ff 75 d8             	pushl  -0x28(%ebp)
  80025e:	e8 7d 0b 00 00       	call   800de0 <__udivdi3>
  800263:	83 c4 18             	add    $0x18,%esp
  800266:	52                   	push   %edx
  800267:	50                   	push   %eax
  800268:	89 f2                	mov    %esi,%edx
  80026a:	89 f8                	mov    %edi,%eax
  80026c:	e8 9e ff ff ff       	call   80020f <printnum>
  800271:	83 c4 20             	add    $0x20,%esp
  800274:	eb 18                	jmp    80028e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800276:	83 ec 08             	sub    $0x8,%esp
  800279:	56                   	push   %esi
  80027a:	ff 75 18             	pushl  0x18(%ebp)
  80027d:	ff d7                	call   *%edi
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	eb 03                	jmp    800287 <printnum+0x78>
  800284:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800287:	83 eb 01             	sub    $0x1,%ebx
  80028a:	85 db                	test   %ebx,%ebx
  80028c:	7f e8                	jg     800276 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	56                   	push   %esi
  800292:	83 ec 04             	sub    $0x4,%esp
  800295:	ff 75 e4             	pushl  -0x1c(%ebp)
  800298:	ff 75 e0             	pushl  -0x20(%ebp)
  80029b:	ff 75 dc             	pushl  -0x24(%ebp)
  80029e:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a1:	e8 6a 0c 00 00       	call   800f10 <__umoddi3>
  8002a6:	83 c4 14             	add    $0x14,%esp
  8002a9:	0f be 80 1b 11 80 00 	movsbl 0x80111b(%eax),%eax
  8002b0:	50                   	push   %eax
  8002b1:	ff d7                	call   *%edi
}
  8002b3:	83 c4 10             	add    $0x10,%esp
  8002b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b9:	5b                   	pop    %ebx
  8002ba:	5e                   	pop    %esi
  8002bb:	5f                   	pop    %edi
  8002bc:	5d                   	pop    %ebp
  8002bd:	c3                   	ret    

008002be <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c1:	83 fa 01             	cmp    $0x1,%edx
  8002c4:	7e 0e                	jle    8002d4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c6:	8b 10                	mov    (%eax),%edx
  8002c8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002cb:	89 08                	mov    %ecx,(%eax)
  8002cd:	8b 02                	mov    (%edx),%eax
  8002cf:	8b 52 04             	mov    0x4(%edx),%edx
  8002d2:	eb 22                	jmp    8002f6 <getuint+0x38>
	else if (lflag)
  8002d4:	85 d2                	test   %edx,%edx
  8002d6:	74 10                	je     8002e8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d8:	8b 10                	mov    (%eax),%edx
  8002da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002dd:	89 08                	mov    %ecx,(%eax)
  8002df:	8b 02                	mov    (%edx),%eax
  8002e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e6:	eb 0e                	jmp    8002f6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e8:	8b 10                	mov    (%eax),%edx
  8002ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ed:	89 08                	mov    %ecx,(%eax)
  8002ef:	8b 02                	mov    (%edx),%eax
  8002f1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fe:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800302:	8b 10                	mov    (%eax),%edx
  800304:	3b 50 04             	cmp    0x4(%eax),%edx
  800307:	73 0a                	jae    800313 <sprintputch+0x1b>
		*b->buf++ = ch;
  800309:	8d 4a 01             	lea    0x1(%edx),%ecx
  80030c:	89 08                	mov    %ecx,(%eax)
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	88 02                	mov    %al,(%edx)
}
  800313:	5d                   	pop    %ebp
  800314:	c3                   	ret    

00800315 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80031b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031e:	50                   	push   %eax
  80031f:	ff 75 10             	pushl  0x10(%ebp)
  800322:	ff 75 0c             	pushl  0xc(%ebp)
  800325:	ff 75 08             	pushl  0x8(%ebp)
  800328:	e8 05 00 00 00       	call   800332 <vprintfmt>
	va_end(ap);
}
  80032d:	83 c4 10             	add    $0x10,%esp
  800330:	c9                   	leave  
  800331:	c3                   	ret    

00800332 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	57                   	push   %edi
  800336:	56                   	push   %esi
  800337:	53                   	push   %ebx
  800338:	83 ec 2c             	sub    $0x2c,%esp
  80033b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
  80033e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800345:	eb 17                	jmp    80035e <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800347:	85 c0                	test   %eax,%eax
  800349:	0f 84 9f 03 00 00    	je     8006ee <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
  80034f:	83 ec 08             	sub    $0x8,%esp
  800352:	ff 75 0c             	pushl  0xc(%ebp)
  800355:	50                   	push   %eax
  800356:	ff 55 08             	call   *0x8(%ebp)
  800359:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80035c:	89 f3                	mov    %esi,%ebx
  80035e:	8d 73 01             	lea    0x1(%ebx),%esi
  800361:	0f b6 03             	movzbl (%ebx),%eax
  800364:	83 f8 25             	cmp    $0x25,%eax
  800367:	75 de                	jne    800347 <vprintfmt+0x15>
  800369:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80036d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800374:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800379:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800380:	ba 00 00 00 00       	mov    $0x0,%edx
  800385:	eb 06                	jmp    80038d <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800387:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800389:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038d:	8d 5e 01             	lea    0x1(%esi),%ebx
  800390:	0f b6 06             	movzbl (%esi),%eax
  800393:	0f b6 c8             	movzbl %al,%ecx
  800396:	83 e8 23             	sub    $0x23,%eax
  800399:	3c 55                	cmp    $0x55,%al
  80039b:	0f 87 2d 03 00 00    	ja     8006ce <vprintfmt+0x39c>
  8003a1:	0f b6 c0             	movzbl %al,%eax
  8003a4:	ff 24 85 e0 11 80 00 	jmp    *0x8011e0(,%eax,4)
  8003ab:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ad:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003b1:	eb da                	jmp    80038d <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	89 de                	mov    %ebx,%esi
  8003b5:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ba:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  8003bd:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  8003c1:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  8003c4:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8003c7:	83 f8 09             	cmp    $0x9,%eax
  8003ca:	77 33                	ja     8003ff <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003cc:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003cf:	eb e9                	jmp    8003ba <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d4:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003da:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003de:	eb 1f                	jmp    8003ff <vprintfmt+0xcd>
  8003e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ea:	0f 49 c8             	cmovns %eax,%ecx
  8003ed:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	89 de                	mov    %ebx,%esi
  8003f2:	eb 99                	jmp    80038d <vprintfmt+0x5b>
  8003f4:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f6:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  8003fd:	eb 8e                	jmp    80038d <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8003ff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800403:	79 88                	jns    80038d <vprintfmt+0x5b>
				width = precision, precision = -1;
  800405:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800408:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80040d:	e9 7b ff ff ff       	jmp    80038d <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800412:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800417:	e9 71 ff ff ff       	jmp    80038d <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
  80041c:	8b 45 14             	mov    0x14(%ebp),%eax
  80041f:	8d 50 04             	lea    0x4(%eax),%edx
  800422:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  800425:	83 ec 08             	sub    $0x8,%esp
  800428:	ff 75 0c             	pushl  0xc(%ebp)
  80042b:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80042e:	03 08                	add    (%eax),%ecx
  800430:	51                   	push   %ecx
  800431:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
  800434:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
  800437:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
  80043e:	e9 1b ff ff ff       	jmp    80035e <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	8d 48 04             	lea    0x4(%eax),%ecx
  800449:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80044c:	8b 00                	mov    (%eax),%eax
  80044e:	83 f8 02             	cmp    $0x2,%eax
  800451:	74 1a                	je     80046d <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800453:	89 de                	mov    %ebx,%esi
  800455:	83 f8 04             	cmp    $0x4,%eax
  800458:	b8 00 00 00 00       	mov    $0x0,%eax
  80045d:	b9 00 04 00 00       	mov    $0x400,%ecx
  800462:	0f 44 c1             	cmove  %ecx,%eax
  800465:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800468:	e9 20 ff ff ff       	jmp    80038d <vprintfmt+0x5b>
  80046d:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
  80046f:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
  800476:	e9 12 ff ff ff       	jmp    80038d <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80047b:	8b 45 14             	mov    0x14(%ebp),%eax
  80047e:	8d 50 04             	lea    0x4(%eax),%edx
  800481:	89 55 14             	mov    %edx,0x14(%ebp)
  800484:	8b 00                	mov    (%eax),%eax
  800486:	99                   	cltd   
  800487:	31 d0                	xor    %edx,%eax
  800489:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048b:	83 f8 09             	cmp    $0x9,%eax
  80048e:	7f 0b                	jg     80049b <vprintfmt+0x169>
  800490:	8b 14 85 40 13 80 00 	mov    0x801340(,%eax,4),%edx
  800497:	85 d2                	test   %edx,%edx
  800499:	75 19                	jne    8004b4 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  80049b:	50                   	push   %eax
  80049c:	68 33 11 80 00       	push   $0x801133
  8004a1:	ff 75 0c             	pushl  0xc(%ebp)
  8004a4:	ff 75 08             	pushl  0x8(%ebp)
  8004a7:	e8 69 fe ff ff       	call   800315 <printfmt>
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	e9 aa fe ff ff       	jmp    80035e <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  8004b4:	52                   	push   %edx
  8004b5:	68 3c 11 80 00       	push   $0x80113c
  8004ba:	ff 75 0c             	pushl  0xc(%ebp)
  8004bd:	ff 75 08             	pushl  0x8(%ebp)
  8004c0:	e8 50 fe ff ff       	call   800315 <printfmt>
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	e9 91 fe ff ff       	jmp    80035e <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d0:	8d 50 04             	lea    0x4(%eax),%edx
  8004d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d6:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004d8:	85 f6                	test   %esi,%esi
  8004da:	b8 2c 11 80 00       	mov    $0x80112c,%eax
  8004df:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8004e2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e6:	0f 8e 93 00 00 00    	jle    80057f <vprintfmt+0x24d>
  8004ec:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004f0:	0f 84 91 00 00 00    	je     800587 <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f6:	83 ec 08             	sub    $0x8,%esp
  8004f9:	57                   	push   %edi
  8004fa:	56                   	push   %esi
  8004fb:	e8 76 02 00 00       	call   800776 <strnlen>
  800500:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800503:	29 c1                	sub    %eax,%ecx
  800505:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800508:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80050b:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  80050f:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800512:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800515:	8b 75 0c             	mov    0xc(%ebp),%esi
  800518:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80051b:	89 cb                	mov    %ecx,%ebx
  80051d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051f:	eb 0e                	jmp    80052f <vprintfmt+0x1fd>
					putch(padc, putdat);
  800521:	83 ec 08             	sub    $0x8,%esp
  800524:	56                   	push   %esi
  800525:	57                   	push   %edi
  800526:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800529:	83 eb 01             	sub    $0x1,%ebx
  80052c:	83 c4 10             	add    $0x10,%esp
  80052f:	85 db                	test   %ebx,%ebx
  800531:	7f ee                	jg     800521 <vprintfmt+0x1ef>
  800533:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800536:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800539:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80053c:	85 c9                	test   %ecx,%ecx
  80053e:	b8 00 00 00 00       	mov    $0x0,%eax
  800543:	0f 49 c1             	cmovns %ecx,%eax
  800546:	29 c1                	sub    %eax,%ecx
  800548:	89 cb                	mov    %ecx,%ebx
  80054a:	eb 41                	jmp    80058d <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80054c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800550:	74 1b                	je     80056d <vprintfmt+0x23b>
  800552:	0f be c0             	movsbl %al,%eax
  800555:	83 e8 20             	sub    $0x20,%eax
  800558:	83 f8 5e             	cmp    $0x5e,%eax
  80055b:	76 10                	jbe    80056d <vprintfmt+0x23b>
					putch('?', putdat);
  80055d:	83 ec 08             	sub    $0x8,%esp
  800560:	ff 75 0c             	pushl  0xc(%ebp)
  800563:	6a 3f                	push   $0x3f
  800565:	ff 55 08             	call   *0x8(%ebp)
  800568:	83 c4 10             	add    $0x10,%esp
  80056b:	eb 0d                	jmp    80057a <vprintfmt+0x248>
				else
					putch(ch, putdat);
  80056d:	83 ec 08             	sub    $0x8,%esp
  800570:	ff 75 0c             	pushl  0xc(%ebp)
  800573:	52                   	push   %edx
  800574:	ff 55 08             	call   *0x8(%ebp)
  800577:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057a:	83 eb 01             	sub    $0x1,%ebx
  80057d:	eb 0e                	jmp    80058d <vprintfmt+0x25b>
  80057f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800582:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800585:	eb 06                	jmp    80058d <vprintfmt+0x25b>
  800587:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80058a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058d:	83 c6 01             	add    $0x1,%esi
  800590:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800594:	0f be d0             	movsbl %al,%edx
  800597:	85 d2                	test   %edx,%edx
  800599:	74 25                	je     8005c0 <vprintfmt+0x28e>
  80059b:	85 ff                	test   %edi,%edi
  80059d:	78 ad                	js     80054c <vprintfmt+0x21a>
  80059f:	83 ef 01             	sub    $0x1,%edi
  8005a2:	79 a8                	jns    80054c <vprintfmt+0x21a>
  8005a4:	89 d8                	mov    %ebx,%eax
  8005a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005ac:	89 c3                	mov    %eax,%ebx
  8005ae:	eb 16                	jmp    8005c6 <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005b0:	83 ec 08             	sub    $0x8,%esp
  8005b3:	57                   	push   %edi
  8005b4:	6a 20                	push   $0x20
  8005b6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b8:	83 eb 01             	sub    $0x1,%ebx
  8005bb:	83 c4 10             	add    $0x10,%esp
  8005be:	eb 06                	jmp    8005c6 <vprintfmt+0x294>
  8005c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c3:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005c6:	85 db                	test   %ebx,%ebx
  8005c8:	7f e6                	jg     8005b0 <vprintfmt+0x27e>
  8005ca:	89 75 08             	mov    %esi,0x8(%ebp)
  8005cd:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005d3:	e9 86 fd ff ff       	jmp    80035e <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d8:	83 fa 01             	cmp    $0x1,%edx
  8005db:	7e 10                	jle    8005ed <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8d 50 08             	lea    0x8(%eax),%edx
  8005e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e6:	8b 30                	mov    (%eax),%esi
  8005e8:	8b 78 04             	mov    0x4(%eax),%edi
  8005eb:	eb 26                	jmp    800613 <vprintfmt+0x2e1>
	else if (lflag)
  8005ed:	85 d2                	test   %edx,%edx
  8005ef:	74 12                	je     800603 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8d 50 04             	lea    0x4(%eax),%edx
  8005f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fa:	8b 30                	mov    (%eax),%esi
  8005fc:	89 f7                	mov    %esi,%edi
  8005fe:	c1 ff 1f             	sar    $0x1f,%edi
  800601:	eb 10                	jmp    800613 <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8d 50 04             	lea    0x4(%eax),%edx
  800609:	89 55 14             	mov    %edx,0x14(%ebp)
  80060c:	8b 30                	mov    (%eax),%esi
  80060e:	89 f7                	mov    %esi,%edi
  800610:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800613:	89 f0                	mov    %esi,%eax
  800615:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800617:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80061c:	85 ff                	test   %edi,%edi
  80061e:	79 7b                	jns    80069b <vprintfmt+0x369>
				putch('-', putdat);
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	ff 75 0c             	pushl  0xc(%ebp)
  800626:	6a 2d                	push   $0x2d
  800628:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80062b:	89 f0                	mov    %esi,%eax
  80062d:	89 fa                	mov    %edi,%edx
  80062f:	f7 d8                	neg    %eax
  800631:	83 d2 00             	adc    $0x0,%edx
  800634:	f7 da                	neg    %edx
  800636:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800639:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80063e:	eb 5b                	jmp    80069b <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800640:	8d 45 14             	lea    0x14(%ebp),%eax
  800643:	e8 76 fc ff ff       	call   8002be <getuint>
			base = 10;
  800648:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80064d:	eb 4c                	jmp    80069b <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
  80064f:	8d 45 14             	lea    0x14(%ebp),%eax
  800652:	e8 67 fc ff ff       	call   8002be <getuint>
            base = 8;
  800657:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80065c:	eb 3d                	jmp    80069b <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	ff 75 0c             	pushl  0xc(%ebp)
  800664:	6a 30                	push   $0x30
  800666:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800669:	83 c4 08             	add    $0x8,%esp
  80066c:	ff 75 0c             	pushl  0xc(%ebp)
  80066f:	6a 78                	push   $0x78
  800671:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8d 50 04             	lea    0x4(%eax),%edx
  80067a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80067d:	8b 00                	mov    (%eax),%eax
  80067f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800684:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800687:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80068c:	eb 0d                	jmp    80069b <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80068e:	8d 45 14             	lea    0x14(%ebp),%eax
  800691:	e8 28 fc ff ff       	call   8002be <getuint>
			base = 16;
  800696:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80069b:	83 ec 0c             	sub    $0xc,%esp
  80069e:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  8006a2:	56                   	push   %esi
  8006a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a6:	51                   	push   %ecx
  8006a7:	52                   	push   %edx
  8006a8:	50                   	push   %eax
  8006a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8006af:	e8 5b fb ff ff       	call   80020f <printnum>
			break;
  8006b4:	83 c4 20             	add    $0x20,%esp
  8006b7:	e9 a2 fc ff ff       	jmp    80035e <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	ff 75 0c             	pushl  0xc(%ebp)
  8006c2:	51                   	push   %ecx
  8006c3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006c6:	83 c4 10             	add    $0x10,%esp
  8006c9:	e9 90 fc ff ff       	jmp    80035e <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ce:	83 ec 08             	sub    $0x8,%esp
  8006d1:	ff 75 0c             	pushl  0xc(%ebp)
  8006d4:	6a 25                	push   $0x25
  8006d6:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d9:	83 c4 10             	add    $0x10,%esp
  8006dc:	89 f3                	mov    %esi,%ebx
  8006de:	eb 03                	jmp    8006e3 <vprintfmt+0x3b1>
  8006e0:	83 eb 01             	sub    $0x1,%ebx
  8006e3:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006e7:	75 f7                	jne    8006e0 <vprintfmt+0x3ae>
  8006e9:	e9 70 fc ff ff       	jmp    80035e <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  8006ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f1:	5b                   	pop    %ebx
  8006f2:	5e                   	pop    %esi
  8006f3:	5f                   	pop    %edi
  8006f4:	5d                   	pop    %ebp
  8006f5:	c3                   	ret    

008006f6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	83 ec 18             	sub    $0x18,%esp
  8006fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ff:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800702:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800705:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800709:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800713:	85 c0                	test   %eax,%eax
  800715:	74 26                	je     80073d <vsnprintf+0x47>
  800717:	85 d2                	test   %edx,%edx
  800719:	7e 22                	jle    80073d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071b:	ff 75 14             	pushl  0x14(%ebp)
  80071e:	ff 75 10             	pushl  0x10(%ebp)
  800721:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800724:	50                   	push   %eax
  800725:	68 f8 02 80 00       	push   $0x8002f8
  80072a:	e8 03 fc ff ff       	call   800332 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800732:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800735:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	eb 05                	jmp    800742 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800742:	c9                   	leave  
  800743:	c3                   	ret    

00800744 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074d:	50                   	push   %eax
  80074e:	ff 75 10             	pushl  0x10(%ebp)
  800751:	ff 75 0c             	pushl  0xc(%ebp)
  800754:	ff 75 08             	pushl  0x8(%ebp)
  800757:	e8 9a ff ff ff       	call   8006f6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075c:	c9                   	leave  
  80075d:	c3                   	ret    

0080075e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800764:	b8 00 00 00 00       	mov    $0x0,%eax
  800769:	eb 03                	jmp    80076e <strlen+0x10>
		n++;
  80076b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80076e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800772:	75 f7                	jne    80076b <strlen+0xd>
		n++;
	return n;
}
  800774:	5d                   	pop    %ebp
  800775:	c3                   	ret    

00800776 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077f:	ba 00 00 00 00       	mov    $0x0,%edx
  800784:	eb 03                	jmp    800789 <strnlen+0x13>
		n++;
  800786:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800789:	39 c2                	cmp    %eax,%edx
  80078b:	74 08                	je     800795 <strnlen+0x1f>
  80078d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800791:	75 f3                	jne    800786 <strnlen+0x10>
  800793:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	53                   	push   %ebx
  80079b:	8b 45 08             	mov    0x8(%ebp),%eax
  80079e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a1:	89 c2                	mov    %eax,%edx
  8007a3:	83 c2 01             	add    $0x1,%edx
  8007a6:	83 c1 01             	add    $0x1,%ecx
  8007a9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ad:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b0:	84 db                	test   %bl,%bl
  8007b2:	75 ef                	jne    8007a3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b4:	5b                   	pop    %ebx
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	53                   	push   %ebx
  8007bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007be:	53                   	push   %ebx
  8007bf:	e8 9a ff ff ff       	call   80075e <strlen>
  8007c4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ca:	01 d8                	add    %ebx,%eax
  8007cc:	50                   	push   %eax
  8007cd:	e8 c5 ff ff ff       	call   800797 <strcpy>
	return dst;
}
  8007d2:	89 d8                	mov    %ebx,%eax
  8007d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    

008007d9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	56                   	push   %esi
  8007dd:	53                   	push   %ebx
  8007de:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e4:	89 f3                	mov    %esi,%ebx
  8007e6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e9:	89 f2                	mov    %esi,%edx
  8007eb:	eb 0f                	jmp    8007fc <strncpy+0x23>
		*dst++ = *src;
  8007ed:	83 c2 01             	add    $0x1,%edx
  8007f0:	0f b6 01             	movzbl (%ecx),%eax
  8007f3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f6:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fc:	39 da                	cmp    %ebx,%edx
  8007fe:	75 ed                	jne    8007ed <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800800:	89 f0                	mov    %esi,%eax
  800802:	5b                   	pop    %ebx
  800803:	5e                   	pop    %esi
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    

00800806 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	56                   	push   %esi
  80080a:	53                   	push   %ebx
  80080b:	8b 75 08             	mov    0x8(%ebp),%esi
  80080e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800811:	8b 55 10             	mov    0x10(%ebp),%edx
  800814:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800816:	85 d2                	test   %edx,%edx
  800818:	74 21                	je     80083b <strlcpy+0x35>
  80081a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80081e:	89 f2                	mov    %esi,%edx
  800820:	eb 09                	jmp    80082b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800822:	83 c2 01             	add    $0x1,%edx
  800825:	83 c1 01             	add    $0x1,%ecx
  800828:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80082b:	39 c2                	cmp    %eax,%edx
  80082d:	74 09                	je     800838 <strlcpy+0x32>
  80082f:	0f b6 19             	movzbl (%ecx),%ebx
  800832:	84 db                	test   %bl,%bl
  800834:	75 ec                	jne    800822 <strlcpy+0x1c>
  800836:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800838:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80083b:	29 f0                	sub    %esi,%eax
}
  80083d:	5b                   	pop    %ebx
  80083e:	5e                   	pop    %esi
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800847:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084a:	eb 06                	jmp    800852 <strcmp+0x11>
		p++, q++;
  80084c:	83 c1 01             	add    $0x1,%ecx
  80084f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800852:	0f b6 01             	movzbl (%ecx),%eax
  800855:	84 c0                	test   %al,%al
  800857:	74 04                	je     80085d <strcmp+0x1c>
  800859:	3a 02                	cmp    (%edx),%al
  80085b:	74 ef                	je     80084c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085d:	0f b6 c0             	movzbl %al,%eax
  800860:	0f b6 12             	movzbl (%edx),%edx
  800863:	29 d0                	sub    %edx,%eax
}
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800871:	89 c3                	mov    %eax,%ebx
  800873:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800876:	eb 06                	jmp    80087e <strncmp+0x17>
		n--, p++, q++;
  800878:	83 c0 01             	add    $0x1,%eax
  80087b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80087e:	39 d8                	cmp    %ebx,%eax
  800880:	74 15                	je     800897 <strncmp+0x30>
  800882:	0f b6 08             	movzbl (%eax),%ecx
  800885:	84 c9                	test   %cl,%cl
  800887:	74 04                	je     80088d <strncmp+0x26>
  800889:	3a 0a                	cmp    (%edx),%cl
  80088b:	74 eb                	je     800878 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088d:	0f b6 00             	movzbl (%eax),%eax
  800890:	0f b6 12             	movzbl (%edx),%edx
  800893:	29 d0                	sub    %edx,%eax
  800895:	eb 05                	jmp    80089c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800897:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80089c:	5b                   	pop    %ebx
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a9:	eb 07                	jmp    8008b2 <strchr+0x13>
		if (*s == c)
  8008ab:	38 ca                	cmp    %cl,%dl
  8008ad:	74 0f                	je     8008be <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008af:	83 c0 01             	add    $0x1,%eax
  8008b2:	0f b6 10             	movzbl (%eax),%edx
  8008b5:	84 d2                	test   %dl,%dl
  8008b7:	75 f2                	jne    8008ab <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ca:	eb 03                	jmp    8008cf <strfind+0xf>
  8008cc:	83 c0 01             	add    $0x1,%eax
  8008cf:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d2:	38 ca                	cmp    %cl,%dl
  8008d4:	74 04                	je     8008da <strfind+0x1a>
  8008d6:	84 d2                	test   %dl,%dl
  8008d8:	75 f2                	jne    8008cc <strfind+0xc>
			break;
	return (char *) s;
}
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	57                   	push   %edi
  8008e0:	56                   	push   %esi
  8008e1:	53                   	push   %ebx
  8008e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e8:	85 c9                	test   %ecx,%ecx
  8008ea:	74 36                	je     800922 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ec:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f2:	75 28                	jne    80091c <memset+0x40>
  8008f4:	f6 c1 03             	test   $0x3,%cl
  8008f7:	75 23                	jne    80091c <memset+0x40>
		c &= 0xFF;
  8008f9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fd:	89 d3                	mov    %edx,%ebx
  8008ff:	c1 e3 08             	shl    $0x8,%ebx
  800902:	89 d6                	mov    %edx,%esi
  800904:	c1 e6 18             	shl    $0x18,%esi
  800907:	89 d0                	mov    %edx,%eax
  800909:	c1 e0 10             	shl    $0x10,%eax
  80090c:	09 f0                	or     %esi,%eax
  80090e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800910:	89 d8                	mov    %ebx,%eax
  800912:	09 d0                	or     %edx,%eax
  800914:	c1 e9 02             	shr    $0x2,%ecx
  800917:	fc                   	cld    
  800918:	f3 ab                	rep stos %eax,%es:(%edi)
  80091a:	eb 06                	jmp    800922 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091f:	fc                   	cld    
  800920:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800922:	89 f8                	mov    %edi,%eax
  800924:	5b                   	pop    %ebx
  800925:	5e                   	pop    %esi
  800926:	5f                   	pop    %edi
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	57                   	push   %edi
  80092d:	56                   	push   %esi
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	8b 75 0c             	mov    0xc(%ebp),%esi
  800934:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800937:	39 c6                	cmp    %eax,%esi
  800939:	73 35                	jae    800970 <memmove+0x47>
  80093b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093e:	39 d0                	cmp    %edx,%eax
  800940:	73 2e                	jae    800970 <memmove+0x47>
		s += n;
		d += n;
  800942:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800945:	89 d6                	mov    %edx,%esi
  800947:	09 fe                	or     %edi,%esi
  800949:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094f:	75 13                	jne    800964 <memmove+0x3b>
  800951:	f6 c1 03             	test   $0x3,%cl
  800954:	75 0e                	jne    800964 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800956:	83 ef 04             	sub    $0x4,%edi
  800959:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095c:	c1 e9 02             	shr    $0x2,%ecx
  80095f:	fd                   	std    
  800960:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800962:	eb 09                	jmp    80096d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800964:	83 ef 01             	sub    $0x1,%edi
  800967:	8d 72 ff             	lea    -0x1(%edx),%esi
  80096a:	fd                   	std    
  80096b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096d:	fc                   	cld    
  80096e:	eb 1d                	jmp    80098d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800970:	89 f2                	mov    %esi,%edx
  800972:	09 c2                	or     %eax,%edx
  800974:	f6 c2 03             	test   $0x3,%dl
  800977:	75 0f                	jne    800988 <memmove+0x5f>
  800979:	f6 c1 03             	test   $0x3,%cl
  80097c:	75 0a                	jne    800988 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80097e:	c1 e9 02             	shr    $0x2,%ecx
  800981:	89 c7                	mov    %eax,%edi
  800983:	fc                   	cld    
  800984:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800986:	eb 05                	jmp    80098d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800988:	89 c7                	mov    %eax,%edi
  80098a:	fc                   	cld    
  80098b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098d:	5e                   	pop    %esi
  80098e:	5f                   	pop    %edi
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800994:	ff 75 10             	pushl  0x10(%ebp)
  800997:	ff 75 0c             	pushl  0xc(%ebp)
  80099a:	ff 75 08             	pushl  0x8(%ebp)
  80099d:	e8 87 ff ff ff       	call   800929 <memmove>
}
  8009a2:	c9                   	leave  
  8009a3:	c3                   	ret    

008009a4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	56                   	push   %esi
  8009a8:	53                   	push   %ebx
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009af:	89 c6                	mov    %eax,%esi
  8009b1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b4:	eb 1a                	jmp    8009d0 <memcmp+0x2c>
		if (*s1 != *s2)
  8009b6:	0f b6 08             	movzbl (%eax),%ecx
  8009b9:	0f b6 1a             	movzbl (%edx),%ebx
  8009bc:	38 d9                	cmp    %bl,%cl
  8009be:	74 0a                	je     8009ca <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009c0:	0f b6 c1             	movzbl %cl,%eax
  8009c3:	0f b6 db             	movzbl %bl,%ebx
  8009c6:	29 d8                	sub    %ebx,%eax
  8009c8:	eb 0f                	jmp    8009d9 <memcmp+0x35>
		s1++, s2++;
  8009ca:	83 c0 01             	add    $0x1,%eax
  8009cd:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d0:	39 f0                	cmp    %esi,%eax
  8009d2:	75 e2                	jne    8009b6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d9:	5b                   	pop    %ebx
  8009da:	5e                   	pop    %esi
  8009db:	5d                   	pop    %ebp
  8009dc:	c3                   	ret    

008009dd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	53                   	push   %ebx
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009e4:	89 c1                	mov    %eax,%ecx
  8009e6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ed:	eb 0a                	jmp    8009f9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ef:	0f b6 10             	movzbl (%eax),%edx
  8009f2:	39 da                	cmp    %ebx,%edx
  8009f4:	74 07                	je     8009fd <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f6:	83 c0 01             	add    $0x1,%eax
  8009f9:	39 c8                	cmp    %ecx,%eax
  8009fb:	72 f2                	jb     8009ef <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009fd:	5b                   	pop    %ebx
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	57                   	push   %edi
  800a04:	56                   	push   %esi
  800a05:	53                   	push   %ebx
  800a06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a09:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0c:	eb 03                	jmp    800a11 <strtol+0x11>
		s++;
  800a0e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a11:	0f b6 01             	movzbl (%ecx),%eax
  800a14:	3c 20                	cmp    $0x20,%al
  800a16:	74 f6                	je     800a0e <strtol+0xe>
  800a18:	3c 09                	cmp    $0x9,%al
  800a1a:	74 f2                	je     800a0e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a1c:	3c 2b                	cmp    $0x2b,%al
  800a1e:	75 0a                	jne    800a2a <strtol+0x2a>
		s++;
  800a20:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a23:	bf 00 00 00 00       	mov    $0x0,%edi
  800a28:	eb 11                	jmp    800a3b <strtol+0x3b>
  800a2a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a2f:	3c 2d                	cmp    $0x2d,%al
  800a31:	75 08                	jne    800a3b <strtol+0x3b>
		s++, neg = 1;
  800a33:	83 c1 01             	add    $0x1,%ecx
  800a36:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a41:	75 15                	jne    800a58 <strtol+0x58>
  800a43:	80 39 30             	cmpb   $0x30,(%ecx)
  800a46:	75 10                	jne    800a58 <strtol+0x58>
  800a48:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a4c:	75 7c                	jne    800aca <strtol+0xca>
		s += 2, base = 16;
  800a4e:	83 c1 02             	add    $0x2,%ecx
  800a51:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a56:	eb 16                	jmp    800a6e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a58:	85 db                	test   %ebx,%ebx
  800a5a:	75 12                	jne    800a6e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a61:	80 39 30             	cmpb   $0x30,(%ecx)
  800a64:	75 08                	jne    800a6e <strtol+0x6e>
		s++, base = 8;
  800a66:	83 c1 01             	add    $0x1,%ecx
  800a69:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a73:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a76:	0f b6 11             	movzbl (%ecx),%edx
  800a79:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a7c:	89 f3                	mov    %esi,%ebx
  800a7e:	80 fb 09             	cmp    $0x9,%bl
  800a81:	77 08                	ja     800a8b <strtol+0x8b>
			dig = *s - '0';
  800a83:	0f be d2             	movsbl %dl,%edx
  800a86:	83 ea 30             	sub    $0x30,%edx
  800a89:	eb 22                	jmp    800aad <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a8b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a8e:	89 f3                	mov    %esi,%ebx
  800a90:	80 fb 19             	cmp    $0x19,%bl
  800a93:	77 08                	ja     800a9d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a95:	0f be d2             	movsbl %dl,%edx
  800a98:	83 ea 57             	sub    $0x57,%edx
  800a9b:	eb 10                	jmp    800aad <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a9d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa0:	89 f3                	mov    %esi,%ebx
  800aa2:	80 fb 19             	cmp    $0x19,%bl
  800aa5:	77 16                	ja     800abd <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aa7:	0f be d2             	movsbl %dl,%edx
  800aaa:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aad:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab0:	7d 0b                	jge    800abd <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ab2:	83 c1 01             	add    $0x1,%ecx
  800ab5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800abb:	eb b9                	jmp    800a76 <strtol+0x76>

	if (endptr)
  800abd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac1:	74 0d                	je     800ad0 <strtol+0xd0>
		*endptr = (char *) s;
  800ac3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac6:	89 0e                	mov    %ecx,(%esi)
  800ac8:	eb 06                	jmp    800ad0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aca:	85 db                	test   %ebx,%ebx
  800acc:	74 98                	je     800a66 <strtol+0x66>
  800ace:	eb 9e                	jmp    800a6e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ad0:	89 c2                	mov    %eax,%edx
  800ad2:	f7 da                	neg    %edx
  800ad4:	85 ff                	test   %edi,%edi
  800ad6:	0f 45 c2             	cmovne %edx,%eax
}
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aec:	8b 55 08             	mov    0x8(%ebp),%edx
  800aef:	89 c3                	mov    %eax,%ebx
  800af1:	89 c7                	mov    %eax,%edi
  800af3:	89 c6                	mov    %eax,%esi
  800af5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5f                   	pop    %edi
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <sys_cgetc>:

int
sys_cgetc(void)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	57                   	push   %edi
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b02:	ba 00 00 00 00       	mov    $0x0,%edx
  800b07:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0c:	89 d1                	mov    %edx,%ecx
  800b0e:	89 d3                	mov    %edx,%ebx
  800b10:	89 d7                	mov    %edx,%edi
  800b12:	89 d6                	mov    %edx,%esi
  800b14:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
  800b21:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b24:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b29:	b8 03 00 00 00       	mov    $0x3,%eax
  800b2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b31:	89 cb                	mov    %ecx,%ebx
  800b33:	89 cf                	mov    %ecx,%edi
  800b35:	89 ce                	mov    %ecx,%esi
  800b37:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b39:	85 c0                	test   %eax,%eax
  800b3b:	7e 17                	jle    800b54 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3d:	83 ec 0c             	sub    $0xc,%esp
  800b40:	50                   	push   %eax
  800b41:	6a 03                	push   $0x3
  800b43:	68 68 13 80 00       	push   $0x801368
  800b48:	6a 23                	push   $0x23
  800b4a:	68 85 13 80 00       	push   $0x801385
  800b4f:	e8 ce f5 ff ff       	call   800122 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b62:	ba 00 00 00 00       	mov    $0x0,%edx
  800b67:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6c:	89 d1                	mov    %edx,%ecx
  800b6e:	89 d3                	mov    %edx,%ebx
  800b70:	89 d7                	mov    %edx,%edi
  800b72:	89 d6                	mov    %edx,%esi
  800b74:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <sys_yield>:

void
sys_yield(void)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b81:	ba 00 00 00 00       	mov    $0x0,%edx
  800b86:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b8b:	89 d1                	mov    %edx,%ecx
  800b8d:	89 d3                	mov    %edx,%ebx
  800b8f:	89 d7                	mov    %edx,%edi
  800b91:	89 d6                	mov    %edx,%esi
  800b93:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
  800ba0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba3:	be 00 00 00 00       	mov    $0x0,%esi
  800ba8:	b8 04 00 00 00       	mov    $0x4,%eax
  800bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb6:	89 f7                	mov    %esi,%edi
  800bb8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bba:	85 c0                	test   %eax,%eax
  800bbc:	7e 17                	jle    800bd5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbe:	83 ec 0c             	sub    $0xc,%esp
  800bc1:	50                   	push   %eax
  800bc2:	6a 04                	push   $0x4
  800bc4:	68 68 13 80 00       	push   $0x801368
  800bc9:	6a 23                	push   $0x23
  800bcb:	68 85 13 80 00       	push   $0x801385
  800bd0:	e8 4d f5 ff ff       	call   800122 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
  800be3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be6:	b8 05 00 00 00       	mov    $0x5,%eax
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bee:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf7:	8b 75 18             	mov    0x18(%ebp),%esi
  800bfa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bfc:	85 c0                	test   %eax,%eax
  800bfe:	7e 17                	jle    800c17 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c00:	83 ec 0c             	sub    $0xc,%esp
  800c03:	50                   	push   %eax
  800c04:	6a 05                	push   $0x5
  800c06:	68 68 13 80 00       	push   $0x801368
  800c0b:	6a 23                	push   $0x23
  800c0d:	68 85 13 80 00       	push   $0x801385
  800c12:	e8 0b f5 ff ff       	call   800122 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1a:	5b                   	pop    %ebx
  800c1b:	5e                   	pop    %esi
  800c1c:	5f                   	pop    %edi
  800c1d:	5d                   	pop    %ebp
  800c1e:	c3                   	ret    

00800c1f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	57                   	push   %edi
  800c23:	56                   	push   %esi
  800c24:	53                   	push   %ebx
  800c25:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c28:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2d:	b8 06 00 00 00       	mov    $0x6,%eax
  800c32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c35:	8b 55 08             	mov    0x8(%ebp),%edx
  800c38:	89 df                	mov    %ebx,%edi
  800c3a:	89 de                	mov    %ebx,%esi
  800c3c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3e:	85 c0                	test   %eax,%eax
  800c40:	7e 17                	jle    800c59 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c42:	83 ec 0c             	sub    $0xc,%esp
  800c45:	50                   	push   %eax
  800c46:	6a 06                	push   $0x6
  800c48:	68 68 13 80 00       	push   $0x801368
  800c4d:	6a 23                	push   $0x23
  800c4f:	68 85 13 80 00       	push   $0x801385
  800c54:	e8 c9 f4 ff ff       	call   800122 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6f:	b8 08 00 00 00       	mov    $0x8,%eax
  800c74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c77:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7a:	89 df                	mov    %ebx,%edi
  800c7c:	89 de                	mov    %ebx,%esi
  800c7e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c80:	85 c0                	test   %eax,%eax
  800c82:	7e 17                	jle    800c9b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c84:	83 ec 0c             	sub    $0xc,%esp
  800c87:	50                   	push   %eax
  800c88:	6a 08                	push   $0x8
  800c8a:	68 68 13 80 00       	push   $0x801368
  800c8f:	6a 23                	push   $0x23
  800c91:	68 85 13 80 00       	push   $0x801385
  800c96:	e8 87 f4 ff ff       	call   800122 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9e:	5b                   	pop    %ebx
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
  800ca9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb1:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbc:	89 df                	mov    %ebx,%edi
  800cbe:	89 de                	mov    %ebx,%esi
  800cc0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc2:	85 c0                	test   %eax,%eax
  800cc4:	7e 17                	jle    800cdd <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc6:	83 ec 0c             	sub    $0xc,%esp
  800cc9:	50                   	push   %eax
  800cca:	6a 09                	push   $0x9
  800ccc:	68 68 13 80 00       	push   $0x801368
  800cd1:	6a 23                	push   $0x23
  800cd3:	68 85 13 80 00       	push   $0x801385
  800cd8:	e8 45 f4 ff ff       	call   800122 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ceb:	be 00 00 00 00       	mov    $0x0,%esi
  800cf0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d01:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
  800d0e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d11:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d16:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1e:	89 cb                	mov    %ecx,%ebx
  800d20:	89 cf                	mov    %ecx,%edi
  800d22:	89 ce                	mov    %ecx,%esi
  800d24:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d26:	85 c0                	test   %eax,%eax
  800d28:	7e 17                	jle    800d41 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2a:	83 ec 0c             	sub    $0xc,%esp
  800d2d:	50                   	push   %eax
  800d2e:	6a 0c                	push   $0xc
  800d30:	68 68 13 80 00       	push   $0x801368
  800d35:	6a 23                	push   $0x23
  800d37:	68 85 13 80 00       	push   $0x801385
  800d3c:	e8 e1 f3 ff ff       	call   800122 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d4f:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d56:	75 4c                	jne    800da4 <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.

        void *va = (void *)(UXSTACKTOP - PGSIZE);
        if (sys_page_alloc(thisenv->env_id, va, PTE_P | PTE_U | PTE_W))
  800d58:	a1 04 20 80 00       	mov    0x802004,%eax
  800d5d:	8b 40 48             	mov    0x48(%eax),%eax
  800d60:	83 ec 04             	sub    $0x4,%esp
  800d63:	6a 07                	push   $0x7
  800d65:	68 00 f0 bf ee       	push   $0xeebff000
  800d6a:	50                   	push   %eax
  800d6b:	e8 2a fe ff ff       	call   800b9a <sys_page_alloc>
  800d70:	83 c4 10             	add    $0x10,%esp
  800d73:	85 c0                	test   %eax,%eax
  800d75:	74 14                	je     800d8b <set_pgfault_handler+0x42>
        {
            panic("Unable to allocate memory for pgfault expected\n");
  800d77:	83 ec 04             	sub    $0x4,%esp
  800d7a:	68 94 13 80 00       	push   $0x801394
  800d7f:	6a 24                	push   $0x24
  800d81:	68 c4 13 80 00       	push   $0x8013c4
  800d86:	e8 97 f3 ff ff       	call   800122 <_panic>
        }

        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800d8b:	a1 04 20 80 00       	mov    0x802004,%eax
  800d90:	8b 40 48             	mov    0x48(%eax),%eax
  800d93:	83 ec 08             	sub    $0x8,%esp
  800d96:	68 ae 0d 80 00       	push   $0x800dae
  800d9b:	50                   	push   %eax
  800d9c:	e8 02 ff ff ff       	call   800ca3 <sys_env_set_pgfault_upcall>
  800da1:	83 c4 10             	add    $0x10,%esp

		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800da4:	8b 45 08             	mov    0x8(%ebp),%eax
  800da7:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800dac:	c9                   	leave  
  800dad:	c3                   	ret    

00800dae <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800dae:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800daf:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800db4:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800db6:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
    movl %esp, %ebx
  800db9:	89 e3                	mov    %esp,%ebx
    // 40 is the size between utf_fault_va ~ utf_regs
    movl 40(%esp), %eax
  800dbb:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 48(%esp), %esp
  800dbf:	8b 64 24 30          	mov    0x30(%esp),%esp
    pushl %eax
  800dc3:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    movl %ebx, %esp
  800dc4:	89 dc                	mov    %ebx,%esp
    subl $4, 48(%esp)
  800dc6:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    popl %eax
  800dcb:	58                   	pop    %eax
    popl %eax
  800dcc:	58                   	pop    %eax
    popal
  800dcd:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  800dce:	83 c4 04             	add    $0x4,%esp
    popfl
  800dd1:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp
  800dd2:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  800dd3:	c3                   	ret    
  800dd4:	66 90                	xchg   %ax,%ax
  800dd6:	66 90                	xchg   %ax,%ax
  800dd8:	66 90                	xchg   %ax,%ax
  800dda:	66 90                	xchg   %ax,%ax
  800ddc:	66 90                	xchg   %ax,%ax
  800dde:	66 90                	xchg   %ax,%ax

00800de0 <__udivdi3>:
  800de0:	55                   	push   %ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	53                   	push   %ebx
  800de4:	83 ec 1c             	sub    $0x1c,%esp
  800de7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800deb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800def:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800df3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800df7:	85 f6                	test   %esi,%esi
  800df9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800dfd:	89 ca                	mov    %ecx,%edx
  800dff:	89 f8                	mov    %edi,%eax
  800e01:	75 3d                	jne    800e40 <__udivdi3+0x60>
  800e03:	39 cf                	cmp    %ecx,%edi
  800e05:	0f 87 c5 00 00 00    	ja     800ed0 <__udivdi3+0xf0>
  800e0b:	85 ff                	test   %edi,%edi
  800e0d:	89 fd                	mov    %edi,%ebp
  800e0f:	75 0b                	jne    800e1c <__udivdi3+0x3c>
  800e11:	b8 01 00 00 00       	mov    $0x1,%eax
  800e16:	31 d2                	xor    %edx,%edx
  800e18:	f7 f7                	div    %edi
  800e1a:	89 c5                	mov    %eax,%ebp
  800e1c:	89 c8                	mov    %ecx,%eax
  800e1e:	31 d2                	xor    %edx,%edx
  800e20:	f7 f5                	div    %ebp
  800e22:	89 c1                	mov    %eax,%ecx
  800e24:	89 d8                	mov    %ebx,%eax
  800e26:	89 cf                	mov    %ecx,%edi
  800e28:	f7 f5                	div    %ebp
  800e2a:	89 c3                	mov    %eax,%ebx
  800e2c:	89 d8                	mov    %ebx,%eax
  800e2e:	89 fa                	mov    %edi,%edx
  800e30:	83 c4 1c             	add    $0x1c,%esp
  800e33:	5b                   	pop    %ebx
  800e34:	5e                   	pop    %esi
  800e35:	5f                   	pop    %edi
  800e36:	5d                   	pop    %ebp
  800e37:	c3                   	ret    
  800e38:	90                   	nop
  800e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e40:	39 ce                	cmp    %ecx,%esi
  800e42:	77 74                	ja     800eb8 <__udivdi3+0xd8>
  800e44:	0f bd fe             	bsr    %esi,%edi
  800e47:	83 f7 1f             	xor    $0x1f,%edi
  800e4a:	0f 84 98 00 00 00    	je     800ee8 <__udivdi3+0x108>
  800e50:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e55:	89 f9                	mov    %edi,%ecx
  800e57:	89 c5                	mov    %eax,%ebp
  800e59:	29 fb                	sub    %edi,%ebx
  800e5b:	d3 e6                	shl    %cl,%esi
  800e5d:	89 d9                	mov    %ebx,%ecx
  800e5f:	d3 ed                	shr    %cl,%ebp
  800e61:	89 f9                	mov    %edi,%ecx
  800e63:	d3 e0                	shl    %cl,%eax
  800e65:	09 ee                	or     %ebp,%esi
  800e67:	89 d9                	mov    %ebx,%ecx
  800e69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e6d:	89 d5                	mov    %edx,%ebp
  800e6f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e73:	d3 ed                	shr    %cl,%ebp
  800e75:	89 f9                	mov    %edi,%ecx
  800e77:	d3 e2                	shl    %cl,%edx
  800e79:	89 d9                	mov    %ebx,%ecx
  800e7b:	d3 e8                	shr    %cl,%eax
  800e7d:	09 c2                	or     %eax,%edx
  800e7f:	89 d0                	mov    %edx,%eax
  800e81:	89 ea                	mov    %ebp,%edx
  800e83:	f7 f6                	div    %esi
  800e85:	89 d5                	mov    %edx,%ebp
  800e87:	89 c3                	mov    %eax,%ebx
  800e89:	f7 64 24 0c          	mull   0xc(%esp)
  800e8d:	39 d5                	cmp    %edx,%ebp
  800e8f:	72 10                	jb     800ea1 <__udivdi3+0xc1>
  800e91:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e95:	89 f9                	mov    %edi,%ecx
  800e97:	d3 e6                	shl    %cl,%esi
  800e99:	39 c6                	cmp    %eax,%esi
  800e9b:	73 07                	jae    800ea4 <__udivdi3+0xc4>
  800e9d:	39 d5                	cmp    %edx,%ebp
  800e9f:	75 03                	jne    800ea4 <__udivdi3+0xc4>
  800ea1:	83 eb 01             	sub    $0x1,%ebx
  800ea4:	31 ff                	xor    %edi,%edi
  800ea6:	89 d8                	mov    %ebx,%eax
  800ea8:	89 fa                	mov    %edi,%edx
  800eaa:	83 c4 1c             	add    $0x1c,%esp
  800ead:	5b                   	pop    %ebx
  800eae:	5e                   	pop    %esi
  800eaf:	5f                   	pop    %edi
  800eb0:	5d                   	pop    %ebp
  800eb1:	c3                   	ret    
  800eb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800eb8:	31 ff                	xor    %edi,%edi
  800eba:	31 db                	xor    %ebx,%ebx
  800ebc:	89 d8                	mov    %ebx,%eax
  800ebe:	89 fa                	mov    %edi,%edx
  800ec0:	83 c4 1c             	add    $0x1c,%esp
  800ec3:	5b                   	pop    %ebx
  800ec4:	5e                   	pop    %esi
  800ec5:	5f                   	pop    %edi
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    
  800ec8:	90                   	nop
  800ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	89 d8                	mov    %ebx,%eax
  800ed2:	f7 f7                	div    %edi
  800ed4:	31 ff                	xor    %edi,%edi
  800ed6:	89 c3                	mov    %eax,%ebx
  800ed8:	89 d8                	mov    %ebx,%eax
  800eda:	89 fa                	mov    %edi,%edx
  800edc:	83 c4 1c             	add    $0x1c,%esp
  800edf:	5b                   	pop    %ebx
  800ee0:	5e                   	pop    %esi
  800ee1:	5f                   	pop    %edi
  800ee2:	5d                   	pop    %ebp
  800ee3:	c3                   	ret    
  800ee4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ee8:	39 ce                	cmp    %ecx,%esi
  800eea:	72 0c                	jb     800ef8 <__udivdi3+0x118>
  800eec:	31 db                	xor    %ebx,%ebx
  800eee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800ef2:	0f 87 34 ff ff ff    	ja     800e2c <__udivdi3+0x4c>
  800ef8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800efd:	e9 2a ff ff ff       	jmp    800e2c <__udivdi3+0x4c>
  800f02:	66 90                	xchg   %ax,%ax
  800f04:	66 90                	xchg   %ax,%ax
  800f06:	66 90                	xchg   %ax,%ax
  800f08:	66 90                	xchg   %ax,%ax
  800f0a:	66 90                	xchg   %ax,%ax
  800f0c:	66 90                	xchg   %ax,%ax
  800f0e:	66 90                	xchg   %ax,%ax

00800f10 <__umoddi3>:
  800f10:	55                   	push   %ebp
  800f11:	57                   	push   %edi
  800f12:	56                   	push   %esi
  800f13:	53                   	push   %ebx
  800f14:	83 ec 1c             	sub    $0x1c,%esp
  800f17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f1b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f27:	85 d2                	test   %edx,%edx
  800f29:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f31:	89 f3                	mov    %esi,%ebx
  800f33:	89 3c 24             	mov    %edi,(%esp)
  800f36:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f3a:	75 1c                	jne    800f58 <__umoddi3+0x48>
  800f3c:	39 f7                	cmp    %esi,%edi
  800f3e:	76 50                	jbe    800f90 <__umoddi3+0x80>
  800f40:	89 c8                	mov    %ecx,%eax
  800f42:	89 f2                	mov    %esi,%edx
  800f44:	f7 f7                	div    %edi
  800f46:	89 d0                	mov    %edx,%eax
  800f48:	31 d2                	xor    %edx,%edx
  800f4a:	83 c4 1c             	add    $0x1c,%esp
  800f4d:	5b                   	pop    %ebx
  800f4e:	5e                   	pop    %esi
  800f4f:	5f                   	pop    %edi
  800f50:	5d                   	pop    %ebp
  800f51:	c3                   	ret    
  800f52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f58:	39 f2                	cmp    %esi,%edx
  800f5a:	89 d0                	mov    %edx,%eax
  800f5c:	77 52                	ja     800fb0 <__umoddi3+0xa0>
  800f5e:	0f bd ea             	bsr    %edx,%ebp
  800f61:	83 f5 1f             	xor    $0x1f,%ebp
  800f64:	75 5a                	jne    800fc0 <__umoddi3+0xb0>
  800f66:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f6a:	0f 82 e0 00 00 00    	jb     801050 <__umoddi3+0x140>
  800f70:	39 0c 24             	cmp    %ecx,(%esp)
  800f73:	0f 86 d7 00 00 00    	jbe    801050 <__umoddi3+0x140>
  800f79:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f7d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f81:	83 c4 1c             	add    $0x1c,%esp
  800f84:	5b                   	pop    %ebx
  800f85:	5e                   	pop    %esi
  800f86:	5f                   	pop    %edi
  800f87:	5d                   	pop    %ebp
  800f88:	c3                   	ret    
  800f89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f90:	85 ff                	test   %edi,%edi
  800f92:	89 fd                	mov    %edi,%ebp
  800f94:	75 0b                	jne    800fa1 <__umoddi3+0x91>
  800f96:	b8 01 00 00 00       	mov    $0x1,%eax
  800f9b:	31 d2                	xor    %edx,%edx
  800f9d:	f7 f7                	div    %edi
  800f9f:	89 c5                	mov    %eax,%ebp
  800fa1:	89 f0                	mov    %esi,%eax
  800fa3:	31 d2                	xor    %edx,%edx
  800fa5:	f7 f5                	div    %ebp
  800fa7:	89 c8                	mov    %ecx,%eax
  800fa9:	f7 f5                	div    %ebp
  800fab:	89 d0                	mov    %edx,%eax
  800fad:	eb 99                	jmp    800f48 <__umoddi3+0x38>
  800faf:	90                   	nop
  800fb0:	89 c8                	mov    %ecx,%eax
  800fb2:	89 f2                	mov    %esi,%edx
  800fb4:	83 c4 1c             	add    $0x1c,%esp
  800fb7:	5b                   	pop    %ebx
  800fb8:	5e                   	pop    %esi
  800fb9:	5f                   	pop    %edi
  800fba:	5d                   	pop    %ebp
  800fbb:	c3                   	ret    
  800fbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fc0:	8b 34 24             	mov    (%esp),%esi
  800fc3:	bf 20 00 00 00       	mov    $0x20,%edi
  800fc8:	89 e9                	mov    %ebp,%ecx
  800fca:	29 ef                	sub    %ebp,%edi
  800fcc:	d3 e0                	shl    %cl,%eax
  800fce:	89 f9                	mov    %edi,%ecx
  800fd0:	89 f2                	mov    %esi,%edx
  800fd2:	d3 ea                	shr    %cl,%edx
  800fd4:	89 e9                	mov    %ebp,%ecx
  800fd6:	09 c2                	or     %eax,%edx
  800fd8:	89 d8                	mov    %ebx,%eax
  800fda:	89 14 24             	mov    %edx,(%esp)
  800fdd:	89 f2                	mov    %esi,%edx
  800fdf:	d3 e2                	shl    %cl,%edx
  800fe1:	89 f9                	mov    %edi,%ecx
  800fe3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fe7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800feb:	d3 e8                	shr    %cl,%eax
  800fed:	89 e9                	mov    %ebp,%ecx
  800fef:	89 c6                	mov    %eax,%esi
  800ff1:	d3 e3                	shl    %cl,%ebx
  800ff3:	89 f9                	mov    %edi,%ecx
  800ff5:	89 d0                	mov    %edx,%eax
  800ff7:	d3 e8                	shr    %cl,%eax
  800ff9:	89 e9                	mov    %ebp,%ecx
  800ffb:	09 d8                	or     %ebx,%eax
  800ffd:	89 d3                	mov    %edx,%ebx
  800fff:	89 f2                	mov    %esi,%edx
  801001:	f7 34 24             	divl   (%esp)
  801004:	89 d6                	mov    %edx,%esi
  801006:	d3 e3                	shl    %cl,%ebx
  801008:	f7 64 24 04          	mull   0x4(%esp)
  80100c:	39 d6                	cmp    %edx,%esi
  80100e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801012:	89 d1                	mov    %edx,%ecx
  801014:	89 c3                	mov    %eax,%ebx
  801016:	72 08                	jb     801020 <__umoddi3+0x110>
  801018:	75 11                	jne    80102b <__umoddi3+0x11b>
  80101a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80101e:	73 0b                	jae    80102b <__umoddi3+0x11b>
  801020:	2b 44 24 04          	sub    0x4(%esp),%eax
  801024:	1b 14 24             	sbb    (%esp),%edx
  801027:	89 d1                	mov    %edx,%ecx
  801029:	89 c3                	mov    %eax,%ebx
  80102b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80102f:	29 da                	sub    %ebx,%edx
  801031:	19 ce                	sbb    %ecx,%esi
  801033:	89 f9                	mov    %edi,%ecx
  801035:	89 f0                	mov    %esi,%eax
  801037:	d3 e0                	shl    %cl,%eax
  801039:	89 e9                	mov    %ebp,%ecx
  80103b:	d3 ea                	shr    %cl,%edx
  80103d:	89 e9                	mov    %ebp,%ecx
  80103f:	d3 ee                	shr    %cl,%esi
  801041:	09 d0                	or     %edx,%eax
  801043:	89 f2                	mov    %esi,%edx
  801045:	83 c4 1c             	add    $0x1c,%esp
  801048:	5b                   	pop    %ebx
  801049:	5e                   	pop    %esi
  80104a:	5f                   	pop    %edi
  80104b:	5d                   	pop    %ebp
  80104c:	c3                   	ret    
  80104d:	8d 76 00             	lea    0x0(%esi),%esi
  801050:	29 f9                	sub    %edi,%ecx
  801052:	19 d6                	sbb    %edx,%esi
  801054:	89 74 24 04          	mov    %esi,0x4(%esp)
  801058:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80105c:	e9 18 ff ff ff       	jmp    800f79 <__umoddi3+0x69>
