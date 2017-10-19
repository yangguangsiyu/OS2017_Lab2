
obj/user/badsegment：     文件格式 elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
    asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds

    // Code below this is used for testing how to set segment correctly.
	//asm volatile("movw $0x20,%ax; movw %ax,%ds");
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800049:	e8 c6 00 00 00       	call   800114 <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x2d>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008a:	6a 00                	push   $0x0
  80008c:	e8 42 00 00 00       	call   8000d3 <sys_env_destroy>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	57                   	push   %edi
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009c:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a7:	89 c3                	mov    %eax,%ebx
  8000a9:	89 c7                	mov    %eax,%edi
  8000ab:	89 c6                	mov    %eax,%esi
  8000ad:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	5f                   	pop    %edi
  8000b2:	5d                   	pop    %ebp
  8000b3:	c3                   	ret    

008000b4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c4:	89 d1                	mov    %edx,%ecx
  8000c6:	89 d3                	mov    %edx,%ebx
  8000c8:	89 d7                	mov    %edx,%edi
  8000ca:	89 d6                	mov    %edx,%esi
  8000cc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5f                   	pop    %edi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e1:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e9:	89 cb                	mov    %ecx,%ebx
  8000eb:	89 cf                	mov    %ecx,%edi
  8000ed:	89 ce                	mov    %ecx,%esi
  8000ef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f1:	85 c0                	test   %eax,%eax
  8000f3:	7e 17                	jle    80010c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f5:	83 ec 0c             	sub    $0xc,%esp
  8000f8:	50                   	push   %eax
  8000f9:	6a 03                	push   $0x3
  8000fb:	68 6a 0f 80 00       	push   $0x800f6a
  800100:	6a 23                	push   $0x23
  800102:	68 87 0f 80 00       	push   $0x800f87
  800107:	e8 f5 01 00 00       	call   800301 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010f:	5b                   	pop    %ebx
  800110:	5e                   	pop    %esi
  800111:	5f                   	pop    %edi
  800112:	5d                   	pop    %ebp
  800113:	c3                   	ret    

00800114 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	57                   	push   %edi
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011a:	ba 00 00 00 00       	mov    $0x0,%edx
  80011f:	b8 02 00 00 00       	mov    $0x2,%eax
  800124:	89 d1                	mov    %edx,%ecx
  800126:	89 d3                	mov    %edx,%ebx
  800128:	89 d7                	mov    %edx,%edi
  80012a:	89 d6                	mov    %edx,%esi
  80012c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <sys_yield>:

void
sys_yield(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	57                   	push   %edi
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800139:	ba 00 00 00 00       	mov    $0x0,%edx
  80013e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800143:	89 d1                	mov    %edx,%ecx
  800145:	89 d3                	mov    %edx,%ebx
  800147:	89 d7                	mov    %edx,%edi
  800149:	89 d6                	mov    %edx,%esi
  80014b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80014d:	5b                   	pop    %ebx
  80014e:	5e                   	pop    %esi
  80014f:	5f                   	pop    %edi
  800150:	5d                   	pop    %ebp
  800151:	c3                   	ret    

00800152 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800152:	55                   	push   %ebp
  800153:	89 e5                	mov    %esp,%ebp
  800155:	57                   	push   %edi
  800156:	56                   	push   %esi
  800157:	53                   	push   %ebx
  800158:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015b:	be 00 00 00 00       	mov    $0x0,%esi
  800160:	b8 04 00 00 00       	mov    $0x4,%eax
  800165:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800168:	8b 55 08             	mov    0x8(%ebp),%edx
  80016b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80016e:	89 f7                	mov    %esi,%edi
  800170:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800172:	85 c0                	test   %eax,%eax
  800174:	7e 17                	jle    80018d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	50                   	push   %eax
  80017a:	6a 04                	push   $0x4
  80017c:	68 6a 0f 80 00       	push   $0x800f6a
  800181:	6a 23                	push   $0x23
  800183:	68 87 0f 80 00       	push   $0x800f87
  800188:	e8 74 01 00 00       	call   800301 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80018d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800190:	5b                   	pop    %ebx
  800191:	5e                   	pop    %esi
  800192:	5f                   	pop    %edi
  800193:	5d                   	pop    %ebp
  800194:	c3                   	ret    

00800195 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	57                   	push   %edi
  800199:	56                   	push   %esi
  80019a:	53                   	push   %ebx
  80019b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019e:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ac:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001af:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	7e 17                	jle    8001cf <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b8:	83 ec 0c             	sub    $0xc,%esp
  8001bb:	50                   	push   %eax
  8001bc:	6a 05                	push   $0x5
  8001be:	68 6a 0f 80 00       	push   $0x800f6a
  8001c3:	6a 23                	push   $0x23
  8001c5:	68 87 0f 80 00       	push   $0x800f87
  8001ca:	e8 32 01 00 00       	call   800301 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d2:	5b                   	pop    %ebx
  8001d3:	5e                   	pop    %esi
  8001d4:	5f                   	pop    %edi
  8001d5:	5d                   	pop    %ebp
  8001d6:	c3                   	ret    

008001d7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	57                   	push   %edi
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e5:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f0:	89 df                	mov    %ebx,%edi
  8001f2:	89 de                	mov    %ebx,%esi
  8001f4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f6:	85 c0                	test   %eax,%eax
  8001f8:	7e 17                	jle    800211 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fa:	83 ec 0c             	sub    $0xc,%esp
  8001fd:	50                   	push   %eax
  8001fe:	6a 06                	push   $0x6
  800200:	68 6a 0f 80 00       	push   $0x800f6a
  800205:	6a 23                	push   $0x23
  800207:	68 87 0f 80 00       	push   $0x800f87
  80020c:	e8 f0 00 00 00       	call   800301 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800211:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800214:	5b                   	pop    %ebx
  800215:	5e                   	pop    %esi
  800216:	5f                   	pop    %edi
  800217:	5d                   	pop    %ebp
  800218:	c3                   	ret    

00800219 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	57                   	push   %edi
  80021d:	56                   	push   %esi
  80021e:	53                   	push   %ebx
  80021f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800222:	bb 00 00 00 00       	mov    $0x0,%ebx
  800227:	b8 08 00 00 00       	mov    $0x8,%eax
  80022c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022f:	8b 55 08             	mov    0x8(%ebp),%edx
  800232:	89 df                	mov    %ebx,%edi
  800234:	89 de                	mov    %ebx,%esi
  800236:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800238:	85 c0                	test   %eax,%eax
  80023a:	7e 17                	jle    800253 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023c:	83 ec 0c             	sub    $0xc,%esp
  80023f:	50                   	push   %eax
  800240:	6a 08                	push   $0x8
  800242:	68 6a 0f 80 00       	push   $0x800f6a
  800247:	6a 23                	push   $0x23
  800249:	68 87 0f 80 00       	push   $0x800f87
  80024e:	e8 ae 00 00 00       	call   800301 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800253:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800256:	5b                   	pop    %ebx
  800257:	5e                   	pop    %esi
  800258:	5f                   	pop    %edi
  800259:	5d                   	pop    %ebp
  80025a:	c3                   	ret    

0080025b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	57                   	push   %edi
  80025f:	56                   	push   %esi
  800260:	53                   	push   %ebx
  800261:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800264:	bb 00 00 00 00       	mov    $0x0,%ebx
  800269:	b8 09 00 00 00       	mov    $0x9,%eax
  80026e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800271:	8b 55 08             	mov    0x8(%ebp),%edx
  800274:	89 df                	mov    %ebx,%edi
  800276:	89 de                	mov    %ebx,%esi
  800278:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80027a:	85 c0                	test   %eax,%eax
  80027c:	7e 17                	jle    800295 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	50                   	push   %eax
  800282:	6a 09                	push   $0x9
  800284:	68 6a 0f 80 00       	push   $0x800f6a
  800289:	6a 23                	push   $0x23
  80028b:	68 87 0f 80 00       	push   $0x800f87
  800290:	e8 6c 00 00 00       	call   800301 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800295:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800298:	5b                   	pop    %ebx
  800299:	5e                   	pop    %esi
  80029a:	5f                   	pop    %edi
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    

0080029d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	57                   	push   %edi
  8002a1:	56                   	push   %esi
  8002a2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a3:	be 00 00 00 00       	mov    $0x0,%esi
  8002a8:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002b6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002bb:	5b                   	pop    %ebx
  8002bc:	5e                   	pop    %esi
  8002bd:	5f                   	pop    %edi
  8002be:	5d                   	pop    %ebp
  8002bf:	c3                   	ret    

008002c0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ce:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d6:	89 cb                	mov    %ecx,%ebx
  8002d8:	89 cf                	mov    %ecx,%edi
  8002da:	89 ce                	mov    %ecx,%esi
  8002dc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002de:	85 c0                	test   %eax,%eax
  8002e0:	7e 17                	jle    8002f9 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e2:	83 ec 0c             	sub    $0xc,%esp
  8002e5:	50                   	push   %eax
  8002e6:	6a 0c                	push   $0xc
  8002e8:	68 6a 0f 80 00       	push   $0x800f6a
  8002ed:	6a 23                	push   $0x23
  8002ef:	68 87 0f 80 00       	push   $0x800f87
  8002f4:	e8 08 00 00 00       	call   800301 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
  800304:	56                   	push   %esi
  800305:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800306:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800309:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80030f:	e8 00 fe ff ff       	call   800114 <sys_getenvid>
  800314:	83 ec 0c             	sub    $0xc,%esp
  800317:	ff 75 0c             	pushl  0xc(%ebp)
  80031a:	ff 75 08             	pushl  0x8(%ebp)
  80031d:	56                   	push   %esi
  80031e:	50                   	push   %eax
  80031f:	68 98 0f 80 00       	push   $0x800f98
  800324:	e8 b1 00 00 00       	call   8003da <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800329:	83 c4 18             	add    $0x18,%esp
  80032c:	53                   	push   %ebx
  80032d:	ff 75 10             	pushl  0x10(%ebp)
  800330:	e8 54 00 00 00       	call   800389 <vcprintf>
	cprintf("\n");
  800335:	c7 04 24 bc 0f 80 00 	movl   $0x800fbc,(%esp)
  80033c:	e8 99 00 00 00       	call   8003da <cprintf>
  800341:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800344:	cc                   	int3   
  800345:	eb fd                	jmp    800344 <_panic+0x43>

00800347 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	53                   	push   %ebx
  80034b:	83 ec 04             	sub    $0x4,%esp
  80034e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800351:	8b 13                	mov    (%ebx),%edx
  800353:	8d 42 01             	lea    0x1(%edx),%eax
  800356:	89 03                	mov    %eax,(%ebx)
  800358:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80035b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80035f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800364:	75 1a                	jne    800380 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800366:	83 ec 08             	sub    $0x8,%esp
  800369:	68 ff 00 00 00       	push   $0xff
  80036e:	8d 43 08             	lea    0x8(%ebx),%eax
  800371:	50                   	push   %eax
  800372:	e8 1f fd ff ff       	call   800096 <sys_cputs>
		b->idx = 0;
  800377:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80037d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800380:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800384:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800387:	c9                   	leave  
  800388:	c3                   	ret    

00800389 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800392:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800399:	00 00 00 
	b.cnt = 0;
  80039c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003a3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003a6:	ff 75 0c             	pushl  0xc(%ebp)
  8003a9:	ff 75 08             	pushl  0x8(%ebp)
  8003ac:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003b2:	50                   	push   %eax
  8003b3:	68 47 03 80 00       	push   $0x800347
  8003b8:	e8 54 01 00 00       	call   800511 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003bd:	83 c4 08             	add    $0x8,%esp
  8003c0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003c6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003cc:	50                   	push   %eax
  8003cd:	e8 c4 fc ff ff       	call   800096 <sys_cputs>

	return b.cnt;
}
  8003d2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003d8:	c9                   	leave  
  8003d9:	c3                   	ret    

008003da <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003da:	55                   	push   %ebp
  8003db:	89 e5                	mov    %esp,%ebp
  8003dd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003e0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003e3:	50                   	push   %eax
  8003e4:	ff 75 08             	pushl  0x8(%ebp)
  8003e7:	e8 9d ff ff ff       	call   800389 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003ec:	c9                   	leave  
  8003ed:	c3                   	ret    

008003ee <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	57                   	push   %edi
  8003f2:	56                   	push   %esi
  8003f3:	53                   	push   %ebx
  8003f4:	83 ec 1c             	sub    $0x1c,%esp
  8003f7:	89 c7                	mov    %eax,%edi
  8003f9:	89 d6                	mov    %edx,%esi
  8003fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800401:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800404:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800407:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80040a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80040f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800412:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800415:	39 d3                	cmp    %edx,%ebx
  800417:	72 05                	jb     80041e <printnum+0x30>
  800419:	39 45 10             	cmp    %eax,0x10(%ebp)
  80041c:	77 45                	ja     800463 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80041e:	83 ec 0c             	sub    $0xc,%esp
  800421:	ff 75 18             	pushl  0x18(%ebp)
  800424:	8b 45 14             	mov    0x14(%ebp),%eax
  800427:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80042a:	53                   	push   %ebx
  80042b:	ff 75 10             	pushl  0x10(%ebp)
  80042e:	83 ec 08             	sub    $0x8,%esp
  800431:	ff 75 e4             	pushl  -0x1c(%ebp)
  800434:	ff 75 e0             	pushl  -0x20(%ebp)
  800437:	ff 75 dc             	pushl  -0x24(%ebp)
  80043a:	ff 75 d8             	pushl  -0x28(%ebp)
  80043d:	e8 7e 08 00 00       	call   800cc0 <__udivdi3>
  800442:	83 c4 18             	add    $0x18,%esp
  800445:	52                   	push   %edx
  800446:	50                   	push   %eax
  800447:	89 f2                	mov    %esi,%edx
  800449:	89 f8                	mov    %edi,%eax
  80044b:	e8 9e ff ff ff       	call   8003ee <printnum>
  800450:	83 c4 20             	add    $0x20,%esp
  800453:	eb 18                	jmp    80046d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	56                   	push   %esi
  800459:	ff 75 18             	pushl  0x18(%ebp)
  80045c:	ff d7                	call   *%edi
  80045e:	83 c4 10             	add    $0x10,%esp
  800461:	eb 03                	jmp    800466 <printnum+0x78>
  800463:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800466:	83 eb 01             	sub    $0x1,%ebx
  800469:	85 db                	test   %ebx,%ebx
  80046b:	7f e8                	jg     800455 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80046d:	83 ec 08             	sub    $0x8,%esp
  800470:	56                   	push   %esi
  800471:	83 ec 04             	sub    $0x4,%esp
  800474:	ff 75 e4             	pushl  -0x1c(%ebp)
  800477:	ff 75 e0             	pushl  -0x20(%ebp)
  80047a:	ff 75 dc             	pushl  -0x24(%ebp)
  80047d:	ff 75 d8             	pushl  -0x28(%ebp)
  800480:	e8 6b 09 00 00       	call   800df0 <__umoddi3>
  800485:	83 c4 14             	add    $0x14,%esp
  800488:	0f be 80 be 0f 80 00 	movsbl 0x800fbe(%eax),%eax
  80048f:	50                   	push   %eax
  800490:	ff d7                	call   *%edi
}
  800492:	83 c4 10             	add    $0x10,%esp
  800495:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800498:	5b                   	pop    %ebx
  800499:	5e                   	pop    %esi
  80049a:	5f                   	pop    %edi
  80049b:	5d                   	pop    %ebp
  80049c:	c3                   	ret    

0080049d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80049d:	55                   	push   %ebp
  80049e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004a0:	83 fa 01             	cmp    $0x1,%edx
  8004a3:	7e 0e                	jle    8004b3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004a5:	8b 10                	mov    (%eax),%edx
  8004a7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004aa:	89 08                	mov    %ecx,(%eax)
  8004ac:	8b 02                	mov    (%edx),%eax
  8004ae:	8b 52 04             	mov    0x4(%edx),%edx
  8004b1:	eb 22                	jmp    8004d5 <getuint+0x38>
	else if (lflag)
  8004b3:	85 d2                	test   %edx,%edx
  8004b5:	74 10                	je     8004c7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004b7:	8b 10                	mov    (%eax),%edx
  8004b9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004bc:	89 08                	mov    %ecx,(%eax)
  8004be:	8b 02                	mov    (%edx),%eax
  8004c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c5:	eb 0e                	jmp    8004d5 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004c7:	8b 10                	mov    (%eax),%edx
  8004c9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004cc:	89 08                	mov    %ecx,(%eax)
  8004ce:	8b 02                	mov    (%edx),%eax
  8004d0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004d5:	5d                   	pop    %ebp
  8004d6:	c3                   	ret    

008004d7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004d7:	55                   	push   %ebp
  8004d8:	89 e5                	mov    %esp,%ebp
  8004da:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004dd:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004e1:	8b 10                	mov    (%eax),%edx
  8004e3:	3b 50 04             	cmp    0x4(%eax),%edx
  8004e6:	73 0a                	jae    8004f2 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004e8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004eb:	89 08                	mov    %ecx,(%eax)
  8004ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f0:	88 02                	mov    %al,(%edx)
}
  8004f2:	5d                   	pop    %ebp
  8004f3:	c3                   	ret    

008004f4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004fa:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004fd:	50                   	push   %eax
  8004fe:	ff 75 10             	pushl  0x10(%ebp)
  800501:	ff 75 0c             	pushl  0xc(%ebp)
  800504:	ff 75 08             	pushl  0x8(%ebp)
  800507:	e8 05 00 00 00       	call   800511 <vprintfmt>
	va_end(ap);
}
  80050c:	83 c4 10             	add    $0x10,%esp
  80050f:	c9                   	leave  
  800510:	c3                   	ret    

00800511 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800511:	55                   	push   %ebp
  800512:	89 e5                	mov    %esp,%ebp
  800514:	57                   	push   %edi
  800515:	56                   	push   %esi
  800516:	53                   	push   %ebx
  800517:	83 ec 2c             	sub    $0x2c,%esp
  80051a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

    int Color = 0;// EOF added
  80051d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800524:	eb 17                	jmp    80053d <vprintfmt+0x2c>

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800526:	85 c0                	test   %eax,%eax
  800528:	0f 84 9f 03 00 00    	je     8008cd <vprintfmt+0x3bc>
				return;
			putch(ch, putdat);
  80052e:	83 ec 08             	sub    $0x8,%esp
  800531:	ff 75 0c             	pushl  0xc(%ebp)
  800534:	50                   	push   %eax
  800535:	ff 55 08             	call   *0x8(%ebp)
  800538:	83 c4 10             	add    $0x10,%esp
	char padc;

    int Color = 0;// EOF added

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80053b:	89 f3                	mov    %esi,%ebx
  80053d:	8d 73 01             	lea    0x1(%ebx),%esi
  800540:	0f b6 03             	movzbl (%ebx),%eax
  800543:	83 f8 25             	cmp    $0x25,%eax
  800546:	75 de                	jne    800526 <vprintfmt+0x15>
  800548:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80054c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800553:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800558:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80055f:	ba 00 00 00 00       	mov    $0x0,%edx
  800564:	eb 06                	jmp    80056c <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800566:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800568:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056c:	8d 5e 01             	lea    0x1(%esi),%ebx
  80056f:	0f b6 06             	movzbl (%esi),%eax
  800572:	0f b6 c8             	movzbl %al,%ecx
  800575:	83 e8 23             	sub    $0x23,%eax
  800578:	3c 55                	cmp    $0x55,%al
  80057a:	0f 87 2d 03 00 00    	ja     8008ad <vprintfmt+0x39c>
  800580:	0f b6 c0             	movzbl %al,%eax
  800583:	ff 24 85 80 10 80 00 	jmp    *0x801080(,%eax,4)
  80058a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80058c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800590:	eb da                	jmp    80056c <vprintfmt+0x5b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800592:	89 de                	mov    %ebx,%esi
  800594:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800599:	8d 04 bf             	lea    (%edi,%edi,4),%eax
  80059c:	8d 7c 41 d0          	lea    -0x30(%ecx,%eax,2),%edi
				ch = *fmt;
  8005a0:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
  8005a3:	8d 41 d0             	lea    -0x30(%ecx),%eax
  8005a6:	83 f8 09             	cmp    $0x9,%eax
  8005a9:	77 33                	ja     8005de <vprintfmt+0xcd>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005ab:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005ae:	eb e9                	jmp    800599 <vprintfmt+0x88>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8d 48 04             	lea    0x4(%eax),%ecx
  8005b6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005b9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bb:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005bd:	eb 1f                	jmp    8005de <vprintfmt+0xcd>
  8005bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c2:	85 c0                	test   %eax,%eax
  8005c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c9:	0f 49 c8             	cmovns %eax,%ecx
  8005cc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cf:	89 de                	mov    %ebx,%esi
  8005d1:	eb 99                	jmp    80056c <vprintfmt+0x5b>
  8005d3:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005d5:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
  8005dc:	eb 8e                	jmp    80056c <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8005de:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005e2:	79 88                	jns    80056c <vprintfmt+0x5b>
				width = precision, precision = -1;
  8005e4:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8005e7:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8005ec:	e9 7b ff ff ff       	jmp    80056c <vprintfmt+0x5b>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005f1:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f4:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005f6:	e9 71 ff ff ff       	jmp    80056c <vprintfmt+0x5b>
		// character
		case 'c':
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8d 50 04             	lea    0x4(%eax),%edx
  800601:	89 55 14             	mov    %edx,0x14(%ebp)
			putch(ch, putdat);
  800604:	83 ec 08             	sub    $0x8,%esp
  800607:	ff 75 0c             	pushl  0xc(%ebp)
  80060a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80060d:	03 08                	add    (%eax),%ecx
  80060f:	51                   	push   %ecx
  800610:	ff 55 08             	call   *0x8(%ebp)
            Color = 0;

			break;
  800613:	83 c4 10             	add    $0x10,%esp
            /*
             * EOF added
             */
            ch = va_arg(ap, int) + Color;
			putch(ch, putdat);
            Color = 0;
  800616:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

			break;
  80061d:	e9 1b ff ff ff       	jmp    80053d <vprintfmt+0x2c>

        case 'C':
            switch(va_arg(ap, int))
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8d 48 04             	lea    0x4(%eax),%ecx
  800628:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80062b:	8b 00                	mov    (%eax),%eax
  80062d:	83 f8 02             	cmp    $0x2,%eax
  800630:	74 1a                	je     80064c <vprintfmt+0x13b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800632:	89 de                	mov    %ebx,%esi
  800634:	83 f8 04             	cmp    $0x4,%eax
  800637:	b8 00 00 00 00       	mov    $0x0,%eax
  80063c:	b9 00 04 00 00       	mov    $0x400,%ecx
  800641:	0f 44 c1             	cmove  %ecx,%eax
  800644:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800647:	e9 20 ff ff ff       	jmp    80056c <vprintfmt+0x5b>
  80064c:	89 de                	mov    %ebx,%esi
                case COLOR_RED:
                    Color = COLOR_RED<<8;
                    break;

                case COLOR_GRN:
                    Color = COLOR_GRN<<8;
  80064e:	c7 45 d8 00 02 00 00 	movl   $0x200,-0x28(%ebp)
  800655:	e9 12 ff ff ff       	jmp    80056c <vprintfmt+0x5b>

            goto reswitch;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	8d 50 04             	lea    0x4(%eax),%edx
  800660:	89 55 14             	mov    %edx,0x14(%ebp)
  800663:	8b 00                	mov    (%eax),%eax
  800665:	99                   	cltd   
  800666:	31 d0                	xor    %edx,%eax
  800668:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80066a:	83 f8 09             	cmp    $0x9,%eax
  80066d:	7f 0b                	jg     80067a <vprintfmt+0x169>
  80066f:	8b 14 85 e0 11 80 00 	mov    0x8011e0(,%eax,4),%edx
  800676:	85 d2                	test   %edx,%edx
  800678:	75 19                	jne    800693 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  80067a:	50                   	push   %eax
  80067b:	68 d6 0f 80 00       	push   $0x800fd6
  800680:	ff 75 0c             	pushl  0xc(%ebp)
  800683:	ff 75 08             	pushl  0x8(%ebp)
  800686:	e8 69 fe ff ff       	call   8004f4 <printfmt>
  80068b:	83 c4 10             	add    $0x10,%esp
  80068e:	e9 aa fe ff ff       	jmp    80053d <vprintfmt+0x2c>
			else
				printfmt(putch, putdat, "%s", p);
  800693:	52                   	push   %edx
  800694:	68 df 0f 80 00       	push   $0x800fdf
  800699:	ff 75 0c             	pushl  0xc(%ebp)
  80069c:	ff 75 08             	pushl  0x8(%ebp)
  80069f:	e8 50 fe ff ff       	call   8004f4 <printfmt>
  8006a4:	83 c4 10             	add    $0x10,%esp
  8006a7:	e9 91 fe ff ff       	jmp    80053d <vprintfmt+0x2c>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8d 50 04             	lea    0x4(%eax),%edx
  8006b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b5:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006b7:	85 f6                	test   %esi,%esi
  8006b9:	b8 cf 0f 80 00       	mov    $0x800fcf,%eax
  8006be:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006c5:	0f 8e 93 00 00 00    	jle    80075e <vprintfmt+0x24d>
  8006cb:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8006cf:	0f 84 91 00 00 00    	je     800766 <vprintfmt+0x255>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d5:	83 ec 08             	sub    $0x8,%esp
  8006d8:	57                   	push   %edi
  8006d9:	56                   	push   %esi
  8006da:	e8 76 02 00 00       	call   800955 <strnlen>
  8006df:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006e2:	29 c1                	sub    %eax,%ecx
  8006e4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006e7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006ea:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
  8006ee:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8006f1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006f4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8006f7:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8006fa:	89 cb                	mov    %ecx,%ebx
  8006fc:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fe:	eb 0e                	jmp    80070e <vprintfmt+0x1fd>
					putch(padc, putdat);
  800700:	83 ec 08             	sub    $0x8,%esp
  800703:	56                   	push   %esi
  800704:	57                   	push   %edi
  800705:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800708:	83 eb 01             	sub    $0x1,%ebx
  80070b:	83 c4 10             	add    $0x10,%esp
  80070e:	85 db                	test   %ebx,%ebx
  800710:	7f ee                	jg     800700 <vprintfmt+0x1ef>
  800712:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800715:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800718:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80071b:	85 c9                	test   %ecx,%ecx
  80071d:	b8 00 00 00 00       	mov    $0x0,%eax
  800722:	0f 49 c1             	cmovns %ecx,%eax
  800725:	29 c1                	sub    %eax,%ecx
  800727:	89 cb                	mov    %ecx,%ebx
  800729:	eb 41                	jmp    80076c <vprintfmt+0x25b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80072b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80072f:	74 1b                	je     80074c <vprintfmt+0x23b>
  800731:	0f be c0             	movsbl %al,%eax
  800734:	83 e8 20             	sub    $0x20,%eax
  800737:	83 f8 5e             	cmp    $0x5e,%eax
  80073a:	76 10                	jbe    80074c <vprintfmt+0x23b>
					putch('?', putdat);
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	ff 75 0c             	pushl  0xc(%ebp)
  800742:	6a 3f                	push   $0x3f
  800744:	ff 55 08             	call   *0x8(%ebp)
  800747:	83 c4 10             	add    $0x10,%esp
  80074a:	eb 0d                	jmp    800759 <vprintfmt+0x248>
				else
					putch(ch, putdat);
  80074c:	83 ec 08             	sub    $0x8,%esp
  80074f:	ff 75 0c             	pushl  0xc(%ebp)
  800752:	52                   	push   %edx
  800753:	ff 55 08             	call   *0x8(%ebp)
  800756:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800759:	83 eb 01             	sub    $0x1,%ebx
  80075c:	eb 0e                	jmp    80076c <vprintfmt+0x25b>
  80075e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800761:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800764:	eb 06                	jmp    80076c <vprintfmt+0x25b>
  800766:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800769:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80076c:	83 c6 01             	add    $0x1,%esi
  80076f:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800773:	0f be d0             	movsbl %al,%edx
  800776:	85 d2                	test   %edx,%edx
  800778:	74 25                	je     80079f <vprintfmt+0x28e>
  80077a:	85 ff                	test   %edi,%edi
  80077c:	78 ad                	js     80072b <vprintfmt+0x21a>
  80077e:	83 ef 01             	sub    $0x1,%edi
  800781:	79 a8                	jns    80072b <vprintfmt+0x21a>
  800783:	89 d8                	mov    %ebx,%eax
  800785:	8b 75 08             	mov    0x8(%ebp),%esi
  800788:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80078b:	89 c3                	mov    %eax,%ebx
  80078d:	eb 16                	jmp    8007a5 <vprintfmt+0x294>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80078f:	83 ec 08             	sub    $0x8,%esp
  800792:	57                   	push   %edi
  800793:	6a 20                	push   $0x20
  800795:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800797:	83 eb 01             	sub    $0x1,%ebx
  80079a:	83 c4 10             	add    $0x10,%esp
  80079d:	eb 06                	jmp    8007a5 <vprintfmt+0x294>
  80079f:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8007a5:	85 db                	test   %ebx,%ebx
  8007a7:	7f e6                	jg     80078f <vprintfmt+0x27e>
  8007a9:	89 75 08             	mov    %esi,0x8(%ebp)
  8007ac:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8007af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007b2:	e9 86 fd ff ff       	jmp    80053d <vprintfmt+0x2c>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007b7:	83 fa 01             	cmp    $0x1,%edx
  8007ba:	7e 10                	jle    8007cc <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
  8007bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bf:	8d 50 08             	lea    0x8(%eax),%edx
  8007c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c5:	8b 30                	mov    (%eax),%esi
  8007c7:	8b 78 04             	mov    0x4(%eax),%edi
  8007ca:	eb 26                	jmp    8007f2 <vprintfmt+0x2e1>
	else if (lflag)
  8007cc:	85 d2                	test   %edx,%edx
  8007ce:	74 12                	je     8007e2 <vprintfmt+0x2d1>
		return va_arg(*ap, long);
  8007d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d3:	8d 50 04             	lea    0x4(%eax),%edx
  8007d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d9:	8b 30                	mov    (%eax),%esi
  8007db:	89 f7                	mov    %esi,%edi
  8007dd:	c1 ff 1f             	sar    $0x1f,%edi
  8007e0:	eb 10                	jmp    8007f2 <vprintfmt+0x2e1>
	else
		return va_arg(*ap, int);
  8007e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e5:	8d 50 04             	lea    0x4(%eax),%edx
  8007e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007eb:	8b 30                	mov    (%eax),%esi
  8007ed:	89 f7                	mov    %esi,%edi
  8007ef:	c1 ff 1f             	sar    $0x1f,%edi
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007f2:	89 f0                	mov    %esi,%eax
  8007f4:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007f6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007fb:	85 ff                	test   %edi,%edi
  8007fd:	79 7b                	jns    80087a <vprintfmt+0x369>
				putch('-', putdat);
  8007ff:	83 ec 08             	sub    $0x8,%esp
  800802:	ff 75 0c             	pushl  0xc(%ebp)
  800805:	6a 2d                	push   $0x2d
  800807:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80080a:	89 f0                	mov    %esi,%eax
  80080c:	89 fa                	mov    %edi,%edx
  80080e:	f7 d8                	neg    %eax
  800810:	83 d2 00             	adc    $0x0,%edx
  800813:	f7 da                	neg    %edx
  800815:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800818:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80081d:	eb 5b                	jmp    80087a <vprintfmt+0x369>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80081f:	8d 45 14             	lea    0x14(%ebp),%eax
  800822:	e8 76 fc ff ff       	call   80049d <getuint>
			base = 10;
  800827:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80082c:	eb 4c                	jmp    80087a <vprintfmt+0x369>

            /*
                What I added. --by EOF
             */

            num = getuint(&ap, lflag);
  80082e:	8d 45 14             	lea    0x14(%ebp),%eax
  800831:	e8 67 fc ff ff       	call   80049d <getuint>
            base = 8;
  800836:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80083b:	eb 3d                	jmp    80087a <vprintfmt+0x369>

		// pointer
		case 'p':
			putch('0', putdat);
  80083d:	83 ec 08             	sub    $0x8,%esp
  800840:	ff 75 0c             	pushl  0xc(%ebp)
  800843:	6a 30                	push   $0x30
  800845:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800848:	83 c4 08             	add    $0x8,%esp
  80084b:	ff 75 0c             	pushl  0xc(%ebp)
  80084e:	6a 78                	push   $0x78
  800850:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800853:	8b 45 14             	mov    0x14(%ebp),%eax
  800856:	8d 50 04             	lea    0x4(%eax),%edx
  800859:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80085c:	8b 00                	mov    (%eax),%eax
  80085e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800863:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800866:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80086b:	eb 0d                	jmp    80087a <vprintfmt+0x369>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80086d:	8d 45 14             	lea    0x14(%ebp),%eax
  800870:	e8 28 fc ff ff       	call   80049d <getuint>
			base = 16;
  800875:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80087a:	83 ec 0c             	sub    $0xc,%esp
  80087d:	0f be 75 dc          	movsbl -0x24(%ebp),%esi
  800881:	56                   	push   %esi
  800882:	ff 75 e0             	pushl  -0x20(%ebp)
  800885:	51                   	push   %ecx
  800886:	52                   	push   %edx
  800887:	50                   	push   %eax
  800888:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	e8 5b fb ff ff       	call   8003ee <printnum>
			break;
  800893:	83 c4 20             	add    $0x20,%esp
  800896:	e9 a2 fc ff ff       	jmp    80053d <vprintfmt+0x2c>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80089b:	83 ec 08             	sub    $0x8,%esp
  80089e:	ff 75 0c             	pushl  0xc(%ebp)
  8008a1:	51                   	push   %ecx
  8008a2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8008a5:	83 c4 10             	add    $0x10,%esp
  8008a8:	e9 90 fc ff ff       	jmp    80053d <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008ad:	83 ec 08             	sub    $0x8,%esp
  8008b0:	ff 75 0c             	pushl  0xc(%ebp)
  8008b3:	6a 25                	push   $0x25
  8008b5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b8:	83 c4 10             	add    $0x10,%esp
  8008bb:	89 f3                	mov    %esi,%ebx
  8008bd:	eb 03                	jmp    8008c2 <vprintfmt+0x3b1>
  8008bf:	83 eb 01             	sub    $0x1,%ebx
  8008c2:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8008c6:	75 f7                	jne    8008bf <vprintfmt+0x3ae>
  8008c8:	e9 70 fc ff ff       	jmp    80053d <vprintfmt+0x2c>
				/* do nothing */;
			break;
		}
	}
}
  8008cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008d0:	5b                   	pop    %ebx
  8008d1:	5e                   	pop    %esi
  8008d2:	5f                   	pop    %edi
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	83 ec 18             	sub    $0x18,%esp
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008e4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008e8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008f2:	85 c0                	test   %eax,%eax
  8008f4:	74 26                	je     80091c <vsnprintf+0x47>
  8008f6:	85 d2                	test   %edx,%edx
  8008f8:	7e 22                	jle    80091c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008fa:	ff 75 14             	pushl  0x14(%ebp)
  8008fd:	ff 75 10             	pushl  0x10(%ebp)
  800900:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800903:	50                   	push   %eax
  800904:	68 d7 04 80 00       	push   $0x8004d7
  800909:	e8 03 fc ff ff       	call   800511 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80090e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800911:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800914:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800917:	83 c4 10             	add    $0x10,%esp
  80091a:	eb 05                	jmp    800921 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80091c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800921:	c9                   	leave  
  800922:	c3                   	ret    

00800923 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800929:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80092c:	50                   	push   %eax
  80092d:	ff 75 10             	pushl  0x10(%ebp)
  800930:	ff 75 0c             	pushl  0xc(%ebp)
  800933:	ff 75 08             	pushl  0x8(%ebp)
  800936:	e8 9a ff ff ff       	call   8008d5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80093b:	c9                   	leave  
  80093c:	c3                   	ret    

0080093d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800943:	b8 00 00 00 00       	mov    $0x0,%eax
  800948:	eb 03                	jmp    80094d <strlen+0x10>
		n++;
  80094a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80094d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800951:	75 f7                	jne    80094a <strlen+0xd>
		n++;
	return n;
}
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80095e:	ba 00 00 00 00       	mov    $0x0,%edx
  800963:	eb 03                	jmp    800968 <strnlen+0x13>
		n++;
  800965:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800968:	39 c2                	cmp    %eax,%edx
  80096a:	74 08                	je     800974 <strnlen+0x1f>
  80096c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800970:	75 f3                	jne    800965 <strnlen+0x10>
  800972:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	53                   	push   %ebx
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
  80097d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800980:	89 c2                	mov    %eax,%edx
  800982:	83 c2 01             	add    $0x1,%edx
  800985:	83 c1 01             	add    $0x1,%ecx
  800988:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80098c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80098f:	84 db                	test   %bl,%bl
  800991:	75 ef                	jne    800982 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800993:	5b                   	pop    %ebx
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	53                   	push   %ebx
  80099a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80099d:	53                   	push   %ebx
  80099e:	e8 9a ff ff ff       	call   80093d <strlen>
  8009a3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009a6:	ff 75 0c             	pushl  0xc(%ebp)
  8009a9:	01 d8                	add    %ebx,%eax
  8009ab:	50                   	push   %eax
  8009ac:	e8 c5 ff ff ff       	call   800976 <strcpy>
	return dst;
}
  8009b1:	89 d8                	mov    %ebx,%eax
  8009b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	56                   	push   %esi
  8009bc:	53                   	push   %ebx
  8009bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c3:	89 f3                	mov    %esi,%ebx
  8009c5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c8:	89 f2                	mov    %esi,%edx
  8009ca:	eb 0f                	jmp    8009db <strncpy+0x23>
		*dst++ = *src;
  8009cc:	83 c2 01             	add    $0x1,%edx
  8009cf:	0f b6 01             	movzbl (%ecx),%eax
  8009d2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009d5:	80 39 01             	cmpb   $0x1,(%ecx)
  8009d8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009db:	39 da                	cmp    %ebx,%edx
  8009dd:	75 ed                	jne    8009cc <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009df:	89 f0                	mov    %esi,%eax
  8009e1:	5b                   	pop    %ebx
  8009e2:	5e                   	pop    %esi
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	56                   	push   %esi
  8009e9:	53                   	push   %ebx
  8009ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f0:	8b 55 10             	mov    0x10(%ebp),%edx
  8009f3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009f5:	85 d2                	test   %edx,%edx
  8009f7:	74 21                	je     800a1a <strlcpy+0x35>
  8009f9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009fd:	89 f2                	mov    %esi,%edx
  8009ff:	eb 09                	jmp    800a0a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a01:	83 c2 01             	add    $0x1,%edx
  800a04:	83 c1 01             	add    $0x1,%ecx
  800a07:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a0a:	39 c2                	cmp    %eax,%edx
  800a0c:	74 09                	je     800a17 <strlcpy+0x32>
  800a0e:	0f b6 19             	movzbl (%ecx),%ebx
  800a11:	84 db                	test   %bl,%bl
  800a13:	75 ec                	jne    800a01 <strlcpy+0x1c>
  800a15:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a17:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a1a:	29 f0                	sub    %esi,%eax
}
  800a1c:	5b                   	pop    %ebx
  800a1d:	5e                   	pop    %esi
  800a1e:	5d                   	pop    %ebp
  800a1f:	c3                   	ret    

00800a20 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a26:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a29:	eb 06                	jmp    800a31 <strcmp+0x11>
		p++, q++;
  800a2b:	83 c1 01             	add    $0x1,%ecx
  800a2e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a31:	0f b6 01             	movzbl (%ecx),%eax
  800a34:	84 c0                	test   %al,%al
  800a36:	74 04                	je     800a3c <strcmp+0x1c>
  800a38:	3a 02                	cmp    (%edx),%al
  800a3a:	74 ef                	je     800a2b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a3c:	0f b6 c0             	movzbl %al,%eax
  800a3f:	0f b6 12             	movzbl (%edx),%edx
  800a42:	29 d0                	sub    %edx,%eax
}
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	53                   	push   %ebx
  800a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a50:	89 c3                	mov    %eax,%ebx
  800a52:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a55:	eb 06                	jmp    800a5d <strncmp+0x17>
		n--, p++, q++;
  800a57:	83 c0 01             	add    $0x1,%eax
  800a5a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a5d:	39 d8                	cmp    %ebx,%eax
  800a5f:	74 15                	je     800a76 <strncmp+0x30>
  800a61:	0f b6 08             	movzbl (%eax),%ecx
  800a64:	84 c9                	test   %cl,%cl
  800a66:	74 04                	je     800a6c <strncmp+0x26>
  800a68:	3a 0a                	cmp    (%edx),%cl
  800a6a:	74 eb                	je     800a57 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a6c:	0f b6 00             	movzbl (%eax),%eax
  800a6f:	0f b6 12             	movzbl (%edx),%edx
  800a72:	29 d0                	sub    %edx,%eax
  800a74:	eb 05                	jmp    800a7b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a76:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a7b:	5b                   	pop    %ebx
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	8b 45 08             	mov    0x8(%ebp),%eax
  800a84:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a88:	eb 07                	jmp    800a91 <strchr+0x13>
		if (*s == c)
  800a8a:	38 ca                	cmp    %cl,%dl
  800a8c:	74 0f                	je     800a9d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a8e:	83 c0 01             	add    $0x1,%eax
  800a91:	0f b6 10             	movzbl (%eax),%edx
  800a94:	84 d2                	test   %dl,%dl
  800a96:	75 f2                	jne    800a8a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a98:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa9:	eb 03                	jmp    800aae <strfind+0xf>
  800aab:	83 c0 01             	add    $0x1,%eax
  800aae:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ab1:	38 ca                	cmp    %cl,%dl
  800ab3:	74 04                	je     800ab9 <strfind+0x1a>
  800ab5:	84 d2                	test   %dl,%dl
  800ab7:	75 f2                	jne    800aab <strfind+0xc>
			break;
	return (char *) s;
}
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	57                   	push   %edi
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
  800ac1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ac4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ac7:	85 c9                	test   %ecx,%ecx
  800ac9:	74 36                	je     800b01 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800acb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ad1:	75 28                	jne    800afb <memset+0x40>
  800ad3:	f6 c1 03             	test   $0x3,%cl
  800ad6:	75 23                	jne    800afb <memset+0x40>
		c &= 0xFF;
  800ad8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800adc:	89 d3                	mov    %edx,%ebx
  800ade:	c1 e3 08             	shl    $0x8,%ebx
  800ae1:	89 d6                	mov    %edx,%esi
  800ae3:	c1 e6 18             	shl    $0x18,%esi
  800ae6:	89 d0                	mov    %edx,%eax
  800ae8:	c1 e0 10             	shl    $0x10,%eax
  800aeb:	09 f0                	or     %esi,%eax
  800aed:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800aef:	89 d8                	mov    %ebx,%eax
  800af1:	09 d0                	or     %edx,%eax
  800af3:	c1 e9 02             	shr    $0x2,%ecx
  800af6:	fc                   	cld    
  800af7:	f3 ab                	rep stos %eax,%es:(%edi)
  800af9:	eb 06                	jmp    800b01 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800afb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afe:	fc                   	cld    
  800aff:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b01:	89 f8                	mov    %edi,%eax
  800b03:	5b                   	pop    %ebx
  800b04:	5e                   	pop    %esi
  800b05:	5f                   	pop    %edi
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    

00800b08 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	57                   	push   %edi
  800b0c:	56                   	push   %esi
  800b0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b10:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b13:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b16:	39 c6                	cmp    %eax,%esi
  800b18:	73 35                	jae    800b4f <memmove+0x47>
  800b1a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b1d:	39 d0                	cmp    %edx,%eax
  800b1f:	73 2e                	jae    800b4f <memmove+0x47>
		s += n;
		d += n;
  800b21:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b24:	89 d6                	mov    %edx,%esi
  800b26:	09 fe                	or     %edi,%esi
  800b28:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b2e:	75 13                	jne    800b43 <memmove+0x3b>
  800b30:	f6 c1 03             	test   $0x3,%cl
  800b33:	75 0e                	jne    800b43 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b35:	83 ef 04             	sub    $0x4,%edi
  800b38:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b3b:	c1 e9 02             	shr    $0x2,%ecx
  800b3e:	fd                   	std    
  800b3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b41:	eb 09                	jmp    800b4c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b43:	83 ef 01             	sub    $0x1,%edi
  800b46:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b49:	fd                   	std    
  800b4a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b4c:	fc                   	cld    
  800b4d:	eb 1d                	jmp    800b6c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4f:	89 f2                	mov    %esi,%edx
  800b51:	09 c2                	or     %eax,%edx
  800b53:	f6 c2 03             	test   $0x3,%dl
  800b56:	75 0f                	jne    800b67 <memmove+0x5f>
  800b58:	f6 c1 03             	test   $0x3,%cl
  800b5b:	75 0a                	jne    800b67 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b5d:	c1 e9 02             	shr    $0x2,%ecx
  800b60:	89 c7                	mov    %eax,%edi
  800b62:	fc                   	cld    
  800b63:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b65:	eb 05                	jmp    800b6c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b67:	89 c7                	mov    %eax,%edi
  800b69:	fc                   	cld    
  800b6a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b6c:	5e                   	pop    %esi
  800b6d:	5f                   	pop    %edi
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b73:	ff 75 10             	pushl  0x10(%ebp)
  800b76:	ff 75 0c             	pushl  0xc(%ebp)
  800b79:	ff 75 08             	pushl  0x8(%ebp)
  800b7c:	e8 87 ff ff ff       	call   800b08 <memmove>
}
  800b81:	c9                   	leave  
  800b82:	c3                   	ret    

00800b83 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
  800b88:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b8e:	89 c6                	mov    %eax,%esi
  800b90:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b93:	eb 1a                	jmp    800baf <memcmp+0x2c>
		if (*s1 != *s2)
  800b95:	0f b6 08             	movzbl (%eax),%ecx
  800b98:	0f b6 1a             	movzbl (%edx),%ebx
  800b9b:	38 d9                	cmp    %bl,%cl
  800b9d:	74 0a                	je     800ba9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b9f:	0f b6 c1             	movzbl %cl,%eax
  800ba2:	0f b6 db             	movzbl %bl,%ebx
  800ba5:	29 d8                	sub    %ebx,%eax
  800ba7:	eb 0f                	jmp    800bb8 <memcmp+0x35>
		s1++, s2++;
  800ba9:	83 c0 01             	add    $0x1,%eax
  800bac:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800baf:	39 f0                	cmp    %esi,%eax
  800bb1:	75 e2                	jne    800b95 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	53                   	push   %ebx
  800bc0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bc3:	89 c1                	mov    %eax,%ecx
  800bc5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bcc:	eb 0a                	jmp    800bd8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bce:	0f b6 10             	movzbl (%eax),%edx
  800bd1:	39 da                	cmp    %ebx,%edx
  800bd3:	74 07                	je     800bdc <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bd5:	83 c0 01             	add    $0x1,%eax
  800bd8:	39 c8                	cmp    %ecx,%eax
  800bda:	72 f2                	jb     800bce <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bdc:	5b                   	pop    %ebx
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	57                   	push   %edi
  800be3:	56                   	push   %esi
  800be4:	53                   	push   %ebx
  800be5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800beb:	eb 03                	jmp    800bf0 <strtol+0x11>
		s++;
  800bed:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf0:	0f b6 01             	movzbl (%ecx),%eax
  800bf3:	3c 20                	cmp    $0x20,%al
  800bf5:	74 f6                	je     800bed <strtol+0xe>
  800bf7:	3c 09                	cmp    $0x9,%al
  800bf9:	74 f2                	je     800bed <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bfb:	3c 2b                	cmp    $0x2b,%al
  800bfd:	75 0a                	jne    800c09 <strtol+0x2a>
		s++;
  800bff:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c02:	bf 00 00 00 00       	mov    $0x0,%edi
  800c07:	eb 11                	jmp    800c1a <strtol+0x3b>
  800c09:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c0e:	3c 2d                	cmp    $0x2d,%al
  800c10:	75 08                	jne    800c1a <strtol+0x3b>
		s++, neg = 1;
  800c12:	83 c1 01             	add    $0x1,%ecx
  800c15:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c1a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c20:	75 15                	jne    800c37 <strtol+0x58>
  800c22:	80 39 30             	cmpb   $0x30,(%ecx)
  800c25:	75 10                	jne    800c37 <strtol+0x58>
  800c27:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c2b:	75 7c                	jne    800ca9 <strtol+0xca>
		s += 2, base = 16;
  800c2d:	83 c1 02             	add    $0x2,%ecx
  800c30:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c35:	eb 16                	jmp    800c4d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c37:	85 db                	test   %ebx,%ebx
  800c39:	75 12                	jne    800c4d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c3b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c40:	80 39 30             	cmpb   $0x30,(%ecx)
  800c43:	75 08                	jne    800c4d <strtol+0x6e>
		s++, base = 8;
  800c45:	83 c1 01             	add    $0x1,%ecx
  800c48:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c52:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c55:	0f b6 11             	movzbl (%ecx),%edx
  800c58:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c5b:	89 f3                	mov    %esi,%ebx
  800c5d:	80 fb 09             	cmp    $0x9,%bl
  800c60:	77 08                	ja     800c6a <strtol+0x8b>
			dig = *s - '0';
  800c62:	0f be d2             	movsbl %dl,%edx
  800c65:	83 ea 30             	sub    $0x30,%edx
  800c68:	eb 22                	jmp    800c8c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c6a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c6d:	89 f3                	mov    %esi,%ebx
  800c6f:	80 fb 19             	cmp    $0x19,%bl
  800c72:	77 08                	ja     800c7c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c74:	0f be d2             	movsbl %dl,%edx
  800c77:	83 ea 57             	sub    $0x57,%edx
  800c7a:	eb 10                	jmp    800c8c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c7c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c7f:	89 f3                	mov    %esi,%ebx
  800c81:	80 fb 19             	cmp    $0x19,%bl
  800c84:	77 16                	ja     800c9c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c86:	0f be d2             	movsbl %dl,%edx
  800c89:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c8c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c8f:	7d 0b                	jge    800c9c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c91:	83 c1 01             	add    $0x1,%ecx
  800c94:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c98:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c9a:	eb b9                	jmp    800c55 <strtol+0x76>

	if (endptr)
  800c9c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ca0:	74 0d                	je     800caf <strtol+0xd0>
		*endptr = (char *) s;
  800ca2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca5:	89 0e                	mov    %ecx,(%esi)
  800ca7:	eb 06                	jmp    800caf <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca9:	85 db                	test   %ebx,%ebx
  800cab:	74 98                	je     800c45 <strtol+0x66>
  800cad:	eb 9e                	jmp    800c4d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800caf:	89 c2                	mov    %eax,%edx
  800cb1:	f7 da                	neg    %edx
  800cb3:	85 ff                	test   %edi,%edi
  800cb5:	0f 45 c2             	cmovne %edx,%eax
}
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    
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
