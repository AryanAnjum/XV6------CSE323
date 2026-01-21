
user/_cowdemo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <test_cow>:
// Allocate a large chunk of memory
#define LARGE_SIZE (10 * 1024 * 1024) // 10 MB

void
test_cow()
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	e84a                	sd	s2,16(sp)
   8:	1800                	addi	s0,sp,48
  int pid;
  char *mem;
  int initial_free, after_alloc, after_fork, after_write;
  
  printf("--- Copy-on-Write (CoW) Demonstration ---\n\n");
   a:	00001517          	auipc	a0,0x1
   e:	a3650513          	addi	a0,a0,-1482 # a40 <malloc+0xfc>
  12:	07f000ef          	jal	890 <printf>

  initial_free = freemem();
  16:	4ea000ef          	jal	500 <freemem>
  1a:	892a                	mv	s2,a0
  printf("1. Initial Free Memory: %d KB\n", initial_free / 1024);
  1c:	41f5559b          	sraiw	a1,a0,0x1f
  20:	0165d59b          	srliw	a1,a1,0x16
  24:	9da9                	addw	a1,a1,a0
  26:	40a5d59b          	sraiw	a1,a1,0xa
  2a:	00001517          	auipc	a0,0x1
  2e:	a4650513          	addi	a0,a0,-1466 # a70 <malloc+0x12c>
  32:	05f000ef          	jal	890 <printf>

  // Allocate 10MB
  printf("   Allocating %d KB...\n", LARGE_SIZE / 1024);
  36:	658d                	lui	a1,0x3
  38:	80058593          	addi	a1,a1,-2048 # 2800 <base+0x17f0>
  3c:	00001517          	auipc	a0,0x1
  40:	a5450513          	addi	a0,a0,-1452 # a90 <malloc+0x14c>
  44:	04d000ef          	jal	890 <printf>
  mem = malloc(LARGE_SIZE);
  48:	00a00537          	lui	a0,0xa00
  4c:	0f9000ef          	jal	944 <malloc>
  if(mem == 0){
  50:	10050463          	beqz	a0,158 <test_cow+0x158>
  54:	ec26                	sd	s1,24(sp)
  56:	e44e                	sd	s3,8(sp)
  58:	89aa                	mv	s3,a0
    printf("malloc failed\n");
    return;
  }
  // Determine physical memory usage by checking free memory drop
  memset(mem, 'A', LARGE_SIZE);
  5a:	00a00637          	lui	a2,0xa00
  5e:	04100593          	li	a1,65
  62:	1e4000ef          	jal	246 <memset>
  after_alloc = freemem();
  66:	49a000ef          	jal	500 <freemem>
  6a:	84aa                	mv	s1,a0
  printf("2. Free Memory after malloc (and writing to it): %d KB\n", after_alloc / 1024);
  6c:	41f5559b          	sraiw	a1,a0,0x1f
  70:	0165d59b          	srliw	a1,a1,0x16
  74:	9da9                	addw	a1,a1,a0
  76:	40a5d59b          	sraiw	a1,a1,0xa
  7a:	00001517          	auipc	a0,0x1
  7e:	a3e50513          	addi	a0,a0,-1474 # ab8 <malloc+0x174>
  82:	00f000ef          	jal	890 <printf>
  printf("   (Dropped by ~%d KB)\n\n", (initial_free - after_alloc) / 1024);
  86:	4099093b          	subw	s2,s2,s1
  8a:	41f9559b          	sraiw	a1,s2,0x1f
  8e:	0165d59b          	srliw	a1,a1,0x16
  92:	012585bb          	addw	a1,a1,s2
  96:	40a5d59b          	sraiw	a1,a1,0xa
  9a:	00001517          	auipc	a0,0x1
  9e:	a5650513          	addi	a0,a0,-1450 # af0 <malloc+0x1ac>
  a2:	7ee000ef          	jal	890 <printf>


  printf("3. Forking Process...\n");
  a6:	00001517          	auipc	a0,0x1
  aa:	a6a50513          	addi	a0,a0,-1430 # b10 <malloc+0x1cc>
  ae:	7e2000ef          	jal	890 <printf>
  pid = fork();
  b2:	39e000ef          	jal	450 <fork>

  if(pid < 0){
  b6:	0a054863          	bltz	a0,166 <test_cow+0x166>
    printf("fork failed\n");
    exit(1);
  }

  if(pid == 0){
  ba:	cd5d                	beqz	a0,178 <test_cow+0x178>
    // PARENT PROCESS
    
    // Check free memory immediately after fork
    // IF CoW works: Free memory should NOT drop significantly (only page table overhead)
    // IF Standard Fork: Free memory would drop by another 10MB
    after_fork = freemem();
  bc:	444000ef          	jal	500 <freemem>
  c0:	892a                	mv	s2,a0
    printf("4. Free Memory immediately after fork: %d KB\n", after_fork / 1024);
  c2:	41f5559b          	sraiw	a1,a0,0x1f
  c6:	0165d59b          	srliw	a1,a1,0x16
  ca:	9da9                	addw	a1,a1,a0
  cc:	40a5d59b          	sraiw	a1,a1,0xa
  d0:	00001517          	auipc	a0,0x1
  d4:	ab850513          	addi	a0,a0,-1352 # b88 <malloc+0x244>
  d8:	7b8000ef          	jal	890 <printf>
    printf("   Difference: %d KB\n", (after_alloc - after_fork) / 1024);
  dc:	412484bb          	subw	s1,s1,s2
  e0:	0004891b          	sext.w	s2,s1
  e4:	41f4d59b          	sraiw	a1,s1,0x1f
  e8:	0165d59b          	srliw	a1,a1,0x16
  ec:	9da5                	addw	a1,a1,s1
  ee:	40a5d59b          	sraiw	a1,a1,0xa
  f2:	00001517          	auipc	a0,0x1
  f6:	ac650513          	addi	a0,a0,-1338 # bb8 <malloc+0x274>
  fa:	796000ef          	jal	890 <printf>
    
    if (after_alloc - after_fork < LARGE_SIZE / 2) {
  fe:	005007b7          	lui	a5,0x500
 102:	0af95163          	bge	s2,a5,1a4 <test_cow+0x1a4>
        printf("   >> SUCCESS! Memory usage did NOT double. CoW is working.\n");
 106:	00001517          	auipc	a0,0x1
 10a:	aca50513          	addi	a0,a0,-1334 # bd0 <malloc+0x28c>
 10e:	782000ef          	jal	890 <printf>
    } else {
        printf("   >> FAILURE! Memory usage doubled. Standard fork behavior.\n");
    }

    wait(0); // Wait for child
 112:	4501                	li	a0,0
 114:	34c000ef          	jal	460 <wait>
    
    // After child writes and exits...
    after_write = freemem();
 118:	3e8000ef          	jal	500 <freemem>
 11c:	84aa                	mv	s1,a0
    printf("5. Child exited. Memory reclaimed.\n");
 11e:	00001517          	auipc	a0,0x1
 122:	b3250513          	addi	a0,a0,-1230 # c50 <malloc+0x30c>
 126:	76a000ef          	jal	890 <printf>
    printf("   Final Free Memory: %d KB\n", after_write / 1024);
 12a:	41f4d59b          	sraiw	a1,s1,0x1f
 12e:	0165d59b          	srliw	a1,a1,0x16
 132:	9da5                	addw	a1,a1,s1
 134:	40a5d59b          	sraiw	a1,a1,0xa
 138:	00001517          	auipc	a0,0x1
 13c:	b4050513          	addi	a0,a0,-1216 # c78 <malloc+0x334>
 140:	750000ef          	jal	890 <printf>
  }

  free(mem);
 144:	854e                	mv	a0,s3
 146:	77c000ef          	jal	8c2 <free>
 14a:	64e2                	ld	s1,24(sp)
 14c:	69a2                	ld	s3,8(sp)
}
 14e:	70a2                	ld	ra,40(sp)
 150:	7402                	ld	s0,32(sp)
 152:	6942                	ld	s2,16(sp)
 154:	6145                	addi	sp,sp,48
 156:	8082                	ret
    printf("malloc failed\n");
 158:	00001517          	auipc	a0,0x1
 15c:	95050513          	addi	a0,a0,-1712 # aa8 <malloc+0x164>
 160:	730000ef          	jal	890 <printf>
    return;
 164:	b7ed                	j	14e <test_cow+0x14e>
    printf("fork failed\n");
 166:	00001517          	auipc	a0,0x1
 16a:	9c250513          	addi	a0,a0,-1598 # b28 <malloc+0x1e4>
 16e:	722000ef          	jal	890 <printf>
    exit(1);
 172:	4505                	li	a0,1
 174:	2e4000ef          	jal	458 <exit>
    sleep(10); // Wait for parent to check stats
 178:	4529                	li	a0,10
 17a:	37e000ef          	jal	4f8 <sleep>
    printf("\n[Child] Writing to memory (Triggering CoW)...\n");
 17e:	00001517          	auipc	a0,0x1
 182:	9ba50513          	addi	a0,a0,-1606 # b38 <malloc+0x1f4>
 186:	70a000ef          	jal	890 <printf>
    mem[0] = 'B'; // Modify separate page
 18a:	04200793          	li	a5,66
 18e:	00f98023          	sb	a5,0(s3)
    printf("[Child] Done writing. Exiting.\n");
 192:	00001517          	auipc	a0,0x1
 196:	9d650513          	addi	a0,a0,-1578 # b68 <malloc+0x224>
 19a:	6f6000ef          	jal	890 <printf>
    exit(0);
 19e:	4501                	li	a0,0
 1a0:	2b8000ef          	jal	458 <exit>
        printf("   >> FAILURE! Memory usage doubled. Standard fork behavior.\n");
 1a4:	00001517          	auipc	a0,0x1
 1a8:	a6c50513          	addi	a0,a0,-1428 # c10 <malloc+0x2cc>
 1ac:	6e4000ef          	jal	890 <printf>
 1b0:	b78d                	j	112 <test_cow+0x112>

00000000000001b2 <main>:

int
main(int argc, char *argv[])
{
 1b2:	1141                	addi	sp,sp,-16
 1b4:	e406                	sd	ra,8(sp)
 1b6:	e022                	sd	s0,0(sp)
 1b8:	0800                	addi	s0,sp,16
  test_cow();
 1ba:	e47ff0ef          	jal	0 <test_cow>
  exit(0);
 1be:	4501                	li	a0,0
 1c0:	298000ef          	jal	458 <exit>

00000000000001c4 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1c4:	1141                	addi	sp,sp,-16
 1c6:	e406                	sd	ra,8(sp)
 1c8:	e022                	sd	s0,0(sp)
 1ca:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1cc:	fe7ff0ef          	jal	1b2 <main>
  exit(r);
 1d0:	288000ef          	jal	458 <exit>

00000000000001d4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1d4:	1141                	addi	sp,sp,-16
 1d6:	e422                	sd	s0,8(sp)
 1d8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1da:	87aa                	mv	a5,a0
 1dc:	0585                	addi	a1,a1,1
 1de:	0785                	addi	a5,a5,1 # 500001 <base+0x4feff1>
 1e0:	fff5c703          	lbu	a4,-1(a1)
 1e4:	fee78fa3          	sb	a4,-1(a5)
 1e8:	fb75                	bnez	a4,1dc <strcpy+0x8>
    ;
  return os;
}
 1ea:	6422                	ld	s0,8(sp)
 1ec:	0141                	addi	sp,sp,16
 1ee:	8082                	ret

00000000000001f0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1f0:	1141                	addi	sp,sp,-16
 1f2:	e422                	sd	s0,8(sp)
 1f4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1f6:	00054783          	lbu	a5,0(a0)
 1fa:	cb91                	beqz	a5,20e <strcmp+0x1e>
 1fc:	0005c703          	lbu	a4,0(a1)
 200:	00f71763          	bne	a4,a5,20e <strcmp+0x1e>
    p++, q++;
 204:	0505                	addi	a0,a0,1
 206:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 208:	00054783          	lbu	a5,0(a0)
 20c:	fbe5                	bnez	a5,1fc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 20e:	0005c503          	lbu	a0,0(a1)
}
 212:	40a7853b          	subw	a0,a5,a0
 216:	6422                	ld	s0,8(sp)
 218:	0141                	addi	sp,sp,16
 21a:	8082                	ret

000000000000021c <strlen>:

uint
strlen(const char *s)
{
 21c:	1141                	addi	sp,sp,-16
 21e:	e422                	sd	s0,8(sp)
 220:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 222:	00054783          	lbu	a5,0(a0)
 226:	cf91                	beqz	a5,242 <strlen+0x26>
 228:	0505                	addi	a0,a0,1
 22a:	87aa                	mv	a5,a0
 22c:	86be                	mv	a3,a5
 22e:	0785                	addi	a5,a5,1
 230:	fff7c703          	lbu	a4,-1(a5)
 234:	ff65                	bnez	a4,22c <strlen+0x10>
 236:	40a6853b          	subw	a0,a3,a0
 23a:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 23c:	6422                	ld	s0,8(sp)
 23e:	0141                	addi	sp,sp,16
 240:	8082                	ret
  for(n = 0; s[n]; n++)
 242:	4501                	li	a0,0
 244:	bfe5                	j	23c <strlen+0x20>

0000000000000246 <memset>:

void*
memset(void *dst, int c, uint n)
{
 246:	1141                	addi	sp,sp,-16
 248:	e422                	sd	s0,8(sp)
 24a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 24c:	ca19                	beqz	a2,262 <memset+0x1c>
 24e:	87aa                	mv	a5,a0
 250:	1602                	slli	a2,a2,0x20
 252:	9201                	srli	a2,a2,0x20
 254:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 258:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 25c:	0785                	addi	a5,a5,1
 25e:	fee79de3          	bne	a5,a4,258 <memset+0x12>
  }
  return dst;
}
 262:	6422                	ld	s0,8(sp)
 264:	0141                	addi	sp,sp,16
 266:	8082                	ret

0000000000000268 <strchr>:

char*
strchr(const char *s, char c)
{
 268:	1141                	addi	sp,sp,-16
 26a:	e422                	sd	s0,8(sp)
 26c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 26e:	00054783          	lbu	a5,0(a0)
 272:	cb99                	beqz	a5,288 <strchr+0x20>
    if(*s == c)
 274:	00f58763          	beq	a1,a5,282 <strchr+0x1a>
  for(; *s; s++)
 278:	0505                	addi	a0,a0,1
 27a:	00054783          	lbu	a5,0(a0)
 27e:	fbfd                	bnez	a5,274 <strchr+0xc>
      return (char*)s;
  return 0;
 280:	4501                	li	a0,0
}
 282:	6422                	ld	s0,8(sp)
 284:	0141                	addi	sp,sp,16
 286:	8082                	ret
  return 0;
 288:	4501                	li	a0,0
 28a:	bfe5                	j	282 <strchr+0x1a>

000000000000028c <gets>:

char*
gets(char *buf, int max)
{
 28c:	711d                	addi	sp,sp,-96
 28e:	ec86                	sd	ra,88(sp)
 290:	e8a2                	sd	s0,80(sp)
 292:	e4a6                	sd	s1,72(sp)
 294:	e0ca                	sd	s2,64(sp)
 296:	fc4e                	sd	s3,56(sp)
 298:	f852                	sd	s4,48(sp)
 29a:	f456                	sd	s5,40(sp)
 29c:	f05a                	sd	s6,32(sp)
 29e:	ec5e                	sd	s7,24(sp)
 2a0:	1080                	addi	s0,sp,96
 2a2:	8baa                	mv	s7,a0
 2a4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2a6:	892a                	mv	s2,a0
 2a8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2aa:	4aa9                	li	s5,10
 2ac:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2ae:	89a6                	mv	s3,s1
 2b0:	2485                	addiw	s1,s1,1
 2b2:	0344d663          	bge	s1,s4,2de <gets+0x52>
    cc = read(0, &c, 1);
 2b6:	4605                	li	a2,1
 2b8:	faf40593          	addi	a1,s0,-81
 2bc:	4501                	li	a0,0
 2be:	1b2000ef          	jal	470 <read>
    if(cc < 1)
 2c2:	00a05e63          	blez	a0,2de <gets+0x52>
    buf[i++] = c;
 2c6:	faf44783          	lbu	a5,-81(s0)
 2ca:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2ce:	01578763          	beq	a5,s5,2dc <gets+0x50>
 2d2:	0905                	addi	s2,s2,1
 2d4:	fd679de3          	bne	a5,s6,2ae <gets+0x22>
    buf[i++] = c;
 2d8:	89a6                	mv	s3,s1
 2da:	a011                	j	2de <gets+0x52>
 2dc:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2de:	99de                	add	s3,s3,s7
 2e0:	00098023          	sb	zero,0(s3)
  return buf;
}
 2e4:	855e                	mv	a0,s7
 2e6:	60e6                	ld	ra,88(sp)
 2e8:	6446                	ld	s0,80(sp)
 2ea:	64a6                	ld	s1,72(sp)
 2ec:	6906                	ld	s2,64(sp)
 2ee:	79e2                	ld	s3,56(sp)
 2f0:	7a42                	ld	s4,48(sp)
 2f2:	7aa2                	ld	s5,40(sp)
 2f4:	7b02                	ld	s6,32(sp)
 2f6:	6be2                	ld	s7,24(sp)
 2f8:	6125                	addi	sp,sp,96
 2fa:	8082                	ret

00000000000002fc <stat>:

int
stat(const char *n, struct stat *st)
{
 2fc:	1101                	addi	sp,sp,-32
 2fe:	ec06                	sd	ra,24(sp)
 300:	e822                	sd	s0,16(sp)
 302:	e04a                	sd	s2,0(sp)
 304:	1000                	addi	s0,sp,32
 306:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 308:	4581                	li	a1,0
 30a:	18e000ef          	jal	498 <open>
  if(fd < 0)
 30e:	02054263          	bltz	a0,332 <stat+0x36>
 312:	e426                	sd	s1,8(sp)
 314:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 316:	85ca                	mv	a1,s2
 318:	198000ef          	jal	4b0 <fstat>
 31c:	892a                	mv	s2,a0
  close(fd);
 31e:	8526                	mv	a0,s1
 320:	160000ef          	jal	480 <close>
  return r;
 324:	64a2                	ld	s1,8(sp)
}
 326:	854a                	mv	a0,s2
 328:	60e2                	ld	ra,24(sp)
 32a:	6442                	ld	s0,16(sp)
 32c:	6902                	ld	s2,0(sp)
 32e:	6105                	addi	sp,sp,32
 330:	8082                	ret
    return -1;
 332:	597d                	li	s2,-1
 334:	bfcd                	j	326 <stat+0x2a>

0000000000000336 <atoi>:

int
atoi(const char *s)
{
 336:	1141                	addi	sp,sp,-16
 338:	e422                	sd	s0,8(sp)
 33a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 33c:	00054683          	lbu	a3,0(a0)
 340:	fd06879b          	addiw	a5,a3,-48
 344:	0ff7f793          	zext.b	a5,a5
 348:	4625                	li	a2,9
 34a:	02f66863          	bltu	a2,a5,37a <atoi+0x44>
 34e:	872a                	mv	a4,a0
  n = 0;
 350:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 352:	0705                	addi	a4,a4,1
 354:	0025179b          	slliw	a5,a0,0x2
 358:	9fa9                	addw	a5,a5,a0
 35a:	0017979b          	slliw	a5,a5,0x1
 35e:	9fb5                	addw	a5,a5,a3
 360:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 364:	00074683          	lbu	a3,0(a4)
 368:	fd06879b          	addiw	a5,a3,-48
 36c:	0ff7f793          	zext.b	a5,a5
 370:	fef671e3          	bgeu	a2,a5,352 <atoi+0x1c>
  return n;
}
 374:	6422                	ld	s0,8(sp)
 376:	0141                	addi	sp,sp,16
 378:	8082                	ret
  n = 0;
 37a:	4501                	li	a0,0
 37c:	bfe5                	j	374 <atoi+0x3e>

000000000000037e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 37e:	1141                	addi	sp,sp,-16
 380:	e422                	sd	s0,8(sp)
 382:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 384:	02b57463          	bgeu	a0,a1,3ac <memmove+0x2e>
    while(n-- > 0)
 388:	00c05f63          	blez	a2,3a6 <memmove+0x28>
 38c:	1602                	slli	a2,a2,0x20
 38e:	9201                	srli	a2,a2,0x20
 390:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 394:	872a                	mv	a4,a0
      *dst++ = *src++;
 396:	0585                	addi	a1,a1,1
 398:	0705                	addi	a4,a4,1
 39a:	fff5c683          	lbu	a3,-1(a1)
 39e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3a2:	fef71ae3          	bne	a4,a5,396 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3a6:	6422                	ld	s0,8(sp)
 3a8:	0141                	addi	sp,sp,16
 3aa:	8082                	ret
    dst += n;
 3ac:	00c50733          	add	a4,a0,a2
    src += n;
 3b0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3b2:	fec05ae3          	blez	a2,3a6 <memmove+0x28>
 3b6:	fff6079b          	addiw	a5,a2,-1 # 9fffff <base+0x9fefef>
 3ba:	1782                	slli	a5,a5,0x20
 3bc:	9381                	srli	a5,a5,0x20
 3be:	fff7c793          	not	a5,a5
 3c2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3c4:	15fd                	addi	a1,a1,-1
 3c6:	177d                	addi	a4,a4,-1
 3c8:	0005c683          	lbu	a3,0(a1)
 3cc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3d0:	fee79ae3          	bne	a5,a4,3c4 <memmove+0x46>
 3d4:	bfc9                	j	3a6 <memmove+0x28>

00000000000003d6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3d6:	1141                	addi	sp,sp,-16
 3d8:	e422                	sd	s0,8(sp)
 3da:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3dc:	ca05                	beqz	a2,40c <memcmp+0x36>
 3de:	fff6069b          	addiw	a3,a2,-1
 3e2:	1682                	slli	a3,a3,0x20
 3e4:	9281                	srli	a3,a3,0x20
 3e6:	0685                	addi	a3,a3,1
 3e8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3ea:	00054783          	lbu	a5,0(a0)
 3ee:	0005c703          	lbu	a4,0(a1)
 3f2:	00e79863          	bne	a5,a4,402 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3f6:	0505                	addi	a0,a0,1
    p2++;
 3f8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3fa:	fed518e3          	bne	a0,a3,3ea <memcmp+0x14>
  }
  return 0;
 3fe:	4501                	li	a0,0
 400:	a019                	j	406 <memcmp+0x30>
      return *p1 - *p2;
 402:	40e7853b          	subw	a0,a5,a4
}
 406:	6422                	ld	s0,8(sp)
 408:	0141                	addi	sp,sp,16
 40a:	8082                	ret
  return 0;
 40c:	4501                	li	a0,0
 40e:	bfe5                	j	406 <memcmp+0x30>

0000000000000410 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 410:	1141                	addi	sp,sp,-16
 412:	e406                	sd	ra,8(sp)
 414:	e022                	sd	s0,0(sp)
 416:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 418:	f67ff0ef          	jal	37e <memmove>
}
 41c:	60a2                	ld	ra,8(sp)
 41e:	6402                	ld	s0,0(sp)
 420:	0141                	addi	sp,sp,16
 422:	8082                	ret

0000000000000424 <sbrk>:

char *
sbrk(int n) {
 424:	1141                	addi	sp,sp,-16
 426:	e406                	sd	ra,8(sp)
 428:	e022                	sd	s0,0(sp)
 42a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 42c:	4585                	li	a1,1
 42e:	0b2000ef          	jal	4e0 <sys_sbrk>
}
 432:	60a2                	ld	ra,8(sp)
 434:	6402                	ld	s0,0(sp)
 436:	0141                	addi	sp,sp,16
 438:	8082                	ret

000000000000043a <sbrklazy>:

char *
sbrklazy(int n) {
 43a:	1141                	addi	sp,sp,-16
 43c:	e406                	sd	ra,8(sp)
 43e:	e022                	sd	s0,0(sp)
 440:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 442:	4589                	li	a1,2
 444:	09c000ef          	jal	4e0 <sys_sbrk>
}
 448:	60a2                	ld	ra,8(sp)
 44a:	6402                	ld	s0,0(sp)
 44c:	0141                	addi	sp,sp,16
 44e:	8082                	ret

0000000000000450 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 450:	4885                	li	a7,1
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <exit>:
.global exit
exit:
 li a7, SYS_exit
 458:	4889                	li	a7,2
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <wait>:
.global wait
wait:
 li a7, SYS_wait
 460:	488d                	li	a7,3
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 468:	4891                	li	a7,4
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <read>:
.global read
read:
 li a7, SYS_read
 470:	4895                	li	a7,5
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <write>:
.global write
write:
 li a7, SYS_write
 478:	48c1                	li	a7,16
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <close>:
.global close
close:
 li a7, SYS_close
 480:	48d5                	li	a7,21
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <kill>:
.global kill
kill:
 li a7, SYS_kill
 488:	4899                	li	a7,6
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <exec>:
.global exec
exec:
 li a7, SYS_exec
 490:	489d                	li	a7,7
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <open>:
.global open
open:
 li a7, SYS_open
 498:	48bd                	li	a7,15
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4a0:	48c5                	li	a7,17
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4a8:	48c9                	li	a7,18
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4b0:	48a1                	li	a7,8
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <link>:
.global link
link:
 li a7, SYS_link
 4b8:	48cd                	li	a7,19
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4c0:	48d1                	li	a7,20
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4c8:	48a5                	li	a7,9
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4d0:	48a9                	li	a7,10
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4d8:	48ad                	li	a7,11
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4e0:	48b1                	li	a7,12
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <pause>:
.global pause
pause:
 li a7, SYS_pause
 4e8:	48b5                	li	a7,13
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4f0:	48b9                	li	a7,14
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4f8:	48d9                	li	a7,22
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <freemem>:
.global freemem
freemem:
 li a7, SYS_freemem
 500:	48dd                	li	a7,23
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 508:	1101                	addi	sp,sp,-32
 50a:	ec06                	sd	ra,24(sp)
 50c:	e822                	sd	s0,16(sp)
 50e:	1000                	addi	s0,sp,32
 510:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 514:	4605                	li	a2,1
 516:	fef40593          	addi	a1,s0,-17
 51a:	f5fff0ef          	jal	478 <write>
}
 51e:	60e2                	ld	ra,24(sp)
 520:	6442                	ld	s0,16(sp)
 522:	6105                	addi	sp,sp,32
 524:	8082                	ret

0000000000000526 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 526:	715d                	addi	sp,sp,-80
 528:	e486                	sd	ra,72(sp)
 52a:	e0a2                	sd	s0,64(sp)
 52c:	f84a                	sd	s2,48(sp)
 52e:	0880                	addi	s0,sp,80
 530:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 532:	c299                	beqz	a3,538 <printint+0x12>
 534:	0805c363          	bltz	a1,5ba <printint+0x94>
  neg = 0;
 538:	4881                	li	a7,0
 53a:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 53e:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 540:	00000517          	auipc	a0,0x0
 544:	76050513          	addi	a0,a0,1888 # ca0 <digits>
 548:	883e                	mv	a6,a5
 54a:	2785                	addiw	a5,a5,1
 54c:	02c5f733          	remu	a4,a1,a2
 550:	972a                	add	a4,a4,a0
 552:	00074703          	lbu	a4,0(a4)
 556:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 55a:	872e                	mv	a4,a1
 55c:	02c5d5b3          	divu	a1,a1,a2
 560:	0685                	addi	a3,a3,1
 562:	fec773e3          	bgeu	a4,a2,548 <printint+0x22>
  if(neg)
 566:	00088b63          	beqz	a7,57c <printint+0x56>
    buf[i++] = '-';
 56a:	fd078793          	addi	a5,a5,-48
 56e:	97a2                	add	a5,a5,s0
 570:	02d00713          	li	a4,45
 574:	fee78423          	sb	a4,-24(a5)
 578:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 57c:	02f05a63          	blez	a5,5b0 <printint+0x8a>
 580:	fc26                	sd	s1,56(sp)
 582:	f44e                	sd	s3,40(sp)
 584:	fb840713          	addi	a4,s0,-72
 588:	00f704b3          	add	s1,a4,a5
 58c:	fff70993          	addi	s3,a4,-1
 590:	99be                	add	s3,s3,a5
 592:	37fd                	addiw	a5,a5,-1
 594:	1782                	slli	a5,a5,0x20
 596:	9381                	srli	a5,a5,0x20
 598:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 59c:	fff4c583          	lbu	a1,-1(s1)
 5a0:	854a                	mv	a0,s2
 5a2:	f67ff0ef          	jal	508 <putc>
  while(--i >= 0)
 5a6:	14fd                	addi	s1,s1,-1
 5a8:	ff349ae3          	bne	s1,s3,59c <printint+0x76>
 5ac:	74e2                	ld	s1,56(sp)
 5ae:	79a2                	ld	s3,40(sp)
}
 5b0:	60a6                	ld	ra,72(sp)
 5b2:	6406                	ld	s0,64(sp)
 5b4:	7942                	ld	s2,48(sp)
 5b6:	6161                	addi	sp,sp,80
 5b8:	8082                	ret
    x = -xx;
 5ba:	40b005b3          	neg	a1,a1
    neg = 1;
 5be:	4885                	li	a7,1
    x = -xx;
 5c0:	bfad                	j	53a <printint+0x14>

00000000000005c2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5c2:	711d                	addi	sp,sp,-96
 5c4:	ec86                	sd	ra,88(sp)
 5c6:	e8a2                	sd	s0,80(sp)
 5c8:	e0ca                	sd	s2,64(sp)
 5ca:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5cc:	0005c903          	lbu	s2,0(a1)
 5d0:	28090663          	beqz	s2,85c <vprintf+0x29a>
 5d4:	e4a6                	sd	s1,72(sp)
 5d6:	fc4e                	sd	s3,56(sp)
 5d8:	f852                	sd	s4,48(sp)
 5da:	f456                	sd	s5,40(sp)
 5dc:	f05a                	sd	s6,32(sp)
 5de:	ec5e                	sd	s7,24(sp)
 5e0:	e862                	sd	s8,16(sp)
 5e2:	e466                	sd	s9,8(sp)
 5e4:	8b2a                	mv	s6,a0
 5e6:	8a2e                	mv	s4,a1
 5e8:	8bb2                	mv	s7,a2
  state = 0;
 5ea:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5ec:	4481                	li	s1,0
 5ee:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5f0:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5f4:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5f8:	06c00c93          	li	s9,108
 5fc:	a005                	j	61c <vprintf+0x5a>
        putc(fd, c0);
 5fe:	85ca                	mv	a1,s2
 600:	855a                	mv	a0,s6
 602:	f07ff0ef          	jal	508 <putc>
 606:	a019                	j	60c <vprintf+0x4a>
    } else if(state == '%'){
 608:	03598263          	beq	s3,s5,62c <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 60c:	2485                	addiw	s1,s1,1
 60e:	8726                	mv	a4,s1
 610:	009a07b3          	add	a5,s4,s1
 614:	0007c903          	lbu	s2,0(a5)
 618:	22090a63          	beqz	s2,84c <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 61c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 620:	fe0994e3          	bnez	s3,608 <vprintf+0x46>
      if(c0 == '%'){
 624:	fd579de3          	bne	a5,s5,5fe <vprintf+0x3c>
        state = '%';
 628:	89be                	mv	s3,a5
 62a:	b7cd                	j	60c <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 62c:	00ea06b3          	add	a3,s4,a4
 630:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 634:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 636:	c681                	beqz	a3,63e <vprintf+0x7c>
 638:	9752                	add	a4,a4,s4
 63a:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 63e:	05878363          	beq	a5,s8,684 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 642:	05978d63          	beq	a5,s9,69c <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 646:	07500713          	li	a4,117
 64a:	0ee78763          	beq	a5,a4,738 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 64e:	07800713          	li	a4,120
 652:	12e78963          	beq	a5,a4,784 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 656:	07000713          	li	a4,112
 65a:	14e78e63          	beq	a5,a4,7b6 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 65e:	06300713          	li	a4,99
 662:	18e78e63          	beq	a5,a4,7fe <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 666:	07300713          	li	a4,115
 66a:	1ae78463          	beq	a5,a4,812 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 66e:	02500713          	li	a4,37
 672:	04e79563          	bne	a5,a4,6bc <vprintf+0xfa>
        putc(fd, '%');
 676:	02500593          	li	a1,37
 67a:	855a                	mv	a0,s6
 67c:	e8dff0ef          	jal	508 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 680:	4981                	li	s3,0
 682:	b769                	j	60c <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 684:	008b8913          	addi	s2,s7,8
 688:	4685                	li	a3,1
 68a:	4629                	li	a2,10
 68c:	000ba583          	lw	a1,0(s7)
 690:	855a                	mv	a0,s6
 692:	e95ff0ef          	jal	526 <printint>
 696:	8bca                	mv	s7,s2
      state = 0;
 698:	4981                	li	s3,0
 69a:	bf8d                	j	60c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 69c:	06400793          	li	a5,100
 6a0:	02f68963          	beq	a3,a5,6d2 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6a4:	06c00793          	li	a5,108
 6a8:	04f68263          	beq	a3,a5,6ec <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 6ac:	07500793          	li	a5,117
 6b0:	0af68063          	beq	a3,a5,750 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 6b4:	07800793          	li	a5,120
 6b8:	0ef68263          	beq	a3,a5,79c <vprintf+0x1da>
        putc(fd, '%');
 6bc:	02500593          	li	a1,37
 6c0:	855a                	mv	a0,s6
 6c2:	e47ff0ef          	jal	508 <putc>
        putc(fd, c0);
 6c6:	85ca                	mv	a1,s2
 6c8:	855a                	mv	a0,s6
 6ca:	e3fff0ef          	jal	508 <putc>
      state = 0;
 6ce:	4981                	li	s3,0
 6d0:	bf35                	j	60c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6d2:	008b8913          	addi	s2,s7,8
 6d6:	4685                	li	a3,1
 6d8:	4629                	li	a2,10
 6da:	000bb583          	ld	a1,0(s7)
 6de:	855a                	mv	a0,s6
 6e0:	e47ff0ef          	jal	526 <printint>
        i += 1;
 6e4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6e6:	8bca                	mv	s7,s2
      state = 0;
 6e8:	4981                	li	s3,0
        i += 1;
 6ea:	b70d                	j	60c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6ec:	06400793          	li	a5,100
 6f0:	02f60763          	beq	a2,a5,71e <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6f4:	07500793          	li	a5,117
 6f8:	06f60963          	beq	a2,a5,76a <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6fc:	07800793          	li	a5,120
 700:	faf61ee3          	bne	a2,a5,6bc <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 704:	008b8913          	addi	s2,s7,8
 708:	4681                	li	a3,0
 70a:	4641                	li	a2,16
 70c:	000bb583          	ld	a1,0(s7)
 710:	855a                	mv	a0,s6
 712:	e15ff0ef          	jal	526 <printint>
        i += 2;
 716:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 718:	8bca                	mv	s7,s2
      state = 0;
 71a:	4981                	li	s3,0
        i += 2;
 71c:	bdc5                	j	60c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 71e:	008b8913          	addi	s2,s7,8
 722:	4685                	li	a3,1
 724:	4629                	li	a2,10
 726:	000bb583          	ld	a1,0(s7)
 72a:	855a                	mv	a0,s6
 72c:	dfbff0ef          	jal	526 <printint>
        i += 2;
 730:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 732:	8bca                	mv	s7,s2
      state = 0;
 734:	4981                	li	s3,0
        i += 2;
 736:	bdd9                	j	60c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 738:	008b8913          	addi	s2,s7,8
 73c:	4681                	li	a3,0
 73e:	4629                	li	a2,10
 740:	000be583          	lwu	a1,0(s7)
 744:	855a                	mv	a0,s6
 746:	de1ff0ef          	jal	526 <printint>
 74a:	8bca                	mv	s7,s2
      state = 0;
 74c:	4981                	li	s3,0
 74e:	bd7d                	j	60c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 750:	008b8913          	addi	s2,s7,8
 754:	4681                	li	a3,0
 756:	4629                	li	a2,10
 758:	000bb583          	ld	a1,0(s7)
 75c:	855a                	mv	a0,s6
 75e:	dc9ff0ef          	jal	526 <printint>
        i += 1;
 762:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 764:	8bca                	mv	s7,s2
      state = 0;
 766:	4981                	li	s3,0
        i += 1;
 768:	b555                	j	60c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 76a:	008b8913          	addi	s2,s7,8
 76e:	4681                	li	a3,0
 770:	4629                	li	a2,10
 772:	000bb583          	ld	a1,0(s7)
 776:	855a                	mv	a0,s6
 778:	dafff0ef          	jal	526 <printint>
        i += 2;
 77c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 77e:	8bca                	mv	s7,s2
      state = 0;
 780:	4981                	li	s3,0
        i += 2;
 782:	b569                	j	60c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 784:	008b8913          	addi	s2,s7,8
 788:	4681                	li	a3,0
 78a:	4641                	li	a2,16
 78c:	000be583          	lwu	a1,0(s7)
 790:	855a                	mv	a0,s6
 792:	d95ff0ef          	jal	526 <printint>
 796:	8bca                	mv	s7,s2
      state = 0;
 798:	4981                	li	s3,0
 79a:	bd8d                	j	60c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 79c:	008b8913          	addi	s2,s7,8
 7a0:	4681                	li	a3,0
 7a2:	4641                	li	a2,16
 7a4:	000bb583          	ld	a1,0(s7)
 7a8:	855a                	mv	a0,s6
 7aa:	d7dff0ef          	jal	526 <printint>
        i += 1;
 7ae:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 7b0:	8bca                	mv	s7,s2
      state = 0;
 7b2:	4981                	li	s3,0
        i += 1;
 7b4:	bda1                	j	60c <vprintf+0x4a>
 7b6:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 7b8:	008b8d13          	addi	s10,s7,8
 7bc:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7c0:	03000593          	li	a1,48
 7c4:	855a                	mv	a0,s6
 7c6:	d43ff0ef          	jal	508 <putc>
  putc(fd, 'x');
 7ca:	07800593          	li	a1,120
 7ce:	855a                	mv	a0,s6
 7d0:	d39ff0ef          	jal	508 <putc>
 7d4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7d6:	00000b97          	auipc	s7,0x0
 7da:	4cab8b93          	addi	s7,s7,1226 # ca0 <digits>
 7de:	03c9d793          	srli	a5,s3,0x3c
 7e2:	97de                	add	a5,a5,s7
 7e4:	0007c583          	lbu	a1,0(a5)
 7e8:	855a                	mv	a0,s6
 7ea:	d1fff0ef          	jal	508 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7ee:	0992                	slli	s3,s3,0x4
 7f0:	397d                	addiw	s2,s2,-1
 7f2:	fe0916e3          	bnez	s2,7de <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 7f6:	8bea                	mv	s7,s10
      state = 0;
 7f8:	4981                	li	s3,0
 7fa:	6d02                	ld	s10,0(sp)
 7fc:	bd01                	j	60c <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 7fe:	008b8913          	addi	s2,s7,8
 802:	000bc583          	lbu	a1,0(s7)
 806:	855a                	mv	a0,s6
 808:	d01ff0ef          	jal	508 <putc>
 80c:	8bca                	mv	s7,s2
      state = 0;
 80e:	4981                	li	s3,0
 810:	bbf5                	j	60c <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 812:	008b8993          	addi	s3,s7,8
 816:	000bb903          	ld	s2,0(s7)
 81a:	00090f63          	beqz	s2,838 <vprintf+0x276>
        for(; *s; s++)
 81e:	00094583          	lbu	a1,0(s2)
 822:	c195                	beqz	a1,846 <vprintf+0x284>
          putc(fd, *s);
 824:	855a                	mv	a0,s6
 826:	ce3ff0ef          	jal	508 <putc>
        for(; *s; s++)
 82a:	0905                	addi	s2,s2,1
 82c:	00094583          	lbu	a1,0(s2)
 830:	f9f5                	bnez	a1,824 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 832:	8bce                	mv	s7,s3
      state = 0;
 834:	4981                	li	s3,0
 836:	bbd9                	j	60c <vprintf+0x4a>
          s = "(null)";
 838:	00000917          	auipc	s2,0x0
 83c:	46090913          	addi	s2,s2,1120 # c98 <malloc+0x354>
        for(; *s; s++)
 840:	02800593          	li	a1,40
 844:	b7c5                	j	824 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 846:	8bce                	mv	s7,s3
      state = 0;
 848:	4981                	li	s3,0
 84a:	b3c9                	j	60c <vprintf+0x4a>
 84c:	64a6                	ld	s1,72(sp)
 84e:	79e2                	ld	s3,56(sp)
 850:	7a42                	ld	s4,48(sp)
 852:	7aa2                	ld	s5,40(sp)
 854:	7b02                	ld	s6,32(sp)
 856:	6be2                	ld	s7,24(sp)
 858:	6c42                	ld	s8,16(sp)
 85a:	6ca2                	ld	s9,8(sp)
    }
  }
}
 85c:	60e6                	ld	ra,88(sp)
 85e:	6446                	ld	s0,80(sp)
 860:	6906                	ld	s2,64(sp)
 862:	6125                	addi	sp,sp,96
 864:	8082                	ret

0000000000000866 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 866:	715d                	addi	sp,sp,-80
 868:	ec06                	sd	ra,24(sp)
 86a:	e822                	sd	s0,16(sp)
 86c:	1000                	addi	s0,sp,32
 86e:	e010                	sd	a2,0(s0)
 870:	e414                	sd	a3,8(s0)
 872:	e818                	sd	a4,16(s0)
 874:	ec1c                	sd	a5,24(s0)
 876:	03043023          	sd	a6,32(s0)
 87a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 87e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 882:	8622                	mv	a2,s0
 884:	d3fff0ef          	jal	5c2 <vprintf>
}
 888:	60e2                	ld	ra,24(sp)
 88a:	6442                	ld	s0,16(sp)
 88c:	6161                	addi	sp,sp,80
 88e:	8082                	ret

0000000000000890 <printf>:

void
printf(const char *fmt, ...)
{
 890:	711d                	addi	sp,sp,-96
 892:	ec06                	sd	ra,24(sp)
 894:	e822                	sd	s0,16(sp)
 896:	1000                	addi	s0,sp,32
 898:	e40c                	sd	a1,8(s0)
 89a:	e810                	sd	a2,16(s0)
 89c:	ec14                	sd	a3,24(s0)
 89e:	f018                	sd	a4,32(s0)
 8a0:	f41c                	sd	a5,40(s0)
 8a2:	03043823          	sd	a6,48(s0)
 8a6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8aa:	00840613          	addi	a2,s0,8
 8ae:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8b2:	85aa                	mv	a1,a0
 8b4:	4505                	li	a0,1
 8b6:	d0dff0ef          	jal	5c2 <vprintf>
}
 8ba:	60e2                	ld	ra,24(sp)
 8bc:	6442                	ld	s0,16(sp)
 8be:	6125                	addi	sp,sp,96
 8c0:	8082                	ret

00000000000008c2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8c2:	1141                	addi	sp,sp,-16
 8c4:	e422                	sd	s0,8(sp)
 8c6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8c8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8cc:	00000797          	auipc	a5,0x0
 8d0:	7347b783          	ld	a5,1844(a5) # 1000 <freep>
 8d4:	a02d                	j	8fe <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8d6:	4618                	lw	a4,8(a2)
 8d8:	9f2d                	addw	a4,a4,a1
 8da:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8de:	6398                	ld	a4,0(a5)
 8e0:	6310                	ld	a2,0(a4)
 8e2:	a83d                	j	920 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8e4:	ff852703          	lw	a4,-8(a0)
 8e8:	9f31                	addw	a4,a4,a2
 8ea:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8ec:	ff053683          	ld	a3,-16(a0)
 8f0:	a091                	j	934 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8f2:	6398                	ld	a4,0(a5)
 8f4:	00e7e463          	bltu	a5,a4,8fc <free+0x3a>
 8f8:	00e6ea63          	bltu	a3,a4,90c <free+0x4a>
{
 8fc:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8fe:	fed7fae3          	bgeu	a5,a3,8f2 <free+0x30>
 902:	6398                	ld	a4,0(a5)
 904:	00e6e463          	bltu	a3,a4,90c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 908:	fee7eae3          	bltu	a5,a4,8fc <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 90c:	ff852583          	lw	a1,-8(a0)
 910:	6390                	ld	a2,0(a5)
 912:	02059813          	slli	a6,a1,0x20
 916:	01c85713          	srli	a4,a6,0x1c
 91a:	9736                	add	a4,a4,a3
 91c:	fae60de3          	beq	a2,a4,8d6 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 920:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 924:	4790                	lw	a2,8(a5)
 926:	02061593          	slli	a1,a2,0x20
 92a:	01c5d713          	srli	a4,a1,0x1c
 92e:	973e                	add	a4,a4,a5
 930:	fae68ae3          	beq	a3,a4,8e4 <free+0x22>
    p->s.ptr = bp->s.ptr;
 934:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 936:	00000717          	auipc	a4,0x0
 93a:	6cf73523          	sd	a5,1738(a4) # 1000 <freep>
}
 93e:	6422                	ld	s0,8(sp)
 940:	0141                	addi	sp,sp,16
 942:	8082                	ret

0000000000000944 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 944:	7139                	addi	sp,sp,-64
 946:	fc06                	sd	ra,56(sp)
 948:	f822                	sd	s0,48(sp)
 94a:	f426                	sd	s1,40(sp)
 94c:	ec4e                	sd	s3,24(sp)
 94e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 950:	02051493          	slli	s1,a0,0x20
 954:	9081                	srli	s1,s1,0x20
 956:	04bd                	addi	s1,s1,15
 958:	8091                	srli	s1,s1,0x4
 95a:	0014899b          	addiw	s3,s1,1
 95e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 960:	00000517          	auipc	a0,0x0
 964:	6a053503          	ld	a0,1696(a0) # 1000 <freep>
 968:	c915                	beqz	a0,99c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 96a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 96c:	4798                	lw	a4,8(a5)
 96e:	08977a63          	bgeu	a4,s1,a02 <malloc+0xbe>
 972:	f04a                	sd	s2,32(sp)
 974:	e852                	sd	s4,16(sp)
 976:	e456                	sd	s5,8(sp)
 978:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 97a:	8a4e                	mv	s4,s3
 97c:	0009871b          	sext.w	a4,s3
 980:	6685                	lui	a3,0x1
 982:	00d77363          	bgeu	a4,a3,988 <malloc+0x44>
 986:	6a05                	lui	s4,0x1
 988:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 98c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 990:	00000917          	auipc	s2,0x0
 994:	67090913          	addi	s2,s2,1648 # 1000 <freep>
  if(p == SBRK_ERROR)
 998:	5afd                	li	s5,-1
 99a:	a081                	j	9da <malloc+0x96>
 99c:	f04a                	sd	s2,32(sp)
 99e:	e852                	sd	s4,16(sp)
 9a0:	e456                	sd	s5,8(sp)
 9a2:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9a4:	00000797          	auipc	a5,0x0
 9a8:	66c78793          	addi	a5,a5,1644 # 1010 <base>
 9ac:	00000717          	auipc	a4,0x0
 9b0:	64f73a23          	sd	a5,1620(a4) # 1000 <freep>
 9b4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9b6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9ba:	b7c1                	j	97a <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 9bc:	6398                	ld	a4,0(a5)
 9be:	e118                	sd	a4,0(a0)
 9c0:	a8a9                	j	a1a <malloc+0xd6>
  hp->s.size = nu;
 9c2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9c6:	0541                	addi	a0,a0,16
 9c8:	efbff0ef          	jal	8c2 <free>
  return freep;
 9cc:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9d0:	c12d                	beqz	a0,a32 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9d2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9d4:	4798                	lw	a4,8(a5)
 9d6:	02977263          	bgeu	a4,s1,9fa <malloc+0xb6>
    if(p == freep)
 9da:	00093703          	ld	a4,0(s2)
 9de:	853e                	mv	a0,a5
 9e0:	fef719e3          	bne	a4,a5,9d2 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 9e4:	8552                	mv	a0,s4
 9e6:	a3fff0ef          	jal	424 <sbrk>
  if(p == SBRK_ERROR)
 9ea:	fd551ce3          	bne	a0,s5,9c2 <malloc+0x7e>
        return 0;
 9ee:	4501                	li	a0,0
 9f0:	7902                	ld	s2,32(sp)
 9f2:	6a42                	ld	s4,16(sp)
 9f4:	6aa2                	ld	s5,8(sp)
 9f6:	6b02                	ld	s6,0(sp)
 9f8:	a03d                	j	a26 <malloc+0xe2>
 9fa:	7902                	ld	s2,32(sp)
 9fc:	6a42                	ld	s4,16(sp)
 9fe:	6aa2                	ld	s5,8(sp)
 a00:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a02:	fae48de3          	beq	s1,a4,9bc <malloc+0x78>
        p->s.size -= nunits;
 a06:	4137073b          	subw	a4,a4,s3
 a0a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a0c:	02071693          	slli	a3,a4,0x20
 a10:	01c6d713          	srli	a4,a3,0x1c
 a14:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a16:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a1a:	00000717          	auipc	a4,0x0
 a1e:	5ea73323          	sd	a0,1510(a4) # 1000 <freep>
      return (void*)(p + 1);
 a22:	01078513          	addi	a0,a5,16
  }
}
 a26:	70e2                	ld	ra,56(sp)
 a28:	7442                	ld	s0,48(sp)
 a2a:	74a2                	ld	s1,40(sp)
 a2c:	69e2                	ld	s3,24(sp)
 a2e:	6121                	addi	sp,sp,64
 a30:	8082                	ret
 a32:	7902                	ld	s2,32(sp)
 a34:	6a42                	ld	s4,16(sp)
 a36:	6aa2                	ld	s5,8(sp)
 a38:	6b02                	ld	s6,0(sp)
 a3a:	b7f5                	j	a26 <malloc+0xe2>
