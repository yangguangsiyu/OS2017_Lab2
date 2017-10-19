
obj/user/pingpong：     文件格式 elf32-i386


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
  80002c:	e8 8d 00 00 00       	call   8000be <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 2a 0e 00 00       	call   800e6b <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 27                	je     80006f <umain+0x3c>
  800048:	89 c3                	mov    %eax,%ebx
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 bb 0a 00 00       	call   800b0a <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 20 16 80 00       	push   $0x801620
  800059:	e8 4b 01 00 00       	call   8001a9 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 a6 11 00 00       	call   801212 <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 1e 11 00 00       	call   80119d <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 81 0a 00 00       	call   800b0a <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 36 16 80 00       	push   $0x801636
  800091:	e8 13 01 00 00       	call   8001a9 <cprintf>
		if (i == 10)
  800096:	83 c4 20             	add    $0x20,%esp
  800099:	83 fb 0a             	cmp    $0xa,%ebx
  80009c:	74 18                	je     8000b6 <umain+0x83>
			return;
		i++;
  80009e:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	53                   	push   %ebx
  8000a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a9:	e8 64 11 00 00       	call   801212 <ipc_send>
		if (i == 10)
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	83 fb 0a             	cmp    $0xa,%ebx
  8000b4:	75 bc                	jne    800072 <umain+0x3f>
			return;
	}

}
  8000b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
  8000c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000c9:	e8 3c 0a 00 00       	call   800b0a <sys_getenvid>
  8000ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000db:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e0:	85 db                	test   %ebx,%ebx
  8000e2:	7e 07                	jle    8000eb <libmain+0x2d>
		binaryname = argv[0];
  8000e4:	8b 06                	mov    (%esi),%eax
  8000e6:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	e8 3e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f5:	e8 0a 00 00 00       	call   800104 <exit>
}
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80010a:	6a 00                	push   $0x0
  80010c:	e8 b8 09 00 00       	call   800ac9 <sys_env_destroy>
}
  800111:	83 c4 10             	add    $0x10,%esp
  800114:	c9                   	leave  
  800115:	c3                   	ret    

00800116 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	53                   	push   %ebx
  80011a:	83 ec 04             	sub    $0x4,%esp
  80011d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800120:	8b 13                	mov    (%ebx),%edx
  800122:	8d 42 01             	lea    0x1(%edx),%eax
  800125:	89 03                	mov    %eax,(%ebx)
  800127:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80012a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800133:	75 1a                	jne    80014f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800135:	83 ec 08             	sub    $0x8,%esp
  800138:	68 ff 00 00 00       	push   $0xff
  80013d:	8d 43 08             	lea    0x8(%ebx),%eax
  800140:	50                   	push   %eax
  800141:	e8 46 09 00 00       	call   800a8c <sys_cputs>
		b->idx = 0;
  800146:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80014f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800153:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800161:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800168:	00 00 00 
	b.cnt = 0;
  80016b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800172:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800175:	ff 75 0c             	pushl  0xc(%ebp)
  800178:	ff 75 08             	pushl  0x8(%ebp)
  80017b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800181:	50                   	push   %eax
  800182:	68 16 01 80 00       	push   $0x800116
  800187:	e8 54 01 00 00       	call   8002e0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018c:	83 c4 08             	add    $0x8,%esp
  80018f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800195:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019b:	50                   	push   %eax
  80019c:	e8 eb 08 00 00       	call   800a8c <sys_cputs>

	return b.cnt;
}
  8001a1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a7:	c9                   	leave  
  8001a8:	c3                   	ret    

008001a9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001af:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b2:	50                   	push   %eax
  8001b3:	ff 75 08             	pushl  0x8(%ebp)
  8001b6:	e8 9d ff ff ff       	call   800158 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bb:	c9                   	leave  
  8001bc:	c3                   	ret    

008001bd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	57                   	push   %edi
  8001c1:	56                   	push   %esi
  8001c2:	53                   	push   %ebx
  8001c3:	83 ec 1c             	sub    $0x1c,%esp
  8001c6:	89 c7                	mov    %eax,%edi
  8001c8:	89 d6                	mov    %edx,%esi
  8001ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d3:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001de:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e1:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001e4:	39 d3                	cmp    %edx,%ebx
  8001e6:	72 05                	jb     8001ed <printnum+0x30>
  8001e8:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001eb:	77 45                	ja     800232 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ed:	83 ec 0c             	sub    $0xc,%esp
  8001f0:	ff 75 18             	pushl  0x18(%ebp)
  8001f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f6:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f9:	53                   	push   %ebx
  8001fa:	ff 75 10             	pushl  0x10(%ebp)
  8001fd:	83 ec 08             	sub    $0x8,%esp
  800200:	ff 75 e4             	pushl  -0x1c(%ebp)
  800203:	ff 75 e0             	pushl  -0x20(%ebp)
  800206:	ff 75 dc             	pushl  -0x24(%ebp)
  800209:	ff 75 d8             	pushl  -0x28(%ebp)
  80020c:	e8 6f 11 00 00       	call   801380 <__udivdi3>
  800211:	83 c4 18             	add    $0x18,%esp
  800214:	52                   	push   %edx
  800215:	50                   	push   %eax
  800216:	89 f2                	mov    %esi,%edx
  800218:	89 f8                	mov    %edi,%eax
  80021a:	e8 9e ff ff ff       	call   8001bd <printnum>
  80021f:	83 c4 20             	add    $0x20,%esp
  800222:	eb 18                	jmp    80023c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800224:	83 ec 08             	sub    $0x8,%esp
  800227:	56                   	push   %esi
  800228:	ff 75 18             	pushl  0x18(%ebp)
  80022b:	ff d7                	call   *%edi
  80022d:	83 c4 10             	add    $0x10,%esp
  800230:	eb 03                	jmp    800235 <printnum+0x78>
  800232:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800235:	83 eb 01             	sub    $0x1,%ebx
  800238:	85 db                	test   %ebx,%ebx
  80023a:	7f e8                	jg     800224 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023c:	83 ec 08             	sub    $0x8,%esp
  80023f:	56                   	push   %esi
  800240:	83 ec 04             	sub    $0x4,%esp
  800243:	ff 75 e4             	pushl  -0x1c(%ebp)
  800246:	ff 75 e0             	pushl  -0x20(%ebp)
  800249:	ff 75 dc             	pushl  -0x24(%ebp)
  80024c:	ff 75 d8             	pushl  -0x28(%ebp)
  80024f:	e8 5c 12 00 00       	call   8014b0 <__umoddi3>
  800254:	83 c4 14             	add    $0x14,%esp
  800257:	0f be 80 53 16 80 00 	movsbl 0x801653(%eax),%eax
  80025e:	50                   	push   %eax
  80025f:	ff d7                	call   *%edi
}
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80026f:	83 fa 01             	cmp    $0x1,%edx
  800272:	7e 0e                	jle    800282 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800274:	8b 10                	mov    (%eax),%edx
  800276:	8d 4a 08             	lea    0x8(%edx),%ecx
  800279:	89 08                	mov    %ecx,(%eax)
  80027b:	8b 02                	mov    (%edx),%eax
  80027d:	8b 52 04             	mov    0x4(%edx),%edx
  800280:	eb 22                	jmp    8002a4 <getuint+0x38>
	else if (lflag)
  800282:	85 d2                	test   %edx,%edx
  800284:	74 10                	je     800296 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800286:	8b 10                	mov    (%eax),%edx
  800288:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028b:	89 08                	mov    %ecx,(%eax)
  80028d:	8b 02                	mov    (%edx),%eax
  80028f:	ba 00 00 00 00       	mov    $0x0,%edx
  800294:	eb 0e                	jmp    8002a4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800296:	8b 10                	mov    (%eax),%edx
  800298:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029b:	89 08                	mov    %ecx,(%eax)
  80029d:	8b 02                	mov    (%edx),%eax
  80029f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ac:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b0:	8b 10                	mov    (%eax),%edx
  8002b2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b5:	73 0a                	jae    8002c1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002b7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ba:	89 08                	mov    %ecx,(%eax)
  8002bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bf:	88 02                	mov    %al,(%edx)
}
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002cc:	50                   	push   %eax
  8002cd:	ff 75 10             	pushl  0x10(%ebp)
  8002d0:	ff 75 0c             	pushl  0xc(%ebp)
  8002d3:	ff 75 08             	pushl  0x8(%ebp)
  8002d6:	e8 05 00 00 00       	call   8002e0 <vprintfmt>
	va_end(ap);
}
  8002db:	83 c4 10             	add    $0x10,%esp
  8002de:	c9                   	leave  
  8002df:	c3                   	ret    

008002e0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	83 ec 2c             	sub    $0x2c,%esp
  8002e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
  8002ec:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002f3:	eb 17                	jmp    80030c <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f5:	85 c0                	test   %eax,%eax
  8002f7:	0f 84 9f 03 00 00    	je     80069c <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
  8002fd:	83 ec 08             	sub    $0x8,%esp
  800300:	ff 75 0c             	pushl  0xc(%ebp)
  800303:	50                   	push   %eax
  800304:	ff 55 08             	call   *0x8(%ebp)
  800307:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030a:	89 f3                	mov    %esi,%ebx
  80030c:	8d 73 01             	lea    0x1(%ebx),%esi
  80030f:	0f b6 03             	movzbl (%ebx),%eax
  800312:	83 f8 25             	cmp    $0x25,%eax
  800315:	75 de                	jne    8002f5 <vprintfmt+0x15>
  800317:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80031b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800322:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800327:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80032e:	ba 00 00 00 00       	mov    $0x0,%edx
  800333:	eb 06                	jmp    80033b <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800335:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800337:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80033e:	0f b6 06             	movzbl (%esi),%eax
  800341:	0f b6 c8             	movzbl %al,%ecx
  800344:	83 e8 23             	sub    $0x23,%eax
  800347:	3c 55                	cmp    $0x55,%al
  800349:	0f 87 2d 03 00 00    	ja     80067c <vprintfmt+0x39c>
  80034f:	0f b6 c0             	movzbl %al,%eax
  800352:	ff 24 85 20 17 80 00 	jmp    *0x801720(,%eax,4)
  800359:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80035b:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80035f:	eb da                	jmp    80033b <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800361:	89 de                	mov    %ebx,%esi
  800363:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800368:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  80036b:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  80036f:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  800372:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800375:	83 f8 09             	cmp    $0x9,%eax
  800378:	77 33                	ja     8003ad <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80037a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80037d:	eb e9                	jmp    800368 <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80037f:	8b 45 14             	mov    0x14(%ebp),%eax
  800382:	8d 48 04             	lea    0x4(%eax),%ecx
  800385:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800388:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80038c:	eb 1f                	jmp    8003ad <vprintfmt+0xcd>
  80038e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800391:	85 c0                	test   %eax,%eax
  800393:	b9 00 00 00 00       	mov    $0x0,%ecx
  800398:	0f 49 c8             	cmovns %eax,%ecx
  80039b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	89 de                	mov    %ebx,%esi
  8003a0:	eb 99                	jmp    80033b <vprintfmt+0x5b>
  8003a2:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003a4:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  8003ab:	eb 8e                	jmp    80033b <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8003ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b1:	79 88                	jns    80033b <vprintfmt+0x5b>
				width = precision, precision = -1;
  8003b3:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8003b6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003bb:	e9 7b ff ff ff       	jmp    80033b <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c0:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c3:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003c5:	e9 71 ff ff ff       	jmp    80033b <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
  8003ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cd:	8d 50 04             	lea    0x4(%eax),%edx
  8003d0:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  8003d3:	83 ec 08             	sub    $0x8,%esp
  8003d6:	ff 75 0c             	pushl  0xc(%ebp)
  8003d9:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8003dc:	03 08                	add    (%eax),%ecx
  8003de:	51                   	push   %ecx
  8003df:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
  8003e2:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
  8003e5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
  8003ec:	e9 1b ff ff ff       	jmp    80030c <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8d 48 04             	lea    0x4(%eax),%ecx
  8003f7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003fa:	8b 00                	mov    (%eax),%eax
  8003fc:	83 f8 02             	cmp    $0x2,%eax
  8003ff:	74 1a                	je     80041b <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800401:	89 de                	mov    %ebx,%esi
  800403:	83 f8 04             	cmp    $0x4,%eax
  800406:	b8 00 00 00 00       	mov    $0x0,%eax
  80040b:	b9 00 04 00 00       	mov    $0x400,%ecx
  800410:	0f 44 c1             	cmove  %ecx,%eax
  800413:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800416:	e9 20 ff ff ff       	jmp    80033b <vprintfmt+0x5b>
  80041b:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
  80041d:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
  800424:	e9 12 ff ff ff       	jmp    80033b <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800429:	8b 45 14             	mov    0x14(%ebp),%eax
  80042c:	8d 50 04             	lea    0x4(%eax),%edx
  80042f:	89 55 14             	mov    %edx,0x14(%ebp)
  800432:	8b 00                	mov    (%eax),%eax
  800434:	99                   	cltd   
  800435:	31 d0                	xor    %edx,%eax
  800437:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800439:	83 f8 09             	cmp    $0x9,%eax
  80043c:	7f 0b                	jg     800449 <vprintfmt+0x169>
  80043e:	8b 14 85 80 18 80 00 	mov    0x801880(,%eax,4),%edx
  800445:	85 d2                	test   %edx,%edx
  800447:	75 19                	jne    800462 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800449:	50                   	push   %eax
  80044a:	68 6b 16 80 00       	push   $0x80166b
  80044f:	ff 75 0c             	pushl  0xc(%ebp)
  800452:	ff 75 08             	pushl  0x8(%ebp)
  800455:	e8 69 fe ff ff       	call   8002c3 <printfmt>
  80045a:	83 c4 10             	add    $0x10,%esp
  80045d:	e9 aa fe ff ff       	jmp    80030c <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  800462:	52                   	push   %edx
  800463:	68 74 16 80 00       	push   $0x801674
  800468:	ff 75 0c             	pushl  0xc(%ebp)
  80046b:	ff 75 08             	pushl  0x8(%ebp)
  80046e:	e8 50 fe ff ff       	call   8002c3 <printfmt>
  800473:	83 c4 10             	add    $0x10,%esp
  800476:	e9 91 fe ff ff       	jmp    80030c <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80047b:	8b 45 14             	mov    0x14(%ebp),%eax
  80047e:	8d 50 04             	lea    0x4(%eax),%edx
  800481:	89 55 14             	mov    %edx,0x14(%ebp)
  800484:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800486:	85 f6                	test   %esi,%esi
  800488:	b8 64 16 80 00       	mov    $0x801664,%eax
  80048d:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800490:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800494:	0f 8e 93 00 00 00    	jle    80052d <vprintfmt+0x24d>
  80049a:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80049e:	0f 84 91 00 00 00    	je     800535 <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a4:	83 ec 08             	sub    $0x8,%esp
  8004a7:	57                   	push   %edi
  8004a8:	56                   	push   %esi
  8004a9:	e8 76 02 00 00       	call   800724 <strnlen>
  8004ae:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b1:	29 c1                	sub    %eax,%ecx
  8004b3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004b6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004b9:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8004bd:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004c0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004c6:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004c9:	89 cb                	mov    %ecx,%ebx
  8004cb:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cd:	eb 0e                	jmp    8004dd <vprintfmt+0x1fd>
					putch(padc, putdat);
  8004cf:	83 ec 08             	sub    $0x8,%esp
  8004d2:	56                   	push   %esi
  8004d3:	57                   	push   %edi
  8004d4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d7:	83 eb 01             	sub    $0x1,%ebx
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	85 db                	test   %ebx,%ebx
  8004df:	7f ee                	jg     8004cf <vprintfmt+0x1ef>
  8004e1:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004e4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ea:	85 c9                	test   %ecx,%ecx
  8004ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f1:	0f 49 c1             	cmovns %ecx,%eax
  8004f4:	29 c1                	sub    %eax,%ecx
  8004f6:	89 cb                	mov    %ecx,%ebx
  8004f8:	eb 41                	jmp    80053b <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004fa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004fe:	74 1b                	je     80051b <vprintfmt+0x23b>
  800500:	0f be c0             	movsbl %al,%eax
  800503:	83 e8 20             	sub    $0x20,%eax
  800506:	83 f8 5e             	cmp    $0x5e,%eax
  800509:	76 10                	jbe    80051b <vprintfmt+0x23b>
					putch('?', putdat);
  80050b:	83 ec 08             	sub    $0x8,%esp
  80050e:	ff 75 0c             	pushl  0xc(%ebp)
  800511:	6a 3f                	push   $0x3f
  800513:	ff 55 08             	call   *0x8(%ebp)
  800516:	83 c4 10             	add    $0x10,%esp
  800519:	eb 0d                	jmp    800528 <vprintfmt+0x248>
				else
					putch(ch, putdat);
  80051b:	83 ec 08             	sub    $0x8,%esp
  80051e:	ff 75 0c             	pushl  0xc(%ebp)
  800521:	52                   	push   %edx
  800522:	ff 55 08             	call   *0x8(%ebp)
  800525:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800528:	83 eb 01             	sub    $0x1,%ebx
  80052b:	eb 0e                	jmp    80053b <vprintfmt+0x25b>
  80052d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800530:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800533:	eb 06                	jmp    80053b <vprintfmt+0x25b>
  800535:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800538:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80053b:	83 c6 01             	add    $0x1,%esi
  80053e:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800542:	0f be d0             	movsbl %al,%edx
  800545:	85 d2                	test   %edx,%edx
  800547:	74 25                	je     80056e <vprintfmt+0x28e>
  800549:	85 ff                	test   %edi,%edi
  80054b:	78 ad                	js     8004fa <vprintfmt+0x21a>
  80054d:	83 ef 01             	sub    $0x1,%edi
  800550:	79 a8                	jns    8004fa <vprintfmt+0x21a>
  800552:	89 d8                	mov    %ebx,%eax
  800554:	8b 75 08             	mov    0x8(%ebp),%esi
  800557:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80055a:	89 c3                	mov    %eax,%ebx
  80055c:	eb 16                	jmp    800574 <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	57                   	push   %edi
  800562:	6a 20                	push   $0x20
  800564:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800566:	83 eb 01             	sub    $0x1,%ebx
  800569:	83 c4 10             	add    $0x10,%esp
  80056c:	eb 06                	jmp    800574 <vprintfmt+0x294>
  80056e:	8b 75 08             	mov    0x8(%ebp),%esi
  800571:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800574:	85 db                	test   %ebx,%ebx
  800576:	7f e6                	jg     80055e <vprintfmt+0x27e>
  800578:	89 75 08             	mov    %esi,0x8(%ebp)
  80057b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80057e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800581:	e9 86 fd ff ff       	jmp    80030c <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800586:	83 fa 01             	cmp    $0x1,%edx
  800589:	7e 10                	jle    80059b <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8d 50 08             	lea    0x8(%eax),%edx
  800591:	89 55 14             	mov    %edx,0x14(%ebp)
  800594:	8b 30                	mov    (%eax),%esi
  800596:	8b 78 04             	mov    0x4(%eax),%edi
  800599:	eb 26                	jmp    8005c1 <vprintfmt+0x2e1>
	else if (lflag)
  80059b:	85 d2                	test   %edx,%edx
  80059d:	74 12                	je     8005b1 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  80059f:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a2:	8d 50 04             	lea    0x4(%eax),%edx
  8005a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a8:	8b 30                	mov    (%eax),%esi
  8005aa:	89 f7                	mov    %esi,%edi
  8005ac:	c1 ff 1f             	sar    $0x1f,%edi
  8005af:	eb 10                	jmp    8005c1 <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8d 50 04             	lea    0x4(%eax),%edx
  8005b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ba:	8b 30                	mov    (%eax),%esi
  8005bc:	89 f7                	mov    %esi,%edi
  8005be:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005c1:	89 f0                	mov    %esi,%eax
  8005c3:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ca:	85 ff                	test   %edi,%edi
  8005cc:	79 7b                	jns    800649 <vprintfmt+0x369>
				putch('-', putdat);
  8005ce:	83 ec 08             	sub    $0x8,%esp
  8005d1:	ff 75 0c             	pushl  0xc(%ebp)
  8005d4:	6a 2d                	push   $0x2d
  8005d6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005d9:	89 f0                	mov    %esi,%eax
  8005db:	89 fa                	mov    %edi,%edx
  8005dd:	f7 d8                	neg    %eax
  8005df:	83 d2 00             	adc    $0x0,%edx
  8005e2:	f7 da                	neg    %edx
  8005e4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005e7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ec:	eb 5b                	jmp    800649 <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f1:	e8 76 fc ff ff       	call   80026c <getuint>
			base = 10;
  8005f6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005fb:	eb 4c                	jmp    800649 <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
  8005fd:	8d 45 14             	lea    0x14(%ebp),%eax
  800600:	e8 67 fc ff ff       	call   80026c <getuint>
            base = 8;
  800605:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80060a:	eb 3d                	jmp    800649 <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
  80060c:	83 ec 08             	sub    $0x8,%esp
  80060f:	ff 75 0c             	pushl  0xc(%ebp)
  800612:	6a 30                	push   $0x30
  800614:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800617:	83 c4 08             	add    $0x8,%esp
  80061a:	ff 75 0c             	pushl  0xc(%ebp)
  80061d:	6a 78                	push   $0x78
  80061f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8d 50 04             	lea    0x4(%eax),%edx
  800628:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80062b:	8b 00                	mov    (%eax),%eax
  80062d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800632:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800635:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80063a:	eb 0d                	jmp    800649 <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80063c:	8d 45 14             	lea    0x14(%ebp),%eax
  80063f:	e8 28 fc ff ff       	call   80026c <getuint>
			base = 16;
  800644:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800649:	83 ec 0c             	sub    $0xc,%esp
  80064c:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  800650:	56                   	push   %esi
  800651:	ff 75 e0             	pushl  -0x20(%ebp)
  800654:	51                   	push   %ecx
  800655:	52                   	push   %edx
  800656:	50                   	push   %eax
  800657:	8b 55 0c             	mov    0xc(%ebp),%edx
  80065a:	8b 45 08             	mov    0x8(%ebp),%eax
  80065d:	e8 5b fb ff ff       	call   8001bd <printnum>
			break;
  800662:	83 c4 20             	add    $0x20,%esp
  800665:	e9 a2 fc ff ff       	jmp    80030c <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80066a:	83 ec 08             	sub    $0x8,%esp
  80066d:	ff 75 0c             	pushl  0xc(%ebp)
  800670:	51                   	push   %ecx
  800671:	ff 55 08             	call   *0x8(%ebp)
			break;
  800674:	83 c4 10             	add    $0x10,%esp
  800677:	e9 90 fc ff ff       	jmp    80030c <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80067c:	83 ec 08             	sub    $0x8,%esp
  80067f:	ff 75 0c             	pushl  0xc(%ebp)
  800682:	6a 25                	push   $0x25
  800684:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800687:	83 c4 10             	add    $0x10,%esp
  80068a:	89 f3                	mov    %esi,%ebx
  80068c:	eb 03                	jmp    800691 <vprintfmt+0x3b1>
  80068e:	83 eb 01             	sub    $0x1,%ebx
  800691:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800695:	75 f7                	jne    80068e <vprintfmt+0x3ae>
  800697:	e9 70 fc ff ff       	jmp    80030c <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  80069c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80069f:	5b                   	pop    %ebx
  8006a0:	5e                   	pop    %esi
  8006a1:	5f                   	pop    %edi
  8006a2:	5d                   	pop    %ebp
  8006a3:	c3                   	ret    

008006a4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006a4:	55                   	push   %ebp
  8006a5:	89 e5                	mov    %esp,%ebp
  8006a7:	83 ec 18             	sub    $0x18,%esp
  8006aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006b3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006b7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006c1:	85 c0                	test   %eax,%eax
  8006c3:	74 26                	je     8006eb <vsnprintf+0x47>
  8006c5:	85 d2                	test   %edx,%edx
  8006c7:	7e 22                	jle    8006eb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c9:	ff 75 14             	pushl  0x14(%ebp)
  8006cc:	ff 75 10             	pushl  0x10(%ebp)
  8006cf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006d2:	50                   	push   %eax
  8006d3:	68 a6 02 80 00       	push   $0x8002a6
  8006d8:	e8 03 fc ff ff       	call   8002e0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006e0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	eb 05                	jmp    8006f0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006f0:	c9                   	leave  
  8006f1:	c3                   	ret    

008006f2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006f8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006fb:	50                   	push   %eax
  8006fc:	ff 75 10             	pushl  0x10(%ebp)
  8006ff:	ff 75 0c             	pushl  0xc(%ebp)
  800702:	ff 75 08             	pushl  0x8(%ebp)
  800705:	e8 9a ff ff ff       	call   8006a4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80070a:	c9                   	leave  
  80070b:	c3                   	ret    

0080070c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800712:	b8 00 00 00 00       	mov    $0x0,%eax
  800717:	eb 03                	jmp    80071c <strlen+0x10>
		n++;
  800719:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80071c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800720:	75 f7                	jne    800719 <strlen+0xd>
		n++;
	return n;
}
  800722:	5d                   	pop    %ebp
  800723:	c3                   	ret    

00800724 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80072a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072d:	ba 00 00 00 00       	mov    $0x0,%edx
  800732:	eb 03                	jmp    800737 <strnlen+0x13>
		n++;
  800734:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800737:	39 c2                	cmp    %eax,%edx
  800739:	74 08                	je     800743 <strnlen+0x1f>
  80073b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80073f:	75 f3                	jne    800734 <strnlen+0x10>
  800741:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800743:	5d                   	pop    %ebp
  800744:	c3                   	ret    

00800745 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	53                   	push   %ebx
  800749:	8b 45 08             	mov    0x8(%ebp),%eax
  80074c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80074f:	89 c2                	mov    %eax,%edx
  800751:	83 c2 01             	add    $0x1,%edx
  800754:	83 c1 01             	add    $0x1,%ecx
  800757:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80075b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80075e:	84 db                	test   %bl,%bl
  800760:	75 ef                	jne    800751 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800762:	5b                   	pop    %ebx
  800763:	5d                   	pop    %ebp
  800764:	c3                   	ret    

00800765 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	53                   	push   %ebx
  800769:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80076c:	53                   	push   %ebx
  80076d:	e8 9a ff ff ff       	call   80070c <strlen>
  800772:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800775:	ff 75 0c             	pushl  0xc(%ebp)
  800778:	01 d8                	add    %ebx,%eax
  80077a:	50                   	push   %eax
  80077b:	e8 c5 ff ff ff       	call   800745 <strcpy>
	return dst;
}
  800780:	89 d8                	mov    %ebx,%eax
  800782:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800785:	c9                   	leave  
  800786:	c3                   	ret    

00800787 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	56                   	push   %esi
  80078b:	53                   	push   %ebx
  80078c:	8b 75 08             	mov    0x8(%ebp),%esi
  80078f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800792:	89 f3                	mov    %esi,%ebx
  800794:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800797:	89 f2                	mov    %esi,%edx
  800799:	eb 0f                	jmp    8007aa <strncpy+0x23>
		*dst++ = *src;
  80079b:	83 c2 01             	add    $0x1,%edx
  80079e:	0f b6 01             	movzbl (%ecx),%eax
  8007a1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007a4:	80 39 01             	cmpb   $0x1,(%ecx)
  8007a7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007aa:	39 da                	cmp    %ebx,%edx
  8007ac:	75 ed                	jne    80079b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ae:	89 f0                	mov    %esi,%eax
  8007b0:	5b                   	pop    %ebx
  8007b1:	5e                   	pop    %esi
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	56                   	push   %esi
  8007b8:	53                   	push   %ebx
  8007b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007bf:	8b 55 10             	mov    0x10(%ebp),%edx
  8007c2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c4:	85 d2                	test   %edx,%edx
  8007c6:	74 21                	je     8007e9 <strlcpy+0x35>
  8007c8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007cc:	89 f2                	mov    %esi,%edx
  8007ce:	eb 09                	jmp    8007d9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007d0:	83 c2 01             	add    $0x1,%edx
  8007d3:	83 c1 01             	add    $0x1,%ecx
  8007d6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007d9:	39 c2                	cmp    %eax,%edx
  8007db:	74 09                	je     8007e6 <strlcpy+0x32>
  8007dd:	0f b6 19             	movzbl (%ecx),%ebx
  8007e0:	84 db                	test   %bl,%bl
  8007e2:	75 ec                	jne    8007d0 <strlcpy+0x1c>
  8007e4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007e6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007e9:	29 f0                	sub    %esi,%eax
}
  8007eb:	5b                   	pop    %ebx
  8007ec:	5e                   	pop    %esi
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f8:	eb 06                	jmp    800800 <strcmp+0x11>
		p++, q++;
  8007fa:	83 c1 01             	add    $0x1,%ecx
  8007fd:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800800:	0f b6 01             	movzbl (%ecx),%eax
  800803:	84 c0                	test   %al,%al
  800805:	74 04                	je     80080b <strcmp+0x1c>
  800807:	3a 02                	cmp    (%edx),%al
  800809:	74 ef                	je     8007fa <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80080b:	0f b6 c0             	movzbl %al,%eax
  80080e:	0f b6 12             	movzbl (%edx),%edx
  800811:	29 d0                	sub    %edx,%eax
}
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	53                   	push   %ebx
  800819:	8b 45 08             	mov    0x8(%ebp),%eax
  80081c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081f:	89 c3                	mov    %eax,%ebx
  800821:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800824:	eb 06                	jmp    80082c <strncmp+0x17>
		n--, p++, q++;
  800826:	83 c0 01             	add    $0x1,%eax
  800829:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80082c:	39 d8                	cmp    %ebx,%eax
  80082e:	74 15                	je     800845 <strncmp+0x30>
  800830:	0f b6 08             	movzbl (%eax),%ecx
  800833:	84 c9                	test   %cl,%cl
  800835:	74 04                	je     80083b <strncmp+0x26>
  800837:	3a 0a                	cmp    (%edx),%cl
  800839:	74 eb                	je     800826 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80083b:	0f b6 00             	movzbl (%eax),%eax
  80083e:	0f b6 12             	movzbl (%edx),%edx
  800841:	29 d0                	sub    %edx,%eax
  800843:	eb 05                	jmp    80084a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800845:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80084a:	5b                   	pop    %ebx
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	8b 45 08             	mov    0x8(%ebp),%eax
  800853:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800857:	eb 07                	jmp    800860 <strchr+0x13>
		if (*s == c)
  800859:	38 ca                	cmp    %cl,%dl
  80085b:	74 0f                	je     80086c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80085d:	83 c0 01             	add    $0x1,%eax
  800860:	0f b6 10             	movzbl (%eax),%edx
  800863:	84 d2                	test   %dl,%dl
  800865:	75 f2                	jne    800859 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800867:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	8b 45 08             	mov    0x8(%ebp),%eax
  800874:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800878:	eb 03                	jmp    80087d <strfind+0xf>
  80087a:	83 c0 01             	add    $0x1,%eax
  80087d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800880:	38 ca                	cmp    %cl,%dl
  800882:	74 04                	je     800888 <strfind+0x1a>
  800884:	84 d2                	test   %dl,%dl
  800886:	75 f2                	jne    80087a <strfind+0xc>
			break;
	return (char *) s;
}
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	57                   	push   %edi
  80088e:	56                   	push   %esi
  80088f:	53                   	push   %ebx
  800890:	8b 7d 08             	mov    0x8(%ebp),%edi
  800893:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800896:	85 c9                	test   %ecx,%ecx
  800898:	74 36                	je     8008d0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80089a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008a0:	75 28                	jne    8008ca <memset+0x40>
  8008a2:	f6 c1 03             	test   $0x3,%cl
  8008a5:	75 23                	jne    8008ca <memset+0x40>
		c &= 0xFF;
  8008a7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ab:	89 d3                	mov    %edx,%ebx
  8008ad:	c1 e3 08             	shl    $0x8,%ebx
  8008b0:	89 d6                	mov    %edx,%esi
  8008b2:	c1 e6 18             	shl    $0x18,%esi
  8008b5:	89 d0                	mov    %edx,%eax
  8008b7:	c1 e0 10             	shl    $0x10,%eax
  8008ba:	09 f0                	or     %esi,%eax
  8008bc:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008be:	89 d8                	mov    %ebx,%eax
  8008c0:	09 d0                	or     %edx,%eax
  8008c2:	c1 e9 02             	shr    $0x2,%ecx
  8008c5:	fc                   	cld    
  8008c6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c8:	eb 06                	jmp    8008d0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008cd:	fc                   	cld    
  8008ce:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008d0:	89 f8                	mov    %edi,%eax
  8008d2:	5b                   	pop    %ebx
  8008d3:	5e                   	pop    %esi
  8008d4:	5f                   	pop    %edi
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	57                   	push   %edi
  8008db:	56                   	push   %esi
  8008dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008df:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008e5:	39 c6                	cmp    %eax,%esi
  8008e7:	73 35                	jae    80091e <memmove+0x47>
  8008e9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008ec:	39 d0                	cmp    %edx,%eax
  8008ee:	73 2e                	jae    80091e <memmove+0x47>
		s += n;
		d += n;
  8008f0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f3:	89 d6                	mov    %edx,%esi
  8008f5:	09 fe                	or     %edi,%esi
  8008f7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008fd:	75 13                	jne    800912 <memmove+0x3b>
  8008ff:	f6 c1 03             	test   $0x3,%cl
  800902:	75 0e                	jne    800912 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800904:	83 ef 04             	sub    $0x4,%edi
  800907:	8d 72 fc             	lea    -0x4(%edx),%esi
  80090a:	c1 e9 02             	shr    $0x2,%ecx
  80090d:	fd                   	std    
  80090e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800910:	eb 09                	jmp    80091b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800912:	83 ef 01             	sub    $0x1,%edi
  800915:	8d 72 ff             	lea    -0x1(%edx),%esi
  800918:	fd                   	std    
  800919:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80091b:	fc                   	cld    
  80091c:	eb 1d                	jmp    80093b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091e:	89 f2                	mov    %esi,%edx
  800920:	09 c2                	or     %eax,%edx
  800922:	f6 c2 03             	test   $0x3,%dl
  800925:	75 0f                	jne    800936 <memmove+0x5f>
  800927:	f6 c1 03             	test   $0x3,%cl
  80092a:	75 0a                	jne    800936 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80092c:	c1 e9 02             	shr    $0x2,%ecx
  80092f:	89 c7                	mov    %eax,%edi
  800931:	fc                   	cld    
  800932:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800934:	eb 05                	jmp    80093b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800936:	89 c7                	mov    %eax,%edi
  800938:	fc                   	cld    
  800939:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80093b:	5e                   	pop    %esi
  80093c:	5f                   	pop    %edi
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800942:	ff 75 10             	pushl  0x10(%ebp)
  800945:	ff 75 0c             	pushl  0xc(%ebp)
  800948:	ff 75 08             	pushl  0x8(%ebp)
  80094b:	e8 87 ff ff ff       	call   8008d7 <memmove>
}
  800950:	c9                   	leave  
  800951:	c3                   	ret    

00800952 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	56                   	push   %esi
  800956:	53                   	push   %ebx
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095d:	89 c6                	mov    %eax,%esi
  80095f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800962:	eb 1a                	jmp    80097e <memcmp+0x2c>
		if (*s1 != *s2)
  800964:	0f b6 08             	movzbl (%eax),%ecx
  800967:	0f b6 1a             	movzbl (%edx),%ebx
  80096a:	38 d9                	cmp    %bl,%cl
  80096c:	74 0a                	je     800978 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80096e:	0f b6 c1             	movzbl %cl,%eax
  800971:	0f b6 db             	movzbl %bl,%ebx
  800974:	29 d8                	sub    %ebx,%eax
  800976:	eb 0f                	jmp    800987 <memcmp+0x35>
		s1++, s2++;
  800978:	83 c0 01             	add    $0x1,%eax
  80097b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097e:	39 f0                	cmp    %esi,%eax
  800980:	75 e2                	jne    800964 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800982:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800987:	5b                   	pop    %ebx
  800988:	5e                   	pop    %esi
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	53                   	push   %ebx
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800992:	89 c1                	mov    %eax,%ecx
  800994:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800997:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80099b:	eb 0a                	jmp    8009a7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80099d:	0f b6 10             	movzbl (%eax),%edx
  8009a0:	39 da                	cmp    %ebx,%edx
  8009a2:	74 07                	je     8009ab <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009a4:	83 c0 01             	add    $0x1,%eax
  8009a7:	39 c8                	cmp    %ecx,%eax
  8009a9:	72 f2                	jb     80099d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ab:	5b                   	pop    %ebx
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	57                   	push   %edi
  8009b2:	56                   	push   %esi
  8009b3:	53                   	push   %ebx
  8009b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ba:	eb 03                	jmp    8009bf <strtol+0x11>
		s++;
  8009bc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009bf:	0f b6 01             	movzbl (%ecx),%eax
  8009c2:	3c 20                	cmp    $0x20,%al
  8009c4:	74 f6                	je     8009bc <strtol+0xe>
  8009c6:	3c 09                	cmp    $0x9,%al
  8009c8:	74 f2                	je     8009bc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ca:	3c 2b                	cmp    $0x2b,%al
  8009cc:	75 0a                	jne    8009d8 <strtol+0x2a>
		s++;
  8009ce:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009d1:	bf 00 00 00 00       	mov    $0x0,%edi
  8009d6:	eb 11                	jmp    8009e9 <strtol+0x3b>
  8009d8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009dd:	3c 2d                	cmp    $0x2d,%al
  8009df:	75 08                	jne    8009e9 <strtol+0x3b>
		s++, neg = 1;
  8009e1:	83 c1 01             	add    $0x1,%ecx
  8009e4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009ef:	75 15                	jne    800a06 <strtol+0x58>
  8009f1:	80 39 30             	cmpb   $0x30,(%ecx)
  8009f4:	75 10                	jne    800a06 <strtol+0x58>
  8009f6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009fa:	75 7c                	jne    800a78 <strtol+0xca>
		s += 2, base = 16;
  8009fc:	83 c1 02             	add    $0x2,%ecx
  8009ff:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a04:	eb 16                	jmp    800a1c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a06:	85 db                	test   %ebx,%ebx
  800a08:	75 12                	jne    800a1c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a0a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a0f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a12:	75 08                	jne    800a1c <strtol+0x6e>
		s++, base = 8;
  800a14:	83 c1 01             	add    $0x1,%ecx
  800a17:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a21:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a24:	0f b6 11             	movzbl (%ecx),%edx
  800a27:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a2a:	89 f3                	mov    %esi,%ebx
  800a2c:	80 fb 09             	cmp    $0x9,%bl
  800a2f:	77 08                	ja     800a39 <strtol+0x8b>
			dig = *s - '0';
  800a31:	0f be d2             	movsbl %dl,%edx
  800a34:	83 ea 30             	sub    $0x30,%edx
  800a37:	eb 22                	jmp    800a5b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a39:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a3c:	89 f3                	mov    %esi,%ebx
  800a3e:	80 fb 19             	cmp    $0x19,%bl
  800a41:	77 08                	ja     800a4b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a43:	0f be d2             	movsbl %dl,%edx
  800a46:	83 ea 57             	sub    $0x57,%edx
  800a49:	eb 10                	jmp    800a5b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a4b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a4e:	89 f3                	mov    %esi,%ebx
  800a50:	80 fb 19             	cmp    $0x19,%bl
  800a53:	77 16                	ja     800a6b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a55:	0f be d2             	movsbl %dl,%edx
  800a58:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a5b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a5e:	7d 0b                	jge    800a6b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a60:	83 c1 01             	add    $0x1,%ecx
  800a63:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a67:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a69:	eb b9                	jmp    800a24 <strtol+0x76>

	if (endptr)
  800a6b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a6f:	74 0d                	je     800a7e <strtol+0xd0>
		*endptr = (char *) s;
  800a71:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a74:	89 0e                	mov    %ecx,(%esi)
  800a76:	eb 06                	jmp    800a7e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a78:	85 db                	test   %ebx,%ebx
  800a7a:	74 98                	je     800a14 <strtol+0x66>
  800a7c:	eb 9e                	jmp    800a1c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a7e:	89 c2                	mov    %eax,%edx
  800a80:	f7 da                	neg    %edx
  800a82:	85 ff                	test   %edi,%edi
  800a84:	0f 45 c2             	cmovne %edx,%eax
}
  800a87:	5b                   	pop    %ebx
  800a88:	5e                   	pop    %esi
  800a89:	5f                   	pop    %edi
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	57                   	push   %edi
  800a90:	56                   	push   %esi
  800a91:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a92:	b8 00 00 00 00       	mov    $0x0,%eax
  800a97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9d:	89 c3                	mov    %eax,%ebx
  800a9f:	89 c7                	mov    %eax,%edi
  800aa1:	89 c6                	mov    %eax,%esi
  800aa3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5f                   	pop    %edi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <sys_cgetc>:

int
sys_cgetc(void)
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
  800ab5:	b8 01 00 00 00       	mov    $0x1,%eax
  800aba:	89 d1                	mov    %edx,%ecx
  800abc:	89 d3                	mov    %edx,%ebx
  800abe:	89 d7                	mov    %edx,%edi
  800ac0:	89 d6                	mov    %edx,%esi
  800ac2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ac4:	5b                   	pop    %ebx
  800ac5:	5e                   	pop    %esi
  800ac6:	5f                   	pop    %edi
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	57                   	push   %edi
  800acd:	56                   	push   %esi
  800ace:	53                   	push   %ebx
  800acf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ad7:	b8 03 00 00 00       	mov    $0x3,%eax
  800adc:	8b 55 08             	mov    0x8(%ebp),%edx
  800adf:	89 cb                	mov    %ecx,%ebx
  800ae1:	89 cf                	mov    %ecx,%edi
  800ae3:	89 ce                	mov    %ecx,%esi
  800ae5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ae7:	85 c0                	test   %eax,%eax
  800ae9:	7e 17                	jle    800b02 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aeb:	83 ec 0c             	sub    $0xc,%esp
  800aee:	50                   	push   %eax
  800aef:	6a 03                	push   $0x3
  800af1:	68 a8 18 80 00       	push   $0x8018a8
  800af6:	6a 23                	push   $0x23
  800af8:	68 c5 18 80 00       	push   $0x8018c5
  800afd:	e8 a1 07 00 00       	call   8012a3 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5f                   	pop    %edi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	57                   	push   %edi
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b10:	ba 00 00 00 00       	mov    $0x0,%edx
  800b15:	b8 02 00 00 00       	mov    $0x2,%eax
  800b1a:	89 d1                	mov    %edx,%ecx
  800b1c:	89 d3                	mov    %edx,%ebx
  800b1e:	89 d7                	mov    %edx,%edi
  800b20:	89 d6                	mov    %edx,%esi
  800b22:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b24:	5b                   	pop    %ebx
  800b25:	5e                   	pop    %esi
  800b26:	5f                   	pop    %edi
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <sys_yield>:

void
sys_yield(void)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	57                   	push   %edi
  800b2d:	56                   	push   %esi
  800b2e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b34:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b39:	89 d1                	mov    %edx,%ecx
  800b3b:	89 d3                	mov    %edx,%ebx
  800b3d:	89 d7                	mov    %edx,%edi
  800b3f:	89 d6                	mov    %edx,%esi
  800b41:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b43:	5b                   	pop    %ebx
  800b44:	5e                   	pop    %esi
  800b45:	5f                   	pop    %edi
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    

00800b48 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	57                   	push   %edi
  800b4c:	56                   	push   %esi
  800b4d:	53                   	push   %ebx
  800b4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b51:	be 00 00 00 00       	mov    $0x0,%esi
  800b56:	b8 04 00 00 00       	mov    $0x4,%eax
  800b5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b64:	89 f7                	mov    %esi,%edi
  800b66:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b68:	85 c0                	test   %eax,%eax
  800b6a:	7e 17                	jle    800b83 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6c:	83 ec 0c             	sub    $0xc,%esp
  800b6f:	50                   	push   %eax
  800b70:	6a 04                	push   $0x4
  800b72:	68 a8 18 80 00       	push   $0x8018a8
  800b77:	6a 23                	push   $0x23
  800b79:	68 c5 18 80 00       	push   $0x8018c5
  800b7e:	e8 20 07 00 00       	call   8012a3 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5f                   	pop    %edi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	57                   	push   %edi
  800b8f:	56                   	push   %esi
  800b90:	53                   	push   %ebx
  800b91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b94:	b8 05 00 00 00       	mov    $0x5,%eax
  800b99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ba5:	8b 75 18             	mov    0x18(%ebp),%esi
  800ba8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800baa:	85 c0                	test   %eax,%eax
  800bac:	7e 17                	jle    800bc5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bae:	83 ec 0c             	sub    $0xc,%esp
  800bb1:	50                   	push   %eax
  800bb2:	6a 05                	push   $0x5
  800bb4:	68 a8 18 80 00       	push   $0x8018a8
  800bb9:	6a 23                	push   $0x23
  800bbb:	68 c5 18 80 00       	push   $0x8018c5
  800bc0:	e8 de 06 00 00       	call   8012a3 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bdb:	b8 06 00 00 00       	mov    $0x6,%eax
  800be0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be3:	8b 55 08             	mov    0x8(%ebp),%edx
  800be6:	89 df                	mov    %ebx,%edi
  800be8:	89 de                	mov    %ebx,%esi
  800bea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bec:	85 c0                	test   %eax,%eax
  800bee:	7e 17                	jle    800c07 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf0:	83 ec 0c             	sub    $0xc,%esp
  800bf3:	50                   	push   %eax
  800bf4:	6a 06                	push   $0x6
  800bf6:	68 a8 18 80 00       	push   $0x8018a8
  800bfb:	6a 23                	push   $0x23
  800bfd:	68 c5 18 80 00       	push   $0x8018c5
  800c02:	e8 9c 06 00 00       	call   8012a3 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0a:	5b                   	pop    %ebx
  800c0b:	5e                   	pop    %esi
  800c0c:	5f                   	pop    %edi
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	57                   	push   %edi
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
  800c15:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c1d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c25:	8b 55 08             	mov    0x8(%ebp),%edx
  800c28:	89 df                	mov    %ebx,%edi
  800c2a:	89 de                	mov    %ebx,%esi
  800c2c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c2e:	85 c0                	test   %eax,%eax
  800c30:	7e 17                	jle    800c49 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c32:	83 ec 0c             	sub    $0xc,%esp
  800c35:	50                   	push   %eax
  800c36:	6a 08                	push   $0x8
  800c38:	68 a8 18 80 00       	push   $0x8018a8
  800c3d:	6a 23                	push   $0x23
  800c3f:	68 c5 18 80 00       	push   $0x8018c5
  800c44:	e8 5a 06 00 00       	call   8012a3 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4c:	5b                   	pop    %ebx
  800c4d:	5e                   	pop    %esi
  800c4e:	5f                   	pop    %edi
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	57                   	push   %edi
  800c55:	56                   	push   %esi
  800c56:	53                   	push   %ebx
  800c57:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5f:	b8 09 00 00 00       	mov    $0x9,%eax
  800c64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c67:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6a:	89 df                	mov    %ebx,%edi
  800c6c:	89 de                	mov    %ebx,%esi
  800c6e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c70:	85 c0                	test   %eax,%eax
  800c72:	7e 17                	jle    800c8b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c74:	83 ec 0c             	sub    $0xc,%esp
  800c77:	50                   	push   %eax
  800c78:	6a 09                	push   $0x9
  800c7a:	68 a8 18 80 00       	push   $0x8018a8
  800c7f:	6a 23                	push   $0x23
  800c81:	68 c5 18 80 00       	push   $0x8018c5
  800c86:	e8 18 06 00 00       	call   8012a3 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c99:	be 00 00 00 00       	mov    $0x0,%esi
  800c9e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ca3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cac:	8b 7d 14             	mov    0x14(%ebp),%edi
  800caf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
  800cbc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccc:	89 cb                	mov    %ecx,%ebx
  800cce:	89 cf                	mov    %ecx,%edi
  800cd0:	89 ce                	mov    %ecx,%esi
  800cd2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd4:	85 c0                	test   %eax,%eax
  800cd6:	7e 17                	jle    800cef <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd8:	83 ec 0c             	sub    $0xc,%esp
  800cdb:	50                   	push   %eax
  800cdc:	6a 0c                	push   $0xc
  800cde:	68 a8 18 80 00       	push   $0x8018a8
  800ce3:	6a 23                	push   $0x23
  800ce5:	68 c5 18 80 00       	push   $0x8018c5
  800cea:	e8 b4 05 00 00       	call   8012a3 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf2:	5b                   	pop    %ebx
  800cf3:	5e                   	pop    %esi
  800cf4:	5f                   	pop    %edi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    

00800cf7 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	57                   	push   %edi
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
  800cfd:	83 ec 0c             	sub    $0xc,%esp
  800d00:	89 c7                	mov    %eax,%edi
  800d02:	89 d3                	mov    %edx,%ebx
	int r;

	// LAB 4: Your code here.

    envid_t myenvid = sys_getenvid();
  800d04:	e8 01 fe ff ff       	call   800b0a <sys_getenvid>
  800d09:	89 c6                	mov    %eax,%esi
    pte_t pte = uvpt[pn];
  800d0b:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    int perm;

    perm = PTE_U | PTE_P;
    if(pte & PTE_W || pte & PTE_COW)
  800d12:	a9 02 08 00 00       	test   $0x802,%eax
  800d17:	75 40                	jne    800d59 <duppage+0x62>
    {
        perm |= PTE_COW;
    }

    // map to envid VA
    if ((r = sys_page_map(myenvid,
  800d19:	c1 e3 0c             	shl    $0xc,%ebx
  800d1c:	83 ec 0c             	sub    $0xc,%esp
  800d1f:	6a 05                	push   $0x5
  800d21:	53                   	push   %ebx
  800d22:	57                   	push   %edi
  800d23:	53                   	push   %ebx
  800d24:	56                   	push   %esi
  800d25:	e8 61 fe ff ff       	call   800b8b <sys_page_map>
  800d2a:	83 c4 20             	add    $0x20,%esp
  800d2d:	85 c0                	test   %eax,%eax
  800d2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d34:	0f 4f c2             	cmovg  %edx,%eax
  800d37:	eb 3b                	jmp    800d74 <duppage+0x7d>
    }

    // if COW remap to self
    if(perm & PTE_COW)
    {
        if((r = sys_page_map(myenvid, 
  800d39:	83 ec 0c             	sub    $0xc,%esp
  800d3c:	68 05 08 00 00       	push   $0x805
  800d41:	53                   	push   %ebx
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
  800d44:	56                   	push   %esi
  800d45:	e8 41 fe ff ff       	call   800b8b <sys_page_map>
  800d4a:	83 c4 20             	add    $0x20,%esp
  800d4d:	85 c0                	test   %eax,%eax
  800d4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d54:	0f 4f c2             	cmovg  %edx,%eax
  800d57:	eb 1b                	jmp    800d74 <duppage+0x7d>
    {
        perm |= PTE_COW;
    }

    // map to envid VA
    if ((r = sys_page_map(myenvid,
  800d59:	c1 e3 0c             	shl    $0xc,%ebx
  800d5c:	83 ec 0c             	sub    $0xc,%esp
  800d5f:	68 05 08 00 00       	push   $0x805
  800d64:	53                   	push   %ebx
  800d65:	57                   	push   %edi
  800d66:	53                   	push   %ebx
  800d67:	56                   	push   %esi
  800d68:	e8 1e fe ff ff       	call   800b8b <sys_page_map>
  800d6d:	83 c4 20             	add    $0x20,%esp
  800d70:	85 c0                	test   %eax,%eax
  800d72:	79 c5                	jns    800d39 <duppage+0x42>
            return r;
        }
    }

	return 0;
}
  800d74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d77:	5b                   	pop    %ebx
  800d78:	5e                   	pop    %esi
  800d79:	5f                   	pop    %edi
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	56                   	push   %esi
  800d80:	53                   	push   %ebx
  800d81:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d84:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

    if ((err & FEC_WR) == 0)
  800d86:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d8a:	75 12                	jne    800d9e <pgfault+0x22>
    {
        panic("pgfault: page fault was not caused by write; %x.\n", utf->utf_fault_va);
  800d8c:	53                   	push   %ebx
  800d8d:	68 d4 18 80 00       	push   $0x8018d4
  800d92:	6a 1f                	push   $0x1f
  800d94:	68 ab 19 80 00       	push   $0x8019ab
  800d99:	e8 05 05 00 00       	call   8012a3 <_panic>
    }

    if ((uvpt[PGNUM(addr)] & PTE_COW) == 0) 
  800d9e:	89 d8                	mov    %ebx,%eax
  800da0:	c1 e8 0c             	shr    $0xc,%eax
  800da3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800daa:	f6 c4 08             	test   $0x8,%ah
  800dad:	75 12                	jne    800dc1 <pgfault+0x45>
    {
        panic("pgfault: page fault on page which is not COW %x.\n", utf->utf_fault_va);
  800daf:	53                   	push   %ebx
  800db0:	68 08 19 80 00       	push   $0x801908
  800db5:	6a 24                	push   $0x24
  800db7:	68 ab 19 80 00       	push   $0x8019ab
  800dbc:	e8 e2 04 00 00       	call   8012a3 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    envid_t envid = sys_getenvid();
  800dc1:	e8 44 fd ff ff       	call   800b0a <sys_getenvid>
  800dc6:	89 c6                	mov    %eax,%esi

    //allocate temp page
    if (sys_page_alloc(envid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  800dc8:	83 ec 04             	sub    $0x4,%esp
  800dcb:	6a 07                	push   $0x7
  800dcd:	68 00 f0 7f 00       	push   $0x7ff000
  800dd2:	50                   	push   %eax
  800dd3:	e8 70 fd ff ff       	call   800b48 <sys_page_alloc>
  800dd8:	83 c4 10             	add    $0x10,%esp
  800ddb:	85 c0                	test   %eax,%eax
  800ddd:	79 14                	jns    800df3 <pgfault+0x77>
    {
        panic("pgfault: can't allocate temp page.\n");
  800ddf:	83 ec 04             	sub    $0x4,%esp
  800de2:	68 3c 19 80 00       	push   $0x80193c
  800de7:	6a 32                	push   $0x32
  800de9:	68 ab 19 80 00       	push   $0x8019ab
  800dee:	e8 b0 04 00 00       	call   8012a3 <_panic>
    }

    memmove(PFTEMP, (void *)ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800df3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800df9:	83 ec 04             	sub    $0x4,%esp
  800dfc:	68 00 10 00 00       	push   $0x1000
  800e01:	53                   	push   %ebx
  800e02:	68 00 f0 7f 00       	push   $0x7ff000
  800e07:	e8 cb fa ff ff       	call   8008d7 <memmove>

    if(sys_page_map(envid, PFTEMP, envid, (void *)ROUNDDOWN(addr, PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
  800e0c:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e13:	53                   	push   %ebx
  800e14:	56                   	push   %esi
  800e15:	68 00 f0 7f 00       	push   $0x7ff000
  800e1a:	56                   	push   %esi
  800e1b:	e8 6b fd ff ff       	call   800b8b <sys_page_map>
  800e20:	83 c4 20             	add    $0x20,%esp
  800e23:	85 c0                	test   %eax,%eax
  800e25:	79 14                	jns    800e3b <pgfault+0xbf>
    {
        panic("pgfault: can't map temp page to old page.\n");
  800e27:	83 ec 04             	sub    $0x4,%esp
  800e2a:	68 60 19 80 00       	push   $0x801960
  800e2f:	6a 39                	push   $0x39
  800e31:	68 ab 19 80 00       	push   $0x8019ab
  800e36:	e8 68 04 00 00       	call   8012a3 <_panic>
    }

    if(sys_page_unmap(envid, PFTEMP) < 0)
  800e3b:	83 ec 08             	sub    $0x8,%esp
  800e3e:	68 00 f0 7f 00       	push   $0x7ff000
  800e43:	56                   	push   %esi
  800e44:	e8 84 fd ff ff       	call   800bcd <sys_page_unmap>
  800e49:	83 c4 10             	add    $0x10,%esp
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	79 14                	jns    800e64 <pgfault+0xe8>
    {
        panic("pgfault: couldn't unmap page.\n");
  800e50:	83 ec 04             	sub    $0x4,%esp
  800e53:	68 8c 19 80 00       	push   $0x80198c
  800e58:	6a 3e                	push   $0x3e
  800e5a:	68 ab 19 80 00       	push   $0x8019ab
  800e5f:	e8 3f 04 00 00       	call   8012a3 <_panic>
    }
	//panic("pgfault not implemented");
}
  800e64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e67:	5b                   	pop    %ebx
  800e68:	5e                   	pop    %esi
  800e69:	5d                   	pop    %ebp
  800e6a:	c3                   	ret    

00800e6b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	57                   	push   %edi
  800e6f:	56                   	push   %esi
  800e70:	53                   	push   %ebx
  800e71:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    extern void _pgfault_upcall(void);
    envid_t myenvid = sys_getenvid();
  800e74:	e8 91 fc ff ff       	call   800b0a <sys_getenvid>
  800e79:	89 45 e0             	mov    %eax,-0x20(%ebp)
    envid_t envid;
    uint32_t i, j, pn;

    //set page fault handler
    set_pgfault_handler(pgfault);
  800e7c:	83 ec 0c             	sub    $0xc,%esp
  800e7f:	68 7c 0d 80 00       	push   $0x800d7c
  800e84:	e8 60 04 00 00       	call   8012e9 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e89:	b8 07 00 00 00       	mov    $0x7,%eax
  800e8e:	cd 30                	int    $0x30
  800e90:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e93:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    //create a child
    if((envid = sys_exofork()) < 0)
  800e96:	83 c4 10             	add    $0x10,%esp
  800e99:	85 c0                	test   %eax,%eax
  800e9b:	0f 88 13 01 00 00    	js     800fb4 <fork+0x149>
  800ea1:	bf 02 00 00 00       	mov    $0x2,%edi
    {
        return -1;
    }

    if(envid == 0)
  800ea6:	85 c0                	test   %eax,%eax
  800ea8:	75 21                	jne    800ecb <fork+0x60>
    {
        thisenv = &envs[ENVX(sys_getenvid())];
  800eaa:	e8 5b fc ff ff       	call   800b0a <sys_getenvid>
  800eaf:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eb4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800eb7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ebc:	a3 04 20 80 00       	mov    %eax,0x802004

        return envid;
  800ec1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec6:	e9 0a 01 00 00       	jmp    800fd5 <fork+0x16a>
    }

    //copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
  800ecb:	8b 04 bd 00 d0 7b ef 	mov    -0x10843000(,%edi,4),%eax
  800ed2:	a8 01                	test   $0x1,%al
  800ed4:	74 3a                	je     800f10 <fork+0xa5>
        {
            for (j = 0; j < NPTENTRIES; j++)
            {
                pn = PGNUM(PGADDR(i, j, 0));
  800ed6:	89 fe                	mov    %edi,%esi
  800ed8:	c1 e6 16             	shl    $0x16,%esi
  800edb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee0:	89 da                	mov    %ebx,%edx
  800ee2:	c1 e2 0c             	shl    $0xc,%edx
  800ee5:	09 f2                	or     %esi,%edx
  800ee7:	c1 ea 0c             	shr    $0xc,%edx
                if(pn == PGNUM(UXSTACKTOP - PGSIZE))
  800eea:	81 fa ff eb 0e 00    	cmp    $0xeebff,%edx
  800ef0:	74 1e                	je     800f10 <fork+0xa5>
                {
                    break;
                }

                if(uvpt[pn] & PTE_P)
  800ef2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800ef9:	a8 01                	test   $0x1,%al
  800efb:	74 08                	je     800f05 <fork+0x9a>
                {
                    duppage(envid, pn);
  800efd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f00:	e8 f2 fd ff ff       	call   800cf7 <duppage>
    //copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
        {
            for (j = 0; j < NPTENTRIES; j++)
  800f05:	83 c3 01             	add    $0x1,%ebx
  800f08:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  800f0e:	75 d0                	jne    800ee0 <fork+0x75>

        return envid;
    }

    //copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
  800f10:	83 c7 01             	add    $0x1,%edi
  800f13:	81 ff bb 03 00 00    	cmp    $0x3bb,%edi
  800f19:	75 b0                	jne    800ecb <fork+0x60>
                }
            }
        }
    }

    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
  800f1b:	83 ec 04             	sub    $0x4,%esp
  800f1e:	6a 07                	push   $0x7
  800f20:	68 00 f0 bf ee       	push   $0xeebff000
  800f25:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800f28:	57                   	push   %edi
  800f29:	e8 1a fc ff ff       	call   800b48 <sys_page_alloc>
  800f2e:	83 c4 10             	add    $0x10,%esp
  800f31:	85 c0                	test   %eax,%eax
  800f33:	0f 88 82 00 00 00    	js     800fbb <fork+0x150>
    {
        return -1;
    }

    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  800f39:	83 ec 0c             	sub    $0xc,%esp
  800f3c:	6a 07                	push   $0x7
  800f3e:	68 00 f0 7f 00       	push   $0x7ff000
  800f43:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800f46:	56                   	push   %esi
  800f47:	68 00 f0 bf ee       	push   $0xeebff000
  800f4c:	57                   	push   %edi
  800f4d:	e8 39 fc ff ff       	call   800b8b <sys_page_map>
  800f52:	83 c4 20             	add    $0x20,%esp
  800f55:	85 c0                	test   %eax,%eax
  800f57:	78 69                	js     800fc2 <fork+0x157>
    {
        return -1;
    }

    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);
  800f59:	83 ec 04             	sub    $0x4,%esp
  800f5c:	68 00 10 00 00       	push   $0x1000
  800f61:	68 00 f0 7f 00       	push   $0x7ff000
  800f66:	68 00 f0 bf ee       	push   $0xeebff000
  800f6b:	e8 67 f9 ff ff       	call   8008d7 <memmove>

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
  800f70:	83 c4 08             	add    $0x8,%esp
  800f73:	68 00 f0 7f 00       	push   $0x7ff000
  800f78:	56                   	push   %esi
  800f79:	e8 4f fc ff ff       	call   800bcd <sys_page_unmap>
  800f7e:	83 c4 10             	add    $0x10,%esp
  800f81:	85 c0                	test   %eax,%eax
  800f83:	78 44                	js     800fc9 <fork+0x15e>
    {
        return -1;
    }

    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
  800f85:	83 ec 08             	sub    $0x8,%esp
  800f88:	68 4e 13 80 00       	push   $0x80134e
  800f8d:	57                   	push   %edi
  800f8e:	e8 be fc ff ff       	call   800c51 <sys_env_set_pgfault_upcall>
  800f93:	83 c4 10             	add    $0x10,%esp
  800f96:	85 c0                	test   %eax,%eax
  800f98:	78 36                	js     800fd0 <fork+0x165>
    {
        return -1;
    }

    if(sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  800f9a:	83 ec 08             	sub    $0x8,%esp
  800f9d:	6a 02                	push   $0x2
  800f9f:	57                   	push   %edi
  800fa0:	e8 6a fc ff ff       	call   800c0f <sys_env_set_status>
  800fa5:	83 c4 10             	add    $0x10,%esp
    {
        return -1;
    }

    return envid;
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800faf:	0f 49 c7             	cmovns %edi,%eax
  800fb2:	eb 21                	jmp    800fd5 <fork+0x16a>
    set_pgfault_handler(pgfault);

    //create a child
    if((envid = sys_exofork()) < 0)
    {
        return -1;
  800fb4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800fb9:	eb 1a                	jmp    800fd5 <fork+0x16a>
        }
    }

    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  800fbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800fc0:	eb 13                	jmp    800fd5 <fork+0x16a>
    }

    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  800fc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800fc7:	eb 0c                	jmp    800fd5 <fork+0x16a>

    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
    {
        return -1;
  800fc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800fce:	eb 05                	jmp    800fd5 <fork+0x16a>
    }

    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
    {
        return -1;
  800fd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
        return -1;
    }

    return envid;
    //	panic("fork not implemented");
}
  800fd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd8:	5b                   	pop    %ebx
  800fd9:	5e                   	pop    %esi
  800fda:	5f                   	pop    %edi
  800fdb:	5d                   	pop    %ebp
  800fdc:	c3                   	ret    

00800fdd <sfork>:

// Challenge!
int
sfork(void)
{
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	57                   	push   %edi
  800fe1:	56                   	push   %esi
  800fe2:	53                   	push   %ebx
  800fe3:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    extern void _pgfault_upcall(void);
    envid_t myenvid = sys_getenvid();
  800fe6:	e8 1f fb ff ff       	call   800b0a <sys_getenvid>
  800feb:	89 45 e0             	mov    %eax,-0x20(%ebp)
    envid_t envid;
    uint32_t i, j, pn;
    int perm;

    // set page fault handler
    set_pgfault_handler(pgfault);
  800fee:	83 ec 0c             	sub    $0xc,%esp
  800ff1:	68 7c 0d 80 00       	push   $0x800d7c
  800ff6:	e8 ee 02 00 00       	call   8012e9 <set_pgfault_handler>
  800ffb:	b8 07 00 00 00       	mov    $0x7,%eax
  801000:	cd 30                	int    $0x30
  801002:	89 45 dc             	mov    %eax,-0x24(%ebp)

    // create a child
    if((envid = sys_exofork()) < 0)
  801005:	83 c4 10             	add    $0x10,%esp
  801008:	85 c0                	test   %eax,%eax
  80100a:	0f 88 5d 01 00 00    	js     80116d <sfork+0x190>
  801010:	89 c7                	mov    %eax,%edi
  801012:	c7 45 e4 02 00 00 00 	movl   $0x2,-0x1c(%ebp)
    {
        return -1;
    }

    if(envid == 0)
  801019:	85 c0                	test   %eax,%eax
  80101b:	75 21                	jne    80103e <sfork+0x61>
    {
        thisenv = &envs[ENVX(sys_getenvid())];
  80101d:	e8 e8 fa ff ff       	call   800b0a <sys_getenvid>
  801022:	25 ff 03 00 00       	and    $0x3ff,%eax
  801027:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80102a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80102f:	a3 04 20 80 00       	mov    %eax,0x802004
        return envid;
  801034:	b8 00 00 00 00       	mov    $0x0,%eax
  801039:	e9 57 01 00 00       	jmp    801195 <sfork+0x1b8>
    }

    // copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
  80103e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801041:	8b 04 b5 00 d0 7b ef 	mov    -0x10843000(,%esi,4),%eax
  801048:	a8 01                	test   $0x1,%al
  80104a:	74 76                	je     8010c2 <sfork+0xe5>
        {
            for (j = 0; j < NPTENTRIES; j++)
            {
                pn = PGNUM(PGADDR(i, j, 0));
  80104c:	c1 e6 16             	shl    $0x16,%esi
  80104f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801054:	89 d8                	mov    %ebx,%eax
  801056:	c1 e0 0c             	shl    $0xc,%eax
  801059:	09 f0                	or     %esi,%eax
  80105b:	89 c2                	mov    %eax,%edx
  80105d:	c1 ea 0c             	shr    $0xc,%edx
                if(pn == PGNUM(UXSTACKTOP - PGSIZE))
  801060:	81 fa ff eb 0e 00    	cmp    $0xeebff,%edx
  801066:	74 5a                	je     8010c2 <sfork+0xe5>
                {
                    break;
                }

                if(pn == PGNUM(USTACKTOP - PGSIZE))
  801068:	81 fa fd eb 0e 00    	cmp    $0xeebfd,%edx
  80106e:	75 09                	jne    801079 <sfork+0x9c>
                {
                     duppage(envid, pn); // cow for stack page
  801070:	89 f8                	mov    %edi,%eax
  801072:	e8 80 fc ff ff       	call   800cf7 <duppage>
                     continue;
  801077:	eb 3e                	jmp    8010b7 <sfork+0xda>
                }

                // map same page to child env with same perms
                if (uvpt[pn] & PTE_P)
  801079:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801080:	f6 c1 01             	test   $0x1,%cl
  801083:	74 32                	je     8010b7 <sfork+0xda>
                {
                    
                    perm = uvpt[pn] & ~(uvpt[pn] & ~(PTE_P |PTE_U | PTE_W | PTE_AVAIL));
  801085:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  80108c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
                    if (sys_page_map(myenvid, (void *)(PGADDR(i, j, 0)),
  801093:	83 ec 0c             	sub    $0xc,%esp
  801096:	81 e2 f8 f1 ff ff    	and    $0xfffff1f8,%edx
  80109c:	f7 d2                	not    %edx
  80109e:	21 d1                	and    %edx,%ecx
  8010a0:	51                   	push   %ecx
  8010a1:	50                   	push   %eax
  8010a2:	57                   	push   %edi
  8010a3:	50                   	push   %eax
  8010a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8010a7:	e8 df fa ff ff       	call   800b8b <sys_page_map>
  8010ac:	83 c4 20             	add    $0x20,%esp
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	0f 88 bd 00 00 00    	js     801174 <sfork+0x197>
    // copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
        {
            for (j = 0; j < NPTENTRIES; j++)
  8010b7:	83 c3 01             	add    $0x1,%ebx
  8010ba:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  8010c0:	75 92                	jne    801054 <sfork+0x77>
        thisenv = &envs[ENVX(sys_getenvid())];
        return envid;
    }

    // copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
  8010c2:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  8010c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010c9:	3d bb 03 00 00       	cmp    $0x3bb,%eax
  8010ce:	0f 85 6a ff ff ff    	jne    80103e <sfork+0x61>
            }
        }
    }

    // allocate new exception stack for child
    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
  8010d4:	83 ec 04             	sub    $0x4,%esp
  8010d7:	6a 07                	push   $0x7
  8010d9:	68 00 f0 bf ee       	push   $0xeebff000
  8010de:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8010e1:	57                   	push   %edi
  8010e2:	e8 61 fa ff ff       	call   800b48 <sys_page_alloc>
  8010e7:	83 c4 10             	add    $0x10,%esp
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	0f 88 89 00 00 00    	js     80117b <sfork+0x19e>
    {
        return -1;
    }

    // map child uxstack to temp page
    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  8010f2:	83 ec 0c             	sub    $0xc,%esp
  8010f5:	6a 07                	push   $0x7
  8010f7:	68 00 f0 7f 00       	push   $0x7ff000
  8010fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8010ff:	56                   	push   %esi
  801100:	68 00 f0 bf ee       	push   $0xeebff000
  801105:	57                   	push   %edi
  801106:	e8 80 fa ff ff       	call   800b8b <sys_page_map>
  80110b:	83 c4 20             	add    $0x20,%esp
  80110e:	85 c0                	test   %eax,%eax
  801110:	78 70                	js     801182 <sfork+0x1a5>
    {
        return -1;
    }

    // copy own uxstack to temp page
    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);
  801112:	83 ec 04             	sub    $0x4,%esp
  801115:	68 00 10 00 00       	push   $0x1000
  80111a:	68 00 f0 7f 00       	push   $0x7ff000
  80111f:	68 00 f0 bf ee       	push   $0xeebff000
  801124:	e8 ae f7 ff ff       	call   8008d7 <memmove>

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
  801129:	83 c4 08             	add    $0x8,%esp
  80112c:	68 00 f0 7f 00       	push   $0x7ff000
  801131:	56                   	push   %esi
  801132:	e8 96 fa ff ff       	call   800bcd <sys_page_unmap>
  801137:	83 c4 10             	add    $0x10,%esp
  80113a:	85 c0                	test   %eax,%eax
  80113c:	78 4b                	js     801189 <sfork+0x1ac>
    {
        return -1;
    }

    // set page fault handler in child
    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
  80113e:	83 ec 08             	sub    $0x8,%esp
  801141:	68 4e 13 80 00       	push   $0x80134e
  801146:	57                   	push   %edi
  801147:	e8 05 fb ff ff       	call   800c51 <sys_env_set_pgfault_upcall>
  80114c:	83 c4 10             	add    $0x10,%esp
  80114f:	85 c0                	test   %eax,%eax
  801151:	78 3d                	js     801190 <sfork+0x1b3>
    {
        return -1;
    }

    // mark child env as RUNNABLE
    if(sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  801153:	83 ec 08             	sub    $0x8,%esp
  801156:	6a 02                	push   $0x2
  801158:	57                   	push   %edi
  801159:	e8 b1 fa ff ff       	call   800c0f <sys_env_set_status>
  80115e:	83 c4 10             	add    $0x10,%esp
    {
        return -1;
    }

    return envid;
  801161:	85 c0                	test   %eax,%eax
  801163:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801168:	0f 49 c7             	cmovns %edi,%eax
  80116b:	eb 28                	jmp    801195 <sfork+0x1b8>
    set_pgfault_handler(pgfault);

    // create a child
    if((envid = sys_exofork()) < 0)
    {
        return -1;
  80116d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801172:	eb 21                	jmp    801195 <sfork+0x1b8>
                    
                    perm = uvpt[pn] & ~(uvpt[pn] & ~(PTE_P |PTE_U | PTE_W | PTE_AVAIL));
                    if (sys_page_map(myenvid, (void *)(PGADDR(i, j, 0)),
                                     envid,   (void *)(PGADDR(i, j, 0)), perm) < 0)
                    {
                        return -1;
  801174:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801179:	eb 1a                	jmp    801195 <sfork+0x1b8>
    }

    // allocate new exception stack for child
    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  80117b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801180:	eb 13                	jmp    801195 <sfork+0x1b8>
    }

    // map child uxstack to temp page
    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  801182:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801187:	eb 0c                	jmp    801195 <sfork+0x1b8>
    // copy own uxstack to temp page
    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
    {
        return -1;
  801189:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80118e:	eb 05                	jmp    801195 <sfork+0x1b8>
    }

    // set page fault handler in child
    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
    {
        return -1;
  801190:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    {
        return -1;
    }

    return envid;
}
  801195:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801198:	5b                   	pop    %ebx
  801199:	5e                   	pop    %esi
  80119a:	5f                   	pop    %edi
  80119b:	5d                   	pop    %ebp
  80119c:	c3                   	ret    

0080119d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	57                   	push   %edi
  8011a1:	56                   	push   %esi
  8011a2:	53                   	push   %ebx
  8011a3:	83 ec 18             	sub    $0x18,%esp
  8011a6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011ac:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
    int r = sys_ipc_recv((pg) ? pg : (void *)UTOP);
  8011af:	85 db                	test   %ebx,%ebx
  8011b1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8011b6:	0f 45 c3             	cmovne %ebx,%eax
  8011b9:	50                   	push   %eax
  8011ba:	e8 f7 fa ff ff       	call   800cb6 <sys_ipc_recv>
  8011bf:	89 c2                	mov    %eax,%edx

    if (from_env_store)
  8011c1:	83 c4 10             	add    $0x10,%esp
  8011c4:	85 ff                	test   %edi,%edi
  8011c6:	74 13                	je     8011db <ipc_recv+0x3e>
    {
        *from_env_store = (r == 0) ? thisenv->env_ipc_from : 0;
  8011c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8011cd:	85 d2                	test   %edx,%edx
  8011cf:	75 08                	jne    8011d9 <ipc_recv+0x3c>
  8011d1:	a1 04 20 80 00       	mov    0x802004,%eax
  8011d6:	8b 40 74             	mov    0x74(%eax),%eax
  8011d9:	89 07                	mov    %eax,(%edi)
    }

    if (perm_store)
  8011db:	85 f6                	test   %esi,%esi
  8011dd:	74 1d                	je     8011fc <ipc_recv+0x5f>
    {
        *perm_store = (r == 0 && (uint32_t) pg < UTOP) ? thisenv->env_ipc_perm : 0;
  8011df:	85 d2                	test   %edx,%edx
  8011e1:	75 12                	jne    8011f5 <ipc_recv+0x58>
  8011e3:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  8011e9:	77 0a                	ja     8011f5 <ipc_recv+0x58>
  8011eb:	a1 04 20 80 00       	mov    0x802004,%eax
  8011f0:	8b 40 78             	mov    0x78(%eax),%eax
  8011f3:	eb 05                	jmp    8011fa <ipc_recv+0x5d>
  8011f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011fa:	89 06                	mov    %eax,(%esi)
    }

    if (r)
    {
        return r;
  8011fc:	89 d0                	mov    %edx,%eax
    if (perm_store)
    {
        *perm_store = (r == 0 && (uint32_t) pg < UTOP) ? thisenv->env_ipc_perm : 0;
    }

    if (r)
  8011fe:	85 d2                	test   %edx,%edx
  801200:	75 08                	jne    80120a <ipc_recv+0x6d>
    {
        return r;
    }

    return thisenv->env_ipc_value;
  801202:	a1 04 20 80 00       	mov    0x802004,%eax
  801207:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  80120a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80120d:	5b                   	pop    %ebx
  80120e:	5e                   	pop    %esi
  80120f:	5f                   	pop    %edi
  801210:	5d                   	pop    %ebp
  801211:	c3                   	ret    

00801212 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801212:	55                   	push   %ebp
  801213:	89 e5                	mov    %esp,%ebp
  801215:	57                   	push   %edi
  801216:	56                   	push   %esi
  801217:	53                   	push   %ebx
  801218:	83 ec 0c             	sub    $0xc,%esp
  80121b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80121e:	8b 45 10             	mov    0x10(%ebp),%eax
  801221:	85 c0                	test   %eax,%eax
  801223:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
  801228:	0f 45 f0             	cmovne %eax,%esi
	// LAB 4: Your code here.
 
    int r = 0;
    do
    {
        r = sys_ipc_try_send(to_env, val, pg ? pg : (void *)UTOP, perm);
  80122b:	ff 75 14             	pushl  0x14(%ebp)
  80122e:	56                   	push   %esi
  80122f:	ff 75 0c             	pushl  0xc(%ebp)
  801232:	57                   	push   %edi
  801233:	e8 5b fa ff ff       	call   800c93 <sys_ipc_try_send>
  801238:	89 c3                	mov    %eax,%ebx

        if (r != 0 && r != -E_IPC_NOT_RECV)
  80123a:	8d 40 08             	lea    0x8(%eax),%eax
  80123d:	83 c4 10             	add    $0x10,%esp
  801240:	a9 f7 ff ff ff       	test   $0xfffffff7,%eax
  801245:	74 12                	je     801259 <ipc_send+0x47>
        {
            panic("ipc_send: error %e", r);
  801247:	53                   	push   %ebx
  801248:	68 b6 19 80 00       	push   $0x8019b6
  80124d:	6a 44                	push   $0x44
  80124f:	68 c9 19 80 00       	push   $0x8019c9
  801254:	e8 4a 00 00 00       	call   8012a3 <_panic>
        }
        else
        {
            sys_yield();
  801259:	e8 cb f8 ff ff       	call   800b29 <sys_yield>
        }
    }while(r != 0);
  80125e:	85 db                	test   %ebx,%ebx
  801260:	75 c9                	jne    80122b <ipc_send+0x19>
	//panic("ipc_send not implemented");
}
  801262:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801265:	5b                   	pop    %ebx
  801266:	5e                   	pop    %esi
  801267:	5f                   	pop    %edi
  801268:	5d                   	pop    %ebp
  801269:	c3                   	ret    

0080126a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801270:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801275:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801278:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80127e:	8b 52 50             	mov    0x50(%edx),%edx
  801281:	39 ca                	cmp    %ecx,%edx
  801283:	75 0d                	jne    801292 <ipc_find_env+0x28>
			return envs[i].env_id;
  801285:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801288:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80128d:	8b 40 48             	mov    0x48(%eax),%eax
  801290:	eb 0f                	jmp    8012a1 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801292:	83 c0 01             	add    $0x1,%eax
  801295:	3d 00 04 00 00       	cmp    $0x400,%eax
  80129a:	75 d9                	jne    801275 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80129c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012a1:	5d                   	pop    %ebp
  8012a2:	c3                   	ret    

008012a3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8012a3:	55                   	push   %ebp
  8012a4:	89 e5                	mov    %esp,%ebp
  8012a6:	56                   	push   %esi
  8012a7:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8012a8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8012ab:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8012b1:	e8 54 f8 ff ff       	call   800b0a <sys_getenvid>
  8012b6:	83 ec 0c             	sub    $0xc,%esp
  8012b9:	ff 75 0c             	pushl  0xc(%ebp)
  8012bc:	ff 75 08             	pushl  0x8(%ebp)
  8012bf:	56                   	push   %esi
  8012c0:	50                   	push   %eax
  8012c1:	68 d4 19 80 00       	push   $0x8019d4
  8012c6:	e8 de ee ff ff       	call   8001a9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8012cb:	83 c4 18             	add    $0x18,%esp
  8012ce:	53                   	push   %ebx
  8012cf:	ff 75 10             	pushl  0x10(%ebp)
  8012d2:	e8 81 ee ff ff       	call   800158 <vcprintf>
	cprintf("\n");
  8012d7:	c7 04 24 47 16 80 00 	movl   $0x801647,(%esp)
  8012de:	e8 c6 ee ff ff       	call   8001a9 <cprintf>
  8012e3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8012e6:	cc                   	int3   
  8012e7:	eb fd                	jmp    8012e6 <_panic+0x43>

008012e9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012ef:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8012f6:	75 4c                	jne    801344 <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.

        void *va = (void *)(UXSTACKTOP - PGSIZE);
        if (sys_page_alloc(thisenv->env_id, va, PTE_P | PTE_U | PTE_W))
  8012f8:	a1 04 20 80 00       	mov    0x802004,%eax
  8012fd:	8b 40 48             	mov    0x48(%eax),%eax
  801300:	83 ec 04             	sub    $0x4,%esp
  801303:	6a 07                	push   $0x7
  801305:	68 00 f0 bf ee       	push   $0xeebff000
  80130a:	50                   	push   %eax
  80130b:	e8 38 f8 ff ff       	call   800b48 <sys_page_alloc>
  801310:	83 c4 10             	add    $0x10,%esp
  801313:	85 c0                	test   %eax,%eax
  801315:	74 14                	je     80132b <set_pgfault_handler+0x42>
        {
            panic("Unable to allocate memory for pgfault expected\n");
  801317:	83 ec 04             	sub    $0x4,%esp
  80131a:	68 f8 19 80 00       	push   $0x8019f8
  80131f:	6a 24                	push   $0x24
  801321:	68 28 1a 80 00       	push   $0x801a28
  801326:	e8 78 ff ff ff       	call   8012a3 <_panic>
        }

        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  80132b:	a1 04 20 80 00       	mov    0x802004,%eax
  801330:	8b 40 48             	mov    0x48(%eax),%eax
  801333:	83 ec 08             	sub    $0x8,%esp
  801336:	68 4e 13 80 00       	push   $0x80134e
  80133b:	50                   	push   %eax
  80133c:	e8 10 f9 ff ff       	call   800c51 <sys_env_set_pgfault_upcall>
  801341:	83 c4 10             	add    $0x10,%esp

		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801344:	8b 45 08             	mov    0x8(%ebp),%eax
  801347:	a3 08 20 80 00       	mov    %eax,0x802008
}
  80134c:	c9                   	leave  
  80134d:	c3                   	ret    

0080134e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80134e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80134f:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801354:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801356:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
    movl %esp, %ebx
  801359:	89 e3                	mov    %esp,%ebx
    // 40 is the size between utf_fault_va ~ utf_regs
    movl 40(%esp), %eax
  80135b:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 48(%esp), %esp
  80135f:	8b 64 24 30          	mov    0x30(%esp),%esp
    pushl %eax
  801363:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    movl %ebx, %esp
  801364:	89 dc                	mov    %ebx,%esp
    subl $4, 48(%esp)
  801366:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    popl %eax
  80136b:	58                   	pop    %eax
    popl %eax
  80136c:	58                   	pop    %eax
    popal
  80136d:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  80136e:	83 c4 04             	add    $0x4,%esp
    popfl
  801371:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp
  801372:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  801373:	c3                   	ret    
  801374:	66 90                	xchg   %ax,%ax
  801376:	66 90                	xchg   %ax,%ax
  801378:	66 90                	xchg   %ax,%ax
  80137a:	66 90                	xchg   %ax,%ax
  80137c:	66 90                	xchg   %ax,%ax
  80137e:	66 90                	xchg   %ax,%ax

00801380 <__udivdi3>:
  801380:	55                   	push   %ebp
  801381:	57                   	push   %edi
  801382:	56                   	push   %esi
  801383:	53                   	push   %ebx
  801384:	83 ec 1c             	sub    $0x1c,%esp
  801387:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80138b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80138f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801393:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801397:	85 f6                	test   %esi,%esi
  801399:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80139d:	89 ca                	mov    %ecx,%edx
  80139f:	89 f8                	mov    %edi,%eax
  8013a1:	75 3d                	jne    8013e0 <__udivdi3+0x60>
  8013a3:	39 cf                	cmp    %ecx,%edi
  8013a5:	0f 87 c5 00 00 00    	ja     801470 <__udivdi3+0xf0>
  8013ab:	85 ff                	test   %edi,%edi
  8013ad:	89 fd                	mov    %edi,%ebp
  8013af:	75 0b                	jne    8013bc <__udivdi3+0x3c>
  8013b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8013b6:	31 d2                	xor    %edx,%edx
  8013b8:	f7 f7                	div    %edi
  8013ba:	89 c5                	mov    %eax,%ebp
  8013bc:	89 c8                	mov    %ecx,%eax
  8013be:	31 d2                	xor    %edx,%edx
  8013c0:	f7 f5                	div    %ebp
  8013c2:	89 c1                	mov    %eax,%ecx
  8013c4:	89 d8                	mov    %ebx,%eax
  8013c6:	89 cf                	mov    %ecx,%edi
  8013c8:	f7 f5                	div    %ebp
  8013ca:	89 c3                	mov    %eax,%ebx
  8013cc:	89 d8                	mov    %ebx,%eax
  8013ce:	89 fa                	mov    %edi,%edx
  8013d0:	83 c4 1c             	add    $0x1c,%esp
  8013d3:	5b                   	pop    %ebx
  8013d4:	5e                   	pop    %esi
  8013d5:	5f                   	pop    %edi
  8013d6:	5d                   	pop    %ebp
  8013d7:	c3                   	ret    
  8013d8:	90                   	nop
  8013d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013e0:	39 ce                	cmp    %ecx,%esi
  8013e2:	77 74                	ja     801458 <__udivdi3+0xd8>
  8013e4:	0f bd fe             	bsr    %esi,%edi
  8013e7:	83 f7 1f             	xor    $0x1f,%edi
  8013ea:	0f 84 98 00 00 00    	je     801488 <__udivdi3+0x108>
  8013f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8013f5:	89 f9                	mov    %edi,%ecx
  8013f7:	89 c5                	mov    %eax,%ebp
  8013f9:	29 fb                	sub    %edi,%ebx
  8013fb:	d3 e6                	shl    %cl,%esi
  8013fd:	89 d9                	mov    %ebx,%ecx
  8013ff:	d3 ed                	shr    %cl,%ebp
  801401:	89 f9                	mov    %edi,%ecx
  801403:	d3 e0                	shl    %cl,%eax
  801405:	09 ee                	or     %ebp,%esi
  801407:	89 d9                	mov    %ebx,%ecx
  801409:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80140d:	89 d5                	mov    %edx,%ebp
  80140f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801413:	d3 ed                	shr    %cl,%ebp
  801415:	89 f9                	mov    %edi,%ecx
  801417:	d3 e2                	shl    %cl,%edx
  801419:	89 d9                	mov    %ebx,%ecx
  80141b:	d3 e8                	shr    %cl,%eax
  80141d:	09 c2                	or     %eax,%edx
  80141f:	89 d0                	mov    %edx,%eax
  801421:	89 ea                	mov    %ebp,%edx
  801423:	f7 f6                	div    %esi
  801425:	89 d5                	mov    %edx,%ebp
  801427:	89 c3                	mov    %eax,%ebx
  801429:	f7 64 24 0c          	mull   0xc(%esp)
  80142d:	39 d5                	cmp    %edx,%ebp
  80142f:	72 10                	jb     801441 <__udivdi3+0xc1>
  801431:	8b 74 24 08          	mov    0x8(%esp),%esi
  801435:	89 f9                	mov    %edi,%ecx
  801437:	d3 e6                	shl    %cl,%esi
  801439:	39 c6                	cmp    %eax,%esi
  80143b:	73 07                	jae    801444 <__udivdi3+0xc4>
  80143d:	39 d5                	cmp    %edx,%ebp
  80143f:	75 03                	jne    801444 <__udivdi3+0xc4>
  801441:	83 eb 01             	sub    $0x1,%ebx
  801444:	31 ff                	xor    %edi,%edi
  801446:	89 d8                	mov    %ebx,%eax
  801448:	89 fa                	mov    %edi,%edx
  80144a:	83 c4 1c             	add    $0x1c,%esp
  80144d:	5b                   	pop    %ebx
  80144e:	5e                   	pop    %esi
  80144f:	5f                   	pop    %edi
  801450:	5d                   	pop    %ebp
  801451:	c3                   	ret    
  801452:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801458:	31 ff                	xor    %edi,%edi
  80145a:	31 db                	xor    %ebx,%ebx
  80145c:	89 d8                	mov    %ebx,%eax
  80145e:	89 fa                	mov    %edi,%edx
  801460:	83 c4 1c             	add    $0x1c,%esp
  801463:	5b                   	pop    %ebx
  801464:	5e                   	pop    %esi
  801465:	5f                   	pop    %edi
  801466:	5d                   	pop    %ebp
  801467:	c3                   	ret    
  801468:	90                   	nop
  801469:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801470:	89 d8                	mov    %ebx,%eax
  801472:	f7 f7                	div    %edi
  801474:	31 ff                	xor    %edi,%edi
  801476:	89 c3                	mov    %eax,%ebx
  801478:	89 d8                	mov    %ebx,%eax
  80147a:	89 fa                	mov    %edi,%edx
  80147c:	83 c4 1c             	add    $0x1c,%esp
  80147f:	5b                   	pop    %ebx
  801480:	5e                   	pop    %esi
  801481:	5f                   	pop    %edi
  801482:	5d                   	pop    %ebp
  801483:	c3                   	ret    
  801484:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801488:	39 ce                	cmp    %ecx,%esi
  80148a:	72 0c                	jb     801498 <__udivdi3+0x118>
  80148c:	31 db                	xor    %ebx,%ebx
  80148e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801492:	0f 87 34 ff ff ff    	ja     8013cc <__udivdi3+0x4c>
  801498:	bb 01 00 00 00       	mov    $0x1,%ebx
  80149d:	e9 2a ff ff ff       	jmp    8013cc <__udivdi3+0x4c>
  8014a2:	66 90                	xchg   %ax,%ax
  8014a4:	66 90                	xchg   %ax,%ax
  8014a6:	66 90                	xchg   %ax,%ax
  8014a8:	66 90                	xchg   %ax,%ax
  8014aa:	66 90                	xchg   %ax,%ax
  8014ac:	66 90                	xchg   %ax,%ax
  8014ae:	66 90                	xchg   %ax,%ax

008014b0 <__umoddi3>:
  8014b0:	55                   	push   %ebp
  8014b1:	57                   	push   %edi
  8014b2:	56                   	push   %esi
  8014b3:	53                   	push   %ebx
  8014b4:	83 ec 1c             	sub    $0x1c,%esp
  8014b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8014bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8014bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8014c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8014c7:	85 d2                	test   %edx,%edx
  8014c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8014cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014d1:	89 f3                	mov    %esi,%ebx
  8014d3:	89 3c 24             	mov    %edi,(%esp)
  8014d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014da:	75 1c                	jne    8014f8 <__umoddi3+0x48>
  8014dc:	39 f7                	cmp    %esi,%edi
  8014de:	76 50                	jbe    801530 <__umoddi3+0x80>
  8014e0:	89 c8                	mov    %ecx,%eax
  8014e2:	89 f2                	mov    %esi,%edx
  8014e4:	f7 f7                	div    %edi
  8014e6:	89 d0                	mov    %edx,%eax
  8014e8:	31 d2                	xor    %edx,%edx
  8014ea:	83 c4 1c             	add    $0x1c,%esp
  8014ed:	5b                   	pop    %ebx
  8014ee:	5e                   	pop    %esi
  8014ef:	5f                   	pop    %edi
  8014f0:	5d                   	pop    %ebp
  8014f1:	c3                   	ret    
  8014f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8014f8:	39 f2                	cmp    %esi,%edx
  8014fa:	89 d0                	mov    %edx,%eax
  8014fc:	77 52                	ja     801550 <__umoddi3+0xa0>
  8014fe:	0f bd ea             	bsr    %edx,%ebp
  801501:	83 f5 1f             	xor    $0x1f,%ebp
  801504:	75 5a                	jne    801560 <__umoddi3+0xb0>
  801506:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80150a:	0f 82 e0 00 00 00    	jb     8015f0 <__umoddi3+0x140>
  801510:	39 0c 24             	cmp    %ecx,(%esp)
  801513:	0f 86 d7 00 00 00    	jbe    8015f0 <__umoddi3+0x140>
  801519:	8b 44 24 08          	mov    0x8(%esp),%eax
  80151d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801521:	83 c4 1c             	add    $0x1c,%esp
  801524:	5b                   	pop    %ebx
  801525:	5e                   	pop    %esi
  801526:	5f                   	pop    %edi
  801527:	5d                   	pop    %ebp
  801528:	c3                   	ret    
  801529:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801530:	85 ff                	test   %edi,%edi
  801532:	89 fd                	mov    %edi,%ebp
  801534:	75 0b                	jne    801541 <__umoddi3+0x91>
  801536:	b8 01 00 00 00       	mov    $0x1,%eax
  80153b:	31 d2                	xor    %edx,%edx
  80153d:	f7 f7                	div    %edi
  80153f:	89 c5                	mov    %eax,%ebp
  801541:	89 f0                	mov    %esi,%eax
  801543:	31 d2                	xor    %edx,%edx
  801545:	f7 f5                	div    %ebp
  801547:	89 c8                	mov    %ecx,%eax
  801549:	f7 f5                	div    %ebp
  80154b:	89 d0                	mov    %edx,%eax
  80154d:	eb 99                	jmp    8014e8 <__umoddi3+0x38>
  80154f:	90                   	nop
  801550:	89 c8                	mov    %ecx,%eax
  801552:	89 f2                	mov    %esi,%edx
  801554:	83 c4 1c             	add    $0x1c,%esp
  801557:	5b                   	pop    %ebx
  801558:	5e                   	pop    %esi
  801559:	5f                   	pop    %edi
  80155a:	5d                   	pop    %ebp
  80155b:	c3                   	ret    
  80155c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801560:	8b 34 24             	mov    (%esp),%esi
  801563:	bf 20 00 00 00       	mov    $0x20,%edi
  801568:	89 e9                	mov    %ebp,%ecx
  80156a:	29 ef                	sub    %ebp,%edi
  80156c:	d3 e0                	shl    %cl,%eax
  80156e:	89 f9                	mov    %edi,%ecx
  801570:	89 f2                	mov    %esi,%edx
  801572:	d3 ea                	shr    %cl,%edx
  801574:	89 e9                	mov    %ebp,%ecx
  801576:	09 c2                	or     %eax,%edx
  801578:	89 d8                	mov    %ebx,%eax
  80157a:	89 14 24             	mov    %edx,(%esp)
  80157d:	89 f2                	mov    %esi,%edx
  80157f:	d3 e2                	shl    %cl,%edx
  801581:	89 f9                	mov    %edi,%ecx
  801583:	89 54 24 04          	mov    %edx,0x4(%esp)
  801587:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80158b:	d3 e8                	shr    %cl,%eax
  80158d:	89 e9                	mov    %ebp,%ecx
  80158f:	89 c6                	mov    %eax,%esi
  801591:	d3 e3                	shl    %cl,%ebx
  801593:	89 f9                	mov    %edi,%ecx
  801595:	89 d0                	mov    %edx,%eax
  801597:	d3 e8                	shr    %cl,%eax
  801599:	89 e9                	mov    %ebp,%ecx
  80159b:	09 d8                	or     %ebx,%eax
  80159d:	89 d3                	mov    %edx,%ebx
  80159f:	89 f2                	mov    %esi,%edx
  8015a1:	f7 34 24             	divl   (%esp)
  8015a4:	89 d6                	mov    %edx,%esi
  8015a6:	d3 e3                	shl    %cl,%ebx
  8015a8:	f7 64 24 04          	mull   0x4(%esp)
  8015ac:	39 d6                	cmp    %edx,%esi
  8015ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015b2:	89 d1                	mov    %edx,%ecx
  8015b4:	89 c3                	mov    %eax,%ebx
  8015b6:	72 08                	jb     8015c0 <__umoddi3+0x110>
  8015b8:	75 11                	jne    8015cb <__umoddi3+0x11b>
  8015ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8015be:	73 0b                	jae    8015cb <__umoddi3+0x11b>
  8015c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8015c4:	1b 14 24             	sbb    (%esp),%edx
  8015c7:	89 d1                	mov    %edx,%ecx
  8015c9:	89 c3                	mov    %eax,%ebx
  8015cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8015cf:	29 da                	sub    %ebx,%edx
  8015d1:	19 ce                	sbb    %ecx,%esi
  8015d3:	89 f9                	mov    %edi,%ecx
  8015d5:	89 f0                	mov    %esi,%eax
  8015d7:	d3 e0                	shl    %cl,%eax
  8015d9:	89 e9                	mov    %ebp,%ecx
  8015db:	d3 ea                	shr    %cl,%edx
  8015dd:	89 e9                	mov    %ebp,%ecx
  8015df:	d3 ee                	shr    %cl,%esi
  8015e1:	09 d0                	or     %edx,%eax
  8015e3:	89 f2                	mov    %esi,%edx
  8015e5:	83 c4 1c             	add    $0x1c,%esp
  8015e8:	5b                   	pop    %ebx
  8015e9:	5e                   	pop    %esi
  8015ea:	5f                   	pop    %edi
  8015eb:	5d                   	pop    %ebp
  8015ec:	c3                   	ret    
  8015ed:	8d 76 00             	lea    0x0(%esi),%esi
  8015f0:	29 f9                	sub    %edi,%ecx
  8015f2:	19 d6                	sbb    %edx,%esi
  8015f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015fc:	e9 18 ff ff ff       	jmp    801519 <__umoddi3+0x69>
