
obj/user/fairness：     文件格式 elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 ad 0a 00 00       	call   800aed <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 20 80 00 7c 	cmpl   $0xeec0007c,0x802004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 7c 0c 00 00       	call   800cda <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 c0 10 80 00       	push   $0x8010c0
  80006a:	e8 1d 01 00 00       	call   80018c <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 d1 10 80 00       	push   $0x8010d1
  800083:	e8 04 01 00 00       	call   80018c <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 b3 0c 00 00       	call   800d4f <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000ac:	e8 3c 0a 00 00       	call   800aed <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x2d>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	e8 5b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0a 00 00 00       	call   8000e7 <exit>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ed:	6a 00                	push   $0x0
  8000ef:	e8 b8 09 00 00       	call   800aac <sys_env_destroy>
}
  8000f4:	83 c4 10             	add    $0x10,%esp
  8000f7:	c9                   	leave  
  8000f8:	c3                   	ret    

008000f9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 04             	sub    $0x4,%esp
  800100:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800103:	8b 13                	mov    (%ebx),%edx
  800105:	8d 42 01             	lea    0x1(%edx),%eax
  800108:	89 03                	mov    %eax,(%ebx)
  80010a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800111:	3d ff 00 00 00       	cmp    $0xff,%eax
  800116:	75 1a                	jne    800132 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800118:	83 ec 08             	sub    $0x8,%esp
  80011b:	68 ff 00 00 00       	push   $0xff
  800120:	8d 43 08             	lea    0x8(%ebx),%eax
  800123:	50                   	push   %eax
  800124:	e8 46 09 00 00       	call   800a6f <sys_cputs>
		b->idx = 0;
  800129:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80012f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800132:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800136:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800144:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014b:	00 00 00 
	b.cnt = 0;
  80014e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800155:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800158:	ff 75 0c             	pushl  0xc(%ebp)
  80015b:	ff 75 08             	pushl  0x8(%ebp)
  80015e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800164:	50                   	push   %eax
  800165:	68 f9 00 80 00       	push   $0x8000f9
  80016a:	e8 54 01 00 00       	call   8002c3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80016f:	83 c4 08             	add    $0x8,%esp
  800172:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800178:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017e:	50                   	push   %eax
  80017f:	e8 eb 08 00 00       	call   800a6f <sys_cputs>

	return b.cnt;
}
  800184:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018a:	c9                   	leave  
  80018b:	c3                   	ret    

0080018c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800192:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800195:	50                   	push   %eax
  800196:	ff 75 08             	pushl  0x8(%ebp)
  800199:	e8 9d ff ff ff       	call   80013b <vcprintf>
	va_end(ap);

	return cnt;
}
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	57                   	push   %edi
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
  8001a6:	83 ec 1c             	sub    $0x1c,%esp
  8001a9:	89 c7                	mov    %eax,%edi
  8001ab:	89 d6                	mov    %edx,%esi
  8001ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001c4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001c7:	39 d3                	cmp    %edx,%ebx
  8001c9:	72 05                	jb     8001d0 <printnum+0x30>
  8001cb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ce:	77 45                	ja     800215 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d0:	83 ec 0c             	sub    $0xc,%esp
  8001d3:	ff 75 18             	pushl  0x18(%ebp)
  8001d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8001d9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001dc:	53                   	push   %ebx
  8001dd:	ff 75 10             	pushl  0x10(%ebp)
  8001e0:	83 ec 08             	sub    $0x8,%esp
  8001e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ef:	e8 3c 0c 00 00       	call   800e30 <__udivdi3>
  8001f4:	83 c4 18             	add    $0x18,%esp
  8001f7:	52                   	push   %edx
  8001f8:	50                   	push   %eax
  8001f9:	89 f2                	mov    %esi,%edx
  8001fb:	89 f8                	mov    %edi,%eax
  8001fd:	e8 9e ff ff ff       	call   8001a0 <printnum>
  800202:	83 c4 20             	add    $0x20,%esp
  800205:	eb 18                	jmp    80021f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800207:	83 ec 08             	sub    $0x8,%esp
  80020a:	56                   	push   %esi
  80020b:	ff 75 18             	pushl  0x18(%ebp)
  80020e:	ff d7                	call   *%edi
  800210:	83 c4 10             	add    $0x10,%esp
  800213:	eb 03                	jmp    800218 <printnum+0x78>
  800215:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800218:	83 eb 01             	sub    $0x1,%ebx
  80021b:	85 db                	test   %ebx,%ebx
  80021d:	7f e8                	jg     800207 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021f:	83 ec 08             	sub    $0x8,%esp
  800222:	56                   	push   %esi
  800223:	83 ec 04             	sub    $0x4,%esp
  800226:	ff 75 e4             	pushl  -0x1c(%ebp)
  800229:	ff 75 e0             	pushl  -0x20(%ebp)
  80022c:	ff 75 dc             	pushl  -0x24(%ebp)
  80022f:	ff 75 d8             	pushl  -0x28(%ebp)
  800232:	e8 29 0d 00 00       	call   800f60 <__umoddi3>
  800237:	83 c4 14             	add    $0x14,%esp
  80023a:	0f be 80 f2 10 80 00 	movsbl 0x8010f2(%eax),%eax
  800241:	50                   	push   %eax
  800242:	ff d7                	call   *%edi
}
  800244:	83 c4 10             	add    $0x10,%esp
  800247:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024a:	5b                   	pop    %ebx
  80024b:	5e                   	pop    %esi
  80024c:	5f                   	pop    %edi
  80024d:	5d                   	pop    %ebp
  80024e:	c3                   	ret    

0080024f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800252:	83 fa 01             	cmp    $0x1,%edx
  800255:	7e 0e                	jle    800265 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800257:	8b 10                	mov    (%eax),%edx
  800259:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025c:	89 08                	mov    %ecx,(%eax)
  80025e:	8b 02                	mov    (%edx),%eax
  800260:	8b 52 04             	mov    0x4(%edx),%edx
  800263:	eb 22                	jmp    800287 <getuint+0x38>
	else if (lflag)
  800265:	85 d2                	test   %edx,%edx
  800267:	74 10                	je     800279 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800269:	8b 10                	mov    (%eax),%edx
  80026b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026e:	89 08                	mov    %ecx,(%eax)
  800270:	8b 02                	mov    (%edx),%eax
  800272:	ba 00 00 00 00       	mov    $0x0,%edx
  800277:	eb 0e                	jmp    800287 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800279:	8b 10                	mov    (%eax),%edx
  80027b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027e:	89 08                	mov    %ecx,(%eax)
  800280:	8b 02                	mov    (%edx),%eax
  800282:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800287:	5d                   	pop    %ebp
  800288:	c3                   	ret    

00800289 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800293:	8b 10                	mov    (%eax),%edx
  800295:	3b 50 04             	cmp    0x4(%eax),%edx
  800298:	73 0a                	jae    8002a4 <sprintputch+0x1b>
		*b->buf++ = ch;
  80029a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80029d:	89 08                	mov    %ecx,(%eax)
  80029f:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a2:	88 02                	mov    %al,(%edx)
}
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002af:	50                   	push   %eax
  8002b0:	ff 75 10             	pushl  0x10(%ebp)
  8002b3:	ff 75 0c             	pushl  0xc(%ebp)
  8002b6:	ff 75 08             	pushl  0x8(%ebp)
  8002b9:	e8 05 00 00 00       	call   8002c3 <vprintfmt>
	va_end(ap);
}
  8002be:	83 c4 10             	add    $0x10,%esp
  8002c1:	c9                   	leave  
  8002c2:	c3                   	ret    

008002c3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	57                   	push   %edi
  8002c7:	56                   	push   %esi
  8002c8:	53                   	push   %ebx
  8002c9:	83 ec 2c             	sub    $0x2c,%esp
  8002cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
  8002cf:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002d6:	eb 17                	jmp    8002ef <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d8:	85 c0                	test   %eax,%eax
  8002da:	0f 84 9f 03 00 00    	je     80067f <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	ff 75 0c             	pushl  0xc(%ebp)
  8002e6:	50                   	push   %eax
  8002e7:	ff 55 08             	call   *0x8(%ebp)
  8002ea:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ed:	89 f3                	mov    %esi,%ebx
  8002ef:	8d 73 01             	lea    0x1(%ebx),%esi
  8002f2:	0f b6 03             	movzbl (%ebx),%eax
  8002f5:	83 f8 25             	cmp    $0x25,%eax
  8002f8:	75 de                	jne    8002d8 <vprintfmt+0x15>
  8002fa:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8002fe:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800305:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80030a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800311:	ba 00 00 00 00       	mov    $0x0,%edx
  800316:	eb 06                	jmp    80031e <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800318:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80031a:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031e:	8d 5e 01             	lea    0x1(%esi),%ebx
  800321:	0f b6 06             	movzbl (%esi),%eax
  800324:	0f b6 c8             	movzbl %al,%ecx
  800327:	83 e8 23             	sub    $0x23,%eax
  80032a:	3c 55                	cmp    $0x55,%al
  80032c:	0f 87 2d 03 00 00    	ja     80065f <vprintfmt+0x39c>
  800332:	0f b6 c0             	movzbl %al,%eax
  800335:	ff 24 85 c0 11 80 00 	jmp    *0x8011c0(,%eax,4)
  80033c:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80033e:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800342:	eb da                	jmp    80031e <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800344:	89 de                	mov    %ebx,%esi
  800346:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80034b:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  80034e:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  800352:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  800355:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800358:	83 f8 09             	cmp    $0x9,%eax
  80035b:	77 33                	ja     800390 <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80035d:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800360:	eb e9                	jmp    80034b <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800362:	8b 45 14             	mov    0x14(%ebp),%eax
  800365:	8d 48 04             	lea    0x4(%eax),%ecx
  800368:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80036b:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036d:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80036f:	eb 1f                	jmp    800390 <vprintfmt+0xcd>
  800371:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800374:	85 c0                	test   %eax,%eax
  800376:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037b:	0f 49 c8             	cmovns %eax,%ecx
  80037e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800381:	89 de                	mov    %ebx,%esi
  800383:	eb 99                	jmp    80031e <vprintfmt+0x5b>
  800385:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800387:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  80038e:	eb 8e                	jmp    80031e <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  800390:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800394:	79 88                	jns    80031e <vprintfmt+0x5b>
				width = precision, precision = -1;
  800396:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800399:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80039e:	e9 7b ff ff ff       	jmp    80031e <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003a8:	e9 71 ff ff ff       	jmp    80031e <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
  8003ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b0:	8d 50 04             	lea    0x4(%eax),%edx
  8003b3:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  8003b6:	83 ec 08             	sub    $0x8,%esp
  8003b9:	ff 75 0c             	pushl  0xc(%ebp)
  8003bc:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8003bf:	03 08                	add    (%eax),%ecx
  8003c1:	51                   	push   %ecx
  8003c2:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
  8003c5:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
  8003c8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
  8003cf:	e9 1b ff ff ff       	jmp    8002ef <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
  8003d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d7:	8d 48 04             	lea    0x4(%eax),%ecx
  8003da:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003dd:	8b 00                	mov    (%eax),%eax
  8003df:	83 f8 02             	cmp    $0x2,%eax
  8003e2:	74 1a                	je     8003fe <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	89 de                	mov    %ebx,%esi
  8003e6:	83 f8 04             	cmp    $0x4,%eax
  8003e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ee:	b9 00 04 00 00       	mov    $0x400,%ecx
  8003f3:	0f 44 c1             	cmove  %ecx,%eax
  8003f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003f9:	e9 20 ff ff ff       	jmp    80031e <vprintfmt+0x5b>
  8003fe:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
  800400:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
  800407:	e9 12 ff ff ff       	jmp    80031e <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	8d 50 04             	lea    0x4(%eax),%edx
  800412:	89 55 14             	mov    %edx,0x14(%ebp)
  800415:	8b 00                	mov    (%eax),%eax
  800417:	99                   	cltd   
  800418:	31 d0                	xor    %edx,%eax
  80041a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041c:	83 f8 09             	cmp    $0x9,%eax
  80041f:	7f 0b                	jg     80042c <vprintfmt+0x169>
  800421:	8b 14 85 20 13 80 00 	mov    0x801320(,%eax,4),%edx
  800428:	85 d2                	test   %edx,%edx
  80042a:	75 19                	jne    800445 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  80042c:	50                   	push   %eax
  80042d:	68 0a 11 80 00       	push   $0x80110a
  800432:	ff 75 0c             	pushl  0xc(%ebp)
  800435:	ff 75 08             	pushl  0x8(%ebp)
  800438:	e8 69 fe ff ff       	call   8002a6 <printfmt>
  80043d:	83 c4 10             	add    $0x10,%esp
  800440:	e9 aa fe ff ff       	jmp    8002ef <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  800445:	52                   	push   %edx
  800446:	68 13 11 80 00       	push   $0x801113
  80044b:	ff 75 0c             	pushl  0xc(%ebp)
  80044e:	ff 75 08             	pushl  0x8(%ebp)
  800451:	e8 50 fe ff ff       	call   8002a6 <printfmt>
  800456:	83 c4 10             	add    $0x10,%esp
  800459:	e9 91 fe ff ff       	jmp    8002ef <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80045e:	8b 45 14             	mov    0x14(%ebp),%eax
  800461:	8d 50 04             	lea    0x4(%eax),%edx
  800464:	89 55 14             	mov    %edx,0x14(%ebp)
  800467:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800469:	85 f6                	test   %esi,%esi
  80046b:	b8 03 11 80 00       	mov    $0x801103,%eax
  800470:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800473:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800477:	0f 8e 93 00 00 00    	jle    800510 <vprintfmt+0x24d>
  80047d:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800481:	0f 84 91 00 00 00    	je     800518 <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	57                   	push   %edi
  80048b:	56                   	push   %esi
  80048c:	e8 76 02 00 00       	call   800707 <strnlen>
  800491:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800494:	29 c1                	sub    %eax,%ecx
  800496:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800499:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049c:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8004a0:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004a3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004a9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004ac:	89 cb                	mov    %ecx,%ebx
  8004ae:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b0:	eb 0e                	jmp    8004c0 <vprintfmt+0x1fd>
					putch(padc, putdat);
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	56                   	push   %esi
  8004b6:	57                   	push   %edi
  8004b7:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ba:	83 eb 01             	sub    $0x1,%ebx
  8004bd:	83 c4 10             	add    $0x10,%esp
  8004c0:	85 db                	test   %ebx,%ebx
  8004c2:	7f ee                	jg     8004b2 <vprintfmt+0x1ef>
  8004c4:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004c7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004ca:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004cd:	85 c9                	test   %ecx,%ecx
  8004cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d4:	0f 49 c1             	cmovns %ecx,%eax
  8004d7:	29 c1                	sub    %eax,%ecx
  8004d9:	89 cb                	mov    %ecx,%ebx
  8004db:	eb 41                	jmp    80051e <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004dd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e1:	74 1b                	je     8004fe <vprintfmt+0x23b>
  8004e3:	0f be c0             	movsbl %al,%eax
  8004e6:	83 e8 20             	sub    $0x20,%eax
  8004e9:	83 f8 5e             	cmp    $0x5e,%eax
  8004ec:	76 10                	jbe    8004fe <vprintfmt+0x23b>
					putch('?', putdat);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	ff 75 0c             	pushl  0xc(%ebp)
  8004f4:	6a 3f                	push   $0x3f
  8004f6:	ff 55 08             	call   *0x8(%ebp)
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	eb 0d                	jmp    80050b <vprintfmt+0x248>
				else
					putch(ch, putdat);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	ff 75 0c             	pushl  0xc(%ebp)
  800504:	52                   	push   %edx
  800505:	ff 55 08             	call   *0x8(%ebp)
  800508:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050b:	83 eb 01             	sub    $0x1,%ebx
  80050e:	eb 0e                	jmp    80051e <vprintfmt+0x25b>
  800510:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800513:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800516:	eb 06                	jmp    80051e <vprintfmt+0x25b>
  800518:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80051b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051e:	83 c6 01             	add    $0x1,%esi
  800521:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800525:	0f be d0             	movsbl %al,%edx
  800528:	85 d2                	test   %edx,%edx
  80052a:	74 25                	je     800551 <vprintfmt+0x28e>
  80052c:	85 ff                	test   %edi,%edi
  80052e:	78 ad                	js     8004dd <vprintfmt+0x21a>
  800530:	83 ef 01             	sub    $0x1,%edi
  800533:	79 a8                	jns    8004dd <vprintfmt+0x21a>
  800535:	89 d8                	mov    %ebx,%eax
  800537:	8b 75 08             	mov    0x8(%ebp),%esi
  80053a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80053d:	89 c3                	mov    %eax,%ebx
  80053f:	eb 16                	jmp    800557 <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	57                   	push   %edi
  800545:	6a 20                	push   $0x20
  800547:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800549:	83 eb 01             	sub    $0x1,%ebx
  80054c:	83 c4 10             	add    $0x10,%esp
  80054f:	eb 06                	jmp    800557 <vprintfmt+0x294>
  800551:	8b 75 08             	mov    0x8(%ebp),%esi
  800554:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800557:	85 db                	test   %ebx,%ebx
  800559:	7f e6                	jg     800541 <vprintfmt+0x27e>
  80055b:	89 75 08             	mov    %esi,0x8(%ebp)
  80055e:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800561:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800564:	e9 86 fd ff ff       	jmp    8002ef <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800569:	83 fa 01             	cmp    $0x1,%edx
  80056c:	7e 10                	jle    80057e <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
  80056e:	8b 45 14             	mov    0x14(%ebp),%eax
  800571:	8d 50 08             	lea    0x8(%eax),%edx
  800574:	89 55 14             	mov    %edx,0x14(%ebp)
  800577:	8b 30                	mov    (%eax),%esi
  800579:	8b 78 04             	mov    0x4(%eax),%edi
  80057c:	eb 26                	jmp    8005a4 <vprintfmt+0x2e1>
	else if (lflag)
  80057e:	85 d2                	test   %edx,%edx
  800580:	74 12                	je     800594 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8d 50 04             	lea    0x4(%eax),%edx
  800588:	89 55 14             	mov    %edx,0x14(%ebp)
  80058b:	8b 30                	mov    (%eax),%esi
  80058d:	89 f7                	mov    %esi,%edi
  80058f:	c1 ff 1f             	sar    $0x1f,%edi
  800592:	eb 10                	jmp    8005a4 <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 50 04             	lea    0x4(%eax),%edx
  80059a:	89 55 14             	mov    %edx,0x14(%ebp)
  80059d:	8b 30                	mov    (%eax),%esi
  80059f:	89 f7                	mov    %esi,%edi
  8005a1:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005a4:	89 f0                	mov    %esi,%eax
  8005a6:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ad:	85 ff                	test   %edi,%edi
  8005af:	79 7b                	jns    80062c <vprintfmt+0x369>
				putch('-', putdat);
  8005b1:	83 ec 08             	sub    $0x8,%esp
  8005b4:	ff 75 0c             	pushl  0xc(%ebp)
  8005b7:	6a 2d                	push   $0x2d
  8005b9:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005bc:	89 f0                	mov    %esi,%eax
  8005be:	89 fa                	mov    %edi,%edx
  8005c0:	f7 d8                	neg    %eax
  8005c2:	83 d2 00             	adc    $0x0,%edx
  8005c5:	f7 da                	neg    %edx
  8005c7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ca:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005cf:	eb 5b                	jmp    80062c <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005d1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d4:	e8 76 fc ff ff       	call   80024f <getuint>
			base = 10;
  8005d9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005de:	eb 4c                	jmp    80062c <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
  8005e0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e3:	e8 67 fc ff ff       	call   80024f <getuint>
            base = 8;
  8005e8:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005ed:	eb 3d                	jmp    80062c <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	ff 75 0c             	pushl  0xc(%ebp)
  8005f5:	6a 30                	push   $0x30
  8005f7:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005fa:	83 c4 08             	add    $0x8,%esp
  8005fd:	ff 75 0c             	pushl  0xc(%ebp)
  800600:	6a 78                	push   $0x78
  800602:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8d 50 04             	lea    0x4(%eax),%edx
  80060b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80060e:	8b 00                	mov    (%eax),%eax
  800610:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800615:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800618:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80061d:	eb 0d                	jmp    80062c <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80061f:	8d 45 14             	lea    0x14(%ebp),%eax
  800622:	e8 28 fc ff ff       	call   80024f <getuint>
			base = 16;
  800627:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80062c:	83 ec 0c             	sub    $0xc,%esp
  80062f:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  800633:	56                   	push   %esi
  800634:	ff 75 e0             	pushl  -0x20(%ebp)
  800637:	51                   	push   %ecx
  800638:	52                   	push   %edx
  800639:	50                   	push   %eax
  80063a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80063d:	8b 45 08             	mov    0x8(%ebp),%eax
  800640:	e8 5b fb ff ff       	call   8001a0 <printnum>
			break;
  800645:	83 c4 20             	add    $0x20,%esp
  800648:	e9 a2 fc ff ff       	jmp    8002ef <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	ff 75 0c             	pushl  0xc(%ebp)
  800653:	51                   	push   %ecx
  800654:	ff 55 08             	call   *0x8(%ebp)
			break;
  800657:	83 c4 10             	add    $0x10,%esp
  80065a:	e9 90 fc ff ff       	jmp    8002ef <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80065f:	83 ec 08             	sub    $0x8,%esp
  800662:	ff 75 0c             	pushl  0xc(%ebp)
  800665:	6a 25                	push   $0x25
  800667:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80066a:	83 c4 10             	add    $0x10,%esp
  80066d:	89 f3                	mov    %esi,%ebx
  80066f:	eb 03                	jmp    800674 <vprintfmt+0x3b1>
  800671:	83 eb 01             	sub    $0x1,%ebx
  800674:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800678:	75 f7                	jne    800671 <vprintfmt+0x3ae>
  80067a:	e9 70 fc ff ff       	jmp    8002ef <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  80067f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800682:	5b                   	pop    %ebx
  800683:	5e                   	pop    %esi
  800684:	5f                   	pop    %edi
  800685:	5d                   	pop    %ebp
  800686:	c3                   	ret    

00800687 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800687:	55                   	push   %ebp
  800688:	89 e5                	mov    %esp,%ebp
  80068a:	83 ec 18             	sub    $0x18,%esp
  80068d:	8b 45 08             	mov    0x8(%ebp),%eax
  800690:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800693:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800696:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80069a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80069d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a4:	85 c0                	test   %eax,%eax
  8006a6:	74 26                	je     8006ce <vsnprintf+0x47>
  8006a8:	85 d2                	test   %edx,%edx
  8006aa:	7e 22                	jle    8006ce <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ac:	ff 75 14             	pushl  0x14(%ebp)
  8006af:	ff 75 10             	pushl  0x10(%ebp)
  8006b2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006b5:	50                   	push   %eax
  8006b6:	68 89 02 80 00       	push   $0x800289
  8006bb:	e8 03 fc ff ff       	call   8002c3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c9:	83 c4 10             	add    $0x10,%esp
  8006cc:	eb 05                	jmp    8006d3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006d3:	c9                   	leave  
  8006d4:	c3                   	ret    

008006d5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006d5:	55                   	push   %ebp
  8006d6:	89 e5                	mov    %esp,%ebp
  8006d8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006db:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006de:	50                   	push   %eax
  8006df:	ff 75 10             	pushl  0x10(%ebp)
  8006e2:	ff 75 0c             	pushl  0xc(%ebp)
  8006e5:	ff 75 08             	pushl  0x8(%ebp)
  8006e8:	e8 9a ff ff ff       	call   800687 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006ed:	c9                   	leave  
  8006ee:	c3                   	ret    

008006ef <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006ef:	55                   	push   %ebp
  8006f0:	89 e5                	mov    %esp,%ebp
  8006f2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fa:	eb 03                	jmp    8006ff <strlen+0x10>
		n++;
  8006fc:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ff:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800703:	75 f7                	jne    8006fc <strlen+0xd>
		n++;
	return n;
}
  800705:	5d                   	pop    %ebp
  800706:	c3                   	ret    

00800707 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80070d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800710:	ba 00 00 00 00       	mov    $0x0,%edx
  800715:	eb 03                	jmp    80071a <strnlen+0x13>
		n++;
  800717:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071a:	39 c2                	cmp    %eax,%edx
  80071c:	74 08                	je     800726 <strnlen+0x1f>
  80071e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800722:	75 f3                	jne    800717 <strnlen+0x10>
  800724:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800726:	5d                   	pop    %ebp
  800727:	c3                   	ret    

00800728 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	53                   	push   %ebx
  80072c:	8b 45 08             	mov    0x8(%ebp),%eax
  80072f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800732:	89 c2                	mov    %eax,%edx
  800734:	83 c2 01             	add    $0x1,%edx
  800737:	83 c1 01             	add    $0x1,%ecx
  80073a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80073e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800741:	84 db                	test   %bl,%bl
  800743:	75 ef                	jne    800734 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800745:	5b                   	pop    %ebx
  800746:	5d                   	pop    %ebp
  800747:	c3                   	ret    

00800748 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800748:	55                   	push   %ebp
  800749:	89 e5                	mov    %esp,%ebp
  80074b:	53                   	push   %ebx
  80074c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80074f:	53                   	push   %ebx
  800750:	e8 9a ff ff ff       	call   8006ef <strlen>
  800755:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800758:	ff 75 0c             	pushl  0xc(%ebp)
  80075b:	01 d8                	add    %ebx,%eax
  80075d:	50                   	push   %eax
  80075e:	e8 c5 ff ff ff       	call   800728 <strcpy>
	return dst;
}
  800763:	89 d8                	mov    %ebx,%eax
  800765:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800768:	c9                   	leave  
  800769:	c3                   	ret    

0080076a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80076a:	55                   	push   %ebp
  80076b:	89 e5                	mov    %esp,%ebp
  80076d:	56                   	push   %esi
  80076e:	53                   	push   %ebx
  80076f:	8b 75 08             	mov    0x8(%ebp),%esi
  800772:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800775:	89 f3                	mov    %esi,%ebx
  800777:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077a:	89 f2                	mov    %esi,%edx
  80077c:	eb 0f                	jmp    80078d <strncpy+0x23>
		*dst++ = *src;
  80077e:	83 c2 01             	add    $0x1,%edx
  800781:	0f b6 01             	movzbl (%ecx),%eax
  800784:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800787:	80 39 01             	cmpb   $0x1,(%ecx)
  80078a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078d:	39 da                	cmp    %ebx,%edx
  80078f:	75 ed                	jne    80077e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800791:	89 f0                	mov    %esi,%eax
  800793:	5b                   	pop    %ebx
  800794:	5e                   	pop    %esi
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	56                   	push   %esi
  80079b:	53                   	push   %ebx
  80079c:	8b 75 08             	mov    0x8(%ebp),%esi
  80079f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a2:	8b 55 10             	mov    0x10(%ebp),%edx
  8007a5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a7:	85 d2                	test   %edx,%edx
  8007a9:	74 21                	je     8007cc <strlcpy+0x35>
  8007ab:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007af:	89 f2                	mov    %esi,%edx
  8007b1:	eb 09                	jmp    8007bc <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007b3:	83 c2 01             	add    $0x1,%edx
  8007b6:	83 c1 01             	add    $0x1,%ecx
  8007b9:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007bc:	39 c2                	cmp    %eax,%edx
  8007be:	74 09                	je     8007c9 <strlcpy+0x32>
  8007c0:	0f b6 19             	movzbl (%ecx),%ebx
  8007c3:	84 db                	test   %bl,%bl
  8007c5:	75 ec                	jne    8007b3 <strlcpy+0x1c>
  8007c7:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007c9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007cc:	29 f0                	sub    %esi,%eax
}
  8007ce:	5b                   	pop    %ebx
  8007cf:	5e                   	pop    %esi
  8007d0:	5d                   	pop    %ebp
  8007d1:	c3                   	ret    

008007d2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007db:	eb 06                	jmp    8007e3 <strcmp+0x11>
		p++, q++;
  8007dd:	83 c1 01             	add    $0x1,%ecx
  8007e0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007e3:	0f b6 01             	movzbl (%ecx),%eax
  8007e6:	84 c0                	test   %al,%al
  8007e8:	74 04                	je     8007ee <strcmp+0x1c>
  8007ea:	3a 02                	cmp    (%edx),%al
  8007ec:	74 ef                	je     8007dd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ee:	0f b6 c0             	movzbl %al,%eax
  8007f1:	0f b6 12             	movzbl (%edx),%edx
  8007f4:	29 d0                	sub    %edx,%eax
}
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	53                   	push   %ebx
  8007fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800802:	89 c3                	mov    %eax,%ebx
  800804:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800807:	eb 06                	jmp    80080f <strncmp+0x17>
		n--, p++, q++;
  800809:	83 c0 01             	add    $0x1,%eax
  80080c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80080f:	39 d8                	cmp    %ebx,%eax
  800811:	74 15                	je     800828 <strncmp+0x30>
  800813:	0f b6 08             	movzbl (%eax),%ecx
  800816:	84 c9                	test   %cl,%cl
  800818:	74 04                	je     80081e <strncmp+0x26>
  80081a:	3a 0a                	cmp    (%edx),%cl
  80081c:	74 eb                	je     800809 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80081e:	0f b6 00             	movzbl (%eax),%eax
  800821:	0f b6 12             	movzbl (%edx),%edx
  800824:	29 d0                	sub    %edx,%eax
  800826:	eb 05                	jmp    80082d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800828:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80082d:	5b                   	pop    %ebx
  80082e:	5d                   	pop    %ebp
  80082f:	c3                   	ret    

00800830 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	8b 45 08             	mov    0x8(%ebp),%eax
  800836:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80083a:	eb 07                	jmp    800843 <strchr+0x13>
		if (*s == c)
  80083c:	38 ca                	cmp    %cl,%dl
  80083e:	74 0f                	je     80084f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800840:	83 c0 01             	add    $0x1,%eax
  800843:	0f b6 10             	movzbl (%eax),%edx
  800846:	84 d2                	test   %dl,%dl
  800848:	75 f2                	jne    80083c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80084a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	8b 45 08             	mov    0x8(%ebp),%eax
  800857:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80085b:	eb 03                	jmp    800860 <strfind+0xf>
  80085d:	83 c0 01             	add    $0x1,%eax
  800860:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800863:	38 ca                	cmp    %cl,%dl
  800865:	74 04                	je     80086b <strfind+0x1a>
  800867:	84 d2                	test   %dl,%dl
  800869:	75 f2                	jne    80085d <strfind+0xc>
			break;
	return (char *) s;
}
  80086b:	5d                   	pop    %ebp
  80086c:	c3                   	ret    

0080086d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	57                   	push   %edi
  800871:	56                   	push   %esi
  800872:	53                   	push   %ebx
  800873:	8b 7d 08             	mov    0x8(%ebp),%edi
  800876:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800879:	85 c9                	test   %ecx,%ecx
  80087b:	74 36                	je     8008b3 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80087d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800883:	75 28                	jne    8008ad <memset+0x40>
  800885:	f6 c1 03             	test   $0x3,%cl
  800888:	75 23                	jne    8008ad <memset+0x40>
		c &= 0xFF;
  80088a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80088e:	89 d3                	mov    %edx,%ebx
  800890:	c1 e3 08             	shl    $0x8,%ebx
  800893:	89 d6                	mov    %edx,%esi
  800895:	c1 e6 18             	shl    $0x18,%esi
  800898:	89 d0                	mov    %edx,%eax
  80089a:	c1 e0 10             	shl    $0x10,%eax
  80089d:	09 f0                	or     %esi,%eax
  80089f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008a1:	89 d8                	mov    %ebx,%eax
  8008a3:	09 d0                	or     %edx,%eax
  8008a5:	c1 e9 02             	shr    $0x2,%ecx
  8008a8:	fc                   	cld    
  8008a9:	f3 ab                	rep stos %eax,%es:(%edi)
  8008ab:	eb 06                	jmp    8008b3 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b0:	fc                   	cld    
  8008b1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008b3:	89 f8                	mov    %edi,%eax
  8008b5:	5b                   	pop    %ebx
  8008b6:	5e                   	pop    %esi
  8008b7:	5f                   	pop    %edi
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	57                   	push   %edi
  8008be:	56                   	push   %esi
  8008bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008c8:	39 c6                	cmp    %eax,%esi
  8008ca:	73 35                	jae    800901 <memmove+0x47>
  8008cc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008cf:	39 d0                	cmp    %edx,%eax
  8008d1:	73 2e                	jae    800901 <memmove+0x47>
		s += n;
		d += n;
  8008d3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d6:	89 d6                	mov    %edx,%esi
  8008d8:	09 fe                	or     %edi,%esi
  8008da:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008e0:	75 13                	jne    8008f5 <memmove+0x3b>
  8008e2:	f6 c1 03             	test   $0x3,%cl
  8008e5:	75 0e                	jne    8008f5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008e7:	83 ef 04             	sub    $0x4,%edi
  8008ea:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008ed:	c1 e9 02             	shr    $0x2,%ecx
  8008f0:	fd                   	std    
  8008f1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f3:	eb 09                	jmp    8008fe <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008f5:	83 ef 01             	sub    $0x1,%edi
  8008f8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008fb:	fd                   	std    
  8008fc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008fe:	fc                   	cld    
  8008ff:	eb 1d                	jmp    80091e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800901:	89 f2                	mov    %esi,%edx
  800903:	09 c2                	or     %eax,%edx
  800905:	f6 c2 03             	test   $0x3,%dl
  800908:	75 0f                	jne    800919 <memmove+0x5f>
  80090a:	f6 c1 03             	test   $0x3,%cl
  80090d:	75 0a                	jne    800919 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80090f:	c1 e9 02             	shr    $0x2,%ecx
  800912:	89 c7                	mov    %eax,%edi
  800914:	fc                   	cld    
  800915:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800917:	eb 05                	jmp    80091e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800919:	89 c7                	mov    %eax,%edi
  80091b:	fc                   	cld    
  80091c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80091e:	5e                   	pop    %esi
  80091f:	5f                   	pop    %edi
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800925:	ff 75 10             	pushl  0x10(%ebp)
  800928:	ff 75 0c             	pushl  0xc(%ebp)
  80092b:	ff 75 08             	pushl  0x8(%ebp)
  80092e:	e8 87 ff ff ff       	call   8008ba <memmove>
}
  800933:	c9                   	leave  
  800934:	c3                   	ret    

00800935 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	56                   	push   %esi
  800939:	53                   	push   %ebx
  80093a:	8b 45 08             	mov    0x8(%ebp),%eax
  80093d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800940:	89 c6                	mov    %eax,%esi
  800942:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800945:	eb 1a                	jmp    800961 <memcmp+0x2c>
		if (*s1 != *s2)
  800947:	0f b6 08             	movzbl (%eax),%ecx
  80094a:	0f b6 1a             	movzbl (%edx),%ebx
  80094d:	38 d9                	cmp    %bl,%cl
  80094f:	74 0a                	je     80095b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800951:	0f b6 c1             	movzbl %cl,%eax
  800954:	0f b6 db             	movzbl %bl,%ebx
  800957:	29 d8                	sub    %ebx,%eax
  800959:	eb 0f                	jmp    80096a <memcmp+0x35>
		s1++, s2++;
  80095b:	83 c0 01             	add    $0x1,%eax
  80095e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800961:	39 f0                	cmp    %esi,%eax
  800963:	75 e2                	jne    800947 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800965:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80096a:	5b                   	pop    %ebx
  80096b:	5e                   	pop    %esi
  80096c:	5d                   	pop    %ebp
  80096d:	c3                   	ret    

0080096e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	53                   	push   %ebx
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800975:	89 c1                	mov    %eax,%ecx
  800977:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80097a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80097e:	eb 0a                	jmp    80098a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800980:	0f b6 10             	movzbl (%eax),%edx
  800983:	39 da                	cmp    %ebx,%edx
  800985:	74 07                	je     80098e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800987:	83 c0 01             	add    $0x1,%eax
  80098a:	39 c8                	cmp    %ecx,%eax
  80098c:	72 f2                	jb     800980 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80098e:	5b                   	pop    %ebx
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	57                   	push   %edi
  800995:	56                   	push   %esi
  800996:	53                   	push   %ebx
  800997:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80099d:	eb 03                	jmp    8009a2 <strtol+0x11>
		s++;
  80099f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a2:	0f b6 01             	movzbl (%ecx),%eax
  8009a5:	3c 20                	cmp    $0x20,%al
  8009a7:	74 f6                	je     80099f <strtol+0xe>
  8009a9:	3c 09                	cmp    $0x9,%al
  8009ab:	74 f2                	je     80099f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ad:	3c 2b                	cmp    $0x2b,%al
  8009af:	75 0a                	jne    8009bb <strtol+0x2a>
		s++;
  8009b1:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009b4:	bf 00 00 00 00       	mov    $0x0,%edi
  8009b9:	eb 11                	jmp    8009cc <strtol+0x3b>
  8009bb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009c0:	3c 2d                	cmp    $0x2d,%al
  8009c2:	75 08                	jne    8009cc <strtol+0x3b>
		s++, neg = 1;
  8009c4:	83 c1 01             	add    $0x1,%ecx
  8009c7:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009cc:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009d2:	75 15                	jne    8009e9 <strtol+0x58>
  8009d4:	80 39 30             	cmpb   $0x30,(%ecx)
  8009d7:	75 10                	jne    8009e9 <strtol+0x58>
  8009d9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009dd:	75 7c                	jne    800a5b <strtol+0xca>
		s += 2, base = 16;
  8009df:	83 c1 02             	add    $0x2,%ecx
  8009e2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009e7:	eb 16                	jmp    8009ff <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009e9:	85 db                	test   %ebx,%ebx
  8009eb:	75 12                	jne    8009ff <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009ed:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009f2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009f5:	75 08                	jne    8009ff <strtol+0x6e>
		s++, base = 8;
  8009f7:	83 c1 01             	add    $0x1,%ecx
  8009fa:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800a04:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a07:	0f b6 11             	movzbl (%ecx),%edx
  800a0a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a0d:	89 f3                	mov    %esi,%ebx
  800a0f:	80 fb 09             	cmp    $0x9,%bl
  800a12:	77 08                	ja     800a1c <strtol+0x8b>
			dig = *s - '0';
  800a14:	0f be d2             	movsbl %dl,%edx
  800a17:	83 ea 30             	sub    $0x30,%edx
  800a1a:	eb 22                	jmp    800a3e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a1c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a1f:	89 f3                	mov    %esi,%ebx
  800a21:	80 fb 19             	cmp    $0x19,%bl
  800a24:	77 08                	ja     800a2e <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a26:	0f be d2             	movsbl %dl,%edx
  800a29:	83 ea 57             	sub    $0x57,%edx
  800a2c:	eb 10                	jmp    800a3e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a2e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a31:	89 f3                	mov    %esi,%ebx
  800a33:	80 fb 19             	cmp    $0x19,%bl
  800a36:	77 16                	ja     800a4e <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a38:	0f be d2             	movsbl %dl,%edx
  800a3b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a3e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a41:	7d 0b                	jge    800a4e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a43:	83 c1 01             	add    $0x1,%ecx
  800a46:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a4a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a4c:	eb b9                	jmp    800a07 <strtol+0x76>

	if (endptr)
  800a4e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a52:	74 0d                	je     800a61 <strtol+0xd0>
		*endptr = (char *) s;
  800a54:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a57:	89 0e                	mov    %ecx,(%esi)
  800a59:	eb 06                	jmp    800a61 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a5b:	85 db                	test   %ebx,%ebx
  800a5d:	74 98                	je     8009f7 <strtol+0x66>
  800a5f:	eb 9e                	jmp    8009ff <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a61:	89 c2                	mov    %eax,%edx
  800a63:	f7 da                	neg    %edx
  800a65:	85 ff                	test   %edi,%edi
  800a67:	0f 45 c2             	cmovne %edx,%eax
}
  800a6a:	5b                   	pop    %ebx
  800a6b:	5e                   	pop    %esi
  800a6c:	5f                   	pop    %edi
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    

00800a6f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	57                   	push   %edi
  800a73:	56                   	push   %esi
  800a74:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a75:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a80:	89 c3                	mov    %eax,%ebx
  800a82:	89 c7                	mov    %eax,%edi
  800a84:	89 c6                	mov    %eax,%esi
  800a86:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a88:	5b                   	pop    %ebx
  800a89:	5e                   	pop    %esi
  800a8a:	5f                   	pop    %edi
  800a8b:	5d                   	pop    %ebp
  800a8c:	c3                   	ret    

00800a8d <sys_cgetc>:

int
sys_cgetc(void)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	57                   	push   %edi
  800a91:	56                   	push   %esi
  800a92:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a93:	ba 00 00 00 00       	mov    $0x0,%edx
  800a98:	b8 01 00 00 00       	mov    $0x1,%eax
  800a9d:	89 d1                	mov    %edx,%ecx
  800a9f:	89 d3                	mov    %edx,%ebx
  800aa1:	89 d7                	mov    %edx,%edi
  800aa3:	89 d6                	mov    %edx,%esi
  800aa5:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aa7:	5b                   	pop    %ebx
  800aa8:	5e                   	pop    %esi
  800aa9:	5f                   	pop    %edi
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	57                   	push   %edi
  800ab0:	56                   	push   %esi
  800ab1:	53                   	push   %ebx
  800ab2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aba:	b8 03 00 00 00       	mov    $0x3,%eax
  800abf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac2:	89 cb                	mov    %ecx,%ebx
  800ac4:	89 cf                	mov    %ecx,%edi
  800ac6:	89 ce                	mov    %ecx,%esi
  800ac8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aca:	85 c0                	test   %eax,%eax
  800acc:	7e 17                	jle    800ae5 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ace:	83 ec 0c             	sub    $0xc,%esp
  800ad1:	50                   	push   %eax
  800ad2:	6a 03                	push   $0x3
  800ad4:	68 48 13 80 00       	push   $0x801348
  800ad9:	6a 23                	push   $0x23
  800adb:	68 65 13 80 00       	push   $0x801365
  800ae0:	e8 fb 02 00 00       	call   800de0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ae5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ae8:	5b                   	pop    %ebx
  800ae9:	5e                   	pop    %esi
  800aea:	5f                   	pop    %edi
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	57                   	push   %edi
  800af1:	56                   	push   %esi
  800af2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af3:	ba 00 00 00 00       	mov    $0x0,%edx
  800af8:	b8 02 00 00 00       	mov    $0x2,%eax
  800afd:	89 d1                	mov    %edx,%ecx
  800aff:	89 d3                	mov    %edx,%ebx
  800b01:	89 d7                	mov    %edx,%edi
  800b03:	89 d6                	mov    %edx,%esi
  800b05:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b07:	5b                   	pop    %ebx
  800b08:	5e                   	pop    %esi
  800b09:	5f                   	pop    %edi
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <sys_yield>:

void
sys_yield(void)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b12:	ba 00 00 00 00       	mov    $0x0,%edx
  800b17:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b1c:	89 d1                	mov    %edx,%ecx
  800b1e:	89 d3                	mov    %edx,%ebx
  800b20:	89 d7                	mov    %edx,%edi
  800b22:	89 d6                	mov    %edx,%esi
  800b24:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b26:	5b                   	pop    %ebx
  800b27:	5e                   	pop    %esi
  800b28:	5f                   	pop    %edi
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800b34:	be 00 00 00 00       	mov    $0x0,%esi
  800b39:	b8 04 00 00 00       	mov    $0x4,%eax
  800b3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b41:	8b 55 08             	mov    0x8(%ebp),%edx
  800b44:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b47:	89 f7                	mov    %esi,%edi
  800b49:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b4b:	85 c0                	test   %eax,%eax
  800b4d:	7e 17                	jle    800b66 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4f:	83 ec 0c             	sub    $0xc,%esp
  800b52:	50                   	push   %eax
  800b53:	6a 04                	push   $0x4
  800b55:	68 48 13 80 00       	push   $0x801348
  800b5a:	6a 23                	push   $0x23
  800b5c:	68 65 13 80 00       	push   $0x801365
  800b61:	e8 7a 02 00 00       	call   800de0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5f                   	pop    %edi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
  800b74:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b77:	b8 05 00 00 00       	mov    $0x5,%eax
  800b7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b82:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b85:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b88:	8b 75 18             	mov    0x18(%ebp),%esi
  800b8b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b8d:	85 c0                	test   %eax,%eax
  800b8f:	7e 17                	jle    800ba8 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b91:	83 ec 0c             	sub    $0xc,%esp
  800b94:	50                   	push   %eax
  800b95:	6a 05                	push   $0x5
  800b97:	68 48 13 80 00       	push   $0x801348
  800b9c:	6a 23                	push   $0x23
  800b9e:	68 65 13 80 00       	push   $0x801365
  800ba3:	e8 38 02 00 00       	call   800de0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ba8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bab:	5b                   	pop    %ebx
  800bac:	5e                   	pop    %esi
  800bad:	5f                   	pop    %edi
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    

00800bb0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	57                   	push   %edi
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
  800bb6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bbe:	b8 06 00 00 00       	mov    $0x6,%eax
  800bc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc9:	89 df                	mov    %ebx,%edi
  800bcb:	89 de                	mov    %ebx,%esi
  800bcd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bcf:	85 c0                	test   %eax,%eax
  800bd1:	7e 17                	jle    800bea <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd3:	83 ec 0c             	sub    $0xc,%esp
  800bd6:	50                   	push   %eax
  800bd7:	6a 06                	push   $0x6
  800bd9:	68 48 13 80 00       	push   $0x801348
  800bde:	6a 23                	push   $0x23
  800be0:	68 65 13 80 00       	push   $0x801365
  800be5:	e8 f6 01 00 00       	call   800de0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5f                   	pop    %edi
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    

00800bf2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
  800bf8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c00:	b8 08 00 00 00       	mov    $0x8,%eax
  800c05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c08:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0b:	89 df                	mov    %ebx,%edi
  800c0d:	89 de                	mov    %ebx,%esi
  800c0f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c11:	85 c0                	test   %eax,%eax
  800c13:	7e 17                	jle    800c2c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c15:	83 ec 0c             	sub    $0xc,%esp
  800c18:	50                   	push   %eax
  800c19:	6a 08                	push   $0x8
  800c1b:	68 48 13 80 00       	push   $0x801348
  800c20:	6a 23                	push   $0x23
  800c22:	68 65 13 80 00       	push   $0x801365
  800c27:	e8 b4 01 00 00       	call   800de0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
  800c3a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c42:	b8 09 00 00 00       	mov    $0x9,%eax
  800c47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4d:	89 df                	mov    %ebx,%edi
  800c4f:	89 de                	mov    %ebx,%esi
  800c51:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c53:	85 c0                	test   %eax,%eax
  800c55:	7e 17                	jle    800c6e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c57:	83 ec 0c             	sub    $0xc,%esp
  800c5a:	50                   	push   %eax
  800c5b:	6a 09                	push   $0x9
  800c5d:	68 48 13 80 00       	push   $0x801348
  800c62:	6a 23                	push   $0x23
  800c64:	68 65 13 80 00       	push   $0x801365
  800c69:	e8 72 01 00 00       	call   800de0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    

00800c76 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	57                   	push   %edi
  800c7a:	56                   	push   %esi
  800c7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7c:	be 00 00 00 00       	mov    $0x0,%esi
  800c81:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c89:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c92:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
  800c9f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cac:	8b 55 08             	mov    0x8(%ebp),%edx
  800caf:	89 cb                	mov    %ecx,%ebx
  800cb1:	89 cf                	mov    %ecx,%edi
  800cb3:	89 ce                	mov    %ecx,%esi
  800cb5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb7:	85 c0                	test   %eax,%eax
  800cb9:	7e 17                	jle    800cd2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbb:	83 ec 0c             	sub    $0xc,%esp
  800cbe:	50                   	push   %eax
  800cbf:	6a 0c                	push   $0xc
  800cc1:	68 48 13 80 00       	push   $0x801348
  800cc6:	6a 23                	push   $0x23
  800cc8:	68 65 13 80 00       	push   $0x801365
  800ccd:	e8 0e 01 00 00       	call   800de0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
  800ce0:	83 ec 18             	sub    $0x18,%esp
  800ce3:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ce6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ce9:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
    int r = sys_ipc_recv((pg) ? pg : (void *)UTOP);
  800cec:	85 db                	test   %ebx,%ebx
  800cee:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800cf3:	0f 45 c3             	cmovne %ebx,%eax
  800cf6:	50                   	push   %eax
  800cf7:	e8 9d ff ff ff       	call   800c99 <sys_ipc_recv>
  800cfc:	89 c2                	mov    %eax,%edx

    if (from_env_store)
  800cfe:	83 c4 10             	add    $0x10,%esp
  800d01:	85 ff                	test   %edi,%edi
  800d03:	74 13                	je     800d18 <ipc_recv+0x3e>
    {
        *from_env_store = (r == 0) ? thisenv->env_ipc_from : 0;
  800d05:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0a:	85 d2                	test   %edx,%edx
  800d0c:	75 08                	jne    800d16 <ipc_recv+0x3c>
  800d0e:	a1 04 20 80 00       	mov    0x802004,%eax
  800d13:	8b 40 74             	mov    0x74(%eax),%eax
  800d16:	89 07                	mov    %eax,(%edi)
    }

    if (perm_store)
  800d18:	85 f6                	test   %esi,%esi
  800d1a:	74 1d                	je     800d39 <ipc_recv+0x5f>
    {
        *perm_store = (r == 0 && (uint32_t) pg < UTOP) ? thisenv->env_ipc_perm : 0;
  800d1c:	85 d2                	test   %edx,%edx
  800d1e:	75 12                	jne    800d32 <ipc_recv+0x58>
  800d20:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  800d26:	77 0a                	ja     800d32 <ipc_recv+0x58>
  800d28:	a1 04 20 80 00       	mov    0x802004,%eax
  800d2d:	8b 40 78             	mov    0x78(%eax),%eax
  800d30:	eb 05                	jmp    800d37 <ipc_recv+0x5d>
  800d32:	b8 00 00 00 00       	mov    $0x0,%eax
  800d37:	89 06                	mov    %eax,(%esi)
    }

    if (r)
    {
        return r;
  800d39:	89 d0                	mov    %edx,%eax
    if (perm_store)
    {
        *perm_store = (r == 0 && (uint32_t) pg < UTOP) ? thisenv->env_ipc_perm : 0;
    }

    if (r)
  800d3b:	85 d2                	test   %edx,%edx
  800d3d:	75 08                	jne    800d47 <ipc_recv+0x6d>
    {
        return r;
    }

    return thisenv->env_ipc_value;
  800d3f:	a1 04 20 80 00       	mov    0x802004,%eax
  800d44:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  800d47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4a:	5b                   	pop    %ebx
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    

00800d4f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	57                   	push   %edi
  800d53:	56                   	push   %esi
  800d54:	53                   	push   %ebx
  800d55:	83 ec 0c             	sub    $0xc,%esp
  800d58:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d5b:	8b 45 10             	mov    0x10(%ebp),%eax
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
  800d65:	0f 45 f0             	cmovne %eax,%esi
	// LAB 4: Your code here.
 
    int r = 0;
    do
    {
        r = sys_ipc_try_send(to_env, val, pg ? pg : (void *)UTOP, perm);
  800d68:	ff 75 14             	pushl  0x14(%ebp)
  800d6b:	56                   	push   %esi
  800d6c:	ff 75 0c             	pushl  0xc(%ebp)
  800d6f:	57                   	push   %edi
  800d70:	e8 01 ff ff ff       	call   800c76 <sys_ipc_try_send>
  800d75:	89 c3                	mov    %eax,%ebx

        if (r != 0 && r != -E_IPC_NOT_RECV)
  800d77:	8d 40 08             	lea    0x8(%eax),%eax
  800d7a:	83 c4 10             	add    $0x10,%esp
  800d7d:	a9 f7 ff ff ff       	test   $0xfffffff7,%eax
  800d82:	74 12                	je     800d96 <ipc_send+0x47>
        {
            panic("ipc_send: error %e", r);
  800d84:	53                   	push   %ebx
  800d85:	68 73 13 80 00       	push   $0x801373
  800d8a:	6a 44                	push   $0x44
  800d8c:	68 86 13 80 00       	push   $0x801386
  800d91:	e8 4a 00 00 00       	call   800de0 <_panic>
        }
        else
        {
            sys_yield();
  800d96:	e8 71 fd ff ff       	call   800b0c <sys_yield>
        }
    }while(r != 0);
  800d9b:	85 db                	test   %ebx,%ebx
  800d9d:	75 c9                	jne    800d68 <ipc_send+0x19>
	//panic("ipc_send not implemented");
}
  800d9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da2:	5b                   	pop    %ebx
  800da3:	5e                   	pop    %esi
  800da4:	5f                   	pop    %edi
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800dad:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800db2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800db5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800dbb:	8b 52 50             	mov    0x50(%edx),%edx
  800dbe:	39 ca                	cmp    %ecx,%edx
  800dc0:	75 0d                	jne    800dcf <ipc_find_env+0x28>
			return envs[i].env_id;
  800dc2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800dc5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800dca:	8b 40 48             	mov    0x48(%eax),%eax
  800dcd:	eb 0f                	jmp    800dde <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800dcf:	83 c0 01             	add    $0x1,%eax
  800dd2:	3d 00 04 00 00       	cmp    $0x400,%eax
  800dd7:	75 d9                	jne    800db2 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800dd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	56                   	push   %esi
  800de4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800de5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800de8:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800dee:	e8 fa fc ff ff       	call   800aed <sys_getenvid>
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	ff 75 0c             	pushl  0xc(%ebp)
  800df9:	ff 75 08             	pushl  0x8(%ebp)
  800dfc:	56                   	push   %esi
  800dfd:	50                   	push   %eax
  800dfe:	68 90 13 80 00       	push   $0x801390
  800e03:	e8 84 f3 ff ff       	call   80018c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e08:	83 c4 18             	add    $0x18,%esp
  800e0b:	53                   	push   %ebx
  800e0c:	ff 75 10             	pushl  0x10(%ebp)
  800e0f:	e8 27 f3 ff ff       	call   80013b <vcprintf>
	cprintf("\n");
  800e14:	c7 04 24 cf 10 80 00 	movl   $0x8010cf,(%esp)
  800e1b:	e8 6c f3 ff ff       	call   80018c <cprintf>
  800e20:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e23:	cc                   	int3   
  800e24:	eb fd                	jmp    800e23 <_panic+0x43>
  800e26:	66 90                	xchg   %ax,%ax
  800e28:	66 90                	xchg   %ax,%ax
  800e2a:	66 90                	xchg   %ax,%ax
  800e2c:	66 90                	xchg   %ax,%ax
  800e2e:	66 90                	xchg   %ax,%ax

00800e30 <__udivdi3>:
  800e30:	55                   	push   %ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	53                   	push   %ebx
  800e34:	83 ec 1c             	sub    $0x1c,%esp
  800e37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800e3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800e3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800e43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e47:	85 f6                	test   %esi,%esi
  800e49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e4d:	89 ca                	mov    %ecx,%edx
  800e4f:	89 f8                	mov    %edi,%eax
  800e51:	75 3d                	jne    800e90 <__udivdi3+0x60>
  800e53:	39 cf                	cmp    %ecx,%edi
  800e55:	0f 87 c5 00 00 00    	ja     800f20 <__udivdi3+0xf0>
  800e5b:	85 ff                	test   %edi,%edi
  800e5d:	89 fd                	mov    %edi,%ebp
  800e5f:	75 0b                	jne    800e6c <__udivdi3+0x3c>
  800e61:	b8 01 00 00 00       	mov    $0x1,%eax
  800e66:	31 d2                	xor    %edx,%edx
  800e68:	f7 f7                	div    %edi
  800e6a:	89 c5                	mov    %eax,%ebp
  800e6c:	89 c8                	mov    %ecx,%eax
  800e6e:	31 d2                	xor    %edx,%edx
  800e70:	f7 f5                	div    %ebp
  800e72:	89 c1                	mov    %eax,%ecx
  800e74:	89 d8                	mov    %ebx,%eax
  800e76:	89 cf                	mov    %ecx,%edi
  800e78:	f7 f5                	div    %ebp
  800e7a:	89 c3                	mov    %eax,%ebx
  800e7c:	89 d8                	mov    %ebx,%eax
  800e7e:	89 fa                	mov    %edi,%edx
  800e80:	83 c4 1c             	add    $0x1c,%esp
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    
  800e88:	90                   	nop
  800e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e90:	39 ce                	cmp    %ecx,%esi
  800e92:	77 74                	ja     800f08 <__udivdi3+0xd8>
  800e94:	0f bd fe             	bsr    %esi,%edi
  800e97:	83 f7 1f             	xor    $0x1f,%edi
  800e9a:	0f 84 98 00 00 00    	je     800f38 <__udivdi3+0x108>
  800ea0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800ea5:	89 f9                	mov    %edi,%ecx
  800ea7:	89 c5                	mov    %eax,%ebp
  800ea9:	29 fb                	sub    %edi,%ebx
  800eab:	d3 e6                	shl    %cl,%esi
  800ead:	89 d9                	mov    %ebx,%ecx
  800eaf:	d3 ed                	shr    %cl,%ebp
  800eb1:	89 f9                	mov    %edi,%ecx
  800eb3:	d3 e0                	shl    %cl,%eax
  800eb5:	09 ee                	or     %ebp,%esi
  800eb7:	89 d9                	mov    %ebx,%ecx
  800eb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ebd:	89 d5                	mov    %edx,%ebp
  800ebf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ec3:	d3 ed                	shr    %cl,%ebp
  800ec5:	89 f9                	mov    %edi,%ecx
  800ec7:	d3 e2                	shl    %cl,%edx
  800ec9:	89 d9                	mov    %ebx,%ecx
  800ecb:	d3 e8                	shr    %cl,%eax
  800ecd:	09 c2                	or     %eax,%edx
  800ecf:	89 d0                	mov    %edx,%eax
  800ed1:	89 ea                	mov    %ebp,%edx
  800ed3:	f7 f6                	div    %esi
  800ed5:	89 d5                	mov    %edx,%ebp
  800ed7:	89 c3                	mov    %eax,%ebx
  800ed9:	f7 64 24 0c          	mull   0xc(%esp)
  800edd:	39 d5                	cmp    %edx,%ebp
  800edf:	72 10                	jb     800ef1 <__udivdi3+0xc1>
  800ee1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800ee5:	89 f9                	mov    %edi,%ecx
  800ee7:	d3 e6                	shl    %cl,%esi
  800ee9:	39 c6                	cmp    %eax,%esi
  800eeb:	73 07                	jae    800ef4 <__udivdi3+0xc4>
  800eed:	39 d5                	cmp    %edx,%ebp
  800eef:	75 03                	jne    800ef4 <__udivdi3+0xc4>
  800ef1:	83 eb 01             	sub    $0x1,%ebx
  800ef4:	31 ff                	xor    %edi,%edi
  800ef6:	89 d8                	mov    %ebx,%eax
  800ef8:	89 fa                	mov    %edi,%edx
  800efa:	83 c4 1c             	add    $0x1c,%esp
  800efd:	5b                   	pop    %ebx
  800efe:	5e                   	pop    %esi
  800eff:	5f                   	pop    %edi
  800f00:	5d                   	pop    %ebp
  800f01:	c3                   	ret    
  800f02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f08:	31 ff                	xor    %edi,%edi
  800f0a:	31 db                	xor    %ebx,%ebx
  800f0c:	89 d8                	mov    %ebx,%eax
  800f0e:	89 fa                	mov    %edi,%edx
  800f10:	83 c4 1c             	add    $0x1c,%esp
  800f13:	5b                   	pop    %ebx
  800f14:	5e                   	pop    %esi
  800f15:	5f                   	pop    %edi
  800f16:	5d                   	pop    %ebp
  800f17:	c3                   	ret    
  800f18:	90                   	nop
  800f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f20:	89 d8                	mov    %ebx,%eax
  800f22:	f7 f7                	div    %edi
  800f24:	31 ff                	xor    %edi,%edi
  800f26:	89 c3                	mov    %eax,%ebx
  800f28:	89 d8                	mov    %ebx,%eax
  800f2a:	89 fa                	mov    %edi,%edx
  800f2c:	83 c4 1c             	add    $0x1c,%esp
  800f2f:	5b                   	pop    %ebx
  800f30:	5e                   	pop    %esi
  800f31:	5f                   	pop    %edi
  800f32:	5d                   	pop    %ebp
  800f33:	c3                   	ret    
  800f34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f38:	39 ce                	cmp    %ecx,%esi
  800f3a:	72 0c                	jb     800f48 <__udivdi3+0x118>
  800f3c:	31 db                	xor    %ebx,%ebx
  800f3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800f42:	0f 87 34 ff ff ff    	ja     800e7c <__udivdi3+0x4c>
  800f48:	bb 01 00 00 00       	mov    $0x1,%ebx
  800f4d:	e9 2a ff ff ff       	jmp    800e7c <__udivdi3+0x4c>
  800f52:	66 90                	xchg   %ax,%ax
  800f54:	66 90                	xchg   %ax,%ax
  800f56:	66 90                	xchg   %ax,%ax
  800f58:	66 90                	xchg   %ax,%ax
  800f5a:	66 90                	xchg   %ax,%ax
  800f5c:	66 90                	xchg   %ax,%ax
  800f5e:	66 90                	xchg   %ax,%ax

00800f60 <__umoddi3>:
  800f60:	55                   	push   %ebp
  800f61:	57                   	push   %edi
  800f62:	56                   	push   %esi
  800f63:	53                   	push   %ebx
  800f64:	83 ec 1c             	sub    $0x1c,%esp
  800f67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f77:	85 d2                	test   %edx,%edx
  800f79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f81:	89 f3                	mov    %esi,%ebx
  800f83:	89 3c 24             	mov    %edi,(%esp)
  800f86:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f8a:	75 1c                	jne    800fa8 <__umoddi3+0x48>
  800f8c:	39 f7                	cmp    %esi,%edi
  800f8e:	76 50                	jbe    800fe0 <__umoddi3+0x80>
  800f90:	89 c8                	mov    %ecx,%eax
  800f92:	89 f2                	mov    %esi,%edx
  800f94:	f7 f7                	div    %edi
  800f96:	89 d0                	mov    %edx,%eax
  800f98:	31 d2                	xor    %edx,%edx
  800f9a:	83 c4 1c             	add    $0x1c,%esp
  800f9d:	5b                   	pop    %ebx
  800f9e:	5e                   	pop    %esi
  800f9f:	5f                   	pop    %edi
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    
  800fa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fa8:	39 f2                	cmp    %esi,%edx
  800faa:	89 d0                	mov    %edx,%eax
  800fac:	77 52                	ja     801000 <__umoddi3+0xa0>
  800fae:	0f bd ea             	bsr    %edx,%ebp
  800fb1:	83 f5 1f             	xor    $0x1f,%ebp
  800fb4:	75 5a                	jne    801010 <__umoddi3+0xb0>
  800fb6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800fba:	0f 82 e0 00 00 00    	jb     8010a0 <__umoddi3+0x140>
  800fc0:	39 0c 24             	cmp    %ecx,(%esp)
  800fc3:	0f 86 d7 00 00 00    	jbe    8010a0 <__umoddi3+0x140>
  800fc9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fcd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fd1:	83 c4 1c             	add    $0x1c,%esp
  800fd4:	5b                   	pop    %ebx
  800fd5:	5e                   	pop    %esi
  800fd6:	5f                   	pop    %edi
  800fd7:	5d                   	pop    %ebp
  800fd8:	c3                   	ret    
  800fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fe0:	85 ff                	test   %edi,%edi
  800fe2:	89 fd                	mov    %edi,%ebp
  800fe4:	75 0b                	jne    800ff1 <__umoddi3+0x91>
  800fe6:	b8 01 00 00 00       	mov    $0x1,%eax
  800feb:	31 d2                	xor    %edx,%edx
  800fed:	f7 f7                	div    %edi
  800fef:	89 c5                	mov    %eax,%ebp
  800ff1:	89 f0                	mov    %esi,%eax
  800ff3:	31 d2                	xor    %edx,%edx
  800ff5:	f7 f5                	div    %ebp
  800ff7:	89 c8                	mov    %ecx,%eax
  800ff9:	f7 f5                	div    %ebp
  800ffb:	89 d0                	mov    %edx,%eax
  800ffd:	eb 99                	jmp    800f98 <__umoddi3+0x38>
  800fff:	90                   	nop
  801000:	89 c8                	mov    %ecx,%eax
  801002:	89 f2                	mov    %esi,%edx
  801004:	83 c4 1c             	add    $0x1c,%esp
  801007:	5b                   	pop    %ebx
  801008:	5e                   	pop    %esi
  801009:	5f                   	pop    %edi
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    
  80100c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801010:	8b 34 24             	mov    (%esp),%esi
  801013:	bf 20 00 00 00       	mov    $0x20,%edi
  801018:	89 e9                	mov    %ebp,%ecx
  80101a:	29 ef                	sub    %ebp,%edi
  80101c:	d3 e0                	shl    %cl,%eax
  80101e:	89 f9                	mov    %edi,%ecx
  801020:	89 f2                	mov    %esi,%edx
  801022:	d3 ea                	shr    %cl,%edx
  801024:	89 e9                	mov    %ebp,%ecx
  801026:	09 c2                	or     %eax,%edx
  801028:	89 d8                	mov    %ebx,%eax
  80102a:	89 14 24             	mov    %edx,(%esp)
  80102d:	89 f2                	mov    %esi,%edx
  80102f:	d3 e2                	shl    %cl,%edx
  801031:	89 f9                	mov    %edi,%ecx
  801033:	89 54 24 04          	mov    %edx,0x4(%esp)
  801037:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80103b:	d3 e8                	shr    %cl,%eax
  80103d:	89 e9                	mov    %ebp,%ecx
  80103f:	89 c6                	mov    %eax,%esi
  801041:	d3 e3                	shl    %cl,%ebx
  801043:	89 f9                	mov    %edi,%ecx
  801045:	89 d0                	mov    %edx,%eax
  801047:	d3 e8                	shr    %cl,%eax
  801049:	89 e9                	mov    %ebp,%ecx
  80104b:	09 d8                	or     %ebx,%eax
  80104d:	89 d3                	mov    %edx,%ebx
  80104f:	89 f2                	mov    %esi,%edx
  801051:	f7 34 24             	divl   (%esp)
  801054:	89 d6                	mov    %edx,%esi
  801056:	d3 e3                	shl    %cl,%ebx
  801058:	f7 64 24 04          	mull   0x4(%esp)
  80105c:	39 d6                	cmp    %edx,%esi
  80105e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801062:	89 d1                	mov    %edx,%ecx
  801064:	89 c3                	mov    %eax,%ebx
  801066:	72 08                	jb     801070 <__umoddi3+0x110>
  801068:	75 11                	jne    80107b <__umoddi3+0x11b>
  80106a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80106e:	73 0b                	jae    80107b <__umoddi3+0x11b>
  801070:	2b 44 24 04          	sub    0x4(%esp),%eax
  801074:	1b 14 24             	sbb    (%esp),%edx
  801077:	89 d1                	mov    %edx,%ecx
  801079:	89 c3                	mov    %eax,%ebx
  80107b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80107f:	29 da                	sub    %ebx,%edx
  801081:	19 ce                	sbb    %ecx,%esi
  801083:	89 f9                	mov    %edi,%ecx
  801085:	89 f0                	mov    %esi,%eax
  801087:	d3 e0                	shl    %cl,%eax
  801089:	89 e9                	mov    %ebp,%ecx
  80108b:	d3 ea                	shr    %cl,%edx
  80108d:	89 e9                	mov    %ebp,%ecx
  80108f:	d3 ee                	shr    %cl,%esi
  801091:	09 d0                	or     %edx,%eax
  801093:	89 f2                	mov    %esi,%edx
  801095:	83 c4 1c             	add    $0x1c,%esp
  801098:	5b                   	pop    %ebx
  801099:	5e                   	pop    %esi
  80109a:	5f                   	pop    %edi
  80109b:	5d                   	pop    %ebp
  80109c:	c3                   	ret    
  80109d:	8d 76 00             	lea    0x0(%esi),%esi
  8010a0:	29 f9                	sub    %edi,%ecx
  8010a2:	19 d6                	sbb    %edx,%esi
  8010a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010ac:	e9 18 ff ff ff       	jmp    800fc9 <__umoddi3+0x69>
