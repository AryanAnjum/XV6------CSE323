
user/_mlfqdemo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <spin>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

// Simple spin loop to consume CPU
void spin(int count) {
   0:	1101                	addi	sp,sp,-32
   2:	ec22                	sd	s0,24(sp)
   4:	1000                	addi	s0,sp,32
    int i;
    volatile int x = 0;
   6:	fe042623          	sw	zero,-20(s0)
    for (i = 0; i < count; i++) {
   a:	00a05b63          	blez	a0,20 <spin+0x20>
   e:	4701                	li	a4,0
        x = x + 1; 
  10:	fec42783          	lw	a5,-20(s0)
  14:	2785                	addiw	a5,a5,1
  16:	fef42623          	sw	a5,-20(s0)
    for (i = 0; i < count; i++) {
  1a:	2705                	addiw	a4,a4,1
  1c:	fee51ae3          	bne	a0,a4,10 <spin+0x10>
    }
}
  20:	6462                	ld	s0,24(sp)
  22:	6105                	addi	sp,sp,32
  24:	8082                	ret

0000000000000026 <cpu_bound>:

void cpu_bound() {
  26:	1101                	addi	sp,sp,-32
  28:	ec06                	sd	ra,24(sp)
  2a:	e822                	sd	s0,16(sp)
  2c:	e426                	sd	s1,8(sp)
  2e:	1000                	addi	s0,sp,32
    int pid = getpid();
  30:	434000ef          	jal	464 <getpid>
  34:	85aa                	mv	a1,a0
    printf("CPU-Bound process (PID %d) started. Should drop to Priority 2.\n", pid);
  36:	00001517          	auipc	a0,0x1
  3a:	99a50513          	addi	a0,a0,-1638 # 9d0 <malloc+0x100>
  3e:	7de000ef          	jal	81c <printf>
    
    // Just spin forever
    while (1) {
        spin(1000000);
  42:	000f44b7          	lui	s1,0xf4
  46:	24048493          	addi	s1,s1,576 # f4240 <base+0xf3230>
  4a:	8526                	mv	a0,s1
  4c:	fb5ff0ef          	jal	0 <spin>
    while (1) {
  50:	bfed                	j	4a <cpu_bound+0x24>

0000000000000052 <io_bound>:
    }
}

void io_bound() {
  52:	1101                	addi	sp,sp,-32
  54:	ec06                	sd	ra,24(sp)
  56:	e822                	sd	s0,16(sp)
  58:	e426                	sd	s1,8(sp)
  5a:	1000                	addi	s0,sp,32
    int pid = getpid();
  5c:	408000ef          	jal	464 <getpid>
  60:	85aa                	mv	a1,a0
    printf("I/O-Bound process (PID %d) started. Should stay High Priority (0/1).\n", pid);
  62:	00001517          	auipc	a0,0x1
  66:	9ae50513          	addi	a0,a0,-1618 # a10 <malloc+0x140>
  6a:	7b2000ef          	jal	81c <printf>
    while (1) {
        // Sleep for a bit (simulating waiting for IO)
        sleep(1);
        
        // Do a TINY bit of work
        spin(20000000); // 20 million (was 100)
  6e:	013134b7          	lui	s1,0x1313
  72:	d0048493          	addi	s1,s1,-768 # 1312d00 <base+0x1311cf0>
        sleep(1);
  76:	4505                	li	a0,1
  78:	40c000ef          	jal	484 <sleep>
        spin(20000000); // 20 million (was 100)
  7c:	8526                	mv	a0,s1
  7e:	f83ff0ef          	jal	0 <spin>
    while (1) {
  82:	bfd5                	j	76 <io_bound+0x24>

0000000000000084 <mixed_workload>:
    }
}

void mixed_workload() {
  84:	1101                	addi	sp,sp,-32
  86:	ec06                	sd	ra,24(sp)
  88:	e822                	sd	s0,16(sp)
  8a:	e426                	sd	s1,8(sp)
  8c:	1000                	addi	s0,sp,32
    int pid = getpid();
  8e:	3d6000ef          	jal	464 <getpid>
  92:	85aa                	mv	a1,a0
    printf("Mixed Process (PID %d) started. Should oscillate.\n", pid);
  94:	00001517          	auipc	a0,0x1
  98:	9cc50513          	addi	a0,a0,-1588 # a60 <malloc+0x190>
  9c:	780000ef          	jal	81c <printf>
    
    while (1) {
        // Burst of CPU
        spin(500000000); // 500 million (was 5 million)
  a0:	1dcd64b7          	lui	s1,0x1dcd6
  a4:	50048493          	addi	s1,s1,1280 # 1dcd6500 <base+0x1dcd54f0>
  a8:	8526                	mv	a0,s1
  aa:	f57ff0ef          	jal	0 <spin>
        
        // Then sleep
        sleep(10);
  ae:	4529                	li	a0,10
  b0:	3d4000ef          	jal	484 <sleep>
    while (1) {
  b4:	bfd5                	j	a8 <mixed_workload+0x24>

00000000000000b6 <main>:
    }
}

int main(int argc, char *argv[]) {
  b6:	1101                	addi	sp,sp,-32
  b8:	ec06                	sd	ra,24(sp)
  ba:	e822                	sd	s0,16(sp)
  bc:	1000                	addi	s0,sp,32
    int pid;

    printf("MLFQ Demo Starting...\n");
  be:	00001517          	auipc	a0,0x1
  c2:	9da50513          	addi	a0,a0,-1574 # a98 <malloc+0x1c8>
  c6:	756000ef          	jal	81c <printf>
    printf("Use user/spin.c logic to stress test.\n");
  ca:	00001517          	auipc	a0,0x1
  ce:	9e650513          	addi	a0,a0,-1562 # ab0 <malloc+0x1e0>
  d2:	74a000ef          	jal	81c <printf>

    // 1. Create CPU Bound
    pid = fork();
  d6:	306000ef          	jal	3dc <fork>
    if (pid < 0) {
  da:	00054663          	bltz	a0,e6 <main+0x30>
        printf("Fork failed\n");
        exit(1);
    }
    if (pid == 0) {
  de:	ed11                	bnez	a0,fa <main+0x44>
  e0:	e426                	sd	s1,8(sp)
        cpu_bound();
  e2:	f45ff0ef          	jal	26 <cpu_bound>
  e6:	e426                	sd	s1,8(sp)
        printf("Fork failed\n");
  e8:	00001517          	auipc	a0,0x1
  ec:	9f050513          	addi	a0,a0,-1552 # ad8 <malloc+0x208>
  f0:	72c000ef          	jal	81c <printf>
        exit(1);
  f4:	4505                	li	a0,1
  f6:	2ee000ef          	jal	3e4 <exit>
        exit(0);
    }

    // 2. Create I/O Bound
    pid = fork();
  fa:	2e2000ef          	jal	3dc <fork>
    if (pid < 0) {
  fe:	00054663          	bltz	a0,10a <main+0x54>
 102:	e426                	sd	s1,8(sp)
        printf("Fork failed\n");
        exit(1);
    }
    if (pid == 0) {
 104:	ed09                	bnez	a0,11e <main+0x68>
        io_bound();
 106:	f4dff0ef          	jal	52 <io_bound>
 10a:	e426                	sd	s1,8(sp)
        printf("Fork failed\n");
 10c:	00001517          	auipc	a0,0x1
 110:	9cc50513          	addi	a0,a0,-1588 # ad8 <malloc+0x208>
 114:	708000ef          	jal	81c <printf>
        exit(1);
 118:	4505                	li	a0,1
 11a:	2ca000ef          	jal	3e4 <exit>
        exit(0);
    }

    // 3. Create Mixed
    pid = fork();
 11e:	2be000ef          	jal	3dc <fork>
    if (pid < 0) {
 122:	00054c63          	bltz	a0,13a <main+0x84>
        mixed_workload();
        exit(0);
    }
    
    // Parent just waits
    while(wait(0) != -1);
 126:	54fd                	li	s1,-1
    if (pid == 0) {
 128:	c115                	beqz	a0,14c <main+0x96>
    while(wait(0) != -1);
 12a:	4501                	li	a0,0
 12c:	2c0000ef          	jal	3ec <wait>
 130:	fe951de3          	bne	a0,s1,12a <main+0x74>

    exit(0);
 134:	4501                	li	a0,0
 136:	2ae000ef          	jal	3e4 <exit>
        printf("Fork failed\n");
 13a:	00001517          	auipc	a0,0x1
 13e:	99e50513          	addi	a0,a0,-1634 # ad8 <malloc+0x208>
 142:	6da000ef          	jal	81c <printf>
        exit(1);
 146:	4505                	li	a0,1
 148:	29c000ef          	jal	3e4 <exit>
        mixed_workload();
 14c:	f39ff0ef          	jal	84 <mixed_workload>

0000000000000150 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 150:	1141                	addi	sp,sp,-16
 152:	e406                	sd	ra,8(sp)
 154:	e022                	sd	s0,0(sp)
 156:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 158:	f5fff0ef          	jal	b6 <main>
  exit(r);
 15c:	288000ef          	jal	3e4 <exit>

0000000000000160 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 160:	1141                	addi	sp,sp,-16
 162:	e422                	sd	s0,8(sp)
 164:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 166:	87aa                	mv	a5,a0
 168:	0585                	addi	a1,a1,1
 16a:	0785                	addi	a5,a5,1
 16c:	fff5c703          	lbu	a4,-1(a1)
 170:	fee78fa3          	sb	a4,-1(a5)
 174:	fb75                	bnez	a4,168 <strcpy+0x8>
    ;
  return os;
}
 176:	6422                	ld	s0,8(sp)
 178:	0141                	addi	sp,sp,16
 17a:	8082                	ret

000000000000017c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 17c:	1141                	addi	sp,sp,-16
 17e:	e422                	sd	s0,8(sp)
 180:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 182:	00054783          	lbu	a5,0(a0)
 186:	cb91                	beqz	a5,19a <strcmp+0x1e>
 188:	0005c703          	lbu	a4,0(a1)
 18c:	00f71763          	bne	a4,a5,19a <strcmp+0x1e>
    p++, q++;
 190:	0505                	addi	a0,a0,1
 192:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 194:	00054783          	lbu	a5,0(a0)
 198:	fbe5                	bnez	a5,188 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 19a:	0005c503          	lbu	a0,0(a1)
}
 19e:	40a7853b          	subw	a0,a5,a0
 1a2:	6422                	ld	s0,8(sp)
 1a4:	0141                	addi	sp,sp,16
 1a6:	8082                	ret

00000000000001a8 <strlen>:

uint
strlen(const char *s)
{
 1a8:	1141                	addi	sp,sp,-16
 1aa:	e422                	sd	s0,8(sp)
 1ac:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1ae:	00054783          	lbu	a5,0(a0)
 1b2:	cf91                	beqz	a5,1ce <strlen+0x26>
 1b4:	0505                	addi	a0,a0,1
 1b6:	87aa                	mv	a5,a0
 1b8:	86be                	mv	a3,a5
 1ba:	0785                	addi	a5,a5,1
 1bc:	fff7c703          	lbu	a4,-1(a5)
 1c0:	ff65                	bnez	a4,1b8 <strlen+0x10>
 1c2:	40a6853b          	subw	a0,a3,a0
 1c6:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1c8:	6422                	ld	s0,8(sp)
 1ca:	0141                	addi	sp,sp,16
 1cc:	8082                	ret
  for(n = 0; s[n]; n++)
 1ce:	4501                	li	a0,0
 1d0:	bfe5                	j	1c8 <strlen+0x20>

00000000000001d2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1d2:	1141                	addi	sp,sp,-16
 1d4:	e422                	sd	s0,8(sp)
 1d6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1d8:	ca19                	beqz	a2,1ee <memset+0x1c>
 1da:	87aa                	mv	a5,a0
 1dc:	1602                	slli	a2,a2,0x20
 1de:	9201                	srli	a2,a2,0x20
 1e0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1e4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1e8:	0785                	addi	a5,a5,1
 1ea:	fee79de3          	bne	a5,a4,1e4 <memset+0x12>
  }
  return dst;
}
 1ee:	6422                	ld	s0,8(sp)
 1f0:	0141                	addi	sp,sp,16
 1f2:	8082                	ret

00000000000001f4 <strchr>:

char*
strchr(const char *s, char c)
{
 1f4:	1141                	addi	sp,sp,-16
 1f6:	e422                	sd	s0,8(sp)
 1f8:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1fa:	00054783          	lbu	a5,0(a0)
 1fe:	cb99                	beqz	a5,214 <strchr+0x20>
    if(*s == c)
 200:	00f58763          	beq	a1,a5,20e <strchr+0x1a>
  for(; *s; s++)
 204:	0505                	addi	a0,a0,1
 206:	00054783          	lbu	a5,0(a0)
 20a:	fbfd                	bnez	a5,200 <strchr+0xc>
      return (char*)s;
  return 0;
 20c:	4501                	li	a0,0
}
 20e:	6422                	ld	s0,8(sp)
 210:	0141                	addi	sp,sp,16
 212:	8082                	ret
  return 0;
 214:	4501                	li	a0,0
 216:	bfe5                	j	20e <strchr+0x1a>

0000000000000218 <gets>:

char*
gets(char *buf, int max)
{
 218:	711d                	addi	sp,sp,-96
 21a:	ec86                	sd	ra,88(sp)
 21c:	e8a2                	sd	s0,80(sp)
 21e:	e4a6                	sd	s1,72(sp)
 220:	e0ca                	sd	s2,64(sp)
 222:	fc4e                	sd	s3,56(sp)
 224:	f852                	sd	s4,48(sp)
 226:	f456                	sd	s5,40(sp)
 228:	f05a                	sd	s6,32(sp)
 22a:	ec5e                	sd	s7,24(sp)
 22c:	1080                	addi	s0,sp,96
 22e:	8baa                	mv	s7,a0
 230:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 232:	892a                	mv	s2,a0
 234:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 236:	4aa9                	li	s5,10
 238:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 23a:	89a6                	mv	s3,s1
 23c:	2485                	addiw	s1,s1,1
 23e:	0344d663          	bge	s1,s4,26a <gets+0x52>
    cc = read(0, &c, 1);
 242:	4605                	li	a2,1
 244:	faf40593          	addi	a1,s0,-81
 248:	4501                	li	a0,0
 24a:	1b2000ef          	jal	3fc <read>
    if(cc < 1)
 24e:	00a05e63          	blez	a0,26a <gets+0x52>
    buf[i++] = c;
 252:	faf44783          	lbu	a5,-81(s0)
 256:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 25a:	01578763          	beq	a5,s5,268 <gets+0x50>
 25e:	0905                	addi	s2,s2,1
 260:	fd679de3          	bne	a5,s6,23a <gets+0x22>
    buf[i++] = c;
 264:	89a6                	mv	s3,s1
 266:	a011                	j	26a <gets+0x52>
 268:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 26a:	99de                	add	s3,s3,s7
 26c:	00098023          	sb	zero,0(s3)
  return buf;
}
 270:	855e                	mv	a0,s7
 272:	60e6                	ld	ra,88(sp)
 274:	6446                	ld	s0,80(sp)
 276:	64a6                	ld	s1,72(sp)
 278:	6906                	ld	s2,64(sp)
 27a:	79e2                	ld	s3,56(sp)
 27c:	7a42                	ld	s4,48(sp)
 27e:	7aa2                	ld	s5,40(sp)
 280:	7b02                	ld	s6,32(sp)
 282:	6be2                	ld	s7,24(sp)
 284:	6125                	addi	sp,sp,96
 286:	8082                	ret

0000000000000288 <stat>:

int
stat(const char *n, struct stat *st)
{
 288:	1101                	addi	sp,sp,-32
 28a:	ec06                	sd	ra,24(sp)
 28c:	e822                	sd	s0,16(sp)
 28e:	e04a                	sd	s2,0(sp)
 290:	1000                	addi	s0,sp,32
 292:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 294:	4581                	li	a1,0
 296:	18e000ef          	jal	424 <open>
  if(fd < 0)
 29a:	02054263          	bltz	a0,2be <stat+0x36>
 29e:	e426                	sd	s1,8(sp)
 2a0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2a2:	85ca                	mv	a1,s2
 2a4:	198000ef          	jal	43c <fstat>
 2a8:	892a                	mv	s2,a0
  close(fd);
 2aa:	8526                	mv	a0,s1
 2ac:	160000ef          	jal	40c <close>
  return r;
 2b0:	64a2                	ld	s1,8(sp)
}
 2b2:	854a                	mv	a0,s2
 2b4:	60e2                	ld	ra,24(sp)
 2b6:	6442                	ld	s0,16(sp)
 2b8:	6902                	ld	s2,0(sp)
 2ba:	6105                	addi	sp,sp,32
 2bc:	8082                	ret
    return -1;
 2be:	597d                	li	s2,-1
 2c0:	bfcd                	j	2b2 <stat+0x2a>

00000000000002c2 <atoi>:

int
atoi(const char *s)
{
 2c2:	1141                	addi	sp,sp,-16
 2c4:	e422                	sd	s0,8(sp)
 2c6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2c8:	00054683          	lbu	a3,0(a0)
 2cc:	fd06879b          	addiw	a5,a3,-48
 2d0:	0ff7f793          	zext.b	a5,a5
 2d4:	4625                	li	a2,9
 2d6:	02f66863          	bltu	a2,a5,306 <atoi+0x44>
 2da:	872a                	mv	a4,a0
  n = 0;
 2dc:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2de:	0705                	addi	a4,a4,1
 2e0:	0025179b          	slliw	a5,a0,0x2
 2e4:	9fa9                	addw	a5,a5,a0
 2e6:	0017979b          	slliw	a5,a5,0x1
 2ea:	9fb5                	addw	a5,a5,a3
 2ec:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2f0:	00074683          	lbu	a3,0(a4)
 2f4:	fd06879b          	addiw	a5,a3,-48
 2f8:	0ff7f793          	zext.b	a5,a5
 2fc:	fef671e3          	bgeu	a2,a5,2de <atoi+0x1c>
  return n;
}
 300:	6422                	ld	s0,8(sp)
 302:	0141                	addi	sp,sp,16
 304:	8082                	ret
  n = 0;
 306:	4501                	li	a0,0
 308:	bfe5                	j	300 <atoi+0x3e>

000000000000030a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 30a:	1141                	addi	sp,sp,-16
 30c:	e422                	sd	s0,8(sp)
 30e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 310:	02b57463          	bgeu	a0,a1,338 <memmove+0x2e>
    while(n-- > 0)
 314:	00c05f63          	blez	a2,332 <memmove+0x28>
 318:	1602                	slli	a2,a2,0x20
 31a:	9201                	srli	a2,a2,0x20
 31c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 320:	872a                	mv	a4,a0
      *dst++ = *src++;
 322:	0585                	addi	a1,a1,1
 324:	0705                	addi	a4,a4,1
 326:	fff5c683          	lbu	a3,-1(a1)
 32a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 32e:	fef71ae3          	bne	a4,a5,322 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 332:	6422                	ld	s0,8(sp)
 334:	0141                	addi	sp,sp,16
 336:	8082                	ret
    dst += n;
 338:	00c50733          	add	a4,a0,a2
    src += n;
 33c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 33e:	fec05ae3          	blez	a2,332 <memmove+0x28>
 342:	fff6079b          	addiw	a5,a2,-1
 346:	1782                	slli	a5,a5,0x20
 348:	9381                	srli	a5,a5,0x20
 34a:	fff7c793          	not	a5,a5
 34e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 350:	15fd                	addi	a1,a1,-1
 352:	177d                	addi	a4,a4,-1
 354:	0005c683          	lbu	a3,0(a1)
 358:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 35c:	fee79ae3          	bne	a5,a4,350 <memmove+0x46>
 360:	bfc9                	j	332 <memmove+0x28>

0000000000000362 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 362:	1141                	addi	sp,sp,-16
 364:	e422                	sd	s0,8(sp)
 366:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 368:	ca05                	beqz	a2,398 <memcmp+0x36>
 36a:	fff6069b          	addiw	a3,a2,-1
 36e:	1682                	slli	a3,a3,0x20
 370:	9281                	srli	a3,a3,0x20
 372:	0685                	addi	a3,a3,1
 374:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 376:	00054783          	lbu	a5,0(a0)
 37a:	0005c703          	lbu	a4,0(a1)
 37e:	00e79863          	bne	a5,a4,38e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 382:	0505                	addi	a0,a0,1
    p2++;
 384:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 386:	fed518e3          	bne	a0,a3,376 <memcmp+0x14>
  }
  return 0;
 38a:	4501                	li	a0,0
 38c:	a019                	j	392 <memcmp+0x30>
      return *p1 - *p2;
 38e:	40e7853b          	subw	a0,a5,a4
}
 392:	6422                	ld	s0,8(sp)
 394:	0141                	addi	sp,sp,16
 396:	8082                	ret
  return 0;
 398:	4501                	li	a0,0
 39a:	bfe5                	j	392 <memcmp+0x30>

000000000000039c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 39c:	1141                	addi	sp,sp,-16
 39e:	e406                	sd	ra,8(sp)
 3a0:	e022                	sd	s0,0(sp)
 3a2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3a4:	f67ff0ef          	jal	30a <memmove>
}
 3a8:	60a2                	ld	ra,8(sp)
 3aa:	6402                	ld	s0,0(sp)
 3ac:	0141                	addi	sp,sp,16
 3ae:	8082                	ret

00000000000003b0 <sbrk>:

char *
sbrk(int n) {
 3b0:	1141                	addi	sp,sp,-16
 3b2:	e406                	sd	ra,8(sp)
 3b4:	e022                	sd	s0,0(sp)
 3b6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3b8:	4585                	li	a1,1
 3ba:	0b2000ef          	jal	46c <sys_sbrk>
}
 3be:	60a2                	ld	ra,8(sp)
 3c0:	6402                	ld	s0,0(sp)
 3c2:	0141                	addi	sp,sp,16
 3c4:	8082                	ret

00000000000003c6 <sbrklazy>:

char *
sbrklazy(int n) {
 3c6:	1141                	addi	sp,sp,-16
 3c8:	e406                	sd	ra,8(sp)
 3ca:	e022                	sd	s0,0(sp)
 3cc:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3ce:	4589                	li	a1,2
 3d0:	09c000ef          	jal	46c <sys_sbrk>
}
 3d4:	60a2                	ld	ra,8(sp)
 3d6:	6402                	ld	s0,0(sp)
 3d8:	0141                	addi	sp,sp,16
 3da:	8082                	ret

00000000000003dc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3dc:	4885                	li	a7,1
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3e4:	4889                	li	a7,2
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <wait>:
.global wait
wait:
 li a7, SYS_wait
 3ec:	488d                	li	a7,3
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3f4:	4891                	li	a7,4
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <read>:
.global read
read:
 li a7, SYS_read
 3fc:	4895                	li	a7,5
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <write>:
.global write
write:
 li a7, SYS_write
 404:	48c1                	li	a7,16
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <close>:
.global close
close:
 li a7, SYS_close
 40c:	48d5                	li	a7,21
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <kill>:
.global kill
kill:
 li a7, SYS_kill
 414:	4899                	li	a7,6
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <exec>:
.global exec
exec:
 li a7, SYS_exec
 41c:	489d                	li	a7,7
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <open>:
.global open
open:
 li a7, SYS_open
 424:	48bd                	li	a7,15
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 42c:	48c5                	li	a7,17
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 434:	48c9                	li	a7,18
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 43c:	48a1                	li	a7,8
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <link>:
.global link
link:
 li a7, SYS_link
 444:	48cd                	li	a7,19
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 44c:	48d1                	li	a7,20
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 454:	48a5                	li	a7,9
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <dup>:
.global dup
dup:
 li a7, SYS_dup
 45c:	48a9                	li	a7,10
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 464:	48ad                	li	a7,11
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 46c:	48b1                	li	a7,12
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <pause>:
.global pause
pause:
 li a7, SYS_pause
 474:	48b5                	li	a7,13
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 47c:	48b9                	li	a7,14
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 484:	48d9                	li	a7,22
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <freemem>:
.global freemem
freemem:
 li a7, SYS_freemem
 48c:	48dd                	li	a7,23
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 494:	1101                	addi	sp,sp,-32
 496:	ec06                	sd	ra,24(sp)
 498:	e822                	sd	s0,16(sp)
 49a:	1000                	addi	s0,sp,32
 49c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4a0:	4605                	li	a2,1
 4a2:	fef40593          	addi	a1,s0,-17
 4a6:	f5fff0ef          	jal	404 <write>
}
 4aa:	60e2                	ld	ra,24(sp)
 4ac:	6442                	ld	s0,16(sp)
 4ae:	6105                	addi	sp,sp,32
 4b0:	8082                	ret

00000000000004b2 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4b2:	715d                	addi	sp,sp,-80
 4b4:	e486                	sd	ra,72(sp)
 4b6:	e0a2                	sd	s0,64(sp)
 4b8:	f84a                	sd	s2,48(sp)
 4ba:	0880                	addi	s0,sp,80
 4bc:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4be:	c299                	beqz	a3,4c4 <printint+0x12>
 4c0:	0805c363          	bltz	a1,546 <printint+0x94>
  neg = 0;
 4c4:	4881                	li	a7,0
 4c6:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4ca:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4cc:	00000517          	auipc	a0,0x0
 4d0:	62450513          	addi	a0,a0,1572 # af0 <digits>
 4d4:	883e                	mv	a6,a5
 4d6:	2785                	addiw	a5,a5,1
 4d8:	02c5f733          	remu	a4,a1,a2
 4dc:	972a                	add	a4,a4,a0
 4de:	00074703          	lbu	a4,0(a4)
 4e2:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4e6:	872e                	mv	a4,a1
 4e8:	02c5d5b3          	divu	a1,a1,a2
 4ec:	0685                	addi	a3,a3,1
 4ee:	fec773e3          	bgeu	a4,a2,4d4 <printint+0x22>
  if(neg)
 4f2:	00088b63          	beqz	a7,508 <printint+0x56>
    buf[i++] = '-';
 4f6:	fd078793          	addi	a5,a5,-48
 4fa:	97a2                	add	a5,a5,s0
 4fc:	02d00713          	li	a4,45
 500:	fee78423          	sb	a4,-24(a5)
 504:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 508:	02f05a63          	blez	a5,53c <printint+0x8a>
 50c:	fc26                	sd	s1,56(sp)
 50e:	f44e                	sd	s3,40(sp)
 510:	fb840713          	addi	a4,s0,-72
 514:	00f704b3          	add	s1,a4,a5
 518:	fff70993          	addi	s3,a4,-1
 51c:	99be                	add	s3,s3,a5
 51e:	37fd                	addiw	a5,a5,-1
 520:	1782                	slli	a5,a5,0x20
 522:	9381                	srli	a5,a5,0x20
 524:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 528:	fff4c583          	lbu	a1,-1(s1)
 52c:	854a                	mv	a0,s2
 52e:	f67ff0ef          	jal	494 <putc>
  while(--i >= 0)
 532:	14fd                	addi	s1,s1,-1
 534:	ff349ae3          	bne	s1,s3,528 <printint+0x76>
 538:	74e2                	ld	s1,56(sp)
 53a:	79a2                	ld	s3,40(sp)
}
 53c:	60a6                	ld	ra,72(sp)
 53e:	6406                	ld	s0,64(sp)
 540:	7942                	ld	s2,48(sp)
 542:	6161                	addi	sp,sp,80
 544:	8082                	ret
    x = -xx;
 546:	40b005b3          	neg	a1,a1
    neg = 1;
 54a:	4885                	li	a7,1
    x = -xx;
 54c:	bfad                	j	4c6 <printint+0x14>

000000000000054e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 54e:	711d                	addi	sp,sp,-96
 550:	ec86                	sd	ra,88(sp)
 552:	e8a2                	sd	s0,80(sp)
 554:	e0ca                	sd	s2,64(sp)
 556:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 558:	0005c903          	lbu	s2,0(a1)
 55c:	28090663          	beqz	s2,7e8 <vprintf+0x29a>
 560:	e4a6                	sd	s1,72(sp)
 562:	fc4e                	sd	s3,56(sp)
 564:	f852                	sd	s4,48(sp)
 566:	f456                	sd	s5,40(sp)
 568:	f05a                	sd	s6,32(sp)
 56a:	ec5e                	sd	s7,24(sp)
 56c:	e862                	sd	s8,16(sp)
 56e:	e466                	sd	s9,8(sp)
 570:	8b2a                	mv	s6,a0
 572:	8a2e                	mv	s4,a1
 574:	8bb2                	mv	s7,a2
  state = 0;
 576:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 578:	4481                	li	s1,0
 57a:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 57c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 580:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 584:	06c00c93          	li	s9,108
 588:	a005                	j	5a8 <vprintf+0x5a>
        putc(fd, c0);
 58a:	85ca                	mv	a1,s2
 58c:	855a                	mv	a0,s6
 58e:	f07ff0ef          	jal	494 <putc>
 592:	a019                	j	598 <vprintf+0x4a>
    } else if(state == '%'){
 594:	03598263          	beq	s3,s5,5b8 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 598:	2485                	addiw	s1,s1,1
 59a:	8726                	mv	a4,s1
 59c:	009a07b3          	add	a5,s4,s1
 5a0:	0007c903          	lbu	s2,0(a5)
 5a4:	22090a63          	beqz	s2,7d8 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 5a8:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5ac:	fe0994e3          	bnez	s3,594 <vprintf+0x46>
      if(c0 == '%'){
 5b0:	fd579de3          	bne	a5,s5,58a <vprintf+0x3c>
        state = '%';
 5b4:	89be                	mv	s3,a5
 5b6:	b7cd                	j	598 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5b8:	00ea06b3          	add	a3,s4,a4
 5bc:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5c0:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5c2:	c681                	beqz	a3,5ca <vprintf+0x7c>
 5c4:	9752                	add	a4,a4,s4
 5c6:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5ca:	05878363          	beq	a5,s8,610 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 5ce:	05978d63          	beq	a5,s9,628 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5d2:	07500713          	li	a4,117
 5d6:	0ee78763          	beq	a5,a4,6c4 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5da:	07800713          	li	a4,120
 5de:	12e78963          	beq	a5,a4,710 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5e2:	07000713          	li	a4,112
 5e6:	14e78e63          	beq	a5,a4,742 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5ea:	06300713          	li	a4,99
 5ee:	18e78e63          	beq	a5,a4,78a <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5f2:	07300713          	li	a4,115
 5f6:	1ae78463          	beq	a5,a4,79e <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5fa:	02500713          	li	a4,37
 5fe:	04e79563          	bne	a5,a4,648 <vprintf+0xfa>
        putc(fd, '%');
 602:	02500593          	li	a1,37
 606:	855a                	mv	a0,s6
 608:	e8dff0ef          	jal	494 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 60c:	4981                	li	s3,0
 60e:	b769                	j	598 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 610:	008b8913          	addi	s2,s7,8
 614:	4685                	li	a3,1
 616:	4629                	li	a2,10
 618:	000ba583          	lw	a1,0(s7)
 61c:	855a                	mv	a0,s6
 61e:	e95ff0ef          	jal	4b2 <printint>
 622:	8bca                	mv	s7,s2
      state = 0;
 624:	4981                	li	s3,0
 626:	bf8d                	j	598 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 628:	06400793          	li	a5,100
 62c:	02f68963          	beq	a3,a5,65e <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 630:	06c00793          	li	a5,108
 634:	04f68263          	beq	a3,a5,678 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 638:	07500793          	li	a5,117
 63c:	0af68063          	beq	a3,a5,6dc <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 640:	07800793          	li	a5,120
 644:	0ef68263          	beq	a3,a5,728 <vprintf+0x1da>
        putc(fd, '%');
 648:	02500593          	li	a1,37
 64c:	855a                	mv	a0,s6
 64e:	e47ff0ef          	jal	494 <putc>
        putc(fd, c0);
 652:	85ca                	mv	a1,s2
 654:	855a                	mv	a0,s6
 656:	e3fff0ef          	jal	494 <putc>
      state = 0;
 65a:	4981                	li	s3,0
 65c:	bf35                	j	598 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 65e:	008b8913          	addi	s2,s7,8
 662:	4685                	li	a3,1
 664:	4629                	li	a2,10
 666:	000bb583          	ld	a1,0(s7)
 66a:	855a                	mv	a0,s6
 66c:	e47ff0ef          	jal	4b2 <printint>
        i += 1;
 670:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 672:	8bca                	mv	s7,s2
      state = 0;
 674:	4981                	li	s3,0
        i += 1;
 676:	b70d                	j	598 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 678:	06400793          	li	a5,100
 67c:	02f60763          	beq	a2,a5,6aa <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 680:	07500793          	li	a5,117
 684:	06f60963          	beq	a2,a5,6f6 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 688:	07800793          	li	a5,120
 68c:	faf61ee3          	bne	a2,a5,648 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 690:	008b8913          	addi	s2,s7,8
 694:	4681                	li	a3,0
 696:	4641                	li	a2,16
 698:	000bb583          	ld	a1,0(s7)
 69c:	855a                	mv	a0,s6
 69e:	e15ff0ef          	jal	4b2 <printint>
        i += 2;
 6a2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a4:	8bca                	mv	s7,s2
      state = 0;
 6a6:	4981                	li	s3,0
        i += 2;
 6a8:	bdc5                	j	598 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6aa:	008b8913          	addi	s2,s7,8
 6ae:	4685                	li	a3,1
 6b0:	4629                	li	a2,10
 6b2:	000bb583          	ld	a1,0(s7)
 6b6:	855a                	mv	a0,s6
 6b8:	dfbff0ef          	jal	4b2 <printint>
        i += 2;
 6bc:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6be:	8bca                	mv	s7,s2
      state = 0;
 6c0:	4981                	li	s3,0
        i += 2;
 6c2:	bdd9                	j	598 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6c4:	008b8913          	addi	s2,s7,8
 6c8:	4681                	li	a3,0
 6ca:	4629                	li	a2,10
 6cc:	000be583          	lwu	a1,0(s7)
 6d0:	855a                	mv	a0,s6
 6d2:	de1ff0ef          	jal	4b2 <printint>
 6d6:	8bca                	mv	s7,s2
      state = 0;
 6d8:	4981                	li	s3,0
 6da:	bd7d                	j	598 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6dc:	008b8913          	addi	s2,s7,8
 6e0:	4681                	li	a3,0
 6e2:	4629                	li	a2,10
 6e4:	000bb583          	ld	a1,0(s7)
 6e8:	855a                	mv	a0,s6
 6ea:	dc9ff0ef          	jal	4b2 <printint>
        i += 1;
 6ee:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f0:	8bca                	mv	s7,s2
      state = 0;
 6f2:	4981                	li	s3,0
        i += 1;
 6f4:	b555                	j	598 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f6:	008b8913          	addi	s2,s7,8
 6fa:	4681                	li	a3,0
 6fc:	4629                	li	a2,10
 6fe:	000bb583          	ld	a1,0(s7)
 702:	855a                	mv	a0,s6
 704:	dafff0ef          	jal	4b2 <printint>
        i += 2;
 708:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 70a:	8bca                	mv	s7,s2
      state = 0;
 70c:	4981                	li	s3,0
        i += 2;
 70e:	b569                	j	598 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 710:	008b8913          	addi	s2,s7,8
 714:	4681                	li	a3,0
 716:	4641                	li	a2,16
 718:	000be583          	lwu	a1,0(s7)
 71c:	855a                	mv	a0,s6
 71e:	d95ff0ef          	jal	4b2 <printint>
 722:	8bca                	mv	s7,s2
      state = 0;
 724:	4981                	li	s3,0
 726:	bd8d                	j	598 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 728:	008b8913          	addi	s2,s7,8
 72c:	4681                	li	a3,0
 72e:	4641                	li	a2,16
 730:	000bb583          	ld	a1,0(s7)
 734:	855a                	mv	a0,s6
 736:	d7dff0ef          	jal	4b2 <printint>
        i += 1;
 73a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 73c:	8bca                	mv	s7,s2
      state = 0;
 73e:	4981                	li	s3,0
        i += 1;
 740:	bda1                	j	598 <vprintf+0x4a>
 742:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 744:	008b8d13          	addi	s10,s7,8
 748:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 74c:	03000593          	li	a1,48
 750:	855a                	mv	a0,s6
 752:	d43ff0ef          	jal	494 <putc>
  putc(fd, 'x');
 756:	07800593          	li	a1,120
 75a:	855a                	mv	a0,s6
 75c:	d39ff0ef          	jal	494 <putc>
 760:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 762:	00000b97          	auipc	s7,0x0
 766:	38eb8b93          	addi	s7,s7,910 # af0 <digits>
 76a:	03c9d793          	srli	a5,s3,0x3c
 76e:	97de                	add	a5,a5,s7
 770:	0007c583          	lbu	a1,0(a5)
 774:	855a                	mv	a0,s6
 776:	d1fff0ef          	jal	494 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 77a:	0992                	slli	s3,s3,0x4
 77c:	397d                	addiw	s2,s2,-1
 77e:	fe0916e3          	bnez	s2,76a <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 782:	8bea                	mv	s7,s10
      state = 0;
 784:	4981                	li	s3,0
 786:	6d02                	ld	s10,0(sp)
 788:	bd01                	j	598 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 78a:	008b8913          	addi	s2,s7,8
 78e:	000bc583          	lbu	a1,0(s7)
 792:	855a                	mv	a0,s6
 794:	d01ff0ef          	jal	494 <putc>
 798:	8bca                	mv	s7,s2
      state = 0;
 79a:	4981                	li	s3,0
 79c:	bbf5                	j	598 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 79e:	008b8993          	addi	s3,s7,8
 7a2:	000bb903          	ld	s2,0(s7)
 7a6:	00090f63          	beqz	s2,7c4 <vprintf+0x276>
        for(; *s; s++)
 7aa:	00094583          	lbu	a1,0(s2)
 7ae:	c195                	beqz	a1,7d2 <vprintf+0x284>
          putc(fd, *s);
 7b0:	855a                	mv	a0,s6
 7b2:	ce3ff0ef          	jal	494 <putc>
        for(; *s; s++)
 7b6:	0905                	addi	s2,s2,1
 7b8:	00094583          	lbu	a1,0(s2)
 7bc:	f9f5                	bnez	a1,7b0 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7be:	8bce                	mv	s7,s3
      state = 0;
 7c0:	4981                	li	s3,0
 7c2:	bbd9                	j	598 <vprintf+0x4a>
          s = "(null)";
 7c4:	00000917          	auipc	s2,0x0
 7c8:	32490913          	addi	s2,s2,804 # ae8 <malloc+0x218>
        for(; *s; s++)
 7cc:	02800593          	li	a1,40
 7d0:	b7c5                	j	7b0 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7d2:	8bce                	mv	s7,s3
      state = 0;
 7d4:	4981                	li	s3,0
 7d6:	b3c9                	j	598 <vprintf+0x4a>
 7d8:	64a6                	ld	s1,72(sp)
 7da:	79e2                	ld	s3,56(sp)
 7dc:	7a42                	ld	s4,48(sp)
 7de:	7aa2                	ld	s5,40(sp)
 7e0:	7b02                	ld	s6,32(sp)
 7e2:	6be2                	ld	s7,24(sp)
 7e4:	6c42                	ld	s8,16(sp)
 7e6:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7e8:	60e6                	ld	ra,88(sp)
 7ea:	6446                	ld	s0,80(sp)
 7ec:	6906                	ld	s2,64(sp)
 7ee:	6125                	addi	sp,sp,96
 7f0:	8082                	ret

00000000000007f2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7f2:	715d                	addi	sp,sp,-80
 7f4:	ec06                	sd	ra,24(sp)
 7f6:	e822                	sd	s0,16(sp)
 7f8:	1000                	addi	s0,sp,32
 7fa:	e010                	sd	a2,0(s0)
 7fc:	e414                	sd	a3,8(s0)
 7fe:	e818                	sd	a4,16(s0)
 800:	ec1c                	sd	a5,24(s0)
 802:	03043023          	sd	a6,32(s0)
 806:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 80a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 80e:	8622                	mv	a2,s0
 810:	d3fff0ef          	jal	54e <vprintf>
}
 814:	60e2                	ld	ra,24(sp)
 816:	6442                	ld	s0,16(sp)
 818:	6161                	addi	sp,sp,80
 81a:	8082                	ret

000000000000081c <printf>:

void
printf(const char *fmt, ...)
{
 81c:	711d                	addi	sp,sp,-96
 81e:	ec06                	sd	ra,24(sp)
 820:	e822                	sd	s0,16(sp)
 822:	1000                	addi	s0,sp,32
 824:	e40c                	sd	a1,8(s0)
 826:	e810                	sd	a2,16(s0)
 828:	ec14                	sd	a3,24(s0)
 82a:	f018                	sd	a4,32(s0)
 82c:	f41c                	sd	a5,40(s0)
 82e:	03043823          	sd	a6,48(s0)
 832:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 836:	00840613          	addi	a2,s0,8
 83a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 83e:	85aa                	mv	a1,a0
 840:	4505                	li	a0,1
 842:	d0dff0ef          	jal	54e <vprintf>
}
 846:	60e2                	ld	ra,24(sp)
 848:	6442                	ld	s0,16(sp)
 84a:	6125                	addi	sp,sp,96
 84c:	8082                	ret

000000000000084e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 84e:	1141                	addi	sp,sp,-16
 850:	e422                	sd	s0,8(sp)
 852:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 854:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 858:	00000797          	auipc	a5,0x0
 85c:	7a87b783          	ld	a5,1960(a5) # 1000 <freep>
 860:	a02d                	j	88a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 862:	4618                	lw	a4,8(a2)
 864:	9f2d                	addw	a4,a4,a1
 866:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 86a:	6398                	ld	a4,0(a5)
 86c:	6310                	ld	a2,0(a4)
 86e:	a83d                	j	8ac <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 870:	ff852703          	lw	a4,-8(a0)
 874:	9f31                	addw	a4,a4,a2
 876:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 878:	ff053683          	ld	a3,-16(a0)
 87c:	a091                	j	8c0 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 87e:	6398                	ld	a4,0(a5)
 880:	00e7e463          	bltu	a5,a4,888 <free+0x3a>
 884:	00e6ea63          	bltu	a3,a4,898 <free+0x4a>
{
 888:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 88a:	fed7fae3          	bgeu	a5,a3,87e <free+0x30>
 88e:	6398                	ld	a4,0(a5)
 890:	00e6e463          	bltu	a3,a4,898 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 894:	fee7eae3          	bltu	a5,a4,888 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 898:	ff852583          	lw	a1,-8(a0)
 89c:	6390                	ld	a2,0(a5)
 89e:	02059813          	slli	a6,a1,0x20
 8a2:	01c85713          	srli	a4,a6,0x1c
 8a6:	9736                	add	a4,a4,a3
 8a8:	fae60de3          	beq	a2,a4,862 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8ac:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8b0:	4790                	lw	a2,8(a5)
 8b2:	02061593          	slli	a1,a2,0x20
 8b6:	01c5d713          	srli	a4,a1,0x1c
 8ba:	973e                	add	a4,a4,a5
 8bc:	fae68ae3          	beq	a3,a4,870 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8c0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8c2:	00000717          	auipc	a4,0x0
 8c6:	72f73f23          	sd	a5,1854(a4) # 1000 <freep>
}
 8ca:	6422                	ld	s0,8(sp)
 8cc:	0141                	addi	sp,sp,16
 8ce:	8082                	ret

00000000000008d0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8d0:	7139                	addi	sp,sp,-64
 8d2:	fc06                	sd	ra,56(sp)
 8d4:	f822                	sd	s0,48(sp)
 8d6:	f426                	sd	s1,40(sp)
 8d8:	ec4e                	sd	s3,24(sp)
 8da:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8dc:	02051493          	slli	s1,a0,0x20
 8e0:	9081                	srli	s1,s1,0x20
 8e2:	04bd                	addi	s1,s1,15
 8e4:	8091                	srli	s1,s1,0x4
 8e6:	0014899b          	addiw	s3,s1,1
 8ea:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8ec:	00000517          	auipc	a0,0x0
 8f0:	71453503          	ld	a0,1812(a0) # 1000 <freep>
 8f4:	c915                	beqz	a0,928 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8f8:	4798                	lw	a4,8(a5)
 8fa:	08977a63          	bgeu	a4,s1,98e <malloc+0xbe>
 8fe:	f04a                	sd	s2,32(sp)
 900:	e852                	sd	s4,16(sp)
 902:	e456                	sd	s5,8(sp)
 904:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 906:	8a4e                	mv	s4,s3
 908:	0009871b          	sext.w	a4,s3
 90c:	6685                	lui	a3,0x1
 90e:	00d77363          	bgeu	a4,a3,914 <malloc+0x44>
 912:	6a05                	lui	s4,0x1
 914:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 918:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 91c:	00000917          	auipc	s2,0x0
 920:	6e490913          	addi	s2,s2,1764 # 1000 <freep>
  if(p == SBRK_ERROR)
 924:	5afd                	li	s5,-1
 926:	a081                	j	966 <malloc+0x96>
 928:	f04a                	sd	s2,32(sp)
 92a:	e852                	sd	s4,16(sp)
 92c:	e456                	sd	s5,8(sp)
 92e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 930:	00000797          	auipc	a5,0x0
 934:	6e078793          	addi	a5,a5,1760 # 1010 <base>
 938:	00000717          	auipc	a4,0x0
 93c:	6cf73423          	sd	a5,1736(a4) # 1000 <freep>
 940:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 942:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 946:	b7c1                	j	906 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 948:	6398                	ld	a4,0(a5)
 94a:	e118                	sd	a4,0(a0)
 94c:	a8a9                	j	9a6 <malloc+0xd6>
  hp->s.size = nu;
 94e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 952:	0541                	addi	a0,a0,16
 954:	efbff0ef          	jal	84e <free>
  return freep;
 958:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 95c:	c12d                	beqz	a0,9be <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 95e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 960:	4798                	lw	a4,8(a5)
 962:	02977263          	bgeu	a4,s1,986 <malloc+0xb6>
    if(p == freep)
 966:	00093703          	ld	a4,0(s2)
 96a:	853e                	mv	a0,a5
 96c:	fef719e3          	bne	a4,a5,95e <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 970:	8552                	mv	a0,s4
 972:	a3fff0ef          	jal	3b0 <sbrk>
  if(p == SBRK_ERROR)
 976:	fd551ce3          	bne	a0,s5,94e <malloc+0x7e>
        return 0;
 97a:	4501                	li	a0,0
 97c:	7902                	ld	s2,32(sp)
 97e:	6a42                	ld	s4,16(sp)
 980:	6aa2                	ld	s5,8(sp)
 982:	6b02                	ld	s6,0(sp)
 984:	a03d                	j	9b2 <malloc+0xe2>
 986:	7902                	ld	s2,32(sp)
 988:	6a42                	ld	s4,16(sp)
 98a:	6aa2                	ld	s5,8(sp)
 98c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 98e:	fae48de3          	beq	s1,a4,948 <malloc+0x78>
        p->s.size -= nunits;
 992:	4137073b          	subw	a4,a4,s3
 996:	c798                	sw	a4,8(a5)
        p += p->s.size;
 998:	02071693          	slli	a3,a4,0x20
 99c:	01c6d713          	srli	a4,a3,0x1c
 9a0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9a2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9a6:	00000717          	auipc	a4,0x0
 9aa:	64a73d23          	sd	a0,1626(a4) # 1000 <freep>
      return (void*)(p + 1);
 9ae:	01078513          	addi	a0,a5,16
  }
}
 9b2:	70e2                	ld	ra,56(sp)
 9b4:	7442                	ld	s0,48(sp)
 9b6:	74a2                	ld	s1,40(sp)
 9b8:	69e2                	ld	s3,24(sp)
 9ba:	6121                	addi	sp,sp,64
 9bc:	8082                	ret
 9be:	7902                	ld	s2,32(sp)
 9c0:	6a42                	ld	s4,16(sp)
 9c2:	6aa2                	ld	s5,8(sp)
 9c4:	6b02                	ld	s6,0(sp)
 9c6:	b7f5                	j	9b2 <malloc+0xe2>
