
obj/user/faultregs：     文件格式 elf32-i386


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
  80002c:	e8 60 05 00 00       	call   800591 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 71 15 80 00       	push   $0x801571
  800049:	68 40 15 80 00       	push   $0x801540
  80004e:	e8 6f 06 00 00       	call   8006c2 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 50 15 80 00       	push   $0x801550
  80005c:	68 54 15 80 00       	push   $0x801554
  800061:	e8 5c 06 00 00       	call   8006c2 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 64 15 80 00       	push   $0x801564
  800077:	e8 46 06 00 00       	call   8006c2 <cprintf>
  80007c:	83 c4 10             	add    $0x10,%esp

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  80007f:	bf 00 00 00 00       	mov    $0x0,%edi
  800084:	eb 15                	jmp    80009b <check_regs+0x68>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	68 68 15 80 00       	push   $0x801568
  80008e:	e8 2f 06 00 00       	call   8006c2 <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 72 15 80 00       	push   $0x801572
  8000a6:	68 54 15 80 00       	push   $0x801554
  8000ab:	e8 12 06 00 00       	call   8006c2 <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 64 15 80 00       	push   $0x801564
  8000c3:	e8 fa 05 00 00       	call   8006c2 <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 68 15 80 00       	push   $0x801568
  8000d5:	e8 e8 05 00 00       	call   8006c2 <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 76 15 80 00       	push   $0x801576
  8000ed:	68 54 15 80 00       	push   $0x801554
  8000f2:	e8 cb 05 00 00       	call   8006c2 <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 64 15 80 00       	push   $0x801564
  80010a:	e8 b3 05 00 00       	call   8006c2 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 68 15 80 00       	push   $0x801568
  80011c:	e8 a1 05 00 00       	call   8006c2 <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 7a 15 80 00       	push   $0x80157a
  800134:	68 54 15 80 00       	push   $0x801554
  800139:	e8 84 05 00 00       	call   8006c2 <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 64 15 80 00       	push   $0x801564
  800151:	e8 6c 05 00 00       	call   8006c2 <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 68 15 80 00       	push   $0x801568
  800163:	e8 5a 05 00 00       	call   8006c2 <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 7e 15 80 00       	push   $0x80157e
  80017b:	68 54 15 80 00       	push   $0x801554
  800180:	e8 3d 05 00 00       	call   8006c2 <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 64 15 80 00       	push   $0x801564
  800198:	e8 25 05 00 00       	call   8006c2 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 68 15 80 00       	push   $0x801568
  8001aa:	e8 13 05 00 00       	call   8006c2 <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 82 15 80 00       	push   $0x801582
  8001c2:	68 54 15 80 00       	push   $0x801554
  8001c7:	e8 f6 04 00 00       	call   8006c2 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 64 15 80 00       	push   $0x801564
  8001df:	e8 de 04 00 00       	call   8006c2 <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 68 15 80 00       	push   $0x801568
  8001f1:	e8 cc 04 00 00       	call   8006c2 <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 86 15 80 00       	push   $0x801586
  800209:	68 54 15 80 00       	push   $0x801554
  80020e:	e8 af 04 00 00       	call   8006c2 <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 64 15 80 00       	push   $0x801564
  800226:	e8 97 04 00 00       	call   8006c2 <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 68 15 80 00       	push   $0x801568
  800238:	e8 85 04 00 00       	call   8006c2 <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 8a 15 80 00       	push   $0x80158a
  800250:	68 54 15 80 00       	push   $0x801554
  800255:	e8 68 04 00 00       	call   8006c2 <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 64 15 80 00       	push   $0x801564
  80026d:	e8 50 04 00 00       	call   8006c2 <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 68 15 80 00       	push   $0x801568
  80027f:	e8 3e 04 00 00       	call   8006c2 <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 8e 15 80 00       	push   $0x80158e
  800297:	68 54 15 80 00       	push   $0x801554
  80029c:	e8 21 04 00 00       	call   8006c2 <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 64 15 80 00       	push   $0x801564
  8002b4:	e8 09 04 00 00       	call   8006c2 <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 95 15 80 00       	push   $0x801595
  8002c4:	68 54 15 80 00       	push   $0x801554
  8002c9:	e8 f4 03 00 00       	call   8006c2 <cprintf>
  8002ce:	83 c4 20             	add    $0x20,%esp
  8002d1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002d4:	39 46 28             	cmp    %eax,0x28(%esi)
  8002d7:	74 31                	je     80030a <check_regs+0x2d7>
  8002d9:	eb 55                	jmp    800330 <check_regs+0x2fd>
	CHECK(ebx, regs.reg_ebx);
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	68 68 15 80 00       	push   $0x801568
  8002e3:	e8 da 03 00 00       	call   8006c2 <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 95 15 80 00       	push   $0x801595
  8002f3:	68 54 15 80 00       	push   $0x801554
  8002f8:	e8 c5 03 00 00       	call   8006c2 <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 64 15 80 00       	push   $0x801564
  800312:	e8 ab 03 00 00       	call   8006c2 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 99 15 80 00       	push   $0x801599
  800322:	e8 9b 03 00 00       	call   8006c2 <cprintf>
	if (!mismatch)
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	85 ff                	test   %edi,%edi
  80032c:	74 24                	je     800352 <check_regs+0x31f>
  80032e:	eb 34                	jmp    800364 <check_regs+0x331>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	68 68 15 80 00       	push   $0x801568
  800338:	e8 85 03 00 00       	call   8006c2 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 99 15 80 00       	push   $0x801599
  800348:	e8 75 03 00 00       	call   8006c2 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 64 15 80 00       	push   $0x801564
  80035a:	e8 63 03 00 00       	call   8006c2 <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 68 15 80 00       	push   $0x801568
  80036c:	e8 51 03 00 00       	call   8006c2 <cprintf>
  800371:	83 c4 10             	add    $0x10,%esp
}
  800374:	eb 22                	jmp    800398 <check_regs+0x365>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	68 64 15 80 00       	push   $0x801564
  80037e:	e8 3f 03 00 00       	call   8006c2 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 99 15 80 00       	push   $0x801599
  80038e:	e8 2f 03 00 00       	call   8006c2 <cprintf>
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb cc                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
}
  800398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039b:	5b                   	pop    %ebx
  80039c:	5e                   	pop    %esi
  80039d:	5f                   	pop    %edi
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003b1:	74 18                	je     8003cb <pgfault+0x2b>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8003b3:	83 ec 0c             	sub    $0xc,%esp
  8003b6:	ff 70 28             	pushl  0x28(%eax)
  8003b9:	52                   	push   %edx
  8003ba:	68 00 16 80 00       	push   $0x801600
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 a7 15 80 00       	push   $0x8015a7
  8003c6:	e8 1e 02 00 00       	call   8005e9 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003cb:	8b 50 08             	mov    0x8(%eax),%edx
  8003ce:	89 15 60 20 80 00    	mov    %edx,0x802060
  8003d4:	8b 50 0c             	mov    0xc(%eax),%edx
  8003d7:	89 15 64 20 80 00    	mov    %edx,0x802064
  8003dd:	8b 50 10             	mov    0x10(%eax),%edx
  8003e0:	89 15 68 20 80 00    	mov    %edx,0x802068
  8003e6:	8b 50 14             	mov    0x14(%eax),%edx
  8003e9:	89 15 6c 20 80 00    	mov    %edx,0x80206c
  8003ef:	8b 50 18             	mov    0x18(%eax),%edx
  8003f2:	89 15 70 20 80 00    	mov    %edx,0x802070
  8003f8:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003fb:	89 15 74 20 80 00    	mov    %edx,0x802074
  800401:	8b 50 20             	mov    0x20(%eax),%edx
  800404:	89 15 78 20 80 00    	mov    %edx,0x802078
  80040a:	8b 50 24             	mov    0x24(%eax),%edx
  80040d:	89 15 7c 20 80 00    	mov    %edx,0x80207c
	during.eip = utf->utf_eip;
  800413:	8b 50 28             	mov    0x28(%eax),%edx
  800416:	89 15 80 20 80 00    	mov    %edx,0x802080
	during.eflags = utf->utf_eflags;
  80041c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80041f:	89 15 84 20 80 00    	mov    %edx,0x802084
	during.esp = utf->utf_esp;
  800425:	8b 40 30             	mov    0x30(%eax),%eax
  800428:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	68 bf 15 80 00       	push   $0x8015bf
  800435:	68 cd 15 80 00       	push   $0x8015cd
  80043a:	b9 60 20 80 00       	mov    $0x802060,%ecx
  80043f:	ba b8 15 80 00       	mov    $0x8015b8,%edx
  800444:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  800449:	e8 e5 fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  80044e:	83 c4 0c             	add    $0xc,%esp
  800451:	6a 07                	push   $0x7
  800453:	68 00 00 40 00       	push   $0x400000
  800458:	6a 00                	push   $0x0
  80045a:	e8 02 0c 00 00       	call   801061 <sys_page_alloc>
  80045f:	83 c4 10             	add    $0x10,%esp
  800462:	85 c0                	test   %eax,%eax
  800464:	79 12                	jns    800478 <pgfault+0xd8>
		panic("sys_page_alloc: %e", r);
  800466:	50                   	push   %eax
  800467:	68 d4 15 80 00       	push   $0x8015d4
  80046c:	6a 5c                	push   $0x5c
  80046e:	68 a7 15 80 00       	push   $0x8015a7
  800473:	e8 71 01 00 00       	call   8005e9 <_panic>
}
  800478:	c9                   	leave  
  800479:	c3                   	ret    

0080047a <umain>:

void
umain(int argc, char **argv)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  800480:	68 a0 03 80 00       	push   $0x8003a0
  800485:	e8 86 0d 00 00       	call   801210 <set_pgfault_handler>

	__asm __volatile(
  80048a:	50                   	push   %eax
  80048b:	9c                   	pushf  
  80048c:	58                   	pop    %eax
  80048d:	0d d5 08 00 00       	or     $0x8d5,%eax
  800492:	50                   	push   %eax
  800493:	9d                   	popf   
  800494:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  800499:	8d 05 d4 04 80 00    	lea    0x8004d4,%eax
  80049f:	a3 c0 20 80 00       	mov    %eax,0x8020c0
  8004a4:	58                   	pop    %eax
  8004a5:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  8004ab:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  8004b1:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  8004b7:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  8004bd:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  8004c3:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  8004c9:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  8004ce:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  8004d4:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004db:	00 00 00 
  8004de:	89 3d 20 20 80 00    	mov    %edi,0x802020
  8004e4:	89 35 24 20 80 00    	mov    %esi,0x802024
  8004ea:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  8004f0:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  8004f6:	89 15 34 20 80 00    	mov    %edx,0x802034
  8004fc:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  800502:	a3 3c 20 80 00       	mov    %eax,0x80203c
  800507:	89 25 48 20 80 00    	mov    %esp,0x802048
  80050d:	8b 3d a0 20 80 00    	mov    0x8020a0,%edi
  800513:	8b 35 a4 20 80 00    	mov    0x8020a4,%esi
  800519:	8b 2d a8 20 80 00    	mov    0x8020a8,%ebp
  80051f:	8b 1d b0 20 80 00    	mov    0x8020b0,%ebx
  800525:	8b 15 b4 20 80 00    	mov    0x8020b4,%edx
  80052b:	8b 0d b8 20 80 00    	mov    0x8020b8,%ecx
  800531:	a1 bc 20 80 00       	mov    0x8020bc,%eax
  800536:	8b 25 c8 20 80 00    	mov    0x8020c8,%esp
  80053c:	50                   	push   %eax
  80053d:	9c                   	pushf  
  80053e:	58                   	pop    %eax
  80053f:	a3 44 20 80 00       	mov    %eax,0x802044
  800544:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  80054f:	74 10                	je     800561 <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  800551:	83 ec 0c             	sub    $0xc,%esp
  800554:	68 34 16 80 00       	push   $0x801634
  800559:	e8 64 01 00 00       	call   8006c2 <cprintf>
  80055e:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800561:	a1 c0 20 80 00       	mov    0x8020c0,%eax
  800566:	a3 40 20 80 00       	mov    %eax,0x802040

	check_regs(&before, "before", &after, "after", "after page-fault");
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	68 e7 15 80 00       	push   $0x8015e7
  800573:	68 f8 15 80 00       	push   $0x8015f8
  800578:	b9 20 20 80 00       	mov    $0x802020,%ecx
  80057d:	ba b8 15 80 00       	mov    $0x8015b8,%edx
  800582:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  800587:	e8 a7 fa ff ff       	call   800033 <check_regs>
}
  80058c:	83 c4 10             	add    $0x10,%esp
  80058f:	c9                   	leave  
  800590:	c3                   	ret    

00800591 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800591:	55                   	push   %ebp
  800592:	89 e5                	mov    %esp,%ebp
  800594:	56                   	push   %esi
  800595:	53                   	push   %ebx
  800596:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800599:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80059c:	e8 82 0a 00 00       	call   801023 <sys_getenvid>
  8005a1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005a6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005a9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005ae:	a3 cc 20 80 00       	mov    %eax,0x8020cc

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005b3:	85 db                	test   %ebx,%ebx
  8005b5:	7e 07                	jle    8005be <libmain+0x2d>
		binaryname = argv[0];
  8005b7:	8b 06                	mov    (%esi),%eax
  8005b9:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	56                   	push   %esi
  8005c2:	53                   	push   %ebx
  8005c3:	e8 b2 fe ff ff       	call   80047a <umain>

	// exit gracefully
	exit();
  8005c8:	e8 0a 00 00 00       	call   8005d7 <exit>
}
  8005cd:	83 c4 10             	add    $0x10,%esp
  8005d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005d3:	5b                   	pop    %ebx
  8005d4:	5e                   	pop    %esi
  8005d5:	5d                   	pop    %ebp
  8005d6:	c3                   	ret    

008005d7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005d7:	55                   	push   %ebp
  8005d8:	89 e5                	mov    %esp,%ebp
  8005da:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8005dd:	6a 00                	push   $0x0
  8005df:	e8 fe 09 00 00       	call   800fe2 <sys_env_destroy>
}
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	c9                   	leave  
  8005e8:	c3                   	ret    

008005e9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005e9:	55                   	push   %ebp
  8005ea:	89 e5                	mov    %esp,%ebp
  8005ec:	56                   	push   %esi
  8005ed:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8005ee:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005f1:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8005f7:	e8 27 0a 00 00       	call   801023 <sys_getenvid>
  8005fc:	83 ec 0c             	sub    $0xc,%esp
  8005ff:	ff 75 0c             	pushl  0xc(%ebp)
  800602:	ff 75 08             	pushl  0x8(%ebp)
  800605:	56                   	push   %esi
  800606:	50                   	push   %eax
  800607:	68 60 16 80 00       	push   $0x801660
  80060c:	e8 b1 00 00 00       	call   8006c2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800611:	83 c4 18             	add    $0x18,%esp
  800614:	53                   	push   %ebx
  800615:	ff 75 10             	pushl  0x10(%ebp)
  800618:	e8 54 00 00 00       	call   800671 <vcprintf>
	cprintf("\n");
  80061d:	c7 04 24 70 15 80 00 	movl   $0x801570,(%esp)
  800624:	e8 99 00 00 00       	call   8006c2 <cprintf>
  800629:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80062c:	cc                   	int3   
  80062d:	eb fd                	jmp    80062c <_panic+0x43>

0080062f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80062f:	55                   	push   %ebp
  800630:	89 e5                	mov    %esp,%ebp
  800632:	53                   	push   %ebx
  800633:	83 ec 04             	sub    $0x4,%esp
  800636:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800639:	8b 13                	mov    (%ebx),%edx
  80063b:	8d 42 01             	lea    0x1(%edx),%eax
  80063e:	89 03                	mov    %eax,(%ebx)
  800640:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800643:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800647:	3d ff 00 00 00       	cmp    $0xff,%eax
  80064c:	75 1a                	jne    800668 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	68 ff 00 00 00       	push   $0xff
  800656:	8d 43 08             	lea    0x8(%ebx),%eax
  800659:	50                   	push   %eax
  80065a:	e8 46 09 00 00       	call   800fa5 <sys_cputs>
		b->idx = 0;
  80065f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800665:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800668:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80066c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80066f:	c9                   	leave  
  800670:	c3                   	ret    

00800671 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800671:	55                   	push   %ebp
  800672:	89 e5                	mov    %esp,%ebp
  800674:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80067a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800681:	00 00 00 
	b.cnt = 0;
  800684:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80068b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80068e:	ff 75 0c             	pushl  0xc(%ebp)
  800691:	ff 75 08             	pushl  0x8(%ebp)
  800694:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80069a:	50                   	push   %eax
  80069b:	68 2f 06 80 00       	push   $0x80062f
  8006a0:	e8 54 01 00 00       	call   8007f9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006a5:	83 c4 08             	add    $0x8,%esp
  8006a8:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006ae:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006b4:	50                   	push   %eax
  8006b5:	e8 eb 08 00 00       	call   800fa5 <sys_cputs>

	return b.cnt;
}
  8006ba:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006c0:	c9                   	leave  
  8006c1:	c3                   	ret    

008006c2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006c2:	55                   	push   %ebp
  8006c3:	89 e5                	mov    %esp,%ebp
  8006c5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006c8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006cb:	50                   	push   %eax
  8006cc:	ff 75 08             	pushl  0x8(%ebp)
  8006cf:	e8 9d ff ff ff       	call   800671 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006d4:	c9                   	leave  
  8006d5:	c3                   	ret    

008006d6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006d6:	55                   	push   %ebp
  8006d7:	89 e5                	mov    %esp,%ebp
  8006d9:	57                   	push   %edi
  8006da:	56                   	push   %esi
  8006db:	53                   	push   %ebx
  8006dc:	83 ec 1c             	sub    $0x1c,%esp
  8006df:	89 c7                	mov    %eax,%edi
  8006e1:	89 d6                	mov    %edx,%esi
  8006e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ec:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8006f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006fa:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006fd:	39 d3                	cmp    %edx,%ebx
  8006ff:	72 05                	jb     800706 <printnum+0x30>
  800701:	39 45 10             	cmp    %eax,0x10(%ebp)
  800704:	77 45                	ja     80074b <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800706:	83 ec 0c             	sub    $0xc,%esp
  800709:	ff 75 18             	pushl  0x18(%ebp)
  80070c:	8b 45 14             	mov    0x14(%ebp),%eax
  80070f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800712:	53                   	push   %ebx
  800713:	ff 75 10             	pushl  0x10(%ebp)
  800716:	83 ec 08             	sub    $0x8,%esp
  800719:	ff 75 e4             	pushl  -0x1c(%ebp)
  80071c:	ff 75 e0             	pushl  -0x20(%ebp)
  80071f:	ff 75 dc             	pushl  -0x24(%ebp)
  800722:	ff 75 d8             	pushl  -0x28(%ebp)
  800725:	e8 76 0b 00 00       	call   8012a0 <__udivdi3>
  80072a:	83 c4 18             	add    $0x18,%esp
  80072d:	52                   	push   %edx
  80072e:	50                   	push   %eax
  80072f:	89 f2                	mov    %esi,%edx
  800731:	89 f8                	mov    %edi,%eax
  800733:	e8 9e ff ff ff       	call   8006d6 <printnum>
  800738:	83 c4 20             	add    $0x20,%esp
  80073b:	eb 18                	jmp    800755 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80073d:	83 ec 08             	sub    $0x8,%esp
  800740:	56                   	push   %esi
  800741:	ff 75 18             	pushl  0x18(%ebp)
  800744:	ff d7                	call   *%edi
  800746:	83 c4 10             	add    $0x10,%esp
  800749:	eb 03                	jmp    80074e <printnum+0x78>
  80074b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80074e:	83 eb 01             	sub    $0x1,%ebx
  800751:	85 db                	test   %ebx,%ebx
  800753:	7f e8                	jg     80073d <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800755:	83 ec 08             	sub    $0x8,%esp
  800758:	56                   	push   %esi
  800759:	83 ec 04             	sub    $0x4,%esp
  80075c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80075f:	ff 75 e0             	pushl  -0x20(%ebp)
  800762:	ff 75 dc             	pushl  -0x24(%ebp)
  800765:	ff 75 d8             	pushl  -0x28(%ebp)
  800768:	e8 63 0c 00 00       	call   8013d0 <__umoddi3>
  80076d:	83 c4 14             	add    $0x14,%esp
  800770:	0f be 80 83 16 80 00 	movsbl 0x801683(%eax),%eax
  800777:	50                   	push   %eax
  800778:	ff d7                	call   *%edi
}
  80077a:	83 c4 10             	add    $0x10,%esp
  80077d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800780:	5b                   	pop    %ebx
  800781:	5e                   	pop    %esi
  800782:	5f                   	pop    %edi
  800783:	5d                   	pop    %ebp
  800784:	c3                   	ret    

00800785 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800788:	83 fa 01             	cmp    $0x1,%edx
  80078b:	7e 0e                	jle    80079b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80078d:	8b 10                	mov    (%eax),%edx
  80078f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800792:	89 08                	mov    %ecx,(%eax)
  800794:	8b 02                	mov    (%edx),%eax
  800796:	8b 52 04             	mov    0x4(%edx),%edx
  800799:	eb 22                	jmp    8007bd <getuint+0x38>
	else if (lflag)
  80079b:	85 d2                	test   %edx,%edx
  80079d:	74 10                	je     8007af <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80079f:	8b 10                	mov    (%eax),%edx
  8007a1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007a4:	89 08                	mov    %ecx,(%eax)
  8007a6:	8b 02                	mov    (%edx),%eax
  8007a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ad:	eb 0e                	jmp    8007bd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007af:	8b 10                	mov    (%eax),%edx
  8007b1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007b4:	89 08                	mov    %ecx,(%eax)
  8007b6:	8b 02                	mov    (%edx),%eax
  8007b8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007bd:	5d                   	pop    %ebp
  8007be:	c3                   	ret    

008007bf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007c5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007c9:	8b 10                	mov    (%eax),%edx
  8007cb:	3b 50 04             	cmp    0x4(%eax),%edx
  8007ce:	73 0a                	jae    8007da <sprintputch+0x1b>
		*b->buf++ = ch;
  8007d0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007d3:	89 08                	mov    %ecx,(%eax)
  8007d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d8:	88 02                	mov    %al,(%edx)
}
  8007da:	5d                   	pop    %ebp
  8007db:	c3                   	ret    

008007dc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007e2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007e5:	50                   	push   %eax
  8007e6:	ff 75 10             	pushl  0x10(%ebp)
  8007e9:	ff 75 0c             	pushl  0xc(%ebp)
  8007ec:	ff 75 08             	pushl  0x8(%ebp)
  8007ef:	e8 05 00 00 00       	call   8007f9 <vprintfmt>
	va_end(ap);
}
  8007f4:	83 c4 10             	add    $0x10,%esp
  8007f7:	c9                   	leave  
  8007f8:	c3                   	ret    

008007f9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	57                   	push   %edi
  8007fd:	56                   	push   %esi
  8007fe:	53                   	push   %ebx
  8007ff:	83 ec 2c             	sub    $0x2c,%esp
  800802:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
  800805:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80080c:	eb 17                	jmp    800825 <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80080e:	85 c0                	test   %eax,%eax
  800810:	0f 84 9f 03 00 00    	je     800bb5 <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
  800816:	83 ec 08             	sub    $0x8,%esp
  800819:	ff 75 0c             	pushl  0xc(%ebp)
  80081c:	50                   	push   %eax
  80081d:	ff 55 08             	call   *0x8(%ebp)
  800820:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800823:	89 f3                	mov    %esi,%ebx
  800825:	8d 73 01             	lea    0x1(%ebx),%esi
  800828:	0f b6 03             	movzbl (%ebx),%eax
  80082b:	83 f8 25             	cmp    $0x25,%eax
  80082e:	75 de                	jne    80080e <vprintfmt+0x15>
  800830:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800834:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80083b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800840:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800847:	ba 00 00 00 00       	mov    $0x0,%edx
  80084c:	eb 06                	jmp    800854 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800850:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800854:	8d 5e 01             	lea    0x1(%esi),%ebx
  800857:	0f b6 06             	movzbl (%esi),%eax
  80085a:	0f b6 c8             	movzbl %al,%ecx
  80085d:	83 e8 23             	sub    $0x23,%eax
  800860:	3c 55                	cmp    $0x55,%al
  800862:	0f 87 2d 03 00 00    	ja     800b95 <vprintfmt+0x39c>
  800868:	0f b6 c0             	movzbl %al,%eax
  80086b:	ff 24 85 40 17 80 00 	jmp    *0x801740(,%eax,4)
  800872:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800874:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800878:	eb da                	jmp    800854 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087a:	89 de                	mov    %ebx,%esi
  80087c:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800881:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  800884:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  800888:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  80088b:	8d 41 d0             	lea    -0x30(%ecx),%eax
  80088e:	83 f8 09             	cmp    $0x9,%eax
  800891:	77 33                	ja     8008c6 <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800893:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800896:	eb e9                	jmp    800881 <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800898:	8b 45 14             	mov    0x14(%ebp),%eax
  80089b:	8d 48 04             	lea    0x4(%eax),%ecx
  80089e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008a1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a3:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008a5:	eb 1f                	jmp    8008c6 <vprintfmt+0xcd>
  8008a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008aa:	85 c0                	test   %eax,%eax
  8008ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008b1:	0f 49 c8             	cmovns %eax,%ecx
  8008b4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b7:	89 de                	mov    %ebx,%esi
  8008b9:	eb 99                	jmp    800854 <vprintfmt+0x5b>
  8008bb:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008bd:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  8008c4:	eb 8e                	jmp    800854 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8008c6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008ca:	79 88                	jns    800854 <vprintfmt+0x5b>
				width = precision, precision = -1;
  8008cc:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8008cf:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8008d4:	e9 7b ff ff ff       	jmp    800854 <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008d9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008dc:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8008de:	e9 71 ff ff ff       	jmp    800854 <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
  8008e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e6:	8d 50 04             	lea    0x4(%eax),%edx
  8008e9:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  8008ec:	83 ec 08             	sub    $0x8,%esp
  8008ef:	ff 75 0c             	pushl  0xc(%ebp)
  8008f2:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8008f5:	03 08                	add    (%eax),%ecx
  8008f7:	51                   	push   %ecx
  8008f8:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
  8008fb:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
  8008fe:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
  800905:	e9 1b ff ff ff       	jmp    800825 <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
  80090a:	8b 45 14             	mov    0x14(%ebp),%eax
  80090d:	8d 48 04             	lea    0x4(%eax),%ecx
  800910:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800913:	8b 00                	mov    (%eax),%eax
  800915:	83 f8 02             	cmp    $0x2,%eax
  800918:	74 1a                	je     800934 <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091a:	89 de                	mov    %ebx,%esi
  80091c:	83 f8 04             	cmp    $0x4,%eax
  80091f:	b8 00 00 00 00       	mov    $0x0,%eax
  800924:	b9 00 04 00 00       	mov    $0x400,%ecx
  800929:	0f 44 c1             	cmove  %ecx,%eax
  80092c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80092f:	e9 20 ff ff ff       	jmp    800854 <vprintfmt+0x5b>
  800934:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
  800936:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
  80093d:	e9 12 ff ff ff       	jmp    800854 <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800942:	8b 45 14             	mov    0x14(%ebp),%eax
  800945:	8d 50 04             	lea    0x4(%eax),%edx
  800948:	89 55 14             	mov    %edx,0x14(%ebp)
  80094b:	8b 00                	mov    (%eax),%eax
  80094d:	99                   	cltd   
  80094e:	31 d0                	xor    %edx,%eax
  800950:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800952:	83 f8 09             	cmp    $0x9,%eax
  800955:	7f 0b                	jg     800962 <vprintfmt+0x169>
  800957:	8b 14 85 a0 18 80 00 	mov    0x8018a0(,%eax,4),%edx
  80095e:	85 d2                	test   %edx,%edx
  800960:	75 19                	jne    80097b <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800962:	50                   	push   %eax
  800963:	68 9b 16 80 00       	push   $0x80169b
  800968:	ff 75 0c             	pushl  0xc(%ebp)
  80096b:	ff 75 08             	pushl  0x8(%ebp)
  80096e:	e8 69 fe ff ff       	call   8007dc <printfmt>
  800973:	83 c4 10             	add    $0x10,%esp
  800976:	e9 aa fe ff ff       	jmp    800825 <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  80097b:	52                   	push   %edx
  80097c:	68 a4 16 80 00       	push   $0x8016a4
  800981:	ff 75 0c             	pushl  0xc(%ebp)
  800984:	ff 75 08             	pushl  0x8(%ebp)
  800987:	e8 50 fe ff ff       	call   8007dc <printfmt>
  80098c:	83 c4 10             	add    $0x10,%esp
  80098f:	e9 91 fe ff ff       	jmp    800825 <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800994:	8b 45 14             	mov    0x14(%ebp),%eax
  800997:	8d 50 04             	lea    0x4(%eax),%edx
  80099a:	89 55 14             	mov    %edx,0x14(%ebp)
  80099d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80099f:	85 f6                	test   %esi,%esi
  8009a1:	b8 94 16 80 00       	mov    $0x801694,%eax
  8009a6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8009a9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009ad:	0f 8e 93 00 00 00    	jle    800a46 <vprintfmt+0x24d>
  8009b3:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8009b7:	0f 84 91 00 00 00    	je     800a4e <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009bd:	83 ec 08             	sub    $0x8,%esp
  8009c0:	57                   	push   %edi
  8009c1:	56                   	push   %esi
  8009c2:	e8 76 02 00 00       	call   800c3d <strnlen>
  8009c7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009ca:	29 c1                	sub    %eax,%ecx
  8009cc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8009cf:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8009d2:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8009d6:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8009d9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8009dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009df:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009e2:	89 cb                	mov    %ecx,%ebx
  8009e4:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009e6:	eb 0e                	jmp    8009f6 <vprintfmt+0x1fd>
					putch(padc, putdat);
  8009e8:	83 ec 08             	sub    $0x8,%esp
  8009eb:	56                   	push   %esi
  8009ec:	57                   	push   %edi
  8009ed:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009f0:	83 eb 01             	sub    $0x1,%ebx
  8009f3:	83 c4 10             	add    $0x10,%esp
  8009f6:	85 db                	test   %ebx,%ebx
  8009f8:	7f ee                	jg     8009e8 <vprintfmt+0x1ef>
  8009fa:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8009fd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a00:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a03:	85 c9                	test   %ecx,%ecx
  800a05:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0a:	0f 49 c1             	cmovns %ecx,%eax
  800a0d:	29 c1                	sub    %eax,%ecx
  800a0f:	89 cb                	mov    %ecx,%ebx
  800a11:	eb 41                	jmp    800a54 <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a13:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a17:	74 1b                	je     800a34 <vprintfmt+0x23b>
  800a19:	0f be c0             	movsbl %al,%eax
  800a1c:	83 e8 20             	sub    $0x20,%eax
  800a1f:	83 f8 5e             	cmp    $0x5e,%eax
  800a22:	76 10                	jbe    800a34 <vprintfmt+0x23b>
					putch('?', putdat);
  800a24:	83 ec 08             	sub    $0x8,%esp
  800a27:	ff 75 0c             	pushl  0xc(%ebp)
  800a2a:	6a 3f                	push   $0x3f
  800a2c:	ff 55 08             	call   *0x8(%ebp)
  800a2f:	83 c4 10             	add    $0x10,%esp
  800a32:	eb 0d                	jmp    800a41 <vprintfmt+0x248>
				else
					putch(ch, putdat);
  800a34:	83 ec 08             	sub    $0x8,%esp
  800a37:	ff 75 0c             	pushl  0xc(%ebp)
  800a3a:	52                   	push   %edx
  800a3b:	ff 55 08             	call   *0x8(%ebp)
  800a3e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a41:	83 eb 01             	sub    $0x1,%ebx
  800a44:	eb 0e                	jmp    800a54 <vprintfmt+0x25b>
  800a46:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a49:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a4c:	eb 06                	jmp    800a54 <vprintfmt+0x25b>
  800a4e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a51:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a54:	83 c6 01             	add    $0x1,%esi
  800a57:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800a5b:	0f be d0             	movsbl %al,%edx
  800a5e:	85 d2                	test   %edx,%edx
  800a60:	74 25                	je     800a87 <vprintfmt+0x28e>
  800a62:	85 ff                	test   %edi,%edi
  800a64:	78 ad                	js     800a13 <vprintfmt+0x21a>
  800a66:	83 ef 01             	sub    $0x1,%edi
  800a69:	79 a8                	jns    800a13 <vprintfmt+0x21a>
  800a6b:	89 d8                	mov    %ebx,%eax
  800a6d:	8b 75 08             	mov    0x8(%ebp),%esi
  800a70:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a73:	89 c3                	mov    %eax,%ebx
  800a75:	eb 16                	jmp    800a8d <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a77:	83 ec 08             	sub    $0x8,%esp
  800a7a:	57                   	push   %edi
  800a7b:	6a 20                	push   $0x20
  800a7d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a7f:	83 eb 01             	sub    $0x1,%ebx
  800a82:	83 c4 10             	add    $0x10,%esp
  800a85:	eb 06                	jmp    800a8d <vprintfmt+0x294>
  800a87:	8b 75 08             	mov    0x8(%ebp),%esi
  800a8a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a8d:	85 db                	test   %ebx,%ebx
  800a8f:	7f e6                	jg     800a77 <vprintfmt+0x27e>
  800a91:	89 75 08             	mov    %esi,0x8(%ebp)
  800a94:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800a97:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a9a:	e9 86 fd ff ff       	jmp    800825 <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a9f:	83 fa 01             	cmp    $0x1,%edx
  800aa2:	7e 10                	jle    800ab4 <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
  800aa4:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa7:	8d 50 08             	lea    0x8(%eax),%edx
  800aaa:	89 55 14             	mov    %edx,0x14(%ebp)
  800aad:	8b 30                	mov    (%eax),%esi
  800aaf:	8b 78 04             	mov    0x4(%eax),%edi
  800ab2:	eb 26                	jmp    800ada <vprintfmt+0x2e1>
	else if (lflag)
  800ab4:	85 d2                	test   %edx,%edx
  800ab6:	74 12                	je     800aca <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  800ab8:	8b 45 14             	mov    0x14(%ebp),%eax
  800abb:	8d 50 04             	lea    0x4(%eax),%edx
  800abe:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac1:	8b 30                	mov    (%eax),%esi
  800ac3:	89 f7                	mov    %esi,%edi
  800ac5:	c1 ff 1f             	sar    $0x1f,%edi
  800ac8:	eb 10                	jmp    800ada <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
  800aca:	8b 45 14             	mov    0x14(%ebp),%eax
  800acd:	8d 50 04             	lea    0x4(%eax),%edx
  800ad0:	89 55 14             	mov    %edx,0x14(%ebp)
  800ad3:	8b 30                	mov    (%eax),%esi
  800ad5:	89 f7                	mov    %esi,%edi
  800ad7:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ada:	89 f0                	mov    %esi,%eax
  800adc:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ade:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ae3:	85 ff                	test   %edi,%edi
  800ae5:	79 7b                	jns    800b62 <vprintfmt+0x369>
				putch('-', putdat);
  800ae7:	83 ec 08             	sub    $0x8,%esp
  800aea:	ff 75 0c             	pushl  0xc(%ebp)
  800aed:	6a 2d                	push   $0x2d
  800aef:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800af2:	89 f0                	mov    %esi,%eax
  800af4:	89 fa                	mov    %edi,%edx
  800af6:	f7 d8                	neg    %eax
  800af8:	83 d2 00             	adc    $0x0,%edx
  800afb:	f7 da                	neg    %edx
  800afd:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b00:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b05:	eb 5b                	jmp    800b62 <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b07:	8d 45 14             	lea    0x14(%ebp),%eax
  800b0a:	e8 76 fc ff ff       	call   800785 <getuint>
			base = 10;
  800b0f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b14:	eb 4c                	jmp    800b62 <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
  800b16:	8d 45 14             	lea    0x14(%ebp),%eax
  800b19:	e8 67 fc ff ff       	call   800785 <getuint>
            base = 8;
  800b1e:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800b23:	eb 3d                	jmp    800b62 <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
  800b25:	83 ec 08             	sub    $0x8,%esp
  800b28:	ff 75 0c             	pushl  0xc(%ebp)
  800b2b:	6a 30                	push   $0x30
  800b2d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b30:	83 c4 08             	add    $0x8,%esp
  800b33:	ff 75 0c             	pushl  0xc(%ebp)
  800b36:	6a 78                	push   $0x78
  800b38:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b3b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3e:	8d 50 04             	lea    0x4(%eax),%edx
  800b41:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b44:	8b 00                	mov    (%eax),%eax
  800b46:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b4b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b4e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b53:	eb 0d                	jmp    800b62 <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b55:	8d 45 14             	lea    0x14(%ebp),%eax
  800b58:	e8 28 fc ff ff       	call   800785 <getuint>
			base = 16;
  800b5d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b62:	83 ec 0c             	sub    $0xc,%esp
  800b65:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  800b69:	56                   	push   %esi
  800b6a:	ff 75 e0             	pushl  -0x20(%ebp)
  800b6d:	51                   	push   %ecx
  800b6e:	52                   	push   %edx
  800b6f:	50                   	push   %eax
  800b70:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b73:	8b 45 08             	mov    0x8(%ebp),%eax
  800b76:	e8 5b fb ff ff       	call   8006d6 <printnum>
			break;
  800b7b:	83 c4 20             	add    $0x20,%esp
  800b7e:	e9 a2 fc ff ff       	jmp    800825 <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b83:	83 ec 08             	sub    $0x8,%esp
  800b86:	ff 75 0c             	pushl  0xc(%ebp)
  800b89:	51                   	push   %ecx
  800b8a:	ff 55 08             	call   *0x8(%ebp)
			break;
  800b8d:	83 c4 10             	add    $0x10,%esp
  800b90:	e9 90 fc ff ff       	jmp    800825 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b95:	83 ec 08             	sub    $0x8,%esp
  800b98:	ff 75 0c             	pushl  0xc(%ebp)
  800b9b:	6a 25                	push   $0x25
  800b9d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ba0:	83 c4 10             	add    $0x10,%esp
  800ba3:	89 f3                	mov    %esi,%ebx
  800ba5:	eb 03                	jmp    800baa <vprintfmt+0x3b1>
  800ba7:	83 eb 01             	sub    $0x1,%ebx
  800baa:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800bae:	75 f7                	jne    800ba7 <vprintfmt+0x3ae>
  800bb0:	e9 70 fc ff ff       	jmp    800825 <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  800bb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	83 ec 18             	sub    $0x18,%esp
  800bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bc9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bcc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bd0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bd3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bda:	85 c0                	test   %eax,%eax
  800bdc:	74 26                	je     800c04 <vsnprintf+0x47>
  800bde:	85 d2                	test   %edx,%edx
  800be0:	7e 22                	jle    800c04 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800be2:	ff 75 14             	pushl  0x14(%ebp)
  800be5:	ff 75 10             	pushl  0x10(%ebp)
  800be8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800beb:	50                   	push   %eax
  800bec:	68 bf 07 80 00       	push   $0x8007bf
  800bf1:	e8 03 fc ff ff       	call   8007f9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bf6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bf9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bff:	83 c4 10             	add    $0x10,%esp
  800c02:	eb 05                	jmp    800c09 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c04:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c09:	c9                   	leave  
  800c0a:	c3                   	ret    

00800c0b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c11:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c14:	50                   	push   %eax
  800c15:	ff 75 10             	pushl  0x10(%ebp)
  800c18:	ff 75 0c             	pushl  0xc(%ebp)
  800c1b:	ff 75 08             	pushl  0x8(%ebp)
  800c1e:	e8 9a ff ff ff       	call   800bbd <vsnprintf>
	va_end(ap);

	return rc;
}
  800c23:	c9                   	leave  
  800c24:	c3                   	ret    

00800c25 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c30:	eb 03                	jmp    800c35 <strlen+0x10>
		n++;
  800c32:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c35:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c39:	75 f7                	jne    800c32 <strlen+0xd>
		n++;
	return n;
}
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c43:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c46:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4b:	eb 03                	jmp    800c50 <strnlen+0x13>
		n++;
  800c4d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c50:	39 c2                	cmp    %eax,%edx
  800c52:	74 08                	je     800c5c <strnlen+0x1f>
  800c54:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800c58:	75 f3                	jne    800c4d <strnlen+0x10>
  800c5a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	53                   	push   %ebx
  800c62:	8b 45 08             	mov    0x8(%ebp),%eax
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c68:	89 c2                	mov    %eax,%edx
  800c6a:	83 c2 01             	add    $0x1,%edx
  800c6d:	83 c1 01             	add    $0x1,%ecx
  800c70:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800c74:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c77:	84 db                	test   %bl,%bl
  800c79:	75 ef                	jne    800c6a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800c7b:	5b                   	pop    %ebx
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    

00800c7e <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	53                   	push   %ebx
  800c82:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c85:	53                   	push   %ebx
  800c86:	e8 9a ff ff ff       	call   800c25 <strlen>
  800c8b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800c8e:	ff 75 0c             	pushl  0xc(%ebp)
  800c91:	01 d8                	add    %ebx,%eax
  800c93:	50                   	push   %eax
  800c94:	e8 c5 ff ff ff       	call   800c5e <strcpy>
	return dst;
}
  800c99:	89 d8                	mov    %ebx,%eax
  800c9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c9e:	c9                   	leave  
  800c9f:	c3                   	ret    

00800ca0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	56                   	push   %esi
  800ca4:	53                   	push   %ebx
  800ca5:	8b 75 08             	mov    0x8(%ebp),%esi
  800ca8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cab:	89 f3                	mov    %esi,%ebx
  800cad:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cb0:	89 f2                	mov    %esi,%edx
  800cb2:	eb 0f                	jmp    800cc3 <strncpy+0x23>
		*dst++ = *src;
  800cb4:	83 c2 01             	add    $0x1,%edx
  800cb7:	0f b6 01             	movzbl (%ecx),%eax
  800cba:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cbd:	80 39 01             	cmpb   $0x1,(%ecx)
  800cc0:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cc3:	39 da                	cmp    %ebx,%edx
  800cc5:	75 ed                	jne    800cb4 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cc7:	89 f0                	mov    %esi,%eax
  800cc9:	5b                   	pop    %ebx
  800cca:	5e                   	pop    %esi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    

00800ccd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	8b 75 08             	mov    0x8(%ebp),%esi
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd8:	8b 55 10             	mov    0x10(%ebp),%edx
  800cdb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cdd:	85 d2                	test   %edx,%edx
  800cdf:	74 21                	je     800d02 <strlcpy+0x35>
  800ce1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ce5:	89 f2                	mov    %esi,%edx
  800ce7:	eb 09                	jmp    800cf2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ce9:	83 c2 01             	add    $0x1,%edx
  800cec:	83 c1 01             	add    $0x1,%ecx
  800cef:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800cf2:	39 c2                	cmp    %eax,%edx
  800cf4:	74 09                	je     800cff <strlcpy+0x32>
  800cf6:	0f b6 19             	movzbl (%ecx),%ebx
  800cf9:	84 db                	test   %bl,%bl
  800cfb:	75 ec                	jne    800ce9 <strlcpy+0x1c>
  800cfd:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800cff:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d02:	29 f0                	sub    %esi,%eax
}
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d11:	eb 06                	jmp    800d19 <strcmp+0x11>
		p++, q++;
  800d13:	83 c1 01             	add    $0x1,%ecx
  800d16:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d19:	0f b6 01             	movzbl (%ecx),%eax
  800d1c:	84 c0                	test   %al,%al
  800d1e:	74 04                	je     800d24 <strcmp+0x1c>
  800d20:	3a 02                	cmp    (%edx),%al
  800d22:	74 ef                	je     800d13 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d24:	0f b6 c0             	movzbl %al,%eax
  800d27:	0f b6 12             	movzbl (%edx),%edx
  800d2a:	29 d0                	sub    %edx,%eax
}
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	53                   	push   %ebx
  800d32:	8b 45 08             	mov    0x8(%ebp),%eax
  800d35:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d38:	89 c3                	mov    %eax,%ebx
  800d3a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d3d:	eb 06                	jmp    800d45 <strncmp+0x17>
		n--, p++, q++;
  800d3f:	83 c0 01             	add    $0x1,%eax
  800d42:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d45:	39 d8                	cmp    %ebx,%eax
  800d47:	74 15                	je     800d5e <strncmp+0x30>
  800d49:	0f b6 08             	movzbl (%eax),%ecx
  800d4c:	84 c9                	test   %cl,%cl
  800d4e:	74 04                	je     800d54 <strncmp+0x26>
  800d50:	3a 0a                	cmp    (%edx),%cl
  800d52:	74 eb                	je     800d3f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d54:	0f b6 00             	movzbl (%eax),%eax
  800d57:	0f b6 12             	movzbl (%edx),%edx
  800d5a:	29 d0                	sub    %edx,%eax
  800d5c:	eb 05                	jmp    800d63 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d5e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d63:	5b                   	pop    %ebx
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d70:	eb 07                	jmp    800d79 <strchr+0x13>
		if (*s == c)
  800d72:	38 ca                	cmp    %cl,%dl
  800d74:	74 0f                	je     800d85 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d76:	83 c0 01             	add    $0x1,%eax
  800d79:	0f b6 10             	movzbl (%eax),%edx
  800d7c:	84 d2                	test   %dl,%dl
  800d7e:	75 f2                	jne    800d72 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800d80:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d91:	eb 03                	jmp    800d96 <strfind+0xf>
  800d93:	83 c0 01             	add    $0x1,%eax
  800d96:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800d99:	38 ca                	cmp    %cl,%dl
  800d9b:	74 04                	je     800da1 <strfind+0x1a>
  800d9d:	84 d2                	test   %dl,%dl
  800d9f:	75 f2                	jne    800d93 <strfind+0xc>
			break;
	return (char *) s;
}
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	57                   	push   %edi
  800da7:	56                   	push   %esi
  800da8:	53                   	push   %ebx
  800da9:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dac:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800daf:	85 c9                	test   %ecx,%ecx
  800db1:	74 36                	je     800de9 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800db3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800db9:	75 28                	jne    800de3 <memset+0x40>
  800dbb:	f6 c1 03             	test   $0x3,%cl
  800dbe:	75 23                	jne    800de3 <memset+0x40>
		c &= 0xFF;
  800dc0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800dc4:	89 d3                	mov    %edx,%ebx
  800dc6:	c1 e3 08             	shl    $0x8,%ebx
  800dc9:	89 d6                	mov    %edx,%esi
  800dcb:	c1 e6 18             	shl    $0x18,%esi
  800dce:	89 d0                	mov    %edx,%eax
  800dd0:	c1 e0 10             	shl    $0x10,%eax
  800dd3:	09 f0                	or     %esi,%eax
  800dd5:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800dd7:	89 d8                	mov    %ebx,%eax
  800dd9:	09 d0                	or     %edx,%eax
  800ddb:	c1 e9 02             	shr    $0x2,%ecx
  800dde:	fc                   	cld    
  800ddf:	f3 ab                	rep stos %eax,%es:(%edi)
  800de1:	eb 06                	jmp    800de9 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800de3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de6:	fc                   	cld    
  800de7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800de9:	89 f8                	mov    %edi,%eax
  800deb:	5b                   	pop    %ebx
  800dec:	5e                   	pop    %esi
  800ded:	5f                   	pop    %edi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	57                   	push   %edi
  800df4:	56                   	push   %esi
  800df5:	8b 45 08             	mov    0x8(%ebp),%eax
  800df8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dfb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800dfe:	39 c6                	cmp    %eax,%esi
  800e00:	73 35                	jae    800e37 <memmove+0x47>
  800e02:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e05:	39 d0                	cmp    %edx,%eax
  800e07:	73 2e                	jae    800e37 <memmove+0x47>
		s += n;
		d += n;
  800e09:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e0c:	89 d6                	mov    %edx,%esi
  800e0e:	09 fe                	or     %edi,%esi
  800e10:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e16:	75 13                	jne    800e2b <memmove+0x3b>
  800e18:	f6 c1 03             	test   $0x3,%cl
  800e1b:	75 0e                	jne    800e2b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800e1d:	83 ef 04             	sub    $0x4,%edi
  800e20:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e23:	c1 e9 02             	shr    $0x2,%ecx
  800e26:	fd                   	std    
  800e27:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e29:	eb 09                	jmp    800e34 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e2b:	83 ef 01             	sub    $0x1,%edi
  800e2e:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e31:	fd                   	std    
  800e32:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e34:	fc                   	cld    
  800e35:	eb 1d                	jmp    800e54 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e37:	89 f2                	mov    %esi,%edx
  800e39:	09 c2                	or     %eax,%edx
  800e3b:	f6 c2 03             	test   $0x3,%dl
  800e3e:	75 0f                	jne    800e4f <memmove+0x5f>
  800e40:	f6 c1 03             	test   $0x3,%cl
  800e43:	75 0a                	jne    800e4f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800e45:	c1 e9 02             	shr    $0x2,%ecx
  800e48:	89 c7                	mov    %eax,%edi
  800e4a:	fc                   	cld    
  800e4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e4d:	eb 05                	jmp    800e54 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e4f:	89 c7                	mov    %eax,%edi
  800e51:	fc                   	cld    
  800e52:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e54:	5e                   	pop    %esi
  800e55:	5f                   	pop    %edi
  800e56:	5d                   	pop    %ebp
  800e57:	c3                   	ret    

00800e58 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e5b:	ff 75 10             	pushl  0x10(%ebp)
  800e5e:	ff 75 0c             	pushl  0xc(%ebp)
  800e61:	ff 75 08             	pushl  0x8(%ebp)
  800e64:	e8 87 ff ff ff       	call   800df0 <memmove>
}
  800e69:	c9                   	leave  
  800e6a:	c3                   	ret    

00800e6b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	56                   	push   %esi
  800e6f:	53                   	push   %ebx
  800e70:	8b 45 08             	mov    0x8(%ebp),%eax
  800e73:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e76:	89 c6                	mov    %eax,%esi
  800e78:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e7b:	eb 1a                	jmp    800e97 <memcmp+0x2c>
		if (*s1 != *s2)
  800e7d:	0f b6 08             	movzbl (%eax),%ecx
  800e80:	0f b6 1a             	movzbl (%edx),%ebx
  800e83:	38 d9                	cmp    %bl,%cl
  800e85:	74 0a                	je     800e91 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800e87:	0f b6 c1             	movzbl %cl,%eax
  800e8a:	0f b6 db             	movzbl %bl,%ebx
  800e8d:	29 d8                	sub    %ebx,%eax
  800e8f:	eb 0f                	jmp    800ea0 <memcmp+0x35>
		s1++, s2++;
  800e91:	83 c0 01             	add    $0x1,%eax
  800e94:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e97:	39 f0                	cmp    %esi,%eax
  800e99:	75 e2                	jne    800e7d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ea0:	5b                   	pop    %ebx
  800ea1:	5e                   	pop    %esi
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	53                   	push   %ebx
  800ea8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800eab:	89 c1                	mov    %eax,%ecx
  800ead:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800eb0:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800eb4:	eb 0a                	jmp    800ec0 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800eb6:	0f b6 10             	movzbl (%eax),%edx
  800eb9:	39 da                	cmp    %ebx,%edx
  800ebb:	74 07                	je     800ec4 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ebd:	83 c0 01             	add    $0x1,%eax
  800ec0:	39 c8                	cmp    %ecx,%eax
  800ec2:	72 f2                	jb     800eb6 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ec4:	5b                   	pop    %ebx
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	57                   	push   %edi
  800ecb:	56                   	push   %esi
  800ecc:	53                   	push   %ebx
  800ecd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ed3:	eb 03                	jmp    800ed8 <strtol+0x11>
		s++;
  800ed5:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ed8:	0f b6 01             	movzbl (%ecx),%eax
  800edb:	3c 20                	cmp    $0x20,%al
  800edd:	74 f6                	je     800ed5 <strtol+0xe>
  800edf:	3c 09                	cmp    $0x9,%al
  800ee1:	74 f2                	je     800ed5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ee3:	3c 2b                	cmp    $0x2b,%al
  800ee5:	75 0a                	jne    800ef1 <strtol+0x2a>
		s++;
  800ee7:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800eea:	bf 00 00 00 00       	mov    $0x0,%edi
  800eef:	eb 11                	jmp    800f02 <strtol+0x3b>
  800ef1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ef6:	3c 2d                	cmp    $0x2d,%al
  800ef8:	75 08                	jne    800f02 <strtol+0x3b>
		s++, neg = 1;
  800efa:	83 c1 01             	add    $0x1,%ecx
  800efd:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f02:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f08:	75 15                	jne    800f1f <strtol+0x58>
  800f0a:	80 39 30             	cmpb   $0x30,(%ecx)
  800f0d:	75 10                	jne    800f1f <strtol+0x58>
  800f0f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f13:	75 7c                	jne    800f91 <strtol+0xca>
		s += 2, base = 16;
  800f15:	83 c1 02             	add    $0x2,%ecx
  800f18:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f1d:	eb 16                	jmp    800f35 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800f1f:	85 db                	test   %ebx,%ebx
  800f21:	75 12                	jne    800f35 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f23:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f28:	80 39 30             	cmpb   $0x30,(%ecx)
  800f2b:	75 08                	jne    800f35 <strtol+0x6e>
		s++, base = 8;
  800f2d:	83 c1 01             	add    $0x1,%ecx
  800f30:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800f35:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f3d:	0f b6 11             	movzbl (%ecx),%edx
  800f40:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f43:	89 f3                	mov    %esi,%ebx
  800f45:	80 fb 09             	cmp    $0x9,%bl
  800f48:	77 08                	ja     800f52 <strtol+0x8b>
			dig = *s - '0';
  800f4a:	0f be d2             	movsbl %dl,%edx
  800f4d:	83 ea 30             	sub    $0x30,%edx
  800f50:	eb 22                	jmp    800f74 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800f52:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f55:	89 f3                	mov    %esi,%ebx
  800f57:	80 fb 19             	cmp    $0x19,%bl
  800f5a:	77 08                	ja     800f64 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800f5c:	0f be d2             	movsbl %dl,%edx
  800f5f:	83 ea 57             	sub    $0x57,%edx
  800f62:	eb 10                	jmp    800f74 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800f64:	8d 72 bf             	lea    -0x41(%edx),%esi
  800f67:	89 f3                	mov    %esi,%ebx
  800f69:	80 fb 19             	cmp    $0x19,%bl
  800f6c:	77 16                	ja     800f84 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800f6e:	0f be d2             	movsbl %dl,%edx
  800f71:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800f74:	3b 55 10             	cmp    0x10(%ebp),%edx
  800f77:	7d 0b                	jge    800f84 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800f79:	83 c1 01             	add    $0x1,%ecx
  800f7c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f80:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800f82:	eb b9                	jmp    800f3d <strtol+0x76>

	if (endptr)
  800f84:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f88:	74 0d                	je     800f97 <strtol+0xd0>
		*endptr = (char *) s;
  800f8a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f8d:	89 0e                	mov    %ecx,(%esi)
  800f8f:	eb 06                	jmp    800f97 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f91:	85 db                	test   %ebx,%ebx
  800f93:	74 98                	je     800f2d <strtol+0x66>
  800f95:	eb 9e                	jmp    800f35 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800f97:	89 c2                	mov    %eax,%edx
  800f99:	f7 da                	neg    %edx
  800f9b:	85 ff                	test   %edi,%edi
  800f9d:	0f 45 c2             	cmovne %edx,%eax
}
  800fa0:	5b                   	pop    %ebx
  800fa1:	5e                   	pop    %esi
  800fa2:	5f                   	pop    %edi
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    

00800fa5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
  800fa8:	57                   	push   %edi
  800fa9:	56                   	push   %esi
  800faa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fab:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb6:	89 c3                	mov    %eax,%ebx
  800fb8:	89 c7                	mov    %eax,%edi
  800fba:	89 c6                	mov    %eax,%esi
  800fbc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fbe:	5b                   	pop    %ebx
  800fbf:	5e                   	pop    %esi
  800fc0:	5f                   	pop    %edi
  800fc1:	5d                   	pop    %ebp
  800fc2:	c3                   	ret    

00800fc3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800fc3:	55                   	push   %ebp
  800fc4:	89 e5                	mov    %esp,%ebp
  800fc6:	57                   	push   %edi
  800fc7:	56                   	push   %esi
  800fc8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800fce:	b8 01 00 00 00       	mov    $0x1,%eax
  800fd3:	89 d1                	mov    %edx,%ecx
  800fd5:	89 d3                	mov    %edx,%ebx
  800fd7:	89 d7                	mov    %edx,%edi
  800fd9:	89 d6                	mov    %edx,%esi
  800fdb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fdd:	5b                   	pop    %ebx
  800fde:	5e                   	pop    %esi
  800fdf:	5f                   	pop    %edi
  800fe0:	5d                   	pop    %ebp
  800fe1:	c3                   	ret    

00800fe2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	57                   	push   %edi
  800fe6:	56                   	push   %esi
  800fe7:	53                   	push   %ebx
  800fe8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800feb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ff0:	b8 03 00 00 00       	mov    $0x3,%eax
  800ff5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff8:	89 cb                	mov    %ecx,%ebx
  800ffa:	89 cf                	mov    %ecx,%edi
  800ffc:	89 ce                	mov    %ecx,%esi
  800ffe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801000:	85 c0                	test   %eax,%eax
  801002:	7e 17                	jle    80101b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801004:	83 ec 0c             	sub    $0xc,%esp
  801007:	50                   	push   %eax
  801008:	6a 03                	push   $0x3
  80100a:	68 c8 18 80 00       	push   $0x8018c8
  80100f:	6a 23                	push   $0x23
  801011:	68 e5 18 80 00       	push   $0x8018e5
  801016:	e8 ce f5 ff ff       	call   8005e9 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80101b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80101e:	5b                   	pop    %ebx
  80101f:	5e                   	pop    %esi
  801020:	5f                   	pop    %edi
  801021:	5d                   	pop    %ebp
  801022:	c3                   	ret    

00801023 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801023:	55                   	push   %ebp
  801024:	89 e5                	mov    %esp,%ebp
  801026:	57                   	push   %edi
  801027:	56                   	push   %esi
  801028:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801029:	ba 00 00 00 00       	mov    $0x0,%edx
  80102e:	b8 02 00 00 00       	mov    $0x2,%eax
  801033:	89 d1                	mov    %edx,%ecx
  801035:	89 d3                	mov    %edx,%ebx
  801037:	89 d7                	mov    %edx,%edi
  801039:	89 d6                	mov    %edx,%esi
  80103b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80103d:	5b                   	pop    %ebx
  80103e:	5e                   	pop    %esi
  80103f:	5f                   	pop    %edi
  801040:	5d                   	pop    %ebp
  801041:	c3                   	ret    

00801042 <sys_yield>:

void
sys_yield(void)
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	57                   	push   %edi
  801046:	56                   	push   %esi
  801047:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801048:	ba 00 00 00 00       	mov    $0x0,%edx
  80104d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801052:	89 d1                	mov    %edx,%ecx
  801054:	89 d3                	mov    %edx,%ebx
  801056:	89 d7                	mov    %edx,%edi
  801058:	89 d6                	mov    %edx,%esi
  80105a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80105c:	5b                   	pop    %ebx
  80105d:	5e                   	pop    %esi
  80105e:	5f                   	pop    %edi
  80105f:	5d                   	pop    %ebp
  801060:	c3                   	ret    

00801061 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	57                   	push   %edi
  801065:	56                   	push   %esi
  801066:	53                   	push   %ebx
  801067:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80106a:	be 00 00 00 00       	mov    $0x0,%esi
  80106f:	b8 04 00 00 00       	mov    $0x4,%eax
  801074:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801077:	8b 55 08             	mov    0x8(%ebp),%edx
  80107a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80107d:	89 f7                	mov    %esi,%edi
  80107f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801081:	85 c0                	test   %eax,%eax
  801083:	7e 17                	jle    80109c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801085:	83 ec 0c             	sub    $0xc,%esp
  801088:	50                   	push   %eax
  801089:	6a 04                	push   $0x4
  80108b:	68 c8 18 80 00       	push   $0x8018c8
  801090:	6a 23                	push   $0x23
  801092:	68 e5 18 80 00       	push   $0x8018e5
  801097:	e8 4d f5 ff ff       	call   8005e9 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80109c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80109f:	5b                   	pop    %ebx
  8010a0:	5e                   	pop    %esi
  8010a1:	5f                   	pop    %edi
  8010a2:	5d                   	pop    %ebp
  8010a3:	c3                   	ret    

008010a4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010a4:	55                   	push   %ebp
  8010a5:	89 e5                	mov    %esp,%ebp
  8010a7:	57                   	push   %edi
  8010a8:	56                   	push   %esi
  8010a9:	53                   	push   %ebx
  8010aa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ad:	b8 05 00 00 00       	mov    $0x5,%eax
  8010b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010bb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010be:	8b 75 18             	mov    0x18(%ebp),%esi
  8010c1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	7e 17                	jle    8010de <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c7:	83 ec 0c             	sub    $0xc,%esp
  8010ca:	50                   	push   %eax
  8010cb:	6a 05                	push   $0x5
  8010cd:	68 c8 18 80 00       	push   $0x8018c8
  8010d2:	6a 23                	push   $0x23
  8010d4:	68 e5 18 80 00       	push   $0x8018e5
  8010d9:	e8 0b f5 ff ff       	call   8005e9 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e1:	5b                   	pop    %ebx
  8010e2:	5e                   	pop    %esi
  8010e3:	5f                   	pop    %edi
  8010e4:	5d                   	pop    %ebp
  8010e5:	c3                   	ret    

008010e6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	57                   	push   %edi
  8010ea:	56                   	push   %esi
  8010eb:	53                   	push   %ebx
  8010ec:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f4:	b8 06 00 00 00       	mov    $0x6,%eax
  8010f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ff:	89 df                	mov    %ebx,%edi
  801101:	89 de                	mov    %ebx,%esi
  801103:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801105:	85 c0                	test   %eax,%eax
  801107:	7e 17                	jle    801120 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801109:	83 ec 0c             	sub    $0xc,%esp
  80110c:	50                   	push   %eax
  80110d:	6a 06                	push   $0x6
  80110f:	68 c8 18 80 00       	push   $0x8018c8
  801114:	6a 23                	push   $0x23
  801116:	68 e5 18 80 00       	push   $0x8018e5
  80111b:	e8 c9 f4 ff ff       	call   8005e9 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801120:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801123:	5b                   	pop    %ebx
  801124:	5e                   	pop    %esi
  801125:	5f                   	pop    %edi
  801126:	5d                   	pop    %ebp
  801127:	c3                   	ret    

00801128 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	57                   	push   %edi
  80112c:	56                   	push   %esi
  80112d:	53                   	push   %ebx
  80112e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801131:	bb 00 00 00 00       	mov    $0x0,%ebx
  801136:	b8 08 00 00 00       	mov    $0x8,%eax
  80113b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113e:	8b 55 08             	mov    0x8(%ebp),%edx
  801141:	89 df                	mov    %ebx,%edi
  801143:	89 de                	mov    %ebx,%esi
  801145:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801147:	85 c0                	test   %eax,%eax
  801149:	7e 17                	jle    801162 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80114b:	83 ec 0c             	sub    $0xc,%esp
  80114e:	50                   	push   %eax
  80114f:	6a 08                	push   $0x8
  801151:	68 c8 18 80 00       	push   $0x8018c8
  801156:	6a 23                	push   $0x23
  801158:	68 e5 18 80 00       	push   $0x8018e5
  80115d:	e8 87 f4 ff ff       	call   8005e9 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801162:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801165:	5b                   	pop    %ebx
  801166:	5e                   	pop    %esi
  801167:	5f                   	pop    %edi
  801168:	5d                   	pop    %ebp
  801169:	c3                   	ret    

0080116a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80116a:	55                   	push   %ebp
  80116b:	89 e5                	mov    %esp,%ebp
  80116d:	57                   	push   %edi
  80116e:	56                   	push   %esi
  80116f:	53                   	push   %ebx
  801170:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801173:	bb 00 00 00 00       	mov    $0x0,%ebx
  801178:	b8 09 00 00 00       	mov    $0x9,%eax
  80117d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801180:	8b 55 08             	mov    0x8(%ebp),%edx
  801183:	89 df                	mov    %ebx,%edi
  801185:	89 de                	mov    %ebx,%esi
  801187:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801189:	85 c0                	test   %eax,%eax
  80118b:	7e 17                	jle    8011a4 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80118d:	83 ec 0c             	sub    $0xc,%esp
  801190:	50                   	push   %eax
  801191:	6a 09                	push   $0x9
  801193:	68 c8 18 80 00       	push   $0x8018c8
  801198:	6a 23                	push   $0x23
  80119a:	68 e5 18 80 00       	push   $0x8018e5
  80119f:	e8 45 f4 ff ff       	call   8005e9 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a7:	5b                   	pop    %ebx
  8011a8:	5e                   	pop    %esi
  8011a9:	5f                   	pop    %edi
  8011aa:	5d                   	pop    %ebp
  8011ab:	c3                   	ret    

008011ac <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	57                   	push   %edi
  8011b0:	56                   	push   %esi
  8011b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011b2:	be 00 00 00 00       	mov    $0x0,%esi
  8011b7:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011c5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011c8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011ca:	5b                   	pop    %ebx
  8011cb:	5e                   	pop    %esi
  8011cc:	5f                   	pop    %edi
  8011cd:	5d                   	pop    %ebp
  8011ce:	c3                   	ret    

008011cf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011cf:	55                   	push   %ebp
  8011d0:	89 e5                	mov    %esp,%ebp
  8011d2:	57                   	push   %edi
  8011d3:	56                   	push   %esi
  8011d4:	53                   	push   %ebx
  8011d5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011dd:	b8 0c 00 00 00       	mov    $0xc,%eax
  8011e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e5:	89 cb                	mov    %ecx,%ebx
  8011e7:	89 cf                	mov    %ecx,%edi
  8011e9:	89 ce                	mov    %ecx,%esi
  8011eb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011ed:	85 c0                	test   %eax,%eax
  8011ef:	7e 17                	jle    801208 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011f1:	83 ec 0c             	sub    $0xc,%esp
  8011f4:	50                   	push   %eax
  8011f5:	6a 0c                	push   $0xc
  8011f7:	68 c8 18 80 00       	push   $0x8018c8
  8011fc:	6a 23                	push   $0x23
  8011fe:	68 e5 18 80 00       	push   $0x8018e5
  801203:	e8 e1 f3 ff ff       	call   8005e9 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801208:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80120b:	5b                   	pop    %ebx
  80120c:	5e                   	pop    %esi
  80120d:	5f                   	pop    %edi
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    

00801210 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801216:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  80121d:	75 4c                	jne    80126b <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.

        void *va = (void *)(UXSTACKTOP - PGSIZE);
        if (sys_page_alloc(thisenv->env_id, va, PTE_P | PTE_U | PTE_W))
  80121f:	a1 cc 20 80 00       	mov    0x8020cc,%eax
  801224:	8b 40 48             	mov    0x48(%eax),%eax
  801227:	83 ec 04             	sub    $0x4,%esp
  80122a:	6a 07                	push   $0x7
  80122c:	68 00 f0 bf ee       	push   $0xeebff000
  801231:	50                   	push   %eax
  801232:	e8 2a fe ff ff       	call   801061 <sys_page_alloc>
  801237:	83 c4 10             	add    $0x10,%esp
  80123a:	85 c0                	test   %eax,%eax
  80123c:	74 14                	je     801252 <set_pgfault_handler+0x42>
        {
            panic("Unable to allocate memory for pgfault expected\n");
  80123e:	83 ec 04             	sub    $0x4,%esp
  801241:	68 f4 18 80 00       	push   $0x8018f4
  801246:	6a 24                	push   $0x24
  801248:	68 24 19 80 00       	push   $0x801924
  80124d:	e8 97 f3 ff ff       	call   8005e9 <_panic>
        }

        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801252:	a1 cc 20 80 00       	mov    0x8020cc,%eax
  801257:	8b 40 48             	mov    0x48(%eax),%eax
  80125a:	83 ec 08             	sub    $0x8,%esp
  80125d:	68 75 12 80 00       	push   $0x801275
  801262:	50                   	push   %eax
  801263:	e8 02 ff ff ff       	call   80116a <sys_env_set_pgfault_upcall>
  801268:	83 c4 10             	add    $0x10,%esp

		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80126b:	8b 45 08             	mov    0x8(%ebp),%eax
  80126e:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  801273:	c9                   	leave  
  801274:	c3                   	ret    

00801275 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801275:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801276:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  80127b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80127d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
    movl %esp, %ebx
  801280:	89 e3                	mov    %esp,%ebx
    // 40 is the size between utf_fault_va ~ utf_regs
    movl 40(%esp), %eax
  801282:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 48(%esp), %esp
  801286:	8b 64 24 30          	mov    0x30(%esp),%esp
    pushl %eax
  80128a:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    movl %ebx, %esp
  80128b:	89 dc                	mov    %ebx,%esp
    subl $4, 48(%esp)
  80128d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    popl %eax
  801292:	58                   	pop    %eax
    popl %eax
  801293:	58                   	pop    %eax
    popal
  801294:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  801295:	83 c4 04             	add    $0x4,%esp
    popfl
  801298:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp
  801299:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  80129a:	c3                   	ret    
  80129b:	66 90                	xchg   %ax,%ax
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
