
obj/user/sfork：     文件格式 elf32-i386


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
  80002c:	e8 91 00 00 00       	call   8000c2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

uint32_t val = 0;

void umain(int argc, char* argv[])
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp
    envid_t who;
    if((who = sfork()) == 0)
  800039:	e8 a3 0f 00 00       	call   800fe1 <sfork>
  80003e:	85 c0                	test   %eax,%eax
  800040:	75 44                	jne    800086 <umain+0x53>
    {
        cprintf("in child val = %d\n", val);
  800042:	83 ec 08             	sub    $0x8,%esp
  800045:	ff 35 04 20 80 00    	pushl  0x802004
  80004b:	68 20 15 80 00       	push   $0x801520
  800050:	e8 58 01 00 00       	call   8001ad <cprintf>
        val = 2;
  800055:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  80005c:	00 00 00 
        sys_yield();
  80005f:	e8 c9 0a 00 00       	call   800b2d <sys_yield>
        cprintf("in child val = %d\n", val);
  800064:	83 c4 08             	add    $0x8,%esp
  800067:	ff 35 04 20 80 00    	pushl  0x802004
  80006d:	68 20 15 80 00       	push   $0x801520
  800072:	e8 36 01 00 00       	call   8001ad <cprintf>
        val = 10;
  800077:	c7 05 04 20 80 00 0a 	movl   $0xa,0x802004
  80007e:	00 00 00 

        return;
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	eb 3a                	jmp    8000c0 <umain+0x8d>
    }

    sys_yield();
  800086:	e8 a2 0a 00 00       	call   800b2d <sys_yield>
    cprintf("in parent  val = %d\n", val);
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	ff 35 04 20 80 00    	pushl  0x802004
  800094:	68 33 15 80 00       	push   $0x801533
  800099:	e8 0f 01 00 00       	call   8001ad <cprintf>
    val++;
  80009e:	83 05 04 20 80 00 01 	addl   $0x1,0x802004
    sys_yield();
  8000a5:	e8 83 0a 00 00       	call   800b2d <sys_yield>
    cprintf("in parent  val = %d\n", val);
  8000aa:	83 c4 08             	add    $0x8,%esp
  8000ad:	ff 35 04 20 80 00    	pushl  0x802004
  8000b3:	68 33 15 80 00       	push   $0x801533
  8000b8:	e8 f0 00 00 00       	call   8001ad <cprintf>
    return ;
  8000bd:	83 c4 10             	add    $0x10,%esp
}
  8000c0:	c9                   	leave  
  8000c1:	c3                   	ret    

008000c2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	56                   	push   %esi
  8000c6:	53                   	push   %ebx
  8000c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ca:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000cd:	e8 3c 0a 00 00       	call   800b0e <sys_getenvid>
  8000d2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000da:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000df:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e4:	85 db                	test   %ebx,%ebx
  8000e6:	7e 07                	jle    8000ef <libmain+0x2d>
		binaryname = argv[0];
  8000e8:	8b 06                	mov    (%esi),%eax
  8000ea:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ef:	83 ec 08             	sub    $0x8,%esp
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
  8000f4:	e8 3a ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f9:	e8 0a 00 00 00       	call   800108 <exit>
}
  8000fe:	83 c4 10             	add    $0x10,%esp
  800101:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800104:	5b                   	pop    %ebx
  800105:	5e                   	pop    %esi
  800106:	5d                   	pop    %ebp
  800107:	c3                   	ret    

00800108 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80010e:	6a 00                	push   $0x0
  800110:	e8 b8 09 00 00       	call   800acd <sys_env_destroy>
}
  800115:	83 c4 10             	add    $0x10,%esp
  800118:	c9                   	leave  
  800119:	c3                   	ret    

0080011a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	53                   	push   %ebx
  80011e:	83 ec 04             	sub    $0x4,%esp
  800121:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800124:	8b 13                	mov    (%ebx),%edx
  800126:	8d 42 01             	lea    0x1(%edx),%eax
  800129:	89 03                	mov    %eax,(%ebx)
  80012b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80012e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800132:	3d ff 00 00 00       	cmp    $0xff,%eax
  800137:	75 1a                	jne    800153 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800139:	83 ec 08             	sub    $0x8,%esp
  80013c:	68 ff 00 00 00       	push   $0xff
  800141:	8d 43 08             	lea    0x8(%ebx),%eax
  800144:	50                   	push   %eax
  800145:	e8 46 09 00 00       	call   800a90 <sys_cputs>
		b->idx = 0;
  80014a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800150:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800153:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800157:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800165:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80016c:	00 00 00 
	b.cnt = 0;
  80016f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800176:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800179:	ff 75 0c             	pushl  0xc(%ebp)
  80017c:	ff 75 08             	pushl  0x8(%ebp)
  80017f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800185:	50                   	push   %eax
  800186:	68 1a 01 80 00       	push   $0x80011a
  80018b:	e8 54 01 00 00       	call   8002e4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800190:	83 c4 08             	add    $0x8,%esp
  800193:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800199:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019f:	50                   	push   %eax
  8001a0:	e8 eb 08 00 00       	call   800a90 <sys_cputs>

	return b.cnt;
}
  8001a5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ab:	c9                   	leave  
  8001ac:	c3                   	ret    

008001ad <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b6:	50                   	push   %eax
  8001b7:	ff 75 08             	pushl  0x8(%ebp)
  8001ba:	e8 9d ff ff ff       	call   80015c <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bf:	c9                   	leave  
  8001c0:	c3                   	ret    

008001c1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c1:	55                   	push   %ebp
  8001c2:	89 e5                	mov    %esp,%ebp
  8001c4:	57                   	push   %edi
  8001c5:	56                   	push   %esi
  8001c6:	53                   	push   %ebx
  8001c7:	83 ec 1c             	sub    $0x1c,%esp
  8001ca:	89 c7                	mov    %eax,%edi
  8001cc:	89 d6                	mov    %edx,%esi
  8001ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001da:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001e8:	39 d3                	cmp    %edx,%ebx
  8001ea:	72 05                	jb     8001f1 <printnum+0x30>
  8001ec:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ef:	77 45                	ja     800236 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f1:	83 ec 0c             	sub    $0xc,%esp
  8001f4:	ff 75 18             	pushl  0x18(%ebp)
  8001f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8001fa:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001fd:	53                   	push   %ebx
  8001fe:	ff 75 10             	pushl  0x10(%ebp)
  800201:	83 ec 08             	sub    $0x8,%esp
  800204:	ff 75 e4             	pushl  -0x1c(%ebp)
  800207:	ff 75 e0             	pushl  -0x20(%ebp)
  80020a:	ff 75 dc             	pushl  -0x24(%ebp)
  80020d:	ff 75 d8             	pushl  -0x28(%ebp)
  800210:	e8 6b 10 00 00       	call   801280 <__udivdi3>
  800215:	83 c4 18             	add    $0x18,%esp
  800218:	52                   	push   %edx
  800219:	50                   	push   %eax
  80021a:	89 f2                	mov    %esi,%edx
  80021c:	89 f8                	mov    %edi,%eax
  80021e:	e8 9e ff ff ff       	call   8001c1 <printnum>
  800223:	83 c4 20             	add    $0x20,%esp
  800226:	eb 18                	jmp    800240 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800228:	83 ec 08             	sub    $0x8,%esp
  80022b:	56                   	push   %esi
  80022c:	ff 75 18             	pushl  0x18(%ebp)
  80022f:	ff d7                	call   *%edi
  800231:	83 c4 10             	add    $0x10,%esp
  800234:	eb 03                	jmp    800239 <printnum+0x78>
  800236:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800239:	83 eb 01             	sub    $0x1,%ebx
  80023c:	85 db                	test   %ebx,%ebx
  80023e:	7f e8                	jg     800228 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800240:	83 ec 08             	sub    $0x8,%esp
  800243:	56                   	push   %esi
  800244:	83 ec 04             	sub    $0x4,%esp
  800247:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024a:	ff 75 e0             	pushl  -0x20(%ebp)
  80024d:	ff 75 dc             	pushl  -0x24(%ebp)
  800250:	ff 75 d8             	pushl  -0x28(%ebp)
  800253:	e8 58 11 00 00       	call   8013b0 <__umoddi3>
  800258:	83 c4 14             	add    $0x14,%esp
  80025b:	0f be 80 52 15 80 00 	movsbl 0x801552(%eax),%eax
  800262:	50                   	push   %eax
  800263:	ff d7                	call   *%edi
}
  800265:	83 c4 10             	add    $0x10,%esp
  800268:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026b:	5b                   	pop    %ebx
  80026c:	5e                   	pop    %esi
  80026d:	5f                   	pop    %edi
  80026e:	5d                   	pop    %ebp
  80026f:	c3                   	ret    

00800270 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800273:	83 fa 01             	cmp    $0x1,%edx
  800276:	7e 0e                	jle    800286 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800278:	8b 10                	mov    (%eax),%edx
  80027a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80027d:	89 08                	mov    %ecx,(%eax)
  80027f:	8b 02                	mov    (%edx),%eax
  800281:	8b 52 04             	mov    0x4(%edx),%edx
  800284:	eb 22                	jmp    8002a8 <getuint+0x38>
	else if (lflag)
  800286:	85 d2                	test   %edx,%edx
  800288:	74 10                	je     80029a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80028a:	8b 10                	mov    (%eax),%edx
  80028c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028f:	89 08                	mov    %ecx,(%eax)
  800291:	8b 02                	mov    (%edx),%eax
  800293:	ba 00 00 00 00       	mov    $0x0,%edx
  800298:	eb 0e                	jmp    8002a8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80029a:	8b 10                	mov    (%eax),%edx
  80029c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029f:	89 08                	mov    %ecx,(%eax)
  8002a1:	8b 02                	mov    (%edx),%eax
  8002a3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a8:	5d                   	pop    %ebp
  8002a9:	c3                   	ret    

008002aa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b4:	8b 10                	mov    (%eax),%edx
  8002b6:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b9:	73 0a                	jae    8002c5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002bb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002be:	89 08                	mov    %ecx,(%eax)
  8002c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c3:	88 02                	mov    %al,(%edx)
}
  8002c5:	5d                   	pop    %ebp
  8002c6:	c3                   	ret    

008002c7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c7:	55                   	push   %ebp
  8002c8:	89 e5                	mov    %esp,%ebp
  8002ca:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002cd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d0:	50                   	push   %eax
  8002d1:	ff 75 10             	pushl  0x10(%ebp)
  8002d4:	ff 75 0c             	pushl  0xc(%ebp)
  8002d7:	ff 75 08             	pushl  0x8(%ebp)
  8002da:	e8 05 00 00 00       	call   8002e4 <vprintfmt>
	va_end(ap);
}
  8002df:	83 c4 10             	add    $0x10,%esp
  8002e2:	c9                   	leave  
  8002e3:	c3                   	ret    

008002e4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	57                   	push   %edi
  8002e8:	56                   	push   %esi
  8002e9:	53                   	push   %ebx
  8002ea:	83 ec 2c             	sub    $0x2c,%esp
  8002ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
  8002f0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002f7:	eb 17                	jmp    800310 <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f9:	85 c0                	test   %eax,%eax
  8002fb:	0f 84 9f 03 00 00    	je     8006a0 <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
  800301:	83 ec 08             	sub    $0x8,%esp
  800304:	ff 75 0c             	pushl  0xc(%ebp)
  800307:	50                   	push   %eax
  800308:	ff 55 08             	call   *0x8(%ebp)
  80030b:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030e:	89 f3                	mov    %esi,%ebx
  800310:	8d 73 01             	lea    0x1(%ebx),%esi
  800313:	0f b6 03             	movzbl (%ebx),%eax
  800316:	83 f8 25             	cmp    $0x25,%eax
  800319:	75 de                	jne    8002f9 <vprintfmt+0x15>
  80031b:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80031f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800326:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80032b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800332:	ba 00 00 00 00       	mov    $0x0,%edx
  800337:	eb 06                	jmp    80033f <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800339:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80033b:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033f:	8d 5e 01             	lea    0x1(%esi),%ebx
  800342:	0f b6 06             	movzbl (%esi),%eax
  800345:	0f b6 c8             	movzbl %al,%ecx
  800348:	83 e8 23             	sub    $0x23,%eax
  80034b:	3c 55                	cmp    $0x55,%al
  80034d:	0f 87 2d 03 00 00    	ja     800680 <vprintfmt+0x39c>
  800353:	0f b6 c0             	movzbl %al,%eax
  800356:	ff 24 85 20 16 80 00 	jmp    *0x801620(,%eax,4)
  80035d:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80035f:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800363:	eb da                	jmp    80033f <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800365:	89 de                	mov    %ebx,%esi
  800367:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80036c:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  80036f:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  800373:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  800376:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800379:	83 f8 09             	cmp    $0x9,%eax
  80037c:	77 33                	ja     8003b1 <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80037e:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800381:	eb e9                	jmp    80036c <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800383:	8b 45 14             	mov    0x14(%ebp),%eax
  800386:	8d 48 04             	lea    0x4(%eax),%ecx
  800389:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80038c:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800390:	eb 1f                	jmp    8003b1 <vprintfmt+0xcd>
  800392:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800395:	85 c0                	test   %eax,%eax
  800397:	b9 00 00 00 00       	mov    $0x0,%ecx
  80039c:	0f 49 c8             	cmovns %eax,%ecx
  80039f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a2:	89 de                	mov    %ebx,%esi
  8003a4:	eb 99                	jmp    80033f <vprintfmt+0x5b>
  8003a6:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003a8:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  8003af:	eb 8e                	jmp    80033f <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8003b1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b5:	79 88                	jns    80033f <vprintfmt+0x5b>
				width = precision, precision = -1;
  8003b7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8003ba:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003bf:	e9 7b ff ff ff       	jmp    80033f <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c4:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c7:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003c9:	e9 71 ff ff ff       	jmp    80033f <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
  8003ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d1:	8d 50 04             	lea    0x4(%eax),%edx
  8003d4:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  8003d7:	83 ec 08             	sub    $0x8,%esp
  8003da:	ff 75 0c             	pushl  0xc(%ebp)
  8003dd:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8003e0:	03 08                	add    (%eax),%ecx
  8003e2:	51                   	push   %ecx
  8003e3:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
  8003e6:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
  8003e9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
  8003f0:	e9 1b ff ff ff       	jmp    800310 <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
  8003f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f8:	8d 48 04             	lea    0x4(%eax),%ecx
  8003fb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003fe:	8b 00                	mov    (%eax),%eax
  800400:	83 f8 02             	cmp    $0x2,%eax
  800403:	74 1a                	je     80041f <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800405:	89 de                	mov    %ebx,%esi
  800407:	83 f8 04             	cmp    $0x4,%eax
  80040a:	b8 00 00 00 00       	mov    $0x0,%eax
  80040f:	b9 00 04 00 00       	mov    $0x400,%ecx
  800414:	0f 44 c1             	cmove  %ecx,%eax
  800417:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80041a:	e9 20 ff ff ff       	jmp    80033f <vprintfmt+0x5b>
  80041f:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
  800421:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
  800428:	e9 12 ff ff ff       	jmp    80033f <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80042d:	8b 45 14             	mov    0x14(%ebp),%eax
  800430:	8d 50 04             	lea    0x4(%eax),%edx
  800433:	89 55 14             	mov    %edx,0x14(%ebp)
  800436:	8b 00                	mov    (%eax),%eax
  800438:	99                   	cltd   
  800439:	31 d0                	xor    %edx,%eax
  80043b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80043d:	83 f8 09             	cmp    $0x9,%eax
  800440:	7f 0b                	jg     80044d <vprintfmt+0x169>
  800442:	8b 14 85 80 17 80 00 	mov    0x801780(,%eax,4),%edx
  800449:	85 d2                	test   %edx,%edx
  80044b:	75 19                	jne    800466 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  80044d:	50                   	push   %eax
  80044e:	68 6a 15 80 00       	push   $0x80156a
  800453:	ff 75 0c             	pushl  0xc(%ebp)
  800456:	ff 75 08             	pushl  0x8(%ebp)
  800459:	e8 69 fe ff ff       	call   8002c7 <printfmt>
  80045e:	83 c4 10             	add    $0x10,%esp
  800461:	e9 aa fe ff ff       	jmp    800310 <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  800466:	52                   	push   %edx
  800467:	68 73 15 80 00       	push   $0x801573
  80046c:	ff 75 0c             	pushl  0xc(%ebp)
  80046f:	ff 75 08             	pushl  0x8(%ebp)
  800472:	e8 50 fe ff ff       	call   8002c7 <printfmt>
  800477:	83 c4 10             	add    $0x10,%esp
  80047a:	e9 91 fe ff ff       	jmp    800310 <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80047f:	8b 45 14             	mov    0x14(%ebp),%eax
  800482:	8d 50 04             	lea    0x4(%eax),%edx
  800485:	89 55 14             	mov    %edx,0x14(%ebp)
  800488:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80048a:	85 f6                	test   %esi,%esi
  80048c:	b8 63 15 80 00       	mov    $0x801563,%eax
  800491:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800494:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800498:	0f 8e 93 00 00 00    	jle    800531 <vprintfmt+0x24d>
  80049e:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004a2:	0f 84 91 00 00 00    	je     800539 <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	57                   	push   %edi
  8004ac:	56                   	push   %esi
  8004ad:	e8 76 02 00 00       	call   800728 <strnlen>
  8004b2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b5:	29 c1                	sub    %eax,%ecx
  8004b7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004ba:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004bd:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8004c1:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004c4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004ca:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004cd:	89 cb                	mov    %ecx,%ebx
  8004cf:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d1:	eb 0e                	jmp    8004e1 <vprintfmt+0x1fd>
					putch(padc, putdat);
  8004d3:	83 ec 08             	sub    $0x8,%esp
  8004d6:	56                   	push   %esi
  8004d7:	57                   	push   %edi
  8004d8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004db:	83 eb 01             	sub    $0x1,%ebx
  8004de:	83 c4 10             	add    $0x10,%esp
  8004e1:	85 db                	test   %ebx,%ebx
  8004e3:	7f ee                	jg     8004d3 <vprintfmt+0x1ef>
  8004e5:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004e8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004eb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ee:	85 c9                	test   %ecx,%ecx
  8004f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f5:	0f 49 c1             	cmovns %ecx,%eax
  8004f8:	29 c1                	sub    %eax,%ecx
  8004fa:	89 cb                	mov    %ecx,%ebx
  8004fc:	eb 41                	jmp    80053f <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004fe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800502:	74 1b                	je     80051f <vprintfmt+0x23b>
  800504:	0f be c0             	movsbl %al,%eax
  800507:	83 e8 20             	sub    $0x20,%eax
  80050a:	83 f8 5e             	cmp    $0x5e,%eax
  80050d:	76 10                	jbe    80051f <vprintfmt+0x23b>
					putch('?', putdat);
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	ff 75 0c             	pushl  0xc(%ebp)
  800515:	6a 3f                	push   $0x3f
  800517:	ff 55 08             	call   *0x8(%ebp)
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	eb 0d                	jmp    80052c <vprintfmt+0x248>
				else
					putch(ch, putdat);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	ff 75 0c             	pushl  0xc(%ebp)
  800525:	52                   	push   %edx
  800526:	ff 55 08             	call   *0x8(%ebp)
  800529:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052c:	83 eb 01             	sub    $0x1,%ebx
  80052f:	eb 0e                	jmp    80053f <vprintfmt+0x25b>
  800531:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800534:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800537:	eb 06                	jmp    80053f <vprintfmt+0x25b>
  800539:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80053c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80053f:	83 c6 01             	add    $0x1,%esi
  800542:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800546:	0f be d0             	movsbl %al,%edx
  800549:	85 d2                	test   %edx,%edx
  80054b:	74 25                	je     800572 <vprintfmt+0x28e>
  80054d:	85 ff                	test   %edi,%edi
  80054f:	78 ad                	js     8004fe <vprintfmt+0x21a>
  800551:	83 ef 01             	sub    $0x1,%edi
  800554:	79 a8                	jns    8004fe <vprintfmt+0x21a>
  800556:	89 d8                	mov    %ebx,%eax
  800558:	8b 75 08             	mov    0x8(%ebp),%esi
  80055b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80055e:	89 c3                	mov    %eax,%ebx
  800560:	eb 16                	jmp    800578 <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800562:	83 ec 08             	sub    $0x8,%esp
  800565:	57                   	push   %edi
  800566:	6a 20                	push   $0x20
  800568:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80056a:	83 eb 01             	sub    $0x1,%ebx
  80056d:	83 c4 10             	add    $0x10,%esp
  800570:	eb 06                	jmp    800578 <vprintfmt+0x294>
  800572:	8b 75 08             	mov    0x8(%ebp),%esi
  800575:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800578:	85 db                	test   %ebx,%ebx
  80057a:	7f e6                	jg     800562 <vprintfmt+0x27e>
  80057c:	89 75 08             	mov    %esi,0x8(%ebp)
  80057f:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800582:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800585:	e9 86 fd ff ff       	jmp    800310 <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80058a:	83 fa 01             	cmp    $0x1,%edx
  80058d:	7e 10                	jle    80059f <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
  80058f:	8b 45 14             	mov    0x14(%ebp),%eax
  800592:	8d 50 08             	lea    0x8(%eax),%edx
  800595:	89 55 14             	mov    %edx,0x14(%ebp)
  800598:	8b 30                	mov    (%eax),%esi
  80059a:	8b 78 04             	mov    0x4(%eax),%edi
  80059d:	eb 26                	jmp    8005c5 <vprintfmt+0x2e1>
	else if (lflag)
  80059f:	85 d2                	test   %edx,%edx
  8005a1:	74 12                	je     8005b5 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8d 50 04             	lea    0x4(%eax),%edx
  8005a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ac:	8b 30                	mov    (%eax),%esi
  8005ae:	89 f7                	mov    %esi,%edi
  8005b0:	c1 ff 1f             	sar    $0x1f,%edi
  8005b3:	eb 10                	jmp    8005c5 <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8d 50 04             	lea    0x4(%eax),%edx
  8005bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005be:	8b 30                	mov    (%eax),%esi
  8005c0:	89 f7                	mov    %esi,%edi
  8005c2:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005c5:	89 f0                	mov    %esi,%eax
  8005c7:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ce:	85 ff                	test   %edi,%edi
  8005d0:	79 7b                	jns    80064d <vprintfmt+0x369>
				putch('-', putdat);
  8005d2:	83 ec 08             	sub    $0x8,%esp
  8005d5:	ff 75 0c             	pushl  0xc(%ebp)
  8005d8:	6a 2d                	push   $0x2d
  8005da:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005dd:	89 f0                	mov    %esi,%eax
  8005df:	89 fa                	mov    %edi,%edx
  8005e1:	f7 d8                	neg    %eax
  8005e3:	83 d2 00             	adc    $0x0,%edx
  8005e6:	f7 da                	neg    %edx
  8005e8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005eb:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005f0:	eb 5b                	jmp    80064d <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f5:	e8 76 fc ff ff       	call   800270 <getuint>
			base = 10;
  8005fa:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005ff:	eb 4c                	jmp    80064d <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
  800601:	8d 45 14             	lea    0x14(%ebp),%eax
  800604:	e8 67 fc ff ff       	call   800270 <getuint>
            base = 8;
  800609:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80060e:	eb 3d                	jmp    80064d <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
  800610:	83 ec 08             	sub    $0x8,%esp
  800613:	ff 75 0c             	pushl  0xc(%ebp)
  800616:	6a 30                	push   $0x30
  800618:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80061b:	83 c4 08             	add    $0x8,%esp
  80061e:	ff 75 0c             	pushl  0xc(%ebp)
  800621:	6a 78                	push   $0x78
  800623:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8d 50 04             	lea    0x4(%eax),%edx
  80062c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80062f:	8b 00                	mov    (%eax),%eax
  800631:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800636:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800639:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80063e:	eb 0d                	jmp    80064d <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800640:	8d 45 14             	lea    0x14(%ebp),%eax
  800643:	e8 28 fc ff ff       	call   800270 <getuint>
			base = 16;
  800648:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80064d:	83 ec 0c             	sub    $0xc,%esp
  800650:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  800654:	56                   	push   %esi
  800655:	ff 75 e0             	pushl  -0x20(%ebp)
  800658:	51                   	push   %ecx
  800659:	52                   	push   %edx
  80065a:	50                   	push   %eax
  80065b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80065e:	8b 45 08             	mov    0x8(%ebp),%eax
  800661:	e8 5b fb ff ff       	call   8001c1 <printnum>
			break;
  800666:	83 c4 20             	add    $0x20,%esp
  800669:	e9 a2 fc ff ff       	jmp    800310 <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80066e:	83 ec 08             	sub    $0x8,%esp
  800671:	ff 75 0c             	pushl  0xc(%ebp)
  800674:	51                   	push   %ecx
  800675:	ff 55 08             	call   *0x8(%ebp)
			break;
  800678:	83 c4 10             	add    $0x10,%esp
  80067b:	e9 90 fc ff ff       	jmp    800310 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800680:	83 ec 08             	sub    $0x8,%esp
  800683:	ff 75 0c             	pushl  0xc(%ebp)
  800686:	6a 25                	push   $0x25
  800688:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80068b:	83 c4 10             	add    $0x10,%esp
  80068e:	89 f3                	mov    %esi,%ebx
  800690:	eb 03                	jmp    800695 <vprintfmt+0x3b1>
  800692:	83 eb 01             	sub    $0x1,%ebx
  800695:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800699:	75 f7                	jne    800692 <vprintfmt+0x3ae>
  80069b:	e9 70 fc ff ff       	jmp    800310 <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  8006a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006a3:	5b                   	pop    %ebx
  8006a4:	5e                   	pop    %esi
  8006a5:	5f                   	pop    %edi
  8006a6:	5d                   	pop    %ebp
  8006a7:	c3                   	ret    

008006a8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006a8:	55                   	push   %ebp
  8006a9:	89 e5                	mov    %esp,%ebp
  8006ab:	83 ec 18             	sub    $0x18,%esp
  8006ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006b7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006bb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006c5:	85 c0                	test   %eax,%eax
  8006c7:	74 26                	je     8006ef <vsnprintf+0x47>
  8006c9:	85 d2                	test   %edx,%edx
  8006cb:	7e 22                	jle    8006ef <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006cd:	ff 75 14             	pushl  0x14(%ebp)
  8006d0:	ff 75 10             	pushl  0x10(%ebp)
  8006d3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006d6:	50                   	push   %eax
  8006d7:	68 aa 02 80 00       	push   $0x8002aa
  8006dc:	e8 03 fc ff ff       	call   8002e4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006e4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ea:	83 c4 10             	add    $0x10,%esp
  8006ed:	eb 05                	jmp    8006f4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006f4:	c9                   	leave  
  8006f5:	c3                   	ret    

008006f6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006fc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ff:	50                   	push   %eax
  800700:	ff 75 10             	pushl  0x10(%ebp)
  800703:	ff 75 0c             	pushl  0xc(%ebp)
  800706:	ff 75 08             	pushl  0x8(%ebp)
  800709:	e8 9a ff ff ff       	call   8006a8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80070e:	c9                   	leave  
  80070f:	c3                   	ret    

00800710 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800716:	b8 00 00 00 00       	mov    $0x0,%eax
  80071b:	eb 03                	jmp    800720 <strlen+0x10>
		n++;
  80071d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800720:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800724:	75 f7                	jne    80071d <strlen+0xd>
		n++;
	return n;
}
  800726:	5d                   	pop    %ebp
  800727:	c3                   	ret    

00800728 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80072e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800731:	ba 00 00 00 00       	mov    $0x0,%edx
  800736:	eb 03                	jmp    80073b <strnlen+0x13>
		n++;
  800738:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073b:	39 c2                	cmp    %eax,%edx
  80073d:	74 08                	je     800747 <strnlen+0x1f>
  80073f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800743:	75 f3                	jne    800738 <strnlen+0x10>
  800745:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800747:	5d                   	pop    %ebp
  800748:	c3                   	ret    

00800749 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800749:	55                   	push   %ebp
  80074a:	89 e5                	mov    %esp,%ebp
  80074c:	53                   	push   %ebx
  80074d:	8b 45 08             	mov    0x8(%ebp),%eax
  800750:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800753:	89 c2                	mov    %eax,%edx
  800755:	83 c2 01             	add    $0x1,%edx
  800758:	83 c1 01             	add    $0x1,%ecx
  80075b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80075f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800762:	84 db                	test   %bl,%bl
  800764:	75 ef                	jne    800755 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800766:	5b                   	pop    %ebx
  800767:	5d                   	pop    %ebp
  800768:	c3                   	ret    

00800769 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800769:	55                   	push   %ebp
  80076a:	89 e5                	mov    %esp,%ebp
  80076c:	53                   	push   %ebx
  80076d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800770:	53                   	push   %ebx
  800771:	e8 9a ff ff ff       	call   800710 <strlen>
  800776:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800779:	ff 75 0c             	pushl  0xc(%ebp)
  80077c:	01 d8                	add    %ebx,%eax
  80077e:	50                   	push   %eax
  80077f:	e8 c5 ff ff ff       	call   800749 <strcpy>
	return dst;
}
  800784:	89 d8                	mov    %ebx,%eax
  800786:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800789:	c9                   	leave  
  80078a:	c3                   	ret    

0080078b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	56                   	push   %esi
  80078f:	53                   	push   %ebx
  800790:	8b 75 08             	mov    0x8(%ebp),%esi
  800793:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800796:	89 f3                	mov    %esi,%ebx
  800798:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079b:	89 f2                	mov    %esi,%edx
  80079d:	eb 0f                	jmp    8007ae <strncpy+0x23>
		*dst++ = *src;
  80079f:	83 c2 01             	add    $0x1,%edx
  8007a2:	0f b6 01             	movzbl (%ecx),%eax
  8007a5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007a8:	80 39 01             	cmpb   $0x1,(%ecx)
  8007ab:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ae:	39 da                	cmp    %ebx,%edx
  8007b0:	75 ed                	jne    80079f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007b2:	89 f0                	mov    %esi,%eax
  8007b4:	5b                   	pop    %ebx
  8007b5:	5e                   	pop    %esi
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	56                   	push   %esi
  8007bc:	53                   	push   %ebx
  8007bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c3:	8b 55 10             	mov    0x10(%ebp),%edx
  8007c6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c8:	85 d2                	test   %edx,%edx
  8007ca:	74 21                	je     8007ed <strlcpy+0x35>
  8007cc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007d0:	89 f2                	mov    %esi,%edx
  8007d2:	eb 09                	jmp    8007dd <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007d4:	83 c2 01             	add    $0x1,%edx
  8007d7:	83 c1 01             	add    $0x1,%ecx
  8007da:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007dd:	39 c2                	cmp    %eax,%edx
  8007df:	74 09                	je     8007ea <strlcpy+0x32>
  8007e1:	0f b6 19             	movzbl (%ecx),%ebx
  8007e4:	84 db                	test   %bl,%bl
  8007e6:	75 ec                	jne    8007d4 <strlcpy+0x1c>
  8007e8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007ea:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007ed:	29 f0                	sub    %esi,%eax
}
  8007ef:	5b                   	pop    %ebx
  8007f0:	5e                   	pop    %esi
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007fc:	eb 06                	jmp    800804 <strcmp+0x11>
		p++, q++;
  8007fe:	83 c1 01             	add    $0x1,%ecx
  800801:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800804:	0f b6 01             	movzbl (%ecx),%eax
  800807:	84 c0                	test   %al,%al
  800809:	74 04                	je     80080f <strcmp+0x1c>
  80080b:	3a 02                	cmp    (%edx),%al
  80080d:	74 ef                	je     8007fe <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80080f:	0f b6 c0             	movzbl %al,%eax
  800812:	0f b6 12             	movzbl (%edx),%edx
  800815:	29 d0                	sub    %edx,%eax
}
  800817:	5d                   	pop    %ebp
  800818:	c3                   	ret    

00800819 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	53                   	push   %ebx
  80081d:	8b 45 08             	mov    0x8(%ebp),%eax
  800820:	8b 55 0c             	mov    0xc(%ebp),%edx
  800823:	89 c3                	mov    %eax,%ebx
  800825:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800828:	eb 06                	jmp    800830 <strncmp+0x17>
		n--, p++, q++;
  80082a:	83 c0 01             	add    $0x1,%eax
  80082d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800830:	39 d8                	cmp    %ebx,%eax
  800832:	74 15                	je     800849 <strncmp+0x30>
  800834:	0f b6 08             	movzbl (%eax),%ecx
  800837:	84 c9                	test   %cl,%cl
  800839:	74 04                	je     80083f <strncmp+0x26>
  80083b:	3a 0a                	cmp    (%edx),%cl
  80083d:	74 eb                	je     80082a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80083f:	0f b6 00             	movzbl (%eax),%eax
  800842:	0f b6 12             	movzbl (%edx),%edx
  800845:	29 d0                	sub    %edx,%eax
  800847:	eb 05                	jmp    80084e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800849:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80084e:	5b                   	pop    %ebx
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	8b 45 08             	mov    0x8(%ebp),%eax
  800857:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80085b:	eb 07                	jmp    800864 <strchr+0x13>
		if (*s == c)
  80085d:	38 ca                	cmp    %cl,%dl
  80085f:	74 0f                	je     800870 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800861:	83 c0 01             	add    $0x1,%eax
  800864:	0f b6 10             	movzbl (%eax),%edx
  800867:	84 d2                	test   %dl,%dl
  800869:	75 f2                	jne    80085d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80086b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	8b 45 08             	mov    0x8(%ebp),%eax
  800878:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80087c:	eb 03                	jmp    800881 <strfind+0xf>
  80087e:	83 c0 01             	add    $0x1,%eax
  800881:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800884:	38 ca                	cmp    %cl,%dl
  800886:	74 04                	je     80088c <strfind+0x1a>
  800888:	84 d2                	test   %dl,%dl
  80088a:	75 f2                	jne    80087e <strfind+0xc>
			break;
	return (char *) s;
}
  80088c:	5d                   	pop    %ebp
  80088d:	c3                   	ret    

0080088e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	57                   	push   %edi
  800892:	56                   	push   %esi
  800893:	53                   	push   %ebx
  800894:	8b 7d 08             	mov    0x8(%ebp),%edi
  800897:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80089a:	85 c9                	test   %ecx,%ecx
  80089c:	74 36                	je     8008d4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80089e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008a4:	75 28                	jne    8008ce <memset+0x40>
  8008a6:	f6 c1 03             	test   $0x3,%cl
  8008a9:	75 23                	jne    8008ce <memset+0x40>
		c &= 0xFF;
  8008ab:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008af:	89 d3                	mov    %edx,%ebx
  8008b1:	c1 e3 08             	shl    $0x8,%ebx
  8008b4:	89 d6                	mov    %edx,%esi
  8008b6:	c1 e6 18             	shl    $0x18,%esi
  8008b9:	89 d0                	mov    %edx,%eax
  8008bb:	c1 e0 10             	shl    $0x10,%eax
  8008be:	09 f0                	or     %esi,%eax
  8008c0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008c2:	89 d8                	mov    %ebx,%eax
  8008c4:	09 d0                	or     %edx,%eax
  8008c6:	c1 e9 02             	shr    $0x2,%ecx
  8008c9:	fc                   	cld    
  8008ca:	f3 ab                	rep stos %eax,%es:(%edi)
  8008cc:	eb 06                	jmp    8008d4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d1:	fc                   	cld    
  8008d2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008d4:	89 f8                	mov    %edi,%eax
  8008d6:	5b                   	pop    %ebx
  8008d7:	5e                   	pop    %esi
  8008d8:	5f                   	pop    %edi
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	57                   	push   %edi
  8008df:	56                   	push   %esi
  8008e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008e9:	39 c6                	cmp    %eax,%esi
  8008eb:	73 35                	jae    800922 <memmove+0x47>
  8008ed:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008f0:	39 d0                	cmp    %edx,%eax
  8008f2:	73 2e                	jae    800922 <memmove+0x47>
		s += n;
		d += n;
  8008f4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f7:	89 d6                	mov    %edx,%esi
  8008f9:	09 fe                	or     %edi,%esi
  8008fb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800901:	75 13                	jne    800916 <memmove+0x3b>
  800903:	f6 c1 03             	test   $0x3,%cl
  800906:	75 0e                	jne    800916 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800908:	83 ef 04             	sub    $0x4,%edi
  80090b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80090e:	c1 e9 02             	shr    $0x2,%ecx
  800911:	fd                   	std    
  800912:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800914:	eb 09                	jmp    80091f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800916:	83 ef 01             	sub    $0x1,%edi
  800919:	8d 72 ff             	lea    -0x1(%edx),%esi
  80091c:	fd                   	std    
  80091d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80091f:	fc                   	cld    
  800920:	eb 1d                	jmp    80093f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800922:	89 f2                	mov    %esi,%edx
  800924:	09 c2                	or     %eax,%edx
  800926:	f6 c2 03             	test   $0x3,%dl
  800929:	75 0f                	jne    80093a <memmove+0x5f>
  80092b:	f6 c1 03             	test   $0x3,%cl
  80092e:	75 0a                	jne    80093a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800930:	c1 e9 02             	shr    $0x2,%ecx
  800933:	89 c7                	mov    %eax,%edi
  800935:	fc                   	cld    
  800936:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800938:	eb 05                	jmp    80093f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80093a:	89 c7                	mov    %eax,%edi
  80093c:	fc                   	cld    
  80093d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80093f:	5e                   	pop    %esi
  800940:	5f                   	pop    %edi
  800941:	5d                   	pop    %ebp
  800942:	c3                   	ret    

00800943 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800946:	ff 75 10             	pushl  0x10(%ebp)
  800949:	ff 75 0c             	pushl  0xc(%ebp)
  80094c:	ff 75 08             	pushl  0x8(%ebp)
  80094f:	e8 87 ff ff ff       	call   8008db <memmove>
}
  800954:	c9                   	leave  
  800955:	c3                   	ret    

00800956 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	56                   	push   %esi
  80095a:	53                   	push   %ebx
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
  80095e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800961:	89 c6                	mov    %eax,%esi
  800963:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800966:	eb 1a                	jmp    800982 <memcmp+0x2c>
		if (*s1 != *s2)
  800968:	0f b6 08             	movzbl (%eax),%ecx
  80096b:	0f b6 1a             	movzbl (%edx),%ebx
  80096e:	38 d9                	cmp    %bl,%cl
  800970:	74 0a                	je     80097c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800972:	0f b6 c1             	movzbl %cl,%eax
  800975:	0f b6 db             	movzbl %bl,%ebx
  800978:	29 d8                	sub    %ebx,%eax
  80097a:	eb 0f                	jmp    80098b <memcmp+0x35>
		s1++, s2++;
  80097c:	83 c0 01             	add    $0x1,%eax
  80097f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800982:	39 f0                	cmp    %esi,%eax
  800984:	75 e2                	jne    800968 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800986:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80098b:	5b                   	pop    %ebx
  80098c:	5e                   	pop    %esi
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    

0080098f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	53                   	push   %ebx
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800996:	89 c1                	mov    %eax,%ecx
  800998:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80099b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80099f:	eb 0a                	jmp    8009ab <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a1:	0f b6 10             	movzbl (%eax),%edx
  8009a4:	39 da                	cmp    %ebx,%edx
  8009a6:	74 07                	je     8009af <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009a8:	83 c0 01             	add    $0x1,%eax
  8009ab:	39 c8                	cmp    %ecx,%eax
  8009ad:	72 f2                	jb     8009a1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009af:	5b                   	pop    %ebx
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	57                   	push   %edi
  8009b6:	56                   	push   %esi
  8009b7:	53                   	push   %ebx
  8009b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009be:	eb 03                	jmp    8009c3 <strtol+0x11>
		s++;
  8009c0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c3:	0f b6 01             	movzbl (%ecx),%eax
  8009c6:	3c 20                	cmp    $0x20,%al
  8009c8:	74 f6                	je     8009c0 <strtol+0xe>
  8009ca:	3c 09                	cmp    $0x9,%al
  8009cc:	74 f2                	je     8009c0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ce:	3c 2b                	cmp    $0x2b,%al
  8009d0:	75 0a                	jne    8009dc <strtol+0x2a>
		s++;
  8009d2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009d5:	bf 00 00 00 00       	mov    $0x0,%edi
  8009da:	eb 11                	jmp    8009ed <strtol+0x3b>
  8009dc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009e1:	3c 2d                	cmp    $0x2d,%al
  8009e3:	75 08                	jne    8009ed <strtol+0x3b>
		s++, neg = 1;
  8009e5:	83 c1 01             	add    $0x1,%ecx
  8009e8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ed:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009f3:	75 15                	jne    800a0a <strtol+0x58>
  8009f5:	80 39 30             	cmpb   $0x30,(%ecx)
  8009f8:	75 10                	jne    800a0a <strtol+0x58>
  8009fa:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009fe:	75 7c                	jne    800a7c <strtol+0xca>
		s += 2, base = 16;
  800a00:	83 c1 02             	add    $0x2,%ecx
  800a03:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a08:	eb 16                	jmp    800a20 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a0a:	85 db                	test   %ebx,%ebx
  800a0c:	75 12                	jne    800a20 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a0e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a13:	80 39 30             	cmpb   $0x30,(%ecx)
  800a16:	75 08                	jne    800a20 <strtol+0x6e>
		s++, base = 8;
  800a18:	83 c1 01             	add    $0x1,%ecx
  800a1b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a20:	b8 00 00 00 00       	mov    $0x0,%eax
  800a25:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a28:	0f b6 11             	movzbl (%ecx),%edx
  800a2b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a2e:	89 f3                	mov    %esi,%ebx
  800a30:	80 fb 09             	cmp    $0x9,%bl
  800a33:	77 08                	ja     800a3d <strtol+0x8b>
			dig = *s - '0';
  800a35:	0f be d2             	movsbl %dl,%edx
  800a38:	83 ea 30             	sub    $0x30,%edx
  800a3b:	eb 22                	jmp    800a5f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a3d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a40:	89 f3                	mov    %esi,%ebx
  800a42:	80 fb 19             	cmp    $0x19,%bl
  800a45:	77 08                	ja     800a4f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a47:	0f be d2             	movsbl %dl,%edx
  800a4a:	83 ea 57             	sub    $0x57,%edx
  800a4d:	eb 10                	jmp    800a5f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a4f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a52:	89 f3                	mov    %esi,%ebx
  800a54:	80 fb 19             	cmp    $0x19,%bl
  800a57:	77 16                	ja     800a6f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a59:	0f be d2             	movsbl %dl,%edx
  800a5c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a5f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a62:	7d 0b                	jge    800a6f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a64:	83 c1 01             	add    $0x1,%ecx
  800a67:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a6b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a6d:	eb b9                	jmp    800a28 <strtol+0x76>

	if (endptr)
  800a6f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a73:	74 0d                	je     800a82 <strtol+0xd0>
		*endptr = (char *) s;
  800a75:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a78:	89 0e                	mov    %ecx,(%esi)
  800a7a:	eb 06                	jmp    800a82 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a7c:	85 db                	test   %ebx,%ebx
  800a7e:	74 98                	je     800a18 <strtol+0x66>
  800a80:	eb 9e                	jmp    800a20 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a82:	89 c2                	mov    %eax,%edx
  800a84:	f7 da                	neg    %edx
  800a86:	85 ff                	test   %edi,%edi
  800a88:	0f 45 c2             	cmovne %edx,%eax
}
  800a8b:	5b                   	pop    %ebx
  800a8c:	5e                   	pop    %esi
  800a8d:	5f                   	pop    %edi
  800a8e:	5d                   	pop    %ebp
  800a8f:	c3                   	ret    

00800a90 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	57                   	push   %edi
  800a94:	56                   	push   %esi
  800a95:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a96:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa1:	89 c3                	mov    %eax,%ebx
  800aa3:	89 c7                	mov    %eax,%edi
  800aa5:	89 c6                	mov    %eax,%esi
  800aa7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aa9:	5b                   	pop    %ebx
  800aaa:	5e                   	pop    %esi
  800aab:	5f                   	pop    %edi
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    

00800aae <sys_cgetc>:

int
sys_cgetc(void)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	57                   	push   %edi
  800ab2:	56                   	push   %esi
  800ab3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab9:	b8 01 00 00 00       	mov    $0x1,%eax
  800abe:	89 d1                	mov    %edx,%ecx
  800ac0:	89 d3                	mov    %edx,%ebx
  800ac2:	89 d7                	mov    %edx,%edi
  800ac4:	89 d6                	mov    %edx,%esi
  800ac6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5f                   	pop    %edi
  800acb:	5d                   	pop    %ebp
  800acc:	c3                   	ret    

00800acd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	57                   	push   %edi
  800ad1:	56                   	push   %esi
  800ad2:	53                   	push   %ebx
  800ad3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800adb:	b8 03 00 00 00       	mov    $0x3,%eax
  800ae0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae3:	89 cb                	mov    %ecx,%ebx
  800ae5:	89 cf                	mov    %ecx,%edi
  800ae7:	89 ce                	mov    %ecx,%esi
  800ae9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aeb:	85 c0                	test   %eax,%eax
  800aed:	7e 17                	jle    800b06 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aef:	83 ec 0c             	sub    $0xc,%esp
  800af2:	50                   	push   %eax
  800af3:	6a 03                	push   $0x3
  800af5:	68 a8 17 80 00       	push   $0x8017a8
  800afa:	6a 23                	push   $0x23
  800afc:	68 c5 17 80 00       	push   $0x8017c5
  800b01:	e8 9b 06 00 00       	call   8011a1 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b09:	5b                   	pop    %ebx
  800b0a:	5e                   	pop    %esi
  800b0b:	5f                   	pop    %edi
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    

00800b0e <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800b19:	b8 02 00 00 00       	mov    $0x2,%eax
  800b1e:	89 d1                	mov    %edx,%ecx
  800b20:	89 d3                	mov    %edx,%ebx
  800b22:	89 d7                	mov    %edx,%edi
  800b24:	89 d6                	mov    %edx,%esi
  800b26:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b28:	5b                   	pop    %ebx
  800b29:	5e                   	pop    %esi
  800b2a:	5f                   	pop    %edi
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <sys_yield>:

void
sys_yield(void)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	57                   	push   %edi
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b33:	ba 00 00 00 00       	mov    $0x0,%edx
  800b38:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b3d:	89 d1                	mov    %edx,%ecx
  800b3f:	89 d3                	mov    %edx,%ebx
  800b41:	89 d7                	mov    %edx,%edi
  800b43:	89 d6                	mov    %edx,%esi
  800b45:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b47:	5b                   	pop    %ebx
  800b48:	5e                   	pop    %esi
  800b49:	5f                   	pop    %edi
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
  800b52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b55:	be 00 00 00 00       	mov    $0x0,%esi
  800b5a:	b8 04 00 00 00       	mov    $0x4,%eax
  800b5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b62:	8b 55 08             	mov    0x8(%ebp),%edx
  800b65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b68:	89 f7                	mov    %esi,%edi
  800b6a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b6c:	85 c0                	test   %eax,%eax
  800b6e:	7e 17                	jle    800b87 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b70:	83 ec 0c             	sub    $0xc,%esp
  800b73:	50                   	push   %eax
  800b74:	6a 04                	push   $0x4
  800b76:	68 a8 17 80 00       	push   $0x8017a8
  800b7b:	6a 23                	push   $0x23
  800b7d:	68 c5 17 80 00       	push   $0x8017c5
  800b82:	e8 1a 06 00 00       	call   8011a1 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800b98:	b8 05 00 00 00       	mov    $0x5,%eax
  800b9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ba9:	8b 75 18             	mov    0x18(%ebp),%esi
  800bac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bae:	85 c0                	test   %eax,%eax
  800bb0:	7e 17                	jle    800bc9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb2:	83 ec 0c             	sub    $0xc,%esp
  800bb5:	50                   	push   %eax
  800bb6:	6a 05                	push   $0x5
  800bb8:	68 a8 17 80 00       	push   $0x8017a8
  800bbd:	6a 23                	push   $0x23
  800bbf:	68 c5 17 80 00       	push   $0x8017c5
  800bc4:	e8 d8 05 00 00       	call   8011a1 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcc:	5b                   	pop    %ebx
  800bcd:	5e                   	pop    %esi
  800bce:	5f                   	pop    %edi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800bdf:	b8 06 00 00 00       	mov    $0x6,%eax
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
  800bf2:	7e 17                	jle    800c0b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf4:	83 ec 0c             	sub    $0xc,%esp
  800bf7:	50                   	push   %eax
  800bf8:	6a 06                	push   $0x6
  800bfa:	68 a8 17 80 00       	push   $0x8017a8
  800bff:	6a 23                	push   $0x23
  800c01:	68 c5 17 80 00       	push   $0x8017c5
  800c06:	e8 96 05 00 00       	call   8011a1 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5f                   	pop    %edi
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800c21:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800c34:	7e 17                	jle    800c4d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c36:	83 ec 0c             	sub    $0xc,%esp
  800c39:	50                   	push   %eax
  800c3a:	6a 08                	push   $0x8
  800c3c:	68 a8 17 80 00       	push   $0x8017a8
  800c41:	6a 23                	push   $0x23
  800c43:	68 c5 17 80 00       	push   $0x8017c5
  800c48:	e8 54 05 00 00       	call   8011a1 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c63:	b8 09 00 00 00       	mov    $0x9,%eax
  800c68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6e:	89 df                	mov    %ebx,%edi
  800c70:	89 de                	mov    %ebx,%esi
  800c72:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c74:	85 c0                	test   %eax,%eax
  800c76:	7e 17                	jle    800c8f <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c78:	83 ec 0c             	sub    $0xc,%esp
  800c7b:	50                   	push   %eax
  800c7c:	6a 09                	push   $0x9
  800c7e:	68 a8 17 80 00       	push   $0x8017a8
  800c83:	6a 23                	push   $0x23
  800c85:	68 c5 17 80 00       	push   $0x8017c5
  800c8a:	e8 12 05 00 00       	call   8011a1 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9d:	be 00 00 00 00       	mov    $0x0,%esi
  800ca2:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    

00800cba <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	57                   	push   %edi
  800cbe:	56                   	push   %esi
  800cbf:	53                   	push   %ebx
  800cc0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ccd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd0:	89 cb                	mov    %ecx,%ebx
  800cd2:	89 cf                	mov    %ecx,%edi
  800cd4:	89 ce                	mov    %ecx,%esi
  800cd6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd8:	85 c0                	test   %eax,%eax
  800cda:	7e 17                	jle    800cf3 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdc:	83 ec 0c             	sub    $0xc,%esp
  800cdf:	50                   	push   %eax
  800ce0:	6a 0c                	push   $0xc
  800ce2:	68 a8 17 80 00       	push   $0x8017a8
  800ce7:	6a 23                	push   $0x23
  800ce9:	68 c5 17 80 00       	push   $0x8017c5
  800cee:	e8 ae 04 00 00       	call   8011a1 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf6:	5b                   	pop    %ebx
  800cf7:	5e                   	pop    %esi
  800cf8:	5f                   	pop    %edi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	57                   	push   %edi
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
  800d01:	83 ec 0c             	sub    $0xc,%esp
  800d04:	89 c7                	mov    %eax,%edi
  800d06:	89 d3                	mov    %edx,%ebx
	int r;

	// LAB 4: Your code here.

    envid_t myenvid = sys_getenvid();
  800d08:	e8 01 fe ff ff       	call   800b0e <sys_getenvid>
  800d0d:	89 c6                	mov    %eax,%esi
    pte_t pte = uvpt[pn];
  800d0f:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    int perm;

    perm = PTE_U | PTE_P;
    if(pte & PTE_W || pte & PTE_COW)
  800d16:	a9 02 08 00 00       	test   $0x802,%eax
  800d1b:	75 40                	jne    800d5d <duppage+0x62>
    {
        perm |= PTE_COW;
    }

    // map to envid VA
    if ((r = sys_page_map(myenvid,
  800d1d:	c1 e3 0c             	shl    $0xc,%ebx
  800d20:	83 ec 0c             	sub    $0xc,%esp
  800d23:	6a 05                	push   $0x5
  800d25:	53                   	push   %ebx
  800d26:	57                   	push   %edi
  800d27:	53                   	push   %ebx
  800d28:	56                   	push   %esi
  800d29:	e8 61 fe ff ff       	call   800b8f <sys_page_map>
  800d2e:	83 c4 20             	add    $0x20,%esp
  800d31:	85 c0                	test   %eax,%eax
  800d33:	ba 00 00 00 00       	mov    $0x0,%edx
  800d38:	0f 4f c2             	cmovg  %edx,%eax
  800d3b:	eb 3b                	jmp    800d78 <duppage+0x7d>
    }

    // if COW remap to self
    if(perm & PTE_COW)
    {
        if((r = sys_page_map(myenvid, 
  800d3d:	83 ec 0c             	sub    $0xc,%esp
  800d40:	68 05 08 00 00       	push   $0x805
  800d45:	53                   	push   %ebx
  800d46:	56                   	push   %esi
  800d47:	53                   	push   %ebx
  800d48:	56                   	push   %esi
  800d49:	e8 41 fe ff ff       	call   800b8f <sys_page_map>
  800d4e:	83 c4 20             	add    $0x20,%esp
  800d51:	85 c0                	test   %eax,%eax
  800d53:	ba 00 00 00 00       	mov    $0x0,%edx
  800d58:	0f 4f c2             	cmovg  %edx,%eax
  800d5b:	eb 1b                	jmp    800d78 <duppage+0x7d>
    {
        perm |= PTE_COW;
    }

    // map to envid VA
    if ((r = sys_page_map(myenvid,
  800d5d:	c1 e3 0c             	shl    $0xc,%ebx
  800d60:	83 ec 0c             	sub    $0xc,%esp
  800d63:	68 05 08 00 00       	push   $0x805
  800d68:	53                   	push   %ebx
  800d69:	57                   	push   %edi
  800d6a:	53                   	push   %ebx
  800d6b:	56                   	push   %esi
  800d6c:	e8 1e fe ff ff       	call   800b8f <sys_page_map>
  800d71:	83 c4 20             	add    $0x20,%esp
  800d74:	85 c0                	test   %eax,%eax
  800d76:	79 c5                	jns    800d3d <duppage+0x42>
            return r;
        }
    }

	return 0;
}
  800d78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7b:	5b                   	pop    %ebx
  800d7c:	5e                   	pop    %esi
  800d7d:	5f                   	pop    %edi
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    

00800d80 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	56                   	push   %esi
  800d84:	53                   	push   %ebx
  800d85:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d88:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

    if ((err & FEC_WR) == 0)
  800d8a:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d8e:	75 12                	jne    800da2 <pgfault+0x22>
    {
        panic("pgfault: page fault was not caused by write; %x.\n", utf->utf_fault_va);
  800d90:	53                   	push   %ebx
  800d91:	68 d4 17 80 00       	push   $0x8017d4
  800d96:	6a 1f                	push   $0x1f
  800d98:	68 ab 18 80 00       	push   $0x8018ab
  800d9d:	e8 ff 03 00 00       	call   8011a1 <_panic>
    }

    if ((uvpt[PGNUM(addr)] & PTE_COW) == 0) 
  800da2:	89 d8                	mov    %ebx,%eax
  800da4:	c1 e8 0c             	shr    $0xc,%eax
  800da7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dae:	f6 c4 08             	test   $0x8,%ah
  800db1:	75 12                	jne    800dc5 <pgfault+0x45>
    {
        panic("pgfault: page fault on page which is not COW %x.\n", utf->utf_fault_va);
  800db3:	53                   	push   %ebx
  800db4:	68 08 18 80 00       	push   $0x801808
  800db9:	6a 24                	push   $0x24
  800dbb:	68 ab 18 80 00       	push   $0x8018ab
  800dc0:	e8 dc 03 00 00       	call   8011a1 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    envid_t envid = sys_getenvid();
  800dc5:	e8 44 fd ff ff       	call   800b0e <sys_getenvid>
  800dca:	89 c6                	mov    %eax,%esi

    //allocate temp page
    if (sys_page_alloc(envid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  800dcc:	83 ec 04             	sub    $0x4,%esp
  800dcf:	6a 07                	push   $0x7
  800dd1:	68 00 f0 7f 00       	push   $0x7ff000
  800dd6:	50                   	push   %eax
  800dd7:	e8 70 fd ff ff       	call   800b4c <sys_page_alloc>
  800ddc:	83 c4 10             	add    $0x10,%esp
  800ddf:	85 c0                	test   %eax,%eax
  800de1:	79 14                	jns    800df7 <pgfault+0x77>
    {
        panic("pgfault: can't allocate temp page.\n");
  800de3:	83 ec 04             	sub    $0x4,%esp
  800de6:	68 3c 18 80 00       	push   $0x80183c
  800deb:	6a 32                	push   $0x32
  800ded:	68 ab 18 80 00       	push   $0x8018ab
  800df2:	e8 aa 03 00 00       	call   8011a1 <_panic>
    }

    memmove(PFTEMP, (void *)ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800df7:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800dfd:	83 ec 04             	sub    $0x4,%esp
  800e00:	68 00 10 00 00       	push   $0x1000
  800e05:	53                   	push   %ebx
  800e06:	68 00 f0 7f 00       	push   $0x7ff000
  800e0b:	e8 cb fa ff ff       	call   8008db <memmove>

    if(sys_page_map(envid, PFTEMP, envid, (void *)ROUNDDOWN(addr, PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
  800e10:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e17:	53                   	push   %ebx
  800e18:	56                   	push   %esi
  800e19:	68 00 f0 7f 00       	push   $0x7ff000
  800e1e:	56                   	push   %esi
  800e1f:	e8 6b fd ff ff       	call   800b8f <sys_page_map>
  800e24:	83 c4 20             	add    $0x20,%esp
  800e27:	85 c0                	test   %eax,%eax
  800e29:	79 14                	jns    800e3f <pgfault+0xbf>
    {
        panic("pgfault: can't map temp page to old page.\n");
  800e2b:	83 ec 04             	sub    $0x4,%esp
  800e2e:	68 60 18 80 00       	push   $0x801860
  800e33:	6a 39                	push   $0x39
  800e35:	68 ab 18 80 00       	push   $0x8018ab
  800e3a:	e8 62 03 00 00       	call   8011a1 <_panic>
    }

    if(sys_page_unmap(envid, PFTEMP) < 0)
  800e3f:	83 ec 08             	sub    $0x8,%esp
  800e42:	68 00 f0 7f 00       	push   $0x7ff000
  800e47:	56                   	push   %esi
  800e48:	e8 84 fd ff ff       	call   800bd1 <sys_page_unmap>
  800e4d:	83 c4 10             	add    $0x10,%esp
  800e50:	85 c0                	test   %eax,%eax
  800e52:	79 14                	jns    800e68 <pgfault+0xe8>
    {
        panic("pgfault: couldn't unmap page.\n");
  800e54:	83 ec 04             	sub    $0x4,%esp
  800e57:	68 8c 18 80 00       	push   $0x80188c
  800e5c:	6a 3e                	push   $0x3e
  800e5e:	68 ab 18 80 00       	push   $0x8018ab
  800e63:	e8 39 03 00 00       	call   8011a1 <_panic>
    }
	//panic("pgfault not implemented");
}
  800e68:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e6b:	5b                   	pop    %ebx
  800e6c:	5e                   	pop    %esi
  800e6d:	5d                   	pop    %ebp
  800e6e:	c3                   	ret    

00800e6f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	57                   	push   %edi
  800e73:	56                   	push   %esi
  800e74:	53                   	push   %ebx
  800e75:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    extern void _pgfault_upcall(void);
    envid_t myenvid = sys_getenvid();
  800e78:	e8 91 fc ff ff       	call   800b0e <sys_getenvid>
  800e7d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    envid_t envid;
    uint32_t i, j, pn;

    //set page fault handler
    set_pgfault_handler(pgfault);
  800e80:	83 ec 0c             	sub    $0xc,%esp
  800e83:	68 80 0d 80 00       	push   $0x800d80
  800e88:	e8 5a 03 00 00       	call   8011e7 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e8d:	b8 07 00 00 00       	mov    $0x7,%eax
  800e92:	cd 30                	int    $0x30
  800e94:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e97:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    //create a child
    if((envid = sys_exofork()) < 0)
  800e9a:	83 c4 10             	add    $0x10,%esp
  800e9d:	85 c0                	test   %eax,%eax
  800e9f:	0f 88 13 01 00 00    	js     800fb8 <fork+0x149>
  800ea5:	bf 02 00 00 00       	mov    $0x2,%edi
    {
        return -1;
    }

    if(envid == 0)
  800eaa:	85 c0                	test   %eax,%eax
  800eac:	75 21                	jne    800ecf <fork+0x60>
    {
        thisenv = &envs[ENVX(sys_getenvid())];
  800eae:	e8 5b fc ff ff       	call   800b0e <sys_getenvid>
  800eb3:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eb8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ebb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ec0:	a3 08 20 80 00       	mov    %eax,0x802008

        return envid;
  800ec5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eca:	e9 0a 01 00 00       	jmp    800fd9 <fork+0x16a>
    }

    //copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
  800ecf:	8b 04 bd 00 d0 7b ef 	mov    -0x10843000(,%edi,4),%eax
  800ed6:	a8 01                	test   $0x1,%al
  800ed8:	74 3a                	je     800f14 <fork+0xa5>
        {
            for (j = 0; j < NPTENTRIES; j++)
            {
                pn = PGNUM(PGADDR(i, j, 0));
  800eda:	89 fe                	mov    %edi,%esi
  800edc:	c1 e6 16             	shl    $0x16,%esi
  800edf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee4:	89 da                	mov    %ebx,%edx
  800ee6:	c1 e2 0c             	shl    $0xc,%edx
  800ee9:	09 f2                	or     %esi,%edx
  800eeb:	c1 ea 0c             	shr    $0xc,%edx
                if(pn == PGNUM(UXSTACKTOP - PGSIZE))
  800eee:	81 fa ff eb 0e 00    	cmp    $0xeebff,%edx
  800ef4:	74 1e                	je     800f14 <fork+0xa5>
                {
                    break;
                }

                if(uvpt[pn] & PTE_P)
  800ef6:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800efd:	a8 01                	test   $0x1,%al
  800eff:	74 08                	je     800f09 <fork+0x9a>
                {
                    duppage(envid, pn);
  800f01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f04:	e8 f2 fd ff ff       	call   800cfb <duppage>
    //copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
        {
            for (j = 0; j < NPTENTRIES; j++)
  800f09:	83 c3 01             	add    $0x1,%ebx
  800f0c:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  800f12:	75 d0                	jne    800ee4 <fork+0x75>

        return envid;
    }

    //copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
  800f14:	83 c7 01             	add    $0x1,%edi
  800f17:	81 ff bb 03 00 00    	cmp    $0x3bb,%edi
  800f1d:	75 b0                	jne    800ecf <fork+0x60>
                }
            }
        }
    }

    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
  800f1f:	83 ec 04             	sub    $0x4,%esp
  800f22:	6a 07                	push   $0x7
  800f24:	68 00 f0 bf ee       	push   $0xeebff000
  800f29:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800f2c:	57                   	push   %edi
  800f2d:	e8 1a fc ff ff       	call   800b4c <sys_page_alloc>
  800f32:	83 c4 10             	add    $0x10,%esp
  800f35:	85 c0                	test   %eax,%eax
  800f37:	0f 88 82 00 00 00    	js     800fbf <fork+0x150>
    {
        return -1;
    }

    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  800f3d:	83 ec 0c             	sub    $0xc,%esp
  800f40:	6a 07                	push   $0x7
  800f42:	68 00 f0 7f 00       	push   $0x7ff000
  800f47:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800f4a:	56                   	push   %esi
  800f4b:	68 00 f0 bf ee       	push   $0xeebff000
  800f50:	57                   	push   %edi
  800f51:	e8 39 fc ff ff       	call   800b8f <sys_page_map>
  800f56:	83 c4 20             	add    $0x20,%esp
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	78 69                	js     800fc6 <fork+0x157>
    {
        return -1;
    }

    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);
  800f5d:	83 ec 04             	sub    $0x4,%esp
  800f60:	68 00 10 00 00       	push   $0x1000
  800f65:	68 00 f0 7f 00       	push   $0x7ff000
  800f6a:	68 00 f0 bf ee       	push   $0xeebff000
  800f6f:	e8 67 f9 ff ff       	call   8008db <memmove>

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
  800f74:	83 c4 08             	add    $0x8,%esp
  800f77:	68 00 f0 7f 00       	push   $0x7ff000
  800f7c:	56                   	push   %esi
  800f7d:	e8 4f fc ff ff       	call   800bd1 <sys_page_unmap>
  800f82:	83 c4 10             	add    $0x10,%esp
  800f85:	85 c0                	test   %eax,%eax
  800f87:	78 44                	js     800fcd <fork+0x15e>
    {
        return -1;
    }

    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
  800f89:	83 ec 08             	sub    $0x8,%esp
  800f8c:	68 4c 12 80 00       	push   $0x80124c
  800f91:	57                   	push   %edi
  800f92:	e8 be fc ff ff       	call   800c55 <sys_env_set_pgfault_upcall>
  800f97:	83 c4 10             	add    $0x10,%esp
  800f9a:	85 c0                	test   %eax,%eax
  800f9c:	78 36                	js     800fd4 <fork+0x165>
    {
        return -1;
    }

    if(sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  800f9e:	83 ec 08             	sub    $0x8,%esp
  800fa1:	6a 02                	push   $0x2
  800fa3:	57                   	push   %edi
  800fa4:	e8 6a fc ff ff       	call   800c13 <sys_env_set_status>
  800fa9:	83 c4 10             	add    $0x10,%esp
    {
        return -1;
    }

    return envid;
  800fac:	85 c0                	test   %eax,%eax
  800fae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800fb3:	0f 49 c7             	cmovns %edi,%eax
  800fb6:	eb 21                	jmp    800fd9 <fork+0x16a>
    set_pgfault_handler(pgfault);

    //create a child
    if((envid = sys_exofork()) < 0)
    {
        return -1;
  800fb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800fbd:	eb 1a                	jmp    800fd9 <fork+0x16a>
        }
    }

    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  800fbf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800fc4:	eb 13                	jmp    800fd9 <fork+0x16a>
    }

    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  800fc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800fcb:	eb 0c                	jmp    800fd9 <fork+0x16a>

    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
    {
        return -1;
  800fcd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800fd2:	eb 05                	jmp    800fd9 <fork+0x16a>
    }

    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
    {
        return -1;
  800fd4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
        return -1;
    }

    return envid;
    //	panic("fork not implemented");
}
  800fd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fdc:	5b                   	pop    %ebx
  800fdd:	5e                   	pop    %esi
  800fde:	5f                   	pop    %edi
  800fdf:	5d                   	pop    %ebp
  800fe0:	c3                   	ret    

00800fe1 <sfork>:

// Challenge!
int
sfork(void)
{
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	57                   	push   %edi
  800fe5:	56                   	push   %esi
  800fe6:	53                   	push   %ebx
  800fe7:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    extern void _pgfault_upcall(void);
    envid_t myenvid = sys_getenvid();
  800fea:	e8 1f fb ff ff       	call   800b0e <sys_getenvid>
  800fef:	89 45 e0             	mov    %eax,-0x20(%ebp)
    envid_t envid;
    uint32_t i, j, pn;
    int perm;

    // set page fault handler
    set_pgfault_handler(pgfault);
  800ff2:	83 ec 0c             	sub    $0xc,%esp
  800ff5:	68 80 0d 80 00       	push   $0x800d80
  800ffa:	e8 e8 01 00 00       	call   8011e7 <set_pgfault_handler>
  800fff:	b8 07 00 00 00       	mov    $0x7,%eax
  801004:	cd 30                	int    $0x30
  801006:	89 45 dc             	mov    %eax,-0x24(%ebp)

    // create a child
    if((envid = sys_exofork()) < 0)
  801009:	83 c4 10             	add    $0x10,%esp
  80100c:	85 c0                	test   %eax,%eax
  80100e:	0f 88 5d 01 00 00    	js     801171 <sfork+0x190>
  801014:	89 c7                	mov    %eax,%edi
  801016:	c7 45 e4 02 00 00 00 	movl   $0x2,-0x1c(%ebp)
    {
        return -1;
    }

    if(envid == 0)
  80101d:	85 c0                	test   %eax,%eax
  80101f:	75 21                	jne    801042 <sfork+0x61>
    {
        thisenv = &envs[ENVX(sys_getenvid())];
  801021:	e8 e8 fa ff ff       	call   800b0e <sys_getenvid>
  801026:	25 ff 03 00 00       	and    $0x3ff,%eax
  80102b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80102e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801033:	a3 08 20 80 00       	mov    %eax,0x802008
        return envid;
  801038:	b8 00 00 00 00       	mov    $0x0,%eax
  80103d:	e9 57 01 00 00       	jmp    801199 <sfork+0x1b8>
    }

    // copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
  801042:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801045:	8b 04 b5 00 d0 7b ef 	mov    -0x10843000(,%esi,4),%eax
  80104c:	a8 01                	test   $0x1,%al
  80104e:	74 76                	je     8010c6 <sfork+0xe5>
        {
            for (j = 0; j < NPTENTRIES; j++)
            {
                pn = PGNUM(PGADDR(i, j, 0));
  801050:	c1 e6 16             	shl    $0x16,%esi
  801053:	bb 00 00 00 00       	mov    $0x0,%ebx
  801058:	89 d8                	mov    %ebx,%eax
  80105a:	c1 e0 0c             	shl    $0xc,%eax
  80105d:	09 f0                	or     %esi,%eax
  80105f:	89 c2                	mov    %eax,%edx
  801061:	c1 ea 0c             	shr    $0xc,%edx
                if(pn == PGNUM(UXSTACKTOP - PGSIZE))
  801064:	81 fa ff eb 0e 00    	cmp    $0xeebff,%edx
  80106a:	74 5a                	je     8010c6 <sfork+0xe5>
                {
                    break;
                }

                if(pn == PGNUM(USTACKTOP - PGSIZE))
  80106c:	81 fa fd eb 0e 00    	cmp    $0xeebfd,%edx
  801072:	75 09                	jne    80107d <sfork+0x9c>
                {
                     duppage(envid, pn); // cow for stack page
  801074:	89 f8                	mov    %edi,%eax
  801076:	e8 80 fc ff ff       	call   800cfb <duppage>
                     continue;
  80107b:	eb 3e                	jmp    8010bb <sfork+0xda>
                }

                // map same page to child env with same perms
                if (uvpt[pn] & PTE_P)
  80107d:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801084:	f6 c1 01             	test   $0x1,%cl
  801087:	74 32                	je     8010bb <sfork+0xda>
                {
                    
                    perm = uvpt[pn] & ~(uvpt[pn] & ~(PTE_P |PTE_U | PTE_W | PTE_AVAIL));
  801089:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801090:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
                    if (sys_page_map(myenvid, (void *)(PGADDR(i, j, 0)),
  801097:	83 ec 0c             	sub    $0xc,%esp
  80109a:	81 e2 f8 f1 ff ff    	and    $0xfffff1f8,%edx
  8010a0:	f7 d2                	not    %edx
  8010a2:	21 d1                	and    %edx,%ecx
  8010a4:	51                   	push   %ecx
  8010a5:	50                   	push   %eax
  8010a6:	57                   	push   %edi
  8010a7:	50                   	push   %eax
  8010a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8010ab:	e8 df fa ff ff       	call   800b8f <sys_page_map>
  8010b0:	83 c4 20             	add    $0x20,%esp
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	0f 88 bd 00 00 00    	js     801178 <sfork+0x197>
    // copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
        {
            for (j = 0; j < NPTENTRIES; j++)
  8010bb:	83 c3 01             	add    $0x1,%ebx
  8010be:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  8010c4:	75 92                	jne    801058 <sfork+0x77>
        thisenv = &envs[ENVX(sys_getenvid())];
        return envid;
    }

    // copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
  8010c6:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  8010ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010cd:	3d bb 03 00 00       	cmp    $0x3bb,%eax
  8010d2:	0f 85 6a ff ff ff    	jne    801042 <sfork+0x61>
            }
        }
    }

    // allocate new exception stack for child
    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
  8010d8:	83 ec 04             	sub    $0x4,%esp
  8010db:	6a 07                	push   $0x7
  8010dd:	68 00 f0 bf ee       	push   $0xeebff000
  8010e2:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8010e5:	57                   	push   %edi
  8010e6:	e8 61 fa ff ff       	call   800b4c <sys_page_alloc>
  8010eb:	83 c4 10             	add    $0x10,%esp
  8010ee:	85 c0                	test   %eax,%eax
  8010f0:	0f 88 89 00 00 00    	js     80117f <sfork+0x19e>
    {
        return -1;
    }

    // map child uxstack to temp page
    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  8010f6:	83 ec 0c             	sub    $0xc,%esp
  8010f9:	6a 07                	push   $0x7
  8010fb:	68 00 f0 7f 00       	push   $0x7ff000
  801100:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801103:	56                   	push   %esi
  801104:	68 00 f0 bf ee       	push   $0xeebff000
  801109:	57                   	push   %edi
  80110a:	e8 80 fa ff ff       	call   800b8f <sys_page_map>
  80110f:	83 c4 20             	add    $0x20,%esp
  801112:	85 c0                	test   %eax,%eax
  801114:	78 70                	js     801186 <sfork+0x1a5>
    {
        return -1;
    }

    // copy own uxstack to temp page
    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);
  801116:	83 ec 04             	sub    $0x4,%esp
  801119:	68 00 10 00 00       	push   $0x1000
  80111e:	68 00 f0 7f 00       	push   $0x7ff000
  801123:	68 00 f0 bf ee       	push   $0xeebff000
  801128:	e8 ae f7 ff ff       	call   8008db <memmove>

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
  80112d:	83 c4 08             	add    $0x8,%esp
  801130:	68 00 f0 7f 00       	push   $0x7ff000
  801135:	56                   	push   %esi
  801136:	e8 96 fa ff ff       	call   800bd1 <sys_page_unmap>
  80113b:	83 c4 10             	add    $0x10,%esp
  80113e:	85 c0                	test   %eax,%eax
  801140:	78 4b                	js     80118d <sfork+0x1ac>
    {
        return -1;
    }

    // set page fault handler in child
    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
  801142:	83 ec 08             	sub    $0x8,%esp
  801145:	68 4c 12 80 00       	push   $0x80124c
  80114a:	57                   	push   %edi
  80114b:	e8 05 fb ff ff       	call   800c55 <sys_env_set_pgfault_upcall>
  801150:	83 c4 10             	add    $0x10,%esp
  801153:	85 c0                	test   %eax,%eax
  801155:	78 3d                	js     801194 <sfork+0x1b3>
    {
        return -1;
    }

    // mark child env as RUNNABLE
    if(sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  801157:	83 ec 08             	sub    $0x8,%esp
  80115a:	6a 02                	push   $0x2
  80115c:	57                   	push   %edi
  80115d:	e8 b1 fa ff ff       	call   800c13 <sys_env_set_status>
  801162:	83 c4 10             	add    $0x10,%esp
    {
        return -1;
    }

    return envid;
  801165:	85 c0                	test   %eax,%eax
  801167:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80116c:	0f 49 c7             	cmovns %edi,%eax
  80116f:	eb 28                	jmp    801199 <sfork+0x1b8>
    set_pgfault_handler(pgfault);

    // create a child
    if((envid = sys_exofork()) < 0)
    {
        return -1;
  801171:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801176:	eb 21                	jmp    801199 <sfork+0x1b8>
                    
                    perm = uvpt[pn] & ~(uvpt[pn] & ~(PTE_P |PTE_U | PTE_W | PTE_AVAIL));
                    if (sys_page_map(myenvid, (void *)(PGADDR(i, j, 0)),
                                     envid,   (void *)(PGADDR(i, j, 0)), perm) < 0)
                    {
                        return -1;
  801178:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80117d:	eb 1a                	jmp    801199 <sfork+0x1b8>
    }

    // allocate new exception stack for child
    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  80117f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801184:	eb 13                	jmp    801199 <sfork+0x1b8>
    }

    // map child uxstack to temp page
    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  801186:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80118b:	eb 0c                	jmp    801199 <sfork+0x1b8>
    // copy own uxstack to temp page
    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
    {
        return -1;
  80118d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801192:	eb 05                	jmp    801199 <sfork+0x1b8>
    }

    // set page fault handler in child
    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
    {
        return -1;
  801194:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    {
        return -1;
    }

    return envid;
}
  801199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119c:	5b                   	pop    %ebx
  80119d:	5e                   	pop    %esi
  80119e:	5f                   	pop    %edi
  80119f:	5d                   	pop    %ebp
  8011a0:	c3                   	ret    

008011a1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8011a1:	55                   	push   %ebp
  8011a2:	89 e5                	mov    %esp,%ebp
  8011a4:	56                   	push   %esi
  8011a5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8011a6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8011a9:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8011af:	e8 5a f9 ff ff       	call   800b0e <sys_getenvid>
  8011b4:	83 ec 0c             	sub    $0xc,%esp
  8011b7:	ff 75 0c             	pushl  0xc(%ebp)
  8011ba:	ff 75 08             	pushl  0x8(%ebp)
  8011bd:	56                   	push   %esi
  8011be:	50                   	push   %eax
  8011bf:	68 b8 18 80 00       	push   $0x8018b8
  8011c4:	e8 e4 ef ff ff       	call   8001ad <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011c9:	83 c4 18             	add    $0x18,%esp
  8011cc:	53                   	push   %ebx
  8011cd:	ff 75 10             	pushl  0x10(%ebp)
  8011d0:	e8 87 ef ff ff       	call   80015c <vcprintf>
	cprintf("\n");
  8011d5:	c7 04 24 46 15 80 00 	movl   $0x801546,(%esp)
  8011dc:	e8 cc ef ff ff       	call   8001ad <cprintf>
  8011e1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011e4:	cc                   	int3   
  8011e5:	eb fd                	jmp    8011e4 <_panic+0x43>

008011e7 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8011ed:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  8011f4:	75 4c                	jne    801242 <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.

        void *va = (void *)(UXSTACKTOP - PGSIZE);
        if (sys_page_alloc(thisenv->env_id, va, PTE_P | PTE_U | PTE_W))
  8011f6:	a1 08 20 80 00       	mov    0x802008,%eax
  8011fb:	8b 40 48             	mov    0x48(%eax),%eax
  8011fe:	83 ec 04             	sub    $0x4,%esp
  801201:	6a 07                	push   $0x7
  801203:	68 00 f0 bf ee       	push   $0xeebff000
  801208:	50                   	push   %eax
  801209:	e8 3e f9 ff ff       	call   800b4c <sys_page_alloc>
  80120e:	83 c4 10             	add    $0x10,%esp
  801211:	85 c0                	test   %eax,%eax
  801213:	74 14                	je     801229 <set_pgfault_handler+0x42>
        {
            panic("Unable to allocate memory for pgfault expected\n");
  801215:	83 ec 04             	sub    $0x4,%esp
  801218:	68 dc 18 80 00       	push   $0x8018dc
  80121d:	6a 24                	push   $0x24
  80121f:	68 0c 19 80 00       	push   $0x80190c
  801224:	e8 78 ff ff ff       	call   8011a1 <_panic>
        }

        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801229:	a1 08 20 80 00       	mov    0x802008,%eax
  80122e:	8b 40 48             	mov    0x48(%eax),%eax
  801231:	83 ec 08             	sub    $0x8,%esp
  801234:	68 4c 12 80 00       	push   $0x80124c
  801239:	50                   	push   %eax
  80123a:	e8 16 fa ff ff       	call   800c55 <sys_env_set_pgfault_upcall>
  80123f:	83 c4 10             	add    $0x10,%esp

		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801242:	8b 45 08             	mov    0x8(%ebp),%eax
  801245:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  80124a:	c9                   	leave  
  80124b:	c3                   	ret    

0080124c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80124c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80124d:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  801252:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801254:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
    movl %esp, %ebx
  801257:	89 e3                	mov    %esp,%ebx
    // 40 is the size between utf_fault_va ~ utf_regs
    movl 40(%esp), %eax
  801259:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 48(%esp), %esp
  80125d:	8b 64 24 30          	mov    0x30(%esp),%esp
    pushl %eax
  801261:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    movl %ebx, %esp
  801262:	89 dc                	mov    %ebx,%esp
    subl $4, 48(%esp)
  801264:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    popl %eax
  801269:	58                   	pop    %eax
    popl %eax
  80126a:	58                   	pop    %eax
    popal
  80126b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  80126c:	83 c4 04             	add    $0x4,%esp
    popfl
  80126f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp
  801270:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  801271:	c3                   	ret    
  801272:	66 90                	xchg   %ax,%ax
  801274:	66 90                	xchg   %ax,%ax
  801276:	66 90                	xchg   %ax,%ax
  801278:	66 90                	xchg   %ax,%ax
  80127a:	66 90                	xchg   %ax,%ax
  80127c:	66 90                	xchg   %ax,%ax
  80127e:	66 90                	xchg   %ax,%ax

00801280 <__udivdi3>:
  801280:	55                   	push   %ebp
  801281:	57                   	push   %edi
  801282:	56                   	push   %esi
  801283:	53                   	push   %ebx
  801284:	83 ec 1c             	sub    $0x1c,%esp
  801287:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80128b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80128f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801293:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801297:	85 f6                	test   %esi,%esi
  801299:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80129d:	89 ca                	mov    %ecx,%edx
  80129f:	89 f8                	mov    %edi,%eax
  8012a1:	75 3d                	jne    8012e0 <__udivdi3+0x60>
  8012a3:	39 cf                	cmp    %ecx,%edi
  8012a5:	0f 87 c5 00 00 00    	ja     801370 <__udivdi3+0xf0>
  8012ab:	85 ff                	test   %edi,%edi
  8012ad:	89 fd                	mov    %edi,%ebp
  8012af:	75 0b                	jne    8012bc <__udivdi3+0x3c>
  8012b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8012b6:	31 d2                	xor    %edx,%edx
  8012b8:	f7 f7                	div    %edi
  8012ba:	89 c5                	mov    %eax,%ebp
  8012bc:	89 c8                	mov    %ecx,%eax
  8012be:	31 d2                	xor    %edx,%edx
  8012c0:	f7 f5                	div    %ebp
  8012c2:	89 c1                	mov    %eax,%ecx
  8012c4:	89 d8                	mov    %ebx,%eax
  8012c6:	89 cf                	mov    %ecx,%edi
  8012c8:	f7 f5                	div    %ebp
  8012ca:	89 c3                	mov    %eax,%ebx
  8012cc:	89 d8                	mov    %ebx,%eax
  8012ce:	89 fa                	mov    %edi,%edx
  8012d0:	83 c4 1c             	add    $0x1c,%esp
  8012d3:	5b                   	pop    %ebx
  8012d4:	5e                   	pop    %esi
  8012d5:	5f                   	pop    %edi
  8012d6:	5d                   	pop    %ebp
  8012d7:	c3                   	ret    
  8012d8:	90                   	nop
  8012d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012e0:	39 ce                	cmp    %ecx,%esi
  8012e2:	77 74                	ja     801358 <__udivdi3+0xd8>
  8012e4:	0f bd fe             	bsr    %esi,%edi
  8012e7:	83 f7 1f             	xor    $0x1f,%edi
  8012ea:	0f 84 98 00 00 00    	je     801388 <__udivdi3+0x108>
  8012f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8012f5:	89 f9                	mov    %edi,%ecx
  8012f7:	89 c5                	mov    %eax,%ebp
  8012f9:	29 fb                	sub    %edi,%ebx
  8012fb:	d3 e6                	shl    %cl,%esi
  8012fd:	89 d9                	mov    %ebx,%ecx
  8012ff:	d3 ed                	shr    %cl,%ebp
  801301:	89 f9                	mov    %edi,%ecx
  801303:	d3 e0                	shl    %cl,%eax
  801305:	09 ee                	or     %ebp,%esi
  801307:	89 d9                	mov    %ebx,%ecx
  801309:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80130d:	89 d5                	mov    %edx,%ebp
  80130f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801313:	d3 ed                	shr    %cl,%ebp
  801315:	89 f9                	mov    %edi,%ecx
  801317:	d3 e2                	shl    %cl,%edx
  801319:	89 d9                	mov    %ebx,%ecx
  80131b:	d3 e8                	shr    %cl,%eax
  80131d:	09 c2                	or     %eax,%edx
  80131f:	89 d0                	mov    %edx,%eax
  801321:	89 ea                	mov    %ebp,%edx
  801323:	f7 f6                	div    %esi
  801325:	89 d5                	mov    %edx,%ebp
  801327:	89 c3                	mov    %eax,%ebx
  801329:	f7 64 24 0c          	mull   0xc(%esp)
  80132d:	39 d5                	cmp    %edx,%ebp
  80132f:	72 10                	jb     801341 <__udivdi3+0xc1>
  801331:	8b 74 24 08          	mov    0x8(%esp),%esi
  801335:	89 f9                	mov    %edi,%ecx
  801337:	d3 e6                	shl    %cl,%esi
  801339:	39 c6                	cmp    %eax,%esi
  80133b:	73 07                	jae    801344 <__udivdi3+0xc4>
  80133d:	39 d5                	cmp    %edx,%ebp
  80133f:	75 03                	jne    801344 <__udivdi3+0xc4>
  801341:	83 eb 01             	sub    $0x1,%ebx
  801344:	31 ff                	xor    %edi,%edi
  801346:	89 d8                	mov    %ebx,%eax
  801348:	89 fa                	mov    %edi,%edx
  80134a:	83 c4 1c             	add    $0x1c,%esp
  80134d:	5b                   	pop    %ebx
  80134e:	5e                   	pop    %esi
  80134f:	5f                   	pop    %edi
  801350:	5d                   	pop    %ebp
  801351:	c3                   	ret    
  801352:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801358:	31 ff                	xor    %edi,%edi
  80135a:	31 db                	xor    %ebx,%ebx
  80135c:	89 d8                	mov    %ebx,%eax
  80135e:	89 fa                	mov    %edi,%edx
  801360:	83 c4 1c             	add    $0x1c,%esp
  801363:	5b                   	pop    %ebx
  801364:	5e                   	pop    %esi
  801365:	5f                   	pop    %edi
  801366:	5d                   	pop    %ebp
  801367:	c3                   	ret    
  801368:	90                   	nop
  801369:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801370:	89 d8                	mov    %ebx,%eax
  801372:	f7 f7                	div    %edi
  801374:	31 ff                	xor    %edi,%edi
  801376:	89 c3                	mov    %eax,%ebx
  801378:	89 d8                	mov    %ebx,%eax
  80137a:	89 fa                	mov    %edi,%edx
  80137c:	83 c4 1c             	add    $0x1c,%esp
  80137f:	5b                   	pop    %ebx
  801380:	5e                   	pop    %esi
  801381:	5f                   	pop    %edi
  801382:	5d                   	pop    %ebp
  801383:	c3                   	ret    
  801384:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801388:	39 ce                	cmp    %ecx,%esi
  80138a:	72 0c                	jb     801398 <__udivdi3+0x118>
  80138c:	31 db                	xor    %ebx,%ebx
  80138e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801392:	0f 87 34 ff ff ff    	ja     8012cc <__udivdi3+0x4c>
  801398:	bb 01 00 00 00       	mov    $0x1,%ebx
  80139d:	e9 2a ff ff ff       	jmp    8012cc <__udivdi3+0x4c>
  8013a2:	66 90                	xchg   %ax,%ax
  8013a4:	66 90                	xchg   %ax,%ax
  8013a6:	66 90                	xchg   %ax,%ax
  8013a8:	66 90                	xchg   %ax,%ax
  8013aa:	66 90                	xchg   %ax,%ax
  8013ac:	66 90                	xchg   %ax,%ax
  8013ae:	66 90                	xchg   %ax,%ax

008013b0 <__umoddi3>:
  8013b0:	55                   	push   %ebp
  8013b1:	57                   	push   %edi
  8013b2:	56                   	push   %esi
  8013b3:	53                   	push   %ebx
  8013b4:	83 ec 1c             	sub    $0x1c,%esp
  8013b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8013bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8013bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8013c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8013c7:	85 d2                	test   %edx,%edx
  8013c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8013cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013d1:	89 f3                	mov    %esi,%ebx
  8013d3:	89 3c 24             	mov    %edi,(%esp)
  8013d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013da:	75 1c                	jne    8013f8 <__umoddi3+0x48>
  8013dc:	39 f7                	cmp    %esi,%edi
  8013de:	76 50                	jbe    801430 <__umoddi3+0x80>
  8013e0:	89 c8                	mov    %ecx,%eax
  8013e2:	89 f2                	mov    %esi,%edx
  8013e4:	f7 f7                	div    %edi
  8013e6:	89 d0                	mov    %edx,%eax
  8013e8:	31 d2                	xor    %edx,%edx
  8013ea:	83 c4 1c             	add    $0x1c,%esp
  8013ed:	5b                   	pop    %ebx
  8013ee:	5e                   	pop    %esi
  8013ef:	5f                   	pop    %edi
  8013f0:	5d                   	pop    %ebp
  8013f1:	c3                   	ret    
  8013f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013f8:	39 f2                	cmp    %esi,%edx
  8013fa:	89 d0                	mov    %edx,%eax
  8013fc:	77 52                	ja     801450 <__umoddi3+0xa0>
  8013fe:	0f bd ea             	bsr    %edx,%ebp
  801401:	83 f5 1f             	xor    $0x1f,%ebp
  801404:	75 5a                	jne    801460 <__umoddi3+0xb0>
  801406:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80140a:	0f 82 e0 00 00 00    	jb     8014f0 <__umoddi3+0x140>
  801410:	39 0c 24             	cmp    %ecx,(%esp)
  801413:	0f 86 d7 00 00 00    	jbe    8014f0 <__umoddi3+0x140>
  801419:	8b 44 24 08          	mov    0x8(%esp),%eax
  80141d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801421:	83 c4 1c             	add    $0x1c,%esp
  801424:	5b                   	pop    %ebx
  801425:	5e                   	pop    %esi
  801426:	5f                   	pop    %edi
  801427:	5d                   	pop    %ebp
  801428:	c3                   	ret    
  801429:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801430:	85 ff                	test   %edi,%edi
  801432:	89 fd                	mov    %edi,%ebp
  801434:	75 0b                	jne    801441 <__umoddi3+0x91>
  801436:	b8 01 00 00 00       	mov    $0x1,%eax
  80143b:	31 d2                	xor    %edx,%edx
  80143d:	f7 f7                	div    %edi
  80143f:	89 c5                	mov    %eax,%ebp
  801441:	89 f0                	mov    %esi,%eax
  801443:	31 d2                	xor    %edx,%edx
  801445:	f7 f5                	div    %ebp
  801447:	89 c8                	mov    %ecx,%eax
  801449:	f7 f5                	div    %ebp
  80144b:	89 d0                	mov    %edx,%eax
  80144d:	eb 99                	jmp    8013e8 <__umoddi3+0x38>
  80144f:	90                   	nop
  801450:	89 c8                	mov    %ecx,%eax
  801452:	89 f2                	mov    %esi,%edx
  801454:	83 c4 1c             	add    $0x1c,%esp
  801457:	5b                   	pop    %ebx
  801458:	5e                   	pop    %esi
  801459:	5f                   	pop    %edi
  80145a:	5d                   	pop    %ebp
  80145b:	c3                   	ret    
  80145c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801460:	8b 34 24             	mov    (%esp),%esi
  801463:	bf 20 00 00 00       	mov    $0x20,%edi
  801468:	89 e9                	mov    %ebp,%ecx
  80146a:	29 ef                	sub    %ebp,%edi
  80146c:	d3 e0                	shl    %cl,%eax
  80146e:	89 f9                	mov    %edi,%ecx
  801470:	89 f2                	mov    %esi,%edx
  801472:	d3 ea                	shr    %cl,%edx
  801474:	89 e9                	mov    %ebp,%ecx
  801476:	09 c2                	or     %eax,%edx
  801478:	89 d8                	mov    %ebx,%eax
  80147a:	89 14 24             	mov    %edx,(%esp)
  80147d:	89 f2                	mov    %esi,%edx
  80147f:	d3 e2                	shl    %cl,%edx
  801481:	89 f9                	mov    %edi,%ecx
  801483:	89 54 24 04          	mov    %edx,0x4(%esp)
  801487:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80148b:	d3 e8                	shr    %cl,%eax
  80148d:	89 e9                	mov    %ebp,%ecx
  80148f:	89 c6                	mov    %eax,%esi
  801491:	d3 e3                	shl    %cl,%ebx
  801493:	89 f9                	mov    %edi,%ecx
  801495:	89 d0                	mov    %edx,%eax
  801497:	d3 e8                	shr    %cl,%eax
  801499:	89 e9                	mov    %ebp,%ecx
  80149b:	09 d8                	or     %ebx,%eax
  80149d:	89 d3                	mov    %edx,%ebx
  80149f:	89 f2                	mov    %esi,%edx
  8014a1:	f7 34 24             	divl   (%esp)
  8014a4:	89 d6                	mov    %edx,%esi
  8014a6:	d3 e3                	shl    %cl,%ebx
  8014a8:	f7 64 24 04          	mull   0x4(%esp)
  8014ac:	39 d6                	cmp    %edx,%esi
  8014ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014b2:	89 d1                	mov    %edx,%ecx
  8014b4:	89 c3                	mov    %eax,%ebx
  8014b6:	72 08                	jb     8014c0 <__umoddi3+0x110>
  8014b8:	75 11                	jne    8014cb <__umoddi3+0x11b>
  8014ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8014be:	73 0b                	jae    8014cb <__umoddi3+0x11b>
  8014c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8014c4:	1b 14 24             	sbb    (%esp),%edx
  8014c7:	89 d1                	mov    %edx,%ecx
  8014c9:	89 c3                	mov    %eax,%ebx
  8014cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8014cf:	29 da                	sub    %ebx,%edx
  8014d1:	19 ce                	sbb    %ecx,%esi
  8014d3:	89 f9                	mov    %edi,%ecx
  8014d5:	89 f0                	mov    %esi,%eax
  8014d7:	d3 e0                	shl    %cl,%eax
  8014d9:	89 e9                	mov    %ebp,%ecx
  8014db:	d3 ea                	shr    %cl,%edx
  8014dd:	89 e9                	mov    %ebp,%ecx
  8014df:	d3 ee                	shr    %cl,%esi
  8014e1:	09 d0                	or     %edx,%eax
  8014e3:	89 f2                	mov    %esi,%edx
  8014e5:	83 c4 1c             	add    $0x1c,%esp
  8014e8:	5b                   	pop    %ebx
  8014e9:	5e                   	pop    %esi
  8014ea:	5f                   	pop    %edi
  8014eb:	5d                   	pop    %ebp
  8014ec:	c3                   	ret    
  8014ed:	8d 76 00             	lea    0x0(%esi),%esi
  8014f0:	29 f9                	sub    %edi,%ecx
  8014f2:	19 d6                	sbb    %edx,%esi
  8014f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014fc:	e9 18 ff ff ff       	jmp    801419 <__umoddi3+0x69>
