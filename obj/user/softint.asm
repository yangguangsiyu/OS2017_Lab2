
obj/user/softint：     文件格式 elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800045:	e8 c6 00 00 00       	call   800110 <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800057:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005c:	85 db                	test   %ebx,%ebx
  80005e:	7e 07                	jle    800067 <libmain+0x2d>
		binaryname = argv[0];
  800060:	8b 06                	mov    (%esi),%eax
  800062:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800067:	83 ec 08             	sub    $0x8,%esp
  80006a:	56                   	push   %esi
  80006b:	53                   	push   %ebx
  80006c:	e8 c2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800071:	e8 0a 00 00 00       	call   800080 <exit>
}
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007c:	5b                   	pop    %ebx
  80007d:	5e                   	pop    %esi
  80007e:	5d                   	pop    %ebp
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800086:	6a 00                	push   $0x0
  800088:	e8 42 00 00 00       	call   8000cf <sys_env_destroy>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	c9                   	leave  
  800091:	c3                   	ret    

00800092 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	57                   	push   %edi
  800096:	56                   	push   %esi
  800097:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800098:	b8 00 00 00 00       	mov    $0x0,%eax
  80009d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a3:	89 c3                	mov    %eax,%ebx
  8000a5:	89 c7                	mov    %eax,%edi
  8000a7:	89 c6                	mov    %eax,%esi
  8000a9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ab:	5b                   	pop    %ebx
  8000ac:	5e                   	pop    %esi
  8000ad:	5f                   	pop    %edi
  8000ae:	5d                   	pop    %ebp
  8000af:	c3                   	ret    

008000b0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c0:	89 d1                	mov    %edx,%ecx
  8000c2:	89 d3                	mov    %edx,%ebx
  8000c4:	89 d7                	mov    %edx,%edi
  8000c6:	89 d6                	mov    %edx,%esi
  8000c8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ca:	5b                   	pop    %ebx
  8000cb:	5e                   	pop    %esi
  8000cc:	5f                   	pop    %edi
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    

008000cf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	57                   	push   %edi
  8000d3:	56                   	push   %esi
  8000d4:	53                   	push   %ebx
  8000d5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000dd:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e5:	89 cb                	mov    %ecx,%ebx
  8000e7:	89 cf                	mov    %ecx,%edi
  8000e9:	89 ce                	mov    %ecx,%esi
  8000eb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	7e 17                	jle    800108 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f1:	83 ec 0c             	sub    $0xc,%esp
  8000f4:	50                   	push   %eax
  8000f5:	6a 03                	push   $0x3
  8000f7:	68 6a 0f 80 00       	push   $0x800f6a
  8000fc:	6a 23                	push   $0x23
  8000fe:	68 87 0f 80 00       	push   $0x800f87
  800103:	e8 f5 01 00 00       	call   8002fd <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800108:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010b:	5b                   	pop    %ebx
  80010c:	5e                   	pop    %esi
  80010d:	5f                   	pop    %edi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	57                   	push   %edi
  800114:	56                   	push   %esi
  800115:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800116:	ba 00 00 00 00       	mov    $0x0,%edx
  80011b:	b8 02 00 00 00       	mov    $0x2,%eax
  800120:	89 d1                	mov    %edx,%ecx
  800122:	89 d3                	mov    %edx,%ebx
  800124:	89 d7                	mov    %edx,%edi
  800126:	89 d6                	mov    %edx,%esi
  800128:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	5f                   	pop    %edi
  80012d:	5d                   	pop    %ebp
  80012e:	c3                   	ret    

0080012f <sys_yield>:

void
sys_yield(void)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	57                   	push   %edi
  800133:	56                   	push   %esi
  800134:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800135:	ba 00 00 00 00       	mov    $0x0,%edx
  80013a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80013f:	89 d1                	mov    %edx,%ecx
  800141:	89 d3                	mov    %edx,%ebx
  800143:	89 d7                	mov    %edx,%edi
  800145:	89 d6                	mov    %edx,%esi
  800147:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800149:	5b                   	pop    %ebx
  80014a:	5e                   	pop    %esi
  80014b:	5f                   	pop    %edi
  80014c:	5d                   	pop    %ebp
  80014d:	c3                   	ret    

0080014e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	57                   	push   %edi
  800152:	56                   	push   %esi
  800153:	53                   	push   %ebx
  800154:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800157:	be 00 00 00 00       	mov    $0x0,%esi
  80015c:	b8 04 00 00 00       	mov    $0x4,%eax
  800161:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800164:	8b 55 08             	mov    0x8(%ebp),%edx
  800167:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80016a:	89 f7                	mov    %esi,%edi
  80016c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80016e:	85 c0                	test   %eax,%eax
  800170:	7e 17                	jle    800189 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800172:	83 ec 0c             	sub    $0xc,%esp
  800175:	50                   	push   %eax
  800176:	6a 04                	push   $0x4
  800178:	68 6a 0f 80 00       	push   $0x800f6a
  80017d:	6a 23                	push   $0x23
  80017f:	68 87 0f 80 00       	push   $0x800f87
  800184:	e8 74 01 00 00       	call   8002fd <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800189:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018c:	5b                   	pop    %ebx
  80018d:	5e                   	pop    %esi
  80018e:	5f                   	pop    %edi
  80018f:	5d                   	pop    %ebp
  800190:	c3                   	ret    

00800191 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	57                   	push   %edi
  800195:	56                   	push   %esi
  800196:	53                   	push   %ebx
  800197:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019a:	b8 05 00 00 00       	mov    $0x5,%eax
  80019f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ab:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001b0:	85 c0                	test   %eax,%eax
  8001b2:	7e 17                	jle    8001cb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	50                   	push   %eax
  8001b8:	6a 05                	push   $0x5
  8001ba:	68 6a 0f 80 00       	push   $0x800f6a
  8001bf:	6a 23                	push   $0x23
  8001c1:	68 87 0f 80 00       	push   $0x800f87
  8001c6:	e8 32 01 00 00       	call   8002fd <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ce:	5b                   	pop    %ebx
  8001cf:	5e                   	pop    %esi
  8001d0:	5f                   	pop    %edi
  8001d1:	5d                   	pop    %ebp
  8001d2:	c3                   	ret    

008001d3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	57                   	push   %edi
  8001d7:	56                   	push   %esi
  8001d8:	53                   	push   %ebx
  8001d9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e1:	b8 06 00 00 00       	mov    $0x6,%eax
  8001e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ec:	89 df                	mov    %ebx,%edi
  8001ee:	89 de                	mov    %ebx,%esi
  8001f0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f2:	85 c0                	test   %eax,%eax
  8001f4:	7e 17                	jle    80020d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f6:	83 ec 0c             	sub    $0xc,%esp
  8001f9:	50                   	push   %eax
  8001fa:	6a 06                	push   $0x6
  8001fc:	68 6a 0f 80 00       	push   $0x800f6a
  800201:	6a 23                	push   $0x23
  800203:	68 87 0f 80 00       	push   $0x800f87
  800208:	e8 f0 00 00 00       	call   8002fd <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80020d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800210:	5b                   	pop    %ebx
  800211:	5e                   	pop    %esi
  800212:	5f                   	pop    %edi
  800213:	5d                   	pop    %ebp
  800214:	c3                   	ret    

00800215 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	57                   	push   %edi
  800219:	56                   	push   %esi
  80021a:	53                   	push   %ebx
  80021b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80021e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800223:	b8 08 00 00 00       	mov    $0x8,%eax
  800228:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022b:	8b 55 08             	mov    0x8(%ebp),%edx
  80022e:	89 df                	mov    %ebx,%edi
  800230:	89 de                	mov    %ebx,%esi
  800232:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800234:	85 c0                	test   %eax,%eax
  800236:	7e 17                	jle    80024f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800238:	83 ec 0c             	sub    $0xc,%esp
  80023b:	50                   	push   %eax
  80023c:	6a 08                	push   $0x8
  80023e:	68 6a 0f 80 00       	push   $0x800f6a
  800243:	6a 23                	push   $0x23
  800245:	68 87 0f 80 00       	push   $0x800f87
  80024a:	e8 ae 00 00 00       	call   8002fd <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80024f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800252:	5b                   	pop    %ebx
  800253:	5e                   	pop    %esi
  800254:	5f                   	pop    %edi
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    

00800257 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	57                   	push   %edi
  80025b:	56                   	push   %esi
  80025c:	53                   	push   %ebx
  80025d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800260:	bb 00 00 00 00       	mov    $0x0,%ebx
  800265:	b8 09 00 00 00       	mov    $0x9,%eax
  80026a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026d:	8b 55 08             	mov    0x8(%ebp),%edx
  800270:	89 df                	mov    %ebx,%edi
  800272:	89 de                	mov    %ebx,%esi
  800274:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800276:	85 c0                	test   %eax,%eax
  800278:	7e 17                	jle    800291 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80027a:	83 ec 0c             	sub    $0xc,%esp
  80027d:	50                   	push   %eax
  80027e:	6a 09                	push   $0x9
  800280:	68 6a 0f 80 00       	push   $0x800f6a
  800285:	6a 23                	push   $0x23
  800287:	68 87 0f 80 00       	push   $0x800f87
  80028c:	e8 6c 00 00 00       	call   8002fd <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800291:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800294:	5b                   	pop    %ebx
  800295:	5e                   	pop    %esi
  800296:	5f                   	pop    %edi
  800297:	5d                   	pop    %ebp
  800298:	c3                   	ret    

00800299 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	57                   	push   %edi
  80029d:	56                   	push   %esi
  80029e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80029f:	be 00 00 00 00       	mov    $0x0,%esi
  8002a4:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8002af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002b2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002b7:	5b                   	pop    %ebx
  8002b8:	5e                   	pop    %esi
  8002b9:	5f                   	pop    %edi
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	57                   	push   %edi
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ca:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d2:	89 cb                	mov    %ecx,%ebx
  8002d4:	89 cf                	mov    %ecx,%edi
  8002d6:	89 ce                	mov    %ecx,%esi
  8002d8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7e 17                	jle    8002f5 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002de:	83 ec 0c             	sub    $0xc,%esp
  8002e1:	50                   	push   %eax
  8002e2:	6a 0c                	push   $0xc
  8002e4:	68 6a 0f 80 00       	push   $0x800f6a
  8002e9:	6a 23                	push   $0x23
  8002eb:	68 87 0f 80 00       	push   $0x800f87
  8002f0:	e8 08 00 00 00       	call   8002fd <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f8:	5b                   	pop    %ebx
  8002f9:	5e                   	pop    %esi
  8002fa:	5f                   	pop    %edi
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	56                   	push   %esi
  800301:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800302:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800305:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80030b:	e8 00 fe ff ff       	call   800110 <sys_getenvid>
  800310:	83 ec 0c             	sub    $0xc,%esp
  800313:	ff 75 0c             	pushl  0xc(%ebp)
  800316:	ff 75 08             	pushl  0x8(%ebp)
  800319:	56                   	push   %esi
  80031a:	50                   	push   %eax
  80031b:	68 98 0f 80 00       	push   $0x800f98
  800320:	e8 b1 00 00 00       	call   8003d6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800325:	83 c4 18             	add    $0x18,%esp
  800328:	53                   	push   %ebx
  800329:	ff 75 10             	pushl  0x10(%ebp)
  80032c:	e8 54 00 00 00       	call   800385 <vcprintf>
	cprintf("\n");
  800331:	c7 04 24 bc 0f 80 00 	movl   $0x800fbc,(%esp)
  800338:	e8 99 00 00 00       	call   8003d6 <cprintf>
  80033d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800340:	cc                   	int3   
  800341:	eb fd                	jmp    800340 <_panic+0x43>

00800343 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
  800346:	53                   	push   %ebx
  800347:	83 ec 04             	sub    $0x4,%esp
  80034a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80034d:	8b 13                	mov    (%ebx),%edx
  80034f:	8d 42 01             	lea    0x1(%edx),%eax
  800352:	89 03                	mov    %eax,(%ebx)
  800354:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800357:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80035b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800360:	75 1a                	jne    80037c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800362:	83 ec 08             	sub    $0x8,%esp
  800365:	68 ff 00 00 00       	push   $0xff
  80036a:	8d 43 08             	lea    0x8(%ebx),%eax
  80036d:	50                   	push   %eax
  80036e:	e8 1f fd ff ff       	call   800092 <sys_cputs>
		b->idx = 0;
  800373:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800379:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80037c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800380:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800383:	c9                   	leave  
  800384:	c3                   	ret    

00800385 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80038e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800395:	00 00 00 
	b.cnt = 0;
  800398:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80039f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003a2:	ff 75 0c             	pushl  0xc(%ebp)
  8003a5:	ff 75 08             	pushl  0x8(%ebp)
  8003a8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ae:	50                   	push   %eax
  8003af:	68 43 03 80 00       	push   $0x800343
  8003b4:	e8 54 01 00 00       	call   80050d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003b9:	83 c4 08             	add    $0x8,%esp
  8003bc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003c2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003c8:	50                   	push   %eax
  8003c9:	e8 c4 fc ff ff       	call   800092 <sys_cputs>

	return b.cnt;
}
  8003ce:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003d4:	c9                   	leave  
  8003d5:	c3                   	ret    

008003d6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003d6:	55                   	push   %ebp
  8003d7:	89 e5                	mov    %esp,%ebp
  8003d9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003dc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003df:	50                   	push   %eax
  8003e0:	ff 75 08             	pushl  0x8(%ebp)
  8003e3:	e8 9d ff ff ff       	call   800385 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003e8:	c9                   	leave  
  8003e9:	c3                   	ret    

008003ea <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ea:	55                   	push   %ebp
  8003eb:	89 e5                	mov    %esp,%ebp
  8003ed:	57                   	push   %edi
  8003ee:	56                   	push   %esi
  8003ef:	53                   	push   %ebx
  8003f0:	83 ec 1c             	sub    $0x1c,%esp
  8003f3:	89 c7                	mov    %eax,%edi
  8003f5:	89 d6                	mov    %edx,%esi
  8003f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800400:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800403:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800406:	bb 00 00 00 00       	mov    $0x0,%ebx
  80040b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80040e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800411:	39 d3                	cmp    %edx,%ebx
  800413:	72 05                	jb     80041a <printnum+0x30>
  800415:	39 45 10             	cmp    %eax,0x10(%ebp)
  800418:	77 45                	ja     80045f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80041a:	83 ec 0c             	sub    $0xc,%esp
  80041d:	ff 75 18             	pushl  0x18(%ebp)
  800420:	8b 45 14             	mov    0x14(%ebp),%eax
  800423:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800426:	53                   	push   %ebx
  800427:	ff 75 10             	pushl  0x10(%ebp)
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800430:	ff 75 e0             	pushl  -0x20(%ebp)
  800433:	ff 75 dc             	pushl  -0x24(%ebp)
  800436:	ff 75 d8             	pushl  -0x28(%ebp)
  800439:	e8 82 08 00 00       	call   800cc0 <__udivdi3>
  80043e:	83 c4 18             	add    $0x18,%esp
  800441:	52                   	push   %edx
  800442:	50                   	push   %eax
  800443:	89 f2                	mov    %esi,%edx
  800445:	89 f8                	mov    %edi,%eax
  800447:	e8 9e ff ff ff       	call   8003ea <printnum>
  80044c:	83 c4 20             	add    $0x20,%esp
  80044f:	eb 18                	jmp    800469 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	56                   	push   %esi
  800455:	ff 75 18             	pushl  0x18(%ebp)
  800458:	ff d7                	call   *%edi
  80045a:	83 c4 10             	add    $0x10,%esp
  80045d:	eb 03                	jmp    800462 <printnum+0x78>
  80045f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800462:	83 eb 01             	sub    $0x1,%ebx
  800465:	85 db                	test   %ebx,%ebx
  800467:	7f e8                	jg     800451 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800469:	83 ec 08             	sub    $0x8,%esp
  80046c:	56                   	push   %esi
  80046d:	83 ec 04             	sub    $0x4,%esp
  800470:	ff 75 e4             	pushl  -0x1c(%ebp)
  800473:	ff 75 e0             	pushl  -0x20(%ebp)
  800476:	ff 75 dc             	pushl  -0x24(%ebp)
  800479:	ff 75 d8             	pushl  -0x28(%ebp)
  80047c:	e8 6f 09 00 00       	call   800df0 <__umoddi3>
  800481:	83 c4 14             	add    $0x14,%esp
  800484:	0f be 80 be 0f 80 00 	movsbl 0x800fbe(%eax),%eax
  80048b:	50                   	push   %eax
  80048c:	ff d7                	call   *%edi
}
  80048e:	83 c4 10             	add    $0x10,%esp
  800491:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800494:	5b                   	pop    %ebx
  800495:	5e                   	pop    %esi
  800496:	5f                   	pop    %edi
  800497:	5d                   	pop    %ebp
  800498:	c3                   	ret    

00800499 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800499:	55                   	push   %ebp
  80049a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80049c:	83 fa 01             	cmp    $0x1,%edx
  80049f:	7e 0e                	jle    8004af <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004a1:	8b 10                	mov    (%eax),%edx
  8004a3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004a6:	89 08                	mov    %ecx,(%eax)
  8004a8:	8b 02                	mov    (%edx),%eax
  8004aa:	8b 52 04             	mov    0x4(%edx),%edx
  8004ad:	eb 22                	jmp    8004d1 <getuint+0x38>
	else if (lflag)
  8004af:	85 d2                	test   %edx,%edx
  8004b1:	74 10                	je     8004c3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004b3:	8b 10                	mov    (%eax),%edx
  8004b5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004b8:	89 08                	mov    %ecx,(%eax)
  8004ba:	8b 02                	mov    (%edx),%eax
  8004bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c1:	eb 0e                	jmp    8004d1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004c3:	8b 10                	mov    (%eax),%edx
  8004c5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c8:	89 08                	mov    %ecx,(%eax)
  8004ca:	8b 02                	mov    (%edx),%eax
  8004cc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004d1:	5d                   	pop    %ebp
  8004d2:	c3                   	ret    

008004d3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004d3:	55                   	push   %ebp
  8004d4:	89 e5                	mov    %esp,%ebp
  8004d6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004d9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004dd:	8b 10                	mov    (%eax),%edx
  8004df:	3b 50 04             	cmp    0x4(%eax),%edx
  8004e2:	73 0a                	jae    8004ee <sprintputch+0x1b>
		*b->buf++ = ch;
  8004e4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004e7:	89 08                	mov    %ecx,(%eax)
  8004e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ec:	88 02                	mov    %al,(%edx)
}
  8004ee:	5d                   	pop    %ebp
  8004ef:	c3                   	ret    

008004f0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
  8004f3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004f6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f9:	50                   	push   %eax
  8004fa:	ff 75 10             	pushl  0x10(%ebp)
  8004fd:	ff 75 0c             	pushl  0xc(%ebp)
  800500:	ff 75 08             	pushl  0x8(%ebp)
  800503:	e8 05 00 00 00       	call   80050d <vprintfmt>
	va_end(ap);
}
  800508:	83 c4 10             	add    $0x10,%esp
  80050b:	c9                   	leave  
  80050c:	c3                   	ret    

0080050d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80050d:	55                   	push   %ebp
  80050e:	89 e5                	mov    %esp,%ebp
  800510:	57                   	push   %edi
  800511:	56                   	push   %esi
  800512:	53                   	push   %ebx
  800513:	83 ec 2c             	sub    $0x2c,%esp
  800516:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
  800519:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800520:	eb 17                	jmp    800539 <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800522:	85 c0                	test   %eax,%eax
  800524:	0f 84 9f 03 00 00    	je     8008c9 <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
  80052a:	83 ec 08             	sub    $0x8,%esp
  80052d:	ff 75 0c             	pushl  0xc(%ebp)
  800530:	50                   	push   %eax
  800531:	ff 55 08             	call   *0x8(%ebp)
  800534:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800537:	89 f3                	mov    %esi,%ebx
  800539:	8d 73 01             	lea    0x1(%ebx),%esi
  80053c:	0f b6 03             	movzbl (%ebx),%eax
  80053f:	83 f8 25             	cmp    $0x25,%eax
  800542:	75 de                	jne    800522 <vprintfmt+0x15>
  800544:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800548:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80054f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800554:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80055b:	ba 00 00 00 00       	mov    $0x0,%edx
  800560:	eb 06                	jmp    800568 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800562:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800564:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800568:	8d 5e 01             	lea    0x1(%esi),%ebx
  80056b:	0f b6 06             	movzbl (%esi),%eax
  80056e:	0f b6 c8             	movzbl %al,%ecx
  800571:	83 e8 23             	sub    $0x23,%eax
  800574:	3c 55                	cmp    $0x55,%al
  800576:	0f 87 2d 03 00 00    	ja     8008a9 <vprintfmt+0x39c>
  80057c:	0f b6 c0             	movzbl %al,%eax
  80057f:	ff 24 85 80 10 80 00 	jmp    *0x801080(,%eax,4)
  800586:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800588:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80058c:	eb da                	jmp    800568 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058e:	89 de                	mov    %ebx,%esi
  800590:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800595:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  800598:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  80059c:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  80059f:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8005a2:	83 f8 09             	cmp    $0x9,%eax
  8005a5:	77 33                	ja     8005da <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005a7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005aa:	eb e9                	jmp    800595 <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8d 48 04             	lea    0x4(%eax),%ecx
  8005b2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005b5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005b9:	eb 1f                	jmp    8005da <vprintfmt+0xcd>
  8005bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005be:	85 c0                	test   %eax,%eax
  8005c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c5:	0f 49 c8             	cmovns %eax,%ecx
  8005c8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cb:	89 de                	mov    %ebx,%esi
  8005cd:	eb 99                	jmp    800568 <vprintfmt+0x5b>
  8005cf:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005d1:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  8005d8:	eb 8e                	jmp    800568 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8005da:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005de:	79 88                	jns    800568 <vprintfmt+0x5b>
				width = precision, precision = -1;
  8005e0:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8005e3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8005e8:	e9 7b ff ff ff       	jmp    800568 <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005ed:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f0:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005f2:	e9 71 ff ff ff       	jmp    800568 <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8d 50 04             	lea    0x4(%eax),%edx
  8005fd:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	ff 75 0c             	pushl  0xc(%ebp)
  800606:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800609:	03 08                	add    (%eax),%ecx
  80060b:	51                   	push   %ecx
  80060c:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
  80060f:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
  800612:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
  800619:	e9 1b ff ff ff       	jmp    800539 <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
  80061e:	8b 45 14             	mov    0x14(%ebp),%eax
  800621:	8d 48 04             	lea    0x4(%eax),%ecx
  800624:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800627:	8b 00                	mov    (%eax),%eax
  800629:	83 f8 02             	cmp    $0x2,%eax
  80062c:	74 1a                	je     800648 <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062e:	89 de                	mov    %ebx,%esi
  800630:	83 f8 04             	cmp    $0x4,%eax
  800633:	b8 00 00 00 00       	mov    $0x0,%eax
  800638:	b9 00 04 00 00       	mov    $0x400,%ecx
  80063d:	0f 44 c1             	cmove  %ecx,%eax
  800640:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800643:	e9 20 ff ff ff       	jmp    800568 <vprintfmt+0x5b>
  800648:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
  80064a:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
  800651:	e9 12 ff ff ff       	jmp    800568 <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8d 50 04             	lea    0x4(%eax),%edx
  80065c:	89 55 14             	mov    %edx,0x14(%ebp)
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	99                   	cltd   
  800662:	31 d0                	xor    %edx,%eax
  800664:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800666:	83 f8 09             	cmp    $0x9,%eax
  800669:	7f 0b                	jg     800676 <vprintfmt+0x169>
  80066b:	8b 14 85 e0 11 80 00 	mov    0x8011e0(,%eax,4),%edx
  800672:	85 d2                	test   %edx,%edx
  800674:	75 19                	jne    80068f <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800676:	50                   	push   %eax
  800677:	68 d6 0f 80 00       	push   $0x800fd6
  80067c:	ff 75 0c             	pushl  0xc(%ebp)
  80067f:	ff 75 08             	pushl  0x8(%ebp)
  800682:	e8 69 fe ff ff       	call   8004f0 <printfmt>
  800687:	83 c4 10             	add    $0x10,%esp
  80068a:	e9 aa fe ff ff       	jmp    800539 <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  80068f:	52                   	push   %edx
  800690:	68 df 0f 80 00       	push   $0x800fdf
  800695:	ff 75 0c             	pushl  0xc(%ebp)
  800698:	ff 75 08             	pushl  0x8(%ebp)
  80069b:	e8 50 fe ff ff       	call   8004f0 <printfmt>
  8006a0:	83 c4 10             	add    $0x10,%esp
  8006a3:	e9 91 fe ff ff       	jmp    800539 <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8d 50 04             	lea    0x4(%eax),%edx
  8006ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006b3:	85 f6                	test   %esi,%esi
  8006b5:	b8 cf 0f 80 00       	mov    $0x800fcf,%eax
  8006ba:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006bd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006c1:	0f 8e 93 00 00 00    	jle    80075a <vprintfmt+0x24d>
  8006c7:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8006cb:	0f 84 91 00 00 00    	je     800762 <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d1:	83 ec 08             	sub    $0x8,%esp
  8006d4:	57                   	push   %edi
  8006d5:	56                   	push   %esi
  8006d6:	e8 76 02 00 00       	call   800951 <strnlen>
  8006db:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006de:	29 c1                	sub    %eax,%ecx
  8006e0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006e3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006e6:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8006ea:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006ed:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006f0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8006f3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006f6:	89 cb                	mov    %ecx,%ebx
  8006f8:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fa:	eb 0e                	jmp    80070a <vprintfmt+0x1fd>
					putch(padc, putdat);
  8006fc:	83 ec 08             	sub    $0x8,%esp
  8006ff:	56                   	push   %esi
  800700:	57                   	push   %edi
  800701:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800704:	83 eb 01             	sub    $0x1,%ebx
  800707:	83 c4 10             	add    $0x10,%esp
  80070a:	85 db                	test   %ebx,%ebx
  80070c:	7f ee                	jg     8006fc <vprintfmt+0x1ef>
  80070e:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800711:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800714:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800717:	85 c9                	test   %ecx,%ecx
  800719:	b8 00 00 00 00       	mov    $0x0,%eax
  80071e:	0f 49 c1             	cmovns %ecx,%eax
  800721:	29 c1                	sub    %eax,%ecx
  800723:	89 cb                	mov    %ecx,%ebx
  800725:	eb 41                	jmp    800768 <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800727:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80072b:	74 1b                	je     800748 <vprintfmt+0x23b>
  80072d:	0f be c0             	movsbl %al,%eax
  800730:	83 e8 20             	sub    $0x20,%eax
  800733:	83 f8 5e             	cmp    $0x5e,%eax
  800736:	76 10                	jbe    800748 <vprintfmt+0x23b>
					putch('?', putdat);
  800738:	83 ec 08             	sub    $0x8,%esp
  80073b:	ff 75 0c             	pushl  0xc(%ebp)
  80073e:	6a 3f                	push   $0x3f
  800740:	ff 55 08             	call   *0x8(%ebp)
  800743:	83 c4 10             	add    $0x10,%esp
  800746:	eb 0d                	jmp    800755 <vprintfmt+0x248>
				else
					putch(ch, putdat);
  800748:	83 ec 08             	sub    $0x8,%esp
  80074b:	ff 75 0c             	pushl  0xc(%ebp)
  80074e:	52                   	push   %edx
  80074f:	ff 55 08             	call   *0x8(%ebp)
  800752:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800755:	83 eb 01             	sub    $0x1,%ebx
  800758:	eb 0e                	jmp    800768 <vprintfmt+0x25b>
  80075a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80075d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800760:	eb 06                	jmp    800768 <vprintfmt+0x25b>
  800762:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800765:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800768:	83 c6 01             	add    $0x1,%esi
  80076b:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80076f:	0f be d0             	movsbl %al,%edx
  800772:	85 d2                	test   %edx,%edx
  800774:	74 25                	je     80079b <vprintfmt+0x28e>
  800776:	85 ff                	test   %edi,%edi
  800778:	78 ad                	js     800727 <vprintfmt+0x21a>
  80077a:	83 ef 01             	sub    $0x1,%edi
  80077d:	79 a8                	jns    800727 <vprintfmt+0x21a>
  80077f:	89 d8                	mov    %ebx,%eax
  800781:	8b 75 08             	mov    0x8(%ebp),%esi
  800784:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800787:	89 c3                	mov    %eax,%ebx
  800789:	eb 16                	jmp    8007a1 <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80078b:	83 ec 08             	sub    $0x8,%esp
  80078e:	57                   	push   %edi
  80078f:	6a 20                	push   $0x20
  800791:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800793:	83 eb 01             	sub    $0x1,%ebx
  800796:	83 c4 10             	add    $0x10,%esp
  800799:	eb 06                	jmp    8007a1 <vprintfmt+0x294>
  80079b:	8b 75 08             	mov    0x8(%ebp),%esi
  80079e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8007a1:	85 db                	test   %ebx,%ebx
  8007a3:	7f e6                	jg     80078b <vprintfmt+0x27e>
  8007a5:	89 75 08             	mov    %esi,0x8(%ebp)
  8007a8:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8007ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007ae:	e9 86 fd ff ff       	jmp    800539 <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007b3:	83 fa 01             	cmp    $0x1,%edx
  8007b6:	7e 10                	jle    8007c8 <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
  8007b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bb:	8d 50 08             	lea    0x8(%eax),%edx
  8007be:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c1:	8b 30                	mov    (%eax),%esi
  8007c3:	8b 78 04             	mov    0x4(%eax),%edi
  8007c6:	eb 26                	jmp    8007ee <vprintfmt+0x2e1>
	else if (lflag)
  8007c8:	85 d2                	test   %edx,%edx
  8007ca:	74 12                	je     8007de <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  8007cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cf:	8d 50 04             	lea    0x4(%eax),%edx
  8007d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d5:	8b 30                	mov    (%eax),%esi
  8007d7:	89 f7                	mov    %esi,%edi
  8007d9:	c1 ff 1f             	sar    $0x1f,%edi
  8007dc:	eb 10                	jmp    8007ee <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
  8007de:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e1:	8d 50 04             	lea    0x4(%eax),%edx
  8007e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e7:	8b 30                	mov    (%eax),%esi
  8007e9:	89 f7                	mov    %esi,%edi
  8007eb:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007ee:	89 f0                	mov    %esi,%eax
  8007f0:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007f2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007f7:	85 ff                	test   %edi,%edi
  8007f9:	79 7b                	jns    800876 <vprintfmt+0x369>
				putch('-', putdat);
  8007fb:	83 ec 08             	sub    $0x8,%esp
  8007fe:	ff 75 0c             	pushl  0xc(%ebp)
  800801:	6a 2d                	push   $0x2d
  800803:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800806:	89 f0                	mov    %esi,%eax
  800808:	89 fa                	mov    %edi,%edx
  80080a:	f7 d8                	neg    %eax
  80080c:	83 d2 00             	adc    $0x0,%edx
  80080f:	f7 da                	neg    %edx
  800811:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800814:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800819:	eb 5b                	jmp    800876 <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80081b:	8d 45 14             	lea    0x14(%ebp),%eax
  80081e:	e8 76 fc ff ff       	call   800499 <getuint>
			base = 10;
  800823:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800828:	eb 4c                	jmp    800876 <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
  80082a:	8d 45 14             	lea    0x14(%ebp),%eax
  80082d:	e8 67 fc ff ff       	call   800499 <getuint>
            base = 8;
  800832:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800837:	eb 3d                	jmp    800876 <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
  800839:	83 ec 08             	sub    $0x8,%esp
  80083c:	ff 75 0c             	pushl  0xc(%ebp)
  80083f:	6a 30                	push   $0x30
  800841:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800844:	83 c4 08             	add    $0x8,%esp
  800847:	ff 75 0c             	pushl  0xc(%ebp)
  80084a:	6a 78                	push   $0x78
  80084c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80084f:	8b 45 14             	mov    0x14(%ebp),%eax
  800852:	8d 50 04             	lea    0x4(%eax),%edx
  800855:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800858:	8b 00                	mov    (%eax),%eax
  80085a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80085f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800862:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800867:	eb 0d                	jmp    800876 <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800869:	8d 45 14             	lea    0x14(%ebp),%eax
  80086c:	e8 28 fc ff ff       	call   800499 <getuint>
			base = 16;
  800871:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800876:	83 ec 0c             	sub    $0xc,%esp
  800879:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  80087d:	56                   	push   %esi
  80087e:	ff 75 e0             	pushl  -0x20(%ebp)
  800881:	51                   	push   %ecx
  800882:	52                   	push   %edx
  800883:	50                   	push   %eax
  800884:	8b 55 0c             	mov    0xc(%ebp),%edx
  800887:	8b 45 08             	mov    0x8(%ebp),%eax
  80088a:	e8 5b fb ff ff       	call   8003ea <printnum>
			break;
  80088f:	83 c4 20             	add    $0x20,%esp
  800892:	e9 a2 fc ff ff       	jmp    800539 <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800897:	83 ec 08             	sub    $0x8,%esp
  80089a:	ff 75 0c             	pushl  0xc(%ebp)
  80089d:	51                   	push   %ecx
  80089e:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008a1:	83 c4 10             	add    $0x10,%esp
  8008a4:	e9 90 fc ff ff       	jmp    800539 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008a9:	83 ec 08             	sub    $0x8,%esp
  8008ac:	ff 75 0c             	pushl  0xc(%ebp)
  8008af:	6a 25                	push   $0x25
  8008b1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	89 f3                	mov    %esi,%ebx
  8008b9:	eb 03                	jmp    8008be <vprintfmt+0x3b1>
  8008bb:	83 eb 01             	sub    $0x1,%ebx
  8008be:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8008c2:	75 f7                	jne    8008bb <vprintfmt+0x3ae>
  8008c4:	e9 70 fc ff ff       	jmp    800539 <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  8008c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008cc:	5b                   	pop    %ebx
  8008cd:	5e                   	pop    %esi
  8008ce:	5f                   	pop    %edi
  8008cf:	5d                   	pop    %ebp
  8008d0:	c3                   	ret    

008008d1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	83 ec 18             	sub    $0x18,%esp
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008e0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008e4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008ee:	85 c0                	test   %eax,%eax
  8008f0:	74 26                	je     800918 <vsnprintf+0x47>
  8008f2:	85 d2                	test   %edx,%edx
  8008f4:	7e 22                	jle    800918 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f6:	ff 75 14             	pushl  0x14(%ebp)
  8008f9:	ff 75 10             	pushl  0x10(%ebp)
  8008fc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ff:	50                   	push   %eax
  800900:	68 d3 04 80 00       	push   $0x8004d3
  800905:	e8 03 fc ff ff       	call   80050d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80090a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80090d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800910:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800913:	83 c4 10             	add    $0x10,%esp
  800916:	eb 05                	jmp    80091d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800918:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80091d:	c9                   	leave  
  80091e:	c3                   	ret    

0080091f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800925:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800928:	50                   	push   %eax
  800929:	ff 75 10             	pushl  0x10(%ebp)
  80092c:	ff 75 0c             	pushl  0xc(%ebp)
  80092f:	ff 75 08             	pushl  0x8(%ebp)
  800932:	e8 9a ff ff ff       	call   8008d1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800937:	c9                   	leave  
  800938:	c3                   	ret    

00800939 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80093f:	b8 00 00 00 00       	mov    $0x0,%eax
  800944:	eb 03                	jmp    800949 <strlen+0x10>
		n++;
  800946:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800949:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80094d:	75 f7                	jne    800946 <strlen+0xd>
		n++;
	return n;
}
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800957:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80095a:	ba 00 00 00 00       	mov    $0x0,%edx
  80095f:	eb 03                	jmp    800964 <strnlen+0x13>
		n++;
  800961:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800964:	39 c2                	cmp    %eax,%edx
  800966:	74 08                	je     800970 <strnlen+0x1f>
  800968:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80096c:	75 f3                	jne    800961 <strnlen+0x10>
  80096e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	53                   	push   %ebx
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80097c:	89 c2                	mov    %eax,%edx
  80097e:	83 c2 01             	add    $0x1,%edx
  800981:	83 c1 01             	add    $0x1,%ecx
  800984:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800988:	88 5a ff             	mov    %bl,-0x1(%edx)
  80098b:	84 db                	test   %bl,%bl
  80098d:	75 ef                	jne    80097e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80098f:	5b                   	pop    %ebx
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	53                   	push   %ebx
  800996:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800999:	53                   	push   %ebx
  80099a:	e8 9a ff ff ff       	call   800939 <strlen>
  80099f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009a2:	ff 75 0c             	pushl  0xc(%ebp)
  8009a5:	01 d8                	add    %ebx,%eax
  8009a7:	50                   	push   %eax
  8009a8:	e8 c5 ff ff ff       	call   800972 <strcpy>
	return dst;
}
  8009ad:	89 d8                	mov    %ebx,%eax
  8009af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009b2:	c9                   	leave  
  8009b3:	c3                   	ret    

008009b4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	56                   	push   %esi
  8009b8:	53                   	push   %ebx
  8009b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009bf:	89 f3                	mov    %esi,%ebx
  8009c1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c4:	89 f2                	mov    %esi,%edx
  8009c6:	eb 0f                	jmp    8009d7 <strncpy+0x23>
		*dst++ = *src;
  8009c8:	83 c2 01             	add    $0x1,%edx
  8009cb:	0f b6 01             	movzbl (%ecx),%eax
  8009ce:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009d1:	80 39 01             	cmpb   $0x1,(%ecx)
  8009d4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d7:	39 da                	cmp    %ebx,%edx
  8009d9:	75 ed                	jne    8009c8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009db:	89 f0                	mov    %esi,%eax
  8009dd:	5b                   	pop    %ebx
  8009de:	5e                   	pop    %esi
  8009df:	5d                   	pop    %ebp
  8009e0:	c3                   	ret    

008009e1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	56                   	push   %esi
  8009e5:	53                   	push   %ebx
  8009e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8009e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ec:	8b 55 10             	mov    0x10(%ebp),%edx
  8009ef:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009f1:	85 d2                	test   %edx,%edx
  8009f3:	74 21                	je     800a16 <strlcpy+0x35>
  8009f5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009f9:	89 f2                	mov    %esi,%edx
  8009fb:	eb 09                	jmp    800a06 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009fd:	83 c2 01             	add    $0x1,%edx
  800a00:	83 c1 01             	add    $0x1,%ecx
  800a03:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a06:	39 c2                	cmp    %eax,%edx
  800a08:	74 09                	je     800a13 <strlcpy+0x32>
  800a0a:	0f b6 19             	movzbl (%ecx),%ebx
  800a0d:	84 db                	test   %bl,%bl
  800a0f:	75 ec                	jne    8009fd <strlcpy+0x1c>
  800a11:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a13:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a16:	29 f0                	sub    %esi,%eax
}
  800a18:	5b                   	pop    %ebx
  800a19:	5e                   	pop    %esi
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a22:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a25:	eb 06                	jmp    800a2d <strcmp+0x11>
		p++, q++;
  800a27:	83 c1 01             	add    $0x1,%ecx
  800a2a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a2d:	0f b6 01             	movzbl (%ecx),%eax
  800a30:	84 c0                	test   %al,%al
  800a32:	74 04                	je     800a38 <strcmp+0x1c>
  800a34:	3a 02                	cmp    (%edx),%al
  800a36:	74 ef                	je     800a27 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a38:	0f b6 c0             	movzbl %al,%eax
  800a3b:	0f b6 12             	movzbl (%edx),%edx
  800a3e:	29 d0                	sub    %edx,%eax
}
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    

00800a42 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	53                   	push   %ebx
  800a46:	8b 45 08             	mov    0x8(%ebp),%eax
  800a49:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4c:	89 c3                	mov    %eax,%ebx
  800a4e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a51:	eb 06                	jmp    800a59 <strncmp+0x17>
		n--, p++, q++;
  800a53:	83 c0 01             	add    $0x1,%eax
  800a56:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a59:	39 d8                	cmp    %ebx,%eax
  800a5b:	74 15                	je     800a72 <strncmp+0x30>
  800a5d:	0f b6 08             	movzbl (%eax),%ecx
  800a60:	84 c9                	test   %cl,%cl
  800a62:	74 04                	je     800a68 <strncmp+0x26>
  800a64:	3a 0a                	cmp    (%edx),%cl
  800a66:	74 eb                	je     800a53 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a68:	0f b6 00             	movzbl (%eax),%eax
  800a6b:	0f b6 12             	movzbl (%edx),%edx
  800a6e:	29 d0                	sub    %edx,%eax
  800a70:	eb 05                	jmp    800a77 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a72:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a77:	5b                   	pop    %ebx
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a80:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a84:	eb 07                	jmp    800a8d <strchr+0x13>
		if (*s == c)
  800a86:	38 ca                	cmp    %cl,%dl
  800a88:	74 0f                	je     800a99 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a8a:	83 c0 01             	add    $0x1,%eax
  800a8d:	0f b6 10             	movzbl (%eax),%edx
  800a90:	84 d2                	test   %dl,%dl
  800a92:	75 f2                	jne    800a86 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a94:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa5:	eb 03                	jmp    800aaa <strfind+0xf>
  800aa7:	83 c0 01             	add    $0x1,%eax
  800aaa:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aad:	38 ca                	cmp    %cl,%dl
  800aaf:	74 04                	je     800ab5 <strfind+0x1a>
  800ab1:	84 d2                	test   %dl,%dl
  800ab3:	75 f2                	jne    800aa7 <strfind+0xc>
			break;
	return (char *) s;
}
  800ab5:	5d                   	pop    %ebp
  800ab6:	c3                   	ret    

00800ab7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	57                   	push   %edi
  800abb:	56                   	push   %esi
  800abc:	53                   	push   %ebx
  800abd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ac0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ac3:	85 c9                	test   %ecx,%ecx
  800ac5:	74 36                	je     800afd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ac7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800acd:	75 28                	jne    800af7 <memset+0x40>
  800acf:	f6 c1 03             	test   $0x3,%cl
  800ad2:	75 23                	jne    800af7 <memset+0x40>
		c &= 0xFF;
  800ad4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ad8:	89 d3                	mov    %edx,%ebx
  800ada:	c1 e3 08             	shl    $0x8,%ebx
  800add:	89 d6                	mov    %edx,%esi
  800adf:	c1 e6 18             	shl    $0x18,%esi
  800ae2:	89 d0                	mov    %edx,%eax
  800ae4:	c1 e0 10             	shl    $0x10,%eax
  800ae7:	09 f0                	or     %esi,%eax
  800ae9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800aeb:	89 d8                	mov    %ebx,%eax
  800aed:	09 d0                	or     %edx,%eax
  800aef:	c1 e9 02             	shr    $0x2,%ecx
  800af2:	fc                   	cld    
  800af3:	f3 ab                	rep stos %eax,%es:(%edi)
  800af5:	eb 06                	jmp    800afd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800af7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afa:	fc                   	cld    
  800afb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800afd:	89 f8                	mov    %edi,%eax
  800aff:	5b                   	pop    %ebx
  800b00:	5e                   	pop    %esi
  800b01:	5f                   	pop    %edi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b12:	39 c6                	cmp    %eax,%esi
  800b14:	73 35                	jae    800b4b <memmove+0x47>
  800b16:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b19:	39 d0                	cmp    %edx,%eax
  800b1b:	73 2e                	jae    800b4b <memmove+0x47>
		s += n;
		d += n;
  800b1d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b20:	89 d6                	mov    %edx,%esi
  800b22:	09 fe                	or     %edi,%esi
  800b24:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b2a:	75 13                	jne    800b3f <memmove+0x3b>
  800b2c:	f6 c1 03             	test   $0x3,%cl
  800b2f:	75 0e                	jne    800b3f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b31:	83 ef 04             	sub    $0x4,%edi
  800b34:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b37:	c1 e9 02             	shr    $0x2,%ecx
  800b3a:	fd                   	std    
  800b3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3d:	eb 09                	jmp    800b48 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b3f:	83 ef 01             	sub    $0x1,%edi
  800b42:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b45:	fd                   	std    
  800b46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b48:	fc                   	cld    
  800b49:	eb 1d                	jmp    800b68 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4b:	89 f2                	mov    %esi,%edx
  800b4d:	09 c2                	or     %eax,%edx
  800b4f:	f6 c2 03             	test   $0x3,%dl
  800b52:	75 0f                	jne    800b63 <memmove+0x5f>
  800b54:	f6 c1 03             	test   $0x3,%cl
  800b57:	75 0a                	jne    800b63 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b59:	c1 e9 02             	shr    $0x2,%ecx
  800b5c:	89 c7                	mov    %eax,%edi
  800b5e:	fc                   	cld    
  800b5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b61:	eb 05                	jmp    800b68 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b63:	89 c7                	mov    %eax,%edi
  800b65:	fc                   	cld    
  800b66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b68:	5e                   	pop    %esi
  800b69:	5f                   	pop    %edi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b6f:	ff 75 10             	pushl  0x10(%ebp)
  800b72:	ff 75 0c             	pushl  0xc(%ebp)
  800b75:	ff 75 08             	pushl  0x8(%ebp)
  800b78:	e8 87 ff ff ff       	call   800b04 <memmove>
}
  800b7d:	c9                   	leave  
  800b7e:	c3                   	ret    

00800b7f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
  800b84:	8b 45 08             	mov    0x8(%ebp),%eax
  800b87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b8a:	89 c6                	mov    %eax,%esi
  800b8c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8f:	eb 1a                	jmp    800bab <memcmp+0x2c>
		if (*s1 != *s2)
  800b91:	0f b6 08             	movzbl (%eax),%ecx
  800b94:	0f b6 1a             	movzbl (%edx),%ebx
  800b97:	38 d9                	cmp    %bl,%cl
  800b99:	74 0a                	je     800ba5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b9b:	0f b6 c1             	movzbl %cl,%eax
  800b9e:	0f b6 db             	movzbl %bl,%ebx
  800ba1:	29 d8                	sub    %ebx,%eax
  800ba3:	eb 0f                	jmp    800bb4 <memcmp+0x35>
		s1++, s2++;
  800ba5:	83 c0 01             	add    $0x1,%eax
  800ba8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bab:	39 f0                	cmp    %esi,%eax
  800bad:	75 e2                	jne    800b91 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800baf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	53                   	push   %ebx
  800bbc:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bbf:	89 c1                	mov    %eax,%ecx
  800bc1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bc8:	eb 0a                	jmp    800bd4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bca:	0f b6 10             	movzbl (%eax),%edx
  800bcd:	39 da                	cmp    %ebx,%edx
  800bcf:	74 07                	je     800bd8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bd1:	83 c0 01             	add    $0x1,%eax
  800bd4:	39 c8                	cmp    %ecx,%eax
  800bd6:	72 f2                	jb     800bca <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bd8:	5b                   	pop    %ebx
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
  800be1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be7:	eb 03                	jmp    800bec <strtol+0x11>
		s++;
  800be9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bec:	0f b6 01             	movzbl (%ecx),%eax
  800bef:	3c 20                	cmp    $0x20,%al
  800bf1:	74 f6                	je     800be9 <strtol+0xe>
  800bf3:	3c 09                	cmp    $0x9,%al
  800bf5:	74 f2                	je     800be9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bf7:	3c 2b                	cmp    $0x2b,%al
  800bf9:	75 0a                	jne    800c05 <strtol+0x2a>
		s++;
  800bfb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bfe:	bf 00 00 00 00       	mov    $0x0,%edi
  800c03:	eb 11                	jmp    800c16 <strtol+0x3b>
  800c05:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c0a:	3c 2d                	cmp    $0x2d,%al
  800c0c:	75 08                	jne    800c16 <strtol+0x3b>
		s++, neg = 1;
  800c0e:	83 c1 01             	add    $0x1,%ecx
  800c11:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c16:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c1c:	75 15                	jne    800c33 <strtol+0x58>
  800c1e:	80 39 30             	cmpb   $0x30,(%ecx)
  800c21:	75 10                	jne    800c33 <strtol+0x58>
  800c23:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c27:	75 7c                	jne    800ca5 <strtol+0xca>
		s += 2, base = 16;
  800c29:	83 c1 02             	add    $0x2,%ecx
  800c2c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c31:	eb 16                	jmp    800c49 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c33:	85 db                	test   %ebx,%ebx
  800c35:	75 12                	jne    800c49 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c37:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c3c:	80 39 30             	cmpb   $0x30,(%ecx)
  800c3f:	75 08                	jne    800c49 <strtol+0x6e>
		s++, base = 8;
  800c41:	83 c1 01             	add    $0x1,%ecx
  800c44:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c49:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c51:	0f b6 11             	movzbl (%ecx),%edx
  800c54:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c57:	89 f3                	mov    %esi,%ebx
  800c59:	80 fb 09             	cmp    $0x9,%bl
  800c5c:	77 08                	ja     800c66 <strtol+0x8b>
			dig = *s - '0';
  800c5e:	0f be d2             	movsbl %dl,%edx
  800c61:	83 ea 30             	sub    $0x30,%edx
  800c64:	eb 22                	jmp    800c88 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c66:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c69:	89 f3                	mov    %esi,%ebx
  800c6b:	80 fb 19             	cmp    $0x19,%bl
  800c6e:	77 08                	ja     800c78 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c70:	0f be d2             	movsbl %dl,%edx
  800c73:	83 ea 57             	sub    $0x57,%edx
  800c76:	eb 10                	jmp    800c88 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c78:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c7b:	89 f3                	mov    %esi,%ebx
  800c7d:	80 fb 19             	cmp    $0x19,%bl
  800c80:	77 16                	ja     800c98 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c82:	0f be d2             	movsbl %dl,%edx
  800c85:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c88:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c8b:	7d 0b                	jge    800c98 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c8d:	83 c1 01             	add    $0x1,%ecx
  800c90:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c94:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c96:	eb b9                	jmp    800c51 <strtol+0x76>

	if (endptr)
  800c98:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c9c:	74 0d                	je     800cab <strtol+0xd0>
		*endptr = (char *) s;
  800c9e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca1:	89 0e                	mov    %ecx,(%esi)
  800ca3:	eb 06                	jmp    800cab <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca5:	85 db                	test   %ebx,%ebx
  800ca7:	74 98                	je     800c41 <strtol+0x66>
  800ca9:	eb 9e                	jmp    800c49 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cab:	89 c2                	mov    %eax,%edx
  800cad:	f7 da                	neg    %edx
  800caf:	85 ff                	test   %edi,%edi
  800cb1:	0f 45 c2             	cmovne %edx,%eax
}
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5f                   	pop    %edi
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    
  800cb9:	66 90                	xchg   %ax,%ax
  800cbb:	66 90                	xchg   %ax,%ax
  800cbd:	66 90                	xchg   %ax,%ax
  800cbf:	90                   	nop

00800cc0 <__udivdi3>:
  800cc0:	55                   	push   %ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	53                   	push   %ebx
  800cc4:	83 ec 1c             	sub    $0x1c,%esp
  800cc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800ccb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800ccf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800cd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800cd7:	85 f6                	test   %esi,%esi
  800cd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800cdd:	89 ca                	mov    %ecx,%edx
  800cdf:	89 f8                	mov    %edi,%eax
  800ce1:	75 3d                	jne    800d20 <__udivdi3+0x60>
  800ce3:	39 cf                	cmp    %ecx,%edi
  800ce5:	0f 87 c5 00 00 00    	ja     800db0 <__udivdi3+0xf0>
  800ceb:	85 ff                	test   %edi,%edi
  800ced:	89 fd                	mov    %edi,%ebp
  800cef:	75 0b                	jne    800cfc <__udivdi3+0x3c>
  800cf1:	b8 01 00 00 00       	mov    $0x1,%eax
  800cf6:	31 d2                	xor    %edx,%edx
  800cf8:	f7 f7                	div    %edi
  800cfa:	89 c5                	mov    %eax,%ebp
  800cfc:	89 c8                	mov    %ecx,%eax
  800cfe:	31 d2                	xor    %edx,%edx
  800d00:	f7 f5                	div    %ebp
  800d02:	89 c1                	mov    %eax,%ecx
  800d04:	89 d8                	mov    %ebx,%eax
  800d06:	89 cf                	mov    %ecx,%edi
  800d08:	f7 f5                	div    %ebp
  800d0a:	89 c3                	mov    %eax,%ebx
  800d0c:	89 d8                	mov    %ebx,%eax
  800d0e:	89 fa                	mov    %edi,%edx
  800d10:	83 c4 1c             	add    $0x1c,%esp
  800d13:	5b                   	pop    %ebx
  800d14:	5e                   	pop    %esi
  800d15:	5f                   	pop    %edi
  800d16:	5d                   	pop    %ebp
  800d17:	c3                   	ret    
  800d18:	90                   	nop
  800d19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d20:	39 ce                	cmp    %ecx,%esi
  800d22:	77 74                	ja     800d98 <__udivdi3+0xd8>
  800d24:	0f bd fe             	bsr    %esi,%edi
  800d27:	83 f7 1f             	xor    $0x1f,%edi
  800d2a:	0f 84 98 00 00 00    	je     800dc8 <__udivdi3+0x108>
  800d30:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d35:	89 f9                	mov    %edi,%ecx
  800d37:	89 c5                	mov    %eax,%ebp
  800d39:	29 fb                	sub    %edi,%ebx
  800d3b:	d3 e6                	shl    %cl,%esi
  800d3d:	89 d9                	mov    %ebx,%ecx
  800d3f:	d3 ed                	shr    %cl,%ebp
  800d41:	89 f9                	mov    %edi,%ecx
  800d43:	d3 e0                	shl    %cl,%eax
  800d45:	09 ee                	or     %ebp,%esi
  800d47:	89 d9                	mov    %ebx,%ecx
  800d49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d4d:	89 d5                	mov    %edx,%ebp
  800d4f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d53:	d3 ed                	shr    %cl,%ebp
  800d55:	89 f9                	mov    %edi,%ecx
  800d57:	d3 e2                	shl    %cl,%edx
  800d59:	89 d9                	mov    %ebx,%ecx
  800d5b:	d3 e8                	shr    %cl,%eax
  800d5d:	09 c2                	or     %eax,%edx
  800d5f:	89 d0                	mov    %edx,%eax
  800d61:	89 ea                	mov    %ebp,%edx
  800d63:	f7 f6                	div    %esi
  800d65:	89 d5                	mov    %edx,%ebp
  800d67:	89 c3                	mov    %eax,%ebx
  800d69:	f7 64 24 0c          	mull   0xc(%esp)
  800d6d:	39 d5                	cmp    %edx,%ebp
  800d6f:	72 10                	jb     800d81 <__udivdi3+0xc1>
  800d71:	8b 74 24 08          	mov    0x8(%esp),%esi
  800d75:	89 f9                	mov    %edi,%ecx
  800d77:	d3 e6                	shl    %cl,%esi
  800d79:	39 c6                	cmp    %eax,%esi
  800d7b:	73 07                	jae    800d84 <__udivdi3+0xc4>
  800d7d:	39 d5                	cmp    %edx,%ebp
  800d7f:	75 03                	jne    800d84 <__udivdi3+0xc4>
  800d81:	83 eb 01             	sub    $0x1,%ebx
  800d84:	31 ff                	xor    %edi,%edi
  800d86:	89 d8                	mov    %ebx,%eax
  800d88:	89 fa                	mov    %edi,%edx
  800d8a:	83 c4 1c             	add    $0x1c,%esp
  800d8d:	5b                   	pop    %ebx
  800d8e:	5e                   	pop    %esi
  800d8f:	5f                   	pop    %edi
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    
  800d92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d98:	31 ff                	xor    %edi,%edi
  800d9a:	31 db                	xor    %ebx,%ebx
  800d9c:	89 d8                	mov    %ebx,%eax
  800d9e:	89 fa                	mov    %edi,%edx
  800da0:	83 c4 1c             	add    $0x1c,%esp
  800da3:	5b                   	pop    %ebx
  800da4:	5e                   	pop    %esi
  800da5:	5f                   	pop    %edi
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    
  800da8:	90                   	nop
  800da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800db0:	89 d8                	mov    %ebx,%eax
  800db2:	f7 f7                	div    %edi
  800db4:	31 ff                	xor    %edi,%edi
  800db6:	89 c3                	mov    %eax,%ebx
  800db8:	89 d8                	mov    %ebx,%eax
  800dba:	89 fa                	mov    %edi,%edx
  800dbc:	83 c4 1c             	add    $0x1c,%esp
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    
  800dc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800dc8:	39 ce                	cmp    %ecx,%esi
  800dca:	72 0c                	jb     800dd8 <__udivdi3+0x118>
  800dcc:	31 db                	xor    %ebx,%ebx
  800dce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800dd2:	0f 87 34 ff ff ff    	ja     800d0c <__udivdi3+0x4c>
  800dd8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800ddd:	e9 2a ff ff ff       	jmp    800d0c <__udivdi3+0x4c>
  800de2:	66 90                	xchg   %ax,%ax
  800de4:	66 90                	xchg   %ax,%ax
  800de6:	66 90                	xchg   %ax,%ax
  800de8:	66 90                	xchg   %ax,%ax
  800dea:	66 90                	xchg   %ax,%ax
  800dec:	66 90                	xchg   %ax,%ax
  800dee:	66 90                	xchg   %ax,%ax

00800df0 <__umoddi3>:
  800df0:	55                   	push   %ebp
  800df1:	57                   	push   %edi
  800df2:	56                   	push   %esi
  800df3:	53                   	push   %ebx
  800df4:	83 ec 1c             	sub    $0x1c,%esp
  800df7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800dfb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800dff:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e07:	85 d2                	test   %edx,%edx
  800e09:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e11:	89 f3                	mov    %esi,%ebx
  800e13:	89 3c 24             	mov    %edi,(%esp)
  800e16:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e1a:	75 1c                	jne    800e38 <__umoddi3+0x48>
  800e1c:	39 f7                	cmp    %esi,%edi
  800e1e:	76 50                	jbe    800e70 <__umoddi3+0x80>
  800e20:	89 c8                	mov    %ecx,%eax
  800e22:	89 f2                	mov    %esi,%edx
  800e24:	f7 f7                	div    %edi
  800e26:	89 d0                	mov    %edx,%eax
  800e28:	31 d2                	xor    %edx,%edx
  800e2a:	83 c4 1c             	add    $0x1c,%esp
  800e2d:	5b                   	pop    %ebx
  800e2e:	5e                   	pop    %esi
  800e2f:	5f                   	pop    %edi
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    
  800e32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e38:	39 f2                	cmp    %esi,%edx
  800e3a:	89 d0                	mov    %edx,%eax
  800e3c:	77 52                	ja     800e90 <__umoddi3+0xa0>
  800e3e:	0f bd ea             	bsr    %edx,%ebp
  800e41:	83 f5 1f             	xor    $0x1f,%ebp
  800e44:	75 5a                	jne    800ea0 <__umoddi3+0xb0>
  800e46:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800e4a:	0f 82 e0 00 00 00    	jb     800f30 <__umoddi3+0x140>
  800e50:	39 0c 24             	cmp    %ecx,(%esp)
  800e53:	0f 86 d7 00 00 00    	jbe    800f30 <__umoddi3+0x140>
  800e59:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e5d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e61:	83 c4 1c             	add    $0x1c,%esp
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    
  800e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e70:	85 ff                	test   %edi,%edi
  800e72:	89 fd                	mov    %edi,%ebp
  800e74:	75 0b                	jne    800e81 <__umoddi3+0x91>
  800e76:	b8 01 00 00 00       	mov    $0x1,%eax
  800e7b:	31 d2                	xor    %edx,%edx
  800e7d:	f7 f7                	div    %edi
  800e7f:	89 c5                	mov    %eax,%ebp
  800e81:	89 f0                	mov    %esi,%eax
  800e83:	31 d2                	xor    %edx,%edx
  800e85:	f7 f5                	div    %ebp
  800e87:	89 c8                	mov    %ecx,%eax
  800e89:	f7 f5                	div    %ebp
  800e8b:	89 d0                	mov    %edx,%eax
  800e8d:	eb 99                	jmp    800e28 <__umoddi3+0x38>
  800e8f:	90                   	nop
  800e90:	89 c8                	mov    %ecx,%eax
  800e92:	89 f2                	mov    %esi,%edx
  800e94:	83 c4 1c             	add    $0x1c,%esp
  800e97:	5b                   	pop    %ebx
  800e98:	5e                   	pop    %esi
  800e99:	5f                   	pop    %edi
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    
  800e9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ea0:	8b 34 24             	mov    (%esp),%esi
  800ea3:	bf 20 00 00 00       	mov    $0x20,%edi
  800ea8:	89 e9                	mov    %ebp,%ecx
  800eaa:	29 ef                	sub    %ebp,%edi
  800eac:	d3 e0                	shl    %cl,%eax
  800eae:	89 f9                	mov    %edi,%ecx
  800eb0:	89 f2                	mov    %esi,%edx
  800eb2:	d3 ea                	shr    %cl,%edx
  800eb4:	89 e9                	mov    %ebp,%ecx
  800eb6:	09 c2                	or     %eax,%edx
  800eb8:	89 d8                	mov    %ebx,%eax
  800eba:	89 14 24             	mov    %edx,(%esp)
  800ebd:	89 f2                	mov    %esi,%edx
  800ebf:	d3 e2                	shl    %cl,%edx
  800ec1:	89 f9                	mov    %edi,%ecx
  800ec3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ec7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800ecb:	d3 e8                	shr    %cl,%eax
  800ecd:	89 e9                	mov    %ebp,%ecx
  800ecf:	89 c6                	mov    %eax,%esi
  800ed1:	d3 e3                	shl    %cl,%ebx
  800ed3:	89 f9                	mov    %edi,%ecx
  800ed5:	89 d0                	mov    %edx,%eax
  800ed7:	d3 e8                	shr    %cl,%eax
  800ed9:	89 e9                	mov    %ebp,%ecx
  800edb:	09 d8                	or     %ebx,%eax
  800edd:	89 d3                	mov    %edx,%ebx
  800edf:	89 f2                	mov    %esi,%edx
  800ee1:	f7 34 24             	divl   (%esp)
  800ee4:	89 d6                	mov    %edx,%esi
  800ee6:	d3 e3                	shl    %cl,%ebx
  800ee8:	f7 64 24 04          	mull   0x4(%esp)
  800eec:	39 d6                	cmp    %edx,%esi
  800eee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ef2:	89 d1                	mov    %edx,%ecx
  800ef4:	89 c3                	mov    %eax,%ebx
  800ef6:	72 08                	jb     800f00 <__umoddi3+0x110>
  800ef8:	75 11                	jne    800f0b <__umoddi3+0x11b>
  800efa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800efe:	73 0b                	jae    800f0b <__umoddi3+0x11b>
  800f00:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f04:	1b 14 24             	sbb    (%esp),%edx
  800f07:	89 d1                	mov    %edx,%ecx
  800f09:	89 c3                	mov    %eax,%ebx
  800f0b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f0f:	29 da                	sub    %ebx,%edx
  800f11:	19 ce                	sbb    %ecx,%esi
  800f13:	89 f9                	mov    %edi,%ecx
  800f15:	89 f0                	mov    %esi,%eax
  800f17:	d3 e0                	shl    %cl,%eax
  800f19:	89 e9                	mov    %ebp,%ecx
  800f1b:	d3 ea                	shr    %cl,%edx
  800f1d:	89 e9                	mov    %ebp,%ecx
  800f1f:	d3 ee                	shr    %cl,%esi
  800f21:	09 d0                	or     %edx,%eax
  800f23:	89 f2                	mov    %esi,%edx
  800f25:	83 c4 1c             	add    $0x1c,%esp
  800f28:	5b                   	pop    %ebx
  800f29:	5e                   	pop    %esi
  800f2a:	5f                   	pop    %edi
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    
  800f2d:	8d 76 00             	lea    0x0(%esi),%esi
  800f30:	29 f9                	sub    %edi,%ecx
  800f32:	19 d6                	sbb    %edx,%esi
  800f34:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f38:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f3c:	e9 18 ff ff ff       	jmp    800e59 <__umoddi3+0x69>
