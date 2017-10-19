
obj/user/spin：     文件格式 elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 00 15 80 00       	push   $0x801500
  80003f:	e8 5c 01 00 00       	call   8001a0 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 19 0e 00 00       	call   800e62 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 78 15 80 00       	push   $0x801578
  800058:	e8 43 01 00 00       	call   8001a0 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 28 15 80 00       	push   $0x801528
  80006c:	e8 2f 01 00 00       	call   8001a0 <cprintf>
	sys_yield();
  800071:	e8 aa 0a 00 00       	call   800b20 <sys_yield>
	sys_yield();
  800076:	e8 a5 0a 00 00       	call   800b20 <sys_yield>
	sys_yield();
  80007b:	e8 a0 0a 00 00       	call   800b20 <sys_yield>
	sys_yield();
  800080:	e8 9b 0a 00 00       	call   800b20 <sys_yield>
	sys_yield();
  800085:	e8 96 0a 00 00       	call   800b20 <sys_yield>
	sys_yield();
  80008a:	e8 91 0a 00 00       	call   800b20 <sys_yield>
	sys_yield();
  80008f:	e8 8c 0a 00 00       	call   800b20 <sys_yield>
	sys_yield();
  800094:	e8 87 0a 00 00       	call   800b20 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 50 15 80 00 	movl   $0x801550,(%esp)
  8000a0:	e8 fb 00 00 00       	call   8001a0 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 13 0a 00 00       	call   800ac0 <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000c0:	e8 3c 0a 00 00       	call   800b01 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 47 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800101:	6a 00                	push   $0x0
  800103:	e8 b8 09 00 00       	call   800ac0 <sys_env_destroy>
}
  800108:	83 c4 10             	add    $0x10,%esp
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	53                   	push   %ebx
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800117:	8b 13                	mov    (%ebx),%edx
  800119:	8d 42 01             	lea    0x1(%edx),%eax
  80011c:	89 03                	mov    %eax,(%ebx)
  80011e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800121:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800125:	3d ff 00 00 00       	cmp    $0xff,%eax
  80012a:	75 1a                	jne    800146 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80012c:	83 ec 08             	sub    $0x8,%esp
  80012f:	68 ff 00 00 00       	push   $0xff
  800134:	8d 43 08             	lea    0x8(%ebx),%eax
  800137:	50                   	push   %eax
  800138:	e8 46 09 00 00       	call   800a83 <sys_cputs>
		b->idx = 0;
  80013d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800143:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800146:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80014a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800158:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80015f:	00 00 00 
	b.cnt = 0;
  800162:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800169:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016c:	ff 75 0c             	pushl  0xc(%ebp)
  80016f:	ff 75 08             	pushl  0x8(%ebp)
  800172:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800178:	50                   	push   %eax
  800179:	68 0d 01 80 00       	push   $0x80010d
  80017e:	e8 54 01 00 00       	call   8002d7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800183:	83 c4 08             	add    $0x8,%esp
  800186:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80018c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	e8 eb 08 00 00       	call   800a83 <sys_cputs>

	return b.cnt;
}
  800198:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a9:	50                   	push   %eax
  8001aa:	ff 75 08             	pushl  0x8(%ebp)
  8001ad:	e8 9d ff ff ff       	call   80014f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	57                   	push   %edi
  8001b8:	56                   	push   %esi
  8001b9:	53                   	push   %ebx
  8001ba:	83 ec 1c             	sub    $0x1c,%esp
  8001bd:	89 c7                	mov    %eax,%edi
  8001bf:	89 d6                	mov    %edx,%esi
  8001c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ca:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001d8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001db:	39 d3                	cmp    %edx,%ebx
  8001dd:	72 05                	jb     8001e4 <printnum+0x30>
  8001df:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001e2:	77 45                	ja     800229 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 18             	pushl  0x18(%ebp)
  8001ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8001ed:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f0:	53                   	push   %ebx
  8001f1:	ff 75 10             	pushl  0x10(%ebp)
  8001f4:	83 ec 08             	sub    $0x8,%esp
  8001f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8001fd:	ff 75 dc             	pushl  -0x24(%ebp)
  800200:	ff 75 d8             	pushl  -0x28(%ebp)
  800203:	e8 68 10 00 00       	call   801270 <__udivdi3>
  800208:	83 c4 18             	add    $0x18,%esp
  80020b:	52                   	push   %edx
  80020c:	50                   	push   %eax
  80020d:	89 f2                	mov    %esi,%edx
  80020f:	89 f8                	mov    %edi,%eax
  800211:	e8 9e ff ff ff       	call   8001b4 <printnum>
  800216:	83 c4 20             	add    $0x20,%esp
  800219:	eb 18                	jmp    800233 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80021b:	83 ec 08             	sub    $0x8,%esp
  80021e:	56                   	push   %esi
  80021f:	ff 75 18             	pushl  0x18(%ebp)
  800222:	ff d7                	call   *%edi
  800224:	83 c4 10             	add    $0x10,%esp
  800227:	eb 03                	jmp    80022c <printnum+0x78>
  800229:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022c:	83 eb 01             	sub    $0x1,%ebx
  80022f:	85 db                	test   %ebx,%ebx
  800231:	7f e8                	jg     80021b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800233:	83 ec 08             	sub    $0x8,%esp
  800236:	56                   	push   %esi
  800237:	83 ec 04             	sub    $0x4,%esp
  80023a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80023d:	ff 75 e0             	pushl  -0x20(%ebp)
  800240:	ff 75 dc             	pushl  -0x24(%ebp)
  800243:	ff 75 d8             	pushl  -0x28(%ebp)
  800246:	e8 55 11 00 00       	call   8013a0 <__umoddi3>
  80024b:	83 c4 14             	add    $0x14,%esp
  80024e:	0f be 80 a0 15 80 00 	movsbl 0x8015a0(%eax),%eax
  800255:	50                   	push   %eax
  800256:	ff d7                	call   *%edi
}
  800258:	83 c4 10             	add    $0x10,%esp
  80025b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025e:	5b                   	pop    %ebx
  80025f:	5e                   	pop    %esi
  800260:	5f                   	pop    %edi
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800266:	83 fa 01             	cmp    $0x1,%edx
  800269:	7e 0e                	jle    800279 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80026b:	8b 10                	mov    (%eax),%edx
  80026d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800270:	89 08                	mov    %ecx,(%eax)
  800272:	8b 02                	mov    (%edx),%eax
  800274:	8b 52 04             	mov    0x4(%edx),%edx
  800277:	eb 22                	jmp    80029b <getuint+0x38>
	else if (lflag)
  800279:	85 d2                	test   %edx,%edx
  80027b:	74 10                	je     80028d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80027d:	8b 10                	mov    (%eax),%edx
  80027f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800282:	89 08                	mov    %ecx,(%eax)
  800284:	8b 02                	mov    (%edx),%eax
  800286:	ba 00 00 00 00       	mov    $0x0,%edx
  80028b:	eb 0e                	jmp    80029b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80028d:	8b 10                	mov    (%eax),%edx
  80028f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800292:	89 08                	mov    %ecx,(%eax)
  800294:	8b 02                	mov    (%edx),%eax
  800296:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    

0080029d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a7:	8b 10                	mov    (%eax),%edx
  8002a9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ac:	73 0a                	jae    8002b8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ae:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002b1:	89 08                	mov    %ecx,(%eax)
  8002b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b6:	88 02                	mov    %al,(%edx)
}
  8002b8:	5d                   	pop    %ebp
  8002b9:	c3                   	ret    

008002ba <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
  8002bd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c3:	50                   	push   %eax
  8002c4:	ff 75 10             	pushl  0x10(%ebp)
  8002c7:	ff 75 0c             	pushl  0xc(%ebp)
  8002ca:	ff 75 08             	pushl  0x8(%ebp)
  8002cd:	e8 05 00 00 00       	call   8002d7 <vprintfmt>
	va_end(ap);
}
  8002d2:	83 c4 10             	add    $0x10,%esp
  8002d5:	c9                   	leave  
  8002d6:	c3                   	ret    

008002d7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	57                   	push   %edi
  8002db:	56                   	push   %esi
  8002dc:	53                   	push   %ebx
  8002dd:	83 ec 2c             	sub    $0x2c,%esp
  8002e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
  8002e3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002ea:	eb 17                	jmp    800303 <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ec:	85 c0                	test   %eax,%eax
  8002ee:	0f 84 9f 03 00 00    	je     800693 <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
  8002f4:	83 ec 08             	sub    $0x8,%esp
  8002f7:	ff 75 0c             	pushl  0xc(%ebp)
  8002fa:	50                   	push   %eax
  8002fb:	ff 55 08             	call   *0x8(%ebp)
  8002fe:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800301:	89 f3                	mov    %esi,%ebx
  800303:	8d 73 01             	lea    0x1(%ebx),%esi
  800306:	0f b6 03             	movzbl (%ebx),%eax
  800309:	83 f8 25             	cmp    $0x25,%eax
  80030c:	75 de                	jne    8002ec <vprintfmt+0x15>
  80030e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800312:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800319:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80031e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800325:	ba 00 00 00 00       	mov    $0x0,%edx
  80032a:	eb 06                	jmp    800332 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032c:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80032e:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800332:	8d 5e 01             	lea    0x1(%esi),%ebx
  800335:	0f b6 06             	movzbl (%esi),%eax
  800338:	0f b6 c8             	movzbl %al,%ecx
  80033b:	83 e8 23             	sub    $0x23,%eax
  80033e:	3c 55                	cmp    $0x55,%al
  800340:	0f 87 2d 03 00 00    	ja     800673 <vprintfmt+0x39c>
  800346:	0f b6 c0             	movzbl %al,%eax
  800349:	ff 24 85 60 16 80 00 	jmp    *0x801660(,%eax,4)
  800350:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800352:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800356:	eb da                	jmp    800332 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800358:	89 de                	mov    %ebx,%esi
  80035a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80035f:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  800362:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  800366:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  800369:	8d 41 d0             	lea    -0x30(%ecx),%eax
  80036c:	83 f8 09             	cmp    $0x9,%eax
  80036f:	77 33                	ja     8003a4 <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800371:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800374:	eb e9                	jmp    80035f <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800376:	8b 45 14             	mov    0x14(%ebp),%eax
  800379:	8d 48 04             	lea    0x4(%eax),%ecx
  80037c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80037f:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800381:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800383:	eb 1f                	jmp    8003a4 <vprintfmt+0xcd>
  800385:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800388:	85 c0                	test   %eax,%eax
  80038a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038f:	0f 49 c8             	cmovns %eax,%ecx
  800392:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	89 de                	mov    %ebx,%esi
  800397:	eb 99                	jmp    800332 <vprintfmt+0x5b>
  800399:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80039b:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  8003a2:	eb 8e                	jmp    800332 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8003a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a8:	79 88                	jns    800332 <vprintfmt+0x5b>
				width = precision, precision = -1;
  8003aa:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8003ad:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003b2:	e9 7b ff ff ff       	jmp    800332 <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003b7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003bc:	e9 71 ff ff ff       	jmp    800332 <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
  8003c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c4:	8d 50 04             	lea    0x4(%eax),%edx
  8003c7:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  8003ca:	83 ec 08             	sub    $0x8,%esp
  8003cd:	ff 75 0c             	pushl  0xc(%ebp)
  8003d0:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8003d3:	03 08                	add    (%eax),%ecx
  8003d5:	51                   	push   %ecx
  8003d6:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
  8003d9:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
  8003dc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
  8003e3:	e9 1b ff ff ff       	jmp    800303 <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
  8003e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003eb:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ee:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003f1:	8b 00                	mov    (%eax),%eax
  8003f3:	83 f8 02             	cmp    $0x2,%eax
  8003f6:	74 1a                	je     800412 <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	89 de                	mov    %ebx,%esi
  8003fa:	83 f8 04             	cmp    $0x4,%eax
  8003fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800402:	b9 00 04 00 00       	mov    $0x400,%ecx
  800407:	0f 44 c1             	cmove  %ecx,%eax
  80040a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80040d:	e9 20 ff ff ff       	jmp    800332 <vprintfmt+0x5b>
  800412:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
  800414:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
  80041b:	e9 12 ff ff ff       	jmp    800332 <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800420:	8b 45 14             	mov    0x14(%ebp),%eax
  800423:	8d 50 04             	lea    0x4(%eax),%edx
  800426:	89 55 14             	mov    %edx,0x14(%ebp)
  800429:	8b 00                	mov    (%eax),%eax
  80042b:	99                   	cltd   
  80042c:	31 d0                	xor    %edx,%eax
  80042e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800430:	83 f8 09             	cmp    $0x9,%eax
  800433:	7f 0b                	jg     800440 <vprintfmt+0x169>
  800435:	8b 14 85 c0 17 80 00 	mov    0x8017c0(,%eax,4),%edx
  80043c:	85 d2                	test   %edx,%edx
  80043e:	75 19                	jne    800459 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800440:	50                   	push   %eax
  800441:	68 b8 15 80 00       	push   $0x8015b8
  800446:	ff 75 0c             	pushl  0xc(%ebp)
  800449:	ff 75 08             	pushl  0x8(%ebp)
  80044c:	e8 69 fe ff ff       	call   8002ba <printfmt>
  800451:	83 c4 10             	add    $0x10,%esp
  800454:	e9 aa fe ff ff       	jmp    800303 <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  800459:	52                   	push   %edx
  80045a:	68 c1 15 80 00       	push   $0x8015c1
  80045f:	ff 75 0c             	pushl  0xc(%ebp)
  800462:	ff 75 08             	pushl  0x8(%ebp)
  800465:	e8 50 fe ff ff       	call   8002ba <printfmt>
  80046a:	83 c4 10             	add    $0x10,%esp
  80046d:	e9 91 fe ff ff       	jmp    800303 <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800472:	8b 45 14             	mov    0x14(%ebp),%eax
  800475:	8d 50 04             	lea    0x4(%eax),%edx
  800478:	89 55 14             	mov    %edx,0x14(%ebp)
  80047b:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80047d:	85 f6                	test   %esi,%esi
  80047f:	b8 b1 15 80 00       	mov    $0x8015b1,%eax
  800484:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800487:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80048b:	0f 8e 93 00 00 00    	jle    800524 <vprintfmt+0x24d>
  800491:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800495:	0f 84 91 00 00 00    	je     80052c <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	57                   	push   %edi
  80049f:	56                   	push   %esi
  8004a0:	e8 76 02 00 00       	call   80071b <strnlen>
  8004a5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a8:	29 c1                	sub    %eax,%ecx
  8004aa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004ad:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004b0:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8004b4:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004b7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ba:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004bd:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004c0:	89 cb                	mov    %ecx,%ebx
  8004c2:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c4:	eb 0e                	jmp    8004d4 <vprintfmt+0x1fd>
					putch(padc, putdat);
  8004c6:	83 ec 08             	sub    $0x8,%esp
  8004c9:	56                   	push   %esi
  8004ca:	57                   	push   %edi
  8004cb:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ce:	83 eb 01             	sub    $0x1,%ebx
  8004d1:	83 c4 10             	add    $0x10,%esp
  8004d4:	85 db                	test   %ebx,%ebx
  8004d6:	7f ee                	jg     8004c6 <vprintfmt+0x1ef>
  8004d8:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004db:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004de:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e1:	85 c9                	test   %ecx,%ecx
  8004e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e8:	0f 49 c1             	cmovns %ecx,%eax
  8004eb:	29 c1                	sub    %eax,%ecx
  8004ed:	89 cb                	mov    %ecx,%ebx
  8004ef:	eb 41                	jmp    800532 <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004f1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004f5:	74 1b                	je     800512 <vprintfmt+0x23b>
  8004f7:	0f be c0             	movsbl %al,%eax
  8004fa:	83 e8 20             	sub    $0x20,%eax
  8004fd:	83 f8 5e             	cmp    $0x5e,%eax
  800500:	76 10                	jbe    800512 <vprintfmt+0x23b>
					putch('?', putdat);
  800502:	83 ec 08             	sub    $0x8,%esp
  800505:	ff 75 0c             	pushl  0xc(%ebp)
  800508:	6a 3f                	push   $0x3f
  80050a:	ff 55 08             	call   *0x8(%ebp)
  80050d:	83 c4 10             	add    $0x10,%esp
  800510:	eb 0d                	jmp    80051f <vprintfmt+0x248>
				else
					putch(ch, putdat);
  800512:	83 ec 08             	sub    $0x8,%esp
  800515:	ff 75 0c             	pushl  0xc(%ebp)
  800518:	52                   	push   %edx
  800519:	ff 55 08             	call   *0x8(%ebp)
  80051c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051f:	83 eb 01             	sub    $0x1,%ebx
  800522:	eb 0e                	jmp    800532 <vprintfmt+0x25b>
  800524:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800527:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80052a:	eb 06                	jmp    800532 <vprintfmt+0x25b>
  80052c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80052f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800532:	83 c6 01             	add    $0x1,%esi
  800535:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800539:	0f be d0             	movsbl %al,%edx
  80053c:	85 d2                	test   %edx,%edx
  80053e:	74 25                	je     800565 <vprintfmt+0x28e>
  800540:	85 ff                	test   %edi,%edi
  800542:	78 ad                	js     8004f1 <vprintfmt+0x21a>
  800544:	83 ef 01             	sub    $0x1,%edi
  800547:	79 a8                	jns    8004f1 <vprintfmt+0x21a>
  800549:	89 d8                	mov    %ebx,%eax
  80054b:	8b 75 08             	mov    0x8(%ebp),%esi
  80054e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800551:	89 c3                	mov    %eax,%ebx
  800553:	eb 16                	jmp    80056b <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	57                   	push   %edi
  800559:	6a 20                	push   $0x20
  80055b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80055d:	83 eb 01             	sub    $0x1,%ebx
  800560:	83 c4 10             	add    $0x10,%esp
  800563:	eb 06                	jmp    80056b <vprintfmt+0x294>
  800565:	8b 75 08             	mov    0x8(%ebp),%esi
  800568:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80056b:	85 db                	test   %ebx,%ebx
  80056d:	7f e6                	jg     800555 <vprintfmt+0x27e>
  80056f:	89 75 08             	mov    %esi,0x8(%ebp)
  800572:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800575:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800578:	e9 86 fd ff ff       	jmp    800303 <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80057d:	83 fa 01             	cmp    $0x1,%edx
  800580:	7e 10                	jle    800592 <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8d 50 08             	lea    0x8(%eax),%edx
  800588:	89 55 14             	mov    %edx,0x14(%ebp)
  80058b:	8b 30                	mov    (%eax),%esi
  80058d:	8b 78 04             	mov    0x4(%eax),%edi
  800590:	eb 26                	jmp    8005b8 <vprintfmt+0x2e1>
	else if (lflag)
  800592:	85 d2                	test   %edx,%edx
  800594:	74 12                	je     8005a8 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  800596:	8b 45 14             	mov    0x14(%ebp),%eax
  800599:	8d 50 04             	lea    0x4(%eax),%edx
  80059c:	89 55 14             	mov    %edx,0x14(%ebp)
  80059f:	8b 30                	mov    (%eax),%esi
  8005a1:	89 f7                	mov    %esi,%edi
  8005a3:	c1 ff 1f             	sar    $0x1f,%edi
  8005a6:	eb 10                	jmp    8005b8 <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8d 50 04             	lea    0x4(%eax),%edx
  8005ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b1:	8b 30                	mov    (%eax),%esi
  8005b3:	89 f7                	mov    %esi,%edi
  8005b5:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b8:	89 f0                	mov    %esi,%eax
  8005ba:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005bc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c1:	85 ff                	test   %edi,%edi
  8005c3:	79 7b                	jns    800640 <vprintfmt+0x369>
				putch('-', putdat);
  8005c5:	83 ec 08             	sub    $0x8,%esp
  8005c8:	ff 75 0c             	pushl  0xc(%ebp)
  8005cb:	6a 2d                	push   $0x2d
  8005cd:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005d0:	89 f0                	mov    %esi,%eax
  8005d2:	89 fa                	mov    %edi,%edx
  8005d4:	f7 d8                	neg    %eax
  8005d6:	83 d2 00             	adc    $0x0,%edx
  8005d9:	f7 da                	neg    %edx
  8005db:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005de:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005e3:	eb 5b                	jmp    800640 <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005e5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e8:	e8 76 fc ff ff       	call   800263 <getuint>
			base = 10;
  8005ed:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005f2:	eb 4c                	jmp    800640 <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
  8005f4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f7:	e8 67 fc ff ff       	call   800263 <getuint>
            base = 8;
  8005fc:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800601:	eb 3d                	jmp    800640 <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
  800603:	83 ec 08             	sub    $0x8,%esp
  800606:	ff 75 0c             	pushl  0xc(%ebp)
  800609:	6a 30                	push   $0x30
  80060b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80060e:	83 c4 08             	add    $0x8,%esp
  800611:	ff 75 0c             	pushl  0xc(%ebp)
  800614:	6a 78                	push   $0x78
  800616:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	8d 50 04             	lea    0x4(%eax),%edx
  80061f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800622:	8b 00                	mov    (%eax),%eax
  800624:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800629:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80062c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800631:	eb 0d                	jmp    800640 <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800633:	8d 45 14             	lea    0x14(%ebp),%eax
  800636:	e8 28 fc ff ff       	call   800263 <getuint>
			base = 16;
  80063b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800640:	83 ec 0c             	sub    $0xc,%esp
  800643:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  800647:	56                   	push   %esi
  800648:	ff 75 e0             	pushl  -0x20(%ebp)
  80064b:	51                   	push   %ecx
  80064c:	52                   	push   %edx
  80064d:	50                   	push   %eax
  80064e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800651:	8b 45 08             	mov    0x8(%ebp),%eax
  800654:	e8 5b fb ff ff       	call   8001b4 <printnum>
			break;
  800659:	83 c4 20             	add    $0x20,%esp
  80065c:	e9 a2 fc ff ff       	jmp    800303 <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800661:	83 ec 08             	sub    $0x8,%esp
  800664:	ff 75 0c             	pushl  0xc(%ebp)
  800667:	51                   	push   %ecx
  800668:	ff 55 08             	call   *0x8(%ebp)
			break;
  80066b:	83 c4 10             	add    $0x10,%esp
  80066e:	e9 90 fc ff ff       	jmp    800303 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800673:	83 ec 08             	sub    $0x8,%esp
  800676:	ff 75 0c             	pushl  0xc(%ebp)
  800679:	6a 25                	push   $0x25
  80067b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80067e:	83 c4 10             	add    $0x10,%esp
  800681:	89 f3                	mov    %esi,%ebx
  800683:	eb 03                	jmp    800688 <vprintfmt+0x3b1>
  800685:	83 eb 01             	sub    $0x1,%ebx
  800688:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80068c:	75 f7                	jne    800685 <vprintfmt+0x3ae>
  80068e:	e9 70 fc ff ff       	jmp    800303 <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  800693:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800696:	5b                   	pop    %ebx
  800697:	5e                   	pop    %esi
  800698:	5f                   	pop    %edi
  800699:	5d                   	pop    %ebp
  80069a:	c3                   	ret    

0080069b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80069b:	55                   	push   %ebp
  80069c:	89 e5                	mov    %esp,%ebp
  80069e:	83 ec 18             	sub    $0x18,%esp
  8006a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006aa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ae:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b8:	85 c0                	test   %eax,%eax
  8006ba:	74 26                	je     8006e2 <vsnprintf+0x47>
  8006bc:	85 d2                	test   %edx,%edx
  8006be:	7e 22                	jle    8006e2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c0:	ff 75 14             	pushl  0x14(%ebp)
  8006c3:	ff 75 10             	pushl  0x10(%ebp)
  8006c6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c9:	50                   	push   %eax
  8006ca:	68 9d 02 80 00       	push   $0x80029d
  8006cf:	e8 03 fc ff ff       	call   8002d7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	eb 05                	jmp    8006e7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e7:	c9                   	leave  
  8006e8:	c3                   	ret    

008006e9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e9:	55                   	push   %ebp
  8006ea:	89 e5                	mov    %esp,%ebp
  8006ec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006f2:	50                   	push   %eax
  8006f3:	ff 75 10             	pushl  0x10(%ebp)
  8006f6:	ff 75 0c             	pushl  0xc(%ebp)
  8006f9:	ff 75 08             	pushl  0x8(%ebp)
  8006fc:	e8 9a ff ff ff       	call   80069b <vsnprintf>
	va_end(ap);

	return rc;
}
  800701:	c9                   	leave  
  800702:	c3                   	ret    

00800703 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800703:	55                   	push   %ebp
  800704:	89 e5                	mov    %esp,%ebp
  800706:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800709:	b8 00 00 00 00       	mov    $0x0,%eax
  80070e:	eb 03                	jmp    800713 <strlen+0x10>
		n++;
  800710:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800713:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800717:	75 f7                	jne    800710 <strlen+0xd>
		n++;
	return n;
}
  800719:	5d                   	pop    %ebp
  80071a:	c3                   	ret    

0080071b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800721:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800724:	ba 00 00 00 00       	mov    $0x0,%edx
  800729:	eb 03                	jmp    80072e <strnlen+0x13>
		n++;
  80072b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072e:	39 c2                	cmp    %eax,%edx
  800730:	74 08                	je     80073a <strnlen+0x1f>
  800732:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800736:	75 f3                	jne    80072b <strnlen+0x10>
  800738:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80073a:	5d                   	pop    %ebp
  80073b:	c3                   	ret    

0080073c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	53                   	push   %ebx
  800740:	8b 45 08             	mov    0x8(%ebp),%eax
  800743:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800746:	89 c2                	mov    %eax,%edx
  800748:	83 c2 01             	add    $0x1,%edx
  80074b:	83 c1 01             	add    $0x1,%ecx
  80074e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800752:	88 5a ff             	mov    %bl,-0x1(%edx)
  800755:	84 db                	test   %bl,%bl
  800757:	75 ef                	jne    800748 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800759:	5b                   	pop    %ebx
  80075a:	5d                   	pop    %ebp
  80075b:	c3                   	ret    

0080075c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	53                   	push   %ebx
  800760:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800763:	53                   	push   %ebx
  800764:	e8 9a ff ff ff       	call   800703 <strlen>
  800769:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80076c:	ff 75 0c             	pushl  0xc(%ebp)
  80076f:	01 d8                	add    %ebx,%eax
  800771:	50                   	push   %eax
  800772:	e8 c5 ff ff ff       	call   80073c <strcpy>
	return dst;
}
  800777:	89 d8                	mov    %ebx,%eax
  800779:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80077c:	c9                   	leave  
  80077d:	c3                   	ret    

0080077e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	56                   	push   %esi
  800782:	53                   	push   %ebx
  800783:	8b 75 08             	mov    0x8(%ebp),%esi
  800786:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800789:	89 f3                	mov    %esi,%ebx
  80078b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078e:	89 f2                	mov    %esi,%edx
  800790:	eb 0f                	jmp    8007a1 <strncpy+0x23>
		*dst++ = *src;
  800792:	83 c2 01             	add    $0x1,%edx
  800795:	0f b6 01             	movzbl (%ecx),%eax
  800798:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80079b:	80 39 01             	cmpb   $0x1,(%ecx)
  80079e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a1:	39 da                	cmp    %ebx,%edx
  8007a3:	75 ed                	jne    800792 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a5:	89 f0                	mov    %esi,%eax
  8007a7:	5b                   	pop    %ebx
  8007a8:	5e                   	pop    %esi
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	56                   	push   %esi
  8007af:	53                   	push   %ebx
  8007b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b6:	8b 55 10             	mov    0x10(%ebp),%edx
  8007b9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007bb:	85 d2                	test   %edx,%edx
  8007bd:	74 21                	je     8007e0 <strlcpy+0x35>
  8007bf:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007c3:	89 f2                	mov    %esi,%edx
  8007c5:	eb 09                	jmp    8007d0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c7:	83 c2 01             	add    $0x1,%edx
  8007ca:	83 c1 01             	add    $0x1,%ecx
  8007cd:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007d0:	39 c2                	cmp    %eax,%edx
  8007d2:	74 09                	je     8007dd <strlcpy+0x32>
  8007d4:	0f b6 19             	movzbl (%ecx),%ebx
  8007d7:	84 db                	test   %bl,%bl
  8007d9:	75 ec                	jne    8007c7 <strlcpy+0x1c>
  8007db:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007dd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007e0:	29 f0                	sub    %esi,%eax
}
  8007e2:	5b                   	pop    %ebx
  8007e3:	5e                   	pop    %esi
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ec:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ef:	eb 06                	jmp    8007f7 <strcmp+0x11>
		p++, q++;
  8007f1:	83 c1 01             	add    $0x1,%ecx
  8007f4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f7:	0f b6 01             	movzbl (%ecx),%eax
  8007fa:	84 c0                	test   %al,%al
  8007fc:	74 04                	je     800802 <strcmp+0x1c>
  8007fe:	3a 02                	cmp    (%edx),%al
  800800:	74 ef                	je     8007f1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800802:	0f b6 c0             	movzbl %al,%eax
  800805:	0f b6 12             	movzbl (%edx),%edx
  800808:	29 d0                	sub    %edx,%eax
}
  80080a:	5d                   	pop    %ebp
  80080b:	c3                   	ret    

0080080c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	53                   	push   %ebx
  800810:	8b 45 08             	mov    0x8(%ebp),%eax
  800813:	8b 55 0c             	mov    0xc(%ebp),%edx
  800816:	89 c3                	mov    %eax,%ebx
  800818:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80081b:	eb 06                	jmp    800823 <strncmp+0x17>
		n--, p++, q++;
  80081d:	83 c0 01             	add    $0x1,%eax
  800820:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800823:	39 d8                	cmp    %ebx,%eax
  800825:	74 15                	je     80083c <strncmp+0x30>
  800827:	0f b6 08             	movzbl (%eax),%ecx
  80082a:	84 c9                	test   %cl,%cl
  80082c:	74 04                	je     800832 <strncmp+0x26>
  80082e:	3a 0a                	cmp    (%edx),%cl
  800830:	74 eb                	je     80081d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800832:	0f b6 00             	movzbl (%eax),%eax
  800835:	0f b6 12             	movzbl (%edx),%edx
  800838:	29 d0                	sub    %edx,%eax
  80083a:	eb 05                	jmp    800841 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80083c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800841:	5b                   	pop    %ebx
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	8b 45 08             	mov    0x8(%ebp),%eax
  80084a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084e:	eb 07                	jmp    800857 <strchr+0x13>
		if (*s == c)
  800850:	38 ca                	cmp    %cl,%dl
  800852:	74 0f                	je     800863 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800854:	83 c0 01             	add    $0x1,%eax
  800857:	0f b6 10             	movzbl (%eax),%edx
  80085a:	84 d2                	test   %dl,%dl
  80085c:	75 f2                	jne    800850 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80085e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800863:	5d                   	pop    %ebp
  800864:	c3                   	ret    

00800865 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086f:	eb 03                	jmp    800874 <strfind+0xf>
  800871:	83 c0 01             	add    $0x1,%eax
  800874:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800877:	38 ca                	cmp    %cl,%dl
  800879:	74 04                	je     80087f <strfind+0x1a>
  80087b:	84 d2                	test   %dl,%dl
  80087d:	75 f2                	jne    800871 <strfind+0xc>
			break;
	return (char *) s;
}
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	57                   	push   %edi
  800885:	56                   	push   %esi
  800886:	53                   	push   %ebx
  800887:	8b 7d 08             	mov    0x8(%ebp),%edi
  80088a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80088d:	85 c9                	test   %ecx,%ecx
  80088f:	74 36                	je     8008c7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800891:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800897:	75 28                	jne    8008c1 <memset+0x40>
  800899:	f6 c1 03             	test   $0x3,%cl
  80089c:	75 23                	jne    8008c1 <memset+0x40>
		c &= 0xFF;
  80089e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008a2:	89 d3                	mov    %edx,%ebx
  8008a4:	c1 e3 08             	shl    $0x8,%ebx
  8008a7:	89 d6                	mov    %edx,%esi
  8008a9:	c1 e6 18             	shl    $0x18,%esi
  8008ac:	89 d0                	mov    %edx,%eax
  8008ae:	c1 e0 10             	shl    $0x10,%eax
  8008b1:	09 f0                	or     %esi,%eax
  8008b3:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008b5:	89 d8                	mov    %ebx,%eax
  8008b7:	09 d0                	or     %edx,%eax
  8008b9:	c1 e9 02             	shr    $0x2,%ecx
  8008bc:	fc                   	cld    
  8008bd:	f3 ab                	rep stos %eax,%es:(%edi)
  8008bf:	eb 06                	jmp    8008c7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c4:	fc                   	cld    
  8008c5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c7:	89 f8                	mov    %edi,%eax
  8008c9:	5b                   	pop    %ebx
  8008ca:	5e                   	pop    %esi
  8008cb:	5f                   	pop    %edi
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	57                   	push   %edi
  8008d2:	56                   	push   %esi
  8008d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008dc:	39 c6                	cmp    %eax,%esi
  8008de:	73 35                	jae    800915 <memmove+0x47>
  8008e0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e3:	39 d0                	cmp    %edx,%eax
  8008e5:	73 2e                	jae    800915 <memmove+0x47>
		s += n;
		d += n;
  8008e7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ea:	89 d6                	mov    %edx,%esi
  8008ec:	09 fe                	or     %edi,%esi
  8008ee:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f4:	75 13                	jne    800909 <memmove+0x3b>
  8008f6:	f6 c1 03             	test   $0x3,%cl
  8008f9:	75 0e                	jne    800909 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008fb:	83 ef 04             	sub    $0x4,%edi
  8008fe:	8d 72 fc             	lea    -0x4(%edx),%esi
  800901:	c1 e9 02             	shr    $0x2,%ecx
  800904:	fd                   	std    
  800905:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800907:	eb 09                	jmp    800912 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800909:	83 ef 01             	sub    $0x1,%edi
  80090c:	8d 72 ff             	lea    -0x1(%edx),%esi
  80090f:	fd                   	std    
  800910:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800912:	fc                   	cld    
  800913:	eb 1d                	jmp    800932 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800915:	89 f2                	mov    %esi,%edx
  800917:	09 c2                	or     %eax,%edx
  800919:	f6 c2 03             	test   $0x3,%dl
  80091c:	75 0f                	jne    80092d <memmove+0x5f>
  80091e:	f6 c1 03             	test   $0x3,%cl
  800921:	75 0a                	jne    80092d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800923:	c1 e9 02             	shr    $0x2,%ecx
  800926:	89 c7                	mov    %eax,%edi
  800928:	fc                   	cld    
  800929:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092b:	eb 05                	jmp    800932 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80092d:	89 c7                	mov    %eax,%edi
  80092f:	fc                   	cld    
  800930:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800932:	5e                   	pop    %esi
  800933:	5f                   	pop    %edi
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800939:	ff 75 10             	pushl  0x10(%ebp)
  80093c:	ff 75 0c             	pushl  0xc(%ebp)
  80093f:	ff 75 08             	pushl  0x8(%ebp)
  800942:	e8 87 ff ff ff       	call   8008ce <memmove>
}
  800947:	c9                   	leave  
  800948:	c3                   	ret    

00800949 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	56                   	push   %esi
  80094d:	53                   	push   %ebx
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	8b 55 0c             	mov    0xc(%ebp),%edx
  800954:	89 c6                	mov    %eax,%esi
  800956:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800959:	eb 1a                	jmp    800975 <memcmp+0x2c>
		if (*s1 != *s2)
  80095b:	0f b6 08             	movzbl (%eax),%ecx
  80095e:	0f b6 1a             	movzbl (%edx),%ebx
  800961:	38 d9                	cmp    %bl,%cl
  800963:	74 0a                	je     80096f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800965:	0f b6 c1             	movzbl %cl,%eax
  800968:	0f b6 db             	movzbl %bl,%ebx
  80096b:	29 d8                	sub    %ebx,%eax
  80096d:	eb 0f                	jmp    80097e <memcmp+0x35>
		s1++, s2++;
  80096f:	83 c0 01             	add    $0x1,%eax
  800972:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800975:	39 f0                	cmp    %esi,%eax
  800977:	75 e2                	jne    80095b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800979:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097e:	5b                   	pop    %ebx
  80097f:	5e                   	pop    %esi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	53                   	push   %ebx
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800989:	89 c1                	mov    %eax,%ecx
  80098b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80098e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800992:	eb 0a                	jmp    80099e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800994:	0f b6 10             	movzbl (%eax),%edx
  800997:	39 da                	cmp    %ebx,%edx
  800999:	74 07                	je     8009a2 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80099b:	83 c0 01             	add    $0x1,%eax
  80099e:	39 c8                	cmp    %ecx,%eax
  8009a0:	72 f2                	jb     800994 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009a2:	5b                   	pop    %ebx
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	57                   	push   %edi
  8009a9:	56                   	push   %esi
  8009aa:	53                   	push   %ebx
  8009ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b1:	eb 03                	jmp    8009b6 <strtol+0x11>
		s++;
  8009b3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b6:	0f b6 01             	movzbl (%ecx),%eax
  8009b9:	3c 20                	cmp    $0x20,%al
  8009bb:	74 f6                	je     8009b3 <strtol+0xe>
  8009bd:	3c 09                	cmp    $0x9,%al
  8009bf:	74 f2                	je     8009b3 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009c1:	3c 2b                	cmp    $0x2b,%al
  8009c3:	75 0a                	jne    8009cf <strtol+0x2a>
		s++;
  8009c5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c8:	bf 00 00 00 00       	mov    $0x0,%edi
  8009cd:	eb 11                	jmp    8009e0 <strtol+0x3b>
  8009cf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009d4:	3c 2d                	cmp    $0x2d,%al
  8009d6:	75 08                	jne    8009e0 <strtol+0x3b>
		s++, neg = 1;
  8009d8:	83 c1 01             	add    $0x1,%ecx
  8009db:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e6:	75 15                	jne    8009fd <strtol+0x58>
  8009e8:	80 39 30             	cmpb   $0x30,(%ecx)
  8009eb:	75 10                	jne    8009fd <strtol+0x58>
  8009ed:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009f1:	75 7c                	jne    800a6f <strtol+0xca>
		s += 2, base = 16;
  8009f3:	83 c1 02             	add    $0x2,%ecx
  8009f6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009fb:	eb 16                	jmp    800a13 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009fd:	85 db                	test   %ebx,%ebx
  8009ff:	75 12                	jne    800a13 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a01:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a06:	80 39 30             	cmpb   $0x30,(%ecx)
  800a09:	75 08                	jne    800a13 <strtol+0x6e>
		s++, base = 8;
  800a0b:	83 c1 01             	add    $0x1,%ecx
  800a0e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
  800a18:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a1b:	0f b6 11             	movzbl (%ecx),%edx
  800a1e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a21:	89 f3                	mov    %esi,%ebx
  800a23:	80 fb 09             	cmp    $0x9,%bl
  800a26:	77 08                	ja     800a30 <strtol+0x8b>
			dig = *s - '0';
  800a28:	0f be d2             	movsbl %dl,%edx
  800a2b:	83 ea 30             	sub    $0x30,%edx
  800a2e:	eb 22                	jmp    800a52 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a30:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a33:	89 f3                	mov    %esi,%ebx
  800a35:	80 fb 19             	cmp    $0x19,%bl
  800a38:	77 08                	ja     800a42 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a3a:	0f be d2             	movsbl %dl,%edx
  800a3d:	83 ea 57             	sub    $0x57,%edx
  800a40:	eb 10                	jmp    800a52 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a42:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a45:	89 f3                	mov    %esi,%ebx
  800a47:	80 fb 19             	cmp    $0x19,%bl
  800a4a:	77 16                	ja     800a62 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a4c:	0f be d2             	movsbl %dl,%edx
  800a4f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a52:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a55:	7d 0b                	jge    800a62 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a57:	83 c1 01             	add    $0x1,%ecx
  800a5a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a5e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a60:	eb b9                	jmp    800a1b <strtol+0x76>

	if (endptr)
  800a62:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a66:	74 0d                	je     800a75 <strtol+0xd0>
		*endptr = (char *) s;
  800a68:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6b:	89 0e                	mov    %ecx,(%esi)
  800a6d:	eb 06                	jmp    800a75 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a6f:	85 db                	test   %ebx,%ebx
  800a71:	74 98                	je     800a0b <strtol+0x66>
  800a73:	eb 9e                	jmp    800a13 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a75:	89 c2                	mov    %eax,%edx
  800a77:	f7 da                	neg    %edx
  800a79:	85 ff                	test   %edi,%edi
  800a7b:	0f 45 c2             	cmovne %edx,%eax
}
  800a7e:	5b                   	pop    %ebx
  800a7f:	5e                   	pop    %esi
  800a80:	5f                   	pop    %edi
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	57                   	push   %edi
  800a87:	56                   	push   %esi
  800a88:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a89:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a91:	8b 55 08             	mov    0x8(%ebp),%edx
  800a94:	89 c3                	mov    %eax,%ebx
  800a96:	89 c7                	mov    %eax,%edi
  800a98:	89 c6                	mov    %eax,%esi
  800a9a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <sys_cgetc>:

int
sys_cgetc(void)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	57                   	push   %edi
  800aa5:	56                   	push   %esi
  800aa6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa7:	ba 00 00 00 00       	mov    $0x0,%edx
  800aac:	b8 01 00 00 00       	mov    $0x1,%eax
  800ab1:	89 d1                	mov    %edx,%ecx
  800ab3:	89 d3                	mov    %edx,%ebx
  800ab5:	89 d7                	mov    %edx,%edi
  800ab7:	89 d6                	mov    %edx,%esi
  800ab9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800abb:	5b                   	pop    %ebx
  800abc:	5e                   	pop    %esi
  800abd:	5f                   	pop    %edi
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	57                   	push   %edi
  800ac4:	56                   	push   %esi
  800ac5:	53                   	push   %ebx
  800ac6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ace:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad6:	89 cb                	mov    %ecx,%ebx
  800ad8:	89 cf                	mov    %ecx,%edi
  800ada:	89 ce                	mov    %ecx,%esi
  800adc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ade:	85 c0                	test   %eax,%eax
  800ae0:	7e 17                	jle    800af9 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae2:	83 ec 0c             	sub    $0xc,%esp
  800ae5:	50                   	push   %eax
  800ae6:	6a 03                	push   $0x3
  800ae8:	68 e8 17 80 00       	push   $0x8017e8
  800aed:	6a 23                	push   $0x23
  800aef:	68 05 18 80 00       	push   $0x801805
  800af4:	e8 9b 06 00 00       	call   801194 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800af9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b07:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0c:	b8 02 00 00 00       	mov    $0x2,%eax
  800b11:	89 d1                	mov    %edx,%ecx
  800b13:	89 d3                	mov    %edx,%ebx
  800b15:	89 d7                	mov    %edx,%edi
  800b17:	89 d6                	mov    %edx,%esi
  800b19:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b1b:	5b                   	pop    %ebx
  800b1c:	5e                   	pop    %esi
  800b1d:	5f                   	pop    %edi
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <sys_yield>:

void
sys_yield(void)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	56                   	push   %esi
  800b25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b26:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b30:	89 d1                	mov    %edx,%ecx
  800b32:	89 d3                	mov    %edx,%ebx
  800b34:	89 d7                	mov    %edx,%edi
  800b36:	89 d6                	mov    %edx,%esi
  800b38:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	57                   	push   %edi
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
  800b45:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b48:	be 00 00 00 00       	mov    $0x0,%esi
  800b4d:	b8 04 00 00 00       	mov    $0x4,%eax
  800b52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b55:	8b 55 08             	mov    0x8(%ebp),%edx
  800b58:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b5b:	89 f7                	mov    %esi,%edi
  800b5d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b5f:	85 c0                	test   %eax,%eax
  800b61:	7e 17                	jle    800b7a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b63:	83 ec 0c             	sub    $0xc,%esp
  800b66:	50                   	push   %eax
  800b67:	6a 04                	push   $0x4
  800b69:	68 e8 17 80 00       	push   $0x8017e8
  800b6e:	6a 23                	push   $0x23
  800b70:	68 05 18 80 00       	push   $0x801805
  800b75:	e8 1a 06 00 00       	call   801194 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	57                   	push   %edi
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
  800b88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8b:	b8 05 00 00 00       	mov    $0x5,%eax
  800b90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b93:	8b 55 08             	mov    0x8(%ebp),%edx
  800b96:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b99:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b9c:	8b 75 18             	mov    0x18(%ebp),%esi
  800b9f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba1:	85 c0                	test   %eax,%eax
  800ba3:	7e 17                	jle    800bbc <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba5:	83 ec 0c             	sub    $0xc,%esp
  800ba8:	50                   	push   %eax
  800ba9:	6a 05                	push   $0x5
  800bab:	68 e8 17 80 00       	push   $0x8017e8
  800bb0:	6a 23                	push   $0x23
  800bb2:	68 05 18 80 00       	push   $0x801805
  800bb7:	e8 d8 05 00 00       	call   801194 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
  800bca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd2:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bda:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdd:	89 df                	mov    %ebx,%edi
  800bdf:	89 de                	mov    %ebx,%esi
  800be1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be3:	85 c0                	test   %eax,%eax
  800be5:	7e 17                	jle    800bfe <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be7:	83 ec 0c             	sub    $0xc,%esp
  800bea:	50                   	push   %eax
  800beb:	6a 06                	push   $0x6
  800bed:	68 e8 17 80 00       	push   $0x8017e8
  800bf2:	6a 23                	push   $0x23
  800bf4:	68 05 18 80 00       	push   $0x801805
  800bf9:	e8 96 05 00 00       	call   801194 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c01:	5b                   	pop    %ebx
  800c02:	5e                   	pop    %esi
  800c03:	5f                   	pop    %edi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
  800c0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c14:	b8 08 00 00 00       	mov    $0x8,%eax
  800c19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1f:	89 df                	mov    %ebx,%edi
  800c21:	89 de                	mov    %ebx,%esi
  800c23:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c25:	85 c0                	test   %eax,%eax
  800c27:	7e 17                	jle    800c40 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c29:	83 ec 0c             	sub    $0xc,%esp
  800c2c:	50                   	push   %eax
  800c2d:	6a 08                	push   $0x8
  800c2f:	68 e8 17 80 00       	push   $0x8017e8
  800c34:	6a 23                	push   $0x23
  800c36:	68 05 18 80 00       	push   $0x801805
  800c3b:	e8 54 05 00 00       	call   801194 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5f                   	pop    %edi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
  800c4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c56:	b8 09 00 00 00       	mov    $0x9,%eax
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c61:	89 df                	mov    %ebx,%edi
  800c63:	89 de                	mov    %ebx,%esi
  800c65:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c67:	85 c0                	test   %eax,%eax
  800c69:	7e 17                	jle    800c82 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6b:	83 ec 0c             	sub    $0xc,%esp
  800c6e:	50                   	push   %eax
  800c6f:	6a 09                	push   $0x9
  800c71:	68 e8 17 80 00       	push   $0x8017e8
  800c76:	6a 23                	push   $0x23
  800c78:	68 05 18 80 00       	push   $0x801805
  800c7d:	e8 12 05 00 00       	call   801194 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c90:	be 00 00 00 00       	mov    $0x0,%esi
  800c95:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
  800cb3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cbb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc3:	89 cb                	mov    %ecx,%ebx
  800cc5:	89 cf                	mov    %ecx,%edi
  800cc7:	89 ce                	mov    %ecx,%esi
  800cc9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	7e 17                	jle    800ce6 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccf:	83 ec 0c             	sub    $0xc,%esp
  800cd2:	50                   	push   %eax
  800cd3:	6a 0c                	push   $0xc
  800cd5:	68 e8 17 80 00       	push   $0x8017e8
  800cda:	6a 23                	push   $0x23
  800cdc:	68 05 18 80 00       	push   $0x801805
  800ce1:	e8 ae 04 00 00       	call   801194 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ce6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
  800cf4:	83 ec 0c             	sub    $0xc,%esp
  800cf7:	89 c7                	mov    %eax,%edi
  800cf9:	89 d3                	mov    %edx,%ebx
	int r;

	// LAB 4: Your code here.

    envid_t myenvid = sys_getenvid();
  800cfb:	e8 01 fe ff ff       	call   800b01 <sys_getenvid>
  800d00:	89 c6                	mov    %eax,%esi
    pte_t pte = uvpt[pn];
  800d02:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    int perm;

    perm = PTE_U | PTE_P;
    if(pte & PTE_W || pte & PTE_COW)
  800d09:	a9 02 08 00 00       	test   $0x802,%eax
  800d0e:	75 40                	jne    800d50 <duppage+0x62>
    {
        perm |= PTE_COW;
    }

    // map to envid VA
    if ((r = sys_page_map(myenvid,
  800d10:	c1 e3 0c             	shl    $0xc,%ebx
  800d13:	83 ec 0c             	sub    $0xc,%esp
  800d16:	6a 05                	push   $0x5
  800d18:	53                   	push   %ebx
  800d19:	57                   	push   %edi
  800d1a:	53                   	push   %ebx
  800d1b:	56                   	push   %esi
  800d1c:	e8 61 fe ff ff       	call   800b82 <sys_page_map>
  800d21:	83 c4 20             	add    $0x20,%esp
  800d24:	85 c0                	test   %eax,%eax
  800d26:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2b:	0f 4f c2             	cmovg  %edx,%eax
  800d2e:	eb 3b                	jmp    800d6b <duppage+0x7d>
    }

    // if COW remap to self
    if(perm & PTE_COW)
    {
        if((r = sys_page_map(myenvid, 
  800d30:	83 ec 0c             	sub    $0xc,%esp
  800d33:	68 05 08 00 00       	push   $0x805
  800d38:	53                   	push   %ebx
  800d39:	56                   	push   %esi
  800d3a:	53                   	push   %ebx
  800d3b:	56                   	push   %esi
  800d3c:	e8 41 fe ff ff       	call   800b82 <sys_page_map>
  800d41:	83 c4 20             	add    $0x20,%esp
  800d44:	85 c0                	test   %eax,%eax
  800d46:	ba 00 00 00 00       	mov    $0x0,%edx
  800d4b:	0f 4f c2             	cmovg  %edx,%eax
  800d4e:	eb 1b                	jmp    800d6b <duppage+0x7d>
    {
        perm |= PTE_COW;
    }

    // map to envid VA
    if ((r = sys_page_map(myenvid,
  800d50:	c1 e3 0c             	shl    $0xc,%ebx
  800d53:	83 ec 0c             	sub    $0xc,%esp
  800d56:	68 05 08 00 00       	push   $0x805
  800d5b:	53                   	push   %ebx
  800d5c:	57                   	push   %edi
  800d5d:	53                   	push   %ebx
  800d5e:	56                   	push   %esi
  800d5f:	e8 1e fe ff ff       	call   800b82 <sys_page_map>
  800d64:	83 c4 20             	add    $0x20,%esp
  800d67:	85 c0                	test   %eax,%eax
  800d69:	79 c5                	jns    800d30 <duppage+0x42>
            return r;
        }
    }

	return 0;
}
  800d6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
  800d78:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d7b:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

    if ((err & FEC_WR) == 0)
  800d7d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d81:	75 12                	jne    800d95 <pgfault+0x22>
    {
        panic("pgfault: page fault was not caused by write; %x.\n", utf->utf_fault_va);
  800d83:	53                   	push   %ebx
  800d84:	68 14 18 80 00       	push   $0x801814
  800d89:	6a 1f                	push   $0x1f
  800d8b:	68 eb 18 80 00       	push   $0x8018eb
  800d90:	e8 ff 03 00 00       	call   801194 <_panic>
    }

    if ((uvpt[PGNUM(addr)] & PTE_COW) == 0) 
  800d95:	89 d8                	mov    %ebx,%eax
  800d97:	c1 e8 0c             	shr    $0xc,%eax
  800d9a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800da1:	f6 c4 08             	test   $0x8,%ah
  800da4:	75 12                	jne    800db8 <pgfault+0x45>
    {
        panic("pgfault: page fault on page which is not COW %x.\n", utf->utf_fault_va);
  800da6:	53                   	push   %ebx
  800da7:	68 48 18 80 00       	push   $0x801848
  800dac:	6a 24                	push   $0x24
  800dae:	68 eb 18 80 00       	push   $0x8018eb
  800db3:	e8 dc 03 00 00       	call   801194 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    envid_t envid = sys_getenvid();
  800db8:	e8 44 fd ff ff       	call   800b01 <sys_getenvid>
  800dbd:	89 c6                	mov    %eax,%esi

    //allocate temp page
    if (sys_page_alloc(envid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  800dbf:	83 ec 04             	sub    $0x4,%esp
  800dc2:	6a 07                	push   $0x7
  800dc4:	68 00 f0 7f 00       	push   $0x7ff000
  800dc9:	50                   	push   %eax
  800dca:	e8 70 fd ff ff       	call   800b3f <sys_page_alloc>
  800dcf:	83 c4 10             	add    $0x10,%esp
  800dd2:	85 c0                	test   %eax,%eax
  800dd4:	79 14                	jns    800dea <pgfault+0x77>
    {
        panic("pgfault: can't allocate temp page.\n");
  800dd6:	83 ec 04             	sub    $0x4,%esp
  800dd9:	68 7c 18 80 00       	push   $0x80187c
  800dde:	6a 32                	push   $0x32
  800de0:	68 eb 18 80 00       	push   $0x8018eb
  800de5:	e8 aa 03 00 00       	call   801194 <_panic>
    }

    memmove(PFTEMP, (void *)ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800dea:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800df0:	83 ec 04             	sub    $0x4,%esp
  800df3:	68 00 10 00 00       	push   $0x1000
  800df8:	53                   	push   %ebx
  800df9:	68 00 f0 7f 00       	push   $0x7ff000
  800dfe:	e8 cb fa ff ff       	call   8008ce <memmove>

    if(sys_page_map(envid, PFTEMP, envid, (void *)ROUNDDOWN(addr, PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
  800e03:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e0a:	53                   	push   %ebx
  800e0b:	56                   	push   %esi
  800e0c:	68 00 f0 7f 00       	push   $0x7ff000
  800e11:	56                   	push   %esi
  800e12:	e8 6b fd ff ff       	call   800b82 <sys_page_map>
  800e17:	83 c4 20             	add    $0x20,%esp
  800e1a:	85 c0                	test   %eax,%eax
  800e1c:	79 14                	jns    800e32 <pgfault+0xbf>
    {
        panic("pgfault: can't map temp page to old page.\n");
  800e1e:	83 ec 04             	sub    $0x4,%esp
  800e21:	68 a0 18 80 00       	push   $0x8018a0
  800e26:	6a 39                	push   $0x39
  800e28:	68 eb 18 80 00       	push   $0x8018eb
  800e2d:	e8 62 03 00 00       	call   801194 <_panic>
    }

    if(sys_page_unmap(envid, PFTEMP) < 0)
  800e32:	83 ec 08             	sub    $0x8,%esp
  800e35:	68 00 f0 7f 00       	push   $0x7ff000
  800e3a:	56                   	push   %esi
  800e3b:	e8 84 fd ff ff       	call   800bc4 <sys_page_unmap>
  800e40:	83 c4 10             	add    $0x10,%esp
  800e43:	85 c0                	test   %eax,%eax
  800e45:	79 14                	jns    800e5b <pgfault+0xe8>
    {
        panic("pgfault: couldn't unmap page.\n");
  800e47:	83 ec 04             	sub    $0x4,%esp
  800e4a:	68 cc 18 80 00       	push   $0x8018cc
  800e4f:	6a 3e                	push   $0x3e
  800e51:	68 eb 18 80 00       	push   $0x8018eb
  800e56:	e8 39 03 00 00       	call   801194 <_panic>
    }
	//panic("pgfault not implemented");
}
  800e5b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e5e:	5b                   	pop    %ebx
  800e5f:	5e                   	pop    %esi
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    

00800e62 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	57                   	push   %edi
  800e66:	56                   	push   %esi
  800e67:	53                   	push   %ebx
  800e68:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    extern void _pgfault_upcall(void);
    envid_t myenvid = sys_getenvid();
  800e6b:	e8 91 fc ff ff       	call   800b01 <sys_getenvid>
  800e70:	89 45 e0             	mov    %eax,-0x20(%ebp)
    envid_t envid;
    uint32_t i, j, pn;

    //set page fault handler
    set_pgfault_handler(pgfault);
  800e73:	83 ec 0c             	sub    $0xc,%esp
  800e76:	68 73 0d 80 00       	push   $0x800d73
  800e7b:	e8 5a 03 00 00       	call   8011da <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e80:	b8 07 00 00 00       	mov    $0x7,%eax
  800e85:	cd 30                	int    $0x30
  800e87:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    //create a child
    if((envid = sys_exofork()) < 0)
  800e8d:	83 c4 10             	add    $0x10,%esp
  800e90:	85 c0                	test   %eax,%eax
  800e92:	0f 88 13 01 00 00    	js     800fab <fork+0x149>
  800e98:	bf 02 00 00 00       	mov    $0x2,%edi
    {
        return -1;
    }

    if(envid == 0)
  800e9d:	85 c0                	test   %eax,%eax
  800e9f:	75 21                	jne    800ec2 <fork+0x60>
    {
        thisenv = &envs[ENVX(sys_getenvid())];
  800ea1:	e8 5b fc ff ff       	call   800b01 <sys_getenvid>
  800ea6:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eab:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800eae:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800eb3:	a3 04 20 80 00       	mov    %eax,0x802004

        return envid;
  800eb8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebd:	e9 0a 01 00 00       	jmp    800fcc <fork+0x16a>
    }

    //copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
  800ec2:	8b 04 bd 00 d0 7b ef 	mov    -0x10843000(,%edi,4),%eax
  800ec9:	a8 01                	test   $0x1,%al
  800ecb:	74 3a                	je     800f07 <fork+0xa5>
        {
            for (j = 0; j < NPTENTRIES; j++)
            {
                pn = PGNUM(PGADDR(i, j, 0));
  800ecd:	89 fe                	mov    %edi,%esi
  800ecf:	c1 e6 16             	shl    $0x16,%esi
  800ed2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed7:	89 da                	mov    %ebx,%edx
  800ed9:	c1 e2 0c             	shl    $0xc,%edx
  800edc:	09 f2                	or     %esi,%edx
  800ede:	c1 ea 0c             	shr    $0xc,%edx
                if(pn == PGNUM(UXSTACKTOP - PGSIZE))
  800ee1:	81 fa ff eb 0e 00    	cmp    $0xeebff,%edx
  800ee7:	74 1e                	je     800f07 <fork+0xa5>
                {
                    break;
                }

                if(uvpt[pn] & PTE_P)
  800ee9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800ef0:	a8 01                	test   $0x1,%al
  800ef2:	74 08                	je     800efc <fork+0x9a>
                {
                    duppage(envid, pn);
  800ef4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ef7:	e8 f2 fd ff ff       	call   800cee <duppage>
    //copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
        {
            for (j = 0; j < NPTENTRIES; j++)
  800efc:	83 c3 01             	add    $0x1,%ebx
  800eff:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  800f05:	75 d0                	jne    800ed7 <fork+0x75>

        return envid;
    }

    //copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
  800f07:	83 c7 01             	add    $0x1,%edi
  800f0a:	81 ff bb 03 00 00    	cmp    $0x3bb,%edi
  800f10:	75 b0                	jne    800ec2 <fork+0x60>
                }
            }
        }
    }

    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
  800f12:	83 ec 04             	sub    $0x4,%esp
  800f15:	6a 07                	push   $0x7
  800f17:	68 00 f0 bf ee       	push   $0xeebff000
  800f1c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800f1f:	57                   	push   %edi
  800f20:	e8 1a fc ff ff       	call   800b3f <sys_page_alloc>
  800f25:	83 c4 10             	add    $0x10,%esp
  800f28:	85 c0                	test   %eax,%eax
  800f2a:	0f 88 82 00 00 00    	js     800fb2 <fork+0x150>
    {
        return -1;
    }

    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  800f30:	83 ec 0c             	sub    $0xc,%esp
  800f33:	6a 07                	push   $0x7
  800f35:	68 00 f0 7f 00       	push   $0x7ff000
  800f3a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800f3d:	56                   	push   %esi
  800f3e:	68 00 f0 bf ee       	push   $0xeebff000
  800f43:	57                   	push   %edi
  800f44:	e8 39 fc ff ff       	call   800b82 <sys_page_map>
  800f49:	83 c4 20             	add    $0x20,%esp
  800f4c:	85 c0                	test   %eax,%eax
  800f4e:	78 69                	js     800fb9 <fork+0x157>
    {
        return -1;
    }

    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);
  800f50:	83 ec 04             	sub    $0x4,%esp
  800f53:	68 00 10 00 00       	push   $0x1000
  800f58:	68 00 f0 7f 00       	push   $0x7ff000
  800f5d:	68 00 f0 bf ee       	push   $0xeebff000
  800f62:	e8 67 f9 ff ff       	call   8008ce <memmove>

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
  800f67:	83 c4 08             	add    $0x8,%esp
  800f6a:	68 00 f0 7f 00       	push   $0x7ff000
  800f6f:	56                   	push   %esi
  800f70:	e8 4f fc ff ff       	call   800bc4 <sys_page_unmap>
  800f75:	83 c4 10             	add    $0x10,%esp
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	78 44                	js     800fc0 <fork+0x15e>
    {
        return -1;
    }

    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
  800f7c:	83 ec 08             	sub    $0x8,%esp
  800f7f:	68 3f 12 80 00       	push   $0x80123f
  800f84:	57                   	push   %edi
  800f85:	e8 be fc ff ff       	call   800c48 <sys_env_set_pgfault_upcall>
  800f8a:	83 c4 10             	add    $0x10,%esp
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	78 36                	js     800fc7 <fork+0x165>
    {
        return -1;
    }

    if(sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  800f91:	83 ec 08             	sub    $0x8,%esp
  800f94:	6a 02                	push   $0x2
  800f96:	57                   	push   %edi
  800f97:	e8 6a fc ff ff       	call   800c06 <sys_env_set_status>
  800f9c:	83 c4 10             	add    $0x10,%esp
    {
        return -1;
    }

    return envid;
  800f9f:	85 c0                	test   %eax,%eax
  800fa1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800fa6:	0f 49 c7             	cmovns %edi,%eax
  800fa9:	eb 21                	jmp    800fcc <fork+0x16a>
    set_pgfault_handler(pgfault);

    //create a child
    if((envid = sys_exofork()) < 0)
    {
        return -1;
  800fab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800fb0:	eb 1a                	jmp    800fcc <fork+0x16a>
        }
    }

    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  800fb2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800fb7:	eb 13                	jmp    800fcc <fork+0x16a>
    }

    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  800fb9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800fbe:	eb 0c                	jmp    800fcc <fork+0x16a>

    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
    {
        return -1;
  800fc0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800fc5:	eb 05                	jmp    800fcc <fork+0x16a>
    }

    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
    {
        return -1;
  800fc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
        return -1;
    }

    return envid;
    //	panic("fork not implemented");
}
  800fcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fcf:	5b                   	pop    %ebx
  800fd0:	5e                   	pop    %esi
  800fd1:	5f                   	pop    %edi
  800fd2:	5d                   	pop    %ebp
  800fd3:	c3                   	ret    

00800fd4 <sfork>:

// Challenge!
int
sfork(void)
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
  800fd7:	57                   	push   %edi
  800fd8:	56                   	push   %esi
  800fd9:	53                   	push   %ebx
  800fda:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    extern void _pgfault_upcall(void);
    envid_t myenvid = sys_getenvid();
  800fdd:	e8 1f fb ff ff       	call   800b01 <sys_getenvid>
  800fe2:	89 45 e0             	mov    %eax,-0x20(%ebp)
    envid_t envid;
    uint32_t i, j, pn;
    int perm;

    // set page fault handler
    set_pgfault_handler(pgfault);
  800fe5:	83 ec 0c             	sub    $0xc,%esp
  800fe8:	68 73 0d 80 00       	push   $0x800d73
  800fed:	e8 e8 01 00 00       	call   8011da <set_pgfault_handler>
  800ff2:	b8 07 00 00 00       	mov    $0x7,%eax
  800ff7:	cd 30                	int    $0x30
  800ff9:	89 45 dc             	mov    %eax,-0x24(%ebp)

    // create a child
    if((envid = sys_exofork()) < 0)
  800ffc:	83 c4 10             	add    $0x10,%esp
  800fff:	85 c0                	test   %eax,%eax
  801001:	0f 88 5d 01 00 00    	js     801164 <sfork+0x190>
  801007:	89 c7                	mov    %eax,%edi
  801009:	c7 45 e4 02 00 00 00 	movl   $0x2,-0x1c(%ebp)
    {
        return -1;
    }

    if(envid == 0)
  801010:	85 c0                	test   %eax,%eax
  801012:	75 21                	jne    801035 <sfork+0x61>
    {
        thisenv = &envs[ENVX(sys_getenvid())];
  801014:	e8 e8 fa ff ff       	call   800b01 <sys_getenvid>
  801019:	25 ff 03 00 00       	and    $0x3ff,%eax
  80101e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801021:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801026:	a3 04 20 80 00       	mov    %eax,0x802004
        return envid;
  80102b:	b8 00 00 00 00       	mov    $0x0,%eax
  801030:	e9 57 01 00 00       	jmp    80118c <sfork+0x1b8>
    }

    // copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
  801035:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801038:	8b 04 b5 00 d0 7b ef 	mov    -0x10843000(,%esi,4),%eax
  80103f:	a8 01                	test   $0x1,%al
  801041:	74 76                	je     8010b9 <sfork+0xe5>
        {
            for (j = 0; j < NPTENTRIES; j++)
            {
                pn = PGNUM(PGADDR(i, j, 0));
  801043:	c1 e6 16             	shl    $0x16,%esi
  801046:	bb 00 00 00 00       	mov    $0x0,%ebx
  80104b:	89 d8                	mov    %ebx,%eax
  80104d:	c1 e0 0c             	shl    $0xc,%eax
  801050:	09 f0                	or     %esi,%eax
  801052:	89 c2                	mov    %eax,%edx
  801054:	c1 ea 0c             	shr    $0xc,%edx
                if(pn == PGNUM(UXSTACKTOP - PGSIZE))
  801057:	81 fa ff eb 0e 00    	cmp    $0xeebff,%edx
  80105d:	74 5a                	je     8010b9 <sfork+0xe5>
                {
                    break;
                }

                if(pn == PGNUM(USTACKTOP - PGSIZE))
  80105f:	81 fa fd eb 0e 00    	cmp    $0xeebfd,%edx
  801065:	75 09                	jne    801070 <sfork+0x9c>
                {
                     duppage(envid, pn); // cow for stack page
  801067:	89 f8                	mov    %edi,%eax
  801069:	e8 80 fc ff ff       	call   800cee <duppage>
                     continue;
  80106e:	eb 3e                	jmp    8010ae <sfork+0xda>
                }

                // map same page to child env with same perms
                if (uvpt[pn] & PTE_P)
  801070:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801077:	f6 c1 01             	test   $0x1,%cl
  80107a:	74 32                	je     8010ae <sfork+0xda>
                {
                    
                    perm = uvpt[pn] & ~(uvpt[pn] & ~(PTE_P |PTE_U | PTE_W | PTE_AVAIL));
  80107c:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801083:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
                    if (sys_page_map(myenvid, (void *)(PGADDR(i, j, 0)),
  80108a:	83 ec 0c             	sub    $0xc,%esp
  80108d:	81 e2 f8 f1 ff ff    	and    $0xfffff1f8,%edx
  801093:	f7 d2                	not    %edx
  801095:	21 d1                	and    %edx,%ecx
  801097:	51                   	push   %ecx
  801098:	50                   	push   %eax
  801099:	57                   	push   %edi
  80109a:	50                   	push   %eax
  80109b:	ff 75 e0             	pushl  -0x20(%ebp)
  80109e:	e8 df fa ff ff       	call   800b82 <sys_page_map>
  8010a3:	83 c4 20             	add    $0x20,%esp
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	0f 88 bd 00 00 00    	js     80116b <sfork+0x197>
    // copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
        {
            for (j = 0; j < NPTENTRIES; j++)
  8010ae:	83 c3 01             	add    $0x1,%ebx
  8010b1:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  8010b7:	75 92                	jne    80104b <sfork+0x77>
        thisenv = &envs[ENVX(sys_getenvid())];
        return envid;
    }

    // copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
  8010b9:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  8010bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010c0:	3d bb 03 00 00       	cmp    $0x3bb,%eax
  8010c5:	0f 85 6a ff ff ff    	jne    801035 <sfork+0x61>
            }
        }
    }

    // allocate new exception stack for child
    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
  8010cb:	83 ec 04             	sub    $0x4,%esp
  8010ce:	6a 07                	push   $0x7
  8010d0:	68 00 f0 bf ee       	push   $0xeebff000
  8010d5:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8010d8:	57                   	push   %edi
  8010d9:	e8 61 fa ff ff       	call   800b3f <sys_page_alloc>
  8010de:	83 c4 10             	add    $0x10,%esp
  8010e1:	85 c0                	test   %eax,%eax
  8010e3:	0f 88 89 00 00 00    	js     801172 <sfork+0x19e>
    {
        return -1;
    }

    // map child uxstack to temp page
    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  8010e9:	83 ec 0c             	sub    $0xc,%esp
  8010ec:	6a 07                	push   $0x7
  8010ee:	68 00 f0 7f 00       	push   $0x7ff000
  8010f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8010f6:	56                   	push   %esi
  8010f7:	68 00 f0 bf ee       	push   $0xeebff000
  8010fc:	57                   	push   %edi
  8010fd:	e8 80 fa ff ff       	call   800b82 <sys_page_map>
  801102:	83 c4 20             	add    $0x20,%esp
  801105:	85 c0                	test   %eax,%eax
  801107:	78 70                	js     801179 <sfork+0x1a5>
    {
        return -1;
    }

    // copy own uxstack to temp page
    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);
  801109:	83 ec 04             	sub    $0x4,%esp
  80110c:	68 00 10 00 00       	push   $0x1000
  801111:	68 00 f0 7f 00       	push   $0x7ff000
  801116:	68 00 f0 bf ee       	push   $0xeebff000
  80111b:	e8 ae f7 ff ff       	call   8008ce <memmove>

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
  801120:	83 c4 08             	add    $0x8,%esp
  801123:	68 00 f0 7f 00       	push   $0x7ff000
  801128:	56                   	push   %esi
  801129:	e8 96 fa ff ff       	call   800bc4 <sys_page_unmap>
  80112e:	83 c4 10             	add    $0x10,%esp
  801131:	85 c0                	test   %eax,%eax
  801133:	78 4b                	js     801180 <sfork+0x1ac>
    {
        return -1;
    }

    // set page fault handler in child
    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
  801135:	83 ec 08             	sub    $0x8,%esp
  801138:	68 3f 12 80 00       	push   $0x80123f
  80113d:	57                   	push   %edi
  80113e:	e8 05 fb ff ff       	call   800c48 <sys_env_set_pgfault_upcall>
  801143:	83 c4 10             	add    $0x10,%esp
  801146:	85 c0                	test   %eax,%eax
  801148:	78 3d                	js     801187 <sfork+0x1b3>
    {
        return -1;
    }

    // mark child env as RUNNABLE
    if(sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  80114a:	83 ec 08             	sub    $0x8,%esp
  80114d:	6a 02                	push   $0x2
  80114f:	57                   	push   %edi
  801150:	e8 b1 fa ff ff       	call   800c06 <sys_env_set_status>
  801155:	83 c4 10             	add    $0x10,%esp
    {
        return -1;
    }

    return envid;
  801158:	85 c0                	test   %eax,%eax
  80115a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80115f:	0f 49 c7             	cmovns %edi,%eax
  801162:	eb 28                	jmp    80118c <sfork+0x1b8>
    set_pgfault_handler(pgfault);

    // create a child
    if((envid = sys_exofork()) < 0)
    {
        return -1;
  801164:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801169:	eb 21                	jmp    80118c <sfork+0x1b8>
                    
                    perm = uvpt[pn] & ~(uvpt[pn] & ~(PTE_P |PTE_U | PTE_W | PTE_AVAIL));
                    if (sys_page_map(myenvid, (void *)(PGADDR(i, j, 0)),
                                     envid,   (void *)(PGADDR(i, j, 0)), perm) < 0)
                    {
                        return -1;
  80116b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801170:	eb 1a                	jmp    80118c <sfork+0x1b8>
    }

    // allocate new exception stack for child
    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  801172:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801177:	eb 13                	jmp    80118c <sfork+0x1b8>
    }

    // map child uxstack to temp page
    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  801179:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80117e:	eb 0c                	jmp    80118c <sfork+0x1b8>
    // copy own uxstack to temp page
    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
    {
        return -1;
  801180:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801185:	eb 05                	jmp    80118c <sfork+0x1b8>
    }

    // set page fault handler in child
    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
    {
        return -1;
  801187:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    {
        return -1;
    }

    return envid;
}
  80118c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118f:	5b                   	pop    %ebx
  801190:	5e                   	pop    %esi
  801191:	5f                   	pop    %edi
  801192:	5d                   	pop    %ebp
  801193:	c3                   	ret    

00801194 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	56                   	push   %esi
  801198:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801199:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80119c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8011a2:	e8 5a f9 ff ff       	call   800b01 <sys_getenvid>
  8011a7:	83 ec 0c             	sub    $0xc,%esp
  8011aa:	ff 75 0c             	pushl  0xc(%ebp)
  8011ad:	ff 75 08             	pushl  0x8(%ebp)
  8011b0:	56                   	push   %esi
  8011b1:	50                   	push   %eax
  8011b2:	68 f8 18 80 00       	push   $0x8018f8
  8011b7:	e8 e4 ef ff ff       	call   8001a0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011bc:	83 c4 18             	add    $0x18,%esp
  8011bf:	53                   	push   %ebx
  8011c0:	ff 75 10             	pushl  0x10(%ebp)
  8011c3:	e8 87 ef ff ff       	call   80014f <vcprintf>
	cprintf("\n");
  8011c8:	c7 04 24 94 15 80 00 	movl   $0x801594,(%esp)
  8011cf:	e8 cc ef ff ff       	call   8001a0 <cprintf>
  8011d4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011d7:	cc                   	int3   
  8011d8:	eb fd                	jmp    8011d7 <_panic+0x43>

008011da <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8011e0:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8011e7:	75 4c                	jne    801235 <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.

        void *va = (void *)(UXSTACKTOP - PGSIZE);
        if (sys_page_alloc(thisenv->env_id, va, PTE_P | PTE_U | PTE_W))
  8011e9:	a1 04 20 80 00       	mov    0x802004,%eax
  8011ee:	8b 40 48             	mov    0x48(%eax),%eax
  8011f1:	83 ec 04             	sub    $0x4,%esp
  8011f4:	6a 07                	push   $0x7
  8011f6:	68 00 f0 bf ee       	push   $0xeebff000
  8011fb:	50                   	push   %eax
  8011fc:	e8 3e f9 ff ff       	call   800b3f <sys_page_alloc>
  801201:	83 c4 10             	add    $0x10,%esp
  801204:	85 c0                	test   %eax,%eax
  801206:	74 14                	je     80121c <set_pgfault_handler+0x42>
        {
            panic("Unable to allocate memory for pgfault expected\n");
  801208:	83 ec 04             	sub    $0x4,%esp
  80120b:	68 1c 19 80 00       	push   $0x80191c
  801210:	6a 24                	push   $0x24
  801212:	68 4c 19 80 00       	push   $0x80194c
  801217:	e8 78 ff ff ff       	call   801194 <_panic>
        }

        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  80121c:	a1 04 20 80 00       	mov    0x802004,%eax
  801221:	8b 40 48             	mov    0x48(%eax),%eax
  801224:	83 ec 08             	sub    $0x8,%esp
  801227:	68 3f 12 80 00       	push   $0x80123f
  80122c:	50                   	push   %eax
  80122d:	e8 16 fa ff ff       	call   800c48 <sys_env_set_pgfault_upcall>
  801232:	83 c4 10             	add    $0x10,%esp

		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801235:	8b 45 08             	mov    0x8(%ebp),%eax
  801238:	a3 08 20 80 00       	mov    %eax,0x802008
}
  80123d:	c9                   	leave  
  80123e:	c3                   	ret    

0080123f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80123f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801240:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801245:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801247:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
    movl %esp, %ebx
  80124a:	89 e3                	mov    %esp,%ebx
    // 40 is the size between utf_fault_va ~ utf_regs
    movl 40(%esp), %eax
  80124c:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 48(%esp), %esp
  801250:	8b 64 24 30          	mov    0x30(%esp),%esp
    pushl %eax
  801254:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    movl %ebx, %esp
  801255:	89 dc                	mov    %ebx,%esp
    subl $4, 48(%esp)
  801257:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    popl %eax
  80125c:	58                   	pop    %eax
    popl %eax
  80125d:	58                   	pop    %eax
    popal
  80125e:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  80125f:	83 c4 04             	add    $0x4,%esp
    popfl
  801262:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp
  801263:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  801264:	c3                   	ret    
  801265:	66 90                	xchg   %ax,%ax
  801267:	66 90                	xchg   %ax,%ax
  801269:	66 90                	xchg   %ax,%ax
  80126b:	66 90                	xchg   %ax,%ax
  80126d:	66 90                	xchg   %ax,%ax
  80126f:	90                   	nop

00801270 <__udivdi3>:
  801270:	55                   	push   %ebp
  801271:	57                   	push   %edi
  801272:	56                   	push   %esi
  801273:	53                   	push   %ebx
  801274:	83 ec 1c             	sub    $0x1c,%esp
  801277:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80127b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80127f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801283:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801287:	85 f6                	test   %esi,%esi
  801289:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80128d:	89 ca                	mov    %ecx,%edx
  80128f:	89 f8                	mov    %edi,%eax
  801291:	75 3d                	jne    8012d0 <__udivdi3+0x60>
  801293:	39 cf                	cmp    %ecx,%edi
  801295:	0f 87 c5 00 00 00    	ja     801360 <__udivdi3+0xf0>
  80129b:	85 ff                	test   %edi,%edi
  80129d:	89 fd                	mov    %edi,%ebp
  80129f:	75 0b                	jne    8012ac <__udivdi3+0x3c>
  8012a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8012a6:	31 d2                	xor    %edx,%edx
  8012a8:	f7 f7                	div    %edi
  8012aa:	89 c5                	mov    %eax,%ebp
  8012ac:	89 c8                	mov    %ecx,%eax
  8012ae:	31 d2                	xor    %edx,%edx
  8012b0:	f7 f5                	div    %ebp
  8012b2:	89 c1                	mov    %eax,%ecx
  8012b4:	89 d8                	mov    %ebx,%eax
  8012b6:	89 cf                	mov    %ecx,%edi
  8012b8:	f7 f5                	div    %ebp
  8012ba:	89 c3                	mov    %eax,%ebx
  8012bc:	89 d8                	mov    %ebx,%eax
  8012be:	89 fa                	mov    %edi,%edx
  8012c0:	83 c4 1c             	add    $0x1c,%esp
  8012c3:	5b                   	pop    %ebx
  8012c4:	5e                   	pop    %esi
  8012c5:	5f                   	pop    %edi
  8012c6:	5d                   	pop    %ebp
  8012c7:	c3                   	ret    
  8012c8:	90                   	nop
  8012c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012d0:	39 ce                	cmp    %ecx,%esi
  8012d2:	77 74                	ja     801348 <__udivdi3+0xd8>
  8012d4:	0f bd fe             	bsr    %esi,%edi
  8012d7:	83 f7 1f             	xor    $0x1f,%edi
  8012da:	0f 84 98 00 00 00    	je     801378 <__udivdi3+0x108>
  8012e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8012e5:	89 f9                	mov    %edi,%ecx
  8012e7:	89 c5                	mov    %eax,%ebp
  8012e9:	29 fb                	sub    %edi,%ebx
  8012eb:	d3 e6                	shl    %cl,%esi
  8012ed:	89 d9                	mov    %ebx,%ecx
  8012ef:	d3 ed                	shr    %cl,%ebp
  8012f1:	89 f9                	mov    %edi,%ecx
  8012f3:	d3 e0                	shl    %cl,%eax
  8012f5:	09 ee                	or     %ebp,%esi
  8012f7:	89 d9                	mov    %ebx,%ecx
  8012f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012fd:	89 d5                	mov    %edx,%ebp
  8012ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  801303:	d3 ed                	shr    %cl,%ebp
  801305:	89 f9                	mov    %edi,%ecx
  801307:	d3 e2                	shl    %cl,%edx
  801309:	89 d9                	mov    %ebx,%ecx
  80130b:	d3 e8                	shr    %cl,%eax
  80130d:	09 c2                	or     %eax,%edx
  80130f:	89 d0                	mov    %edx,%eax
  801311:	89 ea                	mov    %ebp,%edx
  801313:	f7 f6                	div    %esi
  801315:	89 d5                	mov    %edx,%ebp
  801317:	89 c3                	mov    %eax,%ebx
  801319:	f7 64 24 0c          	mull   0xc(%esp)
  80131d:	39 d5                	cmp    %edx,%ebp
  80131f:	72 10                	jb     801331 <__udivdi3+0xc1>
  801321:	8b 74 24 08          	mov    0x8(%esp),%esi
  801325:	89 f9                	mov    %edi,%ecx
  801327:	d3 e6                	shl    %cl,%esi
  801329:	39 c6                	cmp    %eax,%esi
  80132b:	73 07                	jae    801334 <__udivdi3+0xc4>
  80132d:	39 d5                	cmp    %edx,%ebp
  80132f:	75 03                	jne    801334 <__udivdi3+0xc4>
  801331:	83 eb 01             	sub    $0x1,%ebx
  801334:	31 ff                	xor    %edi,%edi
  801336:	89 d8                	mov    %ebx,%eax
  801338:	89 fa                	mov    %edi,%edx
  80133a:	83 c4 1c             	add    $0x1c,%esp
  80133d:	5b                   	pop    %ebx
  80133e:	5e                   	pop    %esi
  80133f:	5f                   	pop    %edi
  801340:	5d                   	pop    %ebp
  801341:	c3                   	ret    
  801342:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801348:	31 ff                	xor    %edi,%edi
  80134a:	31 db                	xor    %ebx,%ebx
  80134c:	89 d8                	mov    %ebx,%eax
  80134e:	89 fa                	mov    %edi,%edx
  801350:	83 c4 1c             	add    $0x1c,%esp
  801353:	5b                   	pop    %ebx
  801354:	5e                   	pop    %esi
  801355:	5f                   	pop    %edi
  801356:	5d                   	pop    %ebp
  801357:	c3                   	ret    
  801358:	90                   	nop
  801359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801360:	89 d8                	mov    %ebx,%eax
  801362:	f7 f7                	div    %edi
  801364:	31 ff                	xor    %edi,%edi
  801366:	89 c3                	mov    %eax,%ebx
  801368:	89 d8                	mov    %ebx,%eax
  80136a:	89 fa                	mov    %edi,%edx
  80136c:	83 c4 1c             	add    $0x1c,%esp
  80136f:	5b                   	pop    %ebx
  801370:	5e                   	pop    %esi
  801371:	5f                   	pop    %edi
  801372:	5d                   	pop    %ebp
  801373:	c3                   	ret    
  801374:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801378:	39 ce                	cmp    %ecx,%esi
  80137a:	72 0c                	jb     801388 <__udivdi3+0x118>
  80137c:	31 db                	xor    %ebx,%ebx
  80137e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801382:	0f 87 34 ff ff ff    	ja     8012bc <__udivdi3+0x4c>
  801388:	bb 01 00 00 00       	mov    $0x1,%ebx
  80138d:	e9 2a ff ff ff       	jmp    8012bc <__udivdi3+0x4c>
  801392:	66 90                	xchg   %ax,%ax
  801394:	66 90                	xchg   %ax,%ax
  801396:	66 90                	xchg   %ax,%ax
  801398:	66 90                	xchg   %ax,%ax
  80139a:	66 90                	xchg   %ax,%ax
  80139c:	66 90                	xchg   %ax,%ax
  80139e:	66 90                	xchg   %ax,%ax

008013a0 <__umoddi3>:
  8013a0:	55                   	push   %ebp
  8013a1:	57                   	push   %edi
  8013a2:	56                   	push   %esi
  8013a3:	53                   	push   %ebx
  8013a4:	83 ec 1c             	sub    $0x1c,%esp
  8013a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8013ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8013af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8013b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8013b7:	85 d2                	test   %edx,%edx
  8013b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8013bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013c1:	89 f3                	mov    %esi,%ebx
  8013c3:	89 3c 24             	mov    %edi,(%esp)
  8013c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013ca:	75 1c                	jne    8013e8 <__umoddi3+0x48>
  8013cc:	39 f7                	cmp    %esi,%edi
  8013ce:	76 50                	jbe    801420 <__umoddi3+0x80>
  8013d0:	89 c8                	mov    %ecx,%eax
  8013d2:	89 f2                	mov    %esi,%edx
  8013d4:	f7 f7                	div    %edi
  8013d6:	89 d0                	mov    %edx,%eax
  8013d8:	31 d2                	xor    %edx,%edx
  8013da:	83 c4 1c             	add    $0x1c,%esp
  8013dd:	5b                   	pop    %ebx
  8013de:	5e                   	pop    %esi
  8013df:	5f                   	pop    %edi
  8013e0:	5d                   	pop    %ebp
  8013e1:	c3                   	ret    
  8013e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013e8:	39 f2                	cmp    %esi,%edx
  8013ea:	89 d0                	mov    %edx,%eax
  8013ec:	77 52                	ja     801440 <__umoddi3+0xa0>
  8013ee:	0f bd ea             	bsr    %edx,%ebp
  8013f1:	83 f5 1f             	xor    $0x1f,%ebp
  8013f4:	75 5a                	jne    801450 <__umoddi3+0xb0>
  8013f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8013fa:	0f 82 e0 00 00 00    	jb     8014e0 <__umoddi3+0x140>
  801400:	39 0c 24             	cmp    %ecx,(%esp)
  801403:	0f 86 d7 00 00 00    	jbe    8014e0 <__umoddi3+0x140>
  801409:	8b 44 24 08          	mov    0x8(%esp),%eax
  80140d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801411:	83 c4 1c             	add    $0x1c,%esp
  801414:	5b                   	pop    %ebx
  801415:	5e                   	pop    %esi
  801416:	5f                   	pop    %edi
  801417:	5d                   	pop    %ebp
  801418:	c3                   	ret    
  801419:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801420:	85 ff                	test   %edi,%edi
  801422:	89 fd                	mov    %edi,%ebp
  801424:	75 0b                	jne    801431 <__umoddi3+0x91>
  801426:	b8 01 00 00 00       	mov    $0x1,%eax
  80142b:	31 d2                	xor    %edx,%edx
  80142d:	f7 f7                	div    %edi
  80142f:	89 c5                	mov    %eax,%ebp
  801431:	89 f0                	mov    %esi,%eax
  801433:	31 d2                	xor    %edx,%edx
  801435:	f7 f5                	div    %ebp
  801437:	89 c8                	mov    %ecx,%eax
  801439:	f7 f5                	div    %ebp
  80143b:	89 d0                	mov    %edx,%eax
  80143d:	eb 99                	jmp    8013d8 <__umoddi3+0x38>
  80143f:	90                   	nop
  801440:	89 c8                	mov    %ecx,%eax
  801442:	89 f2                	mov    %esi,%edx
  801444:	83 c4 1c             	add    $0x1c,%esp
  801447:	5b                   	pop    %ebx
  801448:	5e                   	pop    %esi
  801449:	5f                   	pop    %edi
  80144a:	5d                   	pop    %ebp
  80144b:	c3                   	ret    
  80144c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801450:	8b 34 24             	mov    (%esp),%esi
  801453:	bf 20 00 00 00       	mov    $0x20,%edi
  801458:	89 e9                	mov    %ebp,%ecx
  80145a:	29 ef                	sub    %ebp,%edi
  80145c:	d3 e0                	shl    %cl,%eax
  80145e:	89 f9                	mov    %edi,%ecx
  801460:	89 f2                	mov    %esi,%edx
  801462:	d3 ea                	shr    %cl,%edx
  801464:	89 e9                	mov    %ebp,%ecx
  801466:	09 c2                	or     %eax,%edx
  801468:	89 d8                	mov    %ebx,%eax
  80146a:	89 14 24             	mov    %edx,(%esp)
  80146d:	89 f2                	mov    %esi,%edx
  80146f:	d3 e2                	shl    %cl,%edx
  801471:	89 f9                	mov    %edi,%ecx
  801473:	89 54 24 04          	mov    %edx,0x4(%esp)
  801477:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80147b:	d3 e8                	shr    %cl,%eax
  80147d:	89 e9                	mov    %ebp,%ecx
  80147f:	89 c6                	mov    %eax,%esi
  801481:	d3 e3                	shl    %cl,%ebx
  801483:	89 f9                	mov    %edi,%ecx
  801485:	89 d0                	mov    %edx,%eax
  801487:	d3 e8                	shr    %cl,%eax
  801489:	89 e9                	mov    %ebp,%ecx
  80148b:	09 d8                	or     %ebx,%eax
  80148d:	89 d3                	mov    %edx,%ebx
  80148f:	89 f2                	mov    %esi,%edx
  801491:	f7 34 24             	divl   (%esp)
  801494:	89 d6                	mov    %edx,%esi
  801496:	d3 e3                	shl    %cl,%ebx
  801498:	f7 64 24 04          	mull   0x4(%esp)
  80149c:	39 d6                	cmp    %edx,%esi
  80149e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014a2:	89 d1                	mov    %edx,%ecx
  8014a4:	89 c3                	mov    %eax,%ebx
  8014a6:	72 08                	jb     8014b0 <__umoddi3+0x110>
  8014a8:	75 11                	jne    8014bb <__umoddi3+0x11b>
  8014aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8014ae:	73 0b                	jae    8014bb <__umoddi3+0x11b>
  8014b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8014b4:	1b 14 24             	sbb    (%esp),%edx
  8014b7:	89 d1                	mov    %edx,%ecx
  8014b9:	89 c3                	mov    %eax,%ebx
  8014bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8014bf:	29 da                	sub    %ebx,%edx
  8014c1:	19 ce                	sbb    %ecx,%esi
  8014c3:	89 f9                	mov    %edi,%ecx
  8014c5:	89 f0                	mov    %esi,%eax
  8014c7:	d3 e0                	shl    %cl,%eax
  8014c9:	89 e9                	mov    %ebp,%ecx
  8014cb:	d3 ea                	shr    %cl,%edx
  8014cd:	89 e9                	mov    %ebp,%ecx
  8014cf:	d3 ee                	shr    %cl,%esi
  8014d1:	09 d0                	or     %edx,%eax
  8014d3:	89 f2                	mov    %esi,%edx
  8014d5:	83 c4 1c             	add    $0x1c,%esp
  8014d8:	5b                   	pop    %ebx
  8014d9:	5e                   	pop    %esi
  8014da:	5f                   	pop    %edi
  8014db:	5d                   	pop    %ebp
  8014dc:	c3                   	ret    
  8014dd:	8d 76 00             	lea    0x0(%esi),%esi
  8014e0:	29 f9                	sub    %edi,%ecx
  8014e2:	19 d6                	sbb    %edx,%esi
  8014e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014ec:	e9 18 ff ff ff       	jmp    801409 <__umoddi3+0x69>
