
obj/user/buggyhello2：     文件格式 elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 20 80 00    	pushl  0x802000
  800044:	e8 5d 00 00 00       	call   8000a6 <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800059:	e8 c6 00 00 00       	call   800124 <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 42 00 00 00       	call   8000e3 <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	57                   	push   %edi
  8000aa:	56                   	push   %esi
  8000ab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b7:	89 c3                	mov    %eax,%ebx
  8000b9:	89 c7                	mov    %eax,%edi
  8000bb:	89 c6                	mov    %eax,%esi
  8000bd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bf:	5b                   	pop    %ebx
  8000c0:	5e                   	pop    %esi
  8000c1:	5f                   	pop    %edi
  8000c2:	5d                   	pop    %ebp
  8000c3:	c3                   	ret    

008000c4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d4:	89 d1                	mov    %edx,%ecx
  8000d6:	89 d3                	mov    %edx,%ebx
  8000d8:	89 d7                	mov    %edx,%edi
  8000da:	89 d6                	mov    %edx,%esi
  8000dc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f1:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f9:	89 cb                	mov    %ecx,%ebx
  8000fb:	89 cf                	mov    %ecx,%edi
  8000fd:	89 ce                	mov    %ecx,%esi
  8000ff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800101:	85 c0                	test   %eax,%eax
  800103:	7e 17                	jle    80011c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800105:	83 ec 0c             	sub    $0xc,%esp
  800108:	50                   	push   %eax
  800109:	6a 03                	push   $0x3
  80010b:	68 78 0f 80 00       	push   $0x800f78
  800110:	6a 23                	push   $0x23
  800112:	68 95 0f 80 00       	push   $0x800f95
  800117:	e8 f5 01 00 00       	call   800311 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011f:	5b                   	pop    %ebx
  800120:	5e                   	pop    %esi
  800121:	5f                   	pop    %edi
  800122:	5d                   	pop    %ebp
  800123:	c3                   	ret    

00800124 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	57                   	push   %edi
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012a:	ba 00 00 00 00       	mov    $0x0,%edx
  80012f:	b8 02 00 00 00       	mov    $0x2,%eax
  800134:	89 d1                	mov    %edx,%ecx
  800136:	89 d3                	mov    %edx,%ebx
  800138:	89 d7                	mov    %edx,%edi
  80013a:	89 d6                	mov    %edx,%esi
  80013c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_yield>:

void
sys_yield(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
  800168:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016b:	be 00 00 00 00       	mov    $0x0,%esi
  800170:	b8 04 00 00 00       	mov    $0x4,%eax
  800175:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800178:	8b 55 08             	mov    0x8(%ebp),%edx
  80017b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017e:	89 f7                	mov    %esi,%edi
  800180:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800182:	85 c0                	test   %eax,%eax
  800184:	7e 17                	jle    80019d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800186:	83 ec 0c             	sub    $0xc,%esp
  800189:	50                   	push   %eax
  80018a:	6a 04                	push   $0x4
  80018c:	68 78 0f 80 00       	push   $0x800f78
  800191:	6a 23                	push   $0x23
  800193:	68 95 0f 80 00       	push   $0x800f95
  800198:	e8 74 01 00 00       	call   800311 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a0:	5b                   	pop    %ebx
  8001a1:	5e                   	pop    %esi
  8001a2:	5f                   	pop    %edi
  8001a3:	5d                   	pop    %ebp
  8001a4:	c3                   	ret    

008001a5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	57                   	push   %edi
  8001a9:	56                   	push   %esi
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ae:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bf:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c4:	85 c0                	test   %eax,%eax
  8001c6:	7e 17                	jle    8001df <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c8:	83 ec 0c             	sub    $0xc,%esp
  8001cb:	50                   	push   %eax
  8001cc:	6a 05                	push   $0x5
  8001ce:	68 78 0f 80 00       	push   $0x800f78
  8001d3:	6a 23                	push   $0x23
  8001d5:	68 95 0f 80 00       	push   $0x800f95
  8001da:	e8 32 01 00 00       	call   800311 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e2:	5b                   	pop    %ebx
  8001e3:	5e                   	pop    %esi
  8001e4:	5f                   	pop    %edi
  8001e5:	5d                   	pop    %ebp
  8001e6:	c3                   	ret    

008001e7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	57                   	push   %edi
  8001eb:	56                   	push   %esi
  8001ec:	53                   	push   %ebx
  8001ed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f5:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800200:	89 df                	mov    %ebx,%edi
  800202:	89 de                	mov    %ebx,%esi
  800204:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800206:	85 c0                	test   %eax,%eax
  800208:	7e 17                	jle    800221 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020a:	83 ec 0c             	sub    $0xc,%esp
  80020d:	50                   	push   %eax
  80020e:	6a 06                	push   $0x6
  800210:	68 78 0f 80 00       	push   $0x800f78
  800215:	6a 23                	push   $0x23
  800217:	68 95 0f 80 00       	push   $0x800f95
  80021c:	e8 f0 00 00 00       	call   800311 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800221:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800224:	5b                   	pop    %ebx
  800225:	5e                   	pop    %esi
  800226:	5f                   	pop    %edi
  800227:	5d                   	pop    %ebp
  800228:	c3                   	ret    

00800229 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800232:	bb 00 00 00 00       	mov    $0x0,%ebx
  800237:	b8 08 00 00 00       	mov    $0x8,%eax
  80023c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023f:	8b 55 08             	mov    0x8(%ebp),%edx
  800242:	89 df                	mov    %ebx,%edi
  800244:	89 de                	mov    %ebx,%esi
  800246:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800248:	85 c0                	test   %eax,%eax
  80024a:	7e 17                	jle    800263 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024c:	83 ec 0c             	sub    $0xc,%esp
  80024f:	50                   	push   %eax
  800250:	6a 08                	push   $0x8
  800252:	68 78 0f 80 00       	push   $0x800f78
  800257:	6a 23                	push   $0x23
  800259:	68 95 0f 80 00       	push   $0x800f95
  80025e:	e8 ae 00 00 00       	call   800311 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	57                   	push   %edi
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800274:	bb 00 00 00 00       	mov    $0x0,%ebx
  800279:	b8 09 00 00 00       	mov    $0x9,%eax
  80027e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800281:	8b 55 08             	mov    0x8(%ebp),%edx
  800284:	89 df                	mov    %ebx,%edi
  800286:	89 de                	mov    %ebx,%esi
  800288:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80028a:	85 c0                	test   %eax,%eax
  80028c:	7e 17                	jle    8002a5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028e:	83 ec 0c             	sub    $0xc,%esp
  800291:	50                   	push   %eax
  800292:	6a 09                	push   $0x9
  800294:	68 78 0f 80 00       	push   $0x800f78
  800299:	6a 23                	push   $0x23
  80029b:	68 95 0f 80 00       	push   $0x800f95
  8002a0:	e8 6c 00 00 00       	call   800311 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a8:	5b                   	pop    %ebx
  8002a9:	5e                   	pop    %esi
  8002aa:	5f                   	pop    %edi
  8002ab:	5d                   	pop    %ebp
  8002ac:	c3                   	ret    

008002ad <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	57                   	push   %edi
  8002b1:	56                   	push   %esi
  8002b2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b3:	be 00 00 00 00       	mov    $0x0,%esi
  8002b8:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002cb:	5b                   	pop    %ebx
  8002cc:	5e                   	pop    %esi
  8002cd:	5f                   	pop    %edi
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    

008002d0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
  8002d6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002de:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e6:	89 cb                	mov    %ecx,%ebx
  8002e8:	89 cf                	mov    %ecx,%edi
  8002ea:	89 ce                	mov    %ecx,%esi
  8002ec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ee:	85 c0                	test   %eax,%eax
  8002f0:	7e 17                	jle    800309 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f2:	83 ec 0c             	sub    $0xc,%esp
  8002f5:	50                   	push   %eax
  8002f6:	6a 0c                	push   $0xc
  8002f8:	68 78 0f 80 00       	push   $0x800f78
  8002fd:	6a 23                	push   $0x23
  8002ff:	68 95 0f 80 00       	push   $0x800f95
  800304:	e8 08 00 00 00       	call   800311 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800309:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030c:	5b                   	pop    %ebx
  80030d:	5e                   	pop    %esi
  80030e:	5f                   	pop    %edi
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    

00800311 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	56                   	push   %esi
  800315:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800316:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800319:	8b 35 04 20 80 00    	mov    0x802004,%esi
  80031f:	e8 00 fe ff ff       	call   800124 <sys_getenvid>
  800324:	83 ec 0c             	sub    $0xc,%esp
  800327:	ff 75 0c             	pushl  0xc(%ebp)
  80032a:	ff 75 08             	pushl  0x8(%ebp)
  80032d:	56                   	push   %esi
  80032e:	50                   	push   %eax
  80032f:	68 a4 0f 80 00       	push   $0x800fa4
  800334:	e8 b1 00 00 00       	call   8003ea <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800339:	83 c4 18             	add    $0x18,%esp
  80033c:	53                   	push   %ebx
  80033d:	ff 75 10             	pushl  0x10(%ebp)
  800340:	e8 54 00 00 00       	call   800399 <vcprintf>
	cprintf("\n");
  800345:	c7 04 24 6c 0f 80 00 	movl   $0x800f6c,(%esp)
  80034c:	e8 99 00 00 00       	call   8003ea <cprintf>
  800351:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800354:	cc                   	int3   
  800355:	eb fd                	jmp    800354 <_panic+0x43>

00800357 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	53                   	push   %ebx
  80035b:	83 ec 04             	sub    $0x4,%esp
  80035e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800361:	8b 13                	mov    (%ebx),%edx
  800363:	8d 42 01             	lea    0x1(%edx),%eax
  800366:	89 03                	mov    %eax,(%ebx)
  800368:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80036f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800374:	75 1a                	jne    800390 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800376:	83 ec 08             	sub    $0x8,%esp
  800379:	68 ff 00 00 00       	push   $0xff
  80037e:	8d 43 08             	lea    0x8(%ebx),%eax
  800381:	50                   	push   %eax
  800382:	e8 1f fd ff ff       	call   8000a6 <sys_cputs>
		b->idx = 0;
  800387:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80038d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800390:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800394:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800397:	c9                   	leave  
  800398:	c3                   	ret    

00800399 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003a9:	00 00 00 
	b.cnt = 0;
  8003ac:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b6:	ff 75 0c             	pushl  0xc(%ebp)
  8003b9:	ff 75 08             	pushl  0x8(%ebp)
  8003bc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c2:	50                   	push   %eax
  8003c3:	68 57 03 80 00       	push   $0x800357
  8003c8:	e8 54 01 00 00       	call   800521 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003cd:	83 c4 08             	add    $0x8,%esp
  8003d0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003dc:	50                   	push   %eax
  8003dd:	e8 c4 fc ff ff       	call   8000a6 <sys_cputs>

	return b.cnt;
}
  8003e2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e8:	c9                   	leave  
  8003e9:	c3                   	ret    

008003ea <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003ea:	55                   	push   %ebp
  8003eb:	89 e5                	mov    %esp,%ebp
  8003ed:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f3:	50                   	push   %eax
  8003f4:	ff 75 08             	pushl  0x8(%ebp)
  8003f7:	e8 9d ff ff ff       	call   800399 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	57                   	push   %edi
  800402:	56                   	push   %esi
  800403:	53                   	push   %ebx
  800404:	83 ec 1c             	sub    $0x1c,%esp
  800407:	89 c7                	mov    %eax,%edi
  800409:	89 d6                	mov    %edx,%esi
  80040b:	8b 45 08             	mov    0x8(%ebp),%eax
  80040e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800411:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800414:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800417:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80041a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80041f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800422:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800425:	39 d3                	cmp    %edx,%ebx
  800427:	72 05                	jb     80042e <printnum+0x30>
  800429:	39 45 10             	cmp    %eax,0x10(%ebp)
  80042c:	77 45                	ja     800473 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042e:	83 ec 0c             	sub    $0xc,%esp
  800431:	ff 75 18             	pushl  0x18(%ebp)
  800434:	8b 45 14             	mov    0x14(%ebp),%eax
  800437:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80043a:	53                   	push   %ebx
  80043b:	ff 75 10             	pushl  0x10(%ebp)
  80043e:	83 ec 08             	sub    $0x8,%esp
  800441:	ff 75 e4             	pushl  -0x1c(%ebp)
  800444:	ff 75 e0             	pushl  -0x20(%ebp)
  800447:	ff 75 dc             	pushl  -0x24(%ebp)
  80044a:	ff 75 d8             	pushl  -0x28(%ebp)
  80044d:	e8 7e 08 00 00       	call   800cd0 <__udivdi3>
  800452:	83 c4 18             	add    $0x18,%esp
  800455:	52                   	push   %edx
  800456:	50                   	push   %eax
  800457:	89 f2                	mov    %esi,%edx
  800459:	89 f8                	mov    %edi,%eax
  80045b:	e8 9e ff ff ff       	call   8003fe <printnum>
  800460:	83 c4 20             	add    $0x20,%esp
  800463:	eb 18                	jmp    80047d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800465:	83 ec 08             	sub    $0x8,%esp
  800468:	56                   	push   %esi
  800469:	ff 75 18             	pushl  0x18(%ebp)
  80046c:	ff d7                	call   *%edi
  80046e:	83 c4 10             	add    $0x10,%esp
  800471:	eb 03                	jmp    800476 <printnum+0x78>
  800473:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800476:	83 eb 01             	sub    $0x1,%ebx
  800479:	85 db                	test   %ebx,%ebx
  80047b:	7f e8                	jg     800465 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047d:	83 ec 08             	sub    $0x8,%esp
  800480:	56                   	push   %esi
  800481:	83 ec 04             	sub    $0x4,%esp
  800484:	ff 75 e4             	pushl  -0x1c(%ebp)
  800487:	ff 75 e0             	pushl  -0x20(%ebp)
  80048a:	ff 75 dc             	pushl  -0x24(%ebp)
  80048d:	ff 75 d8             	pushl  -0x28(%ebp)
  800490:	e8 6b 09 00 00       	call   800e00 <__umoddi3>
  800495:	83 c4 14             	add    $0x14,%esp
  800498:	0f be 80 c8 0f 80 00 	movsbl 0x800fc8(%eax),%eax
  80049f:	50                   	push   %eax
  8004a0:	ff d7                	call   *%edi
}
  8004a2:	83 c4 10             	add    $0x10,%esp
  8004a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a8:	5b                   	pop    %ebx
  8004a9:	5e                   	pop    %esi
  8004aa:	5f                   	pop    %edi
  8004ab:	5d                   	pop    %ebp
  8004ac:	c3                   	ret    

008004ad <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004ad:	55                   	push   %ebp
  8004ae:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004b0:	83 fa 01             	cmp    $0x1,%edx
  8004b3:	7e 0e                	jle    8004c3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004b5:	8b 10                	mov    (%eax),%edx
  8004b7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004ba:	89 08                	mov    %ecx,(%eax)
  8004bc:	8b 02                	mov    (%edx),%eax
  8004be:	8b 52 04             	mov    0x4(%edx),%edx
  8004c1:	eb 22                	jmp    8004e5 <getuint+0x38>
	else if (lflag)
  8004c3:	85 d2                	test   %edx,%edx
  8004c5:	74 10                	je     8004d7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004c7:	8b 10                	mov    (%eax),%edx
  8004c9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004cc:	89 08                	mov    %ecx,(%eax)
  8004ce:	8b 02                	mov    (%edx),%eax
  8004d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d5:	eb 0e                	jmp    8004e5 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004d7:	8b 10                	mov    (%eax),%edx
  8004d9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004dc:	89 08                	mov    %ecx,(%eax)
  8004de:	8b 02                	mov    (%edx),%eax
  8004e0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004e5:	5d                   	pop    %ebp
  8004e6:	c3                   	ret    

008004e7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e7:	55                   	push   %ebp
  8004e8:	89 e5                	mov    %esp,%ebp
  8004ea:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ed:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004f1:	8b 10                	mov    (%eax),%edx
  8004f3:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f6:	73 0a                	jae    800502 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004fb:	89 08                	mov    %ecx,(%eax)
  8004fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800500:	88 02                	mov    %al,(%edx)
}
  800502:	5d                   	pop    %ebp
  800503:	c3                   	ret    

00800504 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800504:	55                   	push   %ebp
  800505:	89 e5                	mov    %esp,%ebp
  800507:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80050a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80050d:	50                   	push   %eax
  80050e:	ff 75 10             	pushl  0x10(%ebp)
  800511:	ff 75 0c             	pushl  0xc(%ebp)
  800514:	ff 75 08             	pushl  0x8(%ebp)
  800517:	e8 05 00 00 00       	call   800521 <vprintfmt>
	va_end(ap);
}
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	c9                   	leave  
  800520:	c3                   	ret    

00800521 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800521:	55                   	push   %ebp
  800522:	89 e5                	mov    %esp,%ebp
  800524:	57                   	push   %edi
  800525:	56                   	push   %esi
  800526:	53                   	push   %ebx
  800527:	83 ec 2c             	sub    $0x2c,%esp
  80052a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
  80052d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800534:	eb 17                	jmp    80054d <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800536:	85 c0                	test   %eax,%eax
  800538:	0f 84 9f 03 00 00    	je     8008dd <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	ff 75 0c             	pushl  0xc(%ebp)
  800544:	50                   	push   %eax
  800545:	ff 55 08             	call   *0x8(%ebp)
  800548:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80054b:	89 f3                	mov    %esi,%ebx
  80054d:	8d 73 01             	lea    0x1(%ebx),%esi
  800550:	0f b6 03             	movzbl (%ebx),%eax
  800553:	83 f8 25             	cmp    $0x25,%eax
  800556:	75 de                	jne    800536 <vprintfmt+0x15>
  800558:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80055c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800563:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800568:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80056f:	ba 00 00 00 00       	mov    $0x0,%edx
  800574:	eb 06                	jmp    80057c <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800576:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800578:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057c:	8d 5e 01             	lea    0x1(%esi),%ebx
  80057f:	0f b6 06             	movzbl (%esi),%eax
  800582:	0f b6 c8             	movzbl %al,%ecx
  800585:	83 e8 23             	sub    $0x23,%eax
  800588:	3c 55                	cmp    $0x55,%al
  80058a:	0f 87 2d 03 00 00    	ja     8008bd <vprintfmt+0x39c>
  800590:	0f b6 c0             	movzbl %al,%eax
  800593:	ff 24 85 80 10 80 00 	jmp    *0x801080(,%eax,4)
  80059a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80059c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8005a0:	eb da                	jmp    80057c <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a2:	89 de                	mov    %ebx,%esi
  8005a4:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005a9:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  8005ac:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  8005b0:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  8005b3:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8005b6:	83 f8 09             	cmp    $0x9,%eax
  8005b9:	77 33                	ja     8005ee <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005bb:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005be:	eb e9                	jmp    8005a9 <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8d 48 04             	lea    0x4(%eax),%ecx
  8005c6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005c9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cb:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005cd:	eb 1f                	jmp    8005ee <vprintfmt+0xcd>
  8005cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005d2:	85 c0                	test   %eax,%eax
  8005d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d9:	0f 49 c8             	cmovns %eax,%ecx
  8005dc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005df:	89 de                	mov    %ebx,%esi
  8005e1:	eb 99                	jmp    80057c <vprintfmt+0x5b>
  8005e3:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005e5:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  8005ec:	eb 8e                	jmp    80057c <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8005ee:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005f2:	79 88                	jns    80057c <vprintfmt+0x5b>
				width = precision, precision = -1;
  8005f4:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8005f7:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8005fc:	e9 7b ff ff ff       	jmp    80057c <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800601:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800604:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800606:	e9 71 ff ff ff       	jmp    80057c <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8d 50 04             	lea    0x4(%eax),%edx
  800611:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	ff 75 0c             	pushl  0xc(%ebp)
  80061a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80061d:	03 08                	add    (%eax),%ecx
  80061f:	51                   	push   %ecx
  800620:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
  800623:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
  800626:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
  80062d:	e9 1b ff ff ff       	jmp    80054d <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8d 48 04             	lea    0x4(%eax),%ecx
  800638:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80063b:	8b 00                	mov    (%eax),%eax
  80063d:	83 f8 02             	cmp    $0x2,%eax
  800640:	74 1a                	je     80065c <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800642:	89 de                	mov    %ebx,%esi
  800644:	83 f8 04             	cmp    $0x4,%eax
  800647:	b8 00 00 00 00       	mov    $0x0,%eax
  80064c:	b9 00 04 00 00       	mov    $0x400,%ecx
  800651:	0f 44 c1             	cmove  %ecx,%eax
  800654:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800657:	e9 20 ff ff ff       	jmp    80057c <vprintfmt+0x5b>
  80065c:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
  80065e:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
  800665:	e9 12 ff ff ff       	jmp    80057c <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8d 50 04             	lea    0x4(%eax),%edx
  800670:	89 55 14             	mov    %edx,0x14(%ebp)
  800673:	8b 00                	mov    (%eax),%eax
  800675:	99                   	cltd   
  800676:	31 d0                	xor    %edx,%eax
  800678:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80067a:	83 f8 09             	cmp    $0x9,%eax
  80067d:	7f 0b                	jg     80068a <vprintfmt+0x169>
  80067f:	8b 14 85 e0 11 80 00 	mov    0x8011e0(,%eax,4),%edx
  800686:	85 d2                	test   %edx,%edx
  800688:	75 19                	jne    8006a3 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  80068a:	50                   	push   %eax
  80068b:	68 e0 0f 80 00       	push   $0x800fe0
  800690:	ff 75 0c             	pushl  0xc(%ebp)
  800693:	ff 75 08             	pushl  0x8(%ebp)
  800696:	e8 69 fe ff ff       	call   800504 <printfmt>
  80069b:	83 c4 10             	add    $0x10,%esp
  80069e:	e9 aa fe ff ff       	jmp    80054d <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  8006a3:	52                   	push   %edx
  8006a4:	68 e9 0f 80 00       	push   $0x800fe9
  8006a9:	ff 75 0c             	pushl  0xc(%ebp)
  8006ac:	ff 75 08             	pushl  0x8(%ebp)
  8006af:	e8 50 fe ff ff       	call   800504 <printfmt>
  8006b4:	83 c4 10             	add    $0x10,%esp
  8006b7:	e9 91 fe ff ff       	jmp    80054d <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bf:	8d 50 04             	lea    0x4(%eax),%edx
  8006c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c5:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006c7:	85 f6                	test   %esi,%esi
  8006c9:	b8 d9 0f 80 00       	mov    $0x800fd9,%eax
  8006ce:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006d5:	0f 8e 93 00 00 00    	jle    80076e <vprintfmt+0x24d>
  8006db:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8006df:	0f 84 91 00 00 00    	je     800776 <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e5:	83 ec 08             	sub    $0x8,%esp
  8006e8:	57                   	push   %edi
  8006e9:	56                   	push   %esi
  8006ea:	e8 76 02 00 00       	call   800965 <strnlen>
  8006ef:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006f2:	29 c1                	sub    %eax,%ecx
  8006f4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006f7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006fa:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8006fe:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800701:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800704:	8b 75 0c             	mov    0xc(%ebp),%esi
  800707:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80070a:	89 cb                	mov    %ecx,%ebx
  80070c:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80070e:	eb 0e                	jmp    80071e <vprintfmt+0x1fd>
					putch(padc, putdat);
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	56                   	push   %esi
  800714:	57                   	push   %edi
  800715:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800718:	83 eb 01             	sub    $0x1,%ebx
  80071b:	83 c4 10             	add    $0x10,%esp
  80071e:	85 db                	test   %ebx,%ebx
  800720:	7f ee                	jg     800710 <vprintfmt+0x1ef>
  800722:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800725:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800728:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80072b:	85 c9                	test   %ecx,%ecx
  80072d:	b8 00 00 00 00       	mov    $0x0,%eax
  800732:	0f 49 c1             	cmovns %ecx,%eax
  800735:	29 c1                	sub    %eax,%ecx
  800737:	89 cb                	mov    %ecx,%ebx
  800739:	eb 41                	jmp    80077c <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80073b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80073f:	74 1b                	je     80075c <vprintfmt+0x23b>
  800741:	0f be c0             	movsbl %al,%eax
  800744:	83 e8 20             	sub    $0x20,%eax
  800747:	83 f8 5e             	cmp    $0x5e,%eax
  80074a:	76 10                	jbe    80075c <vprintfmt+0x23b>
					putch('?', putdat);
  80074c:	83 ec 08             	sub    $0x8,%esp
  80074f:	ff 75 0c             	pushl  0xc(%ebp)
  800752:	6a 3f                	push   $0x3f
  800754:	ff 55 08             	call   *0x8(%ebp)
  800757:	83 c4 10             	add    $0x10,%esp
  80075a:	eb 0d                	jmp    800769 <vprintfmt+0x248>
				else
					putch(ch, putdat);
  80075c:	83 ec 08             	sub    $0x8,%esp
  80075f:	ff 75 0c             	pushl  0xc(%ebp)
  800762:	52                   	push   %edx
  800763:	ff 55 08             	call   *0x8(%ebp)
  800766:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800769:	83 eb 01             	sub    $0x1,%ebx
  80076c:	eb 0e                	jmp    80077c <vprintfmt+0x25b>
  80076e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800771:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800774:	eb 06                	jmp    80077c <vprintfmt+0x25b>
  800776:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800779:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80077c:	83 c6 01             	add    $0x1,%esi
  80077f:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800783:	0f be d0             	movsbl %al,%edx
  800786:	85 d2                	test   %edx,%edx
  800788:	74 25                	je     8007af <vprintfmt+0x28e>
  80078a:	85 ff                	test   %edi,%edi
  80078c:	78 ad                	js     80073b <vprintfmt+0x21a>
  80078e:	83 ef 01             	sub    $0x1,%edi
  800791:	79 a8                	jns    80073b <vprintfmt+0x21a>
  800793:	89 d8                	mov    %ebx,%eax
  800795:	8b 75 08             	mov    0x8(%ebp),%esi
  800798:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80079b:	89 c3                	mov    %eax,%ebx
  80079d:	eb 16                	jmp    8007b5 <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80079f:	83 ec 08             	sub    $0x8,%esp
  8007a2:	57                   	push   %edi
  8007a3:	6a 20                	push   $0x20
  8007a5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007a7:	83 eb 01             	sub    $0x1,%ebx
  8007aa:	83 c4 10             	add    $0x10,%esp
  8007ad:	eb 06                	jmp    8007b5 <vprintfmt+0x294>
  8007af:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8007b5:	85 db                	test   %ebx,%ebx
  8007b7:	7f e6                	jg     80079f <vprintfmt+0x27e>
  8007b9:	89 75 08             	mov    %esi,0x8(%ebp)
  8007bc:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8007bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007c2:	e9 86 fd ff ff       	jmp    80054d <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007c7:	83 fa 01             	cmp    $0x1,%edx
  8007ca:	7e 10                	jle    8007dc <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
  8007cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cf:	8d 50 08             	lea    0x8(%eax),%edx
  8007d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d5:	8b 30                	mov    (%eax),%esi
  8007d7:	8b 78 04             	mov    0x4(%eax),%edi
  8007da:	eb 26                	jmp    800802 <vprintfmt+0x2e1>
	else if (lflag)
  8007dc:	85 d2                	test   %edx,%edx
  8007de:	74 12                	je     8007f2 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  8007e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e3:	8d 50 04             	lea    0x4(%eax),%edx
  8007e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e9:	8b 30                	mov    (%eax),%esi
  8007eb:	89 f7                	mov    %esi,%edi
  8007ed:	c1 ff 1f             	sar    $0x1f,%edi
  8007f0:	eb 10                	jmp    800802 <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
  8007f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f5:	8d 50 04             	lea    0x4(%eax),%edx
  8007f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fb:	8b 30                	mov    (%eax),%esi
  8007fd:	89 f7                	mov    %esi,%edi
  8007ff:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800802:	89 f0                	mov    %esi,%eax
  800804:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800806:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80080b:	85 ff                	test   %edi,%edi
  80080d:	79 7b                	jns    80088a <vprintfmt+0x369>
				putch('-', putdat);
  80080f:	83 ec 08             	sub    $0x8,%esp
  800812:	ff 75 0c             	pushl  0xc(%ebp)
  800815:	6a 2d                	push   $0x2d
  800817:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80081a:	89 f0                	mov    %esi,%eax
  80081c:	89 fa                	mov    %edi,%edx
  80081e:	f7 d8                	neg    %eax
  800820:	83 d2 00             	adc    $0x0,%edx
  800823:	f7 da                	neg    %edx
  800825:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800828:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80082d:	eb 5b                	jmp    80088a <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80082f:	8d 45 14             	lea    0x14(%ebp),%eax
  800832:	e8 76 fc ff ff       	call   8004ad <getuint>
			base = 10;
  800837:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80083c:	eb 4c                	jmp    80088a <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
  80083e:	8d 45 14             	lea    0x14(%ebp),%eax
  800841:	e8 67 fc ff ff       	call   8004ad <getuint>
            base = 8;
  800846:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80084b:	eb 3d                	jmp    80088a <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
  80084d:	83 ec 08             	sub    $0x8,%esp
  800850:	ff 75 0c             	pushl  0xc(%ebp)
  800853:	6a 30                	push   $0x30
  800855:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800858:	83 c4 08             	add    $0x8,%esp
  80085b:	ff 75 0c             	pushl  0xc(%ebp)
  80085e:	6a 78                	push   $0x78
  800860:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800863:	8b 45 14             	mov    0x14(%ebp),%eax
  800866:	8d 50 04             	lea    0x4(%eax),%edx
  800869:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80086c:	8b 00                	mov    (%eax),%eax
  80086e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800873:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800876:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80087b:	eb 0d                	jmp    80088a <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80087d:	8d 45 14             	lea    0x14(%ebp),%eax
  800880:	e8 28 fc ff ff       	call   8004ad <getuint>
			base = 16;
  800885:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80088a:	83 ec 0c             	sub    $0xc,%esp
  80088d:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  800891:	56                   	push   %esi
  800892:	ff 75 e0             	pushl  -0x20(%ebp)
  800895:	51                   	push   %ecx
  800896:	52                   	push   %edx
  800897:	50                   	push   %eax
  800898:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	e8 5b fb ff ff       	call   8003fe <printnum>
			break;
  8008a3:	83 c4 20             	add    $0x20,%esp
  8008a6:	e9 a2 fc ff ff       	jmp    80054d <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008ab:	83 ec 08             	sub    $0x8,%esp
  8008ae:	ff 75 0c             	pushl  0xc(%ebp)
  8008b1:	51                   	push   %ecx
  8008b2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008b5:	83 c4 10             	add    $0x10,%esp
  8008b8:	e9 90 fc ff ff       	jmp    80054d <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008bd:	83 ec 08             	sub    $0x8,%esp
  8008c0:	ff 75 0c             	pushl  0xc(%ebp)
  8008c3:	6a 25                	push   $0x25
  8008c5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008c8:	83 c4 10             	add    $0x10,%esp
  8008cb:	89 f3                	mov    %esi,%ebx
  8008cd:	eb 03                	jmp    8008d2 <vprintfmt+0x3b1>
  8008cf:	83 eb 01             	sub    $0x1,%ebx
  8008d2:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8008d6:	75 f7                	jne    8008cf <vprintfmt+0x3ae>
  8008d8:	e9 70 fc ff ff       	jmp    80054d <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  8008dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008e0:	5b                   	pop    %ebx
  8008e1:	5e                   	pop    %esi
  8008e2:	5f                   	pop    %edi
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	83 ec 18             	sub    $0x18,%esp
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008f4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008f8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800902:	85 c0                	test   %eax,%eax
  800904:	74 26                	je     80092c <vsnprintf+0x47>
  800906:	85 d2                	test   %edx,%edx
  800908:	7e 22                	jle    80092c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80090a:	ff 75 14             	pushl  0x14(%ebp)
  80090d:	ff 75 10             	pushl  0x10(%ebp)
  800910:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800913:	50                   	push   %eax
  800914:	68 e7 04 80 00       	push   $0x8004e7
  800919:	e8 03 fc ff ff       	call   800521 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80091e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800921:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800924:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800927:	83 c4 10             	add    $0x10,%esp
  80092a:	eb 05                	jmp    800931 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80092c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800931:	c9                   	leave  
  800932:	c3                   	ret    

00800933 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800939:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80093c:	50                   	push   %eax
  80093d:	ff 75 10             	pushl  0x10(%ebp)
  800940:	ff 75 0c             	pushl  0xc(%ebp)
  800943:	ff 75 08             	pushl  0x8(%ebp)
  800946:	e8 9a ff ff ff       	call   8008e5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80094b:	c9                   	leave  
  80094c:	c3                   	ret    

0080094d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800953:	b8 00 00 00 00       	mov    $0x0,%eax
  800958:	eb 03                	jmp    80095d <strlen+0x10>
		n++;
  80095a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80095d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800961:	75 f7                	jne    80095a <strlen+0xd>
		n++;
	return n;
}
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80096e:	ba 00 00 00 00       	mov    $0x0,%edx
  800973:	eb 03                	jmp    800978 <strnlen+0x13>
		n++;
  800975:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800978:	39 c2                	cmp    %eax,%edx
  80097a:	74 08                	je     800984 <strnlen+0x1f>
  80097c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800980:	75 f3                	jne    800975 <strnlen+0x10>
  800982:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	53                   	push   %ebx
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800990:	89 c2                	mov    %eax,%edx
  800992:	83 c2 01             	add    $0x1,%edx
  800995:	83 c1 01             	add    $0x1,%ecx
  800998:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80099c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80099f:	84 db                	test   %bl,%bl
  8009a1:	75 ef                	jne    800992 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009a3:	5b                   	pop    %ebx
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	53                   	push   %ebx
  8009aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009ad:	53                   	push   %ebx
  8009ae:	e8 9a ff ff ff       	call   80094d <strlen>
  8009b3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009b6:	ff 75 0c             	pushl  0xc(%ebp)
  8009b9:	01 d8                	add    %ebx,%eax
  8009bb:	50                   	push   %eax
  8009bc:	e8 c5 ff ff ff       	call   800986 <strcpy>
	return dst;
}
  8009c1:	89 d8                	mov    %ebx,%eax
  8009c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c6:	c9                   	leave  
  8009c7:	c3                   	ret    

008009c8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	56                   	push   %esi
  8009cc:	53                   	push   %ebx
  8009cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8009d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009d3:	89 f3                	mov    %esi,%ebx
  8009d5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d8:	89 f2                	mov    %esi,%edx
  8009da:	eb 0f                	jmp    8009eb <strncpy+0x23>
		*dst++ = *src;
  8009dc:	83 c2 01             	add    $0x1,%edx
  8009df:	0f b6 01             	movzbl (%ecx),%eax
  8009e2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009e5:	80 39 01             	cmpb   $0x1,(%ecx)
  8009e8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009eb:	39 da                	cmp    %ebx,%edx
  8009ed:	75 ed                	jne    8009dc <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009ef:	89 f0                	mov    %esi,%eax
  8009f1:	5b                   	pop    %ebx
  8009f2:	5e                   	pop    %esi
  8009f3:	5d                   	pop    %ebp
  8009f4:	c3                   	ret    

008009f5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	56                   	push   %esi
  8009f9:	53                   	push   %ebx
  8009fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8009fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a00:	8b 55 10             	mov    0x10(%ebp),%edx
  800a03:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a05:	85 d2                	test   %edx,%edx
  800a07:	74 21                	je     800a2a <strlcpy+0x35>
  800a09:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a0d:	89 f2                	mov    %esi,%edx
  800a0f:	eb 09                	jmp    800a1a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a11:	83 c2 01             	add    $0x1,%edx
  800a14:	83 c1 01             	add    $0x1,%ecx
  800a17:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a1a:	39 c2                	cmp    %eax,%edx
  800a1c:	74 09                	je     800a27 <strlcpy+0x32>
  800a1e:	0f b6 19             	movzbl (%ecx),%ebx
  800a21:	84 db                	test   %bl,%bl
  800a23:	75 ec                	jne    800a11 <strlcpy+0x1c>
  800a25:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a27:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a2a:	29 f0                	sub    %esi,%eax
}
  800a2c:	5b                   	pop    %ebx
  800a2d:	5e                   	pop    %esi
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a36:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a39:	eb 06                	jmp    800a41 <strcmp+0x11>
		p++, q++;
  800a3b:	83 c1 01             	add    $0x1,%ecx
  800a3e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a41:	0f b6 01             	movzbl (%ecx),%eax
  800a44:	84 c0                	test   %al,%al
  800a46:	74 04                	je     800a4c <strcmp+0x1c>
  800a48:	3a 02                	cmp    (%edx),%al
  800a4a:	74 ef                	je     800a3b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a4c:	0f b6 c0             	movzbl %al,%eax
  800a4f:	0f b6 12             	movzbl (%edx),%edx
  800a52:	29 d0                	sub    %edx,%eax
}
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	53                   	push   %ebx
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a60:	89 c3                	mov    %eax,%ebx
  800a62:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a65:	eb 06                	jmp    800a6d <strncmp+0x17>
		n--, p++, q++;
  800a67:	83 c0 01             	add    $0x1,%eax
  800a6a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a6d:	39 d8                	cmp    %ebx,%eax
  800a6f:	74 15                	je     800a86 <strncmp+0x30>
  800a71:	0f b6 08             	movzbl (%eax),%ecx
  800a74:	84 c9                	test   %cl,%cl
  800a76:	74 04                	je     800a7c <strncmp+0x26>
  800a78:	3a 0a                	cmp    (%edx),%cl
  800a7a:	74 eb                	je     800a67 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a7c:	0f b6 00             	movzbl (%eax),%eax
  800a7f:	0f b6 12             	movzbl (%edx),%edx
  800a82:	29 d0                	sub    %edx,%eax
  800a84:	eb 05                	jmp    800a8b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a86:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a8b:	5b                   	pop    %ebx
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    

00800a8e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	8b 45 08             	mov    0x8(%ebp),%eax
  800a94:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a98:	eb 07                	jmp    800aa1 <strchr+0x13>
		if (*s == c)
  800a9a:	38 ca                	cmp    %cl,%dl
  800a9c:	74 0f                	je     800aad <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a9e:	83 c0 01             	add    $0x1,%eax
  800aa1:	0f b6 10             	movzbl (%eax),%edx
  800aa4:	84 d2                	test   %dl,%dl
  800aa6:	75 f2                	jne    800a9a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800aa8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aad:	5d                   	pop    %ebp
  800aae:	c3                   	ret    

00800aaf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab9:	eb 03                	jmp    800abe <strfind+0xf>
  800abb:	83 c0 01             	add    $0x1,%eax
  800abe:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ac1:	38 ca                	cmp    %cl,%dl
  800ac3:	74 04                	je     800ac9 <strfind+0x1a>
  800ac5:	84 d2                	test   %dl,%dl
  800ac7:	75 f2                	jne    800abb <strfind+0xc>
			break;
	return (char *) s;
}
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	57                   	push   %edi
  800acf:	56                   	push   %esi
  800ad0:	53                   	push   %ebx
  800ad1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ad4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ad7:	85 c9                	test   %ecx,%ecx
  800ad9:	74 36                	je     800b11 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800adb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ae1:	75 28                	jne    800b0b <memset+0x40>
  800ae3:	f6 c1 03             	test   $0x3,%cl
  800ae6:	75 23                	jne    800b0b <memset+0x40>
		c &= 0xFF;
  800ae8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aec:	89 d3                	mov    %edx,%ebx
  800aee:	c1 e3 08             	shl    $0x8,%ebx
  800af1:	89 d6                	mov    %edx,%esi
  800af3:	c1 e6 18             	shl    $0x18,%esi
  800af6:	89 d0                	mov    %edx,%eax
  800af8:	c1 e0 10             	shl    $0x10,%eax
  800afb:	09 f0                	or     %esi,%eax
  800afd:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800aff:	89 d8                	mov    %ebx,%eax
  800b01:	09 d0                	or     %edx,%eax
  800b03:	c1 e9 02             	shr    $0x2,%ecx
  800b06:	fc                   	cld    
  800b07:	f3 ab                	rep stos %eax,%es:(%edi)
  800b09:	eb 06                	jmp    800b11 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0e:	fc                   	cld    
  800b0f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b11:	89 f8                	mov    %edi,%eax
  800b13:	5b                   	pop    %ebx
  800b14:	5e                   	pop    %esi
  800b15:	5f                   	pop    %edi
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	57                   	push   %edi
  800b1c:	56                   	push   %esi
  800b1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b20:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b23:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b26:	39 c6                	cmp    %eax,%esi
  800b28:	73 35                	jae    800b5f <memmove+0x47>
  800b2a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b2d:	39 d0                	cmp    %edx,%eax
  800b2f:	73 2e                	jae    800b5f <memmove+0x47>
		s += n;
		d += n;
  800b31:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b34:	89 d6                	mov    %edx,%esi
  800b36:	09 fe                	or     %edi,%esi
  800b38:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b3e:	75 13                	jne    800b53 <memmove+0x3b>
  800b40:	f6 c1 03             	test   $0x3,%cl
  800b43:	75 0e                	jne    800b53 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b45:	83 ef 04             	sub    $0x4,%edi
  800b48:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b4b:	c1 e9 02             	shr    $0x2,%ecx
  800b4e:	fd                   	std    
  800b4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b51:	eb 09                	jmp    800b5c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b53:	83 ef 01             	sub    $0x1,%edi
  800b56:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b59:	fd                   	std    
  800b5a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b5c:	fc                   	cld    
  800b5d:	eb 1d                	jmp    800b7c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b5f:	89 f2                	mov    %esi,%edx
  800b61:	09 c2                	or     %eax,%edx
  800b63:	f6 c2 03             	test   $0x3,%dl
  800b66:	75 0f                	jne    800b77 <memmove+0x5f>
  800b68:	f6 c1 03             	test   $0x3,%cl
  800b6b:	75 0a                	jne    800b77 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b6d:	c1 e9 02             	shr    $0x2,%ecx
  800b70:	89 c7                	mov    %eax,%edi
  800b72:	fc                   	cld    
  800b73:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b75:	eb 05                	jmp    800b7c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b77:	89 c7                	mov    %eax,%edi
  800b79:	fc                   	cld    
  800b7a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b83:	ff 75 10             	pushl  0x10(%ebp)
  800b86:	ff 75 0c             	pushl  0xc(%ebp)
  800b89:	ff 75 08             	pushl  0x8(%ebp)
  800b8c:	e8 87 ff ff ff       	call   800b18 <memmove>
}
  800b91:	c9                   	leave  
  800b92:	c3                   	ret    

00800b93 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	56                   	push   %esi
  800b97:	53                   	push   %ebx
  800b98:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b9e:	89 c6                	mov    %eax,%esi
  800ba0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba3:	eb 1a                	jmp    800bbf <memcmp+0x2c>
		if (*s1 != *s2)
  800ba5:	0f b6 08             	movzbl (%eax),%ecx
  800ba8:	0f b6 1a             	movzbl (%edx),%ebx
  800bab:	38 d9                	cmp    %bl,%cl
  800bad:	74 0a                	je     800bb9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800baf:	0f b6 c1             	movzbl %cl,%eax
  800bb2:	0f b6 db             	movzbl %bl,%ebx
  800bb5:	29 d8                	sub    %ebx,%eax
  800bb7:	eb 0f                	jmp    800bc8 <memcmp+0x35>
		s1++, s2++;
  800bb9:	83 c0 01             	add    $0x1,%eax
  800bbc:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bbf:	39 f0                	cmp    %esi,%eax
  800bc1:	75 e2                	jne    800ba5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	53                   	push   %ebx
  800bd0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bd3:	89 c1                	mov    %eax,%ecx
  800bd5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bdc:	eb 0a                	jmp    800be8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bde:	0f b6 10             	movzbl (%eax),%edx
  800be1:	39 da                	cmp    %ebx,%edx
  800be3:	74 07                	je     800bec <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800be5:	83 c0 01             	add    $0x1,%eax
  800be8:	39 c8                	cmp    %ecx,%eax
  800bea:	72 f2                	jb     800bde <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bec:	5b                   	pop    %ebx
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	53                   	push   %ebx
  800bf5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bfb:	eb 03                	jmp    800c00 <strtol+0x11>
		s++;
  800bfd:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c00:	0f b6 01             	movzbl (%ecx),%eax
  800c03:	3c 20                	cmp    $0x20,%al
  800c05:	74 f6                	je     800bfd <strtol+0xe>
  800c07:	3c 09                	cmp    $0x9,%al
  800c09:	74 f2                	je     800bfd <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c0b:	3c 2b                	cmp    $0x2b,%al
  800c0d:	75 0a                	jne    800c19 <strtol+0x2a>
		s++;
  800c0f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c12:	bf 00 00 00 00       	mov    $0x0,%edi
  800c17:	eb 11                	jmp    800c2a <strtol+0x3b>
  800c19:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c1e:	3c 2d                	cmp    $0x2d,%al
  800c20:	75 08                	jne    800c2a <strtol+0x3b>
		s++, neg = 1;
  800c22:	83 c1 01             	add    $0x1,%ecx
  800c25:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c2a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c30:	75 15                	jne    800c47 <strtol+0x58>
  800c32:	80 39 30             	cmpb   $0x30,(%ecx)
  800c35:	75 10                	jne    800c47 <strtol+0x58>
  800c37:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c3b:	75 7c                	jne    800cb9 <strtol+0xca>
		s += 2, base = 16;
  800c3d:	83 c1 02             	add    $0x2,%ecx
  800c40:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c45:	eb 16                	jmp    800c5d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c47:	85 db                	test   %ebx,%ebx
  800c49:	75 12                	jne    800c5d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c4b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c50:	80 39 30             	cmpb   $0x30,(%ecx)
  800c53:	75 08                	jne    800c5d <strtol+0x6e>
		s++, base = 8;
  800c55:	83 c1 01             	add    $0x1,%ecx
  800c58:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c62:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c65:	0f b6 11             	movzbl (%ecx),%edx
  800c68:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c6b:	89 f3                	mov    %esi,%ebx
  800c6d:	80 fb 09             	cmp    $0x9,%bl
  800c70:	77 08                	ja     800c7a <strtol+0x8b>
			dig = *s - '0';
  800c72:	0f be d2             	movsbl %dl,%edx
  800c75:	83 ea 30             	sub    $0x30,%edx
  800c78:	eb 22                	jmp    800c9c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c7a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c7d:	89 f3                	mov    %esi,%ebx
  800c7f:	80 fb 19             	cmp    $0x19,%bl
  800c82:	77 08                	ja     800c8c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c84:	0f be d2             	movsbl %dl,%edx
  800c87:	83 ea 57             	sub    $0x57,%edx
  800c8a:	eb 10                	jmp    800c9c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c8c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c8f:	89 f3                	mov    %esi,%ebx
  800c91:	80 fb 19             	cmp    $0x19,%bl
  800c94:	77 16                	ja     800cac <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c96:	0f be d2             	movsbl %dl,%edx
  800c99:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c9c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c9f:	7d 0b                	jge    800cac <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ca1:	83 c1 01             	add    $0x1,%ecx
  800ca4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ca8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800caa:	eb b9                	jmp    800c65 <strtol+0x76>

	if (endptr)
  800cac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cb0:	74 0d                	je     800cbf <strtol+0xd0>
		*endptr = (char *) s;
  800cb2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cb5:	89 0e                	mov    %ecx,(%esi)
  800cb7:	eb 06                	jmp    800cbf <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cb9:	85 db                	test   %ebx,%ebx
  800cbb:	74 98                	je     800c55 <strtol+0x66>
  800cbd:	eb 9e                	jmp    800c5d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cbf:	89 c2                	mov    %eax,%edx
  800cc1:	f7 da                	neg    %edx
  800cc3:	85 ff                	test   %edi,%edi
  800cc5:	0f 45 c2             	cmovne %edx,%eax
}
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    
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
