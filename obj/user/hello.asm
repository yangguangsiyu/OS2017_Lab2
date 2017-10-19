
obj/user/hello：     文件格式 elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 80 0f 80 00       	push   $0x800f80
  80003e:	e8 06 01 00 00       	call   800149 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 20 80 00       	mov    0x802004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 8e 0f 80 00       	push   $0x800f8e
  800054:	e8 f0 00 00 00       	call   800149 <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800069:	e8 3c 0a 00 00       	call   800aaa <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	85 db                	test   %ebx,%ebx
  800082:	7e 07                	jle    80008b <libmain+0x2d>
		binaryname = argv[0];
  800084:	8b 06                	mov    (%esi),%eax
  800086:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	56                   	push   %esi
  80008f:	53                   	push   %ebx
  800090:	e8 9e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a0:	5b                   	pop    %ebx
  8000a1:	5e                   	pop    %esi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 b8 09 00 00       	call   800a69 <sys_env_destroy>
}
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	c9                   	leave  
  8000b5:	c3                   	ret    

008000b6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b6:	55                   	push   %ebp
  8000b7:	89 e5                	mov    %esp,%ebp
  8000b9:	53                   	push   %ebx
  8000ba:	83 ec 04             	sub    $0x4,%esp
  8000bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c0:	8b 13                	mov    (%ebx),%edx
  8000c2:	8d 42 01             	lea    0x1(%edx),%eax
  8000c5:	89 03                	mov    %eax,(%ebx)
  8000c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ca:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000ce:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d3:	75 1a                	jne    8000ef <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 ff 00 00 00       	push   $0xff
  8000dd:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e0:	50                   	push   %eax
  8000e1:	e8 46 09 00 00       	call   800a2c <sys_cputs>
		b->idx = 0;
  8000e6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ec:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000ef:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f6:	c9                   	leave  
  8000f7:	c3                   	ret    

008000f8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800101:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800108:	00 00 00 
	b.cnt = 0;
  80010b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800112:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800115:	ff 75 0c             	pushl  0xc(%ebp)
  800118:	ff 75 08             	pushl  0x8(%ebp)
  80011b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800121:	50                   	push   %eax
  800122:	68 b6 00 80 00       	push   $0x8000b6
  800127:	e8 54 01 00 00       	call   800280 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012c:	83 c4 08             	add    $0x8,%esp
  80012f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800135:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013b:	50                   	push   %eax
  80013c:	e8 eb 08 00 00       	call   800a2c <sys_cputs>

	return b.cnt;
}
  800141:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800147:	c9                   	leave  
  800148:	c3                   	ret    

00800149 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80014f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800152:	50                   	push   %eax
  800153:	ff 75 08             	pushl  0x8(%ebp)
  800156:	e8 9d ff ff ff       	call   8000f8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80015b:	c9                   	leave  
  80015c:	c3                   	ret    

0080015d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	57                   	push   %edi
  800161:	56                   	push   %esi
  800162:	53                   	push   %ebx
  800163:	83 ec 1c             	sub    $0x1c,%esp
  800166:	89 c7                	mov    %eax,%edi
  800168:	89 d6                	mov    %edx,%esi
  80016a:	8b 45 08             	mov    0x8(%ebp),%eax
  80016d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800170:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800173:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800176:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800179:	bb 00 00 00 00       	mov    $0x0,%ebx
  80017e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800181:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800184:	39 d3                	cmp    %edx,%ebx
  800186:	72 05                	jb     80018d <printnum+0x30>
  800188:	39 45 10             	cmp    %eax,0x10(%ebp)
  80018b:	77 45                	ja     8001d2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80018d:	83 ec 0c             	sub    $0xc,%esp
  800190:	ff 75 18             	pushl  0x18(%ebp)
  800193:	8b 45 14             	mov    0x14(%ebp),%eax
  800196:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800199:	53                   	push   %ebx
  80019a:	ff 75 10             	pushl  0x10(%ebp)
  80019d:	83 ec 08             	sub    $0x8,%esp
  8001a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a6:	ff 75 dc             	pushl  -0x24(%ebp)
  8001a9:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ac:	e8 2f 0b 00 00       	call   800ce0 <__udivdi3>
  8001b1:	83 c4 18             	add    $0x18,%esp
  8001b4:	52                   	push   %edx
  8001b5:	50                   	push   %eax
  8001b6:	89 f2                	mov    %esi,%edx
  8001b8:	89 f8                	mov    %edi,%eax
  8001ba:	e8 9e ff ff ff       	call   80015d <printnum>
  8001bf:	83 c4 20             	add    $0x20,%esp
  8001c2:	eb 18                	jmp    8001dc <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c4:	83 ec 08             	sub    $0x8,%esp
  8001c7:	56                   	push   %esi
  8001c8:	ff 75 18             	pushl  0x18(%ebp)
  8001cb:	ff d7                	call   *%edi
  8001cd:	83 c4 10             	add    $0x10,%esp
  8001d0:	eb 03                	jmp    8001d5 <printnum+0x78>
  8001d2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d5:	83 eb 01             	sub    $0x1,%ebx
  8001d8:	85 db                	test   %ebx,%ebx
  8001da:	7f e8                	jg     8001c4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001dc:	83 ec 08             	sub    $0x8,%esp
  8001df:	56                   	push   %esi
  8001e0:	83 ec 04             	sub    $0x4,%esp
  8001e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ef:	e8 1c 0c 00 00       	call   800e10 <__umoddi3>
  8001f4:	83 c4 14             	add    $0x14,%esp
  8001f7:	0f be 80 af 0f 80 00 	movsbl 0x800faf(%eax),%eax
  8001fe:	50                   	push   %eax
  8001ff:	ff d7                	call   *%edi
}
  800201:	83 c4 10             	add    $0x10,%esp
  800204:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800207:	5b                   	pop    %ebx
  800208:	5e                   	pop    %esi
  800209:	5f                   	pop    %edi
  80020a:	5d                   	pop    %ebp
  80020b:	c3                   	ret    

0080020c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80020f:	83 fa 01             	cmp    $0x1,%edx
  800212:	7e 0e                	jle    800222 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800214:	8b 10                	mov    (%eax),%edx
  800216:	8d 4a 08             	lea    0x8(%edx),%ecx
  800219:	89 08                	mov    %ecx,(%eax)
  80021b:	8b 02                	mov    (%edx),%eax
  80021d:	8b 52 04             	mov    0x4(%edx),%edx
  800220:	eb 22                	jmp    800244 <getuint+0x38>
	else if (lflag)
  800222:	85 d2                	test   %edx,%edx
  800224:	74 10                	je     800236 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800226:	8b 10                	mov    (%eax),%edx
  800228:	8d 4a 04             	lea    0x4(%edx),%ecx
  80022b:	89 08                	mov    %ecx,(%eax)
  80022d:	8b 02                	mov    (%edx),%eax
  80022f:	ba 00 00 00 00       	mov    $0x0,%edx
  800234:	eb 0e                	jmp    800244 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800236:	8b 10                	mov    (%eax),%edx
  800238:	8d 4a 04             	lea    0x4(%edx),%ecx
  80023b:	89 08                	mov    %ecx,(%eax)
  80023d:	8b 02                	mov    (%edx),%eax
  80023f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800244:	5d                   	pop    %ebp
  800245:	c3                   	ret    

00800246 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80024c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800250:	8b 10                	mov    (%eax),%edx
  800252:	3b 50 04             	cmp    0x4(%eax),%edx
  800255:	73 0a                	jae    800261 <sprintputch+0x1b>
		*b->buf++ = ch;
  800257:	8d 4a 01             	lea    0x1(%edx),%ecx
  80025a:	89 08                	mov    %ecx,(%eax)
  80025c:	8b 45 08             	mov    0x8(%ebp),%eax
  80025f:	88 02                	mov    %al,(%edx)
}
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800269:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80026c:	50                   	push   %eax
  80026d:	ff 75 10             	pushl  0x10(%ebp)
  800270:	ff 75 0c             	pushl  0xc(%ebp)
  800273:	ff 75 08             	pushl  0x8(%ebp)
  800276:	e8 05 00 00 00       	call   800280 <vprintfmt>
	va_end(ap);
}
  80027b:	83 c4 10             	add    $0x10,%esp
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 2c             	sub    $0x2c,%esp
  800289:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
  80028c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800293:	eb 17                	jmp    8002ac <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800295:	85 c0                	test   %eax,%eax
  800297:	0f 84 9f 03 00 00    	je     80063c <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
  80029d:	83 ec 08             	sub    $0x8,%esp
  8002a0:	ff 75 0c             	pushl  0xc(%ebp)
  8002a3:	50                   	push   %eax
  8002a4:	ff 55 08             	call   *0x8(%ebp)
  8002a7:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002aa:	89 f3                	mov    %esi,%ebx
  8002ac:	8d 73 01             	lea    0x1(%ebx),%esi
  8002af:	0f b6 03             	movzbl (%ebx),%eax
  8002b2:	83 f8 25             	cmp    $0x25,%eax
  8002b5:	75 de                	jne    800295 <vprintfmt+0x15>
  8002b7:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8002bb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002c2:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8002c7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d3:	eb 06                	jmp    8002db <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d5:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002d7:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002db:	8d 5e 01             	lea    0x1(%esi),%ebx
  8002de:	0f b6 06             	movzbl (%esi),%eax
  8002e1:	0f b6 c8             	movzbl %al,%ecx
  8002e4:	83 e8 23             	sub    $0x23,%eax
  8002e7:	3c 55                	cmp    $0x55,%al
  8002e9:	0f 87 2d 03 00 00    	ja     80061c <vprintfmt+0x39c>
  8002ef:	0f b6 c0             	movzbl %al,%eax
  8002f2:	ff 24 85 80 10 80 00 	jmp    *0x801080(,%eax,4)
  8002f9:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002fb:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8002ff:	eb da                	jmp    8002db <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800301:	89 de                	mov    %ebx,%esi
  800303:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800308:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  80030b:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  80030f:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  800312:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800315:	83 f8 09             	cmp    $0x9,%eax
  800318:	77 33                	ja     80034d <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80031a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80031d:	eb e9                	jmp    800308 <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80031f:	8b 45 14             	mov    0x14(%ebp),%eax
  800322:	8d 48 04             	lea    0x4(%eax),%ecx
  800325:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800328:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80032c:	eb 1f                	jmp    80034d <vprintfmt+0xcd>
  80032e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800331:	85 c0                	test   %eax,%eax
  800333:	b9 00 00 00 00       	mov    $0x0,%ecx
  800338:	0f 49 c8             	cmovns %eax,%ecx
  80033b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033e:	89 de                	mov    %ebx,%esi
  800340:	eb 99                	jmp    8002db <vprintfmt+0x5b>
  800342:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800344:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  80034b:	eb 8e                	jmp    8002db <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80034d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800351:	79 88                	jns    8002db <vprintfmt+0x5b>
				width = precision, precision = -1;
  800353:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800356:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80035b:	e9 7b ff ff ff       	jmp    8002db <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800360:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800363:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800365:	e9 71 ff ff ff       	jmp    8002db <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
  80036a:	8b 45 14             	mov    0x14(%ebp),%eax
  80036d:	8d 50 04             	lea    0x4(%eax),%edx
  800370:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  800373:	83 ec 08             	sub    $0x8,%esp
  800376:	ff 75 0c             	pushl  0xc(%ebp)
  800379:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80037c:	03 08                	add    (%eax),%ecx
  80037e:	51                   	push   %ecx
  80037f:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
  800382:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
  800385:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
  80038c:	e9 1b ff ff ff       	jmp    8002ac <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
  800391:	8b 45 14             	mov    0x14(%ebp),%eax
  800394:	8d 48 04             	lea    0x4(%eax),%ecx
  800397:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80039a:	8b 00                	mov    (%eax),%eax
  80039c:	83 f8 02             	cmp    $0x2,%eax
  80039f:	74 1a                	je     8003bb <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	89 de                	mov    %ebx,%esi
  8003a3:	83 f8 04             	cmp    $0x4,%eax
  8003a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ab:	b9 00 04 00 00       	mov    $0x400,%ecx
  8003b0:	0f 44 c1             	cmove  %ecx,%eax
  8003b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003b6:	e9 20 ff ff ff       	jmp    8002db <vprintfmt+0x5b>
  8003bb:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
  8003bd:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
  8003c4:	e9 12 ff ff ff       	jmp    8002db <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cc:	8d 50 04             	lea    0x4(%eax),%edx
  8003cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d2:	8b 00                	mov    (%eax),%eax
  8003d4:	99                   	cltd   
  8003d5:	31 d0                	xor    %edx,%eax
  8003d7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d9:	83 f8 09             	cmp    $0x9,%eax
  8003dc:	7f 0b                	jg     8003e9 <vprintfmt+0x169>
  8003de:	8b 14 85 e0 11 80 00 	mov    0x8011e0(,%eax,4),%edx
  8003e5:	85 d2                	test   %edx,%edx
  8003e7:	75 19                	jne    800402 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  8003e9:	50                   	push   %eax
  8003ea:	68 c7 0f 80 00       	push   $0x800fc7
  8003ef:	ff 75 0c             	pushl  0xc(%ebp)
  8003f2:	ff 75 08             	pushl  0x8(%ebp)
  8003f5:	e8 69 fe ff ff       	call   800263 <printfmt>
  8003fa:	83 c4 10             	add    $0x10,%esp
  8003fd:	e9 aa fe ff ff       	jmp    8002ac <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  800402:	52                   	push   %edx
  800403:	68 d0 0f 80 00       	push   $0x800fd0
  800408:	ff 75 0c             	pushl  0xc(%ebp)
  80040b:	ff 75 08             	pushl  0x8(%ebp)
  80040e:	e8 50 fe ff ff       	call   800263 <printfmt>
  800413:	83 c4 10             	add    $0x10,%esp
  800416:	e9 91 fe ff ff       	jmp    8002ac <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80041b:	8b 45 14             	mov    0x14(%ebp),%eax
  80041e:	8d 50 04             	lea    0x4(%eax),%edx
  800421:	89 55 14             	mov    %edx,0x14(%ebp)
  800424:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800426:	85 f6                	test   %esi,%esi
  800428:	b8 c0 0f 80 00       	mov    $0x800fc0,%eax
  80042d:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800430:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800434:	0f 8e 93 00 00 00    	jle    8004cd <vprintfmt+0x24d>
  80043a:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80043e:	0f 84 91 00 00 00    	je     8004d5 <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
  800444:	83 ec 08             	sub    $0x8,%esp
  800447:	57                   	push   %edi
  800448:	56                   	push   %esi
  800449:	e8 76 02 00 00       	call   8006c4 <strnlen>
  80044e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800451:	29 c1                	sub    %eax,%ecx
  800453:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800456:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800459:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  80045d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800460:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800463:	8b 75 0c             	mov    0xc(%ebp),%esi
  800466:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800469:	89 cb                	mov    %ecx,%ebx
  80046b:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80046d:	eb 0e                	jmp    80047d <vprintfmt+0x1fd>
					putch(padc, putdat);
  80046f:	83 ec 08             	sub    $0x8,%esp
  800472:	56                   	push   %esi
  800473:	57                   	push   %edi
  800474:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800477:	83 eb 01             	sub    $0x1,%ebx
  80047a:	83 c4 10             	add    $0x10,%esp
  80047d:	85 db                	test   %ebx,%ebx
  80047f:	7f ee                	jg     80046f <vprintfmt+0x1ef>
  800481:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800484:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800487:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80048a:	85 c9                	test   %ecx,%ecx
  80048c:	b8 00 00 00 00       	mov    $0x0,%eax
  800491:	0f 49 c1             	cmovns %ecx,%eax
  800494:	29 c1                	sub    %eax,%ecx
  800496:	89 cb                	mov    %ecx,%ebx
  800498:	eb 41                	jmp    8004db <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80049a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80049e:	74 1b                	je     8004bb <vprintfmt+0x23b>
  8004a0:	0f be c0             	movsbl %al,%eax
  8004a3:	83 e8 20             	sub    $0x20,%eax
  8004a6:	83 f8 5e             	cmp    $0x5e,%eax
  8004a9:	76 10                	jbe    8004bb <vprintfmt+0x23b>
					putch('?', putdat);
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	ff 75 0c             	pushl  0xc(%ebp)
  8004b1:	6a 3f                	push   $0x3f
  8004b3:	ff 55 08             	call   *0x8(%ebp)
  8004b6:	83 c4 10             	add    $0x10,%esp
  8004b9:	eb 0d                	jmp    8004c8 <vprintfmt+0x248>
				else
					putch(ch, putdat);
  8004bb:	83 ec 08             	sub    $0x8,%esp
  8004be:	ff 75 0c             	pushl  0xc(%ebp)
  8004c1:	52                   	push   %edx
  8004c2:	ff 55 08             	call   *0x8(%ebp)
  8004c5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c8:	83 eb 01             	sub    $0x1,%ebx
  8004cb:	eb 0e                	jmp    8004db <vprintfmt+0x25b>
  8004cd:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004d0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004d3:	eb 06                	jmp    8004db <vprintfmt+0x25b>
  8004d5:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004d8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004db:	83 c6 01             	add    $0x1,%esi
  8004de:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8004e2:	0f be d0             	movsbl %al,%edx
  8004e5:	85 d2                	test   %edx,%edx
  8004e7:	74 25                	je     80050e <vprintfmt+0x28e>
  8004e9:	85 ff                	test   %edi,%edi
  8004eb:	78 ad                	js     80049a <vprintfmt+0x21a>
  8004ed:	83 ef 01             	sub    $0x1,%edi
  8004f0:	79 a8                	jns    80049a <vprintfmt+0x21a>
  8004f2:	89 d8                	mov    %ebx,%eax
  8004f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004fa:	89 c3                	mov    %eax,%ebx
  8004fc:	eb 16                	jmp    800514 <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	57                   	push   %edi
  800502:	6a 20                	push   $0x20
  800504:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800506:	83 eb 01             	sub    $0x1,%ebx
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	eb 06                	jmp    800514 <vprintfmt+0x294>
  80050e:	8b 75 08             	mov    0x8(%ebp),%esi
  800511:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800514:	85 db                	test   %ebx,%ebx
  800516:	7f e6                	jg     8004fe <vprintfmt+0x27e>
  800518:	89 75 08             	mov    %esi,0x8(%ebp)
  80051b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80051e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800521:	e9 86 fd ff ff       	jmp    8002ac <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800526:	83 fa 01             	cmp    $0x1,%edx
  800529:	7e 10                	jle    80053b <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8d 50 08             	lea    0x8(%eax),%edx
  800531:	89 55 14             	mov    %edx,0x14(%ebp)
  800534:	8b 30                	mov    (%eax),%esi
  800536:	8b 78 04             	mov    0x4(%eax),%edi
  800539:	eb 26                	jmp    800561 <vprintfmt+0x2e1>
	else if (lflag)
  80053b:	85 d2                	test   %edx,%edx
  80053d:	74 12                	je     800551 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8d 50 04             	lea    0x4(%eax),%edx
  800545:	89 55 14             	mov    %edx,0x14(%ebp)
  800548:	8b 30                	mov    (%eax),%esi
  80054a:	89 f7                	mov    %esi,%edi
  80054c:	c1 ff 1f             	sar    $0x1f,%edi
  80054f:	eb 10                	jmp    800561 <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
  800551:	8b 45 14             	mov    0x14(%ebp),%eax
  800554:	8d 50 04             	lea    0x4(%eax),%edx
  800557:	89 55 14             	mov    %edx,0x14(%ebp)
  80055a:	8b 30                	mov    (%eax),%esi
  80055c:	89 f7                	mov    %esi,%edi
  80055e:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800561:	89 f0                	mov    %esi,%eax
  800563:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800565:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80056a:	85 ff                	test   %edi,%edi
  80056c:	79 7b                	jns    8005e9 <vprintfmt+0x369>
				putch('-', putdat);
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	ff 75 0c             	pushl  0xc(%ebp)
  800574:	6a 2d                	push   $0x2d
  800576:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800579:	89 f0                	mov    %esi,%eax
  80057b:	89 fa                	mov    %edi,%edx
  80057d:	f7 d8                	neg    %eax
  80057f:	83 d2 00             	adc    $0x0,%edx
  800582:	f7 da                	neg    %edx
  800584:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800587:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80058c:	eb 5b                	jmp    8005e9 <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80058e:	8d 45 14             	lea    0x14(%ebp),%eax
  800591:	e8 76 fc ff ff       	call   80020c <getuint>
			base = 10;
  800596:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80059b:	eb 4c                	jmp    8005e9 <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
  80059d:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a0:	e8 67 fc ff ff       	call   80020c <getuint>
            base = 8;
  8005a5:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005aa:	eb 3d                	jmp    8005e9 <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
  8005ac:	83 ec 08             	sub    $0x8,%esp
  8005af:	ff 75 0c             	pushl  0xc(%ebp)
  8005b2:	6a 30                	push   $0x30
  8005b4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005b7:	83 c4 08             	add    $0x8,%esp
  8005ba:	ff 75 0c             	pushl  0xc(%ebp)
  8005bd:	6a 78                	push   $0x78
  8005bf:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 50 04             	lea    0x4(%eax),%edx
  8005c8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005cb:	8b 00                	mov    (%eax),%eax
  8005cd:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005d2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005d5:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005da:	eb 0d                	jmp    8005e9 <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005dc:	8d 45 14             	lea    0x14(%ebp),%eax
  8005df:	e8 28 fc ff ff       	call   80020c <getuint>
			base = 16;
  8005e4:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005e9:	83 ec 0c             	sub    $0xc,%esp
  8005ec:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  8005f0:	56                   	push   %esi
  8005f1:	ff 75 e0             	pushl  -0x20(%ebp)
  8005f4:	51                   	push   %ecx
  8005f5:	52                   	push   %edx
  8005f6:	50                   	push   %eax
  8005f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8005fd:	e8 5b fb ff ff       	call   80015d <printnum>
			break;
  800602:	83 c4 20             	add    $0x20,%esp
  800605:	e9 a2 fc ff ff       	jmp    8002ac <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80060a:	83 ec 08             	sub    $0x8,%esp
  80060d:	ff 75 0c             	pushl  0xc(%ebp)
  800610:	51                   	push   %ecx
  800611:	ff 55 08             	call   *0x8(%ebp)
			break;
  800614:	83 c4 10             	add    $0x10,%esp
  800617:	e9 90 fc ff ff       	jmp    8002ac <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80061c:	83 ec 08             	sub    $0x8,%esp
  80061f:	ff 75 0c             	pushl  0xc(%ebp)
  800622:	6a 25                	push   $0x25
  800624:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800627:	83 c4 10             	add    $0x10,%esp
  80062a:	89 f3                	mov    %esi,%ebx
  80062c:	eb 03                	jmp    800631 <vprintfmt+0x3b1>
  80062e:	83 eb 01             	sub    $0x1,%ebx
  800631:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800635:	75 f7                	jne    80062e <vprintfmt+0x3ae>
  800637:	e9 70 fc ff ff       	jmp    8002ac <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  80063c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063f:	5b                   	pop    %ebx
  800640:	5e                   	pop    %esi
  800641:	5f                   	pop    %edi
  800642:	5d                   	pop    %ebp
  800643:	c3                   	ret    

00800644 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800644:	55                   	push   %ebp
  800645:	89 e5                	mov    %esp,%ebp
  800647:	83 ec 18             	sub    $0x18,%esp
  80064a:	8b 45 08             	mov    0x8(%ebp),%eax
  80064d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800650:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800653:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800657:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80065a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800661:	85 c0                	test   %eax,%eax
  800663:	74 26                	je     80068b <vsnprintf+0x47>
  800665:	85 d2                	test   %edx,%edx
  800667:	7e 22                	jle    80068b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800669:	ff 75 14             	pushl  0x14(%ebp)
  80066c:	ff 75 10             	pushl  0x10(%ebp)
  80066f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800672:	50                   	push   %eax
  800673:	68 46 02 80 00       	push   $0x800246
  800678:	e8 03 fc ff ff       	call   800280 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80067d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800680:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800683:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800686:	83 c4 10             	add    $0x10,%esp
  800689:	eb 05                	jmp    800690 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80068b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800690:	c9                   	leave  
  800691:	c3                   	ret    

00800692 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800692:	55                   	push   %ebp
  800693:	89 e5                	mov    %esp,%ebp
  800695:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800698:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80069b:	50                   	push   %eax
  80069c:	ff 75 10             	pushl  0x10(%ebp)
  80069f:	ff 75 0c             	pushl  0xc(%ebp)
  8006a2:	ff 75 08             	pushl  0x8(%ebp)
  8006a5:	e8 9a ff ff ff       	call   800644 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006aa:	c9                   	leave  
  8006ab:	c3                   	ret    

008006ac <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006ac:	55                   	push   %ebp
  8006ad:	89 e5                	mov    %esp,%ebp
  8006af:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b7:	eb 03                	jmp    8006bc <strlen+0x10>
		n++;
  8006b9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006bc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006c0:	75 f7                	jne    8006b9 <strlen+0xd>
		n++;
	return n;
}
  8006c2:	5d                   	pop    %ebp
  8006c3:	c3                   	ret    

008006c4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ca:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8006d2:	eb 03                	jmp    8006d7 <strnlen+0x13>
		n++;
  8006d4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006d7:	39 c2                	cmp    %eax,%edx
  8006d9:	74 08                	je     8006e3 <strnlen+0x1f>
  8006db:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006df:	75 f3                	jne    8006d4 <strnlen+0x10>
  8006e1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006e3:	5d                   	pop    %ebp
  8006e4:	c3                   	ret    

008006e5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006e5:	55                   	push   %ebp
  8006e6:	89 e5                	mov    %esp,%ebp
  8006e8:	53                   	push   %ebx
  8006e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006ef:	89 c2                	mov    %eax,%edx
  8006f1:	83 c2 01             	add    $0x1,%edx
  8006f4:	83 c1 01             	add    $0x1,%ecx
  8006f7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006fb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006fe:	84 db                	test   %bl,%bl
  800700:	75 ef                	jne    8006f1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800702:	5b                   	pop    %ebx
  800703:	5d                   	pop    %ebp
  800704:	c3                   	ret    

00800705 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	53                   	push   %ebx
  800709:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80070c:	53                   	push   %ebx
  80070d:	e8 9a ff ff ff       	call   8006ac <strlen>
  800712:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800715:	ff 75 0c             	pushl  0xc(%ebp)
  800718:	01 d8                	add    %ebx,%eax
  80071a:	50                   	push   %eax
  80071b:	e8 c5 ff ff ff       	call   8006e5 <strcpy>
	return dst;
}
  800720:	89 d8                	mov    %ebx,%eax
  800722:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800725:	c9                   	leave  
  800726:	c3                   	ret    

00800727 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	56                   	push   %esi
  80072b:	53                   	push   %ebx
  80072c:	8b 75 08             	mov    0x8(%ebp),%esi
  80072f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800732:	89 f3                	mov    %esi,%ebx
  800734:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800737:	89 f2                	mov    %esi,%edx
  800739:	eb 0f                	jmp    80074a <strncpy+0x23>
		*dst++ = *src;
  80073b:	83 c2 01             	add    $0x1,%edx
  80073e:	0f b6 01             	movzbl (%ecx),%eax
  800741:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800744:	80 39 01             	cmpb   $0x1,(%ecx)
  800747:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80074a:	39 da                	cmp    %ebx,%edx
  80074c:	75 ed                	jne    80073b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80074e:	89 f0                	mov    %esi,%eax
  800750:	5b                   	pop    %ebx
  800751:	5e                   	pop    %esi
  800752:	5d                   	pop    %ebp
  800753:	c3                   	ret    

00800754 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	56                   	push   %esi
  800758:	53                   	push   %ebx
  800759:	8b 75 08             	mov    0x8(%ebp),%esi
  80075c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80075f:	8b 55 10             	mov    0x10(%ebp),%edx
  800762:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800764:	85 d2                	test   %edx,%edx
  800766:	74 21                	je     800789 <strlcpy+0x35>
  800768:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80076c:	89 f2                	mov    %esi,%edx
  80076e:	eb 09                	jmp    800779 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800770:	83 c2 01             	add    $0x1,%edx
  800773:	83 c1 01             	add    $0x1,%ecx
  800776:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800779:	39 c2                	cmp    %eax,%edx
  80077b:	74 09                	je     800786 <strlcpy+0x32>
  80077d:	0f b6 19             	movzbl (%ecx),%ebx
  800780:	84 db                	test   %bl,%bl
  800782:	75 ec                	jne    800770 <strlcpy+0x1c>
  800784:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800786:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800789:	29 f0                	sub    %esi,%eax
}
  80078b:	5b                   	pop    %ebx
  80078c:	5e                   	pop    %esi
  80078d:	5d                   	pop    %ebp
  80078e:	c3                   	ret    

0080078f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800795:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800798:	eb 06                	jmp    8007a0 <strcmp+0x11>
		p++, q++;
  80079a:	83 c1 01             	add    $0x1,%ecx
  80079d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007a0:	0f b6 01             	movzbl (%ecx),%eax
  8007a3:	84 c0                	test   %al,%al
  8007a5:	74 04                	je     8007ab <strcmp+0x1c>
  8007a7:	3a 02                	cmp    (%edx),%al
  8007a9:	74 ef                	je     80079a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ab:	0f b6 c0             	movzbl %al,%eax
  8007ae:	0f b6 12             	movzbl (%edx),%edx
  8007b1:	29 d0                	sub    %edx,%eax
}
  8007b3:	5d                   	pop    %ebp
  8007b4:	c3                   	ret    

008007b5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	53                   	push   %ebx
  8007b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bf:	89 c3                	mov    %eax,%ebx
  8007c1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007c4:	eb 06                	jmp    8007cc <strncmp+0x17>
		n--, p++, q++;
  8007c6:	83 c0 01             	add    $0x1,%eax
  8007c9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007cc:	39 d8                	cmp    %ebx,%eax
  8007ce:	74 15                	je     8007e5 <strncmp+0x30>
  8007d0:	0f b6 08             	movzbl (%eax),%ecx
  8007d3:	84 c9                	test   %cl,%cl
  8007d5:	74 04                	je     8007db <strncmp+0x26>
  8007d7:	3a 0a                	cmp    (%edx),%cl
  8007d9:	74 eb                	je     8007c6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007db:	0f b6 00             	movzbl (%eax),%eax
  8007de:	0f b6 12             	movzbl (%edx),%edx
  8007e1:	29 d0                	sub    %edx,%eax
  8007e3:	eb 05                	jmp    8007ea <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007e5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007ea:	5b                   	pop    %ebx
  8007eb:	5d                   	pop    %ebp
  8007ec:	c3                   	ret    

008007ed <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007f7:	eb 07                	jmp    800800 <strchr+0x13>
		if (*s == c)
  8007f9:	38 ca                	cmp    %cl,%dl
  8007fb:	74 0f                	je     80080c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007fd:	83 c0 01             	add    $0x1,%eax
  800800:	0f b6 10             	movzbl (%eax),%edx
  800803:	84 d2                	test   %dl,%dl
  800805:	75 f2                	jne    8007f9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800807:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80080c:	5d                   	pop    %ebp
  80080d:	c3                   	ret    

0080080e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	8b 45 08             	mov    0x8(%ebp),%eax
  800814:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800818:	eb 03                	jmp    80081d <strfind+0xf>
  80081a:	83 c0 01             	add    $0x1,%eax
  80081d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800820:	38 ca                	cmp    %cl,%dl
  800822:	74 04                	je     800828 <strfind+0x1a>
  800824:	84 d2                	test   %dl,%dl
  800826:	75 f2                	jne    80081a <strfind+0xc>
			break;
	return (char *) s;
}
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	57                   	push   %edi
  80082e:	56                   	push   %esi
  80082f:	53                   	push   %ebx
  800830:	8b 7d 08             	mov    0x8(%ebp),%edi
  800833:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800836:	85 c9                	test   %ecx,%ecx
  800838:	74 36                	je     800870 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80083a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800840:	75 28                	jne    80086a <memset+0x40>
  800842:	f6 c1 03             	test   $0x3,%cl
  800845:	75 23                	jne    80086a <memset+0x40>
		c &= 0xFF;
  800847:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80084b:	89 d3                	mov    %edx,%ebx
  80084d:	c1 e3 08             	shl    $0x8,%ebx
  800850:	89 d6                	mov    %edx,%esi
  800852:	c1 e6 18             	shl    $0x18,%esi
  800855:	89 d0                	mov    %edx,%eax
  800857:	c1 e0 10             	shl    $0x10,%eax
  80085a:	09 f0                	or     %esi,%eax
  80085c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80085e:	89 d8                	mov    %ebx,%eax
  800860:	09 d0                	or     %edx,%eax
  800862:	c1 e9 02             	shr    $0x2,%ecx
  800865:	fc                   	cld    
  800866:	f3 ab                	rep stos %eax,%es:(%edi)
  800868:	eb 06                	jmp    800870 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80086a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086d:	fc                   	cld    
  80086e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800870:	89 f8                	mov    %edi,%eax
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	5f                   	pop    %edi
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	57                   	push   %edi
  80087b:	56                   	push   %esi
  80087c:	8b 45 08             	mov    0x8(%ebp),%eax
  80087f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800882:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800885:	39 c6                	cmp    %eax,%esi
  800887:	73 35                	jae    8008be <memmove+0x47>
  800889:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80088c:	39 d0                	cmp    %edx,%eax
  80088e:	73 2e                	jae    8008be <memmove+0x47>
		s += n;
		d += n;
  800890:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800893:	89 d6                	mov    %edx,%esi
  800895:	09 fe                	or     %edi,%esi
  800897:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80089d:	75 13                	jne    8008b2 <memmove+0x3b>
  80089f:	f6 c1 03             	test   $0x3,%cl
  8008a2:	75 0e                	jne    8008b2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008a4:	83 ef 04             	sub    $0x4,%edi
  8008a7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008aa:	c1 e9 02             	shr    $0x2,%ecx
  8008ad:	fd                   	std    
  8008ae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008b0:	eb 09                	jmp    8008bb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008b2:	83 ef 01             	sub    $0x1,%edi
  8008b5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008b8:	fd                   	std    
  8008b9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008bb:	fc                   	cld    
  8008bc:	eb 1d                	jmp    8008db <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008be:	89 f2                	mov    %esi,%edx
  8008c0:	09 c2                	or     %eax,%edx
  8008c2:	f6 c2 03             	test   $0x3,%dl
  8008c5:	75 0f                	jne    8008d6 <memmove+0x5f>
  8008c7:	f6 c1 03             	test   $0x3,%cl
  8008ca:	75 0a                	jne    8008d6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008cc:	c1 e9 02             	shr    $0x2,%ecx
  8008cf:	89 c7                	mov    %eax,%edi
  8008d1:	fc                   	cld    
  8008d2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d4:	eb 05                	jmp    8008db <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008d6:	89 c7                	mov    %eax,%edi
  8008d8:	fc                   	cld    
  8008d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008db:	5e                   	pop    %esi
  8008dc:	5f                   	pop    %edi
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008e2:	ff 75 10             	pushl  0x10(%ebp)
  8008e5:	ff 75 0c             	pushl  0xc(%ebp)
  8008e8:	ff 75 08             	pushl  0x8(%ebp)
  8008eb:	e8 87 ff ff ff       	call   800877 <memmove>
}
  8008f0:	c9                   	leave  
  8008f1:	c3                   	ret    

008008f2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	56                   	push   %esi
  8008f6:	53                   	push   %ebx
  8008f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fd:	89 c6                	mov    %eax,%esi
  8008ff:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800902:	eb 1a                	jmp    80091e <memcmp+0x2c>
		if (*s1 != *s2)
  800904:	0f b6 08             	movzbl (%eax),%ecx
  800907:	0f b6 1a             	movzbl (%edx),%ebx
  80090a:	38 d9                	cmp    %bl,%cl
  80090c:	74 0a                	je     800918 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80090e:	0f b6 c1             	movzbl %cl,%eax
  800911:	0f b6 db             	movzbl %bl,%ebx
  800914:	29 d8                	sub    %ebx,%eax
  800916:	eb 0f                	jmp    800927 <memcmp+0x35>
		s1++, s2++;
  800918:	83 c0 01             	add    $0x1,%eax
  80091b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80091e:	39 f0                	cmp    %esi,%eax
  800920:	75 e2                	jne    800904 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800922:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800927:	5b                   	pop    %ebx
  800928:	5e                   	pop    %esi
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	53                   	push   %ebx
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800932:	89 c1                	mov    %eax,%ecx
  800934:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800937:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80093b:	eb 0a                	jmp    800947 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80093d:	0f b6 10             	movzbl (%eax),%edx
  800940:	39 da                	cmp    %ebx,%edx
  800942:	74 07                	je     80094b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800944:	83 c0 01             	add    $0x1,%eax
  800947:	39 c8                	cmp    %ecx,%eax
  800949:	72 f2                	jb     80093d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80094b:	5b                   	pop    %ebx
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	57                   	push   %edi
  800952:	56                   	push   %esi
  800953:	53                   	push   %ebx
  800954:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800957:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80095a:	eb 03                	jmp    80095f <strtol+0x11>
		s++;
  80095c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80095f:	0f b6 01             	movzbl (%ecx),%eax
  800962:	3c 20                	cmp    $0x20,%al
  800964:	74 f6                	je     80095c <strtol+0xe>
  800966:	3c 09                	cmp    $0x9,%al
  800968:	74 f2                	je     80095c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80096a:	3c 2b                	cmp    $0x2b,%al
  80096c:	75 0a                	jne    800978 <strtol+0x2a>
		s++;
  80096e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800971:	bf 00 00 00 00       	mov    $0x0,%edi
  800976:	eb 11                	jmp    800989 <strtol+0x3b>
  800978:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80097d:	3c 2d                	cmp    $0x2d,%al
  80097f:	75 08                	jne    800989 <strtol+0x3b>
		s++, neg = 1;
  800981:	83 c1 01             	add    $0x1,%ecx
  800984:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800989:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80098f:	75 15                	jne    8009a6 <strtol+0x58>
  800991:	80 39 30             	cmpb   $0x30,(%ecx)
  800994:	75 10                	jne    8009a6 <strtol+0x58>
  800996:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80099a:	75 7c                	jne    800a18 <strtol+0xca>
		s += 2, base = 16;
  80099c:	83 c1 02             	add    $0x2,%ecx
  80099f:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009a4:	eb 16                	jmp    8009bc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009a6:	85 db                	test   %ebx,%ebx
  8009a8:	75 12                	jne    8009bc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009aa:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009af:	80 39 30             	cmpb   $0x30,(%ecx)
  8009b2:	75 08                	jne    8009bc <strtol+0x6e>
		s++, base = 8;
  8009b4:	83 c1 01             	add    $0x1,%ecx
  8009b7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009c4:	0f b6 11             	movzbl (%ecx),%edx
  8009c7:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009ca:	89 f3                	mov    %esi,%ebx
  8009cc:	80 fb 09             	cmp    $0x9,%bl
  8009cf:	77 08                	ja     8009d9 <strtol+0x8b>
			dig = *s - '0';
  8009d1:	0f be d2             	movsbl %dl,%edx
  8009d4:	83 ea 30             	sub    $0x30,%edx
  8009d7:	eb 22                	jmp    8009fb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009d9:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009dc:	89 f3                	mov    %esi,%ebx
  8009de:	80 fb 19             	cmp    $0x19,%bl
  8009e1:	77 08                	ja     8009eb <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009e3:	0f be d2             	movsbl %dl,%edx
  8009e6:	83 ea 57             	sub    $0x57,%edx
  8009e9:	eb 10                	jmp    8009fb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009eb:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009ee:	89 f3                	mov    %esi,%ebx
  8009f0:	80 fb 19             	cmp    $0x19,%bl
  8009f3:	77 16                	ja     800a0b <strtol+0xbd>
			dig = *s - 'A' + 10;
  8009f5:	0f be d2             	movsbl %dl,%edx
  8009f8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009fb:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009fe:	7d 0b                	jge    800a0b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a00:	83 c1 01             	add    $0x1,%ecx
  800a03:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a07:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a09:	eb b9                	jmp    8009c4 <strtol+0x76>

	if (endptr)
  800a0b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a0f:	74 0d                	je     800a1e <strtol+0xd0>
		*endptr = (char *) s;
  800a11:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a14:	89 0e                	mov    %ecx,(%esi)
  800a16:	eb 06                	jmp    800a1e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a18:	85 db                	test   %ebx,%ebx
  800a1a:	74 98                	je     8009b4 <strtol+0x66>
  800a1c:	eb 9e                	jmp    8009bc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a1e:	89 c2                	mov    %eax,%edx
  800a20:	f7 da                	neg    %edx
  800a22:	85 ff                	test   %edi,%edi
  800a24:	0f 45 c2             	cmovne %edx,%eax
}
  800a27:	5b                   	pop    %ebx
  800a28:	5e                   	pop    %esi
  800a29:	5f                   	pop    %edi
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	57                   	push   %edi
  800a30:	56                   	push   %esi
  800a31:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a32:	b8 00 00 00 00       	mov    $0x0,%eax
  800a37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3d:	89 c3                	mov    %eax,%ebx
  800a3f:	89 c7                	mov    %eax,%edi
  800a41:	89 c6                	mov    %eax,%esi
  800a43:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a45:	5b                   	pop    %ebx
  800a46:	5e                   	pop    %esi
  800a47:	5f                   	pop    %edi
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <sys_cgetc>:

int
sys_cgetc(void)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	57                   	push   %edi
  800a4e:	56                   	push   %esi
  800a4f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a50:	ba 00 00 00 00       	mov    $0x0,%edx
  800a55:	b8 01 00 00 00       	mov    $0x1,%eax
  800a5a:	89 d1                	mov    %edx,%ecx
  800a5c:	89 d3                	mov    %edx,%ebx
  800a5e:	89 d7                	mov    %edx,%edi
  800a60:	89 d6                	mov    %edx,%esi
  800a62:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a64:	5b                   	pop    %ebx
  800a65:	5e                   	pop    %esi
  800a66:	5f                   	pop    %edi
  800a67:	5d                   	pop    %ebp
  800a68:	c3                   	ret    

00800a69 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	57                   	push   %edi
  800a6d:	56                   	push   %esi
  800a6e:	53                   	push   %ebx
  800a6f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a72:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a77:	b8 03 00 00 00       	mov    $0x3,%eax
  800a7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7f:	89 cb                	mov    %ecx,%ebx
  800a81:	89 cf                	mov    %ecx,%edi
  800a83:	89 ce                	mov    %ecx,%esi
  800a85:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a87:	85 c0                	test   %eax,%eax
  800a89:	7e 17                	jle    800aa2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a8b:	83 ec 0c             	sub    $0xc,%esp
  800a8e:	50                   	push   %eax
  800a8f:	6a 03                	push   $0x3
  800a91:	68 08 12 80 00       	push   $0x801208
  800a96:	6a 23                	push   $0x23
  800a98:	68 25 12 80 00       	push   $0x801225
  800a9d:	e8 f5 01 00 00       	call   800c97 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aa2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5f                   	pop    %edi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	57                   	push   %edi
  800aae:	56                   	push   %esi
  800aaf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab5:	b8 02 00 00 00       	mov    $0x2,%eax
  800aba:	89 d1                	mov    %edx,%ecx
  800abc:	89 d3                	mov    %edx,%ebx
  800abe:	89 d7                	mov    %edx,%edi
  800ac0:	89 d6                	mov    %edx,%esi
  800ac2:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ac4:	5b                   	pop    %ebx
  800ac5:	5e                   	pop    %esi
  800ac6:	5f                   	pop    %edi
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <sys_yield>:

void
sys_yield(void)
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
  800acf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ad9:	89 d1                	mov    %edx,%ecx
  800adb:	89 d3                	mov    %edx,%ebx
  800add:	89 d7                	mov    %edx,%edi
  800adf:	89 d6                	mov    %edx,%esi
  800ae1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ae3:	5b                   	pop    %ebx
  800ae4:	5e                   	pop    %esi
  800ae5:	5f                   	pop    %edi
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	57                   	push   %edi
  800aec:	56                   	push   %esi
  800aed:	53                   	push   %ebx
  800aee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af1:	be 00 00 00 00       	mov    $0x0,%esi
  800af6:	b8 04 00 00 00       	mov    $0x4,%eax
  800afb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afe:	8b 55 08             	mov    0x8(%ebp),%edx
  800b01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b04:	89 f7                	mov    %esi,%edi
  800b06:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b08:	85 c0                	test   %eax,%eax
  800b0a:	7e 17                	jle    800b23 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b0c:	83 ec 0c             	sub    $0xc,%esp
  800b0f:	50                   	push   %eax
  800b10:	6a 04                	push   $0x4
  800b12:	68 08 12 80 00       	push   $0x801208
  800b17:	6a 23                	push   $0x23
  800b19:	68 25 12 80 00       	push   $0x801225
  800b1e:	e8 74 01 00 00       	call   800c97 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b26:	5b                   	pop    %ebx
  800b27:	5e                   	pop    %esi
  800b28:	5f                   	pop    %edi
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	57                   	push   %edi
  800b2f:	56                   	push   %esi
  800b30:	53                   	push   %ebx
  800b31:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b34:	b8 05 00 00 00       	mov    $0x5,%eax
  800b39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b42:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b45:	8b 75 18             	mov    0x18(%ebp),%esi
  800b48:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b4a:	85 c0                	test   %eax,%eax
  800b4c:	7e 17                	jle    800b65 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4e:	83 ec 0c             	sub    $0xc,%esp
  800b51:	50                   	push   %eax
  800b52:	6a 05                	push   $0x5
  800b54:	68 08 12 80 00       	push   $0x801208
  800b59:	6a 23                	push   $0x23
  800b5b:	68 25 12 80 00       	push   $0x801225
  800b60:	e8 32 01 00 00       	call   800c97 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5f                   	pop    %edi
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	57                   	push   %edi
  800b71:	56                   	push   %esi
  800b72:	53                   	push   %ebx
  800b73:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b7b:	b8 06 00 00 00       	mov    $0x6,%eax
  800b80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b83:	8b 55 08             	mov    0x8(%ebp),%edx
  800b86:	89 df                	mov    %ebx,%edi
  800b88:	89 de                	mov    %ebx,%esi
  800b8a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b8c:	85 c0                	test   %eax,%eax
  800b8e:	7e 17                	jle    800ba7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b90:	83 ec 0c             	sub    $0xc,%esp
  800b93:	50                   	push   %eax
  800b94:	6a 06                	push   $0x6
  800b96:	68 08 12 80 00       	push   $0x801208
  800b9b:	6a 23                	push   $0x23
  800b9d:	68 25 12 80 00       	push   $0x801225
  800ba2:	e8 f0 00 00 00       	call   800c97 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ba7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
  800bb5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bbd:	b8 08 00 00 00       	mov    $0x8,%eax
  800bc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc8:	89 df                	mov    %ebx,%edi
  800bca:	89 de                	mov    %ebx,%esi
  800bcc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bce:	85 c0                	test   %eax,%eax
  800bd0:	7e 17                	jle    800be9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd2:	83 ec 0c             	sub    $0xc,%esp
  800bd5:	50                   	push   %eax
  800bd6:	6a 08                	push   $0x8
  800bd8:	68 08 12 80 00       	push   $0x801208
  800bdd:	6a 23                	push   $0x23
  800bdf:	68 25 12 80 00       	push   $0x801225
  800be4:	e8 ae 00 00 00       	call   800c97 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800be9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
  800bf7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bff:	b8 09 00 00 00       	mov    $0x9,%eax
  800c04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c07:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0a:	89 df                	mov    %ebx,%edi
  800c0c:	89 de                	mov    %ebx,%esi
  800c0e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7e 17                	jle    800c2b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c14:	83 ec 0c             	sub    $0xc,%esp
  800c17:	50                   	push   %eax
  800c18:	6a 09                	push   $0x9
  800c1a:	68 08 12 80 00       	push   $0x801208
  800c1f:	6a 23                	push   $0x23
  800c21:	68 25 12 80 00       	push   $0x801225
  800c26:	e8 6c 00 00 00       	call   800c97 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c39:	be 00 00 00 00       	mov    $0x0,%esi
  800c3e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c46:	8b 55 08             	mov    0x8(%ebp),%edx
  800c49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c4f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
  800c5c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c64:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c69:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6c:	89 cb                	mov    %ecx,%ebx
  800c6e:	89 cf                	mov    %ecx,%edi
  800c70:	89 ce                	mov    %ecx,%esi
  800c72:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c74:	85 c0                	test   %eax,%eax
  800c76:	7e 17                	jle    800c8f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c78:	83 ec 0c             	sub    $0xc,%esp
  800c7b:	50                   	push   %eax
  800c7c:	6a 0c                	push   $0xc
  800c7e:	68 08 12 80 00       	push   $0x801208
  800c83:	6a 23                	push   $0x23
  800c85:	68 25 12 80 00       	push   $0x801225
  800c8a:	e8 08 00 00 00       	call   800c97 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800c8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	56                   	push   %esi
  800c9b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800c9c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c9f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800ca5:	e8 00 fe ff ff       	call   800aaa <sys_getenvid>
  800caa:	83 ec 0c             	sub    $0xc,%esp
  800cad:	ff 75 0c             	pushl  0xc(%ebp)
  800cb0:	ff 75 08             	pushl  0x8(%ebp)
  800cb3:	56                   	push   %esi
  800cb4:	50                   	push   %eax
  800cb5:	68 34 12 80 00       	push   $0x801234
  800cba:	e8 8a f4 ff ff       	call   800149 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800cbf:	83 c4 18             	add    $0x18,%esp
  800cc2:	53                   	push   %ebx
  800cc3:	ff 75 10             	pushl  0x10(%ebp)
  800cc6:	e8 2d f4 ff ff       	call   8000f8 <vcprintf>
	cprintf("\n");
  800ccb:	c7 04 24 8c 0f 80 00 	movl   $0x800f8c,(%esp)
  800cd2:	e8 72 f4 ff ff       	call   800149 <cprintf>
  800cd7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800cda:	cc                   	int3   
  800cdb:	eb fd                	jmp    800cda <_panic+0x43>
  800cdd:	66 90                	xchg   %ax,%ax
  800cdf:	90                   	nop

00800ce0 <__udivdi3>:
  800ce0:	55                   	push   %ebp
  800ce1:	57                   	push   %edi
  800ce2:	56                   	push   %esi
  800ce3:	53                   	push   %ebx
  800ce4:	83 ec 1c             	sub    $0x1c,%esp
  800ce7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800ceb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800cef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800cf3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800cf7:	85 f6                	test   %esi,%esi
  800cf9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800cfd:	89 ca                	mov    %ecx,%edx
  800cff:	89 f8                	mov    %edi,%eax
  800d01:	75 3d                	jne    800d40 <__udivdi3+0x60>
  800d03:	39 cf                	cmp    %ecx,%edi
  800d05:	0f 87 c5 00 00 00    	ja     800dd0 <__udivdi3+0xf0>
  800d0b:	85 ff                	test   %edi,%edi
  800d0d:	89 fd                	mov    %edi,%ebp
  800d0f:	75 0b                	jne    800d1c <__udivdi3+0x3c>
  800d11:	b8 01 00 00 00       	mov    $0x1,%eax
  800d16:	31 d2                	xor    %edx,%edx
  800d18:	f7 f7                	div    %edi
  800d1a:	89 c5                	mov    %eax,%ebp
  800d1c:	89 c8                	mov    %ecx,%eax
  800d1e:	31 d2                	xor    %edx,%edx
  800d20:	f7 f5                	div    %ebp
  800d22:	89 c1                	mov    %eax,%ecx
  800d24:	89 d8                	mov    %ebx,%eax
  800d26:	89 cf                	mov    %ecx,%edi
  800d28:	f7 f5                	div    %ebp
  800d2a:	89 c3                	mov    %eax,%ebx
  800d2c:	89 d8                	mov    %ebx,%eax
  800d2e:	89 fa                	mov    %edi,%edx
  800d30:	83 c4 1c             	add    $0x1c,%esp
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    
  800d38:	90                   	nop
  800d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d40:	39 ce                	cmp    %ecx,%esi
  800d42:	77 74                	ja     800db8 <__udivdi3+0xd8>
  800d44:	0f bd fe             	bsr    %esi,%edi
  800d47:	83 f7 1f             	xor    $0x1f,%edi
  800d4a:	0f 84 98 00 00 00    	je     800de8 <__udivdi3+0x108>
  800d50:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d55:	89 f9                	mov    %edi,%ecx
  800d57:	89 c5                	mov    %eax,%ebp
  800d59:	29 fb                	sub    %edi,%ebx
  800d5b:	d3 e6                	shl    %cl,%esi
  800d5d:	89 d9                	mov    %ebx,%ecx
  800d5f:	d3 ed                	shr    %cl,%ebp
  800d61:	89 f9                	mov    %edi,%ecx
  800d63:	d3 e0                	shl    %cl,%eax
  800d65:	09 ee                	or     %ebp,%esi
  800d67:	89 d9                	mov    %ebx,%ecx
  800d69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d6d:	89 d5                	mov    %edx,%ebp
  800d6f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d73:	d3 ed                	shr    %cl,%ebp
  800d75:	89 f9                	mov    %edi,%ecx
  800d77:	d3 e2                	shl    %cl,%edx
  800d79:	89 d9                	mov    %ebx,%ecx
  800d7b:	d3 e8                	shr    %cl,%eax
  800d7d:	09 c2                	or     %eax,%edx
  800d7f:	89 d0                	mov    %edx,%eax
  800d81:	89 ea                	mov    %ebp,%edx
  800d83:	f7 f6                	div    %esi
  800d85:	89 d5                	mov    %edx,%ebp
  800d87:	89 c3                	mov    %eax,%ebx
  800d89:	f7 64 24 0c          	mull   0xc(%esp)
  800d8d:	39 d5                	cmp    %edx,%ebp
  800d8f:	72 10                	jb     800da1 <__udivdi3+0xc1>
  800d91:	8b 74 24 08          	mov    0x8(%esp),%esi
  800d95:	89 f9                	mov    %edi,%ecx
  800d97:	d3 e6                	shl    %cl,%esi
  800d99:	39 c6                	cmp    %eax,%esi
  800d9b:	73 07                	jae    800da4 <__udivdi3+0xc4>
  800d9d:	39 d5                	cmp    %edx,%ebp
  800d9f:	75 03                	jne    800da4 <__udivdi3+0xc4>
  800da1:	83 eb 01             	sub    $0x1,%ebx
  800da4:	31 ff                	xor    %edi,%edi
  800da6:	89 d8                	mov    %ebx,%eax
  800da8:	89 fa                	mov    %edi,%edx
  800daa:	83 c4 1c             	add    $0x1c,%esp
  800dad:	5b                   	pop    %ebx
  800dae:	5e                   	pop    %esi
  800daf:	5f                   	pop    %edi
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    
  800db2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800db8:	31 ff                	xor    %edi,%edi
  800dba:	31 db                	xor    %ebx,%ebx
  800dbc:	89 d8                	mov    %ebx,%eax
  800dbe:	89 fa                	mov    %edi,%edx
  800dc0:	83 c4 1c             	add    $0x1c,%esp
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    
  800dc8:	90                   	nop
  800dc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800dd0:	89 d8                	mov    %ebx,%eax
  800dd2:	f7 f7                	div    %edi
  800dd4:	31 ff                	xor    %edi,%edi
  800dd6:	89 c3                	mov    %eax,%ebx
  800dd8:	89 d8                	mov    %ebx,%eax
  800dda:	89 fa                	mov    %edi,%edx
  800ddc:	83 c4 1c             	add    $0x1c,%esp
  800ddf:	5b                   	pop    %ebx
  800de0:	5e                   	pop    %esi
  800de1:	5f                   	pop    %edi
  800de2:	5d                   	pop    %ebp
  800de3:	c3                   	ret    
  800de4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800de8:	39 ce                	cmp    %ecx,%esi
  800dea:	72 0c                	jb     800df8 <__udivdi3+0x118>
  800dec:	31 db                	xor    %ebx,%ebx
  800dee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800df2:	0f 87 34 ff ff ff    	ja     800d2c <__udivdi3+0x4c>
  800df8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800dfd:	e9 2a ff ff ff       	jmp    800d2c <__udivdi3+0x4c>
  800e02:	66 90                	xchg   %ax,%ax
  800e04:	66 90                	xchg   %ax,%ax
  800e06:	66 90                	xchg   %ax,%ax
  800e08:	66 90                	xchg   %ax,%ax
  800e0a:	66 90                	xchg   %ax,%ax
  800e0c:	66 90                	xchg   %ax,%ax
  800e0e:	66 90                	xchg   %ax,%ax

00800e10 <__umoddi3>:
  800e10:	55                   	push   %ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
  800e14:	83 ec 1c             	sub    $0x1c,%esp
  800e17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e1b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e27:	85 d2                	test   %edx,%edx
  800e29:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e31:	89 f3                	mov    %esi,%ebx
  800e33:	89 3c 24             	mov    %edi,(%esp)
  800e36:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e3a:	75 1c                	jne    800e58 <__umoddi3+0x48>
  800e3c:	39 f7                	cmp    %esi,%edi
  800e3e:	76 50                	jbe    800e90 <__umoddi3+0x80>
  800e40:	89 c8                	mov    %ecx,%eax
  800e42:	89 f2                	mov    %esi,%edx
  800e44:	f7 f7                	div    %edi
  800e46:	89 d0                	mov    %edx,%eax
  800e48:	31 d2                	xor    %edx,%edx
  800e4a:	83 c4 1c             	add    $0x1c,%esp
  800e4d:	5b                   	pop    %ebx
  800e4e:	5e                   	pop    %esi
  800e4f:	5f                   	pop    %edi
  800e50:	5d                   	pop    %ebp
  800e51:	c3                   	ret    
  800e52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e58:	39 f2                	cmp    %esi,%edx
  800e5a:	89 d0                	mov    %edx,%eax
  800e5c:	77 52                	ja     800eb0 <__umoddi3+0xa0>
  800e5e:	0f bd ea             	bsr    %edx,%ebp
  800e61:	83 f5 1f             	xor    $0x1f,%ebp
  800e64:	75 5a                	jne    800ec0 <__umoddi3+0xb0>
  800e66:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800e6a:	0f 82 e0 00 00 00    	jb     800f50 <__umoddi3+0x140>
  800e70:	39 0c 24             	cmp    %ecx,(%esp)
  800e73:	0f 86 d7 00 00 00    	jbe    800f50 <__umoddi3+0x140>
  800e79:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e7d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e81:	83 c4 1c             	add    $0x1c,%esp
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    
  800e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e90:	85 ff                	test   %edi,%edi
  800e92:	89 fd                	mov    %edi,%ebp
  800e94:	75 0b                	jne    800ea1 <__umoddi3+0x91>
  800e96:	b8 01 00 00 00       	mov    $0x1,%eax
  800e9b:	31 d2                	xor    %edx,%edx
  800e9d:	f7 f7                	div    %edi
  800e9f:	89 c5                	mov    %eax,%ebp
  800ea1:	89 f0                	mov    %esi,%eax
  800ea3:	31 d2                	xor    %edx,%edx
  800ea5:	f7 f5                	div    %ebp
  800ea7:	89 c8                	mov    %ecx,%eax
  800ea9:	f7 f5                	div    %ebp
  800eab:	89 d0                	mov    %edx,%eax
  800ead:	eb 99                	jmp    800e48 <__umoddi3+0x38>
  800eaf:	90                   	nop
  800eb0:	89 c8                	mov    %ecx,%eax
  800eb2:	89 f2                	mov    %esi,%edx
  800eb4:	83 c4 1c             	add    $0x1c,%esp
  800eb7:	5b                   	pop    %ebx
  800eb8:	5e                   	pop    %esi
  800eb9:	5f                   	pop    %edi
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    
  800ebc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ec0:	8b 34 24             	mov    (%esp),%esi
  800ec3:	bf 20 00 00 00       	mov    $0x20,%edi
  800ec8:	89 e9                	mov    %ebp,%ecx
  800eca:	29 ef                	sub    %ebp,%edi
  800ecc:	d3 e0                	shl    %cl,%eax
  800ece:	89 f9                	mov    %edi,%ecx
  800ed0:	89 f2                	mov    %esi,%edx
  800ed2:	d3 ea                	shr    %cl,%edx
  800ed4:	89 e9                	mov    %ebp,%ecx
  800ed6:	09 c2                	or     %eax,%edx
  800ed8:	89 d8                	mov    %ebx,%eax
  800eda:	89 14 24             	mov    %edx,(%esp)
  800edd:	89 f2                	mov    %esi,%edx
  800edf:	d3 e2                	shl    %cl,%edx
  800ee1:	89 f9                	mov    %edi,%ecx
  800ee3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ee7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800eeb:	d3 e8                	shr    %cl,%eax
  800eed:	89 e9                	mov    %ebp,%ecx
  800eef:	89 c6                	mov    %eax,%esi
  800ef1:	d3 e3                	shl    %cl,%ebx
  800ef3:	89 f9                	mov    %edi,%ecx
  800ef5:	89 d0                	mov    %edx,%eax
  800ef7:	d3 e8                	shr    %cl,%eax
  800ef9:	89 e9                	mov    %ebp,%ecx
  800efb:	09 d8                	or     %ebx,%eax
  800efd:	89 d3                	mov    %edx,%ebx
  800eff:	89 f2                	mov    %esi,%edx
  800f01:	f7 34 24             	divl   (%esp)
  800f04:	89 d6                	mov    %edx,%esi
  800f06:	d3 e3                	shl    %cl,%ebx
  800f08:	f7 64 24 04          	mull   0x4(%esp)
  800f0c:	39 d6                	cmp    %edx,%esi
  800f0e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f12:	89 d1                	mov    %edx,%ecx
  800f14:	89 c3                	mov    %eax,%ebx
  800f16:	72 08                	jb     800f20 <__umoddi3+0x110>
  800f18:	75 11                	jne    800f2b <__umoddi3+0x11b>
  800f1a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f1e:	73 0b                	jae    800f2b <__umoddi3+0x11b>
  800f20:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f24:	1b 14 24             	sbb    (%esp),%edx
  800f27:	89 d1                	mov    %edx,%ecx
  800f29:	89 c3                	mov    %eax,%ebx
  800f2b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f2f:	29 da                	sub    %ebx,%edx
  800f31:	19 ce                	sbb    %ecx,%esi
  800f33:	89 f9                	mov    %edi,%ecx
  800f35:	89 f0                	mov    %esi,%eax
  800f37:	d3 e0                	shl    %cl,%eax
  800f39:	89 e9                	mov    %ebp,%ecx
  800f3b:	d3 ea                	shr    %cl,%edx
  800f3d:	89 e9                	mov    %ebp,%ecx
  800f3f:	d3 ee                	shr    %cl,%esi
  800f41:	09 d0                	or     %edx,%eax
  800f43:	89 f2                	mov    %esi,%edx
  800f45:	83 c4 1c             	add    $0x1c,%esp
  800f48:	5b                   	pop    %ebx
  800f49:	5e                   	pop    %esi
  800f4a:	5f                   	pop    %edi
  800f4b:	5d                   	pop    %ebp
  800f4c:	c3                   	ret    
  800f4d:	8d 76 00             	lea    0x0(%esi),%esi
  800f50:	29 f9                	sub    %edi,%ecx
  800f52:	19 d6                	sbb    %edx,%esi
  800f54:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f58:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f5c:	e9 18 ff ff ff       	jmp    800e79 <__umoddi3+0x69>
