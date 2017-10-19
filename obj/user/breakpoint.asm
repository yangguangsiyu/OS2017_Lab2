
obj/user/breakpoint：     文件格式 elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800044:	e8 c6 00 00 00       	call   80010f <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800051:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800056:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005b:	85 db                	test   %ebx,%ebx
  80005d:	7e 07                	jle    800066 <libmain+0x2d>
		binaryname = argv[0];
  80005f:	8b 06                	mov    (%esi),%eax
  800061:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	e8 c3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800070:	e8 0a 00 00 00       	call   80007f <exit>
}
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007b:	5b                   	pop    %ebx
  80007c:	5e                   	pop    %esi
  80007d:	5d                   	pop    %ebp
  80007e:	c3                   	ret    

0080007f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800085:	6a 00                	push   $0x0
  800087:	e8 42 00 00 00       	call   8000ce <sys_env_destroy>
}
  80008c:	83 c4 10             	add    $0x10,%esp
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	57                   	push   %edi
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800097:	b8 00 00 00 00       	mov    $0x0,%eax
  80009c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80009f:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a2:	89 c3                	mov    %eax,%ebx
  8000a4:	89 c7                	mov    %eax,%edi
  8000a6:	89 c6                	mov    %eax,%esi
  8000a8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000aa:	5b                   	pop    %ebx
  8000ab:	5e                   	pop    %esi
  8000ac:	5f                   	pop    %edi
  8000ad:	5d                   	pop    %ebp
  8000ae:	c3                   	ret    

008000af <sys_cgetc>:

int
sys_cgetc(void)
{
  8000af:	55                   	push   %ebp
  8000b0:	89 e5                	mov    %esp,%ebp
  8000b2:	57                   	push   %edi
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8000bf:	89 d1                	mov    %edx,%ecx
  8000c1:	89 d3                	mov    %edx,%ebx
  8000c3:	89 d7                	mov    %edx,%edi
  8000c5:	89 d6                	mov    %edx,%esi
  8000c7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000c9:	5b                   	pop    %ebx
  8000ca:	5e                   	pop    %esi
  8000cb:	5f                   	pop    %edi
  8000cc:	5d                   	pop    %ebp
  8000cd:	c3                   	ret    

008000ce <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	57                   	push   %edi
  8000d2:	56                   	push   %esi
  8000d3:	53                   	push   %ebx
  8000d4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000dc:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e4:	89 cb                	mov    %ecx,%ebx
  8000e6:	89 cf                	mov    %ecx,%edi
  8000e8:	89 ce                	mov    %ecx,%esi
  8000ea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000ec:	85 c0                	test   %eax,%eax
  8000ee:	7e 17                	jle    800107 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f0:	83 ec 0c             	sub    $0xc,%esp
  8000f3:	50                   	push   %eax
  8000f4:	6a 03                	push   $0x3
  8000f6:	68 6a 0f 80 00       	push   $0x800f6a
  8000fb:	6a 23                	push   $0x23
  8000fd:	68 87 0f 80 00       	push   $0x800f87
  800102:	e8 f5 01 00 00       	call   8002fc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800107:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010a:	5b                   	pop    %ebx
  80010b:	5e                   	pop    %esi
  80010c:	5f                   	pop    %edi
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    

0080010f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	57                   	push   %edi
  800113:	56                   	push   %esi
  800114:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800115:	ba 00 00 00 00       	mov    $0x0,%edx
  80011a:	b8 02 00 00 00       	mov    $0x2,%eax
  80011f:	89 d1                	mov    %edx,%ecx
  800121:	89 d3                	mov    %edx,%ebx
  800123:	89 d7                	mov    %edx,%edi
  800125:	89 d6                	mov    %edx,%esi
  800127:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800129:	5b                   	pop    %ebx
  80012a:	5e                   	pop    %esi
  80012b:	5f                   	pop    %edi
  80012c:	5d                   	pop    %ebp
  80012d:	c3                   	ret    

0080012e <sys_yield>:

void
sys_yield(void)
{
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	57                   	push   %edi
  800132:	56                   	push   %esi
  800133:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800134:	ba 00 00 00 00       	mov    $0x0,%edx
  800139:	b8 0a 00 00 00       	mov    $0xa,%eax
  80013e:	89 d1                	mov    %edx,%ecx
  800140:	89 d3                	mov    %edx,%ebx
  800142:	89 d7                	mov    %edx,%edi
  800144:	89 d6                	mov    %edx,%esi
  800146:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800148:	5b                   	pop    %ebx
  800149:	5e                   	pop    %esi
  80014a:	5f                   	pop    %edi
  80014b:	5d                   	pop    %ebp
  80014c:	c3                   	ret    

0080014d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	57                   	push   %edi
  800151:	56                   	push   %esi
  800152:	53                   	push   %ebx
  800153:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800156:	be 00 00 00 00       	mov    $0x0,%esi
  80015b:	b8 04 00 00 00       	mov    $0x4,%eax
  800160:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800163:	8b 55 08             	mov    0x8(%ebp),%edx
  800166:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800169:	89 f7                	mov    %esi,%edi
  80016b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80016d:	85 c0                	test   %eax,%eax
  80016f:	7e 17                	jle    800188 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800171:	83 ec 0c             	sub    $0xc,%esp
  800174:	50                   	push   %eax
  800175:	6a 04                	push   $0x4
  800177:	68 6a 0f 80 00       	push   $0x800f6a
  80017c:	6a 23                	push   $0x23
  80017e:	68 87 0f 80 00       	push   $0x800f87
  800183:	e8 74 01 00 00       	call   8002fc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800188:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018b:	5b                   	pop    %ebx
  80018c:	5e                   	pop    %esi
  80018d:	5f                   	pop    %edi
  80018e:	5d                   	pop    %ebp
  80018f:	c3                   	ret    

00800190 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800199:	b8 05 00 00 00       	mov    $0x5,%eax
  80019e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001aa:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001af:	85 c0                	test   %eax,%eax
  8001b1:	7e 17                	jle    8001ca <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b3:	83 ec 0c             	sub    $0xc,%esp
  8001b6:	50                   	push   %eax
  8001b7:	6a 05                	push   $0x5
  8001b9:	68 6a 0f 80 00       	push   $0x800f6a
  8001be:	6a 23                	push   $0x23
  8001c0:	68 87 0f 80 00       	push   $0x800f87
  8001c5:	e8 32 01 00 00       	call   8002fc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001cd:	5b                   	pop    %ebx
  8001ce:	5e                   	pop    %esi
  8001cf:	5f                   	pop    %edi
  8001d0:	5d                   	pop    %ebp
  8001d1:	c3                   	ret    

008001d2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	57                   	push   %edi
  8001d6:	56                   	push   %esi
  8001d7:	53                   	push   %ebx
  8001d8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e0:	b8 06 00 00 00       	mov    $0x6,%eax
  8001e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001eb:	89 df                	mov    %ebx,%edi
  8001ed:	89 de                	mov    %ebx,%esi
  8001ef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f1:	85 c0                	test   %eax,%eax
  8001f3:	7e 17                	jle    80020c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	50                   	push   %eax
  8001f9:	6a 06                	push   $0x6
  8001fb:	68 6a 0f 80 00       	push   $0x800f6a
  800200:	6a 23                	push   $0x23
  800202:	68 87 0f 80 00       	push   $0x800f87
  800207:	e8 f0 00 00 00       	call   8002fc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80020c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020f:	5b                   	pop    %ebx
  800210:	5e                   	pop    %esi
  800211:	5f                   	pop    %edi
  800212:	5d                   	pop    %ebp
  800213:	c3                   	ret    

00800214 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	57                   	push   %edi
  800218:	56                   	push   %esi
  800219:	53                   	push   %ebx
  80021a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80021d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800222:	b8 08 00 00 00       	mov    $0x8,%eax
  800227:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022a:	8b 55 08             	mov    0x8(%ebp),%edx
  80022d:	89 df                	mov    %ebx,%edi
  80022f:	89 de                	mov    %ebx,%esi
  800231:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800233:	85 c0                	test   %eax,%eax
  800235:	7e 17                	jle    80024e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800237:	83 ec 0c             	sub    $0xc,%esp
  80023a:	50                   	push   %eax
  80023b:	6a 08                	push   $0x8
  80023d:	68 6a 0f 80 00       	push   $0x800f6a
  800242:	6a 23                	push   $0x23
  800244:	68 87 0f 80 00       	push   $0x800f87
  800249:	e8 ae 00 00 00       	call   8002fc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80024e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800251:	5b                   	pop    %ebx
  800252:	5e                   	pop    %esi
  800253:	5f                   	pop    %edi
  800254:	5d                   	pop    %ebp
  800255:	c3                   	ret    

00800256 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
  800259:	57                   	push   %edi
  80025a:	56                   	push   %esi
  80025b:	53                   	push   %ebx
  80025c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80025f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800264:	b8 09 00 00 00       	mov    $0x9,%eax
  800269:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026c:	8b 55 08             	mov    0x8(%ebp),%edx
  80026f:	89 df                	mov    %ebx,%edi
  800271:	89 de                	mov    %ebx,%esi
  800273:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800275:	85 c0                	test   %eax,%eax
  800277:	7e 17                	jle    800290 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800279:	83 ec 0c             	sub    $0xc,%esp
  80027c:	50                   	push   %eax
  80027d:	6a 09                	push   $0x9
  80027f:	68 6a 0f 80 00       	push   $0x800f6a
  800284:	6a 23                	push   $0x23
  800286:	68 87 0f 80 00       	push   $0x800f87
  80028b:	e8 6c 00 00 00       	call   8002fc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800290:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800293:	5b                   	pop    %ebx
  800294:	5e                   	pop    %esi
  800295:	5f                   	pop    %edi
  800296:	5d                   	pop    %ebp
  800297:	c3                   	ret    

00800298 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	57                   	push   %edi
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80029e:	be 00 00 00 00       	mov    $0x0,%esi
  8002a3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002b1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	57                   	push   %edi
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002c9:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d1:	89 cb                	mov    %ecx,%ebx
  8002d3:	89 cf                	mov    %ecx,%edi
  8002d5:	89 ce                	mov    %ecx,%esi
  8002d7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d9:	85 c0                	test   %eax,%eax
  8002db:	7e 17                	jle    8002f4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002dd:	83 ec 0c             	sub    $0xc,%esp
  8002e0:	50                   	push   %eax
  8002e1:	6a 0c                	push   $0xc
  8002e3:	68 6a 0f 80 00       	push   $0x800f6a
  8002e8:	6a 23                	push   $0x23
  8002ea:	68 87 0f 80 00       	push   $0x800f87
  8002ef:	e8 08 00 00 00       	call   8002fc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f7:	5b                   	pop    %ebx
  8002f8:	5e                   	pop    %esi
  8002f9:	5f                   	pop    %edi
  8002fa:	5d                   	pop    %ebp
  8002fb:	c3                   	ret    

008002fc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	56                   	push   %esi
  800300:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800301:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800304:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80030a:	e8 00 fe ff ff       	call   80010f <sys_getenvid>
  80030f:	83 ec 0c             	sub    $0xc,%esp
  800312:	ff 75 0c             	pushl  0xc(%ebp)
  800315:	ff 75 08             	pushl  0x8(%ebp)
  800318:	56                   	push   %esi
  800319:	50                   	push   %eax
  80031a:	68 98 0f 80 00       	push   $0x800f98
  80031f:	e8 b1 00 00 00       	call   8003d5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800324:	83 c4 18             	add    $0x18,%esp
  800327:	53                   	push   %ebx
  800328:	ff 75 10             	pushl  0x10(%ebp)
  80032b:	e8 54 00 00 00       	call   800384 <vcprintf>
	cprintf("\n");
  800330:	c7 04 24 bc 0f 80 00 	movl   $0x800fbc,(%esp)
  800337:	e8 99 00 00 00       	call   8003d5 <cprintf>
  80033c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80033f:	cc                   	int3   
  800340:	eb fd                	jmp    80033f <_panic+0x43>

00800342 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	53                   	push   %ebx
  800346:	83 ec 04             	sub    $0x4,%esp
  800349:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80034c:	8b 13                	mov    (%ebx),%edx
  80034e:	8d 42 01             	lea    0x1(%edx),%eax
  800351:	89 03                	mov    %eax,(%ebx)
  800353:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800356:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80035a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80035f:	75 1a                	jne    80037b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800361:	83 ec 08             	sub    $0x8,%esp
  800364:	68 ff 00 00 00       	push   $0xff
  800369:	8d 43 08             	lea    0x8(%ebx),%eax
  80036c:	50                   	push   %eax
  80036d:	e8 1f fd ff ff       	call   800091 <sys_cputs>
		b->idx = 0;
  800372:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800378:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80037b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80037f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80038d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800394:	00 00 00 
	b.cnt = 0;
  800397:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80039e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003a1:	ff 75 0c             	pushl  0xc(%ebp)
  8003a4:	ff 75 08             	pushl  0x8(%ebp)
  8003a7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ad:	50                   	push   %eax
  8003ae:	68 42 03 80 00       	push   $0x800342
  8003b3:	e8 54 01 00 00       	call   80050c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003b8:	83 c4 08             	add    $0x8,%esp
  8003bb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003c1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003c7:	50                   	push   %eax
  8003c8:	e8 c4 fc ff ff       	call   800091 <sys_cputs>

	return b.cnt;
}
  8003cd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003d3:	c9                   	leave  
  8003d4:	c3                   	ret    

008003d5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003d5:	55                   	push   %ebp
  8003d6:	89 e5                	mov    %esp,%ebp
  8003d8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003db:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003de:	50                   	push   %eax
  8003df:	ff 75 08             	pushl  0x8(%ebp)
  8003e2:	e8 9d ff ff ff       	call   800384 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003e7:	c9                   	leave  
  8003e8:	c3                   	ret    

008003e9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	57                   	push   %edi
  8003ed:	56                   	push   %esi
  8003ee:	53                   	push   %ebx
  8003ef:	83 ec 1c             	sub    $0x1c,%esp
  8003f2:	89 c7                	mov    %eax,%edi
  8003f4:	89 d6                	mov    %edx,%esi
  8003f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ff:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800402:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800405:	bb 00 00 00 00       	mov    $0x0,%ebx
  80040a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80040d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800410:	39 d3                	cmp    %edx,%ebx
  800412:	72 05                	jb     800419 <printnum+0x30>
  800414:	39 45 10             	cmp    %eax,0x10(%ebp)
  800417:	77 45                	ja     80045e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800419:	83 ec 0c             	sub    $0xc,%esp
  80041c:	ff 75 18             	pushl  0x18(%ebp)
  80041f:	8b 45 14             	mov    0x14(%ebp),%eax
  800422:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800425:	53                   	push   %ebx
  800426:	ff 75 10             	pushl  0x10(%ebp)
  800429:	83 ec 08             	sub    $0x8,%esp
  80042c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80042f:	ff 75 e0             	pushl  -0x20(%ebp)
  800432:	ff 75 dc             	pushl  -0x24(%ebp)
  800435:	ff 75 d8             	pushl  -0x28(%ebp)
  800438:	e8 83 08 00 00       	call   800cc0 <__udivdi3>
  80043d:	83 c4 18             	add    $0x18,%esp
  800440:	52                   	push   %edx
  800441:	50                   	push   %eax
  800442:	89 f2                	mov    %esi,%edx
  800444:	89 f8                	mov    %edi,%eax
  800446:	e8 9e ff ff ff       	call   8003e9 <printnum>
  80044b:	83 c4 20             	add    $0x20,%esp
  80044e:	eb 18                	jmp    800468 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800450:	83 ec 08             	sub    $0x8,%esp
  800453:	56                   	push   %esi
  800454:	ff 75 18             	pushl  0x18(%ebp)
  800457:	ff d7                	call   *%edi
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	eb 03                	jmp    800461 <printnum+0x78>
  80045e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800461:	83 eb 01             	sub    $0x1,%ebx
  800464:	85 db                	test   %ebx,%ebx
  800466:	7f e8                	jg     800450 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800468:	83 ec 08             	sub    $0x8,%esp
  80046b:	56                   	push   %esi
  80046c:	83 ec 04             	sub    $0x4,%esp
  80046f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800472:	ff 75 e0             	pushl  -0x20(%ebp)
  800475:	ff 75 dc             	pushl  -0x24(%ebp)
  800478:	ff 75 d8             	pushl  -0x28(%ebp)
  80047b:	e8 70 09 00 00       	call   800df0 <__umoddi3>
  800480:	83 c4 14             	add    $0x14,%esp
  800483:	0f be 80 be 0f 80 00 	movsbl 0x800fbe(%eax),%eax
  80048a:	50                   	push   %eax
  80048b:	ff d7                	call   *%edi
}
  80048d:	83 c4 10             	add    $0x10,%esp
  800490:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800493:	5b                   	pop    %ebx
  800494:	5e                   	pop    %esi
  800495:	5f                   	pop    %edi
  800496:	5d                   	pop    %ebp
  800497:	c3                   	ret    

00800498 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800498:	55                   	push   %ebp
  800499:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80049b:	83 fa 01             	cmp    $0x1,%edx
  80049e:	7e 0e                	jle    8004ae <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004a0:	8b 10                	mov    (%eax),%edx
  8004a2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004a5:	89 08                	mov    %ecx,(%eax)
  8004a7:	8b 02                	mov    (%edx),%eax
  8004a9:	8b 52 04             	mov    0x4(%edx),%edx
  8004ac:	eb 22                	jmp    8004d0 <getuint+0x38>
	else if (lflag)
  8004ae:	85 d2                	test   %edx,%edx
  8004b0:	74 10                	je     8004c2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004b2:	8b 10                	mov    (%eax),%edx
  8004b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004b7:	89 08                	mov    %ecx,(%eax)
  8004b9:	8b 02                	mov    (%edx),%eax
  8004bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c0:	eb 0e                	jmp    8004d0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004c2:	8b 10                	mov    (%eax),%edx
  8004c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c7:	89 08                	mov    %ecx,(%eax)
  8004c9:	8b 02                	mov    (%edx),%eax
  8004cb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004d0:	5d                   	pop    %ebp
  8004d1:	c3                   	ret    

008004d2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
  8004d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004d8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004dc:	8b 10                	mov    (%eax),%edx
  8004de:	3b 50 04             	cmp    0x4(%eax),%edx
  8004e1:	73 0a                	jae    8004ed <sprintputch+0x1b>
		*b->buf++ = ch;
  8004e3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004e6:	89 08                	mov    %ecx,(%eax)
  8004e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004eb:	88 02                	mov    %al,(%edx)
}
  8004ed:	5d                   	pop    %ebp
  8004ee:	c3                   	ret    

008004ef <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004ef:	55                   	push   %ebp
  8004f0:	89 e5                	mov    %esp,%ebp
  8004f2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004f5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f8:	50                   	push   %eax
  8004f9:	ff 75 10             	pushl  0x10(%ebp)
  8004fc:	ff 75 0c             	pushl  0xc(%ebp)
  8004ff:	ff 75 08             	pushl  0x8(%ebp)
  800502:	e8 05 00 00 00       	call   80050c <vprintfmt>
	va_end(ap);
}
  800507:	83 c4 10             	add    $0x10,%esp
  80050a:	c9                   	leave  
  80050b:	c3                   	ret    

0080050c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80050c:	55                   	push   %ebp
  80050d:	89 e5                	mov    %esp,%ebp
  80050f:	57                   	push   %edi
  800510:	56                   	push   %esi
  800511:	53                   	push   %ebx
  800512:	83 ec 2c             	sub    $0x2c,%esp
  800515:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
  800518:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80051f:	eb 17                	jmp    800538 <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800521:	85 c0                	test   %eax,%eax
  800523:	0f 84 9f 03 00 00    	je     8008c8 <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
  800529:	83 ec 08             	sub    $0x8,%esp
  80052c:	ff 75 0c             	pushl  0xc(%ebp)
  80052f:	50                   	push   %eax
  800530:	ff 55 08             	call   *0x8(%ebp)
  800533:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800536:	89 f3                	mov    %esi,%ebx
  800538:	8d 73 01             	lea    0x1(%ebx),%esi
  80053b:	0f b6 03             	movzbl (%ebx),%eax
  80053e:	83 f8 25             	cmp    $0x25,%eax
  800541:	75 de                	jne    800521 <vprintfmt+0x15>
  800543:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800547:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80054e:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800553:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80055a:	ba 00 00 00 00       	mov    $0x0,%edx
  80055f:	eb 06                	jmp    800567 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800561:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800563:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800567:	8d 5e 01             	lea    0x1(%esi),%ebx
  80056a:	0f b6 06             	movzbl (%esi),%eax
  80056d:	0f b6 c8             	movzbl %al,%ecx
  800570:	83 e8 23             	sub    $0x23,%eax
  800573:	3c 55                	cmp    $0x55,%al
  800575:	0f 87 2d 03 00 00    	ja     8008a8 <vprintfmt+0x39c>
  80057b:	0f b6 c0             	movzbl %al,%eax
  80057e:	ff 24 85 80 10 80 00 	jmp    *0x801080(,%eax,4)
  800585:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800587:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80058b:	eb da                	jmp    800567 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	89 de                	mov    %ebx,%esi
  80058f:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800594:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  800597:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  80059b:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  80059e:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8005a1:	83 f8 09             	cmp    $0x9,%eax
  8005a4:	77 33                	ja     8005d9 <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005a6:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005a9:	eb e9                	jmp    800594 <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ae:	8d 48 04             	lea    0x4(%eax),%ecx
  8005b1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005b4:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b6:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005b8:	eb 1f                	jmp    8005d9 <vprintfmt+0xcd>
  8005ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005bd:	85 c0                	test   %eax,%eax
  8005bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c4:	0f 49 c8             	cmovns %eax,%ecx
  8005c7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ca:	89 de                	mov    %ebx,%esi
  8005cc:	eb 99                	jmp    800567 <vprintfmt+0x5b>
  8005ce:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005d0:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  8005d7:	eb 8e                	jmp    800567 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8005d9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005dd:	79 88                	jns    800567 <vprintfmt+0x5b>
				width = precision, precision = -1;
  8005df:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8005e2:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8005e7:	e9 7b ff ff ff       	jmp    800567 <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005ec:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ef:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005f1:	e9 71 ff ff ff       	jmp    800567 <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
  8005f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f9:	8d 50 04             	lea    0x4(%eax),%edx
  8005fc:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  8005ff:	83 ec 08             	sub    $0x8,%esp
  800602:	ff 75 0c             	pushl  0xc(%ebp)
  800605:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800608:	03 08                	add    (%eax),%ecx
  80060a:	51                   	push   %ecx
  80060b:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
  80060e:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
  800611:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
  800618:	e9 1b ff ff ff       	jmp    800538 <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8d 48 04             	lea    0x4(%eax),%ecx
  800623:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800626:	8b 00                	mov    (%eax),%eax
  800628:	83 f8 02             	cmp    $0x2,%eax
  80062b:	74 1a                	je     800647 <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062d:	89 de                	mov    %ebx,%esi
  80062f:	83 f8 04             	cmp    $0x4,%eax
  800632:	b8 00 00 00 00       	mov    $0x0,%eax
  800637:	b9 00 04 00 00       	mov    $0x400,%ecx
  80063c:	0f 44 c1             	cmove  %ecx,%eax
  80063f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800642:	e9 20 ff ff ff       	jmp    800567 <vprintfmt+0x5b>
  800647:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
  800649:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
  800650:	e9 12 ff ff ff       	jmp    800567 <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8d 50 04             	lea    0x4(%eax),%edx
  80065b:	89 55 14             	mov    %edx,0x14(%ebp)
  80065e:	8b 00                	mov    (%eax),%eax
  800660:	99                   	cltd   
  800661:	31 d0                	xor    %edx,%eax
  800663:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800665:	83 f8 09             	cmp    $0x9,%eax
  800668:	7f 0b                	jg     800675 <vprintfmt+0x169>
  80066a:	8b 14 85 e0 11 80 00 	mov    0x8011e0(,%eax,4),%edx
  800671:	85 d2                	test   %edx,%edx
  800673:	75 19                	jne    80068e <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800675:	50                   	push   %eax
  800676:	68 d6 0f 80 00       	push   $0x800fd6
  80067b:	ff 75 0c             	pushl  0xc(%ebp)
  80067e:	ff 75 08             	pushl  0x8(%ebp)
  800681:	e8 69 fe ff ff       	call   8004ef <printfmt>
  800686:	83 c4 10             	add    $0x10,%esp
  800689:	e9 aa fe ff ff       	jmp    800538 <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  80068e:	52                   	push   %edx
  80068f:	68 df 0f 80 00       	push   $0x800fdf
  800694:	ff 75 0c             	pushl  0xc(%ebp)
  800697:	ff 75 08             	pushl  0x8(%ebp)
  80069a:	e8 50 fe ff ff       	call   8004ef <printfmt>
  80069f:	83 c4 10             	add    $0x10,%esp
  8006a2:	e9 91 fe ff ff       	jmp    800538 <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	8d 50 04             	lea    0x4(%eax),%edx
  8006ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b0:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006b2:	85 f6                	test   %esi,%esi
  8006b4:	b8 cf 0f 80 00       	mov    $0x800fcf,%eax
  8006b9:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006bc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006c0:	0f 8e 93 00 00 00    	jle    800759 <vprintfmt+0x24d>
  8006c6:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8006ca:	0f 84 91 00 00 00    	je     800761 <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d0:	83 ec 08             	sub    $0x8,%esp
  8006d3:	57                   	push   %edi
  8006d4:	56                   	push   %esi
  8006d5:	e8 76 02 00 00       	call   800950 <strnlen>
  8006da:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006dd:	29 c1                	sub    %eax,%ecx
  8006df:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006e2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006e5:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8006e9:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006ec:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006ef:	8b 75 0c             	mov    0xc(%ebp),%esi
  8006f2:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006f5:	89 cb                	mov    %ecx,%ebx
  8006f7:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f9:	eb 0e                	jmp    800709 <vprintfmt+0x1fd>
					putch(padc, putdat);
  8006fb:	83 ec 08             	sub    $0x8,%esp
  8006fe:	56                   	push   %esi
  8006ff:	57                   	push   %edi
  800700:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800703:	83 eb 01             	sub    $0x1,%ebx
  800706:	83 c4 10             	add    $0x10,%esp
  800709:	85 db                	test   %ebx,%ebx
  80070b:	7f ee                	jg     8006fb <vprintfmt+0x1ef>
  80070d:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800710:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800713:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800716:	85 c9                	test   %ecx,%ecx
  800718:	b8 00 00 00 00       	mov    $0x0,%eax
  80071d:	0f 49 c1             	cmovns %ecx,%eax
  800720:	29 c1                	sub    %eax,%ecx
  800722:	89 cb                	mov    %ecx,%ebx
  800724:	eb 41                	jmp    800767 <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800726:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80072a:	74 1b                	je     800747 <vprintfmt+0x23b>
  80072c:	0f be c0             	movsbl %al,%eax
  80072f:	83 e8 20             	sub    $0x20,%eax
  800732:	83 f8 5e             	cmp    $0x5e,%eax
  800735:	76 10                	jbe    800747 <vprintfmt+0x23b>
					putch('?', putdat);
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	ff 75 0c             	pushl  0xc(%ebp)
  80073d:	6a 3f                	push   $0x3f
  80073f:	ff 55 08             	call   *0x8(%ebp)
  800742:	83 c4 10             	add    $0x10,%esp
  800745:	eb 0d                	jmp    800754 <vprintfmt+0x248>
				else
					putch(ch, putdat);
  800747:	83 ec 08             	sub    $0x8,%esp
  80074a:	ff 75 0c             	pushl  0xc(%ebp)
  80074d:	52                   	push   %edx
  80074e:	ff 55 08             	call   *0x8(%ebp)
  800751:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800754:	83 eb 01             	sub    $0x1,%ebx
  800757:	eb 0e                	jmp    800767 <vprintfmt+0x25b>
  800759:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80075c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80075f:	eb 06                	jmp    800767 <vprintfmt+0x25b>
  800761:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800764:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800767:	83 c6 01             	add    $0x1,%esi
  80076a:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80076e:	0f be d0             	movsbl %al,%edx
  800771:	85 d2                	test   %edx,%edx
  800773:	74 25                	je     80079a <vprintfmt+0x28e>
  800775:	85 ff                	test   %edi,%edi
  800777:	78 ad                	js     800726 <vprintfmt+0x21a>
  800779:	83 ef 01             	sub    $0x1,%edi
  80077c:	79 a8                	jns    800726 <vprintfmt+0x21a>
  80077e:	89 d8                	mov    %ebx,%eax
  800780:	8b 75 08             	mov    0x8(%ebp),%esi
  800783:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800786:	89 c3                	mov    %eax,%ebx
  800788:	eb 16                	jmp    8007a0 <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80078a:	83 ec 08             	sub    $0x8,%esp
  80078d:	57                   	push   %edi
  80078e:	6a 20                	push   $0x20
  800790:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800792:	83 eb 01             	sub    $0x1,%ebx
  800795:	83 c4 10             	add    $0x10,%esp
  800798:	eb 06                	jmp    8007a0 <vprintfmt+0x294>
  80079a:	8b 75 08             	mov    0x8(%ebp),%esi
  80079d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8007a0:	85 db                	test   %ebx,%ebx
  8007a2:	7f e6                	jg     80078a <vprintfmt+0x27e>
  8007a4:	89 75 08             	mov    %esi,0x8(%ebp)
  8007a7:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8007aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007ad:	e9 86 fd ff ff       	jmp    800538 <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007b2:	83 fa 01             	cmp    $0x1,%edx
  8007b5:	7e 10                	jle    8007c7 <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
  8007b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ba:	8d 50 08             	lea    0x8(%eax),%edx
  8007bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c0:	8b 30                	mov    (%eax),%esi
  8007c2:	8b 78 04             	mov    0x4(%eax),%edi
  8007c5:	eb 26                	jmp    8007ed <vprintfmt+0x2e1>
	else if (lflag)
  8007c7:	85 d2                	test   %edx,%edx
  8007c9:	74 12                	je     8007dd <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  8007cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ce:	8d 50 04             	lea    0x4(%eax),%edx
  8007d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d4:	8b 30                	mov    (%eax),%esi
  8007d6:	89 f7                	mov    %esi,%edi
  8007d8:	c1 ff 1f             	sar    $0x1f,%edi
  8007db:	eb 10                	jmp    8007ed <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8d 50 04             	lea    0x4(%eax),%edx
  8007e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e6:	8b 30                	mov    (%eax),%esi
  8007e8:	89 f7                	mov    %esi,%edi
  8007ea:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007ed:	89 f0                	mov    %esi,%eax
  8007ef:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007f1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007f6:	85 ff                	test   %edi,%edi
  8007f8:	79 7b                	jns    800875 <vprintfmt+0x369>
				putch('-', putdat);
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	ff 75 0c             	pushl  0xc(%ebp)
  800800:	6a 2d                	push   $0x2d
  800802:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800805:	89 f0                	mov    %esi,%eax
  800807:	89 fa                	mov    %edi,%edx
  800809:	f7 d8                	neg    %eax
  80080b:	83 d2 00             	adc    $0x0,%edx
  80080e:	f7 da                	neg    %edx
  800810:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800813:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800818:	eb 5b                	jmp    800875 <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80081a:	8d 45 14             	lea    0x14(%ebp),%eax
  80081d:	e8 76 fc ff ff       	call   800498 <getuint>
			base = 10;
  800822:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800827:	eb 4c                	jmp    800875 <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
  800829:	8d 45 14             	lea    0x14(%ebp),%eax
  80082c:	e8 67 fc ff ff       	call   800498 <getuint>
            base = 8;
  800831:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800836:	eb 3d                	jmp    800875 <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
  800838:	83 ec 08             	sub    $0x8,%esp
  80083b:	ff 75 0c             	pushl  0xc(%ebp)
  80083e:	6a 30                	push   $0x30
  800840:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800843:	83 c4 08             	add    $0x8,%esp
  800846:	ff 75 0c             	pushl  0xc(%ebp)
  800849:	6a 78                	push   $0x78
  80084b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80084e:	8b 45 14             	mov    0x14(%ebp),%eax
  800851:	8d 50 04             	lea    0x4(%eax),%edx
  800854:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800857:	8b 00                	mov    (%eax),%eax
  800859:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80085e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800861:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800866:	eb 0d                	jmp    800875 <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800868:	8d 45 14             	lea    0x14(%ebp),%eax
  80086b:	e8 28 fc ff ff       	call   800498 <getuint>
			base = 16;
  800870:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800875:	83 ec 0c             	sub    $0xc,%esp
  800878:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  80087c:	56                   	push   %esi
  80087d:	ff 75 e0             	pushl  -0x20(%ebp)
  800880:	51                   	push   %ecx
  800881:	52                   	push   %edx
  800882:	50                   	push   %eax
  800883:	8b 55 0c             	mov    0xc(%ebp),%edx
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	e8 5b fb ff ff       	call   8003e9 <printnum>
			break;
  80088e:	83 c4 20             	add    $0x20,%esp
  800891:	e9 a2 fc ff ff       	jmp    800538 <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800896:	83 ec 08             	sub    $0x8,%esp
  800899:	ff 75 0c             	pushl  0xc(%ebp)
  80089c:	51                   	push   %ecx
  80089d:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008a0:	83 c4 10             	add    $0x10,%esp
  8008a3:	e9 90 fc ff ff       	jmp    800538 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008a8:	83 ec 08             	sub    $0x8,%esp
  8008ab:	ff 75 0c             	pushl  0xc(%ebp)
  8008ae:	6a 25                	push   $0x25
  8008b0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b3:	83 c4 10             	add    $0x10,%esp
  8008b6:	89 f3                	mov    %esi,%ebx
  8008b8:	eb 03                	jmp    8008bd <vprintfmt+0x3b1>
  8008ba:	83 eb 01             	sub    $0x1,%ebx
  8008bd:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8008c1:	75 f7                	jne    8008ba <vprintfmt+0x3ae>
  8008c3:	e9 70 fc ff ff       	jmp    800538 <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  8008c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008cb:	5b                   	pop    %ebx
  8008cc:	5e                   	pop    %esi
  8008cd:	5f                   	pop    %edi
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	83 ec 18             	sub    $0x18,%esp
  8008d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008df:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008e3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008ed:	85 c0                	test   %eax,%eax
  8008ef:	74 26                	je     800917 <vsnprintf+0x47>
  8008f1:	85 d2                	test   %edx,%edx
  8008f3:	7e 22                	jle    800917 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f5:	ff 75 14             	pushl  0x14(%ebp)
  8008f8:	ff 75 10             	pushl  0x10(%ebp)
  8008fb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008fe:	50                   	push   %eax
  8008ff:	68 d2 04 80 00       	push   $0x8004d2
  800904:	e8 03 fc ff ff       	call   80050c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800909:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80090c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80090f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800912:	83 c4 10             	add    $0x10,%esp
  800915:	eb 05                	jmp    80091c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800917:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80091c:	c9                   	leave  
  80091d:	c3                   	ret    

0080091e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800924:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800927:	50                   	push   %eax
  800928:	ff 75 10             	pushl  0x10(%ebp)
  80092b:	ff 75 0c             	pushl  0xc(%ebp)
  80092e:	ff 75 08             	pushl  0x8(%ebp)
  800931:	e8 9a ff ff ff       	call   8008d0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800936:	c9                   	leave  
  800937:	c3                   	ret    

00800938 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80093e:	b8 00 00 00 00       	mov    $0x0,%eax
  800943:	eb 03                	jmp    800948 <strlen+0x10>
		n++;
  800945:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800948:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80094c:	75 f7                	jne    800945 <strlen+0xd>
		n++;
	return n;
}
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800956:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800959:	ba 00 00 00 00       	mov    $0x0,%edx
  80095e:	eb 03                	jmp    800963 <strnlen+0x13>
		n++;
  800960:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800963:	39 c2                	cmp    %eax,%edx
  800965:	74 08                	je     80096f <strnlen+0x1f>
  800967:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80096b:	75 f3                	jne    800960 <strnlen+0x10>
  80096d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	53                   	push   %ebx
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80097b:	89 c2                	mov    %eax,%edx
  80097d:	83 c2 01             	add    $0x1,%edx
  800980:	83 c1 01             	add    $0x1,%ecx
  800983:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800987:	88 5a ff             	mov    %bl,-0x1(%edx)
  80098a:	84 db                	test   %bl,%bl
  80098c:	75 ef                	jne    80097d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80098e:	5b                   	pop    %ebx
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	53                   	push   %ebx
  800995:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800998:	53                   	push   %ebx
  800999:	e8 9a ff ff ff       	call   800938 <strlen>
  80099e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009a1:	ff 75 0c             	pushl  0xc(%ebp)
  8009a4:	01 d8                	add    %ebx,%eax
  8009a6:	50                   	push   %eax
  8009a7:	e8 c5 ff ff ff       	call   800971 <strcpy>
	return dst;
}
  8009ac:	89 d8                	mov    %ebx,%eax
  8009ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009b1:	c9                   	leave  
  8009b2:	c3                   	ret    

008009b3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	56                   	push   %esi
  8009b7:	53                   	push   %ebx
  8009b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8009bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009be:	89 f3                	mov    %esi,%ebx
  8009c0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c3:	89 f2                	mov    %esi,%edx
  8009c5:	eb 0f                	jmp    8009d6 <strncpy+0x23>
		*dst++ = *src;
  8009c7:	83 c2 01             	add    $0x1,%edx
  8009ca:	0f b6 01             	movzbl (%ecx),%eax
  8009cd:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009d0:	80 39 01             	cmpb   $0x1,(%ecx)
  8009d3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d6:	39 da                	cmp    %ebx,%edx
  8009d8:	75 ed                	jne    8009c7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009da:	89 f0                	mov    %esi,%eax
  8009dc:	5b                   	pop    %ebx
  8009dd:	5e                   	pop    %esi
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	56                   	push   %esi
  8009e4:	53                   	push   %ebx
  8009e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8009e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009eb:	8b 55 10             	mov    0x10(%ebp),%edx
  8009ee:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009f0:	85 d2                	test   %edx,%edx
  8009f2:	74 21                	je     800a15 <strlcpy+0x35>
  8009f4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009f8:	89 f2                	mov    %esi,%edx
  8009fa:	eb 09                	jmp    800a05 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009fc:	83 c2 01             	add    $0x1,%edx
  8009ff:	83 c1 01             	add    $0x1,%ecx
  800a02:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a05:	39 c2                	cmp    %eax,%edx
  800a07:	74 09                	je     800a12 <strlcpy+0x32>
  800a09:	0f b6 19             	movzbl (%ecx),%ebx
  800a0c:	84 db                	test   %bl,%bl
  800a0e:	75 ec                	jne    8009fc <strlcpy+0x1c>
  800a10:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a12:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a15:	29 f0                	sub    %esi,%eax
}
  800a17:	5b                   	pop    %ebx
  800a18:	5e                   	pop    %esi
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a21:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a24:	eb 06                	jmp    800a2c <strcmp+0x11>
		p++, q++;
  800a26:	83 c1 01             	add    $0x1,%ecx
  800a29:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a2c:	0f b6 01             	movzbl (%ecx),%eax
  800a2f:	84 c0                	test   %al,%al
  800a31:	74 04                	je     800a37 <strcmp+0x1c>
  800a33:	3a 02                	cmp    (%edx),%al
  800a35:	74 ef                	je     800a26 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a37:	0f b6 c0             	movzbl %al,%eax
  800a3a:	0f b6 12             	movzbl (%edx),%edx
  800a3d:	29 d0                	sub    %edx,%eax
}
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	53                   	push   %ebx
  800a45:	8b 45 08             	mov    0x8(%ebp),%eax
  800a48:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4b:	89 c3                	mov    %eax,%ebx
  800a4d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a50:	eb 06                	jmp    800a58 <strncmp+0x17>
		n--, p++, q++;
  800a52:	83 c0 01             	add    $0x1,%eax
  800a55:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a58:	39 d8                	cmp    %ebx,%eax
  800a5a:	74 15                	je     800a71 <strncmp+0x30>
  800a5c:	0f b6 08             	movzbl (%eax),%ecx
  800a5f:	84 c9                	test   %cl,%cl
  800a61:	74 04                	je     800a67 <strncmp+0x26>
  800a63:	3a 0a                	cmp    (%edx),%cl
  800a65:	74 eb                	je     800a52 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a67:	0f b6 00             	movzbl (%eax),%eax
  800a6a:	0f b6 12             	movzbl (%edx),%edx
  800a6d:	29 d0                	sub    %edx,%eax
  800a6f:	eb 05                	jmp    800a76 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a71:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a76:	5b                   	pop    %ebx
  800a77:	5d                   	pop    %ebp
  800a78:	c3                   	ret    

00800a79 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a83:	eb 07                	jmp    800a8c <strchr+0x13>
		if (*s == c)
  800a85:	38 ca                	cmp    %cl,%dl
  800a87:	74 0f                	je     800a98 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a89:	83 c0 01             	add    $0x1,%eax
  800a8c:	0f b6 10             	movzbl (%eax),%edx
  800a8f:	84 d2                	test   %dl,%dl
  800a91:	75 f2                	jne    800a85 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa4:	eb 03                	jmp    800aa9 <strfind+0xf>
  800aa6:	83 c0 01             	add    $0x1,%eax
  800aa9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aac:	38 ca                	cmp    %cl,%dl
  800aae:	74 04                	je     800ab4 <strfind+0x1a>
  800ab0:	84 d2                	test   %dl,%dl
  800ab2:	75 f2                	jne    800aa6 <strfind+0xc>
			break;
	return (char *) s;
}
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	57                   	push   %edi
  800aba:	56                   	push   %esi
  800abb:	53                   	push   %ebx
  800abc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800abf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ac2:	85 c9                	test   %ecx,%ecx
  800ac4:	74 36                	je     800afc <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ac6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800acc:	75 28                	jne    800af6 <memset+0x40>
  800ace:	f6 c1 03             	test   $0x3,%cl
  800ad1:	75 23                	jne    800af6 <memset+0x40>
		c &= 0xFF;
  800ad3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ad7:	89 d3                	mov    %edx,%ebx
  800ad9:	c1 e3 08             	shl    $0x8,%ebx
  800adc:	89 d6                	mov    %edx,%esi
  800ade:	c1 e6 18             	shl    $0x18,%esi
  800ae1:	89 d0                	mov    %edx,%eax
  800ae3:	c1 e0 10             	shl    $0x10,%eax
  800ae6:	09 f0                	or     %esi,%eax
  800ae8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800aea:	89 d8                	mov    %ebx,%eax
  800aec:	09 d0                	or     %edx,%eax
  800aee:	c1 e9 02             	shr    $0x2,%ecx
  800af1:	fc                   	cld    
  800af2:	f3 ab                	rep stos %eax,%es:(%edi)
  800af4:	eb 06                	jmp    800afc <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800af6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af9:	fc                   	cld    
  800afa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800afc:	89 f8                	mov    %edi,%eax
  800afe:	5b                   	pop    %ebx
  800aff:	5e                   	pop    %esi
  800b00:	5f                   	pop    %edi
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	57                   	push   %edi
  800b07:	56                   	push   %esi
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b11:	39 c6                	cmp    %eax,%esi
  800b13:	73 35                	jae    800b4a <memmove+0x47>
  800b15:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b18:	39 d0                	cmp    %edx,%eax
  800b1a:	73 2e                	jae    800b4a <memmove+0x47>
		s += n;
		d += n;
  800b1c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1f:	89 d6                	mov    %edx,%esi
  800b21:	09 fe                	or     %edi,%esi
  800b23:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b29:	75 13                	jne    800b3e <memmove+0x3b>
  800b2b:	f6 c1 03             	test   $0x3,%cl
  800b2e:	75 0e                	jne    800b3e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b30:	83 ef 04             	sub    $0x4,%edi
  800b33:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b36:	c1 e9 02             	shr    $0x2,%ecx
  800b39:	fd                   	std    
  800b3a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3c:	eb 09                	jmp    800b47 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b3e:	83 ef 01             	sub    $0x1,%edi
  800b41:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b44:	fd                   	std    
  800b45:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b47:	fc                   	cld    
  800b48:	eb 1d                	jmp    800b67 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4a:	89 f2                	mov    %esi,%edx
  800b4c:	09 c2                	or     %eax,%edx
  800b4e:	f6 c2 03             	test   $0x3,%dl
  800b51:	75 0f                	jne    800b62 <memmove+0x5f>
  800b53:	f6 c1 03             	test   $0x3,%cl
  800b56:	75 0a                	jne    800b62 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b58:	c1 e9 02             	shr    $0x2,%ecx
  800b5b:	89 c7                	mov    %eax,%edi
  800b5d:	fc                   	cld    
  800b5e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b60:	eb 05                	jmp    800b67 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b62:	89 c7                	mov    %eax,%edi
  800b64:	fc                   	cld    
  800b65:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b67:	5e                   	pop    %esi
  800b68:	5f                   	pop    %edi
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b6e:	ff 75 10             	pushl  0x10(%ebp)
  800b71:	ff 75 0c             	pushl  0xc(%ebp)
  800b74:	ff 75 08             	pushl  0x8(%ebp)
  800b77:	e8 87 ff ff ff       	call   800b03 <memmove>
}
  800b7c:	c9                   	leave  
  800b7d:	c3                   	ret    

00800b7e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
  800b83:	8b 45 08             	mov    0x8(%ebp),%eax
  800b86:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b89:	89 c6                	mov    %eax,%esi
  800b8b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8e:	eb 1a                	jmp    800baa <memcmp+0x2c>
		if (*s1 != *s2)
  800b90:	0f b6 08             	movzbl (%eax),%ecx
  800b93:	0f b6 1a             	movzbl (%edx),%ebx
  800b96:	38 d9                	cmp    %bl,%cl
  800b98:	74 0a                	je     800ba4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b9a:	0f b6 c1             	movzbl %cl,%eax
  800b9d:	0f b6 db             	movzbl %bl,%ebx
  800ba0:	29 d8                	sub    %ebx,%eax
  800ba2:	eb 0f                	jmp    800bb3 <memcmp+0x35>
		s1++, s2++;
  800ba4:	83 c0 01             	add    $0x1,%eax
  800ba7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800baa:	39 f0                	cmp    %esi,%eax
  800bac:	75 e2                	jne    800b90 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	53                   	push   %ebx
  800bbb:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bbe:	89 c1                	mov    %eax,%ecx
  800bc0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bc7:	eb 0a                	jmp    800bd3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc9:	0f b6 10             	movzbl (%eax),%edx
  800bcc:	39 da                	cmp    %ebx,%edx
  800bce:	74 07                	je     800bd7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bd0:	83 c0 01             	add    $0x1,%eax
  800bd3:	39 c8                	cmp    %ecx,%eax
  800bd5:	72 f2                	jb     800bc9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bd7:	5b                   	pop    %ebx
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	57                   	push   %edi
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
  800be0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be6:	eb 03                	jmp    800beb <strtol+0x11>
		s++;
  800be8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800beb:	0f b6 01             	movzbl (%ecx),%eax
  800bee:	3c 20                	cmp    $0x20,%al
  800bf0:	74 f6                	je     800be8 <strtol+0xe>
  800bf2:	3c 09                	cmp    $0x9,%al
  800bf4:	74 f2                	je     800be8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bf6:	3c 2b                	cmp    $0x2b,%al
  800bf8:	75 0a                	jne    800c04 <strtol+0x2a>
		s++;
  800bfa:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bfd:	bf 00 00 00 00       	mov    $0x0,%edi
  800c02:	eb 11                	jmp    800c15 <strtol+0x3b>
  800c04:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c09:	3c 2d                	cmp    $0x2d,%al
  800c0b:	75 08                	jne    800c15 <strtol+0x3b>
		s++, neg = 1;
  800c0d:	83 c1 01             	add    $0x1,%ecx
  800c10:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c15:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c1b:	75 15                	jne    800c32 <strtol+0x58>
  800c1d:	80 39 30             	cmpb   $0x30,(%ecx)
  800c20:	75 10                	jne    800c32 <strtol+0x58>
  800c22:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c26:	75 7c                	jne    800ca4 <strtol+0xca>
		s += 2, base = 16;
  800c28:	83 c1 02             	add    $0x2,%ecx
  800c2b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c30:	eb 16                	jmp    800c48 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c32:	85 db                	test   %ebx,%ebx
  800c34:	75 12                	jne    800c48 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c36:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c3b:	80 39 30             	cmpb   $0x30,(%ecx)
  800c3e:	75 08                	jne    800c48 <strtol+0x6e>
		s++, base = 8;
  800c40:	83 c1 01             	add    $0x1,%ecx
  800c43:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c48:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c50:	0f b6 11             	movzbl (%ecx),%edx
  800c53:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c56:	89 f3                	mov    %esi,%ebx
  800c58:	80 fb 09             	cmp    $0x9,%bl
  800c5b:	77 08                	ja     800c65 <strtol+0x8b>
			dig = *s - '0';
  800c5d:	0f be d2             	movsbl %dl,%edx
  800c60:	83 ea 30             	sub    $0x30,%edx
  800c63:	eb 22                	jmp    800c87 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c65:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c68:	89 f3                	mov    %esi,%ebx
  800c6a:	80 fb 19             	cmp    $0x19,%bl
  800c6d:	77 08                	ja     800c77 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c6f:	0f be d2             	movsbl %dl,%edx
  800c72:	83 ea 57             	sub    $0x57,%edx
  800c75:	eb 10                	jmp    800c87 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c77:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c7a:	89 f3                	mov    %esi,%ebx
  800c7c:	80 fb 19             	cmp    $0x19,%bl
  800c7f:	77 16                	ja     800c97 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c81:	0f be d2             	movsbl %dl,%edx
  800c84:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c87:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c8a:	7d 0b                	jge    800c97 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c8c:	83 c1 01             	add    $0x1,%ecx
  800c8f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c93:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c95:	eb b9                	jmp    800c50 <strtol+0x76>

	if (endptr)
  800c97:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c9b:	74 0d                	je     800caa <strtol+0xd0>
		*endptr = (char *) s;
  800c9d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca0:	89 0e                	mov    %ecx,(%esi)
  800ca2:	eb 06                	jmp    800caa <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca4:	85 db                	test   %ebx,%ebx
  800ca6:	74 98                	je     800c40 <strtol+0x66>
  800ca8:	eb 9e                	jmp    800c48 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800caa:	89 c2                	mov    %eax,%edx
  800cac:	f7 da                	neg    %edx
  800cae:	85 ff                	test   %edi,%edi
  800cb0:	0f 45 c2             	cmovne %edx,%eax
}
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5f                   	pop    %edi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    
  800cb8:	66 90                	xchg   %ax,%ax
  800cba:	66 90                	xchg   %ax,%ax
  800cbc:	66 90                	xchg   %ax,%ax
  800cbe:	66 90                	xchg   %ax,%ax

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
