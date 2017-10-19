
obj/user/divzero：     文件格式 elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 80 0f 80 00       	push   $0x800f80
  800056:	e8 f0 00 00 00       	call   80014b <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80006b:	e8 3c 0a 00 00       	call   800aac <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x2d>
		binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008d:	83 ec 08             	sub    $0x8,%esp
  800090:	56                   	push   %esi
  800091:	53                   	push   %ebx
  800092:	e8 9c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800097:	e8 0a 00 00 00       	call   8000a6 <exit>
}
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a2:	5b                   	pop    %ebx
  8000a3:	5e                   	pop    %esi
  8000a4:	5d                   	pop    %ebp
  8000a5:	c3                   	ret    

008000a6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ac:	6a 00                	push   $0x0
  8000ae:	e8 b8 09 00 00       	call   800a6b <sys_env_destroy>
}
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	53                   	push   %ebx
  8000bc:	83 ec 04             	sub    $0x4,%esp
  8000bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c2:	8b 13                	mov    (%ebx),%edx
  8000c4:	8d 42 01             	lea    0x1(%edx),%eax
  8000c7:	89 03                	mov    %eax,(%ebx)
  8000c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d5:	75 1a                	jne    8000f1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000d7:	83 ec 08             	sub    $0x8,%esp
  8000da:	68 ff 00 00 00       	push   $0xff
  8000df:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e2:	50                   	push   %eax
  8000e3:	e8 46 09 00 00       	call   800a2e <sys_cputs>
		b->idx = 0;
  8000e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ee:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    

008000fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800103:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010a:	00 00 00 
	b.cnt = 0;
  80010d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800114:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800117:	ff 75 0c             	pushl  0xc(%ebp)
  80011a:	ff 75 08             	pushl  0x8(%ebp)
  80011d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800123:	50                   	push   %eax
  800124:	68 b8 00 80 00       	push   $0x8000b8
  800129:	e8 54 01 00 00       	call   800282 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012e:	83 c4 08             	add    $0x8,%esp
  800131:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800137:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013d:	50                   	push   %eax
  80013e:	e8 eb 08 00 00       	call   800a2e <sys_cputs>

	return b.cnt;
}
  800143:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800149:	c9                   	leave  
  80014a:	c3                   	ret    

0080014b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800151:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800154:	50                   	push   %eax
  800155:	ff 75 08             	pushl  0x8(%ebp)
  800158:	e8 9d ff ff ff       	call   8000fa <vcprintf>
	va_end(ap);

	return cnt;
}
  80015d:	c9                   	leave  
  80015e:	c3                   	ret    

0080015f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	57                   	push   %edi
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	83 ec 1c             	sub    $0x1c,%esp
  800168:	89 c7                	mov    %eax,%edi
  80016a:	89 d6                	mov    %edx,%esi
  80016c:	8b 45 08             	mov    0x8(%ebp),%eax
  80016f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800172:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800175:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800178:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80017b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800180:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800183:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800186:	39 d3                	cmp    %edx,%ebx
  800188:	72 05                	jb     80018f <printnum+0x30>
  80018a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80018d:	77 45                	ja     8001d4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	ff 75 18             	pushl  0x18(%ebp)
  800195:	8b 45 14             	mov    0x14(%ebp),%eax
  800198:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80019b:	53                   	push   %ebx
  80019c:	ff 75 10             	pushl  0x10(%ebp)
  80019f:	83 ec 08             	sub    $0x8,%esp
  8001a2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a8:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ab:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ae:	e8 2d 0b 00 00       	call   800ce0 <__udivdi3>
  8001b3:	83 c4 18             	add    $0x18,%esp
  8001b6:	52                   	push   %edx
  8001b7:	50                   	push   %eax
  8001b8:	89 f2                	mov    %esi,%edx
  8001ba:	89 f8                	mov    %edi,%eax
  8001bc:	e8 9e ff ff ff       	call   80015f <printnum>
  8001c1:	83 c4 20             	add    $0x20,%esp
  8001c4:	eb 18                	jmp    8001de <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c6:	83 ec 08             	sub    $0x8,%esp
  8001c9:	56                   	push   %esi
  8001ca:	ff 75 18             	pushl  0x18(%ebp)
  8001cd:	ff d7                	call   *%edi
  8001cf:	83 c4 10             	add    $0x10,%esp
  8001d2:	eb 03                	jmp    8001d7 <printnum+0x78>
  8001d4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d7:	83 eb 01             	sub    $0x1,%ebx
  8001da:	85 db                	test   %ebx,%ebx
  8001dc:	7f e8                	jg     8001c6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001de:	83 ec 08             	sub    $0x8,%esp
  8001e1:	56                   	push   %esi
  8001e2:	83 ec 04             	sub    $0x4,%esp
  8001e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8001eb:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f1:	e8 1a 0c 00 00       	call   800e10 <__umoddi3>
  8001f6:	83 c4 14             	add    $0x14,%esp
  8001f9:	0f be 80 98 0f 80 00 	movsbl 0x800f98(%eax),%eax
  800200:	50                   	push   %eax
  800201:	ff d7                	call   *%edi
}
  800203:	83 c4 10             	add    $0x10,%esp
  800206:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800209:	5b                   	pop    %ebx
  80020a:	5e                   	pop    %esi
  80020b:	5f                   	pop    %edi
  80020c:	5d                   	pop    %ebp
  80020d:	c3                   	ret    

0080020e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80020e:	55                   	push   %ebp
  80020f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800211:	83 fa 01             	cmp    $0x1,%edx
  800214:	7e 0e                	jle    800224 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800216:	8b 10                	mov    (%eax),%edx
  800218:	8d 4a 08             	lea    0x8(%edx),%ecx
  80021b:	89 08                	mov    %ecx,(%eax)
  80021d:	8b 02                	mov    (%edx),%eax
  80021f:	8b 52 04             	mov    0x4(%edx),%edx
  800222:	eb 22                	jmp    800246 <getuint+0x38>
	else if (lflag)
  800224:	85 d2                	test   %edx,%edx
  800226:	74 10                	je     800238 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800228:	8b 10                	mov    (%eax),%edx
  80022a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80022d:	89 08                	mov    %ecx,(%eax)
  80022f:	8b 02                	mov    (%edx),%eax
  800231:	ba 00 00 00 00       	mov    $0x0,%edx
  800236:	eb 0e                	jmp    800246 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800238:	8b 10                	mov    (%eax),%edx
  80023a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80023d:	89 08                	mov    %ecx,(%eax)
  80023f:	8b 02                	mov    (%edx),%eax
  800241:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80024e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800252:	8b 10                	mov    (%eax),%edx
  800254:	3b 50 04             	cmp    0x4(%eax),%edx
  800257:	73 0a                	jae    800263 <sprintputch+0x1b>
		*b->buf++ = ch;
  800259:	8d 4a 01             	lea    0x1(%edx),%ecx
  80025c:	89 08                	mov    %ecx,(%eax)
  80025e:	8b 45 08             	mov    0x8(%ebp),%eax
  800261:	88 02                	mov    %al,(%edx)
}
  800263:	5d                   	pop    %ebp
  800264:	c3                   	ret    

00800265 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800265:	55                   	push   %ebp
  800266:	89 e5                	mov    %esp,%ebp
  800268:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80026b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80026e:	50                   	push   %eax
  80026f:	ff 75 10             	pushl  0x10(%ebp)
  800272:	ff 75 0c             	pushl  0xc(%ebp)
  800275:	ff 75 08             	pushl  0x8(%ebp)
  800278:	e8 05 00 00 00       	call   800282 <vprintfmt>
	va_end(ap);
}
  80027d:	83 c4 10             	add    $0x10,%esp
  800280:	c9                   	leave  
  800281:	c3                   	ret    

00800282 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	57                   	push   %edi
  800286:	56                   	push   %esi
  800287:	53                   	push   %ebx
  800288:	83 ec 2c             	sub    $0x2c,%esp
  80028b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
  80028e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800295:	eb 17                	jmp    8002ae <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800297:	85 c0                	test   %eax,%eax
  800299:	0f 84 9f 03 00 00    	je     80063e <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
  80029f:	83 ec 08             	sub    $0x8,%esp
  8002a2:	ff 75 0c             	pushl  0xc(%ebp)
  8002a5:	50                   	push   %eax
  8002a6:	ff 55 08             	call   *0x8(%ebp)
  8002a9:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ac:	89 f3                	mov    %esi,%ebx
  8002ae:	8d 73 01             	lea    0x1(%ebx),%esi
  8002b1:	0f b6 03             	movzbl (%ebx),%eax
  8002b4:	83 f8 25             	cmp    $0x25,%eax
  8002b7:	75 de                	jne    800297 <vprintfmt+0x15>
  8002b9:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8002bd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002c4:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8002c9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d5:	eb 06                	jmp    8002dd <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d7:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002d9:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002dd:	8d 5e 01             	lea    0x1(%esi),%ebx
  8002e0:	0f b6 06             	movzbl (%esi),%eax
  8002e3:	0f b6 c8             	movzbl %al,%ecx
  8002e6:	83 e8 23             	sub    $0x23,%eax
  8002e9:	3c 55                	cmp    $0x55,%al
  8002eb:	0f 87 2d 03 00 00    	ja     80061e <vprintfmt+0x39c>
  8002f1:	0f b6 c0             	movzbl %al,%eax
  8002f4:	ff 24 85 60 10 80 00 	jmp    *0x801060(,%eax,4)
  8002fb:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002fd:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800301:	eb da                	jmp    8002dd <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800303:	89 de                	mov    %ebx,%esi
  800305:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80030a:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  80030d:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  800311:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  800314:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800317:	83 f8 09             	cmp    $0x9,%eax
  80031a:	77 33                	ja     80034f <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80031c:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80031f:	eb e9                	jmp    80030a <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800321:	8b 45 14             	mov    0x14(%ebp),%eax
  800324:	8d 48 04             	lea    0x4(%eax),%ecx
  800327:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80032a:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032c:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80032e:	eb 1f                	jmp    80034f <vprintfmt+0xcd>
  800330:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800333:	85 c0                	test   %eax,%eax
  800335:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033a:	0f 49 c8             	cmovns %eax,%ecx
  80033d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800340:	89 de                	mov    %ebx,%esi
  800342:	eb 99                	jmp    8002dd <vprintfmt+0x5b>
  800344:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800346:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  80034d:	eb 8e                	jmp    8002dd <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80034f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800353:	79 88                	jns    8002dd <vprintfmt+0x5b>
				width = precision, precision = -1;
  800355:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800358:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80035d:	e9 7b ff ff ff       	jmp    8002dd <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800362:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800365:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800367:	e9 71 ff ff ff       	jmp    8002dd <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
  80036c:	8b 45 14             	mov    0x14(%ebp),%eax
  80036f:	8d 50 04             	lea    0x4(%eax),%edx
  800372:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  800375:	83 ec 08             	sub    $0x8,%esp
  800378:	ff 75 0c             	pushl  0xc(%ebp)
  80037b:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80037e:	03 08                	add    (%eax),%ecx
  800380:	51                   	push   %ecx
  800381:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
  800384:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
  800387:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
  80038e:	e9 1b ff ff ff       	jmp    8002ae <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
  800393:	8b 45 14             	mov    0x14(%ebp),%eax
  800396:	8d 48 04             	lea    0x4(%eax),%ecx
  800399:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80039c:	8b 00                	mov    (%eax),%eax
  80039e:	83 f8 02             	cmp    $0x2,%eax
  8003a1:	74 1a                	je     8003bd <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a3:	89 de                	mov    %ebx,%esi
  8003a5:	83 f8 04             	cmp    $0x4,%eax
  8003a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ad:	b9 00 04 00 00       	mov    $0x400,%ecx
  8003b2:	0f 44 c1             	cmove  %ecx,%eax
  8003b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003b8:	e9 20 ff ff ff       	jmp    8002dd <vprintfmt+0x5b>
  8003bd:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
  8003bf:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
  8003c6:	e9 12 ff ff ff       	jmp    8002dd <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ce:	8d 50 04             	lea    0x4(%eax),%edx
  8003d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d4:	8b 00                	mov    (%eax),%eax
  8003d6:	99                   	cltd   
  8003d7:	31 d0                	xor    %edx,%eax
  8003d9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003db:	83 f8 09             	cmp    $0x9,%eax
  8003de:	7f 0b                	jg     8003eb <vprintfmt+0x169>
  8003e0:	8b 14 85 c0 11 80 00 	mov    0x8011c0(,%eax,4),%edx
  8003e7:	85 d2                	test   %edx,%edx
  8003e9:	75 19                	jne    800404 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  8003eb:	50                   	push   %eax
  8003ec:	68 b0 0f 80 00       	push   $0x800fb0
  8003f1:	ff 75 0c             	pushl  0xc(%ebp)
  8003f4:	ff 75 08             	pushl  0x8(%ebp)
  8003f7:	e8 69 fe ff ff       	call   800265 <printfmt>
  8003fc:	83 c4 10             	add    $0x10,%esp
  8003ff:	e9 aa fe ff ff       	jmp    8002ae <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  800404:	52                   	push   %edx
  800405:	68 b9 0f 80 00       	push   $0x800fb9
  80040a:	ff 75 0c             	pushl  0xc(%ebp)
  80040d:	ff 75 08             	pushl  0x8(%ebp)
  800410:	e8 50 fe ff ff       	call   800265 <printfmt>
  800415:	83 c4 10             	add    $0x10,%esp
  800418:	e9 91 fe ff ff       	jmp    8002ae <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80041d:	8b 45 14             	mov    0x14(%ebp),%eax
  800420:	8d 50 04             	lea    0x4(%eax),%edx
  800423:	89 55 14             	mov    %edx,0x14(%ebp)
  800426:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800428:	85 f6                	test   %esi,%esi
  80042a:	b8 a9 0f 80 00       	mov    $0x800fa9,%eax
  80042f:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800432:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800436:	0f 8e 93 00 00 00    	jle    8004cf <vprintfmt+0x24d>
  80043c:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800440:	0f 84 91 00 00 00    	je     8004d7 <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
  800446:	83 ec 08             	sub    $0x8,%esp
  800449:	57                   	push   %edi
  80044a:	56                   	push   %esi
  80044b:	e8 76 02 00 00       	call   8006c6 <strnlen>
  800450:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800453:	29 c1                	sub    %eax,%ecx
  800455:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800458:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80045b:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  80045f:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800462:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800465:	8b 75 0c             	mov    0xc(%ebp),%esi
  800468:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80046b:	89 cb                	mov    %ecx,%ebx
  80046d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80046f:	eb 0e                	jmp    80047f <vprintfmt+0x1fd>
					putch(padc, putdat);
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	56                   	push   %esi
  800475:	57                   	push   %edi
  800476:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800479:	83 eb 01             	sub    $0x1,%ebx
  80047c:	83 c4 10             	add    $0x10,%esp
  80047f:	85 db                	test   %ebx,%ebx
  800481:	7f ee                	jg     800471 <vprintfmt+0x1ef>
  800483:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800486:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800489:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80048c:	85 c9                	test   %ecx,%ecx
  80048e:	b8 00 00 00 00       	mov    $0x0,%eax
  800493:	0f 49 c1             	cmovns %ecx,%eax
  800496:	29 c1                	sub    %eax,%ecx
  800498:	89 cb                	mov    %ecx,%ebx
  80049a:	eb 41                	jmp    8004dd <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80049c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004a0:	74 1b                	je     8004bd <vprintfmt+0x23b>
  8004a2:	0f be c0             	movsbl %al,%eax
  8004a5:	83 e8 20             	sub    $0x20,%eax
  8004a8:	83 f8 5e             	cmp    $0x5e,%eax
  8004ab:	76 10                	jbe    8004bd <vprintfmt+0x23b>
					putch('?', putdat);
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	ff 75 0c             	pushl  0xc(%ebp)
  8004b3:	6a 3f                	push   $0x3f
  8004b5:	ff 55 08             	call   *0x8(%ebp)
  8004b8:	83 c4 10             	add    $0x10,%esp
  8004bb:	eb 0d                	jmp    8004ca <vprintfmt+0x248>
				else
					putch(ch, putdat);
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	ff 75 0c             	pushl  0xc(%ebp)
  8004c3:	52                   	push   %edx
  8004c4:	ff 55 08             	call   *0x8(%ebp)
  8004c7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ca:	83 eb 01             	sub    $0x1,%ebx
  8004cd:	eb 0e                	jmp    8004dd <vprintfmt+0x25b>
  8004cf:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004d2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004d5:	eb 06                	jmp    8004dd <vprintfmt+0x25b>
  8004d7:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004da:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004dd:	83 c6 01             	add    $0x1,%esi
  8004e0:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8004e4:	0f be d0             	movsbl %al,%edx
  8004e7:	85 d2                	test   %edx,%edx
  8004e9:	74 25                	je     800510 <vprintfmt+0x28e>
  8004eb:	85 ff                	test   %edi,%edi
  8004ed:	78 ad                	js     80049c <vprintfmt+0x21a>
  8004ef:	83 ef 01             	sub    $0x1,%edi
  8004f2:	79 a8                	jns    80049c <vprintfmt+0x21a>
  8004f4:	89 d8                	mov    %ebx,%eax
  8004f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004fc:	89 c3                	mov    %eax,%ebx
  8004fe:	eb 16                	jmp    800516 <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	57                   	push   %edi
  800504:	6a 20                	push   $0x20
  800506:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800508:	83 eb 01             	sub    $0x1,%ebx
  80050b:	83 c4 10             	add    $0x10,%esp
  80050e:	eb 06                	jmp    800516 <vprintfmt+0x294>
  800510:	8b 75 08             	mov    0x8(%ebp),%esi
  800513:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800516:	85 db                	test   %ebx,%ebx
  800518:	7f e6                	jg     800500 <vprintfmt+0x27e>
  80051a:	89 75 08             	mov    %esi,0x8(%ebp)
  80051d:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800520:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800523:	e9 86 fd ff ff       	jmp    8002ae <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800528:	83 fa 01             	cmp    $0x1,%edx
  80052b:	7e 10                	jle    80053d <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
  80052d:	8b 45 14             	mov    0x14(%ebp),%eax
  800530:	8d 50 08             	lea    0x8(%eax),%edx
  800533:	89 55 14             	mov    %edx,0x14(%ebp)
  800536:	8b 30                	mov    (%eax),%esi
  800538:	8b 78 04             	mov    0x4(%eax),%edi
  80053b:	eb 26                	jmp    800563 <vprintfmt+0x2e1>
	else if (lflag)
  80053d:	85 d2                	test   %edx,%edx
  80053f:	74 12                	je     800553 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  800541:	8b 45 14             	mov    0x14(%ebp),%eax
  800544:	8d 50 04             	lea    0x4(%eax),%edx
  800547:	89 55 14             	mov    %edx,0x14(%ebp)
  80054a:	8b 30                	mov    (%eax),%esi
  80054c:	89 f7                	mov    %esi,%edi
  80054e:	c1 ff 1f             	sar    $0x1f,%edi
  800551:	eb 10                	jmp    800563 <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
  800553:	8b 45 14             	mov    0x14(%ebp),%eax
  800556:	8d 50 04             	lea    0x4(%eax),%edx
  800559:	89 55 14             	mov    %edx,0x14(%ebp)
  80055c:	8b 30                	mov    (%eax),%esi
  80055e:	89 f7                	mov    %esi,%edi
  800560:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800563:	89 f0                	mov    %esi,%eax
  800565:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800567:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80056c:	85 ff                	test   %edi,%edi
  80056e:	79 7b                	jns    8005eb <vprintfmt+0x369>
				putch('-', putdat);
  800570:	83 ec 08             	sub    $0x8,%esp
  800573:	ff 75 0c             	pushl  0xc(%ebp)
  800576:	6a 2d                	push   $0x2d
  800578:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80057b:	89 f0                	mov    %esi,%eax
  80057d:	89 fa                	mov    %edi,%edx
  80057f:	f7 d8                	neg    %eax
  800581:	83 d2 00             	adc    $0x0,%edx
  800584:	f7 da                	neg    %edx
  800586:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800589:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80058e:	eb 5b                	jmp    8005eb <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800590:	8d 45 14             	lea    0x14(%ebp),%eax
  800593:	e8 76 fc ff ff       	call   80020e <getuint>
			base = 10;
  800598:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80059d:	eb 4c                	jmp    8005eb <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
  80059f:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a2:	e8 67 fc ff ff       	call   80020e <getuint>
            base = 8;
  8005a7:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005ac:	eb 3d                	jmp    8005eb <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
  8005ae:	83 ec 08             	sub    $0x8,%esp
  8005b1:	ff 75 0c             	pushl  0xc(%ebp)
  8005b4:	6a 30                	push   $0x30
  8005b6:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005b9:	83 c4 08             	add    $0x8,%esp
  8005bc:	ff 75 0c             	pushl  0xc(%ebp)
  8005bf:	6a 78                	push   $0x78
  8005c1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ca:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005cd:	8b 00                	mov    (%eax),%eax
  8005cf:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005d4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005d7:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005dc:	eb 0d                	jmp    8005eb <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005de:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e1:	e8 28 fc ff ff       	call   80020e <getuint>
			base = 16;
  8005e6:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005eb:	83 ec 0c             	sub    $0xc,%esp
  8005ee:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  8005f2:	56                   	push   %esi
  8005f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8005f6:	51                   	push   %ecx
  8005f7:	52                   	push   %edx
  8005f8:	50                   	push   %eax
  8005f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ff:	e8 5b fb ff ff       	call   80015f <printnum>
			break;
  800604:	83 c4 20             	add    $0x20,%esp
  800607:	e9 a2 fc ff ff       	jmp    8002ae <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80060c:	83 ec 08             	sub    $0x8,%esp
  80060f:	ff 75 0c             	pushl  0xc(%ebp)
  800612:	51                   	push   %ecx
  800613:	ff 55 08             	call   *0x8(%ebp)
			break;
  800616:	83 c4 10             	add    $0x10,%esp
  800619:	e9 90 fc ff ff       	jmp    8002ae <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80061e:	83 ec 08             	sub    $0x8,%esp
  800621:	ff 75 0c             	pushl  0xc(%ebp)
  800624:	6a 25                	push   $0x25
  800626:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800629:	83 c4 10             	add    $0x10,%esp
  80062c:	89 f3                	mov    %esi,%ebx
  80062e:	eb 03                	jmp    800633 <vprintfmt+0x3b1>
  800630:	83 eb 01             	sub    $0x1,%ebx
  800633:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800637:	75 f7                	jne    800630 <vprintfmt+0x3ae>
  800639:	e9 70 fc ff ff       	jmp    8002ae <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  80063e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800641:	5b                   	pop    %ebx
  800642:	5e                   	pop    %esi
  800643:	5f                   	pop    %edi
  800644:	5d                   	pop    %ebp
  800645:	c3                   	ret    

00800646 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800646:	55                   	push   %ebp
  800647:	89 e5                	mov    %esp,%ebp
  800649:	83 ec 18             	sub    $0x18,%esp
  80064c:	8b 45 08             	mov    0x8(%ebp),%eax
  80064f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800652:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800655:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800659:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80065c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800663:	85 c0                	test   %eax,%eax
  800665:	74 26                	je     80068d <vsnprintf+0x47>
  800667:	85 d2                	test   %edx,%edx
  800669:	7e 22                	jle    80068d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80066b:	ff 75 14             	pushl  0x14(%ebp)
  80066e:	ff 75 10             	pushl  0x10(%ebp)
  800671:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800674:	50                   	push   %eax
  800675:	68 48 02 80 00       	push   $0x800248
  80067a:	e8 03 fc ff ff       	call   800282 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80067f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800682:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800685:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800688:	83 c4 10             	add    $0x10,%esp
  80068b:	eb 05                	jmp    800692 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80068d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800692:	c9                   	leave  
  800693:	c3                   	ret    

00800694 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800694:	55                   	push   %ebp
  800695:	89 e5                	mov    %esp,%ebp
  800697:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80069a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80069d:	50                   	push   %eax
  80069e:	ff 75 10             	pushl  0x10(%ebp)
  8006a1:	ff 75 0c             	pushl  0xc(%ebp)
  8006a4:	ff 75 08             	pushl  0x8(%ebp)
  8006a7:	e8 9a ff ff ff       	call   800646 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006ac:	c9                   	leave  
  8006ad:	c3                   	ret    

008006ae <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006ae:	55                   	push   %ebp
  8006af:	89 e5                	mov    %esp,%ebp
  8006b1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b9:	eb 03                	jmp    8006be <strlen+0x10>
		n++;
  8006bb:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006be:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006c2:	75 f7                	jne    8006bb <strlen+0xd>
		n++;
	return n;
}
  8006c4:	5d                   	pop    %ebp
  8006c5:	c3                   	ret    

008006c6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006c6:	55                   	push   %ebp
  8006c7:	89 e5                	mov    %esp,%ebp
  8006c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8006d4:	eb 03                	jmp    8006d9 <strnlen+0x13>
		n++;
  8006d6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006d9:	39 c2                	cmp    %eax,%edx
  8006db:	74 08                	je     8006e5 <strnlen+0x1f>
  8006dd:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006e1:	75 f3                	jne    8006d6 <strnlen+0x10>
  8006e3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006e5:	5d                   	pop    %ebp
  8006e6:	c3                   	ret    

008006e7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006e7:	55                   	push   %ebp
  8006e8:	89 e5                	mov    %esp,%ebp
  8006ea:	53                   	push   %ebx
  8006eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006f1:	89 c2                	mov    %eax,%edx
  8006f3:	83 c2 01             	add    $0x1,%edx
  8006f6:	83 c1 01             	add    $0x1,%ecx
  8006f9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006fd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800700:	84 db                	test   %bl,%bl
  800702:	75 ef                	jne    8006f3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800704:	5b                   	pop    %ebx
  800705:	5d                   	pop    %ebp
  800706:	c3                   	ret    

00800707 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	53                   	push   %ebx
  80070b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80070e:	53                   	push   %ebx
  80070f:	e8 9a ff ff ff       	call   8006ae <strlen>
  800714:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800717:	ff 75 0c             	pushl  0xc(%ebp)
  80071a:	01 d8                	add    %ebx,%eax
  80071c:	50                   	push   %eax
  80071d:	e8 c5 ff ff ff       	call   8006e7 <strcpy>
	return dst;
}
  800722:	89 d8                	mov    %ebx,%eax
  800724:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800727:	c9                   	leave  
  800728:	c3                   	ret    

00800729 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800729:	55                   	push   %ebp
  80072a:	89 e5                	mov    %esp,%ebp
  80072c:	56                   	push   %esi
  80072d:	53                   	push   %ebx
  80072e:	8b 75 08             	mov    0x8(%ebp),%esi
  800731:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800734:	89 f3                	mov    %esi,%ebx
  800736:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800739:	89 f2                	mov    %esi,%edx
  80073b:	eb 0f                	jmp    80074c <strncpy+0x23>
		*dst++ = *src;
  80073d:	83 c2 01             	add    $0x1,%edx
  800740:	0f b6 01             	movzbl (%ecx),%eax
  800743:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800746:	80 39 01             	cmpb   $0x1,(%ecx)
  800749:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80074c:	39 da                	cmp    %ebx,%edx
  80074e:	75 ed                	jne    80073d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800750:	89 f0                	mov    %esi,%eax
  800752:	5b                   	pop    %ebx
  800753:	5e                   	pop    %esi
  800754:	5d                   	pop    %ebp
  800755:	c3                   	ret    

00800756 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	56                   	push   %esi
  80075a:	53                   	push   %ebx
  80075b:	8b 75 08             	mov    0x8(%ebp),%esi
  80075e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800761:	8b 55 10             	mov    0x10(%ebp),%edx
  800764:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800766:	85 d2                	test   %edx,%edx
  800768:	74 21                	je     80078b <strlcpy+0x35>
  80076a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80076e:	89 f2                	mov    %esi,%edx
  800770:	eb 09                	jmp    80077b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800772:	83 c2 01             	add    $0x1,%edx
  800775:	83 c1 01             	add    $0x1,%ecx
  800778:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80077b:	39 c2                	cmp    %eax,%edx
  80077d:	74 09                	je     800788 <strlcpy+0x32>
  80077f:	0f b6 19             	movzbl (%ecx),%ebx
  800782:	84 db                	test   %bl,%bl
  800784:	75 ec                	jne    800772 <strlcpy+0x1c>
  800786:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800788:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80078b:	29 f0                	sub    %esi,%eax
}
  80078d:	5b                   	pop    %ebx
  80078e:	5e                   	pop    %esi
  80078f:	5d                   	pop    %ebp
  800790:	c3                   	ret    

00800791 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800797:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80079a:	eb 06                	jmp    8007a2 <strcmp+0x11>
		p++, q++;
  80079c:	83 c1 01             	add    $0x1,%ecx
  80079f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007a2:	0f b6 01             	movzbl (%ecx),%eax
  8007a5:	84 c0                	test   %al,%al
  8007a7:	74 04                	je     8007ad <strcmp+0x1c>
  8007a9:	3a 02                	cmp    (%edx),%al
  8007ab:	74 ef                	je     80079c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ad:	0f b6 c0             	movzbl %al,%eax
  8007b0:	0f b6 12             	movzbl (%edx),%edx
  8007b3:	29 d0                	sub    %edx,%eax
}
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	53                   	push   %ebx
  8007bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c1:	89 c3                	mov    %eax,%ebx
  8007c3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007c6:	eb 06                	jmp    8007ce <strncmp+0x17>
		n--, p++, q++;
  8007c8:	83 c0 01             	add    $0x1,%eax
  8007cb:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007ce:	39 d8                	cmp    %ebx,%eax
  8007d0:	74 15                	je     8007e7 <strncmp+0x30>
  8007d2:	0f b6 08             	movzbl (%eax),%ecx
  8007d5:	84 c9                	test   %cl,%cl
  8007d7:	74 04                	je     8007dd <strncmp+0x26>
  8007d9:	3a 0a                	cmp    (%edx),%cl
  8007db:	74 eb                	je     8007c8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007dd:	0f b6 00             	movzbl (%eax),%eax
  8007e0:	0f b6 12             	movzbl (%edx),%edx
  8007e3:	29 d0                	sub    %edx,%eax
  8007e5:	eb 05                	jmp    8007ec <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007e7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007ec:	5b                   	pop    %ebx
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007f9:	eb 07                	jmp    800802 <strchr+0x13>
		if (*s == c)
  8007fb:	38 ca                	cmp    %cl,%dl
  8007fd:	74 0f                	je     80080e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007ff:	83 c0 01             	add    $0x1,%eax
  800802:	0f b6 10             	movzbl (%eax),%edx
  800805:	84 d2                	test   %dl,%dl
  800807:	75 f2                	jne    8007fb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800809:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80080e:	5d                   	pop    %ebp
  80080f:	c3                   	ret    

00800810 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80081a:	eb 03                	jmp    80081f <strfind+0xf>
  80081c:	83 c0 01             	add    $0x1,%eax
  80081f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800822:	38 ca                	cmp    %cl,%dl
  800824:	74 04                	je     80082a <strfind+0x1a>
  800826:	84 d2                	test   %dl,%dl
  800828:	75 f2                	jne    80081c <strfind+0xc>
			break;
	return (char *) s;
}
  80082a:	5d                   	pop    %ebp
  80082b:	c3                   	ret    

0080082c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	57                   	push   %edi
  800830:	56                   	push   %esi
  800831:	53                   	push   %ebx
  800832:	8b 7d 08             	mov    0x8(%ebp),%edi
  800835:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800838:	85 c9                	test   %ecx,%ecx
  80083a:	74 36                	je     800872 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80083c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800842:	75 28                	jne    80086c <memset+0x40>
  800844:	f6 c1 03             	test   $0x3,%cl
  800847:	75 23                	jne    80086c <memset+0x40>
		c &= 0xFF;
  800849:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80084d:	89 d3                	mov    %edx,%ebx
  80084f:	c1 e3 08             	shl    $0x8,%ebx
  800852:	89 d6                	mov    %edx,%esi
  800854:	c1 e6 18             	shl    $0x18,%esi
  800857:	89 d0                	mov    %edx,%eax
  800859:	c1 e0 10             	shl    $0x10,%eax
  80085c:	09 f0                	or     %esi,%eax
  80085e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800860:	89 d8                	mov    %ebx,%eax
  800862:	09 d0                	or     %edx,%eax
  800864:	c1 e9 02             	shr    $0x2,%ecx
  800867:	fc                   	cld    
  800868:	f3 ab                	rep stos %eax,%es:(%edi)
  80086a:	eb 06                	jmp    800872 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80086c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086f:	fc                   	cld    
  800870:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800872:	89 f8                	mov    %edi,%eax
  800874:	5b                   	pop    %ebx
  800875:	5e                   	pop    %esi
  800876:	5f                   	pop    %edi
  800877:	5d                   	pop    %ebp
  800878:	c3                   	ret    

00800879 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	57                   	push   %edi
  80087d:	56                   	push   %esi
  80087e:	8b 45 08             	mov    0x8(%ebp),%eax
  800881:	8b 75 0c             	mov    0xc(%ebp),%esi
  800884:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800887:	39 c6                	cmp    %eax,%esi
  800889:	73 35                	jae    8008c0 <memmove+0x47>
  80088b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80088e:	39 d0                	cmp    %edx,%eax
  800890:	73 2e                	jae    8008c0 <memmove+0x47>
		s += n;
		d += n;
  800892:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800895:	89 d6                	mov    %edx,%esi
  800897:	09 fe                	or     %edi,%esi
  800899:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80089f:	75 13                	jne    8008b4 <memmove+0x3b>
  8008a1:	f6 c1 03             	test   $0x3,%cl
  8008a4:	75 0e                	jne    8008b4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008a6:	83 ef 04             	sub    $0x4,%edi
  8008a9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008ac:	c1 e9 02             	shr    $0x2,%ecx
  8008af:	fd                   	std    
  8008b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008b2:	eb 09                	jmp    8008bd <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008b4:	83 ef 01             	sub    $0x1,%edi
  8008b7:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008ba:	fd                   	std    
  8008bb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008bd:	fc                   	cld    
  8008be:	eb 1d                	jmp    8008dd <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c0:	89 f2                	mov    %esi,%edx
  8008c2:	09 c2                	or     %eax,%edx
  8008c4:	f6 c2 03             	test   $0x3,%dl
  8008c7:	75 0f                	jne    8008d8 <memmove+0x5f>
  8008c9:	f6 c1 03             	test   $0x3,%cl
  8008cc:	75 0a                	jne    8008d8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008ce:	c1 e9 02             	shr    $0x2,%ecx
  8008d1:	89 c7                	mov    %eax,%edi
  8008d3:	fc                   	cld    
  8008d4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d6:	eb 05                	jmp    8008dd <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008d8:	89 c7                	mov    %eax,%edi
  8008da:	fc                   	cld    
  8008db:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008dd:	5e                   	pop    %esi
  8008de:	5f                   	pop    %edi
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008e4:	ff 75 10             	pushl  0x10(%ebp)
  8008e7:	ff 75 0c             	pushl  0xc(%ebp)
  8008ea:	ff 75 08             	pushl  0x8(%ebp)
  8008ed:	e8 87 ff ff ff       	call   800879 <memmove>
}
  8008f2:	c9                   	leave  
  8008f3:	c3                   	ret    

008008f4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	56                   	push   %esi
  8008f8:	53                   	push   %ebx
  8008f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ff:	89 c6                	mov    %eax,%esi
  800901:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800904:	eb 1a                	jmp    800920 <memcmp+0x2c>
		if (*s1 != *s2)
  800906:	0f b6 08             	movzbl (%eax),%ecx
  800909:	0f b6 1a             	movzbl (%edx),%ebx
  80090c:	38 d9                	cmp    %bl,%cl
  80090e:	74 0a                	je     80091a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800910:	0f b6 c1             	movzbl %cl,%eax
  800913:	0f b6 db             	movzbl %bl,%ebx
  800916:	29 d8                	sub    %ebx,%eax
  800918:	eb 0f                	jmp    800929 <memcmp+0x35>
		s1++, s2++;
  80091a:	83 c0 01             	add    $0x1,%eax
  80091d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800920:	39 f0                	cmp    %esi,%eax
  800922:	75 e2                	jne    800906 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800924:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800929:	5b                   	pop    %ebx
  80092a:	5e                   	pop    %esi
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	53                   	push   %ebx
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800934:	89 c1                	mov    %eax,%ecx
  800936:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800939:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80093d:	eb 0a                	jmp    800949 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80093f:	0f b6 10             	movzbl (%eax),%edx
  800942:	39 da                	cmp    %ebx,%edx
  800944:	74 07                	je     80094d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800946:	83 c0 01             	add    $0x1,%eax
  800949:	39 c8                	cmp    %ecx,%eax
  80094b:	72 f2                	jb     80093f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80094d:	5b                   	pop    %ebx
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	57                   	push   %edi
  800954:	56                   	push   %esi
  800955:	53                   	push   %ebx
  800956:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800959:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80095c:	eb 03                	jmp    800961 <strtol+0x11>
		s++;
  80095e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800961:	0f b6 01             	movzbl (%ecx),%eax
  800964:	3c 20                	cmp    $0x20,%al
  800966:	74 f6                	je     80095e <strtol+0xe>
  800968:	3c 09                	cmp    $0x9,%al
  80096a:	74 f2                	je     80095e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80096c:	3c 2b                	cmp    $0x2b,%al
  80096e:	75 0a                	jne    80097a <strtol+0x2a>
		s++;
  800970:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800973:	bf 00 00 00 00       	mov    $0x0,%edi
  800978:	eb 11                	jmp    80098b <strtol+0x3b>
  80097a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80097f:	3c 2d                	cmp    $0x2d,%al
  800981:	75 08                	jne    80098b <strtol+0x3b>
		s++, neg = 1;
  800983:	83 c1 01             	add    $0x1,%ecx
  800986:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80098b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800991:	75 15                	jne    8009a8 <strtol+0x58>
  800993:	80 39 30             	cmpb   $0x30,(%ecx)
  800996:	75 10                	jne    8009a8 <strtol+0x58>
  800998:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80099c:	75 7c                	jne    800a1a <strtol+0xca>
		s += 2, base = 16;
  80099e:	83 c1 02             	add    $0x2,%ecx
  8009a1:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009a6:	eb 16                	jmp    8009be <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009a8:	85 db                	test   %ebx,%ebx
  8009aa:	75 12                	jne    8009be <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009ac:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009b1:	80 39 30             	cmpb   $0x30,(%ecx)
  8009b4:	75 08                	jne    8009be <strtol+0x6e>
		s++, base = 8;
  8009b6:	83 c1 01             	add    $0x1,%ecx
  8009b9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009be:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009c6:	0f b6 11             	movzbl (%ecx),%edx
  8009c9:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009cc:	89 f3                	mov    %esi,%ebx
  8009ce:	80 fb 09             	cmp    $0x9,%bl
  8009d1:	77 08                	ja     8009db <strtol+0x8b>
			dig = *s - '0';
  8009d3:	0f be d2             	movsbl %dl,%edx
  8009d6:	83 ea 30             	sub    $0x30,%edx
  8009d9:	eb 22                	jmp    8009fd <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009db:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009de:	89 f3                	mov    %esi,%ebx
  8009e0:	80 fb 19             	cmp    $0x19,%bl
  8009e3:	77 08                	ja     8009ed <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009e5:	0f be d2             	movsbl %dl,%edx
  8009e8:	83 ea 57             	sub    $0x57,%edx
  8009eb:	eb 10                	jmp    8009fd <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009ed:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009f0:	89 f3                	mov    %esi,%ebx
  8009f2:	80 fb 19             	cmp    $0x19,%bl
  8009f5:	77 16                	ja     800a0d <strtol+0xbd>
			dig = *s - 'A' + 10;
  8009f7:	0f be d2             	movsbl %dl,%edx
  8009fa:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009fd:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a00:	7d 0b                	jge    800a0d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a02:	83 c1 01             	add    $0x1,%ecx
  800a05:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a09:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a0b:	eb b9                	jmp    8009c6 <strtol+0x76>

	if (endptr)
  800a0d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a11:	74 0d                	je     800a20 <strtol+0xd0>
		*endptr = (char *) s;
  800a13:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a16:	89 0e                	mov    %ecx,(%esi)
  800a18:	eb 06                	jmp    800a20 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a1a:	85 db                	test   %ebx,%ebx
  800a1c:	74 98                	je     8009b6 <strtol+0x66>
  800a1e:	eb 9e                	jmp    8009be <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a20:	89 c2                	mov    %eax,%edx
  800a22:	f7 da                	neg    %edx
  800a24:	85 ff                	test   %edi,%edi
  800a26:	0f 45 c2             	cmovne %edx,%eax
}
  800a29:	5b                   	pop    %ebx
  800a2a:	5e                   	pop    %esi
  800a2b:	5f                   	pop    %edi
  800a2c:	5d                   	pop    %ebp
  800a2d:	c3                   	ret    

00800a2e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	57                   	push   %edi
  800a32:	56                   	push   %esi
  800a33:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a34:	b8 00 00 00 00       	mov    $0x0,%eax
  800a39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3f:	89 c3                	mov    %eax,%ebx
  800a41:	89 c7                	mov    %eax,%edi
  800a43:	89 c6                	mov    %eax,%esi
  800a45:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a47:	5b                   	pop    %ebx
  800a48:	5e                   	pop    %esi
  800a49:	5f                   	pop    %edi
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <sys_cgetc>:

int
sys_cgetc(void)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	57                   	push   %edi
  800a50:	56                   	push   %esi
  800a51:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a52:	ba 00 00 00 00       	mov    $0x0,%edx
  800a57:	b8 01 00 00 00       	mov    $0x1,%eax
  800a5c:	89 d1                	mov    %edx,%ecx
  800a5e:	89 d3                	mov    %edx,%ebx
  800a60:	89 d7                	mov    %edx,%edi
  800a62:	89 d6                	mov    %edx,%esi
  800a64:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a66:	5b                   	pop    %ebx
  800a67:	5e                   	pop    %esi
  800a68:	5f                   	pop    %edi
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	57                   	push   %edi
  800a6f:	56                   	push   %esi
  800a70:	53                   	push   %ebx
  800a71:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a74:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a79:	b8 03 00 00 00       	mov    $0x3,%eax
  800a7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a81:	89 cb                	mov    %ecx,%ebx
  800a83:	89 cf                	mov    %ecx,%edi
  800a85:	89 ce                	mov    %ecx,%esi
  800a87:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a89:	85 c0                	test   %eax,%eax
  800a8b:	7e 17                	jle    800aa4 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a8d:	83 ec 0c             	sub    $0xc,%esp
  800a90:	50                   	push   %eax
  800a91:	6a 03                	push   $0x3
  800a93:	68 e8 11 80 00       	push   $0x8011e8
  800a98:	6a 23                	push   $0x23
  800a9a:	68 05 12 80 00       	push   $0x801205
  800a9f:	e8 f5 01 00 00       	call   800c99 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aa4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aa7:	5b                   	pop    %ebx
  800aa8:	5e                   	pop    %esi
  800aa9:	5f                   	pop    %edi
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	57                   	push   %edi
  800ab0:	56                   	push   %esi
  800ab1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab7:	b8 02 00 00 00       	mov    $0x2,%eax
  800abc:	89 d1                	mov    %edx,%ecx
  800abe:	89 d3                	mov    %edx,%ebx
  800ac0:	89 d7                	mov    %edx,%edi
  800ac2:	89 d6                	mov    %edx,%esi
  800ac4:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ac6:	5b                   	pop    %ebx
  800ac7:	5e                   	pop    %esi
  800ac8:	5f                   	pop    %edi
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <sys_yield>:

void
sys_yield(void)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	57                   	push   %edi
  800acf:	56                   	push   %esi
  800ad0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800adb:	89 d1                	mov    %edx,%ecx
  800add:	89 d3                	mov    %edx,%ebx
  800adf:	89 d7                	mov    %edx,%edi
  800ae1:	89 d6                	mov    %edx,%esi
  800ae3:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5f                   	pop    %edi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	57                   	push   %edi
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
  800af0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af3:	be 00 00 00 00       	mov    $0x0,%esi
  800af8:	b8 04 00 00 00       	mov    $0x4,%eax
  800afd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b00:	8b 55 08             	mov    0x8(%ebp),%edx
  800b03:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b06:	89 f7                	mov    %esi,%edi
  800b08:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b0a:	85 c0                	test   %eax,%eax
  800b0c:	7e 17                	jle    800b25 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b0e:	83 ec 0c             	sub    $0xc,%esp
  800b11:	50                   	push   %eax
  800b12:	6a 04                	push   $0x4
  800b14:	68 e8 11 80 00       	push   $0x8011e8
  800b19:	6a 23                	push   $0x23
  800b1b:	68 05 12 80 00       	push   $0x801205
  800b20:	e8 74 01 00 00       	call   800c99 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b28:	5b                   	pop    %ebx
  800b29:	5e                   	pop    %esi
  800b2a:	5f                   	pop    %edi
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800b36:	b8 05 00 00 00       	mov    $0x5,%eax
  800b3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b41:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b44:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b47:	8b 75 18             	mov    0x18(%ebp),%esi
  800b4a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b4c:	85 c0                	test   %eax,%eax
  800b4e:	7e 17                	jle    800b67 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b50:	83 ec 0c             	sub    $0xc,%esp
  800b53:	50                   	push   %eax
  800b54:	6a 05                	push   $0x5
  800b56:	68 e8 11 80 00       	push   $0x8011e8
  800b5b:	6a 23                	push   $0x23
  800b5d:	68 05 12 80 00       	push   $0x801205
  800b62:	e8 32 01 00 00       	call   800c99 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6a:	5b                   	pop    %ebx
  800b6b:	5e                   	pop    %esi
  800b6c:	5f                   	pop    %edi
  800b6d:	5d                   	pop    %ebp
  800b6e:	c3                   	ret    

00800b6f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	57                   	push   %edi
  800b73:	56                   	push   %esi
  800b74:	53                   	push   %ebx
  800b75:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b78:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b7d:	b8 06 00 00 00       	mov    $0x6,%eax
  800b82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b85:	8b 55 08             	mov    0x8(%ebp),%edx
  800b88:	89 df                	mov    %ebx,%edi
  800b8a:	89 de                	mov    %ebx,%esi
  800b8c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b8e:	85 c0                	test   %eax,%eax
  800b90:	7e 17                	jle    800ba9 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b92:	83 ec 0c             	sub    $0xc,%esp
  800b95:	50                   	push   %eax
  800b96:	6a 06                	push   $0x6
  800b98:	68 e8 11 80 00       	push   $0x8011e8
  800b9d:	6a 23                	push   $0x23
  800b9f:	68 05 12 80 00       	push   $0x801205
  800ba4:	e8 f0 00 00 00       	call   800c99 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ba9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	57                   	push   %edi
  800bb5:	56                   	push   %esi
  800bb6:	53                   	push   %ebx
  800bb7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bba:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bbf:	b8 08 00 00 00       	mov    $0x8,%eax
  800bc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bca:	89 df                	mov    %ebx,%edi
  800bcc:	89 de                	mov    %ebx,%esi
  800bce:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd0:	85 c0                	test   %eax,%eax
  800bd2:	7e 17                	jle    800beb <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd4:	83 ec 0c             	sub    $0xc,%esp
  800bd7:	50                   	push   %eax
  800bd8:	6a 08                	push   $0x8
  800bda:	68 e8 11 80 00       	push   $0x8011e8
  800bdf:	6a 23                	push   $0x23
  800be1:	68 05 12 80 00       	push   $0x801205
  800be6:	e8 ae 00 00 00       	call   800c99 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800beb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	57                   	push   %edi
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
  800bf9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c01:	b8 09 00 00 00       	mov    $0x9,%eax
  800c06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c09:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0c:	89 df                	mov    %ebx,%edi
  800c0e:	89 de                	mov    %ebx,%esi
  800c10:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c12:	85 c0                	test   %eax,%eax
  800c14:	7e 17                	jle    800c2d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c16:	83 ec 0c             	sub    $0xc,%esp
  800c19:	50                   	push   %eax
  800c1a:	6a 09                	push   $0x9
  800c1c:	68 e8 11 80 00       	push   $0x8011e8
  800c21:	6a 23                	push   $0x23
  800c23:	68 05 12 80 00       	push   $0x801205
  800c28:	e8 6c 00 00 00       	call   800c99 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3b:	be 00 00 00 00       	mov    $0x0,%esi
  800c40:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c48:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c51:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c53:	5b                   	pop    %ebx
  800c54:	5e                   	pop    %esi
  800c55:	5f                   	pop    %edi
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	57                   	push   %edi
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
  800c5e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c61:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c66:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6e:	89 cb                	mov    %ecx,%ebx
  800c70:	89 cf                	mov    %ecx,%edi
  800c72:	89 ce                	mov    %ecx,%esi
  800c74:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c76:	85 c0                	test   %eax,%eax
  800c78:	7e 17                	jle    800c91 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7a:	83 ec 0c             	sub    $0xc,%esp
  800c7d:	50                   	push   %eax
  800c7e:	6a 0c                	push   $0xc
  800c80:	68 e8 11 80 00       	push   $0x8011e8
  800c85:	6a 23                	push   $0x23
  800c87:	68 05 12 80 00       	push   $0x801205
  800c8c:	e8 08 00 00 00       	call   800c99 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800c91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	56                   	push   %esi
  800c9d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800c9e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ca1:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800ca7:	e8 00 fe ff ff       	call   800aac <sys_getenvid>
  800cac:	83 ec 0c             	sub    $0xc,%esp
  800caf:	ff 75 0c             	pushl  0xc(%ebp)
  800cb2:	ff 75 08             	pushl  0x8(%ebp)
  800cb5:	56                   	push   %esi
  800cb6:	50                   	push   %eax
  800cb7:	68 14 12 80 00       	push   $0x801214
  800cbc:	e8 8a f4 ff ff       	call   80014b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800cc1:	83 c4 18             	add    $0x18,%esp
  800cc4:	53                   	push   %ebx
  800cc5:	ff 75 10             	pushl  0x10(%ebp)
  800cc8:	e8 2d f4 ff ff       	call   8000fa <vcprintf>
	cprintf("\n");
  800ccd:	c7 04 24 8c 0f 80 00 	movl   $0x800f8c,(%esp)
  800cd4:	e8 72 f4 ff ff       	call   80014b <cprintf>
  800cd9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800cdc:	cc                   	int3   
  800cdd:	eb fd                	jmp    800cdc <_panic+0x43>
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
