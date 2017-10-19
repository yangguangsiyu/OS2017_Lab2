
obj/user/sendpage：     文件格式 elf32-i386


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
  80002c:	e8 68 01 00 00       	call   800199 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 08 0f 00 00       	call   800f46 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 9f 00 00 00    	jne    8000e8 <umain+0xb5>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  800049:	83 ec 04             	sub    $0x4,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	68 00 00 b0 00       	push   $0xb00000
  800053:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 1c 12 00 00       	call   801278 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 e0 16 80 00       	push   $0x8016e0
  80006c:	e8 13 02 00 00       	call   800284 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 20 80 00    	pushl  0x802004
  80007a:	e8 68 07 00 00       	call   8007e7 <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 20 80 00    	pushl  0x802004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 5d 08 00 00       	call   8008f0 <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	75 10                	jne    8000aa <umain+0x77>
			cprintf("child received correct message\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 f4 16 80 00       	push   $0x8016f4
  8000a2:	e8 dd 01 00 00       	call   800284 <cprintf>
  8000a7:	83 c4 10             	add    $0x10,%esp

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	ff 35 00 20 80 00    	pushl  0x802000
  8000b3:	e8 2f 07 00 00       	call   8007e7 <strlen>
  8000b8:	83 c4 0c             	add    $0xc,%esp
  8000bb:	83 c0 01             	add    $0x1,%eax
  8000be:	50                   	push   %eax
  8000bf:	ff 35 00 20 80 00    	pushl  0x802000
  8000c5:	68 00 00 b0 00       	push   $0xb00000
  8000ca:	e8 4b 09 00 00       	call   800a1a <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000cf:	6a 07                	push   $0x7
  8000d1:	68 00 00 b0 00       	push   $0xb00000
  8000d6:	6a 00                	push   $0x0
  8000d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000db:	e8 0d 12 00 00       	call   8012ed <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 af 00 00 00       	jmp    800197 <umain+0x164>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8000ed:	8b 40 48             	mov    0x48(%eax),%eax
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	6a 07                	push   $0x7
  8000f5:	68 00 00 a0 00       	push   $0xa00000
  8000fa:	50                   	push   %eax
  8000fb:	e8 23 0b 00 00       	call   800c23 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800100:	83 c4 04             	add    $0x4,%esp
  800103:	ff 35 04 20 80 00    	pushl  0x802004
  800109:	e8 d9 06 00 00       	call   8007e7 <strlen>
  80010e:	83 c4 0c             	add    $0xc,%esp
  800111:	83 c0 01             	add    $0x1,%eax
  800114:	50                   	push   %eax
  800115:	ff 35 04 20 80 00    	pushl  0x802004
  80011b:	68 00 00 a0 00       	push   $0xa00000
  800120:	e8 f5 08 00 00       	call   800a1a <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800125:	6a 07                	push   $0x7
  800127:	68 00 00 a0 00       	push   $0xa00000
  80012c:	6a 00                	push   $0x0
  80012e:	ff 75 f4             	pushl  -0xc(%ebp)
  800131:	e8 b7 11 00 00       	call   8012ed <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 2f 11 00 00       	call   801278 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 e0 16 80 00       	push   $0x8016e0
  800159:	e8 26 01 00 00       	call   800284 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015e:	83 c4 04             	add    $0x4,%esp
  800161:	ff 35 00 20 80 00    	pushl  0x802000
  800167:	e8 7b 06 00 00       	call   8007e7 <strlen>
  80016c:	83 c4 0c             	add    $0xc,%esp
  80016f:	50                   	push   %eax
  800170:	ff 35 00 20 80 00    	pushl  0x802000
  800176:	68 00 00 a0 00       	push   $0xa00000
  80017b:	e8 70 07 00 00       	call   8008f0 <strncmp>
  800180:	83 c4 10             	add    $0x10,%esp
  800183:	85 c0                	test   %eax,%eax
  800185:	75 10                	jne    800197 <umain+0x164>
		cprintf("parent received correct message\n");
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	68 14 17 80 00       	push   $0x801714
  80018f:	e8 f0 00 00 00       	call   800284 <cprintf>
  800194:	83 c4 10             	add    $0x10,%esp
	return;
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001a1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8001a4:	e8 3c 0a 00 00       	call   800be5 <sys_getenvid>
  8001a9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ae:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001b1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001b6:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001bb:	85 db                	test   %ebx,%ebx
  8001bd:	7e 07                	jle    8001c6 <libmain+0x2d>
		binaryname = argv[0];
  8001bf:	8b 06                	mov    (%esi),%eax
  8001c1:	a3 08 20 80 00       	mov    %eax,0x802008

	// call user main routine
	umain(argc, argv);
  8001c6:	83 ec 08             	sub    $0x8,%esp
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	e8 63 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001d0:	e8 0a 00 00 00       	call   8001df <exit>
}
  8001d5:	83 c4 10             	add    $0x10,%esp
  8001d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001db:	5b                   	pop    %ebx
  8001dc:	5e                   	pop    %esi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8001e5:	6a 00                	push   $0x0
  8001e7:	e8 b8 09 00 00       	call   800ba4 <sys_env_destroy>
}
  8001ec:	83 c4 10             	add    $0x10,%esp
  8001ef:	c9                   	leave  
  8001f0:	c3                   	ret    

008001f1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 04             	sub    $0x4,%esp
  8001f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001fb:	8b 13                	mov    (%ebx),%edx
  8001fd:	8d 42 01             	lea    0x1(%edx),%eax
  800200:	89 03                	mov    %eax,(%ebx)
  800202:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800205:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800209:	3d ff 00 00 00       	cmp    $0xff,%eax
  80020e:	75 1a                	jne    80022a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800210:	83 ec 08             	sub    $0x8,%esp
  800213:	68 ff 00 00 00       	push   $0xff
  800218:	8d 43 08             	lea    0x8(%ebx),%eax
  80021b:	50                   	push   %eax
  80021c:	e8 46 09 00 00       	call   800b67 <sys_cputs>
		b->idx = 0;
  800221:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800227:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80022a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80022e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800231:	c9                   	leave  
  800232:	c3                   	ret    

00800233 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80023c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800243:	00 00 00 
	b.cnt = 0;
  800246:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80024d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800250:	ff 75 0c             	pushl  0xc(%ebp)
  800253:	ff 75 08             	pushl  0x8(%ebp)
  800256:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80025c:	50                   	push   %eax
  80025d:	68 f1 01 80 00       	push   $0x8001f1
  800262:	e8 54 01 00 00       	call   8003bb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800267:	83 c4 08             	add    $0x8,%esp
  80026a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800270:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	e8 eb 08 00 00       	call   800b67 <sys_cputs>

	return b.cnt;
}
  80027c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800282:	c9                   	leave  
  800283:	c3                   	ret    

00800284 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80028d:	50                   	push   %eax
  80028e:	ff 75 08             	pushl  0x8(%ebp)
  800291:	e8 9d ff ff ff       	call   800233 <vcprintf>
	va_end(ap);

	return cnt;
}
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	57                   	push   %edi
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	83 ec 1c             	sub    $0x1c,%esp
  8002a1:	89 c7                	mov    %eax,%edi
  8002a3:	89 d6                	mov    %edx,%esi
  8002a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ae:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002bc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002bf:	39 d3                	cmp    %edx,%ebx
  8002c1:	72 05                	jb     8002c8 <printnum+0x30>
  8002c3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002c6:	77 45                	ja     80030d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c8:	83 ec 0c             	sub    $0xc,%esp
  8002cb:	ff 75 18             	pushl  0x18(%ebp)
  8002ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002d4:	53                   	push   %ebx
  8002d5:	ff 75 10             	pushl  0x10(%ebp)
  8002d8:	83 ec 08             	sub    $0x8,%esp
  8002db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002de:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002e4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002e7:	e8 64 11 00 00       	call   801450 <__udivdi3>
  8002ec:	83 c4 18             	add    $0x18,%esp
  8002ef:	52                   	push   %edx
  8002f0:	50                   	push   %eax
  8002f1:	89 f2                	mov    %esi,%edx
  8002f3:	89 f8                	mov    %edi,%eax
  8002f5:	e8 9e ff ff ff       	call   800298 <printnum>
  8002fa:	83 c4 20             	add    $0x20,%esp
  8002fd:	eb 18                	jmp    800317 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	56                   	push   %esi
  800303:	ff 75 18             	pushl  0x18(%ebp)
  800306:	ff d7                	call   *%edi
  800308:	83 c4 10             	add    $0x10,%esp
  80030b:	eb 03                	jmp    800310 <printnum+0x78>
  80030d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800310:	83 eb 01             	sub    $0x1,%ebx
  800313:	85 db                	test   %ebx,%ebx
  800315:	7f e8                	jg     8002ff <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800317:	83 ec 08             	sub    $0x8,%esp
  80031a:	56                   	push   %esi
  80031b:	83 ec 04             	sub    $0x4,%esp
  80031e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800321:	ff 75 e0             	pushl  -0x20(%ebp)
  800324:	ff 75 dc             	pushl  -0x24(%ebp)
  800327:	ff 75 d8             	pushl  -0x28(%ebp)
  80032a:	e8 51 12 00 00       	call   801580 <__umoddi3>
  80032f:	83 c4 14             	add    $0x14,%esp
  800332:	0f be 80 8c 17 80 00 	movsbl 0x80178c(%eax),%eax
  800339:	50                   	push   %eax
  80033a:	ff d7                	call   *%edi
}
  80033c:	83 c4 10             	add    $0x10,%esp
  80033f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800342:	5b                   	pop    %ebx
  800343:	5e                   	pop    %esi
  800344:	5f                   	pop    %edi
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    

00800347 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80034a:	83 fa 01             	cmp    $0x1,%edx
  80034d:	7e 0e                	jle    80035d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80034f:	8b 10                	mov    (%eax),%edx
  800351:	8d 4a 08             	lea    0x8(%edx),%ecx
  800354:	89 08                	mov    %ecx,(%eax)
  800356:	8b 02                	mov    (%edx),%eax
  800358:	8b 52 04             	mov    0x4(%edx),%edx
  80035b:	eb 22                	jmp    80037f <getuint+0x38>
	else if (lflag)
  80035d:	85 d2                	test   %edx,%edx
  80035f:	74 10                	je     800371 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800361:	8b 10                	mov    (%eax),%edx
  800363:	8d 4a 04             	lea    0x4(%edx),%ecx
  800366:	89 08                	mov    %ecx,(%eax)
  800368:	8b 02                	mov    (%edx),%eax
  80036a:	ba 00 00 00 00       	mov    $0x0,%edx
  80036f:	eb 0e                	jmp    80037f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800371:	8b 10                	mov    (%eax),%edx
  800373:	8d 4a 04             	lea    0x4(%edx),%ecx
  800376:	89 08                	mov    %ecx,(%eax)
  800378:	8b 02                	mov    (%edx),%eax
  80037a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037f:	5d                   	pop    %ebp
  800380:	c3                   	ret    

00800381 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
  800384:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800387:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80038b:	8b 10                	mov    (%eax),%edx
  80038d:	3b 50 04             	cmp    0x4(%eax),%edx
  800390:	73 0a                	jae    80039c <sprintputch+0x1b>
		*b->buf++ = ch;
  800392:	8d 4a 01             	lea    0x1(%edx),%ecx
  800395:	89 08                	mov    %ecx,(%eax)
  800397:	8b 45 08             	mov    0x8(%ebp),%eax
  80039a:	88 02                	mov    %al,(%edx)
}
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a7:	50                   	push   %eax
  8003a8:	ff 75 10             	pushl  0x10(%ebp)
  8003ab:	ff 75 0c             	pushl  0xc(%ebp)
  8003ae:	ff 75 08             	pushl  0x8(%ebp)
  8003b1:	e8 05 00 00 00       	call   8003bb <vprintfmt>
	va_end(ap);
}
  8003b6:	83 c4 10             	add    $0x10,%esp
  8003b9:	c9                   	leave  
  8003ba:	c3                   	ret    

008003bb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
  8003be:	57                   	push   %edi
  8003bf:	56                   	push   %esi
  8003c0:	53                   	push   %ebx
  8003c1:	83 ec 2c             	sub    $0x2c,%esp
  8003c4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
  8003c7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003ce:	eb 17                	jmp    8003e7 <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d0:	85 c0                	test   %eax,%eax
  8003d2:	0f 84 9f 03 00 00    	je     800777 <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
  8003d8:	83 ec 08             	sub    $0x8,%esp
  8003db:	ff 75 0c             	pushl  0xc(%ebp)
  8003de:	50                   	push   %eax
  8003df:	ff 55 08             	call   *0x8(%ebp)
  8003e2:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e5:	89 f3                	mov    %esi,%ebx
  8003e7:	8d 73 01             	lea    0x1(%ebx),%esi
  8003ea:	0f b6 03             	movzbl (%ebx),%eax
  8003ed:	83 f8 25             	cmp    $0x25,%eax
  8003f0:	75 de                	jne    8003d0 <vprintfmt+0x15>
  8003f2:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003f6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003fd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800402:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800409:	ba 00 00 00 00       	mov    $0x0,%edx
  80040e:	eb 06                	jmp    800416 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800412:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	8d 5e 01             	lea    0x1(%esi),%ebx
  800419:	0f b6 06             	movzbl (%esi),%eax
  80041c:	0f b6 c8             	movzbl %al,%ecx
  80041f:	83 e8 23             	sub    $0x23,%eax
  800422:	3c 55                	cmp    $0x55,%al
  800424:	0f 87 2d 03 00 00    	ja     800757 <vprintfmt+0x39c>
  80042a:	0f b6 c0             	movzbl %al,%eax
  80042d:	ff 24 85 60 18 80 00 	jmp    *0x801860(,%eax,4)
  800434:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800436:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80043a:	eb da                	jmp    800416 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	89 de                	mov    %ebx,%esi
  80043e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800443:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  800446:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  80044a:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  80044d:	8d 41 d0             	lea    -0x30(%ecx),%eax
  800450:	83 f8 09             	cmp    $0x9,%eax
  800453:	77 33                	ja     800488 <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800455:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800458:	eb e9                	jmp    800443 <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80045a:	8b 45 14             	mov    0x14(%ebp),%eax
  80045d:	8d 48 04             	lea    0x4(%eax),%ecx
  800460:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800463:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800465:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800467:	eb 1f                	jmp    800488 <vprintfmt+0xcd>
  800469:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80046c:	85 c0                	test   %eax,%eax
  80046e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800473:	0f 49 c8             	cmovns %eax,%ecx
  800476:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800479:	89 de                	mov    %ebx,%esi
  80047b:	eb 99                	jmp    800416 <vprintfmt+0x5b>
  80047d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80047f:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  800486:	eb 8e                	jmp    800416 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  800488:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80048c:	79 88                	jns    800416 <vprintfmt+0x5b>
				width = precision, precision = -1;
  80048e:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800491:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800496:	e9 7b ff ff ff       	jmp    800416 <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80049b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a0:	e9 71 ff ff ff       	jmp    800416 <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
  8004a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a8:	8d 50 04             	lea    0x4(%eax),%edx
  8004ab:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  8004ae:	83 ec 08             	sub    $0x8,%esp
  8004b1:	ff 75 0c             	pushl  0xc(%ebp)
  8004b4:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8004b7:	03 08                	add    (%eax),%ecx
  8004b9:	51                   	push   %ecx
  8004ba:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
  8004bd:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
  8004c0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
  8004c7:	e9 1b ff ff ff       	jmp    8003e7 <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
  8004cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cf:	8d 48 04             	lea    0x4(%eax),%ecx
  8004d2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004d5:	8b 00                	mov    (%eax),%eax
  8004d7:	83 f8 02             	cmp    $0x2,%eax
  8004da:	74 1a                	je     8004f6 <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dc:	89 de                	mov    %ebx,%esi
  8004de:	83 f8 04             	cmp    $0x4,%eax
  8004e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e6:	b9 00 04 00 00       	mov    $0x400,%ecx
  8004eb:	0f 44 c1             	cmove  %ecx,%eax
  8004ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f1:	e9 20 ff ff ff       	jmp    800416 <vprintfmt+0x5b>
  8004f6:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
  8004f8:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
  8004ff:	e9 12 ff ff ff       	jmp    800416 <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800504:	8b 45 14             	mov    0x14(%ebp),%eax
  800507:	8d 50 04             	lea    0x4(%eax),%edx
  80050a:	89 55 14             	mov    %edx,0x14(%ebp)
  80050d:	8b 00                	mov    (%eax),%eax
  80050f:	99                   	cltd   
  800510:	31 d0                	xor    %edx,%eax
  800512:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800514:	83 f8 09             	cmp    $0x9,%eax
  800517:	7f 0b                	jg     800524 <vprintfmt+0x169>
  800519:	8b 14 85 c0 19 80 00 	mov    0x8019c0(,%eax,4),%edx
  800520:	85 d2                	test   %edx,%edx
  800522:	75 19                	jne    80053d <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800524:	50                   	push   %eax
  800525:	68 a4 17 80 00       	push   $0x8017a4
  80052a:	ff 75 0c             	pushl  0xc(%ebp)
  80052d:	ff 75 08             	pushl  0x8(%ebp)
  800530:	e8 69 fe ff ff       	call   80039e <printfmt>
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	e9 aa fe ff ff       	jmp    8003e7 <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  80053d:	52                   	push   %edx
  80053e:	68 ad 17 80 00       	push   $0x8017ad
  800543:	ff 75 0c             	pushl  0xc(%ebp)
  800546:	ff 75 08             	pushl  0x8(%ebp)
  800549:	e8 50 fe ff ff       	call   80039e <printfmt>
  80054e:	83 c4 10             	add    $0x10,%esp
  800551:	e9 91 fe ff ff       	jmp    8003e7 <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800556:	8b 45 14             	mov    0x14(%ebp),%eax
  800559:	8d 50 04             	lea    0x4(%eax),%edx
  80055c:	89 55 14             	mov    %edx,0x14(%ebp)
  80055f:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800561:	85 f6                	test   %esi,%esi
  800563:	b8 9d 17 80 00       	mov    $0x80179d,%eax
  800568:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80056b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80056f:	0f 8e 93 00 00 00    	jle    800608 <vprintfmt+0x24d>
  800575:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800579:	0f 84 91 00 00 00    	je     800610 <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
  80057f:	83 ec 08             	sub    $0x8,%esp
  800582:	57                   	push   %edi
  800583:	56                   	push   %esi
  800584:	e8 76 02 00 00       	call   8007ff <strnlen>
  800589:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80058c:	29 c1                	sub    %eax,%ecx
  80058e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800591:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800594:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  800598:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80059b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80059e:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005a1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005a4:	89 cb                	mov    %ecx,%ebx
  8005a6:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a8:	eb 0e                	jmp    8005b8 <vprintfmt+0x1fd>
					putch(padc, putdat);
  8005aa:	83 ec 08             	sub    $0x8,%esp
  8005ad:	56                   	push   %esi
  8005ae:	57                   	push   %edi
  8005af:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b2:	83 eb 01             	sub    $0x1,%ebx
  8005b5:	83 c4 10             	add    $0x10,%esp
  8005b8:	85 db                	test   %ebx,%ebx
  8005ba:	7f ee                	jg     8005aa <vprintfmt+0x1ef>
  8005bc:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005bf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005c2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005c5:	85 c9                	test   %ecx,%ecx
  8005c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8005cc:	0f 49 c1             	cmovns %ecx,%eax
  8005cf:	29 c1                	sub    %eax,%ecx
  8005d1:	89 cb                	mov    %ecx,%ebx
  8005d3:	eb 41                	jmp    800616 <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005d5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d9:	74 1b                	je     8005f6 <vprintfmt+0x23b>
  8005db:	0f be c0             	movsbl %al,%eax
  8005de:	83 e8 20             	sub    $0x20,%eax
  8005e1:	83 f8 5e             	cmp    $0x5e,%eax
  8005e4:	76 10                	jbe    8005f6 <vprintfmt+0x23b>
					putch('?', putdat);
  8005e6:	83 ec 08             	sub    $0x8,%esp
  8005e9:	ff 75 0c             	pushl  0xc(%ebp)
  8005ec:	6a 3f                	push   $0x3f
  8005ee:	ff 55 08             	call   *0x8(%ebp)
  8005f1:	83 c4 10             	add    $0x10,%esp
  8005f4:	eb 0d                	jmp    800603 <vprintfmt+0x248>
				else
					putch(ch, putdat);
  8005f6:	83 ec 08             	sub    $0x8,%esp
  8005f9:	ff 75 0c             	pushl  0xc(%ebp)
  8005fc:	52                   	push   %edx
  8005fd:	ff 55 08             	call   *0x8(%ebp)
  800600:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800603:	83 eb 01             	sub    $0x1,%ebx
  800606:	eb 0e                	jmp    800616 <vprintfmt+0x25b>
  800608:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80060b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80060e:	eb 06                	jmp    800616 <vprintfmt+0x25b>
  800610:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800613:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800616:	83 c6 01             	add    $0x1,%esi
  800619:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80061d:	0f be d0             	movsbl %al,%edx
  800620:	85 d2                	test   %edx,%edx
  800622:	74 25                	je     800649 <vprintfmt+0x28e>
  800624:	85 ff                	test   %edi,%edi
  800626:	78 ad                	js     8005d5 <vprintfmt+0x21a>
  800628:	83 ef 01             	sub    $0x1,%edi
  80062b:	79 a8                	jns    8005d5 <vprintfmt+0x21a>
  80062d:	89 d8                	mov    %ebx,%eax
  80062f:	8b 75 08             	mov    0x8(%ebp),%esi
  800632:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800635:	89 c3                	mov    %eax,%ebx
  800637:	eb 16                	jmp    80064f <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800639:	83 ec 08             	sub    $0x8,%esp
  80063c:	57                   	push   %edi
  80063d:	6a 20                	push   $0x20
  80063f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800641:	83 eb 01             	sub    $0x1,%ebx
  800644:	83 c4 10             	add    $0x10,%esp
  800647:	eb 06                	jmp    80064f <vprintfmt+0x294>
  800649:	8b 75 08             	mov    0x8(%ebp),%esi
  80064c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80064f:	85 db                	test   %ebx,%ebx
  800651:	7f e6                	jg     800639 <vprintfmt+0x27e>
  800653:	89 75 08             	mov    %esi,0x8(%ebp)
  800656:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800659:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80065c:	e9 86 fd ff ff       	jmp    8003e7 <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800661:	83 fa 01             	cmp    $0x1,%edx
  800664:	7e 10                	jle    800676 <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8d 50 08             	lea    0x8(%eax),%edx
  80066c:	89 55 14             	mov    %edx,0x14(%ebp)
  80066f:	8b 30                	mov    (%eax),%esi
  800671:	8b 78 04             	mov    0x4(%eax),%edi
  800674:	eb 26                	jmp    80069c <vprintfmt+0x2e1>
	else if (lflag)
  800676:	85 d2                	test   %edx,%edx
  800678:	74 12                	je     80068c <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8d 50 04             	lea    0x4(%eax),%edx
  800680:	89 55 14             	mov    %edx,0x14(%ebp)
  800683:	8b 30                	mov    (%eax),%esi
  800685:	89 f7                	mov    %esi,%edi
  800687:	c1 ff 1f             	sar    $0x1f,%edi
  80068a:	eb 10                	jmp    80069c <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8d 50 04             	lea    0x4(%eax),%edx
  800692:	89 55 14             	mov    %edx,0x14(%ebp)
  800695:	8b 30                	mov    (%eax),%esi
  800697:	89 f7                	mov    %esi,%edi
  800699:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80069c:	89 f0                	mov    %esi,%eax
  80069e:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006a0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006a5:	85 ff                	test   %edi,%edi
  8006a7:	79 7b                	jns    800724 <vprintfmt+0x369>
				putch('-', putdat);
  8006a9:	83 ec 08             	sub    $0x8,%esp
  8006ac:	ff 75 0c             	pushl  0xc(%ebp)
  8006af:	6a 2d                	push   $0x2d
  8006b1:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006b4:	89 f0                	mov    %esi,%eax
  8006b6:	89 fa                	mov    %edi,%edx
  8006b8:	f7 d8                	neg    %eax
  8006ba:	83 d2 00             	adc    $0x0,%edx
  8006bd:	f7 da                	neg    %edx
  8006bf:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006c2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006c7:	eb 5b                	jmp    800724 <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006c9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006cc:	e8 76 fc ff ff       	call   800347 <getuint>
			base = 10;
  8006d1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006d6:	eb 4c                	jmp    800724 <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
  8006d8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006db:	e8 67 fc ff ff       	call   800347 <getuint>
            base = 8;
  8006e0:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006e5:	eb 3d                	jmp    800724 <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
  8006e7:	83 ec 08             	sub    $0x8,%esp
  8006ea:	ff 75 0c             	pushl  0xc(%ebp)
  8006ed:	6a 30                	push   $0x30
  8006ef:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006f2:	83 c4 08             	add    $0x8,%esp
  8006f5:	ff 75 0c             	pushl  0xc(%ebp)
  8006f8:	6a 78                	push   $0x78
  8006fa:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800700:	8d 50 04             	lea    0x4(%eax),%edx
  800703:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800706:	8b 00                	mov    (%eax),%eax
  800708:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80070d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800710:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800715:	eb 0d                	jmp    800724 <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800717:	8d 45 14             	lea    0x14(%ebp),%eax
  80071a:	e8 28 fc ff ff       	call   800347 <getuint>
			base = 16;
  80071f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800724:	83 ec 0c             	sub    $0xc,%esp
  800727:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  80072b:	56                   	push   %esi
  80072c:	ff 75 e0             	pushl  -0x20(%ebp)
  80072f:	51                   	push   %ecx
  800730:	52                   	push   %edx
  800731:	50                   	push   %eax
  800732:	8b 55 0c             	mov    0xc(%ebp),%edx
  800735:	8b 45 08             	mov    0x8(%ebp),%eax
  800738:	e8 5b fb ff ff       	call   800298 <printnum>
			break;
  80073d:	83 c4 20             	add    $0x20,%esp
  800740:	e9 a2 fc ff ff       	jmp    8003e7 <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	ff 75 0c             	pushl  0xc(%ebp)
  80074b:	51                   	push   %ecx
  80074c:	ff 55 08             	call   *0x8(%ebp)
			break;
  80074f:	83 c4 10             	add    $0x10,%esp
  800752:	e9 90 fc ff ff       	jmp    8003e7 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800757:	83 ec 08             	sub    $0x8,%esp
  80075a:	ff 75 0c             	pushl  0xc(%ebp)
  80075d:	6a 25                	push   $0x25
  80075f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800762:	83 c4 10             	add    $0x10,%esp
  800765:	89 f3                	mov    %esi,%ebx
  800767:	eb 03                	jmp    80076c <vprintfmt+0x3b1>
  800769:	83 eb 01             	sub    $0x1,%ebx
  80076c:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800770:	75 f7                	jne    800769 <vprintfmt+0x3ae>
  800772:	e9 70 fc ff ff       	jmp    8003e7 <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  800777:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80077a:	5b                   	pop    %ebx
  80077b:	5e                   	pop    %esi
  80077c:	5f                   	pop    %edi
  80077d:	5d                   	pop    %ebp
  80077e:	c3                   	ret    

0080077f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	83 ec 18             	sub    $0x18,%esp
  800785:	8b 45 08             	mov    0x8(%ebp),%eax
  800788:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80078b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80078e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800792:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800795:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80079c:	85 c0                	test   %eax,%eax
  80079e:	74 26                	je     8007c6 <vsnprintf+0x47>
  8007a0:	85 d2                	test   %edx,%edx
  8007a2:	7e 22                	jle    8007c6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007a4:	ff 75 14             	pushl  0x14(%ebp)
  8007a7:	ff 75 10             	pushl  0x10(%ebp)
  8007aa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007ad:	50                   	push   %eax
  8007ae:	68 81 03 80 00       	push   $0x800381
  8007b3:	e8 03 fc ff ff       	call   8003bb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007bb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007c1:	83 c4 10             	add    $0x10,%esp
  8007c4:	eb 05                	jmp    8007cb <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007cb:	c9                   	leave  
  8007cc:	c3                   	ret    

008007cd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007d3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d6:	50                   	push   %eax
  8007d7:	ff 75 10             	pushl  0x10(%ebp)
  8007da:	ff 75 0c             	pushl  0xc(%ebp)
  8007dd:	ff 75 08             	pushl  0x8(%ebp)
  8007e0:	e8 9a ff ff ff       	call   80077f <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e5:	c9                   	leave  
  8007e6:	c3                   	ret    

008007e7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f2:	eb 03                	jmp    8007f7 <strlen+0x10>
		n++;
  8007f4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007fb:	75 f7                	jne    8007f4 <strlen+0xd>
		n++;
	return n;
}
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800805:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800808:	ba 00 00 00 00       	mov    $0x0,%edx
  80080d:	eb 03                	jmp    800812 <strnlen+0x13>
		n++;
  80080f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800812:	39 c2                	cmp    %eax,%edx
  800814:	74 08                	je     80081e <strnlen+0x1f>
  800816:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80081a:	75 f3                	jne    80080f <strnlen+0x10>
  80081c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	53                   	push   %ebx
  800824:	8b 45 08             	mov    0x8(%ebp),%eax
  800827:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80082a:	89 c2                	mov    %eax,%edx
  80082c:	83 c2 01             	add    $0x1,%edx
  80082f:	83 c1 01             	add    $0x1,%ecx
  800832:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800836:	88 5a ff             	mov    %bl,-0x1(%edx)
  800839:	84 db                	test   %bl,%bl
  80083b:	75 ef                	jne    80082c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80083d:	5b                   	pop    %ebx
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	53                   	push   %ebx
  800844:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800847:	53                   	push   %ebx
  800848:	e8 9a ff ff ff       	call   8007e7 <strlen>
  80084d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800850:	ff 75 0c             	pushl  0xc(%ebp)
  800853:	01 d8                	add    %ebx,%eax
  800855:	50                   	push   %eax
  800856:	e8 c5 ff ff ff       	call   800820 <strcpy>
	return dst;
}
  80085b:	89 d8                	mov    %ebx,%eax
  80085d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800860:	c9                   	leave  
  800861:	c3                   	ret    

00800862 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	56                   	push   %esi
  800866:	53                   	push   %ebx
  800867:	8b 75 08             	mov    0x8(%ebp),%esi
  80086a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086d:	89 f3                	mov    %esi,%ebx
  80086f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800872:	89 f2                	mov    %esi,%edx
  800874:	eb 0f                	jmp    800885 <strncpy+0x23>
		*dst++ = *src;
  800876:	83 c2 01             	add    $0x1,%edx
  800879:	0f b6 01             	movzbl (%ecx),%eax
  80087c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80087f:	80 39 01             	cmpb   $0x1,(%ecx)
  800882:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800885:	39 da                	cmp    %ebx,%edx
  800887:	75 ed                	jne    800876 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800889:	89 f0                	mov    %esi,%eax
  80088b:	5b                   	pop    %ebx
  80088c:	5e                   	pop    %esi
  80088d:	5d                   	pop    %ebp
  80088e:	c3                   	ret    

0080088f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	56                   	push   %esi
  800893:	53                   	push   %ebx
  800894:	8b 75 08             	mov    0x8(%ebp),%esi
  800897:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089a:	8b 55 10             	mov    0x10(%ebp),%edx
  80089d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80089f:	85 d2                	test   %edx,%edx
  8008a1:	74 21                	je     8008c4 <strlcpy+0x35>
  8008a3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008a7:	89 f2                	mov    %esi,%edx
  8008a9:	eb 09                	jmp    8008b4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008ab:	83 c2 01             	add    $0x1,%edx
  8008ae:	83 c1 01             	add    $0x1,%ecx
  8008b1:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008b4:	39 c2                	cmp    %eax,%edx
  8008b6:	74 09                	je     8008c1 <strlcpy+0x32>
  8008b8:	0f b6 19             	movzbl (%ecx),%ebx
  8008bb:	84 db                	test   %bl,%bl
  8008bd:	75 ec                	jne    8008ab <strlcpy+0x1c>
  8008bf:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008c1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008c4:	29 f0                	sub    %esi,%eax
}
  8008c6:	5b                   	pop    %ebx
  8008c7:	5e                   	pop    %esi
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d3:	eb 06                	jmp    8008db <strcmp+0x11>
		p++, q++;
  8008d5:	83 c1 01             	add    $0x1,%ecx
  8008d8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008db:	0f b6 01             	movzbl (%ecx),%eax
  8008de:	84 c0                	test   %al,%al
  8008e0:	74 04                	je     8008e6 <strcmp+0x1c>
  8008e2:	3a 02                	cmp    (%edx),%al
  8008e4:	74 ef                	je     8008d5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e6:	0f b6 c0             	movzbl %al,%eax
  8008e9:	0f b6 12             	movzbl (%edx),%edx
  8008ec:	29 d0                	sub    %edx,%eax
}
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	53                   	push   %ebx
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fa:	89 c3                	mov    %eax,%ebx
  8008fc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ff:	eb 06                	jmp    800907 <strncmp+0x17>
		n--, p++, q++;
  800901:	83 c0 01             	add    $0x1,%eax
  800904:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800907:	39 d8                	cmp    %ebx,%eax
  800909:	74 15                	je     800920 <strncmp+0x30>
  80090b:	0f b6 08             	movzbl (%eax),%ecx
  80090e:	84 c9                	test   %cl,%cl
  800910:	74 04                	je     800916 <strncmp+0x26>
  800912:	3a 0a                	cmp    (%edx),%cl
  800914:	74 eb                	je     800901 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800916:	0f b6 00             	movzbl (%eax),%eax
  800919:	0f b6 12             	movzbl (%edx),%edx
  80091c:	29 d0                	sub    %edx,%eax
  80091e:	eb 05                	jmp    800925 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800920:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800925:	5b                   	pop    %ebx
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800932:	eb 07                	jmp    80093b <strchr+0x13>
		if (*s == c)
  800934:	38 ca                	cmp    %cl,%dl
  800936:	74 0f                	je     800947 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800938:	83 c0 01             	add    $0x1,%eax
  80093b:	0f b6 10             	movzbl (%eax),%edx
  80093e:	84 d2                	test   %dl,%dl
  800940:	75 f2                	jne    800934 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800942:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
  80094f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800953:	eb 03                	jmp    800958 <strfind+0xf>
  800955:	83 c0 01             	add    $0x1,%eax
  800958:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80095b:	38 ca                	cmp    %cl,%dl
  80095d:	74 04                	je     800963 <strfind+0x1a>
  80095f:	84 d2                	test   %dl,%dl
  800961:	75 f2                	jne    800955 <strfind+0xc>
			break;
	return (char *) s;
}
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	57                   	push   %edi
  800969:	56                   	push   %esi
  80096a:	53                   	push   %ebx
  80096b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80096e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800971:	85 c9                	test   %ecx,%ecx
  800973:	74 36                	je     8009ab <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800975:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80097b:	75 28                	jne    8009a5 <memset+0x40>
  80097d:	f6 c1 03             	test   $0x3,%cl
  800980:	75 23                	jne    8009a5 <memset+0x40>
		c &= 0xFF;
  800982:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800986:	89 d3                	mov    %edx,%ebx
  800988:	c1 e3 08             	shl    $0x8,%ebx
  80098b:	89 d6                	mov    %edx,%esi
  80098d:	c1 e6 18             	shl    $0x18,%esi
  800990:	89 d0                	mov    %edx,%eax
  800992:	c1 e0 10             	shl    $0x10,%eax
  800995:	09 f0                	or     %esi,%eax
  800997:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800999:	89 d8                	mov    %ebx,%eax
  80099b:	09 d0                	or     %edx,%eax
  80099d:	c1 e9 02             	shr    $0x2,%ecx
  8009a0:	fc                   	cld    
  8009a1:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a3:	eb 06                	jmp    8009ab <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a8:	fc                   	cld    
  8009a9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ab:	89 f8                	mov    %edi,%eax
  8009ad:	5b                   	pop    %ebx
  8009ae:	5e                   	pop    %esi
  8009af:	5f                   	pop    %edi
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	57                   	push   %edi
  8009b6:	56                   	push   %esi
  8009b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ba:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009c0:	39 c6                	cmp    %eax,%esi
  8009c2:	73 35                	jae    8009f9 <memmove+0x47>
  8009c4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c7:	39 d0                	cmp    %edx,%eax
  8009c9:	73 2e                	jae    8009f9 <memmove+0x47>
		s += n;
		d += n;
  8009cb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ce:	89 d6                	mov    %edx,%esi
  8009d0:	09 fe                	or     %edi,%esi
  8009d2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d8:	75 13                	jne    8009ed <memmove+0x3b>
  8009da:	f6 c1 03             	test   $0x3,%cl
  8009dd:	75 0e                	jne    8009ed <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009df:	83 ef 04             	sub    $0x4,%edi
  8009e2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e5:	c1 e9 02             	shr    $0x2,%ecx
  8009e8:	fd                   	std    
  8009e9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009eb:	eb 09                	jmp    8009f6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009ed:	83 ef 01             	sub    $0x1,%edi
  8009f0:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009f3:	fd                   	std    
  8009f4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009f6:	fc                   	cld    
  8009f7:	eb 1d                	jmp    800a16 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f9:	89 f2                	mov    %esi,%edx
  8009fb:	09 c2                	or     %eax,%edx
  8009fd:	f6 c2 03             	test   $0x3,%dl
  800a00:	75 0f                	jne    800a11 <memmove+0x5f>
  800a02:	f6 c1 03             	test   $0x3,%cl
  800a05:	75 0a                	jne    800a11 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a07:	c1 e9 02             	shr    $0x2,%ecx
  800a0a:	89 c7                	mov    %eax,%edi
  800a0c:	fc                   	cld    
  800a0d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0f:	eb 05                	jmp    800a16 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a11:	89 c7                	mov    %eax,%edi
  800a13:	fc                   	cld    
  800a14:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a16:	5e                   	pop    %esi
  800a17:	5f                   	pop    %edi
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a1d:	ff 75 10             	pushl  0x10(%ebp)
  800a20:	ff 75 0c             	pushl  0xc(%ebp)
  800a23:	ff 75 08             	pushl  0x8(%ebp)
  800a26:	e8 87 ff ff ff       	call   8009b2 <memmove>
}
  800a2b:	c9                   	leave  
  800a2c:	c3                   	ret    

00800a2d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	56                   	push   %esi
  800a31:	53                   	push   %ebx
  800a32:	8b 45 08             	mov    0x8(%ebp),%eax
  800a35:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a38:	89 c6                	mov    %eax,%esi
  800a3a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3d:	eb 1a                	jmp    800a59 <memcmp+0x2c>
		if (*s1 != *s2)
  800a3f:	0f b6 08             	movzbl (%eax),%ecx
  800a42:	0f b6 1a             	movzbl (%edx),%ebx
  800a45:	38 d9                	cmp    %bl,%cl
  800a47:	74 0a                	je     800a53 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a49:	0f b6 c1             	movzbl %cl,%eax
  800a4c:	0f b6 db             	movzbl %bl,%ebx
  800a4f:	29 d8                	sub    %ebx,%eax
  800a51:	eb 0f                	jmp    800a62 <memcmp+0x35>
		s1++, s2++;
  800a53:	83 c0 01             	add    $0x1,%eax
  800a56:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a59:	39 f0                	cmp    %esi,%eax
  800a5b:	75 e2                	jne    800a3f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	53                   	push   %ebx
  800a6a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a6d:	89 c1                	mov    %eax,%ecx
  800a6f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a72:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a76:	eb 0a                	jmp    800a82 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a78:	0f b6 10             	movzbl (%eax),%edx
  800a7b:	39 da                	cmp    %ebx,%edx
  800a7d:	74 07                	je     800a86 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a7f:	83 c0 01             	add    $0x1,%eax
  800a82:	39 c8                	cmp    %ecx,%eax
  800a84:	72 f2                	jb     800a78 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a86:	5b                   	pop    %ebx
  800a87:	5d                   	pop    %ebp
  800a88:	c3                   	ret    

00800a89 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a89:	55                   	push   %ebp
  800a8a:	89 e5                	mov    %esp,%ebp
  800a8c:	57                   	push   %edi
  800a8d:	56                   	push   %esi
  800a8e:	53                   	push   %ebx
  800a8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a92:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a95:	eb 03                	jmp    800a9a <strtol+0x11>
		s++;
  800a97:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a9a:	0f b6 01             	movzbl (%ecx),%eax
  800a9d:	3c 20                	cmp    $0x20,%al
  800a9f:	74 f6                	je     800a97 <strtol+0xe>
  800aa1:	3c 09                	cmp    $0x9,%al
  800aa3:	74 f2                	je     800a97 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aa5:	3c 2b                	cmp    $0x2b,%al
  800aa7:	75 0a                	jne    800ab3 <strtol+0x2a>
		s++;
  800aa9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aac:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab1:	eb 11                	jmp    800ac4 <strtol+0x3b>
  800ab3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ab8:	3c 2d                	cmp    $0x2d,%al
  800aba:	75 08                	jne    800ac4 <strtol+0x3b>
		s++, neg = 1;
  800abc:	83 c1 01             	add    $0x1,%ecx
  800abf:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aca:	75 15                	jne    800ae1 <strtol+0x58>
  800acc:	80 39 30             	cmpb   $0x30,(%ecx)
  800acf:	75 10                	jne    800ae1 <strtol+0x58>
  800ad1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ad5:	75 7c                	jne    800b53 <strtol+0xca>
		s += 2, base = 16;
  800ad7:	83 c1 02             	add    $0x2,%ecx
  800ada:	bb 10 00 00 00       	mov    $0x10,%ebx
  800adf:	eb 16                	jmp    800af7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ae1:	85 db                	test   %ebx,%ebx
  800ae3:	75 12                	jne    800af7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ae5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aea:	80 39 30             	cmpb   $0x30,(%ecx)
  800aed:	75 08                	jne    800af7 <strtol+0x6e>
		s++, base = 8;
  800aef:	83 c1 01             	add    $0x1,%ecx
  800af2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800af7:	b8 00 00 00 00       	mov    $0x0,%eax
  800afc:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aff:	0f b6 11             	movzbl (%ecx),%edx
  800b02:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b05:	89 f3                	mov    %esi,%ebx
  800b07:	80 fb 09             	cmp    $0x9,%bl
  800b0a:	77 08                	ja     800b14 <strtol+0x8b>
			dig = *s - '0';
  800b0c:	0f be d2             	movsbl %dl,%edx
  800b0f:	83 ea 30             	sub    $0x30,%edx
  800b12:	eb 22                	jmp    800b36 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b14:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b17:	89 f3                	mov    %esi,%ebx
  800b19:	80 fb 19             	cmp    $0x19,%bl
  800b1c:	77 08                	ja     800b26 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b1e:	0f be d2             	movsbl %dl,%edx
  800b21:	83 ea 57             	sub    $0x57,%edx
  800b24:	eb 10                	jmp    800b36 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b26:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b29:	89 f3                	mov    %esi,%ebx
  800b2b:	80 fb 19             	cmp    $0x19,%bl
  800b2e:	77 16                	ja     800b46 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b30:	0f be d2             	movsbl %dl,%edx
  800b33:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b36:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b39:	7d 0b                	jge    800b46 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b3b:	83 c1 01             	add    $0x1,%ecx
  800b3e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b42:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b44:	eb b9                	jmp    800aff <strtol+0x76>

	if (endptr)
  800b46:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b4a:	74 0d                	je     800b59 <strtol+0xd0>
		*endptr = (char *) s;
  800b4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b4f:	89 0e                	mov    %ecx,(%esi)
  800b51:	eb 06                	jmp    800b59 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b53:	85 db                	test   %ebx,%ebx
  800b55:	74 98                	je     800aef <strtol+0x66>
  800b57:	eb 9e                	jmp    800af7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b59:	89 c2                	mov    %eax,%edx
  800b5b:	f7 da                	neg    %edx
  800b5d:	85 ff                	test   %edi,%edi
  800b5f:	0f 45 c2             	cmovne %edx,%eax
}
  800b62:	5b                   	pop    %ebx
  800b63:	5e                   	pop    %esi
  800b64:	5f                   	pop    %edi
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	57                   	push   %edi
  800b6b:	56                   	push   %esi
  800b6c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b75:	8b 55 08             	mov    0x8(%ebp),%edx
  800b78:	89 c3                	mov    %eax,%ebx
  800b7a:	89 c7                	mov    %eax,%edi
  800b7c:	89 c6                	mov    %eax,%esi
  800b7e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b90:	b8 01 00 00 00       	mov    $0x1,%eax
  800b95:	89 d1                	mov    %edx,%ecx
  800b97:	89 d3                	mov    %edx,%ebx
  800b99:	89 d7                	mov    %edx,%edi
  800b9b:	89 d6                	mov    %edx,%esi
  800b9d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
  800baa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bad:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bb2:	b8 03 00 00 00       	mov    $0x3,%eax
  800bb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bba:	89 cb                	mov    %ecx,%ebx
  800bbc:	89 cf                	mov    %ecx,%edi
  800bbe:	89 ce                	mov    %ecx,%esi
  800bc0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc2:	85 c0                	test   %eax,%eax
  800bc4:	7e 17                	jle    800bdd <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc6:	83 ec 0c             	sub    $0xc,%esp
  800bc9:	50                   	push   %eax
  800bca:	6a 03                	push   $0x3
  800bcc:	68 e8 19 80 00       	push   $0x8019e8
  800bd1:	6a 23                	push   $0x23
  800bd3:	68 05 1a 80 00       	push   $0x801a05
  800bd8:	e8 a1 07 00 00       	call   80137e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	57                   	push   %edi
  800be9:	56                   	push   %esi
  800bea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800beb:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf0:	b8 02 00 00 00       	mov    $0x2,%eax
  800bf5:	89 d1                	mov    %edx,%ecx
  800bf7:	89 d3                	mov    %edx,%ebx
  800bf9:	89 d7                	mov    %edx,%edi
  800bfb:	89 d6                	mov    %edx,%esi
  800bfd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_yield>:

void
sys_yield(void)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c14:	89 d1                	mov    %edx,%ecx
  800c16:	89 d3                	mov    %edx,%ebx
  800c18:	89 d7                	mov    %edx,%edi
  800c1a:	89 d6                	mov    %edx,%esi
  800c1c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2c:	be 00 00 00 00       	mov    $0x0,%esi
  800c31:	b8 04 00 00 00       	mov    $0x4,%eax
  800c36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c3f:	89 f7                	mov    %esi,%edi
  800c41:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c43:	85 c0                	test   %eax,%eax
  800c45:	7e 17                	jle    800c5e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c47:	83 ec 0c             	sub    $0xc,%esp
  800c4a:	50                   	push   %eax
  800c4b:	6a 04                	push   $0x4
  800c4d:	68 e8 19 80 00       	push   $0x8019e8
  800c52:	6a 23                	push   $0x23
  800c54:	68 05 1a 80 00       	push   $0x801a05
  800c59:	e8 20 07 00 00       	call   80137e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c61:	5b                   	pop    %ebx
  800c62:	5e                   	pop    %esi
  800c63:	5f                   	pop    %edi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	57                   	push   %edi
  800c6a:	56                   	push   %esi
  800c6b:	53                   	push   %ebx
  800c6c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c77:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c80:	8b 75 18             	mov    0x18(%ebp),%esi
  800c83:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c85:	85 c0                	test   %eax,%eax
  800c87:	7e 17                	jle    800ca0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c89:	83 ec 0c             	sub    $0xc,%esp
  800c8c:	50                   	push   %eax
  800c8d:	6a 05                	push   $0x5
  800c8f:	68 e8 19 80 00       	push   $0x8019e8
  800c94:	6a 23                	push   $0x23
  800c96:	68 05 1a 80 00       	push   $0x801a05
  800c9b:	e8 de 06 00 00       	call   80137e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca3:	5b                   	pop    %ebx
  800ca4:	5e                   	pop    %esi
  800ca5:	5f                   	pop    %edi
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	57                   	push   %edi
  800cac:	56                   	push   %esi
  800cad:	53                   	push   %ebx
  800cae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb6:	b8 06 00 00 00       	mov    $0x6,%eax
  800cbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	89 df                	mov    %ebx,%edi
  800cc3:	89 de                	mov    %ebx,%esi
  800cc5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc7:	85 c0                	test   %eax,%eax
  800cc9:	7e 17                	jle    800ce2 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccb:	83 ec 0c             	sub    $0xc,%esp
  800cce:	50                   	push   %eax
  800ccf:	6a 06                	push   $0x6
  800cd1:	68 e8 19 80 00       	push   $0x8019e8
  800cd6:	6a 23                	push   $0x23
  800cd8:	68 05 1a 80 00       	push   $0x801a05
  800cdd:	e8 9c 06 00 00       	call   80137e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ce2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
  800cf0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf8:	b8 08 00 00 00       	mov    $0x8,%eax
  800cfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d00:	8b 55 08             	mov    0x8(%ebp),%edx
  800d03:	89 df                	mov    %ebx,%edi
  800d05:	89 de                	mov    %ebx,%esi
  800d07:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	7e 17                	jle    800d24 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0d:	83 ec 0c             	sub    $0xc,%esp
  800d10:	50                   	push   %eax
  800d11:	6a 08                	push   $0x8
  800d13:	68 e8 19 80 00       	push   $0x8019e8
  800d18:	6a 23                	push   $0x23
  800d1a:	68 05 1a 80 00       	push   $0x801a05
  800d1f:	e8 5a 06 00 00       	call   80137e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d27:	5b                   	pop    %ebx
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	57                   	push   %edi
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
  800d32:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d35:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d42:	8b 55 08             	mov    0x8(%ebp),%edx
  800d45:	89 df                	mov    %ebx,%edi
  800d47:	89 de                	mov    %ebx,%esi
  800d49:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d4b:	85 c0                	test   %eax,%eax
  800d4d:	7e 17                	jle    800d66 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4f:	83 ec 0c             	sub    $0xc,%esp
  800d52:	50                   	push   %eax
  800d53:	6a 09                	push   $0x9
  800d55:	68 e8 19 80 00       	push   $0x8019e8
  800d5a:	6a 23                	push   $0x23
  800d5c:	68 05 1a 80 00       	push   $0x801a05
  800d61:	e8 18 06 00 00       	call   80137e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d69:	5b                   	pop    %ebx
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    

00800d6e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d74:	be 00 00 00 00       	mov    $0x0,%esi
  800d79:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d81:	8b 55 08             	mov    0x8(%ebp),%edx
  800d84:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d87:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d8a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d8c:	5b                   	pop    %ebx
  800d8d:	5e                   	pop    %esi
  800d8e:	5f                   	pop    %edi
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	57                   	push   %edi
  800d95:	56                   	push   %esi
  800d96:	53                   	push   %ebx
  800d97:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	89 cb                	mov    %ecx,%ebx
  800da9:	89 cf                	mov    %ecx,%edi
  800dab:	89 ce                	mov    %ecx,%esi
  800dad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800daf:	85 c0                	test   %eax,%eax
  800db1:	7e 17                	jle    800dca <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db3:	83 ec 0c             	sub    $0xc,%esp
  800db6:	50                   	push   %eax
  800db7:	6a 0c                	push   $0xc
  800db9:	68 e8 19 80 00       	push   $0x8019e8
  800dbe:	6a 23                	push   $0x23
  800dc0:	68 05 1a 80 00       	push   $0x801a05
  800dc5:	e8 b4 05 00 00       	call   80137e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcd:	5b                   	pop    %ebx
  800dce:	5e                   	pop    %esi
  800dcf:	5f                   	pop    %edi
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    

00800dd2 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	57                   	push   %edi
  800dd6:	56                   	push   %esi
  800dd7:	53                   	push   %ebx
  800dd8:	83 ec 0c             	sub    $0xc,%esp
  800ddb:	89 c7                	mov    %eax,%edi
  800ddd:	89 d3                	mov    %edx,%ebx
	int r;

	// LAB 4: Your code here.

    envid_t myenvid = sys_getenvid();
  800ddf:	e8 01 fe ff ff       	call   800be5 <sys_getenvid>
  800de4:	89 c6                	mov    %eax,%esi
    pte_t pte = uvpt[pn];
  800de6:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
    int perm;

    perm = PTE_U | PTE_P;
    if(pte & PTE_W || pte & PTE_COW)
  800ded:	a9 02 08 00 00       	test   $0x802,%eax
  800df2:	75 40                	jne    800e34 <duppage+0x62>
    {
        perm |= PTE_COW;
    }

    // map to envid VA
    if ((r = sys_page_map(myenvid,
  800df4:	c1 e3 0c             	shl    $0xc,%ebx
  800df7:	83 ec 0c             	sub    $0xc,%esp
  800dfa:	6a 05                	push   $0x5
  800dfc:	53                   	push   %ebx
  800dfd:	57                   	push   %edi
  800dfe:	53                   	push   %ebx
  800dff:	56                   	push   %esi
  800e00:	e8 61 fe ff ff       	call   800c66 <sys_page_map>
  800e05:	83 c4 20             	add    $0x20,%esp
  800e08:	85 c0                	test   %eax,%eax
  800e0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0f:	0f 4f c2             	cmovg  %edx,%eax
  800e12:	eb 3b                	jmp    800e4f <duppage+0x7d>
    }

    // if COW remap to self
    if(perm & PTE_COW)
    {
        if((r = sys_page_map(myenvid, 
  800e14:	83 ec 0c             	sub    $0xc,%esp
  800e17:	68 05 08 00 00       	push   $0x805
  800e1c:	53                   	push   %ebx
  800e1d:	56                   	push   %esi
  800e1e:	53                   	push   %ebx
  800e1f:	56                   	push   %esi
  800e20:	e8 41 fe ff ff       	call   800c66 <sys_page_map>
  800e25:	83 c4 20             	add    $0x20,%esp
  800e28:	85 c0                	test   %eax,%eax
  800e2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e2f:	0f 4f c2             	cmovg  %edx,%eax
  800e32:	eb 1b                	jmp    800e4f <duppage+0x7d>
    {
        perm |= PTE_COW;
    }

    // map to envid VA
    if ((r = sys_page_map(myenvid,
  800e34:	c1 e3 0c             	shl    $0xc,%ebx
  800e37:	83 ec 0c             	sub    $0xc,%esp
  800e3a:	68 05 08 00 00       	push   $0x805
  800e3f:	53                   	push   %ebx
  800e40:	57                   	push   %edi
  800e41:	53                   	push   %ebx
  800e42:	56                   	push   %esi
  800e43:	e8 1e fe ff ff       	call   800c66 <sys_page_map>
  800e48:	83 c4 20             	add    $0x20,%esp
  800e4b:	85 c0                	test   %eax,%eax
  800e4d:	79 c5                	jns    800e14 <duppage+0x42>
            return r;
        }
    }

	return 0;
}
  800e4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e52:	5b                   	pop    %ebx
  800e53:	5e                   	pop    %esi
  800e54:	5f                   	pop    %edi
  800e55:	5d                   	pop    %ebp
  800e56:	c3                   	ret    

00800e57 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	56                   	push   %esi
  800e5b:	53                   	push   %ebx
  800e5c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e5f:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

    if ((err & FEC_WR) == 0)
  800e61:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e65:	75 12                	jne    800e79 <pgfault+0x22>
    {
        panic("pgfault: page fault was not caused by write; %x.\n", utf->utf_fault_va);
  800e67:	53                   	push   %ebx
  800e68:	68 14 1a 80 00       	push   $0x801a14
  800e6d:	6a 1f                	push   $0x1f
  800e6f:	68 eb 1a 80 00       	push   $0x801aeb
  800e74:	e8 05 05 00 00       	call   80137e <_panic>
    }

    if ((uvpt[PGNUM(addr)] & PTE_COW) == 0) 
  800e79:	89 d8                	mov    %ebx,%eax
  800e7b:	c1 e8 0c             	shr    $0xc,%eax
  800e7e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e85:	f6 c4 08             	test   $0x8,%ah
  800e88:	75 12                	jne    800e9c <pgfault+0x45>
    {
        panic("pgfault: page fault on page which is not COW %x.\n", utf->utf_fault_va);
  800e8a:	53                   	push   %ebx
  800e8b:	68 48 1a 80 00       	push   $0x801a48
  800e90:	6a 24                	push   $0x24
  800e92:	68 eb 1a 80 00       	push   $0x801aeb
  800e97:	e8 e2 04 00 00       	call   80137e <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    envid_t envid = sys_getenvid();
  800e9c:	e8 44 fd ff ff       	call   800be5 <sys_getenvid>
  800ea1:	89 c6                	mov    %eax,%esi

    //allocate temp page
    if (sys_page_alloc(envid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  800ea3:	83 ec 04             	sub    $0x4,%esp
  800ea6:	6a 07                	push   $0x7
  800ea8:	68 00 f0 7f 00       	push   $0x7ff000
  800ead:	50                   	push   %eax
  800eae:	e8 70 fd ff ff       	call   800c23 <sys_page_alloc>
  800eb3:	83 c4 10             	add    $0x10,%esp
  800eb6:	85 c0                	test   %eax,%eax
  800eb8:	79 14                	jns    800ece <pgfault+0x77>
    {
        panic("pgfault: can't allocate temp page.\n");
  800eba:	83 ec 04             	sub    $0x4,%esp
  800ebd:	68 7c 1a 80 00       	push   $0x801a7c
  800ec2:	6a 32                	push   $0x32
  800ec4:	68 eb 1a 80 00       	push   $0x801aeb
  800ec9:	e8 b0 04 00 00       	call   80137e <_panic>
    }

    memmove(PFTEMP, (void *)ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800ece:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800ed4:	83 ec 04             	sub    $0x4,%esp
  800ed7:	68 00 10 00 00       	push   $0x1000
  800edc:	53                   	push   %ebx
  800edd:	68 00 f0 7f 00       	push   $0x7ff000
  800ee2:	e8 cb fa ff ff       	call   8009b2 <memmove>

    if(sys_page_map(envid, PFTEMP, envid, (void *)ROUNDDOWN(addr, PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
  800ee7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eee:	53                   	push   %ebx
  800eef:	56                   	push   %esi
  800ef0:	68 00 f0 7f 00       	push   $0x7ff000
  800ef5:	56                   	push   %esi
  800ef6:	e8 6b fd ff ff       	call   800c66 <sys_page_map>
  800efb:	83 c4 20             	add    $0x20,%esp
  800efe:	85 c0                	test   %eax,%eax
  800f00:	79 14                	jns    800f16 <pgfault+0xbf>
    {
        panic("pgfault: can't map temp page to old page.\n");
  800f02:	83 ec 04             	sub    $0x4,%esp
  800f05:	68 a0 1a 80 00       	push   $0x801aa0
  800f0a:	6a 39                	push   $0x39
  800f0c:	68 eb 1a 80 00       	push   $0x801aeb
  800f11:	e8 68 04 00 00       	call   80137e <_panic>
    }

    if(sys_page_unmap(envid, PFTEMP) < 0)
  800f16:	83 ec 08             	sub    $0x8,%esp
  800f19:	68 00 f0 7f 00       	push   $0x7ff000
  800f1e:	56                   	push   %esi
  800f1f:	e8 84 fd ff ff       	call   800ca8 <sys_page_unmap>
  800f24:	83 c4 10             	add    $0x10,%esp
  800f27:	85 c0                	test   %eax,%eax
  800f29:	79 14                	jns    800f3f <pgfault+0xe8>
    {
        panic("pgfault: couldn't unmap page.\n");
  800f2b:	83 ec 04             	sub    $0x4,%esp
  800f2e:	68 cc 1a 80 00       	push   $0x801acc
  800f33:	6a 3e                	push   $0x3e
  800f35:	68 eb 1a 80 00       	push   $0x801aeb
  800f3a:	e8 3f 04 00 00       	call   80137e <_panic>
    }
	//panic("pgfault not implemented");
}
  800f3f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f42:	5b                   	pop    %ebx
  800f43:	5e                   	pop    %esi
  800f44:	5d                   	pop    %ebp
  800f45:	c3                   	ret    

00800f46 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	57                   	push   %edi
  800f4a:	56                   	push   %esi
  800f4b:	53                   	push   %ebx
  800f4c:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    extern void _pgfault_upcall(void);
    envid_t myenvid = sys_getenvid();
  800f4f:	e8 91 fc ff ff       	call   800be5 <sys_getenvid>
  800f54:	89 45 e0             	mov    %eax,-0x20(%ebp)
    envid_t envid;
    uint32_t i, j, pn;

    //set page fault handler
    set_pgfault_handler(pgfault);
  800f57:	83 ec 0c             	sub    $0xc,%esp
  800f5a:	68 57 0e 80 00       	push   $0x800e57
  800f5f:	e8 60 04 00 00       	call   8013c4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f64:	b8 07 00 00 00       	mov    $0x7,%eax
  800f69:	cd 30                	int    $0x30
  800f6b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f6e:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    //create a child
    if((envid = sys_exofork()) < 0)
  800f71:	83 c4 10             	add    $0x10,%esp
  800f74:	85 c0                	test   %eax,%eax
  800f76:	0f 88 13 01 00 00    	js     80108f <fork+0x149>
  800f7c:	bf 02 00 00 00       	mov    $0x2,%edi
    {
        return -1;
    }

    if(envid == 0)
  800f81:	85 c0                	test   %eax,%eax
  800f83:	75 21                	jne    800fa6 <fork+0x60>
    {
        thisenv = &envs[ENVX(sys_getenvid())];
  800f85:	e8 5b fc ff ff       	call   800be5 <sys_getenvid>
  800f8a:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f8f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f92:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f97:	a3 0c 20 80 00       	mov    %eax,0x80200c

        return envid;
  800f9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa1:	e9 0a 01 00 00       	jmp    8010b0 <fork+0x16a>
    }

    //copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
  800fa6:	8b 04 bd 00 d0 7b ef 	mov    -0x10843000(,%edi,4),%eax
  800fad:	a8 01                	test   $0x1,%al
  800faf:	74 3a                	je     800feb <fork+0xa5>
        {
            for (j = 0; j < NPTENTRIES; j++)
            {
                pn = PGNUM(PGADDR(i, j, 0));
  800fb1:	89 fe                	mov    %edi,%esi
  800fb3:	c1 e6 16             	shl    $0x16,%esi
  800fb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fbb:	89 da                	mov    %ebx,%edx
  800fbd:	c1 e2 0c             	shl    $0xc,%edx
  800fc0:	09 f2                	or     %esi,%edx
  800fc2:	c1 ea 0c             	shr    $0xc,%edx
                if(pn == PGNUM(UXSTACKTOP - PGSIZE))
  800fc5:	81 fa ff eb 0e 00    	cmp    $0xeebff,%edx
  800fcb:	74 1e                	je     800feb <fork+0xa5>
                {
                    break;
                }

                if(uvpt[pn] & PTE_P)
  800fcd:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800fd4:	a8 01                	test   $0x1,%al
  800fd6:	74 08                	je     800fe0 <fork+0x9a>
                {
                    duppage(envid, pn);
  800fd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fdb:	e8 f2 fd ff ff       	call   800dd2 <duppage>
    //copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
        {
            for (j = 0; j < NPTENTRIES; j++)
  800fe0:	83 c3 01             	add    $0x1,%ebx
  800fe3:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  800fe9:	75 d0                	jne    800fbb <fork+0x75>

        return envid;
    }

    //copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
  800feb:	83 c7 01             	add    $0x1,%edi
  800fee:	81 ff bb 03 00 00    	cmp    $0x3bb,%edi
  800ff4:	75 b0                	jne    800fa6 <fork+0x60>
                }
            }
        }
    }

    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
  800ff6:	83 ec 04             	sub    $0x4,%esp
  800ff9:	6a 07                	push   $0x7
  800ffb:	68 00 f0 bf ee       	push   $0xeebff000
  801000:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801003:	57                   	push   %edi
  801004:	e8 1a fc ff ff       	call   800c23 <sys_page_alloc>
  801009:	83 c4 10             	add    $0x10,%esp
  80100c:	85 c0                	test   %eax,%eax
  80100e:	0f 88 82 00 00 00    	js     801096 <fork+0x150>
    {
        return -1;
    }

    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  801014:	83 ec 0c             	sub    $0xc,%esp
  801017:	6a 07                	push   $0x7
  801019:	68 00 f0 7f 00       	push   $0x7ff000
  80101e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801021:	56                   	push   %esi
  801022:	68 00 f0 bf ee       	push   $0xeebff000
  801027:	57                   	push   %edi
  801028:	e8 39 fc ff ff       	call   800c66 <sys_page_map>
  80102d:	83 c4 20             	add    $0x20,%esp
  801030:	85 c0                	test   %eax,%eax
  801032:	78 69                	js     80109d <fork+0x157>
    {
        return -1;
    }

    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);
  801034:	83 ec 04             	sub    $0x4,%esp
  801037:	68 00 10 00 00       	push   $0x1000
  80103c:	68 00 f0 7f 00       	push   $0x7ff000
  801041:	68 00 f0 bf ee       	push   $0xeebff000
  801046:	e8 67 f9 ff ff       	call   8009b2 <memmove>

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
  80104b:	83 c4 08             	add    $0x8,%esp
  80104e:	68 00 f0 7f 00       	push   $0x7ff000
  801053:	56                   	push   %esi
  801054:	e8 4f fc ff ff       	call   800ca8 <sys_page_unmap>
  801059:	83 c4 10             	add    $0x10,%esp
  80105c:	85 c0                	test   %eax,%eax
  80105e:	78 44                	js     8010a4 <fork+0x15e>
    {
        return -1;
    }

    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
  801060:	83 ec 08             	sub    $0x8,%esp
  801063:	68 29 14 80 00       	push   $0x801429
  801068:	57                   	push   %edi
  801069:	e8 be fc ff ff       	call   800d2c <sys_env_set_pgfault_upcall>
  80106e:	83 c4 10             	add    $0x10,%esp
  801071:	85 c0                	test   %eax,%eax
  801073:	78 36                	js     8010ab <fork+0x165>
    {
        return -1;
    }

    if(sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  801075:	83 ec 08             	sub    $0x8,%esp
  801078:	6a 02                	push   $0x2
  80107a:	57                   	push   %edi
  80107b:	e8 6a fc ff ff       	call   800cea <sys_env_set_status>
  801080:	83 c4 10             	add    $0x10,%esp
    {
        return -1;
    }

    return envid;
  801083:	85 c0                	test   %eax,%eax
  801085:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80108a:	0f 49 c7             	cmovns %edi,%eax
  80108d:	eb 21                	jmp    8010b0 <fork+0x16a>
    set_pgfault_handler(pgfault);

    //create a child
    if((envid = sys_exofork()) < 0)
    {
        return -1;
  80108f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801094:	eb 1a                	jmp    8010b0 <fork+0x16a>
        }
    }

    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  801096:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80109b:	eb 13                	jmp    8010b0 <fork+0x16a>
    }

    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  80109d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8010a2:	eb 0c                	jmp    8010b0 <fork+0x16a>

    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
    {
        return -1;
  8010a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8010a9:	eb 05                	jmp    8010b0 <fork+0x16a>
    }

    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
    {
        return -1;
  8010ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
        return -1;
    }

    return envid;
    //	panic("fork not implemented");
}
  8010b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b3:	5b                   	pop    %ebx
  8010b4:	5e                   	pop    %esi
  8010b5:	5f                   	pop    %edi
  8010b6:	5d                   	pop    %ebp
  8010b7:	c3                   	ret    

008010b8 <sfork>:

// Challenge!
int
sfork(void)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	57                   	push   %edi
  8010bc:	56                   	push   %esi
  8010bd:	53                   	push   %ebx
  8010be:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    extern void _pgfault_upcall(void);
    envid_t myenvid = sys_getenvid();
  8010c1:	e8 1f fb ff ff       	call   800be5 <sys_getenvid>
  8010c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    envid_t envid;
    uint32_t i, j, pn;
    int perm;

    // set page fault handler
    set_pgfault_handler(pgfault);
  8010c9:	83 ec 0c             	sub    $0xc,%esp
  8010cc:	68 57 0e 80 00       	push   $0x800e57
  8010d1:	e8 ee 02 00 00       	call   8013c4 <set_pgfault_handler>
  8010d6:	b8 07 00 00 00       	mov    $0x7,%eax
  8010db:	cd 30                	int    $0x30
  8010dd:	89 45 dc             	mov    %eax,-0x24(%ebp)

    // create a child
    if((envid = sys_exofork()) < 0)
  8010e0:	83 c4 10             	add    $0x10,%esp
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	0f 88 5d 01 00 00    	js     801248 <sfork+0x190>
  8010eb:	89 c7                	mov    %eax,%edi
  8010ed:	c7 45 e4 02 00 00 00 	movl   $0x2,-0x1c(%ebp)
    {
        return -1;
    }

    if(envid == 0)
  8010f4:	85 c0                	test   %eax,%eax
  8010f6:	75 21                	jne    801119 <sfork+0x61>
    {
        thisenv = &envs[ENVX(sys_getenvid())];
  8010f8:	e8 e8 fa ff ff       	call   800be5 <sys_getenvid>
  8010fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  801102:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80110a:	a3 0c 20 80 00       	mov    %eax,0x80200c
        return envid;
  80110f:	b8 00 00 00 00       	mov    $0x0,%eax
  801114:	e9 57 01 00 00       	jmp    801270 <sfork+0x1b8>
    }

    // copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
  801119:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80111c:	8b 04 b5 00 d0 7b ef 	mov    -0x10843000(,%esi,4),%eax
  801123:	a8 01                	test   $0x1,%al
  801125:	74 76                	je     80119d <sfork+0xe5>
        {
            for (j = 0; j < NPTENTRIES; j++)
            {
                pn = PGNUM(PGADDR(i, j, 0));
  801127:	c1 e6 16             	shl    $0x16,%esi
  80112a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80112f:	89 d8                	mov    %ebx,%eax
  801131:	c1 e0 0c             	shl    $0xc,%eax
  801134:	09 f0                	or     %esi,%eax
  801136:	89 c2                	mov    %eax,%edx
  801138:	c1 ea 0c             	shr    $0xc,%edx
                if(pn == PGNUM(UXSTACKTOP - PGSIZE))
  80113b:	81 fa ff eb 0e 00    	cmp    $0xeebff,%edx
  801141:	74 5a                	je     80119d <sfork+0xe5>
                {
                    break;
                }

                if(pn == PGNUM(USTACKTOP - PGSIZE))
  801143:	81 fa fd eb 0e 00    	cmp    $0xeebfd,%edx
  801149:	75 09                	jne    801154 <sfork+0x9c>
                {
                     duppage(envid, pn); // cow for stack page
  80114b:	89 f8                	mov    %edi,%eax
  80114d:	e8 80 fc ff ff       	call   800dd2 <duppage>
                     continue;
  801152:	eb 3e                	jmp    801192 <sfork+0xda>
                }

                // map same page to child env with same perms
                if (uvpt[pn] & PTE_P)
  801154:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  80115b:	f6 c1 01             	test   $0x1,%cl
  80115e:	74 32                	je     801192 <sfork+0xda>
                {
                    
                    perm = uvpt[pn] & ~(uvpt[pn] & ~(PTE_P |PTE_U | PTE_W | PTE_AVAIL));
  801160:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801167:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
                    if (sys_page_map(myenvid, (void *)(PGADDR(i, j, 0)),
  80116e:	83 ec 0c             	sub    $0xc,%esp
  801171:	81 e2 f8 f1 ff ff    	and    $0xfffff1f8,%edx
  801177:	f7 d2                	not    %edx
  801179:	21 d1                	and    %edx,%ecx
  80117b:	51                   	push   %ecx
  80117c:	50                   	push   %eax
  80117d:	57                   	push   %edi
  80117e:	50                   	push   %eax
  80117f:	ff 75 e0             	pushl  -0x20(%ebp)
  801182:	e8 df fa ff ff       	call   800c66 <sys_page_map>
  801187:	83 c4 20             	add    $0x20,%esp
  80118a:	85 c0                	test   %eax,%eax
  80118c:	0f 88 bd 00 00 00    	js     80124f <sfork+0x197>
    // copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
    {
        if(uvpd[i] & PTE_P)
        {
            for (j = 0; j < NPTENTRIES; j++)
  801192:	83 c3 01             	add    $0x1,%ebx
  801195:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  80119b:	75 92                	jne    80112f <sfork+0x77>
        thisenv = &envs[ENVX(sys_getenvid())];
        return envid;
    }

    // copy address space to child
    for (i = PDX(UTEXT); i < PDX(UXSTACKTOP); i++)
  80119d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  8011a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011a4:	3d bb 03 00 00       	cmp    $0x3bb,%eax
  8011a9:	0f 85 6a ff ff ff    	jne    801119 <sfork+0x61>
            }
        }
    }

    // allocate new exception stack for child
    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
  8011af:	83 ec 04             	sub    $0x4,%esp
  8011b2:	6a 07                	push   $0x7
  8011b4:	68 00 f0 bf ee       	push   $0xeebff000
  8011b9:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8011bc:	57                   	push   %edi
  8011bd:	e8 61 fa ff ff       	call   800c23 <sys_page_alloc>
  8011c2:	83 c4 10             	add    $0x10,%esp
  8011c5:	85 c0                	test   %eax,%eax
  8011c7:	0f 88 89 00 00 00    	js     801256 <sfork+0x19e>
    {
        return -1;
    }

    // map child uxstack to temp page
    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  8011cd:	83 ec 0c             	sub    $0xc,%esp
  8011d0:	6a 07                	push   $0x7
  8011d2:	68 00 f0 7f 00       	push   $0x7ff000
  8011d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8011da:	56                   	push   %esi
  8011db:	68 00 f0 bf ee       	push   $0xeebff000
  8011e0:	57                   	push   %edi
  8011e1:	e8 80 fa ff ff       	call   800c66 <sys_page_map>
  8011e6:	83 c4 20             	add    $0x20,%esp
  8011e9:	85 c0                	test   %eax,%eax
  8011eb:	78 70                	js     80125d <sfork+0x1a5>
    {
        return -1;
    }

    // copy own uxstack to temp page
    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);
  8011ed:	83 ec 04             	sub    $0x4,%esp
  8011f0:	68 00 10 00 00       	push   $0x1000
  8011f5:	68 00 f0 7f 00       	push   $0x7ff000
  8011fa:	68 00 f0 bf ee       	push   $0xeebff000
  8011ff:	e8 ae f7 ff ff       	call   8009b2 <memmove>

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
  801204:	83 c4 08             	add    $0x8,%esp
  801207:	68 00 f0 7f 00       	push   $0x7ff000
  80120c:	56                   	push   %esi
  80120d:	e8 96 fa ff ff       	call   800ca8 <sys_page_unmap>
  801212:	83 c4 10             	add    $0x10,%esp
  801215:	85 c0                	test   %eax,%eax
  801217:	78 4b                	js     801264 <sfork+0x1ac>
    {
        return -1;
    }

    // set page fault handler in child
    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
  801219:	83 ec 08             	sub    $0x8,%esp
  80121c:	68 29 14 80 00       	push   $0x801429
  801221:	57                   	push   %edi
  801222:	e8 05 fb ff ff       	call   800d2c <sys_env_set_pgfault_upcall>
  801227:	83 c4 10             	add    $0x10,%esp
  80122a:	85 c0                	test   %eax,%eax
  80122c:	78 3d                	js     80126b <sfork+0x1b3>
    {
        return -1;
    }

    // mark child env as RUNNABLE
    if(sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  80122e:	83 ec 08             	sub    $0x8,%esp
  801231:	6a 02                	push   $0x2
  801233:	57                   	push   %edi
  801234:	e8 b1 fa ff ff       	call   800cea <sys_env_set_status>
  801239:	83 c4 10             	add    $0x10,%esp
    {
        return -1;
    }

    return envid;
  80123c:	85 c0                	test   %eax,%eax
  80123e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801243:	0f 49 c7             	cmovns %edi,%eax
  801246:	eb 28                	jmp    801270 <sfork+0x1b8>
    set_pgfault_handler(pgfault);

    // create a child
    if((envid = sys_exofork()) < 0)
    {
        return -1;
  801248:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80124d:	eb 21                	jmp    801270 <sfork+0x1b8>
                    
                    perm = uvpt[pn] & ~(uvpt[pn] & ~(PTE_P |PTE_U | PTE_W | PTE_AVAIL));
                    if (sys_page_map(myenvid, (void *)(PGADDR(i, j, 0)),
                                     envid,   (void *)(PGADDR(i, j, 0)), perm) < 0)
                    {
                        return -1;
  80124f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801254:	eb 1a                	jmp    801270 <sfork+0x1b8>
    }

    // allocate new exception stack for child
    if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  801256:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80125b:	eb 13                	jmp    801270 <sfork+0x1b8>
    }

    // map child uxstack to temp page
    if(sys_page_map(envid, (void *)(UXSTACKTOP - PGSIZE), myenvid, PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
    {
        return -1;
  80125d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801262:	eb 0c                	jmp    801270 <sfork+0x1b8>
    // copy own uxstack to temp page
    memmove((void *)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);

    if(sys_page_unmap(myenvid, PFTEMP) < 0)
    {
        return -1;
  801264:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801269:	eb 05                	jmp    801270 <sfork+0x1b8>
    }

    // set page fault handler in child
    if(sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0)
    {
        return -1;
  80126b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    {
        return -1;
    }

    return envid;
}
  801270:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801273:	5b                   	pop    %ebx
  801274:	5e                   	pop    %esi
  801275:	5f                   	pop    %edi
  801276:	5d                   	pop    %ebp
  801277:	c3                   	ret    

00801278 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801278:	55                   	push   %ebp
  801279:	89 e5                	mov    %esp,%ebp
  80127b:	57                   	push   %edi
  80127c:	56                   	push   %esi
  80127d:	53                   	push   %ebx
  80127e:	83 ec 18             	sub    $0x18,%esp
  801281:	8b 7d 08             	mov    0x8(%ebp),%edi
  801284:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801287:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
    int r = sys_ipc_recv((pg) ? pg : (void *)UTOP);
  80128a:	85 db                	test   %ebx,%ebx
  80128c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801291:	0f 45 c3             	cmovne %ebx,%eax
  801294:	50                   	push   %eax
  801295:	e8 f7 fa ff ff       	call   800d91 <sys_ipc_recv>
  80129a:	89 c2                	mov    %eax,%edx

    if (from_env_store)
  80129c:	83 c4 10             	add    $0x10,%esp
  80129f:	85 ff                	test   %edi,%edi
  8012a1:	74 13                	je     8012b6 <ipc_recv+0x3e>
    {
        *from_env_store = (r == 0) ? thisenv->env_ipc_from : 0;
  8012a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a8:	85 d2                	test   %edx,%edx
  8012aa:	75 08                	jne    8012b4 <ipc_recv+0x3c>
  8012ac:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8012b1:	8b 40 74             	mov    0x74(%eax),%eax
  8012b4:	89 07                	mov    %eax,(%edi)
    }

    if (perm_store)
  8012b6:	85 f6                	test   %esi,%esi
  8012b8:	74 1d                	je     8012d7 <ipc_recv+0x5f>
    {
        *perm_store = (r == 0 && (uint32_t) pg < UTOP) ? thisenv->env_ipc_perm : 0;
  8012ba:	85 d2                	test   %edx,%edx
  8012bc:	75 12                	jne    8012d0 <ipc_recv+0x58>
  8012be:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  8012c4:	77 0a                	ja     8012d0 <ipc_recv+0x58>
  8012c6:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8012cb:	8b 40 78             	mov    0x78(%eax),%eax
  8012ce:	eb 05                	jmp    8012d5 <ipc_recv+0x5d>
  8012d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d5:	89 06                	mov    %eax,(%esi)
    }

    if (r)
    {
        return r;
  8012d7:	89 d0                	mov    %edx,%eax
    if (perm_store)
    {
        *perm_store = (r == 0 && (uint32_t) pg < UTOP) ? thisenv->env_ipc_perm : 0;
    }

    if (r)
  8012d9:	85 d2                	test   %edx,%edx
  8012db:	75 08                	jne    8012e5 <ipc_recv+0x6d>
    {
        return r;
    }

    return thisenv->env_ipc_value;
  8012dd:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8012e2:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  8012e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012e8:	5b                   	pop    %ebx
  8012e9:	5e                   	pop    %esi
  8012ea:	5f                   	pop    %edi
  8012eb:	5d                   	pop    %ebp
  8012ec:	c3                   	ret    

008012ed <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012ed:	55                   	push   %ebp
  8012ee:	89 e5                	mov    %esp,%ebp
  8012f0:	57                   	push   %edi
  8012f1:	56                   	push   %esi
  8012f2:	53                   	push   %ebx
  8012f3:	83 ec 0c             	sub    $0xc,%esp
  8012f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8012fc:	85 c0                	test   %eax,%eax
  8012fe:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
  801303:	0f 45 f0             	cmovne %eax,%esi
	// LAB 4: Your code here.
 
    int r = 0;
    do
    {
        r = sys_ipc_try_send(to_env, val, pg ? pg : (void *)UTOP, perm);
  801306:	ff 75 14             	pushl  0x14(%ebp)
  801309:	56                   	push   %esi
  80130a:	ff 75 0c             	pushl  0xc(%ebp)
  80130d:	57                   	push   %edi
  80130e:	e8 5b fa ff ff       	call   800d6e <sys_ipc_try_send>
  801313:	89 c3                	mov    %eax,%ebx

        if (r != 0 && r != -E_IPC_NOT_RECV)
  801315:	8d 40 08             	lea    0x8(%eax),%eax
  801318:	83 c4 10             	add    $0x10,%esp
  80131b:	a9 f7 ff ff ff       	test   $0xfffffff7,%eax
  801320:	74 12                	je     801334 <ipc_send+0x47>
        {
            panic("ipc_send: error %e", r);
  801322:	53                   	push   %ebx
  801323:	68 f6 1a 80 00       	push   $0x801af6
  801328:	6a 44                	push   $0x44
  80132a:	68 09 1b 80 00       	push   $0x801b09
  80132f:	e8 4a 00 00 00       	call   80137e <_panic>
        }
        else
        {
            sys_yield();
  801334:	e8 cb f8 ff ff       	call   800c04 <sys_yield>
        }
    }while(r != 0);
  801339:	85 db                	test   %ebx,%ebx
  80133b:	75 c9                	jne    801306 <ipc_send+0x19>
	//panic("ipc_send not implemented");
}
  80133d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801340:	5b                   	pop    %ebx
  801341:	5e                   	pop    %esi
  801342:	5f                   	pop    %edi
  801343:	5d                   	pop    %ebp
  801344:	c3                   	ret    

00801345 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80134b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801350:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801353:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801359:	8b 52 50             	mov    0x50(%edx),%edx
  80135c:	39 ca                	cmp    %ecx,%edx
  80135e:	75 0d                	jne    80136d <ipc_find_env+0x28>
			return envs[i].env_id;
  801360:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801363:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801368:	8b 40 48             	mov    0x48(%eax),%eax
  80136b:	eb 0f                	jmp    80137c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80136d:	83 c0 01             	add    $0x1,%eax
  801370:	3d 00 04 00 00       	cmp    $0x400,%eax
  801375:	75 d9                	jne    801350 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801377:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80137c:	5d                   	pop    %ebp
  80137d:	c3                   	ret    

0080137e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80137e:	55                   	push   %ebp
  80137f:	89 e5                	mov    %esp,%ebp
  801381:	56                   	push   %esi
  801382:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801383:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801386:	8b 35 08 20 80 00    	mov    0x802008,%esi
  80138c:	e8 54 f8 ff ff       	call   800be5 <sys_getenvid>
  801391:	83 ec 0c             	sub    $0xc,%esp
  801394:	ff 75 0c             	pushl  0xc(%ebp)
  801397:	ff 75 08             	pushl  0x8(%ebp)
  80139a:	56                   	push   %esi
  80139b:	50                   	push   %eax
  80139c:	68 14 1b 80 00       	push   $0x801b14
  8013a1:	e8 de ee ff ff       	call   800284 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013a6:	83 c4 18             	add    $0x18,%esp
  8013a9:	53                   	push   %ebx
  8013aa:	ff 75 10             	pushl  0x10(%ebp)
  8013ad:	e8 81 ee ff ff       	call   800233 <vcprintf>
	cprintf("\n");
  8013b2:	c7 04 24 f2 16 80 00 	movl   $0x8016f2,(%esp)
  8013b9:	e8 c6 ee ff ff       	call   800284 <cprintf>
  8013be:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8013c1:	cc                   	int3   
  8013c2:	eb fd                	jmp    8013c1 <_panic+0x43>

008013c4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8013c4:	55                   	push   %ebp
  8013c5:	89 e5                	mov    %esp,%ebp
  8013c7:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8013ca:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  8013d1:	75 4c                	jne    80141f <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.

        void *va = (void *)(UXSTACKTOP - PGSIZE);
        if (sys_page_alloc(thisenv->env_id, va, PTE_P | PTE_U | PTE_W))
  8013d3:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8013d8:	8b 40 48             	mov    0x48(%eax),%eax
  8013db:	83 ec 04             	sub    $0x4,%esp
  8013de:	6a 07                	push   $0x7
  8013e0:	68 00 f0 bf ee       	push   $0xeebff000
  8013e5:	50                   	push   %eax
  8013e6:	e8 38 f8 ff ff       	call   800c23 <sys_page_alloc>
  8013eb:	83 c4 10             	add    $0x10,%esp
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	74 14                	je     801406 <set_pgfault_handler+0x42>
        {
            panic("Unable to allocate memory for pgfault expected\n");
  8013f2:	83 ec 04             	sub    $0x4,%esp
  8013f5:	68 38 1b 80 00       	push   $0x801b38
  8013fa:	6a 24                	push   $0x24
  8013fc:	68 68 1b 80 00       	push   $0x801b68
  801401:	e8 78 ff ff ff       	call   80137e <_panic>
        }

        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801406:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80140b:	8b 40 48             	mov    0x48(%eax),%eax
  80140e:	83 ec 08             	sub    $0x8,%esp
  801411:	68 29 14 80 00       	push   $0x801429
  801416:	50                   	push   %eax
  801417:	e8 10 f9 ff ff       	call   800d2c <sys_env_set_pgfault_upcall>
  80141c:	83 c4 10             	add    $0x10,%esp

		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80141f:	8b 45 08             	mov    0x8(%ebp),%eax
  801422:	a3 10 20 80 00       	mov    %eax,0x802010
}
  801427:	c9                   	leave  
  801428:	c3                   	ret    

00801429 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801429:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80142a:	a1 10 20 80 00       	mov    0x802010,%eax
	call *%eax
  80142f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801431:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
    movl %esp, %ebx
  801434:	89 e3                	mov    %esp,%ebx
    // 40 is the size between utf_fault_va ~ utf_regs
    movl 40(%esp), %eax
  801436:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 48(%esp), %esp
  80143a:	8b 64 24 30          	mov    0x30(%esp),%esp
    pushl %eax
  80143e:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    movl %ebx, %esp
  80143f:	89 dc                	mov    %ebx,%esp
    subl $4, 48(%esp)
  801441:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    popl %eax
  801446:	58                   	pop    %eax
    popl %eax
  801447:	58                   	pop    %eax
    popal
  801448:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  801449:	83 c4 04             	add    $0x4,%esp
    popfl
  80144c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp
  80144d:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  80144e:	c3                   	ret    
  80144f:	90                   	nop

00801450 <__udivdi3>:
  801450:	55                   	push   %ebp
  801451:	57                   	push   %edi
  801452:	56                   	push   %esi
  801453:	53                   	push   %ebx
  801454:	83 ec 1c             	sub    $0x1c,%esp
  801457:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80145b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80145f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801463:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801467:	85 f6                	test   %esi,%esi
  801469:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80146d:	89 ca                	mov    %ecx,%edx
  80146f:	89 f8                	mov    %edi,%eax
  801471:	75 3d                	jne    8014b0 <__udivdi3+0x60>
  801473:	39 cf                	cmp    %ecx,%edi
  801475:	0f 87 c5 00 00 00    	ja     801540 <__udivdi3+0xf0>
  80147b:	85 ff                	test   %edi,%edi
  80147d:	89 fd                	mov    %edi,%ebp
  80147f:	75 0b                	jne    80148c <__udivdi3+0x3c>
  801481:	b8 01 00 00 00       	mov    $0x1,%eax
  801486:	31 d2                	xor    %edx,%edx
  801488:	f7 f7                	div    %edi
  80148a:	89 c5                	mov    %eax,%ebp
  80148c:	89 c8                	mov    %ecx,%eax
  80148e:	31 d2                	xor    %edx,%edx
  801490:	f7 f5                	div    %ebp
  801492:	89 c1                	mov    %eax,%ecx
  801494:	89 d8                	mov    %ebx,%eax
  801496:	89 cf                	mov    %ecx,%edi
  801498:	f7 f5                	div    %ebp
  80149a:	89 c3                	mov    %eax,%ebx
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
  8014b0:	39 ce                	cmp    %ecx,%esi
  8014b2:	77 74                	ja     801528 <__udivdi3+0xd8>
  8014b4:	0f bd fe             	bsr    %esi,%edi
  8014b7:	83 f7 1f             	xor    $0x1f,%edi
  8014ba:	0f 84 98 00 00 00    	je     801558 <__udivdi3+0x108>
  8014c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8014c5:	89 f9                	mov    %edi,%ecx
  8014c7:	89 c5                	mov    %eax,%ebp
  8014c9:	29 fb                	sub    %edi,%ebx
  8014cb:	d3 e6                	shl    %cl,%esi
  8014cd:	89 d9                	mov    %ebx,%ecx
  8014cf:	d3 ed                	shr    %cl,%ebp
  8014d1:	89 f9                	mov    %edi,%ecx
  8014d3:	d3 e0                	shl    %cl,%eax
  8014d5:	09 ee                	or     %ebp,%esi
  8014d7:	89 d9                	mov    %ebx,%ecx
  8014d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014dd:	89 d5                	mov    %edx,%ebp
  8014df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8014e3:	d3 ed                	shr    %cl,%ebp
  8014e5:	89 f9                	mov    %edi,%ecx
  8014e7:	d3 e2                	shl    %cl,%edx
  8014e9:	89 d9                	mov    %ebx,%ecx
  8014eb:	d3 e8                	shr    %cl,%eax
  8014ed:	09 c2                	or     %eax,%edx
  8014ef:	89 d0                	mov    %edx,%eax
  8014f1:	89 ea                	mov    %ebp,%edx
  8014f3:	f7 f6                	div    %esi
  8014f5:	89 d5                	mov    %edx,%ebp
  8014f7:	89 c3                	mov    %eax,%ebx
  8014f9:	f7 64 24 0c          	mull   0xc(%esp)
  8014fd:	39 d5                	cmp    %edx,%ebp
  8014ff:	72 10                	jb     801511 <__udivdi3+0xc1>
  801501:	8b 74 24 08          	mov    0x8(%esp),%esi
  801505:	89 f9                	mov    %edi,%ecx
  801507:	d3 e6                	shl    %cl,%esi
  801509:	39 c6                	cmp    %eax,%esi
  80150b:	73 07                	jae    801514 <__udivdi3+0xc4>
  80150d:	39 d5                	cmp    %edx,%ebp
  80150f:	75 03                	jne    801514 <__udivdi3+0xc4>
  801511:	83 eb 01             	sub    $0x1,%ebx
  801514:	31 ff                	xor    %edi,%edi
  801516:	89 d8                	mov    %ebx,%eax
  801518:	89 fa                	mov    %edi,%edx
  80151a:	83 c4 1c             	add    $0x1c,%esp
  80151d:	5b                   	pop    %ebx
  80151e:	5e                   	pop    %esi
  80151f:	5f                   	pop    %edi
  801520:	5d                   	pop    %ebp
  801521:	c3                   	ret    
  801522:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801528:	31 ff                	xor    %edi,%edi
  80152a:	31 db                	xor    %ebx,%ebx
  80152c:	89 d8                	mov    %ebx,%eax
  80152e:	89 fa                	mov    %edi,%edx
  801530:	83 c4 1c             	add    $0x1c,%esp
  801533:	5b                   	pop    %ebx
  801534:	5e                   	pop    %esi
  801535:	5f                   	pop    %edi
  801536:	5d                   	pop    %ebp
  801537:	c3                   	ret    
  801538:	90                   	nop
  801539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801540:	89 d8                	mov    %ebx,%eax
  801542:	f7 f7                	div    %edi
  801544:	31 ff                	xor    %edi,%edi
  801546:	89 c3                	mov    %eax,%ebx
  801548:	89 d8                	mov    %ebx,%eax
  80154a:	89 fa                	mov    %edi,%edx
  80154c:	83 c4 1c             	add    $0x1c,%esp
  80154f:	5b                   	pop    %ebx
  801550:	5e                   	pop    %esi
  801551:	5f                   	pop    %edi
  801552:	5d                   	pop    %ebp
  801553:	c3                   	ret    
  801554:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801558:	39 ce                	cmp    %ecx,%esi
  80155a:	72 0c                	jb     801568 <__udivdi3+0x118>
  80155c:	31 db                	xor    %ebx,%ebx
  80155e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801562:	0f 87 34 ff ff ff    	ja     80149c <__udivdi3+0x4c>
  801568:	bb 01 00 00 00       	mov    $0x1,%ebx
  80156d:	e9 2a ff ff ff       	jmp    80149c <__udivdi3+0x4c>
  801572:	66 90                	xchg   %ax,%ax
  801574:	66 90                	xchg   %ax,%ax
  801576:	66 90                	xchg   %ax,%ax
  801578:	66 90                	xchg   %ax,%ax
  80157a:	66 90                	xchg   %ax,%ax
  80157c:	66 90                	xchg   %ax,%ax
  80157e:	66 90                	xchg   %ax,%ax

00801580 <__umoddi3>:
  801580:	55                   	push   %ebp
  801581:	57                   	push   %edi
  801582:	56                   	push   %esi
  801583:	53                   	push   %ebx
  801584:	83 ec 1c             	sub    $0x1c,%esp
  801587:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80158b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80158f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801593:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801597:	85 d2                	test   %edx,%edx
  801599:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80159d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015a1:	89 f3                	mov    %esi,%ebx
  8015a3:	89 3c 24             	mov    %edi,(%esp)
  8015a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015aa:	75 1c                	jne    8015c8 <__umoddi3+0x48>
  8015ac:	39 f7                	cmp    %esi,%edi
  8015ae:	76 50                	jbe    801600 <__umoddi3+0x80>
  8015b0:	89 c8                	mov    %ecx,%eax
  8015b2:	89 f2                	mov    %esi,%edx
  8015b4:	f7 f7                	div    %edi
  8015b6:	89 d0                	mov    %edx,%eax
  8015b8:	31 d2                	xor    %edx,%edx
  8015ba:	83 c4 1c             	add    $0x1c,%esp
  8015bd:	5b                   	pop    %ebx
  8015be:	5e                   	pop    %esi
  8015bf:	5f                   	pop    %edi
  8015c0:	5d                   	pop    %ebp
  8015c1:	c3                   	ret    
  8015c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8015c8:	39 f2                	cmp    %esi,%edx
  8015ca:	89 d0                	mov    %edx,%eax
  8015cc:	77 52                	ja     801620 <__umoddi3+0xa0>
  8015ce:	0f bd ea             	bsr    %edx,%ebp
  8015d1:	83 f5 1f             	xor    $0x1f,%ebp
  8015d4:	75 5a                	jne    801630 <__umoddi3+0xb0>
  8015d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8015da:	0f 82 e0 00 00 00    	jb     8016c0 <__umoddi3+0x140>
  8015e0:	39 0c 24             	cmp    %ecx,(%esp)
  8015e3:	0f 86 d7 00 00 00    	jbe    8016c0 <__umoddi3+0x140>
  8015e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8015ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8015f1:	83 c4 1c             	add    $0x1c,%esp
  8015f4:	5b                   	pop    %ebx
  8015f5:	5e                   	pop    %esi
  8015f6:	5f                   	pop    %edi
  8015f7:	5d                   	pop    %ebp
  8015f8:	c3                   	ret    
  8015f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801600:	85 ff                	test   %edi,%edi
  801602:	89 fd                	mov    %edi,%ebp
  801604:	75 0b                	jne    801611 <__umoddi3+0x91>
  801606:	b8 01 00 00 00       	mov    $0x1,%eax
  80160b:	31 d2                	xor    %edx,%edx
  80160d:	f7 f7                	div    %edi
  80160f:	89 c5                	mov    %eax,%ebp
  801611:	89 f0                	mov    %esi,%eax
  801613:	31 d2                	xor    %edx,%edx
  801615:	f7 f5                	div    %ebp
  801617:	89 c8                	mov    %ecx,%eax
  801619:	f7 f5                	div    %ebp
  80161b:	89 d0                	mov    %edx,%eax
  80161d:	eb 99                	jmp    8015b8 <__umoddi3+0x38>
  80161f:	90                   	nop
  801620:	89 c8                	mov    %ecx,%eax
  801622:	89 f2                	mov    %esi,%edx
  801624:	83 c4 1c             	add    $0x1c,%esp
  801627:	5b                   	pop    %ebx
  801628:	5e                   	pop    %esi
  801629:	5f                   	pop    %edi
  80162a:	5d                   	pop    %ebp
  80162b:	c3                   	ret    
  80162c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801630:	8b 34 24             	mov    (%esp),%esi
  801633:	bf 20 00 00 00       	mov    $0x20,%edi
  801638:	89 e9                	mov    %ebp,%ecx
  80163a:	29 ef                	sub    %ebp,%edi
  80163c:	d3 e0                	shl    %cl,%eax
  80163e:	89 f9                	mov    %edi,%ecx
  801640:	89 f2                	mov    %esi,%edx
  801642:	d3 ea                	shr    %cl,%edx
  801644:	89 e9                	mov    %ebp,%ecx
  801646:	09 c2                	or     %eax,%edx
  801648:	89 d8                	mov    %ebx,%eax
  80164a:	89 14 24             	mov    %edx,(%esp)
  80164d:	89 f2                	mov    %esi,%edx
  80164f:	d3 e2                	shl    %cl,%edx
  801651:	89 f9                	mov    %edi,%ecx
  801653:	89 54 24 04          	mov    %edx,0x4(%esp)
  801657:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80165b:	d3 e8                	shr    %cl,%eax
  80165d:	89 e9                	mov    %ebp,%ecx
  80165f:	89 c6                	mov    %eax,%esi
  801661:	d3 e3                	shl    %cl,%ebx
  801663:	89 f9                	mov    %edi,%ecx
  801665:	89 d0                	mov    %edx,%eax
  801667:	d3 e8                	shr    %cl,%eax
  801669:	89 e9                	mov    %ebp,%ecx
  80166b:	09 d8                	or     %ebx,%eax
  80166d:	89 d3                	mov    %edx,%ebx
  80166f:	89 f2                	mov    %esi,%edx
  801671:	f7 34 24             	divl   (%esp)
  801674:	89 d6                	mov    %edx,%esi
  801676:	d3 e3                	shl    %cl,%ebx
  801678:	f7 64 24 04          	mull   0x4(%esp)
  80167c:	39 d6                	cmp    %edx,%esi
  80167e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801682:	89 d1                	mov    %edx,%ecx
  801684:	89 c3                	mov    %eax,%ebx
  801686:	72 08                	jb     801690 <__umoddi3+0x110>
  801688:	75 11                	jne    80169b <__umoddi3+0x11b>
  80168a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80168e:	73 0b                	jae    80169b <__umoddi3+0x11b>
  801690:	2b 44 24 04          	sub    0x4(%esp),%eax
  801694:	1b 14 24             	sbb    (%esp),%edx
  801697:	89 d1                	mov    %edx,%ecx
  801699:	89 c3                	mov    %eax,%ebx
  80169b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80169f:	29 da                	sub    %ebx,%edx
  8016a1:	19 ce                	sbb    %ecx,%esi
  8016a3:	89 f9                	mov    %edi,%ecx
  8016a5:	89 f0                	mov    %esi,%eax
  8016a7:	d3 e0                	shl    %cl,%eax
  8016a9:	89 e9                	mov    %ebp,%ecx
  8016ab:	d3 ea                	shr    %cl,%edx
  8016ad:	89 e9                	mov    %ebp,%ecx
  8016af:	d3 ee                	shr    %cl,%esi
  8016b1:	09 d0                	or     %edx,%eax
  8016b3:	89 f2                	mov    %esi,%edx
  8016b5:	83 c4 1c             	add    $0x1c,%esp
  8016b8:	5b                   	pop    %ebx
  8016b9:	5e                   	pop    %esi
  8016ba:	5f                   	pop    %edi
  8016bb:	5d                   	pop    %ebp
  8016bc:	c3                   	ret    
  8016bd:	8d 76 00             	lea    0x0(%esi),%esi
  8016c0:	29 f9                	sub    %edi,%ecx
  8016c2:	19 d6                	sbb    %edx,%esi
  8016c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016cc:	e9 18 ff ff ff       	jmp    8015e9 <__umoddi3+0x69>
