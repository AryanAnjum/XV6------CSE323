
user/_spin:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  int i;
  int x = 0;

  printf("Spinning...\n");
   8:	00001517          	auipc	a0,0x1
   c:	88850513          	addi	a0,a0,-1912 # 890 <malloc+0xfa>
  10:	6d2000ef          	jal	6e2 <printf>
  
  // Infinite loop to burn CPU time
  for(i = 0; ; i++) {
  14:	a001                	j	14 <main+0x14>

0000000000000016 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  16:	1141                	addi	sp,sp,-16
  18:	e406                	sd	ra,8(sp)
  1a:	e022                	sd	s0,0(sp)
  1c:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  1e:	fe3ff0ef          	jal	0 <main>
  exit(r);
  22:	288000ef          	jal	2aa <exit>

0000000000000026 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  26:	1141                	addi	sp,sp,-16
  28:	e422                	sd	s0,8(sp)
  2a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  2c:	87aa                	mv	a5,a0
  2e:	0585                	addi	a1,a1,1
  30:	0785                	addi	a5,a5,1
  32:	fff5c703          	lbu	a4,-1(a1)
  36:	fee78fa3          	sb	a4,-1(a5)
  3a:	fb75                	bnez	a4,2e <strcpy+0x8>
    ;
  return os;
}
  3c:	6422                	ld	s0,8(sp)
  3e:	0141                	addi	sp,sp,16
  40:	8082                	ret

0000000000000042 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  42:	1141                	addi	sp,sp,-16
  44:	e422                	sd	s0,8(sp)
  46:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  48:	00054783          	lbu	a5,0(a0)
  4c:	cb91                	beqz	a5,60 <strcmp+0x1e>
  4e:	0005c703          	lbu	a4,0(a1)
  52:	00f71763          	bne	a4,a5,60 <strcmp+0x1e>
    p++, q++;
  56:	0505                	addi	a0,a0,1
  58:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  5a:	00054783          	lbu	a5,0(a0)
  5e:	fbe5                	bnez	a5,4e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  60:	0005c503          	lbu	a0,0(a1)
}
  64:	40a7853b          	subw	a0,a5,a0
  68:	6422                	ld	s0,8(sp)
  6a:	0141                	addi	sp,sp,16
  6c:	8082                	ret

000000000000006e <strlen>:

uint
strlen(const char *s)
{
  6e:	1141                	addi	sp,sp,-16
  70:	e422                	sd	s0,8(sp)
  72:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  74:	00054783          	lbu	a5,0(a0)
  78:	cf91                	beqz	a5,94 <strlen+0x26>
  7a:	0505                	addi	a0,a0,1
  7c:	87aa                	mv	a5,a0
  7e:	86be                	mv	a3,a5
  80:	0785                	addi	a5,a5,1
  82:	fff7c703          	lbu	a4,-1(a5)
  86:	ff65                	bnez	a4,7e <strlen+0x10>
  88:	40a6853b          	subw	a0,a3,a0
  8c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  8e:	6422                	ld	s0,8(sp)
  90:	0141                	addi	sp,sp,16
  92:	8082                	ret
  for(n = 0; s[n]; n++)
  94:	4501                	li	a0,0
  96:	bfe5                	j	8e <strlen+0x20>

0000000000000098 <memset>:

void*
memset(void *dst, int c, uint n)
{
  98:	1141                	addi	sp,sp,-16
  9a:	e422                	sd	s0,8(sp)
  9c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  9e:	ca19                	beqz	a2,b4 <memset+0x1c>
  a0:	87aa                	mv	a5,a0
  a2:	1602                	slli	a2,a2,0x20
  a4:	9201                	srli	a2,a2,0x20
  a6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  aa:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  ae:	0785                	addi	a5,a5,1
  b0:	fee79de3          	bne	a5,a4,aa <memset+0x12>
  }
  return dst;
}
  b4:	6422                	ld	s0,8(sp)
  b6:	0141                	addi	sp,sp,16
  b8:	8082                	ret

00000000000000ba <strchr>:

char*
strchr(const char *s, char c)
{
  ba:	1141                	addi	sp,sp,-16
  bc:	e422                	sd	s0,8(sp)
  be:	0800                	addi	s0,sp,16
  for(; *s; s++)
  c0:	00054783          	lbu	a5,0(a0)
  c4:	cb99                	beqz	a5,da <strchr+0x20>
    if(*s == c)
  c6:	00f58763          	beq	a1,a5,d4 <strchr+0x1a>
  for(; *s; s++)
  ca:	0505                	addi	a0,a0,1
  cc:	00054783          	lbu	a5,0(a0)
  d0:	fbfd                	bnez	a5,c6 <strchr+0xc>
      return (char*)s;
  return 0;
  d2:	4501                	li	a0,0
}
  d4:	6422                	ld	s0,8(sp)
  d6:	0141                	addi	sp,sp,16
  d8:	8082                	ret
  return 0;
  da:	4501                	li	a0,0
  dc:	bfe5                	j	d4 <strchr+0x1a>

00000000000000de <gets>:

char*
gets(char *buf, int max)
{
  de:	711d                	addi	sp,sp,-96
  e0:	ec86                	sd	ra,88(sp)
  e2:	e8a2                	sd	s0,80(sp)
  e4:	e4a6                	sd	s1,72(sp)
  e6:	e0ca                	sd	s2,64(sp)
  e8:	fc4e                	sd	s3,56(sp)
  ea:	f852                	sd	s4,48(sp)
  ec:	f456                	sd	s5,40(sp)
  ee:	f05a                	sd	s6,32(sp)
  f0:	ec5e                	sd	s7,24(sp)
  f2:	1080                	addi	s0,sp,96
  f4:	8baa                	mv	s7,a0
  f6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  f8:	892a                	mv	s2,a0
  fa:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
  fc:	4aa9                	li	s5,10
  fe:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 100:	89a6                	mv	s3,s1
 102:	2485                	addiw	s1,s1,1
 104:	0344d663          	bge	s1,s4,130 <gets+0x52>
    cc = read(0, &c, 1);
 108:	4605                	li	a2,1
 10a:	faf40593          	addi	a1,s0,-81
 10e:	4501                	li	a0,0
 110:	1b2000ef          	jal	2c2 <read>
    if(cc < 1)
 114:	00a05e63          	blez	a0,130 <gets+0x52>
    buf[i++] = c;
 118:	faf44783          	lbu	a5,-81(s0)
 11c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 120:	01578763          	beq	a5,s5,12e <gets+0x50>
 124:	0905                	addi	s2,s2,1
 126:	fd679de3          	bne	a5,s6,100 <gets+0x22>
    buf[i++] = c;
 12a:	89a6                	mv	s3,s1
 12c:	a011                	j	130 <gets+0x52>
 12e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 130:	99de                	add	s3,s3,s7
 132:	00098023          	sb	zero,0(s3)
  return buf;
}
 136:	855e                	mv	a0,s7
 138:	60e6                	ld	ra,88(sp)
 13a:	6446                	ld	s0,80(sp)
 13c:	64a6                	ld	s1,72(sp)
 13e:	6906                	ld	s2,64(sp)
 140:	79e2                	ld	s3,56(sp)
 142:	7a42                	ld	s4,48(sp)
 144:	7aa2                	ld	s5,40(sp)
 146:	7b02                	ld	s6,32(sp)
 148:	6be2                	ld	s7,24(sp)
 14a:	6125                	addi	sp,sp,96
 14c:	8082                	ret

000000000000014e <stat>:

int
stat(const char *n, struct stat *st)
{
 14e:	1101                	addi	sp,sp,-32
 150:	ec06                	sd	ra,24(sp)
 152:	e822                	sd	s0,16(sp)
 154:	e04a                	sd	s2,0(sp)
 156:	1000                	addi	s0,sp,32
 158:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 15a:	4581                	li	a1,0
 15c:	18e000ef          	jal	2ea <open>
  if(fd < 0)
 160:	02054263          	bltz	a0,184 <stat+0x36>
 164:	e426                	sd	s1,8(sp)
 166:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 168:	85ca                	mv	a1,s2
 16a:	198000ef          	jal	302 <fstat>
 16e:	892a                	mv	s2,a0
  close(fd);
 170:	8526                	mv	a0,s1
 172:	160000ef          	jal	2d2 <close>
  return r;
 176:	64a2                	ld	s1,8(sp)
}
 178:	854a                	mv	a0,s2
 17a:	60e2                	ld	ra,24(sp)
 17c:	6442                	ld	s0,16(sp)
 17e:	6902                	ld	s2,0(sp)
 180:	6105                	addi	sp,sp,32
 182:	8082                	ret
    return -1;
 184:	597d                	li	s2,-1
 186:	bfcd                	j	178 <stat+0x2a>

0000000000000188 <atoi>:

int
atoi(const char *s)
{
 188:	1141                	addi	sp,sp,-16
 18a:	e422                	sd	s0,8(sp)
 18c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 18e:	00054683          	lbu	a3,0(a0)
 192:	fd06879b          	addiw	a5,a3,-48
 196:	0ff7f793          	zext.b	a5,a5
 19a:	4625                	li	a2,9
 19c:	02f66863          	bltu	a2,a5,1cc <atoi+0x44>
 1a0:	872a                	mv	a4,a0
  n = 0;
 1a2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1a4:	0705                	addi	a4,a4,1
 1a6:	0025179b          	slliw	a5,a0,0x2
 1aa:	9fa9                	addw	a5,a5,a0
 1ac:	0017979b          	slliw	a5,a5,0x1
 1b0:	9fb5                	addw	a5,a5,a3
 1b2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1b6:	00074683          	lbu	a3,0(a4)
 1ba:	fd06879b          	addiw	a5,a3,-48
 1be:	0ff7f793          	zext.b	a5,a5
 1c2:	fef671e3          	bgeu	a2,a5,1a4 <atoi+0x1c>
  return n;
}
 1c6:	6422                	ld	s0,8(sp)
 1c8:	0141                	addi	sp,sp,16
 1ca:	8082                	ret
  n = 0;
 1cc:	4501                	li	a0,0
 1ce:	bfe5                	j	1c6 <atoi+0x3e>

00000000000001d0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1d0:	1141                	addi	sp,sp,-16
 1d2:	e422                	sd	s0,8(sp)
 1d4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1d6:	02b57463          	bgeu	a0,a1,1fe <memmove+0x2e>
    while(n-- > 0)
 1da:	00c05f63          	blez	a2,1f8 <memmove+0x28>
 1de:	1602                	slli	a2,a2,0x20
 1e0:	9201                	srli	a2,a2,0x20
 1e2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 1e6:	872a                	mv	a4,a0
      *dst++ = *src++;
 1e8:	0585                	addi	a1,a1,1
 1ea:	0705                	addi	a4,a4,1
 1ec:	fff5c683          	lbu	a3,-1(a1)
 1f0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 1f4:	fef71ae3          	bne	a4,a5,1e8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 1f8:	6422                	ld	s0,8(sp)
 1fa:	0141                	addi	sp,sp,16
 1fc:	8082                	ret
    dst += n;
 1fe:	00c50733          	add	a4,a0,a2
    src += n;
 202:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 204:	fec05ae3          	blez	a2,1f8 <memmove+0x28>
 208:	fff6079b          	addiw	a5,a2,-1
 20c:	1782                	slli	a5,a5,0x20
 20e:	9381                	srli	a5,a5,0x20
 210:	fff7c793          	not	a5,a5
 214:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 216:	15fd                	addi	a1,a1,-1
 218:	177d                	addi	a4,a4,-1
 21a:	0005c683          	lbu	a3,0(a1)
 21e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 222:	fee79ae3          	bne	a5,a4,216 <memmove+0x46>
 226:	bfc9                	j	1f8 <memmove+0x28>

0000000000000228 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 228:	1141                	addi	sp,sp,-16
 22a:	e422                	sd	s0,8(sp)
 22c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 22e:	ca05                	beqz	a2,25e <memcmp+0x36>
 230:	fff6069b          	addiw	a3,a2,-1
 234:	1682                	slli	a3,a3,0x20
 236:	9281                	srli	a3,a3,0x20
 238:	0685                	addi	a3,a3,1
 23a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 23c:	00054783          	lbu	a5,0(a0)
 240:	0005c703          	lbu	a4,0(a1)
 244:	00e79863          	bne	a5,a4,254 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 248:	0505                	addi	a0,a0,1
    p2++;
 24a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 24c:	fed518e3          	bne	a0,a3,23c <memcmp+0x14>
  }
  return 0;
 250:	4501                	li	a0,0
 252:	a019                	j	258 <memcmp+0x30>
      return *p1 - *p2;
 254:	40e7853b          	subw	a0,a5,a4
}
 258:	6422                	ld	s0,8(sp)
 25a:	0141                	addi	sp,sp,16
 25c:	8082                	ret
  return 0;
 25e:	4501                	li	a0,0
 260:	bfe5                	j	258 <memcmp+0x30>

0000000000000262 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 262:	1141                	addi	sp,sp,-16
 264:	e406                	sd	ra,8(sp)
 266:	e022                	sd	s0,0(sp)
 268:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 26a:	f67ff0ef          	jal	1d0 <memmove>
}
 26e:	60a2                	ld	ra,8(sp)
 270:	6402                	ld	s0,0(sp)
 272:	0141                	addi	sp,sp,16
 274:	8082                	ret

0000000000000276 <sbrk>:

char *
sbrk(int n) {
 276:	1141                	addi	sp,sp,-16
 278:	e406                	sd	ra,8(sp)
 27a:	e022                	sd	s0,0(sp)
 27c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 27e:	4585                	li	a1,1
 280:	0b2000ef          	jal	332 <sys_sbrk>
}
 284:	60a2                	ld	ra,8(sp)
 286:	6402                	ld	s0,0(sp)
 288:	0141                	addi	sp,sp,16
 28a:	8082                	ret

000000000000028c <sbrklazy>:

char *
sbrklazy(int n) {
 28c:	1141                	addi	sp,sp,-16
 28e:	e406                	sd	ra,8(sp)
 290:	e022                	sd	s0,0(sp)
 292:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 294:	4589                	li	a1,2
 296:	09c000ef          	jal	332 <sys_sbrk>
}
 29a:	60a2                	ld	ra,8(sp)
 29c:	6402                	ld	s0,0(sp)
 29e:	0141                	addi	sp,sp,16
 2a0:	8082                	ret

00000000000002a2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2a2:	4885                	li	a7,1
 ecall
 2a4:	00000073          	ecall
 ret
 2a8:	8082                	ret

00000000000002aa <exit>:
.global exit
exit:
 li a7, SYS_exit
 2aa:	4889                	li	a7,2
 ecall
 2ac:	00000073          	ecall
 ret
 2b0:	8082                	ret

00000000000002b2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2b2:	488d                	li	a7,3
 ecall
 2b4:	00000073          	ecall
 ret
 2b8:	8082                	ret

00000000000002ba <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2ba:	4891                	li	a7,4
 ecall
 2bc:	00000073          	ecall
 ret
 2c0:	8082                	ret

00000000000002c2 <read>:
.global read
read:
 li a7, SYS_read
 2c2:	4895                	li	a7,5
 ecall
 2c4:	00000073          	ecall
 ret
 2c8:	8082                	ret

00000000000002ca <write>:
.global write
write:
 li a7, SYS_write
 2ca:	48c1                	li	a7,16
 ecall
 2cc:	00000073          	ecall
 ret
 2d0:	8082                	ret

00000000000002d2 <close>:
.global close
close:
 li a7, SYS_close
 2d2:	48d5                	li	a7,21
 ecall
 2d4:	00000073          	ecall
 ret
 2d8:	8082                	ret

00000000000002da <kill>:
.global kill
kill:
 li a7, SYS_kill
 2da:	4899                	li	a7,6
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 2e2:	489d                	li	a7,7
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <open>:
.global open
open:
 li a7, SYS_open
 2ea:	48bd                	li	a7,15
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2f2:	48c5                	li	a7,17
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2fa:	48c9                	li	a7,18
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 302:	48a1                	li	a7,8
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <link>:
.global link
link:
 li a7, SYS_link
 30a:	48cd                	li	a7,19
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 312:	48d1                	li	a7,20
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 31a:	48a5                	li	a7,9
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <dup>:
.global dup
dup:
 li a7, SYS_dup
 322:	48a9                	li	a7,10
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 32a:	48ad                	li	a7,11
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 332:	48b1                	li	a7,12
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <pause>:
.global pause
pause:
 li a7, SYS_pause
 33a:	48b5                	li	a7,13
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 342:	48b9                	li	a7,14
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 34a:	48d9                	li	a7,22
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <freemem>:
.global freemem
freemem:
 li a7, SYS_freemem
 352:	48dd                	li	a7,23
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 35a:	1101                	addi	sp,sp,-32
 35c:	ec06                	sd	ra,24(sp)
 35e:	e822                	sd	s0,16(sp)
 360:	1000                	addi	s0,sp,32
 362:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 366:	4605                	li	a2,1
 368:	fef40593          	addi	a1,s0,-17
 36c:	f5fff0ef          	jal	2ca <write>
}
 370:	60e2                	ld	ra,24(sp)
 372:	6442                	ld	s0,16(sp)
 374:	6105                	addi	sp,sp,32
 376:	8082                	ret

0000000000000378 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 378:	715d                	addi	sp,sp,-80
 37a:	e486                	sd	ra,72(sp)
 37c:	e0a2                	sd	s0,64(sp)
 37e:	f84a                	sd	s2,48(sp)
 380:	0880                	addi	s0,sp,80
 382:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 384:	c299                	beqz	a3,38a <printint+0x12>
 386:	0805c363          	bltz	a1,40c <printint+0x94>
  neg = 0;
 38a:	4881                	li	a7,0
 38c:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 390:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 392:	00000517          	auipc	a0,0x0
 396:	51650513          	addi	a0,a0,1302 # 8a8 <digits>
 39a:	883e                	mv	a6,a5
 39c:	2785                	addiw	a5,a5,1
 39e:	02c5f733          	remu	a4,a1,a2
 3a2:	972a                	add	a4,a4,a0
 3a4:	00074703          	lbu	a4,0(a4)
 3a8:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 3ac:	872e                	mv	a4,a1
 3ae:	02c5d5b3          	divu	a1,a1,a2
 3b2:	0685                	addi	a3,a3,1
 3b4:	fec773e3          	bgeu	a4,a2,39a <printint+0x22>
  if(neg)
 3b8:	00088b63          	beqz	a7,3ce <printint+0x56>
    buf[i++] = '-';
 3bc:	fd078793          	addi	a5,a5,-48
 3c0:	97a2                	add	a5,a5,s0
 3c2:	02d00713          	li	a4,45
 3c6:	fee78423          	sb	a4,-24(a5)
 3ca:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 3ce:	02f05a63          	blez	a5,402 <printint+0x8a>
 3d2:	fc26                	sd	s1,56(sp)
 3d4:	f44e                	sd	s3,40(sp)
 3d6:	fb840713          	addi	a4,s0,-72
 3da:	00f704b3          	add	s1,a4,a5
 3de:	fff70993          	addi	s3,a4,-1
 3e2:	99be                	add	s3,s3,a5
 3e4:	37fd                	addiw	a5,a5,-1
 3e6:	1782                	slli	a5,a5,0x20
 3e8:	9381                	srli	a5,a5,0x20
 3ea:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 3ee:	fff4c583          	lbu	a1,-1(s1)
 3f2:	854a                	mv	a0,s2
 3f4:	f67ff0ef          	jal	35a <putc>
  while(--i >= 0)
 3f8:	14fd                	addi	s1,s1,-1
 3fa:	ff349ae3          	bne	s1,s3,3ee <printint+0x76>
 3fe:	74e2                	ld	s1,56(sp)
 400:	79a2                	ld	s3,40(sp)
}
 402:	60a6                	ld	ra,72(sp)
 404:	6406                	ld	s0,64(sp)
 406:	7942                	ld	s2,48(sp)
 408:	6161                	addi	sp,sp,80
 40a:	8082                	ret
    x = -xx;
 40c:	40b005b3          	neg	a1,a1
    neg = 1;
 410:	4885                	li	a7,1
    x = -xx;
 412:	bfad                	j	38c <printint+0x14>

0000000000000414 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 414:	711d                	addi	sp,sp,-96
 416:	ec86                	sd	ra,88(sp)
 418:	e8a2                	sd	s0,80(sp)
 41a:	e0ca                	sd	s2,64(sp)
 41c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 41e:	0005c903          	lbu	s2,0(a1)
 422:	28090663          	beqz	s2,6ae <vprintf+0x29a>
 426:	e4a6                	sd	s1,72(sp)
 428:	fc4e                	sd	s3,56(sp)
 42a:	f852                	sd	s4,48(sp)
 42c:	f456                	sd	s5,40(sp)
 42e:	f05a                	sd	s6,32(sp)
 430:	ec5e                	sd	s7,24(sp)
 432:	e862                	sd	s8,16(sp)
 434:	e466                	sd	s9,8(sp)
 436:	8b2a                	mv	s6,a0
 438:	8a2e                	mv	s4,a1
 43a:	8bb2                	mv	s7,a2
  state = 0;
 43c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 43e:	4481                	li	s1,0
 440:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 442:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 446:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 44a:	06c00c93          	li	s9,108
 44e:	a005                	j	46e <vprintf+0x5a>
        putc(fd, c0);
 450:	85ca                	mv	a1,s2
 452:	855a                	mv	a0,s6
 454:	f07ff0ef          	jal	35a <putc>
 458:	a019                	j	45e <vprintf+0x4a>
    } else if(state == '%'){
 45a:	03598263          	beq	s3,s5,47e <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 45e:	2485                	addiw	s1,s1,1
 460:	8726                	mv	a4,s1
 462:	009a07b3          	add	a5,s4,s1
 466:	0007c903          	lbu	s2,0(a5)
 46a:	22090a63          	beqz	s2,69e <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 46e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 472:	fe0994e3          	bnez	s3,45a <vprintf+0x46>
      if(c0 == '%'){
 476:	fd579de3          	bne	a5,s5,450 <vprintf+0x3c>
        state = '%';
 47a:	89be                	mv	s3,a5
 47c:	b7cd                	j	45e <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 47e:	00ea06b3          	add	a3,s4,a4
 482:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 486:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 488:	c681                	beqz	a3,490 <vprintf+0x7c>
 48a:	9752                	add	a4,a4,s4
 48c:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 490:	05878363          	beq	a5,s8,4d6 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 494:	05978d63          	beq	a5,s9,4ee <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 498:	07500713          	li	a4,117
 49c:	0ee78763          	beq	a5,a4,58a <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 4a0:	07800713          	li	a4,120
 4a4:	12e78963          	beq	a5,a4,5d6 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 4a8:	07000713          	li	a4,112
 4ac:	14e78e63          	beq	a5,a4,608 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 4b0:	06300713          	li	a4,99
 4b4:	18e78e63          	beq	a5,a4,650 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 4b8:	07300713          	li	a4,115
 4bc:	1ae78463          	beq	a5,a4,664 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 4c0:	02500713          	li	a4,37
 4c4:	04e79563          	bne	a5,a4,50e <vprintf+0xfa>
        putc(fd, '%');
 4c8:	02500593          	li	a1,37
 4cc:	855a                	mv	a0,s6
 4ce:	e8dff0ef          	jal	35a <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 4d2:	4981                	li	s3,0
 4d4:	b769                	j	45e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 4d6:	008b8913          	addi	s2,s7,8
 4da:	4685                	li	a3,1
 4dc:	4629                	li	a2,10
 4de:	000ba583          	lw	a1,0(s7)
 4e2:	855a                	mv	a0,s6
 4e4:	e95ff0ef          	jal	378 <printint>
 4e8:	8bca                	mv	s7,s2
      state = 0;
 4ea:	4981                	li	s3,0
 4ec:	bf8d                	j	45e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 4ee:	06400793          	li	a5,100
 4f2:	02f68963          	beq	a3,a5,524 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 4f6:	06c00793          	li	a5,108
 4fa:	04f68263          	beq	a3,a5,53e <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 4fe:	07500793          	li	a5,117
 502:	0af68063          	beq	a3,a5,5a2 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 506:	07800793          	li	a5,120
 50a:	0ef68263          	beq	a3,a5,5ee <vprintf+0x1da>
        putc(fd, '%');
 50e:	02500593          	li	a1,37
 512:	855a                	mv	a0,s6
 514:	e47ff0ef          	jal	35a <putc>
        putc(fd, c0);
 518:	85ca                	mv	a1,s2
 51a:	855a                	mv	a0,s6
 51c:	e3fff0ef          	jal	35a <putc>
      state = 0;
 520:	4981                	li	s3,0
 522:	bf35                	j	45e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 524:	008b8913          	addi	s2,s7,8
 528:	4685                	li	a3,1
 52a:	4629                	li	a2,10
 52c:	000bb583          	ld	a1,0(s7)
 530:	855a                	mv	a0,s6
 532:	e47ff0ef          	jal	378 <printint>
        i += 1;
 536:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 538:	8bca                	mv	s7,s2
      state = 0;
 53a:	4981                	li	s3,0
        i += 1;
 53c:	b70d                	j	45e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 53e:	06400793          	li	a5,100
 542:	02f60763          	beq	a2,a5,570 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 546:	07500793          	li	a5,117
 54a:	06f60963          	beq	a2,a5,5bc <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 54e:	07800793          	li	a5,120
 552:	faf61ee3          	bne	a2,a5,50e <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 556:	008b8913          	addi	s2,s7,8
 55a:	4681                	li	a3,0
 55c:	4641                	li	a2,16
 55e:	000bb583          	ld	a1,0(s7)
 562:	855a                	mv	a0,s6
 564:	e15ff0ef          	jal	378 <printint>
        i += 2;
 568:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 56a:	8bca                	mv	s7,s2
      state = 0;
 56c:	4981                	li	s3,0
        i += 2;
 56e:	bdc5                	j	45e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 570:	008b8913          	addi	s2,s7,8
 574:	4685                	li	a3,1
 576:	4629                	li	a2,10
 578:	000bb583          	ld	a1,0(s7)
 57c:	855a                	mv	a0,s6
 57e:	dfbff0ef          	jal	378 <printint>
        i += 2;
 582:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 584:	8bca                	mv	s7,s2
      state = 0;
 586:	4981                	li	s3,0
        i += 2;
 588:	bdd9                	j	45e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 58a:	008b8913          	addi	s2,s7,8
 58e:	4681                	li	a3,0
 590:	4629                	li	a2,10
 592:	000be583          	lwu	a1,0(s7)
 596:	855a                	mv	a0,s6
 598:	de1ff0ef          	jal	378 <printint>
 59c:	8bca                	mv	s7,s2
      state = 0;
 59e:	4981                	li	s3,0
 5a0:	bd7d                	j	45e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5a2:	008b8913          	addi	s2,s7,8
 5a6:	4681                	li	a3,0
 5a8:	4629                	li	a2,10
 5aa:	000bb583          	ld	a1,0(s7)
 5ae:	855a                	mv	a0,s6
 5b0:	dc9ff0ef          	jal	378 <printint>
        i += 1;
 5b4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5b6:	8bca                	mv	s7,s2
      state = 0;
 5b8:	4981                	li	s3,0
        i += 1;
 5ba:	b555                	j	45e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5bc:	008b8913          	addi	s2,s7,8
 5c0:	4681                	li	a3,0
 5c2:	4629                	li	a2,10
 5c4:	000bb583          	ld	a1,0(s7)
 5c8:	855a                	mv	a0,s6
 5ca:	dafff0ef          	jal	378 <printint>
        i += 2;
 5ce:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5d0:	8bca                	mv	s7,s2
      state = 0;
 5d2:	4981                	li	s3,0
        i += 2;
 5d4:	b569                	j	45e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 5d6:	008b8913          	addi	s2,s7,8
 5da:	4681                	li	a3,0
 5dc:	4641                	li	a2,16
 5de:	000be583          	lwu	a1,0(s7)
 5e2:	855a                	mv	a0,s6
 5e4:	d95ff0ef          	jal	378 <printint>
 5e8:	8bca                	mv	s7,s2
      state = 0;
 5ea:	4981                	li	s3,0
 5ec:	bd8d                	j	45e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5ee:	008b8913          	addi	s2,s7,8
 5f2:	4681                	li	a3,0
 5f4:	4641                	li	a2,16
 5f6:	000bb583          	ld	a1,0(s7)
 5fa:	855a                	mv	a0,s6
 5fc:	d7dff0ef          	jal	378 <printint>
        i += 1;
 600:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 602:	8bca                	mv	s7,s2
      state = 0;
 604:	4981                	li	s3,0
        i += 1;
 606:	bda1                	j	45e <vprintf+0x4a>
 608:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 60a:	008b8d13          	addi	s10,s7,8
 60e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 612:	03000593          	li	a1,48
 616:	855a                	mv	a0,s6
 618:	d43ff0ef          	jal	35a <putc>
  putc(fd, 'x');
 61c:	07800593          	li	a1,120
 620:	855a                	mv	a0,s6
 622:	d39ff0ef          	jal	35a <putc>
 626:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 628:	00000b97          	auipc	s7,0x0
 62c:	280b8b93          	addi	s7,s7,640 # 8a8 <digits>
 630:	03c9d793          	srli	a5,s3,0x3c
 634:	97de                	add	a5,a5,s7
 636:	0007c583          	lbu	a1,0(a5)
 63a:	855a                	mv	a0,s6
 63c:	d1fff0ef          	jal	35a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 640:	0992                	slli	s3,s3,0x4
 642:	397d                	addiw	s2,s2,-1
 644:	fe0916e3          	bnez	s2,630 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 648:	8bea                	mv	s7,s10
      state = 0;
 64a:	4981                	li	s3,0
 64c:	6d02                	ld	s10,0(sp)
 64e:	bd01                	j	45e <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 650:	008b8913          	addi	s2,s7,8
 654:	000bc583          	lbu	a1,0(s7)
 658:	855a                	mv	a0,s6
 65a:	d01ff0ef          	jal	35a <putc>
 65e:	8bca                	mv	s7,s2
      state = 0;
 660:	4981                	li	s3,0
 662:	bbf5                	j	45e <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 664:	008b8993          	addi	s3,s7,8
 668:	000bb903          	ld	s2,0(s7)
 66c:	00090f63          	beqz	s2,68a <vprintf+0x276>
        for(; *s; s++)
 670:	00094583          	lbu	a1,0(s2)
 674:	c195                	beqz	a1,698 <vprintf+0x284>
          putc(fd, *s);
 676:	855a                	mv	a0,s6
 678:	ce3ff0ef          	jal	35a <putc>
        for(; *s; s++)
 67c:	0905                	addi	s2,s2,1
 67e:	00094583          	lbu	a1,0(s2)
 682:	f9f5                	bnez	a1,676 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 684:	8bce                	mv	s7,s3
      state = 0;
 686:	4981                	li	s3,0
 688:	bbd9                	j	45e <vprintf+0x4a>
          s = "(null)";
 68a:	00000917          	auipc	s2,0x0
 68e:	21690913          	addi	s2,s2,534 # 8a0 <malloc+0x10a>
        for(; *s; s++)
 692:	02800593          	li	a1,40
 696:	b7c5                	j	676 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 698:	8bce                	mv	s7,s3
      state = 0;
 69a:	4981                	li	s3,0
 69c:	b3c9                	j	45e <vprintf+0x4a>
 69e:	64a6                	ld	s1,72(sp)
 6a0:	79e2                	ld	s3,56(sp)
 6a2:	7a42                	ld	s4,48(sp)
 6a4:	7aa2                	ld	s5,40(sp)
 6a6:	7b02                	ld	s6,32(sp)
 6a8:	6be2                	ld	s7,24(sp)
 6aa:	6c42                	ld	s8,16(sp)
 6ac:	6ca2                	ld	s9,8(sp)
    }
  }
}
 6ae:	60e6                	ld	ra,88(sp)
 6b0:	6446                	ld	s0,80(sp)
 6b2:	6906                	ld	s2,64(sp)
 6b4:	6125                	addi	sp,sp,96
 6b6:	8082                	ret

00000000000006b8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6b8:	715d                	addi	sp,sp,-80
 6ba:	ec06                	sd	ra,24(sp)
 6bc:	e822                	sd	s0,16(sp)
 6be:	1000                	addi	s0,sp,32
 6c0:	e010                	sd	a2,0(s0)
 6c2:	e414                	sd	a3,8(s0)
 6c4:	e818                	sd	a4,16(s0)
 6c6:	ec1c                	sd	a5,24(s0)
 6c8:	03043023          	sd	a6,32(s0)
 6cc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6d0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6d4:	8622                	mv	a2,s0
 6d6:	d3fff0ef          	jal	414 <vprintf>
}
 6da:	60e2                	ld	ra,24(sp)
 6dc:	6442                	ld	s0,16(sp)
 6de:	6161                	addi	sp,sp,80
 6e0:	8082                	ret

00000000000006e2 <printf>:

void
printf(const char *fmt, ...)
{
 6e2:	711d                	addi	sp,sp,-96
 6e4:	ec06                	sd	ra,24(sp)
 6e6:	e822                	sd	s0,16(sp)
 6e8:	1000                	addi	s0,sp,32
 6ea:	e40c                	sd	a1,8(s0)
 6ec:	e810                	sd	a2,16(s0)
 6ee:	ec14                	sd	a3,24(s0)
 6f0:	f018                	sd	a4,32(s0)
 6f2:	f41c                	sd	a5,40(s0)
 6f4:	03043823          	sd	a6,48(s0)
 6f8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6fc:	00840613          	addi	a2,s0,8
 700:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 704:	85aa                	mv	a1,a0
 706:	4505                	li	a0,1
 708:	d0dff0ef          	jal	414 <vprintf>
}
 70c:	60e2                	ld	ra,24(sp)
 70e:	6442                	ld	s0,16(sp)
 710:	6125                	addi	sp,sp,96
 712:	8082                	ret

0000000000000714 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 714:	1141                	addi	sp,sp,-16
 716:	e422                	sd	s0,8(sp)
 718:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 71a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 71e:	00001797          	auipc	a5,0x1
 722:	8e27b783          	ld	a5,-1822(a5) # 1000 <freep>
 726:	a02d                	j	750 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 728:	4618                	lw	a4,8(a2)
 72a:	9f2d                	addw	a4,a4,a1
 72c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 730:	6398                	ld	a4,0(a5)
 732:	6310                	ld	a2,0(a4)
 734:	a83d                	j	772 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 736:	ff852703          	lw	a4,-8(a0)
 73a:	9f31                	addw	a4,a4,a2
 73c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 73e:	ff053683          	ld	a3,-16(a0)
 742:	a091                	j	786 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 744:	6398                	ld	a4,0(a5)
 746:	00e7e463          	bltu	a5,a4,74e <free+0x3a>
 74a:	00e6ea63          	bltu	a3,a4,75e <free+0x4a>
{
 74e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 750:	fed7fae3          	bgeu	a5,a3,744 <free+0x30>
 754:	6398                	ld	a4,0(a5)
 756:	00e6e463          	bltu	a3,a4,75e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 75a:	fee7eae3          	bltu	a5,a4,74e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 75e:	ff852583          	lw	a1,-8(a0)
 762:	6390                	ld	a2,0(a5)
 764:	02059813          	slli	a6,a1,0x20
 768:	01c85713          	srli	a4,a6,0x1c
 76c:	9736                	add	a4,a4,a3
 76e:	fae60de3          	beq	a2,a4,728 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 772:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 776:	4790                	lw	a2,8(a5)
 778:	02061593          	slli	a1,a2,0x20
 77c:	01c5d713          	srli	a4,a1,0x1c
 780:	973e                	add	a4,a4,a5
 782:	fae68ae3          	beq	a3,a4,736 <free+0x22>
    p->s.ptr = bp->s.ptr;
 786:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 788:	00001717          	auipc	a4,0x1
 78c:	86f73c23          	sd	a5,-1928(a4) # 1000 <freep>
}
 790:	6422                	ld	s0,8(sp)
 792:	0141                	addi	sp,sp,16
 794:	8082                	ret

0000000000000796 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 796:	7139                	addi	sp,sp,-64
 798:	fc06                	sd	ra,56(sp)
 79a:	f822                	sd	s0,48(sp)
 79c:	f426                	sd	s1,40(sp)
 79e:	ec4e                	sd	s3,24(sp)
 7a0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7a2:	02051493          	slli	s1,a0,0x20
 7a6:	9081                	srli	s1,s1,0x20
 7a8:	04bd                	addi	s1,s1,15
 7aa:	8091                	srli	s1,s1,0x4
 7ac:	0014899b          	addiw	s3,s1,1
 7b0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7b2:	00001517          	auipc	a0,0x1
 7b6:	84e53503          	ld	a0,-1970(a0) # 1000 <freep>
 7ba:	c915                	beqz	a0,7ee <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7bc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7be:	4798                	lw	a4,8(a5)
 7c0:	08977a63          	bgeu	a4,s1,854 <malloc+0xbe>
 7c4:	f04a                	sd	s2,32(sp)
 7c6:	e852                	sd	s4,16(sp)
 7c8:	e456                	sd	s5,8(sp)
 7ca:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7cc:	8a4e                	mv	s4,s3
 7ce:	0009871b          	sext.w	a4,s3
 7d2:	6685                	lui	a3,0x1
 7d4:	00d77363          	bgeu	a4,a3,7da <malloc+0x44>
 7d8:	6a05                	lui	s4,0x1
 7da:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7de:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7e2:	00001917          	auipc	s2,0x1
 7e6:	81e90913          	addi	s2,s2,-2018 # 1000 <freep>
  if(p == SBRK_ERROR)
 7ea:	5afd                	li	s5,-1
 7ec:	a081                	j	82c <malloc+0x96>
 7ee:	f04a                	sd	s2,32(sp)
 7f0:	e852                	sd	s4,16(sp)
 7f2:	e456                	sd	s5,8(sp)
 7f4:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7f6:	00001797          	auipc	a5,0x1
 7fa:	81a78793          	addi	a5,a5,-2022 # 1010 <base>
 7fe:	00001717          	auipc	a4,0x1
 802:	80f73123          	sd	a5,-2046(a4) # 1000 <freep>
 806:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 808:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 80c:	b7c1                	j	7cc <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 80e:	6398                	ld	a4,0(a5)
 810:	e118                	sd	a4,0(a0)
 812:	a8a9                	j	86c <malloc+0xd6>
  hp->s.size = nu;
 814:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 818:	0541                	addi	a0,a0,16
 81a:	efbff0ef          	jal	714 <free>
  return freep;
 81e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 822:	c12d                	beqz	a0,884 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 824:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 826:	4798                	lw	a4,8(a5)
 828:	02977263          	bgeu	a4,s1,84c <malloc+0xb6>
    if(p == freep)
 82c:	00093703          	ld	a4,0(s2)
 830:	853e                	mv	a0,a5
 832:	fef719e3          	bne	a4,a5,824 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 836:	8552                	mv	a0,s4
 838:	a3fff0ef          	jal	276 <sbrk>
  if(p == SBRK_ERROR)
 83c:	fd551ce3          	bne	a0,s5,814 <malloc+0x7e>
        return 0;
 840:	4501                	li	a0,0
 842:	7902                	ld	s2,32(sp)
 844:	6a42                	ld	s4,16(sp)
 846:	6aa2                	ld	s5,8(sp)
 848:	6b02                	ld	s6,0(sp)
 84a:	a03d                	j	878 <malloc+0xe2>
 84c:	7902                	ld	s2,32(sp)
 84e:	6a42                	ld	s4,16(sp)
 850:	6aa2                	ld	s5,8(sp)
 852:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 854:	fae48de3          	beq	s1,a4,80e <malloc+0x78>
        p->s.size -= nunits;
 858:	4137073b          	subw	a4,a4,s3
 85c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 85e:	02071693          	slli	a3,a4,0x20
 862:	01c6d713          	srli	a4,a3,0x1c
 866:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 868:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 86c:	00000717          	auipc	a4,0x0
 870:	78a73a23          	sd	a0,1940(a4) # 1000 <freep>
      return (void*)(p + 1);
 874:	01078513          	addi	a0,a5,16
  }
}
 878:	70e2                	ld	ra,56(sp)
 87a:	7442                	ld	s0,48(sp)
 87c:	74a2                	ld	s1,40(sp)
 87e:	69e2                	ld	s3,24(sp)
 880:	6121                	addi	sp,sp,64
 882:	8082                	ret
 884:	7902                	ld	s2,32(sp)
 886:	6a42                	ld	s4,16(sp)
 888:	6aa2                	ld	s5,8(sp)
 88a:	6b02                	ld	s6,0(sp)
 88c:	b7f5                	j	878 <malloc+0xe2>
