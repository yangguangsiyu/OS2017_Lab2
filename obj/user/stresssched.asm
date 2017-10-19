
obj/user/stresssched：     文件格式 elf32-i386


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
  80002c:	e8 bc 00 00 00       	call   8000ed <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 42 0b 00 00       	call   800b7f <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 97 0e 00 00       	call   800ee0 <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0a                	je     800057 <umain+0x24>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
  800055:	eb 05                	jmp    80005c <umain+0x29>
		if (fork() == 0)
			break;
	if (i == 20) {
  800057:	83 fb 14             	cmp    $0x14,%ebx
  80005a:	75 0e                	jne    80006a <umain+0x37>
		sys_yield();
  80005c:	e8 3d 0b 00 00       	call   800b9e <sys_yield>
		return;
  800061:	e9 80 00 00 00       	jmp    8000e6 <umain+0xb3>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800066:	f3 90                	pause  
  800068:	eb 0f                	jmp    800079 <umain+0x46>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800070:	6b d6 7c             	imul   $0x7c,%esi,%edx
  800073:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800079:	8b 42 54             	mov    0x54(%edx),%eax
  80007c:	85 c0                	test   %eax,%eax
  80007e:	75 e6                	jne    800066 <umain+0x33>
  800080:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800085:	e8 14 0b 00 00       	call   800b9e <sys_yield>
  80008a:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008f:	a1 04 20 80 00       	mov    0x802004,%eax
  800094:	83 c0 01             	add    $0x1,%eax
  800097:	a3 04 20 80 00       	mov    %eax,0x802004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  80009c:	83 ea 01             	sub    $0x1,%edx
  80009f:	75 ee                	jne    80008f <umain+0x5c>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000a1:	83 eb 01             	sub    $0x1,%ebx
  8000a4:	75 df                	jne    800085 <umain+0x52>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000a6:	a1 04 20 80 00       	mov    0x802004,%eax
  8000ab:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b0:	74 17                	je     8000c9 <umain+0x96>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b2:	a1 04 20 80 00       	mov    0x802004,%eax
  8000b7:	50                   	push   %eax
  8000b8:	68 40 15 80 00       	push   $0x801540
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 68 15 80 00       	push   $0x801568
  8000c4:	e8 7c 00 00 00       	call   800145 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 08 20 80 00       	mov    0x802008,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 7b 15 80 00       	push   $0x80157b
  8000de:	e8 3b 01 00 00       	call   80021e <cprintf>
  8000e3:	83 c4 10             	add    $0x10,%esp

}
  8000e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000f8:	e8 82 0a 00 00       	call   800b7f <sys_getenvid>
  8000fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800102:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010a:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010f:	85 db                	test   %ebx,%ebx
  800111:	7e 07                	jle    80011a <libmain+0x2d>
		binaryname = argv[0];
  800113:	8b 06                	mov    (%esi),%eax
  800115:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	56                   	push   %esi
  80011e:	53                   	push   %ebx
  80011f:	e8 0f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800124:	e8 0a 00 00 00       	call   800133 <exit>
}
  800129:	83 c4 10             	add    $0x10,%esp
  80012c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012f:	5b                   	pop    %ebx
  800130:	5e                   	pop    %esi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800139:	6a 00                	push   $0x0
  80013b:	e8 fe 09 00 00       	call   800b3e <sys_env_destroy>
}
  800140:	83 c4 10             	add    $0x10,%esp
  800143:	c9                   	leave  
  800144:	c3                   	ret    

00800145 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80014a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014d:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800153:	e8 27 0a 00 00       	call   800b7f <sys_getenvid>
  800158:	83 ec 0c             	sub    $0xc,%esp
  80015b:	ff 75 0c             	pushl  0xc(%ebp)
  80015e:	ff 75 08             	pushl  0x8(%ebp)
  800161:	56                   	push   %esi
  800162:	50                   	push   %eax
  800163:	68 a4 15 80 00       	push   $0x8015a4
  800168:	e8 b1 00 00 00       	call   80021e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80016d:	83 c4 18             	add    $0x18,%esp
  800170:	53                   	push   %ebx
  800171:	ff 75 10             	pushl  0x10(%ebp)
  800174:	e8 54 00 00 00       	call   8001cd <vcprintf>
	cprintf("\n");
  800179:	c7 04 24 97 15 80 00 	movl   $0x801597,(%esp)
  800180:	e8 99 00 00 00       	call   80021e <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800188:	cc                   	int3   
  800189:	eb fd                	jmp    800188 <_panic+0x43>

0080018b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018b:	55                   	push   %ebp
  80018c:	89 e5                	mov    %esp,%ebp
  80018e:	53                   	push   %ebx
  80018f:	83 ec 04             	sub    $0x4,%esp
  800192:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800195:	8b 13                	mov    (%ebx),%edx
  800197:	8d 42 01             	lea    0x1(%edx),%eax
  80019a:	89 03                	mov    %eax,(%ebx)
  80019c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80019f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a8:	75 1a                	jne    8001c4 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001aa:	83 ec 08             	sub    $0x8,%esp
  8001ad:	68 ff 00 00 00       	push   $0xff
  8001b2:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b5:	50                   	push   %eax
  8001b6:	e8 46 09 00 00       	call   800b01 <sys_cputs>
		b->idx = 0;
  8001bb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c1:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001c4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001cb:	c9                   	leave  
  8001cc:	c3                   	ret    

008001cd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001dd:	00 00 00 
	b.cnt = 0;
  8001e0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ea:	ff 75 0c             	pushl  0xc(%ebp)
  8001ed:	ff 75 08             	pushl  0x8(%ebp)
  8001f0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f6:	50                   	push   %eax
  8001f7:	68 8b 01 80 00       	push   $0x80018b
  8001fc:	e8 54 01 00 00       	call   800355 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800201:	83 c4 08             	add    $0x8,%esp
  800204:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80020a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800210:	50                   	push   %eax
  800211:	e8 eb 08 00 00       	call   800b01 <sys_cputs>

	return b.cnt;
}
  800216:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021c:	c9                   	leave  
  80021d:	c3                   	ret    

0080021e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800224:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800227:	50                   	push   %eax
  800228:	ff 75 08             	pushl  0x8(%ebp)
  80022b:	e8 9d ff ff ff       	call   8001cd <vcprintf>
	va_end(ap);

	return cnt;
}
  800230:	c9                   	leave  
  800231:	c3                   	ret    

00800232 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	57                   	push   %edi
  800236:	56                   	push   %esi
  800237:	53                   	push   %ebx
  800238:	83 ec 1c             	sub    $0x1c,%esp
  80023b:	89 c7                	mov    %eax,%edi
  80023d:	89 d6                	mov    %edx,%esi
  80023f:	8b 45 08             	mov    0x8(%ebp),%eax
  800242:	8b 55 0c             	mov    0xc(%ebp),%edx
  800245:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800248:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80024e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800253:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800256:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800259:	39 d3                	cmp    %edx,%ebx
  80025b:	72 05                	jb     800262 <printnum+0x30>
  80025d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800260:	77 45                	ja     8002a7 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800262:	83 ec 0c             	sub    $0xc,%esp
  800265:	ff 75 18             	pushl  0x18(%ebp)
  800268:	8b 45 14             	mov    0x14(%ebp),%eax
  80026b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80026e:	53                   	push   %ebx
  80026f:	ff 75 10             	pushl  0x10(%ebp)
  800272:	83 ec 08             	sub    $0x8,%esp
  800275:	ff 75 e4             	pushl  -0x1c(%ebp)
  800278:	ff 75 e0             	pushl  -0x20(%ebp)
  80027b:	ff 75 dc             	pushl  -0x24(%ebp)
  80027e:	ff 75 d8             	pushl  -0x28(%ebp)
  800281:	e8 1a 10 00 00       	call   8012a0 <__udivdi3>
  800286:	83 c4 18             	add    $0x18,%esp
  800289:	52                   	push   %edx
  80028a:	50                   	push   %eax
  80028b:	89 f2                	mov    %esi,%edx
  80028d:	89 f8                	mov    %edi,%eax
  80028f:	e8 9e ff ff ff       	call   800232 <printnum>
  800294:	83 c4 20             	add    $0x20,%esp
  800297:	eb 18                	jmp    8002b1 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800299:	83 ec 08             	sub    $0x8,%esp
  80029c:	56                   	push   %esi
  80029d:	ff 75 18             	pushl  0x18(%ebp)
  8002a0:	ff d7                	call   *%edi
  8002a2:	83 c4 10             	add    $0x10,%esp
  8002a5:	eb 03                	jmp    8002aa <printnum+0x78>
  8002a7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002aa:	83 eb 01             	sub    $0x1,%ebx
  8002ad:	85 db                	test   %ebx,%ebx
  8002af:	7f e8                	jg     800299 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b1:	83 ec 08             	sub    $0x8,%esp
  8002b4:	56                   	push   %esi
  8002b5:	83 ec 04             	sub    $0x4,%esp
  8002b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8002be:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c4:	e8 07 11 00 00       	call   8013d0 <__umoddi3>
  8002c9:	83 c4 14             	add    $0x14,%esp
  8002cc:	0f be 80 c7 15 80 00 	movsbl 0x8015c7(%eax),%eax
  8002d3:	50                   	push   %eax
  8002d4:	ff d7                	call   *%edi
}
  8002d6:	83 c4 10             	add    $0x10,%esp
  8002d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dc:	5b                   	pop    %ebx
  8002dd:	5e                   	pop    %esi
  8002de:	5f                   	pop    %edi
  8002df:	5d                   	pop    %ebp
  8002e0:	c3                   	ret    

008002e1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e4:	83 fa 01             	cmp    $0x1,%edx
  8002e7:	7e 0e                	jle    8002f7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e9:	8b 10                	mov    (%eax),%edx
  8002eb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ee:	89 08                	mov    %ecx,(%eax)
  8002f0:	8b 02                	mov    (%edx),%eax
  8002f2:	8b 52 04             	mov    0x4(%edx),%edx
  8002f5:	eb 22                	jmp    800319 <getuint+0x38>
	else if (lflag)
  8002f7:	85 d2                	test   %edx,%edx
  8002f9:	74 10                	je     80030b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002fb:	8b 10                	mov    (%eax),%edx
  8002fd:	8d 4a 04             	lea    0x4(%edx),%ecx
  800300:	89 08                	mov    %ecx,(%eax)
  800302:	8b 02                	mov    (%edx),%eax
  800304:	ba 00 00 00 00       	mov    $0x0,%edx
  800309:	eb 0e                	jmp    800319 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80030b:	8b 10                	mov    (%eax),%edx
  80030d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800310:	89 08                	mov    %ecx,(%eax)
  800312:	8b 02                	mov    (%edx),%eax
  800314:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800319:	5d                   	pop    %ebp
  80031a:	c3                   	ret    

0080031b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800321:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800325:	8b 10                	mov    (%eax),%edx
  800327:	3b 50 04             	cmp    0x4(%eax),%edx
  80032a:	73 0a                	jae    800336 <sprintputch+0x1b>
		*b->buf++ = ch;
  80032c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80032f:	89 08                	mov    %ecx,(%eax)
  800331:	8b 45 08             	mov    0x8(%ebp),%eax
  800334:	88 02                	mov    %al,(%edx)
}
  800336:	5d                   	pop    %ebp
  800337:	c3                   	ret    

00800338 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
  80033b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80033e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800341:	50                   	push   %eax
  800342:	ff 75 10             	pushl  0x10(%ebp)
  800345:	ff 75 0c             	pushl  0xc(%ebp)
  800348:	ff 75 08             	pushl  0x8(%ebp)
  80034b:	e8 05 00 00 00       	call   800355 <vprintfmt>
	va_end(ap);
}
  800350:	83 c4 10             	add    $0x10,%esp
  800353:	c9                   	leave  
  800354:	c3                   	ret    

00800355 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
  800358:	57                   	push   %edi
  800359:	56                   	push   %esi
  80035a:	53                   	push   %ebx
  80035b:	83 ec 2c             	sub    $0x2c,%esp
  80035e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
  800361:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800368:	eb 17                	jmp    800381 <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80036a:	85 c0                	test   %eax,%eax
  80036c:	0f 84 9f 03 00 00    	je     800711 <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
  800372:	83 ec 08             	sub    $0x8,%esp
  800375:	ff 75 0c             	pushl  0xc(%ebp)
  800378:	50                   	push   %eax
  800379:	ff 55 08             	call   *0x8(%ebp)
  80037c:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80037f:	89 f3                	mov    %esi,%ebx
  800381:	8d 73 01             	lea    0x1(%ebx),%esi
  800384:	0f b6 03             	movzbl (%ebx),%eax
  800387:	83 f8 25             	cmp    $0x25,%eax
  80038a:	75 de                	jne    80036a <vprintfmt+0x15>
  80038c:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800390:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800397:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80039c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a8:	eb 06                	jmp    8003b0 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003ac:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003b3:	0f b6 06             	movzbl (%esi),%eax
  8003b6:	0f b6 c8             	movzbl %al,%ecx
  8003b9:	83 e8 23             	sub    $0x23,%eax
  8003bc:	3c 55                	cmp    $0x55,%al
  8003be:	0f 87 2d 03 00 00    	ja     8006f1 <vprintfmt+0x39c>
  8003c4:	0f b6 c0             	movzbl %al,%eax
  8003c7:	ff 24 85 80 16 80 00 	jmp    *0x801680(,%eax,4)
  8003ce:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d0:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003d4:	eb da                	jmp    8003b0 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	89 de                	mov    %ebx,%esi
  8003d8:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003dd:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  8003e0:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  8003e4:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  8003e7:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8003ea:	83 f8 09             	cmp    $0x9,%eax
  8003ed:	77 33                	ja     800422 <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ef:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003f2:	eb e9                	jmp    8003dd <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f7:	8d 48 04             	lea    0x4(%eax),%ecx
  8003fa:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003fd:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800401:	eb 1f                	jmp    800422 <vprintfmt+0xcd>
  800403:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800406:	85 c0                	test   %eax,%eax
  800408:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040d:	0f 49 c8             	cmovns %eax,%ecx
  800410:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800413:	89 de                	mov    %ebx,%esi
  800415:	eb 99                	jmp    8003b0 <vprintfmt+0x5b>
  800417:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800419:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  800420:	eb 8e                	jmp    8003b0 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  800422:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800426:	79 88                	jns    8003b0 <vprintfmt+0x5b>
				width = precision, precision = -1;
  800428:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80042b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800430:	e9 7b ff ff ff       	jmp    8003b0 <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800435:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800438:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80043a:	e9 71 ff ff ff       	jmp    8003b0 <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
  80043f:	8b 45 14             	mov    0x14(%ebp),%eax
  800442:	8d 50 04             	lea    0x4(%eax),%edx
  800445:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  800448:	83 ec 08             	sub    $0x8,%esp
  80044b:	ff 75 0c             	pushl  0xc(%ebp)
  80044e:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800451:	03 08                	add    (%eax),%ecx
  800453:	51                   	push   %ecx
  800454:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
  800457:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
  80045a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
  800461:	e9 1b ff ff ff       	jmp    800381 <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
  800466:	8b 45 14             	mov    0x14(%ebp),%eax
  800469:	8d 48 04             	lea    0x4(%eax),%ecx
  80046c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80046f:	8b 00                	mov    (%eax),%eax
  800471:	83 f8 02             	cmp    $0x2,%eax
  800474:	74 1a                	je     800490 <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800476:	89 de                	mov    %ebx,%esi
  800478:	83 f8 04             	cmp    $0x4,%eax
  80047b:	b8 00 00 00 00       	mov    $0x0,%eax
  800480:	b9 00 04 00 00       	mov    $0x400,%ecx
  800485:	0f 44 c1             	cmove  %ecx,%eax
  800488:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80048b:	e9 20 ff ff ff       	jmp    8003b0 <vprintfmt+0x5b>
  800490:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
  800492:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
  800499:	e9 12 ff ff ff       	jmp    8003b0 <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80049e:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a1:	8d 50 04             	lea    0x4(%eax),%edx
  8004a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a7:	8b 00                	mov    (%eax),%eax
  8004a9:	99                   	cltd   
  8004aa:	31 d0                	xor    %edx,%eax
  8004ac:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ae:	83 f8 09             	cmp    $0x9,%eax
  8004b1:	7f 0b                	jg     8004be <vprintfmt+0x169>
  8004b3:	8b 14 85 e0 17 80 00 	mov    0x8017e0(,%eax,4),%edx
  8004ba:	85 d2                	test   %edx,%edx
  8004bc:	75 19                	jne    8004d7 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  8004be:	50                   	push   %eax
  8004bf:	68 df 15 80 00       	push   $0x8015df
  8004c4:	ff 75 0c             	pushl  0xc(%ebp)
  8004c7:	ff 75 08             	pushl  0x8(%ebp)
  8004ca:	e8 69 fe ff ff       	call   800338 <printfmt>
  8004cf:	83 c4 10             	add    $0x10,%esp
  8004d2:	e9 aa fe ff ff       	jmp    800381 <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  8004d7:	52                   	push   %edx
  8004d8:	68 e8 15 80 00       	push   $0x8015e8
  8004dd:	ff 75 0c             	pushl  0xc(%ebp)
  8004e0:	ff 75 08             	pushl  0x8(%ebp)
  8004e3:	e8 50 fe ff ff       	call   800338 <printfmt>
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	e9 91 fe ff ff       	jmp    800381 <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f3:	8d 50 04             	lea    0x4(%eax),%edx
  8004f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f9:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004fb:	85 f6                	test   %esi,%esi
  8004fd:	b8 d8 15 80 00       	mov    $0x8015d8,%eax
  800502:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800505:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800509:	0f 8e 93 00 00 00    	jle    8005a2 <vprintfmt+0x24d>
  80050f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800513:	0f 84 91 00 00 00    	je     8005aa <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
  800519:	83 ec 08             	sub    $0x8,%esp
  80051c:	57                   	push   %edi
  80051d:	56                   	push   %esi
  80051e:	e8 76 02 00 00       	call   800799 <strnlen>
  800523:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800526:	29 c1                	sub    %eax,%ecx
  800528:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80052b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80052e:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  800532:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800535:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800538:	8b 75 0c             	mov    0xc(%ebp),%esi
  80053b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80053e:	89 cb                	mov    %ecx,%ebx
  800540:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800542:	eb 0e                	jmp    800552 <vprintfmt+0x1fd>
					putch(padc, putdat);
  800544:	83 ec 08             	sub    $0x8,%esp
  800547:	56                   	push   %esi
  800548:	57                   	push   %edi
  800549:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80054c:	83 eb 01             	sub    $0x1,%ebx
  80054f:	83 c4 10             	add    $0x10,%esp
  800552:	85 db                	test   %ebx,%ebx
  800554:	7f ee                	jg     800544 <vprintfmt+0x1ef>
  800556:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800559:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80055c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80055f:	85 c9                	test   %ecx,%ecx
  800561:	b8 00 00 00 00       	mov    $0x0,%eax
  800566:	0f 49 c1             	cmovns %ecx,%eax
  800569:	29 c1                	sub    %eax,%ecx
  80056b:	89 cb                	mov    %ecx,%ebx
  80056d:	eb 41                	jmp    8005b0 <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80056f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800573:	74 1b                	je     800590 <vprintfmt+0x23b>
  800575:	0f be c0             	movsbl %al,%eax
  800578:	83 e8 20             	sub    $0x20,%eax
  80057b:	83 f8 5e             	cmp    $0x5e,%eax
  80057e:	76 10                	jbe    800590 <vprintfmt+0x23b>
					putch('?', putdat);
  800580:	83 ec 08             	sub    $0x8,%esp
  800583:	ff 75 0c             	pushl  0xc(%ebp)
  800586:	6a 3f                	push   $0x3f
  800588:	ff 55 08             	call   *0x8(%ebp)
  80058b:	83 c4 10             	add    $0x10,%esp
  80058e:	eb 0d                	jmp    80059d <vprintfmt+0x248>
				else
					putch(ch, putdat);
  800590:	83 ec 08             	sub    $0x8,%esp
  800593:	ff 75 0c             	pushl  0xc(%ebp)
  800596:	52                   	push   %edx
  800597:	ff 55 08             	call   *0x8(%ebp)
  80059a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059d:	83 eb 01             	sub    $0x1,%ebx
  8005a0:	eb 0e                	jmp    8005b0 <vprintfmt+0x25b>
  8005a2:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005a5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a8:	eb 06                	jmp    8005b0 <vprintfmt+0x25b>
  8005aa:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005ad:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005b0:	83 c6 01             	add    $0x1,%esi
  8005b3:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8005b7:	0f be d0             	movsbl %al,%edx
  8005ba:	85 d2                	test   %edx,%edx
  8005bc:	74 25                	je     8005e3 <vprintfmt+0x28e>
  8005be:	85 ff                	test   %edi,%edi
  8005c0:	78 ad                	js     80056f <vprintfmt+0x21a>
  8005c2:	83 ef 01             	sub    $0x1,%edi
  8005c5:	79 a8                	jns    80056f <vprintfmt+0x21a>
  8005c7:	89 d8                	mov    %ebx,%eax
  8005c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8005cc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005cf:	89 c3                	mov    %eax,%ebx
  8005d1:	eb 16                	jmp    8005e9 <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005d3:	83 ec 08             	sub    $0x8,%esp
  8005d6:	57                   	push   %edi
  8005d7:	6a 20                	push   $0x20
  8005d9:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005db:	83 eb 01             	sub    $0x1,%ebx
  8005de:	83 c4 10             	add    $0x10,%esp
  8005e1:	eb 06                	jmp    8005e9 <vprintfmt+0x294>
  8005e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005e9:	85 db                	test   %ebx,%ebx
  8005eb:	7f e6                	jg     8005d3 <vprintfmt+0x27e>
  8005ed:	89 75 08             	mov    %esi,0x8(%ebp)
  8005f0:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005f6:	e9 86 fd ff ff       	jmp    800381 <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005fb:	83 fa 01             	cmp    $0x1,%edx
  8005fe:	7e 10                	jle    800610 <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 50 08             	lea    0x8(%eax),%edx
  800606:	89 55 14             	mov    %edx,0x14(%ebp)
  800609:	8b 30                	mov    (%eax),%esi
  80060b:	8b 78 04             	mov    0x4(%eax),%edi
  80060e:	eb 26                	jmp    800636 <vprintfmt+0x2e1>
	else if (lflag)
  800610:	85 d2                	test   %edx,%edx
  800612:	74 12                	je     800626 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8d 50 04             	lea    0x4(%eax),%edx
  80061a:	89 55 14             	mov    %edx,0x14(%ebp)
  80061d:	8b 30                	mov    (%eax),%esi
  80061f:	89 f7                	mov    %esi,%edi
  800621:	c1 ff 1f             	sar    $0x1f,%edi
  800624:	eb 10                	jmp    800636 <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8d 50 04             	lea    0x4(%eax),%edx
  80062c:	89 55 14             	mov    %edx,0x14(%ebp)
  80062f:	8b 30                	mov    (%eax),%esi
  800631:	89 f7                	mov    %esi,%edi
  800633:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800636:	89 f0                	mov    %esi,%eax
  800638:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80063a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80063f:	85 ff                	test   %edi,%edi
  800641:	79 7b                	jns    8006be <vprintfmt+0x369>
				putch('-', putdat);
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	ff 75 0c             	pushl  0xc(%ebp)
  800649:	6a 2d                	push   $0x2d
  80064b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80064e:	89 f0                	mov    %esi,%eax
  800650:	89 fa                	mov    %edi,%edx
  800652:	f7 d8                	neg    %eax
  800654:	83 d2 00             	adc    $0x0,%edx
  800657:	f7 da                	neg    %edx
  800659:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80065c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800661:	eb 5b                	jmp    8006be <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800663:	8d 45 14             	lea    0x14(%ebp),%eax
  800666:	e8 76 fc ff ff       	call   8002e1 <getuint>
			base = 10;
  80066b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800670:	eb 4c                	jmp    8006be <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
  800672:	8d 45 14             	lea    0x14(%ebp),%eax
  800675:	e8 67 fc ff ff       	call   8002e1 <getuint>
            base = 8;
  80067a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80067f:	eb 3d                	jmp    8006be <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
  800681:	83 ec 08             	sub    $0x8,%esp
  800684:	ff 75 0c             	pushl  0xc(%ebp)
  800687:	6a 30                	push   $0x30
  800689:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80068c:	83 c4 08             	add    $0x8,%esp
  80068f:	ff 75 0c             	pushl  0xc(%ebp)
  800692:	6a 78                	push   $0x78
  800694:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8d 50 04             	lea    0x4(%eax),%edx
  80069d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a0:	8b 00                	mov    (%eax),%eax
  8006a2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006aa:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006af:	eb 0d                	jmp    8006be <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b4:	e8 28 fc ff ff       	call   8002e1 <getuint>
			base = 16;
  8006b9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006be:	83 ec 0c             	sub    $0xc,%esp
  8006c1:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  8006c5:	56                   	push   %esi
  8006c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c9:	51                   	push   %ecx
  8006ca:	52                   	push   %edx
  8006cb:	50                   	push   %eax
  8006cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d2:	e8 5b fb ff ff       	call   800232 <printnum>
			break;
  8006d7:	83 c4 20             	add    $0x20,%esp
  8006da:	e9 a2 fc ff ff       	jmp    800381 <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	ff 75 0c             	pushl  0xc(%ebp)
  8006e5:	51                   	push   %ecx
  8006e6:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006e9:	83 c4 10             	add    $0x10,%esp
  8006ec:	e9 90 fc ff ff       	jmp    800381 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f1:	83 ec 08             	sub    $0x8,%esp
  8006f4:	ff 75 0c             	pushl  0xc(%ebp)
  8006f7:	6a 25                	push   $0x25
  8006f9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fc:	83 c4 10             	add    $0x10,%esp
  8006ff:	89 f3                	mov    %esi,%ebx
  800701:	eb 03                	jmp    800706 <vprintfmt+0x3b1>
  800703:	83 eb 01             	sub    $0x1,%ebx
  800706:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80070a:	75 f7                	jne    800703 <vprintfmt+0x3ae>
  80070c:	e9 70 fc ff ff       	jmp    800381 <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  800711:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800714:	5b                   	pop    %ebx
  800715:	5e                   	pop    %esi
  800716:	5f                   	pop    %edi
  800717:	5d                   	pop    %ebp
  800718:	c3                   	ret    

00800719 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800719:	55                   	push   %ebp
  80071a:	89 e5                	mov    %esp,%ebp
  80071c:	83 ec 18             	sub    $0x18,%esp
  80071f:	8b 45 08             	mov    0x8(%ebp),%eax
  800722:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800725:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800728:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80072c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800736:	85 c0                	test   %eax,%eax
  800738:	74 26                	je     800760 <vsnprintf+0x47>
  80073a:	85 d2                	test   %edx,%edx
  80073c:	7e 22                	jle    800760 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073e:	ff 75 14             	pushl  0x14(%ebp)
  800741:	ff 75 10             	pushl  0x10(%ebp)
  800744:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800747:	50                   	push   %eax
  800748:	68 1b 03 80 00       	push   $0x80031b
  80074d:	e8 03 fc ff ff       	call   800355 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800752:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800755:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800758:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075b:	83 c4 10             	add    $0x10,%esp
  80075e:	eb 05                	jmp    800765 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800760:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800765:	c9                   	leave  
  800766:	c3                   	ret    

00800767 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800770:	50                   	push   %eax
  800771:	ff 75 10             	pushl  0x10(%ebp)
  800774:	ff 75 0c             	pushl  0xc(%ebp)
  800777:	ff 75 08             	pushl  0x8(%ebp)
  80077a:	e8 9a ff ff ff       	call   800719 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077f:	c9                   	leave  
  800780:	c3                   	ret    

00800781 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800787:	b8 00 00 00 00       	mov    $0x0,%eax
  80078c:	eb 03                	jmp    800791 <strlen+0x10>
		n++;
  80078e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800791:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800795:	75 f7                	jne    80078e <strlen+0xd>
		n++;
	return n;
}
  800797:	5d                   	pop    %ebp
  800798:	c3                   	ret    

00800799 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a7:	eb 03                	jmp    8007ac <strnlen+0x13>
		n++;
  8007a9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ac:	39 c2                	cmp    %eax,%edx
  8007ae:	74 08                	je     8007b8 <strnlen+0x1f>
  8007b0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b4:	75 f3                	jne    8007a9 <strnlen+0x10>
  8007b6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	53                   	push   %ebx
  8007be:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c4:	89 c2                	mov    %eax,%edx
  8007c6:	83 c2 01             	add    $0x1,%edx
  8007c9:	83 c1 01             	add    $0x1,%ecx
  8007cc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007d0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d3:	84 db                	test   %bl,%bl
  8007d5:	75 ef                	jne    8007c6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d7:	5b                   	pop    %ebx
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    

008007da <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	53                   	push   %ebx
  8007de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e1:	53                   	push   %ebx
  8007e2:	e8 9a ff ff ff       	call   800781 <strlen>
  8007e7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ea:	ff 75 0c             	pushl  0xc(%ebp)
  8007ed:	01 d8                	add    %ebx,%eax
  8007ef:	50                   	push   %eax
  8007f0:	e8 c5 ff ff ff       	call   8007ba <strcpy>
	return dst;
}
  8007f5:	89 d8                	mov    %ebx,%eax
  8007f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fa:	c9                   	leave  
  8007fb:	c3                   	ret    

008007fc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	56                   	push   %esi
  800800:	53                   	push   %ebx
  800801:	8b 75 08             	mov    0x8(%ebp),%esi
  800804:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800807:	89 f3                	mov    %esi,%ebx
  800809:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080c:	89 f2                	mov    %esi,%edx
  80080e:	eb 0f                	jmp    80081f <strncpy+0x23>
		*dst++ = *src;
  800810:	83 c2 01             	add    $0x1,%edx
  800813:	0f b6 01             	movzbl (%ecx),%eax
  800816:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800819:	80 39 01             	cmpb   $0x1,(%ecx)
  80081c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081f:	39 da                	cmp    %ebx,%edx
  800821:	75 ed                	jne    800810 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800823:	89 f0                	mov    %esi,%eax
  800825:	5b                   	pop    %ebx
  800826:	5e                   	pop    %esi
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    

00800829 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	56                   	push   %esi
  80082d:	53                   	push   %ebx
  80082e:	8b 75 08             	mov    0x8(%ebp),%esi
  800831:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800834:	8b 55 10             	mov    0x10(%ebp),%edx
  800837:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800839:	85 d2                	test   %edx,%edx
  80083b:	74 21                	je     80085e <strlcpy+0x35>
  80083d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800841:	89 f2                	mov    %esi,%edx
  800843:	eb 09                	jmp    80084e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800845:	83 c2 01             	add    $0x1,%edx
  800848:	83 c1 01             	add    $0x1,%ecx
  80084b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80084e:	39 c2                	cmp    %eax,%edx
  800850:	74 09                	je     80085b <strlcpy+0x32>
  800852:	0f b6 19             	movzbl (%ecx),%ebx
  800855:	84 db                	test   %bl,%bl
  800857:	75 ec                	jne    800845 <strlcpy+0x1c>
  800859:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80085b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085e:	29 f0                	sub    %esi,%eax
}
  800860:	5b                   	pop    %ebx
  800861:	5e                   	pop    %esi
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80086d:	eb 06                	jmp    800875 <strcmp+0x11>
		p++, q++;
  80086f:	83 c1 01             	add    $0x1,%ecx
  800872:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800875:	0f b6 01             	movzbl (%ecx),%eax
  800878:	84 c0                	test   %al,%al
  80087a:	74 04                	je     800880 <strcmp+0x1c>
  80087c:	3a 02                	cmp    (%edx),%al
  80087e:	74 ef                	je     80086f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800880:	0f b6 c0             	movzbl %al,%eax
  800883:	0f b6 12             	movzbl (%edx),%edx
  800886:	29 d0                	sub    %edx,%eax
}
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	53                   	push   %ebx
  80088e:	8b 45 08             	mov    0x8(%ebp),%eax
  800891:	8b 55 0c             	mov    0xc(%ebp),%edx
  800894:	89 c3                	mov    %eax,%ebx
  800896:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800899:	eb 06                	jmp    8008a1 <strncmp+0x17>
		n--, p++, q++;
  80089b:	83 c0 01             	add    $0x1,%eax
  80089e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a1:	39 d8                	cmp    %ebx,%eax
  8008a3:	74 15                	je     8008ba <strncmp+0x30>
  8008a5:	0f b6 08             	movzbl (%eax),%ecx
  8008a8:	84 c9                	test   %cl,%cl
  8008aa:	74 04                	je     8008b0 <strncmp+0x26>
  8008ac:	3a 0a                	cmp    (%edx),%cl
  8008ae:	74 eb                	je     80089b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b0:	0f b6 00             	movzbl (%eax),%eax
  8008b3:	0f b6 12             	movzbl (%edx),%edx
  8008b6:	29 d0                	sub    %edx,%eax
  8008b8:	eb 05                	jmp    8008bf <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ba:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008bf:	5b                   	pop    %ebx
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cc:	eb 07                	jmp    8008d5 <strchr+0x13>
		if (*s == c)
  8008ce:	38 ca                	cmp    %cl,%dl
  8008d0:	74 0f                	je     8008e1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d2:	83 c0 01             	add    $0x1,%eax
  8008d5:	0f b6 10             	movzbl (%eax),%edx
  8008d8:	84 d2                	test   %dl,%dl
  8008da:	75 f2                	jne    8008ce <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ed:	eb 03                	jmp    8008f2 <strfind+0xf>
  8008ef:	83 c0 01             	add    $0x1,%eax
  8008f2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f5:	38 ca                	cmp    %cl,%dl
  8008f7:	74 04                	je     8008fd <strfind+0x1a>
  8008f9:	84 d2                	test   %dl,%dl
  8008fb:	75 f2                	jne    8008ef <strfind+0xc>
			break;
	return (char *) s;
}
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	57                   	push   %edi
  800903:	56                   	push   %esi
  800904:	53                   	push   %ebx
  800905:	8b 7d 08             	mov    0x8(%ebp),%edi
  800908:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80090b:	85 c9                	test   %ecx,%ecx
  80090d:	74 36                	je     800945 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800915:	75 28                	jne    80093f <memset+0x40>
  800917:	f6 c1 03             	test   $0x3,%cl
  80091a:	75 23                	jne    80093f <memset+0x40>
		c &= 0xFF;
  80091c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800920:	89 d3                	mov    %edx,%ebx
  800922:	c1 e3 08             	shl    $0x8,%ebx
  800925:	89 d6                	mov    %edx,%esi
  800927:	c1 e6 18             	shl    $0x18,%esi
  80092a:	89 d0                	mov    %edx,%eax
  80092c:	c1 e0 10             	shl    $0x10,%eax
  80092f:	09 f0                	or     %esi,%eax
  800931:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800933:	89 d8                	mov    %ebx,%eax
  800935:	09 d0                	or     %edx,%eax
  800937:	c1 e9 02             	shr    $0x2,%ecx
  80093a:	fc                   	cld    
  80093b:	f3 ab                	rep stos %eax,%es:(%edi)
  80093d:	eb 06                	jmp    800945 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800942:	fc                   	cld    
  800943:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800945:	89 f8                	mov    %edi,%eax
  800947:	5b                   	pop    %ebx
  800948:	5e                   	pop    %esi
  800949:	5f                   	pop    %edi
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	57                   	push   %edi
  800950:	56                   	push   %esi
  800951:	8b 45 08             	mov    0x8(%ebp),%eax
  800954:	8b 75 0c             	mov    0xc(%ebp),%esi
  800957:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80095a:	39 c6                	cmp    %eax,%esi
  80095c:	73 35                	jae    800993 <memmove+0x47>
  80095e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800961:	39 d0                	cmp    %edx,%eax
  800963:	73 2e                	jae    800993 <memmove+0x47>
		s += n;
		d += n;
  800965:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800968:	89 d6                	mov    %edx,%esi
  80096a:	09 fe                	or     %edi,%esi
  80096c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800972:	75 13                	jne    800987 <memmove+0x3b>
  800974:	f6 c1 03             	test   $0x3,%cl
  800977:	75 0e                	jne    800987 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800979:	83 ef 04             	sub    $0x4,%edi
  80097c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097f:	c1 e9 02             	shr    $0x2,%ecx
  800982:	fd                   	std    
  800983:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800985:	eb 09                	jmp    800990 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800987:	83 ef 01             	sub    $0x1,%edi
  80098a:	8d 72 ff             	lea    -0x1(%edx),%esi
  80098d:	fd                   	std    
  80098e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800990:	fc                   	cld    
  800991:	eb 1d                	jmp    8009b0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800993:	89 f2                	mov    %esi,%edx
  800995:	09 c2                	or     %eax,%edx
  800997:	f6 c2 03             	test   $0x3,%dl
  80099a:	75 0f                	jne    8009ab <memmove+0x5f>
  80099c:	f6 c1 03             	test   $0x3,%cl
  80099f:	75 0a                	jne    8009ab <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009a1:	c1 e9 02             	shr    $0x2,%ecx
  8009a4:	89 c7                	mov    %eax,%edi
  8009a6:	fc                   	cld    
  8009a7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a9:	eb 05                	jmp    8009b0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ab:	89 c7                	mov    %eax,%edi
  8009ad:	fc                   	cld    
  8009ae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b0:	5e                   	pop    %esi
  8009b1:	5f                   	pop    %edi
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b7:	ff 75 10             	pushl  0x10(%ebp)
  8009ba:	ff 75 0c             	pushl  0xc(%ebp)
  8009bd:	ff 75 08             	pushl  0x8(%ebp)
  8009c0:	e8 87 ff ff ff       	call   80094c <memmove>
}
  8009c5:	c9                   	leave  
  8009c6:	c3                   	ret    

008009c7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	56                   	push   %esi
  8009cb:	53                   	push   %ebx
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d2:	89 c6                	mov    %eax,%esi
  8009d4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d7:	eb 1a                	jmp    8009f3 <memcmp+0x2c>
		if (*s1 != *s2)
  8009d9:	0f b6 08             	movzbl (%eax),%ecx
  8009dc:	0f b6 1a             	movzbl (%edx),%ebx
  8009df:	38 d9                	cmp    %bl,%cl
  8009e1:	74 0a                	je     8009ed <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e3:	0f b6 c1             	movzbl %cl,%eax
  8009e6:	0f b6 db             	movzbl %bl,%ebx
  8009e9:	29 d8                	sub    %ebx,%eax
  8009eb:	eb 0f                	jmp    8009fc <memcmp+0x35>
		s1++, s2++;
  8009ed:	83 c0 01             	add    $0x1,%eax
  8009f0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f3:	39 f0                	cmp    %esi,%eax
  8009f5:	75 e2                	jne    8009d9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fc:	5b                   	pop    %ebx
  8009fd:	5e                   	pop    %esi
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	53                   	push   %ebx
  800a04:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a07:	89 c1                	mov    %eax,%ecx
  800a09:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a10:	eb 0a                	jmp    800a1c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a12:	0f b6 10             	movzbl (%eax),%edx
  800a15:	39 da                	cmp    %ebx,%edx
  800a17:	74 07                	je     800a20 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a19:	83 c0 01             	add    $0x1,%eax
  800a1c:	39 c8                	cmp    %ecx,%eax
  800a1e:	72 f2                	jb     800a12 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a20:	5b                   	pop    %ebx
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	57                   	push   %edi
  800a27:	56                   	push   %esi
  800a28:	53                   	push   %ebx
  800a29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2f:	eb 03                	jmp    800a34 <strtol+0x11>
		s++;
  800a31:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a34:	0f b6 01             	movzbl (%ecx),%eax
  800a37:	3c 20                	cmp    $0x20,%al
  800a39:	74 f6                	je     800a31 <strtol+0xe>
  800a3b:	3c 09                	cmp    $0x9,%al
  800a3d:	74 f2                	je     800a31 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3f:	3c 2b                	cmp    $0x2b,%al
  800a41:	75 0a                	jne    800a4d <strtol+0x2a>
		s++;
  800a43:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a46:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4b:	eb 11                	jmp    800a5e <strtol+0x3b>
  800a4d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a52:	3c 2d                	cmp    $0x2d,%al
  800a54:	75 08                	jne    800a5e <strtol+0x3b>
		s++, neg = 1;
  800a56:	83 c1 01             	add    $0x1,%ecx
  800a59:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a64:	75 15                	jne    800a7b <strtol+0x58>
  800a66:	80 39 30             	cmpb   $0x30,(%ecx)
  800a69:	75 10                	jne    800a7b <strtol+0x58>
  800a6b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6f:	75 7c                	jne    800aed <strtol+0xca>
		s += 2, base = 16;
  800a71:	83 c1 02             	add    $0x2,%ecx
  800a74:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a79:	eb 16                	jmp    800a91 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a7b:	85 db                	test   %ebx,%ebx
  800a7d:	75 12                	jne    800a91 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a84:	80 39 30             	cmpb   $0x30,(%ecx)
  800a87:	75 08                	jne    800a91 <strtol+0x6e>
		s++, base = 8;
  800a89:	83 c1 01             	add    $0x1,%ecx
  800a8c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a91:	b8 00 00 00 00       	mov    $0x0,%eax
  800a96:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a99:	0f b6 11             	movzbl (%ecx),%edx
  800a9c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9f:	89 f3                	mov    %esi,%ebx
  800aa1:	80 fb 09             	cmp    $0x9,%bl
  800aa4:	77 08                	ja     800aae <strtol+0x8b>
			dig = *s - '0';
  800aa6:	0f be d2             	movsbl %dl,%edx
  800aa9:	83 ea 30             	sub    $0x30,%edx
  800aac:	eb 22                	jmp    800ad0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aae:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab1:	89 f3                	mov    %esi,%ebx
  800ab3:	80 fb 19             	cmp    $0x19,%bl
  800ab6:	77 08                	ja     800ac0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ab8:	0f be d2             	movsbl %dl,%edx
  800abb:	83 ea 57             	sub    $0x57,%edx
  800abe:	eb 10                	jmp    800ad0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ac0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac3:	89 f3                	mov    %esi,%ebx
  800ac5:	80 fb 19             	cmp    $0x19,%bl
  800ac8:	77 16                	ja     800ae0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aca:	0f be d2             	movsbl %dl,%edx
  800acd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ad0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad3:	7d 0b                	jge    800ae0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad5:	83 c1 01             	add    $0x1,%ecx
  800ad8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800adc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ade:	eb b9                	jmp    800a99 <strtol+0x76>

	if (endptr)
  800ae0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae4:	74 0d                	je     800af3 <strtol+0xd0>
		*endptr = (char *) s;
  800ae6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae9:	89 0e                	mov    %ecx,(%esi)
  800aeb:	eb 06                	jmp    800af3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aed:	85 db                	test   %ebx,%ebx
  800aef:	74 98                	je     800a89 <strtol+0x66>
  800af1:	eb 9e                	jmp    800a91 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800af3:	89 c2                	mov    %eax,%edx
  800af5:	f7 da                	neg    %edx
  800af7:	85 ff                	test   %edi,%edi
  800af9:	0f 45 c2             	cmovne %edx,%eax
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800b07:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b12:	89 c3                	mov    %eax,%ebx
  800b14:	89 c7                	mov    %eax,%edi
  800b16:	89 c6                	mov    %eax,%esi
  800b18:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5f                   	pop    %edi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b25:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2f:	89 d1                	mov    %edx,%ecx
  800b31:	89 d3                	mov    %edx,%ebx
  800b33:	89 d7                	mov    %edx,%edi
  800b35:	89 d6                	mov    %edx,%esi
  800b37:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
  800b44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b47:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4c:	b8 03 00 00 00       	mov    $0x3,%eax
  800b51:	8b 55 08             	mov    0x8(%ebp),%edx
  800b54:	89 cb                	mov    %ecx,%ebx
  800b56:	89 cf                	mov    %ecx,%edi
  800b58:	89 ce                	mov    %ecx,%esi
  800b5a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b5c:	85 c0                	test   %eax,%eax
  800b5e:	7e 17                	jle    800b77 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b60:	83 ec 0c             	sub    $0xc,%esp
  800b63:	50                   	push   %eax
  800b64:	6a 03                	push   $0x3
  800b66:	68 08 18 80 00       	push   $0x801808
  800b6b:	6a 23                	push   $0x23
  800b6d:	68 25 18 80 00       	push   $0x801825
  800b72:	e8 ce f5 ff ff       	call   800145 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b85:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8f:	89 d1                	mov    %edx,%ecx
  800b91:	89 d3                	mov    %edx,%ebx
  800b93:	89 d7                	mov    %edx,%edi
  800b95:	89 d6                	mov    %edx,%esi
  800b97:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5f                   	pop    %edi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <sys_yield>:

void
sys_yield(void)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bae:	89 d1                	mov    %edx,%ecx
  800bb0:	89 d3                	mov    %edx,%ebx
  800bb2:	89 d7                	mov    %edx,%edi
  800bb4:	89 d6                	mov    %edx,%esi
  800bb6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
  800bc3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc6:	be 00 00 00 00       	mov    $0x0,%esi
  800bcb:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd9:	89 f7                	mov    %esi,%edi
  800bdb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bdd:	85 c0                	test   %eax,%eax
  800bdf:	7e 17                	jle    800bf8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be1:	83 ec 0c             	sub    $0xc,%esp
  800be4:	50                   	push   %eax
  800be5:	6a 04                	push   $0x4
  800be7:	68 08 18 80 00       	push   $0x801808
  800bec:	6a 23                	push   $0x23
  800bee:	68 25 18 80 00       	push   $0x801825
  800bf3:	e8 4d f5 ff ff       	call   800145 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	57                   	push   %edi
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
  800c06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c09:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c11:	8b 55 08             	mov    0x8(%ebp),%edx
  800c14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c17:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c1a:	8b 75 18             	mov    0x18(%ebp),%esi
  800c1d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1f:	85 c0                	test   %eax,%eax
  800c21:	7e 17                	jle    800c3a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c23:	83 ec 0c             	sub    $0xc,%esp
  800c26:	50                   	push   %eax
  800c27:	6a 05                	push   $0x5
  800c29:	68 08 18 80 00       	push   $0x801808
  800c2e:	6a 23                	push   $0x23
  800c30:	68 25 18 80 00       	push   $0x801825
  800c35:	e8 0b f5 ff ff       	call   800145 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c50:	b8 06 00 00 00       	mov    $0x6,%eax
  800c55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c58:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5b:	89 df                	mov    %ebx,%edi
  800c5d:	89 de                	mov    %ebx,%esi
  800c5f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c61:	85 c0                	test   %eax,%eax
  800c63:	7e 17                	jle    800c7c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c65:	83 ec 0c             	sub    $0xc,%esp
  800c68:	50                   	push   %eax
  800c69:	6a 06                	push   $0x6
  800c6b:	68 08 18 80 00       	push   $0x801808
  800c70:	6a 23                	push   $0x23
  800c72:	68 25 18 80 00       	push   $0x801825
  800c77:	e8 c9 f4 ff ff       	call   800145 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
  800c8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c92:	b8 08 00 00 00       	mov    $0x8,%eax
  800c97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	89 df                	mov    %ebx,%edi
  800c9f:	89 de                	mov    %ebx,%esi
  800ca1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	7e 17                	jle    800cbe <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca7:	83 ec 0c             	sub    $0xc,%esp
  800caa:	50                   	push   %eax
  800cab:	6a 08                	push   $0x8
  800cad:	68 08 18 80 00       	push   $0x801808
  800cb2:	6a 23                	push   $0x23
  800cb4:	68 25 18 80 00       	push   $0x801825
  800cb9:	e8 87 f4 ff ff       	call   800145 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
  800ccc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd4:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdf:	89 df                	mov    %ebx,%edi
  800ce1:	89 de                	mov    %ebx,%esi
  800ce3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce5:	85 c0                	test   %eax,%eax
  800ce7:	7e 17                	jle    800d00 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce9:	83 ec 0c             	sub    $0xc,%esp
  800cec:	50                   	push   %eax
  800ced:	6a 09                	push   $0x9
  800cef:	68 08 18 80 00       	push   $0x801808
  800cf4:	6a 23                	push   $0x23
  800cf6:	68 25 18 80 00       	push   $0x801825
  800cfb:	e8 45 f4 ff ff       	call   800145 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0e:	be 00 00 00 00       	mov    $0x0,%esi
  800d13:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d21:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d24:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d26:	5b                   	pop    %ebx
  800d27:	5e                   	pop    %esi
  800d28:	5f                   	pop    %edi
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	57                   	push   %edi
  800d2f:	56                   	push   %esi
  800d30:	53                   	push   %ebx
  800d31:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d34:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d39:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d41:	89 cb                	mov    %ecx,%ebx
  800d43:	89 cf                	mov    %ecx,%edi
  800d45:	89 ce                	mov    %ecx,%esi
  800d47:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	7e 17                	jle    800d64 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4d:	83 ec 0c             	sub    $0xc,%esp
  800d50:	50                   	push   %eax
  800d51:	6a 0c                	push   $0xc
  800d53:	68 08 18 80 00       	push   $0x801808
  800d58:	6a 23                	push   $0x23
  800d5a:	68 25 18 80 00       	push   $0x801825
  800d5f:	e8 e1 f3 ff ff       	call   800145 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d67:	5b                   	pop    %ebx
  800d68:	5e                   	pop    %esi
  800d69:	5f                   	pop    %edi
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
  800d72:	83 ec 0c             	sub    $0xc,%esp
  800d75:	89 c7                	mov    %eax,%edi
  800d77:	89 d3                	mov    %edx,%ebx
	int r;

	// LAB 4: Your code here.

    envid_t myenvid = sys_getenvid();
  800d79:	e8 01 fe ff ff       	call   800b7f <sys_getenvid>
  800d7e:	89 c6                	mov    %eax,%esi
    pte_t pte = uvpt[pn];
  800d80:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    int perm;

    perm = PTE_U | PTE_P;
    if(pte & PTE_W || pte & PTE_COW)
  800d87:	a9 02 08 00 00       	test   $0x802,%eax
  800d8c:	75 40                	jne    800dce <duppage+0x62>
    {
        perm |= PTE_COW;
    }

    // map to envid VA
    if ((r = sys_page_map(myenvid,
  800d8e:	c1 e3 0c             	shl    $0xc,%ebx
  800d91:	83 ec 0c             	sub    $0xc,%esp
  800d94:	6a 05                	push   $0x5
  800d96:	53                   	push   %ebx
  800d97:	57                   	push   %edi
  800d98:	53                   	push   %ebx
  800d99:	56                   	push   %esi
  800d9a:	e8 61 fe ff ff       	call   800c00 <sys_page_map>
  800d9f:	83 c4 20             	add    $0x20,%esp
  800da2:	85 c0                	test   %eax,%eax
  800da4:	ba 00 00 00 00       	mov    $0x0,%edx
  800da9:	0f 4f c2             	cmovg  %edx,%eax
  800dac:	eb 3b                	jmp    800de9 <duppage+0x7d>
    }

    // if COW remap to self
    if(perm & PTE_COW)
    {
        if((r = sys_page_map(myenvid, 
  800dae:	83 ec 0c             	sub    $0xc,%esp
  800db1:	68 05 08 00 00       	push   $0x805
  800db6:	53                   	push   %ebx
  800db7:	56                   	push   %esi
  800db8:	53                   	push   %ebx
  800db9:	56                   	push   %esi
  800dba:	e8 41 fe ff ff       	call   800c00 <sys_page_map>
  800dbf:	83 c4 20             	add    $0x20,%esp
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc9:	0f 4f c2             	cmovg  %edx,%eax
  800dcc:	eb 1b                	jmp    800de9 <duppage+0x7d>
    {
        perm |= PTE_COW;
    }

    // map to envid VA
    if ((r = sys_page_map(myenvid,
  800dce:	c1 e3 0c             	shl    $0xc,%ebx
  800dd1:	83 ec 0c             	sub    $0xc,%esp
  800dd4:	68 05 08 00 00       	push   $0x805
  800dd9:	53                   	push   %ebx
  800dda:	57                   	push   %edi
  800ddb:	53                   	push   %ebx
  800ddc:	56                   	push   %esi
  800ddd:	e8 1e fe ff ff       	call   800c00 <sys_page_map>
  800de2:	83 c4 20             	add    $0x20,%esp
  800de5:	85 c0                	test   %eax,%eax
  800de7:	79 c5                	jns    800dae <duppage+0x42>
            return r;
        }
    }

	return 0;
}
  800de9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dec:	5b                   	pop    %ebx
  800ded:	5e                   	pop    %esi
  800dee:	5f                   	pop    %edi
  800def:	5d                   	pop    %ebp
  800df0:	c3                   	ret    

00800df1 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	56                   	push   %esi
  800df5:	53                   	push   %ebx
  800df6:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800df9:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

    if ((err & FEC_WR) == 0)
  800dfb:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dff:	75 12                	jne    800e13 <pgfault+0x22>
    {
        panic("pgfault: page fault was not caused by write; %x.\n", utf->utf_fault_va);
  800e01:	53                   	push   %ebx
  800e02:	68 34 18 80 00       	push   $0x801834
  800e07:	6a 1f                	push   $0x1f
  800e09:	68 0b 19 80 00       	push   $0x80190b
  800e0e:	e8 32 f3 ff ff       	call   800145 <_panic>
    }

    if ((uvpt[PGNUM(addr)] & PTE_COW) == 0) 
  800e13:	89 d8                	mov    %ebx,%eax
  800e15:	c1 e8 0c             	shr    $0xc,%eax
  800e18:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e1f:	f6 c4 08             	test   $0x8,%ah
  800e22:	75 12                	jne    800e36 <pgfault+0x45>
    {
        panic("pgfault: page fault on page which is not COW %x.\n", utf->utf_fault_va);
  800e24:	53                   	push   %ebx
  800e25:	68 68 18 80 00       	push   $0x801868
  800e2a:	6a 24                	push   $0x24
  800e2c:	68 0b 19 80 00       	push   $0x80190b
  800e31:	e8 0f f3 ff ff       	call   800145 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    envid_t envid = sys_getenvid();
  800e36:	e8 44 fd ff ff       	call   800b7f <sys_getenvid>
  800e3b:	89 c6                	mov    %eax,%esi

    //allocate temp page
    if (sys_page_alloc(envid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  800e3d:	83 ec 04             	sub    $0x4,%esp
  800e40:	6a 07                	push   $0x7
  800e42:	68 00 f0 7f 00       	push   $0x7ff000
  800e47:	50                   	push   %eax
  800e48:	e8 70 fd ff ff       	call   800bbd <sys_page_alloc>
  800e4d:	83 c4 10             	add    $0x10,%esp
  800e50:	85 c0                	test   %eax,%eax
  800e52:	79 14                	jns    800e68 <pgfault+0x77>
    {
        panic("pgfault: can't allocate temp page.\n");
  800e54:	83 ec 04             	sub    $0x4,%esp
  800e57:	68 9c 18 80 00       	push   $0x80189c
  800e5c:	6a 32                	push   $0x32
  800e5e:	68 0b 19 80 00       	push   $0x80190b
  800e63:	e8 dd f2 ff ff       	call   800145 <_panic>
    }

    memmove(PFTEMP, (void *)ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800e68:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800e6e:	83 ec 04             	sub    $0x4,%esp
  800e71:	68 00 10 00 00       	push   $0x1000
  800e76:	53                   	push   %ebx
  800e77:	68 00 f0 7f 00       	push   $0x7ff000
  800e7c:	e8 cb fa ff ff       	call   80094c <memmove>

    if(sys_page_map(envid, PFTEMP, envid, (void *)ROUNDDOWN(addr, PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
  800e81:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e88:	53                   	push   %ebx
  800e89:	56                   	push   %esi
  800e8a:	68 00 f0 7f 00       	push   $0x7ff000
  800e8f:	56                   	push   %esi
  800e90:	e8 6b fd ff ff       	call   800c00 <sys_page_map>
  800e95:	83 c4 20             	add    $0x20,%esp
  800e98:	85 c0                	test   %eax,%eax
  800e9a:	79 14                	jns    800eb0 <pgfault+0xbf>
    {
        panic("pgfault: can't map temp page to old page.\n");
  800e9c:	83 ec 04             	sub    $0x4,%esp
  800e9f:	68 c0 18 80 00       	push   $0x8018c0
  800ea4:	6a 39                	push   $0x39
  800ea6:	68 0b 19 80 00       	push   $0x80190b
  800eab:	e8 95 f2 ff ff       	call   800145 <_panic>
    }

    if(sys_page_unmap(envid, PFTEMP) < 0)
  800eb0:	83 ec 08             	sub    $0x8,%esp
  800eb3:	68 00 f0 7f 00       	push   $0x7ff000
  800eb8:	56                   	push   %esi
  800eb9:	e8 84 fd ff ff       	call   800c42 <sys_page_unmap>
  800ebe:	83 c4 10             	add    $0x10,%esp
  800ec1:	85 c0                	test   %eax,%eax
  800ec3:	79 14                	jns    800ed9 <pgfault+0xe8>
    {
        panic("pgfault: couldn't unmap page.\n");
  800ec5:	83 ec 04             	sub    $0x4,%esp
  800ec8:	68 ec 18 80 00       	push   $0x8018ec
  800ecd:	6a 3e                	push   $0x3e
  800ecf:	68 0b 19 80 00       	push   $0x80190b
  800ed4:	e8 6c f2 ff ff       	call   800145 <_panic>
    }
	//panic("pgfault not implemented");
}
  800ed9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800edc:	5b                   	pop    %ebx
  800edd:	5e                   	pop    %esi
  800ede:	5d                   	pop    %ebp
  800edf:	c3                   	ret    

00800ee0 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
  800ee3:	57                   	push   %edi
  800ee4:	56                   	push   %esi
  800ee5:	53                   	push   %ebx
  800ee6:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    extern void _pgfault_upcall(void);
    envid_t myenvid = sys_getenvid();
  800ee9:	e8 91 fc ff ff       	call   800b7f <sys_getenvid>
  800eee:	89 45 e0             	mov    %eax,-0x20(%ebp)
    envid_t envid;
    uint32_t i, j, pn;

    //set page fault handler
    set_pgfault_handler(pgfault);
  800ef1:	83 ec 0c             	sub    $0xc,%esp
  800ef4:	68 f1 0d 80 00       	push   $0x800df1
  800ef9:	e8 14 03 00 00       	call   801212 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800efe:	b8 07 00 00 00       	mov    $0x7,%eax
  800f03:	cd 30                	int    $0x30
  800f05:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f08:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    //create a child
    if((envid = sys_exofork()) < 0)
  800f0b:	83 c4 10             	add    $0x10,%esp
  800f0e:	85 c0                	test   %eax,%eax
  800f10:	0f 88 13 01 00 00    	js     801029 <fork+0x149>
  800f16:	bf 02 00 00 00       	mov    $0x2,%edi
    {
        return -1;
    }

    if(envid == 0)
  800f1b:	85 c0                	test   %eax,%eax
  800f1d:	75 21                	jne    800f40 <fork+0x60>
    {
        thisenv = &envs[ENVX(sys_getenvid())];
  800f1f:	e8 5b fc ff ff       	call   800b7f <sys_getenvid>
  800f24:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f29:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f2c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f31:	a3 08 20 80 00       	mov    %eax,0x802008

        return envid;
  800f36:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3b:	e9 0a 01 00 00       	jmp    80104a <fork+0x16a>
    }

    //copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
  800f40:	8b 04 bd 00 d0 7b ef 	mov    -0x10843000(,%edi,4),%eax
  800f47:	a8 01                	test   $0x1,%al
  800f49:	74 3a                	je     800f85 <fork+0xa5>
        {
            for (j = 0; j < NPTENTRIES; j++)
            {
                pn = PGNUM(PGADDR(i, j, 0));
  800f4b:	89 fe                	mov    %edi,%esi
  800f4d:	c1 e6 16             	shl    $0x16,%esi
  800f50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f55:	89 da                	mov    %ebx,%edx
  800f57:	c1 e2 0c             	shl    $0xc,%edx
  800f5a:	09 f2                	or     %esi,%edx
  800f5c:	c1 ea 0c             	shr    $0xc,%edx
                if(pn == PGNUM(UXSTACKTOP - PGSIZE))
  800f5f:	81 fa ff eb 0e 00    	cmp    $0xeebff,%edx
  800f65:	74 1e                	je     800f85 <fork+0xa5>
                {
                    break;
                }

                if(uvpt[pn] & PTE_P)
  800f67:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800f6e:	a8 01                	test   $0x1,%al
  800f70:	74 08                	je     800f7a <fork+0x9a>
                {
                    duppage(envid, pn);
  800f72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f75:	e8 f2 fd ff ff       	call   800d6c <duppage>
    //copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
        {
            for (j = 0; j < NPTENTRIES; j++)
  800f7a:	83 c3 01             	add    $0x1,%ebx
  800f7d:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  800f83:	75 d0                	jne    800f55 <fork+0x75>

        return envid;
    }

    //copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
  800f85:	83 c7 01             	add    $0x1,%edi
  800f88:	81 ff bb 03 00 00    	cmp    $0x3bb,%edi
  800f8e:	75 b0                	jne    800f40 <fork+0x60>
                }
            }
        }
    }

    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
  800f90:	83 ec 04             	sub    $0x4,%esp
  800f93:	6a 07                	push   $0x7
  800f95:	68 00 f0 bf ee       	push   $0xeebff000
  800f9a:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800f9d:	57                   	push   %edi
  800f9e:	e8 1a fc ff ff       	call   800bbd <sys_page_alloc>
  800fa3:	83 c4 10             	add    $0x10,%esp
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	0f 88 82 00 00 00    	js     801030 <fork+0x150>
    {
        return -1;
    }

    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  800fae:	83 ec 0c             	sub    $0xc,%esp
  800fb1:	6a 07                	push   $0x7
  800fb3:	68 00 f0 7f 00       	push   $0x7ff000
  800fb8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800fbb:	56                   	push   %esi
  800fbc:	68 00 f0 bf ee       	push   $0xeebff000
  800fc1:	57                   	push   %edi
  800fc2:	e8 39 fc ff ff       	call   800c00 <sys_page_map>
  800fc7:	83 c4 20             	add    $0x20,%esp
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	78 69                	js     801037 <fork+0x157>
    {
        return -1;
    }

    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);
  800fce:	83 ec 04             	sub    $0x4,%esp
  800fd1:	68 00 10 00 00       	push   $0x1000
  800fd6:	68 00 f0 7f 00       	push   $0x7ff000
  800fdb:	68 00 f0 bf ee       	push   $0xeebff000
  800fe0:	e8 67 f9 ff ff       	call   80094c <memmove>

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
  800fe5:	83 c4 08             	add    $0x8,%esp
  800fe8:	68 00 f0 7f 00       	push   $0x7ff000
  800fed:	56                   	push   %esi
  800fee:	e8 4f fc ff ff       	call   800c42 <sys_page_unmap>
  800ff3:	83 c4 10             	add    $0x10,%esp
  800ff6:	85 c0                	test   %eax,%eax
  800ff8:	78 44                	js     80103e <fork+0x15e>
    {
        return -1;
    }

    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
  800ffa:	83 ec 08             	sub    $0x8,%esp
  800ffd:	68 77 12 80 00       	push   $0x801277
  801002:	57                   	push   %edi
  801003:	e8 be fc ff ff       	call   800cc6 <sys_env_set_pgfault_upcall>
  801008:	83 c4 10             	add    $0x10,%esp
  80100b:	85 c0                	test   %eax,%eax
  80100d:	78 36                	js     801045 <fork+0x165>
    {
        return -1;
    }

    if(sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  80100f:	83 ec 08             	sub    $0x8,%esp
  801012:	6a 02                	push   $0x2
  801014:	57                   	push   %edi
  801015:	e8 6a fc ff ff       	call   800c84 <sys_env_set_status>
  80101a:	83 c4 10             	add    $0x10,%esp
    {
        return -1;
    }

    return envid;
  80101d:	85 c0                	test   %eax,%eax
  80101f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801024:	0f 49 c7             	cmovns %edi,%eax
  801027:	eb 21                	jmp    80104a <fork+0x16a>
    set_pgfault_handler(pgfault);

    //create a child
    if((envid = sys_exofork()) < 0)
    {
        return -1;
  801029:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80102e:	eb 1a                	jmp    80104a <fork+0x16a>
        }
    }

    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  801030:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801035:	eb 13                	jmp    80104a <fork+0x16a>
    }

    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  801037:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80103c:	eb 0c                	jmp    80104a <fork+0x16a>

    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
    {
        return -1;
  80103e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801043:	eb 05                	jmp    80104a <fork+0x16a>
    }

    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
    {
        return -1;
  801045:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
        return -1;
    }

    return envid;
    //	panic("fork not implemented");
}
  80104a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104d:	5b                   	pop    %ebx
  80104e:	5e                   	pop    %esi
  80104f:	5f                   	pop    %edi
  801050:	5d                   	pop    %ebp
  801051:	c3                   	ret    

00801052 <sfork>:

// Challenge!
int
sfork(void)
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	57                   	push   %edi
  801056:	56                   	push   %esi
  801057:	53                   	push   %ebx
  801058:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    extern void _pgfault_upcall(void);
    envid_t myenvid = sys_getenvid();
  80105b:	e8 1f fb ff ff       	call   800b7f <sys_getenvid>
  801060:	89 45 e0             	mov    %eax,-0x20(%ebp)
    envid_t envid;
    uint32_t i, j, pn;
    int perm;

    // set page fault handler
    set_pgfault_handler(pgfault);
  801063:	83 ec 0c             	sub    $0xc,%esp
  801066:	68 f1 0d 80 00       	push   $0x800df1
  80106b:	e8 a2 01 00 00       	call   801212 <set_pgfault_handler>
  801070:	b8 07 00 00 00       	mov    $0x7,%eax
  801075:	cd 30                	int    $0x30
  801077:	89 45 dc             	mov    %eax,-0x24(%ebp)

    // create a child
    if((envid = sys_exofork()) < 0)
  80107a:	83 c4 10             	add    $0x10,%esp
  80107d:	85 c0                	test   %eax,%eax
  80107f:	0f 88 5d 01 00 00    	js     8011e2 <sfork+0x190>
  801085:	89 c7                	mov    %eax,%edi
  801087:	c7 45 e4 02 00 00 00 	movl   $0x2,-0x1c(%ebp)
    {
        return -1;
    }

    if(envid == 0)
  80108e:	85 c0                	test   %eax,%eax
  801090:	75 21                	jne    8010b3 <sfork+0x61>
    {
        thisenv = &envs[ENVX(sys_getenvid())];
  801092:	e8 e8 fa ff ff       	call   800b7f <sys_getenvid>
  801097:	25 ff 03 00 00       	and    $0x3ff,%eax
  80109c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80109f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010a4:	a3 08 20 80 00       	mov    %eax,0x802008
        return envid;
  8010a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ae:	e9 57 01 00 00       	jmp    80120a <sfork+0x1b8>
    }

    // copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
  8010b3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8010b6:	8b 04 b5 00 d0 7b ef 	mov    -0x10843000(,%esi,4),%eax
  8010bd:	a8 01                	test   $0x1,%al
  8010bf:	74 76                	je     801137 <sfork+0xe5>
        {
            for (j = 0; j < NPTENTRIES; j++)
            {
                pn = PGNUM(PGADDR(i, j, 0));
  8010c1:	c1 e6 16             	shl    $0x16,%esi
  8010c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010c9:	89 d8                	mov    %ebx,%eax
  8010cb:	c1 e0 0c             	shl    $0xc,%eax
  8010ce:	09 f0                	or     %esi,%eax
  8010d0:	89 c2                	mov    %eax,%edx
  8010d2:	c1 ea 0c             	shr    $0xc,%edx
                if(pn == PGNUM(UXSTACKTOP - PGSIZE))
  8010d5:	81 fa ff eb 0e 00    	cmp    $0xeebff,%edx
  8010db:	74 5a                	je     801137 <sfork+0xe5>
                {
                    break;
                }

                if(pn == PGNUM(USTACKTOP - PGSIZE))
  8010dd:	81 fa fd eb 0e 00    	cmp    $0xeebfd,%edx
  8010e3:	75 09                	jne    8010ee <sfork+0x9c>
                {
                     duppage(envid, pn); // cow for stack page
  8010e5:	89 f8                	mov    %edi,%eax
  8010e7:	e8 80 fc ff ff       	call   800d6c <duppage>
                     continue;
  8010ec:	eb 3e                	jmp    80112c <sfork+0xda>
                }

                // map same page to child env with same perms
                if (uvpt[pn] & PTE_P)
  8010ee:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  8010f5:	f6 c1 01             	test   $0x1,%cl
  8010f8:	74 32                	je     80112c <sfork+0xda>
                {
                    
                    perm = uvpt[pn] & ~(uvpt[pn] & ~(PTE_P |PTE_U | PTE_W | PTE_AVAIL));
  8010fa:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801101:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
                    if (sys_page_map(myenvid, (void *)(PGADDR(i, j, 0)),
  801108:	83 ec 0c             	sub    $0xc,%esp
  80110b:	81 e2 f8 f1 ff ff    	and    $0xfffff1f8,%edx
  801111:	f7 d2                	not    %edx
  801113:	21 d1                	and    %edx,%ecx
  801115:	51                   	push   %ecx
  801116:	50                   	push   %eax
  801117:	57                   	push   %edi
  801118:	50                   	push   %eax
  801119:	ff 75 e0             	pushl  -0x20(%ebp)
  80111c:	e8 df fa ff ff       	call   800c00 <sys_page_map>
  801121:	83 c4 20             	add    $0x20,%esp
  801124:	85 c0                	test   %eax,%eax
  801126:	0f 88 bd 00 00 00    	js     8011e9 <sfork+0x197>
    // copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
        {
            for (j = 0; j < NPTENTRIES; j++)
  80112c:	83 c3 01             	add    $0x1,%ebx
  80112f:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801135:	75 92                	jne    8010c9 <sfork+0x77>
        thisenv = &envs[ENVX(sys_getenvid())];
        return envid;
    }

    // copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
  801137:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  80113b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80113e:	3d bb 03 00 00       	cmp    $0x3bb,%eax
  801143:	0f 85 6a ff ff ff    	jne    8010b3 <sfork+0x61>
            }
        }
    }

    // allocate new exception stack for child
    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
  801149:	83 ec 04             	sub    $0x4,%esp
  80114c:	6a 07                	push   $0x7
  80114e:	68 00 f0 bf ee       	push   $0xeebff000
  801153:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801156:	57                   	push   %edi
  801157:	e8 61 fa ff ff       	call   800bbd <sys_page_alloc>
  80115c:	83 c4 10             	add    $0x10,%esp
  80115f:	85 c0                	test   %eax,%eax
  801161:	0f 88 89 00 00 00    	js     8011f0 <sfork+0x19e>
    {
        return -1;
    }

    // map child uxstack to temp page
    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  801167:	83 ec 0c             	sub    $0xc,%esp
  80116a:	6a 07                	push   $0x7
  80116c:	68 00 f0 7f 00       	push   $0x7ff000
  801171:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801174:	56                   	push   %esi
  801175:	68 00 f0 bf ee       	push   $0xeebff000
  80117a:	57                   	push   %edi
  80117b:	e8 80 fa ff ff       	call   800c00 <sys_page_map>
  801180:	83 c4 20             	add    $0x20,%esp
  801183:	85 c0                	test   %eax,%eax
  801185:	78 70                	js     8011f7 <sfork+0x1a5>
    {
        return -1;
    }

    // copy own uxstack to temp page
    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);
  801187:	83 ec 04             	sub    $0x4,%esp
  80118a:	68 00 10 00 00       	push   $0x1000
  80118f:	68 00 f0 7f 00       	push   $0x7ff000
  801194:	68 00 f0 bf ee       	push   $0xeebff000
  801199:	e8 ae f7 ff ff       	call   80094c <memmove>

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
  80119e:	83 c4 08             	add    $0x8,%esp
  8011a1:	68 00 f0 7f 00       	push   $0x7ff000
  8011a6:	56                   	push   %esi
  8011a7:	e8 96 fa ff ff       	call   800c42 <sys_page_unmap>
  8011ac:	83 c4 10             	add    $0x10,%esp
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	78 4b                	js     8011fe <sfork+0x1ac>
    {
        return -1;
    }

    // set page fault handler in child
    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
  8011b3:	83 ec 08             	sub    $0x8,%esp
  8011b6:	68 77 12 80 00       	push   $0x801277
  8011bb:	57                   	push   %edi
  8011bc:	e8 05 fb ff ff       	call   800cc6 <sys_env_set_pgfault_upcall>
  8011c1:	83 c4 10             	add    $0x10,%esp
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	78 3d                	js     801205 <sfork+0x1b3>
    {
        return -1;
    }

    // mark child env as RUNNABLE
    if(sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  8011c8:	83 ec 08             	sub    $0x8,%esp
  8011cb:	6a 02                	push   $0x2
  8011cd:	57                   	push   %edi
  8011ce:	e8 b1 fa ff ff       	call   800c84 <sys_env_set_status>
  8011d3:	83 c4 10             	add    $0x10,%esp
    {
        return -1;
    }

    return envid;
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8011dd:	0f 49 c7             	cmovns %edi,%eax
  8011e0:	eb 28                	jmp    80120a <sfork+0x1b8>
    set_pgfault_handler(pgfault);

    // create a child
    if((envid = sys_exofork()) < 0)
    {
        return -1;
  8011e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8011e7:	eb 21                	jmp    80120a <sfork+0x1b8>
                    
                    perm = uvpt[pn] & ~(uvpt[pn] & ~(PTE_P |PTE_U | PTE_W | PTE_AVAIL));
                    if (sys_page_map(myenvid, (void *)(PGADDR(i, j, 0)),
                                     envid,   (void *)(PGADDR(i, j, 0)), perm) < 0)
                    {
                        return -1;
  8011e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8011ee:	eb 1a                	jmp    80120a <sfork+0x1b8>
    }

    // allocate new exception stack for child
    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  8011f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8011f5:	eb 13                	jmp    80120a <sfork+0x1b8>
    }

    // map child uxstack to temp page
    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  8011f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8011fc:	eb 0c                	jmp    80120a <sfork+0x1b8>
    // copy own uxstack to temp page
    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
    {
        return -1;
  8011fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801203:	eb 05                	jmp    80120a <sfork+0x1b8>
    }

    // set page fault handler in child
    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
    {
        return -1;
  801205:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    {
        return -1;
    }

    return envid;
}
  80120a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80120d:	5b                   	pop    %ebx
  80120e:	5e                   	pop    %esi
  80120f:	5f                   	pop    %edi
  801210:	5d                   	pop    %ebp
  801211:	c3                   	ret    

00801212 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801212:	55                   	push   %ebp
  801213:	89 e5                	mov    %esp,%ebp
  801215:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801218:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  80121f:	75 4c                	jne    80126d <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.

        void *va = (void *)(UXSTACKTOP - PGSIZE);
        if (sys_page_alloc(thisenv->env_id, va, PTE_P | PTE_U | PTE_W))
  801221:	a1 08 20 80 00       	mov    0x802008,%eax
  801226:	8b 40 48             	mov    0x48(%eax),%eax
  801229:	83 ec 04             	sub    $0x4,%esp
  80122c:	6a 07                	push   $0x7
  80122e:	68 00 f0 bf ee       	push   $0xeebff000
  801233:	50                   	push   %eax
  801234:	e8 84 f9 ff ff       	call   800bbd <sys_page_alloc>
  801239:	83 c4 10             	add    $0x10,%esp
  80123c:	85 c0                	test   %eax,%eax
  80123e:	74 14                	je     801254 <set_pgfault_handler+0x42>
        {
            panic("Unable to allocate memory for pgfault expected\n");
  801240:	83 ec 04             	sub    $0x4,%esp
  801243:	68 18 19 80 00       	push   $0x801918
  801248:	6a 24                	push   $0x24
  80124a:	68 48 19 80 00       	push   $0x801948
  80124f:	e8 f1 ee ff ff       	call   800145 <_panic>
        }

        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801254:	a1 08 20 80 00       	mov    0x802008,%eax
  801259:	8b 40 48             	mov    0x48(%eax),%eax
  80125c:	83 ec 08             	sub    $0x8,%esp
  80125f:	68 77 12 80 00       	push   $0x801277
  801264:	50                   	push   %eax
  801265:	e8 5c fa ff ff       	call   800cc6 <sys_env_set_pgfault_upcall>
  80126a:	83 c4 10             	add    $0x10,%esp

		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80126d:	8b 45 08             	mov    0x8(%ebp),%eax
  801270:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  801275:	c9                   	leave  
  801276:	c3                   	ret    

00801277 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801277:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801278:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  80127d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80127f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
    movl %esp, %ebx
  801282:	89 e3                	mov    %esp,%ebx
    // 40 is the size between utf_fault_va ~ utf_regs
    movl 40(%esp), %eax
  801284:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 48(%esp), %esp
  801288:	8b 64 24 30          	mov    0x30(%esp),%esp
    pushl %eax
  80128c:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    movl %ebx, %esp
  80128d:	89 dc                	mov    %ebx,%esp
    subl $4, 48(%esp)
  80128f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    popl %eax
  801294:	58                   	pop    %eax
    popl %eax
  801295:	58                   	pop    %eax
    popal
  801296:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  801297:	83 c4 04             	add    $0x4,%esp
    popfl
  80129a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp
  80129b:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  80129c:	c3                   	ret    
  80129d:	66 90                	xchg   %ax,%ax
  80129f:	90                   	nop

008012a0 <__udivdi3>:
  8012a0:	55                   	push   %ebp
  8012a1:	57                   	push   %edi
  8012a2:	56                   	push   %esi
  8012a3:	53                   	push   %ebx
  8012a4:	83 ec 1c             	sub    $0x1c,%esp
  8012a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8012ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8012af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8012b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8012b7:	85 f6                	test   %esi,%esi
  8012b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012bd:	89 ca                	mov    %ecx,%edx
  8012bf:	89 f8                	mov    %edi,%eax
  8012c1:	75 3d                	jne    801300 <__udivdi3+0x60>
  8012c3:	39 cf                	cmp    %ecx,%edi
  8012c5:	0f 87 c5 00 00 00    	ja     801390 <__udivdi3+0xf0>
  8012cb:	85 ff                	test   %edi,%edi
  8012cd:	89 fd                	mov    %edi,%ebp
  8012cf:	75 0b                	jne    8012dc <__udivdi3+0x3c>
  8012d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8012d6:	31 d2                	xor    %edx,%edx
  8012d8:	f7 f7                	div    %edi
  8012da:	89 c5                	mov    %eax,%ebp
  8012dc:	89 c8                	mov    %ecx,%eax
  8012de:	31 d2                	xor    %edx,%edx
  8012e0:	f7 f5                	div    %ebp
  8012e2:	89 c1                	mov    %eax,%ecx
  8012e4:	89 d8                	mov    %ebx,%eax
  8012e6:	89 cf                	mov    %ecx,%edi
  8012e8:	f7 f5                	div    %ebp
  8012ea:	89 c3                	mov    %eax,%ebx
  8012ec:	89 d8                	mov    %ebx,%eax
  8012ee:	89 fa                	mov    %edi,%edx
  8012f0:	83 c4 1c             	add    $0x1c,%esp
  8012f3:	5b                   	pop    %ebx
  8012f4:	5e                   	pop    %esi
  8012f5:	5f                   	pop    %edi
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    
  8012f8:	90                   	nop
  8012f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801300:	39 ce                	cmp    %ecx,%esi
  801302:	77 74                	ja     801378 <__udivdi3+0xd8>
  801304:	0f bd fe             	bsr    %esi,%edi
  801307:	83 f7 1f             	xor    $0x1f,%edi
  80130a:	0f 84 98 00 00 00    	je     8013a8 <__udivdi3+0x108>
  801310:	bb 20 00 00 00       	mov    $0x20,%ebx
  801315:	89 f9                	mov    %edi,%ecx
  801317:	89 c5                	mov    %eax,%ebp
  801319:	29 fb                	sub    %edi,%ebx
  80131b:	d3 e6                	shl    %cl,%esi
  80131d:	89 d9                	mov    %ebx,%ecx
  80131f:	d3 ed                	shr    %cl,%ebp
  801321:	89 f9                	mov    %edi,%ecx
  801323:	d3 e0                	shl    %cl,%eax
  801325:	09 ee                	or     %ebp,%esi
  801327:	89 d9                	mov    %ebx,%ecx
  801329:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80132d:	89 d5                	mov    %edx,%ebp
  80132f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801333:	d3 ed                	shr    %cl,%ebp
  801335:	89 f9                	mov    %edi,%ecx
  801337:	d3 e2                	shl    %cl,%edx
  801339:	89 d9                	mov    %ebx,%ecx
  80133b:	d3 e8                	shr    %cl,%eax
  80133d:	09 c2                	or     %eax,%edx
  80133f:	89 d0                	mov    %edx,%eax
  801341:	89 ea                	mov    %ebp,%edx
  801343:	f7 f6                	div    %esi
  801345:	89 d5                	mov    %edx,%ebp
  801347:	89 c3                	mov    %eax,%ebx
  801349:	f7 64 24 0c          	mull   0xc(%esp)
  80134d:	39 d5                	cmp    %edx,%ebp
  80134f:	72 10                	jb     801361 <__udivdi3+0xc1>
  801351:	8b 74 24 08          	mov    0x8(%esp),%esi
  801355:	89 f9                	mov    %edi,%ecx
  801357:	d3 e6                	shl    %cl,%esi
  801359:	39 c6                	cmp    %eax,%esi
  80135b:	73 07                	jae    801364 <__udivdi3+0xc4>
  80135d:	39 d5                	cmp    %edx,%ebp
  80135f:	75 03                	jne    801364 <__udivdi3+0xc4>
  801361:	83 eb 01             	sub    $0x1,%ebx
  801364:	31 ff                	xor    %edi,%edi
  801366:	89 d8                	mov    %ebx,%eax
  801368:	89 fa                	mov    %edi,%edx
  80136a:	83 c4 1c             	add    $0x1c,%esp
  80136d:	5b                   	pop    %ebx
  80136e:	5e                   	pop    %esi
  80136f:	5f                   	pop    %edi
  801370:	5d                   	pop    %ebp
  801371:	c3                   	ret    
  801372:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801378:	31 ff                	xor    %edi,%edi
  80137a:	31 db                	xor    %ebx,%ebx
  80137c:	89 d8                	mov    %ebx,%eax
  80137e:	89 fa                	mov    %edi,%edx
  801380:	83 c4 1c             	add    $0x1c,%esp
  801383:	5b                   	pop    %ebx
  801384:	5e                   	pop    %esi
  801385:	5f                   	pop    %edi
  801386:	5d                   	pop    %ebp
  801387:	c3                   	ret    
  801388:	90                   	nop
  801389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801390:	89 d8                	mov    %ebx,%eax
  801392:	f7 f7                	div    %edi
  801394:	31 ff                	xor    %edi,%edi
  801396:	89 c3                	mov    %eax,%ebx
  801398:	89 d8                	mov    %ebx,%eax
  80139a:	89 fa                	mov    %edi,%edx
  80139c:	83 c4 1c             	add    $0x1c,%esp
  80139f:	5b                   	pop    %ebx
  8013a0:	5e                   	pop    %esi
  8013a1:	5f                   	pop    %edi
  8013a2:	5d                   	pop    %ebp
  8013a3:	c3                   	ret    
  8013a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013a8:	39 ce                	cmp    %ecx,%esi
  8013aa:	72 0c                	jb     8013b8 <__udivdi3+0x118>
  8013ac:	31 db                	xor    %ebx,%ebx
  8013ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8013b2:	0f 87 34 ff ff ff    	ja     8012ec <__udivdi3+0x4c>
  8013b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8013bd:	e9 2a ff ff ff       	jmp    8012ec <__udivdi3+0x4c>
  8013c2:	66 90                	xchg   %ax,%ax
  8013c4:	66 90                	xchg   %ax,%ax
  8013c6:	66 90                	xchg   %ax,%ax
  8013c8:	66 90                	xchg   %ax,%ax
  8013ca:	66 90                	xchg   %ax,%ax
  8013cc:	66 90                	xchg   %ax,%ax
  8013ce:	66 90                	xchg   %ax,%ax

008013d0 <__umoddi3>:
  8013d0:	55                   	push   %ebp
  8013d1:	57                   	push   %edi
  8013d2:	56                   	push   %esi
  8013d3:	53                   	push   %ebx
  8013d4:	83 ec 1c             	sub    $0x1c,%esp
  8013d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8013db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8013df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8013e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8013e7:	85 d2                	test   %edx,%edx
  8013e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8013ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013f1:	89 f3                	mov    %esi,%ebx
  8013f3:	89 3c 24             	mov    %edi,(%esp)
  8013f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013fa:	75 1c                	jne    801418 <__umoddi3+0x48>
  8013fc:	39 f7                	cmp    %esi,%edi
  8013fe:	76 50                	jbe    801450 <__umoddi3+0x80>
  801400:	89 c8                	mov    %ecx,%eax
  801402:	89 f2                	mov    %esi,%edx
  801404:	f7 f7                	div    %edi
  801406:	89 d0                	mov    %edx,%eax
  801408:	31 d2                	xor    %edx,%edx
  80140a:	83 c4 1c             	add    $0x1c,%esp
  80140d:	5b                   	pop    %ebx
  80140e:	5e                   	pop    %esi
  80140f:	5f                   	pop    %edi
  801410:	5d                   	pop    %ebp
  801411:	c3                   	ret    
  801412:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801418:	39 f2                	cmp    %esi,%edx
  80141a:	89 d0                	mov    %edx,%eax
  80141c:	77 52                	ja     801470 <__umoddi3+0xa0>
  80141e:	0f bd ea             	bsr    %edx,%ebp
  801421:	83 f5 1f             	xor    $0x1f,%ebp
  801424:	75 5a                	jne    801480 <__umoddi3+0xb0>
  801426:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80142a:	0f 82 e0 00 00 00    	jb     801510 <__umoddi3+0x140>
  801430:	39 0c 24             	cmp    %ecx,(%esp)
  801433:	0f 86 d7 00 00 00    	jbe    801510 <__umoddi3+0x140>
  801439:	8b 44 24 08          	mov    0x8(%esp),%eax
  80143d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801441:	83 c4 1c             	add    $0x1c,%esp
  801444:	5b                   	pop    %ebx
  801445:	5e                   	pop    %esi
  801446:	5f                   	pop    %edi
  801447:	5d                   	pop    %ebp
  801448:	c3                   	ret    
  801449:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801450:	85 ff                	test   %edi,%edi
  801452:	89 fd                	mov    %edi,%ebp
  801454:	75 0b                	jne    801461 <__umoddi3+0x91>
  801456:	b8 01 00 00 00       	mov    $0x1,%eax
  80145b:	31 d2                	xor    %edx,%edx
  80145d:	f7 f7                	div    %edi
  80145f:	89 c5                	mov    %eax,%ebp
  801461:	89 f0                	mov    %esi,%eax
  801463:	31 d2                	xor    %edx,%edx
  801465:	f7 f5                	div    %ebp
  801467:	89 c8                	mov    %ecx,%eax
  801469:	f7 f5                	div    %ebp
  80146b:	89 d0                	mov    %edx,%eax
  80146d:	eb 99                	jmp    801408 <__umoddi3+0x38>
  80146f:	90                   	nop
  801470:	89 c8                	mov    %ecx,%eax
  801472:	89 f2                	mov    %esi,%edx
  801474:	83 c4 1c             	add    $0x1c,%esp
  801477:	5b                   	pop    %ebx
  801478:	5e                   	pop    %esi
  801479:	5f                   	pop    %edi
  80147a:	5d                   	pop    %ebp
  80147b:	c3                   	ret    
  80147c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801480:	8b 34 24             	mov    (%esp),%esi
  801483:	bf 20 00 00 00       	mov    $0x20,%edi
  801488:	89 e9                	mov    %ebp,%ecx
  80148a:	29 ef                	sub    %ebp,%edi
  80148c:	d3 e0                	shl    %cl,%eax
  80148e:	89 f9                	mov    %edi,%ecx
  801490:	89 f2                	mov    %esi,%edx
  801492:	d3 ea                	shr    %cl,%edx
  801494:	89 e9                	mov    %ebp,%ecx
  801496:	09 c2                	or     %eax,%edx
  801498:	89 d8                	mov    %ebx,%eax
  80149a:	89 14 24             	mov    %edx,(%esp)
  80149d:	89 f2                	mov    %esi,%edx
  80149f:	d3 e2                	shl    %cl,%edx
  8014a1:	89 f9                	mov    %edi,%ecx
  8014a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8014ab:	d3 e8                	shr    %cl,%eax
  8014ad:	89 e9                	mov    %ebp,%ecx
  8014af:	89 c6                	mov    %eax,%esi
  8014b1:	d3 e3                	shl    %cl,%ebx
  8014b3:	89 f9                	mov    %edi,%ecx
  8014b5:	89 d0                	mov    %edx,%eax
  8014b7:	d3 e8                	shr    %cl,%eax
  8014b9:	89 e9                	mov    %ebp,%ecx
  8014bb:	09 d8                	or     %ebx,%eax
  8014bd:	89 d3                	mov    %edx,%ebx
  8014bf:	89 f2                	mov    %esi,%edx
  8014c1:	f7 34 24             	divl   (%esp)
  8014c4:	89 d6                	mov    %edx,%esi
  8014c6:	d3 e3                	shl    %cl,%ebx
  8014c8:	f7 64 24 04          	mull   0x4(%esp)
  8014cc:	39 d6                	cmp    %edx,%esi
  8014ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014d2:	89 d1                	mov    %edx,%ecx
  8014d4:	89 c3                	mov    %eax,%ebx
  8014d6:	72 08                	jb     8014e0 <__umoddi3+0x110>
  8014d8:	75 11                	jne    8014eb <__umoddi3+0x11b>
  8014da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8014de:	73 0b                	jae    8014eb <__umoddi3+0x11b>
  8014e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8014e4:	1b 14 24             	sbb    (%esp),%edx
  8014e7:	89 d1                	mov    %edx,%ecx
  8014e9:	89 c3                	mov    %eax,%ebx
  8014eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8014ef:	29 da                	sub    %ebx,%edx
  8014f1:	19 ce                	sbb    %ecx,%esi
  8014f3:	89 f9                	mov    %edi,%ecx
  8014f5:	89 f0                	mov    %esi,%eax
  8014f7:	d3 e0                	shl    %cl,%eax
  8014f9:	89 e9                	mov    %ebp,%ecx
  8014fb:	d3 ea                	shr    %cl,%edx
  8014fd:	89 e9                	mov    %ebp,%ecx
  8014ff:	d3 ee                	shr    %cl,%esi
  801501:	09 d0                	or     %edx,%eax
  801503:	89 f2                	mov    %esi,%edx
  801505:	83 c4 1c             	add    $0x1c,%esp
  801508:	5b                   	pop    %ebx
  801509:	5e                   	pop    %esi
  80150a:	5f                   	pop    %edi
  80150b:	5d                   	pop    %ebp
  80150c:	c3                   	ret    
  80150d:	8d 76 00             	lea    0x0(%esi),%esi
  801510:	29 f9                	sub    %edi,%ecx
  801512:	19 d6                	sbb    %edx,%esi
  801514:	89 74 24 04          	mov    %esi,0x4(%esp)
  801518:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80151c:	e9 18 ff ff ff       	jmp    801439 <__umoddi3+0x69>
