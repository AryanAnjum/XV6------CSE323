
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00008117          	auipc	sp,0x8
    80000004:	8c010113          	addi	sp,sp,-1856 # 800078c0 <stack0>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fecd61f>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	ef078793          	addi	a5,a5,-272 # 80000f70 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a2:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	7119                	addi	sp,sp,-128
    800000d2:	fc86                	sd	ra,120(sp)
    800000d4:	f8a2                	sd	s0,112(sp)
    800000d6:	f4a6                	sd	s1,104(sp)
    800000d8:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while(i < n){
    800000da:	06c05a63          	blez	a2,8000014e <consolewrite+0x7e>
    800000de:	f0ca                	sd	s2,96(sp)
    800000e0:	ecce                	sd	s3,88(sp)
    800000e2:	e8d2                	sd	s4,80(sp)
    800000e4:	e4d6                	sd	s5,72(sp)
    800000e6:	e0da                	sd	s6,64(sp)
    800000e8:	fc5e                	sd	s7,56(sp)
    800000ea:	f862                	sd	s8,48(sp)
    800000ec:	f466                	sd	s9,40(sp)
    800000ee:	8aaa                	mv	s5,a0
    800000f0:	8b2e                	mv	s6,a1
    800000f2:	8a32                	mv	s4,a2
  int i = 0;
    800000f4:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000f6:	02000c13          	li	s8,32
    800000fa:	02000c93          	li	s9,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    800000fe:	5bfd                	li	s7,-1
    80000100:	a035                	j	8000012c <consolewrite+0x5c>
    if(nn > n - i)
    80000102:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000106:	86ce                	mv	a3,s3
    80000108:	01648633          	add	a2,s1,s6
    8000010c:	85d6                	mv	a1,s5
    8000010e:	f8040513          	addi	a0,s0,-128
    80000112:	410020ef          	jal	80002522 <either_copyin>
    80000116:	03750e63          	beq	a0,s7,80000152 <consolewrite+0x82>
      break;
    uartwrite(buf, nn);
    8000011a:	85ce                	mv	a1,s3
    8000011c:	f8040513          	addi	a0,s0,-128
    80000120:	778000ef          	jal	80000898 <uartwrite>
    i += nn;
    80000124:	009904bb          	addw	s1,s2,s1
  while(i < n){
    80000128:	0144da63          	bge	s1,s4,8000013c <consolewrite+0x6c>
    if(nn > n - i)
    8000012c:	409a093b          	subw	s2,s4,s1
    80000130:	0009079b          	sext.w	a5,s2
    80000134:	fcfc57e3          	bge	s8,a5,80000102 <consolewrite+0x32>
    80000138:	8966                	mv	s2,s9
    8000013a:	b7e1                	j	80000102 <consolewrite+0x32>
    8000013c:	7906                	ld	s2,96(sp)
    8000013e:	69e6                	ld	s3,88(sp)
    80000140:	6a46                	ld	s4,80(sp)
    80000142:	6aa6                	ld	s5,72(sp)
    80000144:	6b06                	ld	s6,64(sp)
    80000146:	7be2                	ld	s7,56(sp)
    80000148:	7c42                	ld	s8,48(sp)
    8000014a:	7ca2                	ld	s9,40(sp)
    8000014c:	a819                	j	80000162 <consolewrite+0x92>
  int i = 0;
    8000014e:	4481                	li	s1,0
    80000150:	a809                	j	80000162 <consolewrite+0x92>
    80000152:	7906                	ld	s2,96(sp)
    80000154:	69e6                	ld	s3,88(sp)
    80000156:	6a46                	ld	s4,80(sp)
    80000158:	6aa6                	ld	s5,72(sp)
    8000015a:	6b06                	ld	s6,64(sp)
    8000015c:	7be2                	ld	s7,56(sp)
    8000015e:	7c42                	ld	s8,48(sp)
    80000160:	7ca2                	ld	s9,40(sp)
  }

  return i;
}
    80000162:	8526                	mv	a0,s1
    80000164:	70e6                	ld	ra,120(sp)
    80000166:	7446                	ld	s0,112(sp)
    80000168:	74a6                	ld	s1,104(sp)
    8000016a:	6109                	addi	sp,sp,128
    8000016c:	8082                	ret

000000008000016e <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	711d                	addi	sp,sp,-96
    80000170:	ec86                	sd	ra,88(sp)
    80000172:	e8a2                	sd	s0,80(sp)
    80000174:	e4a6                	sd	s1,72(sp)
    80000176:	e0ca                	sd	s2,64(sp)
    80000178:	fc4e                	sd	s3,56(sp)
    8000017a:	f852                	sd	s4,48(sp)
    8000017c:	f456                	sd	s5,40(sp)
    8000017e:	f05a                	sd	s6,32(sp)
    80000180:	1080                	addi	s0,sp,96
    80000182:	8aaa                	mv	s5,a0
    80000184:	8a2e                	mv	s4,a1
    80000186:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018c:	0000f517          	auipc	a0,0xf
    80000190:	73450513          	addi	a0,a0,1844 # 8000f8c0 <cons>
    80000194:	36f000ef          	jal	80000d02 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000198:	0000f497          	auipc	s1,0xf
    8000019c:	72848493          	addi	s1,s1,1832 # 8000f8c0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a0:	0000f917          	auipc	s2,0xf
    800001a4:	7b890913          	addi	s2,s2,1976 # 8000f958 <cons+0x98>
  while(n > 0){
    800001a8:	0b305d63          	blez	s3,80000262 <consoleread+0xf4>
    while(cons.r == cons.w){
    800001ac:	0984a783          	lw	a5,152(s1)
    800001b0:	09c4a703          	lw	a4,156(s1)
    800001b4:	0af71263          	bne	a4,a5,80000258 <consoleread+0xea>
      if(killed(myproc())){
    800001b8:	11f010ef          	jal	80001ad6 <myproc>
    800001bc:	1f8020ef          	jal	800023b4 <killed>
    800001c0:	e12d                	bnez	a0,80000222 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    800001c2:	85a6                	mv	a1,s1
    800001c4:	854a                	mv	a0,s2
    800001c6:	7b7010ef          	jal	8000217c <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef703e3          	beq	a4,a5,800001b8 <consoleread+0x4a>
    800001d6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001d8:	0000f717          	auipc	a4,0xf
    800001dc:	6e870713          	addi	a4,a4,1768 # 8000f8c0 <cons>
    800001e0:	0017869b          	addiw	a3,a5,1
    800001e4:	08d72c23          	sw	a3,152(a4)
    800001e8:	07f7f693          	andi	a3,a5,127
    800001ec:	9736                	add	a4,a4,a3
    800001ee:	01874703          	lbu	a4,24(a4)
    800001f2:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001f6:	4691                	li	a3,4
    800001f8:	04db8663          	beq	s7,a3,80000244 <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001fc:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000200:	4685                	li	a3,1
    80000202:	faf40613          	addi	a2,s0,-81
    80000206:	85d2                	mv	a1,s4
    80000208:	8556                	mv	a0,s5
    8000020a:	2ce020ef          	jal	800024d8 <either_copyout>
    8000020e:	57fd                	li	a5,-1
    80000210:	04f50863          	beq	a0,a5,80000260 <consoleread+0xf2>
      break;

    dst++;
    80000214:	0a05                	addi	s4,s4,1
    --n;
    80000216:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80000218:	47a9                	li	a5,10
    8000021a:	04fb8d63          	beq	s7,a5,80000274 <consoleread+0x106>
    8000021e:	6be2                	ld	s7,24(sp)
    80000220:	b761                	j	800001a8 <consoleread+0x3a>
        release(&cons.lock);
    80000222:	0000f517          	auipc	a0,0xf
    80000226:	69e50513          	addi	a0,a0,1694 # 8000f8c0 <cons>
    8000022a:	371000ef          	jal	80000d9a <release>
        return -1;
    8000022e:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000230:	60e6                	ld	ra,88(sp)
    80000232:	6446                	ld	s0,80(sp)
    80000234:	64a6                	ld	s1,72(sp)
    80000236:	6906                	ld	s2,64(sp)
    80000238:	79e2                	ld	s3,56(sp)
    8000023a:	7a42                	ld	s4,48(sp)
    8000023c:	7aa2                	ld	s5,40(sp)
    8000023e:	7b02                	ld	s6,32(sp)
    80000240:	6125                	addi	sp,sp,96
    80000242:	8082                	ret
      if(n < target){
    80000244:	0009871b          	sext.w	a4,s3
    80000248:	01677a63          	bgeu	a4,s6,8000025c <consoleread+0xee>
        cons.r--;
    8000024c:	0000f717          	auipc	a4,0xf
    80000250:	70f72623          	sw	a5,1804(a4) # 8000f958 <cons+0x98>
    80000254:	6be2                	ld	s7,24(sp)
    80000256:	a031                	j	80000262 <consoleread+0xf4>
    80000258:	ec5e                	sd	s7,24(sp)
    8000025a:	bfbd                	j	800001d8 <consoleread+0x6a>
    8000025c:	6be2                	ld	s7,24(sp)
    8000025e:	a011                	j	80000262 <consoleread+0xf4>
    80000260:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000262:	0000f517          	auipc	a0,0xf
    80000266:	65e50513          	addi	a0,a0,1630 # 8000f8c0 <cons>
    8000026a:	331000ef          	jal	80000d9a <release>
  return target - n;
    8000026e:	413b053b          	subw	a0,s6,s3
    80000272:	bf7d                	j	80000230 <consoleread+0xc2>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	b7f5                	j	80000262 <consoleread+0xf4>

0000000080000278 <consputc>:
{
    80000278:	1141                	addi	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50863          	beq	a0,a5,80000294 <consputc+0x1c>
    uartputc_sync(c);
    80000288:	6a4000ef          	jal	8000092c <uartputc_sync>
}
    8000028c:	60a2                	ld	ra,8(sp)
    8000028e:	6402                	ld	s0,0(sp)
    80000290:	0141                	addi	sp,sp,16
    80000292:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000294:	4521                	li	a0,8
    80000296:	696000ef          	jal	8000092c <uartputc_sync>
    8000029a:	02000513          	li	a0,32
    8000029e:	68e000ef          	jal	8000092c <uartputc_sync>
    800002a2:	4521                	li	a0,8
    800002a4:	688000ef          	jal	8000092c <uartputc_sync>
    800002a8:	b7d5                	j	8000028c <consputc+0x14>

00000000800002aa <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002aa:	1101                	addi	sp,sp,-32
    800002ac:	ec06                	sd	ra,24(sp)
    800002ae:	e822                	sd	s0,16(sp)
    800002b0:	e426                	sd	s1,8(sp)
    800002b2:	1000                	addi	s0,sp,32
    800002b4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b6:	0000f517          	auipc	a0,0xf
    800002ba:	60a50513          	addi	a0,a0,1546 # 8000f8c0 <cons>
    800002be:	245000ef          	jal	80000d02 <acquire>

  switch(c){
    800002c2:	47d5                	li	a5,21
    800002c4:	08f48f63          	beq	s1,a5,80000362 <consoleintr+0xb8>
    800002c8:	0297c563          	blt	a5,s1,800002f2 <consoleintr+0x48>
    800002cc:	47a1                	li	a5,8
    800002ce:	0ef48463          	beq	s1,a5,800003b6 <consoleintr+0x10c>
    800002d2:	47c1                	li	a5,16
    800002d4:	10f49563          	bne	s1,a5,800003de <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002d8:	294020ef          	jal	8000256c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002dc:	0000f517          	auipc	a0,0xf
    800002e0:	5e450513          	addi	a0,a0,1508 # 8000f8c0 <cons>
    800002e4:	2b7000ef          	jal	80000d9a <release>
}
    800002e8:	60e2                	ld	ra,24(sp)
    800002ea:	6442                	ld	s0,16(sp)
    800002ec:	64a2                	ld	s1,8(sp)
    800002ee:	6105                	addi	sp,sp,32
    800002f0:	8082                	ret
  switch(c){
    800002f2:	07f00793          	li	a5,127
    800002f6:	0cf48063          	beq	s1,a5,800003b6 <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002fa:	0000f717          	auipc	a4,0xf
    800002fe:	5c670713          	addi	a4,a4,1478 # 8000f8c0 <cons>
    80000302:	0a072783          	lw	a5,160(a4)
    80000306:	09872703          	lw	a4,152(a4)
    8000030a:	9f99                	subw	a5,a5,a4
    8000030c:	07f00713          	li	a4,127
    80000310:	fcf766e3          	bltu	a4,a5,800002dc <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000314:	47b5                	li	a5,13
    80000316:	0cf48763          	beq	s1,a5,800003e4 <consoleintr+0x13a>
      consputc(c);
    8000031a:	8526                	mv	a0,s1
    8000031c:	f5dff0ef          	jal	80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000320:	0000f797          	auipc	a5,0xf
    80000324:	5a078793          	addi	a5,a5,1440 # 8000f8c0 <cons>
    80000328:	0a07a683          	lw	a3,160(a5)
    8000032c:	0016871b          	addiw	a4,a3,1
    80000330:	0007061b          	sext.w	a2,a4
    80000334:	0ae7a023          	sw	a4,160(a5)
    80000338:	07f6f693          	andi	a3,a3,127
    8000033c:	97b6                	add	a5,a5,a3
    8000033e:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000342:	47a9                	li	a5,10
    80000344:	0cf48563          	beq	s1,a5,8000040e <consoleintr+0x164>
    80000348:	4791                	li	a5,4
    8000034a:	0cf48263          	beq	s1,a5,8000040e <consoleintr+0x164>
    8000034e:	0000f797          	auipc	a5,0xf
    80000352:	60a7a783          	lw	a5,1546(a5) # 8000f958 <cons+0x98>
    80000356:	9f1d                	subw	a4,a4,a5
    80000358:	08000793          	li	a5,128
    8000035c:	f8f710e3          	bne	a4,a5,800002dc <consoleintr+0x32>
    80000360:	a07d                	j	8000040e <consoleintr+0x164>
    80000362:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000364:	0000f717          	auipc	a4,0xf
    80000368:	55c70713          	addi	a4,a4,1372 # 8000f8c0 <cons>
    8000036c:	0a072783          	lw	a5,160(a4)
    80000370:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000374:	0000f497          	auipc	s1,0xf
    80000378:	54c48493          	addi	s1,s1,1356 # 8000f8c0 <cons>
    while(cons.e != cons.w &&
    8000037c:	4929                	li	s2,10
    8000037e:	02f70863          	beq	a4,a5,800003ae <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000382:	37fd                	addiw	a5,a5,-1
    80000384:	07f7f713          	andi	a4,a5,127
    80000388:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000038a:	01874703          	lbu	a4,24(a4)
    8000038e:	03270263          	beq	a4,s2,800003b2 <consoleintr+0x108>
      cons.e--;
    80000392:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000396:	10000513          	li	a0,256
    8000039a:	edfff0ef          	jal	80000278 <consputc>
    while(cons.e != cons.w &&
    8000039e:	0a04a783          	lw	a5,160(s1)
    800003a2:	09c4a703          	lw	a4,156(s1)
    800003a6:	fcf71ee3          	bne	a4,a5,80000382 <consoleintr+0xd8>
    800003aa:	6902                	ld	s2,0(sp)
    800003ac:	bf05                	j	800002dc <consoleintr+0x32>
    800003ae:	6902                	ld	s2,0(sp)
    800003b0:	b735                	j	800002dc <consoleintr+0x32>
    800003b2:	6902                	ld	s2,0(sp)
    800003b4:	b725                	j	800002dc <consoleintr+0x32>
    if(cons.e != cons.w){
    800003b6:	0000f717          	auipc	a4,0xf
    800003ba:	50a70713          	addi	a4,a4,1290 # 8000f8c0 <cons>
    800003be:	0a072783          	lw	a5,160(a4)
    800003c2:	09c72703          	lw	a4,156(a4)
    800003c6:	f0f70be3          	beq	a4,a5,800002dc <consoleintr+0x32>
      cons.e--;
    800003ca:	37fd                	addiw	a5,a5,-1
    800003cc:	0000f717          	auipc	a4,0xf
    800003d0:	58f72a23          	sw	a5,1428(a4) # 8000f960 <cons+0xa0>
      consputc(BACKSPACE);
    800003d4:	10000513          	li	a0,256
    800003d8:	ea1ff0ef          	jal	80000278 <consputc>
    800003dc:	b701                	j	800002dc <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003de:	ee048fe3          	beqz	s1,800002dc <consoleintr+0x32>
    800003e2:	bf21                	j	800002fa <consoleintr+0x50>
      consputc(c);
    800003e4:	4529                	li	a0,10
    800003e6:	e93ff0ef          	jal	80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003ea:	0000f797          	auipc	a5,0xf
    800003ee:	4d678793          	addi	a5,a5,1238 # 8000f8c0 <cons>
    800003f2:	0a07a703          	lw	a4,160(a5)
    800003f6:	0017069b          	addiw	a3,a4,1
    800003fa:	0006861b          	sext.w	a2,a3
    800003fe:	0ad7a023          	sw	a3,160(a5)
    80000402:	07f77713          	andi	a4,a4,127
    80000406:	97ba                	add	a5,a5,a4
    80000408:	4729                	li	a4,10
    8000040a:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040e:	0000f797          	auipc	a5,0xf
    80000412:	54c7a723          	sw	a2,1358(a5) # 8000f95c <cons+0x9c>
        wakeup(&cons.r);
    80000416:	0000f517          	auipc	a0,0xf
    8000041a:	54250513          	addi	a0,a0,1346 # 8000f958 <cons+0x98>
    8000041e:	5ab010ef          	jal	800021c8 <wakeup>
    80000422:	bd6d                	j	800002dc <consoleintr+0x32>

0000000080000424 <consoleinit>:

void
consoleinit(void)
{
    80000424:	1141                	addi	sp,sp,-16
    80000426:	e406                	sd	ra,8(sp)
    80000428:	e022                	sd	s0,0(sp)
    8000042a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000042c:	00007597          	auipc	a1,0x7
    80000430:	bd458593          	addi	a1,a1,-1068 # 80007000 <etext>
    80000434:	0000f517          	auipc	a0,0xf
    80000438:	48c50513          	addi	a0,a0,1164 # 8000f8c0 <cons>
    8000043c:	047000ef          	jal	80000c82 <initlock>

  uartinit();
    80000440:	400000ef          	jal	80000840 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000444:	00130797          	auipc	a5,0x130
    80000448:	c0478793          	addi	a5,a5,-1020 # 80130048 <devsw>
    8000044c:	00000717          	auipc	a4,0x0
    80000450:	d2270713          	addi	a4,a4,-734 # 8000016e <consoleread>
    80000454:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000456:	00000717          	auipc	a4,0x0
    8000045a:	c7a70713          	addi	a4,a4,-902 # 800000d0 <consolewrite>
    8000045e:	ef98                	sd	a4,24(a5)
}
    80000460:	60a2                	ld	ra,8(sp)
    80000462:	6402                	ld	s0,0(sp)
    80000464:	0141                	addi	sp,sp,16
    80000466:	8082                	ret

0000000080000468 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000468:	7139                	addi	sp,sp,-64
    8000046a:	fc06                	sd	ra,56(sp)
    8000046c:	f822                	sd	s0,48(sp)
    8000046e:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000470:	c219                	beqz	a2,80000476 <printint+0xe>
    80000472:	08054063          	bltz	a0,800004f2 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80000476:	4881                	li	a7,0
    80000478:	fc840693          	addi	a3,s0,-56

  i = 0;
    8000047c:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000047e:	00007617          	auipc	a2,0x7
    80000482:	2ca60613          	addi	a2,a2,714 # 80007748 <digits>
    80000486:	883e                	mv	a6,a5
    80000488:	2785                	addiw	a5,a5,1
    8000048a:	02b57733          	remu	a4,a0,a1
    8000048e:	9732                	add	a4,a4,a2
    80000490:	00074703          	lbu	a4,0(a4)
    80000494:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000498:	872a                	mv	a4,a0
    8000049a:	02b55533          	divu	a0,a0,a1
    8000049e:	0685                	addi	a3,a3,1
    800004a0:	feb773e3          	bgeu	a4,a1,80000486 <printint+0x1e>

  if(sign)
    800004a4:	00088a63          	beqz	a7,800004b8 <printint+0x50>
    buf[i++] = '-';
    800004a8:	1781                	addi	a5,a5,-32
    800004aa:	97a2                	add	a5,a5,s0
    800004ac:	02d00713          	li	a4,45
    800004b0:	fee78423          	sb	a4,-24(a5)
    800004b4:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    800004b8:	02f05963          	blez	a5,800004ea <printint+0x82>
    800004bc:	f426                	sd	s1,40(sp)
    800004be:	f04a                	sd	s2,32(sp)
    800004c0:	fc840713          	addi	a4,s0,-56
    800004c4:	00f704b3          	add	s1,a4,a5
    800004c8:	fff70913          	addi	s2,a4,-1
    800004cc:	993e                	add	s2,s2,a5
    800004ce:	37fd                	addiw	a5,a5,-1
    800004d0:	1782                	slli	a5,a5,0x20
    800004d2:	9381                	srli	a5,a5,0x20
    800004d4:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004d8:	fff4c503          	lbu	a0,-1(s1)
    800004dc:	d9dff0ef          	jal	80000278 <consputc>
  while(--i >= 0)
    800004e0:	14fd                	addi	s1,s1,-1
    800004e2:	ff249be3          	bne	s1,s2,800004d8 <printint+0x70>
    800004e6:	74a2                	ld	s1,40(sp)
    800004e8:	7902                	ld	s2,32(sp)
}
    800004ea:	70e2                	ld	ra,56(sp)
    800004ec:	7442                	ld	s0,48(sp)
    800004ee:	6121                	addi	sp,sp,64
    800004f0:	8082                	ret
    x = -xx;
    800004f2:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004f6:	4885                	li	a7,1
    x = -xx;
    800004f8:	b741                	j	80000478 <printint+0x10>

00000000800004fa <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004fa:	7131                	addi	sp,sp,-192
    800004fc:	fc86                	sd	ra,120(sp)
    800004fe:	f8a2                	sd	s0,112(sp)
    80000500:	e8d2                	sd	s4,80(sp)
    80000502:	0100                	addi	s0,sp,128
    80000504:	8a2a                	mv	s4,a0
    80000506:	e40c                	sd	a1,8(s0)
    80000508:	e810                	sd	a2,16(s0)
    8000050a:	ec14                	sd	a3,24(s0)
    8000050c:	f018                	sd	a4,32(s0)
    8000050e:	f41c                	sd	a5,40(s0)
    80000510:	03043823          	sd	a6,48(s0)
    80000514:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    80000518:	00007797          	auipc	a5,0x7
    8000051c:	36c7a783          	lw	a5,876(a5) # 80007884 <panicking>
    80000520:	c3a1                	beqz	a5,80000560 <printf+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000522:	00840793          	addi	a5,s0,8
    80000526:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000052a:	000a4503          	lbu	a0,0(s4)
    8000052e:	28050763          	beqz	a0,800007bc <printf+0x2c2>
    80000532:	f4a6                	sd	s1,104(sp)
    80000534:	f0ca                	sd	s2,96(sp)
    80000536:	ecce                	sd	s3,88(sp)
    80000538:	e4d6                	sd	s5,72(sp)
    8000053a:	e0da                	sd	s6,64(sp)
    8000053c:	f862                	sd	s8,48(sp)
    8000053e:	f466                	sd	s9,40(sp)
    80000540:	f06a                	sd	s10,32(sp)
    80000542:	ec6e                	sd	s11,24(sp)
    80000544:	4981                	li	s3,0
    if(cx != '%'){
    80000546:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    8000054a:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000054e:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80000552:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000556:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    8000055a:	07000d93          	li	s11,112
    8000055e:	a01d                	j	80000584 <printf+0x8a>
    acquire(&pr.lock);
    80000560:	0000f517          	auipc	a0,0xf
    80000564:	40850513          	addi	a0,a0,1032 # 8000f968 <pr>
    80000568:	79a000ef          	jal	80000d02 <acquire>
    8000056c:	bf5d                	j	80000522 <printf+0x28>
      consputc(cx);
    8000056e:	d0bff0ef          	jal	80000278 <consputc>
      continue;
    80000572:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000574:	0014899b          	addiw	s3,s1,1
    80000578:	013a07b3          	add	a5,s4,s3
    8000057c:	0007c503          	lbu	a0,0(a5)
    80000580:	20050b63          	beqz	a0,80000796 <printf+0x29c>
    if(cx != '%'){
    80000584:	ff5515e3          	bne	a0,s5,8000056e <printf+0x74>
    i++;
    80000588:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    8000058c:	009a07b3          	add	a5,s4,s1
    80000590:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000594:	20090b63          	beqz	s2,800007aa <printf+0x2b0>
    80000598:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    8000059c:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    8000059e:	c789                	beqz	a5,800005a8 <printf+0xae>
    800005a0:	009a0733          	add	a4,s4,s1
    800005a4:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    800005a8:	03690963          	beq	s2,s6,800005da <printf+0xe0>
    } else if(c0 == 'l' && c1 == 'd'){
    800005ac:	05890363          	beq	s2,s8,800005f2 <printf+0xf8>
    } else if(c0 == 'u'){
    800005b0:	0d990663          	beq	s2,s9,8000067c <printf+0x182>
    } else if(c0 == 'x'){
    800005b4:	11a90d63          	beq	s2,s10,800006ce <printf+0x1d4>
    } else if(c0 == 'p'){
    800005b8:	15b90663          	beq	s2,s11,80000704 <printf+0x20a>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    800005bc:	06300793          	li	a5,99
    800005c0:	18f90563          	beq	s2,a5,8000074a <printf+0x250>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    800005c4:	07300793          	li	a5,115
    800005c8:	18f90b63          	beq	s2,a5,8000075e <printf+0x264>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800005cc:	03591b63          	bne	s2,s5,80000602 <printf+0x108>
      consputc('%');
    800005d0:	02500513          	li	a0,37
    800005d4:	ca5ff0ef          	jal	80000278 <consputc>
    800005d8:	bf71                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, int), 10, 1);
    800005da:	f8843783          	ld	a5,-120(s0)
    800005de:	00878713          	addi	a4,a5,8
    800005e2:	f8e43423          	sd	a4,-120(s0)
    800005e6:	4605                	li	a2,1
    800005e8:	45a9                	li	a1,10
    800005ea:	4388                	lw	a0,0(a5)
    800005ec:	e7dff0ef          	jal	80000468 <printint>
    800005f0:	b751                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'd'){
    800005f2:	01678f63          	beq	a5,s6,80000610 <printf+0x116>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005f6:	03878b63          	beq	a5,s8,8000062c <printf+0x132>
    } else if(c0 == 'l' && c1 == 'u'){
    800005fa:	09978e63          	beq	a5,s9,80000696 <printf+0x19c>
    } else if(c0 == 'l' && c1 == 'x'){
    800005fe:	0fa78563          	beq	a5,s10,800006e8 <printf+0x1ee>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80000602:	8556                	mv	a0,s5
    80000604:	c75ff0ef          	jal	80000278 <consputc>
      consputc(c0);
    80000608:	854a                	mv	a0,s2
    8000060a:	c6fff0ef          	jal	80000278 <consputc>
    8000060e:	b79d                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000610:	f8843783          	ld	a5,-120(s0)
    80000614:	00878713          	addi	a4,a5,8
    80000618:	f8e43423          	sd	a4,-120(s0)
    8000061c:	4605                	li	a2,1
    8000061e:	45a9                	li	a1,10
    80000620:	6388                	ld	a0,0(a5)
    80000622:	e47ff0ef          	jal	80000468 <printint>
      i += 1;
    80000626:	0029849b          	addiw	s1,s3,2
    8000062a:	b7a9                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000062c:	06400793          	li	a5,100
    80000630:	02f68863          	beq	a3,a5,80000660 <printf+0x166>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000634:	07500793          	li	a5,117
    80000638:	06f68d63          	beq	a3,a5,800006b2 <printf+0x1b8>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000063c:	07800793          	li	a5,120
    80000640:	fcf691e3          	bne	a3,a5,80000602 <printf+0x108>
      printint(va_arg(ap, uint64), 16, 0);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4601                	li	a2,0
    80000652:	45c1                	li	a1,16
    80000654:	6388                	ld	a0,0(a5)
    80000656:	e13ff0ef          	jal	80000468 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bf19                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4605                	li	a2,1
    8000066e:	45a9                	li	a1,10
    80000670:	6388                	ld	a0,0(a5)
    80000672:	df7ff0ef          	jal	80000468 <printint>
      i += 2;
    80000676:	0039849b          	addiw	s1,s3,3
    8000067a:	bded                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4601                	li	a2,0
    8000068a:	45a9                	li	a1,10
    8000068c:	0007e503          	lwu	a0,0(a5)
    80000690:	dd9ff0ef          	jal	80000468 <printint>
    80000694:	b5c5                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	4601                	li	a2,0
    800006a4:	45a9                	li	a1,10
    800006a6:	6388                	ld	a0,0(a5)
    800006a8:	dc1ff0ef          	jal	80000468 <printint>
      i += 1;
    800006ac:	0029849b          	addiw	s1,s3,2
    800006b0:	b5d1                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	addi	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	4601                	li	a2,0
    800006c0:	45a9                	li	a1,10
    800006c2:	6388                	ld	a0,0(a5)
    800006c4:	da5ff0ef          	jal	80000468 <printint>
      i += 2;
    800006c8:	0039849b          	addiw	s1,s3,3
    800006cc:	b565                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    800006ce:	f8843783          	ld	a5,-120(s0)
    800006d2:	00878713          	addi	a4,a5,8
    800006d6:	f8e43423          	sd	a4,-120(s0)
    800006da:	4601                	li	a2,0
    800006dc:	45c1                	li	a1,16
    800006de:	0007e503          	lwu	a0,0(a5)
    800006e2:	d87ff0ef          	jal	80000468 <printint>
    800006e6:	b579                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    800006e8:	f8843783          	ld	a5,-120(s0)
    800006ec:	00878713          	addi	a4,a5,8
    800006f0:	f8e43423          	sd	a4,-120(s0)
    800006f4:	4601                	li	a2,0
    800006f6:	45c1                	li	a1,16
    800006f8:	6388                	ld	a0,0(a5)
    800006fa:	d6fff0ef          	jal	80000468 <printint>
      i += 1;
    800006fe:	0029849b          	addiw	s1,s3,2
    80000702:	bd8d                	j	80000574 <printf+0x7a>
    80000704:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    80000706:	f8843783          	ld	a5,-120(s0)
    8000070a:	00878713          	addi	a4,a5,8
    8000070e:	f8e43423          	sd	a4,-120(s0)
    80000712:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000716:	03000513          	li	a0,48
    8000071a:	b5fff0ef          	jal	80000278 <consputc>
  consputc('x');
    8000071e:	07800513          	li	a0,120
    80000722:	b57ff0ef          	jal	80000278 <consputc>
    80000726:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000728:	00007b97          	auipc	s7,0x7
    8000072c:	020b8b93          	addi	s7,s7,32 # 80007748 <digits>
    80000730:	03c9d793          	srli	a5,s3,0x3c
    80000734:	97de                	add	a5,a5,s7
    80000736:	0007c503          	lbu	a0,0(a5)
    8000073a:	b3fff0ef          	jal	80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000073e:	0992                	slli	s3,s3,0x4
    80000740:	397d                	addiw	s2,s2,-1
    80000742:	fe0917e3          	bnez	s2,80000730 <printf+0x236>
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	b535                	j	80000574 <printf+0x7a>
      consputc(va_arg(ap, uint));
    8000074a:	f8843783          	ld	a5,-120(s0)
    8000074e:	00878713          	addi	a4,a5,8
    80000752:	f8e43423          	sd	a4,-120(s0)
    80000756:	4388                	lw	a0,0(a5)
    80000758:	b21ff0ef          	jal	80000278 <consputc>
    8000075c:	bd21                	j	80000574 <printf+0x7a>
      if((s = va_arg(ap, char*)) == 0)
    8000075e:	f8843783          	ld	a5,-120(s0)
    80000762:	00878713          	addi	a4,a5,8
    80000766:	f8e43423          	sd	a4,-120(s0)
    8000076a:	0007b903          	ld	s2,0(a5)
    8000076e:	00090d63          	beqz	s2,80000788 <printf+0x28e>
      for(; *s; s++)
    80000772:	00094503          	lbu	a0,0(s2)
    80000776:	de050fe3          	beqz	a0,80000574 <printf+0x7a>
        consputc(*s);
    8000077a:	affff0ef          	jal	80000278 <consputc>
      for(; *s; s++)
    8000077e:	0905                	addi	s2,s2,1
    80000780:	00094503          	lbu	a0,0(s2)
    80000784:	f97d                	bnez	a0,8000077a <printf+0x280>
    80000786:	b3fd                	j	80000574 <printf+0x7a>
        s = "(null)";
    80000788:	00007917          	auipc	s2,0x7
    8000078c:	88090913          	addi	s2,s2,-1920 # 80007008 <etext+0x8>
      for(; *s; s++)
    80000790:	02800513          	li	a0,40
    80000794:	b7dd                	j	8000077a <printf+0x280>
    80000796:	74a6                	ld	s1,104(sp)
    80000798:	7906                	ld	s2,96(sp)
    8000079a:	69e6                	ld	s3,88(sp)
    8000079c:	6aa6                	ld	s5,72(sp)
    8000079e:	6b06                	ld	s6,64(sp)
    800007a0:	7c42                	ld	s8,48(sp)
    800007a2:	7ca2                	ld	s9,40(sp)
    800007a4:	7d02                	ld	s10,32(sp)
    800007a6:	6de2                	ld	s11,24(sp)
    800007a8:	a811                	j	800007bc <printf+0x2c2>
    800007aa:	74a6                	ld	s1,104(sp)
    800007ac:	7906                	ld	s2,96(sp)
    800007ae:	69e6                	ld	s3,88(sp)
    800007b0:	6aa6                	ld	s5,72(sp)
    800007b2:	6b06                	ld	s6,64(sp)
    800007b4:	7c42                	ld	s8,48(sp)
    800007b6:	7ca2                	ld	s9,40(sp)
    800007b8:	7d02                	ld	s10,32(sp)
    800007ba:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    800007bc:	00007797          	auipc	a5,0x7
    800007c0:	0c87a783          	lw	a5,200(a5) # 80007884 <panicking>
    800007c4:	c799                	beqz	a5,800007d2 <printf+0x2d8>
    release(&pr.lock);

  return 0;
}
    800007c6:	4501                	li	a0,0
    800007c8:	70e6                	ld	ra,120(sp)
    800007ca:	7446                	ld	s0,112(sp)
    800007cc:	6a46                	ld	s4,80(sp)
    800007ce:	6129                	addi	sp,sp,192
    800007d0:	8082                	ret
    release(&pr.lock);
    800007d2:	0000f517          	auipc	a0,0xf
    800007d6:	19650513          	addi	a0,a0,406 # 8000f968 <pr>
    800007da:	5c0000ef          	jal	80000d9a <release>
  return 0;
    800007de:	b7e5                	j	800007c6 <printf+0x2cc>

00000000800007e0 <panic>:

void
panic(char *s)
{
    800007e0:	1101                	addi	sp,sp,-32
    800007e2:	ec06                	sd	ra,24(sp)
    800007e4:	e822                	sd	s0,16(sp)
    800007e6:	e426                	sd	s1,8(sp)
    800007e8:	e04a                	sd	s2,0(sp)
    800007ea:	1000                	addi	s0,sp,32
    800007ec:	84aa                	mv	s1,a0
  panicking = 1;
    800007ee:	4905                	li	s2,1
    800007f0:	00007797          	auipc	a5,0x7
    800007f4:	0927aa23          	sw	s2,148(a5) # 80007884 <panicking>
  printf("panic: ");
    800007f8:	00007517          	auipc	a0,0x7
    800007fc:	82050513          	addi	a0,a0,-2016 # 80007018 <etext+0x18>
    80000800:	cfbff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000804:	85a6                	mv	a1,s1
    80000806:	00007517          	auipc	a0,0x7
    8000080a:	81a50513          	addi	a0,a0,-2022 # 80007020 <etext+0x20>
    8000080e:	cedff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000812:	00007797          	auipc	a5,0x7
    80000816:	0727a723          	sw	s2,110(a5) # 80007880 <panicked>
  for(;;)
    8000081a:	a001                	j	8000081a <panic+0x3a>

000000008000081c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000081c:	1141                	addi	sp,sp,-16
    8000081e:	e406                	sd	ra,8(sp)
    80000820:	e022                	sd	s0,0(sp)
    80000822:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000824:	00007597          	auipc	a1,0x7
    80000828:	80458593          	addi	a1,a1,-2044 # 80007028 <etext+0x28>
    8000082c:	0000f517          	auipc	a0,0xf
    80000830:	13c50513          	addi	a0,a0,316 # 8000f968 <pr>
    80000834:	44e000ef          	jal	80000c82 <initlock>
}
    80000838:	60a2                	ld	ra,8(sp)
    8000083a:	6402                	ld	s0,0(sp)
    8000083c:	0141                	addi	sp,sp,16
    8000083e:	8082                	ret

0000000080000840 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80000840:	1141                	addi	sp,sp,-16
    80000842:	e406                	sd	ra,8(sp)
    80000844:	e022                	sd	s0,0(sp)
    80000846:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000848:	100007b7          	lui	a5,0x10000
    8000084c:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000850:	10000737          	lui	a4,0x10000
    80000854:	f8000693          	li	a3,-128
    80000858:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000085c:	468d                	li	a3,3
    8000085e:	10000637          	lui	a2,0x10000
    80000862:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000866:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000086a:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	461d                	li	a2,7
    80000874:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000878:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    8000087c:	00006597          	auipc	a1,0x6
    80000880:	7b458593          	addi	a1,a1,1972 # 80007030 <etext+0x30>
    80000884:	0000f517          	auipc	a0,0xf
    80000888:	0fc50513          	addi	a0,a0,252 # 8000f980 <tx_lock>
    8000088c:	3f6000ef          	jal	80000c82 <initlock>
}
    80000890:	60a2                	ld	ra,8(sp)
    80000892:	6402                	ld	s0,0(sp)
    80000894:	0141                	addi	sp,sp,16
    80000896:	8082                	ret

0000000080000898 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    80000898:	715d                	addi	sp,sp,-80
    8000089a:	e486                	sd	ra,72(sp)
    8000089c:	e0a2                	sd	s0,64(sp)
    8000089e:	fc26                	sd	s1,56(sp)
    800008a0:	ec56                	sd	s5,24(sp)
    800008a2:	0880                	addi	s0,sp,80
    800008a4:	8aaa                	mv	s5,a0
    800008a6:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008a8:	0000f517          	auipc	a0,0xf
    800008ac:	0d850513          	addi	a0,a0,216 # 8000f980 <tx_lock>
    800008b0:	452000ef          	jal	80000d02 <acquire>

  int i = 0;
  while(i < n){ 
    800008b4:	06905063          	blez	s1,80000914 <uartwrite+0x7c>
    800008b8:	f84a                	sd	s2,48(sp)
    800008ba:	f44e                	sd	s3,40(sp)
    800008bc:	f052                	sd	s4,32(sp)
    800008be:	e85a                	sd	s6,16(sp)
    800008c0:	e45e                	sd	s7,8(sp)
    800008c2:	8a56                	mv	s4,s5
    800008c4:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    800008c6:	00007497          	auipc	s1,0x7
    800008ca:	fc648493          	addi	s1,s1,-58 # 8000788c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    800008ce:	0000f997          	auipc	s3,0xf
    800008d2:	0b298993          	addi	s3,s3,178 # 8000f980 <tx_lock>
    800008d6:	00007917          	auipc	s2,0x7
    800008da:	fb290913          	addi	s2,s2,-78 # 80007888 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    800008de:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    800008e2:	4b05                	li	s6,1
    800008e4:	a005                	j	80000904 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    800008e6:	85ce                	mv	a1,s3
    800008e8:	854a                	mv	a0,s2
    800008ea:	093010ef          	jal	8000217c <sleep>
    while(tx_busy != 0){
    800008ee:	409c                	lw	a5,0(s1)
    800008f0:	fbfd                	bnez	a5,800008e6 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    800008f2:	000a4783          	lbu	a5,0(s4)
    800008f6:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    800008fa:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    800008fe:	0a05                	addi	s4,s4,1
    80000900:	015a0563          	beq	s4,s5,8000090a <uartwrite+0x72>
    while(tx_busy != 0){
    80000904:	409c                	lw	a5,0(s1)
    80000906:	f3e5                	bnez	a5,800008e6 <uartwrite+0x4e>
    80000908:	b7ed                	j	800008f2 <uartwrite+0x5a>
    8000090a:	7942                	ld	s2,48(sp)
    8000090c:	79a2                	ld	s3,40(sp)
    8000090e:	7a02                	ld	s4,32(sp)
    80000910:	6b42                	ld	s6,16(sp)
    80000912:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000914:	0000f517          	auipc	a0,0xf
    80000918:	06c50513          	addi	a0,a0,108 # 8000f980 <tx_lock>
    8000091c:	47e000ef          	jal	80000d9a <release>
}
    80000920:	60a6                	ld	ra,72(sp)
    80000922:	6406                	ld	s0,64(sp)
    80000924:	74e2                	ld	s1,56(sp)
    80000926:	6ae2                	ld	s5,24(sp)
    80000928:	6161                	addi	sp,sp,80
    8000092a:	8082                	ret

000000008000092c <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000092c:	1101                	addi	sp,sp,-32
    8000092e:	ec06                	sd	ra,24(sp)
    80000930:	e822                	sd	s0,16(sp)
    80000932:	e426                	sd	s1,8(sp)
    80000934:	1000                	addi	s0,sp,32
    80000936:	84aa                	mv	s1,a0
  if(panicking == 0)
    80000938:	00007797          	auipc	a5,0x7
    8000093c:	f4c7a783          	lw	a5,-180(a5) # 80007884 <panicking>
    80000940:	cf95                	beqz	a5,8000097c <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000942:	00007797          	auipc	a5,0x7
    80000946:	f3e7a783          	lw	a5,-194(a5) # 80007880 <panicked>
    8000094a:	ef85                	bnez	a5,80000982 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000094c:	10000737          	lui	a4,0x10000
    80000950:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000952:	00074783          	lbu	a5,0(a4)
    80000956:	0207f793          	andi	a5,a5,32
    8000095a:	dfe5                	beqz	a5,80000952 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000095c:	0ff4f513          	zext.b	a0,s1
    80000960:	100007b7          	lui	a5,0x10000
    80000964:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80000968:	00007797          	auipc	a5,0x7
    8000096c:	f1c7a783          	lw	a5,-228(a5) # 80007884 <panicking>
    80000970:	cb91                	beqz	a5,80000984 <uartputc_sync+0x58>
    pop_off();
}
    80000972:	60e2                	ld	ra,24(sp)
    80000974:	6442                	ld	s0,16(sp)
    80000976:	64a2                	ld	s1,8(sp)
    80000978:	6105                	addi	sp,sp,32
    8000097a:	8082                	ret
    push_off();
    8000097c:	346000ef          	jal	80000cc2 <push_off>
    80000980:	b7c9                	j	80000942 <uartputc_sync+0x16>
    for(;;)
    80000982:	a001                	j	80000982 <uartputc_sync+0x56>
    pop_off();
    80000984:	3c2000ef          	jal	80000d46 <pop_off>
}
    80000988:	b7ed                	j	80000972 <uartputc_sync+0x46>

000000008000098a <uartgetc>:

// try to read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000098a:	1141                	addi	sp,sp,-16
    8000098c:	e422                	sd	s0,8(sp)
    8000098e:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    80000990:	100007b7          	lui	a5,0x10000
    80000994:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    80000996:	0007c783          	lbu	a5,0(a5)
    8000099a:	8b85                	andi	a5,a5,1
    8000099c:	cb81                	beqz	a5,800009ac <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    8000099e:	100007b7          	lui	a5,0x10000
    800009a2:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009a6:	6422                	ld	s0,8(sp)
    800009a8:	0141                	addi	sp,sp,16
    800009aa:	8082                	ret
    return -1;
    800009ac:	557d                	li	a0,-1
    800009ae:	bfe5                	j	800009a6 <uartgetc+0x1c>

00000000800009b0 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009b0:	1101                	addi	sp,sp,-32
    800009b2:	ec06                	sd	ra,24(sp)
    800009b4:	e822                	sd	s0,16(sp)
    800009b6:	e426                	sd	s1,8(sp)
    800009b8:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009ba:	100007b7          	lui	a5,0x10000
    800009be:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    800009c0:	0007c783          	lbu	a5,0(a5)

  acquire(&tx_lock);
    800009c4:	0000f517          	auipc	a0,0xf
    800009c8:	fbc50513          	addi	a0,a0,-68 # 8000f980 <tx_lock>
    800009cc:	336000ef          	jal	80000d02 <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    800009d0:	100007b7          	lui	a5,0x10000
    800009d4:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009d6:	0007c783          	lbu	a5,0(a5)
    800009da:	0207f793          	andi	a5,a5,32
    800009de:	eb89                	bnez	a5,800009f0 <uartintr+0x40>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    800009e0:	0000f517          	auipc	a0,0xf
    800009e4:	fa050513          	addi	a0,a0,-96 # 8000f980 <tx_lock>
    800009e8:	3b2000ef          	jal	80000d9a <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009ec:	54fd                	li	s1,-1
    800009ee:	a831                	j	80000a0a <uartintr+0x5a>
    tx_busy = 0;
    800009f0:	00007797          	auipc	a5,0x7
    800009f4:	e807ae23          	sw	zero,-356(a5) # 8000788c <tx_busy>
    wakeup(&tx_chan);
    800009f8:	00007517          	auipc	a0,0x7
    800009fc:	e9050513          	addi	a0,a0,-368 # 80007888 <tx_chan>
    80000a00:	7c8010ef          	jal	800021c8 <wakeup>
    80000a04:	bff1                	j	800009e0 <uartintr+0x30>
      break;
    consoleintr(c);
    80000a06:	8a5ff0ef          	jal	800002aa <consoleintr>
    int c = uartgetc();
    80000a0a:	f81ff0ef          	jal	8000098a <uartgetc>
    if(c == -1)
    80000a0e:	fe951ce3          	bne	a0,s1,80000a06 <uartintr+0x56>
  }
}
    80000a12:	60e2                	ld	ra,24(sp)
    80000a14:	6442                	ld	s0,16(sp)
    80000a16:	64a2                	ld	s1,8(sp)
    80000a18:	6105                	addi	sp,sp,32
    80000a1a:	8082                	ret

0000000080000a1c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a1c:	7179                	addi	sp,sp,-48
    80000a1e:	f406                	sd	ra,40(sp)
    80000a20:	f022                	sd	s0,32(sp)
    80000a22:	ec26                	sd	s1,24(sp)
    80000a24:	e84a                	sd	s2,16(sp)
    80000a26:	e44e                	sd	s3,8(sp)
    80000a28:	1800                	addi	s0,sp,48
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a2a:	03451793          	slli	a5,a0,0x34
    80000a2e:	efb9                	bnez	a5,80000a8c <kfree+0x70>
    80000a30:	84aa                	mv	s1,a0
    80000a32:	00130797          	auipc	a5,0x130
    80000a36:	7ae78793          	addi	a5,a5,1966 # 801311e0 <end>
    80000a3a:	04f56963          	bltu	a0,a5,80000a8c <kfree+0x70>
    80000a3e:	47c5                	li	a5,17
    80000a40:	07ee                	slli	a5,a5,0x1b
    80000a42:	04f57563          	bgeu	a0,a5,80000a8c <kfree+0x70>
    panic("kfree");

  // Decrement reference count
  acquire(&reflock);
    80000a46:	0000f997          	auipc	s3,0xf
    80000a4a:	f5298993          	addi	s3,s3,-174 # 8000f998 <reflock>
    80000a4e:	854e                	mv	a0,s3
    80000a50:	2b2000ef          	jal	80000d02 <acquire>
  int count = --ref_count[(uint64)pa / PGSIZE];
    80000a54:	00c4d713          	srli	a4,s1,0xc
    80000a58:	0706                	slli	a4,a4,0x1
    80000a5a:	0000f797          	auipc	a5,0xf
    80000a5e:	f7678793          	addi	a5,a5,-138 # 8000f9d0 <ref_count>
    80000a62:	97ba                	add	a5,a5,a4
    80000a64:	0007d903          	lhu	s2,0(a5)
    80000a68:	397d                	addiw	s2,s2,-1
    80000a6a:	1942                	slli	s2,s2,0x30
    80000a6c:	03095913          	srli	s2,s2,0x30
    80000a70:	01279023          	sh	s2,0(a5)
  release(&reflock);
    80000a74:	854e                	mv	a0,s3
    80000a76:	324000ef          	jal	80000d9a <release>

  // Only free if count is 0
  if (count > 0)
    80000a7a:	00090f63          	beqz	s2,80000a98 <kfree+0x7c>

  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}
    80000a7e:	70a2                	ld	ra,40(sp)
    80000a80:	7402                	ld	s0,32(sp)
    80000a82:	64e2                	ld	s1,24(sp)
    80000a84:	6942                	ld	s2,16(sp)
    80000a86:	69a2                	ld	s3,8(sp)
    80000a88:	6145                	addi	sp,sp,48
    80000a8a:	8082                	ret
    panic("kfree");
    80000a8c:	00006517          	auipc	a0,0x6
    80000a90:	5ac50513          	addi	a0,a0,1452 # 80007038 <etext+0x38>
    80000a94:	d4dff0ef          	jal	800007e0 <panic>
  memset(pa, 1, PGSIZE);
    80000a98:	6605                	lui	a2,0x1
    80000a9a:	4585                	li	a1,1
    80000a9c:	8526                	mv	a0,s1
    80000a9e:	338000ef          	jal	80000dd6 <memset>
  acquire(&kmem.lock);
    80000aa2:	0000f917          	auipc	s2,0xf
    80000aa6:	f0e90913          	addi	s2,s2,-242 # 8000f9b0 <kmem>
    80000aaa:	854a                	mv	a0,s2
    80000aac:	256000ef          	jal	80000d02 <acquire>
  r->next = kmem.freelist;
    80000ab0:	0309b783          	ld	a5,48(s3)
    80000ab4:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000ab6:	0299b823          	sd	s1,48(s3)
  release(&kmem.lock);
    80000aba:	854a                	mv	a0,s2
    80000abc:	2de000ef          	jal	80000d9a <release>
    80000ac0:	bf7d                	j	80000a7e <kfree+0x62>

0000000080000ac2 <freerange>:
{
    80000ac2:	7139                	addi	sp,sp,-64
    80000ac4:	fc06                	sd	ra,56(sp)
    80000ac6:	f822                	sd	s0,48(sp)
    80000ac8:	f426                	sd	s1,40(sp)
    80000aca:	0080                	addi	s0,sp,64
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000acc:	6785                	lui	a5,0x1
    80000ace:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ad2:	953a                	add	a0,a0,a4
    80000ad4:	777d                	lui	a4,0xfffff
    80000ad6:	00e574b3          	and	s1,a0,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    80000ada:	97a6                	add	a5,a5,s1
    80000adc:	04f5e263          	bltu	a1,a5,80000b20 <freerange+0x5e>
    80000ae0:	f04a                	sd	s2,32(sp)
    80000ae2:	ec4e                	sd	s3,24(sp)
    80000ae4:	e852                	sd	s4,16(sp)
    80000ae6:	e456                	sd	s5,8(sp)
    80000ae8:	e05a                	sd	s6,0(sp)
    80000aea:	892e                	mv	s2,a1
    ref_count[(uint64)p / PGSIZE] = 1;
    80000aec:	0000fb17          	auipc	s6,0xf
    80000af0:	ee4b0b13          	addi	s6,s6,-284 # 8000f9d0 <ref_count>
    80000af4:	4a85                	li	s5,1
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    80000af6:	6a05                	lui	s4,0x1
    80000af8:	6989                	lui	s3,0x2
    ref_count[(uint64)p / PGSIZE] = 1;
    80000afa:	00c4d793          	srli	a5,s1,0xc
    80000afe:	0786                	slli	a5,a5,0x1
    80000b00:	97da                	add	a5,a5,s6
    80000b02:	01579023          	sh	s5,0(a5)
    kfree(p);
    80000b06:	8526                	mv	a0,s1
    80000b08:	f15ff0ef          	jal	80000a1c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    80000b0c:	87a6                	mv	a5,s1
    80000b0e:	94d2                	add	s1,s1,s4
    80000b10:	97ce                	add	a5,a5,s3
    80000b12:	fef974e3          	bgeu	s2,a5,80000afa <freerange+0x38>
    80000b16:	7902                	ld	s2,32(sp)
    80000b18:	69e2                	ld	s3,24(sp)
    80000b1a:	6a42                	ld	s4,16(sp)
    80000b1c:	6aa2                	ld	s5,8(sp)
    80000b1e:	6b02                	ld	s6,0(sp)
}
    80000b20:	70e2                	ld	ra,56(sp)
    80000b22:	7442                	ld	s0,48(sp)
    80000b24:	74a2                	ld	s1,40(sp)
    80000b26:	6121                	addi	sp,sp,64
    80000b28:	8082                	ret

0000000080000b2a <kinit>:
{
    80000b2a:	1141                	addi	sp,sp,-16
    80000b2c:	e406                	sd	ra,8(sp)
    80000b2e:	e022                	sd	s0,0(sp)
    80000b30:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b32:	00006597          	auipc	a1,0x6
    80000b36:	50e58593          	addi	a1,a1,1294 # 80007040 <etext+0x40>
    80000b3a:	0000f517          	auipc	a0,0xf
    80000b3e:	e7650513          	addi	a0,a0,-394 # 8000f9b0 <kmem>
    80000b42:	140000ef          	jal	80000c82 <initlock>
  initlock(&reflock, "reflock");
    80000b46:	00006597          	auipc	a1,0x6
    80000b4a:	50258593          	addi	a1,a1,1282 # 80007048 <etext+0x48>
    80000b4e:	0000f517          	auipc	a0,0xf
    80000b52:	e4a50513          	addi	a0,a0,-438 # 8000f998 <reflock>
    80000b56:	12c000ef          	jal	80000c82 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b5a:	45c5                	li	a1,17
    80000b5c:	05ee                	slli	a1,a1,0x1b
    80000b5e:	00130517          	auipc	a0,0x130
    80000b62:	68250513          	addi	a0,a0,1666 # 801311e0 <end>
    80000b66:	f5dff0ef          	jal	80000ac2 <freerange>
}
    80000b6a:	60a2                	ld	ra,8(sp)
    80000b6c:	6402                	ld	s0,0(sp)
    80000b6e:	0141                	addi	sp,sp,16
    80000b70:	8082                	ret

0000000080000b72 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b72:	1101                	addi	sp,sp,-32
    80000b74:	ec06                	sd	ra,24(sp)
    80000b76:	e822                	sd	s0,16(sp)
    80000b78:	e426                	sd	s1,8(sp)
    80000b7a:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b7c:	0000f517          	auipc	a0,0xf
    80000b80:	e3450513          	addi	a0,a0,-460 # 8000f9b0 <kmem>
    80000b84:	17e000ef          	jal	80000d02 <acquire>
  r = kmem.freelist;
    80000b88:	0000f497          	auipc	s1,0xf
    80000b8c:	e404b483          	ld	s1,-448(s1) # 8000f9c8 <kmem+0x18>
  if(r)
    80000b90:	cca1                	beqz	s1,80000be8 <kalloc+0x76>
    80000b92:	e04a                	sd	s2,0(sp)
    kmem.freelist = r->next;
    80000b94:	609c                	ld	a5,0(s1)
    80000b96:	0000f917          	auipc	s2,0xf
    80000b9a:	e0290913          	addi	s2,s2,-510 # 8000f998 <reflock>
    80000b9e:	02f93823          	sd	a5,48(s2)
  release(&kmem.lock);
    80000ba2:	0000f517          	auipc	a0,0xf
    80000ba6:	e0e50513          	addi	a0,a0,-498 # 8000f9b0 <kmem>
    80000baa:	1f0000ef          	jal	80000d9a <release>

  if(r) {
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000bae:	6605                	lui	a2,0x1
    80000bb0:	4595                	li	a1,5
    80000bb2:	8526                	mv	a0,s1
    80000bb4:	222000ef          	jal	80000dd6 <memset>
    
    // Initialize reference count to 1
    acquire(&reflock);
    80000bb8:	854a                	mv	a0,s2
    80000bba:	148000ef          	jal	80000d02 <acquire>
    ref_count[(uint64)r / PGSIZE] = 1;
    80000bbe:	00c4d713          	srli	a4,s1,0xc
    80000bc2:	0706                	slli	a4,a4,0x1
    80000bc4:	0000f797          	auipc	a5,0xf
    80000bc8:	e0c78793          	addi	a5,a5,-500 # 8000f9d0 <ref_count>
    80000bcc:	97ba                	add	a5,a5,a4
    80000bce:	4705                	li	a4,1
    80000bd0:	00e79023          	sh	a4,0(a5)
    release(&reflock);
    80000bd4:	854a                	mv	a0,s2
    80000bd6:	1c4000ef          	jal	80000d9a <release>
  }
  return (void*)r;
    80000bda:	6902                	ld	s2,0(sp)
}
    80000bdc:	8526                	mv	a0,s1
    80000bde:	60e2                	ld	ra,24(sp)
    80000be0:	6442                	ld	s0,16(sp)
    80000be2:	64a2                	ld	s1,8(sp)
    80000be4:	6105                	addi	sp,sp,32
    80000be6:	8082                	ret
  release(&kmem.lock);
    80000be8:	0000f517          	auipc	a0,0xf
    80000bec:	dc850513          	addi	a0,a0,-568 # 8000f9b0 <kmem>
    80000bf0:	1aa000ef          	jal	80000d9a <release>
  if(r) {
    80000bf4:	b7e5                	j	80000bdc <kalloc+0x6a>

0000000080000bf6 <krefinc>:

// Increment reference count of a page
void
krefinc(void *pa)
{
    80000bf6:	1101                	addi	sp,sp,-32
    80000bf8:	ec06                	sd	ra,24(sp)
    80000bfa:	e822                	sd	s0,16(sp)
    80000bfc:	e426                	sd	s1,8(sp)
    80000bfe:	e04a                	sd	s2,0(sp)
    80000c00:	1000                	addi	s0,sp,32
    80000c02:	84aa                	mv	s1,a0
  acquire(&reflock);
    80000c04:	0000f917          	auipc	s2,0xf
    80000c08:	d9490913          	addi	s2,s2,-620 # 8000f998 <reflock>
    80000c0c:	854a                	mv	a0,s2
    80000c0e:	0f4000ef          	jal	80000d02 <acquire>
  ref_count[(uint64)pa / PGSIZE]++;
    80000c12:	80b1                	srli	s1,s1,0xc
    80000c14:	0486                	slli	s1,s1,0x1
    80000c16:	0000f797          	auipc	a5,0xf
    80000c1a:	dba78793          	addi	a5,a5,-582 # 8000f9d0 <ref_count>
    80000c1e:	97a6                	add	a5,a5,s1
    80000c20:	0007d703          	lhu	a4,0(a5)
    80000c24:	2705                	addiw	a4,a4,1 # fffffffffffff001 <end+0xffffffff7fecde21>
    80000c26:	00e79023          	sh	a4,0(a5)
  release(&reflock);
    80000c2a:	854a                	mv	a0,s2
    80000c2c:	16e000ef          	jal	80000d9a <release>
}
    80000c30:	60e2                	ld	ra,24(sp)
    80000c32:	6442                	ld	s0,16(sp)
    80000c34:	64a2                	ld	s1,8(sp)
    80000c36:	6902                	ld	s2,0(sp)
    80000c38:	6105                	addi	sp,sp,32
    80000c3a:	8082                	ret

0000000080000c3c <kfreemem>:

// Return the number of bytes of free memory
uint64
kfreemem(void)
{
    80000c3c:	1101                	addi	sp,sp,-32
    80000c3e:	ec06                	sd	ra,24(sp)
    80000c40:	e822                	sd	s0,16(sp)
    80000c42:	e426                	sd	s1,8(sp)
    80000c44:	1000                	addi	s0,sp,32
  struct run *r;
  uint64 count = 0;

  acquire(&kmem.lock);
    80000c46:	0000f517          	auipc	a0,0xf
    80000c4a:	d6a50513          	addi	a0,a0,-662 # 8000f9b0 <kmem>
    80000c4e:	0b4000ef          	jal	80000d02 <acquire>
  r = kmem.freelist;
    80000c52:	0000f797          	auipc	a5,0xf
    80000c56:	d767b783          	ld	a5,-650(a5) # 8000f9c8 <kmem+0x18>
  while(r){
    80000c5a:	c395                	beqz	a5,80000c7e <kfreemem+0x42>
  uint64 count = 0;
    80000c5c:	4481                	li	s1,0
    count++;
    80000c5e:	0485                	addi	s1,s1,1
    r = r->next;
    80000c60:	639c                	ld	a5,0(a5)
  while(r){
    80000c62:	fff5                	bnez	a5,80000c5e <kfreemem+0x22>
  }
  release(&kmem.lock);
    80000c64:	0000f517          	auipc	a0,0xf
    80000c68:	d4c50513          	addi	a0,a0,-692 # 8000f9b0 <kmem>
    80000c6c:	12e000ef          	jal	80000d9a <release>
  return count * PGSIZE;
}
    80000c70:	00c49513          	slli	a0,s1,0xc
    80000c74:	60e2                	ld	ra,24(sp)
    80000c76:	6442                	ld	s0,16(sp)
    80000c78:	64a2                	ld	s1,8(sp)
    80000c7a:	6105                	addi	sp,sp,32
    80000c7c:	8082                	ret
  uint64 count = 0;
    80000c7e:	4481                	li	s1,0
    80000c80:	b7d5                	j	80000c64 <kfreemem+0x28>

0000000080000c82 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c82:	1141                	addi	sp,sp,-16
    80000c84:	e422                	sd	s0,8(sp)
    80000c86:	0800                	addi	s0,sp,16
  lk->name = name;
    80000c88:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000c8a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000c8e:	00053823          	sd	zero,16(a0)
}
    80000c92:	6422                	ld	s0,8(sp)
    80000c94:	0141                	addi	sp,sp,16
    80000c96:	8082                	ret

0000000080000c98 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c98:	411c                	lw	a5,0(a0)
    80000c9a:	e399                	bnez	a5,80000ca0 <holding+0x8>
    80000c9c:	4501                	li	a0,0
  return r;
}
    80000c9e:	8082                	ret
{
    80000ca0:	1101                	addi	sp,sp,-32
    80000ca2:	ec06                	sd	ra,24(sp)
    80000ca4:	e822                	sd	s0,16(sp)
    80000ca6:	e426                	sd	s1,8(sp)
    80000ca8:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000caa:	6904                	ld	s1,16(a0)
    80000cac:	60f000ef          	jal	80001aba <mycpu>
    80000cb0:	40a48533          	sub	a0,s1,a0
    80000cb4:	00153513          	seqz	a0,a0
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret

0000000080000cc2 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000cc2:	1101                	addi	sp,sp,-32
    80000cc4:	ec06                	sd	ra,24(sp)
    80000cc6:	e822                	sd	s0,16(sp)
    80000cc8:	e426                	sd	s1,8(sp)
    80000cca:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000ccc:	100024f3          	csrr	s1,sstatus
    80000cd0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000cd4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cd6:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000cda:	5e1000ef          	jal	80001aba <mycpu>
    80000cde:	5d3c                	lw	a5,120(a0)
    80000ce0:	cb99                	beqz	a5,80000cf6 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000ce2:	5d9000ef          	jal	80001aba <mycpu>
    80000ce6:	5d3c                	lw	a5,120(a0)
    80000ce8:	2785                	addiw	a5,a5,1
    80000cea:	dd3c                	sw	a5,120(a0)
}
    80000cec:	60e2                	ld	ra,24(sp)
    80000cee:	6442                	ld	s0,16(sp)
    80000cf0:	64a2                	ld	s1,8(sp)
    80000cf2:	6105                	addi	sp,sp,32
    80000cf4:	8082                	ret
    mycpu()->intena = old;
    80000cf6:	5c5000ef          	jal	80001aba <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000cfa:	8085                	srli	s1,s1,0x1
    80000cfc:	8885                	andi	s1,s1,1
    80000cfe:	dd64                	sw	s1,124(a0)
    80000d00:	b7cd                	j	80000ce2 <push_off+0x20>

0000000080000d02 <acquire>:
{
    80000d02:	1101                	addi	sp,sp,-32
    80000d04:	ec06                	sd	ra,24(sp)
    80000d06:	e822                	sd	s0,16(sp)
    80000d08:	e426                	sd	s1,8(sp)
    80000d0a:	1000                	addi	s0,sp,32
    80000d0c:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000d0e:	fb5ff0ef          	jal	80000cc2 <push_off>
  if(holding(lk))
    80000d12:	8526                	mv	a0,s1
    80000d14:	f85ff0ef          	jal	80000c98 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d18:	4705                	li	a4,1
  if(holding(lk))
    80000d1a:	e105                	bnez	a0,80000d3a <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d1c:	87ba                	mv	a5,a4
    80000d1e:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000d22:	2781                	sext.w	a5,a5
    80000d24:	ffe5                	bnez	a5,80000d1c <acquire+0x1a>
  __sync_synchronize();
    80000d26:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000d2a:	591000ef          	jal	80001aba <mycpu>
    80000d2e:	e888                	sd	a0,16(s1)
}
    80000d30:	60e2                	ld	ra,24(sp)
    80000d32:	6442                	ld	s0,16(sp)
    80000d34:	64a2                	ld	s1,8(sp)
    80000d36:	6105                	addi	sp,sp,32
    80000d38:	8082                	ret
    panic("acquire");
    80000d3a:	00006517          	auipc	a0,0x6
    80000d3e:	31650513          	addi	a0,a0,790 # 80007050 <etext+0x50>
    80000d42:	a9fff0ef          	jal	800007e0 <panic>

0000000080000d46 <pop_off>:

void
pop_off(void)
{
    80000d46:	1141                	addi	sp,sp,-16
    80000d48:	e406                	sd	ra,8(sp)
    80000d4a:	e022                	sd	s0,0(sp)
    80000d4c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000d4e:	56d000ef          	jal	80001aba <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d52:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000d56:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000d58:	e78d                	bnez	a5,80000d82 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000d5a:	5d3c                	lw	a5,120(a0)
    80000d5c:	02f05963          	blez	a5,80000d8e <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000d60:	37fd                	addiw	a5,a5,-1
    80000d62:	0007871b          	sext.w	a4,a5
    80000d66:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d68:	eb09                	bnez	a4,80000d7a <pop_off+0x34>
    80000d6a:	5d7c                	lw	a5,124(a0)
    80000d6c:	c799                	beqz	a5,80000d7a <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d6e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d72:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d76:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d7a:	60a2                	ld	ra,8(sp)
    80000d7c:	6402                	ld	s0,0(sp)
    80000d7e:	0141                	addi	sp,sp,16
    80000d80:	8082                	ret
    panic("pop_off - interruptible");
    80000d82:	00006517          	auipc	a0,0x6
    80000d86:	2d650513          	addi	a0,a0,726 # 80007058 <etext+0x58>
    80000d8a:	a57ff0ef          	jal	800007e0 <panic>
    panic("pop_off");
    80000d8e:	00006517          	auipc	a0,0x6
    80000d92:	2e250513          	addi	a0,a0,738 # 80007070 <etext+0x70>
    80000d96:	a4bff0ef          	jal	800007e0 <panic>

0000000080000d9a <release>:
{
    80000d9a:	1101                	addi	sp,sp,-32
    80000d9c:	ec06                	sd	ra,24(sp)
    80000d9e:	e822                	sd	s0,16(sp)
    80000da0:	e426                	sd	s1,8(sp)
    80000da2:	1000                	addi	s0,sp,32
    80000da4:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000da6:	ef3ff0ef          	jal	80000c98 <holding>
    80000daa:	c105                	beqz	a0,80000dca <release+0x30>
  lk->cpu = 0;
    80000dac:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000db0:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000db4:	0f50000f          	fence	iorw,ow
    80000db8:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000dbc:	f8bff0ef          	jal	80000d46 <pop_off>
}
    80000dc0:	60e2                	ld	ra,24(sp)
    80000dc2:	6442                	ld	s0,16(sp)
    80000dc4:	64a2                	ld	s1,8(sp)
    80000dc6:	6105                	addi	sp,sp,32
    80000dc8:	8082                	ret
    panic("release");
    80000dca:	00006517          	auipc	a0,0x6
    80000dce:	2ae50513          	addi	a0,a0,686 # 80007078 <etext+0x78>
    80000dd2:	a0fff0ef          	jal	800007e0 <panic>

0000000080000dd6 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000dd6:	1141                	addi	sp,sp,-16
    80000dd8:	e422                	sd	s0,8(sp)
    80000dda:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000ddc:	ca19                	beqz	a2,80000df2 <memset+0x1c>
    80000dde:	87aa                	mv	a5,a0
    80000de0:	1602                	slli	a2,a2,0x20
    80000de2:	9201                	srli	a2,a2,0x20
    80000de4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000de8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000dec:	0785                	addi	a5,a5,1
    80000dee:	fee79de3          	bne	a5,a4,80000de8 <memset+0x12>
  }
  return dst;
}
    80000df2:	6422                	ld	s0,8(sp)
    80000df4:	0141                	addi	sp,sp,16
    80000df6:	8082                	ret

0000000080000df8 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000df8:	1141                	addi	sp,sp,-16
    80000dfa:	e422                	sd	s0,8(sp)
    80000dfc:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000dfe:	ca05                	beqz	a2,80000e2e <memcmp+0x36>
    80000e00:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000e04:	1682                	slli	a3,a3,0x20
    80000e06:	9281                	srli	a3,a3,0x20
    80000e08:	0685                	addi	a3,a3,1
    80000e0a:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000e0c:	00054783          	lbu	a5,0(a0)
    80000e10:	0005c703          	lbu	a4,0(a1)
    80000e14:	00e79863          	bne	a5,a4,80000e24 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000e18:	0505                	addi	a0,a0,1
    80000e1a:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000e1c:	fed518e3          	bne	a0,a3,80000e0c <memcmp+0x14>
  }

  return 0;
    80000e20:	4501                	li	a0,0
    80000e22:	a019                	j	80000e28 <memcmp+0x30>
      return *s1 - *s2;
    80000e24:	40e7853b          	subw	a0,a5,a4
}
    80000e28:	6422                	ld	s0,8(sp)
    80000e2a:	0141                	addi	sp,sp,16
    80000e2c:	8082                	ret
  return 0;
    80000e2e:	4501                	li	a0,0
    80000e30:	bfe5                	j	80000e28 <memcmp+0x30>

0000000080000e32 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000e32:	1141                	addi	sp,sp,-16
    80000e34:	e422                	sd	s0,8(sp)
    80000e36:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000e38:	c205                	beqz	a2,80000e58 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000e3a:	02a5e263          	bltu	a1,a0,80000e5e <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000e3e:	1602                	slli	a2,a2,0x20
    80000e40:	9201                	srli	a2,a2,0x20
    80000e42:	00c587b3          	add	a5,a1,a2
{
    80000e46:	872a                	mv	a4,a0
      *d++ = *s++;
    80000e48:	0585                	addi	a1,a1,1
    80000e4a:	0705                	addi	a4,a4,1
    80000e4c:	fff5c683          	lbu	a3,-1(a1)
    80000e50:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000e54:	feb79ae3          	bne	a5,a1,80000e48 <memmove+0x16>

  return dst;
}
    80000e58:	6422                	ld	s0,8(sp)
    80000e5a:	0141                	addi	sp,sp,16
    80000e5c:	8082                	ret
  if(s < d && s + n > d){
    80000e5e:	02061693          	slli	a3,a2,0x20
    80000e62:	9281                	srli	a3,a3,0x20
    80000e64:	00d58733          	add	a4,a1,a3
    80000e68:	fce57be3          	bgeu	a0,a4,80000e3e <memmove+0xc>
    d += n;
    80000e6c:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000e6e:	fff6079b          	addiw	a5,a2,-1
    80000e72:	1782                	slli	a5,a5,0x20
    80000e74:	9381                	srli	a5,a5,0x20
    80000e76:	fff7c793          	not	a5,a5
    80000e7a:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000e7c:	177d                	addi	a4,a4,-1
    80000e7e:	16fd                	addi	a3,a3,-1
    80000e80:	00074603          	lbu	a2,0(a4)
    80000e84:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000e88:	fef71ae3          	bne	a4,a5,80000e7c <memmove+0x4a>
    80000e8c:	b7f1                	j	80000e58 <memmove+0x26>

0000000080000e8e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e8e:	1141                	addi	sp,sp,-16
    80000e90:	e406                	sd	ra,8(sp)
    80000e92:	e022                	sd	s0,0(sp)
    80000e94:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e96:	f9dff0ef          	jal	80000e32 <memmove>
}
    80000e9a:	60a2                	ld	ra,8(sp)
    80000e9c:	6402                	ld	s0,0(sp)
    80000e9e:	0141                	addi	sp,sp,16
    80000ea0:	8082                	ret

0000000080000ea2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000ea2:	1141                	addi	sp,sp,-16
    80000ea4:	e422                	sd	s0,8(sp)
    80000ea6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000ea8:	ce11                	beqz	a2,80000ec4 <strncmp+0x22>
    80000eaa:	00054783          	lbu	a5,0(a0)
    80000eae:	cf89                	beqz	a5,80000ec8 <strncmp+0x26>
    80000eb0:	0005c703          	lbu	a4,0(a1)
    80000eb4:	00f71a63          	bne	a4,a5,80000ec8 <strncmp+0x26>
    n--, p++, q++;
    80000eb8:	367d                	addiw	a2,a2,-1
    80000eba:	0505                	addi	a0,a0,1
    80000ebc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000ebe:	f675                	bnez	a2,80000eaa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000ec0:	4501                	li	a0,0
    80000ec2:	a801                	j	80000ed2 <strncmp+0x30>
    80000ec4:	4501                	li	a0,0
    80000ec6:	a031                	j	80000ed2 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000ec8:	00054503          	lbu	a0,0(a0)
    80000ecc:	0005c783          	lbu	a5,0(a1)
    80000ed0:	9d1d                	subw	a0,a0,a5
}
    80000ed2:	6422                	ld	s0,8(sp)
    80000ed4:	0141                	addi	sp,sp,16
    80000ed6:	8082                	ret

0000000080000ed8 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000ed8:	1141                	addi	sp,sp,-16
    80000eda:	e422                	sd	s0,8(sp)
    80000edc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000ede:	87aa                	mv	a5,a0
    80000ee0:	86b2                	mv	a3,a2
    80000ee2:	367d                	addiw	a2,a2,-1
    80000ee4:	02d05563          	blez	a3,80000f0e <strncpy+0x36>
    80000ee8:	0785                	addi	a5,a5,1
    80000eea:	0005c703          	lbu	a4,0(a1)
    80000eee:	fee78fa3          	sb	a4,-1(a5)
    80000ef2:	0585                	addi	a1,a1,1
    80000ef4:	f775                	bnez	a4,80000ee0 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000ef6:	873e                	mv	a4,a5
    80000ef8:	9fb5                	addw	a5,a5,a3
    80000efa:	37fd                	addiw	a5,a5,-1
    80000efc:	00c05963          	blez	a2,80000f0e <strncpy+0x36>
    *s++ = 0;
    80000f00:	0705                	addi	a4,a4,1
    80000f02:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000f06:	40e786bb          	subw	a3,a5,a4
    80000f0a:	fed04be3          	bgtz	a3,80000f00 <strncpy+0x28>
  return os;
}
    80000f0e:	6422                	ld	s0,8(sp)
    80000f10:	0141                	addi	sp,sp,16
    80000f12:	8082                	ret

0000000080000f14 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000f14:	1141                	addi	sp,sp,-16
    80000f16:	e422                	sd	s0,8(sp)
    80000f18:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000f1a:	02c05363          	blez	a2,80000f40 <safestrcpy+0x2c>
    80000f1e:	fff6069b          	addiw	a3,a2,-1
    80000f22:	1682                	slli	a3,a3,0x20
    80000f24:	9281                	srli	a3,a3,0x20
    80000f26:	96ae                	add	a3,a3,a1
    80000f28:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000f2a:	00d58963          	beq	a1,a3,80000f3c <safestrcpy+0x28>
    80000f2e:	0585                	addi	a1,a1,1
    80000f30:	0785                	addi	a5,a5,1
    80000f32:	fff5c703          	lbu	a4,-1(a1)
    80000f36:	fee78fa3          	sb	a4,-1(a5)
    80000f3a:	fb65                	bnez	a4,80000f2a <safestrcpy+0x16>
    ;
  *s = 0;
    80000f3c:	00078023          	sb	zero,0(a5)
  return os;
}
    80000f40:	6422                	ld	s0,8(sp)
    80000f42:	0141                	addi	sp,sp,16
    80000f44:	8082                	ret

0000000080000f46 <strlen>:

int
strlen(const char *s)
{
    80000f46:	1141                	addi	sp,sp,-16
    80000f48:	e422                	sd	s0,8(sp)
    80000f4a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f4c:	00054783          	lbu	a5,0(a0)
    80000f50:	cf91                	beqz	a5,80000f6c <strlen+0x26>
    80000f52:	0505                	addi	a0,a0,1
    80000f54:	87aa                	mv	a5,a0
    80000f56:	86be                	mv	a3,a5
    80000f58:	0785                	addi	a5,a5,1
    80000f5a:	fff7c703          	lbu	a4,-1(a5)
    80000f5e:	ff65                	bnez	a4,80000f56 <strlen+0x10>
    80000f60:	40a6853b          	subw	a0,a3,a0
    80000f64:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000f66:	6422                	ld	s0,8(sp)
    80000f68:	0141                	addi	sp,sp,16
    80000f6a:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f6c:	4501                	li	a0,0
    80000f6e:	bfe5                	j	80000f66 <strlen+0x20>

0000000080000f70 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f70:	1141                	addi	sp,sp,-16
    80000f72:	e406                	sd	ra,8(sp)
    80000f74:	e022                	sd	s0,0(sp)
    80000f76:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f78:	333000ef          	jal	80001aaa <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f7c:	00007717          	auipc	a4,0x7
    80000f80:	91470713          	addi	a4,a4,-1772 # 80007890 <started>
  if(cpuid() == 0){
    80000f84:	c51d                	beqz	a0,80000fb2 <main+0x42>
    while(started == 0)
    80000f86:	431c                	lw	a5,0(a4)
    80000f88:	2781                	sext.w	a5,a5
    80000f8a:	dff5                	beqz	a5,80000f86 <main+0x16>
      ;
    __sync_synchronize();
    80000f8c:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f90:	31b000ef          	jal	80001aaa <cpuid>
    80000f94:	85aa                	mv	a1,a0
    80000f96:	00006517          	auipc	a0,0x6
    80000f9a:	10a50513          	addi	a0,a0,266 # 800070a0 <etext+0xa0>
    80000f9e:	d5cff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000fa2:	080000ef          	jal	80001022 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000fa6:	738010ef          	jal	800026de <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000faa:	08f040ef          	jal	80005838 <plicinithart>
  }

  scheduler();        
    80000fae:	7af000ef          	jal	80001f5c <scheduler>
    consoleinit();
    80000fb2:	c72ff0ef          	jal	80000424 <consoleinit>
    printfinit();
    80000fb6:	867ff0ef          	jal	8000081c <printfinit>
    printf("\n");
    80000fba:	00006517          	auipc	a0,0x6
    80000fbe:	0c650513          	addi	a0,a0,198 # 80007080 <etext+0x80>
    80000fc2:	d38ff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    80000fc6:	00006517          	auipc	a0,0x6
    80000fca:	0c250513          	addi	a0,a0,194 # 80007088 <etext+0x88>
    80000fce:	d2cff0ef          	jal	800004fa <printf>
    printf("\n");
    80000fd2:	00006517          	auipc	a0,0x6
    80000fd6:	0ae50513          	addi	a0,a0,174 # 80007080 <etext+0x80>
    80000fda:	d20ff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    80000fde:	b4dff0ef          	jal	80000b2a <kinit>
    kvminit();       // create kernel page table
    80000fe2:	2ca000ef          	jal	800012ac <kvminit>
    kvminithart();   // turn on paging
    80000fe6:	03c000ef          	jal	80001022 <kvminithart>
    procinit();      // process table
    80000fea:	20b000ef          	jal	800019f4 <procinit>
    trapinit();      // trap vectors
    80000fee:	6cc010ef          	jal	800026ba <trapinit>
    trapinithart();  // install kernel trap vector
    80000ff2:	6ec010ef          	jal	800026de <trapinithart>
    plicinit();      // set up interrupt controller
    80000ff6:	029040ef          	jal	8000581e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ffa:	03f040ef          	jal	80005838 <plicinithart>
    binit();         // buffer cache
    80000ffe:	705010ef          	jal	80002f02 <binit>
    iinit();         // inode table
    80001002:	48a020ef          	jal	8000348c <iinit>
    fileinit();      // file table
    80001006:	37c030ef          	jal	80004382 <fileinit>
    virtio_disk_init(); // emulated hard disk
    8000100a:	11f040ef          	jal	80005928 <virtio_disk_init>
    userinit();      // first user process
    8000100e:	5a3000ef          	jal	80001db0 <userinit>
    __sync_synchronize();
    80001012:	0ff0000f          	fence
    started = 1;
    80001016:	4785                	li	a5,1
    80001018:	00007717          	auipc	a4,0x7
    8000101c:	86f72c23          	sw	a5,-1928(a4) # 80007890 <started>
    80001020:	b779                	j	80000fae <main+0x3e>

0000000080001022 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80001022:	1141                	addi	sp,sp,-16
    80001024:	e422                	sd	s0,8(sp)
    80001026:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001028:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    8000102c:	00007797          	auipc	a5,0x7
    80001030:	86c7b783          	ld	a5,-1940(a5) # 80007898 <kernel_pagetable>
    80001034:	83b1                	srli	a5,a5,0xc
    80001036:	577d                	li	a4,-1
    80001038:	177e                	slli	a4,a4,0x3f
    8000103a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000103c:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001040:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80001044:	6422                	ld	s0,8(sp)
    80001046:	0141                	addi	sp,sp,16
    80001048:	8082                	ret

000000008000104a <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000104a:	7139                	addi	sp,sp,-64
    8000104c:	fc06                	sd	ra,56(sp)
    8000104e:	f822                	sd	s0,48(sp)
    80001050:	f426                	sd	s1,40(sp)
    80001052:	f04a                	sd	s2,32(sp)
    80001054:	ec4e                	sd	s3,24(sp)
    80001056:	e852                	sd	s4,16(sp)
    80001058:	e456                	sd	s5,8(sp)
    8000105a:	e05a                	sd	s6,0(sp)
    8000105c:	0080                	addi	s0,sp,64
    8000105e:	84aa                	mv	s1,a0
    80001060:	89ae                	mv	s3,a1
    80001062:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001064:	57fd                	li	a5,-1
    80001066:	83e9                	srli	a5,a5,0x1a
    80001068:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000106a:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000106c:	02b7fc63          	bgeu	a5,a1,800010a4 <walk+0x5a>
    panic("walk");
    80001070:	00006517          	auipc	a0,0x6
    80001074:	04850513          	addi	a0,a0,72 # 800070b8 <etext+0xb8>
    80001078:	f68ff0ef          	jal	800007e0 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000107c:	060a8263          	beqz	s5,800010e0 <walk+0x96>
    80001080:	af3ff0ef          	jal	80000b72 <kalloc>
    80001084:	84aa                	mv	s1,a0
    80001086:	c139                	beqz	a0,800010cc <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001088:	6605                	lui	a2,0x1
    8000108a:	4581                	li	a1,0
    8000108c:	d4bff0ef          	jal	80000dd6 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001090:	00c4d793          	srli	a5,s1,0xc
    80001094:	07aa                	slli	a5,a5,0xa
    80001096:	0017e793          	ori	a5,a5,1
    8000109a:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000109e:	3a5d                	addiw	s4,s4,-9 # ff7 <_entry-0x7ffff009>
    800010a0:	036a0063          	beq	s4,s6,800010c0 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    800010a4:	0149d933          	srl	s2,s3,s4
    800010a8:	1ff97913          	andi	s2,s2,511
    800010ac:	090e                	slli	s2,s2,0x3
    800010ae:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010b0:	00093483          	ld	s1,0(s2)
    800010b4:	0014f793          	andi	a5,s1,1
    800010b8:	d3f1                	beqz	a5,8000107c <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010ba:	80a9                	srli	s1,s1,0xa
    800010bc:	04b2                	slli	s1,s1,0xc
    800010be:	b7c5                	j	8000109e <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    800010c0:	00c9d513          	srli	a0,s3,0xc
    800010c4:	1ff57513          	andi	a0,a0,511
    800010c8:	050e                	slli	a0,a0,0x3
    800010ca:	9526                	add	a0,a0,s1
}
    800010cc:	70e2                	ld	ra,56(sp)
    800010ce:	7442                	ld	s0,48(sp)
    800010d0:	74a2                	ld	s1,40(sp)
    800010d2:	7902                	ld	s2,32(sp)
    800010d4:	69e2                	ld	s3,24(sp)
    800010d6:	6a42                	ld	s4,16(sp)
    800010d8:	6aa2                	ld	s5,8(sp)
    800010da:	6b02                	ld	s6,0(sp)
    800010dc:	6121                	addi	sp,sp,64
    800010de:	8082                	ret
        return 0;
    800010e0:	4501                	li	a0,0
    800010e2:	b7ed                	j	800010cc <walk+0x82>

00000000800010e4 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010e4:	57fd                	li	a5,-1
    800010e6:	83e9                	srli	a5,a5,0x1a
    800010e8:	00b7f463          	bgeu	a5,a1,800010f0 <walkaddr+0xc>
    return 0;
    800010ec:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010ee:	8082                	ret
{
    800010f0:	1141                	addi	sp,sp,-16
    800010f2:	e406                	sd	ra,8(sp)
    800010f4:	e022                	sd	s0,0(sp)
    800010f6:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010f8:	4601                	li	a2,0
    800010fa:	f51ff0ef          	jal	8000104a <walk>
  if(pte == 0)
    800010fe:	c105                	beqz	a0,8000111e <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80001100:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001102:	0117f693          	andi	a3,a5,17
    80001106:	4745                	li	a4,17
    return 0;
    80001108:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000110a:	00e68663          	beq	a3,a4,80001116 <walkaddr+0x32>
}
    8000110e:	60a2                	ld	ra,8(sp)
    80001110:	6402                	ld	s0,0(sp)
    80001112:	0141                	addi	sp,sp,16
    80001114:	8082                	ret
  pa = PTE2PA(*pte);
    80001116:	83a9                	srli	a5,a5,0xa
    80001118:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000111c:	bfcd                	j	8000110e <walkaddr+0x2a>
    return 0;
    8000111e:	4501                	li	a0,0
    80001120:	b7fd                	j	8000110e <walkaddr+0x2a>

0000000080001122 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001122:	715d                	addi	sp,sp,-80
    80001124:	e486                	sd	ra,72(sp)
    80001126:	e0a2                	sd	s0,64(sp)
    80001128:	fc26                	sd	s1,56(sp)
    8000112a:	f84a                	sd	s2,48(sp)
    8000112c:	f44e                	sd	s3,40(sp)
    8000112e:	f052                	sd	s4,32(sp)
    80001130:	ec56                	sd	s5,24(sp)
    80001132:	e85a                	sd	s6,16(sp)
    80001134:	e45e                	sd	s7,8(sp)
    80001136:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001138:	03459793          	slli	a5,a1,0x34
    8000113c:	e7a9                	bnez	a5,80001186 <mappages+0x64>
    8000113e:	8aaa                	mv	s5,a0
    80001140:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001142:	03461793          	slli	a5,a2,0x34
    80001146:	e7b1                	bnez	a5,80001192 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    80001148:	ca39                	beqz	a2,8000119e <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    8000114a:	77fd                	lui	a5,0xfffff
    8000114c:	963e                	add	a2,a2,a5
    8000114e:	00b609b3          	add	s3,a2,a1
  a = va;
    80001152:	892e                	mv	s2,a1
    80001154:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001158:	6b85                	lui	s7,0x1
    8000115a:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    8000115e:	4605                	li	a2,1
    80001160:	85ca                	mv	a1,s2
    80001162:	8556                	mv	a0,s5
    80001164:	ee7ff0ef          	jal	8000104a <walk>
    80001168:	c539                	beqz	a0,800011b6 <mappages+0x94>
    if(*pte & PTE_V)
    8000116a:	611c                	ld	a5,0(a0)
    8000116c:	8b85                	andi	a5,a5,1
    8000116e:	ef95                	bnez	a5,800011aa <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001170:	80b1                	srli	s1,s1,0xc
    80001172:	04aa                	slli	s1,s1,0xa
    80001174:	0164e4b3          	or	s1,s1,s6
    80001178:	0014e493          	ori	s1,s1,1
    8000117c:	e104                	sd	s1,0(a0)
    if(a == last)
    8000117e:	05390863          	beq	s2,s3,800011ce <mappages+0xac>
    a += PGSIZE;
    80001182:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001184:	bfd9                	j	8000115a <mappages+0x38>
    panic("mappages: va not aligned");
    80001186:	00006517          	auipc	a0,0x6
    8000118a:	f3a50513          	addi	a0,a0,-198 # 800070c0 <etext+0xc0>
    8000118e:	e52ff0ef          	jal	800007e0 <panic>
    panic("mappages: size not aligned");
    80001192:	00006517          	auipc	a0,0x6
    80001196:	f4e50513          	addi	a0,a0,-178 # 800070e0 <etext+0xe0>
    8000119a:	e46ff0ef          	jal	800007e0 <panic>
    panic("mappages: size");
    8000119e:	00006517          	auipc	a0,0x6
    800011a2:	f6250513          	addi	a0,a0,-158 # 80007100 <etext+0x100>
    800011a6:	e3aff0ef          	jal	800007e0 <panic>
      panic("mappages: remap");
    800011aa:	00006517          	auipc	a0,0x6
    800011ae:	f6650513          	addi	a0,a0,-154 # 80007110 <etext+0x110>
    800011b2:	e2eff0ef          	jal	800007e0 <panic>
      return -1;
    800011b6:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800011b8:	60a6                	ld	ra,72(sp)
    800011ba:	6406                	ld	s0,64(sp)
    800011bc:	74e2                	ld	s1,56(sp)
    800011be:	7942                	ld	s2,48(sp)
    800011c0:	79a2                	ld	s3,40(sp)
    800011c2:	7a02                	ld	s4,32(sp)
    800011c4:	6ae2                	ld	s5,24(sp)
    800011c6:	6b42                	ld	s6,16(sp)
    800011c8:	6ba2                	ld	s7,8(sp)
    800011ca:	6161                	addi	sp,sp,80
    800011cc:	8082                	ret
  return 0;
    800011ce:	4501                	li	a0,0
    800011d0:	b7e5                	j	800011b8 <mappages+0x96>

00000000800011d2 <kvmmap>:
{
    800011d2:	1141                	addi	sp,sp,-16
    800011d4:	e406                	sd	ra,8(sp)
    800011d6:	e022                	sd	s0,0(sp)
    800011d8:	0800                	addi	s0,sp,16
    800011da:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800011dc:	86b2                	mv	a3,a2
    800011de:	863e                	mv	a2,a5
    800011e0:	f43ff0ef          	jal	80001122 <mappages>
    800011e4:	e509                	bnez	a0,800011ee <kvmmap+0x1c>
}
    800011e6:	60a2                	ld	ra,8(sp)
    800011e8:	6402                	ld	s0,0(sp)
    800011ea:	0141                	addi	sp,sp,16
    800011ec:	8082                	ret
    panic("kvmmap");
    800011ee:	00006517          	auipc	a0,0x6
    800011f2:	f3250513          	addi	a0,a0,-206 # 80007120 <etext+0x120>
    800011f6:	deaff0ef          	jal	800007e0 <panic>

00000000800011fa <kvmmake>:
{
    800011fa:	1101                	addi	sp,sp,-32
    800011fc:	ec06                	sd	ra,24(sp)
    800011fe:	e822                	sd	s0,16(sp)
    80001200:	e426                	sd	s1,8(sp)
    80001202:	e04a                	sd	s2,0(sp)
    80001204:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001206:	96dff0ef          	jal	80000b72 <kalloc>
    8000120a:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000120c:	6605                	lui	a2,0x1
    8000120e:	4581                	li	a1,0
    80001210:	bc7ff0ef          	jal	80000dd6 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001214:	4719                	li	a4,6
    80001216:	6685                	lui	a3,0x1
    80001218:	10000637          	lui	a2,0x10000
    8000121c:	100005b7          	lui	a1,0x10000
    80001220:	8526                	mv	a0,s1
    80001222:	fb1ff0ef          	jal	800011d2 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001226:	4719                	li	a4,6
    80001228:	6685                	lui	a3,0x1
    8000122a:	10001637          	lui	a2,0x10001
    8000122e:	100015b7          	lui	a1,0x10001
    80001232:	8526                	mv	a0,s1
    80001234:	f9fff0ef          	jal	800011d2 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001238:	4719                	li	a4,6
    8000123a:	040006b7          	lui	a3,0x4000
    8000123e:	0c000637          	lui	a2,0xc000
    80001242:	0c0005b7          	lui	a1,0xc000
    80001246:	8526                	mv	a0,s1
    80001248:	f8bff0ef          	jal	800011d2 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000124c:	00006917          	auipc	s2,0x6
    80001250:	db490913          	addi	s2,s2,-588 # 80007000 <etext>
    80001254:	4729                	li	a4,10
    80001256:	80006697          	auipc	a3,0x80006
    8000125a:	daa68693          	addi	a3,a3,-598 # 7000 <_entry-0x7fff9000>
    8000125e:	4605                	li	a2,1
    80001260:	067e                	slli	a2,a2,0x1f
    80001262:	85b2                	mv	a1,a2
    80001264:	8526                	mv	a0,s1
    80001266:	f6dff0ef          	jal	800011d2 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000126a:	46c5                	li	a3,17
    8000126c:	06ee                	slli	a3,a3,0x1b
    8000126e:	4719                	li	a4,6
    80001270:	412686b3          	sub	a3,a3,s2
    80001274:	864a                	mv	a2,s2
    80001276:	85ca                	mv	a1,s2
    80001278:	8526                	mv	a0,s1
    8000127a:	f59ff0ef          	jal	800011d2 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000127e:	4729                	li	a4,10
    80001280:	6685                	lui	a3,0x1
    80001282:	00005617          	auipc	a2,0x5
    80001286:	d7e60613          	addi	a2,a2,-642 # 80006000 <_trampoline>
    8000128a:	040005b7          	lui	a1,0x4000
    8000128e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001290:	05b2                	slli	a1,a1,0xc
    80001292:	8526                	mv	a0,s1
    80001294:	f3fff0ef          	jal	800011d2 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001298:	8526                	mv	a0,s1
    8000129a:	6c2000ef          	jal	8000195c <proc_mapstacks>
}
    8000129e:	8526                	mv	a0,s1
    800012a0:	60e2                	ld	ra,24(sp)
    800012a2:	6442                	ld	s0,16(sp)
    800012a4:	64a2                	ld	s1,8(sp)
    800012a6:	6902                	ld	s2,0(sp)
    800012a8:	6105                	addi	sp,sp,32
    800012aa:	8082                	ret

00000000800012ac <kvminit>:
{
    800012ac:	1141                	addi	sp,sp,-16
    800012ae:	e406                	sd	ra,8(sp)
    800012b0:	e022                	sd	s0,0(sp)
    800012b2:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800012b4:	f47ff0ef          	jal	800011fa <kvmmake>
    800012b8:	00006797          	auipc	a5,0x6
    800012bc:	5ea7b023          	sd	a0,1504(a5) # 80007898 <kernel_pagetable>
}
    800012c0:	60a2                	ld	ra,8(sp)
    800012c2:	6402                	ld	s0,0(sp)
    800012c4:	0141                	addi	sp,sp,16
    800012c6:	8082                	ret

00000000800012c8 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800012c8:	1101                	addi	sp,sp,-32
    800012ca:	ec06                	sd	ra,24(sp)
    800012cc:	e822                	sd	s0,16(sp)
    800012ce:	e426                	sd	s1,8(sp)
    800012d0:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800012d2:	8a1ff0ef          	jal	80000b72 <kalloc>
    800012d6:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800012d8:	c509                	beqz	a0,800012e2 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800012da:	6605                	lui	a2,0x1
    800012dc:	4581                	li	a1,0
    800012de:	af9ff0ef          	jal	80000dd6 <memset>
  return pagetable;
}
    800012e2:	8526                	mv	a0,s1
    800012e4:	60e2                	ld	ra,24(sp)
    800012e6:	6442                	ld	s0,16(sp)
    800012e8:	64a2                	ld	s1,8(sp)
    800012ea:	6105                	addi	sp,sp,32
    800012ec:	8082                	ret

00000000800012ee <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012ee:	7139                	addi	sp,sp,-64
    800012f0:	fc06                	sd	ra,56(sp)
    800012f2:	f822                	sd	s0,48(sp)
    800012f4:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012f6:	03459793          	slli	a5,a1,0x34
    800012fa:	e38d                	bnez	a5,8000131c <uvmunmap+0x2e>
    800012fc:	f04a                	sd	s2,32(sp)
    800012fe:	ec4e                	sd	s3,24(sp)
    80001300:	e852                	sd	s4,16(sp)
    80001302:	e456                	sd	s5,8(sp)
    80001304:	e05a                	sd	s6,0(sp)
    80001306:	8a2a                	mv	s4,a0
    80001308:	892e                	mv	s2,a1
    8000130a:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000130c:	0632                	slli	a2,a2,0xc
    8000130e:	00b609b3          	add	s3,a2,a1
    80001312:	6b05                	lui	s6,0x1
    80001314:	0535f963          	bgeu	a1,s3,80001366 <uvmunmap+0x78>
    80001318:	f426                	sd	s1,40(sp)
    8000131a:	a015                	j	8000133e <uvmunmap+0x50>
    8000131c:	f426                	sd	s1,40(sp)
    8000131e:	f04a                	sd	s2,32(sp)
    80001320:	ec4e                	sd	s3,24(sp)
    80001322:	e852                	sd	s4,16(sp)
    80001324:	e456                	sd	s5,8(sp)
    80001326:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    80001328:	00006517          	auipc	a0,0x6
    8000132c:	e0050513          	addi	a0,a0,-512 # 80007128 <etext+0x128>
    80001330:	cb0ff0ef          	jal	800007e0 <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001334:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001338:	995a                	add	s2,s2,s6
    8000133a:	03397563          	bgeu	s2,s3,80001364 <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    8000133e:	4601                	li	a2,0
    80001340:	85ca                	mv	a1,s2
    80001342:	8552                	mv	a0,s4
    80001344:	d07ff0ef          	jal	8000104a <walk>
    80001348:	84aa                	mv	s1,a0
    8000134a:	d57d                	beqz	a0,80001338 <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    8000134c:	611c                	ld	a5,0(a0)
    8000134e:	0017f713          	andi	a4,a5,1
    80001352:	d37d                	beqz	a4,80001338 <uvmunmap+0x4a>
    if(do_free){
    80001354:	fe0a80e3          	beqz	s5,80001334 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    80001358:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    8000135a:	00c79513          	slli	a0,a5,0xc
    8000135e:	ebeff0ef          	jal	80000a1c <kfree>
    80001362:	bfc9                	j	80001334 <uvmunmap+0x46>
    80001364:	74a2                	ld	s1,40(sp)
    80001366:	7902                	ld	s2,32(sp)
    80001368:	69e2                	ld	s3,24(sp)
    8000136a:	6a42                	ld	s4,16(sp)
    8000136c:	6aa2                	ld	s5,8(sp)
    8000136e:	6b02                	ld	s6,0(sp)
  }
}
    80001370:	70e2                	ld	ra,56(sp)
    80001372:	7442                	ld	s0,48(sp)
    80001374:	6121                	addi	sp,sp,64
    80001376:	8082                	ret

0000000080001378 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001378:	1101                	addi	sp,sp,-32
    8000137a:	ec06                	sd	ra,24(sp)
    8000137c:	e822                	sd	s0,16(sp)
    8000137e:	e426                	sd	s1,8(sp)
    80001380:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001382:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001384:	00b67d63          	bgeu	a2,a1,8000139e <uvmdealloc+0x26>
    80001388:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000138a:	6785                	lui	a5,0x1
    8000138c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000138e:	00f60733          	add	a4,a2,a5
    80001392:	76fd                	lui	a3,0xfffff
    80001394:	8f75                	and	a4,a4,a3
    80001396:	97ae                	add	a5,a5,a1
    80001398:	8ff5                	and	a5,a5,a3
    8000139a:	00f76863          	bltu	a4,a5,800013aa <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000139e:	8526                	mv	a0,s1
    800013a0:	60e2                	ld	ra,24(sp)
    800013a2:	6442                	ld	s0,16(sp)
    800013a4:	64a2                	ld	s1,8(sp)
    800013a6:	6105                	addi	sp,sp,32
    800013a8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013aa:	8f99                	sub	a5,a5,a4
    800013ac:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013ae:	4685                	li	a3,1
    800013b0:	0007861b          	sext.w	a2,a5
    800013b4:	85ba                	mv	a1,a4
    800013b6:	f39ff0ef          	jal	800012ee <uvmunmap>
    800013ba:	b7d5                	j	8000139e <uvmdealloc+0x26>

00000000800013bc <uvmalloc>:
  if(newsz < oldsz)
    800013bc:	08b66f63          	bltu	a2,a1,8000145a <uvmalloc+0x9e>
{
    800013c0:	7139                	addi	sp,sp,-64
    800013c2:	fc06                	sd	ra,56(sp)
    800013c4:	f822                	sd	s0,48(sp)
    800013c6:	ec4e                	sd	s3,24(sp)
    800013c8:	e852                	sd	s4,16(sp)
    800013ca:	e456                	sd	s5,8(sp)
    800013cc:	0080                	addi	s0,sp,64
    800013ce:	8aaa                	mv	s5,a0
    800013d0:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800013d2:	6785                	lui	a5,0x1
    800013d4:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013d6:	95be                	add	a1,a1,a5
    800013d8:	77fd                	lui	a5,0xfffff
    800013da:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800013de:	08c9f063          	bgeu	s3,a2,8000145e <uvmalloc+0xa2>
    800013e2:	f426                	sd	s1,40(sp)
    800013e4:	f04a                	sd	s2,32(sp)
    800013e6:	e05a                	sd	s6,0(sp)
    800013e8:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800013ea:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800013ee:	f84ff0ef          	jal	80000b72 <kalloc>
    800013f2:	84aa                	mv	s1,a0
    if(mem == 0){
    800013f4:	c515                	beqz	a0,80001420 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800013f6:	6605                	lui	a2,0x1
    800013f8:	4581                	li	a1,0
    800013fa:	9ddff0ef          	jal	80000dd6 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800013fe:	875a                	mv	a4,s6
    80001400:	86a6                	mv	a3,s1
    80001402:	6605                	lui	a2,0x1
    80001404:	85ca                	mv	a1,s2
    80001406:	8556                	mv	a0,s5
    80001408:	d1bff0ef          	jal	80001122 <mappages>
    8000140c:	e915                	bnez	a0,80001440 <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000140e:	6785                	lui	a5,0x1
    80001410:	993e                	add	s2,s2,a5
    80001412:	fd496ee3          	bltu	s2,s4,800013ee <uvmalloc+0x32>
  return newsz;
    80001416:	8552                	mv	a0,s4
    80001418:	74a2                	ld	s1,40(sp)
    8000141a:	7902                	ld	s2,32(sp)
    8000141c:	6b02                	ld	s6,0(sp)
    8000141e:	a811                	j	80001432 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    80001420:	864e                	mv	a2,s3
    80001422:	85ca                	mv	a1,s2
    80001424:	8556                	mv	a0,s5
    80001426:	f53ff0ef          	jal	80001378 <uvmdealloc>
      return 0;
    8000142a:	4501                	li	a0,0
    8000142c:	74a2                	ld	s1,40(sp)
    8000142e:	7902                	ld	s2,32(sp)
    80001430:	6b02                	ld	s6,0(sp)
}
    80001432:	70e2                	ld	ra,56(sp)
    80001434:	7442                	ld	s0,48(sp)
    80001436:	69e2                	ld	s3,24(sp)
    80001438:	6a42                	ld	s4,16(sp)
    8000143a:	6aa2                	ld	s5,8(sp)
    8000143c:	6121                	addi	sp,sp,64
    8000143e:	8082                	ret
      kfree(mem);
    80001440:	8526                	mv	a0,s1
    80001442:	ddaff0ef          	jal	80000a1c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001446:	864e                	mv	a2,s3
    80001448:	85ca                	mv	a1,s2
    8000144a:	8556                	mv	a0,s5
    8000144c:	f2dff0ef          	jal	80001378 <uvmdealloc>
      return 0;
    80001450:	4501                	li	a0,0
    80001452:	74a2                	ld	s1,40(sp)
    80001454:	7902                	ld	s2,32(sp)
    80001456:	6b02                	ld	s6,0(sp)
    80001458:	bfe9                	j	80001432 <uvmalloc+0x76>
    return oldsz;
    8000145a:	852e                	mv	a0,a1
}
    8000145c:	8082                	ret
  return newsz;
    8000145e:	8532                	mv	a0,a2
    80001460:	bfc9                	j	80001432 <uvmalloc+0x76>

0000000080001462 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001462:	7179                	addi	sp,sp,-48
    80001464:	f406                	sd	ra,40(sp)
    80001466:	f022                	sd	s0,32(sp)
    80001468:	ec26                	sd	s1,24(sp)
    8000146a:	e84a                	sd	s2,16(sp)
    8000146c:	e44e                	sd	s3,8(sp)
    8000146e:	e052                	sd	s4,0(sp)
    80001470:	1800                	addi	s0,sp,48
    80001472:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001474:	84aa                	mv	s1,a0
    80001476:	6905                	lui	s2,0x1
    80001478:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000147a:	4985                	li	s3,1
    8000147c:	a819                	j	80001492 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000147e:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001480:	00c79513          	slli	a0,a5,0xc
    80001484:	fdfff0ef          	jal	80001462 <freewalk>
      pagetable[i] = 0;
    80001488:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000148c:	04a1                	addi	s1,s1,8
    8000148e:	01248f63          	beq	s1,s2,800014ac <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001492:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001494:	00f7f713          	andi	a4,a5,15
    80001498:	ff3703e3          	beq	a4,s3,8000147e <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000149c:	8b85                	andi	a5,a5,1
    8000149e:	d7fd                	beqz	a5,8000148c <freewalk+0x2a>
      panic("freewalk: leaf");
    800014a0:	00006517          	auipc	a0,0x6
    800014a4:	ca050513          	addi	a0,a0,-864 # 80007140 <etext+0x140>
    800014a8:	b38ff0ef          	jal	800007e0 <panic>
    }
  }
  kfree((void*)pagetable);
    800014ac:	8552                	mv	a0,s4
    800014ae:	d6eff0ef          	jal	80000a1c <kfree>
}
    800014b2:	70a2                	ld	ra,40(sp)
    800014b4:	7402                	ld	s0,32(sp)
    800014b6:	64e2                	ld	s1,24(sp)
    800014b8:	6942                	ld	s2,16(sp)
    800014ba:	69a2                	ld	s3,8(sp)
    800014bc:	6a02                	ld	s4,0(sp)
    800014be:	6145                	addi	sp,sp,48
    800014c0:	8082                	ret

00000000800014c2 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800014c2:	1101                	addi	sp,sp,-32
    800014c4:	ec06                	sd	ra,24(sp)
    800014c6:	e822                	sd	s0,16(sp)
    800014c8:	e426                	sd	s1,8(sp)
    800014ca:	1000                	addi	s0,sp,32
    800014cc:	84aa                	mv	s1,a0
  if(sz > 0)
    800014ce:	e989                	bnez	a1,800014e0 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800014d0:	8526                	mv	a0,s1
    800014d2:	f91ff0ef          	jal	80001462 <freewalk>
}
    800014d6:	60e2                	ld	ra,24(sp)
    800014d8:	6442                	ld	s0,16(sp)
    800014da:	64a2                	ld	s1,8(sp)
    800014dc:	6105                	addi	sp,sp,32
    800014de:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800014e0:	6785                	lui	a5,0x1
    800014e2:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800014e4:	95be                	add	a1,a1,a5
    800014e6:	4685                	li	a3,1
    800014e8:	00c5d613          	srli	a2,a1,0xc
    800014ec:	4581                	li	a1,0
    800014ee:	e01ff0ef          	jal	800012ee <uvmunmap>
    800014f2:	bff9                	j	800014d0 <uvmfree+0xe>

00000000800014f4 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  // char *mem; // No longer needed for CoW

  for(i = 0; i < sz; i += PGSIZE){
    800014f4:	c245                	beqz	a2,80001594 <uvmcopy+0xa0>
{
    800014f6:	7139                	addi	sp,sp,-64
    800014f8:	fc06                	sd	ra,56(sp)
    800014fa:	f822                	sd	s0,48(sp)
    800014fc:	f426                	sd	s1,40(sp)
    800014fe:	f04a                	sd	s2,32(sp)
    80001500:	ec4e                	sd	s3,24(sp)
    80001502:	e852                	sd	s4,16(sp)
    80001504:	e456                	sd	s5,8(sp)
    80001506:	0080                	addi	s0,sp,64
    80001508:	89aa                	mv	s3,a0
    8000150a:	8a2e                	mv	s4,a1
    8000150c:	8932                	mv	s2,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000150e:	4481                	li	s1,0
    80001510:	a805                	j	80001540 <uvmcopy+0x4c>
    flags = PTE_FLAGS(*pte);

    // For read-only sharing (CoW), mark as read-only and set PTE_COW
    if(flags & PTE_W) {
        // Turn off Write, Turn on Cow
        flags &= ~PTE_W;
    80001512:	3fb77713          	andi	a4,a4,1019
        flags |= PTE_COW;
    80001516:	10076713          	ori	a4,a4,256
        
        // Update Parent's PTE to reflect this change immediately
        *pte = (*pte & ~PTE_W) | PTE_COW;
    8000151a:	efb7f793          	andi	a5,a5,-261
    8000151e:	1007e793          	ori	a5,a5,256
    80001522:	e11c                	sd	a5,0(a0)
    }

    // Map the Child's page to the SAME physical address
    // using the (potentially modified) flags.
    if(mappages(new, i, PGSIZE, pa, flags) != 0){
    80001524:	86d6                	mv	a3,s5
    80001526:	6605                	lui	a2,0x1
    80001528:	85a6                	mv	a1,s1
    8000152a:	8552                	mv	a0,s4
    8000152c:	bf7ff0ef          	jal	80001122 <mappages>
    80001530:	ed0d                	bnez	a0,8000156a <uvmcopy+0x76>
      goto err;
    }

    // Increment Reference Count for the physical page
    krefinc((void*)pa);
    80001532:	8556                	mv	a0,s5
    80001534:	ec2ff0ef          	jal	80000bf6 <krefinc>
  for(i = 0; i < sz; i += PGSIZE){
    80001538:	6785                	lui	a5,0x1
    8000153a:	94be                	add	s1,s1,a5
    8000153c:	0524f063          	bgeu	s1,s2,8000157c <uvmcopy+0x88>
    if((pte = walk(old, i, 0)) == 0)
    80001540:	4601                	li	a2,0
    80001542:	85a6                	mv	a1,s1
    80001544:	854e                	mv	a0,s3
    80001546:	b05ff0ef          	jal	8000104a <walk>
    8000154a:	d57d                	beqz	a0,80001538 <uvmcopy+0x44>
    if((*pte & PTE_V) == 0)
    8000154c:	611c                	ld	a5,0(a0)
    8000154e:	0017f713          	andi	a4,a5,1
    80001552:	d37d                	beqz	a4,80001538 <uvmcopy+0x44>
    pa = PTE2PA(*pte);
    80001554:	00a7da93          	srli	s5,a5,0xa
    80001558:	0ab2                	slli	s5,s5,0xc
    flags = PTE_FLAGS(*pte);
    8000155a:	0007871b          	sext.w	a4,a5
    if(flags & PTE_W) {
    8000155e:	0047f693          	andi	a3,a5,4
    80001562:	fac5                	bnez	a3,80001512 <uvmcopy+0x1e>
    flags = PTE_FLAGS(*pte);
    80001564:	3ff77713          	andi	a4,a4,1023
    80001568:	bf75                	j	80001524 <uvmcopy+0x30>
  sfence_vma(); 

  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000156a:	4685                	li	a3,1
    8000156c:	00c4d613          	srli	a2,s1,0xc
    80001570:	4581                	li	a1,0
    80001572:	8552                	mv	a0,s4
    80001574:	d7bff0ef          	jal	800012ee <uvmunmap>
  return -1;
    80001578:	557d                	li	a0,-1
    8000157a:	a021                	j	80001582 <uvmcopy+0x8e>
    8000157c:	12000073          	sfence.vma
  return 0;
    80001580:	4501                	li	a0,0
}
    80001582:	70e2                	ld	ra,56(sp)
    80001584:	7442                	ld	s0,48(sp)
    80001586:	74a2                	ld	s1,40(sp)
    80001588:	7902                	ld	s2,32(sp)
    8000158a:	69e2                	ld	s3,24(sp)
    8000158c:	6a42                	ld	s4,16(sp)
    8000158e:	6aa2                	ld	s5,8(sp)
    80001590:	6121                	addi	sp,sp,64
    80001592:	8082                	ret
    80001594:	12000073          	sfence.vma
  return 0;
    80001598:	4501                	li	a0,0
}
    8000159a:	8082                	ret

000000008000159c <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000159c:	1141                	addi	sp,sp,-16
    8000159e:	e406                	sd	ra,8(sp)
    800015a0:	e022                	sd	s0,0(sp)
    800015a2:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800015a4:	4601                	li	a2,0
    800015a6:	aa5ff0ef          	jal	8000104a <walk>
  if(pte == 0)
    800015aa:	c901                	beqz	a0,800015ba <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800015ac:	611c                	ld	a5,0(a0)
    800015ae:	9bbd                	andi	a5,a5,-17
    800015b0:	e11c                	sd	a5,0(a0)
}
    800015b2:	60a2                	ld	ra,8(sp)
    800015b4:	6402                	ld	s0,0(sp)
    800015b6:	0141                	addi	sp,sp,16
    800015b8:	8082                	ret
    panic("uvmclear");
    800015ba:	00006517          	auipc	a0,0x6
    800015be:	b9650513          	addi	a0,a0,-1130 # 80007150 <etext+0x150>
    800015c2:	a1eff0ef          	jal	800007e0 <panic>

00000000800015c6 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800015c6:	c6dd                	beqz	a3,80001674 <copyinstr+0xae>
{
    800015c8:	715d                	addi	sp,sp,-80
    800015ca:	e486                	sd	ra,72(sp)
    800015cc:	e0a2                	sd	s0,64(sp)
    800015ce:	fc26                	sd	s1,56(sp)
    800015d0:	f84a                	sd	s2,48(sp)
    800015d2:	f44e                	sd	s3,40(sp)
    800015d4:	f052                	sd	s4,32(sp)
    800015d6:	ec56                	sd	s5,24(sp)
    800015d8:	e85a                	sd	s6,16(sp)
    800015da:	e45e                	sd	s7,8(sp)
    800015dc:	0880                	addi	s0,sp,80
    800015de:	8a2a                	mv	s4,a0
    800015e0:	8b2e                	mv	s6,a1
    800015e2:	8bb2                	mv	s7,a2
    800015e4:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800015e6:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800015e8:	6985                	lui	s3,0x1
    800015ea:	a825                	j	80001622 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800015ec:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800015f0:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800015f2:	37fd                	addiw	a5,a5,-1
    800015f4:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800015f8:	60a6                	ld	ra,72(sp)
    800015fa:	6406                	ld	s0,64(sp)
    800015fc:	74e2                	ld	s1,56(sp)
    800015fe:	7942                	ld	s2,48(sp)
    80001600:	79a2                	ld	s3,40(sp)
    80001602:	7a02                	ld	s4,32(sp)
    80001604:	6ae2                	ld	s5,24(sp)
    80001606:	6b42                	ld	s6,16(sp)
    80001608:	6ba2                	ld	s7,8(sp)
    8000160a:	6161                	addi	sp,sp,80
    8000160c:	8082                	ret
    8000160e:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    80001612:	9742                	add	a4,a4,a6
      --max;
    80001614:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001618:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    8000161c:	04e58463          	beq	a1,a4,80001664 <copyinstr+0x9e>
{
    80001620:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80001622:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001626:	85a6                	mv	a1,s1
    80001628:	8552                	mv	a0,s4
    8000162a:	abbff0ef          	jal	800010e4 <walkaddr>
    if(pa0 == 0)
    8000162e:	cd0d                	beqz	a0,80001668 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001630:	417486b3          	sub	a3,s1,s7
    80001634:	96ce                	add	a3,a3,s3
    if(n > max)
    80001636:	00d97363          	bgeu	s2,a3,8000163c <copyinstr+0x76>
    8000163a:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    8000163c:	955e                	add	a0,a0,s7
    8000163e:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001640:	c695                	beqz	a3,8000166c <copyinstr+0xa6>
    80001642:	87da                	mv	a5,s6
    80001644:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001646:	41650633          	sub	a2,a0,s6
    while(n > 0){
    8000164a:	96da                	add	a3,a3,s6
    8000164c:	85be                	mv	a1,a5
      if(*p == '\0'){
    8000164e:	00f60733          	add	a4,a2,a5
    80001652:	00074703          	lbu	a4,0(a4)
    80001656:	db59                	beqz	a4,800015ec <copyinstr+0x26>
        *dst = *p;
    80001658:	00e78023          	sb	a4,0(a5)
      dst++;
    8000165c:	0785                	addi	a5,a5,1
    while(n > 0){
    8000165e:	fed797e3          	bne	a5,a3,8000164c <copyinstr+0x86>
    80001662:	b775                	j	8000160e <copyinstr+0x48>
    80001664:	4781                	li	a5,0
    80001666:	b771                	j	800015f2 <copyinstr+0x2c>
      return -1;
    80001668:	557d                	li	a0,-1
    8000166a:	b779                	j	800015f8 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    8000166c:	6b85                	lui	s7,0x1
    8000166e:	9ba6                	add	s7,s7,s1
    80001670:	87da                	mv	a5,s6
    80001672:	b77d                	j	80001620 <copyinstr+0x5a>
  int got_null = 0;
    80001674:	4781                	li	a5,0
  if(got_null){
    80001676:	37fd                	addiw	a5,a5,-1
    80001678:	0007851b          	sext.w	a0,a5
}
    8000167c:	8082                	ret

000000008000167e <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    8000167e:	1141                	addi	sp,sp,-16
    80001680:	e406                	sd	ra,8(sp)
    80001682:	e022                	sd	s0,0(sp)
    80001684:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    80001686:	4601                	li	a2,0
    80001688:	9c3ff0ef          	jal	8000104a <walk>
  if (pte == 0) {
    8000168c:	c519                	beqz	a0,8000169a <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    8000168e:	6108                	ld	a0,0(a0)
    80001690:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80001692:	60a2                	ld	ra,8(sp)
    80001694:	6402                	ld	s0,0(sp)
    80001696:	0141                	addi	sp,sp,16
    80001698:	8082                	ret
    return 0;
    8000169a:	4501                	li	a0,0
    8000169c:	bfdd                	j	80001692 <ismapped+0x14>

000000008000169e <vmfault>:
{
    8000169e:	7179                	addi	sp,sp,-48
    800016a0:	f406                	sd	ra,40(sp)
    800016a2:	f022                	sd	s0,32(sp)
    800016a4:	ec26                	sd	s1,24(sp)
    800016a6:	e44e                	sd	s3,8(sp)
    800016a8:	1800                	addi	s0,sp,48
    800016aa:	89aa                	mv	s3,a0
    800016ac:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    800016ae:	428000ef          	jal	80001ad6 <myproc>
  if (va >= p->sz)
    800016b2:	713c                	ld	a5,96(a0)
    800016b4:	00f4ea63          	bltu	s1,a5,800016c8 <vmfault+0x2a>
    return 0;
    800016b8:	4981                	li	s3,0
}
    800016ba:	854e                	mv	a0,s3
    800016bc:	70a2                	ld	ra,40(sp)
    800016be:	7402                	ld	s0,32(sp)
    800016c0:	64e2                	ld	s1,24(sp)
    800016c2:	69a2                	ld	s3,8(sp)
    800016c4:	6145                	addi	sp,sp,48
    800016c6:	8082                	ret
    800016c8:	e84a                	sd	s2,16(sp)
    800016ca:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    800016cc:	77fd                	lui	a5,0xfffff
    800016ce:	8cfd                	and	s1,s1,a5
  if(ismapped(pagetable, va)) {
    800016d0:	85a6                	mv	a1,s1
    800016d2:	854e                	mv	a0,s3
    800016d4:	fabff0ef          	jal	8000167e <ismapped>
    return 0;
    800016d8:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    800016da:	c119                	beqz	a0,800016e0 <vmfault+0x42>
    800016dc:	6942                	ld	s2,16(sp)
    800016de:	bff1                	j	800016ba <vmfault+0x1c>
    800016e0:	e052                	sd	s4,0(sp)
  mem = (uint64) kalloc();
    800016e2:	c90ff0ef          	jal	80000b72 <kalloc>
    800016e6:	8a2a                	mv	s4,a0
  if(mem == 0)
    800016e8:	c90d                	beqz	a0,8000171a <vmfault+0x7c>
  mem = (uint64) kalloc();
    800016ea:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    800016ec:	6605                	lui	a2,0x1
    800016ee:	4581                	li	a1,0
    800016f0:	ee6ff0ef          	jal	80000dd6 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    800016f4:	4759                	li	a4,22
    800016f6:	86d2                	mv	a3,s4
    800016f8:	6605                	lui	a2,0x1
    800016fa:	85a6                	mv	a1,s1
    800016fc:	06893503          	ld	a0,104(s2)
    80001700:	a23ff0ef          	jal	80001122 <mappages>
    80001704:	e501                	bnez	a0,8000170c <vmfault+0x6e>
    80001706:	6942                	ld	s2,16(sp)
    80001708:	6a02                	ld	s4,0(sp)
    8000170a:	bf45                	j	800016ba <vmfault+0x1c>
    kfree((void *)mem);
    8000170c:	8552                	mv	a0,s4
    8000170e:	b0eff0ef          	jal	80000a1c <kfree>
    return 0;
    80001712:	4981                	li	s3,0
    80001714:	6942                	ld	s2,16(sp)
    80001716:	6a02                	ld	s4,0(sp)
    80001718:	b74d                	j	800016ba <vmfault+0x1c>
    8000171a:	6942                	ld	s2,16(sp)
    8000171c:	6a02                	ld	s4,0(sp)
    8000171e:	bf71                	j	800016ba <vmfault+0x1c>

0000000080001720 <copyin>:
  while(len > 0){
    80001720:	c6c9                	beqz	a3,800017aa <copyin+0x8a>
{
    80001722:	715d                	addi	sp,sp,-80
    80001724:	e486                	sd	ra,72(sp)
    80001726:	e0a2                	sd	s0,64(sp)
    80001728:	fc26                	sd	s1,56(sp)
    8000172a:	f84a                	sd	s2,48(sp)
    8000172c:	f44e                	sd	s3,40(sp)
    8000172e:	f052                	sd	s4,32(sp)
    80001730:	ec56                	sd	s5,24(sp)
    80001732:	e85a                	sd	s6,16(sp)
    80001734:	e45e                	sd	s7,8(sp)
    80001736:	e062                	sd	s8,0(sp)
    80001738:	0880                	addi	s0,sp,80
    8000173a:	8baa                	mv	s7,a0
    8000173c:	8aae                	mv	s5,a1
    8000173e:	8932                	mv	s2,a2
    80001740:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80001742:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80001744:	6b05                	lui	s6,0x1
    80001746:	a035                	j	80001772 <copyin+0x52>
    80001748:	412984b3          	sub	s1,s3,s2
    8000174c:	94da                	add	s1,s1,s6
    if(n > len)
    8000174e:	009a7363          	bgeu	s4,s1,80001754 <copyin+0x34>
    80001752:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001754:	413905b3          	sub	a1,s2,s3
    80001758:	0004861b          	sext.w	a2,s1
    8000175c:	95aa                	add	a1,a1,a0
    8000175e:	8556                	mv	a0,s5
    80001760:	ed2ff0ef          	jal	80000e32 <memmove>
    len -= n;
    80001764:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001768:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    8000176a:	01698933          	add	s2,s3,s6
  while(len > 0){
    8000176e:	020a0163          	beqz	s4,80001790 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001772:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001776:	85ce                	mv	a1,s3
    80001778:	855e                	mv	a0,s7
    8000177a:	96bff0ef          	jal	800010e4 <walkaddr>
    if(pa0 == 0) {
    8000177e:	f569                	bnez	a0,80001748 <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001780:	4601                	li	a2,0
    80001782:	85ce                	mv	a1,s3
    80001784:	855e                	mv	a0,s7
    80001786:	f19ff0ef          	jal	8000169e <vmfault>
    8000178a:	fd5d                	bnez	a0,80001748 <copyin+0x28>
        return -1;
    8000178c:	557d                	li	a0,-1
    8000178e:	a011                	j	80001792 <copyin+0x72>
  return 0;
    80001790:	4501                	li	a0,0
}
    80001792:	60a6                	ld	ra,72(sp)
    80001794:	6406                	ld	s0,64(sp)
    80001796:	74e2                	ld	s1,56(sp)
    80001798:	7942                	ld	s2,48(sp)
    8000179a:	79a2                	ld	s3,40(sp)
    8000179c:	7a02                	ld	s4,32(sp)
    8000179e:	6ae2                	ld	s5,24(sp)
    800017a0:	6b42                	ld	s6,16(sp)
    800017a2:	6ba2                	ld	s7,8(sp)
    800017a4:	6c02                	ld	s8,0(sp)
    800017a6:	6161                	addi	sp,sp,80
    800017a8:	8082                	ret
  return 0;
    800017aa:	4501                	li	a0,0
}
    800017ac:	8082                	ret

00000000800017ae <cowalloc>:
  pte_t *pte;
  uint64 pa;
  uint64 flags;
  char *mem;

  if(va >= MAXVA) return -1;
    800017ae:	57fd                	li	a5,-1
    800017b0:	83e9                	srli	a5,a5,0x1a
    800017b2:	06b7ee63          	bltu	a5,a1,8000182e <cowalloc+0x80>
{
    800017b6:	7179                	addi	sp,sp,-48
    800017b8:	f406                	sd	ra,40(sp)
    800017ba:	f022                	sd	s0,32(sp)
    800017bc:	e44e                	sd	s3,8(sp)
    800017be:	1800                	addi	s0,sp,48

  pte = walk(pagetable, va, 0);
    800017c0:	4601                	li	a2,0
    800017c2:	889ff0ef          	jal	8000104a <walk>
    800017c6:	89aa                	mv	s3,a0
  if(pte == 0) return -1;
    800017c8:	c52d                	beqz	a0,80001832 <cowalloc+0x84>
    800017ca:	e84a                	sd	s2,16(sp)
  if((*pte & PTE_V) == 0) return -1;
    800017cc:	00053903          	ld	s2,0(a0)
  if((*pte & PTE_U) == 0) return -1;
    800017d0:	01197713          	andi	a4,s2,17
    800017d4:	47c5                	li	a5,17
    800017d6:	06f71063          	bne	a4,a5,80001836 <cowalloc+0x88>

  // If it's already writable, nothing to do (not CoW)
  if(*pte & PTE_W) return 0;
    800017da:	00497793          	andi	a5,s2,4
    800017de:	4501                	li	a0,0
    800017e0:	e7b5                	bnez	a5,8000184c <cowalloc+0x9e>

  // If NOT writable and NOT CoW, it's a true Read-Only page (segfault)
  if((*pte & PTE_COW) == 0) return -1;
    800017e2:	10097793          	andi	a5,s2,256
    800017e6:	cbb9                	beqz	a5,8000183c <cowalloc+0x8e>
    800017e8:	ec26                	sd	s1,24(sp)
    800017ea:	e052                	sd	s4,0(sp)

  // It IS a CoW page. Execute the split.
  pa = PTE2PA(*pte);
    800017ec:	00a95a13          	srli	s4,s2,0xa
    800017f0:	0a32                	slli	s4,s4,0xc
  flags = PTE_FLAGS(*pte);

  // Allocate new physical page
  if((mem = kalloc()) == 0) return -1;
    800017f2:	b80ff0ef          	jal	80000b72 <kalloc>
    800017f6:	84aa                	mv	s1,a0
    800017f8:	c529                	beqz	a0,80001842 <cowalloc+0x94>

  // Copy data from old (shared) page to new (private) page
  memmove(mem, (char*)pa, PGSIZE);
    800017fa:	6605                	lui	a2,0x1
    800017fc:	85d2                	mv	a1,s4
    800017fe:	e34ff0ef          	jal	80000e32 <memmove>
  flags &= ~PTE_COW;

  // Remap the PTE to point to the new private page
  // This overwrites the old mapping.
  // Note: We use flags directly (which include PTE_V)
  *pte = PA2PTE(mem) | flags;
    80001802:	80b1                	srli	s1,s1,0xc
    80001804:	04aa                	slli	s1,s1,0xa
    80001806:	2ff97913          	andi	s2,s2,767
    8000180a:	0124e4b3          	or	s1,s1,s2
    8000180e:	0044e493          	ori	s1,s1,4
    80001812:	0099b023          	sd	s1,0(s3) # 1000 <_entry-0x7ffff000>

  // Decrement reference count of the OLD shared page
  kfree((void*)pa); 
    80001816:	8552                	mv	a0,s4
    80001818:	a04ff0ef          	jal	80000a1c <kfree>

  return 0;
    8000181c:	4501                	li	a0,0
    8000181e:	64e2                	ld	s1,24(sp)
    80001820:	6942                	ld	s2,16(sp)
    80001822:	6a02                	ld	s4,0(sp)
}
    80001824:	70a2                	ld	ra,40(sp)
    80001826:	7402                	ld	s0,32(sp)
    80001828:	69a2                	ld	s3,8(sp)
    8000182a:	6145                	addi	sp,sp,48
    8000182c:	8082                	ret
  if(va >= MAXVA) return -1;
    8000182e:	557d                	li	a0,-1
}
    80001830:	8082                	ret
  if(pte == 0) return -1;
    80001832:	557d                	li	a0,-1
    80001834:	bfc5                	j	80001824 <cowalloc+0x76>
  if((*pte & PTE_U) == 0) return -1;
    80001836:	557d                	li	a0,-1
    80001838:	6942                	ld	s2,16(sp)
    8000183a:	b7ed                	j	80001824 <cowalloc+0x76>
  if((*pte & PTE_COW) == 0) return -1;
    8000183c:	557d                	li	a0,-1
    8000183e:	6942                	ld	s2,16(sp)
    80001840:	b7d5                	j	80001824 <cowalloc+0x76>
  if((mem = kalloc()) == 0) return -1;
    80001842:	557d                	li	a0,-1
    80001844:	64e2                	ld	s1,24(sp)
    80001846:	6942                	ld	s2,16(sp)
    80001848:	6a02                	ld	s4,0(sp)
    8000184a:	bfe9                	j	80001824 <cowalloc+0x76>
    8000184c:	6942                	ld	s2,16(sp)
    8000184e:	bfd9                	j	80001824 <cowalloc+0x76>

0000000080001850 <copyout>:
  while(len > 0){
    80001850:	cec5                	beqz	a3,80001908 <copyout+0xb8>
{
    80001852:	711d                	addi	sp,sp,-96
    80001854:	ec86                	sd	ra,88(sp)
    80001856:	e8a2                	sd	s0,80(sp)
    80001858:	e4a6                	sd	s1,72(sp)
    8000185a:	fc4e                	sd	s3,56(sp)
    8000185c:	f456                	sd	s5,40(sp)
    8000185e:	f05a                	sd	s6,32(sp)
    80001860:	ec5e                	sd	s7,24(sp)
    80001862:	1080                	addi	s0,sp,96
    80001864:	8aaa                	mv	s5,a0
    80001866:	8b2e                	mv	s6,a1
    80001868:	8bb2                	mv	s7,a2
    8000186a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000186c:	74fd                	lui	s1,0xfffff
    8000186e:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001870:	57fd                	li	a5,-1
    80001872:	83e9                	srli	a5,a5,0x1a
    80001874:	0897ec63          	bltu	a5,s1,8000190c <copyout+0xbc>
    80001878:	e0ca                	sd	s2,64(sp)
    8000187a:	f852                	sd	s4,48(sp)
    8000187c:	e862                	sd	s8,16(sp)
    8000187e:	e466                	sd	s9,8(sp)
    80001880:	6c85                	lui	s9,0x1
    80001882:	8c3e                	mv	s8,a5
    80001884:	a015                	j	800018a8 <copyout+0x58>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001886:	409b04b3          	sub	s1,s6,s1
    8000188a:	0009061b          	sext.w	a2,s2
    8000188e:	85de                	mv	a1,s7
    80001890:	9526                	add	a0,a0,s1
    80001892:	da0ff0ef          	jal	80000e32 <memmove>
    len -= n;
    80001896:	412989b3          	sub	s3,s3,s2
    src += n;
    8000189a:	9bca                	add	s7,s7,s2
  while(len > 0){
    8000189c:	06098063          	beqz	s3,800018fc <copyout+0xac>
    if(va0 >= MAXVA)
    800018a0:	074c6863          	bltu	s8,s4,80001910 <copyout+0xc0>
    800018a4:	84d2                	mv	s1,s4
    800018a6:	8b52                	mv	s6,s4
    pa0 = walkaddr(pagetable, va0);
    800018a8:	85a6                	mv	a1,s1
    800018aa:	8556                	mv	a0,s5
    800018ac:	839ff0ef          	jal	800010e4 <walkaddr>
    if(pa0 == 0) {
    800018b0:	e519                	bnez	a0,800018be <copyout+0x6e>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800018b2:	4601                	li	a2,0
    800018b4:	85a6                	mv	a1,s1
    800018b6:	8556                	mv	a0,s5
    800018b8:	de7ff0ef          	jal	8000169e <vmfault>
    800018bc:	c125                	beqz	a0,8000191c <copyout+0xcc>
    pte = walk(pagetable, va0, 0);
    800018be:	4601                	li	a2,0
    800018c0:	85a6                	mv	a1,s1
    800018c2:	8556                	mv	a0,s5
    800018c4:	f86ff0ef          	jal	8000104a <walk>
    if((*pte & PTE_W) == 0) {
    800018c8:	611c                	ld	a5,0(a0)
    800018ca:	0047f713          	andi	a4,a5,4
    800018ce:	eb11                	bnez	a4,800018e2 <copyout+0x92>
        if(*pte & PTE_COW) {
    800018d0:	1007f793          	andi	a5,a5,256
    800018d4:	cbb1                	beqz	a5,80001928 <copyout+0xd8>
            if(cowalloc(pagetable, va0) < 0)
    800018d6:	85a6                	mv	a1,s1
    800018d8:	8556                	mv	a0,s5
    800018da:	ed5ff0ef          	jal	800017ae <cowalloc>
    800018de:	04054b63          	bltz	a0,80001934 <copyout+0xe4>
    pa0 = walkaddr(pagetable, va0);
    800018e2:	85a6                	mv	a1,s1
    800018e4:	8556                	mv	a0,s5
    800018e6:	ffeff0ef          	jal	800010e4 <walkaddr>
    if(pa0 == 0) return -1;
    800018ea:	c939                	beqz	a0,80001940 <copyout+0xf0>
    n = PGSIZE - (dstva - va0);
    800018ec:	01948a33          	add	s4,s1,s9
    800018f0:	416a0933          	sub	s2,s4,s6
    if(n > len)
    800018f4:	f929f9e3          	bgeu	s3,s2,80001886 <copyout+0x36>
    800018f8:	894e                	mv	s2,s3
    800018fa:	b771                	j	80001886 <copyout+0x36>
  return 0;
    800018fc:	4501                	li	a0,0
    800018fe:	6906                	ld	s2,64(sp)
    80001900:	7a42                	ld	s4,48(sp)
    80001902:	6c42                	ld	s8,16(sp)
    80001904:	6ca2                	ld	s9,8(sp)
    80001906:	a091                	j	8000194a <copyout+0xfa>
    80001908:	4501                	li	a0,0
}
    8000190a:	8082                	ret
      return -1;
    8000190c:	557d                	li	a0,-1
    8000190e:	a835                	j	8000194a <copyout+0xfa>
    80001910:	557d                	li	a0,-1
    80001912:	6906                	ld	s2,64(sp)
    80001914:	7a42                	ld	s4,48(sp)
    80001916:	6c42                	ld	s8,16(sp)
    80001918:	6ca2                	ld	s9,8(sp)
    8000191a:	a805                	j	8000194a <copyout+0xfa>
        return -1;
    8000191c:	557d                	li	a0,-1
    8000191e:	6906                	ld	s2,64(sp)
    80001920:	7a42                	ld	s4,48(sp)
    80001922:	6c42                	ld	s8,16(sp)
    80001924:	6ca2                	ld	s9,8(sp)
    80001926:	a015                	j	8000194a <copyout+0xfa>
             return -1;
    80001928:	557d                	li	a0,-1
    8000192a:	6906                	ld	s2,64(sp)
    8000192c:	7a42                	ld	s4,48(sp)
    8000192e:	6c42                	ld	s8,16(sp)
    80001930:	6ca2                	ld	s9,8(sp)
    80001932:	a821                	j	8000194a <copyout+0xfa>
                return -1;
    80001934:	557d                	li	a0,-1
    80001936:	6906                	ld	s2,64(sp)
    80001938:	7a42                	ld	s4,48(sp)
    8000193a:	6c42                	ld	s8,16(sp)
    8000193c:	6ca2                	ld	s9,8(sp)
    8000193e:	a031                	j	8000194a <copyout+0xfa>
    if(pa0 == 0) return -1;
    80001940:	557d                	li	a0,-1
    80001942:	6906                	ld	s2,64(sp)
    80001944:	7a42                	ld	s4,48(sp)
    80001946:	6c42                	ld	s8,16(sp)
    80001948:	6ca2                	ld	s9,8(sp)
}
    8000194a:	60e6                	ld	ra,88(sp)
    8000194c:	6446                	ld	s0,80(sp)
    8000194e:	64a6                	ld	s1,72(sp)
    80001950:	79e2                	ld	s3,56(sp)
    80001952:	7aa2                	ld	s5,40(sp)
    80001954:	7b02                	ld	s6,32(sp)
    80001956:	6be2                	ld	s7,24(sp)
    80001958:	6125                	addi	sp,sp,96
    8000195a:	8082                	ret

000000008000195c <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000195c:	7139                	addi	sp,sp,-64
    8000195e:	fc06                	sd	ra,56(sp)
    80001960:	f822                	sd	s0,48(sp)
    80001962:	f426                	sd	s1,40(sp)
    80001964:	f04a                	sd	s2,32(sp)
    80001966:	ec4e                	sd	s3,24(sp)
    80001968:	e852                	sd	s4,16(sp)
    8000196a:	e456                	sd	s5,8(sp)
    8000196c:	e05a                	sd	s6,0(sp)
    8000196e:	0080                	addi	s0,sp,64
    80001970:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001972:	0011e497          	auipc	s1,0x11e
    80001976:	48e48493          	addi	s1,s1,1166 # 8011fe00 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000197a:	8b26                	mv	s6,s1
    8000197c:	faaab937          	lui	s2,0xfaaab
    80001980:	aab90913          	addi	s2,s2,-1365 # fffffffffaaaaaab <end+0xffffffff7a9798cb>
    80001984:	0932                	slli	s2,s2,0xc
    80001986:	aab90913          	addi	s2,s2,-1365
    8000198a:	0932                	slli	s2,s2,0xc
    8000198c:	aab90913          	addi	s2,s2,-1365
    80001990:	0932                	slli	s2,s2,0xc
    80001992:	aab90913          	addi	s2,s2,-1365
    80001996:	040009b7          	lui	s3,0x4000
    8000199a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000199c:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000199e:	00124a97          	auipc	s5,0x124
    800019a2:	462a8a93          	addi	s5,s5,1122 # 80125e00 <tickslock>
    char *pa = kalloc();
    800019a6:	9ccff0ef          	jal	80000b72 <kalloc>
    800019aa:	862a                	mv	a2,a0
    if(pa == 0)
    800019ac:	cd15                	beqz	a0,800019e8 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800019ae:	416485b3          	sub	a1,s1,s6
    800019b2:	859d                	srai	a1,a1,0x7
    800019b4:	032585b3          	mul	a1,a1,s2
    800019b8:	2585                	addiw	a1,a1,1
    800019ba:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019be:	4719                	li	a4,6
    800019c0:	6685                	lui	a3,0x1
    800019c2:	40b985b3          	sub	a1,s3,a1
    800019c6:	8552                	mv	a0,s4
    800019c8:	80bff0ef          	jal	800011d2 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800019cc:	18048493          	addi	s1,s1,384
    800019d0:	fd549be3          	bne	s1,s5,800019a6 <proc_mapstacks+0x4a>
  }
}
    800019d4:	70e2                	ld	ra,56(sp)
    800019d6:	7442                	ld	s0,48(sp)
    800019d8:	74a2                	ld	s1,40(sp)
    800019da:	7902                	ld	s2,32(sp)
    800019dc:	69e2                	ld	s3,24(sp)
    800019de:	6a42                	ld	s4,16(sp)
    800019e0:	6aa2                	ld	s5,8(sp)
    800019e2:	6b02                	ld	s6,0(sp)
    800019e4:	6121                	addi	sp,sp,64
    800019e6:	8082                	ret
      panic("kalloc");
    800019e8:	00005517          	auipc	a0,0x5
    800019ec:	77850513          	addi	a0,a0,1912 # 80007160 <etext+0x160>
    800019f0:	df1fe0ef          	jal	800007e0 <panic>

00000000800019f4 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800019f4:	7139                	addi	sp,sp,-64
    800019f6:	fc06                	sd	ra,56(sp)
    800019f8:	f822                	sd	s0,48(sp)
    800019fa:	f426                	sd	s1,40(sp)
    800019fc:	f04a                	sd	s2,32(sp)
    800019fe:	ec4e                	sd	s3,24(sp)
    80001a00:	e852                	sd	s4,16(sp)
    80001a02:	e456                	sd	s5,8(sp)
    80001a04:	e05a                	sd	s6,0(sp)
    80001a06:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001a08:	00005597          	auipc	a1,0x5
    80001a0c:	76058593          	addi	a1,a1,1888 # 80007168 <etext+0x168>
    80001a10:	0011e517          	auipc	a0,0x11e
    80001a14:	fc050513          	addi	a0,a0,-64 # 8011f9d0 <pid_lock>
    80001a18:	a6aff0ef          	jal	80000c82 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001a1c:	00005597          	auipc	a1,0x5
    80001a20:	75458593          	addi	a1,a1,1876 # 80007170 <etext+0x170>
    80001a24:	0011e517          	auipc	a0,0x11e
    80001a28:	fc450513          	addi	a0,a0,-60 # 8011f9e8 <wait_lock>
    80001a2c:	a56ff0ef          	jal	80000c82 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a30:	0011e497          	auipc	s1,0x11e
    80001a34:	3d048493          	addi	s1,s1,976 # 8011fe00 <proc>
      initlock(&p->lock, "proc");
    80001a38:	00005b17          	auipc	s6,0x5
    80001a3c:	748b0b13          	addi	s6,s6,1864 # 80007180 <etext+0x180>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001a40:	8aa6                	mv	s5,s1
    80001a42:	faaab937          	lui	s2,0xfaaab
    80001a46:	aab90913          	addi	s2,s2,-1365 # fffffffffaaaaaab <end+0xffffffff7a9798cb>
    80001a4a:	0932                	slli	s2,s2,0xc
    80001a4c:	aab90913          	addi	s2,s2,-1365
    80001a50:	0932                	slli	s2,s2,0xc
    80001a52:	aab90913          	addi	s2,s2,-1365
    80001a56:	0932                	slli	s2,s2,0xc
    80001a58:	aab90913          	addi	s2,s2,-1365
    80001a5c:	040009b7          	lui	s3,0x4000
    80001a60:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001a62:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a64:	00124a17          	auipc	s4,0x124
    80001a68:	39ca0a13          	addi	s4,s4,924 # 80125e00 <tickslock>
      initlock(&p->lock, "proc");
    80001a6c:	85da                	mv	a1,s6
    80001a6e:	8526                	mv	a0,s1
    80001a70:	a12ff0ef          	jal	80000c82 <initlock>
      p->state = UNUSED;
    80001a74:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001a78:	415487b3          	sub	a5,s1,s5
    80001a7c:	879d                	srai	a5,a5,0x7
    80001a7e:	032787b3          	mul	a5,a5,s2
    80001a82:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7fecde21>
    80001a84:	00d7979b          	slliw	a5,a5,0xd
    80001a88:	40f987b3          	sub	a5,s3,a5
    80001a8c:	ecbc                	sd	a5,88(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a8e:	18048493          	addi	s1,s1,384
    80001a92:	fd449de3          	bne	s1,s4,80001a6c <procinit+0x78>
  }
}
    80001a96:	70e2                	ld	ra,56(sp)
    80001a98:	7442                	ld	s0,48(sp)
    80001a9a:	74a2                	ld	s1,40(sp)
    80001a9c:	7902                	ld	s2,32(sp)
    80001a9e:	69e2                	ld	s3,24(sp)
    80001aa0:	6a42                	ld	s4,16(sp)
    80001aa2:	6aa2                	ld	s5,8(sp)
    80001aa4:	6b02                	ld	s6,0(sp)
    80001aa6:	6121                	addi	sp,sp,64
    80001aa8:	8082                	ret

0000000080001aaa <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001aaa:	1141                	addi	sp,sp,-16
    80001aac:	e422                	sd	s0,8(sp)
    80001aae:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ab0:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001ab2:	2501                	sext.w	a0,a0
    80001ab4:	6422                	ld	s0,8(sp)
    80001ab6:	0141                	addi	sp,sp,16
    80001ab8:	8082                	ret

0000000080001aba <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001aba:	1141                	addi	sp,sp,-16
    80001abc:	e422                	sd	s0,8(sp)
    80001abe:	0800                	addi	s0,sp,16
    80001ac0:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001ac2:	2781                	sext.w	a5,a5
    80001ac4:	079e                	slli	a5,a5,0x7
  return c;
}
    80001ac6:	0011e517          	auipc	a0,0x11e
    80001aca:	f3a50513          	addi	a0,a0,-198 # 8011fa00 <cpus>
    80001ace:	953e                	add	a0,a0,a5
    80001ad0:	6422                	ld	s0,8(sp)
    80001ad2:	0141                	addi	sp,sp,16
    80001ad4:	8082                	ret

0000000080001ad6 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001ad6:	1101                	addi	sp,sp,-32
    80001ad8:	ec06                	sd	ra,24(sp)
    80001ada:	e822                	sd	s0,16(sp)
    80001adc:	e426                	sd	s1,8(sp)
    80001ade:	1000                	addi	s0,sp,32
  push_off();
    80001ae0:	9e2ff0ef          	jal	80000cc2 <push_off>
    80001ae4:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001ae6:	2781                	sext.w	a5,a5
    80001ae8:	079e                	slli	a5,a5,0x7
    80001aea:	0011e717          	auipc	a4,0x11e
    80001aee:	ee670713          	addi	a4,a4,-282 # 8011f9d0 <pid_lock>
    80001af2:	97ba                	add	a5,a5,a4
    80001af4:	7b84                	ld	s1,48(a5)
  pop_off();
    80001af6:	a50ff0ef          	jal	80000d46 <pop_off>
  return p;
}
    80001afa:	8526                	mv	a0,s1
    80001afc:	60e2                	ld	ra,24(sp)
    80001afe:	6442                	ld	s0,16(sp)
    80001b00:	64a2                	ld	s1,8(sp)
    80001b02:	6105                	addi	sp,sp,32
    80001b04:	8082                	ret

0000000080001b06 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001b06:	7179                	addi	sp,sp,-48
    80001b08:	f406                	sd	ra,40(sp)
    80001b0a:	f022                	sd	s0,32(sp)
    80001b0c:	ec26                	sd	s1,24(sp)
    80001b0e:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001b10:	fc7ff0ef          	jal	80001ad6 <myproc>
    80001b14:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001b16:	a84ff0ef          	jal	80000d9a <release>

  if (first) {
    80001b1a:	00006797          	auipc	a5,0x6
    80001b1e:	d567a783          	lw	a5,-682(a5) # 80007870 <first.1>
    80001b22:	cf8d                	beqz	a5,80001b5c <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001b24:	4505                	li	a0,1
    80001b26:	623010ef          	jal	80003948 <fsinit>

    first = 0;
    80001b2a:	00006797          	auipc	a5,0x6
    80001b2e:	d407a323          	sw	zero,-698(a5) # 80007870 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001b32:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001b36:	00005517          	auipc	a0,0x5
    80001b3a:	65250513          	addi	a0,a0,1618 # 80007188 <etext+0x188>
    80001b3e:	fca43823          	sd	a0,-48(s0)
    80001b42:	fc043c23          	sd	zero,-40(s0)
    80001b46:	fd040593          	addi	a1,s0,-48
    80001b4a:	709020ef          	jal	80004a52 <kexec>
    80001b4e:	78bc                	ld	a5,112(s1)
    80001b50:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001b52:	78bc                	ld	a5,112(s1)
    80001b54:	7bb8                	ld	a4,112(a5)
    80001b56:	57fd                	li	a5,-1
    80001b58:	02f70d63          	beq	a4,a5,80001b92 <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001b5c:	39b000ef          	jal	800026f6 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001b60:	74a8                	ld	a0,104(s1)
    80001b62:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001b64:	04000737          	lui	a4,0x4000
    80001b68:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001b6a:	0732                	slli	a4,a4,0xc
    80001b6c:	00004797          	auipc	a5,0x4
    80001b70:	53078793          	addi	a5,a5,1328 # 8000609c <userret>
    80001b74:	00004697          	auipc	a3,0x4
    80001b78:	48c68693          	addi	a3,a3,1164 # 80006000 <_trampoline>
    80001b7c:	8f95                	sub	a5,a5,a3
    80001b7e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001b80:	577d                	li	a4,-1
    80001b82:	177e                	slli	a4,a4,0x3f
    80001b84:	8d59                	or	a0,a0,a4
    80001b86:	9782                	jalr	a5
}
    80001b88:	70a2                	ld	ra,40(sp)
    80001b8a:	7402                	ld	s0,32(sp)
    80001b8c:	64e2                	ld	s1,24(sp)
    80001b8e:	6145                	addi	sp,sp,48
    80001b90:	8082                	ret
      panic("exec");
    80001b92:	00005517          	auipc	a0,0x5
    80001b96:	5fe50513          	addi	a0,a0,1534 # 80007190 <etext+0x190>
    80001b9a:	c47fe0ef          	jal	800007e0 <panic>

0000000080001b9e <allocpid>:
{
    80001b9e:	1101                	addi	sp,sp,-32
    80001ba0:	ec06                	sd	ra,24(sp)
    80001ba2:	e822                	sd	s0,16(sp)
    80001ba4:	e426                	sd	s1,8(sp)
    80001ba6:	e04a                	sd	s2,0(sp)
    80001ba8:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001baa:	0011e917          	auipc	s2,0x11e
    80001bae:	e2690913          	addi	s2,s2,-474 # 8011f9d0 <pid_lock>
    80001bb2:	854a                	mv	a0,s2
    80001bb4:	94eff0ef          	jal	80000d02 <acquire>
  pid = nextpid;
    80001bb8:	00006797          	auipc	a5,0x6
    80001bbc:	cbc78793          	addi	a5,a5,-836 # 80007874 <nextpid>
    80001bc0:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001bc2:	0014871b          	addiw	a4,s1,1
    80001bc6:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001bc8:	854a                	mv	a0,s2
    80001bca:	9d0ff0ef          	jal	80000d9a <release>
}
    80001bce:	8526                	mv	a0,s1
    80001bd0:	60e2                	ld	ra,24(sp)
    80001bd2:	6442                	ld	s0,16(sp)
    80001bd4:	64a2                	ld	s1,8(sp)
    80001bd6:	6902                	ld	s2,0(sp)
    80001bd8:	6105                	addi	sp,sp,32
    80001bda:	8082                	ret

0000000080001bdc <proc_pagetable>:
{
    80001bdc:	1101                	addi	sp,sp,-32
    80001bde:	ec06                	sd	ra,24(sp)
    80001be0:	e822                	sd	s0,16(sp)
    80001be2:	e426                	sd	s1,8(sp)
    80001be4:	e04a                	sd	s2,0(sp)
    80001be6:	1000                	addi	s0,sp,32
    80001be8:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001bea:	edeff0ef          	jal	800012c8 <uvmcreate>
    80001bee:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001bf0:	cd05                	beqz	a0,80001c28 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001bf2:	4729                	li	a4,10
    80001bf4:	00004697          	auipc	a3,0x4
    80001bf8:	40c68693          	addi	a3,a3,1036 # 80006000 <_trampoline>
    80001bfc:	6605                	lui	a2,0x1
    80001bfe:	040005b7          	lui	a1,0x4000
    80001c02:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c04:	05b2                	slli	a1,a1,0xc
    80001c06:	d1cff0ef          	jal	80001122 <mappages>
    80001c0a:	02054663          	bltz	a0,80001c36 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c0e:	4719                	li	a4,6
    80001c10:	07093683          	ld	a3,112(s2)
    80001c14:	6605                	lui	a2,0x1
    80001c16:	020005b7          	lui	a1,0x2000
    80001c1a:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c1c:	05b6                	slli	a1,a1,0xd
    80001c1e:	8526                	mv	a0,s1
    80001c20:	d02ff0ef          	jal	80001122 <mappages>
    80001c24:	00054f63          	bltz	a0,80001c42 <proc_pagetable+0x66>
}
    80001c28:	8526                	mv	a0,s1
    80001c2a:	60e2                	ld	ra,24(sp)
    80001c2c:	6442                	ld	s0,16(sp)
    80001c2e:	64a2                	ld	s1,8(sp)
    80001c30:	6902                	ld	s2,0(sp)
    80001c32:	6105                	addi	sp,sp,32
    80001c34:	8082                	ret
    uvmfree(pagetable, 0);
    80001c36:	4581                	li	a1,0
    80001c38:	8526                	mv	a0,s1
    80001c3a:	889ff0ef          	jal	800014c2 <uvmfree>
    return 0;
    80001c3e:	4481                	li	s1,0
    80001c40:	b7e5                	j	80001c28 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c42:	4681                	li	a3,0
    80001c44:	4605                	li	a2,1
    80001c46:	040005b7          	lui	a1,0x4000
    80001c4a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c4c:	05b2                	slli	a1,a1,0xc
    80001c4e:	8526                	mv	a0,s1
    80001c50:	e9eff0ef          	jal	800012ee <uvmunmap>
    uvmfree(pagetable, 0);
    80001c54:	4581                	li	a1,0
    80001c56:	8526                	mv	a0,s1
    80001c58:	86bff0ef          	jal	800014c2 <uvmfree>
    return 0;
    80001c5c:	4481                	li	s1,0
    80001c5e:	b7e9                	j	80001c28 <proc_pagetable+0x4c>

0000000080001c60 <proc_freepagetable>:
{
    80001c60:	1101                	addi	sp,sp,-32
    80001c62:	ec06                	sd	ra,24(sp)
    80001c64:	e822                	sd	s0,16(sp)
    80001c66:	e426                	sd	s1,8(sp)
    80001c68:	e04a                	sd	s2,0(sp)
    80001c6a:	1000                	addi	s0,sp,32
    80001c6c:	84aa                	mv	s1,a0
    80001c6e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c70:	4681                	li	a3,0
    80001c72:	4605                	li	a2,1
    80001c74:	040005b7          	lui	a1,0x4000
    80001c78:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c7a:	05b2                	slli	a1,a1,0xc
    80001c7c:	e72ff0ef          	jal	800012ee <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c80:	4681                	li	a3,0
    80001c82:	4605                	li	a2,1
    80001c84:	020005b7          	lui	a1,0x2000
    80001c88:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c8a:	05b6                	slli	a1,a1,0xd
    80001c8c:	8526                	mv	a0,s1
    80001c8e:	e60ff0ef          	jal	800012ee <uvmunmap>
  uvmfree(pagetable, sz);
    80001c92:	85ca                	mv	a1,s2
    80001c94:	8526                	mv	a0,s1
    80001c96:	82dff0ef          	jal	800014c2 <uvmfree>
}
    80001c9a:	60e2                	ld	ra,24(sp)
    80001c9c:	6442                	ld	s0,16(sp)
    80001c9e:	64a2                	ld	s1,8(sp)
    80001ca0:	6902                	ld	s2,0(sp)
    80001ca2:	6105                	addi	sp,sp,32
    80001ca4:	8082                	ret

0000000080001ca6 <freeproc>:
{
    80001ca6:	1101                	addi	sp,sp,-32
    80001ca8:	ec06                	sd	ra,24(sp)
    80001caa:	e822                	sd	s0,16(sp)
    80001cac:	e426                	sd	s1,8(sp)
    80001cae:	1000                	addi	s0,sp,32
    80001cb0:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001cb2:	7928                	ld	a0,112(a0)
    80001cb4:	c119                	beqz	a0,80001cba <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001cb6:	d67fe0ef          	jal	80000a1c <kfree>
  p->trapframe = 0;
    80001cba:	0604b823          	sd	zero,112(s1)
  if(p->pagetable)
    80001cbe:	74a8                	ld	a0,104(s1)
    80001cc0:	c501                	beqz	a0,80001cc8 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001cc2:	70ac                	ld	a1,96(s1)
    80001cc4:	f9dff0ef          	jal	80001c60 <proc_freepagetable>
  p->pagetable = 0;
    80001cc8:	0604b423          	sd	zero,104(s1)
  p->sz = 0;
    80001ccc:	0604b023          	sd	zero,96(s1)
  p->pid = 0;
    80001cd0:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001cd4:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001cd8:	16048823          	sb	zero,368(s1)
  p->chan = 0;
    80001cdc:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ce0:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001ce4:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ce8:	0004ac23          	sw	zero,24(s1)
}
    80001cec:	60e2                	ld	ra,24(sp)
    80001cee:	6442                	ld	s0,16(sp)
    80001cf0:	64a2                	ld	s1,8(sp)
    80001cf2:	6105                	addi	sp,sp,32
    80001cf4:	8082                	ret

0000000080001cf6 <allocproc>:
{
    80001cf6:	1101                	addi	sp,sp,-32
    80001cf8:	ec06                	sd	ra,24(sp)
    80001cfa:	e822                	sd	s0,16(sp)
    80001cfc:	e426                	sd	s1,8(sp)
    80001cfe:	e04a                	sd	s2,0(sp)
    80001d00:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d02:	0011e497          	auipc	s1,0x11e
    80001d06:	0fe48493          	addi	s1,s1,254 # 8011fe00 <proc>
    80001d0a:	00124917          	auipc	s2,0x124
    80001d0e:	0f690913          	addi	s2,s2,246 # 80125e00 <tickslock>
    acquire(&p->lock);
    80001d12:	8526                	mv	a0,s1
    80001d14:	feffe0ef          	jal	80000d02 <acquire>
    if(p->state == UNUSED) {
    80001d18:	4c9c                	lw	a5,24(s1)
    80001d1a:	cb91                	beqz	a5,80001d2e <allocproc+0x38>
      release(&p->lock);
    80001d1c:	8526                	mv	a0,s1
    80001d1e:	87cff0ef          	jal	80000d9a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d22:	18048493          	addi	s1,s1,384
    80001d26:	ff2496e3          	bne	s1,s2,80001d12 <allocproc+0x1c>
  return 0;
    80001d2a:	4481                	li	s1,0
    80001d2c:	a899                	j	80001d82 <allocproc+0x8c>
  p->pid = allocpid();
    80001d2e:	e71ff0ef          	jal	80001b9e <allocpid>
    80001d32:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001d34:	4785                	li	a5,1
    80001d36:	cc9c                	sw	a5,24(s1)
  p->priority = 0;
    80001d38:	0404a023          	sw	zero,64(s1)
  p->ticks_count = 0;
    80001d3c:	0404a223          	sw	zero,68(s1)
  p->ticks_in_q[0] = 0;
    80001d40:	0404a423          	sw	zero,72(s1)
  p->ticks_in_q[1] = 0;
    80001d44:	0404a623          	sw	zero,76(s1)
  p->ticks_in_q[2] = 0;
    80001d48:	0404a823          	sw	zero,80(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001d4c:	e27fe0ef          	jal	80000b72 <kalloc>
    80001d50:	892a                	mv	s2,a0
    80001d52:	f8a8                	sd	a0,112(s1)
    80001d54:	cd15                	beqz	a0,80001d90 <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001d56:	8526                	mv	a0,s1
    80001d58:	e85ff0ef          	jal	80001bdc <proc_pagetable>
    80001d5c:	892a                	mv	s2,a0
    80001d5e:	f4a8                	sd	a0,104(s1)
  if(p->pagetable == 0){
    80001d60:	c121                	beqz	a0,80001da0 <allocproc+0xaa>
  memset(&p->context, 0, sizeof(p->context));
    80001d62:	07000613          	li	a2,112
    80001d66:	4581                	li	a1,0
    80001d68:	07848513          	addi	a0,s1,120
    80001d6c:	86aff0ef          	jal	80000dd6 <memset>
  p->context.ra = (uint64)forkret;
    80001d70:	00000797          	auipc	a5,0x0
    80001d74:	d9678793          	addi	a5,a5,-618 # 80001b06 <forkret>
    80001d78:	fcbc                	sd	a5,120(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d7a:	6cbc                	ld	a5,88(s1)
    80001d7c:	6705                	lui	a4,0x1
    80001d7e:	97ba                	add	a5,a5,a4
    80001d80:	e0dc                	sd	a5,128(s1)
}
    80001d82:	8526                	mv	a0,s1
    80001d84:	60e2                	ld	ra,24(sp)
    80001d86:	6442                	ld	s0,16(sp)
    80001d88:	64a2                	ld	s1,8(sp)
    80001d8a:	6902                	ld	s2,0(sp)
    80001d8c:	6105                	addi	sp,sp,32
    80001d8e:	8082                	ret
    freeproc(p);
    80001d90:	8526                	mv	a0,s1
    80001d92:	f15ff0ef          	jal	80001ca6 <freeproc>
    release(&p->lock);
    80001d96:	8526                	mv	a0,s1
    80001d98:	802ff0ef          	jal	80000d9a <release>
    return 0;
    80001d9c:	84ca                	mv	s1,s2
    80001d9e:	b7d5                	j	80001d82 <allocproc+0x8c>
    freeproc(p);
    80001da0:	8526                	mv	a0,s1
    80001da2:	f05ff0ef          	jal	80001ca6 <freeproc>
    release(&p->lock);
    80001da6:	8526                	mv	a0,s1
    80001da8:	ff3fe0ef          	jal	80000d9a <release>
    return 0;
    80001dac:	84ca                	mv	s1,s2
    80001dae:	bfd1                	j	80001d82 <allocproc+0x8c>

0000000080001db0 <userinit>:
{
    80001db0:	1101                	addi	sp,sp,-32
    80001db2:	ec06                	sd	ra,24(sp)
    80001db4:	e822                	sd	s0,16(sp)
    80001db6:	e426                	sd	s1,8(sp)
    80001db8:	1000                	addi	s0,sp,32
  p = allocproc();
    80001dba:	f3dff0ef          	jal	80001cf6 <allocproc>
    80001dbe:	84aa                	mv	s1,a0
  initproc = p;
    80001dc0:	00006797          	auipc	a5,0x6
    80001dc4:	aea7b423          	sd	a0,-1304(a5) # 800078a8 <initproc>
  p->cwd = namei("/");
    80001dc8:	00005517          	auipc	a0,0x5
    80001dcc:	3d050513          	addi	a0,a0,976 # 80007198 <etext+0x198>
    80001dd0:	09a020ef          	jal	80003e6a <namei>
    80001dd4:	16a4b423          	sd	a0,360(s1)
  p->state = RUNNABLE;
    80001dd8:	478d                	li	a5,3
    80001dda:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001ddc:	8526                	mv	a0,s1
    80001dde:	fbdfe0ef          	jal	80000d9a <release>
}
    80001de2:	60e2                	ld	ra,24(sp)
    80001de4:	6442                	ld	s0,16(sp)
    80001de6:	64a2                	ld	s1,8(sp)
    80001de8:	6105                	addi	sp,sp,32
    80001dea:	8082                	ret

0000000080001dec <growproc>:
{
    80001dec:	1101                	addi	sp,sp,-32
    80001dee:	ec06                	sd	ra,24(sp)
    80001df0:	e822                	sd	s0,16(sp)
    80001df2:	e426                	sd	s1,8(sp)
    80001df4:	e04a                	sd	s2,0(sp)
    80001df6:	1000                	addi	s0,sp,32
    80001df8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001dfa:	cddff0ef          	jal	80001ad6 <myproc>
    80001dfe:	892a                	mv	s2,a0
  sz = p->sz;
    80001e00:	712c                	ld	a1,96(a0)
  if(n > 0){
    80001e02:	02905963          	blez	s1,80001e34 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001e06:	00b48633          	add	a2,s1,a1
    80001e0a:	020007b7          	lui	a5,0x2000
    80001e0e:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001e10:	07b6                	slli	a5,a5,0xd
    80001e12:	02c7ea63          	bltu	a5,a2,80001e46 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001e16:	4691                	li	a3,4
    80001e18:	7528                	ld	a0,104(a0)
    80001e1a:	da2ff0ef          	jal	800013bc <uvmalloc>
    80001e1e:	85aa                	mv	a1,a0
    80001e20:	c50d                	beqz	a0,80001e4a <growproc+0x5e>
  p->sz = sz;
    80001e22:	06b93023          	sd	a1,96(s2)
  return 0;
    80001e26:	4501                	li	a0,0
}
    80001e28:	60e2                	ld	ra,24(sp)
    80001e2a:	6442                	ld	s0,16(sp)
    80001e2c:	64a2                	ld	s1,8(sp)
    80001e2e:	6902                	ld	s2,0(sp)
    80001e30:	6105                	addi	sp,sp,32
    80001e32:	8082                	ret
  } else if(n < 0){
    80001e34:	fe04d7e3          	bgez	s1,80001e22 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e38:	00b48633          	add	a2,s1,a1
    80001e3c:	7528                	ld	a0,104(a0)
    80001e3e:	d3aff0ef          	jal	80001378 <uvmdealloc>
    80001e42:	85aa                	mv	a1,a0
    80001e44:	bff9                	j	80001e22 <growproc+0x36>
      return -1;
    80001e46:	557d                	li	a0,-1
    80001e48:	b7c5                	j	80001e28 <growproc+0x3c>
      return -1;
    80001e4a:	557d                	li	a0,-1
    80001e4c:	bff1                	j	80001e28 <growproc+0x3c>

0000000080001e4e <kfork>:
{
    80001e4e:	7139                	addi	sp,sp,-64
    80001e50:	fc06                	sd	ra,56(sp)
    80001e52:	f822                	sd	s0,48(sp)
    80001e54:	f04a                	sd	s2,32(sp)
    80001e56:	e456                	sd	s5,8(sp)
    80001e58:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e5a:	c7dff0ef          	jal	80001ad6 <myproc>
    80001e5e:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e60:	e97ff0ef          	jal	80001cf6 <allocproc>
    80001e64:	0e050a63          	beqz	a0,80001f58 <kfork+0x10a>
    80001e68:	e852                	sd	s4,16(sp)
    80001e6a:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e6c:	060ab603          	ld	a2,96(s5)
    80001e70:	752c                	ld	a1,104(a0)
    80001e72:	068ab503          	ld	a0,104(s5)
    80001e76:	e7eff0ef          	jal	800014f4 <uvmcopy>
    80001e7a:	04054a63          	bltz	a0,80001ece <kfork+0x80>
    80001e7e:	f426                	sd	s1,40(sp)
    80001e80:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001e82:	060ab783          	ld	a5,96(s5)
    80001e86:	06fa3023          	sd	a5,96(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e8a:	070ab683          	ld	a3,112(s5)
    80001e8e:	87b6                	mv	a5,a3
    80001e90:	070a3703          	ld	a4,112(s4)
    80001e94:	12068693          	addi	a3,a3,288
    80001e98:	0007b803          	ld	a6,0(a5)
    80001e9c:	6788                	ld	a0,8(a5)
    80001e9e:	6b8c                	ld	a1,16(a5)
    80001ea0:	6f90                	ld	a2,24(a5)
    80001ea2:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001ea6:	e708                	sd	a0,8(a4)
    80001ea8:	eb0c                	sd	a1,16(a4)
    80001eaa:	ef10                	sd	a2,24(a4)
    80001eac:	02078793          	addi	a5,a5,32
    80001eb0:	02070713          	addi	a4,a4,32
    80001eb4:	fed792e3          	bne	a5,a3,80001e98 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001eb8:	070a3783          	ld	a5,112(s4)
    80001ebc:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001ec0:	0e8a8493          	addi	s1,s5,232
    80001ec4:	0e8a0913          	addi	s2,s4,232
    80001ec8:	168a8993          	addi	s3,s5,360
    80001ecc:	a831                	j	80001ee8 <kfork+0x9a>
    freeproc(np);
    80001ece:	8552                	mv	a0,s4
    80001ed0:	dd7ff0ef          	jal	80001ca6 <freeproc>
    release(&np->lock);
    80001ed4:	8552                	mv	a0,s4
    80001ed6:	ec5fe0ef          	jal	80000d9a <release>
    return -1;
    80001eda:	597d                	li	s2,-1
    80001edc:	6a42                	ld	s4,16(sp)
    80001ede:	a0b5                	j	80001f4a <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001ee0:	04a1                	addi	s1,s1,8
    80001ee2:	0921                	addi	s2,s2,8
    80001ee4:	01348963          	beq	s1,s3,80001ef6 <kfork+0xa8>
    if(p->ofile[i])
    80001ee8:	6088                	ld	a0,0(s1)
    80001eea:	d97d                	beqz	a0,80001ee0 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001eec:	518020ef          	jal	80004404 <filedup>
    80001ef0:	00a93023          	sd	a0,0(s2)
    80001ef4:	b7f5                	j	80001ee0 <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001ef6:	168ab503          	ld	a0,360(s5)
    80001efa:	724010ef          	jal	8000361e <idup>
    80001efe:	16aa3423          	sd	a0,360(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f02:	4641                	li	a2,16
    80001f04:	170a8593          	addi	a1,s5,368
    80001f08:	170a0513          	addi	a0,s4,368
    80001f0c:	808ff0ef          	jal	80000f14 <safestrcpy>
  pid = np->pid;
    80001f10:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001f14:	8552                	mv	a0,s4
    80001f16:	e85fe0ef          	jal	80000d9a <release>
  acquire(&wait_lock);
    80001f1a:	0011e497          	auipc	s1,0x11e
    80001f1e:	ace48493          	addi	s1,s1,-1330 # 8011f9e8 <wait_lock>
    80001f22:	8526                	mv	a0,s1
    80001f24:	ddffe0ef          	jal	80000d02 <acquire>
  np->parent = p;
    80001f28:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001f2c:	8526                	mv	a0,s1
    80001f2e:	e6dfe0ef          	jal	80000d9a <release>
  acquire(&np->lock);
    80001f32:	8552                	mv	a0,s4
    80001f34:	dcffe0ef          	jal	80000d02 <acquire>
  np->state = RUNNABLE;
    80001f38:	478d                	li	a5,3
    80001f3a:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f3e:	8552                	mv	a0,s4
    80001f40:	e5bfe0ef          	jal	80000d9a <release>
  return pid;
    80001f44:	74a2                	ld	s1,40(sp)
    80001f46:	69e2                	ld	s3,24(sp)
    80001f48:	6a42                	ld	s4,16(sp)
}
    80001f4a:	854a                	mv	a0,s2
    80001f4c:	70e2                	ld	ra,56(sp)
    80001f4e:	7442                	ld	s0,48(sp)
    80001f50:	7902                	ld	s2,32(sp)
    80001f52:	6aa2                	ld	s5,8(sp)
    80001f54:	6121                	addi	sp,sp,64
    80001f56:	8082                	ret
    return -1;
    80001f58:	597d                	li	s2,-1
    80001f5a:	bfc5                	j	80001f4a <kfork+0xfc>

0000000080001f5c <scheduler>:
{
    80001f5c:	711d                	addi	sp,sp,-96
    80001f5e:	ec86                	sd	ra,88(sp)
    80001f60:	e8a2                	sd	s0,80(sp)
    80001f62:	e4a6                	sd	s1,72(sp)
    80001f64:	e0ca                	sd	s2,64(sp)
    80001f66:	fc4e                	sd	s3,56(sp)
    80001f68:	f852                	sd	s4,48(sp)
    80001f6a:	f456                	sd	s5,40(sp)
    80001f6c:	f05a                	sd	s6,32(sp)
    80001f6e:	ec5e                	sd	s7,24(sp)
    80001f70:	e862                	sd	s8,16(sp)
    80001f72:	e466                	sd	s9,8(sp)
    80001f74:	1080                	addi	s0,sp,96
    80001f76:	8792                	mv	a5,tp
  int id = r_tp();
    80001f78:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f7a:	00779b93          	slli	s7,a5,0x7
    80001f7e:	0011e717          	auipc	a4,0x11e
    80001f82:	a5270713          	addi	a4,a4,-1454 # 8011f9d0 <pid_lock>
    80001f86:	975e                	add	a4,a4,s7
    80001f88:	02073823          	sd	zero,48(a4)
            swtch(&c->context, &p->context);
    80001f8c:	0011e717          	auipc	a4,0x11e
    80001f90:	a7c70713          	addi	a4,a4,-1412 # 8011fa08 <cpus+0x8>
    80001f94:	9bba                	add	s7,s7,a4
            p->state = RUNNING;
    80001f96:	4c11                	li	s8,4
            c->proc = p;
    80001f98:	079e                	slli	a5,a5,0x7
    80001f9a:	0011ea97          	auipc	s5,0x11e
    80001f9e:	a36a8a93          	addi	s5,s5,-1482 # 8011f9d0 <pid_lock>
    80001fa2:	9abe                	add	s5,s5,a5
            found = 1;
    80001fa4:	4b05                	li	s6,1
    80001fa6:	a055                	j	8000204a <scheduler+0xee>
        for(p = proc; p < &proc[NPROC]; p++){
    80001fa8:	0011e497          	auipc	s1,0x11e
    80001fac:	e5848493          	addi	s1,s1,-424 # 8011fe00 <proc>
    80001fb0:	00124917          	auipc	s2,0x124
    80001fb4:	e5090913          	addi	s2,s2,-432 # 80125e00 <tickslock>
    80001fb8:	a801                	j	80001fc8 <scheduler+0x6c>
            release(&p->lock);
    80001fba:	8526                	mv	a0,s1
    80001fbc:	ddffe0ef          	jal	80000d9a <release>
        for(p = proc; p < &proc[NPROC]; p++){
    80001fc0:	18048493          	addi	s1,s1,384
    80001fc4:	01248c63          	beq	s1,s2,80001fdc <scheduler+0x80>
            acquire(&p->lock);
    80001fc8:	8526                	mv	a0,s1
    80001fca:	d39fe0ef          	jal	80000d02 <acquire>
            if(p->state != UNUSED) {
    80001fce:	4c9c                	lw	a5,24(s1)
    80001fd0:	d7ed                	beqz	a5,80001fba <scheduler+0x5e>
                p->priority = 0;
    80001fd2:	0404a023          	sw	zero,64(s1)
                p->ticks_count = 0;
    80001fd6:	0404a223          	sw	zero,68(s1)
    80001fda:	b7c5                	j	80001fba <scheduler+0x5e>
        last_boost_ticks = current_ticks;
    80001fdc:	00006797          	auipc	a5,0x6
    80001fe0:	8d37a223          	sw	s3,-1852(a5) # 800078a0 <last_boost_ticks.2>
    80001fe4:	a05d                	j	8000208a <scheduler+0x12e>
          release(&p->lock);
    80001fe6:	8526                	mv	a0,s1
    80001fe8:	db3fe0ef          	jal	80000d9a <release>
        for(p = proc; p < &proc[NPROC]; p++) {
    80001fec:	18048493          	addi	s1,s1,384
    80001ff0:	03348863          	beq	s1,s3,80002020 <scheduler+0xc4>
          acquire(&p->lock);
    80001ff4:	8526                	mv	a0,s1
    80001ff6:	d0dfe0ef          	jal	80000d02 <acquire>
          if(p->state == RUNNABLE && p->priority == prio) {
    80001ffa:	4c9c                	lw	a5,24(s1)
    80001ffc:	ff2795e3          	bne	a5,s2,80001fe6 <scheduler+0x8a>
    80002000:	40bc                	lw	a5,64(s1)
    80002002:	ff4792e3          	bne	a5,s4,80001fe6 <scheduler+0x8a>
            p->state = RUNNING;
    80002006:	0184ac23          	sw	s8,24(s1)
            c->proc = p;
    8000200a:	029ab823          	sd	s1,48(s5)
            swtch(&c->context, &p->context);
    8000200e:	07848593          	addi	a1,s1,120
    80002012:	855e                	mv	a0,s7
    80002014:	63c000ef          	jal	80002650 <swtch>
            c->proc = 0;
    80002018:	020ab823          	sd	zero,48(s5)
            found = 1;
    8000201c:	8cda                	mv	s9,s6
    8000201e:	b7e1                	j	80001fe6 <scheduler+0x8a>
        if(found == 1) {
    80002020:	036c8563          	beq	s9,s6,8000204a <scheduler+0xee>
    for (int prio = 0; prio < 3; prio++) {
    80002024:	2a05                	addiw	s4,s4,1
    80002026:	478d                	li	a5,3
    80002028:	00fa0963          	beq	s4,a5,8000203a <scheduler+0xde>
        for(p = proc; p < &proc[NPROC]; p++){
    8000202c:	4c81                	li	s9,0
        for(p = proc; p < &proc[NPROC]; p++) {
    8000202e:	0011e497          	auipc	s1,0x11e
    80002032:	dd248493          	addi	s1,s1,-558 # 8011fe00 <proc>
          if(p->state == RUNNABLE && p->priority == prio) {
    80002036:	490d                	li	s2,3
    80002038:	bf75                	j	80001ff4 <scheduler+0x98>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000203a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000203e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002042:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80002046:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000204a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000204e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002052:	10079073          	csrw	sstatus,a5
    acquire(&tickslock);
    80002056:	00124517          	auipc	a0,0x124
    8000205a:	daa50513          	addi	a0,a0,-598 # 80125e00 <tickslock>
    8000205e:	ca5fe0ef          	jal	80000d02 <acquire>
    current_ticks = ticks;
    80002062:	00006997          	auipc	s3,0x6
    80002066:	84e9a983          	lw	s3,-1970(s3) # 800078b0 <ticks>
    release(&tickslock);
    8000206a:	00124517          	auipc	a0,0x124
    8000206e:	d9650513          	addi	a0,a0,-618 # 80125e00 <tickslock>
    80002072:	d29fe0ef          	jal	80000d9a <release>
    if (current_ticks - last_boost_ticks >= BOOST_INTERVAL) {
    80002076:	00006797          	auipc	a5,0x6
    8000207a:	82a7a783          	lw	a5,-2006(a5) # 800078a0 <last_boost_ticks.2>
    8000207e:	40f987bb          	subw	a5,s3,a5
    80002082:	06300713          	li	a4,99
    80002086:	f2f761e3          	bltu	a4,a5,80001fa8 <scheduler+0x4c>
            found = 1;
    8000208a:	4a01                	li	s4,0
        for(p = proc; p < &proc[NPROC]; p++) {
    8000208c:	00124997          	auipc	s3,0x124
    80002090:	d7498993          	addi	s3,s3,-652 # 80125e00 <tickslock>
    80002094:	bf61                	j	8000202c <scheduler+0xd0>

0000000080002096 <sched>:
{
    80002096:	7179                	addi	sp,sp,-48
    80002098:	f406                	sd	ra,40(sp)
    8000209a:	f022                	sd	s0,32(sp)
    8000209c:	ec26                	sd	s1,24(sp)
    8000209e:	e84a                	sd	s2,16(sp)
    800020a0:	e44e                	sd	s3,8(sp)
    800020a2:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800020a4:	a33ff0ef          	jal	80001ad6 <myproc>
    800020a8:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800020aa:	beffe0ef          	jal	80000c98 <holding>
    800020ae:	c92d                	beqz	a0,80002120 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020b0:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800020b2:	2781                	sext.w	a5,a5
    800020b4:	079e                	slli	a5,a5,0x7
    800020b6:	0011e717          	auipc	a4,0x11e
    800020ba:	91a70713          	addi	a4,a4,-1766 # 8011f9d0 <pid_lock>
    800020be:	97ba                	add	a5,a5,a4
    800020c0:	0a87a703          	lw	a4,168(a5)
    800020c4:	4785                	li	a5,1
    800020c6:	06f71363          	bne	a4,a5,8000212c <sched+0x96>
  if(p->state == RUNNING)
    800020ca:	4c98                	lw	a4,24(s1)
    800020cc:	4791                	li	a5,4
    800020ce:	06f70563          	beq	a4,a5,80002138 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020d2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020d6:	8b89                	andi	a5,a5,2
  if(intr_get())
    800020d8:	e7b5                	bnez	a5,80002144 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020da:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020dc:	0011e917          	auipc	s2,0x11e
    800020e0:	8f490913          	addi	s2,s2,-1804 # 8011f9d0 <pid_lock>
    800020e4:	2781                	sext.w	a5,a5
    800020e6:	079e                	slli	a5,a5,0x7
    800020e8:	97ca                	add	a5,a5,s2
    800020ea:	0ac7a983          	lw	s3,172(a5)
    800020ee:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020f0:	2781                	sext.w	a5,a5
    800020f2:	079e                	slli	a5,a5,0x7
    800020f4:	0011e597          	auipc	a1,0x11e
    800020f8:	91458593          	addi	a1,a1,-1772 # 8011fa08 <cpus+0x8>
    800020fc:	95be                	add	a1,a1,a5
    800020fe:	07848513          	addi	a0,s1,120
    80002102:	54e000ef          	jal	80002650 <swtch>
    80002106:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002108:	2781                	sext.w	a5,a5
    8000210a:	079e                	slli	a5,a5,0x7
    8000210c:	993e                	add	s2,s2,a5
    8000210e:	0b392623          	sw	s3,172(s2)
}
    80002112:	70a2                	ld	ra,40(sp)
    80002114:	7402                	ld	s0,32(sp)
    80002116:	64e2                	ld	s1,24(sp)
    80002118:	6942                	ld	s2,16(sp)
    8000211a:	69a2                	ld	s3,8(sp)
    8000211c:	6145                	addi	sp,sp,48
    8000211e:	8082                	ret
    panic("sched p->lock");
    80002120:	00005517          	auipc	a0,0x5
    80002124:	08050513          	addi	a0,a0,128 # 800071a0 <etext+0x1a0>
    80002128:	eb8fe0ef          	jal	800007e0 <panic>
    panic("sched locks");
    8000212c:	00005517          	auipc	a0,0x5
    80002130:	08450513          	addi	a0,a0,132 # 800071b0 <etext+0x1b0>
    80002134:	eacfe0ef          	jal	800007e0 <panic>
    panic("sched RUNNING");
    80002138:	00005517          	auipc	a0,0x5
    8000213c:	08850513          	addi	a0,a0,136 # 800071c0 <etext+0x1c0>
    80002140:	ea0fe0ef          	jal	800007e0 <panic>
    panic("sched interruptible");
    80002144:	00005517          	auipc	a0,0x5
    80002148:	08c50513          	addi	a0,a0,140 # 800071d0 <etext+0x1d0>
    8000214c:	e94fe0ef          	jal	800007e0 <panic>

0000000080002150 <yield>:
{
    80002150:	1101                	addi	sp,sp,-32
    80002152:	ec06                	sd	ra,24(sp)
    80002154:	e822                	sd	s0,16(sp)
    80002156:	e426                	sd	s1,8(sp)
    80002158:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000215a:	97dff0ef          	jal	80001ad6 <myproc>
    8000215e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002160:	ba3fe0ef          	jal	80000d02 <acquire>
  p->state = RUNNABLE;
    80002164:	478d                	li	a5,3
    80002166:	cc9c                	sw	a5,24(s1)
  sched();
    80002168:	f2fff0ef          	jal	80002096 <sched>
  release(&p->lock);
    8000216c:	8526                	mv	a0,s1
    8000216e:	c2dfe0ef          	jal	80000d9a <release>
}
    80002172:	60e2                	ld	ra,24(sp)
    80002174:	6442                	ld	s0,16(sp)
    80002176:	64a2                	ld	s1,8(sp)
    80002178:	6105                	addi	sp,sp,32
    8000217a:	8082                	ret

000000008000217c <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000217c:	7179                	addi	sp,sp,-48
    8000217e:	f406                	sd	ra,40(sp)
    80002180:	f022                	sd	s0,32(sp)
    80002182:	ec26                	sd	s1,24(sp)
    80002184:	e84a                	sd	s2,16(sp)
    80002186:	e44e                	sd	s3,8(sp)
    80002188:	1800                	addi	s0,sp,48
    8000218a:	89aa                	mv	s3,a0
    8000218c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000218e:	949ff0ef          	jal	80001ad6 <myproc>
    80002192:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002194:	b6ffe0ef          	jal	80000d02 <acquire>
  release(lk);
    80002198:	854a                	mv	a0,s2
    8000219a:	c01fe0ef          	jal	80000d9a <release>

  // Go to sleep.
  p->chan = chan;
    8000219e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800021a2:	4789                	li	a5,2
    800021a4:	cc9c                	sw	a5,24(s1)

  sched();
    800021a6:	ef1ff0ef          	jal	80002096 <sched>

  // Tidy up.
  p->chan = 0;
    800021aa:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800021ae:	8526                	mv	a0,s1
    800021b0:	bebfe0ef          	jal	80000d9a <release>
  acquire(lk);
    800021b4:	854a                	mv	a0,s2
    800021b6:	b4dfe0ef          	jal	80000d02 <acquire>
}
    800021ba:	70a2                	ld	ra,40(sp)
    800021bc:	7402                	ld	s0,32(sp)
    800021be:	64e2                	ld	s1,24(sp)
    800021c0:	6942                	ld	s2,16(sp)
    800021c2:	69a2                	ld	s3,8(sp)
    800021c4:	6145                	addi	sp,sp,48
    800021c6:	8082                	ret

00000000800021c8 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    800021c8:	7139                	addi	sp,sp,-64
    800021ca:	fc06                	sd	ra,56(sp)
    800021cc:	f822                	sd	s0,48(sp)
    800021ce:	f426                	sd	s1,40(sp)
    800021d0:	f04a                	sd	s2,32(sp)
    800021d2:	ec4e                	sd	s3,24(sp)
    800021d4:	e852                	sd	s4,16(sp)
    800021d6:	e456                	sd	s5,8(sp)
    800021d8:	0080                	addi	s0,sp,64
    800021da:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800021dc:	0011e497          	auipc	s1,0x11e
    800021e0:	c2448493          	addi	s1,s1,-988 # 8011fe00 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800021e4:	4989                	li	s3,2
        p->state = RUNNABLE;
    800021e6:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800021e8:	00124917          	auipc	s2,0x124
    800021ec:	c1890913          	addi	s2,s2,-1000 # 80125e00 <tickslock>
    800021f0:	a801                	j	80002200 <wakeup+0x38>
      }
      release(&p->lock);
    800021f2:	8526                	mv	a0,s1
    800021f4:	ba7fe0ef          	jal	80000d9a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800021f8:	18048493          	addi	s1,s1,384
    800021fc:	03248263          	beq	s1,s2,80002220 <wakeup+0x58>
    if(p != myproc()){
    80002200:	8d7ff0ef          	jal	80001ad6 <myproc>
    80002204:	fea48ae3          	beq	s1,a0,800021f8 <wakeup+0x30>
      acquire(&p->lock);
    80002208:	8526                	mv	a0,s1
    8000220a:	af9fe0ef          	jal	80000d02 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000220e:	4c9c                	lw	a5,24(s1)
    80002210:	ff3791e3          	bne	a5,s3,800021f2 <wakeup+0x2a>
    80002214:	709c                	ld	a5,32(s1)
    80002216:	fd479ee3          	bne	a5,s4,800021f2 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000221a:	0154ac23          	sw	s5,24(s1)
    8000221e:	bfd1                	j	800021f2 <wakeup+0x2a>
    }
  }
}
    80002220:	70e2                	ld	ra,56(sp)
    80002222:	7442                	ld	s0,48(sp)
    80002224:	74a2                	ld	s1,40(sp)
    80002226:	7902                	ld	s2,32(sp)
    80002228:	69e2                	ld	s3,24(sp)
    8000222a:	6a42                	ld	s4,16(sp)
    8000222c:	6aa2                	ld	s5,8(sp)
    8000222e:	6121                	addi	sp,sp,64
    80002230:	8082                	ret

0000000080002232 <reparent>:
{
    80002232:	7179                	addi	sp,sp,-48
    80002234:	f406                	sd	ra,40(sp)
    80002236:	f022                	sd	s0,32(sp)
    80002238:	ec26                	sd	s1,24(sp)
    8000223a:	e84a                	sd	s2,16(sp)
    8000223c:	e44e                	sd	s3,8(sp)
    8000223e:	e052                	sd	s4,0(sp)
    80002240:	1800                	addi	s0,sp,48
    80002242:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002244:	0011e497          	auipc	s1,0x11e
    80002248:	bbc48493          	addi	s1,s1,-1092 # 8011fe00 <proc>
      pp->parent = initproc;
    8000224c:	00005a17          	auipc	s4,0x5
    80002250:	65ca0a13          	addi	s4,s4,1628 # 800078a8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002254:	00124997          	auipc	s3,0x124
    80002258:	bac98993          	addi	s3,s3,-1108 # 80125e00 <tickslock>
    8000225c:	a029                	j	80002266 <reparent+0x34>
    8000225e:	18048493          	addi	s1,s1,384
    80002262:	01348b63          	beq	s1,s3,80002278 <reparent+0x46>
    if(pp->parent == p){
    80002266:	7c9c                	ld	a5,56(s1)
    80002268:	ff279be3          	bne	a5,s2,8000225e <reparent+0x2c>
      pp->parent = initproc;
    8000226c:	000a3503          	ld	a0,0(s4)
    80002270:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002272:	f57ff0ef          	jal	800021c8 <wakeup>
    80002276:	b7e5                	j	8000225e <reparent+0x2c>
}
    80002278:	70a2                	ld	ra,40(sp)
    8000227a:	7402                	ld	s0,32(sp)
    8000227c:	64e2                	ld	s1,24(sp)
    8000227e:	6942                	ld	s2,16(sp)
    80002280:	69a2                	ld	s3,8(sp)
    80002282:	6a02                	ld	s4,0(sp)
    80002284:	6145                	addi	sp,sp,48
    80002286:	8082                	ret

0000000080002288 <kexit>:
{
    80002288:	7179                	addi	sp,sp,-48
    8000228a:	f406                	sd	ra,40(sp)
    8000228c:	f022                	sd	s0,32(sp)
    8000228e:	ec26                	sd	s1,24(sp)
    80002290:	e84a                	sd	s2,16(sp)
    80002292:	e44e                	sd	s3,8(sp)
    80002294:	e052                	sd	s4,0(sp)
    80002296:	1800                	addi	s0,sp,48
    80002298:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000229a:	83dff0ef          	jal	80001ad6 <myproc>
    8000229e:	89aa                	mv	s3,a0
  if(p == initproc)
    800022a0:	00005797          	auipc	a5,0x5
    800022a4:	6087b783          	ld	a5,1544(a5) # 800078a8 <initproc>
    800022a8:	0e850493          	addi	s1,a0,232
    800022ac:	16850913          	addi	s2,a0,360
    800022b0:	00a79f63          	bne	a5,a0,800022ce <kexit+0x46>
    panic("init exiting");
    800022b4:	00005517          	auipc	a0,0x5
    800022b8:	f3450513          	addi	a0,a0,-204 # 800071e8 <etext+0x1e8>
    800022bc:	d24fe0ef          	jal	800007e0 <panic>
      fileclose(f);
    800022c0:	18a020ef          	jal	8000444a <fileclose>
      p->ofile[fd] = 0;
    800022c4:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800022c8:	04a1                	addi	s1,s1,8
    800022ca:	01248563          	beq	s1,s2,800022d4 <kexit+0x4c>
    if(p->ofile[fd]){
    800022ce:	6088                	ld	a0,0(s1)
    800022d0:	f965                	bnez	a0,800022c0 <kexit+0x38>
    800022d2:	bfdd                	j	800022c8 <kexit+0x40>
  begin_op();
    800022d4:	56b010ef          	jal	8000403e <begin_op>
  iput(p->cwd);
    800022d8:	1689b503          	ld	a0,360(s3)
    800022dc:	4fa010ef          	jal	800037d6 <iput>
  end_op();
    800022e0:	5c9010ef          	jal	800040a8 <end_op>
  p->cwd = 0;
    800022e4:	1609b423          	sd	zero,360(s3)
  acquire(&wait_lock);
    800022e8:	0011d497          	auipc	s1,0x11d
    800022ec:	70048493          	addi	s1,s1,1792 # 8011f9e8 <wait_lock>
    800022f0:	8526                	mv	a0,s1
    800022f2:	a11fe0ef          	jal	80000d02 <acquire>
  reparent(p);
    800022f6:	854e                	mv	a0,s3
    800022f8:	f3bff0ef          	jal	80002232 <reparent>
  wakeup(p->parent);
    800022fc:	0389b503          	ld	a0,56(s3)
    80002300:	ec9ff0ef          	jal	800021c8 <wakeup>
  acquire(&p->lock);
    80002304:	854e                	mv	a0,s3
    80002306:	9fdfe0ef          	jal	80000d02 <acquire>
  p->xstate = status;
    8000230a:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000230e:	4795                	li	a5,5
    80002310:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002314:	8526                	mv	a0,s1
    80002316:	a85fe0ef          	jal	80000d9a <release>
  sched();
    8000231a:	d7dff0ef          	jal	80002096 <sched>
  panic("zombie exit");
    8000231e:	00005517          	auipc	a0,0x5
    80002322:	eda50513          	addi	a0,a0,-294 # 800071f8 <etext+0x1f8>
    80002326:	cbafe0ef          	jal	800007e0 <panic>

000000008000232a <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    8000232a:	7179                	addi	sp,sp,-48
    8000232c:	f406                	sd	ra,40(sp)
    8000232e:	f022                	sd	s0,32(sp)
    80002330:	ec26                	sd	s1,24(sp)
    80002332:	e84a                	sd	s2,16(sp)
    80002334:	e44e                	sd	s3,8(sp)
    80002336:	1800                	addi	s0,sp,48
    80002338:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000233a:	0011e497          	auipc	s1,0x11e
    8000233e:	ac648493          	addi	s1,s1,-1338 # 8011fe00 <proc>
    80002342:	00124997          	auipc	s3,0x124
    80002346:	abe98993          	addi	s3,s3,-1346 # 80125e00 <tickslock>
    acquire(&p->lock);
    8000234a:	8526                	mv	a0,s1
    8000234c:	9b7fe0ef          	jal	80000d02 <acquire>
    if(p->pid == pid){
    80002350:	589c                	lw	a5,48(s1)
    80002352:	01278b63          	beq	a5,s2,80002368 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002356:	8526                	mv	a0,s1
    80002358:	a43fe0ef          	jal	80000d9a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000235c:	18048493          	addi	s1,s1,384
    80002360:	ff3495e3          	bne	s1,s3,8000234a <kkill+0x20>
  }
  return -1;
    80002364:	557d                	li	a0,-1
    80002366:	a819                	j	8000237c <kkill+0x52>
      p->killed = 1;
    80002368:	4785                	li	a5,1
    8000236a:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000236c:	4c98                	lw	a4,24(s1)
    8000236e:	4789                	li	a5,2
    80002370:	00f70d63          	beq	a4,a5,8000238a <kkill+0x60>
      release(&p->lock);
    80002374:	8526                	mv	a0,s1
    80002376:	a25fe0ef          	jal	80000d9a <release>
      return 0;
    8000237a:	4501                	li	a0,0
}
    8000237c:	70a2                	ld	ra,40(sp)
    8000237e:	7402                	ld	s0,32(sp)
    80002380:	64e2                	ld	s1,24(sp)
    80002382:	6942                	ld	s2,16(sp)
    80002384:	69a2                	ld	s3,8(sp)
    80002386:	6145                	addi	sp,sp,48
    80002388:	8082                	ret
        p->state = RUNNABLE;
    8000238a:	478d                	li	a5,3
    8000238c:	cc9c                	sw	a5,24(s1)
    8000238e:	b7dd                	j	80002374 <kkill+0x4a>

0000000080002390 <setkilled>:

void
setkilled(struct proc *p)
{
    80002390:	1101                	addi	sp,sp,-32
    80002392:	ec06                	sd	ra,24(sp)
    80002394:	e822                	sd	s0,16(sp)
    80002396:	e426                	sd	s1,8(sp)
    80002398:	1000                	addi	s0,sp,32
    8000239a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000239c:	967fe0ef          	jal	80000d02 <acquire>
  p->killed = 1;
    800023a0:	4785                	li	a5,1
    800023a2:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800023a4:	8526                	mv	a0,s1
    800023a6:	9f5fe0ef          	jal	80000d9a <release>
}
    800023aa:	60e2                	ld	ra,24(sp)
    800023ac:	6442                	ld	s0,16(sp)
    800023ae:	64a2                	ld	s1,8(sp)
    800023b0:	6105                	addi	sp,sp,32
    800023b2:	8082                	ret

00000000800023b4 <killed>:

int
killed(struct proc *p)
{
    800023b4:	1101                	addi	sp,sp,-32
    800023b6:	ec06                	sd	ra,24(sp)
    800023b8:	e822                	sd	s0,16(sp)
    800023ba:	e426                	sd	s1,8(sp)
    800023bc:	e04a                	sd	s2,0(sp)
    800023be:	1000                	addi	s0,sp,32
    800023c0:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800023c2:	941fe0ef          	jal	80000d02 <acquire>
  k = p->killed;
    800023c6:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800023ca:	8526                	mv	a0,s1
    800023cc:	9cffe0ef          	jal	80000d9a <release>
  return k;
}
    800023d0:	854a                	mv	a0,s2
    800023d2:	60e2                	ld	ra,24(sp)
    800023d4:	6442                	ld	s0,16(sp)
    800023d6:	64a2                	ld	s1,8(sp)
    800023d8:	6902                	ld	s2,0(sp)
    800023da:	6105                	addi	sp,sp,32
    800023dc:	8082                	ret

00000000800023de <kwait>:
{
    800023de:	715d                	addi	sp,sp,-80
    800023e0:	e486                	sd	ra,72(sp)
    800023e2:	e0a2                	sd	s0,64(sp)
    800023e4:	fc26                	sd	s1,56(sp)
    800023e6:	f84a                	sd	s2,48(sp)
    800023e8:	f44e                	sd	s3,40(sp)
    800023ea:	f052                	sd	s4,32(sp)
    800023ec:	ec56                	sd	s5,24(sp)
    800023ee:	e85a                	sd	s6,16(sp)
    800023f0:	e45e                	sd	s7,8(sp)
    800023f2:	e062                	sd	s8,0(sp)
    800023f4:	0880                	addi	s0,sp,80
    800023f6:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023f8:	edeff0ef          	jal	80001ad6 <myproc>
    800023fc:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023fe:	0011d517          	auipc	a0,0x11d
    80002402:	5ea50513          	addi	a0,a0,1514 # 8011f9e8 <wait_lock>
    80002406:	8fdfe0ef          	jal	80000d02 <acquire>
    havekids = 0;
    8000240a:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000240c:	4a15                	li	s4,5
        havekids = 1;
    8000240e:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002410:	00124997          	auipc	s3,0x124
    80002414:	9f098993          	addi	s3,s3,-1552 # 80125e00 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002418:	0011dc17          	auipc	s8,0x11d
    8000241c:	5d0c0c13          	addi	s8,s8,1488 # 8011f9e8 <wait_lock>
    80002420:	a871                	j	800024bc <kwait+0xde>
          pid = pp->pid;
    80002422:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002426:	000b0c63          	beqz	s6,8000243e <kwait+0x60>
    8000242a:	4691                	li	a3,4
    8000242c:	02c48613          	addi	a2,s1,44
    80002430:	85da                	mv	a1,s6
    80002432:	06893503          	ld	a0,104(s2)
    80002436:	c1aff0ef          	jal	80001850 <copyout>
    8000243a:	02054b63          	bltz	a0,80002470 <kwait+0x92>
          freeproc(pp);
    8000243e:	8526                	mv	a0,s1
    80002440:	867ff0ef          	jal	80001ca6 <freeproc>
          release(&pp->lock);
    80002444:	8526                	mv	a0,s1
    80002446:	955fe0ef          	jal	80000d9a <release>
          release(&wait_lock);
    8000244a:	0011d517          	auipc	a0,0x11d
    8000244e:	59e50513          	addi	a0,a0,1438 # 8011f9e8 <wait_lock>
    80002452:	949fe0ef          	jal	80000d9a <release>
}
    80002456:	854e                	mv	a0,s3
    80002458:	60a6                	ld	ra,72(sp)
    8000245a:	6406                	ld	s0,64(sp)
    8000245c:	74e2                	ld	s1,56(sp)
    8000245e:	7942                	ld	s2,48(sp)
    80002460:	79a2                	ld	s3,40(sp)
    80002462:	7a02                	ld	s4,32(sp)
    80002464:	6ae2                	ld	s5,24(sp)
    80002466:	6b42                	ld	s6,16(sp)
    80002468:	6ba2                	ld	s7,8(sp)
    8000246a:	6c02                	ld	s8,0(sp)
    8000246c:	6161                	addi	sp,sp,80
    8000246e:	8082                	ret
            release(&pp->lock);
    80002470:	8526                	mv	a0,s1
    80002472:	929fe0ef          	jal	80000d9a <release>
            release(&wait_lock);
    80002476:	0011d517          	auipc	a0,0x11d
    8000247a:	57250513          	addi	a0,a0,1394 # 8011f9e8 <wait_lock>
    8000247e:	91dfe0ef          	jal	80000d9a <release>
            return -1;
    80002482:	59fd                	li	s3,-1
    80002484:	bfc9                	j	80002456 <kwait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002486:	18048493          	addi	s1,s1,384
    8000248a:	03348063          	beq	s1,s3,800024aa <kwait+0xcc>
      if(pp->parent == p){
    8000248e:	7c9c                	ld	a5,56(s1)
    80002490:	ff279be3          	bne	a5,s2,80002486 <kwait+0xa8>
        acquire(&pp->lock);
    80002494:	8526                	mv	a0,s1
    80002496:	86dfe0ef          	jal	80000d02 <acquire>
        if(pp->state == ZOMBIE){
    8000249a:	4c9c                	lw	a5,24(s1)
    8000249c:	f94783e3          	beq	a5,s4,80002422 <kwait+0x44>
        release(&pp->lock);
    800024a0:	8526                	mv	a0,s1
    800024a2:	8f9fe0ef          	jal	80000d9a <release>
        havekids = 1;
    800024a6:	8756                	mv	a4,s5
    800024a8:	bff9                	j	80002486 <kwait+0xa8>
    if(!havekids || killed(p)){
    800024aa:	cf19                	beqz	a4,800024c8 <kwait+0xea>
    800024ac:	854a                	mv	a0,s2
    800024ae:	f07ff0ef          	jal	800023b4 <killed>
    800024b2:	e919                	bnez	a0,800024c8 <kwait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800024b4:	85e2                	mv	a1,s8
    800024b6:	854a                	mv	a0,s2
    800024b8:	cc5ff0ef          	jal	8000217c <sleep>
    havekids = 0;
    800024bc:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024be:	0011e497          	auipc	s1,0x11e
    800024c2:	94248493          	addi	s1,s1,-1726 # 8011fe00 <proc>
    800024c6:	b7e1                	j	8000248e <kwait+0xb0>
      release(&wait_lock);
    800024c8:	0011d517          	auipc	a0,0x11d
    800024cc:	52050513          	addi	a0,a0,1312 # 8011f9e8 <wait_lock>
    800024d0:	8cbfe0ef          	jal	80000d9a <release>
      return -1;
    800024d4:	59fd                	li	s3,-1
    800024d6:	b741                	j	80002456 <kwait+0x78>

00000000800024d8 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024d8:	7179                	addi	sp,sp,-48
    800024da:	f406                	sd	ra,40(sp)
    800024dc:	f022                	sd	s0,32(sp)
    800024de:	ec26                	sd	s1,24(sp)
    800024e0:	e84a                	sd	s2,16(sp)
    800024e2:	e44e                	sd	s3,8(sp)
    800024e4:	e052                	sd	s4,0(sp)
    800024e6:	1800                	addi	s0,sp,48
    800024e8:	84aa                	mv	s1,a0
    800024ea:	892e                	mv	s2,a1
    800024ec:	89b2                	mv	s3,a2
    800024ee:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024f0:	de6ff0ef          	jal	80001ad6 <myproc>
  if(user_dst){
    800024f4:	cc99                	beqz	s1,80002512 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800024f6:	86d2                	mv	a3,s4
    800024f8:	864e                	mv	a2,s3
    800024fa:	85ca                	mv	a1,s2
    800024fc:	7528                	ld	a0,104(a0)
    800024fe:	b52ff0ef          	jal	80001850 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002502:	70a2                	ld	ra,40(sp)
    80002504:	7402                	ld	s0,32(sp)
    80002506:	64e2                	ld	s1,24(sp)
    80002508:	6942                	ld	s2,16(sp)
    8000250a:	69a2                	ld	s3,8(sp)
    8000250c:	6a02                	ld	s4,0(sp)
    8000250e:	6145                	addi	sp,sp,48
    80002510:	8082                	ret
    memmove((char *)dst, src, len);
    80002512:	000a061b          	sext.w	a2,s4
    80002516:	85ce                	mv	a1,s3
    80002518:	854a                	mv	a0,s2
    8000251a:	919fe0ef          	jal	80000e32 <memmove>
    return 0;
    8000251e:	8526                	mv	a0,s1
    80002520:	b7cd                	j	80002502 <either_copyout+0x2a>

0000000080002522 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002522:	7179                	addi	sp,sp,-48
    80002524:	f406                	sd	ra,40(sp)
    80002526:	f022                	sd	s0,32(sp)
    80002528:	ec26                	sd	s1,24(sp)
    8000252a:	e84a                	sd	s2,16(sp)
    8000252c:	e44e                	sd	s3,8(sp)
    8000252e:	e052                	sd	s4,0(sp)
    80002530:	1800                	addi	s0,sp,48
    80002532:	892a                	mv	s2,a0
    80002534:	84ae                	mv	s1,a1
    80002536:	89b2                	mv	s3,a2
    80002538:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000253a:	d9cff0ef          	jal	80001ad6 <myproc>
  if(user_src){
    8000253e:	cc99                	beqz	s1,8000255c <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002540:	86d2                	mv	a3,s4
    80002542:	864e                	mv	a2,s3
    80002544:	85ca                	mv	a1,s2
    80002546:	7528                	ld	a0,104(a0)
    80002548:	9d8ff0ef          	jal	80001720 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000254c:	70a2                	ld	ra,40(sp)
    8000254e:	7402                	ld	s0,32(sp)
    80002550:	64e2                	ld	s1,24(sp)
    80002552:	6942                	ld	s2,16(sp)
    80002554:	69a2                	ld	s3,8(sp)
    80002556:	6a02                	ld	s4,0(sp)
    80002558:	6145                	addi	sp,sp,48
    8000255a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000255c:	000a061b          	sext.w	a2,s4
    80002560:	85ce                	mv	a1,s3
    80002562:	854a                	mv	a0,s2
    80002564:	8cffe0ef          	jal	80000e32 <memmove>
    return 0;
    80002568:	8526                	mv	a0,s1
    8000256a:	b7cd                	j	8000254c <either_copyin+0x2a>

000000008000256c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000256c:	715d                	addi	sp,sp,-80
    8000256e:	e486                	sd	ra,72(sp)
    80002570:	e0a2                	sd	s0,64(sp)
    80002572:	fc26                	sd	s1,56(sp)
    80002574:	f84a                	sd	s2,48(sp)
    80002576:	f44e                	sd	s3,40(sp)
    80002578:	f052                	sd	s4,32(sp)
    8000257a:	ec56                	sd	s5,24(sp)
    8000257c:	e85a                	sd	s6,16(sp)
    8000257e:	e45e                	sd	s7,8(sp)
    80002580:	e062                	sd	s8,0(sp)
    80002582:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002584:	00005517          	auipc	a0,0x5
    80002588:	afc50513          	addi	a0,a0,-1284 # 80007080 <etext+0x80>
    8000258c:	f6ffd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002590:	0011e797          	auipc	a5,0x11e
    80002594:	87078793          	addi	a5,a5,-1936 # 8011fe00 <proc>
    80002598:	00124697          	auipc	a3,0x124
    8000259c:	86868693          	addi	a3,a3,-1944 # 80125e00 <tickslock>
    800025a0:	a889                	j	800025f2 <procdump+0x86>
      if(p->state == RUNNING)
        state = "*RUN* ";
      else
        state = states[p->state];
    } else {
      state = "???";
    800025a2:	864e                	mv	a2,s3
    }

    // Print MLFQ stats
    printf("%d\t%s\t%d\t%d\t%d\t%d\t%s\n", 
    800025a4:	ee08a803          	lw	a6,-288(a7)
    800025a8:	edc8a783          	lw	a5,-292(a7)
    800025ac:	ed88a703          	lw	a4,-296(a7)
    800025b0:	ed08a683          	lw	a3,-304(a7)
    800025b4:	ec08a583          	lw	a1,-320(a7)
    800025b8:	8552                	mv	a0,s4
    800025ba:	f41fd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025be:	18048493          	addi	s1,s1,384
    800025c2:	07248b63          	beq	s1,s2,80002638 <procdump+0xcc>
    if(p->state == UNUSED)
    800025c6:	88a6                	mv	a7,s1
    800025c8:	ea84a783          	lw	a5,-344(s1)
    800025cc:	dbed                	beqz	a5,800025be <procdump+0x52>
      state = "???";
    800025ce:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state]) {
    800025d0:	fcfaeae3          	bltu	s5,a5,800025a4 <procdump+0x38>
    800025d4:	02079693          	slli	a3,a5,0x20
    800025d8:	01d6d713          	srli	a4,a3,0x1d
    800025dc:	975a                	add	a4,a4,s6
    800025de:	6310                	ld	a2,0(a4)
    800025e0:	d269                	beqz	a2,800025a2 <procdump+0x36>
      if(p->state == RUNNING)
    800025e2:	fd7791e3          	bne	a5,s7,800025a4 <procdump+0x38>
        state = "*RUN* ";
    800025e6:	8662                	mv	a2,s8
    800025e8:	bf75                	j	800025a4 <procdump+0x38>
  for(p = proc; p < &proc[NPROC]; p++){
    800025ea:	18078793          	addi	a5,a5,384
    800025ee:	04d7f563          	bgeu	a5,a3,80002638 <procdump+0xcc>
    if(p->state == UNUSED)
    800025f2:	4f98                	lw	a4,24(a5)
    800025f4:	db7d                	beqz	a4,800025ea <procdump+0x7e>
  printf("\nPID\tState\tPrio\tQ0\tQ1\tQ2\tName\n");
    800025f6:	00005517          	auipc	a0,0x5
    800025fa:	c2250513          	addi	a0,a0,-990 # 80007218 <etext+0x218>
    800025fe:	efdfd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002602:	0011e497          	auipc	s1,0x11e
    80002606:	96e48493          	addi	s1,s1,-1682 # 8011ff70 <proc+0x170>
    8000260a:	00124917          	auipc	s2,0x124
    8000260e:	96690913          	addi	s2,s2,-1690 # 80125f70 <bcache+0x158>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state]) {
    80002612:	4a95                	li	s5,5
      state = "???";
    80002614:	00005997          	auipc	s3,0x5
    80002618:	bf498993          	addi	s3,s3,-1036 # 80007208 <etext+0x208>
    printf("%d\t%s\t%d\t%d\t%d\t%d\t%s\n", 
    8000261c:	00005a17          	auipc	s4,0x5
    80002620:	c1ca0a13          	addi	s4,s4,-996 # 80007238 <etext+0x238>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state]) {
    80002624:	00005b17          	auipc	s6,0x5
    80002628:	13cb0b13          	addi	s6,s6,316 # 80007760 <states.0>
      if(p->state == RUNNING)
    8000262c:	4b91                	li	s7,4
        state = "*RUN* ";
    8000262e:	00005c17          	auipc	s8,0x5
    80002632:	be2c0c13          	addi	s8,s8,-1054 # 80007210 <etext+0x210>
    80002636:	bf41                	j	800025c6 <procdump+0x5a>
           p->ticks_in_q[1], 
           p->ticks_in_q[2], 
           p->name);
  }
  }
}
    80002638:	60a6                	ld	ra,72(sp)
    8000263a:	6406                	ld	s0,64(sp)
    8000263c:	74e2                	ld	s1,56(sp)
    8000263e:	7942                	ld	s2,48(sp)
    80002640:	79a2                	ld	s3,40(sp)
    80002642:	7a02                	ld	s4,32(sp)
    80002644:	6ae2                	ld	s5,24(sp)
    80002646:	6b42                	ld	s6,16(sp)
    80002648:	6ba2                	ld	s7,8(sp)
    8000264a:	6c02                	ld	s8,0(sp)
    8000264c:	6161                	addi	sp,sp,80
    8000264e:	8082                	ret

0000000080002650 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002650:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002654:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002658:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    8000265a:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    8000265c:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002660:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002664:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002668:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    8000266c:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002670:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002674:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002678:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    8000267c:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002680:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002684:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002688:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    8000268c:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    8000268e:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002690:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002694:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002698:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    8000269c:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800026a0:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800026a4:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800026a8:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800026ac:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800026b0:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800026b4:	0685bd83          	ld	s11,104(a1)
        
        ret
    800026b8:	8082                	ret

00000000800026ba <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800026ba:	1141                	addi	sp,sp,-16
    800026bc:	e406                	sd	ra,8(sp)
    800026be:	e022                	sd	s0,0(sp)
    800026c0:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800026c2:	00005597          	auipc	a1,0x5
    800026c6:	bbe58593          	addi	a1,a1,-1090 # 80007280 <etext+0x280>
    800026ca:	00123517          	auipc	a0,0x123
    800026ce:	73650513          	addi	a0,a0,1846 # 80125e00 <tickslock>
    800026d2:	db0fe0ef          	jal	80000c82 <initlock>
}
    800026d6:	60a2                	ld	ra,8(sp)
    800026d8:	6402                	ld	s0,0(sp)
    800026da:	0141                	addi	sp,sp,16
    800026dc:	8082                	ret

00000000800026de <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026de:	1141                	addi	sp,sp,-16
    800026e0:	e422                	sd	s0,8(sp)
    800026e2:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026e4:	00003797          	auipc	a5,0x3
    800026e8:	0dc78793          	addi	a5,a5,220 # 800057c0 <kernelvec>
    800026ec:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026f0:	6422                	ld	s0,8(sp)
    800026f2:	0141                	addi	sp,sp,16
    800026f4:	8082                	ret

00000000800026f6 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800026f6:	1141                	addi	sp,sp,-16
    800026f8:	e406                	sd	ra,8(sp)
    800026fa:	e022                	sd	s0,0(sp)
    800026fc:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800026fe:	bd8ff0ef          	jal	80001ad6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002702:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002706:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002708:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000270c:	04000737          	lui	a4,0x4000
    80002710:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002712:	0732                	slli	a4,a4,0xc
    80002714:	00004797          	auipc	a5,0x4
    80002718:	8ec78793          	addi	a5,a5,-1812 # 80006000 <_trampoline>
    8000271c:	00004697          	auipc	a3,0x4
    80002720:	8e468693          	addi	a3,a3,-1820 # 80006000 <_trampoline>
    80002724:	8f95                	sub	a5,a5,a3
    80002726:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002728:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000272c:	793c                	ld	a5,112(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000272e:	18002773          	csrr	a4,satp
    80002732:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002734:	7938                	ld	a4,112(a0)
    80002736:	6d3c                	ld	a5,88(a0)
    80002738:	6685                	lui	a3,0x1
    8000273a:	97b6                	add	a5,a5,a3
    8000273c:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000273e:	793c                	ld	a5,112(a0)
    80002740:	00000717          	auipc	a4,0x0
    80002744:	0f870713          	addi	a4,a4,248 # 80002838 <usertrap>
    80002748:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000274a:	793c                	ld	a5,112(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000274c:	8712                	mv	a4,tp
    8000274e:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002750:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002754:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002758:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000275c:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002760:	793c                	ld	a5,112(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002762:	6f9c                	ld	a5,24(a5)
    80002764:	14179073          	csrw	sepc,a5
}
    80002768:	60a2                	ld	ra,8(sp)
    8000276a:	6402                	ld	s0,0(sp)
    8000276c:	0141                	addi	sp,sp,16
    8000276e:	8082                	ret

0000000080002770 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002770:	1101                	addi	sp,sp,-32
    80002772:	ec06                	sd	ra,24(sp)
    80002774:	e822                	sd	s0,16(sp)
    80002776:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002778:	b32ff0ef          	jal	80001aaa <cpuid>
    8000277c:	cd11                	beqz	a0,80002798 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    8000277e:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002782:	000f4737          	lui	a4,0xf4
    80002786:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000278a:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    8000278c:	14d79073          	csrw	stimecmp,a5
}
    80002790:	60e2                	ld	ra,24(sp)
    80002792:	6442                	ld	s0,16(sp)
    80002794:	6105                	addi	sp,sp,32
    80002796:	8082                	ret
    80002798:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    8000279a:	00123497          	auipc	s1,0x123
    8000279e:	66648493          	addi	s1,s1,1638 # 80125e00 <tickslock>
    800027a2:	8526                	mv	a0,s1
    800027a4:	d5efe0ef          	jal	80000d02 <acquire>
    ticks++;
    800027a8:	00005517          	auipc	a0,0x5
    800027ac:	10850513          	addi	a0,a0,264 # 800078b0 <ticks>
    800027b0:	411c                	lw	a5,0(a0)
    800027b2:	2785                	addiw	a5,a5,1
    800027b4:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800027b6:	a13ff0ef          	jal	800021c8 <wakeup>
    release(&tickslock);
    800027ba:	8526                	mv	a0,s1
    800027bc:	ddefe0ef          	jal	80000d9a <release>
    800027c0:	64a2                	ld	s1,8(sp)
    800027c2:	bf75                	j	8000277e <clockintr+0xe>

00000000800027c4 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800027c4:	1101                	addi	sp,sp,-32
    800027c6:	ec06                	sd	ra,24(sp)
    800027c8:	e822                	sd	s0,16(sp)
    800027ca:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027cc:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800027d0:	57fd                	li	a5,-1
    800027d2:	17fe                	slli	a5,a5,0x3f
    800027d4:	07a5                	addi	a5,a5,9
    800027d6:	00f70c63          	beq	a4,a5,800027ee <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800027da:	57fd                	li	a5,-1
    800027dc:	17fe                	slli	a5,a5,0x3f
    800027de:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800027e0:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800027e2:	04f70763          	beq	a4,a5,80002830 <devintr+0x6c>
  }
}
    800027e6:	60e2                	ld	ra,24(sp)
    800027e8:	6442                	ld	s0,16(sp)
    800027ea:	6105                	addi	sp,sp,32
    800027ec:	8082                	ret
    800027ee:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800027f0:	07c030ef          	jal	8000586c <plic_claim>
    800027f4:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027f6:	47a9                	li	a5,10
    800027f8:	00f50963          	beq	a0,a5,8000280a <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    800027fc:	4785                	li	a5,1
    800027fe:	00f50963          	beq	a0,a5,80002810 <devintr+0x4c>
    return 1;
    80002802:	4505                	li	a0,1
    } else if(irq){
    80002804:	e889                	bnez	s1,80002816 <devintr+0x52>
    80002806:	64a2                	ld	s1,8(sp)
    80002808:	bff9                	j	800027e6 <devintr+0x22>
      uartintr();
    8000280a:	9a6fe0ef          	jal	800009b0 <uartintr>
    if(irq)
    8000280e:	a819                	j	80002824 <devintr+0x60>
      virtio_disk_intr();
    80002810:	522030ef          	jal	80005d32 <virtio_disk_intr>
    if(irq)
    80002814:	a801                	j	80002824 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002816:	85a6                	mv	a1,s1
    80002818:	00005517          	auipc	a0,0x5
    8000281c:	a7050513          	addi	a0,a0,-1424 # 80007288 <etext+0x288>
    80002820:	cdbfd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    80002824:	8526                	mv	a0,s1
    80002826:	066030ef          	jal	8000588c <plic_complete>
    return 1;
    8000282a:	4505                	li	a0,1
    8000282c:	64a2                	ld	s1,8(sp)
    8000282e:	bf65                	j	800027e6 <devintr+0x22>
    clockintr();
    80002830:	f41ff0ef          	jal	80002770 <clockintr>
    return 2;
    80002834:	4509                	li	a0,2
    80002836:	bf45                	j	800027e6 <devintr+0x22>

0000000080002838 <usertrap>:
{
    80002838:	1101                	addi	sp,sp,-32
    8000283a:	ec06                	sd	ra,24(sp)
    8000283c:	e822                	sd	s0,16(sp)
    8000283e:	e426                	sd	s1,8(sp)
    80002840:	e04a                	sd	s2,0(sp)
    80002842:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002844:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002848:	1007f793          	andi	a5,a5,256
    8000284c:	efb5                	bnez	a5,800028c8 <usertrap+0x90>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000284e:	00003797          	auipc	a5,0x3
    80002852:	f7278793          	addi	a5,a5,-142 # 800057c0 <kernelvec>
    80002856:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000285a:	a7cff0ef          	jal	80001ad6 <myproc>
    8000285e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002860:	793c                	ld	a5,112(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002862:	14102773          	csrr	a4,sepc
    80002866:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002868:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000286c:	47a1                	li	a5,8
    8000286e:	06f70363          	beq	a4,a5,800028d4 <usertrap+0x9c>
  } else if((which_dev = devintr()) != 0){
    80002872:	f53ff0ef          	jal	800027c4 <devintr>
    80002876:	892a                	mv	s2,a0
    80002878:	0c051963          	bnez	a0,8000294a <usertrap+0x112>
    8000287c:	14202773          	csrr	a4,scause
  } else if (r_scause() == 15) {
    80002880:	47bd                	li	a5,15
    80002882:	08f70d63          	beq	a4,a5,8000291c <usertrap+0xe4>
    80002886:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    8000288a:	47bd                	li	a5,15
    8000288c:	0af70363          	beq	a4,a5,80002932 <usertrap+0xfa>
    80002890:	14202773          	csrr	a4,scause
    80002894:	47b5                	li	a5,13
    80002896:	08f70e63          	beq	a4,a5,80002932 <usertrap+0xfa>
    8000289a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000289e:	5890                	lw	a2,48(s1)
    800028a0:	00005517          	auipc	a0,0x5
    800028a4:	a2850513          	addi	a0,a0,-1496 # 800072c8 <etext+0x2c8>
    800028a8:	c53fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028ac:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028b0:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800028b4:	00005517          	auipc	a0,0x5
    800028b8:	a4450513          	addi	a0,a0,-1468 # 800072f8 <etext+0x2f8>
    800028bc:	c3ffd0ef          	jal	800004fa <printf>
    setkilled(p);
    800028c0:	8526                	mv	a0,s1
    800028c2:	acfff0ef          	jal	80002390 <setkilled>
    800028c6:	a035                	j	800028f2 <usertrap+0xba>
    panic("usertrap: not from user mode");
    800028c8:	00005517          	auipc	a0,0x5
    800028cc:	9e050513          	addi	a0,a0,-1568 # 800072a8 <etext+0x2a8>
    800028d0:	f11fd0ef          	jal	800007e0 <panic>
    if(killed(p))
    800028d4:	ae1ff0ef          	jal	800023b4 <killed>
    800028d8:	ed15                	bnez	a0,80002914 <usertrap+0xdc>
    p->trapframe->epc += 4;
    800028da:	78b8                	ld	a4,112(s1)
    800028dc:	6f1c                	ld	a5,24(a4)
    800028de:	0791                	addi	a5,a5,4
    800028e0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028e2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800028e6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028ea:	10079073          	csrw	sstatus,a5
    syscall();
    800028ee:	314000ef          	jal	80002c02 <syscall>
  if(killed(p))
    800028f2:	8526                	mv	a0,s1
    800028f4:	ac1ff0ef          	jal	800023b4 <killed>
    800028f8:	ed31                	bnez	a0,80002954 <usertrap+0x11c>
  prepare_return();
    800028fa:	dfdff0ef          	jal	800026f6 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800028fe:	74a8                	ld	a0,104(s1)
    80002900:	8131                	srli	a0,a0,0xc
    80002902:	57fd                	li	a5,-1
    80002904:	17fe                	slli	a5,a5,0x3f
    80002906:	8d5d                	or	a0,a0,a5
}
    80002908:	60e2                	ld	ra,24(sp)
    8000290a:	6442                	ld	s0,16(sp)
    8000290c:	64a2                	ld	s1,8(sp)
    8000290e:	6902                	ld	s2,0(sp)
    80002910:	6105                	addi	sp,sp,32
    80002912:	8082                	ret
      kexit(-1);
    80002914:	557d                	li	a0,-1
    80002916:	973ff0ef          	jal	80002288 <kexit>
    8000291a:	b7c1                	j	800028da <usertrap+0xa2>
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000291c:	143025f3          	csrr	a1,stval
      if (cowalloc(p->pagetable, r_stval()) < 0) {
    80002920:	74a8                	ld	a0,104(s1)
    80002922:	e8dfe0ef          	jal	800017ae <cowalloc>
    80002926:	fc0556e3          	bgez	a0,800028f2 <usertrap+0xba>
           setkilled(p); // CoW failed (OOM or bad address)
    8000292a:	8526                	mv	a0,s1
    8000292c:	a65ff0ef          	jal	80002390 <setkilled>
    80002930:	b7c9                	j	800028f2 <usertrap+0xba>
    80002932:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002936:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    8000293a:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    8000293c:	00163613          	seqz	a2,a2
    80002940:	74a8                	ld	a0,104(s1)
    80002942:	d5dfe0ef          	jal	8000169e <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002946:	f555                	bnez	a0,800028f2 <usertrap+0xba>
    80002948:	bf89                	j	8000289a <usertrap+0x62>
  if(killed(p))
    8000294a:	8526                	mv	a0,s1
    8000294c:	a69ff0ef          	jal	800023b4 <killed>
    80002950:	c511                	beqz	a0,8000295c <usertrap+0x124>
    80002952:	a011                	j	80002956 <usertrap+0x11e>
    80002954:	4901                	li	s2,0
    kexit(-1);
    80002956:	557d                	li	a0,-1
    80002958:	931ff0ef          	jal	80002288 <kexit>
  if(which_dev == 2) {
    8000295c:	4789                	li	a5,2
    8000295e:	f8f91ee3          	bne	s2,a5,800028fa <usertrap+0xc2>
      p->ticks_in_q[p->priority]++; 
    80002962:	40b4                	lw	a3,64(s1)
    80002964:	00269793          	slli	a5,a3,0x2
    80002968:	97a6                	add	a5,a5,s1
    8000296a:	47b8                	lw	a4,72(a5)
    8000296c:	2705                	addiw	a4,a4,1
    8000296e:	c7b8                	sw	a4,72(a5)
      p->ticks_count++;
    80002970:	40fc                	lw	a5,68(s1)
    80002972:	2785                	addiw	a5,a5,1
    80002974:	0007871b          	sext.w	a4,a5
    80002978:	c0fc                	sw	a5,68(s1)
      if (p->priority == 0) {
    8000297a:	ee91                	bnez	a3,80002996 <usertrap+0x15e>
          if (p->ticks_count >= LIMIT_Q0) {
    8000297c:	478d                	li	a5,3
    8000297e:	00e7d963          	bge	a5,a4,80002990 <usertrap+0x158>
              p->priority = 1;
    80002982:	4785                	li	a5,1
    80002984:	c0bc                	sw	a5,64(s1)
              p->ticks_count = 0; // Reset counter for new queue
    80002986:	0404a223          	sw	zero,68(s1)
              yield();            // Give up CPU
    8000298a:	fc6ff0ef          	jal	80002150 <yield>
    8000298e:	b7b5                	j	800028fa <usertrap+0xc2>
              yield(); 
    80002990:	fc0ff0ef          	jal	80002150 <yield>
    80002994:	b79d                	j	800028fa <usertrap+0xc2>
      else if (p->priority == 1) {
    80002996:	4785                	li	a5,1
    80002998:	00f69f63          	bne	a3,a5,800029b6 <usertrap+0x17e>
          if (p->ticks_count >= LIMIT_Q1) {
    8000299c:	479d                	li	a5,7
    8000299e:	00e7d963          	bge	a5,a4,800029b0 <usertrap+0x178>
              p->priority = 2;
    800029a2:	4789                	li	a5,2
    800029a4:	c0bc                	sw	a5,64(s1)
              p->ticks_count = 0;
    800029a6:	0404a223          	sw	zero,68(s1)
              yield();
    800029aa:	fa6ff0ef          	jal	80002150 <yield>
    800029ae:	b7b1                	j	800028fa <usertrap+0xc2>
              yield();
    800029b0:	fa0ff0ef          	jal	80002150 <yield>
    800029b4:	b799                	j	800028fa <usertrap+0xc2>
          yield();
    800029b6:	f9aff0ef          	jal	80002150 <yield>
    800029ba:	b781                	j	800028fa <usertrap+0xc2>

00000000800029bc <kerneltrap>:
{
    800029bc:	7179                	addi	sp,sp,-48
    800029be:	f406                	sd	ra,40(sp)
    800029c0:	f022                	sd	s0,32(sp)
    800029c2:	ec26                	sd	s1,24(sp)
    800029c4:	e84a                	sd	s2,16(sp)
    800029c6:	e44e                	sd	s3,8(sp)
    800029c8:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029ca:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029ce:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029d2:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800029d6:	1004f793          	andi	a5,s1,256
    800029da:	c795                	beqz	a5,80002a06 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029dc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800029e0:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800029e2:	eb85                	bnez	a5,80002a12 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    800029e4:	de1ff0ef          	jal	800027c4 <devintr>
    800029e8:	c91d                	beqz	a0,80002a1e <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    800029ea:	4789                	li	a5,2
    800029ec:	04f50a63          	beq	a0,a5,80002a40 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029f0:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029f4:	10049073          	csrw	sstatus,s1
}
    800029f8:	70a2                	ld	ra,40(sp)
    800029fa:	7402                	ld	s0,32(sp)
    800029fc:	64e2                	ld	s1,24(sp)
    800029fe:	6942                	ld	s2,16(sp)
    80002a00:	69a2                	ld	s3,8(sp)
    80002a02:	6145                	addi	sp,sp,48
    80002a04:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a06:	00005517          	auipc	a0,0x5
    80002a0a:	91a50513          	addi	a0,a0,-1766 # 80007320 <etext+0x320>
    80002a0e:	dd3fd0ef          	jal	800007e0 <panic>
    panic("kerneltrap: interrupts enabled");
    80002a12:	00005517          	auipc	a0,0x5
    80002a16:	93650513          	addi	a0,a0,-1738 # 80007348 <etext+0x348>
    80002a1a:	dc7fd0ef          	jal	800007e0 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a1e:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a22:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002a26:	85ce                	mv	a1,s3
    80002a28:	00005517          	auipc	a0,0x5
    80002a2c:	94050513          	addi	a0,a0,-1728 # 80007368 <etext+0x368>
    80002a30:	acbfd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    80002a34:	00005517          	auipc	a0,0x5
    80002a38:	95c50513          	addi	a0,a0,-1700 # 80007390 <etext+0x390>
    80002a3c:	da5fd0ef          	jal	800007e0 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    80002a40:	896ff0ef          	jal	80001ad6 <myproc>
    80002a44:	d555                	beqz	a0,800029f0 <kerneltrap+0x34>
    80002a46:	890ff0ef          	jal	80001ad6 <myproc>
    80002a4a:	4d18                	lw	a4,24(a0)
    80002a4c:	4791                	li	a5,4
    80002a4e:	faf711e3          	bne	a4,a5,800029f0 <kerneltrap+0x34>
      struct proc *p = myproc();
    80002a52:	884ff0ef          	jal	80001ad6 <myproc>
      p->ticks_in_q[p->priority]++;
    80002a56:	4134                	lw	a3,64(a0)
    80002a58:	00269793          	slli	a5,a3,0x2
    80002a5c:	97aa                	add	a5,a5,a0
    80002a5e:	47b8                	lw	a4,72(a5)
    80002a60:	2705                	addiw	a4,a4,1
    80002a62:	c7b8                	sw	a4,72(a5)
      p->ticks_count++;
    80002a64:	417c                	lw	a5,68(a0)
    80002a66:	2785                	addiw	a5,a5,1
    80002a68:	0007871b          	sext.w	a4,a5
    80002a6c:	c17c                	sw	a5,68(a0)
      if (p->priority == 0) {
    80002a6e:	ee91                	bnez	a3,80002a8a <kerneltrap+0xce>
          if (p->ticks_count >= LIMIT_Q0) {
    80002a70:	478d                	li	a5,3
    80002a72:	00e7d963          	bge	a5,a4,80002a84 <kerneltrap+0xc8>
              p->priority = 1;
    80002a76:	4785                	li	a5,1
    80002a78:	c13c                	sw	a5,64(a0)
              p->ticks_count = 0;
    80002a7a:	04052223          	sw	zero,68(a0)
              yield();
    80002a7e:	ed2ff0ef          	jal	80002150 <yield>
    80002a82:	b7bd                	j	800029f0 <kerneltrap+0x34>
             yield(); 
    80002a84:	eccff0ef          	jal	80002150 <yield>
    80002a88:	b7a5                	j	800029f0 <kerneltrap+0x34>
      else if (p->priority == 1) {
    80002a8a:	4785                	li	a5,1
    80002a8c:	00f69f63          	bne	a3,a5,80002aaa <kerneltrap+0xee>
          if (p->ticks_count >= LIMIT_Q1) {
    80002a90:	479d                	li	a5,7
    80002a92:	00e7d963          	bge	a5,a4,80002aa4 <kerneltrap+0xe8>
              p->priority = 2;
    80002a96:	4789                	li	a5,2
    80002a98:	c13c                	sw	a5,64(a0)
              p->ticks_count = 0;
    80002a9a:	04052223          	sw	zero,68(a0)
              yield();
    80002a9e:	eb2ff0ef          	jal	80002150 <yield>
    80002aa2:	b7b9                	j	800029f0 <kerneltrap+0x34>
             yield();
    80002aa4:	eacff0ef          	jal	80002150 <yield>
    80002aa8:	b7a1                	j	800029f0 <kerneltrap+0x34>
          yield();
    80002aaa:	ea6ff0ef          	jal	80002150 <yield>
    80002aae:	b789                	j	800029f0 <kerneltrap+0x34>

0000000080002ab0 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002ab0:	1101                	addi	sp,sp,-32
    80002ab2:	ec06                	sd	ra,24(sp)
    80002ab4:	e822                	sd	s0,16(sp)
    80002ab6:	e426                	sd	s1,8(sp)
    80002ab8:	1000                	addi	s0,sp,32
    80002aba:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002abc:	81aff0ef          	jal	80001ad6 <myproc>
  switch (n) {
    80002ac0:	4795                	li	a5,5
    80002ac2:	0497e163          	bltu	a5,s1,80002b04 <argraw+0x54>
    80002ac6:	048a                	slli	s1,s1,0x2
    80002ac8:	00005717          	auipc	a4,0x5
    80002acc:	cc870713          	addi	a4,a4,-824 # 80007790 <states.0+0x30>
    80002ad0:	94ba                	add	s1,s1,a4
    80002ad2:	409c                	lw	a5,0(s1)
    80002ad4:	97ba                	add	a5,a5,a4
    80002ad6:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002ad8:	793c                	ld	a5,112(a0)
    80002ada:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002adc:	60e2                	ld	ra,24(sp)
    80002ade:	6442                	ld	s0,16(sp)
    80002ae0:	64a2                	ld	s1,8(sp)
    80002ae2:	6105                	addi	sp,sp,32
    80002ae4:	8082                	ret
    return p->trapframe->a1;
    80002ae6:	793c                	ld	a5,112(a0)
    80002ae8:	7fa8                	ld	a0,120(a5)
    80002aea:	bfcd                	j	80002adc <argraw+0x2c>
    return p->trapframe->a2;
    80002aec:	793c                	ld	a5,112(a0)
    80002aee:	63c8                	ld	a0,128(a5)
    80002af0:	b7f5                	j	80002adc <argraw+0x2c>
    return p->trapframe->a3;
    80002af2:	793c                	ld	a5,112(a0)
    80002af4:	67c8                	ld	a0,136(a5)
    80002af6:	b7dd                	j	80002adc <argraw+0x2c>
    return p->trapframe->a4;
    80002af8:	793c                	ld	a5,112(a0)
    80002afa:	6bc8                	ld	a0,144(a5)
    80002afc:	b7c5                	j	80002adc <argraw+0x2c>
    return p->trapframe->a5;
    80002afe:	793c                	ld	a5,112(a0)
    80002b00:	6fc8                	ld	a0,152(a5)
    80002b02:	bfe9                	j	80002adc <argraw+0x2c>
  panic("argraw");
    80002b04:	00005517          	auipc	a0,0x5
    80002b08:	89c50513          	addi	a0,a0,-1892 # 800073a0 <etext+0x3a0>
    80002b0c:	cd5fd0ef          	jal	800007e0 <panic>

0000000080002b10 <fetchaddr>:
{
    80002b10:	1101                	addi	sp,sp,-32
    80002b12:	ec06                	sd	ra,24(sp)
    80002b14:	e822                	sd	s0,16(sp)
    80002b16:	e426                	sd	s1,8(sp)
    80002b18:	e04a                	sd	s2,0(sp)
    80002b1a:	1000                	addi	s0,sp,32
    80002b1c:	84aa                	mv	s1,a0
    80002b1e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b20:	fb7fe0ef          	jal	80001ad6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002b24:	713c                	ld	a5,96(a0)
    80002b26:	02f4f663          	bgeu	s1,a5,80002b52 <fetchaddr+0x42>
    80002b2a:	00848713          	addi	a4,s1,8
    80002b2e:	02e7e463          	bltu	a5,a4,80002b56 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b32:	46a1                	li	a3,8
    80002b34:	8626                	mv	a2,s1
    80002b36:	85ca                	mv	a1,s2
    80002b38:	7528                	ld	a0,104(a0)
    80002b3a:	be7fe0ef          	jal	80001720 <copyin>
    80002b3e:	00a03533          	snez	a0,a0
    80002b42:	40a00533          	neg	a0,a0
}
    80002b46:	60e2                	ld	ra,24(sp)
    80002b48:	6442                	ld	s0,16(sp)
    80002b4a:	64a2                	ld	s1,8(sp)
    80002b4c:	6902                	ld	s2,0(sp)
    80002b4e:	6105                	addi	sp,sp,32
    80002b50:	8082                	ret
    return -1;
    80002b52:	557d                	li	a0,-1
    80002b54:	bfcd                	j	80002b46 <fetchaddr+0x36>
    80002b56:	557d                	li	a0,-1
    80002b58:	b7fd                	j	80002b46 <fetchaddr+0x36>

0000000080002b5a <fetchstr>:
{
    80002b5a:	7179                	addi	sp,sp,-48
    80002b5c:	f406                	sd	ra,40(sp)
    80002b5e:	f022                	sd	s0,32(sp)
    80002b60:	ec26                	sd	s1,24(sp)
    80002b62:	e84a                	sd	s2,16(sp)
    80002b64:	e44e                	sd	s3,8(sp)
    80002b66:	1800                	addi	s0,sp,48
    80002b68:	892a                	mv	s2,a0
    80002b6a:	84ae                	mv	s1,a1
    80002b6c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002b6e:	f69fe0ef          	jal	80001ad6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002b72:	86ce                	mv	a3,s3
    80002b74:	864a                	mv	a2,s2
    80002b76:	85a6                	mv	a1,s1
    80002b78:	7528                	ld	a0,104(a0)
    80002b7a:	a4dfe0ef          	jal	800015c6 <copyinstr>
    80002b7e:	00054c63          	bltz	a0,80002b96 <fetchstr+0x3c>
  return strlen(buf);
    80002b82:	8526                	mv	a0,s1
    80002b84:	bc2fe0ef          	jal	80000f46 <strlen>
}
    80002b88:	70a2                	ld	ra,40(sp)
    80002b8a:	7402                	ld	s0,32(sp)
    80002b8c:	64e2                	ld	s1,24(sp)
    80002b8e:	6942                	ld	s2,16(sp)
    80002b90:	69a2                	ld	s3,8(sp)
    80002b92:	6145                	addi	sp,sp,48
    80002b94:	8082                	ret
    return -1;
    80002b96:	557d                	li	a0,-1
    80002b98:	bfc5                	j	80002b88 <fetchstr+0x2e>

0000000080002b9a <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002b9a:	1101                	addi	sp,sp,-32
    80002b9c:	ec06                	sd	ra,24(sp)
    80002b9e:	e822                	sd	s0,16(sp)
    80002ba0:	e426                	sd	s1,8(sp)
    80002ba2:	1000                	addi	s0,sp,32
    80002ba4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ba6:	f0bff0ef          	jal	80002ab0 <argraw>
    80002baa:	c088                	sw	a0,0(s1)
}
    80002bac:	60e2                	ld	ra,24(sp)
    80002bae:	6442                	ld	s0,16(sp)
    80002bb0:	64a2                	ld	s1,8(sp)
    80002bb2:	6105                	addi	sp,sp,32
    80002bb4:	8082                	ret

0000000080002bb6 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002bb6:	1101                	addi	sp,sp,-32
    80002bb8:	ec06                	sd	ra,24(sp)
    80002bba:	e822                	sd	s0,16(sp)
    80002bbc:	e426                	sd	s1,8(sp)
    80002bbe:	1000                	addi	s0,sp,32
    80002bc0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002bc2:	eefff0ef          	jal	80002ab0 <argraw>
    80002bc6:	e088                	sd	a0,0(s1)
}
    80002bc8:	60e2                	ld	ra,24(sp)
    80002bca:	6442                	ld	s0,16(sp)
    80002bcc:	64a2                	ld	s1,8(sp)
    80002bce:	6105                	addi	sp,sp,32
    80002bd0:	8082                	ret

0000000080002bd2 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002bd2:	7179                	addi	sp,sp,-48
    80002bd4:	f406                	sd	ra,40(sp)
    80002bd6:	f022                	sd	s0,32(sp)
    80002bd8:	ec26                	sd	s1,24(sp)
    80002bda:	e84a                	sd	s2,16(sp)
    80002bdc:	1800                	addi	s0,sp,48
    80002bde:	84ae                	mv	s1,a1
    80002be0:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002be2:	fd840593          	addi	a1,s0,-40
    80002be6:	fd1ff0ef          	jal	80002bb6 <argaddr>
  return fetchstr(addr, buf, max);
    80002bea:	864a                	mv	a2,s2
    80002bec:	85a6                	mv	a1,s1
    80002bee:	fd843503          	ld	a0,-40(s0)
    80002bf2:	f69ff0ef          	jal	80002b5a <fetchstr>
}
    80002bf6:	70a2                	ld	ra,40(sp)
    80002bf8:	7402                	ld	s0,32(sp)
    80002bfa:	64e2                	ld	s1,24(sp)
    80002bfc:	6942                	ld	s2,16(sp)
    80002bfe:	6145                	addi	sp,sp,48
    80002c00:	8082                	ret

0000000080002c02 <syscall>:
[SYS_freemem] sys_freemem,
};

void
syscall(void)
{
    80002c02:	1101                	addi	sp,sp,-32
    80002c04:	ec06                	sd	ra,24(sp)
    80002c06:	e822                	sd	s0,16(sp)
    80002c08:	e426                	sd	s1,8(sp)
    80002c0a:	e04a                	sd	s2,0(sp)
    80002c0c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002c0e:	ec9fe0ef          	jal	80001ad6 <myproc>
    80002c12:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002c14:	07053903          	ld	s2,112(a0)
    80002c18:	0a893783          	ld	a5,168(s2)
    80002c1c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c20:	37fd                	addiw	a5,a5,-1
    80002c22:	4759                	li	a4,22
    80002c24:	00f76f63          	bltu	a4,a5,80002c42 <syscall+0x40>
    80002c28:	00369713          	slli	a4,a3,0x3
    80002c2c:	00005797          	auipc	a5,0x5
    80002c30:	b7c78793          	addi	a5,a5,-1156 # 800077a8 <syscalls>
    80002c34:	97ba                	add	a5,a5,a4
    80002c36:	639c                	ld	a5,0(a5)
    80002c38:	c789                	beqz	a5,80002c42 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002c3a:	9782                	jalr	a5
    80002c3c:	06a93823          	sd	a0,112(s2)
    80002c40:	a829                	j	80002c5a <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002c42:	17048613          	addi	a2,s1,368
    80002c46:	588c                	lw	a1,48(s1)
    80002c48:	00004517          	auipc	a0,0x4
    80002c4c:	76050513          	addi	a0,a0,1888 # 800073a8 <etext+0x3a8>
    80002c50:	8abfd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002c54:	78bc                	ld	a5,112(s1)
    80002c56:	577d                	li	a4,-1
    80002c58:	fbb8                	sd	a4,112(a5)
  }
}
    80002c5a:	60e2                	ld	ra,24(sp)
    80002c5c:	6442                	ld	s0,16(sp)
    80002c5e:	64a2                	ld	s1,8(sp)
    80002c60:	6902                	ld	s2,0(sp)
    80002c62:	6105                	addi	sp,sp,32
    80002c64:	8082                	ret

0000000080002c66 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002c66:	1101                	addi	sp,sp,-32
    80002c68:	ec06                	sd	ra,24(sp)
    80002c6a:	e822                	sd	s0,16(sp)
    80002c6c:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002c6e:	fec40593          	addi	a1,s0,-20
    80002c72:	4501                	li	a0,0
    80002c74:	f27ff0ef          	jal	80002b9a <argint>
  kexit(n);
    80002c78:	fec42503          	lw	a0,-20(s0)
    80002c7c:	e0cff0ef          	jal	80002288 <kexit>
  return 0;  // not reached
}
    80002c80:	4501                	li	a0,0
    80002c82:	60e2                	ld	ra,24(sp)
    80002c84:	6442                	ld	s0,16(sp)
    80002c86:	6105                	addi	sp,sp,32
    80002c88:	8082                	ret

0000000080002c8a <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c8a:	1141                	addi	sp,sp,-16
    80002c8c:	e406                	sd	ra,8(sp)
    80002c8e:	e022                	sd	s0,0(sp)
    80002c90:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c92:	e45fe0ef          	jal	80001ad6 <myproc>
}
    80002c96:	5908                	lw	a0,48(a0)
    80002c98:	60a2                	ld	ra,8(sp)
    80002c9a:	6402                	ld	s0,0(sp)
    80002c9c:	0141                	addi	sp,sp,16
    80002c9e:	8082                	ret

0000000080002ca0 <sys_fork>:

uint64
sys_fork(void)
{
    80002ca0:	1141                	addi	sp,sp,-16
    80002ca2:	e406                	sd	ra,8(sp)
    80002ca4:	e022                	sd	s0,0(sp)
    80002ca6:	0800                	addi	s0,sp,16
  return kfork();
    80002ca8:	9a6ff0ef          	jal	80001e4e <kfork>
}
    80002cac:	60a2                	ld	ra,8(sp)
    80002cae:	6402                	ld	s0,0(sp)
    80002cb0:	0141                	addi	sp,sp,16
    80002cb2:	8082                	ret

0000000080002cb4 <sys_wait>:

uint64
sys_wait(void)
{
    80002cb4:	1101                	addi	sp,sp,-32
    80002cb6:	ec06                	sd	ra,24(sp)
    80002cb8:	e822                	sd	s0,16(sp)
    80002cba:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002cbc:	fe840593          	addi	a1,s0,-24
    80002cc0:	4501                	li	a0,0
    80002cc2:	ef5ff0ef          	jal	80002bb6 <argaddr>
  return kwait(p);
    80002cc6:	fe843503          	ld	a0,-24(s0)
    80002cca:	f14ff0ef          	jal	800023de <kwait>
}
    80002cce:	60e2                	ld	ra,24(sp)
    80002cd0:	6442                	ld	s0,16(sp)
    80002cd2:	6105                	addi	sp,sp,32
    80002cd4:	8082                	ret

0000000080002cd6 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002cd6:	7179                	addi	sp,sp,-48
    80002cd8:	f406                	sd	ra,40(sp)
    80002cda:	f022                	sd	s0,32(sp)
    80002cdc:	ec26                	sd	s1,24(sp)
    80002cde:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002ce0:	fd840593          	addi	a1,s0,-40
    80002ce4:	4501                	li	a0,0
    80002ce6:	eb5ff0ef          	jal	80002b9a <argint>
  argint(1, &t);
    80002cea:	fdc40593          	addi	a1,s0,-36
    80002cee:	4505                	li	a0,1
    80002cf0:	eabff0ef          	jal	80002b9a <argint>
  addr = myproc()->sz;
    80002cf4:	de3fe0ef          	jal	80001ad6 <myproc>
    80002cf8:	7124                	ld	s1,96(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002cfa:	fdc42703          	lw	a4,-36(s0)
    80002cfe:	4785                	li	a5,1
    80002d00:	02f70763          	beq	a4,a5,80002d2e <sys_sbrk+0x58>
    80002d04:	fd842783          	lw	a5,-40(s0)
    80002d08:	0207c363          	bltz	a5,80002d2e <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002d0c:	97a6                	add	a5,a5,s1
    80002d0e:	0297ee63          	bltu	a5,s1,80002d4a <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    80002d12:	02000737          	lui	a4,0x2000
    80002d16:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002d18:	0736                	slli	a4,a4,0xd
    80002d1a:	02f76a63          	bltu	a4,a5,80002d4e <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002d1e:	db9fe0ef          	jal	80001ad6 <myproc>
    80002d22:	fd842703          	lw	a4,-40(s0)
    80002d26:	713c                	ld	a5,96(a0)
    80002d28:	97ba                	add	a5,a5,a4
    80002d2a:	f13c                	sd	a5,96(a0)
    80002d2c:	a039                	j	80002d3a <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002d2e:	fd842503          	lw	a0,-40(s0)
    80002d32:	8baff0ef          	jal	80001dec <growproc>
    80002d36:	00054863          	bltz	a0,80002d46 <sys_sbrk+0x70>
  }
  return addr;
}
    80002d3a:	8526                	mv	a0,s1
    80002d3c:	70a2                	ld	ra,40(sp)
    80002d3e:	7402                	ld	s0,32(sp)
    80002d40:	64e2                	ld	s1,24(sp)
    80002d42:	6145                	addi	sp,sp,48
    80002d44:	8082                	ret
      return -1;
    80002d46:	54fd                	li	s1,-1
    80002d48:	bfcd                	j	80002d3a <sys_sbrk+0x64>
      return -1;
    80002d4a:	54fd                	li	s1,-1
    80002d4c:	b7fd                	j	80002d3a <sys_sbrk+0x64>
      return -1;
    80002d4e:	54fd                	li	s1,-1
    80002d50:	b7ed                	j	80002d3a <sys_sbrk+0x64>

0000000080002d52 <sys_pause>:

uint64
sys_pause(void)
{
    80002d52:	7139                	addi	sp,sp,-64
    80002d54:	fc06                	sd	ra,56(sp)
    80002d56:	f822                	sd	s0,48(sp)
    80002d58:	f04a                	sd	s2,32(sp)
    80002d5a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002d5c:	fcc40593          	addi	a1,s0,-52
    80002d60:	4501                	li	a0,0
    80002d62:	e39ff0ef          	jal	80002b9a <argint>
  if(n < 0)
    80002d66:	fcc42783          	lw	a5,-52(s0)
    80002d6a:	0607c763          	bltz	a5,80002dd8 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002d6e:	00123517          	auipc	a0,0x123
    80002d72:	09250513          	addi	a0,a0,146 # 80125e00 <tickslock>
    80002d76:	f8dfd0ef          	jal	80000d02 <acquire>
  ticks0 = ticks;
    80002d7a:	00005917          	auipc	s2,0x5
    80002d7e:	b3692903          	lw	s2,-1226(s2) # 800078b0 <ticks>
  while(ticks - ticks0 < n){
    80002d82:	fcc42783          	lw	a5,-52(s0)
    80002d86:	cf8d                	beqz	a5,80002dc0 <sys_pause+0x6e>
    80002d88:	f426                	sd	s1,40(sp)
    80002d8a:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d8c:	00123997          	auipc	s3,0x123
    80002d90:	07498993          	addi	s3,s3,116 # 80125e00 <tickslock>
    80002d94:	00005497          	auipc	s1,0x5
    80002d98:	b1c48493          	addi	s1,s1,-1252 # 800078b0 <ticks>
    if(killed(myproc())){
    80002d9c:	d3bfe0ef          	jal	80001ad6 <myproc>
    80002da0:	e14ff0ef          	jal	800023b4 <killed>
    80002da4:	ed0d                	bnez	a0,80002dde <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002da6:	85ce                	mv	a1,s3
    80002da8:	8526                	mv	a0,s1
    80002daa:	bd2ff0ef          	jal	8000217c <sleep>
  while(ticks - ticks0 < n){
    80002dae:	409c                	lw	a5,0(s1)
    80002db0:	412787bb          	subw	a5,a5,s2
    80002db4:	fcc42703          	lw	a4,-52(s0)
    80002db8:	fee7e2e3          	bltu	a5,a4,80002d9c <sys_pause+0x4a>
    80002dbc:	74a2                	ld	s1,40(sp)
    80002dbe:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002dc0:	00123517          	auipc	a0,0x123
    80002dc4:	04050513          	addi	a0,a0,64 # 80125e00 <tickslock>
    80002dc8:	fd3fd0ef          	jal	80000d9a <release>
  return 0;
    80002dcc:	4501                	li	a0,0
}
    80002dce:	70e2                	ld	ra,56(sp)
    80002dd0:	7442                	ld	s0,48(sp)
    80002dd2:	7902                	ld	s2,32(sp)
    80002dd4:	6121                	addi	sp,sp,64
    80002dd6:	8082                	ret
    n = 0;
    80002dd8:	fc042623          	sw	zero,-52(s0)
    80002ddc:	bf49                	j	80002d6e <sys_pause+0x1c>
      release(&tickslock);
    80002dde:	00123517          	auipc	a0,0x123
    80002de2:	02250513          	addi	a0,a0,34 # 80125e00 <tickslock>
    80002de6:	fb5fd0ef          	jal	80000d9a <release>
      return -1;
    80002dea:	557d                	li	a0,-1
    80002dec:	74a2                	ld	s1,40(sp)
    80002dee:	69e2                	ld	s3,24(sp)
    80002df0:	bff9                	j	80002dce <sys_pause+0x7c>

0000000080002df2 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002df2:	7139                	addi	sp,sp,-64
    80002df4:	fc06                	sd	ra,56(sp)
    80002df6:	f822                	sd	s0,48(sp)
    80002df8:	f04a                	sd	s2,32(sp)
    80002dfa:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002dfc:	fcc40593          	addi	a1,s0,-52
    80002e00:	4501                	li	a0,0
    80002e02:	d99ff0ef          	jal	80002b9a <argint>
  if(n < 0)
    80002e06:	fcc42783          	lw	a5,-52(s0)
    80002e0a:	0607c763          	bltz	a5,80002e78 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002e0e:	00123517          	auipc	a0,0x123
    80002e12:	ff250513          	addi	a0,a0,-14 # 80125e00 <tickslock>
    80002e16:	eedfd0ef          	jal	80000d02 <acquire>
  ticks0 = ticks;
    80002e1a:	00005917          	auipc	s2,0x5
    80002e1e:	a9692903          	lw	s2,-1386(s2) # 800078b0 <ticks>
  while(ticks - ticks0 < n){
    80002e22:	fcc42783          	lw	a5,-52(s0)
    80002e26:	cf8d                	beqz	a5,80002e60 <sys_sleep+0x6e>
    80002e28:	f426                	sd	s1,40(sp)
    80002e2a:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002e2c:	00123997          	auipc	s3,0x123
    80002e30:	fd498993          	addi	s3,s3,-44 # 80125e00 <tickslock>
    80002e34:	00005497          	auipc	s1,0x5
    80002e38:	a7c48493          	addi	s1,s1,-1412 # 800078b0 <ticks>
    if(killed(myproc())){
    80002e3c:	c9bfe0ef          	jal	80001ad6 <myproc>
    80002e40:	d74ff0ef          	jal	800023b4 <killed>
    80002e44:	ed0d                	bnez	a0,80002e7e <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80002e46:	85ce                	mv	a1,s3
    80002e48:	8526                	mv	a0,s1
    80002e4a:	b32ff0ef          	jal	8000217c <sleep>
  while(ticks - ticks0 < n){
    80002e4e:	409c                	lw	a5,0(s1)
    80002e50:	412787bb          	subw	a5,a5,s2
    80002e54:	fcc42703          	lw	a4,-52(s0)
    80002e58:	fee7e2e3          	bltu	a5,a4,80002e3c <sys_sleep+0x4a>
    80002e5c:	74a2                	ld	s1,40(sp)
    80002e5e:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002e60:	00123517          	auipc	a0,0x123
    80002e64:	fa050513          	addi	a0,a0,-96 # 80125e00 <tickslock>
    80002e68:	f33fd0ef          	jal	80000d9a <release>
  return 0;
    80002e6c:	4501                	li	a0,0
}
    80002e6e:	70e2                	ld	ra,56(sp)
    80002e70:	7442                	ld	s0,48(sp)
    80002e72:	7902                	ld	s2,32(sp)
    80002e74:	6121                	addi	sp,sp,64
    80002e76:	8082                	ret
    n = 0;
    80002e78:	fc042623          	sw	zero,-52(s0)
    80002e7c:	bf49                	j	80002e0e <sys_sleep+0x1c>
      release(&tickslock);
    80002e7e:	00123517          	auipc	a0,0x123
    80002e82:	f8250513          	addi	a0,a0,-126 # 80125e00 <tickslock>
    80002e86:	f15fd0ef          	jal	80000d9a <release>
      return -1;
    80002e8a:	557d                	li	a0,-1
    80002e8c:	74a2                	ld	s1,40(sp)
    80002e8e:	69e2                	ld	s3,24(sp)
    80002e90:	bff9                	j	80002e6e <sys_sleep+0x7c>

0000000080002e92 <sys_kill>:

uint64
sys_kill(void)
{
    80002e92:	1101                	addi	sp,sp,-32
    80002e94:	ec06                	sd	ra,24(sp)
    80002e96:	e822                	sd	s0,16(sp)
    80002e98:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002e9a:	fec40593          	addi	a1,s0,-20
    80002e9e:	4501                	li	a0,0
    80002ea0:	cfbff0ef          	jal	80002b9a <argint>
  return kkill(pid);
    80002ea4:	fec42503          	lw	a0,-20(s0)
    80002ea8:	c82ff0ef          	jal	8000232a <kkill>
}
    80002eac:	60e2                	ld	ra,24(sp)
    80002eae:	6442                	ld	s0,16(sp)
    80002eb0:	6105                	addi	sp,sp,32
    80002eb2:	8082                	ret

0000000080002eb4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002eb4:	1101                	addi	sp,sp,-32
    80002eb6:	ec06                	sd	ra,24(sp)
    80002eb8:	e822                	sd	s0,16(sp)
    80002eba:	e426                	sd	s1,8(sp)
    80002ebc:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ebe:	00123517          	auipc	a0,0x123
    80002ec2:	f4250513          	addi	a0,a0,-190 # 80125e00 <tickslock>
    80002ec6:	e3dfd0ef          	jal	80000d02 <acquire>
  xticks = ticks;
    80002eca:	00005497          	auipc	s1,0x5
    80002ece:	9e64a483          	lw	s1,-1562(s1) # 800078b0 <ticks>
  release(&tickslock);
    80002ed2:	00123517          	auipc	a0,0x123
    80002ed6:	f2e50513          	addi	a0,a0,-210 # 80125e00 <tickslock>
    80002eda:	ec1fd0ef          	jal	80000d9a <release>
  return xticks;
}
    80002ede:	02049513          	slli	a0,s1,0x20
    80002ee2:	9101                	srli	a0,a0,0x20
    80002ee4:	60e2                	ld	ra,24(sp)
    80002ee6:	6442                	ld	s0,16(sp)
    80002ee8:	64a2                	ld	s1,8(sp)
    80002eea:	6105                	addi	sp,sp,32
    80002eec:	8082                	ret

0000000080002eee <sys_freemem>:

uint64
sys_freemem(void)
{
    80002eee:	1141                	addi	sp,sp,-16
    80002ef0:	e406                	sd	ra,8(sp)
    80002ef2:	e022                	sd	s0,0(sp)
    80002ef4:	0800                	addi	s0,sp,16
  return kfreemem();
    80002ef6:	d47fd0ef          	jal	80000c3c <kfreemem>
}
    80002efa:	60a2                	ld	ra,8(sp)
    80002efc:	6402                	ld	s0,0(sp)
    80002efe:	0141                	addi	sp,sp,16
    80002f00:	8082                	ret

0000000080002f02 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002f02:	7179                	addi	sp,sp,-48
    80002f04:	f406                	sd	ra,40(sp)
    80002f06:	f022                	sd	s0,32(sp)
    80002f08:	ec26                	sd	s1,24(sp)
    80002f0a:	e84a                	sd	s2,16(sp)
    80002f0c:	e44e                	sd	s3,8(sp)
    80002f0e:	e052                	sd	s4,0(sp)
    80002f10:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002f12:	00004597          	auipc	a1,0x4
    80002f16:	4b658593          	addi	a1,a1,1206 # 800073c8 <etext+0x3c8>
    80002f1a:	00123517          	auipc	a0,0x123
    80002f1e:	efe50513          	addi	a0,a0,-258 # 80125e18 <bcache>
    80002f22:	d61fd0ef          	jal	80000c82 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002f26:	0012b797          	auipc	a5,0x12b
    80002f2a:	ef278793          	addi	a5,a5,-270 # 8012de18 <bcache+0x8000>
    80002f2e:	0012b717          	auipc	a4,0x12b
    80002f32:	15270713          	addi	a4,a4,338 # 8012e080 <bcache+0x8268>
    80002f36:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002f3a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f3e:	00123497          	auipc	s1,0x123
    80002f42:	ef248493          	addi	s1,s1,-270 # 80125e30 <bcache+0x18>
    b->next = bcache.head.next;
    80002f46:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f48:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f4a:	00004a17          	auipc	s4,0x4
    80002f4e:	486a0a13          	addi	s4,s4,1158 # 800073d0 <etext+0x3d0>
    b->next = bcache.head.next;
    80002f52:	2b893783          	ld	a5,696(s2)
    80002f56:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f58:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f5c:	85d2                	mv	a1,s4
    80002f5e:	01048513          	addi	a0,s1,16
    80002f62:	322010ef          	jal	80004284 <initsleeplock>
    bcache.head.next->prev = b;
    80002f66:	2b893783          	ld	a5,696(s2)
    80002f6a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f6c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f70:	45848493          	addi	s1,s1,1112
    80002f74:	fd349fe3          	bne	s1,s3,80002f52 <binit+0x50>
  }
}
    80002f78:	70a2                	ld	ra,40(sp)
    80002f7a:	7402                	ld	s0,32(sp)
    80002f7c:	64e2                	ld	s1,24(sp)
    80002f7e:	6942                	ld	s2,16(sp)
    80002f80:	69a2                	ld	s3,8(sp)
    80002f82:	6a02                	ld	s4,0(sp)
    80002f84:	6145                	addi	sp,sp,48
    80002f86:	8082                	ret

0000000080002f88 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f88:	7179                	addi	sp,sp,-48
    80002f8a:	f406                	sd	ra,40(sp)
    80002f8c:	f022                	sd	s0,32(sp)
    80002f8e:	ec26                	sd	s1,24(sp)
    80002f90:	e84a                	sd	s2,16(sp)
    80002f92:	e44e                	sd	s3,8(sp)
    80002f94:	1800                	addi	s0,sp,48
    80002f96:	892a                	mv	s2,a0
    80002f98:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002f9a:	00123517          	auipc	a0,0x123
    80002f9e:	e7e50513          	addi	a0,a0,-386 # 80125e18 <bcache>
    80002fa2:	d61fd0ef          	jal	80000d02 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002fa6:	0012b497          	auipc	s1,0x12b
    80002faa:	12a4b483          	ld	s1,298(s1) # 8012e0d0 <bcache+0x82b8>
    80002fae:	0012b797          	auipc	a5,0x12b
    80002fb2:	0d278793          	addi	a5,a5,210 # 8012e080 <bcache+0x8268>
    80002fb6:	02f48b63          	beq	s1,a5,80002fec <bread+0x64>
    80002fba:	873e                	mv	a4,a5
    80002fbc:	a021                	j	80002fc4 <bread+0x3c>
    80002fbe:	68a4                	ld	s1,80(s1)
    80002fc0:	02e48663          	beq	s1,a4,80002fec <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002fc4:	449c                	lw	a5,8(s1)
    80002fc6:	ff279ce3          	bne	a5,s2,80002fbe <bread+0x36>
    80002fca:	44dc                	lw	a5,12(s1)
    80002fcc:	ff3799e3          	bne	a5,s3,80002fbe <bread+0x36>
      b->refcnt++;
    80002fd0:	40bc                	lw	a5,64(s1)
    80002fd2:	2785                	addiw	a5,a5,1
    80002fd4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002fd6:	00123517          	auipc	a0,0x123
    80002fda:	e4250513          	addi	a0,a0,-446 # 80125e18 <bcache>
    80002fde:	dbdfd0ef          	jal	80000d9a <release>
      acquiresleep(&b->lock);
    80002fe2:	01048513          	addi	a0,s1,16
    80002fe6:	2d4010ef          	jal	800042ba <acquiresleep>
      return b;
    80002fea:	a889                	j	8000303c <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fec:	0012b497          	auipc	s1,0x12b
    80002ff0:	0dc4b483          	ld	s1,220(s1) # 8012e0c8 <bcache+0x82b0>
    80002ff4:	0012b797          	auipc	a5,0x12b
    80002ff8:	08c78793          	addi	a5,a5,140 # 8012e080 <bcache+0x8268>
    80002ffc:	00f48863          	beq	s1,a5,8000300c <bread+0x84>
    80003000:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003002:	40bc                	lw	a5,64(s1)
    80003004:	cb91                	beqz	a5,80003018 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003006:	64a4                	ld	s1,72(s1)
    80003008:	fee49de3          	bne	s1,a4,80003002 <bread+0x7a>
  panic("bget: no buffers");
    8000300c:	00004517          	auipc	a0,0x4
    80003010:	3cc50513          	addi	a0,a0,972 # 800073d8 <etext+0x3d8>
    80003014:	fccfd0ef          	jal	800007e0 <panic>
      b->dev = dev;
    80003018:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000301c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003020:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003024:	4785                	li	a5,1
    80003026:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003028:	00123517          	auipc	a0,0x123
    8000302c:	df050513          	addi	a0,a0,-528 # 80125e18 <bcache>
    80003030:	d6bfd0ef          	jal	80000d9a <release>
      acquiresleep(&b->lock);
    80003034:	01048513          	addi	a0,s1,16
    80003038:	282010ef          	jal	800042ba <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000303c:	409c                	lw	a5,0(s1)
    8000303e:	cb89                	beqz	a5,80003050 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003040:	8526                	mv	a0,s1
    80003042:	70a2                	ld	ra,40(sp)
    80003044:	7402                	ld	s0,32(sp)
    80003046:	64e2                	ld	s1,24(sp)
    80003048:	6942                	ld	s2,16(sp)
    8000304a:	69a2                	ld	s3,8(sp)
    8000304c:	6145                	addi	sp,sp,48
    8000304e:	8082                	ret
    virtio_disk_rw(b, 0);
    80003050:	4581                	li	a1,0
    80003052:	8526                	mv	a0,s1
    80003054:	2cd020ef          	jal	80005b20 <virtio_disk_rw>
    b->valid = 1;
    80003058:	4785                	li	a5,1
    8000305a:	c09c                	sw	a5,0(s1)
  return b;
    8000305c:	b7d5                	j	80003040 <bread+0xb8>

000000008000305e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000305e:	1101                	addi	sp,sp,-32
    80003060:	ec06                	sd	ra,24(sp)
    80003062:	e822                	sd	s0,16(sp)
    80003064:	e426                	sd	s1,8(sp)
    80003066:	1000                	addi	s0,sp,32
    80003068:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000306a:	0541                	addi	a0,a0,16
    8000306c:	2cc010ef          	jal	80004338 <holdingsleep>
    80003070:	c911                	beqz	a0,80003084 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003072:	4585                	li	a1,1
    80003074:	8526                	mv	a0,s1
    80003076:	2ab020ef          	jal	80005b20 <virtio_disk_rw>
}
    8000307a:	60e2                	ld	ra,24(sp)
    8000307c:	6442                	ld	s0,16(sp)
    8000307e:	64a2                	ld	s1,8(sp)
    80003080:	6105                	addi	sp,sp,32
    80003082:	8082                	ret
    panic("bwrite");
    80003084:	00004517          	auipc	a0,0x4
    80003088:	36c50513          	addi	a0,a0,876 # 800073f0 <etext+0x3f0>
    8000308c:	f54fd0ef          	jal	800007e0 <panic>

0000000080003090 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003090:	1101                	addi	sp,sp,-32
    80003092:	ec06                	sd	ra,24(sp)
    80003094:	e822                	sd	s0,16(sp)
    80003096:	e426                	sd	s1,8(sp)
    80003098:	e04a                	sd	s2,0(sp)
    8000309a:	1000                	addi	s0,sp,32
    8000309c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000309e:	01050913          	addi	s2,a0,16
    800030a2:	854a                	mv	a0,s2
    800030a4:	294010ef          	jal	80004338 <holdingsleep>
    800030a8:	c135                	beqz	a0,8000310c <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    800030aa:	854a                	mv	a0,s2
    800030ac:	254010ef          	jal	80004300 <releasesleep>

  acquire(&bcache.lock);
    800030b0:	00123517          	auipc	a0,0x123
    800030b4:	d6850513          	addi	a0,a0,-664 # 80125e18 <bcache>
    800030b8:	c4bfd0ef          	jal	80000d02 <acquire>
  b->refcnt--;
    800030bc:	40bc                	lw	a5,64(s1)
    800030be:	37fd                	addiw	a5,a5,-1
    800030c0:	0007871b          	sext.w	a4,a5
    800030c4:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800030c6:	e71d                	bnez	a4,800030f4 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800030c8:	68b8                	ld	a4,80(s1)
    800030ca:	64bc                	ld	a5,72(s1)
    800030cc:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800030ce:	68b8                	ld	a4,80(s1)
    800030d0:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800030d2:	0012b797          	auipc	a5,0x12b
    800030d6:	d4678793          	addi	a5,a5,-698 # 8012de18 <bcache+0x8000>
    800030da:	2b87b703          	ld	a4,696(a5)
    800030de:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800030e0:	0012b717          	auipc	a4,0x12b
    800030e4:	fa070713          	addi	a4,a4,-96 # 8012e080 <bcache+0x8268>
    800030e8:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800030ea:	2b87b703          	ld	a4,696(a5)
    800030ee:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800030f0:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800030f4:	00123517          	auipc	a0,0x123
    800030f8:	d2450513          	addi	a0,a0,-732 # 80125e18 <bcache>
    800030fc:	c9ffd0ef          	jal	80000d9a <release>
}
    80003100:	60e2                	ld	ra,24(sp)
    80003102:	6442                	ld	s0,16(sp)
    80003104:	64a2                	ld	s1,8(sp)
    80003106:	6902                	ld	s2,0(sp)
    80003108:	6105                	addi	sp,sp,32
    8000310a:	8082                	ret
    panic("brelse");
    8000310c:	00004517          	auipc	a0,0x4
    80003110:	2ec50513          	addi	a0,a0,748 # 800073f8 <etext+0x3f8>
    80003114:	eccfd0ef          	jal	800007e0 <panic>

0000000080003118 <bpin>:

void
bpin(struct buf *b) {
    80003118:	1101                	addi	sp,sp,-32
    8000311a:	ec06                	sd	ra,24(sp)
    8000311c:	e822                	sd	s0,16(sp)
    8000311e:	e426                	sd	s1,8(sp)
    80003120:	1000                	addi	s0,sp,32
    80003122:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003124:	00123517          	auipc	a0,0x123
    80003128:	cf450513          	addi	a0,a0,-780 # 80125e18 <bcache>
    8000312c:	bd7fd0ef          	jal	80000d02 <acquire>
  b->refcnt++;
    80003130:	40bc                	lw	a5,64(s1)
    80003132:	2785                	addiw	a5,a5,1
    80003134:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003136:	00123517          	auipc	a0,0x123
    8000313a:	ce250513          	addi	a0,a0,-798 # 80125e18 <bcache>
    8000313e:	c5dfd0ef          	jal	80000d9a <release>
}
    80003142:	60e2                	ld	ra,24(sp)
    80003144:	6442                	ld	s0,16(sp)
    80003146:	64a2                	ld	s1,8(sp)
    80003148:	6105                	addi	sp,sp,32
    8000314a:	8082                	ret

000000008000314c <bunpin>:

void
bunpin(struct buf *b) {
    8000314c:	1101                	addi	sp,sp,-32
    8000314e:	ec06                	sd	ra,24(sp)
    80003150:	e822                	sd	s0,16(sp)
    80003152:	e426                	sd	s1,8(sp)
    80003154:	1000                	addi	s0,sp,32
    80003156:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003158:	00123517          	auipc	a0,0x123
    8000315c:	cc050513          	addi	a0,a0,-832 # 80125e18 <bcache>
    80003160:	ba3fd0ef          	jal	80000d02 <acquire>
  b->refcnt--;
    80003164:	40bc                	lw	a5,64(s1)
    80003166:	37fd                	addiw	a5,a5,-1
    80003168:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000316a:	00123517          	auipc	a0,0x123
    8000316e:	cae50513          	addi	a0,a0,-850 # 80125e18 <bcache>
    80003172:	c29fd0ef          	jal	80000d9a <release>
}
    80003176:	60e2                	ld	ra,24(sp)
    80003178:	6442                	ld	s0,16(sp)
    8000317a:	64a2                	ld	s1,8(sp)
    8000317c:	6105                	addi	sp,sp,32
    8000317e:	8082                	ret

0000000080003180 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003180:	1101                	addi	sp,sp,-32
    80003182:	ec06                	sd	ra,24(sp)
    80003184:	e822                	sd	s0,16(sp)
    80003186:	e426                	sd	s1,8(sp)
    80003188:	e04a                	sd	s2,0(sp)
    8000318a:	1000                	addi	s0,sp,32
    8000318c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000318e:	00d5d59b          	srliw	a1,a1,0xd
    80003192:	0012b797          	auipc	a5,0x12b
    80003196:	3627a783          	lw	a5,866(a5) # 8012e4f4 <sb+0x1c>
    8000319a:	9dbd                	addw	a1,a1,a5
    8000319c:	dedff0ef          	jal	80002f88 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800031a0:	0074f713          	andi	a4,s1,7
    800031a4:	4785                	li	a5,1
    800031a6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800031aa:	14ce                	slli	s1,s1,0x33
    800031ac:	90d9                	srli	s1,s1,0x36
    800031ae:	00950733          	add	a4,a0,s1
    800031b2:	05874703          	lbu	a4,88(a4)
    800031b6:	00e7f6b3          	and	a3,a5,a4
    800031ba:	c29d                	beqz	a3,800031e0 <bfree+0x60>
    800031bc:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800031be:	94aa                	add	s1,s1,a0
    800031c0:	fff7c793          	not	a5,a5
    800031c4:	8f7d                	and	a4,a4,a5
    800031c6:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800031ca:	7f9000ef          	jal	800041c2 <log_write>
  brelse(bp);
    800031ce:	854a                	mv	a0,s2
    800031d0:	ec1ff0ef          	jal	80003090 <brelse>
}
    800031d4:	60e2                	ld	ra,24(sp)
    800031d6:	6442                	ld	s0,16(sp)
    800031d8:	64a2                	ld	s1,8(sp)
    800031da:	6902                	ld	s2,0(sp)
    800031dc:	6105                	addi	sp,sp,32
    800031de:	8082                	ret
    panic("freeing free block");
    800031e0:	00004517          	auipc	a0,0x4
    800031e4:	22050513          	addi	a0,a0,544 # 80007400 <etext+0x400>
    800031e8:	df8fd0ef          	jal	800007e0 <panic>

00000000800031ec <balloc>:
{
    800031ec:	711d                	addi	sp,sp,-96
    800031ee:	ec86                	sd	ra,88(sp)
    800031f0:	e8a2                	sd	s0,80(sp)
    800031f2:	e4a6                	sd	s1,72(sp)
    800031f4:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800031f6:	0012b797          	auipc	a5,0x12b
    800031fa:	2e67a783          	lw	a5,742(a5) # 8012e4dc <sb+0x4>
    800031fe:	0e078f63          	beqz	a5,800032fc <balloc+0x110>
    80003202:	e0ca                	sd	s2,64(sp)
    80003204:	fc4e                	sd	s3,56(sp)
    80003206:	f852                	sd	s4,48(sp)
    80003208:	f456                	sd	s5,40(sp)
    8000320a:	f05a                	sd	s6,32(sp)
    8000320c:	ec5e                	sd	s7,24(sp)
    8000320e:	e862                	sd	s8,16(sp)
    80003210:	e466                	sd	s9,8(sp)
    80003212:	8baa                	mv	s7,a0
    80003214:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003216:	0012bb17          	auipc	s6,0x12b
    8000321a:	2c2b0b13          	addi	s6,s6,706 # 8012e4d8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000321e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003220:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003222:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003224:	6c89                	lui	s9,0x2
    80003226:	a0b5                	j	80003292 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003228:	97ca                	add	a5,a5,s2
    8000322a:	8e55                	or	a2,a2,a3
    8000322c:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003230:	854a                	mv	a0,s2
    80003232:	791000ef          	jal	800041c2 <log_write>
        brelse(bp);
    80003236:	854a                	mv	a0,s2
    80003238:	e59ff0ef          	jal	80003090 <brelse>
  bp = bread(dev, bno);
    8000323c:	85a6                	mv	a1,s1
    8000323e:	855e                	mv	a0,s7
    80003240:	d49ff0ef          	jal	80002f88 <bread>
    80003244:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003246:	40000613          	li	a2,1024
    8000324a:	4581                	li	a1,0
    8000324c:	05850513          	addi	a0,a0,88
    80003250:	b87fd0ef          	jal	80000dd6 <memset>
  log_write(bp);
    80003254:	854a                	mv	a0,s2
    80003256:	76d000ef          	jal	800041c2 <log_write>
  brelse(bp);
    8000325a:	854a                	mv	a0,s2
    8000325c:	e35ff0ef          	jal	80003090 <brelse>
}
    80003260:	6906                	ld	s2,64(sp)
    80003262:	79e2                	ld	s3,56(sp)
    80003264:	7a42                	ld	s4,48(sp)
    80003266:	7aa2                	ld	s5,40(sp)
    80003268:	7b02                	ld	s6,32(sp)
    8000326a:	6be2                	ld	s7,24(sp)
    8000326c:	6c42                	ld	s8,16(sp)
    8000326e:	6ca2                	ld	s9,8(sp)
}
    80003270:	8526                	mv	a0,s1
    80003272:	60e6                	ld	ra,88(sp)
    80003274:	6446                	ld	s0,80(sp)
    80003276:	64a6                	ld	s1,72(sp)
    80003278:	6125                	addi	sp,sp,96
    8000327a:	8082                	ret
    brelse(bp);
    8000327c:	854a                	mv	a0,s2
    8000327e:	e13ff0ef          	jal	80003090 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003282:	015c87bb          	addw	a5,s9,s5
    80003286:	00078a9b          	sext.w	s5,a5
    8000328a:	004b2703          	lw	a4,4(s6)
    8000328e:	04eaff63          	bgeu	s5,a4,800032ec <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80003292:	41fad79b          	sraiw	a5,s5,0x1f
    80003296:	0137d79b          	srliw	a5,a5,0x13
    8000329a:	015787bb          	addw	a5,a5,s5
    8000329e:	40d7d79b          	sraiw	a5,a5,0xd
    800032a2:	01cb2583          	lw	a1,28(s6)
    800032a6:	9dbd                	addw	a1,a1,a5
    800032a8:	855e                	mv	a0,s7
    800032aa:	cdfff0ef          	jal	80002f88 <bread>
    800032ae:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032b0:	004b2503          	lw	a0,4(s6)
    800032b4:	000a849b          	sext.w	s1,s5
    800032b8:	8762                	mv	a4,s8
    800032ba:	fca4f1e3          	bgeu	s1,a0,8000327c <balloc+0x90>
      m = 1 << (bi % 8);
    800032be:	00777693          	andi	a3,a4,7
    800032c2:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800032c6:	41f7579b          	sraiw	a5,a4,0x1f
    800032ca:	01d7d79b          	srliw	a5,a5,0x1d
    800032ce:	9fb9                	addw	a5,a5,a4
    800032d0:	4037d79b          	sraiw	a5,a5,0x3
    800032d4:	00f90633          	add	a2,s2,a5
    800032d8:	05864603          	lbu	a2,88(a2)
    800032dc:	00c6f5b3          	and	a1,a3,a2
    800032e0:	d5a1                	beqz	a1,80003228 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032e2:	2705                	addiw	a4,a4,1
    800032e4:	2485                	addiw	s1,s1,1
    800032e6:	fd471ae3          	bne	a4,s4,800032ba <balloc+0xce>
    800032ea:	bf49                	j	8000327c <balloc+0x90>
    800032ec:	6906                	ld	s2,64(sp)
    800032ee:	79e2                	ld	s3,56(sp)
    800032f0:	7a42                	ld	s4,48(sp)
    800032f2:	7aa2                	ld	s5,40(sp)
    800032f4:	7b02                	ld	s6,32(sp)
    800032f6:	6be2                	ld	s7,24(sp)
    800032f8:	6c42                	ld	s8,16(sp)
    800032fa:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800032fc:	00004517          	auipc	a0,0x4
    80003300:	11c50513          	addi	a0,a0,284 # 80007418 <etext+0x418>
    80003304:	9f6fd0ef          	jal	800004fa <printf>
  return 0;
    80003308:	4481                	li	s1,0
    8000330a:	b79d                	j	80003270 <balloc+0x84>

000000008000330c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000330c:	7179                	addi	sp,sp,-48
    8000330e:	f406                	sd	ra,40(sp)
    80003310:	f022                	sd	s0,32(sp)
    80003312:	ec26                	sd	s1,24(sp)
    80003314:	e84a                	sd	s2,16(sp)
    80003316:	e44e                	sd	s3,8(sp)
    80003318:	1800                	addi	s0,sp,48
    8000331a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000331c:	47ad                	li	a5,11
    8000331e:	02b7e663          	bltu	a5,a1,8000334a <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80003322:	02059793          	slli	a5,a1,0x20
    80003326:	01e7d593          	srli	a1,a5,0x1e
    8000332a:	00b504b3          	add	s1,a0,a1
    8000332e:	0504a903          	lw	s2,80(s1)
    80003332:	06091a63          	bnez	s2,800033a6 <bmap+0x9a>
      addr = balloc(ip->dev);
    80003336:	4108                	lw	a0,0(a0)
    80003338:	eb5ff0ef          	jal	800031ec <balloc>
    8000333c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003340:	06090363          	beqz	s2,800033a6 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80003344:	0524a823          	sw	s2,80(s1)
    80003348:	a8b9                	j	800033a6 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000334a:	ff45849b          	addiw	s1,a1,-12
    8000334e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003352:	0ff00793          	li	a5,255
    80003356:	06e7ee63          	bltu	a5,a4,800033d2 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000335a:	08052903          	lw	s2,128(a0)
    8000335e:	00091d63          	bnez	s2,80003378 <bmap+0x6c>
      addr = balloc(ip->dev);
    80003362:	4108                	lw	a0,0(a0)
    80003364:	e89ff0ef          	jal	800031ec <balloc>
    80003368:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000336c:	02090d63          	beqz	s2,800033a6 <bmap+0x9a>
    80003370:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003372:	0929a023          	sw	s2,128(s3)
    80003376:	a011                	j	8000337a <bmap+0x6e>
    80003378:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000337a:	85ca                	mv	a1,s2
    8000337c:	0009a503          	lw	a0,0(s3)
    80003380:	c09ff0ef          	jal	80002f88 <bread>
    80003384:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003386:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000338a:	02049713          	slli	a4,s1,0x20
    8000338e:	01e75593          	srli	a1,a4,0x1e
    80003392:	00b784b3          	add	s1,a5,a1
    80003396:	0004a903          	lw	s2,0(s1)
    8000339a:	00090e63          	beqz	s2,800033b6 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000339e:	8552                	mv	a0,s4
    800033a0:	cf1ff0ef          	jal	80003090 <brelse>
    return addr;
    800033a4:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800033a6:	854a                	mv	a0,s2
    800033a8:	70a2                	ld	ra,40(sp)
    800033aa:	7402                	ld	s0,32(sp)
    800033ac:	64e2                	ld	s1,24(sp)
    800033ae:	6942                	ld	s2,16(sp)
    800033b0:	69a2                	ld	s3,8(sp)
    800033b2:	6145                	addi	sp,sp,48
    800033b4:	8082                	ret
      addr = balloc(ip->dev);
    800033b6:	0009a503          	lw	a0,0(s3)
    800033ba:	e33ff0ef          	jal	800031ec <balloc>
    800033be:	0005091b          	sext.w	s2,a0
      if(addr){
    800033c2:	fc090ee3          	beqz	s2,8000339e <bmap+0x92>
        a[bn] = addr;
    800033c6:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800033ca:	8552                	mv	a0,s4
    800033cc:	5f7000ef          	jal	800041c2 <log_write>
    800033d0:	b7f9                	j	8000339e <bmap+0x92>
    800033d2:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800033d4:	00004517          	auipc	a0,0x4
    800033d8:	05c50513          	addi	a0,a0,92 # 80007430 <etext+0x430>
    800033dc:	c04fd0ef          	jal	800007e0 <panic>

00000000800033e0 <iget>:
{
    800033e0:	7179                	addi	sp,sp,-48
    800033e2:	f406                	sd	ra,40(sp)
    800033e4:	f022                	sd	s0,32(sp)
    800033e6:	ec26                	sd	s1,24(sp)
    800033e8:	e84a                	sd	s2,16(sp)
    800033ea:	e44e                	sd	s3,8(sp)
    800033ec:	e052                	sd	s4,0(sp)
    800033ee:	1800                	addi	s0,sp,48
    800033f0:	89aa                	mv	s3,a0
    800033f2:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800033f4:	0012b517          	auipc	a0,0x12b
    800033f8:	10450513          	addi	a0,a0,260 # 8012e4f8 <itable>
    800033fc:	907fd0ef          	jal	80000d02 <acquire>
  empty = 0;
    80003400:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003402:	0012b497          	auipc	s1,0x12b
    80003406:	10e48493          	addi	s1,s1,270 # 8012e510 <itable+0x18>
    8000340a:	0012d697          	auipc	a3,0x12d
    8000340e:	b9668693          	addi	a3,a3,-1130 # 8012ffa0 <log>
    80003412:	a039                	j	80003420 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003414:	02090963          	beqz	s2,80003446 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003418:	08848493          	addi	s1,s1,136
    8000341c:	02d48863          	beq	s1,a3,8000344c <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003420:	449c                	lw	a5,8(s1)
    80003422:	fef059e3          	blez	a5,80003414 <iget+0x34>
    80003426:	4098                	lw	a4,0(s1)
    80003428:	ff3716e3          	bne	a4,s3,80003414 <iget+0x34>
    8000342c:	40d8                	lw	a4,4(s1)
    8000342e:	ff4713e3          	bne	a4,s4,80003414 <iget+0x34>
      ip->ref++;
    80003432:	2785                	addiw	a5,a5,1
    80003434:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003436:	0012b517          	auipc	a0,0x12b
    8000343a:	0c250513          	addi	a0,a0,194 # 8012e4f8 <itable>
    8000343e:	95dfd0ef          	jal	80000d9a <release>
      return ip;
    80003442:	8926                	mv	s2,s1
    80003444:	a02d                	j	8000346e <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003446:	fbe9                	bnez	a5,80003418 <iget+0x38>
      empty = ip;
    80003448:	8926                	mv	s2,s1
    8000344a:	b7f9                	j	80003418 <iget+0x38>
  if(empty == 0)
    8000344c:	02090a63          	beqz	s2,80003480 <iget+0xa0>
  ip->dev = dev;
    80003450:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003454:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003458:	4785                	li	a5,1
    8000345a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000345e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003462:	0012b517          	auipc	a0,0x12b
    80003466:	09650513          	addi	a0,a0,150 # 8012e4f8 <itable>
    8000346a:	931fd0ef          	jal	80000d9a <release>
}
    8000346e:	854a                	mv	a0,s2
    80003470:	70a2                	ld	ra,40(sp)
    80003472:	7402                	ld	s0,32(sp)
    80003474:	64e2                	ld	s1,24(sp)
    80003476:	6942                	ld	s2,16(sp)
    80003478:	69a2                	ld	s3,8(sp)
    8000347a:	6a02                	ld	s4,0(sp)
    8000347c:	6145                	addi	sp,sp,48
    8000347e:	8082                	ret
    panic("iget: no inodes");
    80003480:	00004517          	auipc	a0,0x4
    80003484:	fc850513          	addi	a0,a0,-56 # 80007448 <etext+0x448>
    80003488:	b58fd0ef          	jal	800007e0 <panic>

000000008000348c <iinit>:
{
    8000348c:	7179                	addi	sp,sp,-48
    8000348e:	f406                	sd	ra,40(sp)
    80003490:	f022                	sd	s0,32(sp)
    80003492:	ec26                	sd	s1,24(sp)
    80003494:	e84a                	sd	s2,16(sp)
    80003496:	e44e                	sd	s3,8(sp)
    80003498:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000349a:	00004597          	auipc	a1,0x4
    8000349e:	fbe58593          	addi	a1,a1,-66 # 80007458 <etext+0x458>
    800034a2:	0012b517          	auipc	a0,0x12b
    800034a6:	05650513          	addi	a0,a0,86 # 8012e4f8 <itable>
    800034aa:	fd8fd0ef          	jal	80000c82 <initlock>
  for(i = 0; i < NINODE; i++) {
    800034ae:	0012b497          	auipc	s1,0x12b
    800034b2:	07248493          	addi	s1,s1,114 # 8012e520 <itable+0x28>
    800034b6:	0012d997          	auipc	s3,0x12d
    800034ba:	afa98993          	addi	s3,s3,-1286 # 8012ffb0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800034be:	00004917          	auipc	s2,0x4
    800034c2:	fa290913          	addi	s2,s2,-94 # 80007460 <etext+0x460>
    800034c6:	85ca                	mv	a1,s2
    800034c8:	8526                	mv	a0,s1
    800034ca:	5bb000ef          	jal	80004284 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800034ce:	08848493          	addi	s1,s1,136
    800034d2:	ff349ae3          	bne	s1,s3,800034c6 <iinit+0x3a>
}
    800034d6:	70a2                	ld	ra,40(sp)
    800034d8:	7402                	ld	s0,32(sp)
    800034da:	64e2                	ld	s1,24(sp)
    800034dc:	6942                	ld	s2,16(sp)
    800034de:	69a2                	ld	s3,8(sp)
    800034e0:	6145                	addi	sp,sp,48
    800034e2:	8082                	ret

00000000800034e4 <ialloc>:
{
    800034e4:	7139                	addi	sp,sp,-64
    800034e6:	fc06                	sd	ra,56(sp)
    800034e8:	f822                	sd	s0,48(sp)
    800034ea:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800034ec:	0012b717          	auipc	a4,0x12b
    800034f0:	ff872703          	lw	a4,-8(a4) # 8012e4e4 <sb+0xc>
    800034f4:	4785                	li	a5,1
    800034f6:	06e7f063          	bgeu	a5,a4,80003556 <ialloc+0x72>
    800034fa:	f426                	sd	s1,40(sp)
    800034fc:	f04a                	sd	s2,32(sp)
    800034fe:	ec4e                	sd	s3,24(sp)
    80003500:	e852                	sd	s4,16(sp)
    80003502:	e456                	sd	s5,8(sp)
    80003504:	e05a                	sd	s6,0(sp)
    80003506:	8aaa                	mv	s5,a0
    80003508:	8b2e                	mv	s6,a1
    8000350a:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000350c:	0012ba17          	auipc	s4,0x12b
    80003510:	fcca0a13          	addi	s4,s4,-52 # 8012e4d8 <sb>
    80003514:	00495593          	srli	a1,s2,0x4
    80003518:	018a2783          	lw	a5,24(s4)
    8000351c:	9dbd                	addw	a1,a1,a5
    8000351e:	8556                	mv	a0,s5
    80003520:	a69ff0ef          	jal	80002f88 <bread>
    80003524:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003526:	05850993          	addi	s3,a0,88
    8000352a:	00f97793          	andi	a5,s2,15
    8000352e:	079a                	slli	a5,a5,0x6
    80003530:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003532:	00099783          	lh	a5,0(s3)
    80003536:	cb9d                	beqz	a5,8000356c <ialloc+0x88>
    brelse(bp);
    80003538:	b59ff0ef          	jal	80003090 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000353c:	0905                	addi	s2,s2,1
    8000353e:	00ca2703          	lw	a4,12(s4)
    80003542:	0009079b          	sext.w	a5,s2
    80003546:	fce7e7e3          	bltu	a5,a4,80003514 <ialloc+0x30>
    8000354a:	74a2                	ld	s1,40(sp)
    8000354c:	7902                	ld	s2,32(sp)
    8000354e:	69e2                	ld	s3,24(sp)
    80003550:	6a42                	ld	s4,16(sp)
    80003552:	6aa2                	ld	s5,8(sp)
    80003554:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003556:	00004517          	auipc	a0,0x4
    8000355a:	f1250513          	addi	a0,a0,-238 # 80007468 <etext+0x468>
    8000355e:	f9dfc0ef          	jal	800004fa <printf>
  return 0;
    80003562:	4501                	li	a0,0
}
    80003564:	70e2                	ld	ra,56(sp)
    80003566:	7442                	ld	s0,48(sp)
    80003568:	6121                	addi	sp,sp,64
    8000356a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000356c:	04000613          	li	a2,64
    80003570:	4581                	li	a1,0
    80003572:	854e                	mv	a0,s3
    80003574:	863fd0ef          	jal	80000dd6 <memset>
      dip->type = type;
    80003578:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000357c:	8526                	mv	a0,s1
    8000357e:	445000ef          	jal	800041c2 <log_write>
      brelse(bp);
    80003582:	8526                	mv	a0,s1
    80003584:	b0dff0ef          	jal	80003090 <brelse>
      return iget(dev, inum);
    80003588:	0009059b          	sext.w	a1,s2
    8000358c:	8556                	mv	a0,s5
    8000358e:	e53ff0ef          	jal	800033e0 <iget>
    80003592:	74a2                	ld	s1,40(sp)
    80003594:	7902                	ld	s2,32(sp)
    80003596:	69e2                	ld	s3,24(sp)
    80003598:	6a42                	ld	s4,16(sp)
    8000359a:	6aa2                	ld	s5,8(sp)
    8000359c:	6b02                	ld	s6,0(sp)
    8000359e:	b7d9                	j	80003564 <ialloc+0x80>

00000000800035a0 <iupdate>:
{
    800035a0:	1101                	addi	sp,sp,-32
    800035a2:	ec06                	sd	ra,24(sp)
    800035a4:	e822                	sd	s0,16(sp)
    800035a6:	e426                	sd	s1,8(sp)
    800035a8:	e04a                	sd	s2,0(sp)
    800035aa:	1000                	addi	s0,sp,32
    800035ac:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800035ae:	415c                	lw	a5,4(a0)
    800035b0:	0047d79b          	srliw	a5,a5,0x4
    800035b4:	0012b597          	auipc	a1,0x12b
    800035b8:	f3c5a583          	lw	a1,-196(a1) # 8012e4f0 <sb+0x18>
    800035bc:	9dbd                	addw	a1,a1,a5
    800035be:	4108                	lw	a0,0(a0)
    800035c0:	9c9ff0ef          	jal	80002f88 <bread>
    800035c4:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800035c6:	05850793          	addi	a5,a0,88
    800035ca:	40d8                	lw	a4,4(s1)
    800035cc:	8b3d                	andi	a4,a4,15
    800035ce:	071a                	slli	a4,a4,0x6
    800035d0:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800035d2:	04449703          	lh	a4,68(s1)
    800035d6:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800035da:	04649703          	lh	a4,70(s1)
    800035de:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800035e2:	04849703          	lh	a4,72(s1)
    800035e6:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800035ea:	04a49703          	lh	a4,74(s1)
    800035ee:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800035f2:	44f8                	lw	a4,76(s1)
    800035f4:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800035f6:	03400613          	li	a2,52
    800035fa:	05048593          	addi	a1,s1,80
    800035fe:	00c78513          	addi	a0,a5,12
    80003602:	831fd0ef          	jal	80000e32 <memmove>
  log_write(bp);
    80003606:	854a                	mv	a0,s2
    80003608:	3bb000ef          	jal	800041c2 <log_write>
  brelse(bp);
    8000360c:	854a                	mv	a0,s2
    8000360e:	a83ff0ef          	jal	80003090 <brelse>
}
    80003612:	60e2                	ld	ra,24(sp)
    80003614:	6442                	ld	s0,16(sp)
    80003616:	64a2                	ld	s1,8(sp)
    80003618:	6902                	ld	s2,0(sp)
    8000361a:	6105                	addi	sp,sp,32
    8000361c:	8082                	ret

000000008000361e <idup>:
{
    8000361e:	1101                	addi	sp,sp,-32
    80003620:	ec06                	sd	ra,24(sp)
    80003622:	e822                	sd	s0,16(sp)
    80003624:	e426                	sd	s1,8(sp)
    80003626:	1000                	addi	s0,sp,32
    80003628:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000362a:	0012b517          	auipc	a0,0x12b
    8000362e:	ece50513          	addi	a0,a0,-306 # 8012e4f8 <itable>
    80003632:	ed0fd0ef          	jal	80000d02 <acquire>
  ip->ref++;
    80003636:	449c                	lw	a5,8(s1)
    80003638:	2785                	addiw	a5,a5,1
    8000363a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000363c:	0012b517          	auipc	a0,0x12b
    80003640:	ebc50513          	addi	a0,a0,-324 # 8012e4f8 <itable>
    80003644:	f56fd0ef          	jal	80000d9a <release>
}
    80003648:	8526                	mv	a0,s1
    8000364a:	60e2                	ld	ra,24(sp)
    8000364c:	6442                	ld	s0,16(sp)
    8000364e:	64a2                	ld	s1,8(sp)
    80003650:	6105                	addi	sp,sp,32
    80003652:	8082                	ret

0000000080003654 <ilock>:
{
    80003654:	1101                	addi	sp,sp,-32
    80003656:	ec06                	sd	ra,24(sp)
    80003658:	e822                	sd	s0,16(sp)
    8000365a:	e426                	sd	s1,8(sp)
    8000365c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000365e:	cd19                	beqz	a0,8000367c <ilock+0x28>
    80003660:	84aa                	mv	s1,a0
    80003662:	451c                	lw	a5,8(a0)
    80003664:	00f05c63          	blez	a5,8000367c <ilock+0x28>
  acquiresleep(&ip->lock);
    80003668:	0541                	addi	a0,a0,16
    8000366a:	451000ef          	jal	800042ba <acquiresleep>
  if(ip->valid == 0){
    8000366e:	40bc                	lw	a5,64(s1)
    80003670:	cf89                	beqz	a5,8000368a <ilock+0x36>
}
    80003672:	60e2                	ld	ra,24(sp)
    80003674:	6442                	ld	s0,16(sp)
    80003676:	64a2                	ld	s1,8(sp)
    80003678:	6105                	addi	sp,sp,32
    8000367a:	8082                	ret
    8000367c:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000367e:	00004517          	auipc	a0,0x4
    80003682:	e0250513          	addi	a0,a0,-510 # 80007480 <etext+0x480>
    80003686:	95afd0ef          	jal	800007e0 <panic>
    8000368a:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000368c:	40dc                	lw	a5,4(s1)
    8000368e:	0047d79b          	srliw	a5,a5,0x4
    80003692:	0012b597          	auipc	a1,0x12b
    80003696:	e5e5a583          	lw	a1,-418(a1) # 8012e4f0 <sb+0x18>
    8000369a:	9dbd                	addw	a1,a1,a5
    8000369c:	4088                	lw	a0,0(s1)
    8000369e:	8ebff0ef          	jal	80002f88 <bread>
    800036a2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036a4:	05850593          	addi	a1,a0,88
    800036a8:	40dc                	lw	a5,4(s1)
    800036aa:	8bbd                	andi	a5,a5,15
    800036ac:	079a                	slli	a5,a5,0x6
    800036ae:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800036b0:	00059783          	lh	a5,0(a1)
    800036b4:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800036b8:	00259783          	lh	a5,2(a1)
    800036bc:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800036c0:	00459783          	lh	a5,4(a1)
    800036c4:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800036c8:	00659783          	lh	a5,6(a1)
    800036cc:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800036d0:	459c                	lw	a5,8(a1)
    800036d2:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800036d4:	03400613          	li	a2,52
    800036d8:	05b1                	addi	a1,a1,12
    800036da:	05048513          	addi	a0,s1,80
    800036de:	f54fd0ef          	jal	80000e32 <memmove>
    brelse(bp);
    800036e2:	854a                	mv	a0,s2
    800036e4:	9adff0ef          	jal	80003090 <brelse>
    ip->valid = 1;
    800036e8:	4785                	li	a5,1
    800036ea:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800036ec:	04449783          	lh	a5,68(s1)
    800036f0:	c399                	beqz	a5,800036f6 <ilock+0xa2>
    800036f2:	6902                	ld	s2,0(sp)
    800036f4:	bfbd                	j	80003672 <ilock+0x1e>
      panic("ilock: no type");
    800036f6:	00004517          	auipc	a0,0x4
    800036fa:	d9250513          	addi	a0,a0,-622 # 80007488 <etext+0x488>
    800036fe:	8e2fd0ef          	jal	800007e0 <panic>

0000000080003702 <iunlock>:
{
    80003702:	1101                	addi	sp,sp,-32
    80003704:	ec06                	sd	ra,24(sp)
    80003706:	e822                	sd	s0,16(sp)
    80003708:	e426                	sd	s1,8(sp)
    8000370a:	e04a                	sd	s2,0(sp)
    8000370c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000370e:	c505                	beqz	a0,80003736 <iunlock+0x34>
    80003710:	84aa                	mv	s1,a0
    80003712:	01050913          	addi	s2,a0,16
    80003716:	854a                	mv	a0,s2
    80003718:	421000ef          	jal	80004338 <holdingsleep>
    8000371c:	cd09                	beqz	a0,80003736 <iunlock+0x34>
    8000371e:	449c                	lw	a5,8(s1)
    80003720:	00f05b63          	blez	a5,80003736 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003724:	854a                	mv	a0,s2
    80003726:	3db000ef          	jal	80004300 <releasesleep>
}
    8000372a:	60e2                	ld	ra,24(sp)
    8000372c:	6442                	ld	s0,16(sp)
    8000372e:	64a2                	ld	s1,8(sp)
    80003730:	6902                	ld	s2,0(sp)
    80003732:	6105                	addi	sp,sp,32
    80003734:	8082                	ret
    panic("iunlock");
    80003736:	00004517          	auipc	a0,0x4
    8000373a:	d6250513          	addi	a0,a0,-670 # 80007498 <etext+0x498>
    8000373e:	8a2fd0ef          	jal	800007e0 <panic>

0000000080003742 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003742:	7179                	addi	sp,sp,-48
    80003744:	f406                	sd	ra,40(sp)
    80003746:	f022                	sd	s0,32(sp)
    80003748:	ec26                	sd	s1,24(sp)
    8000374a:	e84a                	sd	s2,16(sp)
    8000374c:	e44e                	sd	s3,8(sp)
    8000374e:	1800                	addi	s0,sp,48
    80003750:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003752:	05050493          	addi	s1,a0,80
    80003756:	08050913          	addi	s2,a0,128
    8000375a:	a021                	j	80003762 <itrunc+0x20>
    8000375c:	0491                	addi	s1,s1,4
    8000375e:	01248b63          	beq	s1,s2,80003774 <itrunc+0x32>
    if(ip->addrs[i]){
    80003762:	408c                	lw	a1,0(s1)
    80003764:	dde5                	beqz	a1,8000375c <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003766:	0009a503          	lw	a0,0(s3)
    8000376a:	a17ff0ef          	jal	80003180 <bfree>
      ip->addrs[i] = 0;
    8000376e:	0004a023          	sw	zero,0(s1)
    80003772:	b7ed                	j	8000375c <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003774:	0809a583          	lw	a1,128(s3)
    80003778:	ed89                	bnez	a1,80003792 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000377a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000377e:	854e                	mv	a0,s3
    80003780:	e21ff0ef          	jal	800035a0 <iupdate>
}
    80003784:	70a2                	ld	ra,40(sp)
    80003786:	7402                	ld	s0,32(sp)
    80003788:	64e2                	ld	s1,24(sp)
    8000378a:	6942                	ld	s2,16(sp)
    8000378c:	69a2                	ld	s3,8(sp)
    8000378e:	6145                	addi	sp,sp,48
    80003790:	8082                	ret
    80003792:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003794:	0009a503          	lw	a0,0(s3)
    80003798:	ff0ff0ef          	jal	80002f88 <bread>
    8000379c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000379e:	05850493          	addi	s1,a0,88
    800037a2:	45850913          	addi	s2,a0,1112
    800037a6:	a021                	j	800037ae <itrunc+0x6c>
    800037a8:	0491                	addi	s1,s1,4
    800037aa:	01248963          	beq	s1,s2,800037bc <itrunc+0x7a>
      if(a[j])
    800037ae:	408c                	lw	a1,0(s1)
    800037b0:	dde5                	beqz	a1,800037a8 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800037b2:	0009a503          	lw	a0,0(s3)
    800037b6:	9cbff0ef          	jal	80003180 <bfree>
    800037ba:	b7fd                	j	800037a8 <itrunc+0x66>
    brelse(bp);
    800037bc:	8552                	mv	a0,s4
    800037be:	8d3ff0ef          	jal	80003090 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800037c2:	0809a583          	lw	a1,128(s3)
    800037c6:	0009a503          	lw	a0,0(s3)
    800037ca:	9b7ff0ef          	jal	80003180 <bfree>
    ip->addrs[NDIRECT] = 0;
    800037ce:	0809a023          	sw	zero,128(s3)
    800037d2:	6a02                	ld	s4,0(sp)
    800037d4:	b75d                	j	8000377a <itrunc+0x38>

00000000800037d6 <iput>:
{
    800037d6:	1101                	addi	sp,sp,-32
    800037d8:	ec06                	sd	ra,24(sp)
    800037da:	e822                	sd	s0,16(sp)
    800037dc:	e426                	sd	s1,8(sp)
    800037de:	1000                	addi	s0,sp,32
    800037e0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800037e2:	0012b517          	auipc	a0,0x12b
    800037e6:	d1650513          	addi	a0,a0,-746 # 8012e4f8 <itable>
    800037ea:	d18fd0ef          	jal	80000d02 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800037ee:	4498                	lw	a4,8(s1)
    800037f0:	4785                	li	a5,1
    800037f2:	02f70063          	beq	a4,a5,80003812 <iput+0x3c>
  ip->ref--;
    800037f6:	449c                	lw	a5,8(s1)
    800037f8:	37fd                	addiw	a5,a5,-1
    800037fa:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800037fc:	0012b517          	auipc	a0,0x12b
    80003800:	cfc50513          	addi	a0,a0,-772 # 8012e4f8 <itable>
    80003804:	d96fd0ef          	jal	80000d9a <release>
}
    80003808:	60e2                	ld	ra,24(sp)
    8000380a:	6442                	ld	s0,16(sp)
    8000380c:	64a2                	ld	s1,8(sp)
    8000380e:	6105                	addi	sp,sp,32
    80003810:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003812:	40bc                	lw	a5,64(s1)
    80003814:	d3ed                	beqz	a5,800037f6 <iput+0x20>
    80003816:	04a49783          	lh	a5,74(s1)
    8000381a:	fff1                	bnez	a5,800037f6 <iput+0x20>
    8000381c:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    8000381e:	01048913          	addi	s2,s1,16
    80003822:	854a                	mv	a0,s2
    80003824:	297000ef          	jal	800042ba <acquiresleep>
    release(&itable.lock);
    80003828:	0012b517          	auipc	a0,0x12b
    8000382c:	cd050513          	addi	a0,a0,-816 # 8012e4f8 <itable>
    80003830:	d6afd0ef          	jal	80000d9a <release>
    itrunc(ip);
    80003834:	8526                	mv	a0,s1
    80003836:	f0dff0ef          	jal	80003742 <itrunc>
    ip->type = 0;
    8000383a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000383e:	8526                	mv	a0,s1
    80003840:	d61ff0ef          	jal	800035a0 <iupdate>
    ip->valid = 0;
    80003844:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003848:	854a                	mv	a0,s2
    8000384a:	2b7000ef          	jal	80004300 <releasesleep>
    acquire(&itable.lock);
    8000384e:	0012b517          	auipc	a0,0x12b
    80003852:	caa50513          	addi	a0,a0,-854 # 8012e4f8 <itable>
    80003856:	cacfd0ef          	jal	80000d02 <acquire>
    8000385a:	6902                	ld	s2,0(sp)
    8000385c:	bf69                	j	800037f6 <iput+0x20>

000000008000385e <iunlockput>:
{
    8000385e:	1101                	addi	sp,sp,-32
    80003860:	ec06                	sd	ra,24(sp)
    80003862:	e822                	sd	s0,16(sp)
    80003864:	e426                	sd	s1,8(sp)
    80003866:	1000                	addi	s0,sp,32
    80003868:	84aa                	mv	s1,a0
  iunlock(ip);
    8000386a:	e99ff0ef          	jal	80003702 <iunlock>
  iput(ip);
    8000386e:	8526                	mv	a0,s1
    80003870:	f67ff0ef          	jal	800037d6 <iput>
}
    80003874:	60e2                	ld	ra,24(sp)
    80003876:	6442                	ld	s0,16(sp)
    80003878:	64a2                	ld	s1,8(sp)
    8000387a:	6105                	addi	sp,sp,32
    8000387c:	8082                	ret

000000008000387e <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000387e:	0012b717          	auipc	a4,0x12b
    80003882:	c6672703          	lw	a4,-922(a4) # 8012e4e4 <sb+0xc>
    80003886:	4785                	li	a5,1
    80003888:	0ae7ff63          	bgeu	a5,a4,80003946 <ireclaim+0xc8>
{
    8000388c:	7139                	addi	sp,sp,-64
    8000388e:	fc06                	sd	ra,56(sp)
    80003890:	f822                	sd	s0,48(sp)
    80003892:	f426                	sd	s1,40(sp)
    80003894:	f04a                	sd	s2,32(sp)
    80003896:	ec4e                	sd	s3,24(sp)
    80003898:	e852                	sd	s4,16(sp)
    8000389a:	e456                	sd	s5,8(sp)
    8000389c:	e05a                	sd	s6,0(sp)
    8000389e:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800038a0:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800038a2:	00050a1b          	sext.w	s4,a0
    800038a6:	0012ba97          	auipc	s5,0x12b
    800038aa:	c32a8a93          	addi	s5,s5,-974 # 8012e4d8 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    800038ae:	00004b17          	auipc	s6,0x4
    800038b2:	bf2b0b13          	addi	s6,s6,-1038 # 800074a0 <etext+0x4a0>
    800038b6:	a099                	j	800038fc <ireclaim+0x7e>
    800038b8:	85ce                	mv	a1,s3
    800038ba:	855a                	mv	a0,s6
    800038bc:	c3ffc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    800038c0:	85ce                	mv	a1,s3
    800038c2:	8552                	mv	a0,s4
    800038c4:	b1dff0ef          	jal	800033e0 <iget>
    800038c8:	89aa                	mv	s3,a0
    brelse(bp);
    800038ca:	854a                	mv	a0,s2
    800038cc:	fc4ff0ef          	jal	80003090 <brelse>
    if (ip) {
    800038d0:	00098f63          	beqz	s3,800038ee <ireclaim+0x70>
      begin_op();
    800038d4:	76a000ef          	jal	8000403e <begin_op>
      ilock(ip);
    800038d8:	854e                	mv	a0,s3
    800038da:	d7bff0ef          	jal	80003654 <ilock>
      iunlock(ip);
    800038de:	854e                	mv	a0,s3
    800038e0:	e23ff0ef          	jal	80003702 <iunlock>
      iput(ip);
    800038e4:	854e                	mv	a0,s3
    800038e6:	ef1ff0ef          	jal	800037d6 <iput>
      end_op();
    800038ea:	7be000ef          	jal	800040a8 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800038ee:	0485                	addi	s1,s1,1
    800038f0:	00caa703          	lw	a4,12(s5)
    800038f4:	0004879b          	sext.w	a5,s1
    800038f8:	02e7fd63          	bgeu	a5,a4,80003932 <ireclaim+0xb4>
    800038fc:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003900:	0044d593          	srli	a1,s1,0x4
    80003904:	018aa783          	lw	a5,24(s5)
    80003908:	9dbd                	addw	a1,a1,a5
    8000390a:	8552                	mv	a0,s4
    8000390c:	e7cff0ef          	jal	80002f88 <bread>
    80003910:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003912:	05850793          	addi	a5,a0,88
    80003916:	00f9f713          	andi	a4,s3,15
    8000391a:	071a                	slli	a4,a4,0x6
    8000391c:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    8000391e:	00079703          	lh	a4,0(a5)
    80003922:	c701                	beqz	a4,8000392a <ireclaim+0xac>
    80003924:	00679783          	lh	a5,6(a5)
    80003928:	dbc1                	beqz	a5,800038b8 <ireclaim+0x3a>
    brelse(bp);
    8000392a:	854a                	mv	a0,s2
    8000392c:	f64ff0ef          	jal	80003090 <brelse>
    if (ip) {
    80003930:	bf7d                	j	800038ee <ireclaim+0x70>
}
    80003932:	70e2                	ld	ra,56(sp)
    80003934:	7442                	ld	s0,48(sp)
    80003936:	74a2                	ld	s1,40(sp)
    80003938:	7902                	ld	s2,32(sp)
    8000393a:	69e2                	ld	s3,24(sp)
    8000393c:	6a42                	ld	s4,16(sp)
    8000393e:	6aa2                	ld	s5,8(sp)
    80003940:	6b02                	ld	s6,0(sp)
    80003942:	6121                	addi	sp,sp,64
    80003944:	8082                	ret
    80003946:	8082                	ret

0000000080003948 <fsinit>:
fsinit(int dev) {
    80003948:	7179                	addi	sp,sp,-48
    8000394a:	f406                	sd	ra,40(sp)
    8000394c:	f022                	sd	s0,32(sp)
    8000394e:	ec26                	sd	s1,24(sp)
    80003950:	e84a                	sd	s2,16(sp)
    80003952:	e44e                	sd	s3,8(sp)
    80003954:	1800                	addi	s0,sp,48
    80003956:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80003958:	4585                	li	a1,1
    8000395a:	e2eff0ef          	jal	80002f88 <bread>
    8000395e:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003960:	0012b997          	auipc	s3,0x12b
    80003964:	b7898993          	addi	s3,s3,-1160 # 8012e4d8 <sb>
    80003968:	02000613          	li	a2,32
    8000396c:	05850593          	addi	a1,a0,88
    80003970:	854e                	mv	a0,s3
    80003972:	cc0fd0ef          	jal	80000e32 <memmove>
  brelse(bp);
    80003976:	854a                	mv	a0,s2
    80003978:	f18ff0ef          	jal	80003090 <brelse>
  if(sb.magic != FSMAGIC)
    8000397c:	0009a703          	lw	a4,0(s3)
    80003980:	102037b7          	lui	a5,0x10203
    80003984:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003988:	02f71363          	bne	a4,a5,800039ae <fsinit+0x66>
  initlog(dev, &sb);
    8000398c:	0012b597          	auipc	a1,0x12b
    80003990:	b4c58593          	addi	a1,a1,-1204 # 8012e4d8 <sb>
    80003994:	8526                	mv	a0,s1
    80003996:	62a000ef          	jal	80003fc0 <initlog>
  ireclaim(dev);
    8000399a:	8526                	mv	a0,s1
    8000399c:	ee3ff0ef          	jal	8000387e <ireclaim>
}
    800039a0:	70a2                	ld	ra,40(sp)
    800039a2:	7402                	ld	s0,32(sp)
    800039a4:	64e2                	ld	s1,24(sp)
    800039a6:	6942                	ld	s2,16(sp)
    800039a8:	69a2                	ld	s3,8(sp)
    800039aa:	6145                	addi	sp,sp,48
    800039ac:	8082                	ret
    panic("invalid file system");
    800039ae:	00004517          	auipc	a0,0x4
    800039b2:	b1250513          	addi	a0,a0,-1262 # 800074c0 <etext+0x4c0>
    800039b6:	e2bfc0ef          	jal	800007e0 <panic>

00000000800039ba <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800039ba:	1141                	addi	sp,sp,-16
    800039bc:	e422                	sd	s0,8(sp)
    800039be:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800039c0:	411c                	lw	a5,0(a0)
    800039c2:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800039c4:	415c                	lw	a5,4(a0)
    800039c6:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800039c8:	04451783          	lh	a5,68(a0)
    800039cc:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800039d0:	04a51783          	lh	a5,74(a0)
    800039d4:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800039d8:	04c56783          	lwu	a5,76(a0)
    800039dc:	e99c                	sd	a5,16(a1)
}
    800039de:	6422                	ld	s0,8(sp)
    800039e0:	0141                	addi	sp,sp,16
    800039e2:	8082                	ret

00000000800039e4 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800039e4:	457c                	lw	a5,76(a0)
    800039e6:	0ed7eb63          	bltu	a5,a3,80003adc <readi+0xf8>
{
    800039ea:	7159                	addi	sp,sp,-112
    800039ec:	f486                	sd	ra,104(sp)
    800039ee:	f0a2                	sd	s0,96(sp)
    800039f0:	eca6                	sd	s1,88(sp)
    800039f2:	e0d2                	sd	s4,64(sp)
    800039f4:	fc56                	sd	s5,56(sp)
    800039f6:	f85a                	sd	s6,48(sp)
    800039f8:	f45e                	sd	s7,40(sp)
    800039fa:	1880                	addi	s0,sp,112
    800039fc:	8b2a                	mv	s6,a0
    800039fe:	8bae                	mv	s7,a1
    80003a00:	8a32                	mv	s4,a2
    80003a02:	84b6                	mv	s1,a3
    80003a04:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003a06:	9f35                	addw	a4,a4,a3
    return 0;
    80003a08:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003a0a:	0cd76063          	bltu	a4,a3,80003aca <readi+0xe6>
    80003a0e:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003a10:	00e7f463          	bgeu	a5,a4,80003a18 <readi+0x34>
    n = ip->size - off;
    80003a14:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a18:	080a8f63          	beqz	s5,80003ab6 <readi+0xd2>
    80003a1c:	e8ca                	sd	s2,80(sp)
    80003a1e:	f062                	sd	s8,32(sp)
    80003a20:	ec66                	sd	s9,24(sp)
    80003a22:	e86a                	sd	s10,16(sp)
    80003a24:	e46e                	sd	s11,8(sp)
    80003a26:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a28:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003a2c:	5c7d                	li	s8,-1
    80003a2e:	a80d                	j	80003a60 <readi+0x7c>
    80003a30:	020d1d93          	slli	s11,s10,0x20
    80003a34:	020ddd93          	srli	s11,s11,0x20
    80003a38:	05890613          	addi	a2,s2,88
    80003a3c:	86ee                	mv	a3,s11
    80003a3e:	963a                	add	a2,a2,a4
    80003a40:	85d2                	mv	a1,s4
    80003a42:	855e                	mv	a0,s7
    80003a44:	a95fe0ef          	jal	800024d8 <either_copyout>
    80003a48:	05850763          	beq	a0,s8,80003a96 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003a4c:	854a                	mv	a0,s2
    80003a4e:	e42ff0ef          	jal	80003090 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a52:	013d09bb          	addw	s3,s10,s3
    80003a56:	009d04bb          	addw	s1,s10,s1
    80003a5a:	9a6e                	add	s4,s4,s11
    80003a5c:	0559f763          	bgeu	s3,s5,80003aaa <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80003a60:	00a4d59b          	srliw	a1,s1,0xa
    80003a64:	855a                	mv	a0,s6
    80003a66:	8a7ff0ef          	jal	8000330c <bmap>
    80003a6a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003a6e:	c5b1                	beqz	a1,80003aba <readi+0xd6>
    bp = bread(ip->dev, addr);
    80003a70:	000b2503          	lw	a0,0(s6)
    80003a74:	d14ff0ef          	jal	80002f88 <bread>
    80003a78:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a7a:	3ff4f713          	andi	a4,s1,1023
    80003a7e:	40ec87bb          	subw	a5,s9,a4
    80003a82:	413a86bb          	subw	a3,s5,s3
    80003a86:	8d3e                	mv	s10,a5
    80003a88:	2781                	sext.w	a5,a5
    80003a8a:	0006861b          	sext.w	a2,a3
    80003a8e:	faf671e3          	bgeu	a2,a5,80003a30 <readi+0x4c>
    80003a92:	8d36                	mv	s10,a3
    80003a94:	bf71                	j	80003a30 <readi+0x4c>
      brelse(bp);
    80003a96:	854a                	mv	a0,s2
    80003a98:	df8ff0ef          	jal	80003090 <brelse>
      tot = -1;
    80003a9c:	59fd                	li	s3,-1
      break;
    80003a9e:	6946                	ld	s2,80(sp)
    80003aa0:	7c02                	ld	s8,32(sp)
    80003aa2:	6ce2                	ld	s9,24(sp)
    80003aa4:	6d42                	ld	s10,16(sp)
    80003aa6:	6da2                	ld	s11,8(sp)
    80003aa8:	a831                	j	80003ac4 <readi+0xe0>
    80003aaa:	6946                	ld	s2,80(sp)
    80003aac:	7c02                	ld	s8,32(sp)
    80003aae:	6ce2                	ld	s9,24(sp)
    80003ab0:	6d42                	ld	s10,16(sp)
    80003ab2:	6da2                	ld	s11,8(sp)
    80003ab4:	a801                	j	80003ac4 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ab6:	89d6                	mv	s3,s5
    80003ab8:	a031                	j	80003ac4 <readi+0xe0>
    80003aba:	6946                	ld	s2,80(sp)
    80003abc:	7c02                	ld	s8,32(sp)
    80003abe:	6ce2                	ld	s9,24(sp)
    80003ac0:	6d42                	ld	s10,16(sp)
    80003ac2:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003ac4:	0009851b          	sext.w	a0,s3
    80003ac8:	69a6                	ld	s3,72(sp)
}
    80003aca:	70a6                	ld	ra,104(sp)
    80003acc:	7406                	ld	s0,96(sp)
    80003ace:	64e6                	ld	s1,88(sp)
    80003ad0:	6a06                	ld	s4,64(sp)
    80003ad2:	7ae2                	ld	s5,56(sp)
    80003ad4:	7b42                	ld	s6,48(sp)
    80003ad6:	7ba2                	ld	s7,40(sp)
    80003ad8:	6165                	addi	sp,sp,112
    80003ada:	8082                	ret
    return 0;
    80003adc:	4501                	li	a0,0
}
    80003ade:	8082                	ret

0000000080003ae0 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ae0:	457c                	lw	a5,76(a0)
    80003ae2:	10d7e063          	bltu	a5,a3,80003be2 <writei+0x102>
{
    80003ae6:	7159                	addi	sp,sp,-112
    80003ae8:	f486                	sd	ra,104(sp)
    80003aea:	f0a2                	sd	s0,96(sp)
    80003aec:	e8ca                	sd	s2,80(sp)
    80003aee:	e0d2                	sd	s4,64(sp)
    80003af0:	fc56                	sd	s5,56(sp)
    80003af2:	f85a                	sd	s6,48(sp)
    80003af4:	f45e                	sd	s7,40(sp)
    80003af6:	1880                	addi	s0,sp,112
    80003af8:	8aaa                	mv	s5,a0
    80003afa:	8bae                	mv	s7,a1
    80003afc:	8a32                	mv	s4,a2
    80003afe:	8936                	mv	s2,a3
    80003b00:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b02:	00e687bb          	addw	a5,a3,a4
    80003b06:	0ed7e063          	bltu	a5,a3,80003be6 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003b0a:	00043737          	lui	a4,0x43
    80003b0e:	0cf76e63          	bltu	a4,a5,80003bea <writei+0x10a>
    80003b12:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b14:	0a0b0f63          	beqz	s6,80003bd2 <writei+0xf2>
    80003b18:	eca6                	sd	s1,88(sp)
    80003b1a:	f062                	sd	s8,32(sp)
    80003b1c:	ec66                	sd	s9,24(sp)
    80003b1e:	e86a                	sd	s10,16(sp)
    80003b20:	e46e                	sd	s11,8(sp)
    80003b22:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b24:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b28:	5c7d                	li	s8,-1
    80003b2a:	a825                	j	80003b62 <writei+0x82>
    80003b2c:	020d1d93          	slli	s11,s10,0x20
    80003b30:	020ddd93          	srli	s11,s11,0x20
    80003b34:	05848513          	addi	a0,s1,88
    80003b38:	86ee                	mv	a3,s11
    80003b3a:	8652                	mv	a2,s4
    80003b3c:	85de                	mv	a1,s7
    80003b3e:	953a                	add	a0,a0,a4
    80003b40:	9e3fe0ef          	jal	80002522 <either_copyin>
    80003b44:	05850a63          	beq	a0,s8,80003b98 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003b48:	8526                	mv	a0,s1
    80003b4a:	678000ef          	jal	800041c2 <log_write>
    brelse(bp);
    80003b4e:	8526                	mv	a0,s1
    80003b50:	d40ff0ef          	jal	80003090 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b54:	013d09bb          	addw	s3,s10,s3
    80003b58:	012d093b          	addw	s2,s10,s2
    80003b5c:	9a6e                	add	s4,s4,s11
    80003b5e:	0569f063          	bgeu	s3,s6,80003b9e <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003b62:	00a9559b          	srliw	a1,s2,0xa
    80003b66:	8556                	mv	a0,s5
    80003b68:	fa4ff0ef          	jal	8000330c <bmap>
    80003b6c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003b70:	c59d                	beqz	a1,80003b9e <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003b72:	000aa503          	lw	a0,0(s5)
    80003b76:	c12ff0ef          	jal	80002f88 <bread>
    80003b7a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b7c:	3ff97713          	andi	a4,s2,1023
    80003b80:	40ec87bb          	subw	a5,s9,a4
    80003b84:	413b06bb          	subw	a3,s6,s3
    80003b88:	8d3e                	mv	s10,a5
    80003b8a:	2781                	sext.w	a5,a5
    80003b8c:	0006861b          	sext.w	a2,a3
    80003b90:	f8f67ee3          	bgeu	a2,a5,80003b2c <writei+0x4c>
    80003b94:	8d36                	mv	s10,a3
    80003b96:	bf59                	j	80003b2c <writei+0x4c>
      brelse(bp);
    80003b98:	8526                	mv	a0,s1
    80003b9a:	cf6ff0ef          	jal	80003090 <brelse>
  }

  if(off > ip->size)
    80003b9e:	04caa783          	lw	a5,76(s5)
    80003ba2:	0327fa63          	bgeu	a5,s2,80003bd6 <writei+0xf6>
    ip->size = off;
    80003ba6:	052aa623          	sw	s2,76(s5)
    80003baa:	64e6                	ld	s1,88(sp)
    80003bac:	7c02                	ld	s8,32(sp)
    80003bae:	6ce2                	ld	s9,24(sp)
    80003bb0:	6d42                	ld	s10,16(sp)
    80003bb2:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003bb4:	8556                	mv	a0,s5
    80003bb6:	9ebff0ef          	jal	800035a0 <iupdate>

  return tot;
    80003bba:	0009851b          	sext.w	a0,s3
    80003bbe:	69a6                	ld	s3,72(sp)
}
    80003bc0:	70a6                	ld	ra,104(sp)
    80003bc2:	7406                	ld	s0,96(sp)
    80003bc4:	6946                	ld	s2,80(sp)
    80003bc6:	6a06                	ld	s4,64(sp)
    80003bc8:	7ae2                	ld	s5,56(sp)
    80003bca:	7b42                	ld	s6,48(sp)
    80003bcc:	7ba2                	ld	s7,40(sp)
    80003bce:	6165                	addi	sp,sp,112
    80003bd0:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bd2:	89da                	mv	s3,s6
    80003bd4:	b7c5                	j	80003bb4 <writei+0xd4>
    80003bd6:	64e6                	ld	s1,88(sp)
    80003bd8:	7c02                	ld	s8,32(sp)
    80003bda:	6ce2                	ld	s9,24(sp)
    80003bdc:	6d42                	ld	s10,16(sp)
    80003bde:	6da2                	ld	s11,8(sp)
    80003be0:	bfd1                	j	80003bb4 <writei+0xd4>
    return -1;
    80003be2:	557d                	li	a0,-1
}
    80003be4:	8082                	ret
    return -1;
    80003be6:	557d                	li	a0,-1
    80003be8:	bfe1                	j	80003bc0 <writei+0xe0>
    return -1;
    80003bea:	557d                	li	a0,-1
    80003bec:	bfd1                	j	80003bc0 <writei+0xe0>

0000000080003bee <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003bee:	1141                	addi	sp,sp,-16
    80003bf0:	e406                	sd	ra,8(sp)
    80003bf2:	e022                	sd	s0,0(sp)
    80003bf4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003bf6:	4639                	li	a2,14
    80003bf8:	aaafd0ef          	jal	80000ea2 <strncmp>
}
    80003bfc:	60a2                	ld	ra,8(sp)
    80003bfe:	6402                	ld	s0,0(sp)
    80003c00:	0141                	addi	sp,sp,16
    80003c02:	8082                	ret

0000000080003c04 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003c04:	7139                	addi	sp,sp,-64
    80003c06:	fc06                	sd	ra,56(sp)
    80003c08:	f822                	sd	s0,48(sp)
    80003c0a:	f426                	sd	s1,40(sp)
    80003c0c:	f04a                	sd	s2,32(sp)
    80003c0e:	ec4e                	sd	s3,24(sp)
    80003c10:	e852                	sd	s4,16(sp)
    80003c12:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c14:	04451703          	lh	a4,68(a0)
    80003c18:	4785                	li	a5,1
    80003c1a:	00f71a63          	bne	a4,a5,80003c2e <dirlookup+0x2a>
    80003c1e:	892a                	mv	s2,a0
    80003c20:	89ae                	mv	s3,a1
    80003c22:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c24:	457c                	lw	a5,76(a0)
    80003c26:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c28:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c2a:	e39d                	bnez	a5,80003c50 <dirlookup+0x4c>
    80003c2c:	a095                	j	80003c90 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003c2e:	00004517          	auipc	a0,0x4
    80003c32:	8aa50513          	addi	a0,a0,-1878 # 800074d8 <etext+0x4d8>
    80003c36:	babfc0ef          	jal	800007e0 <panic>
      panic("dirlookup read");
    80003c3a:	00004517          	auipc	a0,0x4
    80003c3e:	8b650513          	addi	a0,a0,-1866 # 800074f0 <etext+0x4f0>
    80003c42:	b9ffc0ef          	jal	800007e0 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c46:	24c1                	addiw	s1,s1,16
    80003c48:	04c92783          	lw	a5,76(s2)
    80003c4c:	04f4f163          	bgeu	s1,a5,80003c8e <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c50:	4741                	li	a4,16
    80003c52:	86a6                	mv	a3,s1
    80003c54:	fc040613          	addi	a2,s0,-64
    80003c58:	4581                	li	a1,0
    80003c5a:	854a                	mv	a0,s2
    80003c5c:	d89ff0ef          	jal	800039e4 <readi>
    80003c60:	47c1                	li	a5,16
    80003c62:	fcf51ce3          	bne	a0,a5,80003c3a <dirlookup+0x36>
    if(de.inum == 0)
    80003c66:	fc045783          	lhu	a5,-64(s0)
    80003c6a:	dff1                	beqz	a5,80003c46 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003c6c:	fc240593          	addi	a1,s0,-62
    80003c70:	854e                	mv	a0,s3
    80003c72:	f7dff0ef          	jal	80003bee <namecmp>
    80003c76:	f961                	bnez	a0,80003c46 <dirlookup+0x42>
      if(poff)
    80003c78:	000a0463          	beqz	s4,80003c80 <dirlookup+0x7c>
        *poff = off;
    80003c7c:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003c80:	fc045583          	lhu	a1,-64(s0)
    80003c84:	00092503          	lw	a0,0(s2)
    80003c88:	f58ff0ef          	jal	800033e0 <iget>
    80003c8c:	a011                	j	80003c90 <dirlookup+0x8c>
  return 0;
    80003c8e:	4501                	li	a0,0
}
    80003c90:	70e2                	ld	ra,56(sp)
    80003c92:	7442                	ld	s0,48(sp)
    80003c94:	74a2                	ld	s1,40(sp)
    80003c96:	7902                	ld	s2,32(sp)
    80003c98:	69e2                	ld	s3,24(sp)
    80003c9a:	6a42                	ld	s4,16(sp)
    80003c9c:	6121                	addi	sp,sp,64
    80003c9e:	8082                	ret

0000000080003ca0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003ca0:	711d                	addi	sp,sp,-96
    80003ca2:	ec86                	sd	ra,88(sp)
    80003ca4:	e8a2                	sd	s0,80(sp)
    80003ca6:	e4a6                	sd	s1,72(sp)
    80003ca8:	e0ca                	sd	s2,64(sp)
    80003caa:	fc4e                	sd	s3,56(sp)
    80003cac:	f852                	sd	s4,48(sp)
    80003cae:	f456                	sd	s5,40(sp)
    80003cb0:	f05a                	sd	s6,32(sp)
    80003cb2:	ec5e                	sd	s7,24(sp)
    80003cb4:	e862                	sd	s8,16(sp)
    80003cb6:	e466                	sd	s9,8(sp)
    80003cb8:	1080                	addi	s0,sp,96
    80003cba:	84aa                	mv	s1,a0
    80003cbc:	8b2e                	mv	s6,a1
    80003cbe:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003cc0:	00054703          	lbu	a4,0(a0)
    80003cc4:	02f00793          	li	a5,47
    80003cc8:	00f70e63          	beq	a4,a5,80003ce4 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003ccc:	e0bfd0ef          	jal	80001ad6 <myproc>
    80003cd0:	16853503          	ld	a0,360(a0)
    80003cd4:	94bff0ef          	jal	8000361e <idup>
    80003cd8:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003cda:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003cde:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003ce0:	4b85                	li	s7,1
    80003ce2:	a871                	j	80003d7e <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003ce4:	4585                	li	a1,1
    80003ce6:	4505                	li	a0,1
    80003ce8:	ef8ff0ef          	jal	800033e0 <iget>
    80003cec:	8a2a                	mv	s4,a0
    80003cee:	b7f5                	j	80003cda <namex+0x3a>
      iunlockput(ip);
    80003cf0:	8552                	mv	a0,s4
    80003cf2:	b6dff0ef          	jal	8000385e <iunlockput>
      return 0;
    80003cf6:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003cf8:	8552                	mv	a0,s4
    80003cfa:	60e6                	ld	ra,88(sp)
    80003cfc:	6446                	ld	s0,80(sp)
    80003cfe:	64a6                	ld	s1,72(sp)
    80003d00:	6906                	ld	s2,64(sp)
    80003d02:	79e2                	ld	s3,56(sp)
    80003d04:	7a42                	ld	s4,48(sp)
    80003d06:	7aa2                	ld	s5,40(sp)
    80003d08:	7b02                	ld	s6,32(sp)
    80003d0a:	6be2                	ld	s7,24(sp)
    80003d0c:	6c42                	ld	s8,16(sp)
    80003d0e:	6ca2                	ld	s9,8(sp)
    80003d10:	6125                	addi	sp,sp,96
    80003d12:	8082                	ret
      iunlock(ip);
    80003d14:	8552                	mv	a0,s4
    80003d16:	9edff0ef          	jal	80003702 <iunlock>
      return ip;
    80003d1a:	bff9                	j	80003cf8 <namex+0x58>
      iunlockput(ip);
    80003d1c:	8552                	mv	a0,s4
    80003d1e:	b41ff0ef          	jal	8000385e <iunlockput>
      return 0;
    80003d22:	8a4e                	mv	s4,s3
    80003d24:	bfd1                	j	80003cf8 <namex+0x58>
  len = path - s;
    80003d26:	40998633          	sub	a2,s3,s1
    80003d2a:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003d2e:	099c5063          	bge	s8,s9,80003dae <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003d32:	4639                	li	a2,14
    80003d34:	85a6                	mv	a1,s1
    80003d36:	8556                	mv	a0,s5
    80003d38:	8fafd0ef          	jal	80000e32 <memmove>
    80003d3c:	84ce                	mv	s1,s3
  while(*path == '/')
    80003d3e:	0004c783          	lbu	a5,0(s1)
    80003d42:	01279763          	bne	a5,s2,80003d50 <namex+0xb0>
    path++;
    80003d46:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d48:	0004c783          	lbu	a5,0(s1)
    80003d4c:	ff278de3          	beq	a5,s2,80003d46 <namex+0xa6>
    ilock(ip);
    80003d50:	8552                	mv	a0,s4
    80003d52:	903ff0ef          	jal	80003654 <ilock>
    if(ip->type != T_DIR){
    80003d56:	044a1783          	lh	a5,68(s4)
    80003d5a:	f9779be3          	bne	a5,s7,80003cf0 <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003d5e:	000b0563          	beqz	s6,80003d68 <namex+0xc8>
    80003d62:	0004c783          	lbu	a5,0(s1)
    80003d66:	d7dd                	beqz	a5,80003d14 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d68:	4601                	li	a2,0
    80003d6a:	85d6                	mv	a1,s5
    80003d6c:	8552                	mv	a0,s4
    80003d6e:	e97ff0ef          	jal	80003c04 <dirlookup>
    80003d72:	89aa                	mv	s3,a0
    80003d74:	d545                	beqz	a0,80003d1c <namex+0x7c>
    iunlockput(ip);
    80003d76:	8552                	mv	a0,s4
    80003d78:	ae7ff0ef          	jal	8000385e <iunlockput>
    ip = next;
    80003d7c:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003d7e:	0004c783          	lbu	a5,0(s1)
    80003d82:	01279763          	bne	a5,s2,80003d90 <namex+0xf0>
    path++;
    80003d86:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d88:	0004c783          	lbu	a5,0(s1)
    80003d8c:	ff278de3          	beq	a5,s2,80003d86 <namex+0xe6>
  if(*path == 0)
    80003d90:	cb8d                	beqz	a5,80003dc2 <namex+0x122>
  while(*path != '/' && *path != 0)
    80003d92:	0004c783          	lbu	a5,0(s1)
    80003d96:	89a6                	mv	s3,s1
  len = path - s;
    80003d98:	4c81                	li	s9,0
    80003d9a:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003d9c:	01278963          	beq	a5,s2,80003dae <namex+0x10e>
    80003da0:	d3d9                	beqz	a5,80003d26 <namex+0x86>
    path++;
    80003da2:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003da4:	0009c783          	lbu	a5,0(s3)
    80003da8:	ff279ce3          	bne	a5,s2,80003da0 <namex+0x100>
    80003dac:	bfad                	j	80003d26 <namex+0x86>
    memmove(name, s, len);
    80003dae:	2601                	sext.w	a2,a2
    80003db0:	85a6                	mv	a1,s1
    80003db2:	8556                	mv	a0,s5
    80003db4:	87efd0ef          	jal	80000e32 <memmove>
    name[len] = 0;
    80003db8:	9cd6                	add	s9,s9,s5
    80003dba:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003dbe:	84ce                	mv	s1,s3
    80003dc0:	bfbd                	j	80003d3e <namex+0x9e>
  if(nameiparent){
    80003dc2:	f20b0be3          	beqz	s6,80003cf8 <namex+0x58>
    iput(ip);
    80003dc6:	8552                	mv	a0,s4
    80003dc8:	a0fff0ef          	jal	800037d6 <iput>
    return 0;
    80003dcc:	4a01                	li	s4,0
    80003dce:	b72d                	j	80003cf8 <namex+0x58>

0000000080003dd0 <dirlink>:
{
    80003dd0:	7139                	addi	sp,sp,-64
    80003dd2:	fc06                	sd	ra,56(sp)
    80003dd4:	f822                	sd	s0,48(sp)
    80003dd6:	f04a                	sd	s2,32(sp)
    80003dd8:	ec4e                	sd	s3,24(sp)
    80003dda:	e852                	sd	s4,16(sp)
    80003ddc:	0080                	addi	s0,sp,64
    80003dde:	892a                	mv	s2,a0
    80003de0:	8a2e                	mv	s4,a1
    80003de2:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003de4:	4601                	li	a2,0
    80003de6:	e1fff0ef          	jal	80003c04 <dirlookup>
    80003dea:	e535                	bnez	a0,80003e56 <dirlink+0x86>
    80003dec:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dee:	04c92483          	lw	s1,76(s2)
    80003df2:	c48d                	beqz	s1,80003e1c <dirlink+0x4c>
    80003df4:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003df6:	4741                	li	a4,16
    80003df8:	86a6                	mv	a3,s1
    80003dfa:	fc040613          	addi	a2,s0,-64
    80003dfe:	4581                	li	a1,0
    80003e00:	854a                	mv	a0,s2
    80003e02:	be3ff0ef          	jal	800039e4 <readi>
    80003e06:	47c1                	li	a5,16
    80003e08:	04f51b63          	bne	a0,a5,80003e5e <dirlink+0x8e>
    if(de.inum == 0)
    80003e0c:	fc045783          	lhu	a5,-64(s0)
    80003e10:	c791                	beqz	a5,80003e1c <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e12:	24c1                	addiw	s1,s1,16
    80003e14:	04c92783          	lw	a5,76(s2)
    80003e18:	fcf4efe3          	bltu	s1,a5,80003df6 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003e1c:	4639                	li	a2,14
    80003e1e:	85d2                	mv	a1,s4
    80003e20:	fc240513          	addi	a0,s0,-62
    80003e24:	8b4fd0ef          	jal	80000ed8 <strncpy>
  de.inum = inum;
    80003e28:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e2c:	4741                	li	a4,16
    80003e2e:	86a6                	mv	a3,s1
    80003e30:	fc040613          	addi	a2,s0,-64
    80003e34:	4581                	li	a1,0
    80003e36:	854a                	mv	a0,s2
    80003e38:	ca9ff0ef          	jal	80003ae0 <writei>
    80003e3c:	1541                	addi	a0,a0,-16
    80003e3e:	00a03533          	snez	a0,a0
    80003e42:	40a00533          	neg	a0,a0
    80003e46:	74a2                	ld	s1,40(sp)
}
    80003e48:	70e2                	ld	ra,56(sp)
    80003e4a:	7442                	ld	s0,48(sp)
    80003e4c:	7902                	ld	s2,32(sp)
    80003e4e:	69e2                	ld	s3,24(sp)
    80003e50:	6a42                	ld	s4,16(sp)
    80003e52:	6121                	addi	sp,sp,64
    80003e54:	8082                	ret
    iput(ip);
    80003e56:	981ff0ef          	jal	800037d6 <iput>
    return -1;
    80003e5a:	557d                	li	a0,-1
    80003e5c:	b7f5                	j	80003e48 <dirlink+0x78>
      panic("dirlink read");
    80003e5e:	00003517          	auipc	a0,0x3
    80003e62:	6a250513          	addi	a0,a0,1698 # 80007500 <etext+0x500>
    80003e66:	97bfc0ef          	jal	800007e0 <panic>

0000000080003e6a <namei>:

struct inode*
namei(char *path)
{
    80003e6a:	1101                	addi	sp,sp,-32
    80003e6c:	ec06                	sd	ra,24(sp)
    80003e6e:	e822                	sd	s0,16(sp)
    80003e70:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e72:	fe040613          	addi	a2,s0,-32
    80003e76:	4581                	li	a1,0
    80003e78:	e29ff0ef          	jal	80003ca0 <namex>
}
    80003e7c:	60e2                	ld	ra,24(sp)
    80003e7e:	6442                	ld	s0,16(sp)
    80003e80:	6105                	addi	sp,sp,32
    80003e82:	8082                	ret

0000000080003e84 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003e84:	1141                	addi	sp,sp,-16
    80003e86:	e406                	sd	ra,8(sp)
    80003e88:	e022                	sd	s0,0(sp)
    80003e8a:	0800                	addi	s0,sp,16
    80003e8c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e8e:	4585                	li	a1,1
    80003e90:	e11ff0ef          	jal	80003ca0 <namex>
}
    80003e94:	60a2                	ld	ra,8(sp)
    80003e96:	6402                	ld	s0,0(sp)
    80003e98:	0141                	addi	sp,sp,16
    80003e9a:	8082                	ret

0000000080003e9c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003e9c:	1101                	addi	sp,sp,-32
    80003e9e:	ec06                	sd	ra,24(sp)
    80003ea0:	e822                	sd	s0,16(sp)
    80003ea2:	e426                	sd	s1,8(sp)
    80003ea4:	e04a                	sd	s2,0(sp)
    80003ea6:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003ea8:	0012c917          	auipc	s2,0x12c
    80003eac:	0f890913          	addi	s2,s2,248 # 8012ffa0 <log>
    80003eb0:	01892583          	lw	a1,24(s2)
    80003eb4:	02492503          	lw	a0,36(s2)
    80003eb8:	8d0ff0ef          	jal	80002f88 <bread>
    80003ebc:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003ebe:	02892603          	lw	a2,40(s2)
    80003ec2:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003ec4:	00c05f63          	blez	a2,80003ee2 <write_head+0x46>
    80003ec8:	0012c717          	auipc	a4,0x12c
    80003ecc:	10470713          	addi	a4,a4,260 # 8012ffcc <log+0x2c>
    80003ed0:	87aa                	mv	a5,a0
    80003ed2:	060a                	slli	a2,a2,0x2
    80003ed4:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003ed6:	4314                	lw	a3,0(a4)
    80003ed8:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003eda:	0711                	addi	a4,a4,4
    80003edc:	0791                	addi	a5,a5,4
    80003ede:	fec79ce3          	bne	a5,a2,80003ed6 <write_head+0x3a>
  }
  bwrite(buf);
    80003ee2:	8526                	mv	a0,s1
    80003ee4:	97aff0ef          	jal	8000305e <bwrite>
  brelse(buf);
    80003ee8:	8526                	mv	a0,s1
    80003eea:	9a6ff0ef          	jal	80003090 <brelse>
}
    80003eee:	60e2                	ld	ra,24(sp)
    80003ef0:	6442                	ld	s0,16(sp)
    80003ef2:	64a2                	ld	s1,8(sp)
    80003ef4:	6902                	ld	s2,0(sp)
    80003ef6:	6105                	addi	sp,sp,32
    80003ef8:	8082                	ret

0000000080003efa <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003efa:	0012c797          	auipc	a5,0x12c
    80003efe:	0ce7a783          	lw	a5,206(a5) # 8012ffc8 <log+0x28>
    80003f02:	0af05e63          	blez	a5,80003fbe <install_trans+0xc4>
{
    80003f06:	715d                	addi	sp,sp,-80
    80003f08:	e486                	sd	ra,72(sp)
    80003f0a:	e0a2                	sd	s0,64(sp)
    80003f0c:	fc26                	sd	s1,56(sp)
    80003f0e:	f84a                	sd	s2,48(sp)
    80003f10:	f44e                	sd	s3,40(sp)
    80003f12:	f052                	sd	s4,32(sp)
    80003f14:	ec56                	sd	s5,24(sp)
    80003f16:	e85a                	sd	s6,16(sp)
    80003f18:	e45e                	sd	s7,8(sp)
    80003f1a:	0880                	addi	s0,sp,80
    80003f1c:	8b2a                	mv	s6,a0
    80003f1e:	0012ca97          	auipc	s5,0x12c
    80003f22:	0aea8a93          	addi	s5,s5,174 # 8012ffcc <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f26:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003f28:	00003b97          	auipc	s7,0x3
    80003f2c:	5e8b8b93          	addi	s7,s7,1512 # 80007510 <etext+0x510>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f30:	0012ca17          	auipc	s4,0x12c
    80003f34:	070a0a13          	addi	s4,s4,112 # 8012ffa0 <log>
    80003f38:	a025                	j	80003f60 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003f3a:	000aa603          	lw	a2,0(s5)
    80003f3e:	85ce                	mv	a1,s3
    80003f40:	855e                	mv	a0,s7
    80003f42:	db8fc0ef          	jal	800004fa <printf>
    80003f46:	a839                	j	80003f64 <install_trans+0x6a>
    brelse(lbuf);
    80003f48:	854a                	mv	a0,s2
    80003f4a:	946ff0ef          	jal	80003090 <brelse>
    brelse(dbuf);
    80003f4e:	8526                	mv	a0,s1
    80003f50:	940ff0ef          	jal	80003090 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f54:	2985                	addiw	s3,s3,1
    80003f56:	0a91                	addi	s5,s5,4
    80003f58:	028a2783          	lw	a5,40(s4)
    80003f5c:	04f9d663          	bge	s3,a5,80003fa8 <install_trans+0xae>
    if(recovering) {
    80003f60:	fc0b1de3          	bnez	s6,80003f3a <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f64:	018a2583          	lw	a1,24(s4)
    80003f68:	013585bb          	addw	a1,a1,s3
    80003f6c:	2585                	addiw	a1,a1,1
    80003f6e:	024a2503          	lw	a0,36(s4)
    80003f72:	816ff0ef          	jal	80002f88 <bread>
    80003f76:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003f78:	000aa583          	lw	a1,0(s5)
    80003f7c:	024a2503          	lw	a0,36(s4)
    80003f80:	808ff0ef          	jal	80002f88 <bread>
    80003f84:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003f86:	40000613          	li	a2,1024
    80003f8a:	05890593          	addi	a1,s2,88
    80003f8e:	05850513          	addi	a0,a0,88
    80003f92:	ea1fc0ef          	jal	80000e32 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003f96:	8526                	mv	a0,s1
    80003f98:	8c6ff0ef          	jal	8000305e <bwrite>
    if(recovering == 0)
    80003f9c:	fa0b16e3          	bnez	s6,80003f48 <install_trans+0x4e>
      bunpin(dbuf);
    80003fa0:	8526                	mv	a0,s1
    80003fa2:	9aaff0ef          	jal	8000314c <bunpin>
    80003fa6:	b74d                	j	80003f48 <install_trans+0x4e>
}
    80003fa8:	60a6                	ld	ra,72(sp)
    80003faa:	6406                	ld	s0,64(sp)
    80003fac:	74e2                	ld	s1,56(sp)
    80003fae:	7942                	ld	s2,48(sp)
    80003fb0:	79a2                	ld	s3,40(sp)
    80003fb2:	7a02                	ld	s4,32(sp)
    80003fb4:	6ae2                	ld	s5,24(sp)
    80003fb6:	6b42                	ld	s6,16(sp)
    80003fb8:	6ba2                	ld	s7,8(sp)
    80003fba:	6161                	addi	sp,sp,80
    80003fbc:	8082                	ret
    80003fbe:	8082                	ret

0000000080003fc0 <initlog>:
{
    80003fc0:	7179                	addi	sp,sp,-48
    80003fc2:	f406                	sd	ra,40(sp)
    80003fc4:	f022                	sd	s0,32(sp)
    80003fc6:	ec26                	sd	s1,24(sp)
    80003fc8:	e84a                	sd	s2,16(sp)
    80003fca:	e44e                	sd	s3,8(sp)
    80003fcc:	1800                	addi	s0,sp,48
    80003fce:	892a                	mv	s2,a0
    80003fd0:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003fd2:	0012c497          	auipc	s1,0x12c
    80003fd6:	fce48493          	addi	s1,s1,-50 # 8012ffa0 <log>
    80003fda:	00003597          	auipc	a1,0x3
    80003fde:	55658593          	addi	a1,a1,1366 # 80007530 <etext+0x530>
    80003fe2:	8526                	mv	a0,s1
    80003fe4:	c9ffc0ef          	jal	80000c82 <initlock>
  log.start = sb->logstart;
    80003fe8:	0149a583          	lw	a1,20(s3)
    80003fec:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003fee:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003ff2:	854a                	mv	a0,s2
    80003ff4:	f95fe0ef          	jal	80002f88 <bread>
  log.lh.n = lh->n;
    80003ff8:	4d30                	lw	a2,88(a0)
    80003ffa:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003ffc:	00c05f63          	blez	a2,8000401a <initlog+0x5a>
    80004000:	87aa                	mv	a5,a0
    80004002:	0012c717          	auipc	a4,0x12c
    80004006:	fca70713          	addi	a4,a4,-54 # 8012ffcc <log+0x2c>
    8000400a:	060a                	slli	a2,a2,0x2
    8000400c:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    8000400e:	4ff4                	lw	a3,92(a5)
    80004010:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004012:	0791                	addi	a5,a5,4
    80004014:	0711                	addi	a4,a4,4
    80004016:	fec79ce3          	bne	a5,a2,8000400e <initlog+0x4e>
  brelse(buf);
    8000401a:	876ff0ef          	jal	80003090 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000401e:	4505                	li	a0,1
    80004020:	edbff0ef          	jal	80003efa <install_trans>
  log.lh.n = 0;
    80004024:	0012c797          	auipc	a5,0x12c
    80004028:	fa07a223          	sw	zero,-92(a5) # 8012ffc8 <log+0x28>
  write_head(); // clear the log
    8000402c:	e71ff0ef          	jal	80003e9c <write_head>
}
    80004030:	70a2                	ld	ra,40(sp)
    80004032:	7402                	ld	s0,32(sp)
    80004034:	64e2                	ld	s1,24(sp)
    80004036:	6942                	ld	s2,16(sp)
    80004038:	69a2                	ld	s3,8(sp)
    8000403a:	6145                	addi	sp,sp,48
    8000403c:	8082                	ret

000000008000403e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000403e:	1101                	addi	sp,sp,-32
    80004040:	ec06                	sd	ra,24(sp)
    80004042:	e822                	sd	s0,16(sp)
    80004044:	e426                	sd	s1,8(sp)
    80004046:	e04a                	sd	s2,0(sp)
    80004048:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000404a:	0012c517          	auipc	a0,0x12c
    8000404e:	f5650513          	addi	a0,a0,-170 # 8012ffa0 <log>
    80004052:	cb1fc0ef          	jal	80000d02 <acquire>
  while(1){
    if(log.committing){
    80004056:	0012c497          	auipc	s1,0x12c
    8000405a:	f4a48493          	addi	s1,s1,-182 # 8012ffa0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    8000405e:	4979                	li	s2,30
    80004060:	a029                	j	8000406a <begin_op+0x2c>
      sleep(&log, &log.lock);
    80004062:	85a6                	mv	a1,s1
    80004064:	8526                	mv	a0,s1
    80004066:	916fe0ef          	jal	8000217c <sleep>
    if(log.committing){
    8000406a:	509c                	lw	a5,32(s1)
    8000406c:	fbfd                	bnez	a5,80004062 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    8000406e:	4cd8                	lw	a4,28(s1)
    80004070:	2705                	addiw	a4,a4,1
    80004072:	0027179b          	slliw	a5,a4,0x2
    80004076:	9fb9                	addw	a5,a5,a4
    80004078:	0017979b          	slliw	a5,a5,0x1
    8000407c:	5494                	lw	a3,40(s1)
    8000407e:	9fb5                	addw	a5,a5,a3
    80004080:	00f95763          	bge	s2,a5,8000408e <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004084:	85a6                	mv	a1,s1
    80004086:	8526                	mv	a0,s1
    80004088:	8f4fe0ef          	jal	8000217c <sleep>
    8000408c:	bff9                	j	8000406a <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    8000408e:	0012c517          	auipc	a0,0x12c
    80004092:	f1250513          	addi	a0,a0,-238 # 8012ffa0 <log>
    80004096:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80004098:	d03fc0ef          	jal	80000d9a <release>
      break;
    }
  }
}
    8000409c:	60e2                	ld	ra,24(sp)
    8000409e:	6442                	ld	s0,16(sp)
    800040a0:	64a2                	ld	s1,8(sp)
    800040a2:	6902                	ld	s2,0(sp)
    800040a4:	6105                	addi	sp,sp,32
    800040a6:	8082                	ret

00000000800040a8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800040a8:	7139                	addi	sp,sp,-64
    800040aa:	fc06                	sd	ra,56(sp)
    800040ac:	f822                	sd	s0,48(sp)
    800040ae:	f426                	sd	s1,40(sp)
    800040b0:	f04a                	sd	s2,32(sp)
    800040b2:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800040b4:	0012c497          	auipc	s1,0x12c
    800040b8:	eec48493          	addi	s1,s1,-276 # 8012ffa0 <log>
    800040bc:	8526                	mv	a0,s1
    800040be:	c45fc0ef          	jal	80000d02 <acquire>
  log.outstanding -= 1;
    800040c2:	4cdc                	lw	a5,28(s1)
    800040c4:	37fd                	addiw	a5,a5,-1
    800040c6:	0007891b          	sext.w	s2,a5
    800040ca:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    800040cc:	509c                	lw	a5,32(s1)
    800040ce:	ef9d                	bnez	a5,8000410c <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    800040d0:	04091763          	bnez	s2,8000411e <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    800040d4:	0012c497          	auipc	s1,0x12c
    800040d8:	ecc48493          	addi	s1,s1,-308 # 8012ffa0 <log>
    800040dc:	4785                	li	a5,1
    800040de:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800040e0:	8526                	mv	a0,s1
    800040e2:	cb9fc0ef          	jal	80000d9a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800040e6:	549c                	lw	a5,40(s1)
    800040e8:	04f04b63          	bgtz	a5,8000413e <end_op+0x96>
    acquire(&log.lock);
    800040ec:	0012c497          	auipc	s1,0x12c
    800040f0:	eb448493          	addi	s1,s1,-332 # 8012ffa0 <log>
    800040f4:	8526                	mv	a0,s1
    800040f6:	c0dfc0ef          	jal	80000d02 <acquire>
    log.committing = 0;
    800040fa:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    800040fe:	8526                	mv	a0,s1
    80004100:	8c8fe0ef          	jal	800021c8 <wakeup>
    release(&log.lock);
    80004104:	8526                	mv	a0,s1
    80004106:	c95fc0ef          	jal	80000d9a <release>
}
    8000410a:	a025                	j	80004132 <end_op+0x8a>
    8000410c:	ec4e                	sd	s3,24(sp)
    8000410e:	e852                	sd	s4,16(sp)
    80004110:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004112:	00003517          	auipc	a0,0x3
    80004116:	42650513          	addi	a0,a0,1062 # 80007538 <etext+0x538>
    8000411a:	ec6fc0ef          	jal	800007e0 <panic>
    wakeup(&log);
    8000411e:	0012c497          	auipc	s1,0x12c
    80004122:	e8248493          	addi	s1,s1,-382 # 8012ffa0 <log>
    80004126:	8526                	mv	a0,s1
    80004128:	8a0fe0ef          	jal	800021c8 <wakeup>
  release(&log.lock);
    8000412c:	8526                	mv	a0,s1
    8000412e:	c6dfc0ef          	jal	80000d9a <release>
}
    80004132:	70e2                	ld	ra,56(sp)
    80004134:	7442                	ld	s0,48(sp)
    80004136:	74a2                	ld	s1,40(sp)
    80004138:	7902                	ld	s2,32(sp)
    8000413a:	6121                	addi	sp,sp,64
    8000413c:	8082                	ret
    8000413e:	ec4e                	sd	s3,24(sp)
    80004140:	e852                	sd	s4,16(sp)
    80004142:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004144:	0012ca97          	auipc	s5,0x12c
    80004148:	e88a8a93          	addi	s5,s5,-376 # 8012ffcc <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000414c:	0012ca17          	auipc	s4,0x12c
    80004150:	e54a0a13          	addi	s4,s4,-428 # 8012ffa0 <log>
    80004154:	018a2583          	lw	a1,24(s4)
    80004158:	012585bb          	addw	a1,a1,s2
    8000415c:	2585                	addiw	a1,a1,1
    8000415e:	024a2503          	lw	a0,36(s4)
    80004162:	e27fe0ef          	jal	80002f88 <bread>
    80004166:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004168:	000aa583          	lw	a1,0(s5)
    8000416c:	024a2503          	lw	a0,36(s4)
    80004170:	e19fe0ef          	jal	80002f88 <bread>
    80004174:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004176:	40000613          	li	a2,1024
    8000417a:	05850593          	addi	a1,a0,88
    8000417e:	05848513          	addi	a0,s1,88
    80004182:	cb1fc0ef          	jal	80000e32 <memmove>
    bwrite(to);  // write the log
    80004186:	8526                	mv	a0,s1
    80004188:	ed7fe0ef          	jal	8000305e <bwrite>
    brelse(from);
    8000418c:	854e                	mv	a0,s3
    8000418e:	f03fe0ef          	jal	80003090 <brelse>
    brelse(to);
    80004192:	8526                	mv	a0,s1
    80004194:	efdfe0ef          	jal	80003090 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004198:	2905                	addiw	s2,s2,1
    8000419a:	0a91                	addi	s5,s5,4
    8000419c:	028a2783          	lw	a5,40(s4)
    800041a0:	faf94ae3          	blt	s2,a5,80004154 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800041a4:	cf9ff0ef          	jal	80003e9c <write_head>
    install_trans(0); // Now install writes to home locations
    800041a8:	4501                	li	a0,0
    800041aa:	d51ff0ef          	jal	80003efa <install_trans>
    log.lh.n = 0;
    800041ae:	0012c797          	auipc	a5,0x12c
    800041b2:	e007ad23          	sw	zero,-486(a5) # 8012ffc8 <log+0x28>
    write_head();    // Erase the transaction from the log
    800041b6:	ce7ff0ef          	jal	80003e9c <write_head>
    800041ba:	69e2                	ld	s3,24(sp)
    800041bc:	6a42                	ld	s4,16(sp)
    800041be:	6aa2                	ld	s5,8(sp)
    800041c0:	b735                	j	800040ec <end_op+0x44>

00000000800041c2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800041c2:	1101                	addi	sp,sp,-32
    800041c4:	ec06                	sd	ra,24(sp)
    800041c6:	e822                	sd	s0,16(sp)
    800041c8:	e426                	sd	s1,8(sp)
    800041ca:	e04a                	sd	s2,0(sp)
    800041cc:	1000                	addi	s0,sp,32
    800041ce:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800041d0:	0012c917          	auipc	s2,0x12c
    800041d4:	dd090913          	addi	s2,s2,-560 # 8012ffa0 <log>
    800041d8:	854a                	mv	a0,s2
    800041da:	b29fc0ef          	jal	80000d02 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    800041de:	02892603          	lw	a2,40(s2)
    800041e2:	47f5                	li	a5,29
    800041e4:	04c7cc63          	blt	a5,a2,8000423c <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800041e8:	0012c797          	auipc	a5,0x12c
    800041ec:	dd47a783          	lw	a5,-556(a5) # 8012ffbc <log+0x1c>
    800041f0:	04f05c63          	blez	a5,80004248 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800041f4:	4781                	li	a5,0
    800041f6:	04c05f63          	blez	a2,80004254 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800041fa:	44cc                	lw	a1,12(s1)
    800041fc:	0012c717          	auipc	a4,0x12c
    80004200:	dd070713          	addi	a4,a4,-560 # 8012ffcc <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004204:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004206:	4314                	lw	a3,0(a4)
    80004208:	04b68663          	beq	a3,a1,80004254 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    8000420c:	2785                	addiw	a5,a5,1
    8000420e:	0711                	addi	a4,a4,4
    80004210:	fef61be3          	bne	a2,a5,80004206 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004214:	0621                	addi	a2,a2,8
    80004216:	060a                	slli	a2,a2,0x2
    80004218:	0012c797          	auipc	a5,0x12c
    8000421c:	d8878793          	addi	a5,a5,-632 # 8012ffa0 <log>
    80004220:	97b2                	add	a5,a5,a2
    80004222:	44d8                	lw	a4,12(s1)
    80004224:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004226:	8526                	mv	a0,s1
    80004228:	ef1fe0ef          	jal	80003118 <bpin>
    log.lh.n++;
    8000422c:	0012c717          	auipc	a4,0x12c
    80004230:	d7470713          	addi	a4,a4,-652 # 8012ffa0 <log>
    80004234:	571c                	lw	a5,40(a4)
    80004236:	2785                	addiw	a5,a5,1
    80004238:	d71c                	sw	a5,40(a4)
    8000423a:	a80d                	j	8000426c <log_write+0xaa>
    panic("too big a transaction");
    8000423c:	00003517          	auipc	a0,0x3
    80004240:	30c50513          	addi	a0,a0,780 # 80007548 <etext+0x548>
    80004244:	d9cfc0ef          	jal	800007e0 <panic>
    panic("log_write outside of trans");
    80004248:	00003517          	auipc	a0,0x3
    8000424c:	31850513          	addi	a0,a0,792 # 80007560 <etext+0x560>
    80004250:	d90fc0ef          	jal	800007e0 <panic>
  log.lh.block[i] = b->blockno;
    80004254:	00878693          	addi	a3,a5,8
    80004258:	068a                	slli	a3,a3,0x2
    8000425a:	0012c717          	auipc	a4,0x12c
    8000425e:	d4670713          	addi	a4,a4,-698 # 8012ffa0 <log>
    80004262:	9736                	add	a4,a4,a3
    80004264:	44d4                	lw	a3,12(s1)
    80004266:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004268:	faf60fe3          	beq	a2,a5,80004226 <log_write+0x64>
  }
  release(&log.lock);
    8000426c:	0012c517          	auipc	a0,0x12c
    80004270:	d3450513          	addi	a0,a0,-716 # 8012ffa0 <log>
    80004274:	b27fc0ef          	jal	80000d9a <release>
}
    80004278:	60e2                	ld	ra,24(sp)
    8000427a:	6442                	ld	s0,16(sp)
    8000427c:	64a2                	ld	s1,8(sp)
    8000427e:	6902                	ld	s2,0(sp)
    80004280:	6105                	addi	sp,sp,32
    80004282:	8082                	ret

0000000080004284 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004284:	1101                	addi	sp,sp,-32
    80004286:	ec06                	sd	ra,24(sp)
    80004288:	e822                	sd	s0,16(sp)
    8000428a:	e426                	sd	s1,8(sp)
    8000428c:	e04a                	sd	s2,0(sp)
    8000428e:	1000                	addi	s0,sp,32
    80004290:	84aa                	mv	s1,a0
    80004292:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004294:	00003597          	auipc	a1,0x3
    80004298:	2ec58593          	addi	a1,a1,748 # 80007580 <etext+0x580>
    8000429c:	0521                	addi	a0,a0,8
    8000429e:	9e5fc0ef          	jal	80000c82 <initlock>
  lk->name = name;
    800042a2:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800042a6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800042aa:	0204a423          	sw	zero,40(s1)
}
    800042ae:	60e2                	ld	ra,24(sp)
    800042b0:	6442                	ld	s0,16(sp)
    800042b2:	64a2                	ld	s1,8(sp)
    800042b4:	6902                	ld	s2,0(sp)
    800042b6:	6105                	addi	sp,sp,32
    800042b8:	8082                	ret

00000000800042ba <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800042ba:	1101                	addi	sp,sp,-32
    800042bc:	ec06                	sd	ra,24(sp)
    800042be:	e822                	sd	s0,16(sp)
    800042c0:	e426                	sd	s1,8(sp)
    800042c2:	e04a                	sd	s2,0(sp)
    800042c4:	1000                	addi	s0,sp,32
    800042c6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800042c8:	00850913          	addi	s2,a0,8
    800042cc:	854a                	mv	a0,s2
    800042ce:	a35fc0ef          	jal	80000d02 <acquire>
  while (lk->locked) {
    800042d2:	409c                	lw	a5,0(s1)
    800042d4:	c799                	beqz	a5,800042e2 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800042d6:	85ca                	mv	a1,s2
    800042d8:	8526                	mv	a0,s1
    800042da:	ea3fd0ef          	jal	8000217c <sleep>
  while (lk->locked) {
    800042de:	409c                	lw	a5,0(s1)
    800042e0:	fbfd                	bnez	a5,800042d6 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800042e2:	4785                	li	a5,1
    800042e4:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800042e6:	ff0fd0ef          	jal	80001ad6 <myproc>
    800042ea:	591c                	lw	a5,48(a0)
    800042ec:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800042ee:	854a                	mv	a0,s2
    800042f0:	aabfc0ef          	jal	80000d9a <release>
}
    800042f4:	60e2                	ld	ra,24(sp)
    800042f6:	6442                	ld	s0,16(sp)
    800042f8:	64a2                	ld	s1,8(sp)
    800042fa:	6902                	ld	s2,0(sp)
    800042fc:	6105                	addi	sp,sp,32
    800042fe:	8082                	ret

0000000080004300 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004300:	1101                	addi	sp,sp,-32
    80004302:	ec06                	sd	ra,24(sp)
    80004304:	e822                	sd	s0,16(sp)
    80004306:	e426                	sd	s1,8(sp)
    80004308:	e04a                	sd	s2,0(sp)
    8000430a:	1000                	addi	s0,sp,32
    8000430c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000430e:	00850913          	addi	s2,a0,8
    80004312:	854a                	mv	a0,s2
    80004314:	9effc0ef          	jal	80000d02 <acquire>
  lk->locked = 0;
    80004318:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000431c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004320:	8526                	mv	a0,s1
    80004322:	ea7fd0ef          	jal	800021c8 <wakeup>
  release(&lk->lk);
    80004326:	854a                	mv	a0,s2
    80004328:	a73fc0ef          	jal	80000d9a <release>
}
    8000432c:	60e2                	ld	ra,24(sp)
    8000432e:	6442                	ld	s0,16(sp)
    80004330:	64a2                	ld	s1,8(sp)
    80004332:	6902                	ld	s2,0(sp)
    80004334:	6105                	addi	sp,sp,32
    80004336:	8082                	ret

0000000080004338 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004338:	7179                	addi	sp,sp,-48
    8000433a:	f406                	sd	ra,40(sp)
    8000433c:	f022                	sd	s0,32(sp)
    8000433e:	ec26                	sd	s1,24(sp)
    80004340:	e84a                	sd	s2,16(sp)
    80004342:	1800                	addi	s0,sp,48
    80004344:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004346:	00850913          	addi	s2,a0,8
    8000434a:	854a                	mv	a0,s2
    8000434c:	9b7fc0ef          	jal	80000d02 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004350:	409c                	lw	a5,0(s1)
    80004352:	ef81                	bnez	a5,8000436a <holdingsleep+0x32>
    80004354:	4481                	li	s1,0
  release(&lk->lk);
    80004356:	854a                	mv	a0,s2
    80004358:	a43fc0ef          	jal	80000d9a <release>
  return r;
}
    8000435c:	8526                	mv	a0,s1
    8000435e:	70a2                	ld	ra,40(sp)
    80004360:	7402                	ld	s0,32(sp)
    80004362:	64e2                	ld	s1,24(sp)
    80004364:	6942                	ld	s2,16(sp)
    80004366:	6145                	addi	sp,sp,48
    80004368:	8082                	ret
    8000436a:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000436c:	0284a983          	lw	s3,40(s1)
    80004370:	f66fd0ef          	jal	80001ad6 <myproc>
    80004374:	5904                	lw	s1,48(a0)
    80004376:	413484b3          	sub	s1,s1,s3
    8000437a:	0014b493          	seqz	s1,s1
    8000437e:	69a2                	ld	s3,8(sp)
    80004380:	bfd9                	j	80004356 <holdingsleep+0x1e>

0000000080004382 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004382:	1141                	addi	sp,sp,-16
    80004384:	e406                	sd	ra,8(sp)
    80004386:	e022                	sd	s0,0(sp)
    80004388:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000438a:	00003597          	auipc	a1,0x3
    8000438e:	20658593          	addi	a1,a1,518 # 80007590 <etext+0x590>
    80004392:	0012c517          	auipc	a0,0x12c
    80004396:	d5650513          	addi	a0,a0,-682 # 801300e8 <ftable>
    8000439a:	8e9fc0ef          	jal	80000c82 <initlock>
}
    8000439e:	60a2                	ld	ra,8(sp)
    800043a0:	6402                	ld	s0,0(sp)
    800043a2:	0141                	addi	sp,sp,16
    800043a4:	8082                	ret

00000000800043a6 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800043a6:	1101                	addi	sp,sp,-32
    800043a8:	ec06                	sd	ra,24(sp)
    800043aa:	e822                	sd	s0,16(sp)
    800043ac:	e426                	sd	s1,8(sp)
    800043ae:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800043b0:	0012c517          	auipc	a0,0x12c
    800043b4:	d3850513          	addi	a0,a0,-712 # 801300e8 <ftable>
    800043b8:	94bfc0ef          	jal	80000d02 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800043bc:	0012c497          	auipc	s1,0x12c
    800043c0:	d4448493          	addi	s1,s1,-700 # 80130100 <ftable+0x18>
    800043c4:	0012d717          	auipc	a4,0x12d
    800043c8:	cdc70713          	addi	a4,a4,-804 # 801310a0 <disk>
    if(f->ref == 0){
    800043cc:	40dc                	lw	a5,4(s1)
    800043ce:	cf89                	beqz	a5,800043e8 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800043d0:	02848493          	addi	s1,s1,40
    800043d4:	fee49ce3          	bne	s1,a4,800043cc <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800043d8:	0012c517          	auipc	a0,0x12c
    800043dc:	d1050513          	addi	a0,a0,-752 # 801300e8 <ftable>
    800043e0:	9bbfc0ef          	jal	80000d9a <release>
  return 0;
    800043e4:	4481                	li	s1,0
    800043e6:	a809                	j	800043f8 <filealloc+0x52>
      f->ref = 1;
    800043e8:	4785                	li	a5,1
    800043ea:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800043ec:	0012c517          	auipc	a0,0x12c
    800043f0:	cfc50513          	addi	a0,a0,-772 # 801300e8 <ftable>
    800043f4:	9a7fc0ef          	jal	80000d9a <release>
}
    800043f8:	8526                	mv	a0,s1
    800043fa:	60e2                	ld	ra,24(sp)
    800043fc:	6442                	ld	s0,16(sp)
    800043fe:	64a2                	ld	s1,8(sp)
    80004400:	6105                	addi	sp,sp,32
    80004402:	8082                	ret

0000000080004404 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004404:	1101                	addi	sp,sp,-32
    80004406:	ec06                	sd	ra,24(sp)
    80004408:	e822                	sd	s0,16(sp)
    8000440a:	e426                	sd	s1,8(sp)
    8000440c:	1000                	addi	s0,sp,32
    8000440e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004410:	0012c517          	auipc	a0,0x12c
    80004414:	cd850513          	addi	a0,a0,-808 # 801300e8 <ftable>
    80004418:	8ebfc0ef          	jal	80000d02 <acquire>
  if(f->ref < 1)
    8000441c:	40dc                	lw	a5,4(s1)
    8000441e:	02f05063          	blez	a5,8000443e <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004422:	2785                	addiw	a5,a5,1
    80004424:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004426:	0012c517          	auipc	a0,0x12c
    8000442a:	cc250513          	addi	a0,a0,-830 # 801300e8 <ftable>
    8000442e:	96dfc0ef          	jal	80000d9a <release>
  return f;
}
    80004432:	8526                	mv	a0,s1
    80004434:	60e2                	ld	ra,24(sp)
    80004436:	6442                	ld	s0,16(sp)
    80004438:	64a2                	ld	s1,8(sp)
    8000443a:	6105                	addi	sp,sp,32
    8000443c:	8082                	ret
    panic("filedup");
    8000443e:	00003517          	auipc	a0,0x3
    80004442:	15a50513          	addi	a0,a0,346 # 80007598 <etext+0x598>
    80004446:	b9afc0ef          	jal	800007e0 <panic>

000000008000444a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000444a:	7139                	addi	sp,sp,-64
    8000444c:	fc06                	sd	ra,56(sp)
    8000444e:	f822                	sd	s0,48(sp)
    80004450:	f426                	sd	s1,40(sp)
    80004452:	0080                	addi	s0,sp,64
    80004454:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004456:	0012c517          	auipc	a0,0x12c
    8000445a:	c9250513          	addi	a0,a0,-878 # 801300e8 <ftable>
    8000445e:	8a5fc0ef          	jal	80000d02 <acquire>
  if(f->ref < 1)
    80004462:	40dc                	lw	a5,4(s1)
    80004464:	04f05a63          	blez	a5,800044b8 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004468:	37fd                	addiw	a5,a5,-1
    8000446a:	0007871b          	sext.w	a4,a5
    8000446e:	c0dc                	sw	a5,4(s1)
    80004470:	04e04e63          	bgtz	a4,800044cc <fileclose+0x82>
    80004474:	f04a                	sd	s2,32(sp)
    80004476:	ec4e                	sd	s3,24(sp)
    80004478:	e852                	sd	s4,16(sp)
    8000447a:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000447c:	0004a903          	lw	s2,0(s1)
    80004480:	0094ca83          	lbu	s5,9(s1)
    80004484:	0104ba03          	ld	s4,16(s1)
    80004488:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000448c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004490:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004494:	0012c517          	auipc	a0,0x12c
    80004498:	c5450513          	addi	a0,a0,-940 # 801300e8 <ftable>
    8000449c:	8fffc0ef          	jal	80000d9a <release>

  if(ff.type == FD_PIPE){
    800044a0:	4785                	li	a5,1
    800044a2:	04f90063          	beq	s2,a5,800044e2 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800044a6:	3979                	addiw	s2,s2,-2
    800044a8:	4785                	li	a5,1
    800044aa:	0527f563          	bgeu	a5,s2,800044f4 <fileclose+0xaa>
    800044ae:	7902                	ld	s2,32(sp)
    800044b0:	69e2                	ld	s3,24(sp)
    800044b2:	6a42                	ld	s4,16(sp)
    800044b4:	6aa2                	ld	s5,8(sp)
    800044b6:	a00d                	j	800044d8 <fileclose+0x8e>
    800044b8:	f04a                	sd	s2,32(sp)
    800044ba:	ec4e                	sd	s3,24(sp)
    800044bc:	e852                	sd	s4,16(sp)
    800044be:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800044c0:	00003517          	auipc	a0,0x3
    800044c4:	0e050513          	addi	a0,a0,224 # 800075a0 <etext+0x5a0>
    800044c8:	b18fc0ef          	jal	800007e0 <panic>
    release(&ftable.lock);
    800044cc:	0012c517          	auipc	a0,0x12c
    800044d0:	c1c50513          	addi	a0,a0,-996 # 801300e8 <ftable>
    800044d4:	8c7fc0ef          	jal	80000d9a <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800044d8:	70e2                	ld	ra,56(sp)
    800044da:	7442                	ld	s0,48(sp)
    800044dc:	74a2                	ld	s1,40(sp)
    800044de:	6121                	addi	sp,sp,64
    800044e0:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800044e2:	85d6                	mv	a1,s5
    800044e4:	8552                	mv	a0,s4
    800044e6:	336000ef          	jal	8000481c <pipeclose>
    800044ea:	7902                	ld	s2,32(sp)
    800044ec:	69e2                	ld	s3,24(sp)
    800044ee:	6a42                	ld	s4,16(sp)
    800044f0:	6aa2                	ld	s5,8(sp)
    800044f2:	b7dd                	j	800044d8 <fileclose+0x8e>
    begin_op();
    800044f4:	b4bff0ef          	jal	8000403e <begin_op>
    iput(ff.ip);
    800044f8:	854e                	mv	a0,s3
    800044fa:	adcff0ef          	jal	800037d6 <iput>
    end_op();
    800044fe:	babff0ef          	jal	800040a8 <end_op>
    80004502:	7902                	ld	s2,32(sp)
    80004504:	69e2                	ld	s3,24(sp)
    80004506:	6a42                	ld	s4,16(sp)
    80004508:	6aa2                	ld	s5,8(sp)
    8000450a:	b7f9                	j	800044d8 <fileclose+0x8e>

000000008000450c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000450c:	715d                	addi	sp,sp,-80
    8000450e:	e486                	sd	ra,72(sp)
    80004510:	e0a2                	sd	s0,64(sp)
    80004512:	fc26                	sd	s1,56(sp)
    80004514:	f44e                	sd	s3,40(sp)
    80004516:	0880                	addi	s0,sp,80
    80004518:	84aa                	mv	s1,a0
    8000451a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000451c:	dbafd0ef          	jal	80001ad6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004520:	409c                	lw	a5,0(s1)
    80004522:	37f9                	addiw	a5,a5,-2
    80004524:	4705                	li	a4,1
    80004526:	04f76063          	bltu	a4,a5,80004566 <filestat+0x5a>
    8000452a:	f84a                	sd	s2,48(sp)
    8000452c:	892a                	mv	s2,a0
    ilock(f->ip);
    8000452e:	6c88                	ld	a0,24(s1)
    80004530:	924ff0ef          	jal	80003654 <ilock>
    stati(f->ip, &st);
    80004534:	fb840593          	addi	a1,s0,-72
    80004538:	6c88                	ld	a0,24(s1)
    8000453a:	c80ff0ef          	jal	800039ba <stati>
    iunlock(f->ip);
    8000453e:	6c88                	ld	a0,24(s1)
    80004540:	9c2ff0ef          	jal	80003702 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004544:	46e1                	li	a3,24
    80004546:	fb840613          	addi	a2,s0,-72
    8000454a:	85ce                	mv	a1,s3
    8000454c:	06893503          	ld	a0,104(s2)
    80004550:	b00fd0ef          	jal	80001850 <copyout>
    80004554:	41f5551b          	sraiw	a0,a0,0x1f
    80004558:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000455a:	60a6                	ld	ra,72(sp)
    8000455c:	6406                	ld	s0,64(sp)
    8000455e:	74e2                	ld	s1,56(sp)
    80004560:	79a2                	ld	s3,40(sp)
    80004562:	6161                	addi	sp,sp,80
    80004564:	8082                	ret
  return -1;
    80004566:	557d                	li	a0,-1
    80004568:	bfcd                	j	8000455a <filestat+0x4e>

000000008000456a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000456a:	7179                	addi	sp,sp,-48
    8000456c:	f406                	sd	ra,40(sp)
    8000456e:	f022                	sd	s0,32(sp)
    80004570:	e84a                	sd	s2,16(sp)
    80004572:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004574:	00854783          	lbu	a5,8(a0)
    80004578:	cfd1                	beqz	a5,80004614 <fileread+0xaa>
    8000457a:	ec26                	sd	s1,24(sp)
    8000457c:	e44e                	sd	s3,8(sp)
    8000457e:	84aa                	mv	s1,a0
    80004580:	89ae                	mv	s3,a1
    80004582:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004584:	411c                	lw	a5,0(a0)
    80004586:	4705                	li	a4,1
    80004588:	04e78363          	beq	a5,a4,800045ce <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000458c:	470d                	li	a4,3
    8000458e:	04e78763          	beq	a5,a4,800045dc <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004592:	4709                	li	a4,2
    80004594:	06e79a63          	bne	a5,a4,80004608 <fileread+0x9e>
    ilock(f->ip);
    80004598:	6d08                	ld	a0,24(a0)
    8000459a:	8baff0ef          	jal	80003654 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000459e:	874a                	mv	a4,s2
    800045a0:	5094                	lw	a3,32(s1)
    800045a2:	864e                	mv	a2,s3
    800045a4:	4585                	li	a1,1
    800045a6:	6c88                	ld	a0,24(s1)
    800045a8:	c3cff0ef          	jal	800039e4 <readi>
    800045ac:	892a                	mv	s2,a0
    800045ae:	00a05563          	blez	a0,800045b8 <fileread+0x4e>
      f->off += r;
    800045b2:	509c                	lw	a5,32(s1)
    800045b4:	9fa9                	addw	a5,a5,a0
    800045b6:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800045b8:	6c88                	ld	a0,24(s1)
    800045ba:	948ff0ef          	jal	80003702 <iunlock>
    800045be:	64e2                	ld	s1,24(sp)
    800045c0:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800045c2:	854a                	mv	a0,s2
    800045c4:	70a2                	ld	ra,40(sp)
    800045c6:	7402                	ld	s0,32(sp)
    800045c8:	6942                	ld	s2,16(sp)
    800045ca:	6145                	addi	sp,sp,48
    800045cc:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800045ce:	6908                	ld	a0,16(a0)
    800045d0:	388000ef          	jal	80004958 <piperead>
    800045d4:	892a                	mv	s2,a0
    800045d6:	64e2                	ld	s1,24(sp)
    800045d8:	69a2                	ld	s3,8(sp)
    800045da:	b7e5                	j	800045c2 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800045dc:	02451783          	lh	a5,36(a0)
    800045e0:	03079693          	slli	a3,a5,0x30
    800045e4:	92c1                	srli	a3,a3,0x30
    800045e6:	4725                	li	a4,9
    800045e8:	02d76863          	bltu	a4,a3,80004618 <fileread+0xae>
    800045ec:	0792                	slli	a5,a5,0x4
    800045ee:	0012c717          	auipc	a4,0x12c
    800045f2:	a5a70713          	addi	a4,a4,-1446 # 80130048 <devsw>
    800045f6:	97ba                	add	a5,a5,a4
    800045f8:	639c                	ld	a5,0(a5)
    800045fa:	c39d                	beqz	a5,80004620 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    800045fc:	4505                	li	a0,1
    800045fe:	9782                	jalr	a5
    80004600:	892a                	mv	s2,a0
    80004602:	64e2                	ld	s1,24(sp)
    80004604:	69a2                	ld	s3,8(sp)
    80004606:	bf75                	j	800045c2 <fileread+0x58>
    panic("fileread");
    80004608:	00003517          	auipc	a0,0x3
    8000460c:	fa850513          	addi	a0,a0,-88 # 800075b0 <etext+0x5b0>
    80004610:	9d0fc0ef          	jal	800007e0 <panic>
    return -1;
    80004614:	597d                	li	s2,-1
    80004616:	b775                	j	800045c2 <fileread+0x58>
      return -1;
    80004618:	597d                	li	s2,-1
    8000461a:	64e2                	ld	s1,24(sp)
    8000461c:	69a2                	ld	s3,8(sp)
    8000461e:	b755                	j	800045c2 <fileread+0x58>
    80004620:	597d                	li	s2,-1
    80004622:	64e2                	ld	s1,24(sp)
    80004624:	69a2                	ld	s3,8(sp)
    80004626:	bf71                	j	800045c2 <fileread+0x58>

0000000080004628 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004628:	00954783          	lbu	a5,9(a0)
    8000462c:	10078b63          	beqz	a5,80004742 <filewrite+0x11a>
{
    80004630:	715d                	addi	sp,sp,-80
    80004632:	e486                	sd	ra,72(sp)
    80004634:	e0a2                	sd	s0,64(sp)
    80004636:	f84a                	sd	s2,48(sp)
    80004638:	f052                	sd	s4,32(sp)
    8000463a:	e85a                	sd	s6,16(sp)
    8000463c:	0880                	addi	s0,sp,80
    8000463e:	892a                	mv	s2,a0
    80004640:	8b2e                	mv	s6,a1
    80004642:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004644:	411c                	lw	a5,0(a0)
    80004646:	4705                	li	a4,1
    80004648:	02e78763          	beq	a5,a4,80004676 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000464c:	470d                	li	a4,3
    8000464e:	02e78863          	beq	a5,a4,8000467e <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004652:	4709                	li	a4,2
    80004654:	0ce79c63          	bne	a5,a4,8000472c <filewrite+0x104>
    80004658:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000465a:	0ac05863          	blez	a2,8000470a <filewrite+0xe2>
    8000465e:	fc26                	sd	s1,56(sp)
    80004660:	ec56                	sd	s5,24(sp)
    80004662:	e45e                	sd	s7,8(sp)
    80004664:	e062                	sd	s8,0(sp)
    int i = 0;
    80004666:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004668:	6b85                	lui	s7,0x1
    8000466a:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000466e:	6c05                	lui	s8,0x1
    80004670:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004674:	a8b5                	j	800046f0 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    80004676:	6908                	ld	a0,16(a0)
    80004678:	1fc000ef          	jal	80004874 <pipewrite>
    8000467c:	a04d                	j	8000471e <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000467e:	02451783          	lh	a5,36(a0)
    80004682:	03079693          	slli	a3,a5,0x30
    80004686:	92c1                	srli	a3,a3,0x30
    80004688:	4725                	li	a4,9
    8000468a:	0ad76e63          	bltu	a4,a3,80004746 <filewrite+0x11e>
    8000468e:	0792                	slli	a5,a5,0x4
    80004690:	0012c717          	auipc	a4,0x12c
    80004694:	9b870713          	addi	a4,a4,-1608 # 80130048 <devsw>
    80004698:	97ba                	add	a5,a5,a4
    8000469a:	679c                	ld	a5,8(a5)
    8000469c:	c7dd                	beqz	a5,8000474a <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    8000469e:	4505                	li	a0,1
    800046a0:	9782                	jalr	a5
    800046a2:	a8b5                	j	8000471e <filewrite+0xf6>
      if(n1 > max)
    800046a4:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800046a8:	997ff0ef          	jal	8000403e <begin_op>
      ilock(f->ip);
    800046ac:	01893503          	ld	a0,24(s2)
    800046b0:	fa5fe0ef          	jal	80003654 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800046b4:	8756                	mv	a4,s5
    800046b6:	02092683          	lw	a3,32(s2)
    800046ba:	01698633          	add	a2,s3,s6
    800046be:	4585                	li	a1,1
    800046c0:	01893503          	ld	a0,24(s2)
    800046c4:	c1cff0ef          	jal	80003ae0 <writei>
    800046c8:	84aa                	mv	s1,a0
    800046ca:	00a05763          	blez	a0,800046d8 <filewrite+0xb0>
        f->off += r;
    800046ce:	02092783          	lw	a5,32(s2)
    800046d2:	9fa9                	addw	a5,a5,a0
    800046d4:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800046d8:	01893503          	ld	a0,24(s2)
    800046dc:	826ff0ef          	jal	80003702 <iunlock>
      end_op();
    800046e0:	9c9ff0ef          	jal	800040a8 <end_op>

      if(r != n1){
    800046e4:	029a9563          	bne	s5,s1,8000470e <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    800046e8:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800046ec:	0149da63          	bge	s3,s4,80004700 <filewrite+0xd8>
      int n1 = n - i;
    800046f0:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800046f4:	0004879b          	sext.w	a5,s1
    800046f8:	fafbd6e3          	bge	s7,a5,800046a4 <filewrite+0x7c>
    800046fc:	84e2                	mv	s1,s8
    800046fe:	b75d                	j	800046a4 <filewrite+0x7c>
    80004700:	74e2                	ld	s1,56(sp)
    80004702:	6ae2                	ld	s5,24(sp)
    80004704:	6ba2                	ld	s7,8(sp)
    80004706:	6c02                	ld	s8,0(sp)
    80004708:	a039                	j	80004716 <filewrite+0xee>
    int i = 0;
    8000470a:	4981                	li	s3,0
    8000470c:	a029                	j	80004716 <filewrite+0xee>
    8000470e:	74e2                	ld	s1,56(sp)
    80004710:	6ae2                	ld	s5,24(sp)
    80004712:	6ba2                	ld	s7,8(sp)
    80004714:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004716:	033a1c63          	bne	s4,s3,8000474e <filewrite+0x126>
    8000471a:	8552                	mv	a0,s4
    8000471c:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000471e:	60a6                	ld	ra,72(sp)
    80004720:	6406                	ld	s0,64(sp)
    80004722:	7942                	ld	s2,48(sp)
    80004724:	7a02                	ld	s4,32(sp)
    80004726:	6b42                	ld	s6,16(sp)
    80004728:	6161                	addi	sp,sp,80
    8000472a:	8082                	ret
    8000472c:	fc26                	sd	s1,56(sp)
    8000472e:	f44e                	sd	s3,40(sp)
    80004730:	ec56                	sd	s5,24(sp)
    80004732:	e45e                	sd	s7,8(sp)
    80004734:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004736:	00003517          	auipc	a0,0x3
    8000473a:	e8a50513          	addi	a0,a0,-374 # 800075c0 <etext+0x5c0>
    8000473e:	8a2fc0ef          	jal	800007e0 <panic>
    return -1;
    80004742:	557d                	li	a0,-1
}
    80004744:	8082                	ret
      return -1;
    80004746:	557d                	li	a0,-1
    80004748:	bfd9                	j	8000471e <filewrite+0xf6>
    8000474a:	557d                	li	a0,-1
    8000474c:	bfc9                	j	8000471e <filewrite+0xf6>
    ret = (i == n ? n : -1);
    8000474e:	557d                	li	a0,-1
    80004750:	79a2                	ld	s3,40(sp)
    80004752:	b7f1                	j	8000471e <filewrite+0xf6>

0000000080004754 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004754:	7179                	addi	sp,sp,-48
    80004756:	f406                	sd	ra,40(sp)
    80004758:	f022                	sd	s0,32(sp)
    8000475a:	ec26                	sd	s1,24(sp)
    8000475c:	e052                	sd	s4,0(sp)
    8000475e:	1800                	addi	s0,sp,48
    80004760:	84aa                	mv	s1,a0
    80004762:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004764:	0005b023          	sd	zero,0(a1)
    80004768:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000476c:	c3bff0ef          	jal	800043a6 <filealloc>
    80004770:	e088                	sd	a0,0(s1)
    80004772:	c549                	beqz	a0,800047fc <pipealloc+0xa8>
    80004774:	c33ff0ef          	jal	800043a6 <filealloc>
    80004778:	00aa3023          	sd	a0,0(s4)
    8000477c:	cd25                	beqz	a0,800047f4 <pipealloc+0xa0>
    8000477e:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004780:	bf2fc0ef          	jal	80000b72 <kalloc>
    80004784:	892a                	mv	s2,a0
    80004786:	c12d                	beqz	a0,800047e8 <pipealloc+0x94>
    80004788:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000478a:	4985                	li	s3,1
    8000478c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004790:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004794:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004798:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000479c:	00003597          	auipc	a1,0x3
    800047a0:	e3458593          	addi	a1,a1,-460 # 800075d0 <etext+0x5d0>
    800047a4:	cdefc0ef          	jal	80000c82 <initlock>
  (*f0)->type = FD_PIPE;
    800047a8:	609c                	ld	a5,0(s1)
    800047aa:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800047ae:	609c                	ld	a5,0(s1)
    800047b0:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800047b4:	609c                	ld	a5,0(s1)
    800047b6:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800047ba:	609c                	ld	a5,0(s1)
    800047bc:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800047c0:	000a3783          	ld	a5,0(s4)
    800047c4:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800047c8:	000a3783          	ld	a5,0(s4)
    800047cc:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800047d0:	000a3783          	ld	a5,0(s4)
    800047d4:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800047d8:	000a3783          	ld	a5,0(s4)
    800047dc:	0127b823          	sd	s2,16(a5)
  return 0;
    800047e0:	4501                	li	a0,0
    800047e2:	6942                	ld	s2,16(sp)
    800047e4:	69a2                	ld	s3,8(sp)
    800047e6:	a01d                	j	8000480c <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800047e8:	6088                	ld	a0,0(s1)
    800047ea:	c119                	beqz	a0,800047f0 <pipealloc+0x9c>
    800047ec:	6942                	ld	s2,16(sp)
    800047ee:	a029                	j	800047f8 <pipealloc+0xa4>
    800047f0:	6942                	ld	s2,16(sp)
    800047f2:	a029                	j	800047fc <pipealloc+0xa8>
    800047f4:	6088                	ld	a0,0(s1)
    800047f6:	c10d                	beqz	a0,80004818 <pipealloc+0xc4>
    fileclose(*f0);
    800047f8:	c53ff0ef          	jal	8000444a <fileclose>
  if(*f1)
    800047fc:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004800:	557d                	li	a0,-1
  if(*f1)
    80004802:	c789                	beqz	a5,8000480c <pipealloc+0xb8>
    fileclose(*f1);
    80004804:	853e                	mv	a0,a5
    80004806:	c45ff0ef          	jal	8000444a <fileclose>
  return -1;
    8000480a:	557d                	li	a0,-1
}
    8000480c:	70a2                	ld	ra,40(sp)
    8000480e:	7402                	ld	s0,32(sp)
    80004810:	64e2                	ld	s1,24(sp)
    80004812:	6a02                	ld	s4,0(sp)
    80004814:	6145                	addi	sp,sp,48
    80004816:	8082                	ret
  return -1;
    80004818:	557d                	li	a0,-1
    8000481a:	bfcd                	j	8000480c <pipealloc+0xb8>

000000008000481c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000481c:	1101                	addi	sp,sp,-32
    8000481e:	ec06                	sd	ra,24(sp)
    80004820:	e822                	sd	s0,16(sp)
    80004822:	e426                	sd	s1,8(sp)
    80004824:	e04a                	sd	s2,0(sp)
    80004826:	1000                	addi	s0,sp,32
    80004828:	84aa                	mv	s1,a0
    8000482a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000482c:	cd6fc0ef          	jal	80000d02 <acquire>
  if(writable){
    80004830:	02090763          	beqz	s2,8000485e <pipeclose+0x42>
    pi->writeopen = 0;
    80004834:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004838:	21848513          	addi	a0,s1,536
    8000483c:	98dfd0ef          	jal	800021c8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004840:	2204b783          	ld	a5,544(s1)
    80004844:	e785                	bnez	a5,8000486c <pipeclose+0x50>
    release(&pi->lock);
    80004846:	8526                	mv	a0,s1
    80004848:	d52fc0ef          	jal	80000d9a <release>
    kfree((char*)pi);
    8000484c:	8526                	mv	a0,s1
    8000484e:	9cefc0ef          	jal	80000a1c <kfree>
  } else
    release(&pi->lock);
}
    80004852:	60e2                	ld	ra,24(sp)
    80004854:	6442                	ld	s0,16(sp)
    80004856:	64a2                	ld	s1,8(sp)
    80004858:	6902                	ld	s2,0(sp)
    8000485a:	6105                	addi	sp,sp,32
    8000485c:	8082                	ret
    pi->readopen = 0;
    8000485e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004862:	21c48513          	addi	a0,s1,540
    80004866:	963fd0ef          	jal	800021c8 <wakeup>
    8000486a:	bfd9                	j	80004840 <pipeclose+0x24>
    release(&pi->lock);
    8000486c:	8526                	mv	a0,s1
    8000486e:	d2cfc0ef          	jal	80000d9a <release>
}
    80004872:	b7c5                	j	80004852 <pipeclose+0x36>

0000000080004874 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004874:	711d                	addi	sp,sp,-96
    80004876:	ec86                	sd	ra,88(sp)
    80004878:	e8a2                	sd	s0,80(sp)
    8000487a:	e4a6                	sd	s1,72(sp)
    8000487c:	e0ca                	sd	s2,64(sp)
    8000487e:	fc4e                	sd	s3,56(sp)
    80004880:	f852                	sd	s4,48(sp)
    80004882:	f456                	sd	s5,40(sp)
    80004884:	1080                	addi	s0,sp,96
    80004886:	84aa                	mv	s1,a0
    80004888:	8aae                	mv	s5,a1
    8000488a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000488c:	a4afd0ef          	jal	80001ad6 <myproc>
    80004890:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004892:	8526                	mv	a0,s1
    80004894:	c6efc0ef          	jal	80000d02 <acquire>
  while(i < n){
    80004898:	0b405a63          	blez	s4,8000494c <pipewrite+0xd8>
    8000489c:	f05a                	sd	s6,32(sp)
    8000489e:	ec5e                	sd	s7,24(sp)
    800048a0:	e862                	sd	s8,16(sp)
  int i = 0;
    800048a2:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800048a4:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800048a6:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800048aa:	21c48b93          	addi	s7,s1,540
    800048ae:	a81d                	j	800048e4 <pipewrite+0x70>
      release(&pi->lock);
    800048b0:	8526                	mv	a0,s1
    800048b2:	ce8fc0ef          	jal	80000d9a <release>
      return -1;
    800048b6:	597d                	li	s2,-1
    800048b8:	7b02                	ld	s6,32(sp)
    800048ba:	6be2                	ld	s7,24(sp)
    800048bc:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800048be:	854a                	mv	a0,s2
    800048c0:	60e6                	ld	ra,88(sp)
    800048c2:	6446                	ld	s0,80(sp)
    800048c4:	64a6                	ld	s1,72(sp)
    800048c6:	6906                	ld	s2,64(sp)
    800048c8:	79e2                	ld	s3,56(sp)
    800048ca:	7a42                	ld	s4,48(sp)
    800048cc:	7aa2                	ld	s5,40(sp)
    800048ce:	6125                	addi	sp,sp,96
    800048d0:	8082                	ret
      wakeup(&pi->nread);
    800048d2:	8562                	mv	a0,s8
    800048d4:	8f5fd0ef          	jal	800021c8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800048d8:	85a6                	mv	a1,s1
    800048da:	855e                	mv	a0,s7
    800048dc:	8a1fd0ef          	jal	8000217c <sleep>
  while(i < n){
    800048e0:	05495b63          	bge	s2,s4,80004936 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    800048e4:	2204a783          	lw	a5,544(s1)
    800048e8:	d7e1                	beqz	a5,800048b0 <pipewrite+0x3c>
    800048ea:	854e                	mv	a0,s3
    800048ec:	ac9fd0ef          	jal	800023b4 <killed>
    800048f0:	f161                	bnez	a0,800048b0 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800048f2:	2184a783          	lw	a5,536(s1)
    800048f6:	21c4a703          	lw	a4,540(s1)
    800048fa:	2007879b          	addiw	a5,a5,512
    800048fe:	fcf70ae3          	beq	a4,a5,800048d2 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004902:	4685                	li	a3,1
    80004904:	01590633          	add	a2,s2,s5
    80004908:	faf40593          	addi	a1,s0,-81
    8000490c:	0689b503          	ld	a0,104(s3)
    80004910:	e11fc0ef          	jal	80001720 <copyin>
    80004914:	03650e63          	beq	a0,s6,80004950 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004918:	21c4a783          	lw	a5,540(s1)
    8000491c:	0017871b          	addiw	a4,a5,1
    80004920:	20e4ae23          	sw	a4,540(s1)
    80004924:	1ff7f793          	andi	a5,a5,511
    80004928:	97a6                	add	a5,a5,s1
    8000492a:	faf44703          	lbu	a4,-81(s0)
    8000492e:	00e78c23          	sb	a4,24(a5)
      i++;
    80004932:	2905                	addiw	s2,s2,1
    80004934:	b775                	j	800048e0 <pipewrite+0x6c>
    80004936:	7b02                	ld	s6,32(sp)
    80004938:	6be2                	ld	s7,24(sp)
    8000493a:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    8000493c:	21848513          	addi	a0,s1,536
    80004940:	889fd0ef          	jal	800021c8 <wakeup>
  release(&pi->lock);
    80004944:	8526                	mv	a0,s1
    80004946:	c54fc0ef          	jal	80000d9a <release>
  return i;
    8000494a:	bf95                	j	800048be <pipewrite+0x4a>
  int i = 0;
    8000494c:	4901                	li	s2,0
    8000494e:	b7fd                	j	8000493c <pipewrite+0xc8>
    80004950:	7b02                	ld	s6,32(sp)
    80004952:	6be2                	ld	s7,24(sp)
    80004954:	6c42                	ld	s8,16(sp)
    80004956:	b7dd                	j	8000493c <pipewrite+0xc8>

0000000080004958 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004958:	715d                	addi	sp,sp,-80
    8000495a:	e486                	sd	ra,72(sp)
    8000495c:	e0a2                	sd	s0,64(sp)
    8000495e:	fc26                	sd	s1,56(sp)
    80004960:	f84a                	sd	s2,48(sp)
    80004962:	f44e                	sd	s3,40(sp)
    80004964:	f052                	sd	s4,32(sp)
    80004966:	ec56                	sd	s5,24(sp)
    80004968:	0880                	addi	s0,sp,80
    8000496a:	84aa                	mv	s1,a0
    8000496c:	892e                	mv	s2,a1
    8000496e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004970:	966fd0ef          	jal	80001ad6 <myproc>
    80004974:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004976:	8526                	mv	a0,s1
    80004978:	b8afc0ef          	jal	80000d02 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000497c:	2184a703          	lw	a4,536(s1)
    80004980:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004984:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004988:	02f71563          	bne	a4,a5,800049b2 <piperead+0x5a>
    8000498c:	2244a783          	lw	a5,548(s1)
    80004990:	cb85                	beqz	a5,800049c0 <piperead+0x68>
    if(killed(pr)){
    80004992:	8552                	mv	a0,s4
    80004994:	a21fd0ef          	jal	800023b4 <killed>
    80004998:	ed19                	bnez	a0,800049b6 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000499a:	85a6                	mv	a1,s1
    8000499c:	854e                	mv	a0,s3
    8000499e:	fdefd0ef          	jal	8000217c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800049a2:	2184a703          	lw	a4,536(s1)
    800049a6:	21c4a783          	lw	a5,540(s1)
    800049aa:	fef701e3          	beq	a4,a5,8000498c <piperead+0x34>
    800049ae:	e85a                	sd	s6,16(sp)
    800049b0:	a809                	j	800049c2 <piperead+0x6a>
    800049b2:	e85a                	sd	s6,16(sp)
    800049b4:	a039                	j	800049c2 <piperead+0x6a>
      release(&pi->lock);
    800049b6:	8526                	mv	a0,s1
    800049b8:	be2fc0ef          	jal	80000d9a <release>
      return -1;
    800049bc:	59fd                	li	s3,-1
    800049be:	a8b9                	j	80004a1c <piperead+0xc4>
    800049c0:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800049c2:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800049c4:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800049c6:	05505363          	blez	s5,80004a0c <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    800049ca:	2184a783          	lw	a5,536(s1)
    800049ce:	21c4a703          	lw	a4,540(s1)
    800049d2:	02f70d63          	beq	a4,a5,80004a0c <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    800049d6:	1ff7f793          	andi	a5,a5,511
    800049da:	97a6                	add	a5,a5,s1
    800049dc:	0187c783          	lbu	a5,24(a5)
    800049e0:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800049e4:	4685                	li	a3,1
    800049e6:	fbf40613          	addi	a2,s0,-65
    800049ea:	85ca                	mv	a1,s2
    800049ec:	068a3503          	ld	a0,104(s4)
    800049f0:	e61fc0ef          	jal	80001850 <copyout>
    800049f4:	03650e63          	beq	a0,s6,80004a30 <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800049f8:	2184a783          	lw	a5,536(s1)
    800049fc:	2785                	addiw	a5,a5,1
    800049fe:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004a02:	2985                	addiw	s3,s3,1
    80004a04:	0905                	addi	s2,s2,1
    80004a06:	fd3a92e3          	bne	s5,s3,800049ca <piperead+0x72>
    80004a0a:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004a0c:	21c48513          	addi	a0,s1,540
    80004a10:	fb8fd0ef          	jal	800021c8 <wakeup>
  release(&pi->lock);
    80004a14:	8526                	mv	a0,s1
    80004a16:	b84fc0ef          	jal	80000d9a <release>
    80004a1a:	6b42                	ld	s6,16(sp)
  return i;
}
    80004a1c:	854e                	mv	a0,s3
    80004a1e:	60a6                	ld	ra,72(sp)
    80004a20:	6406                	ld	s0,64(sp)
    80004a22:	74e2                	ld	s1,56(sp)
    80004a24:	7942                	ld	s2,48(sp)
    80004a26:	79a2                	ld	s3,40(sp)
    80004a28:	7a02                	ld	s4,32(sp)
    80004a2a:	6ae2                	ld	s5,24(sp)
    80004a2c:	6161                	addi	sp,sp,80
    80004a2e:	8082                	ret
      if(i == 0)
    80004a30:	fc099ee3          	bnez	s3,80004a0c <piperead+0xb4>
        i = -1;
    80004a34:	89aa                	mv	s3,a0
    80004a36:	bfd9                	j	80004a0c <piperead+0xb4>

0000000080004a38 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004a38:	1141                	addi	sp,sp,-16
    80004a3a:	e422                	sd	s0,8(sp)
    80004a3c:	0800                	addi	s0,sp,16
    80004a3e:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004a40:	8905                	andi	a0,a0,1
    80004a42:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004a44:	8b89                	andi	a5,a5,2
    80004a46:	c399                	beqz	a5,80004a4c <flags2perm+0x14>
      perm |= PTE_W;
    80004a48:	00456513          	ori	a0,a0,4
    return perm;
}
    80004a4c:	6422                	ld	s0,8(sp)
    80004a4e:	0141                	addi	sp,sp,16
    80004a50:	8082                	ret

0000000080004a52 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004a52:	df010113          	addi	sp,sp,-528
    80004a56:	20113423          	sd	ra,520(sp)
    80004a5a:	20813023          	sd	s0,512(sp)
    80004a5e:	ffa6                	sd	s1,504(sp)
    80004a60:	fbca                	sd	s2,496(sp)
    80004a62:	0c00                	addi	s0,sp,528
    80004a64:	892a                	mv	s2,a0
    80004a66:	dea43c23          	sd	a0,-520(s0)
    80004a6a:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004a6e:	868fd0ef          	jal	80001ad6 <myproc>
    80004a72:	84aa                	mv	s1,a0

  begin_op();
    80004a74:	dcaff0ef          	jal	8000403e <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004a78:	854a                	mv	a0,s2
    80004a7a:	bf0ff0ef          	jal	80003e6a <namei>
    80004a7e:	c931                	beqz	a0,80004ad2 <kexec+0x80>
    80004a80:	f3d2                	sd	s4,480(sp)
    80004a82:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004a84:	bd1fe0ef          	jal	80003654 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004a88:	04000713          	li	a4,64
    80004a8c:	4681                	li	a3,0
    80004a8e:	e5040613          	addi	a2,s0,-432
    80004a92:	4581                	li	a1,0
    80004a94:	8552                	mv	a0,s4
    80004a96:	f4ffe0ef          	jal	800039e4 <readi>
    80004a9a:	04000793          	li	a5,64
    80004a9e:	00f51a63          	bne	a0,a5,80004ab2 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004aa2:	e5042703          	lw	a4,-432(s0)
    80004aa6:	464c47b7          	lui	a5,0x464c4
    80004aaa:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004aae:	02f70663          	beq	a4,a5,80004ada <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004ab2:	8552                	mv	a0,s4
    80004ab4:	dabfe0ef          	jal	8000385e <iunlockput>
    end_op();
    80004ab8:	df0ff0ef          	jal	800040a8 <end_op>
  }
  return -1;
    80004abc:	557d                	li	a0,-1
    80004abe:	7a1e                	ld	s4,480(sp)
}
    80004ac0:	20813083          	ld	ra,520(sp)
    80004ac4:	20013403          	ld	s0,512(sp)
    80004ac8:	74fe                	ld	s1,504(sp)
    80004aca:	795e                	ld	s2,496(sp)
    80004acc:	21010113          	addi	sp,sp,528
    80004ad0:	8082                	ret
    end_op();
    80004ad2:	dd6ff0ef          	jal	800040a8 <end_op>
    return -1;
    80004ad6:	557d                	li	a0,-1
    80004ad8:	b7e5                	j	80004ac0 <kexec+0x6e>
    80004ada:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004adc:	8526                	mv	a0,s1
    80004ade:	8fefd0ef          	jal	80001bdc <proc_pagetable>
    80004ae2:	8b2a                	mv	s6,a0
    80004ae4:	2c050b63          	beqz	a0,80004dba <kexec+0x368>
    80004ae8:	f7ce                	sd	s3,488(sp)
    80004aea:	efd6                	sd	s5,472(sp)
    80004aec:	e7de                	sd	s7,456(sp)
    80004aee:	e3e2                	sd	s8,448(sp)
    80004af0:	ff66                	sd	s9,440(sp)
    80004af2:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004af4:	e7042d03          	lw	s10,-400(s0)
    80004af8:	e8845783          	lhu	a5,-376(s0)
    80004afc:	12078963          	beqz	a5,80004c2e <kexec+0x1dc>
    80004b00:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004b02:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004b04:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004b06:	6c85                	lui	s9,0x1
    80004b08:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004b0c:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004b10:	6a85                	lui	s5,0x1
    80004b12:	a085                	j	80004b72 <kexec+0x120>
      panic("loadseg: address should exist");
    80004b14:	00003517          	auipc	a0,0x3
    80004b18:	ac450513          	addi	a0,a0,-1340 # 800075d8 <etext+0x5d8>
    80004b1c:	cc5fb0ef          	jal	800007e0 <panic>
    if(sz - i < PGSIZE)
    80004b20:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004b22:	8726                	mv	a4,s1
    80004b24:	012c06bb          	addw	a3,s8,s2
    80004b28:	4581                	li	a1,0
    80004b2a:	8552                	mv	a0,s4
    80004b2c:	eb9fe0ef          	jal	800039e4 <readi>
    80004b30:	2501                	sext.w	a0,a0
    80004b32:	24a49a63          	bne	s1,a0,80004d86 <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80004b36:	012a893b          	addw	s2,s5,s2
    80004b3a:	03397363          	bgeu	s2,s3,80004b60 <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80004b3e:	02091593          	slli	a1,s2,0x20
    80004b42:	9181                	srli	a1,a1,0x20
    80004b44:	95de                	add	a1,a1,s7
    80004b46:	855a                	mv	a0,s6
    80004b48:	d9cfc0ef          	jal	800010e4 <walkaddr>
    80004b4c:	862a                	mv	a2,a0
    if(pa == 0)
    80004b4e:	d179                	beqz	a0,80004b14 <kexec+0xc2>
    if(sz - i < PGSIZE)
    80004b50:	412984bb          	subw	s1,s3,s2
    80004b54:	0004879b          	sext.w	a5,s1
    80004b58:	fcfcf4e3          	bgeu	s9,a5,80004b20 <kexec+0xce>
    80004b5c:	84d6                	mv	s1,s5
    80004b5e:	b7c9                	j	80004b20 <kexec+0xce>
    sz = sz1;
    80004b60:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004b64:	2d85                	addiw	s11,s11,1
    80004b66:	038d0d1b          	addiw	s10,s10,56
    80004b6a:	e8845783          	lhu	a5,-376(s0)
    80004b6e:	08fdd063          	bge	s11,a5,80004bee <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004b72:	2d01                	sext.w	s10,s10
    80004b74:	03800713          	li	a4,56
    80004b78:	86ea                	mv	a3,s10
    80004b7a:	e1840613          	addi	a2,s0,-488
    80004b7e:	4581                	li	a1,0
    80004b80:	8552                	mv	a0,s4
    80004b82:	e63fe0ef          	jal	800039e4 <readi>
    80004b86:	03800793          	li	a5,56
    80004b8a:	1cf51663          	bne	a0,a5,80004d56 <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80004b8e:	e1842783          	lw	a5,-488(s0)
    80004b92:	4705                	li	a4,1
    80004b94:	fce798e3          	bne	a5,a4,80004b64 <kexec+0x112>
    if(ph.memsz < ph.filesz)
    80004b98:	e4043483          	ld	s1,-448(s0)
    80004b9c:	e3843783          	ld	a5,-456(s0)
    80004ba0:	1af4ef63          	bltu	s1,a5,80004d5e <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004ba4:	e2843783          	ld	a5,-472(s0)
    80004ba8:	94be                	add	s1,s1,a5
    80004baa:	1af4ee63          	bltu	s1,a5,80004d66 <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80004bae:	df043703          	ld	a4,-528(s0)
    80004bb2:	8ff9                	and	a5,a5,a4
    80004bb4:	1a079d63          	bnez	a5,80004d6e <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004bb8:	e1c42503          	lw	a0,-484(s0)
    80004bbc:	e7dff0ef          	jal	80004a38 <flags2perm>
    80004bc0:	86aa                	mv	a3,a0
    80004bc2:	8626                	mv	a2,s1
    80004bc4:	85ca                	mv	a1,s2
    80004bc6:	855a                	mv	a0,s6
    80004bc8:	ff4fc0ef          	jal	800013bc <uvmalloc>
    80004bcc:	e0a43423          	sd	a0,-504(s0)
    80004bd0:	1a050363          	beqz	a0,80004d76 <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004bd4:	e2843b83          	ld	s7,-472(s0)
    80004bd8:	e2042c03          	lw	s8,-480(s0)
    80004bdc:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004be0:	00098463          	beqz	s3,80004be8 <kexec+0x196>
    80004be4:	4901                	li	s2,0
    80004be6:	bfa1                	j	80004b3e <kexec+0xec>
    sz = sz1;
    80004be8:	e0843903          	ld	s2,-504(s0)
    80004bec:	bfa5                	j	80004b64 <kexec+0x112>
    80004bee:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004bf0:	8552                	mv	a0,s4
    80004bf2:	c6dfe0ef          	jal	8000385e <iunlockput>
  end_op();
    80004bf6:	cb2ff0ef          	jal	800040a8 <end_op>
  p = myproc();
    80004bfa:	eddfc0ef          	jal	80001ad6 <myproc>
    80004bfe:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004c00:	06053c83          	ld	s9,96(a0)
  sz = PGROUNDUP(sz);
    80004c04:	6985                	lui	s3,0x1
    80004c06:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004c08:	99ca                	add	s3,s3,s2
    80004c0a:	77fd                	lui	a5,0xfffff
    80004c0c:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004c10:	4691                	li	a3,4
    80004c12:	6609                	lui	a2,0x2
    80004c14:	964e                	add	a2,a2,s3
    80004c16:	85ce                	mv	a1,s3
    80004c18:	855a                	mv	a0,s6
    80004c1a:	fa2fc0ef          	jal	800013bc <uvmalloc>
    80004c1e:	892a                	mv	s2,a0
    80004c20:	e0a43423          	sd	a0,-504(s0)
    80004c24:	e519                	bnez	a0,80004c32 <kexec+0x1e0>
  if(pagetable)
    80004c26:	e1343423          	sd	s3,-504(s0)
    80004c2a:	4a01                	li	s4,0
    80004c2c:	aab1                	j	80004d88 <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004c2e:	4901                	li	s2,0
    80004c30:	b7c1                	j	80004bf0 <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004c32:	75f9                	lui	a1,0xffffe
    80004c34:	95aa                	add	a1,a1,a0
    80004c36:	855a                	mv	a0,s6
    80004c38:	965fc0ef          	jal	8000159c <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004c3c:	7bfd                	lui	s7,0xfffff
    80004c3e:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004c40:	e0043783          	ld	a5,-512(s0)
    80004c44:	6388                	ld	a0,0(a5)
    80004c46:	cd39                	beqz	a0,80004ca4 <kexec+0x252>
    80004c48:	e9040993          	addi	s3,s0,-368
    80004c4c:	f9040c13          	addi	s8,s0,-112
    80004c50:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004c52:	af4fc0ef          	jal	80000f46 <strlen>
    80004c56:	0015079b          	addiw	a5,a0,1
    80004c5a:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004c5e:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004c62:	11796e63          	bltu	s2,s7,80004d7e <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004c66:	e0043d03          	ld	s10,-512(s0)
    80004c6a:	000d3a03          	ld	s4,0(s10)
    80004c6e:	8552                	mv	a0,s4
    80004c70:	ad6fc0ef          	jal	80000f46 <strlen>
    80004c74:	0015069b          	addiw	a3,a0,1
    80004c78:	8652                	mv	a2,s4
    80004c7a:	85ca                	mv	a1,s2
    80004c7c:	855a                	mv	a0,s6
    80004c7e:	bd3fc0ef          	jal	80001850 <copyout>
    80004c82:	10054063          	bltz	a0,80004d82 <kexec+0x330>
    ustack[argc] = sp;
    80004c86:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004c8a:	0485                	addi	s1,s1,1
    80004c8c:	008d0793          	addi	a5,s10,8
    80004c90:	e0f43023          	sd	a5,-512(s0)
    80004c94:	008d3503          	ld	a0,8(s10)
    80004c98:	c909                	beqz	a0,80004caa <kexec+0x258>
    if(argc >= MAXARG)
    80004c9a:	09a1                	addi	s3,s3,8
    80004c9c:	fb899be3          	bne	s3,s8,80004c52 <kexec+0x200>
  ip = 0;
    80004ca0:	4a01                	li	s4,0
    80004ca2:	a0dd                	j	80004d88 <kexec+0x336>
  sp = sz;
    80004ca4:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004ca8:	4481                	li	s1,0
  ustack[argc] = 0;
    80004caa:	00349793          	slli	a5,s1,0x3
    80004cae:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7fecddb0>
    80004cb2:	97a2                	add	a5,a5,s0
    80004cb4:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004cb8:	00148693          	addi	a3,s1,1
    80004cbc:	068e                	slli	a3,a3,0x3
    80004cbe:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004cc2:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004cc6:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004cca:	f5796ee3          	bltu	s2,s7,80004c26 <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004cce:	e9040613          	addi	a2,s0,-368
    80004cd2:	85ca                	mv	a1,s2
    80004cd4:	855a                	mv	a0,s6
    80004cd6:	b7bfc0ef          	jal	80001850 <copyout>
    80004cda:	0e054263          	bltz	a0,80004dbe <kexec+0x36c>
  p->trapframe->a1 = sp;
    80004cde:	070ab783          	ld	a5,112(s5) # 1070 <_entry-0x7fffef90>
    80004ce2:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004ce6:	df843783          	ld	a5,-520(s0)
    80004cea:	0007c703          	lbu	a4,0(a5)
    80004cee:	cf11                	beqz	a4,80004d0a <kexec+0x2b8>
    80004cf0:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004cf2:	02f00693          	li	a3,47
    80004cf6:	a039                	j	80004d04 <kexec+0x2b2>
      last = s+1;
    80004cf8:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004cfc:	0785                	addi	a5,a5,1
    80004cfe:	fff7c703          	lbu	a4,-1(a5)
    80004d02:	c701                	beqz	a4,80004d0a <kexec+0x2b8>
    if(*s == '/')
    80004d04:	fed71ce3          	bne	a4,a3,80004cfc <kexec+0x2aa>
    80004d08:	bfc5                	j	80004cf8 <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004d0a:	4641                	li	a2,16
    80004d0c:	df843583          	ld	a1,-520(s0)
    80004d10:	170a8513          	addi	a0,s5,368
    80004d14:	a00fc0ef          	jal	80000f14 <safestrcpy>
  oldpagetable = p->pagetable;
    80004d18:	068ab503          	ld	a0,104(s5)
  p->pagetable = pagetable;
    80004d1c:	076ab423          	sd	s6,104(s5)
  p->sz = sz;
    80004d20:	e0843783          	ld	a5,-504(s0)
    80004d24:	06fab023          	sd	a5,96(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004d28:	070ab783          	ld	a5,112(s5)
    80004d2c:	e6843703          	ld	a4,-408(s0)
    80004d30:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004d32:	070ab783          	ld	a5,112(s5)
    80004d36:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004d3a:	85e6                	mv	a1,s9
    80004d3c:	f25fc0ef          	jal	80001c60 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004d40:	0004851b          	sext.w	a0,s1
    80004d44:	79be                	ld	s3,488(sp)
    80004d46:	7a1e                	ld	s4,480(sp)
    80004d48:	6afe                	ld	s5,472(sp)
    80004d4a:	6b5e                	ld	s6,464(sp)
    80004d4c:	6bbe                	ld	s7,456(sp)
    80004d4e:	6c1e                	ld	s8,448(sp)
    80004d50:	7cfa                	ld	s9,440(sp)
    80004d52:	7d5a                	ld	s10,432(sp)
    80004d54:	b3b5                	j	80004ac0 <kexec+0x6e>
    80004d56:	e1243423          	sd	s2,-504(s0)
    80004d5a:	7dba                	ld	s11,424(sp)
    80004d5c:	a035                	j	80004d88 <kexec+0x336>
    80004d5e:	e1243423          	sd	s2,-504(s0)
    80004d62:	7dba                	ld	s11,424(sp)
    80004d64:	a015                	j	80004d88 <kexec+0x336>
    80004d66:	e1243423          	sd	s2,-504(s0)
    80004d6a:	7dba                	ld	s11,424(sp)
    80004d6c:	a831                	j	80004d88 <kexec+0x336>
    80004d6e:	e1243423          	sd	s2,-504(s0)
    80004d72:	7dba                	ld	s11,424(sp)
    80004d74:	a811                	j	80004d88 <kexec+0x336>
    80004d76:	e1243423          	sd	s2,-504(s0)
    80004d7a:	7dba                	ld	s11,424(sp)
    80004d7c:	a031                	j	80004d88 <kexec+0x336>
  ip = 0;
    80004d7e:	4a01                	li	s4,0
    80004d80:	a021                	j	80004d88 <kexec+0x336>
    80004d82:	4a01                	li	s4,0
  if(pagetable)
    80004d84:	a011                	j	80004d88 <kexec+0x336>
    80004d86:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004d88:	e0843583          	ld	a1,-504(s0)
    80004d8c:	855a                	mv	a0,s6
    80004d8e:	ed3fc0ef          	jal	80001c60 <proc_freepagetable>
  return -1;
    80004d92:	557d                	li	a0,-1
  if(ip){
    80004d94:	000a1b63          	bnez	s4,80004daa <kexec+0x358>
    80004d98:	79be                	ld	s3,488(sp)
    80004d9a:	7a1e                	ld	s4,480(sp)
    80004d9c:	6afe                	ld	s5,472(sp)
    80004d9e:	6b5e                	ld	s6,464(sp)
    80004da0:	6bbe                	ld	s7,456(sp)
    80004da2:	6c1e                	ld	s8,448(sp)
    80004da4:	7cfa                	ld	s9,440(sp)
    80004da6:	7d5a                	ld	s10,432(sp)
    80004da8:	bb21                	j	80004ac0 <kexec+0x6e>
    80004daa:	79be                	ld	s3,488(sp)
    80004dac:	6afe                	ld	s5,472(sp)
    80004dae:	6b5e                	ld	s6,464(sp)
    80004db0:	6bbe                	ld	s7,456(sp)
    80004db2:	6c1e                	ld	s8,448(sp)
    80004db4:	7cfa                	ld	s9,440(sp)
    80004db6:	7d5a                	ld	s10,432(sp)
    80004db8:	b9ed                	j	80004ab2 <kexec+0x60>
    80004dba:	6b5e                	ld	s6,464(sp)
    80004dbc:	b9dd                	j	80004ab2 <kexec+0x60>
  sz = sz1;
    80004dbe:	e0843983          	ld	s3,-504(s0)
    80004dc2:	b595                	j	80004c26 <kexec+0x1d4>

0000000080004dc4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004dc4:	7179                	addi	sp,sp,-48
    80004dc6:	f406                	sd	ra,40(sp)
    80004dc8:	f022                	sd	s0,32(sp)
    80004dca:	ec26                	sd	s1,24(sp)
    80004dcc:	e84a                	sd	s2,16(sp)
    80004dce:	1800                	addi	s0,sp,48
    80004dd0:	892e                	mv	s2,a1
    80004dd2:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004dd4:	fdc40593          	addi	a1,s0,-36
    80004dd8:	dc3fd0ef          	jal	80002b9a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004ddc:	fdc42703          	lw	a4,-36(s0)
    80004de0:	47bd                	li	a5,15
    80004de2:	02e7e963          	bltu	a5,a4,80004e14 <argfd+0x50>
    80004de6:	cf1fc0ef          	jal	80001ad6 <myproc>
    80004dea:	fdc42703          	lw	a4,-36(s0)
    80004dee:	01c70793          	addi	a5,a4,28
    80004df2:	078e                	slli	a5,a5,0x3
    80004df4:	953e                	add	a0,a0,a5
    80004df6:	651c                	ld	a5,8(a0)
    80004df8:	c385                	beqz	a5,80004e18 <argfd+0x54>
    return -1;
  if(pfd)
    80004dfa:	00090463          	beqz	s2,80004e02 <argfd+0x3e>
    *pfd = fd;
    80004dfe:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004e02:	4501                	li	a0,0
  if(pf)
    80004e04:	c091                	beqz	s1,80004e08 <argfd+0x44>
    *pf = f;
    80004e06:	e09c                	sd	a5,0(s1)
}
    80004e08:	70a2                	ld	ra,40(sp)
    80004e0a:	7402                	ld	s0,32(sp)
    80004e0c:	64e2                	ld	s1,24(sp)
    80004e0e:	6942                	ld	s2,16(sp)
    80004e10:	6145                	addi	sp,sp,48
    80004e12:	8082                	ret
    return -1;
    80004e14:	557d                	li	a0,-1
    80004e16:	bfcd                	j	80004e08 <argfd+0x44>
    80004e18:	557d                	li	a0,-1
    80004e1a:	b7fd                	j	80004e08 <argfd+0x44>

0000000080004e1c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004e1c:	1101                	addi	sp,sp,-32
    80004e1e:	ec06                	sd	ra,24(sp)
    80004e20:	e822                	sd	s0,16(sp)
    80004e22:	e426                	sd	s1,8(sp)
    80004e24:	1000                	addi	s0,sp,32
    80004e26:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004e28:	caffc0ef          	jal	80001ad6 <myproc>
    80004e2c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004e2e:	0e850793          	addi	a5,a0,232
    80004e32:	4501                	li	a0,0
    80004e34:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004e36:	6398                	ld	a4,0(a5)
    80004e38:	cb19                	beqz	a4,80004e4e <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004e3a:	2505                	addiw	a0,a0,1
    80004e3c:	07a1                	addi	a5,a5,8
    80004e3e:	fed51ce3          	bne	a0,a3,80004e36 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004e42:	557d                	li	a0,-1
}
    80004e44:	60e2                	ld	ra,24(sp)
    80004e46:	6442                	ld	s0,16(sp)
    80004e48:	64a2                	ld	s1,8(sp)
    80004e4a:	6105                	addi	sp,sp,32
    80004e4c:	8082                	ret
      p->ofile[fd] = f;
    80004e4e:	01c50793          	addi	a5,a0,28
    80004e52:	078e                	slli	a5,a5,0x3
    80004e54:	963e                	add	a2,a2,a5
    80004e56:	e604                	sd	s1,8(a2)
      return fd;
    80004e58:	b7f5                	j	80004e44 <fdalloc+0x28>

0000000080004e5a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004e5a:	715d                	addi	sp,sp,-80
    80004e5c:	e486                	sd	ra,72(sp)
    80004e5e:	e0a2                	sd	s0,64(sp)
    80004e60:	fc26                	sd	s1,56(sp)
    80004e62:	f84a                	sd	s2,48(sp)
    80004e64:	f44e                	sd	s3,40(sp)
    80004e66:	ec56                	sd	s5,24(sp)
    80004e68:	e85a                	sd	s6,16(sp)
    80004e6a:	0880                	addi	s0,sp,80
    80004e6c:	8b2e                	mv	s6,a1
    80004e6e:	89b2                	mv	s3,a2
    80004e70:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004e72:	fb040593          	addi	a1,s0,-80
    80004e76:	80eff0ef          	jal	80003e84 <nameiparent>
    80004e7a:	84aa                	mv	s1,a0
    80004e7c:	10050a63          	beqz	a0,80004f90 <create+0x136>
    return 0;

  ilock(dp);
    80004e80:	fd4fe0ef          	jal	80003654 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004e84:	4601                	li	a2,0
    80004e86:	fb040593          	addi	a1,s0,-80
    80004e8a:	8526                	mv	a0,s1
    80004e8c:	d79fe0ef          	jal	80003c04 <dirlookup>
    80004e90:	8aaa                	mv	s5,a0
    80004e92:	c129                	beqz	a0,80004ed4 <create+0x7a>
    iunlockput(dp);
    80004e94:	8526                	mv	a0,s1
    80004e96:	9c9fe0ef          	jal	8000385e <iunlockput>
    ilock(ip);
    80004e9a:	8556                	mv	a0,s5
    80004e9c:	fb8fe0ef          	jal	80003654 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004ea0:	4789                	li	a5,2
    80004ea2:	02fb1463          	bne	s6,a5,80004eca <create+0x70>
    80004ea6:	044ad783          	lhu	a5,68(s5)
    80004eaa:	37f9                	addiw	a5,a5,-2
    80004eac:	17c2                	slli	a5,a5,0x30
    80004eae:	93c1                	srli	a5,a5,0x30
    80004eb0:	4705                	li	a4,1
    80004eb2:	00f76c63          	bltu	a4,a5,80004eca <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004eb6:	8556                	mv	a0,s5
    80004eb8:	60a6                	ld	ra,72(sp)
    80004eba:	6406                	ld	s0,64(sp)
    80004ebc:	74e2                	ld	s1,56(sp)
    80004ebe:	7942                	ld	s2,48(sp)
    80004ec0:	79a2                	ld	s3,40(sp)
    80004ec2:	6ae2                	ld	s5,24(sp)
    80004ec4:	6b42                	ld	s6,16(sp)
    80004ec6:	6161                	addi	sp,sp,80
    80004ec8:	8082                	ret
    iunlockput(ip);
    80004eca:	8556                	mv	a0,s5
    80004ecc:	993fe0ef          	jal	8000385e <iunlockput>
    return 0;
    80004ed0:	4a81                	li	s5,0
    80004ed2:	b7d5                	j	80004eb6 <create+0x5c>
    80004ed4:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004ed6:	85da                	mv	a1,s6
    80004ed8:	4088                	lw	a0,0(s1)
    80004eda:	e0afe0ef          	jal	800034e4 <ialloc>
    80004ede:	8a2a                	mv	s4,a0
    80004ee0:	cd15                	beqz	a0,80004f1c <create+0xc2>
  ilock(ip);
    80004ee2:	f72fe0ef          	jal	80003654 <ilock>
  ip->major = major;
    80004ee6:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004eea:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004eee:	4905                	li	s2,1
    80004ef0:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004ef4:	8552                	mv	a0,s4
    80004ef6:	eaafe0ef          	jal	800035a0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004efa:	032b0763          	beq	s6,s2,80004f28 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004efe:	004a2603          	lw	a2,4(s4)
    80004f02:	fb040593          	addi	a1,s0,-80
    80004f06:	8526                	mv	a0,s1
    80004f08:	ec9fe0ef          	jal	80003dd0 <dirlink>
    80004f0c:	06054563          	bltz	a0,80004f76 <create+0x11c>
  iunlockput(dp);
    80004f10:	8526                	mv	a0,s1
    80004f12:	94dfe0ef          	jal	8000385e <iunlockput>
  return ip;
    80004f16:	8ad2                	mv	s5,s4
    80004f18:	7a02                	ld	s4,32(sp)
    80004f1a:	bf71                	j	80004eb6 <create+0x5c>
    iunlockput(dp);
    80004f1c:	8526                	mv	a0,s1
    80004f1e:	941fe0ef          	jal	8000385e <iunlockput>
    return 0;
    80004f22:	8ad2                	mv	s5,s4
    80004f24:	7a02                	ld	s4,32(sp)
    80004f26:	bf41                	j	80004eb6 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004f28:	004a2603          	lw	a2,4(s4)
    80004f2c:	00002597          	auipc	a1,0x2
    80004f30:	6cc58593          	addi	a1,a1,1740 # 800075f8 <etext+0x5f8>
    80004f34:	8552                	mv	a0,s4
    80004f36:	e9bfe0ef          	jal	80003dd0 <dirlink>
    80004f3a:	02054e63          	bltz	a0,80004f76 <create+0x11c>
    80004f3e:	40d0                	lw	a2,4(s1)
    80004f40:	00002597          	auipc	a1,0x2
    80004f44:	6c058593          	addi	a1,a1,1728 # 80007600 <etext+0x600>
    80004f48:	8552                	mv	a0,s4
    80004f4a:	e87fe0ef          	jal	80003dd0 <dirlink>
    80004f4e:	02054463          	bltz	a0,80004f76 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004f52:	004a2603          	lw	a2,4(s4)
    80004f56:	fb040593          	addi	a1,s0,-80
    80004f5a:	8526                	mv	a0,s1
    80004f5c:	e75fe0ef          	jal	80003dd0 <dirlink>
    80004f60:	00054b63          	bltz	a0,80004f76 <create+0x11c>
    dp->nlink++;  // for ".."
    80004f64:	04a4d783          	lhu	a5,74(s1)
    80004f68:	2785                	addiw	a5,a5,1
    80004f6a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004f6e:	8526                	mv	a0,s1
    80004f70:	e30fe0ef          	jal	800035a0 <iupdate>
    80004f74:	bf71                	j	80004f10 <create+0xb6>
  ip->nlink = 0;
    80004f76:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004f7a:	8552                	mv	a0,s4
    80004f7c:	e24fe0ef          	jal	800035a0 <iupdate>
  iunlockput(ip);
    80004f80:	8552                	mv	a0,s4
    80004f82:	8ddfe0ef          	jal	8000385e <iunlockput>
  iunlockput(dp);
    80004f86:	8526                	mv	a0,s1
    80004f88:	8d7fe0ef          	jal	8000385e <iunlockput>
  return 0;
    80004f8c:	7a02                	ld	s4,32(sp)
    80004f8e:	b725                	j	80004eb6 <create+0x5c>
    return 0;
    80004f90:	8aaa                	mv	s5,a0
    80004f92:	b715                	j	80004eb6 <create+0x5c>

0000000080004f94 <sys_dup>:
{
    80004f94:	7179                	addi	sp,sp,-48
    80004f96:	f406                	sd	ra,40(sp)
    80004f98:	f022                	sd	s0,32(sp)
    80004f9a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004f9c:	fd840613          	addi	a2,s0,-40
    80004fa0:	4581                	li	a1,0
    80004fa2:	4501                	li	a0,0
    80004fa4:	e21ff0ef          	jal	80004dc4 <argfd>
    return -1;
    80004fa8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004faa:	02054363          	bltz	a0,80004fd0 <sys_dup+0x3c>
    80004fae:	ec26                	sd	s1,24(sp)
    80004fb0:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004fb2:	fd843903          	ld	s2,-40(s0)
    80004fb6:	854a                	mv	a0,s2
    80004fb8:	e65ff0ef          	jal	80004e1c <fdalloc>
    80004fbc:	84aa                	mv	s1,a0
    return -1;
    80004fbe:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004fc0:	00054d63          	bltz	a0,80004fda <sys_dup+0x46>
  filedup(f);
    80004fc4:	854a                	mv	a0,s2
    80004fc6:	c3eff0ef          	jal	80004404 <filedup>
  return fd;
    80004fca:	87a6                	mv	a5,s1
    80004fcc:	64e2                	ld	s1,24(sp)
    80004fce:	6942                	ld	s2,16(sp)
}
    80004fd0:	853e                	mv	a0,a5
    80004fd2:	70a2                	ld	ra,40(sp)
    80004fd4:	7402                	ld	s0,32(sp)
    80004fd6:	6145                	addi	sp,sp,48
    80004fd8:	8082                	ret
    80004fda:	64e2                	ld	s1,24(sp)
    80004fdc:	6942                	ld	s2,16(sp)
    80004fde:	bfcd                	j	80004fd0 <sys_dup+0x3c>

0000000080004fe0 <sys_read>:
{
    80004fe0:	7179                	addi	sp,sp,-48
    80004fe2:	f406                	sd	ra,40(sp)
    80004fe4:	f022                	sd	s0,32(sp)
    80004fe6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004fe8:	fd840593          	addi	a1,s0,-40
    80004fec:	4505                	li	a0,1
    80004fee:	bc9fd0ef          	jal	80002bb6 <argaddr>
  argint(2, &n);
    80004ff2:	fe440593          	addi	a1,s0,-28
    80004ff6:	4509                	li	a0,2
    80004ff8:	ba3fd0ef          	jal	80002b9a <argint>
  if(argfd(0, 0, &f) < 0)
    80004ffc:	fe840613          	addi	a2,s0,-24
    80005000:	4581                	li	a1,0
    80005002:	4501                	li	a0,0
    80005004:	dc1ff0ef          	jal	80004dc4 <argfd>
    80005008:	87aa                	mv	a5,a0
    return -1;
    8000500a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000500c:	0007ca63          	bltz	a5,80005020 <sys_read+0x40>
  return fileread(f, p, n);
    80005010:	fe442603          	lw	a2,-28(s0)
    80005014:	fd843583          	ld	a1,-40(s0)
    80005018:	fe843503          	ld	a0,-24(s0)
    8000501c:	d4eff0ef          	jal	8000456a <fileread>
}
    80005020:	70a2                	ld	ra,40(sp)
    80005022:	7402                	ld	s0,32(sp)
    80005024:	6145                	addi	sp,sp,48
    80005026:	8082                	ret

0000000080005028 <sys_write>:
{
    80005028:	7179                	addi	sp,sp,-48
    8000502a:	f406                	sd	ra,40(sp)
    8000502c:	f022                	sd	s0,32(sp)
    8000502e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005030:	fd840593          	addi	a1,s0,-40
    80005034:	4505                	li	a0,1
    80005036:	b81fd0ef          	jal	80002bb6 <argaddr>
  argint(2, &n);
    8000503a:	fe440593          	addi	a1,s0,-28
    8000503e:	4509                	li	a0,2
    80005040:	b5bfd0ef          	jal	80002b9a <argint>
  if(argfd(0, 0, &f) < 0)
    80005044:	fe840613          	addi	a2,s0,-24
    80005048:	4581                	li	a1,0
    8000504a:	4501                	li	a0,0
    8000504c:	d79ff0ef          	jal	80004dc4 <argfd>
    80005050:	87aa                	mv	a5,a0
    return -1;
    80005052:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005054:	0007ca63          	bltz	a5,80005068 <sys_write+0x40>
  return filewrite(f, p, n);
    80005058:	fe442603          	lw	a2,-28(s0)
    8000505c:	fd843583          	ld	a1,-40(s0)
    80005060:	fe843503          	ld	a0,-24(s0)
    80005064:	dc4ff0ef          	jal	80004628 <filewrite>
}
    80005068:	70a2                	ld	ra,40(sp)
    8000506a:	7402                	ld	s0,32(sp)
    8000506c:	6145                	addi	sp,sp,48
    8000506e:	8082                	ret

0000000080005070 <sys_close>:
{
    80005070:	1101                	addi	sp,sp,-32
    80005072:	ec06                	sd	ra,24(sp)
    80005074:	e822                	sd	s0,16(sp)
    80005076:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005078:	fe040613          	addi	a2,s0,-32
    8000507c:	fec40593          	addi	a1,s0,-20
    80005080:	4501                	li	a0,0
    80005082:	d43ff0ef          	jal	80004dc4 <argfd>
    return -1;
    80005086:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005088:	02054063          	bltz	a0,800050a8 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    8000508c:	a4bfc0ef          	jal	80001ad6 <myproc>
    80005090:	fec42783          	lw	a5,-20(s0)
    80005094:	07f1                	addi	a5,a5,28
    80005096:	078e                	slli	a5,a5,0x3
    80005098:	953e                	add	a0,a0,a5
    8000509a:	00053423          	sd	zero,8(a0)
  fileclose(f);
    8000509e:	fe043503          	ld	a0,-32(s0)
    800050a2:	ba8ff0ef          	jal	8000444a <fileclose>
  return 0;
    800050a6:	4781                	li	a5,0
}
    800050a8:	853e                	mv	a0,a5
    800050aa:	60e2                	ld	ra,24(sp)
    800050ac:	6442                	ld	s0,16(sp)
    800050ae:	6105                	addi	sp,sp,32
    800050b0:	8082                	ret

00000000800050b2 <sys_fstat>:
{
    800050b2:	1101                	addi	sp,sp,-32
    800050b4:	ec06                	sd	ra,24(sp)
    800050b6:	e822                	sd	s0,16(sp)
    800050b8:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800050ba:	fe040593          	addi	a1,s0,-32
    800050be:	4505                	li	a0,1
    800050c0:	af7fd0ef          	jal	80002bb6 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800050c4:	fe840613          	addi	a2,s0,-24
    800050c8:	4581                	li	a1,0
    800050ca:	4501                	li	a0,0
    800050cc:	cf9ff0ef          	jal	80004dc4 <argfd>
    800050d0:	87aa                	mv	a5,a0
    return -1;
    800050d2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800050d4:	0007c863          	bltz	a5,800050e4 <sys_fstat+0x32>
  return filestat(f, st);
    800050d8:	fe043583          	ld	a1,-32(s0)
    800050dc:	fe843503          	ld	a0,-24(s0)
    800050e0:	c2cff0ef          	jal	8000450c <filestat>
}
    800050e4:	60e2                	ld	ra,24(sp)
    800050e6:	6442                	ld	s0,16(sp)
    800050e8:	6105                	addi	sp,sp,32
    800050ea:	8082                	ret

00000000800050ec <sys_link>:
{
    800050ec:	7169                	addi	sp,sp,-304
    800050ee:	f606                	sd	ra,296(sp)
    800050f0:	f222                	sd	s0,288(sp)
    800050f2:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800050f4:	08000613          	li	a2,128
    800050f8:	ed040593          	addi	a1,s0,-304
    800050fc:	4501                	li	a0,0
    800050fe:	ad5fd0ef          	jal	80002bd2 <argstr>
    return -1;
    80005102:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005104:	0c054e63          	bltz	a0,800051e0 <sys_link+0xf4>
    80005108:	08000613          	li	a2,128
    8000510c:	f5040593          	addi	a1,s0,-176
    80005110:	4505                	li	a0,1
    80005112:	ac1fd0ef          	jal	80002bd2 <argstr>
    return -1;
    80005116:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005118:	0c054463          	bltz	a0,800051e0 <sys_link+0xf4>
    8000511c:	ee26                	sd	s1,280(sp)
  begin_op();
    8000511e:	f21fe0ef          	jal	8000403e <begin_op>
  if((ip = namei(old)) == 0){
    80005122:	ed040513          	addi	a0,s0,-304
    80005126:	d45fe0ef          	jal	80003e6a <namei>
    8000512a:	84aa                	mv	s1,a0
    8000512c:	c53d                	beqz	a0,8000519a <sys_link+0xae>
  ilock(ip);
    8000512e:	d26fe0ef          	jal	80003654 <ilock>
  if(ip->type == T_DIR){
    80005132:	04449703          	lh	a4,68(s1)
    80005136:	4785                	li	a5,1
    80005138:	06f70663          	beq	a4,a5,800051a4 <sys_link+0xb8>
    8000513c:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    8000513e:	04a4d783          	lhu	a5,74(s1)
    80005142:	2785                	addiw	a5,a5,1
    80005144:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005148:	8526                	mv	a0,s1
    8000514a:	c56fe0ef          	jal	800035a0 <iupdate>
  iunlock(ip);
    8000514e:	8526                	mv	a0,s1
    80005150:	db2fe0ef          	jal	80003702 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005154:	fd040593          	addi	a1,s0,-48
    80005158:	f5040513          	addi	a0,s0,-176
    8000515c:	d29fe0ef          	jal	80003e84 <nameiparent>
    80005160:	892a                	mv	s2,a0
    80005162:	cd21                	beqz	a0,800051ba <sys_link+0xce>
  ilock(dp);
    80005164:	cf0fe0ef          	jal	80003654 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005168:	00092703          	lw	a4,0(s2)
    8000516c:	409c                	lw	a5,0(s1)
    8000516e:	04f71363          	bne	a4,a5,800051b4 <sys_link+0xc8>
    80005172:	40d0                	lw	a2,4(s1)
    80005174:	fd040593          	addi	a1,s0,-48
    80005178:	854a                	mv	a0,s2
    8000517a:	c57fe0ef          	jal	80003dd0 <dirlink>
    8000517e:	02054b63          	bltz	a0,800051b4 <sys_link+0xc8>
  iunlockput(dp);
    80005182:	854a                	mv	a0,s2
    80005184:	edafe0ef          	jal	8000385e <iunlockput>
  iput(ip);
    80005188:	8526                	mv	a0,s1
    8000518a:	e4cfe0ef          	jal	800037d6 <iput>
  end_op();
    8000518e:	f1bfe0ef          	jal	800040a8 <end_op>
  return 0;
    80005192:	4781                	li	a5,0
    80005194:	64f2                	ld	s1,280(sp)
    80005196:	6952                	ld	s2,272(sp)
    80005198:	a0a1                	j	800051e0 <sys_link+0xf4>
    end_op();
    8000519a:	f0ffe0ef          	jal	800040a8 <end_op>
    return -1;
    8000519e:	57fd                	li	a5,-1
    800051a0:	64f2                	ld	s1,280(sp)
    800051a2:	a83d                	j	800051e0 <sys_link+0xf4>
    iunlockput(ip);
    800051a4:	8526                	mv	a0,s1
    800051a6:	eb8fe0ef          	jal	8000385e <iunlockput>
    end_op();
    800051aa:	efffe0ef          	jal	800040a8 <end_op>
    return -1;
    800051ae:	57fd                	li	a5,-1
    800051b0:	64f2                	ld	s1,280(sp)
    800051b2:	a03d                	j	800051e0 <sys_link+0xf4>
    iunlockput(dp);
    800051b4:	854a                	mv	a0,s2
    800051b6:	ea8fe0ef          	jal	8000385e <iunlockput>
  ilock(ip);
    800051ba:	8526                	mv	a0,s1
    800051bc:	c98fe0ef          	jal	80003654 <ilock>
  ip->nlink--;
    800051c0:	04a4d783          	lhu	a5,74(s1)
    800051c4:	37fd                	addiw	a5,a5,-1
    800051c6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800051ca:	8526                	mv	a0,s1
    800051cc:	bd4fe0ef          	jal	800035a0 <iupdate>
  iunlockput(ip);
    800051d0:	8526                	mv	a0,s1
    800051d2:	e8cfe0ef          	jal	8000385e <iunlockput>
  end_op();
    800051d6:	ed3fe0ef          	jal	800040a8 <end_op>
  return -1;
    800051da:	57fd                	li	a5,-1
    800051dc:	64f2                	ld	s1,280(sp)
    800051de:	6952                	ld	s2,272(sp)
}
    800051e0:	853e                	mv	a0,a5
    800051e2:	70b2                	ld	ra,296(sp)
    800051e4:	7412                	ld	s0,288(sp)
    800051e6:	6155                	addi	sp,sp,304
    800051e8:	8082                	ret

00000000800051ea <sys_unlink>:
{
    800051ea:	7151                	addi	sp,sp,-240
    800051ec:	f586                	sd	ra,232(sp)
    800051ee:	f1a2                	sd	s0,224(sp)
    800051f0:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800051f2:	08000613          	li	a2,128
    800051f6:	f3040593          	addi	a1,s0,-208
    800051fa:	4501                	li	a0,0
    800051fc:	9d7fd0ef          	jal	80002bd2 <argstr>
    80005200:	16054063          	bltz	a0,80005360 <sys_unlink+0x176>
    80005204:	eda6                	sd	s1,216(sp)
  begin_op();
    80005206:	e39fe0ef          	jal	8000403e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000520a:	fb040593          	addi	a1,s0,-80
    8000520e:	f3040513          	addi	a0,s0,-208
    80005212:	c73fe0ef          	jal	80003e84 <nameiparent>
    80005216:	84aa                	mv	s1,a0
    80005218:	c945                	beqz	a0,800052c8 <sys_unlink+0xde>
  ilock(dp);
    8000521a:	c3afe0ef          	jal	80003654 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000521e:	00002597          	auipc	a1,0x2
    80005222:	3da58593          	addi	a1,a1,986 # 800075f8 <etext+0x5f8>
    80005226:	fb040513          	addi	a0,s0,-80
    8000522a:	9c5fe0ef          	jal	80003bee <namecmp>
    8000522e:	10050e63          	beqz	a0,8000534a <sys_unlink+0x160>
    80005232:	00002597          	auipc	a1,0x2
    80005236:	3ce58593          	addi	a1,a1,974 # 80007600 <etext+0x600>
    8000523a:	fb040513          	addi	a0,s0,-80
    8000523e:	9b1fe0ef          	jal	80003bee <namecmp>
    80005242:	10050463          	beqz	a0,8000534a <sys_unlink+0x160>
    80005246:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005248:	f2c40613          	addi	a2,s0,-212
    8000524c:	fb040593          	addi	a1,s0,-80
    80005250:	8526                	mv	a0,s1
    80005252:	9b3fe0ef          	jal	80003c04 <dirlookup>
    80005256:	892a                	mv	s2,a0
    80005258:	0e050863          	beqz	a0,80005348 <sys_unlink+0x15e>
  ilock(ip);
    8000525c:	bf8fe0ef          	jal	80003654 <ilock>
  if(ip->nlink < 1)
    80005260:	04a91783          	lh	a5,74(s2)
    80005264:	06f05763          	blez	a5,800052d2 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005268:	04491703          	lh	a4,68(s2)
    8000526c:	4785                	li	a5,1
    8000526e:	06f70963          	beq	a4,a5,800052e0 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80005272:	4641                	li	a2,16
    80005274:	4581                	li	a1,0
    80005276:	fc040513          	addi	a0,s0,-64
    8000527a:	b5dfb0ef          	jal	80000dd6 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000527e:	4741                	li	a4,16
    80005280:	f2c42683          	lw	a3,-212(s0)
    80005284:	fc040613          	addi	a2,s0,-64
    80005288:	4581                	li	a1,0
    8000528a:	8526                	mv	a0,s1
    8000528c:	855fe0ef          	jal	80003ae0 <writei>
    80005290:	47c1                	li	a5,16
    80005292:	08f51b63          	bne	a0,a5,80005328 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80005296:	04491703          	lh	a4,68(s2)
    8000529a:	4785                	li	a5,1
    8000529c:	08f70d63          	beq	a4,a5,80005336 <sys_unlink+0x14c>
  iunlockput(dp);
    800052a0:	8526                	mv	a0,s1
    800052a2:	dbcfe0ef          	jal	8000385e <iunlockput>
  ip->nlink--;
    800052a6:	04a95783          	lhu	a5,74(s2)
    800052aa:	37fd                	addiw	a5,a5,-1
    800052ac:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800052b0:	854a                	mv	a0,s2
    800052b2:	aeefe0ef          	jal	800035a0 <iupdate>
  iunlockput(ip);
    800052b6:	854a                	mv	a0,s2
    800052b8:	da6fe0ef          	jal	8000385e <iunlockput>
  end_op();
    800052bc:	dedfe0ef          	jal	800040a8 <end_op>
  return 0;
    800052c0:	4501                	li	a0,0
    800052c2:	64ee                	ld	s1,216(sp)
    800052c4:	694e                	ld	s2,208(sp)
    800052c6:	a849                	j	80005358 <sys_unlink+0x16e>
    end_op();
    800052c8:	de1fe0ef          	jal	800040a8 <end_op>
    return -1;
    800052cc:	557d                	li	a0,-1
    800052ce:	64ee                	ld	s1,216(sp)
    800052d0:	a061                	j	80005358 <sys_unlink+0x16e>
    800052d2:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    800052d4:	00002517          	auipc	a0,0x2
    800052d8:	33450513          	addi	a0,a0,820 # 80007608 <etext+0x608>
    800052dc:	d04fb0ef          	jal	800007e0 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800052e0:	04c92703          	lw	a4,76(s2)
    800052e4:	02000793          	li	a5,32
    800052e8:	f8e7f5e3          	bgeu	a5,a4,80005272 <sys_unlink+0x88>
    800052ec:	e5ce                	sd	s3,200(sp)
    800052ee:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800052f2:	4741                	li	a4,16
    800052f4:	86ce                	mv	a3,s3
    800052f6:	f1840613          	addi	a2,s0,-232
    800052fa:	4581                	li	a1,0
    800052fc:	854a                	mv	a0,s2
    800052fe:	ee6fe0ef          	jal	800039e4 <readi>
    80005302:	47c1                	li	a5,16
    80005304:	00f51c63          	bne	a0,a5,8000531c <sys_unlink+0x132>
    if(de.inum != 0)
    80005308:	f1845783          	lhu	a5,-232(s0)
    8000530c:	efa1                	bnez	a5,80005364 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000530e:	29c1                	addiw	s3,s3,16
    80005310:	04c92783          	lw	a5,76(s2)
    80005314:	fcf9efe3          	bltu	s3,a5,800052f2 <sys_unlink+0x108>
    80005318:	69ae                	ld	s3,200(sp)
    8000531a:	bfa1                	j	80005272 <sys_unlink+0x88>
      panic("isdirempty: readi");
    8000531c:	00002517          	auipc	a0,0x2
    80005320:	30450513          	addi	a0,a0,772 # 80007620 <etext+0x620>
    80005324:	cbcfb0ef          	jal	800007e0 <panic>
    80005328:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    8000532a:	00002517          	auipc	a0,0x2
    8000532e:	30e50513          	addi	a0,a0,782 # 80007638 <etext+0x638>
    80005332:	caefb0ef          	jal	800007e0 <panic>
    dp->nlink--;
    80005336:	04a4d783          	lhu	a5,74(s1)
    8000533a:	37fd                	addiw	a5,a5,-1
    8000533c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005340:	8526                	mv	a0,s1
    80005342:	a5efe0ef          	jal	800035a0 <iupdate>
    80005346:	bfa9                	j	800052a0 <sys_unlink+0xb6>
    80005348:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    8000534a:	8526                	mv	a0,s1
    8000534c:	d12fe0ef          	jal	8000385e <iunlockput>
  end_op();
    80005350:	d59fe0ef          	jal	800040a8 <end_op>
  return -1;
    80005354:	557d                	li	a0,-1
    80005356:	64ee                	ld	s1,216(sp)
}
    80005358:	70ae                	ld	ra,232(sp)
    8000535a:	740e                	ld	s0,224(sp)
    8000535c:	616d                	addi	sp,sp,240
    8000535e:	8082                	ret
    return -1;
    80005360:	557d                	li	a0,-1
    80005362:	bfdd                	j	80005358 <sys_unlink+0x16e>
    iunlockput(ip);
    80005364:	854a                	mv	a0,s2
    80005366:	cf8fe0ef          	jal	8000385e <iunlockput>
    goto bad;
    8000536a:	694e                	ld	s2,208(sp)
    8000536c:	69ae                	ld	s3,200(sp)
    8000536e:	bff1                	j	8000534a <sys_unlink+0x160>

0000000080005370 <sys_open>:

uint64
sys_open(void)
{
    80005370:	7131                	addi	sp,sp,-192
    80005372:	fd06                	sd	ra,184(sp)
    80005374:	f922                	sd	s0,176(sp)
    80005376:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005378:	f4c40593          	addi	a1,s0,-180
    8000537c:	4505                	li	a0,1
    8000537e:	81dfd0ef          	jal	80002b9a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005382:	08000613          	li	a2,128
    80005386:	f5040593          	addi	a1,s0,-176
    8000538a:	4501                	li	a0,0
    8000538c:	847fd0ef          	jal	80002bd2 <argstr>
    80005390:	87aa                	mv	a5,a0
    return -1;
    80005392:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005394:	0a07c263          	bltz	a5,80005438 <sys_open+0xc8>
    80005398:	f526                	sd	s1,168(sp)

  begin_op();
    8000539a:	ca5fe0ef          	jal	8000403e <begin_op>

  if(omode & O_CREATE){
    8000539e:	f4c42783          	lw	a5,-180(s0)
    800053a2:	2007f793          	andi	a5,a5,512
    800053a6:	c3d5                	beqz	a5,8000544a <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800053a8:	4681                	li	a3,0
    800053aa:	4601                	li	a2,0
    800053ac:	4589                	li	a1,2
    800053ae:	f5040513          	addi	a0,s0,-176
    800053b2:	aa9ff0ef          	jal	80004e5a <create>
    800053b6:	84aa                	mv	s1,a0
    if(ip == 0){
    800053b8:	c541                	beqz	a0,80005440 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800053ba:	04449703          	lh	a4,68(s1)
    800053be:	478d                	li	a5,3
    800053c0:	00f71763          	bne	a4,a5,800053ce <sys_open+0x5e>
    800053c4:	0464d703          	lhu	a4,70(s1)
    800053c8:	47a5                	li	a5,9
    800053ca:	0ae7ed63          	bltu	a5,a4,80005484 <sys_open+0x114>
    800053ce:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800053d0:	fd7fe0ef          	jal	800043a6 <filealloc>
    800053d4:	892a                	mv	s2,a0
    800053d6:	c179                	beqz	a0,8000549c <sys_open+0x12c>
    800053d8:	ed4e                	sd	s3,152(sp)
    800053da:	a43ff0ef          	jal	80004e1c <fdalloc>
    800053de:	89aa                	mv	s3,a0
    800053e0:	0a054a63          	bltz	a0,80005494 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800053e4:	04449703          	lh	a4,68(s1)
    800053e8:	478d                	li	a5,3
    800053ea:	0cf70263          	beq	a4,a5,800054ae <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800053ee:	4789                	li	a5,2
    800053f0:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800053f4:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800053f8:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800053fc:	f4c42783          	lw	a5,-180(s0)
    80005400:	0017c713          	xori	a4,a5,1
    80005404:	8b05                	andi	a4,a4,1
    80005406:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000540a:	0037f713          	andi	a4,a5,3
    8000540e:	00e03733          	snez	a4,a4
    80005412:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005416:	4007f793          	andi	a5,a5,1024
    8000541a:	c791                	beqz	a5,80005426 <sys_open+0xb6>
    8000541c:	04449703          	lh	a4,68(s1)
    80005420:	4789                	li	a5,2
    80005422:	08f70d63          	beq	a4,a5,800054bc <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80005426:	8526                	mv	a0,s1
    80005428:	adafe0ef          	jal	80003702 <iunlock>
  end_op();
    8000542c:	c7dfe0ef          	jal	800040a8 <end_op>

  return fd;
    80005430:	854e                	mv	a0,s3
    80005432:	74aa                	ld	s1,168(sp)
    80005434:	790a                	ld	s2,160(sp)
    80005436:	69ea                	ld	s3,152(sp)
}
    80005438:	70ea                	ld	ra,184(sp)
    8000543a:	744a                	ld	s0,176(sp)
    8000543c:	6129                	addi	sp,sp,192
    8000543e:	8082                	ret
      end_op();
    80005440:	c69fe0ef          	jal	800040a8 <end_op>
      return -1;
    80005444:	557d                	li	a0,-1
    80005446:	74aa                	ld	s1,168(sp)
    80005448:	bfc5                	j	80005438 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    8000544a:	f5040513          	addi	a0,s0,-176
    8000544e:	a1dfe0ef          	jal	80003e6a <namei>
    80005452:	84aa                	mv	s1,a0
    80005454:	c11d                	beqz	a0,8000547a <sys_open+0x10a>
    ilock(ip);
    80005456:	9fefe0ef          	jal	80003654 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000545a:	04449703          	lh	a4,68(s1)
    8000545e:	4785                	li	a5,1
    80005460:	f4f71de3          	bne	a4,a5,800053ba <sys_open+0x4a>
    80005464:	f4c42783          	lw	a5,-180(s0)
    80005468:	d3bd                	beqz	a5,800053ce <sys_open+0x5e>
      iunlockput(ip);
    8000546a:	8526                	mv	a0,s1
    8000546c:	bf2fe0ef          	jal	8000385e <iunlockput>
      end_op();
    80005470:	c39fe0ef          	jal	800040a8 <end_op>
      return -1;
    80005474:	557d                	li	a0,-1
    80005476:	74aa                	ld	s1,168(sp)
    80005478:	b7c1                	j	80005438 <sys_open+0xc8>
      end_op();
    8000547a:	c2ffe0ef          	jal	800040a8 <end_op>
      return -1;
    8000547e:	557d                	li	a0,-1
    80005480:	74aa                	ld	s1,168(sp)
    80005482:	bf5d                	j	80005438 <sys_open+0xc8>
    iunlockput(ip);
    80005484:	8526                	mv	a0,s1
    80005486:	bd8fe0ef          	jal	8000385e <iunlockput>
    end_op();
    8000548a:	c1ffe0ef          	jal	800040a8 <end_op>
    return -1;
    8000548e:	557d                	li	a0,-1
    80005490:	74aa                	ld	s1,168(sp)
    80005492:	b75d                	j	80005438 <sys_open+0xc8>
      fileclose(f);
    80005494:	854a                	mv	a0,s2
    80005496:	fb5fe0ef          	jal	8000444a <fileclose>
    8000549a:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000549c:	8526                	mv	a0,s1
    8000549e:	bc0fe0ef          	jal	8000385e <iunlockput>
    end_op();
    800054a2:	c07fe0ef          	jal	800040a8 <end_op>
    return -1;
    800054a6:	557d                	li	a0,-1
    800054a8:	74aa                	ld	s1,168(sp)
    800054aa:	790a                	ld	s2,160(sp)
    800054ac:	b771                	j	80005438 <sys_open+0xc8>
    f->type = FD_DEVICE;
    800054ae:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800054b2:	04649783          	lh	a5,70(s1)
    800054b6:	02f91223          	sh	a5,36(s2)
    800054ba:	bf3d                	j	800053f8 <sys_open+0x88>
    itrunc(ip);
    800054bc:	8526                	mv	a0,s1
    800054be:	a84fe0ef          	jal	80003742 <itrunc>
    800054c2:	b795                	j	80005426 <sys_open+0xb6>

00000000800054c4 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800054c4:	7175                	addi	sp,sp,-144
    800054c6:	e506                	sd	ra,136(sp)
    800054c8:	e122                	sd	s0,128(sp)
    800054ca:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800054cc:	b73fe0ef          	jal	8000403e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800054d0:	08000613          	li	a2,128
    800054d4:	f7040593          	addi	a1,s0,-144
    800054d8:	4501                	li	a0,0
    800054da:	ef8fd0ef          	jal	80002bd2 <argstr>
    800054de:	02054363          	bltz	a0,80005504 <sys_mkdir+0x40>
    800054e2:	4681                	li	a3,0
    800054e4:	4601                	li	a2,0
    800054e6:	4585                	li	a1,1
    800054e8:	f7040513          	addi	a0,s0,-144
    800054ec:	96fff0ef          	jal	80004e5a <create>
    800054f0:	c911                	beqz	a0,80005504 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800054f2:	b6cfe0ef          	jal	8000385e <iunlockput>
  end_op();
    800054f6:	bb3fe0ef          	jal	800040a8 <end_op>
  return 0;
    800054fa:	4501                	li	a0,0
}
    800054fc:	60aa                	ld	ra,136(sp)
    800054fe:	640a                	ld	s0,128(sp)
    80005500:	6149                	addi	sp,sp,144
    80005502:	8082                	ret
    end_op();
    80005504:	ba5fe0ef          	jal	800040a8 <end_op>
    return -1;
    80005508:	557d                	li	a0,-1
    8000550a:	bfcd                	j	800054fc <sys_mkdir+0x38>

000000008000550c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000550c:	7135                	addi	sp,sp,-160
    8000550e:	ed06                	sd	ra,152(sp)
    80005510:	e922                	sd	s0,144(sp)
    80005512:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005514:	b2bfe0ef          	jal	8000403e <begin_op>
  argint(1, &major);
    80005518:	f6c40593          	addi	a1,s0,-148
    8000551c:	4505                	li	a0,1
    8000551e:	e7cfd0ef          	jal	80002b9a <argint>
  argint(2, &minor);
    80005522:	f6840593          	addi	a1,s0,-152
    80005526:	4509                	li	a0,2
    80005528:	e72fd0ef          	jal	80002b9a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000552c:	08000613          	li	a2,128
    80005530:	f7040593          	addi	a1,s0,-144
    80005534:	4501                	li	a0,0
    80005536:	e9cfd0ef          	jal	80002bd2 <argstr>
    8000553a:	02054563          	bltz	a0,80005564 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000553e:	f6841683          	lh	a3,-152(s0)
    80005542:	f6c41603          	lh	a2,-148(s0)
    80005546:	458d                	li	a1,3
    80005548:	f7040513          	addi	a0,s0,-144
    8000554c:	90fff0ef          	jal	80004e5a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005550:	c911                	beqz	a0,80005564 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005552:	b0cfe0ef          	jal	8000385e <iunlockput>
  end_op();
    80005556:	b53fe0ef          	jal	800040a8 <end_op>
  return 0;
    8000555a:	4501                	li	a0,0
}
    8000555c:	60ea                	ld	ra,152(sp)
    8000555e:	644a                	ld	s0,144(sp)
    80005560:	610d                	addi	sp,sp,160
    80005562:	8082                	ret
    end_op();
    80005564:	b45fe0ef          	jal	800040a8 <end_op>
    return -1;
    80005568:	557d                	li	a0,-1
    8000556a:	bfcd                	j	8000555c <sys_mknod+0x50>

000000008000556c <sys_chdir>:

uint64
sys_chdir(void)
{
    8000556c:	7135                	addi	sp,sp,-160
    8000556e:	ed06                	sd	ra,152(sp)
    80005570:	e922                	sd	s0,144(sp)
    80005572:	e14a                	sd	s2,128(sp)
    80005574:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005576:	d60fc0ef          	jal	80001ad6 <myproc>
    8000557a:	892a                	mv	s2,a0
  
  begin_op();
    8000557c:	ac3fe0ef          	jal	8000403e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005580:	08000613          	li	a2,128
    80005584:	f6040593          	addi	a1,s0,-160
    80005588:	4501                	li	a0,0
    8000558a:	e48fd0ef          	jal	80002bd2 <argstr>
    8000558e:	04054363          	bltz	a0,800055d4 <sys_chdir+0x68>
    80005592:	e526                	sd	s1,136(sp)
    80005594:	f6040513          	addi	a0,s0,-160
    80005598:	8d3fe0ef          	jal	80003e6a <namei>
    8000559c:	84aa                	mv	s1,a0
    8000559e:	c915                	beqz	a0,800055d2 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800055a0:	8b4fe0ef          	jal	80003654 <ilock>
  if(ip->type != T_DIR){
    800055a4:	04449703          	lh	a4,68(s1)
    800055a8:	4785                	li	a5,1
    800055aa:	02f71963          	bne	a4,a5,800055dc <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800055ae:	8526                	mv	a0,s1
    800055b0:	952fe0ef          	jal	80003702 <iunlock>
  iput(p->cwd);
    800055b4:	16893503          	ld	a0,360(s2)
    800055b8:	a1efe0ef          	jal	800037d6 <iput>
  end_op();
    800055bc:	aedfe0ef          	jal	800040a8 <end_op>
  p->cwd = ip;
    800055c0:	16993423          	sd	s1,360(s2)
  return 0;
    800055c4:	4501                	li	a0,0
    800055c6:	64aa                	ld	s1,136(sp)
}
    800055c8:	60ea                	ld	ra,152(sp)
    800055ca:	644a                	ld	s0,144(sp)
    800055cc:	690a                	ld	s2,128(sp)
    800055ce:	610d                	addi	sp,sp,160
    800055d0:	8082                	ret
    800055d2:	64aa                	ld	s1,136(sp)
    end_op();
    800055d4:	ad5fe0ef          	jal	800040a8 <end_op>
    return -1;
    800055d8:	557d                	li	a0,-1
    800055da:	b7fd                	j	800055c8 <sys_chdir+0x5c>
    iunlockput(ip);
    800055dc:	8526                	mv	a0,s1
    800055de:	a80fe0ef          	jal	8000385e <iunlockput>
    end_op();
    800055e2:	ac7fe0ef          	jal	800040a8 <end_op>
    return -1;
    800055e6:	557d                	li	a0,-1
    800055e8:	64aa                	ld	s1,136(sp)
    800055ea:	bff9                	j	800055c8 <sys_chdir+0x5c>

00000000800055ec <sys_exec>:

uint64
sys_exec(void)
{
    800055ec:	7121                	addi	sp,sp,-448
    800055ee:	ff06                	sd	ra,440(sp)
    800055f0:	fb22                	sd	s0,432(sp)
    800055f2:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800055f4:	e4840593          	addi	a1,s0,-440
    800055f8:	4505                	li	a0,1
    800055fa:	dbcfd0ef          	jal	80002bb6 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800055fe:	08000613          	li	a2,128
    80005602:	f5040593          	addi	a1,s0,-176
    80005606:	4501                	li	a0,0
    80005608:	dcafd0ef          	jal	80002bd2 <argstr>
    8000560c:	87aa                	mv	a5,a0
    return -1;
    8000560e:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005610:	0c07c463          	bltz	a5,800056d8 <sys_exec+0xec>
    80005614:	f726                	sd	s1,424(sp)
    80005616:	f34a                	sd	s2,416(sp)
    80005618:	ef4e                	sd	s3,408(sp)
    8000561a:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000561c:	10000613          	li	a2,256
    80005620:	4581                	li	a1,0
    80005622:	e5040513          	addi	a0,s0,-432
    80005626:	fb0fb0ef          	jal	80000dd6 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000562a:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    8000562e:	89a6                	mv	s3,s1
    80005630:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005632:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005636:	00391513          	slli	a0,s2,0x3
    8000563a:	e4040593          	addi	a1,s0,-448
    8000563e:	e4843783          	ld	a5,-440(s0)
    80005642:	953e                	add	a0,a0,a5
    80005644:	cccfd0ef          	jal	80002b10 <fetchaddr>
    80005648:	02054663          	bltz	a0,80005674 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    8000564c:	e4043783          	ld	a5,-448(s0)
    80005650:	c3a9                	beqz	a5,80005692 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005652:	d20fb0ef          	jal	80000b72 <kalloc>
    80005656:	85aa                	mv	a1,a0
    80005658:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000565c:	cd01                	beqz	a0,80005674 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000565e:	6605                	lui	a2,0x1
    80005660:	e4043503          	ld	a0,-448(s0)
    80005664:	cf6fd0ef          	jal	80002b5a <fetchstr>
    80005668:	00054663          	bltz	a0,80005674 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    8000566c:	0905                	addi	s2,s2,1
    8000566e:	09a1                	addi	s3,s3,8
    80005670:	fd4913e3          	bne	s2,s4,80005636 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005674:	f5040913          	addi	s2,s0,-176
    80005678:	6088                	ld	a0,0(s1)
    8000567a:	c931                	beqz	a0,800056ce <sys_exec+0xe2>
    kfree(argv[i]);
    8000567c:	ba0fb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005680:	04a1                	addi	s1,s1,8
    80005682:	ff249be3          	bne	s1,s2,80005678 <sys_exec+0x8c>
  return -1;
    80005686:	557d                	li	a0,-1
    80005688:	74ba                	ld	s1,424(sp)
    8000568a:	791a                	ld	s2,416(sp)
    8000568c:	69fa                	ld	s3,408(sp)
    8000568e:	6a5a                	ld	s4,400(sp)
    80005690:	a0a1                	j	800056d8 <sys_exec+0xec>
      argv[i] = 0;
    80005692:	0009079b          	sext.w	a5,s2
    80005696:	078e                	slli	a5,a5,0x3
    80005698:	fd078793          	addi	a5,a5,-48
    8000569c:	97a2                	add	a5,a5,s0
    8000569e:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    800056a2:	e5040593          	addi	a1,s0,-432
    800056a6:	f5040513          	addi	a0,s0,-176
    800056aa:	ba8ff0ef          	jal	80004a52 <kexec>
    800056ae:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800056b0:	f5040993          	addi	s3,s0,-176
    800056b4:	6088                	ld	a0,0(s1)
    800056b6:	c511                	beqz	a0,800056c2 <sys_exec+0xd6>
    kfree(argv[i]);
    800056b8:	b64fb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800056bc:	04a1                	addi	s1,s1,8
    800056be:	ff349be3          	bne	s1,s3,800056b4 <sys_exec+0xc8>
  return ret;
    800056c2:	854a                	mv	a0,s2
    800056c4:	74ba                	ld	s1,424(sp)
    800056c6:	791a                	ld	s2,416(sp)
    800056c8:	69fa                	ld	s3,408(sp)
    800056ca:	6a5a                	ld	s4,400(sp)
    800056cc:	a031                	j	800056d8 <sys_exec+0xec>
  return -1;
    800056ce:	557d                	li	a0,-1
    800056d0:	74ba                	ld	s1,424(sp)
    800056d2:	791a                	ld	s2,416(sp)
    800056d4:	69fa                	ld	s3,408(sp)
    800056d6:	6a5a                	ld	s4,400(sp)
}
    800056d8:	70fa                	ld	ra,440(sp)
    800056da:	745a                	ld	s0,432(sp)
    800056dc:	6139                	addi	sp,sp,448
    800056de:	8082                	ret

00000000800056e0 <sys_pipe>:

uint64
sys_pipe(void)
{
    800056e0:	7139                	addi	sp,sp,-64
    800056e2:	fc06                	sd	ra,56(sp)
    800056e4:	f822                	sd	s0,48(sp)
    800056e6:	f426                	sd	s1,40(sp)
    800056e8:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800056ea:	becfc0ef          	jal	80001ad6 <myproc>
    800056ee:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800056f0:	fd840593          	addi	a1,s0,-40
    800056f4:	4501                	li	a0,0
    800056f6:	cc0fd0ef          	jal	80002bb6 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800056fa:	fc840593          	addi	a1,s0,-56
    800056fe:	fd040513          	addi	a0,s0,-48
    80005702:	852ff0ef          	jal	80004754 <pipealloc>
    return -1;
    80005706:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005708:	0a054463          	bltz	a0,800057b0 <sys_pipe+0xd0>
  fd0 = -1;
    8000570c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005710:	fd043503          	ld	a0,-48(s0)
    80005714:	f08ff0ef          	jal	80004e1c <fdalloc>
    80005718:	fca42223          	sw	a0,-60(s0)
    8000571c:	08054163          	bltz	a0,8000579e <sys_pipe+0xbe>
    80005720:	fc843503          	ld	a0,-56(s0)
    80005724:	ef8ff0ef          	jal	80004e1c <fdalloc>
    80005728:	fca42023          	sw	a0,-64(s0)
    8000572c:	06054063          	bltz	a0,8000578c <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005730:	4691                	li	a3,4
    80005732:	fc440613          	addi	a2,s0,-60
    80005736:	fd843583          	ld	a1,-40(s0)
    8000573a:	74a8                	ld	a0,104(s1)
    8000573c:	914fc0ef          	jal	80001850 <copyout>
    80005740:	00054e63          	bltz	a0,8000575c <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005744:	4691                	li	a3,4
    80005746:	fc040613          	addi	a2,s0,-64
    8000574a:	fd843583          	ld	a1,-40(s0)
    8000574e:	0591                	addi	a1,a1,4
    80005750:	74a8                	ld	a0,104(s1)
    80005752:	8fefc0ef          	jal	80001850 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005756:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005758:	04055c63          	bgez	a0,800057b0 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    8000575c:	fc442783          	lw	a5,-60(s0)
    80005760:	07f1                	addi	a5,a5,28
    80005762:	078e                	slli	a5,a5,0x3
    80005764:	97a6                	add	a5,a5,s1
    80005766:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    8000576a:	fc042783          	lw	a5,-64(s0)
    8000576e:	07f1                	addi	a5,a5,28
    80005770:	078e                	slli	a5,a5,0x3
    80005772:	94be                	add	s1,s1,a5
    80005774:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005778:	fd043503          	ld	a0,-48(s0)
    8000577c:	ccffe0ef          	jal	8000444a <fileclose>
    fileclose(wf);
    80005780:	fc843503          	ld	a0,-56(s0)
    80005784:	cc7fe0ef          	jal	8000444a <fileclose>
    return -1;
    80005788:	57fd                	li	a5,-1
    8000578a:	a01d                	j	800057b0 <sys_pipe+0xd0>
    if(fd0 >= 0)
    8000578c:	fc442783          	lw	a5,-60(s0)
    80005790:	0007c763          	bltz	a5,8000579e <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005794:	07f1                	addi	a5,a5,28
    80005796:	078e                	slli	a5,a5,0x3
    80005798:	97a6                	add	a5,a5,s1
    8000579a:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    8000579e:	fd043503          	ld	a0,-48(s0)
    800057a2:	ca9fe0ef          	jal	8000444a <fileclose>
    fileclose(wf);
    800057a6:	fc843503          	ld	a0,-56(s0)
    800057aa:	ca1fe0ef          	jal	8000444a <fileclose>
    return -1;
    800057ae:	57fd                	li	a5,-1
}
    800057b0:	853e                	mv	a0,a5
    800057b2:	70e2                	ld	ra,56(sp)
    800057b4:	7442                	ld	s0,48(sp)
    800057b6:	74a2                	ld	s1,40(sp)
    800057b8:	6121                	addi	sp,sp,64
    800057ba:	8082                	ret
    800057bc:	0000                	unimp
	...

00000000800057c0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800057c0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800057c2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800057c4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    800057c6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    800057c8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800057ca:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800057cc:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800057ce:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800057d0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800057d2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800057d4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800057d6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800057d8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800057da:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800057dc:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800057de:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800057e0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800057e2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800057e4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800057e6:	9d6fd0ef          	jal	800029bc <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800057ea:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800057ec:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800057ee:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800057f0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800057f2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800057f4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800057f6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800057f8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800057fa:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800057fc:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800057fe:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005800:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005802:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005804:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005806:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005808:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000580a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000580c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000580e:	10200073          	sret
	...

000000008000581e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000581e:	1141                	addi	sp,sp,-16
    80005820:	e422                	sd	s0,8(sp)
    80005822:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005824:	0c0007b7          	lui	a5,0xc000
    80005828:	4705                	li	a4,1
    8000582a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000582c:	0c0007b7          	lui	a5,0xc000
    80005830:	c3d8                	sw	a4,4(a5)
}
    80005832:	6422                	ld	s0,8(sp)
    80005834:	0141                	addi	sp,sp,16
    80005836:	8082                	ret

0000000080005838 <plicinithart>:

void
plicinithart(void)
{
    80005838:	1141                	addi	sp,sp,-16
    8000583a:	e406                	sd	ra,8(sp)
    8000583c:	e022                	sd	s0,0(sp)
    8000583e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005840:	a6afc0ef          	jal	80001aaa <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005844:	0085171b          	slliw	a4,a0,0x8
    80005848:	0c0027b7          	lui	a5,0xc002
    8000584c:	97ba                	add	a5,a5,a4
    8000584e:	40200713          	li	a4,1026
    80005852:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005856:	00d5151b          	slliw	a0,a0,0xd
    8000585a:	0c2017b7          	lui	a5,0xc201
    8000585e:	97aa                	add	a5,a5,a0
    80005860:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005864:	60a2                	ld	ra,8(sp)
    80005866:	6402                	ld	s0,0(sp)
    80005868:	0141                	addi	sp,sp,16
    8000586a:	8082                	ret

000000008000586c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000586c:	1141                	addi	sp,sp,-16
    8000586e:	e406                	sd	ra,8(sp)
    80005870:	e022                	sd	s0,0(sp)
    80005872:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005874:	a36fc0ef          	jal	80001aaa <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005878:	00d5151b          	slliw	a0,a0,0xd
    8000587c:	0c2017b7          	lui	a5,0xc201
    80005880:	97aa                	add	a5,a5,a0
  return irq;
}
    80005882:	43c8                	lw	a0,4(a5)
    80005884:	60a2                	ld	ra,8(sp)
    80005886:	6402                	ld	s0,0(sp)
    80005888:	0141                	addi	sp,sp,16
    8000588a:	8082                	ret

000000008000588c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000588c:	1101                	addi	sp,sp,-32
    8000588e:	ec06                	sd	ra,24(sp)
    80005890:	e822                	sd	s0,16(sp)
    80005892:	e426                	sd	s1,8(sp)
    80005894:	1000                	addi	s0,sp,32
    80005896:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005898:	a12fc0ef          	jal	80001aaa <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000589c:	00d5151b          	slliw	a0,a0,0xd
    800058a0:	0c2017b7          	lui	a5,0xc201
    800058a4:	97aa                	add	a5,a5,a0
    800058a6:	c3c4                	sw	s1,4(a5)
}
    800058a8:	60e2                	ld	ra,24(sp)
    800058aa:	6442                	ld	s0,16(sp)
    800058ac:	64a2                	ld	s1,8(sp)
    800058ae:	6105                	addi	sp,sp,32
    800058b0:	8082                	ret

00000000800058b2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800058b2:	1141                	addi	sp,sp,-16
    800058b4:	e406                	sd	ra,8(sp)
    800058b6:	e022                	sd	s0,0(sp)
    800058b8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800058ba:	479d                	li	a5,7
    800058bc:	04a7ca63          	blt	a5,a0,80005910 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800058c0:	0012b797          	auipc	a5,0x12b
    800058c4:	7e078793          	addi	a5,a5,2016 # 801310a0 <disk>
    800058c8:	97aa                	add	a5,a5,a0
    800058ca:	0187c783          	lbu	a5,24(a5)
    800058ce:	e7b9                	bnez	a5,8000591c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800058d0:	00451693          	slli	a3,a0,0x4
    800058d4:	0012b797          	auipc	a5,0x12b
    800058d8:	7cc78793          	addi	a5,a5,1996 # 801310a0 <disk>
    800058dc:	6398                	ld	a4,0(a5)
    800058de:	9736                	add	a4,a4,a3
    800058e0:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800058e4:	6398                	ld	a4,0(a5)
    800058e6:	9736                	add	a4,a4,a3
    800058e8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800058ec:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800058f0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800058f4:	97aa                	add	a5,a5,a0
    800058f6:	4705                	li	a4,1
    800058f8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800058fc:	0012b517          	auipc	a0,0x12b
    80005900:	7bc50513          	addi	a0,a0,1980 # 801310b8 <disk+0x18>
    80005904:	8c5fc0ef          	jal	800021c8 <wakeup>
}
    80005908:	60a2                	ld	ra,8(sp)
    8000590a:	6402                	ld	s0,0(sp)
    8000590c:	0141                	addi	sp,sp,16
    8000590e:	8082                	ret
    panic("free_desc 1");
    80005910:	00002517          	auipc	a0,0x2
    80005914:	d3850513          	addi	a0,a0,-712 # 80007648 <etext+0x648>
    80005918:	ec9fa0ef          	jal	800007e0 <panic>
    panic("free_desc 2");
    8000591c:	00002517          	auipc	a0,0x2
    80005920:	d3c50513          	addi	a0,a0,-708 # 80007658 <etext+0x658>
    80005924:	ebdfa0ef          	jal	800007e0 <panic>

0000000080005928 <virtio_disk_init>:
{
    80005928:	1101                	addi	sp,sp,-32
    8000592a:	ec06                	sd	ra,24(sp)
    8000592c:	e822                	sd	s0,16(sp)
    8000592e:	e426                	sd	s1,8(sp)
    80005930:	e04a                	sd	s2,0(sp)
    80005932:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005934:	00002597          	auipc	a1,0x2
    80005938:	d3458593          	addi	a1,a1,-716 # 80007668 <etext+0x668>
    8000593c:	0012c517          	auipc	a0,0x12c
    80005940:	88c50513          	addi	a0,a0,-1908 # 801311c8 <disk+0x128>
    80005944:	b3efb0ef          	jal	80000c82 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005948:	100017b7          	lui	a5,0x10001
    8000594c:	4398                	lw	a4,0(a5)
    8000594e:	2701                	sext.w	a4,a4
    80005950:	747277b7          	lui	a5,0x74727
    80005954:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005958:	18f71063          	bne	a4,a5,80005ad8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000595c:	100017b7          	lui	a5,0x10001
    80005960:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005962:	439c                	lw	a5,0(a5)
    80005964:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005966:	4709                	li	a4,2
    80005968:	16e79863          	bne	a5,a4,80005ad8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000596c:	100017b7          	lui	a5,0x10001
    80005970:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005972:	439c                	lw	a5,0(a5)
    80005974:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005976:	16e79163          	bne	a5,a4,80005ad8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000597a:	100017b7          	lui	a5,0x10001
    8000597e:	47d8                	lw	a4,12(a5)
    80005980:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005982:	554d47b7          	lui	a5,0x554d4
    80005986:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000598a:	14f71763          	bne	a4,a5,80005ad8 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000598e:	100017b7          	lui	a5,0x10001
    80005992:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005996:	4705                	li	a4,1
    80005998:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000599a:	470d                	li	a4,3
    8000599c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000599e:	10001737          	lui	a4,0x10001
    800059a2:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800059a4:	c7ffe737          	lui	a4,0xc7ffe
    800059a8:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47ecd57f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800059ac:	8ef9                	and	a3,a3,a4
    800059ae:	10001737          	lui	a4,0x10001
    800059b2:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800059b4:	472d                	li	a4,11
    800059b6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800059b8:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800059bc:	439c                	lw	a5,0(a5)
    800059be:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800059c2:	8ba1                	andi	a5,a5,8
    800059c4:	12078063          	beqz	a5,80005ae4 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800059c8:	100017b7          	lui	a5,0x10001
    800059cc:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800059d0:	100017b7          	lui	a5,0x10001
    800059d4:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    800059d8:	439c                	lw	a5,0(a5)
    800059da:	2781                	sext.w	a5,a5
    800059dc:	10079a63          	bnez	a5,80005af0 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800059e0:	100017b7          	lui	a5,0x10001
    800059e4:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    800059e8:	439c                	lw	a5,0(a5)
    800059ea:	2781                	sext.w	a5,a5
  if(max == 0)
    800059ec:	10078863          	beqz	a5,80005afc <virtio_disk_init+0x1d4>
  if(max < NUM)
    800059f0:	471d                	li	a4,7
    800059f2:	10f77b63          	bgeu	a4,a5,80005b08 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    800059f6:	97cfb0ef          	jal	80000b72 <kalloc>
    800059fa:	0012b497          	auipc	s1,0x12b
    800059fe:	6a648493          	addi	s1,s1,1702 # 801310a0 <disk>
    80005a02:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005a04:	96efb0ef          	jal	80000b72 <kalloc>
    80005a08:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005a0a:	968fb0ef          	jal	80000b72 <kalloc>
    80005a0e:	87aa                	mv	a5,a0
    80005a10:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005a12:	6088                	ld	a0,0(s1)
    80005a14:	10050063          	beqz	a0,80005b14 <virtio_disk_init+0x1ec>
    80005a18:	0012b717          	auipc	a4,0x12b
    80005a1c:	69073703          	ld	a4,1680(a4) # 801310a8 <disk+0x8>
    80005a20:	0e070a63          	beqz	a4,80005b14 <virtio_disk_init+0x1ec>
    80005a24:	0e078863          	beqz	a5,80005b14 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005a28:	6605                	lui	a2,0x1
    80005a2a:	4581                	li	a1,0
    80005a2c:	baafb0ef          	jal	80000dd6 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005a30:	0012b497          	auipc	s1,0x12b
    80005a34:	67048493          	addi	s1,s1,1648 # 801310a0 <disk>
    80005a38:	6605                	lui	a2,0x1
    80005a3a:	4581                	li	a1,0
    80005a3c:	6488                	ld	a0,8(s1)
    80005a3e:	b98fb0ef          	jal	80000dd6 <memset>
  memset(disk.used, 0, PGSIZE);
    80005a42:	6605                	lui	a2,0x1
    80005a44:	4581                	li	a1,0
    80005a46:	6888                	ld	a0,16(s1)
    80005a48:	b8efb0ef          	jal	80000dd6 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005a4c:	100017b7          	lui	a5,0x10001
    80005a50:	4721                	li	a4,8
    80005a52:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005a54:	4098                	lw	a4,0(s1)
    80005a56:	100017b7          	lui	a5,0x10001
    80005a5a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005a5e:	40d8                	lw	a4,4(s1)
    80005a60:	100017b7          	lui	a5,0x10001
    80005a64:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005a68:	649c                	ld	a5,8(s1)
    80005a6a:	0007869b          	sext.w	a3,a5
    80005a6e:	10001737          	lui	a4,0x10001
    80005a72:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005a76:	9781                	srai	a5,a5,0x20
    80005a78:	10001737          	lui	a4,0x10001
    80005a7c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005a80:	689c                	ld	a5,16(s1)
    80005a82:	0007869b          	sext.w	a3,a5
    80005a86:	10001737          	lui	a4,0x10001
    80005a8a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005a8e:	9781                	srai	a5,a5,0x20
    80005a90:	10001737          	lui	a4,0x10001
    80005a94:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005a98:	10001737          	lui	a4,0x10001
    80005a9c:	4785                	li	a5,1
    80005a9e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005aa0:	00f48c23          	sb	a5,24(s1)
    80005aa4:	00f48ca3          	sb	a5,25(s1)
    80005aa8:	00f48d23          	sb	a5,26(s1)
    80005aac:	00f48da3          	sb	a5,27(s1)
    80005ab0:	00f48e23          	sb	a5,28(s1)
    80005ab4:	00f48ea3          	sb	a5,29(s1)
    80005ab8:	00f48f23          	sb	a5,30(s1)
    80005abc:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005ac0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ac4:	100017b7          	lui	a5,0x10001
    80005ac8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80005acc:	60e2                	ld	ra,24(sp)
    80005ace:	6442                	ld	s0,16(sp)
    80005ad0:	64a2                	ld	s1,8(sp)
    80005ad2:	6902                	ld	s2,0(sp)
    80005ad4:	6105                	addi	sp,sp,32
    80005ad6:	8082                	ret
    panic("could not find virtio disk");
    80005ad8:	00002517          	auipc	a0,0x2
    80005adc:	ba050513          	addi	a0,a0,-1120 # 80007678 <etext+0x678>
    80005ae0:	d01fa0ef          	jal	800007e0 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005ae4:	00002517          	auipc	a0,0x2
    80005ae8:	bb450513          	addi	a0,a0,-1100 # 80007698 <etext+0x698>
    80005aec:	cf5fa0ef          	jal	800007e0 <panic>
    panic("virtio disk should not be ready");
    80005af0:	00002517          	auipc	a0,0x2
    80005af4:	bc850513          	addi	a0,a0,-1080 # 800076b8 <etext+0x6b8>
    80005af8:	ce9fa0ef          	jal	800007e0 <panic>
    panic("virtio disk has no queue 0");
    80005afc:	00002517          	auipc	a0,0x2
    80005b00:	bdc50513          	addi	a0,a0,-1060 # 800076d8 <etext+0x6d8>
    80005b04:	cddfa0ef          	jal	800007e0 <panic>
    panic("virtio disk max queue too short");
    80005b08:	00002517          	auipc	a0,0x2
    80005b0c:	bf050513          	addi	a0,a0,-1040 # 800076f8 <etext+0x6f8>
    80005b10:	cd1fa0ef          	jal	800007e0 <panic>
    panic("virtio disk kalloc");
    80005b14:	00002517          	auipc	a0,0x2
    80005b18:	c0450513          	addi	a0,a0,-1020 # 80007718 <etext+0x718>
    80005b1c:	cc5fa0ef          	jal	800007e0 <panic>

0000000080005b20 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005b20:	7159                	addi	sp,sp,-112
    80005b22:	f486                	sd	ra,104(sp)
    80005b24:	f0a2                	sd	s0,96(sp)
    80005b26:	eca6                	sd	s1,88(sp)
    80005b28:	e8ca                	sd	s2,80(sp)
    80005b2a:	e4ce                	sd	s3,72(sp)
    80005b2c:	e0d2                	sd	s4,64(sp)
    80005b2e:	fc56                	sd	s5,56(sp)
    80005b30:	f85a                	sd	s6,48(sp)
    80005b32:	f45e                	sd	s7,40(sp)
    80005b34:	f062                	sd	s8,32(sp)
    80005b36:	ec66                	sd	s9,24(sp)
    80005b38:	1880                	addi	s0,sp,112
    80005b3a:	8a2a                	mv	s4,a0
    80005b3c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005b3e:	00c52c83          	lw	s9,12(a0)
    80005b42:	001c9c9b          	slliw	s9,s9,0x1
    80005b46:	1c82                	slli	s9,s9,0x20
    80005b48:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005b4c:	0012b517          	auipc	a0,0x12b
    80005b50:	67c50513          	addi	a0,a0,1660 # 801311c8 <disk+0x128>
    80005b54:	9aefb0ef          	jal	80000d02 <acquire>
  for(int i = 0; i < 3; i++){
    80005b58:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005b5a:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005b5c:	0012bb17          	auipc	s6,0x12b
    80005b60:	544b0b13          	addi	s6,s6,1348 # 801310a0 <disk>
  for(int i = 0; i < 3; i++){
    80005b64:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005b66:	0012bc17          	auipc	s8,0x12b
    80005b6a:	662c0c13          	addi	s8,s8,1634 # 801311c8 <disk+0x128>
    80005b6e:	a8b9                	j	80005bcc <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005b70:	00fb0733          	add	a4,s6,a5
    80005b74:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005b78:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005b7a:	0207c563          	bltz	a5,80005ba4 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    80005b7e:	2905                	addiw	s2,s2,1
    80005b80:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005b82:	05590963          	beq	s2,s5,80005bd4 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005b86:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005b88:	0012b717          	auipc	a4,0x12b
    80005b8c:	51870713          	addi	a4,a4,1304 # 801310a0 <disk>
    80005b90:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005b92:	01874683          	lbu	a3,24(a4)
    80005b96:	fee9                	bnez	a3,80005b70 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005b98:	2785                	addiw	a5,a5,1
    80005b9a:	0705                	addi	a4,a4,1
    80005b9c:	fe979be3          	bne	a5,s1,80005b92 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005ba0:	57fd                	li	a5,-1
    80005ba2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005ba4:	01205d63          	blez	s2,80005bbe <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005ba8:	f9042503          	lw	a0,-112(s0)
    80005bac:	d07ff0ef          	jal	800058b2 <free_desc>
      for(int j = 0; j < i; j++)
    80005bb0:	4785                	li	a5,1
    80005bb2:	0127d663          	bge	a5,s2,80005bbe <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005bb6:	f9442503          	lw	a0,-108(s0)
    80005bba:	cf9ff0ef          	jal	800058b2 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005bbe:	85e2                	mv	a1,s8
    80005bc0:	0012b517          	auipc	a0,0x12b
    80005bc4:	4f850513          	addi	a0,a0,1272 # 801310b8 <disk+0x18>
    80005bc8:	db4fc0ef          	jal	8000217c <sleep>
  for(int i = 0; i < 3; i++){
    80005bcc:	f9040613          	addi	a2,s0,-112
    80005bd0:	894e                	mv	s2,s3
    80005bd2:	bf55                	j	80005b86 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005bd4:	f9042503          	lw	a0,-112(s0)
    80005bd8:	00451693          	slli	a3,a0,0x4

  if(write)
    80005bdc:	0012b797          	auipc	a5,0x12b
    80005be0:	4c478793          	addi	a5,a5,1220 # 801310a0 <disk>
    80005be4:	00a50713          	addi	a4,a0,10
    80005be8:	0712                	slli	a4,a4,0x4
    80005bea:	973e                	add	a4,a4,a5
    80005bec:	01703633          	snez	a2,s7
    80005bf0:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005bf2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005bf6:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005bfa:	6398                	ld	a4,0(a5)
    80005bfc:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005bfe:	0a868613          	addi	a2,a3,168
    80005c02:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005c04:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005c06:	6390                	ld	a2,0(a5)
    80005c08:	00d605b3          	add	a1,a2,a3
    80005c0c:	4741                	li	a4,16
    80005c0e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005c10:	4805                	li	a6,1
    80005c12:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005c16:	f9442703          	lw	a4,-108(s0)
    80005c1a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005c1e:	0712                	slli	a4,a4,0x4
    80005c20:	963a                	add	a2,a2,a4
    80005c22:	058a0593          	addi	a1,s4,88
    80005c26:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005c28:	0007b883          	ld	a7,0(a5)
    80005c2c:	9746                	add	a4,a4,a7
    80005c2e:	40000613          	li	a2,1024
    80005c32:	c710                	sw	a2,8(a4)
  if(write)
    80005c34:	001bb613          	seqz	a2,s7
    80005c38:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005c3c:	00166613          	ori	a2,a2,1
    80005c40:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005c44:	f9842583          	lw	a1,-104(s0)
    80005c48:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005c4c:	00250613          	addi	a2,a0,2
    80005c50:	0612                	slli	a2,a2,0x4
    80005c52:	963e                	add	a2,a2,a5
    80005c54:	577d                	li	a4,-1
    80005c56:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005c5a:	0592                	slli	a1,a1,0x4
    80005c5c:	98ae                	add	a7,a7,a1
    80005c5e:	03068713          	addi	a4,a3,48
    80005c62:	973e                	add	a4,a4,a5
    80005c64:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005c68:	6398                	ld	a4,0(a5)
    80005c6a:	972e                	add	a4,a4,a1
    80005c6c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005c70:	4689                	li	a3,2
    80005c72:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005c76:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005c7a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80005c7e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005c82:	6794                	ld	a3,8(a5)
    80005c84:	0026d703          	lhu	a4,2(a3)
    80005c88:	8b1d                	andi	a4,a4,7
    80005c8a:	0706                	slli	a4,a4,0x1
    80005c8c:	96ba                	add	a3,a3,a4
    80005c8e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005c92:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005c96:	6798                	ld	a4,8(a5)
    80005c98:	00275783          	lhu	a5,2(a4)
    80005c9c:	2785                	addiw	a5,a5,1
    80005c9e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005ca2:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005ca6:	100017b7          	lui	a5,0x10001
    80005caa:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005cae:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005cb2:	0012b917          	auipc	s2,0x12b
    80005cb6:	51690913          	addi	s2,s2,1302 # 801311c8 <disk+0x128>
  while(b->disk == 1) {
    80005cba:	4485                	li	s1,1
    80005cbc:	01079a63          	bne	a5,a6,80005cd0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005cc0:	85ca                	mv	a1,s2
    80005cc2:	8552                	mv	a0,s4
    80005cc4:	cb8fc0ef          	jal	8000217c <sleep>
  while(b->disk == 1) {
    80005cc8:	004a2783          	lw	a5,4(s4)
    80005ccc:	fe978ae3          	beq	a5,s1,80005cc0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005cd0:	f9042903          	lw	s2,-112(s0)
    80005cd4:	00290713          	addi	a4,s2,2
    80005cd8:	0712                	slli	a4,a4,0x4
    80005cda:	0012b797          	auipc	a5,0x12b
    80005cde:	3c678793          	addi	a5,a5,966 # 801310a0 <disk>
    80005ce2:	97ba                	add	a5,a5,a4
    80005ce4:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005ce8:	0012b997          	auipc	s3,0x12b
    80005cec:	3b898993          	addi	s3,s3,952 # 801310a0 <disk>
    80005cf0:	00491713          	slli	a4,s2,0x4
    80005cf4:	0009b783          	ld	a5,0(s3)
    80005cf8:	97ba                	add	a5,a5,a4
    80005cfa:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005cfe:	854a                	mv	a0,s2
    80005d00:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005d04:	bafff0ef          	jal	800058b2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005d08:	8885                	andi	s1,s1,1
    80005d0a:	f0fd                	bnez	s1,80005cf0 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005d0c:	0012b517          	auipc	a0,0x12b
    80005d10:	4bc50513          	addi	a0,a0,1212 # 801311c8 <disk+0x128>
    80005d14:	886fb0ef          	jal	80000d9a <release>
}
    80005d18:	70a6                	ld	ra,104(sp)
    80005d1a:	7406                	ld	s0,96(sp)
    80005d1c:	64e6                	ld	s1,88(sp)
    80005d1e:	6946                	ld	s2,80(sp)
    80005d20:	69a6                	ld	s3,72(sp)
    80005d22:	6a06                	ld	s4,64(sp)
    80005d24:	7ae2                	ld	s5,56(sp)
    80005d26:	7b42                	ld	s6,48(sp)
    80005d28:	7ba2                	ld	s7,40(sp)
    80005d2a:	7c02                	ld	s8,32(sp)
    80005d2c:	6ce2                	ld	s9,24(sp)
    80005d2e:	6165                	addi	sp,sp,112
    80005d30:	8082                	ret

0000000080005d32 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005d32:	1101                	addi	sp,sp,-32
    80005d34:	ec06                	sd	ra,24(sp)
    80005d36:	e822                	sd	s0,16(sp)
    80005d38:	e426                	sd	s1,8(sp)
    80005d3a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005d3c:	0012b497          	auipc	s1,0x12b
    80005d40:	36448493          	addi	s1,s1,868 # 801310a0 <disk>
    80005d44:	0012b517          	auipc	a0,0x12b
    80005d48:	48450513          	addi	a0,a0,1156 # 801311c8 <disk+0x128>
    80005d4c:	fb7fa0ef          	jal	80000d02 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005d50:	100017b7          	lui	a5,0x10001
    80005d54:	53b8                	lw	a4,96(a5)
    80005d56:	8b0d                	andi	a4,a4,3
    80005d58:	100017b7          	lui	a5,0x10001
    80005d5c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80005d5e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005d62:	689c                	ld	a5,16(s1)
    80005d64:	0204d703          	lhu	a4,32(s1)
    80005d68:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005d6c:	04f70663          	beq	a4,a5,80005db8 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005d70:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005d74:	6898                	ld	a4,16(s1)
    80005d76:	0204d783          	lhu	a5,32(s1)
    80005d7a:	8b9d                	andi	a5,a5,7
    80005d7c:	078e                	slli	a5,a5,0x3
    80005d7e:	97ba                	add	a5,a5,a4
    80005d80:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005d82:	00278713          	addi	a4,a5,2
    80005d86:	0712                	slli	a4,a4,0x4
    80005d88:	9726                	add	a4,a4,s1
    80005d8a:	01074703          	lbu	a4,16(a4)
    80005d8e:	e321                	bnez	a4,80005dce <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005d90:	0789                	addi	a5,a5,2
    80005d92:	0792                	slli	a5,a5,0x4
    80005d94:	97a6                	add	a5,a5,s1
    80005d96:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005d98:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005d9c:	c2cfc0ef          	jal	800021c8 <wakeup>

    disk.used_idx += 1;
    80005da0:	0204d783          	lhu	a5,32(s1)
    80005da4:	2785                	addiw	a5,a5,1
    80005da6:	17c2                	slli	a5,a5,0x30
    80005da8:	93c1                	srli	a5,a5,0x30
    80005daa:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005dae:	6898                	ld	a4,16(s1)
    80005db0:	00275703          	lhu	a4,2(a4)
    80005db4:	faf71ee3          	bne	a4,a5,80005d70 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005db8:	0012b517          	auipc	a0,0x12b
    80005dbc:	41050513          	addi	a0,a0,1040 # 801311c8 <disk+0x128>
    80005dc0:	fdbfa0ef          	jal	80000d9a <release>
}
    80005dc4:	60e2                	ld	ra,24(sp)
    80005dc6:	6442                	ld	s0,16(sp)
    80005dc8:	64a2                	ld	s1,8(sp)
    80005dca:	6105                	addi	sp,sp,32
    80005dcc:	8082                	ret
      panic("virtio_disk_intr status");
    80005dce:	00002517          	auipc	a0,0x2
    80005dd2:	96250513          	addi	a0,a0,-1694 # 80007730 <etext+0x730>
    80005dd6:	a0bfa0ef          	jal	800007e0 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
