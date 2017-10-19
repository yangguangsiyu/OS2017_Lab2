
obj/user/faultevilhandler：     文件格式 elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 32 01 00 00       	call   800179 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 20 00 10 f0       	push   $0xf0100020
  80004f:	6a 00                	push   $0x0
  800051:	e8 2c 02 00 00       	call   800282 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800070:	e8 c6 00 00 00       	call   80013b <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x2d>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800092:	83 ec 08             	sub    $0x8,%esp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	e8 97 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0a 00 00 00       	call   8000ab <exit>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b1:	6a 00                	push   $0x0
  8000b3:	e8 42 00 00 00       	call   8000fa <sys_env_destroy>
}
  8000b8:	83 c4 10             	add    $0x10,%esp
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    

008000bd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	57                   	push   %edi
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ce:	89 c3                	mov    %eax,%ebx
  8000d0:	89 c7                	mov    %eax,%edi
  8000d2:	89 c6                	mov    %eax,%esi
  8000d4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_cgetc>:

int
sys_cgetc(void)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000eb:	89 d1                	mov    %edx,%ecx
  8000ed:	89 d3                	mov    %edx,%ebx
  8000ef:	89 d7                	mov    %edx,%edi
  8000f1:	89 d6                	mov    %edx,%esi
  8000f3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f5:	5b                   	pop    %ebx
  8000f6:	5e                   	pop    %esi
  8000f7:	5f                   	pop    %edi
  8000f8:	5d                   	pop    %ebp
  8000f9:	c3                   	ret    

008000fa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	57                   	push   %edi
  8000fe:	56                   	push   %esi
  8000ff:	53                   	push   %ebx
  800100:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800103:	b9 00 00 00 00       	mov    $0x0,%ecx
  800108:	b8 03 00 00 00       	mov    $0x3,%eax
  80010d:	8b 55 08             	mov    0x8(%ebp),%edx
  800110:	89 cb                	mov    %ecx,%ebx
  800112:	89 cf                	mov    %ecx,%edi
  800114:	89 ce                	mov    %ecx,%esi
  800116:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800118:	85 c0                	test   %eax,%eax
  80011a:	7e 17                	jle    800133 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80011c:	83 ec 0c             	sub    $0xc,%esp
  80011f:	50                   	push   %eax
  800120:	6a 03                	push   $0x3
  800122:	68 8a 0f 80 00       	push   $0x800f8a
  800127:	6a 23                	push   $0x23
  800129:	68 a7 0f 80 00       	push   $0x800fa7
  80012e:	e8 f5 01 00 00       	call   800328 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800133:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 02 00 00 00       	mov    $0x2,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_yield>:

void
sys_yield(void)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800160:	ba 00 00 00 00       	mov    $0x0,%edx
  800165:	b8 0a 00 00 00       	mov    $0xa,%eax
  80016a:	89 d1                	mov    %edx,%ecx
  80016c:	89 d3                	mov    %edx,%ebx
  80016e:	89 d7                	mov    %edx,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800174:	5b                   	pop    %ebx
  800175:	5e                   	pop    %esi
  800176:	5f                   	pop    %edi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	57                   	push   %edi
  80017d:	56                   	push   %esi
  80017e:	53                   	push   %ebx
  80017f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800182:	be 00 00 00 00       	mov    $0x0,%esi
  800187:	b8 04 00 00 00       	mov    $0x4,%eax
  80018c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018f:	8b 55 08             	mov    0x8(%ebp),%edx
  800192:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800195:	89 f7                	mov    %esi,%edi
  800197:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800199:	85 c0                	test   %eax,%eax
  80019b:	7e 17                	jle    8001b4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80019d:	83 ec 0c             	sub    $0xc,%esp
  8001a0:	50                   	push   %eax
  8001a1:	6a 04                	push   $0x4
  8001a3:	68 8a 0f 80 00       	push   $0x800f8a
  8001a8:	6a 23                	push   $0x23
  8001aa:	68 a7 0f 80 00       	push   $0x800fa7
  8001af:	e8 74 01 00 00       	call   800328 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b7:	5b                   	pop    %ebx
  8001b8:	5e                   	pop    %esi
  8001b9:	5f                   	pop    %edi
  8001ba:	5d                   	pop    %ebp
  8001bb:	c3                   	ret    

008001bc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d6:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001db:	85 c0                	test   %eax,%eax
  8001dd:	7e 17                	jle    8001f6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001df:	83 ec 0c             	sub    $0xc,%esp
  8001e2:	50                   	push   %eax
  8001e3:	6a 05                	push   $0x5
  8001e5:	68 8a 0f 80 00       	push   $0x800f8a
  8001ea:	6a 23                	push   $0x23
  8001ec:	68 a7 0f 80 00       	push   $0x800fa7
  8001f1:	e8 32 01 00 00       	call   800328 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f9:	5b                   	pop    %ebx
  8001fa:	5e                   	pop    %esi
  8001fb:	5f                   	pop    %edi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	57                   	push   %edi
  800202:	56                   	push   %esi
  800203:	53                   	push   %ebx
  800204:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800207:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020c:	b8 06 00 00 00       	mov    $0x6,%eax
  800211:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800214:	8b 55 08             	mov    0x8(%ebp),%edx
  800217:	89 df                	mov    %ebx,%edi
  800219:	89 de                	mov    %ebx,%esi
  80021b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80021d:	85 c0                	test   %eax,%eax
  80021f:	7e 17                	jle    800238 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800221:	83 ec 0c             	sub    $0xc,%esp
  800224:	50                   	push   %eax
  800225:	6a 06                	push   $0x6
  800227:	68 8a 0f 80 00       	push   $0x800f8a
  80022c:	6a 23                	push   $0x23
  80022e:	68 a7 0f 80 00       	push   $0x800fa7
  800233:	e8 f0 00 00 00       	call   800328 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800238:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023b:	5b                   	pop    %ebx
  80023c:	5e                   	pop    %esi
  80023d:	5f                   	pop    %edi
  80023e:	5d                   	pop    %ebp
  80023f:	c3                   	ret    

00800240 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800249:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024e:	b8 08 00 00 00       	mov    $0x8,%eax
  800253:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800256:	8b 55 08             	mov    0x8(%ebp),%edx
  800259:	89 df                	mov    %ebx,%edi
  80025b:	89 de                	mov    %ebx,%esi
  80025d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80025f:	85 c0                	test   %eax,%eax
  800261:	7e 17                	jle    80027a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800263:	83 ec 0c             	sub    $0xc,%esp
  800266:	50                   	push   %eax
  800267:	6a 08                	push   $0x8
  800269:	68 8a 0f 80 00       	push   $0x800f8a
  80026e:	6a 23                	push   $0x23
  800270:	68 a7 0f 80 00       	push   $0x800fa7
  800275:	e8 ae 00 00 00       	call   800328 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80027a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027d:	5b                   	pop    %ebx
  80027e:	5e                   	pop    %esi
  80027f:	5f                   	pop    %edi
  800280:	5d                   	pop    %ebp
  800281:	c3                   	ret    

00800282 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	57                   	push   %edi
  800286:	56                   	push   %esi
  800287:	53                   	push   %ebx
  800288:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80028b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800290:	b8 09 00 00 00       	mov    $0x9,%eax
  800295:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800298:	8b 55 08             	mov    0x8(%ebp),%edx
  80029b:	89 df                	mov    %ebx,%edi
  80029d:	89 de                	mov    %ebx,%esi
  80029f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002a1:	85 c0                	test   %eax,%eax
  8002a3:	7e 17                	jle    8002bc <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a5:	83 ec 0c             	sub    $0xc,%esp
  8002a8:	50                   	push   %eax
  8002a9:	6a 09                	push   $0x9
  8002ab:	68 8a 0f 80 00       	push   $0x800f8a
  8002b0:	6a 23                	push   $0x23
  8002b2:	68 a7 0f 80 00       	push   $0x800fa7
  8002b7:	e8 6c 00 00 00       	call   800328 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002bf:	5b                   	pop    %ebx
  8002c0:	5e                   	pop    %esi
  8002c1:	5f                   	pop    %edi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	57                   	push   %edi
  8002c8:	56                   	push   %esi
  8002c9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ca:	be 00 00 00 00       	mov    $0x0,%esi
  8002cf:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002dd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002e0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5f                   	pop    %edi
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
  8002ed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002f5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fd:	89 cb                	mov    %ecx,%ebx
  8002ff:	89 cf                	mov    %ecx,%edi
  800301:	89 ce                	mov    %ecx,%esi
  800303:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800305:	85 c0                	test   %eax,%eax
  800307:	7e 17                	jle    800320 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800309:	83 ec 0c             	sub    $0xc,%esp
  80030c:	50                   	push   %eax
  80030d:	6a 0c                	push   $0xc
  80030f:	68 8a 0f 80 00       	push   $0x800f8a
  800314:	6a 23                	push   $0x23
  800316:	68 a7 0f 80 00       	push   $0x800fa7
  80031b:	e8 08 00 00 00       	call   800328 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800320:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800323:	5b                   	pop    %ebx
  800324:	5e                   	pop    %esi
  800325:	5f                   	pop    %edi
  800326:	5d                   	pop    %ebp
  800327:	c3                   	ret    

00800328 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	56                   	push   %esi
  80032c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80032d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800330:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800336:	e8 00 fe ff ff       	call   80013b <sys_getenvid>
  80033b:	83 ec 0c             	sub    $0xc,%esp
  80033e:	ff 75 0c             	pushl  0xc(%ebp)
  800341:	ff 75 08             	pushl  0x8(%ebp)
  800344:	56                   	push   %esi
  800345:	50                   	push   %eax
  800346:	68 b8 0f 80 00       	push   $0x800fb8
  80034b:	e8 b1 00 00 00       	call   800401 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800350:	83 c4 18             	add    $0x18,%esp
  800353:	53                   	push   %ebx
  800354:	ff 75 10             	pushl  0x10(%ebp)
  800357:	e8 54 00 00 00       	call   8003b0 <vcprintf>
	cprintf("\n");
  80035c:	c7 04 24 dc 0f 80 00 	movl   $0x800fdc,(%esp)
  800363:	e8 99 00 00 00       	call   800401 <cprintf>
  800368:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80036b:	cc                   	int3   
  80036c:	eb fd                	jmp    80036b <_panic+0x43>

0080036e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	53                   	push   %ebx
  800372:	83 ec 04             	sub    $0x4,%esp
  800375:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800378:	8b 13                	mov    (%ebx),%edx
  80037a:	8d 42 01             	lea    0x1(%edx),%eax
  80037d:	89 03                	mov    %eax,(%ebx)
  80037f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800382:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800386:	3d ff 00 00 00       	cmp    $0xff,%eax
  80038b:	75 1a                	jne    8003a7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80038d:	83 ec 08             	sub    $0x8,%esp
  800390:	68 ff 00 00 00       	push   $0xff
  800395:	8d 43 08             	lea    0x8(%ebx),%eax
  800398:	50                   	push   %eax
  800399:	e8 1f fd ff ff       	call   8000bd <sys_cputs>
		b->idx = 0;
  80039e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003a4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003a7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003ae:	c9                   	leave  
  8003af:	c3                   	ret    

008003b0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
  8003b3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003b9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003c0:	00 00 00 
	b.cnt = 0;
  8003c3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003ca:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003cd:	ff 75 0c             	pushl  0xc(%ebp)
  8003d0:	ff 75 08             	pushl  0x8(%ebp)
  8003d3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003d9:	50                   	push   %eax
  8003da:	68 6e 03 80 00       	push   $0x80036e
  8003df:	e8 54 01 00 00       	call   800538 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003e4:	83 c4 08             	add    $0x8,%esp
  8003e7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003ed:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003f3:	50                   	push   %eax
  8003f4:	e8 c4 fc ff ff       	call   8000bd <sys_cputs>

	return b.cnt;
}
  8003f9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003ff:	c9                   	leave  
  800400:	c3                   	ret    

00800401 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800401:	55                   	push   %ebp
  800402:	89 e5                	mov    %esp,%ebp
  800404:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800407:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80040a:	50                   	push   %eax
  80040b:	ff 75 08             	pushl  0x8(%ebp)
  80040e:	e8 9d ff ff ff       	call   8003b0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800413:	c9                   	leave  
  800414:	c3                   	ret    

00800415 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800415:	55                   	push   %ebp
  800416:	89 e5                	mov    %esp,%ebp
  800418:	57                   	push   %edi
  800419:	56                   	push   %esi
  80041a:	53                   	push   %ebx
  80041b:	83 ec 1c             	sub    $0x1c,%esp
  80041e:	89 c7                	mov    %eax,%edi
  800420:	89 d6                	mov    %edx,%esi
  800422:	8b 45 08             	mov    0x8(%ebp),%eax
  800425:	8b 55 0c             	mov    0xc(%ebp),%edx
  800428:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80042b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80042e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800431:	bb 00 00 00 00       	mov    $0x0,%ebx
  800436:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800439:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80043c:	39 d3                	cmp    %edx,%ebx
  80043e:	72 05                	jb     800445 <printnum+0x30>
  800440:	39 45 10             	cmp    %eax,0x10(%ebp)
  800443:	77 45                	ja     80048a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800445:	83 ec 0c             	sub    $0xc,%esp
  800448:	ff 75 18             	pushl  0x18(%ebp)
  80044b:	8b 45 14             	mov    0x14(%ebp),%eax
  80044e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800451:	53                   	push   %ebx
  800452:	ff 75 10             	pushl  0x10(%ebp)
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	ff 75 e4             	pushl  -0x1c(%ebp)
  80045b:	ff 75 e0             	pushl  -0x20(%ebp)
  80045e:	ff 75 dc             	pushl  -0x24(%ebp)
  800461:	ff 75 d8             	pushl  -0x28(%ebp)
  800464:	e8 87 08 00 00       	call   800cf0 <__udivdi3>
  800469:	83 c4 18             	add    $0x18,%esp
  80046c:	52                   	push   %edx
  80046d:	50                   	push   %eax
  80046e:	89 f2                	mov    %esi,%edx
  800470:	89 f8                	mov    %edi,%eax
  800472:	e8 9e ff ff ff       	call   800415 <printnum>
  800477:	83 c4 20             	add    $0x20,%esp
  80047a:	eb 18                	jmp    800494 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	56                   	push   %esi
  800480:	ff 75 18             	pushl  0x18(%ebp)
  800483:	ff d7                	call   *%edi
  800485:	83 c4 10             	add    $0x10,%esp
  800488:	eb 03                	jmp    80048d <printnum+0x78>
  80048a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80048d:	83 eb 01             	sub    $0x1,%ebx
  800490:	85 db                	test   %ebx,%ebx
  800492:	7f e8                	jg     80047c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800494:	83 ec 08             	sub    $0x8,%esp
  800497:	56                   	push   %esi
  800498:	83 ec 04             	sub    $0x4,%esp
  80049b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80049e:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a1:	ff 75 dc             	pushl  -0x24(%ebp)
  8004a4:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a7:	e8 74 09 00 00       	call   800e20 <__umoddi3>
  8004ac:	83 c4 14             	add    $0x14,%esp
  8004af:	0f be 80 de 0f 80 00 	movsbl 0x800fde(%eax),%eax
  8004b6:	50                   	push   %eax
  8004b7:	ff d7                	call   *%edi
}
  8004b9:	83 c4 10             	add    $0x10,%esp
  8004bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004bf:	5b                   	pop    %ebx
  8004c0:	5e                   	pop    %esi
  8004c1:	5f                   	pop    %edi
  8004c2:	5d                   	pop    %ebp
  8004c3:	c3                   	ret    

008004c4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004c4:	55                   	push   %ebp
  8004c5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004c7:	83 fa 01             	cmp    $0x1,%edx
  8004ca:	7e 0e                	jle    8004da <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004cc:	8b 10                	mov    (%eax),%edx
  8004ce:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004d1:	89 08                	mov    %ecx,(%eax)
  8004d3:	8b 02                	mov    (%edx),%eax
  8004d5:	8b 52 04             	mov    0x4(%edx),%edx
  8004d8:	eb 22                	jmp    8004fc <getuint+0x38>
	else if (lflag)
  8004da:	85 d2                	test   %edx,%edx
  8004dc:	74 10                	je     8004ee <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004de:	8b 10                	mov    (%eax),%edx
  8004e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e3:	89 08                	mov    %ecx,(%eax)
  8004e5:	8b 02                	mov    (%edx),%eax
  8004e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ec:	eb 0e                	jmp    8004fc <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004ee:	8b 10                	mov    (%eax),%edx
  8004f0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f3:	89 08                	mov    %ecx,(%eax)
  8004f5:	8b 02                	mov    (%edx),%eax
  8004f7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004fc:	5d                   	pop    %ebp
  8004fd:	c3                   	ret    

008004fe <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004fe:	55                   	push   %ebp
  8004ff:	89 e5                	mov    %esp,%ebp
  800501:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800504:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800508:	8b 10                	mov    (%eax),%edx
  80050a:	3b 50 04             	cmp    0x4(%eax),%edx
  80050d:	73 0a                	jae    800519 <sprintputch+0x1b>
		*b->buf++ = ch;
  80050f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800512:	89 08                	mov    %ecx,(%eax)
  800514:	8b 45 08             	mov    0x8(%ebp),%eax
  800517:	88 02                	mov    %al,(%edx)
}
  800519:	5d                   	pop    %ebp
  80051a:	c3                   	ret    

0080051b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80051b:	55                   	push   %ebp
  80051c:	89 e5                	mov    %esp,%ebp
  80051e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800521:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800524:	50                   	push   %eax
  800525:	ff 75 10             	pushl  0x10(%ebp)
  800528:	ff 75 0c             	pushl  0xc(%ebp)
  80052b:	ff 75 08             	pushl  0x8(%ebp)
  80052e:	e8 05 00 00 00       	call   800538 <vprintfmt>
	va_end(ap);
}
  800533:	83 c4 10             	add    $0x10,%esp
  800536:	c9                   	leave  
  800537:	c3                   	ret    

00800538 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800538:	55                   	push   %ebp
  800539:	89 e5                	mov    %esp,%ebp
  80053b:	57                   	push   %edi
  80053c:	56                   	push   %esi
  80053d:	53                   	push   %ebx
  80053e:	83 ec 2c             	sub    $0x2c,%esp
  800541:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
  800544:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80054b:	eb 17                	jmp    800564 <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80054d:	85 c0                	test   %eax,%eax
  80054f:	0f 84 9f 03 00 00    	je     8008f4 <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	ff 75 0c             	pushl  0xc(%ebp)
  80055b:	50                   	push   %eax
  80055c:	ff 55 08             	call   *0x8(%ebp)
  80055f:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800562:	89 f3                	mov    %esi,%ebx
  800564:	8d 73 01             	lea    0x1(%ebx),%esi
  800567:	0f b6 03             	movzbl (%ebx),%eax
  80056a:	83 f8 25             	cmp    $0x25,%eax
  80056d:	75 de                	jne    80054d <vprintfmt+0x15>
  80056f:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800573:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80057a:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80057f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800586:	ba 00 00 00 00       	mov    $0x0,%edx
  80058b:	eb 06                	jmp    800593 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80058f:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800593:	8d 5e 01             	lea    0x1(%esi),%ebx
  800596:	0f b6 06             	movzbl (%esi),%eax
  800599:	0f b6 c8             	movzbl %al,%ecx
  80059c:	83 e8 23             	sub    $0x23,%eax
  80059f:	3c 55                	cmp    $0x55,%al
  8005a1:	0f 87 2d 03 00 00    	ja     8008d4 <vprintfmt+0x39c>
  8005a7:	0f b6 c0             	movzbl %al,%eax
  8005aa:	ff 24 85 a0 10 80 00 	jmp    *0x8010a0(,%eax,4)
  8005b1:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005b3:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8005b7:	eb da                	jmp    800593 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b9:	89 de                	mov    %ebx,%esi
  8005bb:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005c0:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  8005c3:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  8005c7:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  8005ca:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8005cd:	83 f8 09             	cmp    $0x9,%eax
  8005d0:	77 33                	ja     800605 <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005d2:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005d5:	eb e9                	jmp    8005c0 <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8d 48 04             	lea    0x4(%eax),%ecx
  8005dd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005e0:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e2:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005e4:	eb 1f                	jmp    800605 <vprintfmt+0xcd>
  8005e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e9:	85 c0                	test   %eax,%eax
  8005eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f0:	0f 49 c8             	cmovns %eax,%ecx
  8005f3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f6:	89 de                	mov    %ebx,%esi
  8005f8:	eb 99                	jmp    800593 <vprintfmt+0x5b>
  8005fa:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005fc:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  800603:	eb 8e                	jmp    800593 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  800605:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800609:	79 88                	jns    800593 <vprintfmt+0x5b>
				width = precision, precision = -1;
  80060b:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80060e:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800613:	e9 7b ff ff ff       	jmp    800593 <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800618:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061b:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80061d:	e9 71 ff ff ff       	jmp    800593 <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8d 50 04             	lea    0x4(%eax),%edx
  800628:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	ff 75 0c             	pushl  0xc(%ebp)
  800631:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800634:	03 08                	add    (%eax),%ecx
  800636:	51                   	push   %ecx
  800637:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
  80063a:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
  80063d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
  800644:	e9 1b ff ff ff       	jmp    800564 <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8d 48 04             	lea    0x4(%eax),%ecx
  80064f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800652:	8b 00                	mov    (%eax),%eax
  800654:	83 f8 02             	cmp    $0x2,%eax
  800657:	74 1a                	je     800673 <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800659:	89 de                	mov    %ebx,%esi
  80065b:	83 f8 04             	cmp    $0x4,%eax
  80065e:	b8 00 00 00 00       	mov    $0x0,%eax
  800663:	b9 00 04 00 00       	mov    $0x400,%ecx
  800668:	0f 44 c1             	cmove  %ecx,%eax
  80066b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066e:	e9 20 ff ff ff       	jmp    800593 <vprintfmt+0x5b>
  800673:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
  800675:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
  80067c:	e9 12 ff ff ff       	jmp    800593 <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8d 50 04             	lea    0x4(%eax),%edx
  800687:	89 55 14             	mov    %edx,0x14(%ebp)
  80068a:	8b 00                	mov    (%eax),%eax
  80068c:	99                   	cltd   
  80068d:	31 d0                	xor    %edx,%eax
  80068f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800691:	83 f8 09             	cmp    $0x9,%eax
  800694:	7f 0b                	jg     8006a1 <vprintfmt+0x169>
  800696:	8b 14 85 00 12 80 00 	mov    0x801200(,%eax,4),%edx
  80069d:	85 d2                	test   %edx,%edx
  80069f:	75 19                	jne    8006ba <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  8006a1:	50                   	push   %eax
  8006a2:	68 f6 0f 80 00       	push   $0x800ff6
  8006a7:	ff 75 0c             	pushl  0xc(%ebp)
  8006aa:	ff 75 08             	pushl  0x8(%ebp)
  8006ad:	e8 69 fe ff ff       	call   80051b <printfmt>
  8006b2:	83 c4 10             	add    $0x10,%esp
  8006b5:	e9 aa fe ff ff       	jmp    800564 <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  8006ba:	52                   	push   %edx
  8006bb:	68 ff 0f 80 00       	push   $0x800fff
  8006c0:	ff 75 0c             	pushl  0xc(%ebp)
  8006c3:	ff 75 08             	pushl  0x8(%ebp)
  8006c6:	e8 50 fe ff ff       	call   80051b <printfmt>
  8006cb:	83 c4 10             	add    $0x10,%esp
  8006ce:	e9 91 fe ff ff       	jmp    800564 <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8d 50 04             	lea    0x4(%eax),%edx
  8006d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006dc:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006de:	85 f6                	test   %esi,%esi
  8006e0:	b8 ef 0f 80 00       	mov    $0x800fef,%eax
  8006e5:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006e8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006ec:	0f 8e 93 00 00 00    	jle    800785 <vprintfmt+0x24d>
  8006f2:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8006f6:	0f 84 91 00 00 00    	je     80078d <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fc:	83 ec 08             	sub    $0x8,%esp
  8006ff:	57                   	push   %edi
  800700:	56                   	push   %esi
  800701:	e8 76 02 00 00       	call   80097c <strnlen>
  800706:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800709:	29 c1                	sub    %eax,%ecx
  80070b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80070e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800711:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  800715:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800718:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80071b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80071e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800721:	89 cb                	mov    %ecx,%ebx
  800723:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800725:	eb 0e                	jmp    800735 <vprintfmt+0x1fd>
					putch(padc, putdat);
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	56                   	push   %esi
  80072b:	57                   	push   %edi
  80072c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80072f:	83 eb 01             	sub    $0x1,%ebx
  800732:	83 c4 10             	add    $0x10,%esp
  800735:	85 db                	test   %ebx,%ebx
  800737:	7f ee                	jg     800727 <vprintfmt+0x1ef>
  800739:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80073c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80073f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800742:	85 c9                	test   %ecx,%ecx
  800744:	b8 00 00 00 00       	mov    $0x0,%eax
  800749:	0f 49 c1             	cmovns %ecx,%eax
  80074c:	29 c1                	sub    %eax,%ecx
  80074e:	89 cb                	mov    %ecx,%ebx
  800750:	eb 41                	jmp    800793 <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800752:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800756:	74 1b                	je     800773 <vprintfmt+0x23b>
  800758:	0f be c0             	movsbl %al,%eax
  80075b:	83 e8 20             	sub    $0x20,%eax
  80075e:	83 f8 5e             	cmp    $0x5e,%eax
  800761:	76 10                	jbe    800773 <vprintfmt+0x23b>
					putch('?', putdat);
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	ff 75 0c             	pushl  0xc(%ebp)
  800769:	6a 3f                	push   $0x3f
  80076b:	ff 55 08             	call   *0x8(%ebp)
  80076e:	83 c4 10             	add    $0x10,%esp
  800771:	eb 0d                	jmp    800780 <vprintfmt+0x248>
				else
					putch(ch, putdat);
  800773:	83 ec 08             	sub    $0x8,%esp
  800776:	ff 75 0c             	pushl  0xc(%ebp)
  800779:	52                   	push   %edx
  80077a:	ff 55 08             	call   *0x8(%ebp)
  80077d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800780:	83 eb 01             	sub    $0x1,%ebx
  800783:	eb 0e                	jmp    800793 <vprintfmt+0x25b>
  800785:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800788:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80078b:	eb 06                	jmp    800793 <vprintfmt+0x25b>
  80078d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800790:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800793:	83 c6 01             	add    $0x1,%esi
  800796:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80079a:	0f be d0             	movsbl %al,%edx
  80079d:	85 d2                	test   %edx,%edx
  80079f:	74 25                	je     8007c6 <vprintfmt+0x28e>
  8007a1:	85 ff                	test   %edi,%edi
  8007a3:	78 ad                	js     800752 <vprintfmt+0x21a>
  8007a5:	83 ef 01             	sub    $0x1,%edi
  8007a8:	79 a8                	jns    800752 <vprintfmt+0x21a>
  8007aa:	89 d8                	mov    %ebx,%eax
  8007ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8007af:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8007b2:	89 c3                	mov    %eax,%ebx
  8007b4:	eb 16                	jmp    8007cc <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007b6:	83 ec 08             	sub    $0x8,%esp
  8007b9:	57                   	push   %edi
  8007ba:	6a 20                	push   $0x20
  8007bc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007be:	83 eb 01             	sub    $0x1,%ebx
  8007c1:	83 c4 10             	add    $0x10,%esp
  8007c4:	eb 06                	jmp    8007cc <vprintfmt+0x294>
  8007c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8007cc:	85 db                	test   %ebx,%ebx
  8007ce:	7f e6                	jg     8007b6 <vprintfmt+0x27e>
  8007d0:	89 75 08             	mov    %esi,0x8(%ebp)
  8007d3:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8007d6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007d9:	e9 86 fd ff ff       	jmp    800564 <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007de:	83 fa 01             	cmp    $0x1,%edx
  8007e1:	7e 10                	jle    8007f3 <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
  8007e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e6:	8d 50 08             	lea    0x8(%eax),%edx
  8007e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ec:	8b 30                	mov    (%eax),%esi
  8007ee:	8b 78 04             	mov    0x4(%eax),%edi
  8007f1:	eb 26                	jmp    800819 <vprintfmt+0x2e1>
	else if (lflag)
  8007f3:	85 d2                	test   %edx,%edx
  8007f5:	74 12                	je     800809 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  8007f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fa:	8d 50 04             	lea    0x4(%eax),%edx
  8007fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800800:	8b 30                	mov    (%eax),%esi
  800802:	89 f7                	mov    %esi,%edi
  800804:	c1 ff 1f             	sar    $0x1f,%edi
  800807:	eb 10                	jmp    800819 <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
  800809:	8b 45 14             	mov    0x14(%ebp),%eax
  80080c:	8d 50 04             	lea    0x4(%eax),%edx
  80080f:	89 55 14             	mov    %edx,0x14(%ebp)
  800812:	8b 30                	mov    (%eax),%esi
  800814:	89 f7                	mov    %esi,%edi
  800816:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800819:	89 f0                	mov    %esi,%eax
  80081b:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80081d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800822:	85 ff                	test   %edi,%edi
  800824:	79 7b                	jns    8008a1 <vprintfmt+0x369>
				putch('-', putdat);
  800826:	83 ec 08             	sub    $0x8,%esp
  800829:	ff 75 0c             	pushl  0xc(%ebp)
  80082c:	6a 2d                	push   $0x2d
  80082e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800831:	89 f0                	mov    %esi,%eax
  800833:	89 fa                	mov    %edi,%edx
  800835:	f7 d8                	neg    %eax
  800837:	83 d2 00             	adc    $0x0,%edx
  80083a:	f7 da                	neg    %edx
  80083c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80083f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800844:	eb 5b                	jmp    8008a1 <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800846:	8d 45 14             	lea    0x14(%ebp),%eax
  800849:	e8 76 fc ff ff       	call   8004c4 <getuint>
			base = 10;
  80084e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800853:	eb 4c                	jmp    8008a1 <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
  800855:	8d 45 14             	lea    0x14(%ebp),%eax
  800858:	e8 67 fc ff ff       	call   8004c4 <getuint>
            base = 8;
  80085d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800862:	eb 3d                	jmp    8008a1 <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
  800864:	83 ec 08             	sub    $0x8,%esp
  800867:	ff 75 0c             	pushl  0xc(%ebp)
  80086a:	6a 30                	push   $0x30
  80086c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80086f:	83 c4 08             	add    $0x8,%esp
  800872:	ff 75 0c             	pushl  0xc(%ebp)
  800875:	6a 78                	push   $0x78
  800877:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80087a:	8b 45 14             	mov    0x14(%ebp),%eax
  80087d:	8d 50 04             	lea    0x4(%eax),%edx
  800880:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800883:	8b 00                	mov    (%eax),%eax
  800885:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80088a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80088d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800892:	eb 0d                	jmp    8008a1 <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800894:	8d 45 14             	lea    0x14(%ebp),%eax
  800897:	e8 28 fc ff ff       	call   8004c4 <getuint>
			base = 16;
  80089c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008a1:	83 ec 0c             	sub    $0xc,%esp
  8008a4:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  8008a8:	56                   	push   %esi
  8008a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8008ac:	51                   	push   %ecx
  8008ad:	52                   	push   %edx
  8008ae:	50                   	push   %eax
  8008af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b5:	e8 5b fb ff ff       	call   800415 <printnum>
			break;
  8008ba:	83 c4 20             	add    $0x20,%esp
  8008bd:	e9 a2 fc ff ff       	jmp    800564 <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008c2:	83 ec 08             	sub    $0x8,%esp
  8008c5:	ff 75 0c             	pushl  0xc(%ebp)
  8008c8:	51                   	push   %ecx
  8008c9:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008cc:	83 c4 10             	add    $0x10,%esp
  8008cf:	e9 90 fc ff ff       	jmp    800564 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008d4:	83 ec 08             	sub    $0x8,%esp
  8008d7:	ff 75 0c             	pushl  0xc(%ebp)
  8008da:	6a 25                	push   $0x25
  8008dc:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008df:	83 c4 10             	add    $0x10,%esp
  8008e2:	89 f3                	mov    %esi,%ebx
  8008e4:	eb 03                	jmp    8008e9 <vprintfmt+0x3b1>
  8008e6:	83 eb 01             	sub    $0x1,%ebx
  8008e9:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8008ed:	75 f7                	jne    8008e6 <vprintfmt+0x3ae>
  8008ef:	e9 70 fc ff ff       	jmp    800564 <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  8008f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008f7:	5b                   	pop    %ebx
  8008f8:	5e                   	pop    %esi
  8008f9:	5f                   	pop    %edi
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	83 ec 18             	sub    $0x18,%esp
  800902:	8b 45 08             	mov    0x8(%ebp),%eax
  800905:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800908:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80090b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80090f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800912:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800919:	85 c0                	test   %eax,%eax
  80091b:	74 26                	je     800943 <vsnprintf+0x47>
  80091d:	85 d2                	test   %edx,%edx
  80091f:	7e 22                	jle    800943 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800921:	ff 75 14             	pushl  0x14(%ebp)
  800924:	ff 75 10             	pushl  0x10(%ebp)
  800927:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80092a:	50                   	push   %eax
  80092b:	68 fe 04 80 00       	push   $0x8004fe
  800930:	e8 03 fc ff ff       	call   800538 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800935:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800938:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80093b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80093e:	83 c4 10             	add    $0x10,%esp
  800941:	eb 05                	jmp    800948 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800943:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800948:	c9                   	leave  
  800949:	c3                   	ret    

0080094a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800950:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800953:	50                   	push   %eax
  800954:	ff 75 10             	pushl  0x10(%ebp)
  800957:	ff 75 0c             	pushl  0xc(%ebp)
  80095a:	ff 75 08             	pushl  0x8(%ebp)
  80095d:	e8 9a ff ff ff       	call   8008fc <vsnprintf>
	va_end(ap);

	return rc;
}
  800962:	c9                   	leave  
  800963:	c3                   	ret    

00800964 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80096a:	b8 00 00 00 00       	mov    $0x0,%eax
  80096f:	eb 03                	jmp    800974 <strlen+0x10>
		n++;
  800971:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800974:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800978:	75 f7                	jne    800971 <strlen+0xd>
		n++;
	return n;
}
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800982:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800985:	ba 00 00 00 00       	mov    $0x0,%edx
  80098a:	eb 03                	jmp    80098f <strnlen+0x13>
		n++;
  80098c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80098f:	39 c2                	cmp    %eax,%edx
  800991:	74 08                	je     80099b <strnlen+0x1f>
  800993:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800997:	75 f3                	jne    80098c <strnlen+0x10>
  800999:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80099b:	5d                   	pop    %ebp
  80099c:	c3                   	ret    

0080099d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	53                   	push   %ebx
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009a7:	89 c2                	mov    %eax,%edx
  8009a9:	83 c2 01             	add    $0x1,%edx
  8009ac:	83 c1 01             	add    $0x1,%ecx
  8009af:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009b3:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009b6:	84 db                	test   %bl,%bl
  8009b8:	75 ef                	jne    8009a9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009ba:	5b                   	pop    %ebx
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	53                   	push   %ebx
  8009c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009c4:	53                   	push   %ebx
  8009c5:	e8 9a ff ff ff       	call   800964 <strlen>
  8009ca:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009cd:	ff 75 0c             	pushl  0xc(%ebp)
  8009d0:	01 d8                	add    %ebx,%eax
  8009d2:	50                   	push   %eax
  8009d3:	e8 c5 ff ff ff       	call   80099d <strcpy>
	return dst;
}
  8009d8:	89 d8                	mov    %ebx,%eax
  8009da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009dd:	c9                   	leave  
  8009de:	c3                   	ret    

008009df <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	56                   	push   %esi
  8009e3:	53                   	push   %ebx
  8009e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ea:	89 f3                	mov    %esi,%ebx
  8009ec:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ef:	89 f2                	mov    %esi,%edx
  8009f1:	eb 0f                	jmp    800a02 <strncpy+0x23>
		*dst++ = *src;
  8009f3:	83 c2 01             	add    $0x1,%edx
  8009f6:	0f b6 01             	movzbl (%ecx),%eax
  8009f9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009fc:	80 39 01             	cmpb   $0x1,(%ecx)
  8009ff:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a02:	39 da                	cmp    %ebx,%edx
  800a04:	75 ed                	jne    8009f3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a06:	89 f0                	mov    %esi,%eax
  800a08:	5b                   	pop    %ebx
  800a09:	5e                   	pop    %esi
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	56                   	push   %esi
  800a10:	53                   	push   %ebx
  800a11:	8b 75 08             	mov    0x8(%ebp),%esi
  800a14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a17:	8b 55 10             	mov    0x10(%ebp),%edx
  800a1a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a1c:	85 d2                	test   %edx,%edx
  800a1e:	74 21                	je     800a41 <strlcpy+0x35>
  800a20:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a24:	89 f2                	mov    %esi,%edx
  800a26:	eb 09                	jmp    800a31 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a28:	83 c2 01             	add    $0x1,%edx
  800a2b:	83 c1 01             	add    $0x1,%ecx
  800a2e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a31:	39 c2                	cmp    %eax,%edx
  800a33:	74 09                	je     800a3e <strlcpy+0x32>
  800a35:	0f b6 19             	movzbl (%ecx),%ebx
  800a38:	84 db                	test   %bl,%bl
  800a3a:	75 ec                	jne    800a28 <strlcpy+0x1c>
  800a3c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a3e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a41:	29 f0                	sub    %esi,%eax
}
  800a43:	5b                   	pop    %ebx
  800a44:	5e                   	pop    %esi
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a50:	eb 06                	jmp    800a58 <strcmp+0x11>
		p++, q++;
  800a52:	83 c1 01             	add    $0x1,%ecx
  800a55:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a58:	0f b6 01             	movzbl (%ecx),%eax
  800a5b:	84 c0                	test   %al,%al
  800a5d:	74 04                	je     800a63 <strcmp+0x1c>
  800a5f:	3a 02                	cmp    (%edx),%al
  800a61:	74 ef                	je     800a52 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a63:	0f b6 c0             	movzbl %al,%eax
  800a66:	0f b6 12             	movzbl (%edx),%edx
  800a69:	29 d0                	sub    %edx,%eax
}
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    

00800a6d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	53                   	push   %ebx
  800a71:	8b 45 08             	mov    0x8(%ebp),%eax
  800a74:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a77:	89 c3                	mov    %eax,%ebx
  800a79:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a7c:	eb 06                	jmp    800a84 <strncmp+0x17>
		n--, p++, q++;
  800a7e:	83 c0 01             	add    $0x1,%eax
  800a81:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a84:	39 d8                	cmp    %ebx,%eax
  800a86:	74 15                	je     800a9d <strncmp+0x30>
  800a88:	0f b6 08             	movzbl (%eax),%ecx
  800a8b:	84 c9                	test   %cl,%cl
  800a8d:	74 04                	je     800a93 <strncmp+0x26>
  800a8f:	3a 0a                	cmp    (%edx),%cl
  800a91:	74 eb                	je     800a7e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a93:	0f b6 00             	movzbl (%eax),%eax
  800a96:	0f b6 12             	movzbl (%edx),%edx
  800a99:	29 d0                	sub    %edx,%eax
  800a9b:	eb 05                	jmp    800aa2 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a9d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800aa2:	5b                   	pop    %ebx
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aab:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aaf:	eb 07                	jmp    800ab8 <strchr+0x13>
		if (*s == c)
  800ab1:	38 ca                	cmp    %cl,%dl
  800ab3:	74 0f                	je     800ac4 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ab5:	83 c0 01             	add    $0x1,%eax
  800ab8:	0f b6 10             	movzbl (%eax),%edx
  800abb:	84 d2                	test   %dl,%dl
  800abd:	75 f2                	jne    800ab1 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800abf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  800acc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad0:	eb 03                	jmp    800ad5 <strfind+0xf>
  800ad2:	83 c0 01             	add    $0x1,%eax
  800ad5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ad8:	38 ca                	cmp    %cl,%dl
  800ada:	74 04                	je     800ae0 <strfind+0x1a>
  800adc:	84 d2                	test   %dl,%dl
  800ade:	75 f2                	jne    800ad2 <strfind+0xc>
			break;
	return (char *) s;
}
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	57                   	push   %edi
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
  800ae8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aeb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aee:	85 c9                	test   %ecx,%ecx
  800af0:	74 36                	je     800b28 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800af2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800af8:	75 28                	jne    800b22 <memset+0x40>
  800afa:	f6 c1 03             	test   $0x3,%cl
  800afd:	75 23                	jne    800b22 <memset+0x40>
		c &= 0xFF;
  800aff:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b03:	89 d3                	mov    %edx,%ebx
  800b05:	c1 e3 08             	shl    $0x8,%ebx
  800b08:	89 d6                	mov    %edx,%esi
  800b0a:	c1 e6 18             	shl    $0x18,%esi
  800b0d:	89 d0                	mov    %edx,%eax
  800b0f:	c1 e0 10             	shl    $0x10,%eax
  800b12:	09 f0                	or     %esi,%eax
  800b14:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b16:	89 d8                	mov    %ebx,%eax
  800b18:	09 d0                	or     %edx,%eax
  800b1a:	c1 e9 02             	shr    $0x2,%ecx
  800b1d:	fc                   	cld    
  800b1e:	f3 ab                	rep stos %eax,%es:(%edi)
  800b20:	eb 06                	jmp    800b28 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b25:	fc                   	cld    
  800b26:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b28:	89 f8                	mov    %edi,%eax
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	8b 45 08             	mov    0x8(%ebp),%eax
  800b37:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b3a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b3d:	39 c6                	cmp    %eax,%esi
  800b3f:	73 35                	jae    800b76 <memmove+0x47>
  800b41:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b44:	39 d0                	cmp    %edx,%eax
  800b46:	73 2e                	jae    800b76 <memmove+0x47>
		s += n;
		d += n;
  800b48:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4b:	89 d6                	mov    %edx,%esi
  800b4d:	09 fe                	or     %edi,%esi
  800b4f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b55:	75 13                	jne    800b6a <memmove+0x3b>
  800b57:	f6 c1 03             	test   $0x3,%cl
  800b5a:	75 0e                	jne    800b6a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b5c:	83 ef 04             	sub    $0x4,%edi
  800b5f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b62:	c1 e9 02             	shr    $0x2,%ecx
  800b65:	fd                   	std    
  800b66:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b68:	eb 09                	jmp    800b73 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b6a:	83 ef 01             	sub    $0x1,%edi
  800b6d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b70:	fd                   	std    
  800b71:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b73:	fc                   	cld    
  800b74:	eb 1d                	jmp    800b93 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b76:	89 f2                	mov    %esi,%edx
  800b78:	09 c2                	or     %eax,%edx
  800b7a:	f6 c2 03             	test   $0x3,%dl
  800b7d:	75 0f                	jne    800b8e <memmove+0x5f>
  800b7f:	f6 c1 03             	test   $0x3,%cl
  800b82:	75 0a                	jne    800b8e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b84:	c1 e9 02             	shr    $0x2,%ecx
  800b87:	89 c7                	mov    %eax,%edi
  800b89:	fc                   	cld    
  800b8a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b8c:	eb 05                	jmp    800b93 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b8e:	89 c7                	mov    %eax,%edi
  800b90:	fc                   	cld    
  800b91:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b93:	5e                   	pop    %esi
  800b94:	5f                   	pop    %edi
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    

00800b97 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b9a:	ff 75 10             	pushl  0x10(%ebp)
  800b9d:	ff 75 0c             	pushl  0xc(%ebp)
  800ba0:	ff 75 08             	pushl  0x8(%ebp)
  800ba3:	e8 87 ff ff ff       	call   800b2f <memmove>
}
  800ba8:	c9                   	leave  
  800ba9:	c3                   	ret    

00800baa <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
  800baf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bb5:	89 c6                	mov    %eax,%esi
  800bb7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bba:	eb 1a                	jmp    800bd6 <memcmp+0x2c>
		if (*s1 != *s2)
  800bbc:	0f b6 08             	movzbl (%eax),%ecx
  800bbf:	0f b6 1a             	movzbl (%edx),%ebx
  800bc2:	38 d9                	cmp    %bl,%cl
  800bc4:	74 0a                	je     800bd0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bc6:	0f b6 c1             	movzbl %cl,%eax
  800bc9:	0f b6 db             	movzbl %bl,%ebx
  800bcc:	29 d8                	sub    %ebx,%eax
  800bce:	eb 0f                	jmp    800bdf <memcmp+0x35>
		s1++, s2++;
  800bd0:	83 c0 01             	add    $0x1,%eax
  800bd3:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bd6:	39 f0                	cmp    %esi,%eax
  800bd8:	75 e2                	jne    800bbc <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bda:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	53                   	push   %ebx
  800be7:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bea:	89 c1                	mov    %eax,%ecx
  800bec:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bef:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bf3:	eb 0a                	jmp    800bff <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf5:	0f b6 10             	movzbl (%eax),%edx
  800bf8:	39 da                	cmp    %ebx,%edx
  800bfa:	74 07                	je     800c03 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bfc:	83 c0 01             	add    $0x1,%eax
  800bff:	39 c8                	cmp    %ecx,%eax
  800c01:	72 f2                	jb     800bf5 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c03:	5b                   	pop    %ebx
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
  800c0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c12:	eb 03                	jmp    800c17 <strtol+0x11>
		s++;
  800c14:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c17:	0f b6 01             	movzbl (%ecx),%eax
  800c1a:	3c 20                	cmp    $0x20,%al
  800c1c:	74 f6                	je     800c14 <strtol+0xe>
  800c1e:	3c 09                	cmp    $0x9,%al
  800c20:	74 f2                	je     800c14 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c22:	3c 2b                	cmp    $0x2b,%al
  800c24:	75 0a                	jne    800c30 <strtol+0x2a>
		s++;
  800c26:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c29:	bf 00 00 00 00       	mov    $0x0,%edi
  800c2e:	eb 11                	jmp    800c41 <strtol+0x3b>
  800c30:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c35:	3c 2d                	cmp    $0x2d,%al
  800c37:	75 08                	jne    800c41 <strtol+0x3b>
		s++, neg = 1;
  800c39:	83 c1 01             	add    $0x1,%ecx
  800c3c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c41:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c47:	75 15                	jne    800c5e <strtol+0x58>
  800c49:	80 39 30             	cmpb   $0x30,(%ecx)
  800c4c:	75 10                	jne    800c5e <strtol+0x58>
  800c4e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c52:	75 7c                	jne    800cd0 <strtol+0xca>
		s += 2, base = 16;
  800c54:	83 c1 02             	add    $0x2,%ecx
  800c57:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c5c:	eb 16                	jmp    800c74 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c5e:	85 db                	test   %ebx,%ebx
  800c60:	75 12                	jne    800c74 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c62:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c67:	80 39 30             	cmpb   $0x30,(%ecx)
  800c6a:	75 08                	jne    800c74 <strtol+0x6e>
		s++, base = 8;
  800c6c:	83 c1 01             	add    $0x1,%ecx
  800c6f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c74:	b8 00 00 00 00       	mov    $0x0,%eax
  800c79:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c7c:	0f b6 11             	movzbl (%ecx),%edx
  800c7f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c82:	89 f3                	mov    %esi,%ebx
  800c84:	80 fb 09             	cmp    $0x9,%bl
  800c87:	77 08                	ja     800c91 <strtol+0x8b>
			dig = *s - '0';
  800c89:	0f be d2             	movsbl %dl,%edx
  800c8c:	83 ea 30             	sub    $0x30,%edx
  800c8f:	eb 22                	jmp    800cb3 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c91:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c94:	89 f3                	mov    %esi,%ebx
  800c96:	80 fb 19             	cmp    $0x19,%bl
  800c99:	77 08                	ja     800ca3 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c9b:	0f be d2             	movsbl %dl,%edx
  800c9e:	83 ea 57             	sub    $0x57,%edx
  800ca1:	eb 10                	jmp    800cb3 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ca3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ca6:	89 f3                	mov    %esi,%ebx
  800ca8:	80 fb 19             	cmp    $0x19,%bl
  800cab:	77 16                	ja     800cc3 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cad:	0f be d2             	movsbl %dl,%edx
  800cb0:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cb3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cb6:	7d 0b                	jge    800cc3 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cb8:	83 c1 01             	add    $0x1,%ecx
  800cbb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cbf:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cc1:	eb b9                	jmp    800c7c <strtol+0x76>

	if (endptr)
  800cc3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cc7:	74 0d                	je     800cd6 <strtol+0xd0>
		*endptr = (char *) s;
  800cc9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ccc:	89 0e                	mov    %ecx,(%esi)
  800cce:	eb 06                	jmp    800cd6 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cd0:	85 db                	test   %ebx,%ebx
  800cd2:	74 98                	je     800c6c <strtol+0x66>
  800cd4:	eb 9e                	jmp    800c74 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cd6:	89 c2                	mov    %eax,%edx
  800cd8:	f7 da                	neg    %edx
  800cda:	85 ff                	test   %edi,%edi
  800cdc:	0f 45 c2             	cmovne %edx,%eax
}
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    
  800ce4:	66 90                	xchg   %ax,%ax
  800ce6:	66 90                	xchg   %ax,%ax
  800ce8:	66 90                	xchg   %ax,%ax
  800cea:	66 90                	xchg   %ax,%ax
  800cec:	66 90                	xchg   %ax,%ax
  800cee:	66 90                	xchg   %ax,%ax

00800cf0 <__udivdi3>:
  800cf0:	55                   	push   %ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
  800cf4:	83 ec 1c             	sub    $0x1c,%esp
  800cf7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800cfb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800cff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d07:	85 f6                	test   %esi,%esi
  800d09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d0d:	89 ca                	mov    %ecx,%edx
  800d0f:	89 f8                	mov    %edi,%eax
  800d11:	75 3d                	jne    800d50 <__udivdi3+0x60>
  800d13:	39 cf                	cmp    %ecx,%edi
  800d15:	0f 87 c5 00 00 00    	ja     800de0 <__udivdi3+0xf0>
  800d1b:	85 ff                	test   %edi,%edi
  800d1d:	89 fd                	mov    %edi,%ebp
  800d1f:	75 0b                	jne    800d2c <__udivdi3+0x3c>
  800d21:	b8 01 00 00 00       	mov    $0x1,%eax
  800d26:	31 d2                	xor    %edx,%edx
  800d28:	f7 f7                	div    %edi
  800d2a:	89 c5                	mov    %eax,%ebp
  800d2c:	89 c8                	mov    %ecx,%eax
  800d2e:	31 d2                	xor    %edx,%edx
  800d30:	f7 f5                	div    %ebp
  800d32:	89 c1                	mov    %eax,%ecx
  800d34:	89 d8                	mov    %ebx,%eax
  800d36:	89 cf                	mov    %ecx,%edi
  800d38:	f7 f5                	div    %ebp
  800d3a:	89 c3                	mov    %eax,%ebx
  800d3c:	89 d8                	mov    %ebx,%eax
  800d3e:	89 fa                	mov    %edi,%edx
  800d40:	83 c4 1c             	add    $0x1c,%esp
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    
  800d48:	90                   	nop
  800d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d50:	39 ce                	cmp    %ecx,%esi
  800d52:	77 74                	ja     800dc8 <__udivdi3+0xd8>
  800d54:	0f bd fe             	bsr    %esi,%edi
  800d57:	83 f7 1f             	xor    $0x1f,%edi
  800d5a:	0f 84 98 00 00 00    	je     800df8 <__udivdi3+0x108>
  800d60:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d65:	89 f9                	mov    %edi,%ecx
  800d67:	89 c5                	mov    %eax,%ebp
  800d69:	29 fb                	sub    %edi,%ebx
  800d6b:	d3 e6                	shl    %cl,%esi
  800d6d:	89 d9                	mov    %ebx,%ecx
  800d6f:	d3 ed                	shr    %cl,%ebp
  800d71:	89 f9                	mov    %edi,%ecx
  800d73:	d3 e0                	shl    %cl,%eax
  800d75:	09 ee                	or     %ebp,%esi
  800d77:	89 d9                	mov    %ebx,%ecx
  800d79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d7d:	89 d5                	mov    %edx,%ebp
  800d7f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d83:	d3 ed                	shr    %cl,%ebp
  800d85:	89 f9                	mov    %edi,%ecx
  800d87:	d3 e2                	shl    %cl,%edx
  800d89:	89 d9                	mov    %ebx,%ecx
  800d8b:	d3 e8                	shr    %cl,%eax
  800d8d:	09 c2                	or     %eax,%edx
  800d8f:	89 d0                	mov    %edx,%eax
  800d91:	89 ea                	mov    %ebp,%edx
  800d93:	f7 f6                	div    %esi
  800d95:	89 d5                	mov    %edx,%ebp
  800d97:	89 c3                	mov    %eax,%ebx
  800d99:	f7 64 24 0c          	mull   0xc(%esp)
  800d9d:	39 d5                	cmp    %edx,%ebp
  800d9f:	72 10                	jb     800db1 <__udivdi3+0xc1>
  800da1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800da5:	89 f9                	mov    %edi,%ecx
  800da7:	d3 e6                	shl    %cl,%esi
  800da9:	39 c6                	cmp    %eax,%esi
  800dab:	73 07                	jae    800db4 <__udivdi3+0xc4>
  800dad:	39 d5                	cmp    %edx,%ebp
  800daf:	75 03                	jne    800db4 <__udivdi3+0xc4>
  800db1:	83 eb 01             	sub    $0x1,%ebx
  800db4:	31 ff                	xor    %edi,%edi
  800db6:	89 d8                	mov    %ebx,%eax
  800db8:	89 fa                	mov    %edi,%edx
  800dba:	83 c4 1c             	add    $0x1c,%esp
  800dbd:	5b                   	pop    %ebx
  800dbe:	5e                   	pop    %esi
  800dbf:	5f                   	pop    %edi
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    
  800dc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800dc8:	31 ff                	xor    %edi,%edi
  800dca:	31 db                	xor    %ebx,%ebx
  800dcc:	89 d8                	mov    %ebx,%eax
  800dce:	89 fa                	mov    %edi,%edx
  800dd0:	83 c4 1c             	add    $0x1c,%esp
  800dd3:	5b                   	pop    %ebx
  800dd4:	5e                   	pop    %esi
  800dd5:	5f                   	pop    %edi
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    
  800dd8:	90                   	nop
  800dd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800de0:	89 d8                	mov    %ebx,%eax
  800de2:	f7 f7                	div    %edi
  800de4:	31 ff                	xor    %edi,%edi
  800de6:	89 c3                	mov    %eax,%ebx
  800de8:	89 d8                	mov    %ebx,%eax
  800dea:	89 fa                	mov    %edi,%edx
  800dec:	83 c4 1c             	add    $0x1c,%esp
  800def:	5b                   	pop    %ebx
  800df0:	5e                   	pop    %esi
  800df1:	5f                   	pop    %edi
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    
  800df4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800df8:	39 ce                	cmp    %ecx,%esi
  800dfa:	72 0c                	jb     800e08 <__udivdi3+0x118>
  800dfc:	31 db                	xor    %ebx,%ebx
  800dfe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e02:	0f 87 34 ff ff ff    	ja     800d3c <__udivdi3+0x4c>
  800e08:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e0d:	e9 2a ff ff ff       	jmp    800d3c <__udivdi3+0x4c>
  800e12:	66 90                	xchg   %ax,%ax
  800e14:	66 90                	xchg   %ax,%ax
  800e16:	66 90                	xchg   %ax,%ax
  800e18:	66 90                	xchg   %ax,%ax
  800e1a:	66 90                	xchg   %ax,%ax
  800e1c:	66 90                	xchg   %ax,%ax
  800e1e:	66 90                	xchg   %ax,%ax

00800e20 <__umoddi3>:
  800e20:	55                   	push   %ebp
  800e21:	57                   	push   %edi
  800e22:	56                   	push   %esi
  800e23:	53                   	push   %ebx
  800e24:	83 ec 1c             	sub    $0x1c,%esp
  800e27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e2b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e37:	85 d2                	test   %edx,%edx
  800e39:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e41:	89 f3                	mov    %esi,%ebx
  800e43:	89 3c 24             	mov    %edi,(%esp)
  800e46:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e4a:	75 1c                	jne    800e68 <__umoddi3+0x48>
  800e4c:	39 f7                	cmp    %esi,%edi
  800e4e:	76 50                	jbe    800ea0 <__umoddi3+0x80>
  800e50:	89 c8                	mov    %ecx,%eax
  800e52:	89 f2                	mov    %esi,%edx
  800e54:	f7 f7                	div    %edi
  800e56:	89 d0                	mov    %edx,%eax
  800e58:	31 d2                	xor    %edx,%edx
  800e5a:	83 c4 1c             	add    $0x1c,%esp
  800e5d:	5b                   	pop    %ebx
  800e5e:	5e                   	pop    %esi
  800e5f:	5f                   	pop    %edi
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    
  800e62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e68:	39 f2                	cmp    %esi,%edx
  800e6a:	89 d0                	mov    %edx,%eax
  800e6c:	77 52                	ja     800ec0 <__umoddi3+0xa0>
  800e6e:	0f bd ea             	bsr    %edx,%ebp
  800e71:	83 f5 1f             	xor    $0x1f,%ebp
  800e74:	75 5a                	jne    800ed0 <__umoddi3+0xb0>
  800e76:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800e7a:	0f 82 e0 00 00 00    	jb     800f60 <__umoddi3+0x140>
  800e80:	39 0c 24             	cmp    %ecx,(%esp)
  800e83:	0f 86 d7 00 00 00    	jbe    800f60 <__umoddi3+0x140>
  800e89:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e8d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e91:	83 c4 1c             	add    $0x1c,%esp
  800e94:	5b                   	pop    %ebx
  800e95:	5e                   	pop    %esi
  800e96:	5f                   	pop    %edi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    
  800e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ea0:	85 ff                	test   %edi,%edi
  800ea2:	89 fd                	mov    %edi,%ebp
  800ea4:	75 0b                	jne    800eb1 <__umoddi3+0x91>
  800ea6:	b8 01 00 00 00       	mov    $0x1,%eax
  800eab:	31 d2                	xor    %edx,%edx
  800ead:	f7 f7                	div    %edi
  800eaf:	89 c5                	mov    %eax,%ebp
  800eb1:	89 f0                	mov    %esi,%eax
  800eb3:	31 d2                	xor    %edx,%edx
  800eb5:	f7 f5                	div    %ebp
  800eb7:	89 c8                	mov    %ecx,%eax
  800eb9:	f7 f5                	div    %ebp
  800ebb:	89 d0                	mov    %edx,%eax
  800ebd:	eb 99                	jmp    800e58 <__umoddi3+0x38>
  800ebf:	90                   	nop
  800ec0:	89 c8                	mov    %ecx,%eax
  800ec2:	89 f2                	mov    %esi,%edx
  800ec4:	83 c4 1c             	add    $0x1c,%esp
  800ec7:	5b                   	pop    %ebx
  800ec8:	5e                   	pop    %esi
  800ec9:	5f                   	pop    %edi
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    
  800ecc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	8b 34 24             	mov    (%esp),%esi
  800ed3:	bf 20 00 00 00       	mov    $0x20,%edi
  800ed8:	89 e9                	mov    %ebp,%ecx
  800eda:	29 ef                	sub    %ebp,%edi
  800edc:	d3 e0                	shl    %cl,%eax
  800ede:	89 f9                	mov    %edi,%ecx
  800ee0:	89 f2                	mov    %esi,%edx
  800ee2:	d3 ea                	shr    %cl,%edx
  800ee4:	89 e9                	mov    %ebp,%ecx
  800ee6:	09 c2                	or     %eax,%edx
  800ee8:	89 d8                	mov    %ebx,%eax
  800eea:	89 14 24             	mov    %edx,(%esp)
  800eed:	89 f2                	mov    %esi,%edx
  800eef:	d3 e2                	shl    %cl,%edx
  800ef1:	89 f9                	mov    %edi,%ecx
  800ef3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ef7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800efb:	d3 e8                	shr    %cl,%eax
  800efd:	89 e9                	mov    %ebp,%ecx
  800eff:	89 c6                	mov    %eax,%esi
  800f01:	d3 e3                	shl    %cl,%ebx
  800f03:	89 f9                	mov    %edi,%ecx
  800f05:	89 d0                	mov    %edx,%eax
  800f07:	d3 e8                	shr    %cl,%eax
  800f09:	89 e9                	mov    %ebp,%ecx
  800f0b:	09 d8                	or     %ebx,%eax
  800f0d:	89 d3                	mov    %edx,%ebx
  800f0f:	89 f2                	mov    %esi,%edx
  800f11:	f7 34 24             	divl   (%esp)
  800f14:	89 d6                	mov    %edx,%esi
  800f16:	d3 e3                	shl    %cl,%ebx
  800f18:	f7 64 24 04          	mull   0x4(%esp)
  800f1c:	39 d6                	cmp    %edx,%esi
  800f1e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f22:	89 d1                	mov    %edx,%ecx
  800f24:	89 c3                	mov    %eax,%ebx
  800f26:	72 08                	jb     800f30 <__umoddi3+0x110>
  800f28:	75 11                	jne    800f3b <__umoddi3+0x11b>
  800f2a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f2e:	73 0b                	jae    800f3b <__umoddi3+0x11b>
  800f30:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f34:	1b 14 24             	sbb    (%esp),%edx
  800f37:	89 d1                	mov    %edx,%ecx
  800f39:	89 c3                	mov    %eax,%ebx
  800f3b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f3f:	29 da                	sub    %ebx,%edx
  800f41:	19 ce                	sbb    %ecx,%esi
  800f43:	89 f9                	mov    %edi,%ecx
  800f45:	89 f0                	mov    %esi,%eax
  800f47:	d3 e0                	shl    %cl,%eax
  800f49:	89 e9                	mov    %ebp,%ecx
  800f4b:	d3 ea                	shr    %cl,%edx
  800f4d:	89 e9                	mov    %ebp,%ecx
  800f4f:	d3 ee                	shr    %cl,%esi
  800f51:	09 d0                	or     %edx,%eax
  800f53:	89 f2                	mov    %esi,%edx
  800f55:	83 c4 1c             	add    $0x1c,%esp
  800f58:	5b                   	pop    %ebx
  800f59:	5e                   	pop    %esi
  800f5a:	5f                   	pop    %edi
  800f5b:	5d                   	pop    %ebp
  800f5c:	c3                   	ret    
  800f5d:	8d 76 00             	lea    0x0(%esi),%esi
  800f60:	29 f9                	sub    %edi,%ecx
  800f62:	19 d6                	sbb    %edx,%esi
  800f64:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f6c:	e9 18 ff ff ff       	jmp    800e89 <__umoddi3+0x69>
