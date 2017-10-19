
obj/user/evilhello：     文件格式 elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 5d 00 00 00       	call   8000a2 <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800055:	e8 c6 00 00 00       	call   800120 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800096:	6a 00                	push   $0x0
  800098:	e8 42 00 00 00       	call   8000df <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7e 17                	jle    800118 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	50                   	push   %eax
  800105:	6a 03                	push   $0x3
  800107:	68 6a 0f 80 00       	push   $0x800f6a
  80010c:	6a 23                	push   $0x23
  80010e:	68 87 0f 80 00       	push   $0x800f87
  800113:	e8 f5 01 00 00       	call   80030d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011b:	5b                   	pop    %ebx
  80011c:	5e                   	pop    %esi
  80011d:	5f                   	pop    %edi
  80011e:	5d                   	pop    %ebp
  80011f:	c3                   	ret    

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 02 00 00 00       	mov    $0x2,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_yield>:

void
sys_yield(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
  800164:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800167:	be 00 00 00 00       	mov    $0x0,%esi
  80016c:	b8 04 00 00 00       	mov    $0x4,%eax
  800171:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017a:	89 f7                	mov    %esi,%edi
  80017c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80017e:	85 c0                	test   %eax,%eax
  800180:	7e 17                	jle    800199 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	50                   	push   %eax
  800186:	6a 04                	push   $0x4
  800188:	68 6a 0f 80 00       	push   $0x800f6a
  80018d:	6a 23                	push   $0x23
  80018f:	68 87 0f 80 00       	push   $0x800f87
  800194:	e8 74 01 00 00       	call   80030d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8001af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001be:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	7e 17                	jle    8001db <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c4:	83 ec 0c             	sub    $0xc,%esp
  8001c7:	50                   	push   %eax
  8001c8:	6a 05                	push   $0x5
  8001ca:	68 6a 0f 80 00       	push   $0x800f6a
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 87 0f 80 00       	push   $0x800f87
  8001d6:	e8 32 01 00 00       	call   80030d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001de:	5b                   	pop    %ebx
  8001df:	5e                   	pop    %esi
  8001e0:	5f                   	pop    %edi
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fc:	89 df                	mov    %ebx,%edi
  8001fe:	89 de                	mov    %ebx,%esi
  800200:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7e 17                	jle    80021d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	50                   	push   %eax
  80020a:	6a 06                	push   $0x6
  80020c:	68 6a 0f 80 00       	push   $0x800f6a
  800211:	6a 23                	push   $0x23
  800213:	68 87 0f 80 00       	push   $0x800f87
  800218:	e8 f0 00 00 00       	call   80030d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800220:	5b                   	pop    %ebx
  800221:	5e                   	pop    %esi
  800222:	5f                   	pop    %edi
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    

00800225 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	b8 08 00 00 00       	mov    $0x8,%eax
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7e 17                	jle    80025f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	50                   	push   %eax
  80024c:	6a 08                	push   $0x8
  80024e:	68 6a 0f 80 00       	push   $0x800f6a
  800253:	6a 23                	push   $0x23
  800255:	68 87 0f 80 00       	push   $0x800f87
  80025a:	e8 ae 00 00 00       	call   80030d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800262:	5b                   	pop    %ebx
  800263:	5e                   	pop    %esi
  800264:	5f                   	pop    %edi
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800270:	bb 00 00 00 00       	mov    $0x0,%ebx
  800275:	b8 09 00 00 00       	mov    $0x9,%eax
  80027a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
  800280:	89 df                	mov    %ebx,%edi
  800282:	89 de                	mov    %ebx,%esi
  800284:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7e 17                	jle    8002a1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 09                	push   $0x9
  800290:	68 6a 0f 80 00       	push   $0x800f6a
  800295:	6a 23                	push   $0x23
  800297:	68 87 0f 80 00       	push   $0x800f87
  80029c:	e8 6c 00 00 00       	call   80030d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a4:	5b                   	pop    %ebx
  8002a5:	5e                   	pop    %esi
  8002a6:	5f                   	pop    %edi
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002af:	be 00 00 00 00       	mov    $0x0,%esi
  8002b4:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002da:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002df:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e2:	89 cb                	mov    %ecx,%ebx
  8002e4:	89 cf                	mov    %ecx,%edi
  8002e6:	89 ce                	mov    %ecx,%esi
  8002e8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	7e 17                	jle    800305 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ee:	83 ec 0c             	sub    $0xc,%esp
  8002f1:	50                   	push   %eax
  8002f2:	6a 0c                	push   $0xc
  8002f4:	68 6a 0f 80 00       	push   $0x800f6a
  8002f9:	6a 23                	push   $0x23
  8002fb:	68 87 0f 80 00       	push   $0x800f87
  800300:	e8 08 00 00 00       	call   80030d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800305:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800308:	5b                   	pop    %ebx
  800309:	5e                   	pop    %esi
  80030a:	5f                   	pop    %edi
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    

0080030d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	56                   	push   %esi
  800311:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800312:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800315:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80031b:	e8 00 fe ff ff       	call   800120 <sys_getenvid>
  800320:	83 ec 0c             	sub    $0xc,%esp
  800323:	ff 75 0c             	pushl  0xc(%ebp)
  800326:	ff 75 08             	pushl  0x8(%ebp)
  800329:	56                   	push   %esi
  80032a:	50                   	push   %eax
  80032b:	68 98 0f 80 00       	push   $0x800f98
  800330:	e8 b1 00 00 00       	call   8003e6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800335:	83 c4 18             	add    $0x18,%esp
  800338:	53                   	push   %ebx
  800339:	ff 75 10             	pushl  0x10(%ebp)
  80033c:	e8 54 00 00 00       	call   800395 <vcprintf>
	cprintf("\n");
  800341:	c7 04 24 bc 0f 80 00 	movl   $0x800fbc,(%esp)
  800348:	e8 99 00 00 00       	call   8003e6 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800350:	cc                   	int3   
  800351:	eb fd                	jmp    800350 <_panic+0x43>

00800353 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
  800356:	53                   	push   %ebx
  800357:	83 ec 04             	sub    $0x4,%esp
  80035a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80035d:	8b 13                	mov    (%ebx),%edx
  80035f:	8d 42 01             	lea    0x1(%edx),%eax
  800362:	89 03                	mov    %eax,(%ebx)
  800364:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800367:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80036b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800370:	75 1a                	jne    80038c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800372:	83 ec 08             	sub    $0x8,%esp
  800375:	68 ff 00 00 00       	push   $0xff
  80037a:	8d 43 08             	lea    0x8(%ebx),%eax
  80037d:	50                   	push   %eax
  80037e:	e8 1f fd ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  800383:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800389:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80038c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800390:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800393:	c9                   	leave  
  800394:	c3                   	ret    

00800395 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80039e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003a5:	00 00 00 
	b.cnt = 0;
  8003a8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003af:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b2:	ff 75 0c             	pushl  0xc(%ebp)
  8003b5:	ff 75 08             	pushl  0x8(%ebp)
  8003b8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003be:	50                   	push   %eax
  8003bf:	68 53 03 80 00       	push   $0x800353
  8003c4:	e8 54 01 00 00       	call   80051d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003c9:	83 c4 08             	add    $0x8,%esp
  8003cc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003d8:	50                   	push   %eax
  8003d9:	e8 c4 fc ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  8003de:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e4:	c9                   	leave  
  8003e5:	c3                   	ret    

008003e6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003e6:	55                   	push   %ebp
  8003e7:	89 e5                	mov    %esp,%ebp
  8003e9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ec:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ef:	50                   	push   %eax
  8003f0:	ff 75 08             	pushl  0x8(%ebp)
  8003f3:	e8 9d ff ff ff       	call   800395 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003f8:	c9                   	leave  
  8003f9:	c3                   	ret    

008003fa <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003fa:	55                   	push   %ebp
  8003fb:	89 e5                	mov    %esp,%ebp
  8003fd:	57                   	push   %edi
  8003fe:	56                   	push   %esi
  8003ff:	53                   	push   %ebx
  800400:	83 ec 1c             	sub    $0x1c,%esp
  800403:	89 c7                	mov    %eax,%edi
  800405:	89 d6                	mov    %edx,%esi
  800407:	8b 45 08             	mov    0x8(%ebp),%eax
  80040a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80040d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800410:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800413:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800416:	bb 00 00 00 00       	mov    $0x0,%ebx
  80041b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80041e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800421:	39 d3                	cmp    %edx,%ebx
  800423:	72 05                	jb     80042a <printnum+0x30>
  800425:	39 45 10             	cmp    %eax,0x10(%ebp)
  800428:	77 45                	ja     80046f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042a:	83 ec 0c             	sub    $0xc,%esp
  80042d:	ff 75 18             	pushl  0x18(%ebp)
  800430:	8b 45 14             	mov    0x14(%ebp),%eax
  800433:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800436:	53                   	push   %ebx
  800437:	ff 75 10             	pushl  0x10(%ebp)
  80043a:	83 ec 08             	sub    $0x8,%esp
  80043d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800440:	ff 75 e0             	pushl  -0x20(%ebp)
  800443:	ff 75 dc             	pushl  -0x24(%ebp)
  800446:	ff 75 d8             	pushl  -0x28(%ebp)
  800449:	e8 82 08 00 00       	call   800cd0 <__udivdi3>
  80044e:	83 c4 18             	add    $0x18,%esp
  800451:	52                   	push   %edx
  800452:	50                   	push   %eax
  800453:	89 f2                	mov    %esi,%edx
  800455:	89 f8                	mov    %edi,%eax
  800457:	e8 9e ff ff ff       	call   8003fa <printnum>
  80045c:	83 c4 20             	add    $0x20,%esp
  80045f:	eb 18                	jmp    800479 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800461:	83 ec 08             	sub    $0x8,%esp
  800464:	56                   	push   %esi
  800465:	ff 75 18             	pushl  0x18(%ebp)
  800468:	ff d7                	call   *%edi
  80046a:	83 c4 10             	add    $0x10,%esp
  80046d:	eb 03                	jmp    800472 <printnum+0x78>
  80046f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800472:	83 eb 01             	sub    $0x1,%ebx
  800475:	85 db                	test   %ebx,%ebx
  800477:	7f e8                	jg     800461 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800479:	83 ec 08             	sub    $0x8,%esp
  80047c:	56                   	push   %esi
  80047d:	83 ec 04             	sub    $0x4,%esp
  800480:	ff 75 e4             	pushl  -0x1c(%ebp)
  800483:	ff 75 e0             	pushl  -0x20(%ebp)
  800486:	ff 75 dc             	pushl  -0x24(%ebp)
  800489:	ff 75 d8             	pushl  -0x28(%ebp)
  80048c:	e8 6f 09 00 00       	call   800e00 <__umoddi3>
  800491:	83 c4 14             	add    $0x14,%esp
  800494:	0f be 80 be 0f 80 00 	movsbl 0x800fbe(%eax),%eax
  80049b:	50                   	push   %eax
  80049c:	ff d7                	call   *%edi
}
  80049e:	83 c4 10             	add    $0x10,%esp
  8004a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a4:	5b                   	pop    %ebx
  8004a5:	5e                   	pop    %esi
  8004a6:	5f                   	pop    %edi
  8004a7:	5d                   	pop    %ebp
  8004a8:	c3                   	ret    

008004a9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004a9:	55                   	push   %ebp
  8004aa:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004ac:	83 fa 01             	cmp    $0x1,%edx
  8004af:	7e 0e                	jle    8004bf <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004b1:	8b 10                	mov    (%eax),%edx
  8004b3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004b6:	89 08                	mov    %ecx,(%eax)
  8004b8:	8b 02                	mov    (%edx),%eax
  8004ba:	8b 52 04             	mov    0x4(%edx),%edx
  8004bd:	eb 22                	jmp    8004e1 <getuint+0x38>
	else if (lflag)
  8004bf:	85 d2                	test   %edx,%edx
  8004c1:	74 10                	je     8004d3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004c3:	8b 10                	mov    (%eax),%edx
  8004c5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c8:	89 08                	mov    %ecx,(%eax)
  8004ca:	8b 02                	mov    (%edx),%eax
  8004cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d1:	eb 0e                	jmp    8004e1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004d3:	8b 10                	mov    (%eax),%edx
  8004d5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d8:	89 08                	mov    %ecx,(%eax)
  8004da:	8b 02                	mov    (%edx),%eax
  8004dc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004e1:	5d                   	pop    %ebp
  8004e2:	c3                   	ret    

008004e3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e3:	55                   	push   %ebp
  8004e4:	89 e5                	mov    %esp,%ebp
  8004e6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ed:	8b 10                	mov    (%eax),%edx
  8004ef:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f2:	73 0a                	jae    8004fe <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004f7:	89 08                	mov    %ecx,(%eax)
  8004f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fc:	88 02                	mov    %al,(%edx)
}
  8004fe:	5d                   	pop    %ebp
  8004ff:	c3                   	ret    

00800500 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800500:	55                   	push   %ebp
  800501:	89 e5                	mov    %esp,%ebp
  800503:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800506:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800509:	50                   	push   %eax
  80050a:	ff 75 10             	pushl  0x10(%ebp)
  80050d:	ff 75 0c             	pushl  0xc(%ebp)
  800510:	ff 75 08             	pushl  0x8(%ebp)
  800513:	e8 05 00 00 00       	call   80051d <vprintfmt>
	va_end(ap);
}
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	c9                   	leave  
  80051c:	c3                   	ret    

0080051d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
  800520:	57                   	push   %edi
  800521:	56                   	push   %esi
  800522:	53                   	push   %ebx
  800523:	83 ec 2c             	sub    $0x2c,%esp
  800526:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
  800529:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800530:	eb 17                	jmp    800549 <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800532:	85 c0                	test   %eax,%eax
  800534:	0f 84 9f 03 00 00    	je     8008d9 <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	ff 75 0c             	pushl  0xc(%ebp)
  800540:	50                   	push   %eax
  800541:	ff 55 08             	call   *0x8(%ebp)
  800544:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800547:	89 f3                	mov    %esi,%ebx
  800549:	8d 73 01             	lea    0x1(%ebx),%esi
  80054c:	0f b6 03             	movzbl (%ebx),%eax
  80054f:	83 f8 25             	cmp    $0x25,%eax
  800552:	75 de                	jne    800532 <vprintfmt+0x15>
  800554:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800558:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80055f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800564:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80056b:	ba 00 00 00 00       	mov    $0x0,%edx
  800570:	eb 06                	jmp    800578 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800572:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800574:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800578:	8d 5e 01             	lea    0x1(%esi),%ebx
  80057b:	0f b6 06             	movzbl (%esi),%eax
  80057e:	0f b6 c8             	movzbl %al,%ecx
  800581:	83 e8 23             	sub    $0x23,%eax
  800584:	3c 55                	cmp    $0x55,%al
  800586:	0f 87 2d 03 00 00    	ja     8008b9 <vprintfmt+0x39c>
  80058c:	0f b6 c0             	movzbl %al,%eax
  80058f:	ff 24 85 80 10 80 00 	jmp    *0x801080(,%eax,4)
  800596:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800598:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80059c:	eb da                	jmp    800578 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059e:	89 de                	mov    %ebx,%esi
  8005a0:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005a5:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  8005a8:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  8005ac:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  8005af:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8005b2:	83 f8 09             	cmp    $0x9,%eax
  8005b5:	77 33                	ja     8005ea <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005b7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005ba:	eb e9                	jmp    8005a5 <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8d 48 04             	lea    0x4(%eax),%ecx
  8005c2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005c5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005c9:	eb 1f                	jmp    8005ea <vprintfmt+0xcd>
  8005cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ce:	85 c0                	test   %eax,%eax
  8005d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d5:	0f 49 c8             	cmovns %eax,%ecx
  8005d8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005db:	89 de                	mov    %ebx,%esi
  8005dd:	eb 99                	jmp    800578 <vprintfmt+0x5b>
  8005df:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005e1:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  8005e8:	eb 8e                	jmp    800578 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8005ea:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ee:	79 88                	jns    800578 <vprintfmt+0x5b>
				width = precision, precision = -1;
  8005f0:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8005f3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8005f8:	e9 7b ff ff ff       	jmp    800578 <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005fd:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800600:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800602:	e9 71 ff ff ff       	jmp    800578 <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 50 04             	lea    0x4(%eax),%edx
  80060d:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  800610:	83 ec 08             	sub    $0x8,%esp
  800613:	ff 75 0c             	pushl  0xc(%ebp)
  800616:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800619:	03 08                	add    (%eax),%ecx
  80061b:	51                   	push   %ecx
  80061c:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
  80061f:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
  800622:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
  800629:	e9 1b ff ff ff       	jmp    800549 <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8d 48 04             	lea    0x4(%eax),%ecx
  800634:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800637:	8b 00                	mov    (%eax),%eax
  800639:	83 f8 02             	cmp    $0x2,%eax
  80063c:	74 1a                	je     800658 <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063e:	89 de                	mov    %ebx,%esi
  800640:	83 f8 04             	cmp    $0x4,%eax
  800643:	b8 00 00 00 00       	mov    $0x0,%eax
  800648:	b9 00 04 00 00       	mov    $0x400,%ecx
  80064d:	0f 44 c1             	cmove  %ecx,%eax
  800650:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800653:	e9 20 ff ff ff       	jmp    800578 <vprintfmt+0x5b>
  800658:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
  80065a:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
  800661:	e9 12 ff ff ff       	jmp    800578 <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8d 50 04             	lea    0x4(%eax),%edx
  80066c:	89 55 14             	mov    %edx,0x14(%ebp)
  80066f:	8b 00                	mov    (%eax),%eax
  800671:	99                   	cltd   
  800672:	31 d0                	xor    %edx,%eax
  800674:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800676:	83 f8 09             	cmp    $0x9,%eax
  800679:	7f 0b                	jg     800686 <vprintfmt+0x169>
  80067b:	8b 14 85 e0 11 80 00 	mov    0x8011e0(,%eax,4),%edx
  800682:	85 d2                	test   %edx,%edx
  800684:	75 19                	jne    80069f <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800686:	50                   	push   %eax
  800687:	68 d6 0f 80 00       	push   $0x800fd6
  80068c:	ff 75 0c             	pushl  0xc(%ebp)
  80068f:	ff 75 08             	pushl  0x8(%ebp)
  800692:	e8 69 fe ff ff       	call   800500 <printfmt>
  800697:	83 c4 10             	add    $0x10,%esp
  80069a:	e9 aa fe ff ff       	jmp    800549 <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  80069f:	52                   	push   %edx
  8006a0:	68 df 0f 80 00       	push   $0x800fdf
  8006a5:	ff 75 0c             	pushl  0xc(%ebp)
  8006a8:	ff 75 08             	pushl  0x8(%ebp)
  8006ab:	e8 50 fe ff ff       	call   800500 <printfmt>
  8006b0:	83 c4 10             	add    $0x10,%esp
  8006b3:	e9 91 fe ff ff       	jmp    800549 <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bb:	8d 50 04             	lea    0x4(%eax),%edx
  8006be:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006c3:	85 f6                	test   %esi,%esi
  8006c5:	b8 cf 0f 80 00       	mov    $0x800fcf,%eax
  8006ca:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006d1:	0f 8e 93 00 00 00    	jle    80076a <vprintfmt+0x24d>
  8006d7:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8006db:	0f 84 91 00 00 00    	je     800772 <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e1:	83 ec 08             	sub    $0x8,%esp
  8006e4:	57                   	push   %edi
  8006e5:	56                   	push   %esi
  8006e6:	e8 76 02 00 00       	call   800961 <strnlen>
  8006eb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006ee:	29 c1                	sub    %eax,%ecx
  8006f0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006f3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006f6:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8006fa:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006fd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800700:	8b 75 0c             	mov    0xc(%ebp),%esi
  800703:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800706:	89 cb                	mov    %ecx,%ebx
  800708:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80070a:	eb 0e                	jmp    80071a <vprintfmt+0x1fd>
					putch(padc, putdat);
  80070c:	83 ec 08             	sub    $0x8,%esp
  80070f:	56                   	push   %esi
  800710:	57                   	push   %edi
  800711:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800714:	83 eb 01             	sub    $0x1,%ebx
  800717:	83 c4 10             	add    $0x10,%esp
  80071a:	85 db                	test   %ebx,%ebx
  80071c:	7f ee                	jg     80070c <vprintfmt+0x1ef>
  80071e:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800721:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800724:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800727:	85 c9                	test   %ecx,%ecx
  800729:	b8 00 00 00 00       	mov    $0x0,%eax
  80072e:	0f 49 c1             	cmovns %ecx,%eax
  800731:	29 c1                	sub    %eax,%ecx
  800733:	89 cb                	mov    %ecx,%ebx
  800735:	eb 41                	jmp    800778 <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800737:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80073b:	74 1b                	je     800758 <vprintfmt+0x23b>
  80073d:	0f be c0             	movsbl %al,%eax
  800740:	83 e8 20             	sub    $0x20,%eax
  800743:	83 f8 5e             	cmp    $0x5e,%eax
  800746:	76 10                	jbe    800758 <vprintfmt+0x23b>
					putch('?', putdat);
  800748:	83 ec 08             	sub    $0x8,%esp
  80074b:	ff 75 0c             	pushl  0xc(%ebp)
  80074e:	6a 3f                	push   $0x3f
  800750:	ff 55 08             	call   *0x8(%ebp)
  800753:	83 c4 10             	add    $0x10,%esp
  800756:	eb 0d                	jmp    800765 <vprintfmt+0x248>
				else
					putch(ch, putdat);
  800758:	83 ec 08             	sub    $0x8,%esp
  80075b:	ff 75 0c             	pushl  0xc(%ebp)
  80075e:	52                   	push   %edx
  80075f:	ff 55 08             	call   *0x8(%ebp)
  800762:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800765:	83 eb 01             	sub    $0x1,%ebx
  800768:	eb 0e                	jmp    800778 <vprintfmt+0x25b>
  80076a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80076d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800770:	eb 06                	jmp    800778 <vprintfmt+0x25b>
  800772:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800775:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800778:	83 c6 01             	add    $0x1,%esi
  80077b:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80077f:	0f be d0             	movsbl %al,%edx
  800782:	85 d2                	test   %edx,%edx
  800784:	74 25                	je     8007ab <vprintfmt+0x28e>
  800786:	85 ff                	test   %edi,%edi
  800788:	78 ad                	js     800737 <vprintfmt+0x21a>
  80078a:	83 ef 01             	sub    $0x1,%edi
  80078d:	79 a8                	jns    800737 <vprintfmt+0x21a>
  80078f:	89 d8                	mov    %ebx,%eax
  800791:	8b 75 08             	mov    0x8(%ebp),%esi
  800794:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800797:	89 c3                	mov    %eax,%ebx
  800799:	eb 16                	jmp    8007b1 <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80079b:	83 ec 08             	sub    $0x8,%esp
  80079e:	57                   	push   %edi
  80079f:	6a 20                	push   $0x20
  8007a1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007a3:	83 eb 01             	sub    $0x1,%ebx
  8007a6:	83 c4 10             	add    $0x10,%esp
  8007a9:	eb 06                	jmp    8007b1 <vprintfmt+0x294>
  8007ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ae:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8007b1:	85 db                	test   %ebx,%ebx
  8007b3:	7f e6                	jg     80079b <vprintfmt+0x27e>
  8007b5:	89 75 08             	mov    %esi,0x8(%ebp)
  8007b8:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8007bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007be:	e9 86 fd ff ff       	jmp    800549 <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007c3:	83 fa 01             	cmp    $0x1,%edx
  8007c6:	7e 10                	jle    8007d8 <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
  8007c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cb:	8d 50 08             	lea    0x8(%eax),%edx
  8007ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d1:	8b 30                	mov    (%eax),%esi
  8007d3:	8b 78 04             	mov    0x4(%eax),%edi
  8007d6:	eb 26                	jmp    8007fe <vprintfmt+0x2e1>
	else if (lflag)
  8007d8:	85 d2                	test   %edx,%edx
  8007da:	74 12                	je     8007ee <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  8007dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007df:	8d 50 04             	lea    0x4(%eax),%edx
  8007e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e5:	8b 30                	mov    (%eax),%esi
  8007e7:	89 f7                	mov    %esi,%edi
  8007e9:	c1 ff 1f             	sar    $0x1f,%edi
  8007ec:	eb 10                	jmp    8007fe <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
  8007ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f1:	8d 50 04             	lea    0x4(%eax),%edx
  8007f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f7:	8b 30                	mov    (%eax),%esi
  8007f9:	89 f7                	mov    %esi,%edi
  8007fb:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007fe:	89 f0                	mov    %esi,%eax
  800800:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800802:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800807:	85 ff                	test   %edi,%edi
  800809:	79 7b                	jns    800886 <vprintfmt+0x369>
				putch('-', putdat);
  80080b:	83 ec 08             	sub    $0x8,%esp
  80080e:	ff 75 0c             	pushl  0xc(%ebp)
  800811:	6a 2d                	push   $0x2d
  800813:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800816:	89 f0                	mov    %esi,%eax
  800818:	89 fa                	mov    %edi,%edx
  80081a:	f7 d8                	neg    %eax
  80081c:	83 d2 00             	adc    $0x0,%edx
  80081f:	f7 da                	neg    %edx
  800821:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800824:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800829:	eb 5b                	jmp    800886 <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80082b:	8d 45 14             	lea    0x14(%ebp),%eax
  80082e:	e8 76 fc ff ff       	call   8004a9 <getuint>
			base = 10;
  800833:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800838:	eb 4c                	jmp    800886 <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
  80083a:	8d 45 14             	lea    0x14(%ebp),%eax
  80083d:	e8 67 fc ff ff       	call   8004a9 <getuint>
            base = 8;
  800842:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800847:	eb 3d                	jmp    800886 <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
  800849:	83 ec 08             	sub    $0x8,%esp
  80084c:	ff 75 0c             	pushl  0xc(%ebp)
  80084f:	6a 30                	push   $0x30
  800851:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800854:	83 c4 08             	add    $0x8,%esp
  800857:	ff 75 0c             	pushl  0xc(%ebp)
  80085a:	6a 78                	push   $0x78
  80085c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80085f:	8b 45 14             	mov    0x14(%ebp),%eax
  800862:	8d 50 04             	lea    0x4(%eax),%edx
  800865:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800868:	8b 00                	mov    (%eax),%eax
  80086a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80086f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800872:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800877:	eb 0d                	jmp    800886 <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800879:	8d 45 14             	lea    0x14(%ebp),%eax
  80087c:	e8 28 fc ff ff       	call   8004a9 <getuint>
			base = 16;
  800881:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800886:	83 ec 0c             	sub    $0xc,%esp
  800889:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  80088d:	56                   	push   %esi
  80088e:	ff 75 e0             	pushl  -0x20(%ebp)
  800891:	51                   	push   %ecx
  800892:	52                   	push   %edx
  800893:	50                   	push   %eax
  800894:	8b 55 0c             	mov    0xc(%ebp),%edx
  800897:	8b 45 08             	mov    0x8(%ebp),%eax
  80089a:	e8 5b fb ff ff       	call   8003fa <printnum>
			break;
  80089f:	83 c4 20             	add    $0x20,%esp
  8008a2:	e9 a2 fc ff ff       	jmp    800549 <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008a7:	83 ec 08             	sub    $0x8,%esp
  8008aa:	ff 75 0c             	pushl  0xc(%ebp)
  8008ad:	51                   	push   %ecx
  8008ae:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008b1:	83 c4 10             	add    $0x10,%esp
  8008b4:	e9 90 fc ff ff       	jmp    800549 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008b9:	83 ec 08             	sub    $0x8,%esp
  8008bc:	ff 75 0c             	pushl  0xc(%ebp)
  8008bf:	6a 25                	push   $0x25
  8008c1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008c4:	83 c4 10             	add    $0x10,%esp
  8008c7:	89 f3                	mov    %esi,%ebx
  8008c9:	eb 03                	jmp    8008ce <vprintfmt+0x3b1>
  8008cb:	83 eb 01             	sub    $0x1,%ebx
  8008ce:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8008d2:	75 f7                	jne    8008cb <vprintfmt+0x3ae>
  8008d4:	e9 70 fc ff ff       	jmp    800549 <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  8008d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008dc:	5b                   	pop    %ebx
  8008dd:	5e                   	pop    %esi
  8008de:	5f                   	pop    %edi
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	83 ec 18             	sub    $0x18,%esp
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008f0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008f4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008fe:	85 c0                	test   %eax,%eax
  800900:	74 26                	je     800928 <vsnprintf+0x47>
  800902:	85 d2                	test   %edx,%edx
  800904:	7e 22                	jle    800928 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800906:	ff 75 14             	pushl  0x14(%ebp)
  800909:	ff 75 10             	pushl  0x10(%ebp)
  80090c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80090f:	50                   	push   %eax
  800910:	68 e3 04 80 00       	push   $0x8004e3
  800915:	e8 03 fc ff ff       	call   80051d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80091a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80091d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800920:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800923:	83 c4 10             	add    $0x10,%esp
  800926:	eb 05                	jmp    80092d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800928:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    

0080092f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800935:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800938:	50                   	push   %eax
  800939:	ff 75 10             	pushl  0x10(%ebp)
  80093c:	ff 75 0c             	pushl  0xc(%ebp)
  80093f:	ff 75 08             	pushl  0x8(%ebp)
  800942:	e8 9a ff ff ff       	call   8008e1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800947:	c9                   	leave  
  800948:	c3                   	ret    

00800949 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80094f:	b8 00 00 00 00       	mov    $0x0,%eax
  800954:	eb 03                	jmp    800959 <strlen+0x10>
		n++;
  800956:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800959:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80095d:	75 f7                	jne    800956 <strlen+0xd>
		n++;
	return n;
}
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800967:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80096a:	ba 00 00 00 00       	mov    $0x0,%edx
  80096f:	eb 03                	jmp    800974 <strnlen+0x13>
		n++;
  800971:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800974:	39 c2                	cmp    %eax,%edx
  800976:	74 08                	je     800980 <strnlen+0x1f>
  800978:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80097c:	75 f3                	jne    800971 <strnlen+0x10>
  80097e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	53                   	push   %ebx
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80098c:	89 c2                	mov    %eax,%edx
  80098e:	83 c2 01             	add    $0x1,%edx
  800991:	83 c1 01             	add    $0x1,%ecx
  800994:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800998:	88 5a ff             	mov    %bl,-0x1(%edx)
  80099b:	84 db                	test   %bl,%bl
  80099d:	75 ef                	jne    80098e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80099f:	5b                   	pop    %ebx
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	53                   	push   %ebx
  8009a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009a9:	53                   	push   %ebx
  8009aa:	e8 9a ff ff ff       	call   800949 <strlen>
  8009af:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009b2:	ff 75 0c             	pushl  0xc(%ebp)
  8009b5:	01 d8                	add    %ebx,%eax
  8009b7:	50                   	push   %eax
  8009b8:	e8 c5 ff ff ff       	call   800982 <strcpy>
	return dst;
}
  8009bd:	89 d8                	mov    %ebx,%eax
  8009bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c2:	c9                   	leave  
  8009c3:	c3                   	ret    

008009c4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	56                   	push   %esi
  8009c8:	53                   	push   %ebx
  8009c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009cf:	89 f3                	mov    %esi,%ebx
  8009d1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d4:	89 f2                	mov    %esi,%edx
  8009d6:	eb 0f                	jmp    8009e7 <strncpy+0x23>
		*dst++ = *src;
  8009d8:	83 c2 01             	add    $0x1,%edx
  8009db:	0f b6 01             	movzbl (%ecx),%eax
  8009de:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009e1:	80 39 01             	cmpb   $0x1,(%ecx)
  8009e4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009e7:	39 da                	cmp    %ebx,%edx
  8009e9:	75 ed                	jne    8009d8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009eb:	89 f0                	mov    %esi,%eax
  8009ed:	5b                   	pop    %ebx
  8009ee:	5e                   	pop    %esi
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	56                   	push   %esi
  8009f5:	53                   	push   %ebx
  8009f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009fc:	8b 55 10             	mov    0x10(%ebp),%edx
  8009ff:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a01:	85 d2                	test   %edx,%edx
  800a03:	74 21                	je     800a26 <strlcpy+0x35>
  800a05:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a09:	89 f2                	mov    %esi,%edx
  800a0b:	eb 09                	jmp    800a16 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a0d:	83 c2 01             	add    $0x1,%edx
  800a10:	83 c1 01             	add    $0x1,%ecx
  800a13:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a16:	39 c2                	cmp    %eax,%edx
  800a18:	74 09                	je     800a23 <strlcpy+0x32>
  800a1a:	0f b6 19             	movzbl (%ecx),%ebx
  800a1d:	84 db                	test   %bl,%bl
  800a1f:	75 ec                	jne    800a0d <strlcpy+0x1c>
  800a21:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a23:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a26:	29 f0                	sub    %esi,%eax
}
  800a28:	5b                   	pop    %ebx
  800a29:	5e                   	pop    %esi
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a32:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a35:	eb 06                	jmp    800a3d <strcmp+0x11>
		p++, q++;
  800a37:	83 c1 01             	add    $0x1,%ecx
  800a3a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a3d:	0f b6 01             	movzbl (%ecx),%eax
  800a40:	84 c0                	test   %al,%al
  800a42:	74 04                	je     800a48 <strcmp+0x1c>
  800a44:	3a 02                	cmp    (%edx),%al
  800a46:	74 ef                	je     800a37 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a48:	0f b6 c0             	movzbl %al,%eax
  800a4b:	0f b6 12             	movzbl (%edx),%edx
  800a4e:	29 d0                	sub    %edx,%eax
}
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	53                   	push   %ebx
  800a56:	8b 45 08             	mov    0x8(%ebp),%eax
  800a59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5c:	89 c3                	mov    %eax,%ebx
  800a5e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a61:	eb 06                	jmp    800a69 <strncmp+0x17>
		n--, p++, q++;
  800a63:	83 c0 01             	add    $0x1,%eax
  800a66:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a69:	39 d8                	cmp    %ebx,%eax
  800a6b:	74 15                	je     800a82 <strncmp+0x30>
  800a6d:	0f b6 08             	movzbl (%eax),%ecx
  800a70:	84 c9                	test   %cl,%cl
  800a72:	74 04                	je     800a78 <strncmp+0x26>
  800a74:	3a 0a                	cmp    (%edx),%cl
  800a76:	74 eb                	je     800a63 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a78:	0f b6 00             	movzbl (%eax),%eax
  800a7b:	0f b6 12             	movzbl (%edx),%edx
  800a7e:	29 d0                	sub    %edx,%eax
  800a80:	eb 05                	jmp    800a87 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a82:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a87:	5b                   	pop    %ebx
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a94:	eb 07                	jmp    800a9d <strchr+0x13>
		if (*s == c)
  800a96:	38 ca                	cmp    %cl,%dl
  800a98:	74 0f                	je     800aa9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a9a:	83 c0 01             	add    $0x1,%eax
  800a9d:	0f b6 10             	movzbl (%eax),%edx
  800aa0:	84 d2                	test   %dl,%dl
  800aa2:	75 f2                	jne    800a96 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800aa4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab5:	eb 03                	jmp    800aba <strfind+0xf>
  800ab7:	83 c0 01             	add    $0x1,%eax
  800aba:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800abd:	38 ca                	cmp    %cl,%dl
  800abf:	74 04                	je     800ac5 <strfind+0x1a>
  800ac1:	84 d2                	test   %dl,%dl
  800ac3:	75 f2                	jne    800ab7 <strfind+0xc>
			break;
	return (char *) s;
}
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	57                   	push   %edi
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
  800acd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ad0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ad3:	85 c9                	test   %ecx,%ecx
  800ad5:	74 36                	je     800b0d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ad7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800add:	75 28                	jne    800b07 <memset+0x40>
  800adf:	f6 c1 03             	test   $0x3,%cl
  800ae2:	75 23                	jne    800b07 <memset+0x40>
		c &= 0xFF;
  800ae4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ae8:	89 d3                	mov    %edx,%ebx
  800aea:	c1 e3 08             	shl    $0x8,%ebx
  800aed:	89 d6                	mov    %edx,%esi
  800aef:	c1 e6 18             	shl    $0x18,%esi
  800af2:	89 d0                	mov    %edx,%eax
  800af4:	c1 e0 10             	shl    $0x10,%eax
  800af7:	09 f0                	or     %esi,%eax
  800af9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800afb:	89 d8                	mov    %ebx,%eax
  800afd:	09 d0                	or     %edx,%eax
  800aff:	c1 e9 02             	shr    $0x2,%ecx
  800b02:	fc                   	cld    
  800b03:	f3 ab                	rep stos %eax,%es:(%edi)
  800b05:	eb 06                	jmp    800b0d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0a:	fc                   	cld    
  800b0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b0d:	89 f8                	mov    %edi,%eax
  800b0f:	5b                   	pop    %ebx
  800b10:	5e                   	pop    %esi
  800b11:	5f                   	pop    %edi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	57                   	push   %edi
  800b18:	56                   	push   %esi
  800b19:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b22:	39 c6                	cmp    %eax,%esi
  800b24:	73 35                	jae    800b5b <memmove+0x47>
  800b26:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b29:	39 d0                	cmp    %edx,%eax
  800b2b:	73 2e                	jae    800b5b <memmove+0x47>
		s += n;
		d += n;
  800b2d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b30:	89 d6                	mov    %edx,%esi
  800b32:	09 fe                	or     %edi,%esi
  800b34:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b3a:	75 13                	jne    800b4f <memmove+0x3b>
  800b3c:	f6 c1 03             	test   $0x3,%cl
  800b3f:	75 0e                	jne    800b4f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b41:	83 ef 04             	sub    $0x4,%edi
  800b44:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b47:	c1 e9 02             	shr    $0x2,%ecx
  800b4a:	fd                   	std    
  800b4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4d:	eb 09                	jmp    800b58 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b4f:	83 ef 01             	sub    $0x1,%edi
  800b52:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b55:	fd                   	std    
  800b56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b58:	fc                   	cld    
  800b59:	eb 1d                	jmp    800b78 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b5b:	89 f2                	mov    %esi,%edx
  800b5d:	09 c2                	or     %eax,%edx
  800b5f:	f6 c2 03             	test   $0x3,%dl
  800b62:	75 0f                	jne    800b73 <memmove+0x5f>
  800b64:	f6 c1 03             	test   $0x3,%cl
  800b67:	75 0a                	jne    800b73 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b69:	c1 e9 02             	shr    $0x2,%ecx
  800b6c:	89 c7                	mov    %eax,%edi
  800b6e:	fc                   	cld    
  800b6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b71:	eb 05                	jmp    800b78 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b73:	89 c7                	mov    %eax,%edi
  800b75:	fc                   	cld    
  800b76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b7f:	ff 75 10             	pushl  0x10(%ebp)
  800b82:	ff 75 0c             	pushl  0xc(%ebp)
  800b85:	ff 75 08             	pushl  0x8(%ebp)
  800b88:	e8 87 ff ff ff       	call   800b14 <memmove>
}
  800b8d:	c9                   	leave  
  800b8e:	c3                   	ret    

00800b8f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	56                   	push   %esi
  800b93:	53                   	push   %ebx
  800b94:	8b 45 08             	mov    0x8(%ebp),%eax
  800b97:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b9a:	89 c6                	mov    %eax,%esi
  800b9c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b9f:	eb 1a                	jmp    800bbb <memcmp+0x2c>
		if (*s1 != *s2)
  800ba1:	0f b6 08             	movzbl (%eax),%ecx
  800ba4:	0f b6 1a             	movzbl (%edx),%ebx
  800ba7:	38 d9                	cmp    %bl,%cl
  800ba9:	74 0a                	je     800bb5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bab:	0f b6 c1             	movzbl %cl,%eax
  800bae:	0f b6 db             	movzbl %bl,%ebx
  800bb1:	29 d8                	sub    %ebx,%eax
  800bb3:	eb 0f                	jmp    800bc4 <memcmp+0x35>
		s1++, s2++;
  800bb5:	83 c0 01             	add    $0x1,%eax
  800bb8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bbb:	39 f0                	cmp    %esi,%eax
  800bbd:	75 e2                	jne    800ba1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bbf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	53                   	push   %ebx
  800bcc:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bcf:	89 c1                	mov    %eax,%ecx
  800bd1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bd8:	eb 0a                	jmp    800be4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bda:	0f b6 10             	movzbl (%eax),%edx
  800bdd:	39 da                	cmp    %ebx,%edx
  800bdf:	74 07                	je     800be8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800be1:	83 c0 01             	add    $0x1,%eax
  800be4:	39 c8                	cmp    %ecx,%eax
  800be6:	72 f2                	jb     800bda <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800be8:	5b                   	pop    %ebx
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf7:	eb 03                	jmp    800bfc <strtol+0x11>
		s++;
  800bf9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bfc:	0f b6 01             	movzbl (%ecx),%eax
  800bff:	3c 20                	cmp    $0x20,%al
  800c01:	74 f6                	je     800bf9 <strtol+0xe>
  800c03:	3c 09                	cmp    $0x9,%al
  800c05:	74 f2                	je     800bf9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c07:	3c 2b                	cmp    $0x2b,%al
  800c09:	75 0a                	jne    800c15 <strtol+0x2a>
		s++;
  800c0b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c0e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c13:	eb 11                	jmp    800c26 <strtol+0x3b>
  800c15:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c1a:	3c 2d                	cmp    $0x2d,%al
  800c1c:	75 08                	jne    800c26 <strtol+0x3b>
		s++, neg = 1;
  800c1e:	83 c1 01             	add    $0x1,%ecx
  800c21:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c26:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c2c:	75 15                	jne    800c43 <strtol+0x58>
  800c2e:	80 39 30             	cmpb   $0x30,(%ecx)
  800c31:	75 10                	jne    800c43 <strtol+0x58>
  800c33:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c37:	75 7c                	jne    800cb5 <strtol+0xca>
		s += 2, base = 16;
  800c39:	83 c1 02             	add    $0x2,%ecx
  800c3c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c41:	eb 16                	jmp    800c59 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c43:	85 db                	test   %ebx,%ebx
  800c45:	75 12                	jne    800c59 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c47:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c4c:	80 39 30             	cmpb   $0x30,(%ecx)
  800c4f:	75 08                	jne    800c59 <strtol+0x6e>
		s++, base = 8;
  800c51:	83 c1 01             	add    $0x1,%ecx
  800c54:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c59:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c61:	0f b6 11             	movzbl (%ecx),%edx
  800c64:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c67:	89 f3                	mov    %esi,%ebx
  800c69:	80 fb 09             	cmp    $0x9,%bl
  800c6c:	77 08                	ja     800c76 <strtol+0x8b>
			dig = *s - '0';
  800c6e:	0f be d2             	movsbl %dl,%edx
  800c71:	83 ea 30             	sub    $0x30,%edx
  800c74:	eb 22                	jmp    800c98 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c76:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c79:	89 f3                	mov    %esi,%ebx
  800c7b:	80 fb 19             	cmp    $0x19,%bl
  800c7e:	77 08                	ja     800c88 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c80:	0f be d2             	movsbl %dl,%edx
  800c83:	83 ea 57             	sub    $0x57,%edx
  800c86:	eb 10                	jmp    800c98 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c88:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c8b:	89 f3                	mov    %esi,%ebx
  800c8d:	80 fb 19             	cmp    $0x19,%bl
  800c90:	77 16                	ja     800ca8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c92:	0f be d2             	movsbl %dl,%edx
  800c95:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c98:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c9b:	7d 0b                	jge    800ca8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c9d:	83 c1 01             	add    $0x1,%ecx
  800ca0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ca4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ca6:	eb b9                	jmp    800c61 <strtol+0x76>

	if (endptr)
  800ca8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cac:	74 0d                	je     800cbb <strtol+0xd0>
		*endptr = (char *) s;
  800cae:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cb1:	89 0e                	mov    %ecx,(%esi)
  800cb3:	eb 06                	jmp    800cbb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cb5:	85 db                	test   %ebx,%ebx
  800cb7:	74 98                	je     800c51 <strtol+0x66>
  800cb9:	eb 9e                	jmp    800c59 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cbb:	89 c2                	mov    %eax,%edx
  800cbd:	f7 da                	neg    %edx
  800cbf:	85 ff                	test   %edi,%edi
  800cc1:	0f 45 c2             	cmovne %edx,%eax
}
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    
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
