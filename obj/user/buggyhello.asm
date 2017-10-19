
obj/user/buggyhello：     文件格式 elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
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
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 5d 00 00 00       	call   80009f <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800052:	e8 c6 00 00 00       	call   80011d <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800093:	6a 00                	push   $0x0
  800095:	e8 42 00 00 00       	call   8000dc <sys_env_destroy>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	c9                   	leave  
  80009e:	c3                   	ret    

0080009f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009f:	55                   	push   %ebp
  8000a0:	89 e5                	mov    %esp,%ebp
  8000a2:	57                   	push   %edi
  8000a3:	56                   	push   %esi
  8000a4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b0:	89 c3                	mov    %eax,%ebx
  8000b2:	89 c7                	mov    %eax,%edi
  8000b4:	89 c6                	mov    %eax,%esi
  8000b6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b8:	5b                   	pop    %ebx
  8000b9:	5e                   	pop    %esi
  8000ba:	5f                   	pop    %edi
  8000bb:	5d                   	pop    %ebp
  8000bc:	c3                   	ret    

008000bd <sys_cgetc>:

int
sys_cgetc(void)
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
  8000c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c8:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cd:	89 d1                	mov    %edx,%ecx
  8000cf:	89 d3                	mov    %edx,%ebx
  8000d1:	89 d7                	mov    %edx,%edi
  8000d3:	89 d6                	mov    %edx,%esi
  8000d5:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d7:	5b                   	pop    %ebx
  8000d8:	5e                   	pop    %esi
  8000d9:	5f                   	pop    %edi
  8000da:	5d                   	pop    %ebp
  8000db:	c3                   	ret    

008000dc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	57                   	push   %edi
  8000e0:	56                   	push   %esi
  8000e1:	53                   	push   %ebx
  8000e2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ea:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f2:	89 cb                	mov    %ecx,%ebx
  8000f4:	89 cf                	mov    %ecx,%edi
  8000f6:	89 ce                	mov    %ecx,%esi
  8000f8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	7e 17                	jle    800115 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fe:	83 ec 0c             	sub    $0xc,%esp
  800101:	50                   	push   %eax
  800102:	6a 03                	push   $0x3
  800104:	68 6a 0f 80 00       	push   $0x800f6a
  800109:	6a 23                	push   $0x23
  80010b:	68 87 0f 80 00       	push   $0x800f87
  800110:	e8 f5 01 00 00       	call   80030a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800115:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800118:	5b                   	pop    %ebx
  800119:	5e                   	pop    %esi
  80011a:	5f                   	pop    %edi
  80011b:	5d                   	pop    %ebp
  80011c:	c3                   	ret    

0080011d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	57                   	push   %edi
  800121:	56                   	push   %esi
  800122:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800123:	ba 00 00 00 00       	mov    $0x0,%edx
  800128:	b8 02 00 00 00       	mov    $0x2,%eax
  80012d:	89 d1                	mov    %edx,%ecx
  80012f:	89 d3                	mov    %edx,%ebx
  800131:	89 d7                	mov    %edx,%edi
  800133:	89 d6                	mov    %edx,%esi
  800135:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800137:	5b                   	pop    %ebx
  800138:	5e                   	pop    %esi
  800139:	5f                   	pop    %edi
  80013a:	5d                   	pop    %ebp
  80013b:	c3                   	ret    

0080013c <sys_yield>:

void
sys_yield(void)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	57                   	push   %edi
  800140:	56                   	push   %esi
  800141:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800142:	ba 00 00 00 00       	mov    $0x0,%edx
  800147:	b8 0a 00 00 00       	mov    $0xa,%eax
  80014c:	89 d1                	mov    %edx,%ecx
  80014e:	89 d3                	mov    %edx,%ebx
  800150:	89 d7                	mov    %edx,%edi
  800152:	89 d6                	mov    %edx,%esi
  800154:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800156:	5b                   	pop    %ebx
  800157:	5e                   	pop    %esi
  800158:	5f                   	pop    %edi
  800159:	5d                   	pop    %ebp
  80015a:	c3                   	ret    

0080015b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	57                   	push   %edi
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
  800161:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800164:	be 00 00 00 00       	mov    $0x0,%esi
  800169:	b8 04 00 00 00       	mov    $0x4,%eax
  80016e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800171:	8b 55 08             	mov    0x8(%ebp),%edx
  800174:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800177:	89 f7                	mov    %esi,%edi
  800179:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80017b:	85 c0                	test   %eax,%eax
  80017d:	7e 17                	jle    800196 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017f:	83 ec 0c             	sub    $0xc,%esp
  800182:	50                   	push   %eax
  800183:	6a 04                	push   $0x4
  800185:	68 6a 0f 80 00       	push   $0x800f6a
  80018a:	6a 23                	push   $0x23
  80018c:	68 87 0f 80 00       	push   $0x800f87
  800191:	e8 74 01 00 00       	call   80030a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	57                   	push   %edi
  8001a2:	56                   	push   %esi
  8001a3:	53                   	push   %ebx
  8001a4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a7:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001af:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b8:	8b 75 18             	mov    0x18(%ebp),%esi
  8001bb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	7e 17                	jle    8001d8 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c1:	83 ec 0c             	sub    $0xc,%esp
  8001c4:	50                   	push   %eax
  8001c5:	6a 05                	push   $0x5
  8001c7:	68 6a 0f 80 00       	push   $0x800f6a
  8001cc:	6a 23                	push   $0x23
  8001ce:	68 87 0f 80 00       	push   $0x800f87
  8001d3:	e8 32 01 00 00       	call   80030a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001db:	5b                   	pop    %ebx
  8001dc:	5e                   	pop    %esi
  8001dd:	5f                   	pop    %edi
  8001de:	5d                   	pop    %ebp
  8001df:	c3                   	ret    

008001e0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ee:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f9:	89 df                	mov    %ebx,%edi
  8001fb:	89 de                	mov    %ebx,%esi
  8001fd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001ff:	85 c0                	test   %eax,%eax
  800201:	7e 17                	jle    80021a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800203:	83 ec 0c             	sub    $0xc,%esp
  800206:	50                   	push   %eax
  800207:	6a 06                	push   $0x6
  800209:	68 6a 0f 80 00       	push   $0x800f6a
  80020e:	6a 23                	push   $0x23
  800210:	68 87 0f 80 00       	push   $0x800f87
  800215:	e8 f0 00 00 00       	call   80030a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5f                   	pop    %edi
  800220:	5d                   	pop    %ebp
  800221:	c3                   	ret    

00800222 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800222:	55                   	push   %ebp
  800223:	89 e5                	mov    %esp,%ebp
  800225:	57                   	push   %edi
  800226:	56                   	push   %esi
  800227:	53                   	push   %ebx
  800228:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800230:	b8 08 00 00 00       	mov    $0x8,%eax
  800235:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800238:	8b 55 08             	mov    0x8(%ebp),%edx
  80023b:	89 df                	mov    %ebx,%edi
  80023d:	89 de                	mov    %ebx,%esi
  80023f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800241:	85 c0                	test   %eax,%eax
  800243:	7e 17                	jle    80025c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800245:	83 ec 0c             	sub    $0xc,%esp
  800248:	50                   	push   %eax
  800249:	6a 08                	push   $0x8
  80024b:	68 6a 0f 80 00       	push   $0x800f6a
  800250:	6a 23                	push   $0x23
  800252:	68 87 0f 80 00       	push   $0x800f87
  800257:	e8 ae 00 00 00       	call   80030a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025f:	5b                   	pop    %ebx
  800260:	5e                   	pop    %esi
  800261:	5f                   	pop    %edi
  800262:	5d                   	pop    %ebp
  800263:	c3                   	ret    

00800264 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	57                   	push   %edi
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800272:	b8 09 00 00 00       	mov    $0x9,%eax
  800277:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027a:	8b 55 08             	mov    0x8(%ebp),%edx
  80027d:	89 df                	mov    %ebx,%edi
  80027f:	89 de                	mov    %ebx,%esi
  800281:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800283:	85 c0                	test   %eax,%eax
  800285:	7e 17                	jle    80029e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800287:	83 ec 0c             	sub    $0xc,%esp
  80028a:	50                   	push   %eax
  80028b:	6a 09                	push   $0x9
  80028d:	68 6a 0f 80 00       	push   $0x800f6a
  800292:	6a 23                	push   $0x23
  800294:	68 87 0f 80 00       	push   $0x800f87
  800299:	e8 6c 00 00 00       	call   80030a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80029e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a1:	5b                   	pop    %ebx
  8002a2:	5e                   	pop    %esi
  8002a3:	5f                   	pop    %edi
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	57                   	push   %edi
  8002aa:	56                   	push   %esi
  8002ab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ac:	be 00 00 00 00       	mov    $0x0,%esi
  8002b1:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002bf:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002c4:	5b                   	pop    %ebx
  8002c5:	5e                   	pop    %esi
  8002c6:	5f                   	pop    %edi
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    

008002c9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	57                   	push   %edi
  8002cd:	56                   	push   %esi
  8002ce:	53                   	push   %ebx
  8002cf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002d7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002df:	89 cb                	mov    %ecx,%ebx
  8002e1:	89 cf                	mov    %ecx,%edi
  8002e3:	89 ce                	mov    %ecx,%esi
  8002e5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002e7:	85 c0                	test   %eax,%eax
  8002e9:	7e 17                	jle    800302 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002eb:	83 ec 0c             	sub    $0xc,%esp
  8002ee:	50                   	push   %eax
  8002ef:	6a 0c                	push   $0xc
  8002f1:	68 6a 0f 80 00       	push   $0x800f6a
  8002f6:	6a 23                	push   $0x23
  8002f8:	68 87 0f 80 00       	push   $0x800f87
  8002fd:	e8 08 00 00 00       	call   80030a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800302:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	56                   	push   %esi
  80030e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80030f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800312:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800318:	e8 00 fe ff ff       	call   80011d <sys_getenvid>
  80031d:	83 ec 0c             	sub    $0xc,%esp
  800320:	ff 75 0c             	pushl  0xc(%ebp)
  800323:	ff 75 08             	pushl  0x8(%ebp)
  800326:	56                   	push   %esi
  800327:	50                   	push   %eax
  800328:	68 98 0f 80 00       	push   $0x800f98
  80032d:	e8 b1 00 00 00       	call   8003e3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800332:	83 c4 18             	add    $0x18,%esp
  800335:	53                   	push   %ebx
  800336:	ff 75 10             	pushl  0x10(%ebp)
  800339:	e8 54 00 00 00       	call   800392 <vcprintf>
	cprintf("\n");
  80033e:	c7 04 24 bc 0f 80 00 	movl   $0x800fbc,(%esp)
  800345:	e8 99 00 00 00       	call   8003e3 <cprintf>
  80034a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80034d:	cc                   	int3   
  80034e:	eb fd                	jmp    80034d <_panic+0x43>

00800350 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	53                   	push   %ebx
  800354:	83 ec 04             	sub    $0x4,%esp
  800357:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80035a:	8b 13                	mov    (%ebx),%edx
  80035c:	8d 42 01             	lea    0x1(%edx),%eax
  80035f:	89 03                	mov    %eax,(%ebx)
  800361:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800364:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800368:	3d ff 00 00 00       	cmp    $0xff,%eax
  80036d:	75 1a                	jne    800389 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80036f:	83 ec 08             	sub    $0x8,%esp
  800372:	68 ff 00 00 00       	push   $0xff
  800377:	8d 43 08             	lea    0x8(%ebx),%eax
  80037a:	50                   	push   %eax
  80037b:	e8 1f fd ff ff       	call   80009f <sys_cputs>
		b->idx = 0;
  800380:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800386:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800389:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80038d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800390:	c9                   	leave  
  800391:	c3                   	ret    

00800392 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800392:	55                   	push   %ebp
  800393:	89 e5                	mov    %esp,%ebp
  800395:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80039b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003a2:	00 00 00 
	b.cnt = 0;
  8003a5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003ac:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003af:	ff 75 0c             	pushl  0xc(%ebp)
  8003b2:	ff 75 08             	pushl  0x8(%ebp)
  8003b5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003bb:	50                   	push   %eax
  8003bc:	68 50 03 80 00       	push   $0x800350
  8003c1:	e8 54 01 00 00       	call   80051a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003c6:	83 c4 08             	add    $0x8,%esp
  8003c9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003cf:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003d5:	50                   	push   %eax
  8003d6:	e8 c4 fc ff ff       	call   80009f <sys_cputs>

	return b.cnt;
}
  8003db:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e1:	c9                   	leave  
  8003e2:	c3                   	ret    

008003e3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003e3:	55                   	push   %ebp
  8003e4:	89 e5                	mov    %esp,%ebp
  8003e6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003e9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ec:	50                   	push   %eax
  8003ed:	ff 75 08             	pushl  0x8(%ebp)
  8003f0:	e8 9d ff ff ff       	call   800392 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003f5:	c9                   	leave  
  8003f6:	c3                   	ret    

008003f7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003f7:	55                   	push   %ebp
  8003f8:	89 e5                	mov    %esp,%ebp
  8003fa:	57                   	push   %edi
  8003fb:	56                   	push   %esi
  8003fc:	53                   	push   %ebx
  8003fd:	83 ec 1c             	sub    $0x1c,%esp
  800400:	89 c7                	mov    %eax,%edi
  800402:	89 d6                	mov    %edx,%esi
  800404:	8b 45 08             	mov    0x8(%ebp),%eax
  800407:	8b 55 0c             	mov    0xc(%ebp),%edx
  80040a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80040d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800410:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800413:	bb 00 00 00 00       	mov    $0x0,%ebx
  800418:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80041b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80041e:	39 d3                	cmp    %edx,%ebx
  800420:	72 05                	jb     800427 <printnum+0x30>
  800422:	39 45 10             	cmp    %eax,0x10(%ebp)
  800425:	77 45                	ja     80046c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	ff 75 18             	pushl  0x18(%ebp)
  80042d:	8b 45 14             	mov    0x14(%ebp),%eax
  800430:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800433:	53                   	push   %ebx
  800434:	ff 75 10             	pushl  0x10(%ebp)
  800437:	83 ec 08             	sub    $0x8,%esp
  80043a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80043d:	ff 75 e0             	pushl  -0x20(%ebp)
  800440:	ff 75 dc             	pushl  -0x24(%ebp)
  800443:	ff 75 d8             	pushl  -0x28(%ebp)
  800446:	e8 85 08 00 00       	call   800cd0 <__udivdi3>
  80044b:	83 c4 18             	add    $0x18,%esp
  80044e:	52                   	push   %edx
  80044f:	50                   	push   %eax
  800450:	89 f2                	mov    %esi,%edx
  800452:	89 f8                	mov    %edi,%eax
  800454:	e8 9e ff ff ff       	call   8003f7 <printnum>
  800459:	83 c4 20             	add    $0x20,%esp
  80045c:	eb 18                	jmp    800476 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80045e:	83 ec 08             	sub    $0x8,%esp
  800461:	56                   	push   %esi
  800462:	ff 75 18             	pushl  0x18(%ebp)
  800465:	ff d7                	call   *%edi
  800467:	83 c4 10             	add    $0x10,%esp
  80046a:	eb 03                	jmp    80046f <printnum+0x78>
  80046c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80046f:	83 eb 01             	sub    $0x1,%ebx
  800472:	85 db                	test   %ebx,%ebx
  800474:	7f e8                	jg     80045e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800476:	83 ec 08             	sub    $0x8,%esp
  800479:	56                   	push   %esi
  80047a:	83 ec 04             	sub    $0x4,%esp
  80047d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800480:	ff 75 e0             	pushl  -0x20(%ebp)
  800483:	ff 75 dc             	pushl  -0x24(%ebp)
  800486:	ff 75 d8             	pushl  -0x28(%ebp)
  800489:	e8 72 09 00 00       	call   800e00 <__umoddi3>
  80048e:	83 c4 14             	add    $0x14,%esp
  800491:	0f be 80 be 0f 80 00 	movsbl 0x800fbe(%eax),%eax
  800498:	50                   	push   %eax
  800499:	ff d7                	call   *%edi
}
  80049b:	83 c4 10             	add    $0x10,%esp
  80049e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a1:	5b                   	pop    %ebx
  8004a2:	5e                   	pop    %esi
  8004a3:	5f                   	pop    %edi
  8004a4:	5d                   	pop    %ebp
  8004a5:	c3                   	ret    

008004a6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004a6:	55                   	push   %ebp
  8004a7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004a9:	83 fa 01             	cmp    $0x1,%edx
  8004ac:	7e 0e                	jle    8004bc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004ae:	8b 10                	mov    (%eax),%edx
  8004b0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004b3:	89 08                	mov    %ecx,(%eax)
  8004b5:	8b 02                	mov    (%edx),%eax
  8004b7:	8b 52 04             	mov    0x4(%edx),%edx
  8004ba:	eb 22                	jmp    8004de <getuint+0x38>
	else if (lflag)
  8004bc:	85 d2                	test   %edx,%edx
  8004be:	74 10                	je     8004d0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004c0:	8b 10                	mov    (%eax),%edx
  8004c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c5:	89 08                	mov    %ecx,(%eax)
  8004c7:	8b 02                	mov    (%edx),%eax
  8004c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ce:	eb 0e                	jmp    8004de <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004d0:	8b 10                	mov    (%eax),%edx
  8004d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d5:	89 08                	mov    %ecx,(%eax)
  8004d7:	8b 02                	mov    (%edx),%eax
  8004d9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004de:	5d                   	pop    %ebp
  8004df:	c3                   	ret    

008004e0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ea:	8b 10                	mov    (%eax),%edx
  8004ec:	3b 50 04             	cmp    0x4(%eax),%edx
  8004ef:	73 0a                	jae    8004fb <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004f4:	89 08                	mov    %ecx,(%eax)
  8004f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f9:	88 02                	mov    %al,(%edx)
}
  8004fb:	5d                   	pop    %ebp
  8004fc:	c3                   	ret    

008004fd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004fd:	55                   	push   %ebp
  8004fe:	89 e5                	mov    %esp,%ebp
  800500:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800503:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800506:	50                   	push   %eax
  800507:	ff 75 10             	pushl  0x10(%ebp)
  80050a:	ff 75 0c             	pushl  0xc(%ebp)
  80050d:	ff 75 08             	pushl  0x8(%ebp)
  800510:	e8 05 00 00 00       	call   80051a <vprintfmt>
	va_end(ap);
}
  800515:	83 c4 10             	add    $0x10,%esp
  800518:	c9                   	leave  
  800519:	c3                   	ret    

0080051a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80051a:	55                   	push   %ebp
  80051b:	89 e5                	mov    %esp,%ebp
  80051d:	57                   	push   %edi
  80051e:	56                   	push   %esi
  80051f:	53                   	push   %ebx
  800520:	83 ec 2c             	sub    $0x2c,%esp
  800523:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
  800526:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80052d:	eb 17                	jmp    800546 <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80052f:	85 c0                	test   %eax,%eax
  800531:	0f 84 9f 03 00 00    	je     8008d6 <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	ff 75 0c             	pushl  0xc(%ebp)
  80053d:	50                   	push   %eax
  80053e:	ff 55 08             	call   *0x8(%ebp)
  800541:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800544:	89 f3                	mov    %esi,%ebx
  800546:	8d 73 01             	lea    0x1(%ebx),%esi
  800549:	0f b6 03             	movzbl (%ebx),%eax
  80054c:	83 f8 25             	cmp    $0x25,%eax
  80054f:	75 de                	jne    80052f <vprintfmt+0x15>
  800551:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800555:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80055c:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800561:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800568:	ba 00 00 00 00       	mov    $0x0,%edx
  80056d:	eb 06                	jmp    800575 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056f:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800571:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800575:	8d 5e 01             	lea    0x1(%esi),%ebx
  800578:	0f b6 06             	movzbl (%esi),%eax
  80057b:	0f b6 c8             	movzbl %al,%ecx
  80057e:	83 e8 23             	sub    $0x23,%eax
  800581:	3c 55                	cmp    $0x55,%al
  800583:	0f 87 2d 03 00 00    	ja     8008b6 <vprintfmt+0x39c>
  800589:	0f b6 c0             	movzbl %al,%eax
  80058c:	ff 24 85 80 10 80 00 	jmp    *0x801080(,%eax,4)
  800593:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800595:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800599:	eb da                	jmp    800575 <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059b:	89 de                	mov    %ebx,%esi
  80059d:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005a2:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  8005a5:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  8005a9:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  8005ac:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8005af:	83 f8 09             	cmp    $0x9,%eax
  8005b2:	77 33                	ja     8005e7 <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005b4:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005b7:	eb e9                	jmp    8005a2 <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8d 48 04             	lea    0x4(%eax),%ecx
  8005bf:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005c2:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c4:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005c6:	eb 1f                	jmp    8005e7 <vprintfmt+0xcd>
  8005c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005cb:	85 c0                	test   %eax,%eax
  8005cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d2:	0f 49 c8             	cmovns %eax,%ecx
  8005d5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d8:	89 de                	mov    %ebx,%esi
  8005da:	eb 99                	jmp    800575 <vprintfmt+0x5b>
  8005dc:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005de:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  8005e5:	eb 8e                	jmp    800575 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8005e7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005eb:	79 88                	jns    800575 <vprintfmt+0x5b>
				width = precision, precision = -1;
  8005ed:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8005f0:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8005f5:	e9 7b ff ff ff       	jmp    800575 <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005fa:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fd:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005ff:	e9 71 ff ff ff       	jmp    800575 <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8d 50 04             	lea    0x4(%eax),%edx
  80060a:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  80060d:	83 ec 08             	sub    $0x8,%esp
  800610:	ff 75 0c             	pushl  0xc(%ebp)
  800613:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800616:	03 08                	add    (%eax),%ecx
  800618:	51                   	push   %ecx
  800619:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
  80061c:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
  80061f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
  800626:	e9 1b ff ff ff       	jmp    800546 <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8d 48 04             	lea    0x4(%eax),%ecx
  800631:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800634:	8b 00                	mov    (%eax),%eax
  800636:	83 f8 02             	cmp    $0x2,%eax
  800639:	74 1a                	je     800655 <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063b:	89 de                	mov    %ebx,%esi
  80063d:	83 f8 04             	cmp    $0x4,%eax
  800640:	b8 00 00 00 00       	mov    $0x0,%eax
  800645:	b9 00 04 00 00       	mov    $0x400,%ecx
  80064a:	0f 44 c1             	cmove  %ecx,%eax
  80064d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800650:	e9 20 ff ff ff       	jmp    800575 <vprintfmt+0x5b>
  800655:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
  800657:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
  80065e:	e9 12 ff ff ff       	jmp    800575 <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	8d 50 04             	lea    0x4(%eax),%edx
  800669:	89 55 14             	mov    %edx,0x14(%ebp)
  80066c:	8b 00                	mov    (%eax),%eax
  80066e:	99                   	cltd   
  80066f:	31 d0                	xor    %edx,%eax
  800671:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800673:	83 f8 09             	cmp    $0x9,%eax
  800676:	7f 0b                	jg     800683 <vprintfmt+0x169>
  800678:	8b 14 85 e0 11 80 00 	mov    0x8011e0(,%eax,4),%edx
  80067f:	85 d2                	test   %edx,%edx
  800681:	75 19                	jne    80069c <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800683:	50                   	push   %eax
  800684:	68 d6 0f 80 00       	push   $0x800fd6
  800689:	ff 75 0c             	pushl  0xc(%ebp)
  80068c:	ff 75 08             	pushl  0x8(%ebp)
  80068f:	e8 69 fe ff ff       	call   8004fd <printfmt>
  800694:	83 c4 10             	add    $0x10,%esp
  800697:	e9 aa fe ff ff       	jmp    800546 <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  80069c:	52                   	push   %edx
  80069d:	68 df 0f 80 00       	push   $0x800fdf
  8006a2:	ff 75 0c             	pushl  0xc(%ebp)
  8006a5:	ff 75 08             	pushl  0x8(%ebp)
  8006a8:	e8 50 fe ff ff       	call   8004fd <printfmt>
  8006ad:	83 c4 10             	add    $0x10,%esp
  8006b0:	e9 91 fe ff ff       	jmp    800546 <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8d 50 04             	lea    0x4(%eax),%edx
  8006bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006be:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006c0:	85 f6                	test   %esi,%esi
  8006c2:	b8 cf 0f 80 00       	mov    $0x800fcf,%eax
  8006c7:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006ca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006ce:	0f 8e 93 00 00 00    	jle    800767 <vprintfmt+0x24d>
  8006d4:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8006d8:	0f 84 91 00 00 00    	je     80076f <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006de:	83 ec 08             	sub    $0x8,%esp
  8006e1:	57                   	push   %edi
  8006e2:	56                   	push   %esi
  8006e3:	e8 76 02 00 00       	call   80095e <strnlen>
  8006e8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006eb:	29 c1                	sub    %eax,%ecx
  8006ed:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006f0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006f3:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8006f7:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006fa:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006fd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800700:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800703:	89 cb                	mov    %ecx,%ebx
  800705:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800707:	eb 0e                	jmp    800717 <vprintfmt+0x1fd>
					putch(padc, putdat);
  800709:	83 ec 08             	sub    $0x8,%esp
  80070c:	56                   	push   %esi
  80070d:	57                   	push   %edi
  80070e:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800711:	83 eb 01             	sub    $0x1,%ebx
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	85 db                	test   %ebx,%ebx
  800719:	7f ee                	jg     800709 <vprintfmt+0x1ef>
  80071b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80071e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800721:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800724:	85 c9                	test   %ecx,%ecx
  800726:	b8 00 00 00 00       	mov    $0x0,%eax
  80072b:	0f 49 c1             	cmovns %ecx,%eax
  80072e:	29 c1                	sub    %eax,%ecx
  800730:	89 cb                	mov    %ecx,%ebx
  800732:	eb 41                	jmp    800775 <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800734:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800738:	74 1b                	je     800755 <vprintfmt+0x23b>
  80073a:	0f be c0             	movsbl %al,%eax
  80073d:	83 e8 20             	sub    $0x20,%eax
  800740:	83 f8 5e             	cmp    $0x5e,%eax
  800743:	76 10                	jbe    800755 <vprintfmt+0x23b>
					putch('?', putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	ff 75 0c             	pushl  0xc(%ebp)
  80074b:	6a 3f                	push   $0x3f
  80074d:	ff 55 08             	call   *0x8(%ebp)
  800750:	83 c4 10             	add    $0x10,%esp
  800753:	eb 0d                	jmp    800762 <vprintfmt+0x248>
				else
					putch(ch, putdat);
  800755:	83 ec 08             	sub    $0x8,%esp
  800758:	ff 75 0c             	pushl  0xc(%ebp)
  80075b:	52                   	push   %edx
  80075c:	ff 55 08             	call   *0x8(%ebp)
  80075f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800762:	83 eb 01             	sub    $0x1,%ebx
  800765:	eb 0e                	jmp    800775 <vprintfmt+0x25b>
  800767:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80076a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80076d:	eb 06                	jmp    800775 <vprintfmt+0x25b>
  80076f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800772:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800775:	83 c6 01             	add    $0x1,%esi
  800778:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80077c:	0f be d0             	movsbl %al,%edx
  80077f:	85 d2                	test   %edx,%edx
  800781:	74 25                	je     8007a8 <vprintfmt+0x28e>
  800783:	85 ff                	test   %edi,%edi
  800785:	78 ad                	js     800734 <vprintfmt+0x21a>
  800787:	83 ef 01             	sub    $0x1,%edi
  80078a:	79 a8                	jns    800734 <vprintfmt+0x21a>
  80078c:	89 d8                	mov    %ebx,%eax
  80078e:	8b 75 08             	mov    0x8(%ebp),%esi
  800791:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800794:	89 c3                	mov    %eax,%ebx
  800796:	eb 16                	jmp    8007ae <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800798:	83 ec 08             	sub    $0x8,%esp
  80079b:	57                   	push   %edi
  80079c:	6a 20                	push   $0x20
  80079e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007a0:	83 eb 01             	sub    $0x1,%ebx
  8007a3:	83 c4 10             	add    $0x10,%esp
  8007a6:	eb 06                	jmp    8007ae <vprintfmt+0x294>
  8007a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ab:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8007ae:	85 db                	test   %ebx,%ebx
  8007b0:	7f e6                	jg     800798 <vprintfmt+0x27e>
  8007b2:	89 75 08             	mov    %esi,0x8(%ebp)
  8007b5:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8007b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007bb:	e9 86 fd ff ff       	jmp    800546 <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007c0:	83 fa 01             	cmp    $0x1,%edx
  8007c3:	7e 10                	jle    8007d5 <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
  8007c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c8:	8d 50 08             	lea    0x8(%eax),%edx
  8007cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ce:	8b 30                	mov    (%eax),%esi
  8007d0:	8b 78 04             	mov    0x4(%eax),%edi
  8007d3:	eb 26                	jmp    8007fb <vprintfmt+0x2e1>
	else if (lflag)
  8007d5:	85 d2                	test   %edx,%edx
  8007d7:	74 12                	je     8007eb <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  8007d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dc:	8d 50 04             	lea    0x4(%eax),%edx
  8007df:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e2:	8b 30                	mov    (%eax),%esi
  8007e4:	89 f7                	mov    %esi,%edi
  8007e6:	c1 ff 1f             	sar    $0x1f,%edi
  8007e9:	eb 10                	jmp    8007fb <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
  8007eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ee:	8d 50 04             	lea    0x4(%eax),%edx
  8007f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f4:	8b 30                	mov    (%eax),%esi
  8007f6:	89 f7                	mov    %esi,%edi
  8007f8:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007fb:	89 f0                	mov    %esi,%eax
  8007fd:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007ff:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800804:	85 ff                	test   %edi,%edi
  800806:	79 7b                	jns    800883 <vprintfmt+0x369>
				putch('-', putdat);
  800808:	83 ec 08             	sub    $0x8,%esp
  80080b:	ff 75 0c             	pushl  0xc(%ebp)
  80080e:	6a 2d                	push   $0x2d
  800810:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800813:	89 f0                	mov    %esi,%eax
  800815:	89 fa                	mov    %edi,%edx
  800817:	f7 d8                	neg    %eax
  800819:	83 d2 00             	adc    $0x0,%edx
  80081c:	f7 da                	neg    %edx
  80081e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800821:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800826:	eb 5b                	jmp    800883 <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800828:	8d 45 14             	lea    0x14(%ebp),%eax
  80082b:	e8 76 fc ff ff       	call   8004a6 <getuint>
			base = 10;
  800830:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800835:	eb 4c                	jmp    800883 <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
  800837:	8d 45 14             	lea    0x14(%ebp),%eax
  80083a:	e8 67 fc ff ff       	call   8004a6 <getuint>
            base = 8;
  80083f:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800844:	eb 3d                	jmp    800883 <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
  800846:	83 ec 08             	sub    $0x8,%esp
  800849:	ff 75 0c             	pushl  0xc(%ebp)
  80084c:	6a 30                	push   $0x30
  80084e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800851:	83 c4 08             	add    $0x8,%esp
  800854:	ff 75 0c             	pushl  0xc(%ebp)
  800857:	6a 78                	push   $0x78
  800859:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80085c:	8b 45 14             	mov    0x14(%ebp),%eax
  80085f:	8d 50 04             	lea    0x4(%eax),%edx
  800862:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800865:	8b 00                	mov    (%eax),%eax
  800867:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80086c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80086f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800874:	eb 0d                	jmp    800883 <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800876:	8d 45 14             	lea    0x14(%ebp),%eax
  800879:	e8 28 fc ff ff       	call   8004a6 <getuint>
			base = 16;
  80087e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800883:	83 ec 0c             	sub    $0xc,%esp
  800886:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  80088a:	56                   	push   %esi
  80088b:	ff 75 e0             	pushl  -0x20(%ebp)
  80088e:	51                   	push   %ecx
  80088f:	52                   	push   %edx
  800890:	50                   	push   %eax
  800891:	8b 55 0c             	mov    0xc(%ebp),%edx
  800894:	8b 45 08             	mov    0x8(%ebp),%eax
  800897:	e8 5b fb ff ff       	call   8003f7 <printnum>
			break;
  80089c:	83 c4 20             	add    $0x20,%esp
  80089f:	e9 a2 fc ff ff       	jmp    800546 <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008a4:	83 ec 08             	sub    $0x8,%esp
  8008a7:	ff 75 0c             	pushl  0xc(%ebp)
  8008aa:	51                   	push   %ecx
  8008ab:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008ae:	83 c4 10             	add    $0x10,%esp
  8008b1:	e9 90 fc ff ff       	jmp    800546 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008b6:	83 ec 08             	sub    $0x8,%esp
  8008b9:	ff 75 0c             	pushl  0xc(%ebp)
  8008bc:	6a 25                	push   $0x25
  8008be:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008c1:	83 c4 10             	add    $0x10,%esp
  8008c4:	89 f3                	mov    %esi,%ebx
  8008c6:	eb 03                	jmp    8008cb <vprintfmt+0x3b1>
  8008c8:	83 eb 01             	sub    $0x1,%ebx
  8008cb:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8008cf:	75 f7                	jne    8008c8 <vprintfmt+0x3ae>
  8008d1:	e9 70 fc ff ff       	jmp    800546 <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  8008d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008d9:	5b                   	pop    %ebx
  8008da:	5e                   	pop    %esi
  8008db:	5f                   	pop    %edi
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	83 ec 18             	sub    $0x18,%esp
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ed:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008f1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008fb:	85 c0                	test   %eax,%eax
  8008fd:	74 26                	je     800925 <vsnprintf+0x47>
  8008ff:	85 d2                	test   %edx,%edx
  800901:	7e 22                	jle    800925 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800903:	ff 75 14             	pushl  0x14(%ebp)
  800906:	ff 75 10             	pushl  0x10(%ebp)
  800909:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80090c:	50                   	push   %eax
  80090d:	68 e0 04 80 00       	push   $0x8004e0
  800912:	e8 03 fc ff ff       	call   80051a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800917:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80091a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80091d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800920:	83 c4 10             	add    $0x10,%esp
  800923:	eb 05                	jmp    80092a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800925:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80092a:	c9                   	leave  
  80092b:	c3                   	ret    

0080092c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800932:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800935:	50                   	push   %eax
  800936:	ff 75 10             	pushl  0x10(%ebp)
  800939:	ff 75 0c             	pushl  0xc(%ebp)
  80093c:	ff 75 08             	pushl  0x8(%ebp)
  80093f:	e8 9a ff ff ff       	call   8008de <vsnprintf>
	va_end(ap);

	return rc;
}
  800944:	c9                   	leave  
  800945:	c3                   	ret    

00800946 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80094c:	b8 00 00 00 00       	mov    $0x0,%eax
  800951:	eb 03                	jmp    800956 <strlen+0x10>
		n++;
  800953:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800956:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80095a:	75 f7                	jne    800953 <strlen+0xd>
		n++;
	return n;
}
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800964:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800967:	ba 00 00 00 00       	mov    $0x0,%edx
  80096c:	eb 03                	jmp    800971 <strnlen+0x13>
		n++;
  80096e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800971:	39 c2                	cmp    %eax,%edx
  800973:	74 08                	je     80097d <strnlen+0x1f>
  800975:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800979:	75 f3                	jne    80096e <strnlen+0x10>
  80097b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	53                   	push   %ebx
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
  800986:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800989:	89 c2                	mov    %eax,%edx
  80098b:	83 c2 01             	add    $0x1,%edx
  80098e:	83 c1 01             	add    $0x1,%ecx
  800991:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800995:	88 5a ff             	mov    %bl,-0x1(%edx)
  800998:	84 db                	test   %bl,%bl
  80099a:	75 ef                	jne    80098b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80099c:	5b                   	pop    %ebx
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	53                   	push   %ebx
  8009a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009a6:	53                   	push   %ebx
  8009a7:	e8 9a ff ff ff       	call   800946 <strlen>
  8009ac:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009af:	ff 75 0c             	pushl  0xc(%ebp)
  8009b2:	01 d8                	add    %ebx,%eax
  8009b4:	50                   	push   %eax
  8009b5:	e8 c5 ff ff ff       	call   80097f <strcpy>
	return dst;
}
  8009ba:	89 d8                	mov    %ebx,%eax
  8009bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009bf:	c9                   	leave  
  8009c0:	c3                   	ret    

008009c1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	56                   	push   %esi
  8009c5:	53                   	push   %ebx
  8009c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009cc:	89 f3                	mov    %esi,%ebx
  8009ce:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d1:	89 f2                	mov    %esi,%edx
  8009d3:	eb 0f                	jmp    8009e4 <strncpy+0x23>
		*dst++ = *src;
  8009d5:	83 c2 01             	add    $0x1,%edx
  8009d8:	0f b6 01             	movzbl (%ecx),%eax
  8009db:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009de:	80 39 01             	cmpb   $0x1,(%ecx)
  8009e1:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009e4:	39 da                	cmp    %ebx,%edx
  8009e6:	75 ed                	jne    8009d5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009e8:	89 f0                	mov    %esi,%eax
  8009ea:	5b                   	pop    %ebx
  8009eb:	5e                   	pop    %esi
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	56                   	push   %esi
  8009f2:	53                   	push   %ebx
  8009f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f9:	8b 55 10             	mov    0x10(%ebp),%edx
  8009fc:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009fe:	85 d2                	test   %edx,%edx
  800a00:	74 21                	je     800a23 <strlcpy+0x35>
  800a02:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a06:	89 f2                	mov    %esi,%edx
  800a08:	eb 09                	jmp    800a13 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a0a:	83 c2 01             	add    $0x1,%edx
  800a0d:	83 c1 01             	add    $0x1,%ecx
  800a10:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a13:	39 c2                	cmp    %eax,%edx
  800a15:	74 09                	je     800a20 <strlcpy+0x32>
  800a17:	0f b6 19             	movzbl (%ecx),%ebx
  800a1a:	84 db                	test   %bl,%bl
  800a1c:	75 ec                	jne    800a0a <strlcpy+0x1c>
  800a1e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a20:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a23:	29 f0                	sub    %esi,%eax
}
  800a25:	5b                   	pop    %ebx
  800a26:	5e                   	pop    %esi
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a32:	eb 06                	jmp    800a3a <strcmp+0x11>
		p++, q++;
  800a34:	83 c1 01             	add    $0x1,%ecx
  800a37:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a3a:	0f b6 01             	movzbl (%ecx),%eax
  800a3d:	84 c0                	test   %al,%al
  800a3f:	74 04                	je     800a45 <strcmp+0x1c>
  800a41:	3a 02                	cmp    (%edx),%al
  800a43:	74 ef                	je     800a34 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a45:	0f b6 c0             	movzbl %al,%eax
  800a48:	0f b6 12             	movzbl (%edx),%edx
  800a4b:	29 d0                	sub    %edx,%eax
}
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	53                   	push   %ebx
  800a53:	8b 45 08             	mov    0x8(%ebp),%eax
  800a56:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a59:	89 c3                	mov    %eax,%ebx
  800a5b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a5e:	eb 06                	jmp    800a66 <strncmp+0x17>
		n--, p++, q++;
  800a60:	83 c0 01             	add    $0x1,%eax
  800a63:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a66:	39 d8                	cmp    %ebx,%eax
  800a68:	74 15                	je     800a7f <strncmp+0x30>
  800a6a:	0f b6 08             	movzbl (%eax),%ecx
  800a6d:	84 c9                	test   %cl,%cl
  800a6f:	74 04                	je     800a75 <strncmp+0x26>
  800a71:	3a 0a                	cmp    (%edx),%cl
  800a73:	74 eb                	je     800a60 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a75:	0f b6 00             	movzbl (%eax),%eax
  800a78:	0f b6 12             	movzbl (%edx),%edx
  800a7b:	29 d0                	sub    %edx,%eax
  800a7d:	eb 05                	jmp    800a84 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a7f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a84:	5b                   	pop    %ebx
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a91:	eb 07                	jmp    800a9a <strchr+0x13>
		if (*s == c)
  800a93:	38 ca                	cmp    %cl,%dl
  800a95:	74 0f                	je     800aa6 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a97:	83 c0 01             	add    $0x1,%eax
  800a9a:	0f b6 10             	movzbl (%eax),%edx
  800a9d:	84 d2                	test   %dl,%dl
  800a9f:	75 f2                	jne    800a93 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800aa1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa6:	5d                   	pop    %ebp
  800aa7:	c3                   	ret    

00800aa8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	8b 45 08             	mov    0x8(%ebp),%eax
  800aae:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab2:	eb 03                	jmp    800ab7 <strfind+0xf>
  800ab4:	83 c0 01             	add    $0x1,%eax
  800ab7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aba:	38 ca                	cmp    %cl,%dl
  800abc:	74 04                	je     800ac2 <strfind+0x1a>
  800abe:	84 d2                	test   %dl,%dl
  800ac0:	75 f2                	jne    800ab4 <strfind+0xc>
			break;
	return (char *) s;
}
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
  800aca:	8b 7d 08             	mov    0x8(%ebp),%edi
  800acd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ad0:	85 c9                	test   %ecx,%ecx
  800ad2:	74 36                	je     800b0a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ad4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ada:	75 28                	jne    800b04 <memset+0x40>
  800adc:	f6 c1 03             	test   $0x3,%cl
  800adf:	75 23                	jne    800b04 <memset+0x40>
		c &= 0xFF;
  800ae1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ae5:	89 d3                	mov    %edx,%ebx
  800ae7:	c1 e3 08             	shl    $0x8,%ebx
  800aea:	89 d6                	mov    %edx,%esi
  800aec:	c1 e6 18             	shl    $0x18,%esi
  800aef:	89 d0                	mov    %edx,%eax
  800af1:	c1 e0 10             	shl    $0x10,%eax
  800af4:	09 f0                	or     %esi,%eax
  800af6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800af8:	89 d8                	mov    %ebx,%eax
  800afa:	09 d0                	or     %edx,%eax
  800afc:	c1 e9 02             	shr    $0x2,%ecx
  800aff:	fc                   	cld    
  800b00:	f3 ab                	rep stos %eax,%es:(%edi)
  800b02:	eb 06                	jmp    800b0a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b04:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b07:	fc                   	cld    
  800b08:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b0a:	89 f8                	mov    %edi,%eax
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	8b 45 08             	mov    0x8(%ebp),%eax
  800b19:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b1f:	39 c6                	cmp    %eax,%esi
  800b21:	73 35                	jae    800b58 <memmove+0x47>
  800b23:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b26:	39 d0                	cmp    %edx,%eax
  800b28:	73 2e                	jae    800b58 <memmove+0x47>
		s += n;
		d += n;
  800b2a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b2d:	89 d6                	mov    %edx,%esi
  800b2f:	09 fe                	or     %edi,%esi
  800b31:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b37:	75 13                	jne    800b4c <memmove+0x3b>
  800b39:	f6 c1 03             	test   $0x3,%cl
  800b3c:	75 0e                	jne    800b4c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b3e:	83 ef 04             	sub    $0x4,%edi
  800b41:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b44:	c1 e9 02             	shr    $0x2,%ecx
  800b47:	fd                   	std    
  800b48:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4a:	eb 09                	jmp    800b55 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b4c:	83 ef 01             	sub    $0x1,%edi
  800b4f:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b52:	fd                   	std    
  800b53:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b55:	fc                   	cld    
  800b56:	eb 1d                	jmp    800b75 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b58:	89 f2                	mov    %esi,%edx
  800b5a:	09 c2                	or     %eax,%edx
  800b5c:	f6 c2 03             	test   $0x3,%dl
  800b5f:	75 0f                	jne    800b70 <memmove+0x5f>
  800b61:	f6 c1 03             	test   $0x3,%cl
  800b64:	75 0a                	jne    800b70 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b66:	c1 e9 02             	shr    $0x2,%ecx
  800b69:	89 c7                	mov    %eax,%edi
  800b6b:	fc                   	cld    
  800b6c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b6e:	eb 05                	jmp    800b75 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b70:	89 c7                	mov    %eax,%edi
  800b72:	fc                   	cld    
  800b73:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b7c:	ff 75 10             	pushl  0x10(%ebp)
  800b7f:	ff 75 0c             	pushl  0xc(%ebp)
  800b82:	ff 75 08             	pushl  0x8(%ebp)
  800b85:	e8 87 ff ff ff       	call   800b11 <memmove>
}
  800b8a:	c9                   	leave  
  800b8b:	c3                   	ret    

00800b8c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	56                   	push   %esi
  800b90:	53                   	push   %ebx
  800b91:	8b 45 08             	mov    0x8(%ebp),%eax
  800b94:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b97:	89 c6                	mov    %eax,%esi
  800b99:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b9c:	eb 1a                	jmp    800bb8 <memcmp+0x2c>
		if (*s1 != *s2)
  800b9e:	0f b6 08             	movzbl (%eax),%ecx
  800ba1:	0f b6 1a             	movzbl (%edx),%ebx
  800ba4:	38 d9                	cmp    %bl,%cl
  800ba6:	74 0a                	je     800bb2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ba8:	0f b6 c1             	movzbl %cl,%eax
  800bab:	0f b6 db             	movzbl %bl,%ebx
  800bae:	29 d8                	sub    %ebx,%eax
  800bb0:	eb 0f                	jmp    800bc1 <memcmp+0x35>
		s1++, s2++;
  800bb2:	83 c0 01             	add    $0x1,%eax
  800bb5:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bb8:	39 f0                	cmp    %esi,%eax
  800bba:	75 e2                	jne    800b9e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bbc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	53                   	push   %ebx
  800bc9:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bcc:	89 c1                	mov    %eax,%ecx
  800bce:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd1:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bd5:	eb 0a                	jmp    800be1 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd7:	0f b6 10             	movzbl (%eax),%edx
  800bda:	39 da                	cmp    %ebx,%edx
  800bdc:	74 07                	je     800be5 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bde:	83 c0 01             	add    $0x1,%eax
  800be1:	39 c8                	cmp    %ecx,%eax
  800be3:	72 f2                	jb     800bd7 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800be5:	5b                   	pop    %ebx
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    

00800be8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	57                   	push   %edi
  800bec:	56                   	push   %esi
  800bed:	53                   	push   %ebx
  800bee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf4:	eb 03                	jmp    800bf9 <strtol+0x11>
		s++;
  800bf6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf9:	0f b6 01             	movzbl (%ecx),%eax
  800bfc:	3c 20                	cmp    $0x20,%al
  800bfe:	74 f6                	je     800bf6 <strtol+0xe>
  800c00:	3c 09                	cmp    $0x9,%al
  800c02:	74 f2                	je     800bf6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c04:	3c 2b                	cmp    $0x2b,%al
  800c06:	75 0a                	jne    800c12 <strtol+0x2a>
		s++;
  800c08:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c0b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c10:	eb 11                	jmp    800c23 <strtol+0x3b>
  800c12:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c17:	3c 2d                	cmp    $0x2d,%al
  800c19:	75 08                	jne    800c23 <strtol+0x3b>
		s++, neg = 1;
  800c1b:	83 c1 01             	add    $0x1,%ecx
  800c1e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c23:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c29:	75 15                	jne    800c40 <strtol+0x58>
  800c2b:	80 39 30             	cmpb   $0x30,(%ecx)
  800c2e:	75 10                	jne    800c40 <strtol+0x58>
  800c30:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c34:	75 7c                	jne    800cb2 <strtol+0xca>
		s += 2, base = 16;
  800c36:	83 c1 02             	add    $0x2,%ecx
  800c39:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c3e:	eb 16                	jmp    800c56 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c40:	85 db                	test   %ebx,%ebx
  800c42:	75 12                	jne    800c56 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c44:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c49:	80 39 30             	cmpb   $0x30,(%ecx)
  800c4c:	75 08                	jne    800c56 <strtol+0x6e>
		s++, base = 8;
  800c4e:	83 c1 01             	add    $0x1,%ecx
  800c51:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c56:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c5e:	0f b6 11             	movzbl (%ecx),%edx
  800c61:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c64:	89 f3                	mov    %esi,%ebx
  800c66:	80 fb 09             	cmp    $0x9,%bl
  800c69:	77 08                	ja     800c73 <strtol+0x8b>
			dig = *s - '0';
  800c6b:	0f be d2             	movsbl %dl,%edx
  800c6e:	83 ea 30             	sub    $0x30,%edx
  800c71:	eb 22                	jmp    800c95 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c73:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c76:	89 f3                	mov    %esi,%ebx
  800c78:	80 fb 19             	cmp    $0x19,%bl
  800c7b:	77 08                	ja     800c85 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c7d:	0f be d2             	movsbl %dl,%edx
  800c80:	83 ea 57             	sub    $0x57,%edx
  800c83:	eb 10                	jmp    800c95 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c85:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c88:	89 f3                	mov    %esi,%ebx
  800c8a:	80 fb 19             	cmp    $0x19,%bl
  800c8d:	77 16                	ja     800ca5 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c8f:	0f be d2             	movsbl %dl,%edx
  800c92:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c95:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c98:	7d 0b                	jge    800ca5 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c9a:	83 c1 01             	add    $0x1,%ecx
  800c9d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ca1:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ca3:	eb b9                	jmp    800c5e <strtol+0x76>

	if (endptr)
  800ca5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ca9:	74 0d                	je     800cb8 <strtol+0xd0>
		*endptr = (char *) s;
  800cab:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cae:	89 0e                	mov    %ecx,(%esi)
  800cb0:	eb 06                	jmp    800cb8 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cb2:	85 db                	test   %ebx,%ebx
  800cb4:	74 98                	je     800c4e <strtol+0x66>
  800cb6:	eb 9e                	jmp    800c56 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cb8:	89 c2                	mov    %eax,%edx
  800cba:	f7 da                	neg    %edx
  800cbc:	85 ff                	test   %edi,%edi
  800cbe:	0f 45 c2             	cmovne %edx,%eax
}
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    
  800cc6:	66 90                	xchg   %ax,%ax
  800cc8:	66 90                	xchg   %ax,%ax
  800cca:	66 90                	xchg   %ax,%ax
  800ccc:	66 90                	xchg   %ax,%ax
  800cce:	66 90                	xchg   %ax,%ax

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
