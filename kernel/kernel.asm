
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000c117          	auipc	sp,0xc
    80000004:	80010113          	addi	sp,sp,-2048 # 8000b800 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	070000ef          	jal	ra,80000086 <start>

000000008000001a <junk>:
    8000001a:	a001                	j	8000001a <junk>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80000026:	0037969b          	slliw	a3,a5,0x3
    8000002a:	02004737          	lui	a4,0x2004
    8000002e:	96ba                	add	a3,a3,a4
    80000030:	0200c737          	lui	a4,0x200c
    80000034:	ff873603          	ld	a2,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80000038:	000f4737          	lui	a4,0xf4
    8000003c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000040:	963a                	add	a2,a2,a4
    80000042:	e290                	sd	a2,0(a3)

  // prepare information in scratch[] for timervec.
  // scratch[0..3] : space for timervec to save registers.
  // scratch[4] : address of CLINT MTIMECMP register.
  // scratch[5] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &mscratch0[32 * id];
    80000044:	0057979b          	slliw	a5,a5,0x5
    80000048:	078e                	slli	a5,a5,0x3
    8000004a:	0000b617          	auipc	a2,0xb
    8000004e:	fb660613          	addi	a2,a2,-74 # 8000b000 <mscratch0>
    80000052:	97b2                	add	a5,a5,a2
  scratch[4] = CLINT_MTIMECMP(id);
    80000054:	f394                	sd	a3,32(a5)
  scratch[5] = interval;
    80000056:	f798                	sd	a4,40(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000058:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000005c:	00006797          	auipc	a5,0x6
    80000060:	e4478793          	addi	a5,a5,-444 # 80005ea0 <timervec>
    80000064:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000006c:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000074:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000078:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000007c:	30479073          	csrw	mie,a5
}
    80000080:	6422                	ld	s0,8(sp)
    80000082:	0141                	addi	sp,sp,16
    80000084:	8082                	ret

0000000080000086 <start>:
{
    80000086:	1141                	addi	sp,sp,-16
    80000088:	e406                	sd	ra,8(sp)
    8000008a:	e022                	sd	s0,0(sp)
    8000008c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000008e:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000092:	7779                	lui	a4,0xffffe
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd5453>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	e7678793          	addi	a5,a5,-394 # 80000f1c <main>
    800000ae:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b2:	4781                	li	a5,0
    800000b4:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000b8:	67c1                	lui	a5,0x10
    800000ba:	17fd                	addi	a5,a5,-1
    800000bc:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c0:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000c4:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000c8:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000cc:	10479073          	csrw	sie,a5
  timerinit();
    800000d0:	00000097          	auipc	ra,0x0
    800000d4:	f4c080e7          	jalr	-180(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000d8:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000dc:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000de:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e0:	30200073          	mret
}
    800000e4:	60a2                	ld	ra,8(sp)
    800000e6:	6402                	ld	s0,0(sp)
    800000e8:	0141                	addi	sp,sp,16
    800000ea:	8082                	ret

00000000800000ec <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(struct file *f, int user_dst, uint64 dst, int n)
{
    800000ec:	7159                	addi	sp,sp,-112
    800000ee:	f486                	sd	ra,104(sp)
    800000f0:	f0a2                	sd	s0,96(sp)
    800000f2:	eca6                	sd	s1,88(sp)
    800000f4:	e8ca                	sd	s2,80(sp)
    800000f6:	e4ce                	sd	s3,72(sp)
    800000f8:	e0d2                	sd	s4,64(sp)
    800000fa:	fc56                	sd	s5,56(sp)
    800000fc:	f85a                	sd	s6,48(sp)
    800000fe:	f45e                	sd	s7,40(sp)
    80000100:	f062                	sd	s8,32(sp)
    80000102:	ec66                	sd	s9,24(sp)
    80000104:	e86a                	sd	s10,16(sp)
    80000106:	1880                	addi	s0,sp,112
    80000108:	8aae                	mv	s5,a1
    8000010a:	8a32                	mv	s4,a2
    8000010c:	89b6                	mv	s3,a3
  uint target;
  int c;
  char cbuf;

  target = n;
    8000010e:	00068b1b          	sext.w	s6,a3
  acquire(&cons.lock);
    80000112:	00013517          	auipc	a0,0x13
    80000116:	6ee50513          	addi	a0,a0,1774 # 80013800 <cons>
    8000011a:	00001097          	auipc	ra,0x1
    8000011e:	986080e7          	jalr	-1658(ra) # 80000aa0 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000122:	00013497          	auipc	s1,0x13
    80000126:	6de48493          	addi	s1,s1,1758 # 80013800 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000012a:	00013917          	auipc	s2,0x13
    8000012e:	77690913          	addi	s2,s2,1910 # 800138a0 <cons+0xa0>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    80000132:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000134:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    80000136:	4ca9                	li	s9,10
  while(n > 0){
    80000138:	07305863          	blez	s3,800001a8 <consoleread+0xbc>
    while(cons.r == cons.w){
    8000013c:	0a04a783          	lw	a5,160(s1)
    80000140:	0a44a703          	lw	a4,164(s1)
    80000144:	02f71463          	bne	a4,a5,8000016c <consoleread+0x80>
      if(myproc()->killed){
    80000148:	00002097          	auipc	ra,0x2
    8000014c:	94c080e7          	jalr	-1716(ra) # 80001a94 <myproc>
    80000150:	5d1c                	lw	a5,56(a0)
    80000152:	e7b5                	bnez	a5,800001be <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    80000154:	85a6                	mv	a1,s1
    80000156:	854a                	mv	a0,s2
    80000158:	00002097          	auipc	ra,0x2
    8000015c:	0fc080e7          	jalr	252(ra) # 80002254 <sleep>
    while(cons.r == cons.w){
    80000160:	0a04a783          	lw	a5,160(s1)
    80000164:	0a44a703          	lw	a4,164(s1)
    80000168:	fef700e3          	beq	a4,a5,80000148 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    8000016c:	0017871b          	addiw	a4,a5,1
    80000170:	0ae4a023          	sw	a4,160(s1)
    80000174:	07f7f713          	andi	a4,a5,127
    80000178:	9726                	add	a4,a4,s1
    8000017a:	02074703          	lbu	a4,32(a4)
    8000017e:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000182:	077d0563          	beq	s10,s7,800001ec <consoleread+0x100>
    cbuf = c;
    80000186:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000018a:	4685                	li	a3,1
    8000018c:	f9f40613          	addi	a2,s0,-97
    80000190:	85d2                	mv	a1,s4
    80000192:	8556                	mv	a0,s5
    80000194:	00002097          	auipc	ra,0x2
    80000198:	31a080e7          	jalr	794(ra) # 800024ae <either_copyout>
    8000019c:	01850663          	beq	a0,s8,800001a8 <consoleread+0xbc>
    dst++;
    800001a0:	0a05                	addi	s4,s4,1
    --n;
    800001a2:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    800001a4:	f99d1ae3          	bne	s10,s9,80000138 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    800001a8:	00013517          	auipc	a0,0x13
    800001ac:	65850513          	addi	a0,a0,1624 # 80013800 <cons>
    800001b0:	00001097          	auipc	ra,0x1
    800001b4:	9c0080e7          	jalr	-1600(ra) # 80000b70 <release>

  return target - n;
    800001b8:	413b053b          	subw	a0,s6,s3
    800001bc:	a811                	j	800001d0 <consoleread+0xe4>
        release(&cons.lock);
    800001be:	00013517          	auipc	a0,0x13
    800001c2:	64250513          	addi	a0,a0,1602 # 80013800 <cons>
    800001c6:	00001097          	auipc	ra,0x1
    800001ca:	9aa080e7          	jalr	-1622(ra) # 80000b70 <release>
        return -1;
    800001ce:	557d                	li	a0,-1
}
    800001d0:	70a6                	ld	ra,104(sp)
    800001d2:	7406                	ld	s0,96(sp)
    800001d4:	64e6                	ld	s1,88(sp)
    800001d6:	6946                	ld	s2,80(sp)
    800001d8:	69a6                	ld	s3,72(sp)
    800001da:	6a06                	ld	s4,64(sp)
    800001dc:	7ae2                	ld	s5,56(sp)
    800001de:	7b42                	ld	s6,48(sp)
    800001e0:	7ba2                	ld	s7,40(sp)
    800001e2:	7c02                	ld	s8,32(sp)
    800001e4:	6ce2                	ld	s9,24(sp)
    800001e6:	6d42                	ld	s10,16(sp)
    800001e8:	6165                	addi	sp,sp,112
    800001ea:	8082                	ret
      if(n < target){
    800001ec:	0009871b          	sext.w	a4,s3
    800001f0:	fb677ce3          	bgeu	a4,s6,800001a8 <consoleread+0xbc>
        cons.r--;
    800001f4:	00013717          	auipc	a4,0x13
    800001f8:	6af72623          	sw	a5,1708(a4) # 800138a0 <cons+0xa0>
    800001fc:	b775                	j	800001a8 <consoleread+0xbc>

00000000800001fe <consputc>:
  if(panicked){
    800001fe:	00029797          	auipc	a5,0x29
    80000202:	1627a783          	lw	a5,354(a5) # 80029360 <panicked>
    80000206:	c391                	beqz	a5,8000020a <consputc+0xc>
    for(;;)
    80000208:	a001                	j	80000208 <consputc+0xa>
{
    8000020a:	1141                	addi	sp,sp,-16
    8000020c:	e406                	sd	ra,8(sp)
    8000020e:	e022                	sd	s0,0(sp)
    80000210:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000212:	10000793          	li	a5,256
    80000216:	00f50a63          	beq	a0,a5,8000022a <consputc+0x2c>
    uartputc(c);
    8000021a:	00000097          	auipc	ra,0x0
    8000021e:	5dc080e7          	jalr	1500(ra) # 800007f6 <uartputc>
}
    80000222:	60a2                	ld	ra,8(sp)
    80000224:	6402                	ld	s0,0(sp)
    80000226:	0141                	addi	sp,sp,16
    80000228:	8082                	ret
    uartputc('\b'); uartputc(' '); uartputc('\b');
    8000022a:	4521                	li	a0,8
    8000022c:	00000097          	auipc	ra,0x0
    80000230:	5ca080e7          	jalr	1482(ra) # 800007f6 <uartputc>
    80000234:	02000513          	li	a0,32
    80000238:	00000097          	auipc	ra,0x0
    8000023c:	5be080e7          	jalr	1470(ra) # 800007f6 <uartputc>
    80000240:	4521                	li	a0,8
    80000242:	00000097          	auipc	ra,0x0
    80000246:	5b4080e7          	jalr	1460(ra) # 800007f6 <uartputc>
    8000024a:	bfe1                	j	80000222 <consputc+0x24>

000000008000024c <consolewrite>:
{
    8000024c:	715d                	addi	sp,sp,-80
    8000024e:	e486                	sd	ra,72(sp)
    80000250:	e0a2                	sd	s0,64(sp)
    80000252:	fc26                	sd	s1,56(sp)
    80000254:	f84a                	sd	s2,48(sp)
    80000256:	f44e                	sd	s3,40(sp)
    80000258:	f052                	sd	s4,32(sp)
    8000025a:	ec56                	sd	s5,24(sp)
    8000025c:	0880                	addi	s0,sp,80
    8000025e:	89ae                	mv	s3,a1
    80000260:	84b2                	mv	s1,a2
    80000262:	8ab6                	mv	s5,a3
  acquire(&cons.lock);
    80000264:	00013517          	auipc	a0,0x13
    80000268:	59c50513          	addi	a0,a0,1436 # 80013800 <cons>
    8000026c:	00001097          	auipc	ra,0x1
    80000270:	834080e7          	jalr	-1996(ra) # 80000aa0 <acquire>
  for(i = 0; i < n; i++){
    80000274:	03505e63          	blez	s5,800002b0 <consolewrite+0x64>
    80000278:	00148913          	addi	s2,s1,1
    8000027c:	fffa879b          	addiw	a5,s5,-1
    80000280:	1782                	slli	a5,a5,0x20
    80000282:	9381                	srli	a5,a5,0x20
    80000284:	993e                	add	s2,s2,a5
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000286:	5a7d                	li	s4,-1
    80000288:	4685                	li	a3,1
    8000028a:	8626                	mv	a2,s1
    8000028c:	85ce                	mv	a1,s3
    8000028e:	fbf40513          	addi	a0,s0,-65
    80000292:	00002097          	auipc	ra,0x2
    80000296:	272080e7          	jalr	626(ra) # 80002504 <either_copyin>
    8000029a:	01450b63          	beq	a0,s4,800002b0 <consolewrite+0x64>
    consputc(c);
    8000029e:	fbf44503          	lbu	a0,-65(s0)
    800002a2:	00000097          	auipc	ra,0x0
    800002a6:	f5c080e7          	jalr	-164(ra) # 800001fe <consputc>
  for(i = 0; i < n; i++){
    800002aa:	0485                	addi	s1,s1,1
    800002ac:	fd249ee3          	bne	s1,s2,80000288 <consolewrite+0x3c>
  release(&cons.lock);
    800002b0:	00013517          	auipc	a0,0x13
    800002b4:	55050513          	addi	a0,a0,1360 # 80013800 <cons>
    800002b8:	00001097          	auipc	ra,0x1
    800002bc:	8b8080e7          	jalr	-1864(ra) # 80000b70 <release>
}
    800002c0:	8556                	mv	a0,s5
    800002c2:	60a6                	ld	ra,72(sp)
    800002c4:	6406                	ld	s0,64(sp)
    800002c6:	74e2                	ld	s1,56(sp)
    800002c8:	7942                	ld	s2,48(sp)
    800002ca:	79a2                	ld	s3,40(sp)
    800002cc:	7a02                	ld	s4,32(sp)
    800002ce:	6ae2                	ld	s5,24(sp)
    800002d0:	6161                	addi	sp,sp,80
    800002d2:	8082                	ret

00000000800002d4 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002d4:	1101                	addi	sp,sp,-32
    800002d6:	ec06                	sd	ra,24(sp)
    800002d8:	e822                	sd	s0,16(sp)
    800002da:	e426                	sd	s1,8(sp)
    800002dc:	e04a                	sd	s2,0(sp)
    800002de:	1000                	addi	s0,sp,32
    800002e0:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002e2:	00013517          	auipc	a0,0x13
    800002e6:	51e50513          	addi	a0,a0,1310 # 80013800 <cons>
    800002ea:	00000097          	auipc	ra,0x0
    800002ee:	7b6080e7          	jalr	1974(ra) # 80000aa0 <acquire>

  switch(c){
    800002f2:	47d5                	li	a5,21
    800002f4:	0af48663          	beq	s1,a5,800003a0 <consoleintr+0xcc>
    800002f8:	0297ca63          	blt	a5,s1,8000032c <consoleintr+0x58>
    800002fc:	47a1                	li	a5,8
    800002fe:	0ef48763          	beq	s1,a5,800003ec <consoleintr+0x118>
    80000302:	47c1                	li	a5,16
    80000304:	10f49a63          	bne	s1,a5,80000418 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    80000308:	00002097          	auipc	ra,0x2
    8000030c:	252080e7          	jalr	594(ra) # 8000255a <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000310:	00013517          	auipc	a0,0x13
    80000314:	4f050513          	addi	a0,a0,1264 # 80013800 <cons>
    80000318:	00001097          	auipc	ra,0x1
    8000031c:	858080e7          	jalr	-1960(ra) # 80000b70 <release>
}
    80000320:	60e2                	ld	ra,24(sp)
    80000322:	6442                	ld	s0,16(sp)
    80000324:	64a2                	ld	s1,8(sp)
    80000326:	6902                	ld	s2,0(sp)
    80000328:	6105                	addi	sp,sp,32
    8000032a:	8082                	ret
  switch(c){
    8000032c:	07f00793          	li	a5,127
    80000330:	0af48e63          	beq	s1,a5,800003ec <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000334:	00013717          	auipc	a4,0x13
    80000338:	4cc70713          	addi	a4,a4,1228 # 80013800 <cons>
    8000033c:	0a872783          	lw	a5,168(a4)
    80000340:	0a072703          	lw	a4,160(a4)
    80000344:	9f99                	subw	a5,a5,a4
    80000346:	07f00713          	li	a4,127
    8000034a:	fcf763e3          	bltu	a4,a5,80000310 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    8000034e:	47b5                	li	a5,13
    80000350:	0cf48763          	beq	s1,a5,8000041e <consoleintr+0x14a>
      consputc(c);
    80000354:	8526                	mv	a0,s1
    80000356:	00000097          	auipc	ra,0x0
    8000035a:	ea8080e7          	jalr	-344(ra) # 800001fe <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000035e:	00013797          	auipc	a5,0x13
    80000362:	4a278793          	addi	a5,a5,1186 # 80013800 <cons>
    80000366:	0a87a703          	lw	a4,168(a5)
    8000036a:	0017069b          	addiw	a3,a4,1
    8000036e:	0006861b          	sext.w	a2,a3
    80000372:	0ad7a423          	sw	a3,168(a5)
    80000376:	07f77713          	andi	a4,a4,127
    8000037a:	97ba                	add	a5,a5,a4
    8000037c:	02978023          	sb	s1,32(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000380:	47a9                	li	a5,10
    80000382:	0cf48563          	beq	s1,a5,8000044c <consoleintr+0x178>
    80000386:	4791                	li	a5,4
    80000388:	0cf48263          	beq	s1,a5,8000044c <consoleintr+0x178>
    8000038c:	00013797          	auipc	a5,0x13
    80000390:	5147a783          	lw	a5,1300(a5) # 800138a0 <cons+0xa0>
    80000394:	0807879b          	addiw	a5,a5,128
    80000398:	f6f61ce3          	bne	a2,a5,80000310 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000039c:	863e                	mv	a2,a5
    8000039e:	a07d                	j	8000044c <consoleintr+0x178>
    while(cons.e != cons.w &&
    800003a0:	00013717          	auipc	a4,0x13
    800003a4:	46070713          	addi	a4,a4,1120 # 80013800 <cons>
    800003a8:	0a872783          	lw	a5,168(a4)
    800003ac:	0a472703          	lw	a4,164(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003b0:	00013497          	auipc	s1,0x13
    800003b4:	45048493          	addi	s1,s1,1104 # 80013800 <cons>
    while(cons.e != cons.w &&
    800003b8:	4929                	li	s2,10
    800003ba:	f4f70be3          	beq	a4,a5,80000310 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003be:	37fd                	addiw	a5,a5,-1
    800003c0:	07f7f713          	andi	a4,a5,127
    800003c4:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003c6:	02074703          	lbu	a4,32(a4)
    800003ca:	f52703e3          	beq	a4,s2,80000310 <consoleintr+0x3c>
      cons.e--;
    800003ce:	0af4a423          	sw	a5,168(s1)
      consputc(BACKSPACE);
    800003d2:	10000513          	li	a0,256
    800003d6:	00000097          	auipc	ra,0x0
    800003da:	e28080e7          	jalr	-472(ra) # 800001fe <consputc>
    while(cons.e != cons.w &&
    800003de:	0a84a783          	lw	a5,168(s1)
    800003e2:	0a44a703          	lw	a4,164(s1)
    800003e6:	fcf71ce3          	bne	a4,a5,800003be <consoleintr+0xea>
    800003ea:	b71d                	j	80000310 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003ec:	00013717          	auipc	a4,0x13
    800003f0:	41470713          	addi	a4,a4,1044 # 80013800 <cons>
    800003f4:	0a872783          	lw	a5,168(a4)
    800003f8:	0a472703          	lw	a4,164(a4)
    800003fc:	f0f70ae3          	beq	a4,a5,80000310 <consoleintr+0x3c>
      cons.e--;
    80000400:	37fd                	addiw	a5,a5,-1
    80000402:	00013717          	auipc	a4,0x13
    80000406:	4af72323          	sw	a5,1190(a4) # 800138a8 <cons+0xa8>
      consputc(BACKSPACE);
    8000040a:	10000513          	li	a0,256
    8000040e:	00000097          	auipc	ra,0x0
    80000412:	df0080e7          	jalr	-528(ra) # 800001fe <consputc>
    80000416:	bded                	j	80000310 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000418:	ee048ce3          	beqz	s1,80000310 <consoleintr+0x3c>
    8000041c:	bf21                	j	80000334 <consoleintr+0x60>
      consputc(c);
    8000041e:	4529                	li	a0,10
    80000420:	00000097          	auipc	ra,0x0
    80000424:	dde080e7          	jalr	-546(ra) # 800001fe <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000428:	00013797          	auipc	a5,0x13
    8000042c:	3d878793          	addi	a5,a5,984 # 80013800 <cons>
    80000430:	0a87a703          	lw	a4,168(a5)
    80000434:	0017069b          	addiw	a3,a4,1
    80000438:	0006861b          	sext.w	a2,a3
    8000043c:	0ad7a423          	sw	a3,168(a5)
    80000440:	07f77713          	andi	a4,a4,127
    80000444:	97ba                	add	a5,a5,a4
    80000446:	4729                	li	a4,10
    80000448:	02e78023          	sb	a4,32(a5)
        cons.w = cons.e;
    8000044c:	00013797          	auipc	a5,0x13
    80000450:	44c7ac23          	sw	a2,1112(a5) # 800138a4 <cons+0xa4>
        wakeup(&cons.r);
    80000454:	00013517          	auipc	a0,0x13
    80000458:	44c50513          	addi	a0,a0,1100 # 800138a0 <cons+0xa0>
    8000045c:	00002097          	auipc	ra,0x2
    80000460:	f78080e7          	jalr	-136(ra) # 800023d4 <wakeup>
    80000464:	b575                	j	80000310 <consoleintr+0x3c>

0000000080000466 <consoleinit>:

void
consoleinit(void)
{
    80000466:	1141                	addi	sp,sp,-16
    80000468:	e406                	sd	ra,8(sp)
    8000046a:	e022                	sd	s0,0(sp)
    8000046c:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000046e:	00009597          	auipc	a1,0x9
    80000472:	caa58593          	addi	a1,a1,-854 # 80009118 <userret+0x88>
    80000476:	00013517          	auipc	a0,0x13
    8000047a:	38a50513          	addi	a0,a0,906 # 80013800 <cons>
    8000047e:	00000097          	auipc	ra,0x0
    80000482:	54e080e7          	jalr	1358(ra) # 800009cc <initlock>

  uartinit();
    80000486:	00000097          	auipc	ra,0x0
    8000048a:	33a080e7          	jalr	826(ra) # 800007c0 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000048e:	00021797          	auipc	a5,0x21
    80000492:	bd278793          	addi	a5,a5,-1070 # 80021060 <devsw>
    80000496:	00000717          	auipc	a4,0x0
    8000049a:	c5670713          	addi	a4,a4,-938 # 800000ec <consoleread>
    8000049e:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800004a0:	00000717          	auipc	a4,0x0
    800004a4:	dac70713          	addi	a4,a4,-596 # 8000024c <consolewrite>
    800004a8:	ef98                	sd	a4,24(a5)
}
    800004aa:	60a2                	ld	ra,8(sp)
    800004ac:	6402                	ld	s0,0(sp)
    800004ae:	0141                	addi	sp,sp,16
    800004b0:	8082                	ret

00000000800004b2 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004b2:	7179                	addi	sp,sp,-48
    800004b4:	f406                	sd	ra,40(sp)
    800004b6:	f022                	sd	s0,32(sp)
    800004b8:	ec26                	sd	s1,24(sp)
    800004ba:	e84a                	sd	s2,16(sp)
    800004bc:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004be:	c219                	beqz	a2,800004c4 <printint+0x12>
    800004c0:	08054663          	bltz	a0,8000054c <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004c4:	2501                	sext.w	a0,a0
    800004c6:	4881                	li	a7,0
    800004c8:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004cc:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004ce:	2581                	sext.w	a1,a1
    800004d0:	0000a617          	auipc	a2,0xa
    800004d4:	89060613          	addi	a2,a2,-1904 # 80009d60 <digits>
    800004d8:	883a                	mv	a6,a4
    800004da:	2705                	addiw	a4,a4,1
    800004dc:	02b577bb          	remuw	a5,a0,a1
    800004e0:	1782                	slli	a5,a5,0x20
    800004e2:	9381                	srli	a5,a5,0x20
    800004e4:	97b2                	add	a5,a5,a2
    800004e6:	0007c783          	lbu	a5,0(a5)
    800004ea:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004ee:	0005079b          	sext.w	a5,a0
    800004f2:	02b5553b          	divuw	a0,a0,a1
    800004f6:	0685                	addi	a3,a3,1
    800004f8:	feb7f0e3          	bgeu	a5,a1,800004d8 <printint+0x26>

  if(sign)
    800004fc:	00088b63          	beqz	a7,80000512 <printint+0x60>
    buf[i++] = '-';
    80000500:	fe040793          	addi	a5,s0,-32
    80000504:	973e                	add	a4,a4,a5
    80000506:	02d00793          	li	a5,45
    8000050a:	fef70823          	sb	a5,-16(a4)
    8000050e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000512:	02e05763          	blez	a4,80000540 <printint+0x8e>
    80000516:	fd040793          	addi	a5,s0,-48
    8000051a:	00e784b3          	add	s1,a5,a4
    8000051e:	fff78913          	addi	s2,a5,-1
    80000522:	993a                	add	s2,s2,a4
    80000524:	377d                	addiw	a4,a4,-1
    80000526:	1702                	slli	a4,a4,0x20
    80000528:	9301                	srli	a4,a4,0x20
    8000052a:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000052e:	fff4c503          	lbu	a0,-1(s1)
    80000532:	00000097          	auipc	ra,0x0
    80000536:	ccc080e7          	jalr	-820(ra) # 800001fe <consputc>
  while(--i >= 0)
    8000053a:	14fd                	addi	s1,s1,-1
    8000053c:	ff2499e3          	bne	s1,s2,8000052e <printint+0x7c>
}
    80000540:	70a2                	ld	ra,40(sp)
    80000542:	7402                	ld	s0,32(sp)
    80000544:	64e2                	ld	s1,24(sp)
    80000546:	6942                	ld	s2,16(sp)
    80000548:	6145                	addi	sp,sp,48
    8000054a:	8082                	ret
    x = -xx;
    8000054c:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000550:	4885                	li	a7,1
    x = -xx;
    80000552:	bf9d                	j	800004c8 <printint+0x16>

0000000080000554 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000554:	1101                	addi	sp,sp,-32
    80000556:	ec06                	sd	ra,24(sp)
    80000558:	e822                	sd	s0,16(sp)
    8000055a:	e426                	sd	s1,8(sp)
    8000055c:	1000                	addi	s0,sp,32
    8000055e:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000560:	00013797          	auipc	a5,0x13
    80000564:	3607a823          	sw	zero,880(a5) # 800138d0 <pr+0x20>
  printf("PANIC: ");
    80000568:	00009517          	auipc	a0,0x9
    8000056c:	bb850513          	addi	a0,a0,-1096 # 80009120 <userret+0x90>
    80000570:	00000097          	auipc	ra,0x0
    80000574:	03e080e7          	jalr	62(ra) # 800005ae <printf>
  printf(s);
    80000578:	8526                	mv	a0,s1
    8000057a:	00000097          	auipc	ra,0x0
    8000057e:	034080e7          	jalr	52(ra) # 800005ae <printf>
  printf("\n");
    80000582:	00009517          	auipc	a0,0x9
    80000586:	d0e50513          	addi	a0,a0,-754 # 80009290 <userret+0x200>
    8000058a:	00000097          	auipc	ra,0x0
    8000058e:	024080e7          	jalr	36(ra) # 800005ae <printf>
  printf("HINT: restart xv6 using 'make qemu-gdb', type 'b panic' (to set breakpoint in panic) in the gdb window, followed by 'c' (continue), and when the kernel hits the breakpoint, type 'bt' to get a backtrace\n");
    80000592:	00009517          	auipc	a0,0x9
    80000596:	b9650513          	addi	a0,a0,-1130 # 80009128 <userret+0x98>
    8000059a:	00000097          	auipc	ra,0x0
    8000059e:	014080e7          	jalr	20(ra) # 800005ae <printf>
  panicked = 1; // freeze other CPUs
    800005a2:	4785                	li	a5,1
    800005a4:	00029717          	auipc	a4,0x29
    800005a8:	daf72e23          	sw	a5,-580(a4) # 80029360 <panicked>
  for(;;)
    800005ac:	a001                	j	800005ac <panic+0x58>

00000000800005ae <printf>:
{
    800005ae:	7131                	addi	sp,sp,-192
    800005b0:	fc86                	sd	ra,120(sp)
    800005b2:	f8a2                	sd	s0,112(sp)
    800005b4:	f4a6                	sd	s1,104(sp)
    800005b6:	f0ca                	sd	s2,96(sp)
    800005b8:	ecce                	sd	s3,88(sp)
    800005ba:	e8d2                	sd	s4,80(sp)
    800005bc:	e4d6                	sd	s5,72(sp)
    800005be:	e0da                	sd	s6,64(sp)
    800005c0:	fc5e                	sd	s7,56(sp)
    800005c2:	f862                	sd	s8,48(sp)
    800005c4:	f466                	sd	s9,40(sp)
    800005c6:	f06a                	sd	s10,32(sp)
    800005c8:	ec6e                	sd	s11,24(sp)
    800005ca:	0100                	addi	s0,sp,128
    800005cc:	8a2a                	mv	s4,a0
    800005ce:	e40c                	sd	a1,8(s0)
    800005d0:	e810                	sd	a2,16(s0)
    800005d2:	ec14                	sd	a3,24(s0)
    800005d4:	f018                	sd	a4,32(s0)
    800005d6:	f41c                	sd	a5,40(s0)
    800005d8:	03043823          	sd	a6,48(s0)
    800005dc:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005e0:	00013d97          	auipc	s11,0x13
    800005e4:	2f0dad83          	lw	s11,752(s11) # 800138d0 <pr+0x20>
  if(locking)
    800005e8:	020d9b63          	bnez	s11,8000061e <printf+0x70>
  if (fmt == 0)
    800005ec:	040a0263          	beqz	s4,80000630 <printf+0x82>
  va_start(ap, fmt);
    800005f0:	00840793          	addi	a5,s0,8
    800005f4:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005f8:	000a4503          	lbu	a0,0(s4)
    800005fc:	14050f63          	beqz	a0,8000075a <printf+0x1ac>
    80000600:	4981                	li	s3,0
    if(c != '%'){
    80000602:	02500a93          	li	s5,37
    switch(c){
    80000606:	07000b93          	li	s7,112
  consputc('x');
    8000060a:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000060c:	00009b17          	auipc	s6,0x9
    80000610:	754b0b13          	addi	s6,s6,1876 # 80009d60 <digits>
    switch(c){
    80000614:	07300c93          	li	s9,115
    80000618:	06400c13          	li	s8,100
    8000061c:	a82d                	j	80000656 <printf+0xa8>
    acquire(&pr.lock);
    8000061e:	00013517          	auipc	a0,0x13
    80000622:	29250513          	addi	a0,a0,658 # 800138b0 <pr>
    80000626:	00000097          	auipc	ra,0x0
    8000062a:	47a080e7          	jalr	1146(ra) # 80000aa0 <acquire>
    8000062e:	bf7d                	j	800005ec <printf+0x3e>
    panic("null fmt");
    80000630:	00009517          	auipc	a0,0x9
    80000634:	bd050513          	addi	a0,a0,-1072 # 80009200 <userret+0x170>
    80000638:	00000097          	auipc	ra,0x0
    8000063c:	f1c080e7          	jalr	-228(ra) # 80000554 <panic>
      consputc(c);
    80000640:	00000097          	auipc	ra,0x0
    80000644:	bbe080e7          	jalr	-1090(ra) # 800001fe <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000648:	2985                	addiw	s3,s3,1
    8000064a:	013a07b3          	add	a5,s4,s3
    8000064e:	0007c503          	lbu	a0,0(a5)
    80000652:	10050463          	beqz	a0,8000075a <printf+0x1ac>
    if(c != '%'){
    80000656:	ff5515e3          	bne	a0,s5,80000640 <printf+0x92>
    c = fmt[++i] & 0xff;
    8000065a:	2985                	addiw	s3,s3,1
    8000065c:	013a07b3          	add	a5,s4,s3
    80000660:	0007c783          	lbu	a5,0(a5)
    80000664:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000668:	cbed                	beqz	a5,8000075a <printf+0x1ac>
    switch(c){
    8000066a:	05778a63          	beq	a5,s7,800006be <printf+0x110>
    8000066e:	02fbf663          	bgeu	s7,a5,8000069a <printf+0xec>
    80000672:	09978863          	beq	a5,s9,80000702 <printf+0x154>
    80000676:	07800713          	li	a4,120
    8000067a:	0ce79563          	bne	a5,a4,80000744 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    8000067e:	f8843783          	ld	a5,-120(s0)
    80000682:	00878713          	addi	a4,a5,8
    80000686:	f8e43423          	sd	a4,-120(s0)
    8000068a:	4605                	li	a2,1
    8000068c:	85ea                	mv	a1,s10
    8000068e:	4388                	lw	a0,0(a5)
    80000690:	00000097          	auipc	ra,0x0
    80000694:	e22080e7          	jalr	-478(ra) # 800004b2 <printint>
      break;
    80000698:	bf45                	j	80000648 <printf+0x9a>
    switch(c){
    8000069a:	09578f63          	beq	a5,s5,80000738 <printf+0x18a>
    8000069e:	0b879363          	bne	a5,s8,80000744 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    800006a2:	f8843783          	ld	a5,-120(s0)
    800006a6:	00878713          	addi	a4,a5,8
    800006aa:	f8e43423          	sd	a4,-120(s0)
    800006ae:	4605                	li	a2,1
    800006b0:	45a9                	li	a1,10
    800006b2:	4388                	lw	a0,0(a5)
    800006b4:	00000097          	auipc	ra,0x0
    800006b8:	dfe080e7          	jalr	-514(ra) # 800004b2 <printint>
      break;
    800006bc:	b771                	j	80000648 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800006be:	f8843783          	ld	a5,-120(s0)
    800006c2:	00878713          	addi	a4,a5,8
    800006c6:	f8e43423          	sd	a4,-120(s0)
    800006ca:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006ce:	03000513          	li	a0,48
    800006d2:	00000097          	auipc	ra,0x0
    800006d6:	b2c080e7          	jalr	-1236(ra) # 800001fe <consputc>
  consputc('x');
    800006da:	07800513          	li	a0,120
    800006de:	00000097          	auipc	ra,0x0
    800006e2:	b20080e7          	jalr	-1248(ra) # 800001fe <consputc>
    800006e6:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006e8:	03c95793          	srli	a5,s2,0x3c
    800006ec:	97da                	add	a5,a5,s6
    800006ee:	0007c503          	lbu	a0,0(a5)
    800006f2:	00000097          	auipc	ra,0x0
    800006f6:	b0c080e7          	jalr	-1268(ra) # 800001fe <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006fa:	0912                	slli	s2,s2,0x4
    800006fc:	34fd                	addiw	s1,s1,-1
    800006fe:	f4ed                	bnez	s1,800006e8 <printf+0x13a>
    80000700:	b7a1                	j	80000648 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    80000702:	f8843783          	ld	a5,-120(s0)
    80000706:	00878713          	addi	a4,a5,8
    8000070a:	f8e43423          	sd	a4,-120(s0)
    8000070e:	6384                	ld	s1,0(a5)
    80000710:	cc89                	beqz	s1,8000072a <printf+0x17c>
      for(; *s; s++)
    80000712:	0004c503          	lbu	a0,0(s1)
    80000716:	d90d                	beqz	a0,80000648 <printf+0x9a>
        consputc(*s);
    80000718:	00000097          	auipc	ra,0x0
    8000071c:	ae6080e7          	jalr	-1306(ra) # 800001fe <consputc>
      for(; *s; s++)
    80000720:	0485                	addi	s1,s1,1
    80000722:	0004c503          	lbu	a0,0(s1)
    80000726:	f96d                	bnez	a0,80000718 <printf+0x16a>
    80000728:	b705                	j	80000648 <printf+0x9a>
        s = "(null)";
    8000072a:	00009497          	auipc	s1,0x9
    8000072e:	ace48493          	addi	s1,s1,-1330 # 800091f8 <userret+0x168>
      for(; *s; s++)
    80000732:	02800513          	li	a0,40
    80000736:	b7cd                	j	80000718 <printf+0x16a>
      consputc('%');
    80000738:	8556                	mv	a0,s5
    8000073a:	00000097          	auipc	ra,0x0
    8000073e:	ac4080e7          	jalr	-1340(ra) # 800001fe <consputc>
      break;
    80000742:	b719                	j	80000648 <printf+0x9a>
      consputc('%');
    80000744:	8556                	mv	a0,s5
    80000746:	00000097          	auipc	ra,0x0
    8000074a:	ab8080e7          	jalr	-1352(ra) # 800001fe <consputc>
      consputc(c);
    8000074e:	8526                	mv	a0,s1
    80000750:	00000097          	auipc	ra,0x0
    80000754:	aae080e7          	jalr	-1362(ra) # 800001fe <consputc>
      break;
    80000758:	bdc5                	j	80000648 <printf+0x9a>
  if(locking)
    8000075a:	020d9163          	bnez	s11,8000077c <printf+0x1ce>
}
    8000075e:	70e6                	ld	ra,120(sp)
    80000760:	7446                	ld	s0,112(sp)
    80000762:	74a6                	ld	s1,104(sp)
    80000764:	7906                	ld	s2,96(sp)
    80000766:	69e6                	ld	s3,88(sp)
    80000768:	6a46                	ld	s4,80(sp)
    8000076a:	6aa6                	ld	s5,72(sp)
    8000076c:	6b06                	ld	s6,64(sp)
    8000076e:	7be2                	ld	s7,56(sp)
    80000770:	7c42                	ld	s8,48(sp)
    80000772:	7ca2                	ld	s9,40(sp)
    80000774:	7d02                	ld	s10,32(sp)
    80000776:	6de2                	ld	s11,24(sp)
    80000778:	6129                	addi	sp,sp,192
    8000077a:	8082                	ret
    release(&pr.lock);
    8000077c:	00013517          	auipc	a0,0x13
    80000780:	13450513          	addi	a0,a0,308 # 800138b0 <pr>
    80000784:	00000097          	auipc	ra,0x0
    80000788:	3ec080e7          	jalr	1004(ra) # 80000b70 <release>
}
    8000078c:	bfc9                	j	8000075e <printf+0x1b0>

000000008000078e <printfinit>:
    ;
}

void
printfinit(void)
{
    8000078e:	1101                	addi	sp,sp,-32
    80000790:	ec06                	sd	ra,24(sp)
    80000792:	e822                	sd	s0,16(sp)
    80000794:	e426                	sd	s1,8(sp)
    80000796:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000798:	00013497          	auipc	s1,0x13
    8000079c:	11848493          	addi	s1,s1,280 # 800138b0 <pr>
    800007a0:	00009597          	auipc	a1,0x9
    800007a4:	a7058593          	addi	a1,a1,-1424 # 80009210 <userret+0x180>
    800007a8:	8526                	mv	a0,s1
    800007aa:	00000097          	auipc	ra,0x0
    800007ae:	222080e7          	jalr	546(ra) # 800009cc <initlock>
  pr.locking = 1;
    800007b2:	4785                	li	a5,1
    800007b4:	d09c                	sw	a5,32(s1)
}
    800007b6:	60e2                	ld	ra,24(sp)
    800007b8:	6442                	ld	s0,16(sp)
    800007ba:	64a2                	ld	s1,8(sp)
    800007bc:	6105                	addi	sp,sp,32
    800007be:	8082                	ret

00000000800007c0 <uartinit>:
#define ReadReg(reg) (*(Reg(reg)))
#define WriteReg(reg, v) (*(Reg(reg)) = (v))

void
uartinit(void)
{
    800007c0:	1141                	addi	sp,sp,-16
    800007c2:	e422                	sd	s0,8(sp)
    800007c4:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007c6:	100007b7          	lui	a5,0x10000
    800007ca:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, 0x80);
    800007ce:	f8000713          	li	a4,-128
    800007d2:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007d6:	470d                	li	a4,3
    800007d8:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007dc:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, 0x03);
    800007e0:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, 0x07);
    800007e4:	471d                	li	a4,7
    800007e6:	00e78123          	sb	a4,2(a5)

  // enable receive interrupts.
  WriteReg(IER, 0x01);
    800007ea:	4705                	li	a4,1
    800007ec:	00e780a3          	sb	a4,1(a5)
}
    800007f0:	6422                	ld	s0,8(sp)
    800007f2:	0141                	addi	sp,sp,16
    800007f4:	8082                	ret

00000000800007f6 <uartputc>:

// write one output character to the UART.
void
uartputc(int c)
{
    800007f6:	1141                	addi	sp,sp,-16
    800007f8:	e422                	sd	s0,8(sp)
    800007fa:	0800                	addi	s0,sp,16
  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & (1 << 5)) == 0)
    800007fc:	10000737          	lui	a4,0x10000
    80000800:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000804:	0207f793          	andi	a5,a5,32
    80000808:	dfe5                	beqz	a5,80000800 <uartputc+0xa>
    ;
  WriteReg(THR, c);
    8000080a:	0ff57513          	andi	a0,a0,255
    8000080e:	100007b7          	lui	a5,0x10000
    80000812:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>
}
    80000816:	6422                	ld	s0,8(sp)
    80000818:	0141                	addi	sp,sp,16
    8000081a:	8082                	ret

000000008000081c <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000081c:	1141                	addi	sp,sp,-16
    8000081e:	e422                	sd	s0,8(sp)
    80000820:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000822:	100007b7          	lui	a5,0x10000
    80000826:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000082a:	8b85                	andi	a5,a5,1
    8000082c:	cb91                	beqz	a5,80000840 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    8000082e:	100007b7          	lui	a5,0x10000
    80000832:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000836:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000083a:	6422                	ld	s0,8(sp)
    8000083c:	0141                	addi	sp,sp,16
    8000083e:	8082                	ret
    return -1;
    80000840:	557d                	li	a0,-1
    80000842:	bfe5                	j	8000083a <uartgetc+0x1e>

0000000080000844 <uartintr>:

// trap.c calls here when the uart interrupts.
void
uartintr(void)
{
    80000844:	1101                	addi	sp,sp,-32
    80000846:	ec06                	sd	ra,24(sp)
    80000848:	e822                	sd	s0,16(sp)
    8000084a:	e426                	sd	s1,8(sp)
    8000084c:	1000                	addi	s0,sp,32
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000084e:	54fd                	li	s1,-1
    80000850:	a029                	j	8000085a <uartintr+0x16>
      break;
    consoleintr(c);
    80000852:	00000097          	auipc	ra,0x0
    80000856:	a82080e7          	jalr	-1406(ra) # 800002d4 <consoleintr>
    int c = uartgetc();
    8000085a:	00000097          	auipc	ra,0x0
    8000085e:	fc2080e7          	jalr	-62(ra) # 8000081c <uartgetc>
    if(c == -1)
    80000862:	fe9518e3          	bne	a0,s1,80000852 <uartintr+0xe>
  }
}
    80000866:	60e2                	ld	ra,24(sp)
    80000868:	6442                	ld	s0,16(sp)
    8000086a:	64a2                	ld	s1,8(sp)
    8000086c:	6105                	addi	sp,sp,32
    8000086e:	8082                	ret

0000000080000870 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000870:	1101                	addi	sp,sp,-32
    80000872:	ec06                	sd	ra,24(sp)
    80000874:	e822                	sd	s0,16(sp)
    80000876:	e426                	sd	s1,8(sp)
    80000878:	e04a                	sd	s2,0(sp)
    8000087a:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    8000087c:	03451793          	slli	a5,a0,0x34
    80000880:	ebb9                	bnez	a5,800008d6 <kfree+0x66>
    80000882:	84aa                	mv	s1,a0
    80000884:	00029797          	auipc	a5,0x29
    80000888:	b2878793          	addi	a5,a5,-1240 # 800293ac <end>
    8000088c:	04f56563          	bltu	a0,a5,800008d6 <kfree+0x66>
    80000890:	47c5                	li	a5,17
    80000892:	07ee                	slli	a5,a5,0x1b
    80000894:	04f57163          	bgeu	a0,a5,800008d6 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000898:	6605                	lui	a2,0x1
    8000089a:	4585                	li	a1,1
    8000089c:	00000097          	auipc	ra,0x0
    800008a0:	4d2080e7          	jalr	1234(ra) # 80000d6e <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    800008a4:	00013917          	auipc	s2,0x13
    800008a8:	03490913          	addi	s2,s2,52 # 800138d8 <kmem>
    800008ac:	854a                	mv	a0,s2
    800008ae:	00000097          	auipc	ra,0x0
    800008b2:	1f2080e7          	jalr	498(ra) # 80000aa0 <acquire>
  r->next = kmem.freelist;
    800008b6:	02093783          	ld	a5,32(s2)
    800008ba:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    800008bc:	02993023          	sd	s1,32(s2)
  release(&kmem.lock);
    800008c0:	854a                	mv	a0,s2
    800008c2:	00000097          	auipc	ra,0x0
    800008c6:	2ae080e7          	jalr	686(ra) # 80000b70 <release>
}
    800008ca:	60e2                	ld	ra,24(sp)
    800008cc:	6442                	ld	s0,16(sp)
    800008ce:	64a2                	ld	s1,8(sp)
    800008d0:	6902                	ld	s2,0(sp)
    800008d2:	6105                	addi	sp,sp,32
    800008d4:	8082                	ret
    panic("kfree");
    800008d6:	00009517          	auipc	a0,0x9
    800008da:	94250513          	addi	a0,a0,-1726 # 80009218 <userret+0x188>
    800008de:	00000097          	auipc	ra,0x0
    800008e2:	c76080e7          	jalr	-906(ra) # 80000554 <panic>

00000000800008e6 <freerange>:
{
    800008e6:	7179                	addi	sp,sp,-48
    800008e8:	f406                	sd	ra,40(sp)
    800008ea:	f022                	sd	s0,32(sp)
    800008ec:	ec26                	sd	s1,24(sp)
    800008ee:	e84a                	sd	s2,16(sp)
    800008f0:	e44e                	sd	s3,8(sp)
    800008f2:	e052                	sd	s4,0(sp)
    800008f4:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    800008f6:	6785                	lui	a5,0x1
    800008f8:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    800008fc:	94aa                	add	s1,s1,a0
    800008fe:	757d                	lui	a0,0xfffff
    80000900:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000902:	94be                	add	s1,s1,a5
    80000904:	0095ee63          	bltu	a1,s1,80000920 <freerange+0x3a>
    80000908:	892e                	mv	s2,a1
    kfree(p);
    8000090a:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    8000090c:	6985                	lui	s3,0x1
    kfree(p);
    8000090e:	01448533          	add	a0,s1,s4
    80000912:	00000097          	auipc	ra,0x0
    80000916:	f5e080e7          	jalr	-162(ra) # 80000870 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    8000091a:	94ce                	add	s1,s1,s3
    8000091c:	fe9979e3          	bgeu	s2,s1,8000090e <freerange+0x28>
}
    80000920:	70a2                	ld	ra,40(sp)
    80000922:	7402                	ld	s0,32(sp)
    80000924:	64e2                	ld	s1,24(sp)
    80000926:	6942                	ld	s2,16(sp)
    80000928:	69a2                	ld	s3,8(sp)
    8000092a:	6a02                	ld	s4,0(sp)
    8000092c:	6145                	addi	sp,sp,48
    8000092e:	8082                	ret

0000000080000930 <kinit>:
{
    80000930:	1141                	addi	sp,sp,-16
    80000932:	e406                	sd	ra,8(sp)
    80000934:	e022                	sd	s0,0(sp)
    80000936:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000938:	00009597          	auipc	a1,0x9
    8000093c:	8e858593          	addi	a1,a1,-1816 # 80009220 <userret+0x190>
    80000940:	00013517          	auipc	a0,0x13
    80000944:	f9850513          	addi	a0,a0,-104 # 800138d8 <kmem>
    80000948:	00000097          	auipc	ra,0x0
    8000094c:	084080e7          	jalr	132(ra) # 800009cc <initlock>
  freerange(end, (void*)PHYSTOP);
    80000950:	45c5                	li	a1,17
    80000952:	05ee                	slli	a1,a1,0x1b
    80000954:	00029517          	auipc	a0,0x29
    80000958:	a5850513          	addi	a0,a0,-1448 # 800293ac <end>
    8000095c:	00000097          	auipc	ra,0x0
    80000960:	f8a080e7          	jalr	-118(ra) # 800008e6 <freerange>
}
    80000964:	60a2                	ld	ra,8(sp)
    80000966:	6402                	ld	s0,0(sp)
    80000968:	0141                	addi	sp,sp,16
    8000096a:	8082                	ret

000000008000096c <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    8000096c:	1101                	addi	sp,sp,-32
    8000096e:	ec06                	sd	ra,24(sp)
    80000970:	e822                	sd	s0,16(sp)
    80000972:	e426                	sd	s1,8(sp)
    80000974:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000976:	00013497          	auipc	s1,0x13
    8000097a:	f6248493          	addi	s1,s1,-158 # 800138d8 <kmem>
    8000097e:	8526                	mv	a0,s1
    80000980:	00000097          	auipc	ra,0x0
    80000984:	120080e7          	jalr	288(ra) # 80000aa0 <acquire>
  r = kmem.freelist;
    80000988:	7084                	ld	s1,32(s1)
  if(r)
    8000098a:	c885                	beqz	s1,800009ba <kalloc+0x4e>
    kmem.freelist = r->next;
    8000098c:	609c                	ld	a5,0(s1)
    8000098e:	00013517          	auipc	a0,0x13
    80000992:	f4a50513          	addi	a0,a0,-182 # 800138d8 <kmem>
    80000996:	f11c                	sd	a5,32(a0)
  release(&kmem.lock);
    80000998:	00000097          	auipc	ra,0x0
    8000099c:	1d8080e7          	jalr	472(ra) # 80000b70 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    800009a0:	6605                	lui	a2,0x1
    800009a2:	4595                	li	a1,5
    800009a4:	8526                	mv	a0,s1
    800009a6:	00000097          	auipc	ra,0x0
    800009aa:	3c8080e7          	jalr	968(ra) # 80000d6e <memset>
  return (void*)r;
}
    800009ae:	8526                	mv	a0,s1
    800009b0:	60e2                	ld	ra,24(sp)
    800009b2:	6442                	ld	s0,16(sp)
    800009b4:	64a2                	ld	s1,8(sp)
    800009b6:	6105                	addi	sp,sp,32
    800009b8:	8082                	ret
  release(&kmem.lock);
    800009ba:	00013517          	auipc	a0,0x13
    800009be:	f1e50513          	addi	a0,a0,-226 # 800138d8 <kmem>
    800009c2:	00000097          	auipc	ra,0x0
    800009c6:	1ae080e7          	jalr	430(ra) # 80000b70 <release>
  if(r)
    800009ca:	b7d5                	j	800009ae <kalloc+0x42>

00000000800009cc <initlock>:

// assumes locks are not freed
void
initlock(struct spinlock *lk, char *name)
{
  lk->name = name;
    800009cc:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    800009ce:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    800009d2:	00053823          	sd	zero,16(a0)
  lk->nts = 0;
    800009d6:	00052e23          	sw	zero,28(a0)
  lk->n = 0;
    800009da:	00052c23          	sw	zero,24(a0)
  if(nlock >= NLOCK)
    800009de:	00029797          	auipc	a5,0x29
    800009e2:	9867a783          	lw	a5,-1658(a5) # 80029364 <nlock>
    800009e6:	3e700713          	li	a4,999
    800009ea:	02f74063          	blt	a4,a5,80000a0a <initlock+0x3e>
    panic("initlock");
  locks[nlock] = lk;
    800009ee:	00379693          	slli	a3,a5,0x3
    800009f2:	00013717          	auipc	a4,0x13
    800009f6:	f0e70713          	addi	a4,a4,-242 # 80013900 <locks>
    800009fa:	9736                	add	a4,a4,a3
    800009fc:	e308                	sd	a0,0(a4)
  nlock++;
    800009fe:	2785                	addiw	a5,a5,1
    80000a00:	00029717          	auipc	a4,0x29
    80000a04:	96f72223          	sw	a5,-1692(a4) # 80029364 <nlock>
    80000a08:	8082                	ret
{
    80000a0a:	1141                	addi	sp,sp,-16
    80000a0c:	e406                	sd	ra,8(sp)
    80000a0e:	e022                	sd	s0,0(sp)
    80000a10:	0800                	addi	s0,sp,16
    panic("initlock");
    80000a12:	00009517          	auipc	a0,0x9
    80000a16:	81650513          	addi	a0,a0,-2026 # 80009228 <userret+0x198>
    80000a1a:	00000097          	auipc	ra,0x0
    80000a1e:	b3a080e7          	jalr	-1222(ra) # 80000554 <panic>

0000000080000a22 <holding>:
// Must be called with interrupts off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000a22:	411c                	lw	a5,0(a0)
    80000a24:	e399                	bnez	a5,80000a2a <holding+0x8>
    80000a26:	4501                	li	a0,0
  return r;
}
    80000a28:	8082                	ret
{
    80000a2a:	1101                	addi	sp,sp,-32
    80000a2c:	ec06                	sd	ra,24(sp)
    80000a2e:	e822                	sd	s0,16(sp)
    80000a30:	e426                	sd	s1,8(sp)
    80000a32:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000a34:	6904                	ld	s1,16(a0)
    80000a36:	00001097          	auipc	ra,0x1
    80000a3a:	042080e7          	jalr	66(ra) # 80001a78 <mycpu>
    80000a3e:	40a48533          	sub	a0,s1,a0
    80000a42:	00153513          	seqz	a0,a0
}
    80000a46:	60e2                	ld	ra,24(sp)
    80000a48:	6442                	ld	s0,16(sp)
    80000a4a:	64a2                	ld	s1,8(sp)
    80000a4c:	6105                	addi	sp,sp,32
    80000a4e:	8082                	ret

0000000080000a50 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000a50:	1101                	addi	sp,sp,-32
    80000a52:	ec06                	sd	ra,24(sp)
    80000a54:	e822                	sd	s0,16(sp)
    80000a56:	e426                	sd	s1,8(sp)
    80000a58:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000a5a:	100024f3          	csrr	s1,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000a5e:	8889                	andi	s1,s1,2
  int old = intr_get();
  if(old)
    80000a60:	c491                	beqz	s1,80000a6c <push_off+0x1c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000a62:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000a66:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000a68:	10079073          	csrw	sstatus,a5
    intr_off();
  if(mycpu()->noff == 0)
    80000a6c:	00001097          	auipc	ra,0x1
    80000a70:	00c080e7          	jalr	12(ra) # 80001a78 <mycpu>
    80000a74:	5d3c                	lw	a5,120(a0)
    80000a76:	cf89                	beqz	a5,80000a90 <push_off+0x40>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000a78:	00001097          	auipc	ra,0x1
    80000a7c:	000080e7          	jalr	ra # 80001a78 <mycpu>
    80000a80:	5d3c                	lw	a5,120(a0)
    80000a82:	2785                	addiw	a5,a5,1
    80000a84:	dd3c                	sw	a5,120(a0)
}
    80000a86:	60e2                	ld	ra,24(sp)
    80000a88:	6442                	ld	s0,16(sp)
    80000a8a:	64a2                	ld	s1,8(sp)
    80000a8c:	6105                	addi	sp,sp,32
    80000a8e:	8082                	ret
    mycpu()->intena = old;
    80000a90:	00001097          	auipc	ra,0x1
    80000a94:	fe8080e7          	jalr	-24(ra) # 80001a78 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000a98:	009034b3          	snez	s1,s1
    80000a9c:	dd64                	sw	s1,124(a0)
    80000a9e:	bfe9                	j	80000a78 <push_off+0x28>

0000000080000aa0 <acquire>:
{
    80000aa0:	1101                	addi	sp,sp,-32
    80000aa2:	ec06                	sd	ra,24(sp)
    80000aa4:	e822                	sd	s0,16(sp)
    80000aa6:	e426                	sd	s1,8(sp)
    80000aa8:	1000                	addi	s0,sp,32
    80000aaa:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000aac:	00000097          	auipc	ra,0x0
    80000ab0:	fa4080e7          	jalr	-92(ra) # 80000a50 <push_off>
  if(holding(lk))
    80000ab4:	8526                	mv	a0,s1
    80000ab6:	00000097          	auipc	ra,0x0
    80000aba:	f6c080e7          	jalr	-148(ra) # 80000a22 <holding>
    80000abe:	e911                	bnez	a0,80000ad2 <acquire+0x32>
  __sync_fetch_and_add(&(lk->n), 1);
    80000ac0:	4785                	li	a5,1
    80000ac2:	01848713          	addi	a4,s1,24
    80000ac6:	0f50000f          	fence	iorw,ow
    80000aca:	04f7202f          	amoadd.w.aq	zero,a5,(a4)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000ace:	4705                	li	a4,1
    80000ad0:	a839                	j	80000aee <acquire+0x4e>
    panic("acquire");
    80000ad2:	00008517          	auipc	a0,0x8
    80000ad6:	76650513          	addi	a0,a0,1894 # 80009238 <userret+0x1a8>
    80000ada:	00000097          	auipc	ra,0x0
    80000ade:	a7a080e7          	jalr	-1414(ra) # 80000554 <panic>
     __sync_fetch_and_add(&lk->nts, 1);
    80000ae2:	01c48793          	addi	a5,s1,28
    80000ae6:	0f50000f          	fence	iorw,ow
    80000aea:	04e7a02f          	amoadd.w.aq	zero,a4,(a5)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000aee:	87ba                	mv	a5,a4
    80000af0:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000af4:	2781                	sext.w	a5,a5
    80000af6:	f7f5                	bnez	a5,80000ae2 <acquire+0x42>
  __sync_synchronize();
    80000af8:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000afc:	00001097          	auipc	ra,0x1
    80000b00:	f7c080e7          	jalr	-132(ra) # 80001a78 <mycpu>
    80000b04:	e888                	sd	a0,16(s1)
}
    80000b06:	60e2                	ld	ra,24(sp)
    80000b08:	6442                	ld	s0,16(sp)
    80000b0a:	64a2                	ld	s1,8(sp)
    80000b0c:	6105                	addi	sp,sp,32
    80000b0e:	8082                	ret

0000000080000b10 <pop_off>:

void
pop_off(void)
{
    80000b10:	1141                	addi	sp,sp,-16
    80000b12:	e406                	sd	ra,8(sp)
    80000b14:	e022                	sd	s0,0(sp)
    80000b16:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b18:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000b1c:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000b1e:	eb8d                	bnez	a5,80000b50 <pop_off+0x40>
    panic("pop_off - interruptible");
  struct cpu *c = mycpu();
    80000b20:	00001097          	auipc	ra,0x1
    80000b24:	f58080e7          	jalr	-168(ra) # 80001a78 <mycpu>
  if(c->noff < 1)
    80000b28:	5d3c                	lw	a5,120(a0)
    80000b2a:	02f05b63          	blez	a5,80000b60 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000b2e:	37fd                	addiw	a5,a5,-1
    80000b30:	0007871b          	sext.w	a4,a5
    80000b34:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000b36:	eb09                	bnez	a4,80000b48 <pop_off+0x38>
    80000b38:	5d7c                	lw	a5,124(a0)
    80000b3a:	c799                	beqz	a5,80000b48 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b3c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000b40:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b44:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000b48:	60a2                	ld	ra,8(sp)
    80000b4a:	6402                	ld	s0,0(sp)
    80000b4c:	0141                	addi	sp,sp,16
    80000b4e:	8082                	ret
    panic("pop_off - interruptible");
    80000b50:	00008517          	auipc	a0,0x8
    80000b54:	6f050513          	addi	a0,a0,1776 # 80009240 <userret+0x1b0>
    80000b58:	00000097          	auipc	ra,0x0
    80000b5c:	9fc080e7          	jalr	-1540(ra) # 80000554 <panic>
    panic("pop_off");
    80000b60:	00008517          	auipc	a0,0x8
    80000b64:	6f850513          	addi	a0,a0,1784 # 80009258 <userret+0x1c8>
    80000b68:	00000097          	auipc	ra,0x0
    80000b6c:	9ec080e7          	jalr	-1556(ra) # 80000554 <panic>

0000000080000b70 <release>:
{
    80000b70:	1101                	addi	sp,sp,-32
    80000b72:	ec06                	sd	ra,24(sp)
    80000b74:	e822                	sd	s0,16(sp)
    80000b76:	e426                	sd	s1,8(sp)
    80000b78:	1000                	addi	s0,sp,32
    80000b7a:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000b7c:	00000097          	auipc	ra,0x0
    80000b80:	ea6080e7          	jalr	-346(ra) # 80000a22 <holding>
    80000b84:	c115                	beqz	a0,80000ba8 <release+0x38>
  lk->cpu = 0;
    80000b86:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000b8a:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000b8e:	0f50000f          	fence	iorw,ow
    80000b92:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000b96:	00000097          	auipc	ra,0x0
    80000b9a:	f7a080e7          	jalr	-134(ra) # 80000b10 <pop_off>
}
    80000b9e:	60e2                	ld	ra,24(sp)
    80000ba0:	6442                	ld	s0,16(sp)
    80000ba2:	64a2                	ld	s1,8(sp)
    80000ba4:	6105                	addi	sp,sp,32
    80000ba6:	8082                	ret
    panic("release");
    80000ba8:	00008517          	auipc	a0,0x8
    80000bac:	6b850513          	addi	a0,a0,1720 # 80009260 <userret+0x1d0>
    80000bb0:	00000097          	auipc	ra,0x0
    80000bb4:	9a4080e7          	jalr	-1628(ra) # 80000554 <panic>

0000000080000bb8 <print_lock>:

void
print_lock(struct spinlock *lk)
{
  if(lk->n > 0) 
    80000bb8:	4d14                	lw	a3,24(a0)
    80000bba:	e291                	bnez	a3,80000bbe <print_lock+0x6>
    80000bbc:	8082                	ret
{
    80000bbe:	1141                	addi	sp,sp,-16
    80000bc0:	e406                	sd	ra,8(sp)
    80000bc2:	e022                	sd	s0,0(sp)
    80000bc4:	0800                	addi	s0,sp,16
    printf("lock: %s: #test-and-set %d #acquire() %d\n", lk->name, lk->nts, lk->n);
    80000bc6:	4d50                	lw	a2,28(a0)
    80000bc8:	650c                	ld	a1,8(a0)
    80000bca:	00008517          	auipc	a0,0x8
    80000bce:	69e50513          	addi	a0,a0,1694 # 80009268 <userret+0x1d8>
    80000bd2:	00000097          	auipc	ra,0x0
    80000bd6:	9dc080e7          	jalr	-1572(ra) # 800005ae <printf>
}
    80000bda:	60a2                	ld	ra,8(sp)
    80000bdc:	6402                	ld	s0,0(sp)
    80000bde:	0141                	addi	sp,sp,16
    80000be0:	8082                	ret

0000000080000be2 <sys_ntas>:

uint64
sys_ntas(void)
{
    80000be2:	711d                	addi	sp,sp,-96
    80000be4:	ec86                	sd	ra,88(sp)
    80000be6:	e8a2                	sd	s0,80(sp)
    80000be8:	e4a6                	sd	s1,72(sp)
    80000bea:	e0ca                	sd	s2,64(sp)
    80000bec:	fc4e                	sd	s3,56(sp)
    80000bee:	f852                	sd	s4,48(sp)
    80000bf0:	f456                	sd	s5,40(sp)
    80000bf2:	f05a                	sd	s6,32(sp)
    80000bf4:	ec5e                	sd	s7,24(sp)
    80000bf6:	e862                	sd	s8,16(sp)
    80000bf8:	1080                	addi	s0,sp,96
  int zero = 0;
    80000bfa:	fa042623          	sw	zero,-84(s0)
  int tot = 0;
  
  if (argint(0, &zero) < 0) {
    80000bfe:	fac40593          	addi	a1,s0,-84
    80000c02:	4501                	li	a0,0
    80000c04:	00002097          	auipc	ra,0x2
    80000c08:	fb6080e7          	jalr	-74(ra) # 80002bba <argint>
    80000c0c:	14054d63          	bltz	a0,80000d66 <sys_ntas+0x184>
    return -1;
  }
  if(zero == 0) {
    80000c10:	fac42783          	lw	a5,-84(s0)
    80000c14:	e78d                	bnez	a5,80000c3e <sys_ntas+0x5c>
    80000c16:	00013797          	auipc	a5,0x13
    80000c1a:	cea78793          	addi	a5,a5,-790 # 80013900 <locks>
    80000c1e:	00015697          	auipc	a3,0x15
    80000c22:	c2268693          	addi	a3,a3,-990 # 80015840 <pid_lock>
    for(int i = 0; i < NLOCK; i++) {
      if(locks[i] == 0)
    80000c26:	6398                	ld	a4,0(a5)
    80000c28:	14070163          	beqz	a4,80000d6a <sys_ntas+0x188>
        break;
      locks[i]->nts = 0;
    80000c2c:	00072e23          	sw	zero,28(a4)
      locks[i]->n = 0;
    80000c30:	00072c23          	sw	zero,24(a4)
    for(int i = 0; i < NLOCK; i++) {
    80000c34:	07a1                	addi	a5,a5,8
    80000c36:	fed798e3          	bne	a5,a3,80000c26 <sys_ntas+0x44>
    }
    return 0;
    80000c3a:	4501                	li	a0,0
    80000c3c:	aa09                	j	80000d4e <sys_ntas+0x16c>
  }

  printf("=== lock kmem/bcache stats\n");
    80000c3e:	00008517          	auipc	a0,0x8
    80000c42:	65a50513          	addi	a0,a0,1626 # 80009298 <userret+0x208>
    80000c46:	00000097          	auipc	ra,0x0
    80000c4a:	968080e7          	jalr	-1688(ra) # 800005ae <printf>
  for(int i = 0; i < NLOCK; i++) {
    80000c4e:	00013b17          	auipc	s6,0x13
    80000c52:	cb2b0b13          	addi	s6,s6,-846 # 80013900 <locks>
    80000c56:	00015b97          	auipc	s7,0x15
    80000c5a:	beab8b93          	addi	s7,s7,-1046 # 80015840 <pid_lock>
  printf("=== lock kmem/bcache stats\n");
    80000c5e:	84da                	mv	s1,s6
  int tot = 0;
    80000c60:	4981                	li	s3,0
    if(locks[i] == 0)
      break;
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000c62:	00008a17          	auipc	s4,0x8
    80000c66:	656a0a13          	addi	s4,s4,1622 # 800092b8 <userret+0x228>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80000c6a:	00008c17          	auipc	s8,0x8
    80000c6e:	5b6c0c13          	addi	s8,s8,1462 # 80009220 <userret+0x190>
    80000c72:	a829                	j	80000c8c <sys_ntas+0xaa>
      tot += locks[i]->nts;
    80000c74:	00093503          	ld	a0,0(s2)
    80000c78:	4d5c                	lw	a5,28(a0)
    80000c7a:	013789bb          	addw	s3,a5,s3
      print_lock(locks[i]);
    80000c7e:	00000097          	auipc	ra,0x0
    80000c82:	f3a080e7          	jalr	-198(ra) # 80000bb8 <print_lock>
  for(int i = 0; i < NLOCK; i++) {
    80000c86:	04a1                	addi	s1,s1,8
    80000c88:	05748763          	beq	s1,s7,80000cd6 <sys_ntas+0xf4>
    if(locks[i] == 0)
    80000c8c:	8926                	mv	s2,s1
    80000c8e:	609c                	ld	a5,0(s1)
    80000c90:	c3b9                	beqz	a5,80000cd6 <sys_ntas+0xf4>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000c92:	0087ba83          	ld	s5,8(a5)
    80000c96:	8552                	mv	a0,s4
    80000c98:	00000097          	auipc	ra,0x0
    80000c9c:	25a080e7          	jalr	602(ra) # 80000ef2 <strlen>
    80000ca0:	0005061b          	sext.w	a2,a0
    80000ca4:	85d2                	mv	a1,s4
    80000ca6:	8556                	mv	a0,s5
    80000ca8:	00000097          	auipc	ra,0x0
    80000cac:	19e080e7          	jalr	414(ra) # 80000e46 <strncmp>
    80000cb0:	d171                	beqz	a0,80000c74 <sys_ntas+0x92>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80000cb2:	609c                	ld	a5,0(s1)
    80000cb4:	0087ba83          	ld	s5,8(a5)
    80000cb8:	8562                	mv	a0,s8
    80000cba:	00000097          	auipc	ra,0x0
    80000cbe:	238080e7          	jalr	568(ra) # 80000ef2 <strlen>
    80000cc2:	0005061b          	sext.w	a2,a0
    80000cc6:	85e2                	mv	a1,s8
    80000cc8:	8556                	mv	a0,s5
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	17c080e7          	jalr	380(ra) # 80000e46 <strncmp>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000cd2:	f955                	bnez	a0,80000c86 <sys_ntas+0xa4>
    80000cd4:	b745                	j	80000c74 <sys_ntas+0x92>
    }
  }

  printf("=== top 5 contended locks:\n");
    80000cd6:	00008517          	auipc	a0,0x8
    80000cda:	5ea50513          	addi	a0,a0,1514 # 800092c0 <userret+0x230>
    80000cde:	00000097          	auipc	ra,0x0
    80000ce2:	8d0080e7          	jalr	-1840(ra) # 800005ae <printf>
    80000ce6:	4a15                	li	s4,5
  int last = 100000000;
    80000ce8:	05f5e537          	lui	a0,0x5f5e
    80000cec:	10050513          	addi	a0,a0,256 # 5f5e100 <_entry-0x7a0a1f00>
  // stupid way to compute top 5 contended locks
  for(int t= 0; t < 5; t++) {
    int top = 0;
    for(int i = 0; i < NLOCK; i++) {
    80000cf0:	4a81                	li	s5,0
      if(locks[i] == 0)
        break;
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80000cf2:	00013497          	auipc	s1,0x13
    80000cf6:	c0e48493          	addi	s1,s1,-1010 # 80013900 <locks>
    for(int i = 0; i < NLOCK; i++) {
    80000cfa:	3e800913          	li	s2,1000
    80000cfe:	a091                	j	80000d42 <sys_ntas+0x160>
    80000d00:	2705                	addiw	a4,a4,1
    80000d02:	06a1                	addi	a3,a3,8
    80000d04:	03270063          	beq	a4,s2,80000d24 <sys_ntas+0x142>
      if(locks[i] == 0)
    80000d08:	629c                	ld	a5,0(a3)
    80000d0a:	cf89                	beqz	a5,80000d24 <sys_ntas+0x142>
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80000d0c:	4fd0                	lw	a2,28(a5)
    80000d0e:	00359793          	slli	a5,a1,0x3
    80000d12:	97a6                	add	a5,a5,s1
    80000d14:	639c                	ld	a5,0(a5)
    80000d16:	4fdc                	lw	a5,28(a5)
    80000d18:	fec7f4e3          	bgeu	a5,a2,80000d00 <sys_ntas+0x11e>
    80000d1c:	fea672e3          	bgeu	a2,a0,80000d00 <sys_ntas+0x11e>
    80000d20:	85ba                	mv	a1,a4
    80000d22:	bff9                	j	80000d00 <sys_ntas+0x11e>
        top = i;
      }
    }
    print_lock(locks[top]);
    80000d24:	058e                	slli	a1,a1,0x3
    80000d26:	00b48bb3          	add	s7,s1,a1
    80000d2a:	000bb503          	ld	a0,0(s7)
    80000d2e:	00000097          	auipc	ra,0x0
    80000d32:	e8a080e7          	jalr	-374(ra) # 80000bb8 <print_lock>
    last = locks[top]->nts;
    80000d36:	000bb783          	ld	a5,0(s7)
    80000d3a:	4fc8                	lw	a0,28(a5)
  for(int t= 0; t < 5; t++) {
    80000d3c:	3a7d                	addiw	s4,s4,-1
    80000d3e:	000a0763          	beqz	s4,80000d4c <sys_ntas+0x16a>
  int tot = 0;
    80000d42:	86da                	mv	a3,s6
    for(int i = 0; i < NLOCK; i++) {
    80000d44:	8756                	mv	a4,s5
    int top = 0;
    80000d46:	85d6                	mv	a1,s5
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80000d48:	2501                	sext.w	a0,a0
    80000d4a:	bf7d                	j	80000d08 <sys_ntas+0x126>
  }
  return tot;
    80000d4c:	854e                	mv	a0,s3
}
    80000d4e:	60e6                	ld	ra,88(sp)
    80000d50:	6446                	ld	s0,80(sp)
    80000d52:	64a6                	ld	s1,72(sp)
    80000d54:	6906                	ld	s2,64(sp)
    80000d56:	79e2                	ld	s3,56(sp)
    80000d58:	7a42                	ld	s4,48(sp)
    80000d5a:	7aa2                	ld	s5,40(sp)
    80000d5c:	7b02                	ld	s6,32(sp)
    80000d5e:	6be2                	ld	s7,24(sp)
    80000d60:	6c42                	ld	s8,16(sp)
    80000d62:	6125                	addi	sp,sp,96
    80000d64:	8082                	ret
    return -1;
    80000d66:	557d                	li	a0,-1
    80000d68:	b7dd                	j	80000d4e <sys_ntas+0x16c>
    return 0;
    80000d6a:	4501                	li	a0,0
    80000d6c:	b7cd                	j	80000d4e <sys_ntas+0x16c>

0000000080000d6e <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d6e:	1141                	addi	sp,sp,-16
    80000d70:	e422                	sd	s0,8(sp)
    80000d72:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d74:	ca19                	beqz	a2,80000d8a <memset+0x1c>
    80000d76:	87aa                	mv	a5,a0
    80000d78:	1602                	slli	a2,a2,0x20
    80000d7a:	9201                	srli	a2,a2,0x20
    80000d7c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d80:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d84:	0785                	addi	a5,a5,1
    80000d86:	fee79de3          	bne	a5,a4,80000d80 <memset+0x12>
  }
  return dst;
}
    80000d8a:	6422                	ld	s0,8(sp)
    80000d8c:	0141                	addi	sp,sp,16
    80000d8e:	8082                	ret

0000000080000d90 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d90:	1141                	addi	sp,sp,-16
    80000d92:	e422                	sd	s0,8(sp)
    80000d94:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d96:	ca05                	beqz	a2,80000dc6 <memcmp+0x36>
    80000d98:	fff6069b          	addiw	a3,a2,-1
    80000d9c:	1682                	slli	a3,a3,0x20
    80000d9e:	9281                	srli	a3,a3,0x20
    80000da0:	0685                	addi	a3,a3,1
    80000da2:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000da4:	00054783          	lbu	a5,0(a0)
    80000da8:	0005c703          	lbu	a4,0(a1)
    80000dac:	00e79863          	bne	a5,a4,80000dbc <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000db0:	0505                	addi	a0,a0,1
    80000db2:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000db4:	fed518e3          	bne	a0,a3,80000da4 <memcmp+0x14>
  }

  return 0;
    80000db8:	4501                	li	a0,0
    80000dba:	a019                	j	80000dc0 <memcmp+0x30>
      return *s1 - *s2;
    80000dbc:	40e7853b          	subw	a0,a5,a4
}
    80000dc0:	6422                	ld	s0,8(sp)
    80000dc2:	0141                	addi	sp,sp,16
    80000dc4:	8082                	ret
  return 0;
    80000dc6:	4501                	li	a0,0
    80000dc8:	bfe5                	j	80000dc0 <memcmp+0x30>

0000000080000dca <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000dca:	1141                	addi	sp,sp,-16
    80000dcc:	e422                	sd	s0,8(sp)
    80000dce:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000dd0:	02a5e563          	bltu	a1,a0,80000dfa <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000dd4:	fff6069b          	addiw	a3,a2,-1
    80000dd8:	ce11                	beqz	a2,80000df4 <memmove+0x2a>
    80000dda:	1682                	slli	a3,a3,0x20
    80000ddc:	9281                	srli	a3,a3,0x20
    80000dde:	0685                	addi	a3,a3,1
    80000de0:	96ae                	add	a3,a3,a1
    80000de2:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000de4:	0585                	addi	a1,a1,1
    80000de6:	0785                	addi	a5,a5,1
    80000de8:	fff5c703          	lbu	a4,-1(a1)
    80000dec:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000df0:	fed59ae3          	bne	a1,a3,80000de4 <memmove+0x1a>

  return dst;
}
    80000df4:	6422                	ld	s0,8(sp)
    80000df6:	0141                	addi	sp,sp,16
    80000df8:	8082                	ret
  if(s < d && s + n > d){
    80000dfa:	02061713          	slli	a4,a2,0x20
    80000dfe:	9301                	srli	a4,a4,0x20
    80000e00:	00e587b3          	add	a5,a1,a4
    80000e04:	fcf578e3          	bgeu	a0,a5,80000dd4 <memmove+0xa>
    d += n;
    80000e08:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000e0a:	fff6069b          	addiw	a3,a2,-1
    80000e0e:	d27d                	beqz	a2,80000df4 <memmove+0x2a>
    80000e10:	02069613          	slli	a2,a3,0x20
    80000e14:	9201                	srli	a2,a2,0x20
    80000e16:	fff64613          	not	a2,a2
    80000e1a:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000e1c:	17fd                	addi	a5,a5,-1
    80000e1e:	177d                	addi	a4,a4,-1
    80000e20:	0007c683          	lbu	a3,0(a5)
    80000e24:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000e28:	fef61ae3          	bne	a2,a5,80000e1c <memmove+0x52>
    80000e2c:	b7e1                	j	80000df4 <memmove+0x2a>

0000000080000e2e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e2e:	1141                	addi	sp,sp,-16
    80000e30:	e406                	sd	ra,8(sp)
    80000e32:	e022                	sd	s0,0(sp)
    80000e34:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e36:	00000097          	auipc	ra,0x0
    80000e3a:	f94080e7          	jalr	-108(ra) # 80000dca <memmove>
}
    80000e3e:	60a2                	ld	ra,8(sp)
    80000e40:	6402                	ld	s0,0(sp)
    80000e42:	0141                	addi	sp,sp,16
    80000e44:	8082                	ret

0000000080000e46 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e46:	1141                	addi	sp,sp,-16
    80000e48:	e422                	sd	s0,8(sp)
    80000e4a:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e4c:	ce11                	beqz	a2,80000e68 <strncmp+0x22>
    80000e4e:	00054783          	lbu	a5,0(a0)
    80000e52:	cf89                	beqz	a5,80000e6c <strncmp+0x26>
    80000e54:	0005c703          	lbu	a4,0(a1)
    80000e58:	00f71a63          	bne	a4,a5,80000e6c <strncmp+0x26>
    n--, p++, q++;
    80000e5c:	367d                	addiw	a2,a2,-1
    80000e5e:	0505                	addi	a0,a0,1
    80000e60:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e62:	f675                	bnez	a2,80000e4e <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e64:	4501                	li	a0,0
    80000e66:	a809                	j	80000e78 <strncmp+0x32>
    80000e68:	4501                	li	a0,0
    80000e6a:	a039                	j	80000e78 <strncmp+0x32>
  if(n == 0)
    80000e6c:	ca09                	beqz	a2,80000e7e <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e6e:	00054503          	lbu	a0,0(a0)
    80000e72:	0005c783          	lbu	a5,0(a1)
    80000e76:	9d1d                	subw	a0,a0,a5
}
    80000e78:	6422                	ld	s0,8(sp)
    80000e7a:	0141                	addi	sp,sp,16
    80000e7c:	8082                	ret
    return 0;
    80000e7e:	4501                	li	a0,0
    80000e80:	bfe5                	j	80000e78 <strncmp+0x32>

0000000080000e82 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e82:	1141                	addi	sp,sp,-16
    80000e84:	e422                	sd	s0,8(sp)
    80000e86:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e88:	872a                	mv	a4,a0
    80000e8a:	8832                	mv	a6,a2
    80000e8c:	367d                	addiw	a2,a2,-1
    80000e8e:	01005963          	blez	a6,80000ea0 <strncpy+0x1e>
    80000e92:	0705                	addi	a4,a4,1
    80000e94:	0005c783          	lbu	a5,0(a1)
    80000e98:	fef70fa3          	sb	a5,-1(a4)
    80000e9c:	0585                	addi	a1,a1,1
    80000e9e:	f7f5                	bnez	a5,80000e8a <strncpy+0x8>
    ;
  while(n-- > 0)
    80000ea0:	86ba                	mv	a3,a4
    80000ea2:	00c05c63          	blez	a2,80000eba <strncpy+0x38>
    *s++ = 0;
    80000ea6:	0685                	addi	a3,a3,1
    80000ea8:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000eac:	fff6c793          	not	a5,a3
    80000eb0:	9fb9                	addw	a5,a5,a4
    80000eb2:	010787bb          	addw	a5,a5,a6
    80000eb6:	fef048e3          	bgtz	a5,80000ea6 <strncpy+0x24>
  return os;
}
    80000eba:	6422                	ld	s0,8(sp)
    80000ebc:	0141                	addi	sp,sp,16
    80000ebe:	8082                	ret

0000000080000ec0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000ec0:	1141                	addi	sp,sp,-16
    80000ec2:	e422                	sd	s0,8(sp)
    80000ec4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000ec6:	02c05363          	blez	a2,80000eec <safestrcpy+0x2c>
    80000eca:	fff6069b          	addiw	a3,a2,-1
    80000ece:	1682                	slli	a3,a3,0x20
    80000ed0:	9281                	srli	a3,a3,0x20
    80000ed2:	96ae                	add	a3,a3,a1
    80000ed4:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000ed6:	00d58963          	beq	a1,a3,80000ee8 <safestrcpy+0x28>
    80000eda:	0585                	addi	a1,a1,1
    80000edc:	0785                	addi	a5,a5,1
    80000ede:	fff5c703          	lbu	a4,-1(a1)
    80000ee2:	fee78fa3          	sb	a4,-1(a5)
    80000ee6:	fb65                	bnez	a4,80000ed6 <safestrcpy+0x16>
    ;
  *s = 0;
    80000ee8:	00078023          	sb	zero,0(a5)
  return os;
}
    80000eec:	6422                	ld	s0,8(sp)
    80000eee:	0141                	addi	sp,sp,16
    80000ef0:	8082                	ret

0000000080000ef2 <strlen>:

int
strlen(const char *s)
{
    80000ef2:	1141                	addi	sp,sp,-16
    80000ef4:	e422                	sd	s0,8(sp)
    80000ef6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000ef8:	00054783          	lbu	a5,0(a0)
    80000efc:	cf91                	beqz	a5,80000f18 <strlen+0x26>
    80000efe:	0505                	addi	a0,a0,1
    80000f00:	87aa                	mv	a5,a0
    80000f02:	4685                	li	a3,1
    80000f04:	9e89                	subw	a3,a3,a0
    80000f06:	00f6853b          	addw	a0,a3,a5
    80000f0a:	0785                	addi	a5,a5,1
    80000f0c:	fff7c703          	lbu	a4,-1(a5)
    80000f10:	fb7d                	bnez	a4,80000f06 <strlen+0x14>
    ;
  return n;
}
    80000f12:	6422                	ld	s0,8(sp)
    80000f14:	0141                	addi	sp,sp,16
    80000f16:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f18:	4501                	li	a0,0
    80000f1a:	bfe5                	j	80000f12 <strlen+0x20>

0000000080000f1c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f1c:	1141                	addi	sp,sp,-16
    80000f1e:	e406                	sd	ra,8(sp)
    80000f20:	e022                	sd	s0,0(sp)
    80000f22:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f24:	00001097          	auipc	ra,0x1
    80000f28:	b44080e7          	jalr	-1212(ra) # 80001a68 <cpuid>
    sockinit();
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f2c:	00028717          	auipc	a4,0x28
    80000f30:	43c70713          	addi	a4,a4,1084 # 80029368 <started>
  if(cpuid() == 0){
    80000f34:	c139                	beqz	a0,80000f7a <main+0x5e>
    while(started == 0)
    80000f36:	431c                	lw	a5,0(a4)
    80000f38:	2781                	sext.w	a5,a5
    80000f3a:	dff5                	beqz	a5,80000f36 <main+0x1a>
      ;
    __sync_synchronize();
    80000f3c:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f40:	00001097          	auipc	ra,0x1
    80000f44:	b28080e7          	jalr	-1240(ra) # 80001a68 <cpuid>
    80000f48:	85aa                	mv	a1,a0
    80000f4a:	00008517          	auipc	a0,0x8
    80000f4e:	3ae50513          	addi	a0,a0,942 # 800092f8 <userret+0x268>
    80000f52:	fffff097          	auipc	ra,0xfffff
    80000f56:	65c080e7          	jalr	1628(ra) # 800005ae <printf>
    kvminithart();    // turn on paging
    80000f5a:	00000097          	auipc	ra,0x0
    80000f5e:	1fa080e7          	jalr	506(ra) # 80001154 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f62:	00001097          	auipc	ra,0x1
    80000f66:	7d2080e7          	jalr	2002(ra) # 80002734 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f6a:	00005097          	auipc	ra,0x5
    80000f6e:	f8a080e7          	jalr	-118(ra) # 80005ef4 <plicinithart>
  }

  scheduler();        
    80000f72:	00001097          	auipc	ra,0x1
    80000f76:	000080e7          	jalr	ra # 80001f72 <scheduler>
    consoleinit();
    80000f7a:	fffff097          	auipc	ra,0xfffff
    80000f7e:	4ec080e7          	jalr	1260(ra) # 80000466 <consoleinit>
    printfinit();
    80000f82:	00000097          	auipc	ra,0x0
    80000f86:	80c080e7          	jalr	-2036(ra) # 8000078e <printfinit>
    printf("\n");
    80000f8a:	00008517          	auipc	a0,0x8
    80000f8e:	30650513          	addi	a0,a0,774 # 80009290 <userret+0x200>
    80000f92:	fffff097          	auipc	ra,0xfffff
    80000f96:	61c080e7          	jalr	1564(ra) # 800005ae <printf>
    printf("xv6 kernel is booting\n");
    80000f9a:	00008517          	auipc	a0,0x8
    80000f9e:	34650513          	addi	a0,a0,838 # 800092e0 <userret+0x250>
    80000fa2:	fffff097          	auipc	ra,0xfffff
    80000fa6:	60c080e7          	jalr	1548(ra) # 800005ae <printf>
    printf("\n");
    80000faa:	00008517          	auipc	a0,0x8
    80000fae:	2e650513          	addi	a0,a0,742 # 80009290 <userret+0x200>
    80000fb2:	fffff097          	auipc	ra,0xfffff
    80000fb6:	5fc080e7          	jalr	1532(ra) # 800005ae <printf>
    kinit();         // physical page allocator
    80000fba:	00000097          	auipc	ra,0x0
    80000fbe:	976080e7          	jalr	-1674(ra) # 80000930 <kinit>
    kvminit();       // create kernel page table
    80000fc2:	00000097          	auipc	ra,0x0
    80000fc6:	31c080e7          	jalr	796(ra) # 800012de <kvminit>
    kvminithart();   // turn on paging
    80000fca:	00000097          	auipc	ra,0x0
    80000fce:	18a080e7          	jalr	394(ra) # 80001154 <kvminithart>
    procinit();      // process table
    80000fd2:	00001097          	auipc	ra,0x1
    80000fd6:	9c6080e7          	jalr	-1594(ra) # 80001998 <procinit>
    trapinit();      // trap vectors
    80000fda:	00001097          	auipc	ra,0x1
    80000fde:	732080e7          	jalr	1842(ra) # 8000270c <trapinit>
    trapinithart();  // install kernel trap vector
    80000fe2:	00001097          	auipc	ra,0x1
    80000fe6:	752080e7          	jalr	1874(ra) # 80002734 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fea:	00005097          	auipc	ra,0x5
    80000fee:	ee0080e7          	jalr	-288(ra) # 80005eca <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ff2:	00005097          	auipc	ra,0x5
    80000ff6:	f02080e7          	jalr	-254(ra) # 80005ef4 <plicinithart>
    binit();         // buffer cache
    80000ffa:	00002097          	auipc	ra,0x2
    80000ffe:	ea0080e7          	jalr	-352(ra) # 80002e9a <binit>
    iinit();         // inode cache
    80001002:	00002097          	auipc	ra,0x2
    80001006:	534080e7          	jalr	1332(ra) # 80003536 <iinit>
    fileinit();      // file table
    8000100a:	00003097          	auipc	ra,0x3
    8000100e:	5be080e7          	jalr	1470(ra) # 800045c8 <fileinit>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    80001012:	4501                	li	a0,0
    80001014:	00005097          	auipc	ra,0x5
    80001018:	008080e7          	jalr	8(ra) # 8000601c <virtio_disk_init>
    pci_init();
    8000101c:	00006097          	auipc	ra,0x6
    80001020:	4a2080e7          	jalr	1186(ra) # 800074be <pci_init>
    sockinit();
    80001024:	00006097          	auipc	ra,0x6
    80001028:	0b6080e7          	jalr	182(ra) # 800070da <sockinit>
    userinit();      // first user process
    8000102c:	00001097          	auipc	ra,0x1
    80001030:	cdc080e7          	jalr	-804(ra) # 80001d08 <userinit>
    __sync_synchronize();
    80001034:	0ff0000f          	fence
    started = 1;
    80001038:	4785                	li	a5,1
    8000103a:	00028717          	auipc	a4,0x28
    8000103e:	32f72723          	sw	a5,814(a4) # 80029368 <started>
    80001042:	bf05                	j	80000f72 <main+0x56>

0000000080001044 <walk>:
//   21..39 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..12 -- 12 bits of byte offset within the page.
static pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001044:	7139                	addi	sp,sp,-64
    80001046:	fc06                	sd	ra,56(sp)
    80001048:	f822                	sd	s0,48(sp)
    8000104a:	f426                	sd	s1,40(sp)
    8000104c:	f04a                	sd	s2,32(sp)
    8000104e:	ec4e                	sd	s3,24(sp)
    80001050:	e852                	sd	s4,16(sp)
    80001052:	e456                	sd	s5,8(sp)
    80001054:	e05a                	sd	s6,0(sp)
    80001056:	0080                	addi	s0,sp,64
    80001058:	84aa                	mv	s1,a0
    8000105a:	89ae                	mv	s3,a1
    8000105c:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000105e:	57fd                	li	a5,-1
    80001060:	83e9                	srli	a5,a5,0x1a
    80001062:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001064:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001066:	04b7f263          	bgeu	a5,a1,800010aa <walk+0x66>
    panic("walk");
    8000106a:	00008517          	auipc	a0,0x8
    8000106e:	2a650513          	addi	a0,a0,678 # 80009310 <userret+0x280>
    80001072:	fffff097          	auipc	ra,0xfffff
    80001076:	4e2080e7          	jalr	1250(ra) # 80000554 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000107a:	060a8663          	beqz	s5,800010e6 <walk+0xa2>
    8000107e:	00000097          	auipc	ra,0x0
    80001082:	8ee080e7          	jalr	-1810(ra) # 8000096c <kalloc>
    80001086:	84aa                	mv	s1,a0
    80001088:	c529                	beqz	a0,800010d2 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000108a:	6605                	lui	a2,0x1
    8000108c:	4581                	li	a1,0
    8000108e:	00000097          	auipc	ra,0x0
    80001092:	ce0080e7          	jalr	-800(ra) # 80000d6e <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001096:	00c4d793          	srli	a5,s1,0xc
    8000109a:	07aa                	slli	a5,a5,0xa
    8000109c:	0017e793          	ori	a5,a5,1
    800010a0:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800010a4:	3a5d                	addiw	s4,s4,-9
    800010a6:	036a0063          	beq	s4,s6,800010c6 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800010aa:	0149d933          	srl	s2,s3,s4
    800010ae:	1ff97913          	andi	s2,s2,511
    800010b2:	090e                	slli	s2,s2,0x3
    800010b4:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010b6:	00093483          	ld	s1,0(s2)
    800010ba:	0014f793          	andi	a5,s1,1
    800010be:	dfd5                	beqz	a5,8000107a <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010c0:	80a9                	srli	s1,s1,0xa
    800010c2:	04b2                	slli	s1,s1,0xc
    800010c4:	b7c5                	j	800010a4 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800010c6:	00c9d513          	srli	a0,s3,0xc
    800010ca:	1ff57513          	andi	a0,a0,511
    800010ce:	050e                	slli	a0,a0,0x3
    800010d0:	9526                	add	a0,a0,s1
}
    800010d2:	70e2                	ld	ra,56(sp)
    800010d4:	7442                	ld	s0,48(sp)
    800010d6:	74a2                	ld	s1,40(sp)
    800010d8:	7902                	ld	s2,32(sp)
    800010da:	69e2                	ld	s3,24(sp)
    800010dc:	6a42                	ld	s4,16(sp)
    800010de:	6aa2                	ld	s5,8(sp)
    800010e0:	6b02                	ld	s6,0(sp)
    800010e2:	6121                	addi	sp,sp,64
    800010e4:	8082                	ret
        return 0;
    800010e6:	4501                	li	a0,0
    800010e8:	b7ed                	j	800010d2 <walk+0x8e>

00000000800010ea <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
static void
freewalk(pagetable_t pagetable)
{
    800010ea:	7179                	addi	sp,sp,-48
    800010ec:	f406                	sd	ra,40(sp)
    800010ee:	f022                	sd	s0,32(sp)
    800010f0:	ec26                	sd	s1,24(sp)
    800010f2:	e84a                	sd	s2,16(sp)
    800010f4:	e44e                	sd	s3,8(sp)
    800010f6:	e052                	sd	s4,0(sp)
    800010f8:	1800                	addi	s0,sp,48
    800010fa:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800010fc:	84aa                	mv	s1,a0
    800010fe:	6905                	lui	s2,0x1
    80001100:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001102:	4985                	li	s3,1
    80001104:	a821                	j	8000111c <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001106:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001108:	0532                	slli	a0,a0,0xc
    8000110a:	00000097          	auipc	ra,0x0
    8000110e:	fe0080e7          	jalr	-32(ra) # 800010ea <freewalk>
      pagetable[i] = 0;
    80001112:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001116:	04a1                	addi	s1,s1,8
    80001118:	03248163          	beq	s1,s2,8000113a <freewalk+0x50>
    pte_t pte = pagetable[i];
    8000111c:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000111e:	00f57793          	andi	a5,a0,15
    80001122:	ff3782e3          	beq	a5,s3,80001106 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001126:	8905                	andi	a0,a0,1
    80001128:	d57d                	beqz	a0,80001116 <freewalk+0x2c>
      panic("freewalk: leaf");
    8000112a:	00008517          	auipc	a0,0x8
    8000112e:	1ee50513          	addi	a0,a0,494 # 80009318 <userret+0x288>
    80001132:	fffff097          	auipc	ra,0xfffff
    80001136:	422080e7          	jalr	1058(ra) # 80000554 <panic>
    }
  }
  kfree((void*)pagetable);
    8000113a:	8552                	mv	a0,s4
    8000113c:	fffff097          	auipc	ra,0xfffff
    80001140:	734080e7          	jalr	1844(ra) # 80000870 <kfree>
}
    80001144:	70a2                	ld	ra,40(sp)
    80001146:	7402                	ld	s0,32(sp)
    80001148:	64e2                	ld	s1,24(sp)
    8000114a:	6942                	ld	s2,16(sp)
    8000114c:	69a2                	ld	s3,8(sp)
    8000114e:	6a02                	ld	s4,0(sp)
    80001150:	6145                	addi	sp,sp,48
    80001152:	8082                	ret

0000000080001154 <kvminithart>:
{
    80001154:	1141                	addi	sp,sp,-16
    80001156:	e422                	sd	s0,8(sp)
    80001158:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    8000115a:	00028797          	auipc	a5,0x28
    8000115e:	2167b783          	ld	a5,534(a5) # 80029370 <kernel_pagetable>
    80001162:	83b1                	srli	a5,a5,0xc
    80001164:	577d                	li	a4,-1
    80001166:	177e                	slli	a4,a4,0x3f
    80001168:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000116a:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000116e:	12000073          	sfence.vma
}
    80001172:	6422                	ld	s0,8(sp)
    80001174:	0141                	addi	sp,sp,16
    80001176:	8082                	ret

0000000080001178 <walkaddr>:
  if(va >= MAXVA)
    80001178:	57fd                	li	a5,-1
    8000117a:	83e9                	srli	a5,a5,0x1a
    8000117c:	00b7f463          	bgeu	a5,a1,80001184 <walkaddr+0xc>
    return 0;
    80001180:	4501                	li	a0,0
}
    80001182:	8082                	ret
{
    80001184:	1141                	addi	sp,sp,-16
    80001186:	e406                	sd	ra,8(sp)
    80001188:	e022                	sd	s0,0(sp)
    8000118a:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000118c:	4601                	li	a2,0
    8000118e:	00000097          	auipc	ra,0x0
    80001192:	eb6080e7          	jalr	-330(ra) # 80001044 <walk>
  if(pte == 0)
    80001196:	c105                	beqz	a0,800011b6 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001198:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000119a:	0117f693          	andi	a3,a5,17
    8000119e:	4745                	li	a4,17
    return 0;
    800011a0:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800011a2:	00e68663          	beq	a3,a4,800011ae <walkaddr+0x36>
}
    800011a6:	60a2                	ld	ra,8(sp)
    800011a8:	6402                	ld	s0,0(sp)
    800011aa:	0141                	addi	sp,sp,16
    800011ac:	8082                	ret
  pa = PTE2PA(*pte);
    800011ae:	00a7d513          	srli	a0,a5,0xa
    800011b2:	0532                	slli	a0,a0,0xc
  return pa;
    800011b4:	bfcd                	j	800011a6 <walkaddr+0x2e>
    return 0;
    800011b6:	4501                	li	a0,0
    800011b8:	b7fd                	j	800011a6 <walkaddr+0x2e>

00000000800011ba <kvmpa>:
{
    800011ba:	1101                	addi	sp,sp,-32
    800011bc:	ec06                	sd	ra,24(sp)
    800011be:	e822                	sd	s0,16(sp)
    800011c0:	e426                	sd	s1,8(sp)
    800011c2:	1000                	addi	s0,sp,32
    800011c4:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    800011c6:	1552                	slli	a0,a0,0x34
    800011c8:	03455493          	srli	s1,a0,0x34
  pte = walk(kernel_pagetable, va, 0);
    800011cc:	4601                	li	a2,0
    800011ce:	00028517          	auipc	a0,0x28
    800011d2:	1a253503          	ld	a0,418(a0) # 80029370 <kernel_pagetable>
    800011d6:	00000097          	auipc	ra,0x0
    800011da:	e6e080e7          	jalr	-402(ra) # 80001044 <walk>
  if(pte == 0)
    800011de:	cd09                	beqz	a0,800011f8 <kvmpa+0x3e>
  if((*pte & PTE_V) == 0)
    800011e0:	6108                	ld	a0,0(a0)
    800011e2:	00157793          	andi	a5,a0,1
    800011e6:	c38d                	beqz	a5,80001208 <kvmpa+0x4e>
  pa = PTE2PA(*pte);
    800011e8:	8129                	srli	a0,a0,0xa
    800011ea:	0532                	slli	a0,a0,0xc
}
    800011ec:	9526                	add	a0,a0,s1
    800011ee:	60e2                	ld	ra,24(sp)
    800011f0:	6442                	ld	s0,16(sp)
    800011f2:	64a2                	ld	s1,8(sp)
    800011f4:	6105                	addi	sp,sp,32
    800011f6:	8082                	ret
    panic("kvmpa");
    800011f8:	00008517          	auipc	a0,0x8
    800011fc:	13050513          	addi	a0,a0,304 # 80009328 <userret+0x298>
    80001200:	fffff097          	auipc	ra,0xfffff
    80001204:	354080e7          	jalr	852(ra) # 80000554 <panic>
    panic("kvmpa");
    80001208:	00008517          	auipc	a0,0x8
    8000120c:	12050513          	addi	a0,a0,288 # 80009328 <userret+0x298>
    80001210:	fffff097          	auipc	ra,0xfffff
    80001214:	344080e7          	jalr	836(ra) # 80000554 <panic>

0000000080001218 <mappages>:
{
    80001218:	715d                	addi	sp,sp,-80
    8000121a:	e486                	sd	ra,72(sp)
    8000121c:	e0a2                	sd	s0,64(sp)
    8000121e:	fc26                	sd	s1,56(sp)
    80001220:	f84a                	sd	s2,48(sp)
    80001222:	f44e                	sd	s3,40(sp)
    80001224:	f052                	sd	s4,32(sp)
    80001226:	ec56                	sd	s5,24(sp)
    80001228:	e85a                	sd	s6,16(sp)
    8000122a:	e45e                	sd	s7,8(sp)
    8000122c:	0880                	addi	s0,sp,80
    8000122e:	8aaa                	mv	s5,a0
    80001230:	8b3a                	mv	s6,a4
  a = PGROUNDDOWN(va);
    80001232:	777d                	lui	a4,0xfffff
    80001234:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001238:	167d                	addi	a2,a2,-1
    8000123a:	00b609b3          	add	s3,a2,a1
    8000123e:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001242:	893e                	mv	s2,a5
    80001244:	40f68a33          	sub	s4,a3,a5
    a += PGSIZE;
    80001248:	6b85                	lui	s7,0x1
    8000124a:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000124e:	4605                	li	a2,1
    80001250:	85ca                	mv	a1,s2
    80001252:	8556                	mv	a0,s5
    80001254:	00000097          	auipc	ra,0x0
    80001258:	df0080e7          	jalr	-528(ra) # 80001044 <walk>
    8000125c:	c51d                	beqz	a0,8000128a <mappages+0x72>
    if(*pte & PTE_V)
    8000125e:	611c                	ld	a5,0(a0)
    80001260:	8b85                	andi	a5,a5,1
    80001262:	ef81                	bnez	a5,8000127a <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001264:	80b1                	srli	s1,s1,0xc
    80001266:	04aa                	slli	s1,s1,0xa
    80001268:	0164e4b3          	or	s1,s1,s6
    8000126c:	0014e493          	ori	s1,s1,1
    80001270:	e104                	sd	s1,0(a0)
    if(a == last)
    80001272:	03390863          	beq	s2,s3,800012a2 <mappages+0x8a>
    a += PGSIZE;
    80001276:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001278:	bfc9                	j	8000124a <mappages+0x32>
      panic("remap");
    8000127a:	00008517          	auipc	a0,0x8
    8000127e:	0b650513          	addi	a0,a0,182 # 80009330 <userret+0x2a0>
    80001282:	fffff097          	auipc	ra,0xfffff
    80001286:	2d2080e7          	jalr	722(ra) # 80000554 <panic>
      return -1;
    8000128a:	557d                	li	a0,-1
}
    8000128c:	60a6                	ld	ra,72(sp)
    8000128e:	6406                	ld	s0,64(sp)
    80001290:	74e2                	ld	s1,56(sp)
    80001292:	7942                	ld	s2,48(sp)
    80001294:	79a2                	ld	s3,40(sp)
    80001296:	7a02                	ld	s4,32(sp)
    80001298:	6ae2                	ld	s5,24(sp)
    8000129a:	6b42                	ld	s6,16(sp)
    8000129c:	6ba2                	ld	s7,8(sp)
    8000129e:	6161                	addi	sp,sp,80
    800012a0:	8082                	ret
  return 0;
    800012a2:	4501                	li	a0,0
    800012a4:	b7e5                	j	8000128c <mappages+0x74>

00000000800012a6 <kvmmap>:
{
    800012a6:	1141                	addi	sp,sp,-16
    800012a8:	e406                	sd	ra,8(sp)
    800012aa:	e022                	sd	s0,0(sp)
    800012ac:	0800                	addi	s0,sp,16
    800012ae:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    800012b0:	86ae                	mv	a3,a1
    800012b2:	85aa                	mv	a1,a0
    800012b4:	00028517          	auipc	a0,0x28
    800012b8:	0bc53503          	ld	a0,188(a0) # 80029370 <kernel_pagetable>
    800012bc:	00000097          	auipc	ra,0x0
    800012c0:	f5c080e7          	jalr	-164(ra) # 80001218 <mappages>
    800012c4:	e509                	bnez	a0,800012ce <kvmmap+0x28>
}
    800012c6:	60a2                	ld	ra,8(sp)
    800012c8:	6402                	ld	s0,0(sp)
    800012ca:	0141                	addi	sp,sp,16
    800012cc:	8082                	ret
    panic("kvmmap");
    800012ce:	00008517          	auipc	a0,0x8
    800012d2:	06a50513          	addi	a0,a0,106 # 80009338 <userret+0x2a8>
    800012d6:	fffff097          	auipc	ra,0xfffff
    800012da:	27e080e7          	jalr	638(ra) # 80000554 <panic>

00000000800012de <kvminit>:
{
    800012de:	1101                	addi	sp,sp,-32
    800012e0:	ec06                	sd	ra,24(sp)
    800012e2:	e822                	sd	s0,16(sp)
    800012e4:	e426                	sd	s1,8(sp)
    800012e6:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    800012e8:	fffff097          	auipc	ra,0xfffff
    800012ec:	684080e7          	jalr	1668(ra) # 8000096c <kalloc>
    800012f0:	00028797          	auipc	a5,0x28
    800012f4:	08a7b023          	sd	a0,128(a5) # 80029370 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    800012f8:	6605                	lui	a2,0x1
    800012fa:	4581                	li	a1,0
    800012fc:	00000097          	auipc	ra,0x0
    80001300:	a72080e7          	jalr	-1422(ra) # 80000d6e <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001304:	4699                	li	a3,6
    80001306:	6605                	lui	a2,0x1
    80001308:	100005b7          	lui	a1,0x10000
    8000130c:	10000537          	lui	a0,0x10000
    80001310:	00000097          	auipc	ra,0x0
    80001314:	f96080e7          	jalr	-106(ra) # 800012a6 <kvmmap>
  kvmmap(VIRTION(0), VIRTION(0), PGSIZE, PTE_R | PTE_W);
    80001318:	4699                	li	a3,6
    8000131a:	6605                	lui	a2,0x1
    8000131c:	100015b7          	lui	a1,0x10001
    80001320:	10001537          	lui	a0,0x10001
    80001324:	00000097          	auipc	ra,0x0
    80001328:	f82080e7          	jalr	-126(ra) # 800012a6 <kvmmap>
  kvmmap(VIRTION(1), VIRTION(1), PGSIZE, PTE_R | PTE_W);
    8000132c:	4699                	li	a3,6
    8000132e:	6605                	lui	a2,0x1
    80001330:	100025b7          	lui	a1,0x10002
    80001334:	10002537          	lui	a0,0x10002
    80001338:	00000097          	auipc	ra,0x0
    8000133c:	f6e080e7          	jalr	-146(ra) # 800012a6 <kvmmap>
  kvmmap(0x30000000L, 0x30000000L, 0x10000000, PTE_R | PTE_W);
    80001340:	4699                	li	a3,6
    80001342:	10000637          	lui	a2,0x10000
    80001346:	300005b7          	lui	a1,0x30000
    8000134a:	30000537          	lui	a0,0x30000
    8000134e:	00000097          	auipc	ra,0x0
    80001352:	f58080e7          	jalr	-168(ra) # 800012a6 <kvmmap>
  kvmmap(0x40000000L, 0x40000000L, 0x20000, PTE_R | PTE_W);
    80001356:	4699                	li	a3,6
    80001358:	00020637          	lui	a2,0x20
    8000135c:	400005b7          	lui	a1,0x40000
    80001360:	40000537          	lui	a0,0x40000
    80001364:	00000097          	auipc	ra,0x0
    80001368:	f42080e7          	jalr	-190(ra) # 800012a6 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    8000136c:	4699                	li	a3,6
    8000136e:	6641                	lui	a2,0x10
    80001370:	020005b7          	lui	a1,0x2000
    80001374:	02000537          	lui	a0,0x2000
    80001378:	00000097          	auipc	ra,0x0
    8000137c:	f2e080e7          	jalr	-210(ra) # 800012a6 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001380:	4699                	li	a3,6
    80001382:	00400637          	lui	a2,0x400
    80001386:	0c0005b7          	lui	a1,0xc000
    8000138a:	0c000537          	lui	a0,0xc000
    8000138e:	00000097          	auipc	ra,0x0
    80001392:	f18080e7          	jalr	-232(ra) # 800012a6 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001396:	00009497          	auipc	s1,0x9
    8000139a:	c6a48493          	addi	s1,s1,-918 # 8000a000 <initcode>
    8000139e:	46a9                	li	a3,10
    800013a0:	80009617          	auipc	a2,0x80009
    800013a4:	c6060613          	addi	a2,a2,-928 # a000 <_entry-0x7fff6000>
    800013a8:	4585                	li	a1,1
    800013aa:	05fe                	slli	a1,a1,0x1f
    800013ac:	852e                	mv	a0,a1
    800013ae:	00000097          	auipc	ra,0x0
    800013b2:	ef8080e7          	jalr	-264(ra) # 800012a6 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800013b6:	4699                	li	a3,6
    800013b8:	4645                	li	a2,17
    800013ba:	066e                	slli	a2,a2,0x1b
    800013bc:	8e05                	sub	a2,a2,s1
    800013be:	85a6                	mv	a1,s1
    800013c0:	8526                	mv	a0,s1
    800013c2:	00000097          	auipc	ra,0x0
    800013c6:	ee4080e7          	jalr	-284(ra) # 800012a6 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800013ca:	46a9                	li	a3,10
    800013cc:	6605                	lui	a2,0x1
    800013ce:	00008597          	auipc	a1,0x8
    800013d2:	c3258593          	addi	a1,a1,-974 # 80009000 <trampoline>
    800013d6:	04000537          	lui	a0,0x4000
    800013da:	157d                	addi	a0,a0,-1
    800013dc:	0532                	slli	a0,a0,0xc
    800013de:	00000097          	auipc	ra,0x0
    800013e2:	ec8080e7          	jalr	-312(ra) # 800012a6 <kvmmap>
}
    800013e6:	60e2                	ld	ra,24(sp)
    800013e8:	6442                	ld	s0,16(sp)
    800013ea:	64a2                	ld	s1,8(sp)
    800013ec:	6105                	addi	sp,sp,32
    800013ee:	8082                	ret

00000000800013f0 <uvmunmap>:
{
    800013f0:	715d                	addi	sp,sp,-80
    800013f2:	e486                	sd	ra,72(sp)
    800013f4:	e0a2                	sd	s0,64(sp)
    800013f6:	fc26                	sd	s1,56(sp)
    800013f8:	f84a                	sd	s2,48(sp)
    800013fa:	f44e                	sd	s3,40(sp)
    800013fc:	f052                	sd	s4,32(sp)
    800013fe:	ec56                	sd	s5,24(sp)
    80001400:	e85a                	sd	s6,16(sp)
    80001402:	e45e                	sd	s7,8(sp)
    80001404:	0880                	addi	s0,sp,80
    80001406:	8a2a                	mv	s4,a0
    80001408:	8ab6                	mv	s5,a3
  a = PGROUNDDOWN(va);
    8000140a:	77fd                	lui	a5,0xfffff
    8000140c:	00f5f933          	and	s2,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    80001410:	167d                	addi	a2,a2,-1
    80001412:	00b609b3          	add	s3,a2,a1
    80001416:	00f9f9b3          	and	s3,s3,a5
    if(PTE_FLAGS(*pte) == PTE_V)
    8000141a:	4b05                	li	s6,1
    a += PGSIZE;
    8000141c:	6b85                	lui	s7,0x1
    8000141e:	a0b9                	j	8000146c <uvmunmap+0x7c>
      panic("uvmunmap: walk");
    80001420:	00008517          	auipc	a0,0x8
    80001424:	f2050513          	addi	a0,a0,-224 # 80009340 <userret+0x2b0>
    80001428:	fffff097          	auipc	ra,0xfffff
    8000142c:	12c080e7          	jalr	300(ra) # 80000554 <panic>
      printf("va=%p pte=%p\n", a, *pte);
    80001430:	85ca                	mv	a1,s2
    80001432:	00008517          	auipc	a0,0x8
    80001436:	f1e50513          	addi	a0,a0,-226 # 80009350 <userret+0x2c0>
    8000143a:	fffff097          	auipc	ra,0xfffff
    8000143e:	174080e7          	jalr	372(ra) # 800005ae <printf>
      panic("uvmunmap: not mapped");
    80001442:	00008517          	auipc	a0,0x8
    80001446:	f1e50513          	addi	a0,a0,-226 # 80009360 <userret+0x2d0>
    8000144a:	fffff097          	auipc	ra,0xfffff
    8000144e:	10a080e7          	jalr	266(ra) # 80000554 <panic>
      panic("uvmunmap: not a leaf");
    80001452:	00008517          	auipc	a0,0x8
    80001456:	f2650513          	addi	a0,a0,-218 # 80009378 <userret+0x2e8>
    8000145a:	fffff097          	auipc	ra,0xfffff
    8000145e:	0fa080e7          	jalr	250(ra) # 80000554 <panic>
    *pte = 0;
    80001462:	0004b023          	sd	zero,0(s1)
    if(a == last)
    80001466:	03390e63          	beq	s2,s3,800014a2 <uvmunmap+0xb2>
    a += PGSIZE;
    8000146a:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 0)) == 0)
    8000146c:	4601                	li	a2,0
    8000146e:	85ca                	mv	a1,s2
    80001470:	8552                	mv	a0,s4
    80001472:	00000097          	auipc	ra,0x0
    80001476:	bd2080e7          	jalr	-1070(ra) # 80001044 <walk>
    8000147a:	84aa                	mv	s1,a0
    8000147c:	d155                	beqz	a0,80001420 <uvmunmap+0x30>
    if((*pte & PTE_V) == 0){
    8000147e:	6110                	ld	a2,0(a0)
    80001480:	00167793          	andi	a5,a2,1
    80001484:	d7d5                	beqz	a5,80001430 <uvmunmap+0x40>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001486:	3ff67793          	andi	a5,a2,1023
    8000148a:	fd6784e3          	beq	a5,s6,80001452 <uvmunmap+0x62>
    if(do_free){
    8000148e:	fc0a8ae3          	beqz	s5,80001462 <uvmunmap+0x72>
      pa = PTE2PA(*pte);
    80001492:	8229                	srli	a2,a2,0xa
      kfree((void*)pa);
    80001494:	00c61513          	slli	a0,a2,0xc
    80001498:	fffff097          	auipc	ra,0xfffff
    8000149c:	3d8080e7          	jalr	984(ra) # 80000870 <kfree>
    800014a0:	b7c9                	j	80001462 <uvmunmap+0x72>
}
    800014a2:	60a6                	ld	ra,72(sp)
    800014a4:	6406                	ld	s0,64(sp)
    800014a6:	74e2                	ld	s1,56(sp)
    800014a8:	7942                	ld	s2,48(sp)
    800014aa:	79a2                	ld	s3,40(sp)
    800014ac:	7a02                	ld	s4,32(sp)
    800014ae:	6ae2                	ld	s5,24(sp)
    800014b0:	6b42                	ld	s6,16(sp)
    800014b2:	6ba2                	ld	s7,8(sp)
    800014b4:	6161                	addi	sp,sp,80
    800014b6:	8082                	ret

00000000800014b8 <uvmcreate>:
{
    800014b8:	1101                	addi	sp,sp,-32
    800014ba:	ec06                	sd	ra,24(sp)
    800014bc:	e822                	sd	s0,16(sp)
    800014be:	e426                	sd	s1,8(sp)
    800014c0:	1000                	addi	s0,sp,32
  pagetable = (pagetable_t) kalloc();
    800014c2:	fffff097          	auipc	ra,0xfffff
    800014c6:	4aa080e7          	jalr	1194(ra) # 8000096c <kalloc>
  if(pagetable == 0)
    800014ca:	cd11                	beqz	a0,800014e6 <uvmcreate+0x2e>
    800014cc:	84aa                	mv	s1,a0
  memset(pagetable, 0, PGSIZE);
    800014ce:	6605                	lui	a2,0x1
    800014d0:	4581                	li	a1,0
    800014d2:	00000097          	auipc	ra,0x0
    800014d6:	89c080e7          	jalr	-1892(ra) # 80000d6e <memset>
}
    800014da:	8526                	mv	a0,s1
    800014dc:	60e2                	ld	ra,24(sp)
    800014de:	6442                	ld	s0,16(sp)
    800014e0:	64a2                	ld	s1,8(sp)
    800014e2:	6105                	addi	sp,sp,32
    800014e4:	8082                	ret
    panic("uvmcreate: out of memory");
    800014e6:	00008517          	auipc	a0,0x8
    800014ea:	eaa50513          	addi	a0,a0,-342 # 80009390 <userret+0x300>
    800014ee:	fffff097          	auipc	ra,0xfffff
    800014f2:	066080e7          	jalr	102(ra) # 80000554 <panic>

00000000800014f6 <uvminit>:
{
    800014f6:	7179                	addi	sp,sp,-48
    800014f8:	f406                	sd	ra,40(sp)
    800014fa:	f022                	sd	s0,32(sp)
    800014fc:	ec26                	sd	s1,24(sp)
    800014fe:	e84a                	sd	s2,16(sp)
    80001500:	e44e                	sd	s3,8(sp)
    80001502:	e052                	sd	s4,0(sp)
    80001504:	1800                	addi	s0,sp,48
  if(sz >= PGSIZE)
    80001506:	6785                	lui	a5,0x1
    80001508:	04f67863          	bgeu	a2,a5,80001558 <uvminit+0x62>
    8000150c:	8a2a                	mv	s4,a0
    8000150e:	89ae                	mv	s3,a1
    80001510:	84b2                	mv	s1,a2
  mem = kalloc();
    80001512:	fffff097          	auipc	ra,0xfffff
    80001516:	45a080e7          	jalr	1114(ra) # 8000096c <kalloc>
    8000151a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000151c:	6605                	lui	a2,0x1
    8000151e:	4581                	li	a1,0
    80001520:	00000097          	auipc	ra,0x0
    80001524:	84e080e7          	jalr	-1970(ra) # 80000d6e <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001528:	4779                	li	a4,30
    8000152a:	86ca                	mv	a3,s2
    8000152c:	6605                	lui	a2,0x1
    8000152e:	4581                	li	a1,0
    80001530:	8552                	mv	a0,s4
    80001532:	00000097          	auipc	ra,0x0
    80001536:	ce6080e7          	jalr	-794(ra) # 80001218 <mappages>
  memmove(mem, src, sz);
    8000153a:	8626                	mv	a2,s1
    8000153c:	85ce                	mv	a1,s3
    8000153e:	854a                	mv	a0,s2
    80001540:	00000097          	auipc	ra,0x0
    80001544:	88a080e7          	jalr	-1910(ra) # 80000dca <memmove>
}
    80001548:	70a2                	ld	ra,40(sp)
    8000154a:	7402                	ld	s0,32(sp)
    8000154c:	64e2                	ld	s1,24(sp)
    8000154e:	6942                	ld	s2,16(sp)
    80001550:	69a2                	ld	s3,8(sp)
    80001552:	6a02                	ld	s4,0(sp)
    80001554:	6145                	addi	sp,sp,48
    80001556:	8082                	ret
    panic("inituvm: more than a page");
    80001558:	00008517          	auipc	a0,0x8
    8000155c:	e5850513          	addi	a0,a0,-424 # 800093b0 <userret+0x320>
    80001560:	fffff097          	auipc	ra,0xfffff
    80001564:	ff4080e7          	jalr	-12(ra) # 80000554 <panic>

0000000080001568 <uvmdealloc>:
{
    80001568:	1101                	addi	sp,sp,-32
    8000156a:	ec06                	sd	ra,24(sp)
    8000156c:	e822                	sd	s0,16(sp)
    8000156e:	e426                	sd	s1,8(sp)
    80001570:	1000                	addi	s0,sp,32
    return oldsz;
    80001572:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001574:	00b67d63          	bgeu	a2,a1,8000158e <uvmdealloc+0x26>
    80001578:	84b2                	mv	s1,a2
  uint64 newup = PGROUNDUP(newsz);
    8000157a:	6785                	lui	a5,0x1
    8000157c:	17fd                	addi	a5,a5,-1
    8000157e:	00f60733          	add	a4,a2,a5
    80001582:	76fd                	lui	a3,0xfffff
    80001584:	8f75                	and	a4,a4,a3
  if(newup < PGROUNDUP(oldsz))
    80001586:	97ae                	add	a5,a5,a1
    80001588:	8ff5                	and	a5,a5,a3
    8000158a:	00f76863          	bltu	a4,a5,8000159a <uvmdealloc+0x32>
}
    8000158e:	8526                	mv	a0,s1
    80001590:	60e2                	ld	ra,24(sp)
    80001592:	6442                	ld	s0,16(sp)
    80001594:	64a2                	ld	s1,8(sp)
    80001596:	6105                	addi	sp,sp,32
    80001598:	8082                	ret
    uvmunmap(pagetable, newup, oldsz - newup, 1);
    8000159a:	4685                	li	a3,1
    8000159c:	40e58633          	sub	a2,a1,a4
    800015a0:	85ba                	mv	a1,a4
    800015a2:	00000097          	auipc	ra,0x0
    800015a6:	e4e080e7          	jalr	-434(ra) # 800013f0 <uvmunmap>
    800015aa:	b7d5                	j	8000158e <uvmdealloc+0x26>

00000000800015ac <uvmalloc>:
  if(newsz < oldsz)
    800015ac:	0ab66163          	bltu	a2,a1,8000164e <uvmalloc+0xa2>
{
    800015b0:	7139                	addi	sp,sp,-64
    800015b2:	fc06                	sd	ra,56(sp)
    800015b4:	f822                	sd	s0,48(sp)
    800015b6:	f426                	sd	s1,40(sp)
    800015b8:	f04a                	sd	s2,32(sp)
    800015ba:	ec4e                	sd	s3,24(sp)
    800015bc:	e852                	sd	s4,16(sp)
    800015be:	e456                	sd	s5,8(sp)
    800015c0:	0080                	addi	s0,sp,64
    800015c2:	8aaa                	mv	s5,a0
    800015c4:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800015c6:	6985                	lui	s3,0x1
    800015c8:	19fd                	addi	s3,s3,-1
    800015ca:	95ce                	add	a1,a1,s3
    800015cc:	79fd                	lui	s3,0xfffff
    800015ce:	0135f9b3          	and	s3,a1,s3
  for(; a < newsz; a += PGSIZE){
    800015d2:	08c9f063          	bgeu	s3,a2,80001652 <uvmalloc+0xa6>
  a = oldsz;
    800015d6:	894e                	mv	s2,s3
    mem = kalloc();
    800015d8:	fffff097          	auipc	ra,0xfffff
    800015dc:	394080e7          	jalr	916(ra) # 8000096c <kalloc>
    800015e0:	84aa                	mv	s1,a0
    if(mem == 0){
    800015e2:	c51d                	beqz	a0,80001610 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800015e4:	6605                	lui	a2,0x1
    800015e6:	4581                	li	a1,0
    800015e8:	fffff097          	auipc	ra,0xfffff
    800015ec:	786080e7          	jalr	1926(ra) # 80000d6e <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800015f0:	4779                	li	a4,30
    800015f2:	86a6                	mv	a3,s1
    800015f4:	6605                	lui	a2,0x1
    800015f6:	85ca                	mv	a1,s2
    800015f8:	8556                	mv	a0,s5
    800015fa:	00000097          	auipc	ra,0x0
    800015fe:	c1e080e7          	jalr	-994(ra) # 80001218 <mappages>
    80001602:	e905                	bnez	a0,80001632 <uvmalloc+0x86>
  for(; a < newsz; a += PGSIZE){
    80001604:	6785                	lui	a5,0x1
    80001606:	993e                	add	s2,s2,a5
    80001608:	fd4968e3          	bltu	s2,s4,800015d8 <uvmalloc+0x2c>
  return newsz;
    8000160c:	8552                	mv	a0,s4
    8000160e:	a809                	j	80001620 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001610:	864e                	mv	a2,s3
    80001612:	85ca                	mv	a1,s2
    80001614:	8556                	mv	a0,s5
    80001616:	00000097          	auipc	ra,0x0
    8000161a:	f52080e7          	jalr	-174(ra) # 80001568 <uvmdealloc>
      return 0;
    8000161e:	4501                	li	a0,0
}
    80001620:	70e2                	ld	ra,56(sp)
    80001622:	7442                	ld	s0,48(sp)
    80001624:	74a2                	ld	s1,40(sp)
    80001626:	7902                	ld	s2,32(sp)
    80001628:	69e2                	ld	s3,24(sp)
    8000162a:	6a42                	ld	s4,16(sp)
    8000162c:	6aa2                	ld	s5,8(sp)
    8000162e:	6121                	addi	sp,sp,64
    80001630:	8082                	ret
      kfree(mem);
    80001632:	8526                	mv	a0,s1
    80001634:	fffff097          	auipc	ra,0xfffff
    80001638:	23c080e7          	jalr	572(ra) # 80000870 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000163c:	864e                	mv	a2,s3
    8000163e:	85ca                	mv	a1,s2
    80001640:	8556                	mv	a0,s5
    80001642:	00000097          	auipc	ra,0x0
    80001646:	f26080e7          	jalr	-218(ra) # 80001568 <uvmdealloc>
      return 0;
    8000164a:	4501                	li	a0,0
    8000164c:	bfd1                	j	80001620 <uvmalloc+0x74>
    return oldsz;
    8000164e:	852e                	mv	a0,a1
}
    80001650:	8082                	ret
  return newsz;
    80001652:	8532                	mv	a0,a2
    80001654:	b7f1                	j	80001620 <uvmalloc+0x74>

0000000080001656 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001656:	1101                	addi	sp,sp,-32
    80001658:	ec06                	sd	ra,24(sp)
    8000165a:	e822                	sd	s0,16(sp)
    8000165c:	e426                	sd	s1,8(sp)
    8000165e:	1000                	addi	s0,sp,32
    80001660:	84aa                	mv	s1,a0
    80001662:	862e                	mv	a2,a1
  uvmunmap(pagetable, 0, sz, 1);
    80001664:	4685                	li	a3,1
    80001666:	4581                	li	a1,0
    80001668:	00000097          	auipc	ra,0x0
    8000166c:	d88080e7          	jalr	-632(ra) # 800013f0 <uvmunmap>
  freewalk(pagetable);
    80001670:	8526                	mv	a0,s1
    80001672:	00000097          	auipc	ra,0x0
    80001676:	a78080e7          	jalr	-1416(ra) # 800010ea <freewalk>
}
    8000167a:	60e2                	ld	ra,24(sp)
    8000167c:	6442                	ld	s0,16(sp)
    8000167e:	64a2                	ld	s1,8(sp)
    80001680:	6105                	addi	sp,sp,32
    80001682:	8082                	ret

0000000080001684 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001684:	c671                	beqz	a2,80001750 <uvmcopy+0xcc>
{
    80001686:	715d                	addi	sp,sp,-80
    80001688:	e486                	sd	ra,72(sp)
    8000168a:	e0a2                	sd	s0,64(sp)
    8000168c:	fc26                	sd	s1,56(sp)
    8000168e:	f84a                	sd	s2,48(sp)
    80001690:	f44e                	sd	s3,40(sp)
    80001692:	f052                	sd	s4,32(sp)
    80001694:	ec56                	sd	s5,24(sp)
    80001696:	e85a                	sd	s6,16(sp)
    80001698:	e45e                	sd	s7,8(sp)
    8000169a:	0880                	addi	s0,sp,80
    8000169c:	8b2a                	mv	s6,a0
    8000169e:	8aae                	mv	s5,a1
    800016a0:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800016a2:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800016a4:	4601                	li	a2,0
    800016a6:	85ce                	mv	a1,s3
    800016a8:	855a                	mv	a0,s6
    800016aa:	00000097          	auipc	ra,0x0
    800016ae:	99a080e7          	jalr	-1638(ra) # 80001044 <walk>
    800016b2:	c531                	beqz	a0,800016fe <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800016b4:	6118                	ld	a4,0(a0)
    800016b6:	00177793          	andi	a5,a4,1
    800016ba:	cbb1                	beqz	a5,8000170e <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800016bc:	00a75593          	srli	a1,a4,0xa
    800016c0:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800016c4:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800016c8:	fffff097          	auipc	ra,0xfffff
    800016cc:	2a4080e7          	jalr	676(ra) # 8000096c <kalloc>
    800016d0:	892a                	mv	s2,a0
    800016d2:	c939                	beqz	a0,80001728 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800016d4:	6605                	lui	a2,0x1
    800016d6:	85de                	mv	a1,s7
    800016d8:	fffff097          	auipc	ra,0xfffff
    800016dc:	6f2080e7          	jalr	1778(ra) # 80000dca <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800016e0:	8726                	mv	a4,s1
    800016e2:	86ca                	mv	a3,s2
    800016e4:	6605                	lui	a2,0x1
    800016e6:	85ce                	mv	a1,s3
    800016e8:	8556                	mv	a0,s5
    800016ea:	00000097          	auipc	ra,0x0
    800016ee:	b2e080e7          	jalr	-1234(ra) # 80001218 <mappages>
    800016f2:	e515                	bnez	a0,8000171e <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800016f4:	6785                	lui	a5,0x1
    800016f6:	99be                	add	s3,s3,a5
    800016f8:	fb49e6e3          	bltu	s3,s4,800016a4 <uvmcopy+0x20>
    800016fc:	a83d                	j	8000173a <uvmcopy+0xb6>
      panic("uvmcopy: pte should exist");
    800016fe:	00008517          	auipc	a0,0x8
    80001702:	cd250513          	addi	a0,a0,-814 # 800093d0 <userret+0x340>
    80001706:	fffff097          	auipc	ra,0xfffff
    8000170a:	e4e080e7          	jalr	-434(ra) # 80000554 <panic>
      panic("uvmcopy: page not present");
    8000170e:	00008517          	auipc	a0,0x8
    80001712:	ce250513          	addi	a0,a0,-798 # 800093f0 <userret+0x360>
    80001716:	fffff097          	auipc	ra,0xfffff
    8000171a:	e3e080e7          	jalr	-450(ra) # 80000554 <panic>
      kfree(mem);
    8000171e:	854a                	mv	a0,s2
    80001720:	fffff097          	auipc	ra,0xfffff
    80001724:	150080e7          	jalr	336(ra) # 80000870 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i, 1);
    80001728:	4685                	li	a3,1
    8000172a:	864e                	mv	a2,s3
    8000172c:	4581                	li	a1,0
    8000172e:	8556                	mv	a0,s5
    80001730:	00000097          	auipc	ra,0x0
    80001734:	cc0080e7          	jalr	-832(ra) # 800013f0 <uvmunmap>
  return -1;
    80001738:	557d                	li	a0,-1
}
    8000173a:	60a6                	ld	ra,72(sp)
    8000173c:	6406                	ld	s0,64(sp)
    8000173e:	74e2                	ld	s1,56(sp)
    80001740:	7942                	ld	s2,48(sp)
    80001742:	79a2                	ld	s3,40(sp)
    80001744:	7a02                	ld	s4,32(sp)
    80001746:	6ae2                	ld	s5,24(sp)
    80001748:	6b42                	ld	s6,16(sp)
    8000174a:	6ba2                	ld	s7,8(sp)
    8000174c:	6161                	addi	sp,sp,80
    8000174e:	8082                	ret
  return 0;
    80001750:	4501                	li	a0,0
}
    80001752:	8082                	ret

0000000080001754 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001754:	1141                	addi	sp,sp,-16
    80001756:	e406                	sd	ra,8(sp)
    80001758:	e022                	sd	s0,0(sp)
    8000175a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000175c:	4601                	li	a2,0
    8000175e:	00000097          	auipc	ra,0x0
    80001762:	8e6080e7          	jalr	-1818(ra) # 80001044 <walk>
  if(pte == 0)
    80001766:	c901                	beqz	a0,80001776 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001768:	611c                	ld	a5,0(a0)
    8000176a:	9bbd                	andi	a5,a5,-17
    8000176c:	e11c                	sd	a5,0(a0)
}
    8000176e:	60a2                	ld	ra,8(sp)
    80001770:	6402                	ld	s0,0(sp)
    80001772:	0141                	addi	sp,sp,16
    80001774:	8082                	ret
    panic("uvmclear");
    80001776:	00008517          	auipc	a0,0x8
    8000177a:	c9a50513          	addi	a0,a0,-870 # 80009410 <userret+0x380>
    8000177e:	fffff097          	auipc	ra,0xfffff
    80001782:	dd6080e7          	jalr	-554(ra) # 80000554 <panic>

0000000080001786 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001786:	c6bd                	beqz	a3,800017f4 <copyout+0x6e>
{
    80001788:	715d                	addi	sp,sp,-80
    8000178a:	e486                	sd	ra,72(sp)
    8000178c:	e0a2                	sd	s0,64(sp)
    8000178e:	fc26                	sd	s1,56(sp)
    80001790:	f84a                	sd	s2,48(sp)
    80001792:	f44e                	sd	s3,40(sp)
    80001794:	f052                	sd	s4,32(sp)
    80001796:	ec56                	sd	s5,24(sp)
    80001798:	e85a                	sd	s6,16(sp)
    8000179a:	e45e                	sd	s7,8(sp)
    8000179c:	e062                	sd	s8,0(sp)
    8000179e:	0880                	addi	s0,sp,80
    800017a0:	8b2a                	mv	s6,a0
    800017a2:	8c2e                	mv	s8,a1
    800017a4:	8a32                	mv	s4,a2
    800017a6:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800017a8:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800017aa:	6a85                	lui	s5,0x1
    800017ac:	a015                	j	800017d0 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800017ae:	9562                	add	a0,a0,s8
    800017b0:	0004861b          	sext.w	a2,s1
    800017b4:	85d2                	mv	a1,s4
    800017b6:	41250533          	sub	a0,a0,s2
    800017ba:	fffff097          	auipc	ra,0xfffff
    800017be:	610080e7          	jalr	1552(ra) # 80000dca <memmove>

    len -= n;
    800017c2:	409989b3          	sub	s3,s3,s1
    src += n;
    800017c6:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800017c8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017cc:	02098263          	beqz	s3,800017f0 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800017d0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017d4:	85ca                	mv	a1,s2
    800017d6:	855a                	mv	a0,s6
    800017d8:	00000097          	auipc	ra,0x0
    800017dc:	9a0080e7          	jalr	-1632(ra) # 80001178 <walkaddr>
    if(pa0 == 0)
    800017e0:	cd01                	beqz	a0,800017f8 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800017e2:	418904b3          	sub	s1,s2,s8
    800017e6:	94d6                	add	s1,s1,s5
    if(n > len)
    800017e8:	fc99f3e3          	bgeu	s3,s1,800017ae <copyout+0x28>
    800017ec:	84ce                	mv	s1,s3
    800017ee:	b7c1                	j	800017ae <copyout+0x28>
  }
  return 0;
    800017f0:	4501                	li	a0,0
    800017f2:	a021                	j	800017fa <copyout+0x74>
    800017f4:	4501                	li	a0,0
}
    800017f6:	8082                	ret
      return -1;
    800017f8:	557d                	li	a0,-1
}
    800017fa:	60a6                	ld	ra,72(sp)
    800017fc:	6406                	ld	s0,64(sp)
    800017fe:	74e2                	ld	s1,56(sp)
    80001800:	7942                	ld	s2,48(sp)
    80001802:	79a2                	ld	s3,40(sp)
    80001804:	7a02                	ld	s4,32(sp)
    80001806:	6ae2                	ld	s5,24(sp)
    80001808:	6b42                	ld	s6,16(sp)
    8000180a:	6ba2                	ld	s7,8(sp)
    8000180c:	6c02                	ld	s8,0(sp)
    8000180e:	6161                	addi	sp,sp,80
    80001810:	8082                	ret

0000000080001812 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001812:	caa5                	beqz	a3,80001882 <copyin+0x70>
{
    80001814:	715d                	addi	sp,sp,-80
    80001816:	e486                	sd	ra,72(sp)
    80001818:	e0a2                	sd	s0,64(sp)
    8000181a:	fc26                	sd	s1,56(sp)
    8000181c:	f84a                	sd	s2,48(sp)
    8000181e:	f44e                	sd	s3,40(sp)
    80001820:	f052                	sd	s4,32(sp)
    80001822:	ec56                	sd	s5,24(sp)
    80001824:	e85a                	sd	s6,16(sp)
    80001826:	e45e                	sd	s7,8(sp)
    80001828:	e062                	sd	s8,0(sp)
    8000182a:	0880                	addi	s0,sp,80
    8000182c:	8b2a                	mv	s6,a0
    8000182e:	8a2e                	mv	s4,a1
    80001830:	8c32                	mv	s8,a2
    80001832:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001834:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001836:	6a85                	lui	s5,0x1
    80001838:	a01d                	j	8000185e <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000183a:	018505b3          	add	a1,a0,s8
    8000183e:	0004861b          	sext.w	a2,s1
    80001842:	412585b3          	sub	a1,a1,s2
    80001846:	8552                	mv	a0,s4
    80001848:	fffff097          	auipc	ra,0xfffff
    8000184c:	582080e7          	jalr	1410(ra) # 80000dca <memmove>

    len -= n;
    80001850:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001854:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001856:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000185a:	02098263          	beqz	s3,8000187e <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000185e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001862:	85ca                	mv	a1,s2
    80001864:	855a                	mv	a0,s6
    80001866:	00000097          	auipc	ra,0x0
    8000186a:	912080e7          	jalr	-1774(ra) # 80001178 <walkaddr>
    if(pa0 == 0)
    8000186e:	cd01                	beqz	a0,80001886 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001870:	418904b3          	sub	s1,s2,s8
    80001874:	94d6                	add	s1,s1,s5
    if(n > len)
    80001876:	fc99f2e3          	bgeu	s3,s1,8000183a <copyin+0x28>
    8000187a:	84ce                	mv	s1,s3
    8000187c:	bf7d                	j	8000183a <copyin+0x28>
  }
  return 0;
    8000187e:	4501                	li	a0,0
    80001880:	a021                	j	80001888 <copyin+0x76>
    80001882:	4501                	li	a0,0
}
    80001884:	8082                	ret
      return -1;
    80001886:	557d                	li	a0,-1
}
    80001888:	60a6                	ld	ra,72(sp)
    8000188a:	6406                	ld	s0,64(sp)
    8000188c:	74e2                	ld	s1,56(sp)
    8000188e:	7942                	ld	s2,48(sp)
    80001890:	79a2                	ld	s3,40(sp)
    80001892:	7a02                	ld	s4,32(sp)
    80001894:	6ae2                	ld	s5,24(sp)
    80001896:	6b42                	ld	s6,16(sp)
    80001898:	6ba2                	ld	s7,8(sp)
    8000189a:	6c02                	ld	s8,0(sp)
    8000189c:	6161                	addi	sp,sp,80
    8000189e:	8082                	ret

00000000800018a0 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800018a0:	c6c5                	beqz	a3,80001948 <copyinstr+0xa8>
{
    800018a2:	715d                	addi	sp,sp,-80
    800018a4:	e486                	sd	ra,72(sp)
    800018a6:	e0a2                	sd	s0,64(sp)
    800018a8:	fc26                	sd	s1,56(sp)
    800018aa:	f84a                	sd	s2,48(sp)
    800018ac:	f44e                	sd	s3,40(sp)
    800018ae:	f052                	sd	s4,32(sp)
    800018b0:	ec56                	sd	s5,24(sp)
    800018b2:	e85a                	sd	s6,16(sp)
    800018b4:	e45e                	sd	s7,8(sp)
    800018b6:	0880                	addi	s0,sp,80
    800018b8:	8a2a                	mv	s4,a0
    800018ba:	8b2e                	mv	s6,a1
    800018bc:	8bb2                	mv	s7,a2
    800018be:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800018c0:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800018c2:	6985                	lui	s3,0x1
    800018c4:	a035                	j	800018f0 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800018c6:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800018ca:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800018cc:	0017b793          	seqz	a5,a5
    800018d0:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800018d4:	60a6                	ld	ra,72(sp)
    800018d6:	6406                	ld	s0,64(sp)
    800018d8:	74e2                	ld	s1,56(sp)
    800018da:	7942                	ld	s2,48(sp)
    800018dc:	79a2                	ld	s3,40(sp)
    800018de:	7a02                	ld	s4,32(sp)
    800018e0:	6ae2                	ld	s5,24(sp)
    800018e2:	6b42                	ld	s6,16(sp)
    800018e4:	6ba2                	ld	s7,8(sp)
    800018e6:	6161                	addi	sp,sp,80
    800018e8:	8082                	ret
    srcva = va0 + PGSIZE;
    800018ea:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800018ee:	c8a9                	beqz	s1,80001940 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800018f0:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800018f4:	85ca                	mv	a1,s2
    800018f6:	8552                	mv	a0,s4
    800018f8:	00000097          	auipc	ra,0x0
    800018fc:	880080e7          	jalr	-1920(ra) # 80001178 <walkaddr>
    if(pa0 == 0)
    80001900:	c131                	beqz	a0,80001944 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001902:	41790833          	sub	a6,s2,s7
    80001906:	984e                	add	a6,a6,s3
    if(n > max)
    80001908:	0104f363          	bgeu	s1,a6,8000190e <copyinstr+0x6e>
    8000190c:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000190e:	955e                	add	a0,a0,s7
    80001910:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001914:	fc080be3          	beqz	a6,800018ea <copyinstr+0x4a>
    80001918:	985a                	add	a6,a6,s6
    8000191a:	87da                	mv	a5,s6
      if(*p == '\0'){
    8000191c:	41650633          	sub	a2,a0,s6
    80001920:	14fd                	addi	s1,s1,-1
    80001922:	9b26                	add	s6,s6,s1
    80001924:	00f60733          	add	a4,a2,a5
    80001928:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd5c54>
    8000192c:	df49                	beqz	a4,800018c6 <copyinstr+0x26>
        *dst = *p;
    8000192e:	00e78023          	sb	a4,0(a5)
      --max;
    80001932:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001936:	0785                	addi	a5,a5,1
    while(n > 0){
    80001938:	ff0796e3          	bne	a5,a6,80001924 <copyinstr+0x84>
      dst++;
    8000193c:	8b42                	mv	s6,a6
    8000193e:	b775                	j	800018ea <copyinstr+0x4a>
    80001940:	4781                	li	a5,0
    80001942:	b769                	j	800018cc <copyinstr+0x2c>
      return -1;
    80001944:	557d                	li	a0,-1
    80001946:	b779                	j	800018d4 <copyinstr+0x34>
  int got_null = 0;
    80001948:	4781                	li	a5,0
  if(got_null){
    8000194a:	0017b793          	seqz	a5,a5
    8000194e:	40f00533          	neg	a0,a5
}
    80001952:	8082                	ret

0000000080001954 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001954:	1101                	addi	sp,sp,-32
    80001956:	ec06                	sd	ra,24(sp)
    80001958:	e822                	sd	s0,16(sp)
    8000195a:	e426                	sd	s1,8(sp)
    8000195c:	1000                	addi	s0,sp,32
    8000195e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001960:	fffff097          	auipc	ra,0xfffff
    80001964:	0c2080e7          	jalr	194(ra) # 80000a22 <holding>
    80001968:	c909                	beqz	a0,8000197a <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    8000196a:	789c                	ld	a5,48(s1)
    8000196c:	00978f63          	beq	a5,s1,8000198a <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001970:	60e2                	ld	ra,24(sp)
    80001972:	6442                	ld	s0,16(sp)
    80001974:	64a2                	ld	s1,8(sp)
    80001976:	6105                	addi	sp,sp,32
    80001978:	8082                	ret
    panic("wakeup1");
    8000197a:	00008517          	auipc	a0,0x8
    8000197e:	aa650513          	addi	a0,a0,-1370 # 80009420 <userret+0x390>
    80001982:	fffff097          	auipc	ra,0xfffff
    80001986:	bd2080e7          	jalr	-1070(ra) # 80000554 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    8000198a:	5098                	lw	a4,32(s1)
    8000198c:	4785                	li	a5,1
    8000198e:	fef711e3          	bne	a4,a5,80001970 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001992:	4789                	li	a5,2
    80001994:	d09c                	sw	a5,32(s1)
}
    80001996:	bfe9                	j	80001970 <wakeup1+0x1c>

0000000080001998 <procinit>:
{
    80001998:	715d                	addi	sp,sp,-80
    8000199a:	e486                	sd	ra,72(sp)
    8000199c:	e0a2                	sd	s0,64(sp)
    8000199e:	fc26                	sd	s1,56(sp)
    800019a0:	f84a                	sd	s2,48(sp)
    800019a2:	f44e                	sd	s3,40(sp)
    800019a4:	f052                	sd	s4,32(sp)
    800019a6:	ec56                	sd	s5,24(sp)
    800019a8:	e85a                	sd	s6,16(sp)
    800019aa:	e45e                	sd	s7,8(sp)
    800019ac:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    800019ae:	00008597          	auipc	a1,0x8
    800019b2:	a7a58593          	addi	a1,a1,-1414 # 80009428 <userret+0x398>
    800019b6:	00014517          	auipc	a0,0x14
    800019ba:	e8a50513          	addi	a0,a0,-374 # 80015840 <pid_lock>
    800019be:	fffff097          	auipc	ra,0xfffff
    800019c2:	00e080e7          	jalr	14(ra) # 800009cc <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800019c6:	00014917          	auipc	s2,0x14
    800019ca:	29a90913          	addi	s2,s2,666 # 80015c60 <proc>
      initlock(&p->lock, "proc");
    800019ce:	00008a17          	auipc	s4,0x8
    800019d2:	a62a0a13          	addi	s4,s4,-1438 # 80009430 <userret+0x3a0>
      uint64 va = KSTACK((int) (p - proc));
    800019d6:	8bca                	mv	s7,s2
    800019d8:	00008b17          	auipc	s6,0x8
    800019dc:	5a0b0b13          	addi	s6,s6,1440 # 80009f78 <syscalls+0xc0>
    800019e0:	040009b7          	lui	s3,0x4000
    800019e4:	19fd                	addi	s3,s3,-1
    800019e6:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019e8:	00015a97          	auipc	s5,0x15
    800019ec:	0d8a8a93          	addi	s5,s5,216 # 80016ac0 <tickslock>
      initlock(&p->lock, "proc");
    800019f0:	85d2                	mv	a1,s4
    800019f2:	854a                	mv	a0,s2
    800019f4:	fffff097          	auipc	ra,0xfffff
    800019f8:	fd8080e7          	jalr	-40(ra) # 800009cc <initlock>
      char *pa = kalloc();
    800019fc:	fffff097          	auipc	ra,0xfffff
    80001a00:	f70080e7          	jalr	-144(ra) # 8000096c <kalloc>
    80001a04:	85aa                	mv	a1,a0
      if(pa == 0)
    80001a06:	c929                	beqz	a0,80001a58 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001a08:	417904b3          	sub	s1,s2,s7
    80001a0c:	8491                	srai	s1,s1,0x4
    80001a0e:	000b3783          	ld	a5,0(s6)
    80001a12:	02f484b3          	mul	s1,s1,a5
    80001a16:	2485                	addiw	s1,s1,1
    80001a18:	00d4949b          	slliw	s1,s1,0xd
    80001a1c:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a20:	4699                	li	a3,6
    80001a22:	6605                	lui	a2,0x1
    80001a24:	8526                	mv	a0,s1
    80001a26:	00000097          	auipc	ra,0x0
    80001a2a:	880080e7          	jalr	-1920(ra) # 800012a6 <kvmmap>
      p->kstack = va;
    80001a2e:	04993423          	sd	s1,72(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a32:	17090913          	addi	s2,s2,368
    80001a36:	fb591de3          	bne	s2,s5,800019f0 <procinit+0x58>
  kvminithart();
    80001a3a:	fffff097          	auipc	ra,0xfffff
    80001a3e:	71a080e7          	jalr	1818(ra) # 80001154 <kvminithart>
}
    80001a42:	60a6                	ld	ra,72(sp)
    80001a44:	6406                	ld	s0,64(sp)
    80001a46:	74e2                	ld	s1,56(sp)
    80001a48:	7942                	ld	s2,48(sp)
    80001a4a:	79a2                	ld	s3,40(sp)
    80001a4c:	7a02                	ld	s4,32(sp)
    80001a4e:	6ae2                	ld	s5,24(sp)
    80001a50:	6b42                	ld	s6,16(sp)
    80001a52:	6ba2                	ld	s7,8(sp)
    80001a54:	6161                	addi	sp,sp,80
    80001a56:	8082                	ret
        panic("kalloc");
    80001a58:	00008517          	auipc	a0,0x8
    80001a5c:	9e050513          	addi	a0,a0,-1568 # 80009438 <userret+0x3a8>
    80001a60:	fffff097          	auipc	ra,0xfffff
    80001a64:	af4080e7          	jalr	-1292(ra) # 80000554 <panic>

0000000080001a68 <cpuid>:
{
    80001a68:	1141                	addi	sp,sp,-16
    80001a6a:	e422                	sd	s0,8(sp)
    80001a6c:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a6e:	8512                	mv	a0,tp
}
    80001a70:	2501                	sext.w	a0,a0
    80001a72:	6422                	ld	s0,8(sp)
    80001a74:	0141                	addi	sp,sp,16
    80001a76:	8082                	ret

0000000080001a78 <mycpu>:
mycpu(void) {
    80001a78:	1141                	addi	sp,sp,-16
    80001a7a:	e422                	sd	s0,8(sp)
    80001a7c:	0800                	addi	s0,sp,16
    80001a7e:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001a80:	2781                	sext.w	a5,a5
    80001a82:	079e                	slli	a5,a5,0x7
}
    80001a84:	00014517          	auipc	a0,0x14
    80001a88:	ddc50513          	addi	a0,a0,-548 # 80015860 <cpus>
    80001a8c:	953e                	add	a0,a0,a5
    80001a8e:	6422                	ld	s0,8(sp)
    80001a90:	0141                	addi	sp,sp,16
    80001a92:	8082                	ret

0000000080001a94 <myproc>:
myproc(void) {
    80001a94:	1101                	addi	sp,sp,-32
    80001a96:	ec06                	sd	ra,24(sp)
    80001a98:	e822                	sd	s0,16(sp)
    80001a9a:	e426                	sd	s1,8(sp)
    80001a9c:	1000                	addi	s0,sp,32
  push_off();
    80001a9e:	fffff097          	auipc	ra,0xfffff
    80001aa2:	fb2080e7          	jalr	-78(ra) # 80000a50 <push_off>
    80001aa6:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001aa8:	2781                	sext.w	a5,a5
    80001aaa:	079e                	slli	a5,a5,0x7
    80001aac:	00014717          	auipc	a4,0x14
    80001ab0:	d9470713          	addi	a4,a4,-620 # 80015840 <pid_lock>
    80001ab4:	97ba                	add	a5,a5,a4
    80001ab6:	7384                	ld	s1,32(a5)
  pop_off();
    80001ab8:	fffff097          	auipc	ra,0xfffff
    80001abc:	058080e7          	jalr	88(ra) # 80000b10 <pop_off>
}
    80001ac0:	8526                	mv	a0,s1
    80001ac2:	60e2                	ld	ra,24(sp)
    80001ac4:	6442                	ld	s0,16(sp)
    80001ac6:	64a2                	ld	s1,8(sp)
    80001ac8:	6105                	addi	sp,sp,32
    80001aca:	8082                	ret

0000000080001acc <forkret>:
{
    80001acc:	1141                	addi	sp,sp,-16
    80001ace:	e406                	sd	ra,8(sp)
    80001ad0:	e022                	sd	s0,0(sp)
    80001ad2:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001ad4:	00000097          	auipc	ra,0x0
    80001ad8:	fc0080e7          	jalr	-64(ra) # 80001a94 <myproc>
    80001adc:	fffff097          	auipc	ra,0xfffff
    80001ae0:	094080e7          	jalr	148(ra) # 80000b70 <release>
  if (first) {
    80001ae4:	00008797          	auipc	a5,0x8
    80001ae8:	5547a783          	lw	a5,1364(a5) # 8000a038 <first.1>
    80001aec:	eb89                	bnez	a5,80001afe <forkret+0x32>
  usertrapret();
    80001aee:	00001097          	auipc	ra,0x1
    80001af2:	c5e080e7          	jalr	-930(ra) # 8000274c <usertrapret>
}
    80001af6:	60a2                	ld	ra,8(sp)
    80001af8:	6402                	ld	s0,0(sp)
    80001afa:	0141                	addi	sp,sp,16
    80001afc:	8082                	ret
    first = 0;
    80001afe:	00008797          	auipc	a5,0x8
    80001b02:	5207ad23          	sw	zero,1338(a5) # 8000a038 <first.1>
    fsinit(minor(ROOTDEV));
    80001b06:	4501                	li	a0,0
    80001b08:	00002097          	auipc	ra,0x2
    80001b0c:	9ae080e7          	jalr	-1618(ra) # 800034b6 <fsinit>
    80001b10:	bff9                	j	80001aee <forkret+0x22>

0000000080001b12 <allocpid>:
allocpid() {
    80001b12:	1101                	addi	sp,sp,-32
    80001b14:	ec06                	sd	ra,24(sp)
    80001b16:	e822                	sd	s0,16(sp)
    80001b18:	e426                	sd	s1,8(sp)
    80001b1a:	e04a                	sd	s2,0(sp)
    80001b1c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b1e:	00014917          	auipc	s2,0x14
    80001b22:	d2290913          	addi	s2,s2,-734 # 80015840 <pid_lock>
    80001b26:	854a                	mv	a0,s2
    80001b28:	fffff097          	auipc	ra,0xfffff
    80001b2c:	f78080e7          	jalr	-136(ra) # 80000aa0 <acquire>
  pid = nextpid;
    80001b30:	00008797          	auipc	a5,0x8
    80001b34:	50c78793          	addi	a5,a5,1292 # 8000a03c <nextpid>
    80001b38:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b3a:	0014871b          	addiw	a4,s1,1
    80001b3e:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b40:	854a                	mv	a0,s2
    80001b42:	fffff097          	auipc	ra,0xfffff
    80001b46:	02e080e7          	jalr	46(ra) # 80000b70 <release>
}
    80001b4a:	8526                	mv	a0,s1
    80001b4c:	60e2                	ld	ra,24(sp)
    80001b4e:	6442                	ld	s0,16(sp)
    80001b50:	64a2                	ld	s1,8(sp)
    80001b52:	6902                	ld	s2,0(sp)
    80001b54:	6105                	addi	sp,sp,32
    80001b56:	8082                	ret

0000000080001b58 <proc_pagetable>:
{
    80001b58:	1101                	addi	sp,sp,-32
    80001b5a:	ec06                	sd	ra,24(sp)
    80001b5c:	e822                	sd	s0,16(sp)
    80001b5e:	e426                	sd	s1,8(sp)
    80001b60:	e04a                	sd	s2,0(sp)
    80001b62:	1000                	addi	s0,sp,32
    80001b64:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b66:	00000097          	auipc	ra,0x0
    80001b6a:	952080e7          	jalr	-1710(ra) # 800014b8 <uvmcreate>
    80001b6e:	84aa                	mv	s1,a0
  mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b70:	4729                	li	a4,10
    80001b72:	00007697          	auipc	a3,0x7
    80001b76:	48e68693          	addi	a3,a3,1166 # 80009000 <trampoline>
    80001b7a:	6605                	lui	a2,0x1
    80001b7c:	040005b7          	lui	a1,0x4000
    80001b80:	15fd                	addi	a1,a1,-1
    80001b82:	05b2                	slli	a1,a1,0xc
    80001b84:	fffff097          	auipc	ra,0xfffff
    80001b88:	694080e7          	jalr	1684(ra) # 80001218 <mappages>
  mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b8c:	4719                	li	a4,6
    80001b8e:	06093683          	ld	a3,96(s2)
    80001b92:	6605                	lui	a2,0x1
    80001b94:	020005b7          	lui	a1,0x2000
    80001b98:	15fd                	addi	a1,a1,-1
    80001b9a:	05b6                	slli	a1,a1,0xd
    80001b9c:	8526                	mv	a0,s1
    80001b9e:	fffff097          	auipc	ra,0xfffff
    80001ba2:	67a080e7          	jalr	1658(ra) # 80001218 <mappages>
}
    80001ba6:	8526                	mv	a0,s1
    80001ba8:	60e2                	ld	ra,24(sp)
    80001baa:	6442                	ld	s0,16(sp)
    80001bac:	64a2                	ld	s1,8(sp)
    80001bae:	6902                	ld	s2,0(sp)
    80001bb0:	6105                	addi	sp,sp,32
    80001bb2:	8082                	ret

0000000080001bb4 <allocproc>:
{
    80001bb4:	1101                	addi	sp,sp,-32
    80001bb6:	ec06                	sd	ra,24(sp)
    80001bb8:	e822                	sd	s0,16(sp)
    80001bba:	e426                	sd	s1,8(sp)
    80001bbc:	e04a                	sd	s2,0(sp)
    80001bbe:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bc0:	00014497          	auipc	s1,0x14
    80001bc4:	0a048493          	addi	s1,s1,160 # 80015c60 <proc>
    80001bc8:	00015917          	auipc	s2,0x15
    80001bcc:	ef890913          	addi	s2,s2,-264 # 80016ac0 <tickslock>
    acquire(&p->lock);
    80001bd0:	8526                	mv	a0,s1
    80001bd2:	fffff097          	auipc	ra,0xfffff
    80001bd6:	ece080e7          	jalr	-306(ra) # 80000aa0 <acquire>
    if(p->state == UNUSED) {
    80001bda:	509c                	lw	a5,32(s1)
    80001bdc:	c395                	beqz	a5,80001c00 <allocproc+0x4c>
      release(&p->lock);
    80001bde:	8526                	mv	a0,s1
    80001be0:	fffff097          	auipc	ra,0xfffff
    80001be4:	f90080e7          	jalr	-112(ra) # 80000b70 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001be8:	17048493          	addi	s1,s1,368
    80001bec:	ff2492e3          	bne	s1,s2,80001bd0 <allocproc+0x1c>
  return 0;
    80001bf0:	4481                	li	s1,0
}
    80001bf2:	8526                	mv	a0,s1
    80001bf4:	60e2                	ld	ra,24(sp)
    80001bf6:	6442                	ld	s0,16(sp)
    80001bf8:	64a2                	ld	s1,8(sp)
    80001bfa:	6902                	ld	s2,0(sp)
    80001bfc:	6105                	addi	sp,sp,32
    80001bfe:	8082                	ret
  p->pid = allocpid();
    80001c00:	00000097          	auipc	ra,0x0
    80001c04:	f12080e7          	jalr	-238(ra) # 80001b12 <allocpid>
    80001c08:	c0a8                	sw	a0,64(s1)
  if((p->tf = (struct trapframe *)kalloc()) == 0){
    80001c0a:	fffff097          	auipc	ra,0xfffff
    80001c0e:	d62080e7          	jalr	-670(ra) # 8000096c <kalloc>
    80001c12:	892a                	mv	s2,a0
    80001c14:	f0a8                	sd	a0,96(s1)
    80001c16:	c915                	beqz	a0,80001c4a <allocproc+0x96>
  p->pagetable = proc_pagetable(p);
    80001c18:	8526                	mv	a0,s1
    80001c1a:	00000097          	auipc	ra,0x0
    80001c1e:	f3e080e7          	jalr	-194(ra) # 80001b58 <proc_pagetable>
    80001c22:	eca8                	sd	a0,88(s1)
  memset(&p->context, 0, sizeof p->context);
    80001c24:	07000613          	li	a2,112
    80001c28:	4581                	li	a1,0
    80001c2a:	06848513          	addi	a0,s1,104
    80001c2e:	fffff097          	auipc	ra,0xfffff
    80001c32:	140080e7          	jalr	320(ra) # 80000d6e <memset>
  p->context.ra = (uint64)forkret;
    80001c36:	00000797          	auipc	a5,0x0
    80001c3a:	e9678793          	addi	a5,a5,-362 # 80001acc <forkret>
    80001c3e:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c40:	64bc                	ld	a5,72(s1)
    80001c42:	6705                	lui	a4,0x1
    80001c44:	97ba                	add	a5,a5,a4
    80001c46:	f8bc                	sd	a5,112(s1)
  return p;
    80001c48:	b76d                	j	80001bf2 <allocproc+0x3e>
    release(&p->lock);
    80001c4a:	8526                	mv	a0,s1
    80001c4c:	fffff097          	auipc	ra,0xfffff
    80001c50:	f24080e7          	jalr	-220(ra) # 80000b70 <release>
    return 0;
    80001c54:	84ca                	mv	s1,s2
    80001c56:	bf71                	j	80001bf2 <allocproc+0x3e>

0000000080001c58 <proc_freepagetable>:
{
    80001c58:	1101                	addi	sp,sp,-32
    80001c5a:	ec06                	sd	ra,24(sp)
    80001c5c:	e822                	sd	s0,16(sp)
    80001c5e:	e426                	sd	s1,8(sp)
    80001c60:	e04a                	sd	s2,0(sp)
    80001c62:	1000                	addi	s0,sp,32
    80001c64:	84aa                	mv	s1,a0
    80001c66:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, PGSIZE, 0);
    80001c68:	4681                	li	a3,0
    80001c6a:	6605                	lui	a2,0x1
    80001c6c:	040005b7          	lui	a1,0x4000
    80001c70:	15fd                	addi	a1,a1,-1
    80001c72:	05b2                	slli	a1,a1,0xc
    80001c74:	fffff097          	auipc	ra,0xfffff
    80001c78:	77c080e7          	jalr	1916(ra) # 800013f0 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, PGSIZE, 0);
    80001c7c:	4681                	li	a3,0
    80001c7e:	6605                	lui	a2,0x1
    80001c80:	020005b7          	lui	a1,0x2000
    80001c84:	15fd                	addi	a1,a1,-1
    80001c86:	05b6                	slli	a1,a1,0xd
    80001c88:	8526                	mv	a0,s1
    80001c8a:	fffff097          	auipc	ra,0xfffff
    80001c8e:	766080e7          	jalr	1894(ra) # 800013f0 <uvmunmap>
  if(sz > 0)
    80001c92:	00091863          	bnez	s2,80001ca2 <proc_freepagetable+0x4a>
}
    80001c96:	60e2                	ld	ra,24(sp)
    80001c98:	6442                	ld	s0,16(sp)
    80001c9a:	64a2                	ld	s1,8(sp)
    80001c9c:	6902                	ld	s2,0(sp)
    80001c9e:	6105                	addi	sp,sp,32
    80001ca0:	8082                	ret
    uvmfree(pagetable, sz);
    80001ca2:	85ca                	mv	a1,s2
    80001ca4:	8526                	mv	a0,s1
    80001ca6:	00000097          	auipc	ra,0x0
    80001caa:	9b0080e7          	jalr	-1616(ra) # 80001656 <uvmfree>
}
    80001cae:	b7e5                	j	80001c96 <proc_freepagetable+0x3e>

0000000080001cb0 <freeproc>:
{
    80001cb0:	1101                	addi	sp,sp,-32
    80001cb2:	ec06                	sd	ra,24(sp)
    80001cb4:	e822                	sd	s0,16(sp)
    80001cb6:	e426                	sd	s1,8(sp)
    80001cb8:	1000                	addi	s0,sp,32
    80001cba:	84aa                	mv	s1,a0
  if(p->tf)
    80001cbc:	7128                	ld	a0,96(a0)
    80001cbe:	c509                	beqz	a0,80001cc8 <freeproc+0x18>
    kfree((void*)p->tf);
    80001cc0:	fffff097          	auipc	ra,0xfffff
    80001cc4:	bb0080e7          	jalr	-1104(ra) # 80000870 <kfree>
  p->tf = 0;
    80001cc8:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001ccc:	6ca8                	ld	a0,88(s1)
    80001cce:	c511                	beqz	a0,80001cda <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001cd0:	68ac                	ld	a1,80(s1)
    80001cd2:	00000097          	auipc	ra,0x0
    80001cd6:	f86080e7          	jalr	-122(ra) # 80001c58 <proc_freepagetable>
  p->pagetable = 0;
    80001cda:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001cde:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001ce2:	0404a023          	sw	zero,64(s1)
  p->parent = 0;
    80001ce6:	0204b423          	sd	zero,40(s1)
  p->name[0] = 0;
    80001cea:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001cee:	0204b823          	sd	zero,48(s1)
  p->killed = 0;
    80001cf2:	0204ac23          	sw	zero,56(s1)
  p->xstate = 0;
    80001cf6:	0204ae23          	sw	zero,60(s1)
  p->state = UNUSED;
    80001cfa:	0204a023          	sw	zero,32(s1)
}
    80001cfe:	60e2                	ld	ra,24(sp)
    80001d00:	6442                	ld	s0,16(sp)
    80001d02:	64a2                	ld	s1,8(sp)
    80001d04:	6105                	addi	sp,sp,32
    80001d06:	8082                	ret

0000000080001d08 <userinit>:
{
    80001d08:	1101                	addi	sp,sp,-32
    80001d0a:	ec06                	sd	ra,24(sp)
    80001d0c:	e822                	sd	s0,16(sp)
    80001d0e:	e426                	sd	s1,8(sp)
    80001d10:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d12:	00000097          	auipc	ra,0x0
    80001d16:	ea2080e7          	jalr	-350(ra) # 80001bb4 <allocproc>
    80001d1a:	84aa                	mv	s1,a0
  initproc = p;
    80001d1c:	00027797          	auipc	a5,0x27
    80001d20:	64a7be23          	sd	a0,1628(a5) # 80029378 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d24:	03300613          	li	a2,51
    80001d28:	00008597          	auipc	a1,0x8
    80001d2c:	2d858593          	addi	a1,a1,728 # 8000a000 <initcode>
    80001d30:	6d28                	ld	a0,88(a0)
    80001d32:	fffff097          	auipc	ra,0xfffff
    80001d36:	7c4080e7          	jalr	1988(ra) # 800014f6 <uvminit>
  p->sz = PGSIZE;
    80001d3a:	6785                	lui	a5,0x1
    80001d3c:	e8bc                	sd	a5,80(s1)
  p->tf->epc = 0;      // user program counter
    80001d3e:	70b8                	ld	a4,96(s1)
    80001d40:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->tf->sp = PGSIZE;  // user stack pointer
    80001d44:	70b8                	ld	a4,96(s1)
    80001d46:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d48:	4641                	li	a2,16
    80001d4a:	00007597          	auipc	a1,0x7
    80001d4e:	6f658593          	addi	a1,a1,1782 # 80009440 <userret+0x3b0>
    80001d52:	16048513          	addi	a0,s1,352
    80001d56:	fffff097          	auipc	ra,0xfffff
    80001d5a:	16a080e7          	jalr	362(ra) # 80000ec0 <safestrcpy>
  p->cwd = namei("/");
    80001d5e:	00007517          	auipc	a0,0x7
    80001d62:	6f250513          	addi	a0,a0,1778 # 80009450 <userret+0x3c0>
    80001d66:	00002097          	auipc	ra,0x2
    80001d6a:	152080e7          	jalr	338(ra) # 80003eb8 <namei>
    80001d6e:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001d72:	4789                	li	a5,2
    80001d74:	d09c                	sw	a5,32(s1)
  release(&p->lock);
    80001d76:	8526                	mv	a0,s1
    80001d78:	fffff097          	auipc	ra,0xfffff
    80001d7c:	df8080e7          	jalr	-520(ra) # 80000b70 <release>
}
    80001d80:	60e2                	ld	ra,24(sp)
    80001d82:	6442                	ld	s0,16(sp)
    80001d84:	64a2                	ld	s1,8(sp)
    80001d86:	6105                	addi	sp,sp,32
    80001d88:	8082                	ret

0000000080001d8a <growproc>:
{
    80001d8a:	1101                	addi	sp,sp,-32
    80001d8c:	ec06                	sd	ra,24(sp)
    80001d8e:	e822                	sd	s0,16(sp)
    80001d90:	e426                	sd	s1,8(sp)
    80001d92:	e04a                	sd	s2,0(sp)
    80001d94:	1000                	addi	s0,sp,32
    80001d96:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d98:	00000097          	auipc	ra,0x0
    80001d9c:	cfc080e7          	jalr	-772(ra) # 80001a94 <myproc>
    80001da0:	892a                	mv	s2,a0
  sz = p->sz;
    80001da2:	692c                	ld	a1,80(a0)
    80001da4:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001da8:	00904f63          	bgtz	s1,80001dc6 <growproc+0x3c>
  } else if(n < 0){
    80001dac:	0204cc63          	bltz	s1,80001de4 <growproc+0x5a>
  p->sz = sz;
    80001db0:	1602                	slli	a2,a2,0x20
    80001db2:	9201                	srli	a2,a2,0x20
    80001db4:	04c93823          	sd	a2,80(s2)
  return 0;
    80001db8:	4501                	li	a0,0
}
    80001dba:	60e2                	ld	ra,24(sp)
    80001dbc:	6442                	ld	s0,16(sp)
    80001dbe:	64a2                	ld	s1,8(sp)
    80001dc0:	6902                	ld	s2,0(sp)
    80001dc2:	6105                	addi	sp,sp,32
    80001dc4:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001dc6:	9e25                	addw	a2,a2,s1
    80001dc8:	1602                	slli	a2,a2,0x20
    80001dca:	9201                	srli	a2,a2,0x20
    80001dcc:	1582                	slli	a1,a1,0x20
    80001dce:	9181                	srli	a1,a1,0x20
    80001dd0:	6d28                	ld	a0,88(a0)
    80001dd2:	fffff097          	auipc	ra,0xfffff
    80001dd6:	7da080e7          	jalr	2010(ra) # 800015ac <uvmalloc>
    80001dda:	0005061b          	sext.w	a2,a0
    80001dde:	fa69                	bnez	a2,80001db0 <growproc+0x26>
      return -1;
    80001de0:	557d                	li	a0,-1
    80001de2:	bfe1                	j	80001dba <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001de4:	9e25                	addw	a2,a2,s1
    80001de6:	1602                	slli	a2,a2,0x20
    80001de8:	9201                	srli	a2,a2,0x20
    80001dea:	1582                	slli	a1,a1,0x20
    80001dec:	9181                	srli	a1,a1,0x20
    80001dee:	6d28                	ld	a0,88(a0)
    80001df0:	fffff097          	auipc	ra,0xfffff
    80001df4:	778080e7          	jalr	1912(ra) # 80001568 <uvmdealloc>
    80001df8:	0005061b          	sext.w	a2,a0
    80001dfc:	bf55                	j	80001db0 <growproc+0x26>

0000000080001dfe <fork>:
{
    80001dfe:	7139                	addi	sp,sp,-64
    80001e00:	fc06                	sd	ra,56(sp)
    80001e02:	f822                	sd	s0,48(sp)
    80001e04:	f426                	sd	s1,40(sp)
    80001e06:	f04a                	sd	s2,32(sp)
    80001e08:	ec4e                	sd	s3,24(sp)
    80001e0a:	e852                	sd	s4,16(sp)
    80001e0c:	e456                	sd	s5,8(sp)
    80001e0e:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e10:	00000097          	auipc	ra,0x0
    80001e14:	c84080e7          	jalr	-892(ra) # 80001a94 <myproc>
    80001e18:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e1a:	00000097          	auipc	ra,0x0
    80001e1e:	d9a080e7          	jalr	-614(ra) # 80001bb4 <allocproc>
    80001e22:	c17d                	beqz	a0,80001f08 <fork+0x10a>
    80001e24:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e26:	050ab603          	ld	a2,80(s5)
    80001e2a:	6d2c                	ld	a1,88(a0)
    80001e2c:	058ab503          	ld	a0,88(s5)
    80001e30:	00000097          	auipc	ra,0x0
    80001e34:	854080e7          	jalr	-1964(ra) # 80001684 <uvmcopy>
    80001e38:	04054a63          	bltz	a0,80001e8c <fork+0x8e>
  np->sz = p->sz;
    80001e3c:	050ab783          	ld	a5,80(s5)
    80001e40:	04fa3823          	sd	a5,80(s4)
  np->parent = p;
    80001e44:	035a3423          	sd	s5,40(s4)
  *(np->tf) = *(p->tf);
    80001e48:	060ab683          	ld	a3,96(s5)
    80001e4c:	87b6                	mv	a5,a3
    80001e4e:	060a3703          	ld	a4,96(s4)
    80001e52:	12068693          	addi	a3,a3,288
    80001e56:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e5a:	6788                	ld	a0,8(a5)
    80001e5c:	6b8c                	ld	a1,16(a5)
    80001e5e:	6f90                	ld	a2,24(a5)
    80001e60:	01073023          	sd	a6,0(a4)
    80001e64:	e708                	sd	a0,8(a4)
    80001e66:	eb0c                	sd	a1,16(a4)
    80001e68:	ef10                	sd	a2,24(a4)
    80001e6a:	02078793          	addi	a5,a5,32
    80001e6e:	02070713          	addi	a4,a4,32
    80001e72:	fed792e3          	bne	a5,a3,80001e56 <fork+0x58>
  np->tf->a0 = 0;
    80001e76:	060a3783          	ld	a5,96(s4)
    80001e7a:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e7e:	0d8a8493          	addi	s1,s5,216
    80001e82:	0d8a0913          	addi	s2,s4,216
    80001e86:	158a8993          	addi	s3,s5,344
    80001e8a:	a00d                	j	80001eac <fork+0xae>
    freeproc(np);
    80001e8c:	8552                	mv	a0,s4
    80001e8e:	00000097          	auipc	ra,0x0
    80001e92:	e22080e7          	jalr	-478(ra) # 80001cb0 <freeproc>
    release(&np->lock);
    80001e96:	8552                	mv	a0,s4
    80001e98:	fffff097          	auipc	ra,0xfffff
    80001e9c:	cd8080e7          	jalr	-808(ra) # 80000b70 <release>
    return -1;
    80001ea0:	54fd                	li	s1,-1
    80001ea2:	a889                	j	80001ef4 <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
    80001ea4:	04a1                	addi	s1,s1,8
    80001ea6:	0921                	addi	s2,s2,8
    80001ea8:	01348b63          	beq	s1,s3,80001ebe <fork+0xc0>
    if(p->ofile[i])
    80001eac:	6088                	ld	a0,0(s1)
    80001eae:	d97d                	beqz	a0,80001ea4 <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001eb0:	00002097          	auipc	ra,0x2
    80001eb4:	7aa080e7          	jalr	1962(ra) # 8000465a <filedup>
    80001eb8:	00a93023          	sd	a0,0(s2)
    80001ebc:	b7e5                	j	80001ea4 <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001ebe:	158ab503          	ld	a0,344(s5)
    80001ec2:	00002097          	auipc	ra,0x2
    80001ec6:	82e080e7          	jalr	-2002(ra) # 800036f0 <idup>
    80001eca:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ece:	4641                	li	a2,16
    80001ed0:	160a8593          	addi	a1,s5,352
    80001ed4:	160a0513          	addi	a0,s4,352
    80001ed8:	fffff097          	auipc	ra,0xfffff
    80001edc:	fe8080e7          	jalr	-24(ra) # 80000ec0 <safestrcpy>
  pid = np->pid;
    80001ee0:	040a2483          	lw	s1,64(s4)
  np->state = RUNNABLE;
    80001ee4:	4789                	li	a5,2
    80001ee6:	02fa2023          	sw	a5,32(s4)
  release(&np->lock);
    80001eea:	8552                	mv	a0,s4
    80001eec:	fffff097          	auipc	ra,0xfffff
    80001ef0:	c84080e7          	jalr	-892(ra) # 80000b70 <release>
}
    80001ef4:	8526                	mv	a0,s1
    80001ef6:	70e2                	ld	ra,56(sp)
    80001ef8:	7442                	ld	s0,48(sp)
    80001efa:	74a2                	ld	s1,40(sp)
    80001efc:	7902                	ld	s2,32(sp)
    80001efe:	69e2                	ld	s3,24(sp)
    80001f00:	6a42                	ld	s4,16(sp)
    80001f02:	6aa2                	ld	s5,8(sp)
    80001f04:	6121                	addi	sp,sp,64
    80001f06:	8082                	ret
    return -1;
    80001f08:	54fd                	li	s1,-1
    80001f0a:	b7ed                	j	80001ef4 <fork+0xf6>

0000000080001f0c <reparent>:
{
    80001f0c:	7179                	addi	sp,sp,-48
    80001f0e:	f406                	sd	ra,40(sp)
    80001f10:	f022                	sd	s0,32(sp)
    80001f12:	ec26                	sd	s1,24(sp)
    80001f14:	e84a                	sd	s2,16(sp)
    80001f16:	e44e                	sd	s3,8(sp)
    80001f18:	e052                	sd	s4,0(sp)
    80001f1a:	1800                	addi	s0,sp,48
    80001f1c:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f1e:	00014497          	auipc	s1,0x14
    80001f22:	d4248493          	addi	s1,s1,-702 # 80015c60 <proc>
      pp->parent = initproc;
    80001f26:	00027a17          	auipc	s4,0x27
    80001f2a:	452a0a13          	addi	s4,s4,1106 # 80029378 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f2e:	00015997          	auipc	s3,0x15
    80001f32:	b9298993          	addi	s3,s3,-1134 # 80016ac0 <tickslock>
    80001f36:	a029                	j	80001f40 <reparent+0x34>
    80001f38:	17048493          	addi	s1,s1,368
    80001f3c:	03348363          	beq	s1,s3,80001f62 <reparent+0x56>
    if(pp->parent == p){
    80001f40:	749c                	ld	a5,40(s1)
    80001f42:	ff279be3          	bne	a5,s2,80001f38 <reparent+0x2c>
      acquire(&pp->lock);
    80001f46:	8526                	mv	a0,s1
    80001f48:	fffff097          	auipc	ra,0xfffff
    80001f4c:	b58080e7          	jalr	-1192(ra) # 80000aa0 <acquire>
      pp->parent = initproc;
    80001f50:	000a3783          	ld	a5,0(s4)
    80001f54:	f49c                	sd	a5,40(s1)
      release(&pp->lock);
    80001f56:	8526                	mv	a0,s1
    80001f58:	fffff097          	auipc	ra,0xfffff
    80001f5c:	c18080e7          	jalr	-1000(ra) # 80000b70 <release>
    80001f60:	bfe1                	j	80001f38 <reparent+0x2c>
}
    80001f62:	70a2                	ld	ra,40(sp)
    80001f64:	7402                	ld	s0,32(sp)
    80001f66:	64e2                	ld	s1,24(sp)
    80001f68:	6942                	ld	s2,16(sp)
    80001f6a:	69a2                	ld	s3,8(sp)
    80001f6c:	6a02                	ld	s4,0(sp)
    80001f6e:	6145                	addi	sp,sp,48
    80001f70:	8082                	ret

0000000080001f72 <scheduler>:
{
    80001f72:	715d                	addi	sp,sp,-80
    80001f74:	e486                	sd	ra,72(sp)
    80001f76:	e0a2                	sd	s0,64(sp)
    80001f78:	fc26                	sd	s1,56(sp)
    80001f7a:	f84a                	sd	s2,48(sp)
    80001f7c:	f44e                	sd	s3,40(sp)
    80001f7e:	f052                	sd	s4,32(sp)
    80001f80:	ec56                	sd	s5,24(sp)
    80001f82:	e85a                	sd	s6,16(sp)
    80001f84:	e45e                	sd	s7,8(sp)
    80001f86:	e062                	sd	s8,0(sp)
    80001f88:	0880                	addi	s0,sp,80
    80001f8a:	8792                	mv	a5,tp
  int id = r_tp();
    80001f8c:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f8e:	00779b13          	slli	s6,a5,0x7
    80001f92:	00014717          	auipc	a4,0x14
    80001f96:	8ae70713          	addi	a4,a4,-1874 # 80015840 <pid_lock>
    80001f9a:	975a                	add	a4,a4,s6
    80001f9c:	02073023          	sd	zero,32(a4)
        swtch(&c->scheduler, &p->context);
    80001fa0:	00014717          	auipc	a4,0x14
    80001fa4:	8c870713          	addi	a4,a4,-1848 # 80015868 <cpus+0x8>
    80001fa8:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001faa:	4b8d                	li	s7,3
        c->proc = p;
    80001fac:	079e                	slli	a5,a5,0x7
    80001fae:	00014917          	auipc	s2,0x14
    80001fb2:	89290913          	addi	s2,s2,-1902 # 80015840 <pid_lock>
    80001fb6:	993e                	add	s2,s2,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fb8:	00015a17          	auipc	s4,0x15
    80001fbc:	b08a0a13          	addi	s4,s4,-1272 # 80016ac0 <tickslock>
    80001fc0:	a0b9                	j	8000200e <scheduler+0x9c>
      c->intena = 0;
    80001fc2:	08092e23          	sw	zero,156(s2)
      release(&p->lock);
    80001fc6:	8526                	mv	a0,s1
    80001fc8:	fffff097          	auipc	ra,0xfffff
    80001fcc:	ba8080e7          	jalr	-1112(ra) # 80000b70 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fd0:	17048493          	addi	s1,s1,368
    80001fd4:	03448963          	beq	s1,s4,80002006 <scheduler+0x94>
      acquire(&p->lock);
    80001fd8:	8526                	mv	a0,s1
    80001fda:	fffff097          	auipc	ra,0xfffff
    80001fde:	ac6080e7          	jalr	-1338(ra) # 80000aa0 <acquire>
      if(p->state == RUNNABLE) {
    80001fe2:	509c                	lw	a5,32(s1)
    80001fe4:	fd379fe3          	bne	a5,s3,80001fc2 <scheduler+0x50>
        p->state = RUNNING;
    80001fe8:	0374a023          	sw	s7,32(s1)
        c->proc = p;
    80001fec:	02993023          	sd	s1,32(s2)
        swtch(&c->scheduler, &p->context);
    80001ff0:	06848593          	addi	a1,s1,104
    80001ff4:	855a                	mv	a0,s6
    80001ff6:	00000097          	auipc	ra,0x0
    80001ffa:	612080e7          	jalr	1554(ra) # 80002608 <swtch>
        c->proc = 0;
    80001ffe:	02093023          	sd	zero,32(s2)
        found = 1;
    80002002:	8ae2                	mv	s5,s8
    80002004:	bf7d                	j	80001fc2 <scheduler+0x50>
    if(found == 0){
    80002006:	000a9463          	bnez	s5,8000200e <scheduler+0x9c>
      asm volatile("wfi");
    8000200a:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000200e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002012:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002016:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000201a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000201e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002020:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002024:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80002026:	00014497          	auipc	s1,0x14
    8000202a:	c3a48493          	addi	s1,s1,-966 # 80015c60 <proc>
      if(p->state == RUNNABLE) {
    8000202e:	4989                	li	s3,2
        found = 1;
    80002030:	4c05                	li	s8,1
    80002032:	b75d                	j	80001fd8 <scheduler+0x66>

0000000080002034 <sched>:
{
    80002034:	7179                	addi	sp,sp,-48
    80002036:	f406                	sd	ra,40(sp)
    80002038:	f022                	sd	s0,32(sp)
    8000203a:	ec26                	sd	s1,24(sp)
    8000203c:	e84a                	sd	s2,16(sp)
    8000203e:	e44e                	sd	s3,8(sp)
    80002040:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002042:	00000097          	auipc	ra,0x0
    80002046:	a52080e7          	jalr	-1454(ra) # 80001a94 <myproc>
    8000204a:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000204c:	fffff097          	auipc	ra,0xfffff
    80002050:	9d6080e7          	jalr	-1578(ra) # 80000a22 <holding>
    80002054:	c93d                	beqz	a0,800020ca <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002056:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002058:	2781                	sext.w	a5,a5
    8000205a:	079e                	slli	a5,a5,0x7
    8000205c:	00013717          	auipc	a4,0x13
    80002060:	7e470713          	addi	a4,a4,2020 # 80015840 <pid_lock>
    80002064:	97ba                	add	a5,a5,a4
    80002066:	0987a703          	lw	a4,152(a5)
    8000206a:	4785                	li	a5,1
    8000206c:	06f71763          	bne	a4,a5,800020da <sched+0xa6>
  if(p->state == RUNNING)
    80002070:	5098                	lw	a4,32(s1)
    80002072:	478d                	li	a5,3
    80002074:	06f70b63          	beq	a4,a5,800020ea <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002078:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000207c:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000207e:	efb5                	bnez	a5,800020fa <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002080:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002082:	00013917          	auipc	s2,0x13
    80002086:	7be90913          	addi	s2,s2,1982 # 80015840 <pid_lock>
    8000208a:	2781                	sext.w	a5,a5
    8000208c:	079e                	slli	a5,a5,0x7
    8000208e:	97ca                	add	a5,a5,s2
    80002090:	09c7a983          	lw	s3,156(a5)
    80002094:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->scheduler);
    80002096:	2781                	sext.w	a5,a5
    80002098:	079e                	slli	a5,a5,0x7
    8000209a:	00013597          	auipc	a1,0x13
    8000209e:	7ce58593          	addi	a1,a1,1998 # 80015868 <cpus+0x8>
    800020a2:	95be                	add	a1,a1,a5
    800020a4:	06848513          	addi	a0,s1,104
    800020a8:	00000097          	auipc	ra,0x0
    800020ac:	560080e7          	jalr	1376(ra) # 80002608 <swtch>
    800020b0:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020b2:	2781                	sext.w	a5,a5
    800020b4:	079e                	slli	a5,a5,0x7
    800020b6:	97ca                	add	a5,a5,s2
    800020b8:	0937ae23          	sw	s3,156(a5)
}
    800020bc:	70a2                	ld	ra,40(sp)
    800020be:	7402                	ld	s0,32(sp)
    800020c0:	64e2                	ld	s1,24(sp)
    800020c2:	6942                	ld	s2,16(sp)
    800020c4:	69a2                	ld	s3,8(sp)
    800020c6:	6145                	addi	sp,sp,48
    800020c8:	8082                	ret
    panic("sched p->lock");
    800020ca:	00007517          	auipc	a0,0x7
    800020ce:	38e50513          	addi	a0,a0,910 # 80009458 <userret+0x3c8>
    800020d2:	ffffe097          	auipc	ra,0xffffe
    800020d6:	482080e7          	jalr	1154(ra) # 80000554 <panic>
    panic("sched locks");
    800020da:	00007517          	auipc	a0,0x7
    800020de:	38e50513          	addi	a0,a0,910 # 80009468 <userret+0x3d8>
    800020e2:	ffffe097          	auipc	ra,0xffffe
    800020e6:	472080e7          	jalr	1138(ra) # 80000554 <panic>
    panic("sched running");
    800020ea:	00007517          	auipc	a0,0x7
    800020ee:	38e50513          	addi	a0,a0,910 # 80009478 <userret+0x3e8>
    800020f2:	ffffe097          	auipc	ra,0xffffe
    800020f6:	462080e7          	jalr	1122(ra) # 80000554 <panic>
    panic("sched interruptible");
    800020fa:	00007517          	auipc	a0,0x7
    800020fe:	38e50513          	addi	a0,a0,910 # 80009488 <userret+0x3f8>
    80002102:	ffffe097          	auipc	ra,0xffffe
    80002106:	452080e7          	jalr	1106(ra) # 80000554 <panic>

000000008000210a <exit>:
{
    8000210a:	7179                	addi	sp,sp,-48
    8000210c:	f406                	sd	ra,40(sp)
    8000210e:	f022                	sd	s0,32(sp)
    80002110:	ec26                	sd	s1,24(sp)
    80002112:	e84a                	sd	s2,16(sp)
    80002114:	e44e                	sd	s3,8(sp)
    80002116:	e052                	sd	s4,0(sp)
    80002118:	1800                	addi	s0,sp,48
    8000211a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000211c:	00000097          	auipc	ra,0x0
    80002120:	978080e7          	jalr	-1672(ra) # 80001a94 <myproc>
    80002124:	89aa                	mv	s3,a0
  if(p == initproc)
    80002126:	00027797          	auipc	a5,0x27
    8000212a:	2527b783          	ld	a5,594(a5) # 80029378 <initproc>
    8000212e:	0d850493          	addi	s1,a0,216
    80002132:	15850913          	addi	s2,a0,344
    80002136:	02a79363          	bne	a5,a0,8000215c <exit+0x52>
    panic("init exiting");
    8000213a:	00007517          	auipc	a0,0x7
    8000213e:	36650513          	addi	a0,a0,870 # 800094a0 <userret+0x410>
    80002142:	ffffe097          	auipc	ra,0xffffe
    80002146:	412080e7          	jalr	1042(ra) # 80000554 <panic>
      fileclose(f);
    8000214a:	00002097          	auipc	ra,0x2
    8000214e:	562080e7          	jalr	1378(ra) # 800046ac <fileclose>
      p->ofile[fd] = 0;
    80002152:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002156:	04a1                	addi	s1,s1,8
    80002158:	01248563          	beq	s1,s2,80002162 <exit+0x58>
    if(p->ofile[fd]){
    8000215c:	6088                	ld	a0,0(s1)
    8000215e:	f575                	bnez	a0,8000214a <exit+0x40>
    80002160:	bfdd                	j	80002156 <exit+0x4c>
  begin_op(ROOTDEV);
    80002162:	4501                	li	a0,0
    80002164:	00002097          	auipc	ra,0x2
    80002168:	fae080e7          	jalr	-82(ra) # 80004112 <begin_op>
  iput(p->cwd);
    8000216c:	1589b503          	ld	a0,344(s3)
    80002170:	00001097          	auipc	ra,0x1
    80002174:	6cc080e7          	jalr	1740(ra) # 8000383c <iput>
  end_op(ROOTDEV);
    80002178:	4501                	li	a0,0
    8000217a:	00002097          	auipc	ra,0x2
    8000217e:	042080e7          	jalr	66(ra) # 800041bc <end_op>
  p->cwd = 0;
    80002182:	1409bc23          	sd	zero,344(s3)
  acquire(&initproc->lock);
    80002186:	00027497          	auipc	s1,0x27
    8000218a:	1f248493          	addi	s1,s1,498 # 80029378 <initproc>
    8000218e:	6088                	ld	a0,0(s1)
    80002190:	fffff097          	auipc	ra,0xfffff
    80002194:	910080e7          	jalr	-1776(ra) # 80000aa0 <acquire>
  wakeup1(initproc);
    80002198:	6088                	ld	a0,0(s1)
    8000219a:	fffff097          	auipc	ra,0xfffff
    8000219e:	7ba080e7          	jalr	1978(ra) # 80001954 <wakeup1>
  release(&initproc->lock);
    800021a2:	6088                	ld	a0,0(s1)
    800021a4:	fffff097          	auipc	ra,0xfffff
    800021a8:	9cc080e7          	jalr	-1588(ra) # 80000b70 <release>
  acquire(&p->lock);
    800021ac:	854e                	mv	a0,s3
    800021ae:	fffff097          	auipc	ra,0xfffff
    800021b2:	8f2080e7          	jalr	-1806(ra) # 80000aa0 <acquire>
  struct proc *original_parent = p->parent;
    800021b6:	0289b483          	ld	s1,40(s3)
  release(&p->lock);
    800021ba:	854e                	mv	a0,s3
    800021bc:	fffff097          	auipc	ra,0xfffff
    800021c0:	9b4080e7          	jalr	-1612(ra) # 80000b70 <release>
  acquire(&original_parent->lock);
    800021c4:	8526                	mv	a0,s1
    800021c6:	fffff097          	auipc	ra,0xfffff
    800021ca:	8da080e7          	jalr	-1830(ra) # 80000aa0 <acquire>
  acquire(&p->lock);
    800021ce:	854e                	mv	a0,s3
    800021d0:	fffff097          	auipc	ra,0xfffff
    800021d4:	8d0080e7          	jalr	-1840(ra) # 80000aa0 <acquire>
  reparent(p);
    800021d8:	854e                	mv	a0,s3
    800021da:	00000097          	auipc	ra,0x0
    800021de:	d32080e7          	jalr	-718(ra) # 80001f0c <reparent>
  wakeup1(original_parent);
    800021e2:	8526                	mv	a0,s1
    800021e4:	fffff097          	auipc	ra,0xfffff
    800021e8:	770080e7          	jalr	1904(ra) # 80001954 <wakeup1>
  p->xstate = status;
    800021ec:	0349ae23          	sw	s4,60(s3)
  p->state = ZOMBIE;
    800021f0:	4791                	li	a5,4
    800021f2:	02f9a023          	sw	a5,32(s3)
  release(&original_parent->lock);
    800021f6:	8526                	mv	a0,s1
    800021f8:	fffff097          	auipc	ra,0xfffff
    800021fc:	978080e7          	jalr	-1672(ra) # 80000b70 <release>
  sched();
    80002200:	00000097          	auipc	ra,0x0
    80002204:	e34080e7          	jalr	-460(ra) # 80002034 <sched>
  panic("zombie exit");
    80002208:	00007517          	auipc	a0,0x7
    8000220c:	2a850513          	addi	a0,a0,680 # 800094b0 <userret+0x420>
    80002210:	ffffe097          	auipc	ra,0xffffe
    80002214:	344080e7          	jalr	836(ra) # 80000554 <panic>

0000000080002218 <yield>:
{
    80002218:	1101                	addi	sp,sp,-32
    8000221a:	ec06                	sd	ra,24(sp)
    8000221c:	e822                	sd	s0,16(sp)
    8000221e:	e426                	sd	s1,8(sp)
    80002220:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002222:	00000097          	auipc	ra,0x0
    80002226:	872080e7          	jalr	-1934(ra) # 80001a94 <myproc>
    8000222a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000222c:	fffff097          	auipc	ra,0xfffff
    80002230:	874080e7          	jalr	-1932(ra) # 80000aa0 <acquire>
  p->state = RUNNABLE;
    80002234:	4789                	li	a5,2
    80002236:	d09c                	sw	a5,32(s1)
  sched();
    80002238:	00000097          	auipc	ra,0x0
    8000223c:	dfc080e7          	jalr	-516(ra) # 80002034 <sched>
  release(&p->lock);
    80002240:	8526                	mv	a0,s1
    80002242:	fffff097          	auipc	ra,0xfffff
    80002246:	92e080e7          	jalr	-1746(ra) # 80000b70 <release>
}
    8000224a:	60e2                	ld	ra,24(sp)
    8000224c:	6442                	ld	s0,16(sp)
    8000224e:	64a2                	ld	s1,8(sp)
    80002250:	6105                	addi	sp,sp,32
    80002252:	8082                	ret

0000000080002254 <sleep>:
{
    80002254:	7179                	addi	sp,sp,-48
    80002256:	f406                	sd	ra,40(sp)
    80002258:	f022                	sd	s0,32(sp)
    8000225a:	ec26                	sd	s1,24(sp)
    8000225c:	e84a                	sd	s2,16(sp)
    8000225e:	e44e                	sd	s3,8(sp)
    80002260:	1800                	addi	s0,sp,48
    80002262:	89aa                	mv	s3,a0
    80002264:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002266:	00000097          	auipc	ra,0x0
    8000226a:	82e080e7          	jalr	-2002(ra) # 80001a94 <myproc>
    8000226e:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002270:	05250663          	beq	a0,s2,800022bc <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002274:	fffff097          	auipc	ra,0xfffff
    80002278:	82c080e7          	jalr	-2004(ra) # 80000aa0 <acquire>
    release(lk);
    8000227c:	854a                	mv	a0,s2
    8000227e:	fffff097          	auipc	ra,0xfffff
    80002282:	8f2080e7          	jalr	-1806(ra) # 80000b70 <release>
  p->chan = chan;
    80002286:	0334b823          	sd	s3,48(s1)
  p->state = SLEEPING;
    8000228a:	4785                	li	a5,1
    8000228c:	d09c                	sw	a5,32(s1)
  sched();
    8000228e:	00000097          	auipc	ra,0x0
    80002292:	da6080e7          	jalr	-602(ra) # 80002034 <sched>
  p->chan = 0;
    80002296:	0204b823          	sd	zero,48(s1)
    release(&p->lock);
    8000229a:	8526                	mv	a0,s1
    8000229c:	fffff097          	auipc	ra,0xfffff
    800022a0:	8d4080e7          	jalr	-1836(ra) # 80000b70 <release>
    acquire(lk);
    800022a4:	854a                	mv	a0,s2
    800022a6:	ffffe097          	auipc	ra,0xffffe
    800022aa:	7fa080e7          	jalr	2042(ra) # 80000aa0 <acquire>
}
    800022ae:	70a2                	ld	ra,40(sp)
    800022b0:	7402                	ld	s0,32(sp)
    800022b2:	64e2                	ld	s1,24(sp)
    800022b4:	6942                	ld	s2,16(sp)
    800022b6:	69a2                	ld	s3,8(sp)
    800022b8:	6145                	addi	sp,sp,48
    800022ba:	8082                	ret
  p->chan = chan;
    800022bc:	03353823          	sd	s3,48(a0)
  p->state = SLEEPING;
    800022c0:	4785                	li	a5,1
    800022c2:	d11c                	sw	a5,32(a0)
  sched();
    800022c4:	00000097          	auipc	ra,0x0
    800022c8:	d70080e7          	jalr	-656(ra) # 80002034 <sched>
  p->chan = 0;
    800022cc:	0204b823          	sd	zero,48(s1)
  if(lk != &p->lock){
    800022d0:	bff9                	j	800022ae <sleep+0x5a>

00000000800022d2 <wait>:
{
    800022d2:	715d                	addi	sp,sp,-80
    800022d4:	e486                	sd	ra,72(sp)
    800022d6:	e0a2                	sd	s0,64(sp)
    800022d8:	fc26                	sd	s1,56(sp)
    800022da:	f84a                	sd	s2,48(sp)
    800022dc:	f44e                	sd	s3,40(sp)
    800022de:	f052                	sd	s4,32(sp)
    800022e0:	ec56                	sd	s5,24(sp)
    800022e2:	e85a                	sd	s6,16(sp)
    800022e4:	e45e                	sd	s7,8(sp)
    800022e6:	0880                	addi	s0,sp,80
    800022e8:	8aaa                	mv	s5,a0
  struct proc *p = myproc();
    800022ea:	fffff097          	auipc	ra,0xfffff
    800022ee:	7aa080e7          	jalr	1962(ra) # 80001a94 <myproc>
    800022f2:	892a                	mv	s2,a0
  acquire(&p->lock);
    800022f4:	ffffe097          	auipc	ra,0xffffe
    800022f8:	7ac080e7          	jalr	1964(ra) # 80000aa0 <acquire>
    havekids = 0;
    800022fc:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800022fe:	4a11                	li	s4,4
        havekids = 1;
    80002300:	4b05                	li	s6,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002302:	00014997          	auipc	s3,0x14
    80002306:	7be98993          	addi	s3,s3,1982 # 80016ac0 <tickslock>
    havekids = 0;
    8000230a:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    8000230c:	00014497          	auipc	s1,0x14
    80002310:	95448493          	addi	s1,s1,-1708 # 80015c60 <proc>
    80002314:	a08d                	j	80002376 <wait+0xa4>
          pid = np->pid;
    80002316:	0404a983          	lw	s3,64(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000231a:	000a8e63          	beqz	s5,80002336 <wait+0x64>
    8000231e:	4691                	li	a3,4
    80002320:	03c48613          	addi	a2,s1,60
    80002324:	85d6                	mv	a1,s5
    80002326:	05893503          	ld	a0,88(s2)
    8000232a:	fffff097          	auipc	ra,0xfffff
    8000232e:	45c080e7          	jalr	1116(ra) # 80001786 <copyout>
    80002332:	02054263          	bltz	a0,80002356 <wait+0x84>
          freeproc(np);
    80002336:	8526                	mv	a0,s1
    80002338:	00000097          	auipc	ra,0x0
    8000233c:	978080e7          	jalr	-1672(ra) # 80001cb0 <freeproc>
          release(&np->lock);
    80002340:	8526                	mv	a0,s1
    80002342:	fffff097          	auipc	ra,0xfffff
    80002346:	82e080e7          	jalr	-2002(ra) # 80000b70 <release>
          release(&p->lock);
    8000234a:	854a                	mv	a0,s2
    8000234c:	fffff097          	auipc	ra,0xfffff
    80002350:	824080e7          	jalr	-2012(ra) # 80000b70 <release>
          return pid;
    80002354:	a8a9                	j	800023ae <wait+0xdc>
            release(&np->lock);
    80002356:	8526                	mv	a0,s1
    80002358:	fffff097          	auipc	ra,0xfffff
    8000235c:	818080e7          	jalr	-2024(ra) # 80000b70 <release>
            release(&p->lock);
    80002360:	854a                	mv	a0,s2
    80002362:	fffff097          	auipc	ra,0xfffff
    80002366:	80e080e7          	jalr	-2034(ra) # 80000b70 <release>
            return -1;
    8000236a:	59fd                	li	s3,-1
    8000236c:	a089                	j	800023ae <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    8000236e:	17048493          	addi	s1,s1,368
    80002372:	03348463          	beq	s1,s3,8000239a <wait+0xc8>
      if(np->parent == p){
    80002376:	749c                	ld	a5,40(s1)
    80002378:	ff279be3          	bne	a5,s2,8000236e <wait+0x9c>
        acquire(&np->lock);
    8000237c:	8526                	mv	a0,s1
    8000237e:	ffffe097          	auipc	ra,0xffffe
    80002382:	722080e7          	jalr	1826(ra) # 80000aa0 <acquire>
        if(np->state == ZOMBIE){
    80002386:	509c                	lw	a5,32(s1)
    80002388:	f94787e3          	beq	a5,s4,80002316 <wait+0x44>
        release(&np->lock);
    8000238c:	8526                	mv	a0,s1
    8000238e:	ffffe097          	auipc	ra,0xffffe
    80002392:	7e2080e7          	jalr	2018(ra) # 80000b70 <release>
        havekids = 1;
    80002396:	875a                	mv	a4,s6
    80002398:	bfd9                	j	8000236e <wait+0x9c>
    if(!havekids || p->killed){
    8000239a:	c701                	beqz	a4,800023a2 <wait+0xd0>
    8000239c:	03892783          	lw	a5,56(s2)
    800023a0:	c39d                	beqz	a5,800023c6 <wait+0xf4>
      release(&p->lock);
    800023a2:	854a                	mv	a0,s2
    800023a4:	ffffe097          	auipc	ra,0xffffe
    800023a8:	7cc080e7          	jalr	1996(ra) # 80000b70 <release>
      return -1;
    800023ac:	59fd                	li	s3,-1
}
    800023ae:	854e                	mv	a0,s3
    800023b0:	60a6                	ld	ra,72(sp)
    800023b2:	6406                	ld	s0,64(sp)
    800023b4:	74e2                	ld	s1,56(sp)
    800023b6:	7942                	ld	s2,48(sp)
    800023b8:	79a2                	ld	s3,40(sp)
    800023ba:	7a02                	ld	s4,32(sp)
    800023bc:	6ae2                	ld	s5,24(sp)
    800023be:	6b42                	ld	s6,16(sp)
    800023c0:	6ba2                	ld	s7,8(sp)
    800023c2:	6161                	addi	sp,sp,80
    800023c4:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800023c6:	85ca                	mv	a1,s2
    800023c8:	854a                	mv	a0,s2
    800023ca:	00000097          	auipc	ra,0x0
    800023ce:	e8a080e7          	jalr	-374(ra) # 80002254 <sleep>
    havekids = 0;
    800023d2:	bf25                	j	8000230a <wait+0x38>

00000000800023d4 <wakeup>:
{
    800023d4:	7139                	addi	sp,sp,-64
    800023d6:	fc06                	sd	ra,56(sp)
    800023d8:	f822                	sd	s0,48(sp)
    800023da:	f426                	sd	s1,40(sp)
    800023dc:	f04a                	sd	s2,32(sp)
    800023de:	ec4e                	sd	s3,24(sp)
    800023e0:	e852                	sd	s4,16(sp)
    800023e2:	e456                	sd	s5,8(sp)
    800023e4:	0080                	addi	s0,sp,64
    800023e6:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800023e8:	00014497          	auipc	s1,0x14
    800023ec:	87848493          	addi	s1,s1,-1928 # 80015c60 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800023f0:	4985                	li	s3,1
      p->state = RUNNABLE;
    800023f2:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800023f4:	00014917          	auipc	s2,0x14
    800023f8:	6cc90913          	addi	s2,s2,1740 # 80016ac0 <tickslock>
    800023fc:	a811                	j	80002410 <wakeup+0x3c>
    release(&p->lock);
    800023fe:	8526                	mv	a0,s1
    80002400:	ffffe097          	auipc	ra,0xffffe
    80002404:	770080e7          	jalr	1904(ra) # 80000b70 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002408:	17048493          	addi	s1,s1,368
    8000240c:	03248063          	beq	s1,s2,8000242c <wakeup+0x58>
    acquire(&p->lock);
    80002410:	8526                	mv	a0,s1
    80002412:	ffffe097          	auipc	ra,0xffffe
    80002416:	68e080e7          	jalr	1678(ra) # 80000aa0 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    8000241a:	509c                	lw	a5,32(s1)
    8000241c:	ff3791e3          	bne	a5,s3,800023fe <wakeup+0x2a>
    80002420:	789c                	ld	a5,48(s1)
    80002422:	fd479ee3          	bne	a5,s4,800023fe <wakeup+0x2a>
      p->state = RUNNABLE;
    80002426:	0354a023          	sw	s5,32(s1)
    8000242a:	bfd1                	j	800023fe <wakeup+0x2a>
}
    8000242c:	70e2                	ld	ra,56(sp)
    8000242e:	7442                	ld	s0,48(sp)
    80002430:	74a2                	ld	s1,40(sp)
    80002432:	7902                	ld	s2,32(sp)
    80002434:	69e2                	ld	s3,24(sp)
    80002436:	6a42                	ld	s4,16(sp)
    80002438:	6aa2                	ld	s5,8(sp)
    8000243a:	6121                	addi	sp,sp,64
    8000243c:	8082                	ret

000000008000243e <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000243e:	7179                	addi	sp,sp,-48
    80002440:	f406                	sd	ra,40(sp)
    80002442:	f022                	sd	s0,32(sp)
    80002444:	ec26                	sd	s1,24(sp)
    80002446:	e84a                	sd	s2,16(sp)
    80002448:	e44e                	sd	s3,8(sp)
    8000244a:	1800                	addi	s0,sp,48
    8000244c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000244e:	00014497          	auipc	s1,0x14
    80002452:	81248493          	addi	s1,s1,-2030 # 80015c60 <proc>
    80002456:	00014997          	auipc	s3,0x14
    8000245a:	66a98993          	addi	s3,s3,1642 # 80016ac0 <tickslock>
    acquire(&p->lock);
    8000245e:	8526                	mv	a0,s1
    80002460:	ffffe097          	auipc	ra,0xffffe
    80002464:	640080e7          	jalr	1600(ra) # 80000aa0 <acquire>
    if(p->pid == pid){
    80002468:	40bc                	lw	a5,64(s1)
    8000246a:	03278363          	beq	a5,s2,80002490 <kill+0x52>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000246e:	8526                	mv	a0,s1
    80002470:	ffffe097          	auipc	ra,0xffffe
    80002474:	700080e7          	jalr	1792(ra) # 80000b70 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002478:	17048493          	addi	s1,s1,368
    8000247c:	ff3491e3          	bne	s1,s3,8000245e <kill+0x20>
  }
  return -1;
    80002480:	557d                	li	a0,-1
}
    80002482:	70a2                	ld	ra,40(sp)
    80002484:	7402                	ld	s0,32(sp)
    80002486:	64e2                	ld	s1,24(sp)
    80002488:	6942                	ld	s2,16(sp)
    8000248a:	69a2                	ld	s3,8(sp)
    8000248c:	6145                	addi	sp,sp,48
    8000248e:	8082                	ret
      p->killed = 1;
    80002490:	4785                	li	a5,1
    80002492:	dc9c                	sw	a5,56(s1)
      if(p->state == SLEEPING){
    80002494:	5098                	lw	a4,32(s1)
    80002496:	00f70963          	beq	a4,a5,800024a8 <kill+0x6a>
      release(&p->lock);
    8000249a:	8526                	mv	a0,s1
    8000249c:	ffffe097          	auipc	ra,0xffffe
    800024a0:	6d4080e7          	jalr	1748(ra) # 80000b70 <release>
      return 0;
    800024a4:	4501                	li	a0,0
    800024a6:	bff1                	j	80002482 <kill+0x44>
        p->state = RUNNABLE;
    800024a8:	4789                	li	a5,2
    800024aa:	d09c                	sw	a5,32(s1)
    800024ac:	b7fd                	j	8000249a <kill+0x5c>

00000000800024ae <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024ae:	7179                	addi	sp,sp,-48
    800024b0:	f406                	sd	ra,40(sp)
    800024b2:	f022                	sd	s0,32(sp)
    800024b4:	ec26                	sd	s1,24(sp)
    800024b6:	e84a                	sd	s2,16(sp)
    800024b8:	e44e                	sd	s3,8(sp)
    800024ba:	e052                	sd	s4,0(sp)
    800024bc:	1800                	addi	s0,sp,48
    800024be:	84aa                	mv	s1,a0
    800024c0:	892e                	mv	s2,a1
    800024c2:	89b2                	mv	s3,a2
    800024c4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024c6:	fffff097          	auipc	ra,0xfffff
    800024ca:	5ce080e7          	jalr	1486(ra) # 80001a94 <myproc>
  if(user_dst){
    800024ce:	c08d                	beqz	s1,800024f0 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024d0:	86d2                	mv	a3,s4
    800024d2:	864e                	mv	a2,s3
    800024d4:	85ca                	mv	a1,s2
    800024d6:	6d28                	ld	a0,88(a0)
    800024d8:	fffff097          	auipc	ra,0xfffff
    800024dc:	2ae080e7          	jalr	686(ra) # 80001786 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024e0:	70a2                	ld	ra,40(sp)
    800024e2:	7402                	ld	s0,32(sp)
    800024e4:	64e2                	ld	s1,24(sp)
    800024e6:	6942                	ld	s2,16(sp)
    800024e8:	69a2                	ld	s3,8(sp)
    800024ea:	6a02                	ld	s4,0(sp)
    800024ec:	6145                	addi	sp,sp,48
    800024ee:	8082                	ret
    memmove((char *)dst, src, len);
    800024f0:	000a061b          	sext.w	a2,s4
    800024f4:	85ce                	mv	a1,s3
    800024f6:	854a                	mv	a0,s2
    800024f8:	fffff097          	auipc	ra,0xfffff
    800024fc:	8d2080e7          	jalr	-1838(ra) # 80000dca <memmove>
    return 0;
    80002500:	8526                	mv	a0,s1
    80002502:	bff9                	j	800024e0 <either_copyout+0x32>

0000000080002504 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002504:	7179                	addi	sp,sp,-48
    80002506:	f406                	sd	ra,40(sp)
    80002508:	f022                	sd	s0,32(sp)
    8000250a:	ec26                	sd	s1,24(sp)
    8000250c:	e84a                	sd	s2,16(sp)
    8000250e:	e44e                	sd	s3,8(sp)
    80002510:	e052                	sd	s4,0(sp)
    80002512:	1800                	addi	s0,sp,48
    80002514:	892a                	mv	s2,a0
    80002516:	84ae                	mv	s1,a1
    80002518:	89b2                	mv	s3,a2
    8000251a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000251c:	fffff097          	auipc	ra,0xfffff
    80002520:	578080e7          	jalr	1400(ra) # 80001a94 <myproc>
  if(user_src){
    80002524:	c08d                	beqz	s1,80002546 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002526:	86d2                	mv	a3,s4
    80002528:	864e                	mv	a2,s3
    8000252a:	85ca                	mv	a1,s2
    8000252c:	6d28                	ld	a0,88(a0)
    8000252e:	fffff097          	auipc	ra,0xfffff
    80002532:	2e4080e7          	jalr	740(ra) # 80001812 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002536:	70a2                	ld	ra,40(sp)
    80002538:	7402                	ld	s0,32(sp)
    8000253a:	64e2                	ld	s1,24(sp)
    8000253c:	6942                	ld	s2,16(sp)
    8000253e:	69a2                	ld	s3,8(sp)
    80002540:	6a02                	ld	s4,0(sp)
    80002542:	6145                	addi	sp,sp,48
    80002544:	8082                	ret
    memmove(dst, (char*)src, len);
    80002546:	000a061b          	sext.w	a2,s4
    8000254a:	85ce                	mv	a1,s3
    8000254c:	854a                	mv	a0,s2
    8000254e:	fffff097          	auipc	ra,0xfffff
    80002552:	87c080e7          	jalr	-1924(ra) # 80000dca <memmove>
    return 0;
    80002556:	8526                	mv	a0,s1
    80002558:	bff9                	j	80002536 <either_copyin+0x32>

000000008000255a <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000255a:	715d                	addi	sp,sp,-80
    8000255c:	e486                	sd	ra,72(sp)
    8000255e:	e0a2                	sd	s0,64(sp)
    80002560:	fc26                	sd	s1,56(sp)
    80002562:	f84a                	sd	s2,48(sp)
    80002564:	f44e                	sd	s3,40(sp)
    80002566:	f052                	sd	s4,32(sp)
    80002568:	ec56                	sd	s5,24(sp)
    8000256a:	e85a                	sd	s6,16(sp)
    8000256c:	e45e                	sd	s7,8(sp)
    8000256e:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002570:	00007517          	auipc	a0,0x7
    80002574:	d2050513          	addi	a0,a0,-736 # 80009290 <userret+0x200>
    80002578:	ffffe097          	auipc	ra,0xffffe
    8000257c:	036080e7          	jalr	54(ra) # 800005ae <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002580:	00014497          	auipc	s1,0x14
    80002584:	84048493          	addi	s1,s1,-1984 # 80015dc0 <proc+0x160>
    80002588:	00014917          	auipc	s2,0x14
    8000258c:	69890913          	addi	s2,s2,1688 # 80016c20 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002590:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80002592:	00007997          	auipc	s3,0x7
    80002596:	f2e98993          	addi	s3,s3,-210 # 800094c0 <userret+0x430>
    printf("%d %s %s", p->pid, state, p->name);
    8000259a:	00007a97          	auipc	s5,0x7
    8000259e:	f2ea8a93          	addi	s5,s5,-210 # 800094c8 <userret+0x438>
    printf("\n");
    800025a2:	00007a17          	auipc	s4,0x7
    800025a6:	ceea0a13          	addi	s4,s4,-786 # 80009290 <userret+0x200>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025aa:	00007b97          	auipc	s7,0x7
    800025ae:	7ceb8b93          	addi	s7,s7,1998 # 80009d78 <states.0>
    800025b2:	a00d                	j	800025d4 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025b4:	ee06a583          	lw	a1,-288(a3)
    800025b8:	8556                	mv	a0,s5
    800025ba:	ffffe097          	auipc	ra,0xffffe
    800025be:	ff4080e7          	jalr	-12(ra) # 800005ae <printf>
    printf("\n");
    800025c2:	8552                	mv	a0,s4
    800025c4:	ffffe097          	auipc	ra,0xffffe
    800025c8:	fea080e7          	jalr	-22(ra) # 800005ae <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025cc:	17048493          	addi	s1,s1,368
    800025d0:	03248163          	beq	s1,s2,800025f2 <procdump+0x98>
    if(p->state == UNUSED)
    800025d4:	86a6                	mv	a3,s1
    800025d6:	ec04a783          	lw	a5,-320(s1)
    800025da:	dbed                	beqz	a5,800025cc <procdump+0x72>
      state = "???";
    800025dc:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025de:	fcfb6be3          	bltu	s6,a5,800025b4 <procdump+0x5a>
    800025e2:	1782                	slli	a5,a5,0x20
    800025e4:	9381                	srli	a5,a5,0x20
    800025e6:	078e                	slli	a5,a5,0x3
    800025e8:	97de                	add	a5,a5,s7
    800025ea:	6390                	ld	a2,0(a5)
    800025ec:	f661                	bnez	a2,800025b4 <procdump+0x5a>
      state = "???";
    800025ee:	864e                	mv	a2,s3
    800025f0:	b7d1                	j	800025b4 <procdump+0x5a>
  }
}
    800025f2:	60a6                	ld	ra,72(sp)
    800025f4:	6406                	ld	s0,64(sp)
    800025f6:	74e2                	ld	s1,56(sp)
    800025f8:	7942                	ld	s2,48(sp)
    800025fa:	79a2                	ld	s3,40(sp)
    800025fc:	7a02                	ld	s4,32(sp)
    800025fe:	6ae2                	ld	s5,24(sp)
    80002600:	6b42                	ld	s6,16(sp)
    80002602:	6ba2                	ld	s7,8(sp)
    80002604:	6161                	addi	sp,sp,80
    80002606:	8082                	ret

0000000080002608 <swtch>:
    80002608:	00153023          	sd	ra,0(a0)
    8000260c:	00253423          	sd	sp,8(a0)
    80002610:	e900                	sd	s0,16(a0)
    80002612:	ed04                	sd	s1,24(a0)
    80002614:	03253023          	sd	s2,32(a0)
    80002618:	03353423          	sd	s3,40(a0)
    8000261c:	03453823          	sd	s4,48(a0)
    80002620:	03553c23          	sd	s5,56(a0)
    80002624:	05653023          	sd	s6,64(a0)
    80002628:	05753423          	sd	s7,72(a0)
    8000262c:	05853823          	sd	s8,80(a0)
    80002630:	05953c23          	sd	s9,88(a0)
    80002634:	07a53023          	sd	s10,96(a0)
    80002638:	07b53423          	sd	s11,104(a0)
    8000263c:	0005b083          	ld	ra,0(a1)
    80002640:	0085b103          	ld	sp,8(a1)
    80002644:	6980                	ld	s0,16(a1)
    80002646:	6d84                	ld	s1,24(a1)
    80002648:	0205b903          	ld	s2,32(a1)
    8000264c:	0285b983          	ld	s3,40(a1)
    80002650:	0305ba03          	ld	s4,48(a1)
    80002654:	0385ba83          	ld	s5,56(a1)
    80002658:	0405bb03          	ld	s6,64(a1)
    8000265c:	0485bb83          	ld	s7,72(a1)
    80002660:	0505bc03          	ld	s8,80(a1)
    80002664:	0585bc83          	ld	s9,88(a1)
    80002668:	0605bd03          	ld	s10,96(a1)
    8000266c:	0685bd83          	ld	s11,104(a1)
    80002670:	8082                	ret

0000000080002672 <scause_desc>:
  }
}

static const char *
scause_desc(uint64 stval)
{
    80002672:	1141                	addi	sp,sp,-16
    80002674:	e422                	sd	s0,8(sp)
    80002676:	0800                	addi	s0,sp,16
    80002678:	87aa                	mv	a5,a0
    [13] "load page fault",
    [14] "<reserved for future standard use>",
    [15] "store/AMO page fault",
  };
  uint64 interrupt = stval & 0x8000000000000000L;
  uint64 code = stval & ~0x8000000000000000L;
    8000267a:	00151713          	slli	a4,a0,0x1
    8000267e:	8305                	srli	a4,a4,0x1
  if (interrupt) {
    80002680:	04054c63          	bltz	a0,800026d8 <scause_desc+0x66>
      return intr_desc[code];
    } else {
      return "<reserved for platform use>";
    }
  } else {
    if (code < NELEM(nointr_desc)) {
    80002684:	5685                	li	a3,-31
    80002686:	8285                	srli	a3,a3,0x1
    80002688:	8ee9                	and	a3,a3,a0
    8000268a:	caad                	beqz	a3,800026fc <scause_desc+0x8a>
      return nointr_desc[code];
    } else if (code <= 23) {
    8000268c:	46dd                	li	a3,23
      return "<reserved for future standard use>";
    8000268e:	00007517          	auipc	a0,0x7
    80002692:	e7250513          	addi	a0,a0,-398 # 80009500 <userret+0x470>
    } else if (code <= 23) {
    80002696:	06e6f063          	bgeu	a3,a4,800026f6 <scause_desc+0x84>
    } else if (code <= 31) {
    8000269a:	fc100693          	li	a3,-63
    8000269e:	8285                	srli	a3,a3,0x1
    800026a0:	8efd                	and	a3,a3,a5
      return "<reserved for custom use>";
    800026a2:	00007517          	auipc	a0,0x7
    800026a6:	e8650513          	addi	a0,a0,-378 # 80009528 <userret+0x498>
    } else if (code <= 31) {
    800026aa:	c6b1                	beqz	a3,800026f6 <scause_desc+0x84>
    } else if (code <= 47) {
    800026ac:	02f00693          	li	a3,47
      return "<reserved for future standard use>";
    800026b0:	00007517          	auipc	a0,0x7
    800026b4:	e5050513          	addi	a0,a0,-432 # 80009500 <userret+0x470>
    } else if (code <= 47) {
    800026b8:	02e6ff63          	bgeu	a3,a4,800026f6 <scause_desc+0x84>
    } else if (code <= 63) {
    800026bc:	f8100513          	li	a0,-127
    800026c0:	8105                	srli	a0,a0,0x1
    800026c2:	8fe9                	and	a5,a5,a0
      return "<reserved for custom use>";
    800026c4:	00007517          	auipc	a0,0x7
    800026c8:	e6450513          	addi	a0,a0,-412 # 80009528 <userret+0x498>
    } else if (code <= 63) {
    800026cc:	c78d                	beqz	a5,800026f6 <scause_desc+0x84>
    } else {
      return "<reserved for future standard use>";
    800026ce:	00007517          	auipc	a0,0x7
    800026d2:	e3250513          	addi	a0,a0,-462 # 80009500 <userret+0x470>
    800026d6:	a005                	j	800026f6 <scause_desc+0x84>
    if (code < NELEM(intr_desc)) {
    800026d8:	5505                	li	a0,-31
    800026da:	8105                	srli	a0,a0,0x1
    800026dc:	8fe9                	and	a5,a5,a0
      return "<reserved for platform use>";
    800026de:	00007517          	auipc	a0,0x7
    800026e2:	e6a50513          	addi	a0,a0,-406 # 80009548 <userret+0x4b8>
    if (code < NELEM(intr_desc)) {
    800026e6:	eb81                	bnez	a5,800026f6 <scause_desc+0x84>
      return intr_desc[code];
    800026e8:	070e                	slli	a4,a4,0x3
    800026ea:	00007797          	auipc	a5,0x7
    800026ee:	6b678793          	addi	a5,a5,1718 # 80009da0 <intr_desc.1>
    800026f2:	973e                	add	a4,a4,a5
    800026f4:	6308                	ld	a0,0(a4)
    }
  }
}
    800026f6:	6422                	ld	s0,8(sp)
    800026f8:	0141                	addi	sp,sp,16
    800026fa:	8082                	ret
      return nointr_desc[code];
    800026fc:	070e                	slli	a4,a4,0x3
    800026fe:	00007797          	auipc	a5,0x7
    80002702:	6a278793          	addi	a5,a5,1698 # 80009da0 <intr_desc.1>
    80002706:	973e                	add	a4,a4,a5
    80002708:	6348                	ld	a0,128(a4)
    8000270a:	b7f5                	j	800026f6 <scause_desc+0x84>

000000008000270c <trapinit>:
{
    8000270c:	1141                	addi	sp,sp,-16
    8000270e:	e406                	sd	ra,8(sp)
    80002710:	e022                	sd	s0,0(sp)
    80002712:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002714:	00007597          	auipc	a1,0x7
    80002718:	e5458593          	addi	a1,a1,-428 # 80009568 <userret+0x4d8>
    8000271c:	00014517          	auipc	a0,0x14
    80002720:	3a450513          	addi	a0,a0,932 # 80016ac0 <tickslock>
    80002724:	ffffe097          	auipc	ra,0xffffe
    80002728:	2a8080e7          	jalr	680(ra) # 800009cc <initlock>
}
    8000272c:	60a2                	ld	ra,8(sp)
    8000272e:	6402                	ld	s0,0(sp)
    80002730:	0141                	addi	sp,sp,16
    80002732:	8082                	ret

0000000080002734 <trapinithart>:
{
    80002734:	1141                	addi	sp,sp,-16
    80002736:	e422                	sd	s0,8(sp)
    80002738:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000273a:	00003797          	auipc	a5,0x3
    8000273e:	6d678793          	addi	a5,a5,1750 # 80005e10 <kernelvec>
    80002742:	10579073          	csrw	stvec,a5
}
    80002746:	6422                	ld	s0,8(sp)
    80002748:	0141                	addi	sp,sp,16
    8000274a:	8082                	ret

000000008000274c <usertrapret>:
{
    8000274c:	1141                	addi	sp,sp,-16
    8000274e:	e406                	sd	ra,8(sp)
    80002750:	e022                	sd	s0,0(sp)
    80002752:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002754:	fffff097          	auipc	ra,0xfffff
    80002758:	340080e7          	jalr	832(ra) # 80001a94 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000275c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002760:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002762:	10079073          	csrw	sstatus,a5
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002766:	00007617          	auipc	a2,0x7
    8000276a:	89a60613          	addi	a2,a2,-1894 # 80009000 <trampoline>
    8000276e:	00007697          	auipc	a3,0x7
    80002772:	89268693          	addi	a3,a3,-1902 # 80009000 <trampoline>
    80002776:	8e91                	sub	a3,a3,a2
    80002778:	040007b7          	lui	a5,0x4000
    8000277c:	17fd                	addi	a5,a5,-1
    8000277e:	07b2                	slli	a5,a5,0xc
    80002780:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002782:	10569073          	csrw	stvec,a3
  p->tf->kernel_satp = r_satp();         // kernel page table
    80002786:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002788:	180026f3          	csrr	a3,satp
    8000278c:	e314                	sd	a3,0(a4)
  p->tf->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000278e:	7138                	ld	a4,96(a0)
    80002790:	6534                	ld	a3,72(a0)
    80002792:	6585                	lui	a1,0x1
    80002794:	96ae                	add	a3,a3,a1
    80002796:	e714                	sd	a3,8(a4)
  p->tf->kernel_trap = (uint64)usertrap;
    80002798:	7138                	ld	a4,96(a0)
    8000279a:	00000697          	auipc	a3,0x0
    8000279e:	13e68693          	addi	a3,a3,318 # 800028d8 <usertrap>
    800027a2:	eb14                	sd	a3,16(a4)
  p->tf->kernel_hartid = r_tp();         // hartid for cpuid()
    800027a4:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800027a6:	8692                	mv	a3,tp
    800027a8:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027aa:	100026f3          	csrr	a3,sstatus
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800027ae:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800027b2:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027b6:	10069073          	csrw	sstatus,a3
  w_sepc(p->tf->epc);
    800027ba:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800027bc:	6f18                	ld	a4,24(a4)
    800027be:	14171073          	csrw	sepc,a4
  uint64 satp = MAKE_SATP(p->pagetable);
    800027c2:	6d2c                	ld	a1,88(a0)
    800027c4:	81b1                	srli	a1,a1,0xc
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800027c6:	00007717          	auipc	a4,0x7
    800027ca:	8ca70713          	addi	a4,a4,-1846 # 80009090 <userret>
    800027ce:	8f11                	sub	a4,a4,a2
    800027d0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800027d2:	577d                	li	a4,-1
    800027d4:	177e                	slli	a4,a4,0x3f
    800027d6:	8dd9                	or	a1,a1,a4
    800027d8:	02000537          	lui	a0,0x2000
    800027dc:	157d                	addi	a0,a0,-1
    800027de:	0536                	slli	a0,a0,0xd
    800027e0:	9782                	jalr	a5
}
    800027e2:	60a2                	ld	ra,8(sp)
    800027e4:	6402                	ld	s0,0(sp)
    800027e6:	0141                	addi	sp,sp,16
    800027e8:	8082                	ret

00000000800027ea <clockintr>:
{
    800027ea:	1101                	addi	sp,sp,-32
    800027ec:	ec06                	sd	ra,24(sp)
    800027ee:	e822                	sd	s0,16(sp)
    800027f0:	e426                	sd	s1,8(sp)
    800027f2:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800027f4:	00014497          	auipc	s1,0x14
    800027f8:	2cc48493          	addi	s1,s1,716 # 80016ac0 <tickslock>
    800027fc:	8526                	mv	a0,s1
    800027fe:	ffffe097          	auipc	ra,0xffffe
    80002802:	2a2080e7          	jalr	674(ra) # 80000aa0 <acquire>
  ticks++;
    80002806:	00027517          	auipc	a0,0x27
    8000280a:	b7a50513          	addi	a0,a0,-1158 # 80029380 <ticks>
    8000280e:	411c                	lw	a5,0(a0)
    80002810:	2785                	addiw	a5,a5,1
    80002812:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002814:	00000097          	auipc	ra,0x0
    80002818:	bc0080e7          	jalr	-1088(ra) # 800023d4 <wakeup>
  release(&tickslock);
    8000281c:	8526                	mv	a0,s1
    8000281e:	ffffe097          	auipc	ra,0xffffe
    80002822:	352080e7          	jalr	850(ra) # 80000b70 <release>
}
    80002826:	60e2                	ld	ra,24(sp)
    80002828:	6442                	ld	s0,16(sp)
    8000282a:	64a2                	ld	s1,8(sp)
    8000282c:	6105                	addi	sp,sp,32
    8000282e:	8082                	ret

0000000080002830 <devintr>:
{
    80002830:	1101                	addi	sp,sp,-32
    80002832:	ec06                	sd	ra,24(sp)
    80002834:	e822                	sd	s0,16(sp)
    80002836:	e426                	sd	s1,8(sp)
    80002838:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000283a:	14202773          	csrr	a4,scause
  if((scause & 0x8000000000000000L) &&
    8000283e:	00074d63          	bltz	a4,80002858 <devintr+0x28>
  } else if(scause == 0x8000000000000001L){
    80002842:	57fd                	li	a5,-1
    80002844:	17fe                	slli	a5,a5,0x3f
    80002846:	0785                	addi	a5,a5,1
    return 0;
    80002848:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000284a:	06f70663          	beq	a4,a5,800028b6 <devintr+0x86>
}
    8000284e:	60e2                	ld	ra,24(sp)
    80002850:	6442                	ld	s0,16(sp)
    80002852:	64a2                	ld	s1,8(sp)
    80002854:	6105                	addi	sp,sp,32
    80002856:	8082                	ret
     (scause & 0xff) == 9){
    80002858:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    8000285c:	46a5                	li	a3,9
    8000285e:	fed792e3          	bne	a5,a3,80002842 <devintr+0x12>
    int irq = plic_claim();
    80002862:	00003097          	auipc	ra,0x3
    80002866:	6d0080e7          	jalr	1744(ra) # 80005f32 <plic_claim>
    8000286a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000286c:	47a9                	li	a5,10
    8000286e:	00f50e63          	beq	a0,a5,8000288a <devintr+0x5a>
    } else if(irq == VIRTIO0_IRQ || irq == VIRTIO1_IRQ ){
    80002872:	fff5079b          	addiw	a5,a0,-1
    80002876:	4705                	li	a4,1
    80002878:	00f77e63          	bgeu	a4,a5,80002894 <devintr+0x64>
    } else if(irq == E1000_IRQ){
    8000287c:	02100793          	li	a5,33
    80002880:	02f50663          	beq	a0,a5,800028ac <devintr+0x7c>
    return 1;
    80002884:	4505                	li	a0,1
    if(irq)
    80002886:	d4e1                	beqz	s1,8000284e <devintr+0x1e>
    80002888:	a819                	j	8000289e <devintr+0x6e>
      uartintr();
    8000288a:	ffffe097          	auipc	ra,0xffffe
    8000288e:	fba080e7          	jalr	-70(ra) # 80000844 <uartintr>
    80002892:	a031                	j	8000289e <devintr+0x6e>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    80002894:	853e                	mv	a0,a5
    80002896:	00004097          	auipc	ra,0x4
    8000289a:	c6a080e7          	jalr	-918(ra) # 80006500 <virtio_disk_intr>
      plic_complete(irq);
    8000289e:	8526                	mv	a0,s1
    800028a0:	00003097          	auipc	ra,0x3
    800028a4:	6b6080e7          	jalr	1718(ra) # 80005f56 <plic_complete>
    return 1;
    800028a8:	4505                	li	a0,1
    800028aa:	b755                	j	8000284e <devintr+0x1e>
      e1000_intr();
    800028ac:	00004097          	auipc	ra,0x4
    800028b0:	fc0080e7          	jalr	-64(ra) # 8000686c <e1000_intr>
    800028b4:	b7ed                	j	8000289e <devintr+0x6e>
    if(cpuid() == 0){
    800028b6:	fffff097          	auipc	ra,0xfffff
    800028ba:	1b2080e7          	jalr	434(ra) # 80001a68 <cpuid>
    800028be:	c901                	beqz	a0,800028ce <devintr+0x9e>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800028c0:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800028c4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800028c6:	14479073          	csrw	sip,a5
    return 2;
    800028ca:	4509                	li	a0,2
    800028cc:	b749                	j	8000284e <devintr+0x1e>
      clockintr();
    800028ce:	00000097          	auipc	ra,0x0
    800028d2:	f1c080e7          	jalr	-228(ra) # 800027ea <clockintr>
    800028d6:	b7ed                	j	800028c0 <devintr+0x90>

00000000800028d8 <usertrap>:
{
    800028d8:	7179                	addi	sp,sp,-48
    800028da:	f406                	sd	ra,40(sp)
    800028dc:	f022                	sd	s0,32(sp)
    800028de:	ec26                	sd	s1,24(sp)
    800028e0:	e84a                	sd	s2,16(sp)
    800028e2:	e44e                	sd	s3,8(sp)
    800028e4:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028e6:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800028ea:	1007f793          	andi	a5,a5,256
    800028ee:	e3b5                	bnez	a5,80002952 <usertrap+0x7a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028f0:	00003797          	auipc	a5,0x3
    800028f4:	52078793          	addi	a5,a5,1312 # 80005e10 <kernelvec>
    800028f8:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800028fc:	fffff097          	auipc	ra,0xfffff
    80002900:	198080e7          	jalr	408(ra) # 80001a94 <myproc>
    80002904:	84aa                	mv	s1,a0
  p->tf->epc = r_sepc();
    80002906:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002908:	14102773          	csrr	a4,sepc
    8000290c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000290e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002912:	47a1                	li	a5,8
    80002914:	04f71d63          	bne	a4,a5,8000296e <usertrap+0x96>
    if(p->killed)
    80002918:	5d1c                	lw	a5,56(a0)
    8000291a:	e7a1                	bnez	a5,80002962 <usertrap+0x8a>
    p->tf->epc += 4;
    8000291c:	70b8                	ld	a4,96(s1)
    8000291e:	6f1c                	ld	a5,24(a4)
    80002920:	0791                	addi	a5,a5,4
    80002922:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002924:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002928:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000292c:	10079073          	csrw	sstatus,a5
    syscall();
    80002930:	00000097          	auipc	ra,0x0
    80002934:	2fe080e7          	jalr	766(ra) # 80002c2e <syscall>
  if(p->killed)
    80002938:	5c9c                	lw	a5,56(s1)
    8000293a:	e3cd                	bnez	a5,800029dc <usertrap+0x104>
  usertrapret();
    8000293c:	00000097          	auipc	ra,0x0
    80002940:	e10080e7          	jalr	-496(ra) # 8000274c <usertrapret>
}
    80002944:	70a2                	ld	ra,40(sp)
    80002946:	7402                	ld	s0,32(sp)
    80002948:	64e2                	ld	s1,24(sp)
    8000294a:	6942                	ld	s2,16(sp)
    8000294c:	69a2                	ld	s3,8(sp)
    8000294e:	6145                	addi	sp,sp,48
    80002950:	8082                	ret
    panic("usertrap: not from user mode");
    80002952:	00007517          	auipc	a0,0x7
    80002956:	c1e50513          	addi	a0,a0,-994 # 80009570 <userret+0x4e0>
    8000295a:	ffffe097          	auipc	ra,0xffffe
    8000295e:	bfa080e7          	jalr	-1030(ra) # 80000554 <panic>
      exit(-1);
    80002962:	557d                	li	a0,-1
    80002964:	fffff097          	auipc	ra,0xfffff
    80002968:	7a6080e7          	jalr	1958(ra) # 8000210a <exit>
    8000296c:	bf45                	j	8000291c <usertrap+0x44>
  } else if((which_dev = devintr()) != 0){
    8000296e:	00000097          	auipc	ra,0x0
    80002972:	ec2080e7          	jalr	-318(ra) # 80002830 <devintr>
    80002976:	892a                	mv	s2,a0
    80002978:	c501                	beqz	a0,80002980 <usertrap+0xa8>
  if(p->killed)
    8000297a:	5c9c                	lw	a5,56(s1)
    8000297c:	cba1                	beqz	a5,800029cc <usertrap+0xf4>
    8000297e:	a091                	j	800029c2 <usertrap+0xea>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002980:	142029f3          	csrr	s3,scause
    80002984:	14202573          	csrr	a0,scause
    printf("usertrap(): unexpected scause %p (%s) pid=%d\n", r_scause(), scause_desc(r_scause()), p->pid);
    80002988:	00000097          	auipc	ra,0x0
    8000298c:	cea080e7          	jalr	-790(ra) # 80002672 <scause_desc>
    80002990:	862a                	mv	a2,a0
    80002992:	40b4                	lw	a3,64(s1)
    80002994:	85ce                	mv	a1,s3
    80002996:	00007517          	auipc	a0,0x7
    8000299a:	bfa50513          	addi	a0,a0,-1030 # 80009590 <userret+0x500>
    8000299e:	ffffe097          	auipc	ra,0xffffe
    800029a2:	c10080e7          	jalr	-1008(ra) # 800005ae <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029a6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029aa:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029ae:	00007517          	auipc	a0,0x7
    800029b2:	c1250513          	addi	a0,a0,-1006 # 800095c0 <userret+0x530>
    800029b6:	ffffe097          	auipc	ra,0xffffe
    800029ba:	bf8080e7          	jalr	-1032(ra) # 800005ae <printf>
    p->killed = 1;
    800029be:	4785                	li	a5,1
    800029c0:	dc9c                	sw	a5,56(s1)
    exit(-1);
    800029c2:	557d                	li	a0,-1
    800029c4:	fffff097          	auipc	ra,0xfffff
    800029c8:	746080e7          	jalr	1862(ra) # 8000210a <exit>
  if(which_dev == 2)
    800029cc:	4789                	li	a5,2
    800029ce:	f6f917e3          	bne	s2,a5,8000293c <usertrap+0x64>
    yield();
    800029d2:	00000097          	auipc	ra,0x0
    800029d6:	846080e7          	jalr	-1978(ra) # 80002218 <yield>
    800029da:	b78d                	j	8000293c <usertrap+0x64>
  int which_dev = 0;
    800029dc:	4901                	li	s2,0
    800029de:	b7d5                	j	800029c2 <usertrap+0xea>

00000000800029e0 <kerneltrap>:
{
    800029e0:	7179                	addi	sp,sp,-48
    800029e2:	f406                	sd	ra,40(sp)
    800029e4:	f022                	sd	s0,32(sp)
    800029e6:	ec26                	sd	s1,24(sp)
    800029e8:	e84a                	sd	s2,16(sp)
    800029ea:	e44e                	sd	s3,8(sp)
    800029ec:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029ee:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029f2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029f6:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800029fa:	1004f793          	andi	a5,s1,256
    800029fe:	cb85                	beqz	a5,80002a2e <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a00:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002a04:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002a06:	ef85                	bnez	a5,80002a3e <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002a08:	00000097          	auipc	ra,0x0
    80002a0c:	e28080e7          	jalr	-472(ra) # 80002830 <devintr>
    80002a10:	cd1d                	beqz	a0,80002a4e <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a12:	4789                	li	a5,2
    80002a14:	08f50063          	beq	a0,a5,80002a94 <kerneltrap+0xb4>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a18:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a1c:	10049073          	csrw	sstatus,s1
}
    80002a20:	70a2                	ld	ra,40(sp)
    80002a22:	7402                	ld	s0,32(sp)
    80002a24:	64e2                	ld	s1,24(sp)
    80002a26:	6942                	ld	s2,16(sp)
    80002a28:	69a2                	ld	s3,8(sp)
    80002a2a:	6145                	addi	sp,sp,48
    80002a2c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a2e:	00007517          	auipc	a0,0x7
    80002a32:	bb250513          	addi	a0,a0,-1102 # 800095e0 <userret+0x550>
    80002a36:	ffffe097          	auipc	ra,0xffffe
    80002a3a:	b1e080e7          	jalr	-1250(ra) # 80000554 <panic>
    panic("kerneltrap: interrupts enabled");
    80002a3e:	00007517          	auipc	a0,0x7
    80002a42:	bca50513          	addi	a0,a0,-1078 # 80009608 <userret+0x578>
    80002a46:	ffffe097          	auipc	ra,0xffffe
    80002a4a:	b0e080e7          	jalr	-1266(ra) # 80000554 <panic>
    printf("scause %p (%s)\n", scause, scause_desc(scause));
    80002a4e:	854e                	mv	a0,s3
    80002a50:	00000097          	auipc	ra,0x0
    80002a54:	c22080e7          	jalr	-990(ra) # 80002672 <scause_desc>
    80002a58:	862a                	mv	a2,a0
    80002a5a:	85ce                	mv	a1,s3
    80002a5c:	00007517          	auipc	a0,0x7
    80002a60:	bcc50513          	addi	a0,a0,-1076 # 80009628 <userret+0x598>
    80002a64:	ffffe097          	auipc	ra,0xffffe
    80002a68:	b4a080e7          	jalr	-1206(ra) # 800005ae <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a6c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a70:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a74:	00007517          	auipc	a0,0x7
    80002a78:	bc450513          	addi	a0,a0,-1084 # 80009638 <userret+0x5a8>
    80002a7c:	ffffe097          	auipc	ra,0xffffe
    80002a80:	b32080e7          	jalr	-1230(ra) # 800005ae <printf>
    panic("kerneltrap");
    80002a84:	00007517          	auipc	a0,0x7
    80002a88:	bcc50513          	addi	a0,a0,-1076 # 80009650 <userret+0x5c0>
    80002a8c:	ffffe097          	auipc	ra,0xffffe
    80002a90:	ac8080e7          	jalr	-1336(ra) # 80000554 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a94:	fffff097          	auipc	ra,0xfffff
    80002a98:	000080e7          	jalr	ra # 80001a94 <myproc>
    80002a9c:	dd35                	beqz	a0,80002a18 <kerneltrap+0x38>
    80002a9e:	fffff097          	auipc	ra,0xfffff
    80002aa2:	ff6080e7          	jalr	-10(ra) # 80001a94 <myproc>
    80002aa6:	5118                	lw	a4,32(a0)
    80002aa8:	478d                	li	a5,3
    80002aaa:	f6f717e3          	bne	a4,a5,80002a18 <kerneltrap+0x38>
    yield();
    80002aae:	fffff097          	auipc	ra,0xfffff
    80002ab2:	76a080e7          	jalr	1898(ra) # 80002218 <yield>
    80002ab6:	b78d                	j	80002a18 <kerneltrap+0x38>

0000000080002ab8 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002ab8:	1101                	addi	sp,sp,-32
    80002aba:	ec06                	sd	ra,24(sp)
    80002abc:	e822                	sd	s0,16(sp)
    80002abe:	e426                	sd	s1,8(sp)
    80002ac0:	1000                	addi	s0,sp,32
    80002ac2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002ac4:	fffff097          	auipc	ra,0xfffff
    80002ac8:	fd0080e7          	jalr	-48(ra) # 80001a94 <myproc>
  switch (n) {
    80002acc:	4795                	li	a5,5
    80002ace:	0497e163          	bltu	a5,s1,80002b10 <argraw+0x58>
    80002ad2:	048a                	slli	s1,s1,0x2
    80002ad4:	00007717          	auipc	a4,0x7
    80002ad8:	3cc70713          	addi	a4,a4,972 # 80009ea0 <nointr_desc.0+0x80>
    80002adc:	94ba                	add	s1,s1,a4
    80002ade:	409c                	lw	a5,0(s1)
    80002ae0:	97ba                	add	a5,a5,a4
    80002ae2:	8782                	jr	a5
  case 0:
    return p->tf->a0;
    80002ae4:	713c                	ld	a5,96(a0)
    80002ae6:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->tf->a5;
  }
  panic("argraw");
  return -1;
}
    80002ae8:	60e2                	ld	ra,24(sp)
    80002aea:	6442                	ld	s0,16(sp)
    80002aec:	64a2                	ld	s1,8(sp)
    80002aee:	6105                	addi	sp,sp,32
    80002af0:	8082                	ret
    return p->tf->a1;
    80002af2:	713c                	ld	a5,96(a0)
    80002af4:	7fa8                	ld	a0,120(a5)
    80002af6:	bfcd                	j	80002ae8 <argraw+0x30>
    return p->tf->a2;
    80002af8:	713c                	ld	a5,96(a0)
    80002afa:	63c8                	ld	a0,128(a5)
    80002afc:	b7f5                	j	80002ae8 <argraw+0x30>
    return p->tf->a3;
    80002afe:	713c                	ld	a5,96(a0)
    80002b00:	67c8                	ld	a0,136(a5)
    80002b02:	b7dd                	j	80002ae8 <argraw+0x30>
    return p->tf->a4;
    80002b04:	713c                	ld	a5,96(a0)
    80002b06:	6bc8                	ld	a0,144(a5)
    80002b08:	b7c5                	j	80002ae8 <argraw+0x30>
    return p->tf->a5;
    80002b0a:	713c                	ld	a5,96(a0)
    80002b0c:	6fc8                	ld	a0,152(a5)
    80002b0e:	bfe9                	j	80002ae8 <argraw+0x30>
  panic("argraw");
    80002b10:	00007517          	auipc	a0,0x7
    80002b14:	d4850513          	addi	a0,a0,-696 # 80009858 <userret+0x7c8>
    80002b18:	ffffe097          	auipc	ra,0xffffe
    80002b1c:	a3c080e7          	jalr	-1476(ra) # 80000554 <panic>

0000000080002b20 <fetchaddr>:
{
    80002b20:	1101                	addi	sp,sp,-32
    80002b22:	ec06                	sd	ra,24(sp)
    80002b24:	e822                	sd	s0,16(sp)
    80002b26:	e426                	sd	s1,8(sp)
    80002b28:	e04a                	sd	s2,0(sp)
    80002b2a:	1000                	addi	s0,sp,32
    80002b2c:	84aa                	mv	s1,a0
    80002b2e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b30:	fffff097          	auipc	ra,0xfffff
    80002b34:	f64080e7          	jalr	-156(ra) # 80001a94 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002b38:	693c                	ld	a5,80(a0)
    80002b3a:	02f4f863          	bgeu	s1,a5,80002b6a <fetchaddr+0x4a>
    80002b3e:	00848713          	addi	a4,s1,8
    80002b42:	02e7e663          	bltu	a5,a4,80002b6e <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b46:	46a1                	li	a3,8
    80002b48:	8626                	mv	a2,s1
    80002b4a:	85ca                	mv	a1,s2
    80002b4c:	6d28                	ld	a0,88(a0)
    80002b4e:	fffff097          	auipc	ra,0xfffff
    80002b52:	cc4080e7          	jalr	-828(ra) # 80001812 <copyin>
    80002b56:	00a03533          	snez	a0,a0
    80002b5a:	40a00533          	neg	a0,a0
}
    80002b5e:	60e2                	ld	ra,24(sp)
    80002b60:	6442                	ld	s0,16(sp)
    80002b62:	64a2                	ld	s1,8(sp)
    80002b64:	6902                	ld	s2,0(sp)
    80002b66:	6105                	addi	sp,sp,32
    80002b68:	8082                	ret
    return -1;
    80002b6a:	557d                	li	a0,-1
    80002b6c:	bfcd                	j	80002b5e <fetchaddr+0x3e>
    80002b6e:	557d                	li	a0,-1
    80002b70:	b7fd                	j	80002b5e <fetchaddr+0x3e>

0000000080002b72 <fetchstr>:
{
    80002b72:	7179                	addi	sp,sp,-48
    80002b74:	f406                	sd	ra,40(sp)
    80002b76:	f022                	sd	s0,32(sp)
    80002b78:	ec26                	sd	s1,24(sp)
    80002b7a:	e84a                	sd	s2,16(sp)
    80002b7c:	e44e                	sd	s3,8(sp)
    80002b7e:	1800                	addi	s0,sp,48
    80002b80:	892a                	mv	s2,a0
    80002b82:	84ae                	mv	s1,a1
    80002b84:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002b86:	fffff097          	auipc	ra,0xfffff
    80002b8a:	f0e080e7          	jalr	-242(ra) # 80001a94 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002b8e:	86ce                	mv	a3,s3
    80002b90:	864a                	mv	a2,s2
    80002b92:	85a6                	mv	a1,s1
    80002b94:	6d28                	ld	a0,88(a0)
    80002b96:	fffff097          	auipc	ra,0xfffff
    80002b9a:	d0a080e7          	jalr	-758(ra) # 800018a0 <copyinstr>
  if(err < 0)
    80002b9e:	00054763          	bltz	a0,80002bac <fetchstr+0x3a>
  return strlen(buf);
    80002ba2:	8526                	mv	a0,s1
    80002ba4:	ffffe097          	auipc	ra,0xffffe
    80002ba8:	34e080e7          	jalr	846(ra) # 80000ef2 <strlen>
}
    80002bac:	70a2                	ld	ra,40(sp)
    80002bae:	7402                	ld	s0,32(sp)
    80002bb0:	64e2                	ld	s1,24(sp)
    80002bb2:	6942                	ld	s2,16(sp)
    80002bb4:	69a2                	ld	s3,8(sp)
    80002bb6:	6145                	addi	sp,sp,48
    80002bb8:	8082                	ret

0000000080002bba <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002bba:	1101                	addi	sp,sp,-32
    80002bbc:	ec06                	sd	ra,24(sp)
    80002bbe:	e822                	sd	s0,16(sp)
    80002bc0:	e426                	sd	s1,8(sp)
    80002bc2:	1000                	addi	s0,sp,32
    80002bc4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002bc6:	00000097          	auipc	ra,0x0
    80002bca:	ef2080e7          	jalr	-270(ra) # 80002ab8 <argraw>
    80002bce:	c088                	sw	a0,0(s1)
  return 0;
}
    80002bd0:	4501                	li	a0,0
    80002bd2:	60e2                	ld	ra,24(sp)
    80002bd4:	6442                	ld	s0,16(sp)
    80002bd6:	64a2                	ld	s1,8(sp)
    80002bd8:	6105                	addi	sp,sp,32
    80002bda:	8082                	ret

0000000080002bdc <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002bdc:	1101                	addi	sp,sp,-32
    80002bde:	ec06                	sd	ra,24(sp)
    80002be0:	e822                	sd	s0,16(sp)
    80002be2:	e426                	sd	s1,8(sp)
    80002be4:	1000                	addi	s0,sp,32
    80002be6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002be8:	00000097          	auipc	ra,0x0
    80002bec:	ed0080e7          	jalr	-304(ra) # 80002ab8 <argraw>
    80002bf0:	e088                	sd	a0,0(s1)
  return 0;
}
    80002bf2:	4501                	li	a0,0
    80002bf4:	60e2                	ld	ra,24(sp)
    80002bf6:	6442                	ld	s0,16(sp)
    80002bf8:	64a2                	ld	s1,8(sp)
    80002bfa:	6105                	addi	sp,sp,32
    80002bfc:	8082                	ret

0000000080002bfe <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002bfe:	1101                	addi	sp,sp,-32
    80002c00:	ec06                	sd	ra,24(sp)
    80002c02:	e822                	sd	s0,16(sp)
    80002c04:	e426                	sd	s1,8(sp)
    80002c06:	e04a                	sd	s2,0(sp)
    80002c08:	1000                	addi	s0,sp,32
    80002c0a:	84ae                	mv	s1,a1
    80002c0c:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002c0e:	00000097          	auipc	ra,0x0
    80002c12:	eaa080e7          	jalr	-342(ra) # 80002ab8 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002c16:	864a                	mv	a2,s2
    80002c18:	85a6                	mv	a1,s1
    80002c1a:	00000097          	auipc	ra,0x0
    80002c1e:	f58080e7          	jalr	-168(ra) # 80002b72 <fetchstr>
}
    80002c22:	60e2                	ld	ra,24(sp)
    80002c24:	6442                	ld	s0,16(sp)
    80002c26:	64a2                	ld	s1,8(sp)
    80002c28:	6902                	ld	s2,0(sp)
    80002c2a:	6105                	addi	sp,sp,32
    80002c2c:	8082                	ret

0000000080002c2e <syscall>:
[SYS_ntas]    sys_ntas,
};

void
syscall(void)
{
    80002c2e:	1101                	addi	sp,sp,-32
    80002c30:	ec06                	sd	ra,24(sp)
    80002c32:	e822                	sd	s0,16(sp)
    80002c34:	e426                	sd	s1,8(sp)
    80002c36:	e04a                	sd	s2,0(sp)
    80002c38:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002c3a:	fffff097          	auipc	ra,0xfffff
    80002c3e:	e5a080e7          	jalr	-422(ra) # 80001a94 <myproc>
    80002c42:	84aa                	mv	s1,a0

  num = p->tf->a7;
    80002c44:	06053903          	ld	s2,96(a0)
    80002c48:	0a893783          	ld	a5,168(s2)
    80002c4c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c50:	37fd                	addiw	a5,a5,-1
    80002c52:	4759                	li	a4,22
    80002c54:	00f76f63          	bltu	a4,a5,80002c72 <syscall+0x44>
    80002c58:	00369713          	slli	a4,a3,0x3
    80002c5c:	00007797          	auipc	a5,0x7
    80002c60:	25c78793          	addi	a5,a5,604 # 80009eb8 <syscalls>
    80002c64:	97ba                	add	a5,a5,a4
    80002c66:	639c                	ld	a5,0(a5)
    80002c68:	c789                	beqz	a5,80002c72 <syscall+0x44>
    p->tf->a0 = syscalls[num]();
    80002c6a:	9782                	jalr	a5
    80002c6c:	06a93823          	sd	a0,112(s2)
    80002c70:	a839                	j	80002c8e <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002c72:	16048613          	addi	a2,s1,352
    80002c76:	40ac                	lw	a1,64(s1)
    80002c78:	00007517          	auipc	a0,0x7
    80002c7c:	be850513          	addi	a0,a0,-1048 # 80009860 <userret+0x7d0>
    80002c80:	ffffe097          	auipc	ra,0xffffe
    80002c84:	92e080e7          	jalr	-1746(ra) # 800005ae <printf>
            p->pid, p->name, num);
    p->tf->a0 = -1;
    80002c88:	70bc                	ld	a5,96(s1)
    80002c8a:	577d                	li	a4,-1
    80002c8c:	fbb8                	sd	a4,112(a5)
  }
}
    80002c8e:	60e2                	ld	ra,24(sp)
    80002c90:	6442                	ld	s0,16(sp)
    80002c92:	64a2                	ld	s1,8(sp)
    80002c94:	6902                	ld	s2,0(sp)
    80002c96:	6105                	addi	sp,sp,32
    80002c98:	8082                	ret

0000000080002c9a <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002c9a:	1101                	addi	sp,sp,-32
    80002c9c:	ec06                	sd	ra,24(sp)
    80002c9e:	e822                	sd	s0,16(sp)
    80002ca0:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002ca2:	fec40593          	addi	a1,s0,-20
    80002ca6:	4501                	li	a0,0
    80002ca8:	00000097          	auipc	ra,0x0
    80002cac:	f12080e7          	jalr	-238(ra) # 80002bba <argint>
    return -1;
    80002cb0:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002cb2:	00054963          	bltz	a0,80002cc4 <sys_exit+0x2a>
  exit(n);
    80002cb6:	fec42503          	lw	a0,-20(s0)
    80002cba:	fffff097          	auipc	ra,0xfffff
    80002cbe:	450080e7          	jalr	1104(ra) # 8000210a <exit>
  return 0;  // not reached
    80002cc2:	4781                	li	a5,0
}
    80002cc4:	853e                	mv	a0,a5
    80002cc6:	60e2                	ld	ra,24(sp)
    80002cc8:	6442                	ld	s0,16(sp)
    80002cca:	6105                	addi	sp,sp,32
    80002ccc:	8082                	ret

0000000080002cce <sys_getpid>:

uint64
sys_getpid(void)
{
    80002cce:	1141                	addi	sp,sp,-16
    80002cd0:	e406                	sd	ra,8(sp)
    80002cd2:	e022                	sd	s0,0(sp)
    80002cd4:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002cd6:	fffff097          	auipc	ra,0xfffff
    80002cda:	dbe080e7          	jalr	-578(ra) # 80001a94 <myproc>
}
    80002cde:	4128                	lw	a0,64(a0)
    80002ce0:	60a2                	ld	ra,8(sp)
    80002ce2:	6402                	ld	s0,0(sp)
    80002ce4:	0141                	addi	sp,sp,16
    80002ce6:	8082                	ret

0000000080002ce8 <sys_fork>:

uint64
sys_fork(void)
{
    80002ce8:	1141                	addi	sp,sp,-16
    80002cea:	e406                	sd	ra,8(sp)
    80002cec:	e022                	sd	s0,0(sp)
    80002cee:	0800                	addi	s0,sp,16
  return fork();
    80002cf0:	fffff097          	auipc	ra,0xfffff
    80002cf4:	10e080e7          	jalr	270(ra) # 80001dfe <fork>
}
    80002cf8:	60a2                	ld	ra,8(sp)
    80002cfa:	6402                	ld	s0,0(sp)
    80002cfc:	0141                	addi	sp,sp,16
    80002cfe:	8082                	ret

0000000080002d00 <sys_wait>:

uint64
sys_wait(void)
{
    80002d00:	1101                	addi	sp,sp,-32
    80002d02:	ec06                	sd	ra,24(sp)
    80002d04:	e822                	sd	s0,16(sp)
    80002d06:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002d08:	fe840593          	addi	a1,s0,-24
    80002d0c:	4501                	li	a0,0
    80002d0e:	00000097          	auipc	ra,0x0
    80002d12:	ece080e7          	jalr	-306(ra) # 80002bdc <argaddr>
    80002d16:	87aa                	mv	a5,a0
    return -1;
    80002d18:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002d1a:	0007c863          	bltz	a5,80002d2a <sys_wait+0x2a>
  return wait(p);
    80002d1e:	fe843503          	ld	a0,-24(s0)
    80002d22:	fffff097          	auipc	ra,0xfffff
    80002d26:	5b0080e7          	jalr	1456(ra) # 800022d2 <wait>
}
    80002d2a:	60e2                	ld	ra,24(sp)
    80002d2c:	6442                	ld	s0,16(sp)
    80002d2e:	6105                	addi	sp,sp,32
    80002d30:	8082                	ret

0000000080002d32 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002d32:	7179                	addi	sp,sp,-48
    80002d34:	f406                	sd	ra,40(sp)
    80002d36:	f022                	sd	s0,32(sp)
    80002d38:	ec26                	sd	s1,24(sp)
    80002d3a:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002d3c:	fdc40593          	addi	a1,s0,-36
    80002d40:	4501                	li	a0,0
    80002d42:	00000097          	auipc	ra,0x0
    80002d46:	e78080e7          	jalr	-392(ra) # 80002bba <argint>
    return -1;
    80002d4a:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002d4c:	00054f63          	bltz	a0,80002d6a <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002d50:	fffff097          	auipc	ra,0xfffff
    80002d54:	d44080e7          	jalr	-700(ra) # 80001a94 <myproc>
    80002d58:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    80002d5a:	fdc42503          	lw	a0,-36(s0)
    80002d5e:	fffff097          	auipc	ra,0xfffff
    80002d62:	02c080e7          	jalr	44(ra) # 80001d8a <growproc>
    80002d66:	00054863          	bltz	a0,80002d76 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002d6a:	8526                	mv	a0,s1
    80002d6c:	70a2                	ld	ra,40(sp)
    80002d6e:	7402                	ld	s0,32(sp)
    80002d70:	64e2                	ld	s1,24(sp)
    80002d72:	6145                	addi	sp,sp,48
    80002d74:	8082                	ret
    return -1;
    80002d76:	54fd                	li	s1,-1
    80002d78:	bfcd                	j	80002d6a <sys_sbrk+0x38>

0000000080002d7a <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d7a:	7139                	addi	sp,sp,-64
    80002d7c:	fc06                	sd	ra,56(sp)
    80002d7e:	f822                	sd	s0,48(sp)
    80002d80:	f426                	sd	s1,40(sp)
    80002d82:	f04a                	sd	s2,32(sp)
    80002d84:	ec4e                	sd	s3,24(sp)
    80002d86:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002d88:	fcc40593          	addi	a1,s0,-52
    80002d8c:	4501                	li	a0,0
    80002d8e:	00000097          	auipc	ra,0x0
    80002d92:	e2c080e7          	jalr	-468(ra) # 80002bba <argint>
    return -1;
    80002d96:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002d98:	06054563          	bltz	a0,80002e02 <sys_sleep+0x88>
  acquire(&tickslock);
    80002d9c:	00014517          	auipc	a0,0x14
    80002da0:	d2450513          	addi	a0,a0,-732 # 80016ac0 <tickslock>
    80002da4:	ffffe097          	auipc	ra,0xffffe
    80002da8:	cfc080e7          	jalr	-772(ra) # 80000aa0 <acquire>
  ticks0 = ticks;
    80002dac:	00026917          	auipc	s2,0x26
    80002db0:	5d492903          	lw	s2,1492(s2) # 80029380 <ticks>
  while(ticks - ticks0 < n){
    80002db4:	fcc42783          	lw	a5,-52(s0)
    80002db8:	cf85                	beqz	a5,80002df0 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002dba:	00014997          	auipc	s3,0x14
    80002dbe:	d0698993          	addi	s3,s3,-762 # 80016ac0 <tickslock>
    80002dc2:	00026497          	auipc	s1,0x26
    80002dc6:	5be48493          	addi	s1,s1,1470 # 80029380 <ticks>
    if(myproc()->killed){
    80002dca:	fffff097          	auipc	ra,0xfffff
    80002dce:	cca080e7          	jalr	-822(ra) # 80001a94 <myproc>
    80002dd2:	5d1c                	lw	a5,56(a0)
    80002dd4:	ef9d                	bnez	a5,80002e12 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002dd6:	85ce                	mv	a1,s3
    80002dd8:	8526                	mv	a0,s1
    80002dda:	fffff097          	auipc	ra,0xfffff
    80002dde:	47a080e7          	jalr	1146(ra) # 80002254 <sleep>
  while(ticks - ticks0 < n){
    80002de2:	409c                	lw	a5,0(s1)
    80002de4:	412787bb          	subw	a5,a5,s2
    80002de8:	fcc42703          	lw	a4,-52(s0)
    80002dec:	fce7efe3          	bltu	a5,a4,80002dca <sys_sleep+0x50>
  }
  release(&tickslock);
    80002df0:	00014517          	auipc	a0,0x14
    80002df4:	cd050513          	addi	a0,a0,-816 # 80016ac0 <tickslock>
    80002df8:	ffffe097          	auipc	ra,0xffffe
    80002dfc:	d78080e7          	jalr	-648(ra) # 80000b70 <release>
  return 0;
    80002e00:	4781                	li	a5,0
}
    80002e02:	853e                	mv	a0,a5
    80002e04:	70e2                	ld	ra,56(sp)
    80002e06:	7442                	ld	s0,48(sp)
    80002e08:	74a2                	ld	s1,40(sp)
    80002e0a:	7902                	ld	s2,32(sp)
    80002e0c:	69e2                	ld	s3,24(sp)
    80002e0e:	6121                	addi	sp,sp,64
    80002e10:	8082                	ret
      release(&tickslock);
    80002e12:	00014517          	auipc	a0,0x14
    80002e16:	cae50513          	addi	a0,a0,-850 # 80016ac0 <tickslock>
    80002e1a:	ffffe097          	auipc	ra,0xffffe
    80002e1e:	d56080e7          	jalr	-682(ra) # 80000b70 <release>
      return -1;
    80002e22:	57fd                	li	a5,-1
    80002e24:	bff9                	j	80002e02 <sys_sleep+0x88>

0000000080002e26 <sys_kill>:

uint64
sys_kill(void)
{
    80002e26:	1101                	addi	sp,sp,-32
    80002e28:	ec06                	sd	ra,24(sp)
    80002e2a:	e822                	sd	s0,16(sp)
    80002e2c:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002e2e:	fec40593          	addi	a1,s0,-20
    80002e32:	4501                	li	a0,0
    80002e34:	00000097          	auipc	ra,0x0
    80002e38:	d86080e7          	jalr	-634(ra) # 80002bba <argint>
    80002e3c:	87aa                	mv	a5,a0
    return -1;
    80002e3e:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002e40:	0007c863          	bltz	a5,80002e50 <sys_kill+0x2a>
  return kill(pid);
    80002e44:	fec42503          	lw	a0,-20(s0)
    80002e48:	fffff097          	auipc	ra,0xfffff
    80002e4c:	5f6080e7          	jalr	1526(ra) # 8000243e <kill>
}
    80002e50:	60e2                	ld	ra,24(sp)
    80002e52:	6442                	ld	s0,16(sp)
    80002e54:	6105                	addi	sp,sp,32
    80002e56:	8082                	ret

0000000080002e58 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e58:	1101                	addi	sp,sp,-32
    80002e5a:	ec06                	sd	ra,24(sp)
    80002e5c:	e822                	sd	s0,16(sp)
    80002e5e:	e426                	sd	s1,8(sp)
    80002e60:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e62:	00014517          	auipc	a0,0x14
    80002e66:	c5e50513          	addi	a0,a0,-930 # 80016ac0 <tickslock>
    80002e6a:	ffffe097          	auipc	ra,0xffffe
    80002e6e:	c36080e7          	jalr	-970(ra) # 80000aa0 <acquire>
  xticks = ticks;
    80002e72:	00026497          	auipc	s1,0x26
    80002e76:	50e4a483          	lw	s1,1294(s1) # 80029380 <ticks>
  release(&tickslock);
    80002e7a:	00014517          	auipc	a0,0x14
    80002e7e:	c4650513          	addi	a0,a0,-954 # 80016ac0 <tickslock>
    80002e82:	ffffe097          	auipc	ra,0xffffe
    80002e86:	cee080e7          	jalr	-786(ra) # 80000b70 <release>
  return xticks;
}
    80002e8a:	02049513          	slli	a0,s1,0x20
    80002e8e:	9101                	srli	a0,a0,0x20
    80002e90:	60e2                	ld	ra,24(sp)
    80002e92:	6442                	ld	s0,16(sp)
    80002e94:	64a2                	ld	s1,8(sp)
    80002e96:	6105                	addi	sp,sp,32
    80002e98:	8082                	ret

0000000080002e9a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002e9a:	7179                	addi	sp,sp,-48
    80002e9c:	f406                	sd	ra,40(sp)
    80002e9e:	f022                	sd	s0,32(sp)
    80002ea0:	ec26                	sd	s1,24(sp)
    80002ea2:	e84a                	sd	s2,16(sp)
    80002ea4:	e44e                	sd	s3,8(sp)
    80002ea6:	e052                	sd	s4,0(sp)
    80002ea8:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002eaa:	00006597          	auipc	a1,0x6
    80002eae:	40e58593          	addi	a1,a1,1038 # 800092b8 <userret+0x228>
    80002eb2:	00014517          	auipc	a0,0x14
    80002eb6:	c2e50513          	addi	a0,a0,-978 # 80016ae0 <bcache>
    80002eba:	ffffe097          	auipc	ra,0xffffe
    80002ebe:	b12080e7          	jalr	-1262(ra) # 800009cc <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002ec2:	0001c797          	auipc	a5,0x1c
    80002ec6:	c1e78793          	addi	a5,a5,-994 # 8001eae0 <bcache+0x8000>
    80002eca:	0001c717          	auipc	a4,0x1c
    80002ece:	f7670713          	addi	a4,a4,-138 # 8001ee40 <bcache+0x8360>
    80002ed2:	3ae7b823          	sd	a4,944(a5)
  bcache.head.next = &bcache.head;
    80002ed6:	3ae7bc23          	sd	a4,952(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002eda:	00014497          	auipc	s1,0x14
    80002ede:	c2648493          	addi	s1,s1,-986 # 80016b00 <bcache+0x20>
    b->next = bcache.head.next;
    80002ee2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002ee4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002ee6:	00007a17          	auipc	s4,0x7
    80002eea:	99aa0a13          	addi	s4,s4,-1638 # 80009880 <userret+0x7f0>
    b->next = bcache.head.next;
    80002eee:	3b893783          	ld	a5,952(s2)
    80002ef2:	ecbc                	sd	a5,88(s1)
    b->prev = &bcache.head;
    80002ef4:	0534b823          	sd	s3,80(s1)
    initsleeplock(&b->lock, "buffer");
    80002ef8:	85d2                	mv	a1,s4
    80002efa:	01048513          	addi	a0,s1,16
    80002efe:	00001097          	auipc	ra,0x1
    80002f02:	5a0080e7          	jalr	1440(ra) # 8000449e <initsleeplock>
    bcache.head.next->prev = b;
    80002f06:	3b893783          	ld	a5,952(s2)
    80002f0a:	eba4                	sd	s1,80(a5)
    bcache.head.next = b;
    80002f0c:	3a993c23          	sd	s1,952(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f10:	46048493          	addi	s1,s1,1120
    80002f14:	fd349de3          	bne	s1,s3,80002eee <binit+0x54>
  }
}
    80002f18:	70a2                	ld	ra,40(sp)
    80002f1a:	7402                	ld	s0,32(sp)
    80002f1c:	64e2                	ld	s1,24(sp)
    80002f1e:	6942                	ld	s2,16(sp)
    80002f20:	69a2                	ld	s3,8(sp)
    80002f22:	6a02                	ld	s4,0(sp)
    80002f24:	6145                	addi	sp,sp,48
    80002f26:	8082                	ret

0000000080002f28 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f28:	7179                	addi	sp,sp,-48
    80002f2a:	f406                	sd	ra,40(sp)
    80002f2c:	f022                	sd	s0,32(sp)
    80002f2e:	ec26                	sd	s1,24(sp)
    80002f30:	e84a                	sd	s2,16(sp)
    80002f32:	e44e                	sd	s3,8(sp)
    80002f34:	1800                	addi	s0,sp,48
    80002f36:	892a                	mv	s2,a0
    80002f38:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002f3a:	00014517          	auipc	a0,0x14
    80002f3e:	ba650513          	addi	a0,a0,-1114 # 80016ae0 <bcache>
    80002f42:	ffffe097          	auipc	ra,0xffffe
    80002f46:	b5e080e7          	jalr	-1186(ra) # 80000aa0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002f4a:	0001c497          	auipc	s1,0x1c
    80002f4e:	f4e4b483          	ld	s1,-178(s1) # 8001ee98 <bcache+0x83b8>
    80002f52:	0001c797          	auipc	a5,0x1c
    80002f56:	eee78793          	addi	a5,a5,-274 # 8001ee40 <bcache+0x8360>
    80002f5a:	02f48f63          	beq	s1,a5,80002f98 <bread+0x70>
    80002f5e:	873e                	mv	a4,a5
    80002f60:	a021                	j	80002f68 <bread+0x40>
    80002f62:	6ca4                	ld	s1,88(s1)
    80002f64:	02e48a63          	beq	s1,a4,80002f98 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002f68:	449c                	lw	a5,8(s1)
    80002f6a:	ff279ce3          	bne	a5,s2,80002f62 <bread+0x3a>
    80002f6e:	44dc                	lw	a5,12(s1)
    80002f70:	ff3799e3          	bne	a5,s3,80002f62 <bread+0x3a>
      b->refcnt++;
    80002f74:	44bc                	lw	a5,72(s1)
    80002f76:	2785                	addiw	a5,a5,1
    80002f78:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    80002f7a:	00014517          	auipc	a0,0x14
    80002f7e:	b6650513          	addi	a0,a0,-1178 # 80016ae0 <bcache>
    80002f82:	ffffe097          	auipc	ra,0xffffe
    80002f86:	bee080e7          	jalr	-1042(ra) # 80000b70 <release>
      acquiresleep(&b->lock);
    80002f8a:	01048513          	addi	a0,s1,16
    80002f8e:	00001097          	auipc	ra,0x1
    80002f92:	54a080e7          	jalr	1354(ra) # 800044d8 <acquiresleep>
      return b;
    80002f96:	a8b9                	j	80002ff4 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f98:	0001c497          	auipc	s1,0x1c
    80002f9c:	ef84b483          	ld	s1,-264(s1) # 8001ee90 <bcache+0x83b0>
    80002fa0:	0001c797          	auipc	a5,0x1c
    80002fa4:	ea078793          	addi	a5,a5,-352 # 8001ee40 <bcache+0x8360>
    80002fa8:	00f48863          	beq	s1,a5,80002fb8 <bread+0x90>
    80002fac:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002fae:	44bc                	lw	a5,72(s1)
    80002fb0:	cf81                	beqz	a5,80002fc8 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fb2:	68a4                	ld	s1,80(s1)
    80002fb4:	fee49de3          	bne	s1,a4,80002fae <bread+0x86>
  panic("bget: no buffers");
    80002fb8:	00007517          	auipc	a0,0x7
    80002fbc:	8d050513          	addi	a0,a0,-1840 # 80009888 <userret+0x7f8>
    80002fc0:	ffffd097          	auipc	ra,0xffffd
    80002fc4:	594080e7          	jalr	1428(ra) # 80000554 <panic>
      b->dev = dev;
    80002fc8:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002fcc:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002fd0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002fd4:	4785                	li	a5,1
    80002fd6:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    80002fd8:	00014517          	auipc	a0,0x14
    80002fdc:	b0850513          	addi	a0,a0,-1272 # 80016ae0 <bcache>
    80002fe0:	ffffe097          	auipc	ra,0xffffe
    80002fe4:	b90080e7          	jalr	-1136(ra) # 80000b70 <release>
      acquiresleep(&b->lock);
    80002fe8:	01048513          	addi	a0,s1,16
    80002fec:	00001097          	auipc	ra,0x1
    80002ff0:	4ec080e7          	jalr	1260(ra) # 800044d8 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002ff4:	409c                	lw	a5,0(s1)
    80002ff6:	cb89                	beqz	a5,80003008 <bread+0xe0>
    virtio_disk_rw(b->dev, b, 0);
    b->valid = 1;
  }
  return b;
}
    80002ff8:	8526                	mv	a0,s1
    80002ffa:	70a2                	ld	ra,40(sp)
    80002ffc:	7402                	ld	s0,32(sp)
    80002ffe:	64e2                	ld	s1,24(sp)
    80003000:	6942                	ld	s2,16(sp)
    80003002:	69a2                	ld	s3,8(sp)
    80003004:	6145                	addi	sp,sp,48
    80003006:	8082                	ret
    virtio_disk_rw(b->dev, b, 0);
    80003008:	4601                	li	a2,0
    8000300a:	85a6                	mv	a1,s1
    8000300c:	4488                	lw	a0,8(s1)
    8000300e:	00003097          	auipc	ra,0x3
    80003012:	1f6080e7          	jalr	502(ra) # 80006204 <virtio_disk_rw>
    b->valid = 1;
    80003016:	4785                	li	a5,1
    80003018:	c09c                	sw	a5,0(s1)
  return b;
    8000301a:	bff9                	j	80002ff8 <bread+0xd0>

000000008000301c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000301c:	1101                	addi	sp,sp,-32
    8000301e:	ec06                	sd	ra,24(sp)
    80003020:	e822                	sd	s0,16(sp)
    80003022:	e426                	sd	s1,8(sp)
    80003024:	1000                	addi	s0,sp,32
    80003026:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003028:	0541                	addi	a0,a0,16
    8000302a:	00001097          	auipc	ra,0x1
    8000302e:	548080e7          	jalr	1352(ra) # 80004572 <holdingsleep>
    80003032:	cd09                	beqz	a0,8000304c <bwrite+0x30>
    panic("bwrite");
  virtio_disk_rw(b->dev, b, 1);
    80003034:	4605                	li	a2,1
    80003036:	85a6                	mv	a1,s1
    80003038:	4488                	lw	a0,8(s1)
    8000303a:	00003097          	auipc	ra,0x3
    8000303e:	1ca080e7          	jalr	458(ra) # 80006204 <virtio_disk_rw>
}
    80003042:	60e2                	ld	ra,24(sp)
    80003044:	6442                	ld	s0,16(sp)
    80003046:	64a2                	ld	s1,8(sp)
    80003048:	6105                	addi	sp,sp,32
    8000304a:	8082                	ret
    panic("bwrite");
    8000304c:	00007517          	auipc	a0,0x7
    80003050:	85450513          	addi	a0,a0,-1964 # 800098a0 <userret+0x810>
    80003054:	ffffd097          	auipc	ra,0xffffd
    80003058:	500080e7          	jalr	1280(ra) # 80000554 <panic>

000000008000305c <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    8000305c:	1101                	addi	sp,sp,-32
    8000305e:	ec06                	sd	ra,24(sp)
    80003060:	e822                	sd	s0,16(sp)
    80003062:	e426                	sd	s1,8(sp)
    80003064:	e04a                	sd	s2,0(sp)
    80003066:	1000                	addi	s0,sp,32
    80003068:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000306a:	01050913          	addi	s2,a0,16
    8000306e:	854a                	mv	a0,s2
    80003070:	00001097          	auipc	ra,0x1
    80003074:	502080e7          	jalr	1282(ra) # 80004572 <holdingsleep>
    80003078:	c92d                	beqz	a0,800030ea <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000307a:	854a                	mv	a0,s2
    8000307c:	00001097          	auipc	ra,0x1
    80003080:	4b2080e7          	jalr	1202(ra) # 8000452e <releasesleep>

  acquire(&bcache.lock);
    80003084:	00014517          	auipc	a0,0x14
    80003088:	a5c50513          	addi	a0,a0,-1444 # 80016ae0 <bcache>
    8000308c:	ffffe097          	auipc	ra,0xffffe
    80003090:	a14080e7          	jalr	-1516(ra) # 80000aa0 <acquire>
  b->refcnt--;
    80003094:	44bc                	lw	a5,72(s1)
    80003096:	37fd                	addiw	a5,a5,-1
    80003098:	0007871b          	sext.w	a4,a5
    8000309c:	c4bc                	sw	a5,72(s1)
  if (b->refcnt == 0) {
    8000309e:	eb05                	bnez	a4,800030ce <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800030a0:	6cbc                	ld	a5,88(s1)
    800030a2:	68b8                	ld	a4,80(s1)
    800030a4:	ebb8                	sd	a4,80(a5)
    b->prev->next = b->next;
    800030a6:	68bc                	ld	a5,80(s1)
    800030a8:	6cb8                	ld	a4,88(s1)
    800030aa:	efb8                	sd	a4,88(a5)
    b->next = bcache.head.next;
    800030ac:	0001c797          	auipc	a5,0x1c
    800030b0:	a3478793          	addi	a5,a5,-1484 # 8001eae0 <bcache+0x8000>
    800030b4:	3b87b703          	ld	a4,952(a5)
    800030b8:	ecb8                	sd	a4,88(s1)
    b->prev = &bcache.head;
    800030ba:	0001c717          	auipc	a4,0x1c
    800030be:	d8670713          	addi	a4,a4,-634 # 8001ee40 <bcache+0x8360>
    800030c2:	e8b8                	sd	a4,80(s1)
    bcache.head.next->prev = b;
    800030c4:	3b87b703          	ld	a4,952(a5)
    800030c8:	eb24                	sd	s1,80(a4)
    bcache.head.next = b;
    800030ca:	3a97bc23          	sd	s1,952(a5)
  }
  
  release(&bcache.lock);
    800030ce:	00014517          	auipc	a0,0x14
    800030d2:	a1250513          	addi	a0,a0,-1518 # 80016ae0 <bcache>
    800030d6:	ffffe097          	auipc	ra,0xffffe
    800030da:	a9a080e7          	jalr	-1382(ra) # 80000b70 <release>
}
    800030de:	60e2                	ld	ra,24(sp)
    800030e0:	6442                	ld	s0,16(sp)
    800030e2:	64a2                	ld	s1,8(sp)
    800030e4:	6902                	ld	s2,0(sp)
    800030e6:	6105                	addi	sp,sp,32
    800030e8:	8082                	ret
    panic("brelse");
    800030ea:	00006517          	auipc	a0,0x6
    800030ee:	7be50513          	addi	a0,a0,1982 # 800098a8 <userret+0x818>
    800030f2:	ffffd097          	auipc	ra,0xffffd
    800030f6:	462080e7          	jalr	1122(ra) # 80000554 <panic>

00000000800030fa <bpin>:

void
bpin(struct buf *b) {
    800030fa:	1101                	addi	sp,sp,-32
    800030fc:	ec06                	sd	ra,24(sp)
    800030fe:	e822                	sd	s0,16(sp)
    80003100:	e426                	sd	s1,8(sp)
    80003102:	1000                	addi	s0,sp,32
    80003104:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003106:	00014517          	auipc	a0,0x14
    8000310a:	9da50513          	addi	a0,a0,-1574 # 80016ae0 <bcache>
    8000310e:	ffffe097          	auipc	ra,0xffffe
    80003112:	992080e7          	jalr	-1646(ra) # 80000aa0 <acquire>
  b->refcnt++;
    80003116:	44bc                	lw	a5,72(s1)
    80003118:	2785                	addiw	a5,a5,1
    8000311a:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    8000311c:	00014517          	auipc	a0,0x14
    80003120:	9c450513          	addi	a0,a0,-1596 # 80016ae0 <bcache>
    80003124:	ffffe097          	auipc	ra,0xffffe
    80003128:	a4c080e7          	jalr	-1460(ra) # 80000b70 <release>
}
    8000312c:	60e2                	ld	ra,24(sp)
    8000312e:	6442                	ld	s0,16(sp)
    80003130:	64a2                	ld	s1,8(sp)
    80003132:	6105                	addi	sp,sp,32
    80003134:	8082                	ret

0000000080003136 <bunpin>:

void
bunpin(struct buf *b) {
    80003136:	1101                	addi	sp,sp,-32
    80003138:	ec06                	sd	ra,24(sp)
    8000313a:	e822                	sd	s0,16(sp)
    8000313c:	e426                	sd	s1,8(sp)
    8000313e:	1000                	addi	s0,sp,32
    80003140:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003142:	00014517          	auipc	a0,0x14
    80003146:	99e50513          	addi	a0,a0,-1634 # 80016ae0 <bcache>
    8000314a:	ffffe097          	auipc	ra,0xffffe
    8000314e:	956080e7          	jalr	-1706(ra) # 80000aa0 <acquire>
  b->refcnt--;
    80003152:	44bc                	lw	a5,72(s1)
    80003154:	37fd                	addiw	a5,a5,-1
    80003156:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    80003158:	00014517          	auipc	a0,0x14
    8000315c:	98850513          	addi	a0,a0,-1656 # 80016ae0 <bcache>
    80003160:	ffffe097          	auipc	ra,0xffffe
    80003164:	a10080e7          	jalr	-1520(ra) # 80000b70 <release>
}
    80003168:	60e2                	ld	ra,24(sp)
    8000316a:	6442                	ld	s0,16(sp)
    8000316c:	64a2                	ld	s1,8(sp)
    8000316e:	6105                	addi	sp,sp,32
    80003170:	8082                	ret

0000000080003172 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003172:	1101                	addi	sp,sp,-32
    80003174:	ec06                	sd	ra,24(sp)
    80003176:	e822                	sd	s0,16(sp)
    80003178:	e426                	sd	s1,8(sp)
    8000317a:	e04a                	sd	s2,0(sp)
    8000317c:	1000                	addi	s0,sp,32
    8000317e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003180:	00d5d59b          	srliw	a1,a1,0xd
    80003184:	0001c797          	auipc	a5,0x1c
    80003188:	1387a783          	lw	a5,312(a5) # 8001f2bc <sb+0x1c>
    8000318c:	9dbd                	addw	a1,a1,a5
    8000318e:	00000097          	auipc	ra,0x0
    80003192:	d9a080e7          	jalr	-614(ra) # 80002f28 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003196:	0074f713          	andi	a4,s1,7
    8000319a:	4785                	li	a5,1
    8000319c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800031a0:	14ce                	slli	s1,s1,0x33
    800031a2:	90d9                	srli	s1,s1,0x36
    800031a4:	00950733          	add	a4,a0,s1
    800031a8:	06074703          	lbu	a4,96(a4)
    800031ac:	00e7f6b3          	and	a3,a5,a4
    800031b0:	c69d                	beqz	a3,800031de <bfree+0x6c>
    800031b2:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800031b4:	94aa                	add	s1,s1,a0
    800031b6:	fff7c793          	not	a5,a5
    800031ba:	8ff9                	and	a5,a5,a4
    800031bc:	06f48023          	sb	a5,96(s1)
  log_write(bp);
    800031c0:	00001097          	auipc	ra,0x1
    800031c4:	19e080e7          	jalr	414(ra) # 8000435e <log_write>
  brelse(bp);
    800031c8:	854a                	mv	a0,s2
    800031ca:	00000097          	auipc	ra,0x0
    800031ce:	e92080e7          	jalr	-366(ra) # 8000305c <brelse>
}
    800031d2:	60e2                	ld	ra,24(sp)
    800031d4:	6442                	ld	s0,16(sp)
    800031d6:	64a2                	ld	s1,8(sp)
    800031d8:	6902                	ld	s2,0(sp)
    800031da:	6105                	addi	sp,sp,32
    800031dc:	8082                	ret
    panic("freeing free block");
    800031de:	00006517          	auipc	a0,0x6
    800031e2:	6d250513          	addi	a0,a0,1746 # 800098b0 <userret+0x820>
    800031e6:	ffffd097          	auipc	ra,0xffffd
    800031ea:	36e080e7          	jalr	878(ra) # 80000554 <panic>

00000000800031ee <balloc>:
{
    800031ee:	711d                	addi	sp,sp,-96
    800031f0:	ec86                	sd	ra,88(sp)
    800031f2:	e8a2                	sd	s0,80(sp)
    800031f4:	e4a6                	sd	s1,72(sp)
    800031f6:	e0ca                	sd	s2,64(sp)
    800031f8:	fc4e                	sd	s3,56(sp)
    800031fa:	f852                	sd	s4,48(sp)
    800031fc:	f456                	sd	s5,40(sp)
    800031fe:	f05a                	sd	s6,32(sp)
    80003200:	ec5e                	sd	s7,24(sp)
    80003202:	e862                	sd	s8,16(sp)
    80003204:	e466                	sd	s9,8(sp)
    80003206:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003208:	0001c797          	auipc	a5,0x1c
    8000320c:	09c7a783          	lw	a5,156(a5) # 8001f2a4 <sb+0x4>
    80003210:	cbd1                	beqz	a5,800032a4 <balloc+0xb6>
    80003212:	8baa                	mv	s7,a0
    80003214:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003216:	0001cb17          	auipc	s6,0x1c
    8000321a:	08ab0b13          	addi	s6,s6,138 # 8001f2a0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000321e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003220:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003222:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003224:	6c89                	lui	s9,0x2
    80003226:	a831                	j	80003242 <balloc+0x54>
    brelse(bp);
    80003228:	854a                	mv	a0,s2
    8000322a:	00000097          	auipc	ra,0x0
    8000322e:	e32080e7          	jalr	-462(ra) # 8000305c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003232:	015c87bb          	addw	a5,s9,s5
    80003236:	00078a9b          	sext.w	s5,a5
    8000323a:	004b2703          	lw	a4,4(s6)
    8000323e:	06eaf363          	bgeu	s5,a4,800032a4 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003242:	41fad79b          	sraiw	a5,s5,0x1f
    80003246:	0137d79b          	srliw	a5,a5,0x13
    8000324a:	015787bb          	addw	a5,a5,s5
    8000324e:	40d7d79b          	sraiw	a5,a5,0xd
    80003252:	01cb2583          	lw	a1,28(s6)
    80003256:	9dbd                	addw	a1,a1,a5
    80003258:	855e                	mv	a0,s7
    8000325a:	00000097          	auipc	ra,0x0
    8000325e:	cce080e7          	jalr	-818(ra) # 80002f28 <bread>
    80003262:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003264:	004b2503          	lw	a0,4(s6)
    80003268:	000a849b          	sext.w	s1,s5
    8000326c:	8662                	mv	a2,s8
    8000326e:	faa4fde3          	bgeu	s1,a0,80003228 <balloc+0x3a>
      m = 1 << (bi % 8);
    80003272:	41f6579b          	sraiw	a5,a2,0x1f
    80003276:	01d7d69b          	srliw	a3,a5,0x1d
    8000327a:	00c6873b          	addw	a4,a3,a2
    8000327e:	00777793          	andi	a5,a4,7
    80003282:	9f95                	subw	a5,a5,a3
    80003284:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003288:	4037571b          	sraiw	a4,a4,0x3
    8000328c:	00e906b3          	add	a3,s2,a4
    80003290:	0606c683          	lbu	a3,96(a3)
    80003294:	00d7f5b3          	and	a1,a5,a3
    80003298:	cd91                	beqz	a1,800032b4 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000329a:	2605                	addiw	a2,a2,1
    8000329c:	2485                	addiw	s1,s1,1
    8000329e:	fd4618e3          	bne	a2,s4,8000326e <balloc+0x80>
    800032a2:	b759                	j	80003228 <balloc+0x3a>
  panic("balloc: out of blocks");
    800032a4:	00006517          	auipc	a0,0x6
    800032a8:	62450513          	addi	a0,a0,1572 # 800098c8 <userret+0x838>
    800032ac:	ffffd097          	auipc	ra,0xffffd
    800032b0:	2a8080e7          	jalr	680(ra) # 80000554 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800032b4:	974a                	add	a4,a4,s2
    800032b6:	8fd5                	or	a5,a5,a3
    800032b8:	06f70023          	sb	a5,96(a4)
        log_write(bp);
    800032bc:	854a                	mv	a0,s2
    800032be:	00001097          	auipc	ra,0x1
    800032c2:	0a0080e7          	jalr	160(ra) # 8000435e <log_write>
        brelse(bp);
    800032c6:	854a                	mv	a0,s2
    800032c8:	00000097          	auipc	ra,0x0
    800032cc:	d94080e7          	jalr	-620(ra) # 8000305c <brelse>
  bp = bread(dev, bno);
    800032d0:	85a6                	mv	a1,s1
    800032d2:	855e                	mv	a0,s7
    800032d4:	00000097          	auipc	ra,0x0
    800032d8:	c54080e7          	jalr	-940(ra) # 80002f28 <bread>
    800032dc:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800032de:	40000613          	li	a2,1024
    800032e2:	4581                	li	a1,0
    800032e4:	06050513          	addi	a0,a0,96
    800032e8:	ffffe097          	auipc	ra,0xffffe
    800032ec:	a86080e7          	jalr	-1402(ra) # 80000d6e <memset>
  log_write(bp);
    800032f0:	854a                	mv	a0,s2
    800032f2:	00001097          	auipc	ra,0x1
    800032f6:	06c080e7          	jalr	108(ra) # 8000435e <log_write>
  brelse(bp);
    800032fa:	854a                	mv	a0,s2
    800032fc:	00000097          	auipc	ra,0x0
    80003300:	d60080e7          	jalr	-672(ra) # 8000305c <brelse>
}
    80003304:	8526                	mv	a0,s1
    80003306:	60e6                	ld	ra,88(sp)
    80003308:	6446                	ld	s0,80(sp)
    8000330a:	64a6                	ld	s1,72(sp)
    8000330c:	6906                	ld	s2,64(sp)
    8000330e:	79e2                	ld	s3,56(sp)
    80003310:	7a42                	ld	s4,48(sp)
    80003312:	7aa2                	ld	s5,40(sp)
    80003314:	7b02                	ld	s6,32(sp)
    80003316:	6be2                	ld	s7,24(sp)
    80003318:	6c42                	ld	s8,16(sp)
    8000331a:	6ca2                	ld	s9,8(sp)
    8000331c:	6125                	addi	sp,sp,96
    8000331e:	8082                	ret

0000000080003320 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003320:	7179                	addi	sp,sp,-48
    80003322:	f406                	sd	ra,40(sp)
    80003324:	f022                	sd	s0,32(sp)
    80003326:	ec26                	sd	s1,24(sp)
    80003328:	e84a                	sd	s2,16(sp)
    8000332a:	e44e                	sd	s3,8(sp)
    8000332c:	e052                	sd	s4,0(sp)
    8000332e:	1800                	addi	s0,sp,48
    80003330:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003332:	47ad                	li	a5,11
    80003334:	04b7fe63          	bgeu	a5,a1,80003390 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003338:	ff45849b          	addiw	s1,a1,-12
    8000333c:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003340:	0ff00793          	li	a5,255
    80003344:	0ae7e363          	bltu	a5,a4,800033ea <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003348:	08852583          	lw	a1,136(a0)
    8000334c:	c5ad                	beqz	a1,800033b6 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    8000334e:	00092503          	lw	a0,0(s2)
    80003352:	00000097          	auipc	ra,0x0
    80003356:	bd6080e7          	jalr	-1066(ra) # 80002f28 <bread>
    8000335a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000335c:	06050793          	addi	a5,a0,96
    if((addr = a[bn]) == 0){
    80003360:	02049593          	slli	a1,s1,0x20
    80003364:	9181                	srli	a1,a1,0x20
    80003366:	058a                	slli	a1,a1,0x2
    80003368:	00b784b3          	add	s1,a5,a1
    8000336c:	0004a983          	lw	s3,0(s1)
    80003370:	04098d63          	beqz	s3,800033ca <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003374:	8552                	mv	a0,s4
    80003376:	00000097          	auipc	ra,0x0
    8000337a:	ce6080e7          	jalr	-794(ra) # 8000305c <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000337e:	854e                	mv	a0,s3
    80003380:	70a2                	ld	ra,40(sp)
    80003382:	7402                	ld	s0,32(sp)
    80003384:	64e2                	ld	s1,24(sp)
    80003386:	6942                	ld	s2,16(sp)
    80003388:	69a2                	ld	s3,8(sp)
    8000338a:	6a02                	ld	s4,0(sp)
    8000338c:	6145                	addi	sp,sp,48
    8000338e:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003390:	02059493          	slli	s1,a1,0x20
    80003394:	9081                	srli	s1,s1,0x20
    80003396:	048a                	slli	s1,s1,0x2
    80003398:	94aa                	add	s1,s1,a0
    8000339a:	0584a983          	lw	s3,88(s1)
    8000339e:	fe0990e3          	bnez	s3,8000337e <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800033a2:	4108                	lw	a0,0(a0)
    800033a4:	00000097          	auipc	ra,0x0
    800033a8:	e4a080e7          	jalr	-438(ra) # 800031ee <balloc>
    800033ac:	0005099b          	sext.w	s3,a0
    800033b0:	0534ac23          	sw	s3,88(s1)
    800033b4:	b7e9                	j	8000337e <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800033b6:	4108                	lw	a0,0(a0)
    800033b8:	00000097          	auipc	ra,0x0
    800033bc:	e36080e7          	jalr	-458(ra) # 800031ee <balloc>
    800033c0:	0005059b          	sext.w	a1,a0
    800033c4:	08b92423          	sw	a1,136(s2)
    800033c8:	b759                	j	8000334e <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800033ca:	00092503          	lw	a0,0(s2)
    800033ce:	00000097          	auipc	ra,0x0
    800033d2:	e20080e7          	jalr	-480(ra) # 800031ee <balloc>
    800033d6:	0005099b          	sext.w	s3,a0
    800033da:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800033de:	8552                	mv	a0,s4
    800033e0:	00001097          	auipc	ra,0x1
    800033e4:	f7e080e7          	jalr	-130(ra) # 8000435e <log_write>
    800033e8:	b771                	j	80003374 <bmap+0x54>
  panic("bmap: out of range");
    800033ea:	00006517          	auipc	a0,0x6
    800033ee:	4f650513          	addi	a0,a0,1270 # 800098e0 <userret+0x850>
    800033f2:	ffffd097          	auipc	ra,0xffffd
    800033f6:	162080e7          	jalr	354(ra) # 80000554 <panic>

00000000800033fa <iget>:
{
    800033fa:	7179                	addi	sp,sp,-48
    800033fc:	f406                	sd	ra,40(sp)
    800033fe:	f022                	sd	s0,32(sp)
    80003400:	ec26                	sd	s1,24(sp)
    80003402:	e84a                	sd	s2,16(sp)
    80003404:	e44e                	sd	s3,8(sp)
    80003406:	e052                	sd	s4,0(sp)
    80003408:	1800                	addi	s0,sp,48
    8000340a:	89aa                	mv	s3,a0
    8000340c:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    8000340e:	0001c517          	auipc	a0,0x1c
    80003412:	eb250513          	addi	a0,a0,-334 # 8001f2c0 <icache>
    80003416:	ffffd097          	auipc	ra,0xffffd
    8000341a:	68a080e7          	jalr	1674(ra) # 80000aa0 <acquire>
  empty = 0;
    8000341e:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003420:	0001c497          	auipc	s1,0x1c
    80003424:	ec048493          	addi	s1,s1,-320 # 8001f2e0 <icache+0x20>
    80003428:	0001e697          	auipc	a3,0x1e
    8000342c:	ad868693          	addi	a3,a3,-1320 # 80020f00 <log>
    80003430:	a039                	j	8000343e <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003432:	02090b63          	beqz	s2,80003468 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003436:	09048493          	addi	s1,s1,144
    8000343a:	02d48a63          	beq	s1,a3,8000346e <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000343e:	449c                	lw	a5,8(s1)
    80003440:	fef059e3          	blez	a5,80003432 <iget+0x38>
    80003444:	4098                	lw	a4,0(s1)
    80003446:	ff3716e3          	bne	a4,s3,80003432 <iget+0x38>
    8000344a:	40d8                	lw	a4,4(s1)
    8000344c:	ff4713e3          	bne	a4,s4,80003432 <iget+0x38>
      ip->ref++;
    80003450:	2785                	addiw	a5,a5,1
    80003452:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003454:	0001c517          	auipc	a0,0x1c
    80003458:	e6c50513          	addi	a0,a0,-404 # 8001f2c0 <icache>
    8000345c:	ffffd097          	auipc	ra,0xffffd
    80003460:	714080e7          	jalr	1812(ra) # 80000b70 <release>
      return ip;
    80003464:	8926                	mv	s2,s1
    80003466:	a03d                	j	80003494 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003468:	f7f9                	bnez	a5,80003436 <iget+0x3c>
    8000346a:	8926                	mv	s2,s1
    8000346c:	b7e9                	j	80003436 <iget+0x3c>
  if(empty == 0)
    8000346e:	02090c63          	beqz	s2,800034a6 <iget+0xac>
  ip->dev = dev;
    80003472:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003476:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000347a:	4785                	li	a5,1
    8000347c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003480:	04092423          	sw	zero,72(s2)
  release(&icache.lock);
    80003484:	0001c517          	auipc	a0,0x1c
    80003488:	e3c50513          	addi	a0,a0,-452 # 8001f2c0 <icache>
    8000348c:	ffffd097          	auipc	ra,0xffffd
    80003490:	6e4080e7          	jalr	1764(ra) # 80000b70 <release>
}
    80003494:	854a                	mv	a0,s2
    80003496:	70a2                	ld	ra,40(sp)
    80003498:	7402                	ld	s0,32(sp)
    8000349a:	64e2                	ld	s1,24(sp)
    8000349c:	6942                	ld	s2,16(sp)
    8000349e:	69a2                	ld	s3,8(sp)
    800034a0:	6a02                	ld	s4,0(sp)
    800034a2:	6145                	addi	sp,sp,48
    800034a4:	8082                	ret
    panic("iget: no inodes");
    800034a6:	00006517          	auipc	a0,0x6
    800034aa:	45250513          	addi	a0,a0,1106 # 800098f8 <userret+0x868>
    800034ae:	ffffd097          	auipc	ra,0xffffd
    800034b2:	0a6080e7          	jalr	166(ra) # 80000554 <panic>

00000000800034b6 <fsinit>:
fsinit(int dev) {
    800034b6:	7179                	addi	sp,sp,-48
    800034b8:	f406                	sd	ra,40(sp)
    800034ba:	f022                	sd	s0,32(sp)
    800034bc:	ec26                	sd	s1,24(sp)
    800034be:	e84a                	sd	s2,16(sp)
    800034c0:	e44e                	sd	s3,8(sp)
    800034c2:	1800                	addi	s0,sp,48
    800034c4:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800034c6:	4585                	li	a1,1
    800034c8:	00000097          	auipc	ra,0x0
    800034cc:	a60080e7          	jalr	-1440(ra) # 80002f28 <bread>
    800034d0:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800034d2:	0001c997          	auipc	s3,0x1c
    800034d6:	dce98993          	addi	s3,s3,-562 # 8001f2a0 <sb>
    800034da:	02000613          	li	a2,32
    800034de:	06050593          	addi	a1,a0,96
    800034e2:	854e                	mv	a0,s3
    800034e4:	ffffe097          	auipc	ra,0xffffe
    800034e8:	8e6080e7          	jalr	-1818(ra) # 80000dca <memmove>
  brelse(bp);
    800034ec:	8526                	mv	a0,s1
    800034ee:	00000097          	auipc	ra,0x0
    800034f2:	b6e080e7          	jalr	-1170(ra) # 8000305c <brelse>
  if(sb.magic != FSMAGIC)
    800034f6:	0009a703          	lw	a4,0(s3)
    800034fa:	102037b7          	lui	a5,0x10203
    800034fe:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003502:	02f71263          	bne	a4,a5,80003526 <fsinit+0x70>
  initlog(dev, &sb);
    80003506:	0001c597          	auipc	a1,0x1c
    8000350a:	d9a58593          	addi	a1,a1,-614 # 8001f2a0 <sb>
    8000350e:	854a                	mv	a0,s2
    80003510:	00001097          	auipc	ra,0x1
    80003514:	b38080e7          	jalr	-1224(ra) # 80004048 <initlog>
}
    80003518:	70a2                	ld	ra,40(sp)
    8000351a:	7402                	ld	s0,32(sp)
    8000351c:	64e2                	ld	s1,24(sp)
    8000351e:	6942                	ld	s2,16(sp)
    80003520:	69a2                	ld	s3,8(sp)
    80003522:	6145                	addi	sp,sp,48
    80003524:	8082                	ret
    panic("invalid file system");
    80003526:	00006517          	auipc	a0,0x6
    8000352a:	3e250513          	addi	a0,a0,994 # 80009908 <userret+0x878>
    8000352e:	ffffd097          	auipc	ra,0xffffd
    80003532:	026080e7          	jalr	38(ra) # 80000554 <panic>

0000000080003536 <iinit>:
{
    80003536:	7179                	addi	sp,sp,-48
    80003538:	f406                	sd	ra,40(sp)
    8000353a:	f022                	sd	s0,32(sp)
    8000353c:	ec26                	sd	s1,24(sp)
    8000353e:	e84a                	sd	s2,16(sp)
    80003540:	e44e                	sd	s3,8(sp)
    80003542:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003544:	00006597          	auipc	a1,0x6
    80003548:	3dc58593          	addi	a1,a1,988 # 80009920 <userret+0x890>
    8000354c:	0001c517          	auipc	a0,0x1c
    80003550:	d7450513          	addi	a0,a0,-652 # 8001f2c0 <icache>
    80003554:	ffffd097          	auipc	ra,0xffffd
    80003558:	478080e7          	jalr	1144(ra) # 800009cc <initlock>
  for(i = 0; i < NINODE; i++) {
    8000355c:	0001c497          	auipc	s1,0x1c
    80003560:	d9448493          	addi	s1,s1,-620 # 8001f2f0 <icache+0x30>
    80003564:	0001e997          	auipc	s3,0x1e
    80003568:	9ac98993          	addi	s3,s3,-1620 # 80020f10 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    8000356c:	00006917          	auipc	s2,0x6
    80003570:	3bc90913          	addi	s2,s2,956 # 80009928 <userret+0x898>
    80003574:	85ca                	mv	a1,s2
    80003576:	8526                	mv	a0,s1
    80003578:	00001097          	auipc	ra,0x1
    8000357c:	f26080e7          	jalr	-218(ra) # 8000449e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003580:	09048493          	addi	s1,s1,144
    80003584:	ff3498e3          	bne	s1,s3,80003574 <iinit+0x3e>
}
    80003588:	70a2                	ld	ra,40(sp)
    8000358a:	7402                	ld	s0,32(sp)
    8000358c:	64e2                	ld	s1,24(sp)
    8000358e:	6942                	ld	s2,16(sp)
    80003590:	69a2                	ld	s3,8(sp)
    80003592:	6145                	addi	sp,sp,48
    80003594:	8082                	ret

0000000080003596 <ialloc>:
{
    80003596:	715d                	addi	sp,sp,-80
    80003598:	e486                	sd	ra,72(sp)
    8000359a:	e0a2                	sd	s0,64(sp)
    8000359c:	fc26                	sd	s1,56(sp)
    8000359e:	f84a                	sd	s2,48(sp)
    800035a0:	f44e                	sd	s3,40(sp)
    800035a2:	f052                	sd	s4,32(sp)
    800035a4:	ec56                	sd	s5,24(sp)
    800035a6:	e85a                	sd	s6,16(sp)
    800035a8:	e45e                	sd	s7,8(sp)
    800035aa:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800035ac:	0001c717          	auipc	a4,0x1c
    800035b0:	d0072703          	lw	a4,-768(a4) # 8001f2ac <sb+0xc>
    800035b4:	4785                	li	a5,1
    800035b6:	04e7fa63          	bgeu	a5,a4,8000360a <ialloc+0x74>
    800035ba:	8aaa                	mv	s5,a0
    800035bc:	8bae                	mv	s7,a1
    800035be:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800035c0:	0001ca17          	auipc	s4,0x1c
    800035c4:	ce0a0a13          	addi	s4,s4,-800 # 8001f2a0 <sb>
    800035c8:	00048b1b          	sext.w	s6,s1
    800035cc:	0044d793          	srli	a5,s1,0x4
    800035d0:	018a2583          	lw	a1,24(s4)
    800035d4:	9dbd                	addw	a1,a1,a5
    800035d6:	8556                	mv	a0,s5
    800035d8:	00000097          	auipc	ra,0x0
    800035dc:	950080e7          	jalr	-1712(ra) # 80002f28 <bread>
    800035e0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800035e2:	06050993          	addi	s3,a0,96
    800035e6:	00f4f793          	andi	a5,s1,15
    800035ea:	079a                	slli	a5,a5,0x6
    800035ec:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800035ee:	00099783          	lh	a5,0(s3)
    800035f2:	c785                	beqz	a5,8000361a <ialloc+0x84>
    brelse(bp);
    800035f4:	00000097          	auipc	ra,0x0
    800035f8:	a68080e7          	jalr	-1432(ra) # 8000305c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800035fc:	0485                	addi	s1,s1,1
    800035fe:	00ca2703          	lw	a4,12(s4)
    80003602:	0004879b          	sext.w	a5,s1
    80003606:	fce7e1e3          	bltu	a5,a4,800035c8 <ialloc+0x32>
  panic("ialloc: no inodes");
    8000360a:	00006517          	auipc	a0,0x6
    8000360e:	32650513          	addi	a0,a0,806 # 80009930 <userret+0x8a0>
    80003612:	ffffd097          	auipc	ra,0xffffd
    80003616:	f42080e7          	jalr	-190(ra) # 80000554 <panic>
      memset(dip, 0, sizeof(*dip));
    8000361a:	04000613          	li	a2,64
    8000361e:	4581                	li	a1,0
    80003620:	854e                	mv	a0,s3
    80003622:	ffffd097          	auipc	ra,0xffffd
    80003626:	74c080e7          	jalr	1868(ra) # 80000d6e <memset>
      dip->type = type;
    8000362a:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000362e:	854a                	mv	a0,s2
    80003630:	00001097          	auipc	ra,0x1
    80003634:	d2e080e7          	jalr	-722(ra) # 8000435e <log_write>
      brelse(bp);
    80003638:	854a                	mv	a0,s2
    8000363a:	00000097          	auipc	ra,0x0
    8000363e:	a22080e7          	jalr	-1502(ra) # 8000305c <brelse>
      return iget(dev, inum);
    80003642:	85da                	mv	a1,s6
    80003644:	8556                	mv	a0,s5
    80003646:	00000097          	auipc	ra,0x0
    8000364a:	db4080e7          	jalr	-588(ra) # 800033fa <iget>
}
    8000364e:	60a6                	ld	ra,72(sp)
    80003650:	6406                	ld	s0,64(sp)
    80003652:	74e2                	ld	s1,56(sp)
    80003654:	7942                	ld	s2,48(sp)
    80003656:	79a2                	ld	s3,40(sp)
    80003658:	7a02                	ld	s4,32(sp)
    8000365a:	6ae2                	ld	s5,24(sp)
    8000365c:	6b42                	ld	s6,16(sp)
    8000365e:	6ba2                	ld	s7,8(sp)
    80003660:	6161                	addi	sp,sp,80
    80003662:	8082                	ret

0000000080003664 <iupdate>:
{
    80003664:	1101                	addi	sp,sp,-32
    80003666:	ec06                	sd	ra,24(sp)
    80003668:	e822                	sd	s0,16(sp)
    8000366a:	e426                	sd	s1,8(sp)
    8000366c:	e04a                	sd	s2,0(sp)
    8000366e:	1000                	addi	s0,sp,32
    80003670:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003672:	415c                	lw	a5,4(a0)
    80003674:	0047d79b          	srliw	a5,a5,0x4
    80003678:	0001c597          	auipc	a1,0x1c
    8000367c:	c405a583          	lw	a1,-960(a1) # 8001f2b8 <sb+0x18>
    80003680:	9dbd                	addw	a1,a1,a5
    80003682:	4108                	lw	a0,0(a0)
    80003684:	00000097          	auipc	ra,0x0
    80003688:	8a4080e7          	jalr	-1884(ra) # 80002f28 <bread>
    8000368c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000368e:	06050793          	addi	a5,a0,96
    80003692:	40c8                	lw	a0,4(s1)
    80003694:	893d                	andi	a0,a0,15
    80003696:	051a                	slli	a0,a0,0x6
    80003698:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000369a:	04c49703          	lh	a4,76(s1)
    8000369e:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800036a2:	04e49703          	lh	a4,78(s1)
    800036a6:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800036aa:	05049703          	lh	a4,80(s1)
    800036ae:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800036b2:	05249703          	lh	a4,82(s1)
    800036b6:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800036ba:	48f8                	lw	a4,84(s1)
    800036bc:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800036be:	03400613          	li	a2,52
    800036c2:	05848593          	addi	a1,s1,88
    800036c6:	0531                	addi	a0,a0,12
    800036c8:	ffffd097          	auipc	ra,0xffffd
    800036cc:	702080e7          	jalr	1794(ra) # 80000dca <memmove>
  log_write(bp);
    800036d0:	854a                	mv	a0,s2
    800036d2:	00001097          	auipc	ra,0x1
    800036d6:	c8c080e7          	jalr	-884(ra) # 8000435e <log_write>
  brelse(bp);
    800036da:	854a                	mv	a0,s2
    800036dc:	00000097          	auipc	ra,0x0
    800036e0:	980080e7          	jalr	-1664(ra) # 8000305c <brelse>
}
    800036e4:	60e2                	ld	ra,24(sp)
    800036e6:	6442                	ld	s0,16(sp)
    800036e8:	64a2                	ld	s1,8(sp)
    800036ea:	6902                	ld	s2,0(sp)
    800036ec:	6105                	addi	sp,sp,32
    800036ee:	8082                	ret

00000000800036f0 <idup>:
{
    800036f0:	1101                	addi	sp,sp,-32
    800036f2:	ec06                	sd	ra,24(sp)
    800036f4:	e822                	sd	s0,16(sp)
    800036f6:	e426                	sd	s1,8(sp)
    800036f8:	1000                	addi	s0,sp,32
    800036fa:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800036fc:	0001c517          	auipc	a0,0x1c
    80003700:	bc450513          	addi	a0,a0,-1084 # 8001f2c0 <icache>
    80003704:	ffffd097          	auipc	ra,0xffffd
    80003708:	39c080e7          	jalr	924(ra) # 80000aa0 <acquire>
  ip->ref++;
    8000370c:	449c                	lw	a5,8(s1)
    8000370e:	2785                	addiw	a5,a5,1
    80003710:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003712:	0001c517          	auipc	a0,0x1c
    80003716:	bae50513          	addi	a0,a0,-1106 # 8001f2c0 <icache>
    8000371a:	ffffd097          	auipc	ra,0xffffd
    8000371e:	456080e7          	jalr	1110(ra) # 80000b70 <release>
}
    80003722:	8526                	mv	a0,s1
    80003724:	60e2                	ld	ra,24(sp)
    80003726:	6442                	ld	s0,16(sp)
    80003728:	64a2                	ld	s1,8(sp)
    8000372a:	6105                	addi	sp,sp,32
    8000372c:	8082                	ret

000000008000372e <ilock>:
{
    8000372e:	1101                	addi	sp,sp,-32
    80003730:	ec06                	sd	ra,24(sp)
    80003732:	e822                	sd	s0,16(sp)
    80003734:	e426                	sd	s1,8(sp)
    80003736:	e04a                	sd	s2,0(sp)
    80003738:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000373a:	c115                	beqz	a0,8000375e <ilock+0x30>
    8000373c:	84aa                	mv	s1,a0
    8000373e:	451c                	lw	a5,8(a0)
    80003740:	00f05f63          	blez	a5,8000375e <ilock+0x30>
  acquiresleep(&ip->lock);
    80003744:	0541                	addi	a0,a0,16
    80003746:	00001097          	auipc	ra,0x1
    8000374a:	d92080e7          	jalr	-622(ra) # 800044d8 <acquiresleep>
  if(ip->valid == 0){
    8000374e:	44bc                	lw	a5,72(s1)
    80003750:	cf99                	beqz	a5,8000376e <ilock+0x40>
}
    80003752:	60e2                	ld	ra,24(sp)
    80003754:	6442                	ld	s0,16(sp)
    80003756:	64a2                	ld	s1,8(sp)
    80003758:	6902                	ld	s2,0(sp)
    8000375a:	6105                	addi	sp,sp,32
    8000375c:	8082                	ret
    panic("ilock");
    8000375e:	00006517          	auipc	a0,0x6
    80003762:	1ea50513          	addi	a0,a0,490 # 80009948 <userret+0x8b8>
    80003766:	ffffd097          	auipc	ra,0xffffd
    8000376a:	dee080e7          	jalr	-530(ra) # 80000554 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000376e:	40dc                	lw	a5,4(s1)
    80003770:	0047d79b          	srliw	a5,a5,0x4
    80003774:	0001c597          	auipc	a1,0x1c
    80003778:	b445a583          	lw	a1,-1212(a1) # 8001f2b8 <sb+0x18>
    8000377c:	9dbd                	addw	a1,a1,a5
    8000377e:	4088                	lw	a0,0(s1)
    80003780:	fffff097          	auipc	ra,0xfffff
    80003784:	7a8080e7          	jalr	1960(ra) # 80002f28 <bread>
    80003788:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000378a:	06050593          	addi	a1,a0,96
    8000378e:	40dc                	lw	a5,4(s1)
    80003790:	8bbd                	andi	a5,a5,15
    80003792:	079a                	slli	a5,a5,0x6
    80003794:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003796:	00059783          	lh	a5,0(a1)
    8000379a:	04f49623          	sh	a5,76(s1)
    ip->major = dip->major;
    8000379e:	00259783          	lh	a5,2(a1)
    800037a2:	04f49723          	sh	a5,78(s1)
    ip->minor = dip->minor;
    800037a6:	00459783          	lh	a5,4(a1)
    800037aa:	04f49823          	sh	a5,80(s1)
    ip->nlink = dip->nlink;
    800037ae:	00659783          	lh	a5,6(a1)
    800037b2:	04f49923          	sh	a5,82(s1)
    ip->size = dip->size;
    800037b6:	459c                	lw	a5,8(a1)
    800037b8:	c8fc                	sw	a5,84(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800037ba:	03400613          	li	a2,52
    800037be:	05b1                	addi	a1,a1,12
    800037c0:	05848513          	addi	a0,s1,88
    800037c4:	ffffd097          	auipc	ra,0xffffd
    800037c8:	606080e7          	jalr	1542(ra) # 80000dca <memmove>
    brelse(bp);
    800037cc:	854a                	mv	a0,s2
    800037ce:	00000097          	auipc	ra,0x0
    800037d2:	88e080e7          	jalr	-1906(ra) # 8000305c <brelse>
    ip->valid = 1;
    800037d6:	4785                	li	a5,1
    800037d8:	c4bc                	sw	a5,72(s1)
    if(ip->type == 0)
    800037da:	04c49783          	lh	a5,76(s1)
    800037de:	fbb5                	bnez	a5,80003752 <ilock+0x24>
      panic("ilock: no type");
    800037e0:	00006517          	auipc	a0,0x6
    800037e4:	17050513          	addi	a0,a0,368 # 80009950 <userret+0x8c0>
    800037e8:	ffffd097          	auipc	ra,0xffffd
    800037ec:	d6c080e7          	jalr	-660(ra) # 80000554 <panic>

00000000800037f0 <iunlock>:
{
    800037f0:	1101                	addi	sp,sp,-32
    800037f2:	ec06                	sd	ra,24(sp)
    800037f4:	e822                	sd	s0,16(sp)
    800037f6:	e426                	sd	s1,8(sp)
    800037f8:	e04a                	sd	s2,0(sp)
    800037fa:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800037fc:	c905                	beqz	a0,8000382c <iunlock+0x3c>
    800037fe:	84aa                	mv	s1,a0
    80003800:	01050913          	addi	s2,a0,16
    80003804:	854a                	mv	a0,s2
    80003806:	00001097          	auipc	ra,0x1
    8000380a:	d6c080e7          	jalr	-660(ra) # 80004572 <holdingsleep>
    8000380e:	cd19                	beqz	a0,8000382c <iunlock+0x3c>
    80003810:	449c                	lw	a5,8(s1)
    80003812:	00f05d63          	blez	a5,8000382c <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003816:	854a                	mv	a0,s2
    80003818:	00001097          	auipc	ra,0x1
    8000381c:	d16080e7          	jalr	-746(ra) # 8000452e <releasesleep>
}
    80003820:	60e2                	ld	ra,24(sp)
    80003822:	6442                	ld	s0,16(sp)
    80003824:	64a2                	ld	s1,8(sp)
    80003826:	6902                	ld	s2,0(sp)
    80003828:	6105                	addi	sp,sp,32
    8000382a:	8082                	ret
    panic("iunlock");
    8000382c:	00006517          	auipc	a0,0x6
    80003830:	13450513          	addi	a0,a0,308 # 80009960 <userret+0x8d0>
    80003834:	ffffd097          	auipc	ra,0xffffd
    80003838:	d20080e7          	jalr	-736(ra) # 80000554 <panic>

000000008000383c <iput>:
{
    8000383c:	7139                	addi	sp,sp,-64
    8000383e:	fc06                	sd	ra,56(sp)
    80003840:	f822                	sd	s0,48(sp)
    80003842:	f426                	sd	s1,40(sp)
    80003844:	f04a                	sd	s2,32(sp)
    80003846:	ec4e                	sd	s3,24(sp)
    80003848:	e852                	sd	s4,16(sp)
    8000384a:	e456                	sd	s5,8(sp)
    8000384c:	0080                	addi	s0,sp,64
    8000384e:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003850:	0001c517          	auipc	a0,0x1c
    80003854:	a7050513          	addi	a0,a0,-1424 # 8001f2c0 <icache>
    80003858:	ffffd097          	auipc	ra,0xffffd
    8000385c:	248080e7          	jalr	584(ra) # 80000aa0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003860:	4498                	lw	a4,8(s1)
    80003862:	4785                	li	a5,1
    80003864:	02f70663          	beq	a4,a5,80003890 <iput+0x54>
  ip->ref--;
    80003868:	449c                	lw	a5,8(s1)
    8000386a:	37fd                	addiw	a5,a5,-1
    8000386c:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    8000386e:	0001c517          	auipc	a0,0x1c
    80003872:	a5250513          	addi	a0,a0,-1454 # 8001f2c0 <icache>
    80003876:	ffffd097          	auipc	ra,0xffffd
    8000387a:	2fa080e7          	jalr	762(ra) # 80000b70 <release>
}
    8000387e:	70e2                	ld	ra,56(sp)
    80003880:	7442                	ld	s0,48(sp)
    80003882:	74a2                	ld	s1,40(sp)
    80003884:	7902                	ld	s2,32(sp)
    80003886:	69e2                	ld	s3,24(sp)
    80003888:	6a42                	ld	s4,16(sp)
    8000388a:	6aa2                	ld	s5,8(sp)
    8000388c:	6121                	addi	sp,sp,64
    8000388e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003890:	44bc                	lw	a5,72(s1)
    80003892:	dbf9                	beqz	a5,80003868 <iput+0x2c>
    80003894:	05249783          	lh	a5,82(s1)
    80003898:	fbe1                	bnez	a5,80003868 <iput+0x2c>
    acquiresleep(&ip->lock);
    8000389a:	01048a13          	addi	s4,s1,16
    8000389e:	8552                	mv	a0,s4
    800038a0:	00001097          	auipc	ra,0x1
    800038a4:	c38080e7          	jalr	-968(ra) # 800044d8 <acquiresleep>
    release(&icache.lock);
    800038a8:	0001c517          	auipc	a0,0x1c
    800038ac:	a1850513          	addi	a0,a0,-1512 # 8001f2c0 <icache>
    800038b0:	ffffd097          	auipc	ra,0xffffd
    800038b4:	2c0080e7          	jalr	704(ra) # 80000b70 <release>
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800038b8:	05848913          	addi	s2,s1,88
    800038bc:	08848993          	addi	s3,s1,136
    800038c0:	a021                	j	800038c8 <iput+0x8c>
    800038c2:	0911                	addi	s2,s2,4
    800038c4:	01390d63          	beq	s2,s3,800038de <iput+0xa2>
    if(ip->addrs[i]){
    800038c8:	00092583          	lw	a1,0(s2)
    800038cc:	d9fd                	beqz	a1,800038c2 <iput+0x86>
      bfree(ip->dev, ip->addrs[i]);
    800038ce:	4088                	lw	a0,0(s1)
    800038d0:	00000097          	auipc	ra,0x0
    800038d4:	8a2080e7          	jalr	-1886(ra) # 80003172 <bfree>
      ip->addrs[i] = 0;
    800038d8:	00092023          	sw	zero,0(s2)
    800038dc:	b7dd                	j	800038c2 <iput+0x86>
    }
  }

  if(ip->addrs[NDIRECT]){
    800038de:	0884a583          	lw	a1,136(s1)
    800038e2:	ed9d                	bnez	a1,80003920 <iput+0xe4>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800038e4:	0404aa23          	sw	zero,84(s1)
  iupdate(ip);
    800038e8:	8526                	mv	a0,s1
    800038ea:	00000097          	auipc	ra,0x0
    800038ee:	d7a080e7          	jalr	-646(ra) # 80003664 <iupdate>
    ip->type = 0;
    800038f2:	04049623          	sh	zero,76(s1)
    iupdate(ip);
    800038f6:	8526                	mv	a0,s1
    800038f8:	00000097          	auipc	ra,0x0
    800038fc:	d6c080e7          	jalr	-660(ra) # 80003664 <iupdate>
    ip->valid = 0;
    80003900:	0404a423          	sw	zero,72(s1)
    releasesleep(&ip->lock);
    80003904:	8552                	mv	a0,s4
    80003906:	00001097          	auipc	ra,0x1
    8000390a:	c28080e7          	jalr	-984(ra) # 8000452e <releasesleep>
    acquire(&icache.lock);
    8000390e:	0001c517          	auipc	a0,0x1c
    80003912:	9b250513          	addi	a0,a0,-1614 # 8001f2c0 <icache>
    80003916:	ffffd097          	auipc	ra,0xffffd
    8000391a:	18a080e7          	jalr	394(ra) # 80000aa0 <acquire>
    8000391e:	b7a9                	j	80003868 <iput+0x2c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003920:	4088                	lw	a0,0(s1)
    80003922:	fffff097          	auipc	ra,0xfffff
    80003926:	606080e7          	jalr	1542(ra) # 80002f28 <bread>
    8000392a:	8aaa                	mv	s5,a0
    for(j = 0; j < NINDIRECT; j++){
    8000392c:	06050913          	addi	s2,a0,96
    80003930:	46050993          	addi	s3,a0,1120
    80003934:	a021                	j	8000393c <iput+0x100>
    80003936:	0911                	addi	s2,s2,4
    80003938:	01390b63          	beq	s2,s3,8000394e <iput+0x112>
      if(a[j])
    8000393c:	00092583          	lw	a1,0(s2)
    80003940:	d9fd                	beqz	a1,80003936 <iput+0xfa>
        bfree(ip->dev, a[j]);
    80003942:	4088                	lw	a0,0(s1)
    80003944:	00000097          	auipc	ra,0x0
    80003948:	82e080e7          	jalr	-2002(ra) # 80003172 <bfree>
    8000394c:	b7ed                	j	80003936 <iput+0xfa>
    brelse(bp);
    8000394e:	8556                	mv	a0,s5
    80003950:	fffff097          	auipc	ra,0xfffff
    80003954:	70c080e7          	jalr	1804(ra) # 8000305c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003958:	0884a583          	lw	a1,136(s1)
    8000395c:	4088                	lw	a0,0(s1)
    8000395e:	00000097          	auipc	ra,0x0
    80003962:	814080e7          	jalr	-2028(ra) # 80003172 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003966:	0804a423          	sw	zero,136(s1)
    8000396a:	bfad                	j	800038e4 <iput+0xa8>

000000008000396c <iunlockput>:
{
    8000396c:	1101                	addi	sp,sp,-32
    8000396e:	ec06                	sd	ra,24(sp)
    80003970:	e822                	sd	s0,16(sp)
    80003972:	e426                	sd	s1,8(sp)
    80003974:	1000                	addi	s0,sp,32
    80003976:	84aa                	mv	s1,a0
  iunlock(ip);
    80003978:	00000097          	auipc	ra,0x0
    8000397c:	e78080e7          	jalr	-392(ra) # 800037f0 <iunlock>
  iput(ip);
    80003980:	8526                	mv	a0,s1
    80003982:	00000097          	auipc	ra,0x0
    80003986:	eba080e7          	jalr	-326(ra) # 8000383c <iput>
}
    8000398a:	60e2                	ld	ra,24(sp)
    8000398c:	6442                	ld	s0,16(sp)
    8000398e:	64a2                	ld	s1,8(sp)
    80003990:	6105                	addi	sp,sp,32
    80003992:	8082                	ret

0000000080003994 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003994:	1141                	addi	sp,sp,-16
    80003996:	e422                	sd	s0,8(sp)
    80003998:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000399a:	411c                	lw	a5,0(a0)
    8000399c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000399e:	415c                	lw	a5,4(a0)
    800039a0:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800039a2:	04c51783          	lh	a5,76(a0)
    800039a6:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800039aa:	05251783          	lh	a5,82(a0)
    800039ae:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800039b2:	05456783          	lwu	a5,84(a0)
    800039b6:	e99c                	sd	a5,16(a1)
}
    800039b8:	6422                	ld	s0,8(sp)
    800039ba:	0141                	addi	sp,sp,16
    800039bc:	8082                	ret

00000000800039be <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800039be:	497c                	lw	a5,84(a0)
    800039c0:	0ed7e563          	bltu	a5,a3,80003aaa <readi+0xec>
{
    800039c4:	7159                	addi	sp,sp,-112
    800039c6:	f486                	sd	ra,104(sp)
    800039c8:	f0a2                	sd	s0,96(sp)
    800039ca:	eca6                	sd	s1,88(sp)
    800039cc:	e8ca                	sd	s2,80(sp)
    800039ce:	e4ce                	sd	s3,72(sp)
    800039d0:	e0d2                	sd	s4,64(sp)
    800039d2:	fc56                	sd	s5,56(sp)
    800039d4:	f85a                	sd	s6,48(sp)
    800039d6:	f45e                	sd	s7,40(sp)
    800039d8:	f062                	sd	s8,32(sp)
    800039da:	ec66                	sd	s9,24(sp)
    800039dc:	e86a                	sd	s10,16(sp)
    800039de:	e46e                	sd	s11,8(sp)
    800039e0:	1880                	addi	s0,sp,112
    800039e2:	8baa                	mv	s7,a0
    800039e4:	8c2e                	mv	s8,a1
    800039e6:	8ab2                	mv	s5,a2
    800039e8:	8936                	mv	s2,a3
    800039ea:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800039ec:	9f35                	addw	a4,a4,a3
    800039ee:	0cd76063          	bltu	a4,a3,80003aae <readi+0xf0>
    return -1;
  if(off + n > ip->size)
    800039f2:	00e7f463          	bgeu	a5,a4,800039fa <readi+0x3c>
    n = ip->size - off;
    800039f6:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039fa:	080b0763          	beqz	s6,80003a88 <readi+0xca>
    800039fe:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a00:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003a04:	5cfd                	li	s9,-1
    80003a06:	a82d                	j	80003a40 <readi+0x82>
    80003a08:	02099d93          	slli	s11,s3,0x20
    80003a0c:	020ddd93          	srli	s11,s11,0x20
    80003a10:	06048793          	addi	a5,s1,96
    80003a14:	86ee                	mv	a3,s11
    80003a16:	963e                	add	a2,a2,a5
    80003a18:	85d6                	mv	a1,s5
    80003a1a:	8562                	mv	a0,s8
    80003a1c:	fffff097          	auipc	ra,0xfffff
    80003a20:	a92080e7          	jalr	-1390(ra) # 800024ae <either_copyout>
    80003a24:	05950d63          	beq	a0,s9,80003a7e <readi+0xc0>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003a28:	8526                	mv	a0,s1
    80003a2a:	fffff097          	auipc	ra,0xfffff
    80003a2e:	632080e7          	jalr	1586(ra) # 8000305c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a32:	01498a3b          	addw	s4,s3,s4
    80003a36:	0129893b          	addw	s2,s3,s2
    80003a3a:	9aee                	add	s5,s5,s11
    80003a3c:	056a7663          	bgeu	s4,s6,80003a88 <readi+0xca>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003a40:	000ba483          	lw	s1,0(s7)
    80003a44:	00a9559b          	srliw	a1,s2,0xa
    80003a48:	855e                	mv	a0,s7
    80003a4a:	00000097          	auipc	ra,0x0
    80003a4e:	8d6080e7          	jalr	-1834(ra) # 80003320 <bmap>
    80003a52:	0005059b          	sext.w	a1,a0
    80003a56:	8526                	mv	a0,s1
    80003a58:	fffff097          	auipc	ra,0xfffff
    80003a5c:	4d0080e7          	jalr	1232(ra) # 80002f28 <bread>
    80003a60:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a62:	3ff97613          	andi	a2,s2,1023
    80003a66:	40cd07bb          	subw	a5,s10,a2
    80003a6a:	414b073b          	subw	a4,s6,s4
    80003a6e:	89be                	mv	s3,a5
    80003a70:	2781                	sext.w	a5,a5
    80003a72:	0007069b          	sext.w	a3,a4
    80003a76:	f8f6f9e3          	bgeu	a3,a5,80003a08 <readi+0x4a>
    80003a7a:	89ba                	mv	s3,a4
    80003a7c:	b771                	j	80003a08 <readi+0x4a>
      brelse(bp);
    80003a7e:	8526                	mv	a0,s1
    80003a80:	fffff097          	auipc	ra,0xfffff
    80003a84:	5dc080e7          	jalr	1500(ra) # 8000305c <brelse>
  }
  return n;
    80003a88:	000b051b          	sext.w	a0,s6
}
    80003a8c:	70a6                	ld	ra,104(sp)
    80003a8e:	7406                	ld	s0,96(sp)
    80003a90:	64e6                	ld	s1,88(sp)
    80003a92:	6946                	ld	s2,80(sp)
    80003a94:	69a6                	ld	s3,72(sp)
    80003a96:	6a06                	ld	s4,64(sp)
    80003a98:	7ae2                	ld	s5,56(sp)
    80003a9a:	7b42                	ld	s6,48(sp)
    80003a9c:	7ba2                	ld	s7,40(sp)
    80003a9e:	7c02                	ld	s8,32(sp)
    80003aa0:	6ce2                	ld	s9,24(sp)
    80003aa2:	6d42                	ld	s10,16(sp)
    80003aa4:	6da2                	ld	s11,8(sp)
    80003aa6:	6165                	addi	sp,sp,112
    80003aa8:	8082                	ret
    return -1;
    80003aaa:	557d                	li	a0,-1
}
    80003aac:	8082                	ret
    return -1;
    80003aae:	557d                	li	a0,-1
    80003ab0:	bff1                	j	80003a8c <readi+0xce>

0000000080003ab2 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ab2:	497c                	lw	a5,84(a0)
    80003ab4:	10d7e663          	bltu	a5,a3,80003bc0 <writei+0x10e>
{
    80003ab8:	7159                	addi	sp,sp,-112
    80003aba:	f486                	sd	ra,104(sp)
    80003abc:	f0a2                	sd	s0,96(sp)
    80003abe:	eca6                	sd	s1,88(sp)
    80003ac0:	e8ca                	sd	s2,80(sp)
    80003ac2:	e4ce                	sd	s3,72(sp)
    80003ac4:	e0d2                	sd	s4,64(sp)
    80003ac6:	fc56                	sd	s5,56(sp)
    80003ac8:	f85a                	sd	s6,48(sp)
    80003aca:	f45e                	sd	s7,40(sp)
    80003acc:	f062                	sd	s8,32(sp)
    80003ace:	ec66                	sd	s9,24(sp)
    80003ad0:	e86a                	sd	s10,16(sp)
    80003ad2:	e46e                	sd	s11,8(sp)
    80003ad4:	1880                	addi	s0,sp,112
    80003ad6:	8baa                	mv	s7,a0
    80003ad8:	8c2e                	mv	s8,a1
    80003ada:	8ab2                	mv	s5,a2
    80003adc:	8936                	mv	s2,a3
    80003ade:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003ae0:	00e687bb          	addw	a5,a3,a4
    80003ae4:	0ed7e063          	bltu	a5,a3,80003bc4 <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003ae8:	00043737          	lui	a4,0x43
    80003aec:	0cf76e63          	bltu	a4,a5,80003bc8 <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003af0:	0a0b0763          	beqz	s6,80003b9e <writei+0xec>
    80003af4:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003af6:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003afa:	5cfd                	li	s9,-1
    80003afc:	a091                	j	80003b40 <writei+0x8e>
    80003afe:	02099d93          	slli	s11,s3,0x20
    80003b02:	020ddd93          	srli	s11,s11,0x20
    80003b06:	06048793          	addi	a5,s1,96
    80003b0a:	86ee                	mv	a3,s11
    80003b0c:	8656                	mv	a2,s5
    80003b0e:	85e2                	mv	a1,s8
    80003b10:	953e                	add	a0,a0,a5
    80003b12:	fffff097          	auipc	ra,0xfffff
    80003b16:	9f2080e7          	jalr	-1550(ra) # 80002504 <either_copyin>
    80003b1a:	07950263          	beq	a0,s9,80003b7e <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003b1e:	8526                	mv	a0,s1
    80003b20:	00001097          	auipc	ra,0x1
    80003b24:	83e080e7          	jalr	-1986(ra) # 8000435e <log_write>
    brelse(bp);
    80003b28:	8526                	mv	a0,s1
    80003b2a:	fffff097          	auipc	ra,0xfffff
    80003b2e:	532080e7          	jalr	1330(ra) # 8000305c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b32:	01498a3b          	addw	s4,s3,s4
    80003b36:	0129893b          	addw	s2,s3,s2
    80003b3a:	9aee                	add	s5,s5,s11
    80003b3c:	056a7663          	bgeu	s4,s6,80003b88 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003b40:	000ba483          	lw	s1,0(s7)
    80003b44:	00a9559b          	srliw	a1,s2,0xa
    80003b48:	855e                	mv	a0,s7
    80003b4a:	fffff097          	auipc	ra,0xfffff
    80003b4e:	7d6080e7          	jalr	2006(ra) # 80003320 <bmap>
    80003b52:	0005059b          	sext.w	a1,a0
    80003b56:	8526                	mv	a0,s1
    80003b58:	fffff097          	auipc	ra,0xfffff
    80003b5c:	3d0080e7          	jalr	976(ra) # 80002f28 <bread>
    80003b60:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b62:	3ff97513          	andi	a0,s2,1023
    80003b66:	40ad07bb          	subw	a5,s10,a0
    80003b6a:	414b073b          	subw	a4,s6,s4
    80003b6e:	89be                	mv	s3,a5
    80003b70:	2781                	sext.w	a5,a5
    80003b72:	0007069b          	sext.w	a3,a4
    80003b76:	f8f6f4e3          	bgeu	a3,a5,80003afe <writei+0x4c>
    80003b7a:	89ba                	mv	s3,a4
    80003b7c:	b749                	j	80003afe <writei+0x4c>
      brelse(bp);
    80003b7e:	8526                	mv	a0,s1
    80003b80:	fffff097          	auipc	ra,0xfffff
    80003b84:	4dc080e7          	jalr	1244(ra) # 8000305c <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003b88:	054ba783          	lw	a5,84(s7)
    80003b8c:	0127f463          	bgeu	a5,s2,80003b94 <writei+0xe2>
      ip->size = off;
    80003b90:	052baa23          	sw	s2,84(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003b94:	855e                	mv	a0,s7
    80003b96:	00000097          	auipc	ra,0x0
    80003b9a:	ace080e7          	jalr	-1330(ra) # 80003664 <iupdate>
  }

  return n;
    80003b9e:	000b051b          	sext.w	a0,s6
}
    80003ba2:	70a6                	ld	ra,104(sp)
    80003ba4:	7406                	ld	s0,96(sp)
    80003ba6:	64e6                	ld	s1,88(sp)
    80003ba8:	6946                	ld	s2,80(sp)
    80003baa:	69a6                	ld	s3,72(sp)
    80003bac:	6a06                	ld	s4,64(sp)
    80003bae:	7ae2                	ld	s5,56(sp)
    80003bb0:	7b42                	ld	s6,48(sp)
    80003bb2:	7ba2                	ld	s7,40(sp)
    80003bb4:	7c02                	ld	s8,32(sp)
    80003bb6:	6ce2                	ld	s9,24(sp)
    80003bb8:	6d42                	ld	s10,16(sp)
    80003bba:	6da2                	ld	s11,8(sp)
    80003bbc:	6165                	addi	sp,sp,112
    80003bbe:	8082                	ret
    return -1;
    80003bc0:	557d                	li	a0,-1
}
    80003bc2:	8082                	ret
    return -1;
    80003bc4:	557d                	li	a0,-1
    80003bc6:	bff1                	j	80003ba2 <writei+0xf0>
    return -1;
    80003bc8:	557d                	li	a0,-1
    80003bca:	bfe1                	j	80003ba2 <writei+0xf0>

0000000080003bcc <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003bcc:	1141                	addi	sp,sp,-16
    80003bce:	e406                	sd	ra,8(sp)
    80003bd0:	e022                	sd	s0,0(sp)
    80003bd2:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003bd4:	4639                	li	a2,14
    80003bd6:	ffffd097          	auipc	ra,0xffffd
    80003bda:	270080e7          	jalr	624(ra) # 80000e46 <strncmp>
}
    80003bde:	60a2                	ld	ra,8(sp)
    80003be0:	6402                	ld	s0,0(sp)
    80003be2:	0141                	addi	sp,sp,16
    80003be4:	8082                	ret

0000000080003be6 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003be6:	7139                	addi	sp,sp,-64
    80003be8:	fc06                	sd	ra,56(sp)
    80003bea:	f822                	sd	s0,48(sp)
    80003bec:	f426                	sd	s1,40(sp)
    80003bee:	f04a                	sd	s2,32(sp)
    80003bf0:	ec4e                	sd	s3,24(sp)
    80003bf2:	e852                	sd	s4,16(sp)
    80003bf4:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003bf6:	04c51703          	lh	a4,76(a0)
    80003bfa:	4785                	li	a5,1
    80003bfc:	00f71a63          	bne	a4,a5,80003c10 <dirlookup+0x2a>
    80003c00:	892a                	mv	s2,a0
    80003c02:	89ae                	mv	s3,a1
    80003c04:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c06:	497c                	lw	a5,84(a0)
    80003c08:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c0a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c0c:	e79d                	bnez	a5,80003c3a <dirlookup+0x54>
    80003c0e:	a8a5                	j	80003c86 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003c10:	00006517          	auipc	a0,0x6
    80003c14:	d5850513          	addi	a0,a0,-680 # 80009968 <userret+0x8d8>
    80003c18:	ffffd097          	auipc	ra,0xffffd
    80003c1c:	93c080e7          	jalr	-1732(ra) # 80000554 <panic>
      panic("dirlookup read");
    80003c20:	00006517          	auipc	a0,0x6
    80003c24:	d6050513          	addi	a0,a0,-672 # 80009980 <userret+0x8f0>
    80003c28:	ffffd097          	auipc	ra,0xffffd
    80003c2c:	92c080e7          	jalr	-1748(ra) # 80000554 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c30:	24c1                	addiw	s1,s1,16
    80003c32:	05492783          	lw	a5,84(s2)
    80003c36:	04f4f763          	bgeu	s1,a5,80003c84 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c3a:	4741                	li	a4,16
    80003c3c:	86a6                	mv	a3,s1
    80003c3e:	fc040613          	addi	a2,s0,-64
    80003c42:	4581                	li	a1,0
    80003c44:	854a                	mv	a0,s2
    80003c46:	00000097          	auipc	ra,0x0
    80003c4a:	d78080e7          	jalr	-648(ra) # 800039be <readi>
    80003c4e:	47c1                	li	a5,16
    80003c50:	fcf518e3          	bne	a0,a5,80003c20 <dirlookup+0x3a>
    if(de.inum == 0)
    80003c54:	fc045783          	lhu	a5,-64(s0)
    80003c58:	dfe1                	beqz	a5,80003c30 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003c5a:	fc240593          	addi	a1,s0,-62
    80003c5e:	854e                	mv	a0,s3
    80003c60:	00000097          	auipc	ra,0x0
    80003c64:	f6c080e7          	jalr	-148(ra) # 80003bcc <namecmp>
    80003c68:	f561                	bnez	a0,80003c30 <dirlookup+0x4a>
      if(poff)
    80003c6a:	000a0463          	beqz	s4,80003c72 <dirlookup+0x8c>
        *poff = off;
    80003c6e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003c72:	fc045583          	lhu	a1,-64(s0)
    80003c76:	00092503          	lw	a0,0(s2)
    80003c7a:	fffff097          	auipc	ra,0xfffff
    80003c7e:	780080e7          	jalr	1920(ra) # 800033fa <iget>
    80003c82:	a011                	j	80003c86 <dirlookup+0xa0>
  return 0;
    80003c84:	4501                	li	a0,0
}
    80003c86:	70e2                	ld	ra,56(sp)
    80003c88:	7442                	ld	s0,48(sp)
    80003c8a:	74a2                	ld	s1,40(sp)
    80003c8c:	7902                	ld	s2,32(sp)
    80003c8e:	69e2                	ld	s3,24(sp)
    80003c90:	6a42                	ld	s4,16(sp)
    80003c92:	6121                	addi	sp,sp,64
    80003c94:	8082                	ret

0000000080003c96 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003c96:	711d                	addi	sp,sp,-96
    80003c98:	ec86                	sd	ra,88(sp)
    80003c9a:	e8a2                	sd	s0,80(sp)
    80003c9c:	e4a6                	sd	s1,72(sp)
    80003c9e:	e0ca                	sd	s2,64(sp)
    80003ca0:	fc4e                	sd	s3,56(sp)
    80003ca2:	f852                	sd	s4,48(sp)
    80003ca4:	f456                	sd	s5,40(sp)
    80003ca6:	f05a                	sd	s6,32(sp)
    80003ca8:	ec5e                	sd	s7,24(sp)
    80003caa:	e862                	sd	s8,16(sp)
    80003cac:	e466                	sd	s9,8(sp)
    80003cae:	1080                	addi	s0,sp,96
    80003cb0:	84aa                	mv	s1,a0
    80003cb2:	8aae                	mv	s5,a1
    80003cb4:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003cb6:	00054703          	lbu	a4,0(a0)
    80003cba:	02f00793          	li	a5,47
    80003cbe:	02f70363          	beq	a4,a5,80003ce4 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003cc2:	ffffe097          	auipc	ra,0xffffe
    80003cc6:	dd2080e7          	jalr	-558(ra) # 80001a94 <myproc>
    80003cca:	15853503          	ld	a0,344(a0)
    80003cce:	00000097          	auipc	ra,0x0
    80003cd2:	a22080e7          	jalr	-1502(ra) # 800036f0 <idup>
    80003cd6:	89aa                	mv	s3,a0
  while(*path == '/')
    80003cd8:	02f00913          	li	s2,47
  len = path - s;
    80003cdc:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003cde:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003ce0:	4b85                	li	s7,1
    80003ce2:	a865                	j	80003d9a <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003ce4:	4585                	li	a1,1
    80003ce6:	4501                	li	a0,0
    80003ce8:	fffff097          	auipc	ra,0xfffff
    80003cec:	712080e7          	jalr	1810(ra) # 800033fa <iget>
    80003cf0:	89aa                	mv	s3,a0
    80003cf2:	b7dd                	j	80003cd8 <namex+0x42>
      iunlockput(ip);
    80003cf4:	854e                	mv	a0,s3
    80003cf6:	00000097          	auipc	ra,0x0
    80003cfa:	c76080e7          	jalr	-906(ra) # 8000396c <iunlockput>
      return 0;
    80003cfe:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003d00:	854e                	mv	a0,s3
    80003d02:	60e6                	ld	ra,88(sp)
    80003d04:	6446                	ld	s0,80(sp)
    80003d06:	64a6                	ld	s1,72(sp)
    80003d08:	6906                	ld	s2,64(sp)
    80003d0a:	79e2                	ld	s3,56(sp)
    80003d0c:	7a42                	ld	s4,48(sp)
    80003d0e:	7aa2                	ld	s5,40(sp)
    80003d10:	7b02                	ld	s6,32(sp)
    80003d12:	6be2                	ld	s7,24(sp)
    80003d14:	6c42                	ld	s8,16(sp)
    80003d16:	6ca2                	ld	s9,8(sp)
    80003d18:	6125                	addi	sp,sp,96
    80003d1a:	8082                	ret
      iunlock(ip);
    80003d1c:	854e                	mv	a0,s3
    80003d1e:	00000097          	auipc	ra,0x0
    80003d22:	ad2080e7          	jalr	-1326(ra) # 800037f0 <iunlock>
      return ip;
    80003d26:	bfe9                	j	80003d00 <namex+0x6a>
      iunlockput(ip);
    80003d28:	854e                	mv	a0,s3
    80003d2a:	00000097          	auipc	ra,0x0
    80003d2e:	c42080e7          	jalr	-958(ra) # 8000396c <iunlockput>
      return 0;
    80003d32:	89e6                	mv	s3,s9
    80003d34:	b7f1                	j	80003d00 <namex+0x6a>
  len = path - s;
    80003d36:	40b48633          	sub	a2,s1,a1
    80003d3a:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003d3e:	099c5463          	bge	s8,s9,80003dc6 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003d42:	4639                	li	a2,14
    80003d44:	8552                	mv	a0,s4
    80003d46:	ffffd097          	auipc	ra,0xffffd
    80003d4a:	084080e7          	jalr	132(ra) # 80000dca <memmove>
  while(*path == '/')
    80003d4e:	0004c783          	lbu	a5,0(s1)
    80003d52:	01279763          	bne	a5,s2,80003d60 <namex+0xca>
    path++;
    80003d56:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d58:	0004c783          	lbu	a5,0(s1)
    80003d5c:	ff278de3          	beq	a5,s2,80003d56 <namex+0xc0>
    ilock(ip);
    80003d60:	854e                	mv	a0,s3
    80003d62:	00000097          	auipc	ra,0x0
    80003d66:	9cc080e7          	jalr	-1588(ra) # 8000372e <ilock>
    if(ip->type != T_DIR){
    80003d6a:	04c99783          	lh	a5,76(s3)
    80003d6e:	f97793e3          	bne	a5,s7,80003cf4 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003d72:	000a8563          	beqz	s5,80003d7c <namex+0xe6>
    80003d76:	0004c783          	lbu	a5,0(s1)
    80003d7a:	d3cd                	beqz	a5,80003d1c <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d7c:	865a                	mv	a2,s6
    80003d7e:	85d2                	mv	a1,s4
    80003d80:	854e                	mv	a0,s3
    80003d82:	00000097          	auipc	ra,0x0
    80003d86:	e64080e7          	jalr	-412(ra) # 80003be6 <dirlookup>
    80003d8a:	8caa                	mv	s9,a0
    80003d8c:	dd51                	beqz	a0,80003d28 <namex+0x92>
    iunlockput(ip);
    80003d8e:	854e                	mv	a0,s3
    80003d90:	00000097          	auipc	ra,0x0
    80003d94:	bdc080e7          	jalr	-1060(ra) # 8000396c <iunlockput>
    ip = next;
    80003d98:	89e6                	mv	s3,s9
  while(*path == '/')
    80003d9a:	0004c783          	lbu	a5,0(s1)
    80003d9e:	05279763          	bne	a5,s2,80003dec <namex+0x156>
    path++;
    80003da2:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003da4:	0004c783          	lbu	a5,0(s1)
    80003da8:	ff278de3          	beq	a5,s2,80003da2 <namex+0x10c>
  if(*path == 0)
    80003dac:	c79d                	beqz	a5,80003dda <namex+0x144>
    path++;
    80003dae:	85a6                	mv	a1,s1
  len = path - s;
    80003db0:	8cda                	mv	s9,s6
    80003db2:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003db4:	01278963          	beq	a5,s2,80003dc6 <namex+0x130>
    80003db8:	dfbd                	beqz	a5,80003d36 <namex+0xa0>
    path++;
    80003dba:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003dbc:	0004c783          	lbu	a5,0(s1)
    80003dc0:	ff279ce3          	bne	a5,s2,80003db8 <namex+0x122>
    80003dc4:	bf8d                	j	80003d36 <namex+0xa0>
    memmove(name, s, len);
    80003dc6:	2601                	sext.w	a2,a2
    80003dc8:	8552                	mv	a0,s4
    80003dca:	ffffd097          	auipc	ra,0xffffd
    80003dce:	000080e7          	jalr	ra # 80000dca <memmove>
    name[len] = 0;
    80003dd2:	9cd2                	add	s9,s9,s4
    80003dd4:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003dd8:	bf9d                	j	80003d4e <namex+0xb8>
  if(nameiparent){
    80003dda:	f20a83e3          	beqz	s5,80003d00 <namex+0x6a>
    iput(ip);
    80003dde:	854e                	mv	a0,s3
    80003de0:	00000097          	auipc	ra,0x0
    80003de4:	a5c080e7          	jalr	-1444(ra) # 8000383c <iput>
    return 0;
    80003de8:	4981                	li	s3,0
    80003dea:	bf19                	j	80003d00 <namex+0x6a>
  if(*path == 0)
    80003dec:	d7fd                	beqz	a5,80003dda <namex+0x144>
  while(*path != '/' && *path != 0)
    80003dee:	0004c783          	lbu	a5,0(s1)
    80003df2:	85a6                	mv	a1,s1
    80003df4:	b7d1                	j	80003db8 <namex+0x122>

0000000080003df6 <dirlink>:
{
    80003df6:	7139                	addi	sp,sp,-64
    80003df8:	fc06                	sd	ra,56(sp)
    80003dfa:	f822                	sd	s0,48(sp)
    80003dfc:	f426                	sd	s1,40(sp)
    80003dfe:	f04a                	sd	s2,32(sp)
    80003e00:	ec4e                	sd	s3,24(sp)
    80003e02:	e852                	sd	s4,16(sp)
    80003e04:	0080                	addi	s0,sp,64
    80003e06:	892a                	mv	s2,a0
    80003e08:	8a2e                	mv	s4,a1
    80003e0a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e0c:	4601                	li	a2,0
    80003e0e:	00000097          	auipc	ra,0x0
    80003e12:	dd8080e7          	jalr	-552(ra) # 80003be6 <dirlookup>
    80003e16:	e93d                	bnez	a0,80003e8c <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e18:	05492483          	lw	s1,84(s2)
    80003e1c:	c49d                	beqz	s1,80003e4a <dirlink+0x54>
    80003e1e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e20:	4741                	li	a4,16
    80003e22:	86a6                	mv	a3,s1
    80003e24:	fc040613          	addi	a2,s0,-64
    80003e28:	4581                	li	a1,0
    80003e2a:	854a                	mv	a0,s2
    80003e2c:	00000097          	auipc	ra,0x0
    80003e30:	b92080e7          	jalr	-1134(ra) # 800039be <readi>
    80003e34:	47c1                	li	a5,16
    80003e36:	06f51163          	bne	a0,a5,80003e98 <dirlink+0xa2>
    if(de.inum == 0)
    80003e3a:	fc045783          	lhu	a5,-64(s0)
    80003e3e:	c791                	beqz	a5,80003e4a <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e40:	24c1                	addiw	s1,s1,16
    80003e42:	05492783          	lw	a5,84(s2)
    80003e46:	fcf4ede3          	bltu	s1,a5,80003e20 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003e4a:	4639                	li	a2,14
    80003e4c:	85d2                	mv	a1,s4
    80003e4e:	fc240513          	addi	a0,s0,-62
    80003e52:	ffffd097          	auipc	ra,0xffffd
    80003e56:	030080e7          	jalr	48(ra) # 80000e82 <strncpy>
  de.inum = inum;
    80003e5a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e5e:	4741                	li	a4,16
    80003e60:	86a6                	mv	a3,s1
    80003e62:	fc040613          	addi	a2,s0,-64
    80003e66:	4581                	li	a1,0
    80003e68:	854a                	mv	a0,s2
    80003e6a:	00000097          	auipc	ra,0x0
    80003e6e:	c48080e7          	jalr	-952(ra) # 80003ab2 <writei>
    80003e72:	872a                	mv	a4,a0
    80003e74:	47c1                	li	a5,16
  return 0;
    80003e76:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e78:	02f71863          	bne	a4,a5,80003ea8 <dirlink+0xb2>
}
    80003e7c:	70e2                	ld	ra,56(sp)
    80003e7e:	7442                	ld	s0,48(sp)
    80003e80:	74a2                	ld	s1,40(sp)
    80003e82:	7902                	ld	s2,32(sp)
    80003e84:	69e2                	ld	s3,24(sp)
    80003e86:	6a42                	ld	s4,16(sp)
    80003e88:	6121                	addi	sp,sp,64
    80003e8a:	8082                	ret
    iput(ip);
    80003e8c:	00000097          	auipc	ra,0x0
    80003e90:	9b0080e7          	jalr	-1616(ra) # 8000383c <iput>
    return -1;
    80003e94:	557d                	li	a0,-1
    80003e96:	b7dd                	j	80003e7c <dirlink+0x86>
      panic("dirlink read");
    80003e98:	00006517          	auipc	a0,0x6
    80003e9c:	af850513          	addi	a0,a0,-1288 # 80009990 <userret+0x900>
    80003ea0:	ffffc097          	auipc	ra,0xffffc
    80003ea4:	6b4080e7          	jalr	1716(ra) # 80000554 <panic>
    panic("dirlink");
    80003ea8:	00006517          	auipc	a0,0x6
    80003eac:	c0850513          	addi	a0,a0,-1016 # 80009ab0 <userret+0xa20>
    80003eb0:	ffffc097          	auipc	ra,0xffffc
    80003eb4:	6a4080e7          	jalr	1700(ra) # 80000554 <panic>

0000000080003eb8 <namei>:

struct inode*
namei(char *path)
{
    80003eb8:	1101                	addi	sp,sp,-32
    80003eba:	ec06                	sd	ra,24(sp)
    80003ebc:	e822                	sd	s0,16(sp)
    80003ebe:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003ec0:	fe040613          	addi	a2,s0,-32
    80003ec4:	4581                	li	a1,0
    80003ec6:	00000097          	auipc	ra,0x0
    80003eca:	dd0080e7          	jalr	-560(ra) # 80003c96 <namex>
}
    80003ece:	60e2                	ld	ra,24(sp)
    80003ed0:	6442                	ld	s0,16(sp)
    80003ed2:	6105                	addi	sp,sp,32
    80003ed4:	8082                	ret

0000000080003ed6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003ed6:	1141                	addi	sp,sp,-16
    80003ed8:	e406                	sd	ra,8(sp)
    80003eda:	e022                	sd	s0,0(sp)
    80003edc:	0800                	addi	s0,sp,16
    80003ede:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003ee0:	4585                	li	a1,1
    80003ee2:	00000097          	auipc	ra,0x0
    80003ee6:	db4080e7          	jalr	-588(ra) # 80003c96 <namex>
}
    80003eea:	60a2                	ld	ra,8(sp)
    80003eec:	6402                	ld	s0,0(sp)
    80003eee:	0141                	addi	sp,sp,16
    80003ef0:	8082                	ret

0000000080003ef2 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(int dev)
{
    80003ef2:	7179                	addi	sp,sp,-48
    80003ef4:	f406                	sd	ra,40(sp)
    80003ef6:	f022                	sd	s0,32(sp)
    80003ef8:	ec26                	sd	s1,24(sp)
    80003efa:	e84a                	sd	s2,16(sp)
    80003efc:	e44e                	sd	s3,8(sp)
    80003efe:	1800                	addi	s0,sp,48
    80003f00:	84aa                	mv	s1,a0
  struct buf *buf = bread(dev, log[dev].start);
    80003f02:	0b000993          	li	s3,176
    80003f06:	033507b3          	mul	a5,a0,s3
    80003f0a:	0001d997          	auipc	s3,0x1d
    80003f0e:	ff698993          	addi	s3,s3,-10 # 80020f00 <log>
    80003f12:	99be                	add	s3,s3,a5
    80003f14:	0209a583          	lw	a1,32(s3)
    80003f18:	fffff097          	auipc	ra,0xfffff
    80003f1c:	010080e7          	jalr	16(ra) # 80002f28 <bread>
    80003f20:	892a                	mv	s2,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log[dev].lh.n;
    80003f22:	0349a783          	lw	a5,52(s3)
    80003f26:	d13c                	sw	a5,96(a0)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003f28:	0349a783          	lw	a5,52(s3)
    80003f2c:	02f05763          	blez	a5,80003f5a <write_head+0x68>
    80003f30:	0b000793          	li	a5,176
    80003f34:	02f487b3          	mul	a5,s1,a5
    80003f38:	0001d717          	auipc	a4,0x1d
    80003f3c:	00070713          	mv	a4,a4
    80003f40:	97ba                	add	a5,a5,a4
    80003f42:	06450693          	addi	a3,a0,100
    80003f46:	4701                	li	a4,0
    80003f48:	85ce                	mv	a1,s3
    hb->block[i] = log[dev].lh.block[i];
    80003f4a:	4390                	lw	a2,0(a5)
    80003f4c:	c290                	sw	a2,0(a3)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003f4e:	2705                	addiw	a4,a4,1
    80003f50:	0791                	addi	a5,a5,4
    80003f52:	0691                	addi	a3,a3,4
    80003f54:	59d0                	lw	a2,52(a1)
    80003f56:	fec74ae3          	blt	a4,a2,80003f4a <write_head+0x58>
  }
  bwrite(buf);
    80003f5a:	854a                	mv	a0,s2
    80003f5c:	fffff097          	auipc	ra,0xfffff
    80003f60:	0c0080e7          	jalr	192(ra) # 8000301c <bwrite>
  brelse(buf);
    80003f64:	854a                	mv	a0,s2
    80003f66:	fffff097          	auipc	ra,0xfffff
    80003f6a:	0f6080e7          	jalr	246(ra) # 8000305c <brelse>
}
    80003f6e:	70a2                	ld	ra,40(sp)
    80003f70:	7402                	ld	s0,32(sp)
    80003f72:	64e2                	ld	s1,24(sp)
    80003f74:	6942                	ld	s2,16(sp)
    80003f76:	69a2                	ld	s3,8(sp)
    80003f78:	6145                	addi	sp,sp,48
    80003f7a:	8082                	ret

0000000080003f7c <install_trans>:
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003f7c:	0b000793          	li	a5,176
    80003f80:	02f50733          	mul	a4,a0,a5
    80003f84:	0001d797          	auipc	a5,0x1d
    80003f88:	f7c78793          	addi	a5,a5,-132 # 80020f00 <log>
    80003f8c:	97ba                	add	a5,a5,a4
    80003f8e:	5bdc                	lw	a5,52(a5)
    80003f90:	0af05b63          	blez	a5,80004046 <install_trans+0xca>
{
    80003f94:	7139                	addi	sp,sp,-64
    80003f96:	fc06                	sd	ra,56(sp)
    80003f98:	f822                	sd	s0,48(sp)
    80003f9a:	f426                	sd	s1,40(sp)
    80003f9c:	f04a                	sd	s2,32(sp)
    80003f9e:	ec4e                	sd	s3,24(sp)
    80003fa0:	e852                	sd	s4,16(sp)
    80003fa2:	e456                	sd	s5,8(sp)
    80003fa4:	e05a                	sd	s6,0(sp)
    80003fa6:	0080                	addi	s0,sp,64
    80003fa8:	0001d797          	auipc	a5,0x1d
    80003fac:	f9078793          	addi	a5,a5,-112 # 80020f38 <log+0x38>
    80003fb0:	00f70a33          	add	s4,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003fb4:	4981                	li	s3,0
    struct buf *lbuf = bread(dev, log[dev].start+tail+1); // read log block
    80003fb6:	00050b1b          	sext.w	s6,a0
    80003fba:	0001da97          	auipc	s5,0x1d
    80003fbe:	f46a8a93          	addi	s5,s5,-186 # 80020f00 <log>
    80003fc2:	9aba                	add	s5,s5,a4
    80003fc4:	020aa583          	lw	a1,32(s5)
    80003fc8:	013585bb          	addw	a1,a1,s3
    80003fcc:	2585                	addiw	a1,a1,1
    80003fce:	855a                	mv	a0,s6
    80003fd0:	fffff097          	auipc	ra,0xfffff
    80003fd4:	f58080e7          	jalr	-168(ra) # 80002f28 <bread>
    80003fd8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(dev, log[dev].lh.block[tail]); // read dst
    80003fda:	000a2583          	lw	a1,0(s4)
    80003fde:	855a                	mv	a0,s6
    80003fe0:	fffff097          	auipc	ra,0xfffff
    80003fe4:	f48080e7          	jalr	-184(ra) # 80002f28 <bread>
    80003fe8:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003fea:	40000613          	li	a2,1024
    80003fee:	06090593          	addi	a1,s2,96
    80003ff2:	06050513          	addi	a0,a0,96
    80003ff6:	ffffd097          	auipc	ra,0xffffd
    80003ffa:	dd4080e7          	jalr	-556(ra) # 80000dca <memmove>
    bwrite(dbuf);  // write dst to disk
    80003ffe:	8526                	mv	a0,s1
    80004000:	fffff097          	auipc	ra,0xfffff
    80004004:	01c080e7          	jalr	28(ra) # 8000301c <bwrite>
    bunpin(dbuf);
    80004008:	8526                	mv	a0,s1
    8000400a:	fffff097          	auipc	ra,0xfffff
    8000400e:	12c080e7          	jalr	300(ra) # 80003136 <bunpin>
    brelse(lbuf);
    80004012:	854a                	mv	a0,s2
    80004014:	fffff097          	auipc	ra,0xfffff
    80004018:	048080e7          	jalr	72(ra) # 8000305c <brelse>
    brelse(dbuf);
    8000401c:	8526                	mv	a0,s1
    8000401e:	fffff097          	auipc	ra,0xfffff
    80004022:	03e080e7          	jalr	62(ra) # 8000305c <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004026:	2985                	addiw	s3,s3,1
    80004028:	0a11                	addi	s4,s4,4
    8000402a:	034aa783          	lw	a5,52(s5)
    8000402e:	f8f9cbe3          	blt	s3,a5,80003fc4 <install_trans+0x48>
}
    80004032:	70e2                	ld	ra,56(sp)
    80004034:	7442                	ld	s0,48(sp)
    80004036:	74a2                	ld	s1,40(sp)
    80004038:	7902                	ld	s2,32(sp)
    8000403a:	69e2                	ld	s3,24(sp)
    8000403c:	6a42                	ld	s4,16(sp)
    8000403e:	6aa2                	ld	s5,8(sp)
    80004040:	6b02                	ld	s6,0(sp)
    80004042:	6121                	addi	sp,sp,64
    80004044:	8082                	ret
    80004046:	8082                	ret

0000000080004048 <initlog>:
{
    80004048:	7179                	addi	sp,sp,-48
    8000404a:	f406                	sd	ra,40(sp)
    8000404c:	f022                	sd	s0,32(sp)
    8000404e:	ec26                	sd	s1,24(sp)
    80004050:	e84a                	sd	s2,16(sp)
    80004052:	e44e                	sd	s3,8(sp)
    80004054:	e052                	sd	s4,0(sp)
    80004056:	1800                	addi	s0,sp,48
    80004058:	892a                	mv	s2,a0
    8000405a:	8a2e                	mv	s4,a1
  initlock(&log[dev].lock, "log");
    8000405c:	0b000713          	li	a4,176
    80004060:	02e504b3          	mul	s1,a0,a4
    80004064:	0001d997          	auipc	s3,0x1d
    80004068:	e9c98993          	addi	s3,s3,-356 # 80020f00 <log>
    8000406c:	99a6                	add	s3,s3,s1
    8000406e:	00006597          	auipc	a1,0x6
    80004072:	93258593          	addi	a1,a1,-1742 # 800099a0 <userret+0x910>
    80004076:	854e                	mv	a0,s3
    80004078:	ffffd097          	auipc	ra,0xffffd
    8000407c:	954080e7          	jalr	-1708(ra) # 800009cc <initlock>
  log[dev].start = sb->logstart;
    80004080:	014a2583          	lw	a1,20(s4)
    80004084:	02b9a023          	sw	a1,32(s3)
  log[dev].size = sb->nlog;
    80004088:	010a2783          	lw	a5,16(s4)
    8000408c:	02f9a223          	sw	a5,36(s3)
  log[dev].dev = dev;
    80004090:	0329a823          	sw	s2,48(s3)
  struct buf *buf = bread(dev, log[dev].start);
    80004094:	854a                	mv	a0,s2
    80004096:	fffff097          	auipc	ra,0xfffff
    8000409a:	e92080e7          	jalr	-366(ra) # 80002f28 <bread>
  log[dev].lh.n = lh->n;
    8000409e:	5134                	lw	a3,96(a0)
    800040a0:	02d9aa23          	sw	a3,52(s3)
  for (i = 0; i < log[dev].lh.n; i++) {
    800040a4:	02d05663          	blez	a3,800040d0 <initlog+0x88>
    800040a8:	06450793          	addi	a5,a0,100
    800040ac:	0001d717          	auipc	a4,0x1d
    800040b0:	e8c70713          	addi	a4,a4,-372 # 80020f38 <log+0x38>
    800040b4:	9726                	add	a4,a4,s1
    800040b6:	36fd                	addiw	a3,a3,-1
    800040b8:	1682                	slli	a3,a3,0x20
    800040ba:	9281                	srli	a3,a3,0x20
    800040bc:	068a                	slli	a3,a3,0x2
    800040be:	06850613          	addi	a2,a0,104
    800040c2:	96b2                	add	a3,a3,a2
    log[dev].lh.block[i] = lh->block[i];
    800040c4:	4390                	lw	a2,0(a5)
    800040c6:	c310                	sw	a2,0(a4)
  for (i = 0; i < log[dev].lh.n; i++) {
    800040c8:	0791                	addi	a5,a5,4
    800040ca:	0711                	addi	a4,a4,4
    800040cc:	fed79ce3          	bne	a5,a3,800040c4 <initlog+0x7c>
  brelse(buf);
    800040d0:	fffff097          	auipc	ra,0xfffff
    800040d4:	f8c080e7          	jalr	-116(ra) # 8000305c <brelse>

static void
recover_from_log(int dev)
{
  read_head(dev);
  install_trans(dev); // if committed, copy from log to disk
    800040d8:	854a                	mv	a0,s2
    800040da:	00000097          	auipc	ra,0x0
    800040de:	ea2080e7          	jalr	-350(ra) # 80003f7c <install_trans>
  log[dev].lh.n = 0;
    800040e2:	0b000793          	li	a5,176
    800040e6:	02f90733          	mul	a4,s2,a5
    800040ea:	0001d797          	auipc	a5,0x1d
    800040ee:	e1678793          	addi	a5,a5,-490 # 80020f00 <log>
    800040f2:	97ba                	add	a5,a5,a4
    800040f4:	0207aa23          	sw	zero,52(a5)
  write_head(dev); // clear the log
    800040f8:	854a                	mv	a0,s2
    800040fa:	00000097          	auipc	ra,0x0
    800040fe:	df8080e7          	jalr	-520(ra) # 80003ef2 <write_head>
}
    80004102:	70a2                	ld	ra,40(sp)
    80004104:	7402                	ld	s0,32(sp)
    80004106:	64e2                	ld	s1,24(sp)
    80004108:	6942                	ld	s2,16(sp)
    8000410a:	69a2                	ld	s3,8(sp)
    8000410c:	6a02                	ld	s4,0(sp)
    8000410e:	6145                	addi	sp,sp,48
    80004110:	8082                	ret

0000000080004112 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(int dev)
{
    80004112:	7139                	addi	sp,sp,-64
    80004114:	fc06                	sd	ra,56(sp)
    80004116:	f822                	sd	s0,48(sp)
    80004118:	f426                	sd	s1,40(sp)
    8000411a:	f04a                	sd	s2,32(sp)
    8000411c:	ec4e                	sd	s3,24(sp)
    8000411e:	e852                	sd	s4,16(sp)
    80004120:	e456                	sd	s5,8(sp)
    80004122:	0080                	addi	s0,sp,64
    80004124:	8aaa                	mv	s5,a0
  acquire(&log[dev].lock);
    80004126:	0b000913          	li	s2,176
    8000412a:	032507b3          	mul	a5,a0,s2
    8000412e:	0001d917          	auipc	s2,0x1d
    80004132:	dd290913          	addi	s2,s2,-558 # 80020f00 <log>
    80004136:	993e                	add	s2,s2,a5
    80004138:	854a                	mv	a0,s2
    8000413a:	ffffd097          	auipc	ra,0xffffd
    8000413e:	966080e7          	jalr	-1690(ra) # 80000aa0 <acquire>
  while(1){
    if(log[dev].committing){
    80004142:	0001d997          	auipc	s3,0x1d
    80004146:	dbe98993          	addi	s3,s3,-578 # 80020f00 <log>
    8000414a:	84ca                	mv	s1,s2
      sleep(&log, &log[dev].lock);
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000414c:	4a79                	li	s4,30
    8000414e:	a039                	j	8000415c <begin_op+0x4a>
      sleep(&log, &log[dev].lock);
    80004150:	85ca                	mv	a1,s2
    80004152:	854e                	mv	a0,s3
    80004154:	ffffe097          	auipc	ra,0xffffe
    80004158:	100080e7          	jalr	256(ra) # 80002254 <sleep>
    if(log[dev].committing){
    8000415c:	54dc                	lw	a5,44(s1)
    8000415e:	fbed                	bnez	a5,80004150 <begin_op+0x3e>
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004160:	549c                	lw	a5,40(s1)
    80004162:	0017871b          	addiw	a4,a5,1
    80004166:	0007069b          	sext.w	a3,a4
    8000416a:	0027179b          	slliw	a5,a4,0x2
    8000416e:	9fb9                	addw	a5,a5,a4
    80004170:	0017979b          	slliw	a5,a5,0x1
    80004174:	58d8                	lw	a4,52(s1)
    80004176:	9fb9                	addw	a5,a5,a4
    80004178:	00fa5963          	bge	s4,a5,8000418a <begin_op+0x78>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log[dev].lock);
    8000417c:	85ca                	mv	a1,s2
    8000417e:	854e                	mv	a0,s3
    80004180:	ffffe097          	auipc	ra,0xffffe
    80004184:	0d4080e7          	jalr	212(ra) # 80002254 <sleep>
    80004188:	bfd1                	j	8000415c <begin_op+0x4a>
    } else {
      log[dev].outstanding += 1;
    8000418a:	0b000513          	li	a0,176
    8000418e:	02aa8ab3          	mul	s5,s5,a0
    80004192:	0001d797          	auipc	a5,0x1d
    80004196:	d6e78793          	addi	a5,a5,-658 # 80020f00 <log>
    8000419a:	9abe                	add	s5,s5,a5
    8000419c:	02daa423          	sw	a3,40(s5)
      release(&log[dev].lock);
    800041a0:	854a                	mv	a0,s2
    800041a2:	ffffd097          	auipc	ra,0xffffd
    800041a6:	9ce080e7          	jalr	-1586(ra) # 80000b70 <release>
      break;
    }
  }
}
    800041aa:	70e2                	ld	ra,56(sp)
    800041ac:	7442                	ld	s0,48(sp)
    800041ae:	74a2                	ld	s1,40(sp)
    800041b0:	7902                	ld	s2,32(sp)
    800041b2:	69e2                	ld	s3,24(sp)
    800041b4:	6a42                	ld	s4,16(sp)
    800041b6:	6aa2                	ld	s5,8(sp)
    800041b8:	6121                	addi	sp,sp,64
    800041ba:	8082                	ret

00000000800041bc <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(int dev)
{
    800041bc:	715d                	addi	sp,sp,-80
    800041be:	e486                	sd	ra,72(sp)
    800041c0:	e0a2                	sd	s0,64(sp)
    800041c2:	fc26                	sd	s1,56(sp)
    800041c4:	f84a                	sd	s2,48(sp)
    800041c6:	f44e                	sd	s3,40(sp)
    800041c8:	f052                	sd	s4,32(sp)
    800041ca:	ec56                	sd	s5,24(sp)
    800041cc:	e85a                	sd	s6,16(sp)
    800041ce:	e45e                	sd	s7,8(sp)
    800041d0:	e062                	sd	s8,0(sp)
    800041d2:	0880                	addi	s0,sp,80
    800041d4:	89aa                	mv	s3,a0
  int do_commit = 0;

  acquire(&log[dev].lock);
    800041d6:	0b000913          	li	s2,176
    800041da:	03250933          	mul	s2,a0,s2
    800041de:	0001d497          	auipc	s1,0x1d
    800041e2:	d2248493          	addi	s1,s1,-734 # 80020f00 <log>
    800041e6:	94ca                	add	s1,s1,s2
    800041e8:	8526                	mv	a0,s1
    800041ea:	ffffd097          	auipc	ra,0xffffd
    800041ee:	8b6080e7          	jalr	-1866(ra) # 80000aa0 <acquire>
  log[dev].outstanding -= 1;
    800041f2:	549c                	lw	a5,40(s1)
    800041f4:	37fd                	addiw	a5,a5,-1
    800041f6:	00078a9b          	sext.w	s5,a5
    800041fa:	d49c                	sw	a5,40(s1)
  if(log[dev].committing)
    800041fc:	54dc                	lw	a5,44(s1)
    800041fe:	e3b5                	bnez	a5,80004262 <end_op+0xa6>
    panic("log[dev].committing");
  if(log[dev].outstanding == 0){
    80004200:	060a9963          	bnez	s5,80004272 <end_op+0xb6>
    do_commit = 1;
    log[dev].committing = 1;
    80004204:	0b000a13          	li	s4,176
    80004208:	034987b3          	mul	a5,s3,s4
    8000420c:	0001da17          	auipc	s4,0x1d
    80004210:	cf4a0a13          	addi	s4,s4,-780 # 80020f00 <log>
    80004214:	9a3e                	add	s4,s4,a5
    80004216:	4785                	li	a5,1
    80004218:	02fa2623          	sw	a5,44(s4)
    // begin_op() may be waiting for log space,
    // and decrementing log[dev].outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log[dev].lock);
    8000421c:	8526                	mv	a0,s1
    8000421e:	ffffd097          	auipc	ra,0xffffd
    80004222:	952080e7          	jalr	-1710(ra) # 80000b70 <release>
}

static void
commit(int dev)
{
  if (log[dev].lh.n > 0) {
    80004226:	034a2783          	lw	a5,52(s4)
    8000422a:	06f04d63          	bgtz	a5,800042a4 <end_op+0xe8>
    acquire(&log[dev].lock);
    8000422e:	8526                	mv	a0,s1
    80004230:	ffffd097          	auipc	ra,0xffffd
    80004234:	870080e7          	jalr	-1936(ra) # 80000aa0 <acquire>
    log[dev].committing = 0;
    80004238:	0001d517          	auipc	a0,0x1d
    8000423c:	cc850513          	addi	a0,a0,-824 # 80020f00 <log>
    80004240:	0b000793          	li	a5,176
    80004244:	02f989b3          	mul	s3,s3,a5
    80004248:	99aa                	add	s3,s3,a0
    8000424a:	0209a623          	sw	zero,44(s3)
    wakeup(&log);
    8000424e:	ffffe097          	auipc	ra,0xffffe
    80004252:	186080e7          	jalr	390(ra) # 800023d4 <wakeup>
    release(&log[dev].lock);
    80004256:	8526                	mv	a0,s1
    80004258:	ffffd097          	auipc	ra,0xffffd
    8000425c:	918080e7          	jalr	-1768(ra) # 80000b70 <release>
}
    80004260:	a035                	j	8000428c <end_op+0xd0>
    panic("log[dev].committing");
    80004262:	00005517          	auipc	a0,0x5
    80004266:	74650513          	addi	a0,a0,1862 # 800099a8 <userret+0x918>
    8000426a:	ffffc097          	auipc	ra,0xffffc
    8000426e:	2ea080e7          	jalr	746(ra) # 80000554 <panic>
    wakeup(&log);
    80004272:	0001d517          	auipc	a0,0x1d
    80004276:	c8e50513          	addi	a0,a0,-882 # 80020f00 <log>
    8000427a:	ffffe097          	auipc	ra,0xffffe
    8000427e:	15a080e7          	jalr	346(ra) # 800023d4 <wakeup>
  release(&log[dev].lock);
    80004282:	8526                	mv	a0,s1
    80004284:	ffffd097          	auipc	ra,0xffffd
    80004288:	8ec080e7          	jalr	-1812(ra) # 80000b70 <release>
}
    8000428c:	60a6                	ld	ra,72(sp)
    8000428e:	6406                	ld	s0,64(sp)
    80004290:	74e2                	ld	s1,56(sp)
    80004292:	7942                	ld	s2,48(sp)
    80004294:	79a2                	ld	s3,40(sp)
    80004296:	7a02                	ld	s4,32(sp)
    80004298:	6ae2                	ld	s5,24(sp)
    8000429a:	6b42                	ld	s6,16(sp)
    8000429c:	6ba2                	ld	s7,8(sp)
    8000429e:	6c02                	ld	s8,0(sp)
    800042a0:	6161                	addi	sp,sp,80
    800042a2:	8082                	ret
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    800042a4:	0001d797          	auipc	a5,0x1d
    800042a8:	c9478793          	addi	a5,a5,-876 # 80020f38 <log+0x38>
    800042ac:	993e                	add	s2,s2,a5
    struct buf *to = bread(dev, log[dev].start+tail+1); // log block
    800042ae:	00098c1b          	sext.w	s8,s3
    800042b2:	0b000b93          	li	s7,176
    800042b6:	037987b3          	mul	a5,s3,s7
    800042ba:	0001db97          	auipc	s7,0x1d
    800042be:	c46b8b93          	addi	s7,s7,-954 # 80020f00 <log>
    800042c2:	9bbe                	add	s7,s7,a5
    800042c4:	020ba583          	lw	a1,32(s7)
    800042c8:	015585bb          	addw	a1,a1,s5
    800042cc:	2585                	addiw	a1,a1,1
    800042ce:	8562                	mv	a0,s8
    800042d0:	fffff097          	auipc	ra,0xfffff
    800042d4:	c58080e7          	jalr	-936(ra) # 80002f28 <bread>
    800042d8:	8a2a                	mv	s4,a0
    struct buf *from = bread(dev, log[dev].lh.block[tail]); // cache block
    800042da:	00092583          	lw	a1,0(s2)
    800042de:	8562                	mv	a0,s8
    800042e0:	fffff097          	auipc	ra,0xfffff
    800042e4:	c48080e7          	jalr	-952(ra) # 80002f28 <bread>
    800042e8:	8b2a                	mv	s6,a0
    memmove(to->data, from->data, BSIZE);
    800042ea:	40000613          	li	a2,1024
    800042ee:	06050593          	addi	a1,a0,96
    800042f2:	060a0513          	addi	a0,s4,96
    800042f6:	ffffd097          	auipc	ra,0xffffd
    800042fa:	ad4080e7          	jalr	-1324(ra) # 80000dca <memmove>
    bwrite(to);  // write the log
    800042fe:	8552                	mv	a0,s4
    80004300:	fffff097          	auipc	ra,0xfffff
    80004304:	d1c080e7          	jalr	-740(ra) # 8000301c <bwrite>
    brelse(from);
    80004308:	855a                	mv	a0,s6
    8000430a:	fffff097          	auipc	ra,0xfffff
    8000430e:	d52080e7          	jalr	-686(ra) # 8000305c <brelse>
    brelse(to);
    80004312:	8552                	mv	a0,s4
    80004314:	fffff097          	auipc	ra,0xfffff
    80004318:	d48080e7          	jalr	-696(ra) # 8000305c <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    8000431c:	2a85                	addiw	s5,s5,1
    8000431e:	0911                	addi	s2,s2,4
    80004320:	034ba783          	lw	a5,52(s7)
    80004324:	fafac0e3          	blt	s5,a5,800042c4 <end_op+0x108>
    write_log(dev);     // Write modified blocks from cache to log
    write_head(dev);    // Write header to disk -- the real commit
    80004328:	854e                	mv	a0,s3
    8000432a:	00000097          	auipc	ra,0x0
    8000432e:	bc8080e7          	jalr	-1080(ra) # 80003ef2 <write_head>
    install_trans(dev); // Now install writes to home locations
    80004332:	854e                	mv	a0,s3
    80004334:	00000097          	auipc	ra,0x0
    80004338:	c48080e7          	jalr	-952(ra) # 80003f7c <install_trans>
    log[dev].lh.n = 0;
    8000433c:	0b000793          	li	a5,176
    80004340:	02f98733          	mul	a4,s3,a5
    80004344:	0001d797          	auipc	a5,0x1d
    80004348:	bbc78793          	addi	a5,a5,-1092 # 80020f00 <log>
    8000434c:	97ba                	add	a5,a5,a4
    8000434e:	0207aa23          	sw	zero,52(a5)
    write_head(dev);    // Erase the transaction from the log
    80004352:	854e                	mv	a0,s3
    80004354:	00000097          	auipc	ra,0x0
    80004358:	b9e080e7          	jalr	-1122(ra) # 80003ef2 <write_head>
    8000435c:	bdc9                	j	8000422e <end_op+0x72>

000000008000435e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000435e:	7179                	addi	sp,sp,-48
    80004360:	f406                	sd	ra,40(sp)
    80004362:	f022                	sd	s0,32(sp)
    80004364:	ec26                	sd	s1,24(sp)
    80004366:	e84a                	sd	s2,16(sp)
    80004368:	e44e                	sd	s3,8(sp)
    8000436a:	e052                	sd	s4,0(sp)
    8000436c:	1800                	addi	s0,sp,48
  int i;

  int dev = b->dev;
    8000436e:	00852903          	lw	s2,8(a0)
  if (log[dev].lh.n >= LOGSIZE || log[dev].lh.n >= log[dev].size - 1)
    80004372:	0b000793          	li	a5,176
    80004376:	02f90733          	mul	a4,s2,a5
    8000437a:	0001d797          	auipc	a5,0x1d
    8000437e:	b8678793          	addi	a5,a5,-1146 # 80020f00 <log>
    80004382:	97ba                	add	a5,a5,a4
    80004384:	5bd4                	lw	a3,52(a5)
    80004386:	47f5                	li	a5,29
    80004388:	0ad7cc63          	blt	a5,a3,80004440 <log_write+0xe2>
    8000438c:	89aa                	mv	s3,a0
    8000438e:	0001d797          	auipc	a5,0x1d
    80004392:	b7278793          	addi	a5,a5,-1166 # 80020f00 <log>
    80004396:	97ba                	add	a5,a5,a4
    80004398:	53dc                	lw	a5,36(a5)
    8000439a:	37fd                	addiw	a5,a5,-1
    8000439c:	0af6d263          	bge	a3,a5,80004440 <log_write+0xe2>
    panic("too big a transaction");
  if (log[dev].outstanding < 1)
    800043a0:	0b000793          	li	a5,176
    800043a4:	02f90733          	mul	a4,s2,a5
    800043a8:	0001d797          	auipc	a5,0x1d
    800043ac:	b5878793          	addi	a5,a5,-1192 # 80020f00 <log>
    800043b0:	97ba                	add	a5,a5,a4
    800043b2:	579c                	lw	a5,40(a5)
    800043b4:	08f05e63          	blez	a5,80004450 <log_write+0xf2>
    panic("log_write outside of trans");

  acquire(&log[dev].lock);
    800043b8:	0b000793          	li	a5,176
    800043bc:	02f904b3          	mul	s1,s2,a5
    800043c0:	0001da17          	auipc	s4,0x1d
    800043c4:	b40a0a13          	addi	s4,s4,-1216 # 80020f00 <log>
    800043c8:	9a26                	add	s4,s4,s1
    800043ca:	8552                	mv	a0,s4
    800043cc:	ffffc097          	auipc	ra,0xffffc
    800043d0:	6d4080e7          	jalr	1748(ra) # 80000aa0 <acquire>
  for (i = 0; i < log[dev].lh.n; i++) {
    800043d4:	034a2603          	lw	a2,52(s4)
    800043d8:	08c05463          	blez	a2,80004460 <log_write+0x102>
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    800043dc:	00c9a583          	lw	a1,12(s3)
    800043e0:	0001d797          	auipc	a5,0x1d
    800043e4:	b5878793          	addi	a5,a5,-1192 # 80020f38 <log+0x38>
    800043e8:	97a6                	add	a5,a5,s1
  for (i = 0; i < log[dev].lh.n; i++) {
    800043ea:	4701                	li	a4,0
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    800043ec:	4394                	lw	a3,0(a5)
    800043ee:	06b68a63          	beq	a3,a1,80004462 <log_write+0x104>
  for (i = 0; i < log[dev].lh.n; i++) {
    800043f2:	2705                	addiw	a4,a4,1
    800043f4:	0791                	addi	a5,a5,4
    800043f6:	fec71be3          	bne	a4,a2,800043ec <log_write+0x8e>
      break;
  }
  log[dev].lh.block[i] = b->blockno;
    800043fa:	02c00793          	li	a5,44
    800043fe:	02f907b3          	mul	a5,s2,a5
    80004402:	97b2                	add	a5,a5,a2
    80004404:	07b1                	addi	a5,a5,12
    80004406:	078a                	slli	a5,a5,0x2
    80004408:	0001d717          	auipc	a4,0x1d
    8000440c:	af870713          	addi	a4,a4,-1288 # 80020f00 <log>
    80004410:	97ba                	add	a5,a5,a4
    80004412:	00c9a703          	lw	a4,12(s3)
    80004416:	c798                	sw	a4,8(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    bpin(b);
    80004418:	854e                	mv	a0,s3
    8000441a:	fffff097          	auipc	ra,0xfffff
    8000441e:	ce0080e7          	jalr	-800(ra) # 800030fa <bpin>
    log[dev].lh.n++;
    80004422:	0b000793          	li	a5,176
    80004426:	02f90933          	mul	s2,s2,a5
    8000442a:	0001d797          	auipc	a5,0x1d
    8000442e:	ad678793          	addi	a5,a5,-1322 # 80020f00 <log>
    80004432:	993e                	add	s2,s2,a5
    80004434:	03492783          	lw	a5,52(s2)
    80004438:	2785                	addiw	a5,a5,1
    8000443a:	02f92a23          	sw	a5,52(s2)
    8000443e:	a099                	j	80004484 <log_write+0x126>
    panic("too big a transaction");
    80004440:	00005517          	auipc	a0,0x5
    80004444:	58050513          	addi	a0,a0,1408 # 800099c0 <userret+0x930>
    80004448:	ffffc097          	auipc	ra,0xffffc
    8000444c:	10c080e7          	jalr	268(ra) # 80000554 <panic>
    panic("log_write outside of trans");
    80004450:	00005517          	auipc	a0,0x5
    80004454:	58850513          	addi	a0,a0,1416 # 800099d8 <userret+0x948>
    80004458:	ffffc097          	auipc	ra,0xffffc
    8000445c:	0fc080e7          	jalr	252(ra) # 80000554 <panic>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004460:	4701                	li	a4,0
  log[dev].lh.block[i] = b->blockno;
    80004462:	02c00793          	li	a5,44
    80004466:	02f907b3          	mul	a5,s2,a5
    8000446a:	97ba                	add	a5,a5,a4
    8000446c:	07b1                	addi	a5,a5,12
    8000446e:	078a                	slli	a5,a5,0x2
    80004470:	0001d697          	auipc	a3,0x1d
    80004474:	a9068693          	addi	a3,a3,-1392 # 80020f00 <log>
    80004478:	97b6                	add	a5,a5,a3
    8000447a:	00c9a683          	lw	a3,12(s3)
    8000447e:	c794                	sw	a3,8(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    80004480:	f8e60ce3          	beq	a2,a4,80004418 <log_write+0xba>
  }
  release(&log[dev].lock);
    80004484:	8552                	mv	a0,s4
    80004486:	ffffc097          	auipc	ra,0xffffc
    8000448a:	6ea080e7          	jalr	1770(ra) # 80000b70 <release>
}
    8000448e:	70a2                	ld	ra,40(sp)
    80004490:	7402                	ld	s0,32(sp)
    80004492:	64e2                	ld	s1,24(sp)
    80004494:	6942                	ld	s2,16(sp)
    80004496:	69a2                	ld	s3,8(sp)
    80004498:	6a02                	ld	s4,0(sp)
    8000449a:	6145                	addi	sp,sp,48
    8000449c:	8082                	ret

000000008000449e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000449e:	1101                	addi	sp,sp,-32
    800044a0:	ec06                	sd	ra,24(sp)
    800044a2:	e822                	sd	s0,16(sp)
    800044a4:	e426                	sd	s1,8(sp)
    800044a6:	e04a                	sd	s2,0(sp)
    800044a8:	1000                	addi	s0,sp,32
    800044aa:	84aa                	mv	s1,a0
    800044ac:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800044ae:	00005597          	auipc	a1,0x5
    800044b2:	54a58593          	addi	a1,a1,1354 # 800099f8 <userret+0x968>
    800044b6:	0521                	addi	a0,a0,8
    800044b8:	ffffc097          	auipc	ra,0xffffc
    800044bc:	514080e7          	jalr	1300(ra) # 800009cc <initlock>
  lk->name = name;
    800044c0:	0324b423          	sd	s2,40(s1)
  lk->locked = 0;
    800044c4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800044c8:	0204a823          	sw	zero,48(s1)
}
    800044cc:	60e2                	ld	ra,24(sp)
    800044ce:	6442                	ld	s0,16(sp)
    800044d0:	64a2                	ld	s1,8(sp)
    800044d2:	6902                	ld	s2,0(sp)
    800044d4:	6105                	addi	sp,sp,32
    800044d6:	8082                	ret

00000000800044d8 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800044d8:	1101                	addi	sp,sp,-32
    800044da:	ec06                	sd	ra,24(sp)
    800044dc:	e822                	sd	s0,16(sp)
    800044de:	e426                	sd	s1,8(sp)
    800044e0:	e04a                	sd	s2,0(sp)
    800044e2:	1000                	addi	s0,sp,32
    800044e4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800044e6:	00850913          	addi	s2,a0,8
    800044ea:	854a                	mv	a0,s2
    800044ec:	ffffc097          	auipc	ra,0xffffc
    800044f0:	5b4080e7          	jalr	1460(ra) # 80000aa0 <acquire>
  while (lk->locked) {
    800044f4:	409c                	lw	a5,0(s1)
    800044f6:	cb89                	beqz	a5,80004508 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800044f8:	85ca                	mv	a1,s2
    800044fa:	8526                	mv	a0,s1
    800044fc:	ffffe097          	auipc	ra,0xffffe
    80004500:	d58080e7          	jalr	-680(ra) # 80002254 <sleep>
  while (lk->locked) {
    80004504:	409c                	lw	a5,0(s1)
    80004506:	fbed                	bnez	a5,800044f8 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004508:	4785                	li	a5,1
    8000450a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000450c:	ffffd097          	auipc	ra,0xffffd
    80004510:	588080e7          	jalr	1416(ra) # 80001a94 <myproc>
    80004514:	413c                	lw	a5,64(a0)
    80004516:	d89c                	sw	a5,48(s1)
  release(&lk->lk);
    80004518:	854a                	mv	a0,s2
    8000451a:	ffffc097          	auipc	ra,0xffffc
    8000451e:	656080e7          	jalr	1622(ra) # 80000b70 <release>
}
    80004522:	60e2                	ld	ra,24(sp)
    80004524:	6442                	ld	s0,16(sp)
    80004526:	64a2                	ld	s1,8(sp)
    80004528:	6902                	ld	s2,0(sp)
    8000452a:	6105                	addi	sp,sp,32
    8000452c:	8082                	ret

000000008000452e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000452e:	1101                	addi	sp,sp,-32
    80004530:	ec06                	sd	ra,24(sp)
    80004532:	e822                	sd	s0,16(sp)
    80004534:	e426                	sd	s1,8(sp)
    80004536:	e04a                	sd	s2,0(sp)
    80004538:	1000                	addi	s0,sp,32
    8000453a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000453c:	00850913          	addi	s2,a0,8
    80004540:	854a                	mv	a0,s2
    80004542:	ffffc097          	auipc	ra,0xffffc
    80004546:	55e080e7          	jalr	1374(ra) # 80000aa0 <acquire>
  lk->locked = 0;
    8000454a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000454e:	0204a823          	sw	zero,48(s1)
  wakeup(lk);
    80004552:	8526                	mv	a0,s1
    80004554:	ffffe097          	auipc	ra,0xffffe
    80004558:	e80080e7          	jalr	-384(ra) # 800023d4 <wakeup>
  release(&lk->lk);
    8000455c:	854a                	mv	a0,s2
    8000455e:	ffffc097          	auipc	ra,0xffffc
    80004562:	612080e7          	jalr	1554(ra) # 80000b70 <release>
}
    80004566:	60e2                	ld	ra,24(sp)
    80004568:	6442                	ld	s0,16(sp)
    8000456a:	64a2                	ld	s1,8(sp)
    8000456c:	6902                	ld	s2,0(sp)
    8000456e:	6105                	addi	sp,sp,32
    80004570:	8082                	ret

0000000080004572 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004572:	7179                	addi	sp,sp,-48
    80004574:	f406                	sd	ra,40(sp)
    80004576:	f022                	sd	s0,32(sp)
    80004578:	ec26                	sd	s1,24(sp)
    8000457a:	e84a                	sd	s2,16(sp)
    8000457c:	e44e                	sd	s3,8(sp)
    8000457e:	1800                	addi	s0,sp,48
    80004580:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004582:	00850913          	addi	s2,a0,8
    80004586:	854a                	mv	a0,s2
    80004588:	ffffc097          	auipc	ra,0xffffc
    8000458c:	518080e7          	jalr	1304(ra) # 80000aa0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004590:	409c                	lw	a5,0(s1)
    80004592:	ef99                	bnez	a5,800045b0 <holdingsleep+0x3e>
    80004594:	4481                	li	s1,0
  release(&lk->lk);
    80004596:	854a                	mv	a0,s2
    80004598:	ffffc097          	auipc	ra,0xffffc
    8000459c:	5d8080e7          	jalr	1496(ra) # 80000b70 <release>
  return r;
}
    800045a0:	8526                	mv	a0,s1
    800045a2:	70a2                	ld	ra,40(sp)
    800045a4:	7402                	ld	s0,32(sp)
    800045a6:	64e2                	ld	s1,24(sp)
    800045a8:	6942                	ld	s2,16(sp)
    800045aa:	69a2                	ld	s3,8(sp)
    800045ac:	6145                	addi	sp,sp,48
    800045ae:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800045b0:	0304a983          	lw	s3,48(s1)
    800045b4:	ffffd097          	auipc	ra,0xffffd
    800045b8:	4e0080e7          	jalr	1248(ra) # 80001a94 <myproc>
    800045bc:	4124                	lw	s1,64(a0)
    800045be:	413484b3          	sub	s1,s1,s3
    800045c2:	0014b493          	seqz	s1,s1
    800045c6:	bfc1                	j	80004596 <holdingsleep+0x24>

00000000800045c8 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800045c8:	1141                	addi	sp,sp,-16
    800045ca:	e406                	sd	ra,8(sp)
    800045cc:	e022                	sd	s0,0(sp)
    800045ce:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800045d0:	00005597          	auipc	a1,0x5
    800045d4:	43858593          	addi	a1,a1,1080 # 80009a08 <userret+0x978>
    800045d8:	0001d517          	auipc	a0,0x1d
    800045dc:	b2850513          	addi	a0,a0,-1240 # 80021100 <ftable>
    800045e0:	ffffc097          	auipc	ra,0xffffc
    800045e4:	3ec080e7          	jalr	1004(ra) # 800009cc <initlock>
}
    800045e8:	60a2                	ld	ra,8(sp)
    800045ea:	6402                	ld	s0,0(sp)
    800045ec:	0141                	addi	sp,sp,16
    800045ee:	8082                	ret

00000000800045f0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800045f0:	1101                	addi	sp,sp,-32
    800045f2:	ec06                	sd	ra,24(sp)
    800045f4:	e822                	sd	s0,16(sp)
    800045f6:	e426                	sd	s1,8(sp)
    800045f8:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800045fa:	0001d517          	auipc	a0,0x1d
    800045fe:	b0650513          	addi	a0,a0,-1274 # 80021100 <ftable>
    80004602:	ffffc097          	auipc	ra,0xffffc
    80004606:	49e080e7          	jalr	1182(ra) # 80000aa0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000460a:	0001d497          	auipc	s1,0x1d
    8000460e:	b1648493          	addi	s1,s1,-1258 # 80021120 <ftable+0x20>
    80004612:	0001e717          	auipc	a4,0x1e
    80004616:	0ee70713          	addi	a4,a4,238 # 80022700 <ftable+0x1600>
    if(f->ref == 0){
    8000461a:	40dc                	lw	a5,4(s1)
    8000461c:	cf99                	beqz	a5,8000463a <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000461e:	03848493          	addi	s1,s1,56
    80004622:	fee49ce3          	bne	s1,a4,8000461a <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004626:	0001d517          	auipc	a0,0x1d
    8000462a:	ada50513          	addi	a0,a0,-1318 # 80021100 <ftable>
    8000462e:	ffffc097          	auipc	ra,0xffffc
    80004632:	542080e7          	jalr	1346(ra) # 80000b70 <release>
  return 0;
    80004636:	4481                	li	s1,0
    80004638:	a819                	j	8000464e <filealloc+0x5e>
      f->ref = 1;
    8000463a:	4785                	li	a5,1
    8000463c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000463e:	0001d517          	auipc	a0,0x1d
    80004642:	ac250513          	addi	a0,a0,-1342 # 80021100 <ftable>
    80004646:	ffffc097          	auipc	ra,0xffffc
    8000464a:	52a080e7          	jalr	1322(ra) # 80000b70 <release>
}
    8000464e:	8526                	mv	a0,s1
    80004650:	60e2                	ld	ra,24(sp)
    80004652:	6442                	ld	s0,16(sp)
    80004654:	64a2                	ld	s1,8(sp)
    80004656:	6105                	addi	sp,sp,32
    80004658:	8082                	ret

000000008000465a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000465a:	1101                	addi	sp,sp,-32
    8000465c:	ec06                	sd	ra,24(sp)
    8000465e:	e822                	sd	s0,16(sp)
    80004660:	e426                	sd	s1,8(sp)
    80004662:	1000                	addi	s0,sp,32
    80004664:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004666:	0001d517          	auipc	a0,0x1d
    8000466a:	a9a50513          	addi	a0,a0,-1382 # 80021100 <ftable>
    8000466e:	ffffc097          	auipc	ra,0xffffc
    80004672:	432080e7          	jalr	1074(ra) # 80000aa0 <acquire>
  if(f->ref < 1)
    80004676:	40dc                	lw	a5,4(s1)
    80004678:	02f05263          	blez	a5,8000469c <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000467c:	2785                	addiw	a5,a5,1
    8000467e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004680:	0001d517          	auipc	a0,0x1d
    80004684:	a8050513          	addi	a0,a0,-1408 # 80021100 <ftable>
    80004688:	ffffc097          	auipc	ra,0xffffc
    8000468c:	4e8080e7          	jalr	1256(ra) # 80000b70 <release>
  return f;
}
    80004690:	8526                	mv	a0,s1
    80004692:	60e2                	ld	ra,24(sp)
    80004694:	6442                	ld	s0,16(sp)
    80004696:	64a2                	ld	s1,8(sp)
    80004698:	6105                	addi	sp,sp,32
    8000469a:	8082                	ret
    panic("filedup");
    8000469c:	00005517          	auipc	a0,0x5
    800046a0:	37450513          	addi	a0,a0,884 # 80009a10 <userret+0x980>
    800046a4:	ffffc097          	auipc	ra,0xffffc
    800046a8:	eb0080e7          	jalr	-336(ra) # 80000554 <panic>

00000000800046ac <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800046ac:	7139                	addi	sp,sp,-64
    800046ae:	fc06                	sd	ra,56(sp)
    800046b0:	f822                	sd	s0,48(sp)
    800046b2:	f426                	sd	s1,40(sp)
    800046b4:	f04a                	sd	s2,32(sp)
    800046b6:	ec4e                	sd	s3,24(sp)
    800046b8:	e852                	sd	s4,16(sp)
    800046ba:	e456                	sd	s5,8(sp)
    800046bc:	e05a                	sd	s6,0(sp)
    800046be:	0080                	addi	s0,sp,64
    800046c0:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800046c2:	0001d517          	auipc	a0,0x1d
    800046c6:	a3e50513          	addi	a0,a0,-1474 # 80021100 <ftable>
    800046ca:	ffffc097          	auipc	ra,0xffffc
    800046ce:	3d6080e7          	jalr	982(ra) # 80000aa0 <acquire>
  if(f->ref < 1)
    800046d2:	40dc                	lw	a5,4(s1)
    800046d4:	04f05f63          	blez	a5,80004732 <fileclose+0x86>
    panic("fileclose");
  if(--f->ref > 0){
    800046d8:	37fd                	addiw	a5,a5,-1
    800046da:	0007871b          	sext.w	a4,a5
    800046de:	c0dc                	sw	a5,4(s1)
    800046e0:	06e04163          	bgtz	a4,80004742 <fileclose+0x96>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800046e4:	0004a903          	lw	s2,0(s1)
    800046e8:	0094ca83          	lbu	s5,9(s1)
    800046ec:	0184ba03          	ld	s4,24(s1)
    800046f0:	0204b983          	ld	s3,32(s1)
    800046f4:	0284bb03          	ld	s6,40(s1)
  f->ref = 0;
    800046f8:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800046fc:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004700:	0001d517          	auipc	a0,0x1d
    80004704:	a0050513          	addi	a0,a0,-1536 # 80021100 <ftable>
    80004708:	ffffc097          	auipc	ra,0xffffc
    8000470c:	468080e7          	jalr	1128(ra) # 80000b70 <release>

  if(ff.type == FD_PIPE){
    80004710:	4785                	li	a5,1
    80004712:	04f90a63          	beq	s2,a5,80004766 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004716:	ffe9079b          	addiw	a5,s2,-2
    8000471a:	4705                	li	a4,1
    8000471c:	04f77c63          	bgeu	a4,a5,80004774 <fileclose+0xc8>
    begin_op(ff.ip->dev);
    iput(ff.ip);
    end_op(ff.ip->dev);
  } else if(ff.type == FD_SOCK){  // 新增套接字关闭处理
    80004720:	4791                	li	a5,4
    80004722:	02f91863          	bne	s2,a5,80004752 <fileclose+0xa6>
    sockclose(ff.sock);
    80004726:	855a                	mv	a0,s6
    80004728:	00003097          	auipc	ra,0x3
    8000472c:	d06080e7          	jalr	-762(ra) # 8000742e <sockclose>
    80004730:	a00d                	j	80004752 <fileclose+0xa6>
    panic("fileclose");
    80004732:	00005517          	auipc	a0,0x5
    80004736:	2e650513          	addi	a0,a0,742 # 80009a18 <userret+0x988>
    8000473a:	ffffc097          	auipc	ra,0xffffc
    8000473e:	e1a080e7          	jalr	-486(ra) # 80000554 <panic>
    release(&ftable.lock);
    80004742:	0001d517          	auipc	a0,0x1d
    80004746:	9be50513          	addi	a0,a0,-1602 # 80021100 <ftable>
    8000474a:	ffffc097          	auipc	ra,0xffffc
    8000474e:	426080e7          	jalr	1062(ra) # 80000b70 <release>
  }
}
    80004752:	70e2                	ld	ra,56(sp)
    80004754:	7442                	ld	s0,48(sp)
    80004756:	74a2                	ld	s1,40(sp)
    80004758:	7902                	ld	s2,32(sp)
    8000475a:	69e2                	ld	s3,24(sp)
    8000475c:	6a42                	ld	s4,16(sp)
    8000475e:	6aa2                	ld	s5,8(sp)
    80004760:	6b02                	ld	s6,0(sp)
    80004762:	6121                	addi	sp,sp,64
    80004764:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004766:	85d6                	mv	a1,s5
    80004768:	8552                	mv	a0,s4
    8000476a:	00000097          	auipc	ra,0x0
    8000476e:	3be080e7          	jalr	958(ra) # 80004b28 <pipeclose>
    80004772:	b7c5                	j	80004752 <fileclose+0xa6>
    begin_op(ff.ip->dev);
    80004774:	0009a503          	lw	a0,0(s3)
    80004778:	00000097          	auipc	ra,0x0
    8000477c:	99a080e7          	jalr	-1638(ra) # 80004112 <begin_op>
    iput(ff.ip);
    80004780:	854e                	mv	a0,s3
    80004782:	fffff097          	auipc	ra,0xfffff
    80004786:	0ba080e7          	jalr	186(ra) # 8000383c <iput>
    end_op(ff.ip->dev);
    8000478a:	0009a503          	lw	a0,0(s3)
    8000478e:	00000097          	auipc	ra,0x0
    80004792:	a2e080e7          	jalr	-1490(ra) # 800041bc <end_op>
    80004796:	bf75                	j	80004752 <fileclose+0xa6>

0000000080004798 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004798:	715d                	addi	sp,sp,-80
    8000479a:	e486                	sd	ra,72(sp)
    8000479c:	e0a2                	sd	s0,64(sp)
    8000479e:	fc26                	sd	s1,56(sp)
    800047a0:	f84a                	sd	s2,48(sp)
    800047a2:	f44e                	sd	s3,40(sp)
    800047a4:	0880                	addi	s0,sp,80
    800047a6:	84aa                	mv	s1,a0
    800047a8:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800047aa:	ffffd097          	auipc	ra,0xffffd
    800047ae:	2ea080e7          	jalr	746(ra) # 80001a94 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800047b2:	409c                	lw	a5,0(s1)
    800047b4:	37f9                	addiw	a5,a5,-2
    800047b6:	4705                	li	a4,1
    800047b8:	04f76763          	bltu	a4,a5,80004806 <filestat+0x6e>
    800047bc:	892a                	mv	s2,a0
    ilock(f->ip);
    800047be:	7088                	ld	a0,32(s1)
    800047c0:	fffff097          	auipc	ra,0xfffff
    800047c4:	f6e080e7          	jalr	-146(ra) # 8000372e <ilock>
    stati(f->ip, &st);
    800047c8:	fb840593          	addi	a1,s0,-72
    800047cc:	7088                	ld	a0,32(s1)
    800047ce:	fffff097          	auipc	ra,0xfffff
    800047d2:	1c6080e7          	jalr	454(ra) # 80003994 <stati>
    iunlock(f->ip);
    800047d6:	7088                	ld	a0,32(s1)
    800047d8:	fffff097          	auipc	ra,0xfffff
    800047dc:	018080e7          	jalr	24(ra) # 800037f0 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800047e0:	46e1                	li	a3,24
    800047e2:	fb840613          	addi	a2,s0,-72
    800047e6:	85ce                	mv	a1,s3
    800047e8:	05893503          	ld	a0,88(s2)
    800047ec:	ffffd097          	auipc	ra,0xffffd
    800047f0:	f9a080e7          	jalr	-102(ra) # 80001786 <copyout>
    800047f4:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800047f8:	60a6                	ld	ra,72(sp)
    800047fa:	6406                	ld	s0,64(sp)
    800047fc:	74e2                	ld	s1,56(sp)
    800047fe:	7942                	ld	s2,48(sp)
    80004800:	79a2                	ld	s3,40(sp)
    80004802:	6161                	addi	sp,sp,80
    80004804:	8082                	ret
  return -1;
    80004806:	557d                	li	a0,-1
    80004808:	bfc5                	j	800047f8 <filestat+0x60>

000000008000480a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000480a:	7179                	addi	sp,sp,-48
    8000480c:	f406                	sd	ra,40(sp)
    8000480e:	f022                	sd	s0,32(sp)
    80004810:	ec26                	sd	s1,24(sp)
    80004812:	e84a                	sd	s2,16(sp)
    80004814:	e44e                	sd	s3,8(sp)
    80004816:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004818:	00854783          	lbu	a5,8(a0)
    8000481c:	cfd5                	beqz	a5,800048d8 <fileread+0xce>
    8000481e:	84aa                	mv	s1,a0
    80004820:	89ae                	mv	s3,a1
    80004822:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004824:	411c                	lw	a5,0(a0)
    80004826:	4705                	li	a4,1
    80004828:	02e78963          	beq	a5,a4,8000485a <fileread+0x50>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000482c:	470d                	li	a4,3
    8000482e:	02e78d63          	beq	a5,a4,80004868 <fileread+0x5e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80004832:	4709                	li	a4,2
    80004834:	06e78063          	beq	a5,a4,80004894 <fileread+0x8a>
    ilock(f->ip);
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
  } else if(f->type == FD_SOCK){  // 新增套接字读取处理
    80004838:	4711                	li	a4,4
    8000483a:	08e79763          	bne	a5,a4,800048c8 <fileread+0xbe>
    r = sockread(f->sock, addr, n);
    8000483e:	7508                	ld	a0,40(a0)
    80004840:	00003097          	auipc	ra,0x3
    80004844:	a94080e7          	jalr	-1388(ra) # 800072d4 <sockread>
    80004848:	892a                	mv	s2,a0
  } else {
    panic("fileread");
  }

  return r;
}
    8000484a:	854a                	mv	a0,s2
    8000484c:	70a2                	ld	ra,40(sp)
    8000484e:	7402                	ld	s0,32(sp)
    80004850:	64e2                	ld	s1,24(sp)
    80004852:	6942                	ld	s2,16(sp)
    80004854:	69a2                	ld	s3,8(sp)
    80004856:	6145                	addi	sp,sp,48
    80004858:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000485a:	6d08                	ld	a0,24(a0)
    8000485c:	00000097          	auipc	ra,0x0
    80004860:	44a080e7          	jalr	1098(ra) # 80004ca6 <piperead>
    80004864:	892a                	mv	s2,a0
    80004866:	b7d5                	j	8000484a <fileread+0x40>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004868:	03451783          	lh	a5,52(a0)
    8000486c:	03079693          	slli	a3,a5,0x30
    80004870:	92c1                	srli	a3,a3,0x30
    80004872:	4725                	li	a4,9
    80004874:	06d76463          	bltu	a4,a3,800048dc <fileread+0xd2>
    80004878:	0792                	slli	a5,a5,0x4
    8000487a:	0001c717          	auipc	a4,0x1c
    8000487e:	7e670713          	addi	a4,a4,2022 # 80021060 <devsw>
    80004882:	97ba                	add	a5,a5,a4
    80004884:	639c                	ld	a5,0(a5)
    80004886:	cfa9                	beqz	a5,800048e0 <fileread+0xd6>
    r = devsw[f->major].read(f, 1, addr, n);
    80004888:	86b2                	mv	a3,a2
    8000488a:	862e                	mv	a2,a1
    8000488c:	4585                	li	a1,1
    8000488e:	9782                	jalr	a5
    80004890:	892a                	mv	s2,a0
    80004892:	bf65                	j	8000484a <fileread+0x40>
    ilock(f->ip);
    80004894:	7108                	ld	a0,32(a0)
    80004896:	fffff097          	auipc	ra,0xfffff
    8000489a:	e98080e7          	jalr	-360(ra) # 8000372e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000489e:	874a                	mv	a4,s2
    800048a0:	5894                	lw	a3,48(s1)
    800048a2:	864e                	mv	a2,s3
    800048a4:	4585                	li	a1,1
    800048a6:	7088                	ld	a0,32(s1)
    800048a8:	fffff097          	auipc	ra,0xfffff
    800048ac:	116080e7          	jalr	278(ra) # 800039be <readi>
    800048b0:	892a                	mv	s2,a0
    800048b2:	00a05563          	blez	a0,800048bc <fileread+0xb2>
      f->off += r;
    800048b6:	589c                	lw	a5,48(s1)
    800048b8:	9fa9                	addw	a5,a5,a0
    800048ba:	d89c                	sw	a5,48(s1)
    iunlock(f->ip);
    800048bc:	7088                	ld	a0,32(s1)
    800048be:	fffff097          	auipc	ra,0xfffff
    800048c2:	f32080e7          	jalr	-206(ra) # 800037f0 <iunlock>
    800048c6:	b751                	j	8000484a <fileread+0x40>
    panic("fileread");
    800048c8:	00005517          	auipc	a0,0x5
    800048cc:	16050513          	addi	a0,a0,352 # 80009a28 <userret+0x998>
    800048d0:	ffffc097          	auipc	ra,0xffffc
    800048d4:	c84080e7          	jalr	-892(ra) # 80000554 <panic>
    return -1;
    800048d8:	597d                	li	s2,-1
    800048da:	bf85                	j	8000484a <fileread+0x40>
      return -1;
    800048dc:	597d                	li	s2,-1
    800048de:	b7b5                	j	8000484a <fileread+0x40>
    800048e0:	597d                	li	s2,-1
    800048e2:	b7a5                	j	8000484a <fileread+0x40>

00000000800048e4 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800048e4:	00954783          	lbu	a5,9(a0)
    800048e8:	14078e63          	beqz	a5,80004a44 <filewrite+0x160>
{
    800048ec:	715d                	addi	sp,sp,-80
    800048ee:	e486                	sd	ra,72(sp)
    800048f0:	e0a2                	sd	s0,64(sp)
    800048f2:	fc26                	sd	s1,56(sp)
    800048f4:	f84a                	sd	s2,48(sp)
    800048f6:	f44e                	sd	s3,40(sp)
    800048f8:	f052                	sd	s4,32(sp)
    800048fa:	ec56                	sd	s5,24(sp)
    800048fc:	e85a                	sd	s6,16(sp)
    800048fe:	e45e                	sd	s7,8(sp)
    80004900:	e062                	sd	s8,0(sp)
    80004902:	0880                	addi	s0,sp,80
    80004904:	84aa                	mv	s1,a0
    80004906:	8aae                	mv	s5,a1
    80004908:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000490a:	411c                	lw	a5,0(a0)
    8000490c:	4705                	li	a4,1
    8000490e:	02e78c63          	beq	a5,a4,80004946 <filewrite+0x62>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004912:	470d                	li	a4,3
    80004914:	02e78f63          	beq	a5,a4,80004952 <filewrite+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80004918:	4709                	li	a4,2
    8000491a:	06e78163          	beq	a5,a4,8000497c <filewrite+0x98>
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    ret = (i == n ? n : -1);
  } else if(f->type == FD_SOCK){  // 新增套接字写入处理
    8000491e:	4711                	li	a4,4
    80004920:	10e79a63          	bne	a5,a4,80004a34 <filewrite+0x150>
    ret = sockwrite(f->sock, addr, n);
    80004924:	7508                	ld	a0,40(a0)
    80004926:	00003097          	auipc	ra,0x3
    8000492a:	a7e080e7          	jalr	-1410(ra) # 800073a4 <sockwrite>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000492e:	60a6                	ld	ra,72(sp)
    80004930:	6406                	ld	s0,64(sp)
    80004932:	74e2                	ld	s1,56(sp)
    80004934:	7942                	ld	s2,48(sp)
    80004936:	79a2                	ld	s3,40(sp)
    80004938:	7a02                	ld	s4,32(sp)
    8000493a:	6ae2                	ld	s5,24(sp)
    8000493c:	6b42                	ld	s6,16(sp)
    8000493e:	6ba2                	ld	s7,8(sp)
    80004940:	6c02                	ld	s8,0(sp)
    80004942:	6161                	addi	sp,sp,80
    80004944:	8082                	ret
    ret = pipewrite(f->pipe, addr, n);
    80004946:	6d08                	ld	a0,24(a0)
    80004948:	00000097          	auipc	ra,0x0
    8000494c:	250080e7          	jalr	592(ra) # 80004b98 <pipewrite>
    80004950:	bff9                	j	8000492e <filewrite+0x4a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004952:	03451783          	lh	a5,52(a0)
    80004956:	03079693          	slli	a3,a5,0x30
    8000495a:	92c1                	srli	a3,a3,0x30
    8000495c:	4725                	li	a4,9
    8000495e:	0ed76563          	bltu	a4,a3,80004a48 <filewrite+0x164>
    80004962:	0792                	slli	a5,a5,0x4
    80004964:	0001c717          	auipc	a4,0x1c
    80004968:	6fc70713          	addi	a4,a4,1788 # 80021060 <devsw>
    8000496c:	97ba                	add	a5,a5,a4
    8000496e:	679c                	ld	a5,8(a5)
    80004970:	cff1                	beqz	a5,80004a4c <filewrite+0x168>
    ret = devsw[f->major].write(f, 1, addr, n);
    80004972:	86b2                	mv	a3,a2
    80004974:	862e                	mv	a2,a1
    80004976:	4585                	li	a1,1
    80004978:	9782                	jalr	a5
    8000497a:	bf55                	j	8000492e <filewrite+0x4a>
    while(i < n){
    8000497c:	0ac05a63          	blez	a2,80004a30 <filewrite+0x14c>
    int i = 0;
    80004980:	4981                	li	s3,0
    80004982:	6b05                	lui	s6,0x1
    80004984:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004988:	6b85                	lui	s7,0x1
    8000498a:	c00b8b9b          	addiw	s7,s7,-1024
    8000498e:	a8b9                	j	800049ec <filewrite+0x108>
    80004990:	00090c1b          	sext.w	s8,s2
      begin_op(f->ip->dev);
    80004994:	709c                	ld	a5,32(s1)
    80004996:	4388                	lw	a0,0(a5)
    80004998:	fffff097          	auipc	ra,0xfffff
    8000499c:	77a080e7          	jalr	1914(ra) # 80004112 <begin_op>
      ilock(f->ip);
    800049a0:	7088                	ld	a0,32(s1)
    800049a2:	fffff097          	auipc	ra,0xfffff
    800049a6:	d8c080e7          	jalr	-628(ra) # 8000372e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800049aa:	8762                	mv	a4,s8
    800049ac:	5894                	lw	a3,48(s1)
    800049ae:	01598633          	add	a2,s3,s5
    800049b2:	4585                	li	a1,1
    800049b4:	7088                	ld	a0,32(s1)
    800049b6:	fffff097          	auipc	ra,0xfffff
    800049ba:	0fc080e7          	jalr	252(ra) # 80003ab2 <writei>
    800049be:	892a                	mv	s2,a0
    800049c0:	02a05e63          	blez	a0,800049fc <filewrite+0x118>
        f->off += r;
    800049c4:	589c                	lw	a5,48(s1)
    800049c6:	9fa9                	addw	a5,a5,a0
    800049c8:	d89c                	sw	a5,48(s1)
      iunlock(f->ip);
    800049ca:	7088                	ld	a0,32(s1)
    800049cc:	fffff097          	auipc	ra,0xfffff
    800049d0:	e24080e7          	jalr	-476(ra) # 800037f0 <iunlock>
      end_op(f->ip->dev);
    800049d4:	709c                	ld	a5,32(s1)
    800049d6:	4388                	lw	a0,0(a5)
    800049d8:	fffff097          	auipc	ra,0xfffff
    800049dc:	7e4080e7          	jalr	2020(ra) # 800041bc <end_op>
      if(r != n1)
    800049e0:	052c1063          	bne	s8,s2,80004a20 <filewrite+0x13c>
      i += r;
    800049e4:	013909bb          	addw	s3,s2,s3
    while(i < n){
    800049e8:	0349d763          	bge	s3,s4,80004a16 <filewrite+0x132>
      int n1 = n - i;
    800049ec:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800049f0:	893e                	mv	s2,a5
    800049f2:	2781                	sext.w	a5,a5
    800049f4:	f8fb5ee3          	bge	s6,a5,80004990 <filewrite+0xac>
    800049f8:	895e                	mv	s2,s7
    800049fa:	bf59                	j	80004990 <filewrite+0xac>
      iunlock(f->ip);
    800049fc:	7088                	ld	a0,32(s1)
    800049fe:	fffff097          	auipc	ra,0xfffff
    80004a02:	df2080e7          	jalr	-526(ra) # 800037f0 <iunlock>
      end_op(f->ip->dev);
    80004a06:	709c                	ld	a5,32(s1)
    80004a08:	4388                	lw	a0,0(a5)
    80004a0a:	fffff097          	auipc	ra,0xfffff
    80004a0e:	7b2080e7          	jalr	1970(ra) # 800041bc <end_op>
      if(r < 0)
    80004a12:	fc0957e3          	bgez	s2,800049e0 <filewrite+0xfc>
    ret = (i == n ? n : -1);
    80004a16:	8552                	mv	a0,s4
    80004a18:	f13a0be3          	beq	s4,s3,8000492e <filewrite+0x4a>
    80004a1c:	557d                	li	a0,-1
    80004a1e:	bf01                	j	8000492e <filewrite+0x4a>
        panic("short filewrite");
    80004a20:	00005517          	auipc	a0,0x5
    80004a24:	01850513          	addi	a0,a0,24 # 80009a38 <userret+0x9a8>
    80004a28:	ffffc097          	auipc	ra,0xffffc
    80004a2c:	b2c080e7          	jalr	-1236(ra) # 80000554 <panic>
    int i = 0;
    80004a30:	4981                	li	s3,0
    80004a32:	b7d5                	j	80004a16 <filewrite+0x132>
    panic("filewrite");
    80004a34:	00005517          	auipc	a0,0x5
    80004a38:	01450513          	addi	a0,a0,20 # 80009a48 <userret+0x9b8>
    80004a3c:	ffffc097          	auipc	ra,0xffffc
    80004a40:	b18080e7          	jalr	-1256(ra) # 80000554 <panic>
    return -1;
    80004a44:	557d                	li	a0,-1
}
    80004a46:	8082                	ret
      return -1;
    80004a48:	557d                	li	a0,-1
    80004a4a:	b5d5                	j	8000492e <filewrite+0x4a>
    80004a4c:	557d                	li	a0,-1
    80004a4e:	b5c5                	j	8000492e <filewrite+0x4a>

0000000080004a50 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004a50:	7179                	addi	sp,sp,-48
    80004a52:	f406                	sd	ra,40(sp)
    80004a54:	f022                	sd	s0,32(sp)
    80004a56:	ec26                	sd	s1,24(sp)
    80004a58:	e84a                	sd	s2,16(sp)
    80004a5a:	e44e                	sd	s3,8(sp)
    80004a5c:	e052                	sd	s4,0(sp)
    80004a5e:	1800                	addi	s0,sp,48
    80004a60:	84aa                	mv	s1,a0
    80004a62:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004a64:	0005b023          	sd	zero,0(a1)
    80004a68:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004a6c:	00000097          	auipc	ra,0x0
    80004a70:	b84080e7          	jalr	-1148(ra) # 800045f0 <filealloc>
    80004a74:	e088                	sd	a0,0(s1)
    80004a76:	c549                	beqz	a0,80004b00 <pipealloc+0xb0>
    80004a78:	00000097          	auipc	ra,0x0
    80004a7c:	b78080e7          	jalr	-1160(ra) # 800045f0 <filealloc>
    80004a80:	00aa3023          	sd	a0,0(s4)
    80004a84:	c925                	beqz	a0,80004af4 <pipealloc+0xa4>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004a86:	ffffc097          	auipc	ra,0xffffc
    80004a8a:	ee6080e7          	jalr	-282(ra) # 8000096c <kalloc>
    80004a8e:	892a                	mv	s2,a0
    80004a90:	cd39                	beqz	a0,80004aee <pipealloc+0x9e>
    goto bad;
  pi->readopen = 1;
    80004a92:	4985                	li	s3,1
    80004a94:	23352423          	sw	s3,552(a0)
  pi->writeopen = 1;
    80004a98:	23352623          	sw	s3,556(a0)
  pi->nwrite = 0;
    80004a9c:	22052223          	sw	zero,548(a0)
  pi->nread = 0;
    80004aa0:	22052023          	sw	zero,544(a0)
  memset(&pi->lock, 0, sizeof(pi->lock));
    80004aa4:	02000613          	li	a2,32
    80004aa8:	4581                	li	a1,0
    80004aaa:	ffffc097          	auipc	ra,0xffffc
    80004aae:	2c4080e7          	jalr	708(ra) # 80000d6e <memset>
  (*f0)->type = FD_PIPE;
    80004ab2:	609c                	ld	a5,0(s1)
    80004ab4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004ab8:	609c                	ld	a5,0(s1)
    80004aba:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004abe:	609c                	ld	a5,0(s1)
    80004ac0:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004ac4:	609c                	ld	a5,0(s1)
    80004ac6:	0127bc23          	sd	s2,24(a5)
  (*f1)->type = FD_PIPE;
    80004aca:	000a3783          	ld	a5,0(s4)
    80004ace:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004ad2:	000a3783          	ld	a5,0(s4)
    80004ad6:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004ada:	000a3783          	ld	a5,0(s4)
    80004ade:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004ae2:	000a3783          	ld	a5,0(s4)
    80004ae6:	0127bc23          	sd	s2,24(a5)
  return 0;
    80004aea:	4501                	li	a0,0
    80004aec:	a025                	j	80004b14 <pipealloc+0xc4>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004aee:	6088                	ld	a0,0(s1)
    80004af0:	e501                	bnez	a0,80004af8 <pipealloc+0xa8>
    80004af2:	a039                	j	80004b00 <pipealloc+0xb0>
    80004af4:	6088                	ld	a0,0(s1)
    80004af6:	c51d                	beqz	a0,80004b24 <pipealloc+0xd4>
    fileclose(*f0);
    80004af8:	00000097          	auipc	ra,0x0
    80004afc:	bb4080e7          	jalr	-1100(ra) # 800046ac <fileclose>
  if(*f1)
    80004b00:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004b04:	557d                	li	a0,-1
  if(*f1)
    80004b06:	c799                	beqz	a5,80004b14 <pipealloc+0xc4>
    fileclose(*f1);
    80004b08:	853e                	mv	a0,a5
    80004b0a:	00000097          	auipc	ra,0x0
    80004b0e:	ba2080e7          	jalr	-1118(ra) # 800046ac <fileclose>
  return -1;
    80004b12:	557d                	li	a0,-1
}
    80004b14:	70a2                	ld	ra,40(sp)
    80004b16:	7402                	ld	s0,32(sp)
    80004b18:	64e2                	ld	s1,24(sp)
    80004b1a:	6942                	ld	s2,16(sp)
    80004b1c:	69a2                	ld	s3,8(sp)
    80004b1e:	6a02                	ld	s4,0(sp)
    80004b20:	6145                	addi	sp,sp,48
    80004b22:	8082                	ret
  return -1;
    80004b24:	557d                	li	a0,-1
    80004b26:	b7fd                	j	80004b14 <pipealloc+0xc4>

0000000080004b28 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004b28:	1101                	addi	sp,sp,-32
    80004b2a:	ec06                	sd	ra,24(sp)
    80004b2c:	e822                	sd	s0,16(sp)
    80004b2e:	e426                	sd	s1,8(sp)
    80004b30:	e04a                	sd	s2,0(sp)
    80004b32:	1000                	addi	s0,sp,32
    80004b34:	84aa                	mv	s1,a0
    80004b36:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004b38:	ffffc097          	auipc	ra,0xffffc
    80004b3c:	f68080e7          	jalr	-152(ra) # 80000aa0 <acquire>
  if(writable){
    80004b40:	02090d63          	beqz	s2,80004b7a <pipeclose+0x52>
    pi->writeopen = 0;
    80004b44:	2204a623          	sw	zero,556(s1)
    wakeup(&pi->nread);
    80004b48:	22048513          	addi	a0,s1,544
    80004b4c:	ffffe097          	auipc	ra,0xffffe
    80004b50:	888080e7          	jalr	-1912(ra) # 800023d4 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004b54:	2284b783          	ld	a5,552(s1)
    80004b58:	eb95                	bnez	a5,80004b8c <pipeclose+0x64>
    release(&pi->lock);
    80004b5a:	8526                	mv	a0,s1
    80004b5c:	ffffc097          	auipc	ra,0xffffc
    80004b60:	014080e7          	jalr	20(ra) # 80000b70 <release>
    kfree((char*)pi);
    80004b64:	8526                	mv	a0,s1
    80004b66:	ffffc097          	auipc	ra,0xffffc
    80004b6a:	d0a080e7          	jalr	-758(ra) # 80000870 <kfree>
  } else
    release(&pi->lock);
}
    80004b6e:	60e2                	ld	ra,24(sp)
    80004b70:	6442                	ld	s0,16(sp)
    80004b72:	64a2                	ld	s1,8(sp)
    80004b74:	6902                	ld	s2,0(sp)
    80004b76:	6105                	addi	sp,sp,32
    80004b78:	8082                	ret
    pi->readopen = 0;
    80004b7a:	2204a423          	sw	zero,552(s1)
    wakeup(&pi->nwrite);
    80004b7e:	22448513          	addi	a0,s1,548
    80004b82:	ffffe097          	auipc	ra,0xffffe
    80004b86:	852080e7          	jalr	-1966(ra) # 800023d4 <wakeup>
    80004b8a:	b7e9                	j	80004b54 <pipeclose+0x2c>
    release(&pi->lock);
    80004b8c:	8526                	mv	a0,s1
    80004b8e:	ffffc097          	auipc	ra,0xffffc
    80004b92:	fe2080e7          	jalr	-30(ra) # 80000b70 <release>
}
    80004b96:	bfe1                	j	80004b6e <pipeclose+0x46>

0000000080004b98 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004b98:	711d                	addi	sp,sp,-96
    80004b9a:	ec86                	sd	ra,88(sp)
    80004b9c:	e8a2                	sd	s0,80(sp)
    80004b9e:	e4a6                	sd	s1,72(sp)
    80004ba0:	e0ca                	sd	s2,64(sp)
    80004ba2:	fc4e                	sd	s3,56(sp)
    80004ba4:	f852                	sd	s4,48(sp)
    80004ba6:	f456                	sd	s5,40(sp)
    80004ba8:	f05a                	sd	s6,32(sp)
    80004baa:	ec5e                	sd	s7,24(sp)
    80004bac:	e862                	sd	s8,16(sp)
    80004bae:	1080                	addi	s0,sp,96
    80004bb0:	84aa                	mv	s1,a0
    80004bb2:	8aae                	mv	s5,a1
    80004bb4:	8a32                	mv	s4,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004bb6:	ffffd097          	auipc	ra,0xffffd
    80004bba:	ede080e7          	jalr	-290(ra) # 80001a94 <myproc>
    80004bbe:	8baa                	mv	s7,a0

  acquire(&pi->lock);
    80004bc0:	8526                	mv	a0,s1
    80004bc2:	ffffc097          	auipc	ra,0xffffc
    80004bc6:	ede080e7          	jalr	-290(ra) # 80000aa0 <acquire>
  for(i = 0; i < n; i++){
    80004bca:	09405f63          	blez	s4,80004c68 <pipewrite+0xd0>
    80004bce:	fffa0b1b          	addiw	s6,s4,-1
    80004bd2:	1b02                	slli	s6,s6,0x20
    80004bd4:	020b5b13          	srli	s6,s6,0x20
    80004bd8:	001a8793          	addi	a5,s5,1
    80004bdc:	9b3e                	add	s6,s6,a5
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || myproc()->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004bde:	22048993          	addi	s3,s1,544
      sleep(&pi->nwrite, &pi->lock);
    80004be2:	22448913          	addi	s2,s1,548
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004be6:	5c7d                	li	s8,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004be8:	2204a783          	lw	a5,544(s1)
    80004bec:	2244a703          	lw	a4,548(s1)
    80004bf0:	2007879b          	addiw	a5,a5,512
    80004bf4:	02f71e63          	bne	a4,a5,80004c30 <pipewrite+0x98>
      if(pi->readopen == 0 || myproc()->killed){
    80004bf8:	2284a783          	lw	a5,552(s1)
    80004bfc:	c3d9                	beqz	a5,80004c82 <pipewrite+0xea>
    80004bfe:	ffffd097          	auipc	ra,0xffffd
    80004c02:	e96080e7          	jalr	-362(ra) # 80001a94 <myproc>
    80004c06:	5d1c                	lw	a5,56(a0)
    80004c08:	efad                	bnez	a5,80004c82 <pipewrite+0xea>
      wakeup(&pi->nread);
    80004c0a:	854e                	mv	a0,s3
    80004c0c:	ffffd097          	auipc	ra,0xffffd
    80004c10:	7c8080e7          	jalr	1992(ra) # 800023d4 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c14:	85a6                	mv	a1,s1
    80004c16:	854a                	mv	a0,s2
    80004c18:	ffffd097          	auipc	ra,0xffffd
    80004c1c:	63c080e7          	jalr	1596(ra) # 80002254 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004c20:	2204a783          	lw	a5,544(s1)
    80004c24:	2244a703          	lw	a4,548(s1)
    80004c28:	2007879b          	addiw	a5,a5,512
    80004c2c:	fcf706e3          	beq	a4,a5,80004bf8 <pipewrite+0x60>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c30:	4685                	li	a3,1
    80004c32:	8656                	mv	a2,s5
    80004c34:	faf40593          	addi	a1,s0,-81
    80004c38:	058bb503          	ld	a0,88(s7) # 1058 <_entry-0x7fffefa8>
    80004c3c:	ffffd097          	auipc	ra,0xffffd
    80004c40:	bd6080e7          	jalr	-1066(ra) # 80001812 <copyin>
    80004c44:	03850263          	beq	a0,s8,80004c68 <pipewrite+0xd0>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004c48:	2244a783          	lw	a5,548(s1)
    80004c4c:	0017871b          	addiw	a4,a5,1
    80004c50:	22e4a223          	sw	a4,548(s1)
    80004c54:	1ff7f793          	andi	a5,a5,511
    80004c58:	97a6                	add	a5,a5,s1
    80004c5a:	faf44703          	lbu	a4,-81(s0)
    80004c5e:	02e78023          	sb	a4,32(a5)
  for(i = 0; i < n; i++){
    80004c62:	0a85                	addi	s5,s5,1
    80004c64:	f96a92e3          	bne	s5,s6,80004be8 <pipewrite+0x50>
  }
  wakeup(&pi->nread);
    80004c68:	22048513          	addi	a0,s1,544
    80004c6c:	ffffd097          	auipc	ra,0xffffd
    80004c70:	768080e7          	jalr	1896(ra) # 800023d4 <wakeup>
  release(&pi->lock);
    80004c74:	8526                	mv	a0,s1
    80004c76:	ffffc097          	auipc	ra,0xffffc
    80004c7a:	efa080e7          	jalr	-262(ra) # 80000b70 <release>
  return n;
    80004c7e:	8552                	mv	a0,s4
    80004c80:	a039                	j	80004c8e <pipewrite+0xf6>
        release(&pi->lock);
    80004c82:	8526                	mv	a0,s1
    80004c84:	ffffc097          	auipc	ra,0xffffc
    80004c88:	eec080e7          	jalr	-276(ra) # 80000b70 <release>
        return -1;
    80004c8c:	557d                	li	a0,-1
}
    80004c8e:	60e6                	ld	ra,88(sp)
    80004c90:	6446                	ld	s0,80(sp)
    80004c92:	64a6                	ld	s1,72(sp)
    80004c94:	6906                	ld	s2,64(sp)
    80004c96:	79e2                	ld	s3,56(sp)
    80004c98:	7a42                	ld	s4,48(sp)
    80004c9a:	7aa2                	ld	s5,40(sp)
    80004c9c:	7b02                	ld	s6,32(sp)
    80004c9e:	6be2                	ld	s7,24(sp)
    80004ca0:	6c42                	ld	s8,16(sp)
    80004ca2:	6125                	addi	sp,sp,96
    80004ca4:	8082                	ret

0000000080004ca6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004ca6:	715d                	addi	sp,sp,-80
    80004ca8:	e486                	sd	ra,72(sp)
    80004caa:	e0a2                	sd	s0,64(sp)
    80004cac:	fc26                	sd	s1,56(sp)
    80004cae:	f84a                	sd	s2,48(sp)
    80004cb0:	f44e                	sd	s3,40(sp)
    80004cb2:	f052                	sd	s4,32(sp)
    80004cb4:	ec56                	sd	s5,24(sp)
    80004cb6:	e85a                	sd	s6,16(sp)
    80004cb8:	0880                	addi	s0,sp,80
    80004cba:	84aa                	mv	s1,a0
    80004cbc:	892e                	mv	s2,a1
    80004cbe:	8a32                	mv	s4,a2
  int i;
  struct proc *pr = myproc();
    80004cc0:	ffffd097          	auipc	ra,0xffffd
    80004cc4:	dd4080e7          	jalr	-556(ra) # 80001a94 <myproc>
    80004cc8:	8aaa                	mv	s5,a0
  char ch;

  acquire(&pi->lock);
    80004cca:	8526                	mv	a0,s1
    80004ccc:	ffffc097          	auipc	ra,0xffffc
    80004cd0:	dd4080e7          	jalr	-556(ra) # 80000aa0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004cd4:	2204a703          	lw	a4,544(s1)
    80004cd8:	2244a783          	lw	a5,548(s1)
    if(myproc()->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004cdc:	22048993          	addi	s3,s1,544
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ce0:	02f71763          	bne	a4,a5,80004d0e <piperead+0x68>
    80004ce4:	22c4a783          	lw	a5,556(s1)
    80004ce8:	c39d                	beqz	a5,80004d0e <piperead+0x68>
    if(myproc()->killed){
    80004cea:	ffffd097          	auipc	ra,0xffffd
    80004cee:	daa080e7          	jalr	-598(ra) # 80001a94 <myproc>
    80004cf2:	5d1c                	lw	a5,56(a0)
    80004cf4:	ebc1                	bnez	a5,80004d84 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004cf6:	85a6                	mv	a1,s1
    80004cf8:	854e                	mv	a0,s3
    80004cfa:	ffffd097          	auipc	ra,0xffffd
    80004cfe:	55a080e7          	jalr	1370(ra) # 80002254 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d02:	2204a703          	lw	a4,544(s1)
    80004d06:	2244a783          	lw	a5,548(s1)
    80004d0a:	fcf70de3          	beq	a4,a5,80004ce4 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d0e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d10:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d12:	05405363          	blez	s4,80004d58 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004d16:	2204a783          	lw	a5,544(s1)
    80004d1a:	2244a703          	lw	a4,548(s1)
    80004d1e:	02f70d63          	beq	a4,a5,80004d58 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004d22:	0017871b          	addiw	a4,a5,1
    80004d26:	22e4a023          	sw	a4,544(s1)
    80004d2a:	1ff7f793          	andi	a5,a5,511
    80004d2e:	97a6                	add	a5,a5,s1
    80004d30:	0207c783          	lbu	a5,32(a5)
    80004d34:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d38:	4685                	li	a3,1
    80004d3a:	fbf40613          	addi	a2,s0,-65
    80004d3e:	85ca                	mv	a1,s2
    80004d40:	058ab503          	ld	a0,88(s5)
    80004d44:	ffffd097          	auipc	ra,0xffffd
    80004d48:	a42080e7          	jalr	-1470(ra) # 80001786 <copyout>
    80004d4c:	01650663          	beq	a0,s6,80004d58 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d50:	2985                	addiw	s3,s3,1
    80004d52:	0905                	addi	s2,s2,1
    80004d54:	fd3a11e3          	bne	s4,s3,80004d16 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004d58:	22448513          	addi	a0,s1,548
    80004d5c:	ffffd097          	auipc	ra,0xffffd
    80004d60:	678080e7          	jalr	1656(ra) # 800023d4 <wakeup>
  release(&pi->lock);
    80004d64:	8526                	mv	a0,s1
    80004d66:	ffffc097          	auipc	ra,0xffffc
    80004d6a:	e0a080e7          	jalr	-502(ra) # 80000b70 <release>
  return i;
}
    80004d6e:	854e                	mv	a0,s3
    80004d70:	60a6                	ld	ra,72(sp)
    80004d72:	6406                	ld	s0,64(sp)
    80004d74:	74e2                	ld	s1,56(sp)
    80004d76:	7942                	ld	s2,48(sp)
    80004d78:	79a2                	ld	s3,40(sp)
    80004d7a:	7a02                	ld	s4,32(sp)
    80004d7c:	6ae2                	ld	s5,24(sp)
    80004d7e:	6b42                	ld	s6,16(sp)
    80004d80:	6161                	addi	sp,sp,80
    80004d82:	8082                	ret
      release(&pi->lock);
    80004d84:	8526                	mv	a0,s1
    80004d86:	ffffc097          	auipc	ra,0xffffc
    80004d8a:	dea080e7          	jalr	-534(ra) # 80000b70 <release>
      return -1;
    80004d8e:	59fd                	li	s3,-1
    80004d90:	bff9                	j	80004d6e <piperead+0xc8>

0000000080004d92 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004d92:	de010113          	addi	sp,sp,-544
    80004d96:	20113c23          	sd	ra,536(sp)
    80004d9a:	20813823          	sd	s0,528(sp)
    80004d9e:	20913423          	sd	s1,520(sp)
    80004da2:	21213023          	sd	s2,512(sp)
    80004da6:	ffce                	sd	s3,504(sp)
    80004da8:	fbd2                	sd	s4,496(sp)
    80004daa:	f7d6                	sd	s5,488(sp)
    80004dac:	f3da                	sd	s6,480(sp)
    80004dae:	efde                	sd	s7,472(sp)
    80004db0:	ebe2                	sd	s8,464(sp)
    80004db2:	e7e6                	sd	s9,456(sp)
    80004db4:	e3ea                	sd	s10,448(sp)
    80004db6:	ff6e                	sd	s11,440(sp)
    80004db8:	1400                	addi	s0,sp,544
    80004dba:	892a                	mv	s2,a0
    80004dbc:	dea43423          	sd	a0,-536(s0)
    80004dc0:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004dc4:	ffffd097          	auipc	ra,0xffffd
    80004dc8:	cd0080e7          	jalr	-816(ra) # 80001a94 <myproc>
    80004dcc:	84aa                	mv	s1,a0

  begin_op(ROOTDEV);
    80004dce:	4501                	li	a0,0
    80004dd0:	fffff097          	auipc	ra,0xfffff
    80004dd4:	342080e7          	jalr	834(ra) # 80004112 <begin_op>

  if((ip = namei(path)) == 0){
    80004dd8:	854a                	mv	a0,s2
    80004dda:	fffff097          	auipc	ra,0xfffff
    80004dde:	0de080e7          	jalr	222(ra) # 80003eb8 <namei>
    80004de2:	cd25                	beqz	a0,80004e5a <exec+0xc8>
    80004de4:	8aaa                	mv	s5,a0
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80004de6:	fffff097          	auipc	ra,0xfffff
    80004dea:	948080e7          	jalr	-1720(ra) # 8000372e <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004dee:	04000713          	li	a4,64
    80004df2:	4681                	li	a3,0
    80004df4:	e4840613          	addi	a2,s0,-440
    80004df8:	4581                	li	a1,0
    80004dfa:	8556                	mv	a0,s5
    80004dfc:	fffff097          	auipc	ra,0xfffff
    80004e00:	bc2080e7          	jalr	-1086(ra) # 800039be <readi>
    80004e04:	04000793          	li	a5,64
    80004e08:	00f51a63          	bne	a0,a5,80004e1c <exec+0x8a>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004e0c:	e4842703          	lw	a4,-440(s0)
    80004e10:	464c47b7          	lui	a5,0x464c4
    80004e14:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004e18:	04f70863          	beq	a4,a5,80004e68 <exec+0xd6>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004e1c:	8556                	mv	a0,s5
    80004e1e:	fffff097          	auipc	ra,0xfffff
    80004e22:	b4e080e7          	jalr	-1202(ra) # 8000396c <iunlockput>
    end_op(ROOTDEV);
    80004e26:	4501                	li	a0,0
    80004e28:	fffff097          	auipc	ra,0xfffff
    80004e2c:	394080e7          	jalr	916(ra) # 800041bc <end_op>
  }
  return -1;
    80004e30:	557d                	li	a0,-1
}
    80004e32:	21813083          	ld	ra,536(sp)
    80004e36:	21013403          	ld	s0,528(sp)
    80004e3a:	20813483          	ld	s1,520(sp)
    80004e3e:	20013903          	ld	s2,512(sp)
    80004e42:	79fe                	ld	s3,504(sp)
    80004e44:	7a5e                	ld	s4,496(sp)
    80004e46:	7abe                	ld	s5,488(sp)
    80004e48:	7b1e                	ld	s6,480(sp)
    80004e4a:	6bfe                	ld	s7,472(sp)
    80004e4c:	6c5e                	ld	s8,464(sp)
    80004e4e:	6cbe                	ld	s9,456(sp)
    80004e50:	6d1e                	ld	s10,448(sp)
    80004e52:	7dfa                	ld	s11,440(sp)
    80004e54:	22010113          	addi	sp,sp,544
    80004e58:	8082                	ret
    end_op(ROOTDEV);
    80004e5a:	4501                	li	a0,0
    80004e5c:	fffff097          	auipc	ra,0xfffff
    80004e60:	360080e7          	jalr	864(ra) # 800041bc <end_op>
    return -1;
    80004e64:	557d                	li	a0,-1
    80004e66:	b7f1                	j	80004e32 <exec+0xa0>
  if((pagetable = proc_pagetable(p)) == 0)
    80004e68:	8526                	mv	a0,s1
    80004e6a:	ffffd097          	auipc	ra,0xffffd
    80004e6e:	cee080e7          	jalr	-786(ra) # 80001b58 <proc_pagetable>
    80004e72:	8b2a                	mv	s6,a0
    80004e74:	d545                	beqz	a0,80004e1c <exec+0x8a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e76:	e6842783          	lw	a5,-408(s0)
    80004e7a:	e8045703          	lhu	a4,-384(s0)
    80004e7e:	10070263          	beqz	a4,80004f82 <exec+0x1f0>
  sz = 0;
    80004e82:	de043c23          	sd	zero,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e86:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004e8a:	6a05                	lui	s4,0x1
    80004e8c:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004e90:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80004e94:	6d85                	lui	s11,0x1
    80004e96:	7d7d                	lui	s10,0xfffff
    80004e98:	a88d                	j	80004f0a <exec+0x178>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004e9a:	00005517          	auipc	a0,0x5
    80004e9e:	bbe50513          	addi	a0,a0,-1090 # 80009a58 <userret+0x9c8>
    80004ea2:	ffffb097          	auipc	ra,0xffffb
    80004ea6:	6b2080e7          	jalr	1714(ra) # 80000554 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004eaa:	874a                	mv	a4,s2
    80004eac:	009c86bb          	addw	a3,s9,s1
    80004eb0:	4581                	li	a1,0
    80004eb2:	8556                	mv	a0,s5
    80004eb4:	fffff097          	auipc	ra,0xfffff
    80004eb8:	b0a080e7          	jalr	-1270(ra) # 800039be <readi>
    80004ebc:	2501                	sext.w	a0,a0
    80004ebe:	10a91863          	bne	s2,a0,80004fce <exec+0x23c>
  for(i = 0; i < sz; i += PGSIZE){
    80004ec2:	009d84bb          	addw	s1,s11,s1
    80004ec6:	013d09bb          	addw	s3,s10,s3
    80004eca:	0374f263          	bgeu	s1,s7,80004eee <exec+0x15c>
    pa = walkaddr(pagetable, va + i);
    80004ece:	02049593          	slli	a1,s1,0x20
    80004ed2:	9181                	srli	a1,a1,0x20
    80004ed4:	95e2                	add	a1,a1,s8
    80004ed6:	855a                	mv	a0,s6
    80004ed8:	ffffc097          	auipc	ra,0xffffc
    80004edc:	2a0080e7          	jalr	672(ra) # 80001178 <walkaddr>
    80004ee0:	862a                	mv	a2,a0
    if(pa == 0)
    80004ee2:	dd45                	beqz	a0,80004e9a <exec+0x108>
      n = PGSIZE;
    80004ee4:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004ee6:	fd49f2e3          	bgeu	s3,s4,80004eaa <exec+0x118>
      n = sz - i;
    80004eea:	894e                	mv	s2,s3
    80004eec:	bf7d                	j	80004eaa <exec+0x118>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004eee:	e0843783          	ld	a5,-504(s0)
    80004ef2:	0017869b          	addiw	a3,a5,1
    80004ef6:	e0d43423          	sd	a3,-504(s0)
    80004efa:	e0043783          	ld	a5,-512(s0)
    80004efe:	0387879b          	addiw	a5,a5,56
    80004f02:	e8045703          	lhu	a4,-384(s0)
    80004f06:	08e6d063          	bge	a3,a4,80004f86 <exec+0x1f4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f0a:	2781                	sext.w	a5,a5
    80004f0c:	e0f43023          	sd	a5,-512(s0)
    80004f10:	03800713          	li	a4,56
    80004f14:	86be                	mv	a3,a5
    80004f16:	e1040613          	addi	a2,s0,-496
    80004f1a:	4581                	li	a1,0
    80004f1c:	8556                	mv	a0,s5
    80004f1e:	fffff097          	auipc	ra,0xfffff
    80004f22:	aa0080e7          	jalr	-1376(ra) # 800039be <readi>
    80004f26:	03800793          	li	a5,56
    80004f2a:	0af51263          	bne	a0,a5,80004fce <exec+0x23c>
    if(ph.type != ELF_PROG_LOAD)
    80004f2e:	e1042783          	lw	a5,-496(s0)
    80004f32:	4705                	li	a4,1
    80004f34:	fae79de3          	bne	a5,a4,80004eee <exec+0x15c>
    if(ph.memsz < ph.filesz)
    80004f38:	e3843603          	ld	a2,-456(s0)
    80004f3c:	e3043783          	ld	a5,-464(s0)
    80004f40:	08f66763          	bltu	a2,a5,80004fce <exec+0x23c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004f44:	e2043783          	ld	a5,-480(s0)
    80004f48:	963e                	add	a2,a2,a5
    80004f4a:	08f66263          	bltu	a2,a5,80004fce <exec+0x23c>
    if((sz = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004f4e:	df843583          	ld	a1,-520(s0)
    80004f52:	855a                	mv	a0,s6
    80004f54:	ffffc097          	auipc	ra,0xffffc
    80004f58:	658080e7          	jalr	1624(ra) # 800015ac <uvmalloc>
    80004f5c:	dea43c23          	sd	a0,-520(s0)
    80004f60:	c53d                	beqz	a0,80004fce <exec+0x23c>
    if(ph.vaddr % PGSIZE != 0)
    80004f62:	e2043c03          	ld	s8,-480(s0)
    80004f66:	de043783          	ld	a5,-544(s0)
    80004f6a:	00fc77b3          	and	a5,s8,a5
    80004f6e:	e3a5                	bnez	a5,80004fce <exec+0x23c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004f70:	e1842c83          	lw	s9,-488(s0)
    80004f74:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004f78:	f60b8be3          	beqz	s7,80004eee <exec+0x15c>
    80004f7c:	89de                	mv	s3,s7
    80004f7e:	4481                	li	s1,0
    80004f80:	b7b9                	j	80004ece <exec+0x13c>
  sz = 0;
    80004f82:	de043c23          	sd	zero,-520(s0)
  iunlockput(ip);
    80004f86:	8556                	mv	a0,s5
    80004f88:	fffff097          	auipc	ra,0xfffff
    80004f8c:	9e4080e7          	jalr	-1564(ra) # 8000396c <iunlockput>
  end_op(ROOTDEV);
    80004f90:	4501                	li	a0,0
    80004f92:	fffff097          	auipc	ra,0xfffff
    80004f96:	22a080e7          	jalr	554(ra) # 800041bc <end_op>
  p = myproc();
    80004f9a:	ffffd097          	auipc	ra,0xffffd
    80004f9e:	afa080e7          	jalr	-1286(ra) # 80001a94 <myproc>
    80004fa2:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004fa4:	05053c83          	ld	s9,80(a0)
  sz = PGROUNDUP(sz);
    80004fa8:	6585                	lui	a1,0x1
    80004faa:	15fd                	addi	a1,a1,-1
    80004fac:	df843783          	ld	a5,-520(s0)
    80004fb0:	95be                	add	a1,a1,a5
    80004fb2:	77fd                	lui	a5,0xfffff
    80004fb4:	8dfd                	and	a1,a1,a5
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004fb6:	6609                	lui	a2,0x2
    80004fb8:	962e                	add	a2,a2,a1
    80004fba:	855a                	mv	a0,s6
    80004fbc:	ffffc097          	auipc	ra,0xffffc
    80004fc0:	5f0080e7          	jalr	1520(ra) # 800015ac <uvmalloc>
    80004fc4:	892a                	mv	s2,a0
    80004fc6:	dea43c23          	sd	a0,-520(s0)
  ip = 0;
    80004fca:	4a81                	li	s5,0
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004fcc:	ed01                	bnez	a0,80004fe4 <exec+0x252>
    proc_freepagetable(pagetable, sz);
    80004fce:	df843583          	ld	a1,-520(s0)
    80004fd2:	855a                	mv	a0,s6
    80004fd4:	ffffd097          	auipc	ra,0xffffd
    80004fd8:	c84080e7          	jalr	-892(ra) # 80001c58 <proc_freepagetable>
  if(ip){
    80004fdc:	e40a90e3          	bnez	s5,80004e1c <exec+0x8a>
  return -1;
    80004fe0:	557d                	li	a0,-1
    80004fe2:	bd81                	j	80004e32 <exec+0xa0>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004fe4:	75f9                	lui	a1,0xffffe
    80004fe6:	95aa                	add	a1,a1,a0
    80004fe8:	855a                	mv	a0,s6
    80004fea:	ffffc097          	auipc	ra,0xffffc
    80004fee:	76a080e7          	jalr	1898(ra) # 80001754 <uvmclear>
  stackbase = sp - PGSIZE;
    80004ff2:	7c7d                	lui	s8,0xfffff
    80004ff4:	9c4a                	add	s8,s8,s2
  for(argc = 0; argv[argc]; argc++) {
    80004ff6:	df043783          	ld	a5,-528(s0)
    80004ffa:	6388                	ld	a0,0(a5)
    80004ffc:	c52d                	beqz	a0,80005066 <exec+0x2d4>
    80004ffe:	e8840993          	addi	s3,s0,-376
    80005002:	f8840a93          	addi	s5,s0,-120
    80005006:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005008:	ffffc097          	auipc	ra,0xffffc
    8000500c:	eea080e7          	jalr	-278(ra) # 80000ef2 <strlen>
    80005010:	0015079b          	addiw	a5,a0,1
    80005014:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005018:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000501c:	0f896b63          	bltu	s2,s8,80005112 <exec+0x380>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005020:	df043d03          	ld	s10,-528(s0)
    80005024:	000d3a03          	ld	s4,0(s10) # fffffffffffff000 <end+0xffffffff7ffd5c54>
    80005028:	8552                	mv	a0,s4
    8000502a:	ffffc097          	auipc	ra,0xffffc
    8000502e:	ec8080e7          	jalr	-312(ra) # 80000ef2 <strlen>
    80005032:	0015069b          	addiw	a3,a0,1
    80005036:	8652                	mv	a2,s4
    80005038:	85ca                	mv	a1,s2
    8000503a:	855a                	mv	a0,s6
    8000503c:	ffffc097          	auipc	ra,0xffffc
    80005040:	74a080e7          	jalr	1866(ra) # 80001786 <copyout>
    80005044:	0c054963          	bltz	a0,80005116 <exec+0x384>
    ustack[argc] = sp;
    80005048:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000504c:	0485                	addi	s1,s1,1
    8000504e:	008d0793          	addi	a5,s10,8
    80005052:	def43823          	sd	a5,-528(s0)
    80005056:	008d3503          	ld	a0,8(s10)
    8000505a:	c909                	beqz	a0,8000506c <exec+0x2da>
    if(argc >= MAXARG)
    8000505c:	09a1                	addi	s3,s3,8
    8000505e:	fb3a95e3          	bne	s5,s3,80005008 <exec+0x276>
  ip = 0;
    80005062:	4a81                	li	s5,0
    80005064:	b7ad                	j	80004fce <exec+0x23c>
  sp = sz;
    80005066:	df843903          	ld	s2,-520(s0)
  for(argc = 0; argv[argc]; argc++) {
    8000506a:	4481                	li	s1,0
  ustack[argc] = 0;
    8000506c:	00349793          	slli	a5,s1,0x3
    80005070:	f9040713          	addi	a4,s0,-112
    80005074:	97ba                	add	a5,a5,a4
    80005076:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd5b4c>
  sp -= (argc+1) * sizeof(uint64);
    8000507a:	00148693          	addi	a3,s1,1
    8000507e:	068e                	slli	a3,a3,0x3
    80005080:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005084:	ff097913          	andi	s2,s2,-16
  ip = 0;
    80005088:	4a81                	li	s5,0
  if(sp < stackbase)
    8000508a:	f58962e3          	bltu	s2,s8,80004fce <exec+0x23c>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000508e:	e8840613          	addi	a2,s0,-376
    80005092:	85ca                	mv	a1,s2
    80005094:	855a                	mv	a0,s6
    80005096:	ffffc097          	auipc	ra,0xffffc
    8000509a:	6f0080e7          	jalr	1776(ra) # 80001786 <copyout>
    8000509e:	06054e63          	bltz	a0,8000511a <exec+0x388>
  p->tf->a1 = sp;
    800050a2:	060bb783          	ld	a5,96(s7)
    800050a6:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800050aa:	de843783          	ld	a5,-536(s0)
    800050ae:	0007c703          	lbu	a4,0(a5)
    800050b2:	cf11                	beqz	a4,800050ce <exec+0x33c>
    800050b4:	0785                	addi	a5,a5,1
    if(*s == '/')
    800050b6:	02f00693          	li	a3,47
    800050ba:	a039                	j	800050c8 <exec+0x336>
      last = s+1;
    800050bc:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800050c0:	0785                	addi	a5,a5,1
    800050c2:	fff7c703          	lbu	a4,-1(a5)
    800050c6:	c701                	beqz	a4,800050ce <exec+0x33c>
    if(*s == '/')
    800050c8:	fed71ce3          	bne	a4,a3,800050c0 <exec+0x32e>
    800050cc:	bfc5                	j	800050bc <exec+0x32a>
  safestrcpy(p->name, last, sizeof(p->name));
    800050ce:	4641                	li	a2,16
    800050d0:	de843583          	ld	a1,-536(s0)
    800050d4:	160b8513          	addi	a0,s7,352
    800050d8:	ffffc097          	auipc	ra,0xffffc
    800050dc:	de8080e7          	jalr	-536(ra) # 80000ec0 <safestrcpy>
  oldpagetable = p->pagetable;
    800050e0:	058bb503          	ld	a0,88(s7)
  p->pagetable = pagetable;
    800050e4:	056bbc23          	sd	s6,88(s7)
  p->sz = sz;
    800050e8:	df843783          	ld	a5,-520(s0)
    800050ec:	04fbb823          	sd	a5,80(s7)
  p->tf->epc = elf.entry;  // initial program counter = main
    800050f0:	060bb783          	ld	a5,96(s7)
    800050f4:	e6043703          	ld	a4,-416(s0)
    800050f8:	ef98                	sd	a4,24(a5)
  p->tf->sp = sp; // initial stack pointer
    800050fa:	060bb783          	ld	a5,96(s7)
    800050fe:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005102:	85e6                	mv	a1,s9
    80005104:	ffffd097          	auipc	ra,0xffffd
    80005108:	b54080e7          	jalr	-1196(ra) # 80001c58 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000510c:	0004851b          	sext.w	a0,s1
    80005110:	b30d                	j	80004e32 <exec+0xa0>
  ip = 0;
    80005112:	4a81                	li	s5,0
    80005114:	bd6d                	j	80004fce <exec+0x23c>
    80005116:	4a81                	li	s5,0
    80005118:	bd5d                	j	80004fce <exec+0x23c>
    8000511a:	4a81                	li	s5,0
    8000511c:	bd4d                	j	80004fce <exec+0x23c>

000000008000511e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000511e:	1101                	addi	sp,sp,-32
    80005120:	ec06                	sd	ra,24(sp)
    80005122:	e822                	sd	s0,16(sp)
    80005124:	e426                	sd	s1,8(sp)
    80005126:	1000                	addi	s0,sp,32
    80005128:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000512a:	ffffd097          	auipc	ra,0xffffd
    8000512e:	96a080e7          	jalr	-1686(ra) # 80001a94 <myproc>
    80005132:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005134:	0d850793          	addi	a5,a0,216
    80005138:	4501                	li	a0,0
    8000513a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000513c:	6398                	ld	a4,0(a5)
    8000513e:	cb19                	beqz	a4,80005154 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005140:	2505                	addiw	a0,a0,1
    80005142:	07a1                	addi	a5,a5,8
    80005144:	fed51ce3          	bne	a0,a3,8000513c <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005148:	557d                	li	a0,-1
}
    8000514a:	60e2                	ld	ra,24(sp)
    8000514c:	6442                	ld	s0,16(sp)
    8000514e:	64a2                	ld	s1,8(sp)
    80005150:	6105                	addi	sp,sp,32
    80005152:	8082                	ret
      p->ofile[fd] = f;
    80005154:	01a50793          	addi	a5,a0,26
    80005158:	078e                	slli	a5,a5,0x3
    8000515a:	963e                	add	a2,a2,a5
    8000515c:	e604                	sd	s1,8(a2)
      return fd;
    8000515e:	b7f5                	j	8000514a <fdalloc+0x2c>

0000000080005160 <argfd>:
{
    80005160:	7179                	addi	sp,sp,-48
    80005162:	f406                	sd	ra,40(sp)
    80005164:	f022                	sd	s0,32(sp)
    80005166:	ec26                	sd	s1,24(sp)
    80005168:	e84a                	sd	s2,16(sp)
    8000516a:	1800                	addi	s0,sp,48
    8000516c:	892e                	mv	s2,a1
    8000516e:	84b2                	mv	s1,a2
  if(argint(n, &fd) < 0)
    80005170:	fdc40593          	addi	a1,s0,-36
    80005174:	ffffe097          	auipc	ra,0xffffe
    80005178:	a46080e7          	jalr	-1466(ra) # 80002bba <argint>
    8000517c:	04054063          	bltz	a0,800051bc <argfd+0x5c>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005180:	fdc42703          	lw	a4,-36(s0)
    80005184:	47bd                	li	a5,15
    80005186:	02e7ed63          	bltu	a5,a4,800051c0 <argfd+0x60>
    8000518a:	ffffd097          	auipc	ra,0xffffd
    8000518e:	90a080e7          	jalr	-1782(ra) # 80001a94 <myproc>
    80005192:	fdc42703          	lw	a4,-36(s0)
    80005196:	01a70793          	addi	a5,a4,26
    8000519a:	078e                	slli	a5,a5,0x3
    8000519c:	953e                	add	a0,a0,a5
    8000519e:	651c                	ld	a5,8(a0)
    800051a0:	c395                	beqz	a5,800051c4 <argfd+0x64>
  if(pfd)
    800051a2:	00090463          	beqz	s2,800051aa <argfd+0x4a>
    *pfd = fd;
    800051a6:	00e92023          	sw	a4,0(s2)
  return 0;
    800051aa:	4501                	li	a0,0
  if(pf)
    800051ac:	c091                	beqz	s1,800051b0 <argfd+0x50>
    *pf = f;
    800051ae:	e09c                	sd	a5,0(s1)
}
    800051b0:	70a2                	ld	ra,40(sp)
    800051b2:	7402                	ld	s0,32(sp)
    800051b4:	64e2                	ld	s1,24(sp)
    800051b6:	6942                	ld	s2,16(sp)
    800051b8:	6145                	addi	sp,sp,48
    800051ba:	8082                	ret
    return -1;
    800051bc:	557d                	li	a0,-1
    800051be:	bfcd                	j	800051b0 <argfd+0x50>
    return -1;
    800051c0:	557d                	li	a0,-1
    800051c2:	b7fd                	j	800051b0 <argfd+0x50>
    800051c4:	557d                	li	a0,-1
    800051c6:	b7ed                	j	800051b0 <argfd+0x50>

00000000800051c8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800051c8:	715d                	addi	sp,sp,-80
    800051ca:	e486                	sd	ra,72(sp)
    800051cc:	e0a2                	sd	s0,64(sp)
    800051ce:	fc26                	sd	s1,56(sp)
    800051d0:	f84a                	sd	s2,48(sp)
    800051d2:	f44e                	sd	s3,40(sp)
    800051d4:	f052                	sd	s4,32(sp)
    800051d6:	ec56                	sd	s5,24(sp)
    800051d8:	0880                	addi	s0,sp,80
    800051da:	89ae                	mv	s3,a1
    800051dc:	8ab2                	mv	s5,a2
    800051de:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800051e0:	fb040593          	addi	a1,s0,-80
    800051e4:	fffff097          	auipc	ra,0xfffff
    800051e8:	cf2080e7          	jalr	-782(ra) # 80003ed6 <nameiparent>
    800051ec:	892a                	mv	s2,a0
    800051ee:	12050e63          	beqz	a0,8000532a <create+0x162>
    return 0;

  ilock(dp);
    800051f2:	ffffe097          	auipc	ra,0xffffe
    800051f6:	53c080e7          	jalr	1340(ra) # 8000372e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800051fa:	4601                	li	a2,0
    800051fc:	fb040593          	addi	a1,s0,-80
    80005200:	854a                	mv	a0,s2
    80005202:	fffff097          	auipc	ra,0xfffff
    80005206:	9e4080e7          	jalr	-1564(ra) # 80003be6 <dirlookup>
    8000520a:	84aa                	mv	s1,a0
    8000520c:	c921                	beqz	a0,8000525c <create+0x94>
    iunlockput(dp);
    8000520e:	854a                	mv	a0,s2
    80005210:	ffffe097          	auipc	ra,0xffffe
    80005214:	75c080e7          	jalr	1884(ra) # 8000396c <iunlockput>
    ilock(ip);
    80005218:	8526                	mv	a0,s1
    8000521a:	ffffe097          	auipc	ra,0xffffe
    8000521e:	514080e7          	jalr	1300(ra) # 8000372e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005222:	2981                	sext.w	s3,s3
    80005224:	4789                	li	a5,2
    80005226:	02f99463          	bne	s3,a5,8000524e <create+0x86>
    8000522a:	04c4d783          	lhu	a5,76(s1)
    8000522e:	37f9                	addiw	a5,a5,-2
    80005230:	17c2                	slli	a5,a5,0x30
    80005232:	93c1                	srli	a5,a5,0x30
    80005234:	4705                	li	a4,1
    80005236:	00f76c63          	bltu	a4,a5,8000524e <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000523a:	8526                	mv	a0,s1
    8000523c:	60a6                	ld	ra,72(sp)
    8000523e:	6406                	ld	s0,64(sp)
    80005240:	74e2                	ld	s1,56(sp)
    80005242:	7942                	ld	s2,48(sp)
    80005244:	79a2                	ld	s3,40(sp)
    80005246:	7a02                	ld	s4,32(sp)
    80005248:	6ae2                	ld	s5,24(sp)
    8000524a:	6161                	addi	sp,sp,80
    8000524c:	8082                	ret
    iunlockput(ip);
    8000524e:	8526                	mv	a0,s1
    80005250:	ffffe097          	auipc	ra,0xffffe
    80005254:	71c080e7          	jalr	1820(ra) # 8000396c <iunlockput>
    return 0;
    80005258:	4481                	li	s1,0
    8000525a:	b7c5                	j	8000523a <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000525c:	85ce                	mv	a1,s3
    8000525e:	00092503          	lw	a0,0(s2)
    80005262:	ffffe097          	auipc	ra,0xffffe
    80005266:	334080e7          	jalr	820(ra) # 80003596 <ialloc>
    8000526a:	84aa                	mv	s1,a0
    8000526c:	c521                	beqz	a0,800052b4 <create+0xec>
  ilock(ip);
    8000526e:	ffffe097          	auipc	ra,0xffffe
    80005272:	4c0080e7          	jalr	1216(ra) # 8000372e <ilock>
  ip->major = major;
    80005276:	05549723          	sh	s5,78(s1)
  ip->minor = minor;
    8000527a:	05449823          	sh	s4,80(s1)
  ip->nlink = 1;
    8000527e:	4a05                	li	s4,1
    80005280:	05449923          	sh	s4,82(s1)
  iupdate(ip);
    80005284:	8526                	mv	a0,s1
    80005286:	ffffe097          	auipc	ra,0xffffe
    8000528a:	3de080e7          	jalr	990(ra) # 80003664 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000528e:	2981                	sext.w	s3,s3
    80005290:	03498a63          	beq	s3,s4,800052c4 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005294:	40d0                	lw	a2,4(s1)
    80005296:	fb040593          	addi	a1,s0,-80
    8000529a:	854a                	mv	a0,s2
    8000529c:	fffff097          	auipc	ra,0xfffff
    800052a0:	b5a080e7          	jalr	-1190(ra) # 80003df6 <dirlink>
    800052a4:	06054b63          	bltz	a0,8000531a <create+0x152>
  iunlockput(dp);
    800052a8:	854a                	mv	a0,s2
    800052aa:	ffffe097          	auipc	ra,0xffffe
    800052ae:	6c2080e7          	jalr	1730(ra) # 8000396c <iunlockput>
  return ip;
    800052b2:	b761                	j	8000523a <create+0x72>
    panic("create: ialloc");
    800052b4:	00004517          	auipc	a0,0x4
    800052b8:	7c450513          	addi	a0,a0,1988 # 80009a78 <userret+0x9e8>
    800052bc:	ffffb097          	auipc	ra,0xffffb
    800052c0:	298080e7          	jalr	664(ra) # 80000554 <panic>
    dp->nlink++;  // for ".."
    800052c4:	05295783          	lhu	a5,82(s2)
    800052c8:	2785                	addiw	a5,a5,1
    800052ca:	04f91923          	sh	a5,82(s2)
    iupdate(dp);
    800052ce:	854a                	mv	a0,s2
    800052d0:	ffffe097          	auipc	ra,0xffffe
    800052d4:	394080e7          	jalr	916(ra) # 80003664 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800052d8:	40d0                	lw	a2,4(s1)
    800052da:	00004597          	auipc	a1,0x4
    800052de:	7ae58593          	addi	a1,a1,1966 # 80009a88 <userret+0x9f8>
    800052e2:	8526                	mv	a0,s1
    800052e4:	fffff097          	auipc	ra,0xfffff
    800052e8:	b12080e7          	jalr	-1262(ra) # 80003df6 <dirlink>
    800052ec:	00054f63          	bltz	a0,8000530a <create+0x142>
    800052f0:	00492603          	lw	a2,4(s2)
    800052f4:	00004597          	auipc	a1,0x4
    800052f8:	79c58593          	addi	a1,a1,1948 # 80009a90 <userret+0xa00>
    800052fc:	8526                	mv	a0,s1
    800052fe:	fffff097          	auipc	ra,0xfffff
    80005302:	af8080e7          	jalr	-1288(ra) # 80003df6 <dirlink>
    80005306:	f80557e3          	bgez	a0,80005294 <create+0xcc>
      panic("create dots");
    8000530a:	00004517          	auipc	a0,0x4
    8000530e:	78e50513          	addi	a0,a0,1934 # 80009a98 <userret+0xa08>
    80005312:	ffffb097          	auipc	ra,0xffffb
    80005316:	242080e7          	jalr	578(ra) # 80000554 <panic>
    panic("create: dirlink");
    8000531a:	00004517          	auipc	a0,0x4
    8000531e:	78e50513          	addi	a0,a0,1934 # 80009aa8 <userret+0xa18>
    80005322:	ffffb097          	auipc	ra,0xffffb
    80005326:	232080e7          	jalr	562(ra) # 80000554 <panic>
    return 0;
    8000532a:	84aa                	mv	s1,a0
    8000532c:	b739                	j	8000523a <create+0x72>

000000008000532e <sys_connect>:
{
    8000532e:	7179                	addi	sp,sp,-48
    80005330:	f406                	sd	ra,40(sp)
    80005332:	f022                	sd	s0,32(sp)
    80005334:	1800                	addi	s0,sp,48
  if (argint(0, (int*)&raddr) < 0 ||
    80005336:	fe440593          	addi	a1,s0,-28
    8000533a:	4501                	li	a0,0
    8000533c:	ffffe097          	auipc	ra,0xffffe
    80005340:	87e080e7          	jalr	-1922(ra) # 80002bba <argint>
    return -1;
    80005344:	57fd                	li	a5,-1
  if (argint(0, (int*)&raddr) < 0 ||
    80005346:	04054e63          	bltz	a0,800053a2 <sys_connect+0x74>
      argint(1, (int*)&lport) < 0 ||
    8000534a:	fdc40593          	addi	a1,s0,-36
    8000534e:	4505                	li	a0,1
    80005350:	ffffe097          	auipc	ra,0xffffe
    80005354:	86a080e7          	jalr	-1942(ra) # 80002bba <argint>
    return -1;
    80005358:	57fd                	li	a5,-1
  if (argint(0, (int*)&raddr) < 0 ||
    8000535a:	04054463          	bltz	a0,800053a2 <sys_connect+0x74>
      argint(2, (int*)&rport) < 0) {
    8000535e:	fe040593          	addi	a1,s0,-32
    80005362:	4509                	li	a0,2
    80005364:	ffffe097          	auipc	ra,0xffffe
    80005368:	856080e7          	jalr	-1962(ra) # 80002bba <argint>
    return -1;
    8000536c:	57fd                	li	a5,-1
      argint(1, (int*)&lport) < 0 ||
    8000536e:	02054a63          	bltz	a0,800053a2 <sys_connect+0x74>
  if(sockalloc(&f, raddr, lport, rport) < 0)
    80005372:	fe045683          	lhu	a3,-32(s0)
    80005376:	fdc45603          	lhu	a2,-36(s0)
    8000537a:	fe442583          	lw	a1,-28(s0)
    8000537e:	fe840513          	addi	a0,s0,-24
    80005382:	00002097          	auipc	ra,0x2
    80005386:	d80080e7          	jalr	-640(ra) # 80007102 <sockalloc>
    return -1;
    8000538a:	57fd                	li	a5,-1
  if(sockalloc(&f, raddr, lport, rport) < 0)
    8000538c:	00054b63          	bltz	a0,800053a2 <sys_connect+0x74>
  if((fd=fdalloc(f)) < 0){
    80005390:	fe843503          	ld	a0,-24(s0)
    80005394:	00000097          	auipc	ra,0x0
    80005398:	d8a080e7          	jalr	-630(ra) # 8000511e <fdalloc>
  return fd;
    8000539c:	87aa                	mv	a5,a0
  if((fd=fdalloc(f)) < 0){
    8000539e:	00054763          	bltz	a0,800053ac <sys_connect+0x7e>
}
    800053a2:	853e                	mv	a0,a5
    800053a4:	70a2                	ld	ra,40(sp)
    800053a6:	7402                	ld	s0,32(sp)
    800053a8:	6145                	addi	sp,sp,48
    800053aa:	8082                	ret
    fileclose(f);
    800053ac:	fe843503          	ld	a0,-24(s0)
    800053b0:	fffff097          	auipc	ra,0xfffff
    800053b4:	2fc080e7          	jalr	764(ra) # 800046ac <fileclose>
    return -1;
    800053b8:	57fd                	li	a5,-1
    800053ba:	b7e5                	j	800053a2 <sys_connect+0x74>

00000000800053bc <sys_dup>:
{
    800053bc:	7179                	addi	sp,sp,-48
    800053be:	f406                	sd	ra,40(sp)
    800053c0:	f022                	sd	s0,32(sp)
    800053c2:	ec26                	sd	s1,24(sp)
    800053c4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800053c6:	fd840613          	addi	a2,s0,-40
    800053ca:	4581                	li	a1,0
    800053cc:	4501                	li	a0,0
    800053ce:	00000097          	auipc	ra,0x0
    800053d2:	d92080e7          	jalr	-622(ra) # 80005160 <argfd>
    return -1;
    800053d6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800053d8:	02054363          	bltz	a0,800053fe <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800053dc:	fd843503          	ld	a0,-40(s0)
    800053e0:	00000097          	auipc	ra,0x0
    800053e4:	d3e080e7          	jalr	-706(ra) # 8000511e <fdalloc>
    800053e8:	84aa                	mv	s1,a0
    return -1;
    800053ea:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800053ec:	00054963          	bltz	a0,800053fe <sys_dup+0x42>
  filedup(f);
    800053f0:	fd843503          	ld	a0,-40(s0)
    800053f4:	fffff097          	auipc	ra,0xfffff
    800053f8:	266080e7          	jalr	614(ra) # 8000465a <filedup>
  return fd;
    800053fc:	87a6                	mv	a5,s1
}
    800053fe:	853e                	mv	a0,a5
    80005400:	70a2                	ld	ra,40(sp)
    80005402:	7402                	ld	s0,32(sp)
    80005404:	64e2                	ld	s1,24(sp)
    80005406:	6145                	addi	sp,sp,48
    80005408:	8082                	ret

000000008000540a <sys_read>:
{
    8000540a:	7179                	addi	sp,sp,-48
    8000540c:	f406                	sd	ra,40(sp)
    8000540e:	f022                	sd	s0,32(sp)
    80005410:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005412:	fe840613          	addi	a2,s0,-24
    80005416:	4581                	li	a1,0
    80005418:	4501                	li	a0,0
    8000541a:	00000097          	auipc	ra,0x0
    8000541e:	d46080e7          	jalr	-698(ra) # 80005160 <argfd>
    return -1;
    80005422:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005424:	04054163          	bltz	a0,80005466 <sys_read+0x5c>
    80005428:	fe440593          	addi	a1,s0,-28
    8000542c:	4509                	li	a0,2
    8000542e:	ffffd097          	auipc	ra,0xffffd
    80005432:	78c080e7          	jalr	1932(ra) # 80002bba <argint>
    return -1;
    80005436:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005438:	02054763          	bltz	a0,80005466 <sys_read+0x5c>
    8000543c:	fd840593          	addi	a1,s0,-40
    80005440:	4505                	li	a0,1
    80005442:	ffffd097          	auipc	ra,0xffffd
    80005446:	79a080e7          	jalr	1946(ra) # 80002bdc <argaddr>
    return -1;
    8000544a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000544c:	00054d63          	bltz	a0,80005466 <sys_read+0x5c>
  return fileread(f, p, n);
    80005450:	fe442603          	lw	a2,-28(s0)
    80005454:	fd843583          	ld	a1,-40(s0)
    80005458:	fe843503          	ld	a0,-24(s0)
    8000545c:	fffff097          	auipc	ra,0xfffff
    80005460:	3ae080e7          	jalr	942(ra) # 8000480a <fileread>
    80005464:	87aa                	mv	a5,a0
}
    80005466:	853e                	mv	a0,a5
    80005468:	70a2                	ld	ra,40(sp)
    8000546a:	7402                	ld	s0,32(sp)
    8000546c:	6145                	addi	sp,sp,48
    8000546e:	8082                	ret

0000000080005470 <sys_write>:
{
    80005470:	7179                	addi	sp,sp,-48
    80005472:	f406                	sd	ra,40(sp)
    80005474:	f022                	sd	s0,32(sp)
    80005476:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005478:	fe840613          	addi	a2,s0,-24
    8000547c:	4581                	li	a1,0
    8000547e:	4501                	li	a0,0
    80005480:	00000097          	auipc	ra,0x0
    80005484:	ce0080e7          	jalr	-800(ra) # 80005160 <argfd>
    return -1;
    80005488:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000548a:	04054163          	bltz	a0,800054cc <sys_write+0x5c>
    8000548e:	fe440593          	addi	a1,s0,-28
    80005492:	4509                	li	a0,2
    80005494:	ffffd097          	auipc	ra,0xffffd
    80005498:	726080e7          	jalr	1830(ra) # 80002bba <argint>
    return -1;
    8000549c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000549e:	02054763          	bltz	a0,800054cc <sys_write+0x5c>
    800054a2:	fd840593          	addi	a1,s0,-40
    800054a6:	4505                	li	a0,1
    800054a8:	ffffd097          	auipc	ra,0xffffd
    800054ac:	734080e7          	jalr	1844(ra) # 80002bdc <argaddr>
    return -1;
    800054b0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054b2:	00054d63          	bltz	a0,800054cc <sys_write+0x5c>
  return filewrite(f, p, n);
    800054b6:	fe442603          	lw	a2,-28(s0)
    800054ba:	fd843583          	ld	a1,-40(s0)
    800054be:	fe843503          	ld	a0,-24(s0)
    800054c2:	fffff097          	auipc	ra,0xfffff
    800054c6:	422080e7          	jalr	1058(ra) # 800048e4 <filewrite>
    800054ca:	87aa                	mv	a5,a0
}
    800054cc:	853e                	mv	a0,a5
    800054ce:	70a2                	ld	ra,40(sp)
    800054d0:	7402                	ld	s0,32(sp)
    800054d2:	6145                	addi	sp,sp,48
    800054d4:	8082                	ret

00000000800054d6 <sys_close>:
{
    800054d6:	1101                	addi	sp,sp,-32
    800054d8:	ec06                	sd	ra,24(sp)
    800054da:	e822                	sd	s0,16(sp)
    800054dc:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800054de:	fe040613          	addi	a2,s0,-32
    800054e2:	fec40593          	addi	a1,s0,-20
    800054e6:	4501                	li	a0,0
    800054e8:	00000097          	auipc	ra,0x0
    800054ec:	c78080e7          	jalr	-904(ra) # 80005160 <argfd>
    return -1;
    800054f0:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800054f2:	02054463          	bltz	a0,8000551a <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800054f6:	ffffc097          	auipc	ra,0xffffc
    800054fa:	59e080e7          	jalr	1438(ra) # 80001a94 <myproc>
    800054fe:	fec42783          	lw	a5,-20(s0)
    80005502:	07e9                	addi	a5,a5,26
    80005504:	078e                	slli	a5,a5,0x3
    80005506:	97aa                	add	a5,a5,a0
    80005508:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    8000550c:	fe043503          	ld	a0,-32(s0)
    80005510:	fffff097          	auipc	ra,0xfffff
    80005514:	19c080e7          	jalr	412(ra) # 800046ac <fileclose>
  return 0;
    80005518:	4781                	li	a5,0
}
    8000551a:	853e                	mv	a0,a5
    8000551c:	60e2                	ld	ra,24(sp)
    8000551e:	6442                	ld	s0,16(sp)
    80005520:	6105                	addi	sp,sp,32
    80005522:	8082                	ret

0000000080005524 <sys_fstat>:
{
    80005524:	1101                	addi	sp,sp,-32
    80005526:	ec06                	sd	ra,24(sp)
    80005528:	e822                	sd	s0,16(sp)
    8000552a:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000552c:	fe840613          	addi	a2,s0,-24
    80005530:	4581                	li	a1,0
    80005532:	4501                	li	a0,0
    80005534:	00000097          	auipc	ra,0x0
    80005538:	c2c080e7          	jalr	-980(ra) # 80005160 <argfd>
    return -1;
    8000553c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000553e:	02054563          	bltz	a0,80005568 <sys_fstat+0x44>
    80005542:	fe040593          	addi	a1,s0,-32
    80005546:	4505                	li	a0,1
    80005548:	ffffd097          	auipc	ra,0xffffd
    8000554c:	694080e7          	jalr	1684(ra) # 80002bdc <argaddr>
    return -1;
    80005550:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005552:	00054b63          	bltz	a0,80005568 <sys_fstat+0x44>
  return filestat(f, st);
    80005556:	fe043583          	ld	a1,-32(s0)
    8000555a:	fe843503          	ld	a0,-24(s0)
    8000555e:	fffff097          	auipc	ra,0xfffff
    80005562:	23a080e7          	jalr	570(ra) # 80004798 <filestat>
    80005566:	87aa                	mv	a5,a0
}
    80005568:	853e                	mv	a0,a5
    8000556a:	60e2                	ld	ra,24(sp)
    8000556c:	6442                	ld	s0,16(sp)
    8000556e:	6105                	addi	sp,sp,32
    80005570:	8082                	ret

0000000080005572 <sys_link>:
{
    80005572:	7169                	addi	sp,sp,-304
    80005574:	f606                	sd	ra,296(sp)
    80005576:	f222                	sd	s0,288(sp)
    80005578:	ee26                	sd	s1,280(sp)
    8000557a:	ea4a                	sd	s2,272(sp)
    8000557c:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000557e:	08000613          	li	a2,128
    80005582:	ed040593          	addi	a1,s0,-304
    80005586:	4501                	li	a0,0
    80005588:	ffffd097          	auipc	ra,0xffffd
    8000558c:	676080e7          	jalr	1654(ra) # 80002bfe <argstr>
    return -1;
    80005590:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005592:	12054363          	bltz	a0,800056b8 <sys_link+0x146>
    80005596:	08000613          	li	a2,128
    8000559a:	f5040593          	addi	a1,s0,-176
    8000559e:	4505                	li	a0,1
    800055a0:	ffffd097          	auipc	ra,0xffffd
    800055a4:	65e080e7          	jalr	1630(ra) # 80002bfe <argstr>
    return -1;
    800055a8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055aa:	10054763          	bltz	a0,800056b8 <sys_link+0x146>
  begin_op(ROOTDEV);
    800055ae:	4501                	li	a0,0
    800055b0:	fffff097          	auipc	ra,0xfffff
    800055b4:	b62080e7          	jalr	-1182(ra) # 80004112 <begin_op>
  if((ip = namei(old)) == 0){
    800055b8:	ed040513          	addi	a0,s0,-304
    800055bc:	fffff097          	auipc	ra,0xfffff
    800055c0:	8fc080e7          	jalr	-1796(ra) # 80003eb8 <namei>
    800055c4:	84aa                	mv	s1,a0
    800055c6:	c559                	beqz	a0,80005654 <sys_link+0xe2>
  ilock(ip);
    800055c8:	ffffe097          	auipc	ra,0xffffe
    800055cc:	166080e7          	jalr	358(ra) # 8000372e <ilock>
  if(ip->type == T_DIR){
    800055d0:	04c49703          	lh	a4,76(s1)
    800055d4:	4785                	li	a5,1
    800055d6:	08f70663          	beq	a4,a5,80005662 <sys_link+0xf0>
  ip->nlink++;
    800055da:	0524d783          	lhu	a5,82(s1)
    800055de:	2785                	addiw	a5,a5,1
    800055e0:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    800055e4:	8526                	mv	a0,s1
    800055e6:	ffffe097          	auipc	ra,0xffffe
    800055ea:	07e080e7          	jalr	126(ra) # 80003664 <iupdate>
  iunlock(ip);
    800055ee:	8526                	mv	a0,s1
    800055f0:	ffffe097          	auipc	ra,0xffffe
    800055f4:	200080e7          	jalr	512(ra) # 800037f0 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800055f8:	fd040593          	addi	a1,s0,-48
    800055fc:	f5040513          	addi	a0,s0,-176
    80005600:	fffff097          	auipc	ra,0xfffff
    80005604:	8d6080e7          	jalr	-1834(ra) # 80003ed6 <nameiparent>
    80005608:	892a                	mv	s2,a0
    8000560a:	cd2d                	beqz	a0,80005684 <sys_link+0x112>
  ilock(dp);
    8000560c:	ffffe097          	auipc	ra,0xffffe
    80005610:	122080e7          	jalr	290(ra) # 8000372e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005614:	00092703          	lw	a4,0(s2)
    80005618:	409c                	lw	a5,0(s1)
    8000561a:	06f71063          	bne	a4,a5,8000567a <sys_link+0x108>
    8000561e:	40d0                	lw	a2,4(s1)
    80005620:	fd040593          	addi	a1,s0,-48
    80005624:	854a                	mv	a0,s2
    80005626:	ffffe097          	auipc	ra,0xffffe
    8000562a:	7d0080e7          	jalr	2000(ra) # 80003df6 <dirlink>
    8000562e:	04054663          	bltz	a0,8000567a <sys_link+0x108>
  iunlockput(dp);
    80005632:	854a                	mv	a0,s2
    80005634:	ffffe097          	auipc	ra,0xffffe
    80005638:	338080e7          	jalr	824(ra) # 8000396c <iunlockput>
  iput(ip);
    8000563c:	8526                	mv	a0,s1
    8000563e:	ffffe097          	auipc	ra,0xffffe
    80005642:	1fe080e7          	jalr	510(ra) # 8000383c <iput>
  end_op(ROOTDEV);
    80005646:	4501                	li	a0,0
    80005648:	fffff097          	auipc	ra,0xfffff
    8000564c:	b74080e7          	jalr	-1164(ra) # 800041bc <end_op>
  return 0;
    80005650:	4781                	li	a5,0
    80005652:	a09d                	j	800056b8 <sys_link+0x146>
    end_op(ROOTDEV);
    80005654:	4501                	li	a0,0
    80005656:	fffff097          	auipc	ra,0xfffff
    8000565a:	b66080e7          	jalr	-1178(ra) # 800041bc <end_op>
    return -1;
    8000565e:	57fd                	li	a5,-1
    80005660:	a8a1                	j	800056b8 <sys_link+0x146>
    iunlockput(ip);
    80005662:	8526                	mv	a0,s1
    80005664:	ffffe097          	auipc	ra,0xffffe
    80005668:	308080e7          	jalr	776(ra) # 8000396c <iunlockput>
    end_op(ROOTDEV);
    8000566c:	4501                	li	a0,0
    8000566e:	fffff097          	auipc	ra,0xfffff
    80005672:	b4e080e7          	jalr	-1202(ra) # 800041bc <end_op>
    return -1;
    80005676:	57fd                	li	a5,-1
    80005678:	a081                	j	800056b8 <sys_link+0x146>
    iunlockput(dp);
    8000567a:	854a                	mv	a0,s2
    8000567c:	ffffe097          	auipc	ra,0xffffe
    80005680:	2f0080e7          	jalr	752(ra) # 8000396c <iunlockput>
  ilock(ip);
    80005684:	8526                	mv	a0,s1
    80005686:	ffffe097          	auipc	ra,0xffffe
    8000568a:	0a8080e7          	jalr	168(ra) # 8000372e <ilock>
  ip->nlink--;
    8000568e:	0524d783          	lhu	a5,82(s1)
    80005692:	37fd                	addiw	a5,a5,-1
    80005694:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    80005698:	8526                	mv	a0,s1
    8000569a:	ffffe097          	auipc	ra,0xffffe
    8000569e:	fca080e7          	jalr	-54(ra) # 80003664 <iupdate>
  iunlockput(ip);
    800056a2:	8526                	mv	a0,s1
    800056a4:	ffffe097          	auipc	ra,0xffffe
    800056a8:	2c8080e7          	jalr	712(ra) # 8000396c <iunlockput>
  end_op(ROOTDEV);
    800056ac:	4501                	li	a0,0
    800056ae:	fffff097          	auipc	ra,0xfffff
    800056b2:	b0e080e7          	jalr	-1266(ra) # 800041bc <end_op>
  return -1;
    800056b6:	57fd                	li	a5,-1
}
    800056b8:	853e                	mv	a0,a5
    800056ba:	70b2                	ld	ra,296(sp)
    800056bc:	7412                	ld	s0,288(sp)
    800056be:	64f2                	ld	s1,280(sp)
    800056c0:	6952                	ld	s2,272(sp)
    800056c2:	6155                	addi	sp,sp,304
    800056c4:	8082                	ret

00000000800056c6 <sys_unlink>:
{
    800056c6:	7151                	addi	sp,sp,-240
    800056c8:	f586                	sd	ra,232(sp)
    800056ca:	f1a2                	sd	s0,224(sp)
    800056cc:	eda6                	sd	s1,216(sp)
    800056ce:	e9ca                	sd	s2,208(sp)
    800056d0:	e5ce                	sd	s3,200(sp)
    800056d2:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800056d4:	08000613          	li	a2,128
    800056d8:	f3040593          	addi	a1,s0,-208
    800056dc:	4501                	li	a0,0
    800056de:	ffffd097          	auipc	ra,0xffffd
    800056e2:	520080e7          	jalr	1312(ra) # 80002bfe <argstr>
    800056e6:	18054463          	bltz	a0,8000586e <sys_unlink+0x1a8>
  begin_op(ROOTDEV);
    800056ea:	4501                	li	a0,0
    800056ec:	fffff097          	auipc	ra,0xfffff
    800056f0:	a26080e7          	jalr	-1498(ra) # 80004112 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800056f4:	fb040593          	addi	a1,s0,-80
    800056f8:	f3040513          	addi	a0,s0,-208
    800056fc:	ffffe097          	auipc	ra,0xffffe
    80005700:	7da080e7          	jalr	2010(ra) # 80003ed6 <nameiparent>
    80005704:	84aa                	mv	s1,a0
    80005706:	cd61                	beqz	a0,800057de <sys_unlink+0x118>
  ilock(dp);
    80005708:	ffffe097          	auipc	ra,0xffffe
    8000570c:	026080e7          	jalr	38(ra) # 8000372e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005710:	00004597          	auipc	a1,0x4
    80005714:	37858593          	addi	a1,a1,888 # 80009a88 <userret+0x9f8>
    80005718:	fb040513          	addi	a0,s0,-80
    8000571c:	ffffe097          	auipc	ra,0xffffe
    80005720:	4b0080e7          	jalr	1200(ra) # 80003bcc <namecmp>
    80005724:	14050c63          	beqz	a0,8000587c <sys_unlink+0x1b6>
    80005728:	00004597          	auipc	a1,0x4
    8000572c:	36858593          	addi	a1,a1,872 # 80009a90 <userret+0xa00>
    80005730:	fb040513          	addi	a0,s0,-80
    80005734:	ffffe097          	auipc	ra,0xffffe
    80005738:	498080e7          	jalr	1176(ra) # 80003bcc <namecmp>
    8000573c:	14050063          	beqz	a0,8000587c <sys_unlink+0x1b6>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005740:	f2c40613          	addi	a2,s0,-212
    80005744:	fb040593          	addi	a1,s0,-80
    80005748:	8526                	mv	a0,s1
    8000574a:	ffffe097          	auipc	ra,0xffffe
    8000574e:	49c080e7          	jalr	1180(ra) # 80003be6 <dirlookup>
    80005752:	892a                	mv	s2,a0
    80005754:	12050463          	beqz	a0,8000587c <sys_unlink+0x1b6>
  ilock(ip);
    80005758:	ffffe097          	auipc	ra,0xffffe
    8000575c:	fd6080e7          	jalr	-42(ra) # 8000372e <ilock>
  if(ip->nlink < 1)
    80005760:	05291783          	lh	a5,82(s2)
    80005764:	08f05463          	blez	a5,800057ec <sys_unlink+0x126>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005768:	04c91703          	lh	a4,76(s2)
    8000576c:	4785                	li	a5,1
    8000576e:	08f70763          	beq	a4,a5,800057fc <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005772:	4641                	li	a2,16
    80005774:	4581                	li	a1,0
    80005776:	fc040513          	addi	a0,s0,-64
    8000577a:	ffffb097          	auipc	ra,0xffffb
    8000577e:	5f4080e7          	jalr	1524(ra) # 80000d6e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005782:	4741                	li	a4,16
    80005784:	f2c42683          	lw	a3,-212(s0)
    80005788:	fc040613          	addi	a2,s0,-64
    8000578c:	4581                	li	a1,0
    8000578e:	8526                	mv	a0,s1
    80005790:	ffffe097          	auipc	ra,0xffffe
    80005794:	322080e7          	jalr	802(ra) # 80003ab2 <writei>
    80005798:	47c1                	li	a5,16
    8000579a:	0af51763          	bne	a0,a5,80005848 <sys_unlink+0x182>
  if(ip->type == T_DIR){
    8000579e:	04c91703          	lh	a4,76(s2)
    800057a2:	4785                	li	a5,1
    800057a4:	0af70a63          	beq	a4,a5,80005858 <sys_unlink+0x192>
  iunlockput(dp);
    800057a8:	8526                	mv	a0,s1
    800057aa:	ffffe097          	auipc	ra,0xffffe
    800057ae:	1c2080e7          	jalr	450(ra) # 8000396c <iunlockput>
  ip->nlink--;
    800057b2:	05295783          	lhu	a5,82(s2)
    800057b6:	37fd                	addiw	a5,a5,-1
    800057b8:	04f91923          	sh	a5,82(s2)
  iupdate(ip);
    800057bc:	854a                	mv	a0,s2
    800057be:	ffffe097          	auipc	ra,0xffffe
    800057c2:	ea6080e7          	jalr	-346(ra) # 80003664 <iupdate>
  iunlockput(ip);
    800057c6:	854a                	mv	a0,s2
    800057c8:	ffffe097          	auipc	ra,0xffffe
    800057cc:	1a4080e7          	jalr	420(ra) # 8000396c <iunlockput>
  end_op(ROOTDEV);
    800057d0:	4501                	li	a0,0
    800057d2:	fffff097          	auipc	ra,0xfffff
    800057d6:	9ea080e7          	jalr	-1558(ra) # 800041bc <end_op>
  return 0;
    800057da:	4501                	li	a0,0
    800057dc:	a85d                	j	80005892 <sys_unlink+0x1cc>
    end_op(ROOTDEV);
    800057de:	4501                	li	a0,0
    800057e0:	fffff097          	auipc	ra,0xfffff
    800057e4:	9dc080e7          	jalr	-1572(ra) # 800041bc <end_op>
    return -1;
    800057e8:	557d                	li	a0,-1
    800057ea:	a065                	j	80005892 <sys_unlink+0x1cc>
    panic("unlink: nlink < 1");
    800057ec:	00004517          	auipc	a0,0x4
    800057f0:	2cc50513          	addi	a0,a0,716 # 80009ab8 <userret+0xa28>
    800057f4:	ffffb097          	auipc	ra,0xffffb
    800057f8:	d60080e7          	jalr	-672(ra) # 80000554 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057fc:	05492703          	lw	a4,84(s2)
    80005800:	02000793          	li	a5,32
    80005804:	f6e7f7e3          	bgeu	a5,a4,80005772 <sys_unlink+0xac>
    80005808:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000580c:	4741                	li	a4,16
    8000580e:	86ce                	mv	a3,s3
    80005810:	f1840613          	addi	a2,s0,-232
    80005814:	4581                	li	a1,0
    80005816:	854a                	mv	a0,s2
    80005818:	ffffe097          	auipc	ra,0xffffe
    8000581c:	1a6080e7          	jalr	422(ra) # 800039be <readi>
    80005820:	47c1                	li	a5,16
    80005822:	00f51b63          	bne	a0,a5,80005838 <sys_unlink+0x172>
    if(de.inum != 0)
    80005826:	f1845783          	lhu	a5,-232(s0)
    8000582a:	e7a1                	bnez	a5,80005872 <sys_unlink+0x1ac>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000582c:	29c1                	addiw	s3,s3,16
    8000582e:	05492783          	lw	a5,84(s2)
    80005832:	fcf9ede3          	bltu	s3,a5,8000580c <sys_unlink+0x146>
    80005836:	bf35                	j	80005772 <sys_unlink+0xac>
      panic("isdirempty: readi");
    80005838:	00004517          	auipc	a0,0x4
    8000583c:	29850513          	addi	a0,a0,664 # 80009ad0 <userret+0xa40>
    80005840:	ffffb097          	auipc	ra,0xffffb
    80005844:	d14080e7          	jalr	-748(ra) # 80000554 <panic>
    panic("unlink: writei");
    80005848:	00004517          	auipc	a0,0x4
    8000584c:	2a050513          	addi	a0,a0,672 # 80009ae8 <userret+0xa58>
    80005850:	ffffb097          	auipc	ra,0xffffb
    80005854:	d04080e7          	jalr	-764(ra) # 80000554 <panic>
    dp->nlink--;
    80005858:	0524d783          	lhu	a5,82(s1)
    8000585c:	37fd                	addiw	a5,a5,-1
    8000585e:	04f49923          	sh	a5,82(s1)
    iupdate(dp);
    80005862:	8526                	mv	a0,s1
    80005864:	ffffe097          	auipc	ra,0xffffe
    80005868:	e00080e7          	jalr	-512(ra) # 80003664 <iupdate>
    8000586c:	bf35                	j	800057a8 <sys_unlink+0xe2>
    return -1;
    8000586e:	557d                	li	a0,-1
    80005870:	a00d                	j	80005892 <sys_unlink+0x1cc>
    iunlockput(ip);
    80005872:	854a                	mv	a0,s2
    80005874:	ffffe097          	auipc	ra,0xffffe
    80005878:	0f8080e7          	jalr	248(ra) # 8000396c <iunlockput>
  iunlockput(dp);
    8000587c:	8526                	mv	a0,s1
    8000587e:	ffffe097          	auipc	ra,0xffffe
    80005882:	0ee080e7          	jalr	238(ra) # 8000396c <iunlockput>
  end_op(ROOTDEV);
    80005886:	4501                	li	a0,0
    80005888:	fffff097          	auipc	ra,0xfffff
    8000588c:	934080e7          	jalr	-1740(ra) # 800041bc <end_op>
  return -1;
    80005890:	557d                	li	a0,-1
}
    80005892:	70ae                	ld	ra,232(sp)
    80005894:	740e                	ld	s0,224(sp)
    80005896:	64ee                	ld	s1,216(sp)
    80005898:	694e                	ld	s2,208(sp)
    8000589a:	69ae                	ld	s3,200(sp)
    8000589c:	616d                	addi	sp,sp,240
    8000589e:	8082                	ret

00000000800058a0 <sys_open>:

uint64
sys_open(void)
{
    800058a0:	7131                	addi	sp,sp,-192
    800058a2:	fd06                	sd	ra,184(sp)
    800058a4:	f922                	sd	s0,176(sp)
    800058a6:	f526                	sd	s1,168(sp)
    800058a8:	f14a                	sd	s2,160(sp)
    800058aa:	ed4e                	sd	s3,152(sp)
    800058ac:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800058ae:	08000613          	li	a2,128
    800058b2:	f5040593          	addi	a1,s0,-176
    800058b6:	4501                	li	a0,0
    800058b8:	ffffd097          	auipc	ra,0xffffd
    800058bc:	346080e7          	jalr	838(ra) # 80002bfe <argstr>
    return -1;
    800058c0:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800058c2:	0a054963          	bltz	a0,80005974 <sys_open+0xd4>
    800058c6:	f4c40593          	addi	a1,s0,-180
    800058ca:	4505                	li	a0,1
    800058cc:	ffffd097          	auipc	ra,0xffffd
    800058d0:	2ee080e7          	jalr	750(ra) # 80002bba <argint>
    800058d4:	0a054063          	bltz	a0,80005974 <sys_open+0xd4>

  begin_op(ROOTDEV);
    800058d8:	4501                	li	a0,0
    800058da:	fffff097          	auipc	ra,0xfffff
    800058de:	838080e7          	jalr	-1992(ra) # 80004112 <begin_op>

  if(omode & O_CREATE){
    800058e2:	f4c42783          	lw	a5,-180(s0)
    800058e6:	2007f793          	andi	a5,a5,512
    800058ea:	c3dd                	beqz	a5,80005990 <sys_open+0xf0>
    ip = create(path, T_FILE, 0, 0);
    800058ec:	4681                	li	a3,0
    800058ee:	4601                	li	a2,0
    800058f0:	4589                	li	a1,2
    800058f2:	f5040513          	addi	a0,s0,-176
    800058f6:	00000097          	auipc	ra,0x0
    800058fa:	8d2080e7          	jalr	-1838(ra) # 800051c8 <create>
    800058fe:	892a                	mv	s2,a0
    if(ip == 0){
    80005900:	c151                	beqz	a0,80005984 <sys_open+0xe4>
      end_op(ROOTDEV);
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005902:	04c91703          	lh	a4,76(s2)
    80005906:	478d                	li	a5,3
    80005908:	00f71763          	bne	a4,a5,80005916 <sys_open+0x76>
    8000590c:	04e95703          	lhu	a4,78(s2)
    80005910:	47a5                	li	a5,9
    80005912:	0ce7e663          	bltu	a5,a4,800059de <sys_open+0x13e>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005916:	fffff097          	auipc	ra,0xfffff
    8000591a:	cda080e7          	jalr	-806(ra) # 800045f0 <filealloc>
    8000591e:	89aa                	mv	s3,a0
    80005920:	c97d                	beqz	a0,80005a16 <sys_open+0x176>
    80005922:	fffff097          	auipc	ra,0xfffff
    80005926:	7fc080e7          	jalr	2044(ra) # 8000511e <fdalloc>
    8000592a:	84aa                	mv	s1,a0
    8000592c:	0e054063          	bltz	a0,80005a0c <sys_open+0x16c>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005930:	04c91703          	lh	a4,76(s2)
    80005934:	478d                	li	a5,3
    80005936:	0cf70063          	beq	a4,a5,800059f6 <sys_open+0x156>
    f->type = FD_DEVICE;
    f->major = ip->major;
    f->minor = ip->minor;
  } else {
    f->type = FD_INODE;
    8000593a:	4789                	li	a5,2
    8000593c:	00f9a023          	sw	a5,0(s3)
  }
  f->ip = ip;
    80005940:	0329b023          	sd	s2,32(s3)
  f->off = 0;
    80005944:	0209a823          	sw	zero,48(s3)
  f->readable = !(omode & O_WRONLY);
    80005948:	f4c42783          	lw	a5,-180(s0)
    8000594c:	0017c713          	xori	a4,a5,1
    80005950:	8b05                	andi	a4,a4,1
    80005952:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005956:	8b8d                	andi	a5,a5,3
    80005958:	00f037b3          	snez	a5,a5
    8000595c:	00f984a3          	sb	a5,9(s3)

  iunlock(ip);
    80005960:	854a                	mv	a0,s2
    80005962:	ffffe097          	auipc	ra,0xffffe
    80005966:	e8e080e7          	jalr	-370(ra) # 800037f0 <iunlock>
  end_op(ROOTDEV);
    8000596a:	4501                	li	a0,0
    8000596c:	fffff097          	auipc	ra,0xfffff
    80005970:	850080e7          	jalr	-1968(ra) # 800041bc <end_op>

  return fd;
}
    80005974:	8526                	mv	a0,s1
    80005976:	70ea                	ld	ra,184(sp)
    80005978:	744a                	ld	s0,176(sp)
    8000597a:	74aa                	ld	s1,168(sp)
    8000597c:	790a                	ld	s2,160(sp)
    8000597e:	69ea                	ld	s3,152(sp)
    80005980:	6129                	addi	sp,sp,192
    80005982:	8082                	ret
      end_op(ROOTDEV);
    80005984:	4501                	li	a0,0
    80005986:	fffff097          	auipc	ra,0xfffff
    8000598a:	836080e7          	jalr	-1994(ra) # 800041bc <end_op>
      return -1;
    8000598e:	b7dd                	j	80005974 <sys_open+0xd4>
    if((ip = namei(path)) == 0){
    80005990:	f5040513          	addi	a0,s0,-176
    80005994:	ffffe097          	auipc	ra,0xffffe
    80005998:	524080e7          	jalr	1316(ra) # 80003eb8 <namei>
    8000599c:	892a                	mv	s2,a0
    8000599e:	c90d                	beqz	a0,800059d0 <sys_open+0x130>
    ilock(ip);
    800059a0:	ffffe097          	auipc	ra,0xffffe
    800059a4:	d8e080e7          	jalr	-626(ra) # 8000372e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800059a8:	04c91703          	lh	a4,76(s2)
    800059ac:	4785                	li	a5,1
    800059ae:	f4f71ae3          	bne	a4,a5,80005902 <sys_open+0x62>
    800059b2:	f4c42783          	lw	a5,-180(s0)
    800059b6:	d3a5                	beqz	a5,80005916 <sys_open+0x76>
      iunlockput(ip);
    800059b8:	854a                	mv	a0,s2
    800059ba:	ffffe097          	auipc	ra,0xffffe
    800059be:	fb2080e7          	jalr	-78(ra) # 8000396c <iunlockput>
      end_op(ROOTDEV);
    800059c2:	4501                	li	a0,0
    800059c4:	ffffe097          	auipc	ra,0xffffe
    800059c8:	7f8080e7          	jalr	2040(ra) # 800041bc <end_op>
      return -1;
    800059cc:	54fd                	li	s1,-1
    800059ce:	b75d                	j	80005974 <sys_open+0xd4>
      end_op(ROOTDEV);
    800059d0:	4501                	li	a0,0
    800059d2:	ffffe097          	auipc	ra,0xffffe
    800059d6:	7ea080e7          	jalr	2026(ra) # 800041bc <end_op>
      return -1;
    800059da:	54fd                	li	s1,-1
    800059dc:	bf61                	j	80005974 <sys_open+0xd4>
    iunlockput(ip);
    800059de:	854a                	mv	a0,s2
    800059e0:	ffffe097          	auipc	ra,0xffffe
    800059e4:	f8c080e7          	jalr	-116(ra) # 8000396c <iunlockput>
    end_op(ROOTDEV);
    800059e8:	4501                	li	a0,0
    800059ea:	ffffe097          	auipc	ra,0xffffe
    800059ee:	7d2080e7          	jalr	2002(ra) # 800041bc <end_op>
    return -1;
    800059f2:	54fd                	li	s1,-1
    800059f4:	b741                	j	80005974 <sys_open+0xd4>
    f->type = FD_DEVICE;
    800059f6:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800059fa:	04e91783          	lh	a5,78(s2)
    800059fe:	02f99a23          	sh	a5,52(s3)
    f->minor = ip->minor;
    80005a02:	05091783          	lh	a5,80(s2)
    80005a06:	02f99b23          	sh	a5,54(s3)
    80005a0a:	bf1d                	j	80005940 <sys_open+0xa0>
      fileclose(f);
    80005a0c:	854e                	mv	a0,s3
    80005a0e:	fffff097          	auipc	ra,0xfffff
    80005a12:	c9e080e7          	jalr	-866(ra) # 800046ac <fileclose>
    iunlockput(ip);
    80005a16:	854a                	mv	a0,s2
    80005a18:	ffffe097          	auipc	ra,0xffffe
    80005a1c:	f54080e7          	jalr	-172(ra) # 8000396c <iunlockput>
    end_op(ROOTDEV);
    80005a20:	4501                	li	a0,0
    80005a22:	ffffe097          	auipc	ra,0xffffe
    80005a26:	79a080e7          	jalr	1946(ra) # 800041bc <end_op>
    return -1;
    80005a2a:	54fd                	li	s1,-1
    80005a2c:	b7a1                	j	80005974 <sys_open+0xd4>

0000000080005a2e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a2e:	7175                	addi	sp,sp,-144
    80005a30:	e506                	sd	ra,136(sp)
    80005a32:	e122                	sd	s0,128(sp)
    80005a34:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op(ROOTDEV);
    80005a36:	4501                	li	a0,0
    80005a38:	ffffe097          	auipc	ra,0xffffe
    80005a3c:	6da080e7          	jalr	1754(ra) # 80004112 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a40:	08000613          	li	a2,128
    80005a44:	f7040593          	addi	a1,s0,-144
    80005a48:	4501                	li	a0,0
    80005a4a:	ffffd097          	auipc	ra,0xffffd
    80005a4e:	1b4080e7          	jalr	436(ra) # 80002bfe <argstr>
    80005a52:	02054a63          	bltz	a0,80005a86 <sys_mkdir+0x58>
    80005a56:	4681                	li	a3,0
    80005a58:	4601                	li	a2,0
    80005a5a:	4585                	li	a1,1
    80005a5c:	f7040513          	addi	a0,s0,-144
    80005a60:	fffff097          	auipc	ra,0xfffff
    80005a64:	768080e7          	jalr	1896(ra) # 800051c8 <create>
    80005a68:	cd19                	beqz	a0,80005a86 <sys_mkdir+0x58>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80005a6a:	ffffe097          	auipc	ra,0xffffe
    80005a6e:	f02080e7          	jalr	-254(ra) # 8000396c <iunlockput>
  end_op(ROOTDEV);
    80005a72:	4501                	li	a0,0
    80005a74:	ffffe097          	auipc	ra,0xffffe
    80005a78:	748080e7          	jalr	1864(ra) # 800041bc <end_op>
  return 0;
    80005a7c:	4501                	li	a0,0
}
    80005a7e:	60aa                	ld	ra,136(sp)
    80005a80:	640a                	ld	s0,128(sp)
    80005a82:	6149                	addi	sp,sp,144
    80005a84:	8082                	ret
    end_op(ROOTDEV);
    80005a86:	4501                	li	a0,0
    80005a88:	ffffe097          	auipc	ra,0xffffe
    80005a8c:	734080e7          	jalr	1844(ra) # 800041bc <end_op>
    return -1;
    80005a90:	557d                	li	a0,-1
    80005a92:	b7f5                	j	80005a7e <sys_mkdir+0x50>

0000000080005a94 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005a94:	7135                	addi	sp,sp,-160
    80005a96:	ed06                	sd	ra,152(sp)
    80005a98:	e922                	sd	s0,144(sp)
    80005a9a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op(ROOTDEV);
    80005a9c:	4501                	li	a0,0
    80005a9e:	ffffe097          	auipc	ra,0xffffe
    80005aa2:	674080e7          	jalr	1652(ra) # 80004112 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005aa6:	08000613          	li	a2,128
    80005aaa:	f7040593          	addi	a1,s0,-144
    80005aae:	4501                	li	a0,0
    80005ab0:	ffffd097          	auipc	ra,0xffffd
    80005ab4:	14e080e7          	jalr	334(ra) # 80002bfe <argstr>
    80005ab8:	04054b63          	bltz	a0,80005b0e <sys_mknod+0x7a>
     argint(1, &major) < 0 ||
    80005abc:	f6c40593          	addi	a1,s0,-148
    80005ac0:	4505                	li	a0,1
    80005ac2:	ffffd097          	auipc	ra,0xffffd
    80005ac6:	0f8080e7          	jalr	248(ra) # 80002bba <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005aca:	04054263          	bltz	a0,80005b0e <sys_mknod+0x7a>
     argint(2, &minor) < 0 ||
    80005ace:	f6840593          	addi	a1,s0,-152
    80005ad2:	4509                	li	a0,2
    80005ad4:	ffffd097          	auipc	ra,0xffffd
    80005ad8:	0e6080e7          	jalr	230(ra) # 80002bba <argint>
     argint(1, &major) < 0 ||
    80005adc:	02054963          	bltz	a0,80005b0e <sys_mknod+0x7a>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005ae0:	f6841683          	lh	a3,-152(s0)
    80005ae4:	f6c41603          	lh	a2,-148(s0)
    80005ae8:	458d                	li	a1,3
    80005aea:	f7040513          	addi	a0,s0,-144
    80005aee:	fffff097          	auipc	ra,0xfffff
    80005af2:	6da080e7          	jalr	1754(ra) # 800051c8 <create>
     argint(2, &minor) < 0 ||
    80005af6:	cd01                	beqz	a0,80005b0e <sys_mknod+0x7a>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80005af8:	ffffe097          	auipc	ra,0xffffe
    80005afc:	e74080e7          	jalr	-396(ra) # 8000396c <iunlockput>
  end_op(ROOTDEV);
    80005b00:	4501                	li	a0,0
    80005b02:	ffffe097          	auipc	ra,0xffffe
    80005b06:	6ba080e7          	jalr	1722(ra) # 800041bc <end_op>
  return 0;
    80005b0a:	4501                	li	a0,0
    80005b0c:	a039                	j	80005b1a <sys_mknod+0x86>
    end_op(ROOTDEV);
    80005b0e:	4501                	li	a0,0
    80005b10:	ffffe097          	auipc	ra,0xffffe
    80005b14:	6ac080e7          	jalr	1708(ra) # 800041bc <end_op>
    return -1;
    80005b18:	557d                	li	a0,-1
}
    80005b1a:	60ea                	ld	ra,152(sp)
    80005b1c:	644a                	ld	s0,144(sp)
    80005b1e:	610d                	addi	sp,sp,160
    80005b20:	8082                	ret

0000000080005b22 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b22:	7135                	addi	sp,sp,-160
    80005b24:	ed06                	sd	ra,152(sp)
    80005b26:	e922                	sd	s0,144(sp)
    80005b28:	e526                	sd	s1,136(sp)
    80005b2a:	e14a                	sd	s2,128(sp)
    80005b2c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b2e:	ffffc097          	auipc	ra,0xffffc
    80005b32:	f66080e7          	jalr	-154(ra) # 80001a94 <myproc>
    80005b36:	892a                	mv	s2,a0
  
  begin_op(ROOTDEV);
    80005b38:	4501                	li	a0,0
    80005b3a:	ffffe097          	auipc	ra,0xffffe
    80005b3e:	5d8080e7          	jalr	1496(ra) # 80004112 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b42:	08000613          	li	a2,128
    80005b46:	f6040593          	addi	a1,s0,-160
    80005b4a:	4501                	li	a0,0
    80005b4c:	ffffd097          	auipc	ra,0xffffd
    80005b50:	0b2080e7          	jalr	178(ra) # 80002bfe <argstr>
    80005b54:	04054c63          	bltz	a0,80005bac <sys_chdir+0x8a>
    80005b58:	f6040513          	addi	a0,s0,-160
    80005b5c:	ffffe097          	auipc	ra,0xffffe
    80005b60:	35c080e7          	jalr	860(ra) # 80003eb8 <namei>
    80005b64:	84aa                	mv	s1,a0
    80005b66:	c139                	beqz	a0,80005bac <sys_chdir+0x8a>
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80005b68:	ffffe097          	auipc	ra,0xffffe
    80005b6c:	bc6080e7          	jalr	-1082(ra) # 8000372e <ilock>
  if(ip->type != T_DIR){
    80005b70:	04c49703          	lh	a4,76(s1)
    80005b74:	4785                	li	a5,1
    80005b76:	04f71263          	bne	a4,a5,80005bba <sys_chdir+0x98>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }
  iunlock(ip);
    80005b7a:	8526                	mv	a0,s1
    80005b7c:	ffffe097          	auipc	ra,0xffffe
    80005b80:	c74080e7          	jalr	-908(ra) # 800037f0 <iunlock>
  iput(p->cwd);
    80005b84:	15893503          	ld	a0,344(s2)
    80005b88:	ffffe097          	auipc	ra,0xffffe
    80005b8c:	cb4080e7          	jalr	-844(ra) # 8000383c <iput>
  end_op(ROOTDEV);
    80005b90:	4501                	li	a0,0
    80005b92:	ffffe097          	auipc	ra,0xffffe
    80005b96:	62a080e7          	jalr	1578(ra) # 800041bc <end_op>
  p->cwd = ip;
    80005b9a:	14993c23          	sd	s1,344(s2)
  return 0;
    80005b9e:	4501                	li	a0,0
}
    80005ba0:	60ea                	ld	ra,152(sp)
    80005ba2:	644a                	ld	s0,144(sp)
    80005ba4:	64aa                	ld	s1,136(sp)
    80005ba6:	690a                	ld	s2,128(sp)
    80005ba8:	610d                	addi	sp,sp,160
    80005baa:	8082                	ret
    end_op(ROOTDEV);
    80005bac:	4501                	li	a0,0
    80005bae:	ffffe097          	auipc	ra,0xffffe
    80005bb2:	60e080e7          	jalr	1550(ra) # 800041bc <end_op>
    return -1;
    80005bb6:	557d                	li	a0,-1
    80005bb8:	b7e5                	j	80005ba0 <sys_chdir+0x7e>
    iunlockput(ip);
    80005bba:	8526                	mv	a0,s1
    80005bbc:	ffffe097          	auipc	ra,0xffffe
    80005bc0:	db0080e7          	jalr	-592(ra) # 8000396c <iunlockput>
    end_op(ROOTDEV);
    80005bc4:	4501                	li	a0,0
    80005bc6:	ffffe097          	auipc	ra,0xffffe
    80005bca:	5f6080e7          	jalr	1526(ra) # 800041bc <end_op>
    return -1;
    80005bce:	557d                	li	a0,-1
    80005bd0:	bfc1                	j	80005ba0 <sys_chdir+0x7e>

0000000080005bd2 <sys_exec>:

uint64
sys_exec(void)
{
    80005bd2:	7145                	addi	sp,sp,-464
    80005bd4:	e786                	sd	ra,456(sp)
    80005bd6:	e3a2                	sd	s0,448(sp)
    80005bd8:	ff26                	sd	s1,440(sp)
    80005bda:	fb4a                	sd	s2,432(sp)
    80005bdc:	f74e                	sd	s3,424(sp)
    80005bde:	f352                	sd	s4,416(sp)
    80005be0:	ef56                	sd	s5,408(sp)
    80005be2:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005be4:	08000613          	li	a2,128
    80005be8:	f4040593          	addi	a1,s0,-192
    80005bec:	4501                	li	a0,0
    80005bee:	ffffd097          	auipc	ra,0xffffd
    80005bf2:	010080e7          	jalr	16(ra) # 80002bfe <argstr>
    80005bf6:	0e054663          	bltz	a0,80005ce2 <sys_exec+0x110>
    80005bfa:	e3840593          	addi	a1,s0,-456
    80005bfe:	4505                	li	a0,1
    80005c00:	ffffd097          	auipc	ra,0xffffd
    80005c04:	fdc080e7          	jalr	-36(ra) # 80002bdc <argaddr>
    80005c08:	0e054763          	bltz	a0,80005cf6 <sys_exec+0x124>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
    80005c0c:	10000613          	li	a2,256
    80005c10:	4581                	li	a1,0
    80005c12:	e4040513          	addi	a0,s0,-448
    80005c16:	ffffb097          	auipc	ra,0xffffb
    80005c1a:	158080e7          	jalr	344(ra) # 80000d6e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c1e:	e4040913          	addi	s2,s0,-448
  memset(argv, 0, sizeof(argv));
    80005c22:	89ca                	mv	s3,s2
    80005c24:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    80005c26:	02000a13          	li	s4,32
    80005c2a:	00048a9b          	sext.w	s5,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c2e:	00349793          	slli	a5,s1,0x3
    80005c32:	e3040593          	addi	a1,s0,-464
    80005c36:	e3843503          	ld	a0,-456(s0)
    80005c3a:	953e                	add	a0,a0,a5
    80005c3c:	ffffd097          	auipc	ra,0xffffd
    80005c40:	ee4080e7          	jalr	-284(ra) # 80002b20 <fetchaddr>
    80005c44:	02054a63          	bltz	a0,80005c78 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005c48:	e3043783          	ld	a5,-464(s0)
    80005c4c:	c7a1                	beqz	a5,80005c94 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c4e:	ffffb097          	auipc	ra,0xffffb
    80005c52:	d1e080e7          	jalr	-738(ra) # 8000096c <kalloc>
    80005c56:	85aa                	mv	a1,a0
    80005c58:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005c5c:	c92d                	beqz	a0,80005cce <sys_exec+0xfc>
      panic("sys_exec kalloc");
    if(fetchstr(uarg, argv[i], PGSIZE) < 0){
    80005c5e:	6605                	lui	a2,0x1
    80005c60:	e3043503          	ld	a0,-464(s0)
    80005c64:	ffffd097          	auipc	ra,0xffffd
    80005c68:	f0e080e7          	jalr	-242(ra) # 80002b72 <fetchstr>
    80005c6c:	00054663          	bltz	a0,80005c78 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005c70:	0485                	addi	s1,s1,1
    80005c72:	09a1                	addi	s3,s3,8
    80005c74:	fb449be3          	bne	s1,s4,80005c2a <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c78:	10090493          	addi	s1,s2,256
    80005c7c:	00093503          	ld	a0,0(s2)
    80005c80:	cd39                	beqz	a0,80005cde <sys_exec+0x10c>
    kfree(argv[i]);
    80005c82:	ffffb097          	auipc	ra,0xffffb
    80005c86:	bee080e7          	jalr	-1042(ra) # 80000870 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c8a:	0921                	addi	s2,s2,8
    80005c8c:	fe9918e3          	bne	s2,s1,80005c7c <sys_exec+0xaa>
  return -1;
    80005c90:	557d                	li	a0,-1
    80005c92:	a889                	j	80005ce4 <sys_exec+0x112>
      argv[i] = 0;
    80005c94:	0a8e                	slli	s5,s5,0x3
    80005c96:	fc040793          	addi	a5,s0,-64
    80005c9a:	9abe                	add	s5,s5,a5
    80005c9c:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005ca0:	e4040593          	addi	a1,s0,-448
    80005ca4:	f4040513          	addi	a0,s0,-192
    80005ca8:	fffff097          	auipc	ra,0xfffff
    80005cac:	0ea080e7          	jalr	234(ra) # 80004d92 <exec>
    80005cb0:	84aa                	mv	s1,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cb2:	10090993          	addi	s3,s2,256
    80005cb6:	00093503          	ld	a0,0(s2)
    80005cba:	c901                	beqz	a0,80005cca <sys_exec+0xf8>
    kfree(argv[i]);
    80005cbc:	ffffb097          	auipc	ra,0xffffb
    80005cc0:	bb4080e7          	jalr	-1100(ra) # 80000870 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cc4:	0921                	addi	s2,s2,8
    80005cc6:	ff3918e3          	bne	s2,s3,80005cb6 <sys_exec+0xe4>
  return ret;
    80005cca:	8526                	mv	a0,s1
    80005ccc:	a821                	j	80005ce4 <sys_exec+0x112>
      panic("sys_exec kalloc");
    80005cce:	00004517          	auipc	a0,0x4
    80005cd2:	e2a50513          	addi	a0,a0,-470 # 80009af8 <userret+0xa68>
    80005cd6:	ffffb097          	auipc	ra,0xffffb
    80005cda:	87e080e7          	jalr	-1922(ra) # 80000554 <panic>
  return -1;
    80005cde:	557d                	li	a0,-1
    80005ce0:	a011                	j	80005ce4 <sys_exec+0x112>
    return -1;
    80005ce2:	557d                	li	a0,-1
}
    80005ce4:	60be                	ld	ra,456(sp)
    80005ce6:	641e                	ld	s0,448(sp)
    80005ce8:	74fa                	ld	s1,440(sp)
    80005cea:	795a                	ld	s2,432(sp)
    80005cec:	79ba                	ld	s3,424(sp)
    80005cee:	7a1a                	ld	s4,416(sp)
    80005cf0:	6afa                	ld	s5,408(sp)
    80005cf2:	6179                	addi	sp,sp,464
    80005cf4:	8082                	ret
    return -1;
    80005cf6:	557d                	li	a0,-1
    80005cf8:	b7f5                	j	80005ce4 <sys_exec+0x112>

0000000080005cfa <sys_pipe>:

uint64
sys_pipe(void)
{
    80005cfa:	7139                	addi	sp,sp,-64
    80005cfc:	fc06                	sd	ra,56(sp)
    80005cfe:	f822                	sd	s0,48(sp)
    80005d00:	f426                	sd	s1,40(sp)
    80005d02:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d04:	ffffc097          	auipc	ra,0xffffc
    80005d08:	d90080e7          	jalr	-624(ra) # 80001a94 <myproc>
    80005d0c:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005d0e:	fd840593          	addi	a1,s0,-40
    80005d12:	4501                	li	a0,0
    80005d14:	ffffd097          	auipc	ra,0xffffd
    80005d18:	ec8080e7          	jalr	-312(ra) # 80002bdc <argaddr>
    return -1;
    80005d1c:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005d1e:	0e054063          	bltz	a0,80005dfe <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005d22:	fc840593          	addi	a1,s0,-56
    80005d26:	fd040513          	addi	a0,s0,-48
    80005d2a:	fffff097          	auipc	ra,0xfffff
    80005d2e:	d26080e7          	jalr	-730(ra) # 80004a50 <pipealloc>
    return -1;
    80005d32:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d34:	0c054563          	bltz	a0,80005dfe <sys_pipe+0x104>
  fd0 = -1;
    80005d38:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d3c:	fd043503          	ld	a0,-48(s0)
    80005d40:	fffff097          	auipc	ra,0xfffff
    80005d44:	3de080e7          	jalr	990(ra) # 8000511e <fdalloc>
    80005d48:	fca42223          	sw	a0,-60(s0)
    80005d4c:	08054c63          	bltz	a0,80005de4 <sys_pipe+0xea>
    80005d50:	fc843503          	ld	a0,-56(s0)
    80005d54:	fffff097          	auipc	ra,0xfffff
    80005d58:	3ca080e7          	jalr	970(ra) # 8000511e <fdalloc>
    80005d5c:	fca42023          	sw	a0,-64(s0)
    80005d60:	06054863          	bltz	a0,80005dd0 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d64:	4691                	li	a3,4
    80005d66:	fc440613          	addi	a2,s0,-60
    80005d6a:	fd843583          	ld	a1,-40(s0)
    80005d6e:	6ca8                	ld	a0,88(s1)
    80005d70:	ffffc097          	auipc	ra,0xffffc
    80005d74:	a16080e7          	jalr	-1514(ra) # 80001786 <copyout>
    80005d78:	02054063          	bltz	a0,80005d98 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d7c:	4691                	li	a3,4
    80005d7e:	fc040613          	addi	a2,s0,-64
    80005d82:	fd843583          	ld	a1,-40(s0)
    80005d86:	0591                	addi	a1,a1,4
    80005d88:	6ca8                	ld	a0,88(s1)
    80005d8a:	ffffc097          	auipc	ra,0xffffc
    80005d8e:	9fc080e7          	jalr	-1540(ra) # 80001786 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d92:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d94:	06055563          	bgez	a0,80005dfe <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005d98:	fc442783          	lw	a5,-60(s0)
    80005d9c:	07e9                	addi	a5,a5,26
    80005d9e:	078e                	slli	a5,a5,0x3
    80005da0:	97a6                	add	a5,a5,s1
    80005da2:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005da6:	fc042503          	lw	a0,-64(s0)
    80005daa:	0569                	addi	a0,a0,26
    80005dac:	050e                	slli	a0,a0,0x3
    80005dae:	9526                	add	a0,a0,s1
    80005db0:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005db4:	fd043503          	ld	a0,-48(s0)
    80005db8:	fffff097          	auipc	ra,0xfffff
    80005dbc:	8f4080e7          	jalr	-1804(ra) # 800046ac <fileclose>
    fileclose(wf);
    80005dc0:	fc843503          	ld	a0,-56(s0)
    80005dc4:	fffff097          	auipc	ra,0xfffff
    80005dc8:	8e8080e7          	jalr	-1816(ra) # 800046ac <fileclose>
    return -1;
    80005dcc:	57fd                	li	a5,-1
    80005dce:	a805                	j	80005dfe <sys_pipe+0x104>
    if(fd0 >= 0)
    80005dd0:	fc442783          	lw	a5,-60(s0)
    80005dd4:	0007c863          	bltz	a5,80005de4 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005dd8:	01a78513          	addi	a0,a5,26
    80005ddc:	050e                	slli	a0,a0,0x3
    80005dde:	9526                	add	a0,a0,s1
    80005de0:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005de4:	fd043503          	ld	a0,-48(s0)
    80005de8:	fffff097          	auipc	ra,0xfffff
    80005dec:	8c4080e7          	jalr	-1852(ra) # 800046ac <fileclose>
    fileclose(wf);
    80005df0:	fc843503          	ld	a0,-56(s0)
    80005df4:	fffff097          	auipc	ra,0xfffff
    80005df8:	8b8080e7          	jalr	-1864(ra) # 800046ac <fileclose>
    return -1;
    80005dfc:	57fd                	li	a5,-1
}
    80005dfe:	853e                	mv	a0,a5
    80005e00:	70e2                	ld	ra,56(sp)
    80005e02:	7442                	ld	s0,48(sp)
    80005e04:	74a2                	ld	s1,40(sp)
    80005e06:	6121                	addi	sp,sp,64
    80005e08:	8082                	ret
    80005e0a:	0000                	unimp
    80005e0c:	0000                	unimp
	...

0000000080005e10 <kernelvec>:
    80005e10:	7111                	addi	sp,sp,-256
    80005e12:	e006                	sd	ra,0(sp)
    80005e14:	e40a                	sd	sp,8(sp)
    80005e16:	e80e                	sd	gp,16(sp)
    80005e18:	ec12                	sd	tp,24(sp)
    80005e1a:	f016                	sd	t0,32(sp)
    80005e1c:	f41a                	sd	t1,40(sp)
    80005e1e:	f81e                	sd	t2,48(sp)
    80005e20:	fc22                	sd	s0,56(sp)
    80005e22:	e0a6                	sd	s1,64(sp)
    80005e24:	e4aa                	sd	a0,72(sp)
    80005e26:	e8ae                	sd	a1,80(sp)
    80005e28:	ecb2                	sd	a2,88(sp)
    80005e2a:	f0b6                	sd	a3,96(sp)
    80005e2c:	f4ba                	sd	a4,104(sp)
    80005e2e:	f8be                	sd	a5,112(sp)
    80005e30:	fcc2                	sd	a6,120(sp)
    80005e32:	e146                	sd	a7,128(sp)
    80005e34:	e54a                	sd	s2,136(sp)
    80005e36:	e94e                	sd	s3,144(sp)
    80005e38:	ed52                	sd	s4,152(sp)
    80005e3a:	f156                	sd	s5,160(sp)
    80005e3c:	f55a                	sd	s6,168(sp)
    80005e3e:	f95e                	sd	s7,176(sp)
    80005e40:	fd62                	sd	s8,184(sp)
    80005e42:	e1e6                	sd	s9,192(sp)
    80005e44:	e5ea                	sd	s10,200(sp)
    80005e46:	e9ee                	sd	s11,208(sp)
    80005e48:	edf2                	sd	t3,216(sp)
    80005e4a:	f1f6                	sd	t4,224(sp)
    80005e4c:	f5fa                	sd	t5,232(sp)
    80005e4e:	f9fe                	sd	t6,240(sp)
    80005e50:	b91fc0ef          	jal	ra,800029e0 <kerneltrap>
    80005e54:	6082                	ld	ra,0(sp)
    80005e56:	6122                	ld	sp,8(sp)
    80005e58:	61c2                	ld	gp,16(sp)
    80005e5a:	7282                	ld	t0,32(sp)
    80005e5c:	7322                	ld	t1,40(sp)
    80005e5e:	73c2                	ld	t2,48(sp)
    80005e60:	7462                	ld	s0,56(sp)
    80005e62:	6486                	ld	s1,64(sp)
    80005e64:	6526                	ld	a0,72(sp)
    80005e66:	65c6                	ld	a1,80(sp)
    80005e68:	6666                	ld	a2,88(sp)
    80005e6a:	7686                	ld	a3,96(sp)
    80005e6c:	7726                	ld	a4,104(sp)
    80005e6e:	77c6                	ld	a5,112(sp)
    80005e70:	7866                	ld	a6,120(sp)
    80005e72:	688a                	ld	a7,128(sp)
    80005e74:	692a                	ld	s2,136(sp)
    80005e76:	69ca                	ld	s3,144(sp)
    80005e78:	6a6a                	ld	s4,152(sp)
    80005e7a:	7a8a                	ld	s5,160(sp)
    80005e7c:	7b2a                	ld	s6,168(sp)
    80005e7e:	7bca                	ld	s7,176(sp)
    80005e80:	7c6a                	ld	s8,184(sp)
    80005e82:	6c8e                	ld	s9,192(sp)
    80005e84:	6d2e                	ld	s10,200(sp)
    80005e86:	6dce                	ld	s11,208(sp)
    80005e88:	6e6e                	ld	t3,216(sp)
    80005e8a:	7e8e                	ld	t4,224(sp)
    80005e8c:	7f2e                	ld	t5,232(sp)
    80005e8e:	7fce                	ld	t6,240(sp)
    80005e90:	6111                	addi	sp,sp,256
    80005e92:	10200073          	sret
    80005e96:	00000013          	nop
    80005e9a:	00000013          	nop
    80005e9e:	0001                	nop

0000000080005ea0 <timervec>:
    80005ea0:	34051573          	csrrw	a0,mscratch,a0
    80005ea4:	e10c                	sd	a1,0(a0)
    80005ea6:	e510                	sd	a2,8(a0)
    80005ea8:	e914                	sd	a3,16(a0)
    80005eaa:	710c                	ld	a1,32(a0)
    80005eac:	7510                	ld	a2,40(a0)
    80005eae:	6194                	ld	a3,0(a1)
    80005eb0:	96b2                	add	a3,a3,a2
    80005eb2:	e194                	sd	a3,0(a1)
    80005eb4:	4589                	li	a1,2
    80005eb6:	14459073          	csrw	sip,a1
    80005eba:	6914                	ld	a3,16(a0)
    80005ebc:	6510                	ld	a2,8(a0)
    80005ebe:	610c                	ld	a1,0(a0)
    80005ec0:	34051573          	csrrw	a0,mscratch,a0
    80005ec4:	30200073          	mret
	...

0000000080005eca <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005eca:	1141                	addi	sp,sp,-16
    80005ecc:	e422                	sd	s0,8(sp)
    80005ece:	0800                	addi	s0,sp,16
  // XXX need a PLIC_PRIORITY(irq) macro
  
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005ed0:	0c0007b7          	lui	a5,0xc000
    80005ed4:	4705                	li	a4,1
    80005ed6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005ed8:	c3d8                	sw	a4,4(a5)
    80005eda:	0791                	addi	a5,a5,4

  // PCIE IRQs are 32 to 35
  for(int irq = 1; irq < 0x35; irq++){
    *(uint32*)(PLIC + irq*4) = 1;
    80005edc:	4685                	li	a3,1
  for(int irq = 1; irq < 0x35; irq++){
    80005ede:	0c000737          	lui	a4,0xc000
    80005ee2:	0d470713          	addi	a4,a4,212 # c0000d4 <_entry-0x73ffff2c>
    *(uint32*)(PLIC + irq*4) = 1;
    80005ee6:	c394                	sw	a3,0(a5)
  for(int irq = 1; irq < 0x35; irq++){
    80005ee8:	0791                	addi	a5,a5,4
    80005eea:	fee79ee3          	bne	a5,a4,80005ee6 <plicinit+0x1c>
  }
}
    80005eee:	6422                	ld	s0,8(sp)
    80005ef0:	0141                	addi	sp,sp,16
    80005ef2:	8082                	ret

0000000080005ef4 <plicinithart>:

void
plicinithart(void)
{
    80005ef4:	1141                	addi	sp,sp,-16
    80005ef6:	e406                	sd	ra,8(sp)
    80005ef8:	e022                	sd	s0,0(sp)
    80005efa:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005efc:	ffffc097          	auipc	ra,0xffffc
    80005f00:	b6c080e7          	jalr	-1172(ra) # 80001a68 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  uint32 enabled = 0;
  enabled |= (1 << UART0_IRQ);
  enabled |= (1 << VIRTIO0_IRQ);
  *(uint32*)PLIC_SENABLE(hart) = enabled;
    80005f04:	0085171b          	slliw	a4,a0,0x8
    80005f08:	0c0027b7          	lui	a5,0xc002
    80005f0c:	97ba                	add	a5,a5,a4
    80005f0e:	40200713          	li	a4,1026
    80005f12:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // hack to get at next 32 IRQs for e1000
  *(uint32*)(PLIC_SENABLE(hart)+4) = 0xffffffff;
    80005f16:	577d                	li	a4,-1
    80005f18:	08e7a223          	sw	a4,132(a5)

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f1c:	00d5151b          	slliw	a0,a0,0xd
    80005f20:	0c2017b7          	lui	a5,0xc201
    80005f24:	953e                	add	a0,a0,a5
    80005f26:	00052023          	sw	zero,0(a0)
}
    80005f2a:	60a2                	ld	ra,8(sp)
    80005f2c:	6402                	ld	s0,0(sp)
    80005f2e:	0141                	addi	sp,sp,16
    80005f30:	8082                	ret

0000000080005f32 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f32:	1141                	addi	sp,sp,-16
    80005f34:	e406                	sd	ra,8(sp)
    80005f36:	e022                	sd	s0,0(sp)
    80005f38:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f3a:	ffffc097          	auipc	ra,0xffffc
    80005f3e:	b2e080e7          	jalr	-1234(ra) # 80001a68 <cpuid>
  //int irq = *(uint32*)(PLIC + 0x201004);
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f42:	00d5179b          	slliw	a5,a0,0xd
    80005f46:	0c201537          	lui	a0,0xc201
    80005f4a:	953e                	add	a0,a0,a5
  return irq;
}
    80005f4c:	4148                	lw	a0,4(a0)
    80005f4e:	60a2                	ld	ra,8(sp)
    80005f50:	6402                	ld	s0,0(sp)
    80005f52:	0141                	addi	sp,sp,16
    80005f54:	8082                	ret

0000000080005f56 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f56:	1101                	addi	sp,sp,-32
    80005f58:	ec06                	sd	ra,24(sp)
    80005f5a:	e822                	sd	s0,16(sp)
    80005f5c:	e426                	sd	s1,8(sp)
    80005f5e:	1000                	addi	s0,sp,32
    80005f60:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f62:	ffffc097          	auipc	ra,0xffffc
    80005f66:	b06080e7          	jalr	-1274(ra) # 80001a68 <cpuid>
  //*(uint32*)(PLIC + 0x201004) = irq;
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f6a:	00d5151b          	slliw	a0,a0,0xd
    80005f6e:	0c2017b7          	lui	a5,0xc201
    80005f72:	97aa                	add	a5,a5,a0
    80005f74:	c3c4                	sw	s1,4(a5)
}
    80005f76:	60e2                	ld	ra,24(sp)
    80005f78:	6442                	ld	s0,16(sp)
    80005f7a:	64a2                	ld	s1,8(sp)
    80005f7c:	6105                	addi	sp,sp,32
    80005f7e:	8082                	ret

0000000080005f80 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int n, int i)
{
    80005f80:	1141                	addi	sp,sp,-16
    80005f82:	e406                	sd	ra,8(sp)
    80005f84:	e022                	sd	s0,0(sp)
    80005f86:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005f88:	479d                	li	a5,7
    80005f8a:	06b7c963          	blt	a5,a1,80005ffc <free_desc+0x7c>
    panic("virtio_disk_intr 1");
  if(disk[n].free[i])
    80005f8e:	00151793          	slli	a5,a0,0x1
    80005f92:	97aa                	add	a5,a5,a0
    80005f94:	00c79713          	slli	a4,a5,0xc
    80005f98:	0001d797          	auipc	a5,0x1d
    80005f9c:	06878793          	addi	a5,a5,104 # 80023000 <disk>
    80005fa0:	97ba                	add	a5,a5,a4
    80005fa2:	97ae                	add	a5,a5,a1
    80005fa4:	6709                	lui	a4,0x2
    80005fa6:	97ba                	add	a5,a5,a4
    80005fa8:	0187c783          	lbu	a5,24(a5)
    80005fac:	e3a5                	bnez	a5,8000600c <free_desc+0x8c>
    panic("virtio_disk_intr 2");
  disk[n].desc[i].addr = 0;
    80005fae:	0001d817          	auipc	a6,0x1d
    80005fb2:	05280813          	addi	a6,a6,82 # 80023000 <disk>
    80005fb6:	00151693          	slli	a3,a0,0x1
    80005fba:	00a68733          	add	a4,a3,a0
    80005fbe:	0732                	slli	a4,a4,0xc
    80005fc0:	00e807b3          	add	a5,a6,a4
    80005fc4:	6709                	lui	a4,0x2
    80005fc6:	00f70633          	add	a2,a4,a5
    80005fca:	6210                	ld	a2,0(a2)
    80005fcc:	00459893          	slli	a7,a1,0x4
    80005fd0:	9646                	add	a2,a2,a7
    80005fd2:	00063023          	sd	zero,0(a2) # 1000 <_entry-0x7ffff000>
  disk[n].free[i] = 1;
    80005fd6:	97ae                	add	a5,a5,a1
    80005fd8:	97ba                	add	a5,a5,a4
    80005fda:	4605                	li	a2,1
    80005fdc:	00c78c23          	sb	a2,24(a5)
  wakeup(&disk[n].free[0]);
    80005fe0:	96aa                	add	a3,a3,a0
    80005fe2:	06b2                	slli	a3,a3,0xc
    80005fe4:	0761                	addi	a4,a4,24
    80005fe6:	96ba                	add	a3,a3,a4
    80005fe8:	00d80533          	add	a0,a6,a3
    80005fec:	ffffc097          	auipc	ra,0xffffc
    80005ff0:	3e8080e7          	jalr	1000(ra) # 800023d4 <wakeup>
}
    80005ff4:	60a2                	ld	ra,8(sp)
    80005ff6:	6402                	ld	s0,0(sp)
    80005ff8:	0141                	addi	sp,sp,16
    80005ffa:	8082                	ret
    panic("virtio_disk_intr 1");
    80005ffc:	00004517          	auipc	a0,0x4
    80006000:	b0c50513          	addi	a0,a0,-1268 # 80009b08 <userret+0xa78>
    80006004:	ffffa097          	auipc	ra,0xffffa
    80006008:	550080e7          	jalr	1360(ra) # 80000554 <panic>
    panic("virtio_disk_intr 2");
    8000600c:	00004517          	auipc	a0,0x4
    80006010:	b1450513          	addi	a0,a0,-1260 # 80009b20 <userret+0xa90>
    80006014:	ffffa097          	auipc	ra,0xffffa
    80006018:	540080e7          	jalr	1344(ra) # 80000554 <panic>

000000008000601c <virtio_disk_init>:
  __sync_synchronize();
    8000601c:	0ff0000f          	fence
  if(disk[n].init)
    80006020:	00151793          	slli	a5,a0,0x1
    80006024:	97aa                	add	a5,a5,a0
    80006026:	07b2                	slli	a5,a5,0xc
    80006028:	0001d717          	auipc	a4,0x1d
    8000602c:	fd870713          	addi	a4,a4,-40 # 80023000 <disk>
    80006030:	973e                	add	a4,a4,a5
    80006032:	6789                	lui	a5,0x2
    80006034:	97ba                	add	a5,a5,a4
    80006036:	0a87a783          	lw	a5,168(a5) # 20a8 <_entry-0x7fffdf58>
    8000603a:	c391                	beqz	a5,8000603e <virtio_disk_init+0x22>
    8000603c:	8082                	ret
{
    8000603e:	7139                	addi	sp,sp,-64
    80006040:	fc06                	sd	ra,56(sp)
    80006042:	f822                	sd	s0,48(sp)
    80006044:	f426                	sd	s1,40(sp)
    80006046:	f04a                	sd	s2,32(sp)
    80006048:	ec4e                	sd	s3,24(sp)
    8000604a:	e852                	sd	s4,16(sp)
    8000604c:	e456                	sd	s5,8(sp)
    8000604e:	0080                	addi	s0,sp,64
    80006050:	84aa                	mv	s1,a0
  printf("virtio disk init %d\n", n);
    80006052:	85aa                	mv	a1,a0
    80006054:	00004517          	auipc	a0,0x4
    80006058:	ae450513          	addi	a0,a0,-1308 # 80009b38 <userret+0xaa8>
    8000605c:	ffffa097          	auipc	ra,0xffffa
    80006060:	552080e7          	jalr	1362(ra) # 800005ae <printf>
  initlock(&disk[n].vdisk_lock, "virtio_disk");
    80006064:	00149993          	slli	s3,s1,0x1
    80006068:	99a6                	add	s3,s3,s1
    8000606a:	09b2                	slli	s3,s3,0xc
    8000606c:	6789                	lui	a5,0x2
    8000606e:	0b078793          	addi	a5,a5,176 # 20b0 <_entry-0x7fffdf50>
    80006072:	97ce                	add	a5,a5,s3
    80006074:	00004597          	auipc	a1,0x4
    80006078:	adc58593          	addi	a1,a1,-1316 # 80009b50 <userret+0xac0>
    8000607c:	0001d517          	auipc	a0,0x1d
    80006080:	f8450513          	addi	a0,a0,-124 # 80023000 <disk>
    80006084:	953e                	add	a0,a0,a5
    80006086:	ffffb097          	auipc	ra,0xffffb
    8000608a:	946080e7          	jalr	-1722(ra) # 800009cc <initlock>
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000608e:	0014891b          	addiw	s2,s1,1
    80006092:	00c9191b          	slliw	s2,s2,0xc
    80006096:	100007b7          	lui	a5,0x10000
    8000609a:	97ca                	add	a5,a5,s2
    8000609c:	4398                	lw	a4,0(a5)
    8000609e:	2701                	sext.w	a4,a4
    800060a0:	747277b7          	lui	a5,0x74727
    800060a4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800060a8:	12f71663          	bne	a4,a5,800061d4 <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    800060ac:	100007b7          	lui	a5,0x10000
    800060b0:	0791                	addi	a5,a5,4
    800060b2:	97ca                	add	a5,a5,s2
    800060b4:	439c                	lw	a5,0(a5)
    800060b6:	2781                	sext.w	a5,a5
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800060b8:	4705                	li	a4,1
    800060ba:	10e79d63          	bne	a5,a4,800061d4 <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060be:	100007b7          	lui	a5,0x10000
    800060c2:	07a1                	addi	a5,a5,8
    800060c4:	97ca                	add	a5,a5,s2
    800060c6:	439c                	lw	a5,0(a5)
    800060c8:	2781                	sext.w	a5,a5
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    800060ca:	4709                	li	a4,2
    800060cc:	10e79463          	bne	a5,a4,800061d4 <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800060d0:	100007b7          	lui	a5,0x10000
    800060d4:	07b1                	addi	a5,a5,12
    800060d6:	97ca                	add	a5,a5,s2
    800060d8:	4398                	lw	a4,0(a5)
    800060da:	2701                	sext.w	a4,a4
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060dc:	554d47b7          	lui	a5,0x554d4
    800060e0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800060e4:	0ef71863          	bne	a4,a5,800061d4 <virtio_disk_init+0x1b8>
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800060e8:	100007b7          	lui	a5,0x10000
    800060ec:	07078693          	addi	a3,a5,112 # 10000070 <_entry-0x6fffff90>
    800060f0:	96ca                	add	a3,a3,s2
    800060f2:	4705                	li	a4,1
    800060f4:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800060f6:	470d                	li	a4,3
    800060f8:	c298                	sw	a4,0(a3)
  uint64 features = *R(n, VIRTIO_MMIO_DEVICE_FEATURES);
    800060fa:	01078713          	addi	a4,a5,16
    800060fe:	974a                	add	a4,a4,s2
    80006100:	430c                	lw	a1,0(a4)
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006102:	02078613          	addi	a2,a5,32
    80006106:	964a                	add	a2,a2,s2
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006108:	c7ffe737          	lui	a4,0xc7ffe
    8000610c:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd53b3>
    80006110:	8f6d                	and	a4,a4,a1
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006112:	2701                	sext.w	a4,a4
    80006114:	c218                	sw	a4,0(a2)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80006116:	472d                	li	a4,11
    80006118:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    8000611a:	473d                	li	a4,15
    8000611c:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    8000611e:	02878713          	addi	a4,a5,40
    80006122:	974a                	add	a4,a4,s2
    80006124:	6685                	lui	a3,0x1
    80006126:	c314                	sw	a3,0(a4)
  *R(n, VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006128:	03078713          	addi	a4,a5,48
    8000612c:	974a                	add	a4,a4,s2
    8000612e:	00072023          	sw	zero,0(a4)
  uint32 max = *R(n, VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006132:	03478793          	addi	a5,a5,52
    80006136:	97ca                	add	a5,a5,s2
    80006138:	439c                	lw	a5,0(a5)
    8000613a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000613c:	c7c5                	beqz	a5,800061e4 <virtio_disk_init+0x1c8>
  if(max < NUM)
    8000613e:	471d                	li	a4,7
    80006140:	0af77a63          	bgeu	a4,a5,800061f4 <virtio_disk_init+0x1d8>
  *R(n, VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006144:	10000ab7          	lui	s5,0x10000
    80006148:	038a8793          	addi	a5,s5,56 # 10000038 <_entry-0x6fffffc8>
    8000614c:	97ca                	add	a5,a5,s2
    8000614e:	4721                	li	a4,8
    80006150:	c398                	sw	a4,0(a5)
  memset(disk[n].pages, 0, sizeof(disk[n].pages));
    80006152:	0001da17          	auipc	s4,0x1d
    80006156:	eaea0a13          	addi	s4,s4,-338 # 80023000 <disk>
    8000615a:	99d2                	add	s3,s3,s4
    8000615c:	6609                	lui	a2,0x2
    8000615e:	4581                	li	a1,0
    80006160:	854e                	mv	a0,s3
    80006162:	ffffb097          	auipc	ra,0xffffb
    80006166:	c0c080e7          	jalr	-1012(ra) # 80000d6e <memset>
  *R(n, VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk[n].pages) >> PGSHIFT;
    8000616a:	040a8a93          	addi	s5,s5,64
    8000616e:	9956                	add	s2,s2,s5
    80006170:	00c9d793          	srli	a5,s3,0xc
    80006174:	2781                	sext.w	a5,a5
    80006176:	00f92023          	sw	a5,0(s2)
  disk[n].desc = (struct VRingDesc *) disk[n].pages;
    8000617a:	00149693          	slli	a3,s1,0x1
    8000617e:	009687b3          	add	a5,a3,s1
    80006182:	07b2                	slli	a5,a5,0xc
    80006184:	97d2                	add	a5,a5,s4
    80006186:	6609                	lui	a2,0x2
    80006188:	97b2                	add	a5,a5,a2
    8000618a:	0137b023          	sd	s3,0(a5)
  disk[n].avail = (uint16*)(((char*)disk[n].desc) + NUM*sizeof(struct VRingDesc));
    8000618e:	08098713          	addi	a4,s3,128
    80006192:	e798                	sd	a4,8(a5)
  disk[n].used = (struct UsedArea *) (disk[n].pages + PGSIZE);
    80006194:	6705                	lui	a4,0x1
    80006196:	99ba                	add	s3,s3,a4
    80006198:	0137b823          	sd	s3,16(a5)
    disk[n].free[i] = 1;
    8000619c:	4705                	li	a4,1
    8000619e:	00e78c23          	sb	a4,24(a5)
    800061a2:	00e78ca3          	sb	a4,25(a5)
    800061a6:	00e78d23          	sb	a4,26(a5)
    800061aa:	00e78da3          	sb	a4,27(a5)
    800061ae:	00e78e23          	sb	a4,28(a5)
    800061b2:	00e78ea3          	sb	a4,29(a5)
    800061b6:	00e78f23          	sb	a4,30(a5)
    800061ba:	00e78fa3          	sb	a4,31(a5)
  disk[n].init = 1;
    800061be:	0ae7a423          	sw	a4,168(a5)
}
    800061c2:	70e2                	ld	ra,56(sp)
    800061c4:	7442                	ld	s0,48(sp)
    800061c6:	74a2                	ld	s1,40(sp)
    800061c8:	7902                	ld	s2,32(sp)
    800061ca:	69e2                	ld	s3,24(sp)
    800061cc:	6a42                	ld	s4,16(sp)
    800061ce:	6aa2                	ld	s5,8(sp)
    800061d0:	6121                	addi	sp,sp,64
    800061d2:	8082                	ret
    panic("could not find virtio disk");
    800061d4:	00004517          	auipc	a0,0x4
    800061d8:	98c50513          	addi	a0,a0,-1652 # 80009b60 <userret+0xad0>
    800061dc:	ffffa097          	auipc	ra,0xffffa
    800061e0:	378080e7          	jalr	888(ra) # 80000554 <panic>
    panic("virtio disk has no queue 0");
    800061e4:	00004517          	auipc	a0,0x4
    800061e8:	99c50513          	addi	a0,a0,-1636 # 80009b80 <userret+0xaf0>
    800061ec:	ffffa097          	auipc	ra,0xffffa
    800061f0:	368080e7          	jalr	872(ra) # 80000554 <panic>
    panic("virtio disk max queue too short");
    800061f4:	00004517          	auipc	a0,0x4
    800061f8:	9ac50513          	addi	a0,a0,-1620 # 80009ba0 <userret+0xb10>
    800061fc:	ffffa097          	auipc	ra,0xffffa
    80006200:	358080e7          	jalr	856(ra) # 80000554 <panic>

0000000080006204 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(int n, struct buf *b, int write)
{
    80006204:	7135                	addi	sp,sp,-160
    80006206:	ed06                	sd	ra,152(sp)
    80006208:	e922                	sd	s0,144(sp)
    8000620a:	e526                	sd	s1,136(sp)
    8000620c:	e14a                	sd	s2,128(sp)
    8000620e:	fcce                	sd	s3,120(sp)
    80006210:	f8d2                	sd	s4,112(sp)
    80006212:	f4d6                	sd	s5,104(sp)
    80006214:	f0da                	sd	s6,96(sp)
    80006216:	ecde                	sd	s7,88(sp)
    80006218:	e8e2                	sd	s8,80(sp)
    8000621a:	e4e6                	sd	s9,72(sp)
    8000621c:	e0ea                	sd	s10,64(sp)
    8000621e:	fc6e                	sd	s11,56(sp)
    80006220:	1100                	addi	s0,sp,160
    80006222:	8aaa                	mv	s5,a0
    80006224:	8c2e                	mv	s8,a1
    80006226:	8db2                	mv	s11,a2
  uint64 sector = b->blockno * (BSIZE / 512);
    80006228:	45dc                	lw	a5,12(a1)
    8000622a:	0017979b          	slliw	a5,a5,0x1
    8000622e:	1782                	slli	a5,a5,0x20
    80006230:	9381                	srli	a5,a5,0x20
    80006232:	f6f43423          	sd	a5,-152(s0)

  acquire(&disk[n].vdisk_lock);
    80006236:	00151493          	slli	s1,a0,0x1
    8000623a:	94aa                	add	s1,s1,a0
    8000623c:	04b2                	slli	s1,s1,0xc
    8000623e:	6909                	lui	s2,0x2
    80006240:	0b090c93          	addi	s9,s2,176 # 20b0 <_entry-0x7fffdf50>
    80006244:	9ca6                	add	s9,s9,s1
    80006246:	0001d997          	auipc	s3,0x1d
    8000624a:	dba98993          	addi	s3,s3,-582 # 80023000 <disk>
    8000624e:	9cce                	add	s9,s9,s3
    80006250:	8566                	mv	a0,s9
    80006252:	ffffb097          	auipc	ra,0xffffb
    80006256:	84e080e7          	jalr	-1970(ra) # 80000aa0 <acquire>
  int idx[3];
  while(1){
    if(alloc3_desc(n, idx) == 0) {
      break;
    }
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    8000625a:	0961                	addi	s2,s2,24
    8000625c:	94ca                	add	s1,s1,s2
    8000625e:	99a6                	add	s3,s3,s1
  for(int i = 0; i < 3; i++){
    80006260:	4a01                	li	s4,0
  for(int i = 0; i < NUM; i++){
    80006262:	44a1                	li	s1,8
      disk[n].free[i] = 0;
    80006264:	001a9793          	slli	a5,s5,0x1
    80006268:	97d6                	add	a5,a5,s5
    8000626a:	07b2                	slli	a5,a5,0xc
    8000626c:	0001db97          	auipc	s7,0x1d
    80006270:	d94b8b93          	addi	s7,s7,-620 # 80023000 <disk>
    80006274:	9bbe                	add	s7,s7,a5
    80006276:	a8a9                	j	800062d0 <virtio_disk_rw+0xcc>
    80006278:	00fb8733          	add	a4,s7,a5
    8000627c:	9742                	add	a4,a4,a6
    8000627e:	00070c23          	sb	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    idx[i] = alloc_desc(n);
    80006282:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006284:	0207c263          	bltz	a5,800062a8 <virtio_disk_rw+0xa4>
  for(int i = 0; i < 3; i++){
    80006288:	2905                	addiw	s2,s2,1
    8000628a:	0611                	addi	a2,a2,4
    8000628c:	1ca90463          	beq	s2,a0,80006454 <virtio_disk_rw+0x250>
    idx[i] = alloc_desc(n);
    80006290:	85b2                	mv	a1,a2
    80006292:	874e                	mv	a4,s3
  for(int i = 0; i < NUM; i++){
    80006294:	87d2                	mv	a5,s4
    if(disk[n].free[i]){
    80006296:	00074683          	lbu	a3,0(a4)
    8000629a:	fef9                	bnez	a3,80006278 <virtio_disk_rw+0x74>
  for(int i = 0; i < NUM; i++){
    8000629c:	2785                	addiw	a5,a5,1
    8000629e:	0705                	addi	a4,a4,1
    800062a0:	fe979be3          	bne	a5,s1,80006296 <virtio_disk_rw+0x92>
    idx[i] = alloc_desc(n);
    800062a4:	57fd                	li	a5,-1
    800062a6:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800062a8:	01205e63          	blez	s2,800062c4 <virtio_disk_rw+0xc0>
    800062ac:	8d52                	mv	s10,s4
        free_desc(n, idx[j]);
    800062ae:	000b2583          	lw	a1,0(s6)
    800062b2:	8556                	mv	a0,s5
    800062b4:	00000097          	auipc	ra,0x0
    800062b8:	ccc080e7          	jalr	-820(ra) # 80005f80 <free_desc>
      for(int j = 0; j < i; j++)
    800062bc:	2d05                	addiw	s10,s10,1
    800062be:	0b11                	addi	s6,s6,4
    800062c0:	ffa917e3          	bne	s2,s10,800062ae <virtio_disk_rw+0xaa>
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    800062c4:	85e6                	mv	a1,s9
    800062c6:	854e                	mv	a0,s3
    800062c8:	ffffc097          	auipc	ra,0xffffc
    800062cc:	f8c080e7          	jalr	-116(ra) # 80002254 <sleep>
  for(int i = 0; i < 3; i++){
    800062d0:	f8040b13          	addi	s6,s0,-128
{
    800062d4:	865a                	mv	a2,s6
  for(int i = 0; i < 3; i++){
    800062d6:	8952                	mv	s2,s4
      disk[n].free[i] = 0;
    800062d8:	6809                	lui	a6,0x2
  for(int i = 0; i < 3; i++){
    800062da:	450d                	li	a0,3
    800062dc:	bf55                	j	80006290 <virtio_disk_rw+0x8c>
  disk[n].desc[idx[0]].next = idx[1];

  disk[n].desc[idx[1]].addr = (uint64) b->data;
  disk[n].desc[idx[1]].len = BSIZE;
  if(write)
    disk[n].desc[idx[1]].flags = 0; // device reads b->data
    800062de:	001a9793          	slli	a5,s5,0x1
    800062e2:	97d6                	add	a5,a5,s5
    800062e4:	07b2                	slli	a5,a5,0xc
    800062e6:	0001d717          	auipc	a4,0x1d
    800062ea:	d1a70713          	addi	a4,a4,-742 # 80023000 <disk>
    800062ee:	973e                	add	a4,a4,a5
    800062f0:	6789                	lui	a5,0x2
    800062f2:	97ba                	add	a5,a5,a4
    800062f4:	639c                	ld	a5,0(a5)
    800062f6:	97b6                	add	a5,a5,a3
    800062f8:	00079623          	sh	zero,12(a5) # 200c <_entry-0x7fffdff4>
  else
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk[n].desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800062fc:	0001d517          	auipc	a0,0x1d
    80006300:	d0450513          	addi	a0,a0,-764 # 80023000 <disk>
    80006304:	001a9793          	slli	a5,s5,0x1
    80006308:	01578733          	add	a4,a5,s5
    8000630c:	0732                	slli	a4,a4,0xc
    8000630e:	972a                	add	a4,a4,a0
    80006310:	6609                	lui	a2,0x2
    80006312:	9732                	add	a4,a4,a2
    80006314:	6310                	ld	a2,0(a4)
    80006316:	9636                	add	a2,a2,a3
    80006318:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    8000631c:	0015e593          	ori	a1,a1,1
    80006320:	00b61623          	sh	a1,12(a2)
  disk[n].desc[idx[1]].next = idx[2];
    80006324:	f8842603          	lw	a2,-120(s0)
    80006328:	630c                	ld	a1,0(a4)
    8000632a:	96ae                	add	a3,a3,a1
    8000632c:	00c69723          	sh	a2,14(a3) # 100e <_entry-0x7fffeff2>

  disk[n].info[idx[0]].status = 0;
    80006330:	97d6                	add	a5,a5,s5
    80006332:	07a2                	slli	a5,a5,0x8
    80006334:	97a6                	add	a5,a5,s1
    80006336:	20078793          	addi	a5,a5,512
    8000633a:	0792                	slli	a5,a5,0x4
    8000633c:	97aa                	add	a5,a5,a0
    8000633e:	02078823          	sb	zero,48(a5)
  disk[n].desc[idx[2]].addr = (uint64) &disk[n].info[idx[0]].status;
    80006342:	00461693          	slli	a3,a2,0x4
    80006346:	00073803          	ld	a6,0(a4)
    8000634a:	9836                	add	a6,a6,a3
    8000634c:	20348613          	addi	a2,s1,515
    80006350:	001a9593          	slli	a1,s5,0x1
    80006354:	95d6                	add	a1,a1,s5
    80006356:	05a2                	slli	a1,a1,0x8
    80006358:	962e                	add	a2,a2,a1
    8000635a:	0612                	slli	a2,a2,0x4
    8000635c:	962a                	add	a2,a2,a0
    8000635e:	00c83023          	sd	a2,0(a6) # 2000 <_entry-0x7fffe000>
  disk[n].desc[idx[2]].len = 1;
    80006362:	630c                	ld	a1,0(a4)
    80006364:	95b6                	add	a1,a1,a3
    80006366:	4605                	li	a2,1
    80006368:	c590                	sw	a2,8(a1)
  disk[n].desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000636a:	630c                	ld	a1,0(a4)
    8000636c:	95b6                	add	a1,a1,a3
    8000636e:	4509                	li	a0,2
    80006370:	00a59623          	sh	a0,12(a1)
  disk[n].desc[idx[2]].next = 0;
    80006374:	630c                	ld	a1,0(a4)
    80006376:	96ae                	add	a3,a3,a1
    80006378:	00069723          	sh	zero,14(a3)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000637c:	00cc2223          	sw	a2,4(s8) # fffffffffffff004 <end+0xffffffff7ffd5c58>
  disk[n].info[idx[0]].b = b;
    80006380:	0387b423          	sd	s8,40(a5)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk[n].avail[2 + (disk[n].avail[1] % NUM)] = idx[0];
    80006384:	6714                	ld	a3,8(a4)
    80006386:	0026d783          	lhu	a5,2(a3)
    8000638a:	8b9d                	andi	a5,a5,7
    8000638c:	0789                	addi	a5,a5,2
    8000638e:	0786                	slli	a5,a5,0x1
    80006390:	97b6                	add	a5,a5,a3
    80006392:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    80006396:	0ff0000f          	fence
  disk[n].avail[1] = disk[n].avail[1] + 1;
    8000639a:	6718                	ld	a4,8(a4)
    8000639c:	00275783          	lhu	a5,2(a4)
    800063a0:	2785                	addiw	a5,a5,1
    800063a2:	00f71123          	sh	a5,2(a4)

  *R(n, VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800063a6:	001a879b          	addiw	a5,s5,1
    800063aa:	00c7979b          	slliw	a5,a5,0xc
    800063ae:	10000737          	lui	a4,0x10000
    800063b2:	05070713          	addi	a4,a4,80 # 10000050 <_entry-0x6fffffb0>
    800063b6:	97ba                	add	a5,a5,a4
    800063b8:	0007a023          	sw	zero,0(a5)

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800063bc:	004c2783          	lw	a5,4(s8)
    800063c0:	00c79d63          	bne	a5,a2,800063da <virtio_disk_rw+0x1d6>
    800063c4:	4485                	li	s1,1
    sleep(b, &disk[n].vdisk_lock);
    800063c6:	85e6                	mv	a1,s9
    800063c8:	8562                	mv	a0,s8
    800063ca:	ffffc097          	auipc	ra,0xffffc
    800063ce:	e8a080e7          	jalr	-374(ra) # 80002254 <sleep>
  while(b->disk == 1) {
    800063d2:	004c2783          	lw	a5,4(s8)
    800063d6:	fe9788e3          	beq	a5,s1,800063c6 <virtio_disk_rw+0x1c2>
  }

  disk[n].info[idx[0]].b = 0;
    800063da:	f8042483          	lw	s1,-128(s0)
    800063de:	001a9793          	slli	a5,s5,0x1
    800063e2:	97d6                	add	a5,a5,s5
    800063e4:	07a2                	slli	a5,a5,0x8
    800063e6:	97a6                	add	a5,a5,s1
    800063e8:	20078793          	addi	a5,a5,512
    800063ec:	0792                	slli	a5,a5,0x4
    800063ee:	0001d717          	auipc	a4,0x1d
    800063f2:	c1270713          	addi	a4,a4,-1006 # 80023000 <disk>
    800063f6:	97ba                	add	a5,a5,a4
    800063f8:	0207b423          	sd	zero,40(a5)
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    800063fc:	001a9793          	slli	a5,s5,0x1
    80006400:	97d6                	add	a5,a5,s5
    80006402:	07b2                	slli	a5,a5,0xc
    80006404:	97ba                	add	a5,a5,a4
    80006406:	6909                	lui	s2,0x2
    80006408:	993e                	add	s2,s2,a5
    8000640a:	a019                	j	80006410 <virtio_disk_rw+0x20c>
      i = disk[n].desc[i].next;
    8000640c:	00e4d483          	lhu	s1,14(s1)
    free_desc(n, i);
    80006410:	85a6                	mv	a1,s1
    80006412:	8556                	mv	a0,s5
    80006414:	00000097          	auipc	ra,0x0
    80006418:	b6c080e7          	jalr	-1172(ra) # 80005f80 <free_desc>
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    8000641c:	0492                	slli	s1,s1,0x4
    8000641e:	00093783          	ld	a5,0(s2) # 2000 <_entry-0x7fffe000>
    80006422:	94be                	add	s1,s1,a5
    80006424:	00c4d783          	lhu	a5,12(s1)
    80006428:	8b85                	andi	a5,a5,1
    8000642a:	f3ed                	bnez	a5,8000640c <virtio_disk_rw+0x208>
  free_chain(n, idx[0]);

  release(&disk[n].vdisk_lock);
    8000642c:	8566                	mv	a0,s9
    8000642e:	ffffa097          	auipc	ra,0xffffa
    80006432:	742080e7          	jalr	1858(ra) # 80000b70 <release>
}
    80006436:	60ea                	ld	ra,152(sp)
    80006438:	644a                	ld	s0,144(sp)
    8000643a:	64aa                	ld	s1,136(sp)
    8000643c:	690a                	ld	s2,128(sp)
    8000643e:	79e6                	ld	s3,120(sp)
    80006440:	7a46                	ld	s4,112(sp)
    80006442:	7aa6                	ld	s5,104(sp)
    80006444:	7b06                	ld	s6,96(sp)
    80006446:	6be6                	ld	s7,88(sp)
    80006448:	6c46                	ld	s8,80(sp)
    8000644a:	6ca6                	ld	s9,72(sp)
    8000644c:	6d06                	ld	s10,64(sp)
    8000644e:	7de2                	ld	s11,56(sp)
    80006450:	610d                	addi	sp,sp,160
    80006452:	8082                	ret
  if(write)
    80006454:	01b037b3          	snez	a5,s11
    80006458:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    8000645c:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    80006460:	f6843783          	ld	a5,-152(s0)
    80006464:	f6f43c23          	sd	a5,-136(s0)
  disk[n].desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    80006468:	f8042483          	lw	s1,-128(s0)
    8000646c:	00449993          	slli	s3,s1,0x4
    80006470:	001a9793          	slli	a5,s5,0x1
    80006474:	97d6                	add	a5,a5,s5
    80006476:	07b2                	slli	a5,a5,0xc
    80006478:	0001d917          	auipc	s2,0x1d
    8000647c:	b8890913          	addi	s2,s2,-1144 # 80023000 <disk>
    80006480:	97ca                	add	a5,a5,s2
    80006482:	6909                	lui	s2,0x2
    80006484:	993e                	add	s2,s2,a5
    80006486:	00093a03          	ld	s4,0(s2) # 2000 <_entry-0x7fffe000>
    8000648a:	9a4e                	add	s4,s4,s3
    8000648c:	f7040513          	addi	a0,s0,-144
    80006490:	ffffb097          	auipc	ra,0xffffb
    80006494:	d2a080e7          	jalr	-726(ra) # 800011ba <kvmpa>
    80006498:	00aa3023          	sd	a0,0(s4)
  disk[n].desc[idx[0]].len = sizeof(buf0);
    8000649c:	00093783          	ld	a5,0(s2)
    800064a0:	97ce                	add	a5,a5,s3
    800064a2:	4741                	li	a4,16
    800064a4:	c798                	sw	a4,8(a5)
  disk[n].desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800064a6:	00093783          	ld	a5,0(s2)
    800064aa:	97ce                	add	a5,a5,s3
    800064ac:	4705                	li	a4,1
    800064ae:	00e79623          	sh	a4,12(a5)
  disk[n].desc[idx[0]].next = idx[1];
    800064b2:	f8442683          	lw	a3,-124(s0)
    800064b6:	00093783          	ld	a5,0(s2)
    800064ba:	99be                	add	s3,s3,a5
    800064bc:	00d99723          	sh	a3,14(s3)
  disk[n].desc[idx[1]].addr = (uint64) b->data;
    800064c0:	0692                	slli	a3,a3,0x4
    800064c2:	00093783          	ld	a5,0(s2)
    800064c6:	97b6                	add	a5,a5,a3
    800064c8:	060c0713          	addi	a4,s8,96
    800064cc:	e398                	sd	a4,0(a5)
  disk[n].desc[idx[1]].len = BSIZE;
    800064ce:	00093783          	ld	a5,0(s2)
    800064d2:	97b6                	add	a5,a5,a3
    800064d4:	40000713          	li	a4,1024
    800064d8:	c798                	sw	a4,8(a5)
  if(write)
    800064da:	e00d92e3          	bnez	s11,800062de <virtio_disk_rw+0xda>
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800064de:	001a9793          	slli	a5,s5,0x1
    800064e2:	97d6                	add	a5,a5,s5
    800064e4:	07b2                	slli	a5,a5,0xc
    800064e6:	0001d717          	auipc	a4,0x1d
    800064ea:	b1a70713          	addi	a4,a4,-1254 # 80023000 <disk>
    800064ee:	973e                	add	a4,a4,a5
    800064f0:	6789                	lui	a5,0x2
    800064f2:	97ba                	add	a5,a5,a4
    800064f4:	639c                	ld	a5,0(a5)
    800064f6:	97b6                	add	a5,a5,a3
    800064f8:	4709                	li	a4,2
    800064fa:	00e79623          	sh	a4,12(a5) # 200c <_entry-0x7fffdff4>
    800064fe:	bbfd                	j	800062fc <virtio_disk_rw+0xf8>

0000000080006500 <virtio_disk_intr>:

void
virtio_disk_intr(int n)
{
    80006500:	7139                	addi	sp,sp,-64
    80006502:	fc06                	sd	ra,56(sp)
    80006504:	f822                	sd	s0,48(sp)
    80006506:	f426                	sd	s1,40(sp)
    80006508:	f04a                	sd	s2,32(sp)
    8000650a:	ec4e                	sd	s3,24(sp)
    8000650c:	e852                	sd	s4,16(sp)
    8000650e:	e456                	sd	s5,8(sp)
    80006510:	0080                	addi	s0,sp,64
    80006512:	84aa                	mv	s1,a0
  acquire(&disk[n].vdisk_lock);
    80006514:	00151913          	slli	s2,a0,0x1
    80006518:	00a90a33          	add	s4,s2,a0
    8000651c:	0a32                	slli	s4,s4,0xc
    8000651e:	6989                	lui	s3,0x2
    80006520:	0b098793          	addi	a5,s3,176 # 20b0 <_entry-0x7fffdf50>
    80006524:	9a3e                	add	s4,s4,a5
    80006526:	0001da97          	auipc	s5,0x1d
    8000652a:	adaa8a93          	addi	s5,s5,-1318 # 80023000 <disk>
    8000652e:	9a56                	add	s4,s4,s5
    80006530:	8552                	mv	a0,s4
    80006532:	ffffa097          	auipc	ra,0xffffa
    80006536:	56e080e7          	jalr	1390(ra) # 80000aa0 <acquire>

  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    8000653a:	9926                	add	s2,s2,s1
    8000653c:	0932                	slli	s2,s2,0xc
    8000653e:	9956                	add	s2,s2,s5
    80006540:	99ca                	add	s3,s3,s2
    80006542:	0209d783          	lhu	a5,32(s3)
    80006546:	0109b703          	ld	a4,16(s3)
    8000654a:	00275683          	lhu	a3,2(a4)
    8000654e:	8ebd                	xor	a3,a3,a5
    80006550:	8a9d                	andi	a3,a3,7
    80006552:	c2a5                	beqz	a3,800065b2 <virtio_disk_intr+0xb2>
    int id = disk[n].used->elems[disk[n].used_idx].id;

    if(disk[n].info[id].status != 0)
    80006554:	8956                	mv	s2,s5
    80006556:	00149693          	slli	a3,s1,0x1
    8000655a:	96a6                	add	a3,a3,s1
    8000655c:	00869993          	slli	s3,a3,0x8
      panic("virtio_disk_intr status");
    
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk[n].info[id].b);

    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006560:	06b2                	slli	a3,a3,0xc
    80006562:	96d6                	add	a3,a3,s5
    80006564:	6489                	lui	s1,0x2
    80006566:	94b6                	add	s1,s1,a3
    int id = disk[n].used->elems[disk[n].used_idx].id;
    80006568:	078e                	slli	a5,a5,0x3
    8000656a:	97ba                	add	a5,a5,a4
    8000656c:	43dc                	lw	a5,4(a5)
    if(disk[n].info[id].status != 0)
    8000656e:	00f98733          	add	a4,s3,a5
    80006572:	20070713          	addi	a4,a4,512
    80006576:	0712                	slli	a4,a4,0x4
    80006578:	974a                	add	a4,a4,s2
    8000657a:	03074703          	lbu	a4,48(a4)
    8000657e:	eb21                	bnez	a4,800065ce <virtio_disk_intr+0xce>
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    80006580:	97ce                	add	a5,a5,s3
    80006582:	20078793          	addi	a5,a5,512
    80006586:	0792                	slli	a5,a5,0x4
    80006588:	97ca                	add	a5,a5,s2
    8000658a:	7798                	ld	a4,40(a5)
    8000658c:	00072223          	sw	zero,4(a4)
    wakeup(disk[n].info[id].b);
    80006590:	7788                	ld	a0,40(a5)
    80006592:	ffffc097          	auipc	ra,0xffffc
    80006596:	e42080e7          	jalr	-446(ra) # 800023d4 <wakeup>
    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    8000659a:	0204d783          	lhu	a5,32(s1) # 2020 <_entry-0x7fffdfe0>
    8000659e:	2785                	addiw	a5,a5,1
    800065a0:	8b9d                	andi	a5,a5,7
    800065a2:	02f49023          	sh	a5,32(s1)
  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    800065a6:	6898                	ld	a4,16(s1)
    800065a8:	00275683          	lhu	a3,2(a4)
    800065ac:	8a9d                	andi	a3,a3,7
    800065ae:	faf69de3          	bne	a3,a5,80006568 <virtio_disk_intr+0x68>
  }

  release(&disk[n].vdisk_lock);
    800065b2:	8552                	mv	a0,s4
    800065b4:	ffffa097          	auipc	ra,0xffffa
    800065b8:	5bc080e7          	jalr	1468(ra) # 80000b70 <release>
}
    800065bc:	70e2                	ld	ra,56(sp)
    800065be:	7442                	ld	s0,48(sp)
    800065c0:	74a2                	ld	s1,40(sp)
    800065c2:	7902                	ld	s2,32(sp)
    800065c4:	69e2                	ld	s3,24(sp)
    800065c6:	6a42                	ld	s4,16(sp)
    800065c8:	6aa2                	ld	s5,8(sp)
    800065ca:	6121                	addi	sp,sp,64
    800065cc:	8082                	ret
      panic("virtio_disk_intr status");
    800065ce:	00003517          	auipc	a0,0x3
    800065d2:	5f250513          	addi	a0,a0,1522 # 80009bc0 <userret+0xb30>
    800065d6:	ffffa097          	auipc	ra,0xffffa
    800065da:	f7e080e7          	jalr	-130(ra) # 80000554 <panic>

00000000800065de <e1000_init>:
// called by pci_init().
// xregs is the memory address at which the
// e1000's registers are mapped.
void
e1000_init(uint32 *xregs)
{
    800065de:	7179                	addi	sp,sp,-48
    800065e0:	f406                	sd	ra,40(sp)
    800065e2:	f022                	sd	s0,32(sp)
    800065e4:	ec26                	sd	s1,24(sp)
    800065e6:	e84a                	sd	s2,16(sp)
    800065e8:	e44e                	sd	s3,8(sp)
    800065ea:	1800                	addi	s0,sp,48
    800065ec:	84aa                	mv	s1,a0
  int i;

  initlock(&e1000_lock, "e1000");
    800065ee:	00003597          	auipc	a1,0x3
    800065f2:	5ea58593          	addi	a1,a1,1514 # 80009bd8 <userret+0xb48>
    800065f6:	00023517          	auipc	a0,0x23
    800065fa:	a0a50513          	addi	a0,a0,-1526 # 80029000 <e1000_lock>
    800065fe:	ffffa097          	auipc	ra,0xffffa
    80006602:	3ce080e7          	jalr	974(ra) # 800009cc <initlock>

  regs = xregs;
    80006606:	00023797          	auipc	a5,0x23
    8000660a:	d897b123          	sd	s1,-638(a5) # 80029388 <regs>

  // Reset the device
  regs[E1000_IMS] = 0; // disable interrupts
    8000660e:	0c04a823          	sw	zero,208(s1)
  regs[E1000_CTL] |= E1000_CTL_RST;
    80006612:	409c                	lw	a5,0(s1)
    80006614:	00400737          	lui	a4,0x400
    80006618:	8fd9                	or	a5,a5,a4
    8000661a:	2781                	sext.w	a5,a5
    8000661c:	c09c                	sw	a5,0(s1)
  regs[E1000_IMS] = 0; // redisable interrupts
    8000661e:	0c04a823          	sw	zero,208(s1)
  __sync_synchronize();
    80006622:	0ff0000f          	fence

  // [E1000 14.5] Transmit initialization
  memset(tx_ring, 0, sizeof(tx_ring));
    80006626:	10000613          	li	a2,256
    8000662a:	4581                	li	a1,0
    8000662c:	00023517          	auipc	a0,0x23
    80006630:	9f450513          	addi	a0,a0,-1548 # 80029020 <tx_ring>
    80006634:	ffffa097          	auipc	ra,0xffffa
    80006638:	73a080e7          	jalr	1850(ra) # 80000d6e <memset>
  for (i = 0; i < TX_RING_SIZE; i++) {
    8000663c:	00023717          	auipc	a4,0x23
    80006640:	9f070713          	addi	a4,a4,-1552 # 8002902c <tx_ring+0xc>
    80006644:	00023797          	auipc	a5,0x23
    80006648:	adc78793          	addi	a5,a5,-1316 # 80029120 <tx_mbufs>
    8000664c:	00023617          	auipc	a2,0x23
    80006650:	b5460613          	addi	a2,a2,-1196 # 800291a0 <rx_ring>
    tx_ring[i].status = E1000_TXD_STAT_DD;
    80006654:	4685                	li	a3,1
    80006656:	00d70023          	sb	a3,0(a4)
    tx_mbufs[i] = 0;
    8000665a:	0007b023          	sd	zero,0(a5)
  for (i = 0; i < TX_RING_SIZE; i++) {
    8000665e:	0741                	addi	a4,a4,16
    80006660:	07a1                	addi	a5,a5,8
    80006662:	fec79ae3          	bne	a5,a2,80006656 <e1000_init+0x78>
  }
  regs[E1000_TDBAL] = (uint64) tx_ring;
    80006666:	00023717          	auipc	a4,0x23
    8000666a:	9ba70713          	addi	a4,a4,-1606 # 80029020 <tx_ring>
    8000666e:	00023797          	auipc	a5,0x23
    80006672:	d1a7b783          	ld	a5,-742(a5) # 80029388 <regs>
    80006676:	6691                	lui	a3,0x4
    80006678:	97b6                	add	a5,a5,a3
    8000667a:	80e7a023          	sw	a4,-2048(a5)
  if(sizeof(tx_ring) % 128 != 0)
    panic("e1000");
  regs[E1000_TDLEN] = sizeof(tx_ring);
    8000667e:	10000713          	li	a4,256
    80006682:	80e7a423          	sw	a4,-2040(a5)
  regs[E1000_TDH] = regs[E1000_TDT] = 0;
    80006686:	8007ac23          	sw	zero,-2024(a5)
    8000668a:	8007a823          	sw	zero,-2032(a5)
  
  // [E1000 14.4] Receive initialization
  memset(rx_ring, 0, sizeof(rx_ring));
    8000668e:	00023917          	auipc	s2,0x23
    80006692:	b1290913          	addi	s2,s2,-1262 # 800291a0 <rx_ring>
    80006696:	10000613          	li	a2,256
    8000669a:	4581                	li	a1,0
    8000669c:	854a                	mv	a0,s2
    8000669e:	ffffa097          	auipc	ra,0xffffa
    800066a2:	6d0080e7          	jalr	1744(ra) # 80000d6e <memset>
  for (i = 0; i < RX_RING_SIZE; i++) {
    800066a6:	00023497          	auipc	s1,0x23
    800066aa:	bfa48493          	addi	s1,s1,-1030 # 800292a0 <rx_mbufs>
    800066ae:	00023997          	auipc	s3,0x23
    800066b2:	c7298993          	addi	s3,s3,-910 # 80029320 <lock>
    rx_mbufs[i] = mbufalloc(0);
    800066b6:	4501                	li	a0,0
    800066b8:	00000097          	auipc	ra,0x0
    800066bc:	444080e7          	jalr	1092(ra) # 80006afc <mbufalloc>
    800066c0:	e088                	sd	a0,0(s1)
    if (!rx_mbufs[i])
    800066c2:	c945                	beqz	a0,80006772 <e1000_init+0x194>
      panic("e1000");
    rx_ring[i].addr = (uint64) rx_mbufs[i]->head;
    800066c4:	651c                	ld	a5,8(a0)
    800066c6:	00f93023          	sd	a5,0(s2)
  for (i = 0; i < RX_RING_SIZE; i++) {
    800066ca:	04a1                	addi	s1,s1,8
    800066cc:	0941                	addi	s2,s2,16
    800066ce:	ff3494e3          	bne	s1,s3,800066b6 <e1000_init+0xd8>
  }
  regs[E1000_RDBAL] = (uint64) rx_ring;
    800066d2:	00023697          	auipc	a3,0x23
    800066d6:	cb66b683          	ld	a3,-842(a3) # 80029388 <regs>
    800066da:	00023717          	auipc	a4,0x23
    800066de:	ac670713          	addi	a4,a4,-1338 # 800291a0 <rx_ring>
    800066e2:	678d                	lui	a5,0x3
    800066e4:	97b6                	add	a5,a5,a3
    800066e6:	80e7a023          	sw	a4,-2048(a5) # 2800 <_entry-0x7fffd800>
  if(sizeof(rx_ring) % 128 != 0)
    panic("e1000");
  regs[E1000_RDH] = 0;
    800066ea:	8007a823          	sw	zero,-2032(a5)
  regs[E1000_RDT] = RX_RING_SIZE - 1;
    800066ee:	473d                	li	a4,15
    800066f0:	80e7ac23          	sw	a4,-2024(a5)
  regs[E1000_RDLEN] = sizeof(rx_ring);
    800066f4:	10000713          	li	a4,256
    800066f8:	80e7a423          	sw	a4,-2040(a5)

  // filter by qemu's MAC address, 52:54:00:12:34:56
  regs[E1000_RA] = 0x12005452;
    800066fc:	6715                	lui	a4,0x5
    800066fe:	00e68633          	add	a2,a3,a4
    80006702:	120057b7          	lui	a5,0x12005
    80006706:	45278793          	addi	a5,a5,1106 # 12005452 <_entry-0x6dffabae>
    8000670a:	40f62023          	sw	a5,1024(a2)
  regs[E1000_RA+1] = 0x5634 | (1<<31);
    8000670e:	800057b7          	lui	a5,0x80005
    80006712:	63478793          	addi	a5,a5,1588 # ffffffff80005634 <end+0xfffffffefffdc288>
    80006716:	40f62223          	sw	a5,1028(a2)
  // multicast table
  for (int i = 0; i < 4096/32; i++)
    8000671a:	20070793          	addi	a5,a4,512 # 5200 <_entry-0x7fffae00>
    8000671e:	97b6                	add	a5,a5,a3
    80006720:	40070713          	addi	a4,a4,1024
    80006724:	9736                	add	a4,a4,a3
    regs[E1000_MTA + i] = 0;
    80006726:	0007a023          	sw	zero,0(a5)
  for (int i = 0; i < 4096/32; i++)
    8000672a:	0791                	addi	a5,a5,4
    8000672c:	fee79de3          	bne	a5,a4,80006726 <e1000_init+0x148>

  // transmitter control bits.
  regs[E1000_TCTL] = E1000_TCTL_EN |  // enable
    80006730:	000407b7          	lui	a5,0x40
    80006734:	10a78793          	addi	a5,a5,266 # 4010a <_entry-0x7ffbfef6>
    80006738:	40f6a023          	sw	a5,1024(a3)
    E1000_TCTL_PSP |                  // pad short packets
    (0x10 << E1000_TCTL_CT_SHIFT) |   // collision stuff
    (0x40 << E1000_TCTL_COLD_SHIFT);
  regs[E1000_TIPG] = 10 | (8<<10) | (6<<20); // inter-pkt gap
    8000673c:	006027b7          	lui	a5,0x602
    80006740:	07a9                	addi	a5,a5,10
    80006742:	40f6a823          	sw	a5,1040(a3)

  // receiver control bits.
  regs[E1000_RCTL] = E1000_RCTL_EN | // enable receiver
    80006746:	040087b7          	lui	a5,0x4008
    8000674a:	0789                	addi	a5,a5,2
    8000674c:	10f6a023          	sw	a5,256(a3)
    E1000_RCTL_BAM |                 // enable broadcast
    E1000_RCTL_SZ_2048 |             // 2048-byte rx buffers
    E1000_RCTL_SECRC;                // strip CRC
  
  // ask e1000 for receive interrupts.
  regs[E1000_RDTR] = 0; // interrupt after every received packet (no timer)
    80006750:	678d                	lui	a5,0x3
    80006752:	97b6                	add	a5,a5,a3
    80006754:	8207a023          	sw	zero,-2016(a5) # 2820 <_entry-0x7fffd7e0>
  regs[E1000_RADV] = 0; // interrupt after every packet (no timer)
    80006758:	8207a623          	sw	zero,-2004(a5)
  regs[E1000_IMS] = (1 << 7); // RXDW -- Receiver Descriptor Write Back
    8000675c:	08000793          	li	a5,128
    80006760:	0cf6a823          	sw	a5,208(a3)
}
    80006764:	70a2                	ld	ra,40(sp)
    80006766:	7402                	ld	s0,32(sp)
    80006768:	64e2                	ld	s1,24(sp)
    8000676a:	6942                	ld	s2,16(sp)
    8000676c:	69a2                	ld	s3,8(sp)
    8000676e:	6145                	addi	sp,sp,48
    80006770:	8082                	ret
      panic("e1000");
    80006772:	00003517          	auipc	a0,0x3
    80006776:	46650513          	addi	a0,a0,1126 # 80009bd8 <userret+0xb48>
    8000677a:	ffffa097          	auipc	ra,0xffffa
    8000677e:	dda080e7          	jalr	-550(ra) # 80000554 <panic>

0000000080006782 <e1000_transmit>:

int
e1000_transmit(struct mbuf *m)
{
    80006782:	7179                	addi	sp,sp,-48
    80006784:	f406                	sd	ra,40(sp)
    80006786:	f022                	sd	s0,32(sp)
    80006788:	ec26                	sd	s1,24(sp)
    8000678a:	e84a                	sd	s2,16(sp)
    8000678c:	e44e                	sd	s3,8(sp)
    8000678e:	1800                	addi	s0,sp,48
    80006790:	892a                	mv	s2,a0
  acquire(&e1000_lock);
    80006792:	00023997          	auipc	s3,0x23
    80006796:	86e98993          	addi	s3,s3,-1938 # 80029000 <e1000_lock>
    8000679a:	854e                	mv	a0,s3
    8000679c:	ffffa097          	auipc	ra,0xffffa
    800067a0:	304080e7          	jalr	772(ra) # 80000aa0 <acquire>
  
  uint32 idx = regs[E1000_TDT];
    800067a4:	00023797          	auipc	a5,0x23
    800067a8:	be47b783          	ld	a5,-1052(a5) # 80029388 <regs>
    800067ac:	6711                	lui	a4,0x4
    800067ae:	97ba                	add	a5,a5,a4
    800067b0:	8187a783          	lw	a5,-2024(a5)
    800067b4:	0007849b          	sext.w	s1,a5
  struct tx_desc *desc = &tx_ring[idx];
  
  // 检查描述符是否可用
  if(!(desc->status & E1000_TXD_STAT_DD)) {
    800067b8:	1782                	slli	a5,a5,0x20
    800067ba:	9381                	srli	a5,a5,0x20
    800067bc:	0792                	slli	a5,a5,0x4
    800067be:	97ce                	add	a5,a5,s3
    800067c0:	02c7c783          	lbu	a5,44(a5)
    800067c4:	8b85                	andi	a5,a5,1
    800067c6:	cfc1                	beqz	a5,8000685e <e1000_transmit+0xdc>
    release(&e1000_lock);
    return -1;
  }
  
  // 释放之前可能存在的mbuf
  if(tx_mbufs[idx]) {
    800067c8:	02049793          	slli	a5,s1,0x20
    800067cc:	9381                	srli	a5,a5,0x20
    800067ce:	00379713          	slli	a4,a5,0x3
    800067d2:	00023797          	auipc	a5,0x23
    800067d6:	82e78793          	addi	a5,a5,-2002 # 80029000 <e1000_lock>
    800067da:	97ba                	add	a5,a5,a4
    800067dc:	1207b503          	ld	a0,288(a5)
    800067e0:	c10d                	beqz	a0,80006802 <e1000_transmit+0x80>
    mbuffree(tx_mbufs[idx]);
    800067e2:	00000097          	auipc	ra,0x0
    800067e6:	372080e7          	jalr	882(ra) # 80006b54 <mbuffree>
    tx_mbufs[idx] = 0;
    800067ea:	02049793          	slli	a5,s1,0x20
    800067ee:	9381                	srli	a5,a5,0x20
    800067f0:	00379713          	slli	a4,a5,0x3
    800067f4:	00023797          	auipc	a5,0x23
    800067f8:	80c78793          	addi	a5,a5,-2036 # 80029000 <e1000_lock>
    800067fc:	97ba                	add	a5,a5,a4
    800067fe:	1207b023          	sd	zero,288(a5)
  }
  
  // 设置描述符
  desc->addr = (uint64)m->head;
    80006802:	00022517          	auipc	a0,0x22
    80006806:	7fe50513          	addi	a0,a0,2046 # 80029000 <e1000_lock>
    8000680a:	02049793          	slli	a5,s1,0x20
    8000680e:	9381                	srli	a5,a5,0x20
    80006810:	00479713          	slli	a4,a5,0x4
    80006814:	972a                	add	a4,a4,a0
    80006816:	00893683          	ld	a3,8(s2)
    8000681a:	f314                	sd	a3,32(a4)
  desc->length = m->len;
    8000681c:	01092683          	lw	a3,16(s2)
    80006820:	02d71423          	sh	a3,40(a4) # 4028 <_entry-0x7fffbfd8>
  desc->cmd = E1000_TXD_CMD_RS | E1000_TXD_CMD_EOP;
    80006824:	46a5                	li	a3,9
    80006826:	02d705a3          	sb	a3,43(a4)
  tx_mbufs[idx] = m;
    8000682a:	078e                	slli	a5,a5,0x3
    8000682c:	97aa                	add	a5,a5,a0
    8000682e:	1327b023          	sd	s2,288(a5)
  
  // 更新尾指针
  regs[E1000_TDT] = (idx + 1) % TX_RING_SIZE;
    80006832:	2485                	addiw	s1,s1,1
    80006834:	88bd                	andi	s1,s1,15
    80006836:	00023797          	auipc	a5,0x23
    8000683a:	b527b783          	ld	a5,-1198(a5) # 80029388 <regs>
    8000683e:	6711                	lui	a4,0x4
    80006840:	97ba                	add	a5,a5,a4
    80006842:	8097ac23          	sw	s1,-2024(a5)
  
  release(&e1000_lock);
    80006846:	ffffa097          	auipc	ra,0xffffa
    8000684a:	32a080e7          	jalr	810(ra) # 80000b70 <release>
  return 0;
    8000684e:	4501                	li	a0,0
}
    80006850:	70a2                	ld	ra,40(sp)
    80006852:	7402                	ld	s0,32(sp)
    80006854:	64e2                	ld	s1,24(sp)
    80006856:	6942                	ld	s2,16(sp)
    80006858:	69a2                	ld	s3,8(sp)
    8000685a:	6145                	addi	sp,sp,48
    8000685c:	8082                	ret
    release(&e1000_lock);
    8000685e:	854e                	mv	a0,s3
    80006860:	ffffa097          	auipc	ra,0xffffa
    80006864:	310080e7          	jalr	784(ra) # 80000b70 <release>
    return -1;
    80006868:	557d                	li	a0,-1
    8000686a:	b7dd                	j	80006850 <e1000_transmit+0xce>

000000008000686c <e1000_intr>:
  }
}

void
e1000_intr(void)
{
    8000686c:	7139                	addi	sp,sp,-64
    8000686e:	fc06                	sd	ra,56(sp)
    80006870:	f822                	sd	s0,48(sp)
    80006872:	f426                	sd	s1,40(sp)
    80006874:	f04a                	sd	s2,32(sp)
    80006876:	ec4e                	sd	s3,24(sp)
    80006878:	e852                	sd	s4,16(sp)
    8000687a:	e456                	sd	s5,8(sp)
    8000687c:	e05a                	sd	s6,0(sp)
    8000687e:	0080                	addi	s0,sp,64
    uint32 idx = (regs[E1000_RDT] + 1) % RX_RING_SIZE;
    80006880:	00023717          	auipc	a4,0x23
    80006884:	b0873703          	ld	a4,-1272(a4) # 80029388 <regs>
    80006888:	678d                	lui	a5,0x3
    8000688a:	97ba                	add	a5,a5,a4
    8000688c:	8187a783          	lw	a5,-2024(a5) # 2818 <_entry-0x7fffd7e8>
    80006890:	2785                	addiw	a5,a5,1
    80006892:	00f7f493          	andi	s1,a5,15
    if(!(desc->status & E1000_RXD_STAT_DD)) {
    80006896:	00449793          	slli	a5,s1,0x4
    8000689a:	00022697          	auipc	a3,0x22
    8000689e:	76668693          	addi	a3,a3,1894 # 80029000 <e1000_lock>
    800068a2:	97b6                	add	a5,a5,a3
    800068a4:	1ac7c783          	lbu	a5,428(a5)
    800068a8:	8b85                	andi	a5,a5,1
    800068aa:	c3d1                	beqz	a5,8000692e <e1000_intr+0xc2>
    struct mbuf *m = rx_mbufs[idx];
    800068ac:	8936                	mv	s2,a3
    regs[E1000_RDT] = idx;
    800068ae:	00023a17          	auipc	s4,0x23
    800068b2:	adaa0a13          	addi	s4,s4,-1318 # 80029388 <regs>
    800068b6:	698d                	lui	s3,0x3
    struct mbuf *m = rx_mbufs[idx];
    800068b8:	00349a93          	slli	s5,s1,0x3
    800068bc:	9aca                	add	s5,s5,s2
    800068be:	2a0abb03          	ld	s6,672(s5)
    mbufput(m, desc->length);
    800068c2:	00449793          	slli	a5,s1,0x4
    800068c6:	97ca                	add	a5,a5,s2
    800068c8:	1a87d583          	lhu	a1,424(a5)
    800068cc:	855a                	mv	a0,s6
    800068ce:	00000097          	auipc	ra,0x0
    800068d2:	1d2080e7          	jalr	466(ra) # 80006aa0 <mbufput>
    rx_mbufs[idx] = 0;
    800068d6:	2a0ab023          	sd	zero,672(s5)
    net_rx(m);
    800068da:	855a                	mv	a0,s6
    800068dc:	00000097          	auipc	ra,0x0
    800068e0:	3f4080e7          	jalr	1012(ra) # 80006cd0 <net_rx>
    m = mbufalloc(0);
    800068e4:	4501                	li	a0,0
    800068e6:	00000097          	auipc	ra,0x0
    800068ea:	216080e7          	jalr	534(ra) # 80006afc <mbufalloc>
    if(!m) {
    800068ee:	cd21                	beqz	a0,80006946 <e1000_intr+0xda>
    desc->addr = (uint64)m->head;
    800068f0:	00449793          	slli	a5,s1,0x4
    800068f4:	97ca                	add	a5,a5,s2
    800068f6:	6518                	ld	a4,8(a0)
    800068f8:	1ae7b023          	sd	a4,416(a5)
    desc->status = 0;
    800068fc:	1a078623          	sb	zero,428(a5)
    rx_mbufs[idx] = m;
    80006900:	00349793          	slli	a5,s1,0x3
    80006904:	97ca                	add	a5,a5,s2
    80006906:	2aa7b023          	sd	a0,672(a5)
    regs[E1000_RDT] = idx;
    8000690a:	000a3703          	ld	a4,0(s4)
    8000690e:	013707b3          	add	a5,a4,s3
    80006912:	8097ac23          	sw	s1,-2024(a5)
    uint32 idx = (regs[E1000_RDT] + 1) % RX_RING_SIZE;
    80006916:	8187a783          	lw	a5,-2024(a5)
    8000691a:	2785                	addiw	a5,a5,1
    8000691c:	00f7f493          	andi	s1,a5,15
    if(!(desc->status & E1000_RXD_STAT_DD)) {
    80006920:	00449793          	slli	a5,s1,0x4
    80006924:	97ca                	add	a5,a5,s2
    80006926:	1ac7c783          	lbu	a5,428(a5)
    8000692a:	8b85                	andi	a5,a5,1
    8000692c:	f7d1                	bnez	a5,800068b8 <e1000_intr+0x4c>
  e1000_recv();
  // tell the e1000 we've seen this interrupt;
  // without this the e1000 won't raise any
  // further interrupts.
  regs[E1000_ICR];
    8000692e:	0c072783          	lw	a5,192(a4)
}
    80006932:	70e2                	ld	ra,56(sp)
    80006934:	7442                	ld	s0,48(sp)
    80006936:	74a2                	ld	s1,40(sp)
    80006938:	7902                	ld	s2,32(sp)
    8000693a:	69e2                	ld	s3,24(sp)
    8000693c:	6a42                	ld	s4,16(sp)
    8000693e:	6aa2                	ld	s5,8(sp)
    80006940:	6b02                	ld	s6,0(sp)
    80006942:	6121                	addi	sp,sp,64
    80006944:	8082                	ret
      panic("e1000: no mbufs available");
    80006946:	00003517          	auipc	a0,0x3
    8000694a:	29a50513          	addi	a0,a0,666 # 80009be0 <userret+0xb50>
    8000694e:	ffffa097          	auipc	ra,0xffffa
    80006952:	c06080e7          	jalr	-1018(ra) # 80000554 <panic>

0000000080006956 <in_cksum>:

// This code is lifted from FreeBSD's ping.c, and is copyright by the Regents
// of the University of California.
static unsigned short
in_cksum(const unsigned char *addr, int len)
{
    80006956:	1101                	addi	sp,sp,-32
    80006958:	ec22                	sd	s0,24(sp)
    8000695a:	1000                	addi	s0,sp,32
  int nleft = len;
  const unsigned short *w = (const unsigned short *)addr;
  unsigned int sum = 0;
  unsigned short answer = 0;
    8000695c:	fe041723          	sh	zero,-18(s0)
  /*
   * Our algorithm is simple, using a 32 bit accumulator (sum), we add
   * sequential 16 bit words to it, and at the end, fold back all the
   * carry bits from the top 16 bits into the lower 16 bits.
   */
  while (nleft > 1)  {
    80006960:	4785                	li	a5,1
    80006962:	04b7da63          	bge	a5,a1,800069b6 <in_cksum+0x60>
    80006966:	ffe5861b          	addiw	a2,a1,-2
    8000696a:	0016561b          	srliw	a2,a2,0x1
    8000696e:	0016069b          	addiw	a3,a2,1
    80006972:	1682                	slli	a3,a3,0x20
    80006974:	9281                	srli	a3,a3,0x20
    80006976:	0686                	slli	a3,a3,0x1
    80006978:	96aa                	add	a3,a3,a0
  unsigned int sum = 0;
    8000697a:	4781                	li	a5,0
    sum += *w++;
    8000697c:	0509                	addi	a0,a0,2
    8000697e:	ffe55703          	lhu	a4,-2(a0)
    80006982:	9fb9                	addw	a5,a5,a4
  while (nleft > 1)  {
    80006984:	fed51ce3          	bne	a0,a3,8000697c <in_cksum+0x26>
    nleft -= 2;
    80006988:	35f9                	addiw	a1,a1,-2
    8000698a:	0016161b          	slliw	a2,a2,0x1
    8000698e:	9d91                	subw	a1,a1,a2
  }

  /* mop up an odd byte, if necessary */
  if (nleft == 1) {
    80006990:	4705                	li	a4,1
    80006992:	02e58563          	beq	a1,a4,800069bc <in_cksum+0x66>
    *(unsigned char *)(&answer) = *(const unsigned char *)w;
    sum += answer;
  }

  /* add back carry outs from top 16 bits to low 16 bits */
  sum = (sum & 0xffff) + (sum >> 16);
    80006996:	03079513          	slli	a0,a5,0x30
    8000699a:	9141                	srli	a0,a0,0x30
    8000699c:	0107d79b          	srliw	a5,a5,0x10
    800069a0:	9fa9                	addw	a5,a5,a0
  sum += (sum >> 16);
    800069a2:	0107d51b          	srliw	a0,a5,0x10
    800069a6:	9d3d                	addw	a0,a0,a5
  /* guaranteed now that the lower 16 bits of sum are correct */

  answer = ~sum; /* truncate to 16 bits */
    800069a8:	fff54513          	not	a0,a0
  return answer;
}
    800069ac:	1542                	slli	a0,a0,0x30
    800069ae:	9141                	srli	a0,a0,0x30
    800069b0:	6462                	ld	s0,24(sp)
    800069b2:	6105                	addi	sp,sp,32
    800069b4:	8082                	ret
  const unsigned short *w = (const unsigned short *)addr;
    800069b6:	86aa                	mv	a3,a0
  unsigned int sum = 0;
    800069b8:	4781                	li	a5,0
    800069ba:	bfd9                	j	80006990 <in_cksum+0x3a>
    *(unsigned char *)(&answer) = *(const unsigned char *)w;
    800069bc:	0006c703          	lbu	a4,0(a3)
    800069c0:	fee40723          	sb	a4,-18(s0)
    sum += answer;
    800069c4:	fee45703          	lhu	a4,-18(s0)
    800069c8:	9fb9                	addw	a5,a5,a4
    800069ca:	b7f1                	j	80006996 <in_cksum+0x40>

00000000800069cc <mbufpull>:
{
    800069cc:	1141                	addi	sp,sp,-16
    800069ce:	e422                	sd	s0,8(sp)
    800069d0:	0800                	addi	s0,sp,16
    800069d2:	87aa                	mv	a5,a0
  char *tmp = m->head;
    800069d4:	6508                	ld	a0,8(a0)
  if (m->len < len)
    800069d6:	4b98                	lw	a4,16(a5)
    800069d8:	00b76b63          	bltu	a4,a1,800069ee <mbufpull+0x22>
  m->len -= len;
    800069dc:	9f0d                	subw	a4,a4,a1
    800069de:	cb98                	sw	a4,16(a5)
  m->head += len;
    800069e0:	1582                	slli	a1,a1,0x20
    800069e2:	9181                	srli	a1,a1,0x20
    800069e4:	95aa                	add	a1,a1,a0
    800069e6:	e78c                	sd	a1,8(a5)
}
    800069e8:	6422                	ld	s0,8(sp)
    800069ea:	0141                	addi	sp,sp,16
    800069ec:	8082                	ret
    return 0;
    800069ee:	4501                	li	a0,0
    800069f0:	bfe5                	j	800069e8 <mbufpull+0x1c>

00000000800069f2 <mbufpush>:
{
    800069f2:	87aa                	mv	a5,a0
  m->head -= len;
    800069f4:	02059713          	slli	a4,a1,0x20
    800069f8:	9301                	srli	a4,a4,0x20
    800069fa:	6508                	ld	a0,8(a0)
    800069fc:	8d19                	sub	a0,a0,a4
    800069fe:	e788                	sd	a0,8(a5)
  if (m->head < m->buf)
    80006a00:	01478713          	addi	a4,a5,20
    80006a04:	00e56663          	bltu	a0,a4,80006a10 <mbufpush+0x1e>
  m->len += len;
    80006a08:	4b98                	lw	a4,16(a5)
    80006a0a:	9db9                	addw	a1,a1,a4
    80006a0c:	cb8c                	sw	a1,16(a5)
}
    80006a0e:	8082                	ret
{
    80006a10:	1141                	addi	sp,sp,-16
    80006a12:	e406                	sd	ra,8(sp)
    80006a14:	e022                	sd	s0,0(sp)
    80006a16:	0800                	addi	s0,sp,16
    panic("mbufpush");
    80006a18:	00003517          	auipc	a0,0x3
    80006a1c:	1e850513          	addi	a0,a0,488 # 80009c00 <userret+0xb70>
    80006a20:	ffffa097          	auipc	ra,0xffffa
    80006a24:	b34080e7          	jalr	-1228(ra) # 80000554 <panic>

0000000080006a28 <net_tx_eth>:

// sends an ethernet packet
static void
net_tx_eth(struct mbuf *m, uint16 ethtype)
{
    80006a28:	7179                	addi	sp,sp,-48
    80006a2a:	f406                	sd	ra,40(sp)
    80006a2c:	f022                	sd	s0,32(sp)
    80006a2e:	ec26                	sd	s1,24(sp)
    80006a30:	e84a                	sd	s2,16(sp)
    80006a32:	e44e                	sd	s3,8(sp)
    80006a34:	1800                	addi	s0,sp,48
    80006a36:	89aa                	mv	s3,a0
    80006a38:	892e                	mv	s2,a1
  struct eth *ethhdr;

  ethhdr = mbufpushhdr(m, *ethhdr);
    80006a3a:	45b9                	li	a1,14
    80006a3c:	00000097          	auipc	ra,0x0
    80006a40:	fb6080e7          	jalr	-74(ra) # 800069f2 <mbufpush>
    80006a44:	84aa                	mv	s1,a0
  memmove(ethhdr->shost, local_mac, ETHADDR_LEN);
    80006a46:	4619                	li	a2,6
    80006a48:	00003597          	auipc	a1,0x3
    80006a4c:	60058593          	addi	a1,a1,1536 # 8000a048 <local_mac>
    80006a50:	0519                	addi	a0,a0,6
    80006a52:	ffffa097          	auipc	ra,0xffffa
    80006a56:	378080e7          	jalr	888(ra) # 80000dca <memmove>
  // In a real networking stack, dhost would be set to the address discovered
  // through ARP. Because we don't support enough of the ARP protocol, set it
  // to broadcast instead.
  memmove(ethhdr->dhost, broadcast_mac, ETHADDR_LEN);
    80006a5a:	4619                	li	a2,6
    80006a5c:	00003597          	auipc	a1,0x3
    80006a60:	5e458593          	addi	a1,a1,1508 # 8000a040 <broadcast_mac>
    80006a64:	8526                	mv	a0,s1
    80006a66:	ffffa097          	auipc	ra,0xffffa
    80006a6a:	364080e7          	jalr	868(ra) # 80000dca <memmove>
// endianness support
//

static inline uint16 bswaps(uint16 val)
{
  return (((val & 0x00ffU) << 8) |
    80006a6e:	0089579b          	srliw	a5,s2,0x8
  ethhdr->type = htons(ethtype);
    80006a72:	00f48623          	sb	a5,12(s1)
    80006a76:	012486a3          	sb	s2,13(s1)
  if (e1000_transmit(m)) {
    80006a7a:	854e                	mv	a0,s3
    80006a7c:	00000097          	auipc	ra,0x0
    80006a80:	d06080e7          	jalr	-762(ra) # 80006782 <e1000_transmit>
    80006a84:	e901                	bnez	a0,80006a94 <net_tx_eth+0x6c>
    mbuffree(m);
  }
}
    80006a86:	70a2                	ld	ra,40(sp)
    80006a88:	7402                	ld	s0,32(sp)
    80006a8a:	64e2                	ld	s1,24(sp)
    80006a8c:	6942                	ld	s2,16(sp)
    80006a8e:	69a2                	ld	s3,8(sp)
    80006a90:	6145                	addi	sp,sp,48
    80006a92:	8082                	ret
  kfree(m);
    80006a94:	854e                	mv	a0,s3
    80006a96:	ffffa097          	auipc	ra,0xffffa
    80006a9a:	dda080e7          	jalr	-550(ra) # 80000870 <kfree>
}
    80006a9e:	b7e5                	j	80006a86 <net_tx_eth+0x5e>

0000000080006aa0 <mbufput>:
{
    80006aa0:	87aa                	mv	a5,a0
  char *tmp = m->head + m->len;
    80006aa2:	4918                	lw	a4,16(a0)
    80006aa4:	02071693          	slli	a3,a4,0x20
    80006aa8:	9281                	srli	a3,a3,0x20
    80006aaa:	6508                	ld	a0,8(a0)
    80006aac:	9536                	add	a0,a0,a3
  m->len += len;
    80006aae:	9f2d                	addw	a4,a4,a1
    80006ab0:	0007069b          	sext.w	a3,a4
    80006ab4:	cb98                	sw	a4,16(a5)
  if (m->len > MBUF_SIZE)
    80006ab6:	6785                	lui	a5,0x1
    80006ab8:	80078793          	addi	a5,a5,-2048 # 800 <_entry-0x7ffff800>
    80006abc:	00d7e363          	bltu	a5,a3,80006ac2 <mbufput+0x22>
}
    80006ac0:	8082                	ret
{
    80006ac2:	1141                	addi	sp,sp,-16
    80006ac4:	e406                	sd	ra,8(sp)
    80006ac6:	e022                	sd	s0,0(sp)
    80006ac8:	0800                	addi	s0,sp,16
    panic("mbufput");
    80006aca:	00003517          	auipc	a0,0x3
    80006ace:	14650513          	addi	a0,a0,326 # 80009c10 <userret+0xb80>
    80006ad2:	ffffa097          	auipc	ra,0xffffa
    80006ad6:	a82080e7          	jalr	-1406(ra) # 80000554 <panic>

0000000080006ada <mbuftrim>:
{
    80006ada:	1141                	addi	sp,sp,-16
    80006adc:	e422                	sd	s0,8(sp)
    80006ade:	0800                	addi	s0,sp,16
  if (len > m->len)
    80006ae0:	491c                	lw	a5,16(a0)
    80006ae2:	00b7eb63          	bltu	a5,a1,80006af8 <mbuftrim+0x1e>
  m->len -= len;
    80006ae6:	9f8d                	subw	a5,a5,a1
    80006ae8:	c91c                	sw	a5,16(a0)
  return m->head + m->len;
    80006aea:	1782                	slli	a5,a5,0x20
    80006aec:	9381                	srli	a5,a5,0x20
    80006aee:	6508                	ld	a0,8(a0)
    80006af0:	953e                	add	a0,a0,a5
}
    80006af2:	6422                	ld	s0,8(sp)
    80006af4:	0141                	addi	sp,sp,16
    80006af6:	8082                	ret
    return 0;
    80006af8:	4501                	li	a0,0
    80006afa:	bfe5                	j	80006af2 <mbuftrim+0x18>

0000000080006afc <mbufalloc>:
{
    80006afc:	1101                	addi	sp,sp,-32
    80006afe:	ec06                	sd	ra,24(sp)
    80006b00:	e822                	sd	s0,16(sp)
    80006b02:	e426                	sd	s1,8(sp)
    80006b04:	e04a                	sd	s2,0(sp)
    80006b06:	1000                	addi	s0,sp,32
  if (headroom > MBUF_SIZE)
    80006b08:	6785                	lui	a5,0x1
    80006b0a:	80078793          	addi	a5,a5,-2048 # 800 <_entry-0x7ffff800>
    return 0;
    80006b0e:	4901                	li	s2,0
  if (headroom > MBUF_SIZE)
    80006b10:	02a7eb63          	bltu	a5,a0,80006b46 <mbufalloc+0x4a>
    80006b14:	84aa                	mv	s1,a0
  m = kalloc();
    80006b16:	ffffa097          	auipc	ra,0xffffa
    80006b1a:	e56080e7          	jalr	-426(ra) # 8000096c <kalloc>
    80006b1e:	892a                	mv	s2,a0
  if (m == 0)
    80006b20:	c11d                	beqz	a0,80006b46 <mbufalloc+0x4a>
  m->next = 0;
    80006b22:	00053023          	sd	zero,0(a0)
  m->head = (char *)m->buf + headroom;
    80006b26:	0551                	addi	a0,a0,20
    80006b28:	1482                	slli	s1,s1,0x20
    80006b2a:	9081                	srli	s1,s1,0x20
    80006b2c:	94aa                	add	s1,s1,a0
    80006b2e:	00993423          	sd	s1,8(s2)
  m->len = 0;
    80006b32:	00092823          	sw	zero,16(s2)
  memset(m->buf, 0, sizeof(m->buf));
    80006b36:	6605                	lui	a2,0x1
    80006b38:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    80006b3c:	4581                	li	a1,0
    80006b3e:	ffffa097          	auipc	ra,0xffffa
    80006b42:	230080e7          	jalr	560(ra) # 80000d6e <memset>
}
    80006b46:	854a                	mv	a0,s2
    80006b48:	60e2                	ld	ra,24(sp)
    80006b4a:	6442                	ld	s0,16(sp)
    80006b4c:	64a2                	ld	s1,8(sp)
    80006b4e:	6902                	ld	s2,0(sp)
    80006b50:	6105                	addi	sp,sp,32
    80006b52:	8082                	ret

0000000080006b54 <mbuffree>:
{
    80006b54:	1141                	addi	sp,sp,-16
    80006b56:	e406                	sd	ra,8(sp)
    80006b58:	e022                	sd	s0,0(sp)
    80006b5a:	0800                	addi	s0,sp,16
  kfree(m);
    80006b5c:	ffffa097          	auipc	ra,0xffffa
    80006b60:	d14080e7          	jalr	-748(ra) # 80000870 <kfree>
}
    80006b64:	60a2                	ld	ra,8(sp)
    80006b66:	6402                	ld	s0,0(sp)
    80006b68:	0141                	addi	sp,sp,16
    80006b6a:	8082                	ret

0000000080006b6c <mbufq_pushtail>:
{
    80006b6c:	1141                	addi	sp,sp,-16
    80006b6e:	e422                	sd	s0,8(sp)
    80006b70:	0800                	addi	s0,sp,16
  m->next = 0;
    80006b72:	0005b023          	sd	zero,0(a1)
  if (!q->head){
    80006b76:	611c                	ld	a5,0(a0)
    80006b78:	c799                	beqz	a5,80006b86 <mbufq_pushtail+0x1a>
  q->tail->next = m;
    80006b7a:	651c                	ld	a5,8(a0)
    80006b7c:	e38c                	sd	a1,0(a5)
  q->tail = m;
    80006b7e:	e50c                	sd	a1,8(a0)
}
    80006b80:	6422                	ld	s0,8(sp)
    80006b82:	0141                	addi	sp,sp,16
    80006b84:	8082                	ret
    q->head = q->tail = m;
    80006b86:	e50c                	sd	a1,8(a0)
    80006b88:	e10c                	sd	a1,0(a0)
    return;
    80006b8a:	bfdd                	j	80006b80 <mbufq_pushtail+0x14>

0000000080006b8c <mbufq_pophead>:
{
    80006b8c:	1141                	addi	sp,sp,-16
    80006b8e:	e422                	sd	s0,8(sp)
    80006b90:	0800                	addi	s0,sp,16
    80006b92:	87aa                	mv	a5,a0
  struct mbuf *head = q->head;
    80006b94:	6108                	ld	a0,0(a0)
  if (!head)
    80006b96:	c119                	beqz	a0,80006b9c <mbufq_pophead+0x10>
  q->head = head->next;
    80006b98:	6118                	ld	a4,0(a0)
    80006b9a:	e398                	sd	a4,0(a5)
}
    80006b9c:	6422                	ld	s0,8(sp)
    80006b9e:	0141                	addi	sp,sp,16
    80006ba0:	8082                	ret

0000000080006ba2 <mbufq_empty>:
{
    80006ba2:	1141                	addi	sp,sp,-16
    80006ba4:	e422                	sd	s0,8(sp)
    80006ba6:	0800                	addi	s0,sp,16
  return q->head == 0;
    80006ba8:	6108                	ld	a0,0(a0)
}
    80006baa:	00153513          	seqz	a0,a0
    80006bae:	6422                	ld	s0,8(sp)
    80006bb0:	0141                	addi	sp,sp,16
    80006bb2:	8082                	ret

0000000080006bb4 <mbufq_init>:
{
    80006bb4:	1141                	addi	sp,sp,-16
    80006bb6:	e422                	sd	s0,8(sp)
    80006bb8:	0800                	addi	s0,sp,16
  q->head = 0;
    80006bba:	00053023          	sd	zero,0(a0)
}
    80006bbe:	6422                	ld	s0,8(sp)
    80006bc0:	0141                	addi	sp,sp,16
    80006bc2:	8082                	ret

0000000080006bc4 <net_tx_udp>:

// sends a UDP packet
void
net_tx_udp(struct mbuf *m, uint32 dip,
           uint16 sport, uint16 dport)
{
    80006bc4:	7179                	addi	sp,sp,-48
    80006bc6:	f406                	sd	ra,40(sp)
    80006bc8:	f022                	sd	s0,32(sp)
    80006bca:	ec26                	sd	s1,24(sp)
    80006bcc:	e84a                	sd	s2,16(sp)
    80006bce:	e44e                	sd	s3,8(sp)
    80006bd0:	e052                	sd	s4,0(sp)
    80006bd2:	1800                	addi	s0,sp,48
    80006bd4:	89aa                	mv	s3,a0
    80006bd6:	892e                	mv	s2,a1
    80006bd8:	8a32                	mv	s4,a2
    80006bda:	84b6                	mv	s1,a3
  struct udp *udphdr;

  // put the UDP header
  udphdr = mbufpushhdr(m, *udphdr);
    80006bdc:	45a1                	li	a1,8
    80006bde:	00000097          	auipc	ra,0x0
    80006be2:	e14080e7          	jalr	-492(ra) # 800069f2 <mbufpush>
    80006be6:	008a161b          	slliw	a2,s4,0x8
    80006bea:	008a5a1b          	srliw	s4,s4,0x8
    80006bee:	01466a33          	or	s4,a2,s4
  udphdr->sport = htons(sport);
    80006bf2:	01451023          	sh	s4,0(a0)
    80006bf6:	0084969b          	slliw	a3,s1,0x8
    80006bfa:	0084d49b          	srliw	s1,s1,0x8
    80006bfe:	8cd5                	or	s1,s1,a3
  udphdr->dport = htons(dport);
    80006c00:	00951123          	sh	s1,2(a0)
  udphdr->ulen = htons(m->len);
    80006c04:	0109a783          	lw	a5,16(s3) # 3010 <_entry-0x7fffcff0>
    80006c08:	0087971b          	slliw	a4,a5,0x8
    80006c0c:	0107979b          	slliw	a5,a5,0x10
    80006c10:	0107d79b          	srliw	a5,a5,0x10
    80006c14:	0087d79b          	srliw	a5,a5,0x8
    80006c18:	8fd9                	or	a5,a5,a4
    80006c1a:	00f51223          	sh	a5,4(a0)
  udphdr->sum = 0; // zero means no checksum is provided
    80006c1e:	00051323          	sh	zero,6(a0)
  iphdr = mbufpushhdr(m, *iphdr);
    80006c22:	45d1                	li	a1,20
    80006c24:	854e                	mv	a0,s3
    80006c26:	00000097          	auipc	ra,0x0
    80006c2a:	dcc080e7          	jalr	-564(ra) # 800069f2 <mbufpush>
    80006c2e:	84aa                	mv	s1,a0
  memset(iphdr, 0, sizeof(*iphdr));
    80006c30:	4651                	li	a2,20
    80006c32:	4581                	li	a1,0
    80006c34:	ffffa097          	auipc	ra,0xffffa
    80006c38:	13a080e7          	jalr	314(ra) # 80000d6e <memset>
  iphdr->ip_vhl = (4 << 4) | (20 >> 2);
    80006c3c:	04500793          	li	a5,69
    80006c40:	00f48023          	sb	a5,0(s1)
  iphdr->ip_p = proto;
    80006c44:	47c5                	li	a5,17
    80006c46:	00f484a3          	sb	a5,9(s1)
  iphdr->ip_src = htonl(local_ip);
    80006c4a:	0f0207b7          	lui	a5,0xf020
    80006c4e:	07a9                	addi	a5,a5,10
    80006c50:	c4dc                	sw	a5,12(s1)
          ((val & 0xff00U) >> 8));
}

static inline uint32 bswapl(uint32 val)
{
  return (((val & 0x000000ffUL) << 24) |
    80006c52:	0189179b          	slliw	a5,s2,0x18
          ((val & 0x0000ff00UL) << 8) |
          ((val & 0x00ff0000UL) >> 8) |
          ((val & 0xff000000UL) >> 24));
    80006c56:	0189571b          	srliw	a4,s2,0x18
          ((val & 0x00ff0000UL) >> 8) |
    80006c5a:	8fd9                	or	a5,a5,a4
          ((val & 0x0000ff00UL) << 8) |
    80006c5c:	0089171b          	slliw	a4,s2,0x8
    80006c60:	00ff06b7          	lui	a3,0xff0
    80006c64:	8f75                	and	a4,a4,a3
          ((val & 0x00ff0000UL) >> 8) |
    80006c66:	8fd9                	or	a5,a5,a4
    80006c68:	0089591b          	srliw	s2,s2,0x8
    80006c6c:	65c1                	lui	a1,0x10
    80006c6e:	f0058593          	addi	a1,a1,-256 # ff00 <_entry-0x7fff0100>
    80006c72:	00b97933          	and	s2,s2,a1
    80006c76:	0127e933          	or	s2,a5,s2
  iphdr->ip_dst = htonl(dip);
    80006c7a:	0124a823          	sw	s2,16(s1)
  iphdr->ip_len = htons(m->len);
    80006c7e:	0109a783          	lw	a5,16(s3)
  return (((val & 0x00ffU) << 8) |
    80006c82:	0087971b          	slliw	a4,a5,0x8
    80006c86:	0107979b          	slliw	a5,a5,0x10
    80006c8a:	0107d79b          	srliw	a5,a5,0x10
    80006c8e:	0087d79b          	srliw	a5,a5,0x8
    80006c92:	8fd9                	or	a5,a5,a4
    80006c94:	00f49123          	sh	a5,2(s1)
  iphdr->ip_ttl = 100;
    80006c98:	06400793          	li	a5,100
    80006c9c:	00f48423          	sb	a5,8(s1)
  iphdr->ip_sum = in_cksum((unsigned char *)iphdr, sizeof(*iphdr));
    80006ca0:	45d1                	li	a1,20
    80006ca2:	8526                	mv	a0,s1
    80006ca4:	00000097          	auipc	ra,0x0
    80006ca8:	cb2080e7          	jalr	-846(ra) # 80006956 <in_cksum>
    80006cac:	00a49523          	sh	a0,10(s1)
  net_tx_eth(m, ETHTYPE_IP);
    80006cb0:	6585                	lui	a1,0x1
    80006cb2:	80058593          	addi	a1,a1,-2048 # 800 <_entry-0x7ffff800>
    80006cb6:	854e                	mv	a0,s3
    80006cb8:	00000097          	auipc	ra,0x0
    80006cbc:	d70080e7          	jalr	-656(ra) # 80006a28 <net_tx_eth>

  // now on to the IP layer
  net_tx_ip(m, IPPROTO_UDP, dip);
}
    80006cc0:	70a2                	ld	ra,40(sp)
    80006cc2:	7402                	ld	s0,32(sp)
    80006cc4:	64e2                	ld	s1,24(sp)
    80006cc6:	6942                	ld	s2,16(sp)
    80006cc8:	69a2                	ld	s3,8(sp)
    80006cca:	6a02                	ld	s4,0(sp)
    80006ccc:	6145                	addi	sp,sp,48
    80006cce:	8082                	ret

0000000080006cd0 <net_rx>:
}

// called by e1000 driver's interrupt handler to deliver a packet to the
// networking stack
void net_rx(struct mbuf *m)
{
    80006cd0:	715d                	addi	sp,sp,-80
    80006cd2:	e486                	sd	ra,72(sp)
    80006cd4:	e0a2                	sd	s0,64(sp)
    80006cd6:	fc26                	sd	s1,56(sp)
    80006cd8:	f84a                	sd	s2,48(sp)
    80006cda:	f44e                	sd	s3,40(sp)
    80006cdc:	f052                	sd	s4,32(sp)
    80006cde:	ec56                	sd	s5,24(sp)
    80006ce0:	0880                	addi	s0,sp,80
    80006ce2:	84aa                	mv	s1,a0
  struct eth *ethhdr;
  uint16 type;

  ethhdr = mbufpullhdr(m, *ethhdr);
    80006ce4:	45b9                	li	a1,14
    80006ce6:	00000097          	auipc	ra,0x0
    80006cea:	ce6080e7          	jalr	-794(ra) # 800069cc <mbufpull>
  if (!ethhdr) {
    80006cee:	c521                	beqz	a0,80006d36 <net_rx+0x66>
    mbuffree(m);
    return;
  }

  type = ntohs(ethhdr->type);
    80006cf0:	00c54703          	lbu	a4,12(a0)
    80006cf4:	00d54783          	lbu	a5,13(a0)
    80006cf8:	07a2                	slli	a5,a5,0x8
    80006cfa:	8fd9                	or	a5,a5,a4
    80006cfc:	0087971b          	slliw	a4,a5,0x8
    80006d00:	83a1                	srli	a5,a5,0x8
    80006d02:	8fd9                	or	a5,a5,a4
    80006d04:	17c2                	slli	a5,a5,0x30
    80006d06:	93c1                	srli	a5,a5,0x30
  if (type == ETHTYPE_IP)
    80006d08:	8007871b          	addiw	a4,a5,-2048
    80006d0c:	cb1d                	beqz	a4,80006d42 <net_rx+0x72>
    net_rx_ip(m);
  else if (type == ETHTYPE_ARP)
    80006d0e:	2781                	sext.w	a5,a5
    80006d10:	6705                	lui	a4,0x1
    80006d12:	80670713          	addi	a4,a4,-2042 # 806 <_entry-0x7ffff7fa>
    80006d16:	1ae78a63          	beq	a5,a4,80006eca <net_rx+0x1fa>
  kfree(m);
    80006d1a:	8526                	mv	a0,s1
    80006d1c:	ffffa097          	auipc	ra,0xffffa
    80006d20:	b54080e7          	jalr	-1196(ra) # 80000870 <kfree>
    net_rx_arp(m);
  else
    mbuffree(m);
}
    80006d24:	60a6                	ld	ra,72(sp)
    80006d26:	6406                	ld	s0,64(sp)
    80006d28:	74e2                	ld	s1,56(sp)
    80006d2a:	7942                	ld	s2,48(sp)
    80006d2c:	79a2                	ld	s3,40(sp)
    80006d2e:	7a02                	ld	s4,32(sp)
    80006d30:	6ae2                	ld	s5,24(sp)
    80006d32:	6161                	addi	sp,sp,80
    80006d34:	8082                	ret
  kfree(m);
    80006d36:	8526                	mv	a0,s1
    80006d38:	ffffa097          	auipc	ra,0xffffa
    80006d3c:	b38080e7          	jalr	-1224(ra) # 80000870 <kfree>
}
    80006d40:	b7d5                	j	80006d24 <net_rx+0x54>
  iphdr = mbufpullhdr(m, *iphdr);
    80006d42:	45d1                	li	a1,20
    80006d44:	8526                	mv	a0,s1
    80006d46:	00000097          	auipc	ra,0x0
    80006d4a:	c86080e7          	jalr	-890(ra) # 800069cc <mbufpull>
    80006d4e:	892a                	mv	s2,a0
  if (!iphdr)
    80006d50:	c519                	beqz	a0,80006d5e <net_rx+0x8e>
  if (iphdr->ip_vhl != ((4 << 4) | (20 >> 2)))
    80006d52:	00054703          	lbu	a4,0(a0)
    80006d56:	04500793          	li	a5,69
    80006d5a:	00f70863          	beq	a4,a5,80006d6a <net_rx+0x9a>
  kfree(m);
    80006d5e:	8526                	mv	a0,s1
    80006d60:	ffffa097          	auipc	ra,0xffffa
    80006d64:	b10080e7          	jalr	-1264(ra) # 80000870 <kfree>
}
    80006d68:	bf75                	j	80006d24 <net_rx+0x54>
  if (in_cksum((unsigned char *)iphdr, sizeof(*iphdr)))
    80006d6a:	45d1                	li	a1,20
    80006d6c:	00000097          	auipc	ra,0x0
    80006d70:	bea080e7          	jalr	-1046(ra) # 80006956 <in_cksum>
    80006d74:	f56d                	bnez	a0,80006d5e <net_rx+0x8e>
    80006d76:	00695783          	lhu	a5,6(s2)
    80006d7a:	0087971b          	slliw	a4,a5,0x8
    80006d7e:	0107979b          	slliw	a5,a5,0x10
    80006d82:	0107d79b          	srliw	a5,a5,0x10
    80006d86:	0087d79b          	srliw	a5,a5,0x8
    80006d8a:	8fd9                	or	a5,a5,a4
  if (htons(iphdr->ip_off) != 0)
    80006d8c:	17c2                	slli	a5,a5,0x30
    80006d8e:	93c1                	srli	a5,a5,0x30
    80006d90:	f7f9                	bnez	a5,80006d5e <net_rx+0x8e>
  if (htonl(iphdr->ip_dst) != local_ip)
    80006d92:	01092703          	lw	a4,16(s2)
  return (((val & 0x000000ffUL) << 24) |
    80006d96:	0187179b          	slliw	a5,a4,0x18
          ((val & 0xff000000UL) >> 24));
    80006d9a:	0187569b          	srliw	a3,a4,0x18
          ((val & 0x00ff0000UL) >> 8) |
    80006d9e:	8fd5                	or	a5,a5,a3
          ((val & 0x0000ff00UL) << 8) |
    80006da0:	0087169b          	slliw	a3,a4,0x8
    80006da4:	00ff0637          	lui	a2,0xff0
    80006da8:	8ef1                	and	a3,a3,a2
          ((val & 0x00ff0000UL) >> 8) |
    80006daa:	8fd5                	or	a5,a5,a3
    80006dac:	0087571b          	srliw	a4,a4,0x8
    80006db0:	66c1                	lui	a3,0x10
    80006db2:	f0068693          	addi	a3,a3,-256 # ff00 <_entry-0x7fff0100>
    80006db6:	8f75                	and	a4,a4,a3
    80006db8:	8fd9                	or	a5,a5,a4
    80006dba:	2781                	sext.w	a5,a5
    80006dbc:	0a000737          	lui	a4,0xa000
    80006dc0:	20f70713          	addi	a4,a4,527 # a00020f <_entry-0x75fffdf1>
    80006dc4:	f8e79de3          	bne	a5,a4,80006d5e <net_rx+0x8e>
  if (iphdr->ip_p != IPPROTO_UDP)
    80006dc8:	00994703          	lbu	a4,9(s2)
    80006dcc:	47c5                	li	a5,17
    80006dce:	f8f718e3          	bne	a4,a5,80006d5e <net_rx+0x8e>
  return (((val & 0x00ffU) << 8) |
    80006dd2:	00295783          	lhu	a5,2(s2)
    80006dd6:	0087999b          	slliw	s3,a5,0x8
    80006dda:	0107979b          	slliw	a5,a5,0x10
    80006dde:	0107d79b          	srliw	a5,a5,0x10
    80006de2:	0087d79b          	srliw	a5,a5,0x8
    80006de6:	00f9e7b3          	or	a5,s3,a5
    80006dea:	03079993          	slli	s3,a5,0x30
    80006dee:	0309d993          	srli	s3,s3,0x30
  len = ntohs(iphdr->ip_len) - sizeof(*iphdr);
    80006df2:	fec9879b          	addiw	a5,s3,-20
    80006df6:	03079a13          	slli	s4,a5,0x30
    80006dfa:	030a5a13          	srli	s4,s4,0x30
  udphdr = mbufpullhdr(m, *udphdr);
    80006dfe:	45a1                	li	a1,8
    80006e00:	8526                	mv	a0,s1
    80006e02:	00000097          	auipc	ra,0x0
    80006e06:	bca080e7          	jalr	-1078(ra) # 800069cc <mbufpull>
    80006e0a:	8aaa                	mv	s5,a0
  if (!udphdr)
    80006e0c:	cd0d                	beqz	a0,80006e46 <net_rx+0x176>
    80006e0e:	00455783          	lhu	a5,4(a0)
    80006e12:	0087971b          	slliw	a4,a5,0x8
    80006e16:	0107979b          	slliw	a5,a5,0x10
    80006e1a:	0107d79b          	srliw	a5,a5,0x10
    80006e1e:	0087d79b          	srliw	a5,a5,0x8
    80006e22:	8f5d                	or	a4,a4,a5
  if (ntohs(udphdr->ulen) != len)
    80006e24:	000a079b          	sext.w	a5,s4
    80006e28:	1742                	slli	a4,a4,0x30
    80006e2a:	9341                	srli	a4,a4,0x30
    80006e2c:	00e79d63          	bne	a5,a4,80006e46 <net_rx+0x176>
  len -= sizeof(*udphdr);
    80006e30:	fe49879b          	addiw	a5,s3,-28
  if (len > m->len)
    80006e34:	0107979b          	slliw	a5,a5,0x10
    80006e38:	0107d79b          	srliw	a5,a5,0x10
    80006e3c:	0007871b          	sext.w	a4,a5
    80006e40:	488c                	lw	a1,16(s1)
    80006e42:	00e5f863          	bgeu	a1,a4,80006e52 <net_rx+0x182>
  kfree(m);
    80006e46:	8526                	mv	a0,s1
    80006e48:	ffffa097          	auipc	ra,0xffffa
    80006e4c:	a28080e7          	jalr	-1496(ra) # 80000870 <kfree>
}
    80006e50:	bdd1                	j	80006d24 <net_rx+0x54>
  mbuftrim(m, m->len - len);
    80006e52:	9d9d                	subw	a1,a1,a5
    80006e54:	8526                	mv	a0,s1
    80006e56:	00000097          	auipc	ra,0x0
    80006e5a:	c84080e7          	jalr	-892(ra) # 80006ada <mbuftrim>
  sip = ntohl(iphdr->ip_src);
    80006e5e:	00c92783          	lw	a5,12(s2)
    80006e62:	000ad703          	lhu	a4,0(s5)
    80006e66:	0087169b          	slliw	a3,a4,0x8
    80006e6a:	0107171b          	slliw	a4,a4,0x10
    80006e6e:	0107571b          	srliw	a4,a4,0x10
    80006e72:	0087571b          	srliw	a4,a4,0x8
    80006e76:	8ed9                	or	a3,a3,a4
    80006e78:	002ad703          	lhu	a4,2(s5)
    80006e7c:	0087161b          	slliw	a2,a4,0x8
    80006e80:	0107171b          	slliw	a4,a4,0x10
    80006e84:	0107571b          	srliw	a4,a4,0x10
    80006e88:	0087571b          	srliw	a4,a4,0x8
    80006e8c:	8e59                	or	a2,a2,a4
  return (((val & 0x000000ffUL) << 24) |
    80006e8e:	0187971b          	slliw	a4,a5,0x18
          ((val & 0xff000000UL) >> 24));
    80006e92:	0187d59b          	srliw	a1,a5,0x18
          ((val & 0x00ff0000UL) >> 8) |
    80006e96:	8f4d                	or	a4,a4,a1
          ((val & 0x0000ff00UL) << 8) |
    80006e98:	0087959b          	slliw	a1,a5,0x8
    80006e9c:	00ff0537          	lui	a0,0xff0
    80006ea0:	8de9                	and	a1,a1,a0
          ((val & 0x00ff0000UL) >> 8) |
    80006ea2:	8f4d                	or	a4,a4,a1
    80006ea4:	0087d79b          	srliw	a5,a5,0x8
    80006ea8:	65c1                	lui	a1,0x10
    80006eaa:	f0058593          	addi	a1,a1,-256 # ff00 <_entry-0x7fff0100>
    80006eae:	8fed                	and	a5,a5,a1
    80006eb0:	8fd9                	or	a5,a5,a4
  sockrecvudp(m, sip, dport, sport);
    80006eb2:	16c2                	slli	a3,a3,0x30
    80006eb4:	92c1                	srli	a3,a3,0x30
    80006eb6:	1642                	slli	a2,a2,0x30
    80006eb8:	9241                	srli	a2,a2,0x30
    80006eba:	0007859b          	sext.w	a1,a5
    80006ebe:	8526                	mv	a0,s1
    80006ec0:	00000097          	auipc	ra,0x0
    80006ec4:	368080e7          	jalr	872(ra) # 80007228 <sockrecvudp>
  return;
    80006ec8:	bdb1                	j	80006d24 <net_rx+0x54>
  arphdr = mbufpullhdr(m, *arphdr);
    80006eca:	45f1                	li	a1,28
    80006ecc:	8526                	mv	a0,s1
    80006ece:	00000097          	auipc	ra,0x0
    80006ed2:	afe080e7          	jalr	-1282(ra) # 800069cc <mbufpull>
    80006ed6:	892a                	mv	s2,a0
  if (!arphdr)
    80006ed8:	c179                	beqz	a0,80006f9e <net_rx+0x2ce>
  if (ntohs(arphdr->hrd) != ARP_HRD_ETHER ||
    80006eda:	00054703          	lbu	a4,0(a0) # ff0000 <_entry-0x7f010000>
    80006ede:	00154783          	lbu	a5,1(a0)
    80006ee2:	07a2                	slli	a5,a5,0x8
    80006ee4:	8fd9                	or	a5,a5,a4
  return (((val & 0x00ffU) << 8) |
    80006ee6:	0087971b          	slliw	a4,a5,0x8
    80006eea:	83a1                	srli	a5,a5,0x8
    80006eec:	8fd9                	or	a5,a5,a4
    80006eee:	17c2                	slli	a5,a5,0x30
    80006ef0:	93c1                	srli	a5,a5,0x30
    80006ef2:	4705                	li	a4,1
    80006ef4:	0ae79563          	bne	a5,a4,80006f9e <net_rx+0x2ce>
      ntohs(arphdr->pro) != ETHTYPE_IP ||
    80006ef8:	00254703          	lbu	a4,2(a0)
    80006efc:	00354783          	lbu	a5,3(a0)
    80006f00:	07a2                	slli	a5,a5,0x8
    80006f02:	8fd9                	or	a5,a5,a4
    80006f04:	0087971b          	slliw	a4,a5,0x8
    80006f08:	83a1                	srli	a5,a5,0x8
    80006f0a:	8fd9                	or	a5,a5,a4
  if (ntohs(arphdr->hrd) != ARP_HRD_ETHER ||
    80006f0c:	0107979b          	slliw	a5,a5,0x10
    80006f10:	0107d79b          	srliw	a5,a5,0x10
    80006f14:	8007879b          	addiw	a5,a5,-2048
    80006f18:	e3d9                	bnez	a5,80006f9e <net_rx+0x2ce>
      ntohs(arphdr->pro) != ETHTYPE_IP ||
    80006f1a:	00454703          	lbu	a4,4(a0)
    80006f1e:	4799                	li	a5,6
    80006f20:	06f71f63          	bne	a4,a5,80006f9e <net_rx+0x2ce>
      arphdr->hln != ETHADDR_LEN ||
    80006f24:	00554703          	lbu	a4,5(a0)
    80006f28:	4791                	li	a5,4
    80006f2a:	06f71a63          	bne	a4,a5,80006f9e <net_rx+0x2ce>
  if (ntohs(arphdr->op) != ARP_OP_REQUEST || tip != local_ip)
    80006f2e:	00654703          	lbu	a4,6(a0)
    80006f32:	00754783          	lbu	a5,7(a0)
    80006f36:	07a2                	slli	a5,a5,0x8
    80006f38:	8fd9                	or	a5,a5,a4
    80006f3a:	0087971b          	slliw	a4,a5,0x8
    80006f3e:	83a1                	srli	a5,a5,0x8
    80006f40:	8fd9                	or	a5,a5,a4
    80006f42:	17c2                	slli	a5,a5,0x30
    80006f44:	93c1                	srli	a5,a5,0x30
    80006f46:	4705                	li	a4,1
    80006f48:	04e79b63          	bne	a5,a4,80006f9e <net_rx+0x2ce>
  tip = ntohl(arphdr->tip); // target IP address
    80006f4c:	01854783          	lbu	a5,24(a0)
    80006f50:	01954703          	lbu	a4,25(a0)
    80006f54:	0722                	slli	a4,a4,0x8
    80006f56:	8f5d                	or	a4,a4,a5
    80006f58:	01a54783          	lbu	a5,26(a0)
    80006f5c:	07c2                	slli	a5,a5,0x10
    80006f5e:	8f5d                	or	a4,a4,a5
    80006f60:	01b54783          	lbu	a5,27(a0)
    80006f64:	07e2                	slli	a5,a5,0x18
    80006f66:	8fd9                	or	a5,a5,a4
    80006f68:	0007871b          	sext.w	a4,a5
  return (((val & 0x000000ffUL) << 24) |
    80006f6c:	0187979b          	slliw	a5,a5,0x18
          ((val & 0xff000000UL) >> 24));
    80006f70:	0187569b          	srliw	a3,a4,0x18
          ((val & 0x00ff0000UL) >> 8) |
    80006f74:	8fd5                	or	a5,a5,a3
          ((val & 0x0000ff00UL) << 8) |
    80006f76:	0087169b          	slliw	a3,a4,0x8
    80006f7a:	00ff0637          	lui	a2,0xff0
    80006f7e:	8ef1                	and	a3,a3,a2
          ((val & 0x00ff0000UL) >> 8) |
    80006f80:	8fd5                	or	a5,a5,a3
    80006f82:	0087571b          	srliw	a4,a4,0x8
    80006f86:	66c1                	lui	a3,0x10
    80006f88:	f0068693          	addi	a3,a3,-256 # ff00 <_entry-0x7fff0100>
    80006f8c:	8f75                	and	a4,a4,a3
    80006f8e:	8fd9                	or	a5,a5,a4
  if (ntohs(arphdr->op) != ARP_OP_REQUEST || tip != local_ip)
    80006f90:	2781                	sext.w	a5,a5
    80006f92:	0a000737          	lui	a4,0xa000
    80006f96:	20f70713          	addi	a4,a4,527 # a00020f <_entry-0x75fffdf1>
    80006f9a:	00e78863          	beq	a5,a4,80006faa <net_rx+0x2da>
  kfree(m);
    80006f9e:	8526                	mv	a0,s1
    80006fa0:	ffffa097          	auipc	ra,0xffffa
    80006fa4:	8d0080e7          	jalr	-1840(ra) # 80000870 <kfree>
}
    80006fa8:	bbb5                	j	80006d24 <net_rx+0x54>
  memmove(smac, arphdr->sha, ETHADDR_LEN); // sender's ethernet address
    80006faa:	4619                	li	a2,6
    80006fac:	00850593          	addi	a1,a0,8
    80006fb0:	fb840513          	addi	a0,s0,-72
    80006fb4:	ffffa097          	auipc	ra,0xffffa
    80006fb8:	e16080e7          	jalr	-490(ra) # 80000dca <memmove>
  sip = ntohl(arphdr->sip); // sender's IP address (qemu's slirp)
    80006fbc:	00e94783          	lbu	a5,14(s2)
    80006fc0:	00f94703          	lbu	a4,15(s2)
    80006fc4:	0722                	slli	a4,a4,0x8
    80006fc6:	8f5d                	or	a4,a4,a5
    80006fc8:	01094783          	lbu	a5,16(s2)
    80006fcc:	07c2                	slli	a5,a5,0x10
    80006fce:	8f5d                	or	a4,a4,a5
    80006fd0:	01194783          	lbu	a5,17(s2)
    80006fd4:	07e2                	slli	a5,a5,0x18
    80006fd6:	8fd9                	or	a5,a5,a4
    80006fd8:	0007871b          	sext.w	a4,a5
  return (((val & 0x000000ffUL) << 24) |
    80006fdc:	0187991b          	slliw	s2,a5,0x18
          ((val & 0xff000000UL) >> 24));
    80006fe0:	0187579b          	srliw	a5,a4,0x18
          ((val & 0x00ff0000UL) >> 8) |
    80006fe4:	00f96933          	or	s2,s2,a5
          ((val & 0x0000ff00UL) << 8) |
    80006fe8:	0087179b          	slliw	a5,a4,0x8
    80006fec:	00ff06b7          	lui	a3,0xff0
    80006ff0:	8ff5                	and	a5,a5,a3
          ((val & 0x00ff0000UL) >> 8) |
    80006ff2:	00f96933          	or	s2,s2,a5
    80006ff6:	0087579b          	srliw	a5,a4,0x8
    80006ffa:	6741                	lui	a4,0x10
    80006ffc:	f0070713          	addi	a4,a4,-256 # ff00 <_entry-0x7fff0100>
    80007000:	8ff9                	and	a5,a5,a4
    80007002:	00f96933          	or	s2,s2,a5
    80007006:	2901                	sext.w	s2,s2
  m = mbufalloc(MBUF_DEFAULT_HEADROOM);
    80007008:	08000513          	li	a0,128
    8000700c:	00000097          	auipc	ra,0x0
    80007010:	af0080e7          	jalr	-1296(ra) # 80006afc <mbufalloc>
    80007014:	8a2a                	mv	s4,a0
  if (!m)
    80007016:	d541                	beqz	a0,80006f9e <net_rx+0x2ce>
  arphdr = mbufputhdr(m, *arphdr);
    80007018:	45f1                	li	a1,28
    8000701a:	00000097          	auipc	ra,0x0
    8000701e:	a86080e7          	jalr	-1402(ra) # 80006aa0 <mbufput>
    80007022:	89aa                	mv	s3,a0
  arphdr->hrd = htons(ARP_HRD_ETHER);
    80007024:	00050023          	sb	zero,0(a0)
    80007028:	4785                	li	a5,1
    8000702a:	00f500a3          	sb	a5,1(a0)
  arphdr->pro = htons(ETHTYPE_IP);
    8000702e:	47a1                	li	a5,8
    80007030:	00f50123          	sb	a5,2(a0)
    80007034:	000501a3          	sb	zero,3(a0)
  arphdr->hln = ETHADDR_LEN;
    80007038:	4799                	li	a5,6
    8000703a:	00f50223          	sb	a5,4(a0)
  arphdr->pln = sizeof(uint32);
    8000703e:	4791                	li	a5,4
    80007040:	00f502a3          	sb	a5,5(a0)
  arphdr->op = htons(op);
    80007044:	00050323          	sb	zero,6(a0)
    80007048:	4a89                	li	s5,2
    8000704a:	015503a3          	sb	s5,7(a0)
  memmove(arphdr->sha, local_mac, ETHADDR_LEN);
    8000704e:	4619                	li	a2,6
    80007050:	00003597          	auipc	a1,0x3
    80007054:	ff858593          	addi	a1,a1,-8 # 8000a048 <local_mac>
    80007058:	0521                	addi	a0,a0,8
    8000705a:	ffffa097          	auipc	ra,0xffffa
    8000705e:	d70080e7          	jalr	-656(ra) # 80000dca <memmove>
  arphdr->sip = htonl(local_ip);
    80007062:	47a9                	li	a5,10
    80007064:	00f98723          	sb	a5,14(s3)
    80007068:	000987a3          	sb	zero,15(s3)
    8000706c:	01598823          	sb	s5,16(s3)
    80007070:	47bd                	li	a5,15
    80007072:	00f988a3          	sb	a5,17(s3)
  memmove(arphdr->tha, dmac, ETHADDR_LEN);
    80007076:	4619                	li	a2,6
    80007078:	fb840593          	addi	a1,s0,-72
    8000707c:	01298513          	addi	a0,s3,18
    80007080:	ffffa097          	auipc	ra,0xffffa
    80007084:	d4a080e7          	jalr	-694(ra) # 80000dca <memmove>
  return (((val & 0x000000ffUL) << 24) |
    80007088:	0189171b          	slliw	a4,s2,0x18
          ((val & 0xff000000UL) >> 24));
    8000708c:	0189579b          	srliw	a5,s2,0x18
          ((val & 0x00ff0000UL) >> 8) |
    80007090:	8f5d                	or	a4,a4,a5
          ((val & 0x0000ff00UL) << 8) |
    80007092:	0089179b          	slliw	a5,s2,0x8
    80007096:	00ff06b7          	lui	a3,0xff0
    8000709a:	8ff5                	and	a5,a5,a3
          ((val & 0x00ff0000UL) >> 8) |
    8000709c:	8f5d                	or	a4,a4,a5
    8000709e:	0089579b          	srliw	a5,s2,0x8
    800070a2:	66c1                	lui	a3,0x10
    800070a4:	f0068693          	addi	a3,a3,-256 # ff00 <_entry-0x7fff0100>
    800070a8:	8ff5                	and	a5,a5,a3
    800070aa:	8fd9                	or	a5,a5,a4
  arphdr->tip = htonl(dip);
    800070ac:	00e98c23          	sb	a4,24(s3)
    800070b0:	0087d71b          	srliw	a4,a5,0x8
    800070b4:	00e98ca3          	sb	a4,25(s3)
    800070b8:	0107d71b          	srliw	a4,a5,0x10
    800070bc:	00e98d23          	sb	a4,26(s3)
    800070c0:	0187d79b          	srliw	a5,a5,0x18
    800070c4:	00f98da3          	sb	a5,27(s3)
  net_tx_eth(m, ETHTYPE_ARP);
    800070c8:	6585                	lui	a1,0x1
    800070ca:	80658593          	addi	a1,a1,-2042 # 806 <_entry-0x7ffff7fa>
    800070ce:	8552                	mv	a0,s4
    800070d0:	00000097          	auipc	ra,0x0
    800070d4:	958080e7          	jalr	-1704(ra) # 80006a28 <net_tx_eth>
  return 0;
    800070d8:	b5d9                	j	80006f9e <net_rx+0x2ce>

00000000800070da <sockinit>:
static struct spinlock lock;
static struct sock *sockets;

void
sockinit(void)
{
    800070da:	1141                	addi	sp,sp,-16
    800070dc:	e406                	sd	ra,8(sp)
    800070de:	e022                	sd	s0,0(sp)
    800070e0:	0800                	addi	s0,sp,16
  initlock(&lock, "socktbl");
    800070e2:	00003597          	auipc	a1,0x3
    800070e6:	b3658593          	addi	a1,a1,-1226 # 80009c18 <userret+0xb88>
    800070ea:	00022517          	auipc	a0,0x22
    800070ee:	23650513          	addi	a0,a0,566 # 80029320 <lock>
    800070f2:	ffffa097          	auipc	ra,0xffffa
    800070f6:	8da080e7          	jalr	-1830(ra) # 800009cc <initlock>
}
    800070fa:	60a2                	ld	ra,8(sp)
    800070fc:	6402                	ld	s0,0(sp)
    800070fe:	0141                	addi	sp,sp,16
    80007100:	8082                	ret

0000000080007102 <sockalloc>:

int
sockalloc(struct file **f, uint32 raddr, uint16 lport, uint16 rport)
{
    80007102:	7139                	addi	sp,sp,-64
    80007104:	fc06                	sd	ra,56(sp)
    80007106:	f822                	sd	s0,48(sp)
    80007108:	f426                	sd	s1,40(sp)
    8000710a:	f04a                	sd	s2,32(sp)
    8000710c:	ec4e                	sd	s3,24(sp)
    8000710e:	e852                	sd	s4,16(sp)
    80007110:	e456                	sd	s5,8(sp)
    80007112:	0080                	addi	s0,sp,64
    80007114:	892a                	mv	s2,a0
    80007116:	84ae                	mv	s1,a1
    80007118:	8a32                	mv	s4,a2
    8000711a:	89b6                	mv	s3,a3
  struct sock *si, *pos;

  si = 0;
  *f = 0;
    8000711c:	00053023          	sd	zero,0(a0)
  if ((*f = filealloc()) == 0)
    80007120:	ffffd097          	auipc	ra,0xffffd
    80007124:	4d0080e7          	jalr	1232(ra) # 800045f0 <filealloc>
    80007128:	00a93023          	sd	a0,0(s2)
    8000712c:	c975                	beqz	a0,80007220 <sockalloc+0x11e>
    goto bad;
  if ((si = (struct sock*)kalloc()) == 0)
    8000712e:	ffffa097          	auipc	ra,0xffffa
    80007132:	83e080e7          	jalr	-1986(ra) # 8000096c <kalloc>
    80007136:	8aaa                	mv	s5,a0
    80007138:	c15d                	beqz	a0,800071de <sockalloc+0xdc>
    goto bad;

  // initialize objects
  si->raddr = raddr;
    8000713a:	c504                	sw	s1,8(a0)
  si->lport = lport;
    8000713c:	01451623          	sh	s4,12(a0)
  si->rport = rport;
    80007140:	01351723          	sh	s3,14(a0)
  initlock(&si->lock, "sock");
    80007144:	00003597          	auipc	a1,0x3
    80007148:	adc58593          	addi	a1,a1,-1316 # 80009c20 <userret+0xb90>
    8000714c:	0541                	addi	a0,a0,16
    8000714e:	ffffa097          	auipc	ra,0xffffa
    80007152:	87e080e7          	jalr	-1922(ra) # 800009cc <initlock>
  mbufq_init(&si->rxq);
    80007156:	030a8513          	addi	a0,s5,48
    8000715a:	00000097          	auipc	ra,0x0
    8000715e:	a5a080e7          	jalr	-1446(ra) # 80006bb4 <mbufq_init>
  (*f)->type = FD_SOCK;
    80007162:	00093783          	ld	a5,0(s2)
    80007166:	4711                	li	a4,4
    80007168:	c398                	sw	a4,0(a5)
  (*f)->readable = 1;
    8000716a:	00093703          	ld	a4,0(s2)
    8000716e:	4785                	li	a5,1
    80007170:	00f70423          	sb	a5,8(a4)
  (*f)->writable = 1;
    80007174:	00093703          	ld	a4,0(s2)
    80007178:	00f704a3          	sb	a5,9(a4)
  (*f)->sock = si;
    8000717c:	00093783          	ld	a5,0(s2)
    80007180:	0357b423          	sd	s5,40(a5) # f020028 <_entry-0x70fdffd8>

  // add to list of sockets
  acquire(&lock);
    80007184:	00022517          	auipc	a0,0x22
    80007188:	19c50513          	addi	a0,a0,412 # 80029320 <lock>
    8000718c:	ffffa097          	auipc	ra,0xffffa
    80007190:	914080e7          	jalr	-1772(ra) # 80000aa0 <acquire>
  pos = sockets;
    80007194:	00022597          	auipc	a1,0x22
    80007198:	1fc5b583          	ld	a1,508(a1) # 80029390 <sockets>
  while (pos) {
    8000719c:	c9b1                	beqz	a1,800071f0 <sockalloc+0xee>
  pos = sockets;
    8000719e:	87ae                	mv	a5,a1
    if (pos->raddr == raddr &&
    800071a0:	000a061b          	sext.w	a2,s4
        pos->lport == lport &&
    800071a4:	0009869b          	sext.w	a3,s3
    800071a8:	a019                	j	800071ae <sockalloc+0xac>
	pos->rport == rport) {
      release(&lock);
      goto bad;
    }
    pos = pos->next;
    800071aa:	639c                	ld	a5,0(a5)
  while (pos) {
    800071ac:	c3b1                	beqz	a5,800071f0 <sockalloc+0xee>
    if (pos->raddr == raddr &&
    800071ae:	4798                	lw	a4,8(a5)
    800071b0:	fe971de3          	bne	a4,s1,800071aa <sockalloc+0xa8>
    800071b4:	00c7d703          	lhu	a4,12(a5)
    800071b8:	fec719e3          	bne	a4,a2,800071aa <sockalloc+0xa8>
        pos->lport == lport &&
    800071bc:	00e7d703          	lhu	a4,14(a5)
    800071c0:	fed715e3          	bne	a4,a3,800071aa <sockalloc+0xa8>
      release(&lock);
    800071c4:	00022517          	auipc	a0,0x22
    800071c8:	15c50513          	addi	a0,a0,348 # 80029320 <lock>
    800071cc:	ffffa097          	auipc	ra,0xffffa
    800071d0:	9a4080e7          	jalr	-1628(ra) # 80000b70 <release>
  release(&lock);
  return 0;

bad:
  if (si)
    kfree((char*)si);
    800071d4:	8556                	mv	a0,s5
    800071d6:	ffff9097          	auipc	ra,0xffff9
    800071da:	69a080e7          	jalr	1690(ra) # 80000870 <kfree>
  if (*f)
    800071de:	00093503          	ld	a0,0(s2)
    800071e2:	c129                	beqz	a0,80007224 <sockalloc+0x122>
    fileclose(*f);
    800071e4:	ffffd097          	auipc	ra,0xffffd
    800071e8:	4c8080e7          	jalr	1224(ra) # 800046ac <fileclose>
  return -1;
    800071ec:	557d                	li	a0,-1
    800071ee:	a005                	j	8000720e <sockalloc+0x10c>
  si->next = sockets;
    800071f0:	00bab023          	sd	a1,0(s5)
  sockets = si;
    800071f4:	00022797          	auipc	a5,0x22
    800071f8:	1957be23          	sd	s5,412(a5) # 80029390 <sockets>
  release(&lock);
    800071fc:	00022517          	auipc	a0,0x22
    80007200:	12450513          	addi	a0,a0,292 # 80029320 <lock>
    80007204:	ffffa097          	auipc	ra,0xffffa
    80007208:	96c080e7          	jalr	-1684(ra) # 80000b70 <release>
  return 0;
    8000720c:	4501                	li	a0,0
}
    8000720e:	70e2                	ld	ra,56(sp)
    80007210:	7442                	ld	s0,48(sp)
    80007212:	74a2                	ld	s1,40(sp)
    80007214:	7902                	ld	s2,32(sp)
    80007216:	69e2                	ld	s3,24(sp)
    80007218:	6a42                	ld	s4,16(sp)
    8000721a:	6aa2                	ld	s5,8(sp)
    8000721c:	6121                	addi	sp,sp,64
    8000721e:	8082                	ret
  return -1;
    80007220:	557d                	li	a0,-1
    80007222:	b7f5                	j	8000720e <sockalloc+0x10c>
    80007224:	557d                	li	a0,-1
    80007226:	b7e5                	j	8000720e <sockalloc+0x10c>

0000000080007228 <sockrecvudp>:
//

// called by protocol handler layer to deliver UDP packets
void
sockrecvudp(struct mbuf *m, uint32 raddr, uint16 lport, uint16 rport)
{
    80007228:	7179                	addi	sp,sp,-48
    8000722a:	f406                	sd	ra,40(sp)
    8000722c:	f022                	sd	s0,32(sp)
    8000722e:	ec26                	sd	s1,24(sp)
    80007230:	e84a                	sd	s2,16(sp)
    80007232:	e44e                	sd	s3,8(sp)
    80007234:	e052                	sd	s4,0(sp)
    80007236:	1800                	addi	s0,sp,48
    80007238:	89aa                	mv	s3,a0
    8000723a:	84ae                	mv	s1,a1
    8000723c:	8932                	mv	s2,a2
    8000723e:	8a36                	mv	s4,a3
  acquire(&lock);
    80007240:	00022517          	auipc	a0,0x22
    80007244:	0e050513          	addi	a0,a0,224 # 80029320 <lock>
    80007248:	ffffa097          	auipc	ra,0xffffa
    8000724c:	858080e7          	jalr	-1960(ra) # 80000aa0 <acquire>
  
  struct sock *s;
  for(s = sockets; s; s = s->next) {
    80007250:	00022797          	auipc	a5,0x22
    80007254:	1407b783          	ld	a5,320(a5) # 80029390 <sockets>
    80007258:	cba9                	beqz	a5,800072aa <sockrecvudp+0x82>
    if(s->raddr == raddr && s->lport == lport && s->rport == rport) {
    8000725a:	0009061b          	sext.w	a2,s2
    8000725e:	000a069b          	sext.w	a3,s4
    80007262:	a019                	j	80007268 <sockrecvudp+0x40>
  for(s = sockets; s; s = s->next) {
    80007264:	639c                	ld	a5,0(a5)
    80007266:	c3b1                	beqz	a5,800072aa <sockrecvudp+0x82>
    if(s->raddr == raddr && s->lport == lport && s->rport == rport) {
    80007268:	4798                	lw	a4,8(a5)
    8000726a:	fe971de3          	bne	a4,s1,80007264 <sockrecvudp+0x3c>
    8000726e:	00c7d703          	lhu	a4,12(a5)
    80007272:	fec719e3          	bne	a4,a2,80007264 <sockrecvudp+0x3c>
    80007276:	00e7d703          	lhu	a4,14(a5)
    8000727a:	fed715e3          	bne	a4,a3,80007264 <sockrecvudp+0x3c>
      // 正确的 mbuf 入队操作
      mbufq_pushtail(&s->rxq, m);  // 使用 pushtail 而不是 push
    8000727e:	03078493          	addi	s1,a5,48
    80007282:	85ce                	mv	a1,s3
    80007284:	8526                	mv	a0,s1
    80007286:	00000097          	auipc	ra,0x0
    8000728a:	8e6080e7          	jalr	-1818(ra) # 80006b6c <mbufq_pushtail>
      wakeup(&s->rxq);
    8000728e:	8526                	mv	a0,s1
    80007290:	ffffb097          	auipc	ra,0xffffb
    80007294:	144080e7          	jalr	324(ra) # 800023d4 <wakeup>
      release(&lock);
    80007298:	00022517          	auipc	a0,0x22
    8000729c:	08850513          	addi	a0,a0,136 # 80029320 <lock>
    800072a0:	ffffa097          	auipc	ra,0xffffa
    800072a4:	8d0080e7          	jalr	-1840(ra) # 80000b70 <release>
      return;
    800072a8:	a831                	j	800072c4 <sockrecvudp+0x9c>
    }
  }
  
  release(&lock);
    800072aa:	00022517          	auipc	a0,0x22
    800072ae:	07650513          	addi	a0,a0,118 # 80029320 <lock>
    800072b2:	ffffa097          	auipc	ra,0xffffa
    800072b6:	8be080e7          	jalr	-1858(ra) # 80000b70 <release>
  mbuffree(m);  // 没有匹配的 socket，释放 mbuf
    800072ba:	854e                	mv	a0,s3
    800072bc:	00000097          	auipc	ra,0x0
    800072c0:	898080e7          	jalr	-1896(ra) # 80006b54 <mbuffree>
}
    800072c4:	70a2                	ld	ra,40(sp)
    800072c6:	7402                	ld	s0,32(sp)
    800072c8:	64e2                	ld	s1,24(sp)
    800072ca:	6942                	ld	s2,16(sp)
    800072cc:	69a2                	ld	s3,8(sp)
    800072ce:	6a02                	ld	s4,0(sp)
    800072d0:	6145                	addi	sp,sp,48
    800072d2:	8082                	ret

00000000800072d4 <sockread>:

int
sockread(struct sock *s, uint64 addr, int n)
{
    800072d4:	7139                	addi	sp,sp,-64
    800072d6:	fc06                	sd	ra,56(sp)
    800072d8:	f822                	sd	s0,48(sp)
    800072da:	f426                	sd	s1,40(sp)
    800072dc:	f04a                	sd	s2,32(sp)
    800072de:	ec4e                	sd	s3,24(sp)
    800072e0:	e852                	sd	s4,16(sp)
    800072e2:	e456                	sd	s5,8(sp)
    800072e4:	0080                	addi	s0,sp,64
    800072e6:	84aa                	mv	s1,a0
    800072e8:	89ae                	mv	s3,a1
    800072ea:	8ab2                	mv	s5,a2
  struct mbuf *m;
  
  acquire(&s->lock);
    800072ec:	01050913          	addi	s2,a0,16
    800072f0:	854a                	mv	a0,s2
    800072f2:	ffff9097          	auipc	ra,0xffff9
    800072f6:	7ae080e7          	jalr	1966(ra) # 80000aa0 <acquire>
  while(mbufq_empty(&s->rxq)) {
    800072fa:	03048493          	addi	s1,s1,48
    800072fe:	a039                	j	8000730c <sockread+0x38>
    if(myproc()->killed) {
      release(&s->lock);
      return -1;
    }
    sleep(&s->rxq, &s->lock);
    80007300:	85ca                	mv	a1,s2
    80007302:	8526                	mv	a0,s1
    80007304:	ffffb097          	auipc	ra,0xffffb
    80007308:	f50080e7          	jalr	-176(ra) # 80002254 <sleep>
  while(mbufq_empty(&s->rxq)) {
    8000730c:	8526                	mv	a0,s1
    8000730e:	00000097          	auipc	ra,0x0
    80007312:	894080e7          	jalr	-1900(ra) # 80006ba2 <mbufq_empty>
    80007316:	cd11                	beqz	a0,80007332 <sockread+0x5e>
    if(myproc()->killed) {
    80007318:	ffffa097          	auipc	ra,0xffffa
    8000731c:	77c080e7          	jalr	1916(ra) # 80001a94 <myproc>
    80007320:	5d1c                	lw	a5,56(a0)
    80007322:	dff9                	beqz	a5,80007300 <sockread+0x2c>
      release(&s->lock);
    80007324:	854a                	mv	a0,s2
    80007326:	ffffa097          	auipc	ra,0xffffa
    8000732a:	84a080e7          	jalr	-1974(ra) # 80000b70 <release>
      return -1;
    8000732e:	54fd                	li	s1,-1
    80007330:	a889                	j	80007382 <sockread+0xae>
  }
  
  // 正确的 mbuf 出队操作
  m = mbufq_pophead(&s->rxq);
    80007332:	8526                	mv	a0,s1
    80007334:	00000097          	auipc	ra,0x0
    80007338:	858080e7          	jalr	-1960(ra) # 80006b8c <mbufq_pophead>
    8000733c:	8a2a                	mv	s4,a0
  release(&s->lock);
    8000733e:	854a                	mv	a0,s2
    80007340:	ffffa097          	auipc	ra,0xffffa
    80007344:	830080e7          	jalr	-2000(ra) # 80000b70 <release>
  
  int len = m->len;
    80007348:	010a2783          	lw	a5,16(s4)
  if(len > n) {
    8000734c:	84be                	mv	s1,a5
    8000734e:	00fad363          	bge	s5,a5,80007354 <sockread+0x80>
    80007352:	84d6                	mv	s1,s5
    80007354:	2481                	sext.w	s1,s1
    len = n;
  }
  
  if(copyout(myproc()->pagetable, addr, m->head, len) == -1) {
    80007356:	ffffa097          	auipc	ra,0xffffa
    8000735a:	73e080e7          	jalr	1854(ra) # 80001a94 <myproc>
    8000735e:	86a6                	mv	a3,s1
    80007360:	008a3603          	ld	a2,8(s4)
    80007364:	85ce                	mv	a1,s3
    80007366:	6d28                	ld	a0,88(a0)
    80007368:	ffffa097          	auipc	ra,0xffffa
    8000736c:	41e080e7          	jalr	1054(ra) # 80001786 <copyout>
    80007370:	892a                	mv	s2,a0
    80007372:	57fd                	li	a5,-1
    80007374:	02f50163          	beq	a0,a5,80007396 <sockread+0xc2>
    mbuffree(m);
    return -1;
  }
  
  mbuffree(m);
    80007378:	8552                	mv	a0,s4
    8000737a:	fffff097          	auipc	ra,0xfffff
    8000737e:	7da080e7          	jalr	2010(ra) # 80006b54 <mbuffree>
  return len;
}
    80007382:	8526                	mv	a0,s1
    80007384:	70e2                	ld	ra,56(sp)
    80007386:	7442                	ld	s0,48(sp)
    80007388:	74a2                	ld	s1,40(sp)
    8000738a:	7902                	ld	s2,32(sp)
    8000738c:	69e2                	ld	s3,24(sp)
    8000738e:	6a42                	ld	s4,16(sp)
    80007390:	6aa2                	ld	s5,8(sp)
    80007392:	6121                	addi	sp,sp,64
    80007394:	8082                	ret
    mbuffree(m);
    80007396:	8552                	mv	a0,s4
    80007398:	fffff097          	auipc	ra,0xfffff
    8000739c:	7bc080e7          	jalr	1980(ra) # 80006b54 <mbuffree>
    return -1;
    800073a0:	84ca                	mv	s1,s2
    800073a2:	b7c5                	j	80007382 <sockread+0xae>

00000000800073a4 <sockwrite>:

// 套接字写操作
int
sockwrite(struct sock *s, uint64 addr, int n)
{
    800073a4:	7179                	addi	sp,sp,-48
    800073a6:	f406                	sd	ra,40(sp)
    800073a8:	f022                	sd	s0,32(sp)
    800073aa:	ec26                	sd	s1,24(sp)
    800073ac:	e84a                	sd	s2,16(sp)
    800073ae:	e44e                	sd	s3,8(sp)
    800073b0:	e052                	sd	s4,0(sp)
    800073b2:	1800                	addi	s0,sp,48
    800073b4:	89aa                	mv	s3,a0
    800073b6:	8a2e                	mv	s4,a1
    800073b8:	8932                	mv	s2,a2
  struct mbuf *m = mbufalloc(MBUF_DEFAULT_HEADROOM);
    800073ba:	08000513          	li	a0,128
    800073be:	fffff097          	auipc	ra,0xfffff
    800073c2:	73e080e7          	jalr	1854(ra) # 80006afc <mbufalloc>
  if(!m) {
    800073c6:	c135                	beqz	a0,8000742a <sockwrite+0x86>
    800073c8:	84aa                	mv	s1,a0
    return -1;
  }

  mbufput(m, n);
    800073ca:	85ca                	mv	a1,s2
    800073cc:	fffff097          	auipc	ra,0xfffff
    800073d0:	6d4080e7          	jalr	1748(ra) # 80006aa0 <mbufput>
  if(copyin(myproc()->pagetable, m->head, addr, n) == -1) {
    800073d4:	ffffa097          	auipc	ra,0xffffa
    800073d8:	6c0080e7          	jalr	1728(ra) # 80001a94 <myproc>
    800073dc:	86ca                	mv	a3,s2
    800073de:	8652                	mv	a2,s4
    800073e0:	648c                	ld	a1,8(s1)
    800073e2:	6d28                	ld	a0,88(a0)
    800073e4:	ffffa097          	auipc	ra,0xffffa
    800073e8:	42e080e7          	jalr	1070(ra) # 80001812 <copyin>
    800073ec:	8a2a                	mv	s4,a0
    800073ee:	57fd                	li	a5,-1
    800073f0:	02f50763          	beq	a0,a5,8000741e <sockwrite+0x7a>
    mbuffree(m);
    return -1;
  }

  // 正确的参数传递方式
  net_tx_udp(m, s->raddr, s->lport, s->rport);
    800073f4:	00e9d683          	lhu	a3,14(s3)
    800073f8:	00c9d603          	lhu	a2,12(s3)
    800073fc:	0089a583          	lw	a1,8(s3)
    80007400:	8526                	mv	a0,s1
    80007402:	fffff097          	auipc	ra,0xfffff
    80007406:	7c2080e7          	jalr	1986(ra) # 80006bc4 <net_tx_udp>
  return n;
    8000740a:	8a4a                	mv	s4,s2
}
    8000740c:	8552                	mv	a0,s4
    8000740e:	70a2                	ld	ra,40(sp)
    80007410:	7402                	ld	s0,32(sp)
    80007412:	64e2                	ld	s1,24(sp)
    80007414:	6942                	ld	s2,16(sp)
    80007416:	69a2                	ld	s3,8(sp)
    80007418:	6a02                	ld	s4,0(sp)
    8000741a:	6145                	addi	sp,sp,48
    8000741c:	8082                	ret
    mbuffree(m);
    8000741e:	8526                	mv	a0,s1
    80007420:	fffff097          	auipc	ra,0xfffff
    80007424:	734080e7          	jalr	1844(ra) # 80006b54 <mbuffree>
    return -1;
    80007428:	b7d5                	j	8000740c <sockwrite+0x68>
    return -1;
    8000742a:	5a7d                	li	s4,-1
    8000742c:	b7c5                	j	8000740c <sockwrite+0x68>

000000008000742e <sockclose>:

// 套接字关闭操作
void
sockclose(struct sock *s)
{
    8000742e:	1101                	addi	sp,sp,-32
    80007430:	ec06                	sd	ra,24(sp)
    80007432:	e822                	sd	s0,16(sp)
    80007434:	e426                	sd	s1,8(sp)
    80007436:	e04a                	sd	s2,0(sp)
    80007438:	1000                	addi	s0,sp,32
    8000743a:	892a                	mv	s2,a0
  acquire(&lock);
    8000743c:	00022517          	auipc	a0,0x22
    80007440:	ee450513          	addi	a0,a0,-284 # 80029320 <lock>
    80007444:	ffff9097          	auipc	ra,0xffff9
    80007448:	65c080e7          	jalr	1628(ra) # 80000aa0 <acquire>
  
  // 从全局链表中移除
  struct sock **sp;
  for(sp = &sockets; *sp; sp = &(*sp)->next) {
    8000744c:	00022797          	auipc	a5,0x22
    80007450:	f447b783          	ld	a5,-188(a5) # 80029390 <sockets>
    80007454:	cb99                	beqz	a5,8000746a <sockclose+0x3c>
    if(*sp == s) {
    80007456:	04f90463          	beq	s2,a5,8000749e <sockclose+0x70>
  for(sp = &sockets; *sp; sp = &(*sp)->next) {
    8000745a:	873e                	mv	a4,a5
    8000745c:	639c                	ld	a5,0(a5)
    8000745e:	c791                	beqz	a5,8000746a <sockclose+0x3c>
    if(*sp == s) {
    80007460:	fef91de3          	bne	s2,a5,8000745a <sockclose+0x2c>
      *sp = s->next;
    80007464:	00093783          	ld	a5,0(s2)
    80007468:	e31c                	sd	a5,0(a4)
      break;
    }
  }
  
  release(&lock);
    8000746a:	00022517          	auipc	a0,0x22
    8000746e:	eb650513          	addi	a0,a0,-330 # 80029320 <lock>
    80007472:	ffff9097          	auipc	ra,0xffff9
    80007476:	6fe080e7          	jalr	1790(ra) # 80000b70 <release>
  
  // 释放接收队列中的mbuf
  while(!mbufq_empty(&s->rxq)) {
    8000747a:	03090493          	addi	s1,s2,48
    8000747e:	8526                	mv	a0,s1
    80007480:	fffff097          	auipc	ra,0xfffff
    80007484:	722080e7          	jalr	1826(ra) # 80006ba2 <mbufq_empty>
    80007488:	e105                	bnez	a0,800074a8 <sockclose+0x7a>
    mbuffree(mbufq_pophead(&s->rxq));
    8000748a:	8526                	mv	a0,s1
    8000748c:	fffff097          	auipc	ra,0xfffff
    80007490:	700080e7          	jalr	1792(ra) # 80006b8c <mbufq_pophead>
    80007494:	fffff097          	auipc	ra,0xfffff
    80007498:	6c0080e7          	jalr	1728(ra) # 80006b54 <mbuffree>
    8000749c:	b7cd                	j	8000747e <sockclose+0x50>
  for(sp = &sockets; *sp; sp = &(*sp)->next) {
    8000749e:	00022717          	auipc	a4,0x22
    800074a2:	ef270713          	addi	a4,a4,-270 # 80029390 <sockets>
    800074a6:	bf7d                	j	80007464 <sockclose+0x36>
  }
  
  kfree(s);
    800074a8:	854a                	mv	a0,s2
    800074aa:	ffff9097          	auipc	ra,0xffff9
    800074ae:	3c6080e7          	jalr	966(ra) # 80000870 <kfree>
    800074b2:	60e2                	ld	ra,24(sp)
    800074b4:	6442                	ld	s0,16(sp)
    800074b6:	64a2                	ld	s1,8(sp)
    800074b8:	6902                	ld	s2,0(sp)
    800074ba:	6105                	addi	sp,sp,32
    800074bc:	8082                	ret

00000000800074be <pci_init>:
#include "proc.h"
#include "defs.h"

void
pci_init()
{
    800074be:	715d                	addi	sp,sp,-80
    800074c0:	e486                	sd	ra,72(sp)
    800074c2:	e0a2                	sd	s0,64(sp)
    800074c4:	fc26                	sd	s1,56(sp)
    800074c6:	f84a                	sd	s2,48(sp)
    800074c8:	f44e                	sd	s3,40(sp)
    800074ca:	f052                	sd	s4,32(sp)
    800074cc:	ec56                	sd	s5,24(sp)
    800074ce:	e85a                	sd	s6,16(sp)
    800074d0:	e45e                	sd	s7,8(sp)
    800074d2:	0880                	addi	s0,sp,80
    800074d4:	300004b7          	lui	s1,0x30000
    uint32 off = (bus << 16) | (dev << 11) | (func << 8) | (offset);
    volatile uint32 *base = ecam + off;
    uint32 id = base[0];
    
    // 100e:8086 is an e1000
    if(id == 0x100e8086){
    800074d8:	100e8937          	lui	s2,0x100e8
    800074dc:	08690913          	addi	s2,s2,134 # 100e8086 <_entry-0x6ff17f7a>
      // command and status register.
      // bit 0 : I/O access enable
      // bit 1 : memory access enable
      // bit 2 : enable mastering
      base[1] = 7;
    800074e0:	4b9d                	li	s7,7
      for(int i = 0; i < 6; i++){
        uint32 old = base[4+i];

        // writing all 1's to the BAR causes it to be
        // replaced with its size.
        base[4+i] = 0xffffffff;
    800074e2:	5afd                	li	s5,-1
        base[4+i] = old;
      }

      // tell the e1000 to reveal its registers at
      // physical address 0x40000000.
      base[4+0] = e1000_regs;
    800074e4:	40000b37          	lui	s6,0x40000
  for(int dev = 0; dev < 32; dev++){
    800074e8:	6a09                	lui	s4,0x2
    800074ea:	300409b7          	lui	s3,0x30040
    800074ee:	a819                	j	80007504 <pci_init+0x46>
      base[4+0] = e1000_regs;
    800074f0:	0166a823          	sw	s6,16(a3)

      e1000_init((uint32*)e1000_regs);
    800074f4:	855a                	mv	a0,s6
    800074f6:	fffff097          	auipc	ra,0xfffff
    800074fa:	0e8080e7          	jalr	232(ra) # 800065de <e1000_init>
  for(int dev = 0; dev < 32; dev++){
    800074fe:	94d2                	add	s1,s1,s4
    80007500:	03348a63          	beq	s1,s3,80007534 <pci_init+0x76>
    volatile uint32 *base = ecam + off;
    80007504:	86a6                	mv	a3,s1
    uint32 id = base[0];
    80007506:	409c                	lw	a5,0(s1)
    80007508:	2781                	sext.w	a5,a5
    if(id == 0x100e8086){
    8000750a:	ff279ae3          	bne	a5,s2,800074fe <pci_init+0x40>
      base[1] = 7;
    8000750e:	0174a223          	sw	s7,4(s1) # 30000004 <_entry-0x4ffffffc>
      __sync_synchronize();
    80007512:	0ff0000f          	fence
      for(int i = 0; i < 6; i++){
    80007516:	01048793          	addi	a5,s1,16
    8000751a:	02848613          	addi	a2,s1,40
        uint32 old = base[4+i];
    8000751e:	4398                	lw	a4,0(a5)
    80007520:	2701                	sext.w	a4,a4
        base[4+i] = 0xffffffff;
    80007522:	0157a023          	sw	s5,0(a5)
        __sync_synchronize();
    80007526:	0ff0000f          	fence
        base[4+i] = old;
    8000752a:	c398                	sw	a4,0(a5)
      for(int i = 0; i < 6; i++){
    8000752c:	0791                	addi	a5,a5,4
    8000752e:	fec798e3          	bne	a5,a2,8000751e <pci_init+0x60>
    80007532:	bf7d                	j	800074f0 <pci_init+0x32>
    }
  }
}
    80007534:	60a6                	ld	ra,72(sp)
    80007536:	6406                	ld	s0,64(sp)
    80007538:	74e2                	ld	s1,56(sp)
    8000753a:	7942                	ld	s2,48(sp)
    8000753c:	79a2                	ld	s3,40(sp)
    8000753e:	7a02                	ld	s4,32(sp)
    80007540:	6ae2                	ld	s5,24(sp)
    80007542:	6b42                	ld	s6,16(sp)
    80007544:	6ba2                	ld	s7,8(sp)
    80007546:	6161                	addi	sp,sp,80
    80007548:	8082                	ret

000000008000754a <bit_isset>:
static Sz_info *bd_sizes; 
static void *bd_base;   // start address of memory managed by the buddy allocator
static struct spinlock lock;

// Return 1 if bit at position index in array is set to 1
int bit_isset(char *array, int index) {
    8000754a:	1141                	addi	sp,sp,-16
    8000754c:	e422                	sd	s0,8(sp)
    8000754e:	0800                	addi	s0,sp,16
  char b = array[index/8];
  char m = (1 << (index % 8));
    80007550:	41f5d79b          	sraiw	a5,a1,0x1f
    80007554:	01d7d79b          	srliw	a5,a5,0x1d
    80007558:	9dbd                	addw	a1,a1,a5
    8000755a:	0075f713          	andi	a4,a1,7
    8000755e:	9f1d                	subw	a4,a4,a5
    80007560:	4785                	li	a5,1
    80007562:	00e797bb          	sllw	a5,a5,a4
    80007566:	0ff7f793          	andi	a5,a5,255
  char b = array[index/8];
    8000756a:	4035d59b          	sraiw	a1,a1,0x3
    8000756e:	95aa                	add	a1,a1,a0
  return (b & m) == m;
    80007570:	0005c503          	lbu	a0,0(a1)
    80007574:	8d7d                	and	a0,a0,a5
    80007576:	8d1d                	sub	a0,a0,a5
}
    80007578:	00153513          	seqz	a0,a0
    8000757c:	6422                	ld	s0,8(sp)
    8000757e:	0141                	addi	sp,sp,16
    80007580:	8082                	ret

0000000080007582 <bit_set>:

// Set bit at position index in array to 1
void bit_set(char *array, int index) {
    80007582:	1141                	addi	sp,sp,-16
    80007584:	e422                	sd	s0,8(sp)
    80007586:	0800                	addi	s0,sp,16
  char b = array[index/8];
    80007588:	41f5d79b          	sraiw	a5,a1,0x1f
    8000758c:	01d7d79b          	srliw	a5,a5,0x1d
    80007590:	9dbd                	addw	a1,a1,a5
    80007592:	4035d71b          	sraiw	a4,a1,0x3
    80007596:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    80007598:	899d                	andi	a1,a1,7
    8000759a:	9d9d                	subw	a1,a1,a5
    8000759c:	4785                	li	a5,1
    8000759e:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b | m);
    800075a2:	00054783          	lbu	a5,0(a0)
    800075a6:	8ddd                	or	a1,a1,a5
    800075a8:	00b50023          	sb	a1,0(a0)
}
    800075ac:	6422                	ld	s0,8(sp)
    800075ae:	0141                	addi	sp,sp,16
    800075b0:	8082                	ret

00000000800075b2 <bit_clear>:

// Clear bit at position index in array
void bit_clear(char *array, int index) {
    800075b2:	1141                	addi	sp,sp,-16
    800075b4:	e422                	sd	s0,8(sp)
    800075b6:	0800                	addi	s0,sp,16
  char b = array[index/8];
    800075b8:	41f5d79b          	sraiw	a5,a1,0x1f
    800075bc:	01d7d79b          	srliw	a5,a5,0x1d
    800075c0:	9dbd                	addw	a1,a1,a5
    800075c2:	4035d71b          	sraiw	a4,a1,0x3
    800075c6:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    800075c8:	899d                	andi	a1,a1,7
    800075ca:	9d9d                	subw	a1,a1,a5
    800075cc:	4785                	li	a5,1
    800075ce:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b & ~m);
    800075d2:	fff5c593          	not	a1,a1
    800075d6:	00054783          	lbu	a5,0(a0)
    800075da:	8dfd                	and	a1,a1,a5
    800075dc:	00b50023          	sb	a1,0(a0)
}
    800075e0:	6422                	ld	s0,8(sp)
    800075e2:	0141                	addi	sp,sp,16
    800075e4:	8082                	ret

00000000800075e6 <bd_print_vector>:

// Print a bit vector as a list of ranges of 1 bits
void
bd_print_vector(char *vector, int len) {
    800075e6:	715d                	addi	sp,sp,-80
    800075e8:	e486                	sd	ra,72(sp)
    800075ea:	e0a2                	sd	s0,64(sp)
    800075ec:	fc26                	sd	s1,56(sp)
    800075ee:	f84a                	sd	s2,48(sp)
    800075f0:	f44e                	sd	s3,40(sp)
    800075f2:	f052                	sd	s4,32(sp)
    800075f4:	ec56                	sd	s5,24(sp)
    800075f6:	e85a                	sd	s6,16(sp)
    800075f8:	e45e                	sd	s7,8(sp)
    800075fa:	0880                	addi	s0,sp,80
    800075fc:	8a2e                	mv	s4,a1
  int last, lb;
  
  last = 1;
  lb = 0;
  for (int b = 0; b < len; b++) {
    800075fe:	08b05b63          	blez	a1,80007694 <bd_print_vector+0xae>
    80007602:	89aa                	mv	s3,a0
    80007604:	4481                	li	s1,0
  lb = 0;
    80007606:	4a81                	li	s5,0
  last = 1;
    80007608:	4905                	li	s2,1
    if (last == bit_isset(vector, b))
      continue;
    if(last == 1)
    8000760a:	4b05                	li	s6,1
      printf(" [%d, %d)", lb, b);
    8000760c:	00002b97          	auipc	s7,0x2
    80007610:	61cb8b93          	addi	s7,s7,1564 # 80009c28 <userret+0xb98>
    80007614:	a821                	j	8000762c <bd_print_vector+0x46>
    lb = b;
    last = bit_isset(vector, b);
    80007616:	85a6                	mv	a1,s1
    80007618:	854e                	mv	a0,s3
    8000761a:	00000097          	auipc	ra,0x0
    8000761e:	f30080e7          	jalr	-208(ra) # 8000754a <bit_isset>
    80007622:	892a                	mv	s2,a0
    80007624:	8aa6                	mv	s5,s1
  for (int b = 0; b < len; b++) {
    80007626:	2485                	addiw	s1,s1,1
    80007628:	029a0463          	beq	s4,s1,80007650 <bd_print_vector+0x6a>
    if (last == bit_isset(vector, b))
    8000762c:	85a6                	mv	a1,s1
    8000762e:	854e                	mv	a0,s3
    80007630:	00000097          	auipc	ra,0x0
    80007634:	f1a080e7          	jalr	-230(ra) # 8000754a <bit_isset>
    80007638:	ff2507e3          	beq	a0,s2,80007626 <bd_print_vector+0x40>
    if(last == 1)
    8000763c:	fd691de3          	bne	s2,s6,80007616 <bd_print_vector+0x30>
      printf(" [%d, %d)", lb, b);
    80007640:	8626                	mv	a2,s1
    80007642:	85d6                	mv	a1,s5
    80007644:	855e                	mv	a0,s7
    80007646:	ffff9097          	auipc	ra,0xffff9
    8000764a:	f68080e7          	jalr	-152(ra) # 800005ae <printf>
    8000764e:	b7e1                	j	80007616 <bd_print_vector+0x30>
  }
  if(lb == 0 || last == 1) {
    80007650:	000a8563          	beqz	s5,8000765a <bd_print_vector+0x74>
    80007654:	4785                	li	a5,1
    80007656:	00f91c63          	bne	s2,a5,8000766e <bd_print_vector+0x88>
    printf(" [%d, %d)", lb, len);
    8000765a:	8652                	mv	a2,s4
    8000765c:	85d6                	mv	a1,s5
    8000765e:	00002517          	auipc	a0,0x2
    80007662:	5ca50513          	addi	a0,a0,1482 # 80009c28 <userret+0xb98>
    80007666:	ffff9097          	auipc	ra,0xffff9
    8000766a:	f48080e7          	jalr	-184(ra) # 800005ae <printf>
  }
  printf("\n");
    8000766e:	00002517          	auipc	a0,0x2
    80007672:	c2250513          	addi	a0,a0,-990 # 80009290 <userret+0x200>
    80007676:	ffff9097          	auipc	ra,0xffff9
    8000767a:	f38080e7          	jalr	-200(ra) # 800005ae <printf>
}
    8000767e:	60a6                	ld	ra,72(sp)
    80007680:	6406                	ld	s0,64(sp)
    80007682:	74e2                	ld	s1,56(sp)
    80007684:	7942                	ld	s2,48(sp)
    80007686:	79a2                	ld	s3,40(sp)
    80007688:	7a02                	ld	s4,32(sp)
    8000768a:	6ae2                	ld	s5,24(sp)
    8000768c:	6b42                	ld	s6,16(sp)
    8000768e:	6ba2                	ld	s7,8(sp)
    80007690:	6161                	addi	sp,sp,80
    80007692:	8082                	ret
  lb = 0;
    80007694:	4a81                	li	s5,0
    80007696:	b7d1                	j	8000765a <bd_print_vector+0x74>

0000000080007698 <bd_print>:

// Print buddy's data structures
void
bd_print() {
  for (int k = 0; k < nsizes; k++) {
    80007698:	00022697          	auipc	a3,0x22
    8000769c:	d106a683          	lw	a3,-752(a3) # 800293a8 <nsizes>
    800076a0:	10d05063          	blez	a3,800077a0 <bd_print+0x108>
bd_print() {
    800076a4:	711d                	addi	sp,sp,-96
    800076a6:	ec86                	sd	ra,88(sp)
    800076a8:	e8a2                	sd	s0,80(sp)
    800076aa:	e4a6                	sd	s1,72(sp)
    800076ac:	e0ca                	sd	s2,64(sp)
    800076ae:	fc4e                	sd	s3,56(sp)
    800076b0:	f852                	sd	s4,48(sp)
    800076b2:	f456                	sd	s5,40(sp)
    800076b4:	f05a                	sd	s6,32(sp)
    800076b6:	ec5e                	sd	s7,24(sp)
    800076b8:	e862                	sd	s8,16(sp)
    800076ba:	e466                	sd	s9,8(sp)
    800076bc:	e06a                	sd	s10,0(sp)
    800076be:	1080                	addi	s0,sp,96
  for (int k = 0; k < nsizes; k++) {
    800076c0:	4481                	li	s1,0
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    800076c2:	4a85                	li	s5,1
    800076c4:	4c41                	li	s8,16
    800076c6:	00002b97          	auipc	s7,0x2
    800076ca:	572b8b93          	addi	s7,s7,1394 # 80009c38 <userret+0xba8>
    lst_print(&bd_sizes[k].free);
    800076ce:	00022a17          	auipc	s4,0x22
    800076d2:	cd2a0a13          	addi	s4,s4,-814 # 800293a0 <bd_sizes>
    printf("  alloc:");
    800076d6:	00002b17          	auipc	s6,0x2
    800076da:	58ab0b13          	addi	s6,s6,1418 # 80009c60 <userret+0xbd0>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    800076de:	00022997          	auipc	s3,0x22
    800076e2:	cca98993          	addi	s3,s3,-822 # 800293a8 <nsizes>
    if(k > 0) {
      printf("  split:");
    800076e6:	00002c97          	auipc	s9,0x2
    800076ea:	58ac8c93          	addi	s9,s9,1418 # 80009c70 <userret+0xbe0>
    800076ee:	a801                	j	800076fe <bd_print+0x66>
  for (int k = 0; k < nsizes; k++) {
    800076f0:	0009a683          	lw	a3,0(s3)
    800076f4:	0485                	addi	s1,s1,1
    800076f6:	0004879b          	sext.w	a5,s1
    800076fa:	08d7d563          	bge	a5,a3,80007784 <bd_print+0xec>
    800076fe:	0004891b          	sext.w	s2,s1
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80007702:	36fd                	addiw	a3,a3,-1
    80007704:	9e85                	subw	a3,a3,s1
    80007706:	00da96bb          	sllw	a3,s5,a3
    8000770a:	009c1633          	sll	a2,s8,s1
    8000770e:	85ca                	mv	a1,s2
    80007710:	855e                	mv	a0,s7
    80007712:	ffff9097          	auipc	ra,0xffff9
    80007716:	e9c080e7          	jalr	-356(ra) # 800005ae <printf>
    lst_print(&bd_sizes[k].free);
    8000771a:	00549d13          	slli	s10,s1,0x5
    8000771e:	000a3503          	ld	a0,0(s4)
    80007722:	956a                	add	a0,a0,s10
    80007724:	00001097          	auipc	ra,0x1
    80007728:	a56080e7          	jalr	-1450(ra) # 8000817a <lst_print>
    printf("  alloc:");
    8000772c:	855a                	mv	a0,s6
    8000772e:	ffff9097          	auipc	ra,0xffff9
    80007732:	e80080e7          	jalr	-384(ra) # 800005ae <printf>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80007736:	0009a583          	lw	a1,0(s3)
    8000773a:	35fd                	addiw	a1,a1,-1
    8000773c:	412585bb          	subw	a1,a1,s2
    80007740:	000a3783          	ld	a5,0(s4)
    80007744:	97ea                	add	a5,a5,s10
    80007746:	00ba95bb          	sllw	a1,s5,a1
    8000774a:	6b88                	ld	a0,16(a5)
    8000774c:	00000097          	auipc	ra,0x0
    80007750:	e9a080e7          	jalr	-358(ra) # 800075e6 <bd_print_vector>
    if(k > 0) {
    80007754:	f9205ee3          	blez	s2,800076f0 <bd_print+0x58>
      printf("  split:");
    80007758:	8566                	mv	a0,s9
    8000775a:	ffff9097          	auipc	ra,0xffff9
    8000775e:	e54080e7          	jalr	-428(ra) # 800005ae <printf>
      bd_print_vector(bd_sizes[k].split, NBLK(k));
    80007762:	0009a583          	lw	a1,0(s3)
    80007766:	35fd                	addiw	a1,a1,-1
    80007768:	412585bb          	subw	a1,a1,s2
    8000776c:	000a3783          	ld	a5,0(s4)
    80007770:	9d3e                	add	s10,s10,a5
    80007772:	00ba95bb          	sllw	a1,s5,a1
    80007776:	018d3503          	ld	a0,24(s10)
    8000777a:	00000097          	auipc	ra,0x0
    8000777e:	e6c080e7          	jalr	-404(ra) # 800075e6 <bd_print_vector>
    80007782:	b7bd                	j	800076f0 <bd_print+0x58>
    }
  }
}
    80007784:	60e6                	ld	ra,88(sp)
    80007786:	6446                	ld	s0,80(sp)
    80007788:	64a6                	ld	s1,72(sp)
    8000778a:	6906                	ld	s2,64(sp)
    8000778c:	79e2                	ld	s3,56(sp)
    8000778e:	7a42                	ld	s4,48(sp)
    80007790:	7aa2                	ld	s5,40(sp)
    80007792:	7b02                	ld	s6,32(sp)
    80007794:	6be2                	ld	s7,24(sp)
    80007796:	6c42                	ld	s8,16(sp)
    80007798:	6ca2                	ld	s9,8(sp)
    8000779a:	6d02                	ld	s10,0(sp)
    8000779c:	6125                	addi	sp,sp,96
    8000779e:	8082                	ret
    800077a0:	8082                	ret

00000000800077a2 <firstk>:

// What is the first k such that 2^k >= n?
int
firstk(uint64 n) {
    800077a2:	1141                	addi	sp,sp,-16
    800077a4:	e422                	sd	s0,8(sp)
    800077a6:	0800                	addi	s0,sp,16
  int k = 0;
  uint64 size = LEAF_SIZE;

  while (size < n) {
    800077a8:	47c1                	li	a5,16
    800077aa:	00a7fb63          	bgeu	a5,a0,800077c0 <firstk+0x1e>
    800077ae:	872a                	mv	a4,a0
  int k = 0;
    800077b0:	4501                	li	a0,0
    k++;
    800077b2:	2505                	addiw	a0,a0,1
    size *= 2;
    800077b4:	0786                	slli	a5,a5,0x1
  while (size < n) {
    800077b6:	fee7eee3          	bltu	a5,a4,800077b2 <firstk+0x10>
  }
  return k;
}
    800077ba:	6422                	ld	s0,8(sp)
    800077bc:	0141                	addi	sp,sp,16
    800077be:	8082                	ret
  int k = 0;
    800077c0:	4501                	li	a0,0
    800077c2:	bfe5                	j	800077ba <firstk+0x18>

00000000800077c4 <blk_index>:

// Compute the block index for address p at size k
int
blk_index(int k, char *p) {
    800077c4:	1141                	addi	sp,sp,-16
    800077c6:	e422                	sd	s0,8(sp)
    800077c8:	0800                	addi	s0,sp,16
  int n = p - (char *) bd_base;
  return n / BLK_SIZE(k);
    800077ca:	00022797          	auipc	a5,0x22
    800077ce:	bce7b783          	ld	a5,-1074(a5) # 80029398 <bd_base>
    800077d2:	9d9d                	subw	a1,a1,a5
    800077d4:	47c1                	li	a5,16
    800077d6:	00a797b3          	sll	a5,a5,a0
    800077da:	02f5c5b3          	div	a1,a1,a5
}
    800077de:	0005851b          	sext.w	a0,a1
    800077e2:	6422                	ld	s0,8(sp)
    800077e4:	0141                	addi	sp,sp,16
    800077e6:	8082                	ret

00000000800077e8 <addr>:

// Convert a block index at size k back into an address
void *addr(int k, int bi) {
    800077e8:	1141                	addi	sp,sp,-16
    800077ea:	e422                	sd	s0,8(sp)
    800077ec:	0800                	addi	s0,sp,16
  int n = bi * BLK_SIZE(k);
    800077ee:	47c1                	li	a5,16
    800077f0:	00a797b3          	sll	a5,a5,a0
  return (char *) bd_base + n;
    800077f4:	02b787bb          	mulw	a5,a5,a1
}
    800077f8:	00022517          	auipc	a0,0x22
    800077fc:	ba053503          	ld	a0,-1120(a0) # 80029398 <bd_base>
    80007800:	953e                	add	a0,a0,a5
    80007802:	6422                	ld	s0,8(sp)
    80007804:	0141                	addi	sp,sp,16
    80007806:	8082                	ret

0000000080007808 <bd_malloc>:

// allocate nbytes, but malloc won't return anything smaller than LEAF_SIZE
void *
bd_malloc(uint64 nbytes)
{
    80007808:	7159                	addi	sp,sp,-112
    8000780a:	f486                	sd	ra,104(sp)
    8000780c:	f0a2                	sd	s0,96(sp)
    8000780e:	eca6                	sd	s1,88(sp)
    80007810:	e8ca                	sd	s2,80(sp)
    80007812:	e4ce                	sd	s3,72(sp)
    80007814:	e0d2                	sd	s4,64(sp)
    80007816:	fc56                	sd	s5,56(sp)
    80007818:	f85a                	sd	s6,48(sp)
    8000781a:	f45e                	sd	s7,40(sp)
    8000781c:	f062                	sd	s8,32(sp)
    8000781e:	ec66                	sd	s9,24(sp)
    80007820:	e86a                	sd	s10,16(sp)
    80007822:	e46e                	sd	s11,8(sp)
    80007824:	1880                	addi	s0,sp,112
    80007826:	84aa                	mv	s1,a0
  int fk, k;

  acquire(&lock);
    80007828:	00022517          	auipc	a0,0x22
    8000782c:	b1850513          	addi	a0,a0,-1256 # 80029340 <lock>
    80007830:	ffff9097          	auipc	ra,0xffff9
    80007834:	270080e7          	jalr	624(ra) # 80000aa0 <acquire>

  // Find a free block >= nbytes, starting with smallest k possible
  fk = firstk(nbytes);
    80007838:	8526                	mv	a0,s1
    8000783a:	00000097          	auipc	ra,0x0
    8000783e:	f68080e7          	jalr	-152(ra) # 800077a2 <firstk>
  for (k = fk; k < nsizes; k++) {
    80007842:	00022797          	auipc	a5,0x22
    80007846:	b667a783          	lw	a5,-1178(a5) # 800293a8 <nsizes>
    8000784a:	02f55d63          	bge	a0,a5,80007884 <bd_malloc+0x7c>
    8000784e:	8c2a                	mv	s8,a0
    80007850:	00551913          	slli	s2,a0,0x5
    80007854:	84aa                	mv	s1,a0
    if(!lst_empty(&bd_sizes[k].free))
    80007856:	00022997          	auipc	s3,0x22
    8000785a:	b4a98993          	addi	s3,s3,-1206 # 800293a0 <bd_sizes>
  for (k = fk; k < nsizes; k++) {
    8000785e:	00022a17          	auipc	s4,0x22
    80007862:	b4aa0a13          	addi	s4,s4,-1206 # 800293a8 <nsizes>
    if(!lst_empty(&bd_sizes[k].free))
    80007866:	0009b503          	ld	a0,0(s3)
    8000786a:	954a                	add	a0,a0,s2
    8000786c:	00001097          	auipc	ra,0x1
    80007870:	894080e7          	jalr	-1900(ra) # 80008100 <lst_empty>
    80007874:	c115                	beqz	a0,80007898 <bd_malloc+0x90>
  for (k = fk; k < nsizes; k++) {
    80007876:	2485                	addiw	s1,s1,1
    80007878:	02090913          	addi	s2,s2,32
    8000787c:	000a2783          	lw	a5,0(s4)
    80007880:	fef4c3e3          	blt	s1,a5,80007866 <bd_malloc+0x5e>
      break;
  }
  if(k >= nsizes) { // No free blocks?
    release(&lock);
    80007884:	00022517          	auipc	a0,0x22
    80007888:	abc50513          	addi	a0,a0,-1348 # 80029340 <lock>
    8000788c:	ffff9097          	auipc	ra,0xffff9
    80007890:	2e4080e7          	jalr	740(ra) # 80000b70 <release>
    return 0;
    80007894:	4b01                	li	s6,0
    80007896:	a0e1                	j	8000795e <bd_malloc+0x156>
  if(k >= nsizes) { // No free blocks?
    80007898:	00022797          	auipc	a5,0x22
    8000789c:	b107a783          	lw	a5,-1264(a5) # 800293a8 <nsizes>
    800078a0:	fef4d2e3          	bge	s1,a5,80007884 <bd_malloc+0x7c>
  }

  // Found a block; pop it and potentially split it.
  char *p = lst_pop(&bd_sizes[k].free);
    800078a4:	00549993          	slli	s3,s1,0x5
    800078a8:	00022917          	auipc	s2,0x22
    800078ac:	af890913          	addi	s2,s2,-1288 # 800293a0 <bd_sizes>
    800078b0:	00093503          	ld	a0,0(s2)
    800078b4:	954e                	add	a0,a0,s3
    800078b6:	00001097          	auipc	ra,0x1
    800078ba:	876080e7          	jalr	-1930(ra) # 8000812c <lst_pop>
    800078be:	8b2a                	mv	s6,a0
  return n / BLK_SIZE(k);
    800078c0:	00022597          	auipc	a1,0x22
    800078c4:	ad85b583          	ld	a1,-1320(a1) # 80029398 <bd_base>
    800078c8:	40b505bb          	subw	a1,a0,a1
    800078cc:	47c1                	li	a5,16
    800078ce:	009797b3          	sll	a5,a5,s1
    800078d2:	02f5c5b3          	div	a1,a1,a5
  bit_set(bd_sizes[k].alloc, blk_index(k, p));
    800078d6:	00093783          	ld	a5,0(s2)
    800078da:	97ce                	add	a5,a5,s3
    800078dc:	2581                	sext.w	a1,a1
    800078de:	6b88                	ld	a0,16(a5)
    800078e0:	00000097          	auipc	ra,0x0
    800078e4:	ca2080e7          	jalr	-862(ra) # 80007582 <bit_set>
  for(; k > fk; k--) {
    800078e8:	069c5363          	bge	s8,s1,8000794e <bd_malloc+0x146>
    // split a block at size k and mark one half allocated at size k-1
    // and put the buddy on the free list at size k-1
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    800078ec:	4bc1                	li	s7,16
    bit_set(bd_sizes[k].split, blk_index(k, p));
    800078ee:	8dca                	mv	s11,s2
  int n = p - (char *) bd_base;
    800078f0:	00022d17          	auipc	s10,0x22
    800078f4:	aa8d0d13          	addi	s10,s10,-1368 # 80029398 <bd_base>
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    800078f8:	85a6                	mv	a1,s1
    800078fa:	34fd                	addiw	s1,s1,-1
    800078fc:	009b9ab3          	sll	s5,s7,s1
    80007900:	015b0cb3          	add	s9,s6,s5
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80007904:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
  int n = p - (char *) bd_base;
    80007908:	000d3903          	ld	s2,0(s10)
  return n / BLK_SIZE(k);
    8000790c:	412b093b          	subw	s2,s6,s2
    80007910:	00bb95b3          	sll	a1,s7,a1
    80007914:	02b945b3          	div	a1,s2,a1
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80007918:	013a07b3          	add	a5,s4,s3
    8000791c:	2581                	sext.w	a1,a1
    8000791e:	6f88                	ld	a0,24(a5)
    80007920:	00000097          	auipc	ra,0x0
    80007924:	c62080e7          	jalr	-926(ra) # 80007582 <bit_set>
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80007928:	1981                	addi	s3,s3,-32
    8000792a:	9a4e                	add	s4,s4,s3
  return n / BLK_SIZE(k);
    8000792c:	035945b3          	div	a1,s2,s5
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80007930:	2581                	sext.w	a1,a1
    80007932:	010a3503          	ld	a0,16(s4)
    80007936:	00000097          	auipc	ra,0x0
    8000793a:	c4c080e7          	jalr	-948(ra) # 80007582 <bit_set>
    lst_push(&bd_sizes[k-1].free, q);
    8000793e:	85e6                	mv	a1,s9
    80007940:	8552                	mv	a0,s4
    80007942:	00001097          	auipc	ra,0x1
    80007946:	820080e7          	jalr	-2016(ra) # 80008162 <lst_push>
  for(; k > fk; k--) {
    8000794a:	fb8497e3          	bne	s1,s8,800078f8 <bd_malloc+0xf0>
  }
  release(&lock);
    8000794e:	00022517          	auipc	a0,0x22
    80007952:	9f250513          	addi	a0,a0,-1550 # 80029340 <lock>
    80007956:	ffff9097          	auipc	ra,0xffff9
    8000795a:	21a080e7          	jalr	538(ra) # 80000b70 <release>

  return p;
}
    8000795e:	855a                	mv	a0,s6
    80007960:	70a6                	ld	ra,104(sp)
    80007962:	7406                	ld	s0,96(sp)
    80007964:	64e6                	ld	s1,88(sp)
    80007966:	6946                	ld	s2,80(sp)
    80007968:	69a6                	ld	s3,72(sp)
    8000796a:	6a06                	ld	s4,64(sp)
    8000796c:	7ae2                	ld	s5,56(sp)
    8000796e:	7b42                	ld	s6,48(sp)
    80007970:	7ba2                	ld	s7,40(sp)
    80007972:	7c02                	ld	s8,32(sp)
    80007974:	6ce2                	ld	s9,24(sp)
    80007976:	6d42                	ld	s10,16(sp)
    80007978:	6da2                	ld	s11,8(sp)
    8000797a:	6165                	addi	sp,sp,112
    8000797c:	8082                	ret

000000008000797e <size>:

// Find the size of the block that p points to.
int
size(char *p) {
    8000797e:	7139                	addi	sp,sp,-64
    80007980:	fc06                	sd	ra,56(sp)
    80007982:	f822                	sd	s0,48(sp)
    80007984:	f426                	sd	s1,40(sp)
    80007986:	f04a                	sd	s2,32(sp)
    80007988:	ec4e                	sd	s3,24(sp)
    8000798a:	e852                	sd	s4,16(sp)
    8000798c:	e456                	sd	s5,8(sp)
    8000798e:	e05a                	sd	s6,0(sp)
    80007990:	0080                	addi	s0,sp,64
  for (int k = 0; k < nsizes; k++) {
    80007992:	00022a97          	auipc	s5,0x22
    80007996:	a16aaa83          	lw	s5,-1514(s5) # 800293a8 <nsizes>
  return n / BLK_SIZE(k);
    8000799a:	00022a17          	auipc	s4,0x22
    8000799e:	9fea3a03          	ld	s4,-1538(s4) # 80029398 <bd_base>
    800079a2:	41450a3b          	subw	s4,a0,s4
    800079a6:	00022497          	auipc	s1,0x22
    800079aa:	9fa4b483          	ld	s1,-1542(s1) # 800293a0 <bd_sizes>
    800079ae:	03848493          	addi	s1,s1,56
  for (int k = 0; k < nsizes; k++) {
    800079b2:	4901                	li	s2,0
  return n / BLK_SIZE(k);
    800079b4:	4b41                	li	s6,16
  for (int k = 0; k < nsizes; k++) {
    800079b6:	03595363          	bge	s2,s5,800079dc <size+0x5e>
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    800079ba:	0019099b          	addiw	s3,s2,1
  return n / BLK_SIZE(k);
    800079be:	013b15b3          	sll	a1,s6,s3
    800079c2:	02ba45b3          	div	a1,s4,a1
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    800079c6:	2581                	sext.w	a1,a1
    800079c8:	6088                	ld	a0,0(s1)
    800079ca:	00000097          	auipc	ra,0x0
    800079ce:	b80080e7          	jalr	-1152(ra) # 8000754a <bit_isset>
    800079d2:	02048493          	addi	s1,s1,32
    800079d6:	e501                	bnez	a0,800079de <size+0x60>
  for (int k = 0; k < nsizes; k++) {
    800079d8:	894e                	mv	s2,s3
    800079da:	bff1                	j	800079b6 <size+0x38>
      return k;
    }
  }
  return 0;
    800079dc:	4901                	li	s2,0
}
    800079de:	854a                	mv	a0,s2
    800079e0:	70e2                	ld	ra,56(sp)
    800079e2:	7442                	ld	s0,48(sp)
    800079e4:	74a2                	ld	s1,40(sp)
    800079e6:	7902                	ld	s2,32(sp)
    800079e8:	69e2                	ld	s3,24(sp)
    800079ea:	6a42                	ld	s4,16(sp)
    800079ec:	6aa2                	ld	s5,8(sp)
    800079ee:	6b02                	ld	s6,0(sp)
    800079f0:	6121                	addi	sp,sp,64
    800079f2:	8082                	ret

00000000800079f4 <bd_free>:

// Free memory pointed to by p, which was earlier allocated using
// bd_malloc.
void
bd_free(void *p) {
    800079f4:	7159                	addi	sp,sp,-112
    800079f6:	f486                	sd	ra,104(sp)
    800079f8:	f0a2                	sd	s0,96(sp)
    800079fa:	eca6                	sd	s1,88(sp)
    800079fc:	e8ca                	sd	s2,80(sp)
    800079fe:	e4ce                	sd	s3,72(sp)
    80007a00:	e0d2                	sd	s4,64(sp)
    80007a02:	fc56                	sd	s5,56(sp)
    80007a04:	f85a                	sd	s6,48(sp)
    80007a06:	f45e                	sd	s7,40(sp)
    80007a08:	f062                	sd	s8,32(sp)
    80007a0a:	ec66                	sd	s9,24(sp)
    80007a0c:	e86a                	sd	s10,16(sp)
    80007a0e:	e46e                	sd	s11,8(sp)
    80007a10:	1880                	addi	s0,sp,112
    80007a12:	8aaa                	mv	s5,a0
  void *q;
  int k;

  acquire(&lock);
    80007a14:	00022517          	auipc	a0,0x22
    80007a18:	92c50513          	addi	a0,a0,-1748 # 80029340 <lock>
    80007a1c:	ffff9097          	auipc	ra,0xffff9
    80007a20:	084080e7          	jalr	132(ra) # 80000aa0 <acquire>
  for (k = size(p); k < MAXSIZE; k++) {
    80007a24:	8556                	mv	a0,s5
    80007a26:	00000097          	auipc	ra,0x0
    80007a2a:	f58080e7          	jalr	-168(ra) # 8000797e <size>
    80007a2e:	84aa                	mv	s1,a0
    80007a30:	00022797          	auipc	a5,0x22
    80007a34:	9787a783          	lw	a5,-1672(a5) # 800293a8 <nsizes>
    80007a38:	37fd                	addiw	a5,a5,-1
    80007a3a:	0cf55063          	bge	a0,a5,80007afa <bd_free+0x106>
    80007a3e:	00150a13          	addi	s4,a0,1
    80007a42:	0a16                	slli	s4,s4,0x5
  int n = p - (char *) bd_base;
    80007a44:	00022c17          	auipc	s8,0x22
    80007a48:	954c0c13          	addi	s8,s8,-1708 # 80029398 <bd_base>
  return n / BLK_SIZE(k);
    80007a4c:	4bc1                	li	s7,16
    int bi = blk_index(k, p);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80007a4e:	00022b17          	auipc	s6,0x22
    80007a52:	952b0b13          	addi	s6,s6,-1710 # 800293a0 <bd_sizes>
  for (k = size(p); k < MAXSIZE; k++) {
    80007a56:	00022c97          	auipc	s9,0x22
    80007a5a:	952c8c93          	addi	s9,s9,-1710 # 800293a8 <nsizes>
    80007a5e:	a82d                	j	80007a98 <bd_free+0xa4>
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80007a60:	fff58d9b          	addiw	s11,a1,-1
    80007a64:	a881                	j	80007ab4 <bd_free+0xc0>
    if(buddy % 2 == 0) {
      p = q;
    }
    // at size k+1, mark that the merged buddy pair isn't split
    // anymore
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80007a66:	2485                	addiw	s1,s1,1
  int n = p - (char *) bd_base;
    80007a68:	000c3583          	ld	a1,0(s8)
  return n / BLK_SIZE(k);
    80007a6c:	40ba85bb          	subw	a1,s5,a1
    80007a70:	009b97b3          	sll	a5,s7,s1
    80007a74:	02f5c5b3          	div	a1,a1,a5
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80007a78:	000b3783          	ld	a5,0(s6)
    80007a7c:	97d2                	add	a5,a5,s4
    80007a7e:	2581                	sext.w	a1,a1
    80007a80:	6f88                	ld	a0,24(a5)
    80007a82:	00000097          	auipc	ra,0x0
    80007a86:	b30080e7          	jalr	-1232(ra) # 800075b2 <bit_clear>
  for (k = size(p); k < MAXSIZE; k++) {
    80007a8a:	020a0a13          	addi	s4,s4,32
    80007a8e:	000ca783          	lw	a5,0(s9)
    80007a92:	37fd                	addiw	a5,a5,-1
    80007a94:	06f4d363          	bge	s1,a5,80007afa <bd_free+0x106>
  int n = p - (char *) bd_base;
    80007a98:	000c3903          	ld	s2,0(s8)
  return n / BLK_SIZE(k);
    80007a9c:	009b99b3          	sll	s3,s7,s1
    80007aa0:	412a87bb          	subw	a5,s5,s2
    80007aa4:	0337c7b3          	div	a5,a5,s3
    80007aa8:	0007859b          	sext.w	a1,a5
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80007aac:	8b85                	andi	a5,a5,1
    80007aae:	fbcd                	bnez	a5,80007a60 <bd_free+0x6c>
    80007ab0:	00158d9b          	addiw	s11,a1,1
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80007ab4:	fe0a0d13          	addi	s10,s4,-32
    80007ab8:	000b3783          	ld	a5,0(s6)
    80007abc:	9d3e                	add	s10,s10,a5
    80007abe:	010d3503          	ld	a0,16(s10)
    80007ac2:	00000097          	auipc	ra,0x0
    80007ac6:	af0080e7          	jalr	-1296(ra) # 800075b2 <bit_clear>
    if (bit_isset(bd_sizes[k].alloc, buddy)) {  // is buddy allocated?
    80007aca:	85ee                	mv	a1,s11
    80007acc:	010d3503          	ld	a0,16(s10)
    80007ad0:	00000097          	auipc	ra,0x0
    80007ad4:	a7a080e7          	jalr	-1414(ra) # 8000754a <bit_isset>
    80007ad8:	e10d                	bnez	a0,80007afa <bd_free+0x106>
  int n = bi * BLK_SIZE(k);
    80007ada:	000d8d1b          	sext.w	s10,s11
  return (char *) bd_base + n;
    80007ade:	03b989bb          	mulw	s3,s3,s11
    80007ae2:	994e                	add	s2,s2,s3
    lst_remove(q);    // remove buddy from free list
    80007ae4:	854a                	mv	a0,s2
    80007ae6:	00000097          	auipc	ra,0x0
    80007aea:	630080e7          	jalr	1584(ra) # 80008116 <lst_remove>
    if(buddy % 2 == 0) {
    80007aee:	001d7d13          	andi	s10,s10,1
    80007af2:	f60d1ae3          	bnez	s10,80007a66 <bd_free+0x72>
      p = q;
    80007af6:	8aca                	mv	s5,s2
    80007af8:	b7bd                	j	80007a66 <bd_free+0x72>
  }
  lst_push(&bd_sizes[k].free, p);
    80007afa:	0496                	slli	s1,s1,0x5
    80007afc:	85d6                	mv	a1,s5
    80007afe:	00022517          	auipc	a0,0x22
    80007b02:	8a253503          	ld	a0,-1886(a0) # 800293a0 <bd_sizes>
    80007b06:	9526                	add	a0,a0,s1
    80007b08:	00000097          	auipc	ra,0x0
    80007b0c:	65a080e7          	jalr	1626(ra) # 80008162 <lst_push>
  release(&lock);
    80007b10:	00022517          	auipc	a0,0x22
    80007b14:	83050513          	addi	a0,a0,-2000 # 80029340 <lock>
    80007b18:	ffff9097          	auipc	ra,0xffff9
    80007b1c:	058080e7          	jalr	88(ra) # 80000b70 <release>
}
    80007b20:	70a6                	ld	ra,104(sp)
    80007b22:	7406                	ld	s0,96(sp)
    80007b24:	64e6                	ld	s1,88(sp)
    80007b26:	6946                	ld	s2,80(sp)
    80007b28:	69a6                	ld	s3,72(sp)
    80007b2a:	6a06                	ld	s4,64(sp)
    80007b2c:	7ae2                	ld	s5,56(sp)
    80007b2e:	7b42                	ld	s6,48(sp)
    80007b30:	7ba2                	ld	s7,40(sp)
    80007b32:	7c02                	ld	s8,32(sp)
    80007b34:	6ce2                	ld	s9,24(sp)
    80007b36:	6d42                	ld	s10,16(sp)
    80007b38:	6da2                	ld	s11,8(sp)
    80007b3a:	6165                	addi	sp,sp,112
    80007b3c:	8082                	ret

0000000080007b3e <blk_index_next>:

// Compute the first block at size k that doesn't contain p
int
blk_index_next(int k, char *p) {
    80007b3e:	1141                	addi	sp,sp,-16
    80007b40:	e422                	sd	s0,8(sp)
    80007b42:	0800                	addi	s0,sp,16
  int n = (p - (char *) bd_base) / BLK_SIZE(k);
    80007b44:	00022797          	auipc	a5,0x22
    80007b48:	8547b783          	ld	a5,-1964(a5) # 80029398 <bd_base>
    80007b4c:	8d9d                	sub	a1,a1,a5
    80007b4e:	47c1                	li	a5,16
    80007b50:	00a797b3          	sll	a5,a5,a0
    80007b54:	02f5c533          	div	a0,a1,a5
    80007b58:	2501                	sext.w	a0,a0
  if((p - (char*) bd_base) % BLK_SIZE(k) != 0)
    80007b5a:	02f5e5b3          	rem	a1,a1,a5
    80007b5e:	c191                	beqz	a1,80007b62 <blk_index_next+0x24>
      n++;
    80007b60:	2505                	addiw	a0,a0,1
  return n ;
}
    80007b62:	6422                	ld	s0,8(sp)
    80007b64:	0141                	addi	sp,sp,16
    80007b66:	8082                	ret

0000000080007b68 <log2>:

int
log2(uint64 n) {
    80007b68:	1141                	addi	sp,sp,-16
    80007b6a:	e422                	sd	s0,8(sp)
    80007b6c:	0800                	addi	s0,sp,16
  int k = 0;
  while (n > 1) {
    80007b6e:	4705                	li	a4,1
    80007b70:	00a77b63          	bgeu	a4,a0,80007b86 <log2+0x1e>
    80007b74:	87aa                	mv	a5,a0
  int k = 0;
    80007b76:	4501                	li	a0,0
    k++;
    80007b78:	2505                	addiw	a0,a0,1
    n = n >> 1;
    80007b7a:	8385                	srli	a5,a5,0x1
  while (n > 1) {
    80007b7c:	fef76ee3          	bltu	a4,a5,80007b78 <log2+0x10>
  }
  return k;
}
    80007b80:	6422                	ld	s0,8(sp)
    80007b82:	0141                	addi	sp,sp,16
    80007b84:	8082                	ret
  int k = 0;
    80007b86:	4501                	li	a0,0
    80007b88:	bfe5                	j	80007b80 <log2+0x18>

0000000080007b8a <bd_mark>:

// Mark memory from [start, stop), starting at size 0, as allocated. 
void
bd_mark(void *start, void *stop)
{
    80007b8a:	711d                	addi	sp,sp,-96
    80007b8c:	ec86                	sd	ra,88(sp)
    80007b8e:	e8a2                	sd	s0,80(sp)
    80007b90:	e4a6                	sd	s1,72(sp)
    80007b92:	e0ca                	sd	s2,64(sp)
    80007b94:	fc4e                	sd	s3,56(sp)
    80007b96:	f852                	sd	s4,48(sp)
    80007b98:	f456                	sd	s5,40(sp)
    80007b9a:	f05a                	sd	s6,32(sp)
    80007b9c:	ec5e                	sd	s7,24(sp)
    80007b9e:	e862                	sd	s8,16(sp)
    80007ba0:	e466                	sd	s9,8(sp)
    80007ba2:	e06a                	sd	s10,0(sp)
    80007ba4:	1080                	addi	s0,sp,96
  int bi, bj;

  if (((uint64) start % LEAF_SIZE != 0) || ((uint64) stop % LEAF_SIZE != 0))
    80007ba6:	00b56933          	or	s2,a0,a1
    80007baa:	00f97913          	andi	s2,s2,15
    80007bae:	04091263          	bnez	s2,80007bf2 <bd_mark+0x68>
    80007bb2:	8b2a                	mv	s6,a0
    80007bb4:	8bae                	mv	s7,a1
    panic("bd_mark");

  for (int k = 0; k < nsizes; k++) {
    80007bb6:	00021c17          	auipc	s8,0x21
    80007bba:	7f2c2c03          	lw	s8,2034(s8) # 800293a8 <nsizes>
    80007bbe:	4981                	li	s3,0
  int n = p - (char *) bd_base;
    80007bc0:	00021d17          	auipc	s10,0x21
    80007bc4:	7d8d0d13          	addi	s10,s10,2008 # 80029398 <bd_base>
  return n / BLK_SIZE(k);
    80007bc8:	4cc1                	li	s9,16
    bi = blk_index(k, start);
    bj = blk_index_next(k, stop);
    for(; bi < bj; bi++) {
      if(k > 0) {
        // if a block is allocated at size k, mark it as split too.
        bit_set(bd_sizes[k].split, bi);
    80007bca:	00021a97          	auipc	s5,0x21
    80007bce:	7d6a8a93          	addi	s5,s5,2006 # 800293a0 <bd_sizes>
  for (int k = 0; k < nsizes; k++) {
    80007bd2:	07804563          	bgtz	s8,80007c3c <bd_mark+0xb2>
      }
      bit_set(bd_sizes[k].alloc, bi);
    }
  }
}
    80007bd6:	60e6                	ld	ra,88(sp)
    80007bd8:	6446                	ld	s0,80(sp)
    80007bda:	64a6                	ld	s1,72(sp)
    80007bdc:	6906                	ld	s2,64(sp)
    80007bde:	79e2                	ld	s3,56(sp)
    80007be0:	7a42                	ld	s4,48(sp)
    80007be2:	7aa2                	ld	s5,40(sp)
    80007be4:	7b02                	ld	s6,32(sp)
    80007be6:	6be2                	ld	s7,24(sp)
    80007be8:	6c42                	ld	s8,16(sp)
    80007bea:	6ca2                	ld	s9,8(sp)
    80007bec:	6d02                	ld	s10,0(sp)
    80007bee:	6125                	addi	sp,sp,96
    80007bf0:	8082                	ret
    panic("bd_mark");
    80007bf2:	00002517          	auipc	a0,0x2
    80007bf6:	08e50513          	addi	a0,a0,142 # 80009c80 <userret+0xbf0>
    80007bfa:	ffff9097          	auipc	ra,0xffff9
    80007bfe:	95a080e7          	jalr	-1702(ra) # 80000554 <panic>
      bit_set(bd_sizes[k].alloc, bi);
    80007c02:	000ab783          	ld	a5,0(s5)
    80007c06:	97ca                	add	a5,a5,s2
    80007c08:	85a6                	mv	a1,s1
    80007c0a:	6b88                	ld	a0,16(a5)
    80007c0c:	00000097          	auipc	ra,0x0
    80007c10:	976080e7          	jalr	-1674(ra) # 80007582 <bit_set>
    for(; bi < bj; bi++) {
    80007c14:	2485                	addiw	s1,s1,1
    80007c16:	009a0e63          	beq	s4,s1,80007c32 <bd_mark+0xa8>
      if(k > 0) {
    80007c1a:	ff3054e3          	blez	s3,80007c02 <bd_mark+0x78>
        bit_set(bd_sizes[k].split, bi);
    80007c1e:	000ab783          	ld	a5,0(s5)
    80007c22:	97ca                	add	a5,a5,s2
    80007c24:	85a6                	mv	a1,s1
    80007c26:	6f88                	ld	a0,24(a5)
    80007c28:	00000097          	auipc	ra,0x0
    80007c2c:	95a080e7          	jalr	-1702(ra) # 80007582 <bit_set>
    80007c30:	bfc9                	j	80007c02 <bd_mark+0x78>
  for (int k = 0; k < nsizes; k++) {
    80007c32:	2985                	addiw	s3,s3,1
    80007c34:	02090913          	addi	s2,s2,32
    80007c38:	f9898fe3          	beq	s3,s8,80007bd6 <bd_mark+0x4c>
  int n = p - (char *) bd_base;
    80007c3c:	000d3483          	ld	s1,0(s10)
  return n / BLK_SIZE(k);
    80007c40:	409b04bb          	subw	s1,s6,s1
    80007c44:	013c97b3          	sll	a5,s9,s3
    80007c48:	02f4c4b3          	div	s1,s1,a5
    80007c4c:	2481                	sext.w	s1,s1
    bj = blk_index_next(k, stop);
    80007c4e:	85de                	mv	a1,s7
    80007c50:	854e                	mv	a0,s3
    80007c52:	00000097          	auipc	ra,0x0
    80007c56:	eec080e7          	jalr	-276(ra) # 80007b3e <blk_index_next>
    80007c5a:	8a2a                	mv	s4,a0
    for(; bi < bj; bi++) {
    80007c5c:	faa4cfe3          	blt	s1,a0,80007c1a <bd_mark+0x90>
    80007c60:	bfc9                	j	80007c32 <bd_mark+0xa8>

0000000080007c62 <bd_initfree_pair>:

// If a block is marked as allocated and the buddy is free, put the
// buddy on the free list at size k.
int
bd_initfree_pair(int k, int bi) {
    80007c62:	7139                	addi	sp,sp,-64
    80007c64:	fc06                	sd	ra,56(sp)
    80007c66:	f822                	sd	s0,48(sp)
    80007c68:	f426                	sd	s1,40(sp)
    80007c6a:	f04a                	sd	s2,32(sp)
    80007c6c:	ec4e                	sd	s3,24(sp)
    80007c6e:	e852                	sd	s4,16(sp)
    80007c70:	e456                	sd	s5,8(sp)
    80007c72:	e05a                	sd	s6,0(sp)
    80007c74:	0080                	addi	s0,sp,64
    80007c76:	89aa                	mv	s3,a0
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80007c78:	00058a9b          	sext.w	s5,a1
    80007c7c:	0015f793          	andi	a5,a1,1
    80007c80:	ebad                	bnez	a5,80007cf2 <bd_initfree_pair+0x90>
    80007c82:	00158a1b          	addiw	s4,a1,1
  int free = 0;
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80007c86:	00599493          	slli	s1,s3,0x5
    80007c8a:	00021797          	auipc	a5,0x21
    80007c8e:	7167b783          	ld	a5,1814(a5) # 800293a0 <bd_sizes>
    80007c92:	94be                	add	s1,s1,a5
    80007c94:	0104bb03          	ld	s6,16(s1)
    80007c98:	855a                	mv	a0,s6
    80007c9a:	00000097          	auipc	ra,0x0
    80007c9e:	8b0080e7          	jalr	-1872(ra) # 8000754a <bit_isset>
    80007ca2:	892a                	mv	s2,a0
    80007ca4:	85d2                	mv	a1,s4
    80007ca6:	855a                	mv	a0,s6
    80007ca8:	00000097          	auipc	ra,0x0
    80007cac:	8a2080e7          	jalr	-1886(ra) # 8000754a <bit_isset>
  int free = 0;
    80007cb0:	4b01                	li	s6,0
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80007cb2:	02a90563          	beq	s2,a0,80007cdc <bd_initfree_pair+0x7a>
    // one of the pair is free
    free = BLK_SIZE(k);
    80007cb6:	45c1                	li	a1,16
    80007cb8:	013599b3          	sll	s3,a1,s3
    80007cbc:	00098b1b          	sext.w	s6,s3
    if(bit_isset(bd_sizes[k].alloc, bi))
    80007cc0:	02090c63          	beqz	s2,80007cf8 <bd_initfree_pair+0x96>
  return (char *) bd_base + n;
    80007cc4:	034989bb          	mulw	s3,s3,s4
      lst_push(&bd_sizes[k].free, addr(k, buddy));   // put buddy on free list
    80007cc8:	00021597          	auipc	a1,0x21
    80007ccc:	6d05b583          	ld	a1,1744(a1) # 80029398 <bd_base>
    80007cd0:	95ce                	add	a1,a1,s3
    80007cd2:	8526                	mv	a0,s1
    80007cd4:	00000097          	auipc	ra,0x0
    80007cd8:	48e080e7          	jalr	1166(ra) # 80008162 <lst_push>
    else
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
  }
  return free;
}
    80007cdc:	855a                	mv	a0,s6
    80007cde:	70e2                	ld	ra,56(sp)
    80007ce0:	7442                	ld	s0,48(sp)
    80007ce2:	74a2                	ld	s1,40(sp)
    80007ce4:	7902                	ld	s2,32(sp)
    80007ce6:	69e2                	ld	s3,24(sp)
    80007ce8:	6a42                	ld	s4,16(sp)
    80007cea:	6aa2                	ld	s5,8(sp)
    80007cec:	6b02                	ld	s6,0(sp)
    80007cee:	6121                	addi	sp,sp,64
    80007cf0:	8082                	ret
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80007cf2:	fff58a1b          	addiw	s4,a1,-1
    80007cf6:	bf41                	j	80007c86 <bd_initfree_pair+0x24>
  return (char *) bd_base + n;
    80007cf8:	035989bb          	mulw	s3,s3,s5
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
    80007cfc:	00021597          	auipc	a1,0x21
    80007d00:	69c5b583          	ld	a1,1692(a1) # 80029398 <bd_base>
    80007d04:	95ce                	add	a1,a1,s3
    80007d06:	8526                	mv	a0,s1
    80007d08:	00000097          	auipc	ra,0x0
    80007d0c:	45a080e7          	jalr	1114(ra) # 80008162 <lst_push>
    80007d10:	b7f1                	j	80007cdc <bd_initfree_pair+0x7a>

0000000080007d12 <bd_initfree>:
  
// Initialize the free lists for each size k.  For each size k, there
// are only two pairs that may have a buddy that should be on free list:
// bd_left and bd_right.
int
bd_initfree(void *bd_left, void *bd_right) {
    80007d12:	711d                	addi	sp,sp,-96
    80007d14:	ec86                	sd	ra,88(sp)
    80007d16:	e8a2                	sd	s0,80(sp)
    80007d18:	e4a6                	sd	s1,72(sp)
    80007d1a:	e0ca                	sd	s2,64(sp)
    80007d1c:	fc4e                	sd	s3,56(sp)
    80007d1e:	f852                	sd	s4,48(sp)
    80007d20:	f456                	sd	s5,40(sp)
    80007d22:	f05a                	sd	s6,32(sp)
    80007d24:	ec5e                	sd	s7,24(sp)
    80007d26:	e862                	sd	s8,16(sp)
    80007d28:	e466                	sd	s9,8(sp)
    80007d2a:	e06a                	sd	s10,0(sp)
    80007d2c:	1080                	addi	s0,sp,96
  int free = 0;

  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80007d2e:	00021717          	auipc	a4,0x21
    80007d32:	67a72703          	lw	a4,1658(a4) # 800293a8 <nsizes>
    80007d36:	4785                	li	a5,1
    80007d38:	06e7db63          	bge	a5,a4,80007dae <bd_initfree+0x9c>
    80007d3c:	8aaa                	mv	s5,a0
    80007d3e:	8b2e                	mv	s6,a1
    80007d40:	4901                	li	s2,0
  int free = 0;
    80007d42:	4a01                	li	s4,0
  int n = p - (char *) bd_base;
    80007d44:	00021c97          	auipc	s9,0x21
    80007d48:	654c8c93          	addi	s9,s9,1620 # 80029398 <bd_base>
  return n / BLK_SIZE(k);
    80007d4c:	4c41                	li	s8,16
  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80007d4e:	00021b97          	auipc	s7,0x21
    80007d52:	65ab8b93          	addi	s7,s7,1626 # 800293a8 <nsizes>
    80007d56:	a039                	j	80007d64 <bd_initfree+0x52>
    80007d58:	2905                	addiw	s2,s2,1
    80007d5a:	000ba783          	lw	a5,0(s7)
    80007d5e:	37fd                	addiw	a5,a5,-1
    80007d60:	04f95863          	bge	s2,a5,80007db0 <bd_initfree+0x9e>
    int left = blk_index_next(k, bd_left);
    80007d64:	85d6                	mv	a1,s5
    80007d66:	854a                	mv	a0,s2
    80007d68:	00000097          	auipc	ra,0x0
    80007d6c:	dd6080e7          	jalr	-554(ra) # 80007b3e <blk_index_next>
    80007d70:	89aa                	mv	s3,a0
  int n = p - (char *) bd_base;
    80007d72:	000cb483          	ld	s1,0(s9)
  return n / BLK_SIZE(k);
    80007d76:	409b04bb          	subw	s1,s6,s1
    80007d7a:	012c17b3          	sll	a5,s8,s2
    80007d7e:	02f4c4b3          	div	s1,s1,a5
    80007d82:	2481                	sext.w	s1,s1
    int right = blk_index(k, bd_right);
    free += bd_initfree_pair(k, left);
    80007d84:	85aa                	mv	a1,a0
    80007d86:	854a                	mv	a0,s2
    80007d88:	00000097          	auipc	ra,0x0
    80007d8c:	eda080e7          	jalr	-294(ra) # 80007c62 <bd_initfree_pair>
    80007d90:	01450d3b          	addw	s10,a0,s4
    80007d94:	000d0a1b          	sext.w	s4,s10
    if(right <= left)
    80007d98:	fc99d0e3          	bge	s3,s1,80007d58 <bd_initfree+0x46>
      continue;
    free += bd_initfree_pair(k, right);
    80007d9c:	85a6                	mv	a1,s1
    80007d9e:	854a                	mv	a0,s2
    80007da0:	00000097          	auipc	ra,0x0
    80007da4:	ec2080e7          	jalr	-318(ra) # 80007c62 <bd_initfree_pair>
    80007da8:	00ad0a3b          	addw	s4,s10,a0
    80007dac:	b775                	j	80007d58 <bd_initfree+0x46>
  int free = 0;
    80007dae:	4a01                	li	s4,0
  }
  return free;
}
    80007db0:	8552                	mv	a0,s4
    80007db2:	60e6                	ld	ra,88(sp)
    80007db4:	6446                	ld	s0,80(sp)
    80007db6:	64a6                	ld	s1,72(sp)
    80007db8:	6906                	ld	s2,64(sp)
    80007dba:	79e2                	ld	s3,56(sp)
    80007dbc:	7a42                	ld	s4,48(sp)
    80007dbe:	7aa2                	ld	s5,40(sp)
    80007dc0:	7b02                	ld	s6,32(sp)
    80007dc2:	6be2                	ld	s7,24(sp)
    80007dc4:	6c42                	ld	s8,16(sp)
    80007dc6:	6ca2                	ld	s9,8(sp)
    80007dc8:	6d02                	ld	s10,0(sp)
    80007dca:	6125                	addi	sp,sp,96
    80007dcc:	8082                	ret

0000000080007dce <bd_mark_data_structures>:

// Mark the range [bd_base,p) as allocated
int
bd_mark_data_structures(char *p) {
    80007dce:	7179                	addi	sp,sp,-48
    80007dd0:	f406                	sd	ra,40(sp)
    80007dd2:	f022                	sd	s0,32(sp)
    80007dd4:	ec26                	sd	s1,24(sp)
    80007dd6:	e84a                	sd	s2,16(sp)
    80007dd8:	e44e                	sd	s3,8(sp)
    80007dda:	1800                	addi	s0,sp,48
    80007ddc:	892a                	mv	s2,a0
  int meta = p - (char*)bd_base;
    80007dde:	00021997          	auipc	s3,0x21
    80007de2:	5ba98993          	addi	s3,s3,1466 # 80029398 <bd_base>
    80007de6:	0009b483          	ld	s1,0(s3)
    80007dea:	409504bb          	subw	s1,a0,s1
  printf("bd: %d meta bytes for managing %d bytes of memory\n", meta, BLK_SIZE(MAXSIZE));
    80007dee:	00021797          	auipc	a5,0x21
    80007df2:	5ba7a783          	lw	a5,1466(a5) # 800293a8 <nsizes>
    80007df6:	37fd                	addiw	a5,a5,-1
    80007df8:	4641                	li	a2,16
    80007dfa:	00f61633          	sll	a2,a2,a5
    80007dfe:	85a6                	mv	a1,s1
    80007e00:	00002517          	auipc	a0,0x2
    80007e04:	e8850513          	addi	a0,a0,-376 # 80009c88 <userret+0xbf8>
    80007e08:	ffff8097          	auipc	ra,0xffff8
    80007e0c:	7a6080e7          	jalr	1958(ra) # 800005ae <printf>
  bd_mark(bd_base, p);
    80007e10:	85ca                	mv	a1,s2
    80007e12:	0009b503          	ld	a0,0(s3)
    80007e16:	00000097          	auipc	ra,0x0
    80007e1a:	d74080e7          	jalr	-652(ra) # 80007b8a <bd_mark>
  return meta;
}
    80007e1e:	8526                	mv	a0,s1
    80007e20:	70a2                	ld	ra,40(sp)
    80007e22:	7402                	ld	s0,32(sp)
    80007e24:	64e2                	ld	s1,24(sp)
    80007e26:	6942                	ld	s2,16(sp)
    80007e28:	69a2                	ld	s3,8(sp)
    80007e2a:	6145                	addi	sp,sp,48
    80007e2c:	8082                	ret

0000000080007e2e <bd_mark_unavailable>:

// Mark the range [end, HEAPSIZE) as allocated
int
bd_mark_unavailable(void *end, void *left) {
    80007e2e:	1101                	addi	sp,sp,-32
    80007e30:	ec06                	sd	ra,24(sp)
    80007e32:	e822                	sd	s0,16(sp)
    80007e34:	e426                	sd	s1,8(sp)
    80007e36:	1000                	addi	s0,sp,32
  int unavailable = BLK_SIZE(MAXSIZE)-(end-bd_base);
    80007e38:	00021497          	auipc	s1,0x21
    80007e3c:	5704a483          	lw	s1,1392(s1) # 800293a8 <nsizes>
    80007e40:	fff4879b          	addiw	a5,s1,-1
    80007e44:	44c1                	li	s1,16
    80007e46:	00f494b3          	sll	s1,s1,a5
    80007e4a:	00021797          	auipc	a5,0x21
    80007e4e:	54e7b783          	ld	a5,1358(a5) # 80029398 <bd_base>
    80007e52:	8d1d                	sub	a0,a0,a5
    80007e54:	40a4853b          	subw	a0,s1,a0
    80007e58:	0005049b          	sext.w	s1,a0
  if(unavailable > 0)
    80007e5c:	00905a63          	blez	s1,80007e70 <bd_mark_unavailable+0x42>
    unavailable = ROUNDUP(unavailable, LEAF_SIZE);
    80007e60:	357d                	addiw	a0,a0,-1
    80007e62:	41f5549b          	sraiw	s1,a0,0x1f
    80007e66:	01c4d49b          	srliw	s1,s1,0x1c
    80007e6a:	9ca9                	addw	s1,s1,a0
    80007e6c:	98c1                	andi	s1,s1,-16
    80007e6e:	24c1                	addiw	s1,s1,16
  printf("bd: 0x%x bytes unavailable\n", unavailable);
    80007e70:	85a6                	mv	a1,s1
    80007e72:	00002517          	auipc	a0,0x2
    80007e76:	e4e50513          	addi	a0,a0,-434 # 80009cc0 <userret+0xc30>
    80007e7a:	ffff8097          	auipc	ra,0xffff8
    80007e7e:	734080e7          	jalr	1844(ra) # 800005ae <printf>

  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80007e82:	00021717          	auipc	a4,0x21
    80007e86:	51673703          	ld	a4,1302(a4) # 80029398 <bd_base>
    80007e8a:	00021597          	auipc	a1,0x21
    80007e8e:	51e5a583          	lw	a1,1310(a1) # 800293a8 <nsizes>
    80007e92:	fff5879b          	addiw	a5,a1,-1
    80007e96:	45c1                	li	a1,16
    80007e98:	00f595b3          	sll	a1,a1,a5
    80007e9c:	40958533          	sub	a0,a1,s1
  bd_mark(bd_end, bd_base+BLK_SIZE(MAXSIZE));
    80007ea0:	95ba                	add	a1,a1,a4
    80007ea2:	953a                	add	a0,a0,a4
    80007ea4:	00000097          	auipc	ra,0x0
    80007ea8:	ce6080e7          	jalr	-794(ra) # 80007b8a <bd_mark>
  return unavailable;
}
    80007eac:	8526                	mv	a0,s1
    80007eae:	60e2                	ld	ra,24(sp)
    80007eb0:	6442                	ld	s0,16(sp)
    80007eb2:	64a2                	ld	s1,8(sp)
    80007eb4:	6105                	addi	sp,sp,32
    80007eb6:	8082                	ret

0000000080007eb8 <bd_init>:

// Initialize the buddy allocator: it manages memory from [base, end).
void
bd_init(void *base, void *end) {
    80007eb8:	715d                	addi	sp,sp,-80
    80007eba:	e486                	sd	ra,72(sp)
    80007ebc:	e0a2                	sd	s0,64(sp)
    80007ebe:	fc26                	sd	s1,56(sp)
    80007ec0:	f84a                	sd	s2,48(sp)
    80007ec2:	f44e                	sd	s3,40(sp)
    80007ec4:	f052                	sd	s4,32(sp)
    80007ec6:	ec56                	sd	s5,24(sp)
    80007ec8:	e85a                	sd	s6,16(sp)
    80007eca:	e45e                	sd	s7,8(sp)
    80007ecc:	e062                	sd	s8,0(sp)
    80007ece:	0880                	addi	s0,sp,80
    80007ed0:	8c2e                	mv	s8,a1
  char *p = (char *) ROUNDUP((uint64)base, LEAF_SIZE);
    80007ed2:	fff50493          	addi	s1,a0,-1
    80007ed6:	98c1                	andi	s1,s1,-16
    80007ed8:	04c1                	addi	s1,s1,16
  int sz;

  initlock(&lock, "buddy");
    80007eda:	00002597          	auipc	a1,0x2
    80007ede:	e0658593          	addi	a1,a1,-506 # 80009ce0 <userret+0xc50>
    80007ee2:	00021517          	auipc	a0,0x21
    80007ee6:	45e50513          	addi	a0,a0,1118 # 80029340 <lock>
    80007eea:	ffff9097          	auipc	ra,0xffff9
    80007eee:	ae2080e7          	jalr	-1310(ra) # 800009cc <initlock>
  bd_base = (void *) p;
    80007ef2:	00021797          	auipc	a5,0x21
    80007ef6:	4a97b323          	sd	s1,1190(a5) # 80029398 <bd_base>

  // compute the number of sizes we need to manage [base, end)
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80007efa:	409c0933          	sub	s2,s8,s1
    80007efe:	43f95513          	srai	a0,s2,0x3f
    80007f02:	893d                	andi	a0,a0,15
    80007f04:	954a                	add	a0,a0,s2
    80007f06:	8511                	srai	a0,a0,0x4
    80007f08:	00000097          	auipc	ra,0x0
    80007f0c:	c60080e7          	jalr	-928(ra) # 80007b68 <log2>
  if((char*)end-p > BLK_SIZE(MAXSIZE)) {
    80007f10:	47c1                	li	a5,16
    80007f12:	00a797b3          	sll	a5,a5,a0
    80007f16:	1b27c663          	blt	a5,s2,800080c2 <bd_init+0x20a>
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80007f1a:	2505                	addiw	a0,a0,1
    80007f1c:	00021797          	auipc	a5,0x21
    80007f20:	48a7a623          	sw	a0,1164(a5) # 800293a8 <nsizes>
    nsizes++;  // round up to the next power of 2
  }

  printf("bd: memory sz is %d bytes; allocate an size array of length %d\n",
    80007f24:	00021997          	auipc	s3,0x21
    80007f28:	48498993          	addi	s3,s3,1156 # 800293a8 <nsizes>
    80007f2c:	0009a603          	lw	a2,0(s3)
    80007f30:	85ca                	mv	a1,s2
    80007f32:	00002517          	auipc	a0,0x2
    80007f36:	db650513          	addi	a0,a0,-586 # 80009ce8 <userret+0xc58>
    80007f3a:	ffff8097          	auipc	ra,0xffff8
    80007f3e:	674080e7          	jalr	1652(ra) # 800005ae <printf>
         (char*) end - p, nsizes);

  // allocate bd_sizes array
  bd_sizes = (Sz_info *) p;
    80007f42:	00021797          	auipc	a5,0x21
    80007f46:	4497bf23          	sd	s1,1118(a5) # 800293a0 <bd_sizes>
  p += sizeof(Sz_info) * nsizes;
    80007f4a:	0009a603          	lw	a2,0(s3)
    80007f4e:	00561913          	slli	s2,a2,0x5
    80007f52:	9926                	add	s2,s2,s1
  memset(bd_sizes, 0, sizeof(Sz_info) * nsizes);
    80007f54:	0056161b          	slliw	a2,a2,0x5
    80007f58:	4581                	li	a1,0
    80007f5a:	8526                	mv	a0,s1
    80007f5c:	ffff9097          	auipc	ra,0xffff9
    80007f60:	e12080e7          	jalr	-494(ra) # 80000d6e <memset>

  // initialize free list and allocate the alloc array for each size k
  for (int k = 0; k < nsizes; k++) {
    80007f64:	0009a783          	lw	a5,0(s3)
    80007f68:	06f05a63          	blez	a5,80007fdc <bd_init+0x124>
    80007f6c:	4981                	li	s3,0
    lst_init(&bd_sizes[k].free);
    80007f6e:	00021a97          	auipc	s5,0x21
    80007f72:	432a8a93          	addi	s5,s5,1074 # 800293a0 <bd_sizes>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80007f76:	00021a17          	auipc	s4,0x21
    80007f7a:	432a0a13          	addi	s4,s4,1074 # 800293a8 <nsizes>
    80007f7e:	4b05                	li	s6,1
    lst_init(&bd_sizes[k].free);
    80007f80:	00599b93          	slli	s7,s3,0x5
    80007f84:	000ab503          	ld	a0,0(s5)
    80007f88:	955e                	add	a0,a0,s7
    80007f8a:	00000097          	auipc	ra,0x0
    80007f8e:	166080e7          	jalr	358(ra) # 800080f0 <lst_init>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80007f92:	000a2483          	lw	s1,0(s4)
    80007f96:	34fd                	addiw	s1,s1,-1
    80007f98:	413484bb          	subw	s1,s1,s3
    80007f9c:	009b14bb          	sllw	s1,s6,s1
    80007fa0:	fff4879b          	addiw	a5,s1,-1
    80007fa4:	41f7d49b          	sraiw	s1,a5,0x1f
    80007fa8:	01d4d49b          	srliw	s1,s1,0x1d
    80007fac:	9cbd                	addw	s1,s1,a5
    80007fae:	98e1                	andi	s1,s1,-8
    80007fb0:	24a1                	addiw	s1,s1,8
    bd_sizes[k].alloc = p;
    80007fb2:	000ab783          	ld	a5,0(s5)
    80007fb6:	9bbe                	add	s7,s7,a5
    80007fb8:	012bb823          	sd	s2,16(s7)
    memset(bd_sizes[k].alloc, 0, sz);
    80007fbc:	848d                	srai	s1,s1,0x3
    80007fbe:	8626                	mv	a2,s1
    80007fc0:	4581                	li	a1,0
    80007fc2:	854a                	mv	a0,s2
    80007fc4:	ffff9097          	auipc	ra,0xffff9
    80007fc8:	daa080e7          	jalr	-598(ra) # 80000d6e <memset>
    p += sz;
    80007fcc:	9926                	add	s2,s2,s1
  for (int k = 0; k < nsizes; k++) {
    80007fce:	0985                	addi	s3,s3,1
    80007fd0:	000a2703          	lw	a4,0(s4)
    80007fd4:	0009879b          	sext.w	a5,s3
    80007fd8:	fae7c4e3          	blt	a5,a4,80007f80 <bd_init+0xc8>
  }

  // allocate the split array for each size k, except for k = 0, since
  // we will not split blocks of size k = 0, the smallest size.
  for (int k = 1; k < nsizes; k++) {
    80007fdc:	00021797          	auipc	a5,0x21
    80007fe0:	3cc7a783          	lw	a5,972(a5) # 800293a8 <nsizes>
    80007fe4:	4705                	li	a4,1
    80007fe6:	06f75163          	bge	a4,a5,80008048 <bd_init+0x190>
    80007fea:	02000a13          	li	s4,32
    80007fee:	4985                	li	s3,1
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    80007ff0:	4b85                	li	s7,1
    bd_sizes[k].split = p;
    80007ff2:	00021b17          	auipc	s6,0x21
    80007ff6:	3aeb0b13          	addi	s6,s6,942 # 800293a0 <bd_sizes>
  for (int k = 1; k < nsizes; k++) {
    80007ffa:	00021a97          	auipc	s5,0x21
    80007ffe:	3aea8a93          	addi	s5,s5,942 # 800293a8 <nsizes>
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    80008002:	37fd                	addiw	a5,a5,-1
    80008004:	413787bb          	subw	a5,a5,s3
    80008008:	00fb94bb          	sllw	s1,s7,a5
    8000800c:	fff4879b          	addiw	a5,s1,-1
    80008010:	41f7d49b          	sraiw	s1,a5,0x1f
    80008014:	01d4d49b          	srliw	s1,s1,0x1d
    80008018:	9cbd                	addw	s1,s1,a5
    8000801a:	98e1                	andi	s1,s1,-8
    8000801c:	24a1                	addiw	s1,s1,8
    bd_sizes[k].split = p;
    8000801e:	000b3783          	ld	a5,0(s6)
    80008022:	97d2                	add	a5,a5,s4
    80008024:	0127bc23          	sd	s2,24(a5)
    memset(bd_sizes[k].split, 0, sz);
    80008028:	848d                	srai	s1,s1,0x3
    8000802a:	8626                	mv	a2,s1
    8000802c:	4581                	li	a1,0
    8000802e:	854a                	mv	a0,s2
    80008030:	ffff9097          	auipc	ra,0xffff9
    80008034:	d3e080e7          	jalr	-706(ra) # 80000d6e <memset>
    p += sz;
    80008038:	9926                	add	s2,s2,s1
  for (int k = 1; k < nsizes; k++) {
    8000803a:	2985                	addiw	s3,s3,1
    8000803c:	000aa783          	lw	a5,0(s5)
    80008040:	020a0a13          	addi	s4,s4,32
    80008044:	faf9cfe3          	blt	s3,a5,80008002 <bd_init+0x14a>
  }
  p = (char *) ROUNDUP((uint64) p, LEAF_SIZE);
    80008048:	197d                	addi	s2,s2,-1
    8000804a:	ff097913          	andi	s2,s2,-16
    8000804e:	0941                	addi	s2,s2,16

  // done allocating; mark the memory range [base, p) as allocated, so
  // that buddy will not hand out that memory.
  int meta = bd_mark_data_structures(p);
    80008050:	854a                	mv	a0,s2
    80008052:	00000097          	auipc	ra,0x0
    80008056:	d7c080e7          	jalr	-644(ra) # 80007dce <bd_mark_data_structures>
    8000805a:	8a2a                	mv	s4,a0
  
  // mark the unavailable memory range [end, HEAP_SIZE) as allocated,
  // so that buddy will not hand out that memory.
  int unavailable = bd_mark_unavailable(end, p);
    8000805c:	85ca                	mv	a1,s2
    8000805e:	8562                	mv	a0,s8
    80008060:	00000097          	auipc	ra,0x0
    80008064:	dce080e7          	jalr	-562(ra) # 80007e2e <bd_mark_unavailable>
    80008068:	89aa                	mv	s3,a0
  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    8000806a:	00021a97          	auipc	s5,0x21
    8000806e:	33ea8a93          	addi	s5,s5,830 # 800293a8 <nsizes>
    80008072:	000aa783          	lw	a5,0(s5)
    80008076:	37fd                	addiw	a5,a5,-1
    80008078:	44c1                	li	s1,16
    8000807a:	00f497b3          	sll	a5,s1,a5
    8000807e:	8f89                	sub	a5,a5,a0
  
  // initialize free lists for each size k
  int free = bd_initfree(p, bd_end);
    80008080:	00021597          	auipc	a1,0x21
    80008084:	3185b583          	ld	a1,792(a1) # 80029398 <bd_base>
    80008088:	95be                	add	a1,a1,a5
    8000808a:	854a                	mv	a0,s2
    8000808c:	00000097          	auipc	ra,0x0
    80008090:	c86080e7          	jalr	-890(ra) # 80007d12 <bd_initfree>

  // check if the amount that is free is what we expect
  if(free != BLK_SIZE(MAXSIZE)-meta-unavailable) {
    80008094:	000aa603          	lw	a2,0(s5)
    80008098:	367d                	addiw	a2,a2,-1
    8000809a:	00c49633          	sll	a2,s1,a2
    8000809e:	41460633          	sub	a2,a2,s4
    800080a2:	41360633          	sub	a2,a2,s3
    800080a6:	02c51463          	bne	a0,a2,800080ce <bd_init+0x216>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    panic("bd_init: free mem");
  }
}
    800080aa:	60a6                	ld	ra,72(sp)
    800080ac:	6406                	ld	s0,64(sp)
    800080ae:	74e2                	ld	s1,56(sp)
    800080b0:	7942                	ld	s2,48(sp)
    800080b2:	79a2                	ld	s3,40(sp)
    800080b4:	7a02                	ld	s4,32(sp)
    800080b6:	6ae2                	ld	s5,24(sp)
    800080b8:	6b42                	ld	s6,16(sp)
    800080ba:	6ba2                	ld	s7,8(sp)
    800080bc:	6c02                	ld	s8,0(sp)
    800080be:	6161                	addi	sp,sp,80
    800080c0:	8082                	ret
    nsizes++;  // round up to the next power of 2
    800080c2:	2509                	addiw	a0,a0,2
    800080c4:	00021797          	auipc	a5,0x21
    800080c8:	2ea7a223          	sw	a0,740(a5) # 800293a8 <nsizes>
    800080cc:	bda1                	j	80007f24 <bd_init+0x6c>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    800080ce:	85aa                	mv	a1,a0
    800080d0:	00002517          	auipc	a0,0x2
    800080d4:	c5850513          	addi	a0,a0,-936 # 80009d28 <userret+0xc98>
    800080d8:	ffff8097          	auipc	ra,0xffff8
    800080dc:	4d6080e7          	jalr	1238(ra) # 800005ae <printf>
    panic("bd_init: free mem");
    800080e0:	00002517          	auipc	a0,0x2
    800080e4:	c5850513          	addi	a0,a0,-936 # 80009d38 <userret+0xca8>
    800080e8:	ffff8097          	auipc	ra,0xffff8
    800080ec:	46c080e7          	jalr	1132(ra) # 80000554 <panic>

00000000800080f0 <lst_init>:
// fast. circular simplifies code, because don't have to check for
// empty list in insert and remove.

void
lst_init(struct list *lst)
{
    800080f0:	1141                	addi	sp,sp,-16
    800080f2:	e422                	sd	s0,8(sp)
    800080f4:	0800                	addi	s0,sp,16
  lst->next = lst;
    800080f6:	e108                	sd	a0,0(a0)
  lst->prev = lst;
    800080f8:	e508                	sd	a0,8(a0)
}
    800080fa:	6422                	ld	s0,8(sp)
    800080fc:	0141                	addi	sp,sp,16
    800080fe:	8082                	ret

0000000080008100 <lst_empty>:

int
lst_empty(struct list *lst) {
    80008100:	1141                	addi	sp,sp,-16
    80008102:	e422                	sd	s0,8(sp)
    80008104:	0800                	addi	s0,sp,16
  return lst->next == lst;
    80008106:	611c                	ld	a5,0(a0)
    80008108:	40a78533          	sub	a0,a5,a0
}
    8000810c:	00153513          	seqz	a0,a0
    80008110:	6422                	ld	s0,8(sp)
    80008112:	0141                	addi	sp,sp,16
    80008114:	8082                	ret

0000000080008116 <lst_remove>:

void
lst_remove(struct list *e) {
    80008116:	1141                	addi	sp,sp,-16
    80008118:	e422                	sd	s0,8(sp)
    8000811a:	0800                	addi	s0,sp,16
  e->prev->next = e->next;
    8000811c:	6518                	ld	a4,8(a0)
    8000811e:	611c                	ld	a5,0(a0)
    80008120:	e31c                	sd	a5,0(a4)
  e->next->prev = e->prev;
    80008122:	6518                	ld	a4,8(a0)
    80008124:	e798                	sd	a4,8(a5)
}
    80008126:	6422                	ld	s0,8(sp)
    80008128:	0141                	addi	sp,sp,16
    8000812a:	8082                	ret

000000008000812c <lst_pop>:

void*
lst_pop(struct list *lst) {
    8000812c:	1101                	addi	sp,sp,-32
    8000812e:	ec06                	sd	ra,24(sp)
    80008130:	e822                	sd	s0,16(sp)
    80008132:	e426                	sd	s1,8(sp)
    80008134:	1000                	addi	s0,sp,32
  if(lst->next == lst)
    80008136:	6104                	ld	s1,0(a0)
    80008138:	00a48d63          	beq	s1,a0,80008152 <lst_pop+0x26>
    panic("lst_pop");
  struct list *p = lst->next;
  lst_remove(p);
    8000813c:	8526                	mv	a0,s1
    8000813e:	00000097          	auipc	ra,0x0
    80008142:	fd8080e7          	jalr	-40(ra) # 80008116 <lst_remove>
  return (void *)p;
}
    80008146:	8526                	mv	a0,s1
    80008148:	60e2                	ld	ra,24(sp)
    8000814a:	6442                	ld	s0,16(sp)
    8000814c:	64a2                	ld	s1,8(sp)
    8000814e:	6105                	addi	sp,sp,32
    80008150:	8082                	ret
    panic("lst_pop");
    80008152:	00002517          	auipc	a0,0x2
    80008156:	bfe50513          	addi	a0,a0,-1026 # 80009d50 <userret+0xcc0>
    8000815a:	ffff8097          	auipc	ra,0xffff8
    8000815e:	3fa080e7          	jalr	1018(ra) # 80000554 <panic>

0000000080008162 <lst_push>:

void
lst_push(struct list *lst, void *p)
{
    80008162:	1141                	addi	sp,sp,-16
    80008164:	e422                	sd	s0,8(sp)
    80008166:	0800                	addi	s0,sp,16
  struct list *e = (struct list *) p;
  e->next = lst->next;
    80008168:	611c                	ld	a5,0(a0)
    8000816a:	e19c                	sd	a5,0(a1)
  e->prev = lst;
    8000816c:	e588                	sd	a0,8(a1)
  lst->next->prev = p;
    8000816e:	611c                	ld	a5,0(a0)
    80008170:	e78c                	sd	a1,8(a5)
  lst->next = e;
    80008172:	e10c                	sd	a1,0(a0)
}
    80008174:	6422                	ld	s0,8(sp)
    80008176:	0141                	addi	sp,sp,16
    80008178:	8082                	ret

000000008000817a <lst_print>:

void
lst_print(struct list *lst)
{
    8000817a:	7179                	addi	sp,sp,-48
    8000817c:	f406                	sd	ra,40(sp)
    8000817e:	f022                	sd	s0,32(sp)
    80008180:	ec26                	sd	s1,24(sp)
    80008182:	e84a                	sd	s2,16(sp)
    80008184:	e44e                	sd	s3,8(sp)
    80008186:	1800                	addi	s0,sp,48
  for (struct list *p = lst->next; p != lst; p = p->next) {
    80008188:	6104                	ld	s1,0(a0)
    8000818a:	02950063          	beq	a0,s1,800081aa <lst_print+0x30>
    8000818e:	892a                	mv	s2,a0
    printf(" %p", p);
    80008190:	00002997          	auipc	s3,0x2
    80008194:	bc898993          	addi	s3,s3,-1080 # 80009d58 <userret+0xcc8>
    80008198:	85a6                	mv	a1,s1
    8000819a:	854e                	mv	a0,s3
    8000819c:	ffff8097          	auipc	ra,0xffff8
    800081a0:	412080e7          	jalr	1042(ra) # 800005ae <printf>
  for (struct list *p = lst->next; p != lst; p = p->next) {
    800081a4:	6084                	ld	s1,0(s1)
    800081a6:	fe9919e3          	bne	s2,s1,80008198 <lst_print+0x1e>
  }
  printf("\n");
    800081aa:	00001517          	auipc	a0,0x1
    800081ae:	0e650513          	addi	a0,a0,230 # 80009290 <userret+0x200>
    800081b2:	ffff8097          	auipc	ra,0xffff8
    800081b6:	3fc080e7          	jalr	1020(ra) # 800005ae <printf>
}
    800081ba:	70a2                	ld	ra,40(sp)
    800081bc:	7402                	ld	s0,32(sp)
    800081be:	64e2                	ld	s1,24(sp)
    800081c0:	6942                	ld	s2,16(sp)
    800081c2:	69a2                	ld	s3,8(sp)
    800081c4:	6145                	addi	sp,sp,48
    800081c6:	8082                	ret
	...

0000000080009000 <trampoline>:
    80009000:	14051573          	csrrw	a0,sscratch,a0
    80009004:	02153423          	sd	ra,40(a0)
    80009008:	02253823          	sd	sp,48(a0)
    8000900c:	02353c23          	sd	gp,56(a0)
    80009010:	04453023          	sd	tp,64(a0)
    80009014:	04553423          	sd	t0,72(a0)
    80009018:	04653823          	sd	t1,80(a0)
    8000901c:	04753c23          	sd	t2,88(a0)
    80009020:	f120                	sd	s0,96(a0)
    80009022:	f524                	sd	s1,104(a0)
    80009024:	fd2c                	sd	a1,120(a0)
    80009026:	e150                	sd	a2,128(a0)
    80009028:	e554                	sd	a3,136(a0)
    8000902a:	e958                	sd	a4,144(a0)
    8000902c:	ed5c                	sd	a5,152(a0)
    8000902e:	0b053023          	sd	a6,160(a0)
    80009032:	0b153423          	sd	a7,168(a0)
    80009036:	0b253823          	sd	s2,176(a0)
    8000903a:	0b353c23          	sd	s3,184(a0)
    8000903e:	0d453023          	sd	s4,192(a0)
    80009042:	0d553423          	sd	s5,200(a0)
    80009046:	0d653823          	sd	s6,208(a0)
    8000904a:	0d753c23          	sd	s7,216(a0)
    8000904e:	0f853023          	sd	s8,224(a0)
    80009052:	0f953423          	sd	s9,232(a0)
    80009056:	0fa53823          	sd	s10,240(a0)
    8000905a:	0fb53c23          	sd	s11,248(a0)
    8000905e:	11c53023          	sd	t3,256(a0)
    80009062:	11d53423          	sd	t4,264(a0)
    80009066:	11e53823          	sd	t5,272(a0)
    8000906a:	11f53c23          	sd	t6,280(a0)
    8000906e:	140022f3          	csrr	t0,sscratch
    80009072:	06553823          	sd	t0,112(a0)
    80009076:	00853103          	ld	sp,8(a0)
    8000907a:	02053203          	ld	tp,32(a0)
    8000907e:	01053283          	ld	t0,16(a0)
    80009082:	00053303          	ld	t1,0(a0)
    80009086:	18031073          	csrw	satp,t1
    8000908a:	12000073          	sfence.vma
    8000908e:	8282                	jr	t0

0000000080009090 <userret>:
    80009090:	18059073          	csrw	satp,a1
    80009094:	12000073          	sfence.vma
    80009098:	07053283          	ld	t0,112(a0)
    8000909c:	14029073          	csrw	sscratch,t0
    800090a0:	02853083          	ld	ra,40(a0)
    800090a4:	03053103          	ld	sp,48(a0)
    800090a8:	03853183          	ld	gp,56(a0)
    800090ac:	04053203          	ld	tp,64(a0)
    800090b0:	04853283          	ld	t0,72(a0)
    800090b4:	05053303          	ld	t1,80(a0)
    800090b8:	05853383          	ld	t2,88(a0)
    800090bc:	7120                	ld	s0,96(a0)
    800090be:	7524                	ld	s1,104(a0)
    800090c0:	7d2c                	ld	a1,120(a0)
    800090c2:	6150                	ld	a2,128(a0)
    800090c4:	6554                	ld	a3,136(a0)
    800090c6:	6958                	ld	a4,144(a0)
    800090c8:	6d5c                	ld	a5,152(a0)
    800090ca:	0a053803          	ld	a6,160(a0)
    800090ce:	0a853883          	ld	a7,168(a0)
    800090d2:	0b053903          	ld	s2,176(a0)
    800090d6:	0b853983          	ld	s3,184(a0)
    800090da:	0c053a03          	ld	s4,192(a0)
    800090de:	0c853a83          	ld	s5,200(a0)
    800090e2:	0d053b03          	ld	s6,208(a0)
    800090e6:	0d853b83          	ld	s7,216(a0)
    800090ea:	0e053c03          	ld	s8,224(a0)
    800090ee:	0e853c83          	ld	s9,232(a0)
    800090f2:	0f053d03          	ld	s10,240(a0)
    800090f6:	0f853d83          	ld	s11,248(a0)
    800090fa:	10053e03          	ld	t3,256(a0)
    800090fe:	10853e83          	ld	t4,264(a0)
    80009102:	11053f03          	ld	t5,272(a0)
    80009106:	11853f83          	ld	t6,280(a0)
    8000910a:	14051573          	csrrw	a0,sscratch,a0
    8000910e:	10200073          	sret
