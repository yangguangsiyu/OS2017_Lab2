
obj/user/faultread：     文件格式 elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800039:	ff 35 00 00 00 00    	pushl  0x0
  80003f:	68 60 0f 80 00       	push   $0x800f60
  800044:	e8 f0 00 00 00       	call   800139 <cprintf>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800059:	e8 3c 0a 00 00       	call   800a9a <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 b8 09 00 00       	call   800a59 <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	53                   	push   %ebx
  8000aa:	83 ec 04             	sub    $0x4,%esp
  8000ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b0:	8b 13                	mov    (%ebx),%edx
  8000b2:	8d 42 01             	lea    0x1(%edx),%eax
  8000b5:	89 03                	mov    %eax,(%ebx)
  8000b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c3:	75 1a                	jne    8000df <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000c5:	83 ec 08             	sub    $0x8,%esp
  8000c8:	68 ff 00 00 00       	push   $0xff
  8000cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d0:	50                   	push   %eax
  8000d1:	e8 46 09 00 00       	call   800a1c <sys_cputs>
		b->idx = 0;
  8000d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000df:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e6:	c9                   	leave  
  8000e7:	c3                   	ret    

008000e8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000f8:	00 00 00 
	b.cnt = 0;
  8000fb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800102:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800105:	ff 75 0c             	pushl  0xc(%ebp)
  800108:	ff 75 08             	pushl  0x8(%ebp)
  80010b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800111:	50                   	push   %eax
  800112:	68 a6 00 80 00       	push   $0x8000a6
  800117:	e8 54 01 00 00       	call   800270 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80011c:	83 c4 08             	add    $0x8,%esp
  80011f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800125:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 eb 08 00 00       	call   800a1c <sys_cputs>

	return b.cnt;
}
  800131:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800137:	c9                   	leave  
  800138:	c3                   	ret    

00800139 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80013f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800142:	50                   	push   %eax
  800143:	ff 75 08             	pushl  0x8(%ebp)
  800146:	e8 9d ff ff ff       	call   8000e8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	57                   	push   %edi
  800151:	56                   	push   %esi
  800152:	53                   	push   %ebx
  800153:	83 ec 1c             	sub    $0x1c,%esp
  800156:	89 c7                	mov    %eax,%edi
  800158:	89 d6                	mov    %edx,%esi
  80015a:	8b 45 08             	mov    0x8(%ebp),%eax
  80015d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800160:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800163:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800166:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800169:	bb 00 00 00 00       	mov    $0x0,%ebx
  80016e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800171:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800174:	39 d3                	cmp    %edx,%ebx
  800176:	72 05                	jb     80017d <printnum+0x30>
  800178:	39 45 10             	cmp    %eax,0x10(%ebp)
  80017b:	77 45                	ja     8001c2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80017d:	83 ec 0c             	sub    $0xc,%esp
  800180:	ff 75 18             	pushl  0x18(%ebp)
  800183:	8b 45 14             	mov    0x14(%ebp),%eax
  800186:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800189:	53                   	push   %ebx
  80018a:	ff 75 10             	pushl  0x10(%ebp)
  80018d:	83 ec 08             	sub    $0x8,%esp
  800190:	ff 75 e4             	pushl  -0x1c(%ebp)
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	ff 75 dc             	pushl  -0x24(%ebp)
  800199:	ff 75 d8             	pushl  -0x28(%ebp)
  80019c:	e8 2f 0b 00 00       	call   800cd0 <__udivdi3>
  8001a1:	83 c4 18             	add    $0x18,%esp
  8001a4:	52                   	push   %edx
  8001a5:	50                   	push   %eax
  8001a6:	89 f2                	mov    %esi,%edx
  8001a8:	89 f8                	mov    %edi,%eax
  8001aa:	e8 9e ff ff ff       	call   80014d <printnum>
  8001af:	83 c4 20             	add    $0x20,%esp
  8001b2:	eb 18                	jmp    8001cc <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001b4:	83 ec 08             	sub    $0x8,%esp
  8001b7:	56                   	push   %esi
  8001b8:	ff 75 18             	pushl  0x18(%ebp)
  8001bb:	ff d7                	call   *%edi
  8001bd:	83 c4 10             	add    $0x10,%esp
  8001c0:	eb 03                	jmp    8001c5 <printnum+0x78>
  8001c2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c5:	83 eb 01             	sub    $0x1,%ebx
  8001c8:	85 db                	test   %ebx,%ebx
  8001ca:	7f e8                	jg     8001b4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001cc:	83 ec 08             	sub    $0x8,%esp
  8001cf:	56                   	push   %esi
  8001d0:	83 ec 04             	sub    $0x4,%esp
  8001d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001dc:	ff 75 d8             	pushl  -0x28(%ebp)
  8001df:	e8 1c 0c 00 00       	call   800e00 <__umoddi3>
  8001e4:	83 c4 14             	add    $0x14,%esp
  8001e7:	0f be 80 88 0f 80 00 	movsbl 0x800f88(%eax),%eax
  8001ee:	50                   	push   %eax
  8001ef:	ff d7                	call   *%edi
}
  8001f1:	83 c4 10             	add    $0x10,%esp
  8001f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f7:	5b                   	pop    %ebx
  8001f8:	5e                   	pop    %esi
  8001f9:	5f                   	pop    %edi
  8001fa:	5d                   	pop    %ebp
  8001fb:	c3                   	ret    

008001fc <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8001ff:	83 fa 01             	cmp    $0x1,%edx
  800202:	7e 0e                	jle    800212 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800204:	8b 10                	mov    (%eax),%edx
  800206:	8d 4a 08             	lea    0x8(%edx),%ecx
  800209:	89 08                	mov    %ecx,(%eax)
  80020b:	8b 02                	mov    (%edx),%eax
  80020d:	8b 52 04             	mov    0x4(%edx),%edx
  800210:	eb 22                	jmp    800234 <getuint+0x38>
	else if (lflag)
  800212:	85 d2                	test   %edx,%edx
  800214:	74 10                	je     800226 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800216:	8b 10                	mov    (%eax),%edx
  800218:	8d 4a 04             	lea    0x4(%edx),%ecx
  80021b:	89 08                	mov    %ecx,(%eax)
  80021d:	8b 02                	mov    (%edx),%eax
  80021f:	ba 00 00 00 00       	mov    $0x0,%edx
  800224:	eb 0e                	jmp    800234 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800226:	8b 10                	mov    (%eax),%edx
  800228:	8d 4a 04             	lea    0x4(%edx),%ecx
  80022b:	89 08                	mov    %ecx,(%eax)
  80022d:	8b 02                	mov    (%edx),%eax
  80022f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800234:	5d                   	pop    %ebp
  800235:	c3                   	ret    

00800236 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80023c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800240:	8b 10                	mov    (%eax),%edx
  800242:	3b 50 04             	cmp    0x4(%eax),%edx
  800245:	73 0a                	jae    800251 <sprintputch+0x1b>
		*b->buf++ = ch;
  800247:	8d 4a 01             	lea    0x1(%edx),%ecx
  80024a:	89 08                	mov    %ecx,(%eax)
  80024c:	8b 45 08             	mov    0x8(%ebp),%eax
  80024f:	88 02                	mov    %al,(%edx)
}
  800251:	5d                   	pop    %ebp
  800252:	c3                   	ret    

00800253 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800259:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80025c:	50                   	push   %eax
  80025d:	ff 75 10             	pushl  0x10(%ebp)
  800260:	ff 75 0c             	pushl  0xc(%ebp)
  800263:	ff 75 08             	pushl  0x8(%ebp)
  800266:	e8 05 00 00 00       	call   800270 <vprintfmt>
	va_end(ap);
}
  80026b:	83 c4 10             	add    $0x10,%esp
  80026e:	c9                   	leave  
  80026f:	c3                   	ret    

00800270 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 2c             	sub    $0x2c,%esp
  800279:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
  80027c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800283:	eb 17                	jmp    80029c <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800285:	85 c0                	test   %eax,%eax
  800287:	0f 84 9f 03 00 00    	je     80062c <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
  80028d:	83 ec 08             	sub    $0x8,%esp
  800290:	ff 75 0c             	pushl  0xc(%ebp)
  800293:	50                   	push   %eax
  800294:	ff 55 08             	call   *0x8(%ebp)
  800297:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80029a:	89 f3                	mov    %esi,%ebx
  80029c:	8d 73 01             	lea    0x1(%ebx),%esi
  80029f:	0f b6 03             	movzbl (%ebx),%eax
  8002a2:	83 f8 25             	cmp    $0x25,%eax
  8002a5:	75 de                	jne    800285 <vprintfmt+0x15>
  8002a7:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8002ab:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002b2:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8002b7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002be:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c3:	eb 06                	jmp    8002cb <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002c5:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002c7:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002cb:	8d 5e 01             	lea    0x1(%esi),%ebx
  8002ce:	0f b6 06             	movzbl (%esi),%eax
  8002d1:	0f b6 c8             	movzbl %al,%ecx
  8002d4:	83 e8 23             	sub    $0x23,%eax
  8002d7:	3c 55                	cmp    $0x55,%al
  8002d9:	0f 87 2d 03 00 00    	ja     80060c <vprintfmt+0x39c>
  8002df:	0f b6 c0             	movzbl %al,%eax
  8002e2:	ff 24 85 40 10 80 00 	jmp    *0x801040(,%eax,4)
  8002e9:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002eb:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8002ef:	eb da                	jmp    8002cb <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f1:	89 de                	mov    %ebx,%esi
  8002f3:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002f8:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  8002fb:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  8002ff:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  800302:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800305:	83 f8 09             	cmp    $0x9,%eax
  800308:	77 33                	ja     80033d <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80030a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80030d:	eb e9                	jmp    8002f8 <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80030f:	8b 45 14             	mov    0x14(%ebp),%eax
  800312:	8d 48 04             	lea    0x4(%eax),%ecx
  800315:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800318:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031a:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80031c:	eb 1f                	jmp    80033d <vprintfmt+0xcd>
  80031e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800321:	85 c0                	test   %eax,%eax
  800323:	b9 00 00 00 00       	mov    $0x0,%ecx
  800328:	0f 49 c8             	cmovns %eax,%ecx
  80032b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032e:	89 de                	mov    %ebx,%esi
  800330:	eb 99                	jmp    8002cb <vprintfmt+0x5b>
  800332:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800334:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  80033b:	eb 8e                	jmp    8002cb <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80033d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800341:	79 88                	jns    8002cb <vprintfmt+0x5b>
				width = precision, precision = -1;
  800343:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800346:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80034b:	e9 7b ff ff ff       	jmp    8002cb <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800350:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800353:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800355:	e9 71 ff ff ff       	jmp    8002cb <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
  80035a:	8b 45 14             	mov    0x14(%ebp),%eax
  80035d:	8d 50 04             	lea    0x4(%eax),%edx
  800360:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  800363:	83 ec 08             	sub    $0x8,%esp
  800366:	ff 75 0c             	pushl  0xc(%ebp)
  800369:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80036c:	03 08                	add    (%eax),%ecx
  80036e:	51                   	push   %ecx
  80036f:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
  800372:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
  800375:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
  80037c:	e9 1b ff ff ff       	jmp    80029c <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
  800381:	8b 45 14             	mov    0x14(%ebp),%eax
  800384:	8d 48 04             	lea    0x4(%eax),%ecx
  800387:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80038a:	8b 00                	mov    (%eax),%eax
  80038c:	83 f8 02             	cmp    $0x2,%eax
  80038f:	74 1a                	je     8003ab <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800391:	89 de                	mov    %ebx,%esi
  800393:	83 f8 04             	cmp    $0x4,%eax
  800396:	b8 00 00 00 00       	mov    $0x0,%eax
  80039b:	b9 00 04 00 00       	mov    $0x400,%ecx
  8003a0:	0f 44 c1             	cmove  %ecx,%eax
  8003a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a6:	e9 20 ff ff ff       	jmp    8002cb <vprintfmt+0x5b>
  8003ab:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
  8003ad:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
  8003b4:	e9 12 ff ff ff       	jmp    8002cb <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bc:	8d 50 04             	lea    0x4(%eax),%edx
  8003bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c2:	8b 00                	mov    (%eax),%eax
  8003c4:	99                   	cltd   
  8003c5:	31 d0                	xor    %edx,%eax
  8003c7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c9:	83 f8 09             	cmp    $0x9,%eax
  8003cc:	7f 0b                	jg     8003d9 <vprintfmt+0x169>
  8003ce:	8b 14 85 a0 11 80 00 	mov    0x8011a0(,%eax,4),%edx
  8003d5:	85 d2                	test   %edx,%edx
  8003d7:	75 19                	jne    8003f2 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  8003d9:	50                   	push   %eax
  8003da:	68 a0 0f 80 00       	push   $0x800fa0
  8003df:	ff 75 0c             	pushl  0xc(%ebp)
  8003e2:	ff 75 08             	pushl  0x8(%ebp)
  8003e5:	e8 69 fe ff ff       	call   800253 <printfmt>
  8003ea:	83 c4 10             	add    $0x10,%esp
  8003ed:	e9 aa fe ff ff       	jmp    80029c <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  8003f2:	52                   	push   %edx
  8003f3:	68 a9 0f 80 00       	push   $0x800fa9
  8003f8:	ff 75 0c             	pushl  0xc(%ebp)
  8003fb:	ff 75 08             	pushl  0x8(%ebp)
  8003fe:	e8 50 fe ff ff       	call   800253 <printfmt>
  800403:	83 c4 10             	add    $0x10,%esp
  800406:	e9 91 fe ff ff       	jmp    80029c <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80040b:	8b 45 14             	mov    0x14(%ebp),%eax
  80040e:	8d 50 04             	lea    0x4(%eax),%edx
  800411:	89 55 14             	mov    %edx,0x14(%ebp)
  800414:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800416:	85 f6                	test   %esi,%esi
  800418:	b8 99 0f 80 00       	mov    $0x800f99,%eax
  80041d:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800420:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800424:	0f 8e 93 00 00 00    	jle    8004bd <vprintfmt+0x24d>
  80042a:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80042e:	0f 84 91 00 00 00    	je     8004c5 <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
  800434:	83 ec 08             	sub    $0x8,%esp
  800437:	57                   	push   %edi
  800438:	56                   	push   %esi
  800439:	e8 76 02 00 00       	call   8006b4 <strnlen>
  80043e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800441:	29 c1                	sub    %eax,%ecx
  800443:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800446:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800449:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  80044d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800450:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800453:	8b 75 0c             	mov    0xc(%ebp),%esi
  800456:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800459:	89 cb                	mov    %ecx,%ebx
  80045b:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80045d:	eb 0e                	jmp    80046d <vprintfmt+0x1fd>
					putch(padc, putdat);
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	56                   	push   %esi
  800463:	57                   	push   %edi
  800464:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800467:	83 eb 01             	sub    $0x1,%ebx
  80046a:	83 c4 10             	add    $0x10,%esp
  80046d:	85 db                	test   %ebx,%ebx
  80046f:	7f ee                	jg     80045f <vprintfmt+0x1ef>
  800471:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800474:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800477:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80047a:	85 c9                	test   %ecx,%ecx
  80047c:	b8 00 00 00 00       	mov    $0x0,%eax
  800481:	0f 49 c1             	cmovns %ecx,%eax
  800484:	29 c1                	sub    %eax,%ecx
  800486:	89 cb                	mov    %ecx,%ebx
  800488:	eb 41                	jmp    8004cb <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80048a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80048e:	74 1b                	je     8004ab <vprintfmt+0x23b>
  800490:	0f be c0             	movsbl %al,%eax
  800493:	83 e8 20             	sub    $0x20,%eax
  800496:	83 f8 5e             	cmp    $0x5e,%eax
  800499:	76 10                	jbe    8004ab <vprintfmt+0x23b>
					putch('?', putdat);
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	ff 75 0c             	pushl  0xc(%ebp)
  8004a1:	6a 3f                	push   $0x3f
  8004a3:	ff 55 08             	call   *0x8(%ebp)
  8004a6:	83 c4 10             	add    $0x10,%esp
  8004a9:	eb 0d                	jmp    8004b8 <vprintfmt+0x248>
				else
					putch(ch, putdat);
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	ff 75 0c             	pushl  0xc(%ebp)
  8004b1:	52                   	push   %edx
  8004b2:	ff 55 08             	call   *0x8(%ebp)
  8004b5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b8:	83 eb 01             	sub    $0x1,%ebx
  8004bb:	eb 0e                	jmp    8004cb <vprintfmt+0x25b>
  8004bd:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004c0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c3:	eb 06                	jmp    8004cb <vprintfmt+0x25b>
  8004c5:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004c8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004cb:	83 c6 01             	add    $0x1,%esi
  8004ce:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8004d2:	0f be d0             	movsbl %al,%edx
  8004d5:	85 d2                	test   %edx,%edx
  8004d7:	74 25                	je     8004fe <vprintfmt+0x28e>
  8004d9:	85 ff                	test   %edi,%edi
  8004db:	78 ad                	js     80048a <vprintfmt+0x21a>
  8004dd:	83 ef 01             	sub    $0x1,%edi
  8004e0:	79 a8                	jns    80048a <vprintfmt+0x21a>
  8004e2:	89 d8                	mov    %ebx,%eax
  8004e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004ea:	89 c3                	mov    %eax,%ebx
  8004ec:	eb 16                	jmp    800504 <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	57                   	push   %edi
  8004f2:	6a 20                	push   $0x20
  8004f4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f6:	83 eb 01             	sub    $0x1,%ebx
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	eb 06                	jmp    800504 <vprintfmt+0x294>
  8004fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800501:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800504:	85 db                	test   %ebx,%ebx
  800506:	7f e6                	jg     8004ee <vprintfmt+0x27e>
  800508:	89 75 08             	mov    %esi,0x8(%ebp)
  80050b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80050e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800511:	e9 86 fd ff ff       	jmp    80029c <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800516:	83 fa 01             	cmp    $0x1,%edx
  800519:	7e 10                	jle    80052b <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	8d 50 08             	lea    0x8(%eax),%edx
  800521:	89 55 14             	mov    %edx,0x14(%ebp)
  800524:	8b 30                	mov    (%eax),%esi
  800526:	8b 78 04             	mov    0x4(%eax),%edi
  800529:	eb 26                	jmp    800551 <vprintfmt+0x2e1>
	else if (lflag)
  80052b:	85 d2                	test   %edx,%edx
  80052d:	74 12                	je     800541 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  80052f:	8b 45 14             	mov    0x14(%ebp),%eax
  800532:	8d 50 04             	lea    0x4(%eax),%edx
  800535:	89 55 14             	mov    %edx,0x14(%ebp)
  800538:	8b 30                	mov    (%eax),%esi
  80053a:	89 f7                	mov    %esi,%edi
  80053c:	c1 ff 1f             	sar    $0x1f,%edi
  80053f:	eb 10                	jmp    800551 <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
  800541:	8b 45 14             	mov    0x14(%ebp),%eax
  800544:	8d 50 04             	lea    0x4(%eax),%edx
  800547:	89 55 14             	mov    %edx,0x14(%ebp)
  80054a:	8b 30                	mov    (%eax),%esi
  80054c:	89 f7                	mov    %esi,%edi
  80054e:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800551:	89 f0                	mov    %esi,%eax
  800553:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800555:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80055a:	85 ff                	test   %edi,%edi
  80055c:	79 7b                	jns    8005d9 <vprintfmt+0x369>
				putch('-', putdat);
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	ff 75 0c             	pushl  0xc(%ebp)
  800564:	6a 2d                	push   $0x2d
  800566:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800569:	89 f0                	mov    %esi,%eax
  80056b:	89 fa                	mov    %edi,%edx
  80056d:	f7 d8                	neg    %eax
  80056f:	83 d2 00             	adc    $0x0,%edx
  800572:	f7 da                	neg    %edx
  800574:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800577:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80057c:	eb 5b                	jmp    8005d9 <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80057e:	8d 45 14             	lea    0x14(%ebp),%eax
  800581:	e8 76 fc ff ff       	call   8001fc <getuint>
			base = 10;
  800586:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80058b:	eb 4c                	jmp    8005d9 <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
  80058d:	8d 45 14             	lea    0x14(%ebp),%eax
  800590:	e8 67 fc ff ff       	call   8001fc <getuint>
            base = 8;
  800595:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80059a:	eb 3d                	jmp    8005d9 <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
  80059c:	83 ec 08             	sub    $0x8,%esp
  80059f:	ff 75 0c             	pushl  0xc(%ebp)
  8005a2:	6a 30                	push   $0x30
  8005a4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005a7:	83 c4 08             	add    $0x8,%esp
  8005aa:	ff 75 0c             	pushl  0xc(%ebp)
  8005ad:	6a 78                	push   $0x78
  8005af:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8d 50 04             	lea    0x4(%eax),%edx
  8005b8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005bb:	8b 00                	mov    (%eax),%eax
  8005bd:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005c2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005c5:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005ca:	eb 0d                	jmp    8005d9 <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005cc:	8d 45 14             	lea    0x14(%ebp),%eax
  8005cf:	e8 28 fc ff ff       	call   8001fc <getuint>
			base = 16;
  8005d4:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005d9:	83 ec 0c             	sub    $0xc,%esp
  8005dc:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  8005e0:	56                   	push   %esi
  8005e1:	ff 75 e0             	pushl  -0x20(%ebp)
  8005e4:	51                   	push   %ecx
  8005e5:	52                   	push   %edx
  8005e6:	50                   	push   %eax
  8005e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ed:	e8 5b fb ff ff       	call   80014d <printnum>
			break;
  8005f2:	83 c4 20             	add    $0x20,%esp
  8005f5:	e9 a2 fc ff ff       	jmp    80029c <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005fa:	83 ec 08             	sub    $0x8,%esp
  8005fd:	ff 75 0c             	pushl  0xc(%ebp)
  800600:	51                   	push   %ecx
  800601:	ff 55 08             	call   *0x8(%ebp)
			break;
  800604:	83 c4 10             	add    $0x10,%esp
  800607:	e9 90 fc ff ff       	jmp    80029c <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80060c:	83 ec 08             	sub    $0x8,%esp
  80060f:	ff 75 0c             	pushl  0xc(%ebp)
  800612:	6a 25                	push   $0x25
  800614:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800617:	83 c4 10             	add    $0x10,%esp
  80061a:	89 f3                	mov    %esi,%ebx
  80061c:	eb 03                	jmp    800621 <vprintfmt+0x3b1>
  80061e:	83 eb 01             	sub    $0x1,%ebx
  800621:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800625:	75 f7                	jne    80061e <vprintfmt+0x3ae>
  800627:	e9 70 fc ff ff       	jmp    80029c <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  80062c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062f:	5b                   	pop    %ebx
  800630:	5e                   	pop    %esi
  800631:	5f                   	pop    %edi
  800632:	5d                   	pop    %ebp
  800633:	c3                   	ret    

00800634 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800634:	55                   	push   %ebp
  800635:	89 e5                	mov    %esp,%ebp
  800637:	83 ec 18             	sub    $0x18,%esp
  80063a:	8b 45 08             	mov    0x8(%ebp),%eax
  80063d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800640:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800643:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800647:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80064a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800651:	85 c0                	test   %eax,%eax
  800653:	74 26                	je     80067b <vsnprintf+0x47>
  800655:	85 d2                	test   %edx,%edx
  800657:	7e 22                	jle    80067b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800659:	ff 75 14             	pushl  0x14(%ebp)
  80065c:	ff 75 10             	pushl  0x10(%ebp)
  80065f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800662:	50                   	push   %eax
  800663:	68 36 02 80 00       	push   $0x800236
  800668:	e8 03 fc ff ff       	call   800270 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80066d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800670:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800673:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800676:	83 c4 10             	add    $0x10,%esp
  800679:	eb 05                	jmp    800680 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80067b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800680:	c9                   	leave  
  800681:	c3                   	ret    

00800682 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800682:	55                   	push   %ebp
  800683:	89 e5                	mov    %esp,%ebp
  800685:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800688:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80068b:	50                   	push   %eax
  80068c:	ff 75 10             	pushl  0x10(%ebp)
  80068f:	ff 75 0c             	pushl  0xc(%ebp)
  800692:	ff 75 08             	pushl  0x8(%ebp)
  800695:	e8 9a ff ff ff       	call   800634 <vsnprintf>
	va_end(ap);

	return rc;
}
  80069a:	c9                   	leave  
  80069b:	c3                   	ret    

0080069c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80069c:	55                   	push   %ebp
  80069d:	89 e5                	mov    %esp,%ebp
  80069f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a7:	eb 03                	jmp    8006ac <strlen+0x10>
		n++;
  8006a9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ac:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006b0:	75 f7                	jne    8006a9 <strlen+0xd>
		n++;
	return n;
}
  8006b2:	5d                   	pop    %ebp
  8006b3:	c3                   	ret    

008006b4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ba:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c2:	eb 03                	jmp    8006c7 <strnlen+0x13>
		n++;
  8006c4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006c7:	39 c2                	cmp    %eax,%edx
  8006c9:	74 08                	je     8006d3 <strnlen+0x1f>
  8006cb:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006cf:	75 f3                	jne    8006c4 <strnlen+0x10>
  8006d1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006d3:	5d                   	pop    %ebp
  8006d4:	c3                   	ret    

008006d5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006d5:	55                   	push   %ebp
  8006d6:	89 e5                	mov    %esp,%ebp
  8006d8:	53                   	push   %ebx
  8006d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006df:	89 c2                	mov    %eax,%edx
  8006e1:	83 c2 01             	add    $0x1,%edx
  8006e4:	83 c1 01             	add    $0x1,%ecx
  8006e7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006eb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006ee:	84 db                	test   %bl,%bl
  8006f0:	75 ef                	jne    8006e1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006f2:	5b                   	pop    %ebx
  8006f3:	5d                   	pop    %ebp
  8006f4:	c3                   	ret    

008006f5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	53                   	push   %ebx
  8006f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006fc:	53                   	push   %ebx
  8006fd:	e8 9a ff ff ff       	call   80069c <strlen>
  800702:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800705:	ff 75 0c             	pushl  0xc(%ebp)
  800708:	01 d8                	add    %ebx,%eax
  80070a:	50                   	push   %eax
  80070b:	e8 c5 ff ff ff       	call   8006d5 <strcpy>
	return dst;
}
  800710:	89 d8                	mov    %ebx,%eax
  800712:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800715:	c9                   	leave  
  800716:	c3                   	ret    

00800717 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	56                   	push   %esi
  80071b:	53                   	push   %ebx
  80071c:	8b 75 08             	mov    0x8(%ebp),%esi
  80071f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800722:	89 f3                	mov    %esi,%ebx
  800724:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800727:	89 f2                	mov    %esi,%edx
  800729:	eb 0f                	jmp    80073a <strncpy+0x23>
		*dst++ = *src;
  80072b:	83 c2 01             	add    $0x1,%edx
  80072e:	0f b6 01             	movzbl (%ecx),%eax
  800731:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800734:	80 39 01             	cmpb   $0x1,(%ecx)
  800737:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80073a:	39 da                	cmp    %ebx,%edx
  80073c:	75 ed                	jne    80072b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80073e:	89 f0                	mov    %esi,%eax
  800740:	5b                   	pop    %ebx
  800741:	5e                   	pop    %esi
  800742:	5d                   	pop    %ebp
  800743:	c3                   	ret    

00800744 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	56                   	push   %esi
  800748:	53                   	push   %ebx
  800749:	8b 75 08             	mov    0x8(%ebp),%esi
  80074c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80074f:	8b 55 10             	mov    0x10(%ebp),%edx
  800752:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800754:	85 d2                	test   %edx,%edx
  800756:	74 21                	je     800779 <strlcpy+0x35>
  800758:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80075c:	89 f2                	mov    %esi,%edx
  80075e:	eb 09                	jmp    800769 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800760:	83 c2 01             	add    $0x1,%edx
  800763:	83 c1 01             	add    $0x1,%ecx
  800766:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800769:	39 c2                	cmp    %eax,%edx
  80076b:	74 09                	je     800776 <strlcpy+0x32>
  80076d:	0f b6 19             	movzbl (%ecx),%ebx
  800770:	84 db                	test   %bl,%bl
  800772:	75 ec                	jne    800760 <strlcpy+0x1c>
  800774:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800776:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800779:	29 f0                	sub    %esi,%eax
}
  80077b:	5b                   	pop    %ebx
  80077c:	5e                   	pop    %esi
  80077d:	5d                   	pop    %ebp
  80077e:	c3                   	ret    

0080077f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800785:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800788:	eb 06                	jmp    800790 <strcmp+0x11>
		p++, q++;
  80078a:	83 c1 01             	add    $0x1,%ecx
  80078d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800790:	0f b6 01             	movzbl (%ecx),%eax
  800793:	84 c0                	test   %al,%al
  800795:	74 04                	je     80079b <strcmp+0x1c>
  800797:	3a 02                	cmp    (%edx),%al
  800799:	74 ef                	je     80078a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80079b:	0f b6 c0             	movzbl %al,%eax
  80079e:	0f b6 12             	movzbl (%edx),%edx
  8007a1:	29 d0                	sub    %edx,%eax
}
  8007a3:	5d                   	pop    %ebp
  8007a4:	c3                   	ret    

008007a5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	53                   	push   %ebx
  8007a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007af:	89 c3                	mov    %eax,%ebx
  8007b1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007b4:	eb 06                	jmp    8007bc <strncmp+0x17>
		n--, p++, q++;
  8007b6:	83 c0 01             	add    $0x1,%eax
  8007b9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007bc:	39 d8                	cmp    %ebx,%eax
  8007be:	74 15                	je     8007d5 <strncmp+0x30>
  8007c0:	0f b6 08             	movzbl (%eax),%ecx
  8007c3:	84 c9                	test   %cl,%cl
  8007c5:	74 04                	je     8007cb <strncmp+0x26>
  8007c7:	3a 0a                	cmp    (%edx),%cl
  8007c9:	74 eb                	je     8007b6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007cb:	0f b6 00             	movzbl (%eax),%eax
  8007ce:	0f b6 12             	movzbl (%edx),%edx
  8007d1:	29 d0                	sub    %edx,%eax
  8007d3:	eb 05                	jmp    8007da <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007d5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007da:	5b                   	pop    %ebx
  8007db:	5d                   	pop    %ebp
  8007dc:	c3                   	ret    

008007dd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007e7:	eb 07                	jmp    8007f0 <strchr+0x13>
		if (*s == c)
  8007e9:	38 ca                	cmp    %cl,%dl
  8007eb:	74 0f                	je     8007fc <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007ed:	83 c0 01             	add    $0x1,%eax
  8007f0:	0f b6 10             	movzbl (%eax),%edx
  8007f3:	84 d2                	test   %dl,%dl
  8007f5:	75 f2                	jne    8007e9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8007f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	8b 45 08             	mov    0x8(%ebp),%eax
  800804:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800808:	eb 03                	jmp    80080d <strfind+0xf>
  80080a:	83 c0 01             	add    $0x1,%eax
  80080d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800810:	38 ca                	cmp    %cl,%dl
  800812:	74 04                	je     800818 <strfind+0x1a>
  800814:	84 d2                	test   %dl,%dl
  800816:	75 f2                	jne    80080a <strfind+0xc>
			break;
	return (char *) s;
}
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	57                   	push   %edi
  80081e:	56                   	push   %esi
  80081f:	53                   	push   %ebx
  800820:	8b 7d 08             	mov    0x8(%ebp),%edi
  800823:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800826:	85 c9                	test   %ecx,%ecx
  800828:	74 36                	je     800860 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80082a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800830:	75 28                	jne    80085a <memset+0x40>
  800832:	f6 c1 03             	test   $0x3,%cl
  800835:	75 23                	jne    80085a <memset+0x40>
		c &= 0xFF;
  800837:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80083b:	89 d3                	mov    %edx,%ebx
  80083d:	c1 e3 08             	shl    $0x8,%ebx
  800840:	89 d6                	mov    %edx,%esi
  800842:	c1 e6 18             	shl    $0x18,%esi
  800845:	89 d0                	mov    %edx,%eax
  800847:	c1 e0 10             	shl    $0x10,%eax
  80084a:	09 f0                	or     %esi,%eax
  80084c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80084e:	89 d8                	mov    %ebx,%eax
  800850:	09 d0                	or     %edx,%eax
  800852:	c1 e9 02             	shr    $0x2,%ecx
  800855:	fc                   	cld    
  800856:	f3 ab                	rep stos %eax,%es:(%edi)
  800858:	eb 06                	jmp    800860 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80085a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085d:	fc                   	cld    
  80085e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800860:	89 f8                	mov    %edi,%eax
  800862:	5b                   	pop    %ebx
  800863:	5e                   	pop    %esi
  800864:	5f                   	pop    %edi
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	57                   	push   %edi
  80086b:	56                   	push   %esi
  80086c:	8b 45 08             	mov    0x8(%ebp),%eax
  80086f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800872:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800875:	39 c6                	cmp    %eax,%esi
  800877:	73 35                	jae    8008ae <memmove+0x47>
  800879:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80087c:	39 d0                	cmp    %edx,%eax
  80087e:	73 2e                	jae    8008ae <memmove+0x47>
		s += n;
		d += n;
  800880:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800883:	89 d6                	mov    %edx,%esi
  800885:	09 fe                	or     %edi,%esi
  800887:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80088d:	75 13                	jne    8008a2 <memmove+0x3b>
  80088f:	f6 c1 03             	test   $0x3,%cl
  800892:	75 0e                	jne    8008a2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800894:	83 ef 04             	sub    $0x4,%edi
  800897:	8d 72 fc             	lea    -0x4(%edx),%esi
  80089a:	c1 e9 02             	shr    $0x2,%ecx
  80089d:	fd                   	std    
  80089e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008a0:	eb 09                	jmp    8008ab <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008a2:	83 ef 01             	sub    $0x1,%edi
  8008a5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008a8:	fd                   	std    
  8008a9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ab:	fc                   	cld    
  8008ac:	eb 1d                	jmp    8008cb <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ae:	89 f2                	mov    %esi,%edx
  8008b0:	09 c2                	or     %eax,%edx
  8008b2:	f6 c2 03             	test   $0x3,%dl
  8008b5:	75 0f                	jne    8008c6 <memmove+0x5f>
  8008b7:	f6 c1 03             	test   $0x3,%cl
  8008ba:	75 0a                	jne    8008c6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008bc:	c1 e9 02             	shr    $0x2,%ecx
  8008bf:	89 c7                	mov    %eax,%edi
  8008c1:	fc                   	cld    
  8008c2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c4:	eb 05                	jmp    8008cb <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008c6:	89 c7                	mov    %eax,%edi
  8008c8:	fc                   	cld    
  8008c9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008cb:	5e                   	pop    %esi
  8008cc:	5f                   	pop    %edi
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008d2:	ff 75 10             	pushl  0x10(%ebp)
  8008d5:	ff 75 0c             	pushl  0xc(%ebp)
  8008d8:	ff 75 08             	pushl  0x8(%ebp)
  8008db:	e8 87 ff ff ff       	call   800867 <memmove>
}
  8008e0:	c9                   	leave  
  8008e1:	c3                   	ret    

008008e2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	56                   	push   %esi
  8008e6:	53                   	push   %ebx
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ed:	89 c6                	mov    %eax,%esi
  8008ef:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008f2:	eb 1a                	jmp    80090e <memcmp+0x2c>
		if (*s1 != *s2)
  8008f4:	0f b6 08             	movzbl (%eax),%ecx
  8008f7:	0f b6 1a             	movzbl (%edx),%ebx
  8008fa:	38 d9                	cmp    %bl,%cl
  8008fc:	74 0a                	je     800908 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8008fe:	0f b6 c1             	movzbl %cl,%eax
  800901:	0f b6 db             	movzbl %bl,%ebx
  800904:	29 d8                	sub    %ebx,%eax
  800906:	eb 0f                	jmp    800917 <memcmp+0x35>
		s1++, s2++;
  800908:	83 c0 01             	add    $0x1,%eax
  80090b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80090e:	39 f0                	cmp    %esi,%eax
  800910:	75 e2                	jne    8008f4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800912:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800917:	5b                   	pop    %ebx
  800918:	5e                   	pop    %esi
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	53                   	push   %ebx
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800922:	89 c1                	mov    %eax,%ecx
  800924:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800927:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80092b:	eb 0a                	jmp    800937 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80092d:	0f b6 10             	movzbl (%eax),%edx
  800930:	39 da                	cmp    %ebx,%edx
  800932:	74 07                	je     80093b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800934:	83 c0 01             	add    $0x1,%eax
  800937:	39 c8                	cmp    %ecx,%eax
  800939:	72 f2                	jb     80092d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80093b:	5b                   	pop    %ebx
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	57                   	push   %edi
  800942:	56                   	push   %esi
  800943:	53                   	push   %ebx
  800944:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800947:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80094a:	eb 03                	jmp    80094f <strtol+0x11>
		s++;
  80094c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80094f:	0f b6 01             	movzbl (%ecx),%eax
  800952:	3c 20                	cmp    $0x20,%al
  800954:	74 f6                	je     80094c <strtol+0xe>
  800956:	3c 09                	cmp    $0x9,%al
  800958:	74 f2                	je     80094c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80095a:	3c 2b                	cmp    $0x2b,%al
  80095c:	75 0a                	jne    800968 <strtol+0x2a>
		s++;
  80095e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800961:	bf 00 00 00 00       	mov    $0x0,%edi
  800966:	eb 11                	jmp    800979 <strtol+0x3b>
  800968:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80096d:	3c 2d                	cmp    $0x2d,%al
  80096f:	75 08                	jne    800979 <strtol+0x3b>
		s++, neg = 1;
  800971:	83 c1 01             	add    $0x1,%ecx
  800974:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800979:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80097f:	75 15                	jne    800996 <strtol+0x58>
  800981:	80 39 30             	cmpb   $0x30,(%ecx)
  800984:	75 10                	jne    800996 <strtol+0x58>
  800986:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80098a:	75 7c                	jne    800a08 <strtol+0xca>
		s += 2, base = 16;
  80098c:	83 c1 02             	add    $0x2,%ecx
  80098f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800994:	eb 16                	jmp    8009ac <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800996:	85 db                	test   %ebx,%ebx
  800998:	75 12                	jne    8009ac <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80099a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80099f:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a2:	75 08                	jne    8009ac <strtol+0x6e>
		s++, base = 8;
  8009a4:	83 c1 01             	add    $0x1,%ecx
  8009a7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009b4:	0f b6 11             	movzbl (%ecx),%edx
  8009b7:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009ba:	89 f3                	mov    %esi,%ebx
  8009bc:	80 fb 09             	cmp    $0x9,%bl
  8009bf:	77 08                	ja     8009c9 <strtol+0x8b>
			dig = *s - '0';
  8009c1:	0f be d2             	movsbl %dl,%edx
  8009c4:	83 ea 30             	sub    $0x30,%edx
  8009c7:	eb 22                	jmp    8009eb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009c9:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009cc:	89 f3                	mov    %esi,%ebx
  8009ce:	80 fb 19             	cmp    $0x19,%bl
  8009d1:	77 08                	ja     8009db <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009d3:	0f be d2             	movsbl %dl,%edx
  8009d6:	83 ea 57             	sub    $0x57,%edx
  8009d9:	eb 10                	jmp    8009eb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009db:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009de:	89 f3                	mov    %esi,%ebx
  8009e0:	80 fb 19             	cmp    $0x19,%bl
  8009e3:	77 16                	ja     8009fb <strtol+0xbd>
			dig = *s - 'A' + 10;
  8009e5:	0f be d2             	movsbl %dl,%edx
  8009e8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009eb:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009ee:	7d 0b                	jge    8009fb <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8009f0:	83 c1 01             	add    $0x1,%ecx
  8009f3:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009f7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8009f9:	eb b9                	jmp    8009b4 <strtol+0x76>

	if (endptr)
  8009fb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009ff:	74 0d                	je     800a0e <strtol+0xd0>
		*endptr = (char *) s;
  800a01:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a04:	89 0e                	mov    %ecx,(%esi)
  800a06:	eb 06                	jmp    800a0e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a08:	85 db                	test   %ebx,%ebx
  800a0a:	74 98                	je     8009a4 <strtol+0x66>
  800a0c:	eb 9e                	jmp    8009ac <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a0e:	89 c2                	mov    %eax,%edx
  800a10:	f7 da                	neg    %edx
  800a12:	85 ff                	test   %edi,%edi
  800a14:	0f 45 c2             	cmovne %edx,%eax
}
  800a17:	5b                   	pop    %ebx
  800a18:	5e                   	pop    %esi
  800a19:	5f                   	pop    %edi
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	57                   	push   %edi
  800a20:	56                   	push   %esi
  800a21:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a22:	b8 00 00 00 00       	mov    $0x0,%eax
  800a27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2d:	89 c3                	mov    %eax,%ebx
  800a2f:	89 c7                	mov    %eax,%edi
  800a31:	89 c6                	mov    %eax,%esi
  800a33:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a35:	5b                   	pop    %ebx
  800a36:	5e                   	pop    %esi
  800a37:	5f                   	pop    %edi
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <sys_cgetc>:

int
sys_cgetc(void)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	57                   	push   %edi
  800a3e:	56                   	push   %esi
  800a3f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a40:	ba 00 00 00 00       	mov    $0x0,%edx
  800a45:	b8 01 00 00 00       	mov    $0x1,%eax
  800a4a:	89 d1                	mov    %edx,%ecx
  800a4c:	89 d3                	mov    %edx,%ebx
  800a4e:	89 d7                	mov    %edx,%edi
  800a50:	89 d6                	mov    %edx,%esi
  800a52:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a54:	5b                   	pop    %ebx
  800a55:	5e                   	pop    %esi
  800a56:	5f                   	pop    %edi
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	57                   	push   %edi
  800a5d:	56                   	push   %esi
  800a5e:	53                   	push   %ebx
  800a5f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a62:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a67:	b8 03 00 00 00       	mov    $0x3,%eax
  800a6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6f:	89 cb                	mov    %ecx,%ebx
  800a71:	89 cf                	mov    %ecx,%edi
  800a73:	89 ce                	mov    %ecx,%esi
  800a75:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a77:	85 c0                	test   %eax,%eax
  800a79:	7e 17                	jle    800a92 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a7b:	83 ec 0c             	sub    $0xc,%esp
  800a7e:	50                   	push   %eax
  800a7f:	6a 03                	push   $0x3
  800a81:	68 c8 11 80 00       	push   $0x8011c8
  800a86:	6a 23                	push   $0x23
  800a88:	68 e5 11 80 00       	push   $0x8011e5
  800a8d:	e8 f5 01 00 00       	call   800c87 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a95:	5b                   	pop    %ebx
  800a96:	5e                   	pop    %esi
  800a97:	5f                   	pop    %edi
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	57                   	push   %edi
  800a9e:	56                   	push   %esi
  800a9f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa0:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa5:	b8 02 00 00 00       	mov    $0x2,%eax
  800aaa:	89 d1                	mov    %edx,%ecx
  800aac:	89 d3                	mov    %edx,%ebx
  800aae:	89 d7                	mov    %edx,%edi
  800ab0:	89 d6                	mov    %edx,%esi
  800ab2:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ab4:	5b                   	pop    %ebx
  800ab5:	5e                   	pop    %esi
  800ab6:	5f                   	pop    %edi
  800ab7:	5d                   	pop    %ebp
  800ab8:	c3                   	ret    

00800ab9 <sys_yield>:

void
sys_yield(void)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	57                   	push   %edi
  800abd:	56                   	push   %esi
  800abe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800abf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ac9:	89 d1                	mov    %edx,%ecx
  800acb:	89 d3                	mov    %edx,%ebx
  800acd:	89 d7                	mov    %edx,%edi
  800acf:	89 d6                	mov    %edx,%esi
  800ad1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ad3:	5b                   	pop    %ebx
  800ad4:	5e                   	pop    %esi
  800ad5:	5f                   	pop    %edi
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
  800ade:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae1:	be 00 00 00 00       	mov    $0x0,%esi
  800ae6:	b8 04 00 00 00       	mov    $0x4,%eax
  800aeb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aee:	8b 55 08             	mov    0x8(%ebp),%edx
  800af1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800af4:	89 f7                	mov    %esi,%edi
  800af6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800af8:	85 c0                	test   %eax,%eax
  800afa:	7e 17                	jle    800b13 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800afc:	83 ec 0c             	sub    $0xc,%esp
  800aff:	50                   	push   %eax
  800b00:	6a 04                	push   $0x4
  800b02:	68 c8 11 80 00       	push   $0x8011c8
  800b07:	6a 23                	push   $0x23
  800b09:	68 e5 11 80 00       	push   $0x8011e5
  800b0e:	e8 74 01 00 00       	call   800c87 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800b24:	b8 05 00 00 00       	mov    $0x5,%eax
  800b29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b32:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b35:	8b 75 18             	mov    0x18(%ebp),%esi
  800b38:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b3a:	85 c0                	test   %eax,%eax
  800b3c:	7e 17                	jle    800b55 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3e:	83 ec 0c             	sub    $0xc,%esp
  800b41:	50                   	push   %eax
  800b42:	6a 05                	push   $0x5
  800b44:	68 c8 11 80 00       	push   $0x8011c8
  800b49:	6a 23                	push   $0x23
  800b4b:	68 e5 11 80 00       	push   $0x8011e5
  800b50:	e8 32 01 00 00       	call   800c87 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
  800b63:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b66:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b6b:	b8 06 00 00 00       	mov    $0x6,%eax
  800b70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b73:	8b 55 08             	mov    0x8(%ebp),%edx
  800b76:	89 df                	mov    %ebx,%edi
  800b78:	89 de                	mov    %ebx,%esi
  800b7a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7c:	85 c0                	test   %eax,%eax
  800b7e:	7e 17                	jle    800b97 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b80:	83 ec 0c             	sub    $0xc,%esp
  800b83:	50                   	push   %eax
  800b84:	6a 06                	push   $0x6
  800b86:	68 c8 11 80 00       	push   $0x8011c8
  800b8b:	6a 23                	push   $0x23
  800b8d:	68 e5 11 80 00       	push   $0x8011e5
  800b92:	e8 f0 00 00 00       	call   800c87 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
  800ba5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bad:	b8 08 00 00 00       	mov    $0x8,%eax
  800bb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb8:	89 df                	mov    %ebx,%edi
  800bba:	89 de                	mov    %ebx,%esi
  800bbc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bbe:	85 c0                	test   %eax,%eax
  800bc0:	7e 17                	jle    800bd9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc2:	83 ec 0c             	sub    $0xc,%esp
  800bc5:	50                   	push   %eax
  800bc6:	6a 08                	push   $0x8
  800bc8:	68 c8 11 80 00       	push   $0x8011c8
  800bcd:	6a 23                	push   $0x23
  800bcf:	68 e5 11 80 00       	push   $0x8011e5
  800bd4:	e8 ae 00 00 00       	call   800c87 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
  800be7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bea:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bef:	b8 09 00 00 00       	mov    $0x9,%eax
  800bf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfa:	89 df                	mov    %ebx,%edi
  800bfc:	89 de                	mov    %ebx,%esi
  800bfe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c00:	85 c0                	test   %eax,%eax
  800c02:	7e 17                	jle    800c1b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c04:	83 ec 0c             	sub    $0xc,%esp
  800c07:	50                   	push   %eax
  800c08:	6a 09                	push   $0x9
  800c0a:	68 c8 11 80 00       	push   $0x8011c8
  800c0f:	6a 23                	push   $0x23
  800c11:	68 e5 11 80 00       	push   $0x8011e5
  800c16:	e8 6c 00 00 00       	call   800c87 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c29:	be 00 00 00 00       	mov    $0x0,%esi
  800c2e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c36:	8b 55 08             	mov    0x8(%ebp),%edx
  800c39:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c3c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c3f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c54:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	89 cb                	mov    %ecx,%ebx
  800c5e:	89 cf                	mov    %ecx,%edi
  800c60:	89 ce                	mov    %ecx,%esi
  800c62:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c64:	85 c0                	test   %eax,%eax
  800c66:	7e 17                	jle    800c7f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c68:	83 ec 0c             	sub    $0xc,%esp
  800c6b:	50                   	push   %eax
  800c6c:	6a 0c                	push   $0xc
  800c6e:	68 c8 11 80 00       	push   $0x8011c8
  800c73:	6a 23                	push   $0x23
  800c75:	68 e5 11 80 00       	push   $0x8011e5
  800c7a:	e8 08 00 00 00       	call   800c87 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800c7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800c8c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c8f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800c95:	e8 00 fe ff ff       	call   800a9a <sys_getenvid>
  800c9a:	83 ec 0c             	sub    $0xc,%esp
  800c9d:	ff 75 0c             	pushl  0xc(%ebp)
  800ca0:	ff 75 08             	pushl  0x8(%ebp)
  800ca3:	56                   	push   %esi
  800ca4:	50                   	push   %eax
  800ca5:	68 f4 11 80 00       	push   $0x8011f4
  800caa:	e8 8a f4 ff ff       	call   800139 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800caf:	83 c4 18             	add    $0x18,%esp
  800cb2:	53                   	push   %ebx
  800cb3:	ff 75 10             	pushl  0x10(%ebp)
  800cb6:	e8 2d f4 ff ff       	call   8000e8 <vcprintf>
	cprintf("\n");
  800cbb:	c7 04 24 7c 0f 80 00 	movl   $0x800f7c,(%esp)
  800cc2:	e8 72 f4 ff ff       	call   800139 <cprintf>
  800cc7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800cca:	cc                   	int3   
  800ccb:	eb fd                	jmp    800cca <_panic+0x43>
  800ccd:	66 90                	xchg   %ax,%ax
  800ccf:	90                   	nop

00800cd0 <__udivdi3>:
  800cd0:	55                   	push   %ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
  800cd4:	83 ec 1c             	sub    $0x1c,%esp
  800cd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800cdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800cdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800ce3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ce7:	85 f6                	test   %esi,%esi
  800ce9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ced:	89 ca                	mov    %ecx,%edx
  800cef:	89 f8                	mov    %edi,%eax
  800cf1:	75 3d                	jne    800d30 <__udivdi3+0x60>
  800cf3:	39 cf                	cmp    %ecx,%edi
  800cf5:	0f 87 c5 00 00 00    	ja     800dc0 <__udivdi3+0xf0>
  800cfb:	85 ff                	test   %edi,%edi
  800cfd:	89 fd                	mov    %edi,%ebp
  800cff:	75 0b                	jne    800d0c <__udivdi3+0x3c>
  800d01:	b8 01 00 00 00       	mov    $0x1,%eax
  800d06:	31 d2                	xor    %edx,%edx
  800d08:	f7 f7                	div    %edi
  800d0a:	89 c5                	mov    %eax,%ebp
  800d0c:	89 c8                	mov    %ecx,%eax
  800d0e:	31 d2                	xor    %edx,%edx
  800d10:	f7 f5                	div    %ebp
  800d12:	89 c1                	mov    %eax,%ecx
  800d14:	89 d8                	mov    %ebx,%eax
  800d16:	89 cf                	mov    %ecx,%edi
  800d18:	f7 f5                	div    %ebp
  800d1a:	89 c3                	mov    %eax,%ebx
  800d1c:	89 d8                	mov    %ebx,%eax
  800d1e:	89 fa                	mov    %edi,%edx
  800d20:	83 c4 1c             	add    $0x1c,%esp
  800d23:	5b                   	pop    %ebx
  800d24:	5e                   	pop    %esi
  800d25:	5f                   	pop    %edi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    
  800d28:	90                   	nop
  800d29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d30:	39 ce                	cmp    %ecx,%esi
  800d32:	77 74                	ja     800da8 <__udivdi3+0xd8>
  800d34:	0f bd fe             	bsr    %esi,%edi
  800d37:	83 f7 1f             	xor    $0x1f,%edi
  800d3a:	0f 84 98 00 00 00    	je     800dd8 <__udivdi3+0x108>
  800d40:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d45:	89 f9                	mov    %edi,%ecx
  800d47:	89 c5                	mov    %eax,%ebp
  800d49:	29 fb                	sub    %edi,%ebx
  800d4b:	d3 e6                	shl    %cl,%esi
  800d4d:	89 d9                	mov    %ebx,%ecx
  800d4f:	d3 ed                	shr    %cl,%ebp
  800d51:	89 f9                	mov    %edi,%ecx
  800d53:	d3 e0                	shl    %cl,%eax
  800d55:	09 ee                	or     %ebp,%esi
  800d57:	89 d9                	mov    %ebx,%ecx
  800d59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d5d:	89 d5                	mov    %edx,%ebp
  800d5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d63:	d3 ed                	shr    %cl,%ebp
  800d65:	89 f9                	mov    %edi,%ecx
  800d67:	d3 e2                	shl    %cl,%edx
  800d69:	89 d9                	mov    %ebx,%ecx
  800d6b:	d3 e8                	shr    %cl,%eax
  800d6d:	09 c2                	or     %eax,%edx
  800d6f:	89 d0                	mov    %edx,%eax
  800d71:	89 ea                	mov    %ebp,%edx
  800d73:	f7 f6                	div    %esi
  800d75:	89 d5                	mov    %edx,%ebp
  800d77:	89 c3                	mov    %eax,%ebx
  800d79:	f7 64 24 0c          	mull   0xc(%esp)
  800d7d:	39 d5                	cmp    %edx,%ebp
  800d7f:	72 10                	jb     800d91 <__udivdi3+0xc1>
  800d81:	8b 74 24 08          	mov    0x8(%esp),%esi
  800d85:	89 f9                	mov    %edi,%ecx
  800d87:	d3 e6                	shl    %cl,%esi
  800d89:	39 c6                	cmp    %eax,%esi
  800d8b:	73 07                	jae    800d94 <__udivdi3+0xc4>
  800d8d:	39 d5                	cmp    %edx,%ebp
  800d8f:	75 03                	jne    800d94 <__udivdi3+0xc4>
  800d91:	83 eb 01             	sub    $0x1,%ebx
  800d94:	31 ff                	xor    %edi,%edi
  800d96:	89 d8                	mov    %ebx,%eax
  800d98:	89 fa                	mov    %edi,%edx
  800d9a:	83 c4 1c             	add    $0x1c,%esp
  800d9d:	5b                   	pop    %ebx
  800d9e:	5e                   	pop    %esi
  800d9f:	5f                   	pop    %edi
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    
  800da2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800da8:	31 ff                	xor    %edi,%edi
  800daa:	31 db                	xor    %ebx,%ebx
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
  800dc0:	89 d8                	mov    %ebx,%eax
  800dc2:	f7 f7                	div    %edi
  800dc4:	31 ff                	xor    %edi,%edi
  800dc6:	89 c3                	mov    %eax,%ebx
  800dc8:	89 d8                	mov    %ebx,%eax
  800dca:	89 fa                	mov    %edi,%edx
  800dcc:	83 c4 1c             	add    $0x1c,%esp
  800dcf:	5b                   	pop    %ebx
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    
  800dd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800dd8:	39 ce                	cmp    %ecx,%esi
  800dda:	72 0c                	jb     800de8 <__udivdi3+0x118>
  800ddc:	31 db                	xor    %ebx,%ebx
  800dde:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800de2:	0f 87 34 ff ff ff    	ja     800d1c <__udivdi3+0x4c>
  800de8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800ded:	e9 2a ff ff ff       	jmp    800d1c <__udivdi3+0x4c>
  800df2:	66 90                	xchg   %ax,%ax
  800df4:	66 90                	xchg   %ax,%ax
  800df6:	66 90                	xchg   %ax,%ax
  800df8:	66 90                	xchg   %ax,%ax
  800dfa:	66 90                	xchg   %ax,%ax
  800dfc:	66 90                	xchg   %ax,%ax
  800dfe:	66 90                	xchg   %ax,%ax

00800e00 <__umoddi3>:
  800e00:	55                   	push   %ebp
  800e01:	57                   	push   %edi
  800e02:	56                   	push   %esi
  800e03:	53                   	push   %ebx
  800e04:	83 ec 1c             	sub    $0x1c,%esp
  800e07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e17:	85 d2                	test   %edx,%edx
  800e19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e21:	89 f3                	mov    %esi,%ebx
  800e23:	89 3c 24             	mov    %edi,(%esp)
  800e26:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e2a:	75 1c                	jne    800e48 <__umoddi3+0x48>
  800e2c:	39 f7                	cmp    %esi,%edi
  800e2e:	76 50                	jbe    800e80 <__umoddi3+0x80>
  800e30:	89 c8                	mov    %ecx,%eax
  800e32:	89 f2                	mov    %esi,%edx
  800e34:	f7 f7                	div    %edi
  800e36:	89 d0                	mov    %edx,%eax
  800e38:	31 d2                	xor    %edx,%edx
  800e3a:	83 c4 1c             	add    $0x1c,%esp
  800e3d:	5b                   	pop    %ebx
  800e3e:	5e                   	pop    %esi
  800e3f:	5f                   	pop    %edi
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    
  800e42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e48:	39 f2                	cmp    %esi,%edx
  800e4a:	89 d0                	mov    %edx,%eax
  800e4c:	77 52                	ja     800ea0 <__umoddi3+0xa0>
  800e4e:	0f bd ea             	bsr    %edx,%ebp
  800e51:	83 f5 1f             	xor    $0x1f,%ebp
  800e54:	75 5a                	jne    800eb0 <__umoddi3+0xb0>
  800e56:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800e5a:	0f 82 e0 00 00 00    	jb     800f40 <__umoddi3+0x140>
  800e60:	39 0c 24             	cmp    %ecx,(%esp)
  800e63:	0f 86 d7 00 00 00    	jbe    800f40 <__umoddi3+0x140>
  800e69:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e6d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e71:	83 c4 1c             	add    $0x1c,%esp
  800e74:	5b                   	pop    %ebx
  800e75:	5e                   	pop    %esi
  800e76:	5f                   	pop    %edi
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    
  800e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e80:	85 ff                	test   %edi,%edi
  800e82:	89 fd                	mov    %edi,%ebp
  800e84:	75 0b                	jne    800e91 <__umoddi3+0x91>
  800e86:	b8 01 00 00 00       	mov    $0x1,%eax
  800e8b:	31 d2                	xor    %edx,%edx
  800e8d:	f7 f7                	div    %edi
  800e8f:	89 c5                	mov    %eax,%ebp
  800e91:	89 f0                	mov    %esi,%eax
  800e93:	31 d2                	xor    %edx,%edx
  800e95:	f7 f5                	div    %ebp
  800e97:	89 c8                	mov    %ecx,%eax
  800e99:	f7 f5                	div    %ebp
  800e9b:	89 d0                	mov    %edx,%eax
  800e9d:	eb 99                	jmp    800e38 <__umoddi3+0x38>
  800e9f:	90                   	nop
  800ea0:	89 c8                	mov    %ecx,%eax
  800ea2:	89 f2                	mov    %esi,%edx
  800ea4:	83 c4 1c             	add    $0x1c,%esp
  800ea7:	5b                   	pop    %ebx
  800ea8:	5e                   	pop    %esi
  800ea9:	5f                   	pop    %edi
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    
  800eac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	8b 34 24             	mov    (%esp),%esi
  800eb3:	bf 20 00 00 00       	mov    $0x20,%edi
  800eb8:	89 e9                	mov    %ebp,%ecx
  800eba:	29 ef                	sub    %ebp,%edi
  800ebc:	d3 e0                	shl    %cl,%eax
  800ebe:	89 f9                	mov    %edi,%ecx
  800ec0:	89 f2                	mov    %esi,%edx
  800ec2:	d3 ea                	shr    %cl,%edx
  800ec4:	89 e9                	mov    %ebp,%ecx
  800ec6:	09 c2                	or     %eax,%edx
  800ec8:	89 d8                	mov    %ebx,%eax
  800eca:	89 14 24             	mov    %edx,(%esp)
  800ecd:	89 f2                	mov    %esi,%edx
  800ecf:	d3 e2                	shl    %cl,%edx
  800ed1:	89 f9                	mov    %edi,%ecx
  800ed3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ed7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800edb:	d3 e8                	shr    %cl,%eax
  800edd:	89 e9                	mov    %ebp,%ecx
  800edf:	89 c6                	mov    %eax,%esi
  800ee1:	d3 e3                	shl    %cl,%ebx
  800ee3:	89 f9                	mov    %edi,%ecx
  800ee5:	89 d0                	mov    %edx,%eax
  800ee7:	d3 e8                	shr    %cl,%eax
  800ee9:	89 e9                	mov    %ebp,%ecx
  800eeb:	09 d8                	or     %ebx,%eax
  800eed:	89 d3                	mov    %edx,%ebx
  800eef:	89 f2                	mov    %esi,%edx
  800ef1:	f7 34 24             	divl   (%esp)
  800ef4:	89 d6                	mov    %edx,%esi
  800ef6:	d3 e3                	shl    %cl,%ebx
  800ef8:	f7 64 24 04          	mull   0x4(%esp)
  800efc:	39 d6                	cmp    %edx,%esi
  800efe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f02:	89 d1                	mov    %edx,%ecx
  800f04:	89 c3                	mov    %eax,%ebx
  800f06:	72 08                	jb     800f10 <__umoddi3+0x110>
  800f08:	75 11                	jne    800f1b <__umoddi3+0x11b>
  800f0a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f0e:	73 0b                	jae    800f1b <__umoddi3+0x11b>
  800f10:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f14:	1b 14 24             	sbb    (%esp),%edx
  800f17:	89 d1                	mov    %edx,%ecx
  800f19:	89 c3                	mov    %eax,%ebx
  800f1b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f1f:	29 da                	sub    %ebx,%edx
  800f21:	19 ce                	sbb    %ecx,%esi
  800f23:	89 f9                	mov    %edi,%ecx
  800f25:	89 f0                	mov    %esi,%eax
  800f27:	d3 e0                	shl    %cl,%eax
  800f29:	89 e9                	mov    %ebp,%ecx
  800f2b:	d3 ea                	shr    %cl,%edx
  800f2d:	89 e9                	mov    %ebp,%ecx
  800f2f:	d3 ee                	shr    %cl,%esi
  800f31:	09 d0                	or     %edx,%eax
  800f33:	89 f2                	mov    %esi,%edx
  800f35:	83 c4 1c             	add    $0x1c,%esp
  800f38:	5b                   	pop    %ebx
  800f39:	5e                   	pop    %esi
  800f3a:	5f                   	pop    %edi
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    
  800f3d:	8d 76 00             	lea    0x0(%esi),%esi
  800f40:	29 f9                	sub    %edi,%ecx
  800f42:	19 d6                	sbb    %edx,%esi
  800f44:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f4c:	e9 18 ff ff ff       	jmp    800e69 <__umoddi3+0x69>
