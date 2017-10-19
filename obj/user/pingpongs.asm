
obj/user/pingpongs：     文件格式 elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 dc 0f 00 00       	call   80101d <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80004e:	e8 f7 0a 00 00       	call   800b4a <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 60 16 80 00       	push   $0x801660
  80005d:	e8 87 01 00 00       	call   8001e9 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 e0 0a 00 00       	call   800b4a <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 7a 16 80 00       	push   $0x80167a
  800074:	e8 70 01 00 00       	call   8001e9 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 cb 11 00 00       	call   801252 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 43 11 00 00       	call   8011dd <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 04 20 80 00       	mov    0x802004,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 97 0a 00 00       	call   800b4a <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 90 16 80 00       	push   $0x801690
  8000c2:	e8 22 01 00 00       	call   8001e9 <cprintf>
        if(val == 10)
  8000c7:	a1 04 20 80 00       	mov    0x802004,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
          return ;
        ++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 68 11 00 00       	call   801252 <ipc_send>
        if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  8000f4:	75 94                	jne    80008a <umain+0x57>
            return ;
		//++val;
	}

}
  8000f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800106:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800109:	e8 3c 0a 00 00       	call   800b4a <sys_getenvid>
  80010e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800113:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800116:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011b:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800120:	85 db                	test   %ebx,%ebx
  800122:	7e 07                	jle    80012b <libmain+0x2d>
		binaryname = argv[0];
  800124:	8b 06                	mov    (%esi),%eax
  800126:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012b:	83 ec 08             	sub    $0x8,%esp
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
  800130:	e8 fe fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800135:	e8 0a 00 00 00       	call   800144 <exit>
}
  80013a:	83 c4 10             	add    $0x10,%esp
  80013d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800140:	5b                   	pop    %ebx
  800141:	5e                   	pop    %esi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80014a:	6a 00                	push   $0x0
  80014c:	e8 b8 09 00 00       	call   800b09 <sys_env_destroy>
}
  800151:	83 c4 10             	add    $0x10,%esp
  800154:	c9                   	leave  
  800155:	c3                   	ret    

00800156 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	53                   	push   %ebx
  80015a:	83 ec 04             	sub    $0x4,%esp
  80015d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800160:	8b 13                	mov    (%ebx),%edx
  800162:	8d 42 01             	lea    0x1(%edx),%eax
  800165:	89 03                	mov    %eax,(%ebx)
  800167:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80016e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800173:	75 1a                	jne    80018f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800175:	83 ec 08             	sub    $0x8,%esp
  800178:	68 ff 00 00 00       	push   $0xff
  80017d:	8d 43 08             	lea    0x8(%ebx),%eax
  800180:	50                   	push   %eax
  800181:	e8 46 09 00 00       	call   800acc <sys_cputs>
		b->idx = 0;
  800186:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80018c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80018f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800193:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800196:	c9                   	leave  
  800197:	c3                   	ret    

00800198 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001a8:	00 00 00 
	b.cnt = 0;
  8001ab:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b5:	ff 75 0c             	pushl  0xc(%ebp)
  8001b8:	ff 75 08             	pushl  0x8(%ebp)
  8001bb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c1:	50                   	push   %eax
  8001c2:	68 56 01 80 00       	push   $0x800156
  8001c7:	e8 54 01 00 00       	call   800320 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001cc:	83 c4 08             	add    $0x8,%esp
  8001cf:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001d5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001db:	50                   	push   %eax
  8001dc:	e8 eb 08 00 00       	call   800acc <sys_cputs>

	return b.cnt;
}
  8001e1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001e7:	c9                   	leave  
  8001e8:	c3                   	ret    

008001e9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ef:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f2:	50                   	push   %eax
  8001f3:	ff 75 08             	pushl  0x8(%ebp)
  8001f6:	e8 9d ff ff ff       	call   800198 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001fb:	c9                   	leave  
  8001fc:	c3                   	ret    

008001fd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001fd:	55                   	push   %ebp
  8001fe:	89 e5                	mov    %esp,%ebp
  800200:	57                   	push   %edi
  800201:	56                   	push   %esi
  800202:	53                   	push   %ebx
  800203:	83 ec 1c             	sub    $0x1c,%esp
  800206:	89 c7                	mov    %eax,%edi
  800208:	89 d6                	mov    %edx,%esi
  80020a:	8b 45 08             	mov    0x8(%ebp),%eax
  80020d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800210:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800213:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800216:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800219:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800221:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800224:	39 d3                	cmp    %edx,%ebx
  800226:	72 05                	jb     80022d <printnum+0x30>
  800228:	39 45 10             	cmp    %eax,0x10(%ebp)
  80022b:	77 45                	ja     800272 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80022d:	83 ec 0c             	sub    $0xc,%esp
  800230:	ff 75 18             	pushl  0x18(%ebp)
  800233:	8b 45 14             	mov    0x14(%ebp),%eax
  800236:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800239:	53                   	push   %ebx
  80023a:	ff 75 10             	pushl  0x10(%ebp)
  80023d:	83 ec 08             	sub    $0x8,%esp
  800240:	ff 75 e4             	pushl  -0x1c(%ebp)
  800243:	ff 75 e0             	pushl  -0x20(%ebp)
  800246:	ff 75 dc             	pushl  -0x24(%ebp)
  800249:	ff 75 d8             	pushl  -0x28(%ebp)
  80024c:	e8 6f 11 00 00       	call   8013c0 <__udivdi3>
  800251:	83 c4 18             	add    $0x18,%esp
  800254:	52                   	push   %edx
  800255:	50                   	push   %eax
  800256:	89 f2                	mov    %esi,%edx
  800258:	89 f8                	mov    %edi,%eax
  80025a:	e8 9e ff ff ff       	call   8001fd <printnum>
  80025f:	83 c4 20             	add    $0x20,%esp
  800262:	eb 18                	jmp    80027c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800264:	83 ec 08             	sub    $0x8,%esp
  800267:	56                   	push   %esi
  800268:	ff 75 18             	pushl  0x18(%ebp)
  80026b:	ff d7                	call   *%edi
  80026d:	83 c4 10             	add    $0x10,%esp
  800270:	eb 03                	jmp    800275 <printnum+0x78>
  800272:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800275:	83 eb 01             	sub    $0x1,%ebx
  800278:	85 db                	test   %ebx,%ebx
  80027a:	7f e8                	jg     800264 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027c:	83 ec 08             	sub    $0x8,%esp
  80027f:	56                   	push   %esi
  800280:	83 ec 04             	sub    $0x4,%esp
  800283:	ff 75 e4             	pushl  -0x1c(%ebp)
  800286:	ff 75 e0             	pushl  -0x20(%ebp)
  800289:	ff 75 dc             	pushl  -0x24(%ebp)
  80028c:	ff 75 d8             	pushl  -0x28(%ebp)
  80028f:	e8 5c 12 00 00       	call   8014f0 <__umoddi3>
  800294:	83 c4 14             	add    $0x14,%esp
  800297:	0f be 80 c0 16 80 00 	movsbl 0x8016c0(%eax),%eax
  80029e:	50                   	push   %eax
  80029f:	ff d7                	call   *%edi
}
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a7:	5b                   	pop    %ebx
  8002a8:	5e                   	pop    %esi
  8002a9:	5f                   	pop    %edi
  8002aa:	5d                   	pop    %ebp
  8002ab:	c3                   	ret    

008002ac <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002af:	83 fa 01             	cmp    $0x1,%edx
  8002b2:	7e 0e                	jle    8002c2 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b4:	8b 10                	mov    (%eax),%edx
  8002b6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b9:	89 08                	mov    %ecx,(%eax)
  8002bb:	8b 02                	mov    (%edx),%eax
  8002bd:	8b 52 04             	mov    0x4(%edx),%edx
  8002c0:	eb 22                	jmp    8002e4 <getuint+0x38>
	else if (lflag)
  8002c2:	85 d2                	test   %edx,%edx
  8002c4:	74 10                	je     8002d6 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c6:	8b 10                	mov    (%eax),%edx
  8002c8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002cb:	89 08                	mov    %ecx,(%eax)
  8002cd:	8b 02                	mov    (%edx),%eax
  8002cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d4:	eb 0e                	jmp    8002e4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d6:	8b 10                	mov    (%eax),%edx
  8002d8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002db:	89 08                	mov    %ecx,(%eax)
  8002dd:	8b 02                	mov    (%edx),%eax
  8002df:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ec:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f5:	73 0a                	jae    800301 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fa:	89 08                	mov    %ecx,(%eax)
  8002fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ff:	88 02                	mov    %al,(%edx)
}
  800301:	5d                   	pop    %ebp
  800302:	c3                   	ret    

00800303 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
  800306:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800309:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030c:	50                   	push   %eax
  80030d:	ff 75 10             	pushl  0x10(%ebp)
  800310:	ff 75 0c             	pushl  0xc(%ebp)
  800313:	ff 75 08             	pushl  0x8(%ebp)
  800316:	e8 05 00 00 00       	call   800320 <vprintfmt>
	va_end(ap);
}
  80031b:	83 c4 10             	add    $0x10,%esp
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 2c             	sub    $0x2c,%esp
  800329:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
  80032c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800333:	eb 17                	jmp    80034c <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800335:	85 c0                	test   %eax,%eax
  800337:	0f 84 9f 03 00 00    	je     8006dc <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
  80033d:	83 ec 08             	sub    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	50                   	push   %eax
  800344:	ff 55 08             	call   *0x8(%ebp)
  800347:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034a:	89 f3                	mov    %esi,%ebx
  80034c:	8d 73 01             	lea    0x1(%ebx),%esi
  80034f:	0f b6 03             	movzbl (%ebx),%eax
  800352:	83 f8 25             	cmp    $0x25,%eax
  800355:	75 de                	jne    800335 <vprintfmt+0x15>
  800357:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80035b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800362:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800367:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80036e:	ba 00 00 00 00       	mov    $0x0,%edx
  800373:	eb 06                	jmp    80037b <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800375:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800377:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80037e:	0f b6 06             	movzbl (%esi),%eax
  800381:	0f b6 c8             	movzbl %al,%ecx
  800384:	83 e8 23             	sub    $0x23,%eax
  800387:	3c 55                	cmp    $0x55,%al
  800389:	0f 87 2d 03 00 00    	ja     8006bc <vprintfmt+0x39c>
  80038f:	0f b6 c0             	movzbl %al,%eax
  800392:	ff 24 85 80 17 80 00 	jmp    *0x801780(,%eax,4)
  800399:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80039b:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80039f:	eb da                	jmp    80037b <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	89 de                	mov    %ebx,%esi
  8003a3:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a8:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  8003ab:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  8003af:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  8003b2:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8003b5:	83 f8 09             	cmp    $0x9,%eax
  8003b8:	77 33                	ja     8003ed <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ba:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003bd:	eb e9                	jmp    8003a8 <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c2:	8d 48 04             	lea    0x4(%eax),%ecx
  8003c5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003c8:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003cc:	eb 1f                	jmp    8003ed <vprintfmt+0xcd>
  8003ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d1:	85 c0                	test   %eax,%eax
  8003d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d8:	0f 49 c8             	cmovns %eax,%ecx
  8003db:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	89 de                	mov    %ebx,%esi
  8003e0:	eb 99                	jmp    80037b <vprintfmt+0x5b>
  8003e2:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003e4:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  8003eb:	eb 8e                	jmp    80037b <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8003ed:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f1:	79 88                	jns    80037b <vprintfmt+0x5b>
				width = precision, precision = -1;
  8003f3:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8003f6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003fb:	e9 7b ff ff ff       	jmp    80037b <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800400:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800403:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800405:	e9 71 ff ff ff       	jmp    80037b <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
  80040a:	8b 45 14             	mov    0x14(%ebp),%eax
  80040d:	8d 50 04             	lea    0x4(%eax),%edx
  800410:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  800413:	83 ec 08             	sub    $0x8,%esp
  800416:	ff 75 0c             	pushl  0xc(%ebp)
  800419:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80041c:	03 08                	add    (%eax),%ecx
  80041e:	51                   	push   %ecx
  80041f:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
  800422:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
  800425:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
  80042c:	e9 1b ff ff ff       	jmp    80034c <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
  800431:	8b 45 14             	mov    0x14(%ebp),%eax
  800434:	8d 48 04             	lea    0x4(%eax),%ecx
  800437:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80043a:	8b 00                	mov    (%eax),%eax
  80043c:	83 f8 02             	cmp    $0x2,%eax
  80043f:	74 1a                	je     80045b <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800441:	89 de                	mov    %ebx,%esi
  800443:	83 f8 04             	cmp    $0x4,%eax
  800446:	b8 00 00 00 00       	mov    $0x0,%eax
  80044b:	b9 00 04 00 00       	mov    $0x400,%ecx
  800450:	0f 44 c1             	cmove  %ecx,%eax
  800453:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800456:	e9 20 ff ff ff       	jmp    80037b <vprintfmt+0x5b>
  80045b:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
  80045d:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
  800464:	e9 12 ff ff ff       	jmp    80037b <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800469:	8b 45 14             	mov    0x14(%ebp),%eax
  80046c:	8d 50 04             	lea    0x4(%eax),%edx
  80046f:	89 55 14             	mov    %edx,0x14(%ebp)
  800472:	8b 00                	mov    (%eax),%eax
  800474:	99                   	cltd   
  800475:	31 d0                	xor    %edx,%eax
  800477:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800479:	83 f8 09             	cmp    $0x9,%eax
  80047c:	7f 0b                	jg     800489 <vprintfmt+0x169>
  80047e:	8b 14 85 e0 18 80 00 	mov    0x8018e0(,%eax,4),%edx
  800485:	85 d2                	test   %edx,%edx
  800487:	75 19                	jne    8004a2 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800489:	50                   	push   %eax
  80048a:	68 d8 16 80 00       	push   $0x8016d8
  80048f:	ff 75 0c             	pushl  0xc(%ebp)
  800492:	ff 75 08             	pushl  0x8(%ebp)
  800495:	e8 69 fe ff ff       	call   800303 <printfmt>
  80049a:	83 c4 10             	add    $0x10,%esp
  80049d:	e9 aa fe ff ff       	jmp    80034c <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  8004a2:	52                   	push   %edx
  8004a3:	68 e1 16 80 00       	push   $0x8016e1
  8004a8:	ff 75 0c             	pushl  0xc(%ebp)
  8004ab:	ff 75 08             	pushl  0x8(%ebp)
  8004ae:	e8 50 fe ff ff       	call   800303 <printfmt>
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	e9 91 fe ff ff       	jmp    80034c <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004be:	8d 50 04             	lea    0x4(%eax),%edx
  8004c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c4:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004c6:	85 f6                	test   %esi,%esi
  8004c8:	b8 d1 16 80 00       	mov    $0x8016d1,%eax
  8004cd:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8004d0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d4:	0f 8e 93 00 00 00    	jle    80056d <vprintfmt+0x24d>
  8004da:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004de:	0f 84 91 00 00 00    	je     800575 <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e4:	83 ec 08             	sub    $0x8,%esp
  8004e7:	57                   	push   %edi
  8004e8:	56                   	push   %esi
  8004e9:	e8 76 02 00 00       	call   800764 <strnlen>
  8004ee:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f1:	29 c1                	sub    %eax,%ecx
  8004f3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004f6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004f9:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8004fd:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800500:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800503:	8b 75 0c             	mov    0xc(%ebp),%esi
  800506:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800509:	89 cb                	mov    %ecx,%ebx
  80050b:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050d:	eb 0e                	jmp    80051d <vprintfmt+0x1fd>
					putch(padc, putdat);
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	56                   	push   %esi
  800513:	57                   	push   %edi
  800514:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800517:	83 eb 01             	sub    $0x1,%ebx
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	85 db                	test   %ebx,%ebx
  80051f:	7f ee                	jg     80050f <vprintfmt+0x1ef>
  800521:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800524:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800527:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80052a:	85 c9                	test   %ecx,%ecx
  80052c:	b8 00 00 00 00       	mov    $0x0,%eax
  800531:	0f 49 c1             	cmovns %ecx,%eax
  800534:	29 c1                	sub    %eax,%ecx
  800536:	89 cb                	mov    %ecx,%ebx
  800538:	eb 41                	jmp    80057b <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80053a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80053e:	74 1b                	je     80055b <vprintfmt+0x23b>
  800540:	0f be c0             	movsbl %al,%eax
  800543:	83 e8 20             	sub    $0x20,%eax
  800546:	83 f8 5e             	cmp    $0x5e,%eax
  800549:	76 10                	jbe    80055b <vprintfmt+0x23b>
					putch('?', putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	ff 75 0c             	pushl  0xc(%ebp)
  800551:	6a 3f                	push   $0x3f
  800553:	ff 55 08             	call   *0x8(%ebp)
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	eb 0d                	jmp    800568 <vprintfmt+0x248>
				else
					putch(ch, putdat);
  80055b:	83 ec 08             	sub    $0x8,%esp
  80055e:	ff 75 0c             	pushl  0xc(%ebp)
  800561:	52                   	push   %edx
  800562:	ff 55 08             	call   *0x8(%ebp)
  800565:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800568:	83 eb 01             	sub    $0x1,%ebx
  80056b:	eb 0e                	jmp    80057b <vprintfmt+0x25b>
  80056d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800570:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800573:	eb 06                	jmp    80057b <vprintfmt+0x25b>
  800575:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800578:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057b:	83 c6 01             	add    $0x1,%esi
  80057e:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800582:	0f be d0             	movsbl %al,%edx
  800585:	85 d2                	test   %edx,%edx
  800587:	74 25                	je     8005ae <vprintfmt+0x28e>
  800589:	85 ff                	test   %edi,%edi
  80058b:	78 ad                	js     80053a <vprintfmt+0x21a>
  80058d:	83 ef 01             	sub    $0x1,%edi
  800590:	79 a8                	jns    80053a <vprintfmt+0x21a>
  800592:	89 d8                	mov    %ebx,%eax
  800594:	8b 75 08             	mov    0x8(%ebp),%esi
  800597:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80059a:	89 c3                	mov    %eax,%ebx
  80059c:	eb 16                	jmp    8005b4 <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059e:	83 ec 08             	sub    $0x8,%esp
  8005a1:	57                   	push   %edi
  8005a2:	6a 20                	push   $0x20
  8005a4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a6:	83 eb 01             	sub    $0x1,%ebx
  8005a9:	83 c4 10             	add    $0x10,%esp
  8005ac:	eb 06                	jmp    8005b4 <vprintfmt+0x294>
  8005ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005b4:	85 db                	test   %ebx,%ebx
  8005b6:	7f e6                	jg     80059e <vprintfmt+0x27e>
  8005b8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005bb:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005be:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005c1:	e9 86 fd ff ff       	jmp    80034c <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c6:	83 fa 01             	cmp    $0x1,%edx
  8005c9:	7e 10                	jle    8005db <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8d 50 08             	lea    0x8(%eax),%edx
  8005d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d4:	8b 30                	mov    (%eax),%esi
  8005d6:	8b 78 04             	mov    0x4(%eax),%edi
  8005d9:	eb 26                	jmp    800601 <vprintfmt+0x2e1>
	else if (lflag)
  8005db:	85 d2                	test   %edx,%edx
  8005dd:	74 12                	je     8005f1 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8d 50 04             	lea    0x4(%eax),%edx
  8005e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e8:	8b 30                	mov    (%eax),%esi
  8005ea:	89 f7                	mov    %esi,%edi
  8005ec:	c1 ff 1f             	sar    $0x1f,%edi
  8005ef:	eb 10                	jmp    800601 <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8d 50 04             	lea    0x4(%eax),%edx
  8005f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fa:	8b 30                	mov    (%eax),%esi
  8005fc:	89 f7                	mov    %esi,%edi
  8005fe:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800601:	89 f0                	mov    %esi,%eax
  800603:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800605:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80060a:	85 ff                	test   %edi,%edi
  80060c:	79 7b                	jns    800689 <vprintfmt+0x369>
				putch('-', putdat);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	ff 75 0c             	pushl  0xc(%ebp)
  800614:	6a 2d                	push   $0x2d
  800616:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800619:	89 f0                	mov    %esi,%eax
  80061b:	89 fa                	mov    %edi,%edx
  80061d:	f7 d8                	neg    %eax
  80061f:	83 d2 00             	adc    $0x0,%edx
  800622:	f7 da                	neg    %edx
  800624:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800627:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80062c:	eb 5b                	jmp    800689 <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80062e:	8d 45 14             	lea    0x14(%ebp),%eax
  800631:	e8 76 fc ff ff       	call   8002ac <getuint>
			base = 10;
  800636:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80063b:	eb 4c                	jmp    800689 <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
  80063d:	8d 45 14             	lea    0x14(%ebp),%eax
  800640:	e8 67 fc ff ff       	call   8002ac <getuint>
            base = 8;
  800645:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80064a:	eb 3d                	jmp    800689 <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	ff 75 0c             	pushl  0xc(%ebp)
  800652:	6a 30                	push   $0x30
  800654:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800657:	83 c4 08             	add    $0x8,%esp
  80065a:	ff 75 0c             	pushl  0xc(%ebp)
  80065d:	6a 78                	push   $0x78
  80065f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8d 50 04             	lea    0x4(%eax),%edx
  800668:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80066b:	8b 00                	mov    (%eax),%eax
  80066d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800672:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800675:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80067a:	eb 0d                	jmp    800689 <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80067c:	8d 45 14             	lea    0x14(%ebp),%eax
  80067f:	e8 28 fc ff ff       	call   8002ac <getuint>
			base = 16;
  800684:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800689:	83 ec 0c             	sub    $0xc,%esp
  80068c:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  800690:	56                   	push   %esi
  800691:	ff 75 e0             	pushl  -0x20(%ebp)
  800694:	51                   	push   %ecx
  800695:	52                   	push   %edx
  800696:	50                   	push   %eax
  800697:	8b 55 0c             	mov    0xc(%ebp),%edx
  80069a:	8b 45 08             	mov    0x8(%ebp),%eax
  80069d:	e8 5b fb ff ff       	call   8001fd <printnum>
			break;
  8006a2:	83 c4 20             	add    $0x20,%esp
  8006a5:	e9 a2 fc ff ff       	jmp    80034c <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006aa:	83 ec 08             	sub    $0x8,%esp
  8006ad:	ff 75 0c             	pushl  0xc(%ebp)
  8006b0:	51                   	push   %ecx
  8006b1:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006b4:	83 c4 10             	add    $0x10,%esp
  8006b7:	e9 90 fc ff ff       	jmp    80034c <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	ff 75 0c             	pushl  0xc(%ebp)
  8006c2:	6a 25                	push   $0x25
  8006c4:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c7:	83 c4 10             	add    $0x10,%esp
  8006ca:	89 f3                	mov    %esi,%ebx
  8006cc:	eb 03                	jmp    8006d1 <vprintfmt+0x3b1>
  8006ce:	83 eb 01             	sub    $0x1,%ebx
  8006d1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006d5:	75 f7                	jne    8006ce <vprintfmt+0x3ae>
  8006d7:	e9 70 fc ff ff       	jmp    80034c <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  8006dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006df:	5b                   	pop    %ebx
  8006e0:	5e                   	pop    %esi
  8006e1:	5f                   	pop    %edi
  8006e2:	5d                   	pop    %ebp
  8006e3:	c3                   	ret    

008006e4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	83 ec 18             	sub    $0x18,%esp
  8006ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ed:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800701:	85 c0                	test   %eax,%eax
  800703:	74 26                	je     80072b <vsnprintf+0x47>
  800705:	85 d2                	test   %edx,%edx
  800707:	7e 22                	jle    80072b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800709:	ff 75 14             	pushl  0x14(%ebp)
  80070c:	ff 75 10             	pushl  0x10(%ebp)
  80070f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800712:	50                   	push   %eax
  800713:	68 e6 02 80 00       	push   $0x8002e6
  800718:	e8 03 fc ff ff       	call   800320 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80071d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800720:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800723:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800726:	83 c4 10             	add    $0x10,%esp
  800729:	eb 05                	jmp    800730 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80072b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800730:	c9                   	leave  
  800731:	c3                   	ret    

00800732 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800738:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80073b:	50                   	push   %eax
  80073c:	ff 75 10             	pushl  0x10(%ebp)
  80073f:	ff 75 0c             	pushl  0xc(%ebp)
  800742:	ff 75 08             	pushl  0x8(%ebp)
  800745:	e8 9a ff ff ff       	call   8006e4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80074a:	c9                   	leave  
  80074b:	c3                   	ret    

0080074c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800752:	b8 00 00 00 00       	mov    $0x0,%eax
  800757:	eb 03                	jmp    80075c <strlen+0x10>
		n++;
  800759:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80075c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800760:	75 f7                	jne    800759 <strlen+0xd>
		n++;
	return n;
}
  800762:	5d                   	pop    %ebp
  800763:	c3                   	ret    

00800764 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076d:	ba 00 00 00 00       	mov    $0x0,%edx
  800772:	eb 03                	jmp    800777 <strnlen+0x13>
		n++;
  800774:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800777:	39 c2                	cmp    %eax,%edx
  800779:	74 08                	je     800783 <strnlen+0x1f>
  80077b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80077f:	75 f3                	jne    800774 <strnlen+0x10>
  800781:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800783:	5d                   	pop    %ebp
  800784:	c3                   	ret    

00800785 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	53                   	push   %ebx
  800789:	8b 45 08             	mov    0x8(%ebp),%eax
  80078c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80078f:	89 c2                	mov    %eax,%edx
  800791:	83 c2 01             	add    $0x1,%edx
  800794:	83 c1 01             	add    $0x1,%ecx
  800797:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80079b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80079e:	84 db                	test   %bl,%bl
  8007a0:	75 ef                	jne    800791 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007a2:	5b                   	pop    %ebx
  8007a3:	5d                   	pop    %ebp
  8007a4:	c3                   	ret    

008007a5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	53                   	push   %ebx
  8007a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ac:	53                   	push   %ebx
  8007ad:	e8 9a ff ff ff       	call   80074c <strlen>
  8007b2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007b5:	ff 75 0c             	pushl  0xc(%ebp)
  8007b8:	01 d8                	add    %ebx,%eax
  8007ba:	50                   	push   %eax
  8007bb:	e8 c5 ff ff ff       	call   800785 <strcpy>
	return dst;
}
  8007c0:	89 d8                	mov    %ebx,%eax
  8007c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    

008007c7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	56                   	push   %esi
  8007cb:	53                   	push   %ebx
  8007cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d2:	89 f3                	mov    %esi,%ebx
  8007d4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d7:	89 f2                	mov    %esi,%edx
  8007d9:	eb 0f                	jmp    8007ea <strncpy+0x23>
		*dst++ = *src;
  8007db:	83 c2 01             	add    $0x1,%edx
  8007de:	0f b6 01             	movzbl (%ecx),%eax
  8007e1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e4:	80 39 01             	cmpb   $0x1,(%ecx)
  8007e7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ea:	39 da                	cmp    %ebx,%edx
  8007ec:	75 ed                	jne    8007db <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ee:	89 f0                	mov    %esi,%eax
  8007f0:	5b                   	pop    %ebx
  8007f1:	5e                   	pop    %esi
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    

008007f4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	56                   	push   %esi
  8007f8:	53                   	push   %ebx
  8007f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ff:	8b 55 10             	mov    0x10(%ebp),%edx
  800802:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800804:	85 d2                	test   %edx,%edx
  800806:	74 21                	je     800829 <strlcpy+0x35>
  800808:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80080c:	89 f2                	mov    %esi,%edx
  80080e:	eb 09                	jmp    800819 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800810:	83 c2 01             	add    $0x1,%edx
  800813:	83 c1 01             	add    $0x1,%ecx
  800816:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800819:	39 c2                	cmp    %eax,%edx
  80081b:	74 09                	je     800826 <strlcpy+0x32>
  80081d:	0f b6 19             	movzbl (%ecx),%ebx
  800820:	84 db                	test   %bl,%bl
  800822:	75 ec                	jne    800810 <strlcpy+0x1c>
  800824:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800826:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800829:	29 f0                	sub    %esi,%eax
}
  80082b:	5b                   	pop    %ebx
  80082c:	5e                   	pop    %esi
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800835:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800838:	eb 06                	jmp    800840 <strcmp+0x11>
		p++, q++;
  80083a:	83 c1 01             	add    $0x1,%ecx
  80083d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800840:	0f b6 01             	movzbl (%ecx),%eax
  800843:	84 c0                	test   %al,%al
  800845:	74 04                	je     80084b <strcmp+0x1c>
  800847:	3a 02                	cmp    (%edx),%al
  800849:	74 ef                	je     80083a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80084b:	0f b6 c0             	movzbl %al,%eax
  80084e:	0f b6 12             	movzbl (%edx),%edx
  800851:	29 d0                	sub    %edx,%eax
}
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	53                   	push   %ebx
  800859:	8b 45 08             	mov    0x8(%ebp),%eax
  80085c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085f:	89 c3                	mov    %eax,%ebx
  800861:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800864:	eb 06                	jmp    80086c <strncmp+0x17>
		n--, p++, q++;
  800866:	83 c0 01             	add    $0x1,%eax
  800869:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80086c:	39 d8                	cmp    %ebx,%eax
  80086e:	74 15                	je     800885 <strncmp+0x30>
  800870:	0f b6 08             	movzbl (%eax),%ecx
  800873:	84 c9                	test   %cl,%cl
  800875:	74 04                	je     80087b <strncmp+0x26>
  800877:	3a 0a                	cmp    (%edx),%cl
  800879:	74 eb                	je     800866 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80087b:	0f b6 00             	movzbl (%eax),%eax
  80087e:	0f b6 12             	movzbl (%edx),%edx
  800881:	29 d0                	sub    %edx,%eax
  800883:	eb 05                	jmp    80088a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800885:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80088a:	5b                   	pop    %ebx
  80088b:	5d                   	pop    %ebp
  80088c:	c3                   	ret    

0080088d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	8b 45 08             	mov    0x8(%ebp),%eax
  800893:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800897:	eb 07                	jmp    8008a0 <strchr+0x13>
		if (*s == c)
  800899:	38 ca                	cmp    %cl,%dl
  80089b:	74 0f                	je     8008ac <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80089d:	83 c0 01             	add    $0x1,%eax
  8008a0:	0f b6 10             	movzbl (%eax),%edx
  8008a3:	84 d2                	test   %dl,%dl
  8008a5:	75 f2                	jne    800899 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ac:	5d                   	pop    %ebp
  8008ad:	c3                   	ret    

008008ae <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b8:	eb 03                	jmp    8008bd <strfind+0xf>
  8008ba:	83 c0 01             	add    $0x1,%eax
  8008bd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008c0:	38 ca                	cmp    %cl,%dl
  8008c2:	74 04                	je     8008c8 <strfind+0x1a>
  8008c4:	84 d2                	test   %dl,%dl
  8008c6:	75 f2                	jne    8008ba <strfind+0xc>
			break;
	return (char *) s;
}
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	57                   	push   %edi
  8008ce:	56                   	push   %esi
  8008cf:	53                   	push   %ebx
  8008d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d6:	85 c9                	test   %ecx,%ecx
  8008d8:	74 36                	je     800910 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008da:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e0:	75 28                	jne    80090a <memset+0x40>
  8008e2:	f6 c1 03             	test   $0x3,%cl
  8008e5:	75 23                	jne    80090a <memset+0x40>
		c &= 0xFF;
  8008e7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008eb:	89 d3                	mov    %edx,%ebx
  8008ed:	c1 e3 08             	shl    $0x8,%ebx
  8008f0:	89 d6                	mov    %edx,%esi
  8008f2:	c1 e6 18             	shl    $0x18,%esi
  8008f5:	89 d0                	mov    %edx,%eax
  8008f7:	c1 e0 10             	shl    $0x10,%eax
  8008fa:	09 f0                	or     %esi,%eax
  8008fc:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008fe:	89 d8                	mov    %ebx,%eax
  800900:	09 d0                	or     %edx,%eax
  800902:	c1 e9 02             	shr    $0x2,%ecx
  800905:	fc                   	cld    
  800906:	f3 ab                	rep stos %eax,%es:(%edi)
  800908:	eb 06                	jmp    800910 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80090a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090d:	fc                   	cld    
  80090e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800910:	89 f8                	mov    %edi,%eax
  800912:	5b                   	pop    %ebx
  800913:	5e                   	pop    %esi
  800914:	5f                   	pop    %edi
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	57                   	push   %edi
  80091b:	56                   	push   %esi
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800922:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800925:	39 c6                	cmp    %eax,%esi
  800927:	73 35                	jae    80095e <memmove+0x47>
  800929:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80092c:	39 d0                	cmp    %edx,%eax
  80092e:	73 2e                	jae    80095e <memmove+0x47>
		s += n;
		d += n;
  800930:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800933:	89 d6                	mov    %edx,%esi
  800935:	09 fe                	or     %edi,%esi
  800937:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80093d:	75 13                	jne    800952 <memmove+0x3b>
  80093f:	f6 c1 03             	test   $0x3,%cl
  800942:	75 0e                	jne    800952 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800944:	83 ef 04             	sub    $0x4,%edi
  800947:	8d 72 fc             	lea    -0x4(%edx),%esi
  80094a:	c1 e9 02             	shr    $0x2,%ecx
  80094d:	fd                   	std    
  80094e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800950:	eb 09                	jmp    80095b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800952:	83 ef 01             	sub    $0x1,%edi
  800955:	8d 72 ff             	lea    -0x1(%edx),%esi
  800958:	fd                   	std    
  800959:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80095b:	fc                   	cld    
  80095c:	eb 1d                	jmp    80097b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095e:	89 f2                	mov    %esi,%edx
  800960:	09 c2                	or     %eax,%edx
  800962:	f6 c2 03             	test   $0x3,%dl
  800965:	75 0f                	jne    800976 <memmove+0x5f>
  800967:	f6 c1 03             	test   $0x3,%cl
  80096a:	75 0a                	jne    800976 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80096c:	c1 e9 02             	shr    $0x2,%ecx
  80096f:	89 c7                	mov    %eax,%edi
  800971:	fc                   	cld    
  800972:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800974:	eb 05                	jmp    80097b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800976:	89 c7                	mov    %eax,%edi
  800978:	fc                   	cld    
  800979:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80097b:	5e                   	pop    %esi
  80097c:	5f                   	pop    %edi
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800982:	ff 75 10             	pushl  0x10(%ebp)
  800985:	ff 75 0c             	pushl  0xc(%ebp)
  800988:	ff 75 08             	pushl  0x8(%ebp)
  80098b:	e8 87 ff ff ff       	call   800917 <memmove>
}
  800990:	c9                   	leave  
  800991:	c3                   	ret    

00800992 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	56                   	push   %esi
  800996:	53                   	push   %ebx
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099d:	89 c6                	mov    %eax,%esi
  80099f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a2:	eb 1a                	jmp    8009be <memcmp+0x2c>
		if (*s1 != *s2)
  8009a4:	0f b6 08             	movzbl (%eax),%ecx
  8009a7:	0f b6 1a             	movzbl (%edx),%ebx
  8009aa:	38 d9                	cmp    %bl,%cl
  8009ac:	74 0a                	je     8009b8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009ae:	0f b6 c1             	movzbl %cl,%eax
  8009b1:	0f b6 db             	movzbl %bl,%ebx
  8009b4:	29 d8                	sub    %ebx,%eax
  8009b6:	eb 0f                	jmp    8009c7 <memcmp+0x35>
		s1++, s2++;
  8009b8:	83 c0 01             	add    $0x1,%eax
  8009bb:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009be:	39 f0                	cmp    %esi,%eax
  8009c0:	75 e2                	jne    8009a4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c7:	5b                   	pop    %ebx
  8009c8:	5e                   	pop    %esi
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	53                   	push   %ebx
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009d2:	89 c1                	mov    %eax,%ecx
  8009d4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009db:	eb 0a                	jmp    8009e7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009dd:	0f b6 10             	movzbl (%eax),%edx
  8009e0:	39 da                	cmp    %ebx,%edx
  8009e2:	74 07                	je     8009eb <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e4:	83 c0 01             	add    $0x1,%eax
  8009e7:	39 c8                	cmp    %ecx,%eax
  8009e9:	72 f2                	jb     8009dd <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009eb:	5b                   	pop    %ebx
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	57                   	push   %edi
  8009f2:	56                   	push   %esi
  8009f3:	53                   	push   %ebx
  8009f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fa:	eb 03                	jmp    8009ff <strtol+0x11>
		s++;
  8009fc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ff:	0f b6 01             	movzbl (%ecx),%eax
  800a02:	3c 20                	cmp    $0x20,%al
  800a04:	74 f6                	je     8009fc <strtol+0xe>
  800a06:	3c 09                	cmp    $0x9,%al
  800a08:	74 f2                	je     8009fc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a0a:	3c 2b                	cmp    $0x2b,%al
  800a0c:	75 0a                	jne    800a18 <strtol+0x2a>
		s++;
  800a0e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a11:	bf 00 00 00 00       	mov    $0x0,%edi
  800a16:	eb 11                	jmp    800a29 <strtol+0x3b>
  800a18:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a1d:	3c 2d                	cmp    $0x2d,%al
  800a1f:	75 08                	jne    800a29 <strtol+0x3b>
		s++, neg = 1;
  800a21:	83 c1 01             	add    $0x1,%ecx
  800a24:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a29:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a2f:	75 15                	jne    800a46 <strtol+0x58>
  800a31:	80 39 30             	cmpb   $0x30,(%ecx)
  800a34:	75 10                	jne    800a46 <strtol+0x58>
  800a36:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a3a:	75 7c                	jne    800ab8 <strtol+0xca>
		s += 2, base = 16;
  800a3c:	83 c1 02             	add    $0x2,%ecx
  800a3f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a44:	eb 16                	jmp    800a5c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a46:	85 db                	test   %ebx,%ebx
  800a48:	75 12                	jne    800a5c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a4a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a52:	75 08                	jne    800a5c <strtol+0x6e>
		s++, base = 8;
  800a54:	83 c1 01             	add    $0x1,%ecx
  800a57:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a61:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a64:	0f b6 11             	movzbl (%ecx),%edx
  800a67:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a6a:	89 f3                	mov    %esi,%ebx
  800a6c:	80 fb 09             	cmp    $0x9,%bl
  800a6f:	77 08                	ja     800a79 <strtol+0x8b>
			dig = *s - '0';
  800a71:	0f be d2             	movsbl %dl,%edx
  800a74:	83 ea 30             	sub    $0x30,%edx
  800a77:	eb 22                	jmp    800a9b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a79:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a7c:	89 f3                	mov    %esi,%ebx
  800a7e:	80 fb 19             	cmp    $0x19,%bl
  800a81:	77 08                	ja     800a8b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a83:	0f be d2             	movsbl %dl,%edx
  800a86:	83 ea 57             	sub    $0x57,%edx
  800a89:	eb 10                	jmp    800a9b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a8b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a8e:	89 f3                	mov    %esi,%ebx
  800a90:	80 fb 19             	cmp    $0x19,%bl
  800a93:	77 16                	ja     800aab <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a95:	0f be d2             	movsbl %dl,%edx
  800a98:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a9b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a9e:	7d 0b                	jge    800aab <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aa0:	83 c1 01             	add    $0x1,%ecx
  800aa3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aa9:	eb b9                	jmp    800a64 <strtol+0x76>

	if (endptr)
  800aab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aaf:	74 0d                	je     800abe <strtol+0xd0>
		*endptr = (char *) s;
  800ab1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab4:	89 0e                	mov    %ecx,(%esi)
  800ab6:	eb 06                	jmp    800abe <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab8:	85 db                	test   %ebx,%ebx
  800aba:	74 98                	je     800a54 <strtol+0x66>
  800abc:	eb 9e                	jmp    800a5c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800abe:	89 c2                	mov    %eax,%edx
  800ac0:	f7 da                	neg    %edx
  800ac2:	85 ff                	test   %edi,%edi
  800ac4:	0f 45 c2             	cmovne %edx,%eax
}
  800ac7:	5b                   	pop    %ebx
  800ac8:	5e                   	pop    %esi
  800ac9:	5f                   	pop    %edi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800ad2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ada:	8b 55 08             	mov    0x8(%ebp),%edx
  800add:	89 c3                	mov    %eax,%ebx
  800adf:	89 c7                	mov    %eax,%edi
  800ae1:	89 c6                	mov    %eax,%esi
  800ae3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5f                   	pop    %edi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <sys_cgetc>:

int
sys_cgetc(void)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	57                   	push   %edi
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af0:	ba 00 00 00 00       	mov    $0x0,%edx
  800af5:	b8 01 00 00 00       	mov    $0x1,%eax
  800afa:	89 d1                	mov    %edx,%ecx
  800afc:	89 d3                	mov    %edx,%ebx
  800afe:	89 d7                	mov    %edx,%edi
  800b00:	89 d6                	mov    %edx,%esi
  800b02:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5f                   	pop    %edi
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	57                   	push   %edi
  800b0d:	56                   	push   %esi
  800b0e:	53                   	push   %ebx
  800b0f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b12:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b17:	b8 03 00 00 00       	mov    $0x3,%eax
  800b1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1f:	89 cb                	mov    %ecx,%ebx
  800b21:	89 cf                	mov    %ecx,%edi
  800b23:	89 ce                	mov    %ecx,%esi
  800b25:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b27:	85 c0                	test   %eax,%eax
  800b29:	7e 17                	jle    800b42 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2b:	83 ec 0c             	sub    $0xc,%esp
  800b2e:	50                   	push   %eax
  800b2f:	6a 03                	push   $0x3
  800b31:	68 08 19 80 00       	push   $0x801908
  800b36:	6a 23                	push   $0x23
  800b38:	68 25 19 80 00       	push   $0x801925
  800b3d:	e8 a1 07 00 00       	call   8012e3 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b45:	5b                   	pop    %ebx
  800b46:	5e                   	pop    %esi
  800b47:	5f                   	pop    %edi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	57                   	push   %edi
  800b4e:	56                   	push   %esi
  800b4f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b50:	ba 00 00 00 00       	mov    $0x0,%edx
  800b55:	b8 02 00 00 00       	mov    $0x2,%eax
  800b5a:	89 d1                	mov    %edx,%ecx
  800b5c:	89 d3                	mov    %edx,%ebx
  800b5e:	89 d7                	mov    %edx,%edi
  800b60:	89 d6                	mov    %edx,%esi
  800b62:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <sys_yield>:

void
sys_yield(void)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	57                   	push   %edi
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b74:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b79:	89 d1                	mov    %edx,%ecx
  800b7b:	89 d3                	mov    %edx,%ebx
  800b7d:	89 d7                	mov    %edx,%edi
  800b7f:	89 d6                	mov    %edx,%esi
  800b81:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b83:	5b                   	pop    %ebx
  800b84:	5e                   	pop    %esi
  800b85:	5f                   	pop    %edi
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    

00800b88 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	57                   	push   %edi
  800b8c:	56                   	push   %esi
  800b8d:	53                   	push   %ebx
  800b8e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b91:	be 00 00 00 00       	mov    $0x0,%esi
  800b96:	b8 04 00 00 00       	mov    $0x4,%eax
  800b9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba4:	89 f7                	mov    %esi,%edi
  800ba6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba8:	85 c0                	test   %eax,%eax
  800baa:	7e 17                	jle    800bc3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bac:	83 ec 0c             	sub    $0xc,%esp
  800baf:	50                   	push   %eax
  800bb0:	6a 04                	push   $0x4
  800bb2:	68 08 19 80 00       	push   $0x801908
  800bb7:	6a 23                	push   $0x23
  800bb9:	68 25 19 80 00       	push   $0x801925
  800bbe:	e8 20 07 00 00       	call   8012e3 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc6:	5b                   	pop    %ebx
  800bc7:	5e                   	pop    %esi
  800bc8:	5f                   	pop    %edi
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	57                   	push   %edi
  800bcf:	56                   	push   %esi
  800bd0:	53                   	push   %ebx
  800bd1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd4:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800be5:	8b 75 18             	mov    0x18(%ebp),%esi
  800be8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bea:	85 c0                	test   %eax,%eax
  800bec:	7e 17                	jle    800c05 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bee:	83 ec 0c             	sub    $0xc,%esp
  800bf1:	50                   	push   %eax
  800bf2:	6a 05                	push   $0x5
  800bf4:	68 08 19 80 00       	push   $0x801908
  800bf9:	6a 23                	push   $0x23
  800bfb:	68 25 19 80 00       	push   $0x801925
  800c00:	e8 de 06 00 00       	call   8012e3 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c08:	5b                   	pop    %ebx
  800c09:	5e                   	pop    %esi
  800c0a:	5f                   	pop    %edi
  800c0b:	5d                   	pop    %ebp
  800c0c:	c3                   	ret    

00800c0d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	57                   	push   %edi
  800c11:	56                   	push   %esi
  800c12:	53                   	push   %ebx
  800c13:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c1b:	b8 06 00 00 00       	mov    $0x6,%eax
  800c20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c23:	8b 55 08             	mov    0x8(%ebp),%edx
  800c26:	89 df                	mov    %ebx,%edi
  800c28:	89 de                	mov    %ebx,%esi
  800c2a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c2c:	85 c0                	test   %eax,%eax
  800c2e:	7e 17                	jle    800c47 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c30:	83 ec 0c             	sub    $0xc,%esp
  800c33:	50                   	push   %eax
  800c34:	6a 06                	push   $0x6
  800c36:	68 08 19 80 00       	push   $0x801908
  800c3b:	6a 23                	push   $0x23
  800c3d:	68 25 19 80 00       	push   $0x801925
  800c42:	e8 9c 06 00 00       	call   8012e3 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
  800c55:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c65:	8b 55 08             	mov    0x8(%ebp),%edx
  800c68:	89 df                	mov    %ebx,%edi
  800c6a:	89 de                	mov    %ebx,%esi
  800c6c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6e:	85 c0                	test   %eax,%eax
  800c70:	7e 17                	jle    800c89 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c72:	83 ec 0c             	sub    $0xc,%esp
  800c75:	50                   	push   %eax
  800c76:	6a 08                	push   $0x8
  800c78:	68 08 19 80 00       	push   $0x801908
  800c7d:	6a 23                	push   $0x23
  800c7f:	68 25 19 80 00       	push   $0x801925
  800c84:	e8 5a 06 00 00       	call   8012e3 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5f                   	pop    %edi
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	57                   	push   %edi
  800c95:	56                   	push   %esi
  800c96:	53                   	push   %ebx
  800c97:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9f:	b8 09 00 00 00       	mov    $0x9,%eax
  800ca4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca7:	8b 55 08             	mov    0x8(%ebp),%edx
  800caa:	89 df                	mov    %ebx,%edi
  800cac:	89 de                	mov    %ebx,%esi
  800cae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb0:	85 c0                	test   %eax,%eax
  800cb2:	7e 17                	jle    800ccb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb4:	83 ec 0c             	sub    $0xc,%esp
  800cb7:	50                   	push   %eax
  800cb8:	6a 09                	push   $0x9
  800cba:	68 08 19 80 00       	push   $0x801908
  800cbf:	6a 23                	push   $0x23
  800cc1:	68 25 19 80 00       	push   $0x801925
  800cc6:	e8 18 06 00 00       	call   8012e3 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ccb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cce:	5b                   	pop    %ebx
  800ccf:	5e                   	pop    %esi
  800cd0:	5f                   	pop    %edi
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	57                   	push   %edi
  800cd7:	56                   	push   %esi
  800cd8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd9:	be 00 00 00 00       	mov    $0x0,%esi
  800cde:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ce3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cec:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cef:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	57                   	push   %edi
  800cfa:	56                   	push   %esi
  800cfb:	53                   	push   %ebx
  800cfc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d04:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d09:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0c:	89 cb                	mov    %ecx,%ebx
  800d0e:	89 cf                	mov    %ecx,%edi
  800d10:	89 ce                	mov    %ecx,%esi
  800d12:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d14:	85 c0                	test   %eax,%eax
  800d16:	7e 17                	jle    800d2f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d18:	83 ec 0c             	sub    $0xc,%esp
  800d1b:	50                   	push   %eax
  800d1c:	6a 0c                	push   $0xc
  800d1e:	68 08 19 80 00       	push   $0x801908
  800d23:	6a 23                	push   $0x23
  800d25:	68 25 19 80 00       	push   $0x801925
  800d2a:	e8 b4 05 00 00       	call   8012e3 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d32:	5b                   	pop    %ebx
  800d33:	5e                   	pop    %esi
  800d34:	5f                   	pop    %edi
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    

00800d37 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	57                   	push   %edi
  800d3b:	56                   	push   %esi
  800d3c:	53                   	push   %ebx
  800d3d:	83 ec 0c             	sub    $0xc,%esp
  800d40:	89 c7                	mov    %eax,%edi
  800d42:	89 d3                	mov    %edx,%ebx
	int r;

	// LAB 4: Your code here.

    envid_t myenvid = sys_getenvid();
  800d44:	e8 01 fe ff ff       	call   800b4a <sys_getenvid>
  800d49:	89 c6                	mov    %eax,%esi
    pte_t pte = uvpt[pn];
  800d4b:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    int perm;

    perm = PTE_U | PTE_P;
    if(pte & PTE_W || pte & PTE_COW)
  800d52:	a9 02 08 00 00       	test   $0x802,%eax
  800d57:	75 40                	jne    800d99 <duppage+0x62>
    {
        perm |= PTE_COW;
    }

    // map to envid VA
    if ((r = sys_page_map(myenvid,
  800d59:	c1 e3 0c             	shl    $0xc,%ebx
  800d5c:	83 ec 0c             	sub    $0xc,%esp
  800d5f:	6a 05                	push   $0x5
  800d61:	53                   	push   %ebx
  800d62:	57                   	push   %edi
  800d63:	53                   	push   %ebx
  800d64:	56                   	push   %esi
  800d65:	e8 61 fe ff ff       	call   800bcb <sys_page_map>
  800d6a:	83 c4 20             	add    $0x20,%esp
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d74:	0f 4f c2             	cmovg  %edx,%eax
  800d77:	eb 3b                	jmp    800db4 <duppage+0x7d>
    }

    // if COW remap to self
    if(perm & PTE_COW)
    {
        if((r = sys_page_map(myenvid, 
  800d79:	83 ec 0c             	sub    $0xc,%esp
  800d7c:	68 05 08 00 00       	push   $0x805
  800d81:	53                   	push   %ebx
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
  800d84:	56                   	push   %esi
  800d85:	e8 41 fe ff ff       	call   800bcb <sys_page_map>
  800d8a:	83 c4 20             	add    $0x20,%esp
  800d8d:	85 c0                	test   %eax,%eax
  800d8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d94:	0f 4f c2             	cmovg  %edx,%eax
  800d97:	eb 1b                	jmp    800db4 <duppage+0x7d>
    {
        perm |= PTE_COW;
    }

    // map to envid VA
    if ((r = sys_page_map(myenvid,
  800d99:	c1 e3 0c             	shl    $0xc,%ebx
  800d9c:	83 ec 0c             	sub    $0xc,%esp
  800d9f:	68 05 08 00 00       	push   $0x805
  800da4:	53                   	push   %ebx
  800da5:	57                   	push   %edi
  800da6:	53                   	push   %ebx
  800da7:	56                   	push   %esi
  800da8:	e8 1e fe ff ff       	call   800bcb <sys_page_map>
  800dad:	83 c4 20             	add    $0x20,%esp
  800db0:	85 c0                	test   %eax,%eax
  800db2:	79 c5                	jns    800d79 <duppage+0x42>
            return r;
        }
    }

	return 0;
}
  800db4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db7:	5b                   	pop    %ebx
  800db8:	5e                   	pop    %esi
  800db9:	5f                   	pop    %edi
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    

00800dbc <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	56                   	push   %esi
  800dc0:	53                   	push   %ebx
  800dc1:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dc4:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

    if ((err & FEC_WR) == 0)
  800dc6:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dca:	75 12                	jne    800dde <pgfault+0x22>
    {
        panic("pgfault: page fault was not caused by write; %x.\n", utf->utf_fault_va);
  800dcc:	53                   	push   %ebx
  800dcd:	68 34 19 80 00       	push   $0x801934
  800dd2:	6a 1f                	push   $0x1f
  800dd4:	68 0b 1a 80 00       	push   $0x801a0b
  800dd9:	e8 05 05 00 00       	call   8012e3 <_panic>
    }

    if ((uvpt[PGNUM(addr)] & PTE_COW) == 0) 
  800dde:	89 d8                	mov    %ebx,%eax
  800de0:	c1 e8 0c             	shr    $0xc,%eax
  800de3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dea:	f6 c4 08             	test   $0x8,%ah
  800ded:	75 12                	jne    800e01 <pgfault+0x45>
    {
        panic("pgfault: page fault on page which is not COW %x.\n", utf->utf_fault_va);
  800def:	53                   	push   %ebx
  800df0:	68 68 19 80 00       	push   $0x801968
  800df5:	6a 24                	push   $0x24
  800df7:	68 0b 1a 80 00       	push   $0x801a0b
  800dfc:	e8 e2 04 00 00       	call   8012e3 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    envid_t envid = sys_getenvid();
  800e01:	e8 44 fd ff ff       	call   800b4a <sys_getenvid>
  800e06:	89 c6                	mov    %eax,%esi

    //allocate temp page
    if (sys_page_alloc(envid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  800e08:	83 ec 04             	sub    $0x4,%esp
  800e0b:	6a 07                	push   $0x7
  800e0d:	68 00 f0 7f 00       	push   $0x7ff000
  800e12:	50                   	push   %eax
  800e13:	e8 70 fd ff ff       	call   800b88 <sys_page_alloc>
  800e18:	83 c4 10             	add    $0x10,%esp
  800e1b:	85 c0                	test   %eax,%eax
  800e1d:	79 14                	jns    800e33 <pgfault+0x77>
    {
        panic("pgfault: can't allocate temp page.\n");
  800e1f:	83 ec 04             	sub    $0x4,%esp
  800e22:	68 9c 19 80 00       	push   $0x80199c
  800e27:	6a 32                	push   $0x32
  800e29:	68 0b 1a 80 00       	push   $0x801a0b
  800e2e:	e8 b0 04 00 00       	call   8012e3 <_panic>
    }

    memmove(PFTEMP, (void *)ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800e33:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800e39:	83 ec 04             	sub    $0x4,%esp
  800e3c:	68 00 10 00 00       	push   $0x1000
  800e41:	53                   	push   %ebx
  800e42:	68 00 f0 7f 00       	push   $0x7ff000
  800e47:	e8 cb fa ff ff       	call   800917 <memmove>

    if(sys_page_map(envid, PFTEMP, envid, (void *)ROUNDDOWN(addr, PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
  800e4c:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e53:	53                   	push   %ebx
  800e54:	56                   	push   %esi
  800e55:	68 00 f0 7f 00       	push   $0x7ff000
  800e5a:	56                   	push   %esi
  800e5b:	e8 6b fd ff ff       	call   800bcb <sys_page_map>
  800e60:	83 c4 20             	add    $0x20,%esp
  800e63:	85 c0                	test   %eax,%eax
  800e65:	79 14                	jns    800e7b <pgfault+0xbf>
    {
        panic("pgfault: can't map temp page to old page.\n");
  800e67:	83 ec 04             	sub    $0x4,%esp
  800e6a:	68 c0 19 80 00       	push   $0x8019c0
  800e6f:	6a 39                	push   $0x39
  800e71:	68 0b 1a 80 00       	push   $0x801a0b
  800e76:	e8 68 04 00 00       	call   8012e3 <_panic>
    }

    if(sys_page_unmap(envid, PFTEMP) < 0)
  800e7b:	83 ec 08             	sub    $0x8,%esp
  800e7e:	68 00 f0 7f 00       	push   $0x7ff000
  800e83:	56                   	push   %esi
  800e84:	e8 84 fd ff ff       	call   800c0d <sys_page_unmap>
  800e89:	83 c4 10             	add    $0x10,%esp
  800e8c:	85 c0                	test   %eax,%eax
  800e8e:	79 14                	jns    800ea4 <pgfault+0xe8>
    {
        panic("pgfault: couldn't unmap page.\n");
  800e90:	83 ec 04             	sub    $0x4,%esp
  800e93:	68 ec 19 80 00       	push   $0x8019ec
  800e98:	6a 3e                	push   $0x3e
  800e9a:	68 0b 1a 80 00       	push   $0x801a0b
  800e9f:	e8 3f 04 00 00       	call   8012e3 <_panic>
    }
	//panic("pgfault not implemented");
}
  800ea4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea7:	5b                   	pop    %ebx
  800ea8:	5e                   	pop    %esi
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	57                   	push   %edi
  800eaf:	56                   	push   %esi
  800eb0:	53                   	push   %ebx
  800eb1:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    extern void _pgfault_upcall(void);
    envid_t myenvid = sys_getenvid();
  800eb4:	e8 91 fc ff ff       	call   800b4a <sys_getenvid>
  800eb9:	89 45 e0             	mov    %eax,-0x20(%ebp)
    envid_t envid;
    uint32_t i, j, pn;

    //set page fault handler
    set_pgfault_handler(pgfault);
  800ebc:	83 ec 0c             	sub    $0xc,%esp
  800ebf:	68 bc 0d 80 00       	push   $0x800dbc
  800ec4:	e8 60 04 00 00       	call   801329 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ec9:	b8 07 00 00 00       	mov    $0x7,%eax
  800ece:	cd 30                	int    $0x30
  800ed0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800ed3:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    //create a child
    if((envid = sys_exofork()) < 0)
  800ed6:	83 c4 10             	add    $0x10,%esp
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	0f 88 13 01 00 00    	js     800ff4 <fork+0x149>
  800ee1:	bf 02 00 00 00       	mov    $0x2,%edi
    {
        return -1;
    }

    if(envid == 0)
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	75 21                	jne    800f0b <fork+0x60>
    {
        thisenv = &envs[ENVX(sys_getenvid())];
  800eea:	e8 5b fc ff ff       	call   800b4a <sys_getenvid>
  800eef:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ef4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ef7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800efc:	a3 08 20 80 00       	mov    %eax,0x802008

        return envid;
  800f01:	b8 00 00 00 00       	mov    $0x0,%eax
  800f06:	e9 0a 01 00 00       	jmp    801015 <fork+0x16a>
    }

    //copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
  800f0b:	8b 04 bd 00 d0 7b ef 	mov    -0x10843000(,%edi,4),%eax
  800f12:	a8 01                	test   $0x1,%al
  800f14:	74 3a                	je     800f50 <fork+0xa5>
        {
            for (j = 0; j < NPTENTRIES; j++)
            {
                pn = PGNUM(PGADDR(i, j, 0));
  800f16:	89 fe                	mov    %edi,%esi
  800f18:	c1 e6 16             	shl    $0x16,%esi
  800f1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f20:	89 da                	mov    %ebx,%edx
  800f22:	c1 e2 0c             	shl    $0xc,%edx
  800f25:	09 f2                	or     %esi,%edx
  800f27:	c1 ea 0c             	shr    $0xc,%edx
                if(pn == PGNUM(UXSTACKTOP - PGSIZE))
  800f2a:	81 fa ff eb 0e 00    	cmp    $0xeebff,%edx
  800f30:	74 1e                	je     800f50 <fork+0xa5>
                {
                    break;
                }

                if(uvpt[pn] & PTE_P)
  800f32:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800f39:	a8 01                	test   $0x1,%al
  800f3b:	74 08                	je     800f45 <fork+0x9a>
                {
                    duppage(envid, pn);
  800f3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f40:	e8 f2 fd ff ff       	call   800d37 <duppage>
    //copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
        {
            for (j = 0; j < NPTENTRIES; j++)
  800f45:	83 c3 01             	add    $0x1,%ebx
  800f48:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  800f4e:	75 d0                	jne    800f20 <fork+0x75>

        return envid;
    }

    //copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
  800f50:	83 c7 01             	add    $0x1,%edi
  800f53:	81 ff bb 03 00 00    	cmp    $0x3bb,%edi
  800f59:	75 b0                	jne    800f0b <fork+0x60>
                }
            }
        }
    }

    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
  800f5b:	83 ec 04             	sub    $0x4,%esp
  800f5e:	6a 07                	push   $0x7
  800f60:	68 00 f0 bf ee       	push   $0xeebff000
  800f65:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800f68:	57                   	push   %edi
  800f69:	e8 1a fc ff ff       	call   800b88 <sys_page_alloc>
  800f6e:	83 c4 10             	add    $0x10,%esp
  800f71:	85 c0                	test   %eax,%eax
  800f73:	0f 88 82 00 00 00    	js     800ffb <fork+0x150>
    {
        return -1;
    }

    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  800f79:	83 ec 0c             	sub    $0xc,%esp
  800f7c:	6a 07                	push   $0x7
  800f7e:	68 00 f0 7f 00       	push   $0x7ff000
  800f83:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800f86:	56                   	push   %esi
  800f87:	68 00 f0 bf ee       	push   $0xeebff000
  800f8c:	57                   	push   %edi
  800f8d:	e8 39 fc ff ff       	call   800bcb <sys_page_map>
  800f92:	83 c4 20             	add    $0x20,%esp
  800f95:	85 c0                	test   %eax,%eax
  800f97:	78 69                	js     801002 <fork+0x157>
    {
        return -1;
    }

    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);
  800f99:	83 ec 04             	sub    $0x4,%esp
  800f9c:	68 00 10 00 00       	push   $0x1000
  800fa1:	68 00 f0 7f 00       	push   $0x7ff000
  800fa6:	68 00 f0 bf ee       	push   $0xeebff000
  800fab:	e8 67 f9 ff ff       	call   800917 <memmove>

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
  800fb0:	83 c4 08             	add    $0x8,%esp
  800fb3:	68 00 f0 7f 00       	push   $0x7ff000
  800fb8:	56                   	push   %esi
  800fb9:	e8 4f fc ff ff       	call   800c0d <sys_page_unmap>
  800fbe:	83 c4 10             	add    $0x10,%esp
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	78 44                	js     801009 <fork+0x15e>
    {
        return -1;
    }

    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
  800fc5:	83 ec 08             	sub    $0x8,%esp
  800fc8:	68 8e 13 80 00       	push   $0x80138e
  800fcd:	57                   	push   %edi
  800fce:	e8 be fc ff ff       	call   800c91 <sys_env_set_pgfault_upcall>
  800fd3:	83 c4 10             	add    $0x10,%esp
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	78 36                	js     801010 <fork+0x165>
    {
        return -1;
    }

    if(sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  800fda:	83 ec 08             	sub    $0x8,%esp
  800fdd:	6a 02                	push   $0x2
  800fdf:	57                   	push   %edi
  800fe0:	e8 6a fc ff ff       	call   800c4f <sys_env_set_status>
  800fe5:	83 c4 10             	add    $0x10,%esp
    {
        return -1;
    }

    return envid;
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800fef:	0f 49 c7             	cmovns %edi,%eax
  800ff2:	eb 21                	jmp    801015 <fork+0x16a>
    set_pgfault_handler(pgfault);

    //create a child
    if((envid = sys_exofork()) < 0)
    {
        return -1;
  800ff4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800ff9:	eb 1a                	jmp    801015 <fork+0x16a>
        }
    }

    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  800ffb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801000:	eb 13                	jmp    801015 <fork+0x16a>
    }

    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  801002:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801007:	eb 0c                	jmp    801015 <fork+0x16a>

    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
    {
        return -1;
  801009:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80100e:	eb 05                	jmp    801015 <fork+0x16a>
    }

    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
    {
        return -1;
  801010:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
        return -1;
    }

    return envid;
    //	panic("fork not implemented");
}
  801015:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801018:	5b                   	pop    %ebx
  801019:	5e                   	pop    %esi
  80101a:	5f                   	pop    %edi
  80101b:	5d                   	pop    %ebp
  80101c:	c3                   	ret    

0080101d <sfork>:

// Challenge!
int
sfork(void)
{
  80101d:	55                   	push   %ebp
  80101e:	89 e5                	mov    %esp,%ebp
  801020:	57                   	push   %edi
  801021:	56                   	push   %esi
  801022:	53                   	push   %ebx
  801023:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    extern void _pgfault_upcall(void);
    envid_t myenvid = sys_getenvid();
  801026:	e8 1f fb ff ff       	call   800b4a <sys_getenvid>
  80102b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    envid_t envid;
    uint32_t i, j, pn;
    int perm;

    // set page fault handler
    set_pgfault_handler(pgfault);
  80102e:	83 ec 0c             	sub    $0xc,%esp
  801031:	68 bc 0d 80 00       	push   $0x800dbc
  801036:	e8 ee 02 00 00       	call   801329 <set_pgfault_handler>
  80103b:	b8 07 00 00 00       	mov    $0x7,%eax
  801040:	cd 30                	int    $0x30
  801042:	89 45 dc             	mov    %eax,-0x24(%ebp)

    // create a child
    if((envid = sys_exofork()) < 0)
  801045:	83 c4 10             	add    $0x10,%esp
  801048:	85 c0                	test   %eax,%eax
  80104a:	0f 88 5d 01 00 00    	js     8011ad <sfork+0x190>
  801050:	89 c7                	mov    %eax,%edi
  801052:	c7 45 e4 02 00 00 00 	movl   $0x2,-0x1c(%ebp)
    {
        return -1;
    }

    if(envid == 0)
  801059:	85 c0                	test   %eax,%eax
  80105b:	75 21                	jne    80107e <sfork+0x61>
    {
        thisenv = &envs[ENVX(sys_getenvid())];
  80105d:	e8 e8 fa ff ff       	call   800b4a <sys_getenvid>
  801062:	25 ff 03 00 00       	and    $0x3ff,%eax
  801067:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80106a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80106f:	a3 08 20 80 00       	mov    %eax,0x802008
        return envid;
  801074:	b8 00 00 00 00       	mov    $0x0,%eax
  801079:	e9 57 01 00 00       	jmp    8011d5 <sfork+0x1b8>
    }

    // copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
  80107e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801081:	8b 04 b5 00 d0 7b ef 	mov    -0x10843000(,%esi,4),%eax
  801088:	a8 01                	test   $0x1,%al
  80108a:	74 76                	je     801102 <sfork+0xe5>
        {
            for (j = 0; j < NPTENTRIES; j++)
            {
                pn = PGNUM(PGADDR(i, j, 0));
  80108c:	c1 e6 16             	shl    $0x16,%esi
  80108f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801094:	89 d8                	mov    %ebx,%eax
  801096:	c1 e0 0c             	shl    $0xc,%eax
  801099:	09 f0                	or     %esi,%eax
  80109b:	89 c2                	mov    %eax,%edx
  80109d:	c1 ea 0c             	shr    $0xc,%edx
                if(pn == PGNUM(UXSTACKTOP - PGSIZE))
  8010a0:	81 fa ff eb 0e 00    	cmp    $0xeebff,%edx
  8010a6:	74 5a                	je     801102 <sfork+0xe5>
                {
                    break;
                }

                if(pn == PGNUM(USTACKTOP - PGSIZE))
  8010a8:	81 fa fd eb 0e 00    	cmp    $0xeebfd,%edx
  8010ae:	75 09                	jne    8010b9 <sfork+0x9c>
                {
                     duppage(envid, pn); // cow for stack page
  8010b0:	89 f8                	mov    %edi,%eax
  8010b2:	e8 80 fc ff ff       	call   800d37 <duppage>
                     continue;
  8010b7:	eb 3e                	jmp    8010f7 <sfork+0xda>
                }

                // map same page to child env with same perms
                if (uvpt[pn] & PTE_P)
  8010b9:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  8010c0:	f6 c1 01             	test   $0x1,%cl
  8010c3:	74 32                	je     8010f7 <sfork+0xda>
                {
                    
                    perm = uvpt[pn] & ~(uvpt[pn] & ~(PTE_P |PTE_U | PTE_W | PTE_AVAIL));
  8010c5:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  8010cc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
                    if (sys_page_map(myenvid, (void *)(PGADDR(i, j, 0)),
  8010d3:	83 ec 0c             	sub    $0xc,%esp
  8010d6:	81 e2 f8 f1 ff ff    	and    $0xfffff1f8,%edx
  8010dc:	f7 d2                	not    %edx
  8010de:	21 d1                	and    %edx,%ecx
  8010e0:	51                   	push   %ecx
  8010e1:	50                   	push   %eax
  8010e2:	57                   	push   %edi
  8010e3:	50                   	push   %eax
  8010e4:	ff 75 e0             	pushl  -0x20(%ebp)
  8010e7:	e8 df fa ff ff       	call   800bcb <sys_page_map>
  8010ec:	83 c4 20             	add    $0x20,%esp
  8010ef:	85 c0                	test   %eax,%eax
  8010f1:	0f 88 bd 00 00 00    	js     8011b4 <sfork+0x197>
    // copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
        {
            for (j = 0; j < NPTENTRIES; j++)
  8010f7:	83 c3 01             	add    $0x1,%ebx
  8010fa:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801100:	75 92                	jne    801094 <sfork+0x77>
        thisenv = &envs[ENVX(sys_getenvid())];
        return envid;
    }

    // copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
  801102:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  801106:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801109:	3d bb 03 00 00       	cmp    $0x3bb,%eax
  80110e:	0f 85 6a ff ff ff    	jne    80107e <sfork+0x61>
            }
        }
    }

    // allocate new exception stack for child
    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
  801114:	83 ec 04             	sub    $0x4,%esp
  801117:	6a 07                	push   $0x7
  801119:	68 00 f0 bf ee       	push   $0xeebff000
  80111e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801121:	57                   	push   %edi
  801122:	e8 61 fa ff ff       	call   800b88 <sys_page_alloc>
  801127:	83 c4 10             	add    $0x10,%esp
  80112a:	85 c0                	test   %eax,%eax
  80112c:	0f 88 89 00 00 00    	js     8011bb <sfork+0x19e>
    {
        return -1;
    }

    // map child uxstack to temp page
    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  801132:	83 ec 0c             	sub    $0xc,%esp
  801135:	6a 07                	push   $0x7
  801137:	68 00 f0 7f 00       	push   $0x7ff000
  80113c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80113f:	56                   	push   %esi
  801140:	68 00 f0 bf ee       	push   $0xeebff000
  801145:	57                   	push   %edi
  801146:	e8 80 fa ff ff       	call   800bcb <sys_page_map>
  80114b:	83 c4 20             	add    $0x20,%esp
  80114e:	85 c0                	test   %eax,%eax
  801150:	78 70                	js     8011c2 <sfork+0x1a5>
    {
        return -1;
    }

    // copy own uxstack to temp page
    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);
  801152:	83 ec 04             	sub    $0x4,%esp
  801155:	68 00 10 00 00       	push   $0x1000
  80115a:	68 00 f0 7f 00       	push   $0x7ff000
  80115f:	68 00 f0 bf ee       	push   $0xeebff000
  801164:	e8 ae f7 ff ff       	call   800917 <memmove>

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
  801169:	83 c4 08             	add    $0x8,%esp
  80116c:	68 00 f0 7f 00       	push   $0x7ff000
  801171:	56                   	push   %esi
  801172:	e8 96 fa ff ff       	call   800c0d <sys_page_unmap>
  801177:	83 c4 10             	add    $0x10,%esp
  80117a:	85 c0                	test   %eax,%eax
  80117c:	78 4b                	js     8011c9 <sfork+0x1ac>
    {
        return -1;
    }

    // set page fault handler in child
    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
  80117e:	83 ec 08             	sub    $0x8,%esp
  801181:	68 8e 13 80 00       	push   $0x80138e
  801186:	57                   	push   %edi
  801187:	e8 05 fb ff ff       	call   800c91 <sys_env_set_pgfault_upcall>
  80118c:	83 c4 10             	add    $0x10,%esp
  80118f:	85 c0                	test   %eax,%eax
  801191:	78 3d                	js     8011d0 <sfork+0x1b3>
    {
        return -1;
    }

    // mark child env as RUNNABLE
    if(sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  801193:	83 ec 08             	sub    $0x8,%esp
  801196:	6a 02                	push   $0x2
  801198:	57                   	push   %edi
  801199:	e8 b1 fa ff ff       	call   800c4f <sys_env_set_status>
  80119e:	83 c4 10             	add    $0x10,%esp
    {
        return -1;
    }

    return envid;
  8011a1:	85 c0                	test   %eax,%eax
  8011a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8011a8:	0f 49 c7             	cmovns %edi,%eax
  8011ab:	eb 28                	jmp    8011d5 <sfork+0x1b8>
    set_pgfault_handler(pgfault);

    // create a child
    if((envid = sys_exofork()) < 0)
    {
        return -1;
  8011ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8011b2:	eb 21                	jmp    8011d5 <sfork+0x1b8>
                    
                    perm = uvpt[pn] & ~(uvpt[pn] & ~(PTE_P |PTE_U | PTE_W | PTE_AVAIL));
                    if (sys_page_map(myenvid, (void *)(PGADDR(i, j, 0)),
                                     envid,   (void *)(PGADDR(i, j, 0)), perm) < 0)
                    {
                        return -1;
  8011b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8011b9:	eb 1a                	jmp    8011d5 <sfork+0x1b8>
    }

    // allocate new exception stack for child
    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  8011bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8011c0:	eb 13                	jmp    8011d5 <sfork+0x1b8>
    }

    // map child uxstack to temp page
    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  8011c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8011c7:	eb 0c                	jmp    8011d5 <sfork+0x1b8>
    // copy own uxstack to temp page
    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
    {
        return -1;
  8011c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8011ce:	eb 05                	jmp    8011d5 <sfork+0x1b8>
    }

    // set page fault handler in child
    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
    {
        return -1;
  8011d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    {
        return -1;
    }

    return envid;
}
  8011d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d8:	5b                   	pop    %ebx
  8011d9:	5e                   	pop    %esi
  8011da:	5f                   	pop    %edi
  8011db:	5d                   	pop    %ebp
  8011dc:	c3                   	ret    

008011dd <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	57                   	push   %edi
  8011e1:	56                   	push   %esi
  8011e2:	53                   	push   %ebx
  8011e3:	83 ec 18             	sub    $0x18,%esp
  8011e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011ec:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
    int r = sys_ipc_recv((pg) ? pg : (void *)UTOP);
  8011ef:	85 db                	test   %ebx,%ebx
  8011f1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8011f6:	0f 45 c3             	cmovne %ebx,%eax
  8011f9:	50                   	push   %eax
  8011fa:	e8 f7 fa ff ff       	call   800cf6 <sys_ipc_recv>
  8011ff:	89 c2                	mov    %eax,%edx

    if (from_env_store)
  801201:	83 c4 10             	add    $0x10,%esp
  801204:	85 ff                	test   %edi,%edi
  801206:	74 13                	je     80121b <ipc_recv+0x3e>
    {
        *from_env_store = (r == 0) ? thisenv->env_ipc_from : 0;
  801208:	b8 00 00 00 00       	mov    $0x0,%eax
  80120d:	85 d2                	test   %edx,%edx
  80120f:	75 08                	jne    801219 <ipc_recv+0x3c>
  801211:	a1 08 20 80 00       	mov    0x802008,%eax
  801216:	8b 40 74             	mov    0x74(%eax),%eax
  801219:	89 07                	mov    %eax,(%edi)
    }

    if (perm_store)
  80121b:	85 f6                	test   %esi,%esi
  80121d:	74 1d                	je     80123c <ipc_recv+0x5f>
    {
        *perm_store = (r == 0 && (uint32_t) pg < UTOP) ? thisenv->env_ipc_perm : 0;
  80121f:	85 d2                	test   %edx,%edx
  801221:	75 12                	jne    801235 <ipc_recv+0x58>
  801223:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801229:	77 0a                	ja     801235 <ipc_recv+0x58>
  80122b:	a1 08 20 80 00       	mov    0x802008,%eax
  801230:	8b 40 78             	mov    0x78(%eax),%eax
  801233:	eb 05                	jmp    80123a <ipc_recv+0x5d>
  801235:	b8 00 00 00 00       	mov    $0x0,%eax
  80123a:	89 06                	mov    %eax,(%esi)
    }

    if (r)
    {
        return r;
  80123c:	89 d0                	mov    %edx,%eax
    if (perm_store)
    {
        *perm_store = (r == 0 && (uint32_t) pg < UTOP) ? thisenv->env_ipc_perm : 0;
    }

    if (r)
  80123e:	85 d2                	test   %edx,%edx
  801240:	75 08                	jne    80124a <ipc_recv+0x6d>
    {
        return r;
    }

    return thisenv->env_ipc_value;
  801242:	a1 08 20 80 00       	mov    0x802008,%eax
  801247:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  80124a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80124d:	5b                   	pop    %ebx
  80124e:	5e                   	pop    %esi
  80124f:	5f                   	pop    %edi
  801250:	5d                   	pop    %ebp
  801251:	c3                   	ret    

00801252 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	57                   	push   %edi
  801256:	56                   	push   %esi
  801257:	53                   	push   %ebx
  801258:	83 ec 0c             	sub    $0xc,%esp
  80125b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80125e:	8b 45 10             	mov    0x10(%ebp),%eax
  801261:	85 c0                	test   %eax,%eax
  801263:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
  801268:	0f 45 f0             	cmovne %eax,%esi
	// LAB 4: Your code here.
 
    int r = 0;
    do
    {
        r = sys_ipc_try_send(to_env, val, pg ? pg : (void *)UTOP, perm);
  80126b:	ff 75 14             	pushl  0x14(%ebp)
  80126e:	56                   	push   %esi
  80126f:	ff 75 0c             	pushl  0xc(%ebp)
  801272:	57                   	push   %edi
  801273:	e8 5b fa ff ff       	call   800cd3 <sys_ipc_try_send>
  801278:	89 c3                	mov    %eax,%ebx

        if (r != 0 && r != -E_IPC_NOT_RECV)
  80127a:	8d 40 08             	lea    0x8(%eax),%eax
  80127d:	83 c4 10             	add    $0x10,%esp
  801280:	a9 f7 ff ff ff       	test   $0xfffffff7,%eax
  801285:	74 12                	je     801299 <ipc_send+0x47>
        {
            panic("ipc_send: error %e", r);
  801287:	53                   	push   %ebx
  801288:	68 16 1a 80 00       	push   $0x801a16
  80128d:	6a 44                	push   $0x44
  80128f:	68 29 1a 80 00       	push   $0x801a29
  801294:	e8 4a 00 00 00       	call   8012e3 <_panic>
        }
        else
        {
            sys_yield();
  801299:	e8 cb f8 ff ff       	call   800b69 <sys_yield>
        }
    }while(r != 0);
  80129e:	85 db                	test   %ebx,%ebx
  8012a0:	75 c9                	jne    80126b <ipc_send+0x19>
	//panic("ipc_send not implemented");
}
  8012a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012a5:	5b                   	pop    %ebx
  8012a6:	5e                   	pop    %esi
  8012a7:	5f                   	pop    %edi
  8012a8:	5d                   	pop    %ebp
  8012a9:	c3                   	ret    

008012aa <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012aa:	55                   	push   %ebp
  8012ab:	89 e5                	mov    %esp,%ebp
  8012ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8012b0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8012b5:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8012b8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8012be:	8b 52 50             	mov    0x50(%edx),%edx
  8012c1:	39 ca                	cmp    %ecx,%edx
  8012c3:	75 0d                	jne    8012d2 <ipc_find_env+0x28>
			return envs[i].env_id;
  8012c5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012c8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012cd:	8b 40 48             	mov    0x48(%eax),%eax
  8012d0:	eb 0f                	jmp    8012e1 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8012d2:	83 c0 01             	add    $0x1,%eax
  8012d5:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012da:	75 d9                	jne    8012b5 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8012dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012e1:	5d                   	pop    %ebp
  8012e2:	c3                   	ret    

008012e3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	56                   	push   %esi
  8012e7:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8012e8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8012eb:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8012f1:	e8 54 f8 ff ff       	call   800b4a <sys_getenvid>
  8012f6:	83 ec 0c             	sub    $0xc,%esp
  8012f9:	ff 75 0c             	pushl  0xc(%ebp)
  8012fc:	ff 75 08             	pushl  0x8(%ebp)
  8012ff:	56                   	push   %esi
  801300:	50                   	push   %eax
  801301:	68 34 1a 80 00       	push   $0x801a34
  801306:	e8 de ee ff ff       	call   8001e9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80130b:	83 c4 18             	add    $0x18,%esp
  80130e:	53                   	push   %ebx
  80130f:	ff 75 10             	pushl  0x10(%ebp)
  801312:	e8 81 ee ff ff       	call   800198 <vcprintf>
	cprintf("\n");
  801317:	c7 04 24 78 16 80 00 	movl   $0x801678,(%esp)
  80131e:	e8 c6 ee ff ff       	call   8001e9 <cprintf>
  801323:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801326:	cc                   	int3   
  801327:	eb fd                	jmp    801326 <_panic+0x43>

00801329 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801329:	55                   	push   %ebp
  80132a:	89 e5                	mov    %esp,%ebp
  80132c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80132f:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801336:	75 4c                	jne    801384 <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.

        void *va = (void *)(UXSTACKTOP - PGSIZE);
        if (sys_page_alloc(thisenv->env_id, va, PTE_P | PTE_U | PTE_W))
  801338:	a1 08 20 80 00       	mov    0x802008,%eax
  80133d:	8b 40 48             	mov    0x48(%eax),%eax
  801340:	83 ec 04             	sub    $0x4,%esp
  801343:	6a 07                	push   $0x7
  801345:	68 00 f0 bf ee       	push   $0xeebff000
  80134a:	50                   	push   %eax
  80134b:	e8 38 f8 ff ff       	call   800b88 <sys_page_alloc>
  801350:	83 c4 10             	add    $0x10,%esp
  801353:	85 c0                	test   %eax,%eax
  801355:	74 14                	je     80136b <set_pgfault_handler+0x42>
        {
            panic("Unable to allocate memory for pgfault expected\n");
  801357:	83 ec 04             	sub    $0x4,%esp
  80135a:	68 58 1a 80 00       	push   $0x801a58
  80135f:	6a 24                	push   $0x24
  801361:	68 88 1a 80 00       	push   $0x801a88
  801366:	e8 78 ff ff ff       	call   8012e3 <_panic>
        }

        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  80136b:	a1 08 20 80 00       	mov    0x802008,%eax
  801370:	8b 40 48             	mov    0x48(%eax),%eax
  801373:	83 ec 08             	sub    $0x8,%esp
  801376:	68 8e 13 80 00       	push   $0x80138e
  80137b:	50                   	push   %eax
  80137c:	e8 10 f9 ff ff       	call   800c91 <sys_env_set_pgfault_upcall>
  801381:	83 c4 10             	add    $0x10,%esp

		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801384:	8b 45 08             	mov    0x8(%ebp),%eax
  801387:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  80138c:	c9                   	leave  
  80138d:	c3                   	ret    

0080138e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80138e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80138f:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  801394:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801396:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
    movl %esp, %ebx
  801399:	89 e3                	mov    %esp,%ebx
    // 40 is the size between utf_fault_va ~ utf_regs
    movl 40(%esp), %eax
  80139b:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 48(%esp), %esp
  80139f:	8b 64 24 30          	mov    0x30(%esp),%esp
    pushl %eax
  8013a3:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    movl %ebx, %esp
  8013a4:	89 dc                	mov    %ebx,%esp
    subl $4, 48(%esp)
  8013a6:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    popl %eax
  8013ab:	58                   	pop    %eax
    popl %eax
  8013ac:	58                   	pop    %eax
    popal
  8013ad:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  8013ae:	83 c4 04             	add    $0x4,%esp
    popfl
  8013b1:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp
  8013b2:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  8013b3:	c3                   	ret    
  8013b4:	66 90                	xchg   %ax,%ax
  8013b6:	66 90                	xchg   %ax,%ax
  8013b8:	66 90                	xchg   %ax,%ax
  8013ba:	66 90                	xchg   %ax,%ax
  8013bc:	66 90                	xchg   %ax,%ax
  8013be:	66 90                	xchg   %ax,%ax

008013c0 <__udivdi3>:
  8013c0:	55                   	push   %ebp
  8013c1:	57                   	push   %edi
  8013c2:	56                   	push   %esi
  8013c3:	53                   	push   %ebx
  8013c4:	83 ec 1c             	sub    $0x1c,%esp
  8013c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8013cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8013cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8013d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8013d7:	85 f6                	test   %esi,%esi
  8013d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013dd:	89 ca                	mov    %ecx,%edx
  8013df:	89 f8                	mov    %edi,%eax
  8013e1:	75 3d                	jne    801420 <__udivdi3+0x60>
  8013e3:	39 cf                	cmp    %ecx,%edi
  8013e5:	0f 87 c5 00 00 00    	ja     8014b0 <__udivdi3+0xf0>
  8013eb:	85 ff                	test   %edi,%edi
  8013ed:	89 fd                	mov    %edi,%ebp
  8013ef:	75 0b                	jne    8013fc <__udivdi3+0x3c>
  8013f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8013f6:	31 d2                	xor    %edx,%edx
  8013f8:	f7 f7                	div    %edi
  8013fa:	89 c5                	mov    %eax,%ebp
  8013fc:	89 c8                	mov    %ecx,%eax
  8013fe:	31 d2                	xor    %edx,%edx
  801400:	f7 f5                	div    %ebp
  801402:	89 c1                	mov    %eax,%ecx
  801404:	89 d8                	mov    %ebx,%eax
  801406:	89 cf                	mov    %ecx,%edi
  801408:	f7 f5                	div    %ebp
  80140a:	89 c3                	mov    %eax,%ebx
  80140c:	89 d8                	mov    %ebx,%eax
  80140e:	89 fa                	mov    %edi,%edx
  801410:	83 c4 1c             	add    $0x1c,%esp
  801413:	5b                   	pop    %ebx
  801414:	5e                   	pop    %esi
  801415:	5f                   	pop    %edi
  801416:	5d                   	pop    %ebp
  801417:	c3                   	ret    
  801418:	90                   	nop
  801419:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801420:	39 ce                	cmp    %ecx,%esi
  801422:	77 74                	ja     801498 <__udivdi3+0xd8>
  801424:	0f bd fe             	bsr    %esi,%edi
  801427:	83 f7 1f             	xor    $0x1f,%edi
  80142a:	0f 84 98 00 00 00    	je     8014c8 <__udivdi3+0x108>
  801430:	bb 20 00 00 00       	mov    $0x20,%ebx
  801435:	89 f9                	mov    %edi,%ecx
  801437:	89 c5                	mov    %eax,%ebp
  801439:	29 fb                	sub    %edi,%ebx
  80143b:	d3 e6                	shl    %cl,%esi
  80143d:	89 d9                	mov    %ebx,%ecx
  80143f:	d3 ed                	shr    %cl,%ebp
  801441:	89 f9                	mov    %edi,%ecx
  801443:	d3 e0                	shl    %cl,%eax
  801445:	09 ee                	or     %ebp,%esi
  801447:	89 d9                	mov    %ebx,%ecx
  801449:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80144d:	89 d5                	mov    %edx,%ebp
  80144f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801453:	d3 ed                	shr    %cl,%ebp
  801455:	89 f9                	mov    %edi,%ecx
  801457:	d3 e2                	shl    %cl,%edx
  801459:	89 d9                	mov    %ebx,%ecx
  80145b:	d3 e8                	shr    %cl,%eax
  80145d:	09 c2                	or     %eax,%edx
  80145f:	89 d0                	mov    %edx,%eax
  801461:	89 ea                	mov    %ebp,%edx
  801463:	f7 f6                	div    %esi
  801465:	89 d5                	mov    %edx,%ebp
  801467:	89 c3                	mov    %eax,%ebx
  801469:	f7 64 24 0c          	mull   0xc(%esp)
  80146d:	39 d5                	cmp    %edx,%ebp
  80146f:	72 10                	jb     801481 <__udivdi3+0xc1>
  801471:	8b 74 24 08          	mov    0x8(%esp),%esi
  801475:	89 f9                	mov    %edi,%ecx
  801477:	d3 e6                	shl    %cl,%esi
  801479:	39 c6                	cmp    %eax,%esi
  80147b:	73 07                	jae    801484 <__udivdi3+0xc4>
  80147d:	39 d5                	cmp    %edx,%ebp
  80147f:	75 03                	jne    801484 <__udivdi3+0xc4>
  801481:	83 eb 01             	sub    $0x1,%ebx
  801484:	31 ff                	xor    %edi,%edi
  801486:	89 d8                	mov    %ebx,%eax
  801488:	89 fa                	mov    %edi,%edx
  80148a:	83 c4 1c             	add    $0x1c,%esp
  80148d:	5b                   	pop    %ebx
  80148e:	5e                   	pop    %esi
  80148f:	5f                   	pop    %edi
  801490:	5d                   	pop    %ebp
  801491:	c3                   	ret    
  801492:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801498:	31 ff                	xor    %edi,%edi
  80149a:	31 db                	xor    %ebx,%ebx
  80149c:	89 d8                	mov    %ebx,%eax
  80149e:	89 fa                	mov    %edi,%edx
  8014a0:	83 c4 1c             	add    $0x1c,%esp
  8014a3:	5b                   	pop    %ebx
  8014a4:	5e                   	pop    %esi
  8014a5:	5f                   	pop    %edi
  8014a6:	5d                   	pop    %ebp
  8014a7:	c3                   	ret    
  8014a8:	90                   	nop
  8014a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014b0:	89 d8                	mov    %ebx,%eax
  8014b2:	f7 f7                	div    %edi
  8014b4:	31 ff                	xor    %edi,%edi
  8014b6:	89 c3                	mov    %eax,%ebx
  8014b8:	89 d8                	mov    %ebx,%eax
  8014ba:	89 fa                	mov    %edi,%edx
  8014bc:	83 c4 1c             	add    $0x1c,%esp
  8014bf:	5b                   	pop    %ebx
  8014c0:	5e                   	pop    %esi
  8014c1:	5f                   	pop    %edi
  8014c2:	5d                   	pop    %ebp
  8014c3:	c3                   	ret    
  8014c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014c8:	39 ce                	cmp    %ecx,%esi
  8014ca:	72 0c                	jb     8014d8 <__udivdi3+0x118>
  8014cc:	31 db                	xor    %ebx,%ebx
  8014ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8014d2:	0f 87 34 ff ff ff    	ja     80140c <__udivdi3+0x4c>
  8014d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8014dd:	e9 2a ff ff ff       	jmp    80140c <__udivdi3+0x4c>
  8014e2:	66 90                	xchg   %ax,%ax
  8014e4:	66 90                	xchg   %ax,%ax
  8014e6:	66 90                	xchg   %ax,%ax
  8014e8:	66 90                	xchg   %ax,%ax
  8014ea:	66 90                	xchg   %ax,%ax
  8014ec:	66 90                	xchg   %ax,%ax
  8014ee:	66 90                	xchg   %ax,%ax

008014f0 <__umoddi3>:
  8014f0:	55                   	push   %ebp
  8014f1:	57                   	push   %edi
  8014f2:	56                   	push   %esi
  8014f3:	53                   	push   %ebx
  8014f4:	83 ec 1c             	sub    $0x1c,%esp
  8014f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8014fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8014ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  801503:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801507:	85 d2                	test   %edx,%edx
  801509:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80150d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801511:	89 f3                	mov    %esi,%ebx
  801513:	89 3c 24             	mov    %edi,(%esp)
  801516:	89 74 24 04          	mov    %esi,0x4(%esp)
  80151a:	75 1c                	jne    801538 <__umoddi3+0x48>
  80151c:	39 f7                	cmp    %esi,%edi
  80151e:	76 50                	jbe    801570 <__umoddi3+0x80>
  801520:	89 c8                	mov    %ecx,%eax
  801522:	89 f2                	mov    %esi,%edx
  801524:	f7 f7                	div    %edi
  801526:	89 d0                	mov    %edx,%eax
  801528:	31 d2                	xor    %edx,%edx
  80152a:	83 c4 1c             	add    $0x1c,%esp
  80152d:	5b                   	pop    %ebx
  80152e:	5e                   	pop    %esi
  80152f:	5f                   	pop    %edi
  801530:	5d                   	pop    %ebp
  801531:	c3                   	ret    
  801532:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801538:	39 f2                	cmp    %esi,%edx
  80153a:	89 d0                	mov    %edx,%eax
  80153c:	77 52                	ja     801590 <__umoddi3+0xa0>
  80153e:	0f bd ea             	bsr    %edx,%ebp
  801541:	83 f5 1f             	xor    $0x1f,%ebp
  801544:	75 5a                	jne    8015a0 <__umoddi3+0xb0>
  801546:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80154a:	0f 82 e0 00 00 00    	jb     801630 <__umoddi3+0x140>
  801550:	39 0c 24             	cmp    %ecx,(%esp)
  801553:	0f 86 d7 00 00 00    	jbe    801630 <__umoddi3+0x140>
  801559:	8b 44 24 08          	mov    0x8(%esp),%eax
  80155d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801561:	83 c4 1c             	add    $0x1c,%esp
  801564:	5b                   	pop    %ebx
  801565:	5e                   	pop    %esi
  801566:	5f                   	pop    %edi
  801567:	5d                   	pop    %ebp
  801568:	c3                   	ret    
  801569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801570:	85 ff                	test   %edi,%edi
  801572:	89 fd                	mov    %edi,%ebp
  801574:	75 0b                	jne    801581 <__umoddi3+0x91>
  801576:	b8 01 00 00 00       	mov    $0x1,%eax
  80157b:	31 d2                	xor    %edx,%edx
  80157d:	f7 f7                	div    %edi
  80157f:	89 c5                	mov    %eax,%ebp
  801581:	89 f0                	mov    %esi,%eax
  801583:	31 d2                	xor    %edx,%edx
  801585:	f7 f5                	div    %ebp
  801587:	89 c8                	mov    %ecx,%eax
  801589:	f7 f5                	div    %ebp
  80158b:	89 d0                	mov    %edx,%eax
  80158d:	eb 99                	jmp    801528 <__umoddi3+0x38>
  80158f:	90                   	nop
  801590:	89 c8                	mov    %ecx,%eax
  801592:	89 f2                	mov    %esi,%edx
  801594:	83 c4 1c             	add    $0x1c,%esp
  801597:	5b                   	pop    %ebx
  801598:	5e                   	pop    %esi
  801599:	5f                   	pop    %edi
  80159a:	5d                   	pop    %ebp
  80159b:	c3                   	ret    
  80159c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015a0:	8b 34 24             	mov    (%esp),%esi
  8015a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8015a8:	89 e9                	mov    %ebp,%ecx
  8015aa:	29 ef                	sub    %ebp,%edi
  8015ac:	d3 e0                	shl    %cl,%eax
  8015ae:	89 f9                	mov    %edi,%ecx
  8015b0:	89 f2                	mov    %esi,%edx
  8015b2:	d3 ea                	shr    %cl,%edx
  8015b4:	89 e9                	mov    %ebp,%ecx
  8015b6:	09 c2                	or     %eax,%edx
  8015b8:	89 d8                	mov    %ebx,%eax
  8015ba:	89 14 24             	mov    %edx,(%esp)
  8015bd:	89 f2                	mov    %esi,%edx
  8015bf:	d3 e2                	shl    %cl,%edx
  8015c1:	89 f9                	mov    %edi,%ecx
  8015c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8015cb:	d3 e8                	shr    %cl,%eax
  8015cd:	89 e9                	mov    %ebp,%ecx
  8015cf:	89 c6                	mov    %eax,%esi
  8015d1:	d3 e3                	shl    %cl,%ebx
  8015d3:	89 f9                	mov    %edi,%ecx
  8015d5:	89 d0                	mov    %edx,%eax
  8015d7:	d3 e8                	shr    %cl,%eax
  8015d9:	89 e9                	mov    %ebp,%ecx
  8015db:	09 d8                	or     %ebx,%eax
  8015dd:	89 d3                	mov    %edx,%ebx
  8015df:	89 f2                	mov    %esi,%edx
  8015e1:	f7 34 24             	divl   (%esp)
  8015e4:	89 d6                	mov    %edx,%esi
  8015e6:	d3 e3                	shl    %cl,%ebx
  8015e8:	f7 64 24 04          	mull   0x4(%esp)
  8015ec:	39 d6                	cmp    %edx,%esi
  8015ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015f2:	89 d1                	mov    %edx,%ecx
  8015f4:	89 c3                	mov    %eax,%ebx
  8015f6:	72 08                	jb     801600 <__umoddi3+0x110>
  8015f8:	75 11                	jne    80160b <__umoddi3+0x11b>
  8015fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8015fe:	73 0b                	jae    80160b <__umoddi3+0x11b>
  801600:	2b 44 24 04          	sub    0x4(%esp),%eax
  801604:	1b 14 24             	sbb    (%esp),%edx
  801607:	89 d1                	mov    %edx,%ecx
  801609:	89 c3                	mov    %eax,%ebx
  80160b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80160f:	29 da                	sub    %ebx,%edx
  801611:	19 ce                	sbb    %ecx,%esi
  801613:	89 f9                	mov    %edi,%ecx
  801615:	89 f0                	mov    %esi,%eax
  801617:	d3 e0                	shl    %cl,%eax
  801619:	89 e9                	mov    %ebp,%ecx
  80161b:	d3 ea                	shr    %cl,%edx
  80161d:	89 e9                	mov    %ebp,%ecx
  80161f:	d3 ee                	shr    %cl,%esi
  801621:	09 d0                	or     %edx,%eax
  801623:	89 f2                	mov    %esi,%edx
  801625:	83 c4 1c             	add    $0x1c,%esp
  801628:	5b                   	pop    %ebx
  801629:	5e                   	pop    %esi
  80162a:	5f                   	pop    %edi
  80162b:	5d                   	pop    %ebp
  80162c:	c3                   	ret    
  80162d:	8d 76 00             	lea    0x0(%esi),%esi
  801630:	29 f9                	sub    %edi,%ecx
  801632:	19 d6                	sbb    %edx,%esi
  801634:	89 74 24 04          	mov    %esi,0x4(%esp)
  801638:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80163c:	e9 18 ff ff ff       	jmp    801559 <__umoddi3+0x69>
