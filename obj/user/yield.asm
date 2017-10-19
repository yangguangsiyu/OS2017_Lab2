
obj/user/yield：     文件格式 elf32-i386


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
  80002c:	e8 69 00 00 00       	call   80009a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 04 20 80 00       	mov    0x802004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 c0 0f 80 00       	push   $0x800fc0
  800048:	e8 38 01 00 00       	call   800185 <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 ab 0a 00 00       	call   800b05 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 04 20 80 00       	mov    0x802004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 e0 0f 80 00       	push   $0x800fe0
  80006c:	e8 14 01 00 00       	call   800185 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800071:	83 c3 01             	add    $0x1,%ebx
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	83 fb 05             	cmp    $0x5,%ebx
  80007a:	75 d9                	jne    800055 <umain+0x22>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007c:	a1 04 20 80 00       	mov    0x802004,%eax
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 0c 10 80 00       	push   $0x80100c
  80008d:	e8 f3 00 00 00       	call   800185 <cprintf>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000a5:	e8 3c 0a 00 00       	call   800ae6 <sys_getenvid>
  8000aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000af:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b7:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bc:	85 db                	test   %ebx,%ebx
  8000be:	7e 07                	jle    8000c7 <libmain+0x2d>
		binaryname = argv[0];
  8000c0:	8b 06                	mov    (%esi),%eax
  8000c2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000c7:	83 ec 08             	sub    $0x8,%esp
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
  8000cc:	e8 62 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d1:	e8 0a 00 00 00       	call   8000e0 <exit>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000e6:	6a 00                	push   $0x0
  8000e8:	e8 b8 09 00 00       	call   800aa5 <sys_env_destroy>
}
  8000ed:	83 c4 10             	add    $0x10,%esp
  8000f0:	c9                   	leave  
  8000f1:	c3                   	ret    

008000f2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	53                   	push   %ebx
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000fc:	8b 13                	mov    (%ebx),%edx
  8000fe:	8d 42 01             	lea    0x1(%edx),%eax
  800101:	89 03                	mov    %eax,(%ebx)
  800103:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800106:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80010a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80010f:	75 1a                	jne    80012b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	68 ff 00 00 00       	push   $0xff
  800119:	8d 43 08             	lea    0x8(%ebx),%eax
  80011c:	50                   	push   %eax
  80011d:	e8 46 09 00 00       	call   800a68 <sys_cputs>
		b->idx = 0;
  800122:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800128:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80012b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80012f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800132:	c9                   	leave  
  800133:	c3                   	ret    

00800134 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80013d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800144:	00 00 00 
	b.cnt = 0;
  800147:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80014e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800151:	ff 75 0c             	pushl  0xc(%ebp)
  800154:	ff 75 08             	pushl  0x8(%ebp)
  800157:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80015d:	50                   	push   %eax
  80015e:	68 f2 00 80 00       	push   $0x8000f2
  800163:	e8 54 01 00 00       	call   8002bc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800168:	83 c4 08             	add    $0x8,%esp
  80016b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800171:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800177:	50                   	push   %eax
  800178:	e8 eb 08 00 00       	call   800a68 <sys_cputs>

	return b.cnt;
}
  80017d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800183:	c9                   	leave  
  800184:	c3                   	ret    

00800185 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80018b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80018e:	50                   	push   %eax
  80018f:	ff 75 08             	pushl  0x8(%ebp)
  800192:	e8 9d ff ff ff       	call   800134 <vcprintf>
	va_end(ap);

	return cnt;
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 1c             	sub    $0x1c,%esp
  8001a2:	89 c7                	mov    %eax,%edi
  8001a4:	89 d6                	mov    %edx,%esi
  8001a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001af:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ba:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001bd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001c0:	39 d3                	cmp    %edx,%ebx
  8001c2:	72 05                	jb     8001c9 <printnum+0x30>
  8001c4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001c7:	77 45                	ja     80020e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	ff 75 18             	pushl  0x18(%ebp)
  8001cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8001d2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001d5:	53                   	push   %ebx
  8001d6:	ff 75 10             	pushl  0x10(%ebp)
  8001d9:	83 ec 08             	sub    $0x8,%esp
  8001dc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001df:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e8:	e8 33 0b 00 00       	call   800d20 <__udivdi3>
  8001ed:	83 c4 18             	add    $0x18,%esp
  8001f0:	52                   	push   %edx
  8001f1:	50                   	push   %eax
  8001f2:	89 f2                	mov    %esi,%edx
  8001f4:	89 f8                	mov    %edi,%eax
  8001f6:	e8 9e ff ff ff       	call   800199 <printnum>
  8001fb:	83 c4 20             	add    $0x20,%esp
  8001fe:	eb 18                	jmp    800218 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800200:	83 ec 08             	sub    $0x8,%esp
  800203:	56                   	push   %esi
  800204:	ff 75 18             	pushl  0x18(%ebp)
  800207:	ff d7                	call   *%edi
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	eb 03                	jmp    800211 <printnum+0x78>
  80020e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800211:	83 eb 01             	sub    $0x1,%ebx
  800214:	85 db                	test   %ebx,%ebx
  800216:	7f e8                	jg     800200 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800218:	83 ec 08             	sub    $0x8,%esp
  80021b:	56                   	push   %esi
  80021c:	83 ec 04             	sub    $0x4,%esp
  80021f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800222:	ff 75 e0             	pushl  -0x20(%ebp)
  800225:	ff 75 dc             	pushl  -0x24(%ebp)
  800228:	ff 75 d8             	pushl  -0x28(%ebp)
  80022b:	e8 20 0c 00 00       	call   800e50 <__umoddi3>
  800230:	83 c4 14             	add    $0x14,%esp
  800233:	0f be 80 35 10 80 00 	movsbl 0x801035(%eax),%eax
  80023a:	50                   	push   %eax
  80023b:	ff d7                	call   *%edi
}
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800243:	5b                   	pop    %ebx
  800244:	5e                   	pop    %esi
  800245:	5f                   	pop    %edi
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80024b:	83 fa 01             	cmp    $0x1,%edx
  80024e:	7e 0e                	jle    80025e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800250:	8b 10                	mov    (%eax),%edx
  800252:	8d 4a 08             	lea    0x8(%edx),%ecx
  800255:	89 08                	mov    %ecx,(%eax)
  800257:	8b 02                	mov    (%edx),%eax
  800259:	8b 52 04             	mov    0x4(%edx),%edx
  80025c:	eb 22                	jmp    800280 <getuint+0x38>
	else if (lflag)
  80025e:	85 d2                	test   %edx,%edx
  800260:	74 10                	je     800272 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800262:	8b 10                	mov    (%eax),%edx
  800264:	8d 4a 04             	lea    0x4(%edx),%ecx
  800267:	89 08                	mov    %ecx,(%eax)
  800269:	8b 02                	mov    (%edx),%eax
  80026b:	ba 00 00 00 00       	mov    $0x0,%edx
  800270:	eb 0e                	jmp    800280 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800272:	8b 10                	mov    (%eax),%edx
  800274:	8d 4a 04             	lea    0x4(%edx),%ecx
  800277:	89 08                	mov    %ecx,(%eax)
  800279:	8b 02                	mov    (%edx),%eax
  80027b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800280:	5d                   	pop    %ebp
  800281:	c3                   	ret    

00800282 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800288:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80028c:	8b 10                	mov    (%eax),%edx
  80028e:	3b 50 04             	cmp    0x4(%eax),%edx
  800291:	73 0a                	jae    80029d <sprintputch+0x1b>
		*b->buf++ = ch;
  800293:	8d 4a 01             	lea    0x1(%edx),%ecx
  800296:	89 08                	mov    %ecx,(%eax)
  800298:	8b 45 08             	mov    0x8(%ebp),%eax
  80029b:	88 02                	mov    %al,(%edx)
}
  80029d:	5d                   	pop    %ebp
  80029e:	c3                   	ret    

0080029f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
  8002a2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a8:	50                   	push   %eax
  8002a9:	ff 75 10             	pushl  0x10(%ebp)
  8002ac:	ff 75 0c             	pushl  0xc(%ebp)
  8002af:	ff 75 08             	pushl  0x8(%ebp)
  8002b2:	e8 05 00 00 00       	call   8002bc <vprintfmt>
	va_end(ap);
}
  8002b7:	83 c4 10             	add    $0x10,%esp
  8002ba:	c9                   	leave  
  8002bb:	c3                   	ret    

008002bc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	57                   	push   %edi
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	83 ec 2c             	sub    $0x2c,%esp
  8002c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
  8002c8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002cf:	eb 17                	jmp    8002e8 <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d1:	85 c0                	test   %eax,%eax
  8002d3:	0f 84 9f 03 00 00    	je     800678 <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
  8002d9:	83 ec 08             	sub    $0x8,%esp
  8002dc:	ff 75 0c             	pushl  0xc(%ebp)
  8002df:	50                   	push   %eax
  8002e0:	ff 55 08             	call   *0x8(%ebp)
  8002e3:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e6:	89 f3                	mov    %esi,%ebx
  8002e8:	8d 73 01             	lea    0x1(%ebx),%esi
  8002eb:	0f b6 03             	movzbl (%ebx),%eax
  8002ee:	83 f8 25             	cmp    $0x25,%eax
  8002f1:	75 de                	jne    8002d1 <vprintfmt+0x15>
  8002f3:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8002f7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002fe:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800303:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80030a:	ba 00 00 00 00       	mov    $0x0,%edx
  80030f:	eb 06                	jmp    800317 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800311:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800313:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800317:	8d 5e 01             	lea    0x1(%esi),%ebx
  80031a:	0f b6 06             	movzbl (%esi),%eax
  80031d:	0f b6 c8             	movzbl %al,%ecx
  800320:	83 e8 23             	sub    $0x23,%eax
  800323:	3c 55                	cmp    $0x55,%al
  800325:	0f 87 2d 03 00 00    	ja     800658 <vprintfmt+0x39c>
  80032b:	0f b6 c0             	movzbl %al,%eax
  80032e:	ff 24 85 00 11 80 00 	jmp    *0x801100(,%eax,4)
  800335:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800337:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80033b:	eb da                	jmp    800317 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033d:	89 de                	mov    %ebx,%esi
  80033f:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800344:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  800347:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  80034b:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  80034e:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800351:	83 f8 09             	cmp    $0x9,%eax
  800354:	77 33                	ja     800389 <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800356:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800359:	eb e9                	jmp    800344 <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80035b:	8b 45 14             	mov    0x14(%ebp),%eax
  80035e:	8d 48 04             	lea    0x4(%eax),%ecx
  800361:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800364:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800366:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800368:	eb 1f                	jmp    800389 <vprintfmt+0xcd>
  80036a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80036d:	85 c0                	test   %eax,%eax
  80036f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800374:	0f 49 c8             	cmovns %eax,%ecx
  800377:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	89 de                	mov    %ebx,%esi
  80037c:	eb 99                	jmp    800317 <vprintfmt+0x5b>
  80037e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800380:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  800387:	eb 8e                	jmp    800317 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  800389:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80038d:	79 88                	jns    800317 <vprintfmt+0x5b>
				width = precision, precision = -1;
  80038f:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800392:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800397:	e9 7b ff ff ff       	jmp    800317 <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80039c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039f:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003a1:	e9 71 ff ff ff       	jmp    800317 <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
  8003a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a9:	8d 50 04             	lea    0x4(%eax),%edx
  8003ac:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  8003af:	83 ec 08             	sub    $0x8,%esp
  8003b2:	ff 75 0c             	pushl  0xc(%ebp)
  8003b5:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8003b8:	03 08                	add    (%eax),%ecx
  8003ba:	51                   	push   %ecx
  8003bb:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
  8003be:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
  8003c1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
  8003c8:	e9 1b ff ff ff       	jmp    8002e8 <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
  8003cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d0:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d6:	8b 00                	mov    (%eax),%eax
  8003d8:	83 f8 02             	cmp    $0x2,%eax
  8003db:	74 1a                	je     8003f7 <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	89 de                	mov    %ebx,%esi
  8003df:	83 f8 04             	cmp    $0x4,%eax
  8003e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e7:	b9 00 04 00 00       	mov    $0x400,%ecx
  8003ec:	0f 44 c1             	cmove  %ecx,%eax
  8003ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003f2:	e9 20 ff ff ff       	jmp    800317 <vprintfmt+0x5b>
  8003f7:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
  8003f9:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
  800400:	e9 12 ff ff ff       	jmp    800317 <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800405:	8b 45 14             	mov    0x14(%ebp),%eax
  800408:	8d 50 04             	lea    0x4(%eax),%edx
  80040b:	89 55 14             	mov    %edx,0x14(%ebp)
  80040e:	8b 00                	mov    (%eax),%eax
  800410:	99                   	cltd   
  800411:	31 d0                	xor    %edx,%eax
  800413:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800415:	83 f8 09             	cmp    $0x9,%eax
  800418:	7f 0b                	jg     800425 <vprintfmt+0x169>
  80041a:	8b 14 85 60 12 80 00 	mov    0x801260(,%eax,4),%edx
  800421:	85 d2                	test   %edx,%edx
  800423:	75 19                	jne    80043e <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800425:	50                   	push   %eax
  800426:	68 4d 10 80 00       	push   $0x80104d
  80042b:	ff 75 0c             	pushl  0xc(%ebp)
  80042e:	ff 75 08             	pushl  0x8(%ebp)
  800431:	e8 69 fe ff ff       	call   80029f <printfmt>
  800436:	83 c4 10             	add    $0x10,%esp
  800439:	e9 aa fe ff ff       	jmp    8002e8 <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  80043e:	52                   	push   %edx
  80043f:	68 56 10 80 00       	push   $0x801056
  800444:	ff 75 0c             	pushl  0xc(%ebp)
  800447:	ff 75 08             	pushl  0x8(%ebp)
  80044a:	e8 50 fe ff ff       	call   80029f <printfmt>
  80044f:	83 c4 10             	add    $0x10,%esp
  800452:	e9 91 fe ff ff       	jmp    8002e8 <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800457:	8b 45 14             	mov    0x14(%ebp),%eax
  80045a:	8d 50 04             	lea    0x4(%eax),%edx
  80045d:	89 55 14             	mov    %edx,0x14(%ebp)
  800460:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800462:	85 f6                	test   %esi,%esi
  800464:	b8 46 10 80 00       	mov    $0x801046,%eax
  800469:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80046c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800470:	0f 8e 93 00 00 00    	jle    800509 <vprintfmt+0x24d>
  800476:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80047a:	0f 84 91 00 00 00    	je     800511 <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	57                   	push   %edi
  800484:	56                   	push   %esi
  800485:	e8 76 02 00 00       	call   800700 <strnlen>
  80048a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80048d:	29 c1                	sub    %eax,%ecx
  80048f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800492:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800495:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  800499:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80049c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80049f:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004a2:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004a5:	89 cb                	mov    %ecx,%ebx
  8004a7:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a9:	eb 0e                	jmp    8004b9 <vprintfmt+0x1fd>
					putch(padc, putdat);
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	56                   	push   %esi
  8004af:	57                   	push   %edi
  8004b0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b3:	83 eb 01             	sub    $0x1,%ebx
  8004b6:	83 c4 10             	add    $0x10,%esp
  8004b9:	85 db                	test   %ebx,%ebx
  8004bb:	7f ee                	jg     8004ab <vprintfmt+0x1ef>
  8004bd:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004c0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004c6:	85 c9                	test   %ecx,%ecx
  8004c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cd:	0f 49 c1             	cmovns %ecx,%eax
  8004d0:	29 c1                	sub    %eax,%ecx
  8004d2:	89 cb                	mov    %ecx,%ebx
  8004d4:	eb 41                	jmp    800517 <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004d6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004da:	74 1b                	je     8004f7 <vprintfmt+0x23b>
  8004dc:	0f be c0             	movsbl %al,%eax
  8004df:	83 e8 20             	sub    $0x20,%eax
  8004e2:	83 f8 5e             	cmp    $0x5e,%eax
  8004e5:	76 10                	jbe    8004f7 <vprintfmt+0x23b>
					putch('?', putdat);
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	ff 75 0c             	pushl  0xc(%ebp)
  8004ed:	6a 3f                	push   $0x3f
  8004ef:	ff 55 08             	call   *0x8(%ebp)
  8004f2:	83 c4 10             	add    $0x10,%esp
  8004f5:	eb 0d                	jmp    800504 <vprintfmt+0x248>
				else
					putch(ch, putdat);
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	ff 75 0c             	pushl  0xc(%ebp)
  8004fd:	52                   	push   %edx
  8004fe:	ff 55 08             	call   *0x8(%ebp)
  800501:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800504:	83 eb 01             	sub    $0x1,%ebx
  800507:	eb 0e                	jmp    800517 <vprintfmt+0x25b>
  800509:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80050c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80050f:	eb 06                	jmp    800517 <vprintfmt+0x25b>
  800511:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800514:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800517:	83 c6 01             	add    $0x1,%esi
  80051a:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80051e:	0f be d0             	movsbl %al,%edx
  800521:	85 d2                	test   %edx,%edx
  800523:	74 25                	je     80054a <vprintfmt+0x28e>
  800525:	85 ff                	test   %edi,%edi
  800527:	78 ad                	js     8004d6 <vprintfmt+0x21a>
  800529:	83 ef 01             	sub    $0x1,%edi
  80052c:	79 a8                	jns    8004d6 <vprintfmt+0x21a>
  80052e:	89 d8                	mov    %ebx,%eax
  800530:	8b 75 08             	mov    0x8(%ebp),%esi
  800533:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800536:	89 c3                	mov    %eax,%ebx
  800538:	eb 16                	jmp    800550 <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	57                   	push   %edi
  80053e:	6a 20                	push   $0x20
  800540:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800542:	83 eb 01             	sub    $0x1,%ebx
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	eb 06                	jmp    800550 <vprintfmt+0x294>
  80054a:	8b 75 08             	mov    0x8(%ebp),%esi
  80054d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800550:	85 db                	test   %ebx,%ebx
  800552:	7f e6                	jg     80053a <vprintfmt+0x27e>
  800554:	89 75 08             	mov    %esi,0x8(%ebp)
  800557:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80055a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80055d:	e9 86 fd ff ff       	jmp    8002e8 <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800562:	83 fa 01             	cmp    $0x1,%edx
  800565:	7e 10                	jle    800577 <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 50 08             	lea    0x8(%eax),%edx
  80056d:	89 55 14             	mov    %edx,0x14(%ebp)
  800570:	8b 30                	mov    (%eax),%esi
  800572:	8b 78 04             	mov    0x4(%eax),%edi
  800575:	eb 26                	jmp    80059d <vprintfmt+0x2e1>
	else if (lflag)
  800577:	85 d2                	test   %edx,%edx
  800579:	74 12                	je     80058d <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	8d 50 04             	lea    0x4(%eax),%edx
  800581:	89 55 14             	mov    %edx,0x14(%ebp)
  800584:	8b 30                	mov    (%eax),%esi
  800586:	89 f7                	mov    %esi,%edi
  800588:	c1 ff 1f             	sar    $0x1f,%edi
  80058b:	eb 10                	jmp    80059d <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8d 50 04             	lea    0x4(%eax),%edx
  800593:	89 55 14             	mov    %edx,0x14(%ebp)
  800596:	8b 30                	mov    (%eax),%esi
  800598:	89 f7                	mov    %esi,%edi
  80059a:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80059d:	89 f0                	mov    %esi,%eax
  80059f:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a6:	85 ff                	test   %edi,%edi
  8005a8:	79 7b                	jns    800625 <vprintfmt+0x369>
				putch('-', putdat);
  8005aa:	83 ec 08             	sub    $0x8,%esp
  8005ad:	ff 75 0c             	pushl  0xc(%ebp)
  8005b0:	6a 2d                	push   $0x2d
  8005b2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005b5:	89 f0                	mov    %esi,%eax
  8005b7:	89 fa                	mov    %edi,%edx
  8005b9:	f7 d8                	neg    %eax
  8005bb:	83 d2 00             	adc    $0x0,%edx
  8005be:	f7 da                	neg    %edx
  8005c0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005c3:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005c8:	eb 5b                	jmp    800625 <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ca:	8d 45 14             	lea    0x14(%ebp),%eax
  8005cd:	e8 76 fc ff ff       	call   800248 <getuint>
			base = 10;
  8005d2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005d7:	eb 4c                	jmp    800625 <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
  8005d9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005dc:	e8 67 fc ff ff       	call   800248 <getuint>
            base = 8;
  8005e1:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005e6:	eb 3d                	jmp    800625 <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	ff 75 0c             	pushl  0xc(%ebp)
  8005ee:	6a 30                	push   $0x30
  8005f0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005f3:	83 c4 08             	add    $0x8,%esp
  8005f6:	ff 75 0c             	pushl  0xc(%ebp)
  8005f9:	6a 78                	push   $0x78
  8005fb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8d 50 04             	lea    0x4(%eax),%edx
  800604:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800607:	8b 00                	mov    (%eax),%eax
  800609:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80060e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800611:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800616:	eb 0d                	jmp    800625 <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800618:	8d 45 14             	lea    0x14(%ebp),%eax
  80061b:	e8 28 fc ff ff       	call   800248 <getuint>
			base = 16;
  800620:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800625:	83 ec 0c             	sub    $0xc,%esp
  800628:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  80062c:	56                   	push   %esi
  80062d:	ff 75 e0             	pushl  -0x20(%ebp)
  800630:	51                   	push   %ecx
  800631:	52                   	push   %edx
  800632:	50                   	push   %eax
  800633:	8b 55 0c             	mov    0xc(%ebp),%edx
  800636:	8b 45 08             	mov    0x8(%ebp),%eax
  800639:	e8 5b fb ff ff       	call   800199 <printnum>
			break;
  80063e:	83 c4 20             	add    $0x20,%esp
  800641:	e9 a2 fc ff ff       	jmp    8002e8 <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	ff 75 0c             	pushl  0xc(%ebp)
  80064c:	51                   	push   %ecx
  80064d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800650:	83 c4 10             	add    $0x10,%esp
  800653:	e9 90 fc ff ff       	jmp    8002e8 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	ff 75 0c             	pushl  0xc(%ebp)
  80065e:	6a 25                	push   $0x25
  800660:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800663:	83 c4 10             	add    $0x10,%esp
  800666:	89 f3                	mov    %esi,%ebx
  800668:	eb 03                	jmp    80066d <vprintfmt+0x3b1>
  80066a:	83 eb 01             	sub    $0x1,%ebx
  80066d:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800671:	75 f7                	jne    80066a <vprintfmt+0x3ae>
  800673:	e9 70 fc ff ff       	jmp    8002e8 <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  800678:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067b:	5b                   	pop    %ebx
  80067c:	5e                   	pop    %esi
  80067d:	5f                   	pop    %edi
  80067e:	5d                   	pop    %ebp
  80067f:	c3                   	ret    

00800680 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800680:	55                   	push   %ebp
  800681:	89 e5                	mov    %esp,%ebp
  800683:	83 ec 18             	sub    $0x18,%esp
  800686:	8b 45 08             	mov    0x8(%ebp),%eax
  800689:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80068c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80068f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800693:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800696:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80069d:	85 c0                	test   %eax,%eax
  80069f:	74 26                	je     8006c7 <vsnprintf+0x47>
  8006a1:	85 d2                	test   %edx,%edx
  8006a3:	7e 22                	jle    8006c7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a5:	ff 75 14             	pushl  0x14(%ebp)
  8006a8:	ff 75 10             	pushl  0x10(%ebp)
  8006ab:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ae:	50                   	push   %eax
  8006af:	68 82 02 80 00       	push   $0x800282
  8006b4:	e8 03 fc ff ff       	call   8002bc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006bc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c2:	83 c4 10             	add    $0x10,%esp
  8006c5:	eb 05                	jmp    8006cc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006cc:	c9                   	leave  
  8006cd:	c3                   	ret    

008006ce <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006d4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d7:	50                   	push   %eax
  8006d8:	ff 75 10             	pushl  0x10(%ebp)
  8006db:	ff 75 0c             	pushl  0xc(%ebp)
  8006de:	ff 75 08             	pushl  0x8(%ebp)
  8006e1:	e8 9a ff ff ff       	call   800680 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e6:	c9                   	leave  
  8006e7:	c3                   	ret    

008006e8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e8:	55                   	push   %ebp
  8006e9:	89 e5                	mov    %esp,%ebp
  8006eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f3:	eb 03                	jmp    8006f8 <strlen+0x10>
		n++;
  8006f5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006fc:	75 f7                	jne    8006f5 <strlen+0xd>
		n++;
	return n;
}
  8006fe:	5d                   	pop    %ebp
  8006ff:	c3                   	ret    

00800700 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800706:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800709:	ba 00 00 00 00       	mov    $0x0,%edx
  80070e:	eb 03                	jmp    800713 <strnlen+0x13>
		n++;
  800710:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800713:	39 c2                	cmp    %eax,%edx
  800715:	74 08                	je     80071f <strnlen+0x1f>
  800717:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80071b:	75 f3                	jne    800710 <strnlen+0x10>
  80071d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80071f:	5d                   	pop    %ebp
  800720:	c3                   	ret    

00800721 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800721:	55                   	push   %ebp
  800722:	89 e5                	mov    %esp,%ebp
  800724:	53                   	push   %ebx
  800725:	8b 45 08             	mov    0x8(%ebp),%eax
  800728:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80072b:	89 c2                	mov    %eax,%edx
  80072d:	83 c2 01             	add    $0x1,%edx
  800730:	83 c1 01             	add    $0x1,%ecx
  800733:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800737:	88 5a ff             	mov    %bl,-0x1(%edx)
  80073a:	84 db                	test   %bl,%bl
  80073c:	75 ef                	jne    80072d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80073e:	5b                   	pop    %ebx
  80073f:	5d                   	pop    %ebp
  800740:	c3                   	ret    

00800741 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	53                   	push   %ebx
  800745:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800748:	53                   	push   %ebx
  800749:	e8 9a ff ff ff       	call   8006e8 <strlen>
  80074e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800751:	ff 75 0c             	pushl  0xc(%ebp)
  800754:	01 d8                	add    %ebx,%eax
  800756:	50                   	push   %eax
  800757:	e8 c5 ff ff ff       	call   800721 <strcpy>
	return dst;
}
  80075c:	89 d8                	mov    %ebx,%eax
  80075e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800761:	c9                   	leave  
  800762:	c3                   	ret    

00800763 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	56                   	push   %esi
  800767:	53                   	push   %ebx
  800768:	8b 75 08             	mov    0x8(%ebp),%esi
  80076b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80076e:	89 f3                	mov    %esi,%ebx
  800770:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800773:	89 f2                	mov    %esi,%edx
  800775:	eb 0f                	jmp    800786 <strncpy+0x23>
		*dst++ = *src;
  800777:	83 c2 01             	add    $0x1,%edx
  80077a:	0f b6 01             	movzbl (%ecx),%eax
  80077d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800780:	80 39 01             	cmpb   $0x1,(%ecx)
  800783:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800786:	39 da                	cmp    %ebx,%edx
  800788:	75 ed                	jne    800777 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80078a:	89 f0                	mov    %esi,%eax
  80078c:	5b                   	pop    %ebx
  80078d:	5e                   	pop    %esi
  80078e:	5d                   	pop    %ebp
  80078f:	c3                   	ret    

00800790 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	56                   	push   %esi
  800794:	53                   	push   %ebx
  800795:	8b 75 08             	mov    0x8(%ebp),%esi
  800798:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80079b:	8b 55 10             	mov    0x10(%ebp),%edx
  80079e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a0:	85 d2                	test   %edx,%edx
  8007a2:	74 21                	je     8007c5 <strlcpy+0x35>
  8007a4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007a8:	89 f2                	mov    %esi,%edx
  8007aa:	eb 09                	jmp    8007b5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ac:	83 c2 01             	add    $0x1,%edx
  8007af:	83 c1 01             	add    $0x1,%ecx
  8007b2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007b5:	39 c2                	cmp    %eax,%edx
  8007b7:	74 09                	je     8007c2 <strlcpy+0x32>
  8007b9:	0f b6 19             	movzbl (%ecx),%ebx
  8007bc:	84 db                	test   %bl,%bl
  8007be:	75 ec                	jne    8007ac <strlcpy+0x1c>
  8007c0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007c2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007c5:	29 f0                	sub    %esi,%eax
}
  8007c7:	5b                   	pop    %ebx
  8007c8:	5e                   	pop    %esi
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007d4:	eb 06                	jmp    8007dc <strcmp+0x11>
		p++, q++;
  8007d6:	83 c1 01             	add    $0x1,%ecx
  8007d9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007dc:	0f b6 01             	movzbl (%ecx),%eax
  8007df:	84 c0                	test   %al,%al
  8007e1:	74 04                	je     8007e7 <strcmp+0x1c>
  8007e3:	3a 02                	cmp    (%edx),%al
  8007e5:	74 ef                	je     8007d6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e7:	0f b6 c0             	movzbl %al,%eax
  8007ea:	0f b6 12             	movzbl (%edx),%edx
  8007ed:	29 d0                	sub    %edx,%eax
}
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	53                   	push   %ebx
  8007f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fb:	89 c3                	mov    %eax,%ebx
  8007fd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800800:	eb 06                	jmp    800808 <strncmp+0x17>
		n--, p++, q++;
  800802:	83 c0 01             	add    $0x1,%eax
  800805:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800808:	39 d8                	cmp    %ebx,%eax
  80080a:	74 15                	je     800821 <strncmp+0x30>
  80080c:	0f b6 08             	movzbl (%eax),%ecx
  80080f:	84 c9                	test   %cl,%cl
  800811:	74 04                	je     800817 <strncmp+0x26>
  800813:	3a 0a                	cmp    (%edx),%cl
  800815:	74 eb                	je     800802 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800817:	0f b6 00             	movzbl (%eax),%eax
  80081a:	0f b6 12             	movzbl (%edx),%edx
  80081d:	29 d0                	sub    %edx,%eax
  80081f:	eb 05                	jmp    800826 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800821:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800826:	5b                   	pop    %ebx
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    

00800829 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	8b 45 08             	mov    0x8(%ebp),%eax
  80082f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800833:	eb 07                	jmp    80083c <strchr+0x13>
		if (*s == c)
  800835:	38 ca                	cmp    %cl,%dl
  800837:	74 0f                	je     800848 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800839:	83 c0 01             	add    $0x1,%eax
  80083c:	0f b6 10             	movzbl (%eax),%edx
  80083f:	84 d2                	test   %dl,%dl
  800841:	75 f2                	jne    800835 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800843:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	8b 45 08             	mov    0x8(%ebp),%eax
  800850:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800854:	eb 03                	jmp    800859 <strfind+0xf>
  800856:	83 c0 01             	add    $0x1,%eax
  800859:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80085c:	38 ca                	cmp    %cl,%dl
  80085e:	74 04                	je     800864 <strfind+0x1a>
  800860:	84 d2                	test   %dl,%dl
  800862:	75 f2                	jne    800856 <strfind+0xc>
			break;
	return (char *) s;
}
  800864:	5d                   	pop    %ebp
  800865:	c3                   	ret    

00800866 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	57                   	push   %edi
  80086a:	56                   	push   %esi
  80086b:	53                   	push   %ebx
  80086c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80086f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800872:	85 c9                	test   %ecx,%ecx
  800874:	74 36                	je     8008ac <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800876:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80087c:	75 28                	jne    8008a6 <memset+0x40>
  80087e:	f6 c1 03             	test   $0x3,%cl
  800881:	75 23                	jne    8008a6 <memset+0x40>
		c &= 0xFF;
  800883:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800887:	89 d3                	mov    %edx,%ebx
  800889:	c1 e3 08             	shl    $0x8,%ebx
  80088c:	89 d6                	mov    %edx,%esi
  80088e:	c1 e6 18             	shl    $0x18,%esi
  800891:	89 d0                	mov    %edx,%eax
  800893:	c1 e0 10             	shl    $0x10,%eax
  800896:	09 f0                	or     %esi,%eax
  800898:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80089a:	89 d8                	mov    %ebx,%eax
  80089c:	09 d0                	or     %edx,%eax
  80089e:	c1 e9 02             	shr    $0x2,%ecx
  8008a1:	fc                   	cld    
  8008a2:	f3 ab                	rep stos %eax,%es:(%edi)
  8008a4:	eb 06                	jmp    8008ac <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a9:	fc                   	cld    
  8008aa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ac:	89 f8                	mov    %edi,%eax
  8008ae:	5b                   	pop    %ebx
  8008af:	5e                   	pop    %esi
  8008b0:	5f                   	pop    %edi
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	57                   	push   %edi
  8008b7:	56                   	push   %esi
  8008b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008be:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008c1:	39 c6                	cmp    %eax,%esi
  8008c3:	73 35                	jae    8008fa <memmove+0x47>
  8008c5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c8:	39 d0                	cmp    %edx,%eax
  8008ca:	73 2e                	jae    8008fa <memmove+0x47>
		s += n;
		d += n;
  8008cc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008cf:	89 d6                	mov    %edx,%esi
  8008d1:	09 fe                	or     %edi,%esi
  8008d3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d9:	75 13                	jne    8008ee <memmove+0x3b>
  8008db:	f6 c1 03             	test   $0x3,%cl
  8008de:	75 0e                	jne    8008ee <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008e0:	83 ef 04             	sub    $0x4,%edi
  8008e3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008e6:	c1 e9 02             	shr    $0x2,%ecx
  8008e9:	fd                   	std    
  8008ea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ec:	eb 09                	jmp    8008f7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008ee:	83 ef 01             	sub    $0x1,%edi
  8008f1:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008f4:	fd                   	std    
  8008f5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f7:	fc                   	cld    
  8008f8:	eb 1d                	jmp    800917 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008fa:	89 f2                	mov    %esi,%edx
  8008fc:	09 c2                	or     %eax,%edx
  8008fe:	f6 c2 03             	test   $0x3,%dl
  800901:	75 0f                	jne    800912 <memmove+0x5f>
  800903:	f6 c1 03             	test   $0x3,%cl
  800906:	75 0a                	jne    800912 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800908:	c1 e9 02             	shr    $0x2,%ecx
  80090b:	89 c7                	mov    %eax,%edi
  80090d:	fc                   	cld    
  80090e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800910:	eb 05                	jmp    800917 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800912:	89 c7                	mov    %eax,%edi
  800914:	fc                   	cld    
  800915:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800917:	5e                   	pop    %esi
  800918:	5f                   	pop    %edi
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80091e:	ff 75 10             	pushl  0x10(%ebp)
  800921:	ff 75 0c             	pushl  0xc(%ebp)
  800924:	ff 75 08             	pushl  0x8(%ebp)
  800927:	e8 87 ff ff ff       	call   8008b3 <memmove>
}
  80092c:	c9                   	leave  
  80092d:	c3                   	ret    

0080092e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	56                   	push   %esi
  800932:	53                   	push   %ebx
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	8b 55 0c             	mov    0xc(%ebp),%edx
  800939:	89 c6                	mov    %eax,%esi
  80093b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80093e:	eb 1a                	jmp    80095a <memcmp+0x2c>
		if (*s1 != *s2)
  800940:	0f b6 08             	movzbl (%eax),%ecx
  800943:	0f b6 1a             	movzbl (%edx),%ebx
  800946:	38 d9                	cmp    %bl,%cl
  800948:	74 0a                	je     800954 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80094a:	0f b6 c1             	movzbl %cl,%eax
  80094d:	0f b6 db             	movzbl %bl,%ebx
  800950:	29 d8                	sub    %ebx,%eax
  800952:	eb 0f                	jmp    800963 <memcmp+0x35>
		s1++, s2++;
  800954:	83 c0 01             	add    $0x1,%eax
  800957:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80095a:	39 f0                	cmp    %esi,%eax
  80095c:	75 e2                	jne    800940 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80095e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800963:	5b                   	pop    %ebx
  800964:	5e                   	pop    %esi
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	53                   	push   %ebx
  80096b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80096e:	89 c1                	mov    %eax,%ecx
  800970:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800973:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800977:	eb 0a                	jmp    800983 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800979:	0f b6 10             	movzbl (%eax),%edx
  80097c:	39 da                	cmp    %ebx,%edx
  80097e:	74 07                	je     800987 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800980:	83 c0 01             	add    $0x1,%eax
  800983:	39 c8                	cmp    %ecx,%eax
  800985:	72 f2                	jb     800979 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800987:	5b                   	pop    %ebx
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	57                   	push   %edi
  80098e:	56                   	push   %esi
  80098f:	53                   	push   %ebx
  800990:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800993:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800996:	eb 03                	jmp    80099b <strtol+0x11>
		s++;
  800998:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80099b:	0f b6 01             	movzbl (%ecx),%eax
  80099e:	3c 20                	cmp    $0x20,%al
  8009a0:	74 f6                	je     800998 <strtol+0xe>
  8009a2:	3c 09                	cmp    $0x9,%al
  8009a4:	74 f2                	je     800998 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009a6:	3c 2b                	cmp    $0x2b,%al
  8009a8:	75 0a                	jne    8009b4 <strtol+0x2a>
		s++;
  8009aa:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ad:	bf 00 00 00 00       	mov    $0x0,%edi
  8009b2:	eb 11                	jmp    8009c5 <strtol+0x3b>
  8009b4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009b9:	3c 2d                	cmp    $0x2d,%al
  8009bb:	75 08                	jne    8009c5 <strtol+0x3b>
		s++, neg = 1;
  8009bd:	83 c1 01             	add    $0x1,%ecx
  8009c0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009c5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009cb:	75 15                	jne    8009e2 <strtol+0x58>
  8009cd:	80 39 30             	cmpb   $0x30,(%ecx)
  8009d0:	75 10                	jne    8009e2 <strtol+0x58>
  8009d2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009d6:	75 7c                	jne    800a54 <strtol+0xca>
		s += 2, base = 16;
  8009d8:	83 c1 02             	add    $0x2,%ecx
  8009db:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009e0:	eb 16                	jmp    8009f8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009e2:	85 db                	test   %ebx,%ebx
  8009e4:	75 12                	jne    8009f8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009e6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009eb:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ee:	75 08                	jne    8009f8 <strtol+0x6e>
		s++, base = 8;
  8009f0:	83 c1 01             	add    $0x1,%ecx
  8009f3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fd:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a00:	0f b6 11             	movzbl (%ecx),%edx
  800a03:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a06:	89 f3                	mov    %esi,%ebx
  800a08:	80 fb 09             	cmp    $0x9,%bl
  800a0b:	77 08                	ja     800a15 <strtol+0x8b>
			dig = *s - '0';
  800a0d:	0f be d2             	movsbl %dl,%edx
  800a10:	83 ea 30             	sub    $0x30,%edx
  800a13:	eb 22                	jmp    800a37 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a15:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a18:	89 f3                	mov    %esi,%ebx
  800a1a:	80 fb 19             	cmp    $0x19,%bl
  800a1d:	77 08                	ja     800a27 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a1f:	0f be d2             	movsbl %dl,%edx
  800a22:	83 ea 57             	sub    $0x57,%edx
  800a25:	eb 10                	jmp    800a37 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a27:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a2a:	89 f3                	mov    %esi,%ebx
  800a2c:	80 fb 19             	cmp    $0x19,%bl
  800a2f:	77 16                	ja     800a47 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a31:	0f be d2             	movsbl %dl,%edx
  800a34:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a37:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a3a:	7d 0b                	jge    800a47 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a3c:	83 c1 01             	add    $0x1,%ecx
  800a3f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a43:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a45:	eb b9                	jmp    800a00 <strtol+0x76>

	if (endptr)
  800a47:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a4b:	74 0d                	je     800a5a <strtol+0xd0>
		*endptr = (char *) s;
  800a4d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a50:	89 0e                	mov    %ecx,(%esi)
  800a52:	eb 06                	jmp    800a5a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a54:	85 db                	test   %ebx,%ebx
  800a56:	74 98                	je     8009f0 <strtol+0x66>
  800a58:	eb 9e                	jmp    8009f8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a5a:	89 c2                	mov    %eax,%edx
  800a5c:	f7 da                	neg    %edx
  800a5e:	85 ff                	test   %edi,%edi
  800a60:	0f 45 c2             	cmovne %edx,%eax
}
  800a63:	5b                   	pop    %ebx
  800a64:	5e                   	pop    %esi
  800a65:	5f                   	pop    %edi
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	57                   	push   %edi
  800a6c:	56                   	push   %esi
  800a6d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a76:	8b 55 08             	mov    0x8(%ebp),%edx
  800a79:	89 c3                	mov    %eax,%ebx
  800a7b:	89 c7                	mov    %eax,%edi
  800a7d:	89 c6                	mov    %eax,%esi
  800a7f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a81:	5b                   	pop    %ebx
  800a82:	5e                   	pop    %esi
  800a83:	5f                   	pop    %edi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	57                   	push   %edi
  800a8a:	56                   	push   %esi
  800a8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a91:	b8 01 00 00 00       	mov    $0x1,%eax
  800a96:	89 d1                	mov    %edx,%ecx
  800a98:	89 d3                	mov    %edx,%ebx
  800a9a:	89 d7                	mov    %edx,%edi
  800a9c:	89 d6                	mov    %edx,%esi
  800a9e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aa0:	5b                   	pop    %ebx
  800aa1:	5e                   	pop    %esi
  800aa2:	5f                   	pop    %edi
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	57                   	push   %edi
  800aa9:	56                   	push   %esi
  800aaa:	53                   	push   %ebx
  800aab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab8:	8b 55 08             	mov    0x8(%ebp),%edx
  800abb:	89 cb                	mov    %ecx,%ebx
  800abd:	89 cf                	mov    %ecx,%edi
  800abf:	89 ce                	mov    %ecx,%esi
  800ac1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ac3:	85 c0                	test   %eax,%eax
  800ac5:	7e 17                	jle    800ade <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac7:	83 ec 0c             	sub    $0xc,%esp
  800aca:	50                   	push   %eax
  800acb:	6a 03                	push   $0x3
  800acd:	68 88 12 80 00       	push   $0x801288
  800ad2:	6a 23                	push   $0x23
  800ad4:	68 a5 12 80 00       	push   $0x8012a5
  800ad9:	e8 f5 01 00 00       	call   800cd3 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ade:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ae1:	5b                   	pop    %ebx
  800ae2:	5e                   	pop    %esi
  800ae3:	5f                   	pop    %edi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	57                   	push   %edi
  800aea:	56                   	push   %esi
  800aeb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aec:	ba 00 00 00 00       	mov    $0x0,%edx
  800af1:	b8 02 00 00 00       	mov    $0x2,%eax
  800af6:	89 d1                	mov    %edx,%ecx
  800af8:	89 d3                	mov    %edx,%ebx
  800afa:	89 d7                	mov    %edx,%edi
  800afc:	89 d6                	mov    %edx,%esi
  800afe:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5f                   	pop    %edi
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <sys_yield>:

void
sys_yield(void)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	57                   	push   %edi
  800b09:	56                   	push   %esi
  800b0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b10:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b15:	89 d1                	mov    %edx,%ecx
  800b17:	89 d3                	mov    %edx,%ebx
  800b19:	89 d7                	mov    %edx,%edi
  800b1b:	89 d6                	mov    %edx,%esi
  800b1d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b1f:	5b                   	pop    %ebx
  800b20:	5e                   	pop    %esi
  800b21:	5f                   	pop    %edi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
  800b2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2d:	be 00 00 00 00       	mov    $0x0,%esi
  800b32:	b8 04 00 00 00       	mov    $0x4,%eax
  800b37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b40:	89 f7                	mov    %esi,%edi
  800b42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b44:	85 c0                	test   %eax,%eax
  800b46:	7e 17                	jle    800b5f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b48:	83 ec 0c             	sub    $0xc,%esp
  800b4b:	50                   	push   %eax
  800b4c:	6a 04                	push   $0x4
  800b4e:	68 88 12 80 00       	push   $0x801288
  800b53:	6a 23                	push   $0x23
  800b55:	68 a5 12 80 00       	push   $0x8012a5
  800b5a:	e8 74 01 00 00       	call   800cd3 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b62:	5b                   	pop    %ebx
  800b63:	5e                   	pop    %esi
  800b64:	5f                   	pop    %edi
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	57                   	push   %edi
  800b6b:	56                   	push   %esi
  800b6c:	53                   	push   %ebx
  800b6d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b70:	b8 05 00 00 00       	mov    $0x5,%eax
  800b75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b78:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b7e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b81:	8b 75 18             	mov    0x18(%ebp),%esi
  800b84:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b86:	85 c0                	test   %eax,%eax
  800b88:	7e 17                	jle    800ba1 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8a:	83 ec 0c             	sub    $0xc,%esp
  800b8d:	50                   	push   %eax
  800b8e:	6a 05                	push   $0x5
  800b90:	68 88 12 80 00       	push   $0x801288
  800b95:	6a 23                	push   $0x23
  800b97:	68 a5 12 80 00       	push   $0x8012a5
  800b9c:	e8 32 01 00 00       	call   800cd3 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ba1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba4:	5b                   	pop    %ebx
  800ba5:	5e                   	pop    %esi
  800ba6:	5f                   	pop    %edi
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	57                   	push   %edi
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
  800baf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb7:	b8 06 00 00 00       	mov    $0x6,%eax
  800bbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc2:	89 df                	mov    %ebx,%edi
  800bc4:	89 de                	mov    %ebx,%esi
  800bc6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc8:	85 c0                	test   %eax,%eax
  800bca:	7e 17                	jle    800be3 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcc:	83 ec 0c             	sub    $0xc,%esp
  800bcf:	50                   	push   %eax
  800bd0:	6a 06                	push   $0x6
  800bd2:	68 88 12 80 00       	push   $0x801288
  800bd7:	6a 23                	push   $0x23
  800bd9:	68 a5 12 80 00       	push   $0x8012a5
  800bde:	e8 f0 00 00 00       	call   800cd3 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800be3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be6:	5b                   	pop    %ebx
  800be7:	5e                   	pop    %esi
  800be8:	5f                   	pop    %edi
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf9:	b8 08 00 00 00       	mov    $0x8,%eax
  800bfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c01:	8b 55 08             	mov    0x8(%ebp),%edx
  800c04:	89 df                	mov    %ebx,%edi
  800c06:	89 de                	mov    %ebx,%esi
  800c08:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c0a:	85 c0                	test   %eax,%eax
  800c0c:	7e 17                	jle    800c25 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0e:	83 ec 0c             	sub    $0xc,%esp
  800c11:	50                   	push   %eax
  800c12:	6a 08                	push   $0x8
  800c14:	68 88 12 80 00       	push   $0x801288
  800c19:	6a 23                	push   $0x23
  800c1b:	68 a5 12 80 00       	push   $0x8012a5
  800c20:	e8 ae 00 00 00       	call   800cd3 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
  800c33:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3b:	b8 09 00 00 00       	mov    $0x9,%eax
  800c40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c43:	8b 55 08             	mov    0x8(%ebp),%edx
  800c46:	89 df                	mov    %ebx,%edi
  800c48:	89 de                	mov    %ebx,%esi
  800c4a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4c:	85 c0                	test   %eax,%eax
  800c4e:	7e 17                	jle    800c67 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c50:	83 ec 0c             	sub    $0xc,%esp
  800c53:	50                   	push   %eax
  800c54:	6a 09                	push   $0x9
  800c56:	68 88 12 80 00       	push   $0x801288
  800c5b:	6a 23                	push   $0x23
  800c5d:	68 a5 12 80 00       	push   $0x8012a5
  800c62:	e8 6c 00 00 00       	call   800cd3 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6a:	5b                   	pop    %ebx
  800c6b:	5e                   	pop    %esi
  800c6c:	5f                   	pop    %edi
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	57                   	push   %edi
  800c73:	56                   	push   %esi
  800c74:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c75:	be 00 00 00 00       	mov    $0x0,%esi
  800c7a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c82:	8b 55 08             	mov    0x8(%ebp),%edx
  800c85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c88:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c8b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c8d:	5b                   	pop    %ebx
  800c8e:	5e                   	pop    %esi
  800c8f:	5f                   	pop    %edi
  800c90:	5d                   	pop    %ebp
  800c91:	c3                   	ret    

00800c92 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	57                   	push   %edi
  800c96:	56                   	push   %esi
  800c97:	53                   	push   %ebx
  800c98:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ca5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca8:	89 cb                	mov    %ecx,%ebx
  800caa:	89 cf                	mov    %ecx,%edi
  800cac:	89 ce                	mov    %ecx,%esi
  800cae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb0:	85 c0                	test   %eax,%eax
  800cb2:	7e 17                	jle    800ccb <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb4:	83 ec 0c             	sub    $0xc,%esp
  800cb7:	50                   	push   %eax
  800cb8:	6a 0c                	push   $0xc
  800cba:	68 88 12 80 00       	push   $0x801288
  800cbf:	6a 23                	push   $0x23
  800cc1:	68 a5 12 80 00       	push   $0x8012a5
  800cc6:	e8 08 00 00 00       	call   800cd3 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ccb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cce:	5b                   	pop    %ebx
  800ccf:	5e                   	pop    %esi
  800cd0:	5f                   	pop    %edi
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	56                   	push   %esi
  800cd7:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800cd8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800cdb:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800ce1:	e8 00 fe ff ff       	call   800ae6 <sys_getenvid>
  800ce6:	83 ec 0c             	sub    $0xc,%esp
  800ce9:	ff 75 0c             	pushl  0xc(%ebp)
  800cec:	ff 75 08             	pushl  0x8(%ebp)
  800cef:	56                   	push   %esi
  800cf0:	50                   	push   %eax
  800cf1:	68 b4 12 80 00       	push   $0x8012b4
  800cf6:	e8 8a f4 ff ff       	call   800185 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800cfb:	83 c4 18             	add    $0x18,%esp
  800cfe:	53                   	push   %ebx
  800cff:	ff 75 10             	pushl  0x10(%ebp)
  800d02:	e8 2d f4 ff ff       	call   800134 <vcprintf>
	cprintf("\n");
  800d07:	c7 04 24 d8 12 80 00 	movl   $0x8012d8,(%esp)
  800d0e:	e8 72 f4 ff ff       	call   800185 <cprintf>
  800d13:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d16:	cc                   	int3   
  800d17:	eb fd                	jmp    800d16 <_panic+0x43>
  800d19:	66 90                	xchg   %ax,%ax
  800d1b:	66 90                	xchg   %ax,%ax
  800d1d:	66 90                	xchg   %ax,%ax
  800d1f:	90                   	nop

00800d20 <__udivdi3>:
  800d20:	55                   	push   %ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
  800d24:	83 ec 1c             	sub    $0x1c,%esp
  800d27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d37:	85 f6                	test   %esi,%esi
  800d39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d3d:	89 ca                	mov    %ecx,%edx
  800d3f:	89 f8                	mov    %edi,%eax
  800d41:	75 3d                	jne    800d80 <__udivdi3+0x60>
  800d43:	39 cf                	cmp    %ecx,%edi
  800d45:	0f 87 c5 00 00 00    	ja     800e10 <__udivdi3+0xf0>
  800d4b:	85 ff                	test   %edi,%edi
  800d4d:	89 fd                	mov    %edi,%ebp
  800d4f:	75 0b                	jne    800d5c <__udivdi3+0x3c>
  800d51:	b8 01 00 00 00       	mov    $0x1,%eax
  800d56:	31 d2                	xor    %edx,%edx
  800d58:	f7 f7                	div    %edi
  800d5a:	89 c5                	mov    %eax,%ebp
  800d5c:	89 c8                	mov    %ecx,%eax
  800d5e:	31 d2                	xor    %edx,%edx
  800d60:	f7 f5                	div    %ebp
  800d62:	89 c1                	mov    %eax,%ecx
  800d64:	89 d8                	mov    %ebx,%eax
  800d66:	89 cf                	mov    %ecx,%edi
  800d68:	f7 f5                	div    %ebp
  800d6a:	89 c3                	mov    %eax,%ebx
  800d6c:	89 d8                	mov    %ebx,%eax
  800d6e:	89 fa                	mov    %edi,%edx
  800d70:	83 c4 1c             	add    $0x1c,%esp
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    
  800d78:	90                   	nop
  800d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d80:	39 ce                	cmp    %ecx,%esi
  800d82:	77 74                	ja     800df8 <__udivdi3+0xd8>
  800d84:	0f bd fe             	bsr    %esi,%edi
  800d87:	83 f7 1f             	xor    $0x1f,%edi
  800d8a:	0f 84 98 00 00 00    	je     800e28 <__udivdi3+0x108>
  800d90:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d95:	89 f9                	mov    %edi,%ecx
  800d97:	89 c5                	mov    %eax,%ebp
  800d99:	29 fb                	sub    %edi,%ebx
  800d9b:	d3 e6                	shl    %cl,%esi
  800d9d:	89 d9                	mov    %ebx,%ecx
  800d9f:	d3 ed                	shr    %cl,%ebp
  800da1:	89 f9                	mov    %edi,%ecx
  800da3:	d3 e0                	shl    %cl,%eax
  800da5:	09 ee                	or     %ebp,%esi
  800da7:	89 d9                	mov    %ebx,%ecx
  800da9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dad:	89 d5                	mov    %edx,%ebp
  800daf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800db3:	d3 ed                	shr    %cl,%ebp
  800db5:	89 f9                	mov    %edi,%ecx
  800db7:	d3 e2                	shl    %cl,%edx
  800db9:	89 d9                	mov    %ebx,%ecx
  800dbb:	d3 e8                	shr    %cl,%eax
  800dbd:	09 c2                	or     %eax,%edx
  800dbf:	89 d0                	mov    %edx,%eax
  800dc1:	89 ea                	mov    %ebp,%edx
  800dc3:	f7 f6                	div    %esi
  800dc5:	89 d5                	mov    %edx,%ebp
  800dc7:	89 c3                	mov    %eax,%ebx
  800dc9:	f7 64 24 0c          	mull   0xc(%esp)
  800dcd:	39 d5                	cmp    %edx,%ebp
  800dcf:	72 10                	jb     800de1 <__udivdi3+0xc1>
  800dd1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800dd5:	89 f9                	mov    %edi,%ecx
  800dd7:	d3 e6                	shl    %cl,%esi
  800dd9:	39 c6                	cmp    %eax,%esi
  800ddb:	73 07                	jae    800de4 <__udivdi3+0xc4>
  800ddd:	39 d5                	cmp    %edx,%ebp
  800ddf:	75 03                	jne    800de4 <__udivdi3+0xc4>
  800de1:	83 eb 01             	sub    $0x1,%ebx
  800de4:	31 ff                	xor    %edi,%edi
  800de6:	89 d8                	mov    %ebx,%eax
  800de8:	89 fa                	mov    %edi,%edx
  800dea:	83 c4 1c             	add    $0x1c,%esp
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5f                   	pop    %edi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    
  800df2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800df8:	31 ff                	xor    %edi,%edi
  800dfa:	31 db                	xor    %ebx,%ebx
  800dfc:	89 d8                	mov    %ebx,%eax
  800dfe:	89 fa                	mov    %edi,%edx
  800e00:	83 c4 1c             	add    $0x1c,%esp
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    
  800e08:	90                   	nop
  800e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e10:	89 d8                	mov    %ebx,%eax
  800e12:	f7 f7                	div    %edi
  800e14:	31 ff                	xor    %edi,%edi
  800e16:	89 c3                	mov    %eax,%ebx
  800e18:	89 d8                	mov    %ebx,%eax
  800e1a:	89 fa                	mov    %edi,%edx
  800e1c:	83 c4 1c             	add    $0x1c,%esp
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    
  800e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e28:	39 ce                	cmp    %ecx,%esi
  800e2a:	72 0c                	jb     800e38 <__udivdi3+0x118>
  800e2c:	31 db                	xor    %ebx,%ebx
  800e2e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e32:	0f 87 34 ff ff ff    	ja     800d6c <__udivdi3+0x4c>
  800e38:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e3d:	e9 2a ff ff ff       	jmp    800d6c <__udivdi3+0x4c>
  800e42:	66 90                	xchg   %ax,%ax
  800e44:	66 90                	xchg   %ax,%ax
  800e46:	66 90                	xchg   %ax,%ax
  800e48:	66 90                	xchg   %ax,%ax
  800e4a:	66 90                	xchg   %ax,%ax
  800e4c:	66 90                	xchg   %ax,%ax
  800e4e:	66 90                	xchg   %ax,%ax

00800e50 <__umoddi3>:
  800e50:	55                   	push   %ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	83 ec 1c             	sub    $0x1c,%esp
  800e57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e5b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e67:	85 d2                	test   %edx,%edx
  800e69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e71:	89 f3                	mov    %esi,%ebx
  800e73:	89 3c 24             	mov    %edi,(%esp)
  800e76:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e7a:	75 1c                	jne    800e98 <__umoddi3+0x48>
  800e7c:	39 f7                	cmp    %esi,%edi
  800e7e:	76 50                	jbe    800ed0 <__umoddi3+0x80>
  800e80:	89 c8                	mov    %ecx,%eax
  800e82:	89 f2                	mov    %esi,%edx
  800e84:	f7 f7                	div    %edi
  800e86:	89 d0                	mov    %edx,%eax
  800e88:	31 d2                	xor    %edx,%edx
  800e8a:	83 c4 1c             	add    $0x1c,%esp
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    
  800e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e98:	39 f2                	cmp    %esi,%edx
  800e9a:	89 d0                	mov    %edx,%eax
  800e9c:	77 52                	ja     800ef0 <__umoddi3+0xa0>
  800e9e:	0f bd ea             	bsr    %edx,%ebp
  800ea1:	83 f5 1f             	xor    $0x1f,%ebp
  800ea4:	75 5a                	jne    800f00 <__umoddi3+0xb0>
  800ea6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800eaa:	0f 82 e0 00 00 00    	jb     800f90 <__umoddi3+0x140>
  800eb0:	39 0c 24             	cmp    %ecx,(%esp)
  800eb3:	0f 86 d7 00 00 00    	jbe    800f90 <__umoddi3+0x140>
  800eb9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ebd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ec1:	83 c4 1c             	add    $0x1c,%esp
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    
  800ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	85 ff                	test   %edi,%edi
  800ed2:	89 fd                	mov    %edi,%ebp
  800ed4:	75 0b                	jne    800ee1 <__umoddi3+0x91>
  800ed6:	b8 01 00 00 00       	mov    $0x1,%eax
  800edb:	31 d2                	xor    %edx,%edx
  800edd:	f7 f7                	div    %edi
  800edf:	89 c5                	mov    %eax,%ebp
  800ee1:	89 f0                	mov    %esi,%eax
  800ee3:	31 d2                	xor    %edx,%edx
  800ee5:	f7 f5                	div    %ebp
  800ee7:	89 c8                	mov    %ecx,%eax
  800ee9:	f7 f5                	div    %ebp
  800eeb:	89 d0                	mov    %edx,%eax
  800eed:	eb 99                	jmp    800e88 <__umoddi3+0x38>
  800eef:	90                   	nop
  800ef0:	89 c8                	mov    %ecx,%eax
  800ef2:	89 f2                	mov    %esi,%edx
  800ef4:	83 c4 1c             	add    $0x1c,%esp
  800ef7:	5b                   	pop    %ebx
  800ef8:	5e                   	pop    %esi
  800ef9:	5f                   	pop    %edi
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    
  800efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f00:	8b 34 24             	mov    (%esp),%esi
  800f03:	bf 20 00 00 00       	mov    $0x20,%edi
  800f08:	89 e9                	mov    %ebp,%ecx
  800f0a:	29 ef                	sub    %ebp,%edi
  800f0c:	d3 e0                	shl    %cl,%eax
  800f0e:	89 f9                	mov    %edi,%ecx
  800f10:	89 f2                	mov    %esi,%edx
  800f12:	d3 ea                	shr    %cl,%edx
  800f14:	89 e9                	mov    %ebp,%ecx
  800f16:	09 c2                	or     %eax,%edx
  800f18:	89 d8                	mov    %ebx,%eax
  800f1a:	89 14 24             	mov    %edx,(%esp)
  800f1d:	89 f2                	mov    %esi,%edx
  800f1f:	d3 e2                	shl    %cl,%edx
  800f21:	89 f9                	mov    %edi,%ecx
  800f23:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f27:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f2b:	d3 e8                	shr    %cl,%eax
  800f2d:	89 e9                	mov    %ebp,%ecx
  800f2f:	89 c6                	mov    %eax,%esi
  800f31:	d3 e3                	shl    %cl,%ebx
  800f33:	89 f9                	mov    %edi,%ecx
  800f35:	89 d0                	mov    %edx,%eax
  800f37:	d3 e8                	shr    %cl,%eax
  800f39:	89 e9                	mov    %ebp,%ecx
  800f3b:	09 d8                	or     %ebx,%eax
  800f3d:	89 d3                	mov    %edx,%ebx
  800f3f:	89 f2                	mov    %esi,%edx
  800f41:	f7 34 24             	divl   (%esp)
  800f44:	89 d6                	mov    %edx,%esi
  800f46:	d3 e3                	shl    %cl,%ebx
  800f48:	f7 64 24 04          	mull   0x4(%esp)
  800f4c:	39 d6                	cmp    %edx,%esi
  800f4e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f52:	89 d1                	mov    %edx,%ecx
  800f54:	89 c3                	mov    %eax,%ebx
  800f56:	72 08                	jb     800f60 <__umoddi3+0x110>
  800f58:	75 11                	jne    800f6b <__umoddi3+0x11b>
  800f5a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f5e:	73 0b                	jae    800f6b <__umoddi3+0x11b>
  800f60:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f64:	1b 14 24             	sbb    (%esp),%edx
  800f67:	89 d1                	mov    %edx,%ecx
  800f69:	89 c3                	mov    %eax,%ebx
  800f6b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f6f:	29 da                	sub    %ebx,%edx
  800f71:	19 ce                	sbb    %ecx,%esi
  800f73:	89 f9                	mov    %edi,%ecx
  800f75:	89 f0                	mov    %esi,%eax
  800f77:	d3 e0                	shl    %cl,%eax
  800f79:	89 e9                	mov    %ebp,%ecx
  800f7b:	d3 ea                	shr    %cl,%edx
  800f7d:	89 e9                	mov    %ebp,%ecx
  800f7f:	d3 ee                	shr    %cl,%esi
  800f81:	09 d0                	or     %edx,%eax
  800f83:	89 f2                	mov    %esi,%edx
  800f85:	83 c4 1c             	add    $0x1c,%esp
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    
  800f8d:	8d 76 00             	lea    0x0(%esi),%esi
  800f90:	29 f9                	sub    %edi,%ecx
  800f92:	19 d6                	sbb    %edx,%esi
  800f94:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f98:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f9c:	e9 18 ff ff ff       	jmp    800eb9 <__umoddi3+0x69>
