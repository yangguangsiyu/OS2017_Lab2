
obj/user/faultdie：     文件格式 elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 20 10 80 00       	push   $0x801020
  80004a:	e8 1c 01 00 00       	call   80016b <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 78 0a 00 00       	call   800acc <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 2f 0a 00 00       	call   800a8b <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 48 0c 00 00       	call   800cb9 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80008b:	e8 3c 0a 00 00       	call   800acc <sys_getenvid>
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009d:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	85 db                	test   %ebx,%ebx
  8000a4:	7e 07                	jle    8000ad <libmain+0x2d>
		binaryname = argv[0];
  8000a6:	8b 06                	mov    (%esi),%eax
  8000a8:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ad:	83 ec 08             	sub    $0x8,%esp
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
  8000b2:	e8 aa ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000b7:	e8 0a 00 00 00       	call   8000c6 <exit>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000cc:	6a 00                	push   $0x0
  8000ce:	e8 b8 09 00 00       	call   800a8b <sys_env_destroy>
}
  8000d3:	83 c4 10             	add    $0x10,%esp
  8000d6:	c9                   	leave  
  8000d7:	c3                   	ret    

008000d8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 04             	sub    $0x4,%esp
  8000df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000e2:	8b 13                	mov    (%ebx),%edx
  8000e4:	8d 42 01             	lea    0x1(%edx),%eax
  8000e7:	89 03                	mov    %eax,(%ebx)
  8000e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ec:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f5:	75 1a                	jne    800111 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 ff 00 00 00       	push   $0xff
  8000ff:	8d 43 08             	lea    0x8(%ebx),%eax
  800102:	50                   	push   %eax
  800103:	e8 46 09 00 00       	call   800a4e <sys_cputs>
		b->idx = 0;
  800108:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80010e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800111:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800115:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800118:	c9                   	leave  
  800119:	c3                   	ret    

0080011a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800123:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80012a:	00 00 00 
	b.cnt = 0;
  80012d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800134:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800137:	ff 75 0c             	pushl  0xc(%ebp)
  80013a:	ff 75 08             	pushl  0x8(%ebp)
  80013d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	68 d8 00 80 00       	push   $0x8000d8
  800149:	e8 54 01 00 00       	call   8002a2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014e:	83 c4 08             	add    $0x8,%esp
  800151:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800157:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015d:	50                   	push   %eax
  80015e:	e8 eb 08 00 00       	call   800a4e <sys_cputs>

	return b.cnt;
}
  800163:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800169:	c9                   	leave  
  80016a:	c3                   	ret    

0080016b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800171:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800174:	50                   	push   %eax
  800175:	ff 75 08             	pushl  0x8(%ebp)
  800178:	e8 9d ff ff ff       	call   80011a <vcprintf>
	va_end(ap);

	return cnt;
}
  80017d:	c9                   	leave  
  80017e:	c3                   	ret    

0080017f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	57                   	push   %edi
  800183:	56                   	push   %esi
  800184:	53                   	push   %ebx
  800185:	83 ec 1c             	sub    $0x1c,%esp
  800188:	89 c7                	mov    %eax,%edi
  80018a:	89 d6                	mov    %edx,%esi
  80018c:	8b 45 08             	mov    0x8(%ebp),%eax
  80018f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800192:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800195:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800198:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80019b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001a3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001a6:	39 d3                	cmp    %edx,%ebx
  8001a8:	72 05                	jb     8001af <printnum+0x30>
  8001aa:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ad:	77 45                	ja     8001f4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001af:	83 ec 0c             	sub    $0xc,%esp
  8001b2:	ff 75 18             	pushl  0x18(%ebp)
  8001b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8001b8:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001bb:	53                   	push   %ebx
  8001bc:	ff 75 10             	pushl  0x10(%ebp)
  8001bf:	83 ec 08             	sub    $0x8,%esp
  8001c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8001c8:	ff 75 dc             	pushl  -0x24(%ebp)
  8001cb:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ce:	e8 bd 0b 00 00       	call   800d90 <__udivdi3>
  8001d3:	83 c4 18             	add    $0x18,%esp
  8001d6:	52                   	push   %edx
  8001d7:	50                   	push   %eax
  8001d8:	89 f2                	mov    %esi,%edx
  8001da:	89 f8                	mov    %edi,%eax
  8001dc:	e8 9e ff ff ff       	call   80017f <printnum>
  8001e1:	83 c4 20             	add    $0x20,%esp
  8001e4:	eb 18                	jmp    8001fe <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001e6:	83 ec 08             	sub    $0x8,%esp
  8001e9:	56                   	push   %esi
  8001ea:	ff 75 18             	pushl  0x18(%ebp)
  8001ed:	ff d7                	call   *%edi
  8001ef:	83 c4 10             	add    $0x10,%esp
  8001f2:	eb 03                	jmp    8001f7 <printnum+0x78>
  8001f4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001f7:	83 eb 01             	sub    $0x1,%ebx
  8001fa:	85 db                	test   %ebx,%ebx
  8001fc:	7f e8                	jg     8001e6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001fe:	83 ec 08             	sub    $0x8,%esp
  800201:	56                   	push   %esi
  800202:	83 ec 04             	sub    $0x4,%esp
  800205:	ff 75 e4             	pushl  -0x1c(%ebp)
  800208:	ff 75 e0             	pushl  -0x20(%ebp)
  80020b:	ff 75 dc             	pushl  -0x24(%ebp)
  80020e:	ff 75 d8             	pushl  -0x28(%ebp)
  800211:	e8 aa 0c 00 00       	call   800ec0 <__umoddi3>
  800216:	83 c4 14             	add    $0x14,%esp
  800219:	0f be 80 46 10 80 00 	movsbl 0x801046(%eax),%eax
  800220:	50                   	push   %eax
  800221:	ff d7                	call   *%edi
}
  800223:	83 c4 10             	add    $0x10,%esp
  800226:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800229:	5b                   	pop    %ebx
  80022a:	5e                   	pop    %esi
  80022b:	5f                   	pop    %edi
  80022c:	5d                   	pop    %ebp
  80022d:	c3                   	ret    

0080022e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800231:	83 fa 01             	cmp    $0x1,%edx
  800234:	7e 0e                	jle    800244 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800236:	8b 10                	mov    (%eax),%edx
  800238:	8d 4a 08             	lea    0x8(%edx),%ecx
  80023b:	89 08                	mov    %ecx,(%eax)
  80023d:	8b 02                	mov    (%edx),%eax
  80023f:	8b 52 04             	mov    0x4(%edx),%edx
  800242:	eb 22                	jmp    800266 <getuint+0x38>
	else if (lflag)
  800244:	85 d2                	test   %edx,%edx
  800246:	74 10                	je     800258 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800248:	8b 10                	mov    (%eax),%edx
  80024a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80024d:	89 08                	mov    %ecx,(%eax)
  80024f:	8b 02                	mov    (%edx),%eax
  800251:	ba 00 00 00 00       	mov    $0x0,%edx
  800256:	eb 0e                	jmp    800266 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800258:	8b 10                	mov    (%eax),%edx
  80025a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80025d:	89 08                	mov    %ecx,(%eax)
  80025f:	8b 02                	mov    (%edx),%eax
  800261:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800266:	5d                   	pop    %ebp
  800267:	c3                   	ret    

00800268 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80026e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800272:	8b 10                	mov    (%eax),%edx
  800274:	3b 50 04             	cmp    0x4(%eax),%edx
  800277:	73 0a                	jae    800283 <sprintputch+0x1b>
		*b->buf++ = ch;
  800279:	8d 4a 01             	lea    0x1(%edx),%ecx
  80027c:	89 08                	mov    %ecx,(%eax)
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	88 02                	mov    %al,(%edx)
}
  800283:	5d                   	pop    %ebp
  800284:	c3                   	ret    

00800285 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
  800288:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80028b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80028e:	50                   	push   %eax
  80028f:	ff 75 10             	pushl  0x10(%ebp)
  800292:	ff 75 0c             	pushl  0xc(%ebp)
  800295:	ff 75 08             	pushl  0x8(%ebp)
  800298:	e8 05 00 00 00       	call   8002a2 <vprintfmt>
	va_end(ap);
}
  80029d:	83 c4 10             	add    $0x10,%esp
  8002a0:	c9                   	leave  
  8002a1:	c3                   	ret    

008002a2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	57                   	push   %edi
  8002a6:	56                   	push   %esi
  8002a7:	53                   	push   %ebx
  8002a8:	83 ec 2c             	sub    $0x2c,%esp
  8002ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
  8002ae:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002b5:	eb 17                	jmp    8002ce <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002b7:	85 c0                	test   %eax,%eax
  8002b9:	0f 84 9f 03 00 00    	je     80065e <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
  8002bf:	83 ec 08             	sub    $0x8,%esp
  8002c2:	ff 75 0c             	pushl  0xc(%ebp)
  8002c5:	50                   	push   %eax
  8002c6:	ff 55 08             	call   *0x8(%ebp)
  8002c9:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002cc:	89 f3                	mov    %esi,%ebx
  8002ce:	8d 73 01             	lea    0x1(%ebx),%esi
  8002d1:	0f b6 03             	movzbl (%ebx),%eax
  8002d4:	83 f8 25             	cmp    $0x25,%eax
  8002d7:	75 de                	jne    8002b7 <vprintfmt+0x15>
  8002d9:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8002dd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002e4:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8002e9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f5:	eb 06                	jmp    8002fd <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f7:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002f9:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fd:	8d 5e 01             	lea    0x1(%esi),%ebx
  800300:	0f b6 06             	movzbl (%esi),%eax
  800303:	0f b6 c8             	movzbl %al,%ecx
  800306:	83 e8 23             	sub    $0x23,%eax
  800309:	3c 55                	cmp    $0x55,%al
  80030b:	0f 87 2d 03 00 00    	ja     80063e <vprintfmt+0x39c>
  800311:	0f b6 c0             	movzbl %al,%eax
  800314:	ff 24 85 00 11 80 00 	jmp    *0x801100(,%eax,4)
  80031b:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80031d:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800321:	eb da                	jmp    8002fd <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800323:	89 de                	mov    %ebx,%esi
  800325:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80032a:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  80032d:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  800331:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  800334:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800337:	83 f8 09             	cmp    $0x9,%eax
  80033a:	77 33                	ja     80036f <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80033c:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80033f:	eb e9                	jmp    80032a <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800341:	8b 45 14             	mov    0x14(%ebp),%eax
  800344:	8d 48 04             	lea    0x4(%eax),%ecx
  800347:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80034a:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034c:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80034e:	eb 1f                	jmp    80036f <vprintfmt+0xcd>
  800350:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800353:	85 c0                	test   %eax,%eax
  800355:	b9 00 00 00 00       	mov    $0x0,%ecx
  80035a:	0f 49 c8             	cmovns %eax,%ecx
  80035d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800360:	89 de                	mov    %ebx,%esi
  800362:	eb 99                	jmp    8002fd <vprintfmt+0x5b>
  800364:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800366:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  80036d:	eb 8e                	jmp    8002fd <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80036f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800373:	79 88                	jns    8002fd <vprintfmt+0x5b>
				width = precision, precision = -1;
  800375:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800378:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80037d:	e9 7b ff ff ff       	jmp    8002fd <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800382:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800385:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800387:	e9 71 ff ff ff       	jmp    8002fd <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
  80038c:	8b 45 14             	mov    0x14(%ebp),%eax
  80038f:	8d 50 04             	lea    0x4(%eax),%edx
  800392:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  800395:	83 ec 08             	sub    $0x8,%esp
  800398:	ff 75 0c             	pushl  0xc(%ebp)
  80039b:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80039e:	03 08                	add    (%eax),%ecx
  8003a0:	51                   	push   %ecx
  8003a1:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
  8003a4:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
  8003a7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
  8003ae:	e9 1b ff ff ff       	jmp    8002ce <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
  8003b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b6:	8d 48 04             	lea    0x4(%eax),%ecx
  8003b9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003bc:	8b 00                	mov    (%eax),%eax
  8003be:	83 f8 02             	cmp    $0x2,%eax
  8003c1:	74 1a                	je     8003dd <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c3:	89 de                	mov    %ebx,%esi
  8003c5:	83 f8 04             	cmp    $0x4,%eax
  8003c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003cd:	b9 00 04 00 00       	mov    $0x400,%ecx
  8003d2:	0f 44 c1             	cmove  %ecx,%eax
  8003d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d8:	e9 20 ff ff ff       	jmp    8002fd <vprintfmt+0x5b>
  8003dd:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
  8003df:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
  8003e6:	e9 12 ff ff ff       	jmp    8002fd <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ee:	8d 50 04             	lea    0x4(%eax),%edx
  8003f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f4:	8b 00                	mov    (%eax),%eax
  8003f6:	99                   	cltd   
  8003f7:	31 d0                	xor    %edx,%eax
  8003f9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003fb:	83 f8 09             	cmp    $0x9,%eax
  8003fe:	7f 0b                	jg     80040b <vprintfmt+0x169>
  800400:	8b 14 85 60 12 80 00 	mov    0x801260(,%eax,4),%edx
  800407:	85 d2                	test   %edx,%edx
  800409:	75 19                	jne    800424 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  80040b:	50                   	push   %eax
  80040c:	68 5e 10 80 00       	push   $0x80105e
  800411:	ff 75 0c             	pushl  0xc(%ebp)
  800414:	ff 75 08             	pushl  0x8(%ebp)
  800417:	e8 69 fe ff ff       	call   800285 <printfmt>
  80041c:	83 c4 10             	add    $0x10,%esp
  80041f:	e9 aa fe ff ff       	jmp    8002ce <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  800424:	52                   	push   %edx
  800425:	68 67 10 80 00       	push   $0x801067
  80042a:	ff 75 0c             	pushl  0xc(%ebp)
  80042d:	ff 75 08             	pushl  0x8(%ebp)
  800430:	e8 50 fe ff ff       	call   800285 <printfmt>
  800435:	83 c4 10             	add    $0x10,%esp
  800438:	e9 91 fe ff ff       	jmp    8002ce <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80043d:	8b 45 14             	mov    0x14(%ebp),%eax
  800440:	8d 50 04             	lea    0x4(%eax),%edx
  800443:	89 55 14             	mov    %edx,0x14(%ebp)
  800446:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800448:	85 f6                	test   %esi,%esi
  80044a:	b8 57 10 80 00       	mov    $0x801057,%eax
  80044f:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800452:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800456:	0f 8e 93 00 00 00    	jle    8004ef <vprintfmt+0x24d>
  80045c:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800460:	0f 84 91 00 00 00    	je     8004f7 <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	57                   	push   %edi
  80046a:	56                   	push   %esi
  80046b:	e8 76 02 00 00       	call   8006e6 <strnlen>
  800470:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800473:	29 c1                	sub    %eax,%ecx
  800475:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800478:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80047b:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  80047f:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800482:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800485:	8b 75 0c             	mov    0xc(%ebp),%esi
  800488:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80048b:	89 cb                	mov    %ecx,%ebx
  80048d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048f:	eb 0e                	jmp    80049f <vprintfmt+0x1fd>
					putch(padc, putdat);
  800491:	83 ec 08             	sub    $0x8,%esp
  800494:	56                   	push   %esi
  800495:	57                   	push   %edi
  800496:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800499:	83 eb 01             	sub    $0x1,%ebx
  80049c:	83 c4 10             	add    $0x10,%esp
  80049f:	85 db                	test   %ebx,%ebx
  8004a1:	7f ee                	jg     800491 <vprintfmt+0x1ef>
  8004a3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004a6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004a9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ac:	85 c9                	test   %ecx,%ecx
  8004ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b3:	0f 49 c1             	cmovns %ecx,%eax
  8004b6:	29 c1                	sub    %eax,%ecx
  8004b8:	89 cb                	mov    %ecx,%ebx
  8004ba:	eb 41                	jmp    8004fd <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004c0:	74 1b                	je     8004dd <vprintfmt+0x23b>
  8004c2:	0f be c0             	movsbl %al,%eax
  8004c5:	83 e8 20             	sub    $0x20,%eax
  8004c8:	83 f8 5e             	cmp    $0x5e,%eax
  8004cb:	76 10                	jbe    8004dd <vprintfmt+0x23b>
					putch('?', putdat);
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	ff 75 0c             	pushl  0xc(%ebp)
  8004d3:	6a 3f                	push   $0x3f
  8004d5:	ff 55 08             	call   *0x8(%ebp)
  8004d8:	83 c4 10             	add    $0x10,%esp
  8004db:	eb 0d                	jmp    8004ea <vprintfmt+0x248>
				else
					putch(ch, putdat);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	ff 75 0c             	pushl  0xc(%ebp)
  8004e3:	52                   	push   %edx
  8004e4:	ff 55 08             	call   *0x8(%ebp)
  8004e7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ea:	83 eb 01             	sub    $0x1,%ebx
  8004ed:	eb 0e                	jmp    8004fd <vprintfmt+0x25b>
  8004ef:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004f2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f5:	eb 06                	jmp    8004fd <vprintfmt+0x25b>
  8004f7:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004fa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004fd:	83 c6 01             	add    $0x1,%esi
  800500:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800504:	0f be d0             	movsbl %al,%edx
  800507:	85 d2                	test   %edx,%edx
  800509:	74 25                	je     800530 <vprintfmt+0x28e>
  80050b:	85 ff                	test   %edi,%edi
  80050d:	78 ad                	js     8004bc <vprintfmt+0x21a>
  80050f:	83 ef 01             	sub    $0x1,%edi
  800512:	79 a8                	jns    8004bc <vprintfmt+0x21a>
  800514:	89 d8                	mov    %ebx,%eax
  800516:	8b 75 08             	mov    0x8(%ebp),%esi
  800519:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80051c:	89 c3                	mov    %eax,%ebx
  80051e:	eb 16                	jmp    800536 <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	57                   	push   %edi
  800524:	6a 20                	push   $0x20
  800526:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800528:	83 eb 01             	sub    $0x1,%ebx
  80052b:	83 c4 10             	add    $0x10,%esp
  80052e:	eb 06                	jmp    800536 <vprintfmt+0x294>
  800530:	8b 75 08             	mov    0x8(%ebp),%esi
  800533:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800536:	85 db                	test   %ebx,%ebx
  800538:	7f e6                	jg     800520 <vprintfmt+0x27e>
  80053a:	89 75 08             	mov    %esi,0x8(%ebp)
  80053d:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800540:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800543:	e9 86 fd ff ff       	jmp    8002ce <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800548:	83 fa 01             	cmp    $0x1,%edx
  80054b:	7e 10                	jle    80055d <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 50 08             	lea    0x8(%eax),%edx
  800553:	89 55 14             	mov    %edx,0x14(%ebp)
  800556:	8b 30                	mov    (%eax),%esi
  800558:	8b 78 04             	mov    0x4(%eax),%edi
  80055b:	eb 26                	jmp    800583 <vprintfmt+0x2e1>
	else if (lflag)
  80055d:	85 d2                	test   %edx,%edx
  80055f:	74 12                	je     800573 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  800561:	8b 45 14             	mov    0x14(%ebp),%eax
  800564:	8d 50 04             	lea    0x4(%eax),%edx
  800567:	89 55 14             	mov    %edx,0x14(%ebp)
  80056a:	8b 30                	mov    (%eax),%esi
  80056c:	89 f7                	mov    %esi,%edi
  80056e:	c1 ff 1f             	sar    $0x1f,%edi
  800571:	eb 10                	jmp    800583 <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8d 50 04             	lea    0x4(%eax),%edx
  800579:	89 55 14             	mov    %edx,0x14(%ebp)
  80057c:	8b 30                	mov    (%eax),%esi
  80057e:	89 f7                	mov    %esi,%edi
  800580:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800583:	89 f0                	mov    %esi,%eax
  800585:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800587:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80058c:	85 ff                	test   %edi,%edi
  80058e:	79 7b                	jns    80060b <vprintfmt+0x369>
				putch('-', putdat);
  800590:	83 ec 08             	sub    $0x8,%esp
  800593:	ff 75 0c             	pushl  0xc(%ebp)
  800596:	6a 2d                	push   $0x2d
  800598:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80059b:	89 f0                	mov    %esi,%eax
  80059d:	89 fa                	mov    %edi,%edx
  80059f:	f7 d8                	neg    %eax
  8005a1:	83 d2 00             	adc    $0x0,%edx
  8005a4:	f7 da                	neg    %edx
  8005a6:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005a9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ae:	eb 5b                	jmp    80060b <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005b0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b3:	e8 76 fc ff ff       	call   80022e <getuint>
			base = 10;
  8005b8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005bd:	eb 4c                	jmp    80060b <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
  8005bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c2:	e8 67 fc ff ff       	call   80022e <getuint>
            base = 8;
  8005c7:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005cc:	eb 3d                	jmp    80060b <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
  8005ce:	83 ec 08             	sub    $0x8,%esp
  8005d1:	ff 75 0c             	pushl  0xc(%ebp)
  8005d4:	6a 30                	push   $0x30
  8005d6:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005d9:	83 c4 08             	add    $0x8,%esp
  8005dc:	ff 75 0c             	pushl  0xc(%ebp)
  8005df:	6a 78                	push   $0x78
  8005e1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ea:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005ed:	8b 00                	mov    (%eax),%eax
  8005ef:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005f4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005f7:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005fc:	eb 0d                	jmp    80060b <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800601:	e8 28 fc ff ff       	call   80022e <getuint>
			base = 16;
  800606:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80060b:	83 ec 0c             	sub    $0xc,%esp
  80060e:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  800612:	56                   	push   %esi
  800613:	ff 75 e0             	pushl  -0x20(%ebp)
  800616:	51                   	push   %ecx
  800617:	52                   	push   %edx
  800618:	50                   	push   %eax
  800619:	8b 55 0c             	mov    0xc(%ebp),%edx
  80061c:	8b 45 08             	mov    0x8(%ebp),%eax
  80061f:	e8 5b fb ff ff       	call   80017f <printnum>
			break;
  800624:	83 c4 20             	add    $0x20,%esp
  800627:	e9 a2 fc ff ff       	jmp    8002ce <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	ff 75 0c             	pushl  0xc(%ebp)
  800632:	51                   	push   %ecx
  800633:	ff 55 08             	call   *0x8(%ebp)
			break;
  800636:	83 c4 10             	add    $0x10,%esp
  800639:	e9 90 fc ff ff       	jmp    8002ce <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80063e:	83 ec 08             	sub    $0x8,%esp
  800641:	ff 75 0c             	pushl  0xc(%ebp)
  800644:	6a 25                	push   $0x25
  800646:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800649:	83 c4 10             	add    $0x10,%esp
  80064c:	89 f3                	mov    %esi,%ebx
  80064e:	eb 03                	jmp    800653 <vprintfmt+0x3b1>
  800650:	83 eb 01             	sub    $0x1,%ebx
  800653:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800657:	75 f7                	jne    800650 <vprintfmt+0x3ae>
  800659:	e9 70 fc ff ff       	jmp    8002ce <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  80065e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800661:	5b                   	pop    %ebx
  800662:	5e                   	pop    %esi
  800663:	5f                   	pop    %edi
  800664:	5d                   	pop    %ebp
  800665:	c3                   	ret    

00800666 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800666:	55                   	push   %ebp
  800667:	89 e5                	mov    %esp,%ebp
  800669:	83 ec 18             	sub    $0x18,%esp
  80066c:	8b 45 08             	mov    0x8(%ebp),%eax
  80066f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800672:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800675:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800679:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80067c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800683:	85 c0                	test   %eax,%eax
  800685:	74 26                	je     8006ad <vsnprintf+0x47>
  800687:	85 d2                	test   %edx,%edx
  800689:	7e 22                	jle    8006ad <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80068b:	ff 75 14             	pushl  0x14(%ebp)
  80068e:	ff 75 10             	pushl  0x10(%ebp)
  800691:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800694:	50                   	push   %eax
  800695:	68 68 02 80 00       	push   $0x800268
  80069a:	e8 03 fc ff ff       	call   8002a2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80069f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006a2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	eb 05                	jmp    8006b2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006b2:	c9                   	leave  
  8006b3:	c3                   	ret    

008006b4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ba:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006bd:	50                   	push   %eax
  8006be:	ff 75 10             	pushl  0x10(%ebp)
  8006c1:	ff 75 0c             	pushl  0xc(%ebp)
  8006c4:	ff 75 08             	pushl  0x8(%ebp)
  8006c7:	e8 9a ff ff ff       	call   800666 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006cc:	c9                   	leave  
  8006cd:	c3                   	ret    

008006ce <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d9:	eb 03                	jmp    8006de <strlen+0x10>
		n++;
  8006db:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006de:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006e2:	75 f7                	jne    8006db <strlen+0xd>
		n++;
	return n;
}
  8006e4:	5d                   	pop    %ebp
  8006e5:	c3                   	ret    

008006e6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006e6:	55                   	push   %ebp
  8006e7:	89 e5                	mov    %esp,%ebp
  8006e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8006f4:	eb 03                	jmp    8006f9 <strnlen+0x13>
		n++;
  8006f6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f9:	39 c2                	cmp    %eax,%edx
  8006fb:	74 08                	je     800705 <strnlen+0x1f>
  8006fd:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800701:	75 f3                	jne    8006f6 <strnlen+0x10>
  800703:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800705:	5d                   	pop    %ebp
  800706:	c3                   	ret    

00800707 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	53                   	push   %ebx
  80070b:	8b 45 08             	mov    0x8(%ebp),%eax
  80070e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800711:	89 c2                	mov    %eax,%edx
  800713:	83 c2 01             	add    $0x1,%edx
  800716:	83 c1 01             	add    $0x1,%ecx
  800719:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80071d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800720:	84 db                	test   %bl,%bl
  800722:	75 ef                	jne    800713 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800724:	5b                   	pop    %ebx
  800725:	5d                   	pop    %ebp
  800726:	c3                   	ret    

00800727 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	53                   	push   %ebx
  80072b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80072e:	53                   	push   %ebx
  80072f:	e8 9a ff ff ff       	call   8006ce <strlen>
  800734:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800737:	ff 75 0c             	pushl  0xc(%ebp)
  80073a:	01 d8                	add    %ebx,%eax
  80073c:	50                   	push   %eax
  80073d:	e8 c5 ff ff ff       	call   800707 <strcpy>
	return dst;
}
  800742:	89 d8                	mov    %ebx,%eax
  800744:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800747:	c9                   	leave  
  800748:	c3                   	ret    

00800749 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800749:	55                   	push   %ebp
  80074a:	89 e5                	mov    %esp,%ebp
  80074c:	56                   	push   %esi
  80074d:	53                   	push   %ebx
  80074e:	8b 75 08             	mov    0x8(%ebp),%esi
  800751:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800754:	89 f3                	mov    %esi,%ebx
  800756:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800759:	89 f2                	mov    %esi,%edx
  80075b:	eb 0f                	jmp    80076c <strncpy+0x23>
		*dst++ = *src;
  80075d:	83 c2 01             	add    $0x1,%edx
  800760:	0f b6 01             	movzbl (%ecx),%eax
  800763:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800766:	80 39 01             	cmpb   $0x1,(%ecx)
  800769:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076c:	39 da                	cmp    %ebx,%edx
  80076e:	75 ed                	jne    80075d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800770:	89 f0                	mov    %esi,%eax
  800772:	5b                   	pop    %ebx
  800773:	5e                   	pop    %esi
  800774:	5d                   	pop    %ebp
  800775:	c3                   	ret    

00800776 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	56                   	push   %esi
  80077a:	53                   	push   %ebx
  80077b:	8b 75 08             	mov    0x8(%ebp),%esi
  80077e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800781:	8b 55 10             	mov    0x10(%ebp),%edx
  800784:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800786:	85 d2                	test   %edx,%edx
  800788:	74 21                	je     8007ab <strlcpy+0x35>
  80078a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80078e:	89 f2                	mov    %esi,%edx
  800790:	eb 09                	jmp    80079b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800792:	83 c2 01             	add    $0x1,%edx
  800795:	83 c1 01             	add    $0x1,%ecx
  800798:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80079b:	39 c2                	cmp    %eax,%edx
  80079d:	74 09                	je     8007a8 <strlcpy+0x32>
  80079f:	0f b6 19             	movzbl (%ecx),%ebx
  8007a2:	84 db                	test   %bl,%bl
  8007a4:	75 ec                	jne    800792 <strlcpy+0x1c>
  8007a6:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007a8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007ab:	29 f0                	sub    %esi,%eax
}
  8007ad:	5b                   	pop    %ebx
  8007ae:	5e                   	pop    %esi
  8007af:	5d                   	pop    %ebp
  8007b0:	c3                   	ret    

008007b1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ba:	eb 06                	jmp    8007c2 <strcmp+0x11>
		p++, q++;
  8007bc:	83 c1 01             	add    $0x1,%ecx
  8007bf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007c2:	0f b6 01             	movzbl (%ecx),%eax
  8007c5:	84 c0                	test   %al,%al
  8007c7:	74 04                	je     8007cd <strcmp+0x1c>
  8007c9:	3a 02                	cmp    (%edx),%al
  8007cb:	74 ef                	je     8007bc <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007cd:	0f b6 c0             	movzbl %al,%eax
  8007d0:	0f b6 12             	movzbl (%edx),%edx
  8007d3:	29 d0                	sub    %edx,%eax
}
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	53                   	push   %ebx
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e1:	89 c3                	mov    %eax,%ebx
  8007e3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007e6:	eb 06                	jmp    8007ee <strncmp+0x17>
		n--, p++, q++;
  8007e8:	83 c0 01             	add    $0x1,%eax
  8007eb:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007ee:	39 d8                	cmp    %ebx,%eax
  8007f0:	74 15                	je     800807 <strncmp+0x30>
  8007f2:	0f b6 08             	movzbl (%eax),%ecx
  8007f5:	84 c9                	test   %cl,%cl
  8007f7:	74 04                	je     8007fd <strncmp+0x26>
  8007f9:	3a 0a                	cmp    (%edx),%cl
  8007fb:	74 eb                	je     8007e8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fd:	0f b6 00             	movzbl (%eax),%eax
  800800:	0f b6 12             	movzbl (%edx),%edx
  800803:	29 d0                	sub    %edx,%eax
  800805:	eb 05                	jmp    80080c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800807:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80080c:	5b                   	pop    %ebx
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	8b 45 08             	mov    0x8(%ebp),%eax
  800815:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800819:	eb 07                	jmp    800822 <strchr+0x13>
		if (*s == c)
  80081b:	38 ca                	cmp    %cl,%dl
  80081d:	74 0f                	je     80082e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80081f:	83 c0 01             	add    $0x1,%eax
  800822:	0f b6 10             	movzbl (%eax),%edx
  800825:	84 d2                	test   %dl,%dl
  800827:	75 f2                	jne    80081b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800829:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80082e:	5d                   	pop    %ebp
  80082f:	c3                   	ret    

00800830 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	8b 45 08             	mov    0x8(%ebp),%eax
  800836:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80083a:	eb 03                	jmp    80083f <strfind+0xf>
  80083c:	83 c0 01             	add    $0x1,%eax
  80083f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800842:	38 ca                	cmp    %cl,%dl
  800844:	74 04                	je     80084a <strfind+0x1a>
  800846:	84 d2                	test   %dl,%dl
  800848:	75 f2                	jne    80083c <strfind+0xc>
			break;
	return (char *) s;
}
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    

0080084c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	57                   	push   %edi
  800850:	56                   	push   %esi
  800851:	53                   	push   %ebx
  800852:	8b 7d 08             	mov    0x8(%ebp),%edi
  800855:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800858:	85 c9                	test   %ecx,%ecx
  80085a:	74 36                	je     800892 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80085c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800862:	75 28                	jne    80088c <memset+0x40>
  800864:	f6 c1 03             	test   $0x3,%cl
  800867:	75 23                	jne    80088c <memset+0x40>
		c &= 0xFF;
  800869:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80086d:	89 d3                	mov    %edx,%ebx
  80086f:	c1 e3 08             	shl    $0x8,%ebx
  800872:	89 d6                	mov    %edx,%esi
  800874:	c1 e6 18             	shl    $0x18,%esi
  800877:	89 d0                	mov    %edx,%eax
  800879:	c1 e0 10             	shl    $0x10,%eax
  80087c:	09 f0                	or     %esi,%eax
  80087e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800880:	89 d8                	mov    %ebx,%eax
  800882:	09 d0                	or     %edx,%eax
  800884:	c1 e9 02             	shr    $0x2,%ecx
  800887:	fc                   	cld    
  800888:	f3 ab                	rep stos %eax,%es:(%edi)
  80088a:	eb 06                	jmp    800892 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80088c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088f:	fc                   	cld    
  800890:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800892:	89 f8                	mov    %edi,%eax
  800894:	5b                   	pop    %ebx
  800895:	5e                   	pop    %esi
  800896:	5f                   	pop    %edi
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	57                   	push   %edi
  80089d:	56                   	push   %esi
  80089e:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008a7:	39 c6                	cmp    %eax,%esi
  8008a9:	73 35                	jae    8008e0 <memmove+0x47>
  8008ab:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008ae:	39 d0                	cmp    %edx,%eax
  8008b0:	73 2e                	jae    8008e0 <memmove+0x47>
		s += n;
		d += n;
  8008b2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b5:	89 d6                	mov    %edx,%esi
  8008b7:	09 fe                	or     %edi,%esi
  8008b9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008bf:	75 13                	jne    8008d4 <memmove+0x3b>
  8008c1:	f6 c1 03             	test   $0x3,%cl
  8008c4:	75 0e                	jne    8008d4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008c6:	83 ef 04             	sub    $0x4,%edi
  8008c9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008cc:	c1 e9 02             	shr    $0x2,%ecx
  8008cf:	fd                   	std    
  8008d0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d2:	eb 09                	jmp    8008dd <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008d4:	83 ef 01             	sub    $0x1,%edi
  8008d7:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008da:	fd                   	std    
  8008db:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008dd:	fc                   	cld    
  8008de:	eb 1d                	jmp    8008fd <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e0:	89 f2                	mov    %esi,%edx
  8008e2:	09 c2                	or     %eax,%edx
  8008e4:	f6 c2 03             	test   $0x3,%dl
  8008e7:	75 0f                	jne    8008f8 <memmove+0x5f>
  8008e9:	f6 c1 03             	test   $0x3,%cl
  8008ec:	75 0a                	jne    8008f8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008ee:	c1 e9 02             	shr    $0x2,%ecx
  8008f1:	89 c7                	mov    %eax,%edi
  8008f3:	fc                   	cld    
  8008f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f6:	eb 05                	jmp    8008fd <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008f8:	89 c7                	mov    %eax,%edi
  8008fa:	fc                   	cld    
  8008fb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008fd:	5e                   	pop    %esi
  8008fe:	5f                   	pop    %edi
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800904:	ff 75 10             	pushl  0x10(%ebp)
  800907:	ff 75 0c             	pushl  0xc(%ebp)
  80090a:	ff 75 08             	pushl  0x8(%ebp)
  80090d:	e8 87 ff ff ff       	call   800899 <memmove>
}
  800912:	c9                   	leave  
  800913:	c3                   	ret    

00800914 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	56                   	push   %esi
  800918:	53                   	push   %ebx
  800919:	8b 45 08             	mov    0x8(%ebp),%eax
  80091c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091f:	89 c6                	mov    %eax,%esi
  800921:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800924:	eb 1a                	jmp    800940 <memcmp+0x2c>
		if (*s1 != *s2)
  800926:	0f b6 08             	movzbl (%eax),%ecx
  800929:	0f b6 1a             	movzbl (%edx),%ebx
  80092c:	38 d9                	cmp    %bl,%cl
  80092e:	74 0a                	je     80093a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800930:	0f b6 c1             	movzbl %cl,%eax
  800933:	0f b6 db             	movzbl %bl,%ebx
  800936:	29 d8                	sub    %ebx,%eax
  800938:	eb 0f                	jmp    800949 <memcmp+0x35>
		s1++, s2++;
  80093a:	83 c0 01             	add    $0x1,%eax
  80093d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800940:	39 f0                	cmp    %esi,%eax
  800942:	75 e2                	jne    800926 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800944:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800949:	5b                   	pop    %ebx
  80094a:	5e                   	pop    %esi
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	53                   	push   %ebx
  800951:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800954:	89 c1                	mov    %eax,%ecx
  800956:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800959:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80095d:	eb 0a                	jmp    800969 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80095f:	0f b6 10             	movzbl (%eax),%edx
  800962:	39 da                	cmp    %ebx,%edx
  800964:	74 07                	je     80096d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800966:	83 c0 01             	add    $0x1,%eax
  800969:	39 c8                	cmp    %ecx,%eax
  80096b:	72 f2                	jb     80095f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80096d:	5b                   	pop    %ebx
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	57                   	push   %edi
  800974:	56                   	push   %esi
  800975:	53                   	push   %ebx
  800976:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800979:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80097c:	eb 03                	jmp    800981 <strtol+0x11>
		s++;
  80097e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800981:	0f b6 01             	movzbl (%ecx),%eax
  800984:	3c 20                	cmp    $0x20,%al
  800986:	74 f6                	je     80097e <strtol+0xe>
  800988:	3c 09                	cmp    $0x9,%al
  80098a:	74 f2                	je     80097e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80098c:	3c 2b                	cmp    $0x2b,%al
  80098e:	75 0a                	jne    80099a <strtol+0x2a>
		s++;
  800990:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800993:	bf 00 00 00 00       	mov    $0x0,%edi
  800998:	eb 11                	jmp    8009ab <strtol+0x3b>
  80099a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80099f:	3c 2d                	cmp    $0x2d,%al
  8009a1:	75 08                	jne    8009ab <strtol+0x3b>
		s++, neg = 1;
  8009a3:	83 c1 01             	add    $0x1,%ecx
  8009a6:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ab:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009b1:	75 15                	jne    8009c8 <strtol+0x58>
  8009b3:	80 39 30             	cmpb   $0x30,(%ecx)
  8009b6:	75 10                	jne    8009c8 <strtol+0x58>
  8009b8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009bc:	75 7c                	jne    800a3a <strtol+0xca>
		s += 2, base = 16;
  8009be:	83 c1 02             	add    $0x2,%ecx
  8009c1:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009c6:	eb 16                	jmp    8009de <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009c8:	85 db                	test   %ebx,%ebx
  8009ca:	75 12                	jne    8009de <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009cc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009d1:	80 39 30             	cmpb   $0x30,(%ecx)
  8009d4:	75 08                	jne    8009de <strtol+0x6e>
		s++, base = 8;
  8009d6:	83 c1 01             	add    $0x1,%ecx
  8009d9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009de:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009e6:	0f b6 11             	movzbl (%ecx),%edx
  8009e9:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009ec:	89 f3                	mov    %esi,%ebx
  8009ee:	80 fb 09             	cmp    $0x9,%bl
  8009f1:	77 08                	ja     8009fb <strtol+0x8b>
			dig = *s - '0';
  8009f3:	0f be d2             	movsbl %dl,%edx
  8009f6:	83 ea 30             	sub    $0x30,%edx
  8009f9:	eb 22                	jmp    800a1d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009fb:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009fe:	89 f3                	mov    %esi,%ebx
  800a00:	80 fb 19             	cmp    $0x19,%bl
  800a03:	77 08                	ja     800a0d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a05:	0f be d2             	movsbl %dl,%edx
  800a08:	83 ea 57             	sub    $0x57,%edx
  800a0b:	eb 10                	jmp    800a1d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a0d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a10:	89 f3                	mov    %esi,%ebx
  800a12:	80 fb 19             	cmp    $0x19,%bl
  800a15:	77 16                	ja     800a2d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a17:	0f be d2             	movsbl %dl,%edx
  800a1a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a1d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a20:	7d 0b                	jge    800a2d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a22:	83 c1 01             	add    $0x1,%ecx
  800a25:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a29:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a2b:	eb b9                	jmp    8009e6 <strtol+0x76>

	if (endptr)
  800a2d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a31:	74 0d                	je     800a40 <strtol+0xd0>
		*endptr = (char *) s;
  800a33:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a36:	89 0e                	mov    %ecx,(%esi)
  800a38:	eb 06                	jmp    800a40 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a3a:	85 db                	test   %ebx,%ebx
  800a3c:	74 98                	je     8009d6 <strtol+0x66>
  800a3e:	eb 9e                	jmp    8009de <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a40:	89 c2                	mov    %eax,%edx
  800a42:	f7 da                	neg    %edx
  800a44:	85 ff                	test   %edi,%edi
  800a46:	0f 45 c2             	cmovne %edx,%eax
}
  800a49:	5b                   	pop    %ebx
  800a4a:	5e                   	pop    %esi
  800a4b:	5f                   	pop    %edi
  800a4c:	5d                   	pop    %ebp
  800a4d:	c3                   	ret    

00800a4e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	57                   	push   %edi
  800a52:	56                   	push   %esi
  800a53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a54:	b8 00 00 00 00       	mov    $0x0,%eax
  800a59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5f:	89 c3                	mov    %eax,%ebx
  800a61:	89 c7                	mov    %eax,%edi
  800a63:	89 c6                	mov    %eax,%esi
  800a65:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a67:	5b                   	pop    %ebx
  800a68:	5e                   	pop    %esi
  800a69:	5f                   	pop    %edi
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <sys_cgetc>:

int
sys_cgetc(void)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	57                   	push   %edi
  800a70:	56                   	push   %esi
  800a71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a72:	ba 00 00 00 00       	mov    $0x0,%edx
  800a77:	b8 01 00 00 00       	mov    $0x1,%eax
  800a7c:	89 d1                	mov    %edx,%ecx
  800a7e:	89 d3                	mov    %edx,%ebx
  800a80:	89 d7                	mov    %edx,%edi
  800a82:	89 d6                	mov    %edx,%esi
  800a84:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a86:	5b                   	pop    %ebx
  800a87:	5e                   	pop    %esi
  800a88:	5f                   	pop    %edi
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	57                   	push   %edi
  800a8f:	56                   	push   %esi
  800a90:	53                   	push   %ebx
  800a91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a99:	b8 03 00 00 00       	mov    $0x3,%eax
  800a9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa1:	89 cb                	mov    %ecx,%ebx
  800aa3:	89 cf                	mov    %ecx,%edi
  800aa5:	89 ce                	mov    %ecx,%esi
  800aa7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aa9:	85 c0                	test   %eax,%eax
  800aab:	7e 17                	jle    800ac4 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aad:	83 ec 0c             	sub    $0xc,%esp
  800ab0:	50                   	push   %eax
  800ab1:	6a 03                	push   $0x3
  800ab3:	68 88 12 80 00       	push   $0x801288
  800ab8:	6a 23                	push   $0x23
  800aba:	68 a5 12 80 00       	push   $0x8012a5
  800abf:	e8 80 02 00 00       	call   800d44 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ac4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac7:	5b                   	pop    %ebx
  800ac8:	5e                   	pop    %esi
  800ac9:	5f                   	pop    %edi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	57                   	push   %edi
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad7:	b8 02 00 00 00       	mov    $0x2,%eax
  800adc:	89 d1                	mov    %edx,%ecx
  800ade:	89 d3                	mov    %edx,%ebx
  800ae0:	89 d7                	mov    %edx,%edi
  800ae2:	89 d6                	mov    %edx,%esi
  800ae4:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ae6:	5b                   	pop    %ebx
  800ae7:	5e                   	pop    %esi
  800ae8:	5f                   	pop    %edi
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <sys_yield>:

void
sys_yield(void)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	57                   	push   %edi
  800aef:	56                   	push   %esi
  800af0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af1:	ba 00 00 00 00       	mov    $0x0,%edx
  800af6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800afb:	89 d1                	mov    %edx,%ecx
  800afd:	89 d3                	mov    %edx,%ebx
  800aff:	89 d7                	mov    %edx,%edi
  800b01:	89 d6                	mov    %edx,%esi
  800b03:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5f                   	pop    %edi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	57                   	push   %edi
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
  800b10:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b13:	be 00 00 00 00       	mov    $0x0,%esi
  800b18:	b8 04 00 00 00       	mov    $0x4,%eax
  800b1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b20:	8b 55 08             	mov    0x8(%ebp),%edx
  800b23:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b26:	89 f7                	mov    %esi,%edi
  800b28:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b2a:	85 c0                	test   %eax,%eax
  800b2c:	7e 17                	jle    800b45 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2e:	83 ec 0c             	sub    $0xc,%esp
  800b31:	50                   	push   %eax
  800b32:	6a 04                	push   $0x4
  800b34:	68 88 12 80 00       	push   $0x801288
  800b39:	6a 23                	push   $0x23
  800b3b:	68 a5 12 80 00       	push   $0x8012a5
  800b40:	e8 ff 01 00 00       	call   800d44 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	53                   	push   %ebx
  800b53:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b56:	b8 05 00 00 00       	mov    $0x5,%eax
  800b5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b64:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b67:	8b 75 18             	mov    0x18(%ebp),%esi
  800b6a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b6c:	85 c0                	test   %eax,%eax
  800b6e:	7e 17                	jle    800b87 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b70:	83 ec 0c             	sub    $0xc,%esp
  800b73:	50                   	push   %eax
  800b74:	6a 05                	push   $0x5
  800b76:	68 88 12 80 00       	push   $0x801288
  800b7b:	6a 23                	push   $0x23
  800b7d:	68 a5 12 80 00       	push   $0x8012a5
  800b82:	e8 bd 01 00 00       	call   800d44 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
  800b95:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b98:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b9d:	b8 06 00 00 00       	mov    $0x6,%eax
  800ba2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba8:	89 df                	mov    %ebx,%edi
  800baa:	89 de                	mov    %ebx,%esi
  800bac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bae:	85 c0                	test   %eax,%eax
  800bb0:	7e 17                	jle    800bc9 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb2:	83 ec 0c             	sub    $0xc,%esp
  800bb5:	50                   	push   %eax
  800bb6:	6a 06                	push   $0x6
  800bb8:	68 88 12 80 00       	push   $0x801288
  800bbd:	6a 23                	push   $0x23
  800bbf:	68 a5 12 80 00       	push   $0x8012a5
  800bc4:	e8 7b 01 00 00       	call   800d44 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcc:	5b                   	pop    %ebx
  800bcd:	5e                   	pop    %esi
  800bce:	5f                   	pop    %edi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	57                   	push   %edi
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
  800bd7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bdf:	b8 08 00 00 00       	mov    $0x8,%eax
  800be4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bea:	89 df                	mov    %ebx,%edi
  800bec:	89 de                	mov    %ebx,%esi
  800bee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf0:	85 c0                	test   %eax,%eax
  800bf2:	7e 17                	jle    800c0b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf4:	83 ec 0c             	sub    $0xc,%esp
  800bf7:	50                   	push   %eax
  800bf8:	6a 08                	push   $0x8
  800bfa:	68 88 12 80 00       	push   $0x801288
  800bff:	6a 23                	push   $0x23
  800c01:	68 a5 12 80 00       	push   $0x8012a5
  800c06:	e8 39 01 00 00       	call   800d44 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5f                   	pop    %edi
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	57                   	push   %edi
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
  800c19:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c21:	b8 09 00 00 00       	mov    $0x9,%eax
  800c26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c29:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2c:	89 df                	mov    %ebx,%edi
  800c2e:	89 de                	mov    %ebx,%esi
  800c30:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c32:	85 c0                	test   %eax,%eax
  800c34:	7e 17                	jle    800c4d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c36:	83 ec 0c             	sub    $0xc,%esp
  800c39:	50                   	push   %eax
  800c3a:	6a 09                	push   $0x9
  800c3c:	68 88 12 80 00       	push   $0x801288
  800c41:	6a 23                	push   $0x23
  800c43:	68 a5 12 80 00       	push   $0x8012a5
  800c48:	e8 f7 00 00 00       	call   800d44 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5b:	be 00 00 00 00       	mov    $0x0,%esi
  800c60:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c71:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c73:	5b                   	pop    %ebx
  800c74:	5e                   	pop    %esi
  800c75:	5f                   	pop    %edi
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    

00800c78 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	57                   	push   %edi
  800c7c:	56                   	push   %esi
  800c7d:	53                   	push   %ebx
  800c7e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c81:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c86:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8e:	89 cb                	mov    %ecx,%ebx
  800c90:	89 cf                	mov    %ecx,%edi
  800c92:	89 ce                	mov    %ecx,%esi
  800c94:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c96:	85 c0                	test   %eax,%eax
  800c98:	7e 17                	jle    800cb1 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9a:	83 ec 0c             	sub    $0xc,%esp
  800c9d:	50                   	push   %eax
  800c9e:	6a 0c                	push   $0xc
  800ca0:	68 88 12 80 00       	push   $0x801288
  800ca5:	6a 23                	push   $0x23
  800ca7:	68 a5 12 80 00       	push   $0x8012a5
  800cac:	e8 93 00 00 00       	call   800d44 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5f                   	pop    %edi
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    

00800cb9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800cb9:	55                   	push   %ebp
  800cba:	89 e5                	mov    %esp,%ebp
  800cbc:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800cbf:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800cc6:	75 4c                	jne    800d14 <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.

        void *va = (void *)(UXSTACKTOP - PGSIZE);
        if (sys_page_alloc(thisenv->env_id, va, PTE_P | PTE_U | PTE_W))
  800cc8:	a1 04 20 80 00       	mov    0x802004,%eax
  800ccd:	8b 40 48             	mov    0x48(%eax),%eax
  800cd0:	83 ec 04             	sub    $0x4,%esp
  800cd3:	6a 07                	push   $0x7
  800cd5:	68 00 f0 bf ee       	push   $0xeebff000
  800cda:	50                   	push   %eax
  800cdb:	e8 2a fe ff ff       	call   800b0a <sys_page_alloc>
  800ce0:	83 c4 10             	add    $0x10,%esp
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	74 14                	je     800cfb <set_pgfault_handler+0x42>
        {
            panic("Unable to allocate memory for pgfault expected\n");
  800ce7:	83 ec 04             	sub    $0x4,%esp
  800cea:	68 b4 12 80 00       	push   $0x8012b4
  800cef:	6a 24                	push   $0x24
  800cf1:	68 e4 12 80 00       	push   $0x8012e4
  800cf6:	e8 49 00 00 00       	call   800d44 <_panic>
        }

        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800cfb:	a1 04 20 80 00       	mov    0x802004,%eax
  800d00:	8b 40 48             	mov    0x48(%eax),%eax
  800d03:	83 ec 08             	sub    $0x8,%esp
  800d06:	68 1e 0d 80 00       	push   $0x800d1e
  800d0b:	50                   	push   %eax
  800d0c:	e8 02 ff ff ff       	call   800c13 <sys_env_set_pgfault_upcall>
  800d11:	83 c4 10             	add    $0x10,%esp

		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d14:	8b 45 08             	mov    0x8(%ebp),%eax
  800d17:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d1c:	c9                   	leave  
  800d1d:	c3                   	ret    

00800d1e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d1e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d1f:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800d24:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d26:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
    movl %esp, %ebx
  800d29:	89 e3                	mov    %esp,%ebx
    // 40 is the size between utf_fault_va ~ utf_regs
    movl 40(%esp), %eax
  800d2b:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 48(%esp), %esp
  800d2f:	8b 64 24 30          	mov    0x30(%esp),%esp
    pushl %eax
  800d33:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    movl %ebx, %esp
  800d34:	89 dc                	mov    %ebx,%esp
    subl $4, 48(%esp)
  800d36:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    popl %eax
  800d3b:	58                   	pop    %eax
    popl %eax
  800d3c:	58                   	pop    %eax
    popal
  800d3d:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  800d3e:	83 c4 04             	add    $0x4,%esp
    popfl
  800d41:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp
  800d42:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  800d43:	c3                   	ret    

00800d44 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	56                   	push   %esi
  800d48:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d49:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d4c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d52:	e8 75 fd ff ff       	call   800acc <sys_getenvid>
  800d57:	83 ec 0c             	sub    $0xc,%esp
  800d5a:	ff 75 0c             	pushl  0xc(%ebp)
  800d5d:	ff 75 08             	pushl  0x8(%ebp)
  800d60:	56                   	push   %esi
  800d61:	50                   	push   %eax
  800d62:	68 f4 12 80 00       	push   $0x8012f4
  800d67:	e8 ff f3 ff ff       	call   80016b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d6c:	83 c4 18             	add    $0x18,%esp
  800d6f:	53                   	push   %ebx
  800d70:	ff 75 10             	pushl  0x10(%ebp)
  800d73:	e8 a2 f3 ff ff       	call   80011a <vcprintf>
	cprintf("\n");
  800d78:	c7 04 24 3a 10 80 00 	movl   $0x80103a,(%esp)
  800d7f:	e8 e7 f3 ff ff       	call   80016b <cprintf>
  800d84:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d87:	cc                   	int3   
  800d88:	eb fd                	jmp    800d87 <_panic+0x43>
  800d8a:	66 90                	xchg   %ax,%ax
  800d8c:	66 90                	xchg   %ax,%ax
  800d8e:	66 90                	xchg   %ax,%ax

00800d90 <__udivdi3>:
  800d90:	55                   	push   %ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	83 ec 1c             	sub    $0x1c,%esp
  800d97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800da3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800da7:	85 f6                	test   %esi,%esi
  800da9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800dad:	89 ca                	mov    %ecx,%edx
  800daf:	89 f8                	mov    %edi,%eax
  800db1:	75 3d                	jne    800df0 <__udivdi3+0x60>
  800db3:	39 cf                	cmp    %ecx,%edi
  800db5:	0f 87 c5 00 00 00    	ja     800e80 <__udivdi3+0xf0>
  800dbb:	85 ff                	test   %edi,%edi
  800dbd:	89 fd                	mov    %edi,%ebp
  800dbf:	75 0b                	jne    800dcc <__udivdi3+0x3c>
  800dc1:	b8 01 00 00 00       	mov    $0x1,%eax
  800dc6:	31 d2                	xor    %edx,%edx
  800dc8:	f7 f7                	div    %edi
  800dca:	89 c5                	mov    %eax,%ebp
  800dcc:	89 c8                	mov    %ecx,%eax
  800dce:	31 d2                	xor    %edx,%edx
  800dd0:	f7 f5                	div    %ebp
  800dd2:	89 c1                	mov    %eax,%ecx
  800dd4:	89 d8                	mov    %ebx,%eax
  800dd6:	89 cf                	mov    %ecx,%edi
  800dd8:	f7 f5                	div    %ebp
  800dda:	89 c3                	mov    %eax,%ebx
  800ddc:	89 d8                	mov    %ebx,%eax
  800dde:	89 fa                	mov    %edi,%edx
  800de0:	83 c4 1c             	add    $0x1c,%esp
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    
  800de8:	90                   	nop
  800de9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800df0:	39 ce                	cmp    %ecx,%esi
  800df2:	77 74                	ja     800e68 <__udivdi3+0xd8>
  800df4:	0f bd fe             	bsr    %esi,%edi
  800df7:	83 f7 1f             	xor    $0x1f,%edi
  800dfa:	0f 84 98 00 00 00    	je     800e98 <__udivdi3+0x108>
  800e00:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e05:	89 f9                	mov    %edi,%ecx
  800e07:	89 c5                	mov    %eax,%ebp
  800e09:	29 fb                	sub    %edi,%ebx
  800e0b:	d3 e6                	shl    %cl,%esi
  800e0d:	89 d9                	mov    %ebx,%ecx
  800e0f:	d3 ed                	shr    %cl,%ebp
  800e11:	89 f9                	mov    %edi,%ecx
  800e13:	d3 e0                	shl    %cl,%eax
  800e15:	09 ee                	or     %ebp,%esi
  800e17:	89 d9                	mov    %ebx,%ecx
  800e19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e1d:	89 d5                	mov    %edx,%ebp
  800e1f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e23:	d3 ed                	shr    %cl,%ebp
  800e25:	89 f9                	mov    %edi,%ecx
  800e27:	d3 e2                	shl    %cl,%edx
  800e29:	89 d9                	mov    %ebx,%ecx
  800e2b:	d3 e8                	shr    %cl,%eax
  800e2d:	09 c2                	or     %eax,%edx
  800e2f:	89 d0                	mov    %edx,%eax
  800e31:	89 ea                	mov    %ebp,%edx
  800e33:	f7 f6                	div    %esi
  800e35:	89 d5                	mov    %edx,%ebp
  800e37:	89 c3                	mov    %eax,%ebx
  800e39:	f7 64 24 0c          	mull   0xc(%esp)
  800e3d:	39 d5                	cmp    %edx,%ebp
  800e3f:	72 10                	jb     800e51 <__udivdi3+0xc1>
  800e41:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e45:	89 f9                	mov    %edi,%ecx
  800e47:	d3 e6                	shl    %cl,%esi
  800e49:	39 c6                	cmp    %eax,%esi
  800e4b:	73 07                	jae    800e54 <__udivdi3+0xc4>
  800e4d:	39 d5                	cmp    %edx,%ebp
  800e4f:	75 03                	jne    800e54 <__udivdi3+0xc4>
  800e51:	83 eb 01             	sub    $0x1,%ebx
  800e54:	31 ff                	xor    %edi,%edi
  800e56:	89 d8                	mov    %ebx,%eax
  800e58:	89 fa                	mov    %edi,%edx
  800e5a:	83 c4 1c             	add    $0x1c,%esp
  800e5d:	5b                   	pop    %ebx
  800e5e:	5e                   	pop    %esi
  800e5f:	5f                   	pop    %edi
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    
  800e62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e68:	31 ff                	xor    %edi,%edi
  800e6a:	31 db                	xor    %ebx,%ebx
  800e6c:	89 d8                	mov    %ebx,%eax
  800e6e:	89 fa                	mov    %edi,%edx
  800e70:	83 c4 1c             	add    $0x1c,%esp
  800e73:	5b                   	pop    %ebx
  800e74:	5e                   	pop    %esi
  800e75:	5f                   	pop    %edi
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    
  800e78:	90                   	nop
  800e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e80:	89 d8                	mov    %ebx,%eax
  800e82:	f7 f7                	div    %edi
  800e84:	31 ff                	xor    %edi,%edi
  800e86:	89 c3                	mov    %eax,%ebx
  800e88:	89 d8                	mov    %ebx,%eax
  800e8a:	89 fa                	mov    %edi,%edx
  800e8c:	83 c4 1c             	add    $0x1c,%esp
  800e8f:	5b                   	pop    %ebx
  800e90:	5e                   	pop    %esi
  800e91:	5f                   	pop    %edi
  800e92:	5d                   	pop    %ebp
  800e93:	c3                   	ret    
  800e94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e98:	39 ce                	cmp    %ecx,%esi
  800e9a:	72 0c                	jb     800ea8 <__udivdi3+0x118>
  800e9c:	31 db                	xor    %ebx,%ebx
  800e9e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800ea2:	0f 87 34 ff ff ff    	ja     800ddc <__udivdi3+0x4c>
  800ea8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800ead:	e9 2a ff ff ff       	jmp    800ddc <__udivdi3+0x4c>
  800eb2:	66 90                	xchg   %ax,%ax
  800eb4:	66 90                	xchg   %ax,%ax
  800eb6:	66 90                	xchg   %ax,%ax
  800eb8:	66 90                	xchg   %ax,%ax
  800eba:	66 90                	xchg   %ax,%ax
  800ebc:	66 90                	xchg   %ax,%ax
  800ebe:	66 90                	xchg   %ax,%ax

00800ec0 <__umoddi3>:
  800ec0:	55                   	push   %ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	53                   	push   %ebx
  800ec4:	83 ec 1c             	sub    $0x1c,%esp
  800ec7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800ecb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800ecf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ed3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ed7:	85 d2                	test   %edx,%edx
  800ed9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800edd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ee1:	89 f3                	mov    %esi,%ebx
  800ee3:	89 3c 24             	mov    %edi,(%esp)
  800ee6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eea:	75 1c                	jne    800f08 <__umoddi3+0x48>
  800eec:	39 f7                	cmp    %esi,%edi
  800eee:	76 50                	jbe    800f40 <__umoddi3+0x80>
  800ef0:	89 c8                	mov    %ecx,%eax
  800ef2:	89 f2                	mov    %esi,%edx
  800ef4:	f7 f7                	div    %edi
  800ef6:	89 d0                	mov    %edx,%eax
  800ef8:	31 d2                	xor    %edx,%edx
  800efa:	83 c4 1c             	add    $0x1c,%esp
  800efd:	5b                   	pop    %ebx
  800efe:	5e                   	pop    %esi
  800eff:	5f                   	pop    %edi
  800f00:	5d                   	pop    %ebp
  800f01:	c3                   	ret    
  800f02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f08:	39 f2                	cmp    %esi,%edx
  800f0a:	89 d0                	mov    %edx,%eax
  800f0c:	77 52                	ja     800f60 <__umoddi3+0xa0>
  800f0e:	0f bd ea             	bsr    %edx,%ebp
  800f11:	83 f5 1f             	xor    $0x1f,%ebp
  800f14:	75 5a                	jne    800f70 <__umoddi3+0xb0>
  800f16:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f1a:	0f 82 e0 00 00 00    	jb     801000 <__umoddi3+0x140>
  800f20:	39 0c 24             	cmp    %ecx,(%esp)
  800f23:	0f 86 d7 00 00 00    	jbe    801000 <__umoddi3+0x140>
  800f29:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f2d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f31:	83 c4 1c             	add    $0x1c,%esp
  800f34:	5b                   	pop    %ebx
  800f35:	5e                   	pop    %esi
  800f36:	5f                   	pop    %edi
  800f37:	5d                   	pop    %ebp
  800f38:	c3                   	ret    
  800f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f40:	85 ff                	test   %edi,%edi
  800f42:	89 fd                	mov    %edi,%ebp
  800f44:	75 0b                	jne    800f51 <__umoddi3+0x91>
  800f46:	b8 01 00 00 00       	mov    $0x1,%eax
  800f4b:	31 d2                	xor    %edx,%edx
  800f4d:	f7 f7                	div    %edi
  800f4f:	89 c5                	mov    %eax,%ebp
  800f51:	89 f0                	mov    %esi,%eax
  800f53:	31 d2                	xor    %edx,%edx
  800f55:	f7 f5                	div    %ebp
  800f57:	89 c8                	mov    %ecx,%eax
  800f59:	f7 f5                	div    %ebp
  800f5b:	89 d0                	mov    %edx,%eax
  800f5d:	eb 99                	jmp    800ef8 <__umoddi3+0x38>
  800f5f:	90                   	nop
  800f60:	89 c8                	mov    %ecx,%eax
  800f62:	89 f2                	mov    %esi,%edx
  800f64:	83 c4 1c             	add    $0x1c,%esp
  800f67:	5b                   	pop    %ebx
  800f68:	5e                   	pop    %esi
  800f69:	5f                   	pop    %edi
  800f6a:	5d                   	pop    %ebp
  800f6b:	c3                   	ret    
  800f6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f70:	8b 34 24             	mov    (%esp),%esi
  800f73:	bf 20 00 00 00       	mov    $0x20,%edi
  800f78:	89 e9                	mov    %ebp,%ecx
  800f7a:	29 ef                	sub    %ebp,%edi
  800f7c:	d3 e0                	shl    %cl,%eax
  800f7e:	89 f9                	mov    %edi,%ecx
  800f80:	89 f2                	mov    %esi,%edx
  800f82:	d3 ea                	shr    %cl,%edx
  800f84:	89 e9                	mov    %ebp,%ecx
  800f86:	09 c2                	or     %eax,%edx
  800f88:	89 d8                	mov    %ebx,%eax
  800f8a:	89 14 24             	mov    %edx,(%esp)
  800f8d:	89 f2                	mov    %esi,%edx
  800f8f:	d3 e2                	shl    %cl,%edx
  800f91:	89 f9                	mov    %edi,%ecx
  800f93:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f97:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f9b:	d3 e8                	shr    %cl,%eax
  800f9d:	89 e9                	mov    %ebp,%ecx
  800f9f:	89 c6                	mov    %eax,%esi
  800fa1:	d3 e3                	shl    %cl,%ebx
  800fa3:	89 f9                	mov    %edi,%ecx
  800fa5:	89 d0                	mov    %edx,%eax
  800fa7:	d3 e8                	shr    %cl,%eax
  800fa9:	89 e9                	mov    %ebp,%ecx
  800fab:	09 d8                	or     %ebx,%eax
  800fad:	89 d3                	mov    %edx,%ebx
  800faf:	89 f2                	mov    %esi,%edx
  800fb1:	f7 34 24             	divl   (%esp)
  800fb4:	89 d6                	mov    %edx,%esi
  800fb6:	d3 e3                	shl    %cl,%ebx
  800fb8:	f7 64 24 04          	mull   0x4(%esp)
  800fbc:	39 d6                	cmp    %edx,%esi
  800fbe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fc2:	89 d1                	mov    %edx,%ecx
  800fc4:	89 c3                	mov    %eax,%ebx
  800fc6:	72 08                	jb     800fd0 <__umoddi3+0x110>
  800fc8:	75 11                	jne    800fdb <__umoddi3+0x11b>
  800fca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800fce:	73 0b                	jae    800fdb <__umoddi3+0x11b>
  800fd0:	2b 44 24 04          	sub    0x4(%esp),%eax
  800fd4:	1b 14 24             	sbb    (%esp),%edx
  800fd7:	89 d1                	mov    %edx,%ecx
  800fd9:	89 c3                	mov    %eax,%ebx
  800fdb:	8b 54 24 08          	mov    0x8(%esp),%edx
  800fdf:	29 da                	sub    %ebx,%edx
  800fe1:	19 ce                	sbb    %ecx,%esi
  800fe3:	89 f9                	mov    %edi,%ecx
  800fe5:	89 f0                	mov    %esi,%eax
  800fe7:	d3 e0                	shl    %cl,%eax
  800fe9:	89 e9                	mov    %ebp,%ecx
  800feb:	d3 ea                	shr    %cl,%edx
  800fed:	89 e9                	mov    %ebp,%ecx
  800fef:	d3 ee                	shr    %cl,%esi
  800ff1:	09 d0                	or     %edx,%eax
  800ff3:	89 f2                	mov    %esi,%edx
  800ff5:	83 c4 1c             	add    $0x1c,%esp
  800ff8:	5b                   	pop    %ebx
  800ff9:	5e                   	pop    %esi
  800ffa:	5f                   	pop    %edi
  800ffb:	5d                   	pop    %ebp
  800ffc:	c3                   	ret    
  800ffd:	8d 76 00             	lea    0x0(%esi),%esi
  801000:	29 f9                	sub    %edi,%ecx
  801002:	19 d6                	sbb    %edx,%esi
  801004:	89 74 24 04          	mov    %esi,0x4(%esp)
  801008:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80100c:	e9 18 ff ff ff       	jmp    800f29 <__umoddi3+0x69>
