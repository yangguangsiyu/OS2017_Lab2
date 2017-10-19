
obj/user/faultnostack：     文件格式 elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 17 03 80 00       	push   $0x800317
  80003e:	6a 00                	push   $0x0
  800040:	e8 2c 02 00 00       	call   800271 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80005f:	e8 c6 00 00 00       	call   80012a <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a0:	6a 00                	push   $0x0
  8000a2:	e8 42 00 00 00       	call   8000e9 <sys_env_destroy>
}
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	89 c7                	mov    %eax,%edi
  8000c1:	89 c6                	mov    %eax,%esi
  8000c3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	89 d1                	mov    %edx,%ecx
  8000dc:	89 d3                	mov    %edx,%ebx
  8000de:	89 d7                	mov    %edx,%edi
  8000e0:	89 d6                	mov    %edx,%esi
  8000e2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    

008000e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ff:	89 cb                	mov    %ecx,%ebx
  800101:	89 cf                	mov    %ecx,%edi
  800103:	89 ce                	mov    %ecx,%esi
  800105:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7e 17                	jle    800122 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	50                   	push   %eax
  80010f:	6a 03                	push   $0x3
  800111:	68 0a 10 80 00       	push   $0x80100a
  800116:	6a 23                	push   $0x23
  800118:	68 27 10 80 00       	push   $0x801027
  80011d:	e8 1b 02 00 00       	call   80033d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800122:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5f                   	pop    %edi
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    

0080012a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	57                   	push   %edi
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800130:	ba 00 00 00 00       	mov    $0x0,%edx
  800135:	b8 02 00 00 00       	mov    $0x2,%eax
  80013a:	89 d1                	mov    %edx,%ecx
  80013c:	89 d3                	mov    %edx,%ebx
  80013e:	89 d7                	mov    %edx,%edi
  800140:	89 d6                	mov    %edx,%esi
  800142:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <sys_yield>:

void
sys_yield(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014f:	ba 00 00 00 00       	mov    $0x0,%edx
  800154:	b8 0a 00 00 00       	mov    $0xa,%eax
  800159:	89 d1                	mov    %edx,%ecx
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	89 d7                	mov    %edx,%edi
  80015f:	89 d6                	mov    %edx,%esi
  800161:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  80016e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800171:	be 00 00 00 00       	mov    $0x0,%esi
  800176:	b8 04 00 00 00       	mov    $0x4,%eax
  80017b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017e:	8b 55 08             	mov    0x8(%ebp),%edx
  800181:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800184:	89 f7                	mov    %esi,%edi
  800186:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800188:	85 c0                	test   %eax,%eax
  80018a:	7e 17                	jle    8001a3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018c:	83 ec 0c             	sub    $0xc,%esp
  80018f:	50                   	push   %eax
  800190:	6a 04                	push   $0x4
  800192:	68 0a 10 80 00       	push   $0x80100a
  800197:	6a 23                	push   $0x23
  800199:	68 27 10 80 00       	push   $0x801027
  80019e:	e8 9a 01 00 00       	call   80033d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a6:	5b                   	pop    %ebx
  8001a7:	5e                   	pop    %esi
  8001a8:	5f                   	pop    %edi
  8001a9:	5d                   	pop    %ebp
  8001aa:	c3                   	ret    

008001ab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	57                   	push   %edi
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	7e 17                	jle    8001e5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	50                   	push   %eax
  8001d2:	6a 05                	push   $0x5
  8001d4:	68 0a 10 80 00       	push   $0x80100a
  8001d9:	6a 23                	push   $0x23
  8001db:	68 27 10 80 00       	push   $0x801027
  8001e0:	e8 58 01 00 00       	call   80033d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e8:	5b                   	pop    %ebx
  8001e9:	5e                   	pop    %esi
  8001ea:	5f                   	pop    %edi
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    

008001ed <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	57                   	push   %edi
  8001f1:	56                   	push   %esi
  8001f2:	53                   	push   %ebx
  8001f3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fb:	b8 06 00 00 00       	mov    $0x6,%eax
  800200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800203:	8b 55 08             	mov    0x8(%ebp),%edx
  800206:	89 df                	mov    %ebx,%edi
  800208:	89 de                	mov    %ebx,%esi
  80020a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80020c:	85 c0                	test   %eax,%eax
  80020e:	7e 17                	jle    800227 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	50                   	push   %eax
  800214:	6a 06                	push   $0x6
  800216:	68 0a 10 80 00       	push   $0x80100a
  80021b:	6a 23                	push   $0x23
  80021d:	68 27 10 80 00       	push   $0x801027
  800222:	e8 16 01 00 00       	call   80033d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800227:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022a:	5b                   	pop    %ebx
  80022b:	5e                   	pop    %esi
  80022c:	5f                   	pop    %edi
  80022d:	5d                   	pop    %ebp
  80022e:	c3                   	ret    

0080022f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	57                   	push   %edi
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800238:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023d:	b8 08 00 00 00       	mov    $0x8,%eax
  800242:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800245:	8b 55 08             	mov    0x8(%ebp),%edx
  800248:	89 df                	mov    %ebx,%edi
  80024a:	89 de                	mov    %ebx,%esi
  80024c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80024e:	85 c0                	test   %eax,%eax
  800250:	7e 17                	jle    800269 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800252:	83 ec 0c             	sub    $0xc,%esp
  800255:	50                   	push   %eax
  800256:	6a 08                	push   $0x8
  800258:	68 0a 10 80 00       	push   $0x80100a
  80025d:	6a 23                	push   $0x23
  80025f:	68 27 10 80 00       	push   $0x801027
  800264:	e8 d4 00 00 00       	call   80033d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800269:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026c:	5b                   	pop    %ebx
  80026d:	5e                   	pop    %esi
  80026e:	5f                   	pop    %edi
  80026f:	5d                   	pop    %ebp
  800270:	c3                   	ret    

00800271 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	57                   	push   %edi
  800275:	56                   	push   %esi
  800276:	53                   	push   %ebx
  800277:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027f:	b8 09 00 00 00       	mov    $0x9,%eax
  800284:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800287:	8b 55 08             	mov    0x8(%ebp),%edx
  80028a:	89 df                	mov    %ebx,%edi
  80028c:	89 de                	mov    %ebx,%esi
  80028e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800290:	85 c0                	test   %eax,%eax
  800292:	7e 17                	jle    8002ab <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800294:	83 ec 0c             	sub    $0xc,%esp
  800297:	50                   	push   %eax
  800298:	6a 09                	push   $0x9
  80029a:	68 0a 10 80 00       	push   $0x80100a
  80029f:	6a 23                	push   $0x23
  8002a1:	68 27 10 80 00       	push   $0x801027
  8002a6:	e8 92 00 00 00       	call   80033d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5f                   	pop    %edi
  8002b1:	5d                   	pop    %ebp
  8002b2:	c3                   	ret    

008002b3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	57                   	push   %edi
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b9:	be 00 00 00 00       	mov    $0x0,%esi
  8002be:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002cf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ec:	89 cb                	mov    %ecx,%ebx
  8002ee:	89 cf                	mov    %ecx,%edi
  8002f0:	89 ce                	mov    %ecx,%esi
  8002f2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	7e 17                	jle    80030f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	50                   	push   %eax
  8002fc:	6a 0c                	push   $0xc
  8002fe:	68 0a 10 80 00       	push   $0x80100a
  800303:	6a 23                	push   $0x23
  800305:	68 27 10 80 00       	push   $0x801027
  80030a:	e8 2e 00 00 00       	call   80033d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80030f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800312:	5b                   	pop    %ebx
  800313:	5e                   	pop    %esi
  800314:	5f                   	pop    %edi
  800315:	5d                   	pop    %ebp
  800316:	c3                   	ret    

00800317 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800317:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800318:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80031d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80031f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
    movl %esp, %ebx
  800322:	89 e3                	mov    %esp,%ebx
    // 40 is the size between utf_fault_va ~ utf_regs
    movl 40(%esp), %eax
  800324:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 48(%esp), %esp
  800328:	8b 64 24 30          	mov    0x30(%esp),%esp
    pushl %eax
  80032c:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    movl %ebx, %esp
  80032d:	89 dc                	mov    %ebx,%esp
    subl $4, 48(%esp)
  80032f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
    popl %eax
  800334:	58                   	pop    %eax
    popl %eax
  800335:	58                   	pop    %eax
    popal
  800336:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    add $4, %esp
  800337:	83 c4 04             	add    $0x4,%esp
    popfl
  80033a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

    popl %esp
  80033b:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  80033c:	c3                   	ret    

0080033d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	56                   	push   %esi
  800341:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800342:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800345:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80034b:	e8 da fd ff ff       	call   80012a <sys_getenvid>
  800350:	83 ec 0c             	sub    $0xc,%esp
  800353:	ff 75 0c             	pushl  0xc(%ebp)
  800356:	ff 75 08             	pushl  0x8(%ebp)
  800359:	56                   	push   %esi
  80035a:	50                   	push   %eax
  80035b:	68 38 10 80 00       	push   $0x801038
  800360:	e8 b1 00 00 00       	call   800416 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800365:	83 c4 18             	add    $0x18,%esp
  800368:	53                   	push   %ebx
  800369:	ff 75 10             	pushl  0x10(%ebp)
  80036c:	e8 54 00 00 00       	call   8003c5 <vcprintf>
	cprintf("\n");
  800371:	c7 04 24 5b 10 80 00 	movl   $0x80105b,(%esp)
  800378:	e8 99 00 00 00       	call   800416 <cprintf>
  80037d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800380:	cc                   	int3   
  800381:	eb fd                	jmp    800380 <_panic+0x43>

00800383 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	53                   	push   %ebx
  800387:	83 ec 04             	sub    $0x4,%esp
  80038a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80038d:	8b 13                	mov    (%ebx),%edx
  80038f:	8d 42 01             	lea    0x1(%edx),%eax
  800392:	89 03                	mov    %eax,(%ebx)
  800394:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800397:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80039b:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a0:	75 1a                	jne    8003bc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003a2:	83 ec 08             	sub    $0x8,%esp
  8003a5:	68 ff 00 00 00       	push   $0xff
  8003aa:	8d 43 08             	lea    0x8(%ebx),%eax
  8003ad:	50                   	push   %eax
  8003ae:	e8 f9 fc ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  8003b3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003b9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003bc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003c3:	c9                   	leave  
  8003c4:	c3                   	ret    

008003c5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003ce:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003d5:	00 00 00 
	b.cnt = 0;
  8003d8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003df:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e2:	ff 75 0c             	pushl  0xc(%ebp)
  8003e5:	ff 75 08             	pushl  0x8(%ebp)
  8003e8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ee:	50                   	push   %eax
  8003ef:	68 83 03 80 00       	push   $0x800383
  8003f4:	e8 54 01 00 00       	call   80054d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003f9:	83 c4 08             	add    $0x8,%esp
  8003fc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800402:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800408:	50                   	push   %eax
  800409:	e8 9e fc ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  80040e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800414:	c9                   	leave  
  800415:	c3                   	ret    

00800416 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800416:	55                   	push   %ebp
  800417:	89 e5                	mov    %esp,%ebp
  800419:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80041c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80041f:	50                   	push   %eax
  800420:	ff 75 08             	pushl  0x8(%ebp)
  800423:	e8 9d ff ff ff       	call   8003c5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800428:	c9                   	leave  
  800429:	c3                   	ret    

0080042a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	57                   	push   %edi
  80042e:	56                   	push   %esi
  80042f:	53                   	push   %ebx
  800430:	83 ec 1c             	sub    $0x1c,%esp
  800433:	89 c7                	mov    %eax,%edi
  800435:	89 d6                	mov    %edx,%esi
  800437:	8b 45 08             	mov    0x8(%ebp),%eax
  80043a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800440:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800443:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800446:	bb 00 00 00 00       	mov    $0x0,%ebx
  80044b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80044e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800451:	39 d3                	cmp    %edx,%ebx
  800453:	72 05                	jb     80045a <printnum+0x30>
  800455:	39 45 10             	cmp    %eax,0x10(%ebp)
  800458:	77 45                	ja     80049f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80045a:	83 ec 0c             	sub    $0xc,%esp
  80045d:	ff 75 18             	pushl  0x18(%ebp)
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800466:	53                   	push   %ebx
  800467:	ff 75 10             	pushl  0x10(%ebp)
  80046a:	83 ec 08             	sub    $0x8,%esp
  80046d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800470:	ff 75 e0             	pushl  -0x20(%ebp)
  800473:	ff 75 dc             	pushl  -0x24(%ebp)
  800476:	ff 75 d8             	pushl  -0x28(%ebp)
  800479:	e8 e2 08 00 00       	call   800d60 <__udivdi3>
  80047e:	83 c4 18             	add    $0x18,%esp
  800481:	52                   	push   %edx
  800482:	50                   	push   %eax
  800483:	89 f2                	mov    %esi,%edx
  800485:	89 f8                	mov    %edi,%eax
  800487:	e8 9e ff ff ff       	call   80042a <printnum>
  80048c:	83 c4 20             	add    $0x20,%esp
  80048f:	eb 18                	jmp    8004a9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800491:	83 ec 08             	sub    $0x8,%esp
  800494:	56                   	push   %esi
  800495:	ff 75 18             	pushl  0x18(%ebp)
  800498:	ff d7                	call   *%edi
  80049a:	83 c4 10             	add    $0x10,%esp
  80049d:	eb 03                	jmp    8004a2 <printnum+0x78>
  80049f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004a2:	83 eb 01             	sub    $0x1,%ebx
  8004a5:	85 db                	test   %ebx,%ebx
  8004a7:	7f e8                	jg     800491 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	56                   	push   %esi
  8004ad:	83 ec 04             	sub    $0x4,%esp
  8004b0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b6:	ff 75 dc             	pushl  -0x24(%ebp)
  8004b9:	ff 75 d8             	pushl  -0x28(%ebp)
  8004bc:	e8 cf 09 00 00       	call   800e90 <__umoddi3>
  8004c1:	83 c4 14             	add    $0x14,%esp
  8004c4:	0f be 80 5d 10 80 00 	movsbl 0x80105d(%eax),%eax
  8004cb:	50                   	push   %eax
  8004cc:	ff d7                	call   *%edi
}
  8004ce:	83 c4 10             	add    $0x10,%esp
  8004d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004d4:	5b                   	pop    %ebx
  8004d5:	5e                   	pop    %esi
  8004d6:	5f                   	pop    %edi
  8004d7:	5d                   	pop    %ebp
  8004d8:	c3                   	ret    

008004d9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004d9:	55                   	push   %ebp
  8004da:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004dc:	83 fa 01             	cmp    $0x1,%edx
  8004df:	7e 0e                	jle    8004ef <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004e1:	8b 10                	mov    (%eax),%edx
  8004e3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004e6:	89 08                	mov    %ecx,(%eax)
  8004e8:	8b 02                	mov    (%edx),%eax
  8004ea:	8b 52 04             	mov    0x4(%edx),%edx
  8004ed:	eb 22                	jmp    800511 <getuint+0x38>
	else if (lflag)
  8004ef:	85 d2                	test   %edx,%edx
  8004f1:	74 10                	je     800503 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004f3:	8b 10                	mov    (%eax),%edx
  8004f5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f8:	89 08                	mov    %ecx,(%eax)
  8004fa:	8b 02                	mov    (%edx),%eax
  8004fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800501:	eb 0e                	jmp    800511 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800503:	8b 10                	mov    (%eax),%edx
  800505:	8d 4a 04             	lea    0x4(%edx),%ecx
  800508:	89 08                	mov    %ecx,(%eax)
  80050a:	8b 02                	mov    (%edx),%eax
  80050c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800511:	5d                   	pop    %ebp
  800512:	c3                   	ret    

00800513 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800513:	55                   	push   %ebp
  800514:	89 e5                	mov    %esp,%ebp
  800516:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800519:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80051d:	8b 10                	mov    (%eax),%edx
  80051f:	3b 50 04             	cmp    0x4(%eax),%edx
  800522:	73 0a                	jae    80052e <sprintputch+0x1b>
		*b->buf++ = ch;
  800524:	8d 4a 01             	lea    0x1(%edx),%ecx
  800527:	89 08                	mov    %ecx,(%eax)
  800529:	8b 45 08             	mov    0x8(%ebp),%eax
  80052c:	88 02                	mov    %al,(%edx)
}
  80052e:	5d                   	pop    %ebp
  80052f:	c3                   	ret    

00800530 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800530:	55                   	push   %ebp
  800531:	89 e5                	mov    %esp,%ebp
  800533:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800536:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800539:	50                   	push   %eax
  80053a:	ff 75 10             	pushl  0x10(%ebp)
  80053d:	ff 75 0c             	pushl  0xc(%ebp)
  800540:	ff 75 08             	pushl  0x8(%ebp)
  800543:	e8 05 00 00 00       	call   80054d <vprintfmt>
	va_end(ap);
}
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	c9                   	leave  
  80054c:	c3                   	ret    

0080054d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80054d:	55                   	push   %ebp
  80054e:	89 e5                	mov    %esp,%ebp
  800550:	57                   	push   %edi
  800551:	56                   	push   %esi
  800552:	53                   	push   %ebx
  800553:	83 ec 2c             	sub    $0x2c,%esp
  800556:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
  800559:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800560:	eb 17                	jmp    800579 <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800562:	85 c0                	test   %eax,%eax
  800564:	0f 84 9f 03 00 00    	je     800909 <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
  80056a:	83 ec 08             	sub    $0x8,%esp
  80056d:	ff 75 0c             	pushl  0xc(%ebp)
  800570:	50                   	push   %eax
  800571:	ff 55 08             	call   *0x8(%ebp)
  800574:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800577:	89 f3                	mov    %esi,%ebx
  800579:	8d 73 01             	lea    0x1(%ebx),%esi
  80057c:	0f b6 03             	movzbl (%ebx),%eax
  80057f:	83 f8 25             	cmp    $0x25,%eax
  800582:	75 de                	jne    800562 <vprintfmt+0x15>
  800584:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800588:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80058f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800594:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80059b:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a0:	eb 06                	jmp    8005a8 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a2:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005a4:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a8:	8d 5e 01             	lea    0x1(%esi),%ebx
  8005ab:	0f b6 06             	movzbl (%esi),%eax
  8005ae:	0f b6 c8             	movzbl %al,%ecx
  8005b1:	83 e8 23             	sub    $0x23,%eax
  8005b4:	3c 55                	cmp    $0x55,%al
  8005b6:	0f 87 2d 03 00 00    	ja     8008e9 <vprintfmt+0x39c>
  8005bc:	0f b6 c0             	movzbl %al,%eax
  8005bf:	ff 24 85 20 11 80 00 	jmp    *0x801120(,%eax,4)
  8005c6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005c8:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8005cc:	eb da                	jmp    8005a8 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ce:	89 de                	mov    %ebx,%esi
  8005d0:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005d5:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  8005d8:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  8005dc:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  8005df:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8005e2:	83 f8 09             	cmp    $0x9,%eax
  8005e5:	77 33                	ja     80061a <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005e7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005ea:	eb e9                	jmp    8005d5 <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8d 48 04             	lea    0x4(%eax),%ecx
  8005f2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005f5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005f9:	eb 1f                	jmp    80061a <vprintfmt+0xcd>
  8005fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005fe:	85 c0                	test   %eax,%eax
  800600:	b9 00 00 00 00       	mov    $0x0,%ecx
  800605:	0f 49 c8             	cmovns %eax,%ecx
  800608:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060b:	89 de                	mov    %ebx,%esi
  80060d:	eb 99                	jmp    8005a8 <vprintfmt+0x5b>
  80060f:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800611:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  800618:	eb 8e                	jmp    8005a8 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80061a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80061e:	79 88                	jns    8005a8 <vprintfmt+0x5b>
				width = precision, precision = -1;
  800620:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800623:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800628:	e9 7b ff ff ff       	jmp    8005a8 <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80062d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800630:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800632:	e9 71 ff ff ff       	jmp    8005a8 <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
  800637:	8b 45 14             	mov    0x14(%ebp),%eax
  80063a:	8d 50 04             	lea    0x4(%eax),%edx
  80063d:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	ff 75 0c             	pushl  0xc(%ebp)
  800646:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800649:	03 08                	add    (%eax),%ecx
  80064b:	51                   	push   %ecx
  80064c:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
  80064f:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
  800652:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
  800659:	e9 1b ff ff ff       	jmp    800579 <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 48 04             	lea    0x4(%eax),%ecx
  800664:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800667:	8b 00                	mov    (%eax),%eax
  800669:	83 f8 02             	cmp    $0x2,%eax
  80066c:	74 1a                	je     800688 <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066e:	89 de                	mov    %ebx,%esi
  800670:	83 f8 04             	cmp    $0x4,%eax
  800673:	b8 00 00 00 00       	mov    $0x0,%eax
  800678:	b9 00 04 00 00       	mov    $0x400,%ecx
  80067d:	0f 44 c1             	cmove  %ecx,%eax
  800680:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800683:	e9 20 ff ff ff       	jmp    8005a8 <vprintfmt+0x5b>
  800688:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
  80068a:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
  800691:	e9 12 ff ff ff       	jmp    8005a8 <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800696:	8b 45 14             	mov    0x14(%ebp),%eax
  800699:	8d 50 04             	lea    0x4(%eax),%edx
  80069c:	89 55 14             	mov    %edx,0x14(%ebp)
  80069f:	8b 00                	mov    (%eax),%eax
  8006a1:	99                   	cltd   
  8006a2:	31 d0                	xor    %edx,%eax
  8006a4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006a6:	83 f8 09             	cmp    $0x9,%eax
  8006a9:	7f 0b                	jg     8006b6 <vprintfmt+0x169>
  8006ab:	8b 14 85 80 12 80 00 	mov    0x801280(,%eax,4),%edx
  8006b2:	85 d2                	test   %edx,%edx
  8006b4:	75 19                	jne    8006cf <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  8006b6:	50                   	push   %eax
  8006b7:	68 75 10 80 00       	push   $0x801075
  8006bc:	ff 75 0c             	pushl  0xc(%ebp)
  8006bf:	ff 75 08             	pushl  0x8(%ebp)
  8006c2:	e8 69 fe ff ff       	call   800530 <printfmt>
  8006c7:	83 c4 10             	add    $0x10,%esp
  8006ca:	e9 aa fe ff ff       	jmp    800579 <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  8006cf:	52                   	push   %edx
  8006d0:	68 7e 10 80 00       	push   $0x80107e
  8006d5:	ff 75 0c             	pushl  0xc(%ebp)
  8006d8:	ff 75 08             	pushl  0x8(%ebp)
  8006db:	e8 50 fe ff ff       	call   800530 <printfmt>
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	e9 91 fe ff ff       	jmp    800579 <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8d 50 04             	lea    0x4(%eax),%edx
  8006ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006f3:	85 f6                	test   %esi,%esi
  8006f5:	b8 6e 10 80 00       	mov    $0x80106e,%eax
  8006fa:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006fd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800701:	0f 8e 93 00 00 00    	jle    80079a <vprintfmt+0x24d>
  800707:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80070b:	0f 84 91 00 00 00    	je     8007a2 <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
  800711:	83 ec 08             	sub    $0x8,%esp
  800714:	57                   	push   %edi
  800715:	56                   	push   %esi
  800716:	e8 76 02 00 00       	call   800991 <strnlen>
  80071b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80071e:	29 c1                	sub    %eax,%ecx
  800720:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800723:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800726:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  80072a:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80072d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800730:	8b 75 0c             	mov    0xc(%ebp),%esi
  800733:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800736:	89 cb                	mov    %ecx,%ebx
  800738:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80073a:	eb 0e                	jmp    80074a <vprintfmt+0x1fd>
					putch(padc, putdat);
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	56                   	push   %esi
  800740:	57                   	push   %edi
  800741:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800744:	83 eb 01             	sub    $0x1,%ebx
  800747:	83 c4 10             	add    $0x10,%esp
  80074a:	85 db                	test   %ebx,%ebx
  80074c:	7f ee                	jg     80073c <vprintfmt+0x1ef>
  80074e:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800751:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800754:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800757:	85 c9                	test   %ecx,%ecx
  800759:	b8 00 00 00 00       	mov    $0x0,%eax
  80075e:	0f 49 c1             	cmovns %ecx,%eax
  800761:	29 c1                	sub    %eax,%ecx
  800763:	89 cb                	mov    %ecx,%ebx
  800765:	eb 41                	jmp    8007a8 <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800767:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80076b:	74 1b                	je     800788 <vprintfmt+0x23b>
  80076d:	0f be c0             	movsbl %al,%eax
  800770:	83 e8 20             	sub    $0x20,%eax
  800773:	83 f8 5e             	cmp    $0x5e,%eax
  800776:	76 10                	jbe    800788 <vprintfmt+0x23b>
					putch('?', putdat);
  800778:	83 ec 08             	sub    $0x8,%esp
  80077b:	ff 75 0c             	pushl  0xc(%ebp)
  80077e:	6a 3f                	push   $0x3f
  800780:	ff 55 08             	call   *0x8(%ebp)
  800783:	83 c4 10             	add    $0x10,%esp
  800786:	eb 0d                	jmp    800795 <vprintfmt+0x248>
				else
					putch(ch, putdat);
  800788:	83 ec 08             	sub    $0x8,%esp
  80078b:	ff 75 0c             	pushl  0xc(%ebp)
  80078e:	52                   	push   %edx
  80078f:	ff 55 08             	call   *0x8(%ebp)
  800792:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800795:	83 eb 01             	sub    $0x1,%ebx
  800798:	eb 0e                	jmp    8007a8 <vprintfmt+0x25b>
  80079a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80079d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007a0:	eb 06                	jmp    8007a8 <vprintfmt+0x25b>
  8007a2:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8007a5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007a8:	83 c6 01             	add    $0x1,%esi
  8007ab:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8007af:	0f be d0             	movsbl %al,%edx
  8007b2:	85 d2                	test   %edx,%edx
  8007b4:	74 25                	je     8007db <vprintfmt+0x28e>
  8007b6:	85 ff                	test   %edi,%edi
  8007b8:	78 ad                	js     800767 <vprintfmt+0x21a>
  8007ba:	83 ef 01             	sub    $0x1,%edi
  8007bd:	79 a8                	jns    800767 <vprintfmt+0x21a>
  8007bf:	89 d8                	mov    %ebx,%eax
  8007c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8007c7:	89 c3                	mov    %eax,%ebx
  8007c9:	eb 16                	jmp    8007e1 <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007cb:	83 ec 08             	sub    $0x8,%esp
  8007ce:	57                   	push   %edi
  8007cf:	6a 20                	push   $0x20
  8007d1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007d3:	83 eb 01             	sub    $0x1,%ebx
  8007d6:	83 c4 10             	add    $0x10,%esp
  8007d9:	eb 06                	jmp    8007e1 <vprintfmt+0x294>
  8007db:	8b 75 08             	mov    0x8(%ebp),%esi
  8007de:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8007e1:	85 db                	test   %ebx,%ebx
  8007e3:	7f e6                	jg     8007cb <vprintfmt+0x27e>
  8007e5:	89 75 08             	mov    %esi,0x8(%ebp)
  8007e8:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8007eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007ee:	e9 86 fd ff ff       	jmp    800579 <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007f3:	83 fa 01             	cmp    $0x1,%edx
  8007f6:	7e 10                	jle    800808 <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
  8007f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fb:	8d 50 08             	lea    0x8(%eax),%edx
  8007fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800801:	8b 30                	mov    (%eax),%esi
  800803:	8b 78 04             	mov    0x4(%eax),%edi
  800806:	eb 26                	jmp    80082e <vprintfmt+0x2e1>
	else if (lflag)
  800808:	85 d2                	test   %edx,%edx
  80080a:	74 12                	je     80081e <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  80080c:	8b 45 14             	mov    0x14(%ebp),%eax
  80080f:	8d 50 04             	lea    0x4(%eax),%edx
  800812:	89 55 14             	mov    %edx,0x14(%ebp)
  800815:	8b 30                	mov    (%eax),%esi
  800817:	89 f7                	mov    %esi,%edi
  800819:	c1 ff 1f             	sar    $0x1f,%edi
  80081c:	eb 10                	jmp    80082e <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
  80081e:	8b 45 14             	mov    0x14(%ebp),%eax
  800821:	8d 50 04             	lea    0x4(%eax),%edx
  800824:	89 55 14             	mov    %edx,0x14(%ebp)
  800827:	8b 30                	mov    (%eax),%esi
  800829:	89 f7                	mov    %esi,%edi
  80082b:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80082e:	89 f0                	mov    %esi,%eax
  800830:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800832:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800837:	85 ff                	test   %edi,%edi
  800839:	79 7b                	jns    8008b6 <vprintfmt+0x369>
				putch('-', putdat);
  80083b:	83 ec 08             	sub    $0x8,%esp
  80083e:	ff 75 0c             	pushl  0xc(%ebp)
  800841:	6a 2d                	push   $0x2d
  800843:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800846:	89 f0                	mov    %esi,%eax
  800848:	89 fa                	mov    %edi,%edx
  80084a:	f7 d8                	neg    %eax
  80084c:	83 d2 00             	adc    $0x0,%edx
  80084f:	f7 da                	neg    %edx
  800851:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800854:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800859:	eb 5b                	jmp    8008b6 <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80085b:	8d 45 14             	lea    0x14(%ebp),%eax
  80085e:	e8 76 fc ff ff       	call   8004d9 <getuint>
			base = 10;
  800863:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800868:	eb 4c                	jmp    8008b6 <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
  80086a:	8d 45 14             	lea    0x14(%ebp),%eax
  80086d:	e8 67 fc ff ff       	call   8004d9 <getuint>
            base = 8;
  800872:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800877:	eb 3d                	jmp    8008b6 <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
  800879:	83 ec 08             	sub    $0x8,%esp
  80087c:	ff 75 0c             	pushl  0xc(%ebp)
  80087f:	6a 30                	push   $0x30
  800881:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800884:	83 c4 08             	add    $0x8,%esp
  800887:	ff 75 0c             	pushl  0xc(%ebp)
  80088a:	6a 78                	push   $0x78
  80088c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80088f:	8b 45 14             	mov    0x14(%ebp),%eax
  800892:	8d 50 04             	lea    0x4(%eax),%edx
  800895:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800898:	8b 00                	mov    (%eax),%eax
  80089a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80089f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008a2:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8008a7:	eb 0d                	jmp    8008b6 <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008a9:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ac:	e8 28 fc ff ff       	call   8004d9 <getuint>
			base = 16;
  8008b1:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008b6:	83 ec 0c             	sub    $0xc,%esp
  8008b9:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  8008bd:	56                   	push   %esi
  8008be:	ff 75 e0             	pushl  -0x20(%ebp)
  8008c1:	51                   	push   %ecx
  8008c2:	52                   	push   %edx
  8008c3:	50                   	push   %eax
  8008c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ca:	e8 5b fb ff ff       	call   80042a <printnum>
			break;
  8008cf:	83 c4 20             	add    $0x20,%esp
  8008d2:	e9 a2 fc ff ff       	jmp    800579 <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008d7:	83 ec 08             	sub    $0x8,%esp
  8008da:	ff 75 0c             	pushl  0xc(%ebp)
  8008dd:	51                   	push   %ecx
  8008de:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008e1:	83 c4 10             	add    $0x10,%esp
  8008e4:	e9 90 fc ff ff       	jmp    800579 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008e9:	83 ec 08             	sub    $0x8,%esp
  8008ec:	ff 75 0c             	pushl  0xc(%ebp)
  8008ef:	6a 25                	push   $0x25
  8008f1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008f4:	83 c4 10             	add    $0x10,%esp
  8008f7:	89 f3                	mov    %esi,%ebx
  8008f9:	eb 03                	jmp    8008fe <vprintfmt+0x3b1>
  8008fb:	83 eb 01             	sub    $0x1,%ebx
  8008fe:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800902:	75 f7                	jne    8008fb <vprintfmt+0x3ae>
  800904:	e9 70 fc ff ff       	jmp    800579 <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  800909:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80090c:	5b                   	pop    %ebx
  80090d:	5e                   	pop    %esi
  80090e:	5f                   	pop    %edi
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	83 ec 18             	sub    $0x18,%esp
  800917:	8b 45 08             	mov    0x8(%ebp),%eax
  80091a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80091d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800920:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800924:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800927:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80092e:	85 c0                	test   %eax,%eax
  800930:	74 26                	je     800958 <vsnprintf+0x47>
  800932:	85 d2                	test   %edx,%edx
  800934:	7e 22                	jle    800958 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800936:	ff 75 14             	pushl  0x14(%ebp)
  800939:	ff 75 10             	pushl  0x10(%ebp)
  80093c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80093f:	50                   	push   %eax
  800940:	68 13 05 80 00       	push   $0x800513
  800945:	e8 03 fc ff ff       	call   80054d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80094a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80094d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800950:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800953:	83 c4 10             	add    $0x10,%esp
  800956:	eb 05                	jmp    80095d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800958:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80095d:	c9                   	leave  
  80095e:	c3                   	ret    

0080095f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800965:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800968:	50                   	push   %eax
  800969:	ff 75 10             	pushl  0x10(%ebp)
  80096c:	ff 75 0c             	pushl  0xc(%ebp)
  80096f:	ff 75 08             	pushl  0x8(%ebp)
  800972:	e8 9a ff ff ff       	call   800911 <vsnprintf>
	va_end(ap);

	return rc;
}
  800977:	c9                   	leave  
  800978:	c3                   	ret    

00800979 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80097f:	b8 00 00 00 00       	mov    $0x0,%eax
  800984:	eb 03                	jmp    800989 <strlen+0x10>
		n++;
  800986:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800989:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80098d:	75 f7                	jne    800986 <strlen+0xd>
		n++;
	return n;
}
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800997:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80099a:	ba 00 00 00 00       	mov    $0x0,%edx
  80099f:	eb 03                	jmp    8009a4 <strnlen+0x13>
		n++;
  8009a1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a4:	39 c2                	cmp    %eax,%edx
  8009a6:	74 08                	je     8009b0 <strnlen+0x1f>
  8009a8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009ac:	75 f3                	jne    8009a1 <strnlen+0x10>
  8009ae:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	53                   	push   %ebx
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009bc:	89 c2                	mov    %eax,%edx
  8009be:	83 c2 01             	add    $0x1,%edx
  8009c1:	83 c1 01             	add    $0x1,%ecx
  8009c4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009c8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009cb:	84 db                	test   %bl,%bl
  8009cd:	75 ef                	jne    8009be <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009cf:	5b                   	pop    %ebx
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	53                   	push   %ebx
  8009d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009d9:	53                   	push   %ebx
  8009da:	e8 9a ff ff ff       	call   800979 <strlen>
  8009df:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009e2:	ff 75 0c             	pushl  0xc(%ebp)
  8009e5:	01 d8                	add    %ebx,%eax
  8009e7:	50                   	push   %eax
  8009e8:	e8 c5 ff ff ff       	call   8009b2 <strcpy>
	return dst;
}
  8009ed:	89 d8                	mov    %ebx,%eax
  8009ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f2:	c9                   	leave  
  8009f3:	c3                   	ret    

008009f4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	56                   	push   %esi
  8009f8:	53                   	push   %ebx
  8009f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ff:	89 f3                	mov    %esi,%ebx
  800a01:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a04:	89 f2                	mov    %esi,%edx
  800a06:	eb 0f                	jmp    800a17 <strncpy+0x23>
		*dst++ = *src;
  800a08:	83 c2 01             	add    $0x1,%edx
  800a0b:	0f b6 01             	movzbl (%ecx),%eax
  800a0e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a11:	80 39 01             	cmpb   $0x1,(%ecx)
  800a14:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a17:	39 da                	cmp    %ebx,%edx
  800a19:	75 ed                	jne    800a08 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a1b:	89 f0                	mov    %esi,%eax
  800a1d:	5b                   	pop    %ebx
  800a1e:	5e                   	pop    %esi
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	56                   	push   %esi
  800a25:	53                   	push   %ebx
  800a26:	8b 75 08             	mov    0x8(%ebp),%esi
  800a29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2c:	8b 55 10             	mov    0x10(%ebp),%edx
  800a2f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a31:	85 d2                	test   %edx,%edx
  800a33:	74 21                	je     800a56 <strlcpy+0x35>
  800a35:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a39:	89 f2                	mov    %esi,%edx
  800a3b:	eb 09                	jmp    800a46 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a3d:	83 c2 01             	add    $0x1,%edx
  800a40:	83 c1 01             	add    $0x1,%ecx
  800a43:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a46:	39 c2                	cmp    %eax,%edx
  800a48:	74 09                	je     800a53 <strlcpy+0x32>
  800a4a:	0f b6 19             	movzbl (%ecx),%ebx
  800a4d:	84 db                	test   %bl,%bl
  800a4f:	75 ec                	jne    800a3d <strlcpy+0x1c>
  800a51:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a53:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a56:	29 f0                	sub    %esi,%eax
}
  800a58:	5b                   	pop    %ebx
  800a59:	5e                   	pop    %esi
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a62:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a65:	eb 06                	jmp    800a6d <strcmp+0x11>
		p++, q++;
  800a67:	83 c1 01             	add    $0x1,%ecx
  800a6a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a6d:	0f b6 01             	movzbl (%ecx),%eax
  800a70:	84 c0                	test   %al,%al
  800a72:	74 04                	je     800a78 <strcmp+0x1c>
  800a74:	3a 02                	cmp    (%edx),%al
  800a76:	74 ef                	je     800a67 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a78:	0f b6 c0             	movzbl %al,%eax
  800a7b:	0f b6 12             	movzbl (%edx),%edx
  800a7e:	29 d0                	sub    %edx,%eax
}
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	53                   	push   %ebx
  800a86:	8b 45 08             	mov    0x8(%ebp),%eax
  800a89:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8c:	89 c3                	mov    %eax,%ebx
  800a8e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a91:	eb 06                	jmp    800a99 <strncmp+0x17>
		n--, p++, q++;
  800a93:	83 c0 01             	add    $0x1,%eax
  800a96:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a99:	39 d8                	cmp    %ebx,%eax
  800a9b:	74 15                	je     800ab2 <strncmp+0x30>
  800a9d:	0f b6 08             	movzbl (%eax),%ecx
  800aa0:	84 c9                	test   %cl,%cl
  800aa2:	74 04                	je     800aa8 <strncmp+0x26>
  800aa4:	3a 0a                	cmp    (%edx),%cl
  800aa6:	74 eb                	je     800a93 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa8:	0f b6 00             	movzbl (%eax),%eax
  800aab:	0f b6 12             	movzbl (%edx),%edx
  800aae:	29 d0                	sub    %edx,%eax
  800ab0:	eb 05                	jmp    800ab7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ab2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ab7:	5b                   	pop    %ebx
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac4:	eb 07                	jmp    800acd <strchr+0x13>
		if (*s == c)
  800ac6:	38 ca                	cmp    %cl,%dl
  800ac8:	74 0f                	je     800ad9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aca:	83 c0 01             	add    $0x1,%eax
  800acd:	0f b6 10             	movzbl (%eax),%edx
  800ad0:	84 d2                	test   %dl,%dl
  800ad2:	75 f2                	jne    800ac6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ad4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ae5:	eb 03                	jmp    800aea <strfind+0xf>
  800ae7:	83 c0 01             	add    $0x1,%eax
  800aea:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aed:	38 ca                	cmp    %cl,%dl
  800aef:	74 04                	je     800af5 <strfind+0x1a>
  800af1:	84 d2                	test   %dl,%dl
  800af3:	75 f2                	jne    800ae7 <strfind+0xc>
			break;
	return (char *) s;
}
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	57                   	push   %edi
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
  800afd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b00:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b03:	85 c9                	test   %ecx,%ecx
  800b05:	74 36                	je     800b3d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b07:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b0d:	75 28                	jne    800b37 <memset+0x40>
  800b0f:	f6 c1 03             	test   $0x3,%cl
  800b12:	75 23                	jne    800b37 <memset+0x40>
		c &= 0xFF;
  800b14:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b18:	89 d3                	mov    %edx,%ebx
  800b1a:	c1 e3 08             	shl    $0x8,%ebx
  800b1d:	89 d6                	mov    %edx,%esi
  800b1f:	c1 e6 18             	shl    $0x18,%esi
  800b22:	89 d0                	mov    %edx,%eax
  800b24:	c1 e0 10             	shl    $0x10,%eax
  800b27:	09 f0                	or     %esi,%eax
  800b29:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b2b:	89 d8                	mov    %ebx,%eax
  800b2d:	09 d0                	or     %edx,%eax
  800b2f:	c1 e9 02             	shr    $0x2,%ecx
  800b32:	fc                   	cld    
  800b33:	f3 ab                	rep stos %eax,%es:(%edi)
  800b35:	eb 06                	jmp    800b3d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3a:	fc                   	cld    
  800b3b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b3d:	89 f8                	mov    %edi,%eax
  800b3f:	5b                   	pop    %ebx
  800b40:	5e                   	pop    %esi
  800b41:	5f                   	pop    %edi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b52:	39 c6                	cmp    %eax,%esi
  800b54:	73 35                	jae    800b8b <memmove+0x47>
  800b56:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b59:	39 d0                	cmp    %edx,%eax
  800b5b:	73 2e                	jae    800b8b <memmove+0x47>
		s += n;
		d += n;
  800b5d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b60:	89 d6                	mov    %edx,%esi
  800b62:	09 fe                	or     %edi,%esi
  800b64:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b6a:	75 13                	jne    800b7f <memmove+0x3b>
  800b6c:	f6 c1 03             	test   $0x3,%cl
  800b6f:	75 0e                	jne    800b7f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b71:	83 ef 04             	sub    $0x4,%edi
  800b74:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b77:	c1 e9 02             	shr    $0x2,%ecx
  800b7a:	fd                   	std    
  800b7b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b7d:	eb 09                	jmp    800b88 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b7f:	83 ef 01             	sub    $0x1,%edi
  800b82:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b85:	fd                   	std    
  800b86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b88:	fc                   	cld    
  800b89:	eb 1d                	jmp    800ba8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b8b:	89 f2                	mov    %esi,%edx
  800b8d:	09 c2                	or     %eax,%edx
  800b8f:	f6 c2 03             	test   $0x3,%dl
  800b92:	75 0f                	jne    800ba3 <memmove+0x5f>
  800b94:	f6 c1 03             	test   $0x3,%cl
  800b97:	75 0a                	jne    800ba3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b99:	c1 e9 02             	shr    $0x2,%ecx
  800b9c:	89 c7                	mov    %eax,%edi
  800b9e:	fc                   	cld    
  800b9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba1:	eb 05                	jmp    800ba8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ba3:	89 c7                	mov    %eax,%edi
  800ba5:	fc                   	cld    
  800ba6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ba8:	5e                   	pop    %esi
  800ba9:	5f                   	pop    %edi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800baf:	ff 75 10             	pushl  0x10(%ebp)
  800bb2:	ff 75 0c             	pushl  0xc(%ebp)
  800bb5:	ff 75 08             	pushl  0x8(%ebp)
  800bb8:	e8 87 ff ff ff       	call   800b44 <memmove>
}
  800bbd:	c9                   	leave  
  800bbe:	c3                   	ret    

00800bbf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
  800bc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bca:	89 c6                	mov    %eax,%esi
  800bcc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bcf:	eb 1a                	jmp    800beb <memcmp+0x2c>
		if (*s1 != *s2)
  800bd1:	0f b6 08             	movzbl (%eax),%ecx
  800bd4:	0f b6 1a             	movzbl (%edx),%ebx
  800bd7:	38 d9                	cmp    %bl,%cl
  800bd9:	74 0a                	je     800be5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bdb:	0f b6 c1             	movzbl %cl,%eax
  800bde:	0f b6 db             	movzbl %bl,%ebx
  800be1:	29 d8                	sub    %ebx,%eax
  800be3:	eb 0f                	jmp    800bf4 <memcmp+0x35>
		s1++, s2++;
  800be5:	83 c0 01             	add    $0x1,%eax
  800be8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800beb:	39 f0                	cmp    %esi,%eax
  800bed:	75 e2                	jne    800bd1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5d                   	pop    %ebp
  800bf7:	c3                   	ret    

00800bf8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	53                   	push   %ebx
  800bfc:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bff:	89 c1                	mov    %eax,%ecx
  800c01:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c04:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c08:	eb 0a                	jmp    800c14 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c0a:	0f b6 10             	movzbl (%eax),%edx
  800c0d:	39 da                	cmp    %ebx,%edx
  800c0f:	74 07                	je     800c18 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c11:	83 c0 01             	add    $0x1,%eax
  800c14:	39 c8                	cmp    %ecx,%eax
  800c16:	72 f2                	jb     800c0a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c18:	5b                   	pop    %ebx
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	57                   	push   %edi
  800c1f:	56                   	push   %esi
  800c20:	53                   	push   %ebx
  800c21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c24:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c27:	eb 03                	jmp    800c2c <strtol+0x11>
		s++;
  800c29:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c2c:	0f b6 01             	movzbl (%ecx),%eax
  800c2f:	3c 20                	cmp    $0x20,%al
  800c31:	74 f6                	je     800c29 <strtol+0xe>
  800c33:	3c 09                	cmp    $0x9,%al
  800c35:	74 f2                	je     800c29 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c37:	3c 2b                	cmp    $0x2b,%al
  800c39:	75 0a                	jne    800c45 <strtol+0x2a>
		s++;
  800c3b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c3e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c43:	eb 11                	jmp    800c56 <strtol+0x3b>
  800c45:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c4a:	3c 2d                	cmp    $0x2d,%al
  800c4c:	75 08                	jne    800c56 <strtol+0x3b>
		s++, neg = 1;
  800c4e:	83 c1 01             	add    $0x1,%ecx
  800c51:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c56:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c5c:	75 15                	jne    800c73 <strtol+0x58>
  800c5e:	80 39 30             	cmpb   $0x30,(%ecx)
  800c61:	75 10                	jne    800c73 <strtol+0x58>
  800c63:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c67:	75 7c                	jne    800ce5 <strtol+0xca>
		s += 2, base = 16;
  800c69:	83 c1 02             	add    $0x2,%ecx
  800c6c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c71:	eb 16                	jmp    800c89 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c73:	85 db                	test   %ebx,%ebx
  800c75:	75 12                	jne    800c89 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c77:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c7c:	80 39 30             	cmpb   $0x30,(%ecx)
  800c7f:	75 08                	jne    800c89 <strtol+0x6e>
		s++, base = 8;
  800c81:	83 c1 01             	add    $0x1,%ecx
  800c84:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c89:	b8 00 00 00 00       	mov    $0x0,%eax
  800c8e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c91:	0f b6 11             	movzbl (%ecx),%edx
  800c94:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c97:	89 f3                	mov    %esi,%ebx
  800c99:	80 fb 09             	cmp    $0x9,%bl
  800c9c:	77 08                	ja     800ca6 <strtol+0x8b>
			dig = *s - '0';
  800c9e:	0f be d2             	movsbl %dl,%edx
  800ca1:	83 ea 30             	sub    $0x30,%edx
  800ca4:	eb 22                	jmp    800cc8 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ca6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ca9:	89 f3                	mov    %esi,%ebx
  800cab:	80 fb 19             	cmp    $0x19,%bl
  800cae:	77 08                	ja     800cb8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cb0:	0f be d2             	movsbl %dl,%edx
  800cb3:	83 ea 57             	sub    $0x57,%edx
  800cb6:	eb 10                	jmp    800cc8 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cb8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cbb:	89 f3                	mov    %esi,%ebx
  800cbd:	80 fb 19             	cmp    $0x19,%bl
  800cc0:	77 16                	ja     800cd8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cc2:	0f be d2             	movsbl %dl,%edx
  800cc5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cc8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ccb:	7d 0b                	jge    800cd8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ccd:	83 c1 01             	add    $0x1,%ecx
  800cd0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cd4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cd6:	eb b9                	jmp    800c91 <strtol+0x76>

	if (endptr)
  800cd8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cdc:	74 0d                	je     800ceb <strtol+0xd0>
		*endptr = (char *) s;
  800cde:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ce1:	89 0e                	mov    %ecx,(%esi)
  800ce3:	eb 06                	jmp    800ceb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ce5:	85 db                	test   %ebx,%ebx
  800ce7:	74 98                	je     800c81 <strtol+0x66>
  800ce9:	eb 9e                	jmp    800c89 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ceb:	89 c2                	mov    %eax,%edx
  800ced:	f7 da                	neg    %edx
  800cef:	85 ff                	test   %edi,%edi
  800cf1:	0f 45 c2             	cmovne %edx,%eax
}
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800cff:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d06:	75 4c                	jne    800d54 <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.

        void *va = (void *)(UXSTACKTOP - PGSIZE);
        if (sys_page_alloc(thisenv->env_id, va, PTE_P | PTE_U | PTE_W))
  800d08:	a1 04 20 80 00       	mov    0x802004,%eax
  800d0d:	8b 40 48             	mov    0x48(%eax),%eax
  800d10:	83 ec 04             	sub    $0x4,%esp
  800d13:	6a 07                	push   $0x7
  800d15:	68 00 f0 bf ee       	push   $0xeebff000
  800d1a:	50                   	push   %eax
  800d1b:	e8 48 f4 ff ff       	call   800168 <sys_page_alloc>
  800d20:	83 c4 10             	add    $0x10,%esp
  800d23:	85 c0                	test   %eax,%eax
  800d25:	74 14                	je     800d3b <set_pgfault_handler+0x42>
        {
            panic("Unable to allocate memory for pgfault expected\n");
  800d27:	83 ec 04             	sub    $0x4,%esp
  800d2a:	68 a8 12 80 00       	push   $0x8012a8
  800d2f:	6a 24                	push   $0x24
  800d31:	68 d8 12 80 00       	push   $0x8012d8
  800d36:	e8 02 f6 ff ff       	call   80033d <_panic>
        }

        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800d3b:	a1 04 20 80 00       	mov    0x802004,%eax
  800d40:	8b 40 48             	mov    0x48(%eax),%eax
  800d43:	83 ec 08             	sub    $0x8,%esp
  800d46:	68 17 03 80 00       	push   $0x800317
  800d4b:	50                   	push   %eax
  800d4c:	e8 20 f5 ff ff       	call   800271 <sys_env_set_pgfault_upcall>
  800d51:	83 c4 10             	add    $0x10,%esp

		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d54:	8b 45 08             	mov    0x8(%ebp),%eax
  800d57:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d5c:	c9                   	leave  
  800d5d:	c3                   	ret    
  800d5e:	66 90                	xchg   %ax,%ax

00800d60 <__udivdi3>:
  800d60:	55                   	push   %ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 1c             	sub    $0x1c,%esp
  800d67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d77:	85 f6                	test   %esi,%esi
  800d79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d7d:	89 ca                	mov    %ecx,%edx
  800d7f:	89 f8                	mov    %edi,%eax
  800d81:	75 3d                	jne    800dc0 <__udivdi3+0x60>
  800d83:	39 cf                	cmp    %ecx,%edi
  800d85:	0f 87 c5 00 00 00    	ja     800e50 <__udivdi3+0xf0>
  800d8b:	85 ff                	test   %edi,%edi
  800d8d:	89 fd                	mov    %edi,%ebp
  800d8f:	75 0b                	jne    800d9c <__udivdi3+0x3c>
  800d91:	b8 01 00 00 00       	mov    $0x1,%eax
  800d96:	31 d2                	xor    %edx,%edx
  800d98:	f7 f7                	div    %edi
  800d9a:	89 c5                	mov    %eax,%ebp
  800d9c:	89 c8                	mov    %ecx,%eax
  800d9e:	31 d2                	xor    %edx,%edx
  800da0:	f7 f5                	div    %ebp
  800da2:	89 c1                	mov    %eax,%ecx
  800da4:	89 d8                	mov    %ebx,%eax
  800da6:	89 cf                	mov    %ecx,%edi
  800da8:	f7 f5                	div    %ebp
  800daa:	89 c3                	mov    %eax,%ebx
  800dac:	89 d8                	mov    %ebx,%eax
  800dae:	89 fa                	mov    %edi,%edx
  800db0:	83 c4 1c             	add    $0x1c,%esp
  800db3:	5b                   	pop    %ebx
  800db4:	5e                   	pop    %esi
  800db5:	5f                   	pop    %edi
  800db6:	5d                   	pop    %ebp
  800db7:	c3                   	ret    
  800db8:	90                   	nop
  800db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800dc0:	39 ce                	cmp    %ecx,%esi
  800dc2:	77 74                	ja     800e38 <__udivdi3+0xd8>
  800dc4:	0f bd fe             	bsr    %esi,%edi
  800dc7:	83 f7 1f             	xor    $0x1f,%edi
  800dca:	0f 84 98 00 00 00    	je     800e68 <__udivdi3+0x108>
  800dd0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800dd5:	89 f9                	mov    %edi,%ecx
  800dd7:	89 c5                	mov    %eax,%ebp
  800dd9:	29 fb                	sub    %edi,%ebx
  800ddb:	d3 e6                	shl    %cl,%esi
  800ddd:	89 d9                	mov    %ebx,%ecx
  800ddf:	d3 ed                	shr    %cl,%ebp
  800de1:	89 f9                	mov    %edi,%ecx
  800de3:	d3 e0                	shl    %cl,%eax
  800de5:	09 ee                	or     %ebp,%esi
  800de7:	89 d9                	mov    %ebx,%ecx
  800de9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ded:	89 d5                	mov    %edx,%ebp
  800def:	8b 44 24 08          	mov    0x8(%esp),%eax
  800df3:	d3 ed                	shr    %cl,%ebp
  800df5:	89 f9                	mov    %edi,%ecx
  800df7:	d3 e2                	shl    %cl,%edx
  800df9:	89 d9                	mov    %ebx,%ecx
  800dfb:	d3 e8                	shr    %cl,%eax
  800dfd:	09 c2                	or     %eax,%edx
  800dff:	89 d0                	mov    %edx,%eax
  800e01:	89 ea                	mov    %ebp,%edx
  800e03:	f7 f6                	div    %esi
  800e05:	89 d5                	mov    %edx,%ebp
  800e07:	89 c3                	mov    %eax,%ebx
  800e09:	f7 64 24 0c          	mull   0xc(%esp)
  800e0d:	39 d5                	cmp    %edx,%ebp
  800e0f:	72 10                	jb     800e21 <__udivdi3+0xc1>
  800e11:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e15:	89 f9                	mov    %edi,%ecx
  800e17:	d3 e6                	shl    %cl,%esi
  800e19:	39 c6                	cmp    %eax,%esi
  800e1b:	73 07                	jae    800e24 <__udivdi3+0xc4>
  800e1d:	39 d5                	cmp    %edx,%ebp
  800e1f:	75 03                	jne    800e24 <__udivdi3+0xc4>
  800e21:	83 eb 01             	sub    $0x1,%ebx
  800e24:	31 ff                	xor    %edi,%edi
  800e26:	89 d8                	mov    %ebx,%eax
  800e28:	89 fa                	mov    %edi,%edx
  800e2a:	83 c4 1c             	add    $0x1c,%esp
  800e2d:	5b                   	pop    %ebx
  800e2e:	5e                   	pop    %esi
  800e2f:	5f                   	pop    %edi
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    
  800e32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e38:	31 ff                	xor    %edi,%edi
  800e3a:	31 db                	xor    %ebx,%ebx
  800e3c:	89 d8                	mov    %ebx,%eax
  800e3e:	89 fa                	mov    %edi,%edx
  800e40:	83 c4 1c             	add    $0x1c,%esp
  800e43:	5b                   	pop    %ebx
  800e44:	5e                   	pop    %esi
  800e45:	5f                   	pop    %edi
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    
  800e48:	90                   	nop
  800e49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e50:	89 d8                	mov    %ebx,%eax
  800e52:	f7 f7                	div    %edi
  800e54:	31 ff                	xor    %edi,%edi
  800e56:	89 c3                	mov    %eax,%ebx
  800e58:	89 d8                	mov    %ebx,%eax
  800e5a:	89 fa                	mov    %edi,%edx
  800e5c:	83 c4 1c             	add    $0x1c,%esp
  800e5f:	5b                   	pop    %ebx
  800e60:	5e                   	pop    %esi
  800e61:	5f                   	pop    %edi
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    
  800e64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e68:	39 ce                	cmp    %ecx,%esi
  800e6a:	72 0c                	jb     800e78 <__udivdi3+0x118>
  800e6c:	31 db                	xor    %ebx,%ebx
  800e6e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e72:	0f 87 34 ff ff ff    	ja     800dac <__udivdi3+0x4c>
  800e78:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e7d:	e9 2a ff ff ff       	jmp    800dac <__udivdi3+0x4c>
  800e82:	66 90                	xchg   %ax,%ax
  800e84:	66 90                	xchg   %ax,%ax
  800e86:	66 90                	xchg   %ax,%ax
  800e88:	66 90                	xchg   %ax,%ax
  800e8a:	66 90                	xchg   %ax,%ax
  800e8c:	66 90                	xchg   %ax,%ax
  800e8e:	66 90                	xchg   %ax,%ax

00800e90 <__umoddi3>:
  800e90:	55                   	push   %ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	83 ec 1c             	sub    $0x1c,%esp
  800e97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ea3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ea7:	85 d2                	test   %edx,%edx
  800ea9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ead:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800eb1:	89 f3                	mov    %esi,%ebx
  800eb3:	89 3c 24             	mov    %edi,(%esp)
  800eb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eba:	75 1c                	jne    800ed8 <__umoddi3+0x48>
  800ebc:	39 f7                	cmp    %esi,%edi
  800ebe:	76 50                	jbe    800f10 <__umoddi3+0x80>
  800ec0:	89 c8                	mov    %ecx,%eax
  800ec2:	89 f2                	mov    %esi,%edx
  800ec4:	f7 f7                	div    %edi
  800ec6:	89 d0                	mov    %edx,%eax
  800ec8:	31 d2                	xor    %edx,%edx
  800eca:	83 c4 1c             	add    $0x1c,%esp
  800ecd:	5b                   	pop    %ebx
  800ece:	5e                   	pop    %esi
  800ecf:	5f                   	pop    %edi
  800ed0:	5d                   	pop    %ebp
  800ed1:	c3                   	ret    
  800ed2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ed8:	39 f2                	cmp    %esi,%edx
  800eda:	89 d0                	mov    %edx,%eax
  800edc:	77 52                	ja     800f30 <__umoddi3+0xa0>
  800ede:	0f bd ea             	bsr    %edx,%ebp
  800ee1:	83 f5 1f             	xor    $0x1f,%ebp
  800ee4:	75 5a                	jne    800f40 <__umoddi3+0xb0>
  800ee6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800eea:	0f 82 e0 00 00 00    	jb     800fd0 <__umoddi3+0x140>
  800ef0:	39 0c 24             	cmp    %ecx,(%esp)
  800ef3:	0f 86 d7 00 00 00    	jbe    800fd0 <__umoddi3+0x140>
  800ef9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800efd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f01:	83 c4 1c             	add    $0x1c,%esp
  800f04:	5b                   	pop    %ebx
  800f05:	5e                   	pop    %esi
  800f06:	5f                   	pop    %edi
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    
  800f09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f10:	85 ff                	test   %edi,%edi
  800f12:	89 fd                	mov    %edi,%ebp
  800f14:	75 0b                	jne    800f21 <__umoddi3+0x91>
  800f16:	b8 01 00 00 00       	mov    $0x1,%eax
  800f1b:	31 d2                	xor    %edx,%edx
  800f1d:	f7 f7                	div    %edi
  800f1f:	89 c5                	mov    %eax,%ebp
  800f21:	89 f0                	mov    %esi,%eax
  800f23:	31 d2                	xor    %edx,%edx
  800f25:	f7 f5                	div    %ebp
  800f27:	89 c8                	mov    %ecx,%eax
  800f29:	f7 f5                	div    %ebp
  800f2b:	89 d0                	mov    %edx,%eax
  800f2d:	eb 99                	jmp    800ec8 <__umoddi3+0x38>
  800f2f:	90                   	nop
  800f30:	89 c8                	mov    %ecx,%eax
  800f32:	89 f2                	mov    %esi,%edx
  800f34:	83 c4 1c             	add    $0x1c,%esp
  800f37:	5b                   	pop    %ebx
  800f38:	5e                   	pop    %esi
  800f39:	5f                   	pop    %edi
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    
  800f3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f40:	8b 34 24             	mov    (%esp),%esi
  800f43:	bf 20 00 00 00       	mov    $0x20,%edi
  800f48:	89 e9                	mov    %ebp,%ecx
  800f4a:	29 ef                	sub    %ebp,%edi
  800f4c:	d3 e0                	shl    %cl,%eax
  800f4e:	89 f9                	mov    %edi,%ecx
  800f50:	89 f2                	mov    %esi,%edx
  800f52:	d3 ea                	shr    %cl,%edx
  800f54:	89 e9                	mov    %ebp,%ecx
  800f56:	09 c2                	or     %eax,%edx
  800f58:	89 d8                	mov    %ebx,%eax
  800f5a:	89 14 24             	mov    %edx,(%esp)
  800f5d:	89 f2                	mov    %esi,%edx
  800f5f:	d3 e2                	shl    %cl,%edx
  800f61:	89 f9                	mov    %edi,%ecx
  800f63:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f67:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f6b:	d3 e8                	shr    %cl,%eax
  800f6d:	89 e9                	mov    %ebp,%ecx
  800f6f:	89 c6                	mov    %eax,%esi
  800f71:	d3 e3                	shl    %cl,%ebx
  800f73:	89 f9                	mov    %edi,%ecx
  800f75:	89 d0                	mov    %edx,%eax
  800f77:	d3 e8                	shr    %cl,%eax
  800f79:	89 e9                	mov    %ebp,%ecx
  800f7b:	09 d8                	or     %ebx,%eax
  800f7d:	89 d3                	mov    %edx,%ebx
  800f7f:	89 f2                	mov    %esi,%edx
  800f81:	f7 34 24             	divl   (%esp)
  800f84:	89 d6                	mov    %edx,%esi
  800f86:	d3 e3                	shl    %cl,%ebx
  800f88:	f7 64 24 04          	mull   0x4(%esp)
  800f8c:	39 d6                	cmp    %edx,%esi
  800f8e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f92:	89 d1                	mov    %edx,%ecx
  800f94:	89 c3                	mov    %eax,%ebx
  800f96:	72 08                	jb     800fa0 <__umoddi3+0x110>
  800f98:	75 11                	jne    800fab <__umoddi3+0x11b>
  800f9a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f9e:	73 0b                	jae    800fab <__umoddi3+0x11b>
  800fa0:	2b 44 24 04          	sub    0x4(%esp),%eax
  800fa4:	1b 14 24             	sbb    (%esp),%edx
  800fa7:	89 d1                	mov    %edx,%ecx
  800fa9:	89 c3                	mov    %eax,%ebx
  800fab:	8b 54 24 08          	mov    0x8(%esp),%edx
  800faf:	29 da                	sub    %ebx,%edx
  800fb1:	19 ce                	sbb    %ecx,%esi
  800fb3:	89 f9                	mov    %edi,%ecx
  800fb5:	89 f0                	mov    %esi,%eax
  800fb7:	d3 e0                	shl    %cl,%eax
  800fb9:	89 e9                	mov    %ebp,%ecx
  800fbb:	d3 ea                	shr    %cl,%edx
  800fbd:	89 e9                	mov    %ebp,%ecx
  800fbf:	d3 ee                	shr    %cl,%esi
  800fc1:	09 d0                	or     %edx,%eax
  800fc3:	89 f2                	mov    %esi,%edx
  800fc5:	83 c4 1c             	add    $0x1c,%esp
  800fc8:	5b                   	pop    %ebx
  800fc9:	5e                   	pop    %esi
  800fca:	5f                   	pop    %edi
  800fcb:	5d                   	pop    %ebp
  800fcc:	c3                   	ret    
  800fcd:	8d 76 00             	lea    0x0(%esi),%esi
  800fd0:	29 f9                	sub    %edi,%ecx
  800fd2:	19 d6                	sbb    %edx,%esi
  800fd4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fd8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fdc:	e9 18 ff ff ff       	jmp    800ef9 <__umoddi3+0x69>
