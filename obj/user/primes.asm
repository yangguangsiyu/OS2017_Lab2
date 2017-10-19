
obj/user/primes：     文件格式 elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 d1 11 00 00       	call   80121d <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 20 80 00       	mov    0x802004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 40 16 80 00       	push   $0x801640
  800060:	e8 c4 01 00 00       	call   800229 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 81 0e 00 00       	call   800eeb <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 4c 16 80 00       	push   $0x80164c
  800079:	6a 1a                	push   $0x1a
  80007b:	68 55 16 80 00       	push   $0x801655
  800080:	e8 cb 00 00 00       	call   800150 <_panic>
	if (id == 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	74 b6                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800089:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80008c:	83 ec 04             	sub    $0x4,%esp
  80008f:	6a 00                	push   $0x0
  800091:	6a 00                	push   $0x0
  800093:	56                   	push   %esi
  800094:	e8 84 11 00 00       	call   80121d <ipc_recv>
  800099:	89 c1                	mov    %eax,%ecx
		if (i % p)
  80009b:	99                   	cltd   
  80009c:	f7 fb                	idiv   %ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	85 d2                	test   %edx,%edx
  8000a3:	74 e7                	je     80008c <primeproc+0x59>
			ipc_send(id, i, 0, 0);
  8000a5:	6a 00                	push   $0x0
  8000a7:	6a 00                	push   $0x0
  8000a9:	51                   	push   %ecx
  8000aa:	57                   	push   %edi
  8000ab:	e8 e2 11 00 00       	call   801292 <ipc_send>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	eb d7                	jmp    80008c <primeproc+0x59>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 2c 0e 00 00       	call   800eeb <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 4c 16 80 00       	push   $0x80164c
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 55 16 80 00       	push   $0x801655
  8000d2:	e8 79 00 00 00       	call   800150 <_panic>
  8000d7:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	75 05                	jne    8000e5 <umain+0x30>
		primeproc();
  8000e0:	e8 4e ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  8000e5:	6a 00                	push   $0x0
  8000e7:	6a 00                	push   $0x0
  8000e9:	53                   	push   %ebx
  8000ea:	56                   	push   %esi
  8000eb:	e8 a2 11 00 00       	call   801292 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000f0:	83 c3 01             	add    $0x1,%ebx
  8000f3:	83 c4 10             	add    $0x10,%esp
  8000f6:	eb ed                	jmp    8000e5 <umain+0x30>

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800100:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800103:	e8 82 0a 00 00       	call   800b8a <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800110:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800115:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011a:	85 db                	test   %ebx,%ebx
  80011c:	7e 07                	jle    800125 <libmain+0x2d>
		binaryname = argv[0];
  80011e:	8b 06                	mov    (%esi),%eax
  800120:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	e8 86 ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  80012f:	e8 0a 00 00 00       	call   80013e <exit>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5d                   	pop    %ebp
  80013d:	c3                   	ret    

0080013e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800144:	6a 00                	push   $0x0
  800146:	e8 fe 09 00 00       	call   800b49 <sys_env_destroy>
}
  80014b:	83 c4 10             	add    $0x10,%esp
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    

00800150 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800155:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800158:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80015e:	e8 27 0a 00 00       	call   800b8a <sys_getenvid>
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	ff 75 0c             	pushl  0xc(%ebp)
  800169:	ff 75 08             	pushl  0x8(%ebp)
  80016c:	56                   	push   %esi
  80016d:	50                   	push   %eax
  80016e:	68 70 16 80 00       	push   $0x801670
  800173:	e8 b1 00 00 00       	call   800229 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800178:	83 c4 18             	add    $0x18,%esp
  80017b:	53                   	push   %ebx
  80017c:	ff 75 10             	pushl  0x10(%ebp)
  80017f:	e8 54 00 00 00       	call   8001d8 <vcprintf>
	cprintf("\n");
  800184:	c7 04 24 93 16 80 00 	movl   $0x801693,(%esp)
  80018b:	e8 99 00 00 00       	call   800229 <cprintf>
  800190:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800193:	cc                   	int3   
  800194:	eb fd                	jmp    800193 <_panic+0x43>

00800196 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	53                   	push   %ebx
  80019a:	83 ec 04             	sub    $0x4,%esp
  80019d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a0:	8b 13                	mov    (%ebx),%edx
  8001a2:	8d 42 01             	lea    0x1(%edx),%eax
  8001a5:	89 03                	mov    %eax,(%ebx)
  8001a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001aa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b3:	75 1a                	jne    8001cf <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b5:	83 ec 08             	sub    $0x8,%esp
  8001b8:	68 ff 00 00 00       	push   $0xff
  8001bd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c0:	50                   	push   %eax
  8001c1:	e8 46 09 00 00       	call   800b0c <sys_cputs>
		b->idx = 0;
  8001c6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001cc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001cf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e8:	00 00 00 
	b.cnt = 0;
  8001eb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f5:	ff 75 0c             	pushl  0xc(%ebp)
  8001f8:	ff 75 08             	pushl  0x8(%ebp)
  8001fb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800201:	50                   	push   %eax
  800202:	68 96 01 80 00       	push   $0x800196
  800207:	e8 54 01 00 00       	call   800360 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80020c:	83 c4 08             	add    $0x8,%esp
  80020f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800215:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80021b:	50                   	push   %eax
  80021c:	e8 eb 08 00 00       	call   800b0c <sys_cputs>

	return b.cnt;
}
  800221:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800232:	50                   	push   %eax
  800233:	ff 75 08             	pushl  0x8(%ebp)
  800236:	e8 9d ff ff ff       	call   8001d8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80023b:	c9                   	leave  
  80023c:	c3                   	ret    

0080023d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023d:	55                   	push   %ebp
  80023e:	89 e5                	mov    %esp,%ebp
  800240:	57                   	push   %edi
  800241:	56                   	push   %esi
  800242:	53                   	push   %ebx
  800243:	83 ec 1c             	sub    $0x1c,%esp
  800246:	89 c7                	mov    %eax,%edi
  800248:	89 d6                	mov    %edx,%esi
  80024a:	8b 45 08             	mov    0x8(%ebp),%eax
  80024d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800250:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800253:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800256:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800259:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800261:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800264:	39 d3                	cmp    %edx,%ebx
  800266:	72 05                	jb     80026d <printnum+0x30>
  800268:	39 45 10             	cmp    %eax,0x10(%ebp)
  80026b:	77 45                	ja     8002b2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026d:	83 ec 0c             	sub    $0xc,%esp
  800270:	ff 75 18             	pushl  0x18(%ebp)
  800273:	8b 45 14             	mov    0x14(%ebp),%eax
  800276:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800279:	53                   	push   %ebx
  80027a:	ff 75 10             	pushl  0x10(%ebp)
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	ff 75 e4             	pushl  -0x1c(%ebp)
  800283:	ff 75 e0             	pushl  -0x20(%ebp)
  800286:	ff 75 dc             	pushl  -0x24(%ebp)
  800289:	ff 75 d8             	pushl  -0x28(%ebp)
  80028c:	e8 1f 11 00 00       	call   8013b0 <__udivdi3>
  800291:	83 c4 18             	add    $0x18,%esp
  800294:	52                   	push   %edx
  800295:	50                   	push   %eax
  800296:	89 f2                	mov    %esi,%edx
  800298:	89 f8                	mov    %edi,%eax
  80029a:	e8 9e ff ff ff       	call   80023d <printnum>
  80029f:	83 c4 20             	add    $0x20,%esp
  8002a2:	eb 18                	jmp    8002bc <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a4:	83 ec 08             	sub    $0x8,%esp
  8002a7:	56                   	push   %esi
  8002a8:	ff 75 18             	pushl  0x18(%ebp)
  8002ab:	ff d7                	call   *%edi
  8002ad:	83 c4 10             	add    $0x10,%esp
  8002b0:	eb 03                	jmp    8002b5 <printnum+0x78>
  8002b2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b5:	83 eb 01             	sub    $0x1,%ebx
  8002b8:	85 db                	test   %ebx,%ebx
  8002ba:	7f e8                	jg     8002a4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002bc:	83 ec 08             	sub    $0x8,%esp
  8002bf:	56                   	push   %esi
  8002c0:	83 ec 04             	sub    $0x4,%esp
  8002c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cf:	e8 0c 12 00 00       	call   8014e0 <__umoddi3>
  8002d4:	83 c4 14             	add    $0x14,%esp
  8002d7:	0f be 80 95 16 80 00 	movsbl 0x801695(%eax),%eax
  8002de:	50                   	push   %eax
  8002df:	ff d7                	call   *%edi
}
  8002e1:	83 c4 10             	add    $0x10,%esp
  8002e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e7:	5b                   	pop    %ebx
  8002e8:	5e                   	pop    %esi
  8002e9:	5f                   	pop    %edi
  8002ea:	5d                   	pop    %ebp
  8002eb:	c3                   	ret    

008002ec <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ef:	83 fa 01             	cmp    $0x1,%edx
  8002f2:	7e 0e                	jle    800302 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f4:	8b 10                	mov    (%eax),%edx
  8002f6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f9:	89 08                	mov    %ecx,(%eax)
  8002fb:	8b 02                	mov    (%edx),%eax
  8002fd:	8b 52 04             	mov    0x4(%edx),%edx
  800300:	eb 22                	jmp    800324 <getuint+0x38>
	else if (lflag)
  800302:	85 d2                	test   %edx,%edx
  800304:	74 10                	je     800316 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800306:	8b 10                	mov    (%eax),%edx
  800308:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030b:	89 08                	mov    %ecx,(%eax)
  80030d:	8b 02                	mov    (%edx),%eax
  80030f:	ba 00 00 00 00       	mov    $0x0,%edx
  800314:	eb 0e                	jmp    800324 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800316:	8b 10                	mov    (%eax),%edx
  800318:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031b:	89 08                	mov    %ecx,(%eax)
  80031d:	8b 02                	mov    (%edx),%eax
  80031f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800324:	5d                   	pop    %ebp
  800325:	c3                   	ret    

00800326 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
  800329:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80032c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800330:	8b 10                	mov    (%eax),%edx
  800332:	3b 50 04             	cmp    0x4(%eax),%edx
  800335:	73 0a                	jae    800341 <sprintputch+0x1b>
		*b->buf++ = ch;
  800337:	8d 4a 01             	lea    0x1(%edx),%ecx
  80033a:	89 08                	mov    %ecx,(%eax)
  80033c:	8b 45 08             	mov    0x8(%ebp),%eax
  80033f:	88 02                	mov    %al,(%edx)
}
  800341:	5d                   	pop    %ebp
  800342:	c3                   	ret    

00800343 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
  800346:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800349:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80034c:	50                   	push   %eax
  80034d:	ff 75 10             	pushl  0x10(%ebp)
  800350:	ff 75 0c             	pushl  0xc(%ebp)
  800353:	ff 75 08             	pushl  0x8(%ebp)
  800356:	e8 05 00 00 00       	call   800360 <vprintfmt>
	va_end(ap);
}
  80035b:	83 c4 10             	add    $0x10,%esp
  80035e:	c9                   	leave  
  80035f:	c3                   	ret    

00800360 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	57                   	push   %edi
  800364:	56                   	push   %esi
  800365:	53                   	push   %ebx
  800366:	83 ec 2c             	sub    $0x2c,%esp
  800369:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
  80036c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800373:	eb 17                	jmp    80038c <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800375:	85 c0                	test   %eax,%eax
  800377:	0f 84 9f 03 00 00    	je     80071c <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
  80037d:	83 ec 08             	sub    $0x8,%esp
  800380:	ff 75 0c             	pushl  0xc(%ebp)
  800383:	50                   	push   %eax
  800384:	ff 55 08             	call   *0x8(%ebp)
  800387:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038a:	89 f3                	mov    %esi,%ebx
  80038c:	8d 73 01             	lea    0x1(%ebx),%esi
  80038f:	0f b6 03             	movzbl (%ebx),%eax
  800392:	83 f8 25             	cmp    $0x25,%eax
  800395:	75 de                	jne    800375 <vprintfmt+0x15>
  800397:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80039b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003a2:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003a7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b3:	eb 06                	jmp    8003bb <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b7:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bb:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003be:	0f b6 06             	movzbl (%esi),%eax
  8003c1:	0f b6 c8             	movzbl %al,%ecx
  8003c4:	83 e8 23             	sub    $0x23,%eax
  8003c7:	3c 55                	cmp    $0x55,%al
  8003c9:	0f 87 2d 03 00 00    	ja     8006fc <vprintfmt+0x39c>
  8003cf:	0f b6 c0             	movzbl %al,%eax
  8003d2:	ff 24 85 60 17 80 00 	jmp    *0x801760(,%eax,4)
  8003d9:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003db:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003df:	eb da                	jmp    8003bb <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	89 de                	mov    %ebx,%esi
  8003e3:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003e8:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  8003eb:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  8003ef:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  8003f2:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8003f5:	83 f8 09             	cmp    $0x9,%eax
  8003f8:	77 33                	ja     80042d <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003fa:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003fd:	eb e9                	jmp    8003e8 <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800402:	8d 48 04             	lea    0x4(%eax),%ecx
  800405:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800408:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80040c:	eb 1f                	jmp    80042d <vprintfmt+0xcd>
  80040e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800411:	85 c0                	test   %eax,%eax
  800413:	b9 00 00 00 00       	mov    $0x0,%ecx
  800418:	0f 49 c8             	cmovns %eax,%ecx
  80041b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	89 de                	mov    %ebx,%esi
  800420:	eb 99                	jmp    8003bb <vprintfmt+0x5b>
  800422:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800424:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  80042b:	eb 8e                	jmp    8003bb <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80042d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800431:	79 88                	jns    8003bb <vprintfmt+0x5b>
				width = precision, precision = -1;
  800433:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800436:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80043b:	e9 7b ff ff ff       	jmp    8003bb <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800440:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800443:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800445:	e9 71 ff ff ff       	jmp    8003bb <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
  80044a:	8b 45 14             	mov    0x14(%ebp),%eax
  80044d:	8d 50 04             	lea    0x4(%eax),%edx
  800450:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  800453:	83 ec 08             	sub    $0x8,%esp
  800456:	ff 75 0c             	pushl  0xc(%ebp)
  800459:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80045c:	03 08                	add    (%eax),%ecx
  80045e:	51                   	push   %ecx
  80045f:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
  800462:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
  800465:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
  80046c:	e9 1b ff ff ff       	jmp    80038c <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
  800471:	8b 45 14             	mov    0x14(%ebp),%eax
  800474:	8d 48 04             	lea    0x4(%eax),%ecx
  800477:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80047a:	8b 00                	mov    (%eax),%eax
  80047c:	83 f8 02             	cmp    $0x2,%eax
  80047f:	74 1a                	je     80049b <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800481:	89 de                	mov    %ebx,%esi
  800483:	83 f8 04             	cmp    $0x4,%eax
  800486:	b8 00 00 00 00       	mov    $0x0,%eax
  80048b:	b9 00 04 00 00       	mov    $0x400,%ecx
  800490:	0f 44 c1             	cmove  %ecx,%eax
  800493:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800496:	e9 20 ff ff ff       	jmp    8003bb <vprintfmt+0x5b>
  80049b:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
  80049d:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
  8004a4:	e9 12 ff ff ff       	jmp    8003bb <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8d 50 04             	lea    0x4(%eax),%edx
  8004af:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b2:	8b 00                	mov    (%eax),%eax
  8004b4:	99                   	cltd   
  8004b5:	31 d0                	xor    %edx,%eax
  8004b7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b9:	83 f8 09             	cmp    $0x9,%eax
  8004bc:	7f 0b                	jg     8004c9 <vprintfmt+0x169>
  8004be:	8b 14 85 c0 18 80 00 	mov    0x8018c0(,%eax,4),%edx
  8004c5:	85 d2                	test   %edx,%edx
  8004c7:	75 19                	jne    8004e2 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  8004c9:	50                   	push   %eax
  8004ca:	68 ad 16 80 00       	push   $0x8016ad
  8004cf:	ff 75 0c             	pushl  0xc(%ebp)
  8004d2:	ff 75 08             	pushl  0x8(%ebp)
  8004d5:	e8 69 fe ff ff       	call   800343 <printfmt>
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	e9 aa fe ff ff       	jmp    80038c <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  8004e2:	52                   	push   %edx
  8004e3:	68 b6 16 80 00       	push   $0x8016b6
  8004e8:	ff 75 0c             	pushl  0xc(%ebp)
  8004eb:	ff 75 08             	pushl  0x8(%ebp)
  8004ee:	e8 50 fe ff ff       	call   800343 <printfmt>
  8004f3:	83 c4 10             	add    $0x10,%esp
  8004f6:	e9 91 fe ff ff       	jmp    80038c <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fe:	8d 50 04             	lea    0x4(%eax),%edx
  800501:	89 55 14             	mov    %edx,0x14(%ebp)
  800504:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800506:	85 f6                	test   %esi,%esi
  800508:	b8 a6 16 80 00       	mov    $0x8016a6,%eax
  80050d:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800510:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800514:	0f 8e 93 00 00 00    	jle    8005ad <vprintfmt+0x24d>
  80051a:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80051e:	0f 84 91 00 00 00    	je     8005b5 <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
  800524:	83 ec 08             	sub    $0x8,%esp
  800527:	57                   	push   %edi
  800528:	56                   	push   %esi
  800529:	e8 76 02 00 00       	call   8007a4 <strnlen>
  80052e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800531:	29 c1                	sub    %eax,%ecx
  800533:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800536:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800539:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  80053d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800540:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800543:	8b 75 0c             	mov    0xc(%ebp),%esi
  800546:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800549:	89 cb                	mov    %ecx,%ebx
  80054b:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80054d:	eb 0e                	jmp    80055d <vprintfmt+0x1fd>
					putch(padc, putdat);
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	56                   	push   %esi
  800553:	57                   	push   %edi
  800554:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800557:	83 eb 01             	sub    $0x1,%ebx
  80055a:	83 c4 10             	add    $0x10,%esp
  80055d:	85 db                	test   %ebx,%ebx
  80055f:	7f ee                	jg     80054f <vprintfmt+0x1ef>
  800561:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800564:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800567:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80056a:	85 c9                	test   %ecx,%ecx
  80056c:	b8 00 00 00 00       	mov    $0x0,%eax
  800571:	0f 49 c1             	cmovns %ecx,%eax
  800574:	29 c1                	sub    %eax,%ecx
  800576:	89 cb                	mov    %ecx,%ebx
  800578:	eb 41                	jmp    8005bb <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80057a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80057e:	74 1b                	je     80059b <vprintfmt+0x23b>
  800580:	0f be c0             	movsbl %al,%eax
  800583:	83 e8 20             	sub    $0x20,%eax
  800586:	83 f8 5e             	cmp    $0x5e,%eax
  800589:	76 10                	jbe    80059b <vprintfmt+0x23b>
					putch('?', putdat);
  80058b:	83 ec 08             	sub    $0x8,%esp
  80058e:	ff 75 0c             	pushl  0xc(%ebp)
  800591:	6a 3f                	push   $0x3f
  800593:	ff 55 08             	call   *0x8(%ebp)
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	eb 0d                	jmp    8005a8 <vprintfmt+0x248>
				else
					putch(ch, putdat);
  80059b:	83 ec 08             	sub    $0x8,%esp
  80059e:	ff 75 0c             	pushl  0xc(%ebp)
  8005a1:	52                   	push   %edx
  8005a2:	ff 55 08             	call   *0x8(%ebp)
  8005a5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a8:	83 eb 01             	sub    $0x1,%ebx
  8005ab:	eb 0e                	jmp    8005bb <vprintfmt+0x25b>
  8005ad:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005b0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005b3:	eb 06                	jmp    8005bb <vprintfmt+0x25b>
  8005b5:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005b8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005bb:	83 c6 01             	add    $0x1,%esi
  8005be:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8005c2:	0f be d0             	movsbl %al,%edx
  8005c5:	85 d2                	test   %edx,%edx
  8005c7:	74 25                	je     8005ee <vprintfmt+0x28e>
  8005c9:	85 ff                	test   %edi,%edi
  8005cb:	78 ad                	js     80057a <vprintfmt+0x21a>
  8005cd:	83 ef 01             	sub    $0x1,%edi
  8005d0:	79 a8                	jns    80057a <vprintfmt+0x21a>
  8005d2:	89 d8                	mov    %ebx,%eax
  8005d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005da:	89 c3                	mov    %eax,%ebx
  8005dc:	eb 16                	jmp    8005f4 <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005de:	83 ec 08             	sub    $0x8,%esp
  8005e1:	57                   	push   %edi
  8005e2:	6a 20                	push   $0x20
  8005e4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005e6:	83 eb 01             	sub    $0x1,%ebx
  8005e9:	83 c4 10             	add    $0x10,%esp
  8005ec:	eb 06                	jmp    8005f4 <vprintfmt+0x294>
  8005ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8005f1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005f4:	85 db                	test   %ebx,%ebx
  8005f6:	7f e6                	jg     8005de <vprintfmt+0x27e>
  8005f8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005fb:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800601:	e9 86 fd ff ff       	jmp    80038c <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800606:	83 fa 01             	cmp    $0x1,%edx
  800609:	7e 10                	jle    80061b <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8d 50 08             	lea    0x8(%eax),%edx
  800611:	89 55 14             	mov    %edx,0x14(%ebp)
  800614:	8b 30                	mov    (%eax),%esi
  800616:	8b 78 04             	mov    0x4(%eax),%edi
  800619:	eb 26                	jmp    800641 <vprintfmt+0x2e1>
	else if (lflag)
  80061b:	85 d2                	test   %edx,%edx
  80061d:	74 12                	je     800631 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  80061f:	8b 45 14             	mov    0x14(%ebp),%eax
  800622:	8d 50 04             	lea    0x4(%eax),%edx
  800625:	89 55 14             	mov    %edx,0x14(%ebp)
  800628:	8b 30                	mov    (%eax),%esi
  80062a:	89 f7                	mov    %esi,%edi
  80062c:	c1 ff 1f             	sar    $0x1f,%edi
  80062f:	eb 10                	jmp    800641 <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8d 50 04             	lea    0x4(%eax),%edx
  800637:	89 55 14             	mov    %edx,0x14(%ebp)
  80063a:	8b 30                	mov    (%eax),%esi
  80063c:	89 f7                	mov    %esi,%edi
  80063e:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800641:	89 f0                	mov    %esi,%eax
  800643:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800645:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80064a:	85 ff                	test   %edi,%edi
  80064c:	79 7b                	jns    8006c9 <vprintfmt+0x369>
				putch('-', putdat);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	ff 75 0c             	pushl  0xc(%ebp)
  800654:	6a 2d                	push   $0x2d
  800656:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800659:	89 f0                	mov    %esi,%eax
  80065b:	89 fa                	mov    %edi,%edx
  80065d:	f7 d8                	neg    %eax
  80065f:	83 d2 00             	adc    $0x0,%edx
  800662:	f7 da                	neg    %edx
  800664:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800667:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80066c:	eb 5b                	jmp    8006c9 <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80066e:	8d 45 14             	lea    0x14(%ebp),%eax
  800671:	e8 76 fc ff ff       	call   8002ec <getuint>
			base = 10;
  800676:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80067b:	eb 4c                	jmp    8006c9 <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
  80067d:	8d 45 14             	lea    0x14(%ebp),%eax
  800680:	e8 67 fc ff ff       	call   8002ec <getuint>
            base = 8;
  800685:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80068a:	eb 3d                	jmp    8006c9 <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
  80068c:	83 ec 08             	sub    $0x8,%esp
  80068f:	ff 75 0c             	pushl  0xc(%ebp)
  800692:	6a 30                	push   $0x30
  800694:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800697:	83 c4 08             	add    $0x8,%esp
  80069a:	ff 75 0c             	pushl  0xc(%ebp)
  80069d:	6a 78                	push   $0x78
  80069f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8d 50 04             	lea    0x4(%eax),%edx
  8006a8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006ab:	8b 00                	mov    (%eax),%eax
  8006ad:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006b2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b5:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006ba:	eb 0d                	jmp    8006c9 <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006bc:	8d 45 14             	lea    0x14(%ebp),%eax
  8006bf:	e8 28 fc ff ff       	call   8002ec <getuint>
			base = 16;
  8006c4:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c9:	83 ec 0c             	sub    $0xc,%esp
  8006cc:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  8006d0:	56                   	push   %esi
  8006d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d4:	51                   	push   %ecx
  8006d5:	52                   	push   %edx
  8006d6:	50                   	push   %eax
  8006d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006da:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dd:	e8 5b fb ff ff       	call   80023d <printnum>
			break;
  8006e2:	83 c4 20             	add    $0x20,%esp
  8006e5:	e9 a2 fc ff ff       	jmp    80038c <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ea:	83 ec 08             	sub    $0x8,%esp
  8006ed:	ff 75 0c             	pushl  0xc(%ebp)
  8006f0:	51                   	push   %ecx
  8006f1:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006f4:	83 c4 10             	add    $0x10,%esp
  8006f7:	e9 90 fc ff ff       	jmp    80038c <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006fc:	83 ec 08             	sub    $0x8,%esp
  8006ff:	ff 75 0c             	pushl  0xc(%ebp)
  800702:	6a 25                	push   $0x25
  800704:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800707:	83 c4 10             	add    $0x10,%esp
  80070a:	89 f3                	mov    %esi,%ebx
  80070c:	eb 03                	jmp    800711 <vprintfmt+0x3b1>
  80070e:	83 eb 01             	sub    $0x1,%ebx
  800711:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800715:	75 f7                	jne    80070e <vprintfmt+0x3ae>
  800717:	e9 70 fc ff ff       	jmp    80038c <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  80071c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80071f:	5b                   	pop    %ebx
  800720:	5e                   	pop    %esi
  800721:	5f                   	pop    %edi
  800722:	5d                   	pop    %ebp
  800723:	c3                   	ret    

00800724 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	83 ec 18             	sub    $0x18,%esp
  80072a:	8b 45 08             	mov    0x8(%ebp),%eax
  80072d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800730:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800733:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800737:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80073a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800741:	85 c0                	test   %eax,%eax
  800743:	74 26                	je     80076b <vsnprintf+0x47>
  800745:	85 d2                	test   %edx,%edx
  800747:	7e 22                	jle    80076b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800749:	ff 75 14             	pushl  0x14(%ebp)
  80074c:	ff 75 10             	pushl  0x10(%ebp)
  80074f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800752:	50                   	push   %eax
  800753:	68 26 03 80 00       	push   $0x800326
  800758:	e8 03 fc ff ff       	call   800360 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80075d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800760:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800763:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	eb 05                	jmp    800770 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80076b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800770:	c9                   	leave  
  800771:	c3                   	ret    

00800772 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800778:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80077b:	50                   	push   %eax
  80077c:	ff 75 10             	pushl  0x10(%ebp)
  80077f:	ff 75 0c             	pushl  0xc(%ebp)
  800782:	ff 75 08             	pushl  0x8(%ebp)
  800785:	e8 9a ff ff ff       	call   800724 <vsnprintf>
	va_end(ap);

	return rc;
}
  80078a:	c9                   	leave  
  80078b:	c3                   	ret    

0080078c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800792:	b8 00 00 00 00       	mov    $0x0,%eax
  800797:	eb 03                	jmp    80079c <strlen+0x10>
		n++;
  800799:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80079c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a0:	75 f7                	jne    800799 <strlen+0xd>
		n++;
	return n;
}
  8007a2:	5d                   	pop    %ebp
  8007a3:	c3                   	ret    

008007a4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007aa:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b2:	eb 03                	jmp    8007b7 <strnlen+0x13>
		n++;
  8007b4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b7:	39 c2                	cmp    %eax,%edx
  8007b9:	74 08                	je     8007c3 <strnlen+0x1f>
  8007bb:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007bf:	75 f3                	jne    8007b4 <strnlen+0x10>
  8007c1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007c3:	5d                   	pop    %ebp
  8007c4:	c3                   	ret    

008007c5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	53                   	push   %ebx
  8007c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007cf:	89 c2                	mov    %eax,%edx
  8007d1:	83 c2 01             	add    $0x1,%edx
  8007d4:	83 c1 01             	add    $0x1,%ecx
  8007d7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007db:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007de:	84 db                	test   %bl,%bl
  8007e0:	75 ef                	jne    8007d1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007e2:	5b                   	pop    %ebx
  8007e3:	5d                   	pop    %ebp
  8007e4:	c3                   	ret    

008007e5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	53                   	push   %ebx
  8007e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ec:	53                   	push   %ebx
  8007ed:	e8 9a ff ff ff       	call   80078c <strlen>
  8007f2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007f5:	ff 75 0c             	pushl  0xc(%ebp)
  8007f8:	01 d8                	add    %ebx,%eax
  8007fa:	50                   	push   %eax
  8007fb:	e8 c5 ff ff ff       	call   8007c5 <strcpy>
	return dst;
}
  800800:	89 d8                	mov    %ebx,%eax
  800802:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800805:	c9                   	leave  
  800806:	c3                   	ret    

00800807 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	56                   	push   %esi
  80080b:	53                   	push   %ebx
  80080c:	8b 75 08             	mov    0x8(%ebp),%esi
  80080f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800812:	89 f3                	mov    %esi,%ebx
  800814:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800817:	89 f2                	mov    %esi,%edx
  800819:	eb 0f                	jmp    80082a <strncpy+0x23>
		*dst++ = *src;
  80081b:	83 c2 01             	add    $0x1,%edx
  80081e:	0f b6 01             	movzbl (%ecx),%eax
  800821:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800824:	80 39 01             	cmpb   $0x1,(%ecx)
  800827:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082a:	39 da                	cmp    %ebx,%edx
  80082c:	75 ed                	jne    80081b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80082e:	89 f0                	mov    %esi,%eax
  800830:	5b                   	pop    %ebx
  800831:	5e                   	pop    %esi
  800832:	5d                   	pop    %ebp
  800833:	c3                   	ret    

00800834 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	56                   	push   %esi
  800838:	53                   	push   %ebx
  800839:	8b 75 08             	mov    0x8(%ebp),%esi
  80083c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083f:	8b 55 10             	mov    0x10(%ebp),%edx
  800842:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800844:	85 d2                	test   %edx,%edx
  800846:	74 21                	je     800869 <strlcpy+0x35>
  800848:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80084c:	89 f2                	mov    %esi,%edx
  80084e:	eb 09                	jmp    800859 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800850:	83 c2 01             	add    $0x1,%edx
  800853:	83 c1 01             	add    $0x1,%ecx
  800856:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800859:	39 c2                	cmp    %eax,%edx
  80085b:	74 09                	je     800866 <strlcpy+0x32>
  80085d:	0f b6 19             	movzbl (%ecx),%ebx
  800860:	84 db                	test   %bl,%bl
  800862:	75 ec                	jne    800850 <strlcpy+0x1c>
  800864:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800866:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800869:	29 f0                	sub    %esi,%eax
}
  80086b:	5b                   	pop    %ebx
  80086c:	5e                   	pop    %esi
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800875:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800878:	eb 06                	jmp    800880 <strcmp+0x11>
		p++, q++;
  80087a:	83 c1 01             	add    $0x1,%ecx
  80087d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800880:	0f b6 01             	movzbl (%ecx),%eax
  800883:	84 c0                	test   %al,%al
  800885:	74 04                	je     80088b <strcmp+0x1c>
  800887:	3a 02                	cmp    (%edx),%al
  800889:	74 ef                	je     80087a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80088b:	0f b6 c0             	movzbl %al,%eax
  80088e:	0f b6 12             	movzbl (%edx),%edx
  800891:	29 d0                	sub    %edx,%eax
}
  800893:	5d                   	pop    %ebp
  800894:	c3                   	ret    

00800895 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	53                   	push   %ebx
  800899:	8b 45 08             	mov    0x8(%ebp),%eax
  80089c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089f:	89 c3                	mov    %eax,%ebx
  8008a1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a4:	eb 06                	jmp    8008ac <strncmp+0x17>
		n--, p++, q++;
  8008a6:	83 c0 01             	add    $0x1,%eax
  8008a9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008ac:	39 d8                	cmp    %ebx,%eax
  8008ae:	74 15                	je     8008c5 <strncmp+0x30>
  8008b0:	0f b6 08             	movzbl (%eax),%ecx
  8008b3:	84 c9                	test   %cl,%cl
  8008b5:	74 04                	je     8008bb <strncmp+0x26>
  8008b7:	3a 0a                	cmp    (%edx),%cl
  8008b9:	74 eb                	je     8008a6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bb:	0f b6 00             	movzbl (%eax),%eax
  8008be:	0f b6 12             	movzbl (%edx),%edx
  8008c1:	29 d0                	sub    %edx,%eax
  8008c3:	eb 05                	jmp    8008ca <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008c5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ca:	5b                   	pop    %ebx
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    

008008cd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d7:	eb 07                	jmp    8008e0 <strchr+0x13>
		if (*s == c)
  8008d9:	38 ca                	cmp    %cl,%dl
  8008db:	74 0f                	je     8008ec <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008dd:	83 c0 01             	add    $0x1,%eax
  8008e0:	0f b6 10             	movzbl (%eax),%edx
  8008e3:	84 d2                	test   %dl,%dl
  8008e5:	75 f2                	jne    8008d9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    

008008ee <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f8:	eb 03                	jmp    8008fd <strfind+0xf>
  8008fa:	83 c0 01             	add    $0x1,%eax
  8008fd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800900:	38 ca                	cmp    %cl,%dl
  800902:	74 04                	je     800908 <strfind+0x1a>
  800904:	84 d2                	test   %dl,%dl
  800906:	75 f2                	jne    8008fa <strfind+0xc>
			break;
	return (char *) s;
}
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	57                   	push   %edi
  80090e:	56                   	push   %esi
  80090f:	53                   	push   %ebx
  800910:	8b 7d 08             	mov    0x8(%ebp),%edi
  800913:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800916:	85 c9                	test   %ecx,%ecx
  800918:	74 36                	je     800950 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80091a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800920:	75 28                	jne    80094a <memset+0x40>
  800922:	f6 c1 03             	test   $0x3,%cl
  800925:	75 23                	jne    80094a <memset+0x40>
		c &= 0xFF;
  800927:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80092b:	89 d3                	mov    %edx,%ebx
  80092d:	c1 e3 08             	shl    $0x8,%ebx
  800930:	89 d6                	mov    %edx,%esi
  800932:	c1 e6 18             	shl    $0x18,%esi
  800935:	89 d0                	mov    %edx,%eax
  800937:	c1 e0 10             	shl    $0x10,%eax
  80093a:	09 f0                	or     %esi,%eax
  80093c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80093e:	89 d8                	mov    %ebx,%eax
  800940:	09 d0                	or     %edx,%eax
  800942:	c1 e9 02             	shr    $0x2,%ecx
  800945:	fc                   	cld    
  800946:	f3 ab                	rep stos %eax,%es:(%edi)
  800948:	eb 06                	jmp    800950 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80094a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094d:	fc                   	cld    
  80094e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800950:	89 f8                	mov    %edi,%eax
  800952:	5b                   	pop    %ebx
  800953:	5e                   	pop    %esi
  800954:	5f                   	pop    %edi
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	57                   	push   %edi
  80095b:	56                   	push   %esi
  80095c:	8b 45 08             	mov    0x8(%ebp),%eax
  80095f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800962:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800965:	39 c6                	cmp    %eax,%esi
  800967:	73 35                	jae    80099e <memmove+0x47>
  800969:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80096c:	39 d0                	cmp    %edx,%eax
  80096e:	73 2e                	jae    80099e <memmove+0x47>
		s += n;
		d += n;
  800970:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800973:	89 d6                	mov    %edx,%esi
  800975:	09 fe                	or     %edi,%esi
  800977:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80097d:	75 13                	jne    800992 <memmove+0x3b>
  80097f:	f6 c1 03             	test   $0x3,%cl
  800982:	75 0e                	jne    800992 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800984:	83 ef 04             	sub    $0x4,%edi
  800987:	8d 72 fc             	lea    -0x4(%edx),%esi
  80098a:	c1 e9 02             	shr    $0x2,%ecx
  80098d:	fd                   	std    
  80098e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800990:	eb 09                	jmp    80099b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800992:	83 ef 01             	sub    $0x1,%edi
  800995:	8d 72 ff             	lea    -0x1(%edx),%esi
  800998:	fd                   	std    
  800999:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80099b:	fc                   	cld    
  80099c:	eb 1d                	jmp    8009bb <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099e:	89 f2                	mov    %esi,%edx
  8009a0:	09 c2                	or     %eax,%edx
  8009a2:	f6 c2 03             	test   $0x3,%dl
  8009a5:	75 0f                	jne    8009b6 <memmove+0x5f>
  8009a7:	f6 c1 03             	test   $0x3,%cl
  8009aa:	75 0a                	jne    8009b6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009ac:	c1 e9 02             	shr    $0x2,%ecx
  8009af:	89 c7                	mov    %eax,%edi
  8009b1:	fc                   	cld    
  8009b2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b4:	eb 05                	jmp    8009bb <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b6:	89 c7                	mov    %eax,%edi
  8009b8:	fc                   	cld    
  8009b9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009bb:	5e                   	pop    %esi
  8009bc:	5f                   	pop    %edi
  8009bd:	5d                   	pop    %ebp
  8009be:	c3                   	ret    

008009bf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009c2:	ff 75 10             	pushl  0x10(%ebp)
  8009c5:	ff 75 0c             	pushl  0xc(%ebp)
  8009c8:	ff 75 08             	pushl  0x8(%ebp)
  8009cb:	e8 87 ff ff ff       	call   800957 <memmove>
}
  8009d0:	c9                   	leave  
  8009d1:	c3                   	ret    

008009d2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	56                   	push   %esi
  8009d6:	53                   	push   %ebx
  8009d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009dd:	89 c6                	mov    %eax,%esi
  8009df:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e2:	eb 1a                	jmp    8009fe <memcmp+0x2c>
		if (*s1 != *s2)
  8009e4:	0f b6 08             	movzbl (%eax),%ecx
  8009e7:	0f b6 1a             	movzbl (%edx),%ebx
  8009ea:	38 d9                	cmp    %bl,%cl
  8009ec:	74 0a                	je     8009f8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009ee:	0f b6 c1             	movzbl %cl,%eax
  8009f1:	0f b6 db             	movzbl %bl,%ebx
  8009f4:	29 d8                	sub    %ebx,%eax
  8009f6:	eb 0f                	jmp    800a07 <memcmp+0x35>
		s1++, s2++;
  8009f8:	83 c0 01             	add    $0x1,%eax
  8009fb:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009fe:	39 f0                	cmp    %esi,%eax
  800a00:	75 e2                	jne    8009e4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a02:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a07:	5b                   	pop    %ebx
  800a08:	5e                   	pop    %esi
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	53                   	push   %ebx
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a12:	89 c1                	mov    %eax,%ecx
  800a14:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a17:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a1b:	eb 0a                	jmp    800a27 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a1d:	0f b6 10             	movzbl (%eax),%edx
  800a20:	39 da                	cmp    %ebx,%edx
  800a22:	74 07                	je     800a2b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a24:	83 c0 01             	add    $0x1,%eax
  800a27:	39 c8                	cmp    %ecx,%eax
  800a29:	72 f2                	jb     800a1d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a2b:	5b                   	pop    %ebx
  800a2c:	5d                   	pop    %ebp
  800a2d:	c3                   	ret    

00800a2e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	57                   	push   %edi
  800a32:	56                   	push   %esi
  800a33:	53                   	push   %ebx
  800a34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3a:	eb 03                	jmp    800a3f <strtol+0x11>
		s++;
  800a3c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3f:	0f b6 01             	movzbl (%ecx),%eax
  800a42:	3c 20                	cmp    $0x20,%al
  800a44:	74 f6                	je     800a3c <strtol+0xe>
  800a46:	3c 09                	cmp    $0x9,%al
  800a48:	74 f2                	je     800a3c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a4a:	3c 2b                	cmp    $0x2b,%al
  800a4c:	75 0a                	jne    800a58 <strtol+0x2a>
		s++;
  800a4e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a51:	bf 00 00 00 00       	mov    $0x0,%edi
  800a56:	eb 11                	jmp    800a69 <strtol+0x3b>
  800a58:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a5d:	3c 2d                	cmp    $0x2d,%al
  800a5f:	75 08                	jne    800a69 <strtol+0x3b>
		s++, neg = 1;
  800a61:	83 c1 01             	add    $0x1,%ecx
  800a64:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a69:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a6f:	75 15                	jne    800a86 <strtol+0x58>
  800a71:	80 39 30             	cmpb   $0x30,(%ecx)
  800a74:	75 10                	jne    800a86 <strtol+0x58>
  800a76:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a7a:	75 7c                	jne    800af8 <strtol+0xca>
		s += 2, base = 16;
  800a7c:	83 c1 02             	add    $0x2,%ecx
  800a7f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a84:	eb 16                	jmp    800a9c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a86:	85 db                	test   %ebx,%ebx
  800a88:	75 12                	jne    800a9c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a8a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a92:	75 08                	jne    800a9c <strtol+0x6e>
		s++, base = 8;
  800a94:	83 c1 01             	add    $0x1,%ecx
  800a97:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aa4:	0f b6 11             	movzbl (%ecx),%edx
  800aa7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aaa:	89 f3                	mov    %esi,%ebx
  800aac:	80 fb 09             	cmp    $0x9,%bl
  800aaf:	77 08                	ja     800ab9 <strtol+0x8b>
			dig = *s - '0';
  800ab1:	0f be d2             	movsbl %dl,%edx
  800ab4:	83 ea 30             	sub    $0x30,%edx
  800ab7:	eb 22                	jmp    800adb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ab9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800abc:	89 f3                	mov    %esi,%ebx
  800abe:	80 fb 19             	cmp    $0x19,%bl
  800ac1:	77 08                	ja     800acb <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ac3:	0f be d2             	movsbl %dl,%edx
  800ac6:	83 ea 57             	sub    $0x57,%edx
  800ac9:	eb 10                	jmp    800adb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800acb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ace:	89 f3                	mov    %esi,%ebx
  800ad0:	80 fb 19             	cmp    $0x19,%bl
  800ad3:	77 16                	ja     800aeb <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ad5:	0f be d2             	movsbl %dl,%edx
  800ad8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800adb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ade:	7d 0b                	jge    800aeb <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ae0:	83 c1 01             	add    $0x1,%ecx
  800ae3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ae7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ae9:	eb b9                	jmp    800aa4 <strtol+0x76>

	if (endptr)
  800aeb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aef:	74 0d                	je     800afe <strtol+0xd0>
		*endptr = (char *) s;
  800af1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af4:	89 0e                	mov    %ecx,(%esi)
  800af6:	eb 06                	jmp    800afe <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af8:	85 db                	test   %ebx,%ebx
  800afa:	74 98                	je     800a94 <strtol+0x66>
  800afc:	eb 9e                	jmp    800a9c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800afe:	89 c2                	mov    %eax,%edx
  800b00:	f7 da                	neg    %edx
  800b02:	85 ff                	test   %edi,%edi
  800b04:	0f 45 c2             	cmovne %edx,%eax
}
  800b07:	5b                   	pop    %ebx
  800b08:	5e                   	pop    %esi
  800b09:	5f                   	pop    %edi
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800b12:	b8 00 00 00 00       	mov    $0x0,%eax
  800b17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1d:	89 c3                	mov    %eax,%ebx
  800b1f:	89 c7                	mov    %eax,%edi
  800b21:	89 c6                	mov    %eax,%esi
  800b23:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b25:	5b                   	pop    %ebx
  800b26:	5e                   	pop    %esi
  800b27:	5f                   	pop    %edi
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	57                   	push   %edi
  800b2e:	56                   	push   %esi
  800b2f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b30:	ba 00 00 00 00       	mov    $0x0,%edx
  800b35:	b8 01 00 00 00       	mov    $0x1,%eax
  800b3a:	89 d1                	mov    %edx,%ecx
  800b3c:	89 d3                	mov    %edx,%ebx
  800b3e:	89 d7                	mov    %edx,%edi
  800b40:	89 d6                	mov    %edx,%esi
  800b42:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b44:	5b                   	pop    %ebx
  800b45:	5e                   	pop    %esi
  800b46:	5f                   	pop    %edi
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    

00800b49 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	57                   	push   %edi
  800b4d:	56                   	push   %esi
  800b4e:	53                   	push   %ebx
  800b4f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b52:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b57:	b8 03 00 00 00       	mov    $0x3,%eax
  800b5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5f:	89 cb                	mov    %ecx,%ebx
  800b61:	89 cf                	mov    %ecx,%edi
  800b63:	89 ce                	mov    %ecx,%esi
  800b65:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b67:	85 c0                	test   %eax,%eax
  800b69:	7e 17                	jle    800b82 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6b:	83 ec 0c             	sub    $0xc,%esp
  800b6e:	50                   	push   %eax
  800b6f:	6a 03                	push   $0x3
  800b71:	68 e8 18 80 00       	push   $0x8018e8
  800b76:	6a 23                	push   $0x23
  800b78:	68 05 19 80 00       	push   $0x801905
  800b7d:	e8 ce f5 ff ff       	call   800150 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b85:	5b                   	pop    %ebx
  800b86:	5e                   	pop    %esi
  800b87:	5f                   	pop    %edi
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	57                   	push   %edi
  800b8e:	56                   	push   %esi
  800b8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b90:	ba 00 00 00 00       	mov    $0x0,%edx
  800b95:	b8 02 00 00 00       	mov    $0x2,%eax
  800b9a:	89 d1                	mov    %edx,%ecx
  800b9c:	89 d3                	mov    %edx,%ebx
  800b9e:	89 d7                	mov    %edx,%edi
  800ba0:	89 d6                	mov    %edx,%esi
  800ba2:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ba4:	5b                   	pop    %ebx
  800ba5:	5e                   	pop    %esi
  800ba6:	5f                   	pop    %edi
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <sys_yield>:

void
sys_yield(void)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	57                   	push   %edi
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baf:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bb9:	89 d1                	mov    %edx,%ecx
  800bbb:	89 d3                	mov    %edx,%ebx
  800bbd:	89 d7                	mov    %edx,%edi
  800bbf:	89 d6                	mov    %edx,%esi
  800bc1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bc3:	5b                   	pop    %ebx
  800bc4:	5e                   	pop    %esi
  800bc5:	5f                   	pop    %edi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	57                   	push   %edi
  800bcc:	56                   	push   %esi
  800bcd:	53                   	push   %ebx
  800bce:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd1:	be 00 00 00 00       	mov    $0x0,%esi
  800bd6:	b8 04 00 00 00       	mov    $0x4,%eax
  800bdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bde:	8b 55 08             	mov    0x8(%ebp),%edx
  800be1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be4:	89 f7                	mov    %esi,%edi
  800be6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be8:	85 c0                	test   %eax,%eax
  800bea:	7e 17                	jle    800c03 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bec:	83 ec 0c             	sub    $0xc,%esp
  800bef:	50                   	push   %eax
  800bf0:	6a 04                	push   $0x4
  800bf2:	68 e8 18 80 00       	push   $0x8018e8
  800bf7:	6a 23                	push   $0x23
  800bf9:	68 05 19 80 00       	push   $0x801905
  800bfe:	e8 4d f5 ff ff       	call   800150 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c06:	5b                   	pop    %ebx
  800c07:	5e                   	pop    %esi
  800c08:	5f                   	pop    %edi
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    

00800c0b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	57                   	push   %edi
  800c0f:	56                   	push   %esi
  800c10:	53                   	push   %ebx
  800c11:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c14:	b8 05 00 00 00       	mov    $0x5,%eax
  800c19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c22:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c25:	8b 75 18             	mov    0x18(%ebp),%esi
  800c28:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c2a:	85 c0                	test   %eax,%eax
  800c2c:	7e 17                	jle    800c45 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2e:	83 ec 0c             	sub    $0xc,%esp
  800c31:	50                   	push   %eax
  800c32:	6a 05                	push   $0x5
  800c34:	68 e8 18 80 00       	push   $0x8018e8
  800c39:	6a 23                	push   $0x23
  800c3b:	68 05 19 80 00       	push   $0x801905
  800c40:	e8 0b f5 ff ff       	call   800150 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c48:	5b                   	pop    %ebx
  800c49:	5e                   	pop    %esi
  800c4a:	5f                   	pop    %edi
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    

00800c4d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	57                   	push   %edi
  800c51:	56                   	push   %esi
  800c52:	53                   	push   %ebx
  800c53:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5b:	b8 06 00 00 00       	mov    $0x6,%eax
  800c60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c63:	8b 55 08             	mov    0x8(%ebp),%edx
  800c66:	89 df                	mov    %ebx,%edi
  800c68:	89 de                	mov    %ebx,%esi
  800c6a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6c:	85 c0                	test   %eax,%eax
  800c6e:	7e 17                	jle    800c87 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c70:	83 ec 0c             	sub    $0xc,%esp
  800c73:	50                   	push   %eax
  800c74:	6a 06                	push   $0x6
  800c76:	68 e8 18 80 00       	push   $0x8018e8
  800c7b:	6a 23                	push   $0x23
  800c7d:	68 05 19 80 00       	push   $0x801905
  800c82:	e8 c9 f4 ff ff       	call   800150 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	57                   	push   %edi
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
  800c95:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c98:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9d:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca8:	89 df                	mov    %ebx,%edi
  800caa:	89 de                	mov    %ebx,%esi
  800cac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cae:	85 c0                	test   %eax,%eax
  800cb0:	7e 17                	jle    800cc9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb2:	83 ec 0c             	sub    $0xc,%esp
  800cb5:	50                   	push   %eax
  800cb6:	6a 08                	push   $0x8
  800cb8:	68 e8 18 80 00       	push   $0x8018e8
  800cbd:	6a 23                	push   $0x23
  800cbf:	68 05 19 80 00       	push   $0x801905
  800cc4:	e8 87 f4 ff ff       	call   800150 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
  800cd7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdf:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cea:	89 df                	mov    %ebx,%edi
  800cec:	89 de                	mov    %ebx,%esi
  800cee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	7e 17                	jle    800d0b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf4:	83 ec 0c             	sub    $0xc,%esp
  800cf7:	50                   	push   %eax
  800cf8:	6a 09                	push   $0x9
  800cfa:	68 e8 18 80 00       	push   $0x8018e8
  800cff:	6a 23                	push   $0x23
  800d01:	68 05 19 80 00       	push   $0x801905
  800d06:	e8 45 f4 ff ff       	call   800150 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d19:	be 00 00 00 00       	mov    $0x0,%esi
  800d1e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d26:	8b 55 08             	mov    0x8(%ebp),%edx
  800d29:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	57                   	push   %edi
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
  800d3c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d44:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d49:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4c:	89 cb                	mov    %ecx,%ebx
  800d4e:	89 cf                	mov    %ecx,%edi
  800d50:	89 ce                	mov    %ecx,%esi
  800d52:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d54:	85 c0                	test   %eax,%eax
  800d56:	7e 17                	jle    800d6f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d58:	83 ec 0c             	sub    $0xc,%esp
  800d5b:	50                   	push   %eax
  800d5c:	6a 0c                	push   $0xc
  800d5e:	68 e8 18 80 00       	push   $0x8018e8
  800d63:	6a 23                	push   $0x23
  800d65:	68 05 19 80 00       	push   $0x801905
  800d6a:	e8 e1 f3 ff ff       	call   800150 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d72:	5b                   	pop    %ebx
  800d73:	5e                   	pop    %esi
  800d74:	5f                   	pop    %edi
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	57                   	push   %edi
  800d7b:	56                   	push   %esi
  800d7c:	53                   	push   %ebx
  800d7d:	83 ec 0c             	sub    $0xc,%esp
  800d80:	89 c7                	mov    %eax,%edi
  800d82:	89 d3                	mov    %edx,%ebx
	int r;

	// LAB 4: Your code here.

    envid_t myenvid = sys_getenvid();
  800d84:	e8 01 fe ff ff       	call   800b8a <sys_getenvid>
  800d89:	89 c6                	mov    %eax,%esi
    pte_t pte = uvpt[pn];
  800d8b:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    int perm;

    perm = PTE_U | PTE_P;
    if(pte & PTE_W || pte & PTE_COW)
  800d92:	a9 02 08 00 00       	test   $0x802,%eax
  800d97:	75 40                	jne    800dd9 <duppage+0x62>
    {
        perm |= PTE_COW;
    }

    // map to envid VA
    if ((r = sys_page_map(myenvid,
  800d99:	c1 e3 0c             	shl    $0xc,%ebx
  800d9c:	83 ec 0c             	sub    $0xc,%esp
  800d9f:	6a 05                	push   $0x5
  800da1:	53                   	push   %ebx
  800da2:	57                   	push   %edi
  800da3:	53                   	push   %ebx
  800da4:	56                   	push   %esi
  800da5:	e8 61 fe ff ff       	call   800c0b <sys_page_map>
  800daa:	83 c4 20             	add    $0x20,%esp
  800dad:	85 c0                	test   %eax,%eax
  800daf:	ba 00 00 00 00       	mov    $0x0,%edx
  800db4:	0f 4f c2             	cmovg  %edx,%eax
  800db7:	eb 3b                	jmp    800df4 <duppage+0x7d>
    }

    // if COW remap to self
    if(perm & PTE_COW)
    {
        if((r = sys_page_map(myenvid, 
  800db9:	83 ec 0c             	sub    $0xc,%esp
  800dbc:	68 05 08 00 00       	push   $0x805
  800dc1:	53                   	push   %ebx
  800dc2:	56                   	push   %esi
  800dc3:	53                   	push   %ebx
  800dc4:	56                   	push   %esi
  800dc5:	e8 41 fe ff ff       	call   800c0b <sys_page_map>
  800dca:	83 c4 20             	add    $0x20,%esp
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd4:	0f 4f c2             	cmovg  %edx,%eax
  800dd7:	eb 1b                	jmp    800df4 <duppage+0x7d>
    {
        perm |= PTE_COW;
    }

    // map to envid VA
    if ((r = sys_page_map(myenvid,
  800dd9:	c1 e3 0c             	shl    $0xc,%ebx
  800ddc:	83 ec 0c             	sub    $0xc,%esp
  800ddf:	68 05 08 00 00       	push   $0x805
  800de4:	53                   	push   %ebx
  800de5:	57                   	push   %edi
  800de6:	53                   	push   %ebx
  800de7:	56                   	push   %esi
  800de8:	e8 1e fe ff ff       	call   800c0b <sys_page_map>
  800ded:	83 c4 20             	add    $0x20,%esp
  800df0:	85 c0                	test   %eax,%eax
  800df2:	79 c5                	jns    800db9 <duppage+0x42>
            return r;
        }
    }

	return 0;
}
  800df4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df7:	5b                   	pop    %ebx
  800df8:	5e                   	pop    %esi
  800df9:	5f                   	pop    %edi
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	56                   	push   %esi
  800e00:	53                   	push   %ebx
  800e01:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e04:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

    if ((err & FEC_WR) == 0)
  800e06:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e0a:	75 12                	jne    800e1e <pgfault+0x22>
    {
        panic("pgfault: page fault was not caused by write; %x.\n", utf->utf_fault_va);
  800e0c:	53                   	push   %ebx
  800e0d:	68 14 19 80 00       	push   $0x801914
  800e12:	6a 1f                	push   $0x1f
  800e14:	68 eb 19 80 00       	push   $0x8019eb
  800e19:	e8 32 f3 ff ff       	call   800150 <_panic>
    }

    if ((uvpt[PGNUM(addr)] & PTE_COW) == 0) 
  800e1e:	89 d8                	mov    %ebx,%eax
  800e20:	c1 e8 0c             	shr    $0xc,%eax
  800e23:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e2a:	f6 c4 08             	test   $0x8,%ah
  800e2d:	75 12                	jne    800e41 <pgfault+0x45>
    {
        panic("pgfault: page fault on page which is not COW %x.\n", utf->utf_fault_va);
  800e2f:	53                   	push   %ebx
  800e30:	68 48 19 80 00       	push   $0x801948
  800e35:	6a 24                	push   $0x24
  800e37:	68 eb 19 80 00       	push   $0x8019eb
  800e3c:	e8 0f f3 ff ff       	call   800150 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    envid_t envid = sys_getenvid();
  800e41:	e8 44 fd ff ff       	call   800b8a <sys_getenvid>
  800e46:	89 c6                	mov    %eax,%esi

    //allocate temp page
    if (sys_page_alloc(envid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  800e48:	83 ec 04             	sub    $0x4,%esp
  800e4b:	6a 07                	push   $0x7
  800e4d:	68 00 f0 7f 00       	push   $0x7ff000
  800e52:	50                   	push   %eax
  800e53:	e8 70 fd ff ff       	call   800bc8 <sys_page_alloc>
  800e58:	83 c4 10             	add    $0x10,%esp
  800e5b:	85 c0                	test   %eax,%eax
  800e5d:	79 14                	jns    800e73 <pgfault+0x77>
    {
        panic("pgfault: can't allocate temp page.\n");
  800e5f:	83 ec 04             	sub    $0x4,%esp
  800e62:	68 7c 19 80 00       	push   $0x80197c
  800e67:	6a 32                	push   $0x32
  800e69:	68 eb 19 80 00       	push   $0x8019eb
  800e6e:	e8 dd f2 ff ff       	call   800150 <_panic>
    }

    memmove(PFTEMP, (void *)ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800e73:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800e79:	83 ec 04             	sub    $0x4,%esp
  800e7c:	68 00 10 00 00       	push   $0x1000
  800e81:	53                   	push   %ebx
  800e82:	68 00 f0 7f 00       	push   $0x7ff000
  800e87:	e8 cb fa ff ff       	call   800957 <memmove>

    if(sys_page_map(envid, PFTEMP, envid, (void *)ROUNDDOWN(addr, PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
  800e8c:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e93:	53                   	push   %ebx
  800e94:	56                   	push   %esi
  800e95:	68 00 f0 7f 00       	push   $0x7ff000
  800e9a:	56                   	push   %esi
  800e9b:	e8 6b fd ff ff       	call   800c0b <sys_page_map>
  800ea0:	83 c4 20             	add    $0x20,%esp
  800ea3:	85 c0                	test   %eax,%eax
  800ea5:	79 14                	jns    800ebb <pgfault+0xbf>
    {
        panic("pgfault: can't map temp page to old page.\n");
  800ea7:	83 ec 04             	sub    $0x4,%esp
  800eaa:	68 a0 19 80 00       	push   $0x8019a0
  800eaf:	6a 39                	push   $0x39
  800eb1:	68 eb 19 80 00       	push   $0x8019eb
  800eb6:	e8 95 f2 ff ff       	call   800150 <_panic>
    }

    if(sys_page_unmap(envid, PFTEMP) < 0)
  800ebb:	83 ec 08             	sub    $0x8,%esp
  800ebe:	68 00 f0 7f 00       	push   $0x7ff000
  800ec3:	56                   	push   %esi
  800ec4:	e8 84 fd ff ff       	call   800c4d <sys_page_unmap>
  800ec9:	83 c4 10             	add    $0x10,%esp
  800ecc:	85 c0                	test   %eax,%eax
  800ece:	79 14                	jns    800ee4 <pgfault+0xe8>
    {
        panic("pgfault: couldn't unmap page.\n");
  800ed0:	83 ec 04             	sub    $0x4,%esp
  800ed3:	68 cc 19 80 00       	push   $0x8019cc
  800ed8:	6a 3e                	push   $0x3e
  800eda:	68 eb 19 80 00       	push   $0x8019eb
  800edf:	e8 6c f2 ff ff       	call   800150 <_panic>
    }
	//panic("pgfault not implemented");
}
  800ee4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ee7:	5b                   	pop    %ebx
  800ee8:	5e                   	pop    %esi
  800ee9:	5d                   	pop    %ebp
  800eea:	c3                   	ret    

00800eeb <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	57                   	push   %edi
  800eef:	56                   	push   %esi
  800ef0:	53                   	push   %ebx
  800ef1:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    extern void _pgfault_upcall(void);
    envid_t myenvid = sys_getenvid();
  800ef4:	e8 91 fc ff ff       	call   800b8a <sys_getenvid>
  800ef9:	89 45 e0             	mov    %eax,-0x20(%ebp)
    envid_t envid;
    uint32_t i, j, pn;

    //set page fault handler
    set_pgfault_handler(pgfault);
  800efc:	83 ec 0c             	sub    $0xc,%esp
  800eff:	68 fc 0d 80 00       	push   $0x800dfc
  800f04:	e8 1a 04 00 00       	call   801323 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f09:	b8 07 00 00 00       	mov    $0x7,%eax
  800f0e:	cd 30                	int    $0x30
  800f10:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f13:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    //create a child
    if((envid = sys_exofork()) < 0)
  800f16:	83 c4 10             	add    $0x10,%esp
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	0f 88 13 01 00 00    	js     801034 <fork+0x149>
  800f21:	bf 02 00 00 00       	mov    $0x2,%edi
    {
        return -1;
    }

    if(envid == 0)
  800f26:	85 c0                	test   %eax,%eax
  800f28:	75 21                	jne    800f4b <fork+0x60>
    {
        thisenv = &envs[ENVX(sys_getenvid())];
  800f2a:	e8 5b fc ff ff       	call   800b8a <sys_getenvid>
  800f2f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f34:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f37:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f3c:	a3 04 20 80 00       	mov    %eax,0x802004

        return envid;
  800f41:	b8 00 00 00 00       	mov    $0x0,%eax
  800f46:	e9 0a 01 00 00       	jmp    801055 <fork+0x16a>
    }

    //copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
  800f4b:	8b 04 bd 00 d0 7b ef 	mov    -0x10843000(,%edi,4),%eax
  800f52:	a8 01                	test   $0x1,%al
  800f54:	74 3a                	je     800f90 <fork+0xa5>
        {
            for (j = 0; j < NPTENTRIES; j++)
            {
                pn = PGNUM(PGADDR(i, j, 0));
  800f56:	89 fe                	mov    %edi,%esi
  800f58:	c1 e6 16             	shl    $0x16,%esi
  800f5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f60:	89 da                	mov    %ebx,%edx
  800f62:	c1 e2 0c             	shl    $0xc,%edx
  800f65:	09 f2                	or     %esi,%edx
  800f67:	c1 ea 0c             	shr    $0xc,%edx
                if(pn == PGNUM(UXSTACKTOP - PGSIZE))
  800f6a:	81 fa ff eb 0e 00    	cmp    $0xeebff,%edx
  800f70:	74 1e                	je     800f90 <fork+0xa5>
                {
                    break;
                }

                if(uvpt[pn] & PTE_P)
  800f72:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800f79:	a8 01                	test   $0x1,%al
  800f7b:	74 08                	je     800f85 <fork+0x9a>
                {
                    duppage(envid, pn);
  800f7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f80:	e8 f2 fd ff ff       	call   800d77 <duppage>
    //copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
        {
            for (j = 0; j < NPTENTRIES; j++)
  800f85:	83 c3 01             	add    $0x1,%ebx
  800f88:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  800f8e:	75 d0                	jne    800f60 <fork+0x75>

        return envid;
    }

    //copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
  800f90:	83 c7 01             	add    $0x1,%edi
  800f93:	81 ff bb 03 00 00    	cmp    $0x3bb,%edi
  800f99:	75 b0                	jne    800f4b <fork+0x60>
                }
            }
        }
    }

    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
  800f9b:	83 ec 04             	sub    $0x4,%esp
  800f9e:	6a 07                	push   $0x7
  800fa0:	68 00 f0 bf ee       	push   $0xeebff000
  800fa5:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800fa8:	57                   	push   %edi
  800fa9:	e8 1a fc ff ff       	call   800bc8 <sys_page_alloc>
  800fae:	83 c4 10             	add    $0x10,%esp
  800fb1:	85 c0                	test   %eax,%eax
  800fb3:	0f 88 82 00 00 00    	js     80103b <fork+0x150>
    {
        return -1;
    }

    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  800fb9:	83 ec 0c             	sub    $0xc,%esp
  800fbc:	6a 07                	push   $0x7
  800fbe:	68 00 f0 7f 00       	push   $0x7ff000
  800fc3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800fc6:	56                   	push   %esi
  800fc7:	68 00 f0 bf ee       	push   $0xeebff000
  800fcc:	57                   	push   %edi
  800fcd:	e8 39 fc ff ff       	call   800c0b <sys_page_map>
  800fd2:	83 c4 20             	add    $0x20,%esp
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	78 69                	js     801042 <fork+0x157>
    {
        return -1;
    }

    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);
  800fd9:	83 ec 04             	sub    $0x4,%esp
  800fdc:	68 00 10 00 00       	push   $0x1000
  800fe1:	68 00 f0 7f 00       	push   $0x7ff000
  800fe6:	68 00 f0 bf ee       	push   $0xeebff000
  800feb:	e8 67 f9 ff ff       	call   800957 <memmove>

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
  800ff0:	83 c4 08             	add    $0x8,%esp
  800ff3:	68 00 f0 7f 00       	push   $0x7ff000
  800ff8:	56                   	push   %esi
  800ff9:	e8 4f fc ff ff       	call   800c4d <sys_page_unmap>
  800ffe:	83 c4 10             	add    $0x10,%esp
  801001:	85 c0                	test   %eax,%eax
  801003:	78 44                	js     801049 <fork+0x15e>
    {
        return -1;
    }

    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
  801005:	83 ec 08             	sub    $0x8,%esp
  801008:	68 88 13 80 00       	push   $0x801388
  80100d:	57                   	push   %edi
  80100e:	e8 be fc ff ff       	call   800cd1 <sys_env_set_pgfault_upcall>
  801013:	83 c4 10             	add    $0x10,%esp
  801016:	85 c0                	test   %eax,%eax
  801018:	78 36                	js     801050 <fork+0x165>
    {
        return -1;
    }

    if(sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  80101a:	83 ec 08             	sub    $0x8,%esp
  80101d:	6a 02                	push   $0x2
  80101f:	57                   	push   %edi
  801020:	e8 6a fc ff ff       	call   800c8f <sys_env_set_status>
  801025:	83 c4 10             	add    $0x10,%esp
    {
        return -1;
    }

    return envid;
  801028:	85 c0                	test   %eax,%eax
  80102a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80102f:	0f 49 c7             	cmovns %edi,%eax
  801032:	eb 21                	jmp    801055 <fork+0x16a>
    set_pgfault_handler(pgfault);

    //create a child
    if((envid = sys_exofork()) < 0)
    {
        return -1;
  801034:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801039:	eb 1a                	jmp    801055 <fork+0x16a>
        }
    }

    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  80103b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801040:	eb 13                	jmp    801055 <fork+0x16a>
    }

    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  801042:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801047:	eb 0c                	jmp    801055 <fork+0x16a>

    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
    {
        return -1;
  801049:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80104e:	eb 05                	jmp    801055 <fork+0x16a>
    }

    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
    {
        return -1;
  801050:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
        return -1;
    }

    return envid;
    //	panic("fork not implemented");
}
  801055:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801058:	5b                   	pop    %ebx
  801059:	5e                   	pop    %esi
  80105a:	5f                   	pop    %edi
  80105b:	5d                   	pop    %ebp
  80105c:	c3                   	ret    

0080105d <sfork>:

// Challenge!
int
sfork(void)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	57                   	push   %edi
  801061:	56                   	push   %esi
  801062:	53                   	push   %ebx
  801063:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    extern void _pgfault_upcall(void);
    envid_t myenvid = sys_getenvid();
  801066:	e8 1f fb ff ff       	call   800b8a <sys_getenvid>
  80106b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    envid_t envid;
    uint32_t i, j, pn;
    int perm;

    // set page fault handler
    set_pgfault_handler(pgfault);
  80106e:	83 ec 0c             	sub    $0xc,%esp
  801071:	68 fc 0d 80 00       	push   $0x800dfc
  801076:	e8 a8 02 00 00       	call   801323 <set_pgfault_handler>
  80107b:	b8 07 00 00 00       	mov    $0x7,%eax
  801080:	cd 30                	int    $0x30
  801082:	89 45 dc             	mov    %eax,-0x24(%ebp)

    // create a child
    if((envid = sys_exofork()) < 0)
  801085:	83 c4 10             	add    $0x10,%esp
  801088:	85 c0                	test   %eax,%eax
  80108a:	0f 88 5d 01 00 00    	js     8011ed <sfork+0x190>
  801090:	89 c7                	mov    %eax,%edi
  801092:	c7 45 e4 02 00 00 00 	movl   $0x2,-0x1c(%ebp)
    {
        return -1;
    }

    if(envid == 0)
  801099:	85 c0                	test   %eax,%eax
  80109b:	75 21                	jne    8010be <sfork+0x61>
    {
        thisenv = &envs[ENVX(sys_getenvid())];
  80109d:	e8 e8 fa ff ff       	call   800b8a <sys_getenvid>
  8010a2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010a7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010aa:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010af:	a3 04 20 80 00       	mov    %eax,0x802004
        return envid;
  8010b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8010b9:	e9 57 01 00 00       	jmp    801215 <sfork+0x1b8>
    }

    // copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
  8010be:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8010c1:	8b 04 b5 00 d0 7b ef 	mov    -0x10843000(,%esi,4),%eax
  8010c8:	a8 01                	test   $0x1,%al
  8010ca:	74 76                	je     801142 <sfork+0xe5>
        {
            for (j = 0; j < NPTENTRIES; j++)
            {
                pn = PGNUM(PGADDR(i, j, 0));
  8010cc:	c1 e6 16             	shl    $0x16,%esi
  8010cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010d4:	89 d8                	mov    %ebx,%eax
  8010d6:	c1 e0 0c             	shl    $0xc,%eax
  8010d9:	09 f0                	or     %esi,%eax
  8010db:	89 c2                	mov    %eax,%edx
  8010dd:	c1 ea 0c             	shr    $0xc,%edx
                if(pn == PGNUM(UXSTACKTOP - PGSIZE))
  8010e0:	81 fa ff eb 0e 00    	cmp    $0xeebff,%edx
  8010e6:	74 5a                	je     801142 <sfork+0xe5>
                {
                    break;
                }

                if(pn == PGNUM(USTACKTOP - PGSIZE))
  8010e8:	81 fa fd eb 0e 00    	cmp    $0xeebfd,%edx
  8010ee:	75 09                	jne    8010f9 <sfork+0x9c>
                {
                     duppage(envid, pn); // cow for stack page
  8010f0:	89 f8                	mov    %edi,%eax
  8010f2:	e8 80 fc ff ff       	call   800d77 <duppage>
                     continue;
  8010f7:	eb 3e                	jmp    801137 <sfork+0xda>
                }

                // map same page to child env with same perms
                if (uvpt[pn] & PTE_P)
  8010f9:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801100:	f6 c1 01             	test   $0x1,%cl
  801103:	74 32                	je     801137 <sfork+0xda>
                {
                    
                    perm = uvpt[pn] & ~(uvpt[pn] & ~(PTE_P |PTE_U | PTE_W | PTE_AVAIL));
  801105:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  80110c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
                    if (sys_page_map(myenvid, (void *)(PGADDR(i, j, 0)),
  801113:	83 ec 0c             	sub    $0xc,%esp
  801116:	81 e2 f8 f1 ff ff    	and    $0xfffff1f8,%edx
  80111c:	f7 d2                	not    %edx
  80111e:	21 d1                	and    %edx,%ecx
  801120:	51                   	push   %ecx
  801121:	50                   	push   %eax
  801122:	57                   	push   %edi
  801123:	50                   	push   %eax
  801124:	ff 75 e0             	pushl  -0x20(%ebp)
  801127:	e8 df fa ff ff       	call   800c0b <sys_page_map>
  80112c:	83 c4 20             	add    $0x20,%esp
  80112f:	85 c0                	test   %eax,%eax
  801131:	0f 88 bd 00 00 00    	js     8011f4 <sfork+0x197>
    // copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
        {
            for (j = 0; j < NPTENTRIES; j++)
  801137:	83 c3 01             	add    $0x1,%ebx
  80113a:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801140:	75 92                	jne    8010d4 <sfork+0x77>
        thisenv = &envs[ENVX(sys_getenvid())];
        return envid;
    }

    // copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
  801142:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  801146:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801149:	3d bb 03 00 00       	cmp    $0x3bb,%eax
  80114e:	0f 85 6a ff ff ff    	jne    8010be <sfork+0x61>
            }
        }
    }

    // allocate new exception stack for child
    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
  801154:	83 ec 04             	sub    $0x4,%esp
  801157:	6a 07                	push   $0x7
  801159:	68 00 f0 bf ee       	push   $0xeebff000
  80115e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801161:	57                   	push   %edi
  801162:	e8 61 fa ff ff       	call   800bc8 <sys_page_alloc>
  801167:	83 c4 10             	add    $0x10,%esp
  80116a:	85 c0                	test   %eax,%eax
  80116c:	0f 88 89 00 00 00    	js     8011fb <sfork+0x19e>
    {
        return -1;
    }

    // map child uxstack to temp page
    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  801172:	83 ec 0c             	sub    $0xc,%esp
  801175:	6a 07                	push   $0x7
  801177:	68 00 f0 7f 00       	push   $0x7ff000
  80117c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80117f:	56                   	push   %esi
  801180:	68 00 f0 bf ee       	push   $0xeebff000
  801185:	57                   	push   %edi
  801186:	e8 80 fa ff ff       	call   800c0b <sys_page_map>
  80118b:	83 c4 20             	add    $0x20,%esp
  80118e:	85 c0                	test   %eax,%eax
  801190:	78 70                	js     801202 <sfork+0x1a5>
    {
        return -1;
    }

    // copy own uxstack to temp page
    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);
  801192:	83 ec 04             	sub    $0x4,%esp
  801195:	68 00 10 00 00       	push   $0x1000
  80119a:	68 00 f0 7f 00       	push   $0x7ff000
  80119f:	68 00 f0 bf ee       	push   $0xeebff000
  8011a4:	e8 ae f7 ff ff       	call   800957 <memmove>

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
  8011a9:	83 c4 08             	add    $0x8,%esp
  8011ac:	68 00 f0 7f 00       	push   $0x7ff000
  8011b1:	56                   	push   %esi
  8011b2:	e8 96 fa ff ff       	call   800c4d <sys_page_unmap>
  8011b7:	83 c4 10             	add    $0x10,%esp
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	78 4b                	js     801209 <sfork+0x1ac>
    {
        return -1;
    }

    // set page fault handler in child
    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
  8011be:	83 ec 08             	sub    $0x8,%esp
  8011c1:	68 88 13 80 00       	push   $0x801388
  8011c6:	57                   	push   %edi
  8011c7:	e8 05 fb ff ff       	call   800cd1 <sys_env_set_pgfault_upcall>
  8011cc:	83 c4 10             	add    $0x10,%esp
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	78 3d                	js     801210 <sfork+0x1b3>
    {
        return -1;
    }

    // mark child env as RUNNABLE
    if(sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  8011d3:	83 ec 08             	sub    $0x8,%esp
  8011d6:	6a 02                	push   $0x2
  8011d8:	57                   	push   %edi
  8011d9:	e8 b1 fa ff ff       	call   800c8f <sys_env_set_status>
  8011de:	83 c4 10             	add    $0x10,%esp
    {
        return -1;
    }

    return envid;
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8011e8:	0f 49 c7             	cmovns %edi,%eax
  8011eb:	eb 28                	jmp    801215 <sfork+0x1b8>
    set_pgfault_handler(pgfault);

    // create a child
    if((envid = sys_exofork()) < 0)
    {
        return -1;
  8011ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8011f2:	eb 21                	jmp    801215 <sfork+0x1b8>
                    
                    perm = uvpt[pn] & ~(uvpt[pn] & ~(PTE_P |PTE_U | PTE_W | PTE_AVAIL));
                    if (sys_page_map(myenvid, (void *)(PGADDR(i, j, 0)),
                                     envid,   (void *)(PGADDR(i, j, 0)), perm) < 0)
                    {
                        return -1;
  8011f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8011f9:	eb 1a                	jmp    801215 <sfork+0x1b8>
    }

    // allocate new exception stack for child
    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  8011fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801200:	eb 13                	jmp    801215 <sfork+0x1b8>
    }

    // map child uxstack to temp page
    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  801202:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801207:	eb 0c                	jmp    801215 <sfork+0x1b8>
    // copy own uxstack to temp page
    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
    {
        return -1;
  801209:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80120e:	eb 05                	jmp    801215 <sfork+0x1b8>
    }

    // set page fault handler in child
    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
    {
        return -1;
  801210:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    {
        return -1;
    }

    return envid;
}
  801215:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801218:	5b                   	pop    %ebx
  801219:	5e                   	pop    %esi
  80121a:	5f                   	pop    %edi
  80121b:	5d                   	pop    %ebp
  80121c:	c3                   	ret    

0080121d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
  801220:	57                   	push   %edi
  801221:	56                   	push   %esi
  801222:	53                   	push   %ebx
  801223:	83 ec 18             	sub    $0x18,%esp
  801226:	8b 7d 08             	mov    0x8(%ebp),%edi
  801229:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80122c:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
    int r = sys_ipc_recv((pg) ? pg : (void *)UTOP);
  80122f:	85 db                	test   %ebx,%ebx
  801231:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801236:	0f 45 c3             	cmovne %ebx,%eax
  801239:	50                   	push   %eax
  80123a:	e8 f7 fa ff ff       	call   800d36 <sys_ipc_recv>
  80123f:	89 c2                	mov    %eax,%edx

    if (from_env_store)
  801241:	83 c4 10             	add    $0x10,%esp
  801244:	85 ff                	test   %edi,%edi
  801246:	74 13                	je     80125b <ipc_recv+0x3e>
    {
        *from_env_store = (r == 0) ? thisenv->env_ipc_from : 0;
  801248:	b8 00 00 00 00       	mov    $0x0,%eax
  80124d:	85 d2                	test   %edx,%edx
  80124f:	75 08                	jne    801259 <ipc_recv+0x3c>
  801251:	a1 04 20 80 00       	mov    0x802004,%eax
  801256:	8b 40 74             	mov    0x74(%eax),%eax
  801259:	89 07                	mov    %eax,(%edi)
    }

    if (perm_store)
  80125b:	85 f6                	test   %esi,%esi
  80125d:	74 1d                	je     80127c <ipc_recv+0x5f>
    {
        *perm_store = (r == 0 && (uint32_t) pg < UTOP) ? thisenv->env_ipc_perm : 0;
  80125f:	85 d2                	test   %edx,%edx
  801261:	75 12                	jne    801275 <ipc_recv+0x58>
  801263:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801269:	77 0a                	ja     801275 <ipc_recv+0x58>
  80126b:	a1 04 20 80 00       	mov    0x802004,%eax
  801270:	8b 40 78             	mov    0x78(%eax),%eax
  801273:	eb 05                	jmp    80127a <ipc_recv+0x5d>
  801275:	b8 00 00 00 00       	mov    $0x0,%eax
  80127a:	89 06                	mov    %eax,(%esi)
    }

    if (r)
    {
        return r;
  80127c:	89 d0                	mov    %edx,%eax
    if (perm_store)
    {
        *perm_store = (r == 0 && (uint32_t) pg < UTOP) ? thisenv->env_ipc_perm : 0;
    }

    if (r)
  80127e:	85 d2                	test   %edx,%edx
  801280:	75 08                	jne    80128a <ipc_recv+0x6d>
    {
        return r;
    }

    return thisenv->env_ipc_value;
  801282:	a1 04 20 80 00       	mov    0x802004,%eax
  801287:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  80128a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80128d:	5b                   	pop    %ebx
  80128e:	5e                   	pop    %esi
  80128f:	5f                   	pop    %edi
  801290:	5d                   	pop    %ebp
  801291:	c3                   	ret    

00801292 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	57                   	push   %edi
  801296:	56                   	push   %esi
  801297:	53                   	push   %ebx
  801298:	83 ec 0c             	sub    $0xc,%esp
  80129b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80129e:	8b 45 10             	mov    0x10(%ebp),%eax
  8012a1:	85 c0                	test   %eax,%eax
  8012a3:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
  8012a8:	0f 45 f0             	cmovne %eax,%esi
	// LAB 4: Your code here.
 
    int r = 0;
    do
    {
        r = sys_ipc_try_send(to_env, val, pg ? pg : (void *)UTOP, perm);
  8012ab:	ff 75 14             	pushl  0x14(%ebp)
  8012ae:	56                   	push   %esi
  8012af:	ff 75 0c             	pushl  0xc(%ebp)
  8012b2:	57                   	push   %edi
  8012b3:	e8 5b fa ff ff       	call   800d13 <sys_ipc_try_send>
  8012b8:	89 c3                	mov    %eax,%ebx

        if (r != 0 && r != -E_IPC_NOT_RECV)
  8012ba:	8d 40 08             	lea    0x8(%eax),%eax
  8012bd:	83 c4 10             	add    $0x10,%esp
  8012c0:	a9 f7 ff ff ff       	test   $0xfffffff7,%eax
  8012c5:	74 12                	je     8012d9 <ipc_send+0x47>
        {
            panic("ipc_send: error %e", r);
  8012c7:	53                   	push   %ebx
  8012c8:	68 f6 19 80 00       	push   $0x8019f6
  8012cd:	6a 44                	push   $0x44
  8012cf:	68 09 1a 80 00       	push   $0x801a09
  8012d4:	e8 77 ee ff ff       	call   800150 <_panic>
        }
        else
        {
            sys_yield();
  8012d9:	e8 cb f8 ff ff       	call   800ba9 <sys_yield>
        }
    }while(r != 0);
  8012de:	85 db                	test   %ebx,%ebx
  8012e0:	75 c9                	jne    8012ab <ipc_send+0x19>
	//panic("ipc_send not implemented");
}
  8012e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012e5:	5b                   	pop    %ebx
  8012e6:	5e                   	pop    %esi
  8012e7:	5f                   	pop    %edi
  8012e8:	5d                   	pop    %ebp
  8012e9:	c3                   	ret    

008012ea <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012ea:	55                   	push   %ebp
  8012eb:	89 e5                	mov    %esp,%ebp
  8012ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8012f0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8012f5:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8012f8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8012fe:	8b 52 50             	mov    0x50(%edx),%edx
  801301:	39 ca                	cmp    %ecx,%edx
  801303:	75 0d                	jne    801312 <ipc_find_env+0x28>
			return envs[i].env_id;
  801305:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801308:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80130d:	8b 40 48             	mov    0x48(%eax),%eax
  801310:	eb 0f                	jmp    801321 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801312:	83 c0 01             	add    $0x1,%eax
  801315:	3d 00 04 00 00       	cmp    $0x400,%eax
  80131a:	75 d9                	jne    8012f5 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80131c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801321:	5d                   	pop    %ebp
  801322:	c3                   	ret    

00801323 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801329:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801330:	75 4c                	jne    80137e <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.

        void *va = (void *)(UXSTACKTOP - PGSIZE);
        if (sys_page_alloc(thisenv->env_id, va, PTE_P | PTE_U | PTE_W))
  801332:	a1 04 20 80 00       	mov    0x802004,%eax
  801337:	8b 40 48             	mov    0x48(%eax),%eax
  80133a:	83 ec 04             	sub    $0x4,%esp
  80133d:	6a 07                	push   $0x7
  80133f:	68 00 f0 bf ee       	push   $0xeebff000
  801344:	50                   	push   %eax
  801345:	e8 7e f8 ff ff       	call   800bc8 <sys_page_alloc>
  80134a:	83 c4 10             	add    $0x10,%esp
  80134d:	85 c0                	test   %eax,%eax
  80134f:	74 14                	je     801365 <set_pgfault_handler+0x42>
        {
            panic("Unable to allocate memory for pgfault expected\n");
  801351:	83 ec 04             	sub    $0x4,%esp
  801354:	68 14 1a 80 00       	push   $0x801a14
  801359:	6a 24                	push   $0x24
  80135b:	68 44 1a 80 00       	push   $0x801a44
  801360:	e8 eb ed ff ff       	call   800150 <_panic>
        }

        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801365:	a1 04 20 80 00       	mov    0x802004,%eax
  80136a:	8b 40 48             	mov    0x48(%eax),%eax
  80136d:	83 ec 08             	sub    $0x8,%esp
  801370:	68 88 13 80 00       	push   $0x801388
  801375:	50                   	push   %eax
  801376:	e8 56 f9 ff ff       	call   800cd1 <sys_env_set_pgfault_upcall>
  80137b:	83 c4 10             	add    $0x10,%esp

		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80137e:	8b 45 08             	mov    0x8(%ebp),%eax
  801381:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801386:	c9                   	leave  
  801387:	c3                   	ret    

00801388 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801388:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801389:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80138e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801390:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
    movl %esp, %ebx
  801393:	89 e3                	mov    %esp,%ebx
    // 40 is the size between utf_fault_va ~ utf_regs
    movl 40(%esp), %eax
  801395:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 48(%esp), %esp
  801399:	8b 64 24 30          	mov    0x30(%esp),%esp
    pushl %eax
  80139d:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    movl %ebx, %esp
  80139e:	89 dc                	mov    %ebx,%esp
    subl $4, 48(%esp)
  8013a0:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    popl %eax
  8013a5:	58                   	pop    %eax
    popl %eax
  8013a6:	58                   	pop    %eax
    popal
  8013a7:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  8013a8:	83 c4 04             	add    $0x4,%esp
    popfl
  8013ab:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp
  8013ac:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  8013ad:	c3                   	ret    
  8013ae:	66 90                	xchg   %ax,%ax

008013b0 <__udivdi3>:
  8013b0:	55                   	push   %ebp
  8013b1:	57                   	push   %edi
  8013b2:	56                   	push   %esi
  8013b3:	53                   	push   %ebx
  8013b4:	83 ec 1c             	sub    $0x1c,%esp
  8013b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8013bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8013bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8013c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8013c7:	85 f6                	test   %esi,%esi
  8013c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013cd:	89 ca                	mov    %ecx,%edx
  8013cf:	89 f8                	mov    %edi,%eax
  8013d1:	75 3d                	jne    801410 <__udivdi3+0x60>
  8013d3:	39 cf                	cmp    %ecx,%edi
  8013d5:	0f 87 c5 00 00 00    	ja     8014a0 <__udivdi3+0xf0>
  8013db:	85 ff                	test   %edi,%edi
  8013dd:	89 fd                	mov    %edi,%ebp
  8013df:	75 0b                	jne    8013ec <__udivdi3+0x3c>
  8013e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8013e6:	31 d2                	xor    %edx,%edx
  8013e8:	f7 f7                	div    %edi
  8013ea:	89 c5                	mov    %eax,%ebp
  8013ec:	89 c8                	mov    %ecx,%eax
  8013ee:	31 d2                	xor    %edx,%edx
  8013f0:	f7 f5                	div    %ebp
  8013f2:	89 c1                	mov    %eax,%ecx
  8013f4:	89 d8                	mov    %ebx,%eax
  8013f6:	89 cf                	mov    %ecx,%edi
  8013f8:	f7 f5                	div    %ebp
  8013fa:	89 c3                	mov    %eax,%ebx
  8013fc:	89 d8                	mov    %ebx,%eax
  8013fe:	89 fa                	mov    %edi,%edx
  801400:	83 c4 1c             	add    $0x1c,%esp
  801403:	5b                   	pop    %ebx
  801404:	5e                   	pop    %esi
  801405:	5f                   	pop    %edi
  801406:	5d                   	pop    %ebp
  801407:	c3                   	ret    
  801408:	90                   	nop
  801409:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801410:	39 ce                	cmp    %ecx,%esi
  801412:	77 74                	ja     801488 <__udivdi3+0xd8>
  801414:	0f bd fe             	bsr    %esi,%edi
  801417:	83 f7 1f             	xor    $0x1f,%edi
  80141a:	0f 84 98 00 00 00    	je     8014b8 <__udivdi3+0x108>
  801420:	bb 20 00 00 00       	mov    $0x20,%ebx
  801425:	89 f9                	mov    %edi,%ecx
  801427:	89 c5                	mov    %eax,%ebp
  801429:	29 fb                	sub    %edi,%ebx
  80142b:	d3 e6                	shl    %cl,%esi
  80142d:	89 d9                	mov    %ebx,%ecx
  80142f:	d3 ed                	shr    %cl,%ebp
  801431:	89 f9                	mov    %edi,%ecx
  801433:	d3 e0                	shl    %cl,%eax
  801435:	09 ee                	or     %ebp,%esi
  801437:	89 d9                	mov    %ebx,%ecx
  801439:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80143d:	89 d5                	mov    %edx,%ebp
  80143f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801443:	d3 ed                	shr    %cl,%ebp
  801445:	89 f9                	mov    %edi,%ecx
  801447:	d3 e2                	shl    %cl,%edx
  801449:	89 d9                	mov    %ebx,%ecx
  80144b:	d3 e8                	shr    %cl,%eax
  80144d:	09 c2                	or     %eax,%edx
  80144f:	89 d0                	mov    %edx,%eax
  801451:	89 ea                	mov    %ebp,%edx
  801453:	f7 f6                	div    %esi
  801455:	89 d5                	mov    %edx,%ebp
  801457:	89 c3                	mov    %eax,%ebx
  801459:	f7 64 24 0c          	mull   0xc(%esp)
  80145d:	39 d5                	cmp    %edx,%ebp
  80145f:	72 10                	jb     801471 <__udivdi3+0xc1>
  801461:	8b 74 24 08          	mov    0x8(%esp),%esi
  801465:	89 f9                	mov    %edi,%ecx
  801467:	d3 e6                	shl    %cl,%esi
  801469:	39 c6                	cmp    %eax,%esi
  80146b:	73 07                	jae    801474 <__udivdi3+0xc4>
  80146d:	39 d5                	cmp    %edx,%ebp
  80146f:	75 03                	jne    801474 <__udivdi3+0xc4>
  801471:	83 eb 01             	sub    $0x1,%ebx
  801474:	31 ff                	xor    %edi,%edi
  801476:	89 d8                	mov    %ebx,%eax
  801478:	89 fa                	mov    %edi,%edx
  80147a:	83 c4 1c             	add    $0x1c,%esp
  80147d:	5b                   	pop    %ebx
  80147e:	5e                   	pop    %esi
  80147f:	5f                   	pop    %edi
  801480:	5d                   	pop    %ebp
  801481:	c3                   	ret    
  801482:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801488:	31 ff                	xor    %edi,%edi
  80148a:	31 db                	xor    %ebx,%ebx
  80148c:	89 d8                	mov    %ebx,%eax
  80148e:	89 fa                	mov    %edi,%edx
  801490:	83 c4 1c             	add    $0x1c,%esp
  801493:	5b                   	pop    %ebx
  801494:	5e                   	pop    %esi
  801495:	5f                   	pop    %edi
  801496:	5d                   	pop    %ebp
  801497:	c3                   	ret    
  801498:	90                   	nop
  801499:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014a0:	89 d8                	mov    %ebx,%eax
  8014a2:	f7 f7                	div    %edi
  8014a4:	31 ff                	xor    %edi,%edi
  8014a6:	89 c3                	mov    %eax,%ebx
  8014a8:	89 d8                	mov    %ebx,%eax
  8014aa:	89 fa                	mov    %edi,%edx
  8014ac:	83 c4 1c             	add    $0x1c,%esp
  8014af:	5b                   	pop    %ebx
  8014b0:	5e                   	pop    %esi
  8014b1:	5f                   	pop    %edi
  8014b2:	5d                   	pop    %ebp
  8014b3:	c3                   	ret    
  8014b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014b8:	39 ce                	cmp    %ecx,%esi
  8014ba:	72 0c                	jb     8014c8 <__udivdi3+0x118>
  8014bc:	31 db                	xor    %ebx,%ebx
  8014be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8014c2:	0f 87 34 ff ff ff    	ja     8013fc <__udivdi3+0x4c>
  8014c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8014cd:	e9 2a ff ff ff       	jmp    8013fc <__udivdi3+0x4c>
  8014d2:	66 90                	xchg   %ax,%ax
  8014d4:	66 90                	xchg   %ax,%ax
  8014d6:	66 90                	xchg   %ax,%ax
  8014d8:	66 90                	xchg   %ax,%ax
  8014da:	66 90                	xchg   %ax,%ax
  8014dc:	66 90                	xchg   %ax,%ax
  8014de:	66 90                	xchg   %ax,%ax

008014e0 <__umoddi3>:
  8014e0:	55                   	push   %ebp
  8014e1:	57                   	push   %edi
  8014e2:	56                   	push   %esi
  8014e3:	53                   	push   %ebx
  8014e4:	83 ec 1c             	sub    $0x1c,%esp
  8014e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8014eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8014ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8014f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8014f7:	85 d2                	test   %edx,%edx
  8014f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8014fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801501:	89 f3                	mov    %esi,%ebx
  801503:	89 3c 24             	mov    %edi,(%esp)
  801506:	89 74 24 04          	mov    %esi,0x4(%esp)
  80150a:	75 1c                	jne    801528 <__umoddi3+0x48>
  80150c:	39 f7                	cmp    %esi,%edi
  80150e:	76 50                	jbe    801560 <__umoddi3+0x80>
  801510:	89 c8                	mov    %ecx,%eax
  801512:	89 f2                	mov    %esi,%edx
  801514:	f7 f7                	div    %edi
  801516:	89 d0                	mov    %edx,%eax
  801518:	31 d2                	xor    %edx,%edx
  80151a:	83 c4 1c             	add    $0x1c,%esp
  80151d:	5b                   	pop    %ebx
  80151e:	5e                   	pop    %esi
  80151f:	5f                   	pop    %edi
  801520:	5d                   	pop    %ebp
  801521:	c3                   	ret    
  801522:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801528:	39 f2                	cmp    %esi,%edx
  80152a:	89 d0                	mov    %edx,%eax
  80152c:	77 52                	ja     801580 <__umoddi3+0xa0>
  80152e:	0f bd ea             	bsr    %edx,%ebp
  801531:	83 f5 1f             	xor    $0x1f,%ebp
  801534:	75 5a                	jne    801590 <__umoddi3+0xb0>
  801536:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80153a:	0f 82 e0 00 00 00    	jb     801620 <__umoddi3+0x140>
  801540:	39 0c 24             	cmp    %ecx,(%esp)
  801543:	0f 86 d7 00 00 00    	jbe    801620 <__umoddi3+0x140>
  801549:	8b 44 24 08          	mov    0x8(%esp),%eax
  80154d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801551:	83 c4 1c             	add    $0x1c,%esp
  801554:	5b                   	pop    %ebx
  801555:	5e                   	pop    %esi
  801556:	5f                   	pop    %edi
  801557:	5d                   	pop    %ebp
  801558:	c3                   	ret    
  801559:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801560:	85 ff                	test   %edi,%edi
  801562:	89 fd                	mov    %edi,%ebp
  801564:	75 0b                	jne    801571 <__umoddi3+0x91>
  801566:	b8 01 00 00 00       	mov    $0x1,%eax
  80156b:	31 d2                	xor    %edx,%edx
  80156d:	f7 f7                	div    %edi
  80156f:	89 c5                	mov    %eax,%ebp
  801571:	89 f0                	mov    %esi,%eax
  801573:	31 d2                	xor    %edx,%edx
  801575:	f7 f5                	div    %ebp
  801577:	89 c8                	mov    %ecx,%eax
  801579:	f7 f5                	div    %ebp
  80157b:	89 d0                	mov    %edx,%eax
  80157d:	eb 99                	jmp    801518 <__umoddi3+0x38>
  80157f:	90                   	nop
  801580:	89 c8                	mov    %ecx,%eax
  801582:	89 f2                	mov    %esi,%edx
  801584:	83 c4 1c             	add    $0x1c,%esp
  801587:	5b                   	pop    %ebx
  801588:	5e                   	pop    %esi
  801589:	5f                   	pop    %edi
  80158a:	5d                   	pop    %ebp
  80158b:	c3                   	ret    
  80158c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801590:	8b 34 24             	mov    (%esp),%esi
  801593:	bf 20 00 00 00       	mov    $0x20,%edi
  801598:	89 e9                	mov    %ebp,%ecx
  80159a:	29 ef                	sub    %ebp,%edi
  80159c:	d3 e0                	shl    %cl,%eax
  80159e:	89 f9                	mov    %edi,%ecx
  8015a0:	89 f2                	mov    %esi,%edx
  8015a2:	d3 ea                	shr    %cl,%edx
  8015a4:	89 e9                	mov    %ebp,%ecx
  8015a6:	09 c2                	or     %eax,%edx
  8015a8:	89 d8                	mov    %ebx,%eax
  8015aa:	89 14 24             	mov    %edx,(%esp)
  8015ad:	89 f2                	mov    %esi,%edx
  8015af:	d3 e2                	shl    %cl,%edx
  8015b1:	89 f9                	mov    %edi,%ecx
  8015b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8015bb:	d3 e8                	shr    %cl,%eax
  8015bd:	89 e9                	mov    %ebp,%ecx
  8015bf:	89 c6                	mov    %eax,%esi
  8015c1:	d3 e3                	shl    %cl,%ebx
  8015c3:	89 f9                	mov    %edi,%ecx
  8015c5:	89 d0                	mov    %edx,%eax
  8015c7:	d3 e8                	shr    %cl,%eax
  8015c9:	89 e9                	mov    %ebp,%ecx
  8015cb:	09 d8                	or     %ebx,%eax
  8015cd:	89 d3                	mov    %edx,%ebx
  8015cf:	89 f2                	mov    %esi,%edx
  8015d1:	f7 34 24             	divl   (%esp)
  8015d4:	89 d6                	mov    %edx,%esi
  8015d6:	d3 e3                	shl    %cl,%ebx
  8015d8:	f7 64 24 04          	mull   0x4(%esp)
  8015dc:	39 d6                	cmp    %edx,%esi
  8015de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015e2:	89 d1                	mov    %edx,%ecx
  8015e4:	89 c3                	mov    %eax,%ebx
  8015e6:	72 08                	jb     8015f0 <__umoddi3+0x110>
  8015e8:	75 11                	jne    8015fb <__umoddi3+0x11b>
  8015ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8015ee:	73 0b                	jae    8015fb <__umoddi3+0x11b>
  8015f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8015f4:	1b 14 24             	sbb    (%esp),%edx
  8015f7:	89 d1                	mov    %edx,%ecx
  8015f9:	89 c3                	mov    %eax,%ebx
  8015fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8015ff:	29 da                	sub    %ebx,%edx
  801601:	19 ce                	sbb    %ecx,%esi
  801603:	89 f9                	mov    %edi,%ecx
  801605:	89 f0                	mov    %esi,%eax
  801607:	d3 e0                	shl    %cl,%eax
  801609:	89 e9                	mov    %ebp,%ecx
  80160b:	d3 ea                	shr    %cl,%edx
  80160d:	89 e9                	mov    %ebp,%ecx
  80160f:	d3 ee                	shr    %cl,%esi
  801611:	09 d0                	or     %edx,%eax
  801613:	89 f2                	mov    %esi,%edx
  801615:	83 c4 1c             	add    $0x1c,%esp
  801618:	5b                   	pop    %ebx
  801619:	5e                   	pop    %esi
  80161a:	5f                   	pop    %edi
  80161b:	5d                   	pop    %ebp
  80161c:	c3                   	ret    
  80161d:	8d 76 00             	lea    0x0(%esi),%esi
  801620:	29 f9                	sub    %edi,%ecx
  801622:	19 d6                	sbb    %edx,%esi
  801624:	89 74 24 04          	mov    %esi,0x4(%esp)
  801628:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80162c:	e9 18 ff ff ff       	jmp    801549 <__umoddi3+0x69>
