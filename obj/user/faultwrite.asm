
obj/user/faultwrite：     文件格式 elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0 = 0;
  800036:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80004d:	e8 c6 00 00 00       	call   800118 <sys_getenvid>
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x2d>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
}
  80007e:	83 c4 10             	add    $0x10,%esp
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008e:	6a 00                	push   $0x0
  800090:	e8 42 00 00 00       	call   8000d7 <sys_env_destroy>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	57                   	push   %edi
  80009e:	56                   	push   %esi
  80009f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ab:	89 c3                	mov    %eax,%ebx
  8000ad:	89 c7                	mov    %eax,%edi
  8000af:	89 c6                	mov    %eax,%esi
  8000b1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5f                   	pop    %edi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000be:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c8:	89 d1                	mov    %edx,%ecx
  8000ca:	89 d3                	mov    %edx,%ebx
  8000cc:	89 d7                	mov    %edx,%edi
  8000ce:	89 d6                	mov    %edx,%esi
  8000d0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ed:	89 cb                	mov    %ecx,%ebx
  8000ef:	89 cf                	mov    %ecx,%edi
  8000f1:	89 ce                	mov    %ecx,%esi
  8000f3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	7e 17                	jle    800110 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f9:	83 ec 0c             	sub    $0xc,%esp
  8000fc:	50                   	push   %eax
  8000fd:	6a 03                	push   $0x3
  8000ff:	68 6a 0f 80 00       	push   $0x800f6a
  800104:	6a 23                	push   $0x23
  800106:	68 87 0f 80 00       	push   $0x800f87
  80010b:	e8 f5 01 00 00       	call   800305 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800113:	5b                   	pop    %ebx
  800114:	5e                   	pop    %esi
  800115:	5f                   	pop    %edi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    

00800118 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	57                   	push   %edi
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011e:	ba 00 00 00 00       	mov    $0x0,%edx
  800123:	b8 02 00 00 00       	mov    $0x2,%eax
  800128:	89 d1                	mov    %edx,%ecx
  80012a:	89 d3                	mov    %edx,%ebx
  80012c:	89 d7                	mov    %edx,%edi
  80012e:	89 d6                	mov    %edx,%esi
  800130:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5f                   	pop    %edi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <sys_yield>:

void
sys_yield(void)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	57                   	push   %edi
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013d:	ba 00 00 00 00       	mov    $0x0,%edx
  800142:	b8 0a 00 00 00       	mov    $0xa,%eax
  800147:	89 d1                	mov    %edx,%ecx
  800149:	89 d3                	mov    %edx,%ebx
  80014b:	89 d7                	mov    %edx,%edi
  80014d:	89 d6                	mov    %edx,%esi
  80014f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
  80015c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015f:	be 00 00 00 00       	mov    $0x0,%esi
  800164:	b8 04 00 00 00       	mov    $0x4,%eax
  800169:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800172:	89 f7                	mov    %esi,%edi
  800174:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800176:	85 c0                	test   %eax,%eax
  800178:	7e 17                	jle    800191 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017a:	83 ec 0c             	sub    $0xc,%esp
  80017d:	50                   	push   %eax
  80017e:	6a 04                	push   $0x4
  800180:	68 6a 0f 80 00       	push   $0x800f6a
  800185:	6a 23                	push   $0x23
  800187:	68 87 0f 80 00       	push   $0x800f87
  80018c:	e8 74 01 00 00       	call   800305 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800191:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800194:	5b                   	pop    %ebx
  800195:	5e                   	pop    %esi
  800196:	5f                   	pop    %edi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    

00800199 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001b8:	85 c0                	test   %eax,%eax
  8001ba:	7e 17                	jle    8001d3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	50                   	push   %eax
  8001c0:	6a 05                	push   $0x5
  8001c2:	68 6a 0f 80 00       	push   $0x800f6a
  8001c7:	6a 23                	push   $0x23
  8001c9:	68 87 0f 80 00       	push   $0x800f87
  8001ce:	e8 32 01 00 00       	call   800305 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f4:	89 df                	mov    %ebx,%edi
  8001f6:	89 de                	mov    %ebx,%esi
  8001f8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7e 17                	jle    800215 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	50                   	push   %eax
  800202:	6a 06                	push   $0x6
  800204:	68 6a 0f 80 00       	push   $0x800f6a
  800209:	6a 23                	push   $0x23
  80020b:	68 87 0f 80 00       	push   $0x800f87
  800210:	e8 f0 00 00 00       	call   800305 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800215:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5f                   	pop    %edi
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    

0080021d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	57                   	push   %edi
  800221:	56                   	push   %esi
  800222:	53                   	push   %ebx
  800223:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800226:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022b:	b8 08 00 00 00       	mov    $0x8,%eax
  800230:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800233:	8b 55 08             	mov    0x8(%ebp),%edx
  800236:	89 df                	mov    %ebx,%edi
  800238:	89 de                	mov    %ebx,%esi
  80023a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80023c:	85 c0                	test   %eax,%eax
  80023e:	7e 17                	jle    800257 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	50                   	push   %eax
  800244:	6a 08                	push   $0x8
  800246:	68 6a 0f 80 00       	push   $0x800f6a
  80024b:	6a 23                	push   $0x23
  80024d:	68 87 0f 80 00       	push   $0x800f87
  800252:	e8 ae 00 00 00       	call   800305 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
  800265:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800268:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026d:	b8 09 00 00 00       	mov    $0x9,%eax
  800272:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800275:	8b 55 08             	mov    0x8(%ebp),%edx
  800278:	89 df                	mov    %ebx,%edi
  80027a:	89 de                	mov    %ebx,%esi
  80027c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	7e 17                	jle    800299 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	50                   	push   %eax
  800286:	6a 09                	push   $0x9
  800288:	68 6a 0f 80 00       	push   $0x800f6a
  80028d:	6a 23                	push   $0x23
  80028f:	68 87 0f 80 00       	push   $0x800f87
  800294:	e8 6c 00 00 00       	call   800305 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800299:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029c:	5b                   	pop    %ebx
  80029d:	5e                   	pop    %esi
  80029e:	5f                   	pop    %edi
  80029f:	5d                   	pop    %ebp
  8002a0:	c3                   	ret    

008002a1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a7:	be 00 00 00 00       	mov    $0x0,%esi
  8002ac:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002ba:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002bd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002bf:	5b                   	pop    %ebx
  8002c0:	5e                   	pop    %esi
  8002c1:	5f                   	pop    %edi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	57                   	push   %edi
  8002c8:	56                   	push   %esi
  8002c9:	53                   	push   %ebx
  8002ca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002d2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002da:	89 cb                	mov    %ecx,%ebx
  8002dc:	89 cf                	mov    %ecx,%edi
  8002de:	89 ce                	mov    %ecx,%esi
  8002e0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002e2:	85 c0                	test   %eax,%eax
  8002e4:	7e 17                	jle    8002fd <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e6:	83 ec 0c             	sub    $0xc,%esp
  8002e9:	50                   	push   %eax
  8002ea:	6a 0c                	push   $0xc
  8002ec:	68 6a 0f 80 00       	push   $0x800f6a
  8002f1:	6a 23                	push   $0x23
  8002f3:	68 87 0f 80 00       	push   $0x800f87
  8002f8:	e8 08 00 00 00       	call   800305 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5f                   	pop    %edi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	56                   	push   %esi
  800309:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80030a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80030d:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800313:	e8 00 fe ff ff       	call   800118 <sys_getenvid>
  800318:	83 ec 0c             	sub    $0xc,%esp
  80031b:	ff 75 0c             	pushl  0xc(%ebp)
  80031e:	ff 75 08             	pushl  0x8(%ebp)
  800321:	56                   	push   %esi
  800322:	50                   	push   %eax
  800323:	68 98 0f 80 00       	push   $0x800f98
  800328:	e8 b1 00 00 00       	call   8003de <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80032d:	83 c4 18             	add    $0x18,%esp
  800330:	53                   	push   %ebx
  800331:	ff 75 10             	pushl  0x10(%ebp)
  800334:	e8 54 00 00 00       	call   80038d <vcprintf>
	cprintf("\n");
  800339:	c7 04 24 bc 0f 80 00 	movl   $0x800fbc,(%esp)
  800340:	e8 99 00 00 00       	call   8003de <cprintf>
  800345:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800348:	cc                   	int3   
  800349:	eb fd                	jmp    800348 <_panic+0x43>

0080034b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	53                   	push   %ebx
  80034f:	83 ec 04             	sub    $0x4,%esp
  800352:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800355:	8b 13                	mov    (%ebx),%edx
  800357:	8d 42 01             	lea    0x1(%edx),%eax
  80035a:	89 03                	mov    %eax,(%ebx)
  80035c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80035f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800363:	3d ff 00 00 00       	cmp    $0xff,%eax
  800368:	75 1a                	jne    800384 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80036a:	83 ec 08             	sub    $0x8,%esp
  80036d:	68 ff 00 00 00       	push   $0xff
  800372:	8d 43 08             	lea    0x8(%ebx),%eax
  800375:	50                   	push   %eax
  800376:	e8 1f fd ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  80037b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800381:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800384:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800388:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80038b:	c9                   	leave  
  80038c:	c3                   	ret    

0080038d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80038d:	55                   	push   %ebp
  80038e:	89 e5                	mov    %esp,%ebp
  800390:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800396:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80039d:	00 00 00 
	b.cnt = 0;
  8003a0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003a7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003aa:	ff 75 0c             	pushl  0xc(%ebp)
  8003ad:	ff 75 08             	pushl  0x8(%ebp)
  8003b0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003b6:	50                   	push   %eax
  8003b7:	68 4b 03 80 00       	push   $0x80034b
  8003bc:	e8 54 01 00 00       	call   800515 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003c1:	83 c4 08             	add    $0x8,%esp
  8003c4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003ca:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003d0:	50                   	push   %eax
  8003d1:	e8 c4 fc ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  8003d6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003dc:	c9                   	leave  
  8003dd:	c3                   	ret    

008003de <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003de:	55                   	push   %ebp
  8003df:	89 e5                	mov    %esp,%ebp
  8003e1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003e4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003e7:	50                   	push   %eax
  8003e8:	ff 75 08             	pushl  0x8(%ebp)
  8003eb:	e8 9d ff ff ff       	call   80038d <vcprintf>
	va_end(ap);

	return cnt;
}
  8003f0:	c9                   	leave  
  8003f1:	c3                   	ret    

008003f2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003f2:	55                   	push   %ebp
  8003f3:	89 e5                	mov    %esp,%ebp
  8003f5:	57                   	push   %edi
  8003f6:	56                   	push   %esi
  8003f7:	53                   	push   %ebx
  8003f8:	83 ec 1c             	sub    $0x1c,%esp
  8003fb:	89 c7                	mov    %eax,%edi
  8003fd:	89 d6                	mov    %edx,%esi
  8003ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800402:	8b 55 0c             	mov    0xc(%ebp),%edx
  800405:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800408:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80040b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80040e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800413:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800416:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800419:	39 d3                	cmp    %edx,%ebx
  80041b:	72 05                	jb     800422 <printnum+0x30>
  80041d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800420:	77 45                	ja     800467 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800422:	83 ec 0c             	sub    $0xc,%esp
  800425:	ff 75 18             	pushl  0x18(%ebp)
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80042e:	53                   	push   %ebx
  80042f:	ff 75 10             	pushl  0x10(%ebp)
  800432:	83 ec 08             	sub    $0x8,%esp
  800435:	ff 75 e4             	pushl  -0x1c(%ebp)
  800438:	ff 75 e0             	pushl  -0x20(%ebp)
  80043b:	ff 75 dc             	pushl  -0x24(%ebp)
  80043e:	ff 75 d8             	pushl  -0x28(%ebp)
  800441:	e8 8a 08 00 00       	call   800cd0 <__udivdi3>
  800446:	83 c4 18             	add    $0x18,%esp
  800449:	52                   	push   %edx
  80044a:	50                   	push   %eax
  80044b:	89 f2                	mov    %esi,%edx
  80044d:	89 f8                	mov    %edi,%eax
  80044f:	e8 9e ff ff ff       	call   8003f2 <printnum>
  800454:	83 c4 20             	add    $0x20,%esp
  800457:	eb 18                	jmp    800471 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800459:	83 ec 08             	sub    $0x8,%esp
  80045c:	56                   	push   %esi
  80045d:	ff 75 18             	pushl  0x18(%ebp)
  800460:	ff d7                	call   *%edi
  800462:	83 c4 10             	add    $0x10,%esp
  800465:	eb 03                	jmp    80046a <printnum+0x78>
  800467:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80046a:	83 eb 01             	sub    $0x1,%ebx
  80046d:	85 db                	test   %ebx,%ebx
  80046f:	7f e8                	jg     800459 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	56                   	push   %esi
  800475:	83 ec 04             	sub    $0x4,%esp
  800478:	ff 75 e4             	pushl  -0x1c(%ebp)
  80047b:	ff 75 e0             	pushl  -0x20(%ebp)
  80047e:	ff 75 dc             	pushl  -0x24(%ebp)
  800481:	ff 75 d8             	pushl  -0x28(%ebp)
  800484:	e8 77 09 00 00       	call   800e00 <__umoddi3>
  800489:	83 c4 14             	add    $0x14,%esp
  80048c:	0f be 80 be 0f 80 00 	movsbl 0x800fbe(%eax),%eax
  800493:	50                   	push   %eax
  800494:	ff d7                	call   *%edi
}
  800496:	83 c4 10             	add    $0x10,%esp
  800499:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80049c:	5b                   	pop    %ebx
  80049d:	5e                   	pop    %esi
  80049e:	5f                   	pop    %edi
  80049f:	5d                   	pop    %ebp
  8004a0:	c3                   	ret    

008004a1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004a1:	55                   	push   %ebp
  8004a2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004a4:	83 fa 01             	cmp    $0x1,%edx
  8004a7:	7e 0e                	jle    8004b7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004a9:	8b 10                	mov    (%eax),%edx
  8004ab:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004ae:	89 08                	mov    %ecx,(%eax)
  8004b0:	8b 02                	mov    (%edx),%eax
  8004b2:	8b 52 04             	mov    0x4(%edx),%edx
  8004b5:	eb 22                	jmp    8004d9 <getuint+0x38>
	else if (lflag)
  8004b7:	85 d2                	test   %edx,%edx
  8004b9:	74 10                	je     8004cb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004bb:	8b 10                	mov    (%eax),%edx
  8004bd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c0:	89 08                	mov    %ecx,(%eax)
  8004c2:	8b 02                	mov    (%edx),%eax
  8004c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c9:	eb 0e                	jmp    8004d9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004cb:	8b 10                	mov    (%eax),%edx
  8004cd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d0:	89 08                	mov    %ecx,(%eax)
  8004d2:	8b 02                	mov    (%edx),%eax
  8004d4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004d9:	5d                   	pop    %ebp
  8004da:	c3                   	ret    

008004db <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004db:	55                   	push   %ebp
  8004dc:	89 e5                	mov    %esp,%ebp
  8004de:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004e5:	8b 10                	mov    (%eax),%edx
  8004e7:	3b 50 04             	cmp    0x4(%eax),%edx
  8004ea:	73 0a                	jae    8004f6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ec:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004ef:	89 08                	mov    %ecx,(%eax)
  8004f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f4:	88 02                	mov    %al,(%edx)
}
  8004f6:	5d                   	pop    %ebp
  8004f7:	c3                   	ret    

008004f8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004f8:	55                   	push   %ebp
  8004f9:	89 e5                	mov    %esp,%ebp
  8004fb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004fe:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800501:	50                   	push   %eax
  800502:	ff 75 10             	pushl  0x10(%ebp)
  800505:	ff 75 0c             	pushl  0xc(%ebp)
  800508:	ff 75 08             	pushl  0x8(%ebp)
  80050b:	e8 05 00 00 00       	call   800515 <vprintfmt>
	va_end(ap);
}
  800510:	83 c4 10             	add    $0x10,%esp
  800513:	c9                   	leave  
  800514:	c3                   	ret    

00800515 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800515:	55                   	push   %ebp
  800516:	89 e5                	mov    %esp,%ebp
  800518:	57                   	push   %edi
  800519:	56                   	push   %esi
  80051a:	53                   	push   %ebx
  80051b:	83 ec 2c             	sub    $0x2c,%esp
  80051e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
  800521:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800528:	eb 17                	jmp    800541 <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80052a:	85 c0                	test   %eax,%eax
  80052c:	0f 84 9f 03 00 00    	je     8008d1 <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	ff 75 0c             	pushl  0xc(%ebp)
  800538:	50                   	push   %eax
  800539:	ff 55 08             	call   *0x8(%ebp)
  80053c:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80053f:	89 f3                	mov    %esi,%ebx
  800541:	8d 73 01             	lea    0x1(%ebx),%esi
  800544:	0f b6 03             	movzbl (%ebx),%eax
  800547:	83 f8 25             	cmp    $0x25,%eax
  80054a:	75 de                	jne    80052a <vprintfmt+0x15>
  80054c:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800550:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800557:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80055c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800563:	ba 00 00 00 00       	mov    $0x0,%edx
  800568:	eb 06                	jmp    800570 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80056c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800570:	8d 5e 01             	lea    0x1(%esi),%ebx
  800573:	0f b6 06             	movzbl (%esi),%eax
  800576:	0f b6 c8             	movzbl %al,%ecx
  800579:	83 e8 23             	sub    $0x23,%eax
  80057c:	3c 55                	cmp    $0x55,%al
  80057e:	0f 87 2d 03 00 00    	ja     8008b1 <vprintfmt+0x39c>
  800584:	0f b6 c0             	movzbl %al,%eax
  800587:	ff 24 85 80 10 80 00 	jmp    *0x801080(,%eax,4)
  80058e:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800590:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800594:	eb da                	jmp    800570 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800596:	89 de                	mov    %ebx,%esi
  800598:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80059d:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  8005a0:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  8005a4:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  8005a7:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8005aa:	83 f8 09             	cmp    $0x9,%eax
  8005ad:	77 33                	ja     8005e2 <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005af:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005b2:	eb e9                	jmp    80059d <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8d 48 04             	lea    0x4(%eax),%ecx
  8005ba:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005bd:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bf:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005c1:	eb 1f                	jmp    8005e2 <vprintfmt+0xcd>
  8005c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c6:	85 c0                	test   %eax,%eax
  8005c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005cd:	0f 49 c8             	cmovns %eax,%ecx
  8005d0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d3:	89 de                	mov    %ebx,%esi
  8005d5:	eb 99                	jmp    800570 <vprintfmt+0x5b>
  8005d7:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005d9:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  8005e0:	eb 8e                	jmp    800570 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8005e2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005e6:	79 88                	jns    800570 <vprintfmt+0x5b>
				width = precision, precision = -1;
  8005e8:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8005eb:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8005f0:	e9 7b ff ff ff       	jmp    800570 <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005f5:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f8:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005fa:	e9 71 ff ff ff       	jmp    800570 <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8d 50 04             	lea    0x4(%eax),%edx
  800605:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  800608:	83 ec 08             	sub    $0x8,%esp
  80060b:	ff 75 0c             	pushl  0xc(%ebp)
  80060e:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800611:	03 08                	add    (%eax),%ecx
  800613:	51                   	push   %ecx
  800614:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
  800617:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
  80061a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
  800621:	e9 1b ff ff ff       	jmp    800541 <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8d 48 04             	lea    0x4(%eax),%ecx
  80062c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80062f:	8b 00                	mov    (%eax),%eax
  800631:	83 f8 02             	cmp    $0x2,%eax
  800634:	74 1a                	je     800650 <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800636:	89 de                	mov    %ebx,%esi
  800638:	83 f8 04             	cmp    $0x4,%eax
  80063b:	b8 00 00 00 00       	mov    $0x0,%eax
  800640:	b9 00 04 00 00       	mov    $0x400,%ecx
  800645:	0f 44 c1             	cmove  %ecx,%eax
  800648:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064b:	e9 20 ff ff ff       	jmp    800570 <vprintfmt+0x5b>
  800650:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
  800652:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
  800659:	e9 12 ff ff ff       	jmp    800570 <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 50 04             	lea    0x4(%eax),%edx
  800664:	89 55 14             	mov    %edx,0x14(%ebp)
  800667:	8b 00                	mov    (%eax),%eax
  800669:	99                   	cltd   
  80066a:	31 d0                	xor    %edx,%eax
  80066c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80066e:	83 f8 09             	cmp    $0x9,%eax
  800671:	7f 0b                	jg     80067e <vprintfmt+0x169>
  800673:	8b 14 85 e0 11 80 00 	mov    0x8011e0(,%eax,4),%edx
  80067a:	85 d2                	test   %edx,%edx
  80067c:	75 19                	jne    800697 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  80067e:	50                   	push   %eax
  80067f:	68 d6 0f 80 00       	push   $0x800fd6
  800684:	ff 75 0c             	pushl  0xc(%ebp)
  800687:	ff 75 08             	pushl  0x8(%ebp)
  80068a:	e8 69 fe ff ff       	call   8004f8 <printfmt>
  80068f:	83 c4 10             	add    $0x10,%esp
  800692:	e9 aa fe ff ff       	jmp    800541 <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  800697:	52                   	push   %edx
  800698:	68 df 0f 80 00       	push   $0x800fdf
  80069d:	ff 75 0c             	pushl  0xc(%ebp)
  8006a0:	ff 75 08             	pushl  0x8(%ebp)
  8006a3:	e8 50 fe ff ff       	call   8004f8 <printfmt>
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	e9 91 fe ff ff       	jmp    800541 <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b3:	8d 50 04             	lea    0x4(%eax),%edx
  8006b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b9:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006bb:	85 f6                	test   %esi,%esi
  8006bd:	b8 cf 0f 80 00       	mov    $0x800fcf,%eax
  8006c2:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006c9:	0f 8e 93 00 00 00    	jle    800762 <vprintfmt+0x24d>
  8006cf:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8006d3:	0f 84 91 00 00 00    	je     80076a <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d9:	83 ec 08             	sub    $0x8,%esp
  8006dc:	57                   	push   %edi
  8006dd:	56                   	push   %esi
  8006de:	e8 76 02 00 00       	call   800959 <strnlen>
  8006e3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006e6:	29 c1                	sub    %eax,%ecx
  8006e8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006eb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006ee:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8006f2:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006f5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006f8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8006fb:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006fe:	89 cb                	mov    %ecx,%ebx
  800700:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800702:	eb 0e                	jmp    800712 <vprintfmt+0x1fd>
					putch(padc, putdat);
  800704:	83 ec 08             	sub    $0x8,%esp
  800707:	56                   	push   %esi
  800708:	57                   	push   %edi
  800709:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80070c:	83 eb 01             	sub    $0x1,%ebx
  80070f:	83 c4 10             	add    $0x10,%esp
  800712:	85 db                	test   %ebx,%ebx
  800714:	7f ee                	jg     800704 <vprintfmt+0x1ef>
  800716:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800719:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80071c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80071f:	85 c9                	test   %ecx,%ecx
  800721:	b8 00 00 00 00       	mov    $0x0,%eax
  800726:	0f 49 c1             	cmovns %ecx,%eax
  800729:	29 c1                	sub    %eax,%ecx
  80072b:	89 cb                	mov    %ecx,%ebx
  80072d:	eb 41                	jmp    800770 <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80072f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800733:	74 1b                	je     800750 <vprintfmt+0x23b>
  800735:	0f be c0             	movsbl %al,%eax
  800738:	83 e8 20             	sub    $0x20,%eax
  80073b:	83 f8 5e             	cmp    $0x5e,%eax
  80073e:	76 10                	jbe    800750 <vprintfmt+0x23b>
					putch('?', putdat);
  800740:	83 ec 08             	sub    $0x8,%esp
  800743:	ff 75 0c             	pushl  0xc(%ebp)
  800746:	6a 3f                	push   $0x3f
  800748:	ff 55 08             	call   *0x8(%ebp)
  80074b:	83 c4 10             	add    $0x10,%esp
  80074e:	eb 0d                	jmp    80075d <vprintfmt+0x248>
				else
					putch(ch, putdat);
  800750:	83 ec 08             	sub    $0x8,%esp
  800753:	ff 75 0c             	pushl  0xc(%ebp)
  800756:	52                   	push   %edx
  800757:	ff 55 08             	call   *0x8(%ebp)
  80075a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80075d:	83 eb 01             	sub    $0x1,%ebx
  800760:	eb 0e                	jmp    800770 <vprintfmt+0x25b>
  800762:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800765:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800768:	eb 06                	jmp    800770 <vprintfmt+0x25b>
  80076a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80076d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800770:	83 c6 01             	add    $0x1,%esi
  800773:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800777:	0f be d0             	movsbl %al,%edx
  80077a:	85 d2                	test   %edx,%edx
  80077c:	74 25                	je     8007a3 <vprintfmt+0x28e>
  80077e:	85 ff                	test   %edi,%edi
  800780:	78 ad                	js     80072f <vprintfmt+0x21a>
  800782:	83 ef 01             	sub    $0x1,%edi
  800785:	79 a8                	jns    80072f <vprintfmt+0x21a>
  800787:	89 d8                	mov    %ebx,%eax
  800789:	8b 75 08             	mov    0x8(%ebp),%esi
  80078c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80078f:	89 c3                	mov    %eax,%ebx
  800791:	eb 16                	jmp    8007a9 <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800793:	83 ec 08             	sub    $0x8,%esp
  800796:	57                   	push   %edi
  800797:	6a 20                	push   $0x20
  800799:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80079b:	83 eb 01             	sub    $0x1,%ebx
  80079e:	83 c4 10             	add    $0x10,%esp
  8007a1:	eb 06                	jmp    8007a9 <vprintfmt+0x294>
  8007a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8007a9:	85 db                	test   %ebx,%ebx
  8007ab:	7f e6                	jg     800793 <vprintfmt+0x27e>
  8007ad:	89 75 08             	mov    %esi,0x8(%ebp)
  8007b0:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8007b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007b6:	e9 86 fd ff ff       	jmp    800541 <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007bb:	83 fa 01             	cmp    $0x1,%edx
  8007be:	7e 10                	jle    8007d0 <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
  8007c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c3:	8d 50 08             	lea    0x8(%eax),%edx
  8007c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c9:	8b 30                	mov    (%eax),%esi
  8007cb:	8b 78 04             	mov    0x4(%eax),%edi
  8007ce:	eb 26                	jmp    8007f6 <vprintfmt+0x2e1>
	else if (lflag)
  8007d0:	85 d2                	test   %edx,%edx
  8007d2:	74 12                	je     8007e6 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  8007d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d7:	8d 50 04             	lea    0x4(%eax),%edx
  8007da:	89 55 14             	mov    %edx,0x14(%ebp)
  8007dd:	8b 30                	mov    (%eax),%esi
  8007df:	89 f7                	mov    %esi,%edi
  8007e1:	c1 ff 1f             	sar    $0x1f,%edi
  8007e4:	eb 10                	jmp    8007f6 <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
  8007e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e9:	8d 50 04             	lea    0x4(%eax),%edx
  8007ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ef:	8b 30                	mov    (%eax),%esi
  8007f1:	89 f7                	mov    %esi,%edi
  8007f3:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007f6:	89 f0                	mov    %esi,%eax
  8007f8:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007fa:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007ff:	85 ff                	test   %edi,%edi
  800801:	79 7b                	jns    80087e <vprintfmt+0x369>
				putch('-', putdat);
  800803:	83 ec 08             	sub    $0x8,%esp
  800806:	ff 75 0c             	pushl  0xc(%ebp)
  800809:	6a 2d                	push   $0x2d
  80080b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80080e:	89 f0                	mov    %esi,%eax
  800810:	89 fa                	mov    %edi,%edx
  800812:	f7 d8                	neg    %eax
  800814:	83 d2 00             	adc    $0x0,%edx
  800817:	f7 da                	neg    %edx
  800819:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80081c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800821:	eb 5b                	jmp    80087e <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800823:	8d 45 14             	lea    0x14(%ebp),%eax
  800826:	e8 76 fc ff ff       	call   8004a1 <getuint>
			base = 10;
  80082b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800830:	eb 4c                	jmp    80087e <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
  800832:	8d 45 14             	lea    0x14(%ebp),%eax
  800835:	e8 67 fc ff ff       	call   8004a1 <getuint>
            base = 8;
  80083a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80083f:	eb 3d                	jmp    80087e <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
  800841:	83 ec 08             	sub    $0x8,%esp
  800844:	ff 75 0c             	pushl  0xc(%ebp)
  800847:	6a 30                	push   $0x30
  800849:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80084c:	83 c4 08             	add    $0x8,%esp
  80084f:	ff 75 0c             	pushl  0xc(%ebp)
  800852:	6a 78                	push   $0x78
  800854:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800857:	8b 45 14             	mov    0x14(%ebp),%eax
  80085a:	8d 50 04             	lea    0x4(%eax),%edx
  80085d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800860:	8b 00                	mov    (%eax),%eax
  800862:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800867:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80086a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80086f:	eb 0d                	jmp    80087e <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800871:	8d 45 14             	lea    0x14(%ebp),%eax
  800874:	e8 28 fc ff ff       	call   8004a1 <getuint>
			base = 16;
  800879:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80087e:	83 ec 0c             	sub    $0xc,%esp
  800881:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  800885:	56                   	push   %esi
  800886:	ff 75 e0             	pushl  -0x20(%ebp)
  800889:	51                   	push   %ecx
  80088a:	52                   	push   %edx
  80088b:	50                   	push   %eax
  80088c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	e8 5b fb ff ff       	call   8003f2 <printnum>
			break;
  800897:	83 c4 20             	add    $0x20,%esp
  80089a:	e9 a2 fc ff ff       	jmp    800541 <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80089f:	83 ec 08             	sub    $0x8,%esp
  8008a2:	ff 75 0c             	pushl  0xc(%ebp)
  8008a5:	51                   	push   %ecx
  8008a6:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008a9:	83 c4 10             	add    $0x10,%esp
  8008ac:	e9 90 fc ff ff       	jmp    800541 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008b1:	83 ec 08             	sub    $0x8,%esp
  8008b4:	ff 75 0c             	pushl  0xc(%ebp)
  8008b7:	6a 25                	push   $0x25
  8008b9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008bc:	83 c4 10             	add    $0x10,%esp
  8008bf:	89 f3                	mov    %esi,%ebx
  8008c1:	eb 03                	jmp    8008c6 <vprintfmt+0x3b1>
  8008c3:	83 eb 01             	sub    $0x1,%ebx
  8008c6:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8008ca:	75 f7                	jne    8008c3 <vprintfmt+0x3ae>
  8008cc:	e9 70 fc ff ff       	jmp    800541 <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  8008d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008d4:	5b                   	pop    %ebx
  8008d5:	5e                   	pop    %esi
  8008d6:	5f                   	pop    %edi
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    

008008d9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	83 ec 18             	sub    $0x18,%esp
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008e8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008ec:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008f6:	85 c0                	test   %eax,%eax
  8008f8:	74 26                	je     800920 <vsnprintf+0x47>
  8008fa:	85 d2                	test   %edx,%edx
  8008fc:	7e 22                	jle    800920 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008fe:	ff 75 14             	pushl  0x14(%ebp)
  800901:	ff 75 10             	pushl  0x10(%ebp)
  800904:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800907:	50                   	push   %eax
  800908:	68 db 04 80 00       	push   $0x8004db
  80090d:	e8 03 fc ff ff       	call   800515 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800912:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800915:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800918:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80091b:	83 c4 10             	add    $0x10,%esp
  80091e:	eb 05                	jmp    800925 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800920:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800925:	c9                   	leave  
  800926:	c3                   	ret    

00800927 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80092d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800930:	50                   	push   %eax
  800931:	ff 75 10             	pushl  0x10(%ebp)
  800934:	ff 75 0c             	pushl  0xc(%ebp)
  800937:	ff 75 08             	pushl  0x8(%ebp)
  80093a:	e8 9a ff ff ff       	call   8008d9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80093f:	c9                   	leave  
  800940:	c3                   	ret    

00800941 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800947:	b8 00 00 00 00       	mov    $0x0,%eax
  80094c:	eb 03                	jmp    800951 <strlen+0x10>
		n++;
  80094e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800951:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800955:	75 f7                	jne    80094e <strlen+0xd>
		n++;
	return n;
}
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800962:	ba 00 00 00 00       	mov    $0x0,%edx
  800967:	eb 03                	jmp    80096c <strnlen+0x13>
		n++;
  800969:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80096c:	39 c2                	cmp    %eax,%edx
  80096e:	74 08                	je     800978 <strnlen+0x1f>
  800970:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800974:	75 f3                	jne    800969 <strnlen+0x10>
  800976:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	53                   	push   %ebx
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800984:	89 c2                	mov    %eax,%edx
  800986:	83 c2 01             	add    $0x1,%edx
  800989:	83 c1 01             	add    $0x1,%ecx
  80098c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800990:	88 5a ff             	mov    %bl,-0x1(%edx)
  800993:	84 db                	test   %bl,%bl
  800995:	75 ef                	jne    800986 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800997:	5b                   	pop    %ebx
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	53                   	push   %ebx
  80099e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009a1:	53                   	push   %ebx
  8009a2:	e8 9a ff ff ff       	call   800941 <strlen>
  8009a7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009aa:	ff 75 0c             	pushl  0xc(%ebp)
  8009ad:	01 d8                	add    %ebx,%eax
  8009af:	50                   	push   %eax
  8009b0:	e8 c5 ff ff ff       	call   80097a <strcpy>
	return dst;
}
  8009b5:	89 d8                	mov    %ebx,%eax
  8009b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ba:	c9                   	leave  
  8009bb:	c3                   	ret    

008009bc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	56                   	push   %esi
  8009c0:	53                   	push   %ebx
  8009c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c7:	89 f3                	mov    %esi,%ebx
  8009c9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009cc:	89 f2                	mov    %esi,%edx
  8009ce:	eb 0f                	jmp    8009df <strncpy+0x23>
		*dst++ = *src;
  8009d0:	83 c2 01             	add    $0x1,%edx
  8009d3:	0f b6 01             	movzbl (%ecx),%eax
  8009d6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009d9:	80 39 01             	cmpb   $0x1,(%ecx)
  8009dc:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009df:	39 da                	cmp    %ebx,%edx
  8009e1:	75 ed                	jne    8009d0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009e3:	89 f0                	mov    %esi,%eax
  8009e5:	5b                   	pop    %ebx
  8009e6:	5e                   	pop    %esi
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	56                   	push   %esi
  8009ed:	53                   	push   %ebx
  8009ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f4:	8b 55 10             	mov    0x10(%ebp),%edx
  8009f7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009f9:	85 d2                	test   %edx,%edx
  8009fb:	74 21                	je     800a1e <strlcpy+0x35>
  8009fd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a01:	89 f2                	mov    %esi,%edx
  800a03:	eb 09                	jmp    800a0e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a05:	83 c2 01             	add    $0x1,%edx
  800a08:	83 c1 01             	add    $0x1,%ecx
  800a0b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a0e:	39 c2                	cmp    %eax,%edx
  800a10:	74 09                	je     800a1b <strlcpy+0x32>
  800a12:	0f b6 19             	movzbl (%ecx),%ebx
  800a15:	84 db                	test   %bl,%bl
  800a17:	75 ec                	jne    800a05 <strlcpy+0x1c>
  800a19:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a1b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a1e:	29 f0                	sub    %esi,%eax
}
  800a20:	5b                   	pop    %ebx
  800a21:	5e                   	pop    %esi
  800a22:	5d                   	pop    %ebp
  800a23:	c3                   	ret    

00800a24 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a2d:	eb 06                	jmp    800a35 <strcmp+0x11>
		p++, q++;
  800a2f:	83 c1 01             	add    $0x1,%ecx
  800a32:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a35:	0f b6 01             	movzbl (%ecx),%eax
  800a38:	84 c0                	test   %al,%al
  800a3a:	74 04                	je     800a40 <strcmp+0x1c>
  800a3c:	3a 02                	cmp    (%edx),%al
  800a3e:	74 ef                	je     800a2f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a40:	0f b6 c0             	movzbl %al,%eax
  800a43:	0f b6 12             	movzbl (%edx),%edx
  800a46:	29 d0                	sub    %edx,%eax
}
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	53                   	push   %ebx
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a51:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a54:	89 c3                	mov    %eax,%ebx
  800a56:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a59:	eb 06                	jmp    800a61 <strncmp+0x17>
		n--, p++, q++;
  800a5b:	83 c0 01             	add    $0x1,%eax
  800a5e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a61:	39 d8                	cmp    %ebx,%eax
  800a63:	74 15                	je     800a7a <strncmp+0x30>
  800a65:	0f b6 08             	movzbl (%eax),%ecx
  800a68:	84 c9                	test   %cl,%cl
  800a6a:	74 04                	je     800a70 <strncmp+0x26>
  800a6c:	3a 0a                	cmp    (%edx),%cl
  800a6e:	74 eb                	je     800a5b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a70:	0f b6 00             	movzbl (%eax),%eax
  800a73:	0f b6 12             	movzbl (%edx),%edx
  800a76:	29 d0                	sub    %edx,%eax
  800a78:	eb 05                	jmp    800a7f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a7a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a7f:	5b                   	pop    %ebx
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	8b 45 08             	mov    0x8(%ebp),%eax
  800a88:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a8c:	eb 07                	jmp    800a95 <strchr+0x13>
		if (*s == c)
  800a8e:	38 ca                	cmp    %cl,%dl
  800a90:	74 0f                	je     800aa1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a92:	83 c0 01             	add    $0x1,%eax
  800a95:	0f b6 10             	movzbl (%eax),%edx
  800a98:	84 d2                	test   %dl,%dl
  800a9a:	75 f2                	jne    800a8e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aad:	eb 03                	jmp    800ab2 <strfind+0xf>
  800aaf:	83 c0 01             	add    $0x1,%eax
  800ab2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ab5:	38 ca                	cmp    %cl,%dl
  800ab7:	74 04                	je     800abd <strfind+0x1a>
  800ab9:	84 d2                	test   %dl,%dl
  800abb:	75 f2                	jne    800aaf <strfind+0xc>
			break;
	return (char *) s;
}
  800abd:	5d                   	pop    %ebp
  800abe:	c3                   	ret    

00800abf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	57                   	push   %edi
  800ac3:	56                   	push   %esi
  800ac4:	53                   	push   %ebx
  800ac5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ac8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800acb:	85 c9                	test   %ecx,%ecx
  800acd:	74 36                	je     800b05 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800acf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ad5:	75 28                	jne    800aff <memset+0x40>
  800ad7:	f6 c1 03             	test   $0x3,%cl
  800ada:	75 23                	jne    800aff <memset+0x40>
		c &= 0xFF;
  800adc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ae0:	89 d3                	mov    %edx,%ebx
  800ae2:	c1 e3 08             	shl    $0x8,%ebx
  800ae5:	89 d6                	mov    %edx,%esi
  800ae7:	c1 e6 18             	shl    $0x18,%esi
  800aea:	89 d0                	mov    %edx,%eax
  800aec:	c1 e0 10             	shl    $0x10,%eax
  800aef:	09 f0                	or     %esi,%eax
  800af1:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800af3:	89 d8                	mov    %ebx,%eax
  800af5:	09 d0                	or     %edx,%eax
  800af7:	c1 e9 02             	shr    $0x2,%ecx
  800afa:	fc                   	cld    
  800afb:	f3 ab                	rep stos %eax,%es:(%edi)
  800afd:	eb 06                	jmp    800b05 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b02:	fc                   	cld    
  800b03:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b05:	89 f8                	mov    %edi,%eax
  800b07:	5b                   	pop    %ebx
  800b08:	5e                   	pop    %esi
  800b09:	5f                   	pop    %edi
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	8b 45 08             	mov    0x8(%ebp),%eax
  800b14:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b17:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b1a:	39 c6                	cmp    %eax,%esi
  800b1c:	73 35                	jae    800b53 <memmove+0x47>
  800b1e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b21:	39 d0                	cmp    %edx,%eax
  800b23:	73 2e                	jae    800b53 <memmove+0x47>
		s += n;
		d += n;
  800b25:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b28:	89 d6                	mov    %edx,%esi
  800b2a:	09 fe                	or     %edi,%esi
  800b2c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b32:	75 13                	jne    800b47 <memmove+0x3b>
  800b34:	f6 c1 03             	test   $0x3,%cl
  800b37:	75 0e                	jne    800b47 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b39:	83 ef 04             	sub    $0x4,%edi
  800b3c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b3f:	c1 e9 02             	shr    $0x2,%ecx
  800b42:	fd                   	std    
  800b43:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b45:	eb 09                	jmp    800b50 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b47:	83 ef 01             	sub    $0x1,%edi
  800b4a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b4d:	fd                   	std    
  800b4e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b50:	fc                   	cld    
  800b51:	eb 1d                	jmp    800b70 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b53:	89 f2                	mov    %esi,%edx
  800b55:	09 c2                	or     %eax,%edx
  800b57:	f6 c2 03             	test   $0x3,%dl
  800b5a:	75 0f                	jne    800b6b <memmove+0x5f>
  800b5c:	f6 c1 03             	test   $0x3,%cl
  800b5f:	75 0a                	jne    800b6b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b61:	c1 e9 02             	shr    $0x2,%ecx
  800b64:	89 c7                	mov    %eax,%edi
  800b66:	fc                   	cld    
  800b67:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b69:	eb 05                	jmp    800b70 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b6b:	89 c7                	mov    %eax,%edi
  800b6d:	fc                   	cld    
  800b6e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b77:	ff 75 10             	pushl  0x10(%ebp)
  800b7a:	ff 75 0c             	pushl  0xc(%ebp)
  800b7d:	ff 75 08             	pushl  0x8(%ebp)
  800b80:	e8 87 ff ff ff       	call   800b0c <memmove>
}
  800b85:	c9                   	leave  
  800b86:	c3                   	ret    

00800b87 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
  800b8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b92:	89 c6                	mov    %eax,%esi
  800b94:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b97:	eb 1a                	jmp    800bb3 <memcmp+0x2c>
		if (*s1 != *s2)
  800b99:	0f b6 08             	movzbl (%eax),%ecx
  800b9c:	0f b6 1a             	movzbl (%edx),%ebx
  800b9f:	38 d9                	cmp    %bl,%cl
  800ba1:	74 0a                	je     800bad <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ba3:	0f b6 c1             	movzbl %cl,%eax
  800ba6:	0f b6 db             	movzbl %bl,%ebx
  800ba9:	29 d8                	sub    %ebx,%eax
  800bab:	eb 0f                	jmp    800bbc <memcmp+0x35>
		s1++, s2++;
  800bad:	83 c0 01             	add    $0x1,%eax
  800bb0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bb3:	39 f0                	cmp    %esi,%eax
  800bb5:	75 e2                	jne    800b99 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bb7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	53                   	push   %ebx
  800bc4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bc7:	89 c1                	mov    %eax,%ecx
  800bc9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bcc:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bd0:	eb 0a                	jmp    800bdc <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd2:	0f b6 10             	movzbl (%eax),%edx
  800bd5:	39 da                	cmp    %ebx,%edx
  800bd7:	74 07                	je     800be0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bd9:	83 c0 01             	add    $0x1,%eax
  800bdc:	39 c8                	cmp    %ecx,%eax
  800bde:	72 f2                	jb     800bd2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800be0:	5b                   	pop    %ebx
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bef:	eb 03                	jmp    800bf4 <strtol+0x11>
		s++;
  800bf1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf4:	0f b6 01             	movzbl (%ecx),%eax
  800bf7:	3c 20                	cmp    $0x20,%al
  800bf9:	74 f6                	je     800bf1 <strtol+0xe>
  800bfb:	3c 09                	cmp    $0x9,%al
  800bfd:	74 f2                	je     800bf1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bff:	3c 2b                	cmp    $0x2b,%al
  800c01:	75 0a                	jne    800c0d <strtol+0x2a>
		s++;
  800c03:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c06:	bf 00 00 00 00       	mov    $0x0,%edi
  800c0b:	eb 11                	jmp    800c1e <strtol+0x3b>
  800c0d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c12:	3c 2d                	cmp    $0x2d,%al
  800c14:	75 08                	jne    800c1e <strtol+0x3b>
		s++, neg = 1;
  800c16:	83 c1 01             	add    $0x1,%ecx
  800c19:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c1e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c24:	75 15                	jne    800c3b <strtol+0x58>
  800c26:	80 39 30             	cmpb   $0x30,(%ecx)
  800c29:	75 10                	jne    800c3b <strtol+0x58>
  800c2b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c2f:	75 7c                	jne    800cad <strtol+0xca>
		s += 2, base = 16;
  800c31:	83 c1 02             	add    $0x2,%ecx
  800c34:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c39:	eb 16                	jmp    800c51 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c3b:	85 db                	test   %ebx,%ebx
  800c3d:	75 12                	jne    800c51 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c3f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c44:	80 39 30             	cmpb   $0x30,(%ecx)
  800c47:	75 08                	jne    800c51 <strtol+0x6e>
		s++, base = 8;
  800c49:	83 c1 01             	add    $0x1,%ecx
  800c4c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c51:	b8 00 00 00 00       	mov    $0x0,%eax
  800c56:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c59:	0f b6 11             	movzbl (%ecx),%edx
  800c5c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c5f:	89 f3                	mov    %esi,%ebx
  800c61:	80 fb 09             	cmp    $0x9,%bl
  800c64:	77 08                	ja     800c6e <strtol+0x8b>
			dig = *s - '0';
  800c66:	0f be d2             	movsbl %dl,%edx
  800c69:	83 ea 30             	sub    $0x30,%edx
  800c6c:	eb 22                	jmp    800c90 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c6e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c71:	89 f3                	mov    %esi,%ebx
  800c73:	80 fb 19             	cmp    $0x19,%bl
  800c76:	77 08                	ja     800c80 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c78:	0f be d2             	movsbl %dl,%edx
  800c7b:	83 ea 57             	sub    $0x57,%edx
  800c7e:	eb 10                	jmp    800c90 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c80:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c83:	89 f3                	mov    %esi,%ebx
  800c85:	80 fb 19             	cmp    $0x19,%bl
  800c88:	77 16                	ja     800ca0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c8a:	0f be d2             	movsbl %dl,%edx
  800c8d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c90:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c93:	7d 0b                	jge    800ca0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c95:	83 c1 01             	add    $0x1,%ecx
  800c98:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c9c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c9e:	eb b9                	jmp    800c59 <strtol+0x76>

	if (endptr)
  800ca0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ca4:	74 0d                	je     800cb3 <strtol+0xd0>
		*endptr = (char *) s;
  800ca6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca9:	89 0e                	mov    %ecx,(%esi)
  800cab:	eb 06                	jmp    800cb3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cad:	85 db                	test   %ebx,%ebx
  800caf:	74 98                	je     800c49 <strtol+0x66>
  800cb1:	eb 9e                	jmp    800c51 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cb3:	89 c2                	mov    %eax,%edx
  800cb5:	f7 da                	neg    %edx
  800cb7:	85 ff                	test   %edi,%edi
  800cb9:	0f 45 c2             	cmovne %edx,%eax
}
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    
  800cc1:	66 90                	xchg   %ax,%ax
  800cc3:	66 90                	xchg   %ax,%ax
  800cc5:	66 90                	xchg   %ax,%ax
  800cc7:	66 90                	xchg   %ax,%ax
  800cc9:	66 90                	xchg   %ax,%ax
  800ccb:	66 90                	xchg   %ax,%ax
  800ccd:	66 90                	xchg   %ax,%ax
  800ccf:	90                   	nop

00800cd0 <__udivdi3>:
  800cd0:	55                   	push   %ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
  800cd4:	83 ec 1c             	sub    $0x1c,%esp
  800cd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800cdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800cdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800ce3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ce7:	85 f6                	test   %esi,%esi
  800ce9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ced:	89 ca                	mov    %ecx,%edx
  800cef:	89 f8                	mov    %edi,%eax
  800cf1:	75 3d                	jne    800d30 <__udivdi3+0x60>
  800cf3:	39 cf                	cmp    %ecx,%edi
  800cf5:	0f 87 c5 00 00 00    	ja     800dc0 <__udivdi3+0xf0>
  800cfb:	85 ff                	test   %edi,%edi
  800cfd:	89 fd                	mov    %edi,%ebp
  800cff:	75 0b                	jne    800d0c <__udivdi3+0x3c>
  800d01:	b8 01 00 00 00       	mov    $0x1,%eax
  800d06:	31 d2                	xor    %edx,%edx
  800d08:	f7 f7                	div    %edi
  800d0a:	89 c5                	mov    %eax,%ebp
  800d0c:	89 c8                	mov    %ecx,%eax
  800d0e:	31 d2                	xor    %edx,%edx
  800d10:	f7 f5                	div    %ebp
  800d12:	89 c1                	mov    %eax,%ecx
  800d14:	89 d8                	mov    %ebx,%eax
  800d16:	89 cf                	mov    %ecx,%edi
  800d18:	f7 f5                	div    %ebp
  800d1a:	89 c3                	mov    %eax,%ebx
  800d1c:	89 d8                	mov    %ebx,%eax
  800d1e:	89 fa                	mov    %edi,%edx
  800d20:	83 c4 1c             	add    $0x1c,%esp
  800d23:	5b                   	pop    %ebx
  800d24:	5e                   	pop    %esi
  800d25:	5f                   	pop    %edi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    
  800d28:	90                   	nop
  800d29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d30:	39 ce                	cmp    %ecx,%esi
  800d32:	77 74                	ja     800da8 <__udivdi3+0xd8>
  800d34:	0f bd fe             	bsr    %esi,%edi
  800d37:	83 f7 1f             	xor    $0x1f,%edi
  800d3a:	0f 84 98 00 00 00    	je     800dd8 <__udivdi3+0x108>
  800d40:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d45:	89 f9                	mov    %edi,%ecx
  800d47:	89 c5                	mov    %eax,%ebp
  800d49:	29 fb                	sub    %edi,%ebx
  800d4b:	d3 e6                	shl    %cl,%esi
  800d4d:	89 d9                	mov    %ebx,%ecx
  800d4f:	d3 ed                	shr    %cl,%ebp
  800d51:	89 f9                	mov    %edi,%ecx
  800d53:	d3 e0                	shl    %cl,%eax
  800d55:	09 ee                	or     %ebp,%esi
  800d57:	89 d9                	mov    %ebx,%ecx
  800d59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d5d:	89 d5                	mov    %edx,%ebp
  800d5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d63:	d3 ed                	shr    %cl,%ebp
  800d65:	89 f9                	mov    %edi,%ecx
  800d67:	d3 e2                	shl    %cl,%edx
  800d69:	89 d9                	mov    %ebx,%ecx
  800d6b:	d3 e8                	shr    %cl,%eax
  800d6d:	09 c2                	or     %eax,%edx
  800d6f:	89 d0                	mov    %edx,%eax
  800d71:	89 ea                	mov    %ebp,%edx
  800d73:	f7 f6                	div    %esi
  800d75:	89 d5                	mov    %edx,%ebp
  800d77:	89 c3                	mov    %eax,%ebx
  800d79:	f7 64 24 0c          	mull   0xc(%esp)
  800d7d:	39 d5                	cmp    %edx,%ebp
  800d7f:	72 10                	jb     800d91 <__udivdi3+0xc1>
  800d81:	8b 74 24 08          	mov    0x8(%esp),%esi
  800d85:	89 f9                	mov    %edi,%ecx
  800d87:	d3 e6                	shl    %cl,%esi
  800d89:	39 c6                	cmp    %eax,%esi
  800d8b:	73 07                	jae    800d94 <__udivdi3+0xc4>
  800d8d:	39 d5                	cmp    %edx,%ebp
  800d8f:	75 03                	jne    800d94 <__udivdi3+0xc4>
  800d91:	83 eb 01             	sub    $0x1,%ebx
  800d94:	31 ff                	xor    %edi,%edi
  800d96:	89 d8                	mov    %ebx,%eax
  800d98:	89 fa                	mov    %edi,%edx
  800d9a:	83 c4 1c             	add    $0x1c,%esp
  800d9d:	5b                   	pop    %ebx
  800d9e:	5e                   	pop    %esi
  800d9f:	5f                   	pop    %edi
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    
  800da2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800da8:	31 ff                	xor    %edi,%edi
  800daa:	31 db                	xor    %ebx,%ebx
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
  800dc0:	89 d8                	mov    %ebx,%eax
  800dc2:	f7 f7                	div    %edi
  800dc4:	31 ff                	xor    %edi,%edi
  800dc6:	89 c3                	mov    %eax,%ebx
  800dc8:	89 d8                	mov    %ebx,%eax
  800dca:	89 fa                	mov    %edi,%edx
  800dcc:	83 c4 1c             	add    $0x1c,%esp
  800dcf:	5b                   	pop    %ebx
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    
  800dd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800dd8:	39 ce                	cmp    %ecx,%esi
  800dda:	72 0c                	jb     800de8 <__udivdi3+0x118>
  800ddc:	31 db                	xor    %ebx,%ebx
  800dde:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800de2:	0f 87 34 ff ff ff    	ja     800d1c <__udivdi3+0x4c>
  800de8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800ded:	e9 2a ff ff ff       	jmp    800d1c <__udivdi3+0x4c>
  800df2:	66 90                	xchg   %ax,%ax
  800df4:	66 90                	xchg   %ax,%ax
  800df6:	66 90                	xchg   %ax,%ax
  800df8:	66 90                	xchg   %ax,%ax
  800dfa:	66 90                	xchg   %ax,%ax
  800dfc:	66 90                	xchg   %ax,%ax
  800dfe:	66 90                	xchg   %ax,%ax

00800e00 <__umoddi3>:
  800e00:	55                   	push   %ebp
  800e01:	57                   	push   %edi
  800e02:	56                   	push   %esi
  800e03:	53                   	push   %ebx
  800e04:	83 ec 1c             	sub    $0x1c,%esp
  800e07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e17:	85 d2                	test   %edx,%edx
  800e19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e21:	89 f3                	mov    %esi,%ebx
  800e23:	89 3c 24             	mov    %edi,(%esp)
  800e26:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e2a:	75 1c                	jne    800e48 <__umoddi3+0x48>
  800e2c:	39 f7                	cmp    %esi,%edi
  800e2e:	76 50                	jbe    800e80 <__umoddi3+0x80>
  800e30:	89 c8                	mov    %ecx,%eax
  800e32:	89 f2                	mov    %esi,%edx
  800e34:	f7 f7                	div    %edi
  800e36:	89 d0                	mov    %edx,%eax
  800e38:	31 d2                	xor    %edx,%edx
  800e3a:	83 c4 1c             	add    $0x1c,%esp
  800e3d:	5b                   	pop    %ebx
  800e3e:	5e                   	pop    %esi
  800e3f:	5f                   	pop    %edi
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    
  800e42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e48:	39 f2                	cmp    %esi,%edx
  800e4a:	89 d0                	mov    %edx,%eax
  800e4c:	77 52                	ja     800ea0 <__umoddi3+0xa0>
  800e4e:	0f bd ea             	bsr    %edx,%ebp
  800e51:	83 f5 1f             	xor    $0x1f,%ebp
  800e54:	75 5a                	jne    800eb0 <__umoddi3+0xb0>
  800e56:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800e5a:	0f 82 e0 00 00 00    	jb     800f40 <__umoddi3+0x140>
  800e60:	39 0c 24             	cmp    %ecx,(%esp)
  800e63:	0f 86 d7 00 00 00    	jbe    800f40 <__umoddi3+0x140>
  800e69:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e6d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e71:	83 c4 1c             	add    $0x1c,%esp
  800e74:	5b                   	pop    %ebx
  800e75:	5e                   	pop    %esi
  800e76:	5f                   	pop    %edi
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    
  800e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e80:	85 ff                	test   %edi,%edi
  800e82:	89 fd                	mov    %edi,%ebp
  800e84:	75 0b                	jne    800e91 <__umoddi3+0x91>
  800e86:	b8 01 00 00 00       	mov    $0x1,%eax
  800e8b:	31 d2                	xor    %edx,%edx
  800e8d:	f7 f7                	div    %edi
  800e8f:	89 c5                	mov    %eax,%ebp
  800e91:	89 f0                	mov    %esi,%eax
  800e93:	31 d2                	xor    %edx,%edx
  800e95:	f7 f5                	div    %ebp
  800e97:	89 c8                	mov    %ecx,%eax
  800e99:	f7 f5                	div    %ebp
  800e9b:	89 d0                	mov    %edx,%eax
  800e9d:	eb 99                	jmp    800e38 <__umoddi3+0x38>
  800e9f:	90                   	nop
  800ea0:	89 c8                	mov    %ecx,%eax
  800ea2:	89 f2                	mov    %esi,%edx
  800ea4:	83 c4 1c             	add    $0x1c,%esp
  800ea7:	5b                   	pop    %ebx
  800ea8:	5e                   	pop    %esi
  800ea9:	5f                   	pop    %edi
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    
  800eac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	8b 34 24             	mov    (%esp),%esi
  800eb3:	bf 20 00 00 00       	mov    $0x20,%edi
  800eb8:	89 e9                	mov    %ebp,%ecx
  800eba:	29 ef                	sub    %ebp,%edi
  800ebc:	d3 e0                	shl    %cl,%eax
  800ebe:	89 f9                	mov    %edi,%ecx
  800ec0:	89 f2                	mov    %esi,%edx
  800ec2:	d3 ea                	shr    %cl,%edx
  800ec4:	89 e9                	mov    %ebp,%ecx
  800ec6:	09 c2                	or     %eax,%edx
  800ec8:	89 d8                	mov    %ebx,%eax
  800eca:	89 14 24             	mov    %edx,(%esp)
  800ecd:	89 f2                	mov    %esi,%edx
  800ecf:	d3 e2                	shl    %cl,%edx
  800ed1:	89 f9                	mov    %edi,%ecx
  800ed3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ed7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800edb:	d3 e8                	shr    %cl,%eax
  800edd:	89 e9                	mov    %ebp,%ecx
  800edf:	89 c6                	mov    %eax,%esi
  800ee1:	d3 e3                	shl    %cl,%ebx
  800ee3:	89 f9                	mov    %edi,%ecx
  800ee5:	89 d0                	mov    %edx,%eax
  800ee7:	d3 e8                	shr    %cl,%eax
  800ee9:	89 e9                	mov    %ebp,%ecx
  800eeb:	09 d8                	or     %ebx,%eax
  800eed:	89 d3                	mov    %edx,%ebx
  800eef:	89 f2                	mov    %esi,%edx
  800ef1:	f7 34 24             	divl   (%esp)
  800ef4:	89 d6                	mov    %edx,%esi
  800ef6:	d3 e3                	shl    %cl,%ebx
  800ef8:	f7 64 24 04          	mull   0x4(%esp)
  800efc:	39 d6                	cmp    %edx,%esi
  800efe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f02:	89 d1                	mov    %edx,%ecx
  800f04:	89 c3                	mov    %eax,%ebx
  800f06:	72 08                	jb     800f10 <__umoddi3+0x110>
  800f08:	75 11                	jne    800f1b <__umoddi3+0x11b>
  800f0a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f0e:	73 0b                	jae    800f1b <__umoddi3+0x11b>
  800f10:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f14:	1b 14 24             	sbb    (%esp),%edx
  800f17:	89 d1                	mov    %edx,%ecx
  800f19:	89 c3                	mov    %eax,%ebx
  800f1b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f1f:	29 da                	sub    %ebx,%edx
  800f21:	19 ce                	sbb    %ecx,%esi
  800f23:	89 f9                	mov    %edi,%ecx
  800f25:	89 f0                	mov    %esi,%eax
  800f27:	d3 e0                	shl    %cl,%eax
  800f29:	89 e9                	mov    %ebp,%ecx
  800f2b:	d3 ea                	shr    %cl,%edx
  800f2d:	89 e9                	mov    %ebp,%ecx
  800f2f:	d3 ee                	shr    %cl,%esi
  800f31:	09 d0                	or     %edx,%eax
  800f33:	89 f2                	mov    %esi,%edx
  800f35:	83 c4 1c             	add    $0x1c,%esp
  800f38:	5b                   	pop    %ebx
  800f39:	5e                   	pop    %esi
  800f3a:	5f                   	pop    %edi
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    
  800f3d:	8d 76 00             	lea    0x0(%esi),%esi
  800f40:	29 f9                	sub    %edi,%ecx
  800f42:	19 d6                	sbb    %edx,%esi
  800f44:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f4c:	e9 18 ff ff ff       	jmp    800e69 <__umoddi3+0x69>
