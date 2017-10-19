
obj/user/testbss：     文件格式 elf32-i386


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
  80002c:	e8 ab 00 00 00       	call   8000dc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	68 00 10 80 00       	push   $0x801000
  80003e:	e8 ca 01 00 00       	call   80020d <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800052:	00 
  800053:	74 12                	je     800067 <umain+0x34>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	50                   	push   %eax
  800056:	68 7b 10 80 00       	push   $0x80107b
  80005b:	6a 11                	push   $0x11
  80005d:	68 98 10 80 00       	push   $0x801098
  800062:	e8 cd 00 00 00       	call   800134 <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800067:	83 c0 01             	add    $0x1,%eax
  80006a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80006f:	75 da                	jne    80004b <umain+0x18>
  800071:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800076:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80007d:	83 c0 01             	add    $0x1,%eax
  800080:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800085:	75 ef                	jne    800076 <umain+0x43>
  800087:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  80008c:	3b 04 85 20 20 80 00 	cmp    0x802020(,%eax,4),%eax
  800093:	74 12                	je     8000a7 <umain+0x74>
			panic("bigarray[%d] didn't hold its value!\n", i);
  800095:	50                   	push   %eax
  800096:	68 20 10 80 00       	push   $0x801020
  80009b:	6a 16                	push   $0x16
  80009d:	68 98 10 80 00       	push   $0x801098
  8000a2:	e8 8d 00 00 00       	call   800134 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000a7:	83 c0 01             	add    $0x1,%eax
  8000aa:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000af:	75 db                	jne    80008c <umain+0x59>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	68 48 10 80 00       	push   $0x801048
  8000b9:	e8 4f 01 00 00       	call   80020d <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000be:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000c5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c8:	83 c4 0c             	add    $0xc,%esp
  8000cb:	68 a7 10 80 00       	push   $0x8010a7
  8000d0:	6a 1a                	push   $0x1a
  8000d2:	68 98 10 80 00       	push   $0x801098
  8000d7:	e8 58 00 00 00       	call   800134 <_panic>

008000dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000e7:	e8 82 0a 00 00       	call   800b6e <sys_getenvid>
  8000ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f9:	a3 20 20 c0 00       	mov    %eax,0xc02020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000fe:	85 db                	test   %ebx,%ebx
  800100:	7e 07                	jle    800109 <libmain+0x2d>
		binaryname = argv[0];
  800102:	8b 06                	mov    (%esi),%eax
  800104:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800109:	83 ec 08             	sub    $0x8,%esp
  80010c:	56                   	push   %esi
  80010d:	53                   	push   %ebx
  80010e:	e8 20 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800113:	e8 0a 00 00 00       	call   800122 <exit>
}
  800118:	83 c4 10             	add    $0x10,%esp
  80011b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    

00800122 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800128:	6a 00                	push   $0x0
  80012a:	e8 fe 09 00 00       	call   800b2d <sys_env_destroy>
}
  80012f:	83 c4 10             	add    $0x10,%esp
  800132:	c9                   	leave  
  800133:	c3                   	ret    

00800134 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800139:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80013c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800142:	e8 27 0a 00 00       	call   800b6e <sys_getenvid>
  800147:	83 ec 0c             	sub    $0xc,%esp
  80014a:	ff 75 0c             	pushl  0xc(%ebp)
  80014d:	ff 75 08             	pushl  0x8(%ebp)
  800150:	56                   	push   %esi
  800151:	50                   	push   %eax
  800152:	68 c8 10 80 00       	push   $0x8010c8
  800157:	e8 b1 00 00 00       	call   80020d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80015c:	83 c4 18             	add    $0x18,%esp
  80015f:	53                   	push   %ebx
  800160:	ff 75 10             	pushl  0x10(%ebp)
  800163:	e8 54 00 00 00       	call   8001bc <vcprintf>
	cprintf("\n");
  800168:	c7 04 24 96 10 80 00 	movl   $0x801096,(%esp)
  80016f:	e8 99 00 00 00       	call   80020d <cprintf>
  800174:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800177:	cc                   	int3   
  800178:	eb fd                	jmp    800177 <_panic+0x43>

0080017a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	53                   	push   %ebx
  80017e:	83 ec 04             	sub    $0x4,%esp
  800181:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800184:	8b 13                	mov    (%ebx),%edx
  800186:	8d 42 01             	lea    0x1(%edx),%eax
  800189:	89 03                	mov    %eax,(%ebx)
  80018b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80018e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800192:	3d ff 00 00 00       	cmp    $0xff,%eax
  800197:	75 1a                	jne    8001b3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800199:	83 ec 08             	sub    $0x8,%esp
  80019c:	68 ff 00 00 00       	push   $0xff
  8001a1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a4:	50                   	push   %eax
  8001a5:	e8 46 09 00 00       	call   800af0 <sys_cputs>
		b->idx = 0;
  8001aa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001cc:	00 00 00 
	b.cnt = 0;
  8001cf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d9:	ff 75 0c             	pushl  0xc(%ebp)
  8001dc:	ff 75 08             	pushl  0x8(%ebp)
  8001df:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e5:	50                   	push   %eax
  8001e6:	68 7a 01 80 00       	push   $0x80017a
  8001eb:	e8 54 01 00 00       	call   800344 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f0:	83 c4 08             	add    $0x8,%esp
  8001f3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ff:	50                   	push   %eax
  800200:	e8 eb 08 00 00       	call   800af0 <sys_cputs>

	return b.cnt;
}
  800205:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020b:	c9                   	leave  
  80020c:	c3                   	ret    

0080020d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020d:	55                   	push   %ebp
  80020e:	89 e5                	mov    %esp,%ebp
  800210:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800213:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800216:	50                   	push   %eax
  800217:	ff 75 08             	pushl  0x8(%ebp)
  80021a:	e8 9d ff ff ff       	call   8001bc <vcprintf>
	va_end(ap);

	return cnt;
}
  80021f:	c9                   	leave  
  800220:	c3                   	ret    

00800221 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	57                   	push   %edi
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
  800227:	83 ec 1c             	sub    $0x1c,%esp
  80022a:	89 c7                	mov    %eax,%edi
  80022c:	89 d6                	mov    %edx,%esi
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	8b 55 0c             	mov    0xc(%ebp),%edx
  800234:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800237:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80023d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800242:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800245:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800248:	39 d3                	cmp    %edx,%ebx
  80024a:	72 05                	jb     800251 <printnum+0x30>
  80024c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80024f:	77 45                	ja     800296 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800251:	83 ec 0c             	sub    $0xc,%esp
  800254:	ff 75 18             	pushl  0x18(%ebp)
  800257:	8b 45 14             	mov    0x14(%ebp),%eax
  80025a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80025d:	53                   	push   %ebx
  80025e:	ff 75 10             	pushl  0x10(%ebp)
  800261:	83 ec 08             	sub    $0x8,%esp
  800264:	ff 75 e4             	pushl  -0x1c(%ebp)
  800267:	ff 75 e0             	pushl  -0x20(%ebp)
  80026a:	ff 75 dc             	pushl  -0x24(%ebp)
  80026d:	ff 75 d8             	pushl  -0x28(%ebp)
  800270:	e8 eb 0a 00 00       	call   800d60 <__udivdi3>
  800275:	83 c4 18             	add    $0x18,%esp
  800278:	52                   	push   %edx
  800279:	50                   	push   %eax
  80027a:	89 f2                	mov    %esi,%edx
  80027c:	89 f8                	mov    %edi,%eax
  80027e:	e8 9e ff ff ff       	call   800221 <printnum>
  800283:	83 c4 20             	add    $0x20,%esp
  800286:	eb 18                	jmp    8002a0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800288:	83 ec 08             	sub    $0x8,%esp
  80028b:	56                   	push   %esi
  80028c:	ff 75 18             	pushl  0x18(%ebp)
  80028f:	ff d7                	call   *%edi
  800291:	83 c4 10             	add    $0x10,%esp
  800294:	eb 03                	jmp    800299 <printnum+0x78>
  800296:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800299:	83 eb 01             	sub    $0x1,%ebx
  80029c:	85 db                	test   %ebx,%ebx
  80029e:	7f e8                	jg     800288 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a0:	83 ec 08             	sub    $0x8,%esp
  8002a3:	56                   	push   %esi
  8002a4:	83 ec 04             	sub    $0x4,%esp
  8002a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ad:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b0:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b3:	e8 d8 0b 00 00       	call   800e90 <__umoddi3>
  8002b8:	83 c4 14             	add    $0x14,%esp
  8002bb:	0f be 80 ec 10 80 00 	movsbl 0x8010ec(%eax),%eax
  8002c2:	50                   	push   %eax
  8002c3:	ff d7                	call   *%edi
}
  8002c5:	83 c4 10             	add    $0x10,%esp
  8002c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cb:	5b                   	pop    %ebx
  8002cc:	5e                   	pop    %esi
  8002cd:	5f                   	pop    %edi
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    

008002d0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d3:	83 fa 01             	cmp    $0x1,%edx
  8002d6:	7e 0e                	jle    8002e6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d8:	8b 10                	mov    (%eax),%edx
  8002da:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002dd:	89 08                	mov    %ecx,(%eax)
  8002df:	8b 02                	mov    (%edx),%eax
  8002e1:	8b 52 04             	mov    0x4(%edx),%edx
  8002e4:	eb 22                	jmp    800308 <getuint+0x38>
	else if (lflag)
  8002e6:	85 d2                	test   %edx,%edx
  8002e8:	74 10                	je     8002fa <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ea:	8b 10                	mov    (%eax),%edx
  8002ec:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ef:	89 08                	mov    %ecx,(%eax)
  8002f1:	8b 02                	mov    (%edx),%eax
  8002f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f8:	eb 0e                	jmp    800308 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002fa:	8b 10                	mov    (%eax),%edx
  8002fc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ff:	89 08                	mov    %ecx,(%eax)
  800301:	8b 02                	mov    (%edx),%eax
  800303:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800310:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800314:	8b 10                	mov    (%eax),%edx
  800316:	3b 50 04             	cmp    0x4(%eax),%edx
  800319:	73 0a                	jae    800325 <sprintputch+0x1b>
		*b->buf++ = ch;
  80031b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80031e:	89 08                	mov    %ecx,(%eax)
  800320:	8b 45 08             	mov    0x8(%ebp),%eax
  800323:	88 02                	mov    %al,(%edx)
}
  800325:	5d                   	pop    %ebp
  800326:	c3                   	ret    

00800327 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800327:	55                   	push   %ebp
  800328:	89 e5                	mov    %esp,%ebp
  80032a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80032d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800330:	50                   	push   %eax
  800331:	ff 75 10             	pushl  0x10(%ebp)
  800334:	ff 75 0c             	pushl  0xc(%ebp)
  800337:	ff 75 08             	pushl  0x8(%ebp)
  80033a:	e8 05 00 00 00       	call   800344 <vprintfmt>
	va_end(ap);
}
  80033f:	83 c4 10             	add    $0x10,%esp
  800342:	c9                   	leave  
  800343:	c3                   	ret    

00800344 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	57                   	push   %edi
  800348:	56                   	push   %esi
  800349:	53                   	push   %ebx
  80034a:	83 ec 2c             	sub    $0x2c,%esp
  80034d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
  800350:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800357:	eb 17                	jmp    800370 <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800359:	85 c0                	test   %eax,%eax
  80035b:	0f 84 9f 03 00 00    	je     800700 <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
  800361:	83 ec 08             	sub    $0x8,%esp
  800364:	ff 75 0c             	pushl  0xc(%ebp)
  800367:	50                   	push   %eax
  800368:	ff 55 08             	call   *0x8(%ebp)
  80036b:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80036e:	89 f3                	mov    %esi,%ebx
  800370:	8d 73 01             	lea    0x1(%ebx),%esi
  800373:	0f b6 03             	movzbl (%ebx),%eax
  800376:	83 f8 25             	cmp    $0x25,%eax
  800379:	75 de                	jne    800359 <vprintfmt+0x15>
  80037b:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80037f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800386:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80038b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800392:	ba 00 00 00 00       	mov    $0x0,%edx
  800397:	eb 06                	jmp    80039f <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800399:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80039b:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039f:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003a2:	0f b6 06             	movzbl (%esi),%eax
  8003a5:	0f b6 c8             	movzbl %al,%ecx
  8003a8:	83 e8 23             	sub    $0x23,%eax
  8003ab:	3c 55                	cmp    $0x55,%al
  8003ad:	0f 87 2d 03 00 00    	ja     8006e0 <vprintfmt+0x39c>
  8003b3:	0f b6 c0             	movzbl %al,%eax
  8003b6:	ff 24 85 c0 11 80 00 	jmp    *0x8011c0(,%eax,4)
  8003bd:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003bf:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003c3:	eb da                	jmp    80039f <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	89 de                	mov    %ebx,%esi
  8003c7:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003cc:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  8003cf:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  8003d3:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  8003d6:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8003d9:	83 f8 09             	cmp    $0x9,%eax
  8003dc:	77 33                	ja     800411 <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003de:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003e1:	eb e9                	jmp    8003cc <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e6:	8d 48 04             	lea    0x4(%eax),%ecx
  8003e9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ec:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f0:	eb 1f                	jmp    800411 <vprintfmt+0xcd>
  8003f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f5:	85 c0                	test   %eax,%eax
  8003f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fc:	0f 49 c8             	cmovns %eax,%ecx
  8003ff:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	89 de                	mov    %ebx,%esi
  800404:	eb 99                	jmp    80039f <vprintfmt+0x5b>
  800406:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800408:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  80040f:	eb 8e                	jmp    80039f <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  800411:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800415:	79 88                	jns    80039f <vprintfmt+0x5b>
				width = precision, precision = -1;
  800417:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80041a:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80041f:	e9 7b ff ff ff       	jmp    80039f <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800424:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800429:	e9 71 ff ff ff       	jmp    80039f <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8d 50 04             	lea    0x4(%eax),%edx
  800434:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  800437:	83 ec 08             	sub    $0x8,%esp
  80043a:	ff 75 0c             	pushl  0xc(%ebp)
  80043d:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800440:	03 08                	add    (%eax),%ecx
  800442:	51                   	push   %ecx
  800443:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
  800446:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
  800449:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
  800450:	e9 1b ff ff ff       	jmp    800370 <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
  800455:	8b 45 14             	mov    0x14(%ebp),%eax
  800458:	8d 48 04             	lea    0x4(%eax),%ecx
  80045b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80045e:	8b 00                	mov    (%eax),%eax
  800460:	83 f8 02             	cmp    $0x2,%eax
  800463:	74 1a                	je     80047f <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800465:	89 de                	mov    %ebx,%esi
  800467:	83 f8 04             	cmp    $0x4,%eax
  80046a:	b8 00 00 00 00       	mov    $0x0,%eax
  80046f:	b9 00 04 00 00       	mov    $0x400,%ecx
  800474:	0f 44 c1             	cmove  %ecx,%eax
  800477:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80047a:	e9 20 ff ff ff       	jmp    80039f <vprintfmt+0x5b>
  80047f:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
  800481:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
  800488:	e9 12 ff ff ff       	jmp    80039f <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048d:	8b 45 14             	mov    0x14(%ebp),%eax
  800490:	8d 50 04             	lea    0x4(%eax),%edx
  800493:	89 55 14             	mov    %edx,0x14(%ebp)
  800496:	8b 00                	mov    (%eax),%eax
  800498:	99                   	cltd   
  800499:	31 d0                	xor    %edx,%eax
  80049b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049d:	83 f8 09             	cmp    $0x9,%eax
  8004a0:	7f 0b                	jg     8004ad <vprintfmt+0x169>
  8004a2:	8b 14 85 20 13 80 00 	mov    0x801320(,%eax,4),%edx
  8004a9:	85 d2                	test   %edx,%edx
  8004ab:	75 19                	jne    8004c6 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  8004ad:	50                   	push   %eax
  8004ae:	68 04 11 80 00       	push   $0x801104
  8004b3:	ff 75 0c             	pushl  0xc(%ebp)
  8004b6:	ff 75 08             	pushl  0x8(%ebp)
  8004b9:	e8 69 fe ff ff       	call   800327 <printfmt>
  8004be:	83 c4 10             	add    $0x10,%esp
  8004c1:	e9 aa fe ff ff       	jmp    800370 <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  8004c6:	52                   	push   %edx
  8004c7:	68 0d 11 80 00       	push   $0x80110d
  8004cc:	ff 75 0c             	pushl  0xc(%ebp)
  8004cf:	ff 75 08             	pushl  0x8(%ebp)
  8004d2:	e8 50 fe ff ff       	call   800327 <printfmt>
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	e9 91 fe ff ff       	jmp    800370 <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004df:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e2:	8d 50 04             	lea    0x4(%eax),%edx
  8004e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e8:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004ea:	85 f6                	test   %esi,%esi
  8004ec:	b8 fd 10 80 00       	mov    $0x8010fd,%eax
  8004f1:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8004f4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f8:	0f 8e 93 00 00 00    	jle    800591 <vprintfmt+0x24d>
  8004fe:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800502:	0f 84 91 00 00 00    	je     800599 <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	57                   	push   %edi
  80050c:	56                   	push   %esi
  80050d:	e8 76 02 00 00       	call   800788 <strnlen>
  800512:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800515:	29 c1                	sub    %eax,%ecx
  800517:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80051a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80051d:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  800521:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800524:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800527:	8b 75 0c             	mov    0xc(%ebp),%esi
  80052a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80052d:	89 cb                	mov    %ecx,%ebx
  80052f:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800531:	eb 0e                	jmp    800541 <vprintfmt+0x1fd>
					putch(padc, putdat);
  800533:	83 ec 08             	sub    $0x8,%esp
  800536:	56                   	push   %esi
  800537:	57                   	push   %edi
  800538:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80053b:	83 eb 01             	sub    $0x1,%ebx
  80053e:	83 c4 10             	add    $0x10,%esp
  800541:	85 db                	test   %ebx,%ebx
  800543:	7f ee                	jg     800533 <vprintfmt+0x1ef>
  800545:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800548:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80054b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80054e:	85 c9                	test   %ecx,%ecx
  800550:	b8 00 00 00 00       	mov    $0x0,%eax
  800555:	0f 49 c1             	cmovns %ecx,%eax
  800558:	29 c1                	sub    %eax,%ecx
  80055a:	89 cb                	mov    %ecx,%ebx
  80055c:	eb 41                	jmp    80059f <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800562:	74 1b                	je     80057f <vprintfmt+0x23b>
  800564:	0f be c0             	movsbl %al,%eax
  800567:	83 e8 20             	sub    $0x20,%eax
  80056a:	83 f8 5e             	cmp    $0x5e,%eax
  80056d:	76 10                	jbe    80057f <vprintfmt+0x23b>
					putch('?', putdat);
  80056f:	83 ec 08             	sub    $0x8,%esp
  800572:	ff 75 0c             	pushl  0xc(%ebp)
  800575:	6a 3f                	push   $0x3f
  800577:	ff 55 08             	call   *0x8(%ebp)
  80057a:	83 c4 10             	add    $0x10,%esp
  80057d:	eb 0d                	jmp    80058c <vprintfmt+0x248>
				else
					putch(ch, putdat);
  80057f:	83 ec 08             	sub    $0x8,%esp
  800582:	ff 75 0c             	pushl  0xc(%ebp)
  800585:	52                   	push   %edx
  800586:	ff 55 08             	call   *0x8(%ebp)
  800589:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058c:	83 eb 01             	sub    $0x1,%ebx
  80058f:	eb 0e                	jmp    80059f <vprintfmt+0x25b>
  800591:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800594:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800597:	eb 06                	jmp    80059f <vprintfmt+0x25b>
  800599:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80059c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059f:	83 c6 01             	add    $0x1,%esi
  8005a2:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8005a6:	0f be d0             	movsbl %al,%edx
  8005a9:	85 d2                	test   %edx,%edx
  8005ab:	74 25                	je     8005d2 <vprintfmt+0x28e>
  8005ad:	85 ff                	test   %edi,%edi
  8005af:	78 ad                	js     80055e <vprintfmt+0x21a>
  8005b1:	83 ef 01             	sub    $0x1,%edi
  8005b4:	79 a8                	jns    80055e <vprintfmt+0x21a>
  8005b6:	89 d8                	mov    %ebx,%eax
  8005b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8005bb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005be:	89 c3                	mov    %eax,%ebx
  8005c0:	eb 16                	jmp    8005d8 <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c2:	83 ec 08             	sub    $0x8,%esp
  8005c5:	57                   	push   %edi
  8005c6:	6a 20                	push   $0x20
  8005c8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ca:	83 eb 01             	sub    $0x1,%ebx
  8005cd:	83 c4 10             	add    $0x10,%esp
  8005d0:	eb 06                	jmp    8005d8 <vprintfmt+0x294>
  8005d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005d8:	85 db                	test   %ebx,%ebx
  8005da:	7f e6                	jg     8005c2 <vprintfmt+0x27e>
  8005dc:	89 75 08             	mov    %esi,0x8(%ebp)
  8005df:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005e5:	e9 86 fd ff ff       	jmp    800370 <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ea:	83 fa 01             	cmp    $0x1,%edx
  8005ed:	7e 10                	jle    8005ff <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 50 08             	lea    0x8(%eax),%edx
  8005f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f8:	8b 30                	mov    (%eax),%esi
  8005fa:	8b 78 04             	mov    0x4(%eax),%edi
  8005fd:	eb 26                	jmp    800625 <vprintfmt+0x2e1>
	else if (lflag)
  8005ff:	85 d2                	test   %edx,%edx
  800601:	74 12                	je     800615 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8d 50 04             	lea    0x4(%eax),%edx
  800609:	89 55 14             	mov    %edx,0x14(%ebp)
  80060c:	8b 30                	mov    (%eax),%esi
  80060e:	89 f7                	mov    %esi,%edi
  800610:	c1 ff 1f             	sar    $0x1f,%edi
  800613:	eb 10                	jmp    800625 <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8d 50 04             	lea    0x4(%eax),%edx
  80061b:	89 55 14             	mov    %edx,0x14(%ebp)
  80061e:	8b 30                	mov    (%eax),%esi
  800620:	89 f7                	mov    %esi,%edi
  800622:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800625:	89 f0                	mov    %esi,%eax
  800627:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800629:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80062e:	85 ff                	test   %edi,%edi
  800630:	79 7b                	jns    8006ad <vprintfmt+0x369>
				putch('-', putdat);
  800632:	83 ec 08             	sub    $0x8,%esp
  800635:	ff 75 0c             	pushl  0xc(%ebp)
  800638:	6a 2d                	push   $0x2d
  80063a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80063d:	89 f0                	mov    %esi,%eax
  80063f:	89 fa                	mov    %edi,%edx
  800641:	f7 d8                	neg    %eax
  800643:	83 d2 00             	adc    $0x0,%edx
  800646:	f7 da                	neg    %edx
  800648:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80064b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800650:	eb 5b                	jmp    8006ad <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800652:	8d 45 14             	lea    0x14(%ebp),%eax
  800655:	e8 76 fc ff ff       	call   8002d0 <getuint>
			base = 10;
  80065a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80065f:	eb 4c                	jmp    8006ad <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
  800661:	8d 45 14             	lea    0x14(%ebp),%eax
  800664:	e8 67 fc ff ff       	call   8002d0 <getuint>
            base = 8;
  800669:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80066e:	eb 3d                	jmp    8006ad <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
  800670:	83 ec 08             	sub    $0x8,%esp
  800673:	ff 75 0c             	pushl  0xc(%ebp)
  800676:	6a 30                	push   $0x30
  800678:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80067b:	83 c4 08             	add    $0x8,%esp
  80067e:	ff 75 0c             	pushl  0xc(%ebp)
  800681:	6a 78                	push   $0x78
  800683:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8d 50 04             	lea    0x4(%eax),%edx
  80068c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80068f:	8b 00                	mov    (%eax),%eax
  800691:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800696:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800699:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80069e:	eb 0d                	jmp    8006ad <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a3:	e8 28 fc ff ff       	call   8002d0 <getuint>
			base = 16;
  8006a8:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006ad:	83 ec 0c             	sub    $0xc,%esp
  8006b0:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  8006b4:	56                   	push   %esi
  8006b5:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b8:	51                   	push   %ecx
  8006b9:	52                   	push   %edx
  8006ba:	50                   	push   %eax
  8006bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006be:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c1:	e8 5b fb ff ff       	call   800221 <printnum>
			break;
  8006c6:	83 c4 20             	add    $0x20,%esp
  8006c9:	e9 a2 fc ff ff       	jmp    800370 <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ce:	83 ec 08             	sub    $0x8,%esp
  8006d1:	ff 75 0c             	pushl  0xc(%ebp)
  8006d4:	51                   	push   %ecx
  8006d5:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006d8:	83 c4 10             	add    $0x10,%esp
  8006db:	e9 90 fc ff ff       	jmp    800370 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e0:	83 ec 08             	sub    $0x8,%esp
  8006e3:	ff 75 0c             	pushl  0xc(%ebp)
  8006e6:	6a 25                	push   $0x25
  8006e8:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	89 f3                	mov    %esi,%ebx
  8006f0:	eb 03                	jmp    8006f5 <vprintfmt+0x3b1>
  8006f2:	83 eb 01             	sub    $0x1,%ebx
  8006f5:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006f9:	75 f7                	jne    8006f2 <vprintfmt+0x3ae>
  8006fb:	e9 70 fc ff ff       	jmp    800370 <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  800700:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800703:	5b                   	pop    %ebx
  800704:	5e                   	pop    %esi
  800705:	5f                   	pop    %edi
  800706:	5d                   	pop    %ebp
  800707:	c3                   	ret    

00800708 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
  80070b:	83 ec 18             	sub    $0x18,%esp
  80070e:	8b 45 08             	mov    0x8(%ebp),%eax
  800711:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800714:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800717:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80071e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800725:	85 c0                	test   %eax,%eax
  800727:	74 26                	je     80074f <vsnprintf+0x47>
  800729:	85 d2                	test   %edx,%edx
  80072b:	7e 22                	jle    80074f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80072d:	ff 75 14             	pushl  0x14(%ebp)
  800730:	ff 75 10             	pushl  0x10(%ebp)
  800733:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800736:	50                   	push   %eax
  800737:	68 0a 03 80 00       	push   $0x80030a
  80073c:	e8 03 fc ff ff       	call   800344 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800741:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800744:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800747:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074a:	83 c4 10             	add    $0x10,%esp
  80074d:	eb 05                	jmp    800754 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80074f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800754:	c9                   	leave  
  800755:	c3                   	ret    

00800756 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075f:	50                   	push   %eax
  800760:	ff 75 10             	pushl  0x10(%ebp)
  800763:	ff 75 0c             	pushl  0xc(%ebp)
  800766:	ff 75 08             	pushl  0x8(%ebp)
  800769:	e8 9a ff ff ff       	call   800708 <vsnprintf>
	va_end(ap);

	return rc;
}
  80076e:	c9                   	leave  
  80076f:	c3                   	ret    

00800770 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800776:	b8 00 00 00 00       	mov    $0x0,%eax
  80077b:	eb 03                	jmp    800780 <strlen+0x10>
		n++;
  80077d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800780:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800784:	75 f7                	jne    80077d <strlen+0xd>
		n++;
	return n;
}
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800791:	ba 00 00 00 00       	mov    $0x0,%edx
  800796:	eb 03                	jmp    80079b <strnlen+0x13>
		n++;
  800798:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079b:	39 c2                	cmp    %eax,%edx
  80079d:	74 08                	je     8007a7 <strnlen+0x1f>
  80079f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007a3:	75 f3                	jne    800798 <strnlen+0x10>
  8007a5:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007a7:	5d                   	pop    %ebp
  8007a8:	c3                   	ret    

008007a9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a9:	55                   	push   %ebp
  8007aa:	89 e5                	mov    %esp,%ebp
  8007ac:	53                   	push   %ebx
  8007ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b3:	89 c2                	mov    %eax,%edx
  8007b5:	83 c2 01             	add    $0x1,%edx
  8007b8:	83 c1 01             	add    $0x1,%ecx
  8007bb:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007bf:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c2:	84 db                	test   %bl,%bl
  8007c4:	75 ef                	jne    8007b5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c6:	5b                   	pop    %ebx
  8007c7:	5d                   	pop    %ebp
  8007c8:	c3                   	ret    

008007c9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	53                   	push   %ebx
  8007cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d0:	53                   	push   %ebx
  8007d1:	e8 9a ff ff ff       	call   800770 <strlen>
  8007d6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007d9:	ff 75 0c             	pushl  0xc(%ebp)
  8007dc:	01 d8                	add    %ebx,%eax
  8007de:	50                   	push   %eax
  8007df:	e8 c5 ff ff ff       	call   8007a9 <strcpy>
	return dst;
}
  8007e4:	89 d8                	mov    %ebx,%eax
  8007e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e9:	c9                   	leave  
  8007ea:	c3                   	ret    

008007eb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	56                   	push   %esi
  8007ef:	53                   	push   %ebx
  8007f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f6:	89 f3                	mov    %esi,%ebx
  8007f8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fb:	89 f2                	mov    %esi,%edx
  8007fd:	eb 0f                	jmp    80080e <strncpy+0x23>
		*dst++ = *src;
  8007ff:	83 c2 01             	add    $0x1,%edx
  800802:	0f b6 01             	movzbl (%ecx),%eax
  800805:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800808:	80 39 01             	cmpb   $0x1,(%ecx)
  80080b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080e:	39 da                	cmp    %ebx,%edx
  800810:	75 ed                	jne    8007ff <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800812:	89 f0                	mov    %esi,%eax
  800814:	5b                   	pop    %ebx
  800815:	5e                   	pop    %esi
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	56                   	push   %esi
  80081c:	53                   	push   %ebx
  80081d:	8b 75 08             	mov    0x8(%ebp),%esi
  800820:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800823:	8b 55 10             	mov    0x10(%ebp),%edx
  800826:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800828:	85 d2                	test   %edx,%edx
  80082a:	74 21                	je     80084d <strlcpy+0x35>
  80082c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800830:	89 f2                	mov    %esi,%edx
  800832:	eb 09                	jmp    80083d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800834:	83 c2 01             	add    $0x1,%edx
  800837:	83 c1 01             	add    $0x1,%ecx
  80083a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80083d:	39 c2                	cmp    %eax,%edx
  80083f:	74 09                	je     80084a <strlcpy+0x32>
  800841:	0f b6 19             	movzbl (%ecx),%ebx
  800844:	84 db                	test   %bl,%bl
  800846:	75 ec                	jne    800834 <strlcpy+0x1c>
  800848:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80084a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80084d:	29 f0                	sub    %esi,%eax
}
  80084f:	5b                   	pop    %ebx
  800850:	5e                   	pop    %esi
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800859:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085c:	eb 06                	jmp    800864 <strcmp+0x11>
		p++, q++;
  80085e:	83 c1 01             	add    $0x1,%ecx
  800861:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800864:	0f b6 01             	movzbl (%ecx),%eax
  800867:	84 c0                	test   %al,%al
  800869:	74 04                	je     80086f <strcmp+0x1c>
  80086b:	3a 02                	cmp    (%edx),%al
  80086d:	74 ef                	je     80085e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80086f:	0f b6 c0             	movzbl %al,%eax
  800872:	0f b6 12             	movzbl (%edx),%edx
  800875:	29 d0                	sub    %edx,%eax
}
  800877:	5d                   	pop    %ebp
  800878:	c3                   	ret    

00800879 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	53                   	push   %ebx
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	8b 55 0c             	mov    0xc(%ebp),%edx
  800883:	89 c3                	mov    %eax,%ebx
  800885:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800888:	eb 06                	jmp    800890 <strncmp+0x17>
		n--, p++, q++;
  80088a:	83 c0 01             	add    $0x1,%eax
  80088d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800890:	39 d8                	cmp    %ebx,%eax
  800892:	74 15                	je     8008a9 <strncmp+0x30>
  800894:	0f b6 08             	movzbl (%eax),%ecx
  800897:	84 c9                	test   %cl,%cl
  800899:	74 04                	je     80089f <strncmp+0x26>
  80089b:	3a 0a                	cmp    (%edx),%cl
  80089d:	74 eb                	je     80088a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80089f:	0f b6 00             	movzbl (%eax),%eax
  8008a2:	0f b6 12             	movzbl (%edx),%edx
  8008a5:	29 d0                	sub    %edx,%eax
  8008a7:	eb 05                	jmp    8008ae <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ae:	5b                   	pop    %ebx
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008bb:	eb 07                	jmp    8008c4 <strchr+0x13>
		if (*s == c)
  8008bd:	38 ca                	cmp    %cl,%dl
  8008bf:	74 0f                	je     8008d0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c1:	83 c0 01             	add    $0x1,%eax
  8008c4:	0f b6 10             	movzbl (%eax),%edx
  8008c7:	84 d2                	test   %dl,%dl
  8008c9:	75 f2                	jne    8008bd <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008dc:	eb 03                	jmp    8008e1 <strfind+0xf>
  8008de:	83 c0 01             	add    $0x1,%eax
  8008e1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e4:	38 ca                	cmp    %cl,%dl
  8008e6:	74 04                	je     8008ec <strfind+0x1a>
  8008e8:	84 d2                	test   %dl,%dl
  8008ea:	75 f2                	jne    8008de <strfind+0xc>
			break;
	return (char *) s;
}
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    

008008ee <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	57                   	push   %edi
  8008f2:	56                   	push   %esi
  8008f3:	53                   	push   %ebx
  8008f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008fa:	85 c9                	test   %ecx,%ecx
  8008fc:	74 36                	je     800934 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008fe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800904:	75 28                	jne    80092e <memset+0x40>
  800906:	f6 c1 03             	test   $0x3,%cl
  800909:	75 23                	jne    80092e <memset+0x40>
		c &= 0xFF;
  80090b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80090f:	89 d3                	mov    %edx,%ebx
  800911:	c1 e3 08             	shl    $0x8,%ebx
  800914:	89 d6                	mov    %edx,%esi
  800916:	c1 e6 18             	shl    $0x18,%esi
  800919:	89 d0                	mov    %edx,%eax
  80091b:	c1 e0 10             	shl    $0x10,%eax
  80091e:	09 f0                	or     %esi,%eax
  800920:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800922:	89 d8                	mov    %ebx,%eax
  800924:	09 d0                	or     %edx,%eax
  800926:	c1 e9 02             	shr    $0x2,%ecx
  800929:	fc                   	cld    
  80092a:	f3 ab                	rep stos %eax,%es:(%edi)
  80092c:	eb 06                	jmp    800934 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80092e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800931:	fc                   	cld    
  800932:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800934:	89 f8                	mov    %edi,%eax
  800936:	5b                   	pop    %ebx
  800937:	5e                   	pop    %esi
  800938:	5f                   	pop    %edi
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	57                   	push   %edi
  80093f:	56                   	push   %esi
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	8b 75 0c             	mov    0xc(%ebp),%esi
  800946:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800949:	39 c6                	cmp    %eax,%esi
  80094b:	73 35                	jae    800982 <memmove+0x47>
  80094d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800950:	39 d0                	cmp    %edx,%eax
  800952:	73 2e                	jae    800982 <memmove+0x47>
		s += n;
		d += n;
  800954:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800957:	89 d6                	mov    %edx,%esi
  800959:	09 fe                	or     %edi,%esi
  80095b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800961:	75 13                	jne    800976 <memmove+0x3b>
  800963:	f6 c1 03             	test   $0x3,%cl
  800966:	75 0e                	jne    800976 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800968:	83 ef 04             	sub    $0x4,%edi
  80096b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80096e:	c1 e9 02             	shr    $0x2,%ecx
  800971:	fd                   	std    
  800972:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800974:	eb 09                	jmp    80097f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800976:	83 ef 01             	sub    $0x1,%edi
  800979:	8d 72 ff             	lea    -0x1(%edx),%esi
  80097c:	fd                   	std    
  80097d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80097f:	fc                   	cld    
  800980:	eb 1d                	jmp    80099f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800982:	89 f2                	mov    %esi,%edx
  800984:	09 c2                	or     %eax,%edx
  800986:	f6 c2 03             	test   $0x3,%dl
  800989:	75 0f                	jne    80099a <memmove+0x5f>
  80098b:	f6 c1 03             	test   $0x3,%cl
  80098e:	75 0a                	jne    80099a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800990:	c1 e9 02             	shr    $0x2,%ecx
  800993:	89 c7                	mov    %eax,%edi
  800995:	fc                   	cld    
  800996:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800998:	eb 05                	jmp    80099f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80099a:	89 c7                	mov    %eax,%edi
  80099c:	fc                   	cld    
  80099d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80099f:	5e                   	pop    %esi
  8009a0:	5f                   	pop    %edi
  8009a1:	5d                   	pop    %ebp
  8009a2:	c3                   	ret    

008009a3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a6:	ff 75 10             	pushl  0x10(%ebp)
  8009a9:	ff 75 0c             	pushl  0xc(%ebp)
  8009ac:	ff 75 08             	pushl  0x8(%ebp)
  8009af:	e8 87 ff ff ff       	call   80093b <memmove>
}
  8009b4:	c9                   	leave  
  8009b5:	c3                   	ret    

008009b6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	56                   	push   %esi
  8009ba:	53                   	push   %ebx
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c1:	89 c6                	mov    %eax,%esi
  8009c3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c6:	eb 1a                	jmp    8009e2 <memcmp+0x2c>
		if (*s1 != *s2)
  8009c8:	0f b6 08             	movzbl (%eax),%ecx
  8009cb:	0f b6 1a             	movzbl (%edx),%ebx
  8009ce:	38 d9                	cmp    %bl,%cl
  8009d0:	74 0a                	je     8009dc <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009d2:	0f b6 c1             	movzbl %cl,%eax
  8009d5:	0f b6 db             	movzbl %bl,%ebx
  8009d8:	29 d8                	sub    %ebx,%eax
  8009da:	eb 0f                	jmp    8009eb <memcmp+0x35>
		s1++, s2++;
  8009dc:	83 c0 01             	add    $0x1,%eax
  8009df:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e2:	39 f0                	cmp    %esi,%eax
  8009e4:	75 e2                	jne    8009c8 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009eb:	5b                   	pop    %ebx
  8009ec:	5e                   	pop    %esi
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	53                   	push   %ebx
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009f6:	89 c1                	mov    %eax,%ecx
  8009f8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fb:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ff:	eb 0a                	jmp    800a0b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a01:	0f b6 10             	movzbl (%eax),%edx
  800a04:	39 da                	cmp    %ebx,%edx
  800a06:	74 07                	je     800a0f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a08:	83 c0 01             	add    $0x1,%eax
  800a0b:	39 c8                	cmp    %ecx,%eax
  800a0d:	72 f2                	jb     800a01 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a0f:	5b                   	pop    %ebx
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	57                   	push   %edi
  800a16:	56                   	push   %esi
  800a17:	53                   	push   %ebx
  800a18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1e:	eb 03                	jmp    800a23 <strtol+0x11>
		s++;
  800a20:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a23:	0f b6 01             	movzbl (%ecx),%eax
  800a26:	3c 20                	cmp    $0x20,%al
  800a28:	74 f6                	je     800a20 <strtol+0xe>
  800a2a:	3c 09                	cmp    $0x9,%al
  800a2c:	74 f2                	je     800a20 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a2e:	3c 2b                	cmp    $0x2b,%al
  800a30:	75 0a                	jne    800a3c <strtol+0x2a>
		s++;
  800a32:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a35:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3a:	eb 11                	jmp    800a4d <strtol+0x3b>
  800a3c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a41:	3c 2d                	cmp    $0x2d,%al
  800a43:	75 08                	jne    800a4d <strtol+0x3b>
		s++, neg = 1;
  800a45:	83 c1 01             	add    $0x1,%ecx
  800a48:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a4d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a53:	75 15                	jne    800a6a <strtol+0x58>
  800a55:	80 39 30             	cmpb   $0x30,(%ecx)
  800a58:	75 10                	jne    800a6a <strtol+0x58>
  800a5a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a5e:	75 7c                	jne    800adc <strtol+0xca>
		s += 2, base = 16;
  800a60:	83 c1 02             	add    $0x2,%ecx
  800a63:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a68:	eb 16                	jmp    800a80 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a6a:	85 db                	test   %ebx,%ebx
  800a6c:	75 12                	jne    800a80 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a6e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a73:	80 39 30             	cmpb   $0x30,(%ecx)
  800a76:	75 08                	jne    800a80 <strtol+0x6e>
		s++, base = 8;
  800a78:	83 c1 01             	add    $0x1,%ecx
  800a7b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a80:	b8 00 00 00 00       	mov    $0x0,%eax
  800a85:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a88:	0f b6 11             	movzbl (%ecx),%edx
  800a8b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a8e:	89 f3                	mov    %esi,%ebx
  800a90:	80 fb 09             	cmp    $0x9,%bl
  800a93:	77 08                	ja     800a9d <strtol+0x8b>
			dig = *s - '0';
  800a95:	0f be d2             	movsbl %dl,%edx
  800a98:	83 ea 30             	sub    $0x30,%edx
  800a9b:	eb 22                	jmp    800abf <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a9d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aa0:	89 f3                	mov    %esi,%ebx
  800aa2:	80 fb 19             	cmp    $0x19,%bl
  800aa5:	77 08                	ja     800aaf <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aa7:	0f be d2             	movsbl %dl,%edx
  800aaa:	83 ea 57             	sub    $0x57,%edx
  800aad:	eb 10                	jmp    800abf <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aaf:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab2:	89 f3                	mov    %esi,%ebx
  800ab4:	80 fb 19             	cmp    $0x19,%bl
  800ab7:	77 16                	ja     800acf <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ab9:	0f be d2             	movsbl %dl,%edx
  800abc:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800abf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac2:	7d 0b                	jge    800acf <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ac4:	83 c1 01             	add    $0x1,%ecx
  800ac7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800acb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800acd:	eb b9                	jmp    800a88 <strtol+0x76>

	if (endptr)
  800acf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad3:	74 0d                	je     800ae2 <strtol+0xd0>
		*endptr = (char *) s;
  800ad5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad8:	89 0e                	mov    %ecx,(%esi)
  800ada:	eb 06                	jmp    800ae2 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800adc:	85 db                	test   %ebx,%ebx
  800ade:	74 98                	je     800a78 <strtol+0x66>
  800ae0:	eb 9e                	jmp    800a80 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ae2:	89 c2                	mov    %eax,%edx
  800ae4:	f7 da                	neg    %edx
  800ae6:	85 ff                	test   %edi,%edi
  800ae8:	0f 45 c2             	cmovne %edx,%eax
}
  800aeb:	5b                   	pop    %ebx
  800aec:	5e                   	pop    %esi
  800aed:	5f                   	pop    %edi
  800aee:	5d                   	pop    %ebp
  800aef:	c3                   	ret    

00800af0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	57                   	push   %edi
  800af4:	56                   	push   %esi
  800af5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af6:	b8 00 00 00 00       	mov    $0x0,%eax
  800afb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afe:	8b 55 08             	mov    0x8(%ebp),%edx
  800b01:	89 c3                	mov    %eax,%ebx
  800b03:	89 c7                	mov    %eax,%edi
  800b05:	89 c6                	mov    %eax,%esi
  800b07:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b09:	5b                   	pop    %ebx
  800b0a:	5e                   	pop    %esi
  800b0b:	5f                   	pop    %edi
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    

00800b0e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	57                   	push   %edi
  800b12:	56                   	push   %esi
  800b13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b14:	ba 00 00 00 00       	mov    $0x0,%edx
  800b19:	b8 01 00 00 00       	mov    $0x1,%eax
  800b1e:	89 d1                	mov    %edx,%ecx
  800b20:	89 d3                	mov    %edx,%ebx
  800b22:	89 d7                	mov    %edx,%edi
  800b24:	89 d6                	mov    %edx,%esi
  800b26:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b28:	5b                   	pop    %ebx
  800b29:	5e                   	pop    %esi
  800b2a:	5f                   	pop    %edi
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	57                   	push   %edi
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
  800b33:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b36:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b40:	8b 55 08             	mov    0x8(%ebp),%edx
  800b43:	89 cb                	mov    %ecx,%ebx
  800b45:	89 cf                	mov    %ecx,%edi
  800b47:	89 ce                	mov    %ecx,%esi
  800b49:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b4b:	85 c0                	test   %eax,%eax
  800b4d:	7e 17                	jle    800b66 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4f:	83 ec 0c             	sub    $0xc,%esp
  800b52:	50                   	push   %eax
  800b53:	6a 03                	push   $0x3
  800b55:	68 48 13 80 00       	push   $0x801348
  800b5a:	6a 23                	push   $0x23
  800b5c:	68 65 13 80 00       	push   $0x801365
  800b61:	e8 ce f5 ff ff       	call   800134 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5f                   	pop    %edi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b74:	ba 00 00 00 00       	mov    $0x0,%edx
  800b79:	b8 02 00 00 00       	mov    $0x2,%eax
  800b7e:	89 d1                	mov    %edx,%ecx
  800b80:	89 d3                	mov    %edx,%ebx
  800b82:	89 d7                	mov    %edx,%edi
  800b84:	89 d6                	mov    %edx,%esi
  800b86:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5f                   	pop    %edi
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <sys_yield>:

void
sys_yield(void)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	57                   	push   %edi
  800b91:	56                   	push   %esi
  800b92:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b93:	ba 00 00 00 00       	mov    $0x0,%edx
  800b98:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b9d:	89 d1                	mov    %edx,%ecx
  800b9f:	89 d3                	mov    %edx,%ebx
  800ba1:	89 d7                	mov    %edx,%edi
  800ba3:	89 d6                	mov    %edx,%esi
  800ba5:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5f                   	pop    %edi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
  800bb2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb5:	be 00 00 00 00       	mov    $0x0,%esi
  800bba:	b8 04 00 00 00       	mov    $0x4,%eax
  800bbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc8:	89 f7                	mov    %esi,%edi
  800bca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bcc:	85 c0                	test   %eax,%eax
  800bce:	7e 17                	jle    800be7 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd0:	83 ec 0c             	sub    $0xc,%esp
  800bd3:	50                   	push   %eax
  800bd4:	6a 04                	push   $0x4
  800bd6:	68 48 13 80 00       	push   $0x801348
  800bdb:	6a 23                	push   $0x23
  800bdd:	68 65 13 80 00       	push   $0x801365
  800be2:	e8 4d f5 ff ff       	call   800134 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bea:	5b                   	pop    %ebx
  800beb:	5e                   	pop    %esi
  800bec:	5f                   	pop    %edi
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	53                   	push   %ebx
  800bf5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf8:	b8 05 00 00 00       	mov    $0x5,%eax
  800bfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c00:	8b 55 08             	mov    0x8(%ebp),%edx
  800c03:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c06:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c09:	8b 75 18             	mov    0x18(%ebp),%esi
  800c0c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c0e:	85 c0                	test   %eax,%eax
  800c10:	7e 17                	jle    800c29 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c12:	83 ec 0c             	sub    $0xc,%esp
  800c15:	50                   	push   %eax
  800c16:	6a 05                	push   $0x5
  800c18:	68 48 13 80 00       	push   $0x801348
  800c1d:	6a 23                	push   $0x23
  800c1f:	68 65 13 80 00       	push   $0x801365
  800c24:	e8 0b f5 ff ff       	call   800134 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5f                   	pop    %edi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	57                   	push   %edi
  800c35:	56                   	push   %esi
  800c36:	53                   	push   %ebx
  800c37:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3f:	b8 06 00 00 00       	mov    $0x6,%eax
  800c44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c47:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4a:	89 df                	mov    %ebx,%edi
  800c4c:	89 de                	mov    %ebx,%esi
  800c4e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c50:	85 c0                	test   %eax,%eax
  800c52:	7e 17                	jle    800c6b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c54:	83 ec 0c             	sub    $0xc,%esp
  800c57:	50                   	push   %eax
  800c58:	6a 06                	push   $0x6
  800c5a:	68 48 13 80 00       	push   $0x801348
  800c5f:	6a 23                	push   $0x23
  800c61:	68 65 13 80 00       	push   $0x801365
  800c66:	e8 c9 f4 ff ff       	call   800134 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5f                   	pop    %edi
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    

00800c73 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	57                   	push   %edi
  800c77:	56                   	push   %esi
  800c78:	53                   	push   %ebx
  800c79:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c81:	b8 08 00 00 00       	mov    $0x8,%eax
  800c86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c89:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8c:	89 df                	mov    %ebx,%edi
  800c8e:	89 de                	mov    %ebx,%esi
  800c90:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c92:	85 c0                	test   %eax,%eax
  800c94:	7e 17                	jle    800cad <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c96:	83 ec 0c             	sub    $0xc,%esp
  800c99:	50                   	push   %eax
  800c9a:	6a 08                	push   $0x8
  800c9c:	68 48 13 80 00       	push   $0x801348
  800ca1:	6a 23                	push   $0x23
  800ca3:	68 65 13 80 00       	push   $0x801365
  800ca8:	e8 87 f4 ff ff       	call   800134 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	57                   	push   %edi
  800cb9:	56                   	push   %esi
  800cba:	53                   	push   %ebx
  800cbb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc3:	b8 09 00 00 00       	mov    $0x9,%eax
  800cc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cce:	89 df                	mov    %ebx,%edi
  800cd0:	89 de                	mov    %ebx,%esi
  800cd2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd4:	85 c0                	test   %eax,%eax
  800cd6:	7e 17                	jle    800cef <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd8:	83 ec 0c             	sub    $0xc,%esp
  800cdb:	50                   	push   %eax
  800cdc:	6a 09                	push   $0x9
  800cde:	68 48 13 80 00       	push   $0x801348
  800ce3:	6a 23                	push   $0x23
  800ce5:	68 65 13 80 00       	push   $0x801365
  800cea:	e8 45 f4 ff ff       	call   800134 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf2:	5b                   	pop    %ebx
  800cf3:	5e                   	pop    %esi
  800cf4:	5f                   	pop    %edi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    

00800cf7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	57                   	push   %edi
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfd:	be 00 00 00 00       	mov    $0x0,%esi
  800d02:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d10:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d13:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    

00800d1a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	57                   	push   %edi
  800d1e:	56                   	push   %esi
  800d1f:	53                   	push   %ebx
  800d20:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d23:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d28:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d30:	89 cb                	mov    %ecx,%ebx
  800d32:	89 cf                	mov    %ecx,%edi
  800d34:	89 ce                	mov    %ecx,%esi
  800d36:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d38:	85 c0                	test   %eax,%eax
  800d3a:	7e 17                	jle    800d53 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3c:	83 ec 0c             	sub    $0xc,%esp
  800d3f:	50                   	push   %eax
  800d40:	6a 0c                	push   $0xc
  800d42:	68 48 13 80 00       	push   $0x801348
  800d47:	6a 23                	push   $0x23
  800d49:	68 65 13 80 00       	push   $0x801365
  800d4e:	e8 e1 f3 ff ff       	call   800134 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d56:	5b                   	pop    %ebx
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    
  800d5b:	66 90                	xchg   %ax,%ax
  800d5d:	66 90                	xchg   %ax,%ax
  800d5f:	90                   	nop

00800d60 <__udivdi3>:
  800d60:	55                   	push   %ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 1c             	sub    $0x1c,%esp
  800d67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d77:	85 f6                	test   %esi,%esi
  800d79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d7d:	89 ca                	mov    %ecx,%edx
  800d7f:	89 f8                	mov    %edi,%eax
  800d81:	75 3d                	jne    800dc0 <__udivdi3+0x60>
  800d83:	39 cf                	cmp    %ecx,%edi
  800d85:	0f 87 c5 00 00 00    	ja     800e50 <__udivdi3+0xf0>
  800d8b:	85 ff                	test   %edi,%edi
  800d8d:	89 fd                	mov    %edi,%ebp
  800d8f:	75 0b                	jne    800d9c <__udivdi3+0x3c>
  800d91:	b8 01 00 00 00       	mov    $0x1,%eax
  800d96:	31 d2                	xor    %edx,%edx
  800d98:	f7 f7                	div    %edi
  800d9a:	89 c5                	mov    %eax,%ebp
  800d9c:	89 c8                	mov    %ecx,%eax
  800d9e:	31 d2                	xor    %edx,%edx
  800da0:	f7 f5                	div    %ebp
  800da2:	89 c1                	mov    %eax,%ecx
  800da4:	89 d8                	mov    %ebx,%eax
  800da6:	89 cf                	mov    %ecx,%edi
  800da8:	f7 f5                	div    %ebp
  800daa:	89 c3                	mov    %eax,%ebx
  800dac:	89 d8                	mov    %ebx,%eax
  800dae:	89 fa                	mov    %edi,%edx
  800db0:	83 c4 1c             	add    $0x1c,%esp
  800db3:	5b                   	pop    %ebx
  800db4:	5e                   	pop    %esi
  800db5:	5f                   	pop    %edi
  800db6:	5d                   	pop    %ebp
  800db7:	c3                   	ret    
  800db8:	90                   	nop
  800db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800dc0:	39 ce                	cmp    %ecx,%esi
  800dc2:	77 74                	ja     800e38 <__udivdi3+0xd8>
  800dc4:	0f bd fe             	bsr    %esi,%edi
  800dc7:	83 f7 1f             	xor    $0x1f,%edi
  800dca:	0f 84 98 00 00 00    	je     800e68 <__udivdi3+0x108>
  800dd0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800dd5:	89 f9                	mov    %edi,%ecx
  800dd7:	89 c5                	mov    %eax,%ebp
  800dd9:	29 fb                	sub    %edi,%ebx
  800ddb:	d3 e6                	shl    %cl,%esi
  800ddd:	89 d9                	mov    %ebx,%ecx
  800ddf:	d3 ed                	shr    %cl,%ebp
  800de1:	89 f9                	mov    %edi,%ecx
  800de3:	d3 e0                	shl    %cl,%eax
  800de5:	09 ee                	or     %ebp,%esi
  800de7:	89 d9                	mov    %ebx,%ecx
  800de9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ded:	89 d5                	mov    %edx,%ebp
  800def:	8b 44 24 08          	mov    0x8(%esp),%eax
  800df3:	d3 ed                	shr    %cl,%ebp
  800df5:	89 f9                	mov    %edi,%ecx
  800df7:	d3 e2                	shl    %cl,%edx
  800df9:	89 d9                	mov    %ebx,%ecx
  800dfb:	d3 e8                	shr    %cl,%eax
  800dfd:	09 c2                	or     %eax,%edx
  800dff:	89 d0                	mov    %edx,%eax
  800e01:	89 ea                	mov    %ebp,%edx
  800e03:	f7 f6                	div    %esi
  800e05:	89 d5                	mov    %edx,%ebp
  800e07:	89 c3                	mov    %eax,%ebx
  800e09:	f7 64 24 0c          	mull   0xc(%esp)
  800e0d:	39 d5                	cmp    %edx,%ebp
  800e0f:	72 10                	jb     800e21 <__udivdi3+0xc1>
  800e11:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e15:	89 f9                	mov    %edi,%ecx
  800e17:	d3 e6                	shl    %cl,%esi
  800e19:	39 c6                	cmp    %eax,%esi
  800e1b:	73 07                	jae    800e24 <__udivdi3+0xc4>
  800e1d:	39 d5                	cmp    %edx,%ebp
  800e1f:	75 03                	jne    800e24 <__udivdi3+0xc4>
  800e21:	83 eb 01             	sub    $0x1,%ebx
  800e24:	31 ff                	xor    %edi,%edi
  800e26:	89 d8                	mov    %ebx,%eax
  800e28:	89 fa                	mov    %edi,%edx
  800e2a:	83 c4 1c             	add    $0x1c,%esp
  800e2d:	5b                   	pop    %ebx
  800e2e:	5e                   	pop    %esi
  800e2f:	5f                   	pop    %edi
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    
  800e32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e38:	31 ff                	xor    %edi,%edi
  800e3a:	31 db                	xor    %ebx,%ebx
  800e3c:	89 d8                	mov    %ebx,%eax
  800e3e:	89 fa                	mov    %edi,%edx
  800e40:	83 c4 1c             	add    $0x1c,%esp
  800e43:	5b                   	pop    %ebx
  800e44:	5e                   	pop    %esi
  800e45:	5f                   	pop    %edi
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    
  800e48:	90                   	nop
  800e49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e50:	89 d8                	mov    %ebx,%eax
  800e52:	f7 f7                	div    %edi
  800e54:	31 ff                	xor    %edi,%edi
  800e56:	89 c3                	mov    %eax,%ebx
  800e58:	89 d8                	mov    %ebx,%eax
  800e5a:	89 fa                	mov    %edi,%edx
  800e5c:	83 c4 1c             	add    $0x1c,%esp
  800e5f:	5b                   	pop    %ebx
  800e60:	5e                   	pop    %esi
  800e61:	5f                   	pop    %edi
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    
  800e64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e68:	39 ce                	cmp    %ecx,%esi
  800e6a:	72 0c                	jb     800e78 <__udivdi3+0x118>
  800e6c:	31 db                	xor    %ebx,%ebx
  800e6e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e72:	0f 87 34 ff ff ff    	ja     800dac <__udivdi3+0x4c>
  800e78:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e7d:	e9 2a ff ff ff       	jmp    800dac <__udivdi3+0x4c>
  800e82:	66 90                	xchg   %ax,%ax
  800e84:	66 90                	xchg   %ax,%ax
  800e86:	66 90                	xchg   %ax,%ax
  800e88:	66 90                	xchg   %ax,%ax
  800e8a:	66 90                	xchg   %ax,%ax
  800e8c:	66 90                	xchg   %ax,%ax
  800e8e:	66 90                	xchg   %ax,%ax

00800e90 <__umoddi3>:
  800e90:	55                   	push   %ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	83 ec 1c             	sub    $0x1c,%esp
  800e97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ea3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ea7:	85 d2                	test   %edx,%edx
  800ea9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ead:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800eb1:	89 f3                	mov    %esi,%ebx
  800eb3:	89 3c 24             	mov    %edi,(%esp)
  800eb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eba:	75 1c                	jne    800ed8 <__umoddi3+0x48>
  800ebc:	39 f7                	cmp    %esi,%edi
  800ebe:	76 50                	jbe    800f10 <__umoddi3+0x80>
  800ec0:	89 c8                	mov    %ecx,%eax
  800ec2:	89 f2                	mov    %esi,%edx
  800ec4:	f7 f7                	div    %edi
  800ec6:	89 d0                	mov    %edx,%eax
  800ec8:	31 d2                	xor    %edx,%edx
  800eca:	83 c4 1c             	add    $0x1c,%esp
  800ecd:	5b                   	pop    %ebx
  800ece:	5e                   	pop    %esi
  800ecf:	5f                   	pop    %edi
  800ed0:	5d                   	pop    %ebp
  800ed1:	c3                   	ret    
  800ed2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ed8:	39 f2                	cmp    %esi,%edx
  800eda:	89 d0                	mov    %edx,%eax
  800edc:	77 52                	ja     800f30 <__umoddi3+0xa0>
  800ede:	0f bd ea             	bsr    %edx,%ebp
  800ee1:	83 f5 1f             	xor    $0x1f,%ebp
  800ee4:	75 5a                	jne    800f40 <__umoddi3+0xb0>
  800ee6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800eea:	0f 82 e0 00 00 00    	jb     800fd0 <__umoddi3+0x140>
  800ef0:	39 0c 24             	cmp    %ecx,(%esp)
  800ef3:	0f 86 d7 00 00 00    	jbe    800fd0 <__umoddi3+0x140>
  800ef9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800efd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f01:	83 c4 1c             	add    $0x1c,%esp
  800f04:	5b                   	pop    %ebx
  800f05:	5e                   	pop    %esi
  800f06:	5f                   	pop    %edi
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    
  800f09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f10:	85 ff                	test   %edi,%edi
  800f12:	89 fd                	mov    %edi,%ebp
  800f14:	75 0b                	jne    800f21 <__umoddi3+0x91>
  800f16:	b8 01 00 00 00       	mov    $0x1,%eax
  800f1b:	31 d2                	xor    %edx,%edx
  800f1d:	f7 f7                	div    %edi
  800f1f:	89 c5                	mov    %eax,%ebp
  800f21:	89 f0                	mov    %esi,%eax
  800f23:	31 d2                	xor    %edx,%edx
  800f25:	f7 f5                	div    %ebp
  800f27:	89 c8                	mov    %ecx,%eax
  800f29:	f7 f5                	div    %ebp
  800f2b:	89 d0                	mov    %edx,%eax
  800f2d:	eb 99                	jmp    800ec8 <__umoddi3+0x38>
  800f2f:	90                   	nop
  800f30:	89 c8                	mov    %ecx,%eax
  800f32:	89 f2                	mov    %esi,%edx
  800f34:	83 c4 1c             	add    $0x1c,%esp
  800f37:	5b                   	pop    %ebx
  800f38:	5e                   	pop    %esi
  800f39:	5f                   	pop    %edi
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    
  800f3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f40:	8b 34 24             	mov    (%esp),%esi
  800f43:	bf 20 00 00 00       	mov    $0x20,%edi
  800f48:	89 e9                	mov    %ebp,%ecx
  800f4a:	29 ef                	sub    %ebp,%edi
  800f4c:	d3 e0                	shl    %cl,%eax
  800f4e:	89 f9                	mov    %edi,%ecx
  800f50:	89 f2                	mov    %esi,%edx
  800f52:	d3 ea                	shr    %cl,%edx
  800f54:	89 e9                	mov    %ebp,%ecx
  800f56:	09 c2                	or     %eax,%edx
  800f58:	89 d8                	mov    %ebx,%eax
  800f5a:	89 14 24             	mov    %edx,(%esp)
  800f5d:	89 f2                	mov    %esi,%edx
  800f5f:	d3 e2                	shl    %cl,%edx
  800f61:	89 f9                	mov    %edi,%ecx
  800f63:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f67:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f6b:	d3 e8                	shr    %cl,%eax
  800f6d:	89 e9                	mov    %ebp,%ecx
  800f6f:	89 c6                	mov    %eax,%esi
  800f71:	d3 e3                	shl    %cl,%ebx
  800f73:	89 f9                	mov    %edi,%ecx
  800f75:	89 d0                	mov    %edx,%eax
  800f77:	d3 e8                	shr    %cl,%eax
  800f79:	89 e9                	mov    %ebp,%ecx
  800f7b:	09 d8                	or     %ebx,%eax
  800f7d:	89 d3                	mov    %edx,%ebx
  800f7f:	89 f2                	mov    %esi,%edx
  800f81:	f7 34 24             	divl   (%esp)
  800f84:	89 d6                	mov    %edx,%esi
  800f86:	d3 e3                	shl    %cl,%ebx
  800f88:	f7 64 24 04          	mull   0x4(%esp)
  800f8c:	39 d6                	cmp    %edx,%esi
  800f8e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f92:	89 d1                	mov    %edx,%ecx
  800f94:	89 c3                	mov    %eax,%ebx
  800f96:	72 08                	jb     800fa0 <__umoddi3+0x110>
  800f98:	75 11                	jne    800fab <__umoddi3+0x11b>
  800f9a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f9e:	73 0b                	jae    800fab <__umoddi3+0x11b>
  800fa0:	2b 44 24 04          	sub    0x4(%esp),%eax
  800fa4:	1b 14 24             	sbb    (%esp),%edx
  800fa7:	89 d1                	mov    %edx,%ecx
  800fa9:	89 c3                	mov    %eax,%ebx
  800fab:	8b 54 24 08          	mov    0x8(%esp),%edx
  800faf:	29 da                	sub    %ebx,%edx
  800fb1:	19 ce                	sbb    %ecx,%esi
  800fb3:	89 f9                	mov    %edi,%ecx
  800fb5:	89 f0                	mov    %esi,%eax
  800fb7:	d3 e0                	shl    %cl,%eax
  800fb9:	89 e9                	mov    %ebp,%ecx
  800fbb:	d3 ea                	shr    %cl,%edx
  800fbd:	89 e9                	mov    %ebp,%ecx
  800fbf:	d3 ee                	shr    %cl,%esi
  800fc1:	09 d0                	or     %edx,%eax
  800fc3:	89 f2                	mov    %esi,%edx
  800fc5:	83 c4 1c             	add    $0x1c,%esp
  800fc8:	5b                   	pop    %ebx
  800fc9:	5e                   	pop    %esi
  800fca:	5f                   	pop    %edi
  800fcb:	5d                   	pop    %ebp
  800fcc:	c3                   	ret    
  800fcd:	8d 76 00             	lea    0x0(%esi),%esi
  800fd0:	29 f9                	sub    %edi,%ecx
  800fd2:	19 d6                	sbb    %edx,%esi
  800fd4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fd8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fdc:	e9 18 ff ff ff       	jmp    800ef9 <__umoddi3+0x69>
